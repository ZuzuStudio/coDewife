module terms.logicalunderscore;

public import terms.common;

unittest
{
	assert(isOutputTerm!LogicalUnderscore);
}

final class LogicalUnderscore: OutputTerm
{
public:
	static bool printable;
	
	unittest
	{
		auto lu = new LogicalUnderscore;
		LogicalUnderscore.printable = true;
		assert("_" == lu.outputCharSequence);
		LogicalUnderscore.printable = false;
		assert("" == lu.outputCharSequence);
	}
	
	string outputCharSequence()@property
	{
		return printable ? "_" : "";
	}
}

