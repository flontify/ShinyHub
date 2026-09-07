-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Swing Obby for Brainrots
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

local Library = createSymbioteShim("Swing Obby for Brainrots")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "  Symbiote ",
    Size = UDim2.new(0, 580, 0, 420),
})

local PlayerTab   = Window:CreateTab("Player")
local AutoFarmTab = Window:CreateTab("Auto Farm")

local wsValue = 16
PlayerTab:AddSlider("Walk Speed", 16, 200, 16, function(val)
    wsValue = val
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = wsValue end
    end

end)

local jpValue = 50
PlayerTab:AddSlider("Jump Height", 7, 300, 50, function(val)
    jpValue = val
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true

            hum.JumpPower = val
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = jpValue
        end
    end
end)

local flyActive = false
local flySpeed  = 60
local flyConnection, flyBodyVel, flyBodyGyro

PlayerTab:AddToggle("Fly", function(state)
    flyActive = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if state then
        hum.PlatformStand = true
        flyBodyVel = Instance.new("BodyVelocity", hrp)

        flyBodyVel.Name = "FlyVelocity"

        flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyVel.Velocity = Vector3.zero
        flyBodyGyro = Instance.new("BodyGyro", hrp)
        flyBodyGyro.Name = "FlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro.D = 100
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyActive then return end
            local cam = workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            flyBodyVel.Velocity = dir * flySpeed
            flyBodyGyro.CFrame  = cam.CFrame
        end)
    else
        hum.PlatformStand = false
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyBodyVel    then flyBodyVel:Destroy()       flyBodyVel    = nil end
        if flyBodyGyro   then flyBodyGyro:Destroy()      flyBodyGyro   = nil end
    end
end)

PlayerTab:AddSlider("Fly Speed", 10, 300, 60, function(val)
    flySpeed = val
end)

local autoUpgradeActive = false
PlayerTab:AddToggle("Auto Upgrade Speed", function(state)
    autoUpgradeActive = state
    if not state then return end
    task.spawn(function()
        while autoUpgradeActive do
            ReplicatedStorage.Libraries.Packet.RemoteEvent:FireServer(buffer.fromstring("\x13\n"))
            task.wait(0.1)
        end
    end)
end)

local autoRebirthActive = false
PlayerTab:AddToggle("Auto Rebirth", function(state)
    autoRebirthActive = state
    if not state then return end
    task.spawn(function()
        while autoRebirthActive do
            ReplicatedStorage.Libraries.Packet.RemoteEvent:FireServer(buffer.fromstring("\x11"))
            task.wait(1)
        end
    end)
end)

local autoSellActive = false
PlayerTab:AddToggle("Auto Sell All Brainrots", function(state)
    autoSellActive = state
    if not state then return end
    task.spawn(function()
        while autoSellActive do
            ReplicatedStorage.Libraries.Packet.RemoteEvent:FireServer(buffer.fromstring("\a\x01"))
            task.wait(1)
        end
    end)
end)

local autoCollectActive = false
PlayerTab:AddToggle("Auto Collect Cash", function(state)
    autoCollectActive = state
    if not state then return end
    task.spawn(function()
        while autoCollectActive do
            for i = 1, 64 do
                local buf = buffer.create(2)
                buffer.writeu8(buf, 0, 0x0B)
                buffer.writeu8(buf, 1, i)
                ReplicatedStorage.Libraries.Packet.RemoteEvent:FireServer(buf)
            end
            task.wait(1)
        end
    end)
end)

local function getBrainrotNames()
    local names = {}
    local folder = ReplicatedStorage:FindFirstChild("Assets") and
                   ReplicatedStorage.Assets:FindFirstChild("Brainrots")
    if folder then
        for _, c in ipairs(folder:GetChildren()) do
            table.insert(names, c.Name)
        end
    end
    return names
end

local brainrotNames     = getBrainrotNames()
local mutations         = {"Default","Gold","Diamond","Rainbow","Candy"}
local rarities          = {"Common","Rare","Epic","Legendary","Mythic","Brainrot God","Secret","Divine","OG","MEME"}
local selectedBrainrots = {}
local selectedMutations = {}
local selectedRarities  = {}

AutoFarmTab:AddDropdown("Brainrot", brainrotNames, function(map)
    selectedBrainrots = map
end)

AutoFarmTab:AddDropdown("Mutation", mutations, function(map)
    selectedMutations = map
end)

AutoFarmTab:AddDropdown("Rarity", rarities, function(map)
    selectedRarities = map
end)

local vipUserActive = false
AutoFarmTab:AddToggle("VIP User", function(state)
    vipUserActive = state
end)

local autoFarmActive = false

local DEPOSIT_CF = CFrame.new(
    716.34375, 38.7145729, -2122.14771,
    0.0166822299, 7.39878345e-08,  0.999860823,
    5.37959399e-10, 1,            -7.40071044e-08,
    -0.999860823,   1.77248816e-09, 0.0166822299
)

local function hardWait(t)
    local e = tick() + t
    repeat RunService.Heartbeat:Wait() until tick() >= e
end

local function getMatchingBrainrots()
    local wsBrainrots = workspace:FindFirstChild("Brainrots")
    if not wsBrainrots then return {} end

    local matches = {}
    for _, model in ipairs(wsBrainrots:GetChildren()) do
        if not vipUserActive then
            local targetHRP = model:FindFirstChild("HumanoidRootPart")
            if targetHRP and targetHRP.Position.Y > 60 then
                continue
            end
        end

        local nameOK = true
        local hasAny = false
        for _ in pairs(selectedBrainrots) do hasAny = true break end

        if hasAny then
            nameOK = selectedBrainrots[model.Name] == true
        end

        local mutOK = true

        local hasMut = false
        for _ in pairs(selectedMutations) do hasMut = true break end
        if hasMut then
            mutOK = false
            for _, child in ipairs(model:GetChildren()) do
                if child:IsA("Model") and selectedMutations[child.Name] then
                    mutOK = true
                    break
                end
            end
        end

        local rarOK = true
        local hasRar = false
        for _ in pairs(selectedRarities) do hasRar = true break end
        if hasRar then
            local rarity = model:GetAttribute("Rarity")
            rarOK = rarity and selectedRarities[rarity] == true
        end

        if nameOK and mutOK and rarOK then
            table.insert(matches, model)
        end
    end
    return matches
end

local farmThread = nil

local function farmLoop()
    while autoFarmActive do
        local char = LocalPlayer.Character
        if not char then
            hardWait(0.5)
            continue
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            hardWait(0.5)
            continue

        end

        local matches = getMatchingBrainrots()
        if #matches == 0 then
            hardWait(1)
            continue
        end

        local target = matches[math.random(1, #matches)]
        local targetHRP = target:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            hardWait(0.1)
            continue

        end

        local innerModel
        for _, child in ipairs(target:GetChildren()) do
            if child:IsA("Model") then
                innerModel = child
                break
            end
        end
        if not innerModel then
            hardWait(0.1)
            continue
        end

        local mesh = innerModel:FindFirstChild("Mesh", true)
        if not mesh then
            hardWait(0.1)
            continue
        end

        local carry = mesh:FindFirstChild("Carry")
        if not carry or not carry:IsA("ProximityPrompt") then
            hardWait(0.1)
            continue
        end

        carry.HoldDuration = 0
        carry.MaxActivationDistance = 32

        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 0, 2)
        hardWait(0.2)
        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 0, 2)
        hardWait(0.05)
        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 0, 2)
        hardWait(0.05)
        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 0, 2)
        hardWait(0.05)
        hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 0, 2)
        hardWait(0.05)

        fireproximityprompt(carry)
        hardWait(0.2)

        hrp.CFrame = DEPOSIT_CF
        hardWait(0.3)
    end
    farmThread = nil
end

AutoFarmTab:AddToggle("Auto Farm", function(state)
    autoFarmActive = state
    if state then
        if farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
        farmThread = task.spawn(farmLoop)
    else
        if farmThread then
            task.cancel(farmThread)
            farmThread = nil
        end
    end
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})