Identifiers
Identifier:
    IdentifierStart
    IdentifierStart IdentifierChars

IdentifierChars:
    IdentifierChar
    IdentifierChar IdentifierChars

IdentifierStart:
    _
    Letter
    UniversalAlpha

IdentifierChar:
    IdentifierStart
    0
    NonZeroDigit
    
Identifiers start with a letter, _, or universal alpha, and are followed by any number of letters, _, digits, 
or universal alphas. Universal alphas are as defined in ISO/IEC 9899:1999(E) Appendix D. (This is the C99 Standard.) 
Identifiers can be arbitrarily long, and are case sensitive. Identifiers starting with __ (two underscores) are reserved.