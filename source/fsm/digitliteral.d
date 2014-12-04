module fsm.digitliteral;

import terms.userundescore, terms.commonunderscore, terms.logicalunderscore, terms.digit;
import std.algorithm, std.conv, std.utf;

interface Engine
{
	OutputTerm[] parse(ref string text);
}

import std.stdio;

class SimpleReplace: Engine
{
public:
	this(string replace = null)
	{
		this.replace = replace;

		start=new State(false, true);
		auto finish = new State(true, true);

		start.addEdge(new AllOtherEdge(), finish);

		current=start;
	}

	override OutputTerm[] parse(ref string text)
	{
		OutputTerm[] internalModel;
		internalModel~=new InvariantSequence(replace);
		for(size_t i = 0; i < text.length;)
		{
			auto symbol = decode(text, i);
			foreach(edge;current.links)
			{
				if(edge.haveToGo(to!string(symbol)))
				{
					current=edge.target;
					edge.concat(internalModel, to!string(symbol));
					break;
				}
			}
			if(current.terminal)
			{				
				if(current.good)
				{
					text=text[i..$];
				}
				else
					internalModel=null;
				
				current=start;
				return internalModel;
			}
		}
		assert(false);
	}

private:
	State start, current;
	string replace;
}

class DigitLiteral: Engine
{
public:
	this()
	{
		start=new State(false, true);
		auto one=new State(false, true);
		auto two=new State(false, true);
		auto finish = new State(true, true);
		auto crash = new State(true, false);

		start.addEdge(new StringEdge(["1","2","3","4","5","6","7","8","9"]), one);
		start.addEdge(new StringEdge(["0"]),two);
		start.addEdge(new AllOtherEdge(),crash);

		one.addEdge(new StringEdge(["0","1","2","3","4","5","6","7","8","9","_"]), one);
		one.addEdge(new DelemiterEdge([" ", "\t","\n", "," , ".", ";", ":", "[", "]","{","}","(",")","!","?","/","\\","\"","'","&","*","+","-","^"]),finish);
		one.addEdge(new AllOtherEdge(), crash);

		two.addEdge(new DelemiterEdge([" ", "\t","\n", "," , ".", ";", ":", "[", "]","{","}","(",")","!","?","/","\\","\"","'","&","*","+","-","^"]),finish);
		two.addEdge(new AllOtherEdge(), crash);

		current = start;
	}

	override OutputTerm[] parse(ref string text)
	{
		//import std.stdio;
		//writeln("start parse");
		//writeln("parsing text:\n",text);
		OutputTerm[] internalModel;
		//writeln(internalModel);
		for(size_t i = 0; i < text.length;)
		{
			//write("i: ", i);
			auto symbol = decode(text, i);
			//writeln( ", c: ", symbol, ", ni: ", i);
			foreach(edge;current.links)
			{
				if(edge.haveToGo(to!string(symbol)))
				{
					current=edge.target;
					edge.concat(internalModel, to!string(symbol));
					break;
				}
			}
			if(current.terminal)
			{
				/*writeln("TERMINAL");
				writeln(symbol);
				writeln(internalModel);
				writeln("current: ", current, " ", current.good);*/

				if(current.good)
				{
					//writeln("i: ", i, ", pi: ", i - strideBack(text, i));
					i-=strideBack(text, i);
					text=text[i..$];
				}
				else
					internalModel=null;

				current=start;
				return internalModel;
			}
		}
		assert(false);
	}

private:

	State start, current;
}

private class State
{
	this(bool terminal, bool good)
	{
		this.terminal=terminal;
		this.good = good;
	}
	
	void addEdge(Edge edge, State target)
	{
		links~=edge;
		links[$-1].target=target;
	}
	
	bool terminal;
	bool good;
	Edge[] links;
}

private abstract class Edge
{
	bool haveToGo(string key);
	void concat(ref OutputTerm[] passVersion, string symbol);
	State target;
}

private final class StringEdge: Edge
{
	this(string[] keys)
	{
		this.keys=keys;
	}
	
	override bool haveToGo(string key)
	{
		return canFind(keys,key);
	}	
	
	override void concat(ref OutputTerm[] passVersion, string symbol)
	{
		passVersion ~= new InvariantSequence(symbol);
	}
	
	string[] keys;
}

private final class DelemiterEdge: Edge
{
	this(string[] keys)
	{
		this.keys=keys;
	}
	
	override bool haveToGo(string key)
	{
		return canFind(keys,key);
	}	
	
	override void concat(ref OutputTerm[] passVersion, string symbol)
	{
	}
	
	string[] keys;
}

private final class AllOtherEdge: Edge
{
	override bool haveToGo(string key)
	{
		return true;
	}
	
	override void concat(ref OutputTerm[] passVersion, string symbol)
	{
		
	}
}

