module fsm.common;

public import terms.common;

interface Engine
{
	bool parse(string text, ref size_t position, ref OutputTerm[] output);
}

package mixin template MixStandartParse()
{
	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
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
}

package final class Edge
{
public:
	this(Engine engine, bool quasi = false)
	{
		this.engine = engine;
		this.quasi = quasi;
	}

	bool parse(string text, ref size_t position, ref OutputTerm[] output, ref State state)
	{
		assert(engine);
		assert(finish);
		size_t internalPosition = position;
		OutputTerm[] internalOutput = null;
		auto result = engine.parse(text, internalPosition, internalOutput);
		if(result)
			state = finish;
		if(result && !quasi)
		{
			position = internalPosition;
			output ~= internalOutput;
		}
		return result;
	}

	void addFinish(State finish)
	{
		this.finish = finish;
	}

private:
	State finish;
	Engine engine;
	bool quasi;
}

package final class State
{
public:
	this(bool terminal, bool quality)
	{
		this.terminal=terminal;
		this.quality = quality;
	}

	void addEdge(Edge edge, State target)
	{
		links~=edge;
		links[$-1].addFinish(target);
	}

package:
	bool terminal;
	bool quality;
	Edge[] links;
}
