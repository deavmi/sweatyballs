module libsweatyballs.router.core;

import libsweatyballs.link.core : Link;
import libsweatyballs.security.identity : Identity;
import core.thread : Thread, dur;
import core.sync.mutex : Mutex;
import libsweatyballs.router.advertiser : Advertiser;
import libsweatyballs.link.message.core : Message, test;

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

        this.links = links;

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
            /* Cycle through the in queue of each link */
            Link[] links = getLinks();
            foreach(Link link; links)
            {
                /* Check if the in-queue has anything in it */
                if(link.hasInQueue())
                {
                    Message message = link.popInQueue();
                    process(message);
                }
            }

            process(null);

            sleep(dur!("seconds")(1));
        }
    }

    private void process(Message messageIn)
    {
        import std.stdio;
        import google.protobuf;
        writeln(test().toProtobuf);
    }

    public Link[] getLinks()
    {
        Link[] copy;

        linksMutex.lock();
        foreach(Link link; links)
        {
            copy ~= link;
        }
        linksMutex.unlock();

        return copy;
    }

    public void launch()
    {
        start();

        /* Launch the routes advertiser */
        advertiser.launch();
    }
}