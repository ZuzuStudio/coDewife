module terms.underscore;

public import terms.common;

unittest
{
	assert(isOutputTerm!UserUnderscore);
}

final class UserUnderscore: OutputTerm
{
	unittest
	{
		auto uu = new UserUnderscore;
		UserUnderscore.printable = true;
		assert("_" == uu.charSequence);
		UserUnderscore.printable = false;
		assert("" == uu.charSequence);
	}

	mixin MixImplementation!();

	debug
	{
		override string id()@property
		{
			return "UU";
		}
	}
}

unittest
{
	assert(isOutputTerm!CommonUnderscore);
}

final class CommonUnderscore: OutputTerm
{
	unittest
	{
		auto cu = new CommonUnderscore;
		CommonUnderscore.printable = true;
		assert("_" == cu.charSequence);
		CommonUnderscore.printable = false;
		assert("" == cu.charSequence);
	}

	mixin MixImplementation!();

	debug
	{
		override string id()@property
		{
			return "CU";
		}
	}
}

unittest
{
	assert(isOutputTerm!LogicalUnderscore);
}

final class LogicalUnderscore: OutputTerm
{
	unittest
	{
		auto lu = new LogicalUnderscore;
		LogicalUnderscore.printable = true;
		assert("_" == lu.charSequence);
		LogicalUnderscore.printable = false;
		assert("" == lu.charSequence);
	}

	mixin MixImplementation!();

	debug
	{
		override string id()@property
		{
			return "LU";
		}
	}
}

final class LastUnderscore: OutputTerm
{
	unittest
	{
		auto xu = new LastUnderscore;
		LastUnderscore.printable = true;
		assert("_" == xu.charSequence);
		LastUnderscore.printable = false;
		assert("" == xu.charSequence);
	}
	
	mixin MixImplementation!();
	
	debug
	{
		override string id()@property
		{
			return "XU";
		}
	}
}

private mixin template MixImplementation()
{
public:
	static bool printable;

	string charSequence()@property
	{
		return printable ? "_" : "";
	}
}