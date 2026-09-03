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
    edge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    edge.BackgroundTransparency = 1
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

    return edge
end

local function createBackdrop(parent)
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.Parent = parent

    local edges = {
        makeEdge(backdrop, UDim2.fromScale(1, 0.24), UDim2.fromScale(0, 0), 90),
        makeEdge(backdrop, UDim2.fromScale(1, 0.24), UDim2.fromScale(0, 0.76), 270),
        makeEdge(backdrop, UDim2.fromScale(0.24, 1), UDim2.fromScale(0, 0), 0),
        makeEdge(backdrop, UDim2.fromScale(0.24, 1), UDim2.fromScale(0.76, 0), 180),
    }

    return backdrop, edges
end

local function fadeVignette(edges, transparency, duration, direction)
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
    title.Font = Enum.Font.FredokaOne
    title.Text = ""
    title.TextColor3 = Color3.fromRGB(255, 235, 242)
    title.TextSize = 32
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = group

    local titleStroke = Instance.new("UIStroke")
    titleStroke.Color = Color3.fromRGB(70, 157, 101)
    titleStroke.Thickness = 1.5
    titleStroke.Transparency = 0.12
    titleStroke.Parent = title

    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 214, 143)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(232, 255, 237)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(87, 180, 116)),
    })
    titleGradient.Rotation = 0
    titleGradient.Parent = title

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
    status.Position = UDim2.fromScale(0.5, 0.595)
    status.Size = UDim2.fromOffset(280, 18)
    status.Font = Enum.Font.PatrickHand
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(246, 242, 244)
    status.TextSize = 16
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

    local _, vignetteEdges = createBackdrop(screenGui)
    local contentGroup, titleScale, title, status, progressTrack, progressFill = createLoaderContent(screenGui)

    task.spawn(function()
        local backdropIn = fadeVignette(vignetteEdges, 0.9, 0.4, Enum.EasingDirection.Out)
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
        fadeVignette(vignetteEdges, 1, 0.3, Enum.EasingDirection.In)
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
