# Hello 3rd party IDE user!
## hdCharacterService Documentation

hdCharacterService is a supercessional Heimdall Service that overrides the native Roblox character generation and controllers.

# How to use the API
- The only necessary steps to use this API are to include the hdCharacterService file in your Services directory in your Heimdall project. It takes care of the rest, creating proprietary objects and doing the internal work to set up the server and client side backend of a completely custom character system.

# Notes and Other Information
- You can implement your own default character by adding a model named StarterCharacter in StarterPlayer service. This model must contain a part named "HumanoidRootPart". That is the only requirement for it to be considered a valid character.

- You can edit the default control schema by editing the hdCoreScript objects that ship with this service in the CoreScripts directory of the Heimdall project GitHub repository. Roblox Core Scripts are not compatible with hdCharacterService.

- There is no Humanoid object in the default character of this service.
- There is an hdHumanoid object reference obtainable with this service. You must use that API to make use of and configure the "humanoid"-like features.
- There is a client side service counterpart to the hdCharacterService, located in the client services directory of the Heimdall project GitHub repository. This must be included in your client Heimdall services directory to function.