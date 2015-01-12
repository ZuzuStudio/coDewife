module sample.identifier;

import fsm.configurations;

Engine makeIdentifier()
{
  import terms.invariantsequence;
  Engine[string] table;
  table["_"] = makeSingleIdentity("_");
  table["Letter"] = makeGeneral((string s) => ("a" <= s && s <= "z") || ("A" <= s && s <= "Z"),
                                (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
  table["0"] = makeSingleIdentity("0");
  table["NonZeroDigit"] = makeGeneral((string s) => "1" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
                                      
  table["IdentifierStart"] = makeParallel(table["_"], table["Letter"]); // TODO universal alpha                                    
  table["IdentifierChar"] = makeParallel(table["IdentifierStart"], table["0"], table["NonZeroDigit"]);
  table["IdentifierChars"] = makeKleene!star(table["IdentifierChar"]);
  table["Identifier"] = makeSequence(table["IdentifierStart"], table["IdentifierChars"]);
  
  return table["Identifier"];
}
