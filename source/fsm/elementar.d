module fsm.elementar;

import fsm.common;
import terms.invariantsequence;
import std.conv;

unittest
{
	Engine engine = new SingleIdentity("a");
	size_t position = 0;
	OutputTerm[] output;
	assert(!engine.parse("A", position, output));
	assert(!position);
	assert(!output);
	assert(!engine.parse("Ы", position, output));
	assert(!position);
	assert(!output);
	assert(engine.parse("a", position, output));
	assert(position == 1);
	assert(output);
	assert(output[0].charSequence == "a");
}


final class SingleIdentity: Engine
{
public:
	this(string symbol)
	{
		key = symbol;
	}

	mixin MixSimpleParse!(functor);

private:
	string key;
	bool functor(string symbol){return symbol == this.key;} // чаму не працуе лямбда???
}

unittest
{
	Engine engine = new RangeIdentity("1","9");
	size_t position = 0;
	OutputTerm[] output;
	assert(!engine.parse("0", position, output));
	assert(!position);
	assert(!output);
	assert(!engine.parse("Ы", position, output));
	assert(!position);
	assert(!output);
	assert(engine.parse("3", position, output));
	assert(position == 1);
	assert(output);
	assert(output[0].charSequence == "3");
	position = 0;
	assert(engine.parse("9", position, output));
	assert(position == 1);
	assert(output);
	assert(output[1].charSequence == "9");
	position = 0;
	assert(engine.parse("1", position, output));
	assert(position == 1);
	assert(output);
	assert(output[2].charSequence == "1");
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
	
	mixin MixSimpleParse!(functor);

private:
	string down, up;
	bool functor(string symbol){return this.down <= symbol && symbol <= this.up;}
}

unittest
{
	Engine engine = new AllIdentity();
	size_t position = 0;
	OutputTerm[] output;
	auto text = "12,3FЫ";
	assert(engine.parse(text,position,output));
	assert(position == 1);
	assert(output[0].charSequence == "1");
	assert(engine.parse(text,position,output));
	assert(position == 2);
	assert(output[1].charSequence == "2");
	assert(engine.parse(text,position,output));
	assert(position == 3);
	assert(engine.parse(text,position,output));
	assert(position == 4);
	assert(engine.parse(text,position,output));
	assert(position == 5);
	assert(engine.parse(text,position,output));
	assert(position == 7);
	assert(engine.parse(text,position,output));
	assert(position == 7);
	assert(output.charSequence == text);
}

// MAYBE optimize
final class AllIdentity: Engine
{
public:
	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		if(position >= text.length)
			return true;
		size_t index = position;
		auto symbol = to!string(decode(text, index));
		position = index;
		output ~= new InvariantSequence(symbol);
		return true;
	}
}

private mixin template MixSimpleParse(alias predicate)
{
	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		if(position >= text.length)
			return false;
		size_t index = position;
		auto symbol = to!string(decode(text, index));
		auto result = predicate(symbol);
		if(result)
		{
			position = index;
			output ~= new InvariantSequence(symbol);
		}
		return result;
	}
}