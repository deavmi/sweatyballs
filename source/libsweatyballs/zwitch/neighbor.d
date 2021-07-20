module libsweatyballs.zwitch.neighbor;

import std.socket : Address;
import std.conv : to;
import libsweatyballs.link.core : Link;

public final class Neighbor
{
    /* IPv6 address and R2R port of router neighbor */
    private Address address;

    /* The Link this neighbor is attached on */
    private Link link;

    /* Identity of router */
    private string identity;

    this(string identity, Address address, Link link)
    {
        this.identity = identity;
        this.address = address;
        this.link = link;
    }

    public string getIdentity()
    {
        return identity;
    }

    public Address getAddress()
    {
        return address;
    }

    public Link getLink()
    {
        return link;
    }

    public override string toString()
    {
        return "NBR ("~identity~") ["~to!(string)(address)~"]";
    }
}