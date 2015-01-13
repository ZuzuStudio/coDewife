module operator;

import terms.common;

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