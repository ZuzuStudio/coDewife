module sample.identifier;

import fsm.configurations;

Engine makeIdentifier()
{
  import terms.invariantsequence;
  Engine[string] table;
  table["_"] = makeGeneral((string s) => s == "_",
                           (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
  table["Letter"] = makeGeneral((string s) => ("a" <= s && s <= "z") || ("A" <= s && s <= "Z"),
                                (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
  table["0"] = makeGeneral((string s) => s == "0",
                           (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
  table["NonZeroDigit"] = makeGeneral((string s) => "1" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
                                      
  table["IdentifierStart"] = makeParallel(table["_"], table["Letter"]); // TODO universal alpha                                    
  table["IdentifierChar"] = makeParallel(table["IdentifierStart"], table["0"], table["NonZeroDigit"]);
  table["IdentifierChars"] = makeKleene!star(table["IdentifierChar"]);
  table["Identifier"] = makeSequence(table["IdentifierStart"], table["IdentifierChars"]);
  
  return table["Identifier"];
}
