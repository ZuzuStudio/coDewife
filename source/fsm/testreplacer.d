module testreplacer.d;

/*class SimpleReplace: Engine
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

	bool override parse(string text, ref size_t position, ref OutputTerm[] output)
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
}*/
