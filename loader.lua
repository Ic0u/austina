

local Loader = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local BASE_URL = "https://raw.githubusercontent.com/Ic0u/austina/main/"
local UNIVERSAL_URL = "https://raw.githubusercontent.com/Ic0u/austina/b1edf1e/scripts/Universal.lua"
local GUI_NAME = "AustinaLoaderGui"
local BLUR_NAME = "AustinaLoaderBlur"
local DEFAULT_GAMES = {
    ["2753915549"] = "Blox Fruits - First Sea",
    ["4442272183"] = "Blox Fruits - Second Sea",
    ["7449423635"] = "Blox Fruits - Third Sea",
}

local function resolveRequestFunction()
    local environment = (getgenv and getgenv()) or _G
    local synapse = environment.syn
    local fluxus = environment.fluxus
    local http = environment.http

    local candidate = environment.request
        or environment.http_request
        or (synapse and synapse.request)
        or (fluxus and fluxus.request)
        or (http and http.request)

    return type(candidate) == "function" and candidate or nil
end

local requestFunction = resolveRequestFunction()

local function fetchText(url)
    if requestFunction then
        local requested, response = pcall(requestFunction, {
            Url = url,
            Method = "GET",
            Headers = {
                ["Accept"] = "text/plain",
                ["Cache-Control"] = "no-cache",
            },
        })

        if requested and type(response) == "string" and response ~= "" then
            return response
        end

        if requested and type(response) == "table" then
            local statusCode = tonumber(response.StatusCode or response.Status)
            local body = response.Body or response.body
            if type(body) == "string" and body ~= ""
                and response.Success ~= false
                and (not statusCode or (statusCode >= 200 and statusCode < 300)) then
                return body
            end
        end
    end

    local fetched, body = pcall(game.HttpGet, game, url)
    if fetched and type(body) == "string" and body ~= "" then
        return body
    end

    return nil
end

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
        local scale = math.min(viewport.X / 1600, viewport.Y / 900)
        scale = math.clamp(scale, 0.68, 1)
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
    local group = Instance.new("CanvasGroup")
    group.Name = "LoaderContent"
    group.AnchorPoint = Vector2.new(0.5, 0.5)
    group.BackgroundTransparency = 1
    group.GroupTransparency = 1
    group.Position = UDim2.fromScale(0.5, 0.5)
    group.Size = UDim2.fromOffset(560, 240)
    group.Parent = parent

    local container = Instance.new("Frame")
    container.Name = "CenteredContent"
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.Size = UDim2.fromScale(1, 1)
    container.Parent = group

    local responsiveScale = Instance.new("UIScale")
    responsiveScale.Scale = 1
    responsiveScale.Parent = container

    local title = Instance.new("Frame")
    title.Name = "Title"
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromScale(0.5, 0.36)
    title.Size = UDim2.fromOffset(380, 64)
    title.Parent = container

    local titleScale = Instance.new("UIScale")
    titleScale.Scale = 1
    titleScale.Parent = title

    local titleLayout = Instance.new("UIListLayout")
    titleLayout.FillDirection = Enum.FillDirection.Horizontal
    titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    titleLayout.Padding = UDim.new(0, 9)
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
        slot.Size = UDim2.fromOffset(40, 60)
        slot.Parent = title

        local letter = Instance.new("TextLabel")
        letter.Name = "Letter" .. index
        letter.BackgroundTransparency = 1
        letter.Font = Enum.Font.FredokaOne
        letter.Position = UDim2.fromOffset(0, 24)
        letter.Rotation = letterRotations[index]
        letter.Size = UDim2.fromScale(1, 1)
        letter.Text = character
        letter.TextColor3 = Color3.fromRGB(230, 255, 237)
        letter.TextSize = 42
        letter.TextTransparency = 1
        letter.Parent = slot

        local letterStroke = Instance.new("UIStroke")
        letterStroke.Color = Color3.fromRGB(70, 157, 101)
        letterStroke.Thickness = 1.25
        letterStroke.Transparency = 1
        letterStroke.Parent = letter

        local letterGradient = Instance.new("UIGradient")
        letterGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 214, 143)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(232, 255, 237)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(87, 180, 116)),
        })
        letterGradient.Offset = Vector2.new(-0.22, 0)
        letterGradient.Rotation = 90
        letterGradient.Parent = letter

        local letterScale = Instance.new("UIScale")
        letterScale.Scale = 0.72
        letterScale.Parent = letter

        table.insert(letterViews, {
            Label = letter,
            Scale = letterScale,
            Stroke = letterStroke,
            Gradient = letterGradient,
        })
    end

    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.AnchorPoint = Vector2.new(0.5, 0.5)
    progressTrack.BackgroundColor3 = Color3.fromRGB(238, 237, 241)
    progressTrack.BackgroundTransparency = 1
    progressTrack.BorderSizePixel = 0
    progressTrack.Position = UDim2.fromScale(0.5, 0.68)
    progressTrack.Size = UDim2.fromOffset(320, 4)
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

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 159, 98)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(221, 255, 230)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(82, 184, 116)),
    })
    fillGradient.Offset = Vector2.new(-1, 0)
    fillGradient.Parent = progressFill

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromScale(0.5, 0.82)
    status.Size = UDim2.fromOffset(360, 24)
    status.Font = Enum.Font.PatrickHand
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(246, 242, 244)
    status.TextSize = 19
    status.TextTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Center
    status.Parent = container

    return {
        Group = group,
        ResponsiveScale = responsiveScale,
        TitleScale = titleScale,
        LetterViews = letterViews,
        ProgressTrack = progressTrack,
        ProgressFill = progressFill,
        ProgressGradient = fillGradient,
        Status = status,
    }
end

local function fetchGameRegistry()
    local response = fetchText(BASE_URL .. "games.json")
    if not response then
        return DEFAULT_GAMES
    end

    local decodedOk, registry = pcall(HttpService.JSONDecode, HttpService, response)
    if decodedOk and type(registry) == "table" then
        return registry
    end

    return DEFAULT_GAMES
end

local function runSource(url)
    local source = fetchText(url)
    if not source then
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
    local scriptUrl = supportedGames[placeId]
        and (BASE_URL .. "games/" .. placeId .. ".lua")
        or UNIVERSAL_URL
    runSource(scriptUrl)
end

function Loader.Start(onComplete)
    if Loader._running then
        return nil
    end
    Loader._running = true

    destroyExisting()

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = GUI_NAME
    screenGui.DisplayOrder = 1000000
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        screenGui.OnTopOfCoreBlur = true
    end)
    parentGui(screenGui)

    local blur = Instance.new("BlurEffect")
    blur.Name = BLUR_NAME
    blur.Size = 0
    blur.Parent = Lighting

    local vignetteEdges = createWhiteVignette(screenGui)
    local views = createLoaderContent(screenGui)
    local disconnectResponsiveScale = bindResponsiveScale(views.ResponsiveScale)

    task.spawn(function()
        tweenVignette(vignetteEdges, 0.82, 0.48, Enum.EasingDirection.Out)
        local blurIn = tween(blur, 0.48, { Size = 20 })
        blurIn.Completed:Wait()

        local contentIn = tween(
            views.Group,
            0.24,
            { GroupTransparency = 0 },
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        )
        contentIn.Completed:Wait()

        local lastLetterTween
        for _, view in ipairs(views.LetterViews) do
            lastLetterTween = tween(
                view.Label,
                0.44,
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
                0.44,
                { Scale = 1 },
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            )
            tween(
                view.Stroke,
                0.32,
                { Transparency = 0.16 },
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )
            tween(view.Gradient, 0.48, { Offset = Vector2.new(0.22, 0) })
            task.wait(0.048)
        end

        if lastLetterTween then
            lastLetterTween.Completed:Wait()
        end

        local pulseUp = tween(views.TitleScale, 0.16, { Scale = 1.055 }, Enum.EasingStyle.Sine)
        pulseUp.Completed:Wait()
        local pulseDown = tween(views.TitleScale, 0.18, { Scale = 0.988 }, Enum.EasingStyle.Sine)
        pulseDown.Completed:Wait()
        local pulseSettle = tween(views.TitleScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Sine)
        pulseSettle.Completed:Wait()

        local uiFade = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(views.ProgressTrack, uiFade, { BackgroundTransparency = 0.56 }):Play()
        TweenService:Create(views.ProgressFill, uiFade, { BackgroundTransparency = 0 }):Play()
        task.wait(0.1)
        TweenService:Create(views.Status, uiFade, { TextTransparency = 0 }):Play()
        task.wait(0.25)

        local function setProgress(message, percent, holdTime)
            local hideStatus = tween(views.Status, 0.12, { TextTransparency = 1 })
            hideStatus.Completed:Wait()
            views.Status.Text = message
            views.ProgressGradient.Offset = Vector2.new(-1, 0)
            tween(views.Status, 0.18, { TextTransparency = 0 })
            tween(views.ProgressFill, 0.62, { Size = UDim2.fromScale(percent, 1) })
            tween(
                views.ProgressGradient,
                0.72,
                { Offset = Vector2.new(1, 0) },
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut
            )
            task.wait(holdTime)
        end

        setProgress("Initializing...", 0.3, 0.52)
        setProgress("Loading...", 0.74, 0.54)
        setProgress("Ready.", 1, 0.36)

        for index, view in ipairs(views.LetterViews) do
            task.delay((index - 1) * 0.025, function()
                if view.Scale.Parent then
                    local rise = tween(view.Scale, 0.12, { Scale = 1.08 }, Enum.EasingStyle.Sine)
                    rise.Completed:Wait()
                    tween(view.Scale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back)
                end
            end)
        end
        task.wait(0.18)

        tween(views.TitleScale, 0.32, { Scale = 0.94 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tweenVignette(vignetteEdges, 1, 0.34, Enum.EasingDirection.In)
        tween(blur, 0.34, { Size = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        local contentOut = tween(
            views.Group,
            0.34,
            { GroupTransparency = 1 },
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.In
        )
        contentOut.Completed:Wait()

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
