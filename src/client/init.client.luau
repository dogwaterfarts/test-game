game:GetService("UserInputService").InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.Q then
		game.ReplicatedStorage.test:FireServer(workspace.CurrentCamera.CFrame)
	end
end)
