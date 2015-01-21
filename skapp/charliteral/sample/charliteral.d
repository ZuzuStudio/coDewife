module sample.charliteral;

import terms.charliteral;
import terms.invariantsequence;
import fsm.configurations;

Engine makeHungryMachine()
{
  return makeGeneral((string s) => true,
                     (string s) => cast(OutputTerm[])[] ~ new Unknown(s));
}


Engine makeCharLiteral()
{
  Engine[string] table;
  table["Character"] = makeGeneral((string s) => true,
                                   (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
                                   
  table["HexLetter"] = makeGeneral((string s) => (("a" <= s && s <= "f") || ("A" <= s && s <= "F") || s == "_"),
                                   (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
  table["OctalDigit"] = makeGeneral((string s) => (("0" <= s && s <= "7") || s == "_"),
                                    (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
  table["DecimalDigit"] = makeGeneral((string s) => ("0" <= s && s <= "9"),
                                      (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
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
  table["SingleQuotedCharacter"] = makeParallel(table["EscapeSequence"],
                                                table["Character"]);
                                                
  table["SingleQuote"] = makeGeneral((string s) => s == "'",
                                     (string s) => cast(OutputTerm[])[] ~ new SingleQuote(s));
  table["CharLiteral"] = makeSequence(table["SingleQuote"],
                                      table["SingleQuotedCharacter"],
                                      table["SingleQuote"]);
  return table["CharLiteral"];
}
