local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local PlayerControls = require(ReplicatedStorage.Modules.PlayerControls)
local Gun = require(ReplicatedStorage.Modules.Gun)

local playerGuns = {} -- Table to store player guns
local currentGun = "Gun0"

local shooting = false

local Controller = PlayerControls.Load()

local function Zoom(inputState, key)
	local playerGun = playerGuns[currentGun]
	if not playerGun then
		print("No gun found for the player.")
		return
	end
	local Camera = workspace.CurrentCamera

	print(playerGun)
	playerGun:Zoom(game.Players.LocalPlayer, inputState, Camera, key)
end

ContextActionService:BindAction("ToggleSprint", function(_, inputState, _)
	Controller:Sprint(game.Players.LocalPlayer, false, playerGuns[currentGun], inputState == Enum.UserInputState.Begin)
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)

ContextActionService:BindAction("ChangeFireMode", function(_, inputState, _)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	ReplicatedStorage.Remotes.test:FireServer("ChangeFireMode", currentGun)
	task.wait()

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.F, Enum.KeyCode.DPadDown)

ContextActionService:BindAction("ChangeFireMode", function(_, inputState, _)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	ReplicatedStorage.Remotes.test:FireServer("Reload", currentGun)
	task.wait()

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.R, Enum.KeyCode.ButtonX)

ContextActionService:BindAction("Shoot", function(_, inputState, _)
	if inputState == Enum.UserInputState.End then
		if shooting then
			shooting = false
		end
		return Enum.ContextActionResult.Sink
	end

	if inputState == Enum.UserInputState.Begin then
		playerGuns = ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer(true, "")
		shooting = true

		if playerGuns[currentGun].currentFireMode == "Single" then
			ReplicatedStorage.Remotes.test:FireServer("Shoot", workspace.CurrentCamera.CFrame)
			return Enum.ContextActionResult.Sink
		end

		print("boo")

		if playerGuns[currentGun].currentFireMode == "Spray" then
			while shooting do
				task.wait()
				ReplicatedStorage.Remotes.test:FireServer("Shoot", workspace.CurrentCamera.CFrame)
			end
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	end

	return Enum.ContextActionResult.Pass
end, false, Enum.KeyCode.MouseLeftButton, Enum.KeyCode.ButtonR2, Enum.KeyCode.Q)

ContextActionService:BindAction("ChangeGun", function(_, inputState, key)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	ReplicatedStorage.Remotes.test:FireServer("ChangeGun", key)
	currentGun = currentGun == "Gun0" and "Gun1" or "Gun0"

	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.E, Enum.KeyCode.ButtonY)

ContextActionService:BindAction("Zoom", function(_, inputState, key)
	Zoom(inputState, key)
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.P, Enum.KeyCode.ButtonL2)

ReplicatedStorage.Remotes.GetCurrentGun.OnClientInvoke = function()
	return workspace.CurrentCamera
end

ReplicatedStorage.Remotes.test.OnClientEvent:Connect(function(method, input)
	local playerGun = playerGuns[currentGun]
	if not playerGun then
		print("No gun found for the player.")
		return
	end

	if method == "Zoom" then
		local Camera = workspace.CurrentCamera

		print(playerGun)
		Gun:Zoom(game.Players.LocalPlayer, Enum.UserInputState.End, Camera, playerGun, input, true)
	elseif method == "ChangeWeapon" then
		Controller:Sprint(game.Players.LocalPlayer, true, playerGun, false)
	end

	if method == "ReconnectSprint" then
		ContextActionService:BindAction("ToggleSprint", function(_, inputState2, _)
			Controller:Sprint(
				game.Players.LocalPlayer,
				false,
				playerGuns[currentGun],
				inputState2 == Enum.UserInputState.Begin
			)
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
	end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
	playerGuns = ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer(true, "")
	print(playerGuns)
	for a, b in playerGuns do
		-- print("Gun found for player:", gun.Name)
		-- setmetatable(gun, Gun)

		print(a, b)
		setmetatable(b, Gun)
	end
end)

if not playerGuns then
	playerGuns = {}
end
