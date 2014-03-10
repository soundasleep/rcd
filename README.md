rcd
===

A multiplayer Ruby dungeon crawler created at [Rails Camp NZ 2014](http://camp.ruby.org.nz/). This was made over two days and involved a lot of cider.

This is my second ever project in Ruby and mostly was a mechanism for me to learn more Ruby. 
Consequently there are heaps of bugs and it needs significant amounts of refactoring, etc.
(I only learnt about `require_relative` yesterday.)

Running
-------

Run a server: `ruby server.rb`

Run a client: `ruby client.rb`

Keys:
`wasd` - move
`WASD` - shoot at critters and walls
`Q` - quit

Things that need to be done
---------------------------

The networking component was written from scratch using TCP sockets, and I don't know that much about Ruby
thread safety yet, so it's very likely the game may desync between clients and the server.

You can't shoot players.

There isn't actually any goals in the game. Scoring, respawning etc - not implemented.
