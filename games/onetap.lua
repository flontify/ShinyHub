-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | One Tap
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

local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local runservice = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local lplr = players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = lplr:GetMouse()

local UILib = createSymbioteShim("One Tap")

local canClick = mouse1press and mouse1release and mouse1click
local HoldClick = false
local CurrentlyPressed = false
local CurrentTarget = nil
local UIWindow = nil
local isMouseOverUI = false

local CHAR_0 = utf8.char(0)
local CHAR_1 = utf8.char(1)
local CHAR_2 = utf8.char(2)
local CHAR_3 = utf8.char(3)

local ENUM_EXCLUDE = Enum.RaycastFilterType.Exclude
local ENUM_ALWAYS_ON_TOP = Enum.HighlightDepthMode.AlwaysOnTop
local ENUM_JUMPING = Enum.HumanoidStateType.Jumping
local ENUM_AIR = Enum.Material.Air
local ENUM_GOTHAM_BOLD = Enum.Font.GothamBold

local ENUM_W = Enum.KeyCode.W
local ENUM_A = Enum.KeyCode.A
local ENUM_S = Enum.KeyCode.S
local ENUM_D = Enum.KeyCode.D
local ENUM_SPACE = Enum.KeyCode.Space
local ENUM_LSHIFT = Enum.KeyCode.LeftShift

local DEFAULT_VISIBLE_COLOR = Color3.fromRGB(0, 255, 0)
local DEFAULT_HIDDEN_COLOR = Color3.fromRGB(255, 0, 0)

local cfg = {
    Aimbot_Enabled = false,
    Aimbot_VisibleCheck = true,

    SilentAim_Enabled = false,
    SilentAim_FOV = 60,
    SilentAim_VisibleCheck = true,
    SilentAim_TargetPart = "Hitbox_Head",
    SilentAim_ShowFOV = false,

    Triggerbot_Enabled = false,
    Triggerbot_TeamCheck = false,

    ESP_Enabled = false,
    ESP_Box = false,
    ESP_Lines = false,
    ESP_Names = false,
    ESP_VisibleColor = Color3.fromRGB(0, 255, 0),
    ESP_HiddenColor = Color3.fromRGB(255, 0, 0),
    ESP_MaxFOV = 180,
    ESP_NameSize = 18,

    HitboxExpand_Enabled = false,
    HitboxExpand_Part = "Head",
    HitboxExpand_Size = 5,
    HitboxExpand_Visualize = false,

    Rainbow_Enabled = false,
    Rainbow_Speed = 0.25,

    BunnyHop_Enabled = false,
    BunnyHop_Power = 65,

    Fly_Enabled = false,
    Fly_Speed = 3,
    WalkSpeed_Enabled = false,
    WalkSpeed = 26,
    Noclip_Enabled = false,
}

local function getHealth(hum)
    if not hum then return 0 end
    local attr = hum:GetAttribute("Health")
    if attr ~= nil then return attr end
    return hum.Health
end

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    return getHealth(hum) > 0
end

local function getAllTargets()
    local targets = {}
    local myChar = lplr.Character

    for _, obj in workspace:GetChildren() do
        if obj ~= myChar and obj:IsA("Model") then
            local hitboxFolder = obj:FindFirstChild("Hitbox")
            if hitboxFolder and hitboxFolder:IsA("Folder") then
                table.insert(targets, obj)
            end

        end

    end

    return targets
end

local function getHitboxPart(char, partType)
    local hitboxFolder = char:FindFirstChild("Hitbox")
    if not hitboxFolder then return nil end

    if partType == "Head" then
        return hitboxFolder:FindFirstChild("Hitbox_Head")
    elseif partType == "Torso" then
        return hitboxFolder:FindFirstChild("Hitbox_Torso")
    elseif partType == "Legs" then
        local leftLeg = hitboxFolder:FindFirstChild("Hitbox_Left Leg")
        local rightLeg = hitboxFolder:FindFirstChild("Hitbox_Right Leg")
        return leftLeg or rightLeg
    elseif partType == "Arms" then
        local leftArm = hitboxFolder:FindFirstChild("Hitbox_Left Arm")
        local rightArm = hitboxFolder:FindFirstChild("Hitbox_Right Arm")
        return leftArm or rightArm
    end

    return nil
end

local originalHitboxSizes = {}
local hitboxVisualizers = {}

local function visualizeHitbox(char)
    if not cfg.HitboxExpand_Enabled or not cfg.HitboxExpand_Visualize then
        if hitboxVisualizers[char] then
            for _, visualPart in pairs(hitboxVisualizers[char]) do
                if visualPart and visualPart.Parent then
                    visualPart:Destroy()
                end
            end
            hitboxVisualizers[char] = nil

        end
        return
    end

    local hitboxFolder = char:FindFirstChild("Hitbox")
    if not hitboxFolder then return end

    if not hitboxVisualizers[char] then
        hitboxVisualizers[char] = {}
    end

    local parts = {}
    if cfg.HitboxExpand_Part == "Head" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Head"))
    elseif cfg.HitboxExpand_Part == "Torso" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Torso"))
    elseif cfg.HitboxExpand_Part == "Legs" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Left Leg"))
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Right Leg"))
    elseif cfg.HitboxExpand_Part == "Arms" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Left Arm"))
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Right Arm"))
    end

    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            if not hitboxVisualizers[char][part] then
                local visualPart = Instance.new("Part")
                visualPart.Name = "HitboxVisual"

                visualPart.Anchored = true
                visualPart.CanCollide = false
                visualPart.CanTouch = false
                visualPart.CanQuery = false
                visualPart.Material = Enum.Material.ForceField
                visualPart.Color = Color3.fromRGB(255, 0, 0)
                visualPart.Transparency = 0.7
                visualPart.Parent = workspace
                hitboxVisualizers[char][part] = visualPart
            end

            local visualPart = hitboxVisualizers[char][part]
            visualPart.Size = part.Size
            visualPart.CFrame = part.CFrame
            visualPart.CanCollide = false
            visualPart.CanTouch = false
            visualPart.CanQuery = false
        end
    end
end

local function expandHitbox(char)
    if not cfg.HitboxExpand_Enabled then return end

    local hitboxFolder = char:FindFirstChild("Hitbox")
    if not hitboxFolder then return end

    local parts = {}
    if cfg.HitboxExpand_Part == "Head" then

        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Head"))
    elseif cfg.HitboxExpand_Part == "Torso" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Torso"))
    elseif cfg.HitboxExpand_Part == "Legs" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Left Leg"))
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Right Leg"))
    elseif cfg.HitboxExpand_Part == "Arms" then
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Left Arm"))
        table.insert(parts, hitboxFolder:FindFirstChild("Hitbox_Right Arm"))
    end

    for _, part in pairs(parts) do
        if part and part:IsA("BasePart") then
            if not originalHitboxSizes[part] then
                originalHitboxSizes[part] = part.Size
            end
            part.Size = originalHitboxSizes[part] * cfg.HitboxExpand_Size
            part.Transparency = 1
            part.CanCollide = false
            part.Massless = true
        end
    end

    visualizeHitbox(char)
end

local function resetHitbox(char)
    local hitboxFolder = char:FindFirstChild("Hitbox")

    if not hitboxFolder then return end

    for _, part in pairs(hitboxFolder:GetChildren()) do
        if part:IsA("BasePart") and originalHitboxSizes[part] then
            part.Size = originalHitboxSizes[part]
            originalHitboxSizes[part] = nil
        end
    end

    if hitboxVisualizers[char] then
        for _, visualPart in pairs(hitboxVisualizers[char]) do
            if visualPart and visualPart.Parent then
                visualPart:Destroy()
            end
        end
        hitboxVisualizers[char] = nil
    end
end

local lastHitboxExpandTime = 0
local function updateHitboxExpand()
    local now = tick()
    if now - lastHitboxExpandTime >= 1 then
        lastHitboxExpandTime = now
        if cfg.HitboxExpand_Enabled then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                if isAlive(char) then
                    expandHitbox(char)
                else
                    resetHitbox(char)
                end
            end
        end
    end

    if cfg.HitboxExpand_Enabled and cfg.HitboxExpand_Visualize then
        local targets = getAllTargets()
        for _, char in pairs(targets) do
            if isAlive(char) then
                visualizeHitbox(char)
            else
                if hitboxVisualizers[char] then
                    for _, visualPart in pairs(hitboxVisualizers[char]) do
                        if visualPart and visualPart.Parent then
                            visualPart:Destroy()
                        end
                    end

                    hitboxVisualizers[char] = nil
                end

            end
        end
    end
end

local function inFOV(worldPos, halfRad)
    local camCF = Camera.CFrame
    local diff = worldPos - camCF.Position
    local mag = diff.Magnitude
    if mag < 0.001 then return true end
    local dot = camCF.LookVector:Dot(diff / mag)
    return math.acos(math.clamp(dot, -1, 1)) <= halfRad
end

local _visPts = {}
local _visFilter = {nil, nil}

local function isVisible(targetChar, localChar)
    if not targetChar or not localChar then return false end

    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    _visPts[1] = hrp.Position
    _visPts[2] = nil

    _visFilter[1] = localChar
    _visFilter[2] = targetChar

    local hitboxFolder = targetChar:FindFirstChild("Hitbox")
    if hitboxFolder then
        for _, part in pairs(hitboxFolder:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(_visFilter, part)
            end
        end
    end

    local success, result = pcall(Camera.GetPartsObscuringTarget, Camera, _visPts, _visFilter)

    while #_visFilter > 2 do
        table.remove(_visFilter)
    end

    if success then return #result == 0 end
    return false
end

local function newLine(color, thickness)
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = color or Color3.new(1, 0, 0)
    l.Thickness = thickness or 1
    l.Transparency = 1

    return l
end

local espData = {}
local espCharList = {}

local toRemove = {}
local FOV_DEFAULT_COLOR = Color3.fromRGB(140, 60, 255)
local rainbowHue = 0

local STAT_INTERVAL = 0.5
local lastStatTime = 0
local visCheckIndex = 0

local VIS_CHECKS_PER_FRAME = 2
local VIS_INTERVAL = 0.1
local lastVisTime = 0

local heartbeatFrameCounter = 0
local HEARTBEAT_SKIP = 1

local function applyWalkSpeed()
    local char = lplr.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or getHealth(hum) <= 0 then return end

    if cfg.WalkSpeed_Enabled then
        local attr = hum:GetAttribute("WalkSpeed")
        if attr ~= nil then
            hum:SetAttribute("WalkSpeed", cfg.WalkSpeed)
        else
            hum.WalkSpeed = cfg.WalkSpeed
        end
    else
        local attr = hum:GetAttribute("WalkSpeed")
        if attr ~= nil then
            hum:SetAttribute("WalkSpeed", 26)
        else
            hum.WalkSpeed = 26
        end
    end
end

local function applyJump()
    local char = lplr.Character
    if not char or not cfg.BunnyHop_Enabled then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or getHealth(hum) <= 0 then return end
    local attr = hum:GetAttribute("JumpHeight")
    if attr ~= nil then
        hum:SetAttribute("JumpHeight", cfg.BunnyHop_Power)
    elseif hum.UseJumpPower then
        hum.JumpPower = cfg.BunnyHop_Power
    else
        hum.JumpHeight = cfg.BunnyHop_Power / 10
    end
end

local flyBV, flyBG
local flyActive = false
local flyKeys = {W=false, A=false, S=false, D=false, Up=false, Down=false}

local function startFly()
    if flyActive then return end
    local char = lplr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.P = 20000
    flyBG.Parent = hrp

    hum.PlatformStand = true

    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    flyActive = true

    task.spawn(function()
        while cfg.Fly_Enabled and flyActive do
            task.wait(0.1)
            if not flyBV or not flyBV.Parent or not flyBG or not flyBG.Parent then
                flyActive = false
                task.wait(0.2)
                if cfg.Fly_Enabled then
                    pcall(startFly)

                end
                break
            end
        end
    end)
end

local function stopFly()
    flyActive = false
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = lplr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
end

local noclipConn = nil

local function enableNoclip()
    noclipConn = runservice.Stepped:Connect(function()
        if not cfg.Noclip_Enabled then return end
        local char = lplr.Character if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn=nil end
    local char = lplr.Character if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

local function buildESP(char, name)
    if espData[char] then return end

    local ok, err = pcall(function()
        local old = char:FindFirstChildOfClass("Highlight")
        if old then old:Destroy() end

        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.DepthMode = ENUM_ALWAYS_ON_TOP
        hl.Enabled = false
        hl.Parent = char

        local box = {}
        for i = 1, 4 do box[i] = newLine() end

        local traceLine = newLine()

        local nameGui = nil
        local nameLabel = nil
        local head = char:FindFirstChild("Head")
        if head then
            nameGui = Instance.new("BillboardGui")
            nameGui.Name = "ESP_Name"
            nameGui.Adornee = head
            nameGui.Size = UDim2.new(0, 120, 0, 30)
            nameGui.StudsOffset = Vector3.new(0, 2.8, 0)
            nameGui.AlwaysOnTop = true
            nameGui.Enabled = false
            nameGui.Parent = head
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name or char.Name
            lbl.TextColor3 = Color3.new(1, 1, 1)
            lbl.TextStrokeTransparency = 0
            lbl.TextScaled = false
            lbl.TextSize = cfg.ESP_NameSize
            lbl.Font = ENUM_GOTHAM_BOLD
            lbl.Parent = nameGui
            nameLabel = lbl
        end

        local data = {
            hl = hl,
            box = box,
            line = traceLine,
            nameGui = nameGui,
            nameLabel = nameLabel,
            visCache = false,
            visTime = 0,
            lastColor = nil,
        }
        espData[char] = data

        espCharList[#espCharList + 1] = char
    end)
end

local function destroyESP(char)
    local d = espData[char]
    if not d then return end

    pcall(function()
        if d.hl then d.hl:Destroy() end
        for i = 1, 4 do
            local l = d.box[i]
            if l and l.Remove then pcall(l.Remove, l) end
        end
        if d.line and d.line.Remove then pcall(d.line.Remove, d.line) end
        if d.nameGui then d.nameGui:Destroy() end
    end)

    espData[char] = nil
    for i = #espCharList, 1, -1 do
        if espCharList[i] == char then

            table.remove(espCharList, i)
            break
        end
    end
end

local function hideESP(d)
    if d.hl and d.hl.Enabled then d.hl.Enabled = false end
    if d.nameGui and d.nameGui.Enabled then d.nameGui.Enabled = false end
    for i = 1, 4 do
        local b = d.box[i]
        if b and b.Visible then b.Visible = false end
    end
    if d.line and d.line.Visible then d.line.Visible = false end
end

local function getRandomPointInPart(part)
    if not part or not part:IsA("BasePart") then return part.Position end

    local size = part.Size
    local cf = part.CFrame

    local randomX = (math.random() - 0.5) * size.X * 0.8
    local randomY = (math.random() - 0.5) * size.Y * 0.8
    local randomZ = (math.random() - 0.5) * size.Z * 0.8

    return cf * Vector3.new(randomX, randomY, randomZ)
end

local cachedAimPositions = {}
local lastAimUpdateTime = {}

local function getCachedAimPosition(part, updateInterval)
    if not part then return nil end

    local now = tick()
    local lastUpdate = lastAimUpdateTime[part] or 0

    if now - lastUpdate >= updateInterval or not cachedAimPositions[part] then
        cachedAimPositions[part] = part.Position
        lastAimUpdateTime[part] = now
    end

    return cachedAimPositions[part]
end

local function getAimbotTarget()
    local myChar = lplr.Character
    if not myChar then return nil end

    local closest = nil
    local closestDist = math.huge
    local closestPos = nil

    local targets = getAllTargets()
    for _, char in pairs(targets) do
        if isAlive(char) then
            if cfg.Aimbot_VisibleCheck and not isVisible(char, myChar) then
                continue
            end

            local targetPart = char:FindFirstChild("Head")

            if targetPart then
                local targetPos = targetPart.Position
                local dist = (targetPos - Camera.CFrame.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = targetPart
                    closestPos = targetPos
                end
            end
        end
    end
    return closest, closestPos
end

local function getSilentAimTarget()
    local myChar = lplr.Character
    if not myChar then return nil end

    local mousePos = UserInputService:GetMouseLocation()

    local vpSize = Camera.ViewportSize
    local fovRadius = (cfg.SilentAim_FOV / Camera.FieldOfView) * (vpSize.Y / 2)

    local closest = nil
    local closestDist = math.huge
    local closestPos = nil

    local targets = getAllTargets()
    for _, char in pairs(targets) do
        if isAlive(char) then
            if cfg.SilentAim_VisibleCheck and not isVisible(char, myChar) then
                continue
            end

            local part = char:FindFirstChild("Head")

            if part then
                local targetPos = part.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen and screenPos.Z > 0 then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (screenVec - mousePos).Magnitude

                    if dist <= fovRadius then
                        if dist < closestDist then
                            closestDist = dist
                            closest = part
                            closestPos = targetPos
                        end
                    end
                end
            end
        end
    end
    return closest, closestPos
end

local lastShotTime = 0
local SHOT_COOLDOWN = 0.15

local lastTriggerClick = 0
local TRIGGER_COOLDOWN = 0.08

local function updateESPDrawings(char, d, anyESP, myChar)
    if not char.Parent then
        toRemove[#toRemove + 1] = char
        return
    end

    if not anyESP then
        hideESP(d)
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or getHealth(hum) <= 0 then
        hideESP(d)
        return
    end

    local halfFOV = math.rad(cfg.ESP_MaxFOV / 2)
    if not inFOV(hrp.Position, cfg.ESP_MaxFOV) then
        hideESP(d)
        return
    end

    local color
    if cfg.Rainbow_Enabled then
        color = cfg.ESP_VisibleColor
    elseif d.visCache then
        color = cfg.ESP_VisibleColor
    else
        color = cfg.ESP_HiddenColor
    end

    if cfg.ESP_Enabled then
        if not d.hl.Enabled then d.hl.Enabled = true end
        if d.lastColor ~= color then
            d.hl.OutlineColor = color
            d.lastColor = color

        end
    elseif d.hl.Enabled then
        d.hl.Enabled = false
    end

    if d.nameGui then
        local wantNames = cfg.ESP_Names
        if d.nameGui.Enabled ~= wantNames then
            d.nameGui.Enabled = wantNames
        end
        if wantNames and d.nameLabel then
            d.nameLabel.TextColor3 = color
            d.nameLabel.TextSize = cfg.ESP_NameSize
        end
    end

    if cfg.ESP_Box then
        local p2d, onSc = Camera:WorldToViewportPoint(hrp.Position)
        if onSc and p2d.Z > 0 then
            local w = (Camera.ViewportSize.Y / p2d.Z) * 2
            local h = w * 1.5
            local mnX, mnY = p2d.X - w/2, p2d.Y - h/2
            local mxX, mxY = p2d.X + w/2, p2d.Y + h/2

            local b = d.box
            b[1].From = Vector2.new(mnX, mnY); b[1].To = Vector2.new(mxX, mnY)
            b[2].From = Vector2.new(mxX, mnY); b[2].To = Vector2.new(mxX, mxY)
            b[3].From = Vector2.new(mxX, mxY); b[3].To = Vector2.new(mnX, mxY)
            b[4].From = Vector2.new(mnX, mxY); b[4].To = Vector2.new(mnX, mnY)

            for i = 1, 4 do
                b[i].Color = color
                b[i].Visible = true
            end
        else
            for i = 1, 4 do d.box[i].Visible = false end
        end

    else
        for i = 1, 4 do
            local b = d.box[i]
            if b and b.Visible then b.Visible = false end
        end
    end

    if cfg.ESP_Lines then
        local p2d, onSc = Camera:WorldToViewportPoint(hrp.Position)
        if p2d.Z > 0 then
            local sv = Camera.ViewportSize
            local frm = Vector2.new(sv.X / 2, sv.Y)
            local to = Vector2.new(p2d.X, p2d.Y)
            if not onSc then
                local dir = to - frm
                local tv = {}
                if dir.X < 0 then tv[#tv+1] = -frm.X / dir.X end
                if dir.X > 0 then tv[#tv+1] = (sv.X - frm.X) / dir.X end
                if dir.Y < 0 then tv[#tv+1] = -frm.Y / dir.Y end
                if dir.Y > 0 then tv[#tv+1] = (sv.Y - frm.Y) / dir.Y end
                if #tv > 0 then to = frm + dir * math.min(table.unpack(tv)) end
            end
            d.line.From = frm
            d.line.To = to
            d.line.Color = color
            d.line.Visible = true
        else
            d.line.Visible = false
        end
    elseif d.line and d.line.Visible then

        d.line.Visible = false
    end

    if cfg.ESP_Skeleton then
        local skel = d.skeleton
        for i = 1, #skel do
            local b = skel[i]
            local p1 = char:FindFirstChild(b.from)
            local p2 = char:FindFirstChild(b.to)
            if p1 and p2 then
                local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                    b.line.From = Vector2.new(s1.X, s1.Y)
                    b.line.To = Vector2.new(s2.X, s2.Y)
                    b.line.Color = color
                    b.line.Visible = true
                else
                    b.line.Visible = false
                end
            else
                b.line.Visible = false
            end
        end
    else
        local skel = d.skeleton
        for i = 1, #skel do
            local b = skel[i]
            if b.line and b.line.Visible then b.line.Visible = false end
        end
    end
end

local silentFovCircle = Drawing.new("Circle")
silentFovCircle.Visible = false
silentFovCircle.Thickness = 2
silentFovCircle.Color = FOV_DEFAULT_COLOR
silentFovCircle.Filled = false
silentFovCircle.Transparency = 0.8
silentFovCircle.Radius = 1
silentFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

lplr.CharacterAdded:Connect(function(char)
    task.spawn(function()
        task.wait(0.5)

        if cfg.Fly_Enabled then
            flyActive = false
            startFly()
        end

        if cfg.WalkSpeed_Enabled then pcall(applyWalkSpeed) end

        if cfg.BunnyHop_Enabled then pcall(applyJump) end

        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end

        local hasWalkAttr = hum:GetAttribute("WalkSpeed") ~= nil
        if hasWalkAttr then
            hum:GetAttributeChangedSignal("WalkSpeed"):Connect(function()
                if cfg.WalkSpeed_Enabled and hum:GetAttribute("WalkSpeed") ~= cfg.WalkSpeed then
                    hum:SetAttribute("WalkSpeed", cfg.WalkSpeed)
                end
            end)

        else
            hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if cfg.WalkSpeed_Enabled and hum.WalkSpeed ~= cfg.WalkSpeed then
                    hum.WalkSpeed = cfg.WalkSpeed
                end
            end)
        end

        local hasJumpAttr = hum:GetAttribute("JumpHeight") ~= nil
        if hasJumpAttr then
            hum:GetAttributeChangedSignal("JumpHeight"):Connect(function()
                if cfg.BunnyHop_Enabled and hum:GetAttribute("JumpHeight") ~= cfg.BunnyHop_Power then
                    hum:SetAttribute("JumpHeight", cfg.BunnyHop_Power)
                end
            end)
        elseif hum.UseJumpPower then
            hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if cfg.BunnyHop_Enabled and hum.JumpPower ~= cfg.BunnyHop_Power then
                    hum.JumpPower = cfg.BunnyHop_Power
                end
            end)
        else
            hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
                if cfg.BunnyHop_Enabled and hum.JumpHeight ~= cfg.BunnyHop_Power / 10 then
                    hum.JumpHeight = cfg.BunnyHop_Power / 10
                end
            end)
        end
    end)
end)

task.defer(function()
    local Window = UILib:CreateWindow({
        Title = "  Symbiote ",
        Size = UDim2.new(0, 580, 0, 420),
    })
    UIWindow = Window

    local function checkMouseOverUI()
        local mousePos = UserInputService:GetMouseLocation()
        local guiObjects = game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)

        for _, obj in ipairs(guiObjects) do
            if obj:IsDescendantOf(Window.ScreenGui) then
                return true
            end
        end
        return false
    end

    runservice.RenderStepped:Connect(function()
        isMouseOverUI = checkMouseOverUI()
    end)

    local AimbotTab = Window:CreateTab("Aimbot")
    local SilentAimTab = Window:CreateTab("Silent Aim")
    local ESPTab = Window:CreateTab("ESP")
    local PlayerTab = Window:CreateTab("Player")

    local aimbotToggle, silentAimToggle

    aimbotToggle = AimbotTab:AddToggle("Enable Aimbot", function(state)
        task.wait(0.15)
        cfg.Aimbot_Enabled = state
        if state and cfg.SilentAim_Enabled then
            cfg.SilentAim_Enabled = false
            cfg.SilentAim_ShowFOV = false
            cfg.Triggerbot_Enabled = false
            if silentAimToggle then silentAimToggle:SetState(false) end
        end
    end, false)
    AimbotTab:AddToggle("Visible Check", function(s) cfg.Aimbot_VisibleCheck = s end, true)

    silentAimToggle = SilentAimTab:AddToggle("Enable Silent Aim", function(state)
        task.wait(0.15)
        cfg.SilentAim_Enabled = state
        if state and cfg.Aimbot_Enabled then
            cfg.Aimbot_Enabled = false
            if aimbotToggle then aimbotToggle:SetState(false) end
        end
    end, false)
    SilentAimTab:AddSlider("FOV Size", 10, 100, cfg.SilentAim_FOV, function(v)
        cfg.SilentAim_FOV = v
    end)
    SilentAimTab:AddToggle("Visible Check", function(s) cfg.SilentAim_VisibleCheck = s end, true)
    SilentAimTab:AddToggle("Show FOV", function(s) cfg.SilentAim_ShowFOV = s end, false)

    ESPTab:AddToggle("ESP Outline", function(s)
        cfg.ESP_Enabled = s
        if s then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                if isAlive(char) and not espData[char] then
                    buildESP(char, char.Name)
                end
            end
        end

    end, false)
    ESPTab:AddToggle("ESP Box", function(s)
        cfg.ESP_Box = s
        if s then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                if isAlive(char) and not espData[char] then
                    buildESP(char, char.Name)
                end
            end
        end
    end, false)
    ESPTab:AddToggle("ESP Lines", function(s)
        cfg.ESP_Lines = s
        if s then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                if isAlive(char) and not espData[char] then
                    buildESP(char, char.Name)
                end
            end
        end
    end, false)
    ESPTab:AddToggle("ESP Names", function(s)
        cfg.ESP_Names = s
        if s then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                if isAlive(char) and not espData[char] then
                    buildESP(char, char.Name)
                end
            end
        end
    end, false)
    ESPTab:AddSlider("Name Size", 1, 50, cfg.ESP_NameSize, function(v) cfg.ESP_NameSize = math.floor(v) end)
    ESPTab:AddSlider("ESP Max FOV", 10, 360, cfg.ESP_MaxFOV, function(v) cfg.ESP_MaxFOV = v end)

    local HitboxTab = Window:CreateTab("Hitbox Expand")
    HitboxTab:AddToggle("Hitbox Expand", function(s)
        cfg.HitboxExpand_Enabled = s
        if s then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                expandHitbox(char)
            end
        else
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                resetHitbox(char)
            end
        end
    end, false)
    HitboxTab:AddDropdown("Hitbox Select", {"Head", "Torso", "Legs", "Arms"}, function(sel)
        for part in pairs(sel) do
            cfg.HitboxExpand_Part = part
            if cfg.HitboxExpand_Enabled then
                local targets = getAllTargets()
                for _, char in pairs(targets) do
                    resetHitbox(char)
                    expandHitbox(char)
                end
            end
            break
        end
    end)
    HitboxTab:AddSlider("Hitbox Size", 5, 50, cfg.HitboxExpand_Size, function(v)
        cfg.HitboxExpand_Size = v
        if cfg.HitboxExpand_Enabled then
            local targets = getAllTargets()
            for _, char in pairs(targets) do
                resetHitbox(char)
                expandHitbox(char)
            end
        end
    end)
    HitboxTab:AddToggle("Visualize Hitbox", function(s)
        cfg.HitboxExpand_Visualize = s
        if not s then
            for char, visuals in pairs(hitboxVisualizers) do
                for _, visualPart in pairs(visuals) do
                    if visualPart and visualPart.Parent then
                        visualPart:Destroy()
                    end
                end
            end
            hitboxVisualizers = {}
        end
    end, false)

    PlayerTab:AddToggle("Fly", function(s)
        cfg.Fly_Enabled = s
        if s then pcall(startFly) else pcall(stopFly) end
    end, false)
    PlayerTab:AddSlider("Fly Speed", 1, 10, cfg.Fly_Speed, function(v) cfg.Fly_Speed = v end)
    PlayerTab:AddToggle("Walk Speed", function(s)
        cfg.WalkSpeed_Enabled = s
        pcall(applyWalkSpeed)
    end, false)
    PlayerTab:AddSlider("Walk Speed Value", 26, 200, cfg.WalkSpeed, function(v)
        cfg.WalkSpeed = math.floor(v)
        if cfg.WalkSpeed_Enabled then pcall(applyWalkSpeed) end
    end)
    PlayerTab:AddToggle("Bunny Hop", function(s)
        cfg.BunnyHop_Enabled = s
        if s then pcall(applyJump) end
    end, false)
    PlayerTab:AddSlider("Jump Height", 40, 300, cfg.BunnyHop_Power, function(v)
        cfg.BunnyHop_Power = math.floor(v)
        if cfg.BunnyHop_Enabled then pcall(applyJump) end
    end)
    PlayerTab:AddToggle("Noclip", function(s)
        cfg.Noclip_Enabled = s
        if s then pcall(enableNoclip) else pcall(disableNoclip) end
    end, false)
    PlayerTab:AddToggle("Rainbow Mode", function(s) cfg.Rainbow_Enabled = s end, false)
    PlayerTab:AddSlider("Rainbow Speed", 1, 20, math.floor(cfg.Rainbow_Speed * 10), function(v)
        cfg.Rainbow_Speed = math.floor(v) / 10
    end)
end)

local keyToFlyMap = {
    [ENUM_W] = "W",
    [ENUM_A] = "A",
    [ENUM_S] = "S",
    [ENUM_D] = "D",
    [ENUM_SPACE] = "Up",
    [ENUM_LSHIFT] = "Down",
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local mapped = keyToFlyMap[input.KeyCode]
    if mapped then flyKeys[mapped] = true end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    local mapped = keyToFlyMap[input.KeyCode]
    if mapped then flyKeys[mapped] = false end
end)

local function updateESPDrawings(char, d, anyESP, myChar)
    if not char.Parent then
        toRemove[#toRemove + 1] = char
        return
    end

    if not anyESP then
        hideESP(d)
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or getHealth(hum) <= 0 then
        hideESP(d)
        return
    end

    local halfFOV = math.rad(cfg.ESP_MaxFOV / 2)
    if not inFOV(hrp.Position, halfFOV) then
        hideESP(d)
        return
    end

    local color
    if cfg.Rainbow_Enabled then
        color = cfg.ESP_VisibleColor
    elseif d.visCache then
        color = cfg.ESP_VisibleColor
    else
        color = cfg.ESP_HiddenColor
    end

    if cfg.ESP_Enabled then
        if not d.hl.Enabled then d.hl.Enabled = true end
        if d.lastColor ~= color then
            d.hl.OutlineColor = color
            d.lastColor = color
        end
    elseif d.hl.Enabled then
        d.hl.Enabled = false
    end

    if d.nameGui then
        local wantNames = cfg.ESP_Names
        if d.nameGui.Enabled ~= wantNames then
            d.nameGui.Enabled = wantNames
        end
        if wantNames and d.nameLabel then
            d.nameLabel.TextColor3 = color

            d.nameLabel.TextSize = cfg.ESP_NameSize

        end
    end

    if cfg.ESP_Box then
        local p2d, onSc = Camera:WorldToViewportPoint(hrp.Position)
        if onSc and p2d.Z > 0 then
            local w = (Camera.ViewportSize.Y / p2d.Z) * 2
            local h = w * 1.5
            local mnX, mnY = p2d.X - w/2, p2d.Y - h/2
            local mxX, mxY = p2d.X + w/2, p2d.Y + h/2

            local b = d.box
            b[1].From = Vector2.new(mnX, mnY); b[1].To = Vector2.new(mxX, mnY)
            b[2].From = Vector2.new(mxX, mnY); b[2].To = Vector2.new(mxX, mxY)
            b[3].From = Vector2.new(mxX, mxY); b[3].To = Vector2.new(mnX, mxY)
            b[4].From = Vector2.new(mnX, mxY); b[4].To = Vector2.new(mnX, mnY)

            for i = 1, 4 do
                b[i].Color = color
                b[i].Visible = true
            end
        else
            for i = 1, 4 do d.box[i].Visible = false end
        end
    else
        for i = 1, 4 do
            local b = d.box[i]
            if b and b.Visible then b.Visible = false end

        end
    end

    if cfg.ESP_Lines then
        local p2d, onSc = Camera:WorldToViewportPoint(hrp.Position)
        if p2d.Z > 0 then
            local sv = Camera.ViewportSize
            local frm = Vector2.new(sv.X / 2, sv.Y)
            local to = Vector2.new(p2d.X, p2d.Y)
            if not onSc then
                local dir = to - frm
                local tv = {}
                if dir.X < 0 then tv[#tv+1] = -frm.X / dir.X end
                if dir.X > 0 then tv[#tv+1] = (sv.X - frm.X) / dir.X end
                if dir.Y < 0 then tv[#tv+1] = -frm.Y / dir.Y end
                if dir.Y > 0 then tv[#tv+1] = (sv.Y - frm.Y) / dir.Y end
                if #tv > 0 then to = frm + dir * math.min(table.unpack(tv)) end
            end
            d.line.From = frm
            d.line.To = to
            d.line.Color = color
            d.line.Visible = true
        else
            d.line.Visible = false
        end
    elseif d.line and d.line.Visible then

        d.line.Visible = false
    end
end

local function processHeartbeat(now, myChar)
    local removeCount = #toRemove
    if removeCount > 0 then
        for i = removeCount, 1, -1 do

            destroyESP(toRemove[i])
        end
        table.clear(toRemove)
    end

    if now - lastStatTime >= STAT_INTERVAL then
        lastStatTime = now

        if cfg.WalkSpeed_Enabled then pcall(applyWalkSpeed) end
        if cfg.BunnyHop_Enabled then pcall(applyJump) end
    end

    if cfg.Rainbow_Enabled then
        rainbowHue = (rainbowHue + 0.016 * cfg.Rainbow_Speed) % 1
        local rc = Color3.fromHSV(rainbowHue, 1, 1)
        cfg.ESP_VisibleColor = rc
        cfg.ESP_HiddenColor = rc
        silentFovCircle.Color = rc
    else
        if cfg.ESP_VisibleColor ~= DEFAULT_VISIBLE_COLOR then
            cfg.ESP_VisibleColor = DEFAULT_VISIBLE_COLOR
        end
        if cfg.ESP_HiddenColor ~= DEFAULT_HIDDEN_COLOR then
            cfg.ESP_HiddenColor = DEFAULT_HIDDEN_COLOR
        end
        if silentFovCircle.Color ~= FOV_DEFAULT_COLOR then
            silentFovCircle.Color = FOV_DEFAULT_COLOR
        end
    end

    local anyESP = cfg.ESP_Enabled or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Names

    if anyESP and now - lastVisTime >= VIS_INTERVAL then
        lastVisTime = now
        local charCount = #espCharList
        if charCount > 0 then
            local checksThisFrame = math.min(VIS_CHECKS_PER_FRAME, charCount)
            for _ = 1, checksThisFrame do
                visCheckIndex = visCheckIndex + 1
                if visCheckIndex > charCount then visCheckIndex = 1 end
                local char = espCharList[visCheckIndex]
                if char then
                    local d = espData[char]
                    if d and char.Parent and myChar then
                        d.visCache = isVisible(char, myChar)
                        d.visTime = now
                    end
                end
            end
        end
    end
end

runservice.Heartbeat:Connect(function()
    local now = tick()
    local myChar = lplr.Character

    heartbeatFrameCounter = heartbeatFrameCounter + 1

    if heartbeatFrameCounter % 5 == 0 then
        pcall(processHeartbeat, now, myChar)
    end

    pcall(updateHitboxExpand)
end)

local prevAnyESP = false

local function onRenderStep(dt)
    if cfg.Aimbot_Enabled then
        local target, targetPos = getAimbotTarget()
        if target and targetPos then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = targetCFrame

            if not isMouseOverUI then
                local now = tick()
                if canClick and (now - lastTriggerClick) >= TRIGGER_COOLDOWN then
                    lastTriggerClick = now
                    mouse1click()
                end
            end
        end
    end

    if cfg.SilentAim_Enabled then
        local target, targetPos = getSilentAimTarget()
        if target and targetPos then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = targetCFrame

            if not isMouseOverUI then
                if canClick then
                    local now = tick()
                    if (now - lastShotTime) >= SHOT_COOLDOWN then
                        lastShotTime = now
                        mouse1click()
                    end
                end
            end
        end
    end

    if cfg.SilentAim_Enabled and cfg.SilentAim_ShowFOV then
        local vpSize = Camera.ViewportSize
        silentFovCircle.Radius = (cfg.SilentAim_FOV / Camera.FieldOfView) * (vpSize.Y / 2)
        silentFovCircle.Position = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
        silentFovCircle.Visible = true
    elseif silentFovCircle.Visible then
        silentFovCircle.Visible = false
    end

    if cfg.Fly_Enabled and flyActive and flyBV and flyBG then
        local camCF = Camera.CFrame
        local dir = Vector3.zero
        if flyKeys.W then dir = dir + camCF.LookVector end
        if flyKeys.S then dir = dir - camCF.LookVector end
        if flyKeys.D then dir = dir + camCF.RightVector end
        if flyKeys.A then dir = dir - camCF.RightVector end
        if flyKeys.Up then dir = dir + Vector3.yAxis end
        if flyKeys.Down then dir = dir - Vector3.yAxis end
        if dir.Magnitude > 0 then
            flyBV.Velocity = dir.Unit * (cfg.Fly_Speed * 100)

        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = camCF
    elseif cfg.Fly_Enabled and not flyActive then
        pcall(startFly)
    elseif not cfg.Fly_Enabled and flyActive then
        pcall(stopFly)
    end

    if cfg.BunnyHop_Enabled then
        local myChar = lplr.Character
        if myChar then
            local hum = myChar:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= ENUM_JUMPING and hum.FloorMaterial ~= ENUM_AIR then
                hum.Jump = true
            end
        end
    end

    local anyESP = cfg.ESP_Enabled or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Names
    local myChar = lplr.Character
    local totalChars = #espCharList

    if totalChars > 0 then
        if anyESP then
            prevAnyESP = true
            for i = 1, totalChars do
                local char = espCharList[i]
                if char then
                    local d = espData[char]
                    if d then
                        updateESPDrawings(char, d, anyESP, myChar)
                    end
                end
            end
        elseif prevAnyESP then
            prevAnyESP = false
            for i = 1, totalChars do
                local char = espCharList[i]
                if char and char.Parent then
                    local d = espData[char]
                    if d then hideESP(d) end
                end
            end
        end
    end
end

runservice.RenderStepped:Connect(onRenderStep)

local function onCharAdded(char)
    task.delay(1, function()
        if not char or not char.Parent then return end
        local plr = players:GetPlayerFromCharacter(char)
        if plr and plr ~= lplr and isAlive(char) then
            local anyESP = cfg.ESP_Enabled or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Names or cfg.ESP_Skeleton
            if anyESP then
                buildESP(plr, char)
            end
        end
    end)
end

task.spawn(function()
    task.wait(2)
    local allPlayers = players:GetPlayers()
    for i = 1, #allPlayers do
        local p = allPlayers[i]
        if p ~= lplr then
            p.CharacterAdded:Connect(onCharAdded)
        end
    end
end)

players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(onCharAdded)
end)

workspace.ChildAdded:Connect(function(child)
    task.wait(0.5)
    if child:IsA("Model") and child ~= lplr.Character then
        local hitboxFolder = child:FindFirstChild("Hitbox")
        if hitboxFolder and hitboxFolder:IsA("Folder") then
            if isAlive(child) then
                local anyESP = cfg.ESP_Enabled or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Names
                if anyESP then
                    buildESP(child, child.Name)
                end

                if cfg.HitboxExpand_Enabled then
                    expandHitbox(child)
                end
            end
        end
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if espData[child] then
        destroyESP(child)
    end

    if hitboxVisualizers[child] then
        for _, visualPart in pairs(hitboxVisualizers[child]) do
            if visualPart and visualPart.Parent then
                visualPart:Destroy()
            end
        end
        hitboxVisualizers[child] = nil
    end

    if originalHitboxSizes then
        for part, _ in pairs(originalHitboxSizes) do
            if part:IsDescendantOf(child) then
                originalHitboxSizes[part] = nil
            end
        end
    end
end)

task.spawn(function()
    task.wait(2)
    local targets = getAllTargets()
    for _, char in pairs(targets) do
        if isAlive(char) then
            local anyESP = cfg.ESP_Enabled or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Names
            if anyESP then
                buildESP(char, char.Name)
            end

            if cfg.HitboxExpand_Enabled then
                expandHitbox(char)
            end
        end
    end
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})