module terms.common;

import std.traits;

unittest
{
	assert(!isOutputTerm!int);
}

template isOutputTerm(T)
{
	enum bool isOutputTerm = is(T:OutputTerm);
}

interface OutputTerm
{
	string outputCharSequence()@property;
}

