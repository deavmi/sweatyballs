module libsweatyballs.router.table;

import std.socket : Address;
import core.sync.mutex : Mutex;
import std.conv : to;
import std.string : cmp;
import std.datetime.stopwatch : StopWatch;
import std.datetime : Duration;
import gogga;
import libsweatyballs.zwitch.neighbor;
import std.datetime;

/**
* Route
*
* Description: TODO
*/
public final class Route
{
    // We must know our self-route and add it too somewhere
    //private __gshared Identity d;
    private string address;
    private Neighbor nexthop;
    private uint metric;

    /**
    * TODO: Set these and add a loop watcher to
    * the table
    */
    private long timeout;
    private StopWatch updateTime;

    private bool ageibility = true;

    private SysTime creationTime;
    
    this(string address, Neighbor nexthop, SysTime creationTime, long timeout = 100, uint metric = 64)
    {
        this.address = address;
        this.nexthop = nexthop;
        this.timeout = timeout;
        this.metric = metric;

        this.creationTime = creationTime;

        /* Start the stop watch */
        updateTime.start();
    }

    public void updateCreationTime(SysTime creationTime)
    {
        this.creationTime = creationTime;
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

    public SysTime getCreationTime()
    {
        return creationTime;
    }

    public Neighbor getNexthop()
    {
        return nexthop;
    }

    public uint getMetric()
    {
        return metric;
    }

    public void setAgeibility(bool age)
    {
        ageibility = age;
    }

    public override string toString()
    {
        return "Route (To: "~address~", Via: "~to!(string)(nexthop)~", Metric: "~to!(string)(metric)~", Age: "~to!(string)(getAge())~")";
    }

    public long getAge()
    {
        Duration elapsedTime = updateTime.peek();
        return elapsedTime.total!("seconds");
    }

    public bool isExpired()
    {
        Duration elapsedTime = updateTime.peek();
        return (elapsedTime.total!("seconds") >= timeout) && ageibility;
    }

    public override bool opEquals(Object other)
    {
        Route otherRoute = cast(Route)other;

        /* TODO: Add other comparators such as next hops */

        return cmp(otherRoute.getAddress(), this.getAddress()) == 0 &&
                otherRoute.getNexthop() == this.getNexthop() &&
                otherRoute.getMetric() == this.getMetric();
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

    public void lockTable()
    {
        routeLock.lock();
    }

    public void unlockTable()
    {
        routeLock.unlock();
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
            if(cRoute == route)
            {
                /* Refresh the route */
                cRoute.refreshTime();

                goto no_add_route;
            }
        }

        routes ~= route;
        gprintln("Added route "~to!(string)(route));

        gprintln("TABLE IS HOW BIG MY NIGGER??!?!?: "~to!(string)(routes.length), DebugType.ERROR);

        
        
        no_add_route:

        /* Unlock the routing table */
        routeLock.unlock();
    }

    public Route lookup(string address)
    {
        /* The matched route (if any) */
        Route match;

        /* Lock the routing table */
        routeLock.lock();

        /* Add the route (only if it doesn't already exist) */
        foreach(Route route; routes)
        {
            /* FIXME: Make sure nexthop matches as well */
            if(cmp(route.getAddress(), address) == 0)
            {
                match = route;
            }
        }

        /* Unlock the routing table */
        routeLock.unlock();

        return match;
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
            if(cRoute != route)
            {
                newRoutes ~= cRoute;
            }
        }

        routes = newRoutes;

        /* Unlock the routing table */
        routeLock.unlock();
    }
}