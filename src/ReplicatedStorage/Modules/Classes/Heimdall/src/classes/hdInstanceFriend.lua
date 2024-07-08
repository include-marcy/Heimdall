--!strict
local hdTrove = require(script.Parent.Parent.packages.trove);
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

local hdInstanceFriend = {};
hdInstanceFriend.__index = hdInstanceFriend;

export type hdInstanceFriend = typeof(setmetatable({} :: {
	friend : Instance;
	friendTrove : typeof(setmetatable({} :: {}, {} :: typeof(hdTrove)));
}, {} :: typeof(hdInstanceFriend)));

--[=[
	Creates an hdInstanceFriend, a helper object which is designed around the following example problem:

	- Say you want to define some kind of behavior or objects that are tied to a player/character, ROBLOX instances or not.
	- Say you also want to ensure that those objects get properly destroyed at exactly the same time as the character/player,
	not an uncommon thing in ROBLOX games.
	- Enter the hdInstanceFriend, a value that could be returned by certain hdService callbacks to facilitate this use case
	with minimal friction.
	
	All you have to do is define a new CharacterAdded callback in your hdService, and then return an hdInstanceFriend from that
	callback to make a new cleanup object that also contains a trove.
	
	```luau
	function fooService:CharacterAdded(character : Model) : hdInstanceFriend.hdInstanceFriend
		local hdInstanceFriendCreateInfo : hdTypes.hdInstanceFriendCreateInfo = {
			instance = character;
		};
		local hdInstanceFriend = hdInstanceFriend.new(hdInstanceFriendCreateInfo);
		
		local myObject = hdInstanceFriend:Create(myClass);
		-- ^ with this line, myObject will be :Destroy()'ed when "character" is parented to nil (destroyed).
		
		return hdInstanceFriend
	end
	```

	With this pattern, we now have no reason to include a CharacterRemoving callback to any service, reducing grand-scheme code complexity and improving
	understandability.

	@param hdInstanceFriendCreateInfo;
	@return hdInstanceFriend;
]=]
function hdInstanceFriend.new(hdInstanceFriendCreateInfo : hdTypes.hdInstanceFriendCreateInfo) : hdInstanceFriend
	local instanceFriend = setmetatable({}, hdInstanceFriend);
	
	local friend = hdInstanceFriendCreateInfo.instance;
	instanceFriend.friend = friend;
	instanceFriend.friendTrove = hdTrove.instanceTrove(friend);

	return instanceFriend;
end

--[=[
	Acts as a factory for any passed object, automatically calling .new(), and then including it in this hdInstanceFriend's cleanup list.

	@param Object {.new(), :Destroy()};
]=]
function hdInstanceFriend:Create(Object : any)
	local instanceFriend : hdInstanceFriend = self;
	return instanceFriend.friendTrove:Construct(Object);
end

--[=[
	Adds the given object for cleanup (May be luau objects or ROBLOX instances)

	@param ... (anything with a cleanup ":Disconnect()" or ":Destroy()")
]=]
function hdInstanceFriend:Add(...)
	local instanceFriend : hdInstanceFriend = self;
	return instanceFriend.friendTrove:Add(...);
end

return hdInstanceFriend;