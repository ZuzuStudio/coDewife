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

