module main;

import  
	std.stdio,
	std.string,
	fsm.digitliteral,
	terms.commonunderscore,
	terms.logicalunderscore,
	terms.userundescore;

void main()
{
	auto steam_engine = DigitLiteral(1);

	auto line = readln();
	steam_engine.parse(line);
	auto terms = steam_engine.getInternalModel();

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
		write(term.outputCharSequence);
	}
	writeln("\n============================================");
}
