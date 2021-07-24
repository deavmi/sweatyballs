module libsweatyballs.engine.handlers;

import libsweatyballs.link.unit;
import libsweatyballs.link.message.core;
import libsweatyballs.engine.core;
import gogga;
import google.protobuf;
import std.string : cmp;
import std.conv : to;
import libsweatyballs.router.table : Route;
import std.socket : Address;
import libsweatyballs.zwitch.neighbor : Neighbor;
import libsweatyballs.link.core : Link;
import std.datetime : SysTime;

public __gshared Engine engine;

public void advHandler(LinkUnit unit)
{
    /**
    * Message details
    *
    * 1. Public key of Link Neighbor
    * 2. Signature of Link Neighbor
    * 3. Neighbor port of LinkNeighbor
    * 4. Message type (also from LinkUnit address)
    * 5. Payload
    */
    link.LinkMessage message = unit.getMessage();
    link.LinkMessageType mType = message.type;
    Address sender = unit.getSender();
    string identity = message.publicKey;
    ushort neighborPort = to!(ushort)(message.neighborPort);
    ubyte[] msgPayload = message.payload;


    Address neighborAddress = Link.getNeighborIPAddress(sender, neighborPort);
    Neighbor neighbor = new Neighbor(identity, neighborAddress, unit.getLink());



    gprintln("advHandler!!!!!!!!!! "~unit.toString());

    Advertisement advMsg = fromProtobuf!(link.Advertisement)(msgPayload);

    /* Get the routes being advertised */
    RouteEntry[] routes = advMsg.routes;
    gprintln("Total of "~to!(string)(routes.length)~" received");

    /* TODO: Do router2router verification here */

    /* Add each route to the routing table */
    foreach(RouteEntry route; routes)
    {
        uint metric = route.metric;
        SysTime routeCreationTime;
        routeCreationTime.fromISOString(route.creationTime);

        /**
        * Create a new route with `nexthop` as the nexthop address
        * Also set its metric to whatever it is +64
        */
        Route newRoute = new Route(route.address, neighbor, routeCreationTime, 100, metric+64);

       
        /**
        * TODO: Found it, only install routes if their updated metric on arrival is lesser than current route
        * TODO: Search for existing route
        * TODO: This might make above constraints nmeaningless, or well atleast the one above me (outer one not me thinks)
        */
        Route possibleExistingRoute = engine.getRouter().getTable().lookup(route.address);

        /* If no route exists then add it */
        if(!possibleExistingRoute)
        {
            engine.getRouter().getTable().addRoute(newRoute);
        }
        /* If a route exists only install it if current one has higher metric than advertised one */
        else
        {
            /**
            * If the route is already installed then simply update the creationTime field
            */
            if(possibleExistingRoute == newRoute)
            {
                /* TODO: Even more reason to lock the table */
                possibleExistingRoute.updateCreationTime(routeCreationTime);
            }
            /**
            * If the routes are not the same then go and check the metric to see if it is better
            * and only install it if so
            *
            * TODO: Lock WHOLE table when doing these things (the below code is not logically safe)
            */
            else if(possibleExistingRoute.getMetric() > newRoute.getMetric())
            {
                /* Remove the old one (higher metric than advertised route) */
                engine.getRouter().getTable().removeRoute(possibleExistingRoute);

                /* Install the advertised route (lower metric than currently installed route) */
                engine.getRouter().getTable().addRoute(newRoute);
            }
            else
            {
                /* TODO: Nothing needs to be done here */
            }
        }
    }
}

public void pktHandler(LinkUnit unit)
{
    /**
    * Message details
    *
    * 1. Public key of Link Neighbor
    * 2. Signature of Link Neighbor
    * 3. Neighbor port of LinkNeighbor
    * 4. Message type (also from LinkUnit address)
    * 5. Payload
    */
    link.LinkMessage message = unit.getMessage();
    link.LinkMessageType mType = message.type;
    Address sender = unit.getSender();
    string identity = message.publicKey;
    ushort neighborPort = to!(ushort)(message.neighborPort);
    ubyte[] msgPayload = message.payload;


    Address neighborAddress = Link.getNeighborIPAddress(sender, neighborPort);
    Neighbor neighbor = new Neighbor(identity, neighborAddress, unit.getLink());

    gprintln("pktHandler!!!!!!!!!! "~unit.toString());


    gprintln("Woohoo! PACKET received!", DebugType.WARNING);

    try
    {

        /* TODO: Now check if destined to me, if so THEN attempt decrypt */
        link.Packet packet = fromProtobuf!(link.Packet)(msgPayload);
        gprintln("Payload (encrypted): "~to!(string)(packet.payload));

        /* Attempt decrypting with my key */
        import crypto.rsa;
        import std.string : cmp;

        /* TODO: Make sure decryotion passes, maybe add a PayloadBytes thing to use that */
        ubyte[] decryptedPayload = RSA.decrypt(engine.getRouter().getIdentity().getKeys().privateKey, packet.payload);
        gprintln("Payload (decrypted): "~cast(string)(decryptedPayload));

        /* Now see if it is destined to us */

        /* If it is destined to us (TODO: Accept it) */
        if(cmp(packet.toKey, engine.getRouter().getIdentity().getKeys().publicKey) == 0)
        {
            gprintln("PACKET IS ACCEPTED TO ME", DebugType.WARNING);

            bool stat = engine.getSwitch().isNeighbour(packet.fromKey) !is null;
            gprintln("WasPacketFromNeighbor: "~to!(string)(stat), DebugType.WARNING);

            /* Deliver this to the engine */
            engine.newPacket(packet);
        }
        /* If it is not destined to me then forward it */
        else
        {
            engine.getSwitch().forward(packet);
            gprintln("PACKET IS FORWRDED", DebugType.WARNING);
        }
    
    }
    catch(ProtobufException)
    {
        gprintln("Failed to deserialize protobuff bytes", DebugType.ERROR);
    }
}

public void defaultHandler(LinkUnit unit)
{
    gprintln("Unknown mesage type!!!!!!!!!! "~unit.toString());
}