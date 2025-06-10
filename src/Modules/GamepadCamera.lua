-- GamepadCameraSensitivityModule.lua
local _UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local GamepadCamera = {}

-- Public sensitivity multiplier (you can change this!)
GamepadCamera.Sensitivity = 3 -- default 1.0

-- Internal state
local yaw = 0
local pitch = 0

local isActive = false

-- Constants
local rotationSpeed = Vector2.new(1, 0.77) * math.rad(4) -- base rotation speed, tune this
local actionName = "CustomGamepadLook"

local function onGamepadLook(_, _inputState, inputObject)
	-- if inputState ~= Enum.UserInputState.Change then
	-- 	return Enum.ContextActionResult.Pass
	-- end

	local delta = inputObject.Position

	if math.abs(inputObject.Position.Y) < 0.05 then
		delta = Vector2.new(delta.X, 0) -- ignore small movements
	end

	if math.abs(inputObject.Position.X) < 0.05 then
		delta = Vector2.new(0, delta.Y) -- ignore small movements
	end

	yaw = yaw + delta.X * rotationSpeed.X * GamepadCamera.Sensitivity
	pitch = math.clamp(pitch - delta.Y * rotationSpeed.Y * GamepadCamera.Sensitivity, -math.rad(85), math.rad(85))

	return Enum.ContextActionResult.Sink -- block default
end

-- Apply the updated rotation each frame
local function onRenderStep(dt)
	if not isActive then
		return
	end

	camera.CFrame = camera.CFrame:Lerp(
		(CFrame.new(camera.CFrame.Position) * CFrame.Angles(0, -yaw, 0) * CFrame.Angles(-pitch, 0, 0)),
		dt * 20
	)
end

function GamepadCamera:Enable(zoom, playerSensitivity)
	if isActive then
		return
	end
	isActive = true

	-- Adjust sensitivity based on zoom state
	-- camera.CameraType = Enum.CameraType.Scriptable
	GamepadCamera.Sensitivity = (playerSensitivity / zoom * 2) or 3

	-- Initialize yaw/pitch based on current camera direction
	local lookVector = camera.CFrame.LookVector
	yaw = math.atan2(lookVector.X, -lookVector.Z)
	pitch = math.asin(-lookVector.Y)

	ContextActionService:BindActionAtPriority(
		actionName,
		onGamepadLook,
		false,
		Enum.ContextActionPriority.High.Value + 1,
		Enum.KeyCode.Thumbstick2
	)

	RunService:BindToRenderStep(actionName, Enum.RenderPriority.Camera.Value + 1, onRenderStep)
end

function GamepadCamera:Disable(playerSensitivity)
	if not isActive then
		return
	end
	isActive = false

	-- camera.CameraType = Enum.CameraType.Custom
	GamepadCamera.Sensitivity = playerSensitivity or 3

	ContextActionService:UnbindAction(actionName)
	RunService:UnbindFromRenderStep(actionName)
end

return GamepadCamera
