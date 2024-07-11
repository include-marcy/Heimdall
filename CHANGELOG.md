# Heimdall v1.0.0.a
Heimdall v1.0.0 is not yet available[^1]

# Heimdall v0.0.2.a.7.11.24
## Release Date: July 11th, 2024
This release contains the following changes and additions to the Heimdall framework:
- Full Alpha Release of hdCharacterService
    - [x] hdCharacter R6 Pre-Production Release
    - [x] hdHumanoid R6 Pre-Production Release
- hdCharacterService utilizes industry standard netcode design to implement a customized character controller for Roblox.
### How does it work?
- The server contains the source of truth for all characters.
- Clients author commands to the server dictating motion and state of the character.
- The server issues replication requests to update the state of truth to all clients with unreliable remote events.
- The client makes predictions about its own state of truth to reduce latency. In turn, if the client is severely out of sync with the server, it will be rolled back and remediated.
### What does this achieve?
- The real time server knowledge of the character's position reduces latency significantly on the server side.
- The network usage of replication of characters state is low and rapid with unreliable remote events.
- Completely exposed functionality that can be edited by developers.
- High quality Luau interface for working with characters and controlling them.
- Completely exposed functionality of modern core scripts with strict typing and Heimdall integration.

# Heimdall v0.0.1.a.7.10.24
## Release Date: July 10, 2024
The initial version of Heimdall which contains project layouts, some complete classes and some functionality. See the [Road Map](ROADMAP.md) for more information on the project planning and the future of Heimdall.

# Prerelease Notes
- Added Heimdall Core objects and classes.
    - [x] hdService
    - [x] hdCommandChain
    - [x] hdServiceManager
    - [x] hdInstance
    - [x] hdObject
    - [x] hdCompiledService
    - [x] hdScene
    - [x] hdSceneParticipant
    - [x] hdSceneWarper
    - [x] hdSceneHandle
    - [x] hdClient
    - [x] hdCharacter
    - [x] hdHumanoid
    - [x] hdDebugMessenger
    - [x] hdLaunchToken

    INTERNAL:
    - [x] hdFence
    - [x] hdSignal
    - [x] hdWrapping
    - [x] hdProtectedCallResultEmitter

- Added Heimdall Core Services
    - [x] hdCharacterService
    - [x] hdCoreCameraService
    - [x] hdCoreControlService

- Added Heimdall ECS Core objects and classes.
    - [x] hdComponent
    - [x] hdComponentManager
    - [x] hdEntity

- Other Additions
    - [x] hdTypes
    - [x] hdUtils
    - [x] hdEnums
    - [x] TestEZ
    - [x] Trove
    - [x] Net

[^1]: v1.0.0a will be the first stable alpha release, still signed as pre-production.