local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local Lighting          = game:GetService("Lighting")

if not Players.LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end
pcall(function() Players.LocalPlayer:WaitForChild("PlayerGui", 10) end)
pcall(function()
    if not Players.LocalPlayer.Character then
        Players.LocalPlayer.CharacterAdded:Wait()
    end
end)

_G._FH_CarpetTP_Speed = _G._FH_CarpetTP_Speed or 214

do	
    local function _stripToolPhysics(tool)
        if not tool or not tool:IsA("Tool") then return end
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("BasePart") then
                pcall(function()
                    d.Massless   = true
                    d.CanCollide = false
                end)
            elseif d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")
                or d:IsA("AlignPosition") or d:IsA("AlignOrientation") or d:IsA("VectorForce")
                or d:IsA("LinearVelocity") or d:IsA("AngularVelocity") then
                pcall(function() d.Enabled = false end)
            end
        end
        tool.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then
                pcall(function()
                    d.Massless   = true
                    d.CanCollide = false
                end)
            end
        end)
    end
    local function _wireChar(c)
        for _, t in ipairs(c:GetChildren()) do _stripToolPhysics(t) end
        c.ChildAdded:Connect(_stripToolPhysics)
    end
    if Players.LocalPlayer.Character then _wireChar(Players.LocalPlayer.Character) end
    Players.LocalPlayer.CharacterAdded:Connect(_wireChar)
end
local _fhCarpetActiveTween = nil
function _G._FH_CarpetTP(targetCF, speedOverride)
    local lp  = Players.LocalPlayer
    local chr = lp and lp.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetCF then return end
    if typeof(targetCF) == "Vector3" then targetCF = CFrame.new(targetCF) end
    local dist = (hrp.Position - targetCF.Position).Magnitude
    local dur  = math.max(0.05, dist / (speedOverride or _G._FH_CarpetTP_Speed or 214))
    local bp = lp:FindFirstChildOfClass("Backpack")
    local carpet = (bp and bp:FindFirstChild("Flying Carpet")) or chr:FindFirstChild("Flying Carpet")
    local hum = chr:FindFirstChildOfClass("Humanoid")
    if carpet and hum and carpet.Parent ~= chr then pcall(function() hum:EquipTool(carpet) end) end
    if _fhCarpetActiveTween then pcall(function() _fhCarpetActiveTween:Cancel() end) end
    local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = targetCF})
    _fhCarpetActiveTween = tw
    tw:Play()
    return tw
end

do
    local _cfgOk, _cfgRaw = pcall(function() return readfile("FadedHub_Config.json") end)
    local _cfgData = nil
    if _cfgOk and _cfgRaw then
        local _parseOk, _parsed = pcall(function()
            return game:GetService("HttpService"):JSONDecode(_cfgRaw)
        end)
        if _parseOk and type(_parsed) == "table" then _cfgData = _parsed end
    end
    if _cfgData and type(_cfgData.toggles) == "table"
       and _cfgData.toggles["Optimizations"] == false then
        _G._FH_AlwaysOnFPS = false
    else
        _G._FH_AlwaysOnFPS = true
    end

    if _cfgData and type(_cfgData.sliders) == "table" then
        local cap = tonumber(_cfgData.sliders.fps_cap)
        if cap then
            local setter = rawget(getfenv(), "setfpscap") or rawget(getfenv(), "set_fps_cap")
            if setter then pcall(setter, math.floor(cap)) end
        end
    end
end

task.spawn(function()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 1e9
        Lighting.Brightness    = 1
    end)
end)
local function _buildMiniPetsSection(
    Config, T, isMobile, Corner, Stroke, Label, Tween, F,
    MiscTab, Players, configRegistry, ShowToggleNotification,
    _buildMakeAnimalCard, ANIMAL_LIST,
    _FH_AddThemeStroke, CreateToggle, GUI, FH_SaveConfig, _FH_BuildThemeSequence
)
    Config.sliders = Config.sliders or {}
    Config.toggles = Config.toggles or {}

    local selectedItem = tostring(Config.sliders.hide_gui_item or "")
    local toggleName   = "Hide GUI On Equip"
    local enabled      = Config.toggles[toggleName] == true

    local cardH = isMobile and 110 or 88
    local card = Instance.new("Frame")
    card.Size                   = UDim2.new(1, -16, 0, cardH)
    card.BackgroundColor3       = T.Card
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel        = 0
    card.Parent                 = MiscTab.scroll
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

    local nameLbl = Label(card, "Hide GUI Item", isMobile and 11 or 13, T.White, Enum.Font.GothamMedium)
    nameLbl.Size         = UDim2.new(1, -28, 0, 16)
    nameLbl.Position     = UDim2.new(0, 14, 0, 8)
    nameLbl.ZIndex       = 2

    local descLbl = Label(card, "Hides entire GUI while this item is equipped; restores on unequip", isMobile and 9 or 11, T.Dim, Enum.Font.Gotham)
    descLbl.Size         = UDim2.new(1, -28, 0, 14)
    descLbl.Position     = UDim2.new(0, 14, 0, 26)
    descLbl.ZIndex       = 2
    descLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local ddBtn = Instance.new("TextButton")
    ddBtn.Size             = UDim2.new(1, -28, 0, 28)
    ddBtn.Position         = UDim2.new(0, 14, 1, -36)
    ddBtn.BackgroundColor3 = T.Card
    ddBtn.BorderSizePixel  = 0
    ddBtn.AutoButtonColor  = false
    ddBtn.Text             = (selectedItem ~= "" and selectedItem) or "▼  Click to select item"
    ddBtn.TextSize         = isMobile and 10 or 11
    ddBtn.Font             = Enum.Font.GothamBold
    ddBtn.TextColor3       = T.White
    ddBtn.ZIndex           = 3
    ddBtn.Parent           = card
    Corner(ddBtn, 6)
    Stroke(ddBtn, T.Border, 1)

    local popup = Instance.new("Frame")
    popup.Size                   = UDim2.new(0, 240, 0, 200)
    popup.BackgroundColor3       = T.Card
    popup.BackgroundTransparency = 0
    popup.BorderSizePixel        = 0
    popup.Visible                = false
    popup.ZIndex                 = 200
    popup.Parent                 = GUI
    Corner(popup, 8)
    Stroke(popup, T.Border, 1)

    local popupScroll = Instance.new("ScrollingFrame")
    popupScroll.Size                   = UDim2.new(1, -8, 1, -8)
    popupScroll.Position               = UDim2.new(0, 4, 0, 4)
    popupScroll.BackgroundTransparency = 1
    popupScroll.BorderSizePixel        = 0
    popupScroll.ScrollBarThickness     = 4
    popupScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    popupScroll.ZIndex                 = 201
    popupScroll.Parent                 = popup

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding   = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent    = popupScroll

    local function makeItemBtn(toolName)
        local b = Instance.new("TextButton")
        b.Size                   = UDim2.new(1, -4, 0, 24)
        b.BackgroundColor3       = T.Card
        b.BackgroundTransparency = 0.4
        b.BorderSizePixel        = 0
        b.Text                   = toolName
        b.TextSize               = isMobile and 10 or 11
        b.Font                   = Enum.Font.Gotham
        b.TextColor3             = T.White
        b.AutoButtonColor        = true
        b.ZIndex                 = 202
        b.Parent                 = popupScroll
        Corner(b, 4)
        b.MouseButton1Click:Connect(function()
            selectedItem = toolName
            ddBtn.Text   = toolName
            Config.sliders.hide_gui_item = toolName
            pcall(FH_SaveConfig)
            popup.Visible = false
        end)
        return b
    end

    local function refreshList()
        for _, c in ipairs(popupScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local seen = {}
        local lp = Players and Players.LocalPlayer
        if lp then
            local bp = lp:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") and not seen[t.Name] then
                        seen[t.Name] = true
                        makeItemBtn(t.Name)
                    end
                end
            end
            local ch = lp.Character
            if ch then
                for _, t in ipairs(ch:GetChildren()) do
                    if t:IsA("Tool") and not seen[t.Name] then
                        seen[t.Name] = true
                        makeItemBtn(t.Name)
                    end
                end
            end
        end
        if next(seen) == nil then
            local empty = Instance.new("TextLabel")
            empty.Size                   = UDim2.new(1, -4, 0, 24)
            empty.BackgroundTransparency = 1
            empty.Text                   = "No tools in Backpack or equipped"
            empty.TextSize               = isMobile and 10 or 11
            empty.Font                   = Enum.Font.Gotham
            empty.TextColor3             = T.Dim
            empty.ZIndex                 = 202
            empty.Parent                 = popupScroll
        end
        popupScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
    end

    ddBtn.MouseButton1Click:Connect(function()
        if popup.Visible then popup.Visible = false return end
        refreshList()
        local abs = ddBtn.AbsolutePosition
        local sz  = ddBtn.AbsoluteSize
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local px = math.min(abs.X, viewport.X - 240 - 8)
        local py = math.min(abs.Y + sz.Y + 4, viewport.Y - 200 - 8)
        popup.Position = UDim2.new(0, math.max(8, px), 0, math.max(8, py))
        popup.Visible  = true
    end)

    local function isSelectedEquipped()
        if selectedItem == "" then return false end
        local lp = Players and Players.LocalPlayer
        local ch = lp and lp.Character
        if not ch then return false end
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and t.Name == selectedItem then return true end
        end
        return false
    end

    local _HIDE_GUI_ESP_NAMES = {
        "Player ESP",
        "Base ESP", "Timer ESP", "Allowed ESP",
        "Clone ESP", "Brainrot ESP",
    }
    local _espStateBeforeHide = {}
    local _espCurrentlyHidden = false

    local function disableAllESPs()
        if _espCurrentlyHidden then return end
        _espCurrentlyHidden = true
        _espStateBeforeHide = {}
        for _, espName in ipairs(_HIDE_GUI_ESP_NAMES) do
            local reg = configRegistry[espName]
            if reg and reg.getState and reg.getState() == true then
                _espStateBeforeHide[espName] = true
                pcall(function()
                    if reg.setEnabled then reg.setEnabled(false)
                    elseif reg.doToggle then reg.doToggle() end
                end)
            end
        end
    end

    local function restoreAllESPs()
        if not _espCurrentlyHidden then return end
        _espCurrentlyHidden = false
        for _, espName in ipairs(_HIDE_GUI_ESP_NAMES) do
            if _espStateBeforeHide[espName] then
                local reg = configRegistry[espName]
                if reg then
                    pcall(function()
                        if reg.setEnabled then reg.setEnabled(true)
                        elseif reg.doToggle then reg.doToggle() end
                    end)
                end
            end
        end
        _espStateBeforeHide = {}
    end

    local _petWasHidden = false

    local function hideMiniPets()
        if _petWasHidden then return end
        _petWasHidden = true
        pcall(function()
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:sub(1, 4) == "MBF_" then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 1
                        end
                    end
                end
            end
        end)
    end

    local function showMiniPets()
        if not _petWasHidden then return end
        _petWasHidden = false
        pcall(function()
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:sub(1, 4) == "MBF_" then
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
            end
        end)
    end

    local _progBarGui = nil
    local _progBarFill = nil
    local _progBarWasHidden = false

    local function _findProgressBarGui()
        if _progBarGui and _progBarGui.Parent then return _progBarGui end

        local cg = game:GetService("CoreGui")
        _progBarGui = cg:FindFirstChild("FH_AutoGrabProgress")
        if not _progBarGui then
            local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
            _progBarGui = pg and pg:FindFirstChild("FH_AutoGrabProgress")
        end
        if _progBarGui and not _progBarFill then

            local frame = _progBarGui:FindFirstChildOfClass("Frame")
            if frame then
                local track = frame:FindFirstChild("Frame")

                for _, d in ipairs(frame:GetDescendants()) do
                    if d:IsA("Frame") and d.Name ~= "Frame" and d.Parent
                    and d.Parent:IsA("Frame") then
                        _progBarFill = d
                        break
                    end
                end

                if not _progBarFill then
                    local inner = frame:FindFirstChildOfClass("Frame")
                    if inner then
                        _progBarFill = inner:FindFirstChildOfClass("Frame")
                    end
                end
            end

            if _progBarFill then
                local function _syncProgBarTheme()
                    pcall(function()
                        if not (_progBarFill and _progBarFill.Parent) then return end
                        local g = _progBarFill:FindFirstChildOfClass("UIGradient")
                        if not g then
                            g = Instance.new("UIGradient")
                            g.Parent = _progBarFill
                        end
                        if _FH_BuildThemeSequence then
                            g.Color = _FH_BuildThemeSequence()
                        end

                        _progBarFill.BackgroundColor3 = _G._FH_AccentA or Color3.fromRGB(60, 210, 100)
                    end)
                end

                _syncProgBarTheme()

                _G._FH_ThemeCallbacks = _G._FH_ThemeCallbacks or {}
                table.insert(_G._FH_ThemeCallbacks, _syncProgBarTheme)
            end
        end
        return _progBarGui
    end

    local function hideProgressBar()
        if _progBarWasHidden then return end
        _progBarWasHidden = true

        _G._FH_HideAutoGrabBar = true
        pcall(function()
            local gui = _findProgressBarGui()
            if gui then gui.Enabled = false end
        end)
    end

    local function showProgressBar()
        if not _progBarWasHidden then return end
        _progBarWasHidden = false

        local reg = configRegistry["Hide Progress Bar"]
        _G._FH_HideAutoGrabBar = (reg and reg.getState and reg.getState()) or false
        pcall(function()
            if not _G._FH_HideAutoGrabBar then
                local gui = _findProgressBarGui()
                if gui then gui.Enabled = true end
            end
        end)
    end

    task.defer(_findProgressBarGui)

    do
        local function _fixAutoGrabBarTheme()
            pcall(function()
                local cg = game:GetService("CoreGui")
                local gui = cg:FindFirstChild("FH_AutoGrabProgress")
                    or (Players.LocalPlayer:FindFirstChild("PlayerGui")
                        and Players.LocalPlayer.PlayerGui:FindFirstChild("FH_AutoGrabProgress"))
                if not gui then return end
                for _, d in ipairs(gui:GetDescendants()) do
                    if d:IsA("UIGradient") and d.Parent and d.Parent:IsA("Frame") then
                        if _FH_BuildThemeSequence then
                            d.Color = _FH_BuildThemeSequence()
                        end
                        local parentFrame = d.Parent
                        parentFrame.BackgroundColor3 = _G._FH_AccentA or Color3.fromRGB(60, 210, 100)
                    end
                end

                local frame = gui:FindFirstChildOfClass("Frame")
                if frame then
                    for _, d in ipairs(frame:GetDescendants()) do
                        if d:IsA("UIStroke") then
                            local g = d:FindFirstChildOfClass("UIGradient")
                            if not g then
                                g = Instance.new("UIGradient")
                                g.Parent = d
                                table.insert(_G._FH_ThemeStrokes, g)
                            end
                            if _FH_BuildThemeSequence then g.Color = _FH_BuildThemeSequence() end
                        end
                    end
                end
            end)
        end
        _G._FH_ThemeCallbacks = _G._FH_ThemeCallbacks or {}
        table.insert(_G._FH_ThemeCallbacks, _fixAutoGrabBarTheme)
        pcall(_fixAutoGrabBarTheme)
    end

    local function applyGuiState()
        if not GUI then return end
        if not enabled then

            GUI.Enabled = true
            restoreAllESPs()
            showMiniPets()
            showProgressBar()
            return
        end
        local equipped = isSelectedEquipped()
        GUI.Enabled = not equipped
        if equipped then
            disableAllESPs()
            hideMiniPets()
            hideProgressBar()
        else
            restoreAllESPs()
            showMiniPets()
            showProgressBar()
        end
    end

    local _charConns = {}
    local function disconnectCharConns()
        for _, c in ipairs(_charConns) do pcall(function() c:Disconnect() end) end
        _charConns = {}
    end

    local function hookChar(char)
        disconnectCharConns()
        table.insert(_charConns, char.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then task.wait(); applyGuiState() end
        end))
        table.insert(_charConns, char.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then task.wait(); applyGuiState() end
        end))

        if GUI then GUI.Enabled = true end
        restoreAllESPs()
        showMiniPets()
        showProgressBar()
        task.wait(0.1)
        applyGuiState()
    end

    local lp = Players and Players.LocalPlayer
    if lp then
        if lp.Character then hookChar(lp.Character) end
        lp.CharacterAdded:Connect(hookChar)
    end

    CreateToggle(MiscTab.scroll, toggleName, "Auto-hides the UI while your selected item is equipped",
        function(v)
            enabled = v
            if not v then
                if GUI then GUI.Enabled = true end
                restoreAllESPs()
                showMiniPets()
                showProgressBar()
            end
            applyGuiState()
        end
    )
end

task.spawn(function()
    pcall(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect")
            or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("ColorCorrectionEffect") then
                pcall(function() e.Enabled = false end)
            end
        end
    end)
end)
task.spawn(function()

    task.wait()
    pcall(function()
        local _step = 0
        local YIELD_EVERY = 200
        for _, obj in ipairs(workspace:GetDescendants()) do
            local cls = obj.ClassName
            if cls == "ParticleEmitter" or cls == "Trail"
            or cls == "Smoke" or cls == "Fire" or cls == "Sparkles" then
                obj.Enabled = false
            elseif obj:IsA("BasePart") then
                if obj.Material == Enum.Material.Glass then
                    pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
                end
            end
            _step = _step + 1
            if _step % YIELD_EVERY == 0 then task.wait() end
        end
    end)
end)
do
    local NetMod   = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net")
    local NetClone = require(NetMod:Clone())

    local function getRemote(name)
        if not name then return nil end
        local ok, rn = pcall(function() return NetClone:RemoteEvent(name) end)
        if not ok or not rn then return nil end
        return NetMod[tostring(rn)]
    end
    local function getRemoteFunction(name)
        if not name then return nil end
        local ok, rn = pcall(function() return NetClone:RemoteFunction(name) end)
        if not ok or not rn then return nil end
        return NetMod[tostring(rn)]
    end
    _G._FH_NetMod          = NetMod
    _G._FH_NetClone        = NetClone
    _G._FH_GetRemote       = getRemote
    _G._FH_GetRemoteFn     = getRemoteFunction
    _FH_StealRemote = getRemote("3ba148c9-7ed6-4675-93f8-9f7c356a2c54")

    _FH_UseItemRemote = getRemote("UseItem")
    _FH_TRIP_U1  = "68c86eb7-eb7e-4b4d-96ae-cf7cd847c5b0"
    _FH_TRIP_U2  = "07b9cc25-2a1f-4a26-a0ec-f2fab578d8bd"
    _FH_STEAL_U1 = "cda5c764-d4e3-45c4-94e4-53a538347590"
    _FH_STEAL_U2 = "8c852fbf-d542-4ef4-aa28-612e24db8d4a"
    function _FH_ResolvePromptTarget(prompt)
        if not prompt or not prompt.Parent then return nil end
        local att    = prompt.Parent
        local spawn  = att and att.Parent
        local base   = spawn and spawn.Parent
        local podium = base and base.Parent
        local pods   = podium and podium.Parent
        local plot   = pods and pods.Parent
        local pod    = podium and tonumber(podium.Name)
        if not (plot and pod) then return nil end
        return { plotName = plot.Name, pod = pod }
    end
    function _FH_StartTrip(target)
        local T0 = workspace:GetServerTimeNow()
        _G._FH_LastStealStart = tick()
        return { t0 = T0, startedAt = tick(), target = target }
    end
    function _FH_FinishSteal(ctx)
        if not ctx or not ctx.target then return false end
        local elapsed = tick() - ctx.startedAt
        if elapsed < 1.3 then task.wait(1.3 - elapsed) end
        local ts = ctx.t0 + 1.3 + 31
        pcall(function() _FH_StealRemote:FireServer(ts, _FH_STEAL_U1, ctx.target.plotName, ctx.target.pod) end)
        pcall(function() _FH_StealRemote:FireServer(ts, _FH_STEAL_U2, ctx.target.plotName, ctx.target.pod) end)
        return true
    end
    function _FH_FireStealPrompt(prompt)
        local target = _FH_ResolvePromptTarget(prompt)
        if not target then return false end
        local ctx = _FH_StartTrip(target)
        return _FH_FinishSteal(ctx)
    end
end

local __stealActive_v2 = false
_G.__stealActive = false

local __stealCbCache_v2 = {}
local __MIN_HOLD_TIME_v2       = 1.3
local __TRIGGER_AFTER_GREEN_v2 = 0.02

local function __buildStealCallbacks_v2(prompt)
    if __stealCbCache_v2[prompt] then return __stealCbCache_v2[prompt] end
    if not getconnections then return nil end
    local data = { hold = {}, trigger = {} }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table" then
        for _, c in ipairs(conns1) do
            if type(c.Function) == "function" then table.insert(data.hold, c.Function) end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table" then
        for _, c in ipairs(conns2) do
            if type(c.Function) == "function" then table.insert(data.trigger, c.Function) end
        end
    end
    if #data.hold == 0 and #data.trigger == 0 then return nil end
    __stealCbCache_v2[prompt] = data
    return data
end

local __FH_v2 = {}

function __FH_v2.startStealHold(prompt, method)
    if not prompt or not prompt.Parent then return nil end
    local cb = __buildStealCallbacks_v2(prompt)
    if not cb then return nil end

    __stealActive_v2 = true
    _G.__stealActive = true

    for _, fn in ipairs(cb.hold) do task.spawn(fn) end
    local now = tick()

    return {
        prompt          = prompt,
        cb              = cb,
        method          = method,
        ragdollFireTime = now,
        startedAt       = now,
        holdBeganAt     = now,
        holdDone        = true,
    }
end

function __FH_v2.doHoldAndWait(ctx)
    if ctx.holdDone then return end
    for _, fn in ipairs(ctx.cb.hold) do task.spawn(fn) end
    ctx.holdBeganAt = tick()
    task.wait(__MIN_HOLD_TIME_v2)
    ctx.holdDone = true
end

function __FH_v2.waitForStealTime(ctx, sec)
    if not ctx then return end
    if sec >= 1.0 then return end
    local elapsed = tick() - ctx.ragdollFireTime
    if elapsed < sec then task.wait(sec - elapsed) end
end

function __FH_v2.finishStealHold(ctx)
    if not ctx then return false end
    if not ctx.holdBeganAt then __FH_v2.doHoldAndWait(ctx) end
    local heldFor = tick() - (ctx.holdBeganAt or tick())
    if heldFor < __MIN_HOLD_TIME_v2 then task.wait(__MIN_HOLD_TIME_v2 - heldFor) end
    task.wait(__TRIGGER_AFTER_GREEN_v2)
    for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
    __stealActive_v2 = false
    _G.__stealActive = false
    return true
end

local function _FH_V2FireStealPrompt(prompt, finalizeFn)
    if not prompt or not prompt.Parent then return false end
    local cb = __buildStealCallbacks_v2(prompt)
    if not cb then

        local target = _FH_ResolvePromptTarget(prompt)
        if not target then return false end
        local ctx = _FH_StartTrip(target)
        if finalizeFn then pcall(finalizeFn) end
        return _FH_FinishSteal(ctx)
    end

    local target = _FH_ResolvePromptTarget(prompt)
    local ctx = target and _FH_StartTrip(target) or nil

    for _, fn in ipairs(cb.hold) do task.spawn(fn) end
    local holdBeganAt = tick()

    if finalizeFn then
        local holdElapsed = tick() - holdBeganAt
        local waitFor = 1.3 - holdElapsed - 0.05
        if waitFor > 0 then task.wait(waitFor) end
        pcall(finalizeFn)
    else
        local holdElapsed = tick() - holdBeganAt
        if holdElapsed < __MIN_HOLD_TIME_v2 then
            task.wait(__MIN_HOLD_TIME_v2 - holdElapsed)
        end
    end

    task.wait(__TRIGGER_AFTER_GREEN_v2)

    for _, fn in ipairs(cb.trigger) do task.spawn(fn) end

    if ctx then
        task.spawn(function() _FH_FinishSteal(ctx) end)
    end
    return true
end

local _FH_SAVE_PATH = "FadedHub_Config.json"
local configRegistry = {}
local HttpService   = game:GetService("HttpService")
local function FH_LoadConfig()
    local ok, raw = pcall(function() return readfile(_FH_SAVE_PATH) end)
    if ok and raw then
        local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok2 and type(data) == "table" then return data end
    end
    return nil
end

local _FH_RestoreComplete = false
local _FH_SaveDebounceToken = 0
local _FH_SaveLastQueued = 0
local function _FH_DoSaveConfig()
    pcall(function()
        for name, reg in pairs(configRegistry) do
            if reg.getState then
                local live = reg.getState()

                if not _G._FH_IsRestoring then
                    Config.toggles[name] = live
                elseif live == true or Config.toggles[name] == nil then
                    Config.toggles[name] = live
                end
            end
            if reg.getKeyCode then
                local kc = reg.getKeyCode()
                if kc then
                    Config.keybinds[name] = kc.Name
                elseif not _G._FH_IsRestoring then
                    Config.keybinds[name] = nil
                end
            end
        end
        if SP and SP.wsBox then
            Config.sliders = Config.sliders or {}
            Config.sliders.sp_walkspeed = SP.wsBox.Text
        end
        if SP and SP.jpBox then
            Config.sliders = Config.sliders or {}
            Config.sliders.sp_jumppower = SP.jpBox.Text
        end

        if _G._FH_PotionSpeedValue then
            Config.sliders = Config.sliders or {}
            Config.sliders.potion_speed = _G._FH_PotionSpeedValue
        end
        if _G._FH_FpsCapValue then
            Config.sliders = Config.sliders or {}
            Config.sliders.fps_cap = _G._FH_FpsCapValue
        end

        Config.mini = Config.mini or {}
        if SP  and SP.SpeedWin         then Config.mini.sp_open   = SP.SpeedWin.Visible         end
        if SS  and SS.SSWin            then Config.mini.ss_open   = SS.SSWin.Visible             end
        if AB  and AB.AllowBaseWin     then Config.mini.ab_open   = AB.AllowBaseWin.Visible      end
        if FA  and FA.FAWin            then Config.mini.fa_open   = FA.FAWin.Visible             end
        if FD  and FD.FDWin            then Config.mini.fd_open   = FD.FDWin.Visible             end
        if QP  and QP.QPWin            then Config.mini.qp_open   = QP.QPWin.Visible             end
        if CD  and CD.CDWin            then Config.mini.cd_open   = CD.CDWin.Visible             end
        if WSK and WSK.WSKWin          then Config.mini.wsk_open  = WSK.WSKWin.Visible           end
        if QS  and QS.QSWin            then Config.mini.qs_open   = QS.QSWin.Visible             end
        if UB  and UB.UBWin            then Config.mini.ub_open   = UB.UBWin.Visible             end
        if UB  and UB.isHorizontal ~= nil then Config.mini.ub_horiz = UB.isHorizontal == true end
        if FS  and FS.FSWin            then Config.mini.fs_open   = FS.FSWin.Visible              end
        if _G.SpammerGui and _G.SpammerGui.win then
            Config.mini.spam_open      = _G.SpammerGui.win.Visible
        end
        if _G.SpammerGui and _G.SpammerGui.isCustomizeOpen then
            Config.mini.customize_open = _G.SpammerGui.isCustomizeOpen()
        end
        local function _snapPos(win)
            if not win then return nil end
            return {
                x  = win.Position.X.Offset,
                y  = win.Position.Y.Offset,
                xs = win.Position.X.Scale,
                ys = win.Position.Y.Scale,
            }
        end
        if SP  and SP.SpeedWin         then Config.mini.sp_pos   = _snapPos(SP.SpeedWin)         end
        if SS  and SS.SSWin            then Config.mini.ss_pos   = _snapPos(SS.SSWin)            end
        if AB  and AB.AllowBaseWin     then Config.mini.ab_pos   = _snapPos(AB.AllowBaseWin)     end
        if FA  and FA.FAWin            then Config.mini.fa_pos   = _snapPos(FA.FAWin)            end
        if FD  and FD.FDWin            then Config.mini.fd_pos   = _snapPos(FD.FDWin)            end
        if QP  and QP.QPWin            then Config.mini.qp_pos   = _snapPos(QP.QPWin)            end
        if CD  and CD.CDWin            then Config.mini.cd_pos   = _snapPos(CD.CDWin)            end
        if WSK and WSK.WSKWin          then Config.mini.wsk_pos  = _snapPos(WSK.WSKWin)          end
        if QS  and QS.QSWin            then Config.mini.qs_pos   = _snapPos(QS.QSWin)            end
        if FS  and FS.FSWin            then Config.mini.fs_pos   = _snapPos(FS.FSWin)            end
        if Win                         then Config.mini.main_pos = _snapPos(Win)                 end
        if UB and UB.UBWin then
            local vp  = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
            local ax  = UB.UBWin.Position.X.Scale * vp.X + UB.UBWin.Position.X.Offset
            local ay  = UB.UBWin.Position.Y.Scale * vp.Y + UB.UBWin.Position.Y.Offset
            Config.mini.ub_pos = { x = ax, y = ay, xs = 0, ys = 0 }
        end
        if _G.SpammerGui and _G.SpammerGui.win then
            Config.mini.spam_pos = _snapPos(_G.SpammerGui.win)
        end
        local _custWin = GUI and GUI:FindFirstChild("CustomizeSpamGui")
        if _custWin then
            Config.mini.customize_pos = _snapPos(_custWin)
        end
        local data = {
            toggles      = Config.toggles  or {},
            keybinds     = Config.keybinds or {},
            mini         = Config.mini     or {},
            sliders      = Config.sliders  or {},
            spammer      = Config.spammer  or {},
            theme        = Config.theme    or {},
            version      = 1,
        }
        local encoded = HttpService:JSONEncode(data)
        task.spawn(function()
            pcall(function() writefile(_FH_SAVE_PATH, encoded) end)
        end)
    end)
end
local function FH_SaveConfig()
    _FH_SaveDebounceToken = _FH_SaveDebounceToken + 1
    _FH_SaveLastQueued = tick()
    _FH_DoSaveConfig()
end
task.spawn(function()
    while true do
        task.wait(4)
        if _FH_RestoreComplete then
            pcall(FH_SaveConfig)
        end
    end
end)
local _FH_SavedConfig = FH_LoadConfig()
Config = {
    toggles  = (_FH_SavedConfig and _FH_SavedConfig.toggles)  or {},
    keybinds = (_FH_SavedConfig and _FH_SavedConfig.keybinds) or {},
    mini     = (_FH_SavedConfig and _FH_SavedConfig.mini)     or {},
    sliders  = (_FH_SavedConfig and _FH_SavedConfig.sliders)  or {},
    spammer  = (_FH_SavedConfig and _FH_SavedConfig.spammer)  or {},
    theme    = (_FH_SavedConfig and _FH_SavedConfig.theme)    or {},
    version  = 1,
}

if _FH_SavedConfig and _FH_SavedConfig.mini then
    _G._FH_POS = {}
    for k, v in pairs(_FH_SavedConfig.mini) do _G._FH_POS[k] = v end
end

local ShowToggleNotification
local VirtualInputManager = Instance.new("VirtualInputManager")
_G.FadedHubAlive = true
local FriendsESPEnabled = false
local FriendsESPConnections = {}
local V3 = { enabled = false, potionOn = false, giant = nil, potionEquipped = false }
local FPS = { connections = {} }
local AntiRagdoll = { connections = {}, running = false }
local SS = {
    player           = nil,
    teleporting      = false,
    debounce         = false,
    speed            = false,
    minimized        = false,
    dragging         = false,
    dragStart        = nil,
    panelStart       = nil,
    potionState      = false,
    autoTPUnlockState = false,
    stealMethod      = "Walk",
    semiInstantMode  = "Semi",
    _scriptStartTime = tick(),
    _autoFullSwitched = false,
    W = 138, H = 220,
    BG        = Color3.fromRGB(15, 15, 15),
    HDR       = Color3.fromRGB(8,  8,  8),
    BTN       = Color3.fromRGB(24, 24, 24),
    BTN_HOVER = Color3.fromRGB(38, 38, 38),
}
local SP = {
    W = 150, H = 130,
    minimized  = false,
    dragging   = false,
    dragStart  = nil,
    panelStart = nil,
    state      = false,
    entry      = { keyCode = nil },
    kb2Debounce = false,
}
local AB = {
    W = 155, H = 60,
    minimized  = false,
    dragging   = false,
    dragStart  = nil,
    panelStart = nil,
    allowState = false,
}
local FA = {}
local FD = {}
local QP = {}
local CD = {}
local SVN = {}
local STP = {}
local QS  = {}
local PS  = {}
local UB  = {
    W = 180, H = 74,
    minimized  = false,
    dragging   = false,
    dragStart  = nil,
    panelStart = nil,
}
local Win, BorderFrame
local function setGuiVisible(vis)
    Win.Visible         = vis
    BorderFrame.Visible = vis
end
local hidden    = false
local animating = false
local HIDE_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local SHOW_INFO = TweenInfo.new(0.5,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local T, F, M, S
local Tween, Corner, Stroke, Padding, Label
local GUI, WIN_W, WIN_H
local BOOK_OPEN
local BANNER_W, BANNER_H
local BannerStrokeInst
local BannerTitle, BannerDev, BannerStats
local bannerAngle, fpsClock, fpsFrames, displayFPS
local Hdr, HdrFill, HdrLine, Dot, TitleLbl, VerLbl
local TabBar, TBLine, TabLayout, ContentArea
local CreateToggle, CreateSection, MakeScroll
local Tabs, ActiveTab, TabSwiping, TabIndex
local SLIDE_IN, SLIDE_OUT, ActivateTab, TAB_W, CreateTab
local CombatTab, VisualTab, PlayerTab, MiscTab
local TopBanner
local keybindBindingTarget = nil
local keybindEntries = {}
local Player = Players.LocalPlayer
local LocalPlayer = Player

local antiDieConnection = nil
local antiDieDisabled = false
local function setupAntiDie()
    if antiDieDisabled then return end
    local character = Player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if antiDieConnection then
        pcall(function() antiDieConnection:Disconnect() end)
    end
    antiDieConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if antiDieDisabled then return end
        if humanoid.Health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end
setupAntiDie()
Player.CharacterAdded:Connect(function() task.wait(0.1); setupAntiDie() end)

do
    _G._FH_AntiGummyBear  = _G._FH_AntiGummyBear  or false
    _G._FH_AntiAdminPanel = _G._FH_AntiAdminPanel or false

    local antiGummyRespawnGraceUntil = 0
    local originalScales   = {}
    local originalHipHeight = nil
    local scaleNames = {
        "HeadScale", "BodyDepthScale", "BodyHeightScale",
        "BodyProportionScale", "BodyTypeScale", "BodyWidthScale",
    }
    local function captureOriginals()
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        originalHipHeight = hum.HipHeight
        originalScales = {}
        for _, name in ipairs(scaleNames) do
            local sv = hum:FindFirstChild(name)
            if sv then originalScales[name] = sv.Value end
        end
    end
    Player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        antiGummyRespawnGraceUntil = tick() + 1.5
        task.wait(0.1)
        captureOriginals()
    end)
    task.spawn(captureOriginals)

    local _ctrlCache = nil
    local function getControls()
        if _ctrlCache then return _ctrlCache end
        local ps = Player:FindFirstChild("PlayerScripts")
        local pm = ps and ps:FindFirstChild("PlayerModule")
        if not pm then return nil end
        local ok, mod = pcall(require, pm)
        if not ok or not mod then return nil end
        local ok2, c = pcall(function() return mod:GetControls() end)
        if ok2 and c then _ctrlCache = c end
        return _ctrlCache
    end
    Player.CharacterAdded:Connect(function() _ctrlCache = nil end)

    local _charController, _jumpscareMod
    local function _tryRequireCharController()
        if _charController ~= nil then return _charController end
        local ok, mod = pcall(function()
            return require(game:GetService("ReplicatedStorage"):WaitForChild("Controllers"):WaitForChild("CharacterController"))
        end)
        _charController = ok and mod or false
        return _charController
    end
    local function _tryRequireJumpscare()
        if _jumpscareMod ~= nil then return _jumpscareMod end
        local ok, mod = pcall(function()
            return require(game:GetService("ReplicatedStorage"):WaitForChild("Datas"):WaitForChild("AdminCommands"):WaitForChild("jumpscare"))
        end)
        _jumpscareMod = ok and mod or false
        return _jumpscareMod
    end

    local function clearGummyToolBlockState(char)
        for _, inst in ipairs({ Player, char }) do
            if inst then
                if inst:GetAttribute("BlockTools") ~= nil and inst:GetAttribute("BlockTools") ~= false then
                    inst:SetAttribute("BlockTools", false)
                end
                if inst:GetAttribute("Web") ~= nil and inst:GetAttribute("Web") ~= false then
                    inst:SetAttribute("Web", false)
                end
            end
        end
        if char and char:GetAttribute("BackpackReady") == false then
            char:SetAttribute("BackpackReady", true)
        end
    end

    task.spawn(function()
        while task.wait(0.1) do
            if not (_G._FH_AntiGummyBear or _G._FH_AntiAdminPanel) then 
    return 
end
            local char = Player.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then continue end

            if _G._FH_AntiGummyBear and tick() >= antiGummyRespawnGraceUntil then
                clearGummyToolBlockState(char)
            end

            if _G._FH_AntiAdminPanel then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") or v:IsA("Attachment") then
                        v:Destroy()
                    elseif v:IsA("Motor6D") then
                        v.Enabled = true
                    end
                end
                local ctrl = getControls()
                if ctrl then pcall(function() ctrl:Enable() end) end
                local state = hum:GetState()
                if state ~= Enum.HumanoidStateType.Running
                    and state ~= Enum.HumanoidStateType.Jumping
                    and state ~= Enum.HumanoidStateType.Freefall then
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
                end
                if workspace.CurrentCamera and workspace.CurrentCamera.CameraSubject ~= hum then
                    workspace.CurrentCamera.CameraSubject = hum
                end
                local ragdollEnd = Player:GetAttribute("RagdollEndTime") or 0
                if ragdollEnd > workspace:GetServerTimeNow() then
                    hrp.Velocity = Vector3.zero
                    Player:SetAttribute("RagdollEndTime", 0)
                end
                local cc = _tryRequireCharController()
                if cc and ctrl then
                    ctrl.moveFunction = function(p, x, z) cc:RequestMove(p, x, z) end
                end
                local jm = _tryRequireJumpscare()
                if jm and jm.effects and jm.effects.Victim then
                    jm.effects.Victim = function() end
                end
                if originalHipHeight and hum.HipHeight ~= originalHipHeight then
                    hum.HipHeight = originalHipHeight
                end
                for _, name in ipairs(scaleNames) do
                    local sv = hum:FindFirstChild(name)
                    if sv and originalScales[name] and sv.Value ~= originalScales[name] then
                        sv.Value = originalScales[name]
                    end
                end
                for _, v in ipairs(char:GetChildren()) do
                    if v:IsA("Model") and not v:IsA("BackpackItem") then
                        v:Destroy()
                    end
                end
            end
        end
    end)
end

local ToggleHandlers = {}
local instantRespawnDebounce = false
local function instantRespawn(_btn)
    if instantRespawnDebounce then return end
    instantRespawnDebounce = true
    local lp      = Players.LocalPlayer
    local oldChar = lp.Character
    if not oldChar then instantRespawnDebounce = false; return end
    local hrp = oldChar:FindFirstChild("HumanoidRootPart")
    local hum = oldChar:FindFirstChildWhichIsA("Humanoid")
    if hrp and hum then
        hum.Health = 0
        pcall(function() hrp.CFrame = CFrame.new(0, 50000, 0) end)
    end
    while lp.Character == oldChar do task.wait() end
    instantRespawnDebounce = false
end

local function doSelectedReset()
    local lp   = Players.LocalPlayer
    local char = lp and lp.Character
    if not char then return end
    task.spawn(function()
        pcall(function()
            local RSrv  = game:GetService("RunService")
            local remote = _G._FH_GetRemote and _G._FH_GetRemote("Tools/Cooldown")
            if not remote then return end
            local savedTools = {}
            local bp  = lp:FindFirstChild("Backpack")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:UnequipTools() end) end
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
            end
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    if t:IsA("Tool") then table.insert(savedTools, t); t.Parent = nil end
                end
            end
            lp.Character = nil
            local sending  = true
            local loopConn
            local fire     = remote.FireServer
            local throttle = 0
            loopConn = RSrv.Heartbeat:Connect(function(dt)
                if not sending then
                    if loopConn then loopConn:Disconnect(); loopConn = nil end
                    return
                end
                throttle = throttle + dt
                if throttle >= 0.1 then
                    throttle = 0
                    pcall(fire, remote, "f888ee6e-c86d-46e1-93d7-0639d6635d42", lp, "balloon")
                end
                if sending and lp.Character then lp.Character = nil end
            end)
            local charConn
            charConn = lp.CharacterAdded:Connect(function()
                sending = false
                if loopConn then loopConn:Disconnect(); loopConn = nil end
                if charConn then charConn:Disconnect() end
                task.spawn(function()
                    local newBp = lp:WaitForChild("Backpack", 3)
                    if newBp then
                        for _, t in ipairs(savedTools) do if t then t.Parent = newBp end end
                    end
                    savedTools = {}
                end)
            end)
            task.delay(4, function()
                sending = false
                if loopConn then loopConn:Disconnect(); loopConn = nil end
                local curBp = lp:FindFirstChild("Backpack")
                if curBp and #savedTools > 0 then
                    for _, t in ipairs(savedTools) do if t then t.Parent = curBp end end
                    savedTools = {}
                end
            end)
        end)
    end)
end
local _silCtx = { stealStart = 0, victim = "Unknown", halfTP = false, giantUsed = false }
local function _sil_getVictimFromPrompt(prompt)
    if not prompt then return "Unknown"end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return "Unknown"end
    for _, plot in ipairs(plots:GetChildren()) do
        if prompt:IsDescendantOf(plot) then
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local sf = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if sf then
                    local lbl = sf:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl and lbl.Text ~= ""
                    then return lbl.Text end
                end
            end
            break
        end
    end
    return "Unknown"end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Toggles = {}
pcall(function() _FH_AG_AnimalsData = require(ReplicatedStorage:WaitForChild("Datas", 30):WaitForChild("Animals", 30)) end)
pcall(function() _FH_AG_NumberUtils = require(ReplicatedStorage:WaitForChild("Utils", 30):WaitForChild("NumberUtils", 30)) end)
pcall(function() _FH_AG_AnimalsShared = require(ReplicatedStorage:WaitForChild("Shared", 30):WaitForChild("Animals", 30)) end)
_FH_AG_SyncRemotes = (function()
    local folder
    pcall(function() folder = ReplicatedStorage:WaitForChild("Packages", 30):WaitForChild("Synchronizer", 30) end)
    if not folder then return { channelFolder = nil, routeRemote = nil, requestData = nil } end
    return {
        channelFolder = folder:WaitForChild("Channel", 30),
        routeRemote = folder:WaitForChild("CommunicationRoute", 30),
        requestData = folder:FindFirstChild("RequestData"),
    }
end)()
_FH_AG_PlotSync = {
    caches = {},
    connections = {},
}
_FH_AG_CachedBrainrots = {}
function _FH_AG_SplitPath(path)
    if typeof(path) == "table" then return path end
    local out = {}
    for part in string.gmatch(tostring(path), "[^%.]+") do
        table.insert(out, tonumber(part) or part)
    end
    return out
end
function _FH_AG_ResolvePath(path, root)
    local current = root
    local parent = nil
    local key = nil
    for _, part in ipairs(_FH_AG_SplitPath(path)) do
        parent = current
        key = part
        current = current and current[part] or nil
    end
    return current, parent, key
end
function _FH_AG_IsMyPlot(plot)
    if not plot or not plot:IsA("Model") then return false end
    local sign = plot:FindFirstChild("PlotSign")
    return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled
end
function _FH_AG_ApplyPlotDiff(channelName, packet)
    local cache = _FH_AG_PlotSync.caches[channelName]
    if typeof(cache) ~= "table" then return end
    local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
    local current, parent, key = _FH_AG_ResolvePath(path, cache)
    if action == "Changed" then
        if parent ~= nil then parent[key] = a end
    elseif action == "ArrayInsert" then
        if current ~= nil then table.insert(current, b, a) end
    elseif action == "ArrayRemoved" then
        if current ~= nil then table.remove(current, b) end
    elseif action == "DictionaryInsert" then
        if current ~= nil then current[b] = a end
    elseif action == "DictionaryRemoved" then
        if current ~= nil then current[b] = nil end
    end
end
function _FH_AG_AttachPlotChannel(remote)
    if _FH_AG_PlotSync.connections[remote] then return end
    local plots = workspace:FindFirstChild("Plots")
    local channelName = tostring(remote.Name)
    if not (plots and plots:FindFirstChild(channelName)) then return end
    if _FH_AG_SyncRemotes.requestData and _FH_AG_PlotSync.caches[channelName] == nil then
        local ok, data = pcall(function()
            return _FH_AG_SyncRemotes.requestData:InvokeServer(channelName)
        end)
        _FH_AG_PlotSync.caches[channelName] = ok and typeof(data) == "table" and data or {}
    elseif _FH_AG_PlotSync.caches[channelName] == nil then
        _FH_AG_PlotSync.caches[channelName] = {}
    end
    _FH_AG_PlotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
        for _, packet in ipairs(queue) do
            _FH_AG_ApplyPlotDiff(channelName, packet)
        end
    end)
end
function _FH_AG_DetachPlotChannel(channelName)
    for remote, conn in pairs(_FH_AG_PlotSync.connections) do
        if tostring(remote.Name) == tostring(channelName) then
            conn:Disconnect()
            _FH_AG_PlotSync.connections[remote] = nil
            _FH_AG_PlotSync.caches[tostring(channelName)] = nil
            break
        end
    end
end
function _FH_AG_RefreshPlotCache(channelName)
    if not _FH_AG_SyncRemotes.requestData then return end
    local ok, data = pcall(function()
        return _FH_AG_SyncRemotes.requestData:InvokeServer(channelName)
    end)
    if ok and typeof(data) == "table" then
        _FH_AG_PlotSync.caches[channelName] = data
    end
end
function _FH_AG_GetStealPrompt(plot, slot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    local podium = podiums and podiums:FindFirstChild(tostring(slot))
    local spawn = podium and podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
    local att = spawn and spawn:FindFirstChild("PromptAttachment")
    local prompt = att and att:FindFirstChildWhichIsA("ProximityPrompt")
    if not (prompt and prompt.Parent) then return nil end
    return prompt, spawn
end
function _FH_AG_ScanAllPlots()
    local result = {}

    local enemyPlots
    local okPlots = pcall(function() enemyPlots = getEnemyPlots() end)
    if not (okPlots and typeof(enemyPlots) == "table") then
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return result end
        enemyPlots = {}
        for _, plot in ipairs(plots:GetChildren()) do
            if not _FH_AG_IsMyPlot(plot) then
                table.insert(enemyPlots, plot)
            end
        end
    end

    for _, plot in ipairs(enemyPlots) do
        pcall(function()
            local cache = _FH_AG_PlotSync.caches[plot.Name]
            local animalList = cache and cache.AnimalList
            if typeof(animalList) ~= "table" then
                return
            end
            for slot, data in pairs(animalList) do
                if typeof(data) ~= "table" or not data.Index then
                    continue
                end
                local prompt, base, model
                local ok, p, b, m = pcall(function() return getStealPromptForSlot(plot, slot) end)
                if ok and p then
                    prompt, base, model = p, b, m
                else
                    prompt, base = _FH_AG_GetStealPrompt(plot, slot)
                end
                if not prompt or not prompt.Parent then
                    continue
                end
                local animalInfo = _FH_AG_AnimalsData[data.Index]
                local displayName = (animalInfo and animalInfo.DisplayName) or tostring(data.Index)
                local genValue = _FH_AG_AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
                local genText = "$" .. _FH_AG_NumberUtils:ToString(genValue) .. "/s"
                table.insert(result, {
                    displayName = displayName,
                    gen         = genText,
                    num         = genValue,
                    plot        = plot,
                    plotName    = plot.Name,
                    position    = prompt.Parent.WorldPosition,
                    prompt      = prompt,
                    model       = model,
                    base        = base,
                    slot        = tostring(slot),
                    mutation    = data.Mutation,
                    animalData  = data,
                    uid         = plot.Name .. "_" .. tostring(slot),
                    pos         = prompt.Parent.WorldPosition,
                    pod         = tonumber(slot) or 0,
                    genText     = genText,
                    genValue    = genValue,
                })
            end
        end)
    end
    table.sort(result, function(a, b)
        return (a.num or 0) > (b.num or 0)
    end)
    return result
end
function _FH_AG_GetNearestBrainrot()
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, brainrot in ipairs(_FH_AG_CachedBrainrots) do
        local d = (brainrot.pos - hrp.Position).Magnitude
        if d < bestDist then
            bestDist = d
            best = brainrot
        end
    end
    return best, bestDist
end

task.spawn(function()
    for _, child in ipairs(_FH_AG_SyncRemotes.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then
            _FH_AG_AttachPlotChannel(child)
        end
    end
end)
_FH_AG_SyncRemotes.channelFolder.ChildAdded:Connect(function(child)
    if child:IsA("RemoteEvent") then
        _FH_AG_AttachPlotChannel(child)
    end
end)
_FH_AG_SyncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, action in ipairs(actions) do
        local kind, channelName = action[1], tostring(action[2])
        if not plots:FindFirstChild(channelName) then continue end
        if kind == "ListenerAdded" then
            local remote = _FH_AG_SyncRemotes.channelFolder:FindFirstChild(channelName)
            if remote and remote:IsA("RemoteEvent") then
                _FH_AG_AttachPlotChannel(remote)
            end
        elseif kind == "ListenerRemoved" then
            _FH_AG_DetachPlotChannel(channelName)
        end
    end
end)
task.spawn(function()
    while task.wait(1.2) do
        pcall(function()
            local plots = workspace:FindFirstChild("Plots")
            if not plots then return end
            local pending = 0
            local done = 0
            for _, plot in ipairs(plots:GetChildren()) do
                if not _FH_AG_IsMyPlot(plot) then
                    pending = pending + 1
                    local name = plot.Name
                    task.spawn(function()
                        pcall(_FH_AG_RefreshPlotCache, name)
                        done = done + 1
                    end)
                end
            end
            local waitStart = tick()
            while done < pending and tick() - waitStart < 1.0 do
                task.wait(0.05)
            end
            _FH_AG_CachedBrainrots = _FH_AG_ScanAllPlots()
        end)
    end
end)

do
    local STRETCH_NAME = "FH_GameStretcher"
    local STRETCH_MAT  = CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.8, 0, 0, 0, 1)
    local enabled = false

    local function enableStretcher()
        if enabled then return end
        enabled = true
        pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end)
        pcall(function()
            RunService:BindToRenderStep(STRETCH_NAME, Enum.RenderPriority.Last.Value - 1, function()
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = cam.CFrame * STRETCH_MAT
                end
            end)
        end)
    end

    local function disableStretcher()
        if not enabled then return end
        enabled = false
        pcall(function() RunService:UnbindFromRenderStep(STRETCH_NAME) end)
    end

    ToggleHandlers.game_stretcher = function(state)
        if state then enableStretcher() else disableStretcher() end
    end
end
do
    local wallHighlights = {}
    local wallRotAngle   = 0
    local wallHeartbeat  = nil
    local function baseESP_findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local sf = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if sf then
                    local lbl = sf:FindFirstChildWhichIsA("TextLabel", true)
                    if lbl then
                        local txt = lbl.Text:lower()
                        if txt:find(Player.DisplayName:lower(), 1, true)
                        or txt:find(Player.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end
    local function baseESP_isWall(part)
        if not part:IsA("BasePart") then return false end
        if not part.Anchored then return false end
        local x, y, z = part.Size.X, part.Size.Y, part.Size.Z
        local minDim = math.min(x, y, z)
        local maxDim = math.max(x, y, z)
        local midDim = x + y + z - minDim - maxDim
        return minDim <= 1.2 and maxDim >= 8 and midDim >= 4
    end
    local function baseESP_clear()
        for _, hl in pairs(wallHighlights) do
            if hl and hl.Parent then hl:Destroy() end
        end
        wallHighlights = {}
    end
    local function baseESP_apply()
        baseESP_clear()
        local myPlot = baseESP_findMyPlot()
        if not myPlot then return end
        for _, part in ipairs(myPlot:GetDescendants()) do
            if baseESP_isWall(part) then
                local sel = Instance.new("SelectionBox")
                sel.Adornee           = part
                sel.LineThickness     = 0.08
                sel.SurfaceTransparency = 0.7
                sel.Color3            = Color3.fromRGB(255, 255, 255)
                sel.SurfaceColor3     = Color3.fromRGB(0, 0, 0)
                sel.Visible           = true
                sel.AlwaysOnTop       = true
                sel.Parent            = part
                table.insert(wallHighlights, sel)
            end
        end
    end
    do
        local ltbEnabled = false
        local ltbBeam, ltbAtt0, ltbAtt1, ltbAnchor, ltbCharConn, ltbPlotRefresh
        local ltbCachedPlot, ltbCachedPos = nil, nil
        local function _ltbFindMyPlotPos()
            if ltbCachedPlot and ltbCachedPlot.Parent then return ltbCachedPos end
            local plots = workspace:FindFirstChild("Plots")
            if not plots then return nil end
            for _, plot in ipairs(plots:GetChildren()) do
                if _FH_AG_IsMyPlot and _FH_AG_IsMyPlot(plot) then
                    local ok, pos = pcall(function() return plot:GetPivot().Position end)
                    if ok and pos then
                        ltbCachedPlot, ltbCachedPos = plot, pos
                        return pos
                    end
                end
            end
            return nil
        end
        local function _ltbCleanup()
            if ltbCharConn then ltbCharConn:Disconnect(); ltbCharConn = nil end
            if ltbPlotRefresh then ltbPlotRefresh:Disconnect(); ltbPlotRefresh = nil end
            if ltbBeam then ltbBeam:Destroy(); ltbBeam = nil end
            if ltbAtt0 then ltbAtt0:Destroy(); ltbAtt0 = nil end
            if ltbAtt1 then ltbAtt1:Destroy(); ltbAtt1 = nil end
            if ltbAnchor then ltbAnchor:Destroy(); ltbAnchor = nil end
            ltbCachedPlot, ltbCachedPos = nil, nil
        end
        local function _ltbSetup()
            _ltbCleanup()
            local char = Players.LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local pos = _ltbFindMyPlotPos()
            if not pos then return end
            ltbAnchor = Instance.new("Part")
            ltbAnchor.Name         = "FH_LineToBaseAnchor"
            ltbAnchor.Anchored     = true
            ltbAnchor.CanCollide   = false
            ltbAnchor.Transparency = 1
            ltbAnchor.Size         = Vector3.new(0.1, 0.1, 0.1)
            ltbAnchor.CFrame       = CFrame.new(pos)
            ltbAnchor.Parent       = workspace
            ltbAtt0 = Instance.new("Attachment")
            ltbAtt0.Parent = hrp
            ltbAtt1 = Instance.new("Attachment")
            ltbAtt1.Parent = ltbAnchor
            ltbBeam = Instance.new("Beam")
            ltbBeam.Name           = "FH_LineToBaseBeam"
            ltbBeam.Attachment0    = ltbAtt0
            ltbBeam.Attachment1    = ltbAtt1
            ltbBeam.Width0         = 0.4
            ltbBeam.Width1         = 0.4
            ltbBeam.FaceCamera     = true
            ltbBeam.LightEmission  = 1
            ltbBeam.LightInfluence = 0
            ltbBeam.Transparency   = NumberSequence.new(0)
            ltbBeam.Enabled        = true
            ltbBeam.Color          = ColorSequence.new(Color3.fromRGB(255, 0, 0))
            ltbBeam.Parent = hrp
            ltbCharConn = Players.LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.4)
                if ltbEnabled then _ltbSetup() end
            end)
        end
        ToggleHandlers.line_to_base = function(state)
            ltbEnabled = state and true or false
            if ltbEnabled then _ltbSetup() else _ltbCleanup() end
        end
    end
    ToggleHandlers.base_esp = function(state)
        if state then
            baseESP_apply()
            if wallHeartbeat then wallHeartbeat:Disconnect() end
            local _wallAcc = 0
            local _lastIntensity = -1
            wallHeartbeat = RunService.Heartbeat:Connect(function(dt)
                if #wallHighlights == 0 then return end
                wallRotAngle = (wallRotAngle + dt * 0.8) % 1
                _wallAcc = _wallAcc + dt
                if _wallAcc < 1/15 then return end
                _wallAcc = 0
                local brightness = (math.sin(wallRotAngle * math.pi * 2) + 1) / 2
                local intensity  = math.floor(30 + brightness * 225)
                if intensity == _lastIntensity then return end
                _lastIntensity = intensity
                local primary    = Color3.fromRGB(intensity, intensity, intensity)
                local secondary  = Color3.fromRGB(255 - intensity, 255 - intensity, 255 - intensity)
                for _, sel in ipairs(wallHighlights) do
                    if sel and sel.Parent then
                        sel.Color3        = primary
                        sel.SurfaceColor3 = secondary
                    end
                end
            end)
            task.spawn(function()
                while state and _G.FadedHubAlive do
                    task.wait(3)
                    local stale = false
                    for _, hl in ipairs(wallHighlights) do
                        if not hl or not hl.Parent then stale = true; break end
                    end
                    if stale or #wallHighlights == 0 then baseESP_apply() end
                end
            end)
        else
            if wallHeartbeat then wallHeartbeat:Disconnect(); wallHeartbeat = nil end
            baseESP_clear()
        end
    end
end
do
    local espHighlights = {}
    local espConns      = {}
    local function removeESP(player)
        local d = espHighlights[player]
        if d then
            if d.highlight and d.highlight.Parent then d.highlight:Destroy() end
            if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
            espHighlights[player] = nil
        end
    end
    local function applyESP(player)
        if player == Player then return end
        local char = player.Character
        if not char then return end
        removeESP(player)
        local hl = Instance.new("Highlight")
        hl.FillColor           = _G._FH_AccentA or Color3.fromRGB(255, 255, 255)
        hl.FillTransparency    = 0.3
        hl.OutlineColor        = _G._FH_AccentB or Color3.fromRGB(0, 0, 0)
        hl.OutlineTransparency = 0
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee             = char
        hl.Parent              = char
        local head = char:FindFirstChild("Head")
        local bb
        if head then
            bb = Instance.new("BillboardGui")
            bb.Name              = "FHPlayerESP"
            bb.Adornee           = head
            bb.Size              = UDim2.new(0, 240, 0, 50)
            bb.StudsOffset       = Vector3.new(0, 3.2, 0)
            bb.AlwaysOnTop       = true
            bb.ResetOnSpawn      = false
            bb.LightInfluence    = 0
            bb.MaxDistance        = 0
            bb.Parent            = head
            local lbl = Instance.new("TextLabel")
            lbl.Size                    = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency  = 1
            lbl.Text                    = string.format("%s (@%s)", player.DisplayName, player.Name)
            lbl.Font                    = Enum.Font.GothamBold
            lbl.TextSize                = 18
            lbl.TextColor3              = Color3.fromRGB(255, 255, 255)
            lbl.TextStrokeTransparency  = 0
            lbl.TextStrokeColor3        = Color3.fromRGB(0, 0, 0)
            lbl.TextXAlignment          = Enum.TextXAlignment.Center
            lbl.TextWrapped             = true
            lbl.ZIndex                  = 2
            lbl.Parent                  = bb
            if _G._FH_ApplyThemeGradientToText then _G._FH_ApplyThemeGradientToText(lbl) end
        end
        espHighlights[player] = { highlight = hl, billboard = bb }
    end
    local function enableESP()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then
                applyESP(plr)
                local c = plr.CharacterAdded:Connect(function()
                    task.wait(0.1); applyESP(plr)
                end)
                table.insert(espConns, c)
            end
        end
        table.insert(espConns, Players.PlayerAdded:Connect(function(plr)
            if plr == Player then return end
            local c = plr.CharacterAdded:Connect(function()
                task.wait(0.1); applyESP(plr)
            end)
            table.insert(espConns, c)
            task.wait(0.5); applyESP(plr)
        end))
        table.insert(espConns, Players.PlayerRemoving:Connect(function(plr)
            removeESP(plr)
        end))
    end
    local function disableESP()
        for _, conn in ipairs(espConns) do pcall(function() conn:Disconnect() end) end
        espConns = {}
        for plr in pairs(espHighlights) do removeESP(plr) end
        espHighlights = {}
    end
    ToggleHandlers.player_esp = function(state)
        if state then enableESP() else disableESP() end
    end

    _G._FH_RecolorPlayerESP = function()
        local a = _G._FH_AccentA or Color3.fromRGB(255, 255, 255)
        local b = _G._FH_AccentB or Color3.fromRGB(0, 0, 0)
        for _, d in pairs(espHighlights) do
            if d.highlight and d.highlight.Parent then
                d.highlight.FillColor    = a
                d.highlight.OutlineColor = b
            end
        end
    end
end
do
    local SUBSPACE_FOLDER = "ToolsAdds"
    local subspaceData    = {}
    local subspaceEnabled = false
    local subspaceConns   = {}

    local function _smOwnerLabel(mineName)
        local userName = mineName:match("SubspaceTripmine(.+)")
        if not userName then return "Unknown" end
        local foundPlayer = Players:FindFirstChild(userName)
        local displayName = foundPlayer and foundPlayer.DisplayName or userName
        return string.format("%s (@%s)", displayName, userName)
    end

    local function _smCurrentColor()
        return _G._FH_SubspaceColor or Color3.fromRGB(255, 255, 255)
    end

    local function _smCreateESP(mine)
        local ownerLabel = _smOwnerLabel(mine.Name)
        local col = _smCurrentColor()

        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name           = "ESP_Hitbox"
        selectionBox.Adornee        = mine
        selectionBox.Color3         = col
        selectionBox.LineThickness  = 0.06
        selectionBox.SurfaceColor3  = Color3.fromRGB(0, 0, 0)
        selectionBox.SurfaceTransparency = 1
        selectionBox.Parent         = mine

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name        = "ESP_Label"
        billboardGui.Adornee     = mine
        billboardGui.Size        = UDim2.new(0, 250, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent      = mine

        local textLabel = Instance.new("TextLabel")
        textLabel.Size                   = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text                   = ownerLabel .. "'s Subspace Mine"
        textLabel.TextColor3             = col
        textLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font                   = Enum.Font.GothamBold
        textLabel.TextSize               = 16
        textLabel.Parent                 = billboardGui

        return { selectionBox = selectionBox, billboardGui = billboardGui, mine = mine, textLabel = textLabel }
    end

    _G._FH_SubspaceRecolor = function()
        local col = _smCurrentColor()
        for _, data in pairs(subspaceData) do
            if data.selectionBox and data.selectionBox.Parent then
                data.selectionBox.Color3 = col
            end
            if data.textLabel and data.textLabel.Parent then
                data.textLabel.TextColor3 = col
            end
        end
    end

    local function _smClearAll()
        for _, data in pairs(subspaceData) do
            if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
            if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
        end
        table.clear(subspaceData)
    end

    local function _smIsMine(obj)
        return obj:IsA("BasePart") and obj.Name:match("^SubspaceTripmine") ~= nil
    end

    local function _smTryAdd(obj)
        if not subspaceEnabled then return end
        if not _smIsMine(obj) then return end
        if subspaceData[obj] then return end
        subspaceData[obj] = _smCreateESP(obj)
    end

    local function _smRemove(obj)
        local data = subspaceData[obj]
        if not data then return end
        if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
        if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
        subspaceData[obj] = nil
    end

    local function _smDisconnect()
        for _, c in ipairs(subspaceConns) do pcall(function() c:Disconnect() end) end
        subspaceConns = {}
    end

    local function _smBindFolder(folder)
        table.insert(subspaceConns, folder.ChildAdded:Connect(function(obj)
            if subspaceEnabled then _smTryAdd(obj) end
        end))
        table.insert(subspaceConns, folder.ChildRemoved:Connect(function(obj)
            _smRemove(obj)
        end))
        for _, obj in ipairs(folder:GetChildren()) do _smTryAdd(obj) end
    end

    local function _smEnable()
        if subspaceEnabled then return end
        subspaceEnabled = true
        local folder = workspace:FindFirstChild(SUBSPACE_FOLDER)
        if folder then _smBindFolder(folder) end

        table.insert(subspaceConns, workspace.ChildAdded:Connect(function(child)
            if subspaceEnabled and child.Name == SUBSPACE_FOLDER then
                _smBindFolder(child)
            end
        end))
    end

    local function _smDisable()
        if not subspaceEnabled then return end
        subspaceEnabled = false
        _smDisconnect()
        _smClearAll()
    end

    ToggleHandlers.subspace_mine_esp = function(state)
        if state then _smEnable() else _smDisable() end
    end
end
do
    local function ubIsOwnPlot(obj)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return false end
        for _, plot in ipairs(plots:GetChildren()) do
            local owned = (plot.Name == Player.Name)
            if not owned then
                local ov = plot:FindFirstChild("Owner")
                if ov and ov.Value == Player.Name then owned = true end
            end
            if owned and obj:IsDescendantOf(plot) then return true end
        end
        return false
    end
    local function ubNearOther(part, yLevel, thresh)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then
                local char = plr.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if math.abs(hrp.Position.Y - yLevel) <= thresh
                    and (hrp.Position - part.Position).Magnitude <= 60 then
                        return true
                    end
                end
            end
        end
        return false
    end
    local function ubIsLockPrompt(obj)
        local a = obj.ActionText:lower()
        local o = obj.ObjectText:lower()
        return a:find("lock") or o:find("lock")
    end
    UB.triggerFloor = function(yLevel, maxY)
        local char = Player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local THRESH = 5
        local pY = yLevel or hrp.Position.Y
        local bestSame, distSame   = nil, math.huge
        local bestFall, distFall   = nil, math.huge
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        for _, obj in ipairs(plots:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled
            and not ubIsOwnPlot(obj)
            and ubIsLockPrompt(obj) then
                local part = obj.Parent
                if part and part:IsA("BasePart") then
                    if not maxY or part.Position.Y <= maxY then
                        local dist  = (hrp.Position - part.Position).Magnitude
                        local yDiff = math.abs(pY - part.Position.Y)
                        if yDiff <= THRESH then
                            if ubNearOther(part, pY, THRESH) then
                                if dist < distSame then distSame = dist; bestSame = obj end
                            elseif bestSame == nil and dist < distFall then
                                distFall = dist; bestFall = obj
                            end
                        end
                    end
                end
            end
        end
        local target = bestSame or bestFall
        if not target then return end
        local orig = target.MaxActivationDistance
        target.MaxActivationDistance = 9999
        if fireproximityprompt then
            fireproximityprompt(target)
        else
            target:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            target:InputEnded(Enum.UserInputType.MouseButton1)
        end
        task.delay(0.2, function() target.MaxActivationDistance = orig end)
    end
    UB.floors = {
        [1] = { yLevel = -2, maxY = 19 },
        [2] = { yLevel = 15 },
        [3] = { yLevel = 32 },
    }
end
do
    local espBrainrotEnabled    = false
    local espBrainrotConnections = {}
    local Animals = nil
    local rarePets = {}
    local function initializeESP()
        local success, result = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))
        end)
        if success then
            Animals = result
            rarePets = {}

            local HIGH_TIER_RARITIES = {
                ["Brainrot God"] = true,
                ["Secret"]       = true,
            }
            local HIGH_TIER_NAMES = {
                ["Garama"]                       = true,
                ["Dragon Cannelloni"]            = true,
                ["Drags"]                        = true,
                ["La Vacca Saturno Saturnita"]   = true,
                ["La Vacca"]                     = true,
                ["Tralalero Tralala"]            = true,
                ["Tralalero"]                    = true,
                ["Tung Tung Tung Sahur Secret"]  = true,
                ["Tung Tung Sahur Secret"]       = true,
            }
            for petName, petData in pairs(Animals) do
                if petData and (HIGH_TIER_RARITIES[petData.Rarity] or HIGH_TIER_NAMES[petName]) then
                    table.insert(rarePets, petName)
                end
            end
        end
    end
    local function findPlayerBase()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in pairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local yourBase = sign:FindFirstChild("YourBase")
                if yourBase and yourBase.Enabled then return plot end
            end
        end
    end
    local function formatMutationText(mutationName)
        if not mutationName or mutationName == "None"then return ""
        end
        local f = ""
        if mutationName == "Cursed"then
            f = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"elseif mutationName == "Gold"then
            f = "<font color='rgb(255,215,0)'>Gold</font>"elseif mutationName == "Diamond"then
            f = "<font color='rgb(0,255,255)'>Diamond</font>"elseif mutationName == "YinYang"then
            f = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"elseif mutationName == "Candy"then
            f = "<font color='rgb(255,105,180)'>Candy</font>"elseif mutationName == "Divine"then
            f = "<font color='rgb(255,255,255)'>Divine</font>"elseif mutationName == "Rainbow"then
            local cols = {
                "rgb(255,0,0)","rgb(255,127,0)","rgb(255,255,0)",
                "rgb(0,255,0)","rgb(0,0,255)","rgb(75,0,130)","rgb(148,0,211)"}
            for i = 1, #mutationName do
                f = f .. "<font color='"..cols[(i-1)%#cols+1].."'>"..mutationName:sub(i,i).."</font>"end
        else
            f = mutationName
        end
        return f
    end
    local function _lookupGenForModel(model)
        if not model then return nil end
        local function scanGen(root)
            if not root then return nil end
            for _, d in ipairs(root:GetDescendants()) do
                if (d:IsA("BillboardGui") or d:IsA("SurfaceGui")) and d.Name ~= "PetNameTag" then
                    for _, lbl in ipairs(d:GetDescendants()) do
                        if lbl:IsA("TextLabel") and lbl.Name == "Generation" then
                            local txt = lbl.Text
                            if txt and txt ~= "" then return txt end
                        end
                    end
                end
            end
            return nil
        end
        local txt = scanGen(model)
        if txt then return txt end
        local cur = model.Parent
        local hops = 0
        while cur and cur ~= workspace and hops < 3 do
            txt = scanGen(cur)
            if txt then return txt end
            cur = cur.Parent
            hops = hops + 1
        end
        local index = model:GetAttribute("Index") or model:GetAttribute("AnimalIndex")
        if index and _FH_AG_AnimalsShared and _FH_AG_NumberUtils then
            local mut    = model:GetAttribute("Mutation")
            local traits = model:GetAttribute("Traits")
            local ok, gen = pcall(function() return _FH_AG_AnimalsShared:GetGeneration(index, mut, traits, nil) end)
            if not (ok and gen) then
                ok, gen = pcall(function() return _FH_AG_AnimalsShared:GetGeneration(index, mut, nil, nil) end)
            end
            if not (ok and gen) then
                ok, gen = pcall(function() return _FH_AG_AnimalsShared:GetGeneration(index) end)
            end
            if ok and gen then
                local okFmt, txt = pcall(function() return "$" .. _FH_AG_NumberUtils:ToString(gen) .. "/s" end)
                if okFmt and txt then return txt end
                return "$" .. tostring(gen) .. "/s"
            end
        end
        if _FH_AG_CachedBrainrots then
            for _, br in ipairs(_FH_AG_CachedBrainrots) do
                if br.model == model then return br.genText or br.gen end
            end
            for _, br in ipairs(_FH_AG_CachedBrainrots) do
                if br.model and (model:IsDescendantOf(br.model) or br.model:IsDescendantOf(model)) then
                    return br.genText or br.gen
                end
            end
        end
        return nil
    end
    local function createNameTag(model, petName, genTextOverride)
        for _, v in ipairs(model:GetChildren()) do
            if v.Name == "PetNameTag"then v:Destroy() end
        end
        local genText = genTextOverride or _lookupGenForModel(model)
        local bb = Instance.new("BillboardGui")
        bb.Name = "PetNameTag"
bb.Size = UDim2.new(0, 190, 0, genText and 56 or 40)
        bb.StudsOffset = Vector3.new(0, 1.1, 0)
        bb.AlwaysOnTop = true
        bb.Parent = model
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = bb
        local mutation = model:GetAttribute("Mutation") or "None"local formattedMutation = formatMutationText(mutation)
        local rowH = genText and (1/3) or 0.5
        local mutLabel = Instance.new("TextLabel")
        mutLabel.Size = UDim2.new(1, 0, rowH, 0)
        mutLabel.BackgroundTransparency = 1
        mutLabel.RichText = true
        mutLabel.Text = formattedMutation
        mutLabel.Font = Enum.Font.GothamBlack
        mutLabel.TextSize = 13
        mutLabel.TextStrokeTransparency = 0
        mutLabel.TextStrokeColor3 = Color3.new(0,0,0)
        mutLabel.TextYAlignment = Enum.TextYAlignment.Bottom
        mutLabel.Parent = frame
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, rowH, 0)
        nameLabel.Position = UDim2.new(0, 0, rowH, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = petName
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = Color3.new(1,1,1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
        nameLabel.TextYAlignment = genText and Enum.TextYAlignment.Center or Enum.TextYAlignment.Top
        nameLabel.Parent = frame
        if _G._FH_ApplyThemeGradientToText then _G._FH_ApplyThemeGradientToText(nameLabel) end
        if genText then
            local genLabel = Instance.new("TextLabel")
            genLabel.Name = "GenLabel"
            genLabel.Size = UDim2.new(1, 0, rowH, 0)
            genLabel.Position = UDim2.new(0, 0, rowH * 2, 0)
            genLabel.BackgroundTransparency = 1
            genLabel.Text = genText
            genLabel.Font = Enum.Font.GothamBlack
            genLabel.TextSize = 12
            genLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
            genLabel.TextStrokeTransparency = 0
            genLabel.TextStrokeColor3 = Color3.new(0,0,0)
            genLabel.TextYAlignment = Enum.TextYAlignment.Top
            genLabel.Parent = frame
        end
    end
    local function checkForRarePetCached(model, baseModel, genTextOverride)
        if not Animals then return end
        if baseModel then
            local cur = model
            while cur and cur ~= workspace do
                if cur == baseModel then return end
                cur = cur.Parent
            end
        end
        local existing = model:FindFirstChild("PetNameTag")
        if existing then
            local frame = existing:FindFirstChildOfClass("Frame")
            local hasGen = frame and frame:FindFirstChild("GenLabel") ~= nil
            if hasGen or not (genTextOverride or _lookupGenForModel(model)) then return end
        end
        local name = model.Name
        for _, petName in ipairs(rarePets) do
            if name == petName or string.find(name, petName) then
                createNameTag(model, petName, genTextOverride)
                return
            end
        end
    end
    local function checkForRarePet(model)
        checkForRarePetCached(model, findPlayerBase())
    end
    local function scanPlots()
        if not Animals then return end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        local baseModel = findPlayerBase()
        local syncCaches = _FH_AG_PlotSync and _FH_AG_PlotSync.caches
        if not syncCaches then return end

        for _, plot in ipairs(plots:GetChildren()) do
            if _FH_AG_IsMyPlot(plot) then continue end
            pcall(function()
                local cache = syncCaches[plot.Name]
                local animalList = cache and cache.AnimalList
                if typeof(animalList) ~= "table" then return end
                for slot, data in pairs(animalList) do
                    if typeof(data) ~= "table" or not data.Index then continue end
                    local prompt, base, model
                    local ok, p, b, m = pcall(function() return getStealPromptForSlot(plot, slot) end)
                    if ok and p then
                        prompt, base, model = p, b, m
                    else
                        prompt, base = _FH_AG_GetStealPrompt(plot, slot)
                    end
                    if not prompt or not prompt.Parent or not model or not model.Parent then continue end
                    local animalInfo  = _FH_AG_AnimalsData[data.Index]
                    local displayName = (animalInfo and animalInfo.DisplayName) or tostring(data.Index)
                    local isRare = false
                    for _, petName in ipairs(rarePets) do
                        if displayName == petName or string.find(displayName, petName) then isRare = true; break end
                    end
                    if not isRare then continue end
                    local genText
                    local okGen, genValue = pcall(function()
                        return _FH_AG_AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
                    end)
                    if okGen and genValue then
                        local okFmt, txt = pcall(function() return "$" .. _FH_AG_NumberUtils:ToString(genValue) .. "/s" end)
                        if okFmt and txt then genText = txt end
                    end
                    checkForRarePetCached(model, baseModel, genText)
                end
            end)
        end
    end
    local function _stopBrainrotConns()
        for _, conn in pairs(espBrainrotConnections) do
            pcall(function() conn:Disconnect() end)
        end
        espBrainrotConnections = {}
    end
    local function startESP()
        _stopBrainrotConns()
        scanPlots()

        local _plotsFolder = workspace:FindFirstChild("Plots")
        if _plotsFolder then
            espBrainrotConnections.added = _plotsFolder.DescendantAdded:Connect(function(obj)
                if not espBrainrotEnabled then return end
                if not obj:IsA("Model") then return end
                task.wait(0.2)
                checkForRarePet(obj)
                for _, d in ipairs(obj:GetDescendants()) do
                    if d:IsA("Model") then checkForRarePet(d) end
                end
            end)
        end

        task.spawn(function()
            while espBrainrotEnabled do
                task.wait(3)
                if espBrainrotEnabled then pcall(scanPlots) end
            end
        end)
    end
    initializeESP()
    local function enableBrainrotESP()
        espBrainrotEnabled = true
        startESP()
    end
    local function disableBrainrotESP()
        espBrainrotEnabled = false
        _stopBrainrotConns()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "PetNameTag"then obj:Destroy() end
        end
    end
    ToggleHandlers.brainrot_esp = function(state)
        if state then enableBrainrotESP() else disableBrainrotESP() end
    end
end

do
    _G._FH_CloneSwitched = false
    task.spawn(function()
        local hadOwn = false
        while task.wait(0.5) do
            local lp = Players.LocalPlayer
            if not lp then continue end
            local needle = lp.Name .. "_Clone"
            local hasOwn = false
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name == needle then
                    hasOwn = true; break
                end
            end
            if hadOwn and not hasOwn then
                _G._FH_CloneSwitched = true
                task.delay(30, function() _G._FH_CloneSwitched = false end)
                if _G._FH_RescanClonesAfterSwitch then
                    pcall(_G._FH_RescanClonesAfterSwitch)
                end
            end
            hadOwn = hasOwn
        end
    end)
end
do
    local cloneEspEnabled = false
    local cloneEspConnections = {}
    local function getPlayerFromClone(clone)
        if not clone:IsA("Model") then return nil end
        local humanoid = clone:FindFirstChildOfClass("Humanoid")
        if not humanoid then return nil end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                local charHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if charHumanoid.DisplayName == humanoid.DisplayName then return player end
            end
        end
        return nil
    end
    local function highlightClone(clone)

        if not _G._FH_CloneSwitched then return end
        local existing = clone:FindFirstChild("CloneHighlight")
        if existing then existing:Destroy() end
        local existingLabel = clone.Head and clone.Head:FindFirstChild("CloneLabel")
        if existingLabel then existingLabel:Destroy() end
        local player = getPlayerFromClone(clone)
        local labelText = "CLONE"if player then labelText = player.Name .. "CLONE"end
        local highlight = Instance.new("Highlight")
        highlight.Name = "CloneHighlight"
        highlight.FillColor = Color3.fromRGB(0, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.4
        highlight.OutlineTransparency = 0
        highlight.Parent = clone
        local head = clone:FindFirstChild("Head")
        if head then
            local humanoid = clone:FindFirstChildOfClass("Humanoid")
            local displayName = humanoid and humanoid.DisplayName or ""
            local clonePlayerName = ""
            if player then
                clonePlayerName = player.Name
                if displayName == ""
                then displayName = player.DisplayName end
            end
            local nameTag = string.format("(%s) @%s CLONE", displayName ~= ""
            and displayName or clonePlayerName, clonePlayerName)
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "CloneLabel"
billboard.Adornee = head
            billboard.Size = UDim2.new(0, 240, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = nameTag
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextSize = 15
            textLabel.Font = Enum.Font.GothamBold
            textLabel.TextStrokeTransparency = 0
            textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            textLabel.Parent = billboard
            if _G._FH_ApplyThemeGradientToText then _G._FH_ApplyThemeGradientToText(textLabel) end
        end
    end
    local function clearAllCloneESP()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:find("_Clone") and obj:IsA("Model") then
                local highlight = obj:FindFirstChild("CloneHighlight")
                local label = obj.Head and obj.Head:FindFirstChild("CloneLabel")
                if highlight then highlight:Destroy() end
                if label then label:Destroy() end
            end
        end
    end
    local function startCloneESP()
        clearAllCloneESP()
        cloneEspConnections.workspaceAdded = workspace.ChildAdded:Connect(function(child)
            if cloneEspEnabled and child.Name:find("_Clone") and child:IsA("Model") then
                task.wait(0.1)
                highlightClone(child)
            end
        end)
        local _cloneTimer = 0
        cloneEspConnections.heartbeat = RunService.Heartbeat:Connect(function(dt)
            if not cloneEspEnabled then return end
            _cloneTimer = _cloneTimer + dt
            if _cloneTimer < 0.5 then return end
            _cloneTimer = 0
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name:find("_Clone") and obj:IsA("Model") and not obj:FindFirstChild("CloneHighlight") then
                    highlightClone(obj)
                end
            end
        end)
    end
    local function stopCloneESP()
        cloneEspEnabled = false
        for _, conn in pairs(cloneEspConnections) do
            if conn then conn:Disconnect() end
        end
        cloneEspConnections = {}
        clearAllCloneESP()
    end
    ToggleHandlers.clone_esp = function(state)
        cloneEspEnabled = state
        if state then startCloneESP() else stopCloneESP() end
    end

    _G._FH_RescanClonesAfterSwitch = function()
        if not cloneEspEnabled then return end
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("_Clone")
               and not obj:FindFirstChild("CloneHighlight") then
                pcall(highlightClone, obj)
            end
        end
    end
end
do
    local plotsFolder = workspace:FindFirstChild("Plots")
    local baseEspInstances = {}
    local BaseTimerESP = false
    local _baseTimerTexts = {}
    local _baseAllowTexts = {}
    _G._FH_BaseTimerESP_Active     = function() return BaseTimerESP end
    _G._FH_BaseTimerTexts          = _baseTimerTexts
    _G._FH_BaseAllowTexts          = _baseAllowTexts
    _G._FH_BaseEspInstances        = baseEspInstances
    _G._FH_BaseTimerESP_SetActive  = function(v) BaseTimerESP = v end
    local function _buildCombinedText(plot)
        local timer = _baseTimerTexts[plot]
        local allow = _baseAllowTexts[plot]
        if timer and allow then
            return timer .. "\n" .. allow
        elseif timer then
            return timer
        elseif allow then
            return allow
        end
        return ""
    end
    local function _getOrCreateBillboard(plot, mainPart)
        if baseEspInstances[plot] and baseEspInstances[plot].Parent then
            return baseEspInstances[plot]
        end
        if baseEspInstances[plot] then baseEspInstances[plot]:Destroy() end
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "BaseTimerESP"
        billboard.Size = UDim2.new(0, 70, 0, 32)
        billboard.StudsOffset = Vector3.new(0, 6, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = mainPart
        billboard.MaxDistance = 2000
        billboard.Parent = plot
        local bg = Instance.new("Frame")
        bg.Name = "BG"
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(5, 10, 30)
        bg.BackgroundTransparency = 0.3
        bg.BorderSizePixel = 0
        bg.Parent = billboard
        do
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 6)
            c.Parent = bg
        end
        local label = Instance.new("TextLabel")
        label.Name = "TimerText"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(100, 200, 255)
        label.TextStrokeTransparency = 0.3
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = bg
        baseEspInstances[plot] = billboard
        return billboard
    end
    local function _refreshPlotBillboard(plot)
        local text = _buildCombinedText(plot)
        if text == "" then
            if baseEspInstances[plot] then
                baseEspInstances[plot]:Destroy()
                baseEspInstances[plot] = nil
            end
            return
        end

        local purchases = plot:FindFirstChild("Purchases")
        local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
        local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
        if not mainPart then
            if baseEspInstances[plot] then
                baseEspInstances[plot]:Destroy()
                baseEspInstances[plot] = nil
            end
            return
        end
        local billboard = _getOrCreateBillboard(plot, mainPart)
        local bg = billboard:FindFirstChild("BG")
        local label = bg and bg:FindFirstChild("TimerText")
        if label then
            if _baseTimerTexts[plot] and _baseAllowTexts[plot] then
                local allowText = _baseAllowTexts[plot]
                local isAllowed = allowText:find("Allowed") and not allowText:find("Dis")
                local lbl2 = bg:FindFirstChild("AllowLine")
                if not lbl2 then
                    lbl2 = Instance.new("TextLabel")
                    lbl2.Name = "AllowLine"
                    lbl2.Size = UDim2.new(1, -4, 0, 12)
                    lbl2.Position = UDim2.new(0, 2, 1, -13)
                    lbl2.BackgroundTransparency = 1
                    lbl2.TextScaled = true
                    lbl2.Font = Enum.Font.GothamBold
                    lbl2.TextStrokeTransparency = 0.3
                    lbl2.TextStrokeColor3 = Color3.new(0, 0, 0)
                    lbl2.Parent = bg
                end
                lbl2.Text = allowText
                lbl2.TextColor3 = isAllowed and Color3.fromRGB(26, 255, 0) or Color3.fromRGB(252, 3, 3)
                lbl2.Visible = true
                label.Text = _baseTimerTexts[plot]
                label.TextColor3 = Color3.fromRGB(100, 200, 255)
                billboard.Size = UDim2.new(0, 84, 0, 44)
                label.Size = UDim2.new(1, -4, 0, 26)
                label.Position = UDim2.new(0, 2, 0, 2)
            else
                local lbl2 = bg:FindFirstChild("AllowLine")
                if lbl2 then lbl2.Visible = false end
                billboard.Size = UDim2.new(0, 70, 0, 32)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Position = UDim2.new(0, 0, 0, 0)
                if _baseAllowTexts[plot] then
                    local isAllowed = _baseAllowTexts[plot]:find("Allowed") and not _baseAllowTexts[plot]:find("Dis")
                    label.TextColor3 = isAllowed and Color3.fromRGB(26, 255, 0) or Color3.fromRGB(252, 3, 3)
                else
                    label.TextColor3 = Color3.fromRGB(100, 200, 255)
                end
                label.Text = text
            end
        end
    end
    _G._FH_RefreshPlotBillboard = _refreshPlotBillboard
    local function _getPlotForPart(part)
        local plots = plotsFolder
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            if part:IsDescendantOf(plot) then return plot end
        end
        return nil
    end
    _G._FH_GetPlotForPart = _getPlotForPart
    local function clearBaseESP()
        for _, gui in pairs(baseEspInstances) do
            if gui then gui:Destroy() end
        end
        table.clear(baseEspInstances)
        table.clear(_baseTimerTexts)
    end
    local function updateBaseESP()
        if not BaseTimerESP then clearBaseESP(); return end
        if not plotsFolder then return end
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            local purchases = plot:FindFirstChild("Purchases")
            local plotBlock = purchases and purchases:FindFirstChild("PlotBlock")
            local mainPart = plotBlock and plotBlock:FindFirstChild("Main")
            local timeLabel = mainPart
                and mainPart:FindFirstChild("BillboardGui")
                and mainPart.BillboardGui:FindFirstChild("RemainingTime")
            if timeLabel and mainPart then
                _baseTimerTexts[plot] = timeLabel.Text
                _refreshPlotBillboard(plot)
            else
                _baseTimerTexts[plot] = nil
                if baseEspInstances[plot] then

                    if not _baseAllowTexts[plot] then
                        baseEspInstances[plot]:Destroy()
                        baseEspInstances[plot] = nil
                    else
                        _refreshPlotBillboard(plot)
                    end
                end
            end
        end
    end
    local _baseTimer = 0
    RunService.Heartbeat:Connect(function(dt)
        if not BaseTimerESP then return end
        _baseTimer = _baseTimer + dt
        if _baseTimer < 0.5 then return end
        _baseTimer = 0
        updateBaseESP()
    end)

    ToggleHandlers.base_timer_esp = function(state)
        BaseTimerESP = state
        if not state then
            table.clear(_baseTimerTexts)

            if FriendsESPEnabled then
                if plotsFolder then
                    for _, plot in ipairs(plotsFolder:GetChildren()) do
                        _refreshPlotBillboard(plot)
                    end
                end
            else
                clearBaseESP()
            end
        end
    end
end
do
    local function startFriendsESP()
        task.spawn(function()
            task.wait(2)
            local function upd(prompt)
                if not FriendsESPEnabled then return end
                local parent = prompt.Parent
                if not parent or not parent:IsA("BasePart") then return end

                for _, c in ipairs(parent:GetChildren()) do
                    if c.Name == "FriendInd"then
                        c:Destroy()
                    end
                end
                local text = string.lower(prompt.ObjectText or "")
                if not string.find(text, "friends") then

                    local getPlot = _G._FH_GetPlotForPart
                    if getPlot then
                        local plot = getPlot(parent)
                        if plot and _G._FH_BaseAllowTexts then
                            _G._FH_BaseAllowTexts[plot] = nil
                            if _G._FH_BaseTimerESP_Active and _G._FH_BaseTimerESP_Active() then
                                if _G._FH_RefreshPlotBillboard then _G._FH_RefreshPlotBillboard(plot) end
                            elseif _G._FH_BaseEspInstances then
                                local inst = _G._FH_BaseEspInstances[plot]
                                if inst then inst:Destroy(); _G._FH_BaseEspInstances[plot] = nil end
                            end
                        end
                    end
                    return
                end
                local isAllowed = text:find("disallow") ~= nil
                local allowLabel = isAllowed and "Allowed" or "Disallowed"
                local allowColor = isAllowed and Color3.fromRGB(26, 255, 0) or Color3.fromRGB(252, 3, 3)

                if _G._FH_BaseTimerESP_Active and _G._FH_BaseTimerESP_Active() then
                    local getPlot = _G._FH_GetPlotForPart
                    if getPlot then
                        local plot = getPlot(parent)
                        if plot then
                            _G._FH_BaseAllowTexts[plot] = allowLabel
                            _G._FH_RefreshPlotBillboard(plot)
                            return
                        end
                    end
                end

                local getPlot = _G._FH_GetPlotForPart
                if getPlot then
                    local plot = getPlot(parent)
                    if plot then
                        _G._FH_BaseAllowTexts[plot] = allowLabel

                        if _G._FH_RefreshPlotBillboard then
                            _G._FH_RefreshPlotBillboard(plot)
                            return
                        end
                    end
                end

                local bb = Instance.new("BillboardGui")
                bb.Name = "FriendInd"
                bb.Size = UDim2.new(0, 160, 0, 40)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 4, 0)
                bb.Parent = parent
                local lbl2 = Instance.new("TextLabel")
                lbl2.Size = UDim2.new(1, 0, 1, 0)
                lbl2.BackgroundTransparency = 1
                lbl2.Font = Enum.Font.GothamBlack
                lbl2.TextSize = 16
                lbl2.TextStrokeTransparency = 0.4
                lbl2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                lbl2.Text = allowLabel
                lbl2.TextColor3 = allowColor
                lbl2.Parent = bb
            end

            local _plotsRoot = workspace:FindFirstChild("Plots")
            local _scanRoot  = _plotsRoot or workspace
            local _step = 0
            for _, o in ipairs(_scanRoot:GetDescendants()) do
                if o:IsA("ProximityPrompt") then
                    upd(o)
                    local conn = o:GetPropertyChangedSignal("ObjectText"):Connect(function()
                        upd(o)
                    end)
                    table.insert(FriendsESPConnections, conn)
                end
                _step = _step + 1
                if _step % 500 == 0 then task.wait() end
            end
            local conn = _scanRoot.DescendantAdded:Connect(function(o)
                if not FriendsESPEnabled then return end
                if o:IsA("ProximityPrompt") then
                    task.wait(0.1)
                    upd(o)
                    local c = o:GetPropertyChangedSignal("ObjectText"):Connect(function()
                        upd(o)
                    end)
                    table.insert(FriendsESPConnections, c)
                end
            end)
            table.insert(FriendsESPConnections, conn)
        end)
    end
    local function stopFriendsESP()
        for _, conn in ipairs(FriendsESPConnections) do
            if conn then conn:Disconnect() end
        end
        table.clear(FriendsESPConnections)
        for _, v in ipairs(workspace:GetDescendants()) do
            if v.Name == "FriendInd"then
                v:Destroy()
            end
        end

        if _G._FH_BaseAllowTexts then
            for k in pairs(_G._FH_BaseAllowTexts) do
                _G._FH_BaseAllowTexts[k] = nil
            end
        end

        local plots = workspace:FindFirstChild("Plots")
        if plots and _G._FH_RefreshPlotBillboard then
            for _, plot in ipairs(plots:GetChildren()) do
                _G._FH_RefreshPlotBillboard(plot)
            end
        end
    end
    ToggleHandlers.allowed_esp = function(state)
        FriendsESPEnabled = state
        if state then startFriendsESP() else stopFriendsESP() end
    end
end
do
    local carpetSpeedEnabled = false
    local carpetSpeedConnection = nil
    local carpetStatusLabel = nil
    local _carpetToolWatchConn = nil
    local _carpetBoosterWasOn = false
    _G._FH_CarpetClearBoosterMem = function() _carpetBoosterWasOn = false end
    local function setCarpetSpeed(enabled)
        if carpetSpeedConnection then
            carpetSpeedConnection:Disconnect()
            carpetSpeedConnection = nil
        end
        if _carpetToolWatchConn then
            _carpetToolWatchConn:Disconnect()
            _carpetToolWatchConn = nil
        end
        if not enabled then
            local _c = Players.LocalPlayer.Character
            local _hrp = _c and _c:FindFirstChild("HumanoidRootPart")
            if _hrp then
                _hrp.Velocity = Vector3.new(0, _hrp.Velocity.Y, 0)
            end
            local _bp = Players.LocalPlayer:FindFirstChild("Backpack")
            local _carpet = _c and _c:FindFirstChild("Flying Carpet")
            if _carpet and _bp then
                _carpet.Parent = _bp
            end
            if _carpetBoosterWasOn then
                _carpetBoosterWasOn = false
                if SP and not SP.state then
                    SP.spBoosterDoToggle()
                end
            end
            return
        end
        if SP and SP.state then
            SP.spBoosterDoToggle()
            _carpetBoosterWasOn = true
        else
            _carpetBoosterWasOn = false
        end
        _carpetToolWatchConn = Players.LocalPlayer.CharacterAdded:Connect(function() end)
        if _carpetToolWatchConn then _carpetToolWatchConn:Disconnect() end
        local char = Players.LocalPlayer.Character
        if char then
            _carpetToolWatchConn = char.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name ~= "Flying Carpet"then
                    carpetSpeedEnabled = false
                    setCarpetSpeed(false)
                    Toggles["carpet_speed"] = false
                    local reg = configRegistry["Carpet Speed"]
                    if reg and reg.getState and reg.getState() then
                        if reg.setEnabled then reg.setEnabled(false) end
                    end
                    ShowToggleNotification("Carpet Speed: OFF (tool changed)", false)
                end
            end)
        end
        carpetSpeedConnection = RunService.Heartbeat:Connect(function()
            local c = Players.LocalPlayer.Character
            if not c then return end
            local hum = c:FindFirstChild("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local toolName = "Flying Carpet"local hasTool = c:FindFirstChild(toolName)
            if not hasTool then
                local tb = Players.LocalPlayer.Backpack:FindFirstChild(toolName)
                if tb then hum:EquipTool(tb) end
            end
            if hasTool then
                local md = hum.MoveDirection
                if md.Magnitude > 0 then
                    local flatDir = Vector3.new(md.X, 0, md.Z).Unit
                    hrp.Velocity = Vector3.new(flatDir.X * 140, hrp.Velocity.Y, flatDir.Z * 140)
                end
            end
        end)
    end
do
    local LocalPlayer = Players.LocalPlayer
    local function findPlayerBase_TP()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in pairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local yourBase = sign:FindFirstChild("YourBase")
                if yourBase and yourBase.Enabled then
                    return plot
                end
            end
        end
    end
    local function carpetTpNextBase()
        local MyPlot = findPlayerBase_TP()
        if not MyPlot then return end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local order = MyPlot:GetAttribute("Order")
        local approachWaypoints, finalPos
        if order == 2 then
            approachWaypoints = {
                Vector3.new(-352.54, -6.83,   6.66),
                Vector3.new(-351.49, -6.65, 113.72),
                Vector3.new(-337.62, -3.68,  18.13),
                Vector3.new(-337,    -5,     103),
            }
            finalPos = Vector3.new(-348.617157, -6.603045, 113.494453)
        elseif order == 1 then
            approachWaypoints = {
                Vector3.new(-351.49, -6.65, 113.72),
                Vector3.new(-352.54, -6.83,   6.66),
                Vector3.new(-337.62, -3.68,  18.13),
                Vector3.new(-336.37, -3.68, 18.54),
            }
            finalPos = Vector3.new(-350.54, -5.58, 36.59)
        else
            return
        end
        if SS and SS.SSEquipGrapple then pcall(SS.SSEquipGrapple) end
        if _G._FH_WalkTo then
            for _, wp in ipairs(approachWaypoints) do
                _G._FH_WalkTo(wp, 180)
            end
        end
        task.wait(0.25)
        if giantSpeedEnabled then
            local lp = Players.LocalPlayer
            local c  = lp.Character
            local bp = lp:FindFirstChild("Backpack")
            if c and bp then
                local potion = nil
                local potionNames = {"Giant Potion", "Giant", "Grow Potion", "Super Grow", "Potion"}
                for _, name in ipairs(potionNames) do
                    potion = c:FindFirstChild(name) or bp:FindFirstChild(name)
                    if potion and potion:IsA("Tool") then break end
                end
                if potion then
                    local hum = c:FindFirstChildOfClass("Humanoid")
                    if potion.Parent ~= c and hum then hum:EquipTool(potion) end
                    task.wait(0.05)
                    pcall(function() potion:Activate() end)
                end
            end
        end
        if SS and SS.SSEquipGrapple then pcall(SS.SSEquipGrapple) end
        if SS and SS.SSTeleportHRP then
            pcall(SS.SSTeleportHRP, finalPos)
        else
            _G._FH_CarpetTP(CFrame.new(finalPos), 70)
        end
    end
    ToggleHandlers.carpet_tp_base = function(state)
        if state then
            task.spawn(carpetTpNextBase)
            task.defer(function()
                local reg = configRegistry["Teleport Next Base"]
                if reg and reg.getState() then
                    reg.doToggle()
                end
            end)
        end
    end
end
ToggleHandlers.carpet_speed = function(state)
        carpetSpeedEnabled = state
        if state then
            setCarpetSpeed(true)
        else
            setCarpetSpeed(false)
        end
    end
end
local speedBoosterConnection, jumpBoosterConnection = nil, nil
local jumpBoosterEnabled, speedBoosterEnabled = false, false
local _cachedSpeed, _cachedJump = 29, 50
local _chHum, _chHrp = nil, nil
local function _refreshCharCache(c)
    c = c or Players.LocalPlayer.Character
    _chHum = c and c:FindFirstChildOfClass("Humanoid") or nil
    _chHrp = c and c:FindFirstChild("HumanoidRootPart") or nil
end
Players.LocalPlayer.CharacterAdded:Connect(function(c)
    c:WaitForChild("HumanoidRootPart", 5); _refreshCharCache(c)
end)
_refreshCharCache()
local function _bindBoxCache(box, key)
    if not box then return end
    local apply = function() local v = tonumber(box.Text); if v then if key == "s" then _cachedSpeed = v else _cachedJump = v end end end
    box:GetPropertyChangedSignal("Text"):Connect(apply); apply()
end
task.defer(function() _bindBoxCache(SP and SP.wsBox, "s"); _bindBoxCache(SP and SP.jpBox, "j") end)

local function setJumpBooster(enabled)
    if jumpBoosterConnection then jumpBoosterConnection:Disconnect(); jumpBoosterConnection = nil end
    jumpBoosterEnabled = enabled
    if not enabled then return end
    local debounce = false
    jumpBoosterConnection = UserInputService.JumpRequest:Connect(function()
        if not jumpBoosterEnabled or debounce then return end
        if not (UserInputService:IsKeyDown(Enum.KeyCode.Space)
             or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonA)
             or UserInputService.TouchEnabled) then return end
        local hum, hrp = _chHum, _chHrp
        if not hum or not hrp or hum.FloorMaterial == Enum.Material.Air then return end
        debounce = true
        task.delay(0.05, function()
            if not jumpBoosterEnabled then debounce = false; return end
            local h = _chHrp
            if h then
                local v = h.Velocity
                h.Velocity = Vector3.new(v.X, _cachedJump, v.Z)
            end
            local hu = _chHum
            if not hu then debounce = false; return end
            local landConn
            landConn = hu.StateChanged:Connect(function(_, new)
                if new == Enum.HumanoidStateType.Landed
                or new == Enum.HumanoidStateType.Running
                or new == Enum.HumanoidStateType.RunningNoPhysics then
                    debounce = false; landConn:Disconnect()
                end
            end)
            task.delay(4, function()
                if debounce then debounce = false; pcall(function() landConn:Disconnect() end) end
            end)
        end)
    end)
end

local function setSpeedBooster(enabled)
    if speedBoosterConnection then speedBoosterConnection:Disconnect(); speedBoosterConnection = nil end
    speedBoosterEnabled = enabled
    if not enabled then return end
    speedBoosterConnection = RunService.Heartbeat:Connect(function()
        local lp = Players.LocalPlayer
        if not lp.Character then return end
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = lp.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid then return end
        if SP and SP.stealOnlyEnabled and not lp:GetAttribute("Stealing") then return end
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
            hrp.Velocity = Vector3.new(
                flatDir.X * _cachedSpeed,
                hrp.Velocity.Y,
                flatDir.Z * _cachedSpeed
            )
        end
    end)
end
local giantSpeedEnabled = false
local giantSpeedConnection = nil
local GIANT_THRESHOLD = 2.5
local _isGiant = false
local function _giantSpeedDisconnect()
    if giantSpeedConnection then
        giantSpeedConnection:Disconnect()
        giantSpeedConnection = nil
    end
    local _c = Players.LocalPlayer.Character
    local _hrp = _c and _c:FindFirstChild("HumanoidRootPart")
    if _hrp then
        _hrp.Velocity = Vector3.new(0, _hrp.Velocity.Y, 0)
    end
end
local function onGiantActivated()
    _isGiant = true
    if giantSpeedConnection then return end
    giantSpeedConnection = RunService.Heartbeat:Connect(function()
        local c = Players.LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChild("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            local spd = tonumber(SP and SP.wsBox and SP.wsBox.Text) or 29
            local flatDir = Vector3.new(md.X, 0, md.Z).Unit
            hrp.Velocity = Vector3.new(flatDir.X * spd, hrp.Velocity.Y, flatDir.Z * spd)
        end
    end)
end
local function onGiantDeactivated()
    _isGiant = false
    _giantSpeedDisconnect()
end
local function checkGiantState()
    local c = Players.LocalPlayer.Character
    if not c then return end
    local humanoid = c:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local scaleValue = humanoid:FindFirstChild("BodyHeightScale")
        or humanoid:FindFirstChild("BodyDepthScale")
        or humanoid:FindFirstChild("BodyWidthScale")
    if scaleValue then
        local giant = scaleValue.Value >= GIANT_THRESHOLD
        if giant and not _isGiant then
            onGiantActivated()
        elseif not giant and _isGiant then
            onGiantDeactivated()
        end
    end
end
local _giantTimer = 0
RunService.Heartbeat:Connect(function(dt)
    _giantTimer = _giantTimer + dt
    if _giantTimer < 0.5 then return end
    _giantTimer = 0
    checkGiantState()
end)
Players.LocalPlayer.CharacterAdded:Connect(function()
    _isGiant = false
    _giantSpeedDisconnect()
end)
ToggleHandlers.giant_speed = function(state)
    giantSpeedEnabled = state
    if state then
        if _isGiant then onGiantActivated() end
    else
        _giantSpeedDisconnect()
    end
end
do
    local alarmEnabled = false
    local alarmConnection = nil
    local alarmNotifLbl = nil
    local lp = Players.LocalPlayer
    local function ensureAlarmLabel()
        if alarmNotifLbl and alarmNotifLbl.Parent then return end
        alarmNotifLbl = Instance.new("TextLabel")
        alarmNotifLbl.AnchorPoint        = Vector2.new(0.5, 1)
        alarmNotifLbl.Position           = UDim2.new(0.5, 0, 0.92, 0)
        alarmNotifLbl.Size               = UDim2.new(0, 600, 0, 80)
        alarmNotifLbl.BackgroundTransparency = 1
        alarmNotifLbl.TextColor3         = Color3.fromRGB(255, 70, 70)
        alarmNotifLbl.TextSize           = 26
        alarmNotifLbl.Font               = Enum.Font.GothamBold
        alarmNotifLbl.TextWrapped        = true
        alarmNotifLbl.TextStrokeTransparency = 0.3
        alarmNotifLbl.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
        alarmNotifLbl.Visible            = false
        alarmNotifLbl.ZIndex             = 50
        alarmNotifLbl.Parent             = GUI
    end
    local function getStealHitbox()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local lbl = sign:FindFirstChildWhichIsA("TextLabel", true)
                if lbl then
                    local t = lbl.Text:lower()
                    if t:find(lp.Name:lower()) or t:find(lp.DisplayName:lower()) then
                        return plot:FindFirstChild("StealHitbox", true)
                    end
                end
            end
        end
        return nil
    end
    local function startAlarm()
        ensureAlarmLabel()
        if alarmConnection then alarmConnection:Disconnect() end
        local _alarmAcc = 0
        alarmConnection = RunService.Heartbeat:Connect(function(dt)
            if not alarmEnabled then
                if alarmNotifLbl then alarmNotifLbl.Visible = false end
                return
            end
            _alarmAcc = _alarmAcc + dt
            if _alarmAcc < 0.25 then return end
            _alarmAcc = 0
            local hitbox = getStealHitbox()
            if not hitbox then
                if alarmNotifLbl then alarmNotifLbl.Visible = false end
                return
            end
            local cf   = hitbox.CFrame
            local size = hitbox.Size
            local hx, hz = size.X * 0.5, size.Z * 0.5
            local intruders = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local char = p.Character
                    if char then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local rel = cf:PointToObjectSpace(hrp.Position)
                            if math.abs(rel.X) <= hx and math.abs(rel.Z) <= hz then
                                table.insert(intruders, p.Name)
                            end
                        end
                    end
                end
            end
            if #intruders > 0 then
                alarmNotifLbl.Text = "\240\159\154\168 ".. #intruders .. "Player".. (#intruders > 1 and "s"or "") .. "in your Base! \240\159\154\168\n".. table.concat(intruders, ", ")
                alarmNotifLbl.Visible = true
            else
                alarmNotifLbl.Visible = false
            end
        end)
    end
    local function stopAlarm()
        alarmEnabled = false
        if alarmConnection then
            alarmConnection:Disconnect()
            alarmConnection = nil
        end
        if alarmNotifLbl then alarmNotifLbl.Visible = false end
    end
    ToggleHandlers.base_alarm = function(state)
        alarmEnabled = state
        if state then
            startAlarm()
        else
            stopAlarm()
        end
    end
end
do
    local AutoResetBalloonEnabled = false
    local _arbLastFire = 0
    local _arbConns   = {}
    local _arbAddConn = nil
    local _arbBoundRemotes = {}
    local function _arbStringMatchesBalloon(s)
        if type(s) ~= "string" then return false end

        local ls = s:lower()
        return ls:find("jump higher", 1, true) ~= nil
    end

    local function _arbHandleArgs(...)

        if not AutoResetBalloonEnabled then return end
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            if _arbStringMatchesBalloon(arg) then
                local now = tick()
                if now - _arbLastFire < 3 then return end
                _arbLastFire = now

                if AutoResetBalloonEnabled then
                    doSelectedReset()
                end
                return
            end
        end
    end
    local function _arbBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end

        if _arbBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(_arbHandleArgs)
        end)
        if ok and conn then
            table.insert(_arbConns, conn)
            _arbBoundRemotes[obj] = true
        end
    end
    local function startAutoResetBalloon()

        for _, conn in ipairs(_arbConns) do
            pcall(function() conn:Disconnect() end)
        end
        _arbConns = {}
        _arbBoundRemotes = {}
        if _arbAddConn then
            pcall(function() _arbAddConn:Disconnect() end)
            _arbAddConn = nil
        end

        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            _arbBindRemote(obj)
        end

        _arbAddConn = ReplicatedStorage.DescendantAdded:Connect(function(obj)
            if AutoResetBalloonEnabled then _arbBindRemote(obj) end
        end)
    end
    local function stopAutoResetBalloon()
        AutoResetBalloonEnabled = false
        for _, conn in ipairs(_arbConns) do
            pcall(function() conn:Disconnect() end)
        end
        _arbConns = {}
        _arbBoundRemotes = {}
        if _arbAddConn then
            pcall(function() _arbAddConn:Disconnect() end)
            _arbAddConn = nil
        end
    end
    ToggleHandlers.auto_reset_balloon = function(state)
        AutoResetBalloonEnabled = state
        if state then
            startAutoResetBalloon()
        else
            stopAutoResetBalloon()
        end
    end
    ToggleHandlers.set_auto_reset_mode = function(_mode) end
end
do
    local AutoResetJailEnabled = false
    local _arjLastFire = 0
    local _arjConns   = {}
    local _arjAddConn = nil
    local _arjBoundRemotes = {}
    local function _arjStringMatchesJail(s)
        if type(s) ~= "string" then return false end

        return s:lower():find("trapped for 10 seconds", 1, true) ~= nil
    end

    local function _arjHandleArgs(...)

        if not AutoResetJailEnabled then return end
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            if _arjStringMatchesJail(arg) then
                local now = tick()
                if now - _arjLastFire < 3 then return end
                _arjLastFire = now

                if AutoResetJailEnabled then
                    doSelectedReset()
                end
                return
            end
        end
    end
    local function _arjBindRemote(obj)
        if not obj:IsA("RemoteEvent") then return end

        if _arjBoundRemotes[obj] then return end
        local ok, conn = pcall(function()
            return obj.OnClientEvent:Connect(_arjHandleArgs)
        end)
        if ok and conn then
            table.insert(_arjConns, conn)
            _arjBoundRemotes[obj] = true
        end
    end
    local function startAutoResetJail()
        for _, conn in ipairs(_arjConns) do
            pcall(function() conn:Disconnect() end)
        end
        _arjConns = {}
        _arjBoundRemotes = {}
        if _arjAddConn then
            pcall(function() _arjAddConn:Disconnect() end)
            _arjAddConn = nil
        end
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            _arjBindRemote(obj)
        end
        _arjAddConn = ReplicatedStorage.DescendantAdded:Connect(function(obj)
            if AutoResetJailEnabled then _arjBindRemote(obj) end
        end)
    end
    local function stopAutoResetJail()
        AutoResetJailEnabled = false
        for _, conn in ipairs(_arjConns) do
            pcall(function() conn:Disconnect() end)
        end
        _arjConns = {}
        _arjBoundRemotes = {}
        if _arjAddConn then
            pcall(function() _arjAddConn:Disconnect() end)
            _arjAddConn = nil
        end
    end
    ToggleHandlers.auto_reset_jail = function(state)
        AutoResetJailEnabled = state
        if state then
            startAutoResetJail()
        else
            stopAutoResetJail()
        end
    end
end
do
    local autoTurretEnabled  = false
    local turretConns        = {}
    local turretLoopRunning  = false
    local turretAttackBusy   = setmetatable({}, { __mode = "k" })
    local turretAttackQueued = setmetatable({}, { __mode = "k" })
    local turretAttackCD     = setmetatable({}, { __mode = "k" })
    local turretAttackActive = false
    local RETRY_DELAY        = 0.3
    local lp = Players.LocalPlayer

    local function isEnemyTurret(obj)
        if not obj or not obj:IsA("BasePart") then return false end
        local ownerId = obj.Name:match("^Sentry_(%d+)$")
        return ownerId ~= nil and ownerId ~= tostring(lp.UserId)
    end

    local function setTurretNoClip(turret)
        if not isEnemyTurret(turret) then return end
        pcall(function() turret.CanCollide = false end)
    end

    local function getTurretTimeLabel(turret)
        if not turret or not turret.Parent then return nil end
        local sf  = turret:FindFirstChild("SetupFrame")
        local mf  = sf and sf:FindFirstChild("MainFrame")
        local lbl = mf and mf:FindFirstChild("Time")
        if lbl and lbl:IsA("TextLabel") then return lbl end
        return nil
    end

    local function shouldAttackTurret(turret)
        if lp:GetAttribute("Stealing") ~= nil then return false end
        if not isEnemyTurret(turret) then return false end
        setTurretNoClip(turret)
        local lbl = getTurretTimeLabel(turret)
        if not lbl then return false end
        local ok, text = pcall(function() return lbl.Text end)
        if not ok then return false end
        text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        return text ~= "" and string.find(text, "^%d+s!$") ~= nil
    end

    local function bringTurretInFront(turret, hrp)
        if not turret or not hrp then return end
        local fwd = hrp.CFrame.LookVector
        local pos = hrp.Position + fwd * 4 + Vector3.new(0, 1.2, 0)
        local cf  = CFrame.lookAt(pos, pos + fwd)
        pcall(function()
            turret.Velocity     = Vector3.zero
            turret.RotVelocity  = Vector3.zero
        end)
        pcall(function() turret.CFrame = cf end)
    end

    local function attackTurret(turret)
        local now = os.clock()
        if turretAttackBusy[turret] or turretAttackQueued[turret]
        or turretAttackActive or not shouldAttackTurret(turret) then return end
        if (turretAttackCD[turret] or 0) > now then return end
        turretAttackQueued[turret] = true
        turretAttackCD[turret]     = now + RETRY_DELAY
        task.spawn(function()
            turretAttackQueued[turret] = nil
            if turretAttackActive or turretAttackBusy[turret]
            or not shouldAttackTurret(turret) then return end
            turretAttackActive       = true
            turretAttackBusy[turret] = true
            pcall(function()
                local attempts = 0
                while attempts < 12 and autoTurretEnabled do
                    if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
                    local char = lp.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum or hum.Health <= 0 then break end
                    local okD, dist = pcall(function() return (turret.Position - hrp.Position).Magnitude end)
                    if okD and dist > 220 then break end
                    setTurretNoClip(turret)
                    bringTurretInFront(turret, hrp)
                    if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
                    local bp  = lp:FindFirstChild("Backpack")
                    local bat = char:FindFirstChild("Bat") or (bp and bp:FindFirstChild("Bat"))
                    if bat and bat.Parent ~= char then
                        pcall(function() hum:EquipTool(bat) end)
                    end
                    bat = char:FindFirstChild("Bat") or bat
                    if bat then pcall(function() bat:Activate() end) end
                    task.wait(0.03)
                    if turret and turret.Parent and shouldAttackTurret(turret) then
                        setTurretNoClip(turret)
                        bringTurretInFront(turret, hrp)
                    end
                    attempts = attempts + 1
                    task.wait(0.09)
                end
            end)
            turretAttackBusy[turret] = nil
            turretAttackActive       = false
        end)
    end

    local function disconnectAll()
        for _, c in ipairs(turretConns) do pcall(function() c:Disconnect() end) end
        turretConns = {}
    end

    local function startAutoTurret()
        disconnectAll()
        table.insert(turretConns, workspace.DescendantAdded:Connect(function(obj)
            if isEnemyTurret(obj) then setTurretNoClip(obj) end
            if autoTurretEnabled and shouldAttackTurret(obj) then
                task.defer(attackTurret, obj)
            end
        end))
        if not turretLoopRunning then
            turretLoopRunning = true
            task.spawn(function()
                while autoTurretEnabled do
                    task.wait(0.4)
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if isEnemyTurret(obj) then setTurretNoClip(obj) end
                        if autoTurretEnabled and shouldAttackTurret(obj) then attackTurret(obj) end
                    end
                end
                turretLoopRunning = false
            end)
        end
    end

    local function stopAutoTurret()
        disconnectAll()
    end

    ToggleHandlers.anti_turret = function(state)
        autoTurretEnabled = state
        if state then startAutoTurret() else stopAutoTurret() end
    end
end
do
    local AntiBeeDiscoData = {
        running = false,
        connections = {},
        originalMoveFunction = nil,
        controlsProtected = false,
        badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
    }

    local function abNuke(obj)
        if not obj or not obj.Parent then return end
        if AntiBeeDiscoData.badLightingNames[obj.Name] then
            pcall(function() obj:Destroy() end)
        end
    end

    local function abDisconnectAll()
        for _, conn in ipairs(AntiBeeDiscoData.connections) do
            if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        AntiBeeDiscoData.connections = {}
    end

    local function abProtectControls()
        if AntiBeeDiscoData.controlsProtected then return end
        pcall(function()
            local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
            if not PlayerModule then return end
            local Controls = require(PlayerModule):GetControls()
            if not Controls then return end
            if not AntiBeeDiscoData.originalMoveFunction then
                AntiBeeDiscoData.originalMoveFunction = Controls.moveFunction
            end
            local function protectedMove(self, moveVector, relativeToCamera)
                if AntiBeeDiscoData.originalMoveFunction then
                    AntiBeeDiscoData.originalMoveFunction(self, moveVector, relativeToCamera)
                end
            end
            local _abCtrlAcc = 0
            table.insert(AntiBeeDiscoData.connections, RunService.Heartbeat:Connect(function(dt)
                if not AntiBeeDiscoData.running then return end
                _abCtrlAcc = _abCtrlAcc + dt
                if _abCtrlAcc < 0.25 then return end
                _abCtrlAcc = 0
                if Controls.moveFunction ~= protectedMove then Controls.moveFunction = protectedMove end
            end))
            Controls.moveFunction = protectedMove
            AntiBeeDiscoData.controlsProtected = true
        end)
    end

    local function abRestoreControls()
        if not AntiBeeDiscoData.controlsProtected then return end
        pcall(function()
            local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
            if not PlayerModule then return end
            local Controls = require(PlayerModule):GetControls()
            if Controls and AntiBeeDiscoData.originalMoveFunction then
                Controls.moveFunction = AntiBeeDiscoData.originalMoveFunction
                AntiBeeDiscoData.controlsProtected = false
            end
        end)
    end

    local function abBlockBuzzing()
        pcall(function()
            local beeScript = LocalPlayer.PlayerScripts:FindFirstChild("Bee", true)
            if beeScript then
                local buzzing = beeScript:FindFirstChild("Buzzing")
                if buzzing and buzzing:IsA("Sound") then
                    buzzing:Stop()
                    buzzing.Volume = 0
                end
            end
        end)
    end

    local function lockFOV()
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = _G._FH_FOV_Value or 70 end
    end

    local function enableAntiBee()
        if AntiBeeDiscoData.running then return end
        AntiBeeDiscoData.running = true
        Config.AntiBeeDisco = true
        for _, inst in ipairs(Lighting:GetDescendants()) do abNuke(inst) end
        table.insert(AntiBeeDiscoData.connections, Lighting.DescendantAdded:Connect(function(obj)
            if AntiBeeDiscoData.running then abNuke(obj) end
        end))
        abProtectControls()
        local _abBuzzAcc = 0
        table.insert(AntiBeeDiscoData.connections, RunService.Heartbeat:Connect(function(dt)
            if not AntiBeeDiscoData.running then return end
            _abBuzzAcc = _abBuzzAcc + dt
            if _abBuzzAcc < 0.25 then return end
            _abBuzzAcc = 0
            abBlockBuzzing()
            lockFOV()
        end))
    end

    local function disableAntiBee()
        if not AntiBeeDiscoData.running then return end
        AntiBeeDiscoData.running = false
        Config.AntiBeeDisco = false
        abRestoreControls()
        abDisconnectAll()
    end

    ToggleHandlers.anti_bee = function(state)
        if state then enableAntiBee() else disableAntiBee() end
    end
end
local Aim = {
    remoteIndex      = {},
    remoteObjects    = {},
    currentCharacter = nil,
    lastShot         = 0,
    connections      = {},
    VALID_TOOLS      = {"Web Slinger", "Laser Cape"},
    TARGET_PARTS     = {"HumanoidRootPart", "UpperTorso", "Torso"},
    MAX_DISTANCE     = 500,
}
local WSK = {
    enabled      = false,
    loop         = nil,
    minimized    = false,
    dragging     = false,
    dragStart    = nil,
    panelStart   = nil,
    W = 200, H = 90,
    entry        = { keyCode = nil },
    kb2Debounce  = false,
}
local function wskGetNearest()
    local char = Players.LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character then
            local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local d = (tHRP.Position - hrp.Position).Magnitude
                if d < bestDist then bestDist = d; best = plr end
            end
        end
    end
    return best
end
local function wskStart()
    if WSK.loop then WSK.loop:Disconnect() end
    local target = wskGetNearest()
    if not target or not target.Character then return end
    local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end
    local above = true
    local _wskAcc = 0
    WSK.loop = RunService.Heartbeat:Connect(function(dt)
        if not WSK.enabled then WSK.loop:Disconnect(); WSK.loop = nil; return end
        _wskAcc = _wskAcc + dt
        if _wskAcc < 1/20 then return end
        _wskAcc = 0
        if tHRP and tHRP.Parent then
            tHRP.CFrame = tHRP.CFrame + Vector3.new(0, above and 20 or -20, 0)
            above = not above
        end
    end)
end
local function wskStop()
    if WSK.loop then WSK.loop:Disconnect(); WSK.loop = nil end
end
Aim.aimShootWithWSK = function()
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local ws = char:FindFirstChild("Web Slinger")
        or (Players.LocalPlayer:FindFirstChild("Backpack") and Players.LocalPlayer.Backpack:FindFirstChild("Web Slinger"))
    if not ws then return end
    if ws.Parent ~= char then
        hum:EquipTool(ws)
        task.wait(0.05)
    end
    local tool = char:FindFirstChild("Web Slinger")
    if not tool then return end
    Aim.currentCharacter = char
    Aim.aimShoot()
    task.delay(0.08, function()
        if WSK.enabled then wskStart() end
    end)
end

Aim.REMOTE_KEYS = {
    "UseItem",
    "RE/UseItem",
    "Tools/Cooldown",
}
Aim.aimInitRemotes = function()
    Aim.remoteMap     = {}
    Aim.remoteIndex   = {}
    Aim.remoteObjects = {}
    local resolver = _G._FH_GetRemote
    if not resolver then return end
    for _, key in ipairs(Aim.REMOTE_KEYS) do
        local r = resolver(key)
        if r then
            Aim.remoteMap[key]     = r
            Aim.remoteIndex[key]   = r
            Aim.remoteObjects[r]   = r
        end
    end
end
Aim.aimFireRemote = function(name, ...)
    local r = (Aim.remoteMap and Aim.remoteMap[name])
        or (_G._FH_GetRemote and _G._FH_GetRemote(name))
    if not r then return false end
    if Aim.remoteMap then Aim.remoteMap[name] = r end
    local ok = pcall(function(...) r:FireServer(...) end, ...)
    return ok
end
Aim.aimGetTool = function()
    if not Aim.currentCharacter then return nil end
    return Aim.currentCharacter:FindFirstChildOfClass("Tool")
end
Aim.aimHasValidTool = function()
    local tool = Aim.aimGetTool()
    if not tool then return false end
    for _, name in pairs(Aim.VALID_TOOLS) do
        if tool.Name == name then return true end
    end
    return false
end
Aim.aimGetNearestPlayer = function()
    if not Aim.currentCharacter then return nil end
    local hrp = Aim.currentCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, shortest = nil, Aim.MAX_DISTANCE
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player then
            local char = player.Character
            if char then
                local targetHRP = char:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local dist = (targetHRP.Position - hrp.Position).Magnitude
                    if dist < shortest then shortest = dist; closest = player end
                end
            end
        end
    end
    return closest
end
Aim.aimGetBestPart = function(character)
    for _, partName in ipairs(Aim.TARGET_PARTS) do
        local part = character:FindFirstChild(partName)
        if part then return part end
    end
    return nil
end
Aim.aimShoot = function()
    if not Aim.aimHasValidTool() then return end
    local targetPlayer = Aim.aimGetNearestPlayer()
    if not targetPlayer then return end
    local char = targetPlayer.Character
    if not char then return end
    local part = Aim.aimGetBestPart(char)
    if not part then return end
    local targetPos = part.Position + Vector3.new(0, 0.5, 0)
    if _FH_UseItemRemote then
        pcall(function() _FH_UseItemRemote:FireServer(targetPos, part) end)
    else
        Aim.aimFireRemote("RE/UseItem", targetPos, part)
    end
end
Aim.aimTryShoot = function()
    local now = tick()
    if now - Aim.lastShot < 0.07 then return end
    Aim.lastShot = now
    if WSK.enabled then
        Aim.aimShootWithWSK()
    else
        Aim.aimShoot()
    end
end
Aim.aimHookTool = function(tool)
    if not tool then return end
    local conn = tool.Activated:Connect(function() Aim.aimTryShoot() end)
    table.insert(Aim.connections, conn)
end
Aim.aimSetupCharacter = function(char)
    Aim.currentCharacter = char
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then Aim.aimHookTool(tool) end
    local conn = char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then Aim.aimHookTool(child) end
    end)
    table.insert(Aim.connections, conn)
end
Aim.startAimbot = function()
    Aim.aimInitRemotes()
    local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            Aim.aimTryShoot()
        end
    end)
    table.insert(Aim.connections, inputConn)
    if Player.Character then Aim.aimSetupCharacter(Player.Character) end
    local charConn = Player.CharacterAdded:Connect(function(char)
        Aim.aimSetupCharacter(char)
    end)
    table.insert(Aim.connections, charConn)
end
Aim.stopAimbot = function()
    for _, conn in ipairs(Aim.connections) do
        pcall(function() conn:Disconnect() end)
    end
    Aim.connections      = {}
    Aim.currentCharacter = nil
end
local InternalStealCache = {}
local autoBlock = false
local function blockClosest() end
local function buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = {
        holdCallbacks = {},
        triggerCallbacks = {},
        ready = true,
    }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table"then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function"then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table"then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function"then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        InternalStealCache[prompt] = data
    end
end
local function executeInternalStealAsync(prompt)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    task.spawn(function()
        local origDist = prompt.MaxActivationDistance
        local deadline = tick() + 5
        while prompt and prompt.Parent and V3.enabled and tick() < deadline do
            prompt.MaxActivationDistance = 9e9
            if autoBlock then
                blockClosest()
            end
            local ok = pcall(_FH_FireStealPrompt, prompt)
            if ok then break end
            task.wait(0.1)
        end
        if prompt and prompt.Parent then
            prompt.MaxActivationDistance = origDist
        end
        data.ready = true
    end)
    return true
end
local function attemptSteal(prompt)
    if not prompt or not prompt.Parent then
        return false
    end
    buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then
        InternalStealCache[prompt] = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    end
    return executeInternalStealAsync(prompt)
end
function v3p_buildStealCallbacks(prompt)
    if InternalStealCache[prompt] then return end
    local data = {
        holdCallbacks    = {},
        triggerCallbacks = {},
        ready            = true,
    }
    local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(conns1) == "table"then
        for _, conn in ipairs(conns1) do
            if type(conn.Function) == "function"then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, conns2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(conns2) == "table"then
        for _, conn in ipairs(conns2) do
            if type(conn.Function) == "function"then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        InternalStealCache[prompt] = data
    end
end
function v3p_runCallbackList(list)
    for _, fn in ipairs(list) do
        task.spawn(fn)
    end
end
v3p_POTION_NAMES = {"Giant Potion", "Giant", "Grow Potion", "Super Grow", "Potion"}
local function _isCurrentlyGiant()
    if _isGiant then return true end
    local c = Players.LocalPlayer and Players.LocalPlayer.Character
    if not c then return false end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local scale = hum:FindFirstChild("BodyHeightScale")
        or hum:FindFirstChild("BodyDepthScale")
        or hum:FindFirstChild("BodyWidthScale")
    if scale and scale:IsA("NumberValue") and scale.Value >= GIANT_THRESHOLD then
        return true
    end
    return false
end

local function _activateGiantPotion()
    if _isCurrentlyGiant() then return end
    local lp   = Players.LocalPlayer
    local char = lp and lp.Character
    local bp   = lp and lp:FindFirstChild("Backpack")
    if not char or not bp then return end
    local potion = bp:FindFirstChild("Giant Potion")
    if not potion then return end
    pcall(function()
        potion.Parent = char
        potion:Activate()
        potion.Parent = bp
    end)
end
function v3p_activatePotionAt95()
    if not V3.potionOn then return end
    if _isCurrentlyGiant() then return end
    _activateGiantPotion()
    if giantSpeedEnabled then
        local lp  = Players.LocalPlayer
        local c   = lp and lp.Character
        local bp  = lp and lp:FindFirstChild("Backpack")
        if c and bp then
            local hum  = c:FindFirstChildWhichIsA("Humanoid")
            local tool = c:FindFirstChild("Flying Carpet") or bp:FindFirstChild("Flying Carpet")
            if hum and tool then hum:EquipTool(tool) end
        end
    end
end
function v3p_attemptStealWithPotion(prompt)
    if not prompt or not prompt.Parent then return false end
    if not InternalStealCache[prompt] then
        local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1) == "table"then
            for _, conn in ipairs(conns1) do
                if type(conn.Function) == "function"then
                    table.insert(data.holdCallbacks, conn.Function)
                end
            end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2) == "table"then
            for _, conn in ipairs(conns2) do
                if type(conn.Function) == "function"then
                    table.insert(data.triggerCallbacks, conn.Function)
                end
            end
        end
        if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
            InternalStealCache[prompt] = data
        end
    end
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    task.spawn(function()
        if #data.holdCallbacks > 0 then
            for _, fn in ipairs(data.holdCallbacks) do
                task.spawn(fn)
            end
        end
        task.wait(1.425)
        if V3.potionOn then
            v3p_activatePotionAt95()
        end
        task.wait(0.075)
        if #data.triggerCallbacks > 0 then
            for _, fn in ipairs(data.triggerCallbacks) do
                task.spawn(fn)
            end
        end
        task.wait()
        data.ready = true
    end)
    return true
end
function v3p_activatePotion(_tool)
    _activateGiantPotion()
end
function v3p_equipPotion()
    return Players.LocalPlayer.Backpack:FindFirstChild("Giant Potion")
end
v3p_stealAttrCooldown = false
function v3p_executeInternalStealAsync(prompt)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    task.spawn(function()
        if V3.potionOn then
            local equippedPotion = v3p_equipPotion()
            if equippedPotion then
                v3p_activatePotion(equippedPotion)
                task.wait(0.15)
            end
        end
        if #data.holdCallbacks > 0 then
            v3p_runCallbackList(data.holdCallbacks)
        end
        task.wait(1.5)
        if #data.triggerCallbacks > 0 then
            if autoBlock then blockClosest() end
            v3p_runCallbackList(data.triggerCallbacks)
        end
        task.wait()
        data.ready = true
    end)
    return true
end
function v3p_attemptSteal(prompt)
    if not prompt or not prompt.Parent then return false end
    v3p_buildStealCallbacks(prompt)
    if not InternalStealCache[prompt] then return false end
    return v3p_executeInternalStealAsync(prompt)
end
V3.v3FindBestPrompt = function()
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local best, bestDist, bestPlot = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if not (sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled) then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, podium in ipairs(podiums:GetChildren()) do
                    local base   = podium:FindFirstChild("Base")
                    local spawn  = base and base:FindFirstChild("Spawn")
                    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
                    if attach then
                        local pObj = attach:FindFirstChildOfClass("ProximityPrompt")
                        if pObj and pObj.Enabled and
                            (pObj.ActionText:find("Steal") or pObj.ObjectText:find("Steal")) then
                            local d = (hrp.Position - spawn.Position).Magnitude
                            if d < bestDist then bestDist = d; best = pObj; bestPlot = plot end
                        end
                    end
                end
            end
        end
    end
    return best, bestDist, bestPlot
end
_v3PotionHoldWatched = {}
function _v3PotionWatchPrompt(pObj)
    if _v3PotionHoldWatched[pObj] then return end
    _v3PotionHoldWatched[pObj] = true
    local fired = false
    pObj.Triggered:Connect(function()
        if V3.enabled then return end
        if not V3.potionOn then return end
        local _agn = configRegistry and configRegistry["Auto Grab Nearest"]
        local _agb = configRegistry and configRegistry["Auto Grab Best"]
        if (_agn and _agn.getState and _agn.getState()) or (_agb and _agb.getState and _agb.getState()) then return end

        if not _FH_IsPromptOnEnemyPlot(pObj) then return end
        if not _FH_IsPlayerInEnemyPlot() then return end
        if fired then return end
        fired = true
        _activateGiantPotion()
        task.delay(0.5, function() fired = false end)
    end)
end
task.defer(function()
    task.wait(2)
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, desc in pairs(plots:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.ActionText == "Steal"then
                _v3PotionWatchPrompt(desc)
            end
        end
        plots.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") and desc.ActionText == "Steal" then
                _v3PotionWatchPrompt(desc)
            end
        end)
    end
end)
do
    local ProximityPromptService = game:GetService("ProximityPromptService")
    local _pogHoldFired = {}
    local function _pogAutoGrabActive()
        local _agn = configRegistry and configRegistry["Auto Grab Nearest"]
        local _agb = configRegistry and configRegistry["Auto Grab Best"]
        return (_agn and _agn.getState and _agn.getState()) or (_agb and _agb.getState and _agb.getState())
    end
    ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player ~= LocalPlayer then return end
        if prompt.ActionText ~= "Steal"and (not prompt.ObjectText or not prompt.ObjectText:find("Steal")) then return end
        if not V3.potionOn then return end
        if V3.enabled or SVN.autoGrabEnabled then return end
        if _pogAutoGrabActive() then return end

        if not _FH_IsPromptOnEnemyPlot(prompt) then return end
        if not _FH_IsPlayerInEnemyPlot() then return end
        local _pogStart    = tick()
        local _pogHoldDur  = (prompt.HoldDuration and prompt.HoldDuration > 0) and prompt.HoldDuration or 1
        local _pogLeadTime = 0.125
        local _pogFireThreshold = math.max(_pogHoldDur - _pogLeadTime, 0)
        local _pogProgThreshold = (_pogHoldDur > 0) and math.max((_pogHoldDur - _pogLeadTime) / _pogHoldDur, 0) or 0.95
        local conn
        local function _pogFire()
            if _pogHoldFired[prompt] then return end
            _pogHoldFired[prompt] = true
            pcall(_activateGiantPotion)
            if SP and SP.spBoosterDoToggle and SP.state ~= true then
                pcall(SP.spBoosterDoToggle)
            end
            if conn then conn:Disconnect() end
        end
        task.delay(_pogFireThreshold, function()
            if not V3.potionOn or V3.enabled or SVN.autoGrabEnabled or _pogAutoGrabActive() then return end
            if not prompt or not prompt.Parent then return end
            _pogFire()
        end)
        conn = prompt.PromptButtonHoldProgress:Connect(function(progress)
            if not V3.potionOn or V3.enabled or SVN.autoGrabEnabled or _pogAutoGrabActive() then
                conn:Disconnect()
                return
            end
            if progress >= _pogProgThreshold and not _pogHoldFired[prompt] then
                _pogFire()
            end
        end)
    end)
    ProximityPromptService.PromptButtonHoldEnded:Connect(function(prompt, player)
        if player ~= LocalPlayer then return end
        _pogHoldFired[prompt] = nil
    end)
    ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
        if player ~= LocalPlayer then return end
        _pogHoldFired[prompt] = nil
    end)
end
do
    local _v3PBar = nil
    local _v3PBarActive = false
    local function _v3EnsureBar()
        if _v3PBar then return end
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local gui = Instance.new("ScreenGui")
        gui.Name              = "V3StealProgressBar"
gui.ResetOnSpawn      = false
        gui.DisplayOrder      = 1000
        gui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
        gui.IgnoreGuiInset    = true
        gui.Parent            = pg
        local bg = Instance.new("Frame")
        bg.Name               = "BG"
        bg.Size               = UDim2.new(0.36, 0, 0, 10)
        bg.Position           = UDim2.new(0.32, 0, 0, 0)
        bg.AnchorPoint        = Vector2.new(0, 0)
        bg.BackgroundColor3   = Color3.fromRGB(10, 10, 10)
        bg.BackgroundTransparency = 0
        bg.BorderSizePixel    = 0
        bg.ZIndex             = 2
        bg.Visible            = false
        bg.Parent             = gui
        local fill = Instance.new("Frame")
        fill.Name             = "Fill"
fill.Size             = UDim2.new(0, 0, 1, 0)
        fill.Position         = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = (_G._FH_AccentA or Color3.fromRGB(60, 210, 100))
        fill.BorderSizePixel  = 0
        fill.ZIndex           = 3
        fill.Parent           = bg
        local _fillGrad = Instance.new("UIGradient")
        _fillGrad.Color = _FH_BuildThemeSequence and _FH_BuildThemeSequence() or ColorSequence.new(Color3.fromRGB(120,200,255))
        _fillGrad.Parent = fill
        table.insert(_G._FH_ThemeFills, _fillGrad)
        local lbl = Instance.new("TextLabel")
        lbl.Name              = "Lbl"
lbl.Size              = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text              = "V3 Stealing..."
lbl.TextSize          = 11
        lbl.Font              = Enum.Font.GothamBold
        lbl.TextColor3        = Color3.fromRGB(255, 255, 255)
        lbl.ZIndex            = 4
        lbl.Parent            = bg
        _v3PBar = { gui = gui, bg = bg, fill = fill, lbl = lbl }
    end
    local _v3BarTween = nil
    function _v3ShowStealProgress(victimName)
        _v3EnsureBar()
        if not _v3PBar then return end
        if _v3PBarActive then return end
        _v3PBarActive = true
        local bar = _v3PBar
        bar.fill.BackgroundColor3 = (_G._FH_AccentA or Color3.fromRGB(60, 210, 100))
        bar.fill.BackgroundTransparency = 0
        bar.bg.BackgroundTransparency   = 0
        bar.lbl.TextTransparency        = 0
        bar.lbl.Text = victimName and ("Stealing from ".. victimName .. "...") or "V3 Stealing..."
bar.fill.Size = UDim2.new(0, 0, 1, 0)
        bar.bg.Visible = true
        if _v3BarTween then pcall(function() _v3BarTween:Cancel() end) end
        _v3BarTween = TweenService:Create(bar.fill, TweenInfo.new(0.22, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
        _v3BarTween:Play()
        task.delay(0.22, function()
            if not bar.bg.Visible then return end
            bar.lbl.Text = "Stolen!"
bar.fill.BackgroundColor3 = Color3.fromRGB(40, 180, 70)
        end)
        task.delay(0.85, function()
            TweenService:Create(bar.bg,   TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            TweenService:Create(bar.fill, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()

            pcall(function()
                local g = bar.fill:FindFirstChildOfClass("UIGradient")
                if g and _FH_BuildThemeSequence then g.Color = _FH_BuildThemeSequence() end
            end)
            TweenService:Create(bar.lbl,  TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            task.delay(0.3, function()
                bar.bg.Visible = false
                bar.fill.Size  = UDim2.new(0, 0, 1, 0)
                bar.fill.BackgroundColor3 = Color3.fromRGB(60, 210, 100)
                _v3PBarActive = false
            end)
        end)
    end
end
local _ragdollCommandCache = {}
local _ragdollProfileCache = {}
local function _ragdollCacheActivated(guiObject)
    local cached = {}
    local ok, conns = pcall(getconnections, guiObject.Activated)
    if ok and type(conns) == "table"then
        for _, conn in ipairs(conns) do
            if type(conn.Function) == "function"then
                table.insert(cached, conn.Function)
            end
        end
    end
    return cached
end
local function _ragdollFireActivated(cached)
    for _, fn in ipairs(cached) do task.spawn(fn) end
end
local function _ragdollGetAdminFrames()
    local ap = Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
    if not ap then return nil, nil end
    local panel = ap:FindFirstChild("AdminPanel")
    if not panel then return nil, nil end
    local content  = panel:FindFirstChild("Content")
    local profiles = panel:FindFirstChild("Profiles")
    if not content or not profiles then return nil, nil end
    return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end

function _FH_IsPlayerInEnemyPlot()
    local char = Players.LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false, nil end
    for _, plot in ipairs(plots:GetChildren()) do
        if not _FH_AG_IsMyPlot(plot) then
            local hitbox = plot:FindFirstChild("StealHitbox", true)
            if hitbox then
                local rel = hitbox.CFrame:PointToObjectSpace(hrp.Position)
                if math.abs(rel.X) <= hitbox.Size.X * 0.5
                    and math.abs(rel.Z) <= hitbox.Size.Z * 0.5 then
                    return true, plot
                end
            end
        end
    end
    return false, nil
end

function _FH_IsPromptOnEnemyPlot(prompt)
    if not prompt then return false end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    for _, plot in ipairs(plots:GetChildren()) do
        if prompt:IsDescendantOf(plot) then
            return not _FH_AG_IsMyPlot(plot)
        end
    end
    return false
end
local _v3Tick = 0
_v3PotionPreFired = {}
RunService.Heartbeat:Connect(function()
    if not V3.enabled then return end

    if not _FH_IsPlayerInEnemyPlot() then return end
    local now = tick()
    if now - _v3Tick < 0.05 then return end
    _v3Tick = now
    local prompt, dist, bestPlot = V3.v3FindBestPrompt()
    if not prompt then return end
    local function isInsidePlotHitbox()
        if not bestPlot then return false end
        local hitbox = bestPlot:FindFirstChild("StealHitbox", true)
        if not hitbox then return false end
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local cf   = hitbox.CFrame
        local size = hitbox.Size
        local rel  = cf:PointToObjectSpace(hrp.Position)
        return math.abs(rel.X) <= size.X * 0.5 and math.abs(rel.Z) <= size.Z * 0.5
    end
    if V3.potionOn then
        local thresholdPotion = prompt.MaxActivationDistance * 0.15
        if dist <= thresholdPotion and not _v3PotionPreFired[prompt] then
            if isInsidePlotHitbox() then
                _v3PotionPreFired[prompt] = true
                task.spawn(function()
                    _activateGiantPotion()
                end)
            end
        elseif dist > thresholdPotion then
            _v3PotionPreFired[prompt] = nil
        end
    end
    if dist > prompt.MaxActivationDistance + 1 then return end
    if not isInsidePlotHitbox() then return end
    _silCtx.stealStart = tick()
    _silCtx.giantUsed  = V3.potionOn
    _silCtx.halfTP     = false
    _silCtx.victim     = _sil_getVictimFromPrompt(prompt)
    if V3.potionOn then
        local ok = v3p_attemptStealWithPotion(prompt)
        if ok ~= false then
            task.spawn(function() _v3ShowStealProgress(_silCtx.victim) end)
        end
    else
        local ok = attemptSteal(prompt)
        if ok then
            task.spawn(function() _v3ShowStealProgress(_silCtx.victim) end)
        end
    end
end)
local V3P_STEAL_ATTRS = {
    "steal", "Steal", "STEAL",
    "stolen", "Stolen", "STOLEN",
    "stole", "Stole", "STOLE",
    "stealing", "Stealing", "STEALING",
    "grabbing", "Grabbing",
    "isSteal", "IsSteal",
}
function v3p_onStealAttr(attrName)
    if not V3.enabled then return end
    if not V3.potionOn then return end
    if v3p_stealAttrCooldown then return end
    local val = Player:GetAttribute(attrName)
    if val == nil or val == false or val == 0 or val == ""
    then return end
    v3p_stealAttrCooldown = true
    task.spawn(function()
        local prompt, dist = V3.v3FindBestPrompt()
        if prompt and dist <= prompt.MaxActivationDistance + 1 then
            v3p_attemptSteal(prompt)
        end
        task.wait(0.6)
        v3p_stealAttrCooldown = false
    end)
end
for _, attrName in ipairs(V3P_STEAL_ATTRS) do
    Player:GetAttributeChangedSignal(attrName):Connect(function()
        v3p_onStealAttr(attrName)
    end)
end
Player.CharacterAdded:Connect(function()
    V3.potionEquipped = false
    V3.giant          = nil
    v3p_stealAttrCooldown = false
end)
local AnimRemove = { connections = {}, animators = {} }
AnimRemove.isLocalCharacter = function(model)
    return Players.LocalPlayer.Character == model
end
AnimRemove.isMiniFollower = function(model)
    while model do
        if model:IsA("Model") and typeof(model.Name) == "string" and model.Name:sub(1, 4) == "MBF_" then
            return true
        end
        model = model.Parent
    end
    return false
end
AnimRemove.handleAnimator = function(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and AnimRemove.isLocalCharacter(model) then return end
    if model and Players:GetPlayerFromCharacter(model) then return end
    if AnimRemove.isMiniFollower(animator) then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop(0)
    end
    local conn = animator.AnimationPlayed:Connect(function(track)
        track:Stop(0)
    end)
    table.insert(AnimRemove.connections, conn)
    table.insert(AnimRemove.animators, animator)
end
AnimRemove.enable = function()

    local _step = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Animator") then AnimRemove.handleAnimator(obj) end
        _step = _step + 1
        if _step % 500 == 0 then task.wait() end
    end
    AnimRemove.connections.desc = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Animator") then AnimRemove.handleAnimator(obj) end
    end)
end
AnimRemove.disable = function()
    for _, conn in pairs(AnimRemove.connections) do
        if conn then conn:Disconnect() end
    end
    AnimRemove.connections = {}
    for _, animator in ipairs(AnimRemove.animators) do
        if animator and animator.Parent then
            animator.Enabled = false
            task.defer(function()
                if animator and animator.Parent then
                    animator.Enabled = true
                end
            end)
        end
    end
    AnimRemove.animators = {}
end
FPS.stripVisuals = function(obj)
    if obj.Name:sub(1, 3) == "FH_" then return end
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture")
        or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj:Destroy()
    end
end
FPS.applyLowQuality = function(_) end
FPS.destroyAllAccessories = function()
    local localChar = Players.LocalPlayer.Character

    local _step = 0
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Accessory") or d:IsA("MeshPartAccessory") then
            if localChar and d:IsDescendantOf(localChar) then continue end
            pcall(function() d:Destroy() end)
        end
        _step = _step + 1
        if _step % 500 == 0 then task.wait() end
    end
end
FPS.enable = function()
    Lighting.GlobalShadows             = false
    Lighting.FogEnd                    = 1e6
    Lighting.FogStart                  = 0
    Lighting.Brightness                = 1
    Lighting.EnvironmentDiffuseScale   = 0
    Lighting.EnvironmentSpecularScale  = 0
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect")
            or v:IsA("SunRaysEffect") or v:IsA("PostEffect")
            or v:IsA("Atmosphere") then
            v:Destroy()
        end
    end
    FPS.destroyAllAccessories()
    for _, obj in ipairs(workspace:GetDescendants()) do
        FPS.stripVisuals(obj)
        FPS.applyLowQuality(obj)
    end
    FPS.connections.descendant = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Accessory") or obj:IsA("MeshPartAccessory") then
            pcall(function() obj:Destroy() end)
            return
        end
        FPS.stripVisuals(obj)
        FPS.applyLowQuality(obj)
    end)
    local function removeMeshes(tool)
        if not tool:IsA("Tool") then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        for _, d in ipairs(handle:GetDescendants()) do
            if d:IsA("Mesh") or d:IsA("SpecialMesh") then d:Destroy() end
        end
    end
    local function onFPSCharacter(char)
        char.ChildAdded:Connect(removeMeshes)
        for _, child in ipairs(char:GetChildren()) do removeMeshes(child) end
    end
    FPS.connections.player = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(onFPSCharacter)
    end)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then onFPSCharacter(plr.Character) end
    end
    FPS.connections.localChar = Players.LocalPlayer.CharacterAdded:Connect(function(char)
        if not _G._FH_AlwaysOnFPS then return end
        task.wait(0.2)
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e9
            Lighting.Brightness = 1
        end)
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("BlurEffect") or e:IsA("BloomEffect")
            or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("ColorCorrectionEffect") then
                pcall(function() e.Enabled = false end)
            end
        end
        for _, d in ipairs(char:GetDescendants()) do
            FPS.stripVisuals(d)
        end
        removeMeshes(char)
        for _, child in ipairs(char:GetChildren()) do removeMeshes(child) end
    end)
end
FPS.disable = function()
    for _, conn in pairs(FPS.connections) do
        if conn then conn:Disconnect() end
    end
    FPS.connections = {}
end

do
    if _G._FH_AlwaysOnFPS and not _G._FH_AlwaysOnFPS_Applied then
        _G._FH_AlwaysOnFPS_Applied = true
        task.spawn(function()
            pcall(function()
