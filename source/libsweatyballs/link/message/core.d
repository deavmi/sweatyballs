module libsweatyballs.link.message.core;

/**
* Message
*
* base class for encoding/decoding messages
*/
public class Message
{
    /* TODO: Variable for the protocol buffer */
    private Protokak message;
    private byte[] messageBytes;

    /**
    * TODO: Decoder constructor
    */
    this(byte[] bytes)
    {
        decode(bytes);
    }

    private void decode(byte[] bytes)
    {
        /* TODO: Decode and get the bformat protobug message out and set it */
    }

    /**
    * TODO: Encoder constructor
    */
    this(ProtoBuf protoKak)
    {
        /* TODO: Set the protoKak */
        encode(protoKak);
    }

    private void encode(ProtoBuf protoKak)
    {

    }

    public ProtoKak getMessage()
    {
        return message;
    }

    public byte[] getButes()
    {
        return messageBytes;
    }


}