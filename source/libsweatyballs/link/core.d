module libsweatyballs.link.core;

import libsweatyballs.link.message : Message;

/**
* Link
*
* Description: Represents a "pipe" whereby different protocol messages can be transported over.
* Such protocol messages include data packet transport (receiving and sending) along with
* router advertisements messages
*/
public final class Link
{
    /**
    * In and out queues
    */
    private Message[] inQueue;
    private Message[] outQueue;

    this(string interfaceName)
    {

    }

    /**
    * Blocks to receive one message from the incoming queue
    */
    public Message receive()
    {
        /* TODO: Implement me */
        return null;
    }

    /**
    * Sends a message
    */
    public void send(Message message, string recipient)
    {
        /* TODO: Implement me */
    }
}