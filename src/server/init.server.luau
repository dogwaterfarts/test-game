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
		for _, v in pairs(args) do
			if type(v) then
				Camera = v
			end
		end

		Gun:Shoot(PlayerGuns[player.UserId][currentGun], player, Camera)
		print("Shot fired with gun:", currentGun[player.UserId])
		return
	end

	if Method == "ChangeGun" then
		local gunName = 1 - currentGun[player.UserId]:sub(-1) -- Toggle between Gun0 and Gun1
		currentGun[player.UserId] = "Gun" .. gunName

		currentGun[player.UserId] = Gun:ChangeGun(PlayerGuns[player.UserId], currentGun[player.UserId])
	end
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(character)
		PlayerGuns[Player.UserId] = PlayerGuns[Player.UserId] or {}
		-- Initialize guns for the player

		local Gun0 = Gun.new(100, 10, 5, 30, 600)
		local Gun1 = Gun.new(1, 1, 1, 1, 1)
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
