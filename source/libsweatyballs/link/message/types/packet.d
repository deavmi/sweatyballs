module libsweatyballs.link.message.types.packet;

import libsweatyballs.link.message.core : Message;

/**
* DataPacket
*
* Description: This message type represents a data packet that needs to be routed to its
* eventual destination
*/
public final class DataPacket : Message
{
    private string publicKey;
    private byte[] payload;

    /* TODO: Fix this (this is just to get compilation to work) */
    this(string publicKey, byte[] payload)
    {
        super(new byte[1]);

        this.publicKey = publicKey;
        this.payload = payload;
    }

    /* TODO: To be honest we should open a session first */
    public byte[] encode()
    {
        /* TODO: Validate that lengt pf `publicKey` and `payload` are not zero */

        /* Encrypt the payload to the `publicKey` */
        //byte[] encryptedPayload = RSA.encrypt(publicKey, payload);

        /* TODO: */
        return null;
    }

    /* TODO: Fix this (this is just to get compilation to work) */
    this()
    {
        super("");
    }
}