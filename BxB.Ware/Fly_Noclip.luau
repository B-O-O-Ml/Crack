local globalEnv = (getgenv and getgenv()) or _G
globalEnv.BxB_Export = nil

local rawUrl = "https://raw.githubusercontent.com/B-O-O-Ml/Crack/main/BxB.Ware/Library/ui_library.luau?t=" .. tostring(os.time())

local fetchSuccess, rawSource = pcall(function()
    return game:HttpGet(rawUrl, true)
end)

if not fetchSuccess or type(rawSource) ~= "string" or #rawSource < 30 or rawSource:find("404: Not Found") then
    warn("[BxB Error] Network Fetch Exception: Unable to download source from GitHub.")
    return
end

local compileSuccess, chunk = pcall(loadstring, rawSource)
if not compileSuccess or type(chunk) ~= "function" then
    warn("[BxB Error] Syntax Exception: Failed to compile fetched bytecode.")
    return
end

task.spawn(chunk)

local startTime = os.clock()
while not globalEnv.BxB_Export and (os.clock() - startTime) < 3 do
    task.wait(0.05)
end

local BxB = globalEnv.BxB_Export
if type(BxB) ~= "table" then
    warn("[BxB Error] Memory Link Failure: BxB library table not found in global namespace. Verify 'getgenv().BxB_Export = BxB' in source.")
    return
end

globalEnv.BxB_Export = nil

local UI = BxB.new({
    RawTitle = {105, 83, 105, 5, 124, 74, 89, 78, 11, 87, 11, 99, 94, 73},
    ExpectedSig = 0x8BC63ED3,
    Width = 260,
    Height = 196
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Character, RootPart, Humanoid
local isFlying = false
local isAscending, isDescending = false, false
local speedLevel = 1
local bodyVelocity, bodyGyro
local renderConn

local function syncCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
end
syncCharacter()
table.insert(UI.Connections, LocalPlayer.CharacterAdded:Connect(syncCharacter))

UI:CreateAltitudePaddles({
    Parent = UI.BodyContainer,
    Position = UDim2.new(0, 10, 0, 6),
    OnUp = function(s) isAscending = s end,
    OnDown = function(s) isDescending = s end
})

local actionCol = Instance.new("Frame")
actionCol.Size = UDim2.new(1, -78, 0, 84)
actionCol.Position = UDim2.new(0, 68, 0, 6)
actionCol.BackgroundTransparency = 1
actionCol.Parent = UI.BodyContainer

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
        move = (camCF.LookVector * Humanoid.MoveDirection:Dot(flatLook)) + (camCF.RightVector * Humanoid.MoveDirection:Dot(flatRight))
    end
    return move.Magnitude > 0 and move.Unit or Vector3.zero
end

local function toggleFlight(state)
    isFlying = state
    if isFlying then
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
            local fieldStrength = UI:GetSecurityMultiplier()
            local effectiveSpeed = speedLevel * 50
            bodyVelocity.Velocity = calculateVector() * (effectiveSpeed * fieldStrength)
            bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9) * fieldStrength
            bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9) * fieldStrength
            bodyGyro.CFrame = Camera.CFrame
        end)
    else
        if renderConn then renderConn:Disconnect() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        if Humanoid then Humanoid.PlatformStand = false end
    end
end

UI:CreateToggle({
    Parent = actionCol,
    Position = UDim2.new(0, 0, 0, 0),
    Text = "SYSTEM",
    Key = Enum.KeyCode.E,
    Callback = toggleFlight
})

UI:CreateSpeedStepper({
    Parent = actionCol,
    Position = UDim2.new(0, 0, 0, 45),
    Default = 1,
    Min = 1,
    Max = 20,
    Step = 50,
    Callback = function(lvl) speedLevel = lvl end
})

UI.OnCloseCallback = function()
    toggleFlight(false)
end
