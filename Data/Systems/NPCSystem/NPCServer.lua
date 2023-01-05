-- Root
local NPC_SERVER = {}

-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local WORKSPACE = game:GetService("Workspace")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))
local RECO = require(BETTER_WAIT(LIBRARIES, "Reco"))
local BULLFROG = require(BETTER_WAIT(LIBRARIES, "Bullfrog"))

-- Links
NPC_SERVER.remoteLinks = {
	getNPCPositions = BULLFROG.createRemoteFunctionalLink()
}

-- Constants
local STORAGE = BETTER_WAIT(REPLICATED_STORAGE, "Storage")

local GRID_SIZE = 8
local RANDOMIZE_PERCENTAGE = 50

-- Variables
local NPCPositions = {}

-- Local Functions
local function onGetNPCPositions()
	return NPCPositions
end

local function setupNPCPositions()
	local function getBoundingArea()
		return BETTER_WAIT(WORKSPACE, "SpawnArea").Size
	end

	local function getGrid(boundingArea)
		return boundingArea.X / GRID_SIZE, boundingArea.Z / GRID_SIZE
	end

	local function determinePositions(rows, columns, boundingArea)
		local _positions = {}
	
		local function getPosition(row, column)
			local function centerPosition(position, center)
				return position - ((center / 2) + (GRID_SIZE / 2))
			end
		
			local _x = centerPosition(row * GRID_SIZE, boundingArea.X)
			local _y = centerPosition(column * GRID_SIZE, boundingArea.Z)
		
			return Vector3.new(_x, 0, _y)
		end

		local function randomizePosition(position)
			local _offset = GRID_SIZE *
				(math.random(-RANDOMIZE_PERCENTAGE, RANDOMIZE_PERCENTAGE) / 100)
			
			return position + Vector3.new(_offset, 0, _offset)
		end

		for row = 1, rows do
			for column = 1, columns do
				table.insert(_positions,
					randomizePosition(getPosition(row, column)))
			end
		end

		return _positions
	end

	local _boundingArea = getBoundingArea()
	local _rows, _columns = getGrid(_boundingArea)
	
	NPCPositions = determinePositions(_rows, _columns, _boundingArea)
end

-- Global Functions
function NPC_SERVER.onUpdate(deltaTime)
	
end

function NPC_SERVER.onStart()
	math.randomseed(tick())

	NPC_SERVER.remoteLinks.getNPCPositions.OnServerInvoke = onGetNPCPositions

	setupNPCPositions()
end

function NPC_SERVER.onStop()
	
end

function NPC_SERVER.onSetup()
	
end

return NPC_SERVER
