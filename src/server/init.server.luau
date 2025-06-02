local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = require(ReplicatedStorage.Modules.Gun)
local currentGun = "Gun0" -- Default gun name

local PlayerGuns = {}

ReplicatedStorage.Remotes.test.OnServerEvent:Connect(function(player, Method, ...)
	if not PlayerGuns[player.UserId] then
		PlayerGuns[player.UserId] = {}
		return
	end

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	if ... and Method == "Shoot" then
		local Camera
		for _, v in pairs(...) do
			if v:IsA("CFrame") then
				Camera = v
			end
		end

		Gun.Shoot(PlayerGuns[player.UserId], player, Camera)
	end

	if Method == "ChangeGun" then
		local gunName = 1 - currentGun:sub(-1) -- Toggle between Gun0 and Gun1
		currentGun = "Gun" .. gunName

		Gun:ChangeGun(PlayerGuns[player.UserId], currentGun)
	end
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(character)
		local Gun0 = Gun.new(100, 10, 5, 30, 600)
		local Gun1 = Gun.new(1, 1, 1, 1, 1)
		PlayerGuns[Player.UserId].Gun0 = Gun0
		PlayerGuns[Player.UserId].Gun0 = Gun1

		Gun:CreateHitbox(character)
	end)

	Player.CharacterRemoving:Connect(function(character)
		local hitbox = character:FindFirstChild("Hitbox")
		if hitbox then
			hitbox:Destroy()
		end
	end)
end)
