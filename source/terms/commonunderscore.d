module terms.commonunderscore;

public import terms.common;

unittest
{
	assert(isOutputTerm!CommonUnderscore);
}

class CommonUnderscore: OutputTerm
{
public:
	static bool printable;
	
	unittest
	{
		auto cu = new CommonUnderscore;
		CommonUnderscore.printable = true;
		assert("_" == cu.outputCharSequence);
		CommonUnderscore.printable = false;
		assert("" == cu.outputCharSequence);
	}
	
	string outputCharSequence()@property
	{
		return printable ? "_" : "";
	}
}



