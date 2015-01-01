module fsm.parallel;

import std.conv;
import fsm.common;
import fsm.elementar;

unittest
{
	import std.traits;
	import fsm.sequence;

	static assert(__traits(compiles, {auto engine = new Parallel(new SingleIdentity("a"), new RangeIdentity("0","9"));}));
	
	auto engine = new Parallel(new SingleIdentity("a"), new RangeIdentity("0","9"));
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

	engine = new Parallel(new Sequence("zuzu"), new Sequence(new RangeIdentity("0", "5"), new Sequence("_item")));
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

final class Parallel: Engine
{
public:
	this(Engine[] list...)
	{
		this(list);
	}

	this(Engine[] list)
	{
		enum terminal = true;
		enum nonterminal = false;
		enum good = true;
		enum bad = false;
		enum quasi = true;
		
		auto goodCrash = new State(terminal, good);
		auto badCrash = new State(terminal, bad);
		
		start = new State(nonterminal, good);
		auto goodState = new State(nonterminal, good);
		goodState.addEdge(new Edge(new AllIdentity(), quasi), goodCrash);
		foreach(engine; list)
		{
			start.addEdge(new Edge(engine), goodState);
		}
		start.addEdge(new Edge(new AllIdentity(), quasi), badCrash);
	}

	mixin MixStandartParse!();

private:
	State start;
} 
