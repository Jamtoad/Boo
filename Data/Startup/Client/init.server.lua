-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PLAYERS = game:GetService("Players")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BULLFROG = require(LIBRARIES:WaitForChild("Bullfrog"))

-- Constants
local SYSTEMS = REPLICATED_STORAGE:WaitForChild("Systems")

-- Startup
do
    if not PLAYERS.LocalPlayer.Character then
        PLAYERS.LocalPlayer.CharacterAdded:Wait()
    end
    
    BULLFROG.setupSystems(SYSTEMS)
    BULLFROG.start()
end
