local Workspace = game:GetService("Workspace")
local Gun = {}
Gun._index = Gun
local Characters = {}

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

local function FindFirstModelParent(item)
	while item.ClassName ~= "Model" do
		item = item.Parent
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

function Gun.Shoot(currentGun: Gun, Player: Player, CameraCFrame: CFrame): ()
	if not Player.Character then
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

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params:AddToFilter(Characters)

	local RaycastResult = Workspace:Raycast(CameraCFrame.Position, LookVector * currentGun.range, params)

	if not RaycastResult then
		print("no player")
		return
	end

	print("player")

	FindFirstModelParent(RaycastResult.Instance):FindFirstChild("Humanoid"):TakeDamage(currentGun.power)

	return
end

return Gun
