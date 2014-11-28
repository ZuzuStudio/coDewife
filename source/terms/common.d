module terms.common;

import std.traits;

template isOutputTerm(T)
{
	enum bool isOutputTerm = __traits(compiles,{T t; string str = t.outputCharSequence;});
}

