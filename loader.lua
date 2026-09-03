-- Austina cinematic loader module.
-- Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/austina/main/loader.lua"))().Start()

local Loader = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

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

local function createWhiteVignette(parent)
    local layer = Instance.new("Frame")
    layer.Name = "WhiteVignette"
    layer.BackgroundTransparency = 1
    layer.BorderSizePixel = 0
    layer.Size = UDim2.fromScale(1, 1)
    layer.Parent = parent

    local edges = {}
    local edgeDefinitions = {
        { "Top", UDim2.fromScale(1, 0.28), UDim2.fromScale(0, 0), 90 },
        { "Bottom", UDim2.fromScale(1, 0.28), UDim2.fromScale(0, 0.72), 270 },
        { "Left", UDim2.fromScale(0.28, 1), UDim2.fromScale(0, 0), 0 },
        { "Right", UDim2.fromScale(0.28, 1), UDim2.fromScale(0.72, 0), 180 },
    }

    for _, definition in ipairs(edgeDefinitions) do
        local edge = Instance.new("Frame")
        edge.Name = definition[1]
        edge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        edge.BackgroundTransparency = 1
        edge.BorderSizePixel = 0
        edge.Size = definition[2]
        edge.Position = definition[3]
        edge.Parent = layer

        local gradient = Instance.new("UIGradient")
        gradient.Rotation = definition[4]
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.62, 0.72),
            NumberSequenceKeypoint.new(1, 1),
        })
        gradient.Parent = edge

        table.insert(edges, edge)
    end

    return edges
end

local function tweenVignette(edges, transparency, duration, direction)
    local firstTween
    for index, edge in ipairs(edges) do
        local edgeTween = tween(
            edge,
            duration,
            { BackgroundTransparency = transparency },
            Enum.EasingStyle.Quint,
            direction
        )
        if index == 1 then
            firstTween = edgeTween
        end
    end

    return firstTween
end

local function bindResponsiveScale(uiScale)
    local viewportConnection

    local function updateScale()
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end

        local viewport = camera.ViewportSize
        local scale = math.min(viewport.X / 1280, viewport.Y / 720)
        scale = math.clamp(scale, 0.72, 1.65)
        uiScale.Scale = math.floor(scale * 20 + 0.5) / 20
    end

    local function bindCamera()
        if viewportConnection then
            viewportConnection:Disconnect()
            viewportConnection = nil
        end

        local camera = Workspace.CurrentCamera
        if camera then
            viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        end
        updateScale()
    end

    local cameraConnection = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
    bindCamera()

    return function()
        cameraConnection:Disconnect()
        if viewportConnection then
            viewportConnection:Disconnect()
        end
    end
end

local function createLoaderContent(parent)
    local group = Instance.new("Frame")
    group.Name = "LoaderContent"
    group.BackgroundTransparency = 1
    group.Size = UDim2.fromScale(1, 1)
    group.Parent = parent

    local container = Instance.new("Frame")
    container.Name = "CenteredContent"
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromOffset(420, 180)
    container.Parent = group

    local responsiveScale = Instance.new("UIScale")
    responsiveScale.Scale = 1
    responsiveScale.Parent = container

    local title = Instance.new("Frame")
    title.Name = "Title"
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromScale(0.5, 0.3)
    title.Size = UDim2.fromOffset(286, 48)
    title.Parent = container

    local titleScale = Instance.new("UIScale")
    titleScale.Scale = 1
    titleScale.Parent = title

    local titleLayout = Instance.new("UIListLayout")
    titleLayout.FillDirection = Enum.FillDirection.Horizontal
    titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    titleLayout.Padding = UDim.new(0, 7)
    titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    titleLayout.Parent = title

    local letterViews = {}
    local letterRotations = { -7, 4, -3, 5, -4, 3, -5 }
    for index, character in ipairs({ "A", "U", "S", "T", "I", "N", "A" }) do
        local slot = Instance.new("Frame")
        slot.Name = "LetterSlot" .. index
        slot.BackgroundTransparency = 1
        slot.LayoutOrder = index
        slot.Size = UDim2.fromOffset(32, 48)
        slot.Parent = title

        local letter = Instance.new("TextLabel")
        letter.Name = "Letter" .. index
        letter.BackgroundTransparency = 1
        letter.Font = Enum.Font.FredokaOne
        letter.Position = UDim2.fromOffset(0, 18)
        letter.Rotation = letterRotations[index]
        letter.Size = UDim2.fromScale(1, 1)
        letter.Text = character
        letter.TextColor3 = Color3.fromRGB(230, 255, 237)
        letter.TextSize = 32
        letter.TextTransparency = 1
        letter.Parent = slot

        local letterStroke = Instance.new("UIStroke")
        letterStroke.Color = Color3.fromRGB(70, 157, 101)
        letterStroke.Thickness = 1
        letterStroke.Transparency = 1
        letterStroke.Parent = letter

        local letterGradient = Instance.new("UIGradient")
        letterGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 214, 143)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(232, 255, 237)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(87, 180, 116)),
        })
        letterGradient.Rotation = 90
        letterGradient.Parent = letter

        local letterScale = Instance.new("UIScale")
        letterScale.Scale = 0.72
        letterScale.Parent = letter

        table.insert(letterViews, {
            Label = letter,
            Scale = letterScale,
            Stroke = letterStroke,
        })
    end

    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.AnchorPoint = Vector2.new(0.5, 0.5)
    progressTrack.BackgroundColor3 = Color3.fromRGB(238, 237, 241)
    progressTrack.BackgroundTransparency = 1
    progressTrack.BorderSizePixel = 0
    progressTrack.Position = UDim2.fromScale(0.5, 0.68)
    progressTrack.Size = UDim2.fromOffset(230, 3)
    progressTrack.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = progressTrack

    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.BackgroundColor3 = Color3.fromRGB(112, 211, 141)
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
    status.Position = UDim2.fromScale(0.5, 0.83)
    status.Size = UDim2.fromOffset(280, 18)
    status.Font = Enum.Font.PatrickHand
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(246, 242, 244)
    status.TextSize = 16
    status.TextTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = container

    return responsiveScale, titleScale, letterViews, status, progressTrack, progressFill
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

    local vignetteEdges = createWhiteVignette(screenGui)
    local responsiveScale, titleScale, letterViews, status, progressTrack, progressFill = createLoaderContent(screenGui)
    local disconnectResponsiveScale = bindResponsiveScale(responsiveScale)

    task.spawn(function()
        tweenVignette(vignetteEdges, 0.78, 0.45, Enum.EasingDirection.Out)
        local blurIn = tween(blur, 0.45, { Size = 20 })
        blurIn.Completed:Wait()

        local lastLetterTween
        for _, view in ipairs(letterViews) do
            lastLetterTween = tween(
                view.Label,
                0.42,
                {
                    Position = UDim2.fromOffset(0, 0),
                    Rotation = 0,
                    TextTransparency = 0,
                },
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
            tween(
                view.Scale,
                0.42,
                { Scale = 1 },
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
            tween(
                view.Stroke,
                0.3,
                { Transparency = 0.12 },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            task.wait(0.065)
        end

        if lastLetterTween then
            lastLetterTween.Completed:Wait()
        end

        local pulseUp = tween(titleScale, 0.16, { Scale = 1.06 }, Enum.EasingStyle.Sine)
        pulseUp.Completed:Wait()
        local pulseDown = tween(titleScale, 0.18, { Scale = 0.985 }, Enum.EasingStyle.Sine)
        pulseDown.Completed:Wait()
        local pulseSettle = tween(titleScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Sine)
        pulseSettle.Completed:Wait()

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

        for _, view in ipairs(letterViews) do
            tween(
                view.Label,
                0.3,
                { TextTransparency = 1, Position = UDim2.fromOffset(0, -6) },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.In
            )
            tween(
                view.Stroke,
                0.24,
                { Transparency = 1 },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.In
            )
        end

        tween(titleScale, 0.3, { Scale = 0.94 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(progressTrack, 0.26, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(progressFill, 0.26, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local statusOut = tween(
            status,
            0.3,
            { TextTransparency = 1 },
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        )
        tweenVignette(vignetteEdges, 1, 0.3, Enum.EasingDirection.In)
        tween(blur, 0.3, { Size = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        statusOut.Completed:Wait()

        disconnectResponsiveScale()
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
