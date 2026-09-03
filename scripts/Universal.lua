-- Austina

local BASE_URL = "https://raw.githubusercontent.com/Ic0u/austina/main/"

local function loadRemoteModule(path)
    local fetched, source = pcall(game.HttpGet, game, BASE_URL .. path)
    if not fetched or type(source) ~= "string" or source == "" then
        return nil, "could not download " .. path
    end

    local chunk, compileError = loadstring(source)
    if not chunk then
        return nil, compileError
    end

    local executed, module = pcall(chunk)
    if not executed then
        return nil, module
    end

    return module
end

local UILibrary, uiError = loadRemoteModule("libraries/UILibrary.lua")
if not UILibrary then
    error("Austina UI library failed: " .. tostring(uiError))
end

local ESP, espError = loadRemoteModule("libraries/ESPLibrary.lua")

local Players          = game:GetService("Players")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")
local GuiService       = game:GetService("GuiService")
local Lighting         = game:GetService("Lighting")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats            = game:GetService("Stats")
local LocalPlayer      = Players.LocalPlayer or Players.PlayerAdded:Wait()

local GameName = "Roblox"
pcall(function()
    GameName = game:GetService("MarketplaceService")
        :GetProductInfo(game.PlaceId).Name
end)

local AccentSoft = Color3.fromRGB(118, 194, 146)
local AccentDeep = Color3.fromRGB(56, 138, 92)
local MenuKey    = Enum.KeyCode.RightControl

local Window = UILibrary.CreateMain({
    Name  = "Austina",
    Title = "Universal",
    Desc  = "Universal",
})

UILibrary.SetConfigFolder("Austina/Configs")

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

local LocalPlayerPage = Window.CreatePage({ Page_Name = "LocalPlayer", Page_Title = "LocalPlayer" })
local VisualPage      = Window.CreatePage({ Page_Name = "Visual",      Page_Title = "Visual" })
local InfoPage        = Window.CreatePage({ Page_Name = "Info",        Page_Title = "Info" })
local SettingsPage    = Window.CreatePage({ Page_Name = "Settings",    Page_Title = "Settings" })

-- LocalPlayer

local LocalState = {
    WalkSpeedEnabled = false,
    WalkSpeed = 32,
    JumpPowerEnabled = false,
    JumpPower = 75,
    InfiniteJump = false,
    Noclip = false,
}

local humanoidDefaults = setmetatable({}, { __mode = "k" })
local collisionDefaults = setmetatable({}, { __mode = "k" })

local function getHumanoid()
    local character = LocalPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function rememberHumanoid(humanoid)
    if not humanoid or humanoidDefaults[humanoid] then
        return
    end

    local defaults = {
        WalkSpeed = humanoid.WalkSpeed,
        JumpPower = humanoid.JumpPower,
        JumpHeight = humanoid.JumpHeight,
    }
    pcall(function()
        defaults.UseJumpPower = humanoid.UseJumpPower
    end)
    humanoidDefaults[humanoid] = defaults
end

local function restoreWalkSpeed()
    local humanoid = getHumanoid()
    local defaults = humanoid and humanoidDefaults[humanoid]
    if humanoid and defaults then
        humanoid.WalkSpeed = defaults.WalkSpeed
    end
end

local function restoreJumpPower()
    local humanoid = getHumanoid()
    local defaults = humanoid and humanoidDefaults[humanoid]
    if not humanoid or not defaults then
        return
    end

    humanoid.JumpPower = defaults.JumpPower
    humanoid.JumpHeight = defaults.JumpHeight
    if defaults.UseJumpPower ~= nil then
        pcall(function()
            humanoid.UseJumpPower = defaults.UseJumpPower
        end)
    end
end

local function restoreCollisions()
    for part, canCollide in pairs(collisionDefaults) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
        collisionDefaults[part] = nil
    end
end

local movementConnection = RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        rememberHumanoid(humanoid)
        if LocalState.WalkSpeedEnabled then
            humanoid.WalkSpeed = LocalState.WalkSpeed
        end
        if LocalState.JumpPowerEnabled then
            pcall(function()
                humanoid.UseJumpPower = true
            end)
            humanoid.JumpPower = LocalState.JumpPower
        end
    end

    if LocalState.Noclip and character then
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if collisionDefaults[descendant] == nil then
                    collisionDefaults[descendant] = descendant.CanCollide
                end
                descendant.CanCollide = false
            end
        end
    end
end)

local jumpConnection = UserInputService.JumpRequest:Connect(function()
    if not LocalState.InfiniteJump then
        return
    end

    local humanoid = getHumanoid()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local characterConnection = LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then
        rememberHumanoid(humanoid)
    end
end)

local Movement = LocalPlayerPage.CreateSection("Movement")

Movement.CreateToggle({
    Title   = "Walk Speed",
    Desc    = "Keep a custom movement speed",
    Default = false,
}, function(state)
    LocalState.WalkSpeedEnabled = state
    if not state then
        restoreWalkSpeed()
    end
end)

Movement.CreateSlider({
    Title   = "Walk Speed Value",
    Min     = 16,
    Max     = 100,
    Default = 32,
}, function(value)
    LocalState.WalkSpeed = math.floor(value + 0.5)
end)

Movement.CreateToggle({
    Title   = "Jump Power",
    Desc    = "Keep a custom jump strength",
    Default = false,
}, function(state)
    LocalState.JumpPowerEnabled = state
    if not state then
        restoreJumpPower()
    end
end)

Movement.CreateSlider({
    Title   = "Jump Power Value",
    Min     = 50,
    Max     = 150,
    Default = 75,
}, function(value)
    LocalState.JumpPower = math.floor(value + 0.5)
end)

local Character = LocalPlayerPage.CreateSection("Character")

Character.CreateToggle({
    Title   = "Infinite Jump",
    Desc    = "Jump again while airborne",
    Default = false,
}, function(state)
    LocalState.InfiniteJump = state
end)

Character.CreateToggle({
    Title   = "Noclip",
    Desc    = "Disable character collisions",
    Default = false,
}, function(state)
    LocalState.Noclip = state
    if not state then
        restoreCollisions()
    end
end)

-- Visual

local PlayerESP = VisualPage.CreateSection("Player ESP")

if ESP then
    ESP.Color = AccentSoft
    ESP:Toggle(false)

    PlayerESP.CreateToggle({
        Title   = "Enable ESP",
        Desc    = "Show selected overlays on players",
        Default = false,
    }, function(state)
        ESP:Toggle(state)
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Teammates",
        Default = true,
    }, function(state)
        ESP.TeamMates = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Tracers",
        Default = false,
    }, function(state)
        ESP.Tracers = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Names & Distance",
        Default = true,
    }, function(state)
        ESP.Names = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Boxes",
        Default = true,
    }, function(state)
        ESP.Boxes = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Team Color",
        Default = true,
    }, function(state)
        ESP.TeamColor = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Boxes Face Camera",
        Desc    = "Keep boxes facing your camera",
        Default = false,
    }, function(state)
        ESP.FaceCamera = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Attach Tracers To Crosshair",
        Default = false,
    }, function(state)
        ESP.AttachShift = state and 2 or 1
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Skeleton",
        Desc    = "Supports both R6 and R15 characters",
        Default = false,
    }, function(state)
        ESP.Skeletons = state
    end)

    PlayerESP.CreateSlider({
        Title   = "Line Thickness",
        Min     = 1,
        Max     = 5,
        Default = 2,
    }, function(value)
        ESP.Thickness = value
        for _, box in pairs(ESP.Objects) do
            if box.Components then
                pcall(function()
                    box.Components.Quad.Thickness = value
                    box.Components.Tracer.Thickness = value
                    for index = 1, 14 do
                        local line = box.Components["Skeleton" .. index]
                        if line then
                            line.Thickness = value
                        end
                    end
                end)
            end
        end
    end)
else
    PlayerESP.CreateLabel({
        Title = "ESP unavailable: " .. tostring(espError),
    })
end

local WorldVisuals = VisualPage.CreateSection("World Visuals")

local worldDefaults = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local atmosphereDefaults = setmetatable({}, { __mode = "k" })
local WorldState = {
    Brightness = math.clamp(worldDefaults.Brightness, 0, 10),
    BrightnessEnabled = false,
    ClockTime = worldDefaults.ClockTime,
    ClockTimeEnabled = false,
    CustomFog = false,
    FogEnd = math.clamp(worldDefaults.FogEnd, 0, 100000),
    FogStart = math.clamp(worldDefaults.FogStart, 0, 10000),
    Fullbright = false,
    RemoveFog = false,
    Running = true,
}

local function rememberAtmosphere(atmosphere)
    if atmosphereDefaults[atmosphere] then
        return
    end

    atmosphereDefaults[atmosphere] = {
        Density = atmosphere.Density,
        Haze = atmosphere.Haze,
    }
end

local function restoreAtmospheres()
    for atmosphere, defaults in pairs(atmosphereDefaults) do
        if atmosphere and atmosphere.Parent then
            atmosphere.Density = defaults.Density
            atmosphere.Haze = defaults.Haze
        end
    end
end

local function restoreWorldVisuals()
    Lighting.Ambient = worldDefaults.Ambient
    Lighting.Brightness = worldDefaults.Brightness
    Lighting.ClockTime = worldDefaults.ClockTime
    Lighting.FogEnd = worldDefaults.FogEnd
    Lighting.FogStart = worldDefaults.FogStart
    Lighting.GlobalShadows = worldDefaults.GlobalShadows
    Lighting.OutdoorAmbient = worldDefaults.OutdoorAmbient
    restoreAtmospheres()
end

local function applyWorldVisuals()
    if WorldState.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        if not WorldState.BrightnessEnabled then
            Lighting.Brightness = 3
        end
    end

    if WorldState.BrightnessEnabled then
        Lighting.Brightness = WorldState.Brightness
    end

    if WorldState.ClockTimeEnabled then
        Lighting.ClockTime = WorldState.ClockTime
    end

    if WorldState.RemoveFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000000
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") then
                rememberAtmosphere(child)
                child.Density = 0
                child.Haze = 0
            end
        end
    elseif WorldState.CustomFog then
        Lighting.FogStart = math.min(WorldState.FogStart, WorldState.FogEnd)
        Lighting.FogEnd = math.max(WorldState.FogStart, WorldState.FogEnd)
    end
end

local worldConnection = RunService.RenderStepped:Connect(function()
    if WorldState.Running then
        applyWorldVisuals()
    end
end)

WorldVisuals.CreateToggle({
    Title   = "Fullbright",
    Desc    = "Lift ambient light and disable shadows",
    Default = false,
}, function(state)
    WorldState.Fullbright = state
    if not state then
        Lighting.Ambient = worldDefaults.Ambient
        Lighting.OutdoorAmbient = worldDefaults.OutdoorAmbient
        Lighting.GlobalShadows = worldDefaults.GlobalShadows
        if not WorldState.BrightnessEnabled then
            Lighting.Brightness = worldDefaults.Brightness
        end
    end
end)

WorldVisuals.CreateToggle({
    Title   = "Override Brightness",
    Default = false,
}, function(state)
    WorldState.BrightnessEnabled = state
    if not state and not WorldState.Fullbright then
        Lighting.Brightness = worldDefaults.Brightness
    end
end)

WorldVisuals.CreateSlider({
    Title   = "Brightness",
    Min     = 0,
    Max     = 10,
    Default = WorldState.Brightness,
    Precise = true,
}, function(value)
    WorldState.Brightness = value
end)

WorldVisuals.CreateToggle({
    Title   = "Override Time",
    Default = false,
}, function(state)
    WorldState.ClockTimeEnabled = state
    if not state then
        Lighting.ClockTime = worldDefaults.ClockTime
    end
end)

WorldVisuals.CreateSlider({
    Title   = "Clock Time",
    Min     = 0,
    Max     = 24,
    Default = worldDefaults.ClockTime,
    Precise = true,
}, function(value)
    WorldState.ClockTime = value
end)

WorldVisuals.CreateToggle({
    Title   = "Remove Fog",
    Desc    = "Also suppresses Atmosphere haze",
    Default = false,
}, function(state)
    WorldState.RemoveFog = state
    if not state then
        Lighting.FogStart = worldDefaults.FogStart
        Lighting.FogEnd = worldDefaults.FogEnd
        restoreAtmospheres()
    end
end)

WorldVisuals.CreateToggle({
    Title   = "Custom Fog Distance",
    Default = false,
}, function(state)
    WorldState.CustomFog = state
    if not state and not WorldState.RemoveFog then
        Lighting.FogStart = worldDefaults.FogStart
        Lighting.FogEnd = worldDefaults.FogEnd
    end
end)

WorldVisuals.CreateSlider({
    Title   = "Fog Start",
    Min     = 0,
    Max     = 10000,
    Default = WorldState.FogStart,
}, function(value)
    WorldState.FogStart = value
end)

WorldVisuals.CreateSlider({
    Title   = "Fog End",
    Min     = 0,
    Max     = 100000,
    Default = WorldState.FogEnd,
}, function(value)
    WorldState.FogEnd = value
end)

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
local fpsConnection

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
    if movementConnection then movementConnection:Disconnect() end
    if jumpConnection then jumpConnection:Disconnect() end
    if characterConnection then characterConnection:Disconnect() end
    if fpsConnection then fpsConnection:Disconnect() end
    if worldConnection then worldConnection:Disconnect() end

    LocalState.WalkSpeedEnabled = false
    LocalState.JumpPowerEnabled = false
    LocalState.InfiniteJump = false
    LocalState.Noclip = false
    restoreWalkSpeed()
    restoreJumpPower()
    restoreCollisions()
    WorldState.Running = false
    restoreWorldVisuals()

    if ESP then
        pcall(ESP.Toggle, ESP, false)
        for _, box in pairs(ESP.Objects) do
            if box.Remove then
                pcall(box.Remove, box)
            end
        end
    end

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

About.CreateLabel({ Title = "Austina  v0.1a" })
About.CreateLabel({ Title = "Game: " .. GameName })
About.CreateLabel({ Title = "Place Id: " .. tostring(game.PlaceId) })
About.CreateLabel({ Title = "Executor: " .. tostring(executorName) })
About.CreateLabel({ Title = "UI Library: SeaUI " .. tostring(UILibrary.VERSION or "?") })

-- live server readout

local startedAt = os.time()
local frames, frameClock, fps = 0, os.clock(), 0

fpsConnection = RunService.RenderStepped:Connect(function()
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

notify("Loaded", "Universal", 4)
