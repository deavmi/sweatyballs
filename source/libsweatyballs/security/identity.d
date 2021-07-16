module libsweatyballs.security.identity;

import crypto.rsa : RSAKeypair, RSA;

/**
* Identity
*
* Description: represents a router's identity
*/
public final class Identity
{
    /**
    * Roiter identity
    */
    private RSAKeyPair rsaKeys;
    private string fingerprint;

    this(RSAKeyPair keys)
    {
        /* ToDO: Validate keys */
        validateKeys();

        this.rsakeys = keys;

        /* Generate fingerprint */
        fingerprint = generateFingerprint();
    }

    public static string generateFingerprint(RSAKeyPair keys)
    {
        string fingerprint;

        /* TODO: Return fingerprint */
        return fingerprint;
    }

    private void validateKeys(RSAKeyPair keys)
    {
        /* TODO: make sure non-empty and that they are related */
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

        /* TODO: Create a public key fingerprint */

        return identity;
    }
}

unittest
{
    Identity identity;

    identity = Identity.newIdentity(1024);
}