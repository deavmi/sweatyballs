module sweatyballs.main;

import gogga;
import libsweatyballs.engine.configuration : Config;
import libsweatyballs.security.identity : Identity;
import libsweatyballs.link.core : Link;
import libsweatyballs.engine.core : Engine;
import libtun.adapter : TUNException;

void main(string[] args)
{
	gprintln("Welcome to sweatyballs");


	/* TODO: Add command-line parsing here with jcli */

	/* TODO: testing create config */
	Config config;

	/* Create a new Identity for my router */
	Identity myIdentity = Identity.newIdentity(1024);
	config.routerIdentity = myIdentity;

	/* Create some Links */
	string[] links = args[1..args.length];
	//links ~= new Link("interface2");
	config.links = links;

	/* The Engine */
	Engine engine;

	/* Attempt to create a new Engine */
	try
	{
		/* Create the Engine */
		engine = new Engine(config);

		/* Start the engine */
		engine.launch();
	}
	/* Fail well */
	catch(TUNException e)
	{
		gprintln("Error creating tun device: "~e.msg, DebugType.ERROR);
	}
}
