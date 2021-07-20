module libsweatyballs.zwitch.neighbor;

import std.socket : Address;
import std.conv : to;
import libsweatyballs.link.core : Link;
import std.string : cmp;

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

    /**
    * Neighbors are considered equal if both their Link
    * is the same and their identity. There should not
    * be several neighbors with same identity on one Link
    */
    public override bool opEquals(Object other)
    {
        Neighbor otherN = cast(Neighbor)other;



        return otherN.getLink() == this.getLink() && cmp(otherN.getIdentity(), this.getIdentity()) == 0;
    }
}