module fsm.digitliteral;

import terms.userundescore, terms.commonunderscore, terms.logicalunderscore, terms.digit;
import std.algorithm, std.conv;

struct DigitLiteral
{
public:
	this(int unused)
	{
		start=new State(false);
		start.addEdge(new StringEdge(["1","2","3","4","5","6","7","8","9"]));
		auto one=new State(true);
		start.links[0].target=one;
		one.addEdge(new StringEdge(["0","1","2","3","4","5","6","7","8","9","_"]));
		one.links[0].target=one;

		start.addEdge(new StringEdge(["0"]));
		auto two=new State(true);
		start.links[1].target=two;

		start.addEdge(new AllOtherEdge());
		auto three=new State(true);
		start.links[2].target=three;

		current = start;
	}

	void parse(string text)
	{
		foreach(dchar symbol;text)
		{
			bool broken=true;
			foreach(edge;current.links)
			{
				if(edge.haveToGo(to!string(symbol)))
				{
					current=edge.target;
					broken=false;
					passVersion ~= new InvariantSequence(to!string(symbol));
					break;
				}
			}
			if(broken)
			{
				internalModel ~= current.terminal ? passVersion : crashVersion;
				passVersion=null;
				crashVersion=null;
				current=start;
			}
		}
	}

	OutputTerm[] getInternalModel()
	{
		return internalModel;
	}

private:


	class State
	{
		this(bool terminal)
		{
			this.terminal=terminal;
		}

		void addEdge(Edge edge)
		{
			links~=edge;
		}

		bool terminal;
		Edge[] links;
	}

	abstract class Edge
	{
		bool haveToGo(string key);
		State target;
	}

	final class StringEdge: Edge
	{
		this(string[] keys)
		{
			this.keys=keys;
		}

		override bool haveToGo(string key)
		{
			return canFind(keys,key);
		}	

		string[] keys;
	}

	final class AllOtherEdge: Edge
	{
		override bool haveToGo(string key)
		{
			return true;
		}
	}


	State start, current;

	OutputTerm[] internalModel;

	OutputTerm[] passVersion;
	OutputTerm[] crashVersion;

}

