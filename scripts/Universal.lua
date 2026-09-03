-- Austin Hub

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/achieved-scripts/refs/heads/main/seahub.lua"))()

local Players          = game:GetService("Players")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")
local GuiService       = game:GetService("GuiService")
local LocalPlayer      = Players.LocalPlayer

local GameName = "Roblox"
pcall(function()
    GameName = game:GetService("MarketplaceService")
        :GetProductInfo(game.PlaceId).Name
end)

local AccentSoft = Color3.fromRGB(118, 194, 146)
local AccentDeep = Color3.fromRGB(56, 138, 92)
local MenuKey    = Enum.KeyCode.RightControl

local Window = UILibrary.CreateMain({
    Name  = "Austin Hub",
    Title = GameName,
    Desc  = "",
})

UILibrary.SetConfigFolder("AustinHub/Configs")

-- the library already prefixes every notification with the hub name,
-- so Title here is the subject only
local function notify(title, desc, time)
    UILibrary.CreateNoti({ Title = title, Desc = desc, ShowTime = time or 4 })
end

for _, key in ipairs({
    "Title Text Color", "Page Selected Color", "Section Text Color",
    "Label Color", "Dropdown Selected Color", "Search Icon Highlight Color",
}) do
    getgenv().UIColor[key] = AccentSoft
end

for _, key in ipairs({
    "Section Underline Color", "Toggle Border Color", "Toggle Checked Color",
    "Button Color", "Textbox Highlight Color", "Box Highlight Color",
    "Slider Highlight Color",
}) do
    getgenv().UIColor[key] = AccentDeep
end

getgenv().UIColor["Background Main Color"] = Color3.fromRGB(20, 20, 20)
getgenv().UIColor["Background 1 Color"]    = Color3.fromRGB(30, 30, 30)
getgenv().UIColor["Background 2 Color"]    = Color3.fromRGB(45, 45, 45)
getgenv().UIColor["Background 3 Color"]    = Color3.fromRGB(25, 25, 25)
getgenv().UIColor["Slider Line Color"]     = Color3.fromRGB(60, 60, 60)
getgenv().UIColor["Toggle Desc Color"]     = Color3.fromRGB(150, 150, 150)
getgenv().UIColor["Border Color"]          = Color3.fromRGB(40, 40, 40)

local MainPage     = Window.CreatePage({ Page_Name = "Main",     Page_Title = "Main" })
local PlayerPage   = Window.CreatePage({ Page_Name = "Player",   Page_Title = "Player" })
local InfoPage     = Window.CreatePage({ Page_Name = "Info",     Page_Title = "Info" })
local SettingsPage = Window.CreatePage({ Page_Name = "Settings", Page_Title = "Settings" })

-- Main

local General = MainPage.CreateSection("General")

local Status = General.CreateLabel({ Title = "Status: idle" })

General.CreateToggle({
    Title      = "Enable",
    Desc       = "Main feature",
    Default    = false,
    Keybind    = true,
    DefaultKey = Enum.KeyCode.F,
}, function(state)
    Status.SetText(state and "Status: running" or "Status: idle")
end)

General.CreateDropdown({
    Title   = "Mode",
    List    = { "Safe", "Balanced", "Fast" },
    Default = "Balanced",
}, function(value) end)

General.CreateSlider({
    Title   = "Interval",
    Min     = 0,
    Max     = 10,
    Default = 3,
    Precise = true,
}, function(value) end)

General.CreateButton({ Title = "Run Once" }, function()
    notify("Action", "Done.", 3)
end)

-- Player

local Movement = PlayerPage.CreateSection("Movement")

Movement.CreateToggle({
    Title              = "Walk Speed",
    Default            = false,
    Textbox            = true,
    TextboxDefault     = "16",
    TextboxPlaceholder = "speed",
    TextboxCallback    = function(text) end,
}, function(state) end)

Movement.CreateBox({
    Title       = "Value",
    Placeholder = "number",
    Default     = "",
    Number      = true,
}, function(text) end)

-- Settings

local Rejoin = SettingsPage.CreateSection("Rejoin")

local ServerState = {
    AutoRejoin  = false,
    AutoHop     = false,
    HopMinutes  = 60,
    MaxPlayers  = 0,      -- 0 = no cap
    PreferEmpty = true,
}

local hopStatus = Rejoin.CreateLabel({ Title = "Auto hop: off" })

local function rejoinServer()
    local ok, err = pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
    if not ok then notify("Rejoin", tostring(err)) end
end

local function serverHop()
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100")
        :format(game.PlaceId)

    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok then
        return notify("Server Hop", "Could not reach the server list.")
    end

    local decoded
    ok, decoded = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
        return notify("Server Hop", "Bad response from the server list.")
    end

    local candidates = {}
    for _, server in ipairs(decoded.data) do
        local room = server.maxPlayers - server.playing
        local capOK = ServerState.MaxPlayers == 0
            or server.playing <= ServerState.MaxPlayers
        if server.id ~= game.JobId and room > 0 and capOK then
            table.insert(candidates, server)
        end
    end

    if #candidates == 0 then
        return notify("Server Hop", "No other server matched.")
    end

    table.sort(candidates, function(a, b)
        if ServerState.PreferEmpty then
            return a.playing < b.playing
        end
        return a.playing > b.playing
    end)

    local target = candidates[1]
    local sent = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
    end)
    if not sent then notify("Server Hop", "Teleport was rejected.") end
end

Rejoin.CreateToggle({
    Title   = "Auto Rejoin",
    Desc    = "Rejoin automatically when disconnected",
    Default = false,
}, function(state)
    ServerState.AutoRejoin = state
end)

Rejoin.CreateToggle({
    Title   = "Auto Server Hop",
    Desc    = "Switch servers on a timer",
    Default = false,
}, function(state)
    ServerState.AutoHop = state
    hopStatus.SetText(state
        and ("Auto hop: every " .. ServerState.HopMinutes .. " min")
        or  "Auto hop: off")
end)

Rejoin.CreateToggle({
    Title   = "Prefer Emptier Servers",
    Desc    = "Off picks the fullest instead",
    Default = true,
}, function(state)
    ServerState.PreferEmpty = state
end)

Rejoin.CreateSlider({
    Title   = "Switch After (mins)",
    Min     = 1,
    Max     = 180,
    Default = 60,
}, function(value)
    ServerState.HopMinutes = value
    if ServerState.AutoHop then
        hopStatus.SetText("Auto hop: every " .. value .. " min")
    end
end)

Rejoin.CreateBox({
    Title       = "Max Players in Server",
    Placeholder = "0 = any",
    Default     = "0",
    Number      = true,
}, function(text)
    ServerState.MaxPlayers = tonumber(text) or 0
end)

Rejoin.CreateButton({ Title = "Rejoin" }, rejoinServer)
Rejoin.CreateButton({ Title = "Server Hop" }, serverHop)

Rejoin.CreateButton({ Title = "Copy Job Id" }, function()
    if setclipboard then
        setclipboard(game.JobId)
        notify("Server", "Job Id copied.")
    else
        notify("Server", "Executor has no clipboard access.")
    end
end)

-- disconnect watcher
pcall(function()
    GuiService.ErrorMessageChanged:Connect(function()
        if ServerState.AutoRejoin then
            task.wait(1)
            rejoinServer()
        end
    end)
end)

-- hop timer
task.spawn(function()
    local elapsed = 0
    while task.wait(1) do
        if ServerState.AutoHop then
            elapsed = elapsed + 1
            if elapsed >= ServerState.HopMinutes * 60 then
                elapsed = 0
                serverHop()
            end
        else
            elapsed = 0
        end
    end
end)

local Utility = SettingsPage.CreateSection("Utility")

local idleConnection

Utility.CreateToggle({
    Title   = "Anti AFK",
    Desc    = "Blocks the 20 minute idle kick",
    Default = false,
}, function(state)
    if idleConnection then
        idleConnection:Disconnect()
        idleConnection = nil
    end
    if state then
        idleConnection = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end)

Utility.CreateButton({ Title = "Rejoin Current Server" }, function()
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    if not ok then notify("Server", "Teleport was rejected.") end
end)

local Config = SettingsPage.CreateSection("Config")

local ConfigName = ""
local ConfigList

local function refresh()
    local ok, list = pcall(UILibrary.ConfigSystem.List)
    if ok and type(list) == "table" and ConfigList then
        ConfigList.GetNewList(list)
    end
end

if not UILibrary.HasFileSystem then
    Config.CreateLabel({ Title = "Executor has no file access - configs disabled" })
end

Config.CreateBox({
    Title       = "Config Name",
    Placeholder = "name",
    Default     = "",
}, function(text)
    ConfigName = text
end)

ConfigList = Config.CreateDropdown({
    Title   = "Saved Configs",
    List    = {},
    Default = "",
}, function(value)
    ConfigName = value
end)

Config.CreateButton({ Title = "Save" }, function()
    if ConfigName == "" then return notify("Config", "Enter a name first.") end
    local ok, err = UILibrary.ConfigSystem.Save(ConfigName)
    notify("Config", ok and ("Saved " .. ConfigName) or tostring(err))
    refresh()
end)

Config.CreateButton({ Title = "Load" }, function()
    if ConfigName == "" then return notify("Config", "Pick a config first.") end
    local ok, err = UILibrary.ConfigSystem.Load(ConfigName)
    notify("Config", ok and ("Loaded " .. ConfigName) or tostring(err))
end)

Config.CreateButton({ Title = "Delete" }, function()
    if ConfigName == "" then return notify("Config", "Pick a config first.") end
    local ok, err = UILibrary.ConfigSystem.Delete(ConfigName)
    notify("Config", ok and ("Deleted " .. ConfigName) or tostring(err))
    ConfigName = ""
    refresh()
end)

Config.CreateButton({ Title = "Refresh List" }, refresh)

refresh()

local Interface = SettingsPage.CreateSection("Interface")

local function toggleMenu()
    local gui = UILibrary.Internal.Gui
    if gui then gui.Enabled = not gui.Enabled end
end

Interface.CreateKeybind({
    Title   = "Menu Key",
    Default = MenuKey,
}, toggleMenu)

Interface.CreateSlider({
    Title   = "Animation Speed",
    Min     = 0,
    Max     = 1,
    Default = 0.5,
    Precise = true,
}, function(value)
    getgenv().UIColor["Tween Animation 2 Speed"] = value
end)

Interface.CreateDropdown({
    Title   = "Easing Style",
    List    = { "Quad", "Quint", "Back", "Sine", "Linear" },
    Default = "Quad",
}, function(style)
    getgenv().UIColor["Tween Easing Style"] = style
end)

Interface.CreateBox({
    Title       = "Background",
    Placeholder = "rbxassetid:// or image URL",
    Default     = "",
}, function(url)
    if url ~= "" then
        getgenv().UIColor["Background 1 Transparency"] = 0.4
        UILibrary.SetBackground(url)
        getgenv().UIColor["Background 1 Transparency"] = 0.4
    end
end)

Interface.CreateSlider({
    Title   = "Panel Transparency",
    Min     = 0,
    Max     = 1,
    Default = 0,
    Precise = true,
}, function(value)
    getgenv().UIColor["Background 1 Transparency"] = value
end)

Interface.CreateButton({ Title = "Unload" }, function()
    if idleConnection then idleConnection:Disconnect() end
    ServerState.AutoHop = false
    ServerState.AutoRejoin = false
    if UILibrary.Internal.Gui then UILibrary.Internal.Gui:Destroy() end
    if UILibrary.Internal.NotiGui then UILibrary.Internal.NotiGui:Destroy() end
    getgenv().Tvk = nil
    getgenv().Chon = nil
end)

-- Info

local Credits = InfoPage.CreateSection("Credits")

Credits.CreateLabel({ Title = "Marcus  ~  main dev" })
Credits.CreateLabel({ Title = "Kiriot22  ~  esp module" })
Credits.CreateLabel({ Title = "Dum1211  ~  ui lib" })
Credits.CreateLabel({ Title = "Austin  ~  marcus brother" })

local ServerInfo = InfoPage.CreateSection("Server")

local lblPlayers = ServerInfo.CreateLabel({ Title = "Players: -" })
local lblPing    = ServerInfo.CreateLabel({ Title = "Ping: -" })
local lblFps     = ServerInfo.CreateLabel({ Title = "FPS: -" })
local lblUptime  = ServerInfo.CreateLabel({ Title = "Session: 0s" })
local lblJob     = ServerInfo.CreateLabel({ Title = "Job Id: " .. tostring(game.JobId) })

ServerInfo.CreateButton({ Title = "Copy Job Id" }, function()
    if setclipboard then
        setclipboard(game.JobId)
        notify("Server", "Job Id copied.")
    else
        notify("Server", "Executor has no clipboard access.")
    end
end)

local About = InfoPage.CreateSection("About")

local executorName = "Unknown"
pcall(function()
    executorName = (identifyexecutor and identifyexecutor())
        or (getexecutorname and getexecutorname())
        or "Unknown"
end)

About.CreateLabel({ Title = "Austin Hub  v0.1a" })
About.CreateLabel({ Title = "Game: " .. GameName })
About.CreateLabel({ Title = "Place Id: " .. tostring(game.PlaceId) })
About.CreateLabel({ Title = "Executor: " .. tostring(executorName) })
About.CreateLabel({ Title = "UI Library: SeaUI " .. tostring(UILibrary.VERSION or "?") })

-- live server readout
local RunService = game:GetService("RunService")
local Stats      = game:GetService("Stats")

local startedAt = os.time()
local frames, frameClock, fps = 0, os.clock(), 0

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    local now = os.clock()
    if now - frameClock >= 1 then
        fps = math.floor(frames / (now - frameClock) + 0.5)
        frames, frameClock = 0, now
    end
end)

local function formatUptime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor(seconds % 3600 / 60)
    local sec = seconds % 60
    if h > 0 then
        return ("%dh %dm %ds"):format(h, m, sec)
    elseif m > 0 then
        return ("%dm %ds"):format(m, sec)
    end
    return ("%ds"):format(sec)
end

task.spawn(function()
    while task.wait(1) do
        if not UILibrary.Internal.Gui or not UILibrary.Internal.Gui.Parent then
            break
        end

        pcall(function()
            lblPlayers.SetText(("Players: %d / %d")
                :format(#Players:GetPlayers(), Players.MaxPlayers))
        end)

        pcall(function()
            local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            lblPing.SetText(("Ping: %d ms"):format(math.floor(ping + 0.5)))
        end)

        pcall(function()
            lblFps.SetText("FPS: " .. tostring(fps))
        end)

        pcall(function()
            lblUptime.SetText("Session: " .. formatUptime(os.time() - startedAt))
        end)
    end
end)

notify("Loaded", GameName, 4)
