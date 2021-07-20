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
    private Session[] sessions;

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

    private Neighbor isNeighbour(string address)
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
        /* TODO: Generate signature */

        /* Encrypt the payload to `toAddress` (final destination) */
        ubyte[] encryptedPayload = RSA.encrypt(toAddress, cast(ubyte[])data);
        packet.payload = encryptedPayload;

        return packet;
    }

    /**
    * Send a packet
    *
    * Send a packet containing `data` to node at `address`
    */
    public void sendPacket(string address, byte[] data)
    {
        /* Next-hop (for delivery), this is either a router or destination direct */
        Neighbor nextHop;

        /* Construct a Datapacket */

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
            Route routeToHost = engine.getRouter().getTable().lookup(address);
            if(routeToHost)
            {
                /* Set the next hop to the neighbor with the address in the route entry */
                nextHop = routeToHost.getNexthop();
                gprintln("sendPacket: Next-hop (indirect): "~to!(string)(routeToHost));
            }
            else
            {
                gprintln("sendPacket: No route to "~address, DebugType.ERROR);
            }
        }



        /* TODO: Validate key */

        /* TODO: Add signature */

        /* Encrypt the payload to `address` (final destination) */
        ubyte[] encryptedPayload = RSA.encrypt(address, cast(ubyte[])data);

        import libsweatyballs.link.message.core;

        LinkMessage d;


        /* ProtoBuf encoded message */
        byte[] message;

        /* TODO: Open socket to Neighbor and send the ProtoBuf-encoded and encrypted payload packet */
        bool status = sendNBR(message, nextHop.getAddress());
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

    /* TODO: Move this elsewhere */
    public class Session : Thread
    {
        private string aesKey;
        private string sessionID;

        private Socket neighborSock;

        this(Socket clientSocket)
        {
            super(&worker);
            this.neighborSock = neighborSock;
        }

        private void worker()
        {

        }
    }

    private Session fetchSession(string address)
    {
        return null;
    }

    private Session createSession(string address)
    {
        /* TODO: Generate random AES key */

        return null;
    }

    private bool isSessionExists(string address)
    {
        /* Lock sessions */

        /* Find the session */
        foreach(Session session; sessions)
        {

        }


        /* Unlockk sessions */

        return true;
    }
}