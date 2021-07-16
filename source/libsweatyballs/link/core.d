module libsweatyballs.link.core;

import libsweatyballs.link.message.core : Message;
import core.sync.mutex : Mutex;
import core.thread : Thread;
import bmessage;
import std.socket;
import gogga;

/**
* Link
*
* Description: Represents a "pipe" whereby different protocol messages can be transported over.
* Such protocol messages include data packet transport (receiving and sending) along with
* router advertisements messages
*
* This class handles the Message queues for sending and receiving messages (and partially decoding them)
*/
public final class Link : Thread
{
    /**
    * In and out queues
    */
    private Message[] inQueue;
    private Message[] outQueue;
    private Mutex inQueueLock;
    private Mutex outQueueLock;

    private string interfaceName;

    this(string interfaceName)
    {
        /* Set the thread's worker function */
        super(&worker);

        this.interfaceName = interfaceName;

        /* Initialize locks */
        initMutexes();
    }

    public string getInterface()
    {
        return interfaceName;
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
    * Listens for advertisements
    */
    private void worker()
    {
        /* TODO: Implement me */
        
        /* TODO: Make whatever this class is used for more specific */

        /* Create a Socket for (TODO) */
        Socket socket = new Socket(AddressFamily.INET6, SocketType.DGRAM, ProtocolType.UDP);
        // socket.bind();
        // socket.listen(0);

        while(true)
        {
            byte[12] data;
            Address address = parseAddress("ff02::1%"~getInterface(), 6666);
            gprintln("Poes");
            socket.receiveFrom(data, address);
            gprintln(data);
        }
    }

    public void launch()
    {
        start();
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