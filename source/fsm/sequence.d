module fsm.sequence;

import std.conv;
import fsm.common;
import fsm.elementar;

unittest
{
	import std.traits;

	static assert(__traits(compiles, {auto engine = new Sequence(new SingleIdentity("a"), new RangeIdentity("0","9"));}));
	static assert(__traits(compiles, {auto engine = new Sequence("abc");}));
	auto engine = new Sequence("abc");
	size_t position;
	OutputTerm[] output;
	assert(engine.parse("abc",position,output));
	//TODO
	engine = new Sequence(new SingleIdentity("a"), new RangeIdentity("0","9"));
}

final class Sequence: Engine
{
public:
	this(string keyString)
	{
		Engine[] list;
		foreach(dchar symbol; keyString)
			list ~= new SingleIdentity(to!string(symbol));
		this(list);
	}

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
		start = new State(nonterminal, good);
		auto goodCrash = new State(terminal, good);
		auto badCrash = new State(terminal, bad);
		State current = start;
		foreach(engine; list)
		{
			auto newState = new State(nonterminal, good);
			current.addEdge(new Edge(engine), newState);
			current.addEdge(new Edge(new EndOfText(), quasi), badCrash);
			current.addEdge(new Edge(new AllIdentity(), quasi), badCrash);
			current = newState;
		}
		current.addEdge(new Edge(new EndOfText(), quasi), goodCrash);
		current.addEdge(new Edge(new AllIdentity(), quasi), goodCrash);
	}

	bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		auto current = start;
		auto internalPosition = position;
		OutputTerm[] internalOutput;
		while(!current.terminal)
		{
			for(auto i=0;i < current.links.length && !current.links[i].parse(text, internalPosition, internalOutput, current);++i)
			{
			}
		}
		if(current.quality)
		{
			position = internalPosition;
			output ~= internalOutput;
		}
		return current.quality;
	}

private:
	State start;
}
