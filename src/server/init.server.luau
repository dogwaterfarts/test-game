local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = require(ReplicatedStorage.Modules.Gun)

local PlayerGuns = {}

ReplicatedStorage.Remotes.test.OnServerEvent:Connect(function(player, Camera)
	if not PlayerGuns[player.UserId] then
		return
	end

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	Gun.Shoot(PlayerGuns[player.UserId], player, Camera)
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(character)
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local p1Gun = Gun.new(100, 10, 5, 30, 600)
		PlayerGuns[Player.UserId] = p1Gun

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
