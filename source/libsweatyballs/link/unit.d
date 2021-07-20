module libsweatyballs.link.unit;

import libsweatyballs.link.message.core;
import std.socket : Address;

public final class LinkUnit
{
    private Address sender;
    private link.LinkMessage message;

    this(Address sender, link.LinkMessage message)
    {
        this.sender = sender;
        this.message = message;
    }

    public Address getSender()
    {
        return sender;
    }

    public link.LinkMessage getMessage()
    {
        return message;
    }
}