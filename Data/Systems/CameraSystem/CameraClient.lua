-- Root
local CAMERA_CLIENT = {}

-- Services
local PLAYERS = game:GetService("Players")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local WORKSPACE = game:GetService("Workspace")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))

-- Constants
local PLAYER = PLAYERS.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local HUMANOID = BETTER_WAIT(CHARACTER, "Humanoid")

local CAMERA = WORKSPACE.CurrentCamera

-- Variables
local cameraState = nil
local cameraStates = {}

-- Local Functions
function cameraStates.menu()
	return CFrame.new(14.058898, 16.348938, -45.7464371,
		0.999991417, -0.00230275025, 0.0034723361,
		-0, 0.833392799, 0.552681267, -0.0041665067,
		-0.552676499, 0.833385468)
end

function cameraStates.gameplay()
	return CFrame.lookAt(CHARACTER:GetPivot().Position + Vector3.new(-25, 25, 25),
		CHARACTER:GetPivot().Position)
end

-- Global Functions
function CAMERA_CLIENT.setupMenuCamera()
	cameraState = "menu"
end

function CAMERA_CLIENT.setupGameplayCamera()
	cameraState = "gameplay"
end

function CAMERA_CLIENT.onUpdate(deltaTime)
	CAMERA.CFrame = cameraStates[cameraState]()
	CAMERA.Focus = CAMERA.CFrame
end

function CAMERA_CLIENT.onStart()
	CAMERA.CameraType = Enum.CameraType.Scriptable

	CAMERA_CLIENT.setupMenuCamera()
end

function CAMERA_CLIENT.onStop()
	CAMERA.CameraType = Enum.CameraType.Custom
end

function CAMERA_CLIENT.onSetup()
	
end

return CAMERA_CLIENT
