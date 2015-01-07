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

unittest
{
	import terms.underscore, terms.invariantsequence;
	auto engine = new General((string s) => s == "_", (string s) => cast(OutputTerm[])[] ~ new UserUnderscore);

	size_t position;
	OutputTerm[] output = [];
	assert(engine.parse("_", position, output));
	assert(position == 1);
	UserUnderscore.printable = true;
	assert(output.charSequence == "_");
	UserUnderscore.printable = false;
	assert(output.charSequence == "");

	position = 0;
	output = [];
	assert(!engine.parse("-", position, output));
	assert(position == 0);
	assert(output == []);


	engine = new General((string s) => "А" <= s && s <= "Я", /+ both char is cyrillic +/
	                     (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s) ~ new InvariantSequence(s));
	position = 0;
	output = [];
	assert(engine.parse("ЯНЫ", position, output));
	assert(position == 2);
	assert(output.charSequence == "ЯЯ");
	assert(engine.parse("ЯНЫ", position, output));
	assert(position == 4);
	assert(output.charSequence == "ЯЯНН");
	assert(!engine.parse("ЯНы", position, output));
	assert(position == 4);
	assert(output.charSequence == "ЯЯНН");
	assert(engine.parse("ЯНЫ", position, output));
	assert(position == 6);
	assert(output.charSequence == "ЯЯННЫЫ");
	assert(!engine.parse("ЯНЫ", position, output));
	assert(position == 6);
	assert(output.charSequence == "ЯЯННЫЫ");
}

alias General = GeneralImplementation!(Direction.forward);

unittest
{
	import terms.underscore, terms.invariantsequence;
	auto engine = new GeneralBackward((string s) => "0" <= s && s <= "9", (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s) ~ new LogicalUnderscore);
	
	size_t position = 4;
	OutputTerm[] output = [];
	assert(engine.parse("1234", position, output));
	assert(engine.parse("1234", position, output));
	assert(engine.parse("1234", position, output));
	assert(position == 1);
	LogicalUnderscore.printable = true;
	assert(output.charSequence == "2_3_4_");
	LogicalUnderscore.printable = false;
	assert(output.charSequence == "234");

	assert(engine.parse("1234", position, output));
	assert(position == 0);
	assert(output.charSequence == "1234");

	assert(!engine.parse("1234", position, output));
	assert(position == 0);
	assert(output.charSequence == "1234");
	
	position = 1;
	output = [];
	assert(!engine.parse("-", position, output));
	assert(position == 1);
	assert(output == []);

	position = 0;
	output = [];
	assert(!engine.parse("12", position, output));
	assert(position == 0);
	assert(output == []);

	engine = new GeneralBackward((string s) => true,
	                            (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(to!string(cast(dchar)(decodeFront(s)+1))));
	position = 0;
	output = [];
	assert(!engine.parse("Я", position, output));
	assert(position == 0);
	assert(output == []);

	position = 3;
	assert(engine.parse("1Э", position, output));
	assert(position == 1);
	assert(engine.parse("1Э", position, output));
	assert(position == 0);
	assert(output.charSequence == "2Ю");
}

alias GeneralBackward = GeneralImplementation!(Direction.backward);

final class GeneralImplementation(Direction direction): Engine
{
public:
	this(bool delegate(string) predicate , OutputTerm[] delegate(string) mapping)
	{
		this.predicate = predicate;
		this.mapping = mapping;
	}

	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		size_t index = position;
		static if(direction == Direction.backward)
		{
			if(index <= 0)
				return false;
			index -= strideBack(text, index);
		}
		else
		{
			if(index >= text.length)
				return false;
		}

		auto symbol = to!string(decode(text, index));
		static if(direction == Direction.backward)
			index -= strideBack(text, index);
		auto result = predicate(symbol);
		if(result)
		{
			position = index;
			static if(direction == Direction.forward)
				output ~= mapping(symbol);
			else
				output = mapping(symbol) ~ output;
		}
		return result;
	}

private:
	bool delegate(string) predicate;
	OutputTerm[] delegate(string) mapping;
}