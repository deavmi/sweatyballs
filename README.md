Sweatyballs
===========

**Sweatyballs** is a toy routing protocol that I wanted to implement just so that I could say that I've done it and try get something working.

The protocol is rather simple in it's workings and takes ideas from [batman-adv]() and [cjdns]() (so far). A description of all of its working, data formats etc. can be found [here](PROTOCOL.md).


## Bugs

- [x] Duplicated self route
    * I add a self route once but it seems when another node comes online I install it for some reason?
    * Fixed, it was the printing of table that was duplicating stuff
- [ ] Possible unsafety, we must lock whole table when doing route checks, as more than one link could inter-step