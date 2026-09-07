-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Booga Booga
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
                local ok2, _ = pcall(function()
                    return tab:CreateToggle({
                        Name = tName,
                        CurrentValue = default,
                        Flag = flag,
                        Callback = function(v) pcall(callback, v) end
                    })
                end)
                return { Set = function() end, SetValue=function() end }
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

local Library = createSymbioteShim("Booga Booga")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local IS_ALT_PLACE = (game.PlaceId == 11879754496)
local PLANT_BOX_SPACING        = 3
local PLANT_BOX_PLACE_MAX_DIST = 30
local WALKSPEED_MAX_SPEED      = 0.025
local PLANT_SCAN_DIST          = 100
local PLANT_FIRE_DIST          = 30
local MAX_DIST                 = 20
local PLANT_BOX_PLACE_DELAY    = 0.15
local PLANT_BOX_MOVE_TIMEOUT   = 8
local COIN_PRESS_MAX_DIST      = 20
local ESP_STUDS_OFFSET_WORLD   = Vector3.new(0, 2.5, 0)
local KILL_AURA_DIST           = 20
local HIT_DIST                 = 20

local STRUCTURE_FOLDERS = {"Totems","Rubble","ScavangerMounds","Mounds","Deployables"}

local WallOptions = {
    "Wood Wall","Ice Wall","Stone Wall","Iron Wall","Adurite Wall",
    "Crystal Wall","Obsidian Wall","Magnetite Wall","Emerald Wall"
}

local KeybindMap = {
    ["H"] = Enum.KeyCode.H, ["J"] = Enum.KeyCode.J,
    ["G"] = Enum.KeyCode.G, ["Q"] = Enum.KeyCode.Q,
    ["E"] = Enum.KeyCode.E, ["R"] = Enum.KeyCode.R,
    ["U"] = Enum.KeyCode.U,
}

local ArmorPrefixes = {
    "Leaf","Hide","Iron","Steel","Adurite",
    "Crystal","Magnetite","Emerald","Pink Diamond","Void","God"
}

local CollectableItems = {
    "Adurite","Coal","Cooked Meat","Crystal Chunk","Egg","Emerald","Essence",
    "Gold","Hide","Ice Cube","Iron","Jelly","Leaves","Log","Magnetite",
    "Pink Diamond","Raw Adurite","Raw Emerald","Raw Gold","Raw Iron","Raw Magnetite",
    "Raw Meat","Raw Steel","Spirit Key","Steel","Stone","Void Shard","Wood"
}

local PlantableItems = {
    "Berry","Orange","Lemon","Bloodfruit","Apple",
    "Sunfruit","Carrot","Bluefruit","Jelly"
}

local HealItems = {
    "Bloodfruit","Berry","Lemon","Orange","Bluefruit","Orange",
    "Carrot","Sunfruit","Cooked Meat","Cooked Morsel","Cooked Fish",
    "Cooked Egg","Cloudberry","Banana","Pumpkin"
}

local PlantItemIDs = {
    ["Berry"]      = {0x23, 0x00},
    ["Orange"]     = {0x5A, 0x02},
    ["Lemon"]      = {0x63, 0x00},
    ["Bloodfruit"] = {0x5E, 0x00},
    ["Apple"]      = {0xF3, 0x00},
    ["Sunfruit"]   = {0x80, 0x00},
    ["Carrot"]     = {0x95, 0x00},
    ["Bluefruit"]  = {0x79, 0x01},
    ["Jelly"]      = {0x5C, 0x02},
}

local HealFrequencySteps = {0.002, 0.03, 0.05, 0.1, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 1.0}

local S = {
    FlyEnabled = false, NoClipEnabled = false,
    FlyConn = nil, FlyBV = nil, FlyBG = nil, FlySpeed = 50,
    NoClipConn = nil,
    LaggyRun = false, LaggyDelay = 1,
    LaggyConn = nil, LaggyAccum = 0,
    AutoCollect = false, AutoCollectFromChest = false,
    AutoDrop = false, AutoHitResources = false,
    AutoHitMobs = false, AutoHitStructures = false,
    KillAura = false, AimlockClosest = false,
    FollowNearest = false, AutoPlant = false,
    AutoPlantMove = false, AutoHarvest = false,
    AutoHarvestMove = false, AutoHeal = false, MinHealHealth = 99,
    HealFrequency = 0.002,
    WaterWalker = false, UnlockMojos = false,
    AutoPressCoin = false, AutoVoodooBolt = false,
    PlayerESP = false, ESPLines = false, ESPArmorEnabled = false,
    PlayerESPObjs = {}, ESPLineObjs = {}, ESPLinesGui = nil,
    LockCamera = false, SpectateTarget = nil, SpectateEnabled = false,
    AutoPlacePlantBox = false, AutoPlacePlantBoxRunning = false,
    AutoHutEnabled = false, AutoHutKeybind = nil,
    AutoDockEnabled = false, AutoDockKeybind = nil,
    MountainClimber = false, MountainClimberOrigAngle = nil,
    WalkSpeedEnabled = false, WalkSpeedValue = 0.3,
    WalkSpeedConnection = nil,
    GodESP = false, ItemESP = false, MeteorESP = false,
    MerchantESP = false, NodesESP = false,
    GodESPObjs = {}, ItemESPObjs = {}, MeteorESPObjs = {},
    MerchantESPObjs = {}, NodesESPObjs = {},
    FullBright = false, FullBrightLight = nil,
}

local SelectedCollectables = {}
local SelectedDropItems = {}
local SelectedPlantItems = {}
local SelectedHealItems = {}
local DropItemsSet = {}
local _dropDDRef = nil
local _invListConn = nil
local _invListChildConns = {}
local _spectateDDRef = nil
local _lastSpectateNames = {}

local function NewInst(cls, props, parent)
    local i = Instance.new(cls)
    for k, v in pairs(props) do i[k] = v end
    if parent then i.Parent = parent end
    return i
end

local function GetPlayerHRP()
    local pf = Workspace:FindFirstChild("Players")
    if pf then
        local lm = pf:FindFirstChild(LocalPlayer.Name)
        if lm then
            local hrp = lm:FindFirstChild("HumanoidRootPart") or lm:FindFirstChildWhichIsA("BasePart")
            if hrp then return hrp end
        end
    end

    local char = LocalPlayer.Character
    if char then

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then return hrp end
    end
    return nil
end

local function GetPlayerPosition()
    local hrp = GetPlayerHRP()
    return hrp and hrp.Position or nil
end

local function FindPlayerModel(player)
    local f = Workspace:FindFirstChild("Players")
    return f and f:FindFirstChild(player.Name)
end

local function GetPlayerHumanoid()
    local pf = Workspace:FindFirstChild("Players")
    if pf then
        local lm = pf:FindFirstChild(LocalPlayer.Name)
        if lm then
            local hum = lm:FindFirstChild("Humanoid")
            if hum then return hum end
        end
    end
    local char = LocalPlayer.Character

    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then return hum end
    end
    return nil
end

local function GetModelPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    local pp = obj.PrimaryPart
    if pp then return pp.Position end
    for _, ch in ipairs(obj:GetChildren()) do
        if ch:IsA("BasePart") then return ch.Position end
    end
    return nil
end

local function GetPlayerArmor(playerModel)
    if not playerModel then return nil end

    local counts = {}
    for _, prefix in ipairs(ArmorPrefixes) do counts[prefix] = 0 end
    for _, child in ipairs(playerModel:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            for _, prefix in ipairs(ArmorPrefixes) do
                if child.Name:sub(1, #prefix) == prefix then
                    counts[prefix] = counts[prefix] + 1
                    break
                end
            end
        end
    end
    for _, prefix in ipairs(ArmorPrefixes) do
        if counts[prefix] >= 3 then return prefix .. " Armor" end

    end
    return nil
end

local function GetFireEvent()
    return ReplicatedStorage:FindFirstChild("ByteNetReliable")
end

local function GetInventoryList()

    local ok, list = pcall(function()
        return LocalPlayer.PlayerGui.MainGui.RightPanel.Inventory.List
    end)
    if ok and list then return list end
    return nil
end

local function GetInventoryItems()
    local result = {}
    local list = GetInventoryList()
    if not list then return result end
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("ImageLabel") then
            local lo = child.LayoutOrder
            if not result[child.Name] or lo < result[child.Name] then
                result[child.Name] = lo
            end
        end
    end
    return result

end

local function UpdateDropDD()
    if not _dropDDRef then return end
    local names = {}
    for name in pairs(DropItemsSet) do table.insert(names, name) end
    table.sort(names)
    if #names == 0 then names = {"(BoÅŸ)"} end
    pcall(function()
        if _dropDDRef.UpdateOptions then _dropDDRef:UpdateOptions(names)
        elseif _dropDDRef.SetOptions then _dropDDRef:SetOptions(names)
        elseif _dropDDRef.Refresh then _dropDDRef:Refresh(names) end
    end)
end

local function WatchInventoryList()
    if _invListConn then
        pcall(function() _invListConn:Disconnect() end)
        _invListConn = nil
    end
    for _, c in pairs(_invListChildConns) do
        pcall(function() c:Disconnect() end)
    end
    _invListChildConns = {}
    local list = GetInventoryList()
    if not list then return end
    for name in pairs(GetInventoryItems()) do
        DropItemsSet[name] = true
    end
    UpdateDropDD()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("ImageLabel") then
            local conn = child:GetPropertyChangedSignal("LayoutOrder"):Connect(function() end)
            table.insert(_invListChildConns, conn)

        end
    end
    _invListConn = list.ChildAdded:Connect(function(child)
        if not child:IsA("ImageLabel") then return end
        if not DropItemsSet[child.Name] then
            DropItemsSet[child.Name] = true
            UpdateDropDD()
        end
        local conn = child:GetPropertyChangedSignal("LayoutOrder"):Connect(function() end)
        table.insert(_invListChildConns, conn)
    end)
    local removeConn = list.ChildRemoved:Connect(function(child)
        if not child:IsA("ImageLabel") then return end
        local name = child.Name
        local stillExists = false
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("ImageLabel") and c.Name == name then stillExists = true; break end
        end
        if not stillExists then
            DropItemsSet[name] = nil
            SelectedDropItems[name] = nil
            UpdateDropDD()
        end
    end)
    table.insert(_invListChildConns, removeConn)
end

task.spawn(function()
    task.wait(2)
    WatchInventoryList()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        WatchInventoryList()
    end)
end)

local function GetLayoutOrder(itemName)
    local list = GetInventoryList()
    if not list then return nil end
    local bestLO = nil
    for _, child in ipairs(list:GetChildren()) do

        if child:IsA("ImageLabel") and child.Name == itemName then
            local lo = child.LayoutOrder
            if bestLO == nil or lo < bestLO then bestLO = lo end
        end
    end
    return bestLO
end

task.spawn(function()
    task.wait(0.5)
    local ok, Event = pcall(function()
        return ReplicatedStorage:WaitForChild("Events", 5):WaitForChild("Notify", 5)
    end)
    if not ok or not Event then return end
    local function tryFire()
        if typeof(firesignal) == "function" then
            for i = 1, 3 do
                pcall(firesignal, Event.OnClientEvent, "Symbiote", Color3.new(0.5, 0, 0.8), 3)
                if i < 3 then task.wait(0.1) end
            end
            return true
        end
        if typeof(getconnections) == "function" then
            for i = 1, 3 do
                pcall(function()
                    for _, conn in pairs(getconnections(Event.OnClientEvent)) do
                        if conn.Function then conn.Function("Symbiote", Color3.new(0.5, 0, 0.8), 3) end
                    end
                end)
                if i < 3 then task.wait(0.1) end
            end
            return true
        end
        return false
    end
    if not tryFire() then
        pcall(function()
            for i = 1, 3 do
                Event.OnClientEvent:Fire("Symbiote", Color3.new(0.5, 0, 0.8), 3)
                if i < 3 then task.wait(0.1) end
            end
        end)
    end
end)

local function EnableFullBright()
    if S.FullBrightLight then
        pcall(function() S.FullBrightLight:Destroy() end)
        S.FullBrightLight = nil
    end

    local pf = Workspace:FindFirstChild("Players")
    if not pf then return end
    local lm = pf:FindFirstChild(LocalPlayer.Name)
    if not lm then return end
    local head = lm:FindFirstChild("Head")
    if not head then return end
    local light = Instance.new("PointLight")
    light.Brightness = 1.5
    light.Color = Color3.fromRGB(255, 255, 255)
    light.Range = 1000
    light.Parent = head
    S.FullBrightLight = light
end

local function DisableFullBright()
    if S.FullBrightLight then
        pcall(function() S.FullBrightLight:Destroy() end)
        S.FullBrightLight = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if S.FullBright then EnableFullBright() end

end)

local function EnsureNoClip()
    local ch = LocalPlayer.Character
    if not ch then return end
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end

local function EnableNoClip()
    if S.NoClipConn then return end
    S.NoClipConn = RunService.Stepped:Connect(function()
        if S.NoClipEnabled then EnsureNoClip() end
    end)
end

local function DisableNoClip()
    if S.NoClipConn then S.NoClipConn:Disconnect(); S.NoClipConn = nil end
    local ch = LocalPlayer.Character
    if not ch then return end
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = true end
    end
end

local function EnableFly()

    local ch = LocalPlayer.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if S.FlyBV then S.FlyBV:Destroy() end
    if S.FlyBG then S.FlyBG:Destroy() end
    S.FlyBV = NewInst("BodyVelocity", {Velocity=Vector3.new(0,0,0), MaxForce=Vector3.new(9e9,9e9,9e9)}, hrp)
    S.FlyBG = NewInst("BodyGyro", {MaxTorque=Vector3.new(9e9,9e9,9e9), P=9e4}, hrp)
    if S.FlyConn then S.FlyConn:Disconnect() end
    S.FlyConn = RunService.Heartbeat:Connect(function()
        if not S.FlyEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart")
        if not h or not S.FlyBV or not S.FlyBG then return end
        local cam = Workspace.CurrentCamera
        local spd = S.FlySpeed
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, spd, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, spd, 0) end
        S.FlyBV.Velocity = dir
        S.FlyBG.CFrame = cam.CFrame
    end)
end

local function DisableFly()
    if S.FlyConn then S.FlyConn:Disconnect(); S.FlyConn = nil end
    if S.FlyBV then S.FlyBV:Destroy(); S.FlyBV = nil end
    if S.FlyBG then S.FlyBG:Destroy(); S.FlyBG = nil end
end

local function EnableLaggy()
    if S.LaggyConn then S.LaggyConn:Disconnect() end
    S.LaggyAccum = 0
    S.LaggyConn = RunService.Heartbeat:Connect(function(dt)
        if not S.LaggyRun then return end
        local ch = LocalPlayer.Character
        if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = ch:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local md = hum.MoveDirection
        if md.Magnitude < 0.1 then S.LaggyAccum = 0; return end
        S.LaggyAccum = S.LaggyAccum + dt
        if S.LaggyAccum < S.LaggyDelay * 0.1 then return end
        S.LaggyAccum = 0
        local cf = hrp.CFrame
        hrp.CFrame = CFrame.fromMatrix(cf.Position + md.Unit, cf.RightVector, cf.UpVector, -cf.LookVector)
    end)
end

local function DisableLaggy()
    if S.LaggyConn then S.LaggyConn:Disconnect(); S.LaggyConn = nil end
    S.LaggyAccum = 0
end

local function EnableMountainClimber()
    local hum = GetPlayerHumanoid()
    if not hum then return end
    S.MountainClimberOrigAngle = hum.MaxSlopeAngle
    hum.MaxSlopeAngle = 89.9
end

local function DisableMountainClimber()
    local hum = GetPlayerHumanoid()
    if not hum then return end
    if S.MountainClimberOrigAngle ~= nil then
        hum.MaxSlopeAngle = S.MountainClimberOrigAngle
        S.MountainClimberOrigAngle = nil
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.MountainClimber then EnableMountainClimber() end
end)

local function EnableWalkSpeed()
    if S.WalkSpeedConnection then S.WalkSpeedConnection:Disconnect() end
    S.WalkSpeedConnection = RunService.Heartbeat:Connect(function()
        if not S.WalkSpeedEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        if hum.MoveDirection.Magnitude < 0.1 then return end

        local cf = hrp.CFrame
        hrp.CFrame = CFrame.fromMatrix(cf.Position + hum.MoveDirection.Unit * S.WalkSpeedValue, cf.RightVector, cf.UpVector, -cf.LookVector)
    end)
end

local function DisableWalkSpeed()

    if S.WalkSpeedConnection then S.WalkSpeedConnection:Disconnect(); S.WalkSpeedConnection = nil end
end

local _waterWalkerOrig = {mojoItems = nil, disabledMojo = nil}
local _WATER_WALKER_NAME = "Water Walker"

local function EnableWaterWalker()
    local ok, GameUtil = pcall(require, ReplicatedStorage.Modules.GameUtil)

    if not ok or not GameUtil then return end
    local data = GameUtil.Data
    if not data then return end
    data.mojoItems = data.mojoItems or {}
    data.disabledMojo = data.disabledMojo or {}
    _waterWalkerOrig.mojoItems = data.mojoItems[_WATER_WALKER_NAME]
    _waterWalkerOrig.disabledMojo = data.disabledMojo[_WATER_WALKER_NAME]
    data.mojoItems[_WATER_WALKER_NAME] = true
    data.disabledMojo[_WATER_WALKER_NAME] = false
    pcall(function()
        local mojos = require(ReplicatedStorage.Game.mojos)
        if mojos and mojos.start then mojos.start() end
    end)
end

local function DisableWaterWalker()
    local ok, GameUtil = pcall(require, ReplicatedStorage.Modules.GameUtil)
    if not ok or not GameUtil then return end
    local data = GameUtil.Data
    if not data then return end
    if _waterWalkerOrig.mojoItems ~= nil then
        data.mojoItems[_WATER_WALKER_NAME] = _waterWalkerOrig.mojoItems
    else data.mojoItems[_WATER_WALKER_NAME] = nil end
    if _waterWalkerOrig.disabledMojo ~= nil then
        data.disabledMojo[_WATER_WALKER_NAME] = _waterWalkerOrig.disabledMojo
    else data.disabledMojo[_WATER_WALKER_NAME] = nil end
    _waterWalkerOrig.mojoItems = nil
    _waterWalkerOrig.disabledMojo = nil
    pcall(function()
        local mojos = require(ReplicatedStorage.Game.mojos)
        if mojos and mojos.start then mojos.start() end
    end)
end

local _origMojoItems = nil
local _origDisabledMojo = nil

local function EnableUnlockAllMojos()
    local ok, GameUtil = pcall(require, ReplicatedStorage.Modules.GameUtil)
    if not ok or not GameUtil then return end
    local okIDS, ItemIDS = pcall(require, ReplicatedStorage.Modules.ItemIDS)
    if not okIDS or not ItemIDS then return end
    local data = GameUtil.Data
    if not data then return end
    data.mojoItems = data.mojoItems or {}
    data.disabledMojo = data.disabledMojo or {}
    _origMojoItems = {}
    _origDisabledMojo = {}
    for k, v in pairs(data.mojoItems) do _origMojoItems[k] = v end
    for k, v in pairs(data.disabledMojo) do _origDisabledMojo[k] = v end
    for itemName in pairs(ItemIDS) do
        data.mojoItems[itemName] = true
        data.disabledMojo[itemName] = false
    end
    pcall(function()
        local mojos = require(ReplicatedStorage.Game.mojos)
        if mojos and mojos.start then mojos.start() end
    end)
end

local function DisableUnlockAllMojos()
    local ok, GameUtil = pcall(require, ReplicatedStorage.Modules.GameUtil)
    if not ok or not GameUtil then return end
    local data = GameUtil.Data
    if not data or not _origMojoItems then return end
    for k in pairs(data.mojoItems) do data.mojoItems[k] = nil end
    for k in pairs(data.disabledMojo) do data.disabledMojo[k] = nil end
    for k, v in pairs(_origMojoItems) do data.mojoItems[k] = v end
    for k, v in pairs(_origDisabledMojo) do data.disabledMojo[k] = v end
    _origMojoItems = nil
    _origDisabledMojo = nil
    pcall(function()
        local mojos = require(ReplicatedStorage.Game.mojos)
        if mojos and mojos.start then mojos.start() end
    end)
end

local _hitCounter = 0

local function FireHitPacket(entityId, pos)
    local Event = GetFireEvent()
    if not Event then return end
    local px = pos and pos.X or 0
    local py = pos and pos.Y or 0
    local pz = pos and pos.Z or 0
    _hitCounter = (_hitCounter + 1) % 0x100000000
    local b = buffer.create(35)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 57)
    buffer.writef32(b, 2, px)
    buffer.writef32(b, 6, py)
    buffer.writef32(b, 10, pz)
    buffer.writeu8(b, 14, 0)
    buffer.writeu8(b, 15, 0)
    buffer.writeu8(b, 16, 0)
    buffer.writeu8(b, 17, 0)
    buffer.writeu8(b, 18, 0)
    buffer.writeu8(b, 19, 0)
    buffer.writeu8(b, 20, 1)
    buffer.writeu8(b, 21, 0)
    buffer.writeu8(b, 22, 0)
    buffer.writeu32(b, 23, entityId)
    buffer.writeu32(b, 27, _hitCounter)
    buffer.writeu8(b, 31, 251)
    buffer.writeu8(b, 32, 157)
    buffer.writeu8(b, 33, 218)
    buffer.writeu8(b, 34, 65)
    pcall(function() Event:FireServer(b, nil) end)
end

local function fireCollectRemote(entityId)
    local Event = GetFireEvent()
    if not Event then return end
    local b = buffer.create(6)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 59)
    buffer.writeu32(b, 2, entityId)
    pcall(function() Event:FireServer(b, nil) end)
end

local function fireHarvestRemote(entityId)
    local Event = GetFireEvent()
    if not Event then return end
    local b = buffer.create(6)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 59)
    buffer.writeu32(b, 2, entityId)
    pcall(function() Event:FireServer(b, nil) end)
end

local function firePlantRemote(entityId, itemName)
    local Event = GetFireEvent()
    if not Event then return end
    local idBytes = PlantItemIDs[itemName]
    if not idBytes then return end
    local plantId = idBytes[1] + idBytes[2] * 256
    local b = buffer.create(8)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 96)
    buffer.writeu32(b, 2, entityId)
    buffer.writeu16(b, 6, plantId)
    pcall(function() Event:FireServer(b, nil) end)
end

local function fireHealRemote(itemName)
    local lo = GetLayoutOrder(itemName)
    if not lo then return end
    local Event = GetFireEvent()
    if not Event then return end
    local b = buffer.create(4)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 67)
    buffer.writeu16(b, 2, lo)
    pcall(function() Event:FireServer(b, nil) end)
end

local function fireDropRemote(itemName)
    local lo = GetLayoutOrder(itemName)
    if not lo then return end
    local Event = GetFireEvent()
    if not Event then return end
    local b = buffer.create(4)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 66)
    buffer.writeu16(b, 2, lo)
    pcall(function() Event:FireServer(b, nil) end)
end

local function firePlaceStructureRemote(structureName, position)
    local Event = GetFireEvent()
    if not Event then return false end
    local nameLen = #structureName
    local totalLen = 2 + 2 + nameLen + 12 + 6
    local b = buffer.create(totalLen)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 79)
    buffer.writeu16(b, 2, nameLen)
    buffer.writestring(b, 4, structureName)
    local offset = 4 + nameLen
    buffer.writef32(b, offset, position.X)
    buffer.writef32(b, offset + 4, position.Y)
    buffer.writef32(b, offset + 8, position.Z)
    for i = 0, 5 do
        buffer.writeu8(b, offset + 12 + i, 0)
    end
    return pcall(function() Event:FireServer(b, nil) end)
end

local function fireCoinPressRemote(entityId)
    local Event = GetFireEvent()
    if not Event then return end
    local b = buffer.create(8)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 96)
    buffer.writeu32(b, 2, entityId)
    buffer.writeu16(b, 6, 597)
    pcall(function() Event:FireServer(b, nil) end)
end

local function fireVoodooBoltRemote(targetCFrame)
    local Event = GetFireEvent()
    if not Event then return end
    local myPos = GetPlayerPosition()
    local origin = myPos or (LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position) or Vector3.zero
    local targetPos = targetCFrame.Position
    local dir = (targetPos - origin).Magnitude > 0.001 and (targetPos - origin).Unit or Vector3.new(0, 0, 1)
    local b = buffer.create(26)
    buffer.writeu8(b, 0, 0)
    buffer.writeu8(b, 1, 130)
    buffer.writef32(b, 2, dir.X)
    buffer.writef32(b, 6, dir.Y)
    buffer.writef32(b, 10, dir.Z)
    buffer.writef32(b, 14, origin.X)
    buffer.writef32(b, 18, origin.Y)
    buffer.writef32(b, 22, origin.Z)
    pcall(function() Event:FireServer(b, nil) end)
end

local function GetGroundY(x, z)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local excludeList = {}
    local char = LocalPlayer.Character
    if char then table.insert(excludeList, char) end

    local pf = Workspace:FindFirstChild("Players")
    if pf then table.insert(excludeList, pf) end
    params.FilterDescendantsInstances = excludeList
    local result = Workspace:Raycast(Vector3.new(x, 500, z), Vector3.new(0, -1000, 0), params)
    return result and result.Position.Y or -6.0

end

local function GetVoodooValue()
    local ok, val = pcall(function()
        return LocalPlayer.PlayerGui.MainGui.Panels.Stats.Bars.Voodoo.ValueLabel.Text
    end)
    if not ok or not val then return 0 end
    return tonumber(val) or 0
end

local function FindNearestEnemyHRP()
    local myPos = GetPlayerPosition()
    if not myPos then return nil, nil end
    local pf = Workspace:FindFirstChild("Players")
    if not pf then return nil, nil end
    local bestDist = math.huge
    local bestHRP, bestHum = nil, nil
    for _, model in ipairs(pf:GetChildren()) do

        if model.Name == LocalPlayer.Name or not model:IsA("Model") then continue end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then
            for _, ch in ipairs(model:GetChildren()) do
                if ch:IsA("BasePart") then hrp = ch; break end
            end
        end
        if not hrp then continue end
        local dist = (hrp.Position - myPos).Magnitude
        if dist < bestDist then
            bestDist = dist
            bestHRP = hrp
            bestHum = model:FindFirstChild("Humanoid")
        end
    end
    return bestHRP, bestHum
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if S.AutoVoodooBolt then
            local hrp, hum = FindNearestEnemyHRP()
            if hrp and hum and hum.Health <= 40 and GetVoodooValue() >= 30 then
                fireVoodooBoltRemote(hrp.CFrame)
            end
        end
    end
end)

local function FindNearestCoinPress()
    local playerPos = GetPlayerPosition()
    if not playerPos then return nil end
    local depFolder = Workspace:FindFirstChild("Deployables")
    if not depFolder then return nil end
    local bestDist = COIN_PRESS_MAX_DIST
    local bestId = nil
    for _, obj in ipairs(depFolder:GetChildren()) do
        if not obj:IsA("Model") or obj.Name ~= "Coin Press" then continue end
        local entityId = obj:GetAttribute("EntityID")
        if not entityId or type(entityId) ~= "number" then continue end
        local objPos = GetModelPos(obj)
        if not objPos then continue end
        local dist = (objPos - playerPos).Magnitude
        if dist <= bestDist then bestDist = dist; bestId = entityId end
    end
    return bestId

end

task.spawn(function()
    while true do
        task.wait(0.05)
        if S.AutoPressCoin then
            local entityId = FindNearestCoinPress()
            if entityId then fireCoinPressRemote(entityId) end
        end
    end
end)

local function PlaceSingleBox(px, pz)
    if not S.AutoPlacePlantBox then return end
    firePlaceStructureRemote("Plant Box", Vector3.new(px, GetGroundY(px, pz), pz))
    task.wait(PLANT_BOX_PLACE_DELAY)
end

local function RunAutoPlacePlantBox()
    if S.AutoPlacePlantBoxRunning then return end
    S.AutoPlacePlantBoxRunning = true
    local startPos = GetPlayerPosition()
    if not startPos then S.AutoPlacePlantBoxRunning = false; S.AutoPlacePlantBox = false; return end
    local spacing = PLANT_BOX_SPACING
    local steps = math.floor(PLANT_BOX_PLACE_MAX_DIST / spacing)
    local originX = math.floor(startPos.X / spacing + 0.5) * spacing
    local originZ = math.floor(startPos.Z / spacing + 0.5) * spacing
    for row = -steps, steps do
        if not S.AutoPlacePlantBox then break end
        for col = -steps, steps do
            if not S.AutoPlacePlantBox then break end
            PlaceSingleBox(originX + col * spacing, originZ + row * spacing)
        end
    end
    S.AutoPlacePlantBox = false
    S.AutoPlacePlantBoxRunning = false
end

local function StartAutoPlacePlantBox()
    task.spawn(RunAutoPlacePlantBox)
end

local function StopAutoPlacePlantBox()
    S.AutoPlacePlantBox = false
end

local function FindNearestPlayerHRP(maxDist)
    local myPos = GetPlayerPosition()
    if not myPos then return nil end
    local pf = Workspace:FindFirstChild("Players")
    if not pf then return nil end
    local bestDist = maxDist
    local bestHRP = nil
    for _, model in ipairs(pf:GetChildren()) do
        if model.Name == LocalPlayer.Name or not model:IsA("Model") then continue end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then
            for _, ch in ipairs(model:GetChildren()) do
                if ch:IsA("BasePart") then hrp = ch; break end
            end
        end
        if not hrp then continue end
        local dist = (hrp.Position - myPos).Magnitude
        if dist < bestDist then bestDist = dist; bestHRP = hrp end
    end
    return bestHRP
end

local _lastHutKey = false
local _lastDockKey = false
local _hutCooldown = false
local _dockCooldown = false

local function HandleAutoHut()
    if not S.AutoHutEnabled or not S.AutoHutKeybind then _lastHutKey = false; return end
    local down = UserInputService:IsKeyDown(S.AutoHutKeybind)
    if down and not _lastHutKey and not _hutCooldown then
        _hutCooldown = true
        local hrp = FindNearestPlayerHRP(50)
        if hrp then
            local myHRP = GetPlayerHRP()
            local myPos = myHRP and myHRP.Position or hrp.Position
            local flatDir = Vector3.new(hrp.Position.X - myPos.X, 0, hrp.Position.Z - myPos.Z)
            local unitDir = flatDir.Magnitude > 0.1 and flatDir.Unit or Vector3.new(0, 0, 1)
            local placePos = hrp.Position + unitDir * 10
            firePlaceStructureRemote("Big Ol' Hut", Vector3.new(placePos.X, GetGroundY(placePos.X, placePos.Z), placePos.Z))
        end
        task.delay(0.2, function() _hutCooldown = false end)
    end
    _lastHutKey = down
end

local function HandleAutoDock()
    if not S.AutoDockEnabled or not S.AutoDockKeybind then _lastDockKey = false; return end
    local down = UserInputService:IsKeyDown(S.AutoDockKeybind)
    if down and not _lastDockKey and not _dockCooldown then
        _dockCooldown = true
        local hrp = FindNearestPlayerHRP(50)
        if hrp then
            local myHRP = GetPlayerHRP()
            local myPos = myHRP and myHRP.Position or hrp.Position
            local flatDir = Vector3.new(hrp.Position.X - myPos.X, 0, hrp.Position.Z - myPos.Z)
            local unitDir = flatDir.Magnitude > 0.1 and flatDir.Unit or Vector3.new(0, 0, 1)
            local placePos = hrp.Position - unitDir * 5
            firePlaceStructureRemote("Dock", Vector3.new(placePos.X, GetGroundY(placePos.X, placePos.Z), placePos.Z))
        end
        task.delay(0.2, function() _dockCooldown = false end)
    end
    _lastDockKey = down
end

RunService.Heartbeat:Connect(function()
    HandleAutoHut()
    HandleAutoDock()
end)

local function ScanFoldersDirect(folderNames, playerPos, maxDist)
    local maxDist2 = maxDist * maxDist
    local candidates = {}
    local seenIds = {}
    for _, folderName in ipairs(folderNames) do
        local folder = Workspace:FindFirstChild(folderName)
        if not folder then continue end
        for _, obj in ipairs(folder:GetChildren()) do
            if not obj:IsA("Model") then continue end
            local entityId = obj:GetAttribute("EntityID")
            if not entityId or type(entityId) ~= "number" then continue end
            if seenIds[entityId] then continue end
            local objPos = GetModelPos(obj)
            if not objPos then continue end
            local dx = objPos.X - playerPos.X
            local dy = objPos.Y - playerPos.Y
            local dz = objPos.Z - playerPos.Z
            local dist2 = dx*dx + dy*dy + dz*dz
            if dist2 <= maxDist2 then
                seenIds[entityId] = true

                table.insert(candidates, {entityId=entityId, pos=objPos})
            end
        end
    end
    return candidates
end

local function ScanStructuresDirect(playerPos, maxDist)
    local maxDist2 = maxDist * maxDist
    local candidates = {}
    local seenIds = {}
    for _, folderName in ipairs(STRUCTURE_FOLDERS) do
        local folder = Workspace:FindFirstChild(folderName)
        if not folder then continue end
        for _, obj in ipairs(folder:GetChildren()) do
            if not obj:IsA("Model") then continue end
            local entityId = obj:GetAttribute("EntityID")
            if not entityId or type(entityId) ~= "number" or seenIds[entityId] then continue end
            local objPos = GetModelPos(obj)
            if not objPos then continue end
            local dx = objPos.X - playerPos.X
            local dy = objPos.Y - playerPos.Y
            local dz = objPos.Z - playerPos.Z
            local dist2 = dx*dx + dy*dy + dz*dz
            if dist2 <= maxDist2 then
                seenIds[entityId] = true
                table.insert(candidates, {entityId=entityId, pos=objPos})
            end
        end
    end
    for _, obj in ipairs(Workspace:GetChildren()) do
        if not obj:IsA("Model") or not obj.Name:lower():find("meteor", 1, true) then continue end
        local entityId = obj:GetAttribute("EntityID")
        if not entityId or type(entityId) ~= "number" or seenIds[entityId] then continue end
        local objPos = GetModelPos(obj)
        if not objPos then continue end
        local dx = objPos.X - playerPos.X
        local dy = objPos.Y - playerPos.Y
        local dz = objPos.Z - playerPos.Z
        local dist2 = dx*dx + dy*dy + dz*dz
        if dist2 <= maxDist2 then
            seenIds[entityId] = true
            table.insert(candidates, {entityId=entityId, pos=objPos})
        end
    end
    return candidates
end

local function ScanPlayersDirect(playerPos, maxDist)
    local maxDist2 = maxDist * maxDist
    local candidates = {}
    local pf = Workspace:FindFirstChild("Players")
    if not pf then return candidates end
    for _, obj in ipairs(pf:GetChildren()) do
        if obj.Name == LocalPlayer.Name or not obj:IsA("Model") then continue end
        local entityId = obj:GetAttribute("EntityID")
        if not entityId or type(entityId) ~= "number" then continue end
        local objPos = GetModelPos(obj)
        if not objPos then continue end
        local dx = objPos.X - playerPos.X
        local dy = objPos.Y - playerPos.Y
        local dz = objPos.Z - playerPos.Z
        local dist2 = dx*dx + dy*dy + dz*dz
        if dist2 <= maxDist2 then
            table.insert(candidates, {entityId=entityId, pos=objPos})
        end
    end
    return candidates
end

task.spawn(function()

    while true do
        task.wait(0.15)
        if not S.AutoHitResources then continue end
        local playerPos = GetPlayerPosition()
        if not playerPos then continue end
        local targets = ScanFoldersDirect({"Resources"}, playerPos, HIT_DIST)
        for _, entry in ipairs(targets) do
            FireHitPacket(entry.entityId, entry.pos)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoHitMobs then continue end
        local playerPos = GetPlayerPosition()
        if not playerPos then continue end
        local targets = ScanFoldersDirect({"Critters"}, playerPos, HIT_DIST)
        for _, entry in ipairs(targets) do
            FireHitPacket(entry.entityId, entry.pos)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoHitStructures then continue end
        local playerPos = GetPlayerPosition()
        if not playerPos then continue end

        local targets = ScanStructuresDirect(playerPos, HIT_DIST)
        for _, entry in ipairs(targets) do
            FireHitPacket(entry.entityId, entry.pos)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.KillAura then continue end
        local playerPos = GetPlayerPosition()
        if not playerPos then continue end
        local targets = ScanPlayersDirect(playerPos, KILL_AURA_DIST)
        for _, entry in ipairs(targets) do
            FireHitPacket(entry.entityId, entry.pos)
        end
    end
end)

local function FindEntityInItems(entityId)
    local itemsFolder = Workspace:FindFirstChild("Items")
    if not itemsFolder then return false end
    for _, obj in ipairs(itemsFolder:GetChildren()) do
        if obj:GetAttribute("EntityID") == entityId then return true end
        if obj:IsA("Model") then
            for _, ch in ipairs(obj:GetChildren()) do
                if ch:GetAttribute("EntityID") == entityId then return true end
            end
        end
    end
    return false
end

local function FindEntityInChests(entityId)
    local depFolder = Workspace:FindFirstChild("Deployables")
    if not depFolder then return false end

    for _, chestModel in ipairs(depFolder:GetChildren()) do
        if not chestModel:IsA("Model") then continue end
        local name = chestModel.Name
        if name ~= "Chest" and name ~= "Reinforced Chest" then continue end
        local contentsFolder = chestModel:FindFirstChild("Contents")
        if not contentsFolder then continue end
        for _, obj in ipairs(contentsFolder:GetChildren()) do
            if obj:GetAttribute("EntityID") == entityId then return true end
            if obj:IsA("Model") then
                for _, ch in ipairs(obj:GetChildren()) do
                    if ch:GetAttribute("EntityID") == entityId then return true end
                end
            end
        end
    end
    return false
end

local function ProcessCollectObj(obj, playerPos, maxDist2, hasSelection, seenIds, candidates)
    local isModel = obj:IsA("Model")
    if not (isModel or obj:IsA("MeshPart") or obj:IsA("BasePart")) then return end
    if hasSelection and not SelectedCollectables[obj.Name] then return end
    local objPos = GetModelPos(obj)
    if not objPos then return end
    local dx = objPos.X - playerPos.X
    local dy = objPos.Y - playerPos.Y
    local dz = objPos.Z - playerPos.Z
    if dx*dx + dy*dy + dz*dz > maxDist2 then return end
    local entityId = obj:GetAttribute("EntityID")
    if not entityId and isModel then
        for _, ch in ipairs(obj:GetChildren()) do
            local eid = ch:GetAttribute("EntityID")
            if eid then entityId = eid; break end
        end
    end
    if not entityId or type(entityId) ~= "number" then return end
    if seenIds[entityId] then return end
    seenIds[entityId] = true
    local dx2 = objPos.X - playerPos.X
    local dy2 = objPos.Y - playerPos.Y
    local dz2 = objPos.Z - playerPos.Z
    table.insert(candidates, {entityId=entityId, dist=math.sqrt(dx2*dx2+dy2*dy2+dz2*dz2)})
end

local function ScanCollectItems(playerPos, fromChest)
    local maxDist2 = MAX_DIST * MAX_DIST
    local candidates = {}
    local seenIds = {}
    local hasSelection = false
    for _, v in pairs(SelectedCollectables) do if v then hasSelection = true; break end end
    if not fromChest then
        local itemsFolder = Workspace:FindFirstChild("Items")
        if itemsFolder then
            for _, obj in ipairs(itemsFolder:GetChildren()) do
                ProcessCollectObj(obj, playerPos, maxDist2, hasSelection, seenIds, candidates)
            end
        end
    else
        local depFolder = Workspace:FindFirstChild("Deployables")
        if depFolder then
            for _, chestModel in ipairs(depFolder:GetChildren()) do
                if not chestModel:IsA("Model") then continue end
                local cname = chestModel.Name
                if cname ~= "Chest" and cname ~= "Reinforced Chest" then continue end
                local chestPos = GetModelPos(chestModel)
                if not chestPos then continue end
                local cdx = chestPos.X - playerPos.X
                local cdy = chestPos.Y - playerPos.Y
                local cdz = chestPos.Z - playerPos.Z
                if cdx*cdx + cdy*cdy + cdz*cdz > maxDist2 then continue end
                local contentsFolder = chestModel:FindFirstChild("Contents")
                if not contentsFolder then continue end
                for _, obj in ipairs(contentsFolder:GetChildren()) do
                    ProcessCollectObj(obj, playerPos, maxDist2, hasSelection, seenIds, candidates)
                end
            end
        end
    end
    if #candidates > 1 then
        table.sort(candidates, function(a, b) return a.dist < b.dist end)
    end
    return candidates
end

local _collectIgnore = {}
local _chestCollectIgnore = {}

task.spawn(function()
    while true do
        task.wait(0.2)
        if S.AutoCollect then
            local playerPos = GetPlayerPosition()
            if playerPos then
                for _, item in ipairs(ScanCollectItems(playerPos, false)) do
                    if not S.AutoCollect then break end
                    local eid = item.entityId
                    if not _collectIgnore[eid] and FindEntityInItems(eid) then
                        _collectIgnore[eid] = true
                        task.spawn(function()
                            fireCollectRemote(eid)
                            task.wait(1)
                            _collectIgnore[eid] = nil
                        end)
                    end
                end
            end
        end
        if S.AutoCollectFromChest then
            local playerPos = GetPlayerPosition()
            if playerPos then
                for _, item in ipairs(ScanCollectItems(playerPos, true)) do
                    if not S.AutoCollectFromChest then break end
                    local eid = item.entityId
                    if not _chestCollectIgnore[eid] and FindEntityInChests(eid) then
                        _chestCollectIgnore[eid] = true
                        task.spawn(function()
                            fireCollectRemote(eid)
                            task.wait(1)
                            _chestCollectIgnore[eid] = nil
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.AutoDrop then continue end
        local hasAny = false
        for _, v in pairs(SelectedDropItems) do if v then hasAny = true; break end end
        if not hasAny then continue end
        for name, sel in pairs(SelectedDropItems) do
            if not S.AutoDrop then break end
            if sel then fireDropRemote(name); task.wait(0.05) end
        end
    end
end)

local _autoHealConn = nil
local function EnableAutoHeal()
    if _autoHealConn then
        task.cancel(_autoHealConn)
        _autoHealConn = nil
    end
    _autoHealConn = task.spawn(function()
        while true do
            task.wait(S.HealFrequency)
            if not S.AutoHeal then continue end
            local hum = GetPlayerHumanoid()
            if not hum then continue end
            if hum.Health >= S.MinHealHealth then continue end
            local hasSelection = false
            for _, v in pairs(SelectedHealItems) do
                if v then hasSelection = true; break end
            end
            if hasSelection then
                for _, itemName in ipairs(HealItems) do
                    if SelectedHealItems[itemName] then
                        fireHealRemote(itemName)
                        break
                    end
                end
            else
                local available = {}
                for _, itemName in ipairs(HealItems) do
                    if GetLayoutOrder(itemName) then
                        table.insert(available, itemName)
                    end
                end
                if #available > 0 then
                    fireHealRemote(available[math.random(1, #available)])
                end
            end
        end
    end)
end
EnableAutoHeal()

local function IsPlantBoxValid(plantBoxModel)
    for _, child in ipairs(plantBoxModel:GetChildren()) do
        if child.Name == "Seed" then return false end
    end
    local collisionBox = plantBoxModel:FindFirstChild("collisionBox")
    if collisionBox and collisionBox:IsA("BasePart") then
        local cbPos = collisionBox.Position
        local cbSize = collisionBox.Size * 0.5

        for _, obj in ipairs(Workspace:GetChildren()) do
            if not obj:IsA("Model") or obj == plantBoxModel then continue end
            local objPos = GetModelPos(obj)
            if not objPos then continue end
            local rel = objPos - cbPos
            if math.abs(rel.X) <= cbSize.X and math.abs(rel.Y) <= cbSize.Y and math.abs(rel.Z) <= cbSize.Z then
                return false
            end
        end
    end
    return true
end

local _plantBoxAllCache = {}
local _plantBoxValidCache = {}

task.spawn(function()
    while true do
        task.wait(0.15)
        local needScan = S.AutoPlant or S.AutoPlantMove
        if not needScan then
            if #_plantBoxAllCache > 0 then _plantBoxAllCache = {} end
            if #_plantBoxValidCache > 0 then _plantBoxValidCache = {} end
            continue
        end
        local playerPos = GetPlayerPosition()
        local depFolder = playerPos and Workspace:FindFirstChild("Deployables")
        if not playerPos or not depFolder then
            _plantBoxAllCache = {}; _plantBoxValidCache = {}; continue
        end
        local allBoxes, validBoxes = {}, {}
        for _, obj in ipairs(depFolder:GetChildren()) do
            if not obj:IsA("Model") or obj.Name ~= "Plant Box" then continue end
            local entityId = obj:GetAttribute("EntityID")
            if not entityId or type(entityId) ~= "number" then continue end
            local objPos = GetModelPos(obj)
            if not objPos then continue end
            local dist = (objPos - playerPos).Magnitude
            if dist <= PLANT_SCAN_DIST then
                table.insert(allBoxes, {entityId=entityId, dist=dist, pos=objPos, model=obj})
            end
            if dist <= PLANT_FIRE_DIST and IsPlantBoxValid(obj) then
                table.insert(validBoxes, {entityId=entityId, dist=dist, pos=objPos, model=obj})
            end
        end
        if #allBoxes > 1 then table.sort(allBoxes, function(a,b) return a.dist < b.dist end) end
        if #validBoxes > 1 then table.sort(validBoxes, function(a,b) return a.dist < b.dist end) end
        _plantBoxAllCache = allBoxes
        _plantBoxValidCache = validBoxes
    end
end)

local _plantIgnore = {}
local _plantItemIndex = 1

task.spawn(function()
    while true do
        task.wait(0.2)
        if not S.AutoPlant then continue end
        local cache = _plantBoxValidCache
        if #cache == 0 then continue end
        local itemsToPlant = {}
        local hasSelection = false
        for _, v in pairs(SelectedPlantItems) do if v then hasSelection = true; break end end
        if hasSelection then
            for _, itemName in ipairs(PlantableItems) do
                if SelectedPlantItems[itemName] then table.insert(itemsToPlant, itemName) end
            end
        else
            for _, itemName in ipairs(PlantableItems) do table.insert(itemsToPlant, itemName) end
        end
        if #itemsToPlant == 0 then continue end
        if _plantItemIndex > #itemsToPlant then _plantItemIndex = 1 end
        for _, box in ipairs(cache) do
            if not S.AutoPlant then break end
            if not box.model or not box.model.Parent then continue end
            if _plantIgnore[box.entityId] or not IsPlantBoxValid(box.model) then continue end
            local chosenItem = itemsToPlant[_plantItemIndex]
            _plantItemIndex = _plantItemIndex + 1
            if _plantItemIndex > #itemsToPlant then _plantItemIndex = 1 end
            local eid = box.entityId
            _plantIgnore[eid] = true
            task.spawn(function()
                firePlantRemote(eid, chosenItem)
                task.wait(1)
                _plantIgnore[eid] = nil
            end)
        end
    end
end)

local _plantMoveConn = nil
local function EnablePlantMove()
    if _plantMoveConn then _plantMoveConn:Disconnect() end
    _plantMoveConn = RunService.Heartbeat:Connect(function()
        if not S.AutoPlantMove then return end
        local target = nil
        for _, entry in ipairs(_plantBoxAllCache) do
            if entry.model and entry.model.Parent and IsPlantBoxValid(entry.model) then target = entry; break end

        end
        if not target then return end
        local playerPos = GetPlayerPosition()
        if not playerPos or (target.pos - playerPos).Magnitude <= 5 then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(target.pos) end
    end)
end

local function DisablePlantMove()
    if _plantMoveConn then _plantMoveConn:Disconnect(); _plantMoveConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local pos = GetPlayerPosition()

    if hum and pos then hum:MoveTo(pos) end
end

local _harvestAllCache = {}
local _harvestValidCache = {}
local _harvestIgnore = {}

task.spawn(function()
    local plantNamesLower = {}
    for _, name in ipairs(PlantableItems) do plantNamesLower[name:lower()] = true end
    local scanFolders = {"Crops"}

    local function CheckCandidate(obj, playerPos, seenIds, allList, validList)
        if not obj:IsA("Model") then return end
        local lowerName = obj.Name:lower()
        local matched = false
        for plantLower in pairs(plantNamesLower) do
            if lowerName:find(plantLower, 1, true) then matched = true; break end
        end
        if not matched then
            if lowerName:find("bush", 1, true) or lowerName:find("plant", 1, true) or lowerName:find("crop", 1, true) or lowerName:find("tree", 1, true) or lowerName:find("fruit", 1, true) then
                matched = true
            end
        end
        if not matched then return end

        local entityId = obj:GetAttribute("EntityID") or obj:GetAttribute("entityId") or obj:GetAttribute("EntityId")
        if not entityId then

            for _, ch in ipairs(obj:GetChildren()) do
                local eid = ch:GetAttribute("EntityID") or ch:GetAttribute("entityId") or ch:GetAttribute("EntityId")
                if eid and type(eid) == "number" then entityId = eid; break end
            end
        end
        if not entityId or type(entityId) ~= "number" or seenIds[entityId] then return end

        local objPos = GetModelPos(obj)
        if not objPos then return end

        local dx = objPos.X - playerPos.X
        local dy = objPos.Y - playerPos.Y
        local dz = objPos.Z - playerPos.Z
        local dist2 = dx*dx + dy*dy + dz*dz
        if dist2 > 10000 then return end

        seenIds[entityId] = true
        local dist = math.sqrt(dist2)
        local entry = {entityId = entityId, dist = dist, pos = objPos, model = obj}
        table.insert(allList, entry)
        if dist <= MAX_DIST then
            table.insert(validList, entry)
        end
    end

    while true do
        task.wait(0.15)
        local needScan = S.AutoHarvest or S.AutoHarvestMove
        if not needScan then
            if #_harvestAllCache > 0 then _harvestAllCache = {} end
            if #_harvestValidCache > 0 then _harvestValidCache = {} end
            continue
        end

        local playerPos = GetPlayerPosition()
        if not playerPos then
            _harvestAllCache = {}
            _harvestValidCache = {}
            continue
        end
        local allList, validList = {}, {}
        local seenIds = {}
        for _, obj in ipairs(Workspace:GetChildren()) do

            CheckCandidate(obj, playerPos, seenIds, allList, validList)
        end
        for _, folderName in ipairs(scanFolders) do
            local folder = Workspace:FindFirstChild(folderName)
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    CheckCandidate(obj, playerPos, seenIds, allList, validList)
                end
            end
        end
        if #allList > 1 then table.sort(allList, function(a,b) return a.dist < b.dist end) end
        if #validList > 1 then table.sort(validList, function(a,b) return a.dist < b.dist end) end

        _harvestAllCache = allList
        _harvestValidCache = validList
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if not S.AutoHarvest then continue end
        local cache = _harvestValidCache
        if #cache == 0 then continue end
        for _, bush in ipairs(cache) do
            if not S.AutoHarvest then break end
            if not bush.model or not bush.model.Parent then continue end
            if _harvestIgnore[bush.entityId] then continue end
            local eid = bush.entityId
            _harvestIgnore[eid] = true
            task.spawn(function()
                fireHarvestRemote(eid)
                task.wait(1.5)
                _harvestIgnore[eid] = nil
            end)
        end
    end
end)

local _harvestMoveConn = nil

local function EnableHarvestMove()
    if _harvestMoveConn then _harvestMoveConn:Disconnect() end
    _harvestMoveConn = RunService.Heartbeat:Connect(function()
        if not S.AutoHarvestMove then return end
        local target = nil
        for _, entry in ipairs(_harvestAllCache) do
            if entry.model and entry.model.Parent and not _harvestIgnore[entry.entityId] then
                target = entry
                break

            end
        end
        if not target then return end
        local playerPos = GetPlayerPosition()
        if not playerPos or (target.pos - playerPos).Magnitude <= 5 then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(target.pos) end
    end)
end

local function DisableHarvestMove()
    if _harvestMoveConn then _harvestMoveConn:Disconnect(); _harvestMoveConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local pos = GetPlayerPosition()
    if hum and pos then hum:MoveTo(pos) end
end

local _aimlockConn = nil
local function EnableAimlock()
    if _aimlockConn then _aimlockConn:Disconnect() end
    _aimlockConn = RunService.Heartbeat:Connect(function()
        if not S.AimlockClosest then return end
        local myPos = GetPlayerPosition()
        if not myPos then return end
        local pf = Workspace:FindFirstChild("Players")
        if not pf then return end
        local closestPos, closestDist = nil, math.huge
        for _, model in ipairs(pf:GetChildren()) do
            if model.Name == LocalPlayer.Name or not model:IsA("Model") then continue end
            local pos = GetModelPos(model)
            if not pos then continue end
            local dist = (pos - myPos).Magnitude
            if dist < closestDist then closestDist = dist; closestPos = pos end
        end
        if not closestPos then return end
        local myHRP = GetPlayerHRP()
        if not myHRP then return end
        local lookDir = Vector3.new(closestPos.X - myHRP.Position.X, 0, closestPos.Z - myHRP.Position.Z)
        if lookDir.Magnitude >= 0.1 then myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + lookDir.Unit) end
    end)
end

local function DisableAimlock()
    if _aimlockConn then _aimlockConn:Disconnect(); _aimlockConn = nil end
end

local _followConn = nil
local function EnableFollow()
    if _followConn then _followConn:Disconnect() end
    _followConn = RunService.Heartbeat:Connect(function()
        if not S.FollowNearest then return end
        local myPos = GetPlayerPosition()
        if not myPos then return end
        local pf = Workspace:FindFirstChild("Players")
        if not pf then return end
        local closestPos, closestDist = nil, math.huge
        for _, model in ipairs(pf:GetChildren()) do
            if model.Name == LocalPlayer.Name or not model:IsA("Model") then continue end
            local pos = GetModelPos(model)
            if not pos then continue end
            local dist = (pos - myPos).Magnitude
            if dist < closestDist then closestDist = dist; closestPos = pos end
        end
        if not closestPos or closestDist < 4 then return end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(closestPos) end
    end)
end

local function DisableFollow()
    if _followConn then _followConn:Disconnect(); _followConn = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local pos = GetPlayerPosition()

    if hum and pos then hum:MoveTo(pos) end
end

local _spectateConn = nil

local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "(No players)") end
    return names

end

local function StopSpectate()
    S.SpectateEnabled = false; S.SpectateTarget = nil
    if _spectateConn then _spectateConn:Disconnect(); _spectateConn = nil end
    pcall(function()
        local cam = Workspace.CurrentCamera
        local myCh = LocalPlayer.Character

        local mH = myCh and myCh:FindFirstChild("Humanoid")
        if mH then cam.CameraSubject = mH end
        cam.CameraType = Enum.CameraType.Custom
    end)
end

local function StartSpectate(playerName)
    local target = Players:FindFirstChild(playerName)
    if not target then return end
    S.SpectateTarget = target; S.SpectateEnabled = true
    if _spectateConn then _spectateConn:Disconnect() end
    _spectateConn = RunService.Heartbeat:Connect(function()
        if not S.SpectateEnabled or not S.SpectateTarget then return end
        local m = FindPlayerModel(S.SpectateTarget)

        if not m then return end
        local h = m:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local cam = Workspace.CurrentCamera
        cam.CameraSubject = h; cam.CameraType = Enum.CameraType.Follow
    end)
end

task.spawn(function()
    while true do
        task.wait(5)
        if not _spectateDDRef then continue end
        local names = GetPlayerNames()
        local changed = #names ~= #_lastSpectateNames
        if not changed then
            local ns = {}
            for _, n in ipairs(names) do ns[n] = true end
            for _, n in ipairs(_lastSpectateNames) do if not ns[n] then changed = true; break end end
        end
        if not changed then continue end
        _lastSpectateNames = names
        pcall(function()
            if _spectateDDRef.UpdateOptions then _spectateDDRef:UpdateOptions(names)
            elseif _spectateDDRef.SetOptions then _spectateDDRef:SetOptions(names)
            elseif _spectateDDRef.Refresh then _spectateDDRef:Refresh(names) end
        end)
        if S.SpectateEnabled and S.SpectateTarget then
            local found = false
            for _, n in ipairs(names) do if n == S.SpectateTarget.Name then found = true; break end end
            if not found then StopSpectate() end
        end
    end
end)

local function RemovePlayerESP(player)
    local obj = S.PlayerESPObjs[player]
    if not obj then return end
    pcall(function() if obj.sb and obj.sb.Parent then obj.sb:Destroy() end end)
    pcall(function() if obj.bb and obj.bb.Parent then obj.bb:Destroy() end end)
    S.PlayerESPObjs[player] = nil
end

local function RemoveAllPlayerESP()
    for player in pairs(S.PlayerESPObjs) do RemovePlayerESP(player) end
    S.PlayerESPObjs = {}
end

local function CreatePlayerESP(player)
    if player == LocalPlayer or S.PlayerESPObjs[player] then return end
    local model = FindPlayerModel(player)
    if not model then return end
    local rp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not rp then return end
    local cam = Workspace.CurrentCamera
    local sb = NewInst("SelectionBox", {
        Color3 = Color3.fromRGB(255, 60, 60), LineThickness = 0.07,
        SurfaceTransparency = 0.88, SurfaceColor3 = Color3.fromRGB(255, 60, 60), Adornee = model,
    }, cam)
    local bb = NewInst("BillboardGui", {
        AlwaysOnTop = true, Size = UDim2.new(0, 130, 0, 60),
        StudsOffsetWorldSpace = ESP_STUDS_OFFSET_WORLD, Adornee = rp,
    }, cam)
    local hpOutline = NewInst("Frame", {
        Size = UDim2.new(0, 14, 0, 34), Position = UDim2.new(0, 0, 0, 0),

        BackgroundColor3 = Color3.fromRGB(0, 0, 0), BorderSizePixel = 0,
    }, bb)
    local hpBG = NewInst("Frame", {
        Size = UDim2.new(0, 10, 0, 30), Position = UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(30, 10, 10), BorderSizePixel = 0,
    }, hpOutline)
    local hpFill = NewInst("Frame", {
        AnchorPoint = Vector2.new(0, 1), Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(80, 220, 80), BorderSizePixel = 0,
    }, hpBG)
    local nameLabel = NewInst("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16), Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 170, 255),
        TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(20, 5, 50),
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, Text = player.Name,
    }, bb)
    local distLabel = NewInst("TextLabel", {
        Size = UDim2.new(1, -16, 0, 12), Position = UDim2.new(0, 16, 0, 17),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 220, 100),
        TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(20, 5, 50),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, Text = "-- m",
    }, bb)
    local armorLabel = NewInst("TextLabel", {
        Size = UDim2.new(1, -16, 0, 12), Position = UDim2.new(0, 16, 0, 30),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200, 170, 255),
        TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(20, 5, 50),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, Text = "", Visible = false,
    }, bb)
    S.PlayerESPObjs[player] = {
        model=model, bb=bb, sb=sb, rp=rp,

        hpFill=hpFill, distLabel=distLabel, nameLabel=nameLabel, armorLabel=armorLabel,
    }
end

local function UpdatePlayerESP(myHRP)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local model = FindPlayerModel(player)
        if not model then RemovePlayerESP(player); continue end
        if not S.PlayerESPObjs[player] then CreatePlayerESP(player) end
        local obj = S.PlayerESPObjs[player]
        if not obj then continue end
        local nr = model:FindFirstChild("HumanoidRootPart")
        if nr and nr ~= obj.rp then obj.rp = nr; if obj.bb then obj.bb.Adornee = nr end end
        if model ~= obj.model then obj.model = model; if obj.sb then obj.sb.Adornee = model end end
        local hum = model:FindFirstChild("Humanoid")
        if hum and hum.MaxHealth > 0 then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            obj.hpFill.Size = UDim2.new(1, 0, ratio, 0)
            obj.hpFill.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-ratio)), math.floor(220*ratio), 50)
        end
        if myHRP and obj.rp and obj.rp.Parent then
            obj.distLabel.Text = math.floor((myHRP.Position - obj.rp.Position).Magnitude) .. " m"
        end

        if S.ESPArmorEnabled then
            local t = GetPlayerArmor(model)
            obj.armorLabel.Text = t or ""; obj.armorLabel.Visible = t ~= nil
        else
            obj.armorLabel.Text = ""; obj.armorLabel.Visible = false
        end
    end
    local rem = {}
    for player in pairs(S.PlayerESPObjs) do
        if not Players:FindFirstChild(player.Name) then table.insert(rem, player) end
    end
    for _, p in ipairs(rem) do RemovePlayerESP(p) end
end

RunService.Heartbeat:Connect(function()
    if not S.PlayerESP then return end
    local myCh = LocalPlayer.Character
    UpdatePlayerESP(myCh and myCh:FindFirstChild("HumanoidRootPart"))
end)

local function RemoveAllESPLines()
    for _, obj in pairs(S.ESPLineObjs) do
        pcall(function() if obj.line and obj.line.Parent then obj.line:Destroy() end end)
        pcall(function() if obj.outline and obj.outline.Parent then obj.outline:Destroy() end end)
    end
    S.ESPLineObjs = {}
end

local function EnsureESPLinesGui()
    if S.ESPLinesGui and S.ESPLinesGui.Parent then return end
    S.ESPLinesGui = NewInst("ScreenGui", {
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 998, IgnoreGuiInset = true,
    }, LocalPlayer.PlayerGui)
end

local function MakeLine(parent, zi)
    return NewInst("Frame", {BorderSizePixel=0, AnchorPoint=Vector2.new(0.5,0.5), ZIndex=zi or 1}, parent)
end

local function FindClosestPlayer(myHRP)
    local cP, cD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local m = FindPlayerModel(p)

        if not m then continue end
        local r = m:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local d = (myHRP.Position - r.Position).Magnitude
        if d < cD then cD = d; cP = p end
    end
    return cP
end

local function UpdateESPLines(myHRP, cP)
    EnsureESPLinesGui()
    local cam = Workspace.CurrentCamera
    local sbx = cam.ViewportSize.X / 2

    local sby = cam.ViewportSize.Y
    local active = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local m = FindPlayerModel(p)
        if not m then
            if S.ESPLineObjs[p] then
                local o = S.ESPLineObjs[p]
                pcall(function() if o.outline and o.outline.Parent then o.outline:Destroy() end end)
                pcall(function() if o.line and o.line.Parent then o.line:Destroy() end end)
                S.ESPLineObjs[p] = nil
            end
            continue
        end
        local rp = m:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        active[p] = true
        if not S.ESPLineObjs[p] then
            S.ESPLineObjs[p] = {line=MakeLine(S.ESPLinesGui,2), outline=MakeLine(S.ESPLinesGui,1)}
        end
        local obj = S.ESPLineObjs[p]
        local isCl = (p == cP)
        local lc = isCl and Color3.fromRGB(255,50,50) or Color3.fromRGB(180,80,255)
        local lt = isCl and 1.5 or 1
        local ot = isCl and 2 or 1.5
        local ts, tv = cam:WorldToViewportPoint(rp.Position)
        if not tv then obj.line.Visible=false; obj.outline.Visible=false; continue end
        local dx = ts.X - sbx
        local dy = ts.Y - sby
        local len = math.sqrt(dx*dx + dy*dy)
        if len < 1 then obj.line.Visible=false; obj.outline.Visible=false; continue end
        local ang = math.deg(math.atan2(dy, dx))
        local cx = (sbx + ts.X) / 2
        local cy = (sby + ts.Y) / 2
        obj.outline.Size = UDim2.new(0, len+ot, 0, lt+ot)
        obj.outline.Position = UDim2.new(0, cx, 0, cy)
        obj.outline.Rotation = ang
        obj.outline.BackgroundColor3 = Color3.fromRGB(0,0,0)
        obj.outline.Visible = true
        obj.line.Size = UDim2.new(0, len, 0, lt)
        obj.line.Position = UDim2.new(0, cx, 0, cy)
        obj.line.Rotation = ang
        obj.line.BackgroundColor3 = lc
        obj.line.Visible = true
    end
    local rem = {}
    for p in pairs(S.ESPLineObjs) do if not active[p] then table.insert(rem, p) end end
    for _, p in ipairs(rem) do
        local o = S.ESPLineObjs[p]
        pcall(function() if o.outline and o.outline.Parent then o.outline:Destroy() end end)
        pcall(function() if o.line and o.line.Parent then o.line:Destroy() end end)
        S.ESPLineObjs[p] = nil
    end
end

RunService.Heartbeat:Connect(function()
    if not S.ESPLines then
        if next(S.ESPLineObjs) then RemoveAllESPLines() end; return
    end
    local myCh = LocalPlayer.Character
    local myHRP = myCh and myCh:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    UpdateESPLines(myHRP, FindClosestPlayer(myHRP))
end)

local function ResetCamera()
    pcall(function()
        local cam = Workspace.CurrentCamera
        local myCh = LocalPlayer.Character
        local mH = myCh and myCh:FindFirstChild("Humanoid")
        if mH then cam.CameraSubject = mH end
        cam.CameraType = Enum.CameraType.Custom
    end)
end

local function UpdateLockCamera(myHRP)
    local cP, cD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local m = FindPlayerModel(p)
        if not m then continue end
        local r = m:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local d = (myHRP.Position - r.Position).Magnitude
        if d < cD then cD = d; cP = p end
    end
    if not cP then return end
    local tm = FindPlayerModel(cP)
    if not tm then return end

    local th = tm:FindFirstChild("HumanoidRootPart")
    if not th then return end
    local cam = Workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(myHRP.Position + Vector3.new(0,5,0) + (myHRP.Position - th.Position).Unit * 15, th.Position)
end

RunService.Heartbeat:Connect(function()
    if not S.LockCamera then return end
    local myCh = LocalPlayer.Character
    local myHRP = myCh and myCh:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    UpdateLockCamera(myHRP)
end)

local function RemoveWorldESP(espObjsTable, key)
    local obj = espObjsTable[key]
    if not obj then return end
    pcall(function() if obj.sb and obj.sb.Parent then obj.sb:Destroy() end end)
    pcall(function() if obj.bb and obj.bb.Parent then obj.bb:Destroy() end end)
    espObjsTable[key] = nil
end

local function ClearWorldESPTable(espObjsTable)

    for key in pairs(espObjsTable) do RemoveWorldESP(espObjsTable, key) end
end

local function CreateWorldESP(model, color, labelText, espObjsTable, key)
    if espObjsTable[key] then return end
    local rpPart = model.PrimaryPart
    if not rpPart then
        for _, ch in ipairs(model:GetChildren()) do
            if ch:IsA("BasePart") then rpPart = ch; break end
        end
    end
    if not rpPart then return end
    local cam = Workspace.CurrentCamera
    local sb = NewInst("SelectionBox", {
        Color3 = color, LineThickness = 0.07,
        SurfaceTransparency = 0.88, SurfaceColor3 = color, Adornee = model,
    }, cam)
    local bb = NewInst("BillboardGui", {
        AlwaysOnTop = true, Size = UDim2.new(0, 120, 0, 30),
        StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0), Adornee = rpPart,
    }, cam)
    NewInst("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1, TextColor3 = color,
        TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center, Text = labelText,
    }, bb)
    local distLabel = NewInst("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 0, 16),
        BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 220, 100),
        TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center, Text = "-- m",
    }, bb)
    espObjsTable[key] = {model=model, sb=sb, bb=bb, rp=rpPart, distLabel=distLabel}
end

local function UpdateGodESP(myHRP)
    local resourcesFolder = Workspace:FindFirstChild("Resources")
    local activeKeys = {}
    if resourcesFolder then
        for _, obj in ipairs(resourcesFolder:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("God") then
                activeKeys[obj] = true
                if not S.GodESPObjs[obj] then
                    CreateWorldESP(obj, Color3.fromRGB(255, 215, 0), obj.Name, S.GodESPObjs, obj)

                elseif myHRP and S.GodESPObjs[obj] and S.GodESPObjs[obj].rp and S.GodESPObjs[obj].rp.Parent then
                    S.GodESPObjs[obj].distLabel.Text = math.floor((myHRP.Position - S.GodESPObjs[obj].rp.Position).Magnitude) .. " m"
                end
            end
        end
    end
    for key in pairs(S.GodESPObjs) do
        if not activeKeys[key] then RemoveWorldESP(S.GodESPObjs, key) end
    end
end

local function UpdateItemESP(myHRP)
    local itemsFolder = Workspace:FindFirstChild("Items")
    local activeKeys = {}
    if itemsFolder then
        for _, obj in ipairs(itemsFolder:GetChildren()) do
            local isValid = obj:IsA("Model") or obj:IsA("MeshPart") or obj:IsA("BasePart")
            if not isValid then continue end
            activeKeys[obj] = true
            if not S.ItemESPObjs[obj] then
                local rpPart = nil
                if obj:IsA("Model") then
                    rpPart = obj.PrimaryPart
                    if not rpPart then
                        for _, ch in ipairs(obj:GetChildren()) do
                            if ch:IsA("BasePart") then rpPart = ch; break end
                        end
                    end
                else rpPart = obj end
                if not rpPart then continue end
                local cam = Workspace.CurrentCamera
                local sb = NewInst("SelectionBox", {
                    Color3 = Color3.fromRGB(100,220,255), LineThickness = 0.07,
                    SurfaceTransparency = 0.88, SurfaceColor3 = Color3.fromRGB(100,220,255), Adornee = obj,
                }, cam)
                local bb = NewInst("BillboardGui", {
                    AlwaysOnTop = true, Size = UDim2.new(0,120,0,30),
                    StudsOffsetWorldSpace = Vector3.new(0,2.5,0), Adornee = rpPart,
                }, cam)
                NewInst("TextLabel", {
                    Size = UDim2.new(1,0,0,16), Position = UDim2.new(0,0,0,0),
                    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(100,220,255),
                    TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(0,0,0),
                    Font = Enum.Font.GothamBold, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Center, Text = obj.Name,
                }, bb)
                local dl = NewInst("TextLabel", {
                    Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,16),
                    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,220,100),
                    TextStrokeTransparency = 0.35, TextStrokeColor3 = Color3.fromRGB(0,0,0),
                    Font = Enum.Font.GothamBold, TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Center, Text = "-- m",
                }, bb)
                S.ItemESPObjs[obj] = {model=obj, sb=sb, bb=bb, rp=rpPart, distLabel=dl}
            else
                local eo = S.ItemESPObjs[obj]
                if myHRP and eo and eo.rp and eo.rp.Parent then
                    eo.distLabel.Text = math.floor((myHRP.Position - eo.rp.Position).Magnitude) .. " m"
                end
            end
        end
    end
    for key in pairs(S.ItemESPObjs) do
        if not activeKeys[key] then RemoveWorldESP(S.ItemESPObjs, key) end
    end
end

local function UpdateMeteorESP(myHRP)
    local activeKeys = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Meteor Core") then
            activeKeys[obj] = true
            if not S.MeteorESPObjs[obj] then
                CreateWorldESP(obj, Color3.fromRGB(255, 100, 30), obj.Name, S.MeteorESPObjs, obj)
            elseif myHRP and S.MeteorESPObjs[obj] and S.MeteorESPObjs[obj].rp and S.MeteorESPObjs[obj].rp.Parent then
                S.MeteorESPObjs[obj].distLabel.Text = math.floor((myHRP.Position - S.MeteorESPObjs[obj].rp.Position).Magnitude) .. " m"
            end
        end
    end
    for key in pairs(S.MeteorESPObjs) do
        if not activeKeys[key] then RemoveWorldESP(S.MeteorESPObjs, key) end
    end
end

local function UpdateMerchantESP(myHRP)
    local traderFolder = Workspace:FindFirstChild("WanderingTraderSpawns")

    local activeKeys = {}
    if traderFolder then
        for _, obj in ipairs(traderFolder:GetChildren()) do
            if obj:IsA("Model") then
                activeKeys[obj] = true
                if not S.MerchantESPObjs[obj] then
                    CreateWorldESP(obj, Color3.fromRGB(80, 255, 150), obj.Name, S.MerchantESPObjs, obj)
                elseif myHRP and S.MerchantESPObjs[obj] and S.MerchantESPObjs[obj].rp and S.MerchantESPObjs[obj].rp.Parent then
                    S.MerchantESPObjs[obj].distLabel.Text = math.floor((myHRP.Position - S.MerchantESPObjs[obj].rp.Position).Magnitude) .. " m"
                end
            end
        end
    end
    for key in pairs(S.MerchantESPObjs) do
        if not activeKeys[key] then RemoveWorldESP(S.MerchantESPObjs, key) end
    end
end

local function UpdateNodesESP(myHRP)

    local resourcesFolder = Workspace:FindFirstChild("Resources")
    local activeKeys = {}
    if resourcesFolder then
        for _, obj in ipairs(resourcesFolder:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("Node") then
                activeKeys[obj] = true
                if not S.NodesESPObjs[obj] then
                    CreateWorldESP(obj, Color3.fromRGB(180, 130, 255), obj.Name, S.NodesESPObjs, obj)
                elseif myHRP and S.NodesESPObjs[obj] and S.NodesESPObjs[obj].rp and S.NodesESPObjs[obj].rp.Parent then
                    S.NodesESPObjs[obj].distLabel.Text = math.floor((myHRP.Position - S.NodesESPObjs[obj].rp.Position).Magnitude) .. " m"
                end

            end
        end
    end
    for key in pairs(S.NodesESPObjs) do
        if not activeKeys[key] then RemoveWorldESP(S.NodesESPObjs, key) end
    end
end

RunService.Heartbeat:Connect(function()
    local myHRP = GetPlayerHRP()
    if S.GodESP then UpdateGodESP(myHRP)
    elseif next(S.GodESPObjs) then ClearWorldESPTable(S.GodESPObjs) end
end)

RunService.Heartbeat:Connect(function()
    local myHRP = GetPlayerHRP()
    if S.ItemESP then UpdateItemESP(myHRP)
    elseif next(S.ItemESPObjs) then ClearWorldESPTable(S.ItemESPObjs) end
end)

RunService.Heartbeat:Connect(function()
    local myHRP = GetPlayerHRP()
    if S.MeteorESP then UpdateMeteorESP(myHRP)
    elseif next(S.MeteorESPObjs) then ClearWorldESPTable(S.MeteorESPObjs) end
end)

RunService.Heartbeat:Connect(function()
    local myHRP = GetPlayerHRP()
    if S.MerchantESP then UpdateMerchantESP(myHRP)
    elseif next(S.MerchantESPObjs) then ClearWorldESPTable(S.MerchantESPObjs) end
end)

RunService.Heartbeat:Connect(function()
    local myHRP = GetPlayerHRP()
    if S.NodesESP then UpdateNodesESP(myHRP)
    elseif next(S.NodesESPObjs) then ClearWorldESPTable(S.NodesESPObjs) end
end)

local Window = Library:CreateWindow({
    Title = " Symbiote ",
    Size = UDim2.new(0, 580, 0, 440),
})

local PlayerTab   = Window:CreateTab("Player")
local AutoFarmTab = Window:CreateTab("Auto Farm")
local VariousTab  = Window:CreateTab("Various")
local PVPTab      = Window:CreateTab("PVP")
local TPESPTab    = Window:CreateTab("TP & ESP")

local function BuildPlayerTab()
    PlayerTab:AddLabel("MOVEMENT")
    PlayerTab:AddToggle("Fly", function(state)
        S.FlyEnabled = state
        if state then EnableFly() else DisableFly() end
    end)
    PlayerTab:AddSlider("Fly Speed", 50, 500, 50, function(v) S.FlySpeed = v end)
    PlayerTab:AddToggle("NoClip", function(state)
        S.NoClipEnabled = state
        if state then EnableNoClip() else DisableNoClip() end
    end)
    PlayerTab:AddSeparator()
    PlayerTab:AddLabel("MOUNTAIN CLIMBER")
    PlayerTab:AddToggle("Mountain Climber", function(state)
        S.MountainClimber = state
        if state then EnableMountainClimber() else DisableMountainClimber() end
    end)

    PlayerTab:AddSeparator()
    PlayerTab:AddLabel("WALK SPEED")
    PlayerTab:AddToggle("Walk Speed", function(state)
        S.WalkSpeedEnabled = state
        if state then EnableWalkSpeed() else DisableWalkSpeed() end
    end)
    PlayerTab:AddSlider("Walk Speed Amount", 1, 10, 1, function(v)
        local ratio = (v - 1) / (10 - 1)
        S.WalkSpeedValue = WALKSPEED_MAX_SPEED * (0.1 + ratio * 0.9)
    end)
    PlayerTab:AddSeparator()
    PlayerTab:AddLabel("LAGGY RUN")
    PlayerTab:AddToggle("Laggy Run", function(state)
        S.LaggyRun = state
        if state then EnableLaggy() else DisableLaggy() end
    end)
    PlayerTab:AddSlider("Laggy Run Delay", 1, 10, 1, function(v) S.LaggyDelay = v end)
end

local function BuildAutoFarmTab()
    AutoFarmTab:AddLabel("PLANTING")
    AutoFarmTab:AddToggle("Auto Plant", function(state)
        S.AutoPlant = state
        if not state then _plantBoxValidCache = {}; _plantIgnore = {}; _plantItemIndex = 1 end
    end)
    AutoFarmTab:AddDropdown("Select To Auto Plant", PlantableItems, function(selected)
        for k in pairs(SelectedPlantItems) do SelectedPlantItems[k] = nil end
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v then SelectedPlantItems[k] = true
                elseif type(k) == "number" and type(v) == "string" then SelectedPlantItems[v] = true end
            end
        end
        _plantItemIndex = 1
    end)
    AutoFarmTab:AddToggle("Auto Plant Move", function(state)
        S.AutoPlantMove = state
        if state then EnablePlantMove() else DisablePlantMove() end
    end)
    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("HARVESTING")
    AutoFarmTab:AddToggle("Auto Harvest", function(state)
        S.AutoHarvest = state
        if not state then _harvestAllCache = {}; _harvestValidCache = {}; _harvestIgnore = {} end
    end)
    AutoFarmTab:AddToggle("Auto Harvest Move", function(state)
        S.AutoHarvestMove = state
        if state then EnableHarvestMove() else DisableHarvestMove() end
    end)
    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("AUTO PLACE")
    AutoFarmTab:AddToggle("Auto Place Plant Box", function(state)
        S.AutoPlacePlantBox = state
        if state then
            if not S.AutoPlacePlantBoxRunning then StartAutoPlacePlantBox() end
        else StopAutoPlacePlantBox() end
    end)
end

local function BuildVariousTab()
    VariousTab:AddLabel("AUTO COLLECT")
    VariousTab:AddToggle("Auto Collect", function(state)
        S.AutoCollect = state
        if not state then _collectIgnore = {} end
    end)
    VariousTab:AddDropdown("Select To Auto Collect", CollectableItems, function(selected)
        for k in pairs(SelectedCollectables) do SelectedCollectables[k] = nil end
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v then SelectedCollectables[k] = true
                elseif type(k) == "number" and type(v) == "string" then SelectedCollectables[v] = true end
            end
        end
    end)
    VariousTab:AddToggle("Auto Collect From Chest", function(state)
        S.AutoCollectFromChest = state
        if not state then _chestCollectIgnore = {} end
    end)
    VariousTab:AddSeparator()
    VariousTab:AddLabel("AUTO DROP")
    VariousTab:AddToggle("Auto Drop", function(state) S.AutoDrop = state end)
    local function GetInitDropNames()
        local names = {}
        for name in pairs(DropItemsSet) do table.insert(names, name) end
        table.sort(names)
        return #names > 0 and names or {"(BoÅŸ)"}
    end
    _dropDDRef = VariousTab:AddDropdown("Select To Auto Drop", GetInitDropNames(), function(selected)
        for k in pairs(SelectedDropItems) do SelectedDropItems[k] = nil end

        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v then SelectedDropItems[k] = true
                elseif type(k) == "number" and type(v) == "string" then SelectedDropItems[v] = true end
            end
        end
    end)
    VariousTab:AddSeparator()
    VariousTab:AddLabel("AUTO HIT")

    VariousTab:AddToggle("Auto Hit Nearby Resources", function(state)
        S.AutoHitResources = state
    end)
    VariousTab:AddToggle("Auto Hit Nearby Mobs", function(state)
        S.AutoHitMobs = state
    end)
    VariousTab:AddToggle("Auto Hit Nearby Structures", function(state)
        S.AutoHitStructures = state
    end)
    VariousTab:AddSeparator()
    VariousTab:AddLabel("UTILITY")
    VariousTab:AddToggle("Water Walker", function(state)
        S.WaterWalker = state
        if state then EnableWaterWalker() else DisableWaterWalker() end
    end)
    VariousTab:AddToggle("Unlock All Mojos (Visual)", function(state)
        S.UnlockMojos = state
        if state then EnableUnlockAllMojos() else DisableUnlockAllMojos() end
    end)
    VariousTab:AddToggle("Auto Press Coin", function(state)
        S.AutoPressCoin = state
    end)
    VariousTab:AddToggle("Full Bright", function(state)
        S.FullBright = state
        if state then EnableFullBright() else DisableFullBright() end
    end)
end

local function BuildPVPTab()
    PVPTab:AddLabel("ESP")

    PVPTab:AddToggle("ESP Players", function(state)

        S.PlayerESP = state
        if not state then RemoveAllPlayerESP() end
    end)
    PVPTab:AddToggle("ESP Player Lines", function(state)
        S.ESPLines = state
        if not state then RemoveAllESPLines() end
    end)
    PVPTab:AddToggle("ESP Armor", function(state)

        S.ESPArmorEnabled = state
        if not state then
            for _, obj in pairs(S.PlayerESPObjs) do
                if obj.armorLabel then obj.armorLabel.Text = ""; obj.armorLabel.Visible = false end
            end

        end
    end)
    PVPTab:AddSeparator()
    PVPTab:AddLabel("CAMERA")
    PVPTab:AddToggle("Lock Camera On Closest Player", function(state)
        S.LockCamera = state
        if not state then ResetCamera() end
    end)
    PVPTab:AddToggle("Aimlock at Closest Player", function(state)
        S.AimlockClosest = state
        if state then EnableAimlock() else DisableAimlock() end

    end)

    do
        local specSel = false

        local initNames = GetPlayerNames()
        _lastSpectateNames = initNames
        _spectateDDRef = PVPTab:AddDropdown("Spectate Player", initNames, function(selected)
            if specSel then return end
            local keys = {}
            for k in pairs(selected) do table.insert(keys, k) end
            if #keys == 0 then StopSpectate(); return end
            local name = keys[1]
            if name == "(No players)" then StopSpectate(); return end
            if #keys > 1 then
                specSel = true
                pcall(function() _spectateDDRef:ClearSelection() end)
                specSel = false
            end
            StopSpectate(); StartSpectate(name)
        end)
    end
    PVPTab:AddSeparator()
    PVPTab:AddLabel("COMBAT")
    PVPTab:AddToggle("Kill Aura", function(state)
        S.KillAura = state
    end)
    PVPTab:AddToggle("Follow Nearest Player", function(state)
        S.FollowNearest = state
        if state then EnableFollow() else DisableFollow() end
    end)
    PVPTab:AddToggle("Auto Voodoo Bolt Opponent (If <40)", function(state)
        S.AutoVoodooBolt = state
    end)
    PVPTab:AddSeparator()
    PVPTab:AddLabel("HEALING")
    PVPTab:AddToggle("Auto Heal", function(state) S.AutoHeal = state end)
    PVPTab:AddDropdown("Select To Auto Heal", HealItems, function(selected)
        for k in pairs(SelectedHealItems) do SelectedHealItems[k] = nil end
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v then SelectedHealItems[k] = true
                elseif type(k) == "number" and type(v) == "string" then SelectedHealItems[v] = true end
            end
        end
    end)
    PVPTab:AddSlider("Minimum Health To Auto Heal", 1, 99, 99, function(v)
        S.MinHealHealth = v
    end)
    PVPTab:AddSlider("Heal Frequency", 0, 15, 0, function(v)

        local idx = v + 1
        S.HealFrequency = HealFrequencySteps[idx] or 0.002
        if _autoHealConn then
            task.cancel(_autoHealConn)
            _autoHealConn = nil
        end
        EnableAutoHeal()
    end)
    PVPTab:AddSeparator()
    PVPTab:AddLabel("AUTO PLACE")
    PVPTab:AddToggle("Auto Hut Nearest Player", function(state)

        S.AutoHutEnabled = state; _lastHutKey = false
    end)
    PVPTab:AddDropdown("Select Auto Hut Keybind", {"H","J","G","Q","E","R","U"}, function(selected)
        local chosen = nil
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v then chosen = k; break
                elseif type(k) == "number" and type(v) == "string" then chosen = v; break end
            end
        end
        S.AutoHutKeybind = chosen and KeybindMap[chosen] or nil
    end)
    PVPTab:AddToggle("Auto Dock Nearest Player", function(state)
        S.AutoDockEnabled = state; _lastDockKey = false
    end)
    PVPTab:AddDropdown("Select Auto Dock Keybind", {"H","J","G","Q","E","R","U"}, function(selected)
        local chosen = nil
        if type(selected) == "table" then
            for k, v in pairs(selected) do
                if type(k) == "string" and v then chosen = k; break
                elseif type(k) == "number" and type(v) == "string" then chosen = v; break end
            end
        end
        S.AutoDockKeybind = chosen and KeybindMap[chosen] or nil
    end)
end

local function BuildTPESPTab()
    TPESPTab:AddLabel("TP")
    TPESPTab:AddButton("TP To Void", function()
        pcall(function() TeleportService:Teleport(11879754496, LocalPlayer) end)
    end)
    TPESPTab:AddButton("TP To Overworld", function()
        pcall(function() TeleportService:Teleport(11729688377, LocalPlayer) end)
    end)
    TPESPTab:AddButton("Rejoin Server", function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end)
    TPESPTab:AddSeparator()
    TPESPTab:AddLabel("ESP")
    TPESPTab:AddToggle("God ESP", function(state)
        S.GodESP = state
        if not state then ClearWorldESPTable(S.GodESPObjs) end
    end)
    TPESPTab:AddToggle("Item ESP", function(state)
        S.ItemESP = state
        if not state then ClearWorldESPTable(S.ItemESPObjs) end
    end)
    TPESPTab:AddToggle("Meteor ESP", function(state)
        S.MeteorESP = state
        if not state then ClearWorldESPTable(S.MeteorESPObjs) end
    end)
    TPESPTab:AddToggle("Merchant ESP", function(state)
        S.MerchantESP = state
        if not state then ClearWorldESPTable(S.MerchantESPObjs) end
    end)
    TPESPTab:AddToggle("Nodes ESP", function(state)
        S.NodesESP = state
        if not state then ClearWorldESPTable(S.NodesESPObjs) end

    end)
end

BuildPlayerTab()
BuildAutoFarmTab()
BuildVariousTab()
BuildPVPTab()
BuildTPESPTab()

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})