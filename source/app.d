module sweatyballs.main;

import gogga;
import libsweatyballs.engine.configuration : Config;
import libsweatyballs.security.identity : Identity;
import libsweatyballs.link.core : Link;
import libsweatyballs.engine.core : Engine;

void main()
{
	gprintln("Welcome to sweatyballs");

	/* TODO: Add command-line parsing here with jcli */

	/* TODO: testing create config */
	Config config;

	/* Create a new Identity for my router */
	Identity myIdentity = Identity.newIdentity(1024);
	config.routerIdentity = myIdentity;

	/* Create some Links */
	Link[] links;
	links ~= new Link("interface1");
	links ~= new Link("interface2");
	config.links = links;

	/* Create a new Engine */
	Engine engine = new Engine(config);

	/* Start the engine */
	engine.launch();
}
