module sample.identifier;

import terms.common;
import fsm.configurations;

Engine makeIdentifier()
{
  Engine[string] table;
  table["_"] = makeSingleIdentity!(forward, "ID")("_");
  table["Letter"] = makeGeneral((string s) => ("a" <= s && s <= "z") || ("A" <= s && s <= "Z"),
                                (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm!("ID")(s));
  table["0"] = makeSingleIdentity!(forward, "ID")("0");
  table["NonZeroDigit"] = makeGeneral((string s) => "1" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[] ~ makeInvariantTerm!("ID")(s));
                                      
  table["IdentifierStart"] = makeParallel(table["_"], table["Letter"]); // TODO universal alpha                                    
  table["IdentifierChar"] = makeParallel(table["IdentifierStart"], table["0"], table["NonZeroDigit"]);
  table["IdentifierChars"] = makeKleene!star(table["IdentifierChar"]);
  table["Identifier"] = makeSequence(table["IdentifierStart"], table["IdentifierChars"]);
  
  return table["Identifier"];
}
