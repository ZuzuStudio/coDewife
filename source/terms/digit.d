module terms.digit;

public import terms.common;

unittest
{
	assert(isOutputTerm!Digit);
	assert(!isOutputTerm!int);
}

struct Digit
{
public:

unittest
{
	auto digit = Digit("9");
	assert("9"==digit.outputCharSequence);
}

	@property string outputCharSequence()
	{
		return sequence;
	}
private:
	string sequence;
}

