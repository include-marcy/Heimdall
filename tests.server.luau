local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Modules.Classes.TestEZ).TestBootstrap:run({
	ReplicatedStorage.Modules.Classes.Heimdall,
	nil,
	{
		noXpcallByDefault = true
	}
})