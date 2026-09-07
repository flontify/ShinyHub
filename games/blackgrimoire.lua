-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Black Grimoire
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

local Library = createSymbioteShim("Black Grimoire")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local function GetWeaponNames()
    local names = {"Combat"}
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if itemsFolder then
        for _, child in ipairs(itemsFolder:GetChildren()) do
            if child:IsA("Folder") then
                table.insert(names, child.Name)
            end
        end
    end
    return names
end

local WeaponNames = GetWeaponNames()

local NPCNames = {"Thief", "Fire Boar", "Golem", "Slime", "Borula"}
local BossNames = {"Licht"}

local AutoFarmEnabled = false
local AutoFarmBossEnabled = false
local FlyEnabled = false

local NoClipEnabled = false
local SelectedNPCs = {}
local SelectedBosses = {}

local SelectedWeapon = nil
local AutoEquipWeapon = nil
local CurrentTarget = nil

local CurrentBossTarget = nil
local DistanceBetweenNPC = 5
local TweenSpeed = 16
local FlySpeed = 50
local NoClipConnection = nil
local FlyConnection = nil
local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local ServiceNPCESPEnabled = false

local FarmAutoSkillEnabled = false
local FarmSkillCooldown = 2
local PlayerAutoSkillEnabled = false
local PlayerSkillCooldown = 2
local FarmSelectedSkills = {}
local PlayerSelectedSkills = {}

local currentSkillList = {}
local FarmSkillDropdownRef = nil
local PlayerSkillDropdownRef = nil

local PlayerESPEnabled = false
local PlayerESPObjects = {}
local ESPLinesEnabled = false

local ESPLineObjects = {}

local OrbitEnabled = false
local OrbitTarget = nil
local OrbitSpeed = 1
local OrbitDistance = 10
local OrbitAngle = 0
local OrbitConnection = nil
local OrbitDropdownRef = nil

local TPBehindOrbitEnabled = false

local SpectateEnabled = false
local SpectateTarget = nil
local SpectateDropdownRef = nil
local lastSpectatePlayerSet = {}

local LockCameraEnabled = false

local InfiniteJumpEnabled = false
local InfiniteJumpConnection = nil

local SelectedAutoQuest = nil

local WalkSpeedEnabled = false
local WalkSpeedSmoothing = 1
local WalkSpeedConnection = nil

local LaggyRunEnabled = false
local LaggyRunDistance = 1
local LaggyRunDelay = 1
local LaggyRunConnection = nil
local LaggyRunAccum = 0

local CtrlClickTPEnabled = false
local CtrlClickTPConnection = nil

local ServiceNPCTPDropdownRef = nil

local lastServiceNPCNames = {}

local AutoActivateGrimoireEnabled = false

local function GetCurrentMana()
    local ok, result = pcall(function()
        local pg = LocalPlayer.PlayerGui
        local sg = pg:FindFirstChild("StartGui")
        if not sg then return nil end
        local lf = sg:FindFirstChild("LevelFrame")
        if not lf then return nil end
        local mf = lf:FindFirstChild("ManaFrame")
        if not mf then return nil end
        local bar = mf:FindFirstChild("Bar")
        if not bar then return nil end
        local al = bar:FindFirstChild("AmountLabel")
        if not al then return nil end
        local text = al.Text
        local firstNum = text:match("^(%d+)")

        if firstNum then return tonumber(firstNum) end
        return nil
    end)
    if ok then return result end
    return nil
end

local function GetToolManaCost(toolName)
    local char = LocalPlayer.Character

    local bp = LocalPlayer:FindFirstChild("Backpack")
    local tool = nil
    if char then tool = char:FindFirstChild(toolName) end
    if not tool and bp then tool = bp:FindFirstChild(toolName) end
    if not tool then return nil end
    local ok, tip = pcall(function() return tool.ToolTip end)
    if not ok or not tip then return nil end
    local cost = tip:match("^(%d+)%s*[Mm]ana")
    if cost then return tonumber(cost) end
    return nil
end

local function GetSkillToolNames()
    local names = {}
    local inventory = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local seen = {}
    local function checkTools(parent)
        if not parent then return end
        for _, tool in ipairs(parent:GetChildren()) do
            if tool:IsA("Tool") and not seen[tool.Name] then
                local ok, val = pcall(function()
                    return tool:GetAttribute("COOLDOWN")
                end)
                if ok and val ~= nil then
                    seen[tool.Name] = true
                    table.insert(names, tool.Name)
                end
            end
        end
    end
    checkTools(inventory)
    checkTools(char)
    return names
end

local function FindPlayerModel(player)
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return nil end
    return charsFolder:FindFirstChild(player.Name)
end

local function EquipToolByName(toolName)
    if not toolName then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return false end
    local current = char:FindFirstChildOfClass("Tool")
    if current and current.Name == toolName then return true end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local tool = bp and bp:FindFirstChild(toolName)
    if not tool then
        tool = char:FindFirstChild(toolName)
        if tool and not tool:IsA("Tool") then tool = nil end
    end
    if not tool then return false end
    pcall(function() hum:EquipTool(tool) end)
    task.wait(0.35)
    local after = char:FindFirstChildOfClass("Tool")
    return after ~= nil and after.Name == toolName
end

local function ActivateEquippedTool()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    pcall(function()
        local activateEvent = tool:FindFirstChild("Activate")
        if activateEvent then
            activateEvent:FireServer()
        else
            tool:Activate()
        end
    end)
end

local function FireSkillTool(skillToolName)
    if not skillToolName then return end
    local equipped = EquipToolByName(skillToolName)
    if not equipped then return end
    task.wait(0.1)
    ActivateEquippedTool()
end

local function GetSkillCooldown(toolName)
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local tool = nil
    if char then tool = char:FindFirstChild(toolName) end
    if not tool and bp then tool = bp:FindFirstChild(toolName) end
    if not tool then return FarmSkillCooldown end
    local ok, val = pcall(function() return tool:GetAttribute("COOLDOWN") end)
    if ok and type(val) == "number" then return val end
    return FarmSkillCooldown
end

local function GetPlayerSkillCooldown(toolName)
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local tool = nil
    if char then tool = char:FindFirstChild(toolName) end
    if not tool and bp then tool = bp:FindFirstChild(toolName) end
    if not tool then return PlayerSkillCooldown end
    local ok, val = pcall(function() return tool:GetAttribute("COOLDOWN") end)
    if ok and type(val) == "number" then return val end

    return PlayerSkillCooldown
end

local function UpdateDropdown(ref, opts)
    if not ref then return end
    pcall(function()
        if ref.UpdateOptions then ref:UpdateOptions(opts)
        elseif ref.Refresh then ref:Refresh(opts)
        elseif ref.SetOptions then ref:SetOptions(opts) end
    end)
end

local function SkillListChanged(newActions)
    if #newActions ~= #currentSkillList then return true end
    local oldSet = {}
    for _, v in ipairs(currentSkillList) do oldSet[v] = true end
    for _, v in ipairs(newActions) do if not oldSet[v] then return true end end
    return false
end

local function RefreshSkillDropdownsIfChanged(actions)
    if not actions then return end
    if not SkillListChanged(actions) then return end
    currentSkillList = actions
    local opts = #actions > 0 and actions or {"(No skills)"}
    UpdateDropdown(FarmSkillDropdownRef, opts)
    UpdateDropdown(PlayerSkillDropdownRef, opts)
end

task.spawn(function()
    while true do
        task.wait(2)
        local names = GetSkillToolNames()
        RefreshSkillDropdownsIfChanged(names)
    end
end)

task.spawn(function()
    while true do
        if not PlayerAutoSkillEnabled then task.wait(0.1); continue end
        local skillList = {}
        for k in pairs(PlayerSelectedSkills) do table.insert(skillList, k) end
        if #skillList == 0 then task.wait(0.1); continue end
        for _, skillName in ipairs(skillList) do
            if not PlayerAutoSkillEnabled then break end
            FireSkillTool(skillName)
            local cd = GetPlayerSkillCooldown(skillName)
            task.wait(cd)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not AutoActivateGrimoireEnabled then continue end
        pcall(function()
            local grimoires = Workspace:FindFirstChild("Grimoires")
            if not grimoires then return end
            local targetName = LocalPlayer.Name .. "'s Grimoire"
            local found = grimoires:FindFirstChild(targetName)
            if not found then
                local Event = ReplicatedStorage.MainRemote
                Event:FireServer("ToggleGrimoire")
            end
        end)

    end
end)

local function EnableNoClip()
    if NoClipConnection then return end
    NoClipConnection = RunService.Stepped:Connect(function()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

local function DisableNoClip()
    if NoClipConnection then NoClipConnection:Disconnect(); NoClipConnection = nil end
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end

        end

    end
end

local function EnableFly()
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.Parent = hrp
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local fHRP = char:FindFirstChild("HumanoidRootPart")
        if not fHRP or not FlyBodyVelocity or not FlyBodyGyro then return end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, FlySpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, FlySpeed, 0) end
        FlyBodyVelocity.Velocity = dir
        FlyBodyGyro.CFrame = cam.CFrame
    end)
end

local function DisableFly()
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
    if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
end

local function EnableWalkSpeed()
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect() end
    WalkSpeedConnection = RunService.Heartbeat:Connect(function()
        if not WalkSpeedEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude < 0.1 then return end
        local currentCF = hrp.CFrame
        local lookVec = currentCF.LookVector
        local rightVec = currentCF.RightVector
        local upVec = currentCF.UpVector
        local newPos = currentCF.Position + moveDir.Unit * WalkSpeedSmoothing
        hrp.CFrame = CFrame.fromMatrix(newPos, rightVec, upVec, -lookVec)
    end)
end

local function DisableWalkSpeed()
    if WalkSpeedConnection then WalkSpeedConnection:Disconnect(); WalkSpeedConnection = nil end
end

local function EnableLaggyRun()
    if LaggyRunConnection then LaggyRunConnection:Disconnect() end
    LaggyRunAccum = 0
    LaggyRunConnection = RunService.Heartbeat:Connect(function(dt)
        if not LaggyRunEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude < 0.1 then LaggyRunAccum = 0; return end
        LaggyRunAccum = LaggyRunAccum + dt
        local delayThreshold = LaggyRunDelay * 0.1
        if LaggyRunAccum < delayThreshold then return end
        LaggyRunAccum = 0
        local currentCF = hrp.CFrame
        local lookVec = currentCF.LookVector
        local rightVec = currentCF.RightVector
        local upVec = currentCF.UpVector
        local newPos = currentCF.Position + moveDir.Unit * LaggyRunDistance
        hrp.CFrame = CFrame.fromMatrix(newPos, rightVec, upVec, -lookVec)
    end)
end

local function DisableLaggyRun()
    if LaggyRunConnection then LaggyRunConnection:Disconnect(); LaggyRunConnection = nil end
    LaggyRunAccum = 0

end

local function EnableCtrlClickTP()
    if CtrlClickTPConnection then return end
    CtrlClickTPConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not CtrlClickTPEnabled then return end
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cam = Workspace.CurrentCamera
        local mousePos = UserInputService:GetMouseLocation()
        local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {char}
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, raycastParams)
        if result then
            local hitPos = result.Position
            hrp.CFrame = CFrame.new(hitPos + Vector3.new(0, 3, 0)) * (hrp.CFrame - hrp.CFrame.Position)
        end
    end)
end

local function DisableCtrlClickTP()
    if CtrlClickTPConnection then CtrlClickTPConnection:Disconnect(); CtrlClickTPConnection = nil end
end

local function EquipWeapon()
    if not SelectedWeapon then return end
    EquipToolByName(SelectedWeapon)
end

local function EquipAutoWeapon()
    if not AutoEquipWeapon then return end
    EquipToolByName(AutoEquipWeapon)
end

local function IsTargetValid(target)
    if not target or not target.Parent then return false end
    local hum = target:FindFirstChild("Humanoid")

    return hum ~= nil and hum.Health > 0
end

local function IsTargetReady(target)
    if not target or not target.Parent then return false end
    local hum = target:FindFirstChild("Humanoid")
    local hrp = target:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and hrp ~= nil and hum.Health > 0
end

local function GetAllBadEntitiesFolders()
    local folders = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") and child.Name:sub(1, 11) == "BadEntities" then
            table.insert(folders, child)
        end
    end
    return folders
end

local function FindNPCByName(npcName, exactMatch)
    local folders = GetAllBadEntitiesFolders()

    for _, folder in ipairs(folders) do
        for _, npc in pairs(folder:GetChildren()) do
            if npc:IsA("Model") then
                local matches
                if exactMatch then
                    matches = npc.Name == npcName
                else
                    matches = string.match(npc.Name, "^" .. npcName) ~= nil
                end
                if matches then
                    local hum = npc:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then return npc end
                end
            end
        end
    end
    return nil
end

local function FindTargetNPC()
    local hasSelection = false
    for _ in pairs(SelectedNPCs) do hasSelection = true; break end
    if not hasSelection then return nil end
    for npcName in pairs(SelectedNPCs) do
        local npc = FindNPCByName(npcName, true)
        if npc then return npc end
    end
    return nil
end

local function FindTargetBoss()
    local hasSelection = false
    for _ in pairs(SelectedBosses) do hasSelection = true; break end
    if hasSelection then
        for bossName in pairs(SelectedBosses) do
            local npc = FindNPCByName(bossName, false)
            if npc then return npc end
        end
    else
        local folders = GetAllBadEntitiesFolders()
        for _, folder in ipairs(folders) do
            for _, npc in pairs(folder:GetChildren()) do
                if npc:IsA("Model") then
                    for _, bn in ipairs(BossNames) do
                        if string.match(npc.Name, "^" .. bn) then
                            local h = npc:FindFirstChild("Humanoid")
                            if h and h.Health > 0 then return npc end
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function GetTargetCFrame(npcHRP)
    local targetPos = Vector3.new(npcHRP.Position.X, npcHRP.Position.Y + DistanceBetweenNPC, npcHRP.Position.Z)
    return CFrame.new(targetPos, npcHRP.Position)
end

local function TPBackToFarmPosition(pos)
    if not pos then return end
    task.wait(0.5)
    for i = 1, 2 do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(pos) end
        if i < 2 then task.wait(0.1) end
    end
end

local function FarmSkillAndWeaponLoop(isActiveFunc)
    task.spawn(function()
        while isActiveFunc() do
            local skillList = {}
            for k in pairs(FarmSelectedSkills) do table.insert(skillList, k) end

            if #skillList == 0 then
                if SelectedWeapon then
                    EquipToolByName(SelectedWeapon)
                    task.wait(0.1)
                    ActivateEquippedTool()
                end
                task.wait(0.15)
                continue
            end

            if not FarmAutoSkillEnabled then
                if SelectedWeapon then
                    EquipToolByName(SelectedWeapon)
                    task.wait(0.1)
                    ActivateEquippedTool()
                end
                task.wait(0.15)
                continue
            end

            for _, skillName in ipairs(skillList) do
                if not isActiveFunc() then break end
                if not FarmAutoSkillEnabled then break end

                local manaCost = GetToolManaCost(skillName)
                local currentMana = GetCurrentMana()

                if manaCost and currentMana and currentMana < manaCost then
                    if SelectedWeapon then
                        while isActiveFunc() do
                            local mana = GetCurrentMana()
                            if mana and manaCost and mana >= manaCost then break end
                            EquipToolByName(SelectedWeapon)
                            task.wait(0.1)
                            ActivateEquippedTool()
                            task.wait(0.15)
                        end
                    else
                        while isActiveFunc() do
                            local mana = GetCurrentMana()
                            if mana and manaCost and mana >= manaCost then break end
                            task.wait(0.2)
                        end
                    end
                end

                if not isActiveFunc() then break end
                if not FarmAutoSkillEnabled then break end

                FireSkillTool(skillName)

                local cd = GetSkillCooldown(skillName)
                local elapsed = 0
                local step = 0.25
                while isActiveFunc() and elapsed < cd do
                    if SelectedWeapon then
                        EquipToolByName(SelectedWeapon)
                        task.wait(0.1)
                        ActivateEquippedTool()
                        task.wait(step - 0.1)
                        elapsed = elapsed + step
                    else
                        task.wait(step)
                        elapsed = elapsed + step
                    end
                end
            end
        end
    end)
end

local function FarmNormalLoop()
    CurrentTarget = FindTargetNPC()
    local hadTarget = CurrentTarget ~= nil
    local lastKnownTargetPos = nil

    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled then
            heartbeat:Disconnect()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hum.PlatformStand = true
        if CurrentTarget and IsTargetReady(CurrentTarget) then

            local npcHRP = CurrentTarget:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                local targetCF = GetTargetCFrame(npcHRP)
                local dist = (hrp.Position - targetCF.Position).Magnitude
                if dist < 0.5 then hrp.CFrame = targetCF
                else
                    local alpha = math.clamp((TweenSpeed / 16) * 0.15, 0.05, 1)
                    hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
                end
            end
        end
    end)

    task.spawn(function()
        while AutoFarmEnabled do
            if CurrentTarget and IsTargetReady(CurrentTarget) then
                pcall(function()
                    ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
                end)
            end
            task.wait(0.1)
        end
    end)

    FarmSkillAndWeaponLoop(function() return AutoFarmEnabled end)

    while AutoFarmEnabled do
        task.wait(0.05)
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then CurrentTarget = nil; continue end

        local prevTarget = CurrentTarget
        if not CurrentTarget or not IsTargetValid(CurrentTarget) then
            CurrentTarget = FindTargetNPC()
        end

        local hasTargetNow = CurrentTarget ~= nil and IsTargetValid(CurrentTarget)

        if hasTargetNow then
            local npcHRP = CurrentTarget:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                lastKnownTargetPos = npcHRP.Position

            end
            hadTarget = true
        else
            if hadTarget and prevTarget ~= nil then
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                local returnPos = myHRP and myHRP.Position or nil
                task.spawn(function() TPBackToFarmPosition(returnPos) end)
            end
            hadTarget = false
        end
    end

    if heartbeat then heartbeat:Disconnect() end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")

    if hum then hum.PlatformStand = false end

    if lastKnownTargetPos then
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local pos = h and h.Position or nil
        task.spawn(function() TPBackToFarmPosition(pos) end)
    end

    CurrentTarget = nil
end

local function FarmBossLoop()
    CurrentBossTarget = FindTargetBoss()
    local hadTarget = CurrentBossTarget ~= nil
    local lastKnownTargetPos = nil

    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function()
        if not AutoFarmBossEnabled then
            heartbeat:Disconnect()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hum.PlatformStand = true
        if CurrentBossTarget and IsTargetReady(CurrentBossTarget) then
            local npcHRP = CurrentBossTarget:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                local targetCF = GetTargetCFrame(npcHRP)
                local dist = (hrp.Position - targetCF.Position).Magnitude
                if dist < 0.5 then hrp.CFrame = targetCF
                else
                    local alpha = math.clamp((TweenSpeed / 16) * 0.15, 0.05, 1)
                    hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
                end
            end
        end
    end)

    task.spawn(function()
        while AutoFarmBossEnabled do
            if CurrentBossTarget and IsTargetReady(CurrentBossTarget) then
                pcall(function()
                    ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
                end)
            end
            task.wait(0.1)
        end
    end)

    FarmSkillAndWeaponLoop(function() return AutoFarmBossEnabled end)

    while AutoFarmBossEnabled do
        task.wait(0.05)
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then CurrentBossTarget = nil; continue end

        local prevTarget = CurrentBossTarget
        if not CurrentBossTarget or not IsTargetValid(CurrentBossTarget) then
            CurrentBossTarget = FindTargetBoss()
        end

        local hasTargetNow = CurrentBossTarget ~= nil and IsTargetValid(CurrentBossTarget)

        if hasTargetNow then
            local npcHRP = CurrentBossTarget:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                lastKnownTargetPos = npcHRP.Position
            end
            hadTarget = true
        else
            if hadTarget and prevTarget ~= nil then
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                local returnPos = myHRP and myHRP.Position or nil
                task.spawn(function() TPBackToFarmPosition(returnPos) end)
            end
            hadTarget = false
        end
    end

    if heartbeat then heartbeat:Disconnect() end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end

    if lastKnownTargetPos then
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local pos = h and h.Position or nil
        task.spawn(function() TPBackToFarmPosition(pos) end)
    end

    CurrentBossTarget = nil
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if not AutoEquipWeapon then continue end
        local character = LocalPlayer.Character
        if not character then continue end
        local equipped = character:FindFirstChildOfClass("Tool")
        if equipped and equipped.Name == AutoEquipWeapon then continue end
        EquipAutoWeapon()
    end
end)

local AutoQuestRemotes = {
    ["Cut Wood Quest"] = function()

        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "CutWoods", Type = "questpls", NpcName = "Father Orfi"})
        end)
    end,
    ["Bring Water Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "BringWater", Type = "questpls", NpcName = "Larissa"})
        end)
    end,
    ["Potatoes Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "GetPotatoes", Type = "questpls", NpcName = "Chris"})
        end)
    end,
    ["Deliver Steak Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "DeliverSteak", Type = "questpls", NpcName = "Chef Jack"})
        end)
    end,
    ["Thief Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "DefeatThief", Type = "questpls", NpcName = "Johnny"})
        end)
    end,
    ["Train Body Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "TrainBody", Type = "questpls", NpcName = "Asta"})
        end)
    end,
    ["Deliver Green Juice Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "DeliverGreenJuice", Type = "questpls", NpcName = "Yuno"})
        end)
    end,
    ["Slime Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "DefeatSlime", Type = "questpls", NpcName = "DFiveX"})
        end)
    end,
    ["Fire Boar Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "DefeatFire Boar", Type = "questpls", NpcName = "Renna"})
        end)
    end,
    ["Golem Quest"] = function()
        pcall(function()
            local Event = ReplicatedStorage.MainRemote
            Event:FireServer("changeLightingToC", {Extra = "DefeatGolem", Type = "questpls", NpcName = "Davrqwy"})
        end)
    end,
}

task.spawn(function()
    while true do
        task.wait(1)
        if SelectedAutoQuest and AutoQuestRemotes[SelectedAutoQuest] then
            AutoQuestRemotes[SelectedAutoQuest]()
        end
    end

end)

local ESPObjects = {}

local function RemoveAllESP()
    for _, obj in pairs(ESPObjects) do
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
        if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
    end
    ESPObjects = {}
end

local function CreateESPForModel(model, displayName)
    if ESPObjects[model] then return end
    local rootPart = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart

    if not rootPart then return end
    local highlight = Instance.new("SelectionBox")
    highlight.Color3 = Color3.fromRGB(120, 80, 255)
    highlight.LineThickness = 0.07
    highlight.SurfaceTransparency = 0.85
    highlight.SurfaceColor3 = Color3.fromRGB(120, 80, 255)
    highlight.Adornee = model
    highlight.Parent = Workspace.CurrentCamera

    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 160, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = rootPart
    billboard.Parent = Workspace.CurrentCamera
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.52, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
    nameLabel.TextStrokeTransparency = 0.35
    nameLabel.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = displayName or model.Name
    nameLabel.Parent = billboard
    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.48, 0)
    distLabel.Position = UDim2.new(0, 0, 0.52, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    distLabel.TextStrokeTransparency = 0.35
    distLabel.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 13
    distLabel.Text = "-- m"
    distLabel.Parent = billboard
    ESPObjects[model] = {highlight = highlight, billboard = billboard, distLabel = distLabel, rootPart = rootPart}
end

RunService.Heartbeat:Connect(function()
    if not ServiceNPCESPEnabled then return end

    local character = LocalPlayer.Character
    local charHRP = character and character:FindFirstChild("HumanoidRootPart")

    local npcsFolder = Workspace:FindFirstChild("NPCs")
    local activeModels = {}
    if npcsFolder then
        for _, model in pairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") then activeModels[model] = model.Name end
        end
    end
    for model, displayName in pairs(activeModels) do
        if not ESPObjects[model] then CreateESPForModel(model, displayName) end
    end
    local toRemove = {}
    for model in pairs(ESPObjects) do
        if not activeModels[model] then table.insert(toRemove, model) end
    end
    for _, model in ipairs(toRemove) do
        local obj = ESPObjects[model]
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
        if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
        ESPObjects[model] = nil
    end
    if charHRP then
        for _, entry in pairs(ESPObjects) do
            if entry.rootPart and entry.rootPart.Parent then
                local dist = math.floor((charHRP.Position - entry.rootPart.Position).Magnitude)
                entry.distLabel.Text = dist .. " m"
            end
        end
    end

end)

local function GetNPCsForTP()
    local names = {}
    local npcsFolder = Workspace:FindFirstChild("NPCs")

    if npcsFolder then
        for _, model in pairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") then table.insert(names, model.Name) end
        end
    end
    if #names == 0 then table.insert(names, "(None)") end
    return names
end

task.spawn(function()
    while true do
        task.wait(3)
        if not ServiceNPCTPDropdownRef then continue end
        local newNames = GetNPCsForTP()
        local changed = #newNames ~= #lastServiceNPCNames
        if not changed then
            local set = {}
            for _, v in ipairs(lastServiceNPCNames) do set[v] = true end
            for _, v in ipairs(newNames) do if not set[v] then changed = true; break end end
        end
        if changed then
            lastServiceNPCNames = newNames
            UpdateDropdown(ServiceNPCTPDropdownRef, newNames)
        end
    end
end)

local function RemoveAllPlayerESP()
    for _, obj in pairs(PlayerESPObjects) do
        pcall(function()
            if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
            if obj.selBox and obj.selBox.Parent then obj.selBox:Destroy() end
        end)
    end
    PlayerESPObjects = {}
end

local function RemoveAllESPLines()
    for _, obj in pairs(ESPLineObjects) do
        pcall(function()
            if obj.line and obj.line.Parent then obj.line:Destroy() end
            if obj.outline and obj.outline.Parent then obj.outline:Destroy() end
        end)
    end
    ESPLineObjects = {}
end

local ESPLinesGui = nil

local function EnsureESPLinesGui()
    if ESPLinesGui and ESPLinesGui.Parent then return end
    ESPLinesGui = Instance.new("ScreenGui")
    ESPLinesGui.Name = "SymbioteESPLinesGui"
    ESPLinesGui.ResetOnSpawn = false
    ESPLinesGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ESPLinesGui.DisplayOrder = 998
    ESPLinesGui.IgnoreGuiInset = true
    ESPLinesGui.Parent = LocalPlayer.PlayerGui
end

local function CreateLine(parent, zIndex)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.ZIndex = zIndex or 1
    f.Parent = parent
    return f
end

local function CreatePlayerESP(player)
    if player == LocalPlayer then return end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return end
    local model = charsFolder:FindFirstChild(player.Name)
    if not model then return end
    if PlayerESPObjects[player] then return end
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not rootPart then return end

    local selBox = Instance.new("SelectionBox")
    selBox.Color3 = Color3.fromRGB(255, 60, 60)
    selBox.LineThickness = 0.07
    selBox.SurfaceTransparency = 0.88
    selBox.SurfaceColor3 = Color3.fromRGB(255, 60, 60)
    selBox.Adornee = model
    selBox.Parent = Workspace.CurrentCamera

    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 160, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = rootPart
    billboard.Parent = Workspace.CurrentCamera

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
    nameLabel.TextStrokeTransparency = 0.35
    nameLabel.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.45, 0)
    distLabel.Position = UDim2.new(0, 0, 0.55, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    distLabel.TextStrokeTransparency = 0.35
    distLabel.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
    distLabel.Font = Enum.Font.GothamBold
    distLabel.TextSize = 13
    distLabel.TextXAlignment = Enum.TextXAlignment.Center
    distLabel.Text = "0 m"
    distLabel.Parent = billboard

    PlayerESPObjects[player] = {
        model = model,
        billboard = billboard,
        selBox = selBox,
        rootPart = rootPart,
        distLabel = distLabel,
    }
end

local function RemovePlayerESP(player)
    local obj = PlayerESPObjects[player]
    if not obj then return end
    pcall(function()
        if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
        if obj.selBox and obj.selBox.Parent then obj.selBox:Destroy() end
    end)
    PlayerESPObjects[player] = nil
end

RunService.Heartbeat:Connect(function()
    if not PlayerESPEnabled then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local model = charsFolder:FindFirstChild(player.Name)
        if not model then RemovePlayerESP(player); continue end
        if not PlayerESPObjects[player] then CreatePlayerESP(player) end
        local obj = PlayerESPObjects[player]
        if not obj then continue end

        local newRoot = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
        if newRoot and newRoot ~= obj.rootPart then
            obj.rootPart = newRoot
            if obj.billboard then obj.billboard.Adornee = newRoot end
            if obj.selBox then obj.selBox.Adornee = model end
        end

        if myHRP and obj.rootPart and obj.rootPart.Parent then
            local dist = math.floor((myHRP.Position - obj.rootPart.Position).Magnitude)
            obj.distLabel.Text = dist .. " m"
        end
    end

    local toRemovePlayers = {}
    for player in pairs(PlayerESPObjects) do
        if not Players:FindFirstChild(player.Name) then table.insert(toRemovePlayers, player) end
    end
    for _, p in ipairs(toRemovePlayers) do RemovePlayerESP(p) end
end)

RunService.Heartbeat:Connect(function()
    if not ESPLinesEnabled then
        if next(ESPLineObjects) then RemoveAllESPLines() end
        return
    end
    EnsureESPLinesGui()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local cam = Workspace.CurrentCamera
    local screenBottom = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    local charsFolder = Workspace:FindFirstChild("Characters")

    local closestPlayer = nil
    local closestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not charsFolder then continue end
        local model = charsFolder:FindFirstChild(player.Name)
        if not model then continue end
        local rp = model:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        local d = (myHRP.Position - rp.Position).Magnitude
        if d < closestDist then closestDist = d; closestPlayer = player end
    end

    local activePlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not charsFolder then continue end
        local model = charsFolder:FindFirstChild(player.Name)
        if not model then
            if ESPLineObjects[player] then
                local obj = ESPLineObjects[player]
                pcall(function() if obj.outline and obj.outline.Parent then obj.outline:Destroy() end end)
                pcall(function() if obj.line and obj.line.Parent then obj.line:Destroy() end end)
                ESPLineObjects[player] = nil
            end
            continue
        end
        local rp = model:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        activePlayers[player] = true

        if not ESPLineObjects[player] then
            local outline = CreateLine(ESPLinesGui, 1)
            local line    = CreateLine(ESPLinesGui, 2)
            ESPLineObjects[player] = {line = line, outline = outline}
        end

        local obj = ESPLineObjects[player]
        local isClosest = (player == closestPlayer)
        local lineColor    = isClosest and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(180, 80, 255)
        local outlineColor = Color3.fromRGB(0, 0, 0)
        local lineThick    = isClosest and 1.5 or 1
        local outlineThick = isClosest and 2 or 1.5

        local targetScreen, targetVis = cam:WorldToViewportPoint(rp.Position)
        if not targetVis then obj.line.Visible = false; obj.outline.Visible = false; continue end

        local toPos2D = Vector2.new(targetScreen.X, targetScreen.Y)
        local dx = toPos2D.X - screenBottom.X
        local dy = toPos2D.Y - screenBottom.Y
        local length = math.sqrt(dx * dx + dy * dy)
        if length < 1 then obj.line.Visible = false; obj.outline.Visible = false; continue end

        local angle = math.deg(math.atan2(dy, dx))
        local cx = (screenBottom.X + toPos2D.X) / 2
        local cy = (screenBottom.Y + toPos2D.Y) / 2

        obj.outline.Size = UDim2.new(0, length + outlineThick, 0, lineThick + outlineThick)
        obj.outline.Position = UDim2.new(0, cx, 0, cy)

        obj.outline.Rotation = angle
        obj.outline.BackgroundColor3 = outlineColor
        obj.outline.Visible = true

        obj.line.Size = UDim2.new(0, length, 0, lineThick)
        obj.line.Position = UDim2.new(0, cx, 0, cy)
        obj.line.Rotation = angle
        obj.line.BackgroundColor3 = lineColor
        obj.line.Visible = true
    end

    local toRemoveLines = {}
    for player in pairs(ESPLineObjects) do
        if not activePlayers[player] then table.insert(toRemoveLines, player) end
    end
    for _, p in ipairs(toRemoveLines) do
        local obj = ESPLineObjects[p]
        pcall(function() if obj.outline and obj.outline.Parent then obj.outline:Destroy() end end)
        pcall(function() if obj.line and obj.line.Parent then obj.line:Destroy() end end)
        ESPLineObjects[p] = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not SpectateEnabled or not SpectateTarget then return end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return end
    local model = charsFolder:FindFirstChild(SpectateTarget.Name)
    if not model then return end
    local targetHRP = model:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local cam = Workspace.CurrentCamera
    cam.CameraSubject = targetHRP
    cam.CameraType = Enum.CameraType.Follow
end)

RunService.Heartbeat:Connect(function()
    if not LockCameraEnabled then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local charsFolder = Workspace:FindFirstChild("Characters")
    if not charsFolder then return end

    local closestPlayer = nil
    local closestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local model = charsFolder:FindFirstChild(player.Name)
        if not model then continue end
        local rp = model:FindFirstChild("HumanoidRootPart")
        if not rp then continue end
        local d = (myHRP.Position - rp.Position).Magnitude
        if d < closestDist then closestDist = d; closestPlayer = player end
    end

    if not closestPlayer then return end
    local targetModel = charsFolder:FindFirstChild(closestPlayer.Name)
    if not targetModel then return end
    local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local cam = Workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    local camPos = myHRP.Position + Vector3.new(0, 5, 0) + (myHRP.Position - targetHRP.Position).Unit * 15
    cam.CFrame = CFrame.new(camPos, targetHRP.Position)
end)

local function StopOrbit()
    OrbitEnabled = false
    if OrbitConnection then OrbitConnection:Disconnect(); OrbitConnection = nil end
end

local function StartOrbit(targetPlayer)
    StopOrbit()
    if not targetPlayer then return end
    OrbitTarget = targetPlayer

    OrbitEnabled = true
    OrbitAngle = 0

    OrbitConnection = RunService.Heartbeat:Connect(function(dt)
        if not OrbitEnabled then return end
        local charsFolder = Workspace:FindFirstChild("Characters")
        if not charsFolder then return end
        local model = charsFolder:FindFirstChild(OrbitTarget.Name)
        if not model then return end
        local targetHRP = model:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        if TPBehindOrbitEnabled then
            local targetCF = targetHRP.CFrame
            local behindPos = targetCF.Position + (-targetCF.LookVector) * OrbitDistance
            behindPos = Vector3.new(behindPos.X, targetHRP.Position.Y, behindPos.Z)
            myHRP.CFrame = CFrame.new(behindPos, targetHRP.Position)
        else
            OrbitAngle = OrbitAngle + OrbitSpeed * dt
            local x = targetHRP.Position.X + math.cos(OrbitAngle) * OrbitDistance
            local z = targetHRP.Position.Z + math.sin(OrbitAngle) * OrbitDistance
            local orbitPos = Vector3.new(x, targetHRP.Position.Y, z)
            myHRP.CFrame = CFrame.new(orbitPos, targetHRP.Position)
        end
    end)
end

local function GetOnlinePlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "(No players)") end
    return names
end

local lastOrbitPlayerSet = {}

task.spawn(function()
    while true do
        task.wait(3)
        if not OrbitDropdownRef then continue end
        local newNames = GetOnlinePlayerNames()
        local newSet = {}
        for _, n in ipairs(newNames) do newSet[n] = true end
        local changed = false
        for n in pairs(newSet) do if not lastOrbitPlayerSet[n] then changed = true; break end end
        if not changed then
            for n in pairs(lastOrbitPlayerSet) do if not newSet[n] then changed = true; break end end
        end
        if changed then
            lastOrbitPlayerSet = newSet
            local orbitTargetName = OrbitTarget and OrbitTarget.Name or nil
            UpdateDropdown(OrbitDropdownRef, newNames)
            if orbitTargetName and newSet[orbitTargetName] then
                pcall(function()
                    if OrbitDropdownRef.SetSelected then OrbitDropdownRef:SetSelected({[orbitTargetName] = true})
                    elseif OrbitDropdownRef.Select then OrbitDropdownRef:Select(orbitTargetName) end
                end)

            elseif orbitTargetName and not newSet[orbitTargetName] then
                StopOrbit(); OrbitTarget = nil
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if not SpectateDropdownRef then continue end
        local newNames = GetOnlinePlayerNames()
        local newSet = {}
        for _, n in ipairs(newNames) do newSet[n] = true end
        local changed = false
        for n in pairs(newSet) do if not lastSpectatePlayerSet[n] then changed = true; break end end
        if not changed then
            for n in pairs(lastSpectatePlayerSet) do if not newSet[n] then changed = true; break end end
        end
        if changed then
            lastSpectatePlayerSet = newSet
            local specTargetName = SpectateTarget and SpectateTarget.Name or nil
            UpdateDropdown(SpectateDropdownRef, newNames)
            if specTargetName and not newSet[specTargetName] then

                SpectateEnabled = false; SpectateTarget = nil
                pcall(function()
                    local cam = Workspace.CurrentCamera
                    local myChar = LocalPlayer.Character
                    local myHum = myChar and myChar:FindFirstChild("Humanoid")
                    if myHum then cam.CameraSubject = myHum end
                    cam.CameraType = Enum.CameraType.Custom
                end)
            end
        end
    end
end)

local Window = Library:CreateWindow({
    Title = " Symbiote ",
    Size = UDim2.new(0, 580, 0, 440),
})

local PlayerTab   = Window:CreateTab("Player")
local AutoFarmTab = Window:CreateTab("Auto Farm")
local VariousTab  = Window:CreateTab("Various")
local PVPTab      = Window:CreateTab("PVP")

PlayerTab:AddToggle("Fly", function(state)
    FlyEnabled = state
    if state then EnableFly() else DisableFly() end
end)
PlayerTab:AddSlider("Fly Speed", 50, 500, 50, function(v) FlySpeed = v end)

PlayerTab:AddToggle("NoClip", function(state)
    NoClipEnabled = state
    if state then EnableNoClip() else DisableNoClip() end
end)

PlayerTab:AddToggle("Walk Speed", function(state)
    WalkSpeedEnabled = state
    if state then EnableWalkSpeed() else DisableWalkSpeed() end
end)
PlayerTab:AddSlider("Walk Speed Amount", 1, 5, 1, function(v) WalkSpeedSmoothing = v end)

PlayerTab:AddToggle("Laggy Run", function(state)
    LaggyRunEnabled = state
    if state then EnableLaggyRun() else DisableLaggyRun() end
end)
PlayerTab:AddSlider("Laggy Run Distance", 1, 10, 1, function(v) LaggyRunDistance = v end)
PlayerTab:AddSlider("Laggy Run Delay", 1, 10, 1, function(v) LaggyRunDelay = v end)

PlayerTab:AddToggle("CTRL + Click to TP", function(state)
    CtrlClickTPEnabled = state
    if state then EnableCtrlClickTP() else DisableCtrlClickTP() end
end)

PlayerTab:AddToggle("Infinite Jump", function(state)
    InfiniteJumpEnabled = state
    if state then
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not InfiniteJumpEnabled then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect(); InfiniteJumpConnection = nil end
    end
end)

PlayerTab:AddToggle("No Fog", function(state)
    pcall(function()
        if state then Lighting.FogEnd = 9e9; Lighting.FogStart = 9e9
        else Lighting.FogEnd = 100000; Lighting.FogStart = 0 end
    end)
end)

PlayerTab:AddToggle("Full Bright", function(state)

    pcall(function()
        if state then
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1; Lighting.ClockTime = 14
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(70, 70, 70)
            Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
        end
    end)
end)

PlayerTab:AddToggle("Auto Activate Grimoire", function(state)
    AutoActivateGrimoireEnabled = state
end)

do
    local tpLocations = {
        ["Start"] = "108.905479, 54.9745331, -1096.42822, -0.602535367, 6.31144133e-08, -0.798092186, 1.07848088e-07, 1, -2.34042541e-09, 0.798092186, -8.74829027e-08, -0.602535367",
        ["CloverLeaf Village"] = "1.44555628, 45.1980209, -391.644745, -0.999909699, -7.45821627e-09, 0.0134386774, -8.10346279e-09, 1, -4.7959702e-08, -0.0134386774, -4.8064269e-08, -0.999909699",
        ["Volcano"] = "1820.0177, 250.480118, -2530.89722, -0.0742571801, 1.45191981e-09, 0.997239113, -1.37811629e-09, 1, -1.55855784e-09, -0.997239113, -1.49004564e-09, -0.0742571801",
    }
    local tpLocationOrder = {"Start", "CloverLeaf Village", "Volcano"}
    local function ParseCFrameString(cfStr)
        local nums = {}

        for numStr in cfStr:gmatch("[+-]?%d+%.?%d*[eE]?[+-]?%d*") do
            table.insert(nums, tonumber(numStr))
        end
        if #nums >= 12 then
            return CFrame.new(nums[1],nums[2],nums[3],nums[4],nums[5],nums[6],nums[7],nums[8],nums[9],nums[10],nums[11],nums[12])
        elseif #nums >= 3 then
            return CFrame.new(nums[1], nums[2], nums[3])
        end
        return nil
    end
    local tpDropdownRef
    tpDropdownRef = PlayerTab:AddDropdown("Teleport To Place", tpLocationOrder, function(selected)
        for locationName in pairs(selected) do
            local cfStr = tpLocations[locationName]
            if cfStr then
                local cf = ParseCFrameString(cfStr)
                if cf then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = cf end
                end
            end
            break
        end
        task.defer(function() pcall(function() tpDropdownRef:ClearSelection() end) end)
    end)
end

do
    local weaponSelecting = false
    local weaponDropdownRef
    weaponDropdownRef = AutoFarmTab:AddDropdown("Select Weapon", WeaponNames, function(selected)
        if weaponSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then SelectedWeapon = nil; return end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do if k ~= SelectedWeapon then chosen = k; break end end
            chosen = chosen or keys[1]
            weaponSelecting = true; weaponDropdownRef:ClearSelection(); weaponSelecting = false
        end
        SelectedWeapon = chosen
    end)
end

AutoFarmTab:AddSlider("Distance To NPC (studs)", 5, 50, 5, function(v) DistanceBetweenNPC = v end)
AutoFarmTab:AddSlider("Tween Speed", 16, 300, 16, function(v) TweenSpeed = v end)

do
    local initSkillNames = GetSkillToolNames()

    local initOpts = #initSkillNames > 0 and initSkillNames or {"(No skills)"}
    FarmSkillDropdownRef = AutoFarmTab:AddDropdown("Select Skills", initOpts, function(selected)
        FarmSelectedSkills = {}
        for skillName in pairs(selected) do
            if skillName ~= "(No skills)" then FarmSelectedSkills[skillName] = true end
        end
    end)
    AutoFarmTab:AddToggle("Auto Skill", function(state) FarmAutoSkillEnabled = state end)
    AutoFarmTab:AddSlider("Cooldown Between Skills (s)", 0.5, 10, 2, function(v) FarmSkillCooldown = v end)
end

AutoFarmTab:AddToggle("Auto Farm", function(state)
    if state then
        if AutoFarmBossEnabled then AutoFarmEnabled = false; return end
        AutoFarmEnabled = true; task.spawn(FarmNormalLoop)
    else
        AutoFarmEnabled = false; CurrentTarget = nil
    end
end)

local npcOptions = {}
for _, n in ipairs(NPCNames) do table.insert(npcOptions, n) end
AutoFarmTab:AddDropdown("Select NPC", npcOptions, function(selected)
    SelectedNPCs = {}
    for npcName in pairs(selected) do SelectedNPCs[npcName] = true end
end)

AutoFarmTab:AddToggle("Auto Farm Boss", function(state)
    if state then
        if AutoFarmEnabled then AutoFarmBossEnabled = false; return end
        AutoFarmBossEnabled = true; task.spawn(FarmBossLoop)
    else
        AutoFarmBossEnabled = false; CurrentBossTarget = nil
    end
end)

local bossOptions = {}

for _, b in ipairs(BossNames) do table.insert(bossOptions, b) end
AutoFarmTab:AddDropdown("Select Boss", bossOptions, function(selected)
    SelectedBosses = {}
    for bossName in pairs(selected) do SelectedBosses[bossName] = true end
end)

VariousTab:AddToggle("Service NPC ESP", function(state)
    ServiceNPCESPEnabled = state
    if not state then RemoveAllESP() end
end)

do
    local initNPCNames = GetNPCsForTP()
    lastServiceNPCNames = initNPCNames
    local tpNPCSelecting = false
    ServiceNPCTPDropdownRef = VariousTab:AddDropdown("Teleport To NPC", initNPCNames, function(selected)
        if tpNPCSelecting then return end
        for npcName in pairs(selected) do
            if npcName == "(None)" then break end
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then break end
            local npcsFolder = Workspace:FindFirstChild("NPCs")
            if not npcsFolder then break end
            local model = npcsFolder:FindFirstChild(npcName)
            if model and model:IsA("Model") then
                local rp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
                if rp then myHRP.CFrame = CFrame.new(rp.Position + Vector3.new(0, 5, 0)) end
            end
            break
        end
        tpNPCSelecting = true
        task.defer(function()
            pcall(function() ServiceNPCTPDropdownRef:ClearSelection() end)
            tpNPCSelecting = false
        end)
    end)
end

do
    local questOptions = {
        "Cut Wood Quest", "Bring Water Quest", "Potatoes Quest", "Deliver Steak Quest",
        "Thief Quest", "Train Body Quest", "Deliver Green Juice Quest",
        "Slime Quest", "Fire Boar Quest", "Golem Quest",
    }
    local questSelecting = false
    local questDropdownRef
    questDropdownRef = VariousTab:AddDropdown("Auto Quest", questOptions, function(selected)
        if questSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then SelectedAutoQuest = nil; return end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do if k ~= SelectedAutoQuest then chosen = k; break end end
            chosen = chosen or keys[1]
            questSelecting = true; questDropdownRef:ClearSelection(); questSelecting = false
        end
        SelectedAutoQuest = chosen
    end)
end

PVPTab:AddToggle("ESP Players", function(state)
    PlayerESPEnabled = state
    if not state then RemoveAllPlayerESP() end
end)

PVPTab:AddToggle("ESP Lines", function(state)
    ESPLinesEnabled = state
    if not state then RemoveAllESPLines() end
end)

do
    local autoEquipWeaponOptions = {}
    for _, w in ipairs(WeaponNames) do table.insert(autoEquipWeaponOptions, w) end
    local autoEquipSelecting = false
    local autoEquipDropdownRef
    autoEquipDropdownRef = PVPTab:AddDropdown("Auto Equip Weapon", autoEquipWeaponOptions, function(selected)
        if autoEquipSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then AutoEquipWeapon = nil; return end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do if k ~= AutoEquipWeapon then chosen = k; break end end
            chosen = chosen or keys[1]

            autoEquipSelecting = true; autoEquipDropdownRef:ClearSelection(); autoEquipSelecting = false
        end
        AutoEquipWeapon = chosen
    end)
end

do
    local initSkillNames = GetSkillToolNames()
    local initOpts = #initSkillNames > 0 and initSkillNames or {"(No skills)"}
    PlayerSkillDropdownRef = PVPTab:AddDropdown("Select Skill", initOpts, function(selected)
        PlayerSelectedSkills = {}
        for skillName in pairs(selected) do
            if skillName ~= "(No skills)" then PlayerSelectedSkills[skillName] = true end
        end

    end)
    PVPTab:AddToggle("Auto Skill", function(state) PlayerAutoSkillEnabled = state end)
    PVPTab:AddSlider("Skill Cooldown (s)", 0.5, 10, 2, function(v) PlayerSkillCooldown = v end)
end

PVPTab:AddToggle("TP Behind While Orbit", function(state)
    TPBehindOrbitEnabled = state
    if OrbitEnabled and OrbitTarget then StartOrbit(OrbitTarget) end
end)

do

    local initPlayerNames = GetOnlinePlayerNames()
    local orbitSelecting = false
    OrbitDropdownRef = PVPTab:AddDropdown("Orbit Player", initPlayerNames, function(selected)
        if orbitSelecting then return end
        local keys = {}

        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then StopOrbit(); OrbitTarget = nil; return end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do
                local curName = OrbitTarget and OrbitTarget.Name or nil
                if k ~= curName then chosen = k; break end
            end
            chosen = chosen or keys[1]
            orbitSelecting = true; OrbitDropdownRef:ClearSelection(); orbitSelecting = false
        end
        if chosen == "(No players)" then StopOrbit(); OrbitTarget = nil; return end
        local targetPlayer = Players:FindFirstChild(chosen)
        if targetPlayer then StartOrbit(targetPlayer) else StopOrbit(); OrbitTarget = nil end
    end)
end

PVPTab:AddSlider("Orbit Speed", 1, 20, 1, function(v) OrbitSpeed = v end)
PVPTab:AddSlider("Orbit Distance", 5, 50, 10, function(v) OrbitDistance = v end)

do
    local spectateNames = GetOnlinePlayerNames()
    local spectateSelecting = false

    SpectateDropdownRef = PVPTab:AddDropdown("Spectate Player", spectateNames, function(selected)
        if spectateSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then
            SpectateEnabled = false; SpectateTarget = nil
            pcall(function()
                local cam = Workspace.CurrentCamera
                local myChar = LocalPlayer.Character
                local myHum = myChar and myChar:FindFirstChild("Humanoid")
                if myHum then cam.CameraSubject = myHum end
                cam.CameraType = Enum.CameraType.Custom
            end)
            return
        end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do
                local curName = SpectateTarget and SpectateTarget.Name or nil
                if k ~= curName then chosen = k; break end
            end
            chosen = chosen or keys[1]
            spectateSelecting = true; SpectateDropdownRef:ClearSelection(); spectateSelecting = false
        end
        if chosen == "(No players)" then
            SpectateEnabled = false; SpectateTarget = nil
            pcall(function()
                local cam = Workspace.CurrentCamera
                local myChar = LocalPlayer.Character
                local myHum = myChar and myChar:FindFirstChild("Humanoid")
                if myHum then cam.CameraSubject = myHum end
                cam.CameraType = Enum.CameraType.Custom
            end)
            return

        end
        local targetPlayer = Players:FindFirstChild(chosen)
        if targetPlayer then SpectateTarget = targetPlayer; SpectateEnabled = true
        else SpectateEnabled = false; SpectateTarget = nil end
    end)
end

PVPTab:AddToggle("Lock Camera On Closest Player", function(state)
    LockCameraEnabled = state
    if not state then
        pcall(function()
            local cam = Workspace.CurrentCamera
            local myChar = LocalPlayer.Character

            local myHum = myChar and myChar:FindFirstChild("Humanoid")
            if myHum then cam.CameraSubject = myHum end
            cam.CameraType = Enum.CameraType.Custom
        end)
    end
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})