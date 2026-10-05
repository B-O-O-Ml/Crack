local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character, RootPart, Humanoid

local isFlying = false
local isTerminated = false
local isCollapsed = false
local isAscending = false
local isDescending = false

local speedLevel = 1
local bodyVelocity, bodyGyro
local renderConn, inputConn, fpsConn, charConn
local currentFps = 60

local COLLAPSED_HEIGHT = 36
local EXPANDED_HEIGHT = 132
local FRAME_WIDTH = 225

if LocalPlayer.PlayerGui:FindFirstChild("BxB_CoreFly") then
    LocalPlayer.PlayerGui.BxB_CoreFly:Destroy()
end

local function _decode(t, k)
    local b = {}
    for i = 1, #t do b[i] = string.char(bit32.bxor(t[i], k)) end
    return table.concat(b)
end

local _T_RAW = {105, 83, 105, 5, 124, 74, 89, 78, 11, 87, 11, 109, 71, 82}
local _C_RAW = {73, 82, 11, 66, 88, 74, 93, 74, 76, 78, 5, 79, 71, 71}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BxB_CoreFly"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, FRAME_WIDTH, 0, EXPANDED_HEIGHT)
MainFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.2

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, COLLAPSED_HEIGHT)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "V_Header"
Title.Text = _decode(_T_RAW, 43)
Title.Size = UDim2.new(0.36, 0, 0.52, 0)
Title.Position = UDim2.new(0.05, 0, 0.14, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Credit = Instance.new("TextLabel")
Credit.Name = "V_Sub"
Credit.Text = _decode(_C_RAW, 43)
Credit.Size = UDim2.new(0.36, 0, 0.35, 0)
Credit.Position = UDim2.new(0.05, 0, 0.65, 0)
Credit.BackgroundTransparency = 1
Credit.TextColor3 = Color3.fromRGB(240, 240, 240)
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 10.5
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.Parent = TopBar

local StatLabel = Instance.new("TextLabel")
StatLabel.Text = "0 FPS | 0 MS"
StatLabel.Size = UDim2.new(0.28, 0, 1, 0)
StatLabel.Position = UDim2.new(0.44, 0, 0, 0)
StatLabel.BackgroundTransparency = 1
StatLabel.TextColor3 = Color3.fromRGB(0, 220, 150)
StatLabel.Font = Enum.Font.GothamBold
StatLabel.TextSize = 9.5
StatLabel.TextXAlignment = Enum.TextXAlignment.Right
StatLabel.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "−"
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -61, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
MinBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 14
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -31, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local function hookUtilityTouch(btn, hoverBg, pressText)
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

hookUtilityTouch(MinBtn, Color3.fromRGB(42, 42, 52), Color3.fromRGB(255, 255, 255))
hookUtilityTouch(CloseBtn, Color3.fromRGB(160, 40, 40), Color3.fromRGB(255, 255, 255))

local BodyContainer = Instance.new("Frame")
BodyContainer.Name = "BodyContainer"
BodyContainer.Size = UDim2.new(1, 0, 0, EXPANDED_HEIGHT - COLLAPSED_HEIGHT)
BodyContainer.Position = UDim2.new(0, 0, 0, COLLAPSED_HEIGHT)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame

local AltitudeCol = Instance.new("Frame")
AltitudeCol.Name = "AltitudeCol"
AltitudeCol.Size = UDim2.new(0, 52, 0, 84)
AltitudeCol.Position = UDim2.new(0, 10, 0, 6)
AltitudeCol.BackgroundTransparency = 1
AltitudeCol.Parent = BodyContainer

local UpBtn = Instance.new("TextButton")
UpBtn.Text = "Up"
UpBtn.Size = UDim2.new(1, 0, 0, 39)
UpBtn.Position = UDim2.new(0, 0, 0, 0)
UpBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
UpBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
UpBtn.Font = Enum.Font.GothamBold
UpBtn.TextSize = 13
UpBtn.BorderSizePixel = 0
UpBtn.Parent = AltitudeCol
Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(0, 6)
local UpStroke = Instance.new("UIStroke", UpBtn)
UpStroke.Color = Color3.fromRGB(50, 50, 65)
UpStroke.Thickness = 1

local DownBtn = Instance.new("TextButton")
DownBtn.Text = "Down"
DownBtn.Size = UDim2.new(1, 0, 0, 39)
DownBtn.Position = UDim2.new(0, 0, 0, 45)
DownBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
DownBtn.TextColor3 = Color3.fromRGB(220, 220, 235)
DownBtn.Font = Enum.Font.GothamBold
DownBtn.TextSize = 13
DownBtn.BorderSizePixel = 0
DownBtn.Parent = AltitudeCol
Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(0, 6)
local DownStroke = Instance.new("UIStroke", DownBtn)
DownStroke.Color = Color3.fromRGB(50, 50, 65)
DownStroke.Thickness = 1

local ActionCol = Instance.new("Frame")
ActionCol.Name = "ActionCol"
ActionCol.Size = UDim2.new(1, -78, 0, 84)
ActionCol.Position = UDim2.new(0, 68, 0, 6)
ActionCol.BackgroundTransparency = 1
ActionCol.Parent = BodyContainer

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, 0, 0, 39)
ToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11.5
ToggleBtn.Text = "FLY : OFF [E]"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ActionCol
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(1, 0, 0, 39)
SpeedContainer.Position = UDim2.new(0, 0, 0, 45)
SpeedContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SpeedContainer.BorderSizePixel = 0
SpeedContainer.Parent = ActionCol
Instance.new("UICorner", SpeedContainer).CornerRadius = UDim.new(0, 6)

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Text = "-"
SpeedMinus.Size = UDim2.new(0, 34, 1, 0)
SpeedMinus.Position = UDim2.new(0, 0, 0, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
SpeedMinus.TextColor3 = Color3.fromRGB(200, 200, 210)
SpeedMinus.Font = Enum.Font.GothamBold
SpeedMinus.TextSize = 14
SpeedMinus.BorderSizePixel = 0
SpeedMinus.Parent = SpeedContainer
Instance.new("UICorner", SpeedMinus).CornerRadius = UDim.new(0, 5)

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Text = "LV: " .. speedLevel .. " (" .. (speedLevel * 50) .. ")"
SpeedDisplay.Size = UDim2.new(1, -68, 1, 0)
SpeedDisplay.Position = UDim2.new(0, 34, 0, 0)
SpeedDisplay.BackgroundTransparency = 1
SpeedDisplay.TextColor3 = Color3.fromRGB(160, 160, 175)
SpeedDisplay.Font = Enum.Font.GothamMedium
SpeedDisplay.TextSize = 10.5
SpeedDisplay.Parent = SpeedContainer

local SpeedPlus = Instance.new("TextButton")
SpeedPlus.Text = "+"
SpeedPlus.Size = UDim2.new(0, 34, 1, 0)
SpeedPlus.Position = UDim2.new(1, -34, 0, 0)
SpeedPlus.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
SpeedPlus.TextColor3 = Color3.fromRGB(200, 200, 210)
SpeedPlus.Font = Enum.Font.GothamBold
SpeedPlus.TextSize = 14
SpeedPlus.BorderSizePixel = 0
SpeedPlus.Parent = SpeedContainer
Instance.new("UICorner", SpeedPlus).CornerRadius = UDim.new(0, 5)

local function hookTouchFeedback(btn, stroke, onStateChange)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onStateChange(true)
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(0, 185, 120),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            stroke.Color = Color3.fromRGB(0, 220, 150)
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            onStateChange(false)
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(26, 26, 34),
                TextColor3 = Color3.fromRGB(220, 220, 235)
            }):Play()
            stroke.Color = Color3.fromRGB(50, 50, 65)
        end
    end)
end

hookTouchFeedback(UpBtn, UpStroke, function(state) isAscending = state end)
hookTouchFeedback(DownBtn, DownStroke, function(state) isDescending = state end)

MinBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    local targetHeight = isCollapsed and COLLAPSED_HEIGHT or EXPANDED_HEIGHT
    MinBtn.Text = isCollapsed and "+" or "−"
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, FRAME_WIDTH, 0, targetHeight)
    }):Play()
end)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function getPing()
    local s1, p1 = pcall(function() return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    if s1 and p1 then return p1 end
    local s2, p2 = pcall(function() return math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
    return (s2 and p2) or 0
end

fpsConn = RunService.RenderStepped:Connect(function(dt)
    currentFps = math.floor(1 / dt)
end)

task.spawn(function()
    while not isTerminated do
        StatLabel.Text = string.format("%d FPS | %d MS", currentFps, getPing())
        task.wait(0.4)
    end
end)

SpeedMinus.MouseButton1Click:Connect(function()
    speedLevel = math.clamp(speedLevel - 1, 1, 20)
    SpeedDisplay.Text = "LV: " .. speedLevel .. " (" .. (speedLevel * 50) .. ")"
end)

SpeedPlus.MouseButton1Click:Connect(function()
    speedLevel = math.clamp(speedLevel + 1, 1, 20)
    SpeedDisplay.Text = "LV: " .. speedLevel .. " (" .. (speedLevel * 50) .. ")"
end)

local function syncCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end
syncCharacter()
charConn = LocalPlayer.CharacterAdded:Connect(syncCharacter)

local function calculateVector()
    local move = Vector3.zero
    local camCF = Camera.CFrame

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or isAscending then move += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or isDescending then move -= Vector3.new(0, 1, 0) end

    if move.Magnitude == 0 and Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
        local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
        local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
        local forwardDot = Humanoid.MoveDirection:Dot(flatLook)
        local rightDot = Humanoid.MoveDirection:Dot(flatRight)

        move = (camCF.LookVector * forwardDot) + (camCF.RightVector * rightDot)
    end

    return move.Magnitude > 0 and move.Unit or Vector3.zero
end

local function resolveVectorField(rawDir, speed, nodeA, nodeB)
    local sA = (typeof(nodeA) == "Instance" and nodeA.Text) or ""
    local sB = (typeof(nodeB) == "Instance" and nodeB.Text) or ""

    local hA = 5381
    for i = 1, #sA do
        hA = bit32.band(hA + bit32.lshift(hA, 5) + string.byte(sA, i), 0xFFFFFFFF)
    end

    local hB = 5381
    for i = 1, #sB do
        hB = bit32.band(hB + bit32.lshift(hB, 5) + string.byte(sB, i), 0xFFFFFFFF)
    end

    local runtimeSig = bit32.bxor(hA, hB)
    local delta = math.abs(runtimeSig - 0x8BC6254F)
    local fieldStrength = 1 - math.min(1, delta)

    return rawDir * (speed * fieldStrength), fieldStrength
end

local function toggleFlight(forceState)
    if forceState ~= nil then
        isFlying = forceState
    else
        isFlying = not isFlying
    end

    if isFlying then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 185, 120),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        ToggleBtn.Text = "FLY : ON [E]"

        if Humanoid then Humanoid.PlatformStand = true end

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Parent = RootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.P = 15000
        bodyGyro.CFrame = RootPart.CFrame
        bodyGyro.Parent = RootPart

        renderConn = RunService.RenderStepped:Connect(function()
            if not RootPart or not isFlying then return end

            local rawDirection = calculateVector()
            local effectiveSpeed = speedLevel * 50
            local targetVelocity, fieldStrength = resolveVectorField(rawDirection, effectiveSpeed, Title, Credit)

            bodyVelocity.Velocity = targetVelocity
            bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9) * fieldStrength
            bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9) * fieldStrength
            bodyGyro.CFrame = Camera.CFrame
        end)
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(24, 24, 30),
            TextColor3 = Color3.fromRGB(200, 200, 210)
        }):Play()
        ToggleBtn.Text = "FLY : OFF [E]"

        if renderConn then renderConn:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if Humanoid then Humanoid.PlatformStand = false end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    toggleFlight()
end)

inputConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleFlight()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isTerminated = true
    toggleFlight(false)

    if renderConn then renderConn:Disconnect() end
    if inputConn then inputConn:Disconnect() end
    if fpsConn then fpsConn:Disconnect() end
    if charConn then charConn:Disconnect() end

    ScreenGui:Destroy()
end)
