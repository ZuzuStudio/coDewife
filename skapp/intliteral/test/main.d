module main;

import  std.stdio;

import	terms.common;
import	fsm.configurations;
import 	sample.intliteral;

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
	disableLogicalUnderscore();
	disableUserUnderscore();
	disableCommonUnderscore();
	terms.output();
	writeln("\n============================================");
	writeln("============= User Underscore ==============");
	disableLogicalUnderscore();
	enableUserUnderscore();
	enableCommonUnderscore();
	terms.output();
	writeln("\n============================================");
	writeln("============= Logical Underscore ===========");
	enableLogicalUnderscore();
	disableUserUnderscore();
	enableCommonUnderscore();
	terms.output();
	writeln("\n============================================");
	writeln("============= Common Underscore ============");
	disableLogicalUnderscore();
	disableUserUnderscore();
	enableCommonUnderscore();
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