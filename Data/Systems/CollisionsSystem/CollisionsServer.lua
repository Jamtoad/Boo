-- Root
local COLLISIONS_SERVER = {}

-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PHYSICS_SERIVCE = game:GetService("PhysicsService")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))
local RECO = require(BETTER_WAIT(LIBRARIES, "Reco"))
local BULLFROG = require(BETTER_WAIT(LIBRARIES, "Bullfrog"))

-- Local Functions
local function setupCollisions()
	PHYSICS_SERIVCE:RegisterCollisionGroup("Player")
	PHYSICS_SERIVCE:RegisterCollisionGroup("NPCs")

	if PHYSICS_SERIVCE:IsCollisionGroupRegistered("Player") and
		PHYSICS_SERIVCE:IsCollisionGroupRegistered("NPCs") then

		PHYSICS_SERIVCE:CollisionGroupSetCollidable("NPCs", "NPCs", false)
		PHYSICS_SERIVCE:CollisionGroupSetCollidable("Player", "NPCs", false)
	end
end

-- Global Functions
function COLLISIONS_SERVER.onUpdate(deltaTime)
	
end

function COLLISIONS_SERVER.onStart()
	setupCollisions()
end

function COLLISIONS_SERVER.onStop()
	
end

function COLLISIONS_SERVER.onSetup()
	
end

return COLLISIONS_SERVER
