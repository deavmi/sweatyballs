module libsweatyballs.router.core;

import libsweatyballs.link.core : Link;
import libsweatyballs.security.identity : Identity;
import core.thread : Thread;
import core.sync.mutex : Mutex;
import libsweatyballs.router.advertiser : Advertiser;

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

    private Advertiser advertiser;

    this(Identity identity, Link[] links)
    {
        /* Set the thread's worker function */
        super(&worker);

        /* Initialize locks */
        initMutexes();

        /* Initialize the advertiser */
        initAdvertiser();
    }

    /**
    * Initializes all the mutexes
    */
    private void initMutexes()
    {
        linksMutex = new Mutex();
    }

    private void initAdvertiser()
    {
        advertiser = new Advertiser(this);
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

        /* Launch the routes advertiser */
        advertiser.launch();
    }
}