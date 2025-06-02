local Bullet = {}
Bullet._index = Bullet
local RunS = game:GetService("RunService")

export type BulletObject = typeof({} :: {
	position: Vector3,
	velocity: Vector3,
	onHit: Instance,
	onTimeout: Instance,
	lifeTime: number,
	gravity: Vector3,
	airResistance: number,
	params: RaycastParams,
})

local MAX_LIFETIME = 4 --seconds
local GRAVITY = Vector3.new(0, -game.Workspace.Gravity, 0)
-- local HIT_DETECT_RAYCAST_PARAMS = RaycastParams.new() --Set this up how you want it

function Bullet:newBullet(
	startPosition: Vector3,
	startVelocity: Vector3,
	params: RaycastParams,
	resistance: number
): BulletObject
	print("Creating new bullet")
	local onHitEventObject = Instance.new("BindableEvent")
	local onTimeoutEventObject = Instance.new("BindableEvent")

	local bullet = {
		position = startPosition,
		velocity = startVelocity,
		onHit = onHitEventObject,
		onTimeout = onTimeoutEventObject,
		gravity = GRAVITY,
		airResistance = resistance,
		lifeTime = 0,
		params = params,
	}

	bullet.updateConnection = RunS.Heartbeat:Connect(function(dt)
		print("Updating bullet")
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
	newPart.Parent = workspace
	newPart.Color = Color3.new(1, 0, 0)
	newPart.Anchored = true
	newPart.Position = newPosition
	newPart.CanCollide = false

	bullet.position = newPosition
	bullet.velocity = bullet.velocity + bullet.gravity * dt - bullet.velocity * bullet.airResistance * dt

	--Check if the bullet hit something
	local hitResult = Bullet:hitDetect(bullet, oldPosition, newPosition)

	--if bullet.position.Y < -10 then
	--	Bullet:destroyBullet()
	--	return
	--end

	if hitResult then
		bullet.onHit:Fire(hitResult)
		Bullet:destroyBullet(bullet)
		return
	end

	--Destroy the bullet if it doesn't hit anything

	bullet.lifeTime += dt

	if bullet.lifeTime > MAX_LIFETIME then
		bullet.onHit:Fire()
		Bullet:destroyBullet(bullet)
		return
	end
end

function Bullet:hitDetect(bullet, pointFrom, pointTo)
	return game.Workspace:Raycast(pointFrom, pointTo - pointFrom, bullet.params)
end

function Bullet:destroyBullet(bullet)
	--Removed references to allow garbage collection
	bullet.onHit:Destroy() --Allows BindableEvent to be GC'ed, and breaks any connections to it
	bullet.onTimeout:Destroy() --Same
	bullet.updateConnection:Disconnect()
end

return Bullet
