--[==[
	Hermes is a framework dedicated to simplify and organize the creation of Parallel Luau modular framework implementations.
	It is designed around similar frameworks which employ "services" dedicated to specific tasks.
	A Hermes Service is a high-performance, high-workload singleton dedicated to a specific goal or workload within your game.

	::: extra
	For example, hsPhysicsService might be a Hermes Service dedicated to updating a physical simulation each frame based on a parallel
	distribution of workload method where n cores of cpu threads are dedicated to the mathematical workload of your physics simulation.
	:::
]==]
local Hermes = {};
Hermes.__index = Hermes;

export type Hermes = typeof(setmetatable({} :: {}, {} :: typeof(Hermes)));

function Hermes.new() : Hermes
	local self = setmetatable({}, Hermes);
	
	return self;
end

return Hermes;