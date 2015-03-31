module jsonformatchecker;

import std.stdio;
import std.algorithm;

enum JsonPlace{empty, invalid, array, object, name, field, andmore, escape, string, boolean, integer, floating};

bool formatCheck(ubyte[] rawText)
{
	Stack stack;
	uint lineNo = 1;
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
	
	return stack.last == JsonPlace.empty;
}

void printError(uint lineNo, ubyte[] line, string message)
{
	stderr.writeln("There is an error in ", lineNo, " line:\n", cast(char[])line,"\n",message);
	core.stdc.stdlib.exit(1);
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