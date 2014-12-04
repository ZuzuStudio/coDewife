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
		auto one=new State(false);
		start.links[0].target=one;
		one.addEdge(new StringEdge(["0","1","2","3","4","5","6","7","8","9","_"]));
		one.links[0].target=one;

		start.addEdge(new StringEdge(["0"]));
		auto two=new State(false);
		start.links[1].target=two;

		one.addEdge(new DelemiterEdge([" ", "\t","\n", "," , ".", ";", ":", "[", "]","{","}","(",")","!","?","/","\\","\"","'","&","*","+","-","^"]));
		auto finish = new State(true);
		one.links[1].target=finish;

		two.addEdge(new DelemiterEdge([" ", "\t","\n", "," , ".", ";", ":", "[", "]","{","}","(",")","!","?","/","\\","\"","'","&","*","+","-","^"]));
		two.links[0].target=finish;

		//start.addEdge(new AllOtherEdge());
		//auto three=new State(true);
		//start.links[2].target=three;

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
					edge.concat(passVersion, crashVersion);
					//passVersion ~= new InvariantSequence(to!string(symbol));
					break;
				}
			}
			if(current.terminal)
			{
				internalModel ~= !broken ? passVersion : crashVersion;
				internalModel ~= new InvariantSequence("#");
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
		void concat(ref OutputTerm[] passVersion, ref OutputTerm[] crashVersion);
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
			this.key = key;
			return canFind(keys,key);
		}	

		override void concat(ref OutputTerm[] passVersion, ref OutputTerm[] crashVersion)
		{
			passVersion~=new InvariantSequence(key);
			//crashVersion~=key;
		}

		string[] keys;
		string key;
	}

	final class DelemiterEdge: Edge
	{
		this(string[] keys)
		{
			this.keys=keys;
		}
		
		override bool haveToGo(string key)
		{
			this.key = key;
			return canFind(keys,key);
		}	

		override void concat(ref OutputTerm[] passVersion,ref OutputTerm[] crashVersion)
		{
			passVersion~=new InvariantSequence("@");
			//crashVersion~=key;
		}
		
		string[] keys;
		string key;
	}

	final class AllOtherEdge: Edge
	{
		override bool haveToGo(string key)
		{
			this.key=key;
			return true;
		}

		override void concat(ref OutputTerm[] passVersion, ref OutputTerm[] crashVersion)
		{
			
			//crashVersion~=key;
		}

		string key;
	}


	State start, current;

	OutputTerm[] internalModel;

	OutputTerm[] passVersion;
	OutputTerm[] crashVersion;

}

