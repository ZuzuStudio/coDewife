module sample.charliteral;

import terms.charliteral;
import terms.invariantsequence;
import fsm.configurations;

Engine makeHungryMachine()
{
  return makeAllIdentity!(forward, Unknown)();
}


Engine makeCharLiteral()
{
  Engine[string] table;
  table["Character"] = makeAllIdentity!(forward, CharLiteral)();
  
  table["HexLetter"] = makeGeneral((string s) => (("a" <= s && s <= "f") || ("A" <= s && s <= "F") || s == "_"),
                                   (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
  table["OctalDigit"] = makeGeneral((string s) => (("0" <= s && s <= "7") || s == "_"),
                                    (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
  table["DecimalDigit"] = makeRangeIdentity!(forward, CharLiteral)("0", "9");
  //table["DecimalDigit"] = makeGeneral((string s) => ("0" <= s && s <= "9"),
  //                                    (string s) => cast(OutputTerm[])[] ~ new CharLiteral(s));
  table["HexDigit"] = makeParallel(table["DecimalDigit"],
                                   table["HexLetter"]);
  
  table["EscapeSequence"] = makeParallel(makeSequence!(forward, CharLiteral)(`\'`),
                                         makeSequence!(forward, CharLiteral)(`\"`),
                                         makeSequence!(forward, CharLiteral)(`\?`),
                                         makeSequence!(forward, CharLiteral)(`\\`),
                                         makeSequence!(forward, CharLiteral)(`\0`),
                                         makeSequence!(forward, CharLiteral)(`\a`),
                                         makeSequence!(forward, CharLiteral)(`\b`),
                                         makeSequence!(forward, CharLiteral)(`\f`),
                                         makeSequence!(forward, CharLiteral)(`\n`),
                                         makeSequence!(forward, CharLiteral)(`\r`),
                                         makeSequence!(forward, CharLiteral)(`\t`),
                                         makeSequence!(forward, CharLiteral)(`\v`),
                                         makeSequence(makeSequence!(forward, CharLiteral)(`\x`), table["HexDigit"], table["HexDigit"]),
                                         makeSequence(makeSingleIdentity!(forward, CharLiteral)(`\`), table["OctalDigit"]),
                                         makeSequence(makeSingleIdentity!(forward, CharLiteral)(`\`), table["OctalDigit"], table["OctalDigit"]),
                                         makeSequence(makeSingleIdentity!(forward, CharLiteral)(`\`), table["OctalDigit"], table["OctalDigit"], table["OctalDigit"]),
                                         makeSequence(makeSequence!(forward, CharLiteral)(`\u`), table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"]),
                                         makeSequence(makeSequence!(forward, CharLiteral)(`\U`), table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"]),);
  table["SingleQuotedCharacter"] = makeParallel(table["EscapeSequence"],
                                                table["Character"]);
  
  table["SingleQuote"] = makeSingleIdentity!(forward, SingleQuote)("'");
  //table["SingleQuote"] = makeGeneral((string s) => s == "'",
  //                                   (string s) => cast(OutputTerm[])[] ~ new SingleQuote(s));
  table["CharLiteral"] = makeSequence(table["SingleQuote"],
                                      table["SingleQuotedCharacter"],
                                      table["SingleQuote"]);
  return table["CharLiteral"];
}
