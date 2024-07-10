local heraConnection = {};
heraConnection.__index = heraConnection;

export type heraConnection = typeof(setmetatable({} :: {}, {} :: typeof(heraConnection)));

function heraConnection.new(signal : any, obj : any) : heraConnection
    local connection = setmetatable({}, heraConnection);

    connection.obj = obj;
    connection.signal = signal;

    table.insert(signal.connections, connection);

    return connection;
end

function heraConnection:Disconnect()
    local index = table.find(self.signal.connections, self)
    if index then
        table.remove(self.signal.connections, index);
    end
end

return heraConnection;