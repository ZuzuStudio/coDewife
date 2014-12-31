module terms.commonunderscore;

public import terms.common;

unittest
{
	assert(isOutputTerm!CommonUnderscore);
}

final class CommonUnderscore: OutputTerm
{
public:
	static bool printable;
	
	unittest
	{
		auto cu = new CommonUnderscore;
		CommonUnderscore.printable = true;
		assert("_" == cu.charSequence);
		CommonUnderscore.printable = false;
		assert("" == cu.charSequence);
	}
	
	string charSequence()@property
	{
		return printable ? "_" : "";
	}
}



