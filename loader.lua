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

local function createLoaderCard(parent)
    local group = Instance.new("CanvasGroup")
    group.Name = "LoaderCardGroup"
    group.AnchorPoint = Vector2.new(0.5, 0.5)
    group.GroupTransparency = 1
    group.Position = UDim2.fromScale(0.5, 0.5)
    group.Size = UDim2.fromOffset(300, 115)
    group.Parent = parent

    local scale = Instance.new("UIScale")
    scale.Scale = 0.85
    scale.Parent = group

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    card.BorderSizePixel = 0
    card.Size = UDim2.fromScale(1, 1)
    card.Parent = group

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(40, 40, 45)
    stroke.Thickness = 1
    stroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(24, 19)
    title.Size = UDim2.fromOffset(252, 19)
    title.Font = Enum.Font.Code
    title.Text = ""
    title.TextColor3 = Color3.fromRGB(238, 238, 241)
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(24, 55)
    status.Size = UDim2.fromOffset(252, 14)
    status.Font = Enum.Font.Code
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(158, 158, 166)
    status.TextSize = 12
    status.TextTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = card

    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
    progressTrack.BackgroundTransparency = 1
    progressTrack.BorderSizePixel = 0
    progressTrack.Position = UDim2.fromOffset(24, 82)
    progressTrack.Size = UDim2.fromOffset(252, 4)
    progressTrack.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = progressTrack

    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.BackgroundColor3 = Color3.fromRGB(226, 226, 231)
    progressFill.BackgroundTransparency = 1
    progressFill.BorderSizePixel = 0
    progressFill.Size = UDim2.fromScale(0, 1)
    progressFill.Parent = progressTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill

    return group, scale, title, status, progressTrack, progressFill
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
    local cardGroup, cardScale, title, status, progressTrack, progressFill = createLoaderCard(screenGui)

    task.spawn(function()
        local introInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        local groupFade = TweenService:Create(cardGroup, introInfo, { GroupTransparency = 0 })
        local cardPop = TweenService:Create(cardScale, introInfo, { Scale = 1 })

        groupFade:Play()
        cardPop:Play()
        tween(backdrop, 0.35, { GroupTransparency = 0 })
        tween(blur, 0.35, { Size = 20 })
        groupFade.Completed:Wait()

        local letters = { "A", "U", "S", "T", "I", "N", "A" }
        local revealed = {}
        for _, letter in ipairs(letters) do
            table.insert(revealed, letter)
            title.Text = table.concat(revealed, " ")
            task.wait(0.045)
        end

        local uiFade = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(status, uiFade, { TextTransparency = 0 }):Play()
        TweenService:Create(progressTrack, uiFade, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(progressFill, uiFade, { BackgroundTransparency = 0 }):Play()
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
        local groupOut = TweenService:Create(cardGroup, outro, { GroupTransparency = 1 })
        local scaleOut = TweenService:Create(cardScale, outro, { Scale = 0.9 })

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
