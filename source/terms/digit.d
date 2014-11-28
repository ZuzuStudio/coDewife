module terms.digit;

public import terms.common;

unittest
{
	assert(isOutputTerm!Digit);
}

// гэта пэўна не лічба а ўвогуле паслядоўнасць сімвалаў як ёсць
struct Digit
{
public:

unittest
{
	auto digit = Digit("9");
	assert("9"==digit.outputCharSequence);
}

	string outputCharSequence()@property
	{
		return sequence;
	}
private:
	string sequence;
}

