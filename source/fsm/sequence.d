module fsm.sequence;

import fsm.common;

unittest
{
	import std.traits;
	import fsm.elementar;
	static assert(__traits(compiles, {auto engine = new Sequence(new SingleIdentity("a"), new RangeIdentity("0","9"));}));
	static assert(__traits(compiles, {auto engine = new Sequence("abc");}));
	//auto engine = new Sequence(new SingleIdentity("a"), new RangeIdentity("0","9"));
	auto engine = new Sequence("abc");
	size_t position;
	OutputTerm[] output;
	assert(engine.parse("abc",position,output));
}

final class Sequence: Engine
{
public:
	this(string keyString)
	{
		//TODO
	}

	this(Engine[] list...)
	{
		//TODO
	}

	bool parse(string text, ref size_t position, ref OutputTerm[] output)
	{
		//TODO
		return false;
	}
}
