module codewife.operator;

import codewife.terms.common;

// TODO BinaryOperator, UnaryOperator, BinaryOperatorPadding, UnaryOperatorPadding

/*
unittest
{
	assert(isOutputTerm!BinaryOperator);
}

final class BinaryOperator: OutputTerm
{
public:
	static bool padding;

	this(string opString)
	{
		this.opString = opString;
	}

	unittest
	{
		auto bo = new BinaryOperator("/=");
		BinaryOperator.padding = true;
		assert(bo.charSequence == " /= ");
		BinaryOperator.padding = false;
		assert(bo.charSequence == "/=");
	}

	override string charSequence()@property
	{
		string result;
		if(padding)
			result = " " ~ opString ~ " ";
		else
			result = opString;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "BO";
		}
	}

private:
	string opString;
}

unittest
{
	assert(isOutputTerm!UnaryOperator);
}

final class UnaryOperator: OutputTerm
{
public:
	static bool padding;

	this(string opString)
	{
		this.opString = opString;
	}

	unittest
	{
		auto uo = new UnaryOperator("&");
		UnaryOperator.padding = true;
		assert(uo.charSequence == " &");
		UnaryOperator.padding = false;
		assert(uo.charSequence == "&");
	}

	override string charSequence()@property
	{
		string result;
		if(padding)
			result = " " ~ opString;
		else
			result = opString;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "UO";
		}
	}

private:
	string opString;
}
*/