module main;

import  std.stdio;

import	terms.underscore;
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
	LogicalUnderscore.printable = false;
	UserUnderscore.printable = false;
	CommonUnderscore.printable = false;
	terms.output();
	writeln("\n============================================");
	writeln("============= User Underscore ==============");
	LogicalUnderscore.printable = false;
	UserUnderscore.printable = true;
	CommonUnderscore.printable = true;
	terms.output();
	writeln("\n============================================");
	writeln("============= Logical Underscore ===========");
	LogicalUnderscore.printable = true;
	UserUnderscore.printable = false;
	CommonUnderscore.printable = true;
	terms.output();
	writeln("\n============================================");
	writeln("============= Common Underscore ============");
	LogicalUnderscore.printable = false;
	UserUnderscore.printable = false;
	CommonUnderscore.printable = true;
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