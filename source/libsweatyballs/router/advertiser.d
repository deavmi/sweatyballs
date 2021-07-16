module libsweatyballs.router.advertiser;

import core.thread : Thread, dur;
import libsweatyballs.router.core : Router;
import libsweatyballs.link.core : Link;
import std.socket;
import gogga;
import std.conv : to;
import bmessage;

public final class Advertiser : Thread
{
    private Router router;

    this(Router router)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.router = router;
    }

    private void worker()
    {
        /* TODO: Implement me */
        while(true)
        {
            /* TODO: Cycle through each link and advertise on them */
            /* TODO: Fetch links safely */
            Link[] links = router.getLinks();
            gprintln("Advertiser: "~to!(string)(links));
            foreach(Link link; links)
            {
                advertise(link);
            }

            gprintln("Advertiser: "~to!(string)(links));

            sleep(dur!("seconds")(1));
        }
    }

    public void launch()
    {
        start();
    }

    /**
    * Send an IPv6 Multicast advertisement via link-local
    *
    * The multicast address used is `ff69::1` because the
    * sex number is cool and I am a 22 year old virgin
    *
    * TODO: Enqueue this somehow onto Link's sendqueue?
    */
    private void advertise(Link link)
    {
        /* TODO: Add error handling */
        Socket socket = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);
        byte[] message = [65,66,66,65,65,66,66,65,65,66,66,65];

        /* Encode using bformat */
        byte[] buff = encodeBformat(buff);



        gprintln("Bruh"~link.getInterface());
        ulong stats = socket.sendTo(buff, parseAddress("ff02::1%"~link.getInterface(), 6666));
        socket.close();

        import std.conv : to;
        gprintln("Status"~to!(string)(stats));
    }
}