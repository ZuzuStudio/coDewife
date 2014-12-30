module fsm.integralliteral;


import fsm.common;
import terms.userundescore, terms.commonunderscore, terms.logicalunderscore, terms.invariantsequence;
import std.algorithm, std.conv;


/+
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

	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
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

+/