module sweatyballs.main;

import gogga;
import libsweatyballs.engine.configuration : Config;
import libsweatyballs.security.identity : Identity;
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

	/* Create a new Engine */
	Engine engine = new Engine(config);

	/* Start the engine */
	engine.launch();
}
