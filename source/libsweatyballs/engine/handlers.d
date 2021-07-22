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

        /**
        * Create a new route with `nexthop` as the nexthop address
        * Also set its metric to whatever it is +64
        */
        Route newRoute = new Route(route.address, neighbor, 100, metric+64);

        gprintln(route.address);
        gprintln(engine.getRouter().getIdentity().getKeys().publicKey);

        /**
        * Don't add routes to oneself
        */
        if(cmp(route.address, engine.getRouter().getIdentity().getKeys().publicKey) != 0)
        {
            /**
            * Don;t add routes we advertised (from ourself) - this
            * ecludes self route checked before entering here
            */
            if(newRoute.getNexthop().getIdentity() != engine.getRouter().getIdentity().getKeys().publicKey)
            {
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
                    if(possibleExistingRoute.getMetric() > newRoute.getMetric())
                    {
                        /* Remove the old one (higher metric than advertised route) */
                        engine.getRouter().getTable().removeRoute(possibleExistingRoute);

                        /* Install the advertised route (lower metric than currently installed route) */
                        engine.getRouter().getTable().addRoute(newRoute);
                    }
                }
                
            }
            else
            {
                gprintln("Not adding a route that originated from us", DebugType.ERROR);
            }
        
        }
        else
        {
            gprintln("Skipping addition of self-route", DebugType.WARNING);
        }
    }
}

public void pktHandler(LinkUnit unit)
{
    gprintln("pktHandler!!!!!!!!!! "~unit.toString());
}

public void defaultHandler(LinkUnit unit)
{
    gprintln("Unknown mesage type!!!!!!!!!! "~unit.toString());
}