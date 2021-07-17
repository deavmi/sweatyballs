module libsweatyballs.router.table;

import std.socket : Address;
import core.sync.mutex : Mutex;

/**
* Route
*
* Description: TODO
*/
public final class Route
{
    private string address;
    private Address nexthop;

    /**
    * TODO: Set these and add a loop watcher to
    * the table
    */
    private ulong tiemout;
    private string creationTime;
    
    this(string address, Address nexthop)
    {
        this.address = address;
        this.nexthop = nexthop;
    }

    public string getAddress()
    {
        return address;
    }

    public Address getNexthop()
    {
        return nexthop;
    }
}

/**
* Table
*
* Description: TODO
*/
public final class Table
{
    /**
    * Routes
    */
    private Route[] routes;
    private Mutex routeLock;

    this()
    {
        /* Initialize locks */
        initMutexes();
    }

    /**
    * Initialize the mutexes
    */
    private void initMutexes()
    {
        routeLock =  new Mutex();
    }

    /**
    * Get routes
    */
    public Route[] getRoutes()
    {
        /* The copied routes */
        Route[] copiedRoutes;

        /* Lock the routing table */
        routeLock.lock();

        /* Copy each route */
        foreach(Route route; routes)
        {
            copiedRoutes ~= route;
        }

        /* Unlock the routing table */
        routeLock.unlock();

        return copiedRoutes;
    }

    /**
    * Add a route 
    */
    public void addRoute(Route route)
    {
        /* Lock the routing table */
        routeLock.lock();

        /* Add the route */
        routes ~= route;

        /* Unlock the routing table */
        routeLock.unlock();
    }


    /* TODO; Remove route */

}