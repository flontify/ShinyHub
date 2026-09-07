-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Be a Lucky Block
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local WorkspaceService = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
if LocalPlayer then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
        end)
    end)
end

local Rayfield
do

    local ok, mod = pcall(function()
        if loadfile then
            local f = loadfile("rayfield")
            if f then local r=f() if r then return r end end
            f = loadfile("Rayfield.lua")
            if f then local r=f() if r then return r end end
            f = loadfile("Rayfield")
            if f then local r=f() if r then return r end end
        end
    end)
    if ok and mod then
        Rayfield = mod
    else
        local ok2, src = pcall(function() return game:HttpGet("https://sirius.menu/gen2") end)
        if not ok2 or not src or src == "" then ok2, src = pcall(function() return game.HttpGet(game, "https://sirius.menu/gen2") end) end
        if ok2 and src and #src > 100 then
            local ok3, lib = pcall(function() return loadstring(src)() end)
            if ok3 and lib then Rayfield = lib end
        end
    end
end
if not Rayfield then warn("[ShinyHub] Rayfield failed to load") end

local function safeTab(window, name)
    local tab
    pcall(function() tab = window:CreateTab({Name=name, Icon=4483362458}) end)
    if not tab then pcall(function() tab = window:CreateTab(name) end) end
    return tab
end
local function Notify(opts)
    if Rayfield and pcall(function() Rayfield:Notify(opts) end) then return end
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=opts.Title or "ShinyHub", Text=opts.Content or opts.Text or "", Duration=opts.Duration or 3}) end)
end

local function createSymbioteShim(gameName)
    local shimLib = {}
    function shimLib:CreateWindow(opts)
        local title = opts.Title or gameName or "Symbiote"
        title = tostring(title):gsub("^%s+",""):gsub("%s+$","")
        if title:lower():find("symbiote") or title == "" then title = gameName end
        local displayName = "ShinyHub | " .. gameName
        local window
        local ok = pcall(function()
            window = Rayfield:CreateWindow({
                Name = displayName,
                LoadingTitle = "ShinyHub",
                LoadingSubtitle = gameName,
                Theme = "Default",
                ToggleUIKeybind = "K",
                DisableRayfieldPrompts = false,
                DisableBuildWarnings = false,
                ConfigurationSaving = {Enabled=true, FolderName="ShinyHub", FileName=gameName}
            })
        end)
        if not ok or not window then
            pcall(function()
                window = Rayfield:CreateWindow({
                    Name = displayName,
                    LoadingTitle = "ShinyHub",
                    LoadingSubtitle = gameName,
                    Theme = "Default",
                    ToggleUIKeybind = "K",
                    DisableRayfieldPrompts = false,
                    DisableBuildWarnings = false,
                    ConfigurationSaving = {Enabled=true, FolderName="ShinyHub", FileName=gameName}
                })
            end)
        end
        local WindowObj = {}
        WindowObj._ray = window
        function WindowObj:CreateTab(name)
            local tab = safeTab(window, name)
            local TabObj = {}
            TabObj._ray = tab
            TabObj._window = window
            function TabObj:AddToggle(tName, callback, default)
                if type(callback) ~= "function" and type(default) == "function" then
                    local tmp = callback
                    callback = default
                    default = tmp
                end
                if type(default) ~= "boolean" then default = false end
                if type(callback) ~= "function" then callback = function() end end
                local flag = (tName .. "_" .. name):gsub("%s+","_")
                local toggleObj
                pcall(function()
                    toggleObj = tab:CreateToggle({
                        Name = tName,
                        CurrentValue = default,
                        Flag = flag,
                        Callback = function(v) pcall(callback, v) end
                    })
                end)
                local function setToggle(v)
                    if toggleObj then
                        pcall(function()
                            if toggleObj.Set then toggleObj:Set(v)
                            elseif toggleObj.SetValue then toggleObj:SetValue(v)
                            end
                        end)
                    end
                end
                return {
                    Set = setToggle,
                    SetValue = setToggle,
                    SetState = setToggle,
                    SetEnabled = setToggle
                }
            end
            function TabObj:AddSlider(sName, min, max, def, callback)
                if type(callback) ~= "function" then callback = function() end end
                local flag = (sName .. "_" .. name):gsub("%s+","_")
                pcall(function()
                    tab:CreateSlider({
                        Name = sName,
                        Range = {min, max},
                        Increment = 1,
                        Suffix = "",
                        CurrentValue = def,
                        Flag = flag,
                        Callback = function(v) pcall(callback, v) end
                    })
                end)
                return { Set = function() end }
            end
            function TabObj:AddDropdown(dName, options, callback)
                if type(options) ~= "table" then options = {} end
                if type(callback) ~= "function" then callback = function() end end
                local flag = (dName .. "_" .. name):gsub("%s+","_")
                local cleanOpts = {}
                for _,v in ipairs(options) do if type(v)=="string" and v~="" then table.insert(cleanOpts, v) end end
                if #cleanOpts==0 then cleanOpts={"(No options)"} end
                local dd
                pcall(function()
                    dd = tab:CreateDropdown({
                        Name = dName,
                        Options = cleanOpts,
                        CurrentOption = {cleanOpts[1]},
                        MultipleOptions = true,
                        Flag = flag,
                        Callback = function(selected)
                            local map = {}
                            if type(selected)=="table" then
                                for _,opt in ipairs(selected) do map[opt]=true end
                            elseif type(selected)=="string" then
                                map[selected]=true
                            end
                            pcall(callback, map)
                            if type(selected)=="string" then pcall(callback, selected) end
                        end
                    })
                end)
                local obj = {}
                function obj:SetOptions(newOpts)
                    pcall(function()
                        if dd and dd.Refresh then dd:Refresh(newOpts)
                        elseif dd and dd.Set then dd:Set(newOpts)
                        elseif dd and dd.UpdateOptions then dd:UpdateOptions(newOpts)
                        end
                    end)
                end
                function obj:UpdateOptions(newOpts) self:SetOptions(newOpts) end
                function obj:Refresh(newOpts) self:SetOptions(newOpts) end
                function obj:ClearSelection()
                    pcall(function()
                        if dd and dd.Clear then dd:Clear()
                        elseif dd and dd.Set then dd:Set({cleanOpts[1]})
                        end
                    end)
                end
                function obj:Clear() self:ClearSelection() end
                function obj:Set(...) local args={...}; pcall(function() if dd and dd.Set then dd:Set(table.unpack(args)) end end) end
                return obj
            end
            function TabObj:AddSeparator()
                pcall(function() tab:CreateSection("") end)

            end
            function TabObj:AddLabel(text)
                local ok = pcall(function() tab:CreateLabel(tostring(text)) end)
                if not ok then pcall(function() tab:CreateSection(tostring(text)) end) end
                pcall(function() tab:CreateParagraph({Title=tostring(text), Content=""}) end)
            end
            function TabObj:AddButton(bName, callback)
                if type(callback) ~= "function" then callback = function() end end
                pcall(function()
                    tab:CreateButton({
                        Name = bName,
                        Callback = function() pcall(callback) end
                    })
                end)
                return { Set = function() end }
            end
            function TabObj:AddColorPicker(cName, color, callback)
                if type(callback) ~= "function" then callback = function() end end
                local flag = (cName .. "_" .. name):gsub("%s+","_")
                pcall(function()
                    tab:CreateColorPicker({
                        Name = cName,
                        Color = color,
                        Flag = flag,
                        Callback = function(v) pcall(callback, v) end
                    })
                end)
                return { Set = function() end }
            end
            TabObj.AddToggle = TabObj.AddToggle
            TabObj.AddSlider = TabObj.AddSlider
            TabObj.AddDropdown = TabObj.AddDropdown
            TabObj.AddSeparator = TabObj.AddSeparator
            TabObj.AddLabel = TabObj.AddLabel
            TabObj.AddButton = TabObj.AddButton
            TabObj.AddColorPicker = TabObj.AddColorPicker
            return TabObj
        end
        return WindowObj
    end
    return shimLib

end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end)

local Library = createSymbioteShim("Be a Lucky Block")

local CHAR_CF  = CFrame.new(Vector3.new(703.78363, 38.7145729, -2121.90601)) * CFrame.fromMatrix(Vector3.new(0,0,0), Vector3.new(-0.0118755223, 3.96514359e-08, -0.999929488), Vector3.new(2.69361937e-08, 1, -2.64671787e-08))
local THIRD_CF = CFrame.new(Vector3.new(733.78363, 38.7145729, -2121.90601)) * CFrame.fromMatrix(Vector3.new(0,0,0), Vector3.new(-0.0118755223, 3.96514359e-08, -0.999929488), Vector3.new(2.69361937e-08, 1, -2.64671787e-08))

local MODEL_CF = nil
local selectedCollectZoneName = nil

local function getModelCF()
    if MODEL_CF then return MODEL_CF end
    return CFrame.new(Vector3.new(-540.858429, 38.2805481, -2121.86865)) * CFrame.fromMatrix(Vector3.new(0,0,0), Vector3.new(0.00478558522, 3.32576744e-09, -0.999988556), Vector3.new(6.5336053e-08, 1, -6.53527152e-08))
end

local Window = Library:CreateWindow({
    Title = "  Symbiote ",
    Size = UDim2.new(0, 580, 0, 420),
})

local PlayerTab   = Window:CreateTab("Player")
local AutoFarmTab = Window:CreateTab("Auto Farm")
local AutoSellTab = Window:CreateTab("Auto Sell")

PlayerTab:AddSlider("Walk Speed", 16, 200, 16, function(val)
    if Humanoid then Humanoid.WalkSpeed = val end
end)

PlayerTab:AddSlider("Jump Height", 7, 200, 7, function(val)
    if Humanoid then Humanoid.JumpHeight = val end
end)

local flySpeedValue = 80
PlayerTab:AddSlider("Fly Speed", 10, 300, 80, function(val)
    flySpeedValue = val
end)

local flyEnabled    = false
local flyConnection = nil
local flyBodyVelocity, flyBodyGyro

PlayerTab:AddToggle("Fly", function(state)
    flyEnabled = state
    if state then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity  = Vector3.new(0,0,0)
        flyBodyVelocity.MaxForce  = Vector3.new(1e5,1e5,1e5)
        flyBodyVelocity.Parent    = HRP

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
        flyBodyGyro.P         = 1e4
        flyBodyGyro.Parent    = HRP

        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local cam = workspace.CurrentCamera
            local uis = game:GetService("UserInputService")
            local dir = Vector3.new(0,0,0)

            if uis:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cam.CFrame.LookVector  end
            if uis:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cam.CFrame.LookVector  end
            if uis:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0)     end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0)     end

            if dir.Magnitude > 0 then dir = dir.Unit end
            flyBodyVelocity.Velocity = dir * flySpeedValue
            flyBodyGyro.CFrame       = cam.CFrame
            Humanoid.PlatformStand   = true
        end)
    else
        Humanoid.PlatformStand = false
        if flyConnection   then flyConnection:Disconnect();   flyConnection   = nil end
        if flyBodyVelocity then flyBodyVelocity:Destroy();    flyBodyVelocity = nil end
        if flyBodyGyro     then flyBodyGyro:Destroy();        flyBodyGyro     = nil end
    end
end)

local autoUpgradeSpeedEnabled = false
PlayerTab:AddToggle("Auto Upgrade Speed", function(state)
    autoUpgradeSpeedEnabled = state
    if state then
        task.spawn(function()
            while autoUpgradeSpeedEnabled do
                pcall(function()
                    local Event = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.UpgradesService.RF.Upgrade
                    Event:InvokeServer("MovementSpeed", 10)
                end)
                task.wait(0.1)
            end
        end)
    end
end)

local autoRebirthEnabled = false
PlayerTab:AddToggle("Auto Rebirth", function(state)
    autoRebirthEnabled = state
    if state then
        task.spawn(function()
            while autoRebirthEnabled do
                pcall(function()
                    local Event = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.RebirthService.RF.Rebirth
                    Event:InvokeServer()
                end)
                task.wait(0.3)
            end
        end)
    end
end)

local autoCollectEnabled = false
PlayerTab:AddToggle("Auto Collect Cash", function(state)
    autoCollectEnabled = state
    if state then
        task.spawn(function()
            while autoCollectEnabled do
                pcall(function()
                    local playerName = LocalPlayer.Name
                    local Plots = workspace:FindFirstChild("Plots")
                    if Plots then
                        for _, part in ipairs(Plots:GetChildren()) do
                            for _, model in ipairs(part:GetChildren()) do
                                if model:IsA("Model") then
                                    local billGui = model:FindFirstChild(playerName .. "_FloatingPlotSign")
                                    if billGui then
                                        local containers = model:FindFirstChild("Containers")
                                        if containers then
                                            for _, containerPart in ipairs(containers:GetChildren()) do
                                                for _, innerModel in ipairs(containerPart:GetChildren()) do
                                                    if innerModel:IsA("Model") then

                                                        local collectionModel = innerModel:FindFirstChild("Collection")
                                                        if collectionModel then
                                                            local collectionPad = collectionModel:FindFirstChild("CollectionPad")
                                                            if collectionPad then
                                                                firetouchinterest(HRP, collectionPad, 0)
                                                                task.wait(0.05)
                                                                firetouchinterest(HRP, collectionPad, 1)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

local avoidBossEnabled = false
local bossTouchDetectParts = {}

local function setBossTouchDetect(canTouch)
    pcall(function()
        local BossTouchDetect = workspace:FindFirstChild("BossTouchDetectors")
        if BossTouchDetect then
            bossTouchDetectParts = {}
            for _, part in ipairs(BossTouchDetect:GetDescendants()) do
                if part:IsA("BasePart") then
                    table.insert(bossTouchDetectParts, part)
                    part.CanTouch = canTouch
                end
            end
        end
    end)
end

PlayerTab:AddToggle("Avoid Boss Catching", function(state)
    avoidBossEnabled = state
    setBossTouchDetect(not state)

end)

local collectZoneOptions     = {}
local collectZoneDropRef     = nil
local collectZoneInternalMap = {}

local function formatZoneName(rawName)
    local num = rawName:match("^[Bb]ase(%d+)$")
    if num then
        return "Base " .. tostring(tonumber(num))
    end
    return rawName
end

local function sortZoneNames(names)
    local baseNames  = {}
    local otherNames = {}

    for _, name in ipairs(names) do
        local num = name:match("^[Bb]ase(%d+)$")
        if num then
            table.insert(baseNames, { raw = name, num = tonumber(num) })
        else
            table.insert(otherNames, name)
        end

    end

    table.sort(baseNames, function(a, b)
        return a.num < b.num
    end)

    table.sort(otherNames, function(a, b)
        return a < b
    end)

    local sorted = {}
    for _, entry in ipairs(baseNames) do
        table.insert(sorted, entry.raw)
    end
    for _, name in ipairs(otherNames) do
        table.insert(sorted, name)
    end

    return sorted
end

local function buildDisplayOptions(sortedRawNames)
    local displayList    = {}
    local displayToRaw   = {}
    local rawToDisplay   = {}

    for _, rawName in ipairs(sortedRawNames) do
        local displayName = formatZoneName(rawName)
        table.insert(displayList, displayName)
        displayToRaw[displayName] = rawName
        rawToDisplay[rawName]     = displayName
    end

    return displayList, displayToRaw, rawToDisplay
end

local displayToRaw = {}
local rawToDisplay = {}

local function getCollectZoneNames()
    local names = {}
    pcall(function()
        local CollectZones = workspace:FindFirstChild("CollectZones")
        if CollectZones then
            for _, part in ipairs(CollectZones:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("Model") or part:IsA("Folder") then
                    table.insert(names, part.Name)
                end
            end
        end
    end)
    return names

end

local function updateModelCFFromZone(zoneName)
    pcall(function()
        local CollectZones = workspace:FindFirstChild("CollectZones")
        if CollectZones then
            local zone = CollectZones:FindFirstChild(zoneName)

            if zone then
                if zone:IsA("BasePart") then
                    MODEL_CF = zone.CFrame * CFrame.new(0, -10, 0)
                elseif zone:IsA("Model") and zone.PrimaryPart then

                    MODEL_CF = zone.PrimaryPart.CFrame * CFrame.new(0, -10, 0)
                end

            end
        end
    end)
end

local rawNames = getCollectZoneNames()
local sortedRawNames = sortZoneNames(rawNames)
local displayList

displayList, displayToRaw, rawToDisplay = buildDisplayOptions(sortedRawNames)
collectZoneOptions = displayList

collectZoneDropRef = AutoFarmTab:AddDropdown(
    "Select Collect Zone",
    collectZoneOptions,
    function(selectedMap)
        local count = 0
        for _ in pairs(selectedMap) do count = count + 1 end

        if count == 0 then
            selectedCollectZoneName  = nil
            MODEL_CF                 = nil
            collectZoneInternalMap   = {}

        elseif count == 1 then
            for displayKey in pairs(selectedMap) do
                local rawKey = displayToRaw[displayKey] or displayKey
                selectedCollectZoneName = rawKey
                updateModelCFFromZone(rawKey)
            end
            collectZoneInternalMap = {}
            local displayKey = rawToDisplay[selectedCollectZoneName] or selectedCollectZoneName
            collectZoneInternalMap[displayKey] = true

        else
            local newDisplayKey = nil
            for k in pairs(selectedMap) do
                if not collectZoneInternalMap[k] then
                    newDisplayKey = k
                    break
                end

            end

            if newDisplayKey then
                local rawKey = displayToRaw[newDisplayKey] or newDisplayKey
                selectedCollectZoneName = rawKey
                updateModelCFFromZone(rawKey)
                collectZoneInternalMap = { [newDisplayKey] = true }

                for k in pairs(selectedMap) do
                    selectedMap[k] = nil
                end
                selectedMap[newDisplayKey] = true

                if collectZoneDropRef then
                    collectZoneDropRef:SetOptions(collectZoneOptions)
                end
            end
        end
    end
)

task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            local newRawNames = getCollectZoneNames()
            local newSorted   = sortZoneNames(newRawNames)
            local newDisplay, newDTR, newRTD = buildDisplayOptions(newSorted)

            local changed = (#newDisplay ~= #collectZoneOptions)
            if not changed then
                local nameSet = {}
                for _, n in ipairs(collectZoneOptions) do nameSet[n] = true end
                for _, n in ipairs(newDisplay) do
                    if not nameSet[n] then changed = true break end
                end
            end

            if changed then
                collectZoneOptions = newDisplay
                displayToRaw       = newDTR
                rawToDisplay       = newRTD

                local stillExists = false
                if selectedCollectZoneName then
                    for _, rawN in ipairs(newSorted) do
                        if rawN == selectedCollectZoneName then
                            stillExists = true
                            break
                        end
                    end
                end

                if not stillExists then
                    selectedCollectZoneName = nil
                    MODEL_CF               = nil
                    collectZoneInternalMap = {}
                end

                if collectZoneDropRef then
                    collectZoneDropRef:SetOptions(collectZoneOptions)
                end
            else
                if selectedCollectZoneName then
                    updateModelCFFromZone(selectedCollectZoneName)
                end
            end
        end)
    end
end)

local autoFarmEnabled = false
AutoFarmTab:AddToggle("Auto Farm", function(state)
    autoFarmEnabled = state
    if state then
        task.spawn(function()
            while autoFarmEnabled do
                local userId        = tostring(LocalPlayer.UserId)
                local RunningModels = workspace:FindFirstChild("RunningModels")

                HRP.CFrame = CHAR_CF
                wait(1)

                local targetModel = RunningModels and RunningModels:FindFirstChild(userId)

                if targetModel then
                    local modelHRP = targetModel:FindFirstChild("HumanoidRootPart")
                    if modelHRP then
                        modelHRP.CFrame = getModelCF()
                    end

                    local elapsed     = 0
                    local interval    = 0.1
                    local animateGone = false

                    while elapsed < 10 and autoFarmEnabled do
                        task.wait(interval)
                        elapsed = elapsed + interval
                        if not Character:FindFirstChild("Animate") then
                            animateGone = true
                            break
                        end
                    end

                    if animateGone then
                        HRP.CFrame = THIRD_CF
                        task.wait(0.5)
                        continue
                    else
                        if modelHRP then
                            modelHRP.CFrame = getModelCF()
                        end
                    end
                end

                task.wait(0.1)
            end
        end)
    end
end)

local autoFarmEggEnabled = false
AutoFarmTab:AddToggle("Auto Farm Easter Egg", function(state)
    autoFarmEggEnabled = state

    if state then
        task.spawn(function()
            while autoFarmEggEnabled do
                local eggModels = {}
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj.Name:match("^EGG") then
                        table.insert(eggModels, obj)
                    end
                end

                local userId        = tostring(LocalPlayer.UserId)
                local RunningModels = workspace:FindFirstChild("RunningModels")
                local targetModel   = RunningModels and RunningModels:FindFirstChild(userId)
                local modelHRP      = targetModel and targetModel:FindFirstChild("HumanoidRootPart")

                if #eggModels == 0 then
                    if modelHRP then modelHRP.CFrame = CHAR_CF end
                    task.wait(0.3)
                    if not autoFarmEggEnabled then break end
                    HRP.CFrame = THIRD_CF
                    while autoFarmEggEnabled do
                        local found = false
                        for _, obj in ipairs(workspace:GetChildren()) do
                            if obj:IsA("Model") and obj.Name:match("^EGG") then
                                found = true
                                break
                            end
                        end
                        if found then break end
                        HRP.CFrame = THIRD_CF
                        task.wait(0.4)
                    end
                    continue
                end

                HRP.CFrame = CHAR_CF

                task.wait(0.1)

                if not targetModel or not modelHRP then
                    task.wait(0.3)
                    continue
                end

                for _, eggModel in ipairs(eggModels) do
                    if not autoFarmEggEnabled then break end
                    local eggHRP = eggModel:FindFirstChild("HumanoidRootPart")
                    if eggHRP then
                        modelHRP.CFrame = eggHRP.CFrame
                        task.wait(0.07)
                    end
                end

                if autoFarmEggEnabled then
                    if modelHRP then modelHRP.CFrame = getModelCF() end
                    task.wait(2)
                    if not autoFarmEggEnabled then break end
                    HRP.CFrame = THIRD_CF
                end

                task.wait(0.3)
            end

        end)
    end
end)

local selectedMutations = {}

local selectedMinCashKey   = nil
local selectedMinCashValue = nil

local cashOptionValues = {
    ["100K"] = 1e5,
    ["1M"]   = 1e6,
    ["10M"]  = 1e7,
    ["1B"]   = 1e9,
    ["100B"] = 1e11,
    ["1T"]   = 1e12,
}

local function parseCashPerSec(str)
    if not str or str == "" then return 0 end

    local numStr = tostring(str):match("^%+?([%d%.]+%a?)%$")
    if not numStr then return 0 end

    local suffixes = {
        K = 1e3,
        M = 1e6,
        B = 1e9,
        T = 1e12,
        Q = 1e15,
    }

    local num, suf = numStr:match("^([%d%.]+)([KMBTQkmbtq]?)$")
    if not num then return 0 end

    local value = tonumber(num) or 0
    if suf and suf ~= "" then
        local mult = suffixes[suf:upper()]
        if mult then value = value * mult end
    end

    return value
end

AutoSellTab:AddDropdown("Select Mutation", {"NORMAL", "CANDY", "GOLD", "DIAMOND", "VOID"}, function(selectedMap)
    selectedMutations = selectedMap
end)

local minCashOptions = {"100K", "1M", "10M", "1B", "100B", "1T"}

local minCashDropdownRef = nil

local minCashInternalMap = {}

minCashDropdownRef = AutoSellTab:AddDropdown(
    "Select Minimum Cash",
    minCashOptions,
    function(selectedMap)
        local count = 0
        for _ in pairs(selectedMap) do count = count + 1 end

        if count == 0 then

            selectedMinCashKey   = nil
            selectedMinCashValue = nil
            minCashInternalMap   = {}

        elseif count == 1 then
            for k in pairs(selectedMap) do
                selectedMinCashKey   = k
                selectedMinCashValue = cashOptionValues[k]
            end
            minCashInternalMap = {}
            minCashInternalMap[selectedMinCashKey] = true

        else
            local newKey = nil
            for k in pairs(selectedMap) do
                if not minCashInternalMap[k] then
                    newKey = k
                    break
                end
            end

            if newKey then
                selectedMinCashKey   = newKey
                selectedMinCashValue = cashOptionValues[newKey]
                minCashInternalMap   = { [newKey] = true }

                for k in pairs(selectedMap) do
                    selectedMap[k] = nil
                end
                selectedMap[newKey] = true

                if minCashDropdownRef then
                    minCashDropdownRef:SetOptions(minCashOptions)
                end
            end
        end
    end
)

local autoSellEnabled  = false
local autoSellRunning  = false

AutoSellTab:AddToggle("Auto Sell", function(state)
    autoSellEnabled = state

    if state and not autoSellRunning then
        autoSellRunning = true
        task.spawn(function()
            while autoSellEnabled do
                pcall(function()
                    local hasMutationFilter = false
                    for _ in pairs(selectedMutations) do
                        hasMutationFilter = true
                        break
                    end

                    local hasCashFilter = (selectedMinCashValue ~= nil)

                    if not hasMutationFilter and not hasCashFilter then
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        if backpack and #backpack:GetChildren() > 0 then
                            local Event = ReplicatedStorage.Packages
                                ._Index["sleitnick_knit@1.7.0"]
                                .knit.Services.InventoryService.RF.SellAllBrainrots
                            Event:InvokeServer()
                        end
                    else
                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                        if not backpack then return end

                        local SellEvent = ReplicatedStorage.Packages
                            ._Index["sleitnick_knit@1.7.0"]
                            .knit.Services.InventoryService.RF.SellBrainrot

                        local tools = backpack:GetChildren()

                        for _, tool in ipairs(tools) do
                            if not autoSellEnabled then break end
                            if not tool:IsA("Tool") then continue end

                            local entityId = tool:GetAttribute("EntityId")
                            if not entityId then continue end

                            local mutation   = tool:GetAttribute("Mutation")
                            local cashPerSec = tool:GetAttribute("CashPerSec")

                            local passedMutation = true
                            local passedCash     = true

                            if hasMutationFilter then
                                passedMutation = (mutation ~= nil and selectedMutations[tostring(mutation)] == true)
                            end

                            if hasCashFilter then
                                local cashValue = parseCashPerSec(tostring(cashPerSec))
                                passedCash = (cashValue < selectedMinCashValue)
                            end

                            if passedMutation and passedCash then

                                pcall(function()
                                    SellEvent:InvokeServer(entityId)
                                end)
                                task.wait(0.05)
                            end
                        end

                    end
                end)

                task.wait(0.5)
            end

            autoSellRunning = false
        end)
    end
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})