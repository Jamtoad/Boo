-- Root
local CHARACTER_CLIENT = {}

-- Services
local PLAYERS = game:GetService("Players")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local PHYSICS_SERIVCE = game:GetService("PhysicsService")
local CONTEXT_ACTION_SERVICE = game:GetService("ContextActionService")
local WORKSPACE = game:GetService("Workspace")
local TWEEN_SERVICE = game:GetService("TweenService")
local DEBRIS_SERVICE = game:GetService("Debris")

-- Libraries
local LIBRARIES = REPLICATED_STORAGE:WaitForChild("Libraries")
local BETTER_WAIT = require(LIBRARIES:WaitForChild("BetterWait"))
local RECO = require(BETTER_WAIT(LIBRARIES, "Reco"))
local BULLFROG = require(BETTER_WAIT(LIBRARIES, "Bullfrog"))

-- Constants
local PLAYER = PLAYERS.LocalPlayer
local CHARACTER = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local HUMANOID = BETTER_WAIT(CHARACTER, "Humanoid")

local STORAGE = BETTER_WAIT(REPLICATED_STORAGE, "Storage")

local ANIMATIONS = {
	run = "rbxassetid://616010382",
	walk = "rbxassetid://616013216",
	jump = "rbxassetid://616008936",
	fall = "rbxassetid://616005863",
	idle = {
		"rbxassetid://616006778",
		"rbxassetid://616008087",
	}
}

local ATTACK_RANGE = 10

-- Variables
CHARACTER_CLIENT.NPCsInRange = {}

-- Local Functions
local function setupTransparency()
	RECO(CHARACTER:GetDescendants(), function(_, descendant)
		if descendant:IsA("BasePart") then
			descendant.Transparency = .75
		end
	end)
end

local function setupAnimations()
	local function stopAnimations()
		RECO(BETTER_WAIT(HUMANOID, "Animator"):GetPlayingAnimationTracks(),
			function(_, track)
				track:Stop()
			end
		)
	end

	local function replaceAnimations()
		local _animateScript = BETTER_WAIT(CHARACTER, "Animate")
		if _animateScript then
			RECO(ANIMATIONS, function(key, animationId)
				if type(animationId) ~= "table" then
					if _animateScript:FindFirstChild(key) then
						_animateScript[key]:FindFirstChildWhichIsA("Animation")
							.AnimationId = animationId
					end
				else
					RECO(animationId, function(index, animationId)
						if _animateScript[key]["Animation" .. index] then
							_animateScript[key]["Animation" .. index]
								.AnimationId = animationId
						end
					end)
				end
			end)
		end
	end
	
	stopAnimations()
	replaceAnimations()
end

local function setupCollisions()
	RECO(CHARACTER:GetDescendants(), function(_, descendant)
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = "Player"
		end
	end)
end

local function setupHumanoid()
	HUMANOID.JumpHeight = 0
end

local function setupAura()
	local _aura = STORAGE.Aura:Clone()
	_aura.Size = Vector3.new(1, ATTACK_RANGE * 2, ATTACK_RANGE * 2)

	_aura.Front.Position = Vector3.new(-.5, 0, -ATTACK_RANGE)
	_aura.Back.Position = Vector3.new(-.5, 0, ATTACK_RANGE)

	_aura.RightBeam.CurveSize0 = (ATTACK_RANGE * 2) * .65
	_aura.RightBeam.CurveSize1 = (ATTACK_RANGE * 2) * .65
	_aura.LeftBeam.CurveSize0 = (ATTACK_RANGE * 2) * .65
	_aura.LeftBeam.CurveSize1 = (ATTACK_RANGE * 2) * .65
	
	_aura.Parent = CHARACTER
end

local function trackNPCs()
	local function addHighlight(model)
		if not model:FindFirstChildWhichIsA("Highlight") then
			local _highlight = STORAGE.RangeHighlight:Clone()
			_highlight.Parent = model

			TWEEN_SERVICE:Create(_highlight, TweenInfo.new(.1),
				{FillTransparency = .5, OutlineTransparency = 0}):Play()
		end
	end

	local function removeHighlight(model)
		local _highlight = model:FindFirstChildWhichIsA("Highlight")
	
		if _highlight then
			TWEEN_SERVICE:Create(_highlight, TweenInfo.new(.25),
				{FillTransparency = 1, OutlineTransparency = 1}):Play()

			task.delay(.25, function()
				_highlight:Destroy()
			end)
		end
	end

	RECO(WORKSPACE.NPCs:GetChildren(), function(_, NPC)
		local _distance = (NPC:GetPivot().Position -
			CHARACTER:GetPivot().Position).Magnitude

		if _distance <= ATTACK_RANGE then
			addHighlight(NPC)
			CHARACTER_CLIENT.NPCsInRange[tonumber(NPC.Name)] = NPC
		else
			removeHighlight(NPC)
			CHARACTER_CLIENT.NPCsInRange[tonumber(NPC.Name)] = nil
		end
	end)

	task.wait(.1)

	return trackNPCs()
end

local function trackAura()
	CHARACTER.Aura:PivotTo(CHARACTER:GetPivot() *
		CFrame.new(0, -2, 0) * CFrame.Angles(0, 0, math.pi / 2))

	task.wait(.01)

	return trackAura()
end

local function scare(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		local _beatAcceptanceRange =
			BULLFROG.getSystem("MusicSystem").beatAcceptanceRange

		if _beatAcceptanceRange then
			if time() > _beatAcceptanceRange.min and 
				time() < _beatAcceptanceRange.max then

				RECO(CHARACTER_CLIENT.NPCsInRange, function(_, NPC)
					BULLFROG.getSystem("NPCSystem").scare(NPC)
				end)
			else
				warn("YOU FAILED!")
			end
		end
	end
end

-- Global Functions
function CHARACTER_CLIENT.onUpdate(deltaTime)
	
end

function CHARACTER_CLIENT.onStart()
	setupTransparency()
	setupAnimations()
	setupCollisions()
	setupHumanoid()
	setupAura()

	coroutine.wrap(trackNPCs)()
	coroutine.wrap(trackAura)()

	CONTEXT_ACTION_SERVICE:BindAction("Scaring", scare, true,
		Enum.KeyCode.Space)
end

function CHARACTER_CLIENT.onStop()
	
end

function CHARACTER_CLIENT.onSetup()
	
end

return CHARACTER_CLIENT
