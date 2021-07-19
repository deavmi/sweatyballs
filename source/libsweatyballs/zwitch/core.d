module libsweatyballs.zwitch.core;

import libsweatyballs.engine.core : Engine;
import core.thread : Thread;
import crypto.rsa : RSA;
import libsweatyballs.zwitch.neighbor : Neighbor;
import core.sync.mutex : Mutex;
import std.string : cmp;
import std.conv : to;
import gogga;

/**
* Switch
*
* Manages session (far and local)
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

    /**
    * Send a packet
    *
    * Send a packet containing `data` to node at `address`
    */
    public void sendPacket(string address, byte[] data)
    {
        /* Construct a Datapacket */



        /* TODO: Validate key */

        /* TODO: Add signature */
        /* Encrypt the payload to `address` */
        ubyte[] encryptedPayload = RSA.encrypt(address, cast(ubyte[])data);

    }

    /* TODO: Move this elsewhere */
    public class Session
    {
        private string aesKey;
        private string sessionID;
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