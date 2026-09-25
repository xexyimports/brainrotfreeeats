--[[
    xexy hub
    Game: 104339804279870
    Break tape for brainrots
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- // SETTINGS
local SupportedListURL = "https://raw.githubusercontent.com/xexyimports/brainrotfreeeats/refs/heads/main/supportedgames.txt"
local SupportedPlaceIds = {}
local SupportedGamesInfo = {}
local SupportedLoaded = false

local Minimized = false

-- Feature states
local AutoPower = false
local AutoSpeed = false
local AutoCarry = false
local AutoSlot = false
local AutoAllSlots = false

local PowerAmount = 1
local SpeedAmount = 1
local SelectedFloor = 1
local SelectedSlot = 1

-- CFrame
local EndWorldCF = CFrame.new(-10, 6, 872)

-- // LOAD SUPPORTED LIST
task.spawn(function()
    local success, result = pcall(function()
        return game:HttpGet(SupportedListURL)
    end)

    if success and result then
        for line in string.gmatch(result, "[^\r\n]+") do
            line = line:gsub("^%s+", ""):gsub("%s+$", "")
            if line ~= "" and not line:match("^#") then
                local parts = string.split(line, "|")
                if #parts >= 1 then
                    local id = tonumber(parts[1]:match("%d+"))
                    local name = parts[2] and parts[2]:gsub("^%s+", ""):gsub("%s+$", "") or ("Place " .. tostring(id))
                    if id then
                        SupportedPlaceIds[id] = true
                        SupportedGamesInfo[id] = name
                    end
                end
            end
        end
    end
    SupportedLoaded = true
end)

-- // CREATE GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "xexyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 560, 0, 560)
Main.Position = UDim2.new(0.5, -280, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(12, 8, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(90, 15, 28)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 8, 16)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 7, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 5, 8))
})
MainGrad.Rotation = 130
MainGrad.Parent = Main

-- Top bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 6, 10)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 14)
TopFix.Position = UDim2.new(0, 0, 1, -14)
TopFix.BackgroundColor3 = Color3.fromRGB(18, 6, 10)
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "xexy hub"
Title.TextColor3 = Color3.fromRGB(255, 65, 90)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 12, 18)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(220, 180, 190)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(170, 25, 45)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseBtn

-- Sidebar
local Side = Instance.new("Frame")
Side.Name = "Side"
Side.Size = UDim2.new(0, 128, 1, -38)
Side.Position = UDim2.new(0, 0, 0, 38)
Side.BackgroundColor3 = Color3.fromRGB(14, 5, 8)
Side.BorderSizePixel = 0
Side.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Side

local SideFix = Instance.new("Frame")
SideFix.Size = UDim2.new(0, 20, 1, 0)
SideFix.Position = UDim2.new(1, -20, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(14, 5, 8)
SideFix.BorderSizePixel = 0
SideFix.Parent = Side

local function makeTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -14, 0, 32)
    btn.Position = UDim2.new(0, 7, 0, 12 + (order - 1) * 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 10, 15)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 160, 170)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Side

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn
    return btn
end

local TabMain = makeTab("Main", 1)
local TabFarm = makeTab("Farm", 2)
local TabSide = makeTab("Side", 3)
local TabInfo = makeTab("Info", 4)

-- Content
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -138, 1, -48)
Content.Position = UDim2.new(0, 133, 0, 44)
Content.BackgroundTransparency = 1
Content.Parent = Main

local MainPage = Instance.new("ScrollingFrame")
MainPage.Size = UDim2.new(1, 0, 1, 0)
MainPage.BackgroundTransparency = 1
MainPage.BorderSizePixel = 0
MainPage.ScrollBarThickness = 3
MainPage.ScrollBarImageColor3 = Color3.fromRGB(180, 40, 60)
MainPage.CanvasSize = UDim2.new(0, 0, 0, 550)
MainPage.Visible = true
MainPage.Parent = Content

local FarmPage = Instance.new("ScrollingFrame")
FarmPage.Size = UDim2.new(1, 0, 1, 0)
FarmPage.BackgroundTransparency = 1
FarmPage.BorderSizePixel = 0
FarmPage.ScrollBarThickness = 3
FarmPage.ScrollBarImageColor3 = Color3.fromRGB(180, 40, 60)
FarmPage.CanvasSize = UDim2.new(0, 0, 0, 980)
FarmPage.Visible = false
FarmPage.Parent = Content

local SidePage = Instance.new("Frame")
SidePage.Size = UDim2.new(1, 0, 1, 0)
SidePage.BackgroundTransparency = 1
SidePage.Visible = false
SidePage.Parent = Content

local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.new(1, 0, 1, 0)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.Parent = Content

-- Helpers
local function makeLabel(parent, text, y, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, size or 18)
    l.Position = UDim2.new(0, 8, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180, 140, 150)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function makeButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(160, 25, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 240, 245)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeToggleButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 200, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(200, 30, 55)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
            btn.TextColor3 = Color3.fromRGB(230, 200, 210)
        end
        callback(state)
    end)
    return btn
end

-- ===================== MAIN PAGE =====================
makeLabel(MainPage, "CURRENT GAME", 6)

local GameNameLabel = Instance.new("TextLabel")
GameNameLabel.Size = UDim2.new(1, -16, 0, 30)
GameNameLabel.Position = UDim2.new(0, 8, 0, 26)
GameNameLabel.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
GameNameLabel.Text = "  Loading..."
GameNameLabel.TextColor3 = Color3.fromRGB(255, 90, 110)
GameNameLabel.Font = Enum.Font.GothamBold
GameNameLabel.TextSize = 14
GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameNameLabel.Parent = MainPage

local gnc = Instance.new("UICorner")
gnc.CornerRadius = UDim.new(0, 7)
gnc.Parent = GameNameLabel

task.spawn(function()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and info then
        GameNameLabel.Text = "  " .. info.Name
    else
        GameNameLabel.Text = "  " .. (game.Name ~= "" and game.Name or "Unknown")
    end
end)

makeLabel(MainPage, "PLACE ID: " .. tostring(game.PlaceId), 64)

makeLabel(MainPage, "SUPPORT STATUS", 96)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 34)
StatusLabel.Position = UDim2.new(0, 8, 0, 118)
StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
StatusLabel.Text = "  ✓ SUPPORTED"
StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainPage

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 7)
sc.Parent = StatusLabel

makeLabel(MainPage, "SERVER", 168)
makeButton(MainPage, "Server Hop (same game)", 190, function()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end)

makeLabel(MainPage, "SUPPORTED GAMES (click to join)", 242)

local GamesContainer = Instance.new("Frame")
GamesContainer.Name = "GamesContainer"
GamesContainer.Size = UDim2.new(1, -16, 0, 280)
GamesContainer.Position = UDim2.new(0, 8, 0, 268)
GamesContainer.BackgroundTransparency = 1
GamesContainer.Parent = MainPage

local GamesLayout = Instance.new("UIListLayout")
GamesLayout.SortOrder = Enum.SortOrder.LayoutOrder
GamesLayout.Padding = UDim.new(0, 6)
GamesLayout.Parent = GamesContainer

task.spawn(function()
    while not SupportedLoaded do task.wait(0.1) end

    local order = 0
    for id, name in pairs(SupportedGamesInfo) do
        order = order + 1
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Color3.fromRGB(160, 25, 45)
        btn.Text = "  " .. name .. "  (" .. tostring(id) .. ")"
        btn.TextColor3 = Color3.fromRGB(255, 240, 245)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.LayoutOrder = order
        btn.Parent = GamesContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 7)
        c.Parent = btn

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.Parent = btn

        btn.MouseButton1Click:Connect(function()
            pcall(function()
                TeleportService:Teleport(id, player)
            end)
        end)
    end

    MainPage.CanvasSize = UDim2.new(0, 0, 0, 280 + (order * 40))
end)

-- ===================== FARM PAGE =====================
makeLabel(FarmPage, "TELEPORTS", 6)

makeButton(FarmPage, "Teleport to End World", 28, function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = EndWorldCF
    end
end)

makeButton(FarmPage, "Return to Base (Reset)", 70, function()
    local char = player.Character
    if char then
        char:BreakJoints()
    end
end)

-- POWER
makeLabel(FarmPage, "POWER UPGRADE", 120)

local PowerDrop = Instance.new("TextButton")
PowerDrop.Size = UDim2.new(1, -16, 0, 34)
PowerDrop.Position = UDim2.new(0, 8, 0, 142)
PowerDrop.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
PowerDrop.Text = "  +1 Power"
PowerDrop.TextColor3 = Color3.fromRGB(240, 210, 220)
PowerDrop.Font = Enum.Font.Gotham
PowerDrop.TextSize = 13
PowerDrop.TextXAlignment = Enum.TextXAlignment.Left
PowerDrop.Parent = FarmPage

local pdc = Instance.new("UICorner")
pdc.CornerRadius = UDim.new(0, 7)
pdc.Parent = PowerDrop

local PowerOptions = {
    {text = "+1 Power", amount = 1},
    {text = "+5 Power", amount = 5},
    {text = "+10 Power", amount = 10}
}

local PowerOpen = false
local PowerFrame = nil

PowerDrop.MouseButton1Click:Connect(function()
    if PowerOpen and PowerFrame then
        PowerFrame:Destroy()
        PowerOpen = false
        return
    end
    PowerOpen = true
    PowerFrame = Instance.new("Frame")
    PowerFrame.Size = UDim2.new(1, -16, 0, 102)
    PowerFrame.Position = UDim2.new(0, 8, 0, 180)
    PowerFrame.BackgroundColor3 = Color3.fromRGB(20, 8, 12)
    PowerFrame.BorderSizePixel = 0
    PowerFrame.Parent = FarmPage

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 7)
    fc.Parent = PowerFrame

    local layout = Instance.new("UIListLayout")
    layout.Parent = PowerFrame

    for _, opt in ipairs(PowerOptions) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundTransparency = 1
        b.Text = "  " .. opt.text
        b.TextColor3 = Color3.fromRGB(230, 200, 210)
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = PowerFrame

        b.MouseButton1Click:Connect(function()
            PowerAmount = opt.amount
            PowerDrop.Text = "  " .. opt.text
            PowerFrame:Destroy()
            PowerOpen = false
        end)
    end
end)

makeButton(FarmPage, "Upgrade Power (Once)", 230, function()
    local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("PurchasePower")
    if event then
        pcall(function()
            event:FireServer(PowerAmount)
        end)
    end
end)

makeToggleButton(FarmPage, "Auto Upgrade Power", 272, function(state)
    AutoPower = state
end)

-- SPEED
makeLabel(FarmPage, "SPEED UPGRADE", 320)

local SpeedDrop = Instance.new("TextButton")
SpeedDrop.Size = UDim2.new(1, -16, 0, 34)
SpeedDrop.Position = UDim2.new(0, 8, 0, 342)
SpeedDrop.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
SpeedDrop.Text = "  +1 Speed"
SpeedDrop.TextColor3 = Color3.fromRGB(240, 210, 220)
SpeedDrop.Font = Enum.Font.Gotham
SpeedDrop.TextSize = 13
SpeedDrop.TextXAlignment = Enum.TextXAlignment.Left
SpeedDrop.Parent = FarmPage

local sdc = Instance.new("UICorner")
sdc.CornerRadius = UDim.new(0, 7)
sdc.Parent = SpeedDrop

local SpeedOpen = false
local SpeedFrame = nil

SpeedDrop.MouseButton1Click:Connect(function()
    if SpeedOpen and SpeedFrame then
        SpeedFrame:Destroy()
        SpeedOpen = false
        return
    end
    SpeedOpen = true
    SpeedFrame = Instance.new("Frame")
    SpeedFrame.Size = UDim2.new(1, -16, 0, 102)
    SpeedFrame.Position = UDim2.new(0, 8, 0, 380)
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(20, 8, 12)
    SpeedFrame.BorderSizePixel = 0
    SpeedFrame.Parent = FarmPage

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 7)
    fc.Parent = SpeedFrame

    local layout = Instance.new("UIListLayout")
    layout.Parent = SpeedFrame

    for _, opt in ipairs({{text = "+1 Speed", amount = 1}, {text = "+5 Speed", amount = 5}, {text = "+10 Speed", amount = 10}}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 34)
        b.BackgroundTransparency = 1
        b.Text = "  " .. opt.text
        b.TextColor3 = Color3.fromRGB(230, 200, 210)
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.Parent = SpeedFrame

        b.MouseButton1Click:Connect(function()
            SpeedAmount = opt.amount
            SpeedDrop.Text = "  " .. opt.text
            SpeedFrame:Destroy()
            SpeedOpen = false
        end)
    end
end)

makeButton(FarmPage, "Upgrade Speed (Once)", 430, function()
    local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("PurchaseSpeed")
    if event then
        pcall(function()
            event:FireServer(SpeedAmount)
        end)
    end
end)

makeToggleButton(FarmPage, "Auto Upgrade Speed", 472, function(state)
    AutoSpeed = state
end)

-- CARRY
makeLabel(FarmPage, "CARRY UPGRADE", 520)

makeToggleButton(FarmPage, "Auto Upgrade Carry (+1)", 542, function(state)
    AutoCarry = state
end)

-- SLOT UPGRADE
makeLabel(FarmPage, "SLOT UPGRADE (Floor 1-12 | Slot 1-10)", 590)

local FloorDrop = Instance.new("TextButton")
FloorDrop.Size = UDim2.new(0.48, -8, 0, 34)
FloorDrop.Position = UDim2.new(0, 8, 0, 612)
FloorDrop.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
FloorDrop.Text = "  Floor 1"
FloorDrop.TextColor3 = Color3.fromRGB(240, 210, 220)
FloorDrop.Font = Enum.Font.Gotham
FloorDrop.TextSize = 13
FloorDrop.TextXAlignment = Enum.TextXAlignment.Left
FloorDrop.Parent = FarmPage

local fdc = Instance.new("UICorner")
fdc.CornerRadius = UDim.new(0, 7)
fdc.Parent = FloorDrop

local SlotDrop = Instance.new("TextButton")
SlotDrop.Size = UDim2.new(0.48, -8, 0, 34)
SlotDrop.Position = UDim2.new(0.52, 0, 0, 612)
SlotDrop.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
SlotDrop.Text = "  Slot 1"
SlotDrop.TextColor3 = Color3.fromRGB(240, 210, 220)
SlotDrop.Font = Enum.Font.Gotham
SlotDrop.TextSize = 13
SlotDrop.TextXAlignment = Enum.TextXAlignment.Left
SlotDrop.Parent = FarmPage

local sldc = Instance.new("UICorner")
sldc.CornerRadius = UDim.new(0, 7)
sldc.Parent = SlotDrop

FloorDrop.MouseButton1Click:Connect(function()
    SelectedFloor = SelectedFloor % 12 + 1
    FloorDrop.Text = "  Floor " .. SelectedFloor
end)

SlotDrop.MouseButton1Click:Connect(function()
    SelectedSlot = SelectedSlot % 10 + 1
    SlotDrop.Text = "  Slot " .. SelectedSlot
end)

makeButton(FarmPage, "Upgrade Selected Slot (Once)", 656, function()
    local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RequestSlotUpgrade")
    if event then
        local floorName = "Floor" .. SelectedFloor
        local slotName = "Slot" .. SelectedSlot
        pcall(function()
            event:FireServer(floorName, slotName)
        end)
    end
end)

makeToggleButton(FarmPage, "Auto Upgrade Selected Slot", 698, function(state)
    AutoSlot = state
end)

makeToggleButton(FarmPage, "Auto Upgrade ALL Brainrots (All Floors + Slots)", 742, function(state)
    AutoAllSlots = state
end)

makeLabel(FarmPage, "Tip: Click Floor / Slot buttons to cycle 1→12 / 1→10", 790)

-- ===================== SIDE + INFO =====================
makeLabel(SidePage, "SCRIPT LOADERS", 6)

makeButton(SidePage, "Load Cobalt", 30, function()
    pcall(function()
        loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
    end)
end)

makeButton(SidePage, "Load Infinite Yield", 76, function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
end)

makeButton(SidePage, "Load Dex++", 122, function()
    pcall(function()
        loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))()
    end)
end)

makeLabel(InfoPage, "PLAYER INFO", 6)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 84, 0, 84)
Avatar.Position = UDim2.new(0, 8, 0, 30)
Avatar.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
Avatar.Parent = InfoPage

local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(0, 10)
ac.Parent = Avatar

task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok then Avatar.Image = content end
end)

local UserIdLabel = Instance.new("TextLabel")
UserIdLabel.Size = UDim2.new(1, -110, 0, 22)
UserIdLabel.Position = UDim2.new(0, 104, 0, 36)
UserIdLabel.BackgroundTransparency = 1
UserIdLabel.Text = "UserId: " .. tostring(player.UserId)
UserIdLabel.TextColor3 = Color3.fromRGB(240, 200, 210)
UserIdLabel.Font = Enum.Font.GothamBold
UserIdLabel.TextSize = 14
UserIdLabel.TextXAlignment = Enum.TextXAlignment.Left
UserIdLabel.Parent = InfoPage

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -110, 0, 20)
NameLabel.Position = UDim2.new(0, 104, 0, 60)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Name: " .. player.Name
NameLabel.TextColor3 = Color3.fromRGB(200, 160, 170)
NameLabel.Font = Enum.Font.Gotham
NameLabel.TextSize = 13
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = InfoPage

makeLabel(InfoPage, "EXECUTOR", 130)

local ExecutorLabel = Instance.new("TextLabel")
ExecutorLabel.Size = UDim2.new(1, -16, 0, 32)
ExecutorLabel.Position = UDim2.new(0, 8, 0, 152)
ExecutorLabel.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
ExecutorLabel.Text = "  Detecting..."
ExecutorLabel.TextColor3 = Color3.fromRGB(255, 90, 110)
ExecutorLabel.Font = Enum.Font.GothamBold
ExecutorLabel.TextSize = 13
ExecutorLabel.TextXAlignment = Enum.TextXAlignment.Left
ExecutorLabel.Parent = InfoPage

local ec = Instance.new("UICorner")
ec.CornerRadius = UDim.new(0, 7)
ec.Parent = ExecutorLabel

task.spawn(function()
    local name = "Unknown"
    local success, result = pcall(function()
        if identifyexecutor then return identifyexecutor()
        elseif getexecutorname then return getexecutorname()
        else return "Unknown" end
    end)
    if success and result then name = tostring(result) end
    ExecutorLabel.Text = "  " .. name
end)

-- ===================== TAB + WINDOW LOGIC =====================
local pages = {
    [TabMain] = MainPage,
    [TabFarm] = FarmPage,
    [TabSide] = SidePage,
    [TabInfo] = InfoPage
}

local function switchTab(activeTab)
    for tab, page in pairs(pages) do
        page.Visible = (tab == activeTab)
        tab.BackgroundColor3 = (tab == activeTab) and Color3.fromRGB(180, 30, 50) or Color3.fromRGB(30, 10, 15)
        tab.TextColor3 = (tab == activeTab) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 160, 170)
    end
end

TabMain.MouseButton1Click:Connect(function() switchTab(TabMain) end)
TabFarm.MouseButton1Click:Connect(function() switchTab(TabFarm) end)
TabSide.MouseButton1Click:Connect(function() switchTab(TabSide) end)
TabInfo.MouseButton1Click:Connect(function() switchTab(TabInfo) end)
switchTab(TabMain)

CloseBtn.MouseButton1Click:Connect(function()
    AutoPower = false
    AutoSpeed = false
    AutoCarry = false
    AutoSlot = false
    AutoAllSlots = false
    ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        Content.Visible = false
        Side.Visible = false
        Main.Size = UDim2.new(0, 560, 0, 38)
    else
        Content.Visible = true
        Side.Visible = true
        Main.Size = UDim2.new(0, 560, 0, 560)
    end
end)

-- Drag
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===================== AUTO LOOPS =====================

-- Auto Power
task.spawn(function()
    while true do
        if AutoPower then
            local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("PurchasePower")
            if event then
                pcall(function()
                    event:FireServer(PowerAmount)
                end)
            end
            task.wait(0.4)
        else
            task.wait(0.25)
        end
    end
end)

-- Auto Speed
task.spawn(function()
    while true do
        if AutoSpeed then
            local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("PurchaseSpeed")
            if event then
                pcall(function()
                    event:FireServer(SpeedAmount)
                end)
            end
            task.wait(0.4)
        else
            task.wait(0.25)
        end
    end
end)

-- Auto Carry
task.spawn(function()
    while true do
        if AutoCarry then
            local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("PurchaseCarry")
            if event then
                pcall(function()
                    event:FireServer(1)
                end)
            end
            task.wait(0.45)
        else
            task.wait(0.25)
        end
    end
end)

-- Auto Selected Slot
task.spawn(function()
    while true do
        if AutoSlot then
            local event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("RequestSlotUpgrade")
            if event then
                local floorName = "Floor" .. SelectedFloor
                local slotName = "Slot" .. SelectedSlot
                pcall(function()
                    event:FireServer(floorName, slotName)
                end)
            end
            task.wait(0.5)
        else
            task.wait(0.25)
        end
    end
end)

-- Auto Upgrade ALL Brainrots (Floor 1-12 × Slot 1-10)
task.spawn(function()
    while true do
        if AutoAllSlots then
            local event = ReplicatedStorage:FindFirstChild("Events") 
                and ReplicatedStorage.Events:FindFirstChild("RequestSlotUpgrade")

            if event then
                for floor = 1, 12 do
                    for slot = 1, 10 do
                        if not AutoAllSlots then break end
                        local floorName = "Floor" .. floor
                        local slotName = "Slot" .. slot
                        pcall(function()
                            event:FireServer(floorName, slotName)
                        end)
                        task.wait(0.12)
                    end
                    if not AutoAllSlots then break end
                end
            end
            task.wait(0.3)
        else
            task.wait(0.25)
        end
    end
end)

print("[xexy hub] 104339804279870 loaded — Auto All Brainrots added")
