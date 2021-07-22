module libsweatyballs.link.core;

import libsweatyballs.link.message.core;
import libsweatyballs.link.unit : LinkUnit;
import core.sync.mutex : Mutex;
import libsweatyballs.engine.core : Engine;
import core.thread : Thread;
import bmessage;
import std.socket;
import gogga;
import std.conv : to;
import google.protobuf;
import libsweatyballs.router.table : Route;
import libsweatyballs.zwitch.neighbor : Neighbor;
import std.string : cmp;

/**
* Link
*
* Description: Represents a "pipe" whereby different protocol messages can be transported over.
* Such protocol messages include data packet transport (receiving and sending) along with
* router advertisements messages
*
* This class handles the Message queues for sending and receiving messages (and partially decoding them)
*/
public final class Link : Thread
{
    /**
    * In and out queues
    */
    private LinkUnit[] inQueue;
    private LinkUnit[] outQueue;
    private Mutex inQueueLock;
    private Mutex outQueueLock;

    private string interfaceName;


    private Engine engine;


    private Watcher advWatch;
    private Watcher neighWatch;

    this(string interfaceName, Engine engine)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.interfaceName = interfaceName;
        this.engine = engine;

        /* Initialize locks */
        initMutexes();

        /* Setup watchers */
        setupWatchers();
    }

    public string getInterface()
    {
        return interfaceName;
    }

    /**
    * Initialize the queue mutexes
    */
    private void initMutexes()
    {
        inQueueLock = new Mutex();
        outQueueLock = new Mutex();
    }

    /**
    * Sets up watchers, one for advertisements and one for
    * nieghbor-to-neighbor communications
    */
    private void setupWatchers()
    {
        /* Setup the advertisement socket (bound to ff02::1%interface) port 6666 */
        Socket mcastSock = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);
        mcastSock.bind(parseAddress("ff02::1%"~getInterface(), 6666));

        /* Setup the advertisement watcher */
        advWatch = new Watcher(this, mcastSock);


        /* Setup the router-to-router socket (bound to ::) port 6667 */
        Socket neighSock = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);
        neighSock.bind(parseAddress("::", 0));

        /* Setup the neighbor watcher */
        neighWatch = new Watcher(this, neighSock);
    }

    /**
    * Returns the router-to-router port being used for this link
    */
    public ushort getR2RPort()
    {
        return neighWatch.getPort();
    }

    /**
    * Listens for advertisements
    *
    * TODO: We also must listen for traffic here though
    */
    private void worker()
    {
        while(true)
        {

            /**
            * Check if there are any LinkUnit's to be processed
            * then process them
            */
            // gprintln(hasInQueue());
        
            if(hasInQueue())
            {
                /* Pop off a message */
                LinkUnit unit = popInQueue();

                /* Process message */
                process(unit); 

                gprintln("Pablo");
            }

            
        }
    }


    /**
    * Given Address we take the IP address (not source port of mcast packet)
    * and then also the `nieghborPort` and spit out a new Address
    */
    private static Address getNeighborIPAddress(Address sender, ushort neighborPort)
    {
        /* IPv6 reachable neighbor socket */
        Address neighborAddress = parseAddress(sender.toAddrString(), neighborPort);

        return neighborAddress;
    }

    /**
    * This will process the message
    *
    * Handles message type: SESSION, ADVERTISEMENT
    */
    private void process(LinkUnit unit)
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


        gprintln("Processing message from "~to!(string)(sender)~
                " of type "~to!(string)(mType));
        gprintln("Public key: "~identity);
        gprintln("Signature: Not yet implemented");
        gprintln("Neighbor Port: "~to!(string)(neighborPort));



        /**
        * Enter the Neighbor details into the Switch
        */
        Address neighborAddress = getNeighborIPAddress(sender, neighborPort);
        Neighbor neighbor = new Neighbor(identity, neighborAddress, this);
        engine.getSwitch().addNeighbor(neighbor);




        /* Handle route advertisements */
        if(mType == LinkMessageType.ADVERTISEMENT)
        {
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
        /* Handle session messages */
        else if(mType == LinkMessageType.PACKET)
        {
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
        /* TODO: Does protobuf throw en error if so? */
        else
        {
            assert(false);
        }
    }

    public static LinkMessage decode(byte[] data)
    {
        try
        {
            ubyte[] dataIn = cast(ubyte[])data;
            LinkMessage message = fromProtobuf!(LinkMessage)(dataIn);
            return message;
        }
        catch(ProtobufException)
        {
            return null;
        }
    }

    public void enqueueIn(LinkUnit unit)
    {
        /* Add to the in-queue */
        inQueueLock.lock();
        inQueue ~= unit;
        inQueueLock.unlock();
    }

    

    public bool hasInQueue()
    {
        bool status;
        inQueueLock.lock();
        status = inQueue.length != 0;
        inQueueLock.unlock();
        return status;
    }

    public LinkUnit popInQueue()
    {
        LinkUnit message;

        /* TODO: Throw exception on `hasInQueue()` false */

        inQueueLock.lock();

        /* Pop the message */
        message = inQueue[0];

        if(inQueue.length == 1)
        {
            inQueue.length = 0;
        }
        else
        {
            inQueue = inQueue[1..inQueue.length];
        }

        inQueueLock.unlock();

        return message;
    }

    // public bool hasOutQueue()
    // {
    //     bool status;
    //     inQueueLock.lock();
    //     status = inQueue.length != 0;
    //     inQueueLock.unlock();
    //     return status;
    // }

    


    public void launch()
    {
        start();

        advWatch.start();
        neighWatch.start();
    }



    /**
    * Blocks to receive one message from the incoming queue
    */
    public LinkMessage receive()
    {
        /* TODO: Implement me */
        return null;
    }

    /**
    * Sends a message
    */
    public void send(LinkMessage message, string recipient)
    {
        /* TODO: Implement me */
    }
}

/**
* Watcher
*
* Given a socket this will dequeue message, decode them and pass
* them up to the Link for processing
*/
public final class Watcher : Thread
{
    private Socket socket;
    private Link link;

    this(Link link,  Socket socket)
    {
        super(&worker);
        this.link = link;
        this.socket = socket;
    }

    public ushort getPort()
    {
        return to!(ushort)(socket.localAddress.toPortString());
    }

    /**
    * Listens for advertisements
    *
    * TODO: We also must listen for traffic here though
    */
    private void worker()
    {
        while(true)
        {

            /**
            * MSG_PEEK, we don't want to dequeue this message yet but need to call receive
            * MSG_TRUNC, return the number of bytes of the datagram even when
            * bigger than passed in array
            */
            SocketFlags flags;
            flags |= MSG_TRUNC;
            flags |= MSG_PEEK;

            /* Receive buffer */
            byte[] data;
            Address address;

            /* Empty array won't work */
            data.length = 1;
            
            gprintln("Awaiting message...");
            long len = socket.receiveFrom(data, flags, address);

            if(len <= 0)
            {
                /* TODO: Error handling */
            }
            else
            {
                /* Receive at the length found */
                data.length = len;
                socket.receiveFrom(data, address);

                /* Decode the message */
                LinkMessage message = Link.decode(data);

                /* If decoding worked */
                if(message)
                {
                    /* Couple Address-and-message */
                    LinkUnit unit = new LinkUnit(address, message);

                    /* Process message */
                    link.enqueueIn(unit); 
                }
                /* If ProtocolBuffer decoding failed */
                else
                {
                    gprintln("Watcher: ProtocolBuffer decode failed", DebugType.ERROR);
                }
            }
            
        }
    }
}