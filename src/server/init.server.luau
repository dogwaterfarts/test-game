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
		local p1Gun = Gun.new(100, 10, 5, 30, 600)
		PlayerGuns[Player.UserId] = p1Gun

		Gun:CreateHitbox(character)
	end)

	Player.CharacterRemoving:Connect(function(character)
		local hitbox = character:FindFirstChild("Hitbox")
		if hitbox then
			hitbox:Destroy()
		end
	end)
end)
