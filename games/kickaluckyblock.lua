-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Kick a Lucky Block
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

local UILibrary = createSymbioteShim("Kick a Lucky Block")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local autoFarmEnabled = false
local flyEnabled = false
local flySpeed = 50
local walkSpeed = 16
local jumpHeight = 50

local autoRebirth = false
local autoCollectCash = false
local autoUpgradeSpeed = false

local function matrixToCFrame(t)
    return CFrame.new(
        t[1], t[2], t[3],
        t[4], t[5], t[6],
        t[7], t[8], t[9],
        t[10], t[11], t[12]
    )
end

local farmCFrame = matrixToCFrame({
    697.321533, 2.99803257, 236.943375,
    0.0529473573, -9.47559045e-08, 0.998597324,
    -2.93354319e-09, 1, 9.50445482e-08,
    -0.998597324, -7.9617859e-09, 0.0529473573
})

local collectCFrame = matrixToCFrame({
    713.45105, 2.99803257, 237.341827,
    0.0170401055, -2.35750406e-08, 0.999854803,
    -1.08520012e-10, 1, 2.35803128e-08,
    -0.999854803, -5.1031529e-10, 0.0170401055
})

local function startFly()
    flyEnabled = true
    task.spawn(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        hum.PlatformStand = true

        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.Parent = hrp

        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyBG"
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.P = 1e4
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp

        local cam = workspace.CurrentCamera
        while flyEnabled do
            local mv = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0, 1, 0) end
            if mv.Magnitude > 0 then mv = mv.Unit end
            bv.Velocity = mv * flySpeed
            bg.CFrame = cam.CFrame
            task.wait()
        end

        if bv and bv.Parent then bv:Destroy() end
        if bg and bg.Parent then bg:Destroy() end
        if hum then hum.PlatformStand = false end
    end)
end

local function getHRP()
    local workspacePlayers = workspace:FindFirstChild("Players")
    if not workspacePlayers then return nil end
    local playerModel = workspacePlayers:FindFirstChild(LocalPlayer.Name)
    if not playerModel then return nil end
    return playerModel:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local workspacePlayers = workspace:FindFirstChild("Players")
    if not workspacePlayers then return nil end
    local playerModel = workspacePlayers:FindFirstChild(LocalPlayer.Name)
    if not playerModel then return nil end
    return playerModel:FindFirstChildOfClass("Humanoid")
end

local function getPlayerPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:FindFirstChild("HomeIcon", true) then
            return plot
        end

    end
    return nil
end

local function getAllButtonParts()
    local parts = {}
    local plot = getPlayerPlot()
    if not plot then return parts end
    local buttons = plot:FindFirstChild("Buttons")
    if not buttons then return parts end
    for _, child in ipairs(buttons:GetDescendants()) do
        if child:IsA("BasePart") then

            table.insert(parts, child)

        end
    end
    return parts
end

local Window = UILibrary:CreateWindow({
    Title = " Symbiote ",
    Size = UDim2.new(0, 580, 0, 480)
})

local AutoFarmTab = Window:CreateTab("Auto Farm")
local PlayerTab = Window:CreateTab("Player")

AutoFarmTab:AddToggle("Auto Farm", function(Value)

    autoFarmEnabled = Value
end, false)

AutoFarmTab:AddSeparator()
AutoFarmTab:AddLabel("Remotes & Cash")

AutoFarmTab:AddToggle("Auto Collect Cash", function(Value)
    autoCollectCash = Value

end, false)

AutoFarmTab:AddToggle("Auto Rebirth", function(Value)
    autoRebirth = Value
end, false)

AutoFarmTab:AddToggle("Auto Upgrade Speed", function(Value)
    autoUpgradeSpeed = Value
end, false)

PlayerTab:AddSlider("WalkSpeed", 16, 300, 16, function(Value)
    walkSpeed = Value
end)

PlayerTab:AddSlider("Jump Height", 50, 500, 50, function(Value)
    jumpHeight = Value
end)

PlayerTab:AddToggle("Fly", function(Value)

    if Value then startFly() else flyEnabled = false end
end, false)

PlayerTab:AddSlider("Fly Speed", 1, 500, 50, function(Value)
    flySpeed = Value
end)

PlayerTab:AddSeparator()
PlayerTab:AddLabel("Teleport")

local playerDropdown

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

playerDropdown = PlayerTab:AddDropdown("Select Player", getPlayerNames(), function(Options)
    for name, selected in pairs(Options) do
        if selected then
            local target = Players:FindFirstChild(name)
            local hrp = getHRP()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        playerDropdown:SetOptions(getPlayerNames())
    end
end)

task.spawn(function()
    local kickEvent = ReplicatedStorage.Shared.Packages.Network.rev_KickEvent

    local function getRunFrame()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return nil end
        local hud = pg:FindFirstChild("HUD")

        if not hud then return nil end
        return hud:FindFirstChild("Run")
    end

    while true do
        task.wait(0.1)
        if not autoFarmEnabled then continue end

        local hrp = getHRP()
        if not hrp then continue end

        hrp.CFrame = farmCFrame
        task.wait(0.3)

        kickEvent:FireServer(1)

        while autoFarmEnabled do
            local runFrame = getRunFrame()
            if runFrame and runFrame.Visible then break end
            task.wait(0.1)
        end

        if not autoFarmEnabled then continue end

        task.wait(2)

        if not autoFarmEnabled then continue end

        hrp = getHRP()
        if hrp then
            hrp.CFrame = collectCFrame
        end

        task.wait(0.2)
    end

end)

task.spawn(function()
    while true do
        task.wait(1)
        if not autoCollectCash then continue end

        local hrp = getHRP()
        if not hrp then continue end

        local parts = getAllButtonParts()
        for _, part in ipairs(parts) do
            firetouchinterest(part, hrp, 0)
            firetouchinterest(part, hrp, 1)
        end
    end
end)

task.spawn(function()
    local rebirthEvent = ReplicatedStorage.Shared.Packages.Network.rev_RebirthRequest
    while true do
        task.wait(0.5)
        if autoRebirth then
            rebirthEvent:FireServer()
        end
    end
end)

task.spawn(function()
    local speedEvent = ReplicatedStorage.Shared.Packages.Network.rev_SPEED_UPGRADE
    while true do
        task.wait(0.1)
        if autoUpgradeSpeed then
            speedEvent:FireServer(3)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not flyEnabled then
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = walkSpeed
            hum.JumpHeight = jumpHeight
        end
    end
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})