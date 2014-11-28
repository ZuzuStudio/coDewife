module terms.userundescore;

public import terms.common;

unittest
{
	assert(isOutputTerm!UserUnderscore);
}

struct UserUnderscore
{
public:
	static bool printable;

	unittest
	{
		UserUnderscore uu;
		UserUnderscore.printable = true;
		assert("_" == uu.outputCharSequence);
		UserUnderscore.printable = false;
		assert("" == uu.outputCharSequence);
	}

	string outputCharSequence()@property
	{
		return printable?"_":"";
	}
}