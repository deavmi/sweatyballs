module libsweatyballs.zwitch.core;

import libsweatyballs.engine.core : Engine;
import core.thread : Thread;
import crypto.rsa : RSA;
import libsweatyballs.zwitch.neighbor : Neighbor;
import core.sync.mutex : Mutex;
import std.string : cmp;
import std.conv : to;
import gogga;
import std.socket;
import libsweatyballs.router.table : Route;
import libsweatyballs.link.message.core;
import std.array : array;
import google.protobuf;

/**
* Switch
*
* Manages session (far) and neighbour comms
*
* You send and receive data here. The switch asks router for routes
* and then sends stuff on the next-hop to them (if direct) or via them
* (indirect/routed-through)
*/
public final class Switch : Thread
{
    private Engine engine;
    // private Session[] sessions;

    /**
    * Neighboring nodes
    */
    private Neighbor[] neighbors;
    private Mutex neighborsLock;

    /**
    * Neighbor communications
    *
    * Node-to-node
    */
    private Socket neighborSocket;

    this(Engine engine)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.engine = engine;
   
        /* Initialize locks */
        initMutexes();
    }

    /**
    * Initializes all the mutexes
    */
    private void initMutexes()
    {
        neighborsLock = new Mutex();
    }

    public Neighbor[] getNeighbors()
    {
        Neighbor[] copy;

        neighborsLock.lock();
        foreach(Neighbor neighbor; neighbors)
        {
            copy ~= neighbor;
        }
        neighborsLock.unlock();

        return copy;
    }

    public void addNeighbor(Neighbor neighbor)
    {
        /* Lock the neighbors table */
        neighborsLock.lock();

        /* Add the route (only if it doesn't already exist) */
        foreach(Neighbor cNeighbour; neighbors)
        {
            /* If the neighbor is already known of */
            /* TODO: Add neighbor expirations */
            if(cmp(cNeighbour.getIdentity(), neighbor.getIdentity()) == 0)
            {
                goto no_add_neighbor;
            }
        }

        neighbors ~= neighbor;
        gprintln("NeighborDB: Added a new neighbor "~to!(string)(neighbor));
        
        no_add_neighbor:

        /* Unlock the neighbors table */
        neighborsLock.unlock();
    }

    private void initSockets()
    {
        neighborSocket = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);
    }

    private void worker()
    {
        /* TODO: Implement me */
        while(true)
        {

        }
    }

    public void launch()
    {
        start();
    }

    public Neighbor isNeighbour(string address)
    {
        Neighbor match;

        Neighbor[] neighbors = getNeighbors();
        foreach(Neighbor neighbor; neighbors)
        {
            if(cmp(neighbor.getIdentity(), address) == 0)
            {
                match = neighbor;
                break;
            }
        }

        return match;
    }


    private Packet constructPacket(string toAddress, string fromAddress, byte[] data)
    {
        /* The final message */
        Packet packet = new Packet();
        packet.fromKey = fromAddress;
        packet.toKey = toAddress;
        packet.siganture = "not yet implemented";
        packet.ttl = 64;
        /* TODO: Generate signature */

        /* Encrypt the payload to `toAddress` (final destination) */
        ubyte[] encryptedPayload = RSA.encrypt(toAddress, cast(ubyte[])data);
        packet.payload = encryptedPayload;

        return packet;
    }

    // private LinkMessage constructLinkMessage(byte[] data, LinkMessageType type, string )

    /**
    * Send a packet
    *
    * Send a packet containing `data` to node at `address`
    * from `us`
    */
    public void sendPacket(string address, byte[] data)
    {
        /* Construct the packet */
        Packet packet = constructPacket(address, engine.getRouter().getIdentity().getKeys().publicKey, data);

        /* LinkMessage */
        LinkMessage linkMsg = new LinkMessage();
        linkMsg.type = LinkMessageType.PACKET;
        linkMsg.publicKey = engine.getRouter().getIdentity().getKeys().publicKey;
        linkMsg.signature = "not yet implemented";
        linkMsg.payload = cast(ubyte[])array(toProtobuf(packet));
        
        /* Next-hop (for delivery), this is either a router or destination direct */
        Neighbor nextHop;


        /* Find out whether `address` is local (a neighbour) or not */
        Neighbor possibleNeighbor = isNeighbour(address);
        if(possibleNeighbor)
        {
            gprintln("sendPacket: We are sending to a neighor", DebugType.WARNING);
            nextHop = possibleNeighbor;
        }
        else
        {
            gprintln("sendPacket: We are sending to a node VIA router", DebugType.WARNING);

            /* Make sure there is a route entry for it */
            engine.getRouter().getTable().lockTable();
            Route routeToHost = engine.getRouter().getTable().lookup(address);
            engine.getRouter().getTable().unlockTable();
            if(routeToHost)
            {
                /* Set the next hop to the neighbor with the address in the route entry */
                nextHop = routeToHost.getNexthop();
                gprintln("sendPacket: Next-hop (indirect): "~to!(string)(routeToHost));
            }
            else
            {
                gprintln("sendPacket: No route to "~address, DebugType.ERROR);
                return;
            }
        }



        /* TODO: Validate key */

        /* TODO: Add signature */

        import libsweatyballs.link.message.core;

        
        /* Set neighbor port depending on which link it goes out on */
        linkMsg.neighborPort = to!(string)(nextHop.getLink().getR2RPort());

        /* ProtoBuf encoded message */
        byte[] message = cast(byte[])array(toProtobuf(linkMsg));

        /* TODO: Open socket to Neighbor and send the ProtoBuf-encoded and encrypted payload packet */
        bool status = sendNBR(message, nextHop.getAddress());
        gprintln("SendNBR Status: "~to!(string)(status));
        /* TODO: Handle status */
    }

    /**
    * Opens a socket and sends `data` to `address`
    *
    * Returns status
    */
    private bool sendNBR(byte[] data, Address address)
    {
        try
        {
            Socket neighborSocket = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);
            long status = neighborSocket.sendTo(data, address);

            return status > 0;
        }
        catch(SocketOSException)
        {
            return false;
        }
    }

    public void forward(Packet packet)
    {
        /* Decrement ttl */
        packet.ttl--;
        if(packet.ttl == 0)
        {
            gprintln("TTL REACHED, DAAI DING IS DOOD!", DebugType.ERROR);
            return;
        }

        string address = packet.toKey;

        /* Next-hop (for delivery), this is either a router or destination direct */
        Neighbor nextHop;
        
        /* Make sure there is a route entry for it */
        Route routeToHost = engine.getRouter().getTable().lookup(address);
        if(routeToHost)
        {
            /* Set the next hop to the neighbor with the address in the route entry */
            nextHop = routeToHost.getNexthop();
            gprintln("foward(): Next-hop (router): "~to!(string)(routeToHost));
        }
        else
        {
            gprintln("foward(): No route to "~address, DebugType.ERROR);
            return;
        }

        /* LinkMessage */
        LinkMessage linkMsg = new LinkMessage();
        linkMsg.type = LinkMessageType.PACKET;
        linkMsg.publicKey = engine.getRouter().getIdentity().getKeys().publicKey;
        linkMsg.signature = "not yet implemented";
        linkMsg.payload = cast(ubyte[])array(toProtobuf(packet));

        /* Set neighbor port depending on which link it goes out on */
        linkMsg.neighborPort = to!(string)(nextHop.getLink().getR2RPort());

        /* ProtoBuf encoded message */
        byte[] message = cast(byte[])array(toProtobuf(linkMsg));

        /* TODO: Open socket to Neighbor and send the ProtoBuf-encoded and encrypted payload packet */
        bool status = sendNBR(message, nextHop.getAddress());
        gprintln("SendNBR Status: "~to!(string)(status));
        /* TODO: Handle status */
    }

   

}