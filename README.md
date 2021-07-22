Sweatyballs
===========

**Sweatyballs** is a toy routing protocol that I wanted to implement just so that I could say that I've done it and try get something working.

The protocol is rather simple in it's workings and takes ideas from [batman-adv]() and [cjdns]() (so far). A description of all of its working, data formats etc. can be found [here](PROTOCOL.md).


## Bugs

- [ ] Duplicated self route
    * I add a self route once but it seems when another node comes online I install it for some reason?