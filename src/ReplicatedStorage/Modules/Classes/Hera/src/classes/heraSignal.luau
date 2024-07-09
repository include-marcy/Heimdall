local hera = game.ReplicatedStorage.Modules.Classes.Hera.src;
local heraClasses = hera.classes;
local heraTypes = require(hera.lib.heraTypes);

local heraConnection = require(heraClasses.heraConnection);

local heraSignal = {};
heraSignal.__index = heraSignal;

export type heraSignal = typeof(setmetatable({} :: {
    connections : {heraConnection.heraConnection};
}, {} :: typeof(heraSignal)));

function heraSignal.new() : heraSignal
    local signal = setmetatable({}, heraSignal);

    signal.connections = {};

    return signal;
end

function heraSignal:Connect(callback : (any) -> (any)) : heraConnection.heraConnection
    return heraConnection.new(self, callback);;
end

function heraSignal:Fire(...)
    for _, connection in self.connections do
        local obj = connection.obj;
        task.spawn(obj, ...);
    end
end

function heraSignal:Wait()
    local waiting = true;
    local connection = self:Connect(function()
        waiting = false;
    end)

    repeat
        task.wait();
    until not waiting;

    connection:Disconnect();

    return true;
end

function heraSignal:Destroy()
    for _, connection in self.connections do
        connection:Disconnect();
    end

    table.clear(self);
    setmetatable(self, nil);

    self = nil;
end

return heraSignal;