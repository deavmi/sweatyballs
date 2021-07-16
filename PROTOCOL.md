Protocol
========

This document aims to describe the _protocol_ for the routing engine (how it functions, router advertisements, handling of received routes, etc.) and other components, the _packet format_ describing what the data layout looks like and how to construct it and lastly

# Components

## Router

The router has several responsibilities, namely:

1. Maintaining the routing table
    * Adding and removing routes
    * Expiring routes
    * Allowing for queruing of routes
2. Sending route advertisements
    * Letting neighbouring routers know of which routes _we_ know of
3. Handling received route advertisements
    * Adding these to the routing table

## Switch

The switch has a only one responsibiloty:

1. Maintaining a UNIX domain socket
    * This socket is used by applications wanting to send data _in_ and _out_ of the network
    * Users can write a packet into this socket and let the switch handle its delivery
    * Users can read from this socket and obtain a packet that has been received

Nothing else is required here, that is all the switch needs to do.

# Packet format

## Primer

Prototyping something very fast has a lot of downsides to it potentially. I was very eager to go ahead and build out a packet format by hand by manually manipulating bytes but regardless of how skilled I am at doing that, for developing and changing the format several times during development, it can become a bit painful. It is with this in mind that I decided the format would be mainly based off of however Protocol Buffers decides to encode it (I say mainly because there is one component of mine included too, discussed later).

It is with this in mind that you won't see much of a wire format described but rather a list of protocol buffer descriptors.

## Format

Here I will describe the actual format used. There is a partial piece of wire format here which is the header of the protocol-buffer encoded message, this is the _bformat_ header which is a 4 byte entity encoding a length field (unsigned) using little-endian encoding. This is used to demarcate the length of the bytes to read that form the protocol-buffer encoded message, therefore the format looks as follows:

```
|--- bformat length field (4 bytes, unsigned, little endian) ---|--- ProtocolBuffer Message bytes (bformat-length-many bytes) ---|
```

That is all there is in terms of a wire format, the next sub-sections will describe the ProtocolBuffer message types with their descriptors.

### TODO: Message type 1

Description: TODO

Data descriptor:

```protobuf
```