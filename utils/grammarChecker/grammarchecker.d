module main;

import std.json;
import std.stdio;
import std.range;
import std.traits;
import std.algorithm;
import std.array;

immutable(string[]) elementar = ["general", "singleIdentity", "rangeIdentity", "allIdentity"];
immutable(string[]) configurations = ["sequence", "parallel", "Kleene star", "Kleene plus", "quantifier", "heatherAndTheather"];

int main()
{
	auto rawText = stdin.byChunk(4096).joiner.array;
	Stack stack;
	uint lineNo = 1;

	dchar[dchar] complimentar = [ cast(dchar)'}':cast(dchar)'{', '{':'}', ']':'[', '[':']', ];

	foreach(line; rawText.splitter(cast(ubyte)'\n'))
	{
		bool escape = false;
		foreach(dchar c; cast(char[])line)
		{
			if(c == '{' || c == '[')
				stack.push(c);

			if(c == '}' || c == ']')
			{
				if(stack.last != complimentar[c])
					printError(lineNo, line, "not matching braces");
				if(stack.last == ',')
					printError(lineNo, line, "comma before bracket");
				if(stack.last == ':')
					printError(lineNo, line, "collon before bracket");
				stack.pop();
			}

			if(stack.last == '\\' && stack.prelast == '\"')
				stack.pop();
			else
			{
				if(c == '\\' && stack.last == '\"')
					stack.push(c);
			}

			if(c == ',')
			{
				if(stack.last == ':')
					printError(lineNo, line, "comma after collon");
				else if(stack.last != '\\' && stack.last != '\"')
					stack.push(c);
			}

			if(c == ':')
			{
				if(stack.last == ',')
					printError(lineNo, line, "collon after comma");
				else if(stack.last == '[')
					printError(lineNo, line, "collon in array");
				else if(stack.last != '\\' && stack.last != '\"')
					stack.push(c);
			}

			if(c == '\"')
			{
				if(stack.last == '\"')
					stack.pop();
				else
				{
					if(stack.last == ',' || stack.last == ':')
						stack.pop();
					stack.push(c);
				}
			}
			writeln(stack);
		}
		++lineNo;
	}

	auto jsonTree = rawText.parseJSON;
	foreach(automat; jsonTree.array)
	{
		check(("name" in automat), automat, "No name defined");
		check(automat["name"].type == JSON_TYPE.STRING, automat, "Field name isn't string");
		check(("type" in automat), automat, "No type defined");
		check(automat["type"].type == JSON_TYPE.STRING, automat, "Field type isn't string");
		check(canFind(elementar, automat["type"].str) || canFind(configurations, automat["type"].str), automat, "Unregistered type of automaton");

		auto isForwardDirection = "direction" !in automat || automat["direction"].str == "forward"; 
		writeln(automat["name"].str, "  (", automat["type"].str, isForwardDirection? " ==> ": " <== ", ")");

		if(canFind(configurations, automat["type"].str))
		{
			check(("automata" in automat), automat, "No automata for configuration defined");
			check(automat["automata"].type == JSON_TYPE.ARRAY, automat, "Field automata isn't array");
			foreach(subautomat; automat["automata"].array)
				writeln("\t", subautomat.str);
		}

	}
	return 0;
}

struct Stack
{
	dchar last() @property nothrow pure @safe @nogc
	{
		if(representation.length < 1)
			return '\0';
		return representation[$ - 1];
	}

	dchar prelast() @property nothrow pure @safe @nogc
	{
		if(representation.length < 2)
			return '\0';
		return representation[$ - 2];
	}

	void push(dchar c)nothrow pure @safe
	{
		representation ~= c;
	}

	void pop()nothrow pure @safe
	{
		if(representation.length > 0)
			--representation.length;
	}

	dstring toString()pure nothrow @safe
	{
		return representation.idup;
	}

private:
	dchar[] representation;
}

void check(T)(T predicate, lazy JSONValue jsonValue, lazy string message)
{
	if(!predicate)
	{
		stderr.writeln("\nThere is an error in folowing automat:");
		stderr.writeln(jsonValue.toPrettyString());
		stderr.writeln(message);
		core.stdc.stdlib.exit(1);
	}
}

void printError(uint lineNo, ubyte[] line, string message)
{
	stderr.writeln("There is an error in ", lineNo, " line:\n", cast(char[])line,"\n",message);
}