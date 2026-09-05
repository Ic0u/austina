-- Vinsers Hub

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
    error("Vinsers Hub UI library failed: " .. tostring(uiError))
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
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer or Players.PlayerAdded:Wait()

local GameName = "Roblox"
pcall(function()
    local productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    if type(productInfo) == "table" and type(productInfo.Name) == "string" and productInfo.Name ~= "" then
        GameName = productInfo.Name
    end
end)

local MenuKey = Enum.KeyCode.RightControl

local Window = UILibrary.CreateMain({
    Name  = "Vinsers Hub",
    Title = GameName,
    Desc  = "",
})

UILibrary.SetConfigFolder("Vinsers Hub/Configs")

-- the library already prefixes every notification with the hub name,
-- so Title here is the subject only
local function notify(title, desc, time)
    UILibrary.CreateNoti({ Title = title, Desc = desc, ShowTime = time or 4 })
end

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
    Fly = false,
    FlySpeed = 50,
    GravityEnabled = false,
    Gravity = Workspace.Gravity,
}

local humanoidDefaults = setmetatable({}, { __mode = "k" })
local collisionDefaults = setmetatable({}, { __mode = "k" })
local gravityDefault = Workspace.Gravity

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
        AutoRotate = humanoid.AutoRotate,
        PlatformStand = humanoid.PlatformStand,
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

local function stopFly()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        local velocity = root:FindFirstChild("VinsersHubFlyVelocity")
        local gyro = root:FindFirstChild("VinsersHubFlyGyro")
        if velocity then velocity:Destroy() end
        if gyro then gyro:Destroy() end
    end

    local defaults = humanoid and humanoidDefaults[humanoid]
    if humanoid and defaults then
        humanoid.AutoRotate = defaults.AutoRotate
        humanoid.PlatformStand = defaults.PlatformStand
    end
end

local function updateFly(character, humanoid)
    local root = character:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    if not root or not camera then
        return
    end

    local velocity = root:FindFirstChild("VinsersHubFlyVelocity")
    if not velocity then
        velocity = Instance.new("BodyVelocity")
        velocity.Name = "VinsersHubFlyVelocity"
        velocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
        velocity.P = 1250
        velocity.Parent = root
    end

    local gyro = root:FindFirstChild("VinsersHubFlyGyro")
    if not gyro then
        gyro = Instance.new("BodyGyro")
        gyro.Name = "VinsersHubFlyGyro"
        gyro.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
        gyro.P = 3000
        gyro.D = 100
        gyro.Parent = root
    end

    humanoid.AutoRotate = false
    humanoid.PlatformStand = true

    local look = camera.CFrame.LookVector
    local right = camera.CFrame.RightVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    local flatRight = Vector3.new(right.X, 0, right.Z)
    local keyboardDirection = Vector3.new()

    if flatLook.Magnitude > 0.001 and flatRight.Magnitude > 0.001 then
        flatLook = flatLook.Unit
        flatRight = flatRight.Unit
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then keyboardDirection = keyboardDirection + flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then keyboardDirection = keyboardDirection - flatLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then keyboardDirection = keyboardDirection + flatRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then keyboardDirection = keyboardDirection - flatRight end
    end

    local moveDirection = keyboardDirection.Magnitude > 0.001
        and keyboardDirection.Unit
        or humanoid.MoveDirection
    local vertical = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        vertical = vertical + 1
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        vertical = vertical - 1
    end

    velocity.Velocity = moveDirection * LocalState.FlySpeed
        + Vector3.new(0, vertical * LocalState.FlySpeed, 0)

    if flatLook.Magnitude > 0.001 then
        gyro.CFrame = CFrame.new(root.Position, root.Position + flatLook.Unit)
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
        if LocalState.Fly then
            updateFly(character, humanoid)
        end
    end

    if LocalState.GravityEnabled then
        Workspace.Gravity = LocalState.Gravity
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

Movement.CreateToggle({
    Title   = "Gravity Override",
    Desc    = "Keep a custom world gravity on this client",
    Default = false,
}, function(state)
    LocalState.GravityEnabled = state
    if not state then
        Workspace.Gravity = gravityDefault
    end
end)

Movement.CreateSlider({
    Title   = "Gravity",
    Min     = 0,
    Max     = 500,
    Default = math.clamp(gravityDefault, 0, 500),
    Precise = true,
}, function(value)
    LocalState.Gravity = value
end)

Movement.CreateToggle({
    Title   = "Fly",
    Desc    = "Move normally; Space rises and Ctrl or Q descends",
    Default = false,
}, function(state)
    LocalState.Fly = state
    if not state then
        stopFly()
    end
end)

Movement.CreateSlider({
    Title   = "Fly Speed",
    Min     = 10,
    Max     = 250,
    Default = 50,
}, function(value)
    LocalState.FlySpeed = value
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
    ESP.Color = getgenv().UIColor["Title Text Color"]
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
        Title   = "Show Names",
        Default = true,
    }, function(state)
        ESP.Names = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Distance",
        Desc    = "Show [distance] studs below the feet",
        Default = true,
    }, function(state)
        ESP.Distances = state
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
        Title   = "Show Chams",
        Desc    = "Use Roblox Highlight on player characters",
        Default = false,
    }, function(state)
        ESP.Chams = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Chams Through Walls",
        Default = true,
    }, function(state)
        ESP.ChamsAlwaysOnTop = state
    end)

    PlayerESP.CreateSlider({
        Title   = "Chams Fill Transparency",
        Min     = 0,
        Max     = 1,
        Default = 0.65,
        Precise = true,
    }, function(value)
        ESP.ChamsFillTransparency = value
    end)

    PlayerESP.CreateSlider({
        Title   = "Chams Outline Transparency",
        Min     = 0,
        Max     = 1,
        Default = 0,
        Precise = true,
    }, function(value)
        ESP.ChamsOutlineTransparency = value
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

    PlayerESP.CreateToggle({
        Title   = "Show Health Bar",
        Desc    = "Draw health vertically beside the player",
        Default = false,
    }, function(state)
        ESP.HealthBars = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Health Value",
        Desc    = "Show the exact number at the lower-left side",
        Default = false,
    }, function(state)
        ESP.HealthValues = state
    end)

    PlayerESP.CreateToggle({
        Title   = "Show Equipped Tool",
        Desc    = "Show the tool below the feet, or None",
        Default = false,
    }, function(state)
        ESP.Tools = state
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
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ShadowSoftness = Lighting.ShadowSoftness,
}

pcall(function()
    worldDefaults.Technology = Lighting.Technology
end)

local atmosphereDefaults = setmetatable({}, { __mode = "k" })
local WorldState = {
    AdjustLighting = false,
    Ambient = worldDefaults.Ambient,
    Brightness = math.clamp(worldDefaults.Brightness, 0, 10),
    ClockTime = worldDefaults.ClockTime,
    CustomFog = false,
    EnvironmentDiffuseScale = worldDefaults.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = worldDefaults.EnvironmentSpecularScale,
    FogColor = worldDefaults.FogColor,
    FogEnd = math.clamp(worldDefaults.FogEnd, 0, 100000),
    FogStart = math.clamp(worldDefaults.FogStart, 0, 10000),
    Fullbright = false,
    OutdoorAmbient = worldDefaults.OutdoorAmbient,
    RemoveFog = false,
    Running = true,
    ShadowSoftness = worldDefaults.ShadowSoftness,
    Technology = worldDefaults.Technology,
}

local function colorToHex(color)
    return string.format(
        "%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

local function parseHexColor(text)
    local hex = tostring(text):gsub("#", ""):gsub("%s", "")
    if #hex ~= 6 or not hex:match("^[%x]+$") then
        return nil
    end

    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

local function technologyName(technology)
    return tostring(technology):match("([%w_]+)$") or "Unknown"
end

local technologyNames = {}
for _, technology in ipairs(Enum.Technology:GetEnumItems()) do
    table.insert(technologyNames, technology.Name)
end

local function setTechnology(name)
    local technology = Enum.Technology[name]
    if not technology then
        return false
    end

    WorldState.Technology = technology
    if not WorldState.AdjustLighting then
        return true
    end

    return pcall(function()
        Lighting.Technology = technology
    end)
end

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
    Lighting.EnvironmentDiffuseScale = worldDefaults.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = worldDefaults.EnvironmentSpecularScale
    Lighting.FogColor = worldDefaults.FogColor
    Lighting.FogEnd = worldDefaults.FogEnd
    Lighting.FogStart = worldDefaults.FogStart
    Lighting.GlobalShadows = worldDefaults.GlobalShadows
    Lighting.OutdoorAmbient = worldDefaults.OutdoorAmbient
    Lighting.ShadowSoftness = worldDefaults.ShadowSoftness
    if worldDefaults.Technology then
        pcall(function()
            Lighting.Technology = worldDefaults.Technology
        end)
    end
    restoreAtmospheres()
end

local function applyWorldVisuals()
    if WorldState.AdjustLighting then
        Lighting.Ambient = WorldState.Ambient
        Lighting.Brightness = WorldState.Brightness
        Lighting.ClockTime = WorldState.ClockTime
        Lighting.EnvironmentDiffuseScale = WorldState.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = WorldState.EnvironmentSpecularScale
        Lighting.FogColor = WorldState.FogColor
        Lighting.OutdoorAmbient = WorldState.OutdoorAmbient
        Lighting.ShadowSoftness = WorldState.ShadowSoftness
    end

    if WorldState.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        Lighting.Brightness = math.max(WorldState.Brightness, 3)
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
    Title   = "Adjust Lighting",
    Desc    = "Continuously apply the properties below",
    Default = false,
}, function(state)
    WorldState.AdjustLighting = state
    if state then
        if not setTechnology(technologyName(WorldState.Technology)) then
            notify("Lighting", "Technology is locked by this client.")
        end
        applyWorldVisuals()
    else
        restoreWorldVisuals()
    end
end)

WorldVisuals.CreateButton({ Title = "Get Technology" }, function()
    local current = "Unavailable"
    pcall(function()
        current = technologyName(Lighting.Technology)
    end)
    notify("Lighting", "Technology: " .. current)
end)

WorldVisuals.CreateDropdown({
    Title   = "Technology",
    List    = technologyNames,
    Default = worldDefaults.Technology and technologyName(worldDefaults.Technology) or technologyNames[1],
}, function(value)
    if not setTechnology(value) and WorldState.AdjustLighting then
        notify("Lighting", "Technology is locked by this client.")
    end
end)

WorldVisuals.CreateBox({
    Title       = "Ambient",
    Placeholder = "RRGGBB",
    Default     = colorToHex(WorldState.Ambient),
}, function(text)
    local color = parseHexColor(text)
    if color then
        WorldState.Ambient = color
    else
        notify("Lighting", "Ambient needs a 6-digit hex color.")
    end
end)

WorldVisuals.CreateBox({
    Title       = "Outdoor Ambient",
    Placeholder = "RRGGBB",
    Default     = colorToHex(WorldState.OutdoorAmbient),
}, function(text)
    local color = parseHexColor(text)
    if color then
        WorldState.OutdoorAmbient = color
    else
        notify("Lighting", "Outdoor Ambient needs a 6-digit hex color.")
    end
end)

WorldVisuals.CreateSlider({
    Title   = "Clock Time",
    Min     = 0,
    Max     = 24,
    Default = WorldState.ClockTime,
    Precise = true,
}, function(value)
    WorldState.ClockTime = value
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

WorldVisuals.CreateSlider({
    Title   = "Shadow Softness",
    Min     = 0,
    Max     = 1,
    Default = WorldState.ShadowSoftness,
    Precise = true,
}, function(value)
    WorldState.ShadowSoftness = value
end)

WorldVisuals.CreateSlider({
    Title   = "Diffuse Scale",
    Min     = 0,
    Max     = 1,
    Default = WorldState.EnvironmentDiffuseScale,
    Precise = true,
}, function(value)
    WorldState.EnvironmentDiffuseScale = value
end)

WorldVisuals.CreateSlider({
    Title   = "Specular Scale",
    Min     = 0,
    Max     = 1,
    Default = WorldState.EnvironmentSpecularScale,
    Precise = true,
}, function(value)
    WorldState.EnvironmentSpecularScale = value
end)

WorldVisuals.CreateBox({
    Title       = "Fog Color",
    Placeholder = "RRGGBB",
    Default     = colorToHex(WorldState.FogColor),
}, function(text)
    local color = parseHexColor(text)
    if color then
        WorldState.FogColor = color
    else
        notify("Lighting", "Fog Color needs a 6-digit hex color.")
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
        Lighting.Brightness = worldDefaults.Brightness
    end
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
    LocalState.Fly = false
    LocalState.GravityEnabled = false
    restoreWalkSpeed()
    restoreJumpPower()
    restoreCollisions()
    stopFly()
    Workspace.Gravity = gravityDefault
    WorldState.Running = false
    restoreWorldVisuals()

    if ESP then
        if ESP.Destroy then
            pcall(ESP.Destroy, ESP)
        else
            pcall(ESP.Toggle, ESP, false)
            for _, box in pairs(ESP.Objects) do
                if box.Remove then
                    pcall(box.Remove, box)
                end
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

About.CreateLabel({ Title = "Vinsers Hub  v0.1a" })
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
