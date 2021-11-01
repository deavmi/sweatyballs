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
import std.digest.sha : sha512Of;
import std.digest : toHexString;

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

    /* TODO: Either guarantee fast updates or don't expire ourself AT ALL */
    private bool ageibility = true;

    private SysTime creationTime;



    /**
    * Keys, if shortened may clash, so let's hash them
    * such that we get a very different string with
    * higher bits most probably lot different
    * than that of the key cmps.
    */
    private string addressHash;
    
    this(string address, Neighbor nexthop, SysTime creationTime, long timeout = 100, uint metric = 64)
    {
        this.address = address;
        this.nexthop = nexthop;
        this.timeout = timeout;
        this.metric = metric;

        this.creationTime = creationTime;

        /* Compute the address's hash (only use first 16 bytes (128 bits)) */
        ubyte[] hash = sha512Of(address)[0..16];
        addressHash = toHexString(hash);
    }

    public void updateCreationTime(SysTime creationTime)
    {
        this.creationTime = creationTime;
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
        /* Get the current time */
        SysTime currentTime = Clock.currTime();

        return currentTime.toUnixTime() - creationTime.toUnixTime();
    }

    public bool isExpired()
    {
        return (getAge()) > timeout;    
    }

    public override bool opEquals(Object other)
    {
        Route otherRoute = cast(Route)other;

        /* TODO: Add other comparators such as next hops */

        return cmp(otherRoute.getAddress(), this.getAddress()) == 0 &&
                otherRoute.getNexthop() == this.getNexthop() &&
                otherRoute.getMetric() == this.getMetric();
    }

    public string getAddressHash()
    {
        return addressHash;
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
    *
    * unsafe, must lock
    */
    public Route[] getRoutes()
    {
        return routes;
    }

    /**
    * Add a route 
    *
    * unsafe, must lock
    */
    public void addRoute(Route route)
    {
        /* Add the route (only if it doesn't already exist) */
        foreach(Route cRoute; routes)
        {
            /* FIXME: Make sure nexthop matches as well */
            if(cRoute == route)
            {
                goto no_add_route;
            }
        }

        routes ~= route;
         
        no_add_route:
    }

    public Route lookup(string address)
    {
        /* The matched route (if any) */
        Route match;

        /* Add the route (only if it doesn't already exist) */
        foreach(Route route; routes)
        {
            /* FIXME: Make sure nexthop matches as well */
            if(cmp(route.getAddress(), address) == 0)
            {
                match = route;
            }
        }

        return match;
    }

    public Route lookup_hash(string hashDigest)
    {
        /* The matched route (if any) */
        Route match;

        /* Add the route (only if it doesn't already exist) */
        foreach(Route route; routes)
        {
            /* FIXME: Make sure nexthop matches as well */
            if(cmp(route.getAddressHash(), hashDigest) == 0)
            {
                match = route;
            }
        }

        return match;
    }

    /**
    * Remove a route 
    */
    public void removeRoute(Route route)
    {
        /* New routing table */
        Route[] newRoutes;

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
    }
}