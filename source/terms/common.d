module terms.common;

import std.traits;
public import std.utf;

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
	string charSequence()@property;

	debug
	{
		string id()@property;
	}
}

string charSequence(OutputTerm[] terms)
{
		typeof(return) result;
		foreach(term; terms)
			result ~= term.charSequence;
		return result;
}