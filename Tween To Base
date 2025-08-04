-- TWEEN TO BASE FIXED BY WALVY v2 FINAL
-- WALVY COMMUNITY - STEAL A BRAINROT

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Fungsi untuk membeli item berdasarkan itemID -- ADDED
local function buyItem(itemID)
    pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("Net")
            :WaitForChild("RF/CoinsShopService/RequestBuy")
            :InvokeServer(itemID)
    end)
end

-- Fungsi toggle equip/unequip Speed Coil -- ADDED
local function toggleSpeedCoilEquip()
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    
    local equipped = character:FindFirstChild("Speed Coil")
    if equipped then
        equipped.Parent = backpack
    else
        local coil = backpack:FindFirstChild("Speed Coil")
        if coil then
            coil.Parent = character
        end
    end
end

-- Fungsi beli dan langsung equip Speed Coil -- ADDED
local function buyAndEquipSpeedCoil()
    buyItem("Speed Coil")
    task.wait(1) -- tunggu 2 detik biar item muncul di backpack
    toggleSpeedCoilEquip()
end

-- Panggil beli dan equip Speed Coil otomatis saat script jalan -- ADDED
buyAndEquipSpeedCoil()

-- Reconnect on respawn
player.CharacterAdded:Connect(function(c)
	character = c
	hrp = c:WaitForChild("HumanoidRootPart")
	humanoid = c:WaitForChild("Humanoid")
end)

-- Anti Death
local healthConn
local function applyAntiDeath(state)
	if humanoid then
		for _, s in ipairs({
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.PlatformStanding,
			Enum.HumanoidStateType.Seated
		}) do
			humanoid:SetStateEnabled(s, not not state)
		end
		if state then
			humanoid.Health = humanoid.MaxHealth
			if healthConn then healthConn:Disconnect() end
			healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
				if humanoid.Health <= 0 then
					humanoid.Health = humanoid.MaxHealth
				end
			end)
		else
			if healthConn then healthConn:Disconnect() end
		end
	end
end

-- Floating
local float = Instance.new("BodyVelocity")
float.MaxForce = Vector3.new(1e6, 1e6, 1e6)
float.Velocity = Vector3.new(0, 0, 0)

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "WalvyWalkGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 130)
frame.Position = UDim2.new(0.5, -120, 0.5, -65)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Text = "WALVY COMMUNITY"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local button = Instance.new("TextButton", frame)
button.Text = "▶ START TWEEN TO BASE"
button.Size = UDim2.new(0.8, 0, 0, 40)
button.Position = UDim2.new(0.1, 0, 0.25, 0)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel", frame)
status.Text = "Status: Idle"
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0.7, 0)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 14

-- Drag GUI
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	elseif input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

-- Core Logic
local active = false
local currentTween
local walkThread
local tweenSpeed = 80 -- kecepatan tween (semakin besar = lebih cepat)

local function getBasePosition()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	for _, plot in ipairs(plots:GetChildren()) do
		local sign = plot:FindFirstChild("PlotSign")
		local base = plot:FindFirstChild("DeliveryHitbox")
		if sign and base and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled then
			return base.Position
		end
	end
	return nil
end

local function tweenTo(pos)
	if not hrp then return end
	if currentTween then currentTween:Cancel() end
	local dist = (hrp.Position - pos).Magnitude
	local duration = dist / tweenSpeed
	currentTween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
	currentTween:Play()
	currentTween.Completed:Wait()
end

local function walkToBase()
	while active do
		local target = getBasePosition()
		if target then
			status.Text = "📍 Calculating Path..."
			local path = PathfindingService:CreatePath()
			path:ComputeAsync(hrp.Position, target)

			if path.Status == Enum.PathStatus.Success then
				status.Text = "🧭 Following Path"
				for _, wp in ipairs(path:GetWaypoints()) do
					if not active then return end
					tweenTo(wp.Position + Vector3.new(0, 6, 0))
				end
			else
				status.Text = "⚠️ Path Failed, Direct Walk"
				tweenTo(target + Vector3.new(0, 6, 0))
			end

			status.Text = "✅ Arrived"
			task.wait(1.5)
		else
			status.Text = "❌ Base Not Found, retrying..."
			task.wait(1)
		end
	end
end

button.MouseButton1Click:Connect(function()
	if not active then
		active = true
		applyAntiDeath(true)
		humanoid.WalkSpeed = 0
		float.Parent = hrp
		status.Text = "Starting..."
		button.Text = "■ STOP TWEEN TO BASE"
		button.BackgroundColor3 = Color3.fromRGB(180, 60, 60)

		walkThread = task.spawn(function()
			while active do
				walkToBase()
				task.wait(1)
			end
		end)
	else
		active = false
		if walkThread then task.cancel(walkThread) end
		if currentTween then currentTween:Cancel() end
		float.Parent = nil
		applyAntiDeath(false)
		humanoid.WalkSpeed = 16
		status.Text = "Status: Idle"
		button.Text = "▶ START TWEEN TO BASE"
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end
end)

-- Shortcut key 'T' untuk toggle tween to base (sesuai script kamu)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.T then
		button:Activate()
	end
end)

-- Shortcut key 'K' untuk toggle equip/unequip Speed Coil -- ADDED
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.K then
		toggleSpeedCoilEquip()
	end
end)
