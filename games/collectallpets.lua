local HttpService = game:GetService("HttpService")local aClaimQuest = false
local aFarmSmart = false
local aEquipBest = false
local aBuyEgg = false
local aFusePets = false
local aBuySlot = false
local aBuyDamage = false
local aBuySpeed = false
local aBuyMagnet = false
local aUnlockBadges = false
local selectedEgg = 1
local selectedBadges = {"PetScore"}
local equipInterval = 10
local fuseInterval = 15
local webhookUrl = ""
local autoWebhook = false
local autoWebhookInterval = 60
local webhookUsername = "ShinyHub"
local lastEquippedHash = ""
local needEquip = true

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
        Name = "ShinyHub | Collect All Pets",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by flint",
        Theme = "Amoled",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Collect All Pets"}
    })
end)
if not okWin or not window then
    window = Rayfield:CreateWindow({
        Name = "ShinyHub | Collect All Pets",
        LoadingTitle = "ShinyHub",
        LoadingSubtitle = "by you",
        Theme = "Default",
        ToggleUIKeybind = "K",
        DisableRayfieldPrompts = false,
        DisableBuildWarnings = false,
        ConfigurationSaving = {Enabled = true, FolderName = "ShinyHub", FileName = "Collect All Pets"}
    })
end

local function safeTab(name, icon)
    local tab
    pcall(function() tab = window:CreateTab({Name = name, Icon = icon}) end)
    if not tab then pcall(function() tab = window:CreateTab(name) end) end
    return tab
end

local farmTab = safeTab("Farming", 4483362458)
local petsTab = safeTab("Pets", 4483362458)
local discordTab = safeTab("Discord", 4483362458)

local function findPetsFolder()
    local p = game:GetService("Players").LocalPlayer
    for _, name in ipairs({"Pets","PetInventory","Inventory","PetsFolder","Data"}) do
        local f = p:FindFirstChild(name)
        if f then return f end
    end
    for _, v in ipairs(p:GetChildren()) do if v:IsA("Folder") and #v:GetChildren() > 0 then return v end end
    return nil
end

local function getEquippedHash()
    local p = game:GetService("Players").LocalPlayer
    local eq = p:FindFirstChild("EquippedPets") or p:FindFirstChild("Equipped") or (p:FindFirstChild("Data") and p.Data:FindFirstChild("EquippedPets"))
    if eq then
        local t = {}
        for _, pet in ipairs(eq:GetChildren()) do table.insert(t, pet.Name) end
        table.sort(t)
        return table.concat(t, ",")
    end
    return ""
end

local function getCurrentArea()
    local p = game:GetService("Players").LocalPlayer
    for _, name in ipairs({"Area","CurrentArea","Zone","World","Stage","Location"}) do
        local v = p:GetAttribute(name)
        if v then return tonumber(v) end
        local obj = p:FindFirstChild(name)
        if obj and obj.Value then return tonumber(obj.Value) end
        if p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild(name) and p.leaderstats[name].Value then return tonumber(p.leaderstats[name].Value) end
        if p:FindFirstChild("Data") and p.Data:FindFirstChild(name) and p.Data[name].Value then return tonumber(p.Data[name].Value) end
    end
    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local best, bestDist = 1, math.huge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:match("Area") then
                local id = tonumber(obj.Name:match("%d+")) or tonumber(obj:GetAttribute("AreaId"))
                if id then
                    local d = (hrp.Position - obj.Position).Magnitude
                    if d < bestDist and d < 500 then
                        bestDist = d
                        best = id
                    end
                end
            end
        end
        if bestDist ~= math.huge then return best end
    end
    return 1
end

local petsFolder = findPetsFolder()
if petsFolder then pcall(function() petsFolder.ChildAdded:Connect(function() needEquip = true end) end) end

local function sendProgress(isTest)
    if webhookUrl == "" or webhookUrl:len() < 10 then Rayfield:Notify({Title = "Webhook", Content = "Set your webhook URL first!", Duration = 3}) return end
    local player = game:GetService("Players").LocalPlayer
    local fields = {{name = "Player", value = player.Name, inline = true},{name = "PlaceId", value = tostring(game.PlaceId), inline = true},{name = "Area", value = tostring(getCurrentArea()), inline = true}}
    local payload = {username = webhookUsername ~= "" and webhookUsername or "ShinyHub", embeds = {{title = "Collect All Pets - Progress", color = 0x8A2BE2, fields = fields, footer = {text = isTest and "Test webhook" or "Auto webhook"}, timestamp = DateTime.now():ToIsoDate()}}}
    local json = HttpService:JSONEncode(payload)
    local req = (http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request))
    if not req then Rayfield:Notify({Title = "Webhook", Content = "Executor does not support http_request", Duration = 4}) return end
    local ok, res = pcall(function() return req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json}) end)
    if not ok then ok, res = pcall(function() return req({Url = webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = json, body = json}) end) end
    if ok and res and (res.StatusCode == 200 or res.StatusCode == 204 or res.Status == 200) then Rayfield:Notify({Title = "Webhook", Content = "Sent! Area: "..tostring(getCurrentArea()), Duration = 2})
    else Rayfield:Notify({Title = "Webhook", Content = "Failed - check F9", Duration = 4}) warn(res) end
end

farmTab:CreateSection("Farming")
farmTab:CreateToggle({ Name = "Auto Claim Quest", CurrentValue = false, Flag = "AutoClaimQuest", Callback = function(Value) aClaimQuest = Value if Value then task.spawn(function() while aClaimQuest do pcall(function() game:GetService("ReplicatedStorage").Remotes.ClaimQuestReward:FireServer() end) task.wait(3) end end) end end, })
farmTab:CreateDropdown({ Name = "Badges", Options = {"PetScore","GoldEarned","QuestsCompleted","DropsCollected","CrystalsDestroyed","Rebirth","ExoticCrystalScore","Metallic Score","GiantScore","ShinyGiantScore","Ascensions"}, CurrentOption = {"PetScore"}, MultipleOptions = true, Flag = "BadgeSelection", Callback = function(Option) selectedBadges = Option end, })
farmTab:CreateToggle({ Name = "Auto Unlock Badges", CurrentValue = false, Flag = "AutoUnlockBadges", Callback = function(Value) aUnlockBadges = Value if Value then task.spawn(function() while aUnlockBadges do for _, badge in ipairs(selectedBadges) do pcall(function() game:GetService("ReplicatedStorage").Remotes.UnlockBadge:FireServer(badge) end) task.wait(0.3) end task.wait(2) end end) end end, })
farmTab:CreateToggle({ Name = "Auto Farm Current Area", CurrentValue = false, Flag = "AutoFarmSmart", Callback = function(Value) aFarmSmart = Value if Value then task.spawn(function() while aFarmSmart do local area = getCurrentArea() pcall(function() game:GetService("ReplicatedStorage").Remotes.OnAreaButton:FireServer(area) end) task.wait(2) end end) end end, })
farmTab:CreateSection("Codes")
farmTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        local codes = {"TenTickles","Lemonade","Jam","Shortcake","SporesFillTheAirInTheGrove","TheWavesAreCrashingOnTheBeach","TheSandsAreShiftingInTheDesert","TasteTheRainbow","RebelsThinkInPink","Polychromatic","on the floor","Fortune","7up","TheresMyFavoriteLeaf","RaceAgainstTheSinkingSun","PascalsFryingPan","BagesDissonance","ThreeEtherThere","Kesculptorec","Metallicmushroom","ShinySubmarine","DayOfRecord","DayOrRecord","ToInfinity","HiHatsAndRidesOnly","DroppedDropDroppage","SeniorPlanta","DividedBy","ArcticMoon","ConcaveForward","FirstCodeEver","Buttertom_1m","Amebas","FusionIndy","Sub2PHMittens","Chocolatemilk","ChocolateMilk","Meerkat","ThenAddThis","CommonLoon","eaglenight222","Brrrrr","SecretCodeWasHere","4815162342","TreeSauce","KlausWasHere","PentaNeoSecret","PentaNeoSecrets","AddThisStep","ToTheseLogs","TheGreatCodeInTheSky","SpeedPlayzTree","Groupie","Plasmatic_Void","Plasmatic_void","BigHoleInTheWall","InvestigationWeb","Tennessee","LeftToRight","TheHunt","FromTheMachine","Erdentempel","Click","Taikatalvi","MemoryLeak","IfYouAintFirst","HorseWithNoName","Orion","TillFjalls","PillarsOfCreation","TooManyDrops","ShinyHunting","FewAndFarBetween","DuelingDragons","WhoLetTheDogsOut","ImFlying","ItsAChicken","NewCode","shipwrecked","ItsTheGrotto","FastTyper","GlitteringGold","Massproduction","Shinier","FinalForm","FFR","DuneBuggy","Mountin","ProsperousGrounds","BurgersAndFries","InfiniteLoop","SeasonsAndAMovie","AndIThinkToMyself","OneZero","MusketeersAndAmigos","OneOutOfEight","Metallic","GenAutoCalc","CrazyDiamond","Viper_Toffi","Unihorns","LookOut","MrPocket","ToPointOh","NotEnoughDrops","Ocean","Electromagnetism","Stadium","FiveNewCodes","OverEasy","TooMuchBalanceChanges","FourCrystals","StrobeLight","ThingsThatHaveWaves","SticksAndStonesAndLevers"}
        for _, code in ipairs(codes) do pcall(function() game:GetService("ReplicatedStorage").Remotes.RedeemCode:FireServer(code) end) task.wait(0.3) end
        Rayfield:Notify({Title = "Codes", Content = "Tried "..tostring(#codes).." codes", Duration = 3})
    end,
})

petsTab:CreateSection("Pets")
petsTab:CreateToggle({ Name = "Auto Equip Best (Smart)", CurrentValue = false, Flag = "AutoEquipBest", Callback = function(Value) aEquipBest = Value if Value then lastEquippedHash = getEquippedHash() task.spawn(function() while aEquipBest do if needEquip then local before = getEquippedHash() pcall(function() game:GetService("ReplicatedStorage").Remotes.EquipBest:FireServer() end) task.wait(0.5) local after = getEquippedHash() if after ~= "" and after ~= before then print("Equipped new best:", after) lastEquippedHash = after end needEquip = false end task.wait(equipInterval) end end) end end, })
petsTab:CreateSlider({ Name = "Equip Best Interval", Range = {5, 60}, Increment = 5, Suffix = "s", CurrentValue = 15, Flag = "EquipInterval", Callback = function(Value) equipInterval = Value end, })
petsTab:CreateToggle({ Name = "Auto Buy Egg", CurrentValue = false, Flag = "AutoBuyEgg", Callback = function(Value) aBuyEgg = Value if Value then task.spawn(function() while aBuyEgg do pcall(function() game:GetService("ReplicatedStorage").Remotes.BuyEgg:FireServer(selectedEgg) end) needEquip = true task.wait(1) end end) end end, })
petsTab:CreateDropdown({ Name = "Egg Type", Options = {"Common - 7.5k","Uncommon - 35k","Rare - 160k","Epic - 750k","Legendary - 3.5m","Prodigious - 12m","Ascended - 30m","Mythical"}, CurrentOption = {"Common - 7.5k"}, MultipleOptions = false, Flag = "EggType", Callback = function(Option) local map = {["Common"]=1,["Uncommon"]=2,["Rare"]=3,["Epic"]=4,["Legendary"]=5,["Prodigious"]=6,["Ascended"]=7,["Mythical"]=8} local sel = type(Option) == "table" and Option[1] or Option sel = sel:match("^(.-) %-") or sel sel = sel:match("^%s*(.-)%s*$") selectedEgg = map[sel] or 1 end, })
petsTab:CreateToggle({ Name = "Auto Fuse Pets", CurrentValue = false, Flag = "AutoFusePets", Callback = function(Value) aFusePets = Value if Value then task.spawn(function() while aFusePets do local inv = {} local folder = findPetsFolder() if folder then for _, pet in ipairs(folder:GetChildren()) do table.insert(inv, pet) end end if #inv >= 5 then local groups = {} for _, pet in ipairs(inv) do groups[pet.Name] = (groups[pet.Name] or 0) + 1 end local toFuse = {} local found = false for name, count in pairs(groups) do if count >= 5 then for _, pet in ipairs(inv) do if pet.Name == name and #toFuse < 5 then local idx = 1 pcall(function() idx = pet:FindFirstChild("Index") and pet.Index.Value or pet:GetAttribute("Index") or 1 end) table.insert(toFuse, {Pet = pet.Name, Index = idx}) end end found = true break end end if not found then for i = 1, 5 do local pet = inv[i] local idx = 1 pcall(function() idx = pet:FindFirstChild("Index") and pet.Index.Value or pet:GetAttribute("Index") or 1 end) table.insert(toFuse, {Pet = pet.Name, Index = idx}) end end if #toFuse == 5 then pcall(function() game:GetService("ReplicatedStorage").Remotes.FusePets:FireServer(toFuse) end) needEquip = true end end task.wait(fuseInterval) end end) end end, })
petsTab:CreateSlider({ Name = "Fuse Interval", Range = {5, 60}, Increment = 5, Suffix = "s", CurrentValue = 15, Flag = "FuseInterval", Callback = function(Value) fuseInterval = Value end, })
petsTab:CreateToggle({ Name = "Auto Buy Equip Slot", CurrentValue = false, Flag = "AutoBuySlot", Callback = function(Value) aBuySlot = Value if Value then task.spawn(function() while aBuySlot do pcall(function() game:GetService("ReplicatedStorage").Remotes.BuyPetEquipSlot:FireServer(1) end) task.wait(5) end end) end end, })
petsTab:CreateToggle({ Name = "Auto Buy Damage", CurrentValue = false, Flag = "AutoBuyDamage", Callback = function(Value) aBuyDamage = Value if Value then task.spawn(function() while aBuyDamage do pcall(function() game:GetService("ReplicatedStorage").Remotes.BuyStatIncrease:FireServer("Damage") end) task.wait(0.5) end end) end end, })
petsTab:CreateToggle({ Name = "Auto Buy Speed", CurrentValue = false, Flag = "AutoBuySpeed", Callback = function(Value) aBuySpeed = Value if Value then task.spawn(function() while aBuySpeed do pcall(function() game:GetService("ReplicatedStorage").Remotes.BuyStatIncrease:FireServer("Speed") end) task.wait(0.5) end end) end end, })
petsTab:CreateToggle({ Name = "Auto Buy Magnet", CurrentValue = false, Flag = "AutoBuyMagnet", Callback = function(Value) aBuyMagnet = Value if Value then task.spawn(function() while aBuyMagnet do pcall(function() game:GetService("ReplicatedStorage").Remotes.BuyStatIncrease:FireServer("Magnet") end) task.wait(0.5) end end) end end, })

discordTab:CreateSection("Discord Webhook")
discordTab:CreateInput({ Name = "Webhook URL", PlaceholderText = "https://discord.com/api/webhooks/...", RemoveTextAfterFocusLost = false, Callback = function(Text) webhookUrl = Text end, })
discordTab:CreateInput({ Name = "Webhook Username", PlaceholderText = "ShinyHub", RemoveTextAfterFocusLost = false, Callback = function(Text) webhookUsername = Text end, })
discordTab:CreateToggle({ Name = "Auto Send", CurrentValue = false, Flag = "AutoWebhook", Callback = function(Value) autoWebhook = Value if Value then task.spawn(function() while autoWebhook do sendProgress(false) task.wait(autoWebhookInterval) end end) end end, })
discordTab:CreateSlider({ Name = "Auto Send Interval", Range = {10, 600}, Increment = 5, Suffix = "s", CurrentValue = 60, Flag = "WebhookInterval", Callback = function(Value) autoWebhookInterval = Value end, })
discordTab:CreateButton({ Name = "Test Webhook", Callback = function() sendProgress(true) end, })
discordTab:CreateButton({ Name = "Send Progress Now", Callback = function() sendProgress(false) end, })
