local BulletPenetration = {}
BulletPenetration.__index = BulletPenetration

function BulletPenetration:PenetrationDistance(hit: RaycastResult, direction: Vector3)
	local newRayOrigin = hit.Position + (direction * 10000) / 2
	local newDirection = -direction * 10000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams:AddToFilter(hit.Instance)

	local raycastResult = workspace:Raycast(newRayOrigin, newDirection, raycastParams)

	if raycastResult then
		local distance = (raycastResult.Position - hit.Position).Magnitude
		return distance
	end

	return 0
end

return BulletPenetration
