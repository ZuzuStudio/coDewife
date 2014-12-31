module terms.userundescore;

public import terms.common;

unittest
{
	assert(isOutputTerm!UserUnderscore);
}

final class UserUnderscore: OutputTerm
{
public:
	static bool printable;

	unittest
	{
		auto uu = new UserUnderscore;
		UserUnderscore.printable = true;
		assert("_" == uu.charSequence);
		UserUnderscore.printable = false;
		assert("" == uu.charSequence);
	}

	string charSequence()@property
	{
		return printable ? "_" : "";
	}
}