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
		while(!current.status)
		{
			for(auto i=0;i < current.links.length && !current.links[i].parse(text, internalPosition, internalOutput, current);++i)
			{
			}
		}
		if(current.status & goodness)
		{
			position = internalPosition;
			glue!direction(output, internalOutput);
		}
		return current.status & goodness;
	}
}

package interface EdgeInterface
{
	bool parse(string text, ref size_t position, ref OutputTerm[] output, ref State state);
	void addFinish(State finish);
}

package enum : ubyte {simple = 0, quasi, reverse};

package final class Edge(Direction direction, ubyte type = simple)
	if(type == simple || type == quasi || type == reverse)
		:EdgeInterface
{
public:
	this(Engine engine)
	{
		this.engine = engine;
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
		static if(type != quasi)
			if(result)
			{
				static if(type == simple)
					position = internalPosition;
				glue!direction(output, internalOutput);
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
}

package enum : ubyte {trivial = 0, bad = 2, good = 3, terminalness = 2, goodness = 1}; 

package final class State
{
public:
	this(ubyte status = trivial)pure
	{
		this.status = status;
	}

	void addEdge(EdgeInterface edge, State target)
	{
		links~=edge;
		links[$-1].addFinish(target);
	}

package:
	immutable ubyte status;
	EdgeInterface[] links;
}

package void glue(Direction direction)(ref OutputTerm[] output, OutputTerm[] tail)
{
	static if(direction == forward)
		output ~= tail;
	else
		output = tail ~ output;
}
