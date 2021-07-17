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

            sleep(dur!("seconds")(1));
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
    * Send an IPv6 Multicast advertisement via link-local
    *
    * Sends to `ff02::1%<interface>:6666`
    *
    * TODO: Advertise self (we should insert our own route too perhaps or just do it here (eaiser))
    */
    private void advertise(Link link)
    {
        /* Create advertisement message */
        advertisement.AdvertisementMessage d = new  advertisement.AdvertisementMessage();
        advertisement.RouteEntry[] entries;
        advertisement.RouteEntry entry = new advertisement.RouteEntry();
        entry.address = router.getIdentity().getKeys().publicKey;
        entries ~= entry;
        d.routes = entries;

        /* get routes */
        Route[] routes = router.getTable().getRoutes();
        foreach(Route route; routes)
        {
            advertisement.RouteEntry cEntry = new advertisement.RouteEntry();
            cEntry.address = route.getAddress();
            d.routes ~= cEntry;
        }


        /* Create Message */
        packet.Message message = new packet.Message();
        message.publicKey = router.getIdentity().getKeys().publicKey;
        message.signature = "TODO";
        message.type = packet.MessageType.ADVERTISEMENT;
        message.payload = array(toProtobuf(d));

        /* Encode the Message */
        byte[] buff = cast(byte[])array(toProtobuf(message));

        ulong stats = mcastSock.sendTo(buff, parseAddress("ff02::1%"~link.getInterface(), 6666));

        import std.conv : to;
        gprintln("Status"~to!(string)(stats));
    }
}