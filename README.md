![HeimdallTextLogo](assets/HeimdallTextDropShadow-2.png)
![DOCS](https://img.shields.io/badge/latest_release-v1.0.0-blue?style=flat-square&logo=Roblox%20Studio)  ![Non-Production](https://img.shields.io/badge/production-no-red?style=flat-square&logo=Roblox%20Studio)
# What is Heimdall? 
Heimdall (ˈhaɪmdɔl) is a Roblox Experience Framework and API (Application Program Interface) for the ©2024 Roblox Studio software. Heimdall is designed to build high-performing applications, providing a standardized way to create and develop services and utilize parallel features of its native language, [Luau](https://github.com/luau-lang/luau). Heimdall users benefit from its explicit API, which seeks to offer them ultimate control over the execution and control flow of their experience.

# Overview of Heimdall API
The Heimdall API provides a series of objects that each provide their own methods and properties, and each usually requires an `<hdObjectType>CreateInfo` argument. Heimdall's API is strictly typed and it is recommended to enable the `--!strict` Luau fast flag in all implementations. Include the type header file in your source code to take advantage of the many built-in types by requiring the `lib.hdTypes` module. We also recommend compiling in native with the `--!native`[^1] Luau fast flag for further boosts to performance. Finally, if build times are not a concern, we recommend enabling the `--!optimize 2` Luau dynamic fast flag to get consistent Luau code generation with production builds, reducing inconsistencies between developer builds and live builds.

# Installation
Currently, there are no public releases which are recommended for installation. This framework is under development.

# Initialization
To initialize Heimdall, create a single[^2] object on both the client and server —that being the `hdObject` singleton— as the base of your application.
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage");
--...
--// Dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
-- ...
--// Creating the hdObject, or "Heimdall Instance", so to speak.
local hdObjectCreateInfo : hdTypes.hdObjectCreateInfo = {};
local hdObject : Heimdall.hdObject = Heimdall.new(hdObjectCreateInfo);
```
From this hdObject we can create various other framework integral components and give birth to our experience's `hdServices`, the class that drives the framework.
```lua
local hdDebugMessengerCreateInfo : hdTypes.hdDebugMessengerCreateInfo = {
	name = "generalDebug";
	middleware = function(f : string, hdResult : hdTypes.hdProtectedCallResult, ...) -- a callback that executes when any Heimdall safe function is invoked.
		--warn(f, hdResult, ...);
	end;
	onError = function(f : string, hdResult : hdTypes.hdProtectedCallResult) -- a callback that executes when a Heimdall failure is raised.
		warn(f);
	end;
};
local hdDebugMessenger = hdObject:hdCreateDebugMessenger(hdDebugMessengerCreateInfo);

--// Then, create the Heimdall base instance.
local hdInstanceCreateInfo : hdTypes.hdInstanceCreateInfo = {
	debugMessenger = hdDebugMessenger;
};
local hdInstance = hdObject:hdCreateInstance(hdInstanceCreateInfo);

--// The next step in the Heimdall initialization process is the hdServiceManager and all of its dependency services.
--// We create the hdServiceManager with the following commands:
local hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo = {
	services = ReplicatedStorage.Modules.Services;
	debugMessenger = hdDebugMessenger;
};
local hdResult, hdServiceManager = hdInstance:hdCreateServiceManager(hdServiceManagerCreateInfo);
if not hdResult.Success then
	error("failed to create service manager!");
	return;
end
```
With these objects in place, you can now fetch and initialize the experience services like so:
```lua
local hdCompileServicesInfo : hdTypes.hdCompileServicesInfo = {};
hdCompileServicesInfo.timeOut = 30;
local hdCompileServicesResult = hdServiceManager:hdCompileServices(hdCompileServicesInfo);

if not hdCompileServicesResult.Success then
	error("failed to compile services!");
	return;
end
--// As long as that has succeeded, we can move on safely.

--// After creating the hdServiceManager, we need an hdCommandChain which our hdServiceManager will use to execute commands to our hdServices.
--local userhdCommandChainFunctionMap : hdTypes.hdCommandChainFunctionMap = {
--	HD_BOOT = "BootUser";
--	HD_COMP = "CompileUser";
--	HD_STRT = "StartUser";
--}

local hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo = {
	commandedStructs = hdServiceManager:hdGetServices();
	commandDirection = "HD_COMMAND_DIRECTION_LOWEST_FIRST";
	commandInfo = {
		name = "Startup";
		commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
		commandInvocationType = "HD_CMD_INVOC_TYPE_ASYNC";
		commands = {
			"HD_COMP"; -- 1st command to be issued is the HD_COMP command, which will tell services which have a :Compile() function to run it.
			"HD_BOOT"; -- 2nd command is HD_BOOT, similarly calls :Boot()
			"HD_STRT"; -- 3rd command is HD_STRT, similarly calls :Start()
		};
		-- The name of the hdCommands can all be configured by including your own hdCommandChainFunctionMap:
		--commandChainFunctionMap = userhdCommandChainFunctionMap;
		-- By default, the hdCommandChainCreateInfo fills this with a constant mapping though.
		-- Recommended best practice for mapping an existing command chain function map with your own commands and relative names is to
		-- extrapolate the current hdCommandChainFunctionMap with hdCommandChain:hdGetCommandChainFunctionMap() and use a utility map to reconcile
		-- the hdCommandChainFunctionMap with your own, so that unlisted commands don't get lost in the transfer.
	};
	debugMessenger = hdDebugMessenger;
};
local hdCreateCommandChainResult, hdCommandChain = hdServiceManager:hdCreateCommandChain(hdCommandChainCreateInfo);
if not hdCreateCommandChainResult.Success then
	error("failed to create command chain!");
	return;
end

--// Now that the hdServiceManager has been successfully initialized, we can invoke its command chain to boot all the experience services!
--// The hdCommandChain allows us to overwrite arrays of instructions for the hdServiceManager, so we will re-use this hdCommandChain object later on when we
--// need to call more commands on all services at once.
local hdFenceCreateInfo : hdTypes.hdFenceCreateInfo = {
	fenceInitialState = "HD_FENCE_UNSIGNALED";
};
local synchronization : hdFence.hdFence = hdFence.new(hdFenceCreateInfo);

local hdInvokeCommandResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain, synchronization);
if not hdInvokeCommandResult.Success then
	error("failed to boot services!");
	return;
end
```

Heimdall is written in Luau, and is designed to be used either in studio or in the third party code editor of your choice.
High level support and possible implementation in [roblox-ts](https://github.com/roblox-ts/roblox-ts) will be a focus of the framework's [Road Map](ROADMAP.md) later on.

Heimdall also natively ships with 2 key features:
1. Heimdall Core Scripts - Heimdall ships with compatible `hdServices` that supercede the functionality of the core ©Roblox scripts, these are known as `hdCoreScript`s. This allows you to seamlessly modify them to your liking, leaving you with more control over how your experience runs.
2. Heimdall Characters - Heimdall also ships with compatible `hdServices` that completely overrule the ©Roblox character system. ©Roblox's Character system is often known to be buggy and outdated, and often has strange and undesirable behavior that complex experiences have little control over. The Heimdall framework has accounted for this and includes a rewritten Character paradigm that completely changes how a ©Roblox character is controlled and constructed. It also has significant boosts to replication speed of the character's position, and a simpler exposed hdHumanoid API. The two objects, `hdCharacter` and `hdHumanoid` are the most relevant user facing features of the rewrite. To enable these experimental features, you can find them implemented in `hdCharacterService` in the [example project repository](https://github.com/include-marcy/Heimdall)

# When to use Heimdall
Heimdall provides extremely explicit control and doesn't hide any of its functionality behind black boxes. This means that beginners should not use Heimdall for their first experience. If your experience is a lightweight application that only requires a few features, Heimdall is not necessary. However, if your experience intends to support many compute intensive features and has a wide array of mechanics, the Heimdall architecture may benefit your experiences organization and performance by making use of its Parallel-Luau-housing `hdParallelService` class. Additionally, experiences that want to expand the design of their characters should consider Heimdall for its customizable and explicit rebuilt ©Roblox character services.

Any experience that wants to override the core functionality of ©Roblox character services or the ©Roblox core scripts should consider Heimdall, especially if your project utilizes frameworks like [Knit](https://github.com/Sleitnick/Knit). The conversion from Knit project to Heimdall project should be fairly seamless, as Knit services are fairly identical to Heimdall `hdServices`.

Experiences that include manipulation of perspective and that desire strong control over the location and relativity of the character to the experience in a multiplayer setting will be attracted to the native Scene objects.
Heimdall provides a series of objects for working with "Scenes", which are an abstraction over a common problem in ©Roblox experiences that are usually considered "story driven" or might normally be ruined by multiplayer. By providing granular control over the workspace and abstracting its state into a "Scene", Heimdall provides developers with the ability to easily make streamlined experiences across ©Roblox's diverse environments and within user generated worlds.

For this, Heimdall provides the `hdScene` and its corresponding classes:
- `hdSceneParticipant` : An abstraction layer over ©Roblox characters that defines their existence in the `hdScene`.
- `hdSceneHandle` : An "entry point" into the hdScene, sort of like a Spawn object but with more configuration.
- `hdSceneWarper` : A helper object that lets you have control over the way the 2 prior classes interact.
This list is expanding as the `hdScene` API matures, so its not all!

# Usage and general information
In the Heimdall API, almost everything is designed around objects that you create manually and then use. This is not only for actual things like Services, but also for internal configuration structures that describe how you want your experiences state to be commanded. The framework was designed to allow developers to implement the logic of their experience in any way that they desire. For example, it could be used to build an experience that runs like an [ECS](https://github.com/SanderMertens/ecs-faq) (Entity Component System), or more like a traditional OOP (Object Oriented Programming) style engine. It all depends on the way you decide to explicitly implement Heimdall Objects and manipulate them.

In general, implementing Heimdall generally means that your entire experience will be contained inside the Heimdall API.

# hdServices, hdCompiledServices, and hdParallelServices
The 3 afforementioned objects above are considered the "core" of your experience, and as such all behavior should be derived from them. They are usually stored in a contextually appropriate location in a folder like "`ReplicatedStore.Modules.Services`". Services as a general abstraction have been the default implementation for lifetime methods and for experience functionality being packed into a globally accessed singleton. In Heimdall, they come in 3 particular types.
1. `hdService`: The default version of a Service.
2. `hdCompiledService`: Functionally equivalent to `hdService`, except that it takes a module script and then writes the content and descendant content into an array stored in the hdCompiledService.
3. `hdParallelService`: Runs functions in Parallel, with specified fields for compute work and internal runtime configuration (Like how many actors to include, etc...)

# ECS implementations
Above paragraphs have mentioned that Heimdall can be used to create ECS frameworks. Heimdall in itself is not an ECS, but it provides sandboxed objects that can easily allow your project to act like a very proper ECS if you wish for it to do that.
Due to the demand for ECS, Heimdall ships with a built-in language called HECL (Heimdall Entity Composition Language). HECL compiles directly into Luau, and is composed of `name.hc` module script files in your experience. To run HECL, you will need to create an hdHeclInterpreter object and feed it `.hc` files to return results from the source code in the `.hc` file. HECL was designed around ECS, and `.hc` files are designed to make programming experiences in ECS significantly easier. HECL is in an alpha state and is not recommended for production use. The `hdInstance` object which is the main "second layer" of the Heimdall API, housed only secondary to the `hdObject`, contains built-in functions for storing an abstract Entity with a key "name". It also provides methods to directly query entities stored in the `hdInstance`, so any `hdService` can access a set of entities at will based on entity query parameters.

# License
Heimdall is distributed under the terms of the [MIT License](LICENSE).

When Heimdall is integrated into external projects, we ask that you honor the MIT license and include any necessary attribution into user-facing documentation. Attribution using the [Heimdall logo](assets/HeimdallLogo.png) is also encouraged (Looks neat on loading screens, too!)

©2024 Roblox Corporation. All rights belong to their respective owners. Roblox, the Roblox logo and Powering Imagination are among their registered and unregistered trademarks in the U.S. and other countries.
This software is not affiliated with, owned, maintained, nor created by Roblox Corporation. Any and all rights belong to their respective owners.

[^1]: Apply usage of `--!native` appropriately. Not all scenarios benefit from usage of the native flag.
[^2]: You can create multiple `hdObject` instances under namespaces to build seperate environments within the same context (i.e client having 2 hdInstances).