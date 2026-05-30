            row.Name = "row_"..plr.Name
            row.Size = UDim2.new(1, -8, 0, rowH)
            row.BackgroundColor3 = T.Card
            row.BorderSizePixel = 0
            row.ZIndex = 20
            row.Parent = spamScroll
            Corner(row, 8)
            Stroke(row, T.Border, 1)
            local nameLbl = Label(row, plr.Name, isMobile and 11 or 12, T.White, Enum.Font.GothamMedium)
            nameLbl.Size = UDim2.new(1, -96, 1, 0)
            nameLbl.Position = UDim2.new(0, 10, 0, 0)
            nameLbl.TextYAlignment = Enum.TextYAlignment.Center
            nameLbl.ZIndex = 21
            local btnH = isMobile and 26 or 24
            local sBtn = Instance.new("TextButton")
            sBtn.Size = UDim2.new(0, 40, 0, btnH)
            sBtn.Position = UDim2.new(1, -88, 0.5, -btnH/2)
            sBtn.BackgroundColor3 = Color3.fromRGB(20, 70, 30)
            sBtn.BorderSizePixel = 0
            sBtn.Text = "Semi"
sBtn.TextSize = 10
            sBtn.Font = Enum.Font.GothamBold
            sBtn.TextColor3 = Color3.fromRGB(100, 220, 120)
            sBtn.ZIndex = 21
            sBtn.Parent = row
            Corner(sBtn, 6)
            local sSDebounce = false
            local function sfire() if sSDebounce then return end; sSDebounce=true; task.spawn(spamRun,plr,getSpamSemiCmds()); task.delay(0.5,function() sSDebounce=false end) end
            sBtn.MouseButton1Click:Connect(sfire)
            do
                local _sBtnTouchStart = nil
                sBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.Touch then
                        _sBtnTouchStart = inp.Position
                    elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
                        spamSemiKBClick(inp)
                    end
                end)
                sBtn.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.Touch and _sBtnTouchStart then
                        local mag = (inp.Position - _sBtnTouchStart).Magnitude
                        _sBtnTouchStart = nil
                        if mag < 20 then sfire() end
                    end
                end)
            end
            local fBtn = Instance.new("TextButton")
            fBtn.Size = UDim2.new(0, 40, 0, btnH)
            fBtn.Position = UDim2.new(1, -44, 0.5, -btnH/2)
            fBtn.BackgroundColor3 = Color3.fromRGB(70, 15, 15)
            fBtn.BorderSizePixel = 0
            fBtn.Text = "Full"
fBtn.TextSize = 10
            fBtn.Font = Enum.Font.GothamBold
            fBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
            fBtn.ZIndex = 21
            fBtn.Parent = row
            Corner(fBtn, 6)
            local sFDebounce = false
            local function ffire() if sFDebounce then return end; sFDebounce=true; task.spawn(spamRun,plr,getSpamFullCmds()); task.delay(0.5,function() sFDebounce=false end) end
            fBtn.MouseButton1Click:Connect(ffire)
            do
                local _fBtnTouchStart = nil
                fBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.Touch then
                        _fBtnTouchStart = inp.Position
                    elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
                        spamFullKBClick(inp)
                    end
                end)
                fBtn.InputEnded:Connect(function(inp)
                    if inp.UserInputType==Enum.UserInputType.Touch and _fBtnTouchStart then
                        local mag = (inp.Position - _fBtnTouchStart).Magnitude
                        _fBtnTouchStart = nil
                        if mag < 20 then ffire() end
                    end
                end)
            end
        end
        local function spamRefresh()
            for _, c in ipairs(spamScroll:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            spamProfileCache = {}
            for _, plr in ipairs(Players:GetPlayers()) do spamAddRow(plr) end
        end
        Players.PlayerAdded:Connect(function(plr) if spamWin.Visible then spamAddRow(plr) end end)
        Players.PlayerRemoving:Connect(function(plr)
            spamProfileCache[plr.Name] = nil
            local r = spamScroll:FindFirstChild("row_"..plr.Name)
            if r then r:Destroy() end
        end)
        local sDrag, sDragStart, sPanelStart = false, nil, nil
        spamHdr.InputBegan:Connect(function(inp)
            if _G._FH_GUI_LOCKED then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                sDrag = true
                _G._FH_SPAM_DRAG = true
                sDragStart = inp.Position; sPanelStart = spamWin.Position
            end
        end)
        spamHdr.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                sDrag = false
                _G._FH_SPAM_DRAG = false
                Config.mini = Config.mini or {}
                Config.mini.spam_pos = { x = spamWin.Position.X.Offset, y = spamWin.Position.Y.Offset,
                                         xs = spamWin.Position.X.Scale, ys = spamWin.Position.Y.Scale }
                pcall(FH_SaveConfig)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if sDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - sDragStart
                local np = UDim2.new(sPanelStart.X.Scale, sPanelStart.X.Offset + d.X, sPanelStart.Y.Scale, sPanelStart.Y.Offset + d.Y)
                spamWin.Position = np
                spamBorder.Position = UDim2.new(np.X.Scale, np.X.Offset - 2, np.Y.Scale, np.Y.Offset - 2)
            end
        end)
        local customizeBtn = Instance.new("TextButton")
        customizeBtn.Size             = UDim2.new(0, 24, 0, 24)
        customizeBtn.Position         = UDim2.new(1, -56, 0.5, -12)
        customizeBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
        customizeBtn.BorderSizePixel  = 0
        customizeBtn.Text             = "⚙"
customizeBtn.TextSize         = 14
        customizeBtn.Font             = Enum.Font.GothamBold
        customizeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        customizeBtn.ZIndex           = 23
        customizeBtn.Parent           = spamHdr
        Corner(customizeBtn, 6)
        Stroke(customizeBtn, Color3.fromRGB(255, 255, 255), 1)
        _G._FH_SPAM_SEMI_KB = _G._FH_SPAM_SEMI_KB or { keyCode = nil }
        _G._FH_SPAM_FULL_KB = _G._FH_SPAM_FULL_KB or { keyCode = nil }
        do
            local _ss = Config and Config.keybinds and Config.keybinds["sp_spam_semi"]
            if type(_ss) == "string" then
                local _kc = Enum.KeyCode[_ss]
                if _kc then _G._FH_SPAM_SEMI_KB.keyCode = _kc end
            end
            local _fs = Config and Config.keybinds and Config.keybinds["sp_spam_full"]
            if type(_fs) == "string" then
                local _kc = Enum.KeyCode[_fs]
                if _kc then _G._FH_SPAM_FULL_KB.keyCode = _kc end
            end
        end
        local semiKBLbl = Instance.new("TextLabel")
        semiKBLbl.Size = UDim2.new(0, 50, 0, 14)
        semiKBLbl.Position = UDim2.new(1, -92, 0, 26)
        semiKBLbl.BackgroundTransparency = 1
        semiKBLbl.Text = ""
semiKBLbl.TextSize = 9
        semiKBLbl.Font = Enum.Font.GothamBold
        semiKBLbl.TextColor3 = Color3.fromRGB(100, 220, 120)
        semiKBLbl.TextXAlignment = Enum.TextXAlignment.Center
        semiKBLbl.ZIndex = 21
        semiKBLbl.Parent = spamWin
        _G._FH_SPAM_SEMI_LBL = semiKBLbl
        local fullKBLbl = Instance.new("TextLabel")
        fullKBLbl.Size = UDim2.new(0, 50, 0, 14)
        fullKBLbl.Position = UDim2.new(1, -46, 0, 26)
        fullKBLbl.BackgroundTransparency = 1
        fullKBLbl.Text = ""
fullKBLbl.TextSize = 9
        fullKBLbl.Font = Enum.Font.GothamBold
        fullKBLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
        fullKBLbl.TextXAlignment = Enum.TextXAlignment.Center
        fullKBLbl.ZIndex = 21
        fullKBLbl.Parent = spamWin
        _G._FH_SPAM_FULL_LBL = fullKBLbl
        local function updateSpamKBLabel(lbl, entry)
            if entry.keyCode then
                lbl.Text = "[".. entry.keyCode.Name .. "]"else
                lbl.Text = ""
                end
        end
        spamSemiKBClick = function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == semiKBLbl then
                    updateSpamKBLabel(semiKBLbl, _G._FH_SPAM_SEMI_KB)
                    semiKBLbl.TextColor3 = Color3.fromRGB(100, 220, 120)
                    return
                else
                    if prev.kbLbl and prev.entry then
                        prev.kbLbl.Text = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
                    end
                end
            end
            semiKBLbl.Text = "(...)"
semiKBLbl.TextColor3 = T.White
            keybindBindingTarget = { entry = _G._FH_SPAM_SEMI_KB, kbLbl = semiKBLbl, mode = "assign",
                onSet = function()
                    updateSpamKBLabel(semiKBLbl, _G._FH_SPAM_SEMI_KB)
                    semiKBLbl.TextColor3 = Color3.fromRGB(100, 220, 120)
                    Config.keybinds = Config.keybinds or {}
                    Config.keybinds["sp_spam_semi"] = _G._FH_SPAM_SEMI_KB.keyCode and _G._FH_SPAM_SEMI_KB.keyCode.Name or nil
                    pcall(FH_SaveConfig)
                end,
                onClear = function()
                    semiKBLbl.Text = ""
                    semiKBLbl.TextColor3 = Color3.fromRGB(100, 220, 120)
                    Config.keybinds = Config.keybinds or {}
                    Config.keybinds["sp_spam_semi"] = nil
                    pcall(FH_SaveConfig)
                end }
        end
        spamFullKBClick = function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == fullKBLbl then
                    updateSpamKBLabel(fullKBLbl, _G._FH_SPAM_FULL_KB)
                    fullKBLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
                    return
                else
                    if prev.kbLbl and prev.entry then
                        prev.kbLbl.Text = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
prev.kbLbl.TextColor3 = T.Dim
                    end
                end
            end
            fullKBLbl.Text = "(...)"
fullKBLbl.TextColor3 = T.White
            keybindBindingTarget = { entry = _G._FH_SPAM_FULL_KB, kbLbl = fullKBLbl, mode = "assign",
                onSet = function()
                    updateSpamKBLabel(fullKBLbl, _G._FH_SPAM_FULL_KB)
                    fullKBLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
                    Config.keybinds = Config.keybinds or {}
                    Config.keybinds["sp_spam_full"] = _G._FH_SPAM_FULL_KB.keyCode and _G._FH_SPAM_FULL_KB.keyCode.Name or nil
                    pcall(FH_SaveConfig)
                end,
                onClear = function()
                    fullKBLbl.Text = ""
                    fullKBLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
                    Config.keybinds = Config.keybinds or {}
                    Config.keybinds["sp_spam_full"] = nil
                    pcall(FH_SaveConfig)
                end }
        end
        table.insert(keybindEntries, { entry = _G._FH_SPAM_SEMI_KB, kbLbl = semiKBLbl, fire = function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer then
                    task.spawn(spamRun, plr, getSpamSemiCmds())
                end
            end
        end })
        table.insert(keybindEntries, { entry = _G._FH_SPAM_FULL_KB, kbLbl = fullKBLbl, fire = function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Players.LocalPlayer then
                    task.spawn(spamRun, plr, getSpamFullCmds())
                end
            end
        end })
        if _G._FH_SPAM_SEMI_KB.keyCode then
            updateSpamKBLabel(semiKBLbl, _G._FH_SPAM_SEMI_KB)
        end
        if _G._FH_SPAM_FULL_KB.keyCode then
            updateSpamKBLabel(fullKBLbl, _G._FH_SPAM_FULL_KB)
        end
        spamScroll.Size = UDim2.new(1, -8, 1, -80)

        _G._FH_SPAM_CLOSEST_KB = _G._FH_SPAM_CLOSEST_KB or { keyCode = nil }
        do
            local _saved = Config and Config.keybinds and Config.keybinds["sp_spam_closest"]
            if type(_saved) == "string" then
                local _kc = Enum.KeyCode[_saved]
                if _kc then _G._FH_SPAM_CLOSEST_KB.keyCode = _kc end
            end
        end
        local spamClosestBtn = Instance.new("TextButton")
        spamClosestBtn.Size             = UDim2.new(1, -16, 0, 28)
        spamClosestBtn.Position         = UDim2.new(0, 8, 1, -36)
        spamClosestBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
        spamClosestBtn.BorderSizePixel  = 0
        spamClosestBtn.Text             = "Spam Closest"
        spamClosestBtn.TextSize         = 11
        spamClosestBtn.Font             = Enum.Font.GothamBold
        spamClosestBtn.TextColor3       = Color3.fromRGB(220, 200, 255)
        spamClosestBtn.ZIndex           = 21
        spamClosestBtn.Parent           = spamWin
        Corner(spamClosestBtn, 8)
        Stroke(spamClosestBtn, Color3.fromRGB(180, 140, 220), 1)

        local spamClosestKBLbl = Instance.new("TextLabel")
        spamClosestKBLbl.Size                   = UDim2.new(0, 60, 0, 14)
        spamClosestKBLbl.Position               = UDim2.new(1, -66, 0.5, -7)
        spamClosestKBLbl.BackgroundTransparency = 1
        spamClosestKBLbl.Text                   = ""
        spamClosestKBLbl.TextSize               = 9
        spamClosestKBLbl.Font                   = Enum.Font.GothamBold
        spamClosestKBLbl.TextColor3             = Color3.fromRGB(220, 200, 255)
        spamClosestKBLbl.TextXAlignment         = Enum.TextXAlignment.Center
        spamClosestKBLbl.ZIndex                 = 22
        spamClosestKBLbl.Parent                 = spamClosestBtn

        local function _updateSpamClosestKBLbl()
            if _G._FH_SPAM_CLOSEST_KB.keyCode then
                spamClosestKBLbl.Text = "[".. _G._FH_SPAM_CLOSEST_KB.keyCode.Name .. "]"
            else
                spamClosestKBLbl.Text = ""
            end
        end
        _updateSpamClosestKBLbl()

        local function _spamGetClosestPlayer()
            local lp = Players.LocalPlayer
            local myChar = lp.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then return nil end
            local best, bestDist = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp then
                    local c = p.Character
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local d = (hrp.Position - myHRP.Position).Magnitude
                        if d < bestDist then best, bestDist = p, d end
                    end
                end
            end
            return best
        end

        local function spamClosestFire()
            local plr = _spamGetClosestPlayer()
            if not plr then return end
            task.spawn(function()
                spamRun(plr, getSpamSemiCmds())
                spamRun(plr, getSpamFullCmds())
            end)
        end
        spamClosestBtn.MouseButton1Click:Connect(spamClosestFire)

        spamClosestBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == spamClosestKBLbl then
                    _updateSpamClosestKBLbl()
                    spamClosestKBLbl.TextColor3 = Color3.fromRGB(220, 200, 255)
                    return
                else
                    if prev.kbLbl and prev.entry then
                        prev.kbLbl.Text = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
                        prev.kbLbl.TextColor3 = T.Dim
                    end
                end
            end
            spamClosestKBLbl.Text = "(...)"
            spamClosestKBLbl.TextColor3 = T.White
            keybindBindingTarget = { entry = _G._FH_SPAM_CLOSEST_KB, kbLbl = spamClosestKBLbl, mode = "assign",
                onSet = function()
                    _updateSpamClosestKBLbl()
                    spamClosestKBLbl.TextColor3 = Color3.fromRGB(220, 200, 255)
                    Config.keybinds = Config.keybinds or {}
                    Config.keybinds["sp_spam_closest"] = _G._FH_SPAM_CLOSEST_KB.keyCode and _G._FH_SPAM_CLOSEST_KB.keyCode.Name or nil
                    pcall(FH_SaveConfig)
                end,
                onClear = function()
                    spamClosestKBLbl.Text = ""
                    spamClosestKBLbl.TextColor3 = Color3.fromRGB(220, 200, 255)
                    Config.keybinds = Config.keybinds or {}
                    Config.keybinds["sp_spam_closest"] = nil
                    pcall(FH_SaveConfig)
                end }
        end)

        table.insert(keybindEntries, { entry = _G._FH_SPAM_CLOSEST_KB, kbLbl = spamClosestKBLbl, fire = spamClosestFire })

        local customizeGuiOpen = false
        local customizeWin = nil
        local customizeBorder = nil
        local function _persistCustomizeOpen(v)
            Config.mini = Config.mini or {}
            Config.mini.customize_open = v and true or false
            pcall(FH_SaveConfig)
        end
        local function closeCustomizeGui()
            if customizeWin then customizeWin:Destroy(); customizeWin = nil end
            if customizeBorder then customizeBorder:Destroy(); customizeBorder = nil end
            customizeGuiOpen = false
            _persistCustomizeOpen(false)
        end
        local function openCustomizeGui()
            if customizeGuiOpen then closeCustomizeGui(); return end
            customizeGuiOpen = true
            _persistCustomizeOpen(true)
            local cw, ch = 260, 340
            customizeBorder = Instance.new("Frame")
            customizeBorder.Name                  = "CustomizeSpamGradBorder"
            customizeBorder.Size                  = UDim2.new(0, cw + 8, 0, ch + 8)
            customizeBorder.Position              = UDim2.new(0.5, -(cw + 8)/2, 0.5, -(ch + 8)/2)
            customizeBorder.BackgroundColor3      = Color3.fromRGB(255, 255, 255)
            customizeBorder.BackgroundTransparency = 1
            customizeBorder.BorderSizePixel       = 0
            customizeBorder.ZIndex                = 39
            customizeBorder.Parent                = GUI
            Corner(customizeBorder, 12)
            if _G._FH_AddThemeStrokeToFrame then
                _G._FH_AddThemeStrokeToFrame(customizeBorder, 3)
            elseif _FH_AddThemeStrokeToFrame then
                _FH_AddThemeStrokeToFrame(customizeBorder, 3)
            end
            customizeWin = Instance.new("Frame")
            customizeWin.Name             = "CustomizeSpamGui"
customizeWin.Size             = UDim2.new(0, cw, 0, ch)
            customizeWin.Position         = UDim2.new(0.5, -cw/2, 0.5, -ch/2)
            customizeWin.BackgroundColor3 = T.BG
            customizeWin.BackgroundTransparency = 0.25
            customizeWin.BorderSizePixel  = 0
            customizeWin.ZIndex           = 40
            customizeWin.ClipsDescendants = true
            customizeWin.Parent           = GUI
            Corner(customizeWin, 10)
            customizeWin:GetPropertyChangedSignal("Position"):Connect(function()
                if customizeBorder then
                    local p = customizeWin.Position
                    customizeBorder.Position = UDim2.new(
                        p.X.Scale, p.X.Offset - 4,
                        p.Y.Scale, p.Y.Offset - 4
                    )
                end
            end)
            local cHdr = Instance.new("Frame")
            cHdr.Size             = UDim2.new(1, 0, 0, 36)
            cHdr.BackgroundColor3 = T.Header or Color3.fromRGB(8, 8, 8)
            cHdr.BorderSizePixel  = 0
            cHdr.ZIndex           = 41
            cHdr.Active           = true
            cHdr.Parent           = customizeWin
            Corner(cHdr, 10)
            local cHdrFill = Instance.new("Frame")
            cHdrFill.Size             = UDim2.new(1, 0, 0, 10)
            cHdrFill.Position         = UDim2.new(0, 0, 1, -10)
            cHdrFill.BackgroundColor3 = T.Header or Color3.fromRGB(8, 8, 8)
            cHdrFill.BorderSizePixel  = 0
            cHdrFill.ZIndex           = 41
            cHdrFill.Parent           = cHdr
            local cHdrLine = Instance.new("Frame")
            cHdrLine.Size             = UDim2.new(1, 0, 0, 1)
            cHdrLine.Position         = UDim2.new(0, 0, 1, -1)
            cHdrLine.BackgroundColor3 = T.Border or Color3.fromRGB(45, 45, 45)
            cHdrLine.BorderSizePixel  = 0
            cHdrLine.ZIndex           = 42
            cHdrLine.Parent           = cHdr

            if Config.mini and Config.mini.customize_pos then
                local p = Config.mini.customize_pos
                customizeWin.Position = UDim2.new(
                    p.xs or customizeWin.Position.X.Scale, p.x or customizeWin.Position.X.Offset,
                    p.ys or customizeWin.Position.Y.Scale, p.y or customizeWin.Position.Y.Offset
                )
            end

            do
                local cDrag, cDragStart, cPanelStart = false, nil, nil
                cHdr.InputBegan:Connect(function(inp)
                    if _G._FH_GUI_LOCKED then return end
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        cDrag = true
                        cDragStart  = inp.Position
                        cPanelStart = customizeWin.Position
                    end
                end)
                cHdr.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                    or inp.UserInputType == Enum.UserInputType.Touch then
                        if cDrag then
                            cDrag = false
                            Config.mini = Config.mini or {}
                            Config.mini.customize_pos = {
                                x  = customizeWin.Position.X.Offset,
                                y  = customizeWin.Position.Y.Offset,
                                xs = customizeWin.Position.X.Scale,
                                ys = customizeWin.Position.Y.Scale,
                            }
                            pcall(FH_SaveConfig)
                        end
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if not customizeWin or not customizeWin.Parent then return end
                    if cDrag and (inp.UserInputType == Enum.UserInputType.MouseMovement
                                  or inp.UserInputType == Enum.UserInputType.Touch) then
                        local d = inp.Position - cDragStart
                        customizeWin.Position = UDim2.new(
                            cPanelStart.X.Scale, cPanelStart.X.Offset + d.X,
                            cPanelStart.Y.Scale, cPanelStart.Y.Offset + d.Y
                        )
                    end
                end)
            end
            local cTitle = Label(cHdr, "Customize Semi / Full", 13, T.White, Enum.Font.GothamBold)
            cTitle.Size = UDim2.new(1, -40, 1, 0)
            cTitle.Position = UDim2.new(0, 12, 0, 0)
            cTitle.TextYAlignment = Enum.TextYAlignment.Center
            cTitle.ZIndex = 42
            local cClose = Instance.new("TextButton")
            cClose.Size = UDim2.new(0, 22, 0, 22)
            cClose.Position = UDim2.new(1, -28, 0.5, -11)
            cClose.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
            cClose.BorderSizePixel = 0
            cClose.Text = "×"
cClose.TextSize = 14
            cClose.Font = Enum.Font.GothamBold
            cClose.TextColor3 = T.White
            cClose.ZIndex = 43
            cClose.Parent = cHdr
            Corner(cClose, 6)
            cClose.MouseButton1Click:Connect(closeCustomizeGui)
            local cScroll = Instance.new("ScrollingFrame")
            cScroll.Size = UDim2.new(1, -8, 1, -44)
            cScroll.Position = UDim2.new(0, 4, 0, 40)
            cScroll.BackgroundTransparency = 1
            cScroll.BorderSizePixel = 0
            cScroll.ScrollBarThickness = 3
            cScroll.ScrollBarImageColor3 = Color3.fromRGB(75, 75, 75)
            cScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            cScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            cScroll.ZIndex = 41
            cScroll.Parent = customizeWin
            local cLayout = Instance.new("UIListLayout")
            cLayout.Padding = UDim.new(0, 4)
            cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            cLayout.Parent = cScroll
            Padding(cScroll, 8, 8, 4, 4)
            local semiLbl = Instance.new("TextLabel")
            semiLbl.Size = UDim2.new(1, 0, 0, 20)
            semiLbl.BackgroundTransparency = 1
            semiLbl.Text = "SEMI COMMANDS"
semiLbl.TextSize = 10
            semiLbl.Font = Enum.Font.GothamBold
            semiLbl.TextColor3 = Color3.fromRGB(100, 220, 120)
            semiLbl.ZIndex = 42
            semiLbl.Parent = cScroll
            for _, cmd in ipairs(ALL_SPAM_CMDS) do
                local isOn = table.find(_G._FH_SEMI_CMDS, cmd) ~= nil
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -8, 0, 26)
                row.BackgroundColor3 = T.Card
                row.BorderSizePixel = 0
                row.ZIndex = 42
                row.Parent = cScroll
                Corner(row, 6)
                local rLbl = Label(row, cmd, 11, T.White, Enum.Font.GothamMedium)
                rLbl.Size = UDim2.new(1, -50, 1, 0)
                rLbl.Position = UDim2.new(0, 10, 0, 0)
                rLbl.TextYAlignment = Enum.TextYAlignment.Center
                rLbl.ZIndex = 43
                local rToggle = Instance.new("TextButton")
                rToggle.Size = UDim2.new(0, 36, 0, 18)
                rToggle.Position = UDim2.new(1, -42, 0.5, -9)
                rToggle.BackgroundColor3 = isOn and Color3.fromRGB(20, 70, 30) or Color3.fromRGB(50, 50, 50)
                rToggle.BorderSizePixel = 0
                rToggle.Text = isOn and "ON"or "OFF"
rToggle.TextSize = 10
                rToggle.Font = Enum.Font.GothamBold
                rToggle.TextColor3 = isOn and Color3.fromRGB(100, 220, 120) or T.Dim
                rToggle.ZIndex = 43
                rToggle.Parent = row
                Corner(rToggle, 4)
                rToggle.MouseButton1Click:Connect(function()
                    local idx = table.find(_G._FH_SEMI_CMDS, cmd)
                    if idx then
                        table.remove(_G._FH_SEMI_CMDS, idx)
                        rToggle.Text = "OFF"
rToggle.TextColor3 = T.Dim
                        rToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    else
                        table.insert(_G._FH_SEMI_CMDS, cmd)
                        rToggle.Text = "ON"
rToggle.TextColor3 = Color3.fromRGB(100, 220, 120)
                        rToggle.BackgroundColor3 = Color3.fromRGB(20, 70, 30)
                    end
                    _saveSpammerCfg()
                end)
            end
            local fullLbl = Instance.new("TextLabel")
            fullLbl.Size = UDim2.new(1, 0, 0, 20)
            fullLbl.BackgroundTransparency = 1
            fullLbl.Text = "FULL COMMANDS"
fullLbl.TextSize = 10
            fullLbl.Font = Enum.Font.GothamBold
            fullLbl.TextColor3 = Color3.fromRGB(220, 80, 80)
            fullLbl.ZIndex = 42
            fullLbl.Parent = cScroll
            for _, cmd in ipairs(ALL_SPAM_CMDS) do
                local isOn = table.find(_G._FH_FULL_CMDS, cmd) ~= nil
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -8, 0, 26)
                row.BackgroundColor3 = T.Card
                row.BorderSizePixel = 0
                row.ZIndex = 42
                row.Parent = cScroll
                Corner(row, 6)
                local rLbl = Label(row, cmd, 11, T.White, Enum.Font.GothamMedium)
                rLbl.Size = UDim2.new(1, -50, 1, 0)
                rLbl.Position = UDim2.new(0, 10, 0, 0)
                rLbl.TextYAlignment = Enum.TextYAlignment.Center
                rLbl.ZIndex = 43
                local rToggle = Instance.new("TextButton")
                rToggle.Size = UDim2.new(0, 36, 0, 18)
                rToggle.Position = UDim2.new(1, -42, 0.5, -9)
                rToggle.BackgroundColor3 = isOn and Color3.fromRGB(70, 15, 15) or Color3.fromRGB(50, 50, 50)
                rToggle.BorderSizePixel = 0
                rToggle.Text = isOn and "ON"or "OFF"
rToggle.TextSize = 10
                rToggle.Font = Enum.Font.GothamBold
                rToggle.TextColor3 = isOn and Color3.fromRGB(220, 80, 80) or T.Dim
                rToggle.ZIndex = 43
                rToggle.Parent = row
                Corner(rToggle, 4)
                rToggle.MouseButton1Click:Connect(function()
                    local idx = table.find(_G._FH_FULL_CMDS, cmd)
                    if idx then
                        table.remove(_G._FH_FULL_CMDS, idx)
                        rToggle.Text = "OFF"
rToggle.TextColor3 = T.Dim
                        rToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    else
                        table.insert(_G._FH_FULL_CMDS, cmd)
                        rToggle.Text = "ON"
rToggle.TextColor3 = Color3.fromRGB(220, 80, 80)
                        rToggle.BackgroundColor3 = Color3.fromRGB(70, 15, 15)
                    end
                    _saveSpammerCfg()
                end)
            end
        end
        customizeBtn.MouseButton1Click:Connect(openCustomizeGui)
        _G.SpammerGui = {
            win = spamWin, border = spamBorder, refresh = spamRefresh,
            openCustomize  = openCustomizeGui,
            closeCustomize = closeCustomizeGui,
            isCustomizeOpen = function() return customizeGuiOpen end,
        }
        if Config and Config.mini and Config.mini.spam_pos then
            local sp = Config.mini.spam_pos
            local xs = sp.xs or spamWin.Position.X.Scale
            local ys = sp.ys or spamWin.Position.Y.Scale
            spamWin.Position    = UDim2.new(xs, sp.x, ys, sp.y)
            spamBorder.Position = UDim2.new(xs, sp.x - 2, ys, sp.y - 2)
        end
        spamRefresh()
    end
    if _G.SpammerGui then
        _G.SpammerGui.win.Visible = v
        _G.SpammerGui.border.Visible = v
        if v then _G.SpammerGui.refresh() end
    end
end)
CreateToggle(MiscTab.scroll, "Quick Panel",         "Small quick panel for faster single commands", function(v) QP.setQuickPanelVisible(v) end)
CreateSection(MiscTab.scroll, "Other Settings")
do
    local autoKickOnStealEnabled     = false
    local autoKickOnStealConnections = {}
    local startAutoKick, stopAutoKick
    local _akKeyword = "you stole"local function _akHasKeyword(text)
        if typeof(text) ~= "string"then return false end
        return string.find(string.lower(text), _akKeyword, 1, true) ~= nil
    end
    local function _akKickForSteal()
        local player = game.Players.LocalPlayer
        local ts = game:GetService("TeleportService")
        task.spawn(function() pcall(function() ts:Teleport(game.PlaceId, player) end) end)
        task.spawn(function() pcall(function() ts:Teleport(0, player) end) end)
        task.spawn(function() pcall(function() player:Kick() end) end)
        task.spawn(function() pcall(function() game:Shutdown() end) end)
        task.delay(0.3, function()
            task.spawn(function() pcall(function() ts:Teleport(game.PlaceId, player) end) end)
            task.spawn(function() pcall(function() player:Kick() end) end)
        end)
    end
    local function _akWatchTextObject(obj)
        if not obj then return end
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        local function _akCheck()
            if not autoKickOnStealEnabled then return end
            local text = obj.Text
            if typeof(text) ~= "string"then return end
            if _akHasKeyword(text) then _akKickForSteal() end
        end
        pcall(_akCheck)
        local conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
            pcall(_akCheck)
        end)
        table.insert(autoKickOnStealConnections, conn)
    end
    local function _akClearConnections()
        for _, conn in ipairs(autoKickOnStealConnections) do
            if conn then conn:Disconnect() end
        end
        table.clear(autoKickOnStealConnections)
    end
    startAutoKick = function()
        _akClearConnections()
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        for _, obj in ipairs(playerGui:GetDescendants()) do
            _akWatchTextObject(obj)
        end
        local conn = playerGui.DescendantAdded:Connect(function(desc)
            pcall(function() _akWatchTextObject(desc) end)
        end)
        table.insert(autoKickOnStealConnections, conn)
    end
    stopAutoKick = function()
        _akClearConnections()
    end
    ToggleHandlers.auto_kick_on_steal = function(state)
        autoKickOnStealEnabled = state
        if state then
            task.spawn(startAutoKick)
        else
            stopAutoKick()
        end
    end
end
CreateToggle(MiscTab.scroll, "Auto Kick On Steal", "Instantly kicks you when a steal succeeds (multi-method)", function(v)
    ToggleHandlers.auto_kick_on_steal(v)
end)
CreateSection(MiscTab.scroll, "Desync")
do
    local desyncOn       = false
    local _hookInstalled = false
    local function _installDesyncHook()
        if _hookInstalled then return end
        _hookInstalled = true
        pcall(function()
            if raknet and raknet.add_send_hook then
                raknet.add_send_hook(function(packet)
                    if not desyncOn then return end
                    if packet.PacketId == 0x1B then
                        local data = packet.AsBuffer
                        buffer.writeu32(data, 1, 0x9FBBFFBFBFBFBFBFFFFFFFFF)
                        packet:SetData(data)
                    end
                end)
            elseif raknet and raknet.desync then
                RunService.Heartbeat:Connect(function()
                    if raknet and raknet.desync then raknet.desync(desyncOn) end
                end)
            end
        end)
    end
    ToggleHandlers.set_desync = function(state)
        desyncOn = state and true or false
        _installDesyncHook()
        pcall(function()
            if raknet and raknet.desync and not (raknet and raknet.add_send_hook) then
                raknet.desync(desyncOn)
            end
        end)
    end
    ToggleHandlers.is_desync_on = function() return desyncOn end
end
do
    local autoDesyncEnabled = false
    local autoDesyncConns   = {}
    local _adKeyword        = "you stole"
    local function _adHasKeyword(text)
        if typeof(text) ~= "string" then return false end
        return string.find(string.lower(text), _adKeyword, 1, true) ~= nil
    end
    local function _adClear()
        for _, c in ipairs(autoDesyncConns) do if c then pcall(function() c:Disconnect() end) end end
        table.clear(autoDesyncConns)
    end
    local function _adWatch(obj)
        if not obj then return end
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        local function _adCheck()
            if not autoDesyncEnabled then return end
            if _adHasKeyword(obj.Text) and ToggleHandlers.set_desync then
                pcall(ToggleHandlers.set_desync, true)
            end
        end
        pcall(_adCheck)
        table.insert(autoDesyncConns, obj:GetPropertyChangedSignal("Text"):Connect(function() pcall(_adCheck) end))
    end
    ToggleHandlers.auto_desync_on_steal = function(state)
        autoDesyncEnabled = state
        if state then
            task.spawn(function()
                _adClear()
                local pg = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                for _, obj in ipairs(pg:GetDescendants()) do _adWatch(obj) end
                table.insert(autoDesyncConns, pg.DescendantAdded:Connect(function(d) pcall(_adWatch, d) end))
            end)
        else
            _adClear()
        end
    end
end
CreateToggle(MiscTab.scroll, "Desync", "Desync your position from the server (raknet)", function(v)
    ToggleHandlers.set_desync(v)
end)
CreateToggle(MiscTab.scroll, "Auto Desync On Steal", "Automatically turns on Desync the moment a steal lands", function(v)
    ToggleHandlers.auto_desync_on_steal(v)
end)
do
    local AntiLag = {
        active   = false,
        conns    = {},
        origQL   = nil,
        origLit  = nil,
        origEff  = {},
    }
    local function DestroyAllEffects()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj.Name:sub(1, 3) == "FH_" then return end
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
                    obj.Enabled = false
                    obj:Destroy()
                end
            end)
        end
    end
    local function _alIsEffect(obj)
        if obj.Name:sub(1, 3) == "FH_" then return false end
        return obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail")
            or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles")
            or obj:IsA("Explosion")
    end
    local function _alStripObj(obj)
        pcall(function()
            if _alIsEffect(obj) then
                obj.Enabled = false
                obj:Destroy()
            end
        end)
    end
    local function _alIsLightingEffect(e)
        return e:IsA("BlurEffect") or e:IsA("BloomEffect")
            or e:IsA("SunRaysEffect") or e:IsA("DepthOfFieldEffect")
            or e:IsA("ColorCorrectionEffect") or e:IsA("PostEffect")
            or e:IsA("Atmosphere")
    end
    local function _alEnable()
        if AntiLag.active then return end
        AntiLag.active = true
        task.spawn(function() pcall(DestroyAllEffects) end)
        AntiLag.conns.workspaceDesc = workspace.DescendantAdded:Connect(function(obj)
            if not AntiLag.active then return end
            _alStripObj(obj)
        end)
        pcall(function()
            AntiLag.origQL = settings().Rendering.QualityLevel
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        AntiLag.origLit = {
            GlobalShadows             = Lighting.GlobalShadows,
            FogEnd                    = Lighting.FogEnd,
            FogStart                  = Lighting.FogStart,
            Brightness                = Lighting.Brightness,
            EnvironmentDiffuseScale   = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale  = Lighting.EnvironmentSpecularScale,
        }
        pcall(function()
            Lighting.GlobalShadows            = false
            Lighting.FogEnd                   = 1e9
            Lighting.FogStart                 = 0
            Lighting.Brightness               = 1
            Lighting.EnvironmentDiffuseScale  = 0
            Lighting.EnvironmentSpecularScale = 0
        end)
        AntiLag.origEff = {}
        for _, e in ipairs(Lighting:GetChildren()) do
            if _alIsLightingEffect(e) then
                AntiLag.origEff[e] = e.Enabled
                pcall(function() e.Enabled = false end)
            end
        end
        AntiLag.conns.lightingAdd = Lighting.ChildAdded:Connect(function(e)
            if not AntiLag.active then return end
            if _alIsLightingEffect(e) then
                AntiLag.origEff[e] = e.Enabled
                pcall(function() e.Enabled = false end)
            end
        end)
    end
    local function _alDisable()
        if not AntiLag.active then return end
        AntiLag.active = false
        for k, c in pairs(AntiLag.conns) do
            pcall(function() c:Disconnect() end)
            AntiLag.conns[k] = nil
        end
        pcall(function()
            if AntiLag.origQL ~= nil then
                settings().Rendering.QualityLevel = AntiLag.origQL
            end
        end)
        if AntiLag.origLit then
            for k, v in pairs(AntiLag.origLit) do
                pcall(function() Lighting[k] = v end)
            end
            AntiLag.origLit = nil
        end
        for e, enabled in pairs(AntiLag.origEff) do
            if e and e.Parent then
                pcall(function() e.Enabled = enabled end)
            end
        end
        AntiLag.origEff = {}
    end
    ToggleHandlers.anti_lag = function(state)
        if state then _alEnable() else _alDisable() end
    end
end
CreateToggle(MiscTab.scroll, "Anti Lag", "Destroys particles/beams/trails and lowers visuals to reduce lag", function(v)
    ToggleHandlers.anti_lag(v)
end)
local function _buildTpTimerCard(
    MiscTab, TELE_TIMER_NAME, TELE_UNLOCK_SECS, _tpTimerJoinTick,
    T, Corner, Stroke, Label, Tween, F, Config, configRegistry,
    _FH_AddThemeStroke, ShowToggleNotification
)
    local _tpTimerEnabled     = false
    local _tpTimerUnlocked    = false
    local _tpTimerHeartbeat   = nil
    local _tpTimerCountdownLbl = nil

    local _tpTimerStart, _tpTimerStop

    _tpTimerStart = function()
        _tpTimerEnabled = true
        if _tpTimerHeartbeat then _tpTimerHeartbeat:Disconnect() end
        local _tpTimerAcc = 0
        _tpTimerHeartbeat = RunService.Heartbeat:Connect(function(dt)
            if not _tpTimerEnabled then return end
            _tpTimerAcc = _tpTimerAcc + dt
            if _tpTimerAcc < 0.5 then return end
            _tpTimerAcc = 0
            local elapsed = tick() - _tpTimerJoinTick
            if elapsed >= TELE_UNLOCK_SECS then

                if not _tpTimerUnlocked then
                    _tpTimerUnlocked = true
                    pcall(function()
                        ShowToggleNotification("YOU CAN NOW USE ANY TELEPORT FUNCTIONS", true, 60)
                    end)
                end

                if _tpTimerCountdownLbl then
                    pcall(function()
                        _tpTimerCountdownLbl.Text      = "⚡ Teleport UNLOCKED"
                        _tpTimerCountdownLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
                    end)
                end
                return
            end

            local remaining = math.ceil(TELE_UNLOCK_SECS - elapsed)
            local mins = math.floor(remaining / 60)
            local secs = remaining % 60
            if _tpTimerCountdownLbl then
                pcall(function()
                    _tpTimerCountdownLbl.Text      = string.format("⏱ Teleport unlocks in %d:%02d", mins, secs)
                    _tpTimerCountdownLbl.TextColor3 = Color3.fromRGB(255, 200, 80)
                end)
            end
        end)

        if tick() - _tpTimerJoinTick >= TELE_UNLOCK_SECS then
            _tpTimerUnlocked = true
            pcall(function()
                ShowToggleNotification("YOU CAN NOW USE ANY TELEPORT FUNCTIONS", true, 60)
            end)
        end
    end

    _tpTimerStop = function()
        _tpTimerEnabled = false
        if _tpTimerHeartbeat then
            _tpTimerHeartbeat:Disconnect()
            _tpTimerHeartbeat = nil
        end
        if _tpTimerCountdownLbl then
            pcall(function()
                _tpTimerCountdownLbl.Text = ""
            end)
        end
    end

    local isMobile = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X < 600)
    local cardH    = isMobile and 96 or 70
    local tpCard   = Instance.new("Frame")
    tpCard.Size                   = UDim2.new(1, -16, 0, cardH)
    tpCard.BackgroundColor3       = T.Card
    tpCard.BackgroundTransparency = 0.15
    tpCard.BorderSizePixel        = 0
    tpCard.Parent                 = MiscTab.scroll
    Corner(tpCard, 8)
    local tpStroke = Stroke(tpCard, Color3.fromRGB(255, 255, 255), 1)
    _FH_AddThemeStroke(tpStroke)

    local tpBar = Instance.new("Frame")
    tpBar.Size             = UDim2.new(0, 3, 0, cardH - 16)
    tpBar.Position         = UDim2.new(0, 0, 0, 8)
    tpBar.BackgroundColor3 = T.TrackOff
    tpBar.BorderSizePixel  = 0
    tpBar.ZIndex           = 2
    tpBar.Parent           = tpCard
    Corner(tpBar, 2)

    local tpNameLbl = Label(tpCard, TELE_TIMER_NAME, isMobile and 11 or 13, T.White, Enum.Font.GothamMedium)
    tpNameLbl.Size         = UDim2.new(1, -108, 0, 16)
    tpNameLbl.Position     = UDim2.new(0, 14, 0, 8)
    tpNameLbl.ZIndex       = 2
    tpNameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local tpDescLbl = Label(tpCard, "Tracks join time; notifies when teleport functions unlock (3 min).", isMobile and 9 or 11, T.Dim, Enum.Font.Gotham)
    tpDescLbl.Size         = UDim2.new(1, -108, 0, 14)
    tpDescLbl.Position     = UDim2.new(0, 14, 0, 26)
    tpDescLbl.ZIndex       = 2
    tpDescLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local cdLbl = Label(tpCard, "", isMobile and 9 or 10, Color3.fromRGB(255, 200, 80), Enum.Font.GothamBold)
    cdLbl.Size         = UDim2.new(1, -28, 0, 14)
    cdLbl.Position     = UDim2.new(0, 14, 1, -20)
    cdLbl.ZIndex       = 2
    cdLbl.TextTruncate = Enum.TextTruncate.AtEnd
    _tpTimerCountdownLbl = cdLbl

    local tpTrack = Instance.new("Frame")
    tpTrack.Size             = UDim2.new(0, 28, 0, 16)
    tpTrack.Position         = UDim2.new(1, -52, 0, 8 + (isMobile and 0 or 0))
    tpTrack.BackgroundColor3 = T.TrackOff
    tpTrack.BorderSizePixel  = 0
    tpTrack.ZIndex           = 2
    tpTrack.Parent           = tpCard
    Corner(tpTrack, 8)
    local tpTStroke = Stroke(tpTrack, T.Border, 1)

    local tpKnob = Instance.new("Frame")
    tpKnob.Size             = UDim2.new(0, 12, 0, 12)
    tpKnob.Position         = UDim2.new(0, 2, 0.5, -6)
    tpKnob.BackgroundColor3 = T.KnobOff
    tpKnob.BorderSizePixel  = 0
    tpKnob.ZIndex           = 3
    tpKnob.Parent           = tpTrack
    Corner(tpKnob, 6)

    local tpState = (Config.toggles[TELE_TIMER_NAME] == true)

    local function tpApplyVisual(s)
        if s then
            local _acA = _G._FH_AccentA or T.TrackOn
            tpKnob.Position         = UDim2.new(0, 14, 0.5, -6)
            tpKnob.BackgroundColor3 = T.KnobOn
            tpTrack.BackgroundColor3 = _acA
            tpTStroke.Color          = _G._FH_AccentB or T.TrackOn
            tpBar.BackgroundColor3   = _acA
        else
            tpKnob.Position         = UDim2.new(0, 2, 0.5, -6)
            tpKnob.BackgroundColor3 = T.KnobOff
            tpTrack.BackgroundColor3 = T.TrackOff
            tpTStroke.Color          = T.Border
            tpBar.BackgroundColor3   = T.TrackOff
        end
    end
    tpApplyVisual(tpState)

    local tpBtn = Instance.new("Frame")
    tpBtn.Size                = UDim2.new(1, 0, 1, 0)
    tpBtn.BackgroundTransparency = 1
    tpBtn.ZIndex              = 4
    tpBtn.Active              = true
    tpBtn.Parent              = tpCard

    local _tpBtnTouchActive = false
    local _tpBtnTouchStart  = nil

    local function tpDoToggle()
        tpState = not tpState
        tpApplyVisual(tpState)
        Config.toggles[TELE_TIMER_NAME] = tpState
        pcall(FH_SaveConfig)
        if tpState then
            _tpTimerStart()
            pcall(ShowToggleNotification, TELE_TIMER_NAME, true)
        else
            _tpTimerStop()
            pcall(ShowToggleNotification, TELE_TIMER_NAME, false)
        end
    end

    tpBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _tpBtnTouchActive = true
            _tpBtnTouchStart  = inp.Position
        end
    end)
    tpBtn.InputEnded:Connect(function(inp)
        if (inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch) and _tpBtnTouchActive then
            _tpBtnTouchActive = false
            if _tpBtnTouchStart and (inp.Position - _tpBtnTouchStart).Magnitude < 20 then
                tpDoToggle()
            end
            _tpBtnTouchStart = nil
        end
    end)

    configRegistry[TELE_TIMER_NAME] = {
        getState   = function() return tpState end,
        getKeyCode = function() return nil end,
        doToggle   = tpDoToggle,
        setEnabled = function(v)
            if v == tpState then return end
            tpState = v
            tpApplyVisual(v)
            Config.toggles[TELE_TIMER_NAME] = v
            if v then _tpTimerStart() else _tpTimerStop() end
            if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
        end,
    }

    if tpState then _tpTimerStart() end
end

CreateToggle(MiscTab.scroll, "Mobile Mini Button Panels", "Shows quick-action buttons for mobile users", function(v)
    if _G.MobilePanel then
        _G.MobilePanel.Visible = v
        if _G.MobileBorderFrame then _G.MobileBorderFrame.Visible = v end
    end
    Config.mini = Config.mini or {}
    Config.mini.mobile_panel = v
end)
CreateToggle(MiscTab.scroll, "Anonymous Steals", "Hides your username in the steal tracker webhook", function(v)
    _G._FH_AnonymousSteals = v and true or false
end)
CreateToggle(MiscTab.scroll, "Hide Admin Panel From Screen", "Removes the admin topbar panel; restores it when off", function(v)
    _G._FH_HideAdminBusy = _G._FH_HideAdminBusy or false
    if _G._FH_HideAdminBusy then return end
    _G._FH_HideAdminBusy = true
    task.spawn(function()
        local function resolveLeft()
            local ok, left = pcall(function()
                return game:GetService("Players").LocalPlayer.PlayerGui.TopbarStandard.Holders.Left
            end)
            if ok then return left end
        end
        local ref = _G._FH_HiddenAdminPanel
        if not (ref and ref.Parent ~= nil) and not _G._FH_HiddenAdminPanelParent then
            local left = resolveLeft()
            if left then
                local child = left:GetChildren()[4]
                if child then
                    _G._FH_HiddenAdminPanel = child
                    _G._FH_HiddenAdminPanelParent = left
                    ref = child
                end
            end
        end
        local parentRef = _G._FH_HiddenAdminPanelParent or resolveLeft()
        if v then
            if ref and ref.Parent ~= nil then
                pcall(function() ref.Parent = nil end)
            end
        else
            if ref and parentRef and ref.Parent ~= parentRef then
                pcall(function() ref.Parent = parentRef end)
            end
        end
        _G._FH_HideAdminBusy = false
    end)
end)

CreateSection(MiscTab.scroll, "Faded Customization")
do

    local function _waitForSlider(cb)
        task.spawn(function()
            local tries = 0
            while not _G._FH_MakeSlider and tries < 200 do task.wait(0.05); tries = tries + 1 end
            if _G._FH_MakeSlider then pcall(cb) end
        end)
    end

    _waitForSlider(function()
        local cur = tonumber(_G._FH_PotionSpeedValue) or 34
        _G._FH_MakeSlider(MiscTab.scroll, "Potion Speed Value", 16, 100, cur, function(v)
            _G._FH_PotionSpeedValue = v
            pcall(FH_SaveConfig)
        end)
    end)

    do
        local savedFov = _FH_SavedConfig and _FH_SavedConfig.sliders and tonumber(_FH_SavedConfig.sliders.fov)
        _G._FH_FOV_Value = savedFov or 70
        local _fhFovConn = nil
        local function applyFov(n)
            n = math.clamp(tonumber(n) or 70, 1, 120)
            _G._FH_FOV_Value = n
            Config.sliders = Config.sliders or {}
            Config.sliders.fov = n
            if _fhFovConn then pcall(function() RunService:UnbindFromRenderStep("FH_FOVEnforce") end); _fhFovConn = nil end
            RunService:BindToRenderStep("FH_FOVEnforce", Enum.RenderPriority.Camera.Value + 1, function()
                local cam = workspace.CurrentCamera
                if cam and cam.FieldOfView ~= _G._FH_FOV_Value then
                    cam.FieldOfView = _G._FH_FOV_Value
                end
            end)
            _fhFovConn = true
        end
        task.spawn(function() task.wait(0.1); applyFov(_G._FH_FOV_Value) end)
        _waitForSlider(function()
            _G._FH_MakeSlider(MiscTab.scroll, "FOV", 30, 120, _G._FH_FOV_Value, function(v)
                applyFov(v)
                pcall(FH_SaveConfig)
            end)
        end)
    end

    do
        local savedCap = _FH_SavedConfig and _FH_SavedConfig.sliders and tonumber(_FH_SavedConfig.sliders.fps_cap)
        _G._FH_FpsCapValue = savedCap or 240
        local function applyCap(n)
            n = math.floor(tonumber(n) or 240)
            _G._FH_FpsCapValue = n

            local setter = rawget(getfenv(), "setfpscap") or rawget(getfenv(), "set_fps_cap")
            if setter then pcall(setter, n) end
        end

        task.spawn(function() task.wait(0.1); applyCap(_G._FH_FpsCapValue) end)
        _waitForSlider(function()
            _G._FH_MakeSlider(MiscTab.scroll, "Max FPS Cap", 30, 360, _G._FH_FpsCapValue, function(v)
                applyCap(v)
                pcall(FH_SaveConfig)
            end)
        end)
    end

end;
do
    Config.sliders = Config.sliders or {}
    local cardH = isMobile and 86 or 56
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

    local nameLbl = Label(card, "Alt Account Steal", isMobile and 11 or 13, T.White, Enum.Font.GothamMedium)
    nameLbl.Size         = UDim2.new(1, -170, 0, 16)
    nameLbl.Position     = UDim2.new(0, 14, 0, 10)
    nameLbl.ZIndex       = 2
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local descLbl = Label(card, "Skips steal webhook if only you + this alt are in the server", isMobile and 9 or 11, T.Dim, Enum.Font.Gotham)
    descLbl.Size         = UDim2.new(1, -170, 0, 14)
    descLbl.Position     = UDim2.new(0, 14, 0, 28)
    descLbl.ZIndex       = 2
    descLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local altBox = Instance.new("TextBox")
    altBox.Size             = UDim2.new(0, 150, 0, 24)
    altBox.Position         = UDim2.new(1, -160, 0.5, -12)
    altBox.BackgroundColor3 = T.Card
    altBox.BorderSizePixel  = 0
    altBox.PlaceholderText  = "Alt Roblox username"
    altBox.Text             = tostring(Config.sliders.alt_account or "")
    altBox.TextSize         = isMobile and 10 or 11
    altBox.Font             = Enum.Font.GothamBold
    altBox.TextColor3       = T.White
    altBox.TextXAlignment   = Enum.TextXAlignment.Center
    altBox.ZIndex           = 3
    altBox.ClearTextOnFocus = false
    altBox.Parent           = card
    Corner(altBox, 6)
    local altStroke = Stroke(altBox, T.Border, 1)

    local C_ALT_OK  = Color3.fromRGB(120, 220, 130)
    local C_ALT_BAD = Color3.fromRGB(230, 110, 110)

    local function setAltStrokeState(state)
        if state == "ok" then
            altStroke.Color = C_ALT_OK
        elseif state == "bad" then
            altStroke.Color = C_ALT_BAD
        else
            altStroke.Color = T.Border
        end
    end

    local _altValidateToken = 0
    local function validateAlt(name)
        _altValidateToken = _altValidateToken + 1
        local myToken = _altValidateToken
        if name == "" then
            setAltStrokeState("idle")
            return
        end
        task.spawn(function()
            local ok, userId = pcall(function()
                return Players:GetUserIdFromNameAsync(name)
            end)
            if myToken ~= _altValidateToken then return end
            if ok and type(userId) == "number" and userId > 0 then
                setAltStrokeState("ok")
                _G._FH_AltAccount        = name
                Config.sliders.alt_account = name
                Config.sliders.alt_account_verified = true
                pcall(FH_SaveConfig)
                pcall(ShowToggleNotification, "Alt account verified: " .. name, true)
            else
                setAltStrokeState("bad")
                Config.sliders.alt_account_verified = false
                pcall(FH_SaveConfig)
            end
        end)
    end

    _G._FH_AltAccount = altBox.Text
    if altBox.Text ~= "" and Config.sliders.alt_account_verified == true then
        setAltStrokeState("ok")
    end

    altBox.FocusLost:Connect(function()
        local txt = altBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        altBox.Text = txt
        _G._FH_AltAccount = txt
        Config.sliders.alt_account = txt
        pcall(FH_SaveConfig)
        validateAlt(txt)
    end)
end;
local _makeAnimalCard_fn
local function _buildMakeAnimalCard(mbfGridContainer, T, isMobile, Corner, Stroke, Label, Tween, F, createAnimalViewport, refreshList, configRegistry, animalState, destroyFollower, spawnFollower)
    return function(animalName)
        local cardH = 72
        local card  = Instance.new("Frame")
        card.Size             = UDim2.new(0.5, -3, 0, cardH)
        card.BackgroundColor3 = T.Card
        card.BackgroundTransparency = 0.15
        card.BorderSizePixel  = 0
        card.Parent           = mbfGridContainer
        Corner(card, 8)
        local cStroke = Stroke(card, T.Border, 1)
        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(0, 3, 0, cardH - 16)
        bar.Position         = UDim2.new(0, 0, 0, 8)
        bar.BackgroundColor3 = T.TrackOff
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 2
        bar.Parent           = card
        Corner(bar, 2)
        createAnimalViewport(card, animalName)
        local TEXT_LEFT = 72
        local TEXT_RIGHT_PAD = 50
        local nameLbl = Label(card, animalName, isMobile and 9 or 11, T.White, Enum.Font.GothamMedium)
        nameLbl.Size         = UDim2.new(1, -(TEXT_LEFT + TEXT_RIGHT_PAD), 0, 14)
        nameLbl.Position     = UDim2.new(0, TEXT_LEFT, 0, 20)
        nameLbl.ZIndex       = 2
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        local subLbl = Label(card, "Follower", isMobile and 8 or 9, T.Dim, Enum.Font.Gotham)
        subLbl.Size         = UDim2.new(1, -(TEXT_LEFT + TEXT_RIGHT_PAD), 0, 12)
        subLbl.Position     = UDim2.new(0, TEXT_LEFT, 0, 38)
        subLbl.ZIndex       = 2
        subLbl.TextTruncate = Enum.TextTruncate.AtEnd
        local track = Instance.new("Frame")
        track.Size             = UDim2.new(0, 32, 0, 18)
        track.Position         = UDim2.new(1, -40, 0.5, -9)
        track.BackgroundColor3 = T.TrackOff
        track.BorderSizePixel  = 0
        track.ZIndex           = 3
        track.Parent           = card
        Corner(track, 9)
        local tStroke = Stroke(track, T.Border, 1)
        local knob = Instance.new("Frame")
        knob.Size             = UDim2.new(0, 12, 0, 12)
        knob.Position         = UDim2.new(0, 3, 0.5, -6)
        knob.BackgroundColor3 = T.KnobOff
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 4
        knob.Parent           = track
        Corner(knob, 6)
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
        local togState = false
        local function applyVisual(s)
            if s then
                Tween(knob,    M, {Position = UDim2.new(0, 17, 0.5, -6), BackgroundColor3 = T.KnobOn})
                Tween(track,   M, {BackgroundColor3 = T.TrackOn})
                Tween(tStroke, M, {Color = T.TrackOn})
                Tween(bar,     M, {BackgroundColor3 = T.White})
            else
                Tween(knob,    M, {Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = T.KnobOff})
                Tween(track,   M, {BackgroundColor3 = T.TrackOff})
                Tween(tStroke, M, {Color = T.Border})
                Tween(bar,     M, {BackgroundColor3 = T.TrackOff})
            end
        end
        animalState.setOff[animalName] = function()
            if togState then
                togState = false
                applyVisual(false)
                destroyFollower(animalName)
                Config.toggles["mbf_"..animalName] = false
                pcall(FH_SaveConfig)
            end
        end
        local function doToggle()
            if not togState then
                if animalState.active and animalState.setOff[animalState.active] then
                    animalState.setOff[animalState.active]()
                end
                animalState.active = animalName
                togState = true
                applyVisual(true)
                spawnFollower(animalName)
            else
                animalState.active = nil
                togState = false
                applyVisual(false)
                destroyFollower(animalName)
            end
            Config.toggles["mbf_"..animalName] = togState
            pcall(FH_SaveConfig)
        end
        configRegistry["mbf_"..animalName] = {
            getState   = function() return togState end,
            getKeyCode = function() return nil end,
            setKeyCode = function() end,
            doToggle   = doToggle,
            setEnabled = function(v)
                if not _G._FH_IsRestoring then task.defer(function() pcall(FH_SaveConfig) end) end
                if v then
                    if animalState.active and animalState.active ~= animalName and animalState.setOff[animalState.active] then
                        animalState.setOff[animalState.active]()
                    end
                    animalState.active = animalName
                    togState = true
                    applyVisual(true)
                    spawnFollower(animalName)
                else
                    if animalState.active == animalName then animalState.active = nil end
                    togState = false
                    applyVisual(false)
                    destroyFollower(animalName)
                end
                Config.toggles["mbf_"..animalName] = v
            end,
        }
        local hitbox = Instance.new("Frame")
        hitbox.Size                = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.ZIndex              = 5
        hitbox.Active              = true
        hitbox.Parent              = card
        local _touchActive, _touchStart = false, nil
        hitbox.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                _touchActive = true
                _touchStart  = inp.Position
            end
        end)
        hitbox.InputEnded:Connect(function(inp)
            if (inp.UserInputType == Enum.UserInputType.MouseButton1
            or  inp.UserInputType == Enum.UserInputType.Touch) and _touchActive then
                _touchActive = false
                if _touchStart and (inp.Position - _touchStart).Magnitude < 20 then
                    doToggle()
                end
                _touchStart = nil
            end
        end)
    end
end

_buildMiniPetsSection(
    Config, T, isMobile, Corner, Stroke, Label, Tween, F,
    MiscTab, Players, configRegistry, ShowToggleNotification,
    _buildMakeAnimalCard, ANIMAL_LIST,
    _FH_AddThemeStroke, CreateToggle, GUI, FH_SaveConfig, _FH_BuildThemeSequence
)

do
    local TELE_TIMER_NAME   = "Teleport Enable Timer"
    local TELE_UNLOCK_SECS  = 180

    local _tpTimerJoinTick  = tick()
    pcall(function()

        local serverNow = workspace:GetServerTimeNow()
        local localNow  = tick()

        local gameAge = workspace.DistributedGameTime
        if gameAge and gameAge > 0 and gameAge < localNow then

            _tpTimerJoinTick = math.max(_tpTimerJoinTick - gameAge, 0)
        end
    end)

    _buildTpTimerCard(
        MiscTab, TELE_TIMER_NAME, TELE_UNLOCK_SECS, _tpTimerJoinTick,
        T, Corner, Stroke, Label, Tween, F, Config, configRegistry,
        _FH_AddThemeStroke, ShowToggleNotification
    )
end

CreateToggle(MiscTab.scroll, "Teleport Next Base",    "Carpet TP to your next base spawn",          function(v) ToggleHandlers.carpet_tp_base(v) end)
CreateToggle(MiscTab.scroll, "Base Alarm",            "Checks if players are in your base",         function(v) ToggleHandlers.base_alarm(v) end)
CreateToggle(MiscTab.scroll, "Logger Protecter", "Kicks you if trade GUIs are forcibly disabled", function(v)
    if v then
        _G._LoggerProtecterActive = true
        task.spawn(function()
            local lp       = Players.LocalPlayer
            local pg       = lp:WaitForChild("PlayerGui")
            local tradeLive   = pg:WaitForChild("TradeLiveTrade",  10)
            local tradeList   = pg:WaitForChild("TradePlayerList", 10)
            local tradePrompt = pg:WaitForChild("TradePrompts",    10)
            if not (tradeLive and tradeList and tradePrompt) then return end
            local detections = 0
            while _G._LoggerProtecterActive and task.wait(0.05) do
                tradeLive.Enabled   = true
                tradeList.Enabled   = true
                tradePrompt.Enabled = true
                task.wait(0.03)
                if not tradeLive.Enabled
                or not tradeList.Enabled
                or not tradePrompt.Enabled then
                    detections += 1
                    if detections >= 3 then
                        local otherUser = "Unknown"
                        local ok, res = pcall(function()
                            return tradeLive.TradeLiveTrade.Other.Username.Text
                        end)
                        if ok and res then otherUser = res end
                        lp:Kick("Protected By FadedHub :) | Username: " .. otherUser)
                        break
                    end
                else
                    detections = 0
                end
            end
        end)
    else
        _G._LoggerProtecterActive = false
    end
end)
CreateToggle(MiscTab.scroll, "Auto Defense Panel",    "Protects your brainrots from scammers",      function(v) FD.setFadedDefenseVisible(v) end)
do
    local RS   = game:GetService("ReplicatedStorage")
    local RSvc = game:GetService("RunService")
    local AF_SCALE   = 0.68
    local AF_SCALE_OVERRIDE = {
        ["Griffin"]              = 1.20,
        ["Cooki and Milki"]      = 1.40,
        ["Love Love Bear"]       = 1.99,
        ["Signore Carapace"]     = 0.59,
        ["Money Money Puggy"]    = 1.99,
        ["Nuclearo Dinossauro"]  = 0.65,
    }
    local AF_GROUND_OFFSET = 0
    local AF_RAY_UP        = 8
    local AF_RAY_DOWN      = 40
    local AF_MEOWL_HEAD_UP    = 0.3
    local AF_MEOWL_SIDE_SCALE = 0.5
    local AF_rcParams = RaycastParams.new()
    AF_rcParams.FilterType = Enum.RaycastFilterType.Exclude
    local followers = {}
    _G._FH_Followers = followers
    local FOLLOW_DIST  = 4.5
    local FOLLOW_SPEED = 0.12
    local function afGetTemplate(name)
        local ok, v = pcall(function() return RS.Models.Animals[name] end)
        return ok and v or nil
    end
    local function afGetAnimFolder(name)
        local ok, v = pcall(function() return RS.Animations.Animals[name] end)
        return ok and v or nil
    end
    local function afGroundY(worldPos, excludeList)
        AF_rcParams.FilterDescendantsInstances = excludeList
        local origin = Vector3.new(worldPos.X, worldPos.Y + AF_RAY_UP, worldPos.Z)
        local result = workspace:Raycast(origin, Vector3.new(0, -(AF_RAY_UP + AF_RAY_DOWN), 0), AF_rcParams)
        return result and (result.Position.Y + AF_GROUND_OFFSET) or worldPos.Y
    end
    local function afScaleModel(model, scale)
        local ok = pcall(function() model:ScaleTo(scale) end)
        if not ok then
            local pivot = model:GetPivot()
            for _, desc in ipairs(model:GetDescendants()) do
                if desc:IsA("BasePart") then
                    local rel = pivot:ToObjectSpace(desc.CFrame)
                    desc.Size   = desc.Size * scale
                    desc.CFrame = pivot:ToWorldSpace(CFrame.new(rel.Position * scale) * (rel - rel.Position))
                end
            end
        end
    end
    local function afAnchorModel(model)
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then
                desc.Anchored   = true
                desc.CanCollide = false
            end
        end
    end
    local function destroyFollower(name)
        local f = followers[name]
        if not f then return end
        if f.heartbeat then f.heartbeat:Disconnect() end
        if f.walkTrack then pcall(function() f.walkTrack:Stop() end) end
        if f.idleTrack then pcall(function() f.idleTrack:Stop() end) end
        if f.clone and f.clone.Parent then f.clone:Destroy() end
        followers[name] = nil
    end
    local function spawnFollower(name)
        destroyFollower(name)
        local template = afGetTemplate(name)
        if not template then
            warn("[MiniBrainrotFollowers] Model not found for: ".. tostring(name))
            return
        end
        local clone = template:Clone()
        clone.Name = "MBF_".. name
        afAnchorModel(clone)
        clone.Parent = workspace
        local scaleOv = AF_SCALE_OVERRIDE[name]
        afScaleModel(clone, AF_SCALE * (scaleOv or 1))
        local char = Players.LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if name == "Meowl"then
                local head    = char:FindFirstChild("Head")
                local headPos = head and head.Position or (hrp.Position + Vector3.new(0, 2, 0))
                local right   = hrp.CFrame.RightVector
                pcall(function()
                    clone:PivotTo(CFrame.new(
                        headPos.X + right.X * (FOLLOW_DIST * AF_MEOWL_SIDE_SCALE),
                        headPos.Y + AF_MEOWL_HEAD_UP,
                        headPos.Z + right.Z * (FOLLOW_DIST * AF_MEOWL_SIDE_SCALE)
                    ))
                end)
            else
                local sideCF = hrp.CFrame * CFrame.new(FOLLOW_DIST, 0, 1.5)
                local startY = afGroundY(sideCF.Position, {clone, char})
                pcall(function() clone:PivotTo(CFrame.new(sideCF.X, startY, sideCF.Z)) end)
            end
        end
        local controller = clone:FindFirstChildWhichIsA("AnimationController", true)
                        or clone:FindFirstChildWhichIsA("Humanoid", true)
        if not controller then
            controller = Instance.new("AnimationController")
            controller.Parent = clone
        end
        local animatorInst = controller:FindFirstChildWhichIsA("Animator")
        if not animatorInst then
            animatorInst = Instance.new("Animator")
            animatorInst.Parent = controller
        end
        local animFolder  = afGetAnimFolder(name)
        local walkTrack, idleTrack
        if animFolder then
            local walkAnim = animFolder:FindFirstChild("Walk")
            local idleAnim = animFolder:FindFirstChild("Idle")
            if walkAnim then pcall(function() walkTrack = animatorInst:LoadAnimation(walkAnim) end) end
            if idleAnim then pcall(function() idleTrack = animatorInst:LoadAnimation(idleAnim) end) end
        end
        local f = {
            clone     = clone,
            walkTrack = walkTrack,
            idleTrack = idleTrack,
            isWalking = false,
            lastPos   = nil,
            heartbeat = nil,
        }
        followers[name] = f
        if name == "Meowl"then
            if walkTrack then walkTrack.Looped = true; walkTrack:Play(); walkTrack:AdjustSpeed(0.4) end
        else
            if idleTrack then idleTrack.Looped = true; idleTrack:Play() end
        end
        local _petAcc = 0
        f.heartbeat = RSvc.Heartbeat:Connect(function(dt)
            if not (f.clone and f.clone.Parent) then return end
            _petAcc = _petAcc + dt
            if _petAcc < 1/30 then return end
            dt = _petAcc
            _petAcc = 0
            local character = Players.LocalPlayer.Character
            local rootPart  = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            local targetPos
            if name == "Meowl"then
                local head    = character:FindFirstChild("Head")
                local headPos = head and head.Position or (rootPart.Position + Vector3.new(0, 2, 0))
                local right   = rootPart.CFrame.RightVector
                targetPos = Vector3.new(
                    headPos.X + right.X * (FOLLOW_DIST * AF_MEOWL_SIDE_SCALE),
                    headPos.Y + AF_MEOWL_HEAD_UP,
                    headPos.Z + right.Z * (FOLLOW_DIST * AF_MEOWL_SIDE_SCALE)
                )
            else
                local sideCF = rootPart.CFrame * CFrame.new(FOLLOW_DIST, 0, 1.5)
                local human  = character:FindFirstChildWhichIsA("Humanoid")
                local inAir  = human and (human.FloorMaterial == Enum.Material.Air)
                if inAir then
                    targetPos = Vector3.new(sideCF.X, sideCF.Y, sideCF.Z)
                else
                    local gY = afGroundY(Vector3.new(sideCF.X, sideCF.Y, sideCF.Z), {f.clone, character})
                    targetPos = Vector3.new(sideCF.X, gY, sideCF.Z)
                end
            end
            local currentPos = f.clone:GetPivot().Position
            local alpha  = 1 - (1 - math.clamp(FOLLOW_SPEED, 0, 0.99)) ^ (dt * 60)
            local newPos = currentPos:Lerp(targetPos, alpha)
            local playerLook = rootPart.CFrame.LookVector
            local flatLook   = Vector3.new(playerLook.X, 0, playerLook.Z)
            local newCF
            if flatLook.Magnitude > 0.001 then
                newCF = CFrame.new(newPos, newPos + flatLook)
            else
                local cur = f.clone:GetPivot()
                newCF = CFrame.new(newPos) * (cur - cur.Position)
            end
            f.clone:PivotTo(newCF)
            local moving = f.lastPos and (
                Vector2.new(newPos.X, newPos.Z) - Vector2.new(f.lastPos.X, f.lastPos.Z)
            ).Magnitude > 0.015
            f.lastPos = newPos
            if name == "Meowl"then
                if moving and not f.isWalking then
                    f.isWalking = true
                    if f.walkTrack then f.walkTrack:AdjustSpeed(1.0) end
                elseif not moving and f.isWalking then
                    f.isWalking = false
                    if f.walkTrack then f.walkTrack:AdjustSpeed(0.4) end
                end
            else
                if moving and not f.isWalking then
                    f.isWalking = true
                    if f.idleTrack then f.idleTrack:Stop() end
                    if f.walkTrack then f.walkTrack.Looped = true; f.walkTrack:Play() end
                elseif not moving and f.isWalking then
                    f.isWalking = false
                    if f.walkTrack then f.walkTrack:Stop() end
                    if f.idleTrack then f.idleTrack.Looped = true; f.idleTrack:Play() end
                end
            end
        end)
    end

    _G._FH_MBF_spawnFollower   = spawnFollower
    _G._FH_MBF_destroyFollower = destroyFollower
    _G._FH_MBF_followers       = followers
end
do
    local spawnFollower   = _G._FH_MBF_spawnFollower
    local destroyFollower = _G._FH_MBF_destroyFollower
    local followers       = _G._FH_MBF_followers
    local ANIMAL_LIST = {
        "Strawberry Elephant",
        "Love Love Bear",
        "Signore Carapace",
        "Money Money Puggy",
        "Nuclearo Dinossauro",
        "Dragon Cannelloni",
        "Antonio",
        "Eviledon",
        "Tralaledon",
        "Hydra Bunny",
        "Garama and Madundung",
        "Meowl",
        "Headless Horseman",
        "Skibidi Toilet",
        "John Pork",
        "Griffin",
        "Dragon Gingerini",
        "La Supreme Combinasion",
        "Cerberus",
        "Hydra Dragon Cannelloni",
        "Cooki and Milki",
    }
    CreateSection(MiscTab.scroll, "MINI BRAINROT FOLLOWERS")
    local function createAnimalViewport(parent, animalName)
        local vp = Instance.new("ViewportFrame")
        vp.Size                    = UDim2.new(0, 60, 0, 60)
        vp.Position                = UDim2.new(0, 6, 0.5, -30)
        vp.BackgroundColor3        = Color3.fromRGB(14, 14, 18)
        vp.BackgroundTransparency  = 0.1
        vp.BorderSizePixel         = 0
        vp.ZIndex                  = 3
        vp.LightDirection          = Vector3.new(-1, -2, -1)
        vp.LightColor              = Color3.fromRGB(220, 220, 255)
        vp.Ambient                 = Color3.fromRGB(180, 180, 180)
        vp.Parent                  = parent
        Corner(vp, 8)
        Stroke(vp, T.Border, 1)
        local wm = Instance.new("WorldModel")
        wm.Parent = vp
        local cam = Instance.new("Camera")
        cam.Parent = vp
        vp.CurrentCamera = cam
        task.spawn(function()
            local template = afGetTemplate(animalName)
            if not template then return end
            local clone = template:Clone()
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored   = true
                    d.CanCollide = false
                end
            end
            local ok = pcall(function() clone:ScaleTo(0.28) end)
            if not ok then
                for _, d in ipairs(clone:GetDescendants()) do
                    if d:IsA("BasePart") then d.Size = d.Size * 0.28 end
                end
            end
            clone.Parent = wm
            local cf, size = clone:GetBoundingBox()
            local maxDim   = math.max(size.X, size.Y, size.Z)
            local dist     = maxDim * 1.15
            cam.FieldOfView = 55
            cam.CFrame     = CFrame.new(
                cf.Position + Vector3.new(dist * 0.45, maxDim * 0.25, dist),
                cf.Position
            )
            local animFolder = afGetAnimFolder(animalName)
            local idleAnim   = animFolder and animFolder:FindFirstChild("Idle")
            local walkAnim   = animFolder and animFolder:FindFirstChild("Walk")
            local useAnim    = idleAnim or walkAnim
            if useAnim then
                local controller = clone:FindFirstChildWhichIsA("AnimationController", true)
                                or clone:FindFirstChildWhichIsA("Humanoid", true)
                if not controller then
                    controller = Instance.new("AnimationController")
                    controller.Parent = clone
                end
                local anim2 = controller:FindFirstChildWhichIsA("Animator")
                if not anim2 then
                    anim2 = Instance.new("Animator")
                    anim2.Parent = controller
                end
                local ok2, track = pcall(function() return anim2:LoadAnimation(useAnim) end)
                if ok2 and track then
                    track.Looped = true
                    track:Play()
                    RSvc.Heartbeat:Connect(function(dt)
                        if not clone.Parent then return end
                        local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, dt * 0.9, 0))
                        end
                    end)
                end
            end
        end)
        return vp
    end
    local _animalState = { active = nil, setOff = {} }
    local mbfGridContainer = Instance.new("Frame")
    mbfGridContainer.Name                   = "MBFGrid"
    mbfGridContainer.BackgroundTransparency = 1
    mbfGridContainer.Size                   = UDim2.new(1, -16, 0, 0)
    mbfGridContainer.AutomaticSize          = Enum.AutomaticSize.Y
    mbfGridContainer.BorderSizePixel        = 0
    mbfGridContainer.Parent                 = MiscTab.scroll
    local mbfGridLayout = Instance.new("UIGridLayout")
    mbfGridLayout.FillDirection       = Enum.FillDirection.Horizontal
    mbfGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    mbfGridLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    mbfGridLayout.CellPadding         = UDim2.new(0, 6, 0, 6)
    mbfGridLayout.CellSize            = isMobile
        and UDim2.new(1, 0, 0, 72)
        or  UDim2.new(0.5, -3, 0, 72)
    mbfGridLayout.Parent              = mbfGridContainer
    _makeAnimalCard_fn = _buildMakeAnimalCard(mbfGridContainer, T, isMobile, Corner, Stroke, Label, Tween, F, createAnimalViewport, refreshList, configRegistry, _animalState, destroyFollower, spawnFollower)
    for _, animalName in ipairs(ANIMAL_LIST) do
        _makeAnimalCard_fn(animalName)
    end
end

AB.AllowBaseBorderFrame = Instance.new("Frame")
AB.AllowBaseBorderFrame.Name             = "AllowBaseGradBorder"
AB.AllowBaseBorderFrame.Size             = UDim2.new(0, AB.W + 4, 0, AB.H + 4)
AB.AllowBaseBorderFrame.Position         = UDim2.new(0, 96, 0.5, 100)
AB.AllowBaseBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AB.AllowBaseBorderFrame.BorderSizePixel  = 0
AB.AllowBaseBorderFrame.ZIndex           = 18
AB.AllowBaseBorderFrame.Visible          = false
AB.AllowBaseBorderFrame.Parent           = GUI
AB.AllowBaseBorderFrame.BackgroundTransparency = 1
Corner(AB.AllowBaseBorderFrame, 12)
AB.AllowBaseWin = Instance.new("Frame")
AB.AllowBaseWin.Name             = "AllowBasePanel"
AB.AllowBaseWin.Size             = UDim2.new(0, AB.W, 0, AB.H)
AB.AllowBaseWin.Position         = UDim2.new(0, 98, 0.5, 102)
AB.AllowBaseWin.BackgroundColor3 = T.BG
AB.AllowBaseWin.BackgroundTransparency = 0.25
AB.AllowBaseWin.BorderSizePixel  = 0
AB.AllowBaseWin.ZIndex           = 19
AB.AllowBaseWin.Visible          = false
AB.AllowBaseWin.ClipsDescendants = true
AB.AllowBaseWin.Parent           = GUI
Corner(AB.AllowBaseWin, 10)
AB.ABHdr = Instance.new("Frame")
AB.ABHdr.Size             = UDim2.new(1, 0, 0, 26)
AB.ABHdr.BackgroundColor3 = T.Header
AB.ABHdr.BackgroundTransparency = 0.2
AB.ABHdr.BorderSizePixel  = 0
AB.ABHdr.ZIndex           = 20
AB.ABHdr.Parent           = AB.AllowBaseWin
Corner(AB.ABHdr, 10)
AB.ABHdr.Active = true
AB.ABHdrFill = Instance.new("Frame")
AB.ABHdrFill.Size             = UDim2.new(1, 0, 0, 7)
AB.ABHdrFill.Position         = UDim2.new(0, 0, 1, -7)
AB.ABHdrFill.BackgroundColor3 = T.Header
AB.ABHdrFill.BackgroundTransparency = 0.2
AB.ABHdrFill.BorderSizePixel  = 0
AB.ABHdrFill.ZIndex           = 20
AB.ABHdrFill.Parent           = AB.ABHdr
AB.ABHdrLine = Instance.new("Frame")
AB.ABHdrLine.Size             = UDim2.new(1, 0, 0, 1)
AB.ABHdrLine.Position         = UDim2.new(0, 0, 1, -1)
AB.ABHdrLine.BackgroundColor3 = T.Border
AB.ABHdrLine.BorderSizePixel  = 0
AB.ABHdrLine.ZIndex           = 21
AB.ABHdrLine.Parent           = AB.ABHdr
AB.ABTitle = Label(AB.ABHdr, "Allow Base", 12, T.White, Enum.Font.GothamBold)
AB.ABTitle.Size           = UDim2.new(1, -40, 1, 0)
AB.ABTitle.Position       = UDim2.new(0, 10, 0, 0)
AB.ABTitle.TextYAlignment = Enum.TextYAlignment.Center
AB.ABTitle.ZIndex         = 22
AB.ABMinBtn = Instance.new("TextButton")
AB.ABMinBtn.Size             = UDim2.new(0, 20, 0, 20)
AB.ABMinBtn.Position         = UDim2.new(1, -26, 0.5, -10)
AB.ABMinBtn.BackgroundColor3 = T.Card
AB.ABMinBtn.BorderSizePixel  = 0
AB.ABMinBtn.Text             = "\226\136\146"
AB.ABMinBtn.TextSize         = 12
AB.ABMinBtn.Font             = Enum.Font.GothamBold
AB.ABMinBtn.TextColor3       = T.White
AB.ABMinBtn.ZIndex           = 23
AB.ABMinBtn.Parent           = AB.ABHdr
Corner(AB.ABMinBtn, 6)
Stroke(AB.ABMinBtn, T.Border, 1)
AB.ABContent = Instance.new("Frame")
AB.ABContent.Size                   = UDim2.new(1, 0, 1, -26)
AB.ABContent.Position               = UDim2.new(0, 0, 0, 26)
AB.ABContent.BackgroundTransparency = 1
AB.ABContent.ZIndex                 = 19
AB.ABContent.Parent                 = AB.AllowBaseWin
Padding(AB.ABContent, 8, 8, 10, 10)
AB.ABAllowBtn = Instance.new("TextButton")
AB.ABAllowBtn.Size             = UDim2.new(1, 0, 1, 0)
AB.ABAllowBtn.BackgroundColor3 = T.Card
AB.ABAllowBtn.BorderSizePixel  = 0
AB.ABAllowBtn.Text             = "Allow/Disallow"
AB.ABAllowBtn.TextSize         = 14
AB.ABAllowBtn.Font             = Enum.Font.GothamBold
AB.ABAllowBtn.TextColor3       = T.White
AB.ABAllowBtn.ZIndex           = 21
AB.ABAllowBtn.Parent           = AB.ABContent
Corner(AB.ABAllowBtn, 8)
Stroke(AB.ABAllowBtn, T.Border, 1)
AB.ABAllowBtn.MouseEnter:Connect(function()
    Tween(AB.ABAllowBtn, F, {BackgroundColor3 = T.CardHover})
end)
AB.ABAllowBtn.MouseLeave:Connect(function()
    Tween(AB.ABAllowBtn, F, {BackgroundColor3 = T.Card})
end)
AB.fireAllow = function()
    if allowCooldown then return end
    allowCooldown = true
    local plots = workspace:FindFirstChild("Plots")
    if plots then
        for _, plot in ipairs(plots:GetChildren()) do
            local friendPanel = plot:FindFirstChild("FriendPanel", true)
            if friendPanel then
                local main = friendPanel:FindFirstChild("Main")
                if main then
                    for _, obj in ipairs(main:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            pcall(fireproximityprompt, obj)
                        end
                    end
                end
            end
        end
    end
    task.delay(1, function() allowCooldown = false end)
end
AB.ABAllowBtn.MouseButton1Click:Connect(AB.fireAllow)
do
    AB.ABHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            AB.dragging   = true
            AB.dragStart  = inp.Position
            AB.panelStart = AB.AllowBaseWin.Position
        end
    end)
    AB.ABHdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            AB.dragging = false
            Config.mini = Config.mini or {}
            Config.mini.ab_pos = { x = AB.AllowBaseWin.Position.X.Offset, y = AB.AllowBaseWin.Position.Y.Offset,
                                   xs = AB.AllowBaseWin.Position.X.Scale, ys = AB.AllowBaseWin.Position.Y.Scale }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if AB.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - AB.dragStart
            local newPos = UDim2.new(
                AB.panelStart.X.Scale, AB.panelStart.X.Offset + d.X,
                AB.panelStart.Y.Scale, AB.panelStart.Y.Offset + d.Y
            )
            AB.AllowBaseWin.Position         = newPos
            AB.AllowBaseBorderFrame.Position = UDim2.new(
                newPos.X.Scale, newPos.X.Offset - 2,
                newPos.Y.Scale, newPos.Y.Offset - 2
            )
        end
    end)
end
AB.ABMinBtn.MouseButton1Click:Connect(function()
    AB.minimized = not AB.minimized
    if AB.minimized then
        AB.AllowBaseWin.ClipsDescendants = false
        AB.ABHdrFill.Visible = false
        AB.ABHdrLine.Visible = false
        AB.ABContent.Visible = false
        Tween(AB.AllowBaseWin,         M, {Size = UDim2.new(0, AB.W, 0, 32)})
        Tween(AB.AllowBaseBorderFrame, M, {Size = UDim2.new(0, AB.W + 4, 0, 36)})
        AB.ABMinBtn.Text = "+"else
        AB.ABHdrFill.Visible = true
        AB.ABHdrLine.Visible = true
        Tween(AB.AllowBaseWin,         M, {Size = UDim2.new(0, AB.W, 0, AB.H)})
        Tween(AB.AllowBaseBorderFrame, M, {Size = UDim2.new(0, AB.W + 4, 0, AB.H + 4)})
        AB.ABMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            AB.ABContent.Visible = true
            AB.AllowBaseWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.ab_min = AB.minimized
        pcall(FH_SaveConfig)
    end
end)
AB.setAllowBasePanelVisible = function(vis)
    AB.AllowBaseWin.Visible         = vis
    AB.AllowBaseBorderFrame.Visible = vis
    if vis then
        local p = AB.AllowBaseWin.Position
        AB.AllowBaseBorderFrame.Position  = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if AB.minimized then
            AB.ABMinBtn.Text                  = "+"
AB.ABContent.Visible              = false
            AB.ABHdrFill.Visible              = false
            AB.ABHdrLine.Visible              = false
            AB.AllowBaseWin.ClipsDescendants  = false
            AB.AllowBaseWin.Size              = UDim2.new(0, AB.W, 0, 36)
            AB.AllowBaseBorderFrame.Size      = UDim2.new(0, AB.W + 4, 0, 40)
        else
            AB.ABMinBtn.Text                  = "\226\136\146"
AB.ABContent.Visible              = true
            AB.ABHdrFill.Visible              = true
            AB.ABHdrLine.Visible              = true
            AB.AllowBaseWin.ClipsDescendants  = true
            AB.AllowBaseWin.Size              = UDim2.new(0, AB.W, 0, AB.H)
            AB.AllowBaseBorderFrame.Size      = UDim2.new(0, AB.W + 4, 0, AB.H + 4)
        end
    end
end
SS.SSBorderFrame = Instance.new("Frame")
SS.SSBorderFrame.Name             = "SemiStealGradBorder"
SS.SSBorderFrame.Size             = UDim2.new(0, SS.W + 4, 0, SS.H + 4)
SS.SSBorderFrame.Position         = UDim2.new(0, 330, 0.5, -(SS.H + 4) / 2)
SS.SSBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SS.SSBorderFrame.BorderSizePixel  = 0
SS.SSBorderFrame.ZIndex           = 18
SS.SSBorderFrame.Visible          = false
SS.SSBorderFrame.Parent           = GUI
SS.SSBorderFrame.BackgroundTransparency = 1
Corner(SS.SSBorderFrame, 12)
SS.SSWin = Instance.new("Frame")
SS.SSWin.Name             = "SemiStealPanel"
SS.SSWin.Size             = UDim2.new(0, SS.W, 0, SS.H)
SS.SSWin.Position         = UDim2.new(0, 332, 0.5, -SS.H / 2)
SS.SSWin.BackgroundColor3 = SS.BG
SS.SSWin.BackgroundTransparency = 0.25
SS.SSWin.BorderSizePixel  = 0
SS.SSWin.ZIndex           = 19
SS.SSWin.Visible          = false
SS.SSWin.ClipsDescendants = true
SS.SSWin.Parent           = GUI
Corner(SS.SSWin, 10)
SS.SSHdr = Instance.new("Frame")
SS.SSHdr.Size             = UDim2.new(1, 0, 0, 26)
SS.SSHdr.BackgroundColor3 = SS.HDR
SS.SSHdr.BackgroundTransparency = 0.2
SS.SSHdr.BorderSizePixel  = 0
SS.SSHdr.ZIndex           = 20
SS.SSHdr.Parent           = SS.SSWin
Corner(SS.SSHdr, 10)
SS.SSHdr.Active = true
SS.SSHdrFill = Instance.new("Frame")
SS.SSHdrFill.Size             = UDim2.new(1, 0, 0, 7)
SS.SSHdrFill.Position         = UDim2.new(0, 0, 1, -7)
SS.SSHdrFill.BackgroundColor3 = SS.HDR
SS.SSHdrFill.BackgroundTransparency = 0.2
SS.SSHdrFill.BorderSizePixel  = 0
SS.SSHdrFill.ZIndex           = 20
SS.SSHdrFill.Parent           = SS.SSHdr
SS.SSHdrLine = Instance.new("Frame")
SS.SSHdrLine.Size             = UDim2.new(1, 0, 0, 1)
SS.SSHdrLine.Position         = UDim2.new(0, 0, 1, -1)
SS.SSHdrLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SS.SSHdrLine.BorderSizePixel  = 0
SS.SSHdrLine.ZIndex           = 21
SS.SSHdrLine.Parent           = SS.SSHdr
SS.SSTitle = Instance.new("TextLabel")
SS.SSTitle.Size              = UDim2.new(1, -40, 1, 0)
SS.SSTitle.Position          = UDim2.new(0, 12, 0, 0)
SS.SSTitle.BackgroundTransparency = 1
SS.SSTitle.Text              = "Instant Steal V2"
SS.SSTitle.TextSize          = 12
SS.SSTitle.Font              = Enum.Font.GothamBold
SS.SSTitle.TextColor3        = Color3.fromRGB(245, 245, 245)
SS.SSTitle.TextXAlignment    = Enum.TextXAlignment.Left
SS.SSTitle.TextYAlignment    = Enum.TextYAlignment.Center
SS.SSTitle.ZIndex            = 22
SS.SSTitle.Parent            = SS.SSHdr
SS.SSMinBtn = Instance.new("TextButton")
SS.SSMinBtn.Size             = UDim2.new(0, 18, 0, 18)
SS.SSMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
SS.SSMinBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
SS.SSMinBtn.BorderSizePixel  = 0
SS.SSMinBtn.Text             = "\226\136\146"
SS.SSMinBtn.TextSize         = 12
SS.SSMinBtn.Font             = Enum.Font.GothamBold
SS.SSMinBtn.TextColor3       = Color3.fromRGB(245, 245, 245)
SS.SSMinBtn.ZIndex           = 23
SS.SSMinBtn.Parent           = SS.SSHdr
Corner(SS.SSMinBtn, 6)
Stroke(SS.SSMinBtn, Color3.fromRGB(55, 55, 55), 1)
SS.SSContent = Instance.new("Frame")
SS.SSContent.Size                   = UDim2.new(1, 0, 1, -26)
SS.SSContent.Position               = UDim2.new(0, 0, 0, 30)
SS.SSContent.BackgroundTransparency = 1
SS.SSContent.ZIndex                 = 19
SS.SSContent.Parent                 = SS.SSWin
SS.SSLayout = Instance.new("UIListLayout")
SS.SSLayout.FillDirection       = Enum.FillDirection.Vertical
SS.SSLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SS.SSLayout.Padding             = UDim.new(0, 6)
SS.SSLayout.Parent              = SS.SSContent
Padding(SS.SSContent, 6, 6, 10, 10)
SS.SSPotionRow = Instance.new("Frame")
SS.SSPotionRow.Size             = UDim2.new(1, 0, 0, isMobile and 24 or 22)
SS.SSPotionRow.BackgroundColor3 = SS.BTN
SS.SSPotionRow.BorderSizePixel  = 0
SS.SSPotionRow.ZIndex           = 20
SS.SSPotionRow.Parent           = SS.SSContent
Corner(SS.SSPotionRow, 8)
Stroke(SS.SSPotionRow, Color3.fromRGB(45, 45, 45), 1)
SS.SSPotionLbl = Instance.new("TextLabel")
SS.SSPotionLbl.Size              = UDim2.new(1, -64, 1, 0)
SS.SSPotionLbl.Position          = UDim2.new(0, 10, 0, 0)
SS.SSPotionLbl.BackgroundTransparency = 1
SS.SSPotionLbl.Text              = "Giant Potion"
SS.SSPotionLbl.TextSize          = 13
SS.SSPotionLbl.Font              = Enum.Font.GothamMedium
SS.SSPotionLbl.TextColor3        = Color3.fromRGB(245, 245, 245)
SS.SSPotionLbl.TextXAlignment    = Enum.TextXAlignment.Left
SS.SSPotionLbl.TextYAlignment    = Enum.TextYAlignment.Center
SS.SSPotionLbl.ZIndex            = 21
SS.SSPotionLbl.Parent            = SS.SSPotionRow
SS.SSPotionTrack = Instance.new("Frame")
SS.SSPotionTrack.Size             = UDim2.new(0, 28, 0, 16)
SS.SSPotionTrack.Position         = UDim2.new(1, -36, 0.5, -8)
SS.SSPotionTrack.BackgroundColor3 = T.TrackOff
SS.SSPotionTrack.BorderSizePixel  = 0
SS.SSPotionTrack.ZIndex           = 21
SS.SSPotionTrack.Parent           = SS.SSPotionRow
Corner(SS.SSPotionTrack, 8)
SS.SSPotionTStroke = Stroke(SS.SSPotionTrack, T.Border, 1)
SS.SSPotionKnob = Instance.new("Frame")
SS.SSPotionKnob.Size             = UDim2.new(0, 12, 0, 12)
SS.SSPotionKnob.Position         = UDim2.new(0, 2, 0.5, -6)
SS.SSPotionKnob.BackgroundColor3 = T.KnobOff
SS.SSPotionKnob.BorderSizePixel  = 0
SS.SSPotionKnob.ZIndex           = 22
SS.SSPotionKnob.Parent           = SS.SSPotionTrack
Corner(SS.SSPotionKnob, 6)
SS.SSPotionBtn = Instance.new("Frame")
SS.SSPotionBtn.Size                   = UDim2.new(1, 0, 1, 0)
SS.SSPotionBtn.BackgroundTransparency = 1
SS.SSPotionBtn.ZIndex                 = 24
SS.SSPotionBtn.Active                 = true
SS.SSPotionBtn.Parent                 = SS.SSPotionRow
local _ssPotionTouchActive = false
local _ssPotionTouchStart  = nil
SS.SSPotionBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        SS.potionState = not SS.potionState
        if SS.potionState then
            Tween(SS.SSPotionKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SS.SSPotionKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
                Tween(SS.SSPotionKnob,    M, {BackgroundColor3 = T.KnobOn})
                Tween(SS.SSPotionTrack,   M, {BackgroundColor3 = T.TrackOn})
                Tween(SS.SSPotionTStroke, M, {Color = T.TrackOn})
            end)
        else
            Tween(SS.SSPotionKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SS.SSPotionKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
                Tween(SS.SSPotionKnob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(SS.SSPotionTrack,   M, {BackgroundColor3 = T.TrackOff})
                Tween(SS.SSPotionTStroke, M, {Color = T.Border})
            end)
        end
    elseif inp.UserInputType == Enum.UserInputType.Touch then
        _ssPotionTouchActive = true
        _ssPotionTouchStart  = inp.Position
    end
    Config.toggles["ss_potion"] = SS.potionState
    pcall(FH_SaveConfig)
end)
SS.SSPotionBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch and _ssPotionTouchActive then
        _ssPotionTouchActive = false
        if not (_ssPotionTouchStart and (inp.Position - _ssPotionTouchStart).Magnitude < 20) then _ssPotionTouchStart = nil; return end
        _ssPotionTouchStart = nil
        SS.potionState = not SS.potionState
        if SS.potionState then
            Tween(SS.SSPotionKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 3, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SS.SSPotionKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 14, 0.5, -6)})
                Tween(SS.SSPotionKnob,    M, {BackgroundColor3 = T.KnobOn})
                Tween(SS.SSPotionTrack,   M, {BackgroundColor3 = T.TrackOn})
                Tween(SS.SSPotionTStroke, M, {Color = T.TrackOn})
            end)
        else
            Tween(SS.SSPotionKnob, TweenInfo.new(0.06), {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 15, 0.5, -5)})
            task.delay(0.06, function()
                Tween(SS.SSPotionKnob,    M, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(0, 2, 0.5, -6)})
                Tween(SS.SSPotionKnob,    M, {BackgroundColor3 = T.KnobOff})
                Tween(SS.SSPotionTrack,   M, {BackgroundColor3 = T.TrackOff})
                Tween(SS.SSPotionTStroke, M, {Color = T.Border})
            end)
        end
        Config.toggles["ss_potion"] = SS.potionState
        pcall(FH_SaveConfig)
    end
end)
SS.SSAutoTPRow = Instance.new("Frame")
SS.SSAutoTPRow.Size             = UDim2.new(1, 0, 0, isMobile and 24 or 22)
SS.SSAutoTPRow.BackgroundColor3 = SS.BTN
SS.SSAutoTPRow.BorderSizePixel  = 0
SS.SSAutoTPRow.ZIndex           = 20
SS.SSAutoTPRow.Parent           = SS.SSContent
Corner(SS.SSAutoTPRow, 8)
Stroke(SS.SSAutoTPRow, Color3.fromRGB(45, 45, 45), 1)
SS.SSAutoTPLbl = Instance.new("TextLabel")
SS.SSAutoTPLbl.Size              = UDim2.new(1, -64, 1, 0)
SS.SSAutoTPLbl.Position          = UDim2.new(0, 10, 0, 0)
SS.SSAutoTPLbl.BackgroundTransparency = 1
SS.SSAutoTPLbl.Text              = "Auto TP Unlock"
SS.SSAutoTPLbl.TextSize          = 13
SS.SSAutoTPLbl.Font              = Enum.Font.GothamMedium
SS.SSAutoTPLbl.TextColor3        = Color3.fromRGB(245, 245, 245)
SS.SSAutoTPLbl.TextXAlignment    = Enum.TextXAlignment.Left
SS.SSAutoTPLbl.TextYAlignment    = Enum.TextYAlignment.Center
SS.SSAutoTPLbl.ZIndex            = 21
SS.SSAutoTPLbl.Parent            = SS.SSAutoTPRow
SS.SSAutoTPTrack = Instance.new("Frame")
SS.SSAutoTPTrack.Size             = UDim2.new(0, 28, 0, 16)
SS.SSAutoTPTrack.Position         = UDim2.new(1, -36, 0.5, -8)
SS.SSAutoTPTrack.BackgroundColor3 = T.TrackOff
SS.SSAutoTPTrack.BorderSizePixel  = 0
SS.SSAutoTPTrack.ZIndex           = 21
SS.SSAutoTPTrack.Parent           = SS.SSAutoTPRow
Corner(SS.SSAutoTPTrack, 8)
SS.SSAutoTPTStroke = Stroke(SS.SSAutoTPTrack, T.Border, 1)
SS.SSAutoTPKnob = Instance.new("Frame")
SS.SSAutoTPKnob.Size             = UDim2.new(0, 12, 0, 12)
SS.SSAutoTPKnob.Position         = UDim2.new(0, 2, 0.5, -6)
SS.SSAutoTPKnob.BackgroundColor3 = T.KnobOff
SS.SSAutoTPKnob.BorderSizePixel  = 0
SS.SSAutoTPKnob.ZIndex           = 22
SS.SSAutoTPKnob.Parent           = SS.SSAutoTPTrack
Corner(SS.SSAutoTPKnob, 6)
SS.SSAutoTPBtn = Instance.new("Frame")
SS.SSAutoTPBtn.Size                   = UDim2.new(1, 0, 1, 0)
SS.SSAutoTPBtn.BackgroundTransparency = 1
SS.SSAutoTPBtn.ZIndex                 = 24
SS.SSAutoTPBtn.Active                 = true
SS.SSAutoTPBtn.Parent                 = SS.SSAutoTPRow
local function ssAutoTPApplyVisual(on)
    if on then
        Tween(SS.SSAutoTPKnob,    M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,21,0.5,-8)})
        Tween(SS.SSAutoTPKnob,    M, {BackgroundColor3 = T.KnobOn})
        Tween(SS.SSAutoTPTrack,   M, {BackgroundColor3 = T.TrackOn})
        Tween(SS.SSAutoTPTStroke, M, {Color = T.TrackOn})
    else
        Tween(SS.SSAutoTPKnob,    M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,3,0.5,-8)})
        Tween(SS.SSAutoTPKnob,    M, {BackgroundColor3 = T.KnobOff})
        Tween(SS.SSAutoTPTrack,   M, {BackgroundColor3 = T.TrackOff})
        Tween(SS.SSAutoTPTStroke, M, {Color = T.Border})
    end
end
local function ssAutoTPDoToggle()
    SS.autoTPUnlockState = not SS.autoTPUnlockState
    if SS.autoTPUnlockState then
        Tween(SS.SSAutoTPKnob, TweenInfo.new(0.06), {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,4,0.5,-7)})
        task.delay(0.06, function() ssAutoTPApplyVisual(true) end)
    else
        Tween(SS.SSAutoTPKnob, TweenInfo.new(0.06), {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,20,0.5,-7)})
        task.delay(0.06, function() ssAutoTPApplyVisual(false) end)
    end
    Config.toggles["ss_auto_tp_unlock"] = SS.autoTPUnlockState
    pcall(FH_SaveConfig)
end
do
    local _atpTouchActive = false
    local _atpTouchStart  = nil
    SS.SSAutoTPBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            ssAutoTPDoToggle()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _atpTouchActive = true
            _atpTouchStart  = inp.Position
        end
    end)
    SS.SSAutoTPBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _atpTouchActive then
            _atpTouchActive = false
            if _atpTouchStart and (inp.Position - _atpTouchStart).Magnitude < 20 then
                ssAutoTPDoToggle()
            end
            _atpTouchStart = nil
        end
    end)
end
configRegistry["ss_auto_tp_unlock"] = {
    getState   = function() return SS.autoTPUnlockState end,
    getKeyCode = function() return nil end,
    setKeyCode = function() end,
    doToggle   = ssAutoTPDoToggle,
    setEnabled = function(v)
        SS.autoTPUnlockState = v
        ssAutoTPApplyVisual(v)
        Config.toggles["ss_auto_tp_unlock"] = v
        if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
    end,
}

do
    SS.autoTPOnAllowState = false
    local _allowWatchConns  = {}
    local _allowWatchSetup  = false

    local function _getAllowTPPlotOrder()
        local ok, PC = pcall(require, game.ReplicatedStorage.Controllers.PlotController)
        if not ok or not PC then return nil end
        local ok2, mp = pcall(function() return PC:GetMyPlot().PlotModel end)
        if not ok2 or not mp then return nil end
        local order = mp:GetAttribute("Order")
        if order ~= 1 and order ~= 2 then return nil end
        return order
    end

    local function _doAllowTP()
        local order = _getAllowTPPlotOrder()
        if not order then return end
        task.spawn(function()
            SS.SSSetFFlags()
            SS.SSDoTeleport()
        end)
    end

    local function setupAllowWatcher()
        if _allowWatchSetup then return end
        _allowWatchSetup = true
        local function isOppositeBasePlot(prompt)
            local plots = workspace:FindFirstChild("Plots")
            if not plots then return true end
            for _, plot in ipairs(plots:GetChildren()) do
                if prompt:IsDescendantOf(plot) then
                    local sign = plot:FindFirstChild("PlotSign")
                    if sign then
                        local yourBase = sign:FindFirstChild("YourBase")
                        if yourBase and yourBase.Enabled then
                            return false
                        end
                    end
                    return true
                end
            end
            return true
        end
        local function checkPromptText(prompt)
            if not SS.autoTPOnAllowState then return end
            local text = (prompt.ObjectText or ""):lower()

            if text:find("disallow") and isOppositeBasePlot(prompt) then
                _doAllowTP()
            end
        end
        local function watchPrompt(obj)
            if not obj:IsA("ProximityPrompt") then return end
            local c = obj:GetPropertyChangedSignal("ObjectText"):Connect(function()
                checkPromptText(obj)
            end)
            table.insert(_allowWatchConns, c)
        end

        local _plotsRoot = workspace:FindFirstChild("Plots")
        if _plotsRoot then
            local _step = 0
            for _, desc in ipairs(_plotsRoot:GetDescendants()) do
                watchPrompt(desc)
                _step = _step + 1
                if _step % 500 == 0 then task.wait() end
            end
            local addConn = _plotsRoot.DescendantAdded:Connect(function(desc)
                if desc:IsA("ProximityPrompt") then
                    task.defer(function() watchPrompt(desc) end)
                end
            end)
            table.insert(_allowWatchConns, addConn)
        end
    end

    SS.SSAutoAlwRow = Instance.new("Frame")
    SS.SSAutoAlwRow.Size             = UDim2.new(1, 0, 0, isMobile and 24 or 22)
    SS.SSAutoAlwRow.BackgroundColor3 = SS.BTN
    SS.SSAutoAlwRow.BorderSizePixel  = 0
    SS.SSAutoAlwRow.ZIndex           = 20
    SS.SSAutoAlwRow.Parent           = SS.SSContent
    Corner(SS.SSAutoAlwRow, 8)
    Stroke(SS.SSAutoAlwRow, Color3.fromRGB(45, 45, 45), 1)

    SS.SSAutoAlwLbl = Instance.new("TextLabel")
    SS.SSAutoAlwLbl.Size              = UDim2.new(1, -64, 1, 0)
    SS.SSAutoAlwLbl.Position          = UDim2.new(0, 10, 0, 0)
    SS.SSAutoAlwLbl.BackgroundTransparency = 1
    SS.SSAutoAlwLbl.Text              = "Auto TP on Allow"
    SS.SSAutoAlwLbl.TextSize          = isMobile and 10 or 12
    SS.SSAutoAlwLbl.Font              = Enum.Font.GothamMedium
    SS.SSAutoAlwLbl.TextColor3        = Color3.fromRGB(245, 245, 245)
    SS.SSAutoAlwLbl.TextXAlignment    = Enum.TextXAlignment.Left
    SS.SSAutoAlwLbl.TextYAlignment    = Enum.TextYAlignment.Center
    SS.SSAutoAlwLbl.ZIndex            = 21
    SS.SSAutoAlwLbl.Parent            = SS.SSAutoAlwRow

    SS.SSAutoAlwTrack = Instance.new("Frame")
    SS.SSAutoAlwTrack.Size             = UDim2.new(0, 28, 0, 16)
    SS.SSAutoAlwTrack.Position         = UDim2.new(1, -36, 0.5, -8)
    SS.SSAutoAlwTrack.BackgroundColor3 = T.TrackOff
    SS.SSAutoAlwTrack.BorderSizePixel  = 0
    SS.SSAutoAlwTrack.ZIndex           = 21
    SS.SSAutoAlwTrack.Parent           = SS.SSAutoAlwRow
    Corner(SS.SSAutoAlwTrack, 8)
    SS.SSAutoAlwTStroke = Stroke(SS.SSAutoAlwTrack, T.Border, 1)

    SS.SSAutoAlwKnob = Instance.new("Frame")
    SS.SSAutoAlwKnob.Size             = UDim2.new(0, 12, 0, 12)
    SS.SSAutoAlwKnob.Position         = UDim2.new(0, 2, 0.5, -6)
    SS.SSAutoAlwKnob.BackgroundColor3 = T.KnobOff
    SS.SSAutoAlwKnob.BorderSizePixel  = 0
    SS.SSAutoAlwKnob.ZIndex           = 22
    SS.SSAutoAlwKnob.Parent           = SS.SSAutoAlwTrack
    Corner(SS.SSAutoAlwKnob, 6)

    SS.SSAutoAlwBtn = Instance.new("Frame")
    SS.SSAutoAlwBtn.Size                   = UDim2.new(1, 0, 1, 0)
    SS.SSAutoAlwBtn.BackgroundTransparency = 1
    SS.SSAutoAlwBtn.ZIndex                 = 24
    SS.SSAutoAlwBtn.Active                 = true
    SS.SSAutoAlwBtn.Parent                 = SS.SSAutoAlwRow

    local function ssAutoAlwApplyVisual(on)
        if on then
            Tween(SS.SSAutoAlwKnob,    M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,21,0.5,-8)})
            Tween(SS.SSAutoAlwKnob,    M, {BackgroundColor3 = T.KnobOn})
            Tween(SS.SSAutoAlwTrack,   M, {BackgroundColor3 = T.TrackOn})
            Tween(SS.SSAutoAlwTStroke, M, {Color = T.TrackOn})
        else
            Tween(SS.SSAutoAlwKnob,    M, {Size = UDim2.new(0,16,0,16), Position = UDim2.new(0,3,0.5,-8)})
            Tween(SS.SSAutoAlwKnob,    M, {BackgroundColor3 = T.KnobOff})
            Tween(SS.SSAutoAlwTrack,   M, {BackgroundColor3 = T.TrackOff})
            Tween(SS.SSAutoAlwTStroke, M, {Color = T.Border})
        end
    end

    local function ssAutoAlwDoToggle()
        SS.autoTPOnAllowState = not SS.autoTPOnAllowState
        if SS.autoTPOnAllowState then
            Tween(SS.SSAutoAlwKnob, TweenInfo.new(0.06), {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,4,0.5,-7)})
            task.delay(0.06, function() ssAutoAlwApplyVisual(true) end)
            pcall(setupAllowWatcher)
        else
            Tween(SS.SSAutoAlwKnob, TweenInfo.new(0.06), {Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,20,0.5,-7)})
            task.delay(0.06, function() ssAutoAlwApplyVisual(false) end)
        end
        Config.toggles["ss_auto_tp_on_allow"] = SS.autoTPOnAllowState
        pcall(FH_SaveConfig)
    end

    do
        local _alwTouchActive = false
        local _alwTouchStart  = nil
        SS.SSAutoAlwBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                ssAutoAlwDoToggle()
            elseif inp.UserInputType == Enum.UserInputType.Touch then
                _alwTouchActive = true
                _alwTouchStart  = inp.Position
            end
        end)
        SS.SSAutoAlwBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _alwTouchActive then
                _alwTouchActive = false
                if _alwTouchStart and (inp.Position - _alwTouchStart).Magnitude < 20 then
                    ssAutoAlwDoToggle()
                end
                _alwTouchStart = nil
            end
        end)
    end

    configRegistry["ss_auto_tp_on_allow"] = {
        getState   = function() return SS.autoTPOnAllowState end,
        getKeyCode = function() return nil end,
        setKeyCode = function() end,
        doToggle   = ssAutoAlwDoToggle,
        setEnabled = function(v)
            SS.autoTPOnAllowState = v
            ssAutoAlwApplyVisual(v)
            if v then pcall(setupAllowWatcher) end
            Config.toggles["ss_auto_tp_on_allow"] = v
            if not _G._FH_IsRestoring then pcall(FH_SaveConfig) end
        end,
    }
end

do

    local _savedMethod = Config and Config.toggles and Config.toggles["ss_steal_method"]
    if _savedMethod == "Walk" or _savedMethod == "Prime" then
        SS.stealMethod = _savedMethod
    end

    SS.SSMethodRow = Instance.new("Frame")
    SS.SSMethodRow.Size             = UDim2.new(1, 0, 0, isMobile and 26 or 24)
    SS.SSMethodRow.BackgroundColor3 = SS.BTN
    SS.SSMethodRow.BorderSizePixel  = 0
    SS.SSMethodRow.ZIndex           = 20
    SS.SSMethodRow.Parent           = SS.SSContent
    Corner(SS.SSMethodRow, 8)
    Stroke(SS.SSMethodRow, Color3.fromRGB(45, 45, 45), 1)

    SS.SSMethodBtn = Instance.new("TextButton")
    SS.SSMethodBtn.Size             = UDim2.new(1, 0, 1, 0)
    SS.SSMethodBtn.Position         = UDim2.new(0, 0, 0, 0)
    SS.SSMethodBtn.AnchorPoint      = Vector2.new(0, 0)
    SS.SSMethodBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SS.SSMethodBtn.BorderSizePixel  = 0
    SS.SSMethodBtn.Text             = SS.stealMethod
    SS.SSMethodBtn.TextSize         = isMobile and 10 or 11
    SS.SSMethodBtn.Font             = Enum.Font.GothamBold
    SS.SSMethodBtn.TextColor3       = Color3.fromRGB(20, 20, 20)
    SS.SSMethodBtn.AutoButtonColor  = false
    SS.SSMethodBtn.ZIndex           = 22
    SS.SSMethodBtn.Parent           = SS.SSMethodRow
    Corner(SS.SSMethodBtn, 8)
    Stroke(SS.SSMethodBtn, Color3.fromRGB(200, 200, 200), 1, 0.6)

    SS.SSMethodKbLbl = Instance.new("TextLabel")
    SS.SSMethodKbLbl.Size                   = UDim2.new(0, 40, 0, 14)
    SS.SSMethodKbLbl.Position               = UDim2.new(1, -44, 0.5, -7)
    SS.SSMethodKbLbl.BackgroundTransparency = 1
    SS.SSMethodKbLbl.Text                   = ""
    SS.SSMethodKbLbl.TextSize               = 10
    SS.SSMethodKbLbl.Font                   = Enum.Font.GothamBold
    SS.SSMethodKbLbl.TextColor3             = Color3.fromRGB(80, 80, 80)
    SS.SSMethodKbLbl.TextXAlignment         = Enum.TextXAlignment.Center
    SS.SSMethodKbLbl.ZIndex                 = 23
    SS.SSMethodKbLbl.Parent                 = SS.SSMethodBtn

    local _methodEntry = { keyCode = nil }
    do
        local _saved = Config and Config.keybinds and Config.keybinds["ss_steal_method"]
        if type(_saved) == "string" then
            local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
            if _ok and _kc then
                _methodEntry.keyCode    = _kc
                SS.SSMethodKbLbl.Text   = "[" .. _saved .. "]"
            end
        end
    end

    local function _cycleMethod()
        SS.stealMethod = (SS.stealMethod == "Walk") and "Prime" or "Walk"
        SS.SSMethodBtn.Text = SS.stealMethod
        Config.toggles["ss_steal_method"] = SS.stealMethod
        pcall(FH_SaveConfig)
    end

    local _methodTouchActive = false
    local _methodTouchStart  = nil
    local _methodKb2Debounce = false
    SS.SSMethodBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            _cycleMethod()
        elseif inp.UserInputType == Enum.UserInputType.Touch then
            _methodTouchActive = true
            _methodTouchStart  = inp.Position
        elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
            if _methodKb2Debounce then return end
            _methodKb2Debounce = true
            task.delay(0.2, function() _methodKb2Debounce = false end)
            if keybindBindingTarget then
                local prev = keybindBindingTarget
                keybindBindingTarget = nil
                if prev.kbLbl == SS.SSMethodKbLbl then
                    SS.SSMethodKbLbl.Text = _methodEntry.keyCode and ("[".. _methodEntry.keyCode.Name .. "]") or ""
                    return
                else
                    prev.kbLbl.Text = prev.entry.keyCode and ("[".. prev.entry.keyCode.Name .. "]") or ""
                end
            end
            SS.SSMethodKbLbl.Text = "(...)"
            keybindBindingTarget = { entry = _methodEntry, kbLbl = SS.SSMethodKbLbl, mode = "assign" }
        end
    end)
    SS.SSMethodBtn.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch and _methodTouchActive then
            _methodTouchActive = false
            if _methodTouchStart and (inp.Position - _methodTouchStart).Magnitude < 20 then
                _cycleMethod()
            end
            _methodTouchStart = nil
        end
    end)
    table.insert(keybindEntries, { entry = _methodEntry, fire = _cycleMethod, kbLbl = SS.SSMethodKbLbl })
    configRegistry["ss_steal_method"] = {
        getState   = function() return false end,
        getKeyCode = function() return _methodEntry.keyCode end,
        setKeyCode = function(kc)
            _methodEntry.keyCode = kc
            if kc then
                SS.SSMethodKbLbl.Text = "[".. kc.Name .. "]"
                Config.keybinds = Config.keybinds or {}
                Config.keybinds["ss_steal_method"] = kc.Name
            else
                SS.SSMethodKbLbl.Text = ""
                if Config.keybinds then Config.keybinds["ss_steal_method"] = nil end
            end
            pcall(FH_SaveConfig)
        end,
        doToggle   = _cycleMethod,
        kbLbl      = SS.SSMethodKbLbl,
        kbEntry    = _methodEntry,
    }
end

SS.player = Players.LocalPlayer
SS.SSFFlags = {
    GameNetPVHeaderRotationalVelocityZeroCutoffExponent           = -5000,
    LargeReplicatorWrite5                                          = true,
    LargeReplicatorEnabled9                                        = true,
    AngularVelociryLimit                                           = 360,
    TimestepArbiterVelocityCriteriaThresholdTwoDt                  = 2147483646,
    S2PhysicsSenderRate                                            = 15000,
    DisableDPIScale                                                = true,
    MaxDataPacketPerSend                                           = 2147483647,
    PhysicsSenderMaxBandwidthBps                                   = 20000,
    TimestepArbiterHumanoidLinearVelThreshold                      = 21,
    MaxMissedWorldStepsRemembered                                  = -2147483648,
    PlayerHumanoidPropertyUpdateRestrict                           = true,
    SimDefaultHumanoidTimestepMultiplier                           = 0,
    StreamJobNOUVolumeLengthCap                                    = 2147483647,
    DebugSendDistInSteps                                           = -2147483648,
    GameNetDontSendRedundantNumTimes                               = 1,
    CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent  = 1,
    CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
    LargeReplicatorSerializeRead3                                  = true,
    ReplicationFocusNouExtentsSizeCutoffForPauseStuds              = 2147483647,
    CheckPVCachedVelThresholdPercent                               = 10,
    CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
    GameNetDontSendRedundantDeltaPositionMillionth                 = 1,
    InterpolationFrameVelocityThresholdMillionth                   = 5,
    StreamJobNOUVolumeCap                                          = 2147483647,
    InterpolationFrameRotVelocityThresholdMillionth                = 5,
    CheckPVCachedRotVelThresholdPercent                            = 10,
    WorldStepMax                                                   = 30,
    InterpolationFramePositionThresholdMillionth                   = 5,
    TimestepArbiterHumanoidTurningVelThreshold                     = 1,
    SimOwnedNOUCountThresholdMillionth                             = 2147483647,
    GameNetPVHeaderLinearVelocityZeroCutoffExponent                = -5000,
    NextGenReplicatorEnabledWrite4                                  = true,
    TimestepArbiterOmegaThou                                       = 1073741823,
    MaxAcceptableUpdateDelay                                       = 1,
    LargeReplicatorSerializeWrite4                                  = true,
}
SS.SSSetFFlags = function()
    for k, v in pairs(SS.SSFFlags) do
        pcall(function() setfflag(k, tostring(v)) end)
    end
end
SS.SSTeleportHRP = function(position)
    local character = SS.player.Character or SS.player.CharacterAdded:Wait()
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.Velocity = Vector3.zero
    _G._FH_CarpetTP(CFrame.new(position))
end
SS.SSGetPartFromPrompt = function(prompt)
    local o = prompt.Parent
    if o:IsA("BasePart") then return o end
    if o:IsA("Model") then
        return o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
    end
    if o:IsA("Attachment") then return o.Parent end
    return o:FindFirstChildWhichIsA("BasePart", true)
end
SS.SSFindNearestStealPrompt = function()
    local char = SS.player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, t in pairs(plots:GetDescendants()) do
        if t:IsA("ProximityPrompt") and t.Enabled and t.ActionText == "Steal"then
            local part = SS.SSGetPartFromPrompt(t)
            if part then
                local dist = (hrp.Position - part.Position).Magnitude
                if dist < nearestDist then nearestDist = dist; nearest = t end
            end
        end
    end
    return nearest
end
local SSE = { animals = {}, prompts = {}, stealing = false }
do
    local function sseIsMyBase(n)
        local p = workspace.Plots:FindFirstChild(n)
        if not p then return false end
        local s = p:FindFirstChild("PlotSign")
        return s and s:FindFirstChild("YourBase") and s.YourBase.Enabled
    end
    local function sseScan(plot)
        if not plot or not plot:IsA("Model") or sseIsMyBase(plot.Name) then return end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if not pods then return end
        for _, pod in ipairs(pods:GetChildren()) do
            if pod:IsA("Model") and pod:FindFirstChild("Base") then
                table.insert(SSE.animals, {
                    plot = plot.Name, slot = pod.Name,
                    worldPosition = pod:GetPivot().Position,
                    uid = plot.Name.."_"..pod.Name,
                })
            end
        end
    end
    task.spawn(function()
        local plots = workspace:WaitForChild("Plots", 10)
        if not plots then return end
        for _, p in ipairs(plots:GetChildren()) do sseScan(p) end
        plots.ChildAdded:Connect(sseScan)
        task.spawn(function()
            while task.wait(5) do
                table.clear(SSE.animals)
                for _, p in ipairs(plots:GetChildren()) do sseScan(p) end
            end
        end)
    end)
    function SSE.findPrompt(a)
        local c = SSE.prompts[a.uid]
        if c and c.Parent then return c end
        local plot = workspace.Plots:FindFirstChild(a.plot)
        if not plot then return nil end
        local pod  = plot:FindFirstChild("AnimalPodiums") and plot.AnimalPodiums:FindFirstChild(a.slot)
        local sp   = pod and pod:FindFirstChild("Base") and pod.Base:FindFirstChild("Spawn")
        local att  = sp  and sp:FindFirstChild("PromptAttachment")
        local pr   = att and att:FindFirstChildOfClass("ProximityPrompt")
        if pr then SSE.prompts[a.uid] = pr end
        return pr
    end
    function SSE.build(prompt)
        if InternalStealCache[prompt] then return end
        local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
        local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 then for _, c in ipairs(c1) do table.insert(data.holdCallbacks,   c.Function) end end
        local ok2, c2 = pcall(getconnections, prompt.Triggered)
        if ok2 then for _, c in ipairs(c2) do table.insert(data.triggerCallbacks, c.Function) end end
        InternalStealCache[prompt] = data
    end
    function SSE.nearest()
        local char = Players.LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local best, bd = nil, math.huge
        for _, a in ipairs(SSE.animals) do
            local d = (hrp.Position - a.worldPosition).Magnitude
            if d < bd and d <= 2000 then bd = d; best = a end
        end
        return best
    end
    function SSE.activate(usePotion)
        local animal = SSE.nearest()
        if not animal then return end
        local prompt = SSE.findPrompt(animal)
        if not prompt then return end
        local _agNearReg = configRegistry["Auto Grab Nearest"]
        local _agBestReg = configRegistry["Auto Grab Best"]
        local _wasAgNear = _agNearReg and _agNearReg.getState and _agNearReg.getState() or false
        local _wasAgBest = _agBestReg and _agBestReg.getState and _agBestReg.getState() or false
        if _wasAgNear and _agNearReg.setEnabled then pcall(_agNearReg.setEnabled, false) end
        if _wasAgBest and _agBestReg.setEnabled then pcall(_agBestReg.setEnabled, false) end
        local function _restoreAG()
            if _wasAgNear and _agNearReg and _agNearReg.setEnabled then pcall(_agNearReg.setEnabled, true) end
            if _wasAgBest and _agBestReg and _agBestReg.setEnabled then pcall(_agBestReg.setEnabled, true) end
        end
        local ok, PC  = pcall(require, game.ReplicatedStorage.Controllers.PlotController)
        if not ok or not PC then _restoreAG(); return end
        local ok2, mp = pcall(function() return PC:GetMyPlot().PlotModel end)
        if not ok2 or not mp then _restoreAG(); return end
        local side = mp:GetAttribute("Order")
        SSE.build(prompt)
        local data = InternalStealCache[prompt]
        if not data then _restoreAG(); return end
        data.ready   = true
        if SSE.stealing then _restoreAG(); return end
        data.ready   = false
        SSE.stealing = true
        task.spawn(function()

            _FH_V2FireStealPrompt(prompt, function()

                local char2 = Players.LocalPlayer.Character
                local hrp2  = char2 and char2:FindFirstChild("HumanoidRootPart")
                local hum2  = char2 and char2:FindFirstChildOfClass("Humanoid")
                local bp2   = Players.LocalPlayer:FindFirstChild("Backpack")
                if hrp2 then
                    if hum2 and bp2 then
                        local carpet = bp2:FindFirstChild("Flying Carpet")
                        if carpet then hum2:EquipTool(carpet) end
                    end
                    if side == 1 then
                        hrp2.CFrame = CFrame.new(-353.00,-2.08,113.81); task.wait(0.1)
                        hrp2.CFrame = CFrame.new(-351.93,-2.24,8.08);   task.wait(0.2)
                        hrp2.CFrame = CFrame.new(-336.110,-4.123,19.840); task.wait(0.31)
                        hrp2.CFrame = CFrame.new(-352.860,-6.087,44.180)
                    elseif side == 2 then
                        hrp2.CFrame = CFrame.new(-352.76,-0.50,7.06);   task.wait(0.1)
                        hrp2.CFrame = CFrame.new(-353.28,-0.70,114.19); task.wait(0.2)
                        hrp2.CFrame = CFrame.new(-335.17,-4.81,102.54); task.wait(0.31)
                        hrp2.CFrame = CFrame.new(-351.980011,-7.00000238,75.5400009,1,0,0,0,1,0,0,0,1)
                    end
                    if usePotion then
                        local potion = Players.LocalPlayer.Backpack:FindFirstChild("Giant Potion")
                        if potion then
                            potion.Parent = Players.LocalPlayer.Character
                            potion:Activate()
                            potion.Parent = Players.LocalPlayer.Backpack
                        end
                    end
                    ShowToggleNotification("Teleported!", true)
                end
            end)
            task.wait(0.2)
            data.ready   = true
            SSE.stealing = false
            _restoreAG()
        end)
    end
end
SS.SSEquipGrapple = function()
    local char    = SS.player.Character
    local backpack = SS.player:FindFirstChild("Backpack")
    if not char or not backpack then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then tool.Parent = backpack end
    end
    local carpet = backpack:FindFirstChild("Flying Carpet")
    if carpet then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(carpet) end
    end
end
SS.SSRunStealLogic = function(preferredPrompt)
    local b = 0.01
    local char = SS.player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local function getPartFromPrompt(prompt)
        local p = prompt.Parent
        if p:IsA("BasePart") then return p end
        if p:IsA("Model") then return p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart") end
        if p:IsA("Attachment") then return p.Parent end
        return p:FindFirstChildWhichIsA("BasePart", true)
    end
    local function findNearest()
        local best, bestDist = nil, math.huge
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, t in pairs(plots:GetDescendants()) do
            if t:IsA("ProximityPrompt") and t.Enabled and t.ActionText == "Steal"then
                local part = getPartFromPrompt(t)
                if part then
                    local d = (hrp.Position - part.Position).Magnitude
                    if d < bestDist then bestDist = d; best = t end
                end
            end
        end
        return best
    end
    local function firePrompt(x)
        if not x or not x:IsDescendantOf(workspace) then return end
        x.MaxActivationDistance = 9e9
        x.RequiresLineOfSight   = false
        x.ClickablePrompt       = true
        local target = _FH_ResolvePromptTarget(x)
        if not target then return end
        if SS._semiStealCtx then
            SS._semiStealCtx.target = target
            _FH_FinishSteal(SS._semiStealCtx)
            SS._semiStealCtx = nil
        else
            local ctx = _FH_StartTrip(target)
            _FH_FinishSteal(ctx)
        end
    end
    local target = preferredPrompt
    if not (target and target.Parent) then
        target = findNearest()
    end
    if target then firePrompt(target) end
end
SS._BASES = SS._BASES or {
    b1 = { refVec = Vector3.new(-337, -5, 100), finalPos = Vector3.new(-337,    -5,    103)   },
    b2 = { refVec = Vector3.new(-335, -5,  20), finalPos = Vector3.new(-334.80, -5.04, 18.90) },
}
SS._RIGHT_BASE = CFrame.new(-371, -6, 30)
SS._LEFT_BASE  = CFrame.new(-373, -7, 83)

SS.SSDoTeleport = function()
    local player = SS.player
    if not player then return end
    local char = player.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local _pogReg    = configRegistry["Potion On Grab"]
    local _agNearReg = configRegistry["Auto Grab Nearest"]
    local _agBestReg = configRegistry["Auto Grab Best"]
    local _wasPotionOn = _pogReg    and _pogReg.getState()    or false
    local _wasAgNear   = _agNearReg and _agNearReg.getState() or false
    local _wasAgBest   = _agBestReg and _agBestReg.getState() or false
    local _restored = false
    local function _restoreAGs()
        if _restored then return end
        _restored = true
        if _wasPotionOn and _pogReg    then pcall(_pogReg.setEnabled,    true) end
        if _wasAgNear   and _agNearReg then pcall(_agNearReg.setEnabled, true) end
        if _wasAgBest   and _agBestReg then pcall(_agBestReg.setEnabled, true) end
    end
    if _wasPotionOn and _pogReg    then pcall(_pogReg.setEnabled,    false) end
    if _wasAgNear   and _agNearReg then pcall(_agNearReg.setEnabled, false) end
    if _wasAgBest   and _agBestReg then pcall(_agBestReg.setEnabled, false) end

    SS.semiInstantMode = "Semi"

    local right_base = SS._RIGHT_BASE
    local left_base  = SS._LEFT_BASE
    local bases      = SS._BASES

    local function __isPrimeMethod()    return SS.stealMethod == "Prime" end
    local function isWalkMode()         return SS.stealMethod ~= "Prime" end
    local function equipCarpet()        SS.SSEquipGrapple() end
    local function drinkPotion()        if SS.potionState then pcall(_activateGiantPotion) end end

    local canDirectTp, tpThroughWaypoints, doApproachPath

    canDirectTp = function(HRP, targetPos)
        if not HRP or not targetPos then return false end
        local origin = HRP.Position
        local ignored = { player.Character }
        for _ = 1, 12 do
            local direction = targetPos - origin
            if direction.Magnitude <= 0.05 then return true end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = ignored
            params.IgnoreWater = true
            local result = workspace:Raycast(origin, direction, params)
            if not result then return true end
            local hit = result.Instance
            if not hit then return true end
            if hit:IsA("BasePart") and not hit.CanCollide then
                table.insert(ignored, hit)
                origin = result.Position + direction.Unit * 0.1
            else
                return (result.Position - targetPos).Magnitude <= 3
            end
        end
        return false
    end

    tpThroughWaypoints = function(HRP, waypoints)
        if #waypoints == 0 then return end
        local startIndex = 1
        for i = #waypoints, 1, -1 do
            if canDirectTp(HRP, waypoints[i]) then startIndex = i; break end
        end
        for i = startIndex, #waypoints do
            HRP.CFrame = CFrame.new(waypoints[i])
            if i < #waypoints then task.wait(0.135) end
        end
    end

    local function walkTo(HRP, targetPos, speed, arriveDist, timeout)
        if not HRP or not HRP.Parent or not targetPos then return end
        speed      = speed      or 180
        arriveDist = arriveDist or 6
        timeout    = timeout    or 6
        equipCarpet()
        local _ctrls
        pcall(function()
            _ctrls = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
        end)
        if _ctrls then pcall(function() _ctrls:Disable() end) end
        local start = tick()
        while HRP and HRP.Parent do
            local d    = targetPos - HRP.Position
            local flat = Vector3.new(d.X, 0, d.Z)
            local mag  = flat.Magnitude
            if mag < arriveDist then break end
            if tick() - start > timeout then break end
            local effSpeed = speed
            if mag < 25 then effSpeed = math.max(60, speed * (mag / 25)) end
            local dir = flat.Unit
            local vy  = HRP.Velocity.Y
            HRP.Velocity = Vector3.new(dir.X * effSpeed, vy, dir.Z * effSpeed)
            task.wait()
        end
        if HRP and HRP.Parent then
            HRP.Velocity = Vector3.new(0, 0, 0)
            HRP.CFrame   = CFrame.new(targetPos)
        end
        if _ctrls then pcall(function() _ctrls:Enable() end) end
    end

    _G._FH_WalkTo = function(targetPos, speed, arriveDist, timeout)
        return walkTo(hrp, targetPos, speed, arriveDist, timeout)
    end

    local plots = workspace:FindFirstChild("Plots")
    if not plots then _restoreAGs(); return end
    local myName = player.DisplayName
    local enemyPlots = {}
    for _, plot in ipairs(plots:GetChildren()) do
        local sign  = plot:FindFirstChild("PlotSign")
        local label = sign and sign:FindFirstChild("SurfaceGui")
            and sign.SurfaceGui:FindFirstChild("Frame")
            and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
        if label and label.Text ~= "Empty Base" then
            local owner = label.Text:gsub("'s Base$",""):gsub("'s base$",""):gsub("%s+$","")
            if owner ~= myName then table.insert(enemyPlots, plot) end
        end
    end

    local function getClosestPodium()
        if #enemyPlots == 0 then return nil end
        local best, bestDist = nil, math.huge
        for _, plot in ipairs(enemyPlots) do
            local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then continue end
            local plotPos = nil
            for _, part in ipairs(plot:GetDescendants()) do
                if part:IsA("BasePart") then plotPos = part.Position; break end
            end
            local plotIsBase1 = true
            if plotPos then
                local d1 = (plotPos - bases.b1.refVec).Magnitude
                local d2 = (plotPos - bases.b2.refVec).Magnitude
                plotIsBase1 = d1 < d2
            end
            for _, pname in ipairs({"1","10"}) do
                local podium = podiums:FindFirstChild(pname); if not podium then continue end
                local cm = podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main"); if not cm then continue end
                local d = (hrp.Position - cm.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    local spawn  = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
                    local pa     = spawn and spawn:FindFirstChild("PromptAttachment")
                    local prompt = pa and pa:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        best = {
                            plot         = plot,
                            podiumName   = pname,
                            position     = cm.Position,
                            prompt       = prompt,
                            promptPos    = pa.WorldPosition,
                            distance     = d,
                            isEnemyBase1 = plotIsBase1,
                        }
                    end
                end
            end
        end
        return best
    end

    local carpet  = char:FindFirstChild("Flying Carpet") or (player.Backpack and player.Backpack:FindFirstChild("Flying Carpet"))
    local podium  = getClosestPodium()
    if not podium then _restoreAGs(); return end

    local finalPos
    do
        local dB1 = (podium.position - bases.b1.refVec).Magnitude
        local dB2 = (podium.position - bases.b2.refVec).Magnitude
        finalPos  = (dB1 < dB2) and bases.b1.finalPos or bases.b2.finalPos
    end

    if carpet then pcall(function() hum:EquipTool(carpet) end) end

    local netCtx = _FH_StartTrip({ plotName = podium.plot.Name, pod = tonumber(podium.podiumName) or podium.podiumName })
    SS._semiStealCtx = netCtx

    local function doTpSequence(HRP, fPos, pod)
        local isAtBase1
        do
            local dB1 = (pod.position - bases.b1.refVec).Magnitude
            local dB2 = (pod.position - bases.b2.refVec).Magnitude
            isAtBase1 = dB1 < dB2
        end

        local redPos   = isAtBase1 and Vector3.new(-337, -5, 100)         or Vector3.new(-335, -5, 20)
        local greenPos = isAtBase1 and Vector3.new(-347.12, -6.67, 81.64) or Vector3.new(-349.43, -6.78, 37.47)

        local approachWaypoints
        if not isAtBase1 then
            approachWaypoints = {
                Vector3.new(-351.49, -6.65, 113.72),
                Vector3.new(-352.54, -6.83,   6.66),
                Vector3.new(-334.80, -5.04,  18.90),
            }
        else
            approachWaypoints = {
                Vector3.new(-352.54, -6.83,   6.66),
                Vector3.new(-351.49, -6.65, 113.72),
                Vector3.new(-337,    -5,    103),
            }
        end

        doApproachPath = function(HRP_, _pod, _isAtBase1)
            if isWalkMode() then
                local startIndex = 1
                for i = #approachWaypoints, 1, -1 do
                    if canDirectTp(HRP_, approachWaypoints[i]) then startIndex = i; break end
                end
                for i = startIndex, #approachWaypoints do
                    walkTo(HRP_, approachWaypoints[i], 180)
                end
                return
            end
            if _pod and redPos and canDirectTp(HRP_, redPos) then
                HRP_.CFrame = CFrame.new(redPos)
            else
                tpThroughWaypoints(HRP_, approachWaypoints)
            end
        end

        if __isPrimeMethod() then
            local prompt = pod and pod.prompt
            if not prompt or not prompt.Parent then return end
            prompt.RequiresLineOfSight   = false
            prompt.MaxActivationDistance = math.huge
            equipCarpet()
            HRP.CFrame = isAtBase1 and CFrame.new(-343.08, -6.84, 93.20) or CFrame.new(-342.91, -6.81, 28.00)
            task.wait(0.25)
            HRP.CFrame = isAtBase1 and CFrame.new(-340.16, -7.29, 48.82) or CFrame.new(-340.16, -7.29, 72.40)
            task.wait(0.12)
            HRP.CFrame = isAtBase1 and CFrame.new(-341.26, -7.29, 66.95) or CFrame.new(-341.26, -7.29, 54.27)
            task.wait(0.12)
            HRP.CFrame = isAtBase1 and CFrame.new(-339.93, -7.29, 82.14) or CFrame.new(-339.63, -7.29, 39.33)
            task.wait(0.18)
            local ctx = __FH_v2.startStealHold(prompt, "Prime")
            HRP.CFrame = isAtBase1 and CFrame.new(-354.04, -7.21, 90.42) or CFrame.new(-354.04, -7.21, 28.00)
            task.wait(0.45)
            HRP.CFrame = isAtBase1 and CFrame.new(-334.60, -5.00, 101.30) or CFrame.new(-334.60, -5.00, 19.30)
            if ctx and ctx.holdBeganAt then
                while tick() - ctx.holdBeganAt < __MIN_HOLD_TIME_v2 do task.wait() end
            end
            drinkPotion()
            equipCarpet()
            HRP.CFrame = isAtBase1 and CFrame.new(-351.53, -7.29, 83.66) or CFrame.new(-350.62, -7.29, 35.91)
            if ctx then __FH_v2.finishStealHold(ctx) end
        else
            local ctx
            if pod and pod.prompt and pod.prompt.Parent then
                pod.prompt.RequiresLineOfSight   = false
                pod.prompt.MaxActivationDistance = math.huge
                ctx = __FH_v2.startStealHold(pod.prompt, "Walk")
            end

            if ctx then __FH_v2.waitForStealTime(ctx, 0.8) end

            doApproachPath(HRP, pod, isAtBase1)

            task.wait(0.25)
            drinkPotion()
            equipCarpet()

            if pod and pod.prompt and pod.prompt.Parent and ctx then
                if greenPos then
                    __FH_v2.waitForStealTime(ctx, 1.3)
                    HRP.CFrame = CFrame.new(greenPos)
                end
                __FH_v2.finishStealHold(ctx)
            end
        end

        local startTime = tick()
        while player:GetAttribute("Stealing") == nil do
            if tick() - startTime >= 1 then break end
            task.wait(0.1)
        end
    end

    task.spawn(function()
      local _ok, _err = pcall(function()
        doTpSequence(hrp, finalPos, podium)
        SS._semiStealCtx = nil
        task.wait(0.9)
      end)
      _restoreAGs()
      if not _ok then warn("[FH SemiSteal] error during steal sequence: ", _err) end
    end)
end
SS.SSDoSteal = function()
    SS.SSDoTeleport()
end

SS.SSExecute = function()
    if SS.debounce then return end
    SS.debounce = true

    _G._FH_LastV2UseTime = os.clock()
    task.spawn(function()
        SS.SSSetFFlags()
        SS.SSDoTeleport()
        task.wait(1.2)
        SS.debounce = false
    end)
end
SS.SSMakeBtn = function(labelText, fireFn)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1, 0, 0, isMobile and 30 or 26)
    btn.BackgroundColor3 = SS.BTN
    btn.BorderSizePixel  = 0
    btn.Text             = labelText
    btn.TextSize         = isMobile and 12 or 13
    btn.Font             = Enum.Font.GothamBold
    btn.TextColor3       = Color3.fromRGB(245, 245, 245)
    btn.TextXAlignment   = Enum.TextXAlignment.Left
    btn.ClipsDescendants = false
    btn.ZIndex           = 20
    btn.Parent           = SS.SSContent
    Corner(btn, 8)
    Stroke(btn, Color3.fromRGB(45, 45, 45), 1)

    local _btnPad = Instance.new("UIPadding")
    _btnPad.PaddingLeft = UDim.new(0, 10)
    _btnPad.Parent = btn
    local kbLbl = Instance.new("TextLabel")
    kbLbl.Size                   = UDim2.new(0, 40, 0, 14)
    kbLbl.Position               = UDim2.new(1, -44, 0.5, -7)
    kbLbl.BackgroundTransparency = 1
    kbLbl.Text                   = ""
    kbLbl.TextSize               = 10
    kbLbl.Font                   = Enum.Font.GothamBold
    kbLbl.TextColor3             = T.Dim
    kbLbl.TextXAlignment         = Enum.TextXAlignment.Center
    kbLbl.ZIndex                 = 21
    kbLbl.Parent                 = btn
    local entry = { keyCode = nil }
    do
        local _ssKey  = "ss_btn_".. labelText:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
        local _saved  = Config and Config.keybinds and Config.keybinds[_ssKey]
        if type(_saved) == "string" then
            local _ok, _kc = pcall(function() return Enum.KeyCode[_saved] end)
            if _ok and _kc then
                entry.keyCode    = _kc
                kbLbl.Text       = "[" .. _saved .. "]"
                kbLbl.TextColor3 = T.Dim
            end
        end
    end
    btn.MouseEnter:Connect(function() Tween(btn, F, {BackgroundColor3 = SS.BTN_HOVER}) end)
    btn.MouseLeave:Connect(function() Tween(btn, F, {BackgroundColor3 = SS.BTN}) end)
    btn.MouseButton1Click:Connect(function()
        Tween(btn, F, {BackgroundColor3 = SS.BTN_HOVER})
        task.delay(0.12, function() Tween(btn, F, {BackgroundColor3 = SS.BTN}) end)
        fireFn()
    end)
    local ssKb2Debounce = false
    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton2 then return end
        if ssKb2Debounce then return end
        ssKb2Debounce = true
        task.delay(0.2, function() ssKb2Debounce = false end)
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
        kbLbl.Text           = "(...)"
kbLbl.TextColor3     = T.White
        keybindBindingTarget = { entry = entry, kbLbl = kbLbl, mode = "assign"}
    end)
    table.insert(keybindEntries, { entry = entry, fire = fireFn, kbLbl = kbLbl })
    local ssKey = "ss_btn_".. labelText:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
    configRegistry[ssKey] = {
        getState   = function() return false end,
        getKeyCode = function() return entry.keyCode end,
        setKeyCode = function(kc)
            entry.keyCode = kc
            if kc then
                kbLbl.Text       = "[".. kc.Name .. "]"
kbLbl.TextColor3 = T.Dim
                Config.keybinds[ssKey] = kc.Name
            else
                kbLbl.Text = ""
Config.keybinds[ssKey] = nil
            end
            pcall(FH_SaveConfig)
        end,
        doToggle = fireFn,
        kbLbl    = kbLbl,
        kbEntry  = entry,
    }
    return btn
end
SS.SSTeleportBtn = SS.SSMakeBtn("Teleport", function()
    SS.SSDoSteal()
end)
SS.SSActivateBtn = SS.SSMakeBtn("Activate", function()
    SS.SSSetFFlags()
    ShowToggleNotification("FFlags Applied!", true)
    task.spawn(function() doSelectedReset() end)
end)
do
    SS.SSHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            SS.dragging   = true
            SS.dragStart  = inp.Position
            SS.panelStart = SS.SSWin.Position
        end
    end)
    SS.SSHdr.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            SS.dragging = false
            Config.mini = Config.mini or {}
            Config.mini.ss_pos = { x = SS.SSWin.Position.X.Offset, y = SS.SSWin.Position.Y.Offset,
                                   xs = SS.SSWin.Position.X.Scale, ys = SS.SSWin.Position.Y.Scale }
            pcall(FH_SaveConfig)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if SS.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - SS.dragStart
            local newPos = UDim2.new(
                SS.panelStart.X.Scale, SS.panelStart.X.Offset + d.X,
                SS.panelStart.Y.Scale, SS.panelStart.Y.Offset + d.Y
            )
            SS.SSWin.Position         = newPos
            SS.SSBorderFrame.Position = UDim2.new(
                newPos.X.Scale, newPos.X.Offset - 2,
                newPos.Y.Scale, newPos.Y.Offset - 2
            )
        end
    end)
end
SS.SSMinBtn.MouseButton1Click:Connect(function()
    SS.minimized = not SS.minimized
    if SS.minimized then
        SS.SSWin.ClipsDescendants = false
        SS.SSHdrFill.Visible = false
        SS.SSHdrLine.Visible = false
        SS.SSContent.Visible = false
        Tween(SS.SSWin,         M, {Size = UDim2.new(0, SS.W, 0, 30)})
        Tween(SS.SSBorderFrame, M, {Size = UDim2.new(0, SS.W + 4, 0, 34)})
        SS.SSMinBtn.Text = "+"else
        SS.SSHdrFill.Visible = true
        SS.SSHdrLine.Visible = true
        Tween(SS.SSWin,         M, {Size = UDim2.new(0, SS.W, 0, SS.H)})
        Tween(SS.SSBorderFrame, M, {Size = UDim2.new(0, SS.W + 4, 0, SS.H + 4)})
        SS.SSMinBtn.Text = "\226\136\146"
task.delay(M.Time, function()
            SS.SSContent.Visible = true
            SS.SSWin.ClipsDescendants = true
        end)
    end
    if isMobile then
        Config.mini = Config.mini or {}
        Config.mini.ss_min = SS.minimized
        pcall(FH_SaveConfig)
    end
end)
SS.setSemiStealPanelVisible = function(vis)
    SS.SSWin.Visible         = vis
    SS.SSBorderFrame.Visible = vis
    if vis then
        local p = SS.SSWin.Position
        SS.SSBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if SS.minimized then
            SS.SSMinBtn.Text          = "+"
SS.SSContent.Visible      = false
            SS.SSHdrFill.Visible      = false
            SS.SSHdrLine.Visible      = false
            SS.SSWin.ClipsDescendants = false
            SS.SSWin.Size             = UDim2.new(0, SS.W, 0, 30)
            SS.SSBorderFrame.Size     = UDim2.new(0, SS.W + 4, 0, 34)
        else
            SS.SSMinBtn.Text          = "\226\136\146"
SS.SSContent.Visible      = true
            SS.SSHdrFill.Visible      = true
            SS.SSHdrLine.Visible      = true
            SS.SSWin.ClipsDescendants = true
            SS.SSWin.Size             = UDim2.new(0, SS.W, 0, SS.H)
            SS.SSBorderFrame.Size     = UDim2.new(0, SS.W + 4, 0, SS.H + 4)
        end
    end
end

do
    local function _ssApplySavedToggle(key)
        local savedT = (_FH_SavedConfig and _FH_SavedConfig.toggles)
                       or (Config and Config.toggles) or {}
        if savedT[key] ~= true then return end
        local reg = configRegistry and configRegistry[key]
        if not (reg and reg.setEnabled) then return end
        local wasRestoring = _G._FH_IsRestoring
        _G._FH_IsRestoring = true
        pcall(reg.setEnabled, true)
        _G._FH_IsRestoring = wasRestoring
        Config.toggles = Config.toggles or {}
        Config.toggles[key] = true
    end
    task.defer(function()
        _ssApplySavedToggle("ss_potion")
        _ssApplySavedToggle("ss_auto_tp_unlock")
        _ssApplySavedToggle("ss_auto_tp_on_allow")
    end)
end

local function _FH_InitQSModule()
    QS.W          = isMobile and 172 or 218
    QS.H          = isMobile and 228 or 262
    QS.minimized  = false
    QS.dragging   = false
    QS.dragStart  = nil
    QS.panelStart = nil
    QS.entry      = { keyCode = nil }

    do
        local s = (_FH_SavedConfig and _FH_SavedConfig.sliders) or {}
        QS.selectedAnimalName = s.qs_selected_animal_name
    end
    QS.selectedEntry = nil
    QS.lastEntries   = {}

    local PODIUM_MATCH_DISTANCE = 10

    local function qsParseMoney(text)
        text = string.lower(text or "")
        local num = tonumber(text:match("[%d%.]+")) or 0
        if text:find("k") then num = num * 1e3
        elseif text:find("m") then num = num * 1e6
        elseif text:find("b") then num = num * 1e9
        elseif text:find("t") then num = num * 1e12
        elseif text:find("qa") then num = num * 1e15
        end
        return num
    end

    local function qsReadDisplayAndGeneration(part)
        local displayName, generation
        for _, child in ipairs(part:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                for _, label in ipairs(child:GetDescendants()) do
                    if label:IsA("TextLabel") then
                        if label.Name == "DisplayName" then
                            displayName = label.Text
                        elseif label.Name == "Generation" then
                            generation = label.Text
                        end
                    end
                end
            end
        end
        return displayName, generation
    end

    local function qsFindAllAnimals()
        local results = {}
        local step = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local displayName, generation = qsReadDisplayAndGeneration(obj)
                if displayName and displayName ~= "" and generation and generation ~= "" then
                    table.insert(results, {
                        part        = obj,
                        displayName = displayName,
                        generation  = generation,
                        value       = qsParseMoney(generation),
                        position    = obj.Position,
                    })
                end
            end
            step = step + 1
            if step % 800 == 0 then task.wait() end
        end
        return results
    end

    local function qsFindAllPlots()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if plotsFolder then return plotsFolder:GetChildren() end
        return {}
    end

    local function qsGetPodiumNumber(podium)
        local n = tonumber(podium.Name)
        if n then return n end
        local m = podium.Name:match("(%d+)")
        if m then return tonumber(m) end
        return nil
    end

    local function qsGetPodiumPosition(podium)
        if podium:IsA("BasePart") then return podium.Position end
        if podium:IsA("Model") and podium.PrimaryPart then return podium.PrimaryPart.Position end
        local part = podium:FindFirstChildWhichIsA("BasePart", true)
        if part then return part.Position end
        if podium:IsA("Model") then
            local ok, cf = pcall(function() return podium:GetPivot().Position end)
            if ok then return cf end
        end
        return nil
    end

    local function qsFindPodiumsInPlot(plot)
        local results, seen = {}, {}
        for _, desc in ipairs(plot:GetDescendants()) do
            if (desc:IsA("Folder") or desc:IsA("Model")) and desc.Name:lower():find("podium")
                and not tonumber(desc.Name) then
                for _, child in ipairs(desc:GetChildren()) do
                    local num = qsGetPodiumNumber(child)
                    if num and not seen[child] then
                        seen[child] = true
                        local pos = qsGetPodiumPosition(child)
                        if pos then
                            table.insert(results, { podium = child, number = num, position = pos })
                        end
                    end
                end
            end
        end
        if #results == 0 then
            local numbered = {}
            for _, desc in ipairs(plot:GetDescendants()) do
                if (desc:IsA("Model") or desc:IsA("Folder")) and tonumber(desc.Name) then
                    local num = tonumber(desc.Name)
                    if num and num >= 1 and num <= 20 then
                        table.insert(numbered, { obj = desc, num = num })
                    end
                end
            end
            if #numbered >= 3 then
                for _, item in ipairs(numbered) do
                    if not seen[item.obj] then
                        seen[item.obj] = true
                        local pos = qsGetPodiumPosition(item.obj)
                        if pos then
                            table.insert(results, { podium = item.obj, number = item.num, position = pos })
                        end
                    end
                end
            end
        end
        return results
    end

    local function qsGetPlotOwnerName(plot)
        local plotSign = plot:FindFirstChild("PlotSign", true)
        if plotSign then
            for _, desc in ipairs(plotSign:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Text and desc.Text ~= "" then
                    local t  = desc.Text
                    local up = t:upper()
                    if up == "YOUR BASE" then return "YOU" end
                    if t:lower():find("empty") then return "Empty Base" end
                    local m = t:match("[Bb]ase [Oo]f%s+(.+)")
                    if m then return m end
                    if #t > 0 and #t < 30 then return t end
                end
            end
        end
        return plot.Name
    end

    local function qsComputePlotBounds(plot)
        local minX, maxX = math.huge, -math.huge
        local minZ, maxZ = math.huge, -math.huge
        local found = false
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA("BasePart") then
                local pos = desc.Position
                if pos.X < minX then minX = pos.X end
                if pos.X > maxX then maxX = pos.X end
                if pos.Z < minZ then minZ = pos.Z end
                if pos.Z > maxZ then maxZ = pos.Z end
                found = true
            end
        end
        if not found then return nil end
        return { minX = minX, maxX = maxX, minZ = minZ, maxZ = maxZ }
    end

    local function qsAnimalsInPlot(animals, plot, bounds)
        local nearby, pad = {}, 6
        for _, a in ipairs(animals) do
            local inside = a.part:IsDescendantOf(plot)
            if not inside and bounds then
                local p = a.position
                inside = p.X >= bounds.minX - pad and p.X <= bounds.maxX + pad
                    and p.Z >= bounds.minZ - pad and p.Z <= bounds.maxZ + pad
            end
            if inside then table.insert(nearby, a) end
        end
        return nearby
    end

    local function qsMatchAnimalsToPodiums(podiums, animals)
        local candidates = {}
        for pi, p in ipairs(podiums) do
            for ai, animal in ipairs(animals) do
                local diff = animal.position - p.position
                local horizDist = math.sqrt(diff.X * diff.X + diff.Z * diff.Z)
                local yDist     = math.abs(diff.Y)
                if horizDist < PODIUM_MATCH_DISTANCE and yDist < 60 then
                    local score = math.sqrt(horizDist * horizDist + yDist * yDist * 0.15)
                    table.insert(candidates, { pi = pi, ai = ai, score = score })
                end
            end
        end
        table.sort(candidates, function(a, b) return a.score < b.score end)

        local podiumToAnimal, usedAnimals, usedPodiums = {}, {}, {}
        for _, c in ipairs(candidates) do
            if not usedPodiums[c.pi] and not usedAnimals[c.ai] then
                podiumToAnimal[c.pi] = c.ai
                usedPodiums[c.pi]    = true
                usedAnimals[c.ai]    = true
            end
        end

        local entries = {}
        for pi, p in ipairs(podiums) do
            local matched = podiumToAnimal[pi]
            if matched then
                local a = animals[matched]
                table.insert(entries, {
                    number          = p.number,
                    podium          = p.podium,
                    podiumPosition  = p.position,
                    name            = a.displayName,
                    generation      = a.generation,
                    value           = a.value,
                    animalPart      = a.part,
                    animalPosition  = a.position,
                })
            end
        end
        return entries
    end

    function QS.scan()
        local animals = qsFindAllAnimals()
        local plots   = qsFindAllPlots()
        local entries = {}
        local idx = 0
        for _, plot in ipairs(plots) do
            local mine = false
            pcall(function() mine = _FH_AG_IsMyPlot(plot) end)
            if not mine then
                local owner       = qsGetPlotOwnerName(plot)
                local podiums     = qsFindPodiumsInPlot(plot)
                local bounds      = qsComputePlotBounds(plot)
                local plotAnimals = qsAnimalsInPlot(animals, plot, bounds)
                local matched     = qsMatchAnimalsToPodiums(podiums, plotAnimals)
                for _, e in ipairs(matched) do
                    if (tonumber(e.number) or 0) >= 11 then
                        e.plot     = plot
                        e.plotName = owner
                        e.uid      = plot.Name .. "_" .. tostring(e.number)
                        table.insert(entries, e)
                    end
                end
            end
            idx = idx + 1
            if idx % 2 == 0 then task.wait() end
        end
        table.sort(entries, function(a, b)
            return (a.value or 0) > (b.value or 0)
        end)
        local pset = _G._FH_PRIORITY_STEAL
        if pset and next(pset) then
            local filtered = {}
            for _, e in ipairs(entries) do
                if e.name and pset[e.name] then table.insert(filtered, e) end
            end
            entries = filtered
        end
        return entries
    end

    local function _qsFindPromptForEntry(entry)
        if not (entry and entry.plot and entry.plot.Parent) then return nil end
        local pods   = entry.plot:FindFirstChild("AnimalPodiums")
        local podium = pods and pods:FindFirstChild(tostring(entry.number))
        local base   = podium and podium:FindFirstChild("Base")
        local spawn  = base and base:FindFirstChild("Spawn")
        local att    = spawn and spawn:FindFirstChild("PromptAttachment")
        return att and att:FindFirstChildOfClass("ProximityPrompt") or nil
    end

    local _qsCBCache = {}
    local function _qsBuildCallbacks(prompt)
        if _qsCBCache[prompt] then return _qsCBCache[prompt] end
        local data = { holdCallbacks = {}, triggerCallbacks = {} }
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1) == "table" then
            for _, c in ipairs(conns1) do
                if type(c.Function) == "function" then
                    table.insert(data.holdCallbacks, c.Function)
                end
            end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2) == "table" then
            for _, c in ipairs(conns2) do
                if type(c.Function) == "function" then
                    table.insert(data.triggerCallbacks, c.Function)
                end
            end
        end
        if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
            _qsCBCache[prompt] = data
        end
        return data
    end

    local _qsEquipCarpet, _qsWalkToAnimal, _qsEquipFlashTool
    local function _qsInitHelpers()
        _qsEquipCarpet = function()
            local lp        = Players.LocalPlayer
            local character = lp.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local backpack = lp:FindFirstChildOfClass("Backpack")
            if not (humanoid and backpack) then return end
            local carpet = backpack:FindFirstChild("Flying Carpet") or character:FindFirstChild("Flying Carpet")
            if not carpet then
                for _, t in ipairs(backpack:GetChildren()) do
                    if t:IsA("Tool") and t.Name:lower():find("carpet") then
                        carpet = t
                        break
                    end
                end
            end
            if carpet and carpet.Parent == backpack then
                pcall(function() humanoid:EquipTool(carpet) end)
            end
        end

        _qsWalkToAnimal = function(entry)
            local lp        = Players.LocalPlayer
            local character = lp.Character
            local hrp       = character and character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            _qsEquipCarpet()
            local podPos = entry.podiumPosition or entry.animalPosition
            if not podPos then return end
            local diff = hrp.Position - podPos
            local horiz = Vector3.new(diff.X, 0, diff.Z)
            local dirAway
            if horiz.Magnitude < 0.5 then
                dirAway = Vector3.new(0, 0, 1)
            else
                dirAway = horiz.Unit
            end
            local walkTarget = podPos + dirAway * 5 + Vector3.new(0, -4, 0)
            local speed      = 240
            local arriveDist = 4
            local timeout    = 5
            local _ctrls
            pcall(function()
                _ctrls = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
            end)
            if _ctrls then pcall(function() _ctrls:Disable() end) end
            local start = tick()
            while hrp and hrp.Parent do
                local d   = walkTarget - hrp.Position
                local mag = d.Magnitude
                if mag < arriveDist then break end
                if tick() - start > timeout then break end
                local effSpeed = speed
                if mag < 30 then effSpeed = math.max(80, speed * (mag / 30)) end
                local dir = d.Unit
                hrp.Velocity = Vector3.new(dir.X * effSpeed, dir.Y * effSpeed, dir.Z * effSpeed)
                task.wait()
            end
            if hrp and hrp.Parent then
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
            if _ctrls then pcall(function() _ctrls:Enable() end) end
        end

        _qsEquipFlashTool = function()
            local lp   = Players.LocalPlayer
            local char = lp.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            local bp   = lp:FindFirstChildOfClass("Backpack")
            if not (hum and bp) then return nil end
            local function findFlash(parent)
                for _, t in ipairs(parent:GetChildren()) do
                    if t:IsA("Tool") and t.Name:lower():find("flash") then return t end
                end
                return nil
            end
            local tool = findFlash(char) or findFlash(bp)
            if tool and tool.Parent == bp then
                pcall(function() hum:EquipTool(tool) end)
            end
            return tool
        end
    end
    _qsInitHelpers()

    local _qsStartCameraLock, _qsStopCameraLock
    local function _qsInitCamLock()
        local active   = false
        local target   = nil
        local name     = "FH_QS_CamLock"
        local priorTy
        local bound    = false

        local function step()
            if not active then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            if not target then return end
            local lp   = Players.LocalPlayer
            local char = lp.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local headPos = hrp.Position + Vector3.new(0, 1.5, 0)
            local toTarget = target - headPos
            local horiz = Vector3.new(toTarget.X, 0, toTarget.Z)
            local backDir
            if horiz.Magnitude < 0.5 then
                backDir = Vector3.new(0, 0, -1)
            else
                backDir = -horiz.Unit
            end
            local camPos = headPos + backDir * 2.5 + Vector3.new(0, 0.5, 0)
            cam.CFrame = CFrame.new(camPos, target)
        end

        _qsStartCameraLock = function(targetPos)
            if not targetPos then return end
            target = targetPos
            if active then return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            active  = true
            priorTy = cam.CameraType
            pcall(function() cam.CameraType = Enum.CameraType.Scriptable end)
            if not bound then
                local ok = pcall(function()
                    RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, step)
                end)
                bound = ok and true or false
            end
            step()
        end

        _qsStopCameraLock = function()
            if not active then target = nil; return end
            active = false
            target = nil
            if bound then
                pcall(function() RunService:UnbindFromRenderStep(name) end)
                bound = false
            end
            local cam = workspace.CurrentCamera
            if cam then
                pcall(function() cam.CameraType = priorTy or Enum.CameraType.Custom end)
            end
            priorTy = nil
        end
    end
    _qsInitCamLock()

    local qsExecuting = false

    function QS.execute()
        if qsExecuting then return end
        if not QS.selectedEntry then
            pcall(ShowToggleNotification, "Quick Steal: select an animal first", false)
            return
        end
        local entry = QS.selectedEntry
        local plot  = entry.plot
        if not plot or not plot.Parent then
            pcall(ShowToggleNotification, "Quick Steal: target plot missing", false)
            return
        end
        local prompt = _qsFindPromptForEntry(entry)
        if not prompt then
            pcall(ShowToggleNotification, "Quick Steal: prompt not found", false)
            return
        end

        qsExecuting = true
        task.spawn(function()
            local data = _qsBuildCallbacks(prompt)
            if not data or (#data.holdCallbacks == 0 and #data.triggerCallbacks == 0) then
                pcall(ShowToggleNotification, "Quick Steal: prompt has no callbacks", false)
                qsExecuting = false
                return
            end

            local holdDuration = prompt.HoldDuration
            if not holdDuration or holdDuration <= 0 then holdDuration = 1.3 end

            local agNearReg = configRegistry["Auto Grab Nearest"]
            local agBestReg = configRegistry["Auto Grab Best"]
            local wasAgNear = agNearReg and agNearReg.getState() or false
            local wasAgBest = agBestReg and agBestReg.getState() or false
            if wasAgNear and agNearReg.setEnabled then pcall(agNearReg.setEnabled, false) end
            if wasAgBest and agBestReg.setEnabled then pcall(agBestReg.setEnabled, false) end

            _G._FH_LastV2UseTime = os.clock()

            local startTime = tick()

            for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end

            _qsWalkToAnimal(entry)

            local podiumAimPos
            do
                local pods   = entry.plot and entry.plot:FindFirstChild("AnimalPodiums")
                local podium = pods and pods:FindFirstChild(tostring(entry.number))
                local base   = podium and podium:FindFirstChild("Base")
                local spawn  = base and base:FindFirstChild("Spawn")
                local att    = spawn and spawn:FindFirstChild("PromptAttachment")
                if att then podiumAimPos = att.WorldPosition end
            end
            podiumAimPos = podiumAimPos or entry.podiumPosition or entry.animalPosition

            local flashTool = _qsEquipFlashTool()
            _qsStartCameraLock(podiumAimPos)

            local QS_CAM_SETTLE = 0.10
            local camSettleAt   = tick() + QS_CAM_SETTLE
            while tick() < camSettleAt do RunService.Heartbeat:Wait() end

            local flashFireAt = holdDuration * 0.40
            while true do
                local elapsed = tick() - startTime
                if elapsed >= flashFireAt then break end
                local remain = flashFireAt - elapsed
                if remain > 0.030 then
                    task.wait(remain - 0.020)
                else
                    RunService.Heartbeat:Wait()
                end
            end

            if flashTool and flashTool.Parent then
                pcall(function() flashTool:Activate() end)
            end

            if V3 and V3.potionOn then
                pcall(_activateGiantPotion)
            end

            while true do
                local elapsed = tick() - startTime
                if elapsed >= holdDuration then break end
                local remain = holdDuration - elapsed
                if remain > 0.020 then
                    task.wait(remain - 0.010)
                else
                    RunService.Heartbeat:Wait()
                end
            end
            for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end

            _qsStopCameraLock()

            pcall(ShowToggleNotification, "Quick Steal: " .. tostring(entry.name or "?"), true)

            task.wait(0.4)
            if wasAgNear and agNearReg and agNearReg.setEnabled then pcall(agNearReg.setEnabled, true) end
            if wasAgBest and agBestReg and agBestReg.setEnabled then pcall(agBestReg.setEnabled, true) end
            qsExecuting = false
        end)
    end

    _G._FH_QS_WalkToAnimal     = _qsWalkToAnimal
    _G._FH_QS_BuildCallbacks   = _qsBuildCallbacks
    _G._FH_QS_CBCache          = _qsCBCache
end
_FH_InitQSModule(); task.wait()
local function _FH_InitQSPanel()
    local _qsBuildCallbacks  = _G._FH_QS_BuildCallbacks
    local _qsCBCache         = _G._FH_QS_CBCache

    QS.QSBorderFrame = Instance.new("Frame")
    QS.QSBorderFrame.Name                   = "QuickStealGradBorder"
    QS.QSBorderFrame.Size                   = UDim2.new(0, QS.W + 4, 0, QS.H + 4)
    QS.QSBorderFrame.Position               = UDim2.new(0.5, -(QS.W + 4) / 2, 0, 138)
    QS.QSBorderFrame.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    QS.QSBorderFrame.BackgroundTransparency = 1
    QS.QSBorderFrame.BorderSizePixel        = 0
    QS.QSBorderFrame.ZIndex                 = 18
    QS.QSBorderFrame.Visible                = false
    QS.QSBorderFrame.Parent                 = GUI
    Corner(QS.QSBorderFrame, 12)
    _FH_AddThemeStrokeToFrame(QS.QSBorderFrame, 1.5)

    QS.QSWin = Instance.new("Frame")
    QS.QSWin.Name                   = "QuickStealPanel"
    QS.QSWin.Size                   = UDim2.new(0, QS.W, 0, QS.H)
    QS.QSWin.Position               = UDim2.new(0.5, -QS.W / 2, 0, 140)
    QS.QSWin.BackgroundColor3       = T.BG
    QS.QSWin.BackgroundTransparency = 0.25
    QS.QSWin.BorderSizePixel        = 0
    QS.QSWin.ZIndex                 = 19
    QS.QSWin.Visible                = false
    QS.QSWin.ClipsDescendants       = true
    QS.QSWin.Parent                 = GUI
    Corner(QS.QSWin, 10)

    QS.QSHdr = Instance.new("Frame")
    QS.QSHdr.Size                   = UDim2.new(1, 0, 0, 30)
    QS.QSHdr.BackgroundColor3       = T.Header
    QS.QSHdr.BackgroundTransparency = 0.2
    QS.QSHdr.BorderSizePixel        = 0
    QS.QSHdr.ZIndex                 = 20
    QS.QSHdr.Active                 = true
    QS.QSHdr.Parent                 = QS.QSWin
    Corner(QS.QSHdr, 10)

    QS.QSHdrFill = Instance.new("Frame")
    QS.QSHdrFill.Size                   = UDim2.new(1, 0, 0, 7)
    QS.QSHdrFill.Position               = UDim2.new(0, 0, 1, -7)
    QS.QSHdrFill.BackgroundColor3       = T.Header
    QS.QSHdrFill.BackgroundTransparency = 0.2
    QS.QSHdrFill.BorderSizePixel        = 0
    QS.QSHdrFill.ZIndex                 = 20
    QS.QSHdrFill.Parent                 = QS.QSHdr

    QS.QSHdrLine = Instance.new("Frame")
    QS.QSHdrLine.Size             = UDim2.new(1, 0, 0, 1)
    QS.QSHdrLine.Position         = UDim2.new(0, 0, 1, -1)
    QS.QSHdrLine.BackgroundColor3 = T.Border
    QS.QSHdrLine.BorderSizePixel  = 0
    QS.QSHdrLine.ZIndex           = 21
    QS.QSHdrLine.Parent           = QS.QSHdr

    QS.QSTitle = Label(QS.QSHdr, "Quick Steal", 13, T.White, Enum.Font.GothamBold)
    QS.QSTitle.Size           = UDim2.new(1, -40, 1, 0)
    QS.QSTitle.Position       = UDim2.new(0, 12, 0, 0)
    QS.QSTitle.TextYAlignment = Enum.TextYAlignment.Center
    QS.QSTitle.ZIndex         = 22

    QS.QSMinBtn = Instance.new("TextButton")
    QS.QSMinBtn.Size             = UDim2.new(0, 22, 0, 22)
    QS.QSMinBtn.Position         = UDim2.new(1, -28, 0.5, -11)
    QS.QSMinBtn.BackgroundColor3 = T.Card
    QS.QSMinBtn.BorderSizePixel  = 0
    QS.QSMinBtn.Text             = "\226\136\146"
    QS.QSMinBtn.TextSize         = 14
    QS.QSMinBtn.Font             = Enum.Font.GothamBold
    QS.QSMinBtn.TextColor3       = T.White
    QS.QSMinBtn.ZIndex           = 23
    QS.QSMinBtn.Parent           = QS.QSHdr
    Corner(QS.QSMinBtn, 6)
    Stroke(QS.QSMinBtn, T.Border, 1)

    QS.QSContent = Instance.new("Frame")
    QS.QSContent.Size                   = UDim2.new(1, 0, 1, -30)
    QS.QSContent.Position               = UDim2.new(0, 0, 0, 30)
    QS.QSContent.BackgroundTransparency = 1
    QS.QSContent.ZIndex                 = 19
    QS.QSContent.Parent                 = QS.QSWin
    Padding(QS.QSContent, 8, 8, 8, 8)

    local controlsRow = Instance.new("Frame")
    controlsRow.Size                   = UDim2.new(1, 0, 0, isMobile and 26 or 30)
    controlsRow.BackgroundTransparency = 1
    controlsRow.ZIndex                 = 20
    controlsRow.Parent                 = QS.QSContent

    QS.StealBtn = Instance.new("TextButton")
    QS.StealBtn.Size             = UDim2.new(1, 0, 1, 0)
    QS.StealBtn.Position         = UDim2.new(0, 0, 0, 0)
    QS.StealBtn.BackgroundColor3 = T.Card
    QS.StealBtn.BorderSizePixel  = 0
    QS.StealBtn.Text             = "Steal Selected"
    QS.StealBtn.TextSize         = isMobile and 11 or 12
    QS.StealBtn.Font             = Enum.Font.GothamBold
    QS.StealBtn.TextColor3       = T.White
    QS.StealBtn.AutoButtonColor  = false
    QS.StealBtn.ZIndex           = 21
    QS.StealBtn.Parent           = controlsRow
    Corner(QS.StealBtn, 6)
    local _qsStealStroke = Stroke(QS.StealBtn, Color3.fromRGB(255, 255, 255), 1)
    _FH_AddThemeStroke(_qsStealStroke)

    QS.QSKbLbl = Instance.new("TextLabel")
    QS.QSKbLbl.Size                   = UDim2.new(0, 48, 1, -8)
    QS.QSKbLbl.Position               = UDim2.new(1, -52, 0, 4)
    QS.QSKbLbl.BackgroundTransparency = 1
    QS.QSKbLbl.Text                   = ""
    QS.QSKbLbl.TextSize               = isMobile and 9 or 10
    QS.QSKbLbl.Font                   = Enum.Font.GothamBold
    QS.QSKbLbl.TextColor3             = T.Dim
    QS.QSKbLbl.TextXAlignment         = Enum.TextXAlignment.Right
    QS.QSKbLbl.TextYAlignment         = Enum.TextYAlignment.Center
    QS.QSKbLbl.ZIndex                 = 22
    QS.QSKbLbl.Parent                 = QS.StealBtn

    do
        local saved = Config and Config.keybinds and Config.keybinds["qs_steal_selected"]
        if type(saved) == "string" then
            local ok, kc = pcall(function() return Enum.KeyCode[saved] end)
            if ok and kc then
                QS.entry.keyCode      = kc
                QS.QSKbLbl.Text       = "[" .. saved .. "]"
                QS.QSKbLbl.TextColor3 = T.Dim
            end
        end
    end

    QS.QSStatus = Label(QS.QSContent, "Idle", isMobile and 9 or 10, T.Dim, Enum.Font.GothamMedium)
    QS.QSStatus.Size         = UDim2.new(1, 0, 0, 14)
    QS.QSStatus.Position     = UDim2.new(0, 0, 0, isMobile and 30 or 34)
    QS.QSStatus.TextTruncate = Enum.TextTruncate.AtEnd
    QS.QSStatus.ZIndex       = 20

    local listTop      = isMobile and 48 or 52
    QS.QSScroll = Instance.new("ScrollingFrame")
    QS.QSScroll.Size                   = UDim2.new(1, 0, 1, -(listTop + 6))
    QS.QSScroll.Position               = UDim2.new(0, 0, 0, listTop)
    QS.QSScroll.BackgroundColor3       = Color3.fromRGB(14, 14, 18)
    QS.QSScroll.BackgroundTransparency = 0.2
    QS.QSScroll.BorderSizePixel        = 0
    QS.QSScroll.ScrollBarThickness     = 3
    QS.QSScroll.ScrollBarImageColor3   = T.Border
    QS.QSScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    QS.QSScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    QS.QSScroll.ScrollingDirection     = Enum.ScrollingDirection.Y
    QS.QSScroll.ZIndex                 = 19
    QS.QSScroll.Parent                 = QS.QSContent
    Corner(QS.QSScroll, 6)

    local qsListLayout = Instance.new("UIListLayout")
    qsListLayout.Padding             = UDim.new(0, 4)
    qsListLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    qsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    qsListLayout.Parent              = QS.QSScroll
    Padding(QS.QSScroll, 5, 5, 4, 4)

    local rowEntries = {}

    local function _qsSelectByEntry(entry)
        QS.selectedEntry      = entry
        QS.selectedAnimalName = entry and entry.name or nil
        Config.sliders = Config.sliders or {}
        Config.sliders.qs_selected_animal_name = QS.selectedAnimalName
        pcall(FH_SaveConfig)
        for _, r in ipairs(rowEntries) do r.applyVisual(r.entry == entry) end
        if entry then
            QS.QSStatus.Text       = string.format("Selected: %s · podium #%s", tostring(entry.name), tostring(entry.number))
            QS.QSStatus.TextColor3 = Color3.fromRGB(120, 220, 130)
        else
            QS.QSStatus.Text       = "No selection"
            QS.QSStatus.TextColor3 = T.Dim
        end
    end

    local function _qsGetAnimalModel(data)
        if data and data.name then
            local ok, v = pcall(function()
                local rs       = game:GetService("ReplicatedStorage")
                local models   = rs:FindFirstChild("Models")
                local animals  = models and models:FindFirstChild("Animals")
                return animals and animals:FindFirstChild(data.name) or nil
            end)
            if ok and v then return v end
        end
        if data and data.animalPart and data.animalPart.Parent then
            local m = data.animalPart:FindFirstAncestorOfClass("Model")
            if m then return m end
        end
        return nil
    end

    local function _qsBuildAnimalViewport(vp, data)
        local model = _qsGetAnimalModel(data)
        if not model then return end
        local wm = Instance.new("WorldModel")
        wm.Parent = vp
        local cam = Instance.new("Camera")
        cam.Parent = vp
        vp.CurrentCamera = cam
        task.spawn(function()
            local ok, clone = pcall(function() return model:Clone() end)
            if not ok or not clone then return end
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored   = true
                    d.CanCollide = false
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail")
                    or d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") then
                    pcall(function() d.Enabled = false end)
                end
            end
            clone.Parent = wm
            local cf, size = clone:GetBoundingBox()
            local maxDim = math.max(size.X, size.Y, size.Z)
            if maxDim <= 0 then return end
            local dist = maxDim * 1.25
            cam.FieldOfView = 55
            cam.CFrame = CFrame.new(
                cf.Position + Vector3.new(dist * 0.40, maxDim * 0.25, dist),
                cf.Position
            )

            if not _G._FH_QSViewportSpin then
                _G._FH_QSViewportSpin = { clones = {}, _acc = 0 }
                _G._FH_QSViewportSpin.conn = RunService.Heartbeat:Connect(function(dt)
                    local list = _G._FH_QSViewportSpin.clones
                    if #list == 0 then return end
                    _G._FH_QSViewportSpin._acc = _G._FH_QSViewportSpin._acc + dt
                    if _G._FH_QSViewportSpin._acc < 1/15 then return end
                    local acc = _G._FH_QSViewportSpin._acc
                    _G._FH_QSViewportSpin._acc = 0
                    local n, w = #list, 0
                    local angle = CFrame.Angles(0, acc * 0.9, 0)
                    for r = 1, n do
                        local entry = list[r]
                        local c, v = entry[1], entry[2]
                        if c.Parent and v.Parent then
                            w = w + 1
                            list[w] = entry
                            pcall(function() c:PivotTo(c:GetPivot() * angle) end)
                        end
                    end
                    for i = n, w + 1, -1 do list[i] = nil end
                end)
            end
            table.insert(_G._FH_QSViewportSpin.clones, { clone, vp })
        end)
    end

    local function _qsRenderList(entries)
        for _, child in ipairs(QS.QSScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        rowEntries = {}

        local filtered = {}
        for _, e in ipairs(entries) do
            if (tonumber(e.number) or 0) >= 11 then
                table.insert(filtered, e)
            end
        end

        local rowH      = isMobile and 40 or 46
        local vpSize    = isMobile and 32 or 38
        local textLeft  = vpSize + 8
        local numTagW   = isMobile and 22 or 26

        local newlySelected = nil
        for i, data in ipairs(filtered) do
            local row = Instance.new("Frame")
            row.Size                   = UDim2.new(1, -4, 0, rowH)
            row.BackgroundColor3       = T.Card
            row.BackgroundTransparency = 0.15
            row.BorderSizePixel        = 0
            row.LayoutOrder            = i
            row.ZIndex                 = 20
            row.Parent                 = QS.QSScroll
            Corner(row, 6)
            local rs = Stroke(row, T.Border, 1)

            local vp = Instance.new("ViewportFrame")
            vp.Size                   = UDim2.new(0, vpSize, 0, vpSize)
            vp.Position               = UDim2.new(0, 4, 0.5, -vpSize / 2)
            vp.BackgroundColor3       = Color3.fromRGB(14, 14, 20)
            vp.BackgroundTransparency = 0.1
            vp.BorderSizePixel        = 0
            vp.LightDirection         = Vector3.new(-1, -2, -1)
            vp.LightColor             = Color3.fromRGB(220, 220, 255)
            vp.Ambient                = Color3.fromRGB(180, 180, 180)
            vp.ZIndex                 = 21
            vp.Parent                 = row
            Corner(vp, 5)
            local vs = Stroke(vp, T.Border, 1)
            _FH_AddThemeStroke(vs)
            _qsBuildAnimalViewport(vp, data)

            local numLbl = Instance.new("TextLabel")
            numLbl.Size                   = UDim2.new(0, numTagW, 0, isMobile and 11 or 12)
            numLbl.Position               = UDim2.new(1, -(numTagW + 4), 0, 3)
            numLbl.BackgroundTransparency = 1
            numLbl.Text                   = "#" .. tostring(data.number)
            numLbl.TextSize               = isMobile and 9 or 10
            numLbl.Font                   = Enum.Font.GothamBold
            numLbl.TextColor3             = T.Dim
            numLbl.TextXAlignment         = Enum.TextXAlignment.Right
            numLbl.ZIndex                 = 21
            numLbl.Parent                 = row

            local nameLbl = Label(row, tostring(data.name or ""), isMobile and 10 or 11, T.White, Enum.Font.GothamBold)
            nameLbl.Size         = UDim2.new(1, -(textLeft + numTagW + 6), 0, isMobile and 13 or 14)
            nameLbl.Position     = UDim2.new(0, textLeft, 0, 3)
            nameLbl.ZIndex       = 21
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local parts = {}
            if data.generation then table.insert(parts, data.generation) end
            if data.plotName  then table.insert(parts, "@" .. data.plotName) end
            local infoLbl = Label(row, table.concat(parts, "  ·  "),
                isMobile and 8 or 9, Color3.fromRGB(255, 215, 85), Enum.Font.Gotham)
            infoLbl.Size         = UDim2.new(1, -(textLeft + 4), 0, isMobile and 11 or 12)
            infoLbl.Position     = UDim2.new(0, textLeft, 1, isMobile and -13 or -15)
            infoLbl.ZIndex       = 21
            infoLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local hit = Instance.new("TextButton")
            hit.Size                   = UDim2.new(1, 0, 1, 0)
            hit.BackgroundTransparency = 1
            hit.Text                   = ""
            hit.AutoButtonColor        = false
            hit.ZIndex                 = 25
            hit.Parent                 = row

            local applyVisual = function(selected)
                if selected then
                    local accent = _G._FH_AccentA or T.TrackOn
                    Tween(row, F, { BackgroundColor3 = T.CardHover })
                    rs.Color     = accent
                    rs.Thickness = 2
                else
                    Tween(row, F, { BackgroundColor3 = T.Card })
                    rs.Color     = T.Border
                    rs.Thickness = 1
                end
            end

            hit.MouseEnter:Connect(function()
                if QS.selectedEntry ~= data then
                    Tween(row, F, { BackgroundColor3 = T.CardHover })
                end
            end)
            hit.MouseLeave:Connect(function()
                if QS.selectedEntry ~= data then
                    Tween(row, F, { BackgroundColor3 = T.Card })
                end
            end)

            local _rowTouchStart
            hit.MouseButton1Click:Connect(function() _qsSelectByEntry(data) end)
            hit.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    _rowTouchStart = inp.Position
                end
            end)
            hit.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch and _rowTouchStart then
                    local mag = (inp.Position - _rowTouchStart).Magnitude
                    _rowTouchStart = nil
                    if mag < 20 then _qsSelectByEntry(data) end
                end
            end)

            table.insert(rowEntries, { entry = data, row = row, applyVisual = applyVisual })

            if QS.selectedAnimalName and data.name == QS.selectedAnimalName and not newlySelected then
                newlySelected = data
            end
        end

        if newlySelected then
            _qsSelectByEntry(newlySelected)
        else
            if QS.selectedEntry then
                QS.selectedEntry = nil
                for _, r in ipairs(rowEntries) do r.applyVisual(false) end
            end
            QS.QSStatus.Text       = "0 animals selected"
            QS.QSStatus.TextColor3 = T.Dim
        end
    end

    function QS.refresh()

        if not QS.selectedEntry then
            QS.QSStatus.Text       = "0 animals selected"
            QS.QSStatus.TextColor3 = T.Dim
        end
        task.spawn(function()
            local ok, entries = pcall(QS.scan)
            if not ok or type(entries) ~= "table" then return end
            QS.lastEntries = entries
            _qsRenderList(entries)
        end)
    end

    task.spawn(function()
        while true do
            task.wait(2.5)
            if QS.QSWin and QS.QSWin.Parent and QS.QSWin.Visible and not QS.minimized and not qsExecuting then
                pcall(QS.refresh)
            end
        end
    end)

    do
        local _touchStart
        local _qsKb2Debounce = false
        local function fire()
            Tween(QS.StealBtn, F, { BackgroundColor3 = T.CardHover })
            task.delay(0.12, function() Tween(QS.StealBtn, F, { BackgroundColor3 = T.Card }) end)
            QS.execute()
        end
        QS.StealBtn.MouseButton1Click:Connect(fire)
        QS.StealBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                _touchStart = inp.Position
            elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
                if _qsKb2Debounce then return end
                _qsKb2Debounce = true
                task.delay(0.2, function() _qsKb2Debounce = false end)
                if keybindBindingTarget then
                    local prev = keybindBindingTarget
                    keybindBindingTarget = nil
                    if prev.kbLbl == QS.QSKbLbl then
                        QS.QSKbLbl.Text       = QS.entry.keyCode and ("[" .. QS.entry.keyCode.Name .. "]") or ""
                        QS.QSKbLbl.TextColor3 = T.Dim
                        return
                    else
                        prev.kbLbl.Text       = prev.entry.keyCode and ("[" .. prev.entry.keyCode.Name .. "]") or ""
                        prev.kbLbl.TextColor3 = T.Dim
                    end
                end
                QS.QSKbLbl.Text       = "(...)"
                QS.QSKbLbl.TextColor3 = T.White
                keybindBindingTarget  = { entry = QS.entry, kbLbl = QS.QSKbLbl, mode = "assign" }
            end
        end)
        QS.StealBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch and _touchStart then
                local mag = (inp.Position - _touchStart).Magnitude
                _touchStart = nil
                if mag < 20 then fire() end
            end
        end)
        QS.StealBtn.MouseEnter:Connect(function() Tween(QS.StealBtn, F, { BackgroundColor3 = T.CardHover }) end)
        QS.StealBtn.MouseLeave:Connect(function() Tween(QS.StealBtn, F, { BackgroundColor3 = T.Card }) end)
        table.insert(keybindEntries, { entry = QS.entry, fire = function() QS.execute() end, kbLbl = QS.QSKbLbl })
    end

    configRegistry["qs_steal_selected"] = {
        getState   = function() return false end,
        getKeyCode = function() return QS.entry.keyCode end,
        setKeyCode = function(kc)
            QS.entry.keyCode = kc
            if kc then
                QS.QSKbLbl.Text       = "[" .. kc.Name .. "]"
                QS.QSKbLbl.TextColor3 = T.Dim
                Config.keybinds["qs_steal_selected"] = kc.Name
            else
                QS.QSKbLbl.Text = ""
                Config.keybinds["qs_steal_selected"] = nil
            end
            pcall(FH_SaveConfig)
        end,
        doToggle = function() QS.execute() end,
        kbLbl    = QS.QSKbLbl,
        kbEntry  = QS.entry,
    }

    QS.QSHdr.InputBegan:Connect(function(inp)
        if _G._FH_GUI_LOCKED then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            QS.dragging   = true
            QS.dragStart  = inp.Position
            QS.panelStart = QS.QSWin.Position
        end
    end)
    QS.QSHdr.InputEnded:Connect(function(inp)
