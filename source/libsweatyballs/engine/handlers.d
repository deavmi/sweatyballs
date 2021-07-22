module libsweatyballs.engine.handlers;

import libsweatyballs.link.unit;

import gogga;

public void advHandler(LinkUnit unit)
{
    gprintln("advHandler!!!!!!!!!! "~unit.toString());
}

public void pktHandler(LinkUnit unit)
{
    gprintln("pktHandler!!!!!!!!!! "~unit.toString());
}

public void defaultHandler(LinkUnit unit)
{
    gprintln("Unknown mesage type!!!!!!!!!! "~unit.toString());
}