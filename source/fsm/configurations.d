module fsm.sequence;

import std.conv;
import fsm.common;
import fsm.elementar;

final class Configurator: Engine
{
public:
	mixin MixStandartParse!();
	
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
	OutputTerm[] output;
	assert(engine.parse("abc",position,output));
	assert(position == 3);
	assert(output[1].charSequence == "b");
	assert(output.charSequence == "abc");
	position = 0;
	output = null;
	assert(!engine.parse("ab",position,output));
	assert(position == 0);
	assert(output is null);
	position = 0;
	output = null;
	assert(!engine.parse("acb",position,output));
	assert(position == 0);
	assert(output is null);
	position = 0;
	output = null;
	assert(!engine.parse("acb",position,output));
	assert(position == 0);
	assert(output is null);
	position = 0;
	output = null;
	assert(engine.parse("abcdef",position,output));
	assert(position == 3);
	assert(output.charSequence == "abc");
	position = 0;
	output = null;
	assert(engine.parse("abcabc",position,output));
	assert(position == 3);
	assert(output.charSequence == "abc");

	engine = makeSequence(new SingleIdentity("a"), new RangeIdentity("0","9"));
	position = 0;
	output = null;
	assert(engine.parse("a3",position,output));
	assert(position == 2);
	assert(output.charSequence == "a3");
	position = 0;
	output = null;
	assert(engine.parse("a9",position,output));
	assert(position == 2);
	assert(output.charSequence == "a9");
	position = 0;
	output = null;
	assert(!engine.parse("3a",position,output));
	assert(position == 0);
	assert(output is null);
	position = 0;
	output = null;
	assert(engine.parse("a3a5",position,output));
	assert(position == 2);
	assert(output.charSequence == "a3");
	position = 0;
	output = null;
	assert(engine.parse("a334",position,output));
	assert(position == 2);
	assert(output.charSequence == "a3");
	position = 0;
	output = null;
	assert(!engine.parse("a",position,output));
	assert(position == 0);
	assert(output is null);
}

Configurator makeSequence(string keyString)
{
	Engine[] list;
	foreach(dchar symbol; keyString)
		list ~= new SingleIdentity(to!string(symbol));
	return makeSequence(list);
}

auto makeSequence(Engine[] list...)
{
	return makeSequence(list);
}

auto makeSequence(Engine[] list)
{
	enum terminal = true;
	enum nonterminal = false;
	enum good = true;
	enum bad = false;
	enum quasi = true;
	auto result = new Configurator();
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
	output = null;
	assert(engine.parse("a3",position,output));
	assert(position == 1);
	assert(output.charSequence == "a");
	position = 0;
	output = null;
	assert(engine.parse("9a",position,output));
	assert(position == 1);
	assert(output.charSequence == "9");
	position = 0;
	output = null;
	assert(!engine.parse("bac",position,output));
	assert(position == 0);
	assert(output is null);
	position = 0;
	output = null;
	assert(engine.parse("3712",position,output));
	assert(position == 1);
	assert(output.charSequence == "3");
	position = 0;
	output = null;

	engine = makeParallel(makeSequence("zuzu"), makeSequence(new RangeIdentity("0", "5"), makeSequence("_item")));
	position = 0;
	output = null;
	assert(engine.parse("zuzu27",position,output));
	assert(position == 4);
	assert(output.charSequence == "zuzu");
	position = 0;
	output = null;
	assert(engine.parse("2_items",position,output));
	assert(position == 6);
	assert(output.charSequence == "2_item");
	position = 0;
	output = null;
	assert(!engine.parse("uzuzu",position,output));
	assert(position == 0);
	assert(output.charSequence == null);
}

Configurator makeParallel(Engine[] list...)
{
	return makeParallel(list);
}

auto makeParallel(Engine[] list)
{
	enum terminal = true;
	enum nonterminal = false;
	enum good = true;
	enum bad = false;
	enum quasi = true;
	auto result = new Configurator();
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
	OutputTerm[] output;
	assert(engine.parse("",position, output));
	assert(position == 0);
	assert(output.length == 0);// assert(output is null) fails :(

	position = 0;
	output = null;
	assert(engine.parse("a", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");

	position = 0;
	output = null;
	assert(engine.parse("aa", position, output));
	assert(position == 2);
	assert(output.charSequence == "aa");

	position = 0;
	output = null;
	assert(engine.parse("aaa", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");

	position = 0;
	output = null;
	assert(engine.parse("aaa0", position, output));
	assert(position == 3);
	assert(output.charSequence == "aaa");

	position = 0;
	output = null;
	assert(engine.parse("aaaabaa", position, output));
	assert(position == 4);
	assert(output.charSequence == "aaaa");

	position = 0;
	output = null;
	assert(engine.parse("aaaaaaa", position, output));
	assert(position == 7);
	assert(output.charSequence == "aaaaaaa");

	position = 0;
	output = null;
	assert(engine.parse("baaaaaaa", position, output));
	assert(position == 0);
	assert(output.charSequence == "");
}

auto makeCliniAsterisc(Engine engine)
{
	enum terminal = true;
	enum nonterminal = false;
	enum good = true;
	enum bad = false;
	enum quasi = true;
	auto result = new Configurator;
	result.start = new State(nonterminal, good);
	auto goodCrash = new State(terminal, good);
	auto newState = new State(nonterminal, good);
	result.start.addEdge(new Edge(engine), newState);
	result.start.addEdge(new Edge(new AllIdentity, quasi), goodCrash);
	newState.addEdge(new Edge(engine), newState);
	newState.addEdge(new Edge(new AllIdentity, quasi), goodCrash);
	return result;
}