module fsm.elementar;

import fsm.common;
import terms.invariantsequence;
import std.conv;

final class Elementar(Direction direction): Engine
{
public:
	bool key; // !!! IT SHOULD BE REMOVED

	this(bool delegate(string) predicate , OutputTerm[] delegate(string) mapping)
	{
		this.predicate = predicate;
		this.mapping = mapping;

		key = false; // !!! IT SHOULD BE REMOVED
	}
	
	override bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		if (!key) // !!! IT SHOULD BE REMOVED
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
		} else                                                    // !!! IT SHOULD BE REMOVED
		{
			if(position >= text.length)                           //
				return true;                                      //
			size_t index = position;                              //
			auto symbol = to!string(decode(text, index));         //
			position = index;                                     //
			output ~= new InvariantSequence(symbol);              //
			return true;
		}
	}
	
private:
	bool delegate(string) predicate;
	OutputTerm[] delegate(string) mapping;
}

unittest
{
	auto machine = makeSingleIdentity("k");
	OutputTerm[] output;
	size_t position = 0;
	assert(machine.parse("kk", position, output));
	assert(position == 1);
	assert(output.charSequence == "k");

	assert(machine.parse("kk", position, output));
	assert(position == 2);
	assert(output.charSequence == "kk");

	assert(!machine.parse("kk", position, output));
	assert(position == 2);
	assert(output.charSequence == "kk");
	position = 0;
	output = null;

	assert(!machine.parse("break", position, output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = null;
}

Engine makeSingleIdentity(Direction direction = Direction.forward)(string symbol)
{
	return new Elementar!direction(delegate (string s) => s == symbol,
	                               delegate (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
}

unittest
{
	Engine machine = makeRangeIdentity("a", "g");
	OutputTerm[] output;
	size_t position = 0;
	assert(machine.parse("again", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");
	
	assert(machine.parse("again", position, output));
	assert(position == 2);
	assert(output.charSequence == "ag");
	
	assert(machine.parse("again", position, output));
	assert(position == 3);
	assert(output.charSequence == "aga");

	assert(!machine.parse("again", position, output));
	assert(position == 3);
	assert(output.charSequence == "aga");
	position = 0;
	output = null;
	
	assert(machine.parse("ace", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");

	assert(machine.parse("ace", position, output));
	assert(position == 2);
	assert(output.charSequence == "ac");

	assert(machine.parse("ace", position, output));
	assert(position == 3);
	assert(output.charSequence == "ace");

	assert(!machine.parse("ace", position, output));
	assert(position == 3);
	assert(output.charSequence == "ace");
	position = 0;
	output = null;

	assert(!machine.parse("x-mas", position, output));
	assert(position == 0);
	assert(output == []);
	position = 0;
	output = null;

	machine = makeRangeIdentity("а", "р");
	assert(machine.parse("архив", position, output));
	assert(position == 2); 
	assert(output.charSequence == "а");

	assert(machine.parse("архив", position, output));
	assert(position == 4); 
	assert(output.charSequence == "ар");

	assert(!machine.parse("архив", position, output));
	assert(position == 4); 
	assert(output.charSequence == "ар");
}

Engine makeRangeIdentity(Direction direction = Direction.forward)(string down, string up)
{
	return new Elementar!direction(delegate (string s) => down <= s && s <= up,
	                               delegate (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
}

unittest
{
	auto machine = makeAllIdentity();
	OutputTerm[] output;
	size_t position = 0;
	assert(machine.parse("age", position, output));
	assert(position == 1);
	assert(output.charSequence == "a");
	
	assert(machine.parse("age", position, output));
	assert(position == 2);
	assert(output.charSequence == "ag");
	
	assert(machine.parse("age", position, output));
	assert(position == 3);
	assert(output.charSequence == "age");
	
	assert(machine.parse("age", position, output)); // assert(!machine.parse("age", position, output));
	assert(position == 3);
	assert(output.charSequence == "age");
	position = 0;
	output = null;
	
	assert(machine.parse("zag", position, output));
	assert(position == 1);
	assert(output.charSequence == "z");
	position = 0;
	output = null;

	/+
	position = 3;
	machine = makeAllIdentity!(Direction.backward)();
	assert(machine.parse("reverse", position, output));
	assert(position == 2); 
	assert(output.charSequence == "v");
	
	assert(machine.parse("reverse", position, output));
	assert(position == 1); 
	assert(output.charSequence == "ev");
	
	assert(machine.parse("reverse", position, output));
	assert(position == 0); 
	assert(output.charSequence == "rev");

	assert(machine.parse("reverse", position, output)); // assert(!machine.parse("reverse", position, output));
	assert(position == 0); 
	assert(output.charSequence == "rev");
	+/
}

Engine makeAllIdentity(Direction direction = Direction.forward)()
{
	auto obj = new Elementar!direction(delegate (string s) => true, delegate (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));

	obj.key = true;
	return obj;
}

unittest
{
	import terms.underscore, terms.invariantsequence;
	auto engine = makeGeneral!(Direction.forward)((string s) => s == "_", (string s) => cast(OutputTerm[])[] ~ new UserUnderscore);

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


	engine = makeGeneral!(Direction.forward)((string s) => "А" <= s && s <= "Я", /+ both char is cyrillic +/
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

unittest
{
	import terms.underscore, terms.invariantsequence;
	auto engine = makeGeneral!(Direction.backward)((string s) => "0" <= s && s <= "9", (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s) ~ new LogicalUnderscore);
	
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
	
	engine = makeGeneral!(Direction.backward)((string s) => true,
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

Engine makeGeneral(Direction direction = Direction.forward)
                  (bool delegate(string) predicate , OutputTerm[] delegate(string) mapping)
{
	return new Elementar!direction(predicate, mapping);
}