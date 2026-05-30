                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
            pcall(function()
                Lighting.GlobalShadows  = false
                Lighting.FogEnd         = 1e9
                Lighting.Brightness     = 1
            end)
            pcall(function()

                local _step = 0
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                    or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                        obj.Enabled = false
                    end
                    _step = _step + 1
                    if _step % 500 == 0 then task.wait() end
                end
            end)

            workspace.DescendantAdded:Connect(function(obj)
                if not _G._FH_AlwaysOnFPS then return end
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    pcall(function() obj.Enabled = false end)
                end
            end)
        end)
    end
end
AntiRagdoll.forceBackpack = function()
    if not AntiRagdoll.running then return end
    local gui = Player:FindFirstChild("PlayerGui")
    if not gui then return end
    local backpackGui = gui:FindFirstChild("BackpackGui")
    if not backpackGui then return end
    local backpack = backpackGui:FindFirstChild("Backpack")
    if not backpack then return end
    backpack.Visible = true
    if not backpack:FindFirstChild("ForceConnection") then
        local tag = Instance.new("BoolValue")
        tag.Name   = "ForceConnection"
        tag.Parent = backpack
        backpack:GetPropertyChangedSignal("Visible"):Connect(function()
            if not AntiRagdoll.running then return end
            if not backpack.Visible then backpack.Visible = true end
        end)
    end
end
AntiRagdoll.removeRagdollConstraints = function(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
            or d:IsA("NoCollisionConstraint")
            or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
            d:Destroy()
        end
    end
end
AntiRagdoll.resetCharacter = function(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.Anchored = false
        rootPart.Velocity  = Vector3.zero
    end
    if humanoid then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then
                obj.Enabled = true
            end
        end
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid.PlatformStand = false
        humanoid.Sit           = false
        if humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        workspace.CurrentCamera.CameraSubject = humanoid
    end
end
AntiRagdoll.onCharacterAdded_AR = function(char)
    char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")

    AntiRagdoll.connections.charDescAdded = char.DescendantAdded:Connect(function(obj)
        if not AntiRagdoll.running then return end
        if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
            or obj:IsA("NoCollisionConstraint")
            or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
            task.defer(function()
                if not AntiRagdoll.running then return end
                if obj.Parent then obj:Destroy() end
            end)
        end
    end)
    AntiRagdoll.connections.platformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
        if not AntiRagdoll.running then return end
        if humanoid.PlatformStand then
            task.defer(function()
                if not AntiRagdoll.running then return end
                AntiRagdoll.resetCharacter(char)
                AntiRagdoll.removeRagdollConstraints(char)
            end)
        end
    end)
    AntiRagdoll.removeRagdollConstraints(char)
    AntiRagdoll.resetCharacter(char)
end
AntiRagdoll.enable = function()

    if AntiRagdoll.running then return end
    AntiRagdoll.running = true
    local _arTick = 0
    AntiRagdoll.connections.heartbeat = RunService.Heartbeat:Connect(function(dt)
        _arTick = _arTick + dt
        if _arTick < 0.1 then return end
        _arTick = 0
        local char = Player.Character
        if not char then return end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not (hum and root) then return end
        local s = hum:GetState()
        local ragdolled = (s == Enum.HumanoidStateType.Physics
            or s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown)
        local endTime = Player:GetAttribute("RagdollEndTime")
        if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
            ragdolled = true
        end
        if ragdolled then
            pcall(function() Player:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
            AntiRagdoll.removeRagdollConstraints(char)
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then
                    obj.Enabled = true
                end
            end
            if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
            workspace.CurrentCamera.CameraSubject = hum
            root.Anchored = false
            root.Velocity  = Vector3.zero
        end
    end)
    AntiRagdoll.connections.charAdded = Player.CharacterAdded:Connect(function(char)
        task.wait(1)
        AntiRagdoll.forceBackpack()
        AntiRagdoll.onCharacterAdded_AR(char)
    end)
    if Player.Character then AntiRagdoll.onCharacterAdded_AR(Player.Character) end
    task.spawn(function()
        while AntiRagdoll.running do
            task.wait(0.5)
            AntiRagdoll.forceBackpack()
        end
    end)
end
AntiRagdoll.disable = function()
    AntiRagdoll.running = false
    for _, conn in pairs(AntiRagdoll.connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    AntiRagdoll.connections = {}

    pcall(function()
        local char = Player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end
    end)
end
pcall(function()
    if game.CoreGui:FindFirstChild("FadedHub") then
        game.CoreGui.FadedHub:Destroy()
    end
end)
T = {
    BG          = Color3.fromRGB(18,  18,  18),
    Header      = Color3.fromRGB(8,   8,   8),
    Card        = Color3.fromRGB(24,  24,  24),
    CardHover   = Color3.fromRGB(24,  24,  24),
    Border      = Color3.fromRGB(45,  45,  45),
    BorderHover = Color3.fromRGB(45,  45,  45),
    White       = Color3.fromRGB(245, 245, 245),
    Dim         = Color3.fromRGB(110, 110, 110),
    TabActive   = Color3.fromRGB(245, 245, 245),
    TabInact    = Color3.fromRGB(75,  75,  75),
    TrackOn     = Color3.fromRGB(240, 240, 240),
    TrackOff    = Color3.fromRGB(45,  45,  45),
    KnobOn      = Color3.fromRGB(10,  10,  10),
    KnobOff     = Color3.fromRGB(160, 160, 160),
}

do
    local function _restoreRGB(t, dr, dg, db)
        if type(t) == "table" then
            return Color3.fromRGB(tonumber(t[1]) or dr, tonumber(t[2]) or dg, tonumber(t[3]) or db)
        end
        return Color3.fromRGB(dr, dg, db)
    end
    Config.theme   = Config.theme or (_FH_SavedConfig and _FH_SavedConfig.theme) or {}
    _G._FH_AccentA = _restoreRGB(Config.theme.a, 120, 200, 255)
    _G._FH_AccentB = _restoreRGB(Config.theme.b, 255, 120, 220)
end
_G._FH_ThemeStrokes = _G._FH_ThemeStrokes or {}
_G._FH_ThemeFills   = _G._FH_ThemeFills   or {}
local function _FH_BuildThemeSequence()
    local A, B = _G._FH_AccentA, _G._FH_AccentB

    local function mix(c1, c2, t)
        return Color3.new(
            c1.R + (c2.R - c1.R) * t,
            c1.G + (c2.G - c1.G) * t,
            c1.B + (c2.B - c1.B) * t
        )
    end
    local function brighten(c, amt)
        return Color3.new(
            math.min(1, c.R + (1 - c.R) * amt),
            math.min(1, c.G + (1 - c.G) * amt),
            math.min(1, c.B + (1 - c.B) * amt)
        )
    end
    local midAB = brighten(mix(A, B, 0.5), 0.15)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, A),
        ColorSequenceKeypoint.new(0.25, midAB),
        ColorSequenceKeypoint.new(0.50, B),
        ColorSequenceKeypoint.new(0.75, midAB),
        ColorSequenceKeypoint.new(1.00, A),
    })
end

local function _FH_BuildESPSwipeSequence()
    local accent = _G._FH_AccentA or Color3.fromRGB(120, 200, 255)
    local white  = Color3.fromRGB(255, 255, 255)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, white),
        ColorSequenceKeypoint.new(0.42, white),
        ColorSequenceKeypoint.new(0.50, accent),
        ColorSequenceKeypoint.new(0.58, white),
        ColorSequenceKeypoint.new(1.00, white),
    })
end
_G._FH_BuildESPSwipeSequence = _FH_BuildESPSwipeSequence

local function _FH_AddThemeStroke(stroke)
    if not stroke then return end
    local g = stroke:FindFirstChildOfClass("UIGradient")
    if not g then
        g = Instance.new("UIGradient")
        g.Parent = stroke
    end
    g.Color    = _FH_BuildThemeSequence()
    g.Rotation = 35
    g.Transparency = NumberSequence.new(0)
    table.insert(_G._FH_ThemeStrokes, g)
    return g
end

local function _FH_AddThemeStrokeToFrame(frame, thickness)
    if not frame then return end
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Thickness       = thickness or 1.6
    s.Color           = Color3.fromRGB(255, 255, 255)
    s.Parent          = frame
    return _FH_AddThemeStroke(s)
end

local function _FH_AddThemeFill(frame)
    if not frame then return end
    local g = frame:FindFirstChildOfClass("UIGradient")
    if not g then
        g = Instance.new("UIGradient")
        g.Parent = frame
    end
    g.Color    = _FH_BuildThemeSequence()
    g.Rotation = 35
    g.Transparency = NumberSequence.new(0)
    table.insert(_G._FH_ThemeFills, g)
    return g
end
_G._FH_BuildThemeSequence = _FH_BuildThemeSequence

_G._FH_ESPGradients = _G._FH_ESPGradients or {}

local function _FH_ApplyThemeGradientToText(label, rotation, keepColor)
    if not label then return end
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    local g = label:FindFirstChildOfClass("UIGradient")
    local fresh = false
    if not g then
        g = Instance.new("UIGradient")
        g.Parent = label
        fresh = true
    end
    g.Color        = _FH_BuildESPSwipeSequence()
    g.Rotation     = 0
    g.Transparency = NumberSequence.new(0)
    if fresh then
        table.insert(_G._FH_ESPGradients, g)
    end
    return g
end
_G._FH_ApplyThemeGradientToText = _FH_ApplyThemeGradientToText

local function _FH_TintGUI()
    if not _G or not GUI then return end
    local A, B = _G._FH_AccentA, _G._FH_AccentB
    if not (A and B) then return end
    local midR = (A.R + B.R) * 0.5
    local midG = (A.G + B.G) * 0.5
    local midB = (A.B + B.B) * 0.5
    local AMT  = 0.18
    for _, d in ipairs(GUI:GetDescendants()) do
        if d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageButton")
        or d:IsA("ScrollingFrame") or d:IsA("TextBox") then
            local orig = d:GetAttribute("_FH_OrigBG")
            if not orig then
                local c = d.BackgroundColor3

                if math.max(c.R, c.G, c.B) < 0.27 and d.BackgroundTransparency < 0.98 then
                    d:SetAttribute("_FH_OrigBG", c)
                    orig = c
                end
            end
            if orig then
                d.BackgroundColor3 = Color3.new(
                    orig.R + (midR - orig.R) * AMT,
                    orig.G + (midG - orig.G) * AMT,
                    orig.B + (midB - orig.B) * AMT)
            end
        end
    end
end
_G._FH_TintGUI = _FH_TintGUI
_G._FH_ThemeCallbacks = _G._FH_ThemeCallbacks or {}
local function _FH_UpdateThemeColors()
    local seq    = _FH_BuildThemeSequence()
    local espSeq = _FH_BuildESPSwipeSequence()
    for _, g in ipairs(_G._FH_ThemeStrokes) do pcall(function() g.Color = seq    end) end
    for _, g in ipairs(_G._FH_ThemeFills)   do pcall(function() g.Color = seq    end) end
    for _, g in ipairs(_G._FH_ESPGradients) do pcall(function() g.Color = espSeq end) end
    for _, fn in ipairs(_G._FH_ThemeCallbacks) do pcall(fn) end
    pcall(_FH_TintGUI)
    Config.theme = Config.theme or {}
    Config.theme.a = { math.floor(_G._FH_AccentA.R * 255 + 0.5),
                       math.floor(_G._FH_AccentA.G * 255 + 0.5),
                       math.floor(_G._FH_AccentA.B * 255 + 0.5) }
    Config.theme.b = { math.floor(_G._FH_AccentB.R * 255 + 0.5),
                       math.floor(_G._FH_AccentB.G * 255 + 0.5),
                       math.floor(_G._FH_AccentB.B * 255 + 0.5) }
    pcall(FH_SaveConfig)
end
_G._FH_UpdateThemeColors = _FH_UpdateThemeColors

task.spawn(function()
    pcall(_FH_TintGUI)
    while true do
        task.wait(5)
        pcall(_FH_TintGUI)
    end
end)

if not _G._FH_ThemeRotator_v4 then
    _G._FH_ThemeRotator_v4 = true

    local function spin(list, rot)
        local n, w = #list, 0
        for r = 1, n do
            local g = list[r]
            if g and g.Parent then
                w = w + 1
                list[w] = g
                g.Rotation = rot
            end
        end
        for i = n, w + 1, -1 do list[i] = nil end
    end
    task.spawn(function()
        local rot = 0
        while true do
            local strokes = _G._FH_ThemeStrokes
            local fills   = _G._FH_ThemeFills
            if (strokes and #strokes > 0) or (fills and #fills > 0) then
                rot = (rot + 4.8) % 360
                if strokes then spin(strokes, rot) end
                if fills   then spin(fills,   (rot + 60) % 360) end
                task.wait(1 / 15)
            else
                task.wait(0.5)
            end
        end
    end)

    task.spawn(function()
        local t        = -1
        local lastTick = tick()
        local SPEED    = 0.6
        while true do
            local list = _G._FH_ESPGradients
            if list and #list > 0 then
                local now = tick()
                t = t + (now - lastTick) * SPEED
                lastTick = now
                if t > 1 then t = t - 2 end
                local n, w = #list, 0
                local vec = Vector2.new(t, 0)
                for r = 1, n do
                    local g = list[r]
                    if g and g.Parent then
                        w = w + 1
                        list[w] = g
                        g.Offset = vec
                    end
                end
                for i = n, w + 1, -1 do list[i] = nil end
                task.wait(1 / 30)
            else
                lastTick = tick()
                task.wait(0.5)
            end
        end
    end)
end
F = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
M = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
S = TweenInfo.new(0.5,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)
Tween = function(o, i, p) TweenService:Create(o, i, p):Play() end
Corner = function(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end
Stroke = function(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color           = col or T.Border
    s.Thickness       = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end
Padding = function(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.Parent = p
end
Label = function(p, txt, sz, col, font)
    local l = Instance.new("TextLabel")
    l.Text              = txt or ""

    local _szFinal = sz or 13
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        _szFinal = _szFinal + 4
    end
    l.TextSize          = _szFinal
    l.TextColor3        = col or T.White
    l.Font              = font or Enum.Font.GothamMedium
    l.BackgroundTransparency = 1
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.Parent            = p
    return l
end
GUI = Instance.new("ScreenGui")
GUI.Name           = "FadedHub"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn   = false
GUI.IgnoreGuiInset = true
if not pcall(function() GUI.Parent = game.CoreGui end) then
    GUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end
do
local _activeNotifs = {}
local NOTIF_W      = 200
local NOTIF_H      = 44
local NOTIF_GAP    = 6
local NOTIF_PAD_X  = 14
local NOTIF_PAD_Y  = 14
local NOTIF_DUR    = 2
local function _shadowTargetY(slotIdx)
    return -(NOTIF_PAD_Y + NOTIF_H + 4 + slotIdx * (NOTIF_H + NOTIF_GAP))
end
local function _repoAll(tweenInfo)
    for i, e in ipairs(_activeNotifs) do
        local slotIdx = i - 1
        TweenService:Create(e.shadow, tweenInfo, {
            Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(slotIdx))
        }):Play()
    end
end
ShowToggleNotification = function(toggleName, enabled, customDur)
    local statusTxt = enabled and "Enabled"or "Disabled"local statusCol = enabled
        and Color3.fromRGB(150, 255, 150)
        or  Color3.fromRGB(255, 100, 100)

    local _dur = NOTIF_DUR
    if type(toggleName) == "string" then
        local _u = toggleName:upper()
        if _u:find("CAN NOW", 1, true) and _u:find("TELEPORT", 1, true) then
            _dur = 60
        end
    end
    local IN_INFO   = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local OUT_INFO  = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local BAR_INFO  = TweenInfo.new(_dur, Enum.EasingStyle.Linear)
    local FADE_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
    local REPO_INFO = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local shadow = Instance.new("Frame")
    shadow.Name                   = "ToastShadow"
shadow.Size                   = UDim2.new(0, NOTIF_W + 8, 0, NOTIF_H + 8)
    shadow.Position               = UDim2.new(0, -(NOTIF_W + 32), 1, _shadowTargetY(0))
    shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.12
    shadow.BorderSizePixel        = 0
    shadow.ZIndex                 = 99
    shadow.Parent                 = GUI
    local _sc = Instance.new("UICorner"); _sc.CornerRadius = UDim.new(0, 12); _sc.Parent = shadow
    local toast = Instance.new("Frame")
    toast.Name                   = "ToastNotif"
toast.Size                   = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
    toast.Position               = UDim2.new(0, 4, 0, 4)
    toast.BackgroundColor3       = Color3.fromRGB(18, 18, 18)
    toast.BackgroundTransparency = 1
    toast.BorderSizePixel        = 0
    toast.ZIndex                 = 100
    toast.Parent                 = shadow
    local _tc = Instance.new("UICorner"); _tc.CornerRadius = UDim.new(0, 10); _tc.Parent = toast
    local _stroke = Instance.new("UIStroke")
    _stroke.Color        = Color3.fromRGB(55, 55, 55)
    _stroke.Thickness    = 1
    _stroke.Transparency = 1
    _stroke.Parent       = toast
    local pill = Instance.new("Frame")
    pill.Size                   = UDim2.new(0, 3, 0, NOTIF_H - 16)
    pill.Position               = UDim2.new(0, 9, 0.5, -(NOTIF_H - 16) / 2)
    pill.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    pill.BackgroundTransparency = 0.3
    pill.BorderSizePixel        = 0
    pill.ZIndex                 = 101
    pill.Parent                 = toast
    local _pc = Instance.new("UICorner"); _pc.CornerRadius = UDim.new(1, 0); _pc.Parent = pill
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size               = UDim2.new(1, -24, 0, 15)
    nameLabel.Position           = UDim2.new(0, 19, 0, 7)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text               = toggleName
    nameLabel.TextSize           = 11
    nameLabel.Font               = Enum.Font.GothamBold
    nameLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    nameLabel.TextTruncate       = Enum.TextTruncate.AtEnd
    nameLabel.TextTransparency   = 1
    nameLabel.ZIndex             = 101
    nameLabel.Parent             = toast
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size               = UDim2.new(1, -24, 0, 11)
    statusLabel.Position           = UDim2.new(0, 19, 0, 23)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text               = statusTxt
    statusLabel.TextSize           = 10
    statusLabel.Font               = Enum.Font.Gotham
    statusLabel.TextColor3         = statusCol
    statusLabel.TextXAlignment     = Enum.TextXAlignment.Left
    statusLabel.TextTransparency   = 1
    statusLabel.ZIndex             = 101
    statusLabel.Parent             = toast
    local barTrack = Instance.new("Frame")
    barTrack.Size             = UDim2.new(1, 0, 0, 2)
    barTrack.Position         = UDim2.new(0, 0, 1, -2)
    barTrack.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    barTrack.BorderSizePixel  = 0
    barTrack.ZIndex           = 101
    barTrack.Parent           = toast
    local _btc = Instance.new("UICorner"); _btc.CornerRadius = UDim.new(1, 0); _btc.Parent = barTrack
    local barFill = Instance.new("Frame")
    barFill.Size             = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    barFill.BorderSizePixel  = 0
    barFill.ZIndex           = 102
    barFill.Parent           = barTrack
    local _bfc = Instance.new("UICorner"); _bfc.CornerRadius = UDim.new(1, 0); _bfc.Parent = barFill
    local entry = { shadow = shadow }
    table.insert(_activeNotifs, 1, entry)
    _repoAll(REPO_INFO)
    TweenService:Create(shadow, IN_INFO, {
        Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(0))
    }):Play()
    TweenService:Create(toast,       IN_INFO, {BackgroundTransparency = 0}):Play()
    TweenService:Create(_stroke,     IN_INFO, {Transparency = 0.3}):Play()
    TweenService:Create(nameLabel,   IN_INFO, {TextTransparency = 0}):Play()
    TweenService:Create(statusLabel, IN_INFO, {TextTransparency = 0}):Play()
    task.delay(0.1, function()
        TweenService:Create(barFill, BAR_INFO, {Size = UDim2.new(0, 0, 1, 0)}):Play()
    end)
    task.delay(_dur + 0.15, function()
        for i, e in ipairs(_activeNotifs) do
            if e == entry then table.remove(_activeNotifs, i); break end
        end
        _repoAll(REPO_INFO)
        local exitY = shadow.Position.Y.Offset
        TweenService:Create(shadow, OUT_INFO, {
            Position = UDim2.new(0, -(NOTIF_W + 32), 1, exitY)
        }):Play()
        TweenService:Create(toast,       FADE_INFO, {BackgroundTransparency = 1}):Play()
        TweenService:Create(nameLabel,   FADE_INFO, {TextTransparency = 1}):Play()
        local tw = TweenService:Create(statusLabel, FADE_INFO, {TextTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function() shadow:Destroy() end)
    end)
end
end
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPhone = false
if isMobile then
    local _vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
    local _short = math.min(_vp.X, _vp.Y)
    isPhone = _short < 600
end
do
    if isPhone then

        WIN_W = 230
        WIN_H = 250
    elseif isMobile then
        WIN_W = 260
        WIN_H = 270
    else
        WIN_W = 320
        WIN_H = 320
    end
end
if isMobile then
    SS.W = 128; SS.H = 240
    SP.W = 130; SP.H = 124
    AB.W = 134; AB.H = 66
    UB.W = 144; UB.H = 62
end
BorderFrame = Instance.new("Frame")
BorderFrame.Name              = "GradBorder"
BorderFrame.Size              = UDim2.new(0, WIN_W + 10, 0, WIN_H + 10)
BorderFrame.Position          = UDim2.new(0.5, -(WIN_W + 10)/2, 0.5, -(WIN_H + 10)/2)
BorderFrame.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
BorderFrame.BackgroundTransparency = 1
BorderFrame.BorderSizePixel   = 0
BorderFrame.ZIndex            = 1
BorderFrame.Parent            = GUI
Corner(BorderFrame, 16)
_FH_AddThemeStrokeToFrame(BorderFrame, 4)
Win = Instance.new("Frame")
Win.Name             = "Win"
Win.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
Win.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Win.AnchorPoint      = Vector2.new(0, 0)
Win.BackgroundColor3 = T.BG
Win.BackgroundTransparency = 0.25
Win.BorderSizePixel  = 0
Win.ZIndex           = 2
Win.Parent           = GUI
Corner(Win, 12)
BANNER_W, BANNER_H = 280, 82
TopBanner = Instance.new("Frame")
TopBanner.Name                    = "FadedHubBanner"
TopBanner.Size                    = UDim2.new(0, BANNER_W, 0, BANNER_H)
TopBanner.Position                = UDim2.new(0.5, -BANNER_W / 2, 0, 45)
TopBanner.AnchorPoint             = Vector2.new(0, 0)
TopBanner.BackgroundColor3        = Color3.fromRGB(8, 8, 12)
TopBanner.BackgroundTransparency  = 0.45
TopBanner.BorderSizePixel         = 0
TopBanner.ZIndex                  = 50
TopBanner.Active                  = false
TopBanner.Visible                 = not isMobile
TopBanner.Parent                  = GUI
do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = TopBanner
end
BannerStrokeInst = Instance.new("UIStroke")
BannerStrokeInst.Thickness       = 2
BannerStrokeInst.Color           = Color3.fromRGB(255, 255, 255)
BannerStrokeInst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BannerStrokeInst.Parent          = TopBanner
_FH_AddThemeStroke(BannerStrokeInst)
BannerTitle = Instance.new("TextLabel")
BannerTitle.Name              = "BannerTitle"
BannerTitle.Text              = "FADED HUB V3"
BannerTitle.TextSize          = 20
BannerTitle.Font              = Enum.Font.GothamBold
BannerTitle.BackgroundTransparency = 1
BannerTitle.Size              = UDim2.new(1, 0, 0, 26)
BannerTitle.Position          = UDim2.new(0, 0, 0, 8)
BannerTitle.TextXAlignment    = Enum.TextXAlignment.Center
BannerTitle.TextYAlignment    = Enum.TextYAlignment.Center
BannerTitle.TextColor3        = Color3.fromRGB(255, 255, 255)
BannerTitle.ZIndex            = 51
BannerTitle.Parent            = TopBanner
BannerDev = Instance.new("TextLabel")
BannerDev.Name              = "BannerDev"
BannerDev.Text              = "@avi x @sheesh  -  dsc.gg/fadedhub"
BannerDev.TextSize          = 11
BannerDev.Font              = Enum.Font.GothamMedium
BannerDev.BackgroundTransparency = 1
BannerDev.Size              = UDim2.new(1, 0, 0, 18)
BannerDev.Position          = UDim2.new(0, 0, 0, 34)
BannerDev.TextXAlignment    = Enum.TextXAlignment.Center
BannerDev.TextYAlignment    = Enum.TextYAlignment.Center
BannerDev.TextColor3        = Color3.fromRGB(180, 180, 180)
BannerDev.ZIndex            = 51
BannerDev.Parent            = TopBanner
BannerStats = Instance.new("TextLabel")
BannerStats.Name              = "BannerStats"
BannerStats.Text              = "FPS: --   PING: --ms"
BannerStats.TextSize          = 12
BannerStats.Font              = Enum.Font.GothamBold
BannerStats.BackgroundTransparency = 1
BannerStats.Size              = UDim2.new(1, 0, 0, 18)
BannerStats.Position          = UDim2.new(0, 0, 0, 56)
BannerStats.TextXAlignment    = Enum.TextXAlignment.Center
BannerStats.TextYAlignment    = Enum.TextYAlignment.Center
BannerStats.TextColor3        = Color3.fromRGB(245, 245, 245)
BannerStats.ZIndex            = 51
BannerStats.Parent            = TopBanner
bannerAngle = 0
fpsClock    = 0
fpsFrames   = 0
displayFPS  = 0

if not isMobile then
do
local _lastBannerText = ""
RunService.Heartbeat:Connect(function(dt)
    fpsFrames = fpsFrames + 1
    fpsClock  = fpsClock  + dt
    if not TopBanner or not TopBanner.Visible then return end
    if fpsClock >= 1 then
        displayFPS = math.floor(fpsFrames / fpsClock)
        fpsFrames  = 0
        fpsClock   = 0
        local ping = math.floor((Players.LocalPlayer:GetNetworkPing() or 0) * 1000)
        local txt  = "FPS: ".. displayFPS .. "PING: ".. ping .. "ms"
        if txt ~= _lastBannerText then
            BannerStats.Text = txt
            _lastBannerText  = txt
        end
    end
end)
end
end
Hdr = Instance.new("Frame")
Hdr.Size             = UDim2.new(1, 0, 0, 40)
Hdr.BackgroundColor3 = T.Header
Hdr.BackgroundTransparency = 0.2
Hdr.BorderSizePixel  = 0
Hdr.ZIndex           = 5
Hdr.Parent           = Win
Corner(Hdr, 12)
Hdr.Active = true
HdrFill = Instance.new("Frame")
HdrFill.Size             = UDim2.new(1, 0, 0, 8)
HdrFill.Position         = UDim2.new(0, 0, 1, -8)
HdrFill.BackgroundColor3 = T.Header
HdrFill.BackgroundTransparency = 0.2
HdrFill.BorderSizePixel  = 0
HdrFill.ZIndex           = 5
HdrFill.Parent           = Hdr
HdrLine = Instance.new("Frame")
HdrLine.Size             = UDim2.new(1, 0, 0, 1)
HdrLine.Position         = UDim2.new(0, 0, 1, -1)
HdrLine.BackgroundColor3 = T.Border
HdrLine.BorderSizePixel  = 0
HdrLine.ZIndex           = 6
HdrLine.Parent           = Hdr
Dot = Instance.new("Frame")
Dot.Size             = UDim2.new(0, 10, 0, 10)
Dot.Position         = UDim2.new(0, 16, 0.5, -3)
Dot.BackgroundColor3 = T.White
Dot.BorderSizePixel  = 0
Dot.ZIndex           = 6
Dot.Parent           = Hdr
Corner(Dot, 4)
TitleLbl = Label(Hdr, "Faded Hub", 14, T.White, Enum.Font.GothamBold)
TitleLbl.Size     = UDim2.new(0, 160, 0, 20)
TitleLbl.Position = UDim2.new(0, 30, 0.5, -10)
TitleLbl.ZIndex   = 6
VerLbl = Label(Hdr, "v2.0", 10, T.Dim, Enum.Font.Gotham)
VerLbl.Size     = UDim2.new(0, 40, 0, 14)
VerLbl.Position = UDim2.new(0, 30, 0.5, 8)
VerLbl.ZIndex   = 6
do
local LockGuiBtn = Instance.new("TextButton")
LockGuiBtn.Name              = "LockGuiBtn"
LockGuiBtn.Size              = UDim2.new(0, 46, 0, 22)
LockGuiBtn.Position          = UDim2.new(1, -54, 0.5, -11)
LockGuiBtn.BackgroundColor3  = T.Card
LockGuiBtn.BorderSizePixel   = 0
LockGuiBtn.Text              = "FREE"
LockGuiBtn.TextSize          = 10
LockGuiBtn.Font              = Enum.Font.GothamBold
LockGuiBtn.TextColor3        = T.White
LockGuiBtn.ZIndex            = 7
LockGuiBtn.Active            = true
LockGuiBtn.AutoButtonColor   = false
LockGuiBtn.Parent            = Hdr
Corner(LockGuiBtn, 6)
local _lockBtnStroke = Stroke(LockGuiBtn, T.Border, 1)
_G._FH_GUI_LOCKED = false
LockGuiBtn.MouseButton1Click:Connect(function()
    _G._FH_GUI_LOCKED = not _G._FH_GUI_LOCKED
    if _G._FH_GUI_LOCKED then
        LockGuiBtn.Text             = "LOCK"
LockGuiBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
        _lockBtnStroke.Color        = Color3.fromRGB(200, 60, 60)
    else
        LockGuiBtn.Text             = "FREE"
LockGuiBtn.BackgroundColor3 = T.Card
        _lockBtnStroke.Color        = T.Border
    end
end)
end
do
    local dragging, dragStart, winStart
    Hdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            _G._FH_MAIN_DRAG = true
            dragStart = inp.Position
            winStart  = Win.Position
            if inp.UserInputType == Enum.UserInputType.Touch then
                pcall(function() game:GetService("UserInputService"):GetMouseDelta() end)
            end
        end
    end)
    Hdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false

            task.delay(0.05, function() _G._FH_MAIN_DRAG = false end)
            Config.mini = Config.mini or {}
            Config.mini.main_pos = {
                x  = Win.Position.X.Offset,
                y  = Win.Position.Y.Offset,
                xs = Win.Position.X.Scale,
                ys = Win.Position.Y.Scale,
            }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            local d      = inp.Position - dragStart
            local newPos = UDim2.new(
                winStart.X.Scale, winStart.X.Offset + d.X,
                winStart.Y.Scale, winStart.Y.Offset + d.Y
            )
            Win.Position         = newPos
            BorderFrame.Position = UDim2.new(
                newPos.X.Scale, newPos.X.Offset - 5,
                newPos.Y.Scale, newPos.Y.Offset - 5
            )
        end
    end)
end
TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1, 0, 0, 34)
TabBar.Position         = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
TabBar.BackgroundTransparency = 0.2
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 4
TabBar.Parent           = Win
TBLine = Instance.new("Frame")
TBLine.Size             = UDim2.new(1, 0, 0, 1)
TBLine.Position         = UDim2.new(0, 0, 0, 73)
TBLine.BackgroundColor3 = T.Border
TBLine.BorderSizePixel  = 0
TBLine.ZIndex           = 5
TBLine.Parent           = Win
TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection      = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabLayout.Padding             = UDim.new(0, 0)
TabLayout.Parent              = TabBar
do
local TabSizeConstraint = Instance.new("UISizeConstraint")
TabSizeConstraint.MaxSize = Vector2.new(WIN_W, 34)
TabSizeConstraint.Parent  = TabBar
end
ContentArea = Instance.new("Frame")
ContentArea.Size                = UDim2.new(1, 0, 1, -74)
ContentArea.Position            = UDim2.new(0, 0, 0, 74)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants    = true
ContentArea.ZIndex              = 2
ContentArea.Parent              = Win
CreateToggle = function(parent, name, desc, cb, actionFn)
    local state  = (Config.toggles[name] == true)
    local hasDesc = false
    desc = nil

    local cardH  = isMobile and (hasDesc and 50 or 32) or (hasDesc and 42 or 26)
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, -16, 0, cardH)
    card.BackgroundColor3 = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel  = 0
    card.Parent           = parent
    Corner(card, 8)
    local cStroke = Stroke(card, Color3.fromRGB(255, 255, 255), 1)
    _FH_AddThemeStroke(cStroke)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 0, cardH - 16)
    bar.Position         = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = T.TrackOff
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 2
    bar.Parent           = card
    Corner(bar, 2)
    local nameY  = hasDesc and 10 or (cardH/2 - 8)
    local nameLbl = Label(card, name, isMobile and 11 or 13, T.White, Enum.Font.GothamMedium)
    nameLbl.Size     = UDim2.new(1, -108, 0, 16)
    nameLbl.Position = UDim2.new(0, 14, 0, nameY)
    nameLbl.ZIndex   = 2
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    if hasDesc then
        local descLbl = Label(card, desc, isMobile and 9 or 11, T.Dim, Enum.Font.Gotham)
        descLbl.Size     = UDim2.new(1, -108, 0, 14)
        descLbl.Position = UDim2.new(0, 14, 0, nameY + 18)
        descLbl.ZIndex   = 2
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local kbLbl = Instance.new("TextLabel")
    kbLbl.Size              = UDim2.new(0, 32, 0, 16)
    kbLbl.Position          = UDim2.new(1, -92, 0.5, -8)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text              = ""
kbLbl.TextSize          = 10
    kbLbl.Font              = Enum.Font.GothamBold
    kbLbl.TextColor3        = T.Dim
    kbLbl.TextXAlignment    = Enum.TextXAlignment.Center
    kbLbl.ZIndex            = 3
    kbLbl.Parent            = card
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 28, 0, 16)
    track.Position         = UDim2.new(1, -32, 0.5, -6)
    track.BackgroundColor3 = T.TrackOff
    track.BorderSizePixel  = 0
    track.ZIndex           = 2
    track.Parent           = card
    Corner(track, 6)
    local tStroke = Stroke(track, T.Border, 1)
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.Position         = UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = T.KnobOff
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 3
    knob.Parent           = track
    Corner(knob, 4)
    local _cardHovered = false
    local function _cardSetHover(h)
        if h == _cardHovered then return end
        _cardHovered = h
        Tween(card, F, {BackgroundColor3 = h and T.CardHover or T.Card})
    end
    card.MouseEnter:Connect(function() _cardSetHover(true) end)
    card.MouseLeave:Connect(function() _cardSetHover(false) end)
    local btn = Instance.new("Frame")
    btn.Size                = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.ZIndex              = 4
    btn.Active              = true
    btn.Parent              = card
    btn.MouseEnter:Connect(function() _cardSetHover(true) end)
    btn.MouseLeave:Connect(function() _cardSetHover(false) end)
    local keybindEntry = { keyCode = nil }
    do
        local _saved = Config and Config.keybinds and Config.keybinds[name]
        if type(_saved) == "string" then
            local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
            if _ok and _kc then
                keybindEntry.keyCode = _kc
                kbLbl.Text       = "[" .. _saved .. "]"
                kbLbl.TextColor3 = T.Dim
            end
        end
    end
    local function applyVisual(s)
        if s then
            local _acA = _G._FH_AccentA or T.TrackOn
            local _acB = _G._FH_AccentB or T.TrackOn
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.Position         = UDim2.new(0, 14, 0.5, -6)
            knob.BackgroundColor3 = T.KnobOn
            track.BackgroundColor3 = _acA
            tStroke.Color         = _acB

            local _tg = track:FindFirstChildOfClass("UIGradient")
            if not _tg then
                _tg = Instance.new("UIGradient")
                _tg.Parent = track
                table.insert(_G._FH_ThemeFills, _tg)
            end
            if _FH_BuildThemeSequence then _tg.Color = _FH_BuildThemeSequence() end
            bar.BackgroundColor3  = _acA

            local _bg2 = bar:FindFirstChildOfClass("UIGradient")
            if not _bg2 then
                _bg2 = Instance.new("UIGradient")
                _bg2.Rotation = 90
                _bg2.Parent = bar
                table.insert(_G._FH_ThemeFills, _bg2)
            end
            if _FH_BuildThemeSequence then _bg2.Color = _FH_BuildThemeSequence() end
        else
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.Position         = UDim2.new(0, 2, 0.5, -6)
            knob.BackgroundColor3 = T.KnobOff
            track.BackgroundColor3 = T.TrackOff
            local _tg = track:FindFirstChildOfClass("UIGradient")
            if _tg then _tg:Destroy() end
            tStroke.Color         = T.Border
            bar.BackgroundColor3  = T.TrackOff
            local _bg2 = bar:FindFirstChildOfClass("UIGradient")
            if _bg2 then _bg2:Destroy() end
        end
    end
    local function doToggle()
        state = not state
        if state then
            local _acA = _G._FH_AccentA or T.TrackOn
            local _acB = _G._FH_AccentB or T.TrackOn
            Tween(knob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
            task.delay(0.06, function()
                Tween(knob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
                Tween(knob,    M, {BackgroundColor3 = T.KnobOn})
                Tween(track,   M, {BackgroundColor3 = _acA})
                Tween(tStroke, M, {Color = _acB})
                Tween(bar,     M, {BackgroundColor3 = _acA})

                pcall(function()
                    local _tg = track:FindFirstChildOfClass("UIGradient")
                    if not _tg then _tg = Instance.new("UIGradient"); _tg.Parent = track; table.insert(_G._FH_ThemeFills, _tg) end
                    if _FH_BuildThemeSequence then _tg.Color = _FH_BuildThemeSequence() end
                    local _bg2 = bar:FindFirstChildOfClass("UIGradient")
                    if not _bg2 then _bg2 = Instance.new("UIGradient"); _bg2.Rotation = 90; _bg2.Parent = bar; table.insert(_G._FH_ThemeFills, _bg2) end
                    if _FH_BuildThemeSequence then _bg2.Color = _FH_BuildThemeSequence() end
                end)
            end)
        else
            Tween(knob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
            task.delay(0.06, function()
                Tween(knob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
                Tween(knob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(track,   M, {BackgroundColor3 = T.TrackOff})
                Tween(tStroke, M, {Color = T.Border})
                Tween(bar,     M, {BackgroundColor3 = T.TrackOff})
                pcall(function()
                    local _tg = track:FindFirstChildOfClass("UIGradient")
                    if _tg then _tg:Destroy() end
                    local _bg2 = bar:FindFirstChildOfClass("UIGradient")
                    if _bg2 then _bg2:Destroy() end
                end)
            end)
        end
        if cb then pcall(cb, state) end
        Config.toggles[name] = state
        pcall(FH_SaveConfig)

            pcall(ShowToggleNotification, name, state)
    end
    local _btnTouchActive = false
    local _btnTouchStart  = nil
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _btnTouchActive = true
            _btnTouchStart  = inp.Position
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch) and _btnTouchActive then
            _btnTouchActive = false

            if _G._FH_MAIN_DRAG or _G._FH_SPAM_DRAG or _G._FH_MP_DRAG then
                _btnTouchStart = nil
                return
            end
            if _btnTouchStart and (inp.Position - _btnTouchStart).Magnitude < 20 then
                doToggle()
            end
            _btnTouchStart = nil
        end
    end)
    local kb2Debounce = false
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if kb2Debounce then return end
        kb2Debounce = true
        task.delay(0.2, function() kb2Debounce = false end)
        if keybindBindingTarget then
            local prev = keybindBindingTarget
            keybindBindingTarget = nil
            if prev.kbLbl == kbLbl then
                kbLbl.Text      = keybindEntry.keyCode and ("[".. keybindEntry.keyCode.Name .. "]") or ""
kbLbl.TextColor3 = T.Dim
                return
            else
                prev.kbLbl.Text      = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
            end
        end
        kbLbl.Text           = "(...)"
kbLbl.TextColor3     = T.White
        keybindBindingTarget = { entry = keybindEntry, kbLbl = kbLbl, mode = "assign"}
    end)
    table.insert(keybindEntries, { entry = keybindEntry, fire = (actionFn or doToggle), kbLbl = kbLbl })
    do
        local _themeFn = function()
            if state then applyVisual(true) end
        end
        table.insert(_G._FH_ThemeCallbacks, _themeFn)
        pcall(_themeFn)
    end
    configRegistry[name] = {
        getState   = function() return state end,
        getKeyCode = function() return keybindEntry.keyCode end,
        setKeyCode = function(kc)
            keybindEntry.keyCode = kc
            if kc then
                kbLbl.Text       = "[".. kc.Name .. "]"
kbLbl.TextColor3 = T.Dim
                Config.keybinds[name] = kc.Name
            else
                kbLbl.Text = ""
kbLbl.TextColor3 = T.Dim
Config.keybinds[name] = nil
            end
            pcall(FH_SaveConfig)
        end,
        doToggle   = doToggle,
        kbLbl      = kbLbl,
        kbEntry    = keybindEntry,
        setEnabled = function(v)
            local wasState = state
            state = v
            applyVisual(v)
            Config.toggles[name] = v

            if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
            if cb then pcall(cb, v) end
        end,
    }
end
UserInputService.InputBegan:Connect(function(inp, gpe)
    if keybindBindingTarget then
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            local kc = inp.KeyCode
            if kc == Enum.KeyCode.Escape then
                local _tgt = keybindBindingTarget
                if _tgt.entry.keyCode then
                    _tgt.kbLbl.Text      = "[".. _tgt.entry.keyCode.Name .. "]"
_tgt.kbLbl.TextColor3 = T.Dim
                else
                    _tgt.kbLbl.Text = ""
                    end
                if _tgt.onSet and _tgt.entry.keyCode then _tgt.onSet()
                elseif _tgt.onClear then _tgt.onClear() end
                keybindBindingTarget = nil
            elseif kc == Enum.KeyCode.Backspace then
                local _tgt = keybindBindingTarget
                local clearedEntry = _tgt.entry
                clearedEntry.keyCode                  = nil
                _tgt.kbLbl.Text       = ""
_tgt.kbLbl.TextColor3 = T.Dim
                if _tgt.onClear then _tgt.onClear() end
                for tName, reg in pairs(configRegistry) do
                    if reg.getKeyCode and reg.getKeyCode() == nil then
                        Config.keybinds[tName] = nil
                    end
                end
                if clearedEntry == SP.entry then
                    Config.mini = Config.mini or {}
                    Config.mini.sp_keybind = nil
                end
                pcall(FH_SaveConfig)
                keybindBindingTarget = nil
            else
                local _tgt = keybindBindingTarget
                local assignedEntry = _tgt.entry
                assignedEntry.keyCode                 = kc
                _tgt.kbLbl.Text       = "[".. kc.Name .. "]"
_tgt.kbLbl.TextColor3 = T.Dim
                if _tgt.onSet then _tgt.onSet() end

                local matched = 0
                for tName, reg in pairs(configRegistry) do
                    local sameEntry = false
                    if reg.getKeyCode then
                        local ok, regKc = pcall(reg.getKeyCode)
                        if ok and regKc == kc then sameEntry = true end
                    end
                    if sameEntry then
                        Config.keybinds[tName] = kc.Name
                        if reg.setKeyCode then pcall(reg.setKeyCode, kc) end
                        matched = matched + 1
                    end
                end
                if assignedEntry == SP.entry then
                    Config.mini = Config.mini or {}
                    Config.mini.sp_keybind = kc.Name
                end
                pcall(FH_SaveConfig)
                pcall(function()
                    ShowToggleNotification("Keybind ["..kc.Name.."] bound ("..matched..")", true)
                end)
                keybindBindingTarget = nil
            end
            return
        elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
            local prev = keybindBindingTarget
            keybindBindingTarget = nil
            if prev.entry.keyCode then
                prev.kbLbl.Text      = "[".. prev.entry.keyCode.Name .. "]"
prev.kbLbl.TextColor3 = T.Dim
            else
                prev.kbLbl.Text = ""
                end
        end
        return
    end
    if gpe then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard then
        local _fired = {}
        for _, binding in ipairs(keybindEntries) do
            if binding and binding.entry and binding.entry.keyCode
               and inp.KeyCode == binding.entry.keyCode and binding.fire
               and not _fired[binding.fire] then
                _fired[binding.fire] = true
                pcall(binding.fire)
            end
        end
    end
end)
CreateSection = function(parent, title)
    local f = Instance.new("Frame")
    f.Size                = UDim2.new(1, -16, 0, 30)
    f.BackgroundTransparency = 1
    f.Parent              = parent
    local line = Instance.new("Frame")
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = T.Border
    line.BorderSizePixel  = 0
    line.Parent           = f
    local pill = Instance.new("Frame")
    pill.Size             = UDim2.new(0, #title * 7 + 18, 0, 20)
    pill.Position         = UDim2.new(0, 10, 0.5, -10)
    pill.BackgroundTransparency = 1
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 2
    pill.Parent           = f
    local lbl = Label(pill, title, 10, T.Dim, Enum.Font.GothamBold)
    lbl.Size             = UDim2.new(1, 0, 1, 0)
    lbl.TextXAlignment   = Enum.TextXAlignment.Center
    lbl.ZIndex           = 3
end
local CreateButton
CreateButton = function(parent, name, desc, cb)
    local hasDesc = false
    desc = nil
    local cardH   = isMobile and (hasDesc and 48 or 32) or (hasDesc and 42 or 26)
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, -16, 0, cardH)
    card.BackgroundColor3 = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel  = 0
    card.Parent           = parent
    Corner(card, 8)
    local cStroke = Stroke(card, Color3.fromRGB(255, 255, 255), 1)
    _FH_AddThemeStroke(cStroke)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 0, cardH - 16)
    bar.Position         = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = T.TrackOff
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 2
    bar.Parent           = card
    Corner(bar, 2)
    local nameY  = hasDesc and 10 or (cardH/2 - 8)
    local nameLbl = Label(card, name, 13, T.White, Enum.Font.GothamMedium)
    nameLbl.Size     = UDim2.new(1, -100, 0, 16)
    nameLbl.Position = UDim2.new(0, 14, 0, nameY)
    nameLbl.ZIndex   = 2
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    if hasDesc then
        local descLbl = Label(card, desc, 11, T.Dim, Enum.Font.Gotham)
        descLbl.Size     = UDim2.new(1, -100, 0, 14)
        descLbl.Position = UDim2.new(0, 14, 0, nameY + 18)
        descLbl.ZIndex   = 2
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local kbLbl = Instance.new("TextLabel")
    kbLbl.Size                  = UDim2.new(0, 36, 0, 16)
    kbLbl.Position              = UDim2.new(1, -92, 0.5, -8)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text                  = ""
kbLbl.TextSize              = 10
    kbLbl.Font                  = Enum.Font.GothamBold
    kbLbl.TextColor3            = T.Dim
    kbLbl.TextXAlignment        = Enum.TextXAlignment.Center
    kbLbl.ZIndex                = 3
    kbLbl.Parent                = card
    local runLbl = Instance.new("TextLabel")
    runLbl.Size                  = UDim2.new(0, 28, 0, 14)
    runLbl.Position              = UDim2.new(1, -36, 0.5, -7)
    runLbl.BackgroundColor3      = Color3.fromRGB(38, 38, 38)
    runLbl.BorderSizePixel       = 0
    runLbl.Text                  = "RUN"
runLbl.TextSize              = 9
    runLbl.Font                  = Enum.Font.GothamBold
    runLbl.TextColor3            = T.White
    runLbl.TextXAlignment        = Enum.TextXAlignment.Center
    runLbl.ZIndex                = 3
    runLbl.Parent                = card
    Corner(runLbl, 6)
    Stroke(runLbl, T.Border, 1)
    local _cardHovered = false
    local function _cardSetHover(h)
        if h == _cardHovered then return end
        _cardHovered = h
        Tween(card, F, {BackgroundColor3 = h and T.CardHover or T.Card})
    end
    card.MouseEnter:Connect(function() _cardSetHover(true) end)
    card.MouseLeave:Connect(function() _cardSetHover(false) end)
    local btn = Instance.new("Frame")
    btn.Size                = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.ZIndex              = 4
    btn.Active              = true
    btn.Parent              = card
    btn.MouseEnter:Connect(function() _cardSetHover(true) end)
    btn.MouseLeave:Connect(function() _cardSetHover(false) end)
    local keybindEntry = { keyCode = nil }
    do
        local _saved = Config and Config.keybinds and Config.keybinds[name]
        if type(_saved) == "string" then
            local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
            if _ok and _kc then
                keybindEntry.keyCode = _kc
                kbLbl.Text       = "[" .. _saved .. "]"
                kbLbl.TextColor3 = T.Dim
            end
        end
    end
    local function fireButton()
        Tween(bar,    F, {BackgroundColor3 = T.TrackOn})
        Tween(runLbl, F, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
        task.spawn(function()
            pcall(cb)
        end)
        task.delay(0.35, function()
            Tween(bar,    M, {BackgroundColor3 = T.TrackOff})
            Tween(runLbl, M, {BackgroundColor3 = Color3.fromRGB(38, 38, 38)})
        end)
    end
    local debounce = false
    local _actTouchStart = nil
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            if debounce then return end
            debounce = true
            fireButton()
            task.delay(0.4, function() debounce = false end)
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _actTouchStart = inp.Position
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == kbLbl then
                    kbLbl.Text       = keybindEntry.keyCode and ("[".. keybindEntry.keyCode.Name .. "]") or ""
kbLbl.TextColor3 = T.Dim
                    return
                else
                    prev.kbLbl.Text       = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
                end
            end
            kbLbl.Text           = "(...)"
kbLbl.TextColor3     = T.White
            keybindBindingTarget = { entry = keybindEntry, kbLbl = kbLbl, mode = "assign"}
        end
    end)
    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _actTouchStart then
            local mag = (inp.Position - _actTouchStart).Magnitude
            local _start = _actTouchStart
            _actTouchStart = nil

            if _G._FH_MAIN_DRAG or _G._FH_SPAM_DRAG or _G._FH_MP_DRAG then
                return
            end
            if mag < 20 then
                if debounce then return end
                debounce = true
                fireButton()
                task.delay(0.4, function() debounce = false end)
            end
        end
    end)
    table.insert(keybindEntries, { entry = keybindEntry, fire = fireButton, kbLbl = kbLbl })
    configRegistry[name] = {
        getState   = function() return false end,
        getKeyCode = function() return keybindEntry.keyCode end,
        setKeyCode = function(kc)
            keybindEntry.keyCode = kc
            if kc then
                kbLbl.Text       = "[".. kc.Name .. "]"
kbLbl.TextColor3 = T.Dim
                Config.keybinds[name] = kc.Name
            else
                kbLbl.Text = ""
kbLbl.TextColor3 = T.Dim
                Config.keybinds[name] = nil
            end
            pcall(FH_SaveConfig)
        end,
        doToggle   = fireButton,
        kbLbl      = kbLbl,
        kbEntry    = keybindEntry,
    }
end
MakeScroll = function(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size                  = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel       = 0
    s.ScrollBarThickness    = 3
    s.ScrollBarImageColor3  = Color3.fromRGB(75, 75, 75)
    s.CanvasSize            = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    s.ScrollingDirection    = Enum.ScrollingDirection.Y
    s.ZIndex                = 2
    s.Parent                = parent
    local layout = Instance.new("UIListLayout")
    layout.FillDirection      = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding            = UDim.new(0, 6)
    layout.Parent             = s
    Padding(s, 10, 10, 8, 8)
    return s
end
Tabs      = {}
ActiveTab = nil
TabSwiping = false
TabIndex = function(tab)
    for i, t in ipairs(Tabs) do
        if t == tab then return i end
    end
    return 0
end
SLIDE_IN  = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
SLIDE_OUT = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
ActivateTab = function(tab)
    if ActiveTab == tab then return end
    if TabSwiping then return end
    local oldTab = ActiveTab
    ActiveTab = tab
    if oldTab then
        Tween(oldTab.lbl, F, {TextColor3 = Color3.fromRGB(210, 225, 255)})
        Tween(oldTab.btn, F, {BackgroundColor3 = Color3.fromRGB(23, 26, 36)})
    end
    Tween(tab.lbl, F, {TextColor3 = Color3.fromRGB(245, 248, 255)})
    Tween(tab.btn, F, {BackgroundColor3 = Color3.fromRGB(70, 80, 110)})
    if oldTab then
        TabSwiping = true
        local goingRight = (TabIndex(tab) > TabIndex(oldTab))
        tab.page.Position = goingRight and UDim2.new(1, 0, 0, 0) or UDim2.new(-1, 0, 0, 0)
        tab.page.Visible  = true
        local exitPos = goingRight and UDim2.new(-1, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
        Tween(oldTab.page, SLIDE_OUT, {Position = exitPos})
        local tw = TweenService:Create(tab.page, SLIDE_IN, {Position = UDim2.new(0, 0, 0, 0)})
        tw:Play()
        tw.Completed:Connect(function()
            oldTab.page.Visible  = false
            oldTab.page.Position = UDim2.new(0, 0, 0, 0)
            TabSwiping = false
        end)
    else
        tab.page.Position = UDim2.new(0, 0, 0, 0)
        tab.page.Visible  = true
    end
end
TAB_W = math.floor(WIN_W / 4)
CreateTab = function(name)
    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(0.25, -4, 1, -6)
    btn.Position            = UDim2.new(0, 2, 0, 3)
    btn.BackgroundColor3    = Color3.fromRGB(23, 26, 36)
    btn.BackgroundTransparency = 0
    btn.AutoButtonColor     = false
    btn.Text                = ""
    btn.ZIndex              = 5
    btn.Parent              = TabBar
    Corner(btn, 10)
    local nameLbl = Label(btn, name, isMobile and 11 or 10, Color3.fromRGB(210, 225, 255), Enum.Font.GothamBold)
    nameLbl.Size            = UDim2.new(1, -2, 1, 0)
    nameLbl.Position        = UDim2.new(0, 1, 0, 0)
    nameLbl.TextXAlignment  = Enum.TextXAlignment.Center
    nameLbl.TextWrapped     = true
    nameLbl.ZIndex          = 6
    nameLbl.TextScaled      = false
    local nameSC = Instance.new("UITextSizeConstraint")
    nameSC.MaxTextSize = isMobile and 8 or 11
    nameSC.MinTextSize = 5
    nameSC.Parent      = nameLbl
    local indicator = Instance.new("Frame")
    indicator.Size             = UDim2.new(0, 0, 0, 0)
    indicator.Visible          = false
    indicator.Parent           = btn
    local page = Instance.new("Frame")
    page.Size                = UDim2.new(1, 0, 1, 0)
    page.Position            = UDim2.new(0, 0, 0, 0)
    page.BackgroundTransparency = 1
    page.Visible             = false
    page.ClipsDescendants    = true
    page.ZIndex              = 2
    page.Parent              = ContentArea
    local scroll = MakeScroll(page)
    local tab = { btn = btn, lbl = nameLbl, indicator = indicator, page = page, scroll = scroll }
    btn.MouseButton1Click:Connect(function() ActivateTab(tab) end)
    table.insert(Tabs, tab)
    return tab
end
CombatTab   = CreateTab(isMobile and "MAIN" or "Faded [MAIN]")
VisualTab   = CreateTab(isMobile and "ESP" or "Visuals [ESP]")
PlayerTab   = CreateTab(isMobile and "PLAYER" or "My User [PLAYER]")
MiscTab     = CreateTab(isMobile and "MISC" or "Other [MISC]")

CreateSection(CombatTab.scroll, "AUTO STEALERS")
do
    local v1BestEnabled = false
    local v1NearestEnabled = false
    local v1PriorityEnabled = false
    local v1Running = false
    local _agInRange = false
    local V1_RED_PHASE        = 1.5
    local V1_PROXIMITY_RADIUS = 10
    local v1Progress = 0
    local v1HasTarget = false
    local v1TargetName = ""
    local v1TargetRate = ""
    task.defer(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "FH_AutoGrabProgress"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset = true
        pcall(function() gui.Parent = game:GetService("CoreGui") end)
        if not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

        local _agBarDefaultPos = UDim2.new(0.5, 0, 1, -80)
        local _agBarSavedPos = (Config.sliders and Config.sliders.ag_bar_pos)
        local _agBarInitPos = _agBarDefaultPos
        if type(_agBarSavedPos) == "table" then
            pcall(function()
                _agBarInitPos = UDim2.new(
                    _agBarSavedPos.xs or 0.5, _agBarSavedPos.xo or 0,
                    _agBarSavedPos.ys or 1,   _agBarSavedPos.yo or -80
                )
            end)
        end

        local frame = Instance.new("Frame")
        frame.AnchorPoint            = Vector2.new(0.5, 1)
        frame.Position               = _agBarInitPos
        frame.Size                   = UDim2.new(0, 200, 0, 50)
        frame.BackgroundColor3       = Color3.fromRGB(18, 18, 22)
        frame.BackgroundTransparency = 0.05
        frame.BorderSizePixel        = 0
        frame.Visible                = false
        frame.Parent                 = gui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local fs = Instance.new("UIStroke", frame)
        fs.Color        = Color3.fromRGB(255, 255, 255)
        fs.Transparency = 0.55
        fs.Thickness    = 1

        do
            local dragging = false
            local dragStartPos = nil
            local frameStartPos = nil


            local function onDragMoved(inputPos)
                if not dragging then return end
                local delta = inputPos - dragStartPos
                local vp = gui.AbsoluteSize
                frame.Position = UDim2.new(
                    frameStartPos.X.Scale + delta.X / vp.X,
                    frameStartPos.X.Offset,
                    frameStartPos.Y.Scale + delta.Y / vp.Y,
                    frameStartPos.Y.Offset
                )
            end

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                    onDragMoved(Vector2.new(input.Position.X, input.Position.Y))
                end
            end)
        end

        local title = Instance.new("TextLabel")
        title.AnchorPoint            = Vector2.new(0.5, 0)
        title.Position               = UDim2.new(0.5, 0, 0, 4)
        title.Size                   = UDim2.new(1, -12, 0, 14)
        title.BackgroundTransparency = 1
        title.Text                   = "Auto Grab (searching)"
        title.TextSize               = 11
        title.Font                   = Enum.Font.GothamBold
        title.TextColor3             = Color3.fromRGB(245, 245, 245)
        title.TextXAlignment         = Enum.TextXAlignment.Center
        title.TextYAlignment         = Enum.TextYAlignment.Center
        title.TextTruncate           = Enum.TextTruncate.AtEnd
        title.Parent                 = frame

        local div = Instance.new("Frame")
        div.AnchorPoint      = Vector2.new(0.5, 0)
        div.Position         = UDim2.new(0.5, 0, 0, 21)
        div.Size             = UDim2.new(1, -12, 0, 1)
        div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        div.BackgroundTransparency = 0.85
        div.BorderSizePixel  = 0
        div.Parent           = frame

        local barH = 18
        local track = Instance.new("Frame")
        track.AnchorPoint            = Vector2.new(0.5, 1)
        track.Position               = UDim2.new(0.5, 0, 1, -6)
        track.Size                   = UDim2.new(1, -12, 0, barH)
        track.BackgroundColor3       = Color3.fromRGB(30, 30, 36)
        track.BackgroundTransparency = 0.05
        track.BorderSizePixel        = 0
        track.ClipsDescendants       = true
        track.Parent                 = frame
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 6)
        local trackStroke = Instance.new("UIStroke", track)
        trackStroke.Color        = Color3.fromRGB(255, 255, 255)
        trackStroke.Transparency = 0.75
        trackStroke.Thickness    = 1

        local fill = Instance.new("Frame")
        fill.AnchorPoint            = Vector2.new(0, 0.5)
        fill.Position               = UDim2.new(0, 0, 0.5, 0)
        fill.Size                   = UDim2.new(0, 0, 1, 0)

        fill.BackgroundColor3       = _G._FH_AccentA or Color3.fromRGB(60, 210, 100)
        fill.BorderSizePixel        = 0
        fill.ZIndex                 = 1
        fill.Parent                 = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)
        local fillGrad = Instance.new("UIGradient", fill)

        fillGrad.Color    = _FH_BuildThemeSequence and _FH_BuildThemeSequence()
                            or ColorSequence.new(Color3.fromRGB(120, 200, 255))
        fillGrad.Rotation = 0
        _G._FH_ThemeFills = _G._FH_ThemeFills or {}
        table.insert(_G._FH_ThemeFills, fillGrad)

        _G._FH_ThemeCallbacks = _G._FH_ThemeCallbacks or {}
        do
            local _themeFn = function()
                pcall(function()
                    if fill and fill.Parent then
                        fill.BackgroundColor3 = _G._FH_AccentA or Color3.fromRGB(60, 210, 100)
                    end
                end)
            end
            table.insert(_G._FH_ThemeCallbacks, _themeFn)
            pcall(_themeFn)
        end

        local pctLbl = Instance.new("TextLabel")
        pctLbl.AnchorPoint            = Vector2.new(0.5, 0.5)
        pctLbl.Position               = UDim2.new(0.5, 0, 0.5, 0)
        pctLbl.Size                   = UDim2.new(1, -8, 1, 0)
        pctLbl.BackgroundTransparency = 1
        pctLbl.Text                   = "0%"
        pctLbl.TextSize               = 10
        pctLbl.Font                   = Enum.Font.GothamBold
        pctLbl.TextColor3             = Color3.fromRGB(245, 245, 245)
        pctLbl.TextStrokeTransparency = 0.5
        pctLbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        pctLbl.ZIndex                 = 3
        pctLbl.Parent                 = track
        _G._FH_HideAutoGrabBar = _G._FH_HideAutoGrabBar or false
        local fillTween = nil
        local lastTweenP = -1
        local _agBarTimer = 0
        RunService.Heartbeat:Connect(function(dt)
            _agBarTimer = _agBarTimer + dt
            if _agBarTimer < 0.033 then return end
            _agBarTimer = 0
            local on = (v1BestEnabled or v1NearestEnabled or v1PriorityEnabled) and not _G._FH_HideAutoGrabBar
            frame.Visible = on
            if not on then return end
            local p = math.clamp(v1Progress or 0, 0, 1)
            if math.abs(p - lastTweenP) > 0.005 then
                lastTweenP = p
                if fillTween then pcall(function() fillTween:Cancel() end) end
                fillTween = TweenService:Create(
                    fill,
                    TweenInfo.new(0.12, Enum.EasingStyle.Linear),
                    { Size = UDim2.new(p, 0, 1, 0) }
                )
                fillTween:Play()
            end
            if p >= 0.5 then
                fill.BackgroundColor3 = Color3.fromRGB(60, 230, 100)
            else
                fill.BackgroundColor3 = Color3.fromRGB(230, 70, 70)
            end
            pctLbl.Text = string.format("%d%%", math.floor(p * 100 + 0.5))

            if p >= 0.55 then
                pctLbl.TextColor3             = Color3.fromRGB(20, 20, 20)
                pctLbl.TextStrokeTransparency = 0.85
            else
                pctLbl.TextColor3             = Color3.fromRGB(245, 245, 245)
                pctLbl.TextStrokeTransparency = 0.5
            end
            if v1HasTarget and v1TargetName ~= "" then
                if v1TargetRate ~= "" then
                    title.Text = v1TargetName .. " - " .. v1TargetRate
                else
                    title.Text = v1TargetName
                end
            else
                local nearest, nearestDist = _FH_AG_GetNearestBrainrot()
                if nearest then
                    local nm = tostring(nearest.displayName or "")
                    if nm == "" then nm = "Brainrot" end
                    local rate = tostring(nearest.genText or "")
                    if rate:sub(1, 1) == "$" then rate = rate:sub(2) end
                    if rate ~= "" then
                        title.Text = string.format("Nearest: %s (%dm) - %s", nm, math.floor(nearestDist or 0 + 0.5), rate)
                    else
                        title.Text = string.format("Nearest: %s (%dm)", nm, math.floor(nearestDist or 0 + 0.5))
                    end
                else
                    title.Text = "NO ANIMALS NEARBY"
                end
            end
        end)
    end)
    local function v1PickTarget()
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, math.huge end
        if v1PriorityEnabled then
            local pset = _G._FH_PRIORITY_STEAL
            if not (pset and next(pset)) then return nil, math.huge end
            local best, bestDist = nil, math.huge
            for _, brainrot in ipairs(_FH_AG_CachedBrainrots) do
                if brainrot.displayName and pset[brainrot.displayName] then
                    local d = (brainrot.pos - hrp.Position).Magnitude
                    if d < bestDist then bestDist = d; best = brainrot end
                end
            end
            return best, bestDist
        end
        if v1BestEnabled then
            local best = _FH_AG_CachedBrainrots[1]
            if best then
                return best, (best.pos - hrp.Position).Magnitude
            end
        end
        if v1NearestEnabled then
            return _FH_AG_GetNearestBrainrot()
        end
        return nil, math.huge
    end

    local AG_HOLD_MIN     = 1.3
    local AG_HOLD_MAX     = 2.6
    local AG_ENTRY_DELAY  = 0.3
    local AG_STEAL_RANGE  = 10
    local AG_PRIME_RANGE  = 30
    local AG_POTION_RANGE = 6
    local AG_COOLDOWN     = 0.05

    local _agStealCache = {}

    local function _agBuildCallbacks(prompt)
        if _agStealCache[prompt] then return end
        local data = { hold = {}, trig = {}, ready = true }
        pcall(function()
            local conns = getconnections(prompt.PromptButtonHoldBegan)
            for _, c in ipairs(conns) do
                if type(c.Function) == "function" then table.insert(data.hold, c.Function) end
            end
        end)
        pcall(function()
            local conns = getconnections(prompt.Triggered)
            for _, c in ipairs(conns) do
                if type(c.Function) == "function" then table.insert(data.trig, c.Function) end
            end
        end)
        if #data.hold > 0 or #data.trig > 0 then
            _agStealCache[prompt] = data
        end
    end

    local function _agDistTo(target)
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not target or not target.pos then return math.huge end
        return (hrp.Position - target.pos).Magnitude
    end

    local function v1Loop()
        if v1Running then return end
        v1Running = true
        while v1BestEnabled or v1NearestEnabled or v1PriorityEnabled do
            local target = v1PickTarget()
            local prompt = target and target.prompt
            if not (target and prompt and prompt.Parent and _agDistTo(target) <= AG_PRIME_RANGE) then
                _agInRange = false
                task.wait(0.1)
                continue
            end

            _agBuildCallbacks(prompt)
            local data = _agStealCache[prompt]
            if not data or not data.ready then
                task.wait(0.05)
                continue
            end
            data.ready = false

            v1HasTarget   = true
            v1TargetName  = tostring(target.displayName or "")
            local rate    = tostring(target.genText or "")
            if rate:sub(1, 1) == "$" then rate = rate:sub(2) end
            v1TargetRate  = rate
            v1Progress    = 0

            local startT = tick()

            for _, fn in ipairs(data.hold) do task.spawn(fn) end

            while tick() - startT < AG_HOLD_MIN do
                if not (v1BestEnabled or v1NearestEnabled or v1PriorityEnabled) then break end
                v1Progress = math.min((tick() - startT) / AG_HOLD_MAX, 0.5)
                RunService.RenderStepped:Wait()
            end

            local alreadyInRange = _agDistTo(target) <= AG_STEAL_RANGE
            _agInRange = alreadyInRange
            local fired = false
            local potionFired = false
            while tick() - startT < AG_HOLD_MAX do
                if not (v1BestEnabled or v1NearestEnabled or v1PriorityEnabled) then break end
                if not prompt.Parent then break end

                local inRange = _agDistTo(target) <= AG_STEAL_RANGE
                _agInRange = inRange
                if inRange then
                    if not alreadyInRange then task.wait(AG_ENTRY_DELAY) end
                    if V3.potionOn and not potionFired
                        and _agDistTo(target) <= AG_POTION_RANGE
                        and _FH_IsPlayerInEnemyPlot() then
                        potionFired = true
                        pcall(_activateGiantPotion)
                        task.wait(0.05)
                    end
                    for _, fn in ipairs(data.trig) do task.spawn(fn) end
                    fired = true
                    break
                end
                v1Progress = (tick() - startT) / AG_HOLD_MAX
                RunService.RenderStepped:Wait()
            end

            v1Progress    = 1
            task.wait(AG_COOLDOWN)
            v1Progress    = 0
            v1HasTarget   = false
            v1TargetName  = ""
            v1TargetRate  = ""
            _agInRange    = false
            data.ready    = true
        end
        _agInRange = false
        v1Progress    = 0
        v1HasTarget   = false
        v1TargetName  = ""
        v1TargetRate  = ""
        v1Running     = false
    end
    local function _disableOther(name)
        local reg = configRegistry[name]
        if reg and reg.getState and reg.getState() and reg.setEnabled then
            pcall(reg.setEnabled, false)
        end
    end
    ToggleHandlers.auto_grab_best = function(state)
        v1BestEnabled = state and true or false
        if state then
            v1NearestEnabled  = false
            v1PriorityEnabled = false
            _disableOther("Auto Grab Nearest")
            _disableOther("Steal Priority")
            task.spawn(v1Loop)
        end
    end
    ToggleHandlers.auto_grab_nearest = function(state)
        v1NearestEnabled = state and true or false
        if state then
            v1BestEnabled     = false
            v1PriorityEnabled = false
            _disableOther("Auto Grab Best")
            _disableOther("Steal Priority")
            task.spawn(v1Loop)
        end
    end
    ToggleHandlers.steal_priority = function(state)
        v1PriorityEnabled = state and true or false
        if state then
            v1BestEnabled    = false
            v1NearestEnabled = false
            _disableOther("Auto Grab Best")
            _disableOther("Auto Grab Nearest")
            task.spawn(v1Loop)
        end
    end
    CreateToggle(CombatTab.scroll, "Auto Grab Best",     "Grabs the highest gen brainrot in range.",  function(v) ToggleHandlers.auto_grab_best(v) end)
    CreateToggle(CombatTab.scroll, "Auto Grab Nearest",  "Grabs the nearest brainrot in range.",      function(v) ToggleHandlers.auto_grab_nearest(v) end)
    CreateToggle(CombatTab.scroll, "Steal Priority",     "Auto-grabs only whitelisted brainrots (Priority Steal).", function(v) ToggleHandlers.steal_priority(v) end)
end

CreateSection(CombatTab.scroll, "MAIN")
CreateToggle(CombatTab.scroll, "Allow Base Panel",   "Toggle open your base from anywhere",       function(v) AB.setAllowBasePanelVisible(v) end, function()
    if AB and AB.fireAllow then pcall(AB.fireAllow) end
end)
CreateToggle(CombatTab.scroll, "Unlock Base Panel",  "Unlock a nearest player's base",            function(v) UB.setUnlockBasePanelVisible(v) end, function()
    if UB and UB.floors and UB.floors[1] and UB.triggerFloor then
        task.spawn(UB.triggerFloor, UB.floors[1].yLevel, UB.floors[1].maxY)
    end
end)
CreateToggle(CombatTab.scroll, "Potion Speed", "Auto-applies 34 speed when giant potion is active on your character", function(v)
    if _G._FH_PotionSpeedConn then _G._FH_PotionSpeedConn:Disconnect(); _G._FH_PotionSpeedConn = nil end
    if _G._FH_PotionSpeedCharConn then _G._FH_PotionSpeedCharConn:Disconnect(); _G._FH_PotionSpeedCharConn = nil end
    if not v then
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and _G._FH_PotionSpeedActive then
            hrp.Velocity = _G._FH_PotionSpeedBaseVelocity or hrp.Velocity
        end
        _G._FH_PotionSpeedActive = false
        _G._FH_PotionSpeedBaseVelocity = nil
        return
    end
    local SCALE_THRESHOLD = 1.05
    _G._FH_PotionSpeedActive = false
    local function setupChar(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            _G._FH_PotionSpeedBaseVelocity = hrp.Velocity
        end
        _G._FH_PotionSpeedActive = false
    end
    if Player.Character then setupChar(Player.Character) end
    _G._FH_PotionSpeedCharConn = Player.CharacterAdded:Connect(function(char)
        _G._FH_PotionSpeedActive = false
        setupChar(char)
    end)
    _G._FH_PotionSpeedConn = RunService.Heartbeat:Connect(function()
        if not (configRegistry["Potion Speed"] and configRegistry["Potion Speed"].getState()) then return end
        local char = Player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local phum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hrp or not phum then return end
        local bodyHeight = phum:FindFirstChild("BodyHeightScale")
        local isGiant = bodyHeight and bodyHeight:IsA("NumberValue") and bodyHeight.Value > SCALE_THRESHOLD
        if isGiant and not _G._FH_PotionSpeedActive then
            _G._FH_PotionSpeedBaseVelocity = _G._FH_PotionSpeedBaseVelocity or hrp.Velocity
            _G._FH_PotionSpeedActive = true
        elseif not isGiant and _G._FH_PotionSpeedActive then
            _G._FH_PotionSpeedActive = false
            hrp.Velocity = _G._FH_PotionSpeedBaseVelocity or hrp.Velocity
            return
        end
        if isGiant then
            local md = phum.MoveDirection
            if md.Magnitude > 0 then
                local flatDir = Vector3.new(md.X, 0, md.Z).Unit
                local spd = tonumber(_G._FH_PotionSpeedValue) or 34
                hrp.Velocity = Vector3.new(flatDir.X * spd, hrp.Velocity.Y, flatDir.Z * spd)
            end
        end
    end)
end)

do
    local saved = _FH_SavedConfig and _FH_SavedConfig.sliders and tonumber(_FH_SavedConfig.sliders.potion_speed)
    _G._FH_PotionSpeedValue = saved or 34
end
CreateToggle(CombatTab.scroll, "Potion On Grab",     "Activates potion before grabbing for smoother play", function(v) V3.potionOn = v end)
CreateToggle(CombatTab.scroll, "Hide Progress Bar",  "Hide the on-screen Auto Grab progress HUD",          function(v) _G._FH_HideAutoGrabBar = v end)

do
    _G._FH_QuickPickupEnabled = false
    _G._FH_QuickPickupOrig    = {}

    local function _isInMyPlot(inst)
        if not inst or not inst.Parent then return false end
        local node = inst.Parent
        for _ = 1, 10 do
            if not node then return false end
            if node:IsA("Model") and node.Parent and node.Parent.Name == "Plots" then
                return _FH_AG_IsMyPlot(node)
            end
            node = node.Parent
        end
        return false
    end

    local _hookInstalled = false
    local function _installHook()
        if _hookInstalled then return end
        local ok, mt = pcall(getrawmetatable, game)
        if not ok or not mt then return end
        local sok = pcall(setreadonly, mt, false)
        if not sok then return end
        local oldNewIndex = mt.__newindex
        local nc = newcclosure or function(f) return f end
        mt.__newindex = nc(function(self, key, value)
            if key == "HoldDuration"
               and _G._FH_QuickPickupEnabled
               and typeof(self) == "Instance"
               and self:IsA("ProximityPrompt")
               and _isInMyPlot(self) then
                value = 0.1
            end
            return oldNewIndex(self, key, value)
        end)
        pcall(setreadonly, mt, true)
        _hookInstalled = true
    end

    CreateToggle(CombatTab.scroll, "Quick Pickup",
        "Near-instant pickup (0.1s) for brainrots in YOUR base only.",
        function(v)
            _G._FH_QuickPickupEnabled = v
            if v then
                _installHook()

                task.spawn(function()
                    for _, d in ipairs(workspace:GetDescendants()) do
                        if d:IsA("ProximityPrompt") and _isInMyPlot(d) then
                            if _G._FH_QuickPickupOrig[d] == nil then
                                _G._FH_QuickPickupOrig[d] = d.HoldDuration
                            end
                            pcall(function() d.HoldDuration = 0.1 end)
                        end
                    end
                end)
            else

                for p, orig in pairs(_G._FH_QuickPickupOrig) do
                    if p and p.Parent then pcall(function() p.HoldDuration = orig end) end
                end
                _G._FH_QuickPickupOrig = {}
            end
        end
    )
end
CreateSection(CombatTab.scroll, "PANELS")
CreateToggle(CombatTab.scroll, "Semi Steal Panel",          "Famous halfway teleport.",                      function(v) SS.setSemiStealPanelVisible(v) end, function()
    if SS and SS.SSDoSteal then pcall(SS.SSDoSteal) end
end)
CreateToggle(CombatTab.scroll, "Quick Steal Panel",         "Pick an animal & TP-steal it with custom timing.", function(v) if QS and QS.setQuickStealVisible then QS.setQuickStealVisible(v) end end, function()
    if QS and QS.execute then pcall(QS.execute) end
end)
CreateToggle(CombatTab.scroll, "Priority Steal Panel",      "Whitelist animals Quick Steal can target.",     function(v) if PS and PS.setVisible then PS.setVisible(v) end end)
CreateToggle(CombatTab.scroll, "Websling Fire Kill Panel",  "Grabs player with websling then kills player",  function(v) WSK.setWSKPanelVisible(v) end, function()
    if _G._FH_WSKFireBurst then pcall(_G._FH_WSKFireBurst) end
end)
CreateToggle(CombatTab.scroll, "Faded Actions Panel",       "Quick actions: kick self, ragdoll, rejoin.",    function(v) FA.setFadedActionsVisible(v) end)
CreateToggle(CombatTab.scroll, "Command Cooldowns Panel",   "Live cooldown tracker for admin commands.",     function(v) CD.setCDPanelVisible(v) end)
CreateSection(VisualTab.scroll, "ESP")
CreateToggle(VisualTab.scroll, "Player ESP",   "White highlight + name tag on all players.", function(v) ToggleHandlers.player_esp(v) end)
CreateToggle(VisualTab.scroll, "Base ESP",       "Highlights your base walls with animated glow.",   function(v) ToggleHandlers.base_esp(v) end)
CreateToggle(VisualTab.scroll, "Timer ESP",      "Tell's what players base timer is at.",         function(v) ToggleHandlers.base_timer_esp(v) end)
CreateToggle(VisualTab.scroll, "Allowed ESP",    "Shows Allowed/Disallowed on base friend prompts.", function(v) ToggleHandlers.allowed_esp(v) end)
CreateToggle(VisualTab.scroll, "Game Stretcher", "Stretches game for extra performance.",         function(v) ToggleHandlers.game_stretcher(v) end)
CreateToggle(VisualTab.scroll, "Clone ESP",      "Show's where all clones are.",                  function(v) ToggleHandlers.clone_esp(v) end)
CreateToggle(VisualTab.scroll, "Brainrot ESP",   "Brainrot visuals tells where a brainrot is at.", function(v) ToggleHandlers.brainrot_esp(v) end)
CreateToggle(VisualTab.scroll, "Subspace Mine ESP", "White box + owner name on enemy Subspace Tripmines.", function(v) ToggleHandlers.subspace_mine_esp(v) end)
CreateToggle(VisualTab.scroll, "Line to Base",      "Red beam from you to your plot.",                function(v) ToggleHandlers.line_to_base(v) end)
CreateSection(VisualTab.scroll, "Booster's")
CreateToggle(VisualTab.scroll, "Optimizations",  "Gives best optimizations & removes world animations.", function(v)

    _G._FH_AlwaysOnFPS = v
    if v then
        FPS.enable()
        AnimRemove.enable()

        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd        = 1e9
            Lighting.Brightness    = 1
        end)

        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    pcall(function() obj.Enabled = false end)
                end
            end
        end)

        if _G._FH_OptiNewFxConn then
            pcall(function() _G._FH_OptiNewFxConn:Disconnect() end)
        end
        _G._FH_OptiNewFxConn = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
            or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                pcall(function() obj.Enabled = false end)
            end
        end)

        pcall(function()
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect")
                or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("ColorCorrectionEffect") then
                    pcall(function() e.Enabled = false end)
                end
            end
        end)
    else
        if _G._FH_OptiNewFxConn then
            pcall(function() _G._FH_OptiNewFxConn:Disconnect() end)
            _G._FH_OptiNewFxConn = nil
        end
        FPS.disable()
        AnimRemove.disable()

        pcall(function()
            for _, e in ipairs(Lighting:GetChildren()) do
                if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect")
                or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("ColorCorrectionEffect") then
                    pcall(function() e.Enabled = true end)
                end
            end
        end)

        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    pcall(function() obj.Enabled = true end)
                end
            end
        end)

        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.FogEnd        = 100000
        end)
    end
end)
CreateToggle(VisualTab.scroll, "Anti Bee", "See players through walls", function(v) ToggleHandlers.anti_bee(v) end)
do
    local xrayEnabled  = false
    local xrayAddConn  = nil
    local XRAY_AMOUNT  = 0.75
    local _xrayTouched = setmetatable({}, { __mode = "k" })
    local function _xrayShouldAffect(part)
        if not part:IsA("BasePart") then return false end
        if part.Transparency >= 1 then return false end
        if part.Name:sub(1, 3) == "FH_" then return false end
        local char = Player.Character
        if char and part:IsDescendantOf(char) then return false end
        return true
    end
    local function _xrayApplyOne(part)
        if _xrayShouldAffect(part) then
            _xrayTouched[part] = true
            part.LocalTransparencyModifier = XRAY_AMOUNT
        end
    end
    ToggleHandlers.xray = function(state)
        xrayEnabled = state
        if state then
            task.spawn(function()
                local i = 0
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not xrayEnabled then return end
                    pcall(_xrayApplyOne, obj)
                    i = i + 1
                    if i % 400 == 0 then task.wait() end
                end
            end)
            if xrayAddConn then xrayAddConn:Disconnect() end
            xrayAddConn = workspace.DescendantAdded:Connect(function(obj)
                if not xrayEnabled then return end
                task.defer(function()
                    if xrayEnabled then pcall(_xrayApplyOne, obj) end
                end)
            end)
        else
            if xrayAddConn then xrayAddConn:Disconnect(); xrayAddConn = nil end
            for part in pairs(_xrayTouched) do
                if part and part.Parent then
                    pcall(function() part.LocalTransparencyModifier = 0 end)
                end
            end
            _xrayTouched = setmetatable({}, { __mode = "k" })
        end
    end
end
CreateToggle(VisualTab.scroll, "X-Ray", "See through walls (LocalTransparencyModifier, client-only)", function(v) ToggleHandlers.xray(v) end)
CreateSection(PlayerTab.scroll, "Player Movements")
CreateToggle(PlayerTab.scroll, "Anti Ragdoll", "No hit effects.", function(v)
    if v then AntiRagdoll.enable() else AntiRagdoll.disable() end
end)
CreateToggle(PlayerTab.scroll, "Anti Admin Panel", "Block admin command effects (jumpscare, scale, move, etc).", function(v)
    _G._FH_AntiAdminPanel = v
end)
CreateToggle(PlayerTab.scroll, "Anti Gummy Bear", "Clear gummy-bear tool block / web attributes.", function(v)
    _G._FH_AntiGummyBear = v
end)
CreateToggle(PlayerTab.scroll, "Infinite Jump",       "Infinitely Jump With No Cooldown Limit.",   function(v)
    if v then
        if not _G._FH_IJ_fallConn then
            local clampFallSpeed = 50
            _G._FH_IJ_fallConn = RunService.Heartbeat:Connect(function()
                if not (configRegistry["Infinite Jump"] and configRegistry["Infinite Jump"].getState()) then return end
                local char = Player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.Velocity
                    if vel.Y < -clampFallSpeed then
                        hrp.Velocity = Vector3.new(vel.X, -clampFallSpeed, vel.Z)
                    end
                end
            end)
        end
        if not _G._FH_IJ_conn then
            local jumpForce = 50
            _G._FH_IJ_conn = UserInputService.JumpRequest:Connect(function()
                if not (configRegistry["Infinite Jump"] and configRegistry["Infinite Jump"].getState()) then return end
                local char = Player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(
                        hrp.Velocity.X,
                        jumpForce,
                        hrp.Velocity.Z
                    )
                end
            end)
        end
        if not _G._FH_IJ_holdConn then
            local jumpForce   = 50
            local jumpHeld    = false
            local jumpHoldCd  = 0
            _G._FH_IJ_holdBeginConn = UserInputService.InputBegan:Connect(function(inp, gpe)
                if gpe then return end
                if inp.KeyCode == Enum.KeyCode.Space
                or inp.KeyCode == Enum.KeyCode.ButtonA then
                    jumpHeld = true
                end
            end)
            _G._FH_IJ_holdEndConn = UserInputService.InputEnded:Connect(function(inp)
                if inp.KeyCode == Enum.KeyCode.Space
                or inp.KeyCode == Enum.KeyCode.ButtonA then
                    jumpHeld = false
                end
            end)
            _G._FH_IJ_holdConn = RunService.Heartbeat:Connect(function()
                if not (configRegistry["Infinite Jump"] and configRegistry["Infinite Jump"].getState()) then return end
                if not jumpHeld then return end

                if not (UserInputService:IsKeyDown(Enum.KeyCode.Space)
                     or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)) then
                    jumpHeld = false
                    return
                end
                local now = tick()
                if (now - jumpHoldCd) < 0.18 then return end
                jumpHoldCd = now
                local char = Player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(
                        hrp.Velocity.X,
                        jumpForce,
                        hrp.Velocity.Z
                    )
                end
            end)
        end
    else
        if _G._FH_IJ_conn         then _G._FH_IJ_conn:Disconnect();         _G._FH_IJ_conn         = nil end
        if _G._FH_IJ_fallConn     then _G._FH_IJ_fallConn:Disconnect();     _G._FH_IJ_fallConn     = nil end
        if _G._FH_IJ_holdConn     then _G._FH_IJ_holdConn:Disconnect();     _G._FH_IJ_holdConn     = nil end
        if _G._FH_IJ_holdBeginConn then _G._FH_IJ_holdBeginConn:Disconnect(); _G._FH_IJ_holdBeginConn = nil end
        if _G._FH_IJ_holdEndConn  then _G._FH_IJ_holdEndConn:Disconnect();  _G._FH_IJ_holdEndConn  = nil end
    end
end)
CreateToggle(PlayerTab.scroll, "Carpet Speed","Fly fast on the Flying Carpet.",              function(v) Toggles["carpet_speed"] = v; ToggleHandlers.carpet_speed(v) end)
SP.SpeedBorderFrame = Instance.new("Frame")
SP.SpeedBorderFrame.Name             = "SpeedGradBorder"
SP.SpeedBorderFrame.Size             = UDim2.new(0, SP.W + 4, 0, SP.H + 4)
SP.SpeedBorderFrame.Position         = UDim2.new(0, 96, 0.5, -(SP.H + 4) / 2)
SP.SpeedBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SP.SpeedBorderFrame.BorderSizePixel  = 0
SP.SpeedBorderFrame.ZIndex           = 18
SP.SpeedBorderFrame.Visible          = false
SP.SpeedBorderFrame.Parent           = GUI
SP.SpeedBorderFrame.BackgroundTransparency = 1
_FH_AddThemeStrokeToFrame(SP.SpeedBorderFrame, 1.5)
Corner(SP.SpeedBorderFrame, 12)
SP.SpeedWin = Instance.new("Frame")
SP.SpeedWin.Name             = "SpeedBoostPanel"
SP.SpeedWin.Size             = UDim2.new(0, SP.W, 0, SP.H)
SP.SpeedWin.Position         = UDim2.new(0, 98, 0.5, -SP.H / 2)
SP.SpeedWin.BackgroundColor3 = T.BG
SP.SpeedWin.BackgroundTransparency = 0.25
SP.SpeedWin.BorderSizePixel  = 0
SP.SpeedWin.ZIndex           = 19
SP.SpeedWin.Visible          = false
SP.SpeedWin.ClipsDescendants = true
SP.SpeedWin.Parent           = GUI
Corner(SP.SpeedWin, 10)
SP.SpHdr = Instance.new("Frame")
SP.SpHdr.Size             = UDim2.new(1, 0, 0, 30)
SP.SpHdr.BackgroundColor3 = T.Header
SP.SpHdr.BorderSizePixel  = 0
SP.SpHdr.ZIndex           = 20
SP.SpHdr.Parent           = SP.SpeedWin
Corner(SP.SpHdr, 10)
SP.SpHdr.Active = true
SP.SpHdrFill = Instance.new("Frame")
SP.SpHdrFill.Size             = UDim2.new(1, 0, 0, 7)
SP.SpHdrFill.Position         = UDim2.new(0, 0, 1, -7)
SP.SpHdrFill.BackgroundColor3 = T.Header
SP.SpHdrFill.BorderSizePixel  = 0
SP.SpHdrFill.ZIndex           = 20
SP.SpHdrFill.Parent           = SP.SpHdr
SP.SpHdrLine = Instance.new("Frame")
SP.SpHdrLine.Size             = UDim2.new(1, 0, 0, 1)
SP.SpHdrLine.Position         = UDim2.new(0, 0, 1, -1)
SP.SpHdrLine.BackgroundColor3 = T.Border
SP.SpHdrLine.BorderSizePixel  = 0
SP.SpHdrLine.ZIndex           = 21
SP.SpHdrLine.Parent           = SP.SpHdr
SP.SpTitle = Label(SP.SpHdr, "Booster", 13, T.White, Enum.Font.GothamBold)
SP.SpTitle.Size           = UDim2.new(1, -40, 1, 0)
SP.SpTitle.Position       = UDim2.new(0, 12, 0, 0)
SP.SpTitle.TextYAlignment = Enum.TextYAlignment.Center
SP.SpTitle.ZIndex         = 22
SP.SpMinBtn = Instance.new("TextButton")
SP.SpMinBtn.Size             = UDim2.new(0, 22, 0, 22)
SP.SpMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
SP.SpMinBtn.BackgroundColor3 = T.Card
SP.SpMinBtn.BorderSizePixel  = 0
SP.SpMinBtn.Text             = "\226\136\146"
SP.SpMinBtn.TextSize         = 14
SP.SpMinBtn.Font             = Enum.Font.GothamBold
SP.SpMinBtn.TextColor3       = T.White
SP.SpMinBtn.ZIndex           = 23
SP.SpMinBtn.Parent           = SP.SpHdr
Corner(SP.SpMinBtn, 6)
Stroke(SP.SpMinBtn, T.Border, 1)
SP.SpContent = Instance.new("Frame")
SP.SpContent.Size                   = UDim2.new(1, 0, 1, -30)
SP.SpContent.Position               = UDim2.new(0, 0, 0, 30)
SP.SpContent.BackgroundTransparency = 1
SP.SpContent.ZIndex                 = 19
SP.SpContent.Parent                 = SP.SpeedWin
SP.SpLayout = Instance.new("UIListLayout")
SP.SpLayout.FillDirection       = Enum.FillDirection.Vertical
SP.SpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SP.SpLayout.Padding             = UDim.new(0, 4)
SP.SpLayout.Parent              = SP.SpContent
Padding(SP.SpContent, 6, 6, 0, 0)
SP.SpRow = function(h)
    local r = Instance.new("Frame")
    r.Size                   = UDim2.new(1, -16, 0, h or 24)
    r.BackgroundTransparency = 1
    r.ZIndex                 = 20
    r.Parent                 = SP.SpContent
    return r
end
SP.spBoosterRow = SP.SpRow(20)
SP.spBoosterLbl = Label(SP.spBoosterRow, "Booster", 13, T.White, Enum.Font.GothamMedium)
SP.spBoosterLbl.Size           = UDim2.new(1, -60, 1, 0)
SP.spBoosterLbl.Position       = UDim2.new(0, 8, 0, 0)
SP.spBoosterLbl.TextYAlignment = Enum.TextYAlignment.Center
SP.spBoosterLbl.ZIndex         = 21
SP.spKbLbl = Instance.new("TextLabel")
SP.spKbLbl.Size              = UDim2.new(0, 36, 0, 16)
SP.spKbLbl.Position          = UDim2.new(1, -94, 0.5, -8)
SP.spKbLbl.BackgroundTransparency = 1
SP.spKbLbl.Text              = ""
SP.spKbLbl.TextSize          = 10
SP.spKbLbl.Font              = Enum.Font.GothamBold
SP.spKbLbl.TextColor3        = T.Dim
SP.spKbLbl.TextXAlignment    = Enum.TextXAlignment.Center
SP.spKbLbl.ZIndex            = 23
SP.spKbLbl.Parent            = SP.spBoosterRow
do
    local _saved = (Config and Config.mini and Config.mini.sp_keybind)
                or (Config and Config.keybinds and Config.keybinds["sp_booster"])
                or (Config and Config.keybinds and Config.keybinds["Speed Booster"])
    if type(_saved) == "string" then
        local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
        if _ok and _kc then
            SP.entry.keyCode      = _kc
            SP.spKbLbl.Text       = "[" .. _saved .. "]"
            SP.spKbLbl.TextColor3 = T.Dim
        end
    end
end
SP.spTrack = Instance.new("Frame")
SP.spTrack.Size             = UDim2.new(0, 28, 0, 16)
SP.spTrack.Position         = UDim2.new(1, -36, 0.5, -8)
SP.spTrack.BackgroundColor3 = T.TrackOff
SP.spTrack.BorderSizePixel  = 0
SP.spTrack.ZIndex           = 21
SP.spTrack.Parent           = SP.spBoosterRow
Corner(SP.spTrack, 8)
SP.spTStroke = Stroke(SP.spTrack, T.Border, 1)
SP.spKnob = Instance.new("Frame")
SP.spKnob.Size             = UDim2.new(0, 12, 0, 12)
SP.spKnob.Position         = UDim2.new(0, 2, 0.5, -6)
SP.spKnob.BackgroundColor3 = T.KnobOff
SP.spKnob.BorderSizePixel  = 0
SP.spKnob.ZIndex           = 22
SP.spKnob.Parent           = SP.spTrack
Corner(SP.spKnob, 6)
SP.spBoosterDoToggle = function()
    SP.state = not SP.state
    if _G._FH_CarpetClearBoosterMem then _G._FH_CarpetClearBoosterMem() end
    if SP.state then
        if SP.stealOnlyEnabled then
            SP.stealOnlyEnabled = false
            Tween(SP.stealOnlyKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SP.stealOnlyKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
                Tween(SP.stealOnlyKnob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(SP.stealOnlyTrack,   M, {BackgroundColor3 = T.TrackOff})
                Tween(SP.stealOnlyTStroke, M, {Color = T.Border})
            end)
        end
        Tween(SP.spKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
        task.delay(0.06, function()
            Tween(SP.spKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
            Tween(SP.spKnob,    M, {BackgroundColor3 = T.KnobOn})
            Tween(SP.spTrack,   M, {BackgroundColor3 = T.TrackOn})
            Tween(SP.spTStroke, M, {Color = T.TrackOn})
        end)
        setSpeedBooster(true)
    else
        Tween(SP.spKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
        task.delay(0.06, function()
            Tween(SP.spKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
            Tween(SP.spKnob,    M, {BackgroundColor3 = T.KnobOff})
            Tween(SP.spTrack,   M, {BackgroundColor3 = T.TrackOff})
            Tween(SP.spTStroke, M, {Color = T.Border})
        end)
        setSpeedBooster(false)
    end
    Config.toggles["sp_booster"] = SP.state
    pcall(FH_SaveConfig)
end
SP.spBoosterBtn = Instance.new("Frame")
SP.spBoosterBtn.Size                   = UDim2.new(1, 0, 1, 0)
SP.spBoosterBtn.BackgroundTransparency = 1
SP.spBoosterBtn.ZIndex                 = 24
SP.spBoosterBtn.Active                 = true
SP.spBoosterBtn.Parent                 = SP.spBoosterRow
do
    local _spBTouchStart = nil
    SP.spBoosterBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            SP.spBoosterDoToggle()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _spBTouchStart = inp.Position
        end
    end)
    SP.spBoosterBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _spBTouchStart then
            local mag = (inp.Position - _spBTouchStart).Magnitude
            _spBTouchStart = nil
            if mag < 20 then SP.spBoosterDoToggle() end
        end
    end)
end
SP.spBoosterBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
    if SP.kb2Debounce then return end
    SP.kb2Debounce = true
    task.delay(0.2, function() SP.kb2Debounce = false end)
    if keybindBindingTarget then
        local prev = keybindBindingTarget
        keybindBindingTarget = nil
        if prev.kbLbl == SP.spKbLbl then
            SP.spKbLbl.Text       = SP.entry.keyCode and ("[".. SP.entry.keyCode.Name .. "]") or ""
SP.spKbLbl.TextColor3 = T.Dim
            return
        else
            prev.kbLbl.Text       = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
        end
    end
    SP.spKbLbl.Text         = "(...)"
SP.spKbLbl.TextColor3   = T.White
    keybindBindingTarget = { entry = SP.entry, kbLbl = SP.spKbLbl, mode = "assign"}
end)
table.insert(keybindEntries, { entry = SP.entry, fire = SP.spBoosterDoToggle, kbLbl = SP.spKbLbl })
SP.stealOnlyEnabled = false
SP.stealOnlyRow = SP.SpRow(20)
SP.stealOnlyLbl = Label(SP.stealOnlyRow, "Booster Steal", 11, T.White, Enum.Font.GothamMedium)
SP.stealOnlyLbl.Size           = UDim2.new(1, -60, 1, 0)
SP.stealOnlyLbl.Position       = UDim2.new(0, 8, 0, 0)
SP.stealOnlyLbl.TextYAlignment = Enum.TextYAlignment.Center
SP.stealOnlyLbl.ZIndex         = 21
SP.stealOnlyTrack = Instance.new("Frame")
SP.stealOnlyTrack.Size             = UDim2.new(0, 28, 0, 16)
SP.stealOnlyTrack.Position         = UDim2.new(1, -36, 0.5, -8)
SP.stealOnlyTrack.BackgroundColor3 = T.TrackOff
SP.stealOnlyTrack.BorderSizePixel  = 0
SP.stealOnlyTrack.ZIndex           = 21
SP.stealOnlyTrack.Parent           = SP.stealOnlyRow
Corner(SP.stealOnlyTrack, 8)
SP.stealOnlyTStroke = Stroke(SP.stealOnlyTrack, T.Border, 1)
SP.stealOnlyKnob = Instance.new("Frame")
SP.stealOnlyKnob.Size             = UDim2.new(0, 12, 0, 12)
SP.stealOnlyKnob.Position         = UDim2.new(0, 2, 0.5, -6)
SP.stealOnlyKnob.BackgroundColor3 = T.KnobOff
SP.stealOnlyKnob.BorderSizePixel  = 0
SP.stealOnlyKnob.ZIndex           = 22
SP.stealOnlyKnob.Parent           = SP.stealOnlyTrack
Corner(SP.stealOnlyKnob, 6)
SP.stealOnlyBtn = Instance.new("Frame")
SP.stealOnlyBtn.Size                   = UDim2.new(1, 0, 1, 0)
SP.stealOnlyBtn.BackgroundTransparency = 1
SP.stealOnlyBtn.ZIndex                 = 24
SP.stealOnlyBtn.Active                 = true
SP.stealOnlyBtn.Parent                 = SP.stealOnlyRow
SP.stealOnlyEntry = { keyCode = nil }
SP.stealOnlyKbLbl = Instance.new("TextLabel")
SP.stealOnlyKbLbl.Size                   = UDim2.new(0, 32, 0, 14)
SP.stealOnlyKbLbl.Position               = UDim2.new(1, -72, 0.5, -7)
SP.stealOnlyKbLbl.BackgroundTransparency = 1
SP.stealOnlyKbLbl.Text                   = ""
SP.stealOnlyKbLbl.TextSize               = 10
SP.stealOnlyKbLbl.Font                   = Enum.Font.GothamBold
SP.stealOnlyKbLbl.TextColor3             = T.Dim
SP.stealOnlyKbLbl.TextXAlignment         = Enum.TextXAlignment.Center
SP.stealOnlyKbLbl.ZIndex                 = 23
SP.stealOnlyKbLbl.Parent                 = SP.stealOnlyRow
do
    local _saved = Config and Config.keybinds and Config.keybinds["sp_steal_only"]
    if type(_saved) == "string" then
        local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
        if _ok and _kc then
            SP.stealOnlyEntry.keyCode = _kc
            SP.stealOnlyKbLbl.Text    = "[" .. _saved .. "]"
        end
    end
end
do
    local function _stealOnlyDoToggle()
        SP.stealOnlyEnabled = not SP.stealOnlyEnabled
        if SP.stealOnlyEnabled then
            if SP.state then
                SP.spBoosterDoToggle()
            end
            Tween(SP.stealOnlyKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SP.stealOnlyKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
                Tween(SP.stealOnlyKnob,    M, {BackgroundColor3 = T.KnobOn})
                Tween(SP.stealOnlyTrack,   M, {BackgroundColor3 = T.TrackOn})
                Tween(SP.stealOnlyTStroke, M, {Color = T.TrackOn})
            end)
            setSpeedBooster(true)
        else
            setSpeedBooster(false)
            Tween(SP.stealOnlyKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SP.stealOnlyKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
                Tween(SP.stealOnlyKnob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(SP.stealOnlyTrack,   M, {BackgroundColor3 = T.TrackOff})
                Tween(SP.stealOnlyTStroke, M, {Color = T.Border})
            end)
        end
        Config.toggles["sp_steal_only"] = SP.stealOnlyEnabled
        pcall(FH_SaveConfig)
    end
    local _stealOnlyTouchStart = nil
    local _stealOnlyKb2Deb = false
    SP.stealOnlyBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            _stealOnlyDoToggle()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _stealOnlyTouchStart = inp.Position
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
            if _stealOnlyKb2Deb then return end
            _stealOnlyKb2Deb = true
            task.delay(0.2, function() _stealOnlyKb2Deb = false end)
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == SP.stealOnlyKbLbl then
                    SP.stealOnlyKbLbl.Text = SP.stealOnlyEntry.keyCode and ("[".. SP.stealOnlyEntry.keyCode.Name .. "]") or ""
                    return
                else
                    prev.kbLbl.Text = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
                end
            end
            SP.stealOnlyKbLbl.Text = "(...)"
            keybindBindingTarget = { entry = SP.stealOnlyEntry, kbLbl = SP.stealOnlyKbLbl, mode = "assign" }
        end
    end)
    SP.stealOnlyBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _stealOnlyTouchStart then
            local mag = (inp.Position - _stealOnlyTouchStart).Magnitude
            _stealOnlyTouchStart = nil
            if mag < 20 then _stealOnlyDoToggle() end
        end
    end)
    table.insert(keybindEntries, { entry = SP.stealOnlyEntry, fire = _stealOnlyDoToggle, kbLbl = SP.stealOnlyKbLbl })
end
SP.wsRow = SP.SpRow(20)
SP.wsLbl = Label(SP.wsRow, "Walk Speed", 13, T.White, Enum.Font.GothamMedium)
SP.wsLbl.Size           = UDim2.new(1, -60, 1, 0)
SP.wsLbl.Position       = UDim2.new(0, 8, 0, 0)
SP.wsLbl.TextYAlignment = Enum.TextYAlignment.Center
SP.wsLbl.ZIndex         = 21
SP.wsBox = Instance.new("TextBox")
SP.wsBox.Size             = UDim2.new(0, 44, 0, 22)
SP.wsBox.Position         = UDim2.new(1, -52, 0.5, -11)
SP.wsBox.BackgroundColor3 = T.Card
SP.wsBox.BorderSizePixel  = 0
SP.wsBox.Text             = "29"
SP.wsBox.TextSize         = 12
SP.wsBox.Font             = Enum.Font.GothamBold
SP.wsBox.TextColor3       = T.White
SP.wsBox.TextXAlignment   = Enum.TextXAlignment.Center
SP.wsBox.ZIndex           = 21
SP.wsBox.ClearTextOnFocus = false
SP.wsBox.Parent           = SP.wsRow
Corner(SP.wsBox, 6)
Stroke(SP.wsBox, T.Border, 1)
SP.jpRow = SP.SpRow(20)
SP.jpLbl = Label(SP.jpRow, "Jump Power", 13, T.White, Enum.Font.GothamMedium)
SP.jpLbl.Size           = UDim2.new(1, -60, 1, 0)
SP.jpLbl.Position       = UDim2.new(0, 8, 0, 0)
SP.jpLbl.TextYAlignment = Enum.TextYAlignment.Center
SP.jpLbl.ZIndex         = 21
SP.jpBox = Instance.new("TextBox")
SP.jpBox.Size             = UDim2.new(0, 44, 0, 22)
SP.jpBox.Position         = UDim2.new(1, -52, 0.5, -11)
SP.jpBox.BackgroundColor3 = T.Card
SP.jpBox.BorderSizePixel  = 0
SP.jpBox.Text             = "50"
SP.jpBox.TextSize         = 12
SP.jpBox.Font             = Enum.Font.GothamBold
SP.jpBox.TextColor3       = T.White
SP.jpBox.TextXAlignment   = Enum.TextXAlignment.Center
SP.jpBox.ZIndex           = 21
SP.jpBox.ClearTextOnFocus = false
SP.jpBox.Parent           = SP.jpRow
Corner(SP.jpBox, 6)
Stroke(SP.jpBox, T.Border, 1)
local function _spSaveSliders()
    if _G._FH_IsRestoring then return end
    Config.sliders = Config.sliders or {}
    Config.sliders.sp_walkspeed = SP.wsBox.Text
    Config.sliders.sp_jumppower = SP.jpBox.Text
    pcall(FH_SaveConfig)
end
local _spSaveDebounce = false
local function _spQueueSave()
    if _spSaveDebounce then return end
    _spSaveDebounce = true
    task.delay(0.4, function() _spSaveDebounce = false; _spSaveSliders() end)
end
SP.wsBox.FocusLost:Connect(_spSaveSliders)
SP.jpBox.FocusLost:Connect(_spSaveSliders)
SP.wsBox:GetPropertyChangedSignal("Text"):Connect(_spQueueSave)
SP.jpBox:GetPropertyChangedSignal("Text"):Connect(_spQueueSave)
SP.jpBoosterRow = SP.SpRow(20)
SP.jpBoosterLbl = Label(SP.jpBoosterRow, "Jump Booster", 13, T.White, Enum.Font.GothamMedium)
SP.jpBoosterLbl.Size           = UDim2.new(1, -60, 1, 0)
SP.jpBoosterLbl.Position       = UDim2.new(0, 8, 0, 0)
SP.jpBoosterLbl.TextYAlignment = Enum.TextYAlignment.Center
SP.jpBoosterLbl.ZIndex         = 21
SP.jpBoosterTrack = Instance.new("Frame")
SP.jpBoosterTrack.Size             = UDim2.new(0, 28, 0, 16)
SP.jpBoosterTrack.Position         = UDim2.new(1, -36, 0.5, -8)
SP.jpBoosterTrack.BackgroundColor3 = T.TrackOff
SP.jpBoosterTrack.BorderSizePixel  = 0
SP.jpBoosterTrack.ZIndex           = 21
SP.jpBoosterTrack.Parent           = SP.jpBoosterRow
Corner(SP.jpBoosterTrack, 8)
SP.jpBoosterTStroke = Stroke(SP.jpBoosterTrack, T.Border, 1)
SP.jpBoosterKnob = Instance.new("Frame")
SP.jpBoosterKnob.Size             = UDim2.new(0, 12, 0, 12)
SP.jpBoosterKnob.Position         = UDim2.new(0, 2, 0.5, -6)
SP.jpBoosterKnob.BackgroundColor3 = T.KnobOff
SP.jpBoosterKnob.BorderSizePixel  = 0
SP.jpBoosterKnob.ZIndex           = 22
SP.jpBoosterKnob.Parent           = SP.jpBoosterTrack
Corner(SP.jpBoosterKnob, 6)
SP.jpBoosterState = false
SP.jpBoosterDoToggle = function()
    SP.jpBoosterState = not SP.jpBoosterState
    if SP.jpBoosterState then
        Tween(SP.jpBoosterKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
        task.delay(0.06, function()
            Tween(SP.jpBoosterKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
            Tween(SP.jpBoosterKnob,    M, {BackgroundColor3 = T.KnobOn})
            Tween(SP.jpBoosterTrack,   M, {BackgroundColor3 = T.TrackOn})
            Tween(SP.jpBoosterTStroke, M, {Color = T.TrackOn})
        end)
        setJumpBooster(true)
    else
        Tween(SP.jpBoosterKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
        task.delay(0.06, function()
            Tween(SP.jpBoosterKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
            Tween(SP.jpBoosterKnob,    M, {BackgroundColor3 = T.KnobOff})
            Tween(SP.jpBoosterTrack,   M, {BackgroundColor3 = T.TrackOff})
            Tween(SP.jpBoosterTStroke, M, {Color = T.Border})
        end)
        setJumpBooster(false)
    end
    Config.toggles["sp_jump_booster"] = SP.jpBoosterState
    pcall(FH_SaveConfig)
end
SP.jpBoosterBtn = Instance.new("Frame")
SP.jpBoosterBtn.Size                   = UDim2.new(1, 0, 1, 0)
SP.jpBoosterBtn.BackgroundTransparency = 1
SP.jpBoosterBtn.ZIndex                 = 24
SP.jpBoosterBtn.Active                 = true
SP.jpBoosterBtn.Parent                 = SP.jpBoosterRow
SP.jpBoosterEntry = { keyCode = nil }
SP.jpBoosterKbLbl = Instance.new("TextLabel")
SP.jpBoosterKbLbl.Size                   = UDim2.new(0, 32, 0, 14)
SP.jpBoosterKbLbl.Position               = UDim2.new(1, -72, 0.5, -7)
SP.jpBoosterKbLbl.BackgroundTransparency = 1
SP.jpBoosterKbLbl.Text                   = ""
SP.jpBoosterKbLbl.TextSize               = 10
SP.jpBoosterKbLbl.Font                   = Enum.Font.GothamBold
SP.jpBoosterKbLbl.TextColor3             = T.Dim
SP.jpBoosterKbLbl.TextXAlignment         = Enum.TextXAlignment.Center
SP.jpBoosterKbLbl.ZIndex                 = 23
SP.jpBoosterKbLbl.Parent                 = SP.jpBoosterRow
do
    local _saved = Config and Config.keybinds and Config.keybinds["sp_jump_booster"]
    if type(_saved) == "string" then
        local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
        if _ok and _kc then
            SP.jpBoosterEntry.keyCode = _kc
            SP.jpBoosterKbLbl.Text    = "[" .. _saved .. "]"
        end
    end
end
do
    local _jpBTouchStart = nil
    local _jpBKb2Deb = false
    SP.jpBoosterBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            SP.jpBoosterDoToggle()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _jpBTouchStart = inp.Position
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
            if _jpBKb2Deb then return end
            _jpBKb2Deb = true
            task.delay(0.2, function() _jpBKb2Deb = false end)
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == SP.jpBoosterKbLbl then
                    SP.jpBoosterKbLbl.Text = SP.jpBoosterEntry.keyCode and ("[".. SP.jpBoosterEntry.keyCode.Name .. "]") or ""
                    return
                else
                    prev.kbLbl.Text = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
                end
            end
            SP.jpBoosterKbLbl.Text = "(...)"
            keybindBindingTarget = { entry = SP.jpBoosterEntry, kbLbl = SP.jpBoosterKbLbl, mode = "assign" }
        end
    end)
    SP.jpBoosterBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _jpBTouchStart then
            local mag = (inp.Position - _jpBTouchStart).Magnitude
            _jpBTouchStart = nil
            if mag < 20 then SP.jpBoosterDoToggle() end
        end
    end)
    table.insert(keybindEntries, { entry = SP.jpBoosterEntry, fire = SP.jpBoosterDoToggle, kbLbl = SP.jpBoosterKbLbl })
end
SP.giantSpeedRow = SP.SpRow(20)
SP.giantSpeedLbl = Label(SP.giantSpeedRow, "Giant Speed", 13, T.White, Enum.Font.GothamMedium)
SP.giantSpeedLbl.Size           = UDim2.new(1, -60, 1, 0)
SP.giantSpeedLbl.Position       = UDim2.new(0, 8, 0, 0)
SP.giantSpeedLbl.TextYAlignment = Enum.TextYAlignment.Center
SP.giantSpeedLbl.ZIndex         = 21
SP.giantSpeedTrack = Instance.new("Frame")
SP.giantSpeedTrack.Size             = UDim2.new(0, 40, 0, 20)
SP.giantSpeedTrack.Position         = UDim2.new(1, -52, 0.5, -10)
SP.giantSpeedTrack.BackgroundColor3 = T.TrackOff
SP.giantSpeedTrack.BorderSizePixel  = 0
SP.giantSpeedTrack.ZIndex           = 21
SP.giantSpeedTrack.Parent           = SP.giantSpeedRow
Corner(SP.giantSpeedTrack, 10)
SP.giantSpeedTStroke = Stroke(SP.giantSpeedTrack, T.Border, 1)
SP.giantSpeedKnob = Instance.new("Frame")
SP.giantSpeedKnob.Size             = UDim2.new(0, 10, 0, 10)
SP.giantSpeedKnob.Position         = UDim2.new(0, 3, 0.5, -7)
SP.giantSpeedKnob.BackgroundColor3 = T.KnobOff
SP.giantSpeedKnob.BorderSizePixel  = 0
SP.giantSpeedKnob.ZIndex           = 22
SP.giantSpeedKnob.Parent           = SP.giantSpeedTrack
Corner(SP.giantSpeedKnob, 7)
SP.giantSpeedState = false
SP.giantSpeedDoToggle = function()
    SP.giantSpeedState = not SP.giantSpeedState
    if SP.giantSpeedState then
        Tween(SP.giantSpeedKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 4, 0.5, -6)})
        task.delay(0.06, function()
            Tween(SP.giantSpeedKnob,    M, {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 22, 0.5, -7)})
            Tween(SP.giantSpeedKnob,    M, {BackgroundColor3 = T.KnobOn})
            Tween(SP.giantSpeedTrack,   M, {BackgroundColor3 = T.TrackOn})
            Tween(SP.giantSpeedTStroke, M, {Color = T.TrackOn})
        end)
        ToggleHandlers.giant_speed(true)
    else
        Tween(SP.giantSpeedKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 20, 0.5, -6)})
        task.delay(0.06, function()
            Tween(SP.giantSpeedKnob,    M, {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -7)})
            Tween(SP.giantSpeedKnob,    M, {BackgroundColor3 = T.KnobOff})
            Tween(SP.giantSpeedTrack,   M, {BackgroundColor3 = T.TrackOff})
            Tween(SP.giantSpeedTStroke, M, {Color = T.Border})
        end)
        ToggleHandlers.giant_speed(false)
    end
    Config.toggles["sp_giant_speed"] = SP.giantSpeedState
    pcall(FH_SaveConfig)
end
SP.giantSpeedBtn = Instance.new("Frame")
SP.giantSpeedBtn.Size                   = UDim2.new(1, 0, 1, 0)
SP.giantSpeedBtn.BackgroundTransparency = 1
SP.giantSpeedBtn.ZIndex                 = 24
SP.giantSpeedBtn.Active                 = true
SP.giantSpeedBtn.Parent                 = SP.giantSpeedRow
do
    local _gsBTouchStart = nil
    SP.giantSpeedBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            SP.giantSpeedDoToggle()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _gsBTouchStart = inp.Position
        end
    end)
    SP.giantSpeedBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _gsBTouchStart then
            local mag = (inp.Position - _gsBTouchStart).Magnitude
            _gsBTouchStart = nil
            if mag < 20 then SP.giantSpeedDoToggle() end
        end
    end)
end
SP.spBoosterRow.Visible  = false
SP.spBoosterRow.Size     = UDim2.new(0, 0, 0, 0)
SP.giantSpeedRow.Visible = false
SP.giantSpeedRow.Size    = UDim2.new(0, 0, 0, 0)
do
    SP.SpHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            SP.dragging   = true
            SP.dragStart  = inp.Position
            SP.panelStart = SP.SpeedWin.Position
        end
    end)
    SP.SpHdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            SP.dragging = false
            Config.mini = Config.mini or {}
            Config.mini.sp_pos = { x = SP.SpeedWin.Position.X.Offset, y = SP.SpeedWin.Position.Y.Offset,
                                   xs = SP.SpeedWin.Position.X.Scale, ys = SP.SpeedWin.Position.Y.Scale }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if SP.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d      = inp.Position - SP.dragStart
            local newPos = UDim2.new(
                SP.panelStart.X.Scale, SP.panelStart.X.Offset + d.X,
                SP.panelStart.Y.Scale, SP.panelStart.Y.Offset + d.Y
            )
            SP.SpeedWin.Position         = newPos
            SP.SpeedBorderFrame.Position = UDim2.new(
                newPos.X.Scale, newPos.X.Offset - 2,
                newPos.Y.Scale, newPos.Y.Offset - 2
            )
        end
    end)
end
SP.SpMinBtn.MouseButton1Click:Connect(function()
    SP.minimized = not SP.minimized
    if SP.minimized then
        SP.SpeedWin.ClipsDescendants = false
        SP.SpHdrFill.Visible = false
        SP.SpHdrLine.Visible = false
        SP.SpContent.Visible = false
        Tween(SP.SpeedWin,         M, {Size = UDim2.new(0, SP.W, 0, 30)})
        Tween(SP.SpeedBorderFrame, M, {Size = UDim2.new(0, SP.W + 4, 0, 40)})
        SP.SpMinBtn.Text = "+"else
        SP.SpHdrFill.Visible = true
        SP.SpHdrLine.Visible = true
        Tween(SP.SpeedWin,         M, {Size = UDim2.new(0, SP.W, 0, SP.H)})
        Tween(SP.SpeedBorderFrame, M, {Size = UDim2.new(0, SP.W + 4, 0, SP.H + 4)})
        SP.SpMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            SP.SpContent.Visible = true
            SP.SpeedWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.sp_min = SP.minimized
        pcall(FH_SaveConfig)
    end
end)
SP.setSpeedPanelVisible = function(vis)
    SP.SpeedWin.Visible         = vis
    SP.SpeedBorderFrame.Visible = vis
    if vis then

        local p = SP.SpeedWin.Position
        SP.SpeedBorderFrame.Position  = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if SP.minimized then
            SP.SpMinBtn.Text              = "+"
            SP.SpContent.Visible          = false
            SP.SpHdrFill.Visible          = false
            SP.SpHdrLine.Visible          = false
            SP.SpeedWin.ClipsDescendants  = false
            SP.SpeedWin.Size              = UDim2.new(0, SP.W, 0, 30)
            SP.SpeedBorderFrame.Size      = UDim2.new(0, SP.W + 4, 0, 40)
        else
            SP.SpMinBtn.Text              = "\226\136\146"
            SP.SpContent.Visible          = true
            SP.SpHdrFill.Visible          = true
            SP.SpHdrLine.Visible          = true
            SP.SpeedWin.ClipsDescendants  = true
            SP.SpeedWin.Size              = UDim2.new(0, SP.W, 0, SP.H)
            SP.SpeedBorderFrame.Size      = UDim2.new(0, SP.W + 4, 0, SP.H + 4)
        end
    end
end

do
    local function spApplyBooster(v)
        SP.state = v
        if v then
            SP.spKnob.Position         = UDim2.new(0, 14, 0.5, -6)
            SP.spKnob.BackgroundColor3 = T.KnobOn
            SP.spTrack.BackgroundColor3 = T.TrackOn
            SP.spTStroke.Color         = T.TrackOn
            setSpeedBooster(true)
        else
            SP.spKnob.Position         = UDim2.new(0, 2, 0.5, -6)
            SP.spKnob.BackgroundColor3 = T.KnobOff
            SP.spTrack.BackgroundColor3 = T.TrackOff
            SP.spTStroke.Color         = T.Border
            setSpeedBooster(false)
        end
        Config.toggles["sp_booster"] = v
        if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
    end
    configRegistry["sp_booster"] = {
        getState   = function() return SP.state end,
        getKeyCode = function() return SP.entry and SP.entry.keyCode end,
        setKeyCode = function(kc)
            if SP.entry then SP.entry.keyCode = kc end
            if SP.spKbLbl then
                SP.spKbLbl.Text = kc and ("["..kc.Name.."]") or ""
                SP.spKbLbl.TextColor3 = T.Dim
            end
            if kc then Config.keybinds["sp_booster"] = kc.Name
            else Config.keybinds["sp_booster"] = nil end
            pcall(FH_SaveConfig)
        end,
        doToggle   = SP.spBoosterDoToggle,
        setEnabled = spApplyBooster,
    }
    local function spApplyJumpBooster(v)
        SP.jpBoosterState = v
        if v then
            SP.jpBoosterKnob.Position         = UDim2.new(0, 14, 0.5, -6)
            SP.jpBoosterKnob.BackgroundColor3 = T.KnobOn
            SP.jpBoosterTrack.BackgroundColor3 = T.TrackOn
            SP.jpBoosterTStroke.Color         = T.TrackOn
            setJumpBooster(true)
        else
            SP.jpBoosterKnob.Position         = UDim2.new(0, 2, 0.5, -6)
            SP.jpBoosterKnob.BackgroundColor3 = T.KnobOff
            SP.jpBoosterTrack.BackgroundColor3 = T.TrackOff
            SP.jpBoosterTStroke.Color         = T.Border
            setJumpBooster(false)
        end
        Config.toggles["sp_jump_booster"] = v
        if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
    end
    configRegistry["sp_jump_booster"] = {
        getState   = function() return SP.jpBoosterState end,
        getKeyCode = function() return SP.jpBoosterEntry and SP.jpBoosterEntry.keyCode end,
        setKeyCode = function(kc)
            if SP.jpBoosterEntry then SP.jpBoosterEntry.keyCode = kc end
            if SP.jpBoosterKbLbl then
                SP.jpBoosterKbLbl.Text = kc and ("["..kc.Name.."]") or ""
                SP.jpBoosterKbLbl.TextColor3 = T.Dim
            end
            Config.keybinds = Config.keybinds or {}
            if kc then Config.keybinds["sp_jump_booster"] = kc.Name
            else Config.keybinds["sp_jump_booster"] = nil end
            pcall(FH_SaveConfig)
        end,
        doToggle   = SP.jpBoosterDoToggle,
        setEnabled = spApplyJumpBooster,
    }
    local function spApplyGiantSpeed(v)
        SP.giantSpeedState = v
        if v then
            SP.giantSpeedKnob.Position         = UDim2.new(0, 22, 0.5, -7)
            SP.giantSpeedKnob.BackgroundColor3 = T.KnobOn
            SP.giantSpeedTrack.BackgroundColor3 = T.TrackOn
            SP.giantSpeedTStroke.Color         = T.TrackOn
            ToggleHandlers.giant_speed(true)
        else
            SP.giantSpeedKnob.Position         = UDim2.new(0, 3, 0.5, -7)
            SP.giantSpeedKnob.BackgroundColor3 = T.KnobOff
            SP.giantSpeedTrack.BackgroundColor3 = T.TrackOff
            SP.giantSpeedTStroke.Color         = T.Border
            ToggleHandlers.giant_speed(false)
        end
        Config.toggles["sp_giant_speed"] = v
        if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
    end
    configRegistry["sp_giant_speed"] = {
        getState   = function() return SP.giantSpeedState end,
        getKeyCode = function() return nil end,
        setKeyCode = function() end,
        doToggle   = SP.giantSpeedDoToggle,
        setEnabled = spApplyGiantSpeed,
    }
    local function spApplyStealOnly(v)
        SP.stealOnlyEnabled = v
        if v then
            SP.stealOnlyKnob.Position         = UDim2.new(0, 14, 0.5, -6)
            SP.stealOnlyKnob.BackgroundColor3 = T.KnobOn
            SP.stealOnlyTrack.BackgroundColor3 = T.TrackOn
            SP.stealOnlyTStroke.Color         = T.TrackOn
            setSpeedBooster(true)
        else
            SP.stealOnlyKnob.Position         = UDim2.new(0, 2, 0.5, -6)
            SP.stealOnlyKnob.BackgroundColor3 = T.KnobOff
            SP.stealOnlyTrack.BackgroundColor3 = T.TrackOff
            SP.stealOnlyTStroke.Color         = T.Border
            setSpeedBooster(false)
        end
        Config.toggles["sp_steal_only"] = v
        if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
    end
    configRegistry["sp_steal_only"] = {
        getState   = function() return SP.stealOnlyEnabled end,
        getKeyCode = function() return SP.stealOnlyEntry and SP.stealOnlyEntry.keyCode end,
        setKeyCode = function(kc)
            if SP.stealOnlyEntry then SP.stealOnlyEntry.keyCode = kc end
            if SP.stealOnlyKbLbl then
                SP.stealOnlyKbLbl.Text = kc and ("["..kc.Name.."]") or ""
                SP.stealOnlyKbLbl.TextColor3 = T.Dim
            end
            Config.keybinds = Config.keybinds or {}
            if kc then Config.keybinds["sp_steal_only"] = kc.Name
            else Config.keybinds["sp_steal_only"] = nil end
            pcall(FH_SaveConfig)
        end,
        doToggle   = function()
            SP.stealOnlyEnabled = not SP.stealOnlyEnabled
            spApplyStealOnly(SP.stealOnlyEnabled)
        end,
        setEnabled = spApplyStealOnly,
    }
end

do
    local function ssApplyPotion(v)
        SS.potionState = v
        if v then
            SS.SSPotionKnob.Position         = UDim2.new(0, 14, 0.5, -6)
            SS.SSPotionKnob.BackgroundColor3 = T.KnobOn
            SS.SSPotionTrack.BackgroundColor3 = T.TrackOn
            SS.SSPotionTStroke.Color         = T.TrackOn
        else
            SS.SSPotionKnob.Position         = UDim2.new(0, 2, 0.5, -6)
            SS.SSPotionKnob.BackgroundColor3 = T.KnobOff
            SS.SSPotionTrack.BackgroundColor3 = T.TrackOff
            SS.SSPotionTStroke.Color         = T.Border
        end
        Config.toggles["ss_potion"] = v
        if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
    end
    configRegistry["ss_potion"] = {
        getState   = function() return SS.potionState end,
        getKeyCode = function() return nil end,
        setKeyCode = function() end,
        doToggle   = function() ssApplyPotion(not SS.potionState) end,
        setEnabled = ssApplyPotion,
    }
end
CreateToggle(PlayerTab.scroll, "Speed Boost Panel",       "Shows speed booster panel.",                  function(v) SP.setSpeedPanelVisible(v) end, function()
    if SP and SP.spBoosterDoToggle then pcall(SP.spBoosterDoToggle) end
end)

do
    local function _fhMakeSlider(parent, title, minV, maxV, defaultV, onChange)

        local cardH = isMobile and 60 or 52
        local card = Instance.new("Frame")
        card.Size                  = UDim2.new(1, -16, 0, cardH)
        card.BackgroundColor3      = T.Card
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel       = 0
        card.Parent                = parent
        Corner(card, 8)
        Stroke(card, T.Border, 1)

        local nameLbl = Label(card, title, isMobile and 13 or 12, T.White, Enum.Font.GothamMedium)
        nameLbl.Size      = UDim2.new(0.5, -12, 0, 16)
        nameLbl.Position  = UDim2.new(0, 12, 0, 6)

        local valBox = Instance.new("TextBox")
        valBox.Size                = UDim2.new(0, isMobile and 58 or 64, 0, 18)
        valBox.AnchorPoint         = Vector2.new(1, 0)
        valBox.Position            = UDim2.new(1, -12, 0, 5)
        valBox.BackgroundColor3    = T.Card
        valBox.BackgroundTransparency = 0.4
        valBox.BorderSizePixel     = 0
        valBox.Text                = tostring(defaultV)
        valBox.TextSize            = isMobile and 12 or 11
        valBox.Font                = Enum.Font.GothamBold
        valBox.TextColor3          = T.White
        valBox.TextXAlignment      = Enum.TextXAlignment.Center
        valBox.ClearTextOnFocus    = false
        valBox.Parent              = card
        Corner(valBox, 4)
        Stroke(valBox, T.Border, 1)

        local track = Instance.new("Frame")
        track.Size                  = UDim2.new(1, -24, 0, 6)
        track.Position              = UDim2.new(0, 12, 1, isMobile and -20 or -16)
        track.BackgroundColor3      = T.TrackOff or Color3.fromRGB(50,50,55)
        track.BorderSizePixel       = 0
        track.Parent                = card
        Corner(track, 3)

        local fill = Instance.new("Frame")
        local pct  = (defaultV - minV) / (maxV - minV)
        fill.Size                   = UDim2.new(pct, 0, 1, 0)
        fill.BackgroundColor3       = _G._FH_AccentA or Color3.fromRGB(120, 200, 255)
        fill.BorderSizePixel        = 0
        fill.Parent                 = track
        Corner(fill, 3)

        local function _applyValue(val, fromBox)
            val = math.clamp(tonumber(val) or minV, minV, maxV)
            val = math.floor(val * 10 + 0.5) / 10
            local rel = (val - minV) / (maxV - minV)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            if not fromBox then valBox.Text = tostring(val) end
            if onChange then pcall(onChange, val) end
            return val
        end

        local dragging = false
        local function setFromX(absX)
            local rel = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            _applyValue(minV + (maxV - minV) * rel, false)
        end
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(inp.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                          or inp.UserInputType == Enum.UserInputType.Touch) then
                setFromX(inp.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        valBox.FocusLost:Connect(function(enterPressed)
            local v = _applyValue(valBox.Text, true)
            valBox.Text = tostring(v)
        end)
        return card
    end

    _G._FH_MakeSlider = _fhMakeSlider
end

CreateSection(PlayerTab.scroll, "Other")
CreateToggle(PlayerTab.scroll, "Aimbot",                  "Websling, laser cape aimbot.",                function(v)
    if v then Aim.startAimbot() else Aim.stopAimbot() end
end)
CreateToggle(PlayerTab.scroll, "Auto Destroy Turrets",    "Deletes turrets that other players place.",   function(v) ToggleHandlers.anti_turret(v) end)
do
    local arEnabled  = false
    local arCard = Instance.new("Frame")
    arCard.Name             = "ARCard"
arCard.Size             = UDim2.new(1, -16, 0, 44)
    arCard.BackgroundColor3 = T.Card
    arCard.BorderSizePixel  = 0
    arCard.ClipsDescendants = false
    arCard.LayoutOrder      = 999
    arCard.Parent           = PlayerTab.scroll
    Corner(arCard, 8)
    local arCardStroke = Stroke(arCard, T.Border, 1)
    local arBar = Instance.new("Frame")
    arBar.Size             = UDim2.new(0, 3, 0, 28)
    arBar.Position         = UDim2.new(0, 0, 0, 8)
    arBar.BackgroundColor3 = T.TrackOff
    arBar.BorderSizePixel  = 0
    arBar.ZIndex           = 2
    arBar.Parent           = arCard
    Corner(arBar, 2)
    local arNameLbl = Label(arCard, "Auto Reset On Balloon", 13, T.White, Enum.Font.GothamMedium)
    arNameLbl.Size     = UDim2.new(1, -100, 0, 16)
    arNameLbl.Position = UDim2.new(0, 10, 0, 10)
    arNameLbl.ZIndex   = 2
    local arTrack = Instance.new("Frame")
    arTrack.Size             = UDim2.new(0, 28, 0, 16)
    arTrack.Position         = UDim2.new(1, -52, 0, 11)
    arTrack.BackgroundColor3 = T.TrackOff
    arTrack.BorderSizePixel  = 0
    arTrack.ZIndex           = 3
    arTrack.Parent           = arCard
    Corner(arTrack, 8)
    local arTrackStroke = Stroke(arTrack, T.Border, 1)
    local arKnob = Instance.new("Frame")
    arKnob.Size             = UDim2.new(0, 12, 0, 12)
    arKnob.Position         = UDim2.new(0, 2, 0.5, -6)
    arKnob.BackgroundColor3 = T.KnobOff
    arKnob.BorderSizePixel  = 0
    arKnob.ZIndex           = 4
    arKnob.Parent           = arTrack
    Corner(arKnob, 6)

    local function doARToggle()
        arEnabled = not arEnabled
        Config.toggles["Auto Reset On Balloon"] = arEnabled
        if arEnabled then
            Tween(arKnob, TweenInfo.new(0.06), {Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,4,0.5,-7)})
            task.delay(0.06, function()
                Tween(arKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,21,0.5,-8)})
                Tween(arKnob,        M, {BackgroundColor3 = T.KnobOn})
                Tween(arTrack,       M, {BackgroundColor3 = T.TrackOn})
                Tween(arTrackStroke, M, {Color = T.TrackOn})
                Tween(arBar,         M, {BackgroundColor3 = T.White})
            end)
            ToggleHandlers.auto_reset_balloon(true)
        else
            Tween(arKnob, TweenInfo.new(0.06), {Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,20,0.5,-7)})
            task.delay(0.06, function()
                Tween(arKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,3,0.5,-8)})
                Tween(arKnob,        M, {BackgroundColor3 = T.KnobOff})
                Tween(arTrack,       M, {BackgroundColor3 = T.TrackOff})
                Tween(arTrackStroke, M, {Color = T.Border})
                Tween(arBar,         M, {BackgroundColor3 = T.TrackOff})
            end)
            ToggleHandlers.auto_reset_balloon(false)
        end
    end
    configRegistry["Auto Reset On Balloon"] = {
        getState   = function() return arEnabled end,
        getKeyCode = function() return nil end,
        setKeyCode = function() end,
        doToggle   = doARToggle,
        setEnabled = function(v)
            arEnabled = v
            Config.toggles["Auto Reset On Balloon"] = v
            if v then
                Tween(arKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,21,0.5,-8)})
                Tween(arKnob,        M, {BackgroundColor3 = T.KnobOn})
                Tween(arTrack,       M, {BackgroundColor3 = T.TrackOn})
                Tween(arTrackStroke, M, {Color = T.TrackOn})
                Tween(arBar,         M, {BackgroundColor3 = T.White})
                ToggleHandlers.auto_reset_balloon(true)
            else
                Tween(arKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,3,0.5,-8)})
                Tween(arKnob,        M, {BackgroundColor3 = T.KnobOff})
                Tween(arTrack,       M, {BackgroundColor3 = T.TrackOff})
                Tween(arTrackStroke, M, {Color = T.Border})
                Tween(arBar,         M, {BackgroundColor3 = T.TrackOff})
                ToggleHandlers.auto_reset_balloon(false)
            end
            if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
        end,
    }
    arCard.MouseEnter:Connect(function()
        Tween(arCard,       F, {BackgroundColor3 = T.CardHover})
        Tween(arCardStroke, F, {Color = T.BorderHover})
    end)
    arCard.MouseLeave:Connect(function()
        Tween(arCard,       F, {BackgroundColor3 = T.Card})
        Tween(arCardStroke, F, {Color = T.Border})
    end)
    local arHit = Instance.new("Frame")
    arHit.Size                   = UDim2.new(1, 0, 1, 0)
    arHit.BackgroundTransparency = 1
    arHit.ZIndex                 = 5
    arHit.Active                 = true
    arHit.Parent                 = arCard
    do
        local _arTouchStart = nil
        arHit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                doARToggle()
            elseif inp.UserInputType == Enum.UserInputType.Touch then
                _arTouchStart = inp.Position
            end
        end)
        arHit.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _arTouchStart then
                local mag = (inp.Position - _arTouchStart).Magnitude
                _arTouchStart = nil
                if mag < 20 then doARToggle() end
            end
        end)
    end
end
do
    local ajEnabled = false
    local ajCard = Instance.new("Frame")
    ajCard.Name             = "AJCard"
ajCard.Size             = UDim2.new(1, -16, 0, 44)
    ajCard.BackgroundColor3 = T.Card
    ajCard.BorderSizePixel  = 0
    ajCard.ClipsDescendants = false
    ajCard.LayoutOrder      = 1001
    ajCard.Parent           = PlayerTab.scroll
    Corner(ajCard, 8)
    local ajCardStroke = Stroke(ajCard, T.Border, 1)
    local ajBar = Instance.new("Frame")
    ajBar.Size             = UDim2.new(0, 3, 0, 28)
    ajBar.Position         = UDim2.new(0, 0, 0, 8)
    ajBar.BackgroundColor3 = T.TrackOff
    ajBar.BorderSizePixel  = 0
    ajBar.ZIndex           = 2
    ajBar.Parent           = ajCard
    Corner(ajBar, 2)
    local ajNameLbl = Label(ajCard, "Auto Reset On Jail", 13, T.White, Enum.Font.GothamMedium)
    ajNameLbl.Size     = UDim2.new(1, -100, 0, 16)
    ajNameLbl.Position = UDim2.new(0, 10, 0, 10)
    ajNameLbl.ZIndex   = 2
    local ajTrack = Instance.new("Frame")
    ajTrack.Size             = UDim2.new(0, 28, 0, 16)
    ajTrack.Position         = UDim2.new(1, -52, 0, 11)
    ajTrack.BackgroundColor3 = T.TrackOff
    ajTrack.BorderSizePixel  = 0
    ajTrack.ZIndex           = 3
    ajTrack.Parent           = ajCard
    Corner(ajTrack, 8)
    local ajTrackStroke = Stroke(ajTrack, T.Border, 1)
    local ajKnob = Instance.new("Frame")
    ajKnob.Size             = UDim2.new(0, 12, 0, 12)
    ajKnob.Position         = UDim2.new(0, 2, 0.5, -6)
    ajKnob.BackgroundColor3 = T.KnobOff
    ajKnob.BorderSizePixel  = 0
    ajKnob.ZIndex           = 4
    ajKnob.Parent           = ajTrack
    Corner(ajKnob, 6)
    local function doAJToggle()
        ajEnabled = not ajEnabled
        Config.toggles["Auto Reset On Jail"] = ajEnabled
        if ajEnabled then
            Tween(ajKnob, TweenInfo.new(0.06), {Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,4,0.5,-7)})
            task.delay(0.06, function()
                Tween(ajKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,21,0.5,-8)})
                Tween(ajKnob,        M, {BackgroundColor3 = T.KnobOn})
                Tween(ajTrack,       M, {BackgroundColor3 = T.TrackOn})
                Tween(ajTrackStroke, M, {Color = T.TrackOn})
                Tween(ajBar,         M, {BackgroundColor3 = T.White})
            end)
            ToggleHandlers.auto_reset_jail(true)
        else
            Tween(ajKnob, TweenInfo.new(0.06), {Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,20,0.5,-7)})
            task.delay(0.06, function()
                Tween(ajKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,3,0.5,-8)})
                Tween(ajKnob,        M, {BackgroundColor3 = T.KnobOff})
                Tween(ajTrack,       M, {BackgroundColor3 = T.TrackOff})
                Tween(ajTrackStroke, M, {Color = T.Border})
                Tween(ajBar,         M, {BackgroundColor3 = T.TrackOff})
            end)
            ToggleHandlers.auto_reset_jail(false)
        end
    end
    configRegistry["Auto Reset On Jail"] = {
        getState   = function() return ajEnabled end,
        getKeyCode = function() return nil end,
        setKeyCode = function() end,
        doToggle   = doAJToggle,
        setEnabled = function(v)
            ajEnabled = v
            Config.toggles["Auto Reset On Jail"] = v
            if v then
                Tween(ajKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,21,0.5,-8)})
                Tween(ajKnob,        M, {BackgroundColor3 = T.KnobOn})
                Tween(ajTrack,       M, {BackgroundColor3 = T.TrackOn})
                Tween(ajTrackStroke, M, {Color = T.TrackOn})
                Tween(ajBar,         M, {BackgroundColor3 = T.White})
                ToggleHandlers.auto_reset_jail(true)
            else
                Tween(ajKnob,        M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,3,0.5,-8)})
                Tween(ajKnob,        M, {BackgroundColor3 = T.KnobOff})
                Tween(ajTrack,       M, {BackgroundColor3 = T.TrackOff})
                Tween(ajTrackStroke, M, {Color = T.Border})
                Tween(ajBar,         M, {BackgroundColor3 = T.TrackOff})
                ToggleHandlers.auto_reset_jail(false)
            end
            if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
        end,
    }
    ajCard.MouseEnter:Connect(function()
        Tween(ajCard,       F, {BackgroundColor3 = T.CardHover})
        Tween(ajCardStroke, F, {Color = T.BorderHover})
    end)
    ajCard.MouseLeave:Connect(function()
        Tween(ajCard,       F, {BackgroundColor3 = T.Card})
        Tween(ajCardStroke, F, {Color = T.Border})
    end)
    local ajHit = Instance.new("Frame")
    ajHit.Size                   = UDim2.new(1, 0, 1, 0)
    ajHit.BackgroundTransparency = 1
    ajHit.ZIndex                 = 5
    ajHit.Active                 = true
    ajHit.Parent                 = ajCard
    do
        local _ajTouchStart = nil
        ajHit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                doAJToggle()
            elseif inp.UserInputType == Enum.UserInputType.Touch then
                _ajTouchStart = inp.Position
            end
        end)
        ajHit.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _ajTouchStart then
                local mag = (inp.Position - _ajTouchStart).Magnitude
                _ajTouchStart = nil
                if mag < 20 then doAJToggle() end
            end
        end)
    end
end

;(function()

    local SearchUserRemote = nil
    local InviteRemote     = nil
    task.spawn(function()
        local children = ReplicatedStorage:GetDescendants()
        for i, obj in ipairs(children) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local nextObj = children[i + 1]
                if nextObj then
                    if obj.Name == "RF/TradeService/SearchUser" then SearchUserRemote = nextObj end
                    if obj.Name == "RF/TradeService/Invite"     then InviteRemote     = nextObj end
                end
            end
            if i % 50 == 0 then task.wait() end
        end
    end)
    local SEARCH_UUID = "792baf13-54a1-4663-92c4-1edd9da1e3e2"
    local INVITE_UUID = "afb005f9-6e81-4e0a-8bb0-3555938a9658"
    local function invokeTrade(userId, onResult)
        if not (SearchUserRemote and InviteRemote) then
            if onResult then onResult(false, "Remotes not ready") end
            return
        end
        task.spawn(function()
            local ok1, found, inGame, canInvite = pcall(function()
                return SearchUserRemote:InvokeServer(SEARCH_UUID, userId)
            end)
            if not (ok1 and found and inGame and canInvite) then
                if onResult then onResult(false, "Not found / offline / busy") end
                return
            end
            local ok2, result = pcall(function()
                return InviteRemote:InvokeServer(INVITE_UUID, userId)
            end)
            if onResult then onResult(ok2 and result, ok2 and "Sent" or "Invite failed") end
        end)
    end
    CreateSection(PlayerTab.scroll, "User Search")

    local PAD              = 8
    local SEARCH_ROW_H     = isMobile and 28 or 32
    local PROF_AV          = isMobile and 40 or 48
    local PROF_ROW_H       = PROF_AV + PAD
    local BTN_W            = isMobile and 70 or 82
    local BTN_H            = isMobile and 22 or 25
    local CARD_H_COLLAPSED = SEARCH_ROW_H + PAD * 2
    local CARD_H_EXPANDED  = CARD_H_COLLAPSED + PROF_ROW_H + PAD

    local card = Instance.new("Frame")
    card.Name             = "USCard"
    card.Size             = UDim2.new(1, -16, 0, CARD_H_COLLAPSED)
    card.BackgroundColor3 = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel  = 0
    card.LayoutOrder      = 9999
    card.ClipsDescendants = true
    card.Parent           = PlayerTab.scroll
    Corner(card, 12)
    local cStroke = Stroke(card, T.Border, 1)

    local searchRow = Instance.new("Frame")
    searchRow.Name                   = "SearchRow"
    searchRow.Size                   = UDim2.new(1, -PAD * 2, 0, SEARCH_ROW_H)
    searchRow.Position               = UDim2.new(0, PAD, 0, PAD)
    searchRow.BackgroundTransparency = 1
    searchRow.ZIndex                 = 2
    searchRow.Parent                 = card
    local SEARCH_BTN_W = isMobile and 56 or 68
    local searchBox = Instance.new("TextBox")
    searchBox.Size                   = UDim2.new(1, -(SEARCH_BTN_W + 8), 1, 0)
    searchBox.Position               = UDim2.new(0, 0, 0, 0)
    searchBox.BackgroundColor3       = Color3.fromRGB(20, 20, 24)
    searchBox.BorderSizePixel        = 0
    searchBox.PlaceholderText        = "Search by username..."
    searchBox.Text                   = ""
    searchBox.TextSize               = isMobile and 11 or 13
    searchBox.Font                   = Enum.Font.Gotham
    searchBox.TextColor3             = T.White
    searchBox.PlaceholderColor3      = T.Dim
    searchBox.TextXAlignment         = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus       = false
    searchBox.ZIndex                 = 3
    searchBox.Parent                 = searchRow
    Corner(searchBox, 8)
    local searchBoxStroke = Stroke(searchBox, T.Border, 1)
    Padding(searchBox, 0, 0, 12, 12)
    searchBox.Focused:Connect(function() Tween(searchBoxStroke, F, { Color = T.White }) end)
    searchBox.FocusLost:Connect(function() Tween(searchBoxStroke, F, { Color = T.Border }) end)
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size             = UDim2.new(0, SEARCH_BTN_W, 1, 0)
    searchBtn.Position         = UDim2.new(1, -SEARCH_BTN_W, 0, 0)
    searchBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    searchBtn.BorderSizePixel  = 0
    searchBtn.Text             = "Find"
    searchBtn.TextSize         = isMobile and 11 or 13
    searchBtn.Font             = Enum.Font.GothamBold
    searchBtn.TextColor3       = Color3.fromRGB(15, 15, 15)
    searchBtn.AutoButtonColor  = false
    searchBtn.ZIndex           = 3
    searchBtn.Parent           = searchRow
    Corner(searchBtn, 8)

    local profile = Instance.new("Frame")
    profile.Name                   = "Profile"
    profile.Size                   = UDim2.new(1, -PAD * 2, 0, PROF_ROW_H)
    profile.Position               = UDim2.new(0, PAD, 0, PAD * 2 + SEARCH_ROW_H)
    profile.BackgroundColor3       = Color3.fromRGB(16, 16, 20)
    profile.BackgroundTransparency = 0.1
    profile.BorderSizePixel        = 0
    profile.Visible                = false
    profile.ZIndex                 = 2
    profile.Parent                 = card
    Corner(profile, 10)
    Stroke(profile, T.Border, 1)

    local avFrame = Instance.new("Frame")
    avFrame.Position              = UDim2.new(0, PAD, 0.5, -PROF_AV / 2)
    avFrame.Size                  = UDim2.new(0, PROF_AV, 0, PROF_AV)
    avFrame.BackgroundColor3      = Color3.fromRGB(24, 24, 28)
    avFrame.BorderSizePixel       = 0
    avFrame.ClipsDescendants      = true
    avFrame.ZIndex                = 3
    avFrame.Parent                = profile
    Instance.new("UICorner", avFrame).CornerRadius = UDim.new(1, 0)
    local avRing = Instance.new("UIStroke", avFrame)
    avRing.Color     = T.White
    avRing.Thickness = 1
    avRing.Transparency = 0.6
    local avImg = Instance.new("ImageLabel")
    avImg.Size                   = UDim2.new(1, 0, 1, 0)
    avImg.BackgroundTransparency = 1
    avImg.Image                  = ""
    avImg.ZIndex                 = 4
    avImg.Parent                 = avFrame

    local SDOT = 8
    local searchDot = Instance.new("Frame")
    searchDot.Size              = UDim2.new(0, SDOT, 0, SDOT)
    searchDot.Position          = UDim2.new(1, -1, 1, -1)
    searchDot.AnchorPoint       = Vector2.new(1, 1)
    searchDot.BackgroundColor3  = Color3.fromRGB(60, 60, 65)
    searchDot.BorderSizePixel   = 0
    searchDot.ZIndex            = 5
    searchDot.Parent            = avFrame
    Instance.new("UICorner", searchDot).CornerRadius = UDim.new(1, 0)
    local sdotRing = Instance.new("UIStroke", searchDot)
    sdotRing.Color           = Color3.fromRGB(16, 16, 20)
    sdotRing.Thickness       = 2
    sdotRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local TEXT_X      = PAD + PROF_AV + PAD
    local BTN_RIGHT_W = BTN_W + PAD
    local TEXT_W      = -(TEXT_X + BTN_RIGHT_W + PAD)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Position              = UDim2.new(0, TEXT_X, 0, PAD - 2)
    nameLbl.Size                  = UDim2.new(1, TEXT_W, 0, isMobile and 14 or 16)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text                  = ""
    nameLbl.TextSize              = isMobile and 12 or 14
    nameLbl.Font                  = Enum.Font.GothamBold
    nameLbl.TextColor3            = T.White
    nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
    nameLbl.TextTruncate          = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex                = 3
    nameLbl.Parent                = profile

    local idLbl = Instance.new("TextLabel")
    idLbl.Position              = UDim2.new(0, TEXT_X, 0, (isMobile and 18 or 22))
    idLbl.Size                  = UDim2.new(1, TEXT_W, 0, isMobile and 11 or 13)
    idLbl.BackgroundTransparency = 1
    idLbl.Text                  = ""
    idLbl.TextSize              = isMobile and 9 or 10
    idLbl.Font                  = Enum.Font.Gotham
    idLbl.TextColor3            = T.Dim
    idLbl.TextXAlignment        = Enum.TextXAlignment.Left
    idLbl.TextTruncate          = Enum.TextTruncate.AtEnd
    idLbl.ZIndex                = 3
    idLbl.Parent                = profile

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Position              = UDim2.new(0, TEXT_X, 0, (isMobile and 31 or 38))
    statusLbl.Size                  = UDim2.new(1, TEXT_W, 0, isMobile and 10 or 12)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text                  = ""
    statusLbl.TextSize              = isMobile and 9 or 10
    statusLbl.Font                  = Enum.Font.GothamMedium
    statusLbl.TextColor3            = T.Dim
    statusLbl.TextXAlignment        = Enum.TextXAlignment.Left
    statusLbl.ZIndex                = 3
    statusLbl.Parent                = profile

    local function _mkProfileBtn(text, bg, fg, yOff, hoverBg)
        local b = Instance.new("TextButton")
        b.Size             = UDim2.new(0, BTN_W, 0, BTN_H)
        b.Position         = UDim2.new(1, -(BTN_W + PAD), 0, yOff)
        b.BackgroundColor3 = bg
        b.BorderSizePixel  = 0
        b.Text             = text
        b.TextSize         = isMobile and 10 or 11
        b.Font             = Enum.Font.GothamBold
        b.TextColor3       = fg
        b.AutoButtonColor  = false
        b.ZIndex           = 4
        b.Parent           = profile
        Corner(b, 7)
        Stroke(b, Color3.fromRGB(70, 70, 76), 1)
        b.MouseEnter:Connect(function() Tween(b, F, { BackgroundColor3 = hoverBg or T.CardHover }) end)
        b.MouseLeave:Connect(function() Tween(b, F, { BackgroundColor3 = bg }) end)
        return b
    end
    local totalBtnH = BTN_H * 2 + 4
    local btnStartY = math.floor((PROF_ROW_H - totalBtnH) / 2)
    local copyBtn  = _mkProfileBtn("Copy",  Color3.fromRGB(30, 30, 34), T.White,
                                   btnStartY, Color3.fromRGB(46, 46, 52))
    local tradeBtn = _mkProfileBtn("Trade", Color3.fromRGB(245, 245, 245), Color3.fromRGB(15, 15, 15),
                                   btnStartY + BTN_H + 4, Color3.fromRGB(220, 220, 220))

    local currentUserId   = nil
    local currentUserName = nil
    local CARD_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local function setStatus(text, color)
        statusLbl.Text       = text or ""
        statusLbl.TextColor3 = color or T.Dim
    end
    local function showProfile(visible)
        if visible == profile.Visible then return end
        profile.Visible = visible
        local target = visible and CARD_H_EXPANDED or CARD_H_COLLAPSED
        TweenService:Create(card, CARD_TWEEN, { Size = UDim2.new(1, -16, 0, target) }):Play()
    end

    local _presenceJob = 0
    local function _stopPresence()
        _presenceJob = _presenceJob + 1
        searchDot.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
    local function _startPresence(userId)
        _presenceJob = _presenceJob + 1
        local myJob = _presenceJob
        searchDot.BackgroundColor3 = Players:GetPlayerByUserId(userId)
            and Color3.fromRGB(120, 220, 130)
            or  Color3.fromRGB(60, 60, 65)
        local httpReq = (syn and syn.request) or http_request or request
        if not httpReq then return end
        task.spawn(function()
            while myJob == _presenceJob and searchDot.Parent do
                local ok, res = pcall(function()
                    return httpReq({
                        Url     = "https://presence.roblox.com/v1/presence/users",
                        Method  = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body    = HttpService:JSONEncode({ userIds = { userId } }),
                    })
                end)
                if ok and res and res.Body then
                    local d; pcall(function() d = HttpService:JSONDecode(res.Body) end)
                    if d and d.userPresences and d.userPresences[1] then
                        local p = d.userPresences[1]
                        local isOnline = (tonumber(p.userPresenceType) or 0) ~= 0
                        if myJob == _presenceJob and searchDot.Parent then
                            searchDot.BackgroundColor3 = isOnline
                                and Color3.fromRGB(120, 220, 130)
                                or  Color3.fromRGB(230, 110, 110)
                        end
                    end
                end
                task.wait(4)
            end
        end)
    end

    local function setUser(userId, displayName, username)
        currentUserId   = userId
        currentUserName = username or displayName
        nameLbl.Text  = displayName or username or "Unknown"
        idLbl.Text    = (username and ("@" .. username .. "  |  ID: " .. tostring(userId)))
                        or ("ID: " .. tostring(userId))
        avImg.Image   = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
        showProfile(true)
        _startPresence(userId)
    end
    local function clearUser()
        currentUserId, currentUserName = nil, nil
        nameLbl.Text = ""
        idLbl.Text   = ""
        avImg.Image  = ""
        showProfile(false)
        _stopPresence()
    end

    local _isSearching = false
    local function doSearch()
        if _isSearching then return end
        local q = (searchBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if q == "" then
            clearUser()
            setStatus("Enter a username", Color3.fromRGB(220, 180, 90))
            return
        end
        _isSearching = true
        searchBtn.Text = "..."
        setStatus("Looking up " .. q, T.Dim)
        task.spawn(function()
            local idAttempt = tonumber(q)
            local ok, info = pcall(function()
                if idAttempt then
                    return { UserId = idAttempt, Name = Players:GetNameFromUserIdAsync(idAttempt), Username = nil }
                else
                    local uid = Players:GetUserIdFromNameAsync(q)
                    return { UserId = uid, Name = Players:GetNameFromUserIdAsync(uid), Username = q }
                end
            end)
            searchBtn.Text = "Find"
            _isSearching = false
            if not ok or not info or not info.UserId then
                clearUser()
                setStatus("Not found: " .. q, Color3.fromRGB(230, 110, 110))
                return
            end
            setUser(info.UserId, info.Name, info.Username)
            setStatus("Profile loaded", Color3.fromRGB(120, 220, 130))
        end)
    end

    searchBtn.MouseEnter:Connect(function() Tween(searchBtn, F, { BackgroundColor3 = Color3.fromRGB(220, 220, 220) }) end)
    searchBtn.MouseLeave:Connect(function() Tween(searchBtn, F, { BackgroundColor3 = Color3.fromRGB(245, 245, 245) }) end)
    searchBtn.MouseButton1Click:Connect(doSearch)
    searchBox.FocusLost:Connect(function(enterPressed) if enterPressed then doSearch() end end)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if searchBox.Text == "" then
            clearUser()
            setStatus("", T.Dim)
        end
    end)
    copyBtn.MouseButton1Click:Connect(function()
        if not currentUserId then return end
        local url = "https://www.roblox.com/users/" .. tostring(currentUserId) .. "/profile"
        local copied = false
        pcall(function() setclipboard(url); copied = true end)
        if not copied then pcall(function() toclipboard(url); copied = true end) end
        setStatus(copied and "Profile link copied" or "Clipboard unsupported",
                  copied and Color3.fromRGB(120, 220, 130) or Color3.fromRGB(230, 110, 110))
    end)
    tradeBtn.MouseButton1Click:Connect(function()
        if not currentUserId then return end
        setStatus("Sending trade...", T.Dim)
        invokeTrade(currentUserId, function(success, msg)
            setStatus(success and ("Trade " .. (msg or "sent"))
                              or ("Trade failed: " .. tostring(msg or "?")),
                      success and Color3.fromRGB(120, 220, 130)
                              or  Color3.fromRGB(230, 110, 110))
        end)
    end)
    local _cardHov = false
    card.MouseEnter:Connect(function()
        if _cardHov then return end
        _cardHov = true
        Tween(card,    F, {BackgroundColor3 = T.CardHover})
        Tween(cStroke, F, {Color = T.BorderHover})
    end)
    card.MouseLeave:Connect(function()
        if not _cardHov then return end
        _cardHov = false
        Tween(card,    F, {BackgroundColor3 = T.Card})
        Tween(cStroke, F, {Color = T.Border})
    end)
end)()

do
    local function _hsvToColor(h, s, v)
        return Color3.fromHSV(h % 1, math.clamp(s, 0, 1), math.clamp(v, 0, 1))
    end
    local function _rgbToHsv(c)
        local r, g, b = c.R, c.G, c.B
        local mx, mn = math.max(r, g, b), math.min(r, g, b)
        local d = mx - mn
        local h
        if d == 0 then h = 0
        elseif mx == r then h = ((g - b) / d) % 6
        elseif mx == g then h = (b - r) / d + 2
        else                h = (r - g) / d + 4 end
        h = h / 6
        if h < 0 then h = h + 1 end
        local s = (mx == 0) and 0 or (d / mx)
        return h, s, mx
    end
    CreateSection(MiscTab.scroll, "UI THEME")
    local CARD_H = 96
    local themeCard = Instance.new("Frame")
    themeCard.Size             = UDim2.new(1, -16, 0, CARD_H)
    themeCard.BackgroundColor3 = T.Card
    themeCard.BackgroundTransparency = 0.15
    themeCard.BorderSizePixel  = 0
    themeCard.LayoutOrder      = -1000
    themeCard.Parent           = MiscTab.scroll
    Corner(themeCard, 10)
    do
        local tcStroke = Stroke(themeCard, Color3.fromRGB(255, 255, 255), 1)
        _FH_AddThemeStroke(tcStroke)
    end
    local titleLbl = Label(themeCard, "Accent Colors", isMobile and 11 or 13, T.White, Enum.Font.GothamBold)
    titleLbl.Size     = UDim2.new(1, -20, 0, 16)
    titleLbl.Position = UDim2.new(0, 12, 0, 10)
    titleLbl.ZIndex   = 2
    local subLbl = Label(themeCard, "Tap a swatch — changes apply instantly", isMobile and 9 or 10, T.Dim, Enum.Font.Gotham)
    subLbl.Size     = UDim2.new(1, -20, 0, 12)
    subLbl.Position = UDim2.new(0, 12, 0, 28)
    subLbl.ZIndex   = 2

    local SW_W, SW_H = isMobile and 70 or 84, 32
    local function _makeSwatch(label, x, getColor, onOpen)
        local sw = Instance.new("TextButton")
        sw.Size             = UDim2.new(0, SW_W, 0, SW_H)
        sw.Position         = UDim2.new(0, x, 0, 50)
        sw.BackgroundColor3 = getColor()
        sw.BorderSizePixel  = 0
        sw.Text             = label
        sw.TextSize         = 10
        sw.Font             = Enum.Font.GothamBold
        sw.TextColor3       = Color3.fromRGB(20, 20, 20)
        sw.AutoButtonColor  = false
        sw.ZIndex           = 3
        sw.Parent           = themeCard
        Corner(sw, 8)
        do
            local swStroke = Stroke(sw, Color3.fromRGB(255, 255, 255), 1)
            _FH_AddThemeStroke(swStroke)
        end
        sw.MouseButton1Click:Connect(onOpen)
        return sw
    end
    local swA, swB
    local pickerOpen = false
    local function _openPicker(slot)
        if pickerOpen then return end
        pickerOpen = true
        local W, H = isMobile and 240 or 280, isMobile and 240 or 270
        local modal = Instance.new("Frame")
        modal.Size             = UDim2.new(0, W, 0, H)
        modal.AnchorPoint      = Vector2.new(0.5, 0.5)
        modal.Position         = UDim2.new(0.5, 0, 0.5, 0)
        modal.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
        modal.BackgroundTransparency = 0.05
        modal.BorderSizePixel  = 0
        modal.ZIndex           = 60
        modal.Parent           = GUI
        Corner(modal, 12)
        local modalStroke = Stroke(modal, Color3.fromRGB(255, 255, 255), 1)
        _FH_AddThemeStroke(modalStroke)

        local hdr = Instance.new("Frame")
        hdr.Size                   = UDim2.new(1, 0, 0, 30)
        hdr.BackgroundColor3       = Color3.fromRGB(10, 10, 10)
        hdr.BorderSizePixel        = 0
        hdr.ZIndex                 = 61
        hdr.Parent                 = modal
        Corner(hdr, 12)
        local hdrLbl = Label(hdr, slot == "a" and "Pick Accent A" or "Pick Accent B", 12, T.White, Enum.Font.GothamBold)
        hdrLbl.Size          = UDim2.new(1, -40, 1, 0)
        hdrLbl.Position      = UDim2.new(0, 12, 0, 0)
        hdrLbl.TextYAlignment = Enum.TextYAlignment.Center
        hdrLbl.ZIndex        = 62
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size             = UDim2.new(0, 22, 0, 22)
        closeBtn.Position         = UDim2.new(1, -28, 0.5, -11)
        closeBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        closeBtn.BorderSizePixel  = 0
        closeBtn.Text             = "×"
        closeBtn.TextSize         = 14
        closeBtn.Font             = Enum.Font.GothamBold
        closeBtn.TextColor3       = T.White
        closeBtn.AutoButtonColor  = false
        closeBtn.ZIndex           = 62
        closeBtn.Parent           = hdr
        Corner(closeBtn, 6)

        local startColor = (slot == "a") and _G._FH_AccentA or _G._FH_AccentB
        local curH, curS, curV = _rgbToHsv(startColor)

        local SQ = isMobile and 150 or 170
        local HUE_H = 16
        local PADX = (W - SQ) / 2

        local sv = Instance.new("Frame")
        sv.Size                   = UDim2.new(0, SQ, 0, SQ)
        sv.Position               = UDim2.new(0, PADX, 0, 40)
        sv.BackgroundColor3       = _hsvToColor(curH, 1, 1)
        sv.BorderSizePixel        = 0
        sv.ZIndex                 = 61
        sv.Active                 = true
        sv.Parent                 = modal
        Corner(sv, 6)

        local whiteOv = Instance.new("Frame")
        whiteOv.Size                   = UDim2.new(1, 0, 1, 0)
        whiteOv.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
        whiteOv.BorderSizePixel        = 0
        whiteOv.ZIndex                 = 62
        whiteOv.Parent                 = sv
        Corner(whiteOv, 6)
        do
            local g = Instance.new("UIGradient", whiteOv)
            g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            g.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
        end

        local blackOv = Instance.new("Frame")
        blackOv.Size                   = UDim2.new(1, 0, 1, 0)
        blackOv.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
        blackOv.BorderSizePixel        = 0
        blackOv.ZIndex                 = 63
        blackOv.Parent                 = sv
        Corner(blackOv, 6)
        do
            local g = Instance.new("UIGradient", blackOv)
            g.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0))
            g.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0),
            })
            g.Rotation = 90
        end

        local svDot = Instance.new("Frame")
        svDot.AnchorPoint           = Vector2.new(0.5, 0.5)
        svDot.Size                  = UDim2.new(0, 12, 0, 12)
        svDot.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
        svDot.BackgroundTransparency = 1
        svDot.BorderSizePixel       = 0
        svDot.ZIndex                = 65
        svDot.Parent                = sv
        Instance.new("UICorner", svDot).CornerRadius = UDim.new(1, 0)
        Stroke(svDot, Color3.fromRGB(255, 255, 255), 2)

        local hue = Instance.new("Frame")
        hue.Size             = UDim2.new(0, SQ, 0, HUE_H)
        hue.Position         = UDim2.new(0, PADX, 0, 40 + SQ + 10)
        hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hue.BorderSizePixel  = 0
        hue.ZIndex           = 61
        hue.Active           = true
        hue.Parent           = modal
        Corner(hue, HUE_H/2)
        do
            local g = Instance.new("UIGradient", hue)
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0)),
            })
        end
        local hueDot = Instance.new("Frame")
        hueDot.AnchorPoint      = Vector2.new(0.5, 0.5)
        hueDot.Size             = UDim2.new(0, 4, 1, 4)
        hueDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueDot.BorderSizePixel  = 0
        hueDot.ZIndex           = 64
        hueDot.Parent           = hue
        Stroke(hueDot, Color3.fromRGB(0, 0, 0), 1)
        Corner(hueDot, 2)

        local preview = Instance.new("Frame")
        preview.Size             = UDim2.new(0, 28, 0, 28)
        preview.Position         = UDim2.new(0, PADX, 1, -42)
        preview.BackgroundColor3 = startColor
        preview.BorderSizePixel  = 0
        preview.ZIndex           = 61
        preview.Parent           = modal
        Corner(preview, 6)
        Stroke(preview, T.Border, 1)
        local hexLbl = Label(modal, "", 12, T.White, Enum.Font.GothamMedium)
        hexLbl.Size     = UDim2.new(0, 100, 0, 28)
        hexLbl.Position = UDim2.new(0, PADX + 36, 1, -42)
        hexLbl.TextXAlignment = Enum.TextXAlignment.Left
        hexLbl.TextYAlignment = Enum.TextYAlignment.Center
        hexLbl.ZIndex   = 62
        local function refresh()
            local col = _hsvToColor(curH, curS, curV)
            sv.BackgroundColor3 = _hsvToColor(curH, 1, 1)
            preview.BackgroundColor3 = col
            hexLbl.Text = string.format("#%02X%02X%02X",
                math.floor(col.R * 255 + 0.5),
                math.floor(col.G * 255 + 0.5),
                math.floor(col.B * 255 + 0.5))
            svDot.Position = UDim2.new(curS, 0, 1 - curV, 0)
            hueDot.Position = UDim2.new(curH, 0, 0.5, 0)

            if slot == "a" then
                _G._FH_AccentA = col
                swA.BackgroundColor3 = col
            else
                _G._FH_AccentB = col
                swB.BackgroundColor3 = col
            end
            local seq = _FH_BuildThemeSequence()
            for _, g in ipairs(_G._FH_ThemeStrokes) do pcall(function() g.Color = seq end) end
            for _, g in ipairs(_G._FH_ThemeFills)   do pcall(function() g.Color = seq end) end

            if _G._FH_RecolorPlayerESP then pcall(_G._FH_RecolorPlayerESP) end
        end
        refresh()

        do
            local active = false
            local function update(inp)
                local abs = sv.AbsolutePosition
                local sz  = sv.AbsoluteSize
                if sz.X <= 0 or sz.Y <= 0 then return end
                local px = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
                local py = math.clamp((inp.Position.Y - abs.Y) / sz.Y, 0, 1)
                curS = px
                curV = 1 - py
                refresh()
            end
            sv.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    active = true
                    update(inp)
                end
            end)
            sv.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    if active then _FH_UpdateThemeColors() end
                    active = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if active and (inp.UserInputType == Enum.UserInputType.MouseMovement
                            or inp.UserInputType == Enum.UserInputType.Touch) then
                    update(inp)
                end
            end)
        end

        do
            local active = false
            local function update(inp)
                local abs = hue.AbsolutePosition
                local sz  = hue.AbsoluteSize
                if sz.X <= 0 then return end
                curH = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
                refresh()
            end
            hue.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    active = true
                    update(inp)
                end
            end)
            hue.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    if active then _FH_UpdateThemeColors() end
                    active = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if active and (inp.UserInputType == Enum.UserInputType.MouseMovement
                            or inp.UserInputType == Enum.UserInputType.Touch) then
                    update(inp)
                end
            end)
        end
        local function closeModal()
            pickerOpen = false
            if modal and modal.Parent then modal:Destroy() end
        end
        closeBtn.MouseButton1Click:Connect(function()
            _FH_UpdateThemeColors()
            closeModal()
        end)

        do
            local d, ds, ps = false, nil, nil
            hdr.Active = true
            hdr.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    d = true; ds = inp.Position; ps = modal.Position
                end
            end)
            hdr.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    d = false
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if d and (inp.UserInputType == Enum.UserInputType.MouseMovement
                       or inp.UserInputType == Enum.UserInputType.Touch) then
                    local dx, dy = inp.Position.X - ds.X, inp.Position.Y - ds.Y
                    modal.Position = UDim2.new(ps.X.Scale, ps.X.Offset + dx, ps.Y.Scale, ps.Y.Offset + dy)
                end
            end)
        end
    end
    swA = _makeSwatch("A", 12,         function() return _G._FH_AccentA end, function() _openPicker("a") end)
    swB = _makeSwatch("B", 12 + SW_W + 8, function() return _G._FH_AccentB end, function() _openPicker("b") end)

    local preview = Instance.new("Frame")
    preview.Size             = UDim2.new(1, -(12 + (SW_W + 8) * 2 + 12), 0, SW_H)
    preview.Position         = UDim2.new(0, 12 + (SW_W + 8) * 2, 0, 50)
    preview.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    preview.BorderSizePixel  = 0
    preview.ZIndex           = 3
    preview.Parent           = themeCard
    Corner(preview, 8)
    _FH_AddThemeFill(preview)
end

do

    do
        local saved = Config.sliders and Config.sliders.subspace_mine_color
        if type(saved) == "table" and #saved == 3 then
            _G._FH_SubspaceColor = Color3.fromRGB(
                tonumber(saved[1]) or 255,
                tonumber(saved[2]) or 255,
                tonumber(saved[3]) or 255
            )
        else
            _G._FH_SubspaceColor = Color3.fromRGB(255, 255, 255)
        end
    end

    CreateSection(MiscTab.scroll, "Subspace Mine ESP")

    local CARD_H = isMobile and 96 or 108
    local card = Instance.new("Frame")
    card.Size                   = UDim2.new(1, -16, 0, CARD_H)
    card.BackgroundColor3       = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel        = 0
    card.LayoutOrder            = -990
    card.Parent                 = MiscTab.scroll
    Corner(card, 10)
    do
        local cStroke = Stroke(card, Color3.fromRGB(255, 255, 255), 1)
        _FH_AddThemeStroke(cStroke)
    end

    local titleLbl = Label(card, "Subspace Mine Color", isMobile and 11 or 13, T.White, Enum.Font.GothamBold)
    titleLbl.Size     = UDim2.new(1, -90, 0, 16)
    titleLbl.Position = UDim2.new(0, 12, 0, 10)
    titleLbl.ZIndex   = 2

    local hexLbl = Label(card, "", isMobile and 9 or 10, T.Dim, Enum.Font.Code)
    hexLbl.Size              = UDim2.new(0, 76, 0, 16)
    hexLbl.Position          = UDim2.new(1, -84, 0, 10)
    hexLbl.TextXAlignment    = Enum.TextXAlignment.Right
    hexLbl.ZIndex            = 2

    local subLbl = Label(card, "Tap a swatch — applies live to every mine box", isMobile and 8 or 10, T.Dim, Enum.Font.Gotham)
    subLbl.Size     = UDim2.new(1, -20, 0, 12)
    subLbl.Position = UDim2.new(0, 12, 0, 28)
    subLbl.ZIndex   = 2

    local previewBar = Instance.new("Frame")
    previewBar.Size                   = UDim2.new(1, -24, 0, 14)
    previewBar.Position               = UDim2.new(0, 12, 0, 44)
    previewBar.BackgroundColor3       = _G._FH_SubspaceColor
    previewBar.BorderSizePixel        = 0
    previewBar.ZIndex                 = 2
    previewBar.Parent                 = card
    Corner(previewBar, 7)
    Stroke(previewBar, Color3.fromRGB(40, 40, 40), 1)

    local chipsRow = Instance.new("Frame")
    chipsRow.Size                   = UDim2.new(1, -24, 0, isMobile and 26 or 30)
    chipsRow.Position               = UDim2.new(0, 12, 0, 64)
    chipsRow.BackgroundTransparency = 1
    chipsRow.ZIndex                 = 2
    chipsRow.Parent                 = card

    local chipsLayout = Instance.new("UIListLayout")
    chipsLayout.FillDirection        = Enum.FillDirection.Horizontal
    chipsLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Left
    chipsLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
    chipsLayout.Padding              = UDim.new(0, isMobile and 5 or 6)
    chipsLayout.SortOrder            = Enum.SortOrder.LayoutOrder
    chipsLayout.Parent               = chipsRow

    local PRESETS = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255,  70,  70),
        Color3.fromRGB(255, 150,  40),
        Color3.fromRGB(255, 230,  60),
        Color3.fromRGB( 70, 230, 110),
        Color3.fromRGB( 60, 220, 230),
        Color3.fromRGB( 80, 140, 255),
        Color3.fromRGB(220, 110, 255),
    }

    local CHIP_SZ = isMobile and 22 or 26
    local chipFrames = {}

    local function _colorsEqual(a, b)
        return math.abs(a.R - b.R) < 0.01
            and math.abs(a.G - b.G) < 0.01
            and math.abs(a.B - b.B) < 0.01
    end

    local function _refreshHex()
        local c = _G._FH_SubspaceColor
        hexLbl.Text = string.format("#%02X%02X%02X",
            math.floor(c.R * 255 + 0.5),
            math.floor(c.G * 255 + 0.5),
            math.floor(c.B * 255 + 0.5))
    end

    local function _updateActiveRing()
        for col, info in pairs(chipFrames) do
            local active = _colorsEqual(col, _G._FH_SubspaceColor)
            info.stroke.Color     = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
            info.stroke.Thickness = active and 2 or 1
        end
    end

    local function _commitColor(col)
        _G._FH_SubspaceColor = col
        previewBar.BackgroundColor3 = col
        _refreshHex()
        _updateActiveRing()
        Config.sliders = Config.sliders or {}
        Config.sliders.subspace_mine_color = {
            math.floor(col.R * 255 + 0.5),
            math.floor(col.G * 255 + 0.5),
            math.floor(col.B * 255 + 0.5),
        }
        pcall(FH_SaveConfig)
        if _G._FH_SubspaceRecolor then pcall(_G._FH_SubspaceRecolor) end
    end

    for i, col in ipairs(PRESETS) do
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(0, CHIP_SZ, 0, CHIP_SZ)
        btn.BackgroundColor3 = col
        btn.BorderSizePixel  = 0
        btn.Text             = ""
        btn.AutoButtonColor  = false
        btn.LayoutOrder      = i
        btn.ZIndex           = 3
        btn.Parent           = chipsRow
        local round = Instance.new("UICorner")
        round.CornerRadius = UDim.new(1, 0)
        round.Parent       = btn
        local chipStroke = Stroke(btn, Color3.fromRGB(50, 50, 50), 1)
        chipFrames[col] = { btn = btn, stroke = chipStroke }
        btn.MouseEnter:Connect(function()
            if not _colorsEqual(col, _G._FH_SubspaceColor) then
                Tween(btn, F, { Size = UDim2.new(0, CHIP_SZ + 2, 0, CHIP_SZ + 2) })
            end
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, F, { Size = UDim2.new(0, CHIP_SZ, 0, CHIP_SZ) })
        end)
        btn.MouseButton1Click:Connect(function() _commitColor(col) end)
    end

    _refreshHex()
    _updateActiveRing()
end

CreateSection(MiscTab.scroll, "Admin Panel Uses")
CreateToggle(MiscTab.scroll, "Spammer Panel", "Opens an Admin Panel panel", function(v)
    if not _G.SpammerGui then
        local spamW, spamH = isMobile and 190 or 220, isMobile and 220 or 260
        local spamBorder = Instance.new("Frame")
        spamBorder.Name = "SpammerGradBorder"
spamBorder.Size = UDim2.new(0, spamW + 4, 0, spamH + 4)
        spamBorder.Position = UDim2.new(0.5, -(spamW + 4)/2, 0, 140)
        spamBorder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        spamBorder.BorderSizePixel = 0
        spamBorder.ZIndex = 18
        spamBorder.Parent = GUI
        spamBorder.BackgroundTransparency = 1
        Corner(spamBorder, 12)
        local spamWin = Instance.new("Frame")
        spamWin.Name = "SpammerPanel"
spamWin.Size = UDim2.new(0, spamW, 0, spamH)
        spamWin.Position = UDim2.new(0.5, -spamW/2, 0, 142)
        spamWin.BackgroundColor3       = T.BG
        spamWin.BackgroundTransparency = 0.25
        spamWin.BorderSizePixel = 0
        spamWin.ZIndex = 19
        spamWin.ClipsDescendants = true
        spamWin.Parent = GUI
        Corner(spamWin, 10)
        local spamHdr = Instance.new("Frame")
        spamHdr.Size = UDim2.new(1, 0, 0, 36)
        spamHdr.BackgroundColor3 = T.Header
        spamHdr.BorderSizePixel = 0
        spamHdr.ZIndex = 20
        spamHdr.Active = true
        spamHdr.Parent = spamWin
        Corner(spamHdr, 10)
        local spamHdrFill = Instance.new("Frame")
        spamHdrFill.Size = UDim2.new(1, 0, 0, 10)
        spamHdrFill.Position = UDim2.new(0, 0, 1, -10)
        spamHdrFill.BackgroundColor3 = T.Header
        spamHdrFill.BorderSizePixel = 0
        spamHdrFill.ZIndex = 20
        spamHdrFill.Parent = spamHdr
        local spamHdrLine = Instance.new("Frame")
        spamHdrLine.Size = UDim2.new(1, 0, 0, 1)
        spamHdrLine.Position = UDim2.new(0, 0, 1, -1)
        spamHdrLine.BackgroundColor3 = T.Border
        spamHdrLine.BorderSizePixel = 0
        spamHdrLine.ZIndex = 21
        spamHdrLine.Parent = spamHdr
        local spamTitle = Label(spamHdr, "Admin Spammer", 13, T.White, Enum.Font.GothamBold)
        spamTitle.Size = UDim2.new(1, -40, 1, 0)
        spamTitle.Position = UDim2.new(0, 12, 0, 0)
        spamTitle.TextYAlignment = Enum.TextYAlignment.Center
        spamTitle.ZIndex = 22
        local spamClose = Instance.new("TextButton")
        spamClose.Size = UDim2.new(0, 22, 0, 22)
        spamClose.Position = UDim2.new(1, -28, 0.5, -11)
        spamClose.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        spamClose.BorderSizePixel = 0
        spamClose.Text = "×"
spamClose.TextSize = 14
        spamClose.Font = Enum.Font.GothamBold
        spamClose.TextColor3 = T.White
        spamClose.ZIndex = 23
        spamClose.Parent = spamHdr
        Corner(spamClose, 6)
        spamClose.MouseButton1Click:Connect(function()
            spamWin.Visible = false
            spamBorder.Visible = false
            local reg = configRegistry["Spammer Panel"]
            if reg and reg.getState() then reg.doToggle() end
        end)
        local spamHint = Instance.new("TextLabel")
        spamHint.Size = UDim2.new(1, -16, 0, 24)
        spamHint.Position = UDim2.new(0, 8, 0, 40)
        spamHint.BackgroundTransparency = 1
        spamHint.Text = "Click ⚙ to edit Semi/Full • Right-click Spam Closest to bind key"
spamHint.TextSize = 10
        spamHint.Font = Enum.Font.Gotham
        spamHint.TextColor3 = T.Dim
        spamHint.TextWrapped = true
        spamHint.ZIndex = 20
        spamHint.Parent = spamWin
        local plrLbl = Instance.new("TextLabel")
        plrLbl.Size = UDim2.new(1, -16, 0, 14)
        plrLbl.Position = UDim2.new(0, 8, 0, 66)
        plrLbl.BackgroundTransparency = 1
        plrLbl.Text = "PLAYERS"
plrLbl.TextSize = 10
        plrLbl.Font = Enum.Font.GothamBold
        plrLbl.TextColor3 = T.Dim
        plrLbl.ZIndex = 20
        plrLbl.Parent = spamWin
        local spamScroll = Instance.new("ScrollingFrame")
        spamScroll.Size = UDim2.new(1, -16, 1, -124)
        spamScroll.Position = UDim2.new(0, 8, 0, 82)
        spamScroll.BackgroundTransparency = 1
        spamScroll.BorderSizePixel = 0
        spamScroll.ScrollBarThickness = 3
        spamScroll.ScrollBarImageColor3 = Color3.fromRGB(75, 75, 75)
        spamScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        spamScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        spamScroll.ZIndex = 19
        spamScroll.Parent = spamWin
        local spamLayout = Instance.new("UIListLayout")
        spamLayout.Padding = UDim.new(0, 4)
        spamLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        spamLayout.Parent = spamScroll
        Padding(spamScroll, 4, 4, 0, 0)
        local ALL_SPAM_CMDS = {"balloon","tiny","rocket","ragdoll","inverse","jail","morph","jumpscare"}

        Config.spammer = Config.spammer or {}
        local function _cloneCmdList(t)
            local out = {}
            if type(t) == "table" then
                for _, v in ipairs(t) do
                    if type(v) == "string" then table.insert(out, v) end
                end
            end
            return out
        end
        local _savedSemi = _cloneCmdList(Config.spammer.semi)
        local _savedFull = _cloneCmdList(Config.spammer.full)
        _G._FH_SEMI_CMDS = (#_savedSemi > 0 and _savedSemi)
            or {"balloon","tiny","rocket","inverse"}
        _G._FH_FULL_CMDS = (#_savedFull > 0 and _savedFull)
            or {"balloon","tiny","rocket","ragdoll","inverse","jail","morph","jumpscare"}
        local function _saveSpammerCfg()
            Config.spammer = Config.spammer or {}
            Config.spammer.semi = _G._FH_SEMI_CMDS
            Config.spammer.full = _G._FH_FULL_CMDS
            pcall(FH_SaveConfig)
        end
        local function getSpamSemiCmds() return _G._FH_SEMI_CMDS end
        local function getSpamFullCmds() return _G._FH_FULL_CMDS end
        local spamProfileCache = {}
        local spamCommandCache = {}
        local function spamGetFrames()
            local ap = Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
            if not ap then return nil, nil end
            local inner = ap:FindFirstChild("AdminPanel")
            if not inner then return nil, nil end
            local c = inner:FindFirstChild("Content")
            local p = inner:FindFirstChild("Profiles")
            if not c or not p then return nil, nil end
            return c:FindFirstChild("ScrollingFrame"), p:FindFirstChild("ScrollingFrame")
        end
        local function spamCacheBtn(btn)
            local out = {}
            local ok, conns = pcall(getconnections, btn.Activated)
            if ok and type(conns) == "table"then
                for _, c in ipairs(conns) do
                    if type(c.Function) == "function"then table.insert(out, c.Function) end
                end
            end
            return out
        end
        local function spamFire(fns)
            for _, fn in ipairs(fns) do task.spawn(fn) end
        end
        _G._FH_CD_RECENT = _G._FH_CD_RECENT or {}
        local function _spamIsOnCD(cmd)
            local cd = _G._FH_CD_ONCD and _G._FH_CD_ONCD[cmd]
            if cd then return true end
            local rec = _G._FH_CD_RECENT[cmd]
            if rec and tick() < rec then return true end
            return false
        end
        local function spamRun(target, cmds)
            local cf, pf = spamGetFrames()
            if not cf or not pf then return end
            local pb = pf:FindFirstChild(target.Name)
            if not pb then return end
            if not spamProfileCache[target.Name] then
                spamProfileCache[target.Name] = spamCacheBtn(pb)
            end
            for _, cmd in ipairs(cmds) do
                if not _spamIsOnCD(cmd) then
                    if not spamCommandCache[cmd] then
                        local cb = cf:FindFirstChild(cmd)
                        if cb then spamCommandCache[cmd] = spamCacheBtn(cb) end
                    end
                    local cc = spamCommandCache[cmd]
                    if cc and #cc > 0 then
                        spamFire(cc)
                        spamFire(spamProfileCache[target.Name])
                        _G._FH_CD_RECENT[cmd] = tick() + 0.6
                    end
                end
            end
        end
        local spamSemiKBClick, spamFullKBClick
        local function spamAddRow(plr)
            if plr == Players.LocalPlayer then return end
            if spamScroll:FindFirstChild("row_"..plr.Name) then return end
            local rowH = isMobile and 36 or 34
            local row = Instance.new("Frame")
