module libsweatyballs.link.core;

import libsweatyballs.link.message.core : Message;
import core.sync.mutex : Mutex;
import core.thread : Thread;
import bmessage;
import std.socket;
import gogga;
import std.conv : to;

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

        /* Listen on the multicast address on port 6666 */
        socket.bind(parseAddress("ff02::1%"~getInterface(), 6666));

        while(true)
        {

            /**
            * MSG_PEEK, we don't want to dequeue this message yet but need to call receive
            * MSG_TRUNC, return the number of bytes of the datagram even when
            * bigger than passed in array
            */
            SocketFlags flags;
            flags |= MSG_TRUNC;
            flags |= MSG_PEEK;

            /* Receive buffer */
            byte[] data;
            Address address;

            /* Empty array won't work */
            data.length = 1;
            
            gprintln("Awaiting message...");
            long len = socket.receiveFrom(data, flags, address);

            if(len <= 0)
            {
                /* TODO: Error handling */
            }
            else
            {
                data.length = len;
                socket.receiveFrom(data, address);

                gprintln("Received data: "~to!(string)(data));
                gprintln("Message from: "~to!(string)(address));
            }
            
        }
    }

    public bool hasInQueue()
    {
        bool status;
        inQueueLock.lock();
        status = inQueue.length != 0;
        inQueueLock.unlock();
        return status;
    }

    public Message popInQueue()
    {
        Message message;

        /* TODO: Throw exception on `hasInQueue()` false */

        inQueueLock.lock();

        /* Pop the message */
        message = inQueue[0];

        if(inQueue.length == 1)
        {
            inQueue.length = 0;
        }
        else
        {
            inQueue = inQueue[1..inQueue.length];
        }

        inQueueLock.unlock();

        return message;
    }

    // public bool hasOutQueue()
    // {
    //     bool status;
    //     inQueueLock.lock();
    //     status = inQueue.length != 0;
    //     inQueueLock.unlock();
    //     return status;
    // }

    


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