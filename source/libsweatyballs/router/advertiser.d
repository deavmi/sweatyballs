module libsweatyballs.router.advertiser;

import core.thread : Thread;
import libsweatyballs.router.core : Router;
import libsweatyballs.link.core : Link;

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
            Link[] links;
            foreach(Link link; links)
            {
                advertise(link);
            }
        }
    }

    public void launch()
    {
        start();
    }

    private void advertise(Link link)
    {

    }
}