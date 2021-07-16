module libsweatyballs.zwitch.core;

import libsweatyballs.router.core : Router;
import core.thread : Thread;

/**
* Switch
*
* Description: TODO
*
*/
public final class Switch : Thread
{
    private Router router;
    private Session[] sessions;

    this(Router router)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.router = router;
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