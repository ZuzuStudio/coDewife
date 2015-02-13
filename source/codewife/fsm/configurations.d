module codewife.fsm.configurations;

import std.conv;
public import codewife.fsm.common;
public import codewife.fsm.elementar;

// MAYBE private
final class Configurator(Direction direction): Engine
{
public:
	mixin MixStandartParse!(direction);
	
private:
	State start;
	
	this()
	{
	}
}

unittest
{
	import std.traits;
	static assert(__traits(compiles, 
	    {
		    auto engine = makeSequence(makeSingleIdentity("a"), 
		                               makeRangeIdentity("0","9")
		                              );
	    }));
	static assert(__traits(compiles, 
	    {
		    auto engine = makeSequence("abc");
	    }));
	auto engine = makeSequence("abc");
	size_t position;
	OutputTerm[] output = [];
	assert(engine.parse("abc",position,output));
	assert(position == 3);
	assert(output[1].charSequence == "b");
	assert(output.charSequence == "abc");
	position = 0;
	output = [];
	assert(!engine.parse("ab",position,output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = [];
	assert(!engine.parse("acb",position,output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = [];
	assert(!engine.parse("acb",position,output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = [];
	assert(engine.parse("abcdef",position,output));
	assert(position == 3);
	assert(output.charSequence == "abc");
	position = 0;
	output = [];
	assert(engine.parse("abcabc",position,output));
	assert(position == 3);
	assert(output.charSequence == "abc");

	engine = makeSequence(makeSingleIdentity("a"), makeRangeIdentity("0","9"));
	position = 0;
	output = [];
	assert(engine.parse("a3",position,output));
	assert(position == 2);
	assert(output.charSequence == "a3");
	position = 0;
	output = [];
	assert(engine.parse("a9",position,output));
	assert(position == 2);
	assert(output.charSequence == "a9");
	position = 0;
	output = [];
	assert(!engine.parse("3a",position,output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = [];
	assert(engine.parse("a3a5",position,output));
	assert(position == 2);
	assert(output.charSequence == "a3");
	position = 0;
	output = [];
	assert(engine.parse("a334",position,output));
	assert(position == 2);
	assert(output.charSequence == "a3");
	position = 0;
	output = [];
	assert(!engine.parse("a",position,output));
	assert(position == 0);
	assert(output == []);

	import std.stdio;
	engine = makeSequence!backward("cba");
	position = 3;
	output = [];
	assert(engine.parse("abc", position, output));
	assert(position == 0);
	assert(output.charSequence == "abc");

	position = 3;
	output = [];
	assert(!engine.parse("acc",position,output));
	assert(position == 3);
	assert(output == []);
	assert(!engine.parse("bac",position,output));
	assert(position == 3);
	assert(output == []);
	assert(!engine.parse("cba",position,output));
	assert(position == 3);
	assert(output == []);

	engine = makeSequence!backward("гвб");
	position = 6;
	output = [];
	assert(engine.parse("бвг", position, output));
	assert(position == 0);
	assert(output.charSequence == "бвг");
}

Engine makeSequence(Direction direction = forward, string OutputType = "IS")(string keyString)
{
	Engine[] list;
	foreach(dchar symbol; keyString)
	{
		static if(direction == forward)
			list ~= makeSingleIdentity!(forward, OutputType)(to!string(symbol));
		else
		{
			list ~= makeGeneral!(Direction.backward)((string s) => s == to!string(symbol),
			                                         (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm!(OutputType)(s));	
		}
	}
	return makeSequence!direction(list);
}

Engine makeSequence(Direction direction = forward)(Engine[] list...)
{
	return makeSequence!direction(list);
}

Engine makeSequence(Direction direction = forward)(Engine[] list)
{
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	auto badCrash = new State(bad);
	State current = result.start;
	foreach(engine; list)
	{
		auto newState = new State;
		current.addEdge(new Edge!direction(engine), newState);
		current.addEdge(new Edge!(direction, quasi)(makeAllIdentity!direction()), badCrash);
		current = newState;
	}
	current.addEdge(new Edge!(direction,quasi)(makeAllIdentity!direction()), goodCrash);
	return result;
}

unittest
{
	import std.traits;

	static assert(__traits(compiles, {auto engine = makeParallel(makeSingleIdentity("a"), makeRangeIdentity("0","9"));}));
	
	auto engine = makeParallel(makeSingleIdentity("a"), makeRangeIdentity("0","9"));
	size_t position;
	OutputTerm[] output;

	position = 0;
	output = [];
	assert(engine.parse("a3",position,output));
	assert(position == 1);
	assert(output.charSequence == "a");
	position = 0;
	output = [];
	assert(engine.parse("9a",position,output));
	assert(position == 1);
	assert(output.charSequence == "9");
	position = 0;
	output = [];
	assert(!engine.parse("bac",position,output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = [];
	assert(engine.parse("3712",position,output));
	assert(position == 1);
	assert(output.charSequence == "3");
	position = 0;
	output = [];

	engine = makeParallel(makeSequence("zuzu"), makeSequence(makeRangeIdentity("0", "5"), makeSequence("_item")));
	position = 0;
	output = [];
	assert(engine.parse("zuzu27",position,output));
	assert(position == 4);
	assert(output.charSequence == "zuzu");
	position = 0;
	output = [];
	assert(engine.parse("2_items",position,output));
	assert(position == 6);
	assert(output.charSequence == "2_item");
	position = 0;
	output = [];
	assert(!engine.parse("uzuzu",position,output));
	assert(position == 0);
	assert(output.charSequence == []);

	engine = makeParallel!backward(makeSequence!backward("uzuz"), makeSequence!backward("cba"));
	position = 7;
	output = [];
	assert(engine.parse("abczuzu", position, output));
	assert(position == 3);
	assert(output.charSequence == "zuzu");
	assert(engine.parse("abczuzu", position, output));
	assert(position == 0);
	assert(output.charSequence == "abczuzu");

	position = 7;
	output = [];
	assert(!engine.parse("bczuzua", position, output));
	assert(position == 7);
	assert(output == []);

}

Engine makeParallel(Direction direction = forward)(Engine[] list...)
{
	return makeParallel!direction(list);
}

Engine makeParallel(Direction direction = forward)(Engine[] list)
{
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	auto badCrash = new State(bad);
	State current = result.start;
	auto goodState = new State;
	goodState.addEdge(new Edge!(direction, quasi)(makeAllIdentity!direction()), goodCrash);
	foreach(engine; list)
	{
		current.addEdge(new Edge!direction(engine), goodState);
	}
	current.addEdge(new Edge!(direction,quasi)(makeAllIdentity!direction()), badCrash);
	return result;
}


unittest
{
	import std.traits;
	
	static assert(__traits(compiles, {auto engine = makeKleene!star(makeSingleIdentity("a"));}));
	static assert(__traits(compiles, {auto engine = makeKleene!plus(makeSingleIdentity("a"));}));

	auto engine = makeKleene!star(makeSingleIdentity("a"));

	size_t position;
	OutputTerm[] output = [];
	assert(engine.parse("",position, output));
	assert(position == 0);
	assert(output == []);

	position = 0;
	output = [];
	assert(engine.parse("a", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");

	position = 0;
	output = [];
	assert(engine.parse("aa", position, output));
	assert(position == 2);
	assert(output.charSequence == "aa");

	position = 0;
	output = [];
	assert(engine.parse("aaa", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");

	position = 0;
	output = [];
	assert(engine.parse("aaa0", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");

	position = 0;
	output = [];
	assert(engine.parse("aaaabaa", position, output));
	assert(position == 4);
	assert(output.charSequence == "aaaa");

	position = 0; 
	output = [];
	assert(engine.parse("aaaaaaa", position, output));
	assert(position == 7);
	assert(output.charSequence == "aaaaaaa");

	position = 0;
	output = [];
	assert(engine.parse("baaaaaaa", position, output));
	assert(position == 0);
	assert(output == []);

	engine = makeKleene!plus(makeSingleIdentity("a"));

	position = 0;
	output = [];
	assert(!engine.parse("",position, output));
	assert(position == 0);
	assert(output == []);
	
	position = 0;
	output = [];
	assert(engine.parse("a", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");
	
	position = 0;
	output = [];
	assert(engine.parse("aa", position, output));
	assert(position == 2);
	assert(output.charSequence == "aa");
	
	position = 0;
	output = [];
	assert(engine.parse("aaa", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");
	
	position = 0;
	output = [];
	assert(engine.parse("aaa0", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");
	
	position = 0;
	output = [];
	assert(engine.parse("aaaabaa", position, output));
	assert(position == 4);
	assert(output.charSequence == "aaaa");
	
	position = 0; 
	output = [];
	assert(engine.parse("aaaaaaa", position, output));
	assert(position == 7);
	assert(output.charSequence == "aaaaaaa");
	
	position = 0;
	output = [];
	assert(!engine.parse("baaaaaaa", position, output));
	assert(position == 0);
	assert(output == []);

	engine = makeKleene!(star, backward)(makeGeneral!(Direction.backward)((string s) => "0" <= s && s <= "9",
	                                                                     (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm(s)));
	position = 7;
	output = [];
	assert(engine.parse("123a456", position, output));
	assert(position == 4);
	assert(output.charSequence == "456");

	position = 7;
	output = [];
	assert(engine.parse("123a45b", position, output));
	assert(position == 7);
	assert(output == []);

	engine = makeKleene!(plus, backward)(makeGeneral!(Direction.backward)((string s) => "0" <= s && s <= "9",
	                                                                      (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm(s)));
	position = 7;
	output = [];
	assert(engine.parse("123a456", position, output));
	assert(position == 4);
	assert(output.charSequence == "456");
	
	position = 7;
	output = [];
	assert(!engine.parse("123a45b", position, output));
	assert(position == 7);
	assert(output == []);
}

enum KleeneKind: ubyte {star, plus};

alias star = KleeneKind.star;
alias plus = KleeneKind.plus;

Engine makeKleene(KleeneKind kind, Direction direction = forward)(Engine engine)
{
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	static if(kind == plus)
		auto badCrash = new State(bad);
	auto newState = new State;
	result.start.addEdge(new Edge!direction(engine), newState);
	static if(kind == star)
		result.start.addEdge(new Edge!(direction,quasi)(makeAllIdentity!direction()), goodCrash);
	else
		result.start.addEdge(new Edge!(direction,quasi)(makeAllIdentity!direction()), badCrash);
	newState.addEdge(new Edge!direction(engine), newState);
	newState.addEdge(new Edge!(direction, quasi)(makeAllIdentity!direction()), goodCrash);
	return result;
}

unittest
{
	import core.exception, std.traits;
	static assert(__traits(compiles, {auto engine = makeQuantifier(makeSingleIdentity("a"), 4);}));
	try
	{
		auto engine = makeQuantifier(null, 4);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "engine is null");
	}
	try
	{
		auto engine = makeQuantifier(makeSingleIdentity("a"), 0);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "n == 0");
	}

	auto engine = makeQuantifier(makeSingleIdentity("a"), 4);

	size_t position = 0;
	OutputTerm[] output = [];
	assert(engine.parse("aaaadf", position, output));
	assert(position == 4);
	assert(output.charSequence == "aaaa");

	position = 0;
	output = [];
	assert(!engine.parse("aaadf", position, output));
	assert(position == 0);
	assert(output == []);

	position = 0;
	output = [];
	assert(engine.parse("aaaaadf", position, output));
	assert(position == 4);
	assert(output.charSequence == "aaaa");

	engine = makeQuantifier!backward(makeSingleIdentity!backward("a"), 4);
	position = 6;
	output = [];
	assert(engine.parse("dfaaaa", position, output));
	assert(position == 2);
	assert(output.charSequence == "aaaa");

	position = 5;
	output = [];
	assert(!engine.parse("dfaaa", position, output));
	assert(position == 5);
	assert(output == []);

	position = 6;
	output = [];
	assert(engine.parse("daaaaa", position, output));
	assert(position == 2);
	assert(output.charSequence == "aaaa");
}

Engine makeQuantifier(Direction direction = forward)(Engine engine, size_t n)
in
{
	assert(engine, "engine is null");
	assert(n != 0, "n == 0");
}
body
{
	Engine[] list;
	foreach(i; 0..n)
		list ~= engine;
	return makeSequence!direction(list);
}

unittest
{
	import core.exception, std.traits;
	static assert(__traits(compiles, {auto engine = makeQuantifier(makeSingleIdentity("a"), 4, 6);}));
	try
	{
		auto engine = makeQuantifier(null, 4, 7);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "engine is null");
	}
	try
	{
		auto engine = makeQuantifier(makeSingleIdentity("a"), 7, 3);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "imposible m or n");
	}

	auto engine = makeQuantifier(makeRangeIdentity("a", "e"), 4, 6);

	size_t position = 0;
	OutputTerm[] output = [];
	assert(!engine.parse("abbfe", position, output));
	assert(position == 0);
	assert(output == []);

	position = 0;
	output = [];
	assert(engine.parse("abbcfe", position, output));
	assert(position == 4);
	assert(output.charSequence == "abbc");

	position = 0;
	output = [];
	assert(engine.parse("abbcafe", position, output));
	assert(position == 5);
	assert(output.charSequence == "abbca");

	position = 0;
	output = [];
	assert(engine.parse("abbcadfe", position, output));
	assert(position == 6);
	assert(output.charSequence == "abbcad");

	position = 0;
	output = [];
	assert(engine.parse("abbcaddfe", position, output));
	assert(position == 6);
	assert(output.charSequence == "abbcad");



	engine = makeQuantifier(makeRangeIdentity("a", "d"), 0, 3);
	position = 0;
	output = [];
	assert(engine.parse("abba", position, output));
	assert(position == 3);
	assert(output.charSequence == "abb");

	position = 0;
	output = [];
	assert(engine.parse("ac/dc", position, output));
	assert(position == 2);
	assert(output.charSequence == "ac");

	position = 0;
	output = [];
	assert(engine.parse("zuzu", position, output));
	assert(position == 0);
	assert(output == []);



	engine = makeQuantifier(makeRangeIdentity("a", "d"), 2, 0);
	position = 0;
	output = [];
	assert(engine.parse("abba", position, output));
	assert(position == 4);
	assert(output.charSequence == "abba");
	
	position = 0;
	output = [];
	assert(engine.parse("ac/dc", position, output));
	assert(position == 2);
	assert(output.charSequence == "ac");
	
	position = 0;
	output = [];
	assert(!engine.parse("zuzu", position, output));
	assert(position == 0);
	assert(output == []);

	position = 0;
	output = [];
	assert(!engine.parse("azkaban", position, output));
	assert(position == 0);
	assert(output == []);



	engine = makeQuantifier(makeRangeIdentity("a", "d"), 0, 0);
	position = 0;
	output = [];
	assert(engine.parse("abba", position, output));
	assert(position == 4);
	assert(output.charSequence == "abba");
	
	position = 0;
	output = [];
	assert(engine.parse("ac/dc", position, output));
	assert(position == 2);
	assert(output.charSequence == "ac");
	
	position = 0;
	output = [];
	assert(engine.parse("zuzu", position, output));
	assert(position == 0);
	assert(output == []);
	
	position = 0;
	output = [];
	assert(engine.parse("azkaban", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");
}

Engine makeQuantifier(Direction direction = forward)(Engine engine, size_t m, size_t n)
in
{
	assert(engine, "engine is null");
	assert(!n || m < n, "imposible m or n");
}
body
{
	if(n)
	{
		if(m)
			return makeSequence!direction(makeQuantifier!direction(engine, m), makeNoMoreThan!direction(engine, n - m));
		else
			return makeNoMoreThan!direction(engine, n);
	}
	else
	{
		if(m)
			return makeSequence!direction(makeQuantifier!direction(engine, m), makeKleene!star(engine));
		else
			return makeKleene!star(engine);
	}
}

unittest
{
	import core.exception, std.traits;
	static assert(__traits(compiles, {auto engine = makeNoMoreThan(makeSingleIdentity("a"), 3);}));
	try
	{
		auto engine = makeNoMoreThan(null, 3);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "engine is null");
	}
	try
	{
		auto engine = makeNoMoreThan(makeSingleIdentity("a"), 0);
	}
	catch(AssertError ae)
	{
		assert(ae.msg == "n == 0");
	}

	auto engine = makeNoMoreThan(makeSingleIdentity("a"), 3);
	size_t position = 0;
	OutputTerm[] output = [];
	assert(engine.parse("bbbbb", position, output));
	assert(position == 0);
	assert(output == []);

	assert(engine.parse("abbbb", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");

	position = 0;
	output = [];
	assert(engine.parse("aabbb", position, output));
	assert(position == 2);
	assert(output.charSequence == "aa");

	position = 0;
	output = [];
	assert(engine.parse("aaabb", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");

	position = 0;
	output = [];
	assert(engine.parse("aaaab", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");

	engine = makeNoMoreThan!backward(makeParallel!backward(makeSingleIdentity!backward("a"), makeSingleIdentity!backward("c")), 3);

	position = 5;
	output = [];
	assert(engine.parse("bbbbb", position, output));
	assert(position == 5);
	assert(output == []);

	position = 5;
	output = [];
	assert(engine.parse("bbbba", position, output));
	assert(position == 4);
	assert(output.charSequence == "a");

	position = 5;
	output = [];
	assert(engine.parse("bbbca", position, output));
	assert(position == 3);
	assert(output.charSequence == "ca");

	position = 5;
	output = [];
	assert(engine.parse("bbcca", position, output));
	assert(position == 2);
	assert(output.charSequence == "cca");

	position = 5;
	output = [];
	assert(engine.parse("bccca", position, output));
	assert(position == 2);
	assert(output.charSequence == "cca");
}

private Engine makeNoMoreThan(Direction direction = forward)(Engine engine, size_t n)
in
{
	assert(engine, "engine is null");
	assert(n != 0, "n == 0");
}
body
{
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	State current = result.start;
	foreach(i; 0..n)
	{
		auto newState = new State;
		current.addEdge(new Edge!direction(engine), newState);
		current.addEdge(new Edge!(direction, quasi)(makeAllIdentity!direction()), goodCrash);
		current = newState;
	}
	current.addEdge(new Edge!(direction,quasi)(makeAllIdentity!direction()), goodCrash);
	return result;
}

unittest
{
	auto engine = makeHitherAndThither(makeKleene!star(makeGeneral((string s) => "0" <= s && s <= "9", 
	                                                               (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm(s))),
	                                   makeSequence!backward(makeKleene!(star, backward)(makeGeneral!(Direction.backward)((string s) => s == "2" || s == "5",
	                                                                                                                      (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm(to!string(cast(dchar)(decodeFront(s)+1))))),
	                                                         makeGeneral!backward((string s) => true,
	                                                                              (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm("_"))));

	size_t position = 0;
	OutputTerm[] output = [];
	assert(engine.parse("32452552a b25", position, output));
	assert(position == 8);
	assert(output.charSequence == "32452552_63663");

	engine = makeHitherAndThither(makeKleene!star(makeGeneral((string s) => "1" <= s && s <= "9", 
	                                                          (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm(s))),
	                              makeGeneral!backward((string s) => s == "3" || s == "6" || s == "9",
	                                                   (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm(":" ~ s)));
	position = 0;
	output = [];
	assert(!engine.parse("12567ttt", position, output));
	assert(position==0);
	assert(output == []);
	assert(engine.parse("12576ttt", position, output));
	assert(position == 5);
	assert(output.charSequence == "12576:6");
}

Engine makeHitherAndThither(Direction direction = forward)(Engine hither, Engine thither)
{
	static if(direction == forward)
		enum contrdirection = backward;
	else
		enum contrdirection = forward;

	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	auto badCrash = new State(bad);

	auto newState = new State;

	result.start.addEdge(new Edge!direction(hither), newState);
	result.start.addEdge(new Edge!(direction, quasi)(makeAllIdentity!direction()), badCrash);

	newState.addEdge(new Edge!(direction, reverse)(thither), goodCrash);
	newState.addEdge(new Edge!(direction, quasi)(makeAllIdentity!contrdirection()), badCrash);

	return result;
}