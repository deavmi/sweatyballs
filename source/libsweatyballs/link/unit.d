module libsweatyballs.link.unit;

import libsweatyballs.link.message.core;
import std.socket : Address;
import libsweatyballs.link.core : Link;

public final class LinkUnit
{
    private Address sender;
    private LinkMessage message;
    private Link link;

    this(Address sender, LinkMessage message, Link link)
    {
        this.sender = sender;
        this.message = message;
        this.link = link;
    }

    public Address getSender()
    {
        return sender;
    }

    public LinkMessage getMessage()
    {
        return message;
    }

    public Link getLink()
    {
        return link;
    }
}