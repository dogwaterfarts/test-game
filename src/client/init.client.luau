local ReplicatedStorage = game:GetService("ReplicatedStorage")

game:GetService("UserInputService").InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.Q then
		ReplicatedStorage.Remotes.test:FireServer("Shoot", workspace.CurrentCamera.CFrame)
	elseif key.KeyCode == Enum.KeyCode.E then
		ReplicatedStorage.Remotes.test:FireServer("ChangeGun")
	end
end)
