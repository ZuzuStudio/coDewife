module terms.charliteral;

import terms.common;

unittest
{
	assert(isOutputTerm!BinaryOperator);
}

final class SingleQuote: OutputTerm
{
public:
	this(string opString)
	{
		this.opString = opString;
	}

	unittest
	{
		auto sq = new SingleQuote("'");
		assert(sq.charSequence == "'");
	}

	override string charSequence()@property
	{
		string result;
		result = opString;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "SQ";
		}
	}

private:
	string opString;
}

unittest
{
	assert(isOutputTerm!CharLiteral);
}

final class CharLiteral: OutputTerm
{
public:
	this(string opString)
	{
		this.opString = opString;
	}

	unittest
	{
		auto cl = new CharLiteral("a");
		assert(cl.charSequence == "a");
		cl = new CharLiteral(`\t`);
		assert(cl.charSequence == `\t`);
	}

	override string charSequence()@property
	{
		string result;
		result = opString;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "CL";
		}
	}

private:
	string opString;
} 

final class Unknown: OutputTerm
{
public:
	this(string opString)
	{
		this.opString = opString;
	}

	unittest
	{
		auto cl = new Unknown("a");
		assert(cl.charSequence == "a");
		cl = new Unknown(`\t`);
		assert(cl.charSequence == `\t`);
	}

	override string charSequence()@property
	{
		string result;
		result = opString;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "UK";
		}
	}

private:
	string opString;
} 
