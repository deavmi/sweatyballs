module libsweatyballs.zwitch.core;

import libsweatyballs.engine.core : Engine;
import core.thread : Thread;

/**
* Switch
*
* Description: TODO
*
*/
public final class Switch : Thread
{
    private Engine engine;
    private Session[] sessions;

    this(Engine engine)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.engine = engine;
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