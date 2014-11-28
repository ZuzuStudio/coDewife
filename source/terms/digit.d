module terms.digit;

public import terms.common;

unittest
{
	assert(isOutputTerm!InvariantSequence);
}

class InvariantSequence: OutputTerm
{
public:

	unittest
	{
		auto isq = new InvariantSequence("9");
		assert("9" == isq.outputCharSequence);
	}

	this(string sequence)
	{
		this.sequence = sequence;
	}

	string outputCharSequence()@property
	{
		return sequence;
	}

private:
	string sequence;
}

