if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
local Rayfield
do
    local ok, mod = pcall(function()
        if loadfile then
            local f = loadfile("rayfield")
            if f then return f() end
            f = loadfile("Rayfield.lua")
            if f then return f() end
            f = loadfile("Rayfield")
            if f then return f() end
        end
    end)
    if ok and mod then Rayfield = mod else Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))() end
end
local window
local okWin = pcall(function()
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Muscle Legends",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by flint",
        Theme = "Amoled",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Muscle Legends"}
    })
end)
if not okWin or not window then
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Muscle Legends",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by flint",
        Theme = "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Muscle Legends"}
    })
end
local function safeTab(name, icon)
    local tab
    pcall(function() tab = window:CreateTab({Name = name, Icon = icon}) end)
    if not tab then pcall(function() tab = window:CreateTab(name) end) end
    return tab
end
local function Notify(opts)
    if pcall(function() Rayfield:Notify(opts) end) then return end
    pcall(function() window:Notify(opts) end)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = opts.Title, Text = opts.Content or opts.Text, Duration = opts.Duration or 3}) end)
end
local mainTab = safeTab("Main", "user")
local farmingTab = safeTab("Farming", "sprout")
local glitchingTab = safeTab("Glitching", "zap")
local statusTab = safeTab("Status", "bar-chart-2")
local teleportTab = safeTab("Teleport", "map-pin")
local petsTab = safeTab("Pets", "heart")
if not mainTab then mainTab = safeTab("Main", 4483362458) end
if not farmingTab then farmingTab = safeTab("Farming", 4483362458) end
mainTab:CreateSection("Client Stats")
local timeLabel = mainTab:CreateLabel("Executor Time: 0d 0h 0m 0s")
local fpsLabel = mainTab:CreateLabel("FPS: Calculating...")
local pingLabel = mainTab:CreateLabel("Ping: Calculating...")
local smoothLabel = mainTab:CreateLabel("Smoothness: Calculating...")
local startTime = os.clock()
task.spawn(function()
    while task.wait(1) do
        local e = math.floor(os.clock() - startTime)
        pcall(function()
            timeLabel:SetText(string.format("Executor Time: %dd %dh %dm %ds", math.floor(e/86400), math.floor(e%86400/3600), math.floor(e%3600/60), e%60))
        end)
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        pcall(function() fpsLabel:SetText("FPS: " .. math.floor(workspace:GetRealPhysicsFPS())) end)
    end
end)
task.spawn(function()
    while task.wait(0.2) do
        local ok, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
        pcall(function() pingLabel:SetText("Ping: " .. (ok and ping or "N/A")) end)
    end
end)
task.spawn(function()
    while task.wait(0.3) do
        local fps = workspace:GetRealPhysicsFPS()
        local s = fps>=55 and "Very Smooth 🟢" or fps>=40 and "Smooth 🟡" or fps>=25 and "Laggy 🟠" or "Very Laggy 🔴"
        pcall(function() smoothLabel:SetText("Smoothness: " .. s) end)
    end
end)
mainTab:CreateSection("Movement")
mainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {0, 500},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = v end
    end,
})
mainTab:CreateSlider({
    Name = "JumpPower",
    Range = {0, 1500},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = v end
    end,
})
mainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(v) _G.InfJump = v end,
})
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump then
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
mainTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = true,
    Flag = "AntiFling",
    Callback = function(state)
        local function applyAntiFling(char)
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if state then
                if not hrp:FindFirstChild("AntiFling_BV") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "AntiFling_BV"
                    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                    bv.Velocity = Vector3.zero
                    bv.P = 1250
                    bv.Parent = hrp
                end
            else
                local ex = hrp:FindFirstChild("AntiFling_BV")
                if ex then ex:Destroy() end
            end
        end
        applyAntiFling(LocalPlayer.Character)
        LocalPlayer.CharacterAdded:Connect(function(c) task.wait(0.5) applyAntiFling(c) end)
    end,
})
mainTab:CreateToggle({
    Name = "Lock Position",
    CurrentValue = false,
    Flag = "LockPosition",
    Callback = function(state)
        _G.LockPosition = state
        if not state then return end
        task.spawn(function()
            while _G.LockPosition do
                local c = LocalPlayer.Character
                local hrp = c and c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                    hrp.CFrame = CFrame.new(hrp.Position)
                end
                task.wait(0.05)
            end
        end)
    end,
})
mainTab:CreateToggle({
    Name = "Show Pets",
    CurrentValue = false,
    Flag = "ShowPets",
    Callback = function(v)
        local val = LocalPlayer:FindFirstChild("hidePets")
        if val then val.Value = v end
    end,
})
mainTab:CreateToggle({
    Name = "Show Other Pets",
    CurrentValue = false,
    Flag = "ShowOtherPets",
    Callback = function(v)
        local val = LocalPlayer:FindFirstChild("showOtherPetsOn")
        if val then val.Value = v end
    end,
})
local waterParts = {}
task.spawn(function()
    local pSize = 2048
    local basePos = Vector3.new(-2, -9.5, -2)
    for x = -5, 5 do
        for z = -5, 5 do
            local p = Instance.new("Part")
            p.Size = Vector3.new(pSize, 1, pSize)
            p.Position = basePos + Vector3.new(x*pSize, 0, z*pSize)
            p.Anchored = true
            p.Transparency = 1
            p.CanCollide = true
            p.Parent = workspace
            table.insert(waterParts, p)
        end
    end
end)
mainTab:CreateToggle({
    Name = "Walk on Water",
    CurrentValue = true,
    Flag = "WalkOnWater",
    Callback = function(state)
        for _, p in pairs(waterParts) do
            if p and p.Parent then p.CanCollide = state end
        end
    end,
})
mainTab:CreateToggle({
    Name = "Auto Spin Fortune Wheel",
    CurrentValue = false,
    Flag = "AutoSpinWheel",
    Callback = function(state)
        _G.AutoSpin = state
        if not state then return end
        task.spawn(function()
            while _G.AutoSpin do
                pcall(function()
                    local rem = ReplicatedStorage.rEvents.openFortuneWheelRemote
                    rem:InvokeServer("openFortuneWheel", ReplicatedStorage.fortuneWheelChances["Fortune Wheel"])
                end)
                task.wait(1)
            end
        end)
    end,
})
mainTab:CreateDropdown({
    Name = "Time of Day",
    Options = {"Day","Night","Midnight"},
    CurrentOption = {"Day"},
    MultipleOptions = false,
    Flag = "TimeOfDay",
    Callback = function(v)
        local sel = type(v)=="table" and v[1] or v
        if sel=="Day" then Lighting.ClockTime = 12 elseif sel=="Night" then Lighting.ClockTime = 0 elseif sel=="Midnight" then Lighting.ClockTime = 6 end
    end,
})
farmingTab:CreateSection("Core Farming")
farmingTab:CreateToggle({
    Name = "Fast Rebirth",
    CurrentValue = false,
    Flag = "FastRebirth",
    Callback = function(state)
        _G.FastRebirth = state
        if not state then return end
        task.spawn(function()
            local function unequipAll()
                local pf = LocalPlayer:FindFirstChild("petsFolder")
                if not pf then return end
                for _, folder in pairs(pf:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            pcall(function() ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet) end)
                        end
                    end
                end
                task.wait(0.05)
            end
            local function equipByName(name)
                unequipAll()
                local uf = LocalPlayer.petsFolder and LocalPlayer.petsFolder:FindFirstChild("Unique")
                if not uf then return end
                for _, pet in pairs(uf:GetChildren()) do
                    if pet.Name == name then
                        pcall(function() ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet) end)
                    end
                end
            end
            local function findMachine(name)
                local mf = workspace:FindFirstChild("machinesFolder")
                if mf then local m = mf:FindFirstChild(name) if m then return m end end
                for _, f in pairs(workspace:GetChildren()) do
                    if f:IsA("Folder") and f.Name:find("machines") then local m = f:FindFirstChild(name) if m then return m end end
                end
            end
            local function pressE()
                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, "E", false, game)
            end
            while _G.FastRebirth do
                equipByName("Swift Samurai")
                for _ = 1, 15 do
                    if not _G.FastRebirth then break end
                    pcall(function() LocalPlayer.muscleEvent:FireServer("rep") end)
                end
                task.wait(0.1)
                if not _G.FastRebirth then break end
                equipByName("Tribal Overlord")
                local machine = findMachine("Jungle Bar Lift")
                if machine and machine:FindFirstChild("interactSeat") then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = machine.interactSeat.CFrame * CFrame.new(0,3,0)
                        task.wait(0.1)
                        pressE()
                        if char:FindFirstChild("Humanoid") and char.Humanoid.Sit then
                            pcall(function() ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest") end)
                            task.wait(0.15)
                        end
                    end
                end
                task.wait(0.2)
            end
        end)
    end,
})
farmingTab:CreateToggle({
    Name = "Ultimate Fast Strength",
    CurrentValue = false,
    Flag = "UltraStrength",
    Callback = function(state)
        _G.UltraStrength = state
        if not state then return end
        task.spawn(function()
            while _G.UltraStrength do
                for _ = 1, 5 do
                    for _ = 1, 4000 do
                        if not _G.UltraStrength then break end
                        pcall(function() LocalPlayer.muscleEvent:FireServer("rep") end)
                    end
                    task.wait(0.2)
                end
            end
        end)
    end,
})
farmingTab:CreateToggle({
    Name = "Hide ReplicatedStorage Frames",
    CurrentValue = false,
    Flag = "HideFrames",
    Callback = function(state)
        for _, obj in pairs(ReplicatedStorage:GetChildren()) do
            if obj.Name:match("Frame$") then pcall(function() obj.Visible = not state end) end
        end
    end,
})
farmingTab:CreateButton({
    Name = "Anti Lag",
    Callback = function()
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(pg:GetChildren()) do if gui:IsA("ScreenGui") then gui:Destroy() end end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then obj:Destroy() end
        end
        for _, obj in pairs(Lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end
        local sky = Instance.new("Sky")
        sky.SkyboxBk,sky.SkyboxDn,sky.SkyboxFt = "rbxassetid://0","rbxassetid://0","rbxassetid://0"
        sky.SkyboxLf,sky.SkyboxRt,sky.SkyboxUp = "rbxassetid://0","rbxassetid://0","rbxassetid://0"
        sky.Name = "DarkSky"
        sky.Parent = Lighting
        Lighting.Brightness = 0
        Lighting.ClockTime = 0
        Lighting.OutdoorAmbient = Color3.new(0,0,0)
        Lighting.Ambient = Color3.new(0,0,0)
        Lighting.FogColor = Color3.new(0,0,0)
        Lighting.FogEnd = 100
        Notify({Title="Anti Lag", Content="Cleared effects", Duration=2})
    end,
})
farmingTab:CreateToggle({
    Name = "Unlock AutoLift Gamepass",
    CurrentValue = false,
    Flag = "UnlockAutoLift",
    Callback = function(state)
        if not state then return end
        local gamepassIds = ReplicatedStorage:FindFirstChild("gamepassIds")
        if not gamepassIds then warn("gamepassIds not found") return end
        local ownedFolder = LocalPlayer:FindFirstChild("ownedGamepasses")
        if not ownedFolder then ownedFolder = Instance.new("Folder") ownedFolder.Name = "ownedGamepasses" ownedFolder.Parent = LocalPlayer end
        for _, gp in pairs(gamepassIds:GetChildren()) do
            if not ownedFolder:FindFirstChild(gp.Name) then
                local iv = Instance.new("IntValue")
                iv.Name = gp.Name
                iv.Value = gp.Value or 1
                iv.Parent = ownedFolder
            end
        end
        Notify({Title="Gamepass", Content="Unlocked AutoLift", Duration=2})
    end,
})
farmingTab:CreateSection("Exercises & Tools")
local exerciseNames = {"Weight","Pushups","Handstands","Situps","Punch"}
for _, name in ipairs(exerciseNames) do
    local key = "AutoExercise_"..name
    farmingTab:CreateToggle({
        Name = "Auto "..name,
        CurrentValue = false,
        Flag = key,
        Callback = function(state)
            _G[key] = state
            if not state then return end
            task.spawn(function()
                while _G[key] do
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    if bp then
                        local tool = bp:FindFirstChild(name)
                        if tool and LocalPlayer.Character then pcall(function() local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h:EquipTool(tool) end end) end
                        pcall(function() LocalPlayer.muscleEvent:FireServer("rep") end)
                    end
                    task.wait(0.1)
                end
            end)
        end,
    })
end
farmingTab:CreateToggle({
    Name = "Fast Tools",
    CurrentValue = false,
    Flag = "FastTools",
    Callback = function(state)
        _G.FastTools = state
        local settings = {
            {"Punch","attackTime", state and 0 or 0.35},
            {"Ground Slam","attackTime", state and 0 or 6},
            {"Stomp","attackTime", state and 0 or 7},
            {"Handstands","repTime", state and 0 or 1},
            {"Pushups","repTime", state and 0 or 1},
            {"Weight","repTime", state and 0 or 1},
            {"Situps","repTime", state and 0 or 1},
        }
        task.spawn(function()
            local bp = LocalPlayer:WaitForChild("Backpack")
            for _, s in ipairs(settings) do
                local tName, attr, val = s[1], s[2], s[3]
                local function apply(container)
                    local t = container and container:FindFirstChild(tName)
                    if t and t:FindFirstChild(attr) then pcall(function() t[attr].Value = val end) end
                end
                apply(bp)
                apply(LocalPlayer.Character)
            end
        end)
    end,
})
farmingTab:CreateToggle({
    Name = "Auto Eat Egg | 60 min",
    CurrentValue = false,
    Flag = "AutoEat60",
    Callback = function(v) _G.AutoEat60 = v end,
})
farmingTab:CreateToggle({
    Name = "Auto Eat Egg | 30 min",
    CurrentValue = false,
    Flag = "AutoEat30",
    Callback = function(v) _G.AutoEat30 = v end,
})
task.spawn(function()
    local function eatEgg()
        local bp = LocalPlayer:WaitForChild("Backpack")
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local egg = bp:FindFirstChild("Protein Egg")
        if egg then egg.Parent = char pcall(function() egg:Activate() end) end
    end
    while true do
        if _G.AutoEat60 then eatEgg() task.wait(3600)
        elseif _G.AutoEat30 then eatEgg() task.wait(1800)
        else task.wait(1) end
    end
end)
farmingTab:CreateSection("Gym Teleports")
local gymLocs = {
    {"Jungle Bench Press", CFrame.new(-8173,64,1898)},
    {"Jungle Squat", CFrame.new(-8352,34,2878)},
    {"Jungle Pull Ups", CFrame.new(-8666,34,2070)},
    {"Jungle Boulder", CFrame.new(-8621,34,2684)},
}
for _, loc in ipairs(gymLocs) do
    local cf = loc[2]
    farmingTab:CreateButton({
        Name = loc[1],
        Callback = function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            char:WaitForChild("HumanoidRootPart").CFrame = cf
            task.wait(0.2)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end,
    })
end
Notify({Title="ShinyHub", Content="Muscle Legends Rayfield loaded", Duration=3})
