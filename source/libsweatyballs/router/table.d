module libsweatyballs.router.table;

import std.socket : Address;
import core.sync.mutex : Mutex;
import std.conv : to;
import std.string : cmp;
import std.datetime.stopwatch : StopWatch;
import std.datetime : Duration;

/**
* Route
*
* Description: TODO
*/
public final class Route
{
    private string address;
    private Address nexthop;
    private uint metric;

    /**
    * TODO: Set these and add a loop watcher to
    * the table
    */
    private long timeout;
    private StopWatch updateTime;
    
    this(string address, Address nexthop, long timeout = 100, uint metric = 64)
    {
        this.address = address;
        this.nexthop = nexthop;
        this.timeout = timeout;
        this.metric = metric;

        /* Start the stop watch */
        updateTime.start();
    }

    public void refreshTime()
    {
        /* Reset the timer */
        updateTime.reset();
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
        return "Route (To: "~address~", Via: "~to!(string)(nexthop)~", Age: "~to!(string)(getAge())~")";
    }

    public long getAge()
    {
        Duration elapsedTime = updateTime.peek();
        return elapsedTime.total!("seconds");
    }

    public bool isExpired()
    {
        Duration elapsedTime = updateTime.peek();
        return (elapsedTime.total!("seconds") >= timeout);
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