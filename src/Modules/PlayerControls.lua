local Controls = {}
Controls.__index = Controls

export type Controller = typeof(setmetatable(
	{} :: {
		Sprinting: boolean,
	},
	Controls
))

function Controls.Load(): Controller
	local self = {
		Sprinting = false,
	}

	setmetatable(self, Controls)

	return self
end

function Controls:DisableSprint(Player: Player, newSpeed: number): ()
	if self.Sprinting then
		self.Sprinting = false
		local currentCharacter = Player.Character
		if currentCharacter and currentCharacter:FindFirstChild("Humanoid") then
			local humanoid = currentCharacter.Humanoid
			print(typeof(newSpeed))
			humanoid.WalkSpeed = newSpeed -- Reset walk speed to normal
		end
	end
end

function Controls:Sprint(Player: Player, weaponChanging: boolean, currentGun, toSprint: boolean): ()
	local currentCharacter = Player.Character
	if not currentCharacter or not currentCharacter:FindFirstChild("Humanoid") then
		return
	end

	local newArgument = 0.2 * (currentGun.weight - 6)

	local newWalkSpeed = 12 - 7.5 * math.atan(newArgument)

	if toSprint == false then
		self:DisableSprint(Player, newWalkSpeed)
		return
	end

	-- if weaponChanging and self.Sprinting then
	-- 	local humanoid = currentCharacter.Humanoid
	-- 	humanoid.WalkSpeed = newWalkSpeed * 1.6
	-- 	return
	-- end

	if weaponChanging then
		return
	end

	if not self.Sprinting and toSprint then
		-- If not sprinting, start sprinting
		self.Sprinting = true

		local humanoid = currentCharacter.Humanoid
		humanoid.WalkSpeed = newWalkSpeed * 1.6
		return
	end
	return
end

function Controls:Destroy(): ()
	if self.Sprinting then
		self.Sprinting = nil
	end
end

return Controls
