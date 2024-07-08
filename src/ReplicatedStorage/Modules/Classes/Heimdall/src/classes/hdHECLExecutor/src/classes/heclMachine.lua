local hecl = script.Parent.Parent.Parent;
local heclLib = hecl.src.lib;
local heclTypes = require(heclLib.heclTypes);
local heclClasses = hecl.src.classes;

local heclValue = require(heclClasses.heclValue);
local heclObject = require(heclClasses.heclObject);
local heclChunk = require(heclClasses.heclChunk);
local heclCompiler = require(heclClasses.heclCompiler);

local heclMachine = {};
heclMachine.__index = heclMachine;

export type heclMachine = typeof(setmetatable({} :: {
	_chunk : heclChunk.heclChunk;
	_indexPointer : number;
	_stack : {heclValue.heclValue};
	_stackTop : number;
	_objs : {heclObject.heclObject};
	_env : {[string] : any};
	_compiler : heclCompiler.heclCompiler;
}, {} :: typeof(heclMachine)));
export type heclInterpretResult = "HECL_INTERPRET_OK" | "HECL_COMPILE_ERROR" | "HECL_RUNTIME_ERROR";

local STACK_MAX = 256;

local function READ_CONSTANT(machine)
	return machine._chunk.constants[machine:heclReadByte()]
end

local function READ_VAR(machine)
	return machine._env[machine:heclReadByte()]
end

local function WRITE_VAR(machine, varName, varValue)
	
end

local function IS_NUMBER(value : heclValue.heclValue)
	if not value then
		return false;
	end
	if (value.heclValueType ~= "VAL_NUMBER") then
		return false;
	end

	return true;
end

local function IS_BOOL(value : heclValue.heclValue)
	if not value then
		return false;
	end
	if (value.heclValueType ~= "VAL_BOOL") then
		return false;
	end
	
	return true;
end

local function AS_NUMBER(machine, value : heclValue.heclValue)
	if not IS_NUMBER(value) then
		machine:heclRuntimeError("Cannot convert non-number to number!");
		return "HECL_RUNTIME_ERROR";
	end
	return value.num;
end

local function AS_BOOL(machine, value : heclValue.heclValue)
	if not IS_BOOL(value) then
		machine:heclRuntimeError("Cannot convert non-bool to bool!");
		return "HECL_RUNTIME_ERROR";
	end
	
	return value.boolean;
end

local function VALUE_CONSTRUCT(valueType : heclTypes.heclValueType) : heclValue
	local value = heclValue.new();
	value.heclValueType = valueType;
	return value;
end

local function BINARY_OPERATOR(machine, valueConstructor : (heclTypes.heclValueType) -> (heclValue.heclValue), operator) : heclInterpretResult
	if not (IS_NUMBER(machine:heclPeek(1)) or not IS_NUMBER(machine:heclPeek(2))) then
		machine:heclRuntimeError("Operands must be two numbers!");
		return "HECL_RUNTIME_ERROR"; 
	end

	local a = AS_NUMBER(machine, machine:heclPop());
	local b = AS_NUMBER(machine, machine:heclPop());

	machine:heclPush(valueConstructor(operator(b, a)))
end

local function DEBUG_TRACE_EXECUTION()

end

local function NIL_VAL() : heclValue.heclValue
	local value = heclValue.new();
	value.num = 0;
	return value;
end

local function BOOL_VAL(boolean : boolean) : heclValue.heclValue
	local value = heclValue.new();
	value.boolean = boolean;
	value.heclValueType = "VAL_BOOL";
	return value;
end

local function NUMBER_VAL(number : number) : heclValue.heclValue
	local value = heclValue.new();
	value.num = number;
	value.heclValueType = "VAL_NUMBER";
	return value;
end


function heclMachine.new() : heclMachine
	local machine = setmetatable({}, heclMachine);

	machine._indexPointer = 0;
	machine._stack = table.create(STACK_MAX);
	machine._stackTop = 1;
	machine._objs = {};
	machine._env = {};
	machine._compiler = heclCompiler.new();

	return machine;
end

function heclMachine:heclInitMachine()
	local machine : heclMachine = self;
	
	machine:heclResetStack();
	machine._objs = {};
end

function heclMachine:heclFreeMachine()
	local machine : heclMachine = self;
	
	machine:heclFreeObjects();
end

function heclMachine:heclResetStack()
	local machine : heclMachine = self;
	
	machine._stackTop = 1;
end

function heclMachine:heclFreeObjects()
	local machine : heclMachine = self;
end

function heclMachine:heclValuesEqual(A : heclValue.heclValue, B : heclValue.heclValue)
	if A.heclValueType ~= B.heclValueType then
		return false;
	end

	if A.heclValueType == "VAL_BOOL" then
		local AVal = AS_BOOL(self, A);
		local BVal = AS_BOOL(self, B);
		warn(AVal, BVal)
		return AVal == BVal;
	elseif A.heclValueType == "VAL_NIL" then
		return true;
	elseif A.heclValueType == "VAL_NUMBER" then
		return AS_NUMBER(self, A) == AS_NUMBER(self, B);
	end
end

function heclMachine:heclPush(value : heclValue.heclValue)
	local machine : heclMachine = self;
	if (machine._stackTop >= STACK_MAX) then
		return false;
	end

	machine._stack[machine._stackTop] = value;
	machine._stackTop += 1;

	return true;
end

function heclMachine:heclPop() : heclValue.heclValue
	local machine : heclMachine = self;
	if (machine._stackTop <= 0) then
		return nil;
	end
	
	machine._stackTop -= 1;
	
	local pop = machine._stack[machine._stackTop];
	machine._stack[machine._stackTop] = nil;

	return pop
end

function heclMachine:heclPeek(depth : number) : heclValue.heclValue
	local machine : heclMachine = self;
	if (machine._stackTop - depth) <= 0 then
		return nil;
	end
	
	return machine._stack[machine._stackTop - depth];
end

function heclMachine:heclReadByte() : heclTypes.heclOpCode
	local machine : heclMachine = self;
	local byte = machine._chunk.code[machine._indexPointer];
	machine._indexPointer += 1;
	
	return byte;
end

function heclMachine:heclRuntimeError(message : string)
	local machine : heclMachine = self;
	warn(message);
	
	--local instruction = machine._indexPointer - machine._chunks
	return;
end

function heclMachine:heclRun() : heclInterpretResult
	local machine : heclMachine = self;

	while machine._indexPointer <= #machine._chunk.code do
		local instruction : heclTypes.heclOpCode = machine:heclReadByte();

		if instruction == "OP_CONSTANT" then
			local Constant : heclValue.heclValue = READ_CONSTANT(machine);
			machine:heclPush(Constant);
		elseif instruction == "OP_NIL" then
			machine:heclPush(NIL_VAL());
		elseif instruction == "OP_TRUE" then
			machine:heclPush(BOOL_VAL(true));
		elseif instruction == "OP_FALSE" then
			machine:heclPush(BOOL_VAL(false));
		elseif instruction == "OP_EQUAL" then
			local A : heclValue.heclValue = machine:heclPop();
			local B : heclValue.heclValue = machine:heclPop();
			
			machine:heclPush(BOOL_VAL(machine:heclValuesEqual(A, B)));
		elseif instruction == "OP_GREATER" then
			BINARY_OPERATOR(machine, BOOL_VAL, function(a, b)
				return a > b;
			end);
		elseif instruction == "OP_LESS" then
			BINARY_OPERATOR(machine, BOOL_VAL, function(a, b)
				return a < b;
			end);
		elseif instruction == "OP_ADD" then
			BINARY_OPERATOR(machine, NUMBER_VAL, function(a, b)
				return a + b;
			end);
		elseif instruction == "OP_SUBTRACT" then
			BINARY_OPERATOR(machine, NUMBER_VAL, function(a, b)
				return a - b;
			end);
		elseif instruction == "OP_MULTIPLY" then
			BINARY_OPERATOR(machine, NUMBER_VAL, function(a, b)
				return a * b;
			end);
		elseif instruction == "OP_DIVIDE" then
			BINARY_OPERATOR(machine, NUMBER_VAL, function(a, b)
				return a / b;
			end);
		elseif instruction == "OP_NOT" then
			local value = machine:heclPop();
			local asBool = AS_BOOL(machine, value)
			warn(asBool)
			machine:heclPush(BOOL_VAL(not asBool));
		elseif instruction == "OP_NEGATE" then
			if not (IS_NUMBER(machine:heclPeek(0))) then
				machine:heclRuntimeError("Operand must be a number!");
				return "HECL_RUNTIME_ERROR";
			end

			machine:heclPush(NUMBER_VAL(-AS_NUMBER(machine, machine:heclPop())))
		elseif instruction == "OP_READ" then
			
		elseif instruction == "OP_WRITE" then
			
		
		elseif instruction == "OP_RETURN" then
			return "HECL_INTERPRET_OK", machine._stack
		end
	end

	return "HECL_RUNTIME_ERROR";
end

function heclMachine:heclInterpret(source : string) : heclInterpretResult
	local machine : heclMachine = self;
	local startClock = os.clock();
	local chunk = heclChunk.new({});
	
	if not machine._compiler:heclCompile(source, chunk) then
		warn("erm...")
		chunk:heclFreeChunk();
		return "HECL_COMPILE_ERROR";
	end
	
	machine._chunk = chunk;
	machine._indexPointer = 1;
	
	local result : heclInterpretResult, stack = machine:heclRun();
	
	local registerOp = ""
	for _, regValue : heclValue.heclValue in stack do
		registerOp = registerOp .. "\n						" .. regValue.heclValueType .. " :: " .. regValue:heclDeconstruct();
	end
	
	local Time = string.format("%.6f", (os.clock() - startClock));
	print("\n-------------------------" .. "\n" .. "Source: \n", source, "\n", `Compiled in: {Time} seconds\n-------------------------`);
	warn("HECL: \n	\ Register: ", registerOp)
	
	chunk:heclFreeChunk();
	return result;
end

return heclMachine;