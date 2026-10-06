if getgenv().BxB_Process then
    pcall(function() getgenv().BxB_Process:Teardown() end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


local flagFly = getgenv().FLY == true
local flagNoclip = getgenv().NOCLIP == true
local flagShiftlock = getgenv().SHIFTLOCK == true

if not flagFly and not flagNoclip and not flagShiftlock then
    local noticeGui = Instance.new("ScreenGui")
    noticeGui.Name = "BxB_Notice"
    noticeGui.ResetOnSpawn = false
    noticeGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 290, 0, 75)
    card.Position = UDim2.new(0.5, -145, 0.1, 0)
    card.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    card.BorderSizePixel = 0
    card.Parent = noticeGui
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(220, 80, 80)
    stroke.Thickness = 1.2

    local title = Instance.new("TextLabel")
    title.Text = "BxB.Ware // CONFIG REQUIRED"
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 90, 90)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 11
    title.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Please set getgenv().FLY, NOCLIP or SHIFTLOCK\nto true before running."
    desc.Size = UDim2.new(1, 0, 0, 40)
    desc.Position = UDim2.new(0, 0, 0, 28)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Color3.fromRGB(180, 180, 190)
    desc.Font = Enum.Font.GothamMedium
    desc.TextSize = 10
    desc.Parent = card

    task.delay(4, function()
        TweenService:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        noticeGui:Destroy()
    end)
    return
end

local Process = {
    Connections = {},
    BodyMovers = {},
    Instances = {},
    IsTerminated = false
}
getgenv().BxB_Process = Process

local globalEnv = (getgenv and getgenv()) or _G
globalEnv.BxB_Export = nil

local rawUrl = "https://raw.githubusercontent.com/B-O-O-Ml/Crack/main/BxB.Ware/Library/ui_library.luau?t=" .. tostring(os.time())
local fetchSuccess, rawSource = pcall(game.HttpGet, game, rawUrl, true)

if not fetchSuccess or type(rawSource) ~= "string" or #rawSource < 30 or rawSource:find("404: Not Found") then
    warn("[BxB Error] Network Exception: Unable to fetch ui_library from GitHub.")
    return
end

local compileSuccess, chunk = pcall(loadstring, rawSource)
if not compileSuccess or type(chunk) ~= "function" then
    warn("[BxB Error] Syntax Exception: Failed to compile library bytecode.")
    return
end

task.spawn(chunk)

local startTime = os.clock()
while not globalEnv.BxB_Export and (os.clock() - startTime) < 3.5 do
    task.wait(0.05)
end

local BxB = globalEnv.BxB_Export
if type(BxB) ~= "table" or type(BxB.new) ~= "function" then
    warn("[BxB Fatal] Memory Link Failure: BxB library table not found. Verify getgenv().BxB_Export in source.")
    return
end
globalEnv.BxB_Export = nil

local FRAME_WIDTH = flagFly and 260 or 225

local UI = BxB.new({
    RawTitle = {105, 83, 105, 5, 124, 74, 89, 78, 11, 87, 11, 99, 94, 73},
    ExpectedSig = 0x8BC63ED3,
    Width = FRAME_WIDTH
})

local Character, RootPart, Humanoid
local lastSafeCFrame = nil
local isShiftlock = false

local rayParams = RaycastParams.new()
local success, filterType = pcall(function() return Enum.RaycastFilterType.Exclude end)
rayParams.FilterType = (success and filterType) or Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

local function syncCharacter(newChar)
    Character = newChar or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    rayParams.FilterDescendantsInstances = {Character}
    lastSafeCFrame = RootPart.CFrame

    if isShiftlock then
        Humanoid.AutoRotate = false
        Humanoid.CameraOffset = Vector3.new(1.75, 0, 0)
    end
end
syncCharacter(LocalPlayer.Character)
table.insert(Process.Connections, LocalPlayer.CharacterAdded:Connect(syncCharacter))

local isFlying = false
local isNoclip = false
local isAscending = false
local isDescending = false
local speedLevel = 1

local flyVelocity, flyGyro
local flyRenderConn, noclipSteppedConn, shiftlockConn

local KeyFly = Enum.KeyCode.E
local KeyNoclip = Enum.KeyCode.V
local KeyShiftlock = Enum.KeyCode.Z

local FlyToggleObj, NoclipToggleObj, ShiftlockToggleObj
local updateShiftWidget = function() end

local SHIFTLOCK_ZOOM = 400
local SHIFTLOCK_OFFSET = Vector3.new(1.75, 0, 0)
local savedMaxZoom

local function calculateFlyVector()
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
        move = (camCF.LookVector * Humanoid.MoveDirection:Dot(flatLook)) + (camCF.RightVector * Humanoid.MoveDirection:Dot(flatRight))
    end
    return move.Magnitude > 0 and move.Unit or Vector3.zero
end

local function toggleFlight(state)
    isFlying = state
    if isFlying then
        if Humanoid then Humanoid.PlatformStand = true end

        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.zero
        flyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyVelocity.Parent = RootPart
        table.insert(Process.BodyMovers, flyVelocity)

        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyGyro.P = 15000
        flyGyro.CFrame = RootPart.CFrame
        flyGyro.Parent = RootPart
        table.insert(Process.BodyMovers, flyGyro)

        flyRenderConn = RunService.RenderStepped:Connect(function()
            if not RootPart or not isFlying then return end
            local mult = UI:GetSecurityMultiplier()
            flyVelocity.Velocity = calculateFlyVector() * (speedLevel * 50 * mult)
            flyGyro.CFrame = Camera.CFrame
        end)
    else
        if flyRenderConn then flyRenderConn:Disconnect(); flyRenderConn = nil end
        if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
        if flyGyro then flyGyro:Destroy(); flyGyro = nil end
        if RootPart then
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
        end
        if Humanoid then Humanoid.PlatformStand = false end
    end
end

local function toggleNoclip(state)
    isNoclip = state
    if isNoclip then
        noclipSteppedConn = RunService.Stepped:Connect(function()
            if not Character or not RootPart or not isNoclip then return end

            if UI:GetSecurityMultiplier() == 1 then
                for _, part in ipairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end

            if not isFlying then
                local hipHeight = Humanoid.HipHeight > 0 and Humanoid.HipHeight or 2
                local rootOffset = (RootPart.Size.Y / 2) + hipHeight
                local raycastResult = workspace:Raycast(RootPart.Position, Vector3.new(0, -rootOffset - 4, 0), rayParams)

                if raycastResult then
                    lastSafeCFrame = RootPart.CFrame
                    local expectedY = raycastResult.Position.Y + rootOffset
                    if RootPart.Position.Y < expectedY and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                        RootPart.CFrame = CFrame.new(RootPart.Position.X, expectedY, RootPart.Position.Z) * RootPart.CFrame.Rotation
                        local vel = RootPart.AssemblyLinearVelocity
                        if vel.Y < 0 then RootPart.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z) end
                    end
                else
                    local voidThreshold = workspace.FallenPartsDestroyHeight + 60
                    if RootPart.Position.Y <= voidThreshold and lastSafeCFrame then
                        RootPart.CFrame = lastSafeCFrame + Vector3.new(0, 3, 0)
                        RootPart.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end
        end)
    else
        if noclipSteppedConn then noclipSteppedConn:Disconnect(); noclipSteppedConn = nil end

    end
end


local function toggleShiftlock(state)
    isShiftlock = state
    if isShiftlock then
        savedMaxZoom = LocalPlayer.CameraMaxZoomDistance
        LocalPlayer.CameraMaxZoomDistance = SHIFTLOCK_ZOOM

        if Humanoid then
            Humanoid.AutoRotate = false
            Humanoid.CameraOffset = SHIFTLOCK_OFFSET
        end

        shiftlockConn = RunService.RenderStepped:Connect(function()
            if not isShiftlock or not RootPart or not Humanoid then return end

            if isFlying or Humanoid.Sit or Humanoid.Health <= 0 then return end

            local camLook = Camera.CFrame.LookVector
            local flat = Vector3.new(camLook.X, 0, camLook.Z)
            if flat.Magnitude < 1e-3 then return end

            local pos = RootPart.Position
            RootPart.CFrame = CFrame.lookAt(pos, pos + flat.Unit)
        end)
    else
        if shiftlockConn then shiftlockConn:Disconnect(); shiftlockConn = nil end
        if savedMaxZoom then
            LocalPlayer.CameraMaxZoomDistance = savedMaxZoom
            savedMaxZoom = nil
        end
        if Humanoid then
            Humanoid.AutoRotate = true
            Humanoid.CameraOffset = Vector3.zero
        end
    end
    updateShiftWidget()
end

local function createShiftWidget()
    local WIDGET_SIZE = 54
    local DRAG_THRESHOLD = 8

    local gui = Instance.new("ScreenGui")
    gui.Name = "BxB_Shiftlock"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    table.insert(Process.Instances, gui)

    local btn = Instance.new("TextButton")
    btn.Name = "ShiftlockWidget"
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Size = UDim2.fromOffset(WIDGET_SIZE, WIDGET_SIZE)
    btn.Position = UDim2.fromOffset(Camera.ViewportSize.X - 80, Camera.ViewportSize.Y * 0.6)
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    btn.BackgroundTransparency = 0.35
    btn.AutoButtonColor = false
    btn.Text = "◎"
    btn.TextSize = 24
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.BorderSizePixel = 0
    btn.Parent = gui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(70, 70, 85)
    stroke.Thickness = 1.5

    updateShiftWidget = function()
        local on = isShiftlock
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Color3.fromRGB(0, 185, 120) or Color3.fromRGB(15, 15, 18),
            TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
        }):Play()
        stroke.Color = on and Color3.fromRGB(0, 220, 150) or Color3.fromRGB(70, 70, 85)
    end

    local activeInput, dragOrigin, startPos, moved = nil, nil, nil, false

    local function clampToScreen(x, y)
        local vp = Camera.ViewportSize
        local r = WIDGET_SIZE / 2
        return math.clamp(x, r, vp.X - r), math.clamp(y, r, vp.Y - r)
    end

    table.insert(Process.Connections, btn.InputBegan:Connect(function(input)
        if activeInput then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            activeInput = input
            dragOrigin = Vector2.new(input.Position.X, input.Position.Y)
            startPos = Vector2.new(btn.Position.X.Offset, btn.Position.Y.Offset)
            moved = false
        end
    end))

    table.insert(Process.Connections, UserInputService.InputChanged:Connect(function(input)
        if not activeInput then return end
        local isTouchMatch = input == activeInput
        local isMouseMatch = input.UserInputType == Enum.UserInputType.MouseMovement
            and activeInput.UserInputType == Enum.UserInputType.MouseButton1
        if not (isTouchMatch or isMouseMatch) then return end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - dragOrigin
        if delta.Magnitude > DRAG_THRESHOLD then moved = true end
        if moved then
            local x, y = clampToScreen(startPos.X + delta.X, startPos.Y + delta.Y)
            btn.Position = UDim2.fromOffset(x, y)
        end
    end))

    table.insert(Process.Connections, UserInputService.InputEnded:Connect(function(input)
        if not activeInput then return end
        local isTouchMatch = input == activeInput
        local isMouseMatch = input.UserInputType == Enum.UserInputType.MouseButton1
            and activeInput.UserInputType == Enum.UserInputType.MouseButton1
        if not (isTouchMatch or isMouseMatch) then return end

        local wasTap = not moved
        activeInput = nil
        if wasTap and ShiftlockToggleObj then
            ShiftlockToggleObj:SetState(not ShiftlockToggleObj.GetState())
        end
    end))

    updateShiftWidget()
end

if flagFly then
    local flyRow = UI:CreateContainer({
        Name = "FlyRow",
        Parent = UI.BodyContainer,
        Direction = "Horizontal",
        Size = UDim2.new(1, 0, 0, 84),
        Padding = 8,
        LayoutOrder = 1
    })

    UI:CreateAltitudePaddles({
        Parent = flyRow,
        LayoutOrder = 1,
        OnUp = function(s) isAscending = s end,
        OnDown = function(s) isDescending = s end
    })

    local actionCol = UI:CreateContainer({
        Name = "FlyActions",
        Parent = flyRow,
        Direction = "Vertical",
        Size = UDim2.new(1, -62, 0, 84),
        Padding = 6,
        LayoutOrder = 2
    })

    FlyToggleObj = UI:CreateToggle({
        Parent = actionCol,
        LayoutOrder = 1,
        Text = "FLY",
        Key = KeyFly,
        Callback = toggleFlight
    })

    UI:CreateSpeedStepper({
        Parent = actionCol,
        LayoutOrder = 2,
        Default = 1,
        Min = 1,
        Max = 20,
        Step = 50,
        Callback = function(lvl) speedLevel = lvl end
    })
end

if flagNoclip then
    NoclipToggleObj = UI:CreateToggle({
        Parent = UI.BodyContainer,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "NOCLIP",
        Key = KeyNoclip,
        Callback = toggleNoclip
    })
end

if flagShiftlock then
    ShiftlockToggleObj = UI:CreateToggle({
        Parent = UI.BodyContainer,
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "SHIFTLOCK",
        Key = KeyShiftlock,
        Callback = toggleShiftlock
    })

    if UserInputService.TouchEnabled then
        createShiftWidget()
    end
end

if flagFly then
    UI:CreateKeybindRow("Fly Keybind", KeyFly, function(newKey)
        KeyFly = newKey
        if FlyToggleObj then FlyToggleObj:SetKey(newKey) end
    end, 1)
end

if flagNoclip then
    UI:CreateKeybindRow("Noclip Keybind", KeyNoclip, function(newKey)
        KeyNoclip = newKey
        if NoclipToggleObj then NoclipToggleObj:SetKey(newKey) end
    end, 2)
end

if flagShiftlock then
    UI:CreateKeybindRow("Shiftlock Keybind", KeyShiftlock, function(newKey)
        KeyShiftlock = newKey
        if ShiftlockToggleObj then ShiftlockToggleObj:SetKey(newKey) end
    end, 3)
end

function Process:Teardown()
    if self.IsTerminated then return end
    self.IsTerminated = true

    pcall(function() toggleFlight(false) end)
    pcall(function() toggleNoclip(false) end)
    pcall(function() toggleShiftlock(false) end)

    if RootPart and Humanoid then
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
        Humanoid.PlatformStand = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    for _, conn in ipairs(self.Connections) do
        if conn and conn.Disconnect then pcall(function() conn:Disconnect() end) end
    end

    for _, mover in ipairs(self.BodyMovers) do
        if mover and mover.Destroy then pcall(function() mover:Destroy() end) end
    end

    for _, inst in ipairs(self.Instances) do
        if inst and inst.Destroy then pcall(function() inst:Destroy() end) end
    end

    if UI then UI:Destroy() end
    getgenv().BxB_Process = nil
end

UI.OnCloseCallback = function()
    Process:Teardown()
end
