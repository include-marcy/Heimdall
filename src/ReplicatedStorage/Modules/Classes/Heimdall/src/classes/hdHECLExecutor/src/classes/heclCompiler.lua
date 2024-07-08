local hecl = script.Parent.Parent.Parent;
local heclLib = hecl.src.lib;
local heclTypes = require(heclLib.heclTypes);
local heclClasses = hecl.src.classes;

local heclChunk = require(heclClasses.heclChunk);
local heclScanner = require(heclClasses.heclScanner);
local heclValue = require(heclClasses.heclValue);

local heclCompiler = {};
heclCompiler.__index = heclCompiler;

local currentChunk = nil;

export type heclCompiler = typeof(setmetatable({} :: {
	current : heclTypes.heclToken;
	previous : heclTypes.heclToken;
	hadError : boolean;
	panicMode : boolean;
	scanner : heclScanner.heclScanner;
}, {} :: typeof(heclCompiler)));

local precedenceEnums : {[heclTypes.heclPrecedence] : number} = {
	["PREC_NONE"] = 0;
	["PREC_ASSIGNMENT"] = 1;
	["PREC_OR"] = 2;
	["PREC_AND"] = 3;
	["PREC_EQUALITY"] = 4;
	["PREC_COMPARISON"] = 5;
	["PREC_TERM"] = 6;
	["PREC_FACTOR"] = 7;
	["PREC_UNARY"] = 8;
	["PREC_CALL"] = 9;
	["PREC_PRIMARY"] = 10;
}

local search = {
	[0] = "PREC_NONE";
	[1] = "PREC_ASSIGNMENT";
	[2] = "PREC_OR";
	[3] = "PREC_AND";
	[4] = "PREC_EQUALITY";
	[5] = "PREC_COMPARISON";
	[6] = "PREC_TERM";
	[7] = "PREC_FACTOR";
	[8] = "PREC_UNARY";
	[9] = "PREC_CALL";
	[10] = "PREC_PRIMARY";
}

function heclCompiler.new() : heclCompiler
	local compiler = setmetatable({}, heclCompiler);
	
	compiler.scanner = heclScanner.new({
		
	})
	
	return compiler;
end

function heclCompiler:heclGetCurrentChunk() : heclChunk.heclChunk
	local compiler : heclCompiler = self;

	return currentChunk;
end

function heclCompiler:heclErrorAt(token : heclTypes.heclToken, message : string)
	local compiler : heclCompiler = self;
	
	if compiler.panicMode then
		return;
	end
	
	compiler.panicMode = true;
	local err = "";
	err ..= `[line {token.line}] Error`;
	
	if token.tokenType == "TOKEN_EOF" then
		err ..= " at end";
	elseif token.tokenType == "TOKEN_ERROR" then
		
	else
		local c = compiler.scanner.instructions:sub(token.start, token.start + token.length - 1)
		err ..= string.format(" at '%.s", c);
	end
	
	err ..= string.format(": %s\n", message);
	compiler.hadError = true;
	error(err);
end

function heclCompiler:heclError(message : string)
	local compiler : heclCompiler = self;
	
	compiler:heclErrorAt(compiler.previous, message);
end

function heclCompiler:heclErrorAtCurrent(message : string)
	local compiler : heclCompiler = self;

	compiler:heclErrorAt(compiler.current, message);
end

function heclCompiler:heclAdvance()
	local compiler : heclCompiler = self;
	compiler.previous = compiler.current;
	
	while true do
		compiler.current = compiler.scanner:heclScanToken();

		if (compiler.current.tokenType ~= "TOKEN_ERROR") then
			break
		end

		compiler:heclErrorAtCurrent(compiler.current.start);
	end
end

function heclCompiler:heclConsume(tokenType : heclTypes.heclTokenType, message : string)
	local compiler : heclCompiler = self;

	if (compiler.current.tokenType == tokenType) then
		compiler:heclAdvance();
		return;
	end
	
	compiler:heclErrorAtCurrent(message);
end

function heclCompiler:heclEmitByte(byte : heclTypes.heclOpCode)
	local compiler : heclCompiler = self;
	
	currentChunk:heclWriteChunk(byte, compiler.previous.line);
end

function heclCompiler:heclEmitBytes(byte1 : heclTypes.heclOpCode, byte2 : heclTypes.heclOpCode)
	local compiler : heclCompiler = self;
	compiler:heclEmitByte(byte1);
	compiler:heclEmitByte(byte2);
end

function heclCompiler:heclEmitReturn()
	local compiler : heclCompiler = self;
	local returnByte : heclTypes.heclOpCode = "OP_RETURN";
	compiler:heclEmitBytes(returnByte);
end

function heclCompiler:heclMakeConstant(value : heclValue.heclValue)
	local compiler : heclCompiler = self;
	local constant = currentChunk:heclAddConstant(value);

	return constant;
end

function heclCompiler:heclEmitConstant(value : heclValue.heclValue)
	local compiler : heclCompiler = self;
	local constantByte : heclTypes.heclOpCode = "OP_CONSTANT";

	compiler:heclEmitBytes(constantByte, compiler:heclMakeConstant(value));
	--compiler:heclEmitByte(constantByte);
end

function heclCompiler:heclExpression()
	local compiler : heclCompiler = self;
	
	compiler:heclParsePrecedence("PREC_ASSIGNMENT");
end

function heclCompiler.heclGrouping(compiler : heclCompiler)
	compiler:heclExpression();
	compiler:heclConsume("TOKEN_RIGHT_PAREN", "Expect ')' after expression.");
end

function heclCompiler.heclUnary(compiler : heclCompiler)
	local prevType : heclTypes.heclTokenType = compiler.previous.tokenType;
	
	compiler:heclParsePrecedence("PREC_UNARY");
	
	if prevType == "TOKEN_BANG" then
		compiler:heclEmitByte("OP_NOT");
	elseif prevType == "TOKEN_MINUS" then
		compiler:heclEmitByte("OP_NEGATE");
	end
end

function heclCompiler.heclBinary(compiler : heclCompiler)
	local operatorType : heclTypes.heclTokenType = compiler.previous.tokenType;
	local rule : heclTypes.heclParseRule = compiler:heclGetRule(operatorType);
	
	local precedence = rule.precedence
	local precedenceVal = precedenceEnums[precedence]
	local nextPrecedence = search[precedenceVal + 1]

	compiler:heclParsePrecedence(nextPrecedence);
	
	if operatorType == "TOKEN_EQUAL_EQUAL" then
		compiler:heclEmitByte("OP_EQUAL");

	elseif operatorType == "TOKEN_NOT_EQUAL" then
		compiler:heclEmitBytes("OP_EQUAL", "OP_NOT");

	elseif operatorType == "TOKEN_PLUS" then
		compiler:heclEmitByte("OP_ADD");

	elseif operatorType == "TOKEN_MINUS" then
		compiler:heclEmitByte("OP_SUBTRACT");

	elseif operatorType == "TOKEN_STAR" then
		compiler:heclEmitByte("OP_MULTIPLY");

	elseif operatorType == "TOKEN_SLASH" then
		compiler:heclEmitByte("OP_DIVIDE");

	elseif operatorType == "TOKEN_GREATER" then
		compiler:heclEmitByte("OP_GREATER");

	elseif operatorType == "TOKEN_GREATER_EQUAL" then
		compiler:heclEmitBytes("OP_LESS", "OP_NOT");

	elseif operatorType == "TOKEN_LESS" then
		compiler:heclEmitByte("OP_LESS");

	elseif operatorType == "TOKEN_LESS_EQUAL" then
		compiler:heclEmitBytes("OP_GREATER", "OP_NOT");

	end
end

function heclCompiler.heclString(compiler : heclCompiler)

end

function heclCompiler.heclNumber(compiler : heclCompiler)
	local fetch = compiler.scanner.instructions:sub(compiler.previous.start, compiler.previous.start + compiler.previous.length - 1);

	local value : number = tonumber(fetch);
	local valueValue : heclValue.heclValue = heclValue.new()
	valueValue.num = value;
	valueValue.heclValueType = "VAL_NUMBER";
	compiler:heclEmitConstant(valueValue);
end

function heclCompiler.heclLiteral(compiler : heclCompiler)
	local prevType : heclTypes.heclTokenType = compiler.previous.tokenType;
	if prevType == "TOKEN_FALSE" then
		compiler:heclEmitByte("OP_FALSE");
	elseif prevType == "TOKEN_NIL" then
		compiler:heclEmitByte("OP_NIL");
	elseif prevType == "TOKEN_TRUE" then
		compiler:heclEmitByte("OP_TRUE");
	end
end

local prec : heclTypes.heclPrecedence = "PREC_ASSIGNMENT"
local tokenRules : {[heclTypes.heclTokenType] : heclTypes.heclParseRule} = {
	["TOKEN_AS"] = {
		prefix = function(compiler : heclCompiler)
			
		end;
		infix = function(compiler : heclCompiler)
			
		end;
		precedence = "PREC_ASSIGNMENT";
	};
	["TOKEN_LEFT_PAREN"] = {
		prefix = heclCompiler.heclGrouping;
		precedence = "PREC_NONE";
	};
	["TOKEN_HECL"] = {
		prefix = heclCompiler.heclGrouping;
		precedence = "PREC_NONE";
	};
	["TOKEN_END_HECL"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_RIGHT_PAREN"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_TRUE"] = {
		prefix = heclCompiler.heclLiteral;
		precedence = "PREC_NONE";
	};
	["TOKEN_FALSE"] = {
		prefix = heclCompiler.heclLiteral;
		precedence = "PREC_NONE";
	};
	["TOKEN_NIL"] = {
		prefix = heclCompiler.heclLiteral;
		precedence = "PREC_NONE";
	};
	["TOKEN_BANG"] = {
		prefix = heclCompiler.heclUnary;
		precedence = "PREC_NONE";
	};
	["TOKEN_MINUS"] = {
		prefix = heclCompiler.heclUnary;
		infix = heclCompiler.heclBinary;
		precedence = "PREC_TERM";
	};
	["TOKEN_PLUS"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_TERM";
	};
	["TOKEN_STAR"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_FACTOR";
	};
	["TOKEN_SLASH"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_FACTOR";
	};
	["TOKEN_SEMI_COLON"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_COLON"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_EQUAL"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_EQUAL_EQUAL"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_EQUALITY";
	};
	["TOKEN_NOT_EQUAL"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_EQUALITY";
	};
	["TOKEN_GREATER"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_COMPARISON";
	};
	["TOKEN_GREATER_EQUAL"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_COMPARISON";
	};
	["TOKEN_LESS"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_COMPARISON";
	};
	["TOKEN_LESS_EQUAL"] = {
		infix = heclCompiler.heclBinary;
		precedence = "PREC_COMPARISON";
	};
	["TOKEN_STRING"] = {
		prefix = heclCompiler.heclString;
		precedence = "PREC_NONE";
	};
	["TOKEN_NUMBER"] = {
		prefix = heclCompiler.heclNumber;
		precedence = "PREC_NONE";
	};
	["TOKEN_RETURN"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_ERROR"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_EOF"] = {
		precedence = "PREC_NONE";
	};
	["TOKEN_IDENTIFIER"] = {
		precedence = "PREC_NONE";
	};
};

function heclCompiler:heclGetRule(tokenType : heclTypes.heclTokenType) : heclTypes.heclParseRule
	return tokenRules[tokenType];
end

function heclCompiler:heclParsePrecedence(precedence : heclTypes.heclPrecedence)
	local compiler : heclCompiler = self;
	compiler:heclAdvance();

	local rule = compiler:heclGetRule(compiler.previous.tokenType);
	local prefixRule = rule.prefix;
	if prefixRule then
		prefixRule(compiler);
	end
	
	while (precedenceEnums[precedence] <= precedenceEnums[compiler:heclGetRule(compiler.current.tokenType).precedence]) do
		compiler:heclAdvance();
		local infixRule = compiler:heclGetRule(compiler.previous.tokenType).infix;
		if infixRule then
			infixRule(compiler);
		end
	end
end

function heclCompiler:heclDeclaration()
	
end

function heclCompiler:heclCompile(source : string, chunk : heclChunk.heclChunk) : Passed
	local compiler : heclCompiler = self;
	local scanner = compiler.scanner;

	scanner.instructions = source;

	currentChunk = chunk;

	compiler.hadError = false;
	compiler.panicMode = false;

	compiler:heclAdvance();
	compiler:heclExpression();
	compiler:heclAdvance();
	
	warn("chunk: ", chunk)
	while not scanner:heclMatch("TOKEN_EOF") do
		compiler:heclDeclaration();
	end
	--compiler:heclConsume("TOKEN_EOF", "Expect end of expression.");
	compiler:heclEmitReturn();
	
	return not compiler.hadError;
end

return heclCompiler;