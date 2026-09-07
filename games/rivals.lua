-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | RIVALS
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

local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local runservice = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lplr = players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = lplr:GetMouse()

local UILib = createSymbioteShim("RIVALS")

local rs_c = cloneref and cloneref(rs) or rs
local players_c = cloneref and cloneref(players) or players
local workspace_c = cloneref and cloneref(workspace) or workspace
local runservice_c = cloneref and cloneref(runservice) or runservice

local UIWindow = nil
local isMouseOverUI = false

local CHAR_0 = utf8.char(0)
local CHAR_1 = utf8.char(1)
local CHAR_2 = utf8.char(2)
local CHAR_3 = utf8.char(3)

local ENUM_ALWAYS_ON_TOP = Enum.HighlightDepthMode.AlwaysOnTop
local ENUM_JUMPING = Enum.HumanoidStateType.Jumping
local ENUM_AIR = Enum.Material.Air
local ENUM_W = Enum.KeyCode.W
local ENUM_A = Enum.KeyCode.A
local ENUM_S = Enum.KeyCode.S
local ENUM_D = Enum.KeyCode.D
local ENUM_SPACE = Enum.KeyCode.Space
local ENUM_LSHIFT = Enum.KeyCode.LeftShift

local cfg = {
    Aimbot_Enabled = false,
    Aimbot_VisibleCheck = true,
    Aimbot_TeamCheck = false,

    SilentAim_Enabled = false,

    SilentAim_FOV = 60,
    SilentAim_Smoothing = 0,
    SilentAim_FOVColor = Color3.fromRGB(140, 60, 255),
    SilentAim_VisibleCheck = true,
    SilentAim_TeamCheck = false,
    SilentAim_TargetPart = "Head",
    SilentAim_ShowFOV = false,
    SilentAim_AutoFire = true,

    ESP_Enabled = false,
    ESP_Box = false,
    ESP_Lines = false,
    ESP_Skeleton = false,
    ESP_Chams = false,
    ESP_MaxFOV = 180,
    ESP_VisibleEnemyColor = Color3.fromRGB(0, 255, 0),
    ESP_VisibleTeamColor = Color3.fromRGB(0, 120, 255),
    ESP_HiddenEnemyColor = Color3.fromRGB(255, 0, 0),
    ESP_HiddenTeamColor = Color3.fromRGB(255, 165, 0),

    BunnyHop_Enabled = false,

    Fly_Enabled = false,
    Fly_Speed = 1,
    WalkSpeed_Enabled = false,
    WalkSpeed = 1,
    Noclip_Enabled = false,

    TriggerBot_Enabled = false,
    TriggerBot_FireDelay = 0,
    TriggerBot_TeamCheck = false,
    TriggerBot_VisibleCheck = false,
}

local scItemLib = nil
local scViewModels3 = nil
local scReady = false
local scSkinMap = {}
local scGunList = {}
local scTemplateCache = {}

local scApplied = {}
local scSelectedGun = nil
local scSelectedSkin = nil

local function getHealth(hum)
    if not hum then return 0 end
    local attr = hum:GetAttribute("Health")
    if attr ~= nil then return attr end
    return hum.Health
end

local function scGetTemplate(skinName)
    if scTemplateCache[skinName] then return scTemplateCache[skinName] end
    if not scViewModels3 then return nil end
    for _, desc in ipairs(scViewModels3:GetDescendants()) do
        if desc.Name == skinName and (desc:IsA("Model") or desc:IsA("BasePart")) then

            scTemplateCache[skinName] = desc
            return desc
        end
    end
    return nil
end

local function scGetModel(gunName)
    local vms = workspace_c:FindFirstChild("ViewModels")
    if not vms then return nil end
    local fp = vms:FindFirstChild("FirstPerson")
    if not fp then return nil end
    local prefix = lplr.Name .. " - " .. gunName .. " - "
    for _, model in ipairs(fp:GetChildren()) do
        if model:IsA("Model") and model.Name:sub(1, #prefix) == prefix then
            return model, model.Name:sub(#prefix + 1)
        end
    end
    return nil, nil
end

local function scSetupItemVisual(model, template, skinName)
    if not model or not template then return false end
    local primary = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Root")
    if not primary then
        for _, child in ipairs(model:GetChildren()) do
            if child:IsA("BasePart") then
                primary = child
                break
            end
        end
    end
    if not primary then return false end

    local itemVisual = model:FindFirstChild("ItemVisual")
    if not itemVisual then
        itemVisual = Instance.new("Model")
        itemVisual.Name = "ItemVisual"
        itemVisual.Parent = model
    end

    if skinName then
        itemVisual:SetAttribute("SC_Skin", skinName)
    end

    for _, child in ipairs(itemVisual:GetChildren()) do
        child:Destroy()
    end

    local existingMotors = {}
    for _, child in ipairs(primary:GetChildren()) do

        if child:IsA("Motor6D") and child.Name:sub(1, 10) == "ItemVisual" then
            existingMotors[child.Name] = child
        end

    end

    local identity = CFrame.identity
    local firstRefCFrame = nil

    local children = template:IsA("Model") and template:GetChildren() or { template }

    for _, origSub in ipairs(children) do
        if origSub.Name == "_fake" then continue end
        local sub = origSub:Clone()

        local subPrimary = sub:IsA("Model") and (sub.PrimaryPart or sub:FindFirstChild("Primary")) or (sub:IsA("BasePart") and sub or nil)
        if not subPrimary or not subPrimary:IsA("BasePart") then
            subPrimary = sub:FindFirstChildWhichIsA("BasePart", true)
        end
        if not subPrimary then
            sub:Destroy()
            continue

        end
        if sub:IsA("Model") then sub.PrimaryPart = subPrimary end

        local refCFrame = firstRefCFrame or subPrimary.CFrame
        firstRefCFrame = refCFrame

        local armName = if sub.Name == "_right_arm" then "RightArm" elseif sub.Name == "_left_arm" then "LeftArm" else nil

        if armName then
            local armPart = model:FindFirstChild(armName)
            if armPart then
                sub.Parent = armPart
                sub:PivotTo(armPart.CFrame)
                local wc = Instance.new("WeldConstraint")
                wc.Part0 = armPart
                wc.Part1 = subPrimary
                wc.Parent = subPrimary
            end
        else
            sub.Parent = itemVisual
            local motorName = 'ItemVisual["' .. sub.Name .. '"]'
            local m6d = existingMotors[motorName]

            if m6d then
                m6d.Part1 = subPrimary
            else
                m6d = Instance.new("Motor6D")
                m6d.Part0 = primary
                m6d.Part1 = subPrimary

                m6d.Name = motorName
                m6d.C0 = sub:GetAttribute("C0") or (subPrimary.CFrame:ToObjectSpace(refCFrame):Inverse() * identity)
                m6d.C1 = sub:GetAttribute("C1") or identity
                m6d.Parent = primary
                existingMotors[motorName] = m6d
            end
        end

        for _, part in ipairs(sub:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = false
                part.Massless = true

                if part ~= subPrimary then
                    local wc = Instance.new("WeldConstraint")
                    wc.Part0 = subPrimary
                    wc.Part1 = part
                    wc.Parent = subPrimary
                    part.Anchored = false
                end
            end
        end

        subPrimary.Anchored = false
        if not armName then
            subPrimary.Name = sub.Name .. "Primary"
            sub:PivotTo(primary.CFrame)
        end
    end

    pcall(function()
        local getgc_fn = getgc or (getgenv and getgenv().getgc)
        local gcList = if type(getgc_fn) == "function" then getgc_fn(true) else nil

        local function updateVM(vm)
            if type(vm) == "table" and rawget(vm, "Model") == model then
                rawset(vm, "ItemModel", itemVisual)
                vm._body_model = model:FindFirstChild("Body")
                vm._aim_position_attachment = model:FindFirstChild("_aim_position", true)
                vm._aim_lookat_attachment = model:FindFirstChild("_aim_lookat", true)
                vm._center_attachment = model:FindFirstChild("_center", true)
                vm._charm_attachment_model = model:FindFirstChild("_charm_attachment_model", true)
                vm._charm_pivot_attachment = vm._charm_attachment_model and vm._charm_attachment_model:FindFirstChild("_charm_pivot_attachment", true) or model:FindFirstChild("_charm_pivot_attachment", true)
                vm._scope_glare_attachment = model:FindFirstChild("_scope_glare", true)

                vm._muzzle_attachments = {}
                for _, desc in ipairs(model:GetDescendants()) do
                    if desc.Name == "_muzzle" then
                        table.insert(vm._muzzle_attachments, desc)
                    end
                end

                if type(vm._submodels_behind_head_values) == "table" then

                    table.clear(vm._submodels_behind_head_values)
                end
            end
        end

        if aimbotFighter and aimbotFighter.LocalFighter and aimbotFighter.LocalFighter.Items then

            for _, item in pairs(aimbotFighter.LocalFighter.Items) do
                if item.ViewModel then updateVM(item.ViewModel) end
            end
        end

        if gcList then
            for _, obj in ipairs(gcList) do
                updateVM(obj)
            end
        end
    end)

    return true
end

local function scApplySkin(gunName, skinName)
    local template = scGetTemplate(skinName)
    if not template then return false end

    local model, origSkin = scGetModel(gunName)
    if not scApplied[gunName] then
        scApplied[gunName] = { original = origSkin or gunName, applied = skinName }
    else
        if origSkin and not scApplied[gunName].original then
            scApplied[gunName].original = origSkin
        end
        scApplied[gunName].applied = skinName

    end

    if model then
        scSetupItemVisual(model, template, skinName)
    end
    return true
end

local function scResetAll()
    for gunName, data in pairs(scApplied) do
        if data.original then
            local model = scGetModel(gunName)
            if model then
                local template = scGetTemplate(data.original)
                if template then
                    scSetupItemVisual(model, template, data.original)
                end
            end
        end
    end
    table.clear(scApplied)
end

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    return getHealth(hum) > 0
end

local function isTeammate(char)
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    return hrp:FindFirstChild("TeammateLabel") ~= nil
end

local function inFOV(worldPos, maxFOVDeg)
    local camCF = Camera.CFrame
    local diff = worldPos - camCF.Position
    local mag = diff.Magnitude
    if mag < 0.001 then return true end
    local dot = camCF.LookVector:Dot(diff / mag)
    local halfRad = math.rad(maxFOVDeg / 2)
    return math.acos(math.clamp(dot, -1, 1)) <= halfRad
end

local _visRayParams = RaycastParams.new()

local function isVisible(targetChar, localChar)
    if not targetChar or not localChar then return false end
    if not localChar:FindFirstChild("HumanoidRootPart") then return false end
    local origin = Camera.CFrame.Position

    local checkParts = {}
    for _, name in ipairs({"Head", "UpperTorso", "HumanoidRootPart"}) do
        local p = targetChar:FindFirstChild(name)
        if p then
            local toTarget = (p.Position - origin)
            if Camera.CFrame.LookVector:Dot(toTarget.Unit) > 0 then
                checkParts[#checkParts + 1] = p
            end
        end
    end
    if #checkParts == 0 then return false end

    _visRayParams.FilterDescendantsInstances = {localChar, targetChar}
    _visRayParams.FilterType = Enum.RaycastFilterType.Exclude

    for _, part in ipairs(checkParts) do
        local dir = part.Position - origin
        local result = workspace_c:Raycast(origin, dir, _visRayParams)
        if not result then
            return true
        end
    end
    return false
end

local skeletonDef = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local SKELETON_COUNT = #skeletonDef

local function newLine(color, thickness)
    if not Drawing or not Drawing.new then
        return {Visible=false, Color=color or Color3.new(1,0,0), Thickness=thickness or 1, Transparency=1, From=Vector2.new(0,0), To=Vector2.new(0,0), Remove=function() end}
    end
    local ok, l = pcall(function() return Drawing.new("Line") end)
    if not ok or not l then
        return {Visible=false, Color=color or Color3.new(1,0,0), Thickness=thickness or 1, Transparency=1, From=Vector2.new(0,0), To=Vector2.new(0,0), Remove=function() end}
    end
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

local lastStatTime = 0
local STAT_INTERVAL = 0.5

local WalkSpeedConnection = nil
local WalkSpeedEnabled = false

local function EnableWalkSpeed()
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
    WalkSpeedConnection = runservice_c.Heartbeat:Connect(function()
        if not WalkSpeedEnabled then return end
        local c = lplr.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = c:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local md = hum.MoveDirection
        if md.Magnitude < 0.1 then return end
        local cf = hrp.CFrame
        local np = cf.Position + md.Unit * cfg.WalkSpeed * 0.1
        hrp.CFrame = CFrame.fromMatrix(np, cf.RightVector, cf.UpVector, -cf.LookVector)
    end)
end

local function DisableWalkSpeed()
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect(); WalkSpeedConnection = nil end
end

local flyBV, flyBG
local flyActive = false
local flyKeys = {W = false, A = false, S = false, D = false, Up = false, Down = false}

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
    flyBG.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
    flyBG.P = 20000
    flyBG.Parent = hrp
    hum.PlatformStand = true
    flyActive = true
end

local function stopFly()
    flyActive = false
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = lplr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local noclipConn = nil

local function enableNoclip()
    noclipConn = runservice_c.Stepped:Connect(function()
        if not cfg.Noclip_Enabled then return end
        local char = lplr.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function disableNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local char = lplr.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

local function buildESP(plr, char)
    if espData[char] then return end
    pcall(function()
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

        local skeleton = {}
        for idx = 1, SKELETON_COUNT do

            local conn = skeletonDef[idx]
            skeleton[idx] = {from = conn[1], to = conn[2], line = newLine(Color3.new(1, 1, 1), 2)}
        end

        local hBarBg = Drawing.new("Line"); hBarBg.Visible = false; hBarBg.Color = Color3.fromRGB(0,0,0); hBarBg.Thickness = 5; hBarBg.Transparency = 1
        local hBarFg = Drawing.new("Line"); hBarFg.Visible = false; hBarFg.Color = Color3.fromRGB(0,255,0); hBarFg.Thickness = 3; hBarFg.Transparency = 1
        local hBarOL = Drawing.new("Line"); hBarOL.Visible = false; hBarOL.Color = Color3.fromRGB(0,0,0); hBarOL.Thickness = 1; hBarOL.Transparency = 1
        local hBarOR = Drawing.new("Line"); hBarOR.Visible = false; hBarOR.Color = Color3.fromRGB(0,0,0); hBarOR.Thickness = 1; hBarOR.Transparency = 1
        local hBarOT = Drawing.new("Line"); hBarOT.Visible = false; hBarOT.Color = Color3.fromRGB(0,0,0); hBarOT.Thickness = 1; hBarOT.Transparency = 1
        local hBarOB = Drawing.new("Line"); hBarOB.Visible = false; hBarOB.Color = Color3.fromRGB(0,0,0); hBarOB.Thickness = 1; hBarOB.Transparency = 1

        espData[char] = {
            hl = hl, box = box, line = traceLine, skeleton = skeleton,
            visCache = false, lastColor = nil,
            hBarBg = hBarBg, hBarFg = hBarFg,
            hBarOL = hBarOL, hBarOR = hBarOR, hBarOT = hBarOT, hBarOB = hBarOB,
        }
        espCharList[#espCharList + 1] = char
    end)
end

local function destroyESP(char)
    local d = espData[char]
    if not d then return end
    pcall(function()
        if d.hl then d.hl:Destroy() end
        for i = 1, 4 do if d.box[i] and d.box[i].Remove then pcall(d.box[i].Remove, d.box[i]) end end
        if d.line and d.line.Remove then pcall(d.line.Remove, d.line) end
        for i = 1, #d.skeleton do if d.skeleton[i].line and d.skeleton[i].line.Remove then pcall(d.skeleton[i].line.Remove, d.skeleton[i].line) end end
        for _, k in ipairs({"hBarBg","hBarFg","hBarOL","hBarOR","hBarOT","hBarOB"}) do
            if d[k] and d[k].Remove then pcall(d[k].Remove, d[k]) end
        end
    end)
    espData[char] = nil
    for i = #espCharList, 1, -1 do
        if espCharList[i] == char then table.remove(espCharList, i); break end
    end
end

local function hideESP(d)
    if d.hl and d.hl.Enabled then d.hl.Enabled = false end
    for i = 1, 4 do if d.box[i] and d.box[i].Visible then d.box[i].Visible = false end end

    if d.line and d.line.Visible then d.line.Visible = false end
    for i = 1, #d.skeleton do if d.skeleton[i].line and d.skeleton[i].line.Visible then d.skeleton[i].line.Visible = false end end
    for _, k in ipairs({"hBarBg","hBarFg","hBarOL","hBarOR","hBarOT","hBarOB"}) do
        if d[k] and d[k].Visible then d[k].Visible = false end
    end
end

local aimbotUtil = nil
local aimbotEnums = nil
local aimbotFighter = nil
local aimbotReady = false

task.spawn(function()
    task.wait(3)
    pcall(function()
        aimbotUtil = require(rs_c.Modules.Utility)
        aimbotEnums = require(rs_c.Modules.EnumLibrary)
        aimbotFighter = require(lplr.PlayerScripts.Controllers.FighterController)
        aimbotReady = true
    end)
end)

local aimbotRayParams = RaycastParams.new()
local aimbotOffsets = {
    Vector3.new(0,12,0), Vector3.new(0,16,0), Vector3.new(0,20,0), Vector3.new(0,24,0),
    Vector3.new(0,28,0), Vector3.new(0,32,0), Vector3.new(0,36,0), Vector3.new(0,40,0),
}

local function aimbotGetClosest()
    local myChar = lplr.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local target, targetChar, dist = nil, nil, math.huge
    for _, plr in ipairs(players_c:GetPlayers()) do
        if plr ~= lplr and plr.Character and plr.Character:FindFirstChild("Head") then
            if cfg.Aimbot_TeamCheck and isTeammate(plr.Character) then continue end
            if not isAlive(plr.Character) then continue end
            if cfg.Aimbot_VisibleCheck and not isVisible(plr.Character, myChar) then continue end
            local mag = (myChar.HumanoidRootPart.Position - plr.Character.Head.Position).Magnitude
            if mag < dist then
                dist = mag
                target = plr.Character.Head
                targetChar = plr.Character
            end
        end
    end
    return target, targetChar

end

local function aimbotCalculatePoint(origin, targetPos, targetChar, myChar)
    aimbotRayParams.FilterDescendantsInstances = {myChar, targetChar}
    aimbotRayParams.FilterType = Enum.RaycastFilterType.Exclude
    if not workspace_c:Raycast(origin, targetPos - origin, aimbotRayParams) then
        return origin, nil
    end
    for _, offset in ipairs(aimbotOffsets) do
        local scanPos = origin + offset
        if not workspace_c:Raycast(scanPos, targetPos - scanPos, aimbotRayParams) then
            return scanPos, offset.Y
        end
    end
    return nil, nil
end

local AIMBOT_SHOT_INTERVAL = 0.1
local aimbotFireAccum = 0

local function aimbotFire()
    if not aimbotReady then return end
    if not aimbotFighter or not aimbotFighter.LocalFighter then return end
    local item = aimbotFighter.LocalFighter.EquippedItem
    if not item then return end
    local myChar = lplr.Character
    if not myChar then return end
    local targetPart, targetChar = aimbotGetClosest()
    if not targetPart or not targetChar then return end
    local hum = targetChar:FindFirstChild("Humanoid")
    if hum and getHealth(hum) <= 0 then return end
    local cam = Camera.CFrame
    local manip, height = aimbotCalculatePoint(cam.Position, targetPart.Position, targetChar, myChar)
    if not manip then return end
    local shootPos = (height == nil and manip) or cam.Position
    local cameradata = {}
    cameradata[CHAR_1] = {
        [CHAR_0] = aimbotUtil:EncodeCFrame(CFrame.new(shootPos.X, shootPos.Y + (height or 0), shootPos.Z) * CFrame.Angles(CFrame.lookAt(shootPos, targetPart.Position):ToOrientation())),
        [CHAR_1] = height and aimbotUtil:EncodeCFrame(CFrame.new(targetPart.Position) * CFrame.Angles(CFrame.lookAt(shootPos, targetPart.Position):ToOrientation())) or aimbotUtil:EncodeCFrame(CFrame.new(shootPos.X, shootPos.Y + (height or 0), shootPos.Z) * CFrame.Angles(CFrame.lookAt(shootPos, targetPart.Position):ToOrientation())),
        [CHAR_2] = targetPart,
        [CHAR_3] = aimbotUtil:EncodeCFrame(targetPart.CFrame:ToObjectSpace(CFrame.new(targetPart.Position))),
    }
    rs_c.Remotes.Replication.Fighter.UseItem:FireServer(item:Get("ObjectID"), aimbotEnums:ToEnum("StartShooting"), cameradata, nil)
end

local canClick = mouse1press and mouse1release and mouse1click

local silentAimTarget = nil
local silentAimLastShot = 0
local SILENT_AIM_SHOT_COOLDOWN = 0.15

local function getSilentAimTarget()
    local myChar = lplr.Character
    if not myChar then return nil end
    local vpSize = Camera.ViewportSize
    local fovRadius = (cfg.SilentAim_FOV / Camera.FieldOfView) * (vpSize.Y / 2)

    local screenCenter = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(players_c:GetPlayers()) do
        if plr ~= lplr then
            local char = plr.Character
            if char and isAlive(char) then
                if cfg.SilentAim_TeamCheck and isTeammate(char) then continue end
                local part = char:FindFirstChild(cfg.SilentAim_TargetPart) or char:FindFirstChild("Head")
                if part then
                    if cfg.SilentAim_VisibleCheck and not isVisible(char, myChar) then continue end
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and screenPos.Z > 0 then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist <= fovRadius and dist < closestDist then
                            closestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function updateESPDrawings(char, d, anyESP, myChar)
    if not char.Parent then

        toRemove[#toRemove + 1] = char
        return

    end
    if not anyESP then hideESP(d); return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum or getHealth(hum) <= 0 then hideESP(d); return end
    if not inFOV(hrp.Position, cfg.ESP_MaxFOV) then hideESP(d); return end

    local isTeam = isTeammate(char)
    local vis = d.visCache
    local color = vis
        and (isTeam and cfg.ESP_VisibleTeamColor or cfg.ESP_VisibleEnemyColor)
        or (isTeam and cfg.ESP_HiddenTeamColor or cfg.ESP_HiddenEnemyColor)

    local wantHL = cfg.ESP_Enabled or cfg.ESP_Chams
    if wantHL then
        if not d.hl.Enabled then d.hl.Enabled = true end
        local outT = cfg.ESP_Enabled and 0 or 1
        local fillT = cfg.ESP_Chams and 0.5 or 1
        if d.lastColor ~= color or d.hl.OutlineTransparency ~= outT or d.hl.FillTransparency ~= fillT then
            d.hl.OutlineColor = color
            d.hl.OutlineTransparency = outT
            if cfg.ESP_Chams then d.hl.FillColor = color end
            d.hl.FillTransparency = fillT
            d.lastColor = color
        end
    elseif d.hl.Enabled then
        d.hl.Enabled = false
        d.lastColor = nil

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
            for i = 1, 4 do b[i].Color = color; b[i].Visible = true end
        else
            for i = 1, 4 do d.box[i].Visible = false end
        end
    else
        for i = 1, 4 do if d.box[i].Visible then d.box[i].Visible = false end end
    end

    if anyESP then
        local p2d, onSc = Camera:WorldToViewportPoint(hrp.Position)
        if onSc and p2d.Z > 0 then
            local w = (Camera.ViewportSize.Y / p2d.Z) * 2
            local h = w * 1.5
            local bMinX = p2d.X - w/2
            local bMinY = p2d.Y - h/2
            local bMaxY = p2d.Y + h/2

            local healthNow = hum.Health

            local healthMax = hum.MaxHealth
            local ratio = healthMax > 0 and math.clamp(healthNow / healthMax, 0, 1) or 0
            local bW = 4
            local bOff = 6
            local bX = bMinX - bOff - bW
            local barBot = bMaxY
            local barTop = bMinY
            local barH = barBot - barTop

            local fillTop = barBot - barH * ratio
            local hCol = Color3.fromRGB(math.floor((1 - ratio) * 255), math.floor(ratio * 255), 0)
            local om = 1

            d.hBarBg.From = Vector2.new(bX + bW/2, barTop); d.hBarBg.To = Vector2.new(bX + bW/2, barBot)
            d.hBarBg.Thickness = bW; d.hBarBg.Color = Color3.fromRGB(0,0,0); d.hBarBg.Visible = true

            if ratio > 0 then
                d.hBarFg.From = Vector2.new(bX + bW/2, fillTop); d.hBarFg.To = Vector2.new(bX + bW/2, barBot)
                d.hBarFg.Thickness = bW - 2; d.hBarFg.Color = hCol; d.hBarFg.Visible = true
            else
                d.hBarFg.Visible = false
            end

            d.hBarOL.From = Vector2.new(bX-om, barTop-om); d.hBarOL.To = Vector2.new(bX-om, barBot+om); d.hBarOL.Color = Color3.fromRGB(0,0,0); d.hBarOL.Thickness = 1; d.hBarOL.Visible = true
            d.hBarOR.From = Vector2.new(bX+bW+om, barTop-om); d.hBarOR.To = Vector2.new(bX+bW+om, barBot+om); d.hBarOR.Color = Color3.fromRGB(0,0,0); d.hBarOR.Thickness = 1; d.hBarOR.Visible = true
            d.hBarOT.From = Vector2.new(bX-om, barTop-om); d.hBarOT.To = Vector2.new(bX+bW+om, barTop-om); d.hBarOT.Color = Color3.fromRGB(0,0,0); d.hBarOT.Thickness = 1; d.hBarOT.Visible = true
            d.hBarOB.From = Vector2.new(bX-om, barBot+om); d.hBarOB.To = Vector2.new(bX+bW+om, barBot+om); d.hBarOB.Color = Color3.fromRGB(0,0,0); d.hBarOB.Thickness = 1; d.hBarOB.Visible = true
        else
            for _, k in ipairs({"hBarBg","hBarFg","hBarOL","hBarOR","hBarOT","hBarOB"}) do d[k].Visible = false end
        end
    else
        for _, k in ipairs({"hBarBg","hBarFg","hBarOL","hBarOR","hBarOT","hBarOB"}) do d[k].Visible = false end
    end

    if cfg.ESP_Lines then
        local p2d, onSc = Camera:WorldToViewportPoint(hrp.Position)
        if p2d.Z > 0 then
            local sv = Camera.ViewportSize
            local frm = Vector2.new(sv.X/2, sv.Y)
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
            d.line.From = frm; d.line.To = to; d.line.Color = color; d.line.Visible = true
        else
            d.line.Visible = false
        end
    elseif d.line.Visible then
        d.line.Visible = false
    end

    if cfg.ESP_Skeleton then
        for i = 1, #d.skeleton do
            local b = d.skeleton[i]
            local p1 = char:FindFirstChild(b.from)
            local p2 = char:FindFirstChild(b.to)
            if p1 and p2 then
                local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                    b.line.From = Vector2.new(s1.X, s1.Y)
                    b.line.To = Vector2.new(s2.X, s2.Y)
                    b.line.Color = color; b.line.Visible = true
                else
                    b.line.Visible = false
                end
            else
                b.line.Visible = false
            end
        end
    else
        for i = 1, #d.skeleton do
            if d.skeleton[i].line.Visible then d.skeleton[i].line.Visible = false end
        end
    end
end

local silentFovCircle
if Drawing and Drawing.new then
    local ok, c = pcall(function() return Drawing.new("Circle") end)
    if ok and c then
        silentFovCircle = c
        silentFovCircle.Visible = false
        silentFovCircle.Thickness = 2
        silentFovCircle.Color = FOV_DEFAULT_COLOR
        silentFovCircle.Filled = false
        silentFovCircle.Transparency = 0.8
        silentFovCircle.Radius = 1
        silentFovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        silentFovCircle = {Visible=false, Radius=1, Position=Vector2.new(0,0), Color=FOV_DEFAULT_COLOR, Thickness=2, Transparency=0.8}
    end
else
    silentFovCircle = {Visible=false, Radius=1, Position=Vector2.new(0,0), Color=FOV_DEFAULT_COLOR, Thickness=2, Transparency=0.8}
end

lplr.CharacterAdded:Connect(function()
    silentAimTarget = nil
    task.spawn(function()

        task.wait(0.5)
        if cfg.Fly_Enabled then flyActive = false; startFly() end
        if cfg.WalkSpeed_Enabled then WalkSpeedEnabled = true; EnableWalkSpeed() end
    end)
end)

local triggerBotDebounce = false
local triggerBotLastFire = 0

task.defer(function()
    local Window = UILib:CreateWindow({
        Title = "  Symbiote ",
        Size = UDim2.new(0, 580, 0, 420),
    })
    UIWindow = Window

    runservice_c.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local guiObjects = game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
        isMouseOverUI = false
        for _, obj in ipairs(guiObjects) do
            if obj:IsDescendantOf(Window.ScreenGui) then
                isMouseOverUI = true
                break
            end
        end
    end)

    local AimbotTab = Window:CreateTab("Aimbot")
    local SilentAimTab = Window:CreateTab("Silent Aim")
    local ESPTab = Window:CreateTab("ESP")
    local PlayerTab = Window:CreateTab("Player")
    local TriggerBotTab = Window:CreateTab("Trigger Bot")

    local aimbotToggle, silentAimToggle

    AimbotTab:AddLabel("AIMBOT")
    aimbotToggle = AimbotTab:AddToggle("Aimbot", function(state)
        task.wait(0.15)
        cfg.Aimbot_Enabled = state
    end, false)

    AimbotTab:AddSeparator()
    AimbotTab:AddLabel("FILTERS")
    AimbotTab:AddToggle("Visible Check", function(s) cfg.Aimbot_VisibleCheck = s end, true)
    AimbotTab:AddToggle("Team Check", function(s) cfg.Aimbot_TeamCheck = s end, false)

    SilentAimTab:AddLabel("SILENT AIM")
    silentAimToggle = SilentAimTab:AddToggle("Silent Aim", function(state)
        task.wait(0.15)
        cfg.SilentAim_Enabled = state
        if not state then silentAimTarget = nil end
    end, false)
    SilentAimTab:AddToggle("Auto Fire", function(s) cfg.SilentAim_AutoFire = s end, true)
    SilentAimTab:AddSlider("Aim Smoothing", 0, 10, cfg.SilentAim_Smoothing, function(v) cfg.SilentAim_Smoothing = v end)

    SilentAimTab:AddSeparator()
    SilentAimTab:AddLabel("FILTERS")

    SilentAimTab:AddDropdown("Target Part", {"Head", "UpperTorso", "HumanoidRootPart"}, function(sel)
        for part in pairs(sel) do cfg.SilentAim_TargetPart = part; break end
    end)
    SilentAimTab:AddToggle("Visible Check", function(s) cfg.SilentAim_VisibleCheck = s end, true)
    SilentAimTab:AddToggle("Team Check", function(s) cfg.SilentAim_TeamCheck = s end, false)

    SilentAimTab:AddSeparator()
    SilentAimTab:AddLabel("VISUALS")
    SilentAimTab:AddToggle("Show FOV", function(s) cfg.SilentAim_ShowFOV = s end, false)
    SilentAimTab:AddSlider("FOV Size", 10, 100, cfg.SilentAim_FOV, function(v) cfg.SilentAim_FOV = v end)
    SilentAimTab:AddColorPicker("FOV Circle Color", cfg.SilentAim_FOVColor, function(c)
        cfg.SilentAim_FOVColor = c
        silentFovCircle.Color = c
    end)

    local function buildAll()
        for _, p in ipairs(players_c:GetPlayers()) do
            if p ~= lplr and p.Character and not espData[p.Character] then
                -- try to build even if not yet alive, render will hide if dead
                pcall(function() buildESP(p, p.Character) end)
            end
        end
    end

    ESPTab:AddLabel("ESP")
    ESPTab:AddToggle("ESP Outline", function(s) cfg.ESP_Enabled = s; if s then buildAll() end end, false)

    ESPTab:AddToggle("ESP Chams", function(s) cfg.ESP_Chams = s; if s then buildAll() end end, false)
    ESPTab:AddToggle("ESP Box", function(s) cfg.ESP_Box = s; if s then buildAll() end end, false)
    ESPTab:AddToggle("ESP Skeleton", function(s) cfg.ESP_Skeleton = s; if s then buildAll() end end, false)
    ESPTab:AddToggle("ESP Lines", function(s) cfg.ESP_Lines = s; if s then buildAll() end end, false)
    ESPTab:AddSlider("ESP Max FOV", 10, 360, cfg.ESP_MaxFOV, function(v) cfg.ESP_MaxFOV = v end)

    ESPTab:AddSeparator()
    ESPTab:AddLabel("COLORS")
    ESPTab:AddColorPicker("Visible Enemy Color", cfg.ESP_VisibleEnemyColor, function(c) cfg.ESP_VisibleEnemyColor = c end)
    ESPTab:AddColorPicker("Visible Teammate Color", cfg.ESP_VisibleTeamColor, function(c) cfg.ESP_VisibleTeamColor = c end)
    ESPTab:AddColorPicker("Unvisible Enemy Color", cfg.ESP_HiddenEnemyColor, function(c) cfg.ESP_HiddenEnemyColor = c end)
    ESPTab:AddColorPicker("Unvisible Teammate Color", cfg.ESP_HiddenTeamColor, function(c) cfg.ESP_HiddenTeamColor = c end)

    PlayerTab:AddLabel("MOVEMENT")
    PlayerTab:AddToggle("Fly", function(s) cfg.Fly_Enabled = s; if s then pcall(startFly) else pcall(stopFly) end end, false)
    PlayerTab:AddSlider("Fly Speed", 1, 10, cfg.Fly_Speed, function(v) cfg.Fly_Speed = v end)
    PlayerTab:AddToggle("Bunny Hop", function(s) cfg.BunnyHop_Enabled = s end, false)
    PlayerTab:AddToggle("Noclip", function(s)
        cfg.Noclip_Enabled = s
        if s then pcall(enableNoclip) else pcall(disableNoclip) end
    end, false)

    PlayerTab:AddSeparator()
    PlayerTab:AddLabel("SPEED")
    PlayerTab:AddToggle("Walk Speed", function(s)
        cfg.WalkSpeed_Enabled = s
        WalkSpeedEnabled = s
        if s then EnableWalkSpeed() else DisableWalkSpeed() end
    end, false)
    PlayerTab:AddSlider("Walk Speed Value", 1, 200, cfg.WalkSpeed, function(v) cfg.WalkSpeed = math.floor(v) end)

    TriggerBotTab:AddLabel("TRIGGER BOT")
    TriggerBotTab:AddToggle("Trigger Bot", function(s) cfg.TriggerBot_Enabled = s end, false)
    TriggerBotTab:AddSlider("Fire Delay", 0, 10, 0, function(v) cfg.TriggerBot_FireDelay = v / 10 end)
    TriggerBotTab:AddSeparator()
    TriggerBotTab:AddLabel("FILTERS")
    TriggerBotTab:AddToggle("Team Check", function(s) cfg.TriggerBot_TeamCheck = s end, false)
    TriggerBotTab:AddToggle("Visible Check", function(s) cfg.TriggerBot_VisibleCheck = s end, false)

    local SkinChangerTab = Window:CreateTab("Skin Changer")

    local scGunDropdown = nil
    local scSkinDropdown = nil

    pcall(function()
        scItemLib = require(rs_c.Modules.ItemLibrary)
        scViewModels3 = lplr.PlayerScripts.Assets.ViewModels

        local currentGun = nil
        for _, name in ipairs(scItemLib.ViewModelOrder) do
            if scItemLib.Items[name] then
                if name ~= "MISSING_WEAPON" then
                    currentGun = name
                    scSkinMap[name] = {}
                    table.insert(scGunList, name)
                else
                    currentGun = nil
                end
            elseif currentGun and name ~= "MISSING_SKIN" then
                table.insert(scSkinMap[currentGun], name)
            end
        end

        for i = #scGunList, 1, -1 do
            if #scSkinMap[scGunList[i]] == 0 then
                scSkinMap[scGunList[i]] = nil
                table.remove(scGunList, i)
            end
        end

        table.sort(scGunList)
        for _, skins in pairs(scSkinMap) do
            table.sort(skins)
        end

        scReady = true
    end)

    SkinChangerTab:AddLabel("SELECTIONS")

    scGunDropdown = SkinChangerTab:AddDropdown("Select Gun", scGunList, function(sel)

        for gun in pairs(sel) do
            scSelectedGun = gun
            scSelectedSkin = nil
            if scSkinDropdown and scSkinMap[gun] then
                scSkinDropdown:SetOptions(scSkinMap[gun])
            end
            break
        end
    end)

    scSkinDropdown = SkinChangerTab:AddDropdown("Select Skin", {}, function(sel)
        for skin in pairs(sel) do
            scSelectedSkin = skin
            break
        end
    end)

    SkinChangerTab:AddSeparator()
    SkinChangerTab:AddLabel("ACTIONS")

    SkinChangerTab:AddButton("Apply Skin", function()
        if not scReady or not scSelectedGun or not scSelectedSkin then return end
        local skins = scSkinMap[scSelectedGun]
        if not skins then return end
        local valid = false
        for _, s in ipairs(skins) do if s == scSelectedSkin then valid = true; break end end
        if not valid then return end
        scApplySkin(scSelectedGun, scSelectedSkin)
    end)

    SkinChangerTab:AddButton("Reset All Skins", function()
        if not scReady then return end
        scResetAll()
    end)

    runservice_c.Heartbeat:Connect(function()
        if not scReady or not scViewModels3 then return end
        for gunName, data in pairs(scApplied) do
            if not data.applied then continue end
            local model, origSkin = scGetModel(gunName)
            if not model then continue end
            if origSkin and not data.original then
                data.original = origSkin
            end
            local iv = model:FindFirstChild("ItemVisual")

            if not iv or iv:GetAttribute("SC_Skin") ~= data.applied then
                local template = scGetTemplate(data.applied)
                if template then
                    scSetupItemVisual(model, template, data.applied)
                end
            end
        end
    end)
end)

local keyToFlyMap = {
    [ENUM_W] = "W", [ENUM_A] = "A", [ENUM_S] = "S", [ENUM_D] = "D",
    [ENUM_SPACE] = "Up", [ENUM_LSHIFT] = "Down",
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

runservice_c.Heartbeat:Connect(function()
    local myChar = lplr.Character
    local anyESP = cfg.ESP_Enabled or cfg.ESP_Chams or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Skeleton
    if not anyESP or not myChar then return end
    for i = 1, #espCharList do
        local char = espCharList[i]
        if char and char.Parent then
            local d = espData[char]
            if d then d.visCache = isVisible(char, myChar) end
        end
    end
end)

runservice_c.Heartbeat:Connect(function(dt)
    if not cfg.Aimbot_Enabled then aimbotFireAccum = 0; return end
    aimbotFireAccum = aimbotFireAccum + dt
    if aimbotFireAccum >= AIMBOT_SHOT_INTERVAL then
        aimbotFireAccum = 0
        pcall(aimbotFire)
    end
end)

runservice_c.Heartbeat:Connect(function()
    if #toRemove > 0 then
        for i = #toRemove, 1, -1 do destroyESP(toRemove[i]) end
        table.clear(toRemove)
    end
    if cfg.BunnyHop_Enabled then
        local now = tick()
        if now - lastStatTime >= STAT_INTERVAL then
            lastStatTime = now
        end
    end

end)

runservice_c.Heartbeat:Connect(function()
    if not cfg.TriggerBot_Enabled then return end
    if triggerBotDebounce then return end
    local myChar = lplr.Character
    if not myChar then return end
    local target = Mouse.Target
    if not target then return end
    local targetPlr = players_c:GetPlayerFromCharacter(target.Parent)
    if not targetPlr then targetPlr = players_c:GetPlayerFromCharacter(target.Parent and target.Parent.Parent) end
    if not targetPlr or targetPlr == lplr then return end
    local char = targetPlr.Character
    if not char or not isAlive(char) then return end
    if cfg.TriggerBot_TeamCheck and isTeammate(char) then return end
    if cfg.TriggerBot_VisibleCheck and not isVisible(char, myChar) then return end
    local now = tick()
    if now - triggerBotLastFire < cfg.TriggerBot_FireDelay then return end
    triggerBotDebounce = true
    task.delay(cfg.TriggerBot_FireDelay, function()
        if cfg.TriggerBot_Enabled and canClick then
            triggerBotLastFire = tick()
            mouse1click()
        end
        triggerBotDebounce = false
    end)
end)

local WORLD_UP = Vector3.new(0, 1, 0)

local function safeAimCFrame(camPos, targetPos, currentCamCF)
    local lookVector = targetPos - camPos
    local dist = lookVector.Magnitude
    if dist < 0.5 then return nil end
    lookVector = lookVector / dist

    local upRef = WORLD_UP
    if math.abs(lookVector:Dot(upRef)) > 0.9995 then
        upRef = currentCamCF.RightVector
    end

    local rightVector = lookVector:Cross(upRef)
    if rightVector.Magnitude < 0.0001 then
        rightVector = currentCamCF.RightVector
    else
        rightVector = rightVector.Unit
    end

    local upVector = rightVector:Cross(lookVector).Unit

    local cf = CFrame.fromMatrix(camPos, rightVector, upVector, -lookVector)

    local pos = cf.Position
    if pos.X ~= pos.X or pos.Y ~= pos.Y or pos.Z ~= pos.Z then

        return nil
    end

    return cf
end

local lastAimCF = nil

runservice_c:BindToRenderStep("SilentAimCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not cfg.SilentAim_Enabled or not (silentAimTarget and silentAimTarget.Parent) then
        lastAimCF = nil
        return
    end

    local ok, targetPos = pcall(function() return silentAimTarget.Position end)
    if not ok or typeof(targetPos) ~= "Vector3" then
        lastAimCF = nil
        return
    end

    local camCF = Camera.CFrame
    local newCF = safeAimCFrame(camCF.Position, targetPos, camCF)
    if newCF then
        if cfg.SilentAim_Smoothing and cfg.SilentAim_Smoothing > 0 then
            if not lastAimCF then
                lastAimCF = camCF
            else
                lastAimCF = CFrame.new(camCF.Position) * lastAimCF.Rotation
            end
            local rate = 20 - (cfg.SilentAim_Smoothing - 1) * 1.6667
            local alpha = math.clamp(dt * rate, 0.01, 1)
            lastAimCF = lastAimCF:Lerp(newCF, alpha)
            Camera.CFrame = lastAimCF
        else
            lastAimCF = nil
            Camera.CFrame = newCF
        end

        local activeCF = Camera.CFrame
        local vms = workspace_c:FindFirstChild("ViewModels")
        if vms then

            local fp = vms:FindFirstChild("FirstPerson")
            if fp then
                if fp:IsA("Model") then
                    pcall(function() fp:PivotTo(activeCF) end)
                end
                for _, vm in ipairs(fp:GetChildren()) do
                    if vm:IsA("Model") then
                        pcall(function() vm:PivotTo(activeCF) end)
                    end
                end
            end
        end
    else
        lastAimCF = nil
    end
end)

local prevAnyESP = false

local function onRenderStep(dt)
    if cfg.SilentAim_Enabled then
        local newTarget = getSilentAimTarget()
        if newTarget then
            silentAimTarget = newTarget
        elseif silentAimTarget then
            local char = silentAimTarget.Parent
            if char then
                local stillValid = isAlive(char)
                if stillValid and cfg.SilentAim_TeamCheck and isTeammate(char) then stillValid = false end
                if stillValid and cfg.SilentAim_VisibleCheck then
                    local mc = lplr.Character
                    if mc and not isVisible(char, mc) then stillValid = false end
                end
                if not stillValid then silentAimTarget = nil end
            else
                silentAimTarget = nil
            end
        end

        if silentAimTarget and cfg.SilentAim_AutoFire and canClick and not isMouseOverUI then
            local now = tick()
            if now - silentAimLastShot >= SILENT_AIM_SHOT_COOLDOWN then
                silentAimLastShot = now
                mouse1click()
            end
        end
    else
        silentAimTarget = nil
    end

    if cfg.SilentAim_Enabled and cfg.SilentAim_ShowFOV then
        local vpSize = Camera.ViewportSize
        silentFovCircle.Radius = (cfg.SilentAim_FOV / Camera.FieldOfView) * (vpSize.Y / 2)
        silentFovCircle.Position = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
        silentFovCircle.Color = cfg.SilentAim_FOVColor or FOV_DEFAULT_COLOR
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
        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * (cfg.Fly_Speed * 100) or Vector3.zero
        flyBG.CFrame = camCF
    elseif cfg.Fly_Enabled and not flyActive then
        pcall(startFly)
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

    local anyESP = cfg.ESP_Enabled or cfg.ESP_Chams or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Skeleton
    local myChar = lplr.Character
    local totalChars = #espCharList

    if totalChars > 0 then
        if anyESP then
            prevAnyESP = true
            for i = 1, totalChars do

                local char = espCharList[i]
                if char then
                    local d = espData[char]
                    if d then updateESPDrawings(char, d, anyESP, myChar) end
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

runservice_c.RenderStepped:Connect(onRenderStep)

local function onCharAdded(char)
    task.delay(1, function()
        if not char or not char.Parent then return end
        local plr = players_c:GetPlayerFromCharacter(char)
        if plr and plr ~= lplr then
            local anyESP = cfg.ESP_Enabled or cfg.ESP_Chams or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Skeleton
            if anyESP then pcall(function() buildESP(plr, char) end) end
        end
    end)
end
-- periodic check for any missing ESP (fixes ESP not showing if toggled before char loaded)
task.spawn(function()
    while true do
        task.wait(2)
        local anyESP = cfg.ESP_Enabled or cfg.ESP_Chams or cfg.ESP_Box or cfg.ESP_Lines or cfg.ESP_Skeleton
        if anyESP then
            for _, p in ipairs(players_c:GetPlayers()) do
                if p ~= lplr and p.Character and not espData[p.Character] then
                    pcall(function() buildESP(p, p.Character) end)
                end
            end
        end
    end
end)

task.spawn(function()
    task.wait(2)
    for _, p in ipairs(players_c:GetPlayers()) do
        if p ~= lplr then
            p.CharacterAdded:Connect(onCharAdded)
        end
    end
end)

players_c.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(onCharAdded)
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})