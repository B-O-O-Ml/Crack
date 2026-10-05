local BxB = {}
BxB.__index = BxB

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

local function _decode(t, k)
    local b = {}
    for i = 1, #t do b[i] = string.char(bit32.bxor(t[i], k)) end
    return table.concat(b)
end

local _C_RAW = {73, 82, 11, 66, 88, 74, 93, 74, 76, 78, 5, 79, 71, 71}

function BxB.new(config)
    local self = setmetatable({}, BxB)

    self.RawTitle = config.RawTitle
    self.ExpectedSig = config.ExpectedSig or 0
    self.Width = config.Width or 225
    self.ExpandedHeight = config.Height or 132
    self.CollapsedHeight = 36

    self.IsTerminated = false
    self.IsCollapsed = false
    self.CurrentFps = 60
    self.Connections = {}

    self:BuildCore()
    self:StartTelemetry()

    return self
end

function BxB:BuildCore()
    if LocalPlayer.PlayerGui:FindFirstChild("BxB_Framework") then
        LocalPlayer.PlayerGui.BxB_Framework:Destroy()
    end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "BxB_Framework"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, self.Width, 0, self.ExpandedHeight)
    self.MainFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Active = true
    self.MainFrame.Parent = self.ScreenGui

    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", self.MainFrame)
    MainStroke.Color = Color3.fromRGB(45, 45, 55)
    MainStroke.Thickness = 1.2

    self.TopBar = Instance.new("Frame")
    self.TopBar.Name = "TopBar"
    self.TopBar.Size = UDim2.new(1, 0, 0, self.CollapsedHeight)
    self.TopBar.BackgroundTransparency = 1
    self.TopBar.Parent = self.MainFrame

    self.Title = Instance.new("TextLabel")
    self.Title.Name = "V_Header"
    self.Title.Text = self.RawTitle and _decode(self.RawTitle, 43) or "BxB.Ware"
    self.Title.Size = UDim2.new(0.36, 0, 0.52, 0)
    self.Title.Position = UDim2.new(0.05, 0, 0.14, 0)
    self.Title.BackgroundTransparency = 1
    self.Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    self.Title.Font = Enum.Font.GothamBold
    self.Title.TextSize = 11
    self.Title.TextXAlignment = Enum.TextXAlignment.Left
    self.Title.Parent = self.TopBar

    self.Credit = Instance.new("TextLabel")
    self.Credit.Name = "V_Sub"
    self.Credit.Text = _decode(_C_RAW, 43)
    self.Credit.Size = UDim2.new(0.36, 0, 0.35, 0)
    self.Credit.Position = UDim2.new(0.05, 0, 0.65, 0)
    self.Credit.BackgroundTransparency = 1
    self.Credit.TextColor3 = Color3.fromRGB(240, 240, 240)
    self.Credit.Font = Enum.Font.GothamBold
    self.Credit.TextSize = 10.5
    self.Credit.TextXAlignment = Enum.TextXAlignment.Left
    self.Credit.Parent = self.TopBar

    self.StatLabel = Instance.new("TextLabel")
    self.StatLabel.Text = "0 FPS | 0 MS"
    self.StatLabel.Size = UDim2.new(0.28, 0, 1, 0)
    self.StatLabel.Position = UDim2.new(0.44, 0, 0, 0)
    self.StatLabel.BackgroundTransparency = 1
    self.StatLabel.TextColor3 = Color3.fromRGB(0, 220, 150)
    self.StatLabel.Font = Enum.Font.GothamBold
    self.StatLabel.TextSize = 9.5
    self.StatLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.StatLabel.Parent = self.TopBar

    self.MinBtn = Instance.new("TextButton")
    self.MinBtn.Text = "−"
    self.MinBtn.Size = UDim2.new(0, 26, 0, 26)
    self.MinBtn.Position = UDim2.new(1, -61, 0, 5)
    self.MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    self.MinBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
    self.MinBtn.Font = Enum.Font.GothamBold
    self.MinBtn.TextSize = 14
    self.MinBtn.BorderSizePixel = 0
    self.MinBtn.Parent = self.TopBar
    Instance.new("UICorner", self.MinBtn).CornerRadius = UDim.new(0, 5)

    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Text = "×"
    self.CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    self.CloseBtn.Position = UDim2.new(1, -31, 0, 5)
    self.CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    self.CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
    self.CloseBtn.Font = Enum.Font.GothamBold
    self.CloseBtn.TextSize = 14
    self.CloseBtn.BorderSizePixel = 0
    self.CloseBtn.Parent = self.TopBar
    Instance.new("UICorner", self.CloseBtn).CornerRadius = UDim.new(0, 5)

    self.BodyContainer = Instance.new("Frame")
    self.BodyContainer.Name = "BodyContainer"
    self.BodyContainer.Size = UDim2.new(1, 0, 0, self.ExpandedHeight - self.CollapsedHeight)
    self.BodyContainer.Position = UDim2.new(0, 0, 0, self.CollapsedHeight)
    self.BodyContainer.BackgroundTransparency = 1
    self.BodyContainer.Parent = self.MainFrame

    self:BindCoreEvents()
end

function BxB:BindCoreEvents()
    local function hookBtn(btn, hoverBg, pressText)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = hoverBg, TextColor3 = pressText}):Play()
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(180, 180, 195)}):Play()
            end
        end)
    end
    hookBtn(self.MinBtn, Color3.fromRGB(42, 42, 52), Color3.fromRGB(255, 255, 255))
    hookBtn(self.CloseBtn, Color3.fromRGB(160, 40, 40), Color3.fromRGB(255, 255, 255))

    self.MinBtn.MouseButton1Click:Connect(function()
        self.IsCollapsed = not self.IsCollapsed
        local targetH = self.IsCollapsed and self.CollapsedHeight or self.ExpandedHeight
        self.MinBtn.Text = self.IsCollapsed and "+" or "−"
        TweenService:Create(self.MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, self.Width, 0, targetH)
        }):Play()
    end)

    local dragging, dragStart, startPos
    self.MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function BxB:StartTelemetry()
    local fpsConn = RunService.RenderStepped:Connect(function(dt)
        self.CurrentFps = math.floor(1 / dt)
    end)
    table.insert(self.Connections, fpsConn)

    task.spawn(function()
        while not self.IsTerminated do
            local s1, p1 = pcall(function() return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local ping = (s1 and p1) or pcall(function() return math.floor(LocalPlayer:GetNetworkPing() * 1000) end) or 0
            self.StatLabel.Text = string.format("%d FPS | %d MS", self.CurrentFps, ping)
            task.wait(0.4)
        end
    end)
end

function BxB:GetSecurityMultiplier()
    local sA = self.Title.Text or ""
    local sB = self.Credit.Text or ""
    local hA, hB = 5381, 5381
    for i = 1, #sA do hA = bit32.band(hA + bit32.lshift(hA, 5) + string.byte(sA, i), 0xFFFFFFFF) end
    for i = 1, #sB do hB = bit32.band(hB + bit32.lshift(hB, 5) + string.byte(sB, i), 0xFFFFFFFF) end
    local sig = bit32.bxor(hA, hB)
    local delta = math.abs(sig - self.ExpectedSig)
    return 1 - math.min(1, delta)
end

function BxB:CreateToggle(opts)
    local btn = Instance.new("TextButton")
    btn.Size = opts.Size or UDim2.new(1, 0, 0, 39)
    btn.Position = opts.Position or UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11.5
    btn.BorderSizePixel = 0
    btn.Parent = opts.Parent or self.BodyContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local keyLabel = ""
    if typeof(opts.Key) == "EnumItem" then
        keyLabel = " [" .. opts.Key.Name .. "]"
    elseif type(opts.Key) == "string" and opts.Key ~= "" then
        keyLabel = " [" .. opts.Key .. "]"
    end

    local textPrefix = opts.Text or "TOGGLE"
    btn.Text = textPrefix .. " : OFF" .. keyLabel

    local state = false
    local function updateVisual()
        if state then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 185, 120),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            btn.Text = textPrefix .. " : ACTIVE" .. keyLabel
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(24, 24, 30),
                TextColor3 = Color3.fromRGB(200, 200, 210)
            }):Play()
            btn.Text = textPrefix .. " : OFF" .. keyLabel
        end
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if opts.Callback then opts.Callback(state) end
    end)

    if typeof(opts.Key) == "EnumItem" then
        local keyConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == opts.Key then
                state = not state
                updateVisual()
                if opts.Callback then opts.Callback(state) end
            end
        end)
        table.insert(self.Connections, keyConn)
    end

    return {
        Instance = btn,
        SetState = function(_, newState)
            state = newState
            updateVisual()
            if opts.Callback then opts.Callback(state) end
        end,
        GetState = function() return state end
    }
end

function BxB:CreateSpeedStepper(opts)
    local container = Instance.new("Frame")
    container.Size = opts.Size or UDim2.new(1, 0, 0, 39)
    container.Position = opts.Position or UDim2.new(0, 0, 0, 0)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.BorderSizePixel = 0
    container.Parent = opts.Parent or self.BodyContainer
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local current = opts.Default or 1
    local min = opts.Min or 1
    local max = opts.Max or 20
    local step = opts.Step or 50

    local minus = Instance.new("TextButton")
    minus.Text = "-"
    minus.Size = UDim2.new(0, 34, 1, 0)
    minus.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    minus.TextColor3 = Color3.fromRGB(200, 200, 210)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 14
    minus.BorderSizePixel = 0
    minus.Parent = container
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 5)

    local display = Instance.new("TextLabel")
    display.Text = "LV: " .. current .. " (" .. (current * step) .. ")"
    display.Size = UDim2.new(1, -68, 1, 0)
    display.Position = UDim2.new(0, 34, 0, 0)
    display.BackgroundTransparency = 1
    display.TextColor3 = Color3.fromRGB(160, 160, 175)
    display.Font = Enum.Font.GothamMedium
    display.TextSize = 10.5
    display.Parent = container

    local plus = Instance.new("TextButton")
    plus.Text = "+"
    plus.Size = UDim2.new(0, 34, 1, 0)
    plus.Position = UDim2.new(1, -34, 0, 0)
    plus.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    plus.TextColor3 = Color3.fromRGB(200, 200, 210)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 14
    plus.BorderSizePixel = 0
    plus.Parent = container
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 5)

    local function update()
        display.Text = "LV: " .. current .. " (" .. (current * step) .. ")"
        if opts.Callback then opts.Callback(current, current * step) end
    end

    minus.MouseButton1Click:Connect(function()
        current = math.clamp(current - 1, min, max)
        update()
    end)

    plus.MouseButton1Click:Connect(function()
        current = math.clamp(current + 1, min, max)
        update()
    end)

    return {
        GetValue = function() return current, current * step end
    }
end

function BxB:CreateAltitudePaddles(opts)
    local container = Instance.new("Frame")
    container.Size = opts.Size or UDim2.new(0, 52, 0, 84)
    container.Position = opts.Position or UDim2.new(0, 10, 0, 6)
    container.BackgroundTransparency = 1
    container.Parent = opts.Parent or self.BodyContainer

    local up = Instance.new("TextButton")
    up.Text = "Up"
    up.Size = UDim2.new(1, 0, 0, 39)
    up.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    up.TextColor3 = Color3.fromRGB(220, 220, 235)
    up.Font = Enum.Font.GothamBold
    up.TextSize = 13
    up.BorderSizePixel = 0
    up.Parent = container
    Instance.new("UICorner", up).CornerRadius = UDim.new(0, 6)
    local upStroke = Instance.new("UIStroke", up)
    upStroke.Color = Color3.fromRGB(50, 50, 65)

    local down = Instance.new("TextButton")
    down.Text = "Down"
    down.Size = UDim2.new(1, 0, 0, 39)
    down.Position = UDim2.new(0, 0, 0, 45)
    down.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    down.TextColor3 = Color3.fromRGB(220, 220, 235)
    down.Font = Enum.Font.GothamBold
    down.TextSize = 13
    down.BorderSizePixel = 0
    down.Parent = container
    Instance.new("UICorner", down).CornerRadius = UDim.new(0, 6)
    local downStroke = Instance.new("UIStroke", down)
    downStroke.Color = Color3.fromRGB(50, 50, 65)

    local function bindTouch(btn, stroke, cb)
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                cb(true)
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 185, 120), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                stroke.Color = Color3.fromRGB(0, 220, 150)
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                cb(false)
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 34), TextColor3 = Color3.fromRGB(220, 220, 235)}):Play()
                stroke.Color = Color3.fromRGB(50, 50, 65)
            end
        end)
    end

    bindTouch(up, upStroke, opts.OnUp or function() end)
    bindTouch(down, downStroke, opts.OnDown or function() end)
end

function BxB:CreateBadge(opts)
    local frame = Instance.new("Frame")
    frame.Size = opts.Size or UDim2.new(0.88, 0, 0, 24)
    frame.Position = opts.Position or UDim2.new(0.06, 0, 0.58, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    frame.BorderSizePixel = 0
    frame.Parent = opts.Parent or self.BodyContainer
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel")
    label.Text = opts.Text or ""
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(140, 140, 155)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 9
    label.Parent = frame

    return {
        SetText = function(_, t) label.Text = t end
    }
end

function BxB:Destroy()
    self.IsTerminated = true
    if self.OnCloseCallback then self.OnCloseCallback() end
    for _, conn in ipairs(self.Connections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    self.ScreenGui:Destroy()
end

return BxB
