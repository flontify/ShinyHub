-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Cursed Blade
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

local Library = createSymbioteShim("Cursed Blade")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local FlyEnabled = false
local NoClipConnection = nil
local FlyConnection = nil

local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlySpeed = 50

local InfiniteJumpEnabled = false
local InfiniteJumpConnection = nil

local WalkSpeedEnabled = false
local WalkSpeedValue = 1
local WalkSpeedConnection = nil

local LaggyRunEnabled = false
local LaggyRunDistance = 1
local LaggyRunDelay = 1
local LaggyRunConnection = nil
local LaggyRunAccum = 0

local CtrlClickTPEnabled = false
local CtrlClickTPConnection = nil

local AutoHitAllEnabled = false
local AutoCollectEnabled = false

local TPToMobsTopEnabled = false
local AutoSellEnabled = false
local SelectedWeaponType = nil

local TweenSpeed = 300
local DistanceBetweenNPC = 10

local LastValidMobCFrame = nil
local NoMobGroundLockActive = false

local sellSetState = nil

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
        local newPos = currentCF.Position + moveDir.Unit * WalkSpeedValue
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

local function GetTallestEntityModel()
    local entityFolder = Workspace:FindFirstChild("Entity")
    if not entityFolder then return nil, nil end

    local tallestTop = -math.huge
    local tallestHRP = nil
    for _, model in ipairs(entityFolder:GetChildren()) do
        if not model:IsA("Model") then continue end
        if model.Name == "Target" then continue end
        local hrp = model:FindFirstChild("HumanoidRootPart")

        if not hrp then continue end
        local topY = hrp.Position.Y
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local partTop = part.Position.Y + part.Size.Y / 2
                if partTop > topY then topY = partTop end

            end
        end
        if topY > tallestTop then
            tallestTop = topY
            tallestHRP = hrp
        end
    end
    if not tallestHRP then return nil, nil end
    return tallestHRP, tallestTop
end

local function LockCharacterOnDisable()
    task.spawn(function()
        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp then return end

        local lockedCF = hrp.CFrame

        if hum then hum.PlatformStand = false end

        for i = 1, 3 do
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if h then
                h.CFrame = lockedCF
            end
            task.wait(0.2)
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not TPToMobsTopEnabled then
        if NoMobGroundLockActive then
            NoMobGroundLockActive = false
        end
        return
    end

    local entityFolder = Workspace:FindFirstChild("Entity")
    if not entityFolder then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetHRP, tallestTop = GetTallestEntityModel()

    if not targetHRP then
        if LastValidMobCFrame then
            hum.PlatformStand = true
            NoMobGroundLockActive = true
            hrp.CFrame = LastValidMobCFrame
        else
            hum.PlatformStand = false
        end
        return
    end

    NoMobGroundLockActive = false
    hum.PlatformStand = true

    local targetPos = Vector3.new(
        targetHRP.Position.X,
        tallestTop + DistanceBetweenNPC,
        targetHRP.Position.Z
    )
    local targetCF = CFrame.new(
        targetPos,
        Vector3.new(targetHRP.Position.X, targetPos.Y, targetHRP.Position.Z)
            - Vector3.new(0, 1, 0)
    )

    LastValidMobCFrame = targetCF

    local dist = (hrp.Position - targetCF.Position).Magnitude
    if dist < 0.5 then
        hrp.CFrame = targetCF
    else
        local alpha = math.clamp((TweenSpeed / 16) * 0.15, 0.05, 1)
        hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
    end
end)

task.spawn(function()
    while true do

        task.wait(0.2)
        if not AutoHitAllEnabled then continue end
        if not SelectedWeaponType then continue end
        local entityFolder = Workspace:FindFirstChild("Entity")
        if not entityFolder then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local netMessage = char:FindFirstChild("NetMessage")
        if not netMessage then continue end
        local trigerSkill = netMessage:FindFirstChild("TrigerSkill")
        if not trigerSkill then continue end
        local models = entityFolder:GetChildren()
        for _, model in ipairs(models) do
            if not model:IsA("Model") then continue end
            if model.Name == "Target" then continue end
            local mHRP = model:FindFirstChild("HumanoidRootPart")
            if not mHRP then continue end
            local mHum = model:FindFirstChild("Humanoid")
            if not mHum or mHum.Health <= 0 then continue end
            local capturedHRP = mHRP
            local capturedSkill = trigerSkill
            local capturedType = SelectedWeaponType
            task.spawn(function()
                if capturedType == "Sword" then
                    pcall(function()
                        capturedSkill:FireServer(101, "Enter", capturedHRP.CFrame, 1)
                    end)
                elseif capturedType == "Bow" then
                    pcall(function()
                        capturedSkill:FireServer(102, "Atk", capturedHRP, {})
                    end)
                elseif capturedType == "Staff" then
                    pcall(function()
                        capturedSkill:FireServer(103, "Enter", capturedHRP.CFrame, 1)
                    end)
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not AutoCollectEnabled then continue end
        local fxFolder = Workspace:FindFirstChild("FX")
        if not fxFolder then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if not myHRP then continue end
        for _, obj in ipairs(fxFolder:GetChildren()) do
            if not AutoCollectEnabled then break end
            if obj:IsA("Model") then
                local hasHandle = obj:FindFirstChild("Handle")
                local hasItemEff = obj:FindFirstChild("ItemEff")
                if hasHandle or hasItemEff then
                    local targetPart = hasHandle or hasItemEff
                    pcall(function()
                        targetPart.CFrame = myHRP.CFrame
                    end)
                end
            elseif (obj:IsA("BasePart") or obj:IsA("MeshPart")) and obj.Name == "EXP" then
                pcall(function()
                    obj.CFrame = myHRP.CFrame
                end)
            end
        end
    end
end)

local sellPayload = table.create(100)
for i = 1, 100 do sellPayload[i] = i end

local sellRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("RemoteEvent")

local function bindSellState(char)
    local net = char:WaitForChild("NetMessage")
    sellSetState = net:WaitForChild("SetState")
end

if LocalPlayer.Character then bindSellState(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindSellState)

local function doSell()
    if not sellSetState then return end
    sellSetState:FireServer("action", true)
    task.wait(0.05)
    sellSetState:FireServer("action", false)
    sellRemote:FireServer(539767613, sellPayload)

end

task.spawn(function()
    while true do
        if AutoSellEnabled then
            doSell()
            task.wait(10)
        else
            task.wait(0.5)
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

PlayerTab:AddToggle("Fly", function(state)

    FlyEnabled = state
    if state then EnableFly() else DisableFly() end
end)
PlayerTab:AddSlider("Fly Speed", 50, 500, 50, function(v) FlySpeed = v end)

PlayerTab:AddToggle("NoClip", function(state)
    if state then EnableNoClip() else DisableNoClip() end
end)

PlayerTab:AddToggle("Walk Speed", function(state)
    WalkSpeedEnabled = state
    if state then EnableWalkSpeed() else DisableWalkSpeed() end
end)
PlayerTab:AddSlider("Walk Speed Amount", 1, 20, 1, function(v)
    local ratio = (v - 1) / (20 - 1)
    WalkSpeedValue = 1 + ratio * (5 * 5 - 1)

end)

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

do
    local weaponTypeSelecting = false
    local weaponTypeDropdownRef
    weaponTypeDropdownRef = AutoFarmTab:AddDropdown("Select Weapon Type", {"Sword", "Bow", "Staff"}, function(selected)

        if weaponTypeSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then SelectedWeaponType = nil; return end
        local chosen

        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do if k ~= SelectedWeaponType then chosen = k; break end end
            chosen = chosen or keys[1]
            weaponTypeSelecting = true; weaponTypeDropdownRef:ClearSelection(); weaponTypeSelecting = false
        end
        SelectedWeaponType = chosen
    end)
end

AutoFarmTab:AddToggle("Auto Hit All", function(state)
    AutoHitAllEnabled = state
end)

AutoFarmTab:AddToggle("TP To Mobs Top", function(state)
    TPToMobsTopEnabled = state
    if not state then
        LockCharacterOnDisable()
        NoMobGroundLockActive = false
        LastValidMobCFrame = nil
    end
end)

VariousTab:AddToggle("Auto Collect", function(state)
    AutoCollectEnabled = state
end)

VariousTab:AddToggle("Auto Sell (All)", function(state)
    AutoSellEnabled = state
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})