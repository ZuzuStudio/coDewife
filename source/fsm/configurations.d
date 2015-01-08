module fsm.configurations;

import std.conv;
import fsm.common;
import fsm.elementar;

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

Engine makeSequence(Direction direction = Direction.forward)(string keyString)
{
	import terms.invariantsequence;
	Engine[] list;
	foreach(dchar symbol; keyString)
	{
		static if(direction == forward)
			list ~= makeSingleIdentity(to!string(symbol));
		else
		{
			list ~= makeGeneral!(Direction.backward)((string s) => s == to!string(symbol),
			                                         (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));	
		}
	}
	return makeSequence!direction(list);
}

Engine makeSequence(Direction direction = Direction.forward)(Engine[] list...)
{
	return makeSequence!direction(list);
}

Engine makeSequence(Direction direction = Direction.forward)(Engine[] list)
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
		current.addEdge(new Edge!(direction, quasi)(makeAllIdentity()), badCrash);
		current = newState;
	}
	current.addEdge(new Edge!(direction,quasi)(makeAllIdentity()), goodCrash);
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

Engine makeParallel(Direction direction = Direction.forward)(Engine[] list...)
{
	return makeParallel!direction(list);
}

Engine makeParallel(Direction direction = Direction.forward)(Engine[] list)
{
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	auto badCrash = new State(bad);
	State current = result.start;
	auto goodState = new State;
	goodState.addEdge(new Edge!(direction, quasi)(makeAllIdentity()), goodCrash);
	foreach(engine; list)
	{
		current.addEdge(new Edge!direction(engine), goodState);
	}
	current.addEdge(new Edge!(direction,quasi)(makeAllIdentity()), badCrash);
	return result;
}


unittest
{
	import std.traits;
	
	static assert(__traits(compiles, {auto engine = makeCliniAsterisc(makeSingleIdentity("a"));}));

	auto engine = makeCliniAsterisc(makeSingleIdentity("a"));

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

	import terms.invariantsequence;
	engine = makeCliniAsterisc!backward(makeGeneral!(Direction.backward)((string s) => "0" <= s && s <= "9",
	                                                                     (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s)));
	position = 7;
	output = [];
	assert(engine.parse("123a456", position, output));
	assert(position == 4);
	assert(output.charSequence == "456");
}

Engine makeCliniAsterisc(Direction direction = Direction.forward)(Engine engine)
{
	enum quasi = true;
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	auto newState = new State;
	result.start.addEdge(new Edge!direction(engine), newState);
	result.start.addEdge(new Edge!(direction,quasi)(makeAllIdentity()), goodCrash);
	newState.addEdge(new Edge!direction(engine), newState);
	newState.addEdge(new Edge!(direction, quasi)(makeAllIdentity()), goodCrash);
	return result;
}

unittest
{
	import terms.invariantsequence;
	auto engine = makeHitherAndThither(makeCliniAsterisc(makeGeneral((string s) => "0" <= s && s <= "9", 
	                                                                 (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s))),
	                                   makeSequence!backward(makeCliniAsterisc!backward(makeGeneral!(Direction.backward)((string s) => s == "2" || s == "5",
	                                                                                                                     (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(to!string(cast(dchar)(decodeFront(s)+1))))),
	                                                         makeGeneral!(Direction.backward)((string s) => true,
	                                                                                          (string s) => cast(OutputTerm[])[] ~ new InvariantSequence("_"))));

	size_t position = 0;
	OutputTerm[] output = [];
	assert(engine.parse("32452552a b25", position, output));
	assert(position == 8);
	assert(output.charSequence == "32452552_63663");

	engine = makeHitherAndThither(makeCliniAsterisc(makeGeneral((string s) => "1" <= s && s <= "9", 
	                                                            (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s))),
	                              makeGeneral!(Direction.backward)((string s) => s == "3" || s == "6" || s == "9",
	                                                               (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(":" ~ s)));
	position = 0;
	output = [];
	assert(!engine.parse("12567ttt", position, output));
	assert(position==0);
	assert(output == []);
	assert(engine.parse("12576ttt", position, output));
	assert(position == 5);
	assert(output.charSequence == "12576:6");
}

Engine makeHitherAndThither(Direction direction = Direction.forward)(Engine hither, Engine thither)
{
	auto result = new Configurator!direction;
	result.start = new State;
	auto goodCrash = new State(good);
	auto badCrash = new State(bad);

	auto newState = new State;

	result.start.addEdge(new Edge!direction(hither), newState);
	result.start.addEdge(new Edge!(direction, quasi)(makeAllIdentity()), badCrash);

	newState.addEdge(new Edge!(direction, reverse)(thither), goodCrash);
	newState.addEdge(new Edge!(direction, quasi)(makeAllIdentity()), badCrash);

	return result;
}