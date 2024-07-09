local hecl = script.Parent.Parent.Parent;
local heclLib = hecl.src.lib;
local heclTypes = require(heclLib.heclTypes);

local heclScanner = {};
heclScanner.__index = heclScanner;

export type heclScanner = typeof(setmetatable({} :: {
	start : number,
	current : number,
	line : number,
	instructions : string,
}, {} :: typeof(heclScanner)));

function heclScanner.new(heclScannerCreateInfo : heclTypes.heclScannerCreateInfo) : heclScanner
	local scanner = setmetatable({}, heclScanner);
	
	scanner.start = 0;
	scanner.current = 1;
	scanner.line = 1;
	scanner.instructions = '';
	
	return scanner;
end

function heclScanner:heclErrorToken(message : string) : heclTypes.heclToken
	local token : heclTypes.heclToken = {
		tokenType = "TOKEN_ERROR";
		start = message;
		length = string.len(message);
		line = self.line
	};
	
	return token;
end

function heclScanner:heclIsAlpha(c)
	return (c >= "a" and c <= "z") or (c >= "A" and c <= "Z");
end

function heclScanner:heclIsDigit(c)
	return c >= "0" and c <= "9";
end

function heclScanner:heclIsAtEnd()
	return self.current >= #self.instructions;
end

function heclScanner:heclAdvance() : string
	self.current = self.current + 1;

	local currentLexeme : string = self.instructions:sub(self.current, self.current);

	return currentLexeme;
end

function heclScanner:heclScanInstructions(instructions)
	self.instructions = instructions;
	self.current = 1;
	self.start = 0;
	self.line = 1;
end

function heclScanner:heclCheckKeyword(start : number, length : number, rest : string, tokenType : heclTypes.heclTokenType) : heclTypes.heclTokenType
	local scanner : heclScanner = self;
	if (scanner.current - scanner.start == start + length) and 
		(scanner.instructions:sub(scanner.start + start, scanner.start + start + length - 1) == rest)
	then
		return tokenType;
	end
	
	return "TOKEN_IDENTIFIER";
end

function heclScanner:heclGetIdentifierType() : heclTypes.heclTokenType
	local scanner : heclScanner = self;
	local c = scanner.instructions:sub(scanner.start, scanner.start);

	if c == "h" then
		return scanner:heclCheckKeyword(1, 3, "ecl", "TOKEN_HECL");
	elseif c == "m" then
		return scanner:heclCheckKeyword(1, 3, "ake", "TOKEN_MAKE");
	elseif c == "a" then
		return scanner:heclCheckKeyword(1, 1, "s", "TOKEN_AS");
	elseif c == "d" then
		if scanner.current - scanner.start > 1 then
			local n = scanner.instructions:sub(scanner.start + 2, scanner.start + 2);
			if n == "f" then
				return scanner:heclCheckKeyword(1, 2, "ef", "TOKEN_TYPE_DEF");
			elseif n == "c" then
				return scanner:heclCheckKeyword(1, 6, "eclare", "TOKEN_DECLARE");
			end
		end
	elseif c == "w" then
		return scanner:heclCheckKeyword(1, 3, "ith", "TOKEN_WITH");
	elseif c == "c" then
		return scanner:heclCheckKeyword(1, 8, "omponent", "TOKEN_COMPONENT");
	elseif c == "r" then
		return scanner:heclCheckKeyword(1, 5, "eturn", "TOKEN_RETURN");
	elseif c == "e" then
		return scanner:heclCheckKeyword(1, 6, "ndhecl", "TOKEN_END_HECL");
	elseif c == "t" then
		return scanner:heclCheckKeyword(1, 3, "rue",  "TOKEN_TRUE");
	elseif c == "f" then
		return scanner:heclCheckKeyword(1, 4, "alse", "TOKEN_FALSE");
	elseif c == "n" then
		return scanner:heclCheckKeyword(1, 2, "il", "TOKEN_NIL");
	end
	
	return "TOKEN_IDENTIFIER";
end

function heclScanner:heclGetIdentifierToken() : heclTypes.heclToken
	while (self:heclIsAlpha(self:heclPeek()) or self:heclIsDigit(self:heclPeek())) do
		self:heclAdvance();
	end
	
	local identifierType = self:heclGetIdentifierType();

	return self:heclMakeToken(identifierType);
end

function heclScanner:heclPeek()
	return self.instructions:sub(self.current, self.current);
end

function heclScanner:heclPeekNext() : string
	if self:heclIsAtEnd() then
		return '\0';
	end

	return self.instructions:sub(self.current + 1, self.current + 1);
end

function heclScanner:heclMatch(expected)
	local scanner : heclScanner = self;
	if (scanner:heclIsAtEnd()) then
		return false;
	end

	if (scanner:heclPeek() ~= expected) then
		return false
	end
	scanner.current += 1
	return true
end

function heclScanner:heclSkipWhitespace()
	local Skips = 0
	while true do
		local c = self:heclPeek();

		if c == "" or c == " " or c == "\r" or c == "\t" or c:byte() == 32 then
			Skips += 1
			self:heclAdvance();
		elseif c == "\n" or c:byte() == 0x010 then
			self.line += 1;
			Skips += 1
			self:heclAdvance();
		elseif c == "/" then
			if (self:heclPeekNext() == "/") then
				while (self:heclPeek() ~= "\n" and not self:heclIsAtEnd()) do
					self:heclAdvance();
					Skips += 1
				end
			else
				return Skips
			end
		else
			return Skips
		end
	end
	
	return Skips
end

function heclScanner:heclMakeToken(tokenType : heclTypes.heclTokenType) : heclTypes.heclToken
	local token : heclTypes.heclToken = {
		tokenType = tokenType;
		start = self.start;
		length = self.current - self.start;
		line = self.line
	}
	
	return token
end

function heclScanner:heclGetNumberToken() : heclTypes.heclToken
	while self:heclIsDigit(self:heclPeek()) do
		self:heclAdvance();
	end
	
	if (self:heclPeek() == "." and self:heclIsDigit(self:heclPeekNext())) then
		warn("Extra")
		self:heclAdvance();

		while self:heclIsDigit(self:heclPeek()) do
			self:heclAdvance();
		end
	end
	
	return self:heclMakeToken("TOKEN_NUMBER");
end

function heclScanner:heclGetStringToken() : heclTypes.heclToken
	while (self:heclPeek() ~= "\"") do
		if self:heclIsAtEnd() then
			return self:heclErrorToken("Unterminated string.");
		end
		self:heclAdvance();
	end
	self:heclAdvance();

	return self:heclMakeToken("TOKEN_STRING");
end

function heclScanner:heclScanToken() : heclTypes.heclToken
	local scanner : heclScanner = self;
	if scanner:heclIsAtEnd() then
		return scanner:heclMakeToken("TOKEN_EOF");
	end

	local SkippedCharacters = scanner:heclSkipWhitespace();
	scanner.start = scanner.current;
	

	
	local c : string = scanner:heclPeek();

	if (scanner:heclIsAlpha(c)) then
		return scanner:heclGetIdentifierToken();
	end
	if (scanner:heclIsDigit(c)) then
		return scanner:heclGetNumberToken();
	end
	
	scanner:heclAdvance()

	local switch = {
		["("] = function()
			return scanner:heclMakeToken("TOKEN_LEFT_PAREN");
		end;
		[")"] = function()
			return scanner:heclMakeToken("TOKEN_RIGHT_PAREN");
		end;
		[";"] = function()
			return scanner:heclMakeToken("TOKEN_SEMI_COLON");
		end;
		[":"] = function()
			return scanner:heclMakeToken("TOKEN_COLON");
		end;
		["="] = function()
			if scanner:heclMatch("=") then
				return scanner:heclMakeToken("TOKEN_EQUAL_EQUAL");
			else
				return scanner:heclMakeToken("TOKEN_EQUAL");
			end
		end;
		["+"] = function()
			return scanner:heclMakeToken("TOKEN_PLUS");
		end,
		["\""] = function()
			return scanner:heclGetStringToken();
		end;
		["!"] = function()
			if scanner:heclMatch("=") then
				return scanner:heclMakeToken("TOKEN_NOT_EQUAL");
			else
				return scanner:heclMakeToken("TOKEN_BANG");
			end
		end;
		["-"] = function()
			return scanner:heclMakeToken("TOKEN_MINUS");
		end;
		["*"] = function()
			return scanner:heclMakeToken("TOKEN_STAR");
		end;
		["/"] = function()
			return scanner:heclMakeToken("TOKEN_SLASH");
		end;
		["<"] = function()
			if scanner:heclMatch("=") then
				return scanner:heclMakeToken("TOKEN_GREATER_EQUAL");
			else
				return scanner:heclMakeToken("TOKEN_GREATER");
			end
		end;
		[">"] = function()
			if scanner:heclMatch("=") then
				return scanner:heclMakeToken("TOKEN_LESS_EQUAL");
			else
				return scanner:heclMakeToken("TOKEN_LESS");
			end
		end;
	};
	--
	local func = switch[c];
	if func then
		return func();
	end
	--
	return scanner:heclErrorToken("Unexpected character.");
end

return heclScanner;