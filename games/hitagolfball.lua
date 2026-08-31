local HttpService = game:GetService("HttpService")
local autoball = false 
local ashoot = false 
local autoclub = false 
local arebirth = false
local aascend = false
local webhookUrl = ""
local autoWebhook = false
local autoWebhookInterval = 60
local webhookUsername = "ShinyHub"
local webhookIncludeCoins = true
local webhookIncludeRebirths = true
local webhookIncludeJobId = false
local lastBallPrice = 0
local lastBallName = nil
local lastClubPrice = 0
local lastClubName = nil

local Rayfield
pcall(function() Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))() end)
if not Rayfield and isfile and isfile("rayfield.lua") then
    pcall(function() Rayfield = loadstring(readfile("rayfield.lua"))() end)
end
if not Rayfield and writefile then
    local ok, src = pcall(function() return game:HttpGet("https://sirius.menu/gen2") end)
    if ok and src and src:len() > 1000 then
        pcall(function() writefile("rayfield.lua", src) end)
        pcall(function() Rayfield = loadstring(src)() end)
    end
end
assert(Rayfield, "Rayfield failed to load - enable Http Requests")

local window
local okWin = pcall(function()
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Hit A Golf Ball",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by you",
        Theme = "Amoled",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Hit A Golf Ball"}
    })
end)
if not okWin or not window then
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Hit A Golf Ball",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by you",
        Theme = "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Hit A Golf Ball"}
    })
end

local function safeTab(name, icon)
    local tab
    pcall(function() tab = window:CreateTab({Name = name, Icon = icon}) end)
    if not tab then pcall(function() tab = window:CreateTab(name) end) end
    return tab
end

local farmTab = safeTab("Farming", 4483362458)
local shopTab = safeTab("Shop", 4483362458)
local discordTab = safeTab("Discord", 4483362458)

local function getValue(path)
    local ok, val = pcall(function()
        local cur = game:GetService("Players").LocalPlayer
        for _, name in ipairs(path) do cur = cur:WaitForChild(name) end
        if cur.Value ~= nil then return cur.Value end
        return cur
    end)
    if ok then return val end
    return nil
end

local function getCoins()
    return getValue({"Coins"}) or getValue({"leaderstats","Coins"}) or getValue({"leaderstats","Cash"}) or 0
end

local function getRebirths()
    return getValue({"Rebirths"}) or getValue({"leaderstats","Rebirths"}) or getValue({"Rebirth"}) or 0
end

local function sendProgress(isTest)
    if webhookUrl == "" or webhookUrl:len() < 10 then Rayfield:Notify({Title = "Webhook", Content = "Set your webhook URL first!", Duration = 3}) return end
    if not webhookUrl:find("discord.com/api/webhooks") and not webhookUrl:find("discordapp.com/api/webhooks") then Rayfield:Notify({Title = "Webhook", Content = "Invalid webhook URL", Duration = 3}) return end
    local player = game:GetService("Players").LocalPlayer
    local fields = {}
    if webhookIncludeCoins then table.insert(fields, {name = "Coins", value = tostring(getCoins()), inline = true}) end
    if webhookIncludeRebirths then table.insert(fields, {name = "Rebirths", value = tostring(getRebirths()), inline = true}) end
    if webhookIncludeJobId then table.insert(fields, {name = "JobId", value = game.JobId, inline = false}) end
    table.insert(fields, {name = "PlaceId", value = tostring(game.PlaceId), inline = true})
    table.insert(fields, {name = "Player", value = player.Name, inline = true})
    local payload = {username = webhookUsername ~= "" and webhookUsername or "ShinyHub", embeds = {{title = "Hit A Golf Ball - Progress", color = 0x8A2BE2, fields = fields, footer = {text = isTest and "Test webhook" or "Auto webhook"}, timestamp = DateTime.now():ToIsoDate()}}}
    local json = HttpService:JSONEncode(payload)
    local req = (http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request))
    if not req then Rayfield:Notify({Title = "Webhook", Content = "Executor does not support http_request", Duration = 4}) return end
    local ok, res = pcall(function() return req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json}) end)
    if not ok then ok, res = pcall(function() return req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json, body = json}) end) end
    if ok and res then
        local code = res.StatusCode or res.Status or 0
        if code == 200 or code == 204 then Rayfield:Notify({Title = "Webhook", Content = "Sent! Coins: "..tostring(getCoins()), Duration = 2})
        else Rayfield:Notify({Title = "Webhook", Content = "Discord returned "..tostring(code), Duration = 4}) warn("Webhook response:", HttpService:JSONEncode(res)) end
    else Rayfield:Notify({Title = "Webhook", Content = "Failed - check F9", Duration = 4}) warn("Webhook error:", res) end
end

farmTab:CreateSection("Farming")
farmTab:CreateToggle({ Name = "Auto Rebirth", CurrentValue = false, Flag = "AutoRebirth", Callback = function(Value) arebirth = Value if Value then task.spawn(function() while arebirth do game:GetService("ReplicatedStorage").GolfRemotes.DoRebirth:FireServer() task.wait(5) end end) end end, })
farmTab:CreateToggle({ Name = "Auto Ascend", CurrentValue = false, Flag = "AutoAscend", Callback = function(Value) aascend = Value if Value then task.spawn(function() while aascend do game:GetService("ReplicatedStorage").GolfRemotes.AscendDo:FireServer() task.wait(5) end end) end end, })
farmTab:CreateToggle({ Name = "Auto Shoot", CurrentValue = false, Flag = "Autoshoot", Callback = function(Value) ashoot = Value if Value then task.spawn(function() while ashoot do game:GetService("ReplicatedStorage").GolfRemotes.SpawnBall:FireServer(CFrame.new(0.828187048, 4.19568777, 111.41848, 0, 0, 1, 0, 1, -0, -1, 0, -0)) task.wait(0.1) game:GetService("ReplicatedStorage").GolfRemotes.Swing:FireServer(5) task.wait(2.5) end end) end end, })

shopTab:CreateSection("Auto Buy - Best Affordable")

shopTab:CreateToggle({ Name = "Auto Buy Ball", CurrentValue = false, Flag = "Autoball", Callback = function(Value) autoball = Value if Value then task.spawn(function()
    local balls = {{4500000000,"Crystal"},{2100000000,"Engine"},{990000000,"Astronaut"},{460000000,"Rugby"},{220000000,"Gift"},{160000000,"Brick"},{62000000,"King"},{25000000,"Evil"},{9800000,"Burger"},{7700000,"Pumpkin"},{4800000,"Flower"},{3100000,"Donut"},{1900000,"Bank"},{1200000,"Rubiks"},{770000,"Poison"},{560000,"Pac"},{380000,"Eye"},{260000,"Bowling"},{180000,"Earth"},{120000,"Moon"},{86000,"Alien"},{59000,"FishBowl"},{45000,"Beach"},{32000,"Planet"},{23000,"Bomb"},{16000,"Apple"},{11000,"Duck"},}
    while autoball do
        local coins = getCoins()
        for _, v in ipairs(balls) do
            if coins >= v[1] then
                if v[1] > lastBallPrice then
                    print("Last bought ball:", v[2], "Price:", v[1])
                    Rayfield:Notify({Title = "Ball Bought", Content = v[2].." for "..tostring(v[1]), Duration = 2})
                    game:GetService("ReplicatedStorage").GolfRemotes.BuyBall:FireServer(v[2])
                    lastBallPrice = v[1]
                    lastBallName = v[2]
                end
                break
            end
        end
        task.wait(5)
    end
end) end end, })

shopTab:CreateToggle({ Name = "Auto Buy Club", CurrentValue = false, Flag = "Autoclub", Callback = function(Value) autoclub = Value if Value then task.spawn(function()
    local clubs = {{2100000000,"Steampunk"},{990000000,"Toy"},{460000000,"Feline"},{220000000,"Gear"},{160000000,"Wood"},{62000000,"Fail"},{25000000,"Evil"},{9800000,"Mushroom"},{7700000,"Chocolate"},{4800000,"Honey"},{3100000,"Fall"},{1900000,"Flower"},{1200000,"Galactic"},{770000,"Rainbow"},{560000,"Vegetal"},{380000,"Bone"},{260000,"Duck"},{180000,"Cloud"},{120000,"Lunar"},{86000,"Alien"},{59000,"Moon"},{45000,"Cyber"},{32000,"Roblox"},{23000,"Golden"},{16000,"Crystal"},{11000,"Candy"},}
    while autoclub do
        local coins = getCoins()
        for _, v in ipairs(clubs) do
            if coins >= v[1] then
                if v[1] > lastClubPrice then
                    print("Last bought club:", v[2], "Price:", v[1])
                    Rayfield:Notify({Title = "Club Bought", Content = v[2].." for "..tostring(v[1]), Duration = 2})
                    game:GetService("ReplicatedStorage").GolfRemotes.BuyClub:FireServer(v[2])
                    lastClubPrice = v[1]
                    lastClubName = v[2]
                end
                break
            end
        end
        task.wait(5)
    end
end) end end, })

discordTab:CreateSection("Discord Webhook")
discordTab:CreateInput({ Name = "Webhook URL", PlaceholderText = "https://discord.com/api/webhooks/...", RemoveTextAfterFocusLost = false, Callback = function(Text) webhookUrl = Text end, })
discordTab:CreateInput({ Name = "Webhook Username", PlaceholderText = "ShinyHub", RemoveTextAfterFocusLost = false, Callback = function(Text) webhookUsername = Text end, })
discordTab:CreateToggle({ Name = "Include Coins", CurrentValue = true, Flag = "WebhookCoins", Callback = function(Value) webhookIncludeCoins = Value end, })
discordTab:CreateToggle({ Name = "Include Rebirths", CurrentValue = true, Flag = "WebhookRebirths", Callback = function(Value) webhookIncludeRebirths = Value end, })
discordTab:CreateToggle({ Name = "Include JobId", CurrentValue = false, Flag = "WebhookJobId", Callback = function(Value) webhookIncludeJobId = Value end, })
discordTab:CreateSlider({ Name = "Auto Send Interval", Range = {10, 600}, Increment = 5, Suffix = "s", CurrentValue = 60, Flag = "WebhookInterval", Callback = function(Value) autoWebhookInterval = Value end, })
discordTab:CreateButton({ Name = "Test Webhook", Callback = function() sendProgress(true) end, })
discordTab:CreateButton({ Name = "Send Progress Now", Callback = function() sendProgress(false) end, })
discordTab:CreateToggle({ Name = "Auto Send", CurrentValue = false, Flag = "AutoWebhook", Callback = function(Value) autoWebhook = Value if Value then task.spawn(function() while autoWebhook do sendProgress(false) task.wait(autoWebhookInterval) end end) end end, })
