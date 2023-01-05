-- Root
local INTERFACE_CLIENT = {}

-- Services
local PLAYERS = game:GetService("Players")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local TWEEN_SERVICE = game:GetService("TweenService")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))
local RECO = require(BETTER_WAIT(LIBRARIES, "Reco"))
local BULLFROG = require(BETTER_WAIT(LIBRARIES, "Bullfrog"))

-- Constants
local PLAYER = PLAYERS.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local HUMANOID = BETTER_WAIT(CHARACTER, "Humanoid")

local PLAYER_GUI = BETTER_WAIT(PLAYER, "PlayerGui")
local TRANSITION_GUI = BETTER_WAIT(PLAYER_GUI, "TransitionGui")

local MENU_GUI = BETTER_WAIT(PLAYER_GUI, "MenuGui")
local PLAY_BUTTON = BETTER_WAIT(MENU_GUI, "Play", nil, true)

local MAIN_GUI = BETTER_WAIT(PLAYER_GUI, "MainGui")
local TIMER_FRAME = BETTER_WAIT(MAIN_GUI, "Timer", nil, true)
local GHOSTIFY_COUNTER_FRAME = BETTER_WAIT(MAIN_GUI, "GhostifyCounter", nil, true)

local STORAGE = BETTER_WAIT(REPLICATED_STORAGE, "Storage")

-- Variables
local maxGhostifies = nil
local totalGhostifies = 0

-- Connections
local playButtonConnection = nil

-- Local Functions
local function onPlayButtonActivated()
	TWEEN_SERVICE:Create(TRANSITION_GUI.MainFrame.Blackout.UIScale,
		TweenInfo.new(1),
		{Scale = 4}):Play()

	task.delay(1, function()
		MENU_GUI.Enabled = false
	
		TWEEN_SERVICE:Create(TRANSITION_GUI.MainFrame.Description.UIScale,
			TweenInfo.new(.25),
			{Scale = 1}):Play()
	end)

	task.delay(7, function()
		BULLFROG.getSystem("MusicSystem").remoteLinks.startMusic:FireServer()
		BULLFROG.getSystem("MusicSystem").start()
		
		BULLFROG.getSystem("CameraSystem").setupGameplayCamera()
	
		TWEEN_SERVICE:Create(TRANSITION_GUI.MainFrame.Blackout.UIScale,
			TweenInfo.new(.5),
			{Scale = 0}):Play()
	
		TWEEN_SERVICE:Create(TRANSITION_GUI.MainFrame.Description.UIScale,
			TweenInfo.new(.5),
			{Scale = 0}):Play()

		MAIN_GUI.Enabled = true
	end)
end

local function setupGhostifyCounter()
	maxGhostifies = #BULLFROG.getSystem("NPCSystem").remoteLinks.getNPCPositions
		:InvokeServer()

	GHOSTIFY_COUNTER_FRAME.Counter.Text = "0 / " .. tostring(maxGhostifies)
end

local function setupMenuButton()
	playButtonConnection = PLAY_BUTTON.Activated:Connect(onPlayButtonActivated)
end

-- Global Functions
function INTERFACE_CLIENT.updateGhostifyCounter()
	totalGhostifies += 1

	GHOSTIFY_COUNTER_FRAME.Counter.Text = tostring(totalGhostifies) .. " / " ..
		tostring(maxGhostifies)
end

function INTERFACE_CLIENT.updateTimer(total, amount)
	local _timeLeft = math.floor(total - amount)
	local _minutes = math.floor(_timeLeft / 60)
	local _seconds = _timeLeft % 60
	
	TIMER_FRAME.Time.Text = tostring(_minutes) .. ":"
	
	if _seconds < 10 then
		TIMER_FRAME.Time.Text = TIMER_FRAME.Time.Text .. "0" .. _seconds
	else
		TIMER_FRAME.Time.Text = TIMER_FRAME.Time.Text .. _seconds
	end
end

function INTERFACE_CLIENT.onStart()
	setupMenuButton()
	setupGhostifyCounter()
end

return INTERFACE_CLIENT
