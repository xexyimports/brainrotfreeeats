--[[
    xexy hub
    Game: 78177131121429
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- // SETTINGS
local SupportedListURL = "https://raw.githubusercontent.com/xexyimports/brainrotfreeeats/refs/heads/main/supportedgames.txt"
local SupportedPlaceIds = {}
local SupportedGamesInfo = {}
local IsGameSupported = false
local SupportedLoaded = false

local Minimized = false

-- CFrames
local SwagBrainrotCF = CFrame.new(39, -72, 1710)
local BaseCF = CFrame.new(32, -72, -24)

-- // STRONGER INSTANT PICKUP
local instantPickup = false
local cachedPrompts = {}

local function isBrainrotPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return false end
    local text = string.lower((prompt.ActionText or "") .. (prompt.ObjectText or "") .. (prompt.Name or ""))
    return text:find("pick") or text:find("brainrot") or text:find("collect") or text:find("grab") or text:find("take")
end

local function cachePrompts()
    table.clear(cachedPrompts)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if isBrainrotPrompt(prompt) then
            pcall(function()
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 15
            end)
            table.insert(cachedPrompts, prompt)
        end
    end
end

task.spawn(function()
    while true do
        if instantPickup then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                for i = #cachedPrompts, 1, -1 do
                    local prompt = cachedPrompts[i]
                    if prompt and prompt.Parent and prompt.Enabled then
                        local parent = prompt.Parent
                        if parent:IsA("BasePart") then
                            local dist = (parent.Position - root.Position).Magnitude
                            if dist <= 14 then
                                pcall(function()
                                    prompt.HoldDuration = 0
                                    fireproximityprompt(prompt)
                                end)
                                pcall(function()
                                    fireproximityprompt(prompt, 1)
                                end)
                                pcall(function()
                                    if prompt.InputHoldBegin then
                                        prompt:InputHoldBegin()
                                        task.wait()
                                        prompt:InputHoldEnd()
                                    end
                                end)
                            end
                        end
                    else
                        table.remove(cachedPrompts, i)
                    end
                end
            end
            task.wait(0.08)
        else
            task.wait(0.25)
        end
    end
end)

workspace.DescendantAdded:Connect(function(desc)
    if isBrainrotPrompt(desc) then
        pcall(function()
            desc.HoldDuration = 0
            desc.RequiresLineOfSight = false
        end)
        table.insert(cachedPrompts, desc)
    end
end)

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

    IsGameSupported = SupportedPlaceIds[game.PlaceId] == true
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
Main.Size = UDim2.new(0, 560, 0, 460)
Main.Position = UDim2.new(0.5, -280, 0.5, -230)
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
FarmPage.CanvasSize = UDim2.new(0, 0, 0, 480)
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

local function makeTextbox(parent, placeholder, y, default)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 0, 34)
    box.Position = UDim2.new(0, 8, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
    box.Text = tostring(default or "")
    box.PlaceholderText = placeholder
    box.TextColor3 = Color3.fromRGB(240, 210, 220)
    box.PlaceholderColor3 = Color3.fromRGB(120, 80, 90)
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.Parent = parent

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 7)
    bc.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.Parent = box
    return box
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
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
StatusLabel.Text = "  Checking..."
StatusLabel.TextColor3 = Color3.fromRGB(220, 180, 190)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainPage

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 7)
sc.Parent = StatusLabel

task.spawn(function()
    while not SupportedLoaded do task.wait(0.1) end
    if IsGameSupported then
        StatusLabel.Text = "  ✓ SUPPORTED"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
        StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
    else
        StatusLabel.Text = "  ✗ NOT SUPPORTED"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 100)
        StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 15, 20)
    end
end)

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

makeButton(FarmPage, "Teleport to Swag Brainrot. Mine further if you want better", 28, function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = SwagBrainrotCF
    end
end)

makeButton(FarmPage, "Teleport to Base", 70, function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = BaseCF
    end
end)

makeToggleButton(FarmPage, "Instant Brainrot Pickup dosnt work dont try", 112, function(state)
    instantPickup = state
    if state then
        cachePrompts()
    end
end)

makeLabel(FarmPage, "STRENGTH", 160)

local StrengthBox = makeTextbox(FarmPage, "Enter strength value...", 182, "0")

makeButton(FarmPage, "Set Strength", 224, function()
    local value = tonumber(StrengthBox.Text) or 0
    local event = ReplicatedStorage:FindFirstChild("Network") 
        and ReplicatedStorage.Network:FindFirstChild("RemoteEvents") 
        and ReplicatedStorage.Network.RemoteEvents:FindFirstChild("Strength")

    if event then
        pcall(function()
            firesignal(event.OnClientEvent, value, 1)
        end)
    end
end)

makeLabel(FarmPage, "DRILL SELECTOR", 270)

local DrillDropdown = Instance.new("TextButton")
DrillDropdown.Size = UDim2.new(1, -16, 0, 34)
DrillDropdown.Position = UDim2.new(0, 8, 0, 292)
DrillDropdown.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
DrillDropdown.Text = "  Wooden Drill"
DrillDropdown.TextColor3 = Color3.fromRGB(240, 210, 220)
DrillDropdown.Font = Enum.Font.Gotham
DrillDropdown.TextSize = 13
DrillDropdown.TextXAlignment = Enum.TextXAlignment.Left
DrillDropdown.Parent = FarmPage

local ddCorner = Instance.new("UICorner")
ddCorner.CornerRadius = UDim.new(0, 7)
ddCorner.Parent = DrillDropdown

local SelectedDrill = "Wooden Drill"
local DrillList = {"Wooden Drill", "Steel Drill", "Admin Drill"}

task.spawn(function()
    local shovels = ReplicatedStorage:FindFirstChild("Shovels")
    if shovels then
        for _, shovel in ipairs(shovels:GetChildren()) do
            if not table.find(DrillList, shovel.Name) then
                table.insert(DrillList, shovel.Name)
            end
        end
    end
end)

local DrillOpen = false
local DrillFrame = nil

DrillDropdown.MouseButton1Click:Connect(function()
    if DrillOpen and DrillFrame then
        DrillFrame:Destroy()
        DrillOpen = false
        return
    end

    DrillOpen = true
    DrillFrame = Instance.new("ScrollingFrame")
    DrillFrame.Size = UDim2.new(1, -16, 0, 160)
    DrillFrame.Position = UDim2.new(0, 8, 0, 330)
    DrillFrame.BackgroundColor3 = Color3.fromRGB(20, 8, 12)
    DrillFrame.BorderSizePixel = 0
    DrillFrame.ScrollBarThickness = 4
    DrillFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 40, 60)
    DrillFrame.CanvasSize = UDim2.new(0, 0, 0, #DrillList * 28)
    DrillFrame.Parent = FarmPage

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 7)
    fc.Parent = DrillFrame

    local layout = Instance.new("UIListLayout")
    layout.Parent = DrillFrame

    for _, drillName in ipairs(DrillList) do
        local opt = Instance.new("TextButton")
        opt.Size = UDim2.new(1, 0, 0, 28)
        opt.BackgroundTransparency = 1
        opt.Text = "  " .. drillName
        opt.TextColor3 = Color3.fromRGB(230, 200, 210)
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 13
        opt.TextXAlignment = Enum.TextXAlignment.Left
        opt.Parent = DrillFrame

        opt.MouseButton1Click:Connect(function()
            SelectedDrill = drillName
            DrillDropdown.Text = "  " .. drillName
            DrillFrame:Destroy()
            DrillOpen = false
        end)
    end
end)

makeButton(FarmPage, "Give Selected Drill", 380, function()
    local event = ReplicatedStorage:FindFirstChild("Network") 
        and ReplicatedStorage.Network:FindFirstChild("RemoteEvents") 
        and ReplicatedStorage.Network.RemoteEvents:FindFirstChild("ShovelData")

    if event then
        local data = {
            ["Wooden Drill"] = true,
            [SelectedDrill] = true
        }
        pcall(function()
            firesignal(event.OnClientEvent, data, SelectedDrill)
        end)
    end
end)

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
    instantPickup = false
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
        Main.Size = UDim2.new(0, 560, 0, 460)
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

print("[xexy hub] 78177131121429 loaded — stronger instant pickup")
