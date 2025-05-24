local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- Configurable, and you can choose multiple keys
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })

wait(4)

game.ReplicatedStorage.test:FireServer(workspace.CurrentCamera.CFrame)

game:GetService("UserInputService").InputBegan:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.Q then
		local Gun = require(game.ReplicatedStorage.Shared.Modules.Gun)
		local p1Gun = Gun.new(1, 1000, 1, 1, 1)
		Gun.Shoot(p1Gun, game.Players.LocalPlayer, workspace.CurrentCamera.CFrame)
		print("shot")
	end
end)
