local BulletPenetration = {}
BulletPenetration.__index = BulletPenetration

function BulletPenetration:PenetrationDistance(bullet, hit: RaycastResult, direction: Vector3)
	local newRayOrigin = hit.Position + (direction * 10000) / 2
	local newDirection = -direction * 10000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams:AddToFilter(hit.Instance)

	local raycastResult = workspace:Raycast(newRayOrigin, newDirection, raycastParams)

	if raycastResult then
		local distance = (raycastResult.Position - hit.Position).Magnitude
		self:AdjustBulletProperties(bullet, distance)
	end

	return 0
end

function BulletPenetration:AdjustBulletProperties(bullet, distance)
	local changeInVelocity = bullet.velocity * (1 - distance * bullet.weightPerRound / 1000) -- Example adjustment
	return changeInVelocity
end

return BulletPenetration
