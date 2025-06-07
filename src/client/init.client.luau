local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Gun = require(ReplicatedStorage.Modules.Gun)

UserInputService.InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.Q then
		ReplicatedStorage.Remotes.test:FireServer("Shoot", workspace.CurrentCamera.CFrame)
	elseif key.KeyCode == Enum.KeyCode.E then
		ReplicatedStorage.Remotes.test:FireServer("ChangeGun", key)
	elseif key.KeyCode == Enum.KeyCode.LeftShift then
		ReplicatedStorage.Remotes.test:FireServer("ToggleSprint", true)
	elseif key.KeyCode == Enum.KeyCode.P or key.KeyCode == Enum.KeyCode.ButtonL2 then
		local playerGun = ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer()
		if not playerGun then
			print("No gun found for the player.")
			return
		end

		local Camera = workspace.CurrentCamera

		print(playerGun)
		Gun:Zoom(game.Players.LocalPlayer, Camera, playerGun, key)
		-- ReplicatedStorage.Remotes.test:FireServer("Zoom", workspace.CurrentCamera)
	end
end)

ReplicatedStorage.Remotes.GetCurrentGun.OnClientInvoke = function()
	return workspace.CurrentCamera
end

ReplicatedStorage.Remotes.test.OnClientEvent:Connect(function(input)
	local playerGun = ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer()
	if not playerGun then
		print("No gun found for the player.")
		return
	end

	local Camera = workspace.CurrentCamera

	print(playerGun)
	Gun:Zoom(game.Players.LocalPlayer, Camera, playerGun, input, true)
end)
