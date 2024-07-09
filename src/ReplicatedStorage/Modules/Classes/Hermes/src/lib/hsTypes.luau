local hdInstance = require(game.ReplicatedStorage.Modules.Classes.Heimdall.src.classes.hdInstance);
local hsTypes = {};

export type hsInstanceCreateInfo = {
	name : string;
	module : ModuleScript;
	hdInstance : hdInstance.hdInstance;
};

export type hsSprintCreateInfo = {
	workingMethod : ModuleScript;
	actorCount : number;
};

export type hsSprintRunConfig = {
	workLoad : {any : any}; -- represents the 
};

return hsTypes;