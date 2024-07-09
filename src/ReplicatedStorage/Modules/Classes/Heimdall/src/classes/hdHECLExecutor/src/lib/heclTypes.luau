local heclTypes = {};

--=====================================================================================--
--================================= CREATE INFO =======================================--
--=====================================================================================--
export type heclScannerCreateInfo = {
	
};
--=====================================================================================--
export type heclChunkCreateInfo = {
	
};
--=====================================================================================--
--================================ STRING UNIONS ======================================--
--=====================================================================================--
export type heclValueType = "VAL_BOOL" | "VAL_NIL" | "VAL_NUMBER"
                          | "VAL_OBJ";
--=====================================================================================--
export type heclOpCode = "OP_CONSTANT" | "OP_NIL"      | "OP_EQUAL"
                       | "OP_RETURN"   | "OP_INDENT"   | "OP_ADD"
                       | "OP_SUBTRACT" | "OP_MULTIPLY" | "OP_DIVIDE"
                       | "OP_NOT"      | "OP_NEGATE"   | "OP_TRUE"
                       | "OP_FALSE"    | "OP_EQUAL"    | "OP_GREATER"
                       | "OP_LESS"     | "OP_WRITE"    | "OP_READ"
--=====================================================================================--
export type heclPrecedence = "PREC_NONE" | "PREC_ASSIGNMENT" | "PREC_OR"
                           | "PREC_AND"  | "PREC_EQUALITY"   | "PREC_COMPARISON"
                           | "PREC_TERM" | "PREC_FACTOR"     | "PREC_UNARY"
                           | "PREC_CALL" | "PREC_PRIMARY";
--=====================================================================================--
export type heclTokenType = "TOKEN_MAKE"       | "TOKEN_TYPE_DEF"      | "TOKEN_WITH"
                          | "TOKEN_COMPONENT"  | "TOKEN_STRING"        | "TOKEN_NUMBER"
                          | "TOKEN_COLON"      | "TOKEN_SEMI_COLON"    | "TOKEN_RETURN"
                          | "TOKEN_INDENT"     | "TOKEN_EQUAL"         | "TOKEN_IDENTIFIER"
                          | "TOKEN_LEFT_PAREN" | "TOKEN_RIGHT_PAREN"   | "TOKEN_HECL"
                          | "TOKEN_END_HECL"   | "TOKEN_DECLARE"       | "TOKEN_AS"
						  | "TOKEN_ERROR"      | "TOKEN_EOF"           | "TOKEN_PLUS"
                          | "TOKEN_MINUS"      | "TOKEN_EQUAL_EQUAL"   | "TOKEN_TRUE"
						  | "TOKEN_FALSE"      | "TOKEN_NIL"           | "TOKEN_BANG"
						  | "TOKEN_STAR"       | "TOKEN_SLASH"         | "TOKEN_GREATER"
						  | "TOKEN_LESS"       | "TOKEN_GREATER_EQUAL" | "TOKEN_LESS_EQUAL"
                          | "TOKEN_NOT_EQUAL"

--=====================================================================================--
--================================ BUILT IN TYPES =====================================--
--=====================================================================================--
export type heclParseRule = {
	prefix : () -> ();
	infix : () -> ();
	precedence : heclPrecedence;
};
--=====================================================================================--
export type heclToken = {
	tokenType : heclTokenType;
	start : string;
	length : number;
	line : number;
};
--=====================================================================================--

return heclTypes;