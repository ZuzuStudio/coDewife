module sample.charliteral;

import codewife.terms.common;
import codewife.fsm.configurations;

Engine makeHungryMachine()
{
  return makeAllIdentity!(forward, "UK")();
}


Engine makeCharLiteral()
{
  Engine[string] table;
  table["Character"] = makeAllIdentity!(forward, "CL")();
  table["HexLetter"] = makeGeneral((string s) => (("a" <= s && s <= "f") || ("A" <= s && s <= "F") || s == "_"),
                                   (string s) => makeInvariantTerm!("CL")(s));
  table["OctalDigit"] = makeGeneral((string s) => (("0" <= s && s <= "7") || s == "_"),
                                    (string s) => makeInvariantTerm!("CL")(s));
  table["DecimalDigit"] = makeRangeIdentity!(forward, "CL")("0", "9");
  table["HexDigit"] = makeParallel(table["DecimalDigit"],
                                   table["HexLetter"]);
  table["EscapeSequence"] = makeParallel(makeSequence!(forward, "CL")(`\'`),
                                         makeSequence!(forward, "CL")(`\"`),
                                         makeSequence!(forward, "CL")(`\?`),
                                         makeSequence!(forward, "CL")(`\\`),
                                         makeSequence!(forward, "CL")(`\0`),
                                         makeSequence!(forward, "CL")(`\a`),
                                         makeSequence!(forward, "CL")(`\b`),
                                         makeSequence!(forward, "CL")(`\f`),
                                         makeSequence!(forward, "CL")(`\n`),
                                         makeSequence!(forward, "CL")(`\r`),
                                         makeSequence!(forward, "CL")(`\t`),
                                         makeSequence!(forward, "CL")(`\v`),
                                         makeSequence(makeSequence!(forward, "CL")(`\x`), table["HexDigit"], table["HexDigit"]),
                                         makeSequence(makeSingleIdentity!(forward, "CL")(`\`), table["OctalDigit"]),
                                         makeSequence(makeSingleIdentity!(forward, "CL")(`\`), table["OctalDigit"], table["OctalDigit"]),
                                         makeSequence(makeSingleIdentity!(forward, "CL")(`\`), table["OctalDigit"], table["OctalDigit"], table["OctalDigit"]),
                                         makeSequence(makeSequence!(forward, "CL")(`\u`), table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"]),
                                         makeSequence(makeSequence!(forward, "CL")(`\U`), table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"], table["HexDigit"]),);
  table["SingleQuotedCharacter"] = makeParallel(table["EscapeSequence"],
                                                table["Character"]);
  table["SingleQuote"] = makeSingleIdentity!(forward, "SQ")("'");
  table["CharLiteral"] = makeSequence(table["SingleQuote"],
                                      table["SingleQuotedCharacter"],
                                      table["SingleQuote"]);
  return table["CharLiteral"];
}
