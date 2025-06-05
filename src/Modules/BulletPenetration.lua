local BulletPenetration = {}
BulletPenetration.__index = BulletPenetration

function BulletPenetration:Penetrate(bullet, hit: RaycastResult, direction: Vector3)
	local newRayOrigin = hit.Position + (direction * 10000) / 2
	local newDirection = -direction * 10000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams:AddToFilter(hit.Instance)

	local raycastResult = workspace:Raycast(newRayOrigin, newDirection, raycastParams)

	if raycastResult then
		local distance = (raycastResult.Position - hit.Position).Magnitude
		local newVelocity, canPass = self:AdjustBulletProperties(bullet, distance)

		if canPass then
			return {
				distance = distance,
				newVelocity = newVelocity,
				hitPosition = raycastResult.Position,
				canPass = canPass,
			}
		end

		return {
			distance = nil,
			newVelocity = nil,
			hitPosition = nil,
			canPass = false,
		}
	end

	return {
		distance = 0,
		newVelocity = bullet.velocity,
		hitPosition = hit.Position,
		canPass = true,
	} -- No penetration, return original velocity
end

function BulletPenetration:AdjustBulletProperties(bullet, distance)
	print(distance)
	local canPass = true
	local changeInVelocity = bullet.velocity * math.exp(540 * (1 - distance) / bullet.weight) -- Example adjustment
	if changeInVelocity.Magnitude < 5 then
		changeInVelocity = Vector3.new(0, 0, 0)
		canPass = false
	end
	return changeInVelocity, canPass
end

return BulletPenetration
