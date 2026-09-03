-- Austina cinematic loader module.
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/austina/main/loader.lua"))().Start()

local Loader = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local BASE_URL = "https://raw.githubusercontent.com/Ic0u/austina/main/"
local GUI_NAME = "AustinaLoaderGui"
local BLUR_NAME = "AustinaLoaderBlur"
local DEFAULT_GAMES = {}

local function tween(instance, duration, properties, style, direction)
    local animation = TweenService:Create(
        instance,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function getPlayerGui()
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    return player:WaitForChild("PlayerGui")
end

local function getGuiParent()
    local ok, coreGui = pcall(game.GetService, game, "CoreGui")
    if ok and coreGui then
        return coreGui
    end

    return getPlayerGui()
end

local function parentGui(screenGui)
    local preferredParent = getGuiParent()
    local didParent = pcall(function()
        screenGui.Parent = preferredParent
    end)

    if not didParent then
        screenGui.Parent = getPlayerGui()
    end
end

local function destroyExisting()
    local coreGui
    local coreGuiOk = pcall(function()
        coreGui = game:GetService("CoreGui")
    end)

    if coreGuiOk and coreGui then
        local existing = coreGui:FindFirstChild(GUI_NAME)
        if existing then
            existing:Destroy()
        end
    end

    local playerGui = getPlayerGui()
    local existing = playerGui:FindFirstChild(GUI_NAME)
    if existing then
        existing:Destroy()
    end

    local oldBlur = Lighting:FindFirstChild(BLUR_NAME)
    if oldBlur then
        oldBlur:Destroy()
    end
end

local function makeEdge(parent, size, position, rotation)
    local edge = Instance.new("Frame")
    edge.BackgroundColor3 = Color3.fromRGB(192, 192, 198)
    edge.BorderSizePixel = 0
    edge.Position = position
    edge.Size = size
    edge.Parent = parent

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0.35),
    })
    gradient.Parent = edge
end

local function createBackdrop(parent)
    local backdrop = Instance.new("CanvasGroup")
    backdrop.Name = "Backdrop"
    backdrop.GroupTransparency = 1
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.Parent = parent

    local base = Instance.new("Frame")
    base.Name = "DiffuseVignette"
    base.BackgroundColor3 = Color3.fromRGB(236, 236, 240)
    base.BorderSizePixel = 0
    base.Size = UDim2.fromScale(1, 1)
    base.Parent = backdrop

    -- UIGradient is linear in Roblox. Edge layers complete the radial-vignette illusion.
    local centerGradient = Instance.new("UIGradient")
    centerGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(214, 214, 220)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(214, 214, 220)),
    })
    centerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.72),
        NumberSequenceKeypoint.new(0.5, 0.94),
        NumberSequenceKeypoint.new(1, 0.72),
    })
    centerGradient.Parent = base

    makeEdge(backdrop, UDim2.fromScale(1, 0.24), UDim2.fromScale(0, 0), 90)
    makeEdge(backdrop, UDim2.fromScale(1, 0.24), UDim2.fromScale(0, 0.76), 270)
    makeEdge(backdrop, UDim2.fromScale(0.24, 1), UDim2.fromScale(0, 0), 0)
    makeEdge(backdrop, UDim2.fromScale(0.24, 1), UDim2.fromScale(0.76, 0), 180)

    return backdrop
end

local function createLoaderContent(parent)
    local group = Instance.new("CanvasGroup")
    group.Name = "LoaderContentGroup"
    group.GroupTransparency = 1
    group.Size = UDim2.fromScale(1, 1)
    group.Parent = parent

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromScale(0.5, 0.48)
    title.Size = UDim2.fromOffset(420, 42)
    title.Font = Enum.Font.GothamMedium
    title.Text = ""
    title.TextColor3 = Color3.fromRGB(250, 243, 246)
    title.TextSize = 28
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = group

    local titleScale = Instance.new("UIScale")
    titleScale.Scale = 0.94
    titleScale.Parent = title

    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.AnchorPoint = Vector2.new(0.5, 0.5)
    progressTrack.BackgroundColor3 = Color3.fromRGB(238, 237, 241)
    progressTrack.BackgroundTransparency = 1
    progressTrack.BorderSizePixel = 0
    progressTrack.Position = UDim2.fromScale(0.5, 0.565)
    progressTrack.Size = UDim2.fromOffset(230, 3)
    progressTrack.Parent = group

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = progressTrack

    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.BackgroundColor3 = Color3.fromRGB(232, 151, 177)
    progressFill.BackgroundTransparency = 1
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.Parent = progressTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromScale(0.5, 0.595)
    status.Size = UDim2.fromOffset(280, 18)
    status.Font = Enum.Font.Gotham
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(246, 242, 244)
    status.TextSize = 12
    status.TextTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = group

    return group, titleScale, title, status, progressTrack, progressFill
end

local function fetchGameRegistry()
    local ok, response = pcall(game.HttpGet, game, BASE_URL .. "games.json")
    if not ok or response == "" then
        return DEFAULT_GAMES
    end

    local decodedOk, registry = pcall(HttpService.JSONDecode, HttpService, response)
    if decodedOk and type(registry) == "table" then
        return registry
    end

    return DEFAULT_GAMES
end

local function runSource(url)
    local fetched, source = pcall(game.HttpGet, game, url)
    if not fetched or type(source) ~= "string" or source == "" then
        return false
    end

    local compiled = loadstring(source)
    if not compiled then
        return false
    end

    return pcall(compiled)
end

local function launchDefaultScript()
    local supportedGames = fetchGameRegistry()
    local placeId = tostring(game.PlaceId)
    local path = supportedGames[placeId] and ("games/" .. placeId .. ".lua") or "scripts/Universal.lua"
    runSource(BASE_URL .. path)
end

function Loader.Start(onComplete)
    if Loader._running then
        return nil
    end
    Loader._running = true

    destroyExisting()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = GUI_NAME
    screenGui.DisplayOrder = 99999
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    parentGui(screenGui)

    local blur = Instance.new("BlurEffect")
    blur.Name = BLUR_NAME
    blur.Size = 0
    blur.Parent = Lighting

    local backdrop = createBackdrop(screenGui)
    local contentGroup, titleScale, title, status, progressTrack, progressFill = createLoaderContent(screenGui)

    task.spawn(function()
        local backdropIn = tween(backdrop, 0.4, { GroupTransparency = 0 })
        tween(blur, 0.4, { Size = 20 })
        backdropIn.Completed:Wait()

        local titleFade = tween(contentGroup, 0.18, { GroupTransparency = 0 })
        tween(titleScale, 0.32, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        titleFade.Completed:Wait()

        local letters = { "A", "U", "S", "T", "I", "N", "A" }
        local revealed = {}
        for _, letter in ipairs(letters) do
            table.insert(revealed, letter)
            title.Text = table.concat(revealed, " ")
            task.wait(0.045)
        end

        local uiFade = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(progressTrack, uiFade, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(progressFill, uiFade, { BackgroundTransparency = 0 }):Play()
        task.wait(0.1)
        TweenService:Create(status, uiFade, { TextTransparency = 0 }):Play()
        task.wait(0.25)

        local function setProgress(message, percent, holdTime)
            local hideStatus = tween(status, 0.12, { TextTransparency = 1 })
            hideStatus.Completed:Wait()
            status.Text = message
            tween(status, 0.18, { TextTransparency = 0 })
            tween(progressFill, 0.55, { Size = UDim2.fromScale(percent, 1) })
            task.wait(holdTime)
        end

        setProgress("Checking Whitelist...", 0.35, 0.7)
        setProgress("Bypassing Integrity...", 0.65, 0.7)
        setProgress("Loading Assets...", 0.80, 0.65)
        setProgress("Initialization complete.", 1, 0.45)

        local outro = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local groupOut = TweenService:Create(contentGroup, outro, { GroupTransparency = 1 })
        local scaleOut = TweenService:Create(titleScale, outro, { Scale = 0.94 })

        groupOut:Play()
        scaleOut:Play()
        tween(backdrop, 0.3, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(blur, 0.3, { Size = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        groupOut.Completed:Wait()

        if blur.Parent then
            blur:Destroy()
        end
        if screenGui.Parent then
            screenGui:Destroy()
        end

        Loader._running = false
        local callback = onComplete or launchDefaultScript
        task.spawn(function()
            local ok, err = pcall(callback)
            if not ok then
                warn("Austina loader callback failed:", err)
            end
        end)
    end)

    return screenGui
end

return Loader
