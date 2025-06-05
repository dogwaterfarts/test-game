local Bullet = require(script.Parent.BulletDrop) -- Assuming Bullet is in the same directory
local Gun = {}
Gun._index = Gun
local Characters = {}
local Waiting = {}

export type Gun = typeof(setmetatable(
	{} :: {
		initVelocity: number,
		power: number,
		weight: number,
		magSize: number,
		roundsPerMinute: number,
		caliber: number,
		weightPerRound: number,
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
function Gun.new(initVelocity, power, weight, magSize, roundsPerMinute, caliber, weightPerRound): Gun
	local self = {
		initVelocity = initVelocity,
		power = power,
		weight = weight,
		magSize = magSize,
		roundsPerMinute = roundsPerMinute,
		caliber = caliber or 0.01, -- Default caliber if not provided
		weightPerRound = weightPerRound or 100, -- Default weight per round if not provided
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
	params:AddToFilter(workspace.Baseplate) -- Include the Baseplate

	Waiting[Player.UserId] = true
	task.delay(60 / currentGun.roundsPerMinute, function()
		Waiting[Player.UserId] = false
	end)

	-- Perform the raycast
	print(currentGun)
	local bullet = Bullet:newBullet(
		CameraCFrame.Position,
		LookVector * currentGun.initVelocity,
		currentGun.weightPerRound,
		params,
		resistance
	)
	-- Check if the bullet hit anything
	bullet.onHit.Event:Connect(function(hitResult)
		if typeof(hitResult) == "Vector3" then
			local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
			local newHitPosition = Vector3.new(hitResult.X, HRP.Position.Y, hitResult.Z)
			local distance = (newHitPosition - CameraCFrame.Position).Magnitude
			print(distance)
			return
		end

		if hitResult then
			print("Hit detected:", hitResult.Instance:GetFullName())
			if hitResult.Instance == workspace.Baseplate then
				print("Hit the ground") -- Change color to indicate hit
				local distance = (hitResult.Position - CameraCFrame.Position).Magnitude
				print("Distance to hit:", distance)
			end

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
	print("Changed to gun:", gunName, "with initial velocity:", currentGun.initVelocity, "and power:", currentGun.power)
	return currentGun
end

return Gun

--[[
	Module for Gun functionality.
	Contains methods to create a gun and shoot it.
	Handles raycasting to detect hits on players.
]]

--[[
	Usage:
	local Gun = require(script.Parent.Gun)
	local myGun = Gun.new(1500, 10, 5, 30, 600, 0.5, 750)
	myGun:CreateHitbox(player.Character)
	myGun:Shoot(player, cameraCFrame)
	myGun:ChangeGun(playerGuns, "Gun1")
]]
--[[
	Notes:
	- The gun's characteristics can be adjusted based on game requirements.
	- The raycasting logic can be extended to include more complex hit detection.
	- Ensure that the hitbox is properly set up in the player's character model.
	- The `Waiting` table prevents rapid firing of the gun.
]]
--[[
	- The `Characters` table is used to filter raycasts to only hit other players.
	- The `FindFirstModelParent` function is used to find the parent model of a hit instance.
	- The `onHit` event is used to handle bullet hit detection and apply damage.
]]
--[[
	- The `CreateHitbox` function creates a hitbox for the player character to detect hits.
	- The `Shoot` function handles the shooting logic, including raycasting and hit detection.
	- The `ChangeGun` function allows switching between different guns for the player.
]]
