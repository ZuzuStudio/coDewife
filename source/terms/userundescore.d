module terms.userundescore;

public import terms.common;

unittest
{
	assert(isOutputTerm!UserUnderscore);
}

class UserUnderscore: OutputTerm
{
public:
	static bool printable;

	unittest
	{
		auto uu = new UserUnderscore;
		UserUnderscore.printable = true;
		assert("_" == uu.outputCharSequence);
		UserUnderscore.printable = false;
		assert("" == uu.outputCharSequence);
	}

	string outputCharSequence()@property
	{
		return printable ? "_" : "";
	}
}