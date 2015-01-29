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

unittest
{
	assert(charSequence([makeInvariantTerm("jack"), makeInvariantTerm("_6.3")]) == "jack_6.3");
}

string charSequence(OutputTerm[] terms)
{
		typeof(return) result;
		foreach(term; terms)
			result ~= term.charSequence;
		return result;
}

final class TermConfigurator(string term_id) : OutputTerm
{
private:
	string deactive;
	string active;

public:
	static bool active_enabled;
	
	string charSequence() @property
	{
		return active_enabled ? active : deactive;
	}
	
	debug
	{
		override string id()@property
		{
			return term_id;
		}
	}
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
		assert(term.id == "IS");
	}
}

OutputTerm makeInvariantTerm(string type = "IS")(string s)
{
	auto result = new TermConfigurator!(type);
	result.deactive = s;
	result.active = s;
	return result;
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

OutputTerm makeUnderscoreTerm(string variant)()
	if(variant == "UU" || variant == "XU" || variant == "LU" || variant == "CU")
{
	auto result = new TermConfigurator!variant;
	result.deactive = "";
	result.active = "_";
	return result;
}

void disableUnderscore()
{
	TermConfigurator!("UU").active_enabled = false;
	TermConfigurator!("XU").active_enabled = false;
	TermConfigurator!("LU").active_enabled = false;
	TermConfigurator!("CU").active_enabled = false;
}

void keepUserUnderscore()
{
	TermConfigurator!("UU").active_enabled = true;
	TermConfigurator!("XU").active_enabled = false;
	TermConfigurator!("LU").active_enabled = false;
	TermConfigurator!("CU").active_enabled = true;
}

void keepAllUserUnderscore()
{
	TermConfigurator!("UU").active_enabled = true;
	TermConfigurator!("XU").active_enabled = true;
	TermConfigurator!("LU").active_enabled = false;
	TermConfigurator!("CU").active_enabled = true;
}

void bytifyUnderscore()
{
	TermConfigurator!("UU").active_enabled = false;
	TermConfigurator!("XU").active_enabled = false;
	TermConfigurator!("LU").active_enabled = true;
	TermConfigurator!("CU").active_enabled = true;
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
		assert(term.id == "KW");
	}
}

OutputTerm makeKeyWordTerm(string s)
{
	auto result = new TermConfigurator!("KW");
	result.deactive = s;
	result.active = s;
	return result;
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
		assert(term.id == "SQ");
	}
}

OutputTerm makeSingleQuoteTerm()
{
	auto result = new TermConfigurator!("SQ");
	result.deactive = "'";
	result.active = "'";
	return result;
}

// CL

unittest
{
	static assert(__traits(compiles, {auto engine = makeCharLiteralTerm("a");}));
	
	auto term = makeCharLiteralTerm("b");
	assert(term.charSequence == "b");
	debug
	{
		assert(term.id == "CL");
	}
}

OutputTerm makeCharLiteralTerm(string s)
{
	auto result = new TermConfigurator!("CL");
	result.deactive = s;
	result.active = s;
	return result;
}