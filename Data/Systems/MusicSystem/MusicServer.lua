-- Root
local MUSIC_SERVER = {}

-- Services
local SOUND_SERVICE = game:GetService("SoundService")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))
local RECO = require(BETTER_WAIT(LIBRARIES, "Reco"))
local BULLFROG = require(BETTER_WAIT(LIBRARIES, "Bullfrog"))

-- Links
MUSIC_SERVER.remoteLinks = {
	startMusic = BULLFROG.createRemoteLink(),
	
	getBeatTimings = BULLFROG.createRemoteFunctionalLink(),
	getStartingTime = BULLFROG.createRemoteFunctionalLink(),
	getBeatLifetime = BULLFROG.createRemoteFunctionalLink(),
	getMusicLength = BULLFROG.createRemoteFunctionalLink(),
	getMusicPosition = BULLFROG.createRemoteFunctionalLink()
}

-- Constants
local DIFFICULTY_MODIFIER = 75 -- Recommended to step this in 1/4ths of 100

-- Variables
local currentMusic = nil
local beatTimings = {}

-- Local Functions
local function onGetBeatTimings()
	return beatTimings
end

local function onGetStartingTime()
	return currentMusic:GetAttribute("StartingTime")
end

local function onGetBeatLifetime()
	return 1 / (currentMusic:GetAttribute("BPM") / 60)
end

local function onGetMusicLength()
	return currentMusic.TimeLength
end

local function onGetMusicPosition()
	return currentMusic.TimePosition
end

local function setupMusic()
	local function getRandomMusic()
		local _randomMusic = SOUND_SERVICE.Gameplay:GetChildren()
			[math.random(1, #SOUND_SERVICE.Gameplay:GetChildren())]:Clone()

		_randomMusic.Parent = WORKSPACE
		
		return _randomMusic
	end

	local function gameOver()
		RECO(PLAYERS:GetChildren(), function(_, player)
			player:Kick([[You lost! Sorry I ran out of time and couldnt implement
				a proper game loop.]])
		end)
	end

	local _music = getRandomMusic()

	if not _music.IsLoaded then
		_music.Loaded:Wait()
	end

	_music:Play()

	_music.Ended:Connect(gameOver)

	_music:SetAttribute("StartingTime", time())
	_music:SetAttribute("BPM", (DIFFICULTY_MODIFIER / 100) *
		_music:GetAttribute("BPM"))

	currentMusic = _music
end

local function setupBeatTimings()
	local _totalBeats = math.floor((currentMusic.TimeLength / 60) *
		currentMusic:GetAttribute("BPM"))
	local _beatInterval = 1 / (currentMusic:GetAttribute("BPM") / 60)
	
	for _beat = 1, _totalBeats do
		table.insert(beatTimings, _beat * _beatInterval)
	end
end

local function onStartMusic()
	setupMusic()
	setupBeatTimings()
end

-- Global Functions
function MUSIC_SERVER.onStart()
	math.randomseed(tick())

	MUSIC_SERVER.remoteLinks.getBeatTimings.OnServerInvoke = onGetBeatTimings
	MUSIC_SERVER.remoteLinks.getStartingTime.OnServerInvoke = onGetStartingTime
	MUSIC_SERVER.remoteLinks.getBeatLifetime.OnServerInvoke = onGetBeatLifetime
	MUSIC_SERVER.remoteLinks.getMusicLength.OnServerInvoke = onGetMusicLength
	MUSIC_SERVER.remoteLinks.getMusicPosition.OnServerInvoke = onGetMusicPosition

	MUSIC_SERVER.remoteLinks.startMusic.OnServerEvent:Connect(onStartMusic)
end

return MUSIC_SERVER
