local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.cmdr)
local Networker = require(ReplicatedStorage.Packages.networker)
local Gun = require(ReplicatedStorage.Shared.Modules.Gun)

Cmdr:RegisterDefaultCommands()

game.ReplicatedStorage.test.OnServerEvent:Connect(function(player: Player, Camera: CFrame)
	local p1Gun = Gun.new(100, 10, 1, 1, 1)
	Gun.Shoot(p1Gun, player, Camera)
	print("shot")
end)

local myService = {}

function myService:init()
	-- initialize networker to the service/object
	self.networker = Networker.server.new("myService", self, {
		self.Damage,
	})
end

function myService:Damage(_: Player, player: Player, damage: number)
	if not player.Character then
		return
	end

	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:TakeDamage(damage)
	end
end
