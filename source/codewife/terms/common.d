module codewife.terms.common;

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

unittest
{
	assert(charSequence(makeInvariantTerm("jack") ~ makeInvariantTerm("_6.3")) == "jack_6.3");
}

string charSequence(OutputTerm[] terms)
{
		typeof(return) result;
		foreach(term; terms)
			result ~= term.charSequence;
		return result;
}

final class TermMonostate(string term_id) : OutputTerm
{
private:
	string payload;
	
public:	
	string charSequence() @property
	{
		return payload;
	}
	
	debug
	{
		override string id()@property
		{
			return term_id;
		}
	}
}

final class TermBistate(string term_id) : OutputTerm
{
private:
	string deactive;
	string active;

public:
	static bool activated;
	
	string charSequence() @property
	{
		return activated? active: deactive;
	}
	
	debug
	{
		override string id()@property
		{
			return term_id;
		}
	}
}

OutputTerm[] makeEmpty()
{
	return cast(OutputTerm[])[];
}

// =======> Invariant Terms

// IS

unittest
{
	static assert(__traits(compiles, {auto engine = makeInvariantTerm("a");}));
	
	auto term = makeInvariantTerm("D");
	assert(term.charSequence == "D");

	debug
	{
		assert(term[0].id == "IS");
	}
}

OutputTerm[] makeInvariantTerm(string type = "IS")(string s)
{
	auto result = new TermMonostate!(type);
	result.payload = s;
	return makeEmpty() ~ result;
}

// =======> Underscore Terms

unittest
{
	static assert(__traits(compiles, {auto term = makeUnderscoreTerm!"UU"();}));
	static assert(__traits(compiles, {auto term = makeUnderscoreTerm!"XU"();}));
	static assert(__traits(compiles, {auto term = makeUnderscoreTerm!"LU"();}));
	static assert(__traits(compiles, {auto term = makeUnderscoreTerm!"CU"();}));
	static assert(!__traits(compiles, {auto term = makeUnderscoreTerm!"uU"();}));
	OutputTerm[] sequence = [];
	sequence ~= makeUnderscoreTerm!"UU"();
	sequence ~= makeInvariantTerm(":");
	sequence ~= makeUnderscoreTerm!"XU"();
	sequence ~= makeInvariantTerm(":");
	sequence ~= makeUnderscoreTerm!"LU"();
	sequence ~= makeInvariantTerm(":");
	sequence ~= makeUnderscoreTerm!"CU"();

	disableUnderscore();
	assert(sequence.charSequence == ":::");

	keepUserUnderscore();
	assert(sequence.charSequence == "_:::_");

	keepAllUserUnderscore();
	assert(sequence.charSequence == "_:_::_");

	bytifyUnderscore();
	assert(sequence.charSequence == "::_:_");
}

OutputTerm[] makeUnderscoreTerm(string variant)()
	if(variant == "UU" || variant == "XU" || variant == "LU" || variant == "CU")
{
	auto result = new TermBistate!variant;
	result.deactive = "";
	result.active = "_";
	return makeEmpty() ~ result;
}

void disableUnderscore()
{
	TermBistate!("UU").activated = false;
	TermBistate!("XU").activated = false;
	TermBistate!("LU").activated = false;
	TermBistate!("CU").activated = false;
}

void keepUserUnderscore()
{
	TermBistate!("UU").activated = true;
	TermBistate!("XU").activated = false;
	TermBistate!("LU").activated = false;
	TermBistate!("CU").activated = true;
}

void keepAllUserUnderscore()
{
	TermBistate!("UU").activated = true;
	TermBistate!("XU").activated = true;
	TermBistate!("LU").activated = false;
	TermBistate!("CU").activated = true;
}

void bytifyUnderscore()
{
	TermBistate!("UU").activated = false;
	TermBistate!("XU").activated = false;
	TermBistate!("LU").activated = true;
	TermBistate!("CU").activated = true;
}

// =======> KeyWord Terms

// KW

unittest
{
	static assert(__traits(compiles, {auto engine = makeKeyWordTerm("a");}));
	
	auto term = makeKeyWordTerm("f");
	assert(term.charSequence == "f");
	debug
	{
		assert(term[0].id == "KW");
	}
}

OutputTerm[] makeKeyWordTerm(string s)
{
	auto result = new TermMonostate!("KW");
	result.payload = s;
	return makeEmpty() ~ result;
}

// =======> CharLiteral Terms

// SQ

unittest
{
	static assert(__traits(compiles, {auto engine = makeSingleQuoteTerm();}));
	
	auto term = makeSingleQuoteTerm();
	assert(term.charSequence == "'");
	debug
	{
		assert(term[0].id == "SQ");
	}
}

OutputTerm[] makeSingleQuoteTerm()
{
	auto result = new TermMonostate!("SQ");
	result.payload = "'";
	return makeEmpty() ~ result;
}

// CL

unittest
{
	static assert(__traits(compiles, {auto engine = makeCharLiteralTerm("a");}));
	
	auto term = makeCharLiteralTerm("b");
	assert(term.charSequence == "b");
	debug
	{
		assert(term[0].id == "CL");
	}
}

OutputTerm[] makeCharLiteralTerm(string s)
{
	auto result = new TermMonostate!("CL");
	result.payload = s;
	return makeEmpty() ~ result;
}