-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PLAYERS = game:GetService("Players")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BULLFROG = require(LIBRARIES:WaitForChild("Bullfrog"))

-- Constants
local SYSTEMS = REPLICATED_STORAGE:WaitForChild("Systems")

local PLAYER = PLAYERS.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()

-- Startup
do    
    BULLFROG.setupSystems(SYSTEMS)
    BULLFROG.start()
    warn("Bullfrog client started!")
end
