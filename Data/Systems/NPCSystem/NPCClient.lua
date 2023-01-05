-- Root
local NPC_CLIENT = {}

-- Services
local PLAYERS = game:GetService("Players")
local REPLICATED_STORAGE = game:GetService("ReplicatedStorage")
local WORKSPACE = game:GetService("Workspace")
local PHYSICS_SERIVCE = game:GetService("PhysicsService")
local TWEEN_SERVICE = game:GetService("TweenService")
local RUN_SERVICE = game:GetService("RunService")

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

local DANCE_ANIMATIONS = {
	"rbxassetid://10714340543", -- Floss
	"rbxassetid://10370362157", -- Sidekicks
	"rbxassetid://10713983178", -- Baby Dance
	"rbxassetid://10714366910", -- Side to Side
	"rbxassetid://10214314957", -- Floor Rock
	"rbxassetid://10714003221", -- Break Dance
	"rbxassetid://10714364213", -- Hips Poppin
	"rbxassetid://10714391240", -- Old Town Road
	"rbxassetid://10275008655", -- Uprise
	"rbxassetid://11444443576", -- Still Standing
	"rbxassetid://10714386947", -- Samba
	"rbxassetid://10714403700", -- Rock On
	"rbxassetid://10714392953", -- On the Outside
	"rbxassetid://6862001787", -- Cha Cha
	"rbxassetid://10714069471", -- Dorky Dance
	"rbxassetid://10714394082", -- Panini
	"rbxassetid://10714382522", -- Saturday Dance
	"rbxassetid://10714076981", -- Fancy Feet
	"rbxassetid://10713988674", -- Block Party
	"rbxassetid://11444441914", -- Cat Man
}

local SCARE_ANIMATIONS = {
	"rbxassetid://4940563117", -- Cower
	"rbxassetid://4940561610", -- Confused
	"rbxassetid://10714066964" -- Dizzy
}

local GHOSTIFIED_ANIMATION = "rbxassetid://10714360343"

-- Local Functions
local function setupDanceAnimation(NPC)
	local _animation = Instance.new("Animation")
	_animation.AnimationId = DANCE_ANIMATIONS[math.random(1, #DANCE_ANIMATIONS)]

	local _animationTrack = NPC.Humanoid.Animator:LoadAnimation(_animation)
	_animationTrack.Looped = false
	_animationTrack:Play()

	_animationTrack.Ended:Wait()

	return setupDanceAnimation(NPC)
end

local function setupNPCs()
	local _NPCPositions = NPC_CLIENT.remoteLinks.getNPCPositions:InvokeServer()

	local function setupModels()
		local function setupCollisions(model)
			RECO(model:GetDescendants(), function(_, descendant)
				if descendant:IsA("BasePart") then
					descendant.CollisionGroup = "NPCs"
				end
			end)
		end
	
		RECO(_NPCPositions, function(_, position)
			local _model = STORAGE.NPCs:GetChildren()[math.random(1, 
				#STORAGE.NPCs:GetChildren())]:Clone()
				
			local _modelOrientation, _modelSize = _model:GetBoundingBox()

			setupCollisions(_model)

			_model:SetAttribute("Health", 3)

			_model:PivotTo(
				CFrame.new(position + Vector3.new(0, _modelSize.Y / 2, 0)) *
				CFrame.Angles(0, math.rad(math.random(-180, 180)), 0))
			_model.Name = tostring(tick()):split(".")[2]
			_model.Parent = WORKSPACE.NPCs

			coroutine.wrap(function() setupDanceAnimation(_model) end)()
		end)
	end

	setupModels()
end

local function ghostify(NPC)
	RECO(NPC:GetDescendants(), function(_, descendant)
		if descendant:IsA("BasePart") and descendant ~= NPC.PrimaryPart then
			TWEEN_SERVICE:Create(descendant,
				TweenInfo.new(1),
				{Transparency = .75}):Play()
		end
	end)

	TWEEN_SERVICE:Create(NPC.RangeHighlight,
		TweenInfo.new(1),
		{FillTransparency = 1, OutlineTransparency = 1}):Play()

	TWEEN_SERVICE:Create(NPC.HealthGUI,
		TweenInfo.new(.25),
		{ExtentsOffsetWorldSpace = Vector3.new(0, 0, 0), 
			Size = UDim2.fromScale(0, 0)}):Play()

	RECO(NPC.Humanoid.Animator:GetPlayingAnimationTracks(),
		function(_, animationTrack)
			animationTrack:Stop()
			animationTrack:Destroy()
		end)

	local _animation = Instance.new("Animation")
	_animation.AnimationId = GHOSTIFIED_ANIMATION

	local _animationTrack = NPC.Humanoid.Animator:LoadAnimation(_animation)
	_animationTrack.Looped = true
	_animationTrack:Play()

	BULLFROG.getSystem("InterfaceSystem").updateGhostifyCounter(maxGhostifies)

	task.delay(1, function()
		BULLFROG.getSystem("CharacterSystem").NPCsInRange[tonumber(NPC.Name)] =
			nil
		
		NPC.Parent = WORKSPACE.Ghosts

		if #WORKSPACE.NPCs:GetChildren() == 0 then
			PLAYER:Kick([[You won! Sorry I ran out of time and couldnt implement
				a proper game loop.]])
		end
	end)
end

-- Global Functions
function NPC_CLIENT.scare(NPC)
	local function jump()
		if NPC:FindFirstChild("Humanoid") then
			NPC.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	local function playAnimation()
		RECO(NPC.Humanoid.Animator:GetPlayingAnimationTracks(),
			function(_, animationTrack)
				animationTrack:Stop()
				animationTrack:Destroy()
			end)
	
		local _animation = Instance.new("Animation")
		_animation.AnimationId = SCARE_ANIMATIONS[math.random(1, #SCARE_ANIMATIONS)]
		
		local _animationTrack = NPC.Humanoid.Animator:LoadAnimation(_animation)
		_animationTrack.Looped = false
		_animationTrack:Play()
		_animationTrack:AdjustSpeed(1.5)

		_animationTrack.Ended:Wait()

		setupDanceAnimation(NPC)
	end

	local function updateHealthGUI()
		local function setupGUI()
			local _clonedGUI = STORAGE.HealthGUI:Clone()
			_clonedGUI.Parent = NPC

			return _clonedGUI
		end

		local function promptGUI(GUI)
			local function unpromptGUI()
				if (time() - NPC:GetAttribute("LastDamageTime")) >= 3 then
					TWEEN_SERVICE:Create(GUI,
						TweenInfo.new(.25),
						{ExtentsOffsetWorldSpace = Vector3.new(0, 0, 0), 
							Size = UDim2.fromScale(0, 0)}):Play()

					return nil
				end

				task.wait(.1)

				return unpromptGUI()
			end
		
			TWEEN_SERVICE:Create(GUI,
				TweenInfo.new(.25),
				{ExtentsOffsetWorldSpace = Vector3.new(0, 2, 0), 
					Size = UDim2.fromScale(4, 1)}):Play()

			NPC:SetAttribute("LastDamageTime", time())
			
			coroutine.wrap(unpromptGUI)()
		end

		local function tweenBar(GUI)
			TWEEN_SERVICE:Create(GUI.MainFrame.HealthBar,
				TweenInfo.new(.25),
				{Size = UDim2.fromScale(
					GUI.MainFrame.HealthBar.Size.X.Scale - (1 / 3), 1)}):Play()
		end

		local _healthGUI = NPC:FindFirstChild("HealthGUI") or setupGUI()
		promptGUI(_healthGUI)
		task.delay(.25, function()
			tweenBar(_healthGUI)
		end)
	end

	local function updateHealth()
		NPC:SetAttribute("Health", NPC:GetAttribute("Health") - 1)

		if NPC:GetAttribute("Health") == 0 then
			ghostify(NPC)
		end
	end

	jump()
	
	coroutine.wrap(playAnimation)()
	
	updateHealthGUI()
	updateHealth()
end

function NPC_CLIENT.onUpdate(deltaTime)
	
end

function NPC_CLIENT.onStart()
	setupNPCs()
end

function NPC_CLIENT.onStop()
	
end

function NPC_CLIENT.onSetup()
	
end

return NPC_CLIENT
