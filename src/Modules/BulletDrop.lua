local Bullet = {}
Bullet.__index = Bullet
local CollectionService = game:GetService("CollectionService")
local RunS = game:GetService("RunService")
local BulletPenetration = require(script.Parent.BulletPenetration)

export type BulletObject = typeof({} :: {
	position: Vector3,
	velocity: Vector3,
	onHit: Instance,
	onTimeout: Instance,
	lifeTime: number,
	gravity: Vector3,
	airResistance: number,
	params: RaycastParams,
	weight: number,
	wallParams: RaycastParams,
	updateConnection: RBXScriptConnection,
})

local MAX_LIFETIME = 12 --seconds
local GRAVITY = Vector3.new(0, -game.Workspace.Gravity, 0)
-- local HIT_DETECT_RAYCAST_PARAMS = RaycastParams.new() --Set this up how you want it

-- local dragCoefficient = 0.47 -- Sphere, adjust as needed
-- local airDensity = 1.225 -- kg/m^3 at sea level
-- local bulletArea = math.pi * (0.005 ^ 2) -- Example: 1cm radius bullet

function Bullet:newBullet(
	startPosition: Vector3,
	startVelocity: Vector3,
	weight: number,
	params: RaycastParams,
	spread: number
): BulletObject
	-- print("Creating new bullet")
	local onHitEventObject = Instance.new("BindableEvent")
	local onTimeoutEventObject = Instance.new("BindableEvent")

	if not workspace:FindFirstChild("BulletPath") then
		local bulletPath = Instance.new("Folder")
		bulletPath.Name = "BulletPath"
		bulletPath.Parent = workspace
	end

	local wallParams = RaycastParams.new()
	wallParams.FilterType = Enum.RaycastFilterType.Include
	wallParams:AddToFilter(CollectionService:GetTagged("Wall") or {})

	startVelocity = startVelocity + Random.new(math.random(0, 10000000)):NextUnitVector() * spread * 10 -- Add spread to the bullet velocity

	local bullet = {
		position = startPosition,
		velocity = startVelocity,
		onHit = onHitEventObject,
		onTimeout = onTimeoutEventObject,
		gravity = GRAVITY,
		airResistance = math.exp(0.3), -- Use a default value if resistance is not provided
		lifeTime = 0,
		params = params,
		weight = weight or 20, -- Default weight if not provided
		wallParams = wallParams,
	}

	bullet.updateConnection = RunS.Heartbeat:Connect(function(dt)
		-- print("Updating bullet")
		Bullet:updateBullet(bullet, dt)
	end)

	return bullet
end

function Bullet:updateBullet(bullet, dt): ()
	--Move the bullet along the parabola
	local oldPosition = bullet.position
	local newPosition = oldPosition + bullet.velocity * dt + bullet.gravity * dt * dt

	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(1, 1, 1)
	newPart.Parent = workspace.BulletPath
	newPart.Color = Color3.new(1, 0, 0)
	newPart.Anchored = true
	newPart.Position = newPosition
	newPart.CanCollide = false

	bullet.position = newPosition
	-- -- Apply drag (air resistance) using a simple linear drag model: F_drag = -k * v
	-- -- More accurate drag: F_drag = -0.5 * C_d * rho * A * v^2 * v_unit
	-- -- For simplicity, we'll use linear drag here, but you can replace with quadratic drag if needed.

	-- -- Linear drag:
	-- local dragForce = -bullet.airResistance * bullet.velocity
	-- bullet.velocity = bullet.velocity + dragForce * dt

	-- Calculated velocity where the bullet decelerates over time due to air resistance with respect to its velocity:
	bullet.velocity = bullet.velocity
		+ bullet.gravity * dt
		- bullet.velocity * math.exp(-bullet.airResistance * dt) * dt

	-- Quadratic drag (more realistic for bullets):
	-- local v = bullet.velocity.Magnitude
	-- local dragForceMag = 0.5 * dragCoefficient * airDensity * bulletArea * v * v
	-- local dragForce = -dragForceMag * bullet.velocity.Unit
	-- bullet.velocity = bullet.velocity + bullet.gravity * dt + (dragForce * bullet.velocity.Magnitude / 2) * dt
	-- print(dragForce)

	--Check if the bullet hit something
	local hitResult = Bullet:hitDetect(bullet, oldPosition, newPosition, dt)

	if bullet.position.Y < -10 then
		bullet.onHit:Fire(newPosition)
		Bullet:destroyBullet(bullet)
		return
	end

	if hitResult then
		bullet.onHit:Fire(hitResult)
		Bullet:destroyBullet(bullet)
		return
	end

	--Destroy the bullet if it doesn't hit anything

	bullet.lifeTime += dt

	if bullet.lifeTime > MAX_LIFETIME then
		bullet.onHit:Fire(newPosition)
		Bullet:destroyBullet(bullet)
		return
	end
end

function Bullet:hitDetect(bullet, pointFrom, pointTo, dt)
	local raycastResult = workspace:Raycast(pointFrom, pointTo - pointFrom, bullet.wallParams)
	local canPass

	if raycastResult and raycastResult.Instance.CanCollide then
		print("Raycast result:", raycastResult)
		local penetrationResult = BulletPenetration:Penetrate(bullet, raycastResult, bullet.velocity.Unit)

		if not penetrationResult.canPass then
			Bullet:destroyBullet(bullet)
			canPass = false
			return nil
		end

		if penetrationResult.newVelocity and penetrationResult.canPass then
			bullet.velocity = penetrationResult.newVelocity
			bullet.position = penetrationResult.hitPosition
			pointFrom = penetrationResult.hitPosition
			pointTo = pointFrom + bullet.velocity * dt
			canPass = true
		end

		print(penetrationResult.canPass)
	end

	if not canPass then
		return nil
	end

	return game.Workspace:Raycast(pointFrom, pointTo - pointFrom, bullet.params)
end

function Bullet:destroyBullet(bullet: BulletObject): ()
	--Removed references to allow garbage collection
	bullet.onHit:Destroy() --Allows BindableEvent to be GC'ed, and breaks any connections to it
	bullet.onTimeout:Destroy() --Same
	bullet.updateConnection:Disconnect()
end

return Bullet
--[[
	Module for creating and managing bullets in a game.
	Handles bullet physics, hit detection, and lifetime management.
	
	Usage:
		local Bullet = require(path.to.Bullet)
		local newBullet = Bullet:newBullet(startPosition, startVelocity, params, resistance)
		newBullet.onHit.Event:Connect(function(hitResult) ... end)
]]
