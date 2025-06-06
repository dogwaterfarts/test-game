local Controls = {}
Controls.__index = Controls

local Sprinting = {}

function Controls.Load(Player: Player): ()
	local currentCharacter = Player.Character
	if Sprinting[Player.UserId] or not currentCharacter or not currentCharacter:FindFirstChild("Humanoid") then
		return
	end

	Sprinting[Player.UserId] = false
end

function Controls:Sprint(Player: Player, weaponChanging: boolean): ()
	local currentCharacter = Player.Character
	if not currentCharacter or not currentCharacter:FindFirstChild("Humanoid") then
		return
	end

	if weaponChanging and Sprinting[Player.UserId] == true then
		local humanoid = currentCharacter.Humanoid
		humanoid.WalkSpeed = humanoid.WalkSpeed * 1.6
		return
	end

	if Sprinting[Player.UserId] then
		-- If already sprinting, stop sprinting
		Sprinting[Player.UserId] = false
		local humanoid = currentCharacter.Humanoid
		humanoid.WalkSpeed = humanoid.WalkSpeed / 1.6 -- Reset walk speed to normal
		return
	end

	if not Sprinting[Player.UserId] then
		-- If not sprinting, start sprinting
		Sprinting[Player.UserId] = true

		local humanoid = currentCharacter.Humanoid
		humanoid.WalkSpeed = humanoid.WalkSpeed * 1.6
		return
	end
	return
end

function Controls.Remove(Player: Player): ()
	if Sprinting[Player.UserId] then
		Sprinting[Player.UserId] = nil
	end
end

return Controls
