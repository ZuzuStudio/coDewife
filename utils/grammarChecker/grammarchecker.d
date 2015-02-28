module main;

import std.json;
import std.stdio;
import std.range;

void main()
{
	string allText;
	foreach(line; stdin.byLine)
		allText ~= line;

	auto jsonTree = parseJSON(allText);
	foreach(automat; jsonTree.array)
	{
		auto isForwardDirection = "direction" !in automat || automat["direction"].str == "forward"; 
		writeln(automat["name"],"(",automat["type"],") ", isForwardDirection? "->": "<-");
		foreach(subautomat; automat["automata"].array)
			writeln("\t", subautomat);
	}
}