-- Ensure WindUI is loaded correctly      
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local HttpService = game:GetService("HttpService")      
local StarterGui = game:GetService("StarterGui")      
local Players = game:GetService("Players")      
local LocalPlayer = Players.LocalPlayer      
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create config folder if not exists      
local CONFIG_FOLDER = "Walvy-Comunity"      
if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end      

-- Auto-load file      
local autoFile = "WalvyAutoLoad.json"      
local autoLoadEnabled = false      
if isfile(autoFile) then      
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(autoFile)) end)      
    if success and data.enabled ~= nil then      
        autoLoadEnabled = data.enabled      
    end      
end      

-- Create GUI Window      
local Window = WindUI:CreateWindow({      
    Title = "Walvy Community",      
    Icon = "rbxassetid://85151307796718",      
    IconThemed = true,      
    Author = "VERSION : FREEMIUM",      
    Folder = CONFIG_FOLDER,      
    Size = UDim2.fromOffset(600, 480),      
    Theme = "Dark",      
    SideBarWidth = 170,      
    Transparent = false,   
    Center = true,
    Draggable = true
})   

-- Main Tab      
local mainTab = Window:Tab({ Title = "Main", Icon = "package" })      

-- Infinity Jump Toggle      
local infinityJumpEnabled = false
local connection

local infinityJumpToggle = mainTab:Toggle({
    Title = "Infinity Jump",
    Value = false,
    Callback = function(state)
        infinityJumpEnabled = state
        if connection then
            connection:Disconnect()
            connection = nil
        end
        if state then
            connection = UIS.JumpRequest:Connect(function()
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if humanoid and hrp then
                        if humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            if not humanoid.FloorMaterial or humanoid.FloorMaterial == Enum.Material.Air then
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                            end
                        end
                    end
                end
            end)
            WindUI:Notify({
                Title = "Infinity Jump",
                Content = "Enabled",
                Icon = "rbxassetid://85151307796718"
            })
        else
            WindUI:Notify({
                Title = "Infinity Jump",
                Content = "Disabled",
                Icon = "rbxassetid://85151307796718"
            })
        end
    end
})

-- Speed Hack Toggle
local speedOn = false
local speedConnection

local function buyAndEquipItem(itemID)
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage")
            :WaitForChild("Packages")
            :WaitForChild("Net")
            :WaitForChild("RF/CoinsShopService/RequestBuy")
            :InvokeServer(itemID)
    end)

    if success then
        print("Berhasil membeli: " .. itemID)

        -- Tunggu sedikit agar item masuk ke Backpack
        task.delay(0.5, function()
            local backpack = LocalPlayer:WaitForChild("Backpack")
            local tool = backpack:FindFirstChild(itemID)
            if tool then
                -- Equip lalu unequip
                local character = LocalPlayer.Character
                if character then
                    tool.Parent = character -- Equip
                    task.wait(0.25)
                    tool.Parent = backpack -- Unequip
                    print("Equip + Unequip selesai")
                end
            else
                warn("Tool tidak ditemukan di Backpack:", itemID)
            end
        end)
    else
        warn("Gagal membeli item:", err)
    end
end

-- Speed function
local function applySpeed()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = 70
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if humanoid.WalkSpeed ~= 70 then
                humanoid.WalkSpeed = 70
            end
        end)
    end
end

-- apply saat respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.spawn(function()
        task.wait(1)
        if speedOn then applySpeed() end
    end)
end)

-- WindUI Toggle
local speedToggle = mainTab:Toggle({
    Title = "Speed Hack (70)",
    Value = false,
    Callback = function(state)
        speedOn = state
        if speedOn then
            applySpeed()
            buyAndEquipItem("Speed Coil")

            WindUI:Notify({
                Title = "Speed Hack",
                Content = "Enabled Speedhack",
                Icon = "rbxassetid://85151307796718"
            })
        else
            if speedConnection then speedConnection:Disconnect() end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildWhichIsA("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end

            WindUI:Notify({
                Title = "Speed Hack",
                Content = "Disabled",
                Icon = "rbxassetid://85151307796718"
            })
        end
    end
})

-- God Mode Toggle
local godOn = false
local healthConn
local charAddedConn

local function applyGodMode()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = 100
        hum.Health = 100
        if healthConn then healthConn:Disconnect() end
        healthConn = hum.HealthChanged:Connect(function(h)
            if godOn and h < 100 then
                hum.Health = 100
            end
        end)
    end
end

local godToggle = mainTab:Toggle({
    Title = "God Mode",
    Value = false,
    Callback = function(state)
        godOn = state
        if godOn then
            applyGodMode()
            if charAddedConn then charAddedConn:Disconnect() end
            charAddedConn = LocalPlayer.CharacterAdded:Connect(function()
                wait(1)
                if godOn then applyGodMode() end
            end)

            WindUI:Notify({
                Title = "God Mode",
                Content = "Enabled",
                Icon = "rbxassetid://85151307796718"
            })
        else
            if healthConn then healthConn:Disconnect() end
            if charAddedConn then charAddedConn:Disconnect() end

            WindUI:Notify({
                Title = "God Mode",
                Content = "Disabled",
                Icon = "rbxassetid://85151307796718"
            })
        end
    end
})

-- Anti Ragdoll Toggle
local arOn = false
local ragdollConn
local isFrozen = false

local function liftAndFreeze(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and not isFrozen then
        isFrozen = true
        hrp.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.Anchored = true
    end
end

local function unfreeze(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp and isFrozen then
        hrp.Anchored = false
        isFrozen = false
    end
end

local function monitorCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not hrp then return end

    if ragdollConn then ragdollConn:Disconnect() end
    ragdollConn = RunService.Heartbeat:Connect(function()
        if not arOn then return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.Physics then
            liftAndFreeze(character)
        else
            unfreeze(character)
        end
    end)
end

local antiRagdollToggle = mainTab:Toggle({
    Title = "Anti Ragdoll",
    Value = false,
    Callback = function(state)
        arOn = state
        local char = LocalPlayer.Character
        if arOn then
            if char then monitorCharacter(char) end
            LocalPlayer.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                if arOn then monitorCharacter(newChar) end
            end)
            WindUI:Notify({
                Title = "Anti Ragdoll",
                Content = "Enabled - Freeze saat jatuh/ragdoll",
                Icon = "rbxassetid://85151307796718"
            })
        else
            if ragdollConn then ragdollConn:Disconnect() ragdollConn = nil end
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and isFrozen then
                    hrp.Anchored = false
                    isFrozen = false
                end
            end
            WindUI:Notify({
                Title = "Anti Ragdoll",
                Content = "Disabled",
                Icon = "rbxassetid://85151307796718"
            })
        end
    end
})

local atsOn = false
local atsLoop2

local blacklistNames = {"trap", "kill", "lava", "spike", "damage", "void", "web", "slinger"}
local constraintTypes = {
    "RopeConstraint",
    "AlignPosition",
    "AlignOrientation",
    "VectorForce",
    "LinearVelocity",
    "BodyPosition",
    "BodyVelocity",
    "BodyForce",
    "BodyGyro",
}

local function isTrap(obj)
    local name = tostring(obj.Name):lower()
    for _, word in ipairs(blacklistNames) do
        if name:find(word) then
            return true
        end
    end
    return false
end

-- Fungsi hapus trap dan constraint
local function cleanTraps()
    -- Cek folder yang spesifik, misal workspace.Plots atau workspace.Traps (ubah sesuai game)
    local container = workspace:FindFirstChild("Plots") or workspace -- fallback ke workspace

    for _, obj in ipairs(container:GetDescendants()) do
        if obj:IsA("BasePart") and isTrap(obj) then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function cleanConstraints()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp then
            humanoid.Health = humanoid.MaxHealth
            humanoid.PlatformStand = false
            humanoid.Sit = false
            hrp.Anchored = false

            for _, v in ipairs(hrp:GetChildren()) do
                if table.find(constraintTypes, v.ClassName) then
                    pcall(function() v:Destroy() end)
                end
            end

            hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
    end
end

local atsOn = false
local atsConn

local constraintTypes = {
    "RopeConstraint",
    "AlignPosition",
    "AlignOrientation",
    "VectorForce",
    "LinearVelocity",
    "BodyPosition",
    "BodyVelocity",
    "BodyForce",
    "BodyGyro",
}

local function cleanConstraints(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and humanoid) then return false end

    local hadConstraints = false

    for _, v in ipairs(hrp:GetChildren()) do
        if table.find(constraintTypes, v.ClassName) then
            hadConstraints = true
            pcall(function() v:Destroy() end)
        end
    end

    if hadConstraints then
        humanoid.PlatformStand = false
        humanoid.Sit = false
        hrp.Anchored = false
        hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        humanoid.Health = humanoid.MaxHealth
    end

    return hadConstraints
end

local antiTrapReactiveToggle = mainTab:Toggle({
    Title = "Anti Trap Reactive",
    Value = false,
    Callback = function(state)
        atsOn = state

        if atsConn then
            atsConn:Disconnect()
            atsConn = nil
        end

        if atsOn then
            local char = LocalPlayer.Character
            if char then
                -- cek tiap 0.2 detik apakah ada constraint di character
                atsConn = task.spawn(function()
                    while atsOn do
                        local char = LocalPlayer.Character
                        if char then
                            if cleanConstraints(char) then
                                WindUI:Notify({
                                    Title = "Anti Trap Reactive",
                                    Content = "Constraint terdeteksi dan dihapus!",
                                    Icon = "rbxassetid://85151307796718"
                                })
                            end
                        end
                        task.wait(0.2)
                    end
                end)
            end

            LocalPlayer.CharacterAdded:Connect(function(newChar)
                task.wait(1)
                if atsOn then
                    -- restart cek saat karakter baru spawn
                    if atsConn then
                        atsConn:Disconnect()
                        atsConn = nil
                    end
                    atsConn = task.spawn(function()
                        while atsOn do
                            if cleanConstraints(newChar) then
                                WindUI:Notify({
                                    Title = "Anti Trap Reactive",
                                    Content = "Constraint terdeteksi dan dihapus!",
                                    Icon = "rbxassetid://85151307796718"
                                })
                            end
                            task.wait(0.2)
                        end
                    end)
                end
            end)
            WindUI:Notify({
                Title = "Anti Trap Reactive",
                Content = "Aktif",
                Icon = "rbxassetid://85151307796718"
            })
        else
            WindUI:Notify({
                Title = "Anti Trap Reactive",
                Content = "Nonaktif",
                Icon = "rbxassetid://85151307796718"
            })
        end
    end
})

local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye-off" })
local playerESPEnabled = false

-- Folder penyimpanan ESP
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "PlayerESP"
ESPFolder.Parent = game.CoreGui

-- Buat ESP untuk satu player
local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    if ESPFolder:FindFirstChild(player.Name) then return end
    if not player.Character or not player.Character:FindFirstChild("Head") then return end

    local container = Instance.new("Folder")
    container.Name = player.Name
    container.Parent = ESPFolder

    -- Highlight untuk karakter
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Parent = container

    -- Billboard untuk nama
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Adornee = player.Character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = container

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard

    -- Tambah box pada spine (UpperTorso atau Torso)
    local spinePart = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
    if spinePart then
        local spineBox = Instance.new("BoxHandleAdornment")
        spineBox.Adornee = spinePart
        spineBox.AlwaysOnTop = true
        spineBox.ZIndex = 0
        spineBox.Size = spinePart.Size
        spineBox.Color3 = Color3.fromRGB(255, 0, 0)
        spineBox.Transparency = 0.3
        spineBox.Parent = container
    end
end

-- Update semua ESP
local function UpdatePlayerESP()
    if not playerESPEnabled then
        ESPFolder:ClearAllChildren()
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            CreatePlayerESP(p)
        end
    end
end

-- Loop update
RunService.Heartbeat:Connect(UpdatePlayerESP)

-- Tambah player baru
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if playerESPEnabled then
            CreatePlayerESP(p)
        end
    end)
end)

-- Toggle ESP dari WindUI
local playerESPToggle = VisualTab:Toggle({
    Title = "Player ESP",
    Value = false,
    Callback = function(state)
        playerESPEnabled = state
        WindUI:Notify({
            Title = "Player ESP",
            Content = state and "Enabled" or "Disabled",
            Icon = "rbxassetid://85151307796718"
        })

        if not state then
            ESPFolder:ClearAllChildren()
        end
    end
})

-- esp timer base
local activeLockTimerESPParts = {}
local lockTimerESPEnabled = false

local function clearLockTimerESP()
    for _, esp in ipairs(activeLockTimerESPParts) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    table.clear(activeLockTimerESPParts)
end

local function createLockTimerESP(targetPart, text)
    if not targetPart or not targetPart:IsA("BasePart") then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 1
    highlight.Adornee = targetPart
    highlight.Parent = targetPart

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.Adornee = targetPart
    billboard.AlwaysOnTop = true
    billboard.Name = "LockTimerESP"
    billboard.Parent = targetPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    table.insert(activeLockTimerESPParts, billboard)
    table.insert(activeLockTimerESPParts, highlight)
end

-- Loop berjalan terus selama ESP aktif
RunService.Heartbeat:Connect(function()
    if not lockTimerESPEnabled then
        clearLockTimerESP()
        return
    end

    clearLockTimerESP()

    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, plot in ipairs(plots:GetChildren()) do
        local plotBlock = plot:FindFirstChild("PlotBlock", true)
        if plotBlock then
            local main = plotBlock:FindFirstChild("Main")
            if main and main:IsA("BasePart") then
                local billboardGui = main:FindFirstChild("BillboardGui")
                if billboardGui then
                    local label = billboardGui:FindFirstChild("RemainingTime")
                    if label and label:IsA("TextLabel") then
                        local lockTime = label.Text
                        createLockTimerESP(main, lockTime)
                    end
                end
            end
        end
    end
end)

-- Toggle WindUI
local lockTimerESPToggle = VisualTab:Toggle({
    Title = "ESP Lock Timer",
    Value = false,
    Callback = function(state)
        lockTimerESPEnabled = state
        WindUI:Notify({
            Title = "Lock Timer ESP",
            Content = state and "Enabled" or "Disabled",
            Icon = "rbxassetid://85151307796718"
        })
    end
})

local brainrotGodPrices = {
    ["Cocofanto Elefanto"] = 10000,
    ["Girafa Celestre"] = 20000,
    ["Gattatino Neonino"] = 35000,
    ["Matteo"] = 50000,
    ["Tralalero Tralala"] = 50000,
    ["Los Crocodillitos"] = 55000,
    ["Espresso Signora"] = 70000,
    ["Odin Din Din Dun"] = 75000,
    ["Statutino Libertino"] = 75000,
    ["Tukanno Bananno"] = 100000,
    ["Trenostruzzo Turbo 3000"] = 150000,
    ["Trippi Troppi Troppa Trippa"] = 175000,
    ["Ballerino Lololo"] = 200000,
    ["Los Tungtungtungcitos"] = 210000,
    ["Piccione Macchina"] = 225000,
    ["Tigroligre Frutonni"] = 60000,
    ["Orcalero Orcala"] = 100000,
}

local brainrotSecretPrices = {
    ["La Vacca Saturno Saturnita"] = 250000,
    ["Chimpanzini Spiderini"] = 325000,
    ["Agarrini la Palini"] = 425000,
    ["Los Tralaleritos"] = 500000,
    ["Las Tralaleritas"] = 650000,
    ["Las Vaquitas Saturnitas"] = 750000,
    ["Graipuss Medussi"] = 1000000,
    ["Chicleteira Bicicleteira"] = 3500000,
    ["La Grande Combinasion"] = 10000000,
    ["Los Combinasionas"] = 15000000,
    ["Nuclearo Dinossauro"] = 15000000,
    ["Garama and Madundung"] = 50000000,
    ["Dragon Cannelloni"] = 100000000,
    ["Torrtuginni Dragonfrutini"] = 350000,
    ["Pot Hotspot"] = 2500000,
}

local mutationMultipliers = {
    ["Gold"] = 1.25,
    ["Diamond"] = 1.5,
    ["Rainbow"] = 10,
    ["Lava"] = 6,
    ["Bloodrot"] = 2,
    ["Celestial"] = 4,
    ["Candy"] = 4,
    ["Rain"] = 4,
    ["Snow"] = 3,
    ["Concert"] = 5,
    ["Nyan Cats"] = 6,
    ["4th of July"] = 6,
    ["Fire"] = 5,
    ["Crab Rave"] = 5,
    ["Glitch"] = 5,
    ["Tung Tung Attack"] = 4,
    ["Raining Tacos"] = 3,

}

local function getBrainrotType(name)
    if brainrotGodPrices[name] then return "god"
    elseif brainrotSecretPrices[name] then return "secret" end
    return nil
end

local function getColorByType(brainrotType)
    if brainrotType == "god" then return Color3.fromRGB(0, 255, 0)
    elseif brainrotType == "secret" then return Color3.fromRGB(255, 0, 0) end
    return Color3.fromRGB(255, 255, 255)
end

local function formatPrice(n)
    if n >= 1e6 then return tostring(math.floor(n / 1e5) / 10) .. "M"
    elseif n >= 1e3 then return tostring(math.floor(n / 1e2) / 10) .. "K"
    else return tostring(n) end
end

local function createESP(model)
    if not model:IsA("Model") or model:FindFirstChild("ESP") then return end
    local head = model:FindFirstChildWhichIsA("BasePart")
    if not head then return end

    local name = model.Name
    local btype = getBrainrotType(name)
    if not btype then return end

    local basePrice = (btype == "god" and brainrotGodPrices[name]) or brainrotSecretPrices[name]
    if not basePrice then return end

    local mutation = model:GetAttribute("Mutation")
    local multiplier = mutation and mutationMultipliers[mutation] or 1
    local finalPrice = math.floor(basePrice * multiplier)
    local formattedPrice = formatPrice(finalPrice)

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP"
    highlight.Adornee = model
    highlight.FillColor = getColorByType(btype)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = model

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 160, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = getColorByType(btype)
    text.TextStrokeTransparency = 0
    text.TextScaled = true
    text.Text = string.format("%s\n💰: %s/s | 🧪: %s", name, formattedPrice, mutation or "0")
    text.Parent = billboard
end

-- Toggle state
local brainrotESPEnabled = false

local function scanAllBrainrots()
    for _, obj in pairs(workspace:GetChildren()) do
        if brainrotESPEnabled then
            createESP(obj)
        end
    end
end

-- Reapply on spawn
workspace.ChildAdded:Connect(function(child)
    task.wait(0.2)
    if brainrotESPEnabled then
        createESP(child)
    end
end)

local brainrotESPToggle = VisualTab:Toggle({
    Title = "Brainrot ESP",
    Value = false,
    Callback = function(state)
        brainrotESPEnabled = state
        WindUI:Notify({
            Title = "Brainrot ESP",
            Content = state and "Enabled" or "Disabled",
            Icon = "rbxassetid://85151307796718"
        })
        if state then
            scanAllBrainrots()
        else
            -- Clear all ESP from models
            for _, obj in pairs(workspace:GetChildren()) do
                local esp = obj:FindFirstChild("ESP")
                if esp then esp:Destroy() end
                local gui = obj:FindFirstChild("ESP")
                if gui then gui:Destroy() end
            end
        end
    end
})

-- ini codingan anti effect
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Hapus semua BodyForce, BodyVelocity, dll tapi JANGAN reset Velocity manual
RunService.Heartbeat:Connect(function()
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyForce") or v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end
end)

-- Cegah ragdoll atau efek physics
humanoid.StateChanged:Connect(function(old, new)
    if new == Enum.HumanoidStateType.Ragdoll
    or new == Enum.HumanoidStateType.FallingDown
    or new == Enum.HumanoidStateType.Physics then
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- Hapus efek GUI yang mengganggu
local playerGui = player:WaitForChild("PlayerGui")
for _, gui in pairs(playerGui:GetChildren()) do
    if gui:IsA("BlurEffect") or gui:IsA("ColorCorrectionEffect") then
        if gui.Name == "BoogieBombEffect" or gui.Name == "PaintballEffect" or gui.Name == "BeeLauncherEffect" then
            gui:Destroy()
        end
    end
end

-- Biarkan kamera berjalan normal, set ke Custom mode untuk kontrol normal
local camera = workspace.CurrentCamera
camera.CameraType = Enum.CameraType.Custom

-- Jika ada efek kamera shake atau lain, bisa tambahkan deteksi dan hapus (contoh umum):
RunService.RenderStepped:Connect(function()
    -- Misal hapus efek kamera shake yang ada di camera:GetChildren()
    for _, child in pairs(camera:GetChildren()) do
        if child.Name == "CameraShake" then
            child:Destroy()
        end
    end
end)

-- Cegah HP turun akibat senjata/efek
local lastHealth = humanoid.Health
humanoid.HealthChanged:Connect(function(newHealth)
    if newHealth < lastHealth then
        humanoid.Health = lastHealth
    else
        lastHealth = newHealth
    end
end)

local StealingTab = Window:Tab({
    Title = "Stealing",
    Icon = "briefcase"
})

local runningFunc

StealingTab:Toggle({
    Title = "Tween To Base GUI",
    Value = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Tween To Base",
            Content = state and "Enabled" or "Disabled",
            Icon = "rbxassetid://85151307796718"
        })

        if state then
            local ok, loaded = pcall(loadstring, game:HttpGet("https://raw.githubusercontent.com/Walvy404/Script-Tween-To-Base/main/TweenToBase.lua"))
            if ok and type(loaded) == "function" then
                runningFunc = loaded()  -- jalankan fungsi
                WindUI:Notify({Title="Tween To Base", Content="Loaded successfully"})
            else
                warn("Loadstring error:", loaded)
            end
        else
            if runningFunc and type(runningFunc)=="function" then
                pcall(runningFunc) -- jika skrip return fungsi cleanup
            end
        end
    end
})

-- Tambahkan tab baru Aimbot
local aimbotTab = Window:Tab({
    Title = "Aimbot",
    Icon = "crosshair"
})

-- Mapping Tool ke Remote dan Argumen
local toolRemoteMap = {
    ["Web Slinger"] = {
        RemoteName = "WebSlingerRemote",
        Args = function(target)
            return {target.Position}
        end
    },
    ["Taser Gun"] = {
        RemoteName = "TaseRemote",
        Args = function(target)
            return {target}
        end
    },
    ["Rainbowrath Sword"] = {
        RemoteName = "SlashRemote",
        Args = function(target)
            return {target.Position}
        end
    },
    ["Laser Cape"] = {
        RemoteName = "LaserRemote",
        Args = function(target)
            return {target.Position}
        end
    }
}

-- Tool selector
local selectedTool = "Web Slinger"
aimbotTab:Dropdown({
    Title = "Select Tool",
    Values = {"Web Slinger", "Taser Gun", "Rainbowrath Sword", "Laser Cape"},
    Multi = false,
    Callback = function(val)
        selectedTool = val
        WindUI:Notify({
            Title = "Tool Changed",
            Content = "Now using: " .. selectedTool
        })
    end
})

local aimbotEnabled = false
local aimbotConnection

aimbotTab:Toggle({
    Title = "Auto Aim / Use Tool",
    Value = false,
    Callback = function(state)
        aimbotEnabled = state

        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end

        if state then
            aimbotConnection = RunService.Heartbeat:Connect(function()
                local character = LocalPlayer.Character
                local tool = character and character:FindFirstChildOfClass("Tool")
                if not tool or not tool.Name:lower():find(selectedTool:lower()) then return end

                local config = toolRemoteMap[selectedTool]
                if not config then return end

                local remote = tool:FindFirstChild(config.RemoteName)
                if not remote then return end

                -- Cari target terdekat
                local closestPlayer
                local shortest = math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < shortest and dist < 80 then
                            closestPlayer = p
                            shortest = dist
                        end
                    end
                end

                if closestPlayer then
                    local args = config.Args(closestPlayer.Character.HumanoidRootPart)
                    pcall(function()
                        remote:FireServer(unpack(args))
                    end)
                end
            end)
            WindUI:Notify({
                Title = "Aimbot Activated",
                Content = "Using: " .. selectedTool
            })
        else
            WindUI:Notify({
                Title = "Aimbot Disabled",
                Content = "No longer auto-firing"
            })
        end
    end
})

-- ini perbasatan
-- Config Tab      
local configTab = Window:Tab({ Title = "Config", Icon = "settings" })      
local currentFileName = "MyConfig"      

-- Input for config file name      
configTab:Input({      
    Title = "Config File Name",      
    Placeholder = "Example: MyConfig",      
    Text = currentFileName,      
    Callback = function(txt)      
        local valid = txt:match("^[%w_-]+$")      
        if valid then      
            currentFileName = txt      
            WindUI:Notify({ Title = "Config Name", Content = "File name: " .. currentFileName })      
        else      
            currentFileName = "MyConfig"      
            WindUI:Notify({ Title = "Error", Content = "Only use letters, numbers, _ or -." })      
        end      
    end      
})      

-- Toggle for auto-load      
local autoLoadToggle = configTab:Toggle({      
    Title = "Auto Load on Startup",      
    Value = autoLoadEnabled,      
    Callback = function(val)      
        autoLoadEnabled = val      
        writefile(autoFile, HttpService:JSONEncode({ enabled = val }))      
        WindUI:Notify({      
            Title = "Auto Load Config",      
            Content = val and "Enabled" or "Disabled",      
        })      
    end      
})      

-- Config Manager      
local function getConfig()      
    local cfg = Window.ConfigManager:CreateConfig(currentFileName)      
    cfg:Register("autoLoadToggle", autoLoadToggle)
    cfg:Register("infinityJumpToggle", infinityJumpToggle)
    cfg:Register("godToggle", godToggle)
    cfg:Register("speedToggle", speedToggle) -- sudah diperbaiki
    cfg:Register("antiRagdollToggle", antiRagdollToggle)
    cfg:Register("antiRagdollToggle", antiRagdollToggle)
    cfg:Register("playerESPToggle", playerESPToggle)
    cfg:Register("brainrotESPToggle", brainrotESPToggle)
    cfg:Register("antiEffekToggle", AntiEffekToggle)
    return cfg      
end  

-- Save Config      
configTab:Button({      
    Title = "Save Config",      
    Callback = function()      
        local cfg = getConfig()      
        cfg:Save(CONFIG_FOLDER)      
        WindUI:Notify({ Title = "Config", Content = "Saved to: " .. CONFIG_FOLDER .. "/" .. currentFileName })      
    end      
})      

-- Load Config      
configTab:Button({      
    Title = "Load Config",      
    Callback = function()      
        local cfg = getConfig()      
        cfg:Load(CONFIG_FOLDER)      
        WindUI:Notify({ Title = "Config", Content = "Loaded from: " .. CONFIG_FOLDER .. "/" .. currentFileName })      
    end      
})      

-- Manual Auto Load      
configTab:Button({      
    Title = "Run Auto Load Now",      
    Callback = function()      
        pcall(function()      
            local cfg = getConfig()      
            cfg:Load(CONFIG_FOLDER)      
            WindUI:Notify({ Title = "Auto Load", Content = "Loaded from: " .. CONFIG_FOLDER .. "/" .. currentFileName })      
        end)      
    end      
})      

-- Delete Config      
configTab:Button({      
    Title = "Delete Config",      
    Callback = function()      
        local path = CONFIG_FOLDER .. "/" .. currentFileName .. ".json"      
        if isfile(path) then      
            delfile(path)      
            WindUI:Notify({ Title = "Config", Content = "Deleted: " .. path })      
        else      
            WindUI:Notify({ Title = "Config", Content = "File not found." })      
        end      
    end      
})      

-- Auto load config on GUI open      
task.defer(function()      
    if autoLoadEnabled then      
        pcall(function()      
            local cfg = getConfig()      
            cfg:Load(CONFIG_FOLDER)      
        end)      
    end      
end)      

task.defer(function()
    speedToggle:Set(true)
end)

-- On GUI Close      
Window:OnClose(function()      
    print("GUI closed.")      
end)
