module terms.invariantsequence;

public import terms.common;

unittest
{
	assert(isOutputTerm!InvariantSequence);
}

final class InvariantSequence: OutputTerm
{
public:

	unittest
	{
		auto isq = new InvariantSequence("9");
		assert("9" == isq.charSequence);
	}

	this(string sequence)
	{
		this.sequence = sequence;
	}

	string charSequence()@property
	{
		return sequence;
	}

	debug
	{
		override string id()@property
		{
			return "IS";
		}
	}

private:
	string sequence;
}

unittest
{
	assert(isOutputTerm!Unknown);
}

final class Unknown: OutputTerm
{
public:
	this(string opString)
	{
		this.opString = opString;
	}

	unittest
	{
		auto cl = new Unknown("a");
		assert(cl.charSequence == "a");
		cl = new Unknown(`\t`);
		assert(cl.charSequence == `\t`);
	}

	override string charSequence()@property
	{
		string result;
		result = opString;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "UK";
		}
	}

private:
	string opString;
} 

