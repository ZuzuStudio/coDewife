module terms.keyword;

import terms.common;

unittest
{
	assert(isOutputTerm!KeyWord);
}

final class KeyWord: OutputTerm
{
public:
	this(string kw_symbol)
	{
		this.kw_symbol = kw_symbol;
	}

	unittest
	{
		auto kw = new KeyWord("'");
		assert(sq.charSequence == "'");
	}

	override string charSequence()@property
	{
		string result;
		result = kw_symbol;
		return result;
	}
	
	debug
	{
		override string id()@property
		{
			return "KW";
		}
	}

private:
	string kw_symbol;
}
 
