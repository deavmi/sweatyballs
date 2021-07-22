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
        handlersLock = new Mutex();
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

    alias LinkUnitHandler = void function (LinkUnit);

    private LinkUnitHandler[ubyte] handlers;
    private Mutex handlersLock;

    public void registerHandler(LinkUnitHandler funcPtr, ubyte code)
    {
        handlersLock.lock();
        handlers[code] = funcPtr;
        handlersLock.unlock();
    }

    private LinkUnitHandler defaultHandler;

    public void setDefaultHandler(LinkUnitHandler funcPtr)
    {
        defaultHandler = funcPtr;
    }

    /**
    * Returns the given handler function associated
    * with the provided message type.
    *
    * If the message type is not found then a default
    * handler is returned
    *
    * TODO: I should work on eventy again and use that
    * for this project then (next version)
    */
    public LinkUnitHandler getHandler(ubyte code)
    {
        LinkUnitHandler handler;

        handlersLock.lock();

        handler = *(code in handlers);

        if(!handler)
        {
            handler = defaultHandler;
        }

        handlersLock.unlock();
    
        
        return handler;
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


        /**
        * Get the handler required for the given message type
        * and call it
        */
        LinkUnitHandler handlerFunc = getHandler(to!(ubyte)(message.type));
        handlerFunc(unit);




        /* Handle route advertisements */
        if(mType == LinkMessageType.ADVERTISEMENT)
        {
            
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
                    LinkUnit unit = new LinkUnit(address, message, link);

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