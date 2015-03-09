module main.d;

import std.stdio;
import std.datetime;
import std.conv;

import codewife.terms.common;

void main()
{
	string text;
	string line;
	while ((line = stdin.readln()) !is null)
		text ~= line;

	OutputTerm[] terms;
	StopWatch sw;

	sw.start();
	foreach(dchar alpha; text)
	{
		terms ~= makeInvariantTerm(to!string(alpha));
	}
	sw.stop();

	writeln("Code units: ", text.length);
	writeln("Elapsed time: ", sw.peek().usecs, " \u00B5secs");
	writeln("Time per unit: ", sw.peek().usecs/cast(real)text.length, " \u00B5secs");
}
