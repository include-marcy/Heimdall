-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTrove = require(script.Parent.Parent.packages.trove);
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
local hdWrapping = {};
hdWrapping.__index = hdWrapping;

export type hdWrapping = typeof(setmetatable({} :: {
	friend : Instance;
	friendTrove : typeof(setmetatable({} :: {}, {} :: typeof(hdTrove)));
}, {} :: typeof(hdWrapping)));

--[=[
	@class hdWrapping
	Creates an hdWrapping, a helper object which is designed around the following example problem:

	- Say you want to define some kind of behavior or objects that are tied to a player/character, ROBLOX instances or not.
	- Say you also want to ensure that those objects get properly destroyed at exactly the same time as the character/player,
	not an uncommon thing in ROBLOX games.
	- Enter the hdWrapping, a value that could be returned by certain hdService callbacks to facilitate this use case
	with minimal friction.

	All you have to do is define a new CharacterAdded callback in your hdService, and then return an hdWrapping from that
	callback to make a new cleanup object that also contains a trove.

	```luau
	function fooService:CharacterAdded(character : Model) : hdWrapping.hdWrapping
		local hdWrappingCreateInfo : hdTypes.hdWrappingCreateInfo = {
			instance = character;
		};
		local hdWrapping = hdWrapping.new(hdWrappingCreateInfo);

		local myObject = hdWrapping:Create(myClass);
		-- ^ with this line, myObject will be :Destroy()'ed when "character" is parented to nil (destroyed).

		return hdWrapping
	end
	```

	With this pattern, we now have no reason to include a CharacterRemoving callback to any service, reducing grand-scheme code complexity and improving
	understandability.

	@param hdWrappingCreateInfo;
	@return hdWrapping;
]=]
function hdWrapping.new(hdWrappingCreateInfo : hdTypes.hdWrappingCreateInfo) : hdWrapping
	local Wrapping = setmetatable({}, hdWrapping);

	local friend = hdWrappingCreateInfo.instance;
	Wrapping.friend = friend;
	Wrapping.friendTrove = hdTrove.instanceTrove(friend);

	return Wrapping;
end

--[=[
	@class hdWrapping
	Acts as a factory for any passed object, automatically calling .new(), and then including it in this hdWrapping's cleanup list.

	@param Object {.new(), :Destroy()};
]=]
function hdWrapping:Create(Object : any, ...)
	local Wrapping : hdWrapping = self;
	return Wrapping.friendTrove:Construct(Object, ...);
end

--[=[
	@class hdWrapping
	Adds the given object for cleanup (May be luau objects or ROBLOX instances)

	@param ... (anything with a cleanup ":Disconnect()" or ":Destroy()")
]=]
function hdWrapping:Add(...)
	local Wrapping : hdWrapping = self;
	return Wrapping.friendTrove:Add(...);
end

return hdWrapping;