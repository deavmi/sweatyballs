module libsweatyballs.router.core;

import libsweatyballs.link.core : Link;
import libsweatyballs.security.identity : Identity;
import core.thread : Thread;
import core.sync.mutex : Mutex;

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
    private Mutex linksMutex;

    this(Identity identity, Link[] links)
    {
        /* Set the thread's worker function */
        super(&worker);

        /* Initialize locks */
        initMutexes();
    }

    /**
    * Initializes all the mutexes
    */
    private void initMutexes()
    {
        linksMutex = new Mute();
    }

    private void worker()
    {
        /* TODO: Implement me */
        while(true)
        {
            /* TODO: Cycle through each with timeout wait */
        }
    }

    public void launch()
    {
        start();
    }
}