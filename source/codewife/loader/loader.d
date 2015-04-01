module codewife.loader.loader;

import std.json;
import std.stdio;
import std.range;
import std.traits;
import std.algorithm;
import std.array;

import codewife.fsm.common;
import codewife.fsm.elementar;

immutable(string[]) elementar = ["general", "singleIdentity", "rangeIdentity", "allIdentity"];
immutable(string[]) configurations = ["sequence", "parallel", "Kleene star", "Kleene plus", "quantifier", "heatherAndTheather"];

int main()
{
	string text, line;
	while ((line = stdin.readln()) !is null)
	{
                text ~= line;
	}
	
	Engine[string] primordial_soup;

	auto jsonTree = text.parseJSON;
	
	auto elementar_automates = filter!(a => canFind(elementar, a["type"].str))(jsonTree.array);
	
	foreach(automat; elementar_automates)
	{
                // writeln(automat);
                
		auto isForwardDirection = "direction" !in automat || automat["direction"].str == "forward"; 
		auto direction = isForwardDirection ? Direction.forward : Direction.backward;
                
                switch (automat["type"].str)
                {
                    case "singleIdentity":
                        auto str = automat["string"].str;
                        primordial_soup[automat["name"].str] = isForwardDirection ? makeSingleIdentity!(Direction.forward)(str) :
                                                                                    makeSingleIdentity!(Direction.backward)(str);
                        break;
                    case "rangeIdentity":
                        auto from = automat["from"].str;
                        assert(from.length == 1);
                        auto to = automat["to"].str;
                        assert(to.length == 1);
                        primordial_soup[automat["name"].str] = isForwardDirection ? makeRangeIdentity!(Direction.forward)(from, to) :
                                                                                    makeRangeIdentity!(Direction.backward)(from, to);
                        break;
                    case "allIdentity":
                        primordial_soup[automat["name"].str] = isForwardDirection ? makeAllIdentity!(Direction.forward)() :
                                                                                    makeAllIdentity!(Direction.backward)();
                        break;
                    case "general":
                        writeln("[!] General automats don't support now");
                    
                        break;
                    default:
                        assert(false, "Unexpected elementar fsm. Maybe it don't support now");
                }
	}
	return 0;
}