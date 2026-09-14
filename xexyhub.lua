-- all this is, is a hub where all the scripts in this github can be accessed through. Either use this hub to detect the game or just run the code in the .lua file dosnt bother me just easier
--[[
    xexy hub | Official Hub Loader
    (Paste and execute THIS in your executor)
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Clean up any old loaders so nothing ever overlaps
if CoreGui:FindFirstChild("xexyHub_Loader") then
    CoreGui["xexyHub_Loader"]:Destroy()
end

local PlaceId = game.PlaceId
local RepoUser = "xexyimports"
local RepoName = "brainrotfreeeats"

-- Safe GitHub fetcher
local function FetchGitHub(filename)
    filename = filename:gsub("%s+", ""):gsub("^/+", "")
    local urls = {
        string.format("https://raw.githubusercontent.com/%s/%s/main/%s", RepoUser, RepoName, filename),
        string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/main/%s", RepoUser, RepoName, filename)
    }

    for _, url in ipairs(urls) do
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res and res ~= "" and not res:match("^404") and not res:lower():find("404: not found") then
            return true, res
        end
    end
    return false, "404 Not Found"
end

-- =========================================================
-- SMALL LOADER POPUP
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "xexyHub_Loader"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 160)
Main.Position = UDim2.new(0.5, -190, 0.5, -80)
Main.BackgroundColor3 = Color3.fromRGB(12, 8, 10)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90, 15, 28)
Stroke.Thickness = 1.5
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 12, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "xexy hub loader"
Title.TextColor3 = Color3.fromRGB(255, 65, 90)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -24, 0, 95)
Status.Position = UDim2.new(0, 12, 0, 48)
Status.BackgroundColor3 = Color3.fromRGB(20, 7, 10)
Status.TextColor3 = Color3.fromRGB(220, 180, 190)
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.TextWrapped = true
Status.Text = "Checking supported games..."
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = Status

-- =========================================================
-- RUN CHECK & LOAD
-- =========================================================
task.spawn(function()
    local okList, listData = FetchGitHub("supportedgames.txt")
    if not okList then
        Status.Text = "✗ Failed to read supportedgames.txt from GitHub"
        Status.TextColor3 = Color3.fromRGB(255, 90, 100)
        return
    end

    local Games = {}
    for line in listData:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" and not line:match("^#") then
            local parts = string.split(line, "|")
            if #parts >= 2 then
                local id = tonumber(parts[1]:match("%d+"))
                local name = parts[2] and parts[2]:gsub("^%s+", ""):gsub("%s+$", "") or "Unknown"
                local file = parts[3] and parts[3]:gsub("%s+", "") or ""

                if id then
                    Games[id] = {
                        Name = name,
                        File = (file ~= "" and file) or nil
                    }
                end
            end
        end
    end

    local currentGame = Games[PlaceId]

    if not currentGame then
        Status.Text = string.format("✗ Game Not Supported\nPlaceId: %s", tostring(PlaceId))
        Status.TextColor3 = Color3.fromRGB(255, 90, 100)
        return
    end

    if not currentGame.File then
        Status.Text = string.format("✗ No script attached for:\n%s", currentGame.Name)
        Status.TextColor3 = Color3.fromRGB(255, 90, 100)
        return
    end

    Status.Text = string.format("✓ %s\nDownloading %s...", currentGame.Name, currentGame.File)
    Status.TextColor3 = Color3.fromRGB(80, 255, 140)

    local dlOk, scriptSource = FetchGitHub(currentGame.File)
    if not dlOk then
        Status.Text = string.format("✗ 404: %s not found on GitHub repository!", currentGame.File)
        Status.TextColor3 = Color3.fromRGB(255, 90, 100)
        return
    end

    local compileOk, compiledFn = pcall(function() return loadstring(scriptSource) end)
    if not compileOk or not compiledFn then
        Status.Text = "✗ Script Compile Error:\n" .. tostring(compiledFn)
        Status.TextColor3 = Color3.fromRGB(255, 90, 100)
        return
    end

    Status.Text = "✓ Opening hub..."
    task.wait(0.15)

    -- Destroy the loader window completely before starting the game script
    ScreenGui:Destroy()

    -- Run game script
    task.spawn(function()
        local runOk, runErr = pcall(compiledFn)
        if not runOk then
            warn("[xexy hub] Runtime error in " .. currentGame.File .. ": " .. tostring(runErr))
        end
    end)
end)
