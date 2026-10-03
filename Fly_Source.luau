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
local flySpeed = 60
local maxSpeed = 350
local minSpeed = 10
local bodyVelocity, bodyGyro
local renderConn, inputConn, fpsConn, charConn

local currentFps = 60

if LocalPlayer.PlayerGui:FindFirstChild("BxB_CoreFly") then
    LocalPlayer.PlayerGui.BxB_CoreFly:Destroy()
end

local function _decode(cipherTable, key)
    local buffer = {}
    for i = 1, #cipherTable do
        buffer[i] = string.char(bit32.bxor(cipherTable[i], key))
    end
    return table.concat(buffer)
end

local _T_RAW = {105, 83, 105, 5, 124, 74, 89, 78, 11, 87, 11, 109, 71, 82}
local _C_RAW = {73, 82, 11, 66, 88, 74, 93, 74, 76, 78, 5, 79, 71, 71}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BxB_CoreFly"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 210, 0, 118)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.2

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "V_Header"
Title.Text = _decode(_T_RAW, 43)
Title.Size = UDim2.new(0.42, 0, 0.55, 0)
Title.Position = UDim2.new(0.06, 0, 0.15, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Credit = Instance.new("TextLabel")
Credit.Name = "V_Sub"
Credit.Text = _decode(_C_RAW, 43)
Credit.Size = UDim2.new(0.42, 0, 0.35, 0)
Credit.Position = UDim2.new(0.06, 0, 0.65, 0)
Credit.BackgroundTransparency = 1
Credit.TextColor3 = Color3.fromRGB(200, 200, 210)
Credit.Font = Enum.Font.Gotham
Credit.TextSize = 10
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.Parent = TopBar

local StatLabel = Instance.new("TextLabel")
StatLabel.Text = "0 FPS | 0 MS"
StatLabel.Size = UDim2.new(0.36, 0, 1, 0)
StatLabel.Position = UDim2.new(0.44, 0, 0, 0)
StatLabel.BackgroundTransparency = 1
StatLabel.TextColor3 = Color3.fromRGB(0, 220, 150)
StatLabel.Font = Enum.Font.Code
StatLabel.TextSize = 9
StatLabel.TextXAlignment = Enum.TextXAlignment.Right
StatLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "×"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 175)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 30)
ToggleBtn.Position = UDim2.new(0.06, 0, 0.34, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.Text = "FLY : OFF [E]"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(0.88, 0, 0, 26)
SpeedContainer.Position = UDim2.new(0.06, 0, 0.67, 0)
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.Parent = MainFrame

local SpeedMinus = Instance.new("TextButton")
SpeedMinus.Text = "-"
SpeedMinus.Size = UDim2.new(0.2, 0, 1, 0)
SpeedMinus.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
SpeedMinus.TextColor3 = Color3.fromRGB(200, 200, 210)
SpeedMinus.Font = Enum.Font.GothamBold
SpeedMinus.TextSize = 13
SpeedMinus.BorderSizePixel = 0
SpeedMinus.Parent = SpeedContainer
Instance.new("UICorner", SpeedMinus).CornerRadius = UDim.new(0, 5)

local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Text = "SPEED: " .. flySpeed
SpeedDisplay.Size = UDim2.new(0.56, 0, 1, 0)
SpeedDisplay.Position = UDim2.new(0.22, 0, 0, 0)
SpeedDisplay.BackgroundTransparency = 1
SpeedDisplay.TextColor3 = Color3.fromRGB(150, 150, 165)
SpeedDisplay.Font = Enum.Font.GothamMedium
SpeedDisplay.TextSize = 10
SpeedDisplay.Parent = SpeedContainer

local SpeedPlus = Instance.new("TextButton")
SpeedPlus.Text = "+"
SpeedPlus.Size = UDim2.new(0.2, 0, 1, 0)
SpeedPlus.Position = UDim2.new(0.8, 0, 0, 0)
SpeedPlus.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
SpeedPlus.TextColor3 = Color3.fromRGB(200, 200, 210)
SpeedPlus.Font = Enum.Font.GothamBold
SpeedPlus.TextSize = 13
SpeedPlus.BorderSizePixel = 0
SpeedPlus.Parent = SpeedContainer
Instance.new("UICorner", SpeedPlus).CornerRadius = UDim.new(0, 5)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
    local s1, p1 = pcall(function()
        return math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    if s1 and p1 then return p1 end
    local s2, p2 = pcall(function()
        return math.floor(LocalPlayer:GetNetworkPing() * 1000)
    end)
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
    flySpeed = math.clamp(flySpeed - 10, minSpeed, maxSpeed)
    SpeedDisplay.Text = "SPEED: " .. flySpeed
end)

SpeedPlus.MouseButton1Click:Connect(function()
    flySpeed = math.clamp(flySpeed + 10, minSpeed, maxSpeed)
    SpeedDisplay.Text = "SPEED: " .. flySpeed
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
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end

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
        ToggleBtn.Text = "Fly : ON [E]"

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
            local targetVelocity, fieldStrength = resolveVectorField(rawDirection, flySpeed, Title, Credit)

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
