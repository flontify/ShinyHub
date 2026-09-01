if not game:IsLoaded() then game.Loaded:Wait() end
local DISCORD_INVITE = "https://discord.gg/qgUGqmCxb3"
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local autoSteal = false
local autoCollect = false
local autoLock = false
local autoHatch = false
local selectedEgg = 1
local hatchInterval = 1
local webhookUrl = ""
local autoWebhook = false
local autoWebhookInterval = 60
local webhookUsername = "ShinyHub"
local startTime = os.time()
local function copyToClipboard(text)
    local clip = setclipboard or toclipboard or writeclipboard
    if not clip then return false end
    return pcall(clip, text)
end
local function getValue(path)
    local ok, val = pcall(function()
        local cur = LocalPlayer
        for _, name in ipairs(path) do cur = cur:WaitForChild(name) end
        if cur.Value ~= nil then return cur.Value end
        return cur
    end)
    if ok then return val end
    return nil
end
local function getCoins()
    return getValue({"Coins"}) or getValue({"leaderstats","Coins"}) or getValue({"leaderstats","Cash"}) or getValue({"Cash"}) or getValue({"Data","Coins"}) or 0
end
local function getEggs()
    return getValue({"Eggs"}) or getValue({"leaderstats","Eggs"}) or 0
end
local function findRemote(names)
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            for _, n in ipairs(names) do
                if v.Name:lower():find(n:lower()) then
                    return v
                end
            end
        end
    end
    return nil
end
local function fireRemote(remote, ...)
    if not remote then return end
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end)
end
local function getHRP()
    local c = LocalPlayer.Character
    if c then return c:FindFirstChild("HumanoidRootPart") end
    return nil
end
local function getMyPlot()
    local containers = {workspace:FindFirstChild("Plots"), workspace:FindFirstChild("Bases"), workspace:FindFirstChild("Tycoons"), workspace}
    for _, cont in ipairs(containers) do
        if cont then
            for _, plot in ipairs(cont:GetChildren()) do
                local ownerVal = plot:GetAttribute("Owner") or plot:GetAttribute("OwnerId") or plot:GetAttribute("Player")
                if ownerVal and (tostring(ownerVal) == tostring(LocalPlayer.UserId) or tostring(ownerVal) == LocalPlayer.Name) then
                    return plot
                end
                local ownerObj = plot:FindFirstChild("Owner") or plot:FindFirstChild("OwnerValue")
                if ownerObj and ownerObj.Value ~= nil and tostring(ownerObj.Value) == LocalPlayer.Name then
                    return plot
                end
                if plot.Name == LocalPlayer.Name then
                    return plot
                end
            end
        end
    end
    return nil
end
local function fireAllPromptsIn(model, skipOwn)
    local myPlot = skipOwn and getMyPlot()
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            if skipOwn and myPlot and desc:IsDescendantOf(myPlot) then
                continue
            end
            local name = desc.Name:lower()
            local parentName = desc.Parent and desc.Parent.Name:lower() or ""
            pcall(function()
                fireproximityprompt(desc)
            end)
        end
    end
end
Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))() or loadfile("rayfield.lua")
local window
local okWin = pcall(function()
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Steal An Egg",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by flint",
        Theme = "Amoled",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Steal An Egg"}
    })
end)
if not okWin or not window then
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Steal An Egg",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by flint",
        Theme = "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Steal An Egg"}
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
local farmTab = safeTab("Farming", "egg")
local eggsTab = safeTab("Eggs", "bird")
local discordTab = safeTab("Discord", "send")
if not farmTab then farmTab = safeTab("Farming", 4483362458) end
if not eggsTab then eggsTab = safeTab("Eggs", 4483362458) end
if not discordTab then discordTab = safeTab("Discord", 4483362458) end
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)
local function sendProgress(isTest)
    if webhookUrl == "" or webhookUrl:len() < 10 then Notify({Title = "Webhook", Content = "Set your webhook URL first!", Duration = 3}) return end
    if not webhookUrl:find("discord.com/api/webhooks") and not webhookUrl:find("discordapp.com/api/webhooks") then Notify({Title = "Webhook", Content = "Invalid webhook URL", Duration = 3}) return end
    local fields = {
        {name = "Player", value = LocalPlayer.Name, inline = true},
        {name = "Coins", value = tostring(getCoins()), inline = true},
        {name = "Eggs", value = tostring(getEggs()), inline = true},
        {name = "PlaceId", value = tostring(game.PlaceId), inline = true},
        {name = "JobId", value = game.JobId, inline = false},
    }
    local payload = {username = webhookUsername ~= "" and webhookUsername or "ShinyHub", embeds = {{title = "Steal An Egg - Progress", color = 0xFFD65C, fields = fields, footer = {text = isTest and "Test webhook" or "Auto webhook"}, timestamp = DateTime.now():ToIsoDate()}}}
    local json = HttpService:JSONEncode(payload)
    local req = (http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request))
    if not req then Notify({Title = "Webhook", Content = "Executor does not support http_request", Duration = 4}) return end
    local ok, res = pcall(function() return req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json}) end)
    if not ok then ok, res = pcall(function() return req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json, body = json}) end) end
    if ok and res then
        local code = res.StatusCode or res.Status or 0
        if code == 200 or code == 204 then Notify({Title = "Webhook", Content = "Sent! Coins: "..tostring(getCoins()), Duration = 2})
        else Notify({Title = "Webhook", Content = "Discord returned "..tostring(code), Duration = 4}) warn("Webhook response:", HttpService:JSONEncode(res)) end
    else Notify({Title = "Webhook", Content = "Failed - check F9", Duration = 4}) warn("Webhook error:", res) end
end
farmTab:CreateSection("Stealing")
farmTab:CreateToggle({
    Name = "Auto Steal Egg (Proximity)",
    CurrentValue = false,
    Flag = "AutoStealEgg",
    Callback = function(Value)
        autoSteal = Value
        if Value then
            task.spawn(function()
                while autoSteal do
                    pcall(function()
                        local hrp = getHRP()
                        if hrp then
                            local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Bases") or workspace
                            local myPlot = getMyPlot()
                            local targets = {}
                            for _, desc in ipairs(workspace:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local promptName = desc.Name:lower()
                                    local action = desc.ActionText and desc.ActionText:lower() or ""
                                    local objName = desc.ObjectText and desc.ObjectText:lower() or ""
                                    local isSteal = promptName:find("steal") or action:find("steal") or objName:find("steal") or objName:find("egg") or promptName:find("collect") or promptName:find("claim")
                                    if isSteal and desc.Enabled then
                                        if not (myPlot and desc:IsDescendantOf(myPlot)) then
                                            table.insert(targets, desc)
                                        end
                                    end
                                end
                            end
                            table.sort(targets, function(a,b)
                                local pa = a.Parent and a.Parent:IsA("BasePart") and a.Parent.Position or a.Parent and a.Parent:GetPivot().Position or hrp.Position
                                local pb = b.Parent and b.Parent:IsA("BasePart") and b.Parent.Position or b.Parent and b.Parent:GetPivot().Position or hrp.Position
                                local posA = (a.Adornee and a.Adornee:IsA("BasePart") and a.Adornee.Position) or pa
                                local posB = (b.Adornee and b.Adornee:IsA("BasePart") and b.Adornee.Position) or pb
                                return (hrp.Position - posA).Magnitude < (hrp.Position - posB).Magnitude
                            end)
                            for i = 1, math.min(2, #targets) do
                                local prompt = targets[i]
                                local adornee = prompt.Adornee
                                local targetPos
                                if adornee and adornee:IsA("BasePart") then
                                    targetPos = adornee.Position + Vector3.new(0, 3, 0)
                                elseif prompt.Parent and prompt.Parent:IsA("BasePart") then
                                    targetPos = prompt.Parent.Position + Vector3.new(0, 3, 0)
                                elseif prompt.Parent and prompt.Parent:GetPivot() then
                                    targetPos = prompt.Parent:GetPivot().Position + Vector3.new(0, 3, 0)
                                end
                                if targetPos then
                                    hrp.CFrame = CFrame.new(targetPos)
                                    task.wait(0.35)
                                    fireproximityprompt(prompt)
                                    task.wait(0.4)
                                end
                            end
                            local remote = findRemote({"steal", "claim", "collect", "egg"})
                            if remote and #targets == 0 then
                                fireRemote(remote)
                            end
                        end
                    end)
                    task.wait(0.9)
                end
            end)
        end
    end,
})
farmTab:CreateToggle({
    Name = "Auto Collect Cash",
    CurrentValue = false,
    Flag = "AutoCollectCash",
    Callback = function(Value)
        autoCollect = Value
        if Value then
            task.spawn(function()
                while autoCollect do
                    pcall(function()
                        local myPlot = getMyPlot()
                        if myPlot then
                            for _, desc in ipairs(myPlot:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local txt = (desc.ActionText or ""):lower() .. (desc.ObjectText or ""):lower() .. desc.Name:lower()
                                    if txt:find("collect") or txt:find("cash") or txt:find("money") then
                                        if desc.Enabled then
                                            fireproximityprompt(desc)
                                        end
                                    end
                                end
                                if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
                                    local hrp = getHRP()
                                    if hrp and desc.Parent.Name:lower():find("collect") then
                                        firetouchinterest(hrp, desc.Parent, 0)
                                        task.wait(0.05)
                                        firetouchinterest(hrp, desc.Parent, 1)
                                    end
                                end
                            end
                        end
                        local remote = findRemote({"collect", "cash", "money", "claim"})
                        if remote then
                        end
                    end)
                    task.wait(1.2)
                end
            end)
        end
    end,
})
farmTab:CreateToggle({
    Name = "Auto Lock Base",
    CurrentValue = false,
    Flag = "AutoLockBase",
    Callback = function(Value)
        autoLock = Value
        if Value then
            task.spawn(function()
                while autoLock do
                    pcall(function()
                        local myPlot = getMyPlot()
                        if myPlot then
                            for _, desc in ipairs(myPlot:GetDescendants()) do
                                if desc:IsA("ProximityPrompt") then
                                    local txt = (desc.ActionText or ""):lower() .. (desc.ObjectText or ""):lower() .. desc.Name:lower()
                                    if txt:find("lock") then
                                        if desc.Enabled then
                                            fireproximityprompt(desc)
                                        end
                                    end
                                end
                            end
                        end
                        local remote = findRemote({"lock"})
                        if remote then fireRemote(remote) end
                    end)
                    task.wait(4)
                end
            end)
        end
    end,
})
farmTab:CreateSection("Teleport")
farmTab:CreateButton({
    Name = "Teleport to Own Base",
    Callback = function()
        local p = getMyPlot()
        local hrp = getHRP()
        if p and hrp then
            local cf = p:GetPivot()
            hrp.CFrame = cf + Vector3.new(0, 5, 0)
            Notify({Title = "Teleport", Content = "Teleported to your base", Duration = 2})
        else
            Notify({Title = "Teleport", Content = "Own base not found", Duration = 3})
        end
    end,
})
farmTab:CreateButton({
    Name = "Teleport to Random Base",
    Callback = function()
        local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Bases")
        local list = plots and plots:GetChildren() or {}
        if #list == 0 then list = workspace:GetChildren() end
        local hrp = getHRP()
        local myPlot = getMyPlot()
        local candidates = {}
        for _, pl in ipairs(list) do
            if pl ~= myPlot and pl:IsA("Model") then table.insert(candidates, pl) end
        end
        if #candidates > 0 and hrp then
            local pick = candidates[math.random(1, #candidates)]
            hrp.CFrame = pick:GetPivot() + Vector3.new(0, 5, 0)
        end
    end,
})
eggsTab:CreateSection("Hatching")
eggsTab:CreateDropdown({
    Name = "Egg Type",
    Options = {"Egg 1","Egg 2","Egg 3","Egg 4","Egg 5","Egg 6","Egg 7","Egg 8"},
    CurrentOption = {"Egg 1"},
    MultipleOptions = false,
    Flag = "EggType",
    Callback = function(Option)
        local sel = type(Option) == "table" and Option[1] or Option
        local num = tonumber(sel:match("%d+")) or 1
        selectedEgg = num
    end,
})
eggsTab:CreateSlider({
    Name = "Hatch Interval",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "HatchInterval",
    Callback = function(Value) hatchInterval = Value end,
})
eggsTab:CreateToggle({
    Name = "Auto Hatch Egg",
    CurrentValue = false,
    Flag = "AutoHatchEgg",
    Callback = function(Value)
        autoHatch = Value
        if Value then
            task.spawn(function()
                while autoHatch do
                    pcall(function()
                        for _, desc in ipairs(workspace:GetDescendants()) do
                            if desc:IsA("ProximityPrompt") then
                                local txt = (desc.ActionText or ""):lower() .. (desc.ObjectText or ""):lower() .. desc.Name:lower()
                                if txt:find("hatch") or txt:find("buy") or txt:find("egg") then
                                    if desc.Enabled then
                                    end
                                end
                            end
                        end
                        local remote = findRemote({"hatch", "buyegg", "openegg", "egg"})
                        if remote then
                            fireRemote(remote, selectedEgg)
                            fireRemote(remote, tostring(selectedEgg))
                            fireRemote(remote, "Hatch", selectedEgg)
                        end
                    end)
                    task.wait(math.max(0.2, hatchInterval))
                end
            end)
        end
    end,
})
eggsTab:CreateButton({
    Name = "Hatch Once (Test)",
    Callback = function()
        local remote = findRemote({"hatch", "buyegg", "openegg", "egg"})
        if remote then
            fireRemote(remote, selectedEgg)
            Notify({Title = "Hatch", Content = "Fired "..remote.Name.." with "..tostring(selectedEgg), Duration = 2})
        else
            Notify({Title = "Hatch", Content = "No hatch remote found - check F9", Duration = 3})
        end
    end,
})
discordTab:CreateSection("Community")
pcall(function()
    discordTab:CreateParagraph({
        Title = "Join our Discord",
        Content = "Click the button below to copy the invite link ("..DISCORD_INVITE..") to your clipboard, then paste it in your browser."
    })
end)
pcall(function()
    discordTab:CreateLabel("Invite: "..DISCORD_INVITE, 4483362458, Color3.fromRGB(255,255,255), false)
end)
discordTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        local ok = copyToClipboard(DISCORD_INVITE)
        if ok then
            Notify({Title = "Discord", Content = "Invite link copied to clipboard!", Duration = 3})
        else
            Notify({Title = "Discord", Content = "Clipboard not available in this executor.", Duration = 4})
        end
    end,
})
discordTab:CreateButton({
    Name = "Copy Invite (Fallback)",
    Callback = function()
        Notify({Title = "Discord Invite", Content = DISCORD_INVITE, Duration = 6})
        warn("[ShinyHub] Discord Invite:", DISCORD_INVITE)
    end,
})
discordTab:CreateSection("Discord Webhook")
discordTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) webhookUrl = Text end,
})
discordTab:CreateInput({
    Name = "Webhook Username",
    PlaceholderText = "ShinyHub",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text) webhookUsername = Text end,
})
discordTab:CreateSlider({
    Name = "Auto Send Interval",
    Range = {10, 600},
    Increment = 5,
    Suffix = "s",
    CurrentValue = 60,
    Flag = "WebhookInterval2",
    Callback = function(Value) autoWebhookInterval = Value end,
})
discordTab:CreateButton({ Name = "Test Webhook", Callback = function() sendProgress(true) end, })
discordTab:CreateButton({ Name = "Send Progress Now", Callback = function() sendProgress(false) end, })
discordTab:CreateToggle({
    Name = "Auto Send Webhook",
    CurrentValue = false,
    Flag = "AutoWebhook2",
    Callback = function(Value)
        autoWebhook = Value
        if Value then
            task.spawn(function()
                while autoWebhook do
                    sendProgress(false)
                    task.wait(autoWebhookInterval)
                end
            end)
        end
    end,
})
Notify({Title = "ShinyHub", Content = "Steal An Egg loaded! Discord tab ready.", Duration = 3})
