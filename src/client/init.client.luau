local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local PlayerControls = require(ReplicatedStorage.Modules.PlayerControls)
local Gun = require(ReplicatedStorage.Modules.Gun)

local playerGuns = {} -- Table to store player guns
local currentGun = "Gun0"

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
	PlayerControls:Sprint(game.Players.LocalPlayer, false, inputState == Enum.UserInputState.Begin)
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)

ContextActionService:BindAction("Shoot", function(_, inputState, _)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	ReplicatedStorage.Remotes.test:FireServer("Shoot", workspace.CurrentCamera.CFrame)
	return Enum.ContextActionResult.Sink
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
	local playerGun = ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer()
	if not playerGun then
		print("No gun found for the player.")
		return
	end

	if method == "Zoom" then
		local Camera = workspace.CurrentCamera

		print(playerGun)
		Gun:Zoom(game.Players.LocalPlayer, Enum.UserInputState.End, Camera, playerGun, input, true)
	elseif method == "ChangeWeapon" then
		PlayerControls:Sprint(game.Players.LocalPlayer, true, false)
	end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
	playerGuns = ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer(true, "")

	for _, gun in pairs(playerGuns) do
		setmetatable(gun, Gun)
	end
end)

if not playerGuns then
	playerGuns = {}
end
