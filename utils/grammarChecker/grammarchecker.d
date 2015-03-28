module main;

import std.json;
import std.stdio;
import std.range;
import std.traits;
import std.algorithm;
import std.array;

immutable(dchar[]) jsonSymbol = ['[', ']', '{', '}', '\"', '\\', ':', ','];
immutable(string[]) elementar = ["general", "singleIdentity", "rangeIdentity", "allIdentity"];
immutable(string[]) configurations = ["sequence", "parallel", "Kleene star", "Kleene plus", "quantifier", "heatherAndTheather"];

enum JsonPlace{empty, invalid, array, object, name, field, andmore, escape, string, boolean, integer, floating};

int main()
{
	auto rawText = stdin.byChunk(4096).joiner.array;
	Stack stack;
	uint lineNo = 1;

	//dchar[dchar] complimentar = [ cast(dchar)'}':cast(dchar)'{', '{':'}', ']':'[', '[':']', ];

	foreach(line; rawText.splitter(cast(ubyte)'\n'))
	{
		foreach(dchar c; cast(char[])line)
		{
			if(stack.last == JsonPlace.escape)
			{
				stack.pop();
				writeln(stack);
				continue;
			}

			if(c == '[' )
			{
				if(stack.last == JsonPlace.empty
					|| stack.last == JsonPlace.array 
					|| (stack.last == JsonPlace.andmore && stack.prelast == JsonPlace.array)
					|| stack.last == JsonPlace.field)
				{
					if(stack.last == JsonPlace.andmore)
						stack.pop();
					stack.push(JsonPlace.array);
				}
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly start of array");
				}
			}

			if(c == ']')
			{
				if(stack.last == JsonPlace.array)
					stack.pop();
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly end of array");
				}
			}

			if(c == '{')
			{
				if(stack.last == JsonPlace.empty 
					|| stack.last == JsonPlace.array 
					|| (stack.last == JsonPlace.andmore && stack.prelast == JsonPlace.array)
					|| stack.last == JsonPlace.field)
				{
					if(stack.last == JsonPlace.andmore)
						stack.pop();
					stack.push(JsonPlace.object);
				}
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly start of object");
				}
			}

			if(c == '}')
			{
				if(stack.last == JsonPlace.field)
				{
					stack.pop();
					stack.pop();
				}
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly end of object");
				}
			}

			if(('0' <= c && c <= '9') || (c == '.'))
			{
				if(c == '.')
				{
					if(stack.last == JsonPlace.integer)
					{
						stack.pop();
						stack.push(JsonPlace.floating);
					}
					else
					{
						stack.push(JsonPlace.invalid);
						printError(lineNo, line, "dot not in floating");
					}
				}
				else if(stack.last == JsonPlace.array 
					|| (stack.last == JsonPlace.andmore && stack.prelast == JsonPlace.array)
					|| stack.last == JsonPlace.field)
				{
					if(stack.last == JsonPlace.andmore)
						stack.pop();
					stack.push(JsonPlace.integer);
				}
			}
			else
			{
				if(stack.last == JsonPlace.integer || stack.last == JsonPlace.floating)
					stack.pop();
			}

			if(c == ',')
			{
				if(stack.last == JsonPlace.array || stack.last == JsonPlace.field)
				{
					if(stack.last == JsonPlace.field)
						stack.pop();
					stack.push(JsonPlace.andmore);
				}
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly comma");
				}
			}

			if(c == '\"')
			{
				if(stack.last == JsonPlace.array 
					|| (stack.last == JsonPlace.andmore && stack.prelast == JsonPlace.array)
					|| stack.last == JsonPlace.object
					|| (stack.last == JsonPlace.andmore && stack.prelast == JsonPlace.object)
					|| stack.last == JsonPlace.field
					|| stack.last == JsonPlace.string)
				{
					if(stack.last == JsonPlace.string)
						stack.pop();
					else
					{
						if(stack.last == JsonPlace.andmore)
							stack.pop();
						if(stack.last == JsonPlace.object)
							stack.push(JsonPlace.name);
						stack.push(JsonPlace.string);
					}
				}
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly quotes mark");
				}
			}

			if(c == '\\')
			{
				if(stack.last == JsonPlace.string)
					stack.push(JsonPlace.escape);
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly backslash");
				}
			}

			if(c == ':')
			{
				if(stack.last == JsonPlace.name)
				{
					stack.pop();
					stack.push(JsonPlace.field);
				}
				else
				{
					stack.push(JsonPlace.invalid);
					printError(lineNo, line, "suddenly comma");
				}
			}

			version(none){
			if(canFind(jsonSymbol, c))
				writeln(stack);
			}
			
			if(stack.last == JsonPlace.invalid)
				core.stdc.stdlib.exit(1);
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
	JsonPlace last() @property nothrow pure @safe @nogc
	{
		if(representation.length < 1)
			return JsonPlace.empty;
		return representation[$ - 1];
	}

	JsonPlace prelast() @property nothrow pure @safe @nogc
	{
		if(representation.length < 2)
			return JsonPlace.empty;
		return representation[$ - 2];
	}

	void push(JsonPlace jp)nothrow pure @safe
	{
		representation ~= jp;
	}

	void pop()nothrow pure @safe
	{
		if(representation.length > 0)
			--representation.length;
	}

	string toString()nothrow @safe
	{
		auto mapping = [JsonPlace.empty:"e", JsonPlace.invalid:"i",
			JsonPlace.array:"A", JsonPlace.object:"O", 
			JsonPlace.name:"n", JsonPlace.field:"f", JsonPlace.andmore:"m", JsonPlace.escape:"\\",
			JsonPlace.string:"S", JsonPlace.boolean:"B",
			JsonPlace.integer:"I", JsonPlace.floating:"F"];
		string result;
		foreach(jp; representation)
			result ~= mapping[jp] ~ " ";
		return result;
	}

private:
	JsonPlace[] representation;
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
	core.stdc.stdlib.exit(1);
}