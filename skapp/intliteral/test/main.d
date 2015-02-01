module main;

import  std.stdio;

import  codewife.terms.common;
import  codewife.fsm.configurations;
import  sample.intliteral;

void main()
{
	auto engine = makeParallel(makeDigitalLiteral(), makeSymbolIdentity());

	auto line = readln();
	line = line[0..$-1];
	OutputTerm[] terms;
	size_t position=0;
	while(engine.parse(line, position, terms))
	{}

	writeln("============= No Underscore ================");
	disableUnderscore();
	terms.output();
	writeln("\n============================================");
	writeln("============= User Underscore ==============");
	keepUserUnderscore();
	terms.output();
	writeln("\n============================================");
	writeln("============= All User Underscore ===========");
	keepAllUserUnderscore();
	terms.output();
	writeln("\n============================================");
	writeln("============= Logical Underscore ============");
	bytifyUnderscore();
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

version(monod)
{
	static ~this()
	{
		write("Press Enter to continue...");
		readln();
	}
}