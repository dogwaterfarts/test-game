local Bullet = require(script.Parent.BulletDrop) -- Assuming Bullet is in the same directory
local Gun = {}
Gun._index = Gun
local Characters = {}
local Waiting = {}

export type Gun = typeof(setmetatable(
	{} :: {
		range: number,
		power: number,
		weight: number,
		magSize: number,
		roundsPerMinute: number,
	},
	Gun
))

-- Iterate through the children of the item until we find a Model parent
local function FindFirstModelParent(item)
	while item.ClassName ~= "Model" do
		item = item.Parent

		if not item then
			return nil -- Return nil if no Model parent is found
		end
	end

	return item
end

-- Create a new gun with characteristics
function Gun.new(range, power, weight, magSize, roundsPerMinute): Gun
	local self = {
		range = range,
		power = power,
		weight = weight,
		magSize = magSize,
		roundsPerMinute = roundsPerMinute,
	}

	setmetatable(self, Gun)

	return self
end

function Gun:CreateHitbox(character: Model): ()
	if not character or not character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Hitbox") then
		return
	end

	-- Create a hitbox part for the character
	local hitbox = Instance.new("Part")
	hitbox.Name = "Hitbox"
	hitbox.Size = Vector3.new(3.2, 5.5, 1.8)
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.Anchored = true
	hitbox.Parent = character
	-- hitbox:SetNetworkOwner(nil) -- Set to nil to allow server-side control

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local Humanoid = character:FindFirstChild("Humanoid")

	hitbox.CFrame = rootPart.CFrame

	-- Ensure that the hitbox follows the player.
	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		hitbox.CFrame = rootPart.CFrame

		if not Humanoid or Humanoid.Health <= 0 then
			connection:Disconnect()
			hitbox:Destroy()
		end
	end)
end

function Gun:Shoot(currentGun: Gun, Player: Player, CameraCFrame: CFrame, resistance: number): ()
	if not Player.Character then
		return
	end

	if Waiting[Player.UserId] then
		return
	end

	local LookVector = CameraCFrame.LookVector

	-- Find Player Characters
	Characters = {}

	for _, person in game.Players:GetChildren() do
		if person ~= Player then
			table.insert(Characters, person.Character.Hitbox)
		end
	end

	--Create a RaycastParams object to only apply to the characters
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params:AddToFilter(Characters)

	Waiting[Player.UserId] = true
	task.delay(60 / currentGun.roundsPerMinute, function()
		Waiting[Player.UserId] = false
	end)

	-- Perform the raycast
	print(currentGun)
	local bullet = Bullet:newBullet(CameraCFrame.Position, LookVector * currentGun.range, params, resistance)
	-- Check if the bullet hit anything
	bullet.onHit.Event:Connect(function(hitResult)
		if hitResult then
			print("Hit detected:", hitResult.Instance:GetFullName())
			local hitParent = FindFirstModelParent(hitResult.Instance)

			if hitParent and hitParent:FindFirstChild("Humanoid") then
				hitParent.Humanoid:TakeDamage(currentGun.power)
			end
		end
	end)

	return
end

function Gun:ChangeGun(playerGuns: { [string]: Gun }, gunName: string): ()
	if not playerGuns[gunName] then
		error("Gun not found: " .. gunName)
	end

	local currentGun = playerGuns[gunName]
	print("Changed to gun:", gunName, "with range:", currentGun.range, "and power:", currentGun.power)
	return currentGun
end

return Gun

--[[
	Module for Gun functionality.
	Contains methods to create a gun and shoot it.
	Handles raycasting to detect hits on players.
]]
--
-- Usage:
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Gun = require(ReplicatedStorage.Modules.Gun)
-- Create a new gun instance with specified parameters:
-- local myGun = Gun.new(100, 10, 5, 30, 600)

-- Create a hitbox for the player's character when they join:
-- game.Players.PlayerAdded:Connect(function(player)
--     player.CharacterAdded:Connect(function(character)
--         Gun:CreateHitbox(character)
--     end)
-- end)

-- To shoot the gun, call the Shoot method with the player and camera CFrame:
-- local player = game.Players.LocalPlayer
-- local cameraCFrame = workspace.CurrentCamera.CFrame
-- Gun.Shoot(myGun, player, cameraCFrame)
