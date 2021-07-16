module libsweatyballs.engine.configuration;

import libsweatyballs.security.identity : Identity;
import libsweatyballs.link.core : Link;

public struct Config
{
    Identity routerIdentity;
    Link[] links;
}