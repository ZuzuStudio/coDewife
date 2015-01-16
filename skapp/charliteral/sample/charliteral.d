module sample.charliteral;

import terms.invariantsequence;
import fsm.configurations;

Engine makeIdentifier()
{
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


Engine makeCharLiteral()
{
  Engine[string] table;
  table["Character"] = makeGeneral((string s) => true,
                                   (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
                                   
  table["HexLetter"] = makeParallel(makeSingleIdentity("a"),
                                    makeSingleIdentity("b"),
                                    makeSingleIdentity("c"),
                                    makeSingleIdentity("d"),
                                    makeSingleIdentity("e"),
                                    makeSingleIdentity("f"),
                                    makeSingleIdentity("A"),
                                    makeSingleIdentity("B"),
                                    makeSingleIdentity("C"),
                                    makeSingleIdentity("D"),
                                    makeSingleIdentity("E"),
                                    makeSingleIdentity("F"),
                                    makeSingleIdentity("_")); 
  table["OctalDigit"] = makeParallel(makeSingleIdentity("_"),
                                     makeGeneral((string s) => "0" <= s && s <= "7",
                                                 (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s)));
  table["DecimalDigit"] = makeGeneral((string s) => "0" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
  table["HexDigit"] = makeParallel(table["DecimalDigit"],
                                   table["HexLetter"]);
  
  table["EscapeSequence"] = makeParallel(makeSequence(`\'`),
                                         makeSequence(`\"`),
                                         makeSequence(`\?`),
                                         makeSequence(`\\`),
                                         makeSequence(`\0`),
                                         makeSequence(`\a`),
                                         makeSequence(`\b`),
                                         makeSequence(`\f`),
                                         makeSequence(`\n`),
                                         makeSequence(`\r`),
                                         makeSequence(`\t`),
                                         makeSequence(`\v`),
                                         makeSequence(makeSequence(`\x`), table["HexDigit"], table["HexDigit"]),
                                         makeSequence(makeSingleIdentity(`\`), table["OctalDigit"]),
                                         makeSequence(makeSingleIdentity(`\`), table["OctalDigit"], table["OctalDigit"]),
                                         makeSequence(makeSingleIdentity(`\`), table["OctalDigit"], table["OctalDigit"], table["OctalDigit"]),
                                         makeSequence(makeSequence(`\u`), table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"]),
                                         makeSequence(makeSequence(`\U`), table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"]),);
  table["SingleQuotedCharacter"] = makeParallel(table["Character"],
                                                table["EscapeSequence"]);
  table["CharLiteral"] = makeSequence(makeSingleIdentity("'"),
                                      table["SingleQuotedCharacter"],
                                      makeSingleIdentity("'"));
  return table["CharLiteral"];
}
