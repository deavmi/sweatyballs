module libsweatyballs.link.unit;

import libsweatyballs.link.message.core : packet.Message;
import std.socket : Address;

public final class LinkUnit
{
    private Address sender;
    private packet.Message message;

    this(Address sender, packet.Message message)
    {
        this.sender = sender;
        this.message = message;
    }

    public Address getSender()
    {
        return sender;
    }

    public packet.Message getMessage()
    {
        return message;
    }
}