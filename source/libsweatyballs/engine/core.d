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
import libsweatyballs.link.message.core;
import std.container.slist;
import std.range;
import libsweatyballs.engine.handlers : engine, advHandler, pktHandler, defaultHandler;
import std.datetime : Clock;

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
    * Received packets
    */
    private SList!(Packet) packetQueue;
    private Mutex packetQueueLock;

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

        /* Initialize the handler's module globals */
        initEngine();
    }

    /**
    * Initializes all the mutexes
    */
    private void initMutexes()
    {
        linksMutex = new Mutex();
        packetQueueLock = new Mutex();
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

    /**
    * This function will do an import which
    * will initialize the module, any other
    * thread who referes to a mobule's
    * member also inits their own copy
    *
    * There is however a global field
    * `__gshared` that all code using
    * it refers to one entity, not
    * several static members per each
    * module
    *
    * This must be set here
    */
    private void initEngine()
    {
        engine = this;
    }

    private void initLinkHandler(Link link)
    {
        /* Register a handler for advertisements */
        link.registerHandler(&advHandler, 0);

        /* Register a handler for packets */
        link.registerHandler(&pktHandler, 1);

        /* Register default handler */
        link.setDefaultHandler(&defaultHandler);
    }

    private void parseConfig(Config config)
    {
        /* TODO: Setup the tun adapter */
        tun = new TUNAdapter("sweatyballs0", AdapterType.TUN);

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


        Route route = new Route(router.getIdentity().getKeys().publicKey, selfNeighbor, Clock.currTime());
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

    public void newPacket(Packet packet)
    {
        packetQueueLock.lock();
        packetQueue.insertAfter(packetQueue[], packet);
        packetQueueLock.unlock();
    }

    private Packet checkPacket()
    {
        Packet received;

        /* Check for packet */
        packetQueueLock.lock();
        if(!packetQueue.empty())
        {
            /**
            * Dequeue a packet
            *
            * Get the Range internal
            * (use auto as this is some butchered
            * fucking templatised shit)
            */
            received = (packetQueue[]).front();
            (packetQueue[]).popFront();
        }
        packetQueueLock.unlock();


        
        return received;
    
    }

    /**
    * processPacket
    *
    * This method is used when a packet arrives to the engine
    * and is used to decide what to do with the packet, this
    * could be:
    *
    * 1. If the packet's payload is recognizable as a Session
    *    control command, then it will attempt to get a new
    *    Session created
    * 2. If not a Session control message then we (as of now)
    *    drop the packet. (TODO: We could keep it but eh, use
    *    Sessions rather please)
    */
    private void processPacket(Packet packet)
    {

    }


    /**
    * FIXME: Remove this and set it up elsewhere
    *
    * This function is here to setup a tun adapter which will
    * then push shit in and out or something
    */
    import libtun.adapter;
 


    private TUNAdapter tun;

    private void worker()
    {
        

        
        
        while(true)
        {
            byte[] poes;
        
        tun.receive(poes);
            gprintln("TUNRecieve: "~to!(string)(poes));

            /**
            * FIXME: Remove this, this is just testing code
            */
            router.getTable().lockTable();
            Route[] routes = router.getTable().getRoutes();
            foreach(Route route; routes)
            {
                zwitch.sendPacket(route.getAddress(), cast(byte[])"Hello world");    
            }
            router.getTable().unlockTable();

            /**
            * Check receiveve queue
            */
            Packet packet = checkPacket();
            if(packet)
            {
                processPacket(packet);
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
            initLinkHandler(link);
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