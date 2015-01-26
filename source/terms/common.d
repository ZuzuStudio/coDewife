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

unittest
{
	static assert(__traits(compiles, {auto engine = makeInvariantTerm("a");}));
	
	auto term = makeInvariantTerm("D");
	assert(term.charSequence == "D");
	assert(term.id == "IS");
}

OutputTerm makeInvariantTerm(string s)
{
	auto result = new TermConfigurator!("IS");
	result.deactive = s;
	result.active = s;
	return result;
}

// =======> Underscore Terms

// UU

unittest
{
	static assert(__traits(compiles, {auto engine = makeUserUnderscoreTerm();}));
	
	auto term_1 = makeUserUnderscoreTerm();
	auto term_2 = makeUserUnderscoreTerm();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "");
	enableUserUnderscore();
	assert(term_1.charSequence == "_");
	assert(term_2.charSequence == "_");
	disableUserUnderscore();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "");
	assert(term_1.id == "UU");
}

OutputTerm makeUserUnderscoreTerm()
{
	auto result = new TermConfigurator!("UU");
	result.deactive = "";
	result.active = "_";
	return result;
}

void enableUserUnderscore()
{
	TermConfigurator!("UU").active_enabled = true;
}

void disableUserUnderscore()
{
	TermConfigurator!("UU").active_enabled = false;
}

// CU

unittest
{
	static assert(__traits(compiles, {auto engine = makeCommonUnderscoreTerm();}));
	
	auto term_1 = makeCommonUnderscoreTerm();
	auto term_2 = makeUserUnderscoreTerm();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "");
	enableCommonUnderscore();
	assert(term_1.charSequence == "_");
	assert(term_2.charSequence == "");
	disableCommonUnderscore();
	enableUserUnderscore();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "_");
	assert(term_1.id == "CU");
}

OutputTerm makeCommonUnderscoreTerm()
{
	auto result = new TermConfigurator!("CU");
	result.deactive = "";
	result.active = "_";
	return result;
}

void enableCommonUnderscore()
{
	TermConfigurator!("CU").active_enabled = true;
}

void disableCommonUnderscore()
{
	TermConfigurator!("CU").active_enabled = false;
}

// LU

unittest
{
	static assert(__traits(compiles, {auto engine = makeLogicalUnderscoreTerm();}));
	
	auto term_1 = makeLogicalUnderscoreTerm();
	auto term_2 = makeCommonUnderscoreTerm();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "");
	enableLogicalUnderscore();
	assert(term_1.charSequence == "_");
	assert(term_2.charSequence == "");
	disableLogicalUnderscore();
	enableCommonUnderscore();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "_");
	assert(term_1.id == "LU");
}

OutputTerm makeLogicalUnderscoreTerm()
{
	auto result = new TermConfigurator!("LU");
	result.deactive = "";
	result.active = "_";
	return result;
}

void enableLogicalUnderscore()
{
	TermConfigurator!("LU").active_enabled = true;
}

void disableLogicalUnderscore()
{
	TermConfigurator!("LU").active_enabled = false;
}

// XU

unittest
{
	static assert(__traits(compiles, {auto engine = makeLastUnderscoreTerm();}));
	
	auto term_1 = makeLastUnderscoreTerm();
	auto term_2 = makeCommonUnderscoreTerm();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "");
	enableLastUnderscore();
	assert(term_1.charSequence == "_");
	assert(term_2.charSequence == "");
	disableLastUnderscore();
	enableCommonUnderscore();
	assert(term_1.charSequence == "");
	assert(term_2.charSequence == "_");
	assert(term_1.id == "XU");
}

OutputTerm makeLastUnderscoreTerm()
{
	auto result = new TermConfigurator!("XU");
	result.deactive = "";
	result.active = "_";
	return result;
}

void enableLastUnderscore()
{
	TermConfigurator!("XU").active_enabled = true;
}

void disableLastUnderscore()
{
	TermConfigurator!("XU").active_enabled = false;
}