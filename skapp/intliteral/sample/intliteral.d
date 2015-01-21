module sample.intliteral;

import terms.underscore;
import fsm.configurations;
import terms.invariantsequence;

Engine makeDigitalLiteral()
{
	Engine[string] table;
	table["BinaryPrefix"] = makeSequence(makeSingleIdentity("0"),
	                                     makeParallel(makeSingleIdentity("b"),
	                                                  makeSingleIdentity("B")));
	table["ForwardBinaryDigit"] = makeGeneral((string s) => s == "0" || s == "1",
	                                          (string s) => cast(OutputTerm[])[]);
	table["ForwardDecimalDigit"] = makeGeneral((string s) => "0" <= s && s <= "9",
	                                    (string s) => cast(OutputTerm[])[]);
	table["ForwardUnderscore"] = makeGeneral((string s) => s == "_",
	                                         (string s) => cast(OutputTerm[])[]);
	table["BackwardDecimalDigit"] = makeRangeIdentity!backward("0", "9");
	table["BackwardLUDigit"] = makeGeneral!backward((string s) => "0" <= s && s <= "9",
	                                                (string s) => cast(OutputTerm[])[] 
	                                                              ~ new InvariantSequence(s)
	                                                              ~ new LogicalUnderscore);
	table["XU"] = makeGeneral!backward((string s) => s == "_",
	                                   (string s) => cast(OutputTerm[])[] ~ new LastUnderscore);
	table["CU"] = makeGeneral!backward((string s) => s == "_",
	                                   (string s) => cast(OutputTerm[])[] ~ new CommonUnderscore);
	table["UU"] = makeGeneral!backward((string s) => s == "_",
	                                   (string s) => cast(OutputTerm[])[] ~ new UserUnderscore);
	table["UU*D"] = makeSequence!backward(makeKleene!(star, backward)(table["UU"]),
	                                      table["BackwardDecimalDigit"]);
	table["Period"] = makeSequence!backward(makeQuantifier!backward(table["UU*D"], 2),
	                                        makeParallel!backward(makeSequence!backward(table["CU"],
	                                                                                    makeKleene!(star, backward)(table["UU"]),
	                                                                                    table["BackwardDecimalDigit"]),
	                                                              table["BackwardLUDigit"]));
	table["ForwardDecimalLiteral"] = makeSequence(table["ForwardDecimalDigit"],
	                                              makeKleene!star(makeParallel(table["ForwardDecimalDigit"],
	                                                                           table["ForwardUnderscore"])));
	table["BackwardDecimalLiteral"] = makeSequence!backward(makeKleene!(star, backward)(table["XU"]),
	                                                    table["BackwardDecimalDigit"],
	                                                    makeKleene!(star, backward)(table["Period"]),
	                                                    makeQuantifier!backward(table["UU*D"], 0, 2));
	table["IntegerSuffix"] = makeParallel(makeSequence("Lu"),
	                                      makeSequence("LU"),
	                                      makeSequence("uL"),
	                                      makeSequence("UL"),
	                                      makeSequence("L"),
	                                      makeSequence("u"),
	                                      makeSequence("U"));
	table["DecimalInteger"] = makeHitherAndThither(table["ForwardDecimalLiteral"], table["BackwardDecimalLiteral"]);
	table["IntLiteral"] = makeSequence(table["DecimalInteger"], makeQuantifier(table["IntegerSuffix"], 0, 1));
	return table["IntLiteral"];
}

Engine makeSymbolIdentity()
{
	return makeGeneral((string s) => true,
	                   (string s) => cast(OutputTerm[])[] ~ new InvariantSequence(s));
}
