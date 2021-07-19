module libsweatyballs.zwitch.neighbor;

import std.socket : Address;
import std.conv : to;

public final class Neighbor
{
    /* IPv6 address and R2R port of router neighbor */
    private Address address;

    /* Identity of router */
    private string identity;

    this(string identity, Address address)
    {
        this.identity = identity;
        this.address = address;
    }

    public string getIdentity()
    {
        return identity;
    }

    public override string toString()
    {
        return "NBR ("~identity~") ["~to!(string)(address)~"]";
    }
}