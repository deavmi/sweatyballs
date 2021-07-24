module libsweatyballs.router.advertiser;

import core.thread : Thread, dur;
import libsweatyballs.router.core : Router;
import libsweatyballs.link.core : Link;
import std.socket;
import gogga;
import std.conv : to;
import bmessage;
import libsweatyballs.link.message.core;
import google.protobuf;
import std.array : array;
import libsweatyballs.router.table : Route;

public final class Advertiser : Thread
{
    private Router router;
    private Socket mcastSock;

    this(Router router)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.router = router;

        /* Setup socket */
        setupSocket();
    }

    private void setupSocket()
    {
        /* TODO: Error handling */
        mcastSock = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);


    }

    private void worker()
    {
        /* TODO: Implement me */
        while(true)
        {
            /*  Cycle through each link and advertise on them */
            Link[] links = router.getEngine().getLinks();
            foreach(Link link; links)
            {
                gprintln("Sending advertisement on "~to!(string)(link)~" ...");
                advertise(link);
            }

            sleep(dur!("seconds")(2));
        }
    }

    public void launch()
    {
        start();
    }

    public void shutdown()
    {
        /* TODO: Implement me */

        /* Close the multicast socket */
        mcastSock.close();
    }

    /**
    * TODO: Move this elsehwre
    *
    * Given a publicKey, nexthop this generates the advertisement message
    */
    private link.Advertisement makeAdvertisement(Link link, Route[] routes)
    {
        /* The advertisement message */
        Advertisement advMsg = new Advertisement();

        /**
        * Construct RouteEntry's
        */
        RouteEntry[] entries;
        foreach(Route route; routes)
        {
            /* Copy Route's data to a new RouteEntry */
            RouteEntry newRouteEntry = new RouteEntry();
            newRouteEntry.address = route.getAddress();
            newRouteEntry.metric = route.getMetric();
            newRouteEntry.creationTime = route.getCreationTime().toISOString();

            /* Add to list of RouteEntry-s */
            entries ~= newRouteEntry;
        }

        /* Set entries */
        advMsg.routes = entries;

        return advMsg;
    }


    /**
    * Send an IPv6 Multicast advertisement via link-local
    *
    * Sends to `ff02::1%<interface>:6666`
    *
    * TODO: Advertise self (we should insert our own route too perhaps or just do it here (eaiser))
    *
    * TODO: We should split advertisements up, depending on the number, into seperate
    * advertisements
    */
    private void advertise(Link link)
    {
        /**
        * Advertise a set of routes over a link to all neighbors
        * on said link
        *
        * TODO: Shard these (batch them)
        */
        router.getTable().lockTable();
        Route[] routes = router.getTable().getRoutes();
        router.getTable().unlockTable();
        advertiseRoute(link, routes);      
    }

    /**
    * Advertises the given `routes` on the given `link`
    */
    private void advertiseRoute(Link link, Route[] routes)
    {
        /**
        * Construct the Advertisement message for the given Link and
        * set of routes
        */
        Advertisement advMsg = makeAdvertisement(link, routes);

        /**
        * Construct a LinkMessage with type=ADVERTISEMENT and
        * the encoded message above
        *
        * Set the public key to ours
        * Set the signature (TODO)
        * Set neighbor port
        */
        LinkMessage linkMsg = new LinkMessage();
        linkMsg.type = LinkMessageType.ADVERTISEMENT;
        linkMsg.payload = array(toProtobuf(advMsg));
        linkMsg.publicKey = router.getIdentity().getKeys().publicKey;
        linkMsg.neighborPort = to!(string)(link.getR2RPort());
        // linkMsg.signature = 

        /* Encode the LinkMessage */
        byte[] messageBytes = cast(byte[])array(toProtobuf(linkMsg));
        ulong stats = mcastSock.sendTo(messageBytes, parseAddress("ff02::1%"~link.getInterface(), 6666));
        gprintln("Status"~to!(string)(stats));
    }
}