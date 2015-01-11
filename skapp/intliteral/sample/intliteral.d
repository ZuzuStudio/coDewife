module sample.intliteral;

import terms.underscore;
import fsm.configurations;
import terms.invariantsequence;

Engine makeDigitalLiteral()
{
  Engine[string] table;
  table["ForwardDigit"] = makeGeneral((string s) => "0" <= s && s <= "9",
                                      (string s) => cast(OutputTerm[])[]);
  table["ForwardUnderscore"] = makeGeneral((string s) => s == "_",
                                           (string s) => cast(OutputTerm[])[]);
  table["BackwardDigit"] = makeRangeIdentity!backward("0", "9");
  table["BackwardLUDigit"] = makeGeneral!backward((string s) => "0" <= s && s <= "9",
                                                  (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s) ~ new LogicalUnderscore);
  table["XU"] = makeGeneral!backward((string s) => s == "_",
                                     (string s) => cast(OutputTerm[])[] ~ new LastUnderscore);
  table["CU"] = makeGeneral!backward((string s) => s == "_",
                                     (string s) => cast(OutputTerm[])[] ~ new CommonUnderscore);
  table["UU"] = makeGeneral!backward((string s) => s == "_",
                                     (string s) => cast(OutputTerm[])[] ~ new UserUnderscore);
  table["UU*D"] = makeSequence!backward(makeKleene!(star, backward)(table["UU"]),
                                        table["BackwardDigit"]);
  table["Period"] = makeSequence!backward(makeQuantifier!backward(table["UU*D"], 2),
                                          makeParallel!backward(makeSequence!backward(table["CU"],
                                                                                      makeKleene!(star, backward)(table["UU"]),
                                                                                      table["BackwardDigit"]),
                                                                table["BackwardLUDigit"]));
  table["ForwardIntLiteral"] = makeSequence(table["ForwardDigit"],
                                            makeKleene!star(makeParallel(table["ForwardDigit"],
                                                                         table["ForwardUnderscore"])));
  table["BackwardIntLiteral"] = makeSequence!backward(makeKleene!(star, backward)(table["XU"]),
                                                      table["BackwardDigit"],
                                                      makeKleene!(star, backward)(table["Period"]),
                                                      makeQuantifier!backward(table["UU*D"], 0, 2));
  table["IntLiteral"] = makeHitherAndThither(table["ForwardIntLiteral"], table["BackwardIntLiteral"]);
  return table["IntLiteral"];
}

Engine makeSymbolIdentity()
{
	return makeGeneral((string s) => true,
					   (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
}
