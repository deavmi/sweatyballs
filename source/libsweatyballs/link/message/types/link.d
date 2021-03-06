// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: source/libsweatyballs/link/message/types/protobufs/link.proto

module link;

import google.protobuf;

enum protocVersion = 3014000;

class LinkMessage
{
    @Proto(1) LinkMessageType type = protoDefaultValue!LinkMessageType;
    @Proto(2) bytes payload = protoDefaultValue!bytes;
    @Proto(3) string publicKey = protoDefaultValue!string;
    @Proto(4) string signature = protoDefaultValue!string;
    @Proto(5) string neighborPort = protoDefaultValue!string;
}

class Advertisement
{
    @Proto(2) RouteEntry[] routes = protoDefaultValue!(RouteEntry[]);
}

class RouteEntry
{
    @Proto(1) string address = protoDefaultValue!string;
    @Proto(2) uint metric = protoDefaultValue!uint;
}

class Packet
{
    @Proto(1) string fromKey = protoDefaultValue!string;
    @Proto(2) string toKey = protoDefaultValue!string;
    @Proto(3) string siganture = protoDefaultValue!string;
    @Proto(4) bytes payload = protoDefaultValue!bytes;
    @Proto(5) ulong ttl = protoDefaultValue!ulong;
}

enum LinkMessageType
{
    ADVERTISEMENT = 0,
    PACKET = 1,
}
