local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Configuration
local AUTO_DIG = false
local AUTO_SELL = false
local AUTO_EQUIP = false
local DIG_INTERVAL = 0.1
local SELL_INTERVAL = 5
local TOGGLE_KEY = Enum.KeyCode.F4 -- Key to toggle GUI

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "DIGAutoGui"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 250)
Frame.Position = UDim2.new(0.05, 0, 0.05, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "DIG Auto Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Parent = Frame

local AutoDigButton = Instance.new("TextButton")
AutoDigButton.Size = UDim2.new(0.9, 0, 0, 40)
AutoDigButton.Position = UDim2.new(0.05, 0, 0.15, 0)
AutoDigButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AutoDigButton.Text = "Auto Dig: OFF"
AutoDigButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoDigButton.TextScaled = true
AutoDigButton.Parent = Frame

local AutoSellButton = Instance.new("TextButton")
AutoSellButton.Size = UDim2.new(0.9, 0, 0, 40)
AutoSellButton.Position = UDim2.new(0.05, 0, 0.3, 0)
AutoSellButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AutoSellButton.Text = "Auto Sell: OFF"
AutoSellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoSellButton.TextScaled = true
AutoSellButton.Parent = Frame

local AutoEquipButton = Instance.new("TextButton")
AutoEquipButton.Size = UDim2.new(0.9, 0, 0, 40)
AutoEquipButton.Position = UDim2.new(0.05, 0, 0.45, 0)
AutoEquipButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
AutoEquipButton.Text = "Auto Equip: OFF"
AutoEquipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoEquipButton.TextScaled = true
AutoEquipButton.Parent = Frame

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0.9, 0, 0, 40)
TeleportButton.Position = UDim2.new(0.05, 0, 0.6, 0)
TeleportButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TeleportButton.Text = "Teleport to Sell"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.TextScaled = true
TeleportButton.Parent = Frame

-- Rounded corners for GUI
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame
for _, button in pairs({AutoDigButton, AutoSellButton, AutoEquipButton, TeleportButton}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
end

-- Toggle GUI visibility
local guiVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == TOGGLE_KEY then
        guiVisible = not guiVisible
        ScreenGui.Enabled = guiVisible
    end
end)

-- Auto Dig Function
local function findWeakSpot()
    local weakSpot = game.Workspace:FindFirstChild("WeakSpot") -- Adjust if different
    return weakSpot
end

local function autoDig()
    while AUTO_DIG do
        local weakSpot = findWeakSpot()
        if weakSpot then
            local args = {weakSpot}
            local digEvent = ReplicatedStorage:FindFirstChild("DigEvent") -- Adjust if different
            if digEvent then
                digEvent:FireServer(unpack(args))
            end
        end
        wait(DIG_INTERVAL)
    end
end

-- Auto Sell Function
local function autoSell()
    while AUTO_SELL do
        local sellEvent = ReplicatedStorage:FindFirstChild("SellEvent") -- Adjust if different
        if sellEvent then
            sellEvent:FireServer()
        end
        wait(SELL_INTERVAL)
    end
end

-- Auto Equip Shovel Function
local function autoEquipShovel()
    while AUTO_EQUIP do
        local backpack = Player.Backpack
        local bestShovel = nil
        local highestPower = -1

        -- Find the best shovel in backpack
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:match("Shovel") then -- Adjust if shovels have specific names
                local power = tool:GetAttribute("Power") or 0 -- Adjust if power is stored differently
                if power > highestPower then
                    highestPower = power
                    bestShovel = tool
                end
            end
        end

        -- Equip the best shovel
        if bestShovel then
            Player.Character.Humanoid:EquipTool(bestShovel)
        end

        wait(2) -- Check every 2 seconds
    end
end

-- Teleport Function
local function teleportTo(locationName)
    local locations = {
        Sell = Vector3.new(0, 10, 0), -- Replace with actual sell point coordinates
        Dig = Vector3.new(100, 10, 100) -- Replace with actual dig area coordinates
    }
    local targetPos = locations[locationName]
    if targetPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(Player.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
        tween:Play()
    end
end

-- Button Connections
AutoDigButton.MouseButton1Click:Connect(function()
    AUTO_DIG = not AUTO_DIG
    AutoDigButton.Text = "Auto Dig: " .. (AUTO_DIG and "ON" or "OFF")
    AutoDigButton.BackgroundColor3 = AUTO_DIG and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
    if AUTO_DIG then
        spawn(autoDig)
    end
end)

AutoSellButton.MouseButton1Click:Connect(function()
    AUTO_SELL = not AUTO_SELL
    AutoSellButton.Text = "Auto Sell: " .. (AUTO_SELL and "ON" or "OFF")
    AutoSellButton.BackgroundColor3 = AUTO_SELL and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
    if AUTO_SELL then
        spawn(autoSell)
    end
end)

AutoEquipButton.MouseButton1Click:Connect(function()
    AUTO_EQUIP = not AUTO_EQUIP
    AutoEquipButton.Text = "Auto Equip: " .. (AUTO_EQUIP and "ON" or "OFF")
    AutoEquipButton.BackgroundColor3 = AUTO_EQUIP and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
    if AUTO_EQUIP then
        spawn(autoEquipShovel)
    end
end)

TeleportButton.MouseButton1Click:Connect(function()
    teleportTo("Sell")
end)

print("DIG Auto Script Loaded! Press F4 to toggle GUI.")