local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = require(ReplicatedStorage.Modules.Gun)

local currentGun = {} -- Initialize currentGun to an empty table
local PlayerGuns = {}

ReplicatedStorage.Remotes.test.OnServerEvent:Connect(function(player, Method, ...)
	if not PlayerGuns[player.UserId] then
		PlayerGuns[player.UserId] = {}
		return
	end

	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	local args = { ... }

	if args and Method == "Shoot" then
		local Camera
		local resistance
		for _, v in pairs(args) do
			if typeof(v) == "CFrame" then
				Camera = v
			end

			if typeof(v) == "number" then
				resistance = v
			end
		end

		Gun:Shoot(PlayerGuns[player.UserId][currentGun[player.UserId]], player, Camera, resistance)
		--print("Shot fired with gun:", currentGun[player.UserId])
		return
	end

	if Method == "ChangeGun" then
		local gunName = 1 - currentGun[player.UserId]:sub(-1) -- Toggle between Gun0 and Gun1
		currentGun[player.UserId] = "Gun" .. gunName

		Gun:ChangeGun(PlayerGuns[player.UserId], currentGun[player.UserId])
	end
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(character)
		PlayerGuns[Player.UserId] = {}

		-- Initialize guns for the player

		local Gun0 = Gun.new(1000, 10, 5, 30, 600, 0.5, 8) -- Example parameters
		local Gun1 = Gun.new(1, 1, 1, 1, 1, 1, 1)
		PlayerGuns[Player.UserId]["Gun0"] = Gun0
		PlayerGuns[Player.UserId]["Gun1"] = Gun1

		currentGun[Player.UserId] = "Gun0" -- Set the initial gun

		Gun:CreateHitbox(character)
	end)

	Player.CharacterRemoving:Connect(function(character)
		local hitbox = character:FindFirstChild("Hitbox")
		if hitbox then
			hitbox:Destroy()
		end

		if PlayerGuns[Player.UserId] then
			PlayerGuns[Player.UserId] = nil
		end
	end)
end)
