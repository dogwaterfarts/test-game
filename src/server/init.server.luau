local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = require(ReplicatedStorage.Modules.Gun)

game.ReplicatedStorage.test.OnServerEvent:Connect(function(player: Player, Camera: CFrame)
	local p1Gun = Gun.new(100, 10, 1, 1, 1)
	Gun.Shoot(p1Gun, player, Camera)
	print("shot")
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(character)
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return
		end
		local hitbox = Instance.new("Part")
		hitbox.Name = "Hitbox"
		hitbox.Size = Vector3.new(3.2, 5.5, 1.8)
		hitbox.Transparency = 1
		hitbox.CanCollide = false
		hitbox.Anchored = true
		hitbox.Parent = character

		hitbox.CFrame = character.HumanoidRootPart.CFrame

		local connection
		connection = game:GetService("RunService").Heartbeat:Connect(function()
			hitbox.CFrame = character.HumanoidRootPart.CFrame

			if not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
				connection:Disconnect()
				hitbox:Destroy()
			end
		end)
	end)
	Player.CharacterRemoving:Connect(function(character)
		local hitbox = character:FindFirstChild("Hitbox")
		if hitbox then
			hitbox:Destroy()
		end
	end)
end)
