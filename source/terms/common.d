module terms.common;

import std.traits;

unittest
{
	assert(!isOutputTerm!int);
}

template isOutputTerm(T)
{
	enum bool isOutputTerm = __traits(compiles,{T t; string str = t.outputCharSequence;});
}

