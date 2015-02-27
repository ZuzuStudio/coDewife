module sample.intliteral;

import codewife.terms.common;
import codewife.fsm.configurations;

Engine makeDigitalLiteral()
{
	Engine[string] table;
	table["BinaryPrefix"] = makeSequence(makeSingleIdentity("0"),
	                                     makeParallel(makeSingleIdentity("b"),
	                                                  makeSingleIdentity("B")));
	table["ForwardBinaryDigit"] = makeGeneral((string s) => "0" <= s && s <= "1",
	                                          (string s) => makeEmpty());
	table["BackwardBinaryDigit"] = makeRangeIdentity!backward("0", "1");
	table["BackwardLUBinaryDigit"] = makeGeneral!backward((string s) => "0" <= s && s <= "1",
	                                                      (string s) => makeInvariantTerm(s)
	                                                                    ~ makeUnderscoreTerm!"LU"());
	table["BackwardLULUBinaryDigit"] = makeGeneral!backward((string s) => "0" <= s && s <= "1",
	                                                        (string s) => makeInvariantTerm(s)
	                                                                      ~ makeUnderscoreTerm!"LU"()
	                                                                      ~ makeUnderscoreTerm!"LU"());
	table["ForwardDecimalDigit"] = makeGeneral((string s) => "0" <= s && s <= "9",
	                                           (string s) => makeEmpty());
	table["ForwardUnderscore"] = makeGeneral((string s) => s == "_",
	                                         (string s) => makeEmpty());
	table["BackwardDecimalDigit"] = makeRangeIdentity!backward("0", "9");
	table["BackwardLUDecimalDigit"] = makeGeneral!backward((string s) => "0" <= s && s <= "9",
	                                                       (string s) => makeInvariantTerm(s)
	                                                                     ~ makeUnderscoreTerm!"LU"());
	table["XU"] = makeGeneral!backward((string s) => s == "_",
	                                   (string s) => makeUnderscoreTerm!"XU"());
	table["CU"] = makeGeneral!backward((string s) => s == "_",
	                                   (string s) => makeUnderscoreTerm!"CU"());
	table["UU"] = makeGeneral!backward((string s) => s == "_",
	                                   (string s) => makeUnderscoreTerm!"UU"());
	table["UU*B"] = makeSequence!backward(makeKleene!(star, backward)(table["UU"]),
	                                      table["BackwardBinaryDigit"]);
	table["UU*D"] = makeSequence!backward(makeKleene!(star, backward)(table["UU"]),
	                                      table["BackwardDecimalDigit"]);
	table["BinaryPeriod"] = makeSequence!backward(makeQuantifier!backward(table["UU*B"], 3),
	                                              makeParallel!backward(makeSequence!backward(table["CU"],
	                                                                                          makeKleene!(star, backward)(table["UU"]),
	                                                                                          table["BackwardBinaryDigit"]),
	                                                                    table["BackwardLUBinaryDigit"]));
	table["DecimalPeriod"] = makeSequence!backward(makeQuantifier!backward(table["UU*D"], 2),
	                                               makeParallel!backward(makeSequence!backward(table["CU"],
	                                                                                           makeKleene!(star, backward)(table["UU"]),
	                                                                                           table["BackwardDecimalDigit"]),
	                                                                     table["BackwardLUDecimalDigit"]));
	table["ForwardBinaryLiteral"] = makeSequence(table["BinaryPrefix"],
	                                             makeKleene!star(makeParallel(table["ForwardBinaryDigit"],
	                                                                          table["ForwardUnderscore"])));
	table["BackwardBinaryLiteral"] = makeSequence!backward(makeKleene!(star, backward)(table["XU"]),
	                                                       table["BackwardBinaryDigit"],
	                                                       makeKleene!(star, backward)(table["BinaryPeriod"]),
	                                                       makeQuantifier!backward(table["UU*B"], 0, 3));
	table["ForwardDecimalLiteral"] = makeSequence(table["ForwardDecimalDigit"],
	                                              makeKleene!star(makeParallel(table["ForwardDecimalDigit"],
	                                                                           table["ForwardUnderscore"])));
	table["BackwardDecimalLiteral"] = makeSequence!backward(makeKleene!(star, backward)(table["XU"]),
	                                                        table["BackwardDecimalDigit"],
	                                                        makeKleene!(star, backward)(table["DecimalPeriod"]),
	                                                        makeQuantifier!backward(table["UU*D"], 0, 2));
	table["IntegerSuffix"] = makeParallel(makeSequence("Lu"),
	                                      makeSequence("LU"),
	                                      makeSequence("uL"),
	                                      makeSequence("UL"),
	                                      makeSequence("L"),
	                                      makeSequence("u"),
	                                      makeSequence("U"));
	table["DecimalInteger"] = makeHitherAndThither(table["ForwardDecimalLiteral"], table["BackwardDecimalLiteral"]);
	table["BinaryInteger"] = makeHitherAndThither(table["ForwardBinaryLiteral"], table["BackwardBinaryLiteral"]);
	table["Integer"] = makeParallel(table["BinaryInteger"], table["DecimalInteger"]);
	table["IntLiteral"] = makeSequence(table["Integer"], makeQuantifier(table["IntegerSuffix"], 0, 1));
	return table["IntLiteral"];
}

Engine makeSymbolIdentity()
{
	return makeGeneral((string s) => true,
	                   (string s) => makeInvariantTerm(s));
}
