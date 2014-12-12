module main;

import  
	std.stdio,
	std.string,
	fsm.global,
	terms.commonunderscore,
	terms.logicalunderscore,
	terms.userundescore;

void main()
{
	Engine[] steam_engine;
	steam_engine~=new DigitLiteral;
	steam_engine~=new SimpleReplace("#");

	auto line = readln();
	OutputTerm[] terms;
	do
	{
		terms ~= steam_engine[0].parse(line);
		terms ~= steam_engine[1].parse(line);
	}while(line.length);

	writeln("============= No Underscore ================");
	LogicalUnderscore.printable = false;
	UserUnderscore.printable = false;
	CommonUnderscore.printable = false;
	foreach(term; terms)
	{
		write(term.outputCharSequence);
	}
	writeln("\n============================================");
	writeln("============= User Underscore ==============");
	LogicalUnderscore.printable = false;
	UserUnderscore.printable = true;
	CommonUnderscore.printable = true;
	foreach(term; terms)
	{
		write(term.outputCharSequence);
	}
	writeln("\n============================================");
	writeln("============= Logical Underscore ===========");
	LogicalUnderscore.printable = true;
	UserUnderscore.printable = false;
	CommonUnderscore.printable = true;
	foreach(term; terms)
	{
		write(term.outputCharSequence);
	}
	writeln("\n============================================");
	writeln("============= User Underscore ==============");
	LogicalUnderscore.printable = false;
	UserUnderscore.printable = false;
	CommonUnderscore.printable = true;
	foreach(term; terms)
	{
		writeln(term.outputCharSequence);
	}
	writeln("\n============================================");
}
