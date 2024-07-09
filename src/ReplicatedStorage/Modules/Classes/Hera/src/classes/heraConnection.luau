local heraConnection = {};
heraConnection.__index = heraConnection;

export type heraConnection = typeof(setmetatable({} :: {}, {} :: typeof(heraConnection)));

function heraConnection.new(signal : any, obj : any) : heraConnection
    local connection = setmetatable({}, heraConnection);

    connection.obj = obj;
    connection.signal = signal;

    return connection;
end

function heraConnection:Disconnect()
    
end

return heraConnection;