if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
LocalPlayer.Idled:Connect(function()
    pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
end)
local Rayfield
do
    local ok, mod = pcall(function()
        if loadfile then
            local f = loadfile("rayfield")
            if f then local r = f() if r then return r end end
            f = loadfile("Rayfield.lua")
            if f then local r = f() if r then return r end end
            f = loadfile("Rayfield")
            if f then local r = f() if r then return r end end
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
if not Rayfield then warn("[ShinyHub] Rayfield failed to load - check sirius.menu/gen2 or place rayfield file locally") return end
local window
local okWin = pcall(function()
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Restaurant Tycoon 3",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "Restaurant Tycoon 3",
        Theme = "Amoled",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Restaurant Tycoon 3"}
    })
end)
if not okWin or not window then
    pcall(function()
        window = Rayfield:CreateWindow({
            Name = "ShinyHub | Restaurant Tycoon 3",
            LoadingTitle = "ShinyHub",
            LoadingSubtitle = "Restaurant Tycoon 3",
            Theme = "Default",
            ToggleUIKeybind = "K",
            DisableRayfieldPrompts = false,
            DisableBuildWarnings = false,
            ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Restaurant Tycoon 3"}
        })
    end)
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
local function addParagraph(tab, title, content)
    local ok = pcall(function() tab:CreateParagraph({Title = title, Content = content}) end)
    if not ok then
        local ok2 = pcall(function() tab:CreateLabel(title) end)
        if ok2 then pcall(function() tab:CreateLabel(content) end) end
    end
end
local homeTab = safeTab("Home", "home")
local mainTab = safeTab("Main", "backpack")
local teleportsTab = safeTab("Teleports", "map-pin")
local miscTab = safeTab("Misc", "component")
local localPlayerTab = safeTab("Local Player", "user")
local serverTab = safeTab("Server", "server")
if not homeTab then homeTab = safeTab("Home", 4483362458) end
if not mainTab then mainTab = safeTab("Main", 4483362458) end
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local events = ReplicatedStorage:WaitForChild("Events")
local restaurant = events:WaitForChild("Restaurant")
local taskCompleted = restaurant:WaitForChild("TaskCompleted")
local restaurantStatusUpdated = restaurant:WaitForChild("RestaurantStatusUpdated")
local requestTeleport = events:WaitForChild("Teleports"):WaitForChild("RequestTeleport")
local cookInputRequested = events:WaitForChild("Cook"):WaitForChild("CookInputRequested")
local unlockUpgradeRequested = events:WaitForChild("Upgrades"):WaitForChild("UnlockUpgradeRequested")
local dailyRewardClaimed = events:WaitForChild("DailyRewards"):WaitForChild("DailyRewardClaimed")
local grabFood = restaurant:WaitForChild("GrabFood")
local tipsCollected = restaurant:WaitForChild("TipsCollected")
local taskCompleted2 = events.Restaurant.TaskCompleted
local cookInputRequested2 = events.Cook:WaitForChild("CookInputRequested")
local v5 = {
    AutoCookNear = false,
    AutoCookTP = false,
    InstantCook = false,
    AutoSeatCustomers = false,
    AutoTakeOrders = false,
    AutoGiveFood = false,
    AutoPickupDirtyDishes = false,
    AutoCollectBills = false,
    AutoCollectTips = false,
    AutoClaimDaily = false,
    DebugLog = false,
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    FOV = 70,
    CameraZoom = 50,
    InfCameraZoom = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
}
local function ShowNotification(content) Notify({Title = "ShinyHub", Content = content, Duration = 3}) end
local function f2(p1, p2)
    if v5.DebugLog then
        if p2 == "warn" then warn("[ShinyHub Debug]: " .. p1) else print("[ShinyHub Debug]: " .. p1) end
        ShowNotification("Debug: " .. p1)
    end
end
local function f6()
    for _, value in pairs(Workspace.Tycoons:GetChildren()) do
        for _, value2 in pairs(value:GetChildren()) do
            if value2:IsA("ObjectValue") and value2.Value == LocalPlayer then return value end
        end
    end
    return Workspace.Tycoons:GetChildren()[7]
end
local function f7(p3)
    local surface = p3.Items.Surface
    local v11 = {}
    for _, value3 in ipairs(surface:GetChildren()) do
        if value3.Name:match("^T%d+$") then v11[#v11 + 1] = value3 end
    end
    for _, value4 in ipairs(playerGui:GetChildren()) do
        if value4.Name == "CustomerSpeechUI" and value4.Adornee then
            local findFirstChild = value4:FindFirstChild("Header", true)
            if findFirstChild and findFirstChild:IsA("TextLabel") then
                local text = findFirstChild.Text
                if text and (text:match("A table for (%d+), please%.") or text:match("Table for (%d+)")) then
                    local model = value4.Adornee:FindFirstAncestorOfClass("Model")
                    if model then
                        for _, value5 in ipairs(v11) do
                            taskCompleted2:FireServer({FurnitureModel = value5, Tycoon = p3, Name = "SendToTable", GroupId = model.Parent.Name})
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end
local function f3(p4)
    if p4 and p4:IsA("ProximityPrompt") then
        local holdDuration = p4.HoldDuration
        p4.HoldDuration = 0
        p4:InputHoldBegin()
        RunService.Heartbeat:Wait()
        p4:InputHoldEnd()
        p4.HoldDuration = holdDuration
    end
end
local function f8(p5)
    if not p5 then return end
    local surface2 = p5.Items.Surface
    local count = 0
    for _, value6 in pairs(surface2:GetChildren()) do
        if value6:FindFirstChild("Bill") then
            taskCompleted:FireServer({Tycoon = p5, Name = "CollectBill", FurnitureModel = value6})
            count = count + 1
            task.wait(0.1)
        end
    end
    if count > 0 and v5.DebugLog then f2("Collected " .. count .. " bills", "print") end
end
local function f9(p6)
    if not p6 then return end
    local surface3 = p6.Items.Surface
    local count2 = 0
    for _, value7 in pairs(surface3:GetChildren()) do
        if value7:FindFirstChild("Trash") then
            taskCompleted:FireServer({Tycoon = p6, Name = "CollectDishes", FurnitureModel = value7})
            count2 = count2 + 1
            task.wait(0.1)
        end
    end
    if count2 > 0 and v5.DebugLog then f2("Collected " .. count2 .. " dirty dishes", "print") end
end
local function f10(p7)
    if not p7 then return end
    for _, value10 in pairs(p7.Items.Surface:GetChildren()) do
        if value10.Name:match("^K%d+$") then
            cookInputRequested:FireServer("Interact", value10, "Kitchen")
            cookInputRequested:FireServer("CompleteTask", value10, "Kitchen")
            cookInputRequested:FireServer("Interact", value10, "Oven")
            cookInputRequested:FireServer("CompleteTask", value10, "Oven", false)
            task.wait(0.1)
        end
    end
end
local function f11(p8)
    if not p8 then return end
    local food = p8:FindFirstChild("Objects") and p8.Objects:FindFirstChild("Food")
    if not food then return end
    local count3 = 0
    for _, value13 in pairs(food:GetChildren()) do
        local v14 = value13
        local v16, v17 = pcall(function() grabFood:InvokeServer(v14) end)
        if not v16 and v5.DebugLog then f2("GrabFood error: " .. v17, "warn") end
        task.wait(0.1)
        for _, value14 in pairs(playerGui:GetChildren()) do
            if value14.Name == "CustomerSpeechUI" and value14.Adornee then
                local model2 = value14.Adornee:FindFirstAncestorOfClass("Model")
                if model2 then
                    if pcall(function() taskCompleted:FireServer({Name = "Serve", GroupId = model2.Parent.Name, Tycoon = p8, FoodModel = v14, CustomerId = model2.Name}) end) then
                        count3 = count3 + 1
                        task.wait(0.1)
                    elseif v5.DebugLog then f2("Failed to serve customer: " .. model2.Name, "warn") end
                end
            end
        end
    end
    if count3 > 0 and v5.DebugLog then f2("Served " .. count3 .. " foods via UI customers", "print") end
end
coroutine.wrap(function()
    while true do
        if v5.AutoCookNear then
            if f6() then
                local temp = workspace:FindFirstChild("Temp")
                if temp then
                    for _, value8 in ipairs(temp:GetDescendants()) do
                        if value8:IsA("ProximityPrompt") then
                            f3(value8)
                            task.wait(0.02)
                            for i = 1, 10 do cookInputRequested2:FireServer("Interact", workspace, "Oven") end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)()
coroutine.wrap(function()
    while true do
        if v5.AutoCookTP then
            if f6() then
                local temp2 = Workspace:FindFirstChild("Temp")
                if temp2 then
                    local character = LocalPlayer.Character
                    if character then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            for _, value9 in ipairs(temp2:GetDescendants()) do
                                if value9:IsA("ProximityPrompt") then
                                    local cframe = humanoidRootPart.CFrame
                                    humanoidRootPart.CFrame = value9.Parent.CFrame * CFrame.new(0, 0, -3)
                                    task.wait()
                                    local holdDuration2 = value9.HoldDuration
                                    value9.HoldDuration = 0
                                    value9:InputHoldBegin()
                                    RunService.Heartbeat:Wait()
                                    value9:InputHoldEnd()
                                    value9.HoldDuration = holdDuration2
                                    task.wait(0.02)
                                    for j = 1, 10 do cookInputRequested:FireServer("Interact", Workspace, "Oven") end
                                    humanoidRootPart.CFrame = cframe
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)()
coroutine.wrap(function()
    while true do
        if v5.InstantCook then
            local v12 = f6()
            if v12 then f10(v12) end
        end
        task.wait(0.5)
    end
end)()
coroutine.wrap(function()
    while true do
        if v5.AutoTakeOrders then
            local v13 = f6()
            if v13 and v13:FindFirstChild("ClientCustomers") then
                for _, value11 in pairs(v13.ClientCustomers:GetChildren()) do
                    for _, value12 in pairs(value11:GetChildren()) do
                        if value12:IsA("Model") then
                            taskCompleted:FireServer({GroupId = value11.Name, Tycoon = v13, Name = "TakeOrder", CustomerId = value12.Name})
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)()
task.spawn(function()
    while true do
        if not v5.AutoGiveFood then task.wait(1)
        else
            local v18, v19 = pcall(function()
                local v20 = f6()
                if v20 then
                    local food2 = v20:FindFirstChild("Objects") and v20.Objects:FindFirstChild("Food")
                    if food2 and #food2:GetChildren() > 0 then f11(v20) end
                end
            end)
            if not v18 and v5.DebugLog then f2("AutoGiveFood error: " .. v19, "warn") end
            task.wait(0.5)
        end
    end
end)
coroutine.wrap(function()
    while true do
        local v21 = f6()
        if v21 then
            if v5.AutoSeatCustomers then f7(v21) end
            if v5.AutoCollectBills then f8(v21) end
            if v5.AutoPickupDirtyDishes then f9(v21) end
            if v5.AutoCollectTips then tipsCollected:FireServer(v21) end
        end
        if v5.AutoClaimDaily then dailyRewardClaimed:FireServer() end
        task.wait(1)
    end
end)()
homeTab:CreateSection("Information")
addParagraph(homeTab, "Welcome", "Welcome to ShinyHub for Restaurant Tycoon 3!\nPorted to Rayfield Gen2 | Dont forget to join the discord server https://discord.gg/TtH3rBCyrv")
homeTab:CreateButton({Name = "Copy Discord Server Link", Callback = function() local cb = setclipboard or toclipboard or writeclipboard if cb then pcall(cb, "https://discord.gg/TtH3rBCyrv") end Notify({Title="Discord", Content="Discord link copied! https://discord.gg/TtH3rBCyrv", Duration=3}) end})
homeTab:CreateButton({Name = "Join Discord Server", Callback = function()
    local code = "TtH3rBCyrv"
    local req = http_request or request or (syn and syn.request) or (http and http.request) or http_request
    if not req then Notify({Title="Discord", Content="Executor does not support discord RPC", Duration=3}) return end
    for k = 6453, 6464 do
        pcall(function()
            req({Url = string.format("http://127.0.0.1:%s/rpc?v=1", tostring(k)), Method = "POST", Body = HttpService:JSONEncode({nonce = HttpService:GenerateGUID(false), args = {invite = {code = code}, code = code}, cmd = "INVITE_BROWSER"}), Headers = {Origin = "https://discord.com", ["Content-Type"] = "application/json"}})
        end)
    end
    Notify({Title="Discord", Content="Opening Discord invite...", Duration=3})
end})
addParagraph(homeTab, "Changelogs - ShinyHub", "Ported from Space Hub 1.4 to Rayfield Gen2\nRemoved feedback webhook\nKept all auto features")
homeTab:CreateSlider({Name = "Set FPS", Range = {1, 240}, Increment = 1, Suffix = " FPS", CurrentValue = 120, Flag = "SetFPS", Callback = function(value17) pcall(function() setfpscap(value17) end) end})
addParagraph(homeTab, "Credits", "Original: Space Hub | Ported: ShinyHub\nUI: Rayfield Gen2\nDont forget to join https://discord.gg/TtH3rBCyrv")
mainTab:CreateSection("Auto Features")
mainTab:CreateToggle({Name = "Auto Cook (Near Kitchen)", CurrentValue = false, Flag = "AutoCookNear", Callback = function(v) if v and v5.AutoCookTP then Notify({Title="Conflict", Content="Auto Cook TP disabled", Duration=2}) end if v and v5.InstantCook then Notify({Title="Conflict", Content="Instant Cook disabled", Duration=2}) end v5.AutoCookNear = v end})
mainTab:CreateToggle({Name = "Auto Cook (TP)", CurrentValue = false, Flag = "AutoCookTP", Callback = function(v) if v and v5.AutoCookNear then Notify({Title="Conflict", Content="Auto Cook Near disabled", Duration=2}) end if v and v5.InstantCook then Notify({Title="Conflict", Content="Instant Cook disabled", Duration=2}) end v5.AutoCookTP = v end})
mainTab:CreateToggle({Name = "Instant Cook", CurrentValue = false, Flag = "InstantCook", Callback = function(v) if v and (v5.AutoCookNear or v5.AutoCookTP) then Notify({Title="Conflict", Content="Auto Cook disabled", Duration=2}) end v5.InstantCook = v end})
mainTab:CreateToggle({Name = "Auto Seat Customers", CurrentValue = false, Flag = "AutoSeatCustomers", Callback = function(v) v5.AutoSeatCustomers = v end})
mainTab:CreateToggle({Name = "Auto Take Orders", CurrentValue = false, Flag = "AutoTakeOrders", Callback = function(v) v5.AutoTakeOrders = v end})
mainTab:CreateToggle({Name = "Auto Give Food", CurrentValue = false, Flag = "AutoGiveFood", Callback = function(v) v5.AutoGiveFood = v end})
mainTab:CreateToggle({Name = "Auto Pickup Dirty Dishes", CurrentValue = false, Flag = "AutoPickupDirtyDishes", Callback = function(v) v5.AutoPickupDirtyDishes = v end})
mainTab:CreateToggle({Name = "Auto Collect Bills", CurrentValue = false, Flag = "AutoCollectBills", Callback = function(v) v5.AutoCollectBills = v end})
teleportsTab:CreateSection("Teleports")
teleportsTab:CreateButton({Name = "Teleport To Your Tycoon", Callback = function() requestTeleport:InvokeServer("Tycoon") end})
teleportsTab:CreateButton({Name = "Teleport To Plaza", Callback = function() requestTeleport:InvokeServer("Plaza") end})
teleportsTab:CreateButton({Name = "Teleport To Farm", Callback = function() requestTeleport:InvokeServer("Farm") end})
teleportsTab:CreateButton({Name = "Teleport To EKEA", Callback = function() requestTeleport:InvokeServer("EKEA") end})
miscTab:CreateSection("Restaurant Controls")
miscTab:CreateButton({Name = "Close Restaurant", Callback = function() local v38 = f6() if v38 then restaurantStatusUpdated:FireServer(v38, "Closed") f2("Restaurant closed", "print") end end})
miscTab:CreateButton({Name = "Open Restaurant", Callback = function() local v39 = f6() if v39 then restaurantStatusUpdated:FireServer(v39, "Open") f2("Restaurant opened", "print") end end})
miscTab:CreateButton({Name = "Kick All Customers", Callback = function() local v40 = f6() if v40 then restaurantStatusUpdated:FireServer(v40, "Empty") f2("Kicked all customers", "print") end end})
miscTab:CreateToggle({Name = "Auto Collect Tips", CurrentValue = false, Flag = "AutoCollectTips", Callback = function(v) v5.AutoCollectTips = v end})
miscTab:CreateToggle({Name = "Auto Claim Daily Rewards", CurrentValue = false, Flag = "AutoClaimDaily", Callback = function(v) v5.AutoClaimDaily = v end})
miscTab:CreateToggle({Name = "Debug Log", CurrentValue = false, Flag = "DebugLog", Callback = function(v) v5.DebugLog = v f2("Debug Log " .. (v and "enabled" or "disabled"), "warn") end})
miscTab:CreateSection("Auto Upgrades")
miscTab:CreateToggle({Name = "Auto Restaurant Upgrades", CurrentValue = false, Flag = "RestaurantUpgrades", Callback = function(v) end})
coroutine.wrap(function()
    while true do
        local flag = false
        pcall(function() flag = Rayfield.Flags and Rayfield.Flags["RestaurantUpgrades"] and Rayfield.Flags["RestaurantUpgrades"].CurrentValue end)
        if flag then
            local v41 = f6()
            if v41 then
                local scrollingFrame
                pcall(function() scrollingFrame = LocalPlayer.PlayerGui:WaitForChild("UpgradesMenu"):WaitForChild("Frame"):WaitForChild("Content"):WaitForChild("Pages"):WaitForChild("Upgrades"):WaitForChild("Content"):WaitForChild("ScrollingFrame") end)
                if scrollingFrame then
                    local count4 = 0
                    for _, value18 in pairs(scrollingFrame:GetChildren()) do
                        if value18.Name == "UpgradeTemplate" and value18:FindFirstChild("Title") then
                            unlockUpgradeRequested:FireServer(v41, value18.Title.Text)
                            count4 = count4 + 1
                            task.wait(0.1)
                        end
                    end
                    if count4 > 0 and v5.DebugLog then f2("Upgraded " .. count4 .. " items", "print") end
                end
            end
        end
        task.wait(5)
    end
end)()
localPlayerTab:CreateSection("Movement")
localPlayerTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "InfiniteJump", Callback = function(v) v5.InfiniteJump = v end})
UserInputService.JumpRequest:Connect(function() if v5.InfiniteJump then local c = LocalPlayer.Character local h = c and c:FindFirstChildOfClass("Humanoid") if h then h:ChangeState("Jumping") end end end)
localPlayerTab:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(v) v5.Fly = v end})
localPlayerTab:CreateSlider({Name = "Fly Speed", Range = {1, 300}, Increment = 1, Suffix = " speed", CurrentValue = 50, Flag = "FlySpeed", Callback = function(v) v5.FlySpeed = v end})
RunService.RenderStepped:Connect(function()
    if v5.Fly then
        local character2 = LocalPlayer.Character
        if character2 then
            local humanoid = character2:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoidRootPart2 then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                humanoidRootPart2.Velocity = Vector3.new(0, 0, 0)
                local currentCamera = Workspace.CurrentCamera
                local vector = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vector = vector + currentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vector = vector - currentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vector = vector - currentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vector = vector + currentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vector = vector + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vector = vector - Vector3.new(0, 1, 0) end
                if vector.Magnitude > 0 then humanoidRootPart2.Velocity = vector.Unit * v5.FlySpeed end
            end
        end
    end
end)
localPlayerTab:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(v) v5.Noclip = v end})
RunService.Stepped:Connect(function()
    if v5.Noclip then
        local character3 = LocalPlayer.Character
        if character3 then for _, value20 in pairs(character3:GetDescendants()) do if value20:IsA("BasePart") then value20.CanCollide = false end end end
    end
end)
localPlayerTab:CreateSlider({Name = "FOV Changer", Range = {1, 120}, Increment = 1, Suffix = "", CurrentValue = 70, Flag = "FOV", Callback = function(v) v5.FOV = v Workspace.CurrentCamera.FieldOfView = v end})
localPlayerTab:CreateSlider({Name = "Change Camera Zoom", Range = {1, 1000}, Increment = 1, Suffix = "", CurrentValue = 50, Flag = "CameraZoom", Callback = function(v) v5.CameraZoom = v LocalPlayer.CameraMaxZoomDistance = v end})
localPlayerTab:CreateToggle({Name = "Inf Camera Zoom", CurrentValue = false, Flag = "InfCameraZoom", Callback = function(v) v5.InfCameraZoom = v if v then LocalPlayer.CameraMaxZoomDistance = math.huge else LocalPlayer.CameraMaxZoomDistance = v5.CameraZoom end end})
localPlayerTab:CreateSlider({Name = "Change WalkSpeed", Range = {1, 500}, Increment = 1, Suffix = "", CurrentValue = 16, Flag = "WalkSpeed", Callback = function(v) v5.WalkSpeed = v local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end end})
localPlayerTab:CreateSlider({Name = "Change JumpPower", Range = {1, 500}, Increment = 1, Suffix = "", CurrentValue = 50, Flag = "JumpPower", Callback = function(v) v5.JumpPower = v local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = v end end})
localPlayerTab:CreateSlider({Name = "Gravity Changer", Range = {0, 500}, Increment = 1, Suffix = "", CurrentValue = 196.2, Flag = "Gravity", Callback = function(v) v5.Gravity = v Workspace.Gravity = v end})
serverTab:CreateSection("Server")
serverTab:CreateButton({Name = "Server Hop", Callback = function()
    local jsonDecode = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    local v42 = jsonDecode.data[math.random(1, #jsonDecode.data)]
    while v42.id == game.JobId do v42 = jsonDecode.data[math.random(1, #jsonDecode.data)] end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, v42.id)
end})
serverTab:CreateButton({Name = "Join Small Server", Callback = function()
    local v44
    for _, value26 in pairs(HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
        if value26.id ~= game.JobId then if not v44 or value26.playing < v44.playing then v44 = value26 end end
    end
    if v44 then TeleportService:TeleportToPlaceInstance(game.PlaceId, v44.id) end
end})
serverTab:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end})
serverTab:CreateInput({Name = "JobId", PlaceholderText = "Enter JobId", RemoveTextAfterFocusLost = false, Callback = function(value27) TeleportService:TeleportToPlaceInstance(game.PlaceId, value27) end})
serverTab:CreateButton({Name = "Copy JobId", Callback = function() local cb = setclipboard or toclipboard or writeclipboard if cb then pcall(cb, game.JobId) end Notify({Title="JobId", Content="JobId copied!", Duration=2}) end})
Notify({Title="ShinyHub", Content="Restaurant Tycoon 3 Rayfield loaded! Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})
