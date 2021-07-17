module libsweatyballs.router.table;

import std.socket : Address;

/**
* Route
*
* Description: TODO
*/
public final class Route
{
    private string address;
    private Address nexthop;
    
    this(string address, Address nexthop)
    {
        this.address = address;
        this.nexthop = nexthop;
    }

    public string getAddress()
    {
        return address;
    }

    public Address getNexthop()
    {
        return nexthop;
    }
}

/**
* Table
*
* Description: TODO
*/
public final class Table
{

}