local hecl = script.Parent.Parent.Parent;
local heclLib = hecl.src.lib;
local heclTypes = require(heclLib.heclTypes);
local heclClasses = hecl.src.classes;

local heclValue = require(heclClasses.heclValue);

local heclChunk = {};
heclChunk.__index = heclChunk;

export type heclChunk = typeof(setmetatable({} :: {
	count : number;
	capacity : number;
	code : heclTypes.heclOpCode;
	lines : {number};
	constants : {heclValue.heclValue};
}, {} :: typeof(heclChunk)));

function heclChunk.new(heclChunkCreateInfo :heclTypes.heclChunkCreateInfo) : heclChunk
	local chunk = setmetatable({}, heclChunk);

	chunk:heclInitChunk()

	return chunk;
end

function heclChunk:heclInitChunk()
	local chunk : heclChunk = self;
	chunk.count = 0;
	chunk.capacity = 0;
	chunk.code = {};
	chunk.lines = {};
	chunk.constants = {};
end

function heclChunk:heclFreeChunk()
	local chunk : heclChunk = self;
	table.clear(chunk.code);
	table.clear(chunk.lines);
	for i, v in chunk.constants do
		table.clear(v)
		chunk.constants[i] = nil
	end

	chunk:heclInitChunk()
end

function heclChunk:heclWriteChunk(byte : heclTypes.heclOpCode, line : number)
	local chunk : heclChunk = self;
	
	table.insert(chunk.code, byte);
	table.insert(chunk.lines, line);
	chunk.count += 1;
end

function heclChunk:heclAddConstant(value : heclValue.heclValue) : number
	local chunk : heclChunk = self;
	table.insert(chunk.constants, value);
	
	return #chunk.constants
end

function heclChunk:heclGetConstant(constantIndex : number)
	local chunk : heclChunk = self;
	
	return chunk.constants[constantIndex];
end

return heclChunk;