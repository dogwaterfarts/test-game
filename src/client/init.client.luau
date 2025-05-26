local ReplicatedStorage = game:GetService("ReplicatedStorage")

game:GetService("UserInputService").InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.Q then
		ReplicatedStorage.Remotes.test:FireServer(workspace.CurrentCamera.CFrame)
	end
end)
