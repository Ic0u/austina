--Settings--
local ESP = {
    Enabled = false,
    Boxes = true,
    BoxShift = CFrame.new(0,-1.5,0),
	BoxSize = Vector3.new(4,6,0),
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
local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local V3new = Vector3.new
local WorldToViewportPoint = cam.WorldToViewportPoint

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
    self.Enabled = bool
    if not bool then
        for i,v in pairs(self.Objects) do
            if v.Type == "Box" then --fov circle etc
                if v.Temporary then
                    v:Remove()
                else
                    for i,v in pairs(v.Components) do
                        v.Visible = false
                    end
                end
            end
        end
    end
end

function ESP:GetBox(obj)
    return self.Objects[obj]
end

function ESP:AddObjectListener(parent, options)
    local function NewListener(c)
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

    if options.Recursive then
        parent.DescendantAdded:Connect(NewListener)
        for i,v in pairs(parent:GetDescendants()) do
            coroutine.wrap(NewListener)(v)
        end
    else
        parent.ChildAdded:Connect(NewListener)
        for i,v in pairs(parent:GetChildren()) do
            coroutine.wrap(NewListener)(v)
        end
    end
end

local boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    ESP.Objects[self.Object] = nil
    for i,v in pairs(self.Components) do
        v.Visible = false
        v:Remove()
        self.Components[i] = nil
    end
end

function boxBase:Update()
    if not self.PrimaryPart then
        --warn("not supposed to print", self.Object)
        return self:Remove()
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
        for i,v in pairs(self.Components) do
            v.Visible = false
        end
        return
    end

    if ESP.Highlighted == self.Object then
        color = ESP.HighlightColor
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

    if ESP.Boxes then
        local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
        local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
        local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
        local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

        if self.Components.Quad then
            if Vis1 or Vis2 or Vis3 or Vis4 then
                self.Components.Quad.Visible = true
                self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
                self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                self.Components.Quad.Color = color
            else
                self.Components.Quad.Visible = false
            end
        end
    else
        self.Components.Quad.Visible = false
    end

    local tagPosition, tagVisible = WorldToViewportPoint(cam, locs.TagPos.p)
    if ESP.Names and tagVisible and tagPosition.Z > 0 then
        self.Components.Name.Visible = true
        self.Components.Name.Position = Vector2.new(tagPosition.X, tagPosition.Y)
        self.Components.Name.Text = self.Name
        self.Components.Name.Color = color
    else
        self.Components.Name.Visible = false
    end

    if ESP.Distances and tagVisible and tagPosition.Z > 0 then
        self.Components.Distance.Visible = true
        self.Components.Distance.Position = Vector2.new(tagPosition.X, tagPosition.Y + (ESP.Names and 14 or 0))
        self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .. "m away"
        self.Components.Distance.Color = color
    else
        self.Components.Distance.Visible = false
    end

    local humanoid
    if (ESP.HealthBars or ESP.HealthValues) and self.Object:IsA("Model") then
        humanoid = self.Object:FindFirstChildOfClass("Humanoid")
    end
    local healthRatio = humanoid and humanoid.MaxHealth > 0
        and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        or 0
    local healthColor = Color3.fromHSV(healthRatio * 0.33, 0.85, 1)

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

        local topLeft, topVisible = WorldToViewportPoint(cam, locs.TopLeft.p)
        local bottomLeft, bottomVisible = WorldToViewportPoint(cam, locs.BottomLeft.p)
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
                Color = healthColor,
                Outline = true,
                Size = 16,
                Visible = false,
            })
            self.Components.HealthValue = healthValue
        end

        local bottomLeft, bottomVisible = WorldToViewportPoint(cam, locs.BottomLeft.p)
        if bottomVisible and bottomLeft.Z > 0 then
            healthValue.Position = Vector2.new(bottomLeft.X - 20, bottomLeft.Y + 2)
            healthValue.Text = math.floor(humanoid.Health + 0.5) .. " HP"
            healthValue.Color = healthColor
            healthValue.Visible = true
        end
    end

    local toolLabel = self.Components.Tool
    if toolLabel then toolLabel.Visible = false end
    if ESP.Tools and self.Object:IsA("Model") then
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

        local toolName = "None"
        for _, child in ipairs(self.Object:GetChildren()) do
            if child:IsA("Tool") then
                toolName = child.Name
                break
            end
        end

        local toolPosition, toolVisible = WorldToViewportPoint(cam, locs.ToolPos.p)
        if toolVisible and toolPosition.Z > 0 then
            toolLabel.Position = Vector2.new(toolPosition.X, toolPosition.Y + 16)
            toolLabel.Text = toolName
            toolLabel.Color = color
            toolLabel.Visible = true
        end
    end

    if ESP.Tracers then
        local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

        if Vis6 then
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
        for index, bone in ipairs(bones) do
            local fromPart = self.Object:FindFirstChild(bone[1])
            local toPart = self.Object:FindFirstChild(bone[2])
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
        IsEnabled = options.IsEnabled,
        Temporary = options.Temporary,
        ColorDynamic = options.ColorDynamic,
        RenderInNil = options.RenderInNil
    }, boxBase)

    if self:GetBox(obj) then
        self:GetBox(obj):Remove()
    end

    box.Components["Quad"] = Draw("Quad", {
        Thickness = self.Thickness,
        Color = color,
        Transparency = 1,
        Filled = false,
        Visible = self.Enabled and self.Boxes
    })
    box.Components["Name"] = Draw("Text", {
		Text = box.Name,
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
        Visible = self.Enabled and self.Names
	})
	box.Components["Distance"] = Draw("Text", {
		Color = box.Color,
		Center = true,
		Outline = true,
        Size = 19,
		Visible = self.Enabled and self.Distances
	})

	box.Components["Tracer"] = Draw("Line", {
		Thickness = ESP.Thickness,
		Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.Tracers
    })
    self.Objects[obj] = box

    obj.AncestryChanged:Connect(function(_, parent)
        if parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)
    obj:GetPropertyChangedSignal("Parent"):Connect(function()
        if obj.Parent == nil and ESP.AutoRemove ~= false then
            box:Remove()
        end
    end)

    local hum = obj:FindFirstChildOfClass("Humanoid")
	if hum then
        hum.Died:Connect(function()
            if ESP.AutoRemove ~= false then
                box:Remove()
            end
		end)
    end

    return box
end

local function CharAdded(char)
    local p = plrs:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart
        })
    end
end
local function PlayerAdded(p)
    p.CharacterAdded:Connect(CharAdded)
    if p.Character then
        coroutine.wrap(CharAdded)(p.Character)
    end
end
plrs.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(plrs:GetPlayers()) do
    if v ~= plr then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    cam = workspace.CurrentCamera
    for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn("[EU]", e, v.Object:GetFullName()) end
        end
    end
end)

return ESP
