-- Brainrot Free Eats GUI (Executor) - Full Auto

local TeleportService = game:GetService("TeleportService")
local targetPlaceId = 84968446824850

if game.PlaceId ~= targetPlaceId then
    TeleportService:Teleport(targetPlaceId)
    return
end

-- rest of the script stays exactly the same from here downward
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Destroy old one if it exists
if CoreGui:FindFirstChild("BrainrotGui") then
    CoreGui.BrainrotGui:Destroy()
end

local instantPickup = false
local autoMoney = false
local autoUpgrade = false
local promptConnection = nil
local moneyThread = nil
local upgradeThread = nil

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 420, 0, 260)
frame.Position = UDim2.new(0.5, -210, 0.28, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 80)
stroke.Thickness = 1.5
stroke.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -50, 0, 36)
title.Position = UDim2.new(0, 14, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Brainrot free eats"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Close Button (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -42, 0, 6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 55, 55)
closeBtn.TextSize = 26
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    instantPickup = false
    autoMoney = false
    autoUpgrade = false
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end
    screenGui:Destroy()
end)

-- Button Holder
local buttonHolder = Instance.new("Frame")
buttonHolder.Name = "ButtonHolder"
buttonHolder.Size = UDim2.new(1, -24, 0, 190)
buttonHolder.Position = UDim2.new(0, 12, 0, 52)
buttonHolder.BackgroundTransparency = 1
buttonHolder.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Wraps = true
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = buttonHolder

local function makeButton(name, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 185, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = true
    btn.Parent = buttonHolder

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 7)
    btnCorner.Parent = btn

    return btn
end

local tpBtn = makeButton("TpToEnd", "Tp to end")
local upgradeBtn = makeButton("UpgradeAll", "Upgrade all")
local collectBtn = makeButton("CollectCash", "Collect Cash")
local backBtn = makeButton("BackToBase", "Back to base")
local autoMoneyBtn = makeButton("AutoMoney", "Auto Collect Money")
local autoUpgradeBtn = makeButton("AutoUpgrade", "Auto Upgrade")

-- Helper to update toggle button look
local function setToggle(btn, state, onText, offText)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        btn.Text = onText
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        btn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
        btn.Text = offText
        btn.TextColor3 = Color3.fromRGB(25, 25, 25)
    end
end

-- Instant pickup logic
local function isBrainrotPrompt(prompt)
    local text = string.lower((prompt.ActionText or "") .. (prompt.ObjectText or ""))
    return text:find("pick") or text:find("brainrot")
end

local function enableInstant()
    if promptConnection then return end

    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and isBrainrotPrompt(prompt) then
            prompt.HoldDuration = 0
            prompt.RequiresLineOfSight = false
        end
    end

    promptConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
        if not instantPickup then return end
        if isBrainrotPrompt(prompt) then
            prompt.HoldDuration = 0
            pcall(fireproximityprompt, prompt)
        end
    end)

    workspace.DescendantAdded:Connect(function(desc)
        if not instantPickup then return end
        if desc:IsA("ProximityPrompt") and isBrainrotPrompt(desc) then
            desc.HoldDuration = 0
            desc.RequiresLineOfSight = false
        end
    end)
end

local function disableInstant()
    instantPickup = false
    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end
end

-- Silent Auto Collect Money (no animation / no sound)
local function startAutoMoney()
    if moneyThread then return end
    moneyThread = task.spawn(function()
        while autoMoney do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot1") and workspace.Plots.Plot2:FindFirstChild("Pods")
            local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot2") and workspace.Plots.Plot2:FindFirstChild("Pods")
            local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot3") and workspace.Plots.Plot2:FindFirstChild("Pods")
            local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot4") and workspace.Plots.Plot2:FindFirstChild("Pods")
            local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot5") and workspace.Plots.Plot2:FindFirstChild("Pods")

            if root and pods then
                for i = 1, 40 do
                    if not autoMoney then break end
                    local pod = pods:FindFirstChild(tostring(i))
                    if pod then
                        local touchPart = pod:FindFirstChild("TouchPart")
                        if touchPart then
                            pcall(function()
                                firetouchinterest(root, touchPart, 0)
                                firetouchinterest(root, touchPart, 1)
                            end)
                        end
                    end
                end
            end
            task.wait(0.8)
        end
        moneyThread = nil
    end)
end

-- Auto Upgrade
local function startAutoUpgrade()
    if upgradeThread then return end
    upgradeThread = task.spawn(function()
        while autoUpgrade do
            local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("UpgradeBrainrot")
            local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot2") and workspace.Plots.Plot2:FindFirstChild("Pods")

            if Event and pods then
                for i = 1, 40 do
                    if not autoUpgrade then break end
                    local pod = pods:FindFirstChild(tostring(i))
                    if pod then
                        pcall(function()
                            Event:FireServer(pod)
                        end)
                    end
                end
            end
            task.wait(2.5)
        end
        upgradeThread = nil
    end)
end

-- Manual Collect Cash (still silent)
local function collectAllCash()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local pods = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild("Plot2") and workspace.Plots.Plot2:FindFirstChild("Pods")

    if not root or not pods then return end

    for i = 1, 40 do
        local pod = pods:FindFirstChild(tostring(i))
        if pod then
            local touchPart = pod:FindFirstChild("TouchPart")
            if touchPart then
                pcall(function()
                    firetouchinterest(root, touchPart, 0)
                    firetouchinterest(root, touchPart, 1)
                end)
            end
        end
    end
end

-- Buttons
tpBtn.MouseButton1Click:Connect(function()
    local character = player.Character or player.CharacterAdded:Wait()
    if character then
        character:PivotTo(CFrame.new(-13, -10, -4476))
    end
    instantPickup = true
    enableInstant()
end)

upgradeBtn.MouseButton1Click:Connect(function()
    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("UpgradeBrainrot")
    if Event then
        for i = 1, 40 do
            pcall(function()
                Event:FireServer(workspace.Plots.Plot2.Pods[tostring(i)])
            end)
        end
    end
end)

collectBtn.MouseButton1Click:Connect(function()
    collectAllCash()
end)

backBtn.MouseButton1Click:Connect(function()
    disableInstant()
    autoMoney = false
    autoUpgrade = false
    setToggle(autoMoneyBtn, false, "Auto Collect Money: ON", "Auto Collect Money")
    setToggle(autoUpgradeBtn, false, "Auto Upgrade: ON", "Auto Upgrade")

    local Event = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("ReturnToPlot")
    if Event then
        Event:FireServer()
    end
end)

autoMoneyBtn.MouseButton1Click:Connect(function()
    autoMoney = not autoMoney
    setToggle(autoMoneyBtn, autoMoney, "Auto Collect Money: ON", "Auto Collect Money")
    if autoMoney then
        startAutoMoney()
    end
end)

autoUpgradeBtn.MouseButton1Click:Connect(function()
    autoUpgrade = not autoUpgrade
    setToggle(autoUpgradeBtn, autoUpgrade, "Auto Upgrade: ON", "Auto Upgrade")
    if autoUpgrade then
        startAutoUpgrade()
    end
end)

-- Dragging
local dragging = false
local dragStart, startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("Brainrot Free Eats loaded - Full Auto")
