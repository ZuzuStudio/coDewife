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
}

Engine makeDigitalLiteral()
{
  import terms.invariantsequence;
  Engine[string] table;
  table["ForwardDigit"] = makeGeneral((string s) => "0" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[]);
  table["ForwardUnderscore"] = makeGeneral((string s) => s == "_",
                                           (string s) => cast(OutputTerm[])[]);
  table["BackwardDigit"] = makeRangeIdentity!backward("0", "9");
  table["BackwardLUDigit"] = makeGeneral!backward((string s) => "0" <= s && s <= "9",
                                                  (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s) ~ new LogicalUnderscore);
  table["XU"] = makeGeneral!backward((string s) => s == "_",
                                     (string s) => cast(OutputTerm[])[] ~ new LastUnderscore);
  table["CU"] = makeGeneral!backward((string s) => s == "_",
                                     (string s) => cast(OutputTerm[])[] ~ new CommonUnderscore);
  table["UU"] = makeGeneral!backward((string s) => s == "_",
                                     (string s) => cast(OutputTerm[])[] ~ new UserUnderscore);
  table["UU*D"] = makeSequence!backward(makeKleene!(star, backward)(table["UU"]),
                                        table["BackwardDigit"]);
  table["Period"] = makeSequence!backward(makeQuantifier!backward(table["UU*D"], 2),
                                          makeParallel!backward(makeSequence!backward(table["CU"],
                                                                                      makeKleene!(star, backward)(table["UU"]),
                                                                                      table["BackwardDigit"]),
                                                                table["BackwardLUDigit"]));
                                                                              
  table["ForwardIntLiteral"] = makeSequence(table["ForwardDigit"],
                                            makeKleene!star(makeParallel(table["ForwardDigit"],
                                                                         table["ForwardUnderscore"])));
  table["BackwardIntLiteral"] = makeSequence!backward(makeKleene!(star, backward)(table["XU"]),
                                                      table["BackwardDigit"],
                                                      makeKleene!(star, backward)(table["Period"]),
                                                      makeQuantifier!backward(table["UU*D"], 0, 2));
  table["IntLiteral"] = makeHitherAndThither(table["ForwardIntLiteral"], table["BackwardIntLiteral"]);
  return table["IntLiteral"];
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