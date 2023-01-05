-- Root
local MUSIC_CLIENT = {}

-- Services
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PLAYERS = game:GetService("Players")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))
local RECO = require(BETTER_WAIT(LIBRARIES, "Reco"))
local BULLFROG = require(BETTER_WAIT(LIBRARIES, "Bullfrog"))

-- Constants
local PLAYER = PLAYERS.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()

local BEAT_COLORS = {
	on = Color3.new(85/255, 1, 127/255),
	off = Color3.new(1, 0, 0)
}

-- Variables
local beatTimings = nil
local startingTime = nil
local beatLifetime = nil
local musicLength = nil

MUSIC_CLIENT.beatAcceptanceRange = nil

-- Local Functions
local function setupMusic()
	beatTimings = MUSIC_CLIENT.remoteLinks.getBeatTimings:InvokeServer()
	startingTime = MUSIC_CLIENT.remoteLinks.getStartingTime:InvokeServer()
	beatLifetime = MUSIC_CLIENT.remoteLinks.getBeatLifetime:InvokeServer()
	musicLength = MUSIC_CLIENT.remoteLinks.getMusicLength:InvokeServer()
end

local function trackMusic()
	local function changeColor(state)
		RECO(BULLFROG.getSystem("CharacterSystem").NPCsInRange,
			function(_, NPC)
				if NPC:FindFirstChild("RangeHighlight") then
					NPC.RangeHighlight.FillColor = BEAT_COLORS[state]
				end
			end)
		
		CHARACTER.Aura.LeftBeam.Color = ColorSequence.new(BEAT_COLORS[state])
		CHARACTER.Aura.RightBeam.Color = ColorSequence.new(BEAT_COLORS[state])
	end

	if time() - startingTime >= beatTimings[1] then
		table.remove(beatTimings, 1)

		MUSIC_CLIENT.beatAcceptanceRange = {}
		MUSIC_CLIENT.beatAcceptanceRange.min = time() - (beatLifetime / 2)
		MUSIC_CLIENT.beatAcceptanceRange.max = time() + (beatLifetime / 2)
	end
	
	if MUSIC_CLIENT.beatAcceptanceRange then
		if time() > MUSIC_CLIENT.beatAcceptanceRange.min and
			time() < MUSIC_CLIENT.beatAcceptanceRange.max then

			changeColor("on")
		else
			changeColor("off")
		end
	end
	
	task.wait(.01)

	return trackMusic()
end

local function trackTimer()
	local _musicPosition = MUSIC_CLIENT.remoteLinks.getMusicPosition:InvokeServer()

	BULLFROG.getSystem("InterfaceSystem").updateTimer(musicLength, _musicPosition)

	task.wait(1)

	return trackTimer()
end

-- Global Functions
function MUSIC_CLIENT.start()
	setupMusic()
	
	coroutine.wrap(trackMusic)()
	coroutine.wrap(trackTimer)()
end

return MUSIC_CLIENT
