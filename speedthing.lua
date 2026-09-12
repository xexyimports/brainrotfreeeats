--[[
    xexy hub | Universal Hub & Support Validator
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- =========================================================
-- REPOSITORY CONFIGURATION
-- =========================================================

local BaseRepoURL = "https://raw.githubusercontent.com/xexyimports/brainrotfreeeats/refs/heads/main/"
local SupportedListURL = BaseRepoURL .. "supportedgames.txt"

-- Built-in Speed Farm Settings (for games without a .lua attached)
local StepsAmount = 9999999999999999999
local EndCFrame = CFrame.new(-5.63876893e-06, 2, -9076, 0, 0, 1, 0, 1, 0, -1, 0, 0)

local SupportedPlaceIds = {}
local CurrentGameData = nil
local IsGameSupported = false
local SupportedLoaded = false
local Minimized = false

-- =========================================================
-- CREATE GUI
-- =========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "xexyHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 560, 0, 400)
Main.Position = UDim2.new(0.5, -280, 0.5, -200)
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

-- Top Bar
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

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = btn
    return btn
end

local TabMain = makeTab("Main", 1)
local TabFarm = makeTab("Farm", 2)
local TabSide = makeTab("Side", 3)
local TabInfo = makeTab("Info", 4)

-- Content Pages
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
MainPage.CanvasSize = UDim2.new(0, 0, 0, 470)
MainPage.Visible = true
MainPage.Parent = Content

local FarmPage = Instance.new("Frame")
FarmPage.Size = UDim2.new(1, 0, 1, 0)
FarmPage.BackgroundTransparency = 1
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

-- =========================================================
-- UI HELPERS
-- =========================================================

local function makeLabel(parent, text, y, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, size or 18)
    label.Position = UDim2.new(0, 8, 0, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 140, 150)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function makeButton(parent, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(160, 25, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 240, 245)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeToggle(parent, text, y)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -16, 0, 34)
    holder.Position = UDim2.new(0, 8, 0, y)
    holder.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
    holder.BorderSizePixel = 0
    holder.Parent = parent

    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 7)
    hc.Parent = holder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 200, 210)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 24)
    toggle.Position = UDim2.new(1, -52, 0.5, -12)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 18, 24)
    toggle.Text = ""
    toggle.Parent = holder

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 220, 225)
    knob.Parent = toggle

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local state = false
    toggle.MouseButton1Click:Connect(function()
        if not IsGameSupported then return end
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(200, 30, 55) or Color3.fromRGB(50, 18, 24)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()
    end)

    return function() return state and IsGameSupported end
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

-- =========================================================
-- MAIN TAB
-- =========================================================

makeLabel(MainPage, "CURRENT GAME", 6)

local GameNameLabel = Instance.new("TextLabel")
GameNameLabel.Size = UDim2.new(1, -16, 0, 30)
GameNameLabel.Position = UDim2.new(0, 8, 0, 26)
GameNameLabel.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
GameNameLabel.Text = "  Checking repository..."
GameNameLabel.TextColor3 = Color3.fromRGB(255, 90, 110)
GameNameLabel.Font = Enum.Font.GothamBold
GameNameLabel.TextSize = 14
GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameNameLabel.Parent = MainPage

local GameNameCorner = Instance.new("UICorner")
GameNameCorner.CornerRadius = UDim.new(0, 7)
GameNameCorner.Parent = GameNameLabel

makeLabel(MainPage, "PLACE ID: " .. tostring(game.PlaceId), 64)
makeLabel(MainPage, "SUPPORT STATUS", 96)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 34)
StatusLabel.Position = UDim2.new(0, 8, 0, 118)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
StatusLabel.Text = "  Checking repository..."
StatusLabel.TextColor3 = Color3.fromRGB(220, 180, 190)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainPage

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 7)
StatusCorner.Parent = StatusLabel

makeLabel(MainPage, "SERVER", 168)
makeButton(MainPage, "Server Hop", 190, function()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end)

makeLabel(MainPage, "SUPPORTED GAMES LIST", 242)
makeLabel(MainPage, "Click a game below to teleport to it.", 264)

local GamesContainer = Instance.new("ScrollingFrame")
GamesContainer.Name = "GamesContainer"
GamesContainer.Size = UDim2.new(1, -16, 0, 145)
GamesContainer.Position = UDim2.new(0, 8, 0, 290)
GamesContainer.BackgroundTransparency = 1
GamesContainer.BorderSizePixel = 0
GamesContainer.ScrollBarThickness = 3
GamesContainer.ScrollBarImageColor3 = Color3.fromRGB(180, 40, 60)
GamesContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
GamesContainer.Parent = MainPage

local GamesLayout = Instance.new("UIListLayout")
GamesLayout.SortOrder = Enum.SortOrder.LayoutOrder
GamesLayout.Padding = UDim.new(0, 6)
GamesLayout.Parent = GamesContainer

GamesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    GamesContainer.CanvasSize = UDim2.new(0, 0, 0, GamesLayout.AbsoluteContentSize.Y + 8)
end)

local function addGameButton(placeId, gameName, order)
    local button = Instance.new("TextButton")
    button.Name = "Game_" .. tostring(placeId)
    button.Size = UDim2.new(1, 0, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(160, 25, 45)
    button.BorderSizePixel = 0
    button.Text = "  " .. gameName .. "  [" .. tostring(placeId) .. "]"
    button.TextColor3 = Color3.fromRGB(255, 240, 245)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.LayoutOrder = order
    button.Parent = GamesContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        pcall(function()
            TeleportService:Teleport(placeId, player)
        end)
    end)
end

-- =========================================================
-- FARM TAB UI
-- =========================================================

makeLabel(FarmPage, "FARMING", 6)
local FarmStatusLabel = makeLabel(FarmPage, "Checking repository...", 28)

-- Speed Farm container (used when game has no .lua in txt)
local SpeedFarmFrame = Instance.new("Frame")
SpeedFarmFrame.Size = UDim2.new(1, 0, 1, -55)
SpeedFarmFrame.Position = UDim2.new(0, 0, 0, 55)
SpeedFarmFrame.BackgroundTransparency = 1
SpeedFarmFrame.Visible = false
SpeedFarmFrame.Parent = FarmPage

local getAutoSteps = makeToggle(SpeedFarmFrame, "Auto Farm Steps", 0)
local getAutoCash = makeToggle(SpeedFarmFrame, "Auto Cash (CFrame)", 40)
local getAutoRebirth = makeToggle(SpeedFarmFrame, "Auto Rebirth", 80)

makeLabel(SpeedFarmFrame, "STEPS AMOUNT", 126)
local StepsBox = makeTextbox(SpeedFarmFrame, "Enter steps amount...", 148, StepsAmount)

StepsBox.FocusLost:Connect(function()
    local n = tonumber(StepsBox.Text)
    if n and n > 0 then
        StepsAmount = math.floor(n)
        StepsBox.Text = tostring(StepsAmount)
    else
        StepsBox.Text = tostring(StepsAmount)
    end
end)

-- External Script container (used when game has a .lua file attached)
local ExternalScriptFrame = Instance.new("Frame")
ExternalScriptFrame.Size = UDim2.new(1, 0, 1, -55)
ExternalScriptFrame.Position = UDim2.new(0, 0, 0, 55)
ExternalScriptFrame.BackgroundTransparency = 1
ExternalScriptFrame.Visible = false
ExternalScriptFrame.Parent = FarmPage

local ExtLoadedLabel = makeLabel(ExternalScriptFrame, "Running external script from GitHub:", 0)

local ExtFileNameBox = Instance.new("TextLabel")
ExtFileNameBox.Size = UDim2.new(1, -16, 0, 32)
ExtFileNameBox.Position = UDim2.new(0, 8, 0, 24)
ExtFileNameBox.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
ExtFileNameBox.Text = "  None"
ExtFileNameBox.TextColor3 = Color3.fromRGB(80, 255, 140)
ExtFileNameBox.Font = Enum.Font.GothamBold
ExtFileNameBox.TextSize = 13
ExtFileNameBox.TextXAlignment = Enum.TextXAlignment.Left
ExtFileNameBox.Parent = ExternalScriptFrame

local ExtCorner = Instance.new("UICorner")
ExtCorner.CornerRadius = UDim.new(0, 7)
ExtCorner.Parent = ExtFileNameBox

-- =========================================================
-- REPOSITORY CHECK & DYNAMIC LOADER
-- =========================================================

task.spawn(function()
    local success, result = pcall(function()
        return game:HttpGet(SupportedListURL)
    end)

    if success and type(result) == "string" then
        for line in string.gmatch(result, "[^\r\n]+") do
            line = line:gsub("^%s+", ""):gsub("%s+$", "")
            if line ~= "" and not line:match("^#") then
                local parts = string.split(line, "|")
                local id = tonumber(parts[1] and parts[1]:match("%d+"))
                if id then
                    local name = parts[2] and parts[2]:gsub("^%s+", ""):gsub("%s+$", "") or ""
                    local scriptFile = parts[3] and parts[3]:gsub("^%s+", ""):gsub("%s+$", "") or ""

                    SupportedPlaceIds[id] = {
                        name = (name ~= "" and name) or ("Place " .. tostring(id)),
                        script = (scriptFile ~= "" and scriptFile) or nil
                    }
                end
            end
        end
    end

    CurrentGameData = SupportedPlaceIds[game.PlaceId]
    IsGameSupported = (CurrentGameData ~= nil)
    SupportedLoaded = true

    -- 1. NOT SUPPORTED
    if not IsGameSupported then
        StatusLabel.Text = "  ✗ NOT SUPPORTED"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 90, 100)
        StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 15, 20)

        FarmStatusLabel.Text = "✗ Game is NOT supported. Farming disabled."
        FarmStatusLabel.TextColor3 = Color3.fromRGB(255, 90, 100)
        makeLabel(FarmPage, "This game is not listed in your repository.", 55)

        pcall(function()
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            GameNameLabel.Text = "  " .. (info and info.Name or game.Name)
        end)

    -- 2. SUPPORTED
    else
        StatusLabel.Text = "  ✓ SUPPORTED"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
        StatusLabel.BackgroundColor3 = Color3.fromRGB(20, 50, 30)
        GameNameLabel.Text = "  " .. CurrentGameData.name

        -- If the game has a .lua file listed in supportedgames.txt:
        if CurrentGameData.script then
            FarmStatusLabel.Text = "✓ Running GitHub Script: " .. CurrentGameData.script
            FarmStatusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
            ExtFileNameBox.Text = "  " .. CurrentGameData.script
            ExternalScriptFrame.Visible = true

            -- Execute the script from the repository
            task.spawn(function()
                local sUrl = BaseRepoURL .. CurrentGameData.script
                print("[xexy hub] Fetching script from: " .. sUrl)
                local ok, content = pcall(function() return game:HttpGet(sUrl) end)
                if ok and content and content ~= "" then
                    local runOk, runErr = pcall(function() loadstring(content)() end)
                    if not runOk then
                        warn("[xexy hub] Script runtime error: " .. tostring(runErr))
                    end
                else
                    warn("[xexy hub] Could not fetch script from repository!")
                end
            end)

        -- If the game has NO .lua file listed (Speed game thing):
        else
            FarmStatusLabel.Text = "✓ Speed Farm Active"
            FarmStatusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
            SpeedFarmFrame.Visible = true
        end
    end

    -- Populate teleport list with repository games
    local ids = {}
    for placeId in pairs(SupportedPlaceIds) do
        table.insert(ids, placeId)
    end
    table.sort(ids)

    for order, placeId in ipairs(ids) do
        local data = SupportedPlaceIds[placeId]
        addGameButton(placeId, data.name, order)
    end
end)

-- =========================================================
-- SPEED GAME FARM ENGINE (Runs only for games without .lua)
-- =========================================================

RunService.Heartbeat:Connect(function()
    -- Only run if supported AND has no external script attached
    if not IsGameSupported or (CurrentGameData and CurrentGameData.script) then
        return
    end

    -- 1. Auto Steps
    if getAutoSteps() then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local event = remotes:FindFirstChild("StepTaken")
            if event then
                pcall(function()
                    event:FireServer(StepsAmount, true, "Road1")
                end)
            end
        end
    end

    -- 2. Auto Cash (CFrame)
    if getAutoCash() then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = EndCFrame
        end
    end

    -- 3. Auto Rebirth
    if getAutoRebirth() then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local event = remotes:FindFirstChild("RequestRebirth")
            if event then
                pcall(function()
                    event:FireServer("free")
                end)
            end
        end
    end
end)

-- =========================================================
-- SIDE PAGE (LOADERS)
-- =========================================================

makeLabel(SidePage, "EXTERNAL UTILITIES & LOADERS", 6)

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

makeLabel(SidePage, "All external loaders are wrapped safely in pcall.", 175)

-- =========================================================
-- INFO PAGE
-- =========================================================

makeLabel(InfoPage, "PLAYER INFO", 6)

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 84, 0, 84)
Avatar.Position = UDim2.new(0, 8, 0, 30)
Avatar.BackgroundColor3 = Color3.fromRGB(28, 10, 14)
Avatar.Parent = InfoPage

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 10)
AvatarCorner.Parent = Avatar

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

local DisplayLabel = Instance.new("TextLabel")
DisplayLabel.Size = UDim2.new(1, -110, 0, 20)
DisplayLabel.Position = UDim2.new(0, 104, 0, 82)
DisplayLabel.BackgroundTransparency = 1
DisplayLabel.Text = "Display: " .. player.DisplayName
DisplayLabel.TextColor3 = Color3.fromRGB(200, 160, 170)
DisplayLabel.Font = Enum.Font.Gotham
DisplayLabel.TextSize = 13
DisplayLabel.TextXAlignment = Enum.TextXAlignment.Left
DisplayLabel.Parent = InfoPage

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
    local execName = "Unknown"
    local ok, res = pcall(function()
        if identifyexecutor then return identifyexecutor()
        elseif getexecutorname then return getexecutorname()
        elseif syn then return "Synapse X"
        elseif fluxus then return "Fluxus"
        elseif KRNL_LOADED then return "KRNL"
        else return "Unknown / Generic" end
    end)
    if ok and res then execName = tostring(res) end
    ExecutorLabel.Text = "  " .. execName
end)

makeLabel(InfoPage, "PlaceId: " .. tostring(game.PlaceId), 200)
makeLabel(InfoPage, "JobId: " .. tostring(game.JobId), 222)

-- =========================================================
-- TAB SWITCHER & WINDOW LOGIC
-- =========================================================

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
    if ScreenGui then ScreenGui:Destroy() end
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
        Main.Size = UDim2.new(0, 560, 0, 400)
    end
end)

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

print("[xexy hub] initialized and support checks ready")
