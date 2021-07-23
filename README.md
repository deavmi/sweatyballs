Sweatyballs
===========

**Sweatyballs** is a toy routing protocol that I wanted to implement just so that I could say that I've done it and try get something working.

The protocol is rather simple in it's workings and takes ideas from [batman-adv]() and [cjdns]() (so far). A description of all of its working, data formats etc. can be found [here](PROTOCOL.md).


## Bugs

- [x] Duplicated self route
    * I add a self route once but it seems when another node comes online I install it for some reason?
    * Fixed, it was the printing of table that was duplicating stuff
- [ ] Possible unsafety, we must lock whole table when doing route checks, as more than one link could inter-step
- [ ] Routing loops are caused by routes that expire at the one node, but almost expire at next, then they install
    the roite advertised to them from the node they advertised it to previously, but sending to it routes
    right back to them and then them with that new route back to the router it just came from.
    We could do something whereby if we send a packet via a given route and.

    alternatively, there should be a time set in the route that is never changed (and set by originator).
    When we pass the route along we pass this static time field with and chek it against a threshold
    If the elapsed time is too high then we drop that route. We most likely want to make the time threshold
    very small as to make routing loops disappear quickly but also not too small as to allow the route to
    properly propagate throughout the network