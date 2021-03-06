module libsweatyballs.engine.core;

import libsweatyballs.router.core : Router;
import libsweatyballs.router.table;
import libsweatyballs.zwitch.core : Switch;
import libsweatyballs.zwitch.neighbor;
import libsweatyballs.link.core : Link;
import core.sync.mutex : Mutex;
import libsweatyballs.engine.configuration : Config;
import std.conv : to;
import gogga;
import core.thread : Thread, dur;
import libsweatyballs.router.table : Route;
import std.socket : Address, parseAddress;

/* TODO: Import for config thing */

/**
* Engine
*
* Description: TODO
*/
public final class Engine : Thread
{
    /**
    * Network components
    */
    private Router router;
    private Switch zwitch;

    /**
    * Links the router can advertise over
    */
    private Link[] links;
    private Mutex linksMutex;

    /**
    * 1. This must read config given to it
    * 2. Setups links
    * 3. Create new Router with these links
    * 4. Spawn a Switch that handles packet in/out
    * 5. Pass the Switch the router
    * 6. Start the switch
    * 7. We must then mainloop and collect statistics and handle shutdown etc
    */
    this(Config config)
    {
        /* TODO: Add comment */
        super(&worker);

        /* TODO: Read config */
        parseConfig(config);

        /* Initialize locks */
        initMutexes();
    }

    /**
    * Initializes all the mutexes
    */
    private void initMutexes()
    {
        linksMutex = new Mutex();
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

    private void parseConfig(Config config)
    {
        /* TODO: Set configuration parameter */

        /* Setup links */
        links = createLinks(config.links);
        setupLinks(links);

        /**
        * Setup a new Router
        */
        router = new Router(this, config.routerIdentity);
        
        
        

        /* Setup a new Switch */
        zwitch = new Switch(this);

        /* Add self neighbor to any link (try the first, TODO: Atleast one link is needed) */
        Address address = parseAddress("::", links[0].getR2RPort());
        Neighbor selfNeighbor = new Neighbor(router.getIdentity().getKeys().publicKey, address, links[0]);


        Route route = new Route(router.getIdentity().getKeys().publicKey, selfNeighbor);
        route.setAgeibility(false);

        router.getTable().addRoute(route);
        
    }

    public Router getRouter()
    {
        return router;
    }

    public Switch getSwitch()
    {
        return zwitch;
    }

    private void worker()
    {
        while(true)
        {
            /**
            * FIXME: Remove this, this is just testing code
            */
            Route[] routes = router.getTable().getRoutes();
            foreach(Route route; routes)
            {
                zwitch.sendPacket(route.getAddress(), cast(byte[])"Hello world");    
            }

            Thread.sleep(dur!("seconds")(1));
        }
    }

    private Link[] createLinks(string[] interfaces)
    {
        Link[] createdLinks;

        foreach(string interfaceName; interfaces)
        {
            createdLinks ~= new Link(interfaceName, this);
        }

        return createdLinks;
    }

    private void setupLinks(Link[] links)
    {
        gprintln("Begin link initailization");
        foreach(Link link; links)
        {
            gprintln("Initializing link "~to!(string)(link)~" ...");
            link.launch();
        }
        gprintln("Links have been initialized");
    }

    public void launch()
    {
        /* Start the engine */
        start();

        /* Start router */
        router.launch();

        /* Start switch */
        zwitch.launch();

        /* Start collector */
        /* TODO: Add me */

        gprintln("Engine has started all threads and is now going to finish and return to constructor thread control");
    }
}