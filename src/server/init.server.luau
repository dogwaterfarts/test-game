local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerControls = require(ReplicatedStorage.Modules.PlayerControls)
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

		PlayerGuns[player.UserId][currentGun[player.UserId]]:Shoot(player, Camera, resistance)
		--print("Shot fired with gun:", currentGun[player.UserId])
		return
	end

	if Method == "ChangeGun" and args then
		local gunName = 1 - currentGun[player.UserId]:sub(-1) -- Toggle between Gun0 and Gun1
		currentGun[player.UserId] = "Gun" .. gunName

		Gun:ChangeGun(PlayerGuns[player.UserId], currentGun[player.UserId], player, args[1])
		return
	end

	if Method == "ChangeFireMode" and args then
		local gunName = args[1]
		if PlayerGuns[player.UserId][gunName] then
			currentGun[player.UserId] = gunName
			PlayerGuns[player.UserId][gunName]:ChangeFireMode()
		else
			print("Gun not found for player:", player.Name)
		end
		return
	end

	if Method == "Reload" then
		PlayerGuns[player.UserId][currentGun[player.UserId]]:Reload(player)
		return
	end
end)

ReplicatedStorage.Remotes.GetCurrentGun.OnServerInvoke = function(player, ...)
	if ... then
		print(PlayerGuns[player.UserId])
		return PlayerGuns[player.UserId]
	end
	return PlayerGuns[player.UserId][currentGun[player.UserId]]
end

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(character)
		PlayerGuns[Player.UserId] = {}

		-- Initialize guns for the player

		local Gun0 = Gun.new(1500, 10, 5, 30, 600, 0.5, 750, 3, 0.5, 5, "Spray", true, 8) -- Example parameters
		local Gun1 = Gun.new(1, 1, 1, 1, 600, 1, 1, 1, 1, 1, "Spray", false, 1)
		PlayerGuns[Player.UserId]["Gun0"] = Gun0
		PlayerGuns[Player.UserId]["Gun1"] = Gun1

		currentGun[Player.UserId] = "Gun0"

		print(currentGun, PlayerGuns) -- Set the initial gun

		Gun:CreateHitbox(character)
		PlayerControls.Load()
		Gun0:ChangeCharMovement(Player)
	end)

	Player.CharacterRemoving:Connect(function(character)
		local hitbox = character:FindFirstChild("Hitbox")
		if hitbox then
			hitbox:Destroy()
		end

		if PlayerGuns[Player.UserId] then
			PlayerGuns[Player.UserId] = nil
			currentGun[Player.UserId] = nil
		end
	end)

	Player.Chatted:Connect(function(message)
		if not tonumber(message) then
			return
		end
		print(message)

		local gunVelocity = tonumber(message)

		if PlayerGuns[Player.UserId][currentGun[Player.UserId]] then
			local newGun = Gun.new(gunVelocity, 10, 3.2, 30, 600, 0.5, 750, 3, 0.5, 1, "Spray", true, 8) -- Example parameters
			PlayerGuns[Player.UserId][currentGun[Player.UserId]] = newGun

			Gun:ChangeGun(
				PlayerGuns[Player.UserId],
				currentGun[Player.UserId],
				Player,
				ReplicatedStorage.Remotes.GetCurrentGun:InvokeServer()
			)
		end
	end)
end)
