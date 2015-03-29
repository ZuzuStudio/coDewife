module main;

import std.json;
import std.stdio;
import std.range;
import std.traits;
import std.algorithm;
import std.array;

import jsonformatchecker;

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

