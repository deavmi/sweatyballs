module libsweatyballs.link.core;

import libsweatyballs.link.message.core : Message;
import core.sync.mutex : Mutex;

/**
* Link
*
* Description: Represents a "pipe" whereby different protocol messages can be transported over.
* Such protocol messages include data packet transport (receiving and sending) along with
* router advertisements messages
*
* This class handles the Message queues for sending and receiving messages (and partially decoding them)
*/
public final class Link
{
    /**
    * In and out queues
    */
    private Message[] inQueue;
    private Message[] outQueue;
    private Mutex inQueueLock;
    private Mutex outQueueLock;

    this(string interfaceName)
    {
        /* Initialize locks */
        initMutexes();
    }

    /**
    * Initialize the queue mutexes
    */
    private void initMutexes()
    {
        inQueueLock = new Mutex();
        outQueueLock = new Mutex();
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