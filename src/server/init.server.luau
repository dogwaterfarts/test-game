local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.cmdr)

Cmdr:RegisterDefaultCommands()

game.ReplicatedStorage.test.OnServerEvent:Connect(function(player: Player, Camera: CFrame)
	local Gun = require(game.ReplicatedStorage.Shared.Modules.Gun)
	local p1Gun = Gun.new(100, 10, 1, 1, 1)
	Gun.Shoot(p1Gun, player, Camera)
	print("shot")
end)
