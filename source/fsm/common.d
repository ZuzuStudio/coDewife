module fsm.common;

public import terms.common;

interface Engine
{
	bool parse(string text, ref size_t position, ref OutputTerm[] output);
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
		if(result && !quasi)
		{
			state = finish;
			position = internalPosition;
			output ~= internalOutput;pupublic:
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
	this(bool terminal, bool good)
	{
		this.terminal=terminal;
		this.good = good;
	}

	void addEdge(Edge edge, State target)
	{
		links~=edge;
		links[$-1].addFinish(target);
	}

package:
	bool terminal;
	bool good;
	Edge[] links;
}
