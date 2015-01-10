module main;

import  std.stdio;

import	terms.underscore;
import	fsm.configurations;

void main()
{
	Engine[] steam_engine;
	steam_engine ~= makeDigitalLiteral();
	steam_engine ~= makeAllIdentity();

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
	readln();
}

Engine makeDigitalLiteral()
{
  import terms.invariantsequence;
  Engine[string] table;
  table["ForwardDigit"] = makeGeneral((string s) => "0" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[]);
  return makeGeneral((string s) => "0" <= s && s <= "9",
                     (string s) => cast(OutputTerm[])[] ~ new InvariantSequence("*" ~ s));
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