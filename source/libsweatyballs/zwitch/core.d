module libsweatyballs.zwitch.core;

import core.threading : Thread;

/**
* Switch
*
* Description: TODO
*
*/
public final class Switch : Thread
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

        }
    }

    public void launch()
    {
        start();
    }
}