module main;

import  std.stdio;

import	codewife.fsm.configurations;
import	sample.charliteral;

void main()
{
	Engine[] steam_engine;
	steam_engine ~= makeCharLiteral();
	steam_engine ~= makeHungryMachine();
	
	auto line = readln();
	line = line[0..$-1];
	OutputTerm[] terms;
	size_t position=0;
	while(position < line.length)
	{
		if(steam_engine[0].parse(line, position, terms))
		  continue;
		steam_engine[1].parse(line, position, terms);
	}

	writeln("============= CHARLITERAL TEST =============");
	terms.output();
	writeln("\n============================================");
}

void output(OutputTerm[] terms)
{
	foreach(term; terms)
	{
		write(term.charSequence);
	}
	writeln("\n");
	foreach(term; terms)
	{
		writef("%2s ", term.charSequence);
	}
	writeln();
	foreach(term; terms)
	{
		write(term.id,":");
	}
	writeln();
}