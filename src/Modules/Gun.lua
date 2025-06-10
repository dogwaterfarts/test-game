local PlayerControls = require(script.Parent.PlayerControls) -- Assuming PlayerControls is in the same directory
local Bullet = require(script.Parent.BulletDrop) -- Assuming Bullet is in the same directory
local GamepadCamera = require(script.Parent.GamepadCamera) -- Assuming GamepadCamera is in the same directory

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService") -- Assuming GamepadCamera is in the ReplicatedStorage")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local Gun = {}
Gun.__index = Gun

local Characters = {}

export type Gun = typeof(setmetatable(
	{} :: {
		initVelocity: number,
		power: number,
		weight: number,
		magSize: number,
		roundsPerMinute: number,
		caliber: number,
		weightPerRound: number,
		magnification: number,
		onCooldown: boolean,
		zoomActive: boolean,
		connection: { [number]: RBXScriptConnection },
	},
	Gun
))

-- Iterate through the children of the item until we find a Model parent
local function FindFirstModelParent(item)
	while item.ClassName ~= "Model" do
		item = item.Parent

		if not item then
			return nil -- Return nil if no Model parent is found
		end
	end

	return item
end

-- Create a new gun with characteristics
function Gun.new(initVelocity, power, weight, magSize, roundsPerMinute, caliber, weightPerRound, magnification): Gun
	local self = {
		initVelocity = initVelocity,
		power = power,
		weight = weight,
		magSize = magSize,
		roundsPerMinute = roundsPerMinute,
		caliber = caliber or 0.01, -- Default caliber if not provided
		weightPerRound = weightPerRound or 100,
		magnification = magnification, -- Default weight per round if not provided
		onCooldown = false,
		zoomActive = false,
		connection = nil,
	}

	setmetatable(self, Gun)

	return self
end

function Gun:CreateHitbox(character: Model): ()
	if not character or not character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Hitbox") then
		return
	end

	-- Create a hitbox part for the character
	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = Vector3.new(3.2, 5.5, 1.8)
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.Parent = character
	-- hitbox:SetNetworkOwner(nil) -- Set to nil to allow server-side control

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local Humanoid = character:FindFirstChild("Humanoid")

	hitbox.CFrame = rootPart.CFrame

	-- Ensure that the hitbox follows the player.
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		hitbox.CFrame = rootPart.CFrame

		if not Humanoid or Humanoid.Health <= 0 then
			connection:Disconnect()
			hitbox:Destroy()
		end
	end)
end

function Gun:Shoot(Player: Player, CameraCFrame: CFrame, resistance: number): ()
	if not Player.Character then
		return
	end

	if self.onCooldown then
		return
	end

	local LookVector = CameraCFrame.LookVector

	-- Find Player Characters
	Characters = {}

	for _, person in game.Players:GetChildren() do
		if person ~= Player then
			table.insert(Characters, person.Character.Hitbox)
		end
	end

	--Create a RaycastParams object to only apply to the characters
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params:AddToFilter(Characters)
	params:AddToFilter(workspace.Baseplate) -- Include the Baseplate

	self.onCooldown = true
	task.delay(60 / self.roundsPerMinute, function()
		self.onCooldown = false
	end)

	-- Perform the raycast
	print(self)
	local bullet =
		Bullet:newBullet(CameraCFrame.Position, LookVector * self.initVelocity, self.weightPerRound, params, resistance)
	-- Check if the bullet hit anything
	bullet.onHit.Event:Connect(function(hitResult)
		if typeof(hitResult) == "Vector3" then
			local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
			local newHitPosition = Vector3.new(hitResult.X, HRP.Position.Y, hitResult.Z)
			local distance = (newHitPosition - CameraCFrame.Position).Magnitude
			print(distance)
			return
		end

		if hitResult then
			print("Hit detected:", hitResult.Instance:GetFullName())
			if hitResult.Instance == workspace.Baseplate then
				print("Hit the ground") -- Change color to indicate hit
				local distance = (hitResult.Position - CameraCFrame.Position).Magnitude
				print("Distance to hit:", distance)
			end

			local hitParent = FindFirstModelParent(hitResult.Instance)

			if hitParent and hitParent:FindFirstChild("Humanoid") then
				hitParent.Humanoid:TakeDamage(self.power)
			end
		end
	end)

	return
end

function Gun:ChangeGun(playerGuns: { [string]: Gun }, gunName: string, player: Player, input): ()
	if not playerGuns[gunName] then
		error("Gun not found: " .. gunName)
	end
	local currentGun = playerGuns[gunName]
	print(currentGun)

	local timeDelay = math.exp(currentGun.weight / 70)
	wait(timeDelay)
	print("Changed to gun:", gunName, "with initial velocity:", currentGun.initVelocity, "and power:", currentGun.power)
	currentGun:ChangeCharMovement(player)
	ReplicatedStorage.Remotes.test:FireClient(player, input)
	return currentGun
end

function Gun:ChangeCharMovement(Player: Player): ()
	local weight = self.weight

	if not Player.Character or not Player.Character:FindFirstChild("Humanoid") then
		return
	end

	local humanoid = Player.Character:FindFirstChild("Humanoid")
	if humanoid then
		local newArgument = 0.2 * (weight - 6)

		local newWalkSpeed = 12 - 7.5 * math.atan(newArgument)
		print(newWalkSpeed)
		humanoid.WalkSpeed = newWalkSpeed
		print("Walk speed set to:", humanoid.WalkSpeed)

		-- PlayerControls:Sprint(Player, true)
		ReplicatedStorage.Remotes.test:FireClient(Player, "ChangeWeapon")
	end
	-- Reload player controls to apply changes
end

function Gun:Zoom(player: Player, inputState: Enum.UserInputState, camera: Camera, input: InputObject, ...): ()
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end
	print("boo")

	local args = { ... }

	print(player.UserId, self.zoomActive, self.connection)

	if inputState == Enum.UserInputState.End and self.zoomActive then
		print("Already zoomed in, toggling zoom out.")
		self.zoomActive = false
		local state, msg = pcall(function()
			self.connection:Disconnect()
		end)

		ContextActionService:BindAction("ToggleSprint", function(_, inputState2, _)
			PlayerControls:Sprint(game.Players.LocalPlayer, false, inputState2 == Enum.UserInputState.Begin)
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)

		if not state then
			warn("Error disconnecting zoom connection:", msg)
			wait()
			GamepadCamera:Disable() -- Disable gamepad camera controls if an error occurs
		else
			self.connection = nil
		end

		local tween = game:GetService("TweenService"):Create(
			camera,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ FieldOfView = 70 } -- Reset to default FOV
		)
		tween:Play()
		tween.Completed:Wait()
		userInputService.MouseDeltaSensitivity = 1 -- Reset mouse sensitivity
		return
	end

	if not args[1] and inputState == Enum.UserInputState.Begin and not self.zoomActive then
		PlayerControls:Sprint(player, false, false)
		ContextActionService:UnbindAction("ToggleSprint")

		if input.UserInputType == Enum.UserInputType.Gamepad1 then
			self:ControllerZoom(camera)
			return
		end
		-- PlayerControls:Sprint(player, false, false) -- Load player controls to ensure they are ready for zooming
		-- Adjust the camera's CFrame for zooming
		local tween = game:GetService("TweenService"):Create(
			camera,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ FieldOfView = camera.FieldOfView / self.magnification } -- Reset to default FOV
		)
		tween:Play()
		tween.Completed:Wait()
		self.zoomActive = true

		local mouseDeltaSensitivity = (2 / math.sqrt(camera.FieldOfView)) / UserGameSettings.MouseSensitivity
		userInputService.MouseDeltaSensitivity = mouseDeltaSensitivity
		self.connection = UserGameSettings:GetPropertyChangedSignal("MouseSensitivity"):Connect(function()
			mouseDeltaSensitivity = (2 / math.sqrt(camera.FieldOfView)) / UserGameSettings.MouseSensitivity
			userInputService.MouseDeltaSensitivity = mouseDeltaSensitivity
		end)
		return
	end
	return
end

function Gun:ControllerZoom(camera: Camera): ()
	print("Zooming in with controller")
	local tween = game:GetService("TweenService"):Create(
		camera,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = camera.FieldOfView / self.magnification } -- Adjust FOV for zoom
	)
	tween:Play()
	tween.Completed:Wait()

	self.zoomActive = true
	local playerSensitivity = UserGameSettings.MouseSensitivity or 1

	GamepadCamera:Enable(self.magnification, playerSensitivity) -- Enable gamepad camera controls
end

return Gun

--[[
	Module for Gun functionality.
	Contains methods to create a gun and shoot it.
	Handles raycasting to detect hits on players.
]]
