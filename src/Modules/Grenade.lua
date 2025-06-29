local Grenade = {}
Grenade.__index = Grenade

local CollectionService = game:GetService("CollectionService")

export type Grenade = typeof(setmetatable(
	{} :: {
		position: Vector3,
		velocity: Vector3,
		damage: number,
		radius: number,
		isExploded: boolean,
		lifetime: number,
		connection: RBXScriptConnection?,
	},
	Grenade
))

local airResistance = math.exp(0.3)
local gravity = Vector3.new(0, -game.Workspace.Gravity, 0)
local baseElasticity = 0.9 -- Base elasticity for damping

local function axisDamping(vComponent, normalComponent)
	local normalInfluence = math.abs(normalComponent)
	local velocityInfluence = math.abs(vComponent)
	return 1 - (1 - baseElasticity) * normalInfluence * (velocityInfluence / (velocityInfluence + 1))
end

function Grenade.new(position, velocity, damage, radius): Grenade
	local self = {
		position = position or Vector3.new(0, 0, 0),
		velocity = velocity or Vector3.new(0, 0, 0),
		damage = damage or 50, -- Default damage value
		radius = radius or 5, -- Default explosion radius
		isExploded = false,
		lifetime = 0, -- Time since the grenade was thrown
		connection = nil, -- Connection to the heartbeat event
	}

	setmetatable(self, Grenade)

	return self
end

function Grenade:Throw(): ()
	print(typeof(self))
	if not self then
		error("Grenade instance is nil")
	end

	if self.isExploded then
		error("Grenade has already exploded")
	end

	-- Simulate the grenade being thrown
	self.connection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		self:CalculateTrajectory(dt)
	end)
end

function Grenade:CalculateTrajectory(dt): ()
	print(typeof(self))
	if not self then
		error("Grenade instance is nil")
	end

	if self.isExploded then
		error("Grenade has already exploded")
	end

	if self.lifetime >= 5 then
		self:Explode()
		return true
	end

	self.lifetime += dt

	-- Update the grenade's position based on its velocity and gravity
	local oldPosition = self.position
	local newPosition = oldPosition + self.velocity * dt + gravity * dt * dt
	local newVelocity = self.velocity + gravity * dt - self.velocity * math.exp(-airResistance * dt) * dt

	-- if (newPosition - oldPosition).Magnitude < 0.5 or self.velocity.Magnitude < gravity.Y * dt then
	-- 	newVelocity = Vector3.new(0, 0, 0) -- Stop the grenade if it is too close to the point
	-- 	newPosition = oldPosition -- Keep the position unchanged
	-- end

	local raycastResult, hasStopped = self:HandleCollision(oldPosition, newPosition)

	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(1, 1, 1)
	newPart.Parent = workspace.BulletPath
	newPart.Color = Color3.new(0, 1, 0)
	newPart.Anchored = true
	newPart.Position = newPosition
	newPart.CanCollide = false

	if raycastResult then
		newVelocity = (newVelocity - 2 * (newVelocity:Dot(raycastResult.Normal)) * raycastResult.Normal)

		if hasStopped then
			newVelocity = Vector3.new(0, 0, 0) -- Stop the grenade if it is too close to the point
			newPosition = raycastResult.Position -- Keep the position unchangeds
		end

		local vX = newVelocity.X * axisDamping(newVelocity.X, raycastResult.Normal.X)
		local vY = newVelocity.Y * axisDamping(newVelocity.Y, raycastResult.Normal.Y)
		local vZ = newVelocity.Z * axisDamping(newVelocity.Z, raycastResult.Normal.Z)

		newVelocity = Vector3.new(vX, vY, vZ)
		print("Grenade collided with wall, new velocity:", newVelocity.Magnitude)

		newPosition = raycastResult.Position
	end

	self.position = newPosition
	self.velocity = newVelocity

	return false
end

function Grenade:HandleCollision(pointFrom, pointTo)
	local wallParams = RaycastParams.new()
	wallParams.FilterType = Enum.RaycastFilterType.Include
	wallParams:AddToFilter(CollectionService:GetTagged("Wall") or {})
	wallParams:AddToFilter(workspace.Baseplate)

	local direction = pointTo - pointFrom
	local distance = direction.Magnitude
	local hasStopped = false

	if distance < 0.3 then
		-- Make sure we raycast at least a small distance
		direction = direction.Unit * 3
		self.velocity = Vector3.new(0, 0, 0) -- Stop the grenade if it is too close to the point
		hasStopped = true
	end

	local raycastResult = workspace:Raycast(pointFrom, direction, wallParams)

	if raycastResult then
		return raycastResult, hasStopped
	else
		return nil, hasStopped
	end
end

function Grenade:Explode(): ()
	if self.isExploded then
		return
	end

	self.isExploded = true
	self.connection:Disconnect()

	-- Create an explosion effect
	local explosion = Instance.new("Explosion")
	explosion.Position = self.position
	explosion.BlastRadius = self.radius
	explosion.BlastPressure = 0 -- Set to 0 to prevent physical damage
	explosion.DestroyJointRadiusPercent = 0 -- Prevent destruction of joints
	explosion.Parent = workspace

	-- Apply damage to players within the explosion radius
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - self.position).Magnitude
			if distance <= self.radius then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid:TakeDamage(self.damage)
				end
			end
		end
	end

	print("Grenade exploded at position:", self.position)
end

return Grenade
