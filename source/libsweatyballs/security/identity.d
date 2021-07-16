module libsweatyballs.security.identity;

import crypto.rsa : RSAKeyPair, RSA;

/**
* Identity
*
* Description: Represents this router's identity
*/
public final class Identity
{
    /**
    * Router identity
    */
    private RSAKeyPair rsaKeys;
    private string fingerprint;

    this(RSAKeyPair keys)
    {
        /* ToDO: Validate keys */
        validateKeys(keys);

        this.rsaKeys = keys;

        /* Generate fingerprint */
        fingerprint = generateFingerprint(rsaKeys);
    }

    /**
    * Generates a fingerprint of the public key
    *
    * This will run SHA512 on the public key
    */
    public static string generateFingerprint(RSAKeyPair keys)
    {
        /* Generated fingerprint */
        string fingerprint;

        /* TODO: Validate keys */
        validateKeys(keys);

        /* SHA-512 the public key */
        import std.digest.sha;
        byte[] dataIn = [1,2];
        ubyte[] shaBytes = sha512Of(keys.publicKey);
        fingerprint = toHexString(shaBytes);


        /* TODO: Return fingerprint */
        return fingerprint;
    }

    public static bool validateKeys(RSAKeyPair keys)
    {
        /* TODO: make sure non-empty and that they are related */
        return true;
    }


    /**
    * Creates a new router identity. This includes generating a new
    * set of the following:
    * 1. An RSA key-pair
    * 2. TODO
    *
    * @param uint rsaBitLength: This is the bit length of the RSA keys
    */
    public static Identity newIdentity(uint rsaBitLength)
    {
        Identity identity;

        /* Create new RSA keys */
        RSAKeyPair rsaKeys = RSA.generateKeyPair(rsaBitLength);

        /* Create the Identity with the given keypair */
        identity = new Identity(rsaKeys);

        return identity;
    }

    public RSAKeyPair getKeys()
    {
        return rsaKeys;
    }

    public string getFingerprint()
    {
        return fingerprint;
    }

    public override string toString()
    {
        return "Identity "~fingerprint~")";
    }
}

unittest
{
    import std.stdio;

    Identity identity = Identity.newIdentity(1024);

    writeln(identity);
    writeln(identity.getFingerprint());
    writeln(identity.getKeys());
}