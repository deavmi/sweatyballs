module libsweatyballs.router.core;

import libsweatyballs.link.core : Link;
import libsweatyballs.security.identity : Identity;
import libsweatyballs.router.table : Table, Route;
import core.thread : Thread, dur;
import core.sync.mutex : Mutex;
import libsweatyballs.router.advertiser : Advertiser;
import libsweatyballs.link.message.core : Message, test;
import libsweatyballs.engine.core : Engine;
import gogga;

/**
* Router
*
* Description: TODO
*/
public final class Router : Thread
{
    
    private Advertiser advertiser;

    private Identity identity;

    private Table routingTable;

    private Engine engine;

    this(Engine engine, Identity identity)
    {
        /* Set the thread's worker function */
        super(&worker);

        

        this.engine = engine;
        this.identity = identity;

        /* Create a new routing table */
        routingTable = new Table();

        /* Initialize the advertiser */
        initAdvertiser();
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
            // /* Cycle through the in queue of each link */
            // Link[] links = getLinks();
            // foreach(Link link; links)
            // {
            //     /* Check if the in-queue has anything in it */
            //     if(link.hasInQueue())
            //     {
            //         Message message = link.popInQueue();
            //         process(message);
            //     }
            // }

            // process(null);

            
            string routeInfo;
            Route[] routes = routingTable.getRoutes();
            foreach(Route route; routes)
            {
                routeInfo ~= routeInfo ~ to!(string)(route) ~ "\n";
            }

            gprintln("<<<<<<< Routing table state >>>>>>>\n"~routeInfo);


            sleep(dur!("seconds")(5));
        }
    }

    private void process(Message messageIn)
    {
        import std.stdio;
        import google.protobuf;
        writeln(test().toProtobuf);
    }

    public Engine getEngine()
    {
        return engine;
    }

    public Table getTable()
    {
        return routingTable;
    }

    public Identity getIdentity()
    {
        return identity;
    }

    public void launch()
    {
        start();

        /* Launch the routes advertiser */
        advertiser.launch();
    }
}