--[=[
	MIT License
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]=]

--[=[
	Heimdall is an integrated development framework designed to simplify common patterns of development for logic heavy Roblox experiences.

	Heimdall's service design is driven by the principle of providing as much control as possible to developers seeking to create powerful and expressive code.
	This is achieved by providing developers with a wide range of tools to customize and integrate their code with Heimdall's features.
	Heimdall contains:
	1. Objects and wrappers to simplify and organize your experience's module structures and lifetimes in the form of various Service types.
	2. Objects to simplify and aid in parallel luau development (in the form of hdParallelServices)
	3. Built-in objects to override the default Roblox PlayerModule with a completely revamped and exposed one, made with modern code structure and
	fully reformatted.
	4. A structural type system with tons of built-in custom types so that there is no confusion regarding its robust API.
	5. Complete control over the execution flow of the entire experience's code structures, using reusable and simple objects
	6. A false-singleton model allowing you to create different paradigms of Heimdall root objects, allowing for even further structuring and organization
	if desired.
	7. A variety of development utilities and extra objects for common use cases.
	8. Ability to create expressive frameworks which capture the essence of your experience's logic in a single, unified housing.

	@class Heimdall
]=]

--[=[ Heimdall
	The firstmost object needed to initialize the Heimdall framework is the hdObject. You can create 1 or more hdObject on both the client and the server.
	The hdObject is the backbone of the Heimdall framework. It contains the core functionality of the framework, but it is mostly used to bootstrap other core instances.

	@class hdObject
]=]

--[=[ Heimdall Instance
	The most important class by far is the hdInstance object, a namespaced singleton of which there is 1 hdInstance per namespace.
	An hdInstance namespace refers to an identifier passed to the creation method of the hdObject to initialize an hdInstance. For most purposes, namespacing other
	hdInstances in the same hdObject is just an easier way to reuse an hdObject.

	@class hdInstance
]=]

--[=[ Protected Code

	Most core Heimdall classes emit a custom type of error handled result with their methods, known as an hdProtectedCallResult.
	This is a custom type of table that when converted to a string can either be HD_SUCCESS or HD_FAILURE.
	It contains a numeric field which can also be used to read the result by comparing it to the hdEnums file.

	```luau
	local hdResult, ... = heimdallPsuedoObject:fooBar(...);
	if hdResult.ProtectedCallResult ~= hdEnums.hdProtectedCallResults.Passed.Value then
		error("failed to foo the bar!");
		return;
	end
	```

	The above psuedo code displays an example of luau code which uses this custom type with the manual checking method.
	However, you can also quickly check a boolean result if you are not interested in the reason for the HD_FAILURE being thrown,
	which is passed as custom metadata used by other Heimdall classes, like so:
	```luau
	local hdResult, ... = heimdallPsuedoObject:fooBar(...);
	if not hdResult.Passed then
		error("failed to foo the bar!");
		return;
	end
	```

	@type hdProtectedCallResult
		@within hdProtectedCallResult
			@prop ProtectedCallResult number
				@readonly
				@tag Enum
			@prop Passed boolean
				@readonly
			@prop Traceback string
				@readonly
			@prop ErrorString string
				@readonly
			@prop FailureType string
				@readonly
]=]

--[=[ Heimdall Service Manager
	The hdServiceManager object is instantiated within the hdInstance object, and automatically stored into its internal registry.
	This object should be created and used to compile the hdServices contained inside the current environment (client or server).
	This object is a singleton.
	After compiling the services with hdCompileServices, you should create an hdCommandChain to execute callbacks on the new data.

	@class hdServiceManager
]=]

--[=[ Heimdall Commands, or Dynamic Module Callbacks
	An hdCommand is a custom string type in the Heimdall environment that defines a callback that is executed on some arbitrary array containing
	the explicitly named function.

	The hdCommandChain object is responsible for executing hdCommands based on the passed hdCommandInfo.
	It contains a field, of type hdCommandedStruct, which contains a list of arrays containing functions (for example, your compiled hdServices).
	hdCommandChains can execute commands based on the hdCommandInfo in various ways:
	1. HD_CMD_INVOC_TYPE_ASYNC
		- The command chain will thread the command execution and return immediately, with no yielding.
	2. HD_CMD_INVOC_TYPE_SYNC
		- The command chain will execute each command 1 by 1 in serial and will yield.
	3. HD_CMD_INVOC_TYPE_MIXED
		- The command chain will create a synchronization object per array and will thread each array per command, but use the hdFence object to ensure that
		all arrays return a result before moving onto the next command in the chain.

	The following sample code demonstrates an example of using the hdCommandChain to execute a "Boot" command on a list of hdServices:
	```lua
	-- first define the paramaters with an hdCommandChainCreateInfo
	local hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo = {
		-- defines the arrays which commands will be performed on
		commandedStructs = hdServiceManager:hdGetServices();

		-- defines details about which commands to execute, and how to execute them
		commandInfo = {
			name = "Startup";
			commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
			commandInvocationType = "HD_CMD_INVOC_TYPE_ASYNC";
			commands = {
				"HD_COMP";
				"HD_BOOT";
				"HD_STRT";
			};
		};

		-- contained for reuse and safe execution
		debugMessenger = hdDebugMessenger;
	};

	-- create the command chain:
	local hdResult, hdCommandChain = hdServiceManager:hdCreateCommandChain(hdCommandChainCreateInfo);
	if not hdResult.Success then
		error("failed to create command chain!");
		return;
	end

	--// Now that the hdServiceManager has been successfully initialized, we can invoke its command chain to boot all the experience services!
	--// The hdCommandChain allows us to overwrite arrays of instructions for the hdServiceManager, so we will re-use this hdCommandChain object later on when we
	--// need to call more commands on all services at once.
	local hdFenceCreateInfo : hdTypes.hdFenceCreateInfo = {
		fenceInitialState = "HD_FENCE_UNSIGNALED";
	};

	local hdResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain);
	if not hdResult.Success then
		error("failed to boot services!");
		return;
	end
	```

	:::WARNING
	The hdCommandChain has an internal hdCommandChainState which can either be of value HD_COMMAND_CHAIN_STATE_BUSY or HD_COMMAND_CHAIN_STATE_FREE.

	Always check the hdCommandChainState before attempting to run commands, as a busy command chain will not accept an invoke.
	Attempting to invoke a busy command chain will throw an error with the heimdall error enum value HD_COMMAND_CHAIN_BUSY
	:::

	@class hdCommandChain
]=]

--[=[ Scenes
	A Scene is a theoretical model describing a place or setting within the Roblox workspace seperate from the "main" world.
	For example, if you were creating the an identical location 5 times for 5 players, but want them to each have their own instance of that place,
	you would easily achieve this with the built-in hdScene and its various helper objects.

	In order to allow any type of character to interact with an hdScene, you need to wrap characters in an hdSceneParticipant object. This will allow them to interact
	with other hdScene related objects to use the Scene.

	hdSceneParticipants need one or more entry point(s) into the Scene, which can be achieved with the hdSceneHandle object. This acts as a "portal" into the Scene,
	defining where participants could enter and exit.

	When you have an hdSceneParticipant and an hdSceneHandle, you can use an hdSceneWarper to perform the transformation. Due to anticipating the design constraints of
	developers, the Scene Warper object is designed to allow a custom callback in case you need special logic to transform characters (For example, physical constraints don't
	teleport all constituent objects when you move the humanoid root part of a character, so if you attached a part via ballsocket constraint, it might be left behind.)

	@class hdScene
]=]

--[=[ Components
	Heimdall is designed to be extremely modular, allowing developers to pick and choose which components they want to use in their experiences.
	It comes with a core class called the hdComponent class, which act as a sort of "data instance"-- By this we mean you can use them to describe any object in your experience.

	For example, if you wanted to create a door, you would create an hdComponent called "Door" and attach it to a part in your experience.
	Then, you would use the hdComponent's API to modify the door's state, allowing it to open and close.

	On their own, hdComponents aren't very useful. But when combined with the hdService class, you can generate behavior and act on components en masse, vastly reducing the
	difficulty of achieving non-repetitive code that is extensible and data driven.

	While components do provide extremely powerful data-driven coding models, they have some limitations.
	For one, hdComponents only represent code and only exist in the Heimdall environment, being unaccessible to any outside actor.
	Secondly, assembling hdComponents around Roblox instances can be tricky.
	Finally, hdComponents have some data limitations around buffers: due to how they are designed, they are stored as high-performance buffer objects in binary data.

	@class hdComponent
]=]

--[=[ Entity Composition Language
	The Heimdall Entity Composition Language is a way of describing entities and their constituent components using Heimdall's interface.
	An example of the Heimdall Entity Composition Language (HECL) in use:
	```luau

	local instructions = [[
		hecl:
			return makeEntity:
				with:
					hdComponent:
						from : hdToolbox:hdGetComponent : "myComponent1";
					hdComponent:
						from : hdToolbox:hdGetComponent : "myComponent2";
				in:
					hdInstance;
				bornFrom:
					player;
		endhecl;
	]]
	local entity = hdInstance:toHECL(instructions);
	```
]=]

return {};