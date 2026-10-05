local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character, RootPart, Humanoid

local isNoclip = false
local isTerminated = false
local steppedConn, renderConn, inputConn, fpsConn, charConn

local currentFps = 60
local lastSafeCFrame = nil
local rayParams = RaycastParams.new()
local success, filterType = pcall(function()
    return Enum.RaycastFilterType.Exclude
end)
rayParams.FilterType = (success and filterType) or Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

if LocalPlayer.PlayerGui:FindFirstChild("BxB_SmartNoclip") then
    LocalPlayer.PlayerGui.BxB_SmartNoclip:Destroy()
end

local function _decode(t, k)
    local b = {}
    for i = 1, #t do b[i] = string.char(bit32.bxor(t[i], k)) end
    return table.concat(b)
end

local _T_RAW = {105, 83, 105, 5, 124, 74, 89, 78, 11, 87, 11, 109, 71, 82}
local _C_RAW = {73, 82, 11, 66, 88, 74, 93, 74, 76, 78, 5, 79, 71, 71}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BxB_SmartNoclip"
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
ToggleBtn.Size = UDim2.new(0.88, 0, 0, 32)
ToggleBtn.Position = UDim2.new(0.06, 0, 0.34, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 11
ToggleBtn.Text = "NOCLIP : OFF [V]"
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0.88, 0, 0, 24)
StatusFrame.Position = UDim2.new(0.06, 0, 0.69, 0)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 5)

local ModeTag = Instance.new("TextLabel")
ModeTag.Text = "MODE: SELECTIVE / ANTI-VOID"
ModeTag.Size = UDim2.new(1, 0, 1, 0)
ModeTag.BackgroundTransparency = 1
ModeTag.TextColor3 = Color3.fromRGB(140, 140, 155)
ModeTag.Font = Enum.Font.GothamMedium
ModeTag.TextSize = 9
ModeTag.Parent = StatusFrame

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

local function syncCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    rayParams.FilterDescendantsInstances = {Character}
    lastSafeCFrame = RootPart.CFrame
end
syncCharacter()
charConn = LocalPlayer.CharacterAdded:Connect(syncCharacter)

local function toggleNoclip(forceState)
    if forceState ~= nil then
        isNoclip = forceState
    else
        isNoclip = not isNoclip
    end

    if isNoclip then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(0, 185, 120),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        ToggleBtn.Text = "NOCLIP : ACTIVE [V]"

        steppedConn = RunService.Stepped:Connect(function()
            if not Character or not RootPart or not isNoclip then return end

            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            local hipHeight = Humanoid.HipHeight > 0 and Humanoid.HipHeight or 2
            local rootOffset = (RootPart.Size.Y / 2) + hipHeight
            local raycastResult = workspace:Raycast(RootPart.Position, Vector3.new(0, -rootOffset - 4, 0), rayParams)

            if raycastResult then
                lastSafeCFrame = RootPart.CFrame
                local floorY = raycastResult.Position.Y
                local expectedY = floorY + rootOffset

                if RootPart.Position.Y < expectedY and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    RootPart.CFrame = CFrame.new(RootPart.Position.X, expectedY, RootPart.Position.Z) * RootPart.CFrame.Rotation
                    local vel = RootPart.AssemblyLinearVelocity
                    if vel.Y < 0 then
                        RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
                    end
                end
            else
                local voidThreshold = workspace.FallenPartsDestroyHeight + 60
                if RootPart.Position.Y <= voidThreshold and lastSafeCFrame then
                    RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
                    RootPart.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(24, 24, 30),
            TextColor3 = Color3.fromRGB(200, 200, 210)
        }):Play()
        ToggleBtn.Text = "NOCLIP : OFF [V]"

        if steppedConn then
            steppedConn:Disconnect()
            steppedConn = nil
        end

        if Character then
            for _, part in ipairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    toggleNoclip()
end)

inputConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.V then
        toggleNoclip()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    isTerminated = true
    toggleNoclip(false)

    if steppedConn then steppedConn:Disconnect() end
    if inputConn then inputConn:Disconnect() end
    if fpsConn then fpsConn:Disconnect() end
    if charConn then charConn:Disconnect() end

    ScreenGui:Destroy()
end)
