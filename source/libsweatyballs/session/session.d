module libsweatyballs.session.session;

/**
* Session
*
* A Session runs ontop of the layer of transport that the protocol provides
* It sends PACKET LinkMessages the exchange keys (symmetric).
*
* It is intended one then used Session system for exchanging data in a faster
* way than directly usign PACKET and LinkMessages
*
* It takes in the Engine API and uses that as a way to talk to the network
*/
public final class SessionManager
{
    private Session[] sessions;
    private Engine engine;

    this(Engine engine)
    {

    }

    public Session newSession(string address)
    {
        
    }
}

public final class Session : Thread
{
    this(string address)
    {
        init(address);
    }

    private void init(string address)
    {
        /* TODO: Generate new AES key */
        /* TODO: Generate Session MessageType LinkMessage with key in it */
        /* TODO: Send a packet */
        /* TODO: Await on Engine for a certain message type */
    }
}