--Settings--
local ESP = {
    Enabled = false,
    Boxes = true,
    BoxShift = CFrame.new(0,-1.5,0),
	BoxSize = Vector3.new(4,6,0),
    Chams = false,
    ChamsAlwaysOnTop = true,
    ChamsFillTransparency = 0.65,
    ChamsOutlineTransparency = 0,
    Color = Color3.fromRGB(255, 170, 0),
    Distances = true,
    FaceCamera = false,
    HealthBars = false,
    HealthValues = false,
    Names = true,
    Skeletons = false,
    TeamColor = true,
    Thickness = 2,
    AttachShift = 1,
    TeamMates = true,
    Tools = false,
    Players = true,

    Objects = setmetatable({}, {__mode="kv"}),
    Overrides = {}
}

--Declarations--
local plrs = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local plr = plrs.LocalPlayer or plrs.PlayerAdded:Wait()
local cam = Workspace.CurrentCamera
local WorldToViewportPoint = cam and cam.WorldToViewportPoint
local globalConnections = {}
local sharedEnvironment = getgenv and getgenv() or _G
local renderBindName = "VinsersHubESPRender"

local previousESP = sharedEnvironment.VinsersHubESP
if previousESP and previousESP ~= ESP and previousESP.Destroy then
    pcall(previousESP.Destroy, previousESP)
end
sharedEnvironment.VinsersHubESP = ESP

local MAX_SKELETON_LINES = 14
local R6_BONES = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}
local R15_BONES = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

--Functions--
local function Draw(obj, props)
	local new = Drawing.new(obj)

	props = props or {}
	for i,v in pairs(props) do
		new[i] = v
	end
	return new
end

local function trackGlobalConnection(connection)
    table.insert(globalConnections, connection)
    return connection
end

function ESP:GetTeam(p)
	local ov = self.Overrides.GetTeam
	if ov then
		return ov(p)
	end

	return p and p.Team
end

function ESP:IsTeamMate(p)
    local ov = self.Overrides.IsTeamMate
	if ov then
		return ov(p)
    end

    return self:GetTeam(p) == self:GetTeam(plr)
end

function ESP:GetColor(obj)
	local ov = self.Overrides.GetColor
	if ov then
		return ov(obj)
    end
    local p = self:GetPlrFromChar(obj)
	return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
end

function ESP:GetPlrFromChar(char)
	local ov = self.Overrides.GetPlrFromChar
	if ov then
		return ov(char)
	end

	return plrs:GetPlayerFromCharacter(char)
end

function ESP:Toggle(bool)
    if self.Destroyed then
        return
    end

    self.Enabled = bool == true
    if not self.Enabled then
        for _, box in pairs(self.Objects) do
            if box.Type == "Box" then --fov circle etc
                if box.Temporary then
                    box:Remove()
                else
                    box:Hide()
                end
            end
        end
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    options = options or {}

    local function NewListener(c)
        if ESP.Destroyed then
            return
        end
        if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
            if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
                if not options.Validator or options.Validator(c) then
                    local box = ESP:Add(c, {
                        PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
                        Color = type(options.Color) == "function" and options.Color(c) or options.Color,
                        ColorDynamic = options.ColorDynamic,
                        Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
                        IsEnabled = options.IsEnabled,
                        RenderInNil = options.RenderInNil
                    })
                    --TODO: add a better way of passing options
                    if options.OnAdded then
                        coroutine.wrap(options.OnAdded)(box)
                    end
                end
            end
        end
    end

    local listener
    if options.Recursive then
        listener = trackGlobalConnection(parent.DescendantAdded:Connect(NewListener))
        for i,v in pairs(parent:GetDescendants()) do
            coroutine.wrap(NewListener)(v)
        end
    else
        listener = trackGlobalConnection(parent.ChildAdded:Connect(NewListener))
        for i,v in pairs(parent:GetChildren()) do
            coroutine.wrap(NewListener)(v)
        end
    end

    return listener
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:HideDrawings()
    for _, component in pairs(self.Components) do
        component.Visible = false
    end
end

function boxBase:Hide()
    self:HideDrawings()
    if self.Highlight then
        self.Highlight.Enabled = false
    end
end

function boxBase:TrackConnection(connection)
    table.insert(self.Connections, connection)
    return connection
end

function boxBase:RefreshTool()
    self.ToolName = "None"
    if not self.Object:IsA("Model") then
        return
    end

    for _, child in ipairs(self.Object:GetChildren()) do
        if child:IsA("Tool") then
            self.ToolName = child.Name
            return
        end
    end
end

function boxBase:EnsureToolTracking()
    if self.ToolTracking or not self.Object:IsA("Model") then
        return
    end

    self.ToolTracking = true
    self:RefreshTool()
    self:TrackConnection(self.Object.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            self:RefreshTool()
        end
    end))
    self:TrackConnection(self.Object.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            self:RefreshTool()
        end
    end))
end

function boxBase:UpdateHighlight(color)
    local canHighlight = self.Object:IsA("Model") or self.Object:IsA("BasePart")
    if not ESP.Chams or not canHighlight then
        if self.Highlight then
            self.Highlight.Enabled = false
        end
        return
    end

    if not self.Highlight then
        local highlight = Instance.new("Highlight")
        highlight.Name = "VinsersHubChams"
        highlight.Adornee = self.Object
        highlight.Parent = self.Object
        self.Highlight = highlight
    end

    self.Highlight.DepthMode = ESP.ChamsAlwaysOnTop
        and Enum.HighlightDepthMode.AlwaysOnTop
        or Enum.HighlightDepthMode.Occluded
    self.Highlight.FillColor = color
    self.Highlight.FillTransparency = ESP.ChamsFillTransparency
    self.Highlight.OutlineColor = color
    self.Highlight.OutlineTransparency = ESP.ChamsOutlineTransparency
    self.Highlight.Enabled = true
end

function boxBase:Remove()
    if self.Removed then
        return
    end
    self.Removed = true
    ESP.Objects[self.Object] = nil

    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}

    for name, component in pairs(self.Components) do
        component.Visible = false
        component:Remove()
        self.Components[name] = nil
    end

    if self.Highlight then
        self.Highlight:Destroy()
        self.Highlight = nil
    end
end

function boxBase:Update()
    if self.Removed then
        return
    end
    if not self.PrimaryPart then
        return self:Remove()
    end
    if not cam or not WorldToViewportPoint then
        return self:Hide()
    end

    local color
    if ESP.Highlighted == self.Object then
       color = ESP.HighlightColor
    else
        color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
    end

    local allow = true
    if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
        allow = false
    end
    if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
        allow = false
    end
    if self.Player and not ESP.Players then
        allow = false
    end
    if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
        allow = false
    end
    if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
        allow = false
    end

    if not allow then
        self:Hide()
        return
    end

    if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
    end

    self:UpdateHighlight(color)

    local hasDrawing = ESP.Boxes
        or ESP.Distances
        or ESP.HealthBars
        or ESP.HealthValues
        or ESP.Names
        or ESP.Skeletons
        or ESP.Tools
        or ESP.Tracers
    if not hasDrawing then
        self:HideDrawings()
        return
    end

    --calculations--
    local cf = self.PrimaryPart.CFrame
    if ESP.FaceCamera then
        cf = CFrame.new(cf.p, cam.CFrame.p)
    end
    local size = self.Size
    local locs = {
        TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
        TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
        BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
        BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
        TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
        ToolPos = cf * ESP.BoxShift * CFrame.new(0,-size.Y/2,0),
        Torso = cf * ESP.BoxShift
    }

    local topLeft, topVisible
    local topRight, topRightVisible
    local bottomLeft, bottomVisible
    local bottomRight, bottomRightVisible
    if ESP.Boxes or ESP.HealthBars or ESP.HealthValues then
        topLeft, topVisible = WorldToViewportPoint(cam, locs.TopLeft.p)
        bottomLeft, bottomVisible = WorldToViewportPoint(cam, locs.BottomLeft.p)
        if ESP.Boxes then
            topRight, topRightVisible = WorldToViewportPoint(cam, locs.TopRight.p)
            bottomRight, bottomRightVisible = WorldToViewportPoint(cam, locs.BottomRight.p)
        end
    end

    if ESP.Boxes then
        if self.Components.Quad then
            local boundsInFront = topLeft.Z > 0
                and topRight.Z > 0
                and bottomLeft.Z > 0
                and bottomRight.Z > 0
            if boundsInFront and (topVisible or topRightVisible or bottomVisible or bottomRightVisible) then
                self.Components.Quad.Visible = true
                self.Components.Quad.PointA = Vector2.new(topRight.X, topRight.Y)
                self.Components.Quad.PointB = Vector2.new(topLeft.X, topLeft.Y)
                self.Components.Quad.PointC = Vector2.new(bottomLeft.X, bottomLeft.Y)
                self.Components.Quad.PointD = Vector2.new(bottomRight.X, bottomRight.Y)
                self.Components.Quad.Color = color
            else
                self.Components.Quad.Visible = false
            end
        end
    else
        self.Components.Quad.Visible = false
    end

    local namePosition, nameVisible
    if ESP.Names then
        local head = self.Head
        if not head or not head.Parent then
            head = self.Object:IsA("Model") and self.Object:FindFirstChild("Head")
            self.Head = head
        end

        local nameWorldPosition = head and head:IsA("BasePart")
            and head.Position + Vector3.new(0, head.Size.Y * 0.5 + 0.35, 0)
            or locs.TagPos.p
        namePosition, nameVisible = WorldToViewportPoint(cam, nameWorldPosition)
    end
    if ESP.Names and nameVisible and namePosition.Z > 0 then
        self.Components.Name.Visible = true
        self.Components.Name.Position = Vector2.new(namePosition.X, namePosition.Y - 16)
        self.Components.Name.Text = self.Name
        self.Components.Name.Color = color
    else
        self.Components.Name.Visible = false
    end

    local lowerPosition, lowerVisible
    if ESP.Distances or ESP.Tools then
        lowerPosition, lowerVisible = WorldToViewportPoint(cam, locs.ToolPos.p)
    end
    if ESP.Distances and lowerVisible and lowerPosition.Z > 0 then
        self.Components.Distance.Visible = true
        self.Components.Distance.Position = Vector2.new(lowerPosition.X, lowerPosition.Y + 4)
        self.Components.Distance.Text = ("[%d] studs"):format(math.floor((cam.CFrame.p - cf.p).magnitude + 0.5))
        self.Components.Distance.Color = color
    else
        self.Components.Distance.Visible = false
    end

    local wantsHealth = ESP.HealthBars or ESP.HealthValues
    local humanoid = wantsHealth and self.Humanoid or nil
    if wantsHealth and (not humanoid or not humanoid.Parent) then
        humanoid = self.Object:IsA("Model") and self.Object:FindFirstChildOfClass("Humanoid")
        self.Humanoid = humanoid
    end
    local healthRatio
    local healthColor
    if humanoid then
        healthRatio = humanoid.MaxHealth > 0
            and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            or 0
        healthColor = Color3.fromHSV(healthRatio * 0.33, 0.85, 1)
    end

    local healthBarBackground = self.Components.HealthBarBackground
    local healthBar = self.Components.HealthBar
    if healthBarBackground then healthBarBackground.Visible = false end
    if healthBar then healthBar.Visible = false end

    if ESP.HealthBars and humanoid then
        if not healthBarBackground then
            healthBarBackground = Draw("Line", {
                Color = Color3.fromRGB(15, 15, 18),
                Thickness = math.max(ESP.Thickness + 4, 5),
                Transparency = 0.8,
                Visible = false,
            })
            self.Components.HealthBarBackground = healthBarBackground
        end
        if not healthBar then
            healthBar = Draw("Line", {
                Color = healthColor,
                Thickness = math.max(ESP.Thickness + 1, 3),
                Transparency = 1,
                Visible = false,
            })
            self.Components.HealthBar = healthBar
        end

        if topVisible and bottomVisible and topLeft.Z > 0 and bottomLeft.Z > 0 then
            local barBottom = Vector2.new(bottomLeft.X - 7, bottomLeft.Y)
            local barTop = Vector2.new(topLeft.X - 7, topLeft.Y)
            healthBarBackground.From = barBottom
            healthBarBackground.To = barTop
            healthBarBackground.Visible = true
            healthBar.From = barBottom
            healthBar.To = barBottom:Lerp(barTop, healthRatio)
            healthBar.Color = healthColor
            healthBar.Visible = true
        end
    end

    local healthValue = self.Components.HealthValue
    if healthValue then healthValue.Visible = false end
    if ESP.HealthValues and humanoid then
        if not healthValue then
            healthValue = Draw("Text", {
                Center = true,
                Color = ESP.Color,
                Outline = true,
                Size = 16,
                Visible = false,
            })
            self.Components.HealthValue = healthValue
        end

        if bottomVisible and bottomLeft.Z > 0 then
            healthValue.Position = Vector2.new(bottomLeft.X - 20, bottomLeft.Y + 2)
            healthValue.Text = tostring(math.floor(humanoid.Health + 0.5))
            healthValue.Color = ESP.Color
            healthValue.Visible = true
        end
    end

    local toolLabel = self.Components.Tool
    if toolLabel then toolLabel.Visible = false end
    if ESP.Tools and self.Object:IsA("Model") then
        self:EnsureToolTracking()
        if not toolLabel then
            toolLabel = Draw("Text", {
                Center = true,
                Color = color,
                Outline = true,
                Size = 17,
                Visible = false,
            })
            self.Components.Tool = toolLabel
        end

        if lowerVisible and lowerPosition.Z > 0 then
            toolLabel.Position = Vector2.new(lowerPosition.X, lowerPosition.Y + (ESP.Distances and 22 or 4))
            toolLabel.Text = self.ToolName
            toolLabel.Color = color
            toolLabel.Visible = true
        end
    end

    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 and TorsoPos.Z > 0 then
            self.Components.Tracer.Visible = true
            self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
            self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
            self.Components.Tracer.Color = color
        else
            self.Components.Tracer.Visible = false
        end
    else
        self.Components.Tracer.Visible = false
    end

    for index = 1, MAX_SKELETON_LINES do
        local line = self.Components["Skeleton" .. index]
        if line then
            line.Visible = false
        end
    end

    if ESP.Skeletons and self.Object:IsA("Model") then
        local bones = self.Object:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
        self.SkeletonParts = self.SkeletonParts or {}
        for index, bone in ipairs(bones) do
            local cachedParts = self.SkeletonParts[index]
            local fromPart = cachedParts and cachedParts[1]
            local toPart = cachedParts and cachedParts[2]
            if not fromPart or not fromPart.Parent or not toPart or not toPart.Parent then
                fromPart = self.Object:FindFirstChild(bone[1])
                toPart = self.Object:FindFirstChild(bone[2])
                if fromPart and toPart then
                    self.SkeletonParts[index] = { fromPart, toPart }
                end
            end
            local componentName = "Skeleton" .. index
            local line = self.Components[componentName]

            if not line then
                line = Draw("Line", {
                    Thickness = ESP.Thickness,
                    Color = color,
                    Transparency = 1,
                    Visible = false,
                })
                self.Components[componentName] = line
            end

            if fromPart and toPart and fromPart:IsA("BasePart") and toPart:IsA("BasePart") then
                local fromPoint, fromVisible = WorldToViewportPoint(cam, fromPart.Position)
                local toPoint, toVisible = WorldToViewportPoint(cam, toPart.Position)
                if fromVisible and toVisible and fromPoint.Z > 0 and toPoint.Z > 0 then
                    line.From = Vector2.new(fromPoint.X, fromPoint.Y)
                    line.To = Vector2.new(toPoint.X, toPoint.Y)
                    line.Color = color
                    line.Thickness = ESP.Thickness
                    line.Visible = true
                end
            end
        end
    end
end

function ESP:Add(obj, options)
    options = options or {}
    if self.Destroyed then
        return nil
    end
    if not obj.Parent and not options.RenderInNil then
        return warn(obj, "has no parent")
    end

    local box = setmetatable({
        Name = options.Name or obj.Name,
        Type = "Box",
        Color = options.Color --[[or self:GetColor(obj)]],
        Size = options.Size or self.BoxSize,
        Object = obj,
        Player = options.Player or plrs:GetPlayerFromCharacter(obj),
        PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
        Components = {},
        Connections = {},
        Head = obj:IsA("Model") and obj:FindFirstChild("Head") or nil,
        Humanoid = obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") or nil,
        IsEnabled = options.IsEnabled,
        SkeletonParts = {},
        Temporary = options.Temporary,
        ToolName = "None",
        ToolTracking = false,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end

    local initialColor = box.Color or self:GetColor(obj) or self.Color

    box.Components["Quad"] = Draw("Quad", {
        Thickness = self.Thickness,
        Color = initialColor,
        Transparency = 1,
        Filled = false,
        Visible = self.Enabled and self.Boxes
    })
    box.Components["Name"] = Draw("Text", {
			Text = box.Name,
			Color = initialColor,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	box.Components["Distance"] = Draw("Text", {
			Color = initialColor,
		Center = true,
		Outline = true,
        Size = 19,
		Visible = self.Enabled and self.Distances
	})

	box.Components["Tracer"] = Draw("Line", {
			Thickness = ESP.Thickness,
			Color = initialColor,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })
    self.Objects[obj] = box

    box:TrackConnection(obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end))
    box:TrackConnection(obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end))

    local hum = box.Humanoid
	if hum then
        box:TrackConnection(hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
		end))
    end

    return box
end

local function CharAdded(p, char)
    if ESP.Destroyed or p == plr then
        return
    end

    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = trackGlobalConnection(char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end))
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    if ESP.Destroyed or p == plr then
        return
    end

    trackGlobalConnection(p.CharacterAdded:Connect(function(char)
        CharAdded(p, char)
    end))
    if p.Character then
        coroutine.wrap(CharAdded)(p, p.Character)
    end
end
trackGlobalConnection(plrs.PlayerAdded:Connect(PlayerAdded))
for _, player in pairs(plrs:GetPlayers()) do
    PlayerAdded(player)
end

local function renderESP()
    if ESP.Destroyed then
        return
    end

    local currentCamera = Workspace.CurrentCamera
    if currentCamera ~= cam then
        cam = currentCamera
        WorldToViewportPoint = cam and cam.WorldToViewportPoint
    end
    if not cam then
        return
    end

    for _, object in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if object.Update then
            local success, err = pcall(object.Update, object)
            if not success then
                local objectName = object.Object and object.Object:GetFullName() or "custom object"
                warn("[Vinsers Hub ESP]", err, objectName)
            end
        end
    end
end

pcall(RunService.UnbindFromRenderStep, RunService, renderBindName)
RunService:BindToRenderStep(renderBindName, Enum.RenderPriority.Camera.Value + 1, renderESP)

function ESP:Destroy()
    if self.Destroyed then
        return
    end

    self.Enabled = false
    self.Destroyed = true
    RunService:UnbindFromRenderStep(renderBindName)

    local boxes = {}
    for _, object in pairs(self.Objects) do
        if type(object) == "table" and object.Type == "Box" and object.Remove then
            table.insert(boxes, object)
        end
    end
    for _, box in ipairs(boxes) do
        box:Remove()
    end

    for _, connection in ipairs(globalConnections) do
        connection:Disconnect()
    end
    globalConnections = {}

    if sharedEnvironment.VinsersHubESP == self then
        sharedEnvironment.VinsersHubESP = nil
    end
end

return ESP
