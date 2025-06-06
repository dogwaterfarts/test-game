local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- Assuming PlayerControls is in the same directory

game:GetService("UserInputService").InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.Q then
		ReplicatedStorage.Remotes.test:FireServer("Shoot", workspace.CurrentCamera.CFrame)
	elseif key.KeyCode == Enum.KeyCode.E then
		ReplicatedStorage.Remotes.test:FireServer("ChangeGun")
	elseif key.KeyCode == Enum.KeyCode.LeftShift then
		ReplicatedStorage.Remotes.test:FireServer("ToggleSprint", true)
	end
end)
