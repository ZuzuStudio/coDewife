module main;

import std.json;
import std.stdio;
import std.range;
import std.traits;
import std.algorithm;
import std.array;
import std.typecons;

import jsonformatchecker;

alias MarkableAutomat = Tuple!(string[], bool);

immutable(dchar[]) jsonSymbol = ['[', ']', '{', '}', '\"', '\\', ':', ','];
immutable(string[]) elementar = ["general", "singleIdentity", "rangeIdentity", "allIdentity"];
immutable(string[]) configurations = ["sequence", "parallel", "Kleene star", "Kleene plus", "quantifier", "heatherAndTheather"];

int main()
{
	auto rawText = stdin.byChunk(4096).joiner.array;
	
	if(!formatCheck(rawText))
	{
		writeln("Error in format");
		return 1;
	}

	auto jsonTree = rawText.parseJSON;


	MarkableAutomat[string] verteces;
	foreach(automat; jsonTree.array)
	{
		check(("name" in automat), automat, "No name defined");
		check(automat["name"].type == JSON_TYPE.STRING, automat, "Field name isn't string");
		check(("type" in automat), automat, "No type defined");
		check(automat["type"].type == JSON_TYPE.STRING, automat, "Field type isn't string");
		check(canFind(elementar, automat["type"].str) || canFind(configurations, automat["type"].str), automat, "Unregistered type of automaton");

		auto isForwardDirection = "direction" !in automat || automat["direction"].str == "forward"; 
		writeln(automat["name"].str, "  (", automat["type"].str, isForwardDirection? " ==> ": " <== ", ")");

		verteces[automat["name"].str] = tuple(null, false);

		if(canFind(configurations, automat["type"].str))
		{
			check(("automata" in automat), automat, "No automata for configuration defined");
			check(automat["automata"].type == JSON_TYPE.ARRAY, automat, "Field automata isn't array");
			string[] automataString;
			check(automat["automata"].array.length > 0, automat,  "Field automata is empty");
			foreach(subautomat; automat["automata"].array)
			{
				writeln("\t", subautomat.str);
				automataString ~= subautomat.str;
			}
			verteces[automat["name"].str][0] = automataString;
		}

	}

	foreach(pair; verteces.byKeyValue)
		writeln(pair.key, ": ", pair.value[0], " ", pair.value[1]);

	writeln();

	dfs(verteces, jsonTree.array[0]["name"].str);

	writeln();

	foreach(pair; verteces.byKeyValue)
		writeln(pair.key, ": ", pair.value[0], " ", pair.value[1]);

	bool cohernce = true;

	foreach(automat; verteces.byValue)
		cohernce = cohernce && automat[1];

	if(!cohernce)
		stderr.writeln("System of automata isn't coherent");

	return 0;
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

void dfs(ref MarkableAutomat[string] vertices, string current)
{
	if(!vertices[current][1])
	{
		vertices[current][1] = true;
		foreach(next; vertices[current][0])
		{
			if(next in vertices)
				dfs(vertices, next);
			else
				stderr.writeln(current, " reference to node ", next, " that doesn't exist");
		}
	}
}

