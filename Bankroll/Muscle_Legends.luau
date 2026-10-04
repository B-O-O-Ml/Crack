--bypass ui key system :D
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

if _G.BankrollMuscleLegendsCleanup then
    pcall(_G.BankrollMuscleLegendsCleanup)
end

local function cleanupOldGuis(parent)
    if parent then
        for _, obj in pairs(parent:GetChildren()) do
            if obj.Name == "BankrollKeySystem" or obj.Name == "bankroll.wtf" then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end
pcall(function() cleanupOldGuis(game:GetService("CoreGui")) end)
pcall(function() cleanupOldGuis(LocalPlayer:WaitForChild("PlayerGui")) end)

local selectedCrystal = "Blue Crystal"
local selectedPet = "A. Gnatomy"
local selectedAura = "Blue Aura"
local autoOpenCrystal = false
local autoOpenPet = false
local autoOpenAura = false
local fastForceHatch = false
local autoEvolve = false
local CRYSTAL_LIST = {
    "Blue Crystal", "Green Crystal", "Frost Crystal", "Mythical Crystal",
    "Inferno Crystal", "Legends Crystal", "Muscle Elite Crystal",
    "Galaxy Oracle Crystal", "Jungle Crystal", "Cybernetic Crystal",
    "Ultra Inferno Crystal"
}

local rockStates = {}
local rockThreads = {}
local targetRebirthValue = 0
local autoTargetRebirth = false
local infiniteRebirth = false
local autoSizeActive = false
local teleportActive = false
local autoWeight = false
local autoPushups = false
local autoHandstands = false
local autoSitups = false
local autoPunch = false
local fastTools = false
local autoWinBrawl = false
local autoJoinBrawl = false
local autoKillAll = false
local ignoreFriendsInKillAll = false
local selectedKillPlayer = ""
local autoKillSelected = false
local killSelectedFreezeConnection = nil
local playerAddedConnection = nil
local playerRemovingConnection = nil
local antiKnockback = false
local antiAFKConnection = nil
local walkOnWater = false
local autoSpinWheel = false
local autoClaimGifts = false
local sessionStartTime = os.time()
local sessionStartStrength = 0
local sessionStartDurability = 0
local sessionStartKills = 0
local sessionStartRebirths = 0
local sessionStartBrawls = 0
local parts = {}
local rockFreezeConnection = nil
local killAllFreezeConnection = nil

local PET_LIST = {
    "A. Gnatomy", "Aether Spirit Bunny", "Alien Girl", "Astral Electro",
    "Azure Tundra", "Blue Aura", "Blue Birdie", "Blue Bunny", "Blue Firecaster",
    "Blue Pheonix", "Boy Wonder", "Chops", "Cool Guy Larry", "Crimson Falcon",
    "Cybernetic Showdown Dragon", "Dark Electro", "Dark Golem", "Dark Legends Manticore",
    "Dark Lightning", "Dark Storm", "Dark Vampy", "Darkstar Hunter", "Electro",
    "Enchanted Mirage", "Entropic Blast", "Eternal Megastrike", "Eternal Strike Leviathan",
    "Frostwave Legends Penguin", "Gold Warrior", "Golden Pheonix", "Golden Viking",
    "Grand Supernova", "Green Aura", "Green Butterfly", "Green Firecaster",
    "Green-Fly", "Hank", "Ice Ice", "Infernal Dragon", "Inferno", "Lightning",
    "Lightning Strike Phantom", "Magic Butterfly", "Mask Of Gold", "Masked Marksman",
    "Mr. Serious", "Muscle King", "Muscle Sensei", "Neon Guardian", "Orange Hedgehog",
    "Orange Pegasus", "Phantom Genesis Dragon", "Power Lightning", "Purple Aura",
    "Purple Dragon", "Purple Falcon", "Purple Nova", "Red Aura", "Red Dragon",
    "Red Firecaster", "Red Kitty", "Screaming Bones", "Silver Dog", "Sir Flame",
    "Sky Hawk", "Slitherman", "Smiley", "Supernova", "Ultimate Supernova Pegasus",
    "Ultra Birdie", "Ultra Inferno", "Ultra Mirage", "Unstable Mirage",
    "White Pegasus", "White Pheonix", "Yellow Aura", "Yellow Butterfly"
}

local originalRockProperties = {}

local function bringRock(rockName)
    rockStates[rockName] = true
    
    rockThreads[rockName] = task.spawn(function()
        while rockStates[rockName] do
            local model = Workspace.machinesFolder:FindFirstChild(rockName)
            if model then
                local neededDur = model:FindFirstChild("neededDurability", true)
                local durability = neededDur and neededDur.Value or 0
                
                local durObj = LocalPlayer:FindFirstChild("Durability")
                local durVal = durObj and durObj.Value or 0
                if durVal >= durability then
                    local rock = model:FindFirstChild("Rock") or model:FindFirstChildOfClass("BasePart")
                    
                    local activeChar = LocalPlayer.Character
                    local activeRoot = activeChar and activeChar:FindFirstChild("HumanoidRootPart")
                    local activeHum = activeChar and activeChar:FindFirstChildOfClass("Humanoid")
                    
                    if activeRoot and activeHum then
                        if not rockFreezeConnection then
                            local lastChar = activeChar
                            local freezeCFrame = activeRoot.CFrame
                            rockFreezeConnection = RunService.Heartbeat:Connect(function()
                                local cChar = LocalPlayer.Character
                                local cRoot = cChar and cChar:FindFirstChild("HumanoidRootPart")
                                if cRoot then
                                    if cChar ~= lastChar then
                                        lastChar = cChar
                                        freezeCFrame = cRoot.CFrame
                                    end
                                    cRoot.CFrame = freezeCFrame
                                    cRoot.Velocity = Vector3.new(0, 0, 0)
                                end
                            end)
                        end
                        
                        if not originalRockProperties[model] then
                            local descProps = {}
                            for _, child in pairs(model:GetDescendants()) do
                                if child:IsA("BasePart") then
                                    descProps[child] = {
                                        CanCollide = child.CanCollide,
                                        Anchored = child.Anchored,
                                        Transparency = child.Transparency
                                    }
                                end
                            end
                            originalRockProperties[model] = {
                                Pivot = model:GetPivot(),
                                Descendants = descProps
                            }
                        end
                        
                        for child, _ in pairs(originalRockProperties[model].Descendants) do
                            child.CanCollide = false
                            child.Anchored = true
                            child.Transparency = 0.5
                        end
                        
                        model:PivotTo(activeRoot.CFrame * CFrame.new(0, 0, -2))
                        
                        local punch = activeChar:FindFirstChild("Punch") or LocalPlayer.Backpack:FindFirstChild("Punch")
                        if punch then
                            if punch.Parent == LocalPlayer.Backpack then
                                activeHum:EquipTool(punch)
                            end
                            punch:Activate()
                        end
                        
                        local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            muscleEvent:FireServer("punch", "leftHand")
                            muscleEvent:FireServer("punch", "rightHand")
                        end
                        
                        if rock then
                            local myLeft = activeChar:FindFirstChild("LeftHand") or activeChar:FindFirstChild("Left Arm")
                            local myRight = activeChar:FindFirstChild("RightHand") or activeChar:FindFirstChild("Right Arm")
                            
                            if myRight then
                                firetouchinterest(rock, myRight, 0)
                                task.wait(0.01)
                                firetouchinterest(rock, myRight, 1)
                            end
                            
                            if myLeft then
                                firetouchinterest(rock, myLeft, 0)
                                task.wait(0.01)
                                firetouchinterest(rock, myLeft, 1)
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
        
        for modelObj, props in pairs(originalRockProperties) do
            if modelObj and modelObj.Parent then
                pcall(function()
                    modelObj:PivotTo(props.Pivot)
                    for child, childProps in pairs(props.Descendants) do
                        if child and child.Parent then
                            child.CanCollide = childProps.CanCollide
                            child.Anchored = childProps.Anchored
                            child.Transparency = childProps.Transparency
                        end
                    end
                end)
            end
        end
        table.clear(originalRockProperties)
        
        local anyFarming = false
        for _, state in pairs(rockStates) do
            if state then anyFarming = true break end
        end
        if not anyFarming then
            if rockFreezeConnection then
                rockFreezeConnection:Disconnect()
                rockFreezeConnection = nil
            end
        end
    end)
end

local function formatNumber(number)
    if not number then return "0" end
    if number >= 1e15 then return string.format("%.2fQ", number/1e15)
    elseif number >= 1e12 then return string.format("%.2fT", number/1e12)
    elseif number >= 1e9 then return string.format("%.2fB", number/1e9)
    elseif number >= 1e6 then return string.format("%.2fM", number/1e6)
    elseif number >= 1e3 then return string.format("%.2fK", number/1e3)
    end
    return tostring(math.floor(number))
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function isFriend(player)
    if not player or player == LocalPlayer then return false end
    local success, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    return success and result or false
end

local function createParts()
    local partSize = 2048
    local totalDistance = 50000
    local startPosition = Vector3.new(-2, -9.5, -2)
    local numberOfParts = math.ceil(totalDistance / partSize)
    for x = 0, numberOfParts - 1 do
        for z = 0, numberOfParts - 1 do
            local newPartSide = Instance.new("Part")
            newPartSide.Size = Vector3.new(partSize, 1, partSize)
            newPartSide.Position = startPosition + Vector3.new(x * partSize, 0, z * partSize)
            newPartSide.Anchored = true
            newPartSide.Transparency = 1
            newPartSide.CanCollide = true
            newPartSide.Name = "Part_Side_" .. x .. "_" .. z
            newPartSide.Parent = Workspace
            table.insert(parts, newPartSide)
            
            local newPartLeftRight = Instance.new("Part")
            newPartLeftRight.Size = Vector3.new(partSize, 1, partSize)
            newPartLeftRight.Position = startPosition + Vector3.new(-x * partSize, 0, z * partSize)
            newPartLeftRight.Anchored = true
            newPartLeftRight.Transparency = 1
            newPartLeftRight.CanCollide = true
            newPartLeftRight.Name = "Part_LeftRight_" .. x .. "_" .. z
            newPartLeftRight.Parent = Workspace
            table.insert(parts, newPartLeftRight)
        end
    end
end

local function makePartsWalkthrough()
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
end

local function initializeScript()
    pcall(function()
        sessionStartStrength = LocalPlayer.leaderstats.Strength.Value
        sessionStartDurability = LocalPlayer.Durability.Value
        sessionStartKills = LocalPlayer.leaderstats.Kills.Value
        sessionStartRebirths = LocalPlayer.leaderstats.Rebirths.Value
        sessionStartBrawls = LocalPlayer.leaderstats.Brawls.Value
    end)

    _G.BankrollMuscleLegendsCleanup = function()
        autoOpenCrystal = false
        autoOpenPet = false
        autoOpenAura = false
        fastForceHatch = false
        autoEvolve = false
        autoWeight = false
        autoPushups = false
        autoHandstands = false
        autoSitups = false
        autoPunch = false
        fastTools = false
        autoWinBrawl = false
        autoJoinBrawl = false
        autoKillAll = false
        ignoreFriendsInKillAll = false
        autoKillSelected = false
        autoTargetRebirth = false
        infiniteRebirth = false
        autoSizeActive = false
        teleportActive = false
        walkOnWater = false
        autoSpinWheel = false
        autoClaimGifts = false
        
        for rockName, _ in pairs(rockStates) do
            rockStates[rockName] = false
        end
        
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
        
        if rockFreezeConnection then
            rockFreezeConnection:Disconnect()
            rockFreezeConnection = nil
        end
        
        if killAllFreezeConnection then
            killAllFreezeConnection:Disconnect()
            killAllFreezeConnection = nil
        end

        if killSelectedFreezeConnection then
            killSelectedFreezeConnection:Disconnect()
            killSelectedFreezeConnection = nil
        end

        if playerAddedConnection then
            playerAddedConnection:Disconnect()
            playerAddedConnection = nil
        end

        if playerRemovingConnection then
            playerRemovingConnection:Disconnect()
            playerRemovingConnection = nil
        end
        
        for modelObj, props in pairs(originalRockProperties) do
            if modelObj and modelObj.Parent then
                pcall(function()
                    modelObj:PivotTo(props.Pivot)
                    for child, childProps in pairs(props.Descendants) do
                        if child and child.Parent then
                            child.CanCollide = childProps.CanCollide
                            child.Anchored = childProps.Anchored
                            child.Transparency = childProps.Transparency
                        end
                    end
                end)
            end
        end
        table.clear(originalRockProperties)
        
        makePartsWalkthrough()
    end

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/B-O-O-Ml/Crack/refs/heads/main/Bankroll/Library.lua"))()


    local Window = Library:Window({
        Name = "bankroll.wtf | leak by BxB.Ware ",
        Logo = "rbxassetid://105944724315073",
        Center = true,
        Size = Vector2.new(450, 600)
    })

    local farmTab = Library:Tab({
        Title = "Farm",
        Icon = "rbxassetid://6031075939"
    })

    local autoToolsSection = farmTab:Section({
        Name = "Auto Workout Tools",
        ShowTitle = true,
        Side = "Left"
    })

    autoToolsSection:Toggle({
        Name = "Auto Weight",
        Default = false,
        Callback = function(value)
            autoWeight = value
            if value then
                task.spawn(function()
                    while autoWeight do
                        local weightTool = LocalPlayer.Backpack:FindFirstChild("Weight")
                        if weightTool and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Weight") then
                            LocalPlayer.Character.Humanoid:EquipTool(weightTool)
                        end
                        if LocalPlayer:FindFirstChild("muscleEvent") then
                            LocalPlayer.muscleEvent:FireServer("rep")
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    autoToolsSection:Toggle({
        Name = "Auto Pushups",
        Default = false,
        Callback = function(value)
            autoPushups = value
            if value then
                task.spawn(function()
                    while autoPushups do
                        local pushupsTool = LocalPlayer.Backpack:FindFirstChild("Pushups")
                        if pushupsTool and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Pushups") then
                            LocalPlayer.Character.Humanoid:EquipTool(pushupsTool)
                        end
                        if LocalPlayer:FindFirstChild("muscleEvent") then
                            LocalPlayer.muscleEvent:FireServer("rep")
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    autoToolsSection:Toggle({
        Name = "Auto Handstands",
        Default = false,
        Callback = function(value)
            autoHandstands = value
            if value then
                task.spawn(function()
                    while autoHandstands do
                        local handstandsTool = LocalPlayer.Backpack:FindFirstChild("Handstands")
                        if handstandsTool and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Handstands") then
                            LocalPlayer.Character.Humanoid:EquipTool(handstandsTool)
                        end
                        if LocalPlayer:FindFirstChild("muscleEvent") then
                            LocalPlayer.muscleEvent:FireServer("rep")
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    autoToolsSection:Toggle({
        Name = "Auto Situps",
        Default = false,
        Callback = function(value)
            autoSitups = value
            if value then
                task.spawn(function()
                    while autoSitups do
                        local situpsTool = LocalPlayer.Backpack:FindFirstChild("Situps")
                        if situpsTool and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Situps") then
                            LocalPlayer.Character.Humanoid:EquipTool(situpsTool)
                        end
                        if LocalPlayer:FindFirstChild("muscleEvent") then
                            LocalPlayer.muscleEvent:FireServer("rep")
                        end
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    autoToolsSection:Toggle({
        Name = "Auto Punch",
        Default = false,
        Callback = function(value)
            autoPunch = value
            if value then
                task.spawn(function()
                    while autoPunch do
                        local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                        if punch and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Punch") then
                            LocalPlayer.Character.Humanoid:EquipTool(punch)
                            if punch:FindFirstChild("attackTime") then
                                punch.attackTime.Value = 0
                            end
                        end
                        if LocalPlayer:FindFirstChild("muscleEvent") then
                            LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
                            LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
                        end
                        task.wait(0)
                    end
                end)
            end
        end
    })

    autoToolsSection:Toggle({
        Name = "Fast Tools",
        Default = false,
        Callback = function(value)
            fastTools = value
            local defaultSpeeds = {
                {"Punch", "attackTime", value and 0 or 0.35},
                {"Ground Slam", "attackTime", value and 0 or 6},
                {"Stomp", "attackTime", value and 0 or 7},
                {"Handstands", "repTime", value and 0 or 1},
                {"Pushups", "repTime", value and 0 or 1},
                {"Weight", "repTime", value and 0 or 1},
                {"Situps", "repTime", value and 0 or 1}
            }
            local backpack = LocalPlayer.Backpack
            for _, toolInfo in ipairs(defaultSpeeds) do
                local tool = backpack:FindFirstChild(toolInfo[1])
                if tool and tool:FindFirstChild(toolInfo[2]) then
                    tool[toolInfo[2]].Value = toolInfo[3]
                end
                
                local equippedTool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(toolInfo[1])
                if equippedTool and equippedTool:FindFirstChild(toolInfo[2]) then
                    equippedTool[toolInfo[2]].Value = toolInfo[3]
                end
            end
        end
    })

    local rebirthsSection = farmTab:Section({
        Name = "Rebirths",
        ShowTitle = true,
        Side = "Left"
    })

    rebirthsSection:Textbox({
        Name = "Rebirth Target Amount",
        Default = "0",
        PlaceholderText = "Enter amount...",
        Callback = function(value)
            local newValue = tonumber(value)
            if newValue then
                targetRebirthValue = newValue
            end
        end
    })

    rebirthsSection:Toggle({
        Name = "Auto Rebirth Target",
        Default = false,
        Callback = function(value)
            autoTargetRebirth = value
            if value then
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("rebirthRemote")
                    while autoTargetRebirth do
                        local currentRebirths = LocalPlayer.leaderstats.Rebirths.Value
                        if currentRebirths >= targetRebirthValue then
                            autoTargetRebirth = false
                            pcall(function()
                                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                                    Text = "ð Target reached! " .. tostring(targetRebirthValue) .. " rebirths",
                                    Color = Color3.new(0, 1, 1),
                                    Font = Enum.Font.SourceSansBold,
                                    TextSize = 18
                                })
                            end)
                            break
                        end
                        remote:InvokeServer("rebirthRequest")
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    rebirthsSection:Toggle({
        Name = "Auto Rebirth (Infinite)",
        Default = false,
        Callback = function(value)
            infiniteRebirth = value
            if value then
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("rebirthRemote")
                    while infiniteRebirth do
                        remote:InvokeServer("rebirthRequest")
                        task.wait(0.1)
                    end
                end)
            end
        end
    })

    rebirthsSection:Toggle({
        Name = "Auto Size 1",
        Default = false,
        Callback = function(value)
            autoSizeActive = value
            if value then
                task.spawn(function()
                    local remote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote")
                    while autoSizeActive do
                        remote:InvokeServer("changeSize", 1)
                        task.wait()
                    end
                end)
            end
        end
    })

    rebirthsSection:Toggle({
        Name = "Auto Teleport to Muscle King",
        Default = false,
        Callback = function(value)
            teleportActive = value
            if value then
                task.spawn(function()
                    while teleportActive do
                        if LocalPlayer.Character then
                            LocalPlayer.Character:MoveTo(Vector3.new(-8646, 17, -5738))
                        end
                        task.wait()
                    end
                end)
            end
        end
    })

    local rockFarmSection = farmTab:Section({
        Name = "Rock Farming (Rocks Come to You!)",
        ShowTitle = true,
        Side = "Right"
    })

    local allRockData = {
        ["Tiny Rock"] = 0,
        ["Punching Rock"] = 100,
        ["Legend Beach Rock"] = 5000,
        ["Frozen Rock"] = 150000,
        ["Mythical Rock"] = 400000,
        ["Inferno Rock"] = 750000,
        ["Rock Of Legends"] = 1000000,
        ["Muscle King Mountain"] = 5000000,
        ["Ancient Jungle Rock"] = 10000000
    }

    for rockName, durability in pairs(allRockData) do
        rockFarmSection:Toggle({
            Name = rockName,
            Default = false,
            Callback = function(value)
                if value then
                    bringRock(rockName)
                else
                    rockStates[rockName] = false
                    if rockThreads[rockName] then
                        rockThreads[rockName] = nil
                    end
                    task.defer(function()
                        local anyFarming = false
                        for _, state in pairs(rockStates) do
                            if state then anyFarming = true break end
                        end
                        if not anyFarming then
                            pcall(function()
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                    LocalPlayer.Character.HumanoidRootPart.Anchored = false
                                end
                            end)
                        end
                    end)
                end
            end
        })
    end

    local combatTab = Library:Tab({
        Title = "Combat",
        Icon = "rbxassetid://3926307971"
    })

    local brawlsSection = combatTab:Section({
        Name = "Auto Brawls",
        ShowTitle = true
    })

    brawlsSection:Toggle({
        Name = "Auto Win Brawls",
        Default = false,
        Callback = function(value)
            autoWinBrawl = value
            if value then
                task.spawn(function()
                    while autoWinBrawl do
                        local gameGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("gameGui")
                        if gameGui and gameGui:FindFirstChild("brawlJoinLabel") and gameGui.brawlJoinLabel.Visible then
                            ReplicatedStorage.rEvents.brawlEvent:FireServer("joinBrawl")
                            gameGui.brawlJoinLabel.Visible = false
                        end
                        
                        local bip = ReplicatedStorage:FindFirstChild("brawlInProgress")
                        if bip and bip.Value then
                            local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
                            if punch and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Punch") then
                                LocalPlayer.Character.Humanoid:EquipTool(punch)
                            end
                            if LocalPlayer:FindFirstChild("muscleEvent") then
                                LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
                                LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
                            end
                            
                            for _, target in pairs(Players:GetPlayers()) do
                                if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("LeftHand") then
                                        firetouchinterest(target.Character.HumanoidRootPart, LocalPlayer.Character.LeftHand, 0)
                                        task.wait(0.01)
                                        firetouchinterest(target.Character.HumanoidRootPart, LocalPlayer.Character.LeftHand, 1)
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    brawlsSection:Toggle({
        Name = "Auto Join Brawls",
        Default = false,
        Callback = function(value)
            autoJoinBrawl = value
            if value then
                task.spawn(function()
                    while autoJoinBrawl do
                        local gameGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("gameGui")
                        if gameGui and gameGui:FindFirstChild("brawlJoinLabel") and gameGui.brawlJoinLabel.Visible then
                            ReplicatedStorage.rEvents.brawlEvent:FireServer("joinBrawl")
                            gameGui.brawlJoinLabel.Visible = false
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end
    })

    local combatUtilsSection = combatTab:Section({
        Name = "Combat Utilities",
        ShowTitle = true
    })

    combatUtilsSection:Toggle({
        Name = "Auto Kill All",
        Default = false,
        Callback = function(value)
            autoKillAll = value
            if not value then
                if killAllFreezeConnection then
                    killAllFreezeConnection:Disconnect()
                    killAllFreezeConnection = nil
                end
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local root = LocalPlayer.Character.HumanoidRootPart
                        root.Velocity = Vector3.new(0, 0, 0)
                        root.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
            
            if value then
                task.spawn(function()
                    while autoKillAll do
                        local activeChar = LocalPlayer.Character
                        local activeRoot = activeChar and activeChar:FindFirstChild("HumanoidRootPart")
                        local activeHum = activeChar and activeChar:FindFirstChildOfClass("Humanoid")
                        
                        if activeRoot and activeHum then
                            if not killAllFreezeConnection then
                                local lastChar = activeChar
                                local freezeCFrame = activeRoot.CFrame
                                killAllFreezeConnection = RunService.Heartbeat:Connect(function()
                                    local cChar = LocalPlayer.Character
                                    local cRoot = cChar and cChar:FindFirstChild("HumanoidRootPart")
                                    if cRoot then
                                        if cChar ~= lastChar then
                                            lastChar = cChar
                                            freezeCFrame = cRoot.CFrame
                                        end
                                        cRoot.CFrame = freezeCFrame
                                        cRoot.Velocity = Vector3.new(0, 0, 0)
                                    end
                                end)
                            end
                            
                            local punch = activeChar:FindFirstChild("Punch") or LocalPlayer.Backpack:FindFirstChild("Punch")
                            if punch then
                                if punch.Parent == LocalPlayer.Backpack then
                                    activeHum:EquipTool(punch)
                                end
                                punch:Activate()
                            end
                            
                            local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                            if muscleEvent then
                                muscleEvent:FireServer("punch", "rightHand")
                                muscleEvent:FireServer("punch", "leftHand")
                            end
                            
                            local myLeft = activeChar:FindFirstChild("LeftHand") or activeChar:FindFirstChild("Left Arm")
                            local myRight = activeChar:FindFirstChild("RightHand") or activeChar:FindFirstChild("Right Arm")
                            
                            local targetsToTouch = {}
                            
                            for _, target in pairs(Players:GetPlayers()) do
                                if target ~= LocalPlayer then
                                    if not (ignoreFriendsInKillAll and isFriend(target)) then
                                        local char = target.Character
                                        local targetRoot = char and char:FindFirstChild("HumanoidRootPart")
                                        if targetRoot then
                                            pcall(function()
                                                targetRoot.CFrame = activeRoot.CFrame * CFrame.new(0, 0, -3)
                                                targetRoot.Velocity = Vector3.new(0, 0, 0)
                                            end)
                                            
                                            local targetHum = char:FindFirstChildOfClass("Humanoid")
                                            if targetHum and targetHum.Health > 0 then
                                                local hitPart = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
                                                if hitPart then
                                                    table.insert(targetsToTouch, hitPart)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            
                            for _, part in ipairs(targetsToTouch) do
                                if myLeft then firetouchinterest(part, myLeft, 0) end
                                if myRight then firetouchinterest(part, myRight, 0) end
                            end
                            
                            task.wait(0.02) 
                            
                            for _, part in ipairs(targetsToTouch) do
                                if myLeft then firetouchinterest(part, myLeft, 1) end
                                if myRight then firetouchinterest(part, myRight, 1) end
                            end
                        end
                        task.wait(0.18) 
                    end
                end)
            end
        end
    })

    combatUtilsSection:Toggle({
        Name = "Ignore Friends (Auto Kill All)",
        Default = false,
        Callback = function(value)
            ignoreFriendsInKillAll = value
        end
    })

    local function getPlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        table.sort(names)
        return names
    end

    local playerDropdown
    playerDropdown = combatUtilsSection:Dropdown({
        Name = "Select Target Player",
        Options = getPlayerNames(),
        Default = selectedKillPlayer,
        Callback = function(value)
            selectedKillPlayer = value
            if playerDropdown then
                playerDropdown.Default = value
            end
        end
    })

    playerAddedConnection = Players.PlayerAdded:Connect(function()
        playerDropdown:Refresh(getPlayerNames())
    end)

    playerRemovingConnection = Players.PlayerRemoving:Connect(function()
        playerDropdown:Refresh(getPlayerNames())
    end)

    combatUtilsSection:Toggle({
        Name = "Auto Kill Selected",
        Default = false,
        Callback = function(value)
            autoKillSelected = value
            if not value then
                if killSelectedFreezeConnection then
                    killSelectedFreezeConnection:Disconnect()
                    killSelectedFreezeConnection = nil
                end
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local root = LocalPlayer.Character.HumanoidRootPart
                        root.Velocity = Vector3.new(0, 0, 0)
                        root.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
            
            if value then
                task.spawn(function()
                    while autoKillSelected do
                        local activeChar = LocalPlayer.Character
                        local activeRoot = activeChar and activeChar:FindFirstChild("HumanoidRootPart")
                        local activeHum = activeChar and activeChar:FindFirstChildOfClass("Humanoid")
                        
                        if activeRoot and activeHum then
                            if not killSelectedFreezeConnection then
                                local lastChar = activeChar
                                local freezeCFrame = activeRoot.CFrame
                                killSelectedFreezeConnection = RunService.Heartbeat:Connect(function()
                                    local cChar = LocalPlayer.Character
                                    local cRoot = cChar and cChar:FindFirstChild("HumanoidRootPart")
                                    if cRoot then
                                        if cChar ~= lastChar then
                                            lastChar = cChar
                                            freezeCFrame = cRoot.CFrame
                                        end
                                        cRoot.CFrame = freezeCFrame
                                        cRoot.Velocity = Vector3.new(0, 0, 0)
                                    end
                                end)
                            end
                            
                            local punch = activeChar:FindFirstChild("Punch") or LocalPlayer.Backpack:FindFirstChild("Punch")
                            if punch then
                                if punch.Parent == LocalPlayer.Backpack then
                                    activeHum:EquipTool(punch)
                                end
                                punch:Activate()
                            end
                            
                            local muscleEvent = LocalPlayer:FindFirstChild("muscleEvent")
                            if muscleEvent then
                                muscleEvent:FireServer("punch", "rightHand")
                                muscleEvent:FireServer("punch", "leftHand")
                            end
                            
                            local myLeft = activeChar:FindFirstChild("LeftHand") or activeChar:FindFirstChild("Left Arm")
                            local myRight = activeChar:FindFirstChild("RightHand") or activeChar:FindFirstChild("Right Arm")
                            
                            local targetsToTouch = {}
                            
                            local target = Players:FindFirstChild(selectedKillPlayer)
                            if target and target ~= LocalPlayer then
                                local char = target.Character
                                local targetRoot = char and char:FindFirstChild("HumanoidRootPart")
                                if targetRoot then
                                    pcall(function()
                                        targetRoot.CFrame = activeRoot.CFrame * CFrame.new(0, 0, -3)
                                        targetRoot.Velocity = Vector3.new(0, 0, 0)
                                    end)
                                    
                                    local targetHum = char:FindFirstChildOfClass("Humanoid")
                                    if targetHum and targetHum.Health > 0 then
                                        local hitPart = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
                                        if hitPart then
                                            table.insert(targetsToTouch, hitPart)
                                        end
                                    end
                                end
                            end
                            
                            for _, part in ipairs(targetsToTouch) do
                                if myLeft then firetouchinterest(part, myLeft, 0) end
                                if myRight then firetouchinterest(part, myRight, 0) end
                            end
                            
                            task.wait(0.02) 
                            
                            for _, part in ipairs(targetsToTouch) do
                                if myLeft then firetouchinterest(part, myLeft, 1) end
                                if myRight then firetouchinterest(part, myRight, 1) end
                            end
                        end
                        task.wait(0.18) 
                    end
                end)
            end
        end
    })

    combatUtilsSection:Toggle({
        Name = "Anti Knockback",
        Default = false,
        Callback = function(value)
            antiKnockback = value
            local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                if value then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(100000, 0, 100000)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.P = 1250
                    bv.Parent = rootPart
                else
                    local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
                    if existingVelocity then
                        existingVelocity:Destroy()
                    end
                end
            end
        end
    })

    local function getCrystalRemote()
        local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
        if not rEvents then
            pcall(function()
                rEvents = ReplicatedStorage:WaitForChild("rEvents", 2)
            end)
        end
        return (rEvents and rEvents:FindFirstChild("openCrystalRemote"))
            or ReplicatedStorage:FindFirstChild("openCrystalRemote")
            or (rEvents and rEvents:FindFirstChild("cPetShopRemote"))
            or ReplicatedStorage:FindFirstChild("cPetShopRemote")
    end

    local function getShopRemote()
        local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
        if not rEvents then
            pcall(function()
                rEvents = ReplicatedStorage:WaitForChild("rEvents", 2)
            end)
        end
        local remote = (rEvents and rEvents:FindFirstChild("cPetShopRemote"))
            or ReplicatedStorage:FindFirstChild("cPetShopRemote")
            or (rEvents and rEvents:FindFirstChild("petShopRemote"))
            or ReplicatedStorage:FindFirstChild("petShopRemote")
        if not remote and rEvents then
            pcall(function()
                remote = rEvents:WaitForChild("cPetShopRemote", 2)
            end)
        end
        return remote
    end

    local function getShopFolder()
        local folder = ReplicatedStorage:FindFirstChild("cPetShopFolder")
        if not folder then
            local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
            if rEvents then
                folder = rEvents:FindFirstChild("cPetShopFolder") or rEvents:FindFirstChild("petShopFolder")
            end
        end
        if not folder then
            folder = ReplicatedStorage:FindFirstChild("petShopFolder")
        end
        if not folder then
            pcall(function()
                folder = ReplicatedStorage:WaitForChild("cPetShopFolder", 2)
            end)
        end
        if not folder then
            pcall(function()
                local rEvents = ReplicatedStorage:FindFirstChild("rEvents") or ReplicatedStorage:WaitForChild("rEvents", 2)
                if rEvents then
                    folder = rEvents:FindFirstChild("cPetShopFolder") or rEvents:FindFirstChild("petShopFolder")
                end
            end)
        end
        return folder
    end

    local function findShopItem(itemName)
        if not itemName or itemName == "" then return nil end
        local folder = getShopFolder()
        if folder then
            local direct = folder:FindFirstChild(itemName)
            if direct then return direct end
            
            local lowerName = string.lower(itemName)
            for _, child in ipairs(folder:GetChildren()) do
                if string.lower(child.Name) == lowerName then
                    return child
                end
            end
        end
        
        local deep = ReplicatedStorage:FindFirstChild(itemName, true)
        if deep and deep.Parent and (string.find(string.lower(deep.Parent.Name), "shop") or string.find(string.lower(deep.Parent.Name), "pet") or string.find(string.lower(deep.Parent.Name), "aura")) then
            return deep
        end
        
        return nil
    end

    local function openCrystalAction(crystalName)
        if not crystalName or crystalName == "" then return end
        pcall(function()
            local rEvents = ReplicatedStorage:FindFirstChild("rEvents") or ReplicatedStorage:WaitForChild("rEvents", 2)
            local crystalRemote = (rEvents and rEvents:FindFirstChild("openCrystalRemote"))
                or ReplicatedStorage:FindFirstChild("openCrystalRemote")
                
            local crystalObj = (Workspace:FindFirstChild("machinesFolder") and Workspace.machinesFolder:FindFirstChild(crystalName))
                or Workspace:FindFirstChild(crystalName)

            if crystalRemote then
                if crystalRemote:IsA("RemoteFunction") then
                    pcall(function() crystalRemote:InvokeServer("openCrystal", crystalName) end)
                    if crystalObj then
                        pcall(function() crystalRemote:InvokeServer("openCrystal", crystalObj) end)
                    end
                elseif crystalRemote:IsA("RemoteEvent") then
                    pcall(function() crystalRemote:FireServer("openCrystal", crystalName) end)
                    if crystalObj then
                        pcall(function() crystalRemote:FireServer("openCrystal", crystalObj) end)
                    end
                end
            end
        end)
    end

    local function openPetShopAction(itemName)
        if not itemName or itemName == "" then return end
        pcall(function()
            local shopRemote = getShopRemote()
            if not shopRemote then return end

            local itemObj = findShopItem(itemName)
            local target = itemObj or itemName

            if shopRemote:IsA("RemoteFunction") then
                shopRemote:InvokeServer(target)
            elseif shopRemote:IsA("RemoteEvent") then
                shopRemote:FireServer(target)
            end
        end)
    end

    local function getAvailableCrystals()
        local list = {}
        local seen = {}
        for _, c in ipairs(CRYSTAL_LIST) do
            if not seen[c] then
                seen[c] = true
                table.insert(list, c)
            end
        end
        pcall(function()
            local machinesFolder = Workspace:FindFirstChild("machinesFolder")
            if machinesFolder then
                for _, obj in ipairs(machinesFolder:GetChildren()) do
                    if string.find(obj.Name, "Crystal") and not seen[obj.Name] then
                        seen[obj.Name] = true
                        table.insert(list, obj.Name)
                    end
                end
            end
            for _, obj in ipairs(Workspace:GetChildren()) do
                if string.find(obj.Name, "Crystal") and not seen[obj.Name] then
                    seen[obj.Name] = true
                    table.insert(list, obj.Name)
                end
            end
        end)
        return list
    end

    local function getAvailableShopPets()
        local list = {}
        local seen = {}
        local folder = getShopFolder()
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if not string.find(child.Name, "Aura") and not seen[child.Name] then
                    seen[child.Name] = true
                    table.insert(list, child.Name)
                end
            end
        end
        for _, name in ipairs(PET_LIST) do
            if not seen[name] then
                seen[name] = true
                table.insert(list, name)
            end
        end
        table.sort(list)
        return list
    end

    local function getAvailableShopAuras()
        local list = {}
        local seen = {}
        local folder = getShopFolder()
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if string.find(child.Name, "Aura") and not seen[child.Name] then
                    seen[child.Name] = true
                    table.insert(list, child.Name)
                end
            end
        end
        local defaultAuras = {
            "Astral Electro", "Azure Tundra", "Blue Aura", "Dark Electro", "Dark Lightning",
            "Dark Storm", "Electro", "Enchanted Mirage", "Entropic Blast", "Eternal Megastrike",
            "Grand Supernova", "Green Aura", "Inferno", "Lightning", "Muscle King",
            "Power Lightning", "Purple Aura", "Purple Nova", "Red Aura", "Supernova",
            "Ultra Inferno", "Ultra Mirage", "Unstable Mirage", "Yellow Aura"
        }
        for _, name in ipairs(defaultAuras) do
            if not seen[name] then
                seen[name] = true
                table.insert(list, name)
            end
        end
        table.sort(list)
        return list
    end

    local function evolveAllEligiblePets()
        local evolvedCount = 0
        pcall(function()
            local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
            local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
            local evolveRemote = rEvents and rEvents:FindFirstChild("petEvolveEvent")
            if petsFolder and evolveRemote then
                local petCounts = {}
                for _, rarityFolder in pairs(petsFolder:GetChildren()) do
                    if rarityFolder:IsA("Folder") then
                        for _, pet in pairs(rarityFolder:GetChildren()) do
                            if pet:IsA("StringValue") and not pet:FindFirstChild("evolved") then
                                petCounts[pet.Name] = (petCounts[pet.Name] or 0) + 1
                            end
                        end
                    end
                end
                for petName, count in pairs(petCounts) do
                    if count >= 5 then
                        local sets = math.floor(count / 5)
                        for _ = 1, sets do
                            if evolveRemote:IsA("RemoteEvent") then
                                evolveRemote:FireServer("evolvePet", petName)
                            elseif evolveRemote:IsA("RemoteFunction") then
                                evolveRemote:InvokeServer("evolvePet", petName)
                            end
                            evolvedCount = evolvedCount + 1
                            task.wait(0.15)
                        end
                    end
                end
            end
        end)
        return evolvedCount
    end

    local eggsTab = Library:Tab({
        Title = "Crystals & Pets",
        Icon = "rbxassetid://6031075935"
    })

    local crystalSection = eggsTab:Section({
        Name = "Force Hatch Crystals",
        ShowTitle = true,
        Side = "Left"
    })

    local crystalDropdown
    crystalDropdown = crystalSection:Dropdown({
        Name = "Select Crystal",
        Options = getAvailableCrystals(),
        Default = selectedCrystal,
        Callback = function(value)
            selectedCrystal = value
            if crystalDropdown then
                crystalDropdown.Default = value
            end
        end
    })

    crystalSection:Toggle({
        Name = "Auto Force Hatch",
        Default = false,
        Callback = function(value)
            autoOpenCrystal = value
            if value then
                task.spawn(function()
                    while autoOpenCrystal do
                        if selectedCrystal then
                            openCrystalAction(selectedCrystal)
                        end
                        if fastForceHatch then
                            task.wait(0.01)
                        else
                            task.wait(0.1)
                        end
                    end
                end)
            end
        end
    })

    crystalSection:Toggle({
        Name = "Fast Force Hatch (No Delay)",
        Default = false,
        Callback = function(value)
            fastForceHatch = value
        end
    })

    crystalSection:Button({
        Name = "Hatch 1x (Selected Crystal)",
        Callback = function()
            if selectedCrystal then
                openCrystalAction(selectedCrystal)
            end
        end
    })

    crystalSection:Toggle({
        Name = "Auto Evolve Pets (5x)",
        Default = false,
        Callback = function(value)
            autoEvolve = value
            if value then
                task.spawn(function()
                    while autoEvolve do
                        evolveAllEligiblePets()
                        task.wait(1.5)
                    end
                end)
            end
        end
    })

    crystalSection:Button({
        Name = "Evolve All Eligible Pets Now",
        Callback = function()
            local count = evolveAllEligiblePets()
            pcall(function()
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = "Evolved " .. tostring(count) .. " pet set(s)!",
                    Color = Color3.new(0, 1, 0),
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18
                })
            end)
        end
    })

    local petEggsSection = eggsTab:Section({
        Name = "Pet & Aura Shops",
        ShowTitle = true,
        Side = "Right"
    })

    local petDropdown
    petDropdown = petEggsSection:Dropdown({
        Name = "Select Pet",
        Options = getAvailableShopPets(),
        Default = selectedPet,
        Callback = function(value)
            selectedPet = value
            if petDropdown then
                petDropdown.Default = value
            end
        end
    })

    petEggsSection:Toggle({
        Name = "Auto Open Pet (Shop)",
        Default = false,
        Callback = function(value)
            autoOpenPet = value
            if value then
                task.spawn(function()
                    while autoOpenPet do
                        if selectedPet then
                            openPetShopAction(selectedPet)
                        end
                        if fastForceHatch then
                            task.wait(0.01)
                        else
                            task.wait(0.1)
                        end
                    end
                end)
            end
        end
    })

    petEggsSection:Button({
        Name = "Open 1x Pet (Shop)",
        Callback = function()
            if selectedPet then
                openPetShopAction(selectedPet)
            end
        end
    })

    local selectedAura = "Blue Aura"
    local auraDropdown
    auraDropdown = petEggsSection:Dropdown({
        Name = "Select Aura",
        Options = getAvailableShopAuras(),
        Default = selectedAura,
        Callback = function(value)
            selectedAura = value
            if auraDropdown then
                auraDropdown.Default = value
            end
        end
    })

    petEggsSection:Toggle({
        Name = "Auto Open Aura (Shop)",
        Default = false,
        Callback = function(value)
            autoOpenAura = value
            if value then
                task.spawn(function()
                    while autoOpenAura do
                        if selectedAura then
                            openPetShopAction(selectedAura)
                        end
                        if fastForceHatch then
                            task.wait(0.01)
                        else
                            task.wait(0.1)
                        end
                    end
                end)
            end
        end
    })

    petEggsSection:Button({
        Name = "Open 1x Aura (Shop)",
        Callback = function()
            if selectedAura then
                openPetShopAction(selectedAura)
            end
        end
    })

    local miscTab = Library:Tab({
        Title = "Misc",
        Icon = "rbxassetid://6031068433"
    })

    local misc1Section = miscTab:Section({
        Name = "Utilities",
        ShowTitle = true
    })

    misc1Section:Toggle({
        Name = "Anti-AFK System",
        Default = false,
        Callback = function(value)
            if value then
                antiAFKConnection = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            else
                if antiAFKConnection then
                    antiAFKConnection:Disconnect()
                    antiAFKConnection = nil
                end
            end
        end
    })

    misc1Section:Button({
        Name = "Remove Ads",
        Callback = function()
            for _, portal in pairs(game:GetDescendants()) do
                if portal.Name == "RobloxForwardPortals" then
                    pcall(function() portal:Destroy() end)
                end
            end
            if _G.AdRemovalConnection then
                _G.AdRemovalConnection:Disconnect()
            end
            _G.AdRemovalConnection = game.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "RobloxForwardPortals" then
                    pcall(function() descendant:Destroy() end)
                end
            end)
            pcall(function()
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = "Roblox ads removed!",
                    Color = Color3.new(0, 1, 0),
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18
                })
            end)
        end
    })

    misc1Section:Toggle({
        Name = "Walk on Water",
        Default = false,
        Callback = function(value)
            walkOnWater = value
            if value then
                createParts()
                pcall(function()
                    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                        Text = "Walk on Water enabled!",
                        Color = Color3.new(0, 1, 0),
                        Font = Enum.Font.SourceSansBold,
                        TextSize = 18
                    })
                end)
            else
                makePartsWalkthrough()
                pcall(function()
                    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                        Text = "Walk on Water disabled!",
                        Color = Color3.new(1, 0.5, 0),
                        Font = Enum.Font.SourceSansBold,
                        TextSize = 18
                    })
                end)
            end
        end
    })

    misc1Section:Toggle({
        Name = "Auto Spin Wheel",
        Default = false,
        Callback = function(value)
            autoSpinWheel = value
            if value then
                task.spawn(function()
                    while autoSpinWheel do
                        pcall(function()
                            ReplicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", ReplicatedStorage.fortuneWheelChances["Fortune Wheel"])
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })

    misc1Section:Toggle({
        Name = "Auto Claim Gifts",
        Default = false,
        Callback = function(value)
            autoClaimGifts = value
            if value then
                task.spawn(function()
                    while autoClaimGifts do
                        for i = 1, 8 do
                            pcall(function()
                                ReplicatedStorage.rEvents.freeGiftClaimRemote:InvokeServer("claimGift", i)
                            end)
                        end
                        task.wait(1)
                    end
                end)
            end
        end
    })

    local statsSection = miscTab:Section({
        Name = "Session Statistics",
        ShowTitle = true
    })

    statsSection:Button({
        Name = "Reset Session Stats",
        Callback = function()
            pcall(function()
                sessionStartStrength = LocalPlayer.leaderstats.Strength.Value
                sessionStartDurability = LocalPlayer.Durability.Value
                sessionStartKills = LocalPlayer.leaderstats.Kills.Value
                sessionStartRebirths = LocalPlayer.leaderstats.Rebirths.Value
                sessionStartBrawls = LocalPlayer.leaderstats.Brawls.Value
                sessionStartTime = os.time()
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = "Session stats reset!",
                    Color = Color3.new(0, 1, 0),
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18
                })
            end)
        end
    })

    statsSection:Button({
        Name = "Copy Stats to Clipboard",
        Callback = function()
            local currentStr = LocalPlayer.leaderstats.Strength.Value
            local currentDur = LocalPlayer.Durability.Value
            local currentKills = LocalPlayer.leaderstats.Kills.Value
            local currentRebirths = LocalPlayer.leaderstats.Rebirths.Value
            local currentBrawls = LocalPlayer.leaderstats.Brawls.Value
            
            local statsText = "Muscle Legends Session Stats:\n"
            statsText = statsText .. "Time Elapsed: " .. formatTime(os.time() - sessionStartTime) .. "\n"
            statsText = statsText .. "Strength Gained: " .. formatNumber(currentStr - sessionStartStrength) .. " (Total: " .. formatNumber(currentStr) .. ")\n"
            statsText = statsText .. "Durability Gained: " .. formatNumber(currentDur - sessionStartDurability) .. " (Total: " .. formatNumber(currentDur) .. ")\n"
            statsText = statsText .. "Rebirths Gained: " .. tostring(currentRebirths - sessionStartRebirths) .. " (Total: " .. tostring(currentRebirths) .. ")\n"
            statsText = statsText .. "Kills Gained: " .. tostring(currentKills - sessionStartKills) .. " (Total: " .. tostring(currentKills) .. ")\n"
            statsText = statsText .. "Brawls Won: " .. tostring(currentBrawls - sessionStartBrawls) .. " (Total: " .. tostring(currentBrawls) .. ")"
            
            pcall(function()
                setclipboard(statsText)
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = "Stats copied to clipboard!",
                    Color = Color3.new(0, 1, 0),
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18
                })
            end)
        end
    })
end

initializeScript()
