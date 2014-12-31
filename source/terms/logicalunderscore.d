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
		assert("_" == lu.charSequence);
		LogicalUnderscore.printable = false;
		assert("" == lu.charSequence);
	}
	
	string charSequence()@property
	{
		return printable ? "_" : "";
	}
}

