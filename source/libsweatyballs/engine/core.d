module libsweatyballs.engine.core;

import libsweatyballs.router.core : Router;
import libsweatyballs.zwitch.core : Switch;
import libsweatyballs.engine.configuration : Config;
import std.stdio : writeln;

/* TODO: Import for config thing */

/**
* Engine
*
* Description: TODO
*/
public final class Engine
{
    /**
    * Network components
    */
    private Router router;
    private Switch zwitch;

    /**
    * 1. This must read config given to it
    * 2. Setups links
    * 3. Create new Router with these links
    * 4. Spawn a Switch that handles packet in/out
    * 5. Pass the Switch the router
    * 6. Start the switch
    * 7. We must then mainloop and collect statistics and handle shutdown etc
    */
    this(Config config)
    {
        /* TODO: Read config */
        parseConfig(config);
    }

    private void parseConfig(Config config)
    {
        /* TODO: Set configuration parameter */
    }

    public void launch()
    {
        /* Start router */

        /* Start switch */

        /* Start collector */

        writeln("Engine has started all threads and is now going to finish and return to constructor thread control");
        
        /* TODO: Maybe create Engine thread or all user to do that */
    }
}