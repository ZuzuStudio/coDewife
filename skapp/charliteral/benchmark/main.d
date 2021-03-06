module main;

import std.stdio;
import std.datetime;


import codewife.fsm.configurations;
import sample.charliteral;


void main()
{
	string text;
	string line;
	while ((line = stdin.readln()) !is null)
		text ~= line;
	
	Engine[] steam_engine;
	steam_engine ~= makeCharLiteral();
	steam_engine ~= makeAllIdentity();
	
	OutputTerm[] terms;
	size_t position = 0;
	
	StopWatch sw;
	
	sw.start();
	while(position < text.length)
	{
		if(steam_engine[0].parse(text, position, terms))
		  continue;
		steam_engine[1].parse(text, position, terms);
	}
	sw.stop();
	
	writeln("\nOutput:");
	writeln(terms.charSequence);
	
	writeln("\n\nCode units: ", text.length);
	writeln("Elapsed time: ", sw.peek().usecs, " \u00B5secs");
	writeln("Time per unit: ", sw.peek().usecs/cast(real)text.length, " \u00B5secs");
}