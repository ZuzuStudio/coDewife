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

	static assert(__traits(compiles, {auto engine = makeSequence(new SingleIdentity("a"), new RangeIdentity("0","9"));}));
	static assert(__traits(compiles, {auto engine = makeSequence("abc");}));
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
	assert(output is []);
	position = 0;
	output = [];
	assert(!engine.parse("acb",position,output));
	assert(position == 0);
	assert(output is []);
	position = 0;
	output = [];
	assert(!engine.parse("acb",position,output));
	assert(position == 0);
	assert(output is []);
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

	engine = makeSequence(new SingleIdentity("a"), new RangeIdentity("0","9"));
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
	assert(output is []);
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
	assert(output is []);
}

Engine makeSequence(Direction direction = Direction.forward)(string keyString)
{
	Engine[] list;
	foreach(dchar symbol; keyString)
		list ~= new SingleIdentity(to!string(symbol));
	return makeSequence!direction(list);
}

Engine makeSequence(Direction direction = Direction.forward)(Engine[] list...)
{
	return makeSequence!direction(list);
}

Engine makeSequence(Direction direction = Direction.forward)(Engine[] list)
{
	enum terminal = true;
	enum nonterminal = false;
	enum good = true;
	enum bad = false;
	enum quasi = true;
	auto result = new Configurator!direction;
	result.start = new State(nonterminal, good);
	auto goodCrash = new State(terminal, good);
	auto badCrash = new State(terminal, bad);
	State current = result.start;
	foreach(engine; list)
	{
		auto newState = new State(nonterminal, good);
		current.addEdge(new Edge(engine), newState);
		current.addEdge(new Edge(new AllIdentity(), quasi), badCrash);
		current = newState;
	}
	current.addEdge(new Edge(new AllIdentity(), quasi), goodCrash);
	return result;
}

unittest
{
	import std.traits;

	static assert(__traits(compiles, {auto engine = makeParallel(new SingleIdentity("a"), new RangeIdentity("0","9"));}));
	
	auto engine = makeParallel(new SingleIdentity("a"), new RangeIdentity("0","9"));
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
	assert(output is []);
	position = 0;
	output = [];
	assert(engine.parse("3712",position,output));
	assert(position == 1);
	assert(output.charSequence == "3");
	position = 0;
	output = [];

	engine = makeParallel(makeSequence("zuzu"), makeSequence(new RangeIdentity("0", "5"), makeSequence("_item")));
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
}

Engine makeParallel(Direction direction = Direction.forward)(Engine[] list...)
{
	return makeParallel!direction(list);
}

Engine makeParallel(Direction direction = Direction.forward)(Engine[] list)
{
	enum terminal = true;
	enum nonterminal = false;
	enum good = true;
	enum bad = false;
	enum quasi = true;
	auto result = new Configurator!direction;
	result.start = new State(nonterminal, good);
	auto goodCrash = new State(terminal, good);
	auto badCrash = new State(terminal, bad);
	State current = result.start;
	auto goodState = new State(nonterminal, good);
	goodState.addEdge(new Edge(new AllIdentity(), quasi), goodCrash);
	foreach(engine; list)
	{
		current.addEdge(new Edge(engine), goodState);
	}
	current.addEdge(new Edge(new AllIdentity(), quasi), badCrash);
	return result;
}

unittest
{
	import std.traits;
	
	static assert(__traits(compiles, {auto engine = makeCliniAsterisc(new SingleIdentity("a"));}));

	auto engine = makeCliniAsterisc(new SingleIdentity("a"));

	size_t position;
	OutputTerm[] output = [];
	assert(engine.parse("",position, output));
	assert(position == 0);
	import std.stdio;
	writeln(typeid(output));
	assert(output is []);

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
	assert(output is []);
}

Engine makeCliniAsterisc(Direction direction = Direction.forward)(Engine engine)
{
	enum terminal = true;
	enum nonterminal = false;
	enum good = true;
	enum bad = false;
	enum quasi = true;
	auto result = new Configurator!direction;
	result.start = new State(nonterminal, good);
	auto goodCrash = new State(terminal, good);
	auto newState = new State(nonterminal, good);
	result.start.addEdge(new Edge(engine), newState);
	result.start.addEdge(new Edge(new AllIdentity, quasi), goodCrash);
	newState.addEdge(new Edge(engine), newState);
	newState.addEdge(new Edge(new AllIdentity, quasi), goodCrash);
	return result;
}