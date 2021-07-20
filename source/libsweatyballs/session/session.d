module libsweatyballs.session.session;

/**
* Session
*
* A Session runs ontop of the layer of transport that the protocol provides
* It sends PACKET LinkMessages the exchange keys (symmetric).
*
* It is intended one then used Session system for exchanging data in a faster
* way than directly usign PACKET and LinkMessages
*/