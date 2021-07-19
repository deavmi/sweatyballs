module libsweatyballs.router.table;

import std.socket : Address;
import core.sync.mutex : Mutex;
import std.conv : to;
import std.string : cmp;
import std.datetime.systime : Clock, SysTime;

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
    private ubyte timeout;
    private SysTime updateTime;
    
    this(string address, Address nexthop, ubyte timeout = 100)
    {
        this.address = address;
        this.nexthop = nexthop;

        refreshTime();
    }

    public void refreshTime()
    {
        /* Set the creation/updated time */
        updateTime = Clock.currTime();
    }

    public string getAddress()
    {
        return address;
    }

    public Address getNexthop()
    {
        return nexthop;
    }

    public override string toString()
    {
        return "Route (To: "~address~", Via: "~to!(string)(nexthop)~")";
    }

    public bool isExpired()
    {
        SysTime currentTime = Clock.currTime();

        return (currentTime.second()-updateTime.second()) > timeout;
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

        /* Add the route (only if it doesn't already exist) */
        foreach(Route cRoute; routes)
        {
            /* FIXME: Make sure nexthop matches as well */
            if(cmp(cRoute.getAddress(), route.getAddress()) == 0)
            {
                /* Refresh the route */
                cRoute.refreshTime();

                goto no_add_route;
            }
        }

        routes ~= route;
        
        no_add_route:

        /* Unlock the routing table */
        routeLock.unlock();
    }

    /**
    * Remove a route 
    */
    public void removeRoute(Route route)
    {
        /* New routing table */
        Route[] newRoutes;

        /* Lock the routing table */
        routeLock.lock();

        /* Add the route (only if it doesn't already exist) */
        foreach(Route cRoute; routes)
        {
            /* FIXME: Make sure nexthop matches as well */
            if(cmp(cRoute.getAddress(), route.getAddress()) != 0)
            {
                newRoutes ~= cRoute;
            }
        }

        routes = newRoutes;

        /* Unlock the routing table */
        routeLock.unlock();
    }
}