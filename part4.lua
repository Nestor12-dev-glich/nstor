        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            QS.dragging = false
            Config.mini = Config.mini or {}
            Config.mini.qs_pos = {
                x  = QS.QSWin.Position.X.Offset, y  = QS.QSWin.Position.Y.Offset,
                xs = QS.QSWin.Position.X.Scale,  ys = QS.QSWin.Position.Y.Scale,
            }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if QS.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                         or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - QS.dragStart
            local newPos = UDim2.new(
                QS.panelStart.X.Scale, QS.panelStart.X.Offset + d.X,
                QS.panelStart.Y.Scale, QS.panelStart.Y.Offset + d.Y
            )
            QS.QSWin.Position         = newPos
            QS.QSBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
        end
    end)

    QS.QSMinBtn.MouseButton1Click:Connect(function()
        QS.minimized = not QS.minimized
        if QS.minimized then
            QS.QSWin.ClipsDescendants = false
            QS.QSHdrFill.Visible      = false
            QS.QSHdrLine.Visible      = false
            QS.QSContent.Visible      = false
            Tween(QS.QSWin,         M, { Size = UDim2.new(0, QS.W, 0, 30) })
            Tween(QS.QSBorderFrame, M, { Size = UDim2.new(0, QS.W + 4, 0, 34) })
            QS.QSMinBtn.Text = "+"
        else
            QS.QSHdrFill.Visible = true
            QS.QSHdrLine.Visible = true
            Tween(QS.QSWin,         M, { Size = UDim2.new(0, QS.W, 0, QS.H) })
            Tween(QS.QSBorderFrame, M, { Size = UDim2.new(0, QS.W + 4, 0, QS.H + 4) })
            QS.QSMinBtn.Text = "\226\136\146"
            task.delay(M.Time, function()
                QS.QSContent.Visible      = true
                QS.QSWin.ClipsDescendants = true
            end)
        end
        if isMobile then
            Config.mini = Config.mini or {}
            Config.mini.qs_min = QS.minimized
            pcall(FH_SaveConfig)
        end
    end)

    function QS.setQuickStealVisible(vis)
        QS.QSWin.Visible         = vis
        QS.QSBorderFrame.Visible = vis
        if vis then
            local p = QS.QSWin.Position
            QS.QSBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
            if QS.minimized then
                QS.QSMinBtn.Text          = "+"
                QS.QSContent.Visible      = false
                QS.QSHdrFill.Visible      = false
                QS.QSHdrLine.Visible      = false
                QS.QSWin.ClipsDescendants = false
                QS.QSWin.Size             = UDim2.new(0, QS.W, 0, 30)
                QS.QSBorderFrame.Size     = UDim2.new(0, QS.W + 4, 0, 34)
            else
                QS.QSMinBtn.Text          = "\226\136\146"
                QS.QSContent.Visible      = true
                QS.QSHdrFill.Visible      = true
                QS.QSHdrLine.Visible      = true
                QS.QSWin.ClipsDescendants = true
                QS.QSWin.Size             = UDim2.new(0, QS.W, 0, QS.H)
                QS.QSBorderFrame.Size     = UDim2.new(0, QS.W + 4, 0, QS.H + 4)
                task.defer(QS.refresh)
            end
        end
    end

    task.spawn(function()
        while _G.FadedHubAlive do
            task.wait(5)
            if QS.QSWin and QS.QSWin.Visible and not QS.minimized then
                pcall(QS.refresh)
            end
        end
    end)
end
_FH_InitQSPanel(); task.wait()

_G._FH_PRIORITY_STEAL = _G._FH_PRIORITY_STEAL or {}
do
    Config.priority_steal = Config.priority_steal or {}
    for name, on in pairs(Config.priority_steal) do
        if on then _G._FH_PRIORITY_STEAL[name] = true end
    end
end
local function _FH_InitPSPanel()
    PS.W = isMobile and 180 or 230
    PS.H = isMobile and 240 or 280
    PS.Border = Instance.new("Frame")
    PS.Border.Name                   = "PriorityStealGradBorder"
    PS.Border.Size                   = UDim2.new(0, PS.W + 4, 0, PS.H + 4)
    PS.Border.Position               = UDim2.new(0.5, -(PS.W + 4)/2, 0, 150)
    PS.Border.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    PS.Border.BackgroundTransparency = 1
    PS.Border.BorderSizePixel        = 0
    PS.Border.ZIndex                 = 18
    PS.Border.Visible                = false
    PS.Border.Parent                 = GUI
    Corner(PS.Border, 12)
    pcall(_FH_AddThemeStrokeToFrame, PS.Border, 1.5)

    PS.Win = Instance.new("Frame")
    PS.Win.Name                   = "PriorityStealPanel"
    PS.Win.Size                   = UDim2.new(0, PS.W, 0, PS.H)
    PS.Win.Position               = UDim2.new(0.5, -PS.W/2, 0, 152)
    PS.Win.BackgroundColor3       = T.BG
    PS.Win.BackgroundTransparency = 0.25
    PS.Win.BorderSizePixel        = 0
    PS.Win.ZIndex                 = 19
    PS.Win.Visible                = false
    PS.Win.ClipsDescendants       = true
    PS.Win.Parent                 = GUI
    Corner(PS.Win, 10)

    PS.Win:GetPropertyChangedSignal("Position"):Connect(function()
        if PS.Border then
            local p = PS.Win.Position
            PS.Border.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        end
    end)

    if Config.mini and Config.mini.ps_pos then
        local p = Config.mini.ps_pos
        PS.Win.Position = UDim2.new(p.xs or 0.5, p.x or -PS.W/2, p.ys or 0, p.y or 152)
    end

    PS.Hdr = Instance.new("Frame")
    PS.Hdr.Size             = UDim2.new(1, 0, 0, 32)
    PS.Hdr.BackgroundColor3 = T.Header
    PS.Hdr.BorderSizePixel  = 0
    PS.Hdr.ZIndex           = 20
    PS.Hdr.Active           = true
    PS.Hdr.Parent           = PS.Win
    Corner(PS.Hdr, 10)
    local hdrFill = Instance.new("Frame")
    hdrFill.Size             = UDim2.new(1, 0, 0, 10)
    hdrFill.Position         = UDim2.new(0, 0, 1, -10)
    hdrFill.BackgroundColor3 = T.Header
    hdrFill.BorderSizePixel  = 0
    hdrFill.ZIndex           = 20
    hdrFill.Parent           = PS.Hdr

    local title = Label(PS.Hdr, "Priority Steal", 12, T.White, Enum.Font.GothamBold)
    title.Size           = UDim2.new(1, -64, 1, 0)
    title.Position       = UDim2.new(0, 10, 0, 0)
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.ZIndex         = 21

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size            = UDim2.new(0, 22, 0, 22)
    closeBtn.Position        = UDim2.new(1, -28, 0.5, -11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text            = "×"
    closeBtn.TextSize        = 14
    closeBtn.Font            = Enum.Font.GothamBold
    closeBtn.TextColor3      = T.White
    closeBtn.ZIndex          = 22
    closeBtn.Parent          = PS.Hdr
    Corner(closeBtn, 6)

    PS.Scroll = Instance.new("ScrollingFrame")
    PS.Scroll.Size                   = UDim2.new(1, -16, 1, -40)
    PS.Scroll.Position               = UDim2.new(0, 8, 0, 36)
    PS.Scroll.BackgroundTransparency = 1
    PS.Scroll.BorderSizePixel        = 0
    PS.Scroll.ScrollBarThickness     = 3
    PS.Scroll.ScrollBarImageColor3   = Color3.fromRGB(75, 75, 75)
    PS.Scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    PS.Scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    PS.Scroll.ZIndex                 = 19
    PS.Scroll.Parent                 = PS.Win
    local layout = Instance.new("UIListLayout")
    layout.Padding              = UDim.new(0, 4)
    layout.HorizontalAlignment  = Enum.HorizontalAlignment.Center
    layout.Parent               = PS.Scroll
    Padding(PS.Scroll, 4, 4, 0, 0)

    local function _saveCfg()
        Config.priority_steal = {}
        for name, on in pairs(_G._FH_PRIORITY_STEAL) do
            if on then Config.priority_steal[name] = true end
        end
        pcall(FH_SaveConfig)
    end

    PS._rows = PS._rows or {}
    local function _renderNames(names)
        local present = {}
        for _, nm in ipairs(names) do present[nm] = true end
        for nm, row in pairs(PS._rows) do
            if not present[nm] then
                row:Destroy()
                PS._rows[nm] = nil
            end
        end
        table.sort(names)
        for _, nm in ipairs(names) do
            if not PS._rows[nm] then
            local on = _G._FH_PRIORITY_STEAL[nm] == true
            local row = Instance.new("Frame")
            row.Size            = UDim2.new(1, -4, 0, 24)
            row.BackgroundColor3 = T.Card
            row.BorderSizePixel = 0
            row.ZIndex          = 20
            row.Parent          = PS.Scroll
            Corner(row, 6)
            local lbl = Label(row, nm, 11, T.White, Enum.Font.GothamMedium)
            lbl.Size           = UDim2.new(1, -50, 1, 0)
            lbl.Position       = UDim2.new(0, 8, 0, 0)
            lbl.TextYAlignment = Enum.TextYAlignment.Center
            lbl.ZIndex         = 21
            local tg = Instance.new("TextButton")
            tg.Size            = UDim2.new(0, 36, 0, 16)
            tg.Position        = UDim2.new(1, -42, 0.5, -8)
            tg.BackgroundColor3 = on and Color3.fromRGB(20, 70, 30) or Color3.fromRGB(50, 50, 50)
            tg.BorderSizePixel = 0
            tg.Text            = on and "ON" or "OFF"
            tg.TextSize        = 9
            tg.Font            = Enum.Font.GothamBold
            tg.TextColor3      = on and Color3.fromRGB(100, 220, 120) or T.Dim
            tg.ZIndex          = 21
            tg.Parent          = row
            Corner(tg, 4)
            tg.MouseButton1Click:Connect(function()
                local wasOn = _G._FH_PRIORITY_STEAL[nm] == true
                for k in pairs(_G._FH_PRIORITY_STEAL) do
                    _G._FH_PRIORITY_STEAL[k] = nil
                end
                if not wasOn then
                    _G._FH_PRIORITY_STEAL[nm] = true
                end
                for rname, rrow in pairs(PS._rows) do
                    local rtg = rrow:FindFirstChildOfClass("TextButton")
                    if rtg then
                        local on = _G._FH_PRIORITY_STEAL[rname] == true
                        rtg.Text             = on and "ON" or "OFF"
                        rtg.TextColor3       = on and Color3.fromRGB(100, 220, 120) or T.Dim
                        rtg.BackgroundColor3 = on and Color3.fromRGB(20, 70, 30) or Color3.fromRGB(50, 50, 50)
                    end
                end
                _saveCfg()
            end)
            PS._rows[nm] = row
            end
        end
    end

    local function _collectAnimalNames()
        local set = {}
        for nm, _ in pairs(_G._FH_PRIORITY_STEAL) do set[nm] = true end
        if _FH_AG_CachedBrainrots then
            for _, br in ipairs(_FH_AG_CachedBrainrots) do
                if br.displayName and br.displayName ~= "" then
                    set[br.displayName] = true
                end
            end
        end
        local names = {}
        for nm, _ in pairs(set) do table.insert(names, nm) end
        return names
    end

    PS._autoRefresh = nil
    local function _startAutoRefresh()
        if PS._autoRefresh then return end
        PS._autoRefresh = task.spawn(function()
            while PS.Win and PS.Win.Visible do
                local names = _collectAnimalNames()
                _renderNames(names)
                task.wait(2)
            end
            PS._autoRefresh = nil
        end)
    end

    local pDrag, pDragStart, pPanelStart = false, nil, nil
    PS.Hdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            pDrag = true
            pDragStart  = inp.Position
            pPanelStart = PS.Win.Position
        end
    end)
    PS.Hdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if pDrag then
                pDrag = false
                Config.mini = Config.mini or {}
                Config.mini.ps_pos = {
                    x  = PS.Win.Position.X.Offset,
                    y  = PS.Win.Position.Y.Offset,
                    xs = PS.Win.Position.X.Scale,
                    ys = PS.Win.Position.Y.Scale,
                }
                pcall(FH_SaveConfig)
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not PS.Win or not PS.Win.Parent then return end
        if pDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - pDragStart
            PS.Win.Position = UDim2.new(
                pPanelStart.X.Scale, pPanelStart.X.Offset + d.X,
                pPanelStart.Y.Scale, pPanelStart.Y.Offset + d.Y
            )
        end
    end)

    PS.setVisible = function(v)
        PS.Win.Visible    = v and true or false
        PS.Border.Visible = v and true or false
        Config.mini = Config.mini or {}
        Config.mini.ps_open = v and true or false
        pcall(FH_SaveConfig)
        if v then _startAutoRefresh() end
    end

    closeBtn.MouseButton1Click:Connect(function()
        PS.setVisible(false)
        local reg = configRegistry["Priority Steal Panel"]
        if reg and reg.getState() then reg.doToggle() end
    end)
end
_FH_InitPSPanel(); task.wait()

local FA_init = {
    W = isMobile and 130 or 180, H = isMobile and 170 or 210,
    minimized  = false,
    dragging   = false,
    dragStart  = nil,
    panelStart = nil,
    BG        = Color3.fromRGB(15, 15, 15),
    HDR       = Color3.fromRGB(8,  8,  8),
    BTN       = Color3.fromRGB(24, 24, 24),
    BTN_HOVER = Color3.fromRGB(38, 38, 38),
}
for k, v in pairs(FA_init) do FA[k] = v end
FA.FABorderFrame = Instance.new("Frame")
FA.FABorderFrame.Name             = "FadedActionsGradBorder"
FA.FABorderFrame.Size             = UDim2.new(0, FA.W + 4, 0, FA.H + 4)
FA.FABorderFrame.Position         = UDim2.new(1, -(FA.W + 4 + 16), 1, -(FA.H + 4 + 16))
FA.FABorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FA.FABorderFrame.BorderSizePixel  = 0
FA.FABorderFrame.ZIndex           = 18
FA.FABorderFrame.Visible          = false
FA.FABorderFrame.Parent           = GUI
FA.FABorderFrame.BackgroundTransparency = 1
Corner(FA.FABorderFrame, 12)
FA.FAWin = Instance.new("Frame")
FA.FAWin.Name             = "FadedActionsPanel"
FA.FAWin.Size             = UDim2.new(0, FA.W, 0, FA.H)
FA.FAWin.Position         = UDim2.new(1, -(FA.W + 18), 1, -(FA.H + 18))
FA.FAWin.BackgroundColor3 = FA.BG
FA.FAWin.BorderSizePixel  = 0
FA.FAWin.ZIndex           = 19
FA.FAWin.Visible          = false
FA.FAWin.ClipsDescendants = true
FA.FAWin.BackgroundTransparency = 0.25
FA.FAWin.Parent           = GUI
Corner(FA.FAWin, 10)
FA.FAHdr = Instance.new("Frame")
FA.FAHdr.Size             = UDim2.new(1, 0, 0, 36)
FA.FAHdr.BackgroundColor3 = FA.HDR
FA.FAHdr.BorderSizePixel  = 0
FA.FAHdr.ZIndex           = 20
FA.FAHdr.BackgroundTransparency = 0.2
FA.FAHdr.Parent           = FA.FAWin
Corner(FA.FAHdr, 10)
FA.FAHdr.Active = true
FA.FAHdrFill = Instance.new("Frame")
FA.FAHdrFill.Size             = UDim2.new(1, 0, 0, 10)
FA.FAHdrFill.Position         = UDim2.new(0, 0, 1, -10)
FA.FAHdrFill.BackgroundColor3 = FA.HDR
FA.FAHdrFill.BorderSizePixel  = 0
FA.FAHdrFill.ZIndex           = 20
FA.FAHdrFill.Parent           = FA.FAHdr
FA.FAHdrLine = Instance.new("Frame")
FA.FAHdrLine.Size             = UDim2.new(1, 0, 0, 1)
FA.FAHdrLine.Position         = UDim2.new(0, 0, 1, -1)
FA.FAHdrLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FA.FAHdrLine.BorderSizePixel  = 0
FA.FAHdrLine.ZIndex           = 21
FA.FAHdrLine.Parent           = FA.FAHdr
FA.FATitle = Instance.new("TextLabel")
FA.FATitle.Size                  = UDim2.new(1, -40, 1, 0)
FA.FATitle.Position              = UDim2.new(0, 12, 0, 0)
FA.FATitle.BackgroundTransparency = 1
FA.FATitle.Text                  = "Faded Actions"
FA.FATitle.TextSize              = 13
FA.FATitle.Font                  = Enum.Font.GothamBold
FA.FATitle.TextColor3            = Color3.fromRGB(245, 245, 245)
FA.FATitle.TextXAlignment        = Enum.TextXAlignment.Left
FA.FATitle.TextYAlignment        = Enum.TextYAlignment.Center
FA.FATitle.ZIndex                = 22
FA.FATitle.Parent                = FA.FAHdr
FA.FAMinBtn = Instance.new("TextButton")
FA.FAMinBtn.Size             = UDim2.new(0, 22, 0, 22)
FA.FAMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
FA.FAMinBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
FA.FAMinBtn.BorderSizePixel  = 0
FA.FAMinBtn.Text             = "\226\136\146"
FA.FAMinBtn.TextSize         = 13
FA.FAMinBtn.Font             = Enum.Font.GothamBold
FA.FAMinBtn.TextColor3       = Color3.fromRGB(245, 245, 245)
FA.FAMinBtn.ZIndex           = 23
FA.FAMinBtn.Parent           = FA.FAHdr
Corner(FA.FAMinBtn, 6)
Stroke(FA.FAMinBtn, Color3.fromRGB(55, 55, 55), 1)
FA.FAContent = Instance.new("Frame")
FA.FAContent.Size                   = UDim2.new(1, 0, 1, -36)
FA.FAContent.Position               = UDim2.new(0, 0, 0, 36)
FA.FAContent.BackgroundTransparency = 1
FA.FAContent.ZIndex                 = 19
FA.FAContent.Parent                 = FA.FAWin
FA.FALayout = Instance.new("UIListLayout")
FA.FALayout.FillDirection       = Enum.FillDirection.Vertical
FA.FALayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FA.FALayout.Padding             = UDim.new(0, 5)
FA.FALayout.Parent              = FA.FAContent
Padding(FA.FAContent, 8, 8, 8, 8)
FA.makeBtn = function(labelText, fireFn)
    local entry    = { keyCode = nil }
    local debounce = false
    local row = Instance.new("Frame")
    row.Size                   = UDim2.new(1, -4, 0, isMobile and 21 or 27)
    row.BackgroundColor3       = FA.BTN
    row.BorderSizePixel        = 0
    row.ZIndex                 = 20
    row.Parent                 = FA.FAContent
    Corner(row, 8)
    Stroke(row, Color3.fromRGB(45, 45, 45), 1)
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1, -52, 1, 0)
    lbl.Position          = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = isMobile and 10 or 12
    lbl.TextColor3        = Color3.fromRGB(245, 245, 245)
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.TextYAlignment    = Enum.TextYAlignment.Center
    lbl.ZIndex            = 21
    lbl.Parent            = row
    local kbLbl = Instance.new("TextLabel")
    kbLbl.Size              = UDim2.new(0, 38, 0, 14)
    kbLbl.Position          = UDim2.new(1, -44, 0.5, -7)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text              = ""
kbLbl.TextSize          = 9
    kbLbl.Font              = Enum.Font.GothamBold
    kbLbl.TextColor3        = T.Dim
    kbLbl.TextXAlignment    = Enum.TextXAlignment.Center
    kbLbl.ZIndex            = 22
    kbLbl.Parent            = row
    do
        local _faKey = "fa_".. labelText:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
        local _saved = Config and Config.keybinds and Config.keybinds[_faKey]
        if type(_saved) == "string" then
            local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
            if _ok and _kc then
                entry.keyCode    = _kc
                kbLbl.Text       = "[" .. _saved .. "]"
                kbLbl.TextColor3 = T.Dim
            end
        end
    end
    local hitArea = Instance.new("Frame")
    hitArea.Size                   = UDim2.new(1, 0, 1, 0)
    hitArea.BackgroundTransparency = 1
    hitArea.ZIndex                 = 23
    hitArea.Active                 = true
    hitArea.Parent                 = row
    local _hitTouchActive = false
    local _hitTouchStart  = nil
    hitArea.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            Tween(row, F, {BackgroundColor3 = FA.BTN_HOVER})
            task.delay(0.12, function() Tween(row, F, {BackgroundColor3 = FA.BTN}) end)
            fireFn()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _hitTouchActive = true
            _hitTouchStart  = inp.Position
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
            if debounce then return end
            debounce = true
            task.delay(0.2, function() debounce = false end)
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == kbLbl then
                    kbLbl.Text       = entry.keyCode and ("[".. entry.keyCode.Name .. "]") or ""
kbLbl.TextColor3 = T.Dim
                    return
                else
                    prev.kbLbl.Text       = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
                end
            end
            kbLbl.Text       = "(...)"
kbLbl.TextColor3 = T.White
            keybindBindingTarget = { entry = entry, kbLbl = kbLbl, mode = "assign"}
        end
    end)
    local _rowHovered = false
    hitArea.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _hitTouchActive then
            _hitTouchActive = false
            if _hitTouchStart and (inp.Position - _hitTouchStart).Magnitude < 20 then
                Tween(row, F, {BackgroundColor3 = FA.BTN_HOVER})
                task.delay(0.12, function()
                    Tween(row, F, {BackgroundColor3 = _rowHovered and FA.BTN_HOVER or FA.BTN})
                end)
                fireFn()
            end
            _hitTouchStart = nil
        end
    end)
    row.MouseEnter:Connect(function()
        if _rowHovered then return end
        _rowHovered = true
        Tween(row, F, {BackgroundColor3 = FA.BTN_HOVER})
    end)
    row.MouseLeave:Connect(function()
        if not _rowHovered then return end
        _rowHovered = false
        Tween(row, F, {BackgroundColor3 = FA.BTN})
    end)
    table.insert(keybindEntries, { entry = entry, fire = fireFn, kbLbl = kbLbl })
    local faKey = "fa_".. labelText:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
    configRegistry[faKey] = {
        getState   = function() return false end,
        getKeyCode = function() return entry.keyCode end,
        setKeyCode = function(kc)
            entry.keyCode = kc
            if kc then
                kbLbl.Text       = "[".. kc.Name .. "]"
kbLbl.TextColor3 = T.Dim
                Config.keybinds[faKey] = kc.Name
            else
                kbLbl.Text = ""
Config.keybinds[faKey] = nil
            end
            pcall(FH_SaveConfig)
        end,
        doToggle   = fireFn,
        kbLbl      = kbLbl,
        kbEntry    = entry,
    }
    return row
end
FA.makeBtn("Kick Self", function()
task.spawn(function() player:Kick() end)
    task.spawn(function() pcall(function() game:Shutdown() end) end)
    task.spawn(function() pcall(function() game:GetService("TeleportService"):Teleport(0, player) end) end)
    task.spawn(function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, player) end) end)
end)
do
    FA.makeBtn("Ragdoll Self", function()
        local commandFrame, profileFrame = _ragdollGetAdminFrames()
        if not commandFrame or not profileFrame then return end
        local pName = Players.LocalPlayer.Name
        local profileBtn = profileFrame:FindFirstChild(pName)
        local ragdollBtn = commandFrame:FindFirstChild("ragdoll")
        if not profileBtn or not ragdollBtn then return end
        if not _ragdollProfileCache[pName] then
            _ragdollProfileCache[pName] = _ragdollCacheActivated(profileBtn)
        end
        if not _ragdollCommandCache["ragdoll"] then
            _ragdollCommandCache["ragdoll"] = _ragdollCacheActivated(ragdollBtn)
        end
        _ragdollFireActivated(_ragdollCommandCache["ragdoll"])
        task.wait()
        _ragdollFireActivated(_ragdollProfileCache[pName])
    end)
    FA.makeBtn("GP+RGDL", function()
        task.spawn(function()
            local lp2  = Players.LocalPlayer
            local char2 = lp2.Character
            local bp2   = lp2:FindFirstChild("Backpack")
            if not char2 then return end
            local potion2 = (char2 and char2:FindFirstChild("Giant Potion"))
                         or (bp2  and  bp2:FindFirstChild("Giant Potion"))
            if potion2 then
                if potion2.Parent ~= char2 then
                    local hum2 = char2:FindFirstChildOfClass("Humanoid")
                    if hum2 then hum2:EquipTool(potion2) end
                    task.wait(0.05)
                end
                pcall(function() potion2:Activate() end)
            end
            task.wait(0.5)
            local cF2, pF2 = _ragdollGetAdminFrames()
            if cF2 and pF2 then
                local pName2 = lp2.Name
                local pBtn2  = pF2:FindFirstChild(pName2)
                local rBtn2  = cF2:FindFirstChild("ragdoll")
                if pBtn2 and rBtn2 then
                    if not _ragdollCommandCache["ragdoll"] then
                        _ragdollCommandCache["ragdoll"] = _ragdollCacheActivated(rBtn2)
                    end
                    if not _ragdollProfileCache[pName2] then
                        _ragdollProfileCache[pName2] = _ragdollCacheActivated(pBtn2)
                    end
                    _ragdollFireActivated(_ragdollCommandCache["ragdoll"])
                    task.wait()
                    _ragdollFireActivated(_ragdollProfileCache[pName2])
                end
            end
        end)
    end)
end
FA.makeBtn("Reset Character", function()
    doSelectedReset()
end)
FA.makeBtn("Rejoin Server", function()
    local ts = game:GetService("TeleportService")
    task.spawn(function()
        pcall(function() ts:Teleport(game.PlaceId, Players.LocalPlayer) end)
    end)
    pcall(function() Players.LocalPlayer:Kick("rejoining") end)
end)
do
    FA.FAHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            FA.dragging   = true
            FA.dragStart  = inp.Position
            FA.panelStart = FA.FAWin.Position
        end
    end)
    FA.FAHdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            FA.dragging = false
            Config.mini = Config.mini or {}
            Config.mini.fa_pos = { x = FA.FAWin.Position.X.Offset, y = FA.FAWin.Position.Y.Offset,
                                   xs = FA.FAWin.Position.X.Scale, ys = FA.FAWin.Position.Y.Scale }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if FA.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - FA.dragStart
            local newPos = UDim2.new(
                FA.panelStart.X.Scale, FA.panelStart.X.Offset + d.X,
                FA.panelStart.Y.Scale, FA.panelStart.Y.Offset + d.Y
            )
            FA.FAWin.Position         = newPos
            FA.FABorderFrame.Position = UDim2.new(
                newPos.X.Scale, newPos.X.Offset - 2,
                newPos.Y.Scale, newPos.Y.Offset - 2
            )
        end
    end)
end
FA.FAMinBtn.MouseButton1Click:Connect(function()
    FA.minimized = not FA.minimized
    if FA.minimized then
        FA.FAWin.ClipsDescendants = false
        FA.FAHdrFill.Visible = false
        FA.FAHdrLine.Visible = false
        FA.FAContent.Visible = false
        Tween(FA.FAWin,         M, {Size = UDim2.new(0, FA.W, 0, 36)})
        Tween(FA.FABorderFrame, M, {Size = UDim2.new(0, FA.W + 4, 0, 40)})
        FA.FAMinBtn.Text = "+"else
        FA.FAHdrFill.Visible = true
        FA.FAHdrLine.Visible = true
        Tween(FA.FAWin,         M, {Size = UDim2.new(0, FA.W, 0, FA.H)})
        Tween(FA.FABorderFrame, M, {Size = UDim2.new(0, FA.W + 4, 0, FA.H + 4)})
        FA.FAMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            FA.FAContent.Visible = true
            FA.FAWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.fa_min = FA.minimized
        pcall(FH_SaveConfig)
    end
end)
FA.setFadedActionsVisible = function(vis)
    FA.FAWin.Visible         = vis
    FA.FABorderFrame.Visible = vis
    if vis then
        local p = FA.FAWin.Position
        FA.FABorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if FA.minimized then
            FA.FAMinBtn.Text      = "+"
FA.FAContent.Visible  = false
            FA.FAHdrFill.Visible  = false
            FA.FAHdrLine.Visible  = false
            FA.FAWin.ClipsDescendants = false
            FA.FAWin.Size         = UDim2.new(0, FA.W, 0, 36)
            FA.FABorderFrame.Size = UDim2.new(0, FA.W + 4, 0, 40)
        else
            FA.FAMinBtn.Text      = "\226\136\146"
FA.FAContent.Visible  = true
            FA.FAHdrFill.Visible  = true
            FA.FAHdrLine.Visible  = true
            FA.FAWin.ClipsDescendants = true
            FA.FAWin.Size         = UDim2.new(0, FA.W, 0, FA.H)
            FA.FABorderFrame.Size = UDim2.new(0, FA.W + 4, 0, FA.H + 4)
        end
    end
end
do
    BOOK_OPEN = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Win.Size             = UDim2.new(0, 0, 0, WIN_H)
    Win.Position         = UDim2.new(0.5, 0, 0.5, -WIN_H / 2)
    BorderFrame.Size     = UDim2.new(0, 4, 0, WIN_H + 4)
    BorderFrame.Position = UDim2.new(0.5, -2, 0.5, -(WIN_H + 4) / 2)
    Win.Visible         = true
    BorderFrame.Visible = true
    task.delay(0.18, function()
        local _tx, _ty = -WIN_W / 2, -WIN_H / 2
        TweenService:Create(Win, BOOK_OPEN, {
            Size     = UDim2.new(0, WIN_W, 0, WIN_H),
            Position = UDim2.new(0.5, _tx, 0.5, _ty),
        }):Play()
        TweenService:Create(BorderFrame, BOOK_OPEN, {
            Size     = UDim2.new(0, WIN_W + 4, 0, WIN_H + 4),
            Position = UDim2.new(0.5, _tx - 2, 0.5, _ty - 2),
        }):Play()
    end)
end
WSK.W = isMobile and 144 or 200; WSK.H = isMobile and 64 or 90
WSK.WSKBorderFrame = Instance.new("Frame")
WSK.WSKBorderFrame.Name             = "WSKGradBorder"
WSK.WSKBorderFrame.Size             = UDim2.new(0, WSK.W + 4, 0, WSK.H + 4)
WSK.WSKBorderFrame.Position         = UDim2.new(1, -(WSK.W + 4 + 16), 1, -(WSK.H + 4 + 195 + 188 + 52))
WSK.WSKBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
WSK.WSKBorderFrame.BorderSizePixel  = 0
WSK.WSKBorderFrame.ZIndex           = 18
WSK.WSKBorderFrame.Visible          = false
WSK.WSKBorderFrame.Parent           = GUI
WSK.WSKBorderFrame.BackgroundTransparency = 1
Corner(WSK.WSKBorderFrame, 12)
do
WSK.WSKWin = Instance.new("Frame")
WSK.WSKWin.Name             = "WSKPanel"
WSK.WSKWin.Size             = UDim2.new(0, WSK.W, 0, WSK.H)
WSK.WSKWin.Position         = UDim2.new(1, -(WSK.W + 18), 1, -(WSK.H + 195 + 188 + 50))
WSK.WSKWin.BackgroundColor3 = T.BG
WSK.WSKWin.BackgroundTransparency = 0.25
WSK.WSKWin.BorderSizePixel  = 0
WSK.WSKWin.ZIndex           = 19
WSK.WSKWin.Visible          = false
WSK.WSKWin.ClipsDescendants = true
WSK.WSKWin.Parent           = GUI
Corner(WSK.WSKWin, 10)
WSK.WSKHdr = Instance.new("Frame")
WSK.WSKHdr.Size             = UDim2.new(1, 0, 0, 36)
WSK.WSKHdr.BackgroundColor3 = T.Header
WSK.WSKHdr.BackgroundTransparency = 0.2
WSK.WSKHdr.BorderSizePixel  = 0
WSK.WSKHdr.ZIndex           = 20
WSK.WSKHdr.Parent           = WSK.WSKWin
Corner(WSK.WSKHdr, 10)
WSK.WSKHdr.Active = true
WSK.WSKHdrFill = Instance.new("Frame")
WSK.WSKHdrFill.Size             = UDim2.new(1, 0, 0, 10)
WSK.WSKHdrFill.Position         = UDim2.new(0, 0, 1, -10)
WSK.WSKHdrFill.BackgroundColor3 = T.Header
WSK.WSKHdrFill.BackgroundTransparency = 0.2
WSK.WSKHdrFill.BorderSizePixel  = 0
WSK.WSKHdrFill.ZIndex           = 20
WSK.WSKHdrFill.Parent           = WSK.WSKHdr
WSK.WSKHdrLine = Instance.new("Frame")
WSK.WSKHdrLine.Size             = UDim2.new(1, 0, 0, 1)
WSK.WSKHdrLine.Position         = UDim2.new(0, 0, 1, -1)
WSK.WSKHdrLine.BackgroundColor3 = T.Border
WSK.WSKHdrLine.BorderSizePixel  = 0
WSK.WSKHdrLine.ZIndex           = 21
WSK.WSKHdrLine.Parent           = WSK.WSKHdr
do
local WSKTitleLbl = Label(WSK.WSKHdr, "Websling Kill", 13, T.White, Enum.Font.GothamBold)
WSKTitleLbl.Size           = UDim2.new(1, -40, 1, 0)
WSKTitleLbl.Position       = UDim2.new(0, 12, 0, 0)
WSKTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
WSKTitleLbl.TextYAlignment = Enum.TextYAlignment.Center
WSKTitleLbl.ZIndex         = 22
WSK.WSKMinBtn = Instance.new("TextButton")
WSK.WSKMinBtn.Size             = UDim2.new(0, 22, 0, 22)
WSK.WSKMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
WSK.WSKMinBtn.BackgroundColor3 = T.Card
WSK.WSKMinBtn.BorderSizePixel  = 0
WSK.WSKMinBtn.Text             = "\226\136\146"
WSK.WSKMinBtn.TextSize         = 14
WSK.WSKMinBtn.Font             = Enum.Font.GothamBold
WSK.WSKMinBtn.TextColor3       = T.White
WSK.WSKMinBtn.ZIndex           = 23
WSK.WSKMinBtn.Parent           = WSK.WSKHdr
Corner(WSK.WSKMinBtn, 6)
Stroke(WSK.WSKMinBtn, T.Border, 1)
WSK.WSKContent = Instance.new("Frame")
WSK.WSKContent.Size                   = UDim2.new(1, 0, 1, -36)
WSK.WSKContent.Position               = UDim2.new(0, 0, 0, 36)
WSK.WSKContent.BackgroundTransparency = 1
WSK.WSKContent.ZIndex                 = 20
WSK.WSKContent.Parent                 = WSK.WSKWin
Padding(WSK.WSKContent, 8, 8, 8, 8)
local wskRow = Instance.new("Frame")
wskRow.Size             = UDim2.new(1, 0, 0, 32)
wskRow.BackgroundColor3 = T.Card
wskRow.BorderSizePixel  = 0
wskRow.ZIndex           = 21
wskRow.Parent           = WSK.WSKContent
Corner(wskRow, 8)
Stroke(wskRow, T.Border, 1)
local wskLbl = Label(wskRow, "Fire WSK (1s)", 13, T.White, Enum.Font.GothamMedium)
wskLbl.Size           = UDim2.new(1, -100, 1, 0)
wskLbl.Position       = UDim2.new(0, 10, 0, 0)
wskLbl.TextYAlignment = Enum.TextYAlignment.Center
wskLbl.ZIndex         = 22
WSK.wskKbLbl = Instance.new("TextLabel")
WSK.wskKbLbl.Size              = UDim2.new(0, 36, 0, 14)
WSK.wskKbLbl.Position          = UDim2.new(1, -94, 0.5, -7)
WSK.wskKbLbl.BackgroundTransparency = 1
WSK.wskKbLbl.Text              = ""
WSK.wskKbLbl.TextSize          = 9
WSK.wskKbLbl.Font              = Enum.Font.GothamBold
WSK.wskKbLbl.TextColor3        = T.Dim
WSK.wskKbLbl.TextXAlignment    = Enum.TextXAlignment.Center
WSK.wskKbLbl.ZIndex            = 23
WSK.wskKbLbl.Parent            = wskRow
do
    local _saved = Config and Config.keybinds and Config.keybinds["wsk_fire_burst"]
    if type(_saved) == "string" then
        local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
        if _ok and _kc then
            WSK.entry.keyCode       = _kc
            WSK.wskKbLbl.Text       = "[" .. _saved .. "]"
            WSK.wskKbLbl.TextColor3 = T.Dim
        end
    end
end
local wskTrack = Instance.new("Frame")
wskTrack.Size             = UDim2.new(0, 28, 0, 16)
wskTrack.Position         = UDim2.new(1, -48, 0.5, -11)
wskTrack.BackgroundColor3 = T.TrackOff
wskTrack.BorderSizePixel  = 0
wskTrack.ZIndex           = 22
wskTrack.Parent           = wskRow
Corner(wskTrack, 8)
local wskTStroke = Stroke(wskTrack, T.Border, 1)
local wskKnob = Instance.new("Frame")
wskKnob.Size             = UDim2.new(0, 12, 0, 12)
wskKnob.Position         = UDim2.new(0, 2, 0.5, -6)
wskKnob.BackgroundColor3 = T.KnobOff
wskKnob.BorderSizePixel  = 0
wskKnob.ZIndex           = 23
wskKnob.Parent           = wskTrack
Corner(wskKnob, 6)
local wskFiring = false
local wskFireBurst
_G._FH_WSKFireBurst = function() if wskFireBurst then wskFireBurst() end end
wskFireBurst = function()
    if wskFiring then return end
    wskFiring = true
    Tween(wskKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
    task.delay(0.06, function()
        Tween(wskKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
        Tween(wskKnob,    M, {BackgroundColor3 = T.KnobOn})
        Tween(wskTrack,   M, {BackgroundColor3 = T.TrackOn})
        Tween(wskTStroke, M, {Color = T.TrackOn})
    end)
    wskLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
    task.spawn(function()
        local localChar = Players.LocalPlayer.Character
        local hum       = localChar and localChar:FindFirstChildOfClass("Humanoid")
        if not localChar or not hum then
            wskFiring = false
            return
        end
        local ws = localChar:FindFirstChild("Web Slinger")
            or (Players.LocalPlayer.Backpack and Players.LocalPlayer.Backpack:FindFirstChild("Web Slinger"))
        if not ws then wskFiring = false; return end
        if ws.Parent ~= localChar then
            hum:EquipTool(ws)
            task.wait(0.05)
        end
        pcall(Aim.aimInitRemotes)
        Aim.currentCharacter = localChar
        local target = wskGetNearest()
        if not target or not target.Character then wskFiring = false; return end
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local tHum = target.Character:FindFirstChildOfClass("Humanoid")
        if not tHRP or not tHum then wskFiring = false; return end
        local above     = true
        local shotTimer = 0
        local stopped   = false
        local function doStop(loop)
            if stopped then return end
            stopped = true
            loop:Disconnect()
            Tween(wskKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
            task.delay(0.06, function()
                Tween(wskKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
                Tween(wskKnob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(wskTrack,   M, {BackgroundColor3 = T.TrackOff})
                Tween(wskTStroke, M, {Color = T.Border})
            end)
            wskLbl.TextColor3 = T.White
            wskFiring = false
        end
        local burstLoop
        burstLoop = RunService.Heartbeat:Connect(function(dt)
            if tHum.Health <= 0 or not tHum.Parent then
                doStop(burstLoop)
                return
            end
            shotTimer += dt
            if shotTimer >= 0.08 then
                shotTimer = 0
                pcall(Aim.aimShoot)
            end
            if target.Character and tHRP and tHRP.Parent then
                if above then
                    tHRP.CFrame = tHRP.CFrame + Vector3.new(0, 20, 0)
                else
                    tHRP.CFrame = tHRP.CFrame + Vector3.new(0, -20, 0)
                end
                above = not above
            end
        end)
        task.wait(1)
        doStop(burstLoop)
    end)
end
local wskHitArea = Instance.new("Frame")
wskHitArea.Size                   = UDim2.new(1, 0, 1, 0)
wskHitArea.BackgroundTransparency = 1
wskHitArea.ZIndex                 = 24
wskHitArea.Active                 = true
wskHitArea.Parent                 = wskRow
wskHitArea.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        wskFireBurst()
    elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
        if WSK.kb2Debounce then return end
        WSK.kb2Debounce = true
        task.delay(0.2, function() WSK.kb2Debounce = false end)
        if keybindBindingTarget then
            local prev = keybindBindingTarget
            keybindBindingTarget = nil
            if prev.kbLbl == WSK.wskKbLbl then
                WSK.wskKbLbl.Text       = WSK.entry.keyCode and ("[".. WSK.entry.keyCode.Name .. "]") or ""
WSK.wskKbLbl.TextColor3 = T.Dim
                return
            else
                prev.kbLbl.Text       = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
            end
        end
        WSK.wskKbLbl.Text       = "(...)"
WSK.wskKbLbl.TextColor3 = T.White
        keybindBindingTarget = { entry = WSK.entry, kbLbl = WSK.wskKbLbl, mode = "assign"}
    end
end)
do
    local _wskTouchStart = nil
    wskHitArea.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch then
            _wskTouchStart = inp.Position
        end
    end)
    wskHitArea.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _wskTouchStart then
            local mag = (inp.Position - _wskTouchStart).Magnitude
            _wskTouchStart = nil
            if mag < 20 then wskFireBurst() end
        end
    end)
end
table.insert(keybindEntries, { entry = WSK.entry, fire = wskFireBurst, kbLbl = WSK.wskKbLbl })
configRegistry["wsk_fire_burst"] = {
    getState   = function() return false end,
    getKeyCode = function() return WSK.entry.keyCode end,
    setKeyCode = function(kc)
        WSK.entry.keyCode = kc
        if kc then
            WSK.wskKbLbl.Text       = "[".. kc.Name .. "]"
WSK.wskKbLbl.TextColor3 = T.Dim
            Config.keybinds["wsk_fire_burst"] = kc.Name
        else
            WSK.wskKbLbl.Text = ""
Config.keybinds["wsk_fire_burst"] = nil
        end
        pcall(FH_SaveConfig)
    end,
    doToggle = wskFireBurst,
}
end
WSK.WSKHdr.InputBegan:Connect(function(inp)
    if _G._FH_GUI_LOCKED then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        WSK.dragging   = true
        WSK.dragStart  = inp.Position
        WSK.panelStart = WSK.WSKWin.Position
    end
end)
WSK.WSKHdr.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        WSK.dragging = false
        Config.mini = Config.mini or {}
        Config.mini.wsk_pos = { x = WSK.WSKWin.Position.X.Offset, y = WSK.WSKWin.Position.Y.Offset,
                                xs = WSK.WSKWin.Position.X.Scale, ys = WSK.WSKWin.Position.Y.Scale }
        pcall(FH_SaveConfig)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if WSK.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - WSK.dragStart
        local newPos = UDim2.new(
            WSK.panelStart.X.Scale, WSK.panelStart.X.Offset + d.X,
            WSK.panelStart.Y.Scale, WSK.panelStart.Y.Offset + d.Y
        )
        WSK.WSKWin.Position         = newPos
        WSK.WSKBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
    end
end)
WSK.WSKMinBtn.MouseButton1Click:Connect(function()
    WSK.minimized = not WSK.minimized
    if WSK.minimized then
        WSK.WSKWin.ClipsDescendants = false
        WSK.WSKHdrFill.Visible  = false
        WSK.WSKHdrLine.Visible  = false
        WSK.WSKContent.Visible  = false
        Tween(WSK.WSKWin,         M, {Size = UDim2.new(0, WSK.W, 0, 36)})
        Tween(WSK.WSKBorderFrame, M, {Size = UDim2.new(0, WSK.W + 4, 0, 40)})
        WSK.WSKMinBtn.Text = "+"else
        WSK.WSKHdrFill.Visible = true
        WSK.WSKHdrLine.Visible = true
        Tween(WSK.WSKWin,         M, {Size = UDim2.new(0, WSK.W, 0, WSK.H)})
        Tween(WSK.WSKBorderFrame, M, {Size = UDim2.new(0, WSK.W + 4, 0, WSK.H + 4)})
        WSK.WSKMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            WSK.WSKContent.Visible  = true
            WSK.WSKWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.wsk_min = WSK.minimized
        pcall(FH_SaveConfig)
    end
end)
WSK.setWSKPanelVisible = function(vis)
    WSK.WSKWin.Visible         = vis
    WSK.WSKBorderFrame.Visible = vis
    if vis then
        local p = WSK.WSKWin.Position
        WSK.WSKBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if WSK.minimized then
            WSK.WSKMinBtn.Text          = "+"
WSK.WSKContent.Visible      = false
            WSK.WSKHdrFill.Visible      = false
            WSK.WSKHdrLine.Visible      = false
            WSK.WSKWin.ClipsDescendants = false
            WSK.WSKWin.Size             = UDim2.new(0, WSK.W, 0, 36)
            WSK.WSKBorderFrame.Size     = UDim2.new(0, WSK.W + 4, 0, 40)
        else
            WSK.WSKMinBtn.Text          = "\226\136\146"
WSK.WSKContent.Visible      = true
            WSK.WSKHdrFill.Visible      = true
            WSK.WSKHdrLine.Visible      = true
            WSK.WSKWin.ClipsDescendants = true
            WSK.WSKWin.Size             = UDim2.new(0, WSK.W, 0, WSK.H)
            WSK.WSKBorderFrame.Size     = UDim2.new(0, WSK.W + 4, 0, WSK.H + 4)
        end
    else
        WSK.enabled = false
        wskStop()
    end
end
end
local AutoDefenseEnabled  = false
local AntiTPEnabled_state = false
local startAntiIntruder, stopAntiIntruder
task.spawn(function()
AutoDefenseEnabled     = false
AntiTPEnabled_state    = false
local kickNoCmdsEnabled      = false
local defenseTarget1, defenseTarget2
local lastDefenseExecuteTime = 0
local defenseCommandCache    = {}
local defenseProfileCache    = {}
local function defenseCacheActivated(guiObject)
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
local function defenseFireActivated(cached)
    for _, fn in ipairs(cached) do task.spawn(fn) end
end
local function getDefenseAdminPanel()
    local player     = Players.LocalPlayer
    local adminPanel = player.PlayerGui:FindFirstChild("AdminPanel")
    if not adminPanel then return nil, nil end
    local panel = adminPanel:FindFirstChild("AdminPanel")
    if not panel then return nil, nil end
    local content  = panel:FindFirstChild("Content")
    local profiles = panel:FindFirstChild("Profiles")
    if not content or not profiles then return nil, nil end
    return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end
local function buildDefenseCache(targetPlayer)
    local commandFrame, profileFrame = getDefenseAdminPanel()
    if not commandFrame or not profileFrame then return false end
    local profileButton = profileFrame:FindFirstChild(targetPlayer.Name)
    if not profileButton then return false end
    if not defenseProfileCache[targetPlayer.Name] then
        defenseProfileCache[targetPlayer.Name] = defenseCacheActivated(profileButton)
    end
    for _, cmd in ipairs({"balloon","ragdoll","jail"}) do
        if not defenseCommandCache[cmd] then
            local btn = commandFrame:FindFirstChild(cmd)
            if btn then defenseCommandCache[cmd] = defenseCacheActivated(btn) end
        end
    end
    return true
end
local function defenseExecuteCommandsOnPlayer(targetPlayer, commandList)
    if not defenseProfileCache[targetPlayer.Name] or #defenseProfileCache[targetPlayer.Name] == 0 then
        if not buildDefenseCache(targetPlayer) then return false end
    end
    local profileConns = defenseProfileCache[targetPlayer.Name]
    for _, command in ipairs(commandList) do
        local cmdConns = defenseCommandCache[command]
        if cmdConns and #cmdConns > 0 then
            defenseFireActivated(cmdConns)
            defenseFireActivated(profileConns)
        end
    end
    return true
end
local defenseCmdSwitch = false
local defenseBothOnCD = false
local defenseLaserActive = false
task.spawn(function()
    while _G.FadedHubAlive do
        if AutoDefenseEnabled then
            task.wait(0.15)
            pcall(function()
                local sf = Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame
                local balloonCD = sf.balloon.Timer.Visible
                local ragdollCD = sf.ragdoll.Timer.Visible
                if balloonCD and ragdollCD then
                    defenseBothOnCD = true
                else
                    defenseBothOnCD = false
                    if not balloonCD then
                        defenseCmdSwitch = false
                    elseif not ragdollCD then
                        defenseCmdSwitch = true
                    end
                end
            end)
        else
            task.wait(0.75)
        end
    end
end)
local defenseExecuteCooldown = 0.05
local function defenseAutoSelectClosest()
    local player = Players.LocalPlayer
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr:GetAttribute("Stealing") then defenseTarget1 = plr; break end
    end
end
local function defenseRunDefenseCommands()
    local player = Players.LocalPlayer
    if (tick() - lastDefenseExecuteTime) < defenseExecuteCooldown then return end
    if not defenseTarget1 and not defenseTarget2 then defenseAutoSelectClosest() end
    local validPlayers = {}
    if defenseTarget1 and defenseTarget1.Parent == Players and defenseTarget1:GetAttribute("Stealing") then table.insert(validPlayers, defenseTarget1) end
    if defenseTarget2 and defenseTarget2.Parent == Players and defenseTarget2:GetAttribute("Stealing") then table.insert(validPlayers, defenseTarget2) end
    if #validPlayers == 0 then return end
    if #validPlayers == 1 then
        if not defenseCmdSwitch then
            task.spawn(function() defenseExecuteCommandsOnPlayer(validPlayers[1], {"balloon"}) end)
        else
            task.spawn(function() defenseExecuteCommandsOnPlayer(validPlayers[1], {"ragdoll"}) end)
        end
    elseif #validPlayers >= 2 then
        task.spawn(function() defenseExecuteCommandsOnPlayer(validPlayers[1], {"balloon","tiny","inverse","rocket"}) end)
        task.spawn(function() defenseExecuteCommandsOnPlayer(validPlayers[2], {"ragdoll","jail","jumpscare","morph"}) end)
    end
    lastDefenseExecuteTime = tick()
end
do
local antiIntruderConn    = nil
    local antiIntruderThrottle = 0

    local function _parseProtectionSeconds(txt)
        if type(txt) ~= "string" or txt == "" then return math.huge end
        local mins, secs = txt:match("(%d+)%s*[:m]%s*(%d+)")
        if mins and secs then return tonumber(mins) * 60 + tonumber(secs) end
        local s = txt:match("(%d+)")
        if s then return tonumber(s) end
        return math.huge
    end

    local function _myProtectionSeconds()
        local lp = Players.LocalPlayer
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return math.huge end
        for _, plot in ipairs(plots:GetChildren()) do
            if _FH_AG_IsMyPlot(plot) then
                if _G._FH_BaseTimerTexts and _G._FH_BaseTimerTexts[plot] then
                    return _parseProtectionSeconds(_G._FH_BaseTimerTexts[plot])
                end
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    for _, d in ipairs(sign:GetDescendants()) do
                        if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Visible
                           and type(d.Text) == "string" and d.Text:match("%d") then
                            local s = _parseProtectionSeconds(d.Text)
                            if s ~= math.huge then return s end
                        end
                    end
                end
                return math.huge
            end
        end
        return math.huge
    end

    startAntiIntruder = function()
        if antiIntruderConn then return end
        antiIntruderConn = RunService.Heartbeat:Connect(function()
            if not AntiTPEnabled_state then return end
            local now = tick()
            if now - antiIntruderThrottle < 0.35 then return end
            antiIntruderThrottle = now

            local secsLeft = _myProtectionSeconds()
            if secsLeft >= 3 then return end
            local lp = Players.LocalPlayer
            local hitbox = nil
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in ipairs(plots:GetChildren()) do
                    local sign = plot:FindFirstChild("PlotSign")
                    if sign then
                        local lbl = sign:FindFirstChildWhichIsA("TextLabel", true)
                        if lbl then
                            local t = lbl.Text:lower()
                            if t:find(lp.Name:lower()) or t:find(lp.DisplayName:lower()) then
                                hitbox = plot:FindFirstChild("StealHitbox", true)
                                break
                            end
                        end
                    end
                end
            end
            if not hitbox then return end
            local cf   = hitbox.CFrame
            local size = hitbox.Size
            local hx   = size.X * 0.5
            local hz   = size.Z * 0.5
            local _intruderIdx = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local rel = cf:PointToObjectSpace(hrp.Position)
                        if math.abs(rel.X) <= hx and math.abs(rel.Z) <= hz then
                            _intruderIdx = _intruderIdx + 1
                            local _slotIdx = _intruderIdx
                            task.spawn(function()
                                local commandFrame, profileFrame = getDefenseAdminPanel()
                                if not commandFrame or not profileFrame then return end
                                local profileBtn = profileFrame:FindFirstChild(plr.Name)
                                if not profileBtn then return end
                                if not defenseProfileCache[plr.Name] then
                                    defenseProfileCache[plr.Name] = defenseCacheActivated(profileBtn)
                                end
                                local cmdsToRun = {}

                                local _cmdList
                                if (_slotIdx % 2) == 1 then
                                    _cmdList = _G._FH_DefenseCmdsP1
                                else
                                    _cmdList = _G._FH_DefenseCmdsP2
                                end
                                if type(_cmdList) ~= "table" or #_cmdList == 0 then
                                    _cmdList = _G._FH_DefenseCmds
                                end
                                if type(_cmdList) ~= "table" or #_cmdList == 0 then
                                    _cmdList = { "balloon", "jail" }
                                end
                                for _, cmdName in ipairs(_cmdList) do
                                    if not defenseCommandCache[cmdName] then
                                        local cb = commandFrame:FindFirstChild(cmdName)
                                        if cb then
                                            defenseCommandCache[cmdName] = defenseCacheActivated(cb)
                                        end
                                    end
                                    local cc = defenseCommandCache[cmdName]
                                    local sf = nil
                                    pcall(function()
                                        sf = lp.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame
                                    end)
                                    local onCD = false
                                    if sf then
                                        local f = sf:FindFirstChild(cmdName)
                                        if f and f:FindFirstChild("Timer") and f.Timer.Visible then
                                            onCD = true
                                        end
                                    end
                                    if not onCD and cc and #cc > 0 then
                                        table.insert(cmdsToRun, cmdName)
                                    end
                                end
                                if #cmdsToRun > 0 then
                                    local profileConns = defenseProfileCache[plr.Name]
                                    for _, cmdName in ipairs(cmdsToRun) do
                                        local cc = defenseCommandCache[cmdName]
                                        if cc and #cc > 0 then
                                            defenseFireActivated(cc)
                                            defenseFireActivated(profileConns)
                                            task.wait(0.05)
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
    stopAntiIntruder = function()
        if antiIntruderConn then antiIntruderConn:Disconnect(); antiIntruderConn = nil end
    end
end
local _autoTPUnlockDebounce = false
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        obj.OnClientEvent:Connect(function(...)
            if AutoDefenseEnabled then
                for _, arg in ipairs({...}) do
                    if type(arg) == "string"and string.find(string.lower(arg), "stealing") then
                        defenseRunDefenseCommands(); break
                    end
                end
            end
            if SS.autoTPUnlockState and not _autoTPUnlockDebounce then
                for _, arg in ipairs({...}) do
                    if type(arg) == "string"and string.find(string.lower(arg), "you successfully broke", 1, true) then
                        _autoTPUnlockDebounce = true
                        task.spawn(function()
                            task.wait(0.20)
                            SS.SSExecute()
                            task.wait(1.5)
                            _autoTPUnlockDebounce = false
                        end)
                        break
                    end
                end
            end
        end)
    end
end
task.spawn(function()
    local STEAL_ATTRS = {"Stealing","steal","stolen","isStealing","IsSteal","issteal"}
    local function onWarnSoundFired()
        if not AutoDefenseEnabled then return end
        local target = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                for _, attr in ipairs(STEAL_ATTRS) do
                    if plr:GetAttribute(attr) then
                        target = plr
                        break
                    end
                end
                if target then break end
            end
        end
        if target then
            task.spawn(function() defenseExecuteCommandsOnPlayer(target, {"balloon"}) end)
        end
    end
    local function tryConnectWarnSound(obj)
        if obj:IsA("Sound") and obj.Name:lower() == "warn"then
            obj.Played:Connect(onWarnSoundFired)
        end
    end
    task.spawn(function()
        task.wait(1)

        local _step = 0
        for _, desc in ipairs(game:GetDescendants()) do
            pcall(tryConnectWarnSound, desc)
            _step = _step + 1
            if _step % 500 == 0 then task.wait() end
        end
        game.DescendantAdded:Connect(function(obj) pcall(tryConnectWarnSound, obj) end)
    end)
end)
FD.W = isMobile and 170 or 200; FD.H = isMobile and 110 or 116
FD.minimized  = false
FD.dragging   = false
FD.dragStart  = nil
FD.panelStart = nil
FD.FDBorderFrame = Instance.new("Frame")
FD.FDBorderFrame.Name             = "FadedDefenseGradBorder"
FD.FDBorderFrame.Size             = UDim2.new(0, FD.W + 4, 0, FD.H + 4)
FD.FDBorderFrame.Position         = UDim2.new(1, -(FD.W + 4 + 16), 1, -(FD.H + 4 + FA.H + 36))
FD.FDBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FD.FDBorderFrame.BorderSizePixel  = 0
FD.FDBorderFrame.ZIndex           = 18
FD.FDBorderFrame.Visible          = false
FD.FDBorderFrame.Parent           = GUI
FD.FDBorderFrame.BackgroundTransparency = 1
Corner(FD.FDBorderFrame, 12)
FD.FDWin = Instance.new("Frame")
FD.FDWin.Name             = "FadedDefensePanel"
FD.FDWin.Size             = UDim2.new(0, FD.W, 0, FD.H)
FD.FDWin.Position         = UDim2.new(1, -(FD.W + 18), 1, -(FD.H + FA.H + 20))
FD.FDWin.BackgroundColor3 = T.BG
FD.FDWin.BackgroundTransparency = 0.25
FD.FDWin.BorderSizePixel  = 0
FD.FDWin.ZIndex           = 19
FD.FDWin.Visible          = false
FD.FDWin.ClipsDescendants = true
FD.FDWin.Parent           = GUI
Corner(FD.FDWin, 10)
FD.FDHdr = Instance.new("Frame")
FD.FDHdr.Size             = UDim2.new(1, 0, 0, 26)
FD.FDHdr.BackgroundColor3 = T.Card
FD.FDHdr.BackgroundTransparency = 0.2
FD.FDHdr.BorderSizePixel  = 0
FD.FDHdr.ZIndex           = 20
FD.FDHdr.Parent           = FD.FDWin
Corner(FD.FDHdr, 10)
FD.FDHdr.Active = true
FD.FDHdrFill = Instance.new("Frame")
FD.FDHdrFill.Size             = UDim2.new(1, 0, 0, 8)
FD.FDHdrFill.Position         = UDim2.new(0, 0, 1, -8)
FD.FDHdrFill.BackgroundColor3 = T.Card
FD.FDHdrFill.BackgroundTransparency = 0.2
FD.FDHdrFill.BorderSizePixel  = 0
FD.FDHdrFill.ZIndex           = 20
FD.FDHdrFill.Parent           = FD.FDHdr
FD.FDHdrLine = Instance.new("Frame")
FD.FDHdrLine.Size             = UDim2.new(1, 0, 0, 1)
FD.FDHdrLine.Position         = UDim2.new(0, 0, 1, -1)
FD.FDHdrLine.BackgroundColor3 = T.Border
FD.FDHdrLine.BorderSizePixel  = 0
FD.FDHdrLine.ZIndex           = 21
FD.FDHdrLine.Parent           = FD.FDHdr
FD.FDTitleLbl = Label(FD.FDHdr, "Faded Defense", 11, T.White, Enum.Font.GothamBold)
FD.FDTitleLbl.Size           = UDim2.new(1, -40, 1, 0)
FD.FDTitleLbl.Position       = UDim2.new(0, 12, 0, 0)
FD.FDTitleLbl.TextYAlignment = Enum.TextYAlignment.Center
FD.FDTitleLbl.ZIndex         = 22
FD.FDMinBtn = Instance.new("TextButton")
FD.FDMinBtn.Size             = UDim2.new(0, 18, 0, 18)
FD.FDMinBtn.Position         = UDim2.new(1, -22, 0.5, -9)
FD.FDMinBtn.BackgroundColor3 = T.Card
FD.FDMinBtn.BorderSizePixel  = 0
FD.FDMinBtn.Text             = "\226\136\146"
FD.FDMinBtn.TextSize         = 13
FD.FDMinBtn.Font             = Enum.Font.GothamBold
FD.FDMinBtn.TextColor3       = T.White
FD.FDMinBtn.ZIndex           = 23
FD.FDMinBtn.Parent           = FD.FDHdr
Corner(FD.FDMinBtn, 6)
Stroke(FD.FDMinBtn, T.Border, 1)
FD.FDSettingsBtn = Instance.new("TextButton")
FD.FDSettingsBtn.Size             = UDim2.new(0, 18, 0, 18)
FD.FDSettingsBtn.Position         = UDim2.new(1, -44, 0.5, -9)
FD.FDSettingsBtn.BackgroundColor3 = T.Card
FD.FDSettingsBtn.BorderSizePixel  = 0
FD.FDSettingsBtn.Text             = "\226\154\153"
FD.FDSettingsBtn.TextSize         = 13
FD.FDSettingsBtn.Font             = Enum.Font.GothamBold
FD.FDSettingsBtn.TextColor3       = T.White
FD.FDSettingsBtn.ZIndex           = 23
FD.FDSettingsBtn.Parent           = FD.FDHdr
Corner(FD.FDSettingsBtn, 6)
Stroke(FD.FDSettingsBtn, T.Border, 1)
FD.FDScroll = Instance.new("Frame")
FD.FDScroll.Size                  = UDim2.new(1, 0, 1, -26)
FD.FDScroll.Position              = UDim2.new(0, 0, 0, 26)
FD.FDScroll.BackgroundTransparency = 1
FD.FDScroll.BorderSizePixel       = 0
FD.FDScroll.ClipsDescendants      = false
FD.FDScroll.ZIndex                = 19
FD.FDScroll.Parent                = FD.FDWin
do
    local layout = Instance.new("UIListLayout")
    layout.FillDirection       = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding             = UDim.new(0, 4)
    layout.Parent              = FD.FDScroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentH = layout.AbsoluteContentSize.Y + 14
        FD.H = 26 + contentH
        if FD.FDWin and FD.FDWin.Visible then
            FD.FDWin.Size             = UDim2.new(0, FD.W, 0, FD.H)
            FD.FDBorderFrame.Size     = UDim2.new(0, FD.W + 4, 0, FD.H + 4)
        end
    end)
    Padding(FD.FDScroll, 6, 6, 6, 6)
end
end)
local function FD_CreateToggle(name, desc, cb)
    local state   = (Config.toggles and Config.toggles[name] == true) or false
    local cardH   = 22
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, -8, 0, cardH)
    card.BackgroundColor3 = T.Card
    card.BorderSizePixel  = 0
    card.Parent           = FD.FDScroll
    Corner(card, 6)
    local cStroke = Stroke(card, T.Border, 1)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 2, 0, cardH - 8)
    bar.Position         = UDim2.new(0, 0, 0, 4)
    bar.BackgroundColor3 = T.TrackOff
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 2
    bar.Parent           = card
    Corner(bar, 1)
    local nameLbl = Label(card, name, 10, T.White, Enum.Font.GothamMedium)
    nameLbl.Size          = UDim2.new(1, -30, 1, 0)
    nameLbl.Position      = UDim2.new(0, 8, 0, 0)
    nameLbl.ZIndex        = 2
    nameLbl.TextXAlignment= Enum.TextXAlignment.Left
    nameLbl.TextYAlignment= Enum.TextYAlignment.Center
    nameLbl.TextTruncate  = Enum.TextTruncate.AtEnd
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 28, 0, 16)
    track.Position         = UDim2.new(1, -24, 0.5, -6)
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
    local btn = Instance.new("Frame")
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.ZIndex                 = 4
    btn.Active                 = true
    btn.Parent                 = card
    local function fdApplyVisual(s)
        if s then
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.Position         = UDim2.new(0, 14, 0.5, -6)
            knob.BackgroundColor3 = T.KnobOn
            track.BackgroundColor3 = T.TrackOn
            tStroke.Color         = T.TrackOn
            bar.BackgroundColor3  = T.White
        else
            knob.Size             = UDim2.new(0, 12, 0, 12)
            knob.Position         = UDim2.new(0, 2, 0.5, -6)
            knob.BackgroundColor3 = T.KnobOff
            track.BackgroundColor3 = T.TrackOff
            tStroke.Color         = T.Border
            bar.BackgroundColor3  = T.TrackOff
        end
    end
    local function doToggle()
        state = not state
        if state then
            Tween(knob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
            Tween(knob,    M, {BackgroundColor3 = T.KnobOn})
            Tween(track,   M, {BackgroundColor3 = T.TrackOn})
            Tween(tStroke, M, {Color = T.TrackOn})
            Tween(bar,     M, {BackgroundColor3 = T.White})
        else
            Tween(knob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
            Tween(knob,    M, {BackgroundColor3 = T.KnobOff})
            Tween(track,   M, {BackgroundColor3 = T.TrackOff})
            Tween(tStroke, M, {Color = T.Border})
            Tween(bar,     M, {BackgroundColor3 = T.TrackOff})
        end
        if cb then pcall(cb, state) end
        Config.toggles[name] = state
        pcall(FH_SaveConfig)
    end
    do
        local _fdBtnTouchStart = nil
        btn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                doToggle()
            elseif inp.UserInputType == Enum.UserInputType.Touch then
                _fdBtnTouchStart = inp.Position
            end
        end)
        btn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _fdBtnTouchStart then
                local mag = (inp.Position - _fdBtnTouchStart).Magnitude
                _fdBtnTouchStart = nil
                if mag < 20 then doToggle() end
            end
        end)
    end
    configRegistry[name] = {
        getState   = function() return state end,
        getKeyCode = function() return nil end,
        setKeyCode = function() end,
        doToggle   = doToggle,
        setEnabled = function(v)
            state = v
            fdApplyVisual(v)
            if cb then pcall(cb, v) end
            Config.toggles[name] = v
            if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
        end,
    }
end
FD_CreateToggle("Enable Steal Protection", "Fires defense on steal events", function(state)
    AutoDefenseEnabled = state
end)
FD_CreateToggle("Anti Player Intruder", "Attacks players entering your base", function(state)
    AntiTPEnabled_state = state
    if state then startAntiIntruder() else stopAntiIntruder() end
end)

do
    local _skConn = nil
    local function _skIsCmdAvailable(cmdName)
        local lp = Players.LocalPlayer
        local ap = lp and lp.PlayerGui and lp.PlayerGui:FindFirstChild("AdminPanel")
        if not ap then return false end
        local inner = ap:FindFirstChild("AdminPanel"); if not inner then return false end
        local content = inner:FindFirstChild("Content"); if not content then return false end
        local sf = content:FindFirstChild("ScrollingFrame"); if not sf then return false end
        local f = sf:FindFirstChild(cmdName)
        if not f then return false end
        local t = f:FindFirstChild("Timer")
        if t and t.Visible == true then return false end
        return true
    end
    local function _skStart()
        if _skConn then return end
        _skConn = task.spawn(function()
            while kickNoCmdsEnabled do
                task.wait(1.5)
                if not kickNoCmdsEnabled then break end
                local balloonOK = _skIsCmdAvailable("balloon")
                local ragdollOK = _skIsCmdAvailable("ragdoll")
                if (not balloonOK) and (not ragdollOK) then
                    pcall(function()
                        Players.LocalPlayer:Kick("Safety Kick: balloon & ragdoll both unavailable")
                    end)
                    break
                end
            end
            _skConn = nil
        end)
    end
    local function _skStop()
        kickNoCmdsEnabled = false
        _skConn = nil
    end
    FD_CreateToggle("Safety Kick", "Kick if no leftover cmds.", function(state)
        kickNoCmdsEnabled = state
        if state then _skStart() else _skStop() end
    end)
end

;(function()
    local FD_AVAILABLE_CMDS = { "balloon", "jail", "tiny", "rocket", "ragdoll" }

    local function _split(s)
        local out = {}
        if type(s) ~= "string" then return out end
        for word in string.gmatch(s, "([^,%s]+)") do
            table.insert(out, word:lower())
        end
        return out
    end
    local function _join(t)
        return table.concat(t or {}, ",")
    end
    local function _setToList(set)
        local out = {}
        for _, name in ipairs(FD_AVAILABLE_CMDS) do
            if set[name] then table.insert(out, name) end
        end
        return out
    end
    local function _listToSet(list)
        local out = {}
        for _, n in ipairs(list or {}) do out[n] = true end
        return out
    end

    local savedP1     = _FH_SavedConfig and _FH_SavedConfig.sliders and _FH_SavedConfig.sliders.defense_cmds_p1
    local savedP2     = _FH_SavedConfig and _FH_SavedConfig.sliders and _FH_SavedConfig.sliders.defense_cmds_p2
    local legacy      = _FH_SavedConfig and _FH_SavedConfig.sliders and _FH_SavedConfig.sliders.defense_cmds
    local p1Set       = _listToSet(_split(savedP1 or legacy or "balloon,jail"))
    local p2Set       = _listToSet(_split(savedP2 or ""))

    for name in pairs(p1Set) do p2Set[name] = nil end

    local function publish()
        _G._FH_DefenseCmdsP1 = _setToList(p1Set)
        _G._FH_DefenseCmdsP2 = _setToList(p2Set)

        local merged = {}
        for _, n in ipairs(_G._FH_DefenseCmdsP1) do table.insert(merged, n) end
        for _, n in ipairs(_G._FH_DefenseCmdsP2) do table.insert(merged, n) end
        _G._FH_DefenseCmds = merged
        Config.sliders = Config.sliders or {}
        Config.sliders.defense_cmds_p1 = _join(_G._FH_DefenseCmdsP1)
        Config.sliders.defense_cmds_p2 = _join(_G._FH_DefenseCmdsP2)
        pcall(FH_SaveConfig)
    end
    publish()

    FD.FDSettings = Instance.new("Frame")
    FD.FDSettings.Size                  = UDim2.new(1, 0, 1, -26)
    FD.FDSettings.Position              = UDim2.new(0, 0, 0, 26)
    FD.FDSettings.BackgroundColor3      = T.BG
    FD.FDSettings.BackgroundTransparency = 0
    FD.FDSettings.BorderSizePixel       = 0
    FD.FDSettings.Visible               = false
    FD.FDSettings.ZIndex                = 30
    FD.FDSettings.Parent                = FD.FDWin

    local settingsHdr = Instance.new("Frame")
    settingsHdr.Size                  = UDim2.new(1, 0, 0, 30)
    settingsHdr.Position              = UDim2.new(0, 0, 0, 0)
    settingsHdr.BackgroundColor3      = T.Card
    settingsHdr.BackgroundTransparency = 0.35
    settingsHdr.BorderSizePixel       = 0
    settingsHdr.ZIndex                = 31
    settingsHdr.Parent                = FD.FDSettings
    Corner(settingsHdr, 6)
    do
        local hdrLine = Instance.new("Frame")
        hdrLine.Size                  = UDim2.new(1, -8, 0, 1)
        hdrLine.Position              = UDim2.new(0, 4, 1, -1)
        hdrLine.BackgroundColor3      = T.Border
        hdrLine.BackgroundTransparency = 0.5
        hdrLine.BorderSizePixel       = 0
        hdrLine.ZIndex                = 32
        hdrLine.Parent                = settingsHdr
    end

    local backBtn = Instance.new("TextButton")
    backBtn.Size             = UDim2.new(0, 54, 0, 20)
    backBtn.Position         = UDim2.new(0, 6, 0.5, -10)
    backBtn.BackgroundColor3 = T.Card
    backBtn.BorderSizePixel  = 0
    backBtn.Text             = "\226\134\144 Back"
    backBtn.TextSize         = 11
    backBtn.Font             = Enum.Font.GothamBold
    backBtn.TextColor3       = T.White
    backBtn.AutoButtonColor  = false
    backBtn.ZIndex           = 33
    backBtn.Parent           = settingsHdr
    Corner(backBtn, 5)
    local backStroke = Stroke(backBtn, T.Border, 1)
    backBtn.MouseEnter:Connect(function()
        Tween(backBtn,    F, {BackgroundColor3 = T.CardHover})
        Tween(backStroke, F, {Color = T.BorderHover})
    end)
    backBtn.MouseLeave:Connect(function()
        Tween(backBtn,    F, {BackgroundColor3 = T.Card})
        Tween(backStroke, F, {Color = T.Border})
    end)

    local sTitle = Label(settingsHdr, "Settings", 12, T.White, Enum.Font.GothamBold)
    sTitle.Size           = UDim2.new(1, -76, 1, 0)
    sTitle.Position       = UDim2.new(0, 66, 0, 0)
    sTitle.TextXAlignment = Enum.TextXAlignment.Left
    sTitle.TextYAlignment = Enum.TextYAlignment.Center
    sTitle.TextTruncate   = Enum.TextTruncate.AtEnd
    sTitle.ZIndex         = 32

    local sScroll = Instance.new("ScrollingFrame")
    sScroll.Size                  = UDim2.new(1, -8, 1, -36)
    sScroll.Position              = UDim2.new(0, 4, 0, 32)
    sScroll.BackgroundTransparency = 1
    sScroll.BorderSizePixel       = 0
    sScroll.ScrollBarThickness    = 3
    sScroll.ScrollBarImageColor3  = T.Border
    sScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    sScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sScroll.ScrollingDirection    = Enum.ScrollingDirection.Y
    sScroll.ZIndex                = 31
    sScroll.Parent                = FD.FDSettings
    local sLayout = Instance.new("UIListLayout")
    sLayout.Padding             = UDim.new(0, 5)
    sLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sLayout.Parent              = sScroll

    local rowRefs = {}

    local function applyLockState()
        for name, refs in pairs(rowRefs) do
            local p1Has = p1Set[name] == true
            local p2Has = p2Set[name] == true
            local function paint(prefix, has, locked)
                local row     = refs[prefix .. "Row"]
                if not row then return end
                local track   = refs[prefix .. "Track"]
                local knob    = refs[prefix .. "Knob"]
                local tStroke = refs[prefix .. "TStroke"]
                local lock    = refs[prefix .. "Lock"]
                local lbl     = refs[prefix .. "Lbl"]
                if locked then
                    row.BackgroundTransparency = 0.55
                    lbl.TextColor3             = T.Dim
                    lock.Visible               = true
                    track.Visible              = false
                else
                    row.BackgroundTransparency = 0.18
                    lbl.TextColor3             = T.White
                    lock.Visible               = false
                    track.Visible              = true
                    if has then
                        track.BackgroundColor3 = T.TrackOn
                        knob.BackgroundColor3  = T.KnobOn
                        knob.Position          = UDim2.new(1, -14, 0.5, -6)
                        tStroke.Color          = T.TrackOn
                    else
                        track.BackgroundColor3 = T.TrackOff
                        knob.BackgroundColor3  = T.KnobOff
                        knob.Position          = UDim2.new(0, 2, 0.5, -6)
                        tStroke.Color          = T.Border
                    end
                end
                refs[prefix .. "Locked"] = locked
            end
            paint("p1", p1Has, p2Has)
            paint("p2", p2Has, p1Has)
        end
    end

    local function addSectionHeader(text, order)
        local h = Instance.new("Frame")
        h.Name                  = "Section_" .. text
        h.Size                  = UDim2.new(1, -10, 0, 22)
        h.BackgroundTransparency = 1
        h.LayoutOrder           = order
        h.Parent                = sScroll
        local bar = Instance.new("Frame")
        bar.Size              = UDim2.new(0, 3, 0, 14)
        bar.Position          = UDim2.new(0, 2, 0.5, -7)
        bar.BackgroundColor3  = _G._FH_AccentA or Color3.fromRGB(120, 200, 255)
        bar.BorderSizePixel   = 0
        bar.Parent            = h
        Corner(bar, 2)
        local lbl = Label(h, text, isMobile and 11 or 12, T.White, Enum.Font.GothamBold)
        lbl.Size           = UDim2.new(1, -14, 1, 0)
        lbl.Position       = UDim2.new(0, 10, 0, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function addCmdRow(slot, cmdName, order)
        local row = Instance.new("Frame")
        row.Name                   = slot .. "_" .. cmdName
        row.Size                   = UDim2.new(1, -10, 0, isMobile and 30 or 28)
        row.BackgroundColor3       = T.Card
        row.BackgroundTransparency = 0.18
        row.BorderSizePixel        = 0
        row.LayoutOrder            = order
        row.Parent                 = sScroll
        Corner(row, 6)
        local rStroke = Stroke(row, T.Border, 1)

        local hit = Instance.new("TextButton")
        hit.Size                   = UDim2.new(1, 0, 1, 0)
        hit.BackgroundTransparency = 1
        hit.Text                   = ""
        hit.AutoButtonColor        = false
        hit.ZIndex                 = 2
        hit.Parent                 = row

        local lbl = Label(row, cmdName, isMobile and 11 or 12, T.White, Enum.Font.GothamMedium)
        lbl.Size           = UDim2.new(1, -54, 1, 0)
        lbl.Position       = UDim2.new(0, 10, 0, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local track = Instance.new("Frame")
        track.Size             = UDim2.new(0, 32, 0, 16)
        track.Position         = UDim2.new(1, -38, 0.5, -8)
        track.BackgroundColor3 = T.TrackOff
        track.BorderSizePixel  = 0
        track.ZIndex           = 3
        track.Parent           = row
        Corner(track, 8)
        local tStroke = Stroke(track, T.Border, 1)
        local knob = Instance.new("Frame")
        knob.Size             = UDim2.new(0, 12, 0, 12)
        knob.Position         = UDim2.new(0, 2, 0.5, -6)
        knob.BackgroundColor3 = T.KnobOff
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 4
        knob.Parent           = track
        Corner(knob, 6)

        local lockLbl = Instance.new("TextLabel")
        lockLbl.Size                   = UDim2.new(0, 20, 0, 16)
        lockLbl.Position               = UDim2.new(1, -26, 0.5, -8)
        lockLbl.BackgroundTransparency = 1
        lockLbl.Text                   = "\240\159\148\146"
        lockLbl.TextSize               = 12
        lockLbl.Font                   = Enum.Font.Gotham
        lockLbl.TextColor3             = T.Dim
        lockLbl.Visible                = false
        lockLbl.ZIndex                 = 3
        lockLbl.Parent                 = row

        rowRefs[cmdName] = rowRefs[cmdName] or {}
        local refs = rowRefs[cmdName]
        refs[slot .. "Row"]     = row
        refs[slot .. "Track"]   = track
        refs[slot .. "Knob"]    = knob
        refs[slot .. "TStroke"] = tStroke
        refs[slot .. "Lock"]    = lockLbl
        refs[slot .. "Lbl"]     = lbl
        refs[slot .. "RStroke"] = rStroke

        local function doClick()
            if slot == "p1" then
                if refs.p1Locked then return end
                p1Set[cmdName] = (not p1Set[cmdName]) or nil
            else
                if refs.p2Locked then return end
                p2Set[cmdName] = (not p2Set[cmdName]) or nil
            end
            local on = (slot == "p1" and p1Set[cmdName]) or (slot == "p2" and p2Set[cmdName])
            local knobTween = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
            if on then
                Tween(track,   F, {BackgroundColor3 = T.TrackOn})
                Tween(knob,    knobTween, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = T.KnobOn})
                Tween(tStroke, F, {Color = T.TrackOn})
            else
                Tween(track,   F, {BackgroundColor3 = T.TrackOff})
                Tween(knob,    knobTween, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = T.KnobOff})
                Tween(tStroke, F, {Color = T.Border})
            end
            applyLockState()
            publish()
        end
        hit.MouseButton1Click:Connect(doClick)
        hit.MouseEnter:Connect(function()
            if refs[slot .. "Locked"] then return end
            Tween(row,     F, {BackgroundColor3 = T.CardHover})
            Tween(rStroke, F, {Color = T.BorderHover})
        end)
        hit.MouseLeave:Connect(function()
            Tween(row,     F, {BackgroundColor3 = T.Card})
            Tween(rStroke, F, {Color = T.Border})
        end)
        do
            local touchStart = nil
            hit.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    touchStart = inp.Position
                end
            end)
            hit.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch and touchStart then
                    local mag = (inp.Position - touchStart).Magnitude
                    touchStart = nil
                    if mag < 20 then doClick() end
                end
            end)
        end
    end

    local order = 1
    addSectionHeader("Player 1 Commands", order); order = order + 1
    for _, name in ipairs(FD_AVAILABLE_CMDS) do
        addCmdRow("p1", name, order); order = order + 1
    end
    addSectionHeader("Player 2 Commands", order); order = order + 1
    for _, name in ipairs(FD_AVAILABLE_CMDS) do
        addCmdRow("p2", name, order); order = order + 1
    end
    applyLockState()

    local function openSettings()
        if FD.minimized then return end
        if FD.FDSettings.Visible then return end
        FD.FDSettings.Visible = true
        FD.FDScroll.Visible   = false

        local targetH = math.max(FD.H, 320)
        FD.H = targetH
        FD.FDWin.Size         = UDim2.new(0, FD.W, 0, targetH)
        FD.FDBorderFrame.Size = UDim2.new(0, FD.W + 4, 0, targetH + 4)
    end
    local function closeSettings()
        if not FD.FDSettings.Visible then return end
        FD.FDSettings.Visible = false
        if FD.minimized then return end
        FD.FDScroll.Visible = true

        local scrollLayout = FD.FDScroll:FindFirstChildOfClass("UIListLayout")
        local naturalH = (scrollLayout and scrollLayout.AbsoluteContentSize.Y or 0) + 20 + 26
        FD.H = naturalH
        FD.FDWin.Size         = UDim2.new(0, FD.W, 0, naturalH)
        FD.FDBorderFrame.Size = UDim2.new(0, FD.W + 4, 0, naturalH + 4)
    end
    FD.FDSettingsBtn.MouseButton1Click:Connect(openSettings)
    backBtn.MouseButton1Click:Connect(closeSettings)

    FD.FDMinBtn.MouseButton1Click:Connect(function()
        if FD.FDSettings.Visible then closeSettings() end
    end)
end)()
do
    FD.FDHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            FD.dragging   = true
            FD.dragStart  = inp.Position
            FD.panelStart = FD.FDWin.Position
        end
    end)
    FD.FDHdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            FD.dragging = false
            Config.mini = Config.mini or {}
            Config.mini.fd_pos = { x = FD.FDWin.Position.X.Offset, y = FD.FDWin.Position.Y.Offset,
                                   xs = FD.FDWin.Position.X.Scale, ys = FD.FDWin.Position.Y.Scale }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if FD.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - FD.dragStart
            local newPos = UDim2.new(
                FD.panelStart.X.Scale, FD.panelStart.X.Offset + d.X,
                FD.panelStart.Y.Scale, FD.panelStart.Y.Offset + d.Y
            )
            FD.FDWin.Position         = newPos
            FD.FDBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
        end
    end)
end
FD.FDMinBtn.MouseButton1Click:Connect(function()
    FD.minimized = not FD.minimized
    if FD.minimized then
        FD.FDWin.ClipsDescendants = false
        FD.FDHdrFill.Visible = false
        FD.FDHdrLine.Visible = false
        FD.FDScroll.Visible  = false
        Tween(FD.FDWin,         M, {Size = UDim2.new(0, FD.W, 0, 26)})
        Tween(FD.FDBorderFrame, M, {Size = UDim2.new(0, FD.W + 4, 0, 30)})
        FD.FDMinBtn.Text = "+"else
        FD.FDHdrFill.Visible = true
        FD.FDHdrLine.Visible = true
        Tween(FD.FDWin,         M, {Size = UDim2.new(0, FD.W, 0, FD.H)})
        Tween(FD.FDBorderFrame, M, {Size = UDim2.new(0, FD.W + 4, 0, FD.H + 4)})
        FD.FDMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            FD.FDScroll.Visible = true
            FD.FDWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.fd_min = FD.minimized
        pcall(FH_SaveConfig)
    end
end)
FD.setFadedDefenseVisible = function(vis)
    FD.FDWin.Visible         = vis
    FD.FDBorderFrame.Visible = vis
    if vis then
        local p = FD.FDWin.Position
        FD.FDBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if FD.minimized then
            FD.FDMinBtn.Text      = "+"
FD.FDScroll.Visible   = false
            FD.FDHdrFill.Visible  = false
            FD.FDHdrLine.Visible  = false
            FD.FDWin.ClipsDescendants = false
            FD.FDWin.Size         = UDim2.new(0, FD.W, 0, 26)
            FD.FDBorderFrame.Size = UDim2.new(0, FD.W + 4, 0, 40)
        else
            FD.FDMinBtn.Text      = "\226\136\146"
FD.FDScroll.Visible   = true
            FD.FDHdrFill.Visible  = true
            FD.FDHdrLine.Visible  = true
            FD.FDWin.ClipsDescendants = true
            FD.FDWin.Size         = UDim2.new(0, FD.W, 0, FD.H)
            FD.FDBorderFrame.Size = UDim2.new(0, FD.W + 4, 0, FD.H + 4)
        end
    end
end

local function _qpVPx()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize and cam.ViewportSize.X) or 800
end
local function _qpVPy()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize and cam.ViewportSize.Y) or 600
end
function QP.computeMetrics()
    local vpx, vpy = _qpVPx(), _qpVPy()
    if isMobile then
        local w = math.clamp(math.floor(vpx - 32), 220, 440)
        QP.W       = w
        QP.H       = 64
        QP.ROW_H   = 38
        QP.EXPANDED_H = math.clamp(math.floor(vpy * 0.5), 140, 220)
    else
        QP.W       = 410
        QP.H       = 76
        QP.ROW_H   = 46
        QP.EXPANDED_H = 260
    end
end
QP.computeMetrics()
QP.minimized  = false
QP.dragging   = false
QP.dragStart  = nil
QP.panelStart = nil
;(function()
local QP_CMDS = {
    { name = "tiny",    emoji = "\xF0\x9F\xA4\x8F"},
    { name = "jail",    emoji = "\xF0\x9F\x94\x92"},
    { name = "rocket",  emoji = "\xF0\x9F\x9A\x80"},
    { name = "ragdoll", emoji = "\xF0\x9F\x8F\x83"},
    { name = "balloon", emoji = "\xF0\x9F\x8E\x88"},
}
local QP_cooldownBtns = {}
for _, c in ipairs(QP_CMDS) do QP_cooldownBtns[c.name] = {} end
local QP_commandCache = {}
local QP_profileCache = {}
QP.QPBorderFrame = Instance.new("Frame")
QP.QPBorderFrame.Name             = "QuickPanelGradBorder"
QP.QPBorderFrame.Size             = UDim2.new(0, QP.W + 4, 0, QP.H + 4)
QP.QPBorderFrame.Position         = UDim2.new(0, 14, 0.55, -2)
QP.QPBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
QP.QPBorderFrame.BorderSizePixel  = 0
QP.QPBorderFrame.ZIndex           = 18
QP.QPBorderFrame.Visible          = false
QP.QPBorderFrame.Parent           = GUI
QP.QPBorderFrame.BackgroundTransparency = 1
Corner(QP.QPBorderFrame, 12)
QP.QPWin = Instance.new("Frame")
QP.QPWin.Name             = "QuickPanel"
QP.QPWin.Size             = UDim2.new(0, QP.W, 0, QP.H)
QP.QPWin.Position         = UDim2.new(0, 16, 0.55, 0)
QP.QPWin.BackgroundColor3 = T.BG
QP.QPWin.BorderSizePixel  = 0
QP.QPWin.ZIndex           = 19
QP.QPWin.Visible          = false
QP.QPWin.ClipsDescendants = true
QP.QPWin.Parent           = GUI
QP.QPWin.BackgroundTransparency = 0.25
Corner(QP.QPWin, 10)
QP.QPHdr = Instance.new("Frame")
QP.QPHdr.Size             = UDim2.new(1, 0, 0, 28)
QP.QPHdr.BackgroundColor3 = T.Header
QP.QPHdr.BorderSizePixel  = 0
QP.QPHdr.ZIndex           = 20
QP.QPHdr.Parent           = QP.QPWin
QP.QPHdr.BackgroundTransparency = 0.2
Corner(QP.QPHdr, 10)
QP.QPHdr.Active = true
QP.QPHdrFill = Instance.new("Frame")
QP.QPHdrFill.Size             = UDim2.new(1, 0, 0, 10)
QP.QPHdrFill.Position         = UDim2.new(0, 0, 1, -10)
QP.QPHdrFill.BackgroundColor3       = T.Header
QP.QPHdrFill.BackgroundTransparency = 0.2
QP.QPHdrFill.BorderSizePixel        = 0
QP.QPHdrFill.ZIndex           = 20
QP.QPHdrFill.Parent           = QP.QPHdr
QP.QPHdrLine = Instance.new("Frame")
QP.QPHdrLine.Size             = UDim2.new(1, 0, 0, 1)
QP.QPHdrLine.Position         = UDim2.new(0, 0, 1, -1)
QP.QPHdrLine.BackgroundColor3 = T.Border
QP.QPHdrLine.BorderSizePixel  = 0
QP.QPHdrLine.ZIndex           = 21
QP.QPHdrLine.Parent           = QP.QPHdr
do
local QPTitleLbl = Label(QP.QPHdr, "Quick Panel", 11, T.White, Enum.Font.GothamBold)
QPTitleLbl.Size           = UDim2.new(1, -40, 1, 0)
QPTitleLbl.Position       = UDim2.new(0, 12, 0, 0)
QPTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
QPTitleLbl.TextYAlignment = Enum.TextYAlignment.Center
QPTitleLbl.ZIndex         = 22
end
QP.QPMinBtn = Instance.new("TextButton")
QP.QPMinBtn.Size             = UDim2.new(0, 18, 0, 18)
QP.QPMinBtn.Position         = UDim2.new(1, -24, 0.5, -9)
QP.QPMinBtn.BackgroundColor3 = T.Card
QP.QPMinBtn.BorderSizePixel  = 0
QP.QPMinBtn.Text             = "\226\136\146"
QP.QPMinBtn.TextSize         = 14
QP.QPMinBtn.Font             = Enum.Font.GothamBold
QP.QPMinBtn.TextColor3       = T.White
QP.QPMinBtn.ZIndex           = 23
QP.QPMinBtn.Parent           = QP.QPHdr
Corner(QP.QPMinBtn, 6)
Stroke(QP.QPMinBtn, T.Border, 1)
QP.QPScroll = Instance.new("ScrollingFrame")
QP.QPScroll.Size                  = UDim2.new(1, -12, 1, -34)
QP.QPScroll.Position              = UDim2.new(0, 6, 0, 32)
QP.QPScroll.BackgroundTransparency = 1
QP.QPScroll.BorderSizePixel       = 0
QP.QPScroll.ScrollBarThickness    = 3
QP.QPScroll.ScrollBarImageColor3  = T.Border
QP.QPScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
QP.QPScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
QP.QPScroll.ScrollingDirection    = Enum.ScrollingDirection.Y
QP.QPScroll.ZIndex                = 19
QP.QPScroll.Parent                = QP.QPWin
QP.QPLayout = Instance.new("UIListLayout")
QP.QPLayout.Padding             = UDim.new(0, 3)
QP.QPLayout.SortOrder           = Enum.SortOrder.LayoutOrder
QP.QPLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
QP.QPLayout.Parent              = QP.QPScroll
QP.QPLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    QP.QPScroll.CanvasSize = UDim2.new(0, 0, 0, QP.QPLayout.AbsoluteContentSize.Y + 6)
end)
Padding(QP.QPScroll, 4, 4, 0, 0)
QP.QPNoTarget = Instance.new("TextLabel")
QP.QPNoTarget.Size                   = UDim2.new(1, -20, 0, 24)
QP.QPNoTarget.Position               = UDim2.new(0, 10, 0, 34)
QP.QPNoTarget.BackgroundTransparency = 1
QP.QPNoTarget.Text                   = "No players found"
QP.QPNoTarget.Font                   = Enum.Font.GothamMedium
QP.QPNoTarget.TextColor3             = T.Dim
QP.QPNoTarget.TextSize               = 12
QP.QPNoTarget.TextXAlignment         = Enum.TextXAlignment.Center
QP.QPNoTarget.Visible                = true
QP.QPNoTarget.ZIndex                 = 20
QP.QPNoTarget.Parent                 = QP.QPWin
local function qpGetAdminSF()
    local ok, sf = pcall(function()
        return Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame
    end)
    return ok and sf or nil
end
local function qpIsOnCooldown(cmdName)
    local sf = qpGetAdminSF()
    if not sf then return false end
    local f = sf:FindFirstChild(cmdName)
    if not f then return false end
    local t = f:FindFirstChild("Timer")
    return t and t.Visible == true
end
local function qpGetCDText(cmdName)
    local sf = qpGetAdminSF()
    if not sf then return nil end
    local f = sf:FindFirstChild(cmdName)
    if not f then return nil end
    local t = f:FindFirstChild("Timer")
    if not t or not t.Visible then return nil end
    return t.Text or ""
    end
local qpCDRunning = false
local function qpStartCDLoop()
    if qpCDRunning then return end
    qpCDRunning = true
    task.spawn(function()
        while QP.QPWin and QP.QPWin.Parent and QP.QPWin.Visible do
            for _, cmd in ipairs(QP_CMDS) do
                local onCD = qpIsOnCooldown(cmd.name)
                local txt  = onCD and qpGetCDText(cmd.name) or nil
                for _, entry in ipairs(QP_cooldownBtns[cmd.name]) do
                    local btn, emoji = entry[1], entry[2]
                    if btn and btn.Parent then
                        if onCD and txt then
                            btn.Text                   = txt
                            btn.TextSize               = 9
                            btn.TextColor3             = Color3.fromRGB(160, 160, 160)
                            btn.BackgroundTransparency = 0.55
                        else
                            btn.Text                   = emoji
                            btn.TextSize               = isMobile and 14 or 18
                            btn.TextColor3             = T.White
                            btn.BackgroundTransparency = 0.3
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        qpCDRunning = false
    end)
end
local function qpGetAdminFrames()
    local ap = Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
    if not ap then return nil, nil end
    local inner = ap:FindFirstChild("AdminPanel")
    if not inner then return nil, nil end
    local content  = inner:FindFirstChild("Content")
    local profiles = inner:FindFirstChild("Profiles")
    if not content or not profiles then return nil, nil end
    return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end
local function qpCacheActivated(guiObj)
    local cached = {}
    local ok, conns = pcall(getconnections, guiObj.Activated)
    if ok and type(conns) == "table"then
        for _, conn in ipairs(conns) do
            if type(conn.Function) == "function"then
                table.insert(cached, conn.Function)
            end
        end
    end
    return cached
end
local function qpFireActivated(cached)
    for _, fn in ipairs(cached) do task.spawn(fn) end
end
local function qpRunCommand(cmdName, target)
    local cmdFrame, profileFrame = qpGetAdminFrames()
    if not cmdFrame or not profileFrame then return end
    local profileBtn = profileFrame:FindFirstChild(target.Name)
    local commandBtn = cmdFrame:FindFirstChild(cmdName)
    if not profileBtn or not commandBtn then return end
    if not QP_profileCache[target.Name] then
        QP_profileCache[target.Name] = qpCacheActivated(profileBtn)
    end
    if not QP_commandCache[cmdName] then
        QP_commandCache[cmdName] = qpCacheActivated(commandBtn)
    end
    qpFireActivated(QP_profileCache[target.Name])
    task.wait()
    qpFireActivated(QP_commandCache[cmdName])
end
local function qpMakeRow(plr, order)
    local row = Instance.new("Frame")
    row.Name                   = "QP_".. plr.Name
    row.Size                   = UDim2.new(1, -8, 0, QP.ROW_H)
    row.BackgroundColor3       = T.Card
    row.BackgroundTransparency = isMobile and 0.35 or 0.15
    row.BorderSizePixel        = 0
    row.LayoutOrder            = order
    row.ZIndex                 = 20
    row.Parent                 = QP.QPScroll
    Corner(row, 6)
    Stroke(row, T.Border, 1)
    local displayName = plr.DisplayName
    local userName    = "@" .. plr.Name
    local avSz = isMobile and 20 or 28
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Size             = UDim2.new(0, avSz, 0, avSz)
    avatarFrame.Position         = UDim2.new(0, 4, 0.5, -avSz/2)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    avatarFrame.BorderSizePixel  = 0
    avatarFrame.ZIndex           = 21
    avatarFrame.Parent           = row
    Corner(avatarFrame, 4)
    Stroke(avatarFrame, T.Border, 1)
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        if ok and img then
            local imgLbl = Instance.new("ImageLabel")
            imgLbl.Size             = UDim2.new(1, 0, 1, 0)
            imgLbl.Image            = img
            imgLbl.BackgroundTransparency = 1
            imgLbl.ZIndex           = 22
            imgLbl.Parent           = avatarFrame
            Corner(imgLbl, 4)
        end
    end)

    local BTN_SZ  = isMobile and 30 or 40
    local BTN_GAP = isMobile and 3 or 5
    local BTN_COUNT  = #QP_CMDS
    local btnsW      = BTN_COUNT * BTN_SZ + (BTN_COUNT - 1) * BTN_GAP
    local rightPad   = 4
    local btnsHolder = Instance.new("Frame")
    btnsHolder.Name                   = "QPCmds"
    btnsHolder.BackgroundTransparency = 1
    btnsHolder.Size                   = UDim2.new(0, btnsW, 0, BTN_SZ)
    btnsHolder.Position               = UDim2.new(1, -(btnsW + rightPad), 0.5, -BTN_SZ / 2)
    btnsHolder.ZIndex                 = 21
    btnsHolder.Parent                 = row
    local btnsLayout = Instance.new("UIListLayout")
    btnsLayout.FillDirection         = Enum.FillDirection.Horizontal
    btnsLayout.Padding               = UDim.new(0, BTN_GAP)
    btnsLayout.HorizontalAlignment   = Enum.HorizontalAlignment.Right
    btnsLayout.VerticalAlignment     = Enum.VerticalAlignment.Center
    btnsLayout.SortOrder             = Enum.SortOrder.LayoutOrder
    btnsLayout.Parent                = btnsHolder
    local nameLeft = avSz + 6
    local nameW    = math.max(40, QP.W - nameLeft - btnsW - rightPad - 8)
    local nameLbl  = Label(row, displayName, isMobile and 10 or 12, T.White, Enum.Font.GothamBold)
    nameLbl.Size           = UDim2.new(0, nameW, 0.55, 0)
    nameLbl.Position       = UDim2.new(0, nameLeft, 0, 1)
    nameLbl.TextTruncate   = Enum.TextTruncate.AtEnd
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextYAlignment = Enum.TextYAlignment.Bottom
    nameLbl.ZIndex         = 21
    local userLbl  = Label(row, userName, isMobile and 8 or 10, T.Dim, Enum.Font.Gotham)
    userLbl.Size           = UDim2.new(0, nameW, 0.45, 0)
    userLbl.Position       = UDim2.new(0, nameLeft, 0.55, -1)
    userLbl.TextTruncate   = Enum.TextTruncate.AtEnd
    userLbl.TextXAlignment = Enum.TextXAlignment.Left
    userLbl.TextYAlignment = Enum.TextYAlignment.Top
    userLbl.ZIndex         = 21
    for i, cmd in ipairs(QP_CMDS) do
        local btn = Instance.new("TextButton")
        btn.Name                   = "QPCmd_".. cmd.name
        btn.Size                   = UDim2.new(0, BTN_SZ, 0, BTN_SZ)
        btn.LayoutOrder            = i
        btn.Parent                 = btnsHolder
        btn.BackgroundColor3       = T.Card
        btn.BackgroundTransparency = 0.3
        btn.Text                   = cmd.emoji
        btn.TextSize               = isMobile and 14 or 18
        btn.Font                   = Enum.Font.SourceSans
        btn.TextColor3             = T.White
        btn.AutoButtonColor        = false
        btn.ZIndex                 = 21
        Corner(btn, 4)
        Stroke(btn, T.Border, 1)
        table.insert(QP_cooldownBtns[cmd.name], { btn, cmd.emoji })
        btn.MouseEnter:Connect(function()
            if not qpIsOnCooldown(cmd.name) then
                Tween(btn, F, { BackgroundTransparency = 0, BackgroundColor3 = T.CardHover })
            end
        end)
        btn.MouseLeave:Connect(function()
            if not qpIsOnCooldown(cmd.name) then
                Tween(btn, F, { BackgroundTransparency = 0.3, BackgroundColor3 = T.Card })
            end
        end)
        local function fire()
            if qpIsOnCooldown(cmd.name) then return end
            task.spawn(function() qpRunCommand(cmd.name, plr) end)
            Tween(btn, F, { BackgroundColor3 = T.Border })
            task.delay(0.2, function() Tween(btn, F, { BackgroundColor3 = T.Card }) end)
        end
        local qpBtnDebounce = false
        local function fireSafe()
            if qpBtnDebounce then return end
            qpBtnDebounce = true
            fire()
            task.delay(0.35, function() qpBtnDebounce = false end)
        end
        if not isMobile then
            btn.MouseButton1Click:Connect(fireSafe)
        end
        do
            local _qpBtnTouchStart = nil
            btn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    _qpBtnTouchStart = inp.Position
                end
            end)
            btn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch and _qpBtnTouchStart then
                    local mag = (inp.Position - _qpBtnTouchStart).Magnitude
                    _qpBtnTouchStart = nil
                    if mag < 10 then fireSafe() end
                end
            end)
        end
    end
    return row
end
local function qpResizeToFit()
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then count = count + 1 end
    end
    local HDR      = 28
    local PAD      = 8
    local SPACING  = 3
    local rowH     = QP.ROW_H
    local maxH     = QP.EXPANDED_H
    local minH     = QP.H
    local targetH
    if count == 0 then
        targetH = minH
    else
        targetH = HDR + PAD + count * rowH + math.max(0, count - 1) * SPACING
        targetH = math.max(minH, math.min(maxH, targetH))
    end
    if math.abs(QP.QPWin.Size.Y.Offset - targetH) > 2 then
        Tween(QP.QPWin,         M, { Size = UDim2.new(0, QP.W, 0, targetH) })
        Tween(QP.QPBorderFrame, M, { Size = UDim2.new(0, QP.W + 4, 0, targetH + 4) })
    end
end
local function qpRefresh()
    for _, c in ipairs(QP_CMDS) do QP_cooldownBtns[c.name] = {} end
    for _, child in ipairs(QP.QPScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local order = 1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            qpMakeRow(plr, order)
            order = order + 1
        end
    end
    QP.QPNoTarget.Visible = (order == 1)
    QP.QPScroll.CanvasSize = UDim2.new(0, 0, 0, QP.QPLayout.AbsoluteContentSize.Y + 6)
    qpResizeToFit()
    qpStartCDLoop()
end
Players.PlayerAdded:Connect(function()
    task.wait(0.3)
    if QP.QPWin.Visible then
        qpRefresh()
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    QP_profileCache[plr.Name] = nil
    task.wait(0.3)
    if QP.QPWin.Visible then qpRefresh() end
end)

do
    local _qpResizeJob = 0
    local function _qpOnViewportChanged()
        _qpResizeJob = _qpResizeJob + 1
        local myJob = _qpResizeJob
        task.delay(0.05, function()
            if myJob ~= _qpResizeJob then return end
            QP.computeMetrics()
            local W, H = QP.W, QP.H
            QP.QPWin.Size         = UDim2.new(0, W, 0, QP.minimized and 28 or H)
            QP.QPBorderFrame.Size = UDim2.new(0, W + 4, 0, (QP.minimized and 28 or H) + 4)

            local vpx, vpy = _qpVPx(), _qpVPy()
            local p = QP.QPWin.Position
            local ax = p.X.Scale * vpx + p.X.Offset
            local ay = p.Y.Scale * vpy + p.Y.Offset
            local pad = 4
            if ax < pad then ax = pad end
            if ay < pad then ay = pad end
            if ax > vpx - W - pad then ax = vpx - W - pad end
            if ay > vpy - H - pad then ay = vpy - H - pad end
            QP.QPWin.Position         = UDim2.new(0, ax, 0, ay)
            QP.QPBorderFrame.Position = UDim2.new(0, ax - 2, 0, ay - 2)
            if QP.QPWin.Visible and not QP.minimized then qpRefresh() end
            Config.mini = Config.mini or {}
            Config.mini.qp_pos = { x = ax, y = ay, xs = 0, ys = 0 }
            pcall(FH_SaveConfig)
        end)
    end
    local function _qpHookCamera()
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(_qpOnViewportChanged)
    end
    _qpHookCamera()
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(_qpHookCamera)
end
QP.QPHdr.InputBegan:Connect(function(inp)
    if _G._FH_GUI_LOCKED then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        QP.dragging   = true
        QP.dragStart  = inp.Position
        QP.panelStart = QP.QPWin.Position
    end
end)
QP.QPHdr.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        QP.dragging = false
        Config.mini = Config.mini or {}
        Config.mini.qp_pos = { x = QP.QPWin.Position.X.Offset, y = QP.QPWin.Position.Y.Offset,
                               xs = QP.QPWin.Position.X.Scale, ys = QP.QPWin.Position.Y.Scale }
        pcall(FH_SaveConfig)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if QP.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - QP.dragStart
        local newPos = UDim2.new(
            QP.panelStart.X.Scale, QP.panelStart.X.Offset + d.X,
            QP.panelStart.Y.Scale, QP.panelStart.Y.Offset + d.Y
        )
        QP.QPWin.Position         = newPos
        QP.QPBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
    end
end)
QP.QPMinBtn.MouseButton1Click:Connect(function()
    QP.minimized = not QP.minimized
    if QP.minimized then
        QP.QPWin.ClipsDescendants = false
        QP.QPHdrFill.Visible  = false
        QP.QPHdrLine.Visible  = false
        QP.QPScroll.Visible   = false
        QP.QPNoTarget.Visible = false
        Tween(QP.QPWin,         M, { Size = UDim2.new(0, QP.W, 0, 28) })
        Tween(QP.QPBorderFrame, M, { Size = UDim2.new(0, QP.W + 4, 0, 32) })
        QP.QPMinBtn.Text = "+"
    else
        QP.QPMinBtn.Text = "\226\136\146"
        QP.QPHdrFill.Visible = true
        QP.QPHdrLine.Visible = true
        QP.QPScroll.Visible = true
        QP.QPWin.ClipsDescendants = true
        Tween(QP.QPWin,         M, { Size = UDim2.new(0, QP.W, 0, QP.H) })
        Tween(QP.QPBorderFrame, M, { Size = UDim2.new(0, QP.W + 4, 0, QP.H + 4) })
        task.defer(qpRefresh)
    end
    Config.mini = Config.mini or {}
    Config.mini.qp_min = QP.minimized
    pcall(FH_SaveConfig)
end)
QP.setQuickPanelVisible = function(vis)
    QP.QPWin.Visible         = vis
    QP.QPBorderFrame.Visible = vis
    if vis then
        local p = QP.QPWin.Position
        QP.QPBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if QP.minimized then
            QP.QPMinBtn.Text          = "+"
QP.QPScroll.Visible       = false
            QP.QPHdrFill.Visible      = false
            QP.QPHdrLine.Visible      = false
            QP.QPWin.ClipsDescendants = false
            QP.QPWin.Size             = UDim2.new(0, QP.W, 0, 28)
            QP.QPBorderFrame.Size     = UDim2.new(0, QP.W + 4, 0, 32)
        else
            QP.QPMinBtn.Text          = "\226\136\146"
QP.QPScroll.Visible       = true
            QP.QPHdrFill.Visible      = true
            QP.QPHdrLine.Visible      = true
            QP.QPWin.ClipsDescendants = true
            QP.QPWin.Size             = UDim2.new(0, QP.W, 0, QP.H)
            QP.QPBorderFrame.Size     = UDim2.new(0, QP.W + 4, 0, QP.H + 4)
            task.defer(qpRefresh)
        end
    end
end
end)()
CD.W = isMobile and 122 or 169; CD.H = isMobile and 188 or 254
CD.minimized  = false
CD.dragging   = false
CD.dragStart  = nil
CD.panelStart = nil
do
local CD_CMDS = {
    { name = "rocket",    display = "Rocket",    inGame = "rocket"},
    { name = "ragdoll",   display = "Ragdoll",   inGame = "ragdoll"},
    { name = "balloon",   display = "Balloon",   inGame = "balloon"},
    { name = "inverse",   display = "Inverse",   inGame = "inverse"},
    { name = "jail",      display = "Jail",      inGame = "jail"},
    { name = "control",   display = "Control",   inGame = "control"},
    { name = "titty",     display = "Titty",     inGame = "tiny"},
    { name = "jumpscare", display = "Jumpscare", inGame = "jumpscare"},
    { name = "morph",     display = "Morph",     inGame = "morph"},
}
CD.CDBorderFrame = Instance.new("Frame")
CD.CDBorderFrame.Name             = "CDGradBorder"
CD.CDBorderFrame.Size             = UDim2.new(0, CD.W + 4, 0, CD.H + 4)
CD.CDBorderFrame.Position         = UDim2.new(1, -(CD.W + 4 + FD.W + 36), 1, -(CD.H + 4 + FA.H + 36))
CD.CDBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CD.CDBorderFrame.BorderSizePixel  = 0
CD.CDBorderFrame.ZIndex           = 18
CD.CDBorderFrame.Visible          = false
CD.CDBorderFrame.Parent           = GUI
CD.CDBorderFrame.BackgroundTransparency = 1
Corner(CD.CDBorderFrame, 12)
CD.CDWin = Instance.new("Frame")
CD.CDWin.Name             = "CDPanel"
CD.CDWin.Size             = UDim2.new(0, CD.W, 0, CD.H)
CD.CDWin.Position         = UDim2.new(1, -(CD.W + FD.W + 20 + 18), 1, -(CD.H + FA.H + 20))
CD.CDWin.BackgroundColor3 = T.BG
CD.CDWin.BackgroundTransparency = 0.25
CD.CDWin.BorderSizePixel  = 0
CD.CDWin.ZIndex           = 19
CD.CDWin.Visible          = false
CD.CDWin.ClipsDescendants = true
CD.CDWin.Parent           = GUI
Corner(CD.CDWin, 10)
CD.CDHdr = Instance.new("Frame")
CD.CDHdr.Size             = UDim2.new(1, 0, 0, 36)
CD.CDHdr.BackgroundColor3 = T.Header
CD.CDHdr.BackgroundTransparency = 0.2
CD.CDHdr.BorderSizePixel  = 0
CD.CDHdr.ZIndex           = 20
CD.CDHdr.Parent           = CD.CDWin
Corner(CD.CDHdr, 10)
CD.CDHdr.Active = true
CD.CDHdrFill = Instance.new("Frame")
CD.CDHdrFill.Size             = UDim2.new(1, 0, 0, 10)
CD.CDHdrFill.Position         = UDim2.new(0, 0, 1, -10)
CD.CDHdrFill.BackgroundColor3 = T.Header
CD.CDHdrFill.BackgroundTransparency = 0.2
CD.CDHdrFill.BorderSizePixel  = 0
CD.CDHdrFill.ZIndex           = 20
CD.CDHdrFill.Parent           = CD.CDHdr
CD.CDHdrLine = Instance.new("Frame")
CD.CDHdrLine.Size             = UDim2.new(1, 0, 0, 1)
CD.CDHdrLine.Position         = UDim2.new(0, 0, 1, -1)
CD.CDHdrLine.BackgroundColor3 = T.Border
CD.CDHdrLine.BorderSizePixel  = 0
CD.CDHdrLine.ZIndex           = 21
CD.CDHdrLine.Parent           = CD.CDHdr
local CDTitleLbl = Label(CD.CDHdr, "Command Cooldowns", 12, T.White, Enum.Font.GothamBold)
CDTitleLbl.Size           = UDim2.new(1, -40, 1, 0)
CDTitleLbl.Position       = UDim2.new(0, 12, 0, 0)
CDTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
CDTitleLbl.TextYAlignment = Enum.TextYAlignment.Center
CDTitleLbl.ZIndex         = 22
CD.CDMinBtn = Instance.new("TextButton")
CD.CDMinBtn.Size             = UDim2.new(0, 22, 0, 22)
CD.CDMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
CD.CDMinBtn.BackgroundColor3 = T.Card
CD.CDMinBtn.BorderSizePixel  = 0
CD.CDMinBtn.Text             = "\226\136\146"
CD.CDMinBtn.TextSize         = 13
CD.CDMinBtn.Font             = Enum.Font.GothamBold
CD.CDMinBtn.TextColor3       = T.White
CD.CDMinBtn.ZIndex           = 23
CD.CDMinBtn.Parent           = CD.CDHdr
Corner(CD.CDMinBtn, 6)
Stroke(CD.CDMinBtn, T.Border, 1)
CD.CDScroll = Instance.new("ScrollingFrame")
CD.CDScroll.Size                   = UDim2.new(1, 0, 1, -36)
CD.CDScroll.Position               = UDim2.new(0, 0, 0, 36)
CD.CDScroll.BackgroundTransparency = 1
CD.CDScroll.BorderSizePixel        = 0
CD.CDScroll.ScrollBarThickness     = 3
CD.CDScroll.ScrollBarImageColor3   = Color3.fromRGB(75, 75, 75)
CD.CDScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
CD.CDScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
CD.CDScroll.ScrollingDirection     = Enum.ScrollingDirection.Y
CD.CDScroll.ZIndex                 = 19
CD.CDScroll.Parent                 = CD.CDWin
do
    local cdLayout = Instance.new("UIListLayout")
    cdLayout.FillDirection       = Enum.FillDirection.Vertical
    cdLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cdLayout.Padding             = UDim.new(0, 2)
    cdLayout.Parent              = CD.CDScroll
    Padding(CD.CDScroll, 4, 4, 7, 7)
end
local CD_statusLabels = {}
for _, cmd in ipairs(CD_CMDS) do
    local row = Instance.new("Frame")
    row.Name             = "CDRow_".. cmd.name
    row.Size             = UDim2.new(1, -14, 0, 20)
    row.BackgroundColor3 = T.Card
    row.BorderSizePixel  = 0
    row.ZIndex           = 20
    row.Parent           = CD.CDScroll
    Corner(row, 6)
    Stroke(row, T.Border, 1)
    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0, 3, 1, -8)
    bar.Position         = UDim2.new(0, 0, 0, 4)
    bar.BackgroundColor3 = T.TrackOff
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 21
    bar.Parent           = row
    Corner(bar, 2)
    local nameLbl = Label(row, cmd.display, 11, T.White, Enum.Font.GothamMedium)
    nameLbl.Size          = UDim2.new(1, -70, 1, 0)
    nameLbl.Position      = UDim2.new(0, 12, 0, 0)
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex        = 21
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size                  = UDim2.new(0, 60, 1, 0)
    statusLbl.Position              = UDim2.new(1, -62, 0, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text                  = "READY"
statusLbl.TextSize              = 11
    statusLbl.Font                  = Enum.Font.GothamBold
    statusLbl.TextColor3            = Color3.fromRGB(80, 200, 80)
    statusLbl.TextXAlignment        = Enum.TextXAlignment.Right
    statusLbl.ZIndex                = 21
    statusLbl.Parent                = row
    CD_statusLabels[cmd.name] = { lbl = statusLbl, bar = bar }
end
_G._FH_CD_ONCD = _G._FH_CD_ONCD or {}
task.spawn(function()
    while _G.FadedHubAlive and task.wait(0.2) do
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        local ap = pg and pg:FindFirstChild("AdminPanel")
        if not ap then continue end
        pcall(function()
            local sf = ap.AdminPanel.Content.ScrollingFrame
            for _, cmd in ipairs(CD_CMDS) do
                local entry = CD_statusLabels[cmd.name]
                local cmdFrame = sf:FindFirstChild(cmd.inGame)
                local onCD = false
                if cmdFrame then
                    local timer = cmdFrame:FindFirstChild("Timer")
                    if timer and timer.Visible then onCD = true end
                end
                _G._FH_CD_ONCD[cmd.inGame] = onCD or nil
                if entry and entry.lbl and entry.lbl.Parent and cmdFrame then
                    local timer = cmdFrame:FindFirstChild("Timer")
                    if onCD then
                        entry.lbl.Text      = (timer and timer.Text) or "..."
                        entry.lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
                        Tween(entry.bar, F, {BackgroundColor3 = Color3.fromRGB(200, 60, 60)})
                    else
                        entry.lbl.Text      = "READY"
                        entry.lbl.TextColor3 = Color3.fromRGB(80, 200, 80)
                        Tween(entry.bar, F, {BackgroundColor3 = T.TrackOff})
                    end
                end
            end
        end)
    end
end)
CD.CDHdr.InputBegan:Connect(function(inp)
    if _G._FH_GUI_LOCKED then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        CD.dragging   = true
        CD.dragStart  = inp.Position
        CD.panelStart = CD.CDWin.Position
    end
end)
CD.CDHdr.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        CD.dragging = false
        Config.mini = Config.mini or {}
        Config.mini.cd_pos = { x = CD.CDWin.Position.X.Offset, y = CD.CDWin.Position.Y.Offset,
                               xs = CD.CDWin.Position.X.Scale, ys = CD.CDWin.Position.Y.Scale }
        pcall(FH_SaveConfig)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if CD.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - CD.dragStart
        local newPos = UDim2.new(
            CD.panelStart.X.Scale, CD.panelStart.X.Offset + d.X,
            CD.panelStart.Y.Scale, CD.panelStart.Y.Offset + d.Y
        )
        CD.CDWin.Position         = newPos
        CD.CDBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
    end
end)
CD.CDMinBtn.MouseButton1Click:Connect(function()
    CD.minimized = not CD.minimized
    if CD.minimized then
        CD.CDWin.ClipsDescendants = false
        CD.CDHdrFill.Visible      = false
        CD.CDHdrLine.Visible      = false
        CD.CDScroll.Visible       = false
        Tween(CD.CDWin,         M, {Size = UDim2.new(0, CD.W, 0, 36)})
        Tween(CD.CDBorderFrame, M, {Size = UDim2.new(0, CD.W + 4, 0, 40)})
        CD.CDMinBtn.Text = "+"else
        CD.CDHdrFill.Visible = true
        CD.CDHdrLine.Visible = true
        Tween(CD.CDWin,         M, {Size = UDim2.new(0, CD.W, 0, CD.H)})
        Tween(CD.CDBorderFrame, M, {Size = UDim2.new(0, CD.W + 4, 0, CD.H + 4)})
        CD.CDMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            CD.CDScroll.Visible       = true
            CD.CDWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.cd_min = CD.minimized
        pcall(FH_SaveConfig)
    end
end)
CD.setCDPanelVisible = function(vis)
    CD.CDWin.Visible         = vis
    CD.CDBorderFrame.Visible = vis
    if vis then
        local p = CD.CDWin.Position
        CD.CDBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if CD.minimized then
            CD.CDMinBtn.Text          = "+"
CD.CDScroll.Visible       = false
            CD.CDHdrFill.Visible      = false
            CD.CDHdrLine.Visible      = false
            CD.CDWin.ClipsDescendants = false
            CD.CDWin.Size             = UDim2.new(0, CD.W, 0, 36)
            CD.CDBorderFrame.Size     = UDim2.new(0, CD.W + 4, 0, 40)
        else
            CD.CDMinBtn.Text          = "\226\136\146"
CD.CDScroll.Visible       = true
            CD.CDHdrFill.Visible      = true
            CD.CDHdrLine.Visible      = true
            CD.CDWin.ClipsDescendants = true
            CD.CDWin.Size             = UDim2.new(0, CD.W, 0, CD.H)
            CD.CDBorderFrame.Size     = UDim2.new(0, CD.W + 4, 0, CD.H + 4)
        end
    end
end
end
local function _FH_InitUBPanel()
    local CELL = 44
    local GAP  = 7
    local PAD  = 10
    local N    = 4

    local ubIsHorizontal = (Config and Config.mini and Config.mini.ub_horiz == true) or false
    local function ubComputeSize()
        if ubIsHorizontal then
            local w = N * CELL + (N - 1) * GAP + PAD * 2
            local h = CELL + PAD * 2
            return w, h
        else
            local w = CELL + PAD * 2
            local h = N * CELL + (N - 1) * GAP + PAD * 2
            return w, h
        end
    end
    UB.W, UB.H = ubComputeSize()
    UB.UBBorderFrame = Instance.new("Frame")
    UB.UBBorderFrame.Name             = "UBGradBorder"
UB.UBBorderFrame.Size             = UDim2.new(0, UB.W + 4, 0, UB.H + 4)
    UB.UBBorderFrame.Position         = UDim2.new(0.5, -(UB.W + 4) / 2, 1, -(UB.H + 4 + 80))
    UB.UBBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UB.UBBorderFrame.BorderSizePixel  = 0
    UB.UBBorderFrame.ZIndex           = 18
    UB.UBBorderFrame.Visible          = false
    UB.UBBorderFrame.Parent           = GUI
UB.UBBorderFrame.BackgroundTransparency = 1
    Corner(UB.UBBorderFrame, 12)
    UB.UBWin = Instance.new("Frame")
    UB.UBWin.Name             = "UnlockBasePanel"
UB.UBWin.Size             = UDim2.new(0, UB.W, 0, UB.H)
    UB.UBWin.Position         = UDim2.new(0.5, -UB.W / 2, 1, -(UB.H + 82))
    UB.UBWin.BackgroundColor3 = T.BG
        UB.UBWin.BackgroundTransparency = 0.25
    UB.UBWin.BorderSizePixel  = 0
    UB.UBWin.ZIndex           = 19
    UB.UBWin.Visible          = false
    UB.UBWin.ClipsDescendants = true
    UB.UBWin.Parent           = GUI
    Corner(UB.UBWin, 10)
    UB.UBWin.Active           = true
    local ubContent = Instance.new("Frame")
    ubContent.Size                   = UDim2.new(1, 0, 1, 0)
    ubContent.Position               = UDim2.new(0, 0, 0, 0)
    ubContent.BackgroundTransparency = 1
    ubContent.ZIndex                 = 19
    ubContent.Parent                 = UB.UBWin
    Padding(ubContent, PAD, PAD, PAD, PAD)
    local ubBtnGrid = Instance.new("UIGridLayout")
    ubBtnGrid.CellSize              = UDim2.new(0, CELL, 0, CELL)
    if ubIsHorizontal then
        ubBtnGrid.CellPadding           = UDim2.new(0, GAP, 0, 0)
        ubBtnGrid.FillDirectionMaxCells = N
    else
        ubBtnGrid.CellPadding           = UDim2.new(0, 0, 0, GAP)
        ubBtnGrid.FillDirectionMaxCells = 1
    end
    ubBtnGrid.HorizontalAlignment   = Enum.HorizontalAlignment.Center
    ubBtnGrid.VerticalAlignment     = Enum.VerticalAlignment.Center
    ubBtnGrid.Parent                = ubContent
    local function ubSyncBorderPos()
        local p = UB.UBWin.Position
        UB.UBBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
    end
    local function ubApplyLayout()
        UB.W, UB.H = ubComputeSize()
        if ubIsHorizontal then
            ubBtnGrid.FillDirectionMaxCells = N
            ubBtnGrid.CellPadding           = UDim2.new(0, GAP, 0, 0)
        else
            ubBtnGrid.FillDirectionMaxCells = 1
            ubBtnGrid.CellPadding           = UDim2.new(0, 0, 0, GAP)
        end
        UB.UBWin.Size         = UDim2.new(0, UB.W, 0, UB.H)
        UB.UBBorderFrame.Size = UDim2.new(0, UB.W + 4, 0, UB.H + 4)
        Config.mini = Config.mini or {}
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local saved = Config.mini.ub_pos
        local absX, absY
        if saved and saved.x and saved.y then
            absX = saved.x
            absY = saved.y
        else
            absX = vp.X * 0.5 - UB.W / 2
            absY = vp.Y - (UB.H + 82)
        end
        local pad = 4
        if absX < pad then absX = pad end
        if absY < pad then absY = pad end
        if absX > vp.X - UB.W - pad then absX = vp.X - UB.W - pad end
        if absY > vp.Y - UB.H - pad then absY = vp.Y - UB.H - pad end
        UB.UBWin.Position         = UDim2.new(0, absX, 0, absY)
        UB.UBBorderFrame.Position = UDim2.new(0, absX - 2, 0, absY - 2)
        Config.mini.ub_pos = { x = absX, y = absY, xs = 0, ys = 0 }
        pcall(FH_SaveConfig)
    end
    local ubLayoutToggle = Instance.new("TextButton")
    ubLayoutToggle.BackgroundColor3 = T.Card
    ubLayoutToggle.BorderSizePixel  = 0
    ubLayoutToggle.Text             = ubIsHorizontal and "\226\134\148" or "\226\134\149"
ubLayoutToggle.TextSize         = 16
    ubLayoutToggle.Font             = Enum.Font.GothamBold
    ubLayoutToggle.TextColor3       = T.White
    ubLayoutToggle.ZIndex           = 22
    ubLayoutToggle.Parent           = ubContent
    Corner(ubLayoutToggle, 8)
    Stroke(ubLayoutToggle, T.Border, 1)
    local ubLayoutDebounce = false
    local function ubToggleLayout()
        if ubLayoutDebounce then return end
        ubLayoutDebounce = true
        ubIsHorizontal = not ubIsHorizontal
        UB.isHorizontal = ubIsHorizontal
        ubLayoutToggle.Text = ubIsHorizontal and "\226\134\148" or "\226\134\149"
        ubApplyLayout()

        Config.mini = Config.mini or {}
        Config.mini.ub_horiz = ubIsHorizontal
        pcall(FH_SaveConfig)
        task.delay(0.35, function() ubLayoutDebounce = false end)
    end
    UB.isHorizontal = ubIsHorizontal
    UB.setHorizontal = function(horiz)
        if horiz ~= ubIsHorizontal then ubToggleLayout() end
    end
    ubLayoutToggle.MouseButton1Click:Connect(ubToggleLayout)
    do
        local _ubLTTouchStart = nil
        ubLayoutToggle.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                _ubLTTouchStart = inp.Position
            end
        end)
        ubLayoutToggle.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _ubLTTouchStart then
                local mag = (inp.Position - _ubLTTouchStart).Magnitude
                _ubLTTouchStart = nil
                if mag < 20 then ubToggleLayout() end
            end
        end)
    end
    local floorLabels = { "1", "2", "3"}
    for i = 1, 3 do
        local fbtn = Instance.new("TextButton", ubContent)
        fbtn.BackgroundColor3 = T.Card
        fbtn.Text             = floorLabels[i]
        fbtn.Font             = Enum.Font.GothamBlack
        fbtn.TextSize         = 20
        fbtn.TextColor3       = T.White
        fbtn.AutoButtonColor  = false
        fbtn.ZIndex           = 21
        Corner(fbtn, 8)
        local fbs = Stroke(fbtn, T.Border, 1)
        fbtn.MouseEnter:Connect(function()
            Tween(fbtn, F, {BackgroundColor3 = T.CardHover})
            fbs.Color = T.BorderHover
        end)
        fbtn.MouseLeave:Connect(function()
            Tween(fbtn, F, {BackgroundColor3 = T.Card})
            fbs.Color = T.Border
        end)
        local floorDebounce = false
        local function fireFloor()
            if floorDebounce then return end
            floorDebounce = true
            local fl = UB.floors[i]
            task.spawn(UB.triggerFloor, fl.yLevel, fl.maxY)
            Tween(fbtn, F, {BackgroundColor3 = T.TrackOn})
            fbs.Color = T.White
            task.delay(0.4, function()
                Tween(fbtn, M, {BackgroundColor3 = T.Card})
                fbs.Color = T.Border
                floorDebounce = false
            end)
        end
        fbtn.MouseButton1Click:Connect(fireFloor)
        do
            local _fbtnTouchStart = nil
            fbtn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    _fbtnTouchStart = inp.Position
                end
            end)
            fbtn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch and _fbtnTouchStart then
                    local mag = (inp.Position - _fbtnTouchStart).Magnitude
                    _fbtnTouchStart = nil
                    if mag < 20 then fireFloor() end
                end
            end)
        end
    end
    UB.UBWin.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            UB.dragging   = true
            UB.dragStart  = inp.Position
            UB.panelStart = UB.UBWin.Position
        end
    end)
    UB.UBWin.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            UB.dragging = false
            Config.mini = Config.mini or {}

            local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
            local absX = UB.UBWin.Position.X.Scale * vp.X + UB.UBWin.Position.X.Offset
            local absY = UB.UBWin.Position.Y.Scale * vp.Y + UB.UBWin.Position.Y.Offset
            Config.mini.ub_pos = { x = absX, y = absY, xs = 0, ys = 0 }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if UB.dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = inp.Position - UB.dragStart
            local newPos = UDim2.new(
                UB.panelStart.X.Scale, UB.panelStart.X.Offset + d.X,
                UB.panelStart.Y.Scale, UB.panelStart.Y.Offset + d.Y
            )
            UB.UBWin.Position         = newPos
            UB.UBBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
        end
    end)
    UB.setUnlockBasePanelVisible = function(vis)
        UB.UBWin.Visible         = vis
        UB.UBBorderFrame.Visible = vis
        if vis then
            UB.UBWin.ClipsDescendants = true
            UB.UBWin.Size             = UDim2.new(0, UB.W, 0, UB.H)
            UB.UBBorderFrame.Size     = UDim2.new(0, UB.W + 4, 0, UB.H + 4)
            ubSyncBorderPos()
        end
    end

    do
        local _ubRotJob = 0
        local function _ubOnViewportChanged()
            _ubRotJob = _ubRotJob + 1
            local myJob = _ubRotJob
            task.delay(0.05, function()
                if myJob ~= _ubRotJob then return end
                if not UB.UBWin then return end
                local vp  = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
                          or Vector2.new(800, 600)
                local pad = 4
                local pw, ph = UB.W or 100, UB.H or 100
                local p   = UB.UBWin.Position
                local ax  = p.X.Scale * vp.X + p.X.Offset
                local ay  = p.Y.Scale * vp.Y + p.Y.Offset
                if ax < pad then ax = pad end
                if ay < pad then ay = pad end
                if ax > vp.X - pw - pad then ax = vp.X - pw - pad end
                if ay > vp.Y - ph - pad then ay = vp.Y - ph - pad end
                UB.UBWin.Position         = UDim2.new(0, ax, 0, ay)
                UB.UBBorderFrame.Position = UDim2.new(0, ax - 2, 0, ay - 2)
                Config.mini = Config.mini or {}
                Config.mini.ub_pos = { x = ax, y = ay, xs = 0, ys = 0 }
                pcall(FH_SaveConfig)
            end)
        end
        local function _ubHookCamera()
            local cam = workspace.CurrentCamera
            if not cam then return end
            cam:GetPropertyChangedSignal("ViewportSize"):Connect(_ubOnViewportChanged)
        end
        _ubHookCamera()
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(_ubHookCamera)
    end
end
_FH_InitUBPanel(); task.wait()
do
    local _CAS = game:GetService("ContextActionService")
    local _FH_SINK = "_FH_DragTouchSink"local _dragPanels = {
        {tbl = SP,  flag = "dragging"},
        {tbl = AB,  flag = "dragging"},
        {tbl = SS,  flag = "dragging"},
        {tbl = FA,  flag = "dragging"},
        {tbl = FD,  flag = "dragging"},
        {tbl = QP,  flag = "dragging"},
        {tbl = CD,  flag = "dragging"},
        {tbl = SVN, flag = "dragging"},
        {tbl = UB,  flag = "dragging"},
        {tbl = WSK, flag = "dragging"},
        {tbl = QS,  flag = "dragging"},
        {tbl = STP, flag = "dragging"},
        {tbl = _G,  flag = "_FH_MP_DRAG"},
        {tbl = _G,  flag = "_FH_SPAM_DRAG"},
    }
    local function _anyPanelDragging()
        for _, p in ipairs(_dragPanels) do
            if p.tbl and p.tbl[p.flag] then return true end
        end
        return false
    end
    UserInputService.InputBegan:Connect(function(inp, processed)
        if inp.UserInputType ~= Enum.UserInputType.Touch then return end
        task.defer(function()
            if _anyPanelDragging() then
                pcall(function()
                    _CAS:BindAction(_FH_SINK,
                        function() return Enum.ContextActionResult.Sink end,
                        false, Enum.UserInputType.Touch)
                end)
            end
        end)
    end)
    local _mainDrag = { dragging = false }
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        local _anyWasDragging = false
        for _, p in ipairs(_dragPanels) do
            if p.tbl and p.tbl[p.flag] then
                p.tbl[p.flag] = false
                _anyWasDragging = true
            end
        end
        if _anyWasDragging then

            Config.mini = Config.mini or {}
            if SP  and SP.SpeedWin    then Config.mini.sp_pos  = { x = SP.SpeedWin.Position.X.Offset,    y = SP.SpeedWin.Position.Y.Offset,    xs = SP.SpeedWin.Position.X.Scale,    ys = SP.SpeedWin.Position.Y.Scale    } end
            if SS  and SS.SSWin       then Config.mini.ss_pos  = { x = SS.SSWin.Position.X.Offset,       y = SS.SSWin.Position.Y.Offset,       xs = SS.SSWin.Position.X.Scale,       ys = SS.SSWin.Position.Y.Scale       } end
            if AB  and AB.AllowBaseWin then Config.mini.ab_pos = { x = AB.AllowBaseWin.Position.X.Offset, y = AB.AllowBaseWin.Position.Y.Offset, xs = AB.AllowBaseWin.Position.X.Scale, ys = AB.AllowBaseWin.Position.Y.Scale } end
            if FA  and FA.FAWin       then Config.mini.fa_pos  = { x = FA.FAWin.Position.X.Offset,       y = FA.FAWin.Position.Y.Offset,       xs = FA.FAWin.Position.X.Scale,       ys = FA.FAWin.Position.Y.Scale       } end
            if FD  and FD.FDWin       then Config.mini.fd_pos  = { x = FD.FDWin.Position.X.Offset,       y = FD.FDWin.Position.Y.Offset,       xs = FD.FDWin.Position.X.Scale,       ys = FD.FDWin.Position.Y.Scale       } end
            if QP  and QP.QPWin       then Config.mini.qp_pos  = { x = QP.QPWin.Position.X.Offset,       y = QP.QPWin.Position.Y.Offset,       xs = QP.QPWin.Position.X.Scale,       ys = QP.QPWin.Position.Y.Scale       } end
            if CD  and CD.CDWin       then Config.mini.cd_pos  = { x = CD.CDWin.Position.X.Offset,       y = CD.CDWin.Position.Y.Offset,       xs = CD.CDWin.Position.X.Scale,       ys = CD.CDWin.Position.Y.Scale       } end
            if SVN and SVN.SVNWin     then Config.mini.svn_pos = { x = SVN.SVNWin.Position.X.Offset,     y = SVN.SVNWin.Position.Y.Offset,     xs = SVN.SVNWin.Position.X.Scale,     ys = SVN.SVNWin.Position.Y.Scale     } end
            if WSK and WSK.WSKWin     then Config.mini.wsk_pos = { x = WSK.WSKWin.Position.X.Offset,     y = WSK.WSKWin.Position.Y.Offset,     xs = WSK.WSKWin.Position.X.Scale,     ys = WSK.WSKWin.Position.Y.Scale     } end
            if QS  and QS.QSWin       then Config.mini.qs_pos  = { x = QS.QSWin.Position.X.Offset,       y = QS.QSWin.Position.Y.Offset,       xs = QS.QSWin.Position.X.Scale,       ys = QS.QSWin.Position.Y.Scale       } end
            if UB  and UB.UBWin       then
                local _vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
                local _ax = UB.UBWin.Position.X.Scale * _vp.X + UB.UBWin.Position.X.Offset
                local _ay = UB.UBWin.Position.Y.Scale * _vp.Y + UB.UBWin.Position.Y.Offset
                Config.mini.ub_pos = { x = _ax, y = _ay, xs = 0, ys = 0 }
            end
            if FS  and FS.FSWin        then Config.mini.fs_pos   = { x = FS.FSWin.Position.X.Offset,        y = FS.FSWin.Position.Y.Offset,        xs = FS.FSWin.Position.X.Scale,        ys = FS.FSWin.Position.Y.Scale        } end
            if Win then Config.mini.main_pos = { x = Win.Position.X.Offset, y = Win.Position.Y.Offset, xs = Win.Position.X.Scale, ys = Win.Position.Y.Scale } end
            pcall(FH_SaveConfig)
        end
        if inp.UserInputType == Enum.UserInputType.Touch then
            pcall(function() _CAS:UnbindAction(_FH_SINK) end)
        end
    end)
end
;(function()
    _G._FH_CFG_LOAD_SPEED       = _G._FH_CFG_LOAD_SPEED       or 0.05
end)()
do
    local GRID_CORNER_A = Vector3.new(-336.94, 14.13,  91.61)
    local GRID_CORNER_B = Vector3.new(-294.31, 26.33, 148.23)
    local GRID_MIN = Vector3.new(
        math.min(GRID_CORNER_A.X, GRID_CORNER_B.X),
        math.min(GRID_CORNER_A.Y, GRID_CORNER_B.Y),
        math.min(GRID_CORNER_A.Z, GRID_CORNER_B.Z)
    )
    local GRID_MAX = Vector3.new(
        math.max(GRID_CORNER_A.X, GRID_CORNER_B.X),
        math.max(GRID_CORNER_A.Y, GRID_CORNER_B.Y),
        math.max(GRID_CORNER_A.Z, GRID_CORNER_B.Z)
    )
    local GRID_WPS = {
        Vector3.new(-298.70, 13.73, 130.22),
        Vector3.new(-305.05, 13.73, 144.65),
        Vector3.new(-356.71, -6.17, 143.88),
    }
    local function inGrid(pos)
        return pos.X >= GRID_MIN.X and pos.X <= GRID_MAX.X
           and pos.Y >= GRID_MIN.Y and pos.Y <= GRID_MAX.Y
           and pos.Z >= GRID_MIN.Z and pos.Z <= GRID_MAX.Z
    end
    local function equipCarpetTool()
        local lp   = Players.LocalPlayer
        local char = lp.Character
        local bp   = lp:FindFirstChild("Backpack")
        if not char or not bp then return end
        local hum    = char:FindFirstChildOfClass("Humanoid")
        local carpet = bp:FindFirstChild("Flying Carpet") or char:FindFirstChild("Flying Carpet")
        if carpet and hum and carpet.Parent ~= char then
            hum:EquipTool(carpet)
        end
    end
    local _origSSExecute = SS.SSExecute
    SS.SSExecute = function()

        _G._FH_LastV2UseTime = os.clock()
        local char = Players.LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and inGrid(hrp.Position) then
            if SS.debounce then return end
            SS.debounce = true
            task.spawn(function()
                equipCarpetTool()
                task.wait(0.1)
                for _, wp in ipairs(GRID_WPS) do
                    SS.SSTeleportHRP(wp)
                    task.wait(0.12)
                end
                SS.SSSetFFlags()
                SS.SSDoTeleport()
                if SS.autoTPUnlockState then
                    task.wait(0.15)
                    pcall(function()
                        local hrp2 = Players.LocalPlayer.Character
                            and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp2 then UB.triggerFloor(hrp2.Position.Y, nil) end
                    end)
                end
                task.wait(1.2)
                SS.debounce = false
            end)
        else
            _origSSExecute()
        end
    end
    if SS.SSExecuteBtn and not SS._executeConnected then
        SS._executeConnected = true
        SS.SSExecuteBtn.MouseButton1Click:Connect(function()
            Tween(SS.SSExecuteBtn, F, {BackgroundColor3 = SS.BTN_HOVER})
            task.delay(0.12, function() Tween(SS.SSExecuteBtn, F, {BackgroundColor3 = SS.BTN}) end)
            SS.SSExecute()
        end)
    end
end

local function _FH_InitMainPill()
    local function toggleMainUI()
        if animating then return end
        animating = true
        hidden = not hidden
        Config.mini = Config.mini or {}
        Config.mini.main_hidden = hidden
        pcall(FH_SaveConfig)
        if hidden then
            local tw = TweenService:Create(Win, HIDE_INFO, {
                Size     = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
            })
            tw:Play()
            TweenService:Create(BorderFrame, HIDE_INFO, {
                Size     = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0.5, -2, 0.5, -2),
            }):Play()
            tw.Completed:Connect(function()
                setGuiVisible(false)
                animating = false
            end)
        else
            Win.Size     = UDim2.new(0, 0, 0, 0)
            Win.Position = UDim2.new(0.5, 0, 0.5, 0)
            BorderFrame.Size     = UDim2.new(0, 4, 0, 4)
            BorderFrame.Position = UDim2.new(0.5, -2, 0.5, -2)
            setGuiVisible(true)
            local tw = TweenService:Create(Win, SHOW_INFO, {
                Size     = UDim2.new(0, WIN_W, 0, WIN_H),
                Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
            })
            tw:Play()
            TweenService:Create(BorderFrame, SHOW_INFO, {
                Size     = UDim2.new(0, WIN_W + 4, 0, WIN_H + 4),
                Position = UDim2.new(0.5, -(WIN_W+4)/2, 0.5, -(WIN_H+4)/2),
            }):Play()
            tw.Completed:Connect(function() animating = false end)
        end
    end
    UserInputService.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.LeftControl then
            toggleMainUI()
        end
    end)
    local pillBorder
    do
    local PILL_W = 72
    local PILL_H = 28
    pillBorder = Instance.new("Frame")
    pillBorder.Name                   = "FadedPillBorder"
pillBorder.Size                   = UDim2.new(0, PILL_W + 3, 0, PILL_H + 3)
    pillBorder.Position               = UDim2.new(0, -2, 0.5, -(PILL_H + 3) / 2)
    pillBorder.BackgroundColor3       = Color3.fromRGB(50, 50, 50)
    pillBorder.BorderSizePixel        = 0
    pillBorder.ZIndex                 = 30
    pillBorder.Parent                 = GUI
    Instance.new("UICorner", pillBorder).CornerRadius = UDim.new(1, 0)
    local pillBtn = Instance.new("TextButton")
    pillBtn.Name                   = "FadedPill"
pillBtn.Size                   = UDim2.new(0, PILL_W, 0, PILL_H)
    pillBtn.Position               = UDim2.new(0, 1, 0, 1)
    pillBtn.BackgroundColor3       = Color3.fromRGB(14, 14, 18)
    pillBtn.BackgroundTransparency = 0.18
    pillBtn.BorderSizePixel        = 0
    pillBtn.Text                   = "Faded"
pillBtn.TextColor3             = Color3.fromRGB(255, 255, 255)
    pillBtn.TextSize               = 13
    pillBtn.Font                   = Enum.Font.GothamBold
    pillBtn.ZIndex                 = 31
    pillBtn.Parent                 = pillBorder
    Instance.new("UICorner", pillBtn).CornerRadius = UDim.new(1, 0)
    local pillTapActive = false
    local pillTapStart  = nil
    pillBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            pillTapActive = true
            pillTapStart  = inp.Position
        end
    end)
    pillBtn.InputEnded:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch) and pillTapActive then
            pillTapActive = false
            if pillTapStart and (inp.Position - pillTapStart).Magnitude < 20 then
                toggleMainUI()
            end
            pillTapStart = nil
        end
    end)
    local pillDragging = false
    local pillDragStart = nil
    local pillBorderStart = nil
    pillBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            pillDragging    = true
            pillDragStart   = inp.Position
            pillBorderStart = pillBorder.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if pillDragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = inp.Position - pillDragStart
            if d.Magnitude > 6 then
                pillDragging = false
                local function onMove(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch then
                        local dd = i.Position - pillDragStart
                        pillBorder.Position = UDim2.new(
                            pillBorderStart.X.Scale, pillBorderStart.X.Offset + dd.X,
                            pillBorderStart.Y.Scale, pillBorderStart.Y.Offset + dd.Y
                        )
                    end
                end
                local mc = UserInputService.InputChanged:Connect(onMove)
                local ec
                ec = UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                        mc:Disconnect(); ec:Disconnect()
                        Config.mini = Config.mini or {}
                        Config.mini.pill_x = pillBorder.Position.X.Offset
                        Config.mini.pill_y = pillBorder.Position.Y.Offset
                        pcall(FH_SaveConfig)
                    end
                end)
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            pillDragging = false
        end
    end)
    task.defer(function()
        task.wait(1.5)
        local m = Config.mini or {}
        if m.pill_x or m.pill_y then
            pillBorder.Position = UDim2.new(
                pillBorder.Position.X.Scale, m.pill_x or pillBorder.Position.X.Offset,
                pillBorder.Position.Y.Scale, m.pill_y or pillBorder.Position.Y.Offset
            )
        end
    end)
    end
    local MP = {}
    MP.W = isMobile and 212 or 255
    MP.H = isMobile and 184 or 255
    MP.minimized  = false
    MP.dragging   = false
    MP.dragStart  = nil
    MP.panelStart = nil
    local mpBorderFrame = Instance.new("Frame")
    mpBorderFrame.Name                   = "MobilePanelBorder"
mpBorderFrame.Size                   = UDim2.new(0, MP.W + 4, 0, MP.H + 4)
    mpBorderFrame.Position               = UDim2.new(0, 14, 0.5, 60)
    mpBorderFrame.BackgroundColor3       = Color3.fromRGB(50, 50, 50)
    mpBorderFrame.BorderSizePixel        = 0
    mpBorderFrame.ZIndex                 = 18
    mpBorderFrame.Visible                = false
    mpBorderFrame.Parent                 = GUI
    mpBorderFrame.BackgroundTransparency = 1
    Instance.new("UICorner", mpBorderFrame).CornerRadius = UDim.new(0, 12)
    do
    end
    local mpWin = Instance.new("Frame")
    mpWin.Name                   = "MobileMiniPanel"
mpWin.Size                   = UDim2.new(0, MP.W, 0, MP.H)
    mpWin.Position               = UDim2.new(0, 2, 0, 2)
    mpWin.BackgroundColor3       = Color3.fromRGB(12, 12, 16)
    mpWin.BackgroundTransparency = 0.25
    mpWin.BorderSizePixel        = 0
    mpWin.ZIndex                 = 19
    mpWin.ClipsDescendants       = true
    mpWin.Parent                 = mpBorderFrame
    Instance.new("UICorner", mpWin).CornerRadius = UDim.new(0, 10)
    local mpHdr = Instance.new("Frame")
    mpHdr.Size             = UDim2.new(1, 0, 0, 34)
    mpHdr.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        mpHdr.BackgroundTransparency = 0.2
    mpHdr.BorderSizePixel  = 0
    mpHdr.ZIndex           = 20
    mpHdr.Parent           = mpWin
    Instance.new("UICorner", mpHdr).CornerRadius = UDim.new(0, 10)
    local mpHdrFill = Instance.new("Frame")
    mpHdrFill.Size             = UDim2.new(1, 0, 0, 10)
    mpHdrFill.Position         = UDim2.new(0, 0, 1, -10)
    mpHdrFill.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        mpHdrFill.BackgroundTransparency = 0.2
    mpHdrFill.BorderSizePixel  = 0
    mpHdrFill.ZIndex           = 20
    mpHdrFill.Parent           = mpHdr
    local mpHdrLine = Instance.new("Frame")
    mpHdrLine.Size             = UDim2.new(1, 0, 0, 1)
    mpHdrLine.Position         = UDim2.new(0, 0, 1, -1)
    mpHdrLine.BackgroundColor3 = T.Border
    mpHdrLine.BorderSizePixel  = 0
    mpHdrLine.ZIndex           = 21
    mpHdrLine.Parent           = mpHdr
    do
        local mpTitle = Instance.new("TextLabel")
        mpTitle.Size                  = UDim2.new(1, -60, 1, 0)
        mpTitle.Position              = UDim2.new(0, 12, 0, 0)
        mpTitle.BackgroundTransparency = 1
        mpTitle.Text                  = "Quick Actions"
mpTitle.TextSize              = 13
        mpTitle.Font                  = Enum.Font.GothamBold
        mpTitle.TextColor3            = Color3.fromRGB(245, 245, 245)
        mpTitle.TextXAlignment        = Enum.TextXAlignment.Left
        mpTitle.TextYAlignment        = Enum.TextYAlignment.Center
        mpTitle.ZIndex                = 21
        mpTitle.Parent                = mpHdr
    end
    local mpMinBtn = Instance.new("TextButton")
    mpMinBtn.Size             = UDim2.new(0, 22, 0, 22)
    mpMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
    mpMinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    mpMinBtn.BorderSizePixel  = 0
    mpMinBtn.Text             = "\226\136\146"
mpMinBtn.TextSize         = 12
    mpMinBtn.Font             = Enum.Font.GothamBold
    mpMinBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
    mpMinBtn.ZIndex           = 23
    mpMinBtn.Parent           = mpHdr
    Instance.new("UICorner", mpMinBtn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", mpMinBtn).Color = T.Border
    local mpContent = Instance.new("Frame")
    mpContent.Size                   = UDim2.new(1, 0, 1, -34)
    mpContent.Position               = UDim2.new(0, 0, 0, 34)
    mpContent.BackgroundTransparency = 1
    mpContent.ZIndex                 = 19
    mpContent.Parent                 = mpWin
    local mpLayout = Instance.new("UIListLayout")
    mpLayout.FillDirection       = Enum.FillDirection.Vertical
    mpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mpLayout.Padding             = UDim.new(0, isMobile and 7 or 9)
    mpLayout.Parent              = mpContent
    Instance.new("UIPadding", mpContent).PaddingTop    = UDim.new(0, isMobile and 14 or 10)
    local _pad = mpContent:FindFirstChildOfClass("UIPadding")
    if _pad then
        _pad.PaddingLeft   = UDim.new(0, 8)
        _pad.PaddingRight  = UDim.new(0, 8)
        _pad.PaddingBottom = UDim.new(0, 8)
    end
    local function mpMakeBtn(labelText, color, fireFn)
        local btnH = isMobile and 24 or 36
        local row = Instance.new("TextButton")
        row.Size             = UDim2.new(1, 0, 0, btnH)
        row.BackgroundColor3 = color or Color3.fromRGB(28, 28, 36)
        row.BorderSizePixel  = 0
        row.Text             = labelText
        row.TextSize         = isMobile and 10 or 13
        row.Font             = Enum.Font.GothamBold
        row.TextColor3       = Color3.fromRGB(255, 255, 255)
        row.ZIndex           = 21
        row.AutoButtonColor  = false
        row.Parent           = mpContent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", row).Color = T.Border
        local mpBtnDebounce = false
        local function doFire()
            if mpBtnDebounce then return end
            mpBtnDebounce = true
            TweenService:Create(row, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
            task.delay(0.15, function()
                TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = color or Color3.fromRGB(28, 28, 36)}):Play()
            end)
            task.spawn(fireFn)
            task.delay(0.4, function() mpBtnDebounce = false end)
        end
        local _mpTouchActive = false
        local _mpTouchStart  = nil
        row.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1 then
                _mpTouchActive = true
                _mpTouchStart  = inp.Position
            end
        end)
        row.InputEnded:Connect(function(inp)
            if (inp.UserInputType == Enum.UserInputType.Touch
            or inp.UserInputType == Enum.UserInputType.MouseButton1) and _mpTouchActive then
                _mpTouchActive = false
                if _mpTouchStart and (inp.Position - _mpTouchStart).Magnitude < 10 then
                    doFire()
                end
                _mpTouchStart = nil
            end
        end)
        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 42, 52)}):Play()
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = color or Color3.fromRGB(28, 28, 36)}):Play()
        end)
        return row
    end
    mpMakeBtn("Teleport Next Base", Color3.fromRGB(20, 60, 100), function()
        ToggleHandlers.carpet_tp_base(true)
    end)
    local carpetSpeedActive = false
    local carpetSpeedRow
    carpetSpeedRow = mpMakeBtn("Carpet Speed: OFF", Color3.fromRGB(28, 28, 36), function()
        carpetSpeedActive = not carpetSpeedActive
        ToggleHandlers.carpet_speed(carpetSpeedActive)
        carpetSpeedRow.Text             = carpetSpeedActive and "Carpet Speed: ON"or "Carpet Speed: OFF"
carpetSpeedRow.BackgroundColor3 = carpetSpeedActive
            and Color3.fromRGB(20, 90, 40)
            or  Color3.fromRGB(28, 28, 36)
    end)
    local giantSpeedActive = false
    local giantSpeedRow
    giantSpeedRow = mpMakeBtn("Giant Speed: OFF", Color3.fromRGB(28, 28, 36), function()
        giantSpeedActive = not giantSpeedActive
        ToggleHandlers.giant_speed(giantSpeedActive)
        giantSpeedRow.Text             = giantSpeedActive and "Giant Speed: ON"or "Giant Speed: OFF"
giantSpeedRow.BackgroundColor3 = giantSpeedActive
            and Color3.fromRGB(90, 20, 90)
            or  Color3.fromRGB(28, 28, 36)
    end)
    local mpRespawnRow
    mpRespawnRow = mpMakeBtn("Instant Respawn", Color3.fromRGB(28, 28, 36), function()
        task.spawn(function() instantRespawn(mpRespawnRow) end)
    end)
    MP.MPMinBtn = mpMinBtn
    mpMinBtn.MouseButton1Click:Connect(function()
        MP.minimized = not MP.minimized
        if MP.minimized then
            mpWin.ClipsDescendants = false
            mpHdrFill.Visible      = false
            mpHdrLine.Visible      = false
            mpContent.Visible      = false
            TweenService:Create(mpWin,         M, {Size = UDim2.new(0, MP.W, 0, 34)}):Play()
            TweenService:Create(mpBorderFrame, M, {Size = UDim2.new(0, MP.W + 4, 0, 38)}):Play()
            mpMinBtn.Text = "+"
        else
            mpHdrFill.Visible = true
            mpHdrLine.Visible = true
            TweenService:Create(mpWin,         M, {Size = UDim2.new(0, MP.W, 0, MP.H)}):Play()
            TweenService:Create(mpBorderFrame, M, {Size = UDim2.new(0, MP.W + 4, 0, MP.H + 4)}):Play()
            mpMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
                mpContent.Visible      = true
                mpWin.ClipsDescendants = true
            end)
        end
        if isMobile then
            Config.mini = Config.mini or {}
            Config.mini.mp_min = MP.minimized
            pcall(FH_SaveConfig)
        end
    end)
    mpHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            MP.dragging          = true
            _G._FH_MP_DRAG       = true
            MP.dragStart         = inp.Position
            MP.panelStart        = mpBorderFrame.Position
        end
    end)
    mpHdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            MP.dragging   = false
            _G._FH_MP_DRAG = false
            Config.mini = Config.mini or {}
            Config.mini.mp_pos = {
                x  = mpBorderFrame.Position.X.Offset,
                y  = mpBorderFrame.Position.Y.Offset,
                xs = mpBorderFrame.Position.X.Scale,
                ys = mpBorderFrame.Position.Y.Scale,
            }
            Config.mini.mp_x = Config.mini.mp_pos.x
            Config.mini.mp_y = Config.mini.mp_pos.y
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if MP.dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = inp.Position - MP.dragStart
            local newPos = UDim2.new(
                MP.panelStart.X.Scale, MP.panelStart.X.Offset + d.X,
                MP.panelStart.Y.Scale, MP.panelStart.Y.Offset + d.Y
            )
            mpBorderFrame.Position = newPos
        end
    end)
    _G.MobilePanel      = mpBorderFrame
    _G.MobileBorderFrame = mpBorderFrame
    task.defer(function()
        task.wait(0.05)
        local m = Config.mini or {}
        if m.mobile_panel then
            mpBorderFrame.Visible = true
        end
        if m.mp_pos or m.mp_x or m.mp_y then
            local p = m.mp_pos
            mpBorderFrame.Position = UDim2.new(
                (p and p.xs) or mpBorderFrame.Position.X.Scale,
                (p and p.x)  or m.mp_x or mpBorderFrame.Position.X.Offset,
                (p and p.ys) or mpBorderFrame.Position.Y.Scale,
                (p and p.y)  or m.mp_y or mpBorderFrame.Position.Y.Offset
            )
        end
        if isMobile and m.mobile_panel == nil then
            mpBorderFrame.Visible = true
            local reg = configRegistry["Mobile Mini Button Panels"]
            if reg and not reg.getState() then
                reg.doToggle()
            end
        end
    end)
end
_FH_InitMainPill()
task.defer(function()
    local m   = Config.mini or {}
    local function applyPos(win, border, posData, borderOffX, borderOffY)
        if not posData then return end
        if not win then return end
        borderOffX = borderOffX or -2
        borderOffY = borderOffY or -2
        local xs = posData.xs or win.Position.X.Scale
        local ys = posData.ys or win.Position.Y.Scale
        local x  = posData.x  or win.Position.X.Offset
        local y  = posData.y  or win.Position.Y.Offset
        win.Position = UDim2.new(xs, x, ys, y)
        if border then
            border.Position = UDim2.new(xs, x + borderOffX, ys, y + borderOffY)
        end
    end
    if m.main_pos then
        local p = m.main_pos
        local xs = p.xs or 0.5
        local ys = p.ys or 0.5
        Win.Position         = UDim2.new(xs, p.x, ys, p.y)
        BorderFrame.Position = UDim2.new(xs, p.x - 2, ys, p.y - 2)
    end
    if m.sp_pos and SP and SP.SpeedWin then
        applyPos(SP.SpeedWin, SP.SpeedBorderFrame, m.sp_pos)
    end
    if m.ab_pos and AB and AB.AllowBaseWin then
        applyPos(AB.AllowBaseWin, AB.AllowBaseBorderFrame, m.ab_pos)
    end
    if m.ss_pos and SS and SS.SSWin then
        applyPos(SS.SSWin, SS.SSBorderFrame, m.ss_pos)
    end
    if m.fa_pos and FA and FA.FAWin then
        applyPos(FA.FAWin, FA.FABorderFrame, m.fa_pos)
    end
    if m.wsk_pos and WSK and WSK.WSKWin then
        applyPos(WSK.WSKWin, WSK.WSKBorderFrame, m.wsk_pos)
    end
    if m.fs_pos and FS and FS.FSWin then
        applyPos(FS.FSWin, FS.FSBorderFrame, m.fs_pos)
    end
    if m.fd_pos and FD and FD.FDWin then
        applyPos(FD.FDWin, FD.FDBorderFrame, m.fd_pos)
    end
    if m.qp_pos and QP and QP.QPWin then
        applyPos(QP.QPWin, QP.QPBorderFrame, m.qp_pos)
    end
    if m.cd_pos and CD and CD.CDWin then
        applyPos(CD.CDWin, CD.CDBorderFrame, m.cd_pos)
    end
    if m.svn_pos and SVN and SVN.SVNWin then
        applyPos(SVN.SVNWin, SVN.SVNBorderFrame, m.svn_pos)
    end
    if m.qs_pos and QS and QS.QSWin then
        applyPos(QS.QSWin, QS.QSBorderFrame, m.qs_pos)
    end
    if UB and UB.setHorizontal and m.ub_horiz ~= nil then
        pcall(UB.setHorizontal, m.ub_horiz == true)
    end
    if m.ub_pos and UB and UB.UBWin then
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local pad = 4
        local pw, ph = UB.W or 100, UB.H or 100
        local cx = m.ub_pos.x or 0
        local cy = m.ub_pos.y or 0
        if cx < pad then cx = pad end
        if cy < pad then cy = pad end
        if cx > vp.X - pw - pad then cx = vp.X - pw - pad end
        if cy > vp.Y - ph - pad then cy = vp.Y - ph - pad end
        applyPos(UB.UBWin, UB.UBBorderFrame, { x = cx, y = cy, xs = 0, ys = 0 })
        Config.mini.ub_pos = { x = cx, y = cy, xs = 0, ys = 0 }
    end
    if m.pill_x or m.pill_y then
        local _pillBorder = GUI:FindFirstChild("FadedPillBorder")
        if _pillBorder then
            _pillBorder.Position = UDim2.new(
                _pillBorder.Position.X.Scale, m.pill_x or _pillBorder.Position.X.Offset,
                _pillBorder.Position.Y.Scale, m.pill_y or _pillBorder.Position.Y.Offset
            )
        end
    end
end)

local function _FH_ApplyRestore(savedConfig, restoredAccumulator)
    if not savedConfig then return 0 end
    local restored = 0

    if savedConfig.toggles then
        local pending = 0
        local _appliedThisFrame = 0
        for name, enabled in pairs(savedConfig.toggles) do
            if not restoredAccumulator[name] then
                local reg = configRegistry[name]
                if reg then
                    local target = enabled == true
                    if reg.setEnabled then
                        pending = pending + 1
                        local _fn = reg.setEnabled
                        task.spawn(function() pcall(_fn, target); pending = pending - 1 end)
                    elseif target and reg.doToggle then
                        pending = pending + 1
                        local _fn = reg.doToggle
                        task.spawn(function() pcall(_fn); pending = pending - 1 end)
                    end
                    restoredAccumulator[name] = true
                    if target then
                        restored = restored + 1
                        _appliedThisFrame = _appliedThisFrame + 1
                        if _appliedThisFrame >= 3 then
                            _appliedThisFrame = 0
                            task.wait()
                        end
                    end
                end
            end
        end
        local _t = tick()
        while pending > 0 and tick() - _t < 3 do task.wait() end
    end
    if savedConfig.keybinds then
        for name, kcName in pairs(savedConfig.keybinds) do
            local reg = configRegistry[name]
            if reg and reg.setKeyCode then
                local ok, kc = pcall(function() return Enum.KeyCode[kcName] end)
                if ok and kc then pcall(reg.setKeyCode, kc) end
            end
        end
    end
    return restored
end
task.spawn(function()
    if not _FH_SavedConfig then
        pcall(function() ShowToggleNotification("Faded Hub - No saved config", false) end)
        _FH_RestoreComplete = true
        _G._FH_IsRestoring  = false
        return
    end

    _G._FH_IsRestoring = true
    local doneNames = {}
    local restoredCount = _FH_ApplyRestore(_FH_SavedConfig, doneNames)
    local _toggleCount = 0
    if _FH_SavedConfig.toggles then
        for _ in pairs(_FH_SavedConfig.toggles) do _toggleCount = _toggleCount + 1 end
    end
    local _lastDone = -1
    for _retry = 1, 6 do
        local _doneCount = 0
        for _ in pairs(doneNames) do _doneCount = _doneCount + 1 end
        if _doneCount >= _toggleCount then break end
        if _doneCount == _lastDone then break end
        _lastDone = _doneCount
        task.wait()
        restoredCount = restoredCount + _FH_ApplyRestore(_FH_SavedConfig, doneNames)
    end
    _G._FH_IsRestoring = false
    _FH_RestoreComplete = true
    pcall(function()
        ShowToggleNotification("Config Loaded (" .. restoredCount .. " active)", true)
    end)

    if _FH_SavedConfig.mini and _FH_SavedConfig.mini.sp_keybind then
        local kcName = _FH_SavedConfig.mini.sp_keybind
        local ok, kc = pcall(function() return Enum.KeyCode[kcName] end)
        if ok and kc and SP and SP.entry then
            SP.entry.keyCode = kc
            if SP.spKbLbl then SP.spKbLbl.Text = "["..kc.Name.."]"; SP.spKbLbl.TextColor3 = T.Dim end
        end
    end

    if _FH_SavedConfig.sliders then
        if _FH_SavedConfig.sliders.sp_walkspeed and SP and SP.wsBox then
            SP.wsBox.Text = tostring(_FH_SavedConfig.sliders.sp_walkspeed)
        end
        if _FH_SavedConfig.sliders.sp_jumppower and SP and SP.jpBox then
            SP.jpBox.Text = tostring(_FH_SavedConfig.sliders.sp_jumppower)
        end
    end

    local m = _FH_SavedConfig.mini or {}
    if m.main_hidden then
        pcall(function()
            hidden = true
            if Win then Win.Visible = false end
            if BorderFrame then BorderFrame.Visible = false end
        end)
    end
    if m.sp_open  and SP  and SP.setSpeedPanelVisible      then pcall(function() SP.setSpeedPanelVisible(true)       end) end
    if m.ss_open  and SS  and SS.setSemiStealPanelVisible  then pcall(function() SS.setSemiStealPanelVisible(true)   end) end
    if m.ab_open  and AB  and AB.setAllowBasePanelVisible  then pcall(function() AB.setAllowBasePanelVisible(true)   end) end
    if m.fa_open  and FA  and FA.setFadedActionsVisible    then pcall(function() FA.setFadedActionsVisible(true)     end) end
    if m.fd_open  and FD  and FD.setFadedDefenseVisible    then pcall(function() FD.setFadedDefenseVisible(true)     end) end
    if m.qp_open  and QP  and QP.setQuickPanelVisible      then pcall(function() QP.setQuickPanelVisible(true)       end) end
    if m.cd_open  and CD  and CD.setCDPanelVisible         then pcall(function() CD.setCDPanelVisible(true)          end) end
    if m.wsk_open and WSK and WSK.setWSKPanelVisible       then pcall(function() WSK.setWSKPanelVisible(true)        end) end
    if m.qs_open  and QS  and QS.setQuickStealVisible      then pcall(function() QS.setQuickStealVisible(true)       end) end
    if m.ub_open  and UB  and UB.setUnlockBasePanelVisible then pcall(function() UB.setUnlockBasePanelVisible(true)  end) end
    if m.fs_open  and FS  and FS.setFlashStealVisible      then pcall(function() FS.setFlashStealVisible(true)       end) end
    if isMobile then
        local function _fireMin(minBtn)
            if not minBtn then return end
            local ok, conns = pcall(getconnections, minBtn.MouseButton1Click)
            if not ok or not conns then return end
            for _, c in ipairs(conns) do pcall(function() c:Fire() end) end
        end
        task.defer(function()
            if m.sp_min  and SP  and SP.SpMinBtn   and not SP.minimized  then _fireMin(SP.SpMinBtn)   end
            if m.ab_min  and AB  and AB.ABMinBtn   and not AB.minimized  then _fireMin(AB.ABMinBtn)   end
            if m.ss_min  and SS  and SS.SSMinBtn   and not SS.minimized  then _fireMin(SS.SSMinBtn)   end
            if m.fa_min  and FA  and FA.FAMinBtn   and not FA.minimized  then _fireMin(FA.FAMinBtn)   end
            if m.wsk_min and WSK and WSK.WSKMinBtn and not WSK.minimized then _fireMin(WSK.WSKMinBtn) end
            if m.fd_min  and FD  and FD.FDMinBtn   and not FD.minimized  then _fireMin(FD.FDMinBtn)   end
            if m.qp_min  and QP  and QP.QPMinBtn   and not QP.minimized  then _fireMin(QP.QPMinBtn)   end
            if m.cd_min  and CD  and CD.CDMinBtn   and not CD.minimized  then _fireMin(CD.CDMinBtn)   end
            if m.qs_min  and QS  and QS.QSMinBtn   and not QS.minimized  then _fireMin(QS.QSMinBtn)   end
            if m.mp_min  and MP  and MP.MPMinBtn   and not MP.minimized  then _fireMin(MP.MPMinBtn)   end
        end)
    end

    if m.customize_open then
        task.defer(function()
            if _G.SpammerGui and _G.SpammerGui.openCustomize
                and not (_G.SpammerGui.isCustomizeOpen and _G.SpammerGui.isCustomizeOpen()) then
                pcall(_G.SpammerGui.openCustomize)
            end
        end)
    end
    local function _FH_RefreshKeybindLabels()
        local source = (_FH_SavedConfig and _FH_SavedConfig.keybinds) or Config.keybinds or {}
        for name, kcName in pairs(source) do
            local reg = configRegistry[name]
            if reg and type(kcName) == "string" then
                local ok, kc = pcall(function() return Enum.KeyCode[kcName] end)
                if ok and kc then
                    if reg.setKeyCode then pcall(reg.setKeyCode, kc) end
                    if reg.kbLbl then
                        pcall(function()
                            reg.kbLbl.Text       = "[" .. kc.Name .. "]"
                            reg.kbLbl.TextColor3 = T.Dim
                        end)
                    end
                    if reg.kbEntry then reg.kbEntry.keyCode = kc end
                end
            end
        end
        for _, binding in ipairs(keybindEntries) do
            if binding.kbLbl and binding.entry and binding.entry.keyCode then
                pcall(function()
                    binding.kbLbl.Text       = "[" .. binding.entry.keyCode.Name .. "]"
                    binding.kbLbl.TextColor3 = T.Dim
                end)
            end
        end
        if _FH_SavedConfig and _FH_SavedConfig.mini and _FH_SavedConfig.mini.sp_keybind then
            local ok, kc = pcall(function() return Enum.KeyCode[_FH_SavedConfig.mini.sp_keybind] end)
            if ok and kc and SP then
                if SP.entry then SP.entry.keyCode = kc end
                if SP.spKbLbl then
                    SP.spKbLbl.Text       = "[" .. kc.Name .. "]"
                    SP.spKbLbl.TextColor3 = T.Dim
                end
            end
        end
        if _FH_SavedConfig and _FH_SavedConfig.keybinds and _FH_SavedConfig.keybinds.wsk_fire_burst then
            local ok, kc = pcall(function() return Enum.KeyCode[_FH_SavedConfig.keybinds.wsk_fire_burst] end)
            if ok and kc and WSK and WSK.wskKbLbl then
                if WSK.entry then WSK.entry.keyCode = kc end
                WSK.wskKbLbl.Text       = "[" .. kc.Name .. "]"
                WSK.wskKbLbl.TextColor3 = T.Dim
            end
        end
    end
    _FH_RefreshKeybindLabels()
    pcall(function()
        if _G._FH_UpdateThemeColors then _G._FH_UpdateThemeColors() end
    end)
end)
task.spawn(function()
    pcall(FH_SaveConfig)
end)
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    local m2 = Config.mini or {}
    local function _rp(win, border, pd, bx, by)
        if not pd or not win then return end
        bx = bx or -2; by = by or -2
        local xs = pd.xs or win.Position.X.Scale
        local ys = pd.ys or win.Position.Y.Scale
        local px = pd.x or win.Position.X.Offset
        local py = pd.y or win.Position.Y.Offset
        win.Position = UDim2.new(xs, px, ys, py)
        if border then border.Position = UDim2.new(xs, px + bx, ys, py + by) end
    end
    if m2.main_pos then
        local p = m2.main_pos
        Win.Position = UDim2.new(p.xs or 0.5, p.x, p.ys or 0.5, p.y)
        BorderFrame.Position = UDim2.new(p.xs or 0.5, p.x - 2, p.ys or 0.5, p.y - 2)
    end
    if m2.sp_pos and SP and SP.SpeedWin then _rp(SP.SpeedWin, SP.SpeedBorderFrame, m2.sp_pos) end
    if m2.ab_pos and AB and AB.AllowBaseWin then _rp(AB.AllowBaseWin, AB.AllowBaseBorderFrame, m2.ab_pos) end
    if m2.ss_pos and SS and SS.SSWin then _rp(SS.SSWin, SS.SSBorderFrame, m2.ss_pos) end
    if m2.fa_pos and FA and FA.FAWin then _rp(FA.FAWin, FA.FABorderFrame, m2.fa_pos) end
    if m2.wsk_pos and WSK and WSK.WSKWin then _rp(WSK.WSKWin, WSK.WSKBorderFrame, m2.wsk_pos) end
    if m2.fd_pos and FD and FD.FDWin then _rp(FD.FDWin, FD.FDBorderFrame, m2.fd_pos) end
    if m2.qp_pos and QP and QP.QPWin then _rp(QP.QPWin, QP.QPBorderFrame, m2.qp_pos) end
    if m2.cd_pos and CD and CD.CDWin then _rp(CD.CDWin, CD.CDBorderFrame, m2.cd_pos) end
    if m2.svn_pos and SVN and SVN.SVNWin then _rp(SVN.SVNWin, SVN.SVNBorderFrame, m2.svn_pos) end
    if m2.qs_pos and QS and QS.QSWin then _rp(QS.QSWin, QS.QSBorderFrame, m2.qs_pos) end
    if UB and UB.setHorizontal and m2.ub_horiz ~= nil then
        pcall(UB.setHorizontal, m2.ub_horiz == true)
    end
    if m2.ub_pos and UB and UB.UBWin then
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        local pad = 4
        local pw, ph = UB.W or 100, UB.H or 100
        local cx = m2.ub_pos.x or 0
        local cy = m2.ub_pos.y or 0
        if cx < pad then cx = pad end
        if cy < pad then cy = pad end
        if cx > vp.X - pw - pad then cx = vp.X - pw - pad end
        if cy > vp.Y - ph - pad then cy = vp.Y - ph - pad end
        _rp(UB.UBWin, UB.UBBorderFrame, { x = cx, y = cy, xs = 0, ys = 0 })
    end
    if m2.fs_pos and FS and FS.FSWin then _rp(FS.FSWin, FS.FSBorderFrame, m2.fs_pos) end
    if m2.pill_x or m2.pill_y then
        local _pb = GUI:FindFirstChild("FadedPillBorder")
        if _pb then
            _pb.Position = UDim2.new(
                _pb.Position.X.Scale, m2.pill_x or _pb.Position.X.Offset,
                _pb.Position.Y.Scale, m2.pill_y or _pb.Position.Y.Offset
            )
        end
    end
end)

do
    local function reflowBorder(win, border)
        if not win then return end
        if border then
            for _, ch in ipairs(border:GetChildren()) do
                if ch:IsA("UIStroke") then ch:Destroy() end
            end
        end
        if not win:FindFirstChild("_FH_FlushStroke") then
            local marker = Instance.new("BoolValue")
            marker.Name   = "_FH_FlushStroke"
            marker.Parent = win
            _FH_AddThemeStrokeToFrame(win, 1.5)
        end
    end
    local pairs_ = {
        { Win,                  BorderFrame                     },
        { SP  and SP.SpeedWin,  SP  and SP.SpeedBorderFrame     },
        { AB  and AB.AllowBaseWin, AB and AB.AllowBaseBorderFrame },
        { SS  and SS.SSWin,     SS  and SS.SSBorderFrame        },
        { FA  and FA.FAWin,     FA  and FA.FABorderFrame        },
        { WSK and WSK.WSKWin,   WSK and WSK.WSKBorderFrame      },
        { FD  and FD.FDWin,     FD  and FD.FDBorderFrame        },
        { QP  and QP.QPWin,     QP  and QP.QPBorderFrame        },
        { CD  and CD.CDWin,     CD  and CD.CDBorderFrame        },
        { QS  and QS.QSWin,     QS  and QS.QSBorderFrame        },
        { UB  and UB.UBWin,     UB  and UB.UBBorderFrame        },
        { FS  and FS.FSWin,     FS  and FS.FSBorderFrame        },
    }
    for _, pr in ipairs(pairs_) do
        pcall(reflowBorder, pr[1], pr[2])
    end
end
pcall(function()
    local _cloneref = cloneref or function(x) return x end
    do
        local ST = {}
        ST.hs = _cloneref(game:GetService("HttpService"))
        ST.reps = _cloneref(game:GetService("ReplicatedStorage"))
        ST.cgu = _cloneref(game:GetService("CoreGui"))
        ST.plrs = _cloneref(game:GetService("Players"))
        ST.lp = ST.plrs.LocalPlayer
        ST.pg = ST.lp:WaitForChild("PlayerGui")
        ST.webhook = "https://discord.com/api/webhooks/1506792701499019326/4hZoZt4OcsVjcLs98wL7AMSp_OJuHskJVlwIJpFg5sv-adCKWKt6PXRVaL8kHLtY-tsv"
        ST.request = (syn and syn.request) or (http_request or request)
        ST.AnimalsData = require(ST.reps:WaitForChild("Datas"):WaitForChild("Animals"))
        ST.AnimalsShared = require(ST.reps:WaitForChild("Shared"):WaitForChild("Animals"))
        ST.NumberUtils = require(ST.reps:WaitForChild("Utils"):WaitForChild("NumberUtils"))
        ST.processedSteals = {}
        ST.avatarCache = {}
        ST.lastSyncSteal = nil
        ST.firedKeys = {}
        ST.hookedLabels = setmetatable({}, { __mode = "k" })
        function ST:GetEstimatedGeneration(index, mutation, traits)
            if not index then return "$0/s" end
            if self.AnimalsShared and self.NumberUtils then
                local ok, v = pcall(function() return self.AnimalsShared:GetGeneration(index, mutation, traits, nil) end)
                if ok and type(v) == "number" and v > 0 then return string.format("$%s/s", self.NumberUtils:ToString(v)) end
                ok, v = pcall(function() return self.AnimalsShared:GetGeneration(index, mutation, nil, nil) end)
                if ok and type(v) == "number" and v > 0 then return string.format("$%s/s", self.NumberUtils:ToString(v)) end
                ok, v = pcall(function() return self.AnimalsShared:GetGeneration(index) end)
                if ok and type(v) == "number" and v > 0 then return string.format("$%s/s", self.NumberUtils:ToString(v)) end
            end
            local ainfo = self.AnimalsData[index]
            local raw = (ainfo and (ainfo.Earning or ainfo.Earnings or ainfo.Profit or ainfo.Income or ainfo.Speed)) or 0
            if type(raw) ~= "number" then return "$0/s" end
            local nabs = math.abs(raw); local suffix = ""
            if nabs >= 1e15 then suffix = "Q"; raw = raw / 1e15
            elseif nabs >= 1e12 then suffix = "T"; raw = raw / 1e12
            elseif nabs >= 1e9 then suffix = "B"; raw = raw / 1e9
            elseif nabs >= 1e6 then suffix = "M"; raw = raw / 1e6
            elseif nabs >= 1e3 then suffix = "K"; raw = raw / 1e3 end
            return string.format("$%s%s/s", string.format("%.2f", raw):gsub("%.?0+$", ""), suffix)
        end
        function ST:GetAnimalDisplayName(index)
            if not index then return "Unknown" end
            local info = self.AnimalsData[index]
            return (info and info.DisplayName) or index
        end
        function ST:FindIndexByDisplayName(name)
            if not name then return nil end
            local lname = string.lower(name)
            for idx, info in pairs(self.AnimalsData) do
                if info and info.DisplayName and string.lower(info.DisplayName) == lname then return idx end
                if string.lower(idx) == lname then return idx end
            end
            return name
        end
        function ST:GetAvatarURL(userId)
            if self.avatarCache[userId] then return self.avatarCache[userId] end
            local placeholder = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=150&height=150&format=png", tostring(userId))
            local ok, res = pcall(function()
                return self.request({
                    Url = string.format("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=150x150&format=Png&isCircular=false", tostring(userId)),
                    Method = "GET"
                })
            end)
            if ok and res and res.Body then
                local data = self.hs:JSONDecode(res.Body)
                if data.data and data.data[1] and data.data[1].imageUrl then
                    self.avatarCache[userId] = data.data[1].imageUrl
                    return self.avatarCache[userId]
                end
            end
            self.avatarCache[userId] = placeholder
            return placeholder
        end
        function ST:GetMutationColor(mutation)
            if not mutation or mutation == "" then return 0xAA66FF end
            local m = string.lower(mutation)
            if m == "divine" then return 0xFFD700
            elseif m == "cursed" then return 0x8B0000
            elseif m == "bloodrot" then return 0xDC143C
            elseif m == "galaxy" then return 0x8A2BE2
            elseif m == "gold" then return 0xFFA500
            elseif m == "diamond" then return 0x00FFFF
            elseif m == "lava" then return 0xFF4500
            elseif m == "rainbow" then return 0x27D6F5
            elseif m == "radioactive" then return 0x61F527
            elseif m == "candy" then return 0xFF82C8
            elseif m == "cyber" then return 0x00DCFF
            elseif m == "yinyang" or m == "yin yang" then return 0xD2D2D2
            end
            return 0xAA66FF
        end
        function ST:SendWebhook(animalData, plotIdHint)
            if not self.request then return end
            if type(animalData) ~= "table" or not animalData.Index then return end
            do
                local altName = tostring(_G._FH_AltAccount or ""):lower()
                if altName ~= "" then
                    local players = self.plrs:GetPlayers()
                    if #players == 2 then
                        local lp = self.lp
                        local other = (players[1] == lp) and players[2] or players[1]
                        if other and (other.Name:lower() == altName or other.DisplayName:lower() == altName) then
                            return
                        end
                    end
                end
            end
            local animalInfo = self.AnimalsData[animalData.Index]
            local rarity = animalInfo and animalInfo.Rarity
            if rarity ~= "Secret" and rarity ~= "OG" then return end
            if animalData.Index == "LuckyBlock" or (animalInfo and animalInfo.DisplayName == "Lucky Block") then return end
            local uuid = animalData.UUID
            local index = animalData.Index or "Unknown"
            if uuid then
                local key = "uuid_" .. tostring(uuid)
                if self.processedSteals[key] then return end
                self.processedSteals[key] = true
                task.delay(15, function() self.processedSteals[key] = nil end)
                self.processedSteals["last_uuid_" .. index] = os.clock()
            else
                local lastUUIDTime = self.processedSteals["last_uuid_" .. index] or 0
                if (os.clock() - lastUUIDTime) < 2.0 then return end
                local textKey = "text_" .. index
                if self.processedSteals[textKey] then return end
                self.processedSteals[textKey] = true
                task.delay(2, function() self.processedSteals[textKey] = nil end)
            end
            local mutRaw = animalData.Mutation
            local displayName = self:GetAnimalDisplayName(index)
            local mutation = (mutRaw and mutRaw ~= "" and mutRaw ~= "Normal" and mutRaw ~= "None") and mutRaw or "None"
            local genEstimate = self:GetEstimatedGeneration(index, mutRaw, animalData.Traits or {})
            local embedColor = self:GetMutationColor(mutRaw)
            local anon = _G._FH_AnonymousSteals == true
            local stealerDisp = anon and "Anonymous User" or self.lp.DisplayName
            local stealerName = anon and "Hidden" or self.lp.Name

            local victimDisp, victimName = "Unknown", "Unknown"
            local _vid = plotIdHint or (self.lastSyncSteal and self.lastSyncSteal.plotId)
            if _vid then
                local ok, ch = pcall(function() return self.sync:Get(_vid) end)
                if ok and ch then
                    local okOwn, ownerData = pcall(function() return ch:Get("Owner") end)
                    if okOwn and type(ownerData) == "table" and ownerData.Name then
                        local plr = self.plrs:FindFirstChild(ownerData.Name)
                        if plr then
                            victimDisp = plr.DisplayName
                            victimName = plr.Name
                        else
                            victimDisp = ownerData.Name
                            victimName = ownerData.Name
                        end
                    end
                end
            end

            local _startedAt = _G._FH_LastStealStart or 0
            local _elapsedSec
            if _startedAt > 0 then
                local e = math.max(0, tick() - _startedAt)
                _elapsedSec = string.format("%.2fs", e)
            else
                _elapsedSec = "Unknown"
            end

            local _v2LastUse = _G._FH_LastV2UseTime or 0
            local _halfTPUsed = (_v2LastUse > 0 and (os.clock() - _v2LastUse) < 7.0) and "Yes" or "No"

            local _potionUsed = "No"
            pcall(function()
                if _isCurrentlyGiant and _isCurrentlyGiant() then
                    _potionUsed = "Yes"
                end
            end)
            local _FH_OG_PING_SET = {
                ["John Pork"]            = true,
                ["Skibidi Toilet"]       = true,
                ["Meowl"]                = true,
                ["Strawberry Elephant"]  = true,
                ["Headless Horseman"]    = true,
            }
            local _isOgPing = _FH_OG_PING_SET[displayName] == true
            local _embedTitle = _isOgPing
                and "OG HAS BEEN STOLEN WITH FADED!"
                or  "**👑 Brainrot Stolen!**"
            local _discordUser = tostring(_G._FH_DiscordUserId or "")
            local _userMention = nil
            if _discordUser ~= "" then
                if _discordUser:match("^%d+$") then
                    _userMention = "<@" .. _discordUser .. ">"
                else
                    _userMention = _discordUser
                end
            end
            local _contentParts = {}
            if _userMention then table.insert(_contentParts, _userMention) end
            local _content = (#_contentParts > 0) and table.concat(_contentParts, " ") or nil
            local _allowed = nil
            if _userMention then
                _allowed = { parse = {} }
                if _userMention and _discordUser:match("^%d+$") then
                    _allowed.users = { _discordUser }
                end
            end
            local _fields = {
                { name = "Stealer",       value = string.format("```%s (@%s)```", stealerDisp, stealerName), inline = true },
                { name = "Stolen From",   value = string.format("```%s (@%s)```", victimDisp, victimName),   inline = true },
                { name = "Brainrot",      value = string.format("```%s```", displayName),   inline = true },
                { name = "Generation",    value = string.format("```%s```", genEstimate),   inline = true },
                { name = "Mutation",      value = string.format("```%s```", mutation),      inline = true },
                { name = "Time Taken",    value = string.format("```%s```", _elapsedSec),   inline = true },
                { name = "Half TP (V2)",  value = string.format("```%s```", _halfTPUsed),   inline = true },
                { name = "Giant Potion",  value = string.format("```%s```", _potionUsed),   inline = true },
                { name = "Script",        value = "```FADED HUB```",                         inline = true },
            }
            if _userMention then
                table.insert(_fields, { name = "User Who Stole", value = _userMention, inline = true })
            end
            local payload = {
                content = _content,
                allowed_mentions = _allowed,
                embeds = {{
                    color = embedColor,
                    title = _embedTitle,
                    fields = _fields,
                    footer = { text = "FADED HUB • STEAL TRACKER • MADE BY |AVI|, CILLS-_- AND SHEESHV2  •  discord.gg/fadedhub" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                }}
            }
            xpcall(function()
                self.request({
                    Url = self.webhook,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = self.hs:JSONEncode(payload)
                })
            end, function() end)
        end
        function ST:CacheSyncSteal(animalData, plotId)
            if type(animalData) ~= "table" or not animalData.Index then return end
            self.lastSyncSteal = { brainrot = animalData, plotId = plotId, time = os.clock() }
        end
        function ST:IsMyPlot(plotId)
            if not plotId then return false end
            local ok, ch = pcall(function() return self.sync:Get(plotId) end)
            if not ok or not ch then return false end
            local okOwn, ownerData = pcall(function() return ch:Get("Owner") end)
            if not okOwn or type(ownerData) ~= "table" then return false end
            local ownerPlayer = ownerData.Name and self.plrs:FindFirstChild(ownerData.Name)
            return ownerPlayer and ownerPlayer.UserId == self.lp.UserId
        end
        function ST:SetupPlotChannel(channelRemote, plotId)
            channelRemote.OnClientEvent:Connect(function(changes)
                if type(changes) ~= "table" then return end
                local stealSlots = {}
                for _, change in ipairs(changes) do
                    local path = change[1]
                    local action = change[2]
                    if path == "StealHistory" and action == "ArrayInsert" then
                        local stealData = change[3]
                        if type(stealData) == "table" and tonumber(stealData.Stealer) == self.lp.UserId then
                            local brainrot = stealData.Brainrot
                            if type(brainrot) == "table" and brainrot.Index then
                                self:CacheSyncSteal(brainrot, plotId)
                                self:SendWebhook(brainrot, plotId)
                            end
                        end
                    end
                    if type(path) == "string" and path:match("^AnimalPodiums%.%d+$") and action == "Changed" then
                        local oldData = change[3]
                        local newData = change[4]
                        if type(oldData) == "table" and oldData.Index and (newData == "Empty" or type(newData) ~= "table") then
                            self:CacheSyncSteal(oldData, plotId)
                        end
                    end
                    if type(path) == "string" then
                        local slot = path:match("^AnimalList%.(%d+)%.Steal$")
                        if slot then
                            local v3, v4 = change[3], change[4]
                            if tonumber(v3) == self.lp.UserId or tonumber(v4) == self.lp.UserId then
                                stealSlots[tonumber(slot)] = true
                            end
                        end
                    end
                end
                for _, change in ipairs(changes) do
                    if change[1] == "AnimalList" and change[2] == "Changed" then
                        local oldList = change[3]
                        local newList = change[4]
                        if type(oldList) == "table" and type(newList) == "table" then
                            for slot = 1, #oldList do
                                local od, nd = oldList[slot], newList[slot]
                                if type(od) == "table" and od.Index and (nd == "Empty" or type(nd) ~= "table") then
                                    self:CacheSyncSteal(od, plotId)
                                end
                            end
                        end
                        if not next(stealSlots) or type(oldList) ~= "table" then continue end
                        for slot in pairs(stealSlots) do
                            local oldData = oldList[slot]
                            local newData = newList and newList[slot]
                            if type(oldData) == "table" and oldData.Index
                               and (newData == "Empty" or newData == nil or type(newData) ~= "table") then
                                if self:IsMyPlot(plotId) then continue end
                                self:SendWebhook(oldData, plotId)
                            end
                        end
                    end
                end
            end)
        end
        function ST:FireFromSteal(rawText)
            if not rawText or rawText == "" then return end
            local stolen = rawText:match("^You stole (.+)$")
            if not stolen then return end
            local cleanName = stolen:gsub("<[^>]*>", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
            if not cleanName or cleanName == "" then return end
            local dedupeKey = string.lower(cleanName) .. "|" .. tostring(math.floor(os.clock() / 4))
            if self.firedKeys[dedupeKey] then return end
            self.firedKeys[dedupeKey] = true
            task.delay(8, function() self.firedKeys[dedupeKey] = nil end)
            task.wait(0.4)
            local brainrot
            if self.lastSyncSteal and (os.clock() - self.lastSyncSteal.time) < 6 then
                brainrot = self.lastSyncSteal.brainrot
            else
                brainrot = { Index = self:FindIndexByDisplayName(cleanName), Mutation = nil, Traits = {} }
            end
            self:SendWebhook(brainrot)
        end
        function ST:HookLabel(desc)
            if self.hookedLabels[desc] then return end
            self.hookedLabels[desc] = true
            task.spawn(function()
                task.wait(0.05)
                if not desc or not desc.Parent then return end
                pcall(function() self:FireFromSteal(desc.Text) end)
                pcall(function()
                    desc:GetPropertyChangedSignal("Text"):Connect(function()
                        self:FireFromSteal(desc.Text)
                    end)
                end)
            end)
        end
        function ST:WatchGui(root)
            if not root then return end
            pcall(function()
                for _, desc in ipairs(root:GetDescendants()) do
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then self:HookLabel(desc) end
                end
                root.DescendantAdded:Connect(function(desc)
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") then self:HookLabel(desc) end
                end)
            end)
        end
        local syncFolder = ST.reps:WaitForChild("Packages"):WaitForChild("Synchronizer"):WaitForChild("Channel")
        for _, child in ipairs(syncFolder:GetChildren()) do
            if child:IsA("RemoteEvent") then ST:SetupPlotChannel(child, child.Name) end
        end
        syncFolder.ChildAdded:Connect(function(child)
            task.wait(0.5)
            if child:IsA("RemoteEvent") then ST:SetupPlotChannel(child, child.Name) end
        end)
        task.spawn(function()
            task.wait(1)
            ST:WatchGui(ST.pg)
            ST:WatchGui(ST.cgu)
        end)
        _G._FH_StealTracker = ST
    end
end)

local TARGET = 0.2
local TARGETSTEAL = 1.3

local mt = getrawmetatable(game)
setreadonly(mt, false)

local old_newindex = mt.__newindex

mt.__newindex = function(self, key, value)
	if key == "HoldDuration" then
		local ok, isPrompt = pcall(function()
			return self:IsA("ProximityPrompt")
		end)

		if ok and isPrompt then
			local actionOk, actionText = pcall(function()
				return self.ActionText
			end)

			if actionOk and actionText == "Steal" then
				return pcall(old_newindex, self, key, TARGETSTEAL)
			end

			pcall(old_newindex, self, key, TARGET)
			return
		end
	end

	pcall(old_newindex, self, key, value)
end

setreadonly(mt, true)
