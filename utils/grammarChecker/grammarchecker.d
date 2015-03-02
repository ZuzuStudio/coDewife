module main;

import std.json;
import std.stdio;
import std.range;

immutable(string[]) elementar = ["general", "singleIdentity", "rangeIdentity", "allIdentity"];
immutable(string[]) configurations = ["sequence", "parallel", "Kleene star", "Kleene plus", "quantifier", "heatherAndTheather"];

void main()
{
	string allText;
	foreach(line; stdin.byLine)
		allText ~= line;

	auto jsonTree = parseJSON(allText);
	foreach(automat; jsonTree.array)
	{
		auto isForwardDirection = "direction" !in automat || automat["direction"].str == "forward"; 
		writeln(automat["name"], isForwardDirection? "-->": "<--", automat["type"]);
		foreach(subautomat; automat["automata"].array)
			writeln("\t", subautomat);
	}
}