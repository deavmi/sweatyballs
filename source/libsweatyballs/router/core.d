module libsweatyballs.router.core;

import libsweatyballs.link.core : Link;
import libsweatyballs.security.identity : Identity;
import core.thread : Thread;

/**
* Router
*
* Description: TODO
*/
public final class Router : Thread
{
    /**
    * Links the router can advertise over
    */
    private Link[] links;

    this(Identity identity, Link[] links)
    {
        /* Set the thread's worker function */
        super(&worker);
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
}