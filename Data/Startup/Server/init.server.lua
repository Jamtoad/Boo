-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BULLFROG = require(LIBRARIES:WaitForChild("Bullfrog"))

-- Constants
local SYSTEMS = REPLICATED_STORAGE:WaitForChild("Systems")

-- Startup
do
    BULLFROG.setupSystems(SYSTEMS)
    BULLFROG.start()
    warn("Bullfrog server started!")
end
