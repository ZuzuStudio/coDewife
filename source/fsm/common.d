module fsm.common;

public import terms.common;

interface Engine
{
	bool parse(string text, ref size_t position, ref OutputTerm[] output);
}

enum Direction{forward, backward};
alias forward = Direction.forward;
alias backward = Direction.backward;

package mixin template MixStandartParse(Direction direction = Direction.forward)
{
	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		auto current = start;
		auto internalPosition = position;
		OutputTerm[] internalOutput = [];
		while(!current.terminal)
		{
			for(auto i=0;i < current.links.length && !current.links[i].parse(text, internalPosition, internalOutput, current);++i)
			{
			}
		}
		if(current.quality)
		{
			position = internalPosition;
			static if(direction == Direction.forward)
				output ~= internalOutput;
			else
				output = internalOutput ~ output;
		}
		return current.quality;
	}
}

package interface EdgeInterface
{
	bool parse(string text, ref size_t position, ref OutputTerm[] output, ref State state);
	void addFinish(State finish);
}

package final class Edge(Direction direction):EdgeInterface
{
public:
	this(Engine engine, bool quasi = false)
	{
		this.engine = engine;
		this.quasi = quasi;
	}

	override bool parse(string text, ref size_t position, ref OutputTerm[] output, ref State state)
	{
		assert(engine);
		assert(finish);
		size_t internalPosition = position;
		OutputTerm[] internalOutput = [];
		auto result = engine.parse(text, internalPosition, internalOutput);
		if(result)
			state = finish;
		output ~= [];
		if(result && !quasi)
		{
			position = internalPosition;
			static if(direction == Direction.forward)
				output ~= internalOutput;
			else
				output = internalOutput ~ output;
		}
		return result;
	}

	override void addFinish(State finish)
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

	void addEdge(EdgeInterface edge, State target)
	{
		links~=edge;
		links[$-1].addFinish(target);
	}

package:
	bool terminal;
	bool quality;
	EdgeInterface[] links;
}
