module fsm.elementar;

import fsm.common;
import terms.invariantsequence;
import std.conv;

final class SingleIdentity: Engine
{
public:
	this(string symbol)
	{
		key = symbol;
	}

	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		if(position>=text.length)
			return false;
		size_t index = position;
		auto symbol = to!string(decode(text, index));
		auto result = symbol == key;
		if(result)
		{
			position = index;
			output ~= InvariantSequence(symbol);
		}
		return result;
	}

private:
	string key;
}

final class RangeIdentity: Engine
{
public:
	this(string down, string up)
	{
		assert(down<=up);
		this.down = down;
		this.up = up;
	}
	
	mixin MixSimpleParse!((string symbol) => down<=symbol && symbol <= up);

private:
	string down, up;
}

private mixin template MixSimpleParse(alias predicate)
{
	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		if(position>=text.length)
			return false;
		size_t index = position;
		auto symbol = to!string(decode(text, index));
		auto result = predicate(symbol);
		if(result)
		{
			position = index;
			output ~= InvariantSequence(symbol);
		}
		return result;
	}
}

final class AllIdentity: Engine
{

}
