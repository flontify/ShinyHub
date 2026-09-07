-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Blox Fruits
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

local RS = game:GetService("ReplicatedStorage")
local Event = RS:WaitForChild("Remotes"):WaitForChild("CommE")

pcall(function()
    if firesignal and Event.OnClientEvent then
        firesignal(Event.OnClientEvent, "Notify", "<Color=Purple>Symbiote<Color=/>")
    end
end)

local Library = createSymbioteShim("Blox Fruits")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local NPCNames = {
    "Bandit","Trainee","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer","Sky Bandit","Dark Master","Prisoner","Dangerous Prisoner","Toga Warrior","Gladiator","Military Soldier","Military Spy","Fishman Warrior","Fishman Commando","God's Guard","Shanda","Royal Squad","Royal Soldier","Galley Pirate","Galley Captain",
    "Raider","Mercenary","Swan Pirate","Factory Staff","Marine Lieutenant","Marine Captain","Zombie","Vampire","Snow Trooper","Winter Warrior","Lab Subordinate","Horned Warrior","Magma Ninja","Lava Pirate","Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior","Snow Lurker","Sea Soldier","Water Fighter",
    "Pirate Millionaire","Pistol Billionaire","Dragon Crew Warrior","Dragon Crew Archer","Hydra Enforcer","Venomous Assailant","Marine","Marine Commodore","Marine Rear Admiral","Fishman Raider","Fishman Captain","Forest Pirate","Mythological Pirate","Jungle Pirate","Musketeer Pirate","Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Peanut Scout","Peanut President","Ice Cream Chef","Ice Cream Commander","Cookie Crafter","Cake Guard","Baking Staff","Head Baker","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel","Candy Pirate","Snow Demon","Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion","Serpent Hunter","Skull Slayer","Reef Bandit","Coral Pirate","Sea Chanter","Ocean Prophet","High Disciple","Grand Devotee",
    "Bladesmith","Bone Breaker","Shocker","Sorcerer","Fruit User","Core","Ghost","Training Dummy","Elite Pirate","Ancient Zombie","Ancient Vampire","Fish Crew Member","Ghost Shark","Haunted Crew Member","Bone Wraith","Evil Wraith"
}

local BossNames = {
    "The Gorilla King","Chef","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral",
    "Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","rip_indra",
    "Stone","Hydra Leader","Kilo Amiral","Captain Elephant","Beautiful Pirate","Longma","Cursed Skeleton Boss","Cake Queen","Heaven's Guardian","Hell's Messenger",
    "Cursed Captain","Order"
}

local NPCLevelData = {
    {name="Bandit", level=5, quest="Bandit Quest"},
    {name="Monkey", level=14, quest="Monkey Quest"},
    {name="Gorilla", level=20, quest="Gorilla Quest"},
    {name="Pirate", level=35, quest="Pirate Quest"},
    {name="Brute", level=45, quest="Brute Quest"},
    {name="Desert Bandit", level=60, quest="Desert Bandit Quest"},
    {name="Desert Officer", level=70, quest="Desert Officer Quest"},
    {name="Snow Bandit", level=90, quest="Snow Bandit Quest"},
    {name="Snowman", level=100, quest="Snowman Quest"},
    {name="Chief Petty Officer", level=120, quest="Chief Petty Officer Quest"},
    {name="Sky Bandit", level=150, quest="Sky Bandit Quest"},
    {name="Dark Master", level=175, quest="Dark Master Quest"},
    {name="Prisoner", level=190, quest="Prisoner Quest"},
    {name="Dangerous Prisoner", level=210, quest="Dangerous Prisoner Quest"},
    {name="Toga Warrior", level=250, quest="Toga Warrior Quest"},
    {name="Gladiator", level=275, quest="Gladiator Quest"},
    {name="Military Soldier", level=300, quest="Military Soldier Quest"},
    {name="Military Spy", level=325, quest="Military Spy Quest"},
    {name="Fishman Warrior", level=375, quest="Fishman Warrior Quest"},
    {name="Fishman Commando", level=400, quest="Fishman Commando Quest"},
    {name="God's Guard", level=450, quest="God's Guard Quest"},
    {name="Shanda", level=475, quest="Shanda Quest"},

    {name="Royal Squad", level=525, quest="Royal Squad Quest"},
    {name="Royal Soldier", level=550, quest="Royal Soldier Quest"},
    {name="Galley Pirate", level=625, quest="Galley Pirate Quest"},
    {name="Galley Captain", level=650, quest="Galley Captain Quest"},
    {name="Raider", level=700, quest="Raider Quest"},
    {name="Mercenary", level=725, quest="Mercenary Quest"},
    {name="Swan Pirate", level=775, quest="Swan Pirate Quest"},
    {name="Factory Staff", level=800, quest="Factory Staff Quest"},

    {name="Marine Lieutenant", level=875, quest="Marine Lieutenant Quest"},
    {name="Marine Captain", level=900, quest="Marine Captain Quest"},
    {name="Zombie", level=950, quest="Zombie Quest"},
    {name="Vampire", level=975, quest="Vampire Quest"},
    {name="Snow Trooper", level=1000, quest="Snow Trooper Quest"},
    {name="Winter Warrior", level=1050, quest="Winter Warrior Quest"},
    {name="Lab Subordinate", level=1100, quest="Lab Subordinate Quest"},

    {name="Horned Warrior", level=1125, quest="Horned Warrior Quest"},
    {name="Magma Ninja", level=1175, quest="Magma Ninja Quest"},
    {name="Lava Pirate", level=1200, quest="Lava Pirate Quest"},
    {name="Ship Deckhand", level=1250, quest="Ship Deckhand Quest"},
    {name="Ship Engineer", level=1275, quest="Ship Engineer Quest"},
    {name="Ship Steward", level=1300, quest="Ship Steward Quest"},
    {name="Ship Officer", level=1325, quest="Ship Officer Quest"},
    {name="Arctic Warrior", level=1350, quest="Arctic Warrior Quest"},
    {name="Snow Lurker", level=1400, quest="Snow Lurker Quest"},
    {name="Sea Soldier", level=1425, quest="Sea Soldier Quest"},
    {name="Water Fighter", level=1450, quest="Water Fighter Quest"},
    {name="Pirate Millionaire", level=1500, quest="Pirate Millionaire Quest"},
    {name="Pistol Billionaire", level=1525, quest="Pistol Billionaire Quest"},
    {name="Dragon Crew Warrior", level=1575, quest="Dragon Crew Warrior Quest"},

    {name="Dragon Crew Archer", level=1600, quest="Dragon Crew Archer Quest"},
    {name="Hydra Enforcer", level=1625, quest="Hydra Enforcer Quest"},
    {name="Venomous Assailant", level=1650, quest="Venomous Assailant Quest"},
    {name="Marine Commodore", level=1700, quest="Marine Commodore Quest"},
    {name="Marine Rear Admiral", level=1725, quest="Marine Rear Admiral Quest"},
    {name="Fishman Raider", level=1775, quest="Fishman Raider Quest"},
    {name="Fishman Captain", level=1800, quest="Fishman Captain Quest"},
    {name="Forest Pirate", level=1825, quest="Forest Pirate Quest"},
    {name="Mythological Pirate", level=1850, quest="Mythological Pirate Quest"},
    {name="Jungle Pirate", level=1900, quest="Jungle Pirate Quest"},
    {name="Musketeer Pirate", level=1925, quest="Musketeer Pirate Quest"},
    {name="Reborn Skeleton", level=1975, quest="Reborn Skeleton Quest"},
    {name="Living Zombie", level=2000, quest="Living Zombie Quest"},
    {name="Demonic Soul", level=2025, quest="Demonic Soul Quest"},
    {name="Posessed Mummy", level=2050, quest="Posessed Mummy Quest"},
    {name="Peanut Scout", level=2075, quest="Peanut Scout Quest"},
    {name="Peanut President", level=2100, quest="Peanut President Quest"},
    {name="Ice Cream Chef", level=2125, quest="Ice Cream Chef Quest"},
    {name="Ice Cream Commander", level=2150, quest="Ice Cream Commander Quest"},
    {name="Cookie Crafter", level=2200, quest="Cookie Crafter Quest"},
    {name="Cake Guard", level=2225, quest="Cake Guard Quest"},
    {name="Baking Staff", level=2250, quest="Baking Staff Quest"},
    {name="Head Baker", level=2275, quest="Head Baker Quest"},
    {name="Cocoa Warrior", level=2300, quest="Cocoa Warrior Quest"},
    {name="Chocolate Bar Battler", level=2325, quest="Chocolate Bar Battler Quest"},
    {name="Sweet Thief", level=2350, quest="Sweet Thief Quest"},
    {name="Candy Rebel", level=2375, quest="Candy Rebel Quest"},
    {name="Candy Pirate", level=2400, quest="Candy Pirate Quest"},
    {name="Snow Demon", level=2425, quest="Snow Demon Quest"},
    {name="Isle Outlaw", level=2450, quest="Isle Outlaw Quest"},
    {name="Island Boy", level=2475, quest="Island Boy Quest"},
    {name="Sun-kissed Warrior", level=2500, quest="Sun-kissed Warrior Quest"},
    {name="Isle Champion", level=2525, quest="Isle Champion Quest"},
    {name="Serpent Hunter", level=2550, quest="Serpent Hunter Quest"},
    {name="Skull Slayer", level=2575, quest="Skull Slayer Quest"},
    {name="Reef Bandit", level=2600, quest="Reef Bandit Quest"},
    {name="Coral Pirate", level=2625, quest="Coral Pirate Quest"},
    {name="Sea Chanter", level=2650, quest="Sea Chanter Quest"},
    {name="Ocean Prophet", level=2675, quest="Ocean Prophet Quest"},
    {name="High Disciple", level=2700, quest="High Disciple Quest"},
    {name="Grand Devotee", level=2725, quest="Grand Devotee Quest"}
}

local SeaEventWaypointsSea2 = {
    Vector3.new(2838.17993, -2.64276028, 10548.6787),
    Vector3.new(8451.55566, -2.64276028, 13342.4932),
    Vector3.new(13789.2314, -2.64276028, 9816.94922),
    Vector3.new(16731.7168, -2.64276028, 2541.39697),
    Vector3.new(19301.5273, -2.64276028, -287.770935),
    Vector3.new(21993.6816, -2.64276028, -5099.17529),
    Vector3.new(23832.6055, -2.64276028, -13994.792),
    Vector3.new(25379.4141, -2.64276028, -19712.1172),
    Vector3.new(24133.4238, -2.64276028, -25188.0859),
    Vector3.new(21095.873, -2.64276028, -31179.0508),
    Vector3.new(23460.302734375, -2.64276028, -39102.8125),
    Vector3.new(28258.609375, -2.64276028, -44793.140625),
    Vector3.new(38692.11328125, -2.64276028, -48541.35546875),
    Vector3.new(45997.81640625, -2.64276028, -51290.34375)
}

local ZoneCFrames = {
    ["Zone 1 Low"] = Vector3.new(20088.91015625, -2.64276028, 9279.701171875),
    ["Zone 2 Medium"] = Vector3.new(22713.39453125, -2.64276028, 12306.0537109375),
    ["Zone 3 High"] = Vector3.new(24884.361328125, -2.64276028, 15012.06640625),
    ["Zone 4 Extreme"] = Vector3.new(28141.53125, -2.64276028, 17779.369140625),
    ["Zone 5 Crazy"] = Vector3.new(31603.8125, -2.64276028, 21682.18359375),
    ["Zone 6 ???"] = {
        Vector3.new(37449.55859375, -2.64276028, 27640.1796875),
        Vector3.new(41940.890625, -2.64276028, 30145.091796875),
        Vector3.new(44610.68359375, -2.64276028, 31819.31640625),
        Vector3.new(48178.01171875, -2.64276028, 33687.69921875),
        Vector3.new(58877.56640625, -2.64276028, 38910.4375),
        Vector3.new(62852.65625, -2.64276028, 41841.86328125),
        Vector3.new(68178.01171875, -2.64276028, 55687.69921875),
        Vector3.new(88178.01171875, -2.64276028, 747.69921875),
        Vector3.new(100178.01171875, -2.64276028, 95687.69921875),
        Vector3.new(120178.01171875, -2.64276028, 110687.69921875),
        Vector3.new(140178.01171875, -2.64276028, 125687.69921875),
        Vector3.new(160178.01171875, -2.64276028, 140687.69921875),
        Vector3.new(180178.01171875, -2.64276028, 155687.69921875)
    }
}

local State = {
    TWEEN_SPEED = 200,
    TWEEN_THRESHOLD = 80,
    AutoFarmEnabled = false,
    AutoFarmBossEnabled = false,
    AutoFarmLevelEnabled = false,
    AutoFarmNearbyNPCsEnabled = false,
    AutoFarmNearbyBossesEnabled = false,
    FlyEnabled = false,
    NoClipEnabled = false,
    SelectedNPCs = {},
    SelectedBosses = {},
    AutoEquipWeaponFarm = nil,
    AutoEquipWeaponPVP = nil,
    DistanceBetweenNPC = 5,
    FlySpeed = 50,
    NoClipConnection = nil,
    FlyConnection = nil,
    FlyPart = nil,
    FlyWeld = nil,
    FlyBodyVelocity = nil,

    FlyBodyGyro = nil,
    ServiceNPCESPEnabled = false,
    FruitESPEnabled = false,
    FruitESPObjects = {},
    AutoHakiEnabled = false,
    WaterWalkingEnabled = false,
    AntiAFKEnabled = false,
    AutoGoLabToStartEnabled = false,
    AntiAFKConnection = nil,
    AutoInstinctEnabled = false,
    InfiniteStaminaEnabled = false,
    InfiniteStaminaConnection = nil,

    InfiniteStaminaChangedConn = nil,
    AutoRollFruitEnabled = false,
    AutoBuddhaTransformEnabled = false,
    TransformingBuddha = false,
    FruitAutoSkillZ = false,

    FruitAutoSkillX = false,
    FruitAutoSkillC = false,
    FruitAutoSkillV = false,
    FruitAutoSkillF = false,
    PlayerESPEnabled = false,
    PlayerESPObjects = {},
    ESPLinesEnabled = false,
    ESPLineObjects = {},
    ESPLinesGui = nil,
    ESPObjects = {},
    SpectateEnabled = false,
    SpectateTarget = nil,
    SpectateDropdownRef = nil,
    lastSpectatePlayerSet = {},
    LockCameraEnabled = false,
    InfiniteJumpEnabled = false,
    InfiniteJumpConnection = nil,
    SelectedAutoQuest = nil,
    WalkSpeedEnabled = false,
    WalkSpeedSmoothing = 1,
    WalkSpeedConnection = nil,

    LaggyRunEnabled = false,
    LaggyRunDistance = 1,
    LaggyRunDelay = 1,
    LaggyRunConnection = nil,
    LaggyRunAccum = 0,
    CtrlClickTPEnabled = false,
    CtrlClickTPConnection = nil,
    ServiceNPCTPDropdownRef = nil,
    lastServiceNPCNames = {},
    KillAuraEnabled = false,
    PlayerKillAuraEnabled = false,
    BringNPCsEnabled = false,
    TweenToPlaceDropdownRef = nil,
    lastLocationNames = {},
    activePlaceTweenActive = false,
    currentTweenModelName = nil,
    placeTweenConnection = nil,
    anchoredTargets = {},
    WatchdogData = {},
    AutoStatsEnabled = false,
    SelectedStats = {},
    StatPointValue = 1,
    autoStatsConnection = nil,
    autoStatsIndex = 1,
    AutoCollectChestEnabled = false,
    OrbitEnabled = false,
    OrbitTarget = nil,
    OrbitAngle = 0,
    OrbitSpeed = 1,
    OrbitDistance = 10,
    TPBehindOrbitEnabled = false,
    OrbitConnection = nil,

    OrbitDropdownRef = nil,
    lastOrbitPlayerSet = {},
    LastRespawnTick = 0,
    RaidAutoEquipWeapon = nil,

    RaidDistanceBetweenNPC = 5,
    RaidBringNPCsEnabled = false,
    AutoRaidEnabled = false,
    AutoStartRaidEnabled = false,
    SelectedRaidType = nil,
    SeaEventAutoEquipWeapon = nil,
    SeaEventDistanceBetweenNPC = 5,
    SeaEventBringNPCsEnabled = false,
    AutoBuyBoatEnabled = false,
    SelectedBoatToBuy = "Guardian",
    SelectedSeaEventZone = "Zone 6 ???",
    AutoFindSeaEventEnabled = false,
    SeaEventWaypointIndex = 1,
    SeaEventWaypointDirection = 1,
    AutoKillSharkEnabled = false,
    AutoKillTerrorsharkEnabled = false,
    AutoKillPiranhaEnabled = false,
    AutoKillBrigadesEnabled = false,
    AutoKillSeaBeastEnabled = false,
    AutoKillFishBoatEnabled = false,
    AutoKillFishCrewMemberEnabled = false,
    LastBoatBuyTick = 0,
    FruitAutoSkillEnabled = false,
    SelectedFruitSkills = {},
    ResetIfBoatSinks = false,
    NoclipBoatEnabled = false,
    NoclipBoatConnection = nil,
    AutoKillEnabled = false,
    SelectedAutoKillTargets = {},
    LockCameraSelectedPlayerEnabled = false,
    LockCameraSelectedPlayerTarget = nil,
    LockCameraSelectedDropdownRef = nil,
    lastLockCameraPlayerSet = {},
    AimlockClosestPlayerEnabled = false,
    AimbotSelectedPlayerEnabled = false,

    AimlockSelectedPlayerTarget = nil,
    AimlockSelectedDropdownRef = nil,
    lastAimlockPlayerSet = {},
    AutoFarmMagnetNPCsEnabled = false,
    IsBuyingBoat = false,
    AutoFindMirageIslandEnabled = false,
    MirageWaypointIndex = 1,
    MirageWaypointDirection = 1,
    HasResetForBoatSink = false,
    AutoFindPrehistoricIslandEnabled = false,
    IsTweening = false,
    AutoGetEliteHunterQuestEnabled = false,
    AutoKillEliteHunterEnabled = false,
    AutoStoreFruitEnabled = false
}

local AutoQuestDefinitions = {
    ["Bandit Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","BanditQuest1",1) end) end,
    ["Trainee Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineQuest",1) end) end,
    ["Monkey Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","JungleQuest",1) end) end,
    ["Gorilla Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","JungleQuest",2) end) end,
    ["Gorilla King Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","JungleQuest",3) end) end,
    ["Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","BuggyQuest1",1) end) end,
    ["Brute Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","BuggyQuest1",2) end) end,
    ["Chef Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","BuggyQuest1",3) end) end,
    ["Desert Bandit Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DesertQuest",1) end) end,
    ["Desert Officer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DesertQuest",2) end) end,
    ["Snow Bandit Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SnowQuest",1) end) end,
    ["Snowman Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SnowQuest",2) end) end,
    ["Yeti Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SnowQuest",3) end) end,
    ["Chief Petty Officer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineQuest2",1) end) end,
    ["Vice Admiral Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineQuest2",2) end) end,
    ["Sky Bandit Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyQuest",1) end) end,
    ["Dark Master Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyQuest",2) end) end,
    ["Prisoner Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","PrisonerQuest",1) end) end,
    ["Dangerous Prisoner Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","PrisonerQuest",2) end) end,
    ["Warden Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ImpelQuest",1) end) end,
    ["Chief Warden Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ImpelQuest",2) end) end,
    ["Swan Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ImpelQuest",3) end) end,
    ["Toga Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ColosseumQuest",1) end) end,
    ["Gladiator Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ColosseumQuest",2) end) end,
    ["Military Soldier Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MagmaQuest",1) end) end,
    ["Military Spy Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MagmaQuest",2) end) end,
    ["Magma Admiral Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MagmaQuest",3) end) end,
    ["Fishman Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FishmanQuest",1) end) end,
    ["Fishman Commando Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FishmanQuest",2) end) end,
    ["Fishman Lord Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FishmanQuest",3) end) end,
    ["God's Guard Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyExp1Quest",1) end) end,
    ["Shanda Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyExp1Quest",2) end) end,
    ["Wysper Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyExp1Quest",3) end) end,
    ["Royal Squad Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyExp2Quest",1) end) end,
    ["Royal Soldier Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyExp2Quest",2) end) end,
    ["Thunder God Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SkyExp2Quest",3) end) end,
    ["Galley Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FountainQuest",1) end) end,
    ["Galley Captain Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FountainQuest",2) end) end,
    ["Cyborg Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FountainQuest",3) end) end,
    ["Raider Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","Area1Quest",1) end) end,
    ["Mercenary Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","Area1Quest",2) end) end,
    ["Diamond Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","Area1Quest",3) end) end,
    ["Swan Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","Area2Quest",1) end) end,
    ["Factory Staff Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","Area2Quest",2) end) end,
    ["Jeremy Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","Area2Quest",3) end) end,
    ["Marine Lieutenant Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineQuest3",1) end) end,
    ["Marine Captain Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineQuest3",2) end) end,
    ["Orbitus Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineQuest3",3) end) end,
    ["Zombie Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ZombieQuest",1) end) end,
    ["Vampire Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ZombieQuest",2) end) end,
    ["Snow Trooper Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SnowMountainQuest",1) end) end,
    ["Winter Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SnowMountainQuest",2) end) end,
    ["Lab Subordinate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","IceSideQuest",1) end) end,
    ["Horned Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","IceSideQuest",2) end) end,
    ["Smoke Admiral Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","IceSideQuest",3) end) end,
    ["Magma Ninja Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FireSideQuest",1) end) end,
    ["Lava Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FireSideQuest",2) end) end,
    ["Ship Deckhand Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ShipQuest1",1) end) end,
    ["Ship Engineer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ShipQuest1",2) end) end,
    ["Ship Steward Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ShipQuest2",1) end) end,
    ["Ship Officer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ShipQuest2",2) end) end,
    ["Arctic Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FrostQuest",1) end) end,
    ["Snow Lurker Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FrostQuest",2) end) end,
    ["Ice Admiral Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","FrostQuest",3) end) end,
    ["Sea Soldier Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ForgottenQuest",1) end) end,
    ["Water Fighter Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ForgottenQuest",2) end) end,
    ["Tide Keeper Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ForgottenQuest",3) end) end,
    ["Pirate Millionaire Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","PiratePortQuest",1) end) end,
    ["Pistol Billionaire Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","PiratePortQuest",2) end) end,
    ["Stone Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","PiratePortQuest",3) end) end,
    ["Dragon Crew Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DragonCrewQuest",1) end) end,
    ["Dragon Crew Archer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DragonCrewQuest",2) end) end,
    ["Hydra Enforcer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","VenomCrewQuest",1) end) end,
    ["Venomous Assailant Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","VenomCrewQuest",2) end) end,
    ["Hydra Leader Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","VenomCrewQuest",3) end) end,
    ["Marine Commodore Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineTreeIsland",1) end) end,
    ["Marine Rear Admiral Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineTreeIsland",2) end) end,

    ["Kilo Admiral Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","MarineTreeIsland",3) end) end,
    ["Fishman Raider Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland3",1) end) end,

    ["Fishman Captain Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland3",2) end) end,
    ["Forest Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland",1) end) end,
    ["Mythological Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland",2) end) end,
    ["Captain Elephant Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland",3) end) end,

    ["Jungle Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland2",1) end) end,
    ["Musketeer Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland2",2) end) end,
    ["Beautiful Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","DeepForestIsland2",3) end) end,
    ["Reborn Skeleton Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","HauntedQuest1",1) end) end,
    ["Living Zombie Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","HauntedQuest1",2) end) end,
    ["Demonic Soul Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","HauntedQuest2",1) end) end,
    ["Posessed Mummy Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","HauntedQuest2",2) end) end,
    ["Peanut Scout Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","NutsIslandQuest",1) end) end,
    ["Peanut President Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","NutsIslandQuest",2) end) end,
    ["Ice Cream Chef Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","IceCreamIslandQuest",1) end) end,
    ["Ice Cream Commander Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","IceCreamIslandQuest",2) end) end,
    ["Cake Queen Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","IceCreamIslandQuest",3) end) end,
    ["Cookie Crafter Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","CakeQuest1",1) end) end,
    ["Cake Guard Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","CakeQuest1",2) end) end,
    ["Baking Staff Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","CakeQuest2",1) end) end,
    ["Head Baker Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","CakeQuest2",2) end) end,
    ["Cocoa Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ChocQuest1",1) end) end,
    ["Chocolate Bar Battler Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ChocQuest1",2) end) end,
    ["Sweet Thief Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ChocQuest2",1) end) end,
    ["Candy Rebel Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","ChocQuest2",2) end) end,
    ["Candy Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","CandyQuest1",1) end) end,
    ["Snow Demon Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","CandyQuest1",2) end) end,
    ["Isle Outlaw Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest1",1) end) end,
    ["Island Boy Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest1",2) end) end,
    ["Sun-kissed Warrior Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest2",1) end) end,
    ["Isle Champion Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest2",2) end) end,
    ["Serpent Hunter Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest3",1) end) end,
    ["Skull Slayer Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","TikiQuest3",2) end) end,
    ["Reef Bandit Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SubmergedQuest1",1) end) end,
    ["Coral Pirate Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SubmergedQuest1",2) end) end,
    ["Sea Chanter Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SubmergedQuest2",1) end) end,
    ["Ocean Prophet Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SubmergedQuest2",2) end) end,
    ["High Disciple Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SubmergedQuest3",1) end) end,
    ["Grand Devotee Quest"]=function() pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest","SubmergedQuest3",2) end) end,
}

local AutoQuestOrder = {
    "Bandit Quest","Trainee Quest","Monkey Quest","Gorilla Quest","Gorilla King Quest","Pirate Quest","Brute Quest","Chef Quest","Desert Bandit Quest","Desert Officer Quest","Snow Bandit Quest","Snowman Quest","Yeti Quest","Chief Petty Officer Quest","Vice Admiral Quest","Sky Bandit Quest","Dark Master Quest","Prisoner Quest","Dangerous Prisoner Quest","Warden Quest","Chief Warden Quest","Swan Quest","Toga Warrior Quest","Gladiator Quest","Military Soldier Quest","Military Spy Quest","Magma Admiral Quest","Fishman Warrior Quest","Fishman Commando Quest","Fishman Lord Quest","God's Guard Quest","Shanda Quest","Wysper Quest","Royal Squad Quest","Royal Soldier Quest","Thunder God Quest","Galley Pirate Quest","Galley Captain Quest","Cyborg Quest",
    "Raider Quest","Mercenary Quest","Diamond Quest","Swan Pirate Quest","Factory Staff Quest","Jeremy Quest","Marine Lieutenant Quest","Marine Captain Quest","Orbitus Quest","Zombie Quest","Vampire Quest","Snow Trooper Quest","Winter Warrior Quest","Lab Subordinate Quest","Horned Warrior Quest","Smoke Admiral Quest","Magma Ninja Quest","Lava Pirate Quest","Ship Deckhand Quest","Ship Engineer Quest","Ship Steward Quest","Ship Officer Quest","Arctic Warrior Quest","Snow Lurker Quest","Ice Admiral Quest","Sea Soldier Quest","Water Fighter Quest","Tide Keeper Quest",
    "Pirate Millionaire Quest","Pistol Billionaire Quest","Stone Quest","Dragon Crew Warrior Quest","Dragon Crew Archer Quest","Hydra Enforcer Quest","Venomous Assailant Quest","Hydra Leader Quest","Marine Commodore Quest","Marine Rear Admiral Quest","Kilo Admiral Quest","Fishman Raider Quest","Fishman Captain Quest","Forest Pirate Quest","Mythological Pirate Quest","Captain Elephant Quest","Jungle Pirate Quest","Musketeer Pirate Quest","Beautiful Pirate Quest","Reborn Skeleton Quest","Living Zombie Quest","Demonic Soul Quest","Posessed Mummy Quest","Peanut Scout Quest","Peanut President Quest","Ice Cream Chef Quest","Ice Cream Commander Quest","Cake Queen Quest","Cookie Crafter Quest","Cake Guard Quest","Baking Staff Quest","Head Baker Quest","Cocoa Warrior Quest","Chocolate Bar Battler Quest","Sweet Thief Quest","Candy Rebel Quest","Candy Pirate Quest","Snow Demon Quest","Isle Outlaw Quest","Island Boy Quest","Sun-kissed Warrior Quest","Isle Champion Quest","Serpent Hunter Quest","Skull Slayer Quest","Reef Bandit Quest","Coral Pirate Quest","Sea Chanter Quest","Ocean Prophet Quest","High Disciple Quest","Grand Devotee Quest"
}

local NPCToQuestMap = {
    ["Bandit"]="Bandit Quest",["Trainee"]="Trainee Quest",["Monkey"]="Monkey Quest",["Gorilla"]="Gorilla Quest",["The Gorilla King"]="Gorilla King Quest",["Pirate"]="Pirate Quest",["Brute"]="Brute Quest",["Chef"]="Chef Quest",["Desert Bandit"]="Desert Bandit Quest",["Desert Officer"]="Desert Officer Quest",["Snow Bandit"]="Snow Bandit Quest",["Snowman"]="Snowman Quest",["Yeti"]="Yeti Quest",["Chief Petty Officer"]="Chief Petty Officer Quest",["Vice Admiral"]="Vice Admiral Quest",["Sky Bandit"]="Sky Bandit Quest",["Dark Master"]="Dark Master Quest",["Prisoner"]="Prisoner Quest",["Dangerous Prisoner"]="Dangerous Prisoner Quest",["Warden"]="Warden Quest",["Chief Warden"]="Chief Warden Quest",["Swan"]="Swan Quest",["Toga Warrior"]="Toga Warrior Quest",["Gladiator"]="Gladiator Quest",["Military Soldier"]="Military Soldier Quest",["Military Spy"]="Military Spy Quest",["Magma Admiral"]="Magma Admiral Quest",["Fishman Warrior"]="Fishman Warrior Quest",["Fishman Commando"]="Fishman Commando Quest",["Fishman Lord"]="Fishman Lord Quest",["God's Guard"]="God's Guard Quest",["Shanda"]="Shanda Quest",["Wysper"]="Wysper Quest",["Royal Squad"]="Royal Squad Quest",["Royal Soldier"]="Royal Soldier Quest",["Thunder God"]="Thunder God Quest",["Galley Pirate"]="Galley Pirate Quest",["Galley Captain"]="Galley Captain Quest",["Cyborg"]="Cyborg Quest",
    ["Raider"]="Raider Quest",["Mercenary"]="Mercenary Quest",["Diamond"]="Diamond Quest",["Swan Pirate"]="Swan Pirate Quest",["Factory Staff"]="Factory Staff Quest",["Jeremy"]="Jeremy Quest",["Marine Lieutenant"]="Marine Lieutenant Quest",["Marine Captain"]="Marine Captain Quest",["Orbitus"]="Orbitus Quest",["Zombie"]="Zombie Quest",["Vampire"]="Vampire Quest",["Snow Trooper"]="Snow Trooper Quest",["Winter Warrior"]="Winter Warrior Quest",["Lab Subordinate"]="Lab Subordinate Quest",["Horned Warrior"]="Horned Warrior Quest",["Smoke Admiral"]="Smoke Admiral Quest",["Magma Ninja"]="Magma Ninja Quest",["Lava Pirate"]="Lava Pirate Quest",["Ship Deckhand"]="Ship Deckhand Quest",["Ship Engineer"]="Ship Engineer Quest",["Ship Steward"]="Ship Steward Quest",["Ship Officer"]="Ship Officer Quest",["Arctic Warrior"]="Arctic Warrior Quest",["Snow Lurker"]="Snow Lurker Quest",["Ice Admiral"]="Ice Admiral Quest",["Sea Soldier"]="Sea Soldier Quest",["Water Fighter"]="Water Fighter Quest",["Tide Keeper"]="Tide Keeper Quest",
    ["Pirate Millionaire"]="Pirate Millionaire Quest",["Pistol Billionaire"]="Pistol Billionaire Quest",["Stone"]="Stone Quest",["Dragon Crew Warrior"]="Dragon Crew Warrior Quest",["Dragon Crew Archer"]="Dragon Crew Archer Quest",["Hydra Enforcer"]="Hydra Enforcer Quest",["Venomous Assailant"]="Venomous Assailant Quest",["Hydra Leader"]="Hydra Leader Quest",["Marine Commodore"]="Marine Commodore Quest",["Marine Rear Admiral"]="Marine Rear Admiral Quest",["Kilo Amiral"]="Kilo Admiral Quest",["Fishman Raider"]="Fishman Raider Quest",["Fishman Captain"]="Fishman Captain Quest",["Forest Pirate"]="Forest Pirate Quest",["Mythological Pirate"]="Mythological Pirate Quest",["Captain Elephant"]="Captain Elephant Quest",["Jungle Pirate"]="Jungle Pirate Quest",["Musketeer Pirate"]="Musketeer Pirate Quest",["Beautiful Pirate"]="Beautiful Pirate Quest",["Reborn Skeleton"]="Reborn Skeleton Quest",["Living Zombie"]="Living Zombie Quest",["Demonic Soul"]="Demonic Soul Quest",["Posessed Mummy"]="Posessed Mummy Quest",["Peanut Scout"]="Peanut Scout Quest",["Peanut President"]="Peanut President Quest",["Ice Cream Chef"]="Ice Cream Chef Quest",["Ice Cream Commander"]="Ice Cream Commander Quest",["Cake Queen"]="Cake Queen Quest",["Cookie Crafter"]="Cookie Crafter Quest",["Cake Guard"]="Cake Guard Quest",["Baking Staff"]="Baking Staff Quest",["Head Baker"]="Head Baker Quest",["Cocoa Warrior"]="Cocoa Warrior Quest",["Chocolate Bar Battler"]="Chocolate Bar Battler Quest",["Sweet Thief"]="Sweet Thief Quest",["Candy Rebel"]="Candy Rebel Quest",["Candy Pirate"]="Candy Pirate Quest",["Snow Demon"]="Snow Demon Quest",["Isle Outlaw"]="Isle Outlaw Quest",["Island Boy"]="Island Boy Quest",["Sun-kissed Warrior"]="Sun-kissed Warrior Quest",["Isle Champion"]="Isle Champion Quest",["Serpent Hunter"]="Serpent Hunter Quest",["Skull Slayer"]="Skull Slayer Quest",["Reef Bandit"]="Reef Bandit Quest",["Coral Pirate"]="Coral Pirate Quest",["Sea Chanter"]="Sea Chanter Quest",["Ocean Prophet"]="Ocean Prophet Quest",["High Disciple"]="High Disciple Quest",["Grand Devotee"]="Grand Devotee Quest"
}

LocalPlayer.CharacterAdded:Connect(function()
    State.LastRespawnTick = tick()
end)

local function GetBaseNameFromSpawnPartName(p) local b=string.match(p,"^(.-)%s*%[") if b then return b:match("^%s*(.-)%s*$") end return p:match("^%s*(.-)%s*$") end
local function GetPlayerLevel() local ok,v=pcall(function() return LocalPlayer.Data.Level.Value end) if ok and v then return v end return 0 end
local function GetEnemyLevelFromModel(m) local ok,v=pcall(function() return m:GetAttribute("Level") end) if ok and v and type(v)=="number" then return v end return nil end
local function GetLevelFromDisplayName(d) if not d then return nil end local l=string.match(d,"%[Lv%.%s*(%d+)%]") if l then return tonumber(l) end return nil end
local function IsLevelValidForPlayer(n,p) if not n then return false end return n<=p and n>=(p-100) end

local function IsQuestActive()
    local ok, r = pcall(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui") if not pg then return false end
        local tqf = pg:FindFirstChild("TrackedQuestFrame") if not tqf then return false end
        local frame = tqf:FindFirstChild("Frame") if not frame then return false end
        local header = frame:FindFirstChild("header") if not header then return false end
        local btn = header:FindFirstChild("abandonQuestButton")
        return btn ~= nil and btn:IsA("TextButton")
    end)
    if ok then return r end return false
end

task.spawn(function()
    while true do task.wait(1)
        if not State.SelectedAutoQuest then continue end
        if IsQuestActive() then continue end
        local fn=AutoQuestDefinitions[State.SelectedAutoQuest]
        if fn then fn() end
    end
end)

local function FireHitRemotes(enemyModels)
    if not enemyModels or #enemyModels == 0 then return end

    local hl = {}
    local fh = nil

    for _, model in ipairs(enemyModels) do
        if not model or not model.Parent then continue end
        local h = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Engine") or model:FindFirstChildWhichIsA("BasePart")
        local hum = model:FindFirstChild("Humanoid")
        local isBrigade = (model.Name == "PirateBrigade" or model.Name == "PirateGrandBrigade")
        local isSeaBeast = model.Parent and model.Parent.Name == "SeaBeasts"
        local isFishBoat = (model.Name == "FishBoat" or string.find(model.Name, "FishBoat"))

        if isBrigade or isSeaBeast or isFishBoat then
            local hpVal = model:FindFirstChild("Health")
            if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) and hpVal.Value <= 0 then
                continue
            end
        else
            if not hum or hum.Health <= 0 then continue end
        end

        local folder = model.Parent
        local ch = folder and folder:GetChildren()
        local mi = nil
        if ch then
            for i, c in ipairs(ch) do
                if c == model then mi = i; break end
            end
        end
        if not mi then continue end

        if not fh and h then fh = h end
        if h then table.insert(hl, { ch[mi], h }) end
    end

    if fh and #hl > 0 then
        pcall(function()
            ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(fh, hl)
        end)
    end

    pcall(function()
        ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer(0.01)
    end)
end

local function GetNearbyEnemies(maxDist)
    local r={} local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return r end
    local ef=Workspace:FindFirstChild("Enemies")
    if ef then
        for _,m in ipairs(ef:GetChildren()) do
            if m:IsA("Model") then
                local mh=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Engine") or m:FindFirstChildWhichIsA("BasePart")
                local isSpecial=(m.Name=="PirateBrigade" or m.Name=="PirateGrandBrigade" or m.Name=="FishBoat" or string.find(m.Name,"FishBoat"))
                local isAlive=false
                if isSpecial then
                    local hpVal=m:FindFirstChild("Health")
                    if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) then
                        isAlive=hpVal.Value>0
                    else
                        local h=m:FindFirstChild("Humanoid")
                        isAlive=(h and h.Health>0) or true
                    end
                else
                    local h=m:FindFirstChild("Humanoid")
                    isAlive=h and h.Health>0
                end
                if mh and isAlive and (hrp.Position-mh.Position).Magnitude<=maxDist then table.insert(r,m) end
            end
        end
    end
    local sf=Workspace:FindFirstChild("SeaBeasts")
    if sf then
        for _,m in ipairs(sf:GetChildren()) do
            if m:IsA("Model") then
                local mh=m:FindFirstChild("HumanoidRootPart")
                local hpVal=m:FindFirstChild("Health")
                local isAlive=false

                if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) then
                    isAlive=hpVal.Value>0
                else
                    local h=m:FindFirstChild("Humanoid")
                    isAlive=(h and h.Health>0) or true
                end
                if mh and isAlive and (hrp.Position-mh.Position).Magnitude<=maxDist then table.insert(r,m) end

            end
        end
    end
    local bf=Workspace:FindFirstChild("Boats")
    if bf then
        for _,m in ipairs(bf:GetChildren()) do
            if m:IsA("Model") and (m.Name=="FishBoat" or string.find(m.Name,"FishBoat")) then
                local mh=m:FindFirstChild("Engine") or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                local hpVal=m:FindFirstChild("Health")
                local isAlive=false
                if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) then
                    isAlive=hpVal.Value>0

                else
                    local h=m:FindFirstChild("Humanoid")
                    isAlive=(h and h.Health>0) or true
                end
                if mh and isAlive and (hrp.Position-mh.Position).Magnitude<=maxDist then table.insert(r,m) end
            end
        end
    end
    return r
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not State.KillAuraEnabled and not State.AutoKillEnabled and not State.AutoFarmEnabled and not State.AutoFarmBossEnabled and not State.AutoFarmLevelEnabled and not State.AutoFarmNearbyNPCsEnabled and not State.AutoFarmNearbyBossesEnabled and not State.AutoRaidEnabled and not State.AutoKillSharkEnabled and not State.AutoKillTerrorsharkEnabled and not State.AutoKillPiranhaEnabled and not State.AutoKillBrigadesEnabled and not State.AutoKillSeaBeastEnabled and not State.AutoKillFishBoatEnabled and not State.AutoKillFishCrewMemberEnabled and not State.AutoKillEliteHunterEnabled then
            continue
        end

        local n = GetNearbyEnemies(80)

        if #n > 0 then
            FireHitRemotes(n)
        else

            pcall(function()
                ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer(0.01)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        if not State.PlayerKillAuraEnabled then task.wait(0.1); continue end
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then task.wait(0.1); continue end
        local cf = Workspace:FindFirstChild("Characters")
        if not cf then task.wait(0.1); continue end

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local pm = cf:FindFirstChild(player.Name)
            if not pm then continue end
            local ph = pm:FindFirstChild("HumanoidRootPart")
            local phum = pm:FindFirstChild("Humanoid")
            if not ph or not phum or phum.Health <= 0 then continue end
            if (myHRP.Position - ph.Position).Magnitude > 50 then continue end

            local head = pm:FindFirstChild("Head")

            if head then
                pcall(function()
                    ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(head, {}, nil, "0974210b")
                end)
            end
            pcall(function()
                ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer(0.01)
            end)
        end

        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do task.wait(0.5)
        if not State.AutoHakiEnabled then continue end
        local cf=Workspace:FindFirstChild("Characters") if not cf then continue end
        local pm=cf:FindFirstChild(LocalPlayer.Name) if not pm then continue end
        if pm:FindFirstChild("HasBuso") then continue end
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
    end
end)

local function UpdateWaterWalking()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    if origin then
        local waterCF = origin:FindFirstChild("WaterCFrame")
        local foam = waterCF and (waterCF:FindFirstChild("Foam;") or waterCF:FindFirstChild("Foam")) or origin:FindFirstChild("Foam;") or origin:FindFirstChild("Foam")
        if foam and foam:IsA("BasePart") then
            pcall(function() foam.CanCollide = State.WaterWalkingEnabled end)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if State.WaterWalkingEnabled then
        UpdateWaterWalking()
    end
end)

local function EnableAntiAFK()
    if State.AntiAFKConnection then State.AntiAFKConnection:Disconnect() end
    State.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        if not State.AntiAFKEnabled then return end
        pcall(function()

            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.zero)
        end)
    end)
end

local function DisableAntiAFK()
    if State.AntiAFKConnection then
        State.AntiAFKConnection:Disconnect()
        State.AntiAFKConnection = nil
    end
end

task.spawn(function()

    while true do
        task.wait(0.5)
        if not State.AutoInstinctEnabled then continue end
        local cf = Workspace:FindFirstChild("Characters")
        local char = cf and cf:FindFirstChild(LocalPlayer.Name)
        if char then

            local hl = char:FindFirstChild("Highlight") or char:FindFirstChildWhichIsA("Highlight")
            if not hl then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                task.wait(2)
            end
        end
    end
end)

local function EnableInfiniteStamina()
    if State.InfiniteStaminaConnection then State.InfiniteStaminaConnection:Disconnect() end
    local function hookEnergy(char)
        if not char then return end
        local energy = char:WaitForChild("Energy", 3)
        if energy and (energy:IsA("IntConstrainedValue") or energy:IsA("ValueBase")) then
            pcall(function() energy.Value = 100 end)
            if State.InfiniteStaminaChangedConn then State.InfiniteStaminaChangedConn:Disconnect() end
            State.InfiniteStaminaChangedConn = energy.Changed:Connect(function()
                if not State.InfiniteStaminaEnabled then return end
                pcall(function() energy.Value = 100 end)
            end)
        end
    end

    local c = LocalPlayer.Character
    if c then hookEnergy(c) end
    State.InfiniteStaminaConnection = LocalPlayer.CharacterAdded:Connect(function(nc)
        if not State.InfiniteStaminaEnabled then return end
        hookEnergy(nc)
    end)
end

local function DisableInfiniteStamina()
    if State.InfiniteStaminaConnection then
        State.InfiniteStaminaConnection:Disconnect()
        State.InfiniteStaminaConnection = nil
    end
    if State.InfiniteStaminaChangedConn then
        State.InfiniteStaminaChangedConn:Disconnect()
        State.InfiniteStaminaChangedConn = nil
    end
end

RunService.Heartbeat:Connect(function()
    if not State.InfiniteStaminaEnabled then return end
    local cf = Workspace:FindFirstChild("Characters")
    local c = cf and cf:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character
    local energy = c and c:FindFirstChild("Energy")
    if energy and (energy:IsA("IntConstrainedValue") or energy:IsA("ValueBase")) then
        if energy.Value ~= 100 then
            pcall(function() energy.Value = 100 end)

        end
    end
end)

local function EquipToolByTooltip(tv)
    if not tv then return false end
    local char=LocalPlayer.Character if not char then return false end
    local hum=char:FindFirstChild("Humanoid") if not hum then return false end
    local cur=char:FindFirstChildOfClass("Tool")
    if cur then local ok,t=pcall(function() return cur.ToolTip end) if ok and t==tv then return true end end
    local bp=LocalPlayer:FindFirstChild("Backpack"); local ft=nil
    if bp then for _,tool in ipairs(bp:GetChildren()) do if tool:IsA("Tool") then local ok,t=pcall(function() return tool.ToolTip end) if ok and t==tv then ft=tool;break end end end end
    if not ft then for _,tool in ipairs(char:GetChildren()) do if tool:IsA("Tool") then local ok,t=pcall(function() return tool.ToolTip end) if ok and t==tv then ft=tool;break end end end end
    if not ft then return false end
    pcall(function() hum:EquipTool(ft) end) task.wait(0.35)
    local af=char:FindFirstChildOfClass("Tool")
    if af then local ok,t=pcall(function() return af.ToolTip end) return ok and t==tv end
    return false
end

local function InvokeHumanoidRemotes(hum, key)
    if not hum then return end
    for _, child in ipairs(hum:GetChildren()) do
        if child.Name == "" then
            pcall(function() child:InvokeServer(key) end)
            pcall(function() child:FireServer(key) end)
        end
    end
end

local function IsBuddhaTransformed()
    local cf = Workspace:FindFirstChild("Characters")
    local char = cf and cf:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local origSize = hrp:FindFirstChild("OriginalSize")
    if origSize and (origSize:IsA("Vector3Value") or origSize:IsA("ValueBase")) then
        local val = origSize.Value
        if type(val) == "userdata" or typeof(val) == "Vector3" then
            if val.X > 3 and val.Y > 3 and val.Z > 2 then
                return true
            end
        end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if not State.AutoBuddhaTransformEnabled then
            State.TransformingBuddha = false
            continue
        end

        local transformed = IsBuddhaTransformed()
        if transformed then
            State.TransformingBuddha = false
        else
            local char = LocalPlayer.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local buddhaTool = char:FindFirstChild("Buddha-Buddha")
            if not buddhaTool then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                buddhaTool = bp and bp:FindFirstChild("Buddha-Buddha")
                if buddhaTool then
                    State.TransformingBuddha = true
                    pcall(function() hum:EquipTool(buddhaTool) end)
                    task.wait(0.3)
                end
            else
                State.TransformingBuddha = true
            end

            if char:FindFirstChild("Buddha-Buddha") then
                InvokeHumanoidRemotes(hum, "Z")
                task.wait(0.8)
                if IsBuddhaTransformed() then
                    State.TransformingBuddha = false
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            if State.FruitAutoSkillEnabled then
                if State.SelectedFruitSkills["Z"] or State.FruitAutoSkillZ then InvokeHumanoidRemotes(hum, "Z") end
                if State.SelectedFruitSkills["X"] or State.FruitAutoSkillX then InvokeHumanoidRemotes(hum, "X") end
                if State.SelectedFruitSkills["C"] or State.FruitAutoSkillC then InvokeHumanoidRemotes(hum, "C") end
                if State.SelectedFruitSkills["V"] or State.FruitAutoSkillV then InvokeHumanoidRemotes(hum, "V") end
                if State.SelectedFruitSkills["F"] or State.FruitAutoSkillF then InvokeHumanoidRemotes(hum, "F") end
            end
        end
    end
end)

local function IsPlayerDrivingBoat()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")

    if not hum or not hum.Sit then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local bf = Workspace:FindFirstChild("Boats")
    if bf then
        for _, b in ipairs(bf:GetChildren()) do
            if b:IsA("Model") then
                local vs = b:FindFirstChild("VehicleSeat") or b:FindFirstChildWhichIsA("VehicleSeat") or b:FindFirstChild("Seat")
                if vs then
                    local weld = vs:FindFirstChild("SeatWeld")
                    if weld and (weld.Part1 == hrp or weld.Part0 == hrp or (weld.Part1 and weld.Part1.Parent == char)) then
                        return true
                    end
                    if (hrp.Position - vs.Position).Magnitude < 6 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while true do task.wait(0.3)
        if State.TransformingBuddha then continue end
        if IsPlayerDrivingBoat() then continue end
        if State.AutoEquipWeaponFarm and (State.AutoFarmEnabled or State.AutoFarmBossEnabled or State.AutoFarmLevelEnabled or State.AutoFarmNearbyNPCsEnabled or State.AutoFarmNearbyBossesEnabled or State.AutoKillEliteHunterEnabled or State.AutoFarmMagnetNPCsEnabled) then
            EquipToolByTooltip(State.AutoEquipWeaponFarm)

        end
        if State.RaidAutoEquipWeapon and State.AutoRaidEnabled then
            EquipToolByTooltip(State.RaidAutoEquipWeapon)
        end
        local isSeaEventActive = State.AutoFindSeaEventEnabled or State.AutoFindMirageIslandEnabled or State.AutoFindPrehistoricIslandEnabled or State.AutoKillEnabled or State.AutoKillSharkEnabled or State.AutoKillTerrorsharkEnabled or State.AutoKillPiranhaEnabled or State.AutoKillBrigadesEnabled or State.AutoKillSeaBeastEnabled or State.AutoKillFishBoatEnabled or State.AutoKillFishCrewMemberEnabled
        if State.SeaEventAutoEquipWeapon and isSeaEventActive then
            EquipToolByTooltip(State.SeaEventAutoEquipWeapon)
        end
        if State.AutoEquipWeaponPVP and not State.AutoFarmEnabled and not State.AutoFarmBossEnabled and not State.AutoFarmLevelEnabled and not State.AutoFarmNearbyNPCsEnabled and not State.AutoFarmNearbyBossesEnabled and not State.AutoRaidEnabled and not isSeaEventActive then
            EquipToolByTooltip(State.AutoEquipWeaponPVP)
        end
    end
end)

local function IsTargetReady(t) if not t or not t.Parent then return false end local h=t:FindFirstChild("Humanoid") local r=t:FindFirstChild("HumanoidRootPart") return h~=nil and r~=nil and h.Health>0 end

local WATCHDOG_TIMEOUT = 1.2

local function CheckTargetStuckWatchdog(model, hrp, hum)
    local now = tick()
    local wd = State.WatchdogData[model]

    if not wd then
        State.WatchdogData[model] = { health = hum.Health, time = now }
        return
    end

    if hum.Health < wd.health then
        wd.health = hum.Health
        wd.time   = now
        return
    end

    if now - wd.time > WATCHDOG_TIMEOUT then
        pcall(function()
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            local curCF = hrp.CFrame
            hrp.CFrame = curCF * CFrame.new(0, 0.05, 0)
            task.defer(function()
                if hrp and hrp.Parent then hrp.CFrame = curCF end
            end)
        end)
        hum.PlatformStand = false
        hum.Sit           = false
        wd.health = hum.Health

        wd.time   = now
    end
end

local function AnchorTarget(model)
    if not model then return end
    if model.Name == "SeaBeast" or (model.Parent and model.Parent.Name == "SeaBeasts") then return end
    local hrp = model:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local hum = model:FindFirstChild("Humanoid")

    local isFirstAnchor = not State.anchoredTargets[model]

    if isFirstAnchor or not hrp.Anchored then
        pcall(function() hrp.Anchored = true end)
        State.anchoredTargets[model] = hrp
    end

    if hum then
        if hum.PlatformStand then hum.PlatformStand = false end

        if hum.Sit           then hum.Sit           = false end
    end

    pcall(function()
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        local curCF = hrp.CFrame
        hrp.CFrame = curCF
    end)

    if hum then
        CheckTargetStuckWatchdog(model, hrp, hum)
    end
end

local function UnanchorAll()
    for model, hrp in pairs(State.anchoredTargets) do
        pcall(function() if hrp and hrp.Parent then hrp.Anchored = false end end)
        State.WatchdogData[model] = nil
    end
    State.anchoredTargets = {}
end

local function CleanAnchoredTargets()
    local tr = {}
    for model, hrp in pairs(State.anchoredTargets) do
        local dead = not model or not model.Parent
        if not dead then
            local h = model:FindFirstChild("Humanoid")
            dead = not h or h.Health <= 0
        end
        if dead then
            pcall(function() if hrp and hrp.Parent then hrp.Anchored = false end end)
            State.WatchdogData[model] = nil
            table.insert(tr, model)
        end
    end
    for _, m in ipairs(tr) do State.anchoredTargets[m] = nil end
end

local function GetAllValidNPCTargets()
    local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return {} end
    local ef=Workspace:FindFirstChild("Enemies") if not ef then return {} end
    local hasSel=false for _ in pairs(State.SelectedNPCs) do hasSel=true;break end
    if not hasSel then return {} end
    local res={}
    for _,model in ipairs(ef:GetChildren()) do
        if model:IsA("Model") then
            local matched=false
            for n in pairs(State.SelectedNPCs) do if model.Name==n then matched=true;break end end
            if matched then local h=model:FindFirstChild("Humanoid") local mh=model:FindFirstChild("HumanoidRootPart") if h and h.Health>0 and mh then table.insert(res,model) end end
        end
    end
    table.sort(res,function(a,b) local ah=a:FindFirstChild("HumanoidRootPart") local bh=b:FindFirstChild("HumanoidRootPart") if not ah then return false end if not bh then return true end return (hrp.Position-ah.Position).Magnitude<(hrp.Position-bh.Position).Magnitude end)
    return res
end

local function GetAllValidBossTargets()
    local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return {} end
    local ef=Workspace:FindFirstChild("Enemies") if not ef then return {} end
    local hasSel=false for _ in pairs(State.SelectedBosses) do hasSel=true;break end
    if not hasSel then return {} end
    local nl={}; for n in pairs(State.SelectedBosses) do table.insert(nl,n) end
    local res={}
    for _,model in ipairs(ef:GetChildren()) do
        if model:IsA("Model") then
            local matched=false for _,n in ipairs(nl) do if string.match(model.Name,"^"..n) then matched=true;break end end
            if matched then local h=model:FindFirstChild("Humanoid") local mh=model:FindFirstChild("HumanoidRootPart") if h and h.Health>0 and mh then table.insert(res,model) end end
        end

    end
    table.sort(res,function(a,b) local ah=a:FindFirstChild("HumanoidRootPart") local bh=b:FindFirstChild("HumanoidRootPart") if not ah then return false end if not bh then return true end return (hrp.Position-ah.Position).Magnitude<(hrp.Position-bh.Position).Magnitude end)

    return res
end

local function GetNearbyNPCTargets()
    local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return {} end
    local ef=Workspace:FindFirstChild("Enemies") if not ef then return {} end
    local res={}
    for _,model in ipairs(ef:GetChildren()) do
        if model:IsA("Model") then
            local h=model:FindFirstChild("Humanoid") local mh=model:FindFirstChild("HumanoidRootPart")
            if h and h.Health>0 and mh then table.insert(res,model) end
        end
    end
    table.sort(res,function(a,b) local ah=a:FindFirstChild("HumanoidRootPart") local bh=b:FindFirstChild("HumanoidRootPart") if not ah then return false end if not bh then return true end return (hrp.Position-ah.Position).Magnitude<(hrp.Position-bh.Position).Magnitude end)
    return res
end

local function GetNearbyBossTargets()
    local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if not hrp then return {} end
    local ef=Workspace:FindFirstChild("Enemies") if not ef then return {} end
    local res={}
    for _,model in ipairs(ef:GetChildren()) do
        if model:IsA("Model") then
            local matched=false for _,n in ipairs(BossNames) do if string.match(model.Name,"^"..n) then matched=true;break end end
            if matched then local h=model:FindFirstChild("Humanoid") local mh=model:FindFirstChild("HumanoidRootPart") if h and h.Health>0 and mh then table.insert(res,model) end end
        end
    end
    table.sort(res,function(a,b) local ah=a:FindFirstChild("HumanoidRootPart") local bh=b:FindFirstChild("HumanoidRootPart") if not ah then return false end if not bh then return true end return (hrp.Position-ah.Position).Magnitude<(hrp.Position-bh.Position).Magnitude end)
    return res
end

local EliteHunterNames = {"Urban", "Diablo", "Deandre", "Tyrant of the Skies"}

local function GetEliteHunterTarget()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, false end

    local ef = Workspace:FindFirstChild("Enemies")
    if ef then
        local workspaceTargets = {}
        for _, model in ipairs(ef:GetChildren()) do
            if model:IsA("Model") then
                local matched = false
                for _, name in ipairs(EliteHunterNames) do
                    if model.Name == name or string.find(model.Name, name) then
                        matched = true
                        break
                    end
                end
                if matched then
                    local h = model:FindFirstChild("Humanoid")
                    local mh = model:FindFirstChild("HumanoidRootPart")
                    if h and h.Health > 0 and mh then

                        table.insert(workspaceTargets, model)
                    end
                end
            end
        end
        if #workspaceTargets > 0 then
            table.sort(workspaceTargets, function(a, b)

                local ah = a:FindFirstChild("HumanoidRootPart")
                local bh = b:FindFirstChild("HumanoidRootPart")
                if not ah then return false end
                if not bh then return true end
                return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
            end)
            return workspaceTargets[1], true
        end
    end

    for _, name in ipairs(EliteHunterNames) do
        local repModel = ReplicatedStorage:FindFirstChild(name)
        if repModel then
            local mh = repModel:FindFirstChild("HumanoidRootPart") or repModel.PrimaryPart or repModel:FindFirstChildWhichIsA("BasePart")
            if mh then
                return repModel, false
            end

        end
    end

    return nil, false
end

local function FindTargetBoss() local b=GetAllValidBossTargets() if #b>0 then return b[1] end return nil end
local function FindTargetNearbyBoss() local b=GetNearbyBossTargets() if #b>0 then return b[1] end return nil end

local function GetBaseNameFromSpawnPart(part)
    local dn=nil pcall(function() dn=part:GetAttribute("DisplayName") end)
    if dn then local b=string.match(dn,"^(.-)%s*%[") if b then return b:match("^%s*(.-)%s*$") end return dn:match("^%s*(.-)%s*$") end
    return GetBaseNameFromSpawnPartName(part.Name)
end

local function GetMobTopPosition(model, customDist)
    local hrp = model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Engine") or model:FindFirstChild("Head", true) or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))
    if not hrp then return nil, nil end
    local dist = customDist or State.DistanceBetweenNPC or 5
    local topY = hrp.Position.Y
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then

            local pt = p.Position.Y + (p.Size.Y / 2)
            if pt > topY then topY = pt end
        end
    end
    local tp = Vector3.new(hrp.Position.X, topY + dist, hrp.Position.Z)
    local lookTarget = Vector3.new(hrp.Position.X, tp.Y, hrp.Position.Z + 1)
    return CFrame.lookAt(tp, lookTarget, Vector3.new(0, 1, 0)), hrp
end

local function TPBackToFarmPosition(pos)
    if not pos then return end task.wait(0.5)
    for i=1,2 do local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame=CFrame.lookAt(pos, pos+Vector3.new(0,0,1), Vector3.new(0,1,0)) end if i<2 then task.wait(0.1) end end
end

local function FindClosestSpawnPart(nameList)
    local sf=Workspace:FindFirstChild("_WorldOrigin") sf=sf and sf:FindFirstChild("EnemySpawns") if not sf then return nil end
    local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local bp=nil; local bd=math.huge
    for _,part in ipairs(sf:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local bn=GetBaseNameFromSpawnPartName(part.Name) if not bn then continue end
        local matched=false for _,n in ipairs(nameList) do if bn==n then matched=true;break end end
        if not matched then continue end
        if hrp then local d=(hrp.Position-part.Position).Magnitude if d<bd then bd=d;bp=part end else bp=part;break end
    end
    return bp
end

local function FindClosestSpawnPartForNPCs()
    local hasSel=false for _ in pairs(State.SelectedNPCs) do hasSel=true;break end
    if not hasSel then return nil end
    local nl={}; for n in pairs(State.SelectedNPCs) do table.insert(nl,n) end
    return FindClosestSpawnPart(nl)
end

local function FindClosestSpawnPartForBosses()
    local hasSel=false for _ in pairs(State.SelectedBosses) do hasSel=true;break end
    if not hasSel then return nil end
    local nl={}; for n in pairs(State.SelectedBosses) do table.insert(nl,n) end
    return FindClosestSpawnPart(nl)
end

local function FindClosestSpawnPartForNearbyBosses()
    return FindClosestSpawnPart(BossNames)
end

local function FindClosestSpawnPartForNearbyNPCs()
    return FindClosestSpawnPart(NPCNames)
end

local function FindEnemyModelBySpawnPart(spawnPart)
    if not spawnPart then return nil end
    local bn=GetBaseNameFromSpawnPartName(spawnPart.Name) if not bn then return nil end
    local ef=Workspace:FindFirstChild("Enemies") if not ef then return nil end
    local char=LocalPlayer.Character local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local cl=nil; local cd=math.huge
    for _,model in ipairs(ef:GetChildren()) do
        if model:IsA("Model") and model.Name==bn then
            local h=model:FindFirstChild("Humanoid") local mh=model:FindFirstChild("HumanoidRootPart")
            if h and h.Health>0 and mh then
                if hrp then local d=(hrp.Position-mh.Position).Magnitude if d<cd then cd=d;cl=model end else return model end
            end
        end
    end
    return cl
end

local function IsPositionInsideSingleIsland(pos, island)
    if not island or not island.Parent then return false end
    local ok, cf, size = pcall(function() return island:GetBoundingBox() end)
    if ok and cf and size and size.X > 5 and size.Z > 5 then
        local localP = cf:PointToObjectSpace(pos)
        local halfX = size.X / 2 + 100
        local halfZ = size.Z / 2 + 100
        local halfY = size.Y / 2 + 300
        if math.abs(localP.X) <= halfX and math.abs(localP.Z) <= halfZ and math.abs(localP.Y) <= halfY then
            return true
        end
    end
    for _, part in ipairs(island:GetDescendants()) do
        if part:IsA("BasePart") then
            local d = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(part.Position.X, 0, part.Position.Z)).Magnitude
            if d <= math.max(part.Size.X, part.Size.Z) / 2 + 100 then
                return true
            end
        end
    end
    return false
end

local function HasRaidNotifier(hrp)
    if not hrp then return false end
    local en = hrp:FindFirstChild("EnemyNotifier")
    if en and en:IsA("BillboardGui") then return true end
    local bn = hrp:FindFirstChild("BossNotifier")
    if bn and bn:IsA("BillboardGui") then return true end
    return false
end

local function GetRaidTargetsForIsland(island)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local ef = Workspace:FindFirstChild("Enemies")
    local res = {}
    if not ef or not island then return res end

    for _, model in ipairs(ef:GetChildren()) do
        if model:IsA("Model") then
            local mh = model:FindFirstChild("HumanoidRootPart")
            local h = model:FindFirstChild("Humanoid")

            if mh and h and h.Health > 0 then
                if HasRaidNotifier(mh) then
                    if IsPositionInsideSingleIsland(mh.Position, island) then
                        table.insert(res, model)
                    end
                end
            end
        end
    end

    table.sort(res, function(a, b)
        local ah = a:FindFirstChild("HumanoidRootPart")
        local bh = b:FindFirstChild("HumanoidRootPart")
        if not ah then return false end
        if not bh then return true end
        if not hrp then return false end
        return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
    end)

    return res
end

local function GetIslandCenterPosition(island)
    if not island then return nil end
    local centerPart = island:FindFirstChild("Center") or island:FindFirstChild("Spawn") or island:FindFirstChild("Spawns") or island:FindFirstChild("Platform") or island:FindFirstChild("Base")
    if centerPart and centerPart:IsA("BasePart") then
        return centerPart.Position
    end
    local maxPart = nil
    local maxVol = 0
    for _, part in ipairs(island:GetDescendants()) do
        if part:IsA("BasePart") then
            local vol = part.Size.X * part.Size.Y * part.Size.Z
            if vol > maxVol then
                maxVol = vol
                maxPart = part

            end
        end
    end
    if maxPart then
        return maxPart.Position
    end
    local ok, cf, size = pcall(function() return island:GetBoundingBox() end)
    if ok and cf and size and size.Magnitude > 0 then
        return cf.Position
    end
    local ok2, piv = pcall(function() return island:GetPivot() end)
    if ok2 and piv then
        return piv.Position
    end
    return nil
end

local function GetHighestExistingRaidIsland(rm)
    if not rm then return nil, nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local maxIdx = -1
    local maxIsland = nil
    for _, island in ipairs(rm:GetChildren()) do
        if island:IsA("Model") then
            local dist = 0
            if hrp then
                local center = GetIslandCenterPosition(island)
                if center then
                    dist = (hrp.Position - center).Magnitude
                end
            end

            if dist <= 3000 then
                local numStr = string.match(island.Name, "^RaidIsland(%d+)$") or string.match(island.Name, "RaidIsland(%d+)")
                if numStr then
                    local num = tonumber(numStr)
                    if num and num > maxIdx then
                        maxIdx = num
                        maxIsland = island

                    end
                elseif island.Name == "RaidIsland" and maxIdx < 1 then
                    maxIdx = 1
                    maxIsland = island
                end
            end
        end

    end
    return maxIdx, maxIsland
end

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if State.BringNPCsEnabled or State.RaidBringNPCsEnabled or State.SeaEventBringNPCsEnabled then
            pcall(function()
                if setscriptable then
                    setscriptable(LocalPlayer, "SimulationRadius", true)
                end
                if sethiddenproperty then
                    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
                end
            end)
        end
    end)
end)

local EXCLUDED_BRING_TARGETS = {
    ["Brigades"] = true,
    ["Fish Boat"] = true,
    ["Sea Beast"] = true,
    ["SeaBeast"] = true,
    ["PirateBrigade"] = true,
}

local function IsExcludedBringTarget(name)
    if not name then return true end
    if EXCLUDED_BRING_TARGETS[name] then return true end
    for k in pairs(EXCLUDED_BRING_TARGETS) do
        if string.find(name, k) then
            return true
        end
    end
    return false
end

local function DoBringNPCs(primaryTarget, primaryHRP, isRaid, currentRaidIsland, isSeaEvent)
    local broughtList = {}
    if not primaryTarget or not primaryTarget.Parent or not primaryHRP then return broughtList end
    table.insert(broughtList, primaryTarget)
    if IsExcludedBringTarget(primaryTarget.Name) then return broughtList end

    if isRaid then
        if not State.RaidBringNPCsEnabled or not currentRaidIsland then return broughtList end
    elseif isSeaEvent then
        if not State.SeaEventBringNPCsEnabled then return broughtList end
    else
        if not State.BringNPCsEnabled then return broughtList end
    end

    pcall(function()
        if setscriptable then setscriptable(LocalPlayer, "SimulationRadius", true) end
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
        end
    end)

    local ef = Workspace:FindFirstChild("Enemies")
    if not ef then return broughtList end

    local char = LocalPlayer.Character
    local charHRP = char and char:FindFirstChild("HumanoidRootPart")

    for _, model in ipairs(ef:GetChildren()) do
        if model ~= primaryTarget and model:IsA("Model") then
            local mh = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
            local hum = model:FindFirstChild("Humanoid")
            if mh and hum and hum.Health > 0 then
                local distToPrimary = (mh.Position - primaryHRP.Position).Magnitude
                local distToChar = charHRP and (mh.Position - charHRP.Position).Magnitude or distToPrimary
                if distToPrimary <= 300 or distToChar <= 300 then
                    local canBring = false
                    if isRaid then
                        if HasRaidNotifier(mh) and IsPositionInsideSingleIsland(mh.Position, currentRaidIsland) then
                            canBring = true
                        end
                    elseif isSeaEvent then
                        if model.Name == primaryTarget.Name then
                            canBring = true
                        end
                    else
                        if model.Name == primaryTarget.Name then
                            canBring = true
                        elseif State.AutoFarmMagnetNPCsEnabled and model:FindFirstChild("MagnetModeProxy") then
                            canBring = true
                        elseif State.AutoFarmBossEnabled or State.AutoFarmNearbyBossesEnabled then
                            if string.match(model.Name, "^" .. primaryTarget.Name) then
                                canBring = true
                            end
                        elseif State.AutoFarmNearbyNPCsEnabled then

                            canBring = true
                        end
                    end

                    if canBring then
                        pcall(function()
                            if mh.Anchored then mh.Anchored = false end
                            mh.AssemblyLinearVelocity = Vector3.zero
                            mh.AssemblyAngularVelocity = Vector3.zero
                            if not hum.PlatformStand then hum.PlatformStand = true end
                            for _, p in ipairs(model:GetDescendants()) do
                                if p:IsA("BasePart") and p.CanCollide then
                                    p.CanCollide = false
                                end
                            end
                            mh.CFrame = primaryHRP.CFrame

                            if mh.Size ~= Vector3.new(1, 1, 1) then
                                mh.Size = Vector3.new(1, 1, 1)
                            end
                        end)
                        table.insert(broughtList, model)
                    end
                end
            end
        end
    end
    return broughtList
end

local function StepMoveTowards(hrp, hum, targetPos, dt)
    local curPos = hrp.Position

    local dist = (curPos - targetPos).Magnitude
    local isUnderRespawn = (tick() - State.LastRespawnTick) <= 3
    State.IsTweening = dist > 0.5

    local c = LocalPlayer.Character
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end

    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    hum.PlatformStand = true

    local newPos
    if dist >= State.TWEEN_THRESHOLD or isUnderRespawn then
        local step = math.min(State.TWEEN_SPEED * dt, dist)
        if dist > 0.001 then
            newPos = curPos + (targetPos - curPos).Unit * step
        else
            newPos = targetPos
        end
    else
        local alpha = math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1)
        newPos = curPos:Lerp(targetPos, alpha)
    end

    local lookTarget = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
    if (lookTarget - newPos).Magnitude > 0.01 then
        hrp.CFrame = CFrame.lookAt(newPos, lookTarget, Vector3.new(0, 1, 0))
    else
        hrp.CFrame = CFrame.new(newPos)
    end
end

local function FarmNormalLoop()
    local lastReturnPos = nil

    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFarmEnabled then
            hb:Disconnect(); UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local hasSel = false
        for _ in pairs(State.SelectedNPCs) do hasSel = true; break end
        if not hasSel then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")

        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CleanAnchoredTargets()

        local npcTargets = GetAllValidNPCTargets()
        if #npcTargets > 0 then
            local target = npcTargets[1]

            if IsTargetReady(target) then
                local tmh = target:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    local dist = (hrp.Position - targetPos).Magnitude
                    if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                        StepMoveTowards(hrp, hum, targetPos, dt)
                        return
                    else
                        AnchorTarget(target)
                        hum.PlatformStand = true
                        pcall(function()
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero

                        end)
                        local cf, thr = GetMobTopPosition(target)
                        if cf then
                            local mobDist = (hrp.Position - cf.Position).Magnitude
                            if mobDist < 0.5 then
                                hrp.CFrame = cf
                            else
                                hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                            end
                            if thr then
                                lastReturnPos = thr.Position
                                if State.BringNPCsEnabled and mobDist <= 5 then
                                    DoBringNPCs(target, thr)
                                end
                            end
                        end
                        return
                    end
                end
            end
        end

        local spawnPart = FindClosestSpawnPartForNPCs()
        if spawnPart then
            local fm = FindEnemyModelBySpawnPart(spawnPart)
            if fm and IsTargetReady(fm) then
                local tmh = fm:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                end
            end
            local spawnPos = spawnPart.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
            StepMoveTowards(hrp, hum, spawnPos, dt)
        else
            hum.PlatformStand = false
            if lastReturnPos then
                local p = lastReturnPos; lastReturnPos = nil
                task.spawn(function() TPBackToFarmPosition(p) end)
            end
        end
    end)

    while State.AutoFarmEnabled do task.wait(0.05) end
    hb:Disconnect(); UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
    if lastReturnPos then
        local p = lastReturnPos
        task.spawn(function() TPBackToFarmPosition(p) end)
    end
end

local function FarmBossLoop()
    local lastReturnPos = nil

    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFarmBossEnabled then
            hb:Disconnect(); UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")

            if h then h.PlatformStand = false end
            return
        end

        local hasSel = false
        for _ in pairs(State.SelectedBosses) do hasSel = true; break end
        if not hasSel then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CleanAnchoredTargets()

        local bt = FindTargetBoss()
        if bt and IsTargetReady(bt) then
            local tmh = bt:FindFirstChild("HumanoidRootPart")
            if tmh then
                local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                local dist = (hrp.Position - targetPos).Magnitude
                if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                else
                    AnchorTarget(bt)
                    hum.PlatformStand = true
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                    local cf, thr = GetMobTopPosition(bt)
                    if cf then
                        local mobDist = (hrp.Position - cf.Position).Magnitude
                        if mobDist < 0.5 then
                            hrp.CFrame = cf
                        else
                            hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                        end
                        if thr then
                            lastReturnPos = thr.Position
                            if State.BringNPCsEnabled and mobDist <= 3 then
                                DoBringNPCs(bt, thr)
                            end
                        end
                    end
                    return
                end
            end
        end

        local spawnPart = FindClosestSpawnPartForBosses()
        if spawnPart then
            local fm = FindEnemyModelBySpawnPart(spawnPart)
            if fm and IsTargetReady(fm) then
                local tmh = fm:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                end
            end
            local spawnPos = spawnPart.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
            StepMoveTowards(hrp, hum, spawnPos, dt)
        else
            hum.PlatformStand = false
            if lastReturnPos then
                local p = lastReturnPos; lastReturnPos = nil
                task.spawn(function() TPBackToFarmPosition(p) end)
            end
        end
    end)

    while State.AutoFarmBossEnabled do task.wait(0.05) end
    hb:Disconnect(); UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
    if lastReturnPos then
        local p = lastReturnPos
        task.spawn(function() TPBackToFarmPosition(p) end)
    end
end

local function FarmNearbyNPCsLoop()
    local lastReturnPos = nil

    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFarmNearbyNPCsEnabled then
            hb:Disconnect(); UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CleanAnchoredTargets()

        local nearby = GetNearbyNPCTargets()
        if #nearby > 0 then

            local target = nearby[1]
            if IsTargetReady(target) then
                local tmh = target:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    local dist = (hrp.Position - targetPos).Magnitude
                    if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                        StepMoveTowards(hrp, hum, targetPos, dt)
                        return
                    else
                        AnchorTarget(target)
                        hum.PlatformStand = true
                        pcall(function()
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                        local cf, thr = GetMobTopPosition(target)
                        if cf then
                            local mobDist = (hrp.Position - cf.Position).Magnitude
                            if mobDist < 0.5 then
                                hrp.CFrame = cf
                            else
                                hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                            end
                            if thr then
                                lastReturnPos = thr.Position

                                if State.BringNPCsEnabled and mobDist <= 3 then
                                    DoBringNPCs(target, thr)
                                end
                            end
                        end
                        return
                    end
                end
            end
        end

        local spawnPart = FindClosestSpawnPartForNearbyNPCs()
        if spawnPart then
            local fm = FindEnemyModelBySpawnPart(spawnPart)
            if fm and IsTargetReady(fm) then
                local tmh = fm:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                end
            end
            local spawnPos = spawnPart.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
            StepMoveTowards(hrp, hum, spawnPos, dt)
        else
            hum.PlatformStand = false
            if lastReturnPos then
                local p = lastReturnPos; lastReturnPos = nil
                task.spawn(function() TPBackToFarmPosition(p) end)
            end
        end
    end)

    while State.AutoFarmNearbyNPCsEnabled do task.wait(0.05) end
    hb:Disconnect(); UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
    if lastReturnPos then
        local p = lastReturnPos
        task.spawn(function() TPBackToFarmPosition(p) end)
    end
end

local function FarmNearbyBossesLoop()
    local lastReturnPos = nil

    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFarmNearbyBossesEnabled then
            hb:Disconnect(); UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local char = LocalPlayer.Character

        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")

        if not hrp then return end

        CleanAnchoredTargets()

        local bt = FindTargetNearbyBoss()
        if bt and IsTargetReady(bt) then
            local tmh = bt:FindFirstChild("HumanoidRootPart")
            if tmh then
                local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                local dist = (hrp.Position - targetPos).Magnitude
                if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                else
                    AnchorTarget(bt)
                    hum.PlatformStand = true
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                    local cf, thr = GetMobTopPosition(bt)
                    if cf then
                        local mobDist = (hrp.Position - cf.Position).Magnitude
                        if mobDist < 0.5 then

                            hrp.CFrame = cf
                        else
                            hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                        end
                        if thr then
                            lastReturnPos = thr.Position
                            if State.BringNPCsEnabled and mobDist <= 3 then
                                DoBringNPCs(bt, thr)
                            end
                        end
                    end
                    return
                end
            end
        end

        local spawnPart = FindClosestSpawnPartForNearbyBosses()
        if spawnPart then
            local fm = FindEnemyModelBySpawnPart(spawnPart)
            if fm and IsTargetReady(fm) then
                local tmh = fm:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                end
            end
            local spawnPos = spawnPart.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
            StepMoveTowards(hrp, hum, spawnPos, dt)
        else
            hum.PlatformStand = false
            if lastReturnPos then
                local p = lastReturnPos; lastReturnPos = nil
                task.spawn(function() TPBackToFarmPosition(p) end)
            end
        end
    end)

    while State.AutoFarmNearbyBossesEnabled do task.wait(0.05) end
    hb:Disconnect(); UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
    if lastReturnPos then

        local p = lastReturnPos
        task.spawn(function() TPBackToFarmPosition(p) end)
    end
end

local function FarmEliteHunterLoop()
    local lastReturnPos = nil
    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoKillEliteHunterEnabled then
            hb:Disconnect()
            UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CleanAnchoredTargets()

        local target, isWorkspace = GetEliteHunterTarget()
        if target then
            local tmh = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
            if tmh then
                local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                if isWorkspace and IsTargetReady(target) then
                    local dist = (hrp.Position - targetPos).Magnitude
                    if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                        StepMoveTowards(hrp, hum, targetPos, dt)
                        return
                    else
                        AnchorTarget(target)
                        hum.PlatformStand = true
                        pcall(function()
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                        local cf, thr = GetMobTopPosition(target)
                        if cf then
                            local mobDist = (hrp.Position - cf.Position).Magnitude
                            if mobDist < 0.5 then
                                hrp.CFrame = cf
                            else
                                hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                            end
                            if thr then
                                lastReturnPos = thr.Position
                                if State.BringNPCsEnabled and mobDist <= 3 then
                                    DoBringNPCs(target, thr)
                                end
                            end
                        end
                        FireHitRemotes({target})
                        return
                    end
                else
                    hum.PlatformStand = true
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                end
            end
        else
            hum.PlatformStand = false
            if lastReturnPos then
                local p = lastReturnPos
                lastReturnPos = nil
                task.spawn(function() TPBackToFarmPosition(p) end)
            end
        end
    end)

    while State.AutoKillEliteHunterEnabled do task.wait(0.05) end
    hb:Disconnect()
    UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
    if lastReturnPos then

        local p = lastReturnPos
        task.spawn(function() TPBackToFarmPosition(p) end)
    end
end

local function GetBestNPCForPlayer(pl)
    local best = nil
    for _, entry in ipairs(NPCLevelData) do
        if entry.level <= pl then
            best = entry
        else
            break
        end
    end
    if best then
        return best.name, best.quest
    end
    return "Bandit", "Bandit Quest"
end

local function FarmLevelLoop()
    local lastReturnPos = nil
    local waitingAtPos = nil
    local lastQuestNPCName = nil

    local function TryTakeQuestForNPC(questName)
        if not questName then return end
        local fn = AutoQuestDefinitions[questName]
        if fn then
            for i = 1, 3 do
                fn()
                if i < 3 then task.wait(0.3) end
            end
        end
    end

    local qcc
    qcc = RunService.Heartbeat:Connect(function()
        if not State.AutoFarmLevelEnabled then qcc:Disconnect(); return end
        if not lastQuestNPCName or IsQuestActive() then return end
        local qn = NPCToQuestMap[lastQuestNPCName]
        if not qn then return end
        local fn = AutoQuestDefinitions[qn]
        if fn then fn() end
    end)

    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFarmLevelEnabled then
            hb:Disconnect()

            UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CleanAnchoredTargets()

        local pl = GetPlayerLevel()
        local bestNPCName, bestQuestName = GetBestNPCForPlayer(pl)
        if not bestNPCName then return end

        if bestNPCName ~= lastQuestNPCName then
            lastQuestNPCName = bestNPCName
            task.spawn(function() TryTakeQuestForNPC(bestQuestName or NPCToQuestMap[bestNPCName]) end)
        end

        local ef = Workspace:FindFirstChild("Enemies")
        local instances = {}
        if ef then
            for _, model in ipairs(ef:GetChildren()) do
                if model:IsA("Model") and model.Name == bestNPCName then
                    local h = model:FindFirstChild("Humanoid")
                    local mh = model:FindFirstChild("HumanoidRootPart")
                    if h and h.Health > 0 and mh then
                        local d = (hrp.Position - mh.Position).Magnitude
                        table.insert(instances, { model = model, hrp = mh, dist = d })
                    end

                end
            end
        end

        table.sort(instances, function(a, b) return a.dist < b.dist end)

        if #instances > 0 then
            local entry = instances[1]
            local target = entry.model
            if IsTargetReady(target) then
                local tmh = entry.hrp
                local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                local dist = (hrp.Position - targetPos).Magnitude

                if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                else
                    AnchorTarget(target)
                    hum.PlatformStand = true
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                    local cf, thr = GetMobTopPosition(target)
                    if cf then
                        local mobDist = (hrp.Position - cf.Position).Magnitude
                        if mobDist < 0.5 then
                            hrp.CFrame = cf
                        else
                            hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                        end
                        lastReturnPos = thr and thr.Position or nil
                        if State.BringNPCsEnabled and thr and mobDist <= 3 then
                            DoBringNPCs(target, thr)
                        end
                    end
                    return
                end
            end
        end

        local sf = Workspace:FindFirstChild("_WorldOrigin")

        sf = sf and sf:FindFirstChild("EnemySpawns")
        local bestSpawnPart = nil
        local minSpawnDist = math.huge
        if sf then
            for _, part in ipairs(sf:GetDescendants()) do
                if part:IsA("BasePart") then
                    local bn = GetBaseNameFromSpawnPart(part)
                    if bn == bestNPCName then
                        local d = (hrp.Position - part.Position).Magnitude
                        if d < minSpawnDist then
                            minSpawnDist = d
                            bestSpawnPart = part
                        end
                    end
                end
            end
        end

        if bestSpawnPart then
            local spawnPos = bestSpawnPart.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
            local dist = (hrp.Position - spawnPos).Magnitude
            if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                StepMoveTowards(hrp, hum, spawnPos, dt)
            else
                hum.PlatformStand = true
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(spawnPos, spawnPos + Vector3.new(0, 0, 1), Vector3.new(0, 1, 0)), math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
            end
            waitingAtPos = spawnPos
        else
            if waitingAtPos then
                hum.PlatformStand = true
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                hrp.CFrame = CFrame.lookAt(waitingAtPos, waitingAtPos + Vector3.new(0, 0, 1), Vector3.new(0, 1, 0))
            elseif lastReturnPos then
                waitingAtPos = lastReturnPos
                hum.PlatformStand = true
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                hrp.CFrame = CFrame.lookAt(waitingAtPos, waitingAtPos + Vector3.new(0, 0, 1), Vector3.new(0, 1, 0))

            else
                hum.PlatformStand = false
            end
        end
    end)

    while State.AutoFarmLevelEnabled do task.wait(0.05) end
    if qcc then qcc:Disconnect() end
    hb:Disconnect()
    UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
    if lastReturnPos then
        local p = lastReturnPos
        task.spawn(function() TPBackToFarmPosition(p) end)
    end
end

local function RaidFarmLoop()
    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoRaidEnabled then
            hb:Disconnect()
            UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CleanAnchoredTargets()

        local rm = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("RaidMap")
        if not rm then
            hum.PlatformStand = false
            return
        end

        local highestIdx, highestIsland = GetHighestExistingRaidIsland(rm)
        if not highestIsland or highestIdx < 1 then
            hum.PlatformStand = false
            return
        end

        local raidTargets = GetRaidTargetsForIsland(highestIsland)

        if #raidTargets > 0 then
            local target = raidTargets[1]
            if IsTargetReady(target) then
                local tmh = target:FindFirstChild("HumanoidRootPart")
                if tmh then
                    local targetPos = tmh.Position + Vector3.new(0, State.RaidDistanceBetweenNPC, 0)
                    local dist = (hrp.Position - targetPos).Magnitude

                    if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                        StepMoveTowards(hrp, hum, targetPos, dt)
                    else
                        AnchorTarget(target)
                        hum.PlatformStand = true
                        pcall(function()
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end)
                        local cf, thr = GetMobTopPosition(target, State.RaidDistanceBetweenNPC)
                        if cf then
                            local mobDist = (hrp.Position - cf.Position).Magnitude
                            if mobDist < 0.5 then
                                hrp.CFrame = cf
                            else
                                hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                            end
                            if State.RaidBringNPCsEnabled and mobDist <= 3 and thr then
                                DoBringNPCs(target, thr, true, highestIsland)
                            end
                        end
                    end
                end

            end
        else
            local islandCenter = GetIslandCenterPosition(highestIsland)
            if islandCenter then
                local waitPos = islandCenter + Vector3.new(0, State.RaidDistanceBetweenNPC, 0)

                local dist = (hrp.Position - waitPos).Magnitude
                if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then

                    StepMoveTowards(hrp, hum, waitPos, dt)
                elseif dist > 1 then
                    StepMoveTowards(hrp, hum, waitPos, dt)
                else
                    hum.PlatformStand = false
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)

                end
            else
                hum.PlatformStand = false
            end
        end
    end)

    while State.AutoRaidEnabled do task.wait(0.05) end
    hb:Disconnect()
    UnanchorAll()
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChild("Humanoid")
    if h then h.PlatformStand = false end
end

local function RemoveAllESP()
    for _,obj in pairs(State.ESPObjects) do if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end end
    State.ESPObjects={}
end

local function CreateESPForModel(model,displayName)
    if State.ESPObjects[model] then return end
    local rp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart if not rp then return end
    local hl=Instance.new("SelectionBox");hl.Color3=Color3.fromRGB(120,80,255);hl.LineThickness=0.07;hl.SurfaceTransparency=0.85;hl.SurfaceColor3=Color3.fromRGB(120,80,255);hl.Adornee=model;hl.Parent=Workspace.CurrentCamera
    local bb=Instance.new("BillboardGui");bb.AlwaysOnTop=true;bb.Size=UDim2.new(0,160,0,50);bb.StudsOffset=Vector3.new(0,4,0);bb.Adornee=rp;bb.Parent=Workspace.CurrentCamera
    local nl=Instance.new("TextLabel");nl.Size=UDim2.new(1,0,0.52,0);nl.BackgroundTransparency=1;nl.TextColor3=Color3.fromRGB(200,170,255);nl.TextStrokeTransparency=0.35;nl.TextStrokeColor3=Color3.fromRGB(20,5,50);nl.Font=Enum.Font.GothamBold;nl.TextSize=14;nl.Text=displayName or model.Name;nl.Parent=bb
    local dl=Instance.new("TextLabel");dl.Size=UDim2.new(1,0,0.48,0);dl.Position=UDim2.new(0,0,0.52,0);dl.BackgroundTransparency=1;dl.TextColor3=Color3.fromRGB(255,220,100);dl.TextStrokeTransparency=0.35;dl.TextStrokeColor3=Color3.fromRGB(20,5,50);dl.Font=Enum.Font.GothamBold;dl.TextSize=13;dl.Text="-- m";dl.Parent=bb
    State.ESPObjects[model]={highlight=hl,billboard=bb,distLabel=dl,rootPart=rp}
end

RunService.Heartbeat:Connect(function()
    if not State.ServiceNPCESPEnabled then return end
    local cHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local nf=Workspace:FindFirstChild("NPCs"); local am={}
    if nf then for _,m in pairs(nf:GetChildren()) do if m:IsA("Model") then am[m]=m.Name end end end
    for m,dn in pairs(am) do if not State.ESPObjects[m] then CreateESPForModel(m,dn) end end
    local tr={}; for m in pairs(State.ESPObjects) do if not am[m] then table.insert(tr,m) end end
    for _,m in ipairs(tr) do local o=State.ESPObjects[m] if o.highlight and o.highlight.Parent then o.highlight:Destroy() end if o.billboard and o.billboard.Parent then o.billboard:Destroy() end State.ESPObjects[m]=nil end
    if cHRP then for _,e in pairs(State.ESPObjects) do if e.rootPart and e.rootPart.Parent then e.distLabel.Text=math.floor((cHRP.Position-e.rootPart.Position).Magnitude).." m" end end end
end)

local function RemoveAllFruitESP()
    for _,obj in pairs(State.FruitESPObjects) do if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end end
    State.FruitESPObjects={}
end

local function CreateFruitESP(item)
    if State.FruitESPObjects[item] then return end
    local rp = item:IsA("BasePart") and item or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart") or item.PrimaryPart
    if not rp then return end
    local hl = Instance.new("SelectionBox")
    hl.Color3 = Color3.fromRGB(255, 100, 200)
    hl.LineThickness = 0.07
    hl.SurfaceTransparency = 0.85
    hl.SurfaceColor3 = Color3.fromRGB(255, 100, 200)
    hl.Adornee = item
    hl.Parent = Workspace.CurrentCamera

    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 160, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = rp
    bb.Parent = Workspace.CurrentCamera

    local nl = Instance.new("TextLabel")
    nl.Size = UDim2.new(1, 0, 0.52, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.fromRGB(255, 180, 230)
    nl.TextStrokeTransparency = 0.35
    nl.TextStrokeColor3 = Color3.fromRGB(50, 5, 30)
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 14
    nl.Text = item.Name
    nl.Parent = bb

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, 0, 0.48, 0)
    dl.Position = UDim2.new(0, 0, 0.52, 0)
    dl.BackgroundTransparency = 1
    dl.TextColor3 = Color3.fromRGB(255, 230, 150)
    dl.TextStrokeTransparency = 0.35
    dl.TextStrokeColor3 = Color3.fromRGB(50, 5, 30)
    dl.Font = Enum.Font.GothamBold
    dl.TextSize = 13
    dl.Text = "-- m"
    dl.Parent = bb

    State.FruitESPObjects[item] = {highlight = hl, billboard = bb, distLabel = dl, rootPart = rp}
end

RunService.Heartbeat:Connect(function()

    if not State.FruitESPEnabled then return end
    local cHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local af = {}
    for _, item in ipairs(Workspace:GetChildren()) do
        if string.find(string.lower(item.Name), "fruit") then
            af[item] = true
        end
    end
    for item in pairs(af) do
        if not State.FruitESPObjects[item] then CreateFruitESP(item) end
    end
    local tr = {}
    for item in pairs(State.FruitESPObjects) do

        if not af[item] or not item.Parent then table.insert(tr, item) end
    end
    for _, item in ipairs(tr) do
        local o = State.FruitESPObjects[item]
        if o.highlight and o.highlight.Parent then o.highlight:Destroy() end
        if o.billboard and o.billboard.Parent then o.billboard:Destroy() end
        State.FruitESPObjects[item] = nil
    end
    if cHRP then
        for _, e in pairs(State.FruitESPObjects) do
            if e.rootPart and e.rootPart.Parent then
                e.distLabel.Text = math.floor((cHRP.Position - e.rootPart.Position).Magnitude) .. " m"
            end
        end
    end
end)

local function GetNPCsForTP()
    local n={} local nf=Workspace:FindFirstChild("NPCs")
    if nf then for _,m in pairs(nf:GetChildren()) do if m:IsA("Model") then table.insert(n,m.Name) end end end
    if #n==0 then table.insert(n,"(None)") end return n
end

local function UpdateDropdown(ref,opts)
    if not ref then return end
    pcall(function() if ref.UpdateOptions then ref:UpdateOptions(opts) elseif ref.Refresh then ref:Refresh(opts) elseif ref.SetOptions then ref:SetOptions(opts) end end)
end

task.spawn(function()
    while true do task.wait(3)
        if not State.ServiceNPCTPDropdownRef then continue end
        local nn=GetNPCsForTP(); local changed=#nn~=#State.lastServiceNPCNames
        if not changed then local s={} for _,v in ipairs(State.lastServiceNPCNames) do s[v]=true end for _,v in ipairs(nn) do if not s[v] then changed=true;break end end end
        if changed then State.lastServiceNPCNames=nn;UpdateDropdown(State.ServiceNPCTPDropdownRef,nn) end
    end
end)

local function GetLocationPartNames()
    local n = {}
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if locs then
        for _, c in ipairs(locs:GetChildren()) do
            if c:IsA("BasePart") or c:IsA("Model") then
                table.insert(n, c.Name)
            end
        end
    end
    if #n == 0 then table.insert(n, "(None)") end
    return n
end

task.spawn(function()
    while true do task.wait(5)
        if not State.TweenToPlaceDropdownRef then continue end
        local nn = GetLocationPartNames()
        local changed = #nn ~= #State.lastLocationNames
        if not changed then
            local s = {}
            for _, v in ipairs(State.lastLocationNames) do s[v] = true end
            for _, v in ipairs(nn) do if not s[v] then changed = true; break end end
        end
        if changed then
            State.lastLocationNames = nn
            UpdateDropdown(State.TweenToPlaceDropdownRef, nn)
        end
    end
end)

local function RemoveAllPlayerESP()
    for _,obj in pairs(State.PlayerESPObjects) do pcall(function() if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end if obj.selBox and obj.selBox.Parent then obj.selBox:Destroy() end end) end
    State.PlayerESPObjects={}
end

local function RemoveAllESPLines()
    for _,obj in pairs(State.ESPLineObjects) do pcall(function() if obj.line and obj.line.Parent then obj.line:Destroy() end if obj.outline and obj.outline.Parent then obj.outline:Destroy() end end) end
    State.ESPLineObjects={}
end

local function EnsureESPLinesGui()
    if State.ESPLinesGui and State.ESPLinesGui.Parent then return end
    State.ESPLinesGui=Instance.new("ScreenGui");State.ESPLinesGui.ResetOnSpawn=false;State.ESPLinesGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;State.ESPLinesGui.DisplayOrder=998;State.ESPLinesGui.IgnoreGuiInset=true;State.ESPLinesGui.Parent=LocalPlayer.PlayerGui
end
local function CreateLine(parent,zIndex) local f=Instance.new("Frame");f.BorderSizePixel=0;f.AnchorPoint=Vector2.new(0.5,0.5);f.ZIndex=zIndex or 1;f.Parent=parent;return f end

local BAR_H = 35
local BAR_W = 10
local BAR_OUTER_W = 14
local BAR_OUTER_H = BAR_H + 4

local function MakeBar(bb, xPos, bgColor, fillColor)
    local outline=Instance.new("Frame");outline.Size=UDim2.new(0,BAR_OUTER_W,0,BAR_OUTER_H);outline.Position=UDim2.new(0,xPos,0,0);outline.BackgroundColor3=Color3.fromRGB(0,0,0);outline.BorderSizePixel=0;outline.Parent=bb
    local bg=Instance.new("Frame");bg.Size=UDim2.new(0,BAR_W,0,BAR_H);bg.Position=UDim2.new(0,2,0,2);bg.BackgroundColor3=bgColor;bg.BorderSizePixel=0;bg.Parent=outline
    local fill=Instance.new("Frame");fill.AnchorPoint=Vector2.new(0,1);fill.Size=UDim2.new(1,0,1,0);fill.Position=UDim2.new(0,0,1,0);fill.BackgroundColor3=fillColor;fill.BorderSizePixel=0;fill.Parent=bg
    return fill
end

local function CreatePlayerESP(player)
    if player==LocalPlayer then return end
    local cf=Workspace:FindFirstChild("Characters") if not cf then return end
    local model=cf:FindFirstChild(player.Name) if not model then return end
    if State.PlayerESPObjects[player] then return end
    local rp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart if not rp then return end

    local sb=Instance.new("SelectionBox");sb.Color3=Color3.fromRGB(255,60,60);sb.LineThickness=0.07;sb.SurfaceTransparency=0.88;sb.SurfaceColor3=Color3.fromRGB(255,60,60);sb.Adornee=model;sb.Parent=Workspace.CurrentCamera

    local bb=Instance.new("BillboardGui");bb.AlwaysOnTop=true;bb.Size=UDim2.new(0,180,0,80);bb.StudsOffset=Vector3.new(0,3,0);bb.Adornee=rp;bb.Parent=Workspace.CurrentCamera

    local hpFill=MakeBar(bb,0,Color3.fromRGB(30,10,10),Color3.fromRGB(100,255,100))
    local energyFill=MakeBar(bb,BAR_OUTER_W+2,Color3.fromRGB(10,10,30),Color3.fromRGB(80,160,255))

    local labelX=BAR_OUTER_W*2+6

    local nl=Instance.new("TextLabel");nl.Size=UDim2.new(1,-labelX,0,16);nl.Position=UDim2.new(0,labelX,0,0);nl.BackgroundTransparency=1;nl.TextColor3=Color3.fromRGB(200,170,255);nl.TextStrokeTransparency=0.35;nl.TextStrokeColor3=Color3.fromRGB(20,5,50);nl.Font=Enum.Font.GothamBold;nl.TextSize=12;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.Text=player.Name;nl.Parent=bb
    local dl=Instance.new("TextLabel");dl.Size=UDim2.new(1,-labelX,0,12);dl.Position=UDim2.new(0,labelX,0,17);dl.BackgroundTransparency=1;dl.TextColor3=Color3.fromRGB(255,220,100);dl.TextStrokeTransparency=0.35;dl.TextStrokeColor3=Color3.fromRGB(20,5,50);dl.Font=Enum.Font.GothamBold;dl.TextSize=11;dl.TextXAlignment=Enum.TextXAlignment.Left;dl.Text="0 m";dl.Parent=bb
    local bl=Instance.new("TextLabel");bl.Size=UDim2.new(1,-labelX,0,12);bl.Position=UDim2.new(0,labelX,0,30);bl.BackgroundTransparency=1;bl.TextColor3=Color3.fromRGB(200,170,255);bl.TextStrokeTransparency=0.35;bl.TextStrokeColor3=Color3.fromRGB(20,5,50);bl.Font=Enum.Font.GothamBold;bl.TextSize=11;bl.TextXAlignment=Enum.TextXAlignment.Left;bl.Text="";bl.Visible=false;bl.Parent=bb
    local sl=Instance.new("TextLabel");sl.Size=UDim2.new(1,-labelX,0,12);sl.Position=UDim2.new(0,labelX,0,43);sl.BackgroundTransparency=1;sl.TextColor3=Color3.fromRGB(255,200,50);sl.TextStrokeTransparency=0.35;sl.TextStrokeColor3=Color3.fromRGB(20,5,50);dl.Font=Enum.Font.GothamBold;sl.TextSize=11;sl.TextXAlignment=Enum.TextXAlignment.Left;sl.Text="";sl.Visible=false;sl.Parent=bb

    State.PlayerESPObjects[player]={model=model,billboard=bb,selBox=sb,rootPart=rp,hpFill=hpFill,energyFill=energyFill,distLabel=dl,nameLabel=nl,busoLabel=bl,stunLabel=sl}
end

local function RemovePlayerESP(player)
    local obj=State.PlayerESPObjects[player] if not obj then return end
    pcall(function() if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end if obj.selBox and obj.selBox.Parent then obj.selBox:Destroy() end end)
    State.PlayerESPObjects[player]=nil
end

RunService.Heartbeat:Connect(function()
    if not State.PlayerESPEnabled then return end
    local myChar=LocalPlayer.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart")
    local cf=Workspace:FindFirstChild("Characters") if not cf then return end
    for _,player in pairs(Players:GetPlayers()) do
        if player==LocalPlayer then continue end
        local model=cf:FindFirstChild(player.Name)
        if not model then RemovePlayerESP(player);continue end
        if not State.PlayerESPObjects[player] then CreatePlayerESP(player) end
        local obj=State.PlayerESPObjects[player] if not obj then continue end
        local nr=model:FindFirstChild("HumanoidRootPart")
        if nr and nr~=obj.rootPart then obj.rootPart=nr if obj.billboard then obj.billboard.Adornee=nr end if obj.selBox then obj.selBox.Adornee=model end end
        local hum=model:FindFirstChild("Humanoid")
        if hum and hum.MaxHealth>0 then
            local r=math.clamp(hum.Health/hum.MaxHealth,0,1)
            obj.hpFill.Size=UDim2.new(1,0,r,0)
            obj.hpFill.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-r)),math.floor(255*r),50)
        end
        local ev=model:FindFirstChild("Energy")
        if ev and ev:IsA("IntConstrainedValue") then
            local range=ev.MaxValue-ev.MinValue
            local er=range>0 and math.clamp((ev.Value-ev.MinValue)/range,0,1) or 0
            obj.energyFill.Size=UDim2.new(1,0,er,0)
        end
        local hasBuso=model:FindFirstChild("HasBuso")
        obj.busoLabel.Text=hasBuso and "BUSO" or ""; obj.busoLabel.Visible=hasBuso~=nil
        local isStun=false
        local sv=model:FindFirstChild("Stun")
        if sv and sv:IsA("NumberValue") and sv.Value~=0 then isStun=true end
        if not isStun then local hrpM=model:FindFirstChild("HumanoidRootPart") if hrpM then local so=hrpM:FindFirstChild("StunObjects") if so and #so:GetChildren()>0 then isStun=true end end end
        obj.stunLabel.Text=isStun and "STUN" or ""; obj.stunLabel.Visible=isStun
        if myHRP and obj.rootPart and obj.rootPart.Parent then obj.distLabel.Text=math.floor((myHRP.Position-obj.rootPart.Position).Magnitude).." m" end
    end
    local tr={}; for player in pairs(State.PlayerESPObjects) do if not Players:FindFirstChild(player.Name) then table.insert(tr,player) end end
    for _,p in ipairs(tr) do RemovePlayerESP(p) end
end)

RunService.Heartbeat:Connect(function()
    if not State.ESPLinesEnabled then if next(State.ESPLineObjects) then RemoveAllESPLines() end;return end
    EnsureESPLinesGui()
    local myChar=LocalPlayer.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart") if not myHRP then return end
    local cam=Workspace.CurrentCamera; local sb=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y)
    local cf=Workspace:FindFirstChild("Characters"); local cp=nil; local cd=math.huge
    for _,player in pairs(Players:GetPlayers()) do
        if player==LocalPlayer or not cf then continue end
        local m=cf:FindFirstChild(player.Name) if not m then continue end
        local rp=m:FindFirstChild("HumanoidRootPart") if not rp then continue end
        local d=(myHRP.Position-rp.Position).Magnitude if d<cd then cd=d;cp=player end
    end
    local ap={}
    for _,player in pairs(Players:GetPlayers()) do
        if player==LocalPlayer or not cf then continue end
        local m=cf:FindFirstChild(player.Name)
        if not m then if State.ESPLineObjects[player] then local o=State.ESPLineObjects[player] pcall(function() if o.outline and o.outline.Parent then o.outline:Destroy() end end) pcall(function() if o.line and o.line.Parent then o.line:Destroy() end end) State.ESPLineObjects[player]=nil end;continue end
        local rp=m:FindFirstChild("HumanoidRootPart") if not rp then continue end
        ap[player]=true
        if not State.ESPLineObjects[player] then State.ESPLineObjects[player]={line=CreateLine(State.ESPLinesGui,2),outline=CreateLine(State.ESPLinesGui,1)} end
        local obj=State.ESPLineObjects[player]; local ic=(player==cp)
        local lc=ic and Color3.fromRGB(255,50,50) or Color3.fromRGB(180,80,255)
        local lt=ic and 1.5 or 1; local ot=ic and 2 or 1.5
        local ts,tv=cam:WorldToViewportPoint(rp.Position)
        if not tv then obj.line.Visible=false;obj.outline.Visible=false;continue end
        local tp2=Vector2.new(ts.X,ts.Y); local dx=tp2.X-sb.X; local dy=tp2.Y-sb.Y
        local len=math.sqrt(dx*dx+dy*dy) if len<1 then obj.line.Visible=false;obj.outline.Visible=false;continue end
        local ang=math.deg(math.atan2(dy,dx)); local cx=(sb.X+tp2.X)/2; local cy=(sb.Y+tp2.Y)/2
        obj.outline.Size=UDim2.new(0,len+ot,0,lt+ot);obj.outline.Position=UDim2.new(0,cx,0,cy);obj.outline.Rotation=ang;obj.outline.BackgroundColor3=Color3.fromRGB(0,0,0);obj.outline.Visible=true
        obj.line.Size=UDim2.new(0,len,0,lt);obj.line.Position=UDim2.new(0,cx,0,cy);obj.line.Rotation=ang;obj.line.BackgroundColor3=lc;obj.line.Visible=true
    end
    local tr={}; for player in pairs(State.ESPLineObjects) do if not ap[player] then table.insert(tr,player) end end
    for _,p in ipairs(tr) do local o=State.ESPLineObjects[p] pcall(function() if o.outline and o.outline.Parent then o.outline:Destroy() end end) pcall(function() if o.line and o.line.Parent then o.line:Destroy() end end) State.ESPLineObjects[p]=nil end
end)

RunService.Heartbeat:Connect(function()
    if not State.SpectateEnabled or not State.SpectateTarget then return end
    local cf=Workspace:FindFirstChild("Characters") if not cf then return end
    local m=cf:FindFirstChild(State.SpectateTarget.Name) if not m then return end
    local th=m:FindFirstChild("HumanoidRootPart") if not th then return end
    local cam=Workspace.CurrentCamera; cam.CameraSubject=th; cam.CameraType=Enum.CameraType.Follow
end)

RunService.Heartbeat:Connect(function()
    if State.LockCameraEnabled then
        local myChar=LocalPlayer.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart") if not myHRP then return end
        local cf=Workspace:FindFirstChild("Characters") if not cf then return end
        local cp=nil; local cd=math.huge
        for _,player in pairs(Players:GetPlayers()) do
            if player==LocalPlayer then continue end
            local m=cf:FindFirstChild(player.Name) if not m then continue end
            local rp=m:FindFirstChild("HumanoidRootPart") if not rp then continue end
            local d=(myHRP.Position-rp.Position).Magnitude if d<cd then cd=d;cp=player end
        end
        if not cp then return end
        local tm=cf:FindFirstChild(cp.Name) if not tm then return end
        local th=tm:FindFirstChild("HumanoidRootPart") if not th then return end
        local cam=Workspace.CurrentCamera; cam.CameraType=Enum.CameraType.Scriptable
        local cp2=myHRP.Position+Vector3.new(0,5,0)+(myHRP.Position-th.Position).Unit*15
        cam.CFrame=CFrame.new(cp2,th.Position)
    elseif State.LockCameraSelectedPlayerEnabled and State.LockCameraSelectedPlayerTarget and State.LockCameraSelectedPlayerTarget ~= "(No players)" then
        local targetPlayer = Players:FindFirstChild(State.LockCameraSelectedPlayerTarget)
        if not targetPlayer then return end
        local myChar=LocalPlayer.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart") if not myHRP then return end
        local cf=Workspace:FindFirstChild("Characters") if not cf then return end
        local tm=cf:FindFirstChild(targetPlayer.Name) if not tm then return end
        local th=tm:FindFirstChild("HumanoidRootPart") if not th then return end
        local cam=Workspace.CurrentCamera; cam.CameraType=Enum.CameraType.Scriptable
        local cp2=myHRP.Position+Vector3.new(0,5,0)+(myHRP.Position-th.Position).Unit*15
        cam.CFrame=CFrame.new(cp2,th.Position)
    end
end)

RunService.Heartbeat:Connect(function()
    if not State.AimlockClosestPlayerEnabled and not State.AimbotSelectedPlayerEnabled then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cf = Workspace:FindFirstChild("Characters")
    if not cf then return end

    local targetPlayer = nil
    if State.AimlockClosestPlayerEnabled then
        local cd = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local pm = cf:FindFirstChild(player.Name)
            local prp = pm and pm:FindFirstChild("HumanoidRootPart")
            if prp then
                local d = (hrp.Position - prp.Position).Magnitude
                if d < cd then cd = d; targetPlayer = player end
            end
        end
    elseif State.AimbotSelectedPlayerEnabled and State.AimlockSelectedPlayerTarget and State.AimlockSelectedPlayerTarget ~= "(No players)" then
        targetPlayer = Players:FindFirstChild(State.AimlockSelectedPlayerTarget)
    end

    if targetPlayer then
        local pm = cf:FindFirstChild(targetPlayer.Name)
        local prp = pm and pm:FindFirstChild("HumanoidRootPart")
        if prp then
            hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(prp.Position.X, hrp.Position.Y, prp.Position.Z))
        end
    end

end)

task.spawn(function()
    while true do task.wait(3)
        if not State.AimlockSelectedDropdownRef then continue end
        local nn = GetOnlinePlayerNames(); local ns = {}; for _, n in ipairs(nn) do ns[n] = true end
        local changed = false
        for n in pairs(ns) do if not State.lastAimlockPlayerSet[n] then changed = true; break end end
        if not changed then for n in pairs(State.lastAimlockPlayerSet) do if not ns[n] then changed = true; break end end end
        if changed then
            State.lastAimlockPlayerSet = ns; UpdateDropdown(State.AimlockSelectedDropdownRef, nn)
            if State.AimlockSelectedPlayerTarget and not ns[State.AimlockSelectedPlayerTarget] then
                State.AimlockSelectedPlayerTarget = nil
            end
        end
    end
end)

task.spawn(function()
    while true do task.wait(3)

        if not State.LockCameraSelectedDropdownRef then continue end
        local nn=GetOnlinePlayerNames(); local ns={}; for _,n in ipairs(nn) do ns[n]=true end
        local changed=false
        for n in pairs(ns) do if not State.lastLockCameraPlayerSet[n] then changed=true;break end end
        if not changed then for n in pairs(State.lastLockCameraPlayerSet) do if not ns[n] then changed=true;break end end end
        if changed then
            State.lastLockCameraPlayerSet=ns; UpdateDropdown(State.LockCameraSelectedDropdownRef,nn)
            if State.LockCameraSelectedPlayerTarget and not ns[State.LockCameraSelectedPlayerTarget] then
                State.LockCameraSelectedPlayerTarget=nil
            end
        end
    end
end)

local function GetOnlinePlayerNames()
    local n={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(n,p.Name) end end
    if #n==0 then table.insert(n,"(No players)") end return n
end

local function StopOrbit() State.OrbitEnabled=false if State.OrbitConnection then State.OrbitConnection:Disconnect();State.OrbitConnection=nil end end

local function StartOrbit(targetPlayer)

    StopOrbit()
    if not targetPlayer then return end
    State.OrbitTarget = targetPlayer
    State.OrbitEnabled = true
    State.OrbitAngle = 0

    State.OrbitConnection = RunService.Heartbeat:Connect(function(dt)
        if not State.OrbitEnabled then return end
        local charsFolder = Workspace:FindFirstChild("Characters")
        if not charsFolder then return end
        local m = charsFolder:FindFirstChild(State.OrbitTarget.Name)
        if not m then return end
        local th = m:FindFirstChild("HumanoidRootPart")
        if not th then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        if not State.TPBehindOrbitEnabled then
            State.OrbitAngle = State.OrbitAngle + State.OrbitSpeed * dt
        end

        local orbitTargetPos
        if State.TPBehindOrbitEnabled then
            local bp = th.CFrame.Position + (-th.CFrame.LookVector) * State.OrbitDistance
            orbitTargetPos = Vector3.new(bp.X, th.Position.Y, bp.Z)
        else
            orbitTargetPos = Vector3.new(
                th.Position.X + math.cos(State.OrbitAngle) * State.OrbitDistance,
                th.Position.Y,
                th.Position.Z + math.sin(State.OrbitAngle) * State.OrbitDistance
            )
        end

        local dist = (myHRP.Position - orbitTargetPos).Magnitude
        local isUnderRespawn = (tick() - State.LastRespawnTick) <= 3

        for _, p in ipairs(myChar:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end

        end

        pcall(function()
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
        end)

        local newPos

        if dist >= State.TWEEN_THRESHOLD or isUnderRespawn then
            local step = math.min(State.TWEEN_SPEED * dt, dist)
            if dist > 0.001 then
                newPos = myHRP.Position + (orbitTargetPos - myHRP.Position).Unit * step
            else
                newPos = orbitTargetPos
            end
        else
            newPos = orbitTargetPos
        end

        myHRP.CFrame = CFrame.lookAt(newPos, th.Position, Vector3.new(0, 1, 0))
    end)
end

task.spawn(function()
    while true do task.wait(3)
        if not State.SpectateDropdownRef then continue end
        local nn=GetOnlinePlayerNames(); local ns={}; for _,n in ipairs(nn) do ns[n]=true end
        local changed=false
        for n in pairs(ns) do if not State.lastSpectatePlayerSet[n] then changed=true;break end end
        if not changed then for n in pairs(State.lastSpectatePlayerSet) do if not ns[n] then changed=true;break end end end
        if changed then

            State.lastSpectatePlayerSet=ns; UpdateDropdown(State.SpectateDropdownRef,nn)
            if State.SpectateTarget and not ns[State.SpectateTarget.Name] then
                State.SpectateEnabled=false;State.SpectateTarget=nil
                pcall(function() local cam=Workspace.CurrentCamera local mc=LocalPlayer.Character local mh=mc and mc:FindFirstChild("Humanoid") if mh then cam.CameraSubject=mh end;cam.CameraType=Enum.CameraType.Custom end)
            end
        end
    end
end)

task.spawn(function()
    while true do task.wait(3)
        if not State.OrbitDropdownRef then continue end
        local nn=GetOnlinePlayerNames(); local ns={}; for _,n in ipairs(nn) do ns[n]=true end
        local changed=false
        for n in pairs(ns) do if not State.lastOrbitPlayerSet[n] then changed=true;break end end
        if not changed then for n in pairs(State.lastOrbitPlayerSet) do if not ns[n] then changed=true;break end end end
        if changed then State.lastOrbitPlayerSet=ns;UpdateDropdown(State.OrbitDropdownRef,nn) if State.OrbitTarget and not ns[State.OrbitTarget.Name] then StopOrbit();State.OrbitTarget=nil end end

    end
end)

local function EnableNoClip()
    if State.NoClipConnection then return end
    State.NoClipConnection=RunService.Stepped:Connect(function() local c=LocalPlayer.Character if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end)

end
local function DisableNoClip()
    if State.NoClipConnection then State.NoClipConnection:Disconnect();State.NoClipConnection=nil end
    local c=LocalPlayer.Character if c then for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
end

local function DisableFly()
    if State.FlyConnection then State.FlyConnection:Disconnect(); State.FlyConnection = nil end
    if State.FlyBodyVelocity then State.FlyBodyVelocity:Destroy(); State.FlyBodyVelocity = nil end
    if State.FlyBodyGyro then State.FlyBodyGyro:Destroy(); State.FlyBodyGyro = nil end
    if State.FlyWeld then State.FlyWeld:Destroy(); State.FlyWeld = nil end
    if State.FlyPart then State.FlyPart:Destroy(); State.FlyPart = nil end
end

local function EnableFly()
    DisableFly()
    State.FlyConnection = RunService.RenderStepped:Connect(function()
        if not State.FlyEnabled then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then
            if State.FlyPart then
                if State.FlyBodyVelocity then State.FlyBodyVelocity:Destroy(); State.FlyBodyVelocity = nil end
                if State.FlyBodyGyro then State.FlyBodyGyro:Destroy(); State.FlyBodyGyro = nil end
                if State.FlyWeld then State.FlyWeld:Destroy(); State.FlyWeld = nil end
                if State.FlyPart then State.FlyPart:Destroy(); State.FlyPart = nil end
            end
            return
        end

        if not State.FlyPart or not State.FlyPart.Parent or State.FlyPart.Parent ~= c or not State.FlyWeld or not State.FlyWeld.Parent or not State.FlyBodyVelocity or not State.FlyBodyGyro then
            if State.FlyBodyVelocity then State.FlyBodyVelocity:Destroy() end
            if State.FlyBodyGyro then State.FlyBodyGyro:Destroy() end
            if State.FlyWeld then State.FlyWeld:Destroy() end
            if State.FlyPart then State.FlyPart:Destroy() end

            State.FlyPart = Instance.new("Part")
            State.FlyPart.Size = Vector3.new(1, 1, 1)
            State.FlyPart.Transparency = 1
            State.FlyPart.CanCollide = false
            State.FlyPart.Massless = true
            State.FlyPart.CFrame = hrp.CFrame
            State.FlyPart.Parent = c

            State.FlyWeld = Instance.new("WeldConstraint")
            State.FlyWeld.Part0 = hrp
            State.FlyWeld.Part1 = State.FlyPart
            State.FlyWeld.Parent = State.FlyPart

            State.FlyBodyVelocity = Instance.new("BodyVelocity")
            State.FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            State.FlyBodyVelocity.Velocity = Vector3.zero
            State.FlyBodyVelocity.Parent = State.FlyPart

            State.FlyBodyGyro = Instance.new("BodyGyro")
            State.FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            State.FlyBodyGyro.P = 90000
            State.FlyBodyGyro.CFrame = hrp.CFrame
            State.FlyBodyGyro.Parent = State.FlyPart
        end

        local cam = Workspace.CurrentCamera
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
            dir = dir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
            dir = dir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
            dir = dir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
            dir = dir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
            dir = dir - Vector3.new(0, 1, 0)
        end

        local md = hum.MoveDirection

        if md.Magnitude > 0 and dir.Magnitude == 0 then
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector

            local lookFlat = Vector3.new(look.X, 0, look.Z)
            local rightFlat = Vector3.new(right.X, 0, right.Z)
            if lookFlat.Magnitude > 0 then lookFlat = lookFlat.Unit end
            if rightFlat.Magnitude > 0 then rightFlat = rightFlat.Unit end
            dir = dir + (look * md:Dot(lookFlat) + right * md:Dot(rightFlat))
        end

        if dir.Magnitude > 0 then
            State.FlyBodyVelocity.Velocity = dir.Unit * State.FlySpeed
        else
            State.FlyBodyVelocity.Velocity = Vector3.zero
        end
        State.FlyBodyGyro.CFrame = cam.CFrame
    end)
end

local function EnableWalkSpeed()
    if State.WalkSpeedConnection then State.WalkSpeedConnection:Disconnect() end
    State.WalkSpeedConnection=RunService.Heartbeat:Connect(function()
        if not State.WalkSpeedEnabled then return end
        local c=LocalPlayer.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local hum=c:FindFirstChild("Humanoid") if not hum or hum.Health<=0 then return end
        local md=hum.MoveDirection if md.Magnitude<0.1 then return end
        local cf=hrp.CFrame; local np=cf.Position+md.Unit*State.WalkSpeedSmoothing
        hrp.CFrame=CFrame.fromMatrix(np,cf.RightVector,cf.UpVector,-cf.LookVector)
    end)
end
local function DisableWalkSpeed() if State.WalkSpeedConnection then State.WalkSpeedConnection:Disconnect();State.WalkSpeedConnection=nil end end

local function EnableLaggyRun()
    if State.LaggyRunConnection then State.LaggyRunConnection:Disconnect() end
    State.LaggyRunAccum=0
    State.LaggyRunConnection=RunService.Heartbeat:Connect(function(dt)
        if not State.LaggyRunEnabled then return end
        local c=LocalPlayer.Character if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local hum=c:FindFirstChild("Humanoid") if not hum or hum.Health<=0 then return end
        local md=hum.MoveDirection if md.Magnitude<0.1 then State.LaggyRunAccum=0;return end
        State.LaggyRunAccum=State.LaggyRunAccum+dt
        if State.LaggyRunAccum<State.LaggyRunDelay*0.1 then return end
        State.LaggyRunAccum=0
        local cf=hrp.CFrame; local np=cf.Position+md.Unit*State.LaggyRunDistance
        hrp.CFrame=CFrame.fromMatrix(np,cf.RightVector,cf.UpVector,-cf.LookVector)
    end)
end
local function DisableLaggyRun() if State.LaggyRunConnection then State.LaggyRunConnection:Disconnect();State.LaggyRunConnection=nil end State.LaggyRunAccum=0 end

local function EnableCtrlClickTP()
    if State.CtrlClickTPConnection then return end
    State.CtrlClickTPConnection=UserInputService.InputBegan:Connect(function(input,gp)
        if not State.CtrlClickTPEnabled or gp then return end
        if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then return end
        local c=LocalPlayer.Character local hrp=c and c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local cam=Workspace.CurrentCamera; local mp=UserInputService:GetMouseLocation(); local ray=cam:ViewportPointToRay(mp.X,mp.Y)
        local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Exclude;rp.FilterDescendantsInstances={c}
        local res=Workspace:Raycast(ray.Origin,ray.Direction*5000,rp)

        if res then hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0))*(hrp.CFrame-hrp.CFrame.Position) end
    end)
end
local function DisableCtrlClickTP() if State.CtrlClickTPConnection then State.CtrlClickTPConnection:Disconnect();State.CtrlClickTPConnection=nil end end

local function CancelPlaceTween()
    State.activePlaceTweenActive=false
    State.currentTweenModelName=nil
    if State.placeTweenConnection then
        State.placeTweenConnection:Disconnect()
        State.placeTweenConnection=nil
    end
end

local function TweenToLocationPart(partName)
    CancelPlaceTween()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if not locs then return end
    local target = locs:FindFirstChild(partName)
    if not target then return end

    local targetCF = nil
    if target:IsA("BasePart") then
        targetCF = target.CFrame
    elseif target:IsA("Model") then
        local ok, piv = pcall(function() return target:GetPivot() end)
        if ok and piv then targetCF = piv end
    end
    if not targetCF then return end

    local targetPos = targetCF.Position + Vector3.new(0, 150, 0)
    local targetCF150 = CFrame.new(targetPos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    State.currentTweenModelName = partName
    State.activePlaceTweenActive = true

    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end

    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= 1 then
        if hum then hum.PlatformStand = false end
        State.activePlaceTweenActive = false
        State.currentTweenModelName = nil
        hrp.CFrame = targetCF150
        return
    end

    State.placeTweenConnection = RunService.Heartbeat:Connect(function(dt)
        if not State.activePlaceTweenActive then
            if State.placeTweenConnection then State.placeTweenConnection:Disconnect(); State.placeTweenConnection = nil end
            return
        end
        local c = LocalPlayer.Character
        local h = c and c:FindFirstChild("HumanoidRootPart")
        local hu = c and c:FindFirstChild("Humanoid")
        if not h then CancelPlaceTween(); return end
        if hu then hu.PlatformStand = true end
        local d = (h.Position - targetPos).Magnitude
        if d <= 1 then
            h.CFrame = targetCF150
            CancelPlaceTween()
            if hu then hu.PlatformStand = false end
            return
        end
        StepMoveTowards(h, hu, targetPos, dt)
    end)
end

local function StartAutoStats()
    if State.autoStatsConnection then State.autoStatsConnection:Disconnect();State.autoStatsConnection=nil end

    State.autoStatsIndex=1; local SE=ReplicatedStorage.Remotes.CommF_; local lt=tick()

    State.autoStatsConnection=RunService.Heartbeat:Connect(function()
        if not State.AutoStatsEnabled then State.autoStatsConnection:Disconnect();State.autoStatsConnection=nil end
        if tick()-lt<0.2 then return end; lt=tick()
        local sl={}; for n in pairs(State.SelectedStats) do table.insert(sl,n) end
        if #sl==0 then return end; table.sort(sl)
        if State.autoStatsIndex>#sl then State.autoStatsIndex=1 end
        pcall(function() SE:InvokeServer("AddPoint",sl[State.autoStatsIndex],State.StatPointValue) end)
        State.autoStatsIndex=State.autoStatsIndex+1; if State.autoStatsIndex>#sl then State.autoStatsIndex=1 end
    end)
end
local function StopAutoStats() if State.autoStatsConnection then State.autoStatsConnection:Disconnect();State.autoStatsConnection=nil end end

local function GetChestParts()
    local r={}; local mf=Workspace:FindFirstChild("Map") if not mf then return r end
    for _,mm in ipairs(mf:GetChildren()) do
        if not mm:IsA("Model") then continue end
        for _,sm in ipairs(mm:GetChildren()) do
            if not sm:IsA("Model") or (sm.Name~="Chests" and sm.Name~="Detail") then continue end
            for _,part in ipairs(sm:GetDescendants()) do
                if part:IsA("BasePart") and string.find(part.Name,"Chest") then
                    local ti=part:FindFirstChild("TouchInterest") if ti then table.insert(r,{part=part,ti=ti}) end
                end
            end
        end
    end
    return r
end

local function StartAutoCollectChest()
    local touchConn=nil; local moveConn=nil; local visited={} local visitedP={}
    local function StopMove() if moveConn then moveConn:Disconnect();moveConn=nil end end

    touchConn=RunService.Heartbeat:Connect(function()
        if not State.AutoCollectChestEnabled then touchConn:Disconnect();StopMove();local c=LocalPlayer.Character local h=c and c:FindFirstChild("Humanoid") if h then h.PlatformStand=false end;return end
        local c=LocalPlayer.Character local hrp=c and c:FindFirstChild("HumanoidRootPart") if not hrp then return end
        local mf=Workspace:FindFirstChild("Map") if not mf then return end
        for _,mm in ipairs(mf:GetChildren()) do
            if not mm:IsA("Model") then continue end
            for _,sm in ipairs(mm:GetChildren()) do
                if not sm:IsA("Model") or (sm.Name~="Chests" and sm.Name~="Detail") then continue end
                for _,part in ipairs(sm:GetDescendants()) do
                    if not part:IsA("BasePart") or not string.find(part.Name,"Chest") then continue end
                    local ti=part:FindFirstChild("TouchInterest") if not ti then continue end
                    pcall(function() firetouchinterest(hrp,part,0);firetouchinterest(hrp,part,1) end)
                end
            end
        end
    end)

    local function MoveToPosition(tp, enabledCheck)
        local c = LocalPlayer.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChild("Humanoid")
        if not hrp or not hum then return end

        StopMove()

        hum.PlatformStand = true

        local dist = (hrp.Position - tp).Magnitude
        if dist <= 1 then return end

        local done = false

        moveConn = RunService.Heartbeat:Connect(function(dt)
            if not enabledCheck() then StopMove(); done = true; return end
            local cc = LocalPlayer.Character
            local h = cc and cc:FindFirstChild("HumanoidRootPart")
            local hu = cc and cc:FindFirstChild("Humanoid")
            if not h or not hu then StopMove(); done = true; return end

            local d = (h.Position - tp).Magnitude
            if d <= 1 then
                h.CFrame = CFrame.new(tp)
                StopMove(); done = true; return
            end

            StepMoveTowards(h, hu, tp, dt)
        end)

        while not done and enabledCheck() do task.wait() end
        StopMove()
    end

    task.spawn(function()
        while State.AutoCollectChestEnabled do
            local c=LocalPlayer.Character local hrp=c and c:FindFirstChild("HumanoidRootPart") local hum=c and c:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health<=0 then task.wait(0.1);continue end

            local cm=Workspace:FindFirstChild("ChestModels"); local ml=cm and cm:GetChildren() or {}; local vm={}
            for _,m in ipairs(ml) do if m:IsA("Model") and not visited[m] then table.insert(vm,m) end end

            if #vm>0 then
                table.sort(vm,function(a,b)
                    local ao,ap2=pcall(function() return a:GetPivot() end)
                    local bo,bp2=pcall(function() return b:GetPivot() end)
                    if not ao or not ap2 then return false end
                    if not bo or not bp2 then return true end
                    return (hrp.Position-ap2.Position).Magnitude<(hrp.Position-bp2.Position).Magnitude
                end)
                local m=vm[1]; visited[m]=true
                local ok,piv=pcall(function() return m:GetPivot() end)
                if ok and piv then
                    local tp = piv.Position + Vector3.new(0, 3, 0)
                    MoveToPosition(tp, function() return State.AutoCollectChestEnabled end)
                end
                task.wait(0.1); continue
            end

            local cl=GetChestParts(); local vp={}
            for _,e in ipairs(cl) do if not visitedP[e.part] then table.insert(vp,e) end end

            if #vp==0 then visited={};visitedP={};task.wait(1);continue end

            table.sort(vp,function(a,b) return (hrp.Position-a.part.Position).Magnitude<(hrp.Position-b.part.Position).Magnitude end)

            local entry=vp[1]; local part=entry.part; visitedP[part]=true
            if not part or not part.Parent or not part:FindFirstChild("TouchInterest") then task.wait(0.1);continue end

            local tp = part.Position + Vector3.new(0, 3, 0)
            MoveToPosition(tp, function() return State.AutoCollectChestEnabled end)
            task.wait(0.1)
        end

        StopMove()
        local c=LocalPlayer.Character local h=c and c:FindFirstChild("Humanoid") if h then h.PlatformStand=false end
    end)
end

local function StopAutoCollectChest() State.AutoCollectChestEnabled=false end

local function PerformStartRaid()
    if not State.SelectedRaidType then return end
    local isPlace100 = (game.PlaceId == 100117331123089 or tostring(game.PlaceId) == "100117331123089")

    if isPlace100 and State.AutoGoLabToStartEnabled then
        local boatCastle = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Boat Castle")
        if not boatCastle then
            local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
            local castlePart = locs and (locs:FindFirstChild("Castle on the Sea") or locs:FindFirstChild("Castle On The Sea"))
            if not castlePart then
                castlePart = Workspace:FindFirstChild("Map") and (Workspace.Map:FindFirstChild("Castle on the Sea") or Workspace.Map:FindFirstChild("Castle On The Sea"))
            end
            if castlePart then

                local char = LocalPlayer.Character

                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                if hrp and hum then
                    local targetPos = castlePart.Position
                    local targetCF = castlePart.CFrame
                    hum.PlatformStand = true
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                    local conn
                    local foundCastle = false
                    conn = RunService.Heartbeat:Connect(function(dt)
                        local c = LocalPlayer.Character
                        local h = c and c:FindFirstChild("HumanoidRootPart")
                        local hu = c and c:FindFirstChild("Humanoid")
                        if not h or not hu or not State.AutoStartRaidEnabled or not State.AutoGoLabToStartEnabled then
                            if conn then conn:Disconnect() end
                            return
                        end
                        local bc = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Boat Castle")
                        if bc then
                            foundCastle = true
                            if conn then conn:Disconnect() end
                            return
                        end
                        local d = (h.Position - targetPos).Magnitude
                        if d <= 1 then

                            h.CFrame = targetCF
                            if conn then conn:Disconnect() end
                            return
                        end
                        StepMoveTowards(h, hu, targetPos, dt)
                    end)
                    while conn and conn.Connected and not foundCastle and State.AutoStartRaidEnabled and State.AutoGoLabToStartEnabled do
                        task.wait(0.05)
                    end
                    if conn then conn:Disconnect() end
                    if hum then hum.PlatformStand = false end
                    local bc = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Boat Castle")
                    if not bc then
                        return
                    end
                end
            end
        end
    end

    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc","Select",State.SelectedRaidType)
    end)
    task.wait(1)
    if isPlace100 then
        local boatCastle = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Boat Castle")
        if boatCastle then
            for _, obj in ipairs(boatCastle:GetChildren()) do
                if obj.Name == "RaidSummon2" or string.find(obj.Name, "RaidSummon2") then
                    local btn = obj:FindFirstChild("Button")

                    local main = btn and btn:FindFirstChild("Main")
                    local cd = main and main:FindFirstChild("ClickDetector")

                    if cd then pcall(function() fireclickdetector(cd) end) end
                end
            end
        end
    else
        local ci = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("CircleIsland")
        if ci then
            for _, obj in ipairs(ci:GetChildren()) do

                if obj.Name == "RaidSummon2" then
                    local btn = obj:FindFirstChild("Button")
                    local main = btn and btn:FindFirstChild("Main")
                    local cd = main and main:FindFirstChild("ClickDetector")
                    if cd then pcall(function() fireclickdetector(cd) end) end
                end
            end
        end
    end
end

local function HasAnyOwnedBoat()
    local bf = Workspace:FindFirstChild("Boats")
    if not bf then return false end
    local char = LocalPlayer.Character
    for _, b in ipairs(bf:GetChildren()) do
        if b:IsA("Model") then
            local ov = b:FindFirstChild("Owner")
            if ov and (ov.Value == LocalPlayer or ov.Value == char or tostring(ov.Value) == LocalPlayer.Name or (ov:IsA("StringValue") and ov.Value == LocalPlayer.Name)) then
                return true
            end
        end
    end
    return false
end

local function TryBuyBoat()
    if (tick() - State.LastBoatBuyTick) < 8 then return end
    if HasAnyOwnedBoat() then return end
    State.LastBoatBuyTick = tick()
    State.IsBuyingBoat = true
    local boatToBuy = State.SelectedBoatToBuy or "Guardian"
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", boatToBuy)
    end)
    task.wait(1.5)
    if not HasAnyOwnedBoat() then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum then
            local fallbackPos = Vector3.new(-333.4233093261719, 20.673694610595703, 5505.423828125)
            local dist = (hrp.Position - fallbackPos).Magnitude
            if dist > 1 then
                local conn
                local reached = false
                hum.PlatformStand = true
                pcall(function()
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end)
                conn = RunService.Heartbeat:Connect(function(dt)
                    local c = LocalPlayer.Character
                    local h = c and c:FindFirstChild("HumanoidRootPart")
                    local hu = c and c:FindFirstChild("Humanoid")
                    if not h or not hu then
                        if conn then conn:Disconnect() end
                        reached = true
                        return
                    end
                    local d = (h.Position - fallbackPos).Magnitude
                    if d <= 1 then
                        h.CFrame = CFrame.new(fallbackPos)
                        if conn then conn:Disconnect() end
                        reached = true
                        return
                    end
                    StepMoveTowards(h, hu, fallbackPos, dt)
                end)
                while not reached and (State.AutoBuyBoatEnabled or State.AutoFindSeaEventEnabled or State.AutoFindMirageIslandEnabled or State.AutoFindPrehistoricIslandEnabled or State.AutoFindShipwreckIslandEnabled or State.AutoFindKitsuneIslandEnabled) do task.wait(0.05) end
                if conn then conn:Disconnect() end
                if hum then hum.PlatformStand = false end
            end
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", boatToBuy)
            end)
        end
    end
    State.IsBuyingBoat = false
end

local function GetPlayerBoat()
    local bf = Workspace:FindFirstChild("Boats")
    if not bf then return nil, nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local candidates = {}
    for _, boat in ipairs(bf:GetChildren()) do
        if boat:IsA("Model") then
            local ov = boat:FindFirstChild("Owner")
            if ov and (ov.Value == LocalPlayer or ov.Value == char or tostring(ov.Value) == LocalPlayer.Name or (ov:IsA("StringValue") and ov.Value == LocalPlayer.Name)) then
                local vs = boat:FindFirstChild("VehicleSeat") or boat:FindFirstChildWhichIsA("VehicleSeat") or boat:FindFirstChild("Seat")
                if vs then
                    local dist = hrp and (hrp.Position - vs.Position).Magnitude or 0
                    table.insert(candidates, { boat = boat, seat = vs, dist = dist })
                end
            end
        end
    end
    if #candidates == 0 then return nil, nil end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    return candidates[1].boat, candidates[1].seat
end

local function IsPlayerSittingInSeat(seat)
    if not seat then return false end
    local weld = seat:FindFirstChild("SeatWeld")
    if weld and weld:IsA("Weld") then return true end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum and hum.Sit then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and (hrp.Position - seat.Position).Magnitude < 8 then
            return true
        end
    end
    return false
end

local function DismountBoatSeat()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if hum.Sit then

        hum.Sit = false
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end

    local bf = Workspace:FindFirstChild("Boats")
    if bf then
        for _, b in ipairs(bf:GetChildren()) do
            if b:IsA("Model") then
                local vs = b:FindFirstChild("VehicleSeat") or b:FindFirstChildWhichIsA("VehicleSeat") or b:FindFirstChild("Seat")
                if vs then
                    local weld = vs:FindFirstChild("SeatWeld")
                    if weld and (weld.Part1 == hrp or weld.Part0 == hrp or (weld.Part1 and weld.Part1.Parent == char)) then
                        pcall(function() weld:Destroy() end)
                    end
                end
            end
        end
    end

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("Weld") or p:IsA("WeldConstraint") or p:IsA("Snap") then
            if (p.Part0 and p.Part0:IsDescendantOf(Workspace:FindFirstChild("Boats") or Workspace) and not p.Part0:IsDescendantOf(char)) or (p.Part1 and p.Part1:IsDescendantOf(Workspace:FindFirstChild("Boats") or Workspace) and not p.Part1:IsDescendantOf(char)) then
                pcall(function() p:Destroy() end)
            end
        end
    end
end

local function MoveBoatTowards(boat, seat, targetX, targetZ, dt)
    local curPos = seat.Position
    local flatCurPos = Vector3.new(curPos.X, 0, curPos.Z)
    local flatTargetPos = Vector3.new(targetX, 0, targetZ)
    local flatDist = (flatTargetPos - flatCurPos).Magnitude

    local step = math.min(State.TWEEN_SPEED * dt, flatDist)
    local newFlatPos
    if flatDist > 0.001 then
        newFlatPos = flatCurPos + (flatTargetPos - flatCurPos).Unit * step
    else
        newFlatPos = flatTargetPos
    end

    local finalY = curPos.Y
    local newPos = Vector3.new(newFlatPos.X, finalY, newFlatPos.Z)
    local lookTarget = Vector3.new(targetX, finalY, targetZ)
    local targetCF
    if (lookTarget - newPos).Magnitude > 0.01 then
        targetCF = CFrame.lookAt(newPos, lookTarget, Vector3.new(0, 1, 0))
    else
        targetCF = CFrame.new(newPos)
    end

    local deltaCF = targetCF * seat.CFrame:Inverse()
    boat:PivotTo(deltaCF * boat:GetPivot())
    return flatDist
end

task.spawn(function()
    while true do
        task.wait(2)
        if State.AutoBuyBoatEnabled and not HasAnyOwnedBoat() then
            TryBuyBoat()
        end
    end
end)

local function GetSharkTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local ef = Workspace:FindFirstChild("Enemies")
    local res = {}
    if not ef then return res end
    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") and m.Name == "Shark" then
            local h = m:FindFirstChild("Humanoid")
            local mh = m:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and mh then
                table.insert(res, m)
            end
        end
    end
    table.sort(res, function(a, b)
        local ah = a:FindFirstChild("HumanoidRootPart")
        local bh = b:FindFirstChild("HumanoidRootPart")
        if not ah then return false end
        if not bh then return true end
        if not hrp then return false end
        return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
    end)
    return res
end

local function GetTerrorsharkTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local ef = Workspace:FindFirstChild("Enemies")
    local res = {}
    if not ef then return res end
    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") and (m.Name == "Terrorshark" or string.find(m.Name, "Terrorshark")) then
            local h = m:FindFirstChild("Humanoid")
            local mh = m:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and mh then
                table.insert(res, m)
            end
        end
    end
    table.sort(res, function(a, b)
        local ah = a:FindFirstChild("HumanoidRootPart")
        local bh = b:FindFirstChild("HumanoidRootPart")
        if not ah then return false end
        if not bh then return true end
        if not hrp then return false end
        return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
    end)
    return res
end

local function GetPiranhaTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local ef = Workspace:FindFirstChild("Enemies")
    local res = {}
    if not ef then return res end
    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") and (m.Name == "Piranha" or string.find(m.Name, "Piranha")) then
            local h = m:FindFirstChild("Humanoid")
            local mh = m:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and mh then
                table.insert(res, m)
            end
        end
    end
    table.sort(res, function(a, b)
        local ah = a:FindFirstChild("HumanoidRootPart")
        local bh = b:FindFirstChild("HumanoidRootPart")
        if not ah then return false end
        if not bh then return true end
        if not hrp then return false end
        return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
    end)
    return res
end

local function GetBrigadeTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local res = {}
    local ef = Workspace:FindFirstChild("Enemies")
    if not ef then return res end
    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") and (m.Name == "PirateBrigade" or m.Name == "PirateGrandBrigade") then
            local eng = m:FindFirstChild("Engine")
            local hpVal = m:FindFirstChild("Health")
            local isAlive = false
            if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) then
                isAlive = hpVal.Value > 0
            else

                local hum = m:FindFirstChild("Humanoid")
                isAlive = hum and hum.Health > 0 or true
            end
            if eng and isAlive then
                table.insert(res, m)
            end
        end
    end
    table.sort(res, function(a, b)
        local ae = a:FindFirstChild("Engine")
        local be = b:FindFirstChild("Engine")
        if not ae then return false end
        if not be then return true end
        if not hrp then return false end
        return (hrp.Position - ae.Position).Magnitude < (hrp.Position - be.Position).Magnitude
    end)
    return res
end

local function IsSeaBeastAlive(target)
    if not target or not target.Parent then return false end
    local hpVal = target:FindFirstChild("Health") or target:FindFirstChild("Health", true)
    if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) then
        return hpVal.Value > 0
    end
    local hum = target:FindFirstChild("Humanoid") or target:FindFirstChild("Humanoid", true)
    if hum then return hum.Health > 0 end
    return true
end

local function GetSeaBeastTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local res = {}
    local sf = Workspace:FindFirstChild("SeaBeasts")
    if not sf then return res end
    for _, m in ipairs(sf:GetChildren()) do
        if m:IsA("Model") then
            local mh = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("HumanoidRootPart", true) or m:FindFirstChildWhichIsA("BasePart")
            if mh and IsSeaBeastAlive(m) then
                table.insert(res, m)
            end
        end
    end
    table.sort(res, function(a, b)
        local ah = a:FindFirstChild("HumanoidRootPart") or a:FindFirstChild("HumanoidRootPart", true) or a:FindFirstChildWhichIsA("BasePart")
        local bh = b:FindFirstChild("HumanoidRootPart") or b:FindFirstChild("HumanoidRootPart", true) or b:FindFirstChildWhichIsA("BasePart")
        if not ah then return false end
        if not bh then return true end
        if not hrp then return false end
        return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
    end)
    return res
end

local function GetFishBoatTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local res = {}
    local folders = { Workspace:FindFirstChild("Enemies"), Workspace:FindFirstChild("Boats"), Workspace }
    for _, folder in ipairs(folders) do
        if folder then
            for _, m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") and (m.Name == "FishBoat" or string.find(m.Name, "FishBoat")) then
                    local targetPart = m:FindFirstChild("Engine") or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    local hpVal = m:FindFirstChild("Health")
                    local isAlive = false
                    if hpVal and (hpVal:IsA("IntValue") or hpVal:IsA("NumberValue") or hpVal:IsA("ValueBase")) then
                        isAlive = hpVal.Value > 0
                    else
                        local hum = m:FindFirstChild("Humanoid")
                        isAlive = (hum and hum.Health > 0) or true
                    end
                    if targetPart and isAlive then
                        table.insert(res, m)
                    end
                end
            end
        end
    end
    table.sort(res, function(a, b)
        local ap = a:FindFirstChild("Engine") or a:FindFirstChild("HumanoidRootPart") or a:FindFirstChildWhichIsA("BasePart")
        local bp = b:FindFirstChild("Engine") or b:FindFirstChild("HumanoidRootPart") or b:FindFirstChildWhichIsA("BasePart")
        if not ap then return false end
        if not bp then return true end
        if not hrp then return false end
        return (hrp.Position - ap.Position).Magnitude < (hrp.Position - bp.Position).Magnitude
    end)
    return res
end

local function GetFishCrewMemberTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local res = {}
    local ef = Workspace:FindFirstChild("Enemies")
    if not ef then return res end

    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") and (m.Name == "Fish Crew Member" or string.find(m.Name, "Fish Crew Member") or m.Name == "FishCrewMember") then
            local h = m:FindFirstChild("Humanoid")
            local mh = m:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and mh then
                table.insert(res, m)
            end
        end
    end
    table.sort(res, function(a, b)
        local ah = a:FindFirstChild("HumanoidRootPart")
        local bh = b:FindFirstChild("HumanoidRootPart")
        if not ah then return false end
        if not bh then return true end
        if not hrp then return false end
        return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
    end)
    return res
end

local BoatOriginalCanCollide = {}

local function EnableNoclipBoat()
    if State.NoclipBoatConnection then State.NoclipBoatConnection:Disconnect() end
    State.NoclipBoatConnection = RunService.Stepped:Connect(function()
        if not State.NoclipBoatEnabled then return end
        local boat, _ = GetPlayerBoat()
        if boat then
            for _, p in ipairs(boat:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end
    end)
end

local function DisableNoclipBoat()
    if State.NoclipBoatConnection then

        State.NoclipBoatConnection:Disconnect()

        State.NoclipBoatConnection = nil
    end
    local boat, _ = GetPlayerBoat()
    if boat then
        for _, p in ipairs(boat:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
    end
end

local function IsAutoKillTargetEnabled(name)
    if not State.AutoKillEnabled then
        if name == "Shark" and State.AutoKillSharkEnabled then return true end
        if name == "Terrorshark" and State.AutoKillTerrorsharkEnabled then return true end
        if name == "Piranha" and State.AutoKillPiranhaEnabled then return true end
        if name == "Brigades" and State.AutoKillBrigadesEnabled then return true end
        if name == "Sea Beast" and State.AutoKillSeaBeastEnabled then return true end
        if name == "Fish Boat" and State.AutoKillFishBoatEnabled then return true end
        if name == "Fish Crew Member" and State.AutoKillFishCrewMemberEnabled then return true end
        return false
    end
    local hasSel = false
    for _ in pairs(State.SelectedAutoKillTargets) do
        hasSel = true
        break
    end
    if not hasSel then return true end
    return State.SelectedAutoKillTargets[name] == true
end

local function GetMirageIslandPart()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if not locs then return nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local parts = {}
    for _, child in ipairs(locs:GetChildren()) do
        if child.Name == "Mirage Island" or string.find(child.Name, "Mirage Island") or child.Name == "MÄ±rage Island" then
            table.insert(parts, child)
        end
    end
    if #parts == 0 then return nil end

    if not hrp then return parts[1] end
    table.sort(parts, function(a, b)
        local ap = a:IsA("BasePart") and a.Position or (a:IsA("Model") and a:GetPivot().Position or Vector3.zero)
        local bp = b:IsA("BasePart") and b.Position or (b:IsA("Model") and b:GetPivot().Position or Vector3.zero)
        return (hrp.Position - ap).Magnitude < (hrp.Position - bp).Magnitude
    end)
    return parts[1]
end

local function GetPrehistoricIslandPart()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if not locs then return nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local parts = {}
    for _, child in ipairs(locs:GetChildren()) do
        if (child.Name == "Prehistoric Island" or string.find(child.Name, "Prehistoric Island")) then
            table.insert(parts, child)
        end
    end
    if #parts == 0 then return nil end
    if not hrp then return parts[1] end
    table.sort(parts, function(a, b)
        local ap = a:IsA("BasePart") and a.Position or (a:IsA("Model") and a:GetPivot().Position or Vector3.zero)
        local bp = b:IsA("BasePart") and b.Position or (b:IsA("Model") and b:GetPivot().Position or Vector3.zero)
        return (hrp.Position - ap).Magnitude < (hrp.Position - bp).Magnitude
    end)
    return parts[1]
end

local function GetShipwreckIslandPart()
    local origin = Workspace:FindFirstChild("_WorldOrigin")
    local locs = origin and origin:FindFirstChild("Locations")
    if not locs then return nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local parts = {}
    for _, child in ipairs(locs:GetChildren()) do
        if (child.Name == "Haunted Shipwreck" or string.find(child.Name, "Haunted Shipwreck")) then
            table.insert(parts, child)

        end
    end
    if #parts == 0 then return nil end
    if not hrp then return parts[1] end
    table.sort(parts, function(a, b)
        local ap = a:IsA("BasePart") and a.Position or (a:IsA("Model") and a:GetPivot().Position or Vector3.zero)
        local bp = b:IsA("BasePart") and b.Position or (b:IsA("Model") and b:GetPivot().Position or Vector3.zero)
        return (hrp.Position - ap).Magnitude < (hrp.Position - bp).Magnitude
    end)
    return parts[1]
end

local function GetKitsuneIslandPart()
    local origin = Workspace:FindFirstChild("_WorldOrigin")

    local locs = origin and origin:FindFirstChild("Locations")
    if not locs then return nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local parts = {}
    for _, child in ipairs(locs:GetChildren()) do

        if (child.Name == "Kitsune Island" or string.find(child.Name, "Kitsune Island")) then
            table.insert(parts, child)
        end
    end
    if #parts == 0 then return nil end
    if not hrp then return parts[1] end
    table.sort(parts, function(a, b)
        local ap = a:IsA("BasePart") and a.Position or (a:IsA("Model") and a:GetPivot().Position or Vector3.zero)
        local bp = b:IsA("BasePart") and b.Position or (b:IsA("Model") and b:GetPivot().Position or Vector3.zero)
        return (hrp.Position - ap).Magnitude < (hrp.Position - bp).Magnitude
    end)
    return parts[1]
end

local isIslandPatrolRunning = false

local function StartIslandPatrolLoop()
    if isIslandPatrolRunning then return end
    isIslandPatrolRunning = true
    task.spawn(function()
        local hb
        hb = RunService.Heartbeat:Connect(function(dt)
            if not State.AutoFindMirageIslandEnabled and not State.AutoFindPrehistoricIslandEnabled and not State.AutoFindShipwreckIslandEnabled and not State.AutoFindKitsuneIslandEnabled then
                hb:Disconnect()
                isIslandPatrolRunning = false
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChild("Humanoid")
                if h then h.PlatformStand = false end
                return

            end

            if State.IsBuyingBoat then return end

            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or hum.Health <= 0 or not hrp then return end

            local targetIsland, islandType = nil, nil
            if State.AutoFindMirageIslandEnabled then
                local mPart = GetMirageIslandPart()
                if mPart then targetIsland, islandType = mPart, "Mirage" end

            end
            if not targetIsland and State.AutoFindPrehistoricIslandEnabled then
                local pPart = GetPrehistoricIslandPart()
                if pPart then targetIsland, islandType = pPart, "Prehistoric" end
            end
            if not targetIsland and State.AutoFindShipwreckIslandEnabled then
                local sPart = GetShipwreckIslandPart()
                if sPart then targetIsland, islandType = sPart, "Shipwreck" end
            end
            if not targetIsland and State.AutoFindKitsuneIslandEnabled then
                local kPart = GetKitsuneIslandPart()
                if kPart then targetIsland, islandType = kPart, "Kitsune" end
            end

            if targetIsland then
                if hum.Sit or IsPlayerDrivingBoat() then
                    DismountBoatSeat()
                end
                local rawPos = targetIsland:IsA("BasePart") and targetIsland.Position or (targetIsland:IsA("Model") and targetIsland:GetPivot().Position or Vector3.zero)
                local targetPos = rawPos + Vector3.new(0, 300, 0)
                local targetCF = CFrame.new(targetPos)
                local dist = (hrp.Position - targetPos).Magnitude
                if dist <= 3 then
                    hrp.CFrame = targetCF
                    hum.PlatformStand = false
                else
                    hum.PlatformStand = true
                    StepMoveTowards(hrp, hum, targetPos, dt)
                end
                return
            end

            local boat, seat = GetPlayerBoat()
            if not boat or not seat then
                if State.AutoBuyBoatEnabled then
                    TryBuyBoat()
                end
                return
            end

            if not IsPlayerSittingInSeat(seat) then
                local seatPos = seat.Position + Vector3.new(0, 2, 0)
                local dist = (hrp.Position - seatPos).Magnitude
                if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                    StepMoveTowards(hrp, hum, seatPos, dt)
                else
                    hrp.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0)
                end
                return
            end

            local waypoints = ZoneCFrames["Zone 6 ???"]
            local wp = waypoints[State.MirageWaypointIndex]
            if not wp then
                State.MirageWaypointIndex = 1
                wp = waypoints[1]
            end

            local flatDist = MoveBoatTowards(boat, seat, wp.X, wp.Z, dt)

            if flatDist < 15 then
                if State.MirageWaypointDirection == 1 then
                    if State.MirageWaypointIndex >= #waypoints then
                        State.MirageWaypointDirection = -1
                        State.MirageWaypointIndex = #waypoints - 1
                    else
                        State.MirageWaypointIndex = State.MirageWaypointIndex + 1
                    end
                else
                    if State.MirageWaypointIndex <= 1 then
                        State.MirageWaypointDirection = 1
                        State.MirageWaypointIndex = 2
                    else
                        State.MirageWaypointIndex = State.MirageWaypointIndex - 1
                    end
                end
            end
        end)
    end)
end

local function GetHauntedCrewMemberTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local ef = Workspace:FindFirstChild("Enemies")
    local res = {}
    if not ef then return res end
    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") and m.Name == "Haunted Crew Member" then
            local h = m:FindFirstChild("Humanoid")
            local mh = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            if h and h.Health > 0 and mh then
                table.insert(res, m)
            end
        end
    end
    if hrp and #res > 1 then
        table.sort(res, function(a, b)
            local ah = a:FindFirstChild("HumanoidRootPart") or a.PrimaryPart
            local bh = b:FindFirstChild("HumanoidRootPart") or b.PrimaryPart
            return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
        end)
    end
    return res
end

local function KillHauntedCrewMemberLoop()
    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not IsAutoKillTargetEnabled("Haunted Crew Member") then
            hb:Disconnect()
            return
        end
        local char = LocalPlayer.Character if not char then return end
        local hum = char:FindFirstChild("Humanoid") local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not hrp then return end
        local targets = GetHauntedCrewMemberTargets()
        if #targets > 0 then
            local target = targets[1]
            if hum.Sit or IsPlayerDrivingBoat() then DismountBoatSeat() end
            hum.PlatformStand = true
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            local cf = GetMobTopPosition(target, State.SeaEventDistanceBetweenNPC or 5)
            if cf then
                local mobDist = (hrp.Position - cf.Position).Magnitude
                if mobDist < 0.5 then
                    hrp.CFrame = cf
                else
                    hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                end
            end
            FireHitRemotes({target})
        end
    end)
end

local function GetActiveZoneTarget()
    local selected = State.SelectedSeaEventZone
    if not selected or selected == "" or selected == "Zone 6 ???" then
        local waypoints = ZoneCFrames["Zone 6 ???"]
        local wp = waypoints[State.SeaEventWaypointIndex]
        if not wp then
            State.SeaEventWaypointIndex = 1
            wp = waypoints[1]
        end
        return wp, true, waypoints
    end
    local targetPos = ZoneCFrames[selected]
    if not targetPos then
        targetPos = ZoneCFrames["Zone 6 ???"][1]

    end    return targetPos, false, nil
end

local function StopBoatAndPlayerMovement()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end

    if hrp then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    local boat, seat = GetPlayerBoat()
    if seat then
        pcall(function()
            seat.AssemblyLinearVelocity = Vector3.zero
            seat.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    if boat then
        for _, p in ipairs(boat:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function()
                    p.AssemblyLinearVelocity = Vector3.zero
                    p.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        end
    end
end

local function SeaEventPatrolLoop()
    local hadBoat = false
    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFindSeaEventEnabled or State.IsBuyingBoat then
            if not State.AutoFindSeaEventEnabled then
                hb:Disconnect()
                StopBoatAndPlayerMovement()
            end
            return
        end

        local hasActiveTargets = false
        if IsAutoKillTargetEnabled("Shark") and #GetSharkTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Terrorshark") and #GetTerrorsharkTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Piranha") and #GetPiranhaTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Brigades") and #GetBrigadeTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Sea Beast") and #GetSeaBeastTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Fish Boat") and #GetFishBoatTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Fish Crew Member") and #GetFishCrewMemberTargets() > 0 then hasActiveTargets = true end
        if IsAutoKillTargetEnabled("Haunted Crew Member") and #GetHauntedCrewMemberTargets() > 0 then hasActiveTargets = true end

        if hasActiveTargets then
            DismountBoatSeat()
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not hrp then return end

        local boat, seat = GetPlayerBoat()
        if not boat or not seat then
            if hadBoat and State.ResetIfBoatSinks and not State.HasResetForBoatSink then
                State.HasResetForBoatSink = true
                pcall(function() char:BreakJoints() end)
            end
            if State.AutoBuyBoatEnabled then
                TryBuyBoat()
            end
            return
        end

        hadBoat = true
        State.HasResetForBoatSink = false

        if not IsPlayerSittingInSeat(seat) then
            local seatPos = seat.Position + Vector3.new(0, 2, 0)
            local dist = (hrp.Position - seatPos).Magnitude
            if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                StepMoveTowards(hrp, hum, seatPos, dt)
            else
                hrp.CFrame = seat.CFrame + Vector3.new(0, 1.5, 0)
            end
            return
        end

        local targetPos, isPatrol, waypoints = GetActiveZoneTarget()
        local flatDist = MoveBoatTowards(boat, seat, targetPos.X, targetPos.Z, dt)

        if isPatrol and waypoints and flatDist < 15 then
            if State.SeaEventWaypointDirection == 1 then
                if State.SeaEventWaypointIndex >= #waypoints then
                    State.SeaEventWaypointDirection = -1

                    State.SeaEventWaypointIndex = #waypoints - 1
                else
                    State.SeaEventWaypointIndex = State.SeaEventWaypointIndex + 1
                end
            else
                if State.SeaEventWaypointIndex <= 1 then
                    State.SeaEventWaypointDirection = 1
                    State.SeaEventWaypointIndex = 2
                else
                    State.SeaEventWaypointIndex = State.SeaEventWaypointIndex - 1
                end
            end
        end
    end)

    while State.AutoFindSeaEventEnabled do task.wait(0.1) end
    hb:Disconnect()
    StopBoatAndPlayerMovement()
end

local function ProcessSeaEventAutoKillTarget(targetName, getTargetsFn, bringNPCs, checkReadyFn)
    if not IsAutoKillTargetEnabled(targetName) then return end
    local char = LocalPlayer.Character if not char then return end
    local hum = char:FindFirstChild("Humanoid") local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end
    local targets = getTargetsFn()
    if #targets > 0 then

        local target = targets[1]
        local isValid = checkReadyFn and checkReadyFn(target) or true
        if isValid then
            if hum.Sit or IsPlayerDrivingBoat() then DismountBoatSeat() end
            hum.PlatformStand = true
            pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end)
            local cf, thr = GetMobTopPosition(target, State.SeaEventDistanceBetweenNPC)
            if cf then
                local mobDist = (hrp.Position - cf.Position).Magnitude
                if mobDist < 0.5 then
                    hrp.CFrame = cf
                else
                    hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                end
                if bringNPCs and thr and State.SeaEventBringNPCsEnabled and mobDist <= 3 then DoBringNPCs(target, thr, false, nil, true) end
            end
            FireHitRemotes({target})
        end
    end
end

task.spawn(function()
    RunService.Heartbeat:Connect(function(dt)
        ProcessSeaEventAutoKillTarget("Shark", GetSharkTargets, true, IsTargetReady)
        ProcessSeaEventAutoKillTarget("Terrorshark", GetTerrorsharkTargets, true, IsTargetReady)

        ProcessSeaEventAutoKillTarget("Piranha", GetPiranhaTargets, true, IsTargetReady)
        ProcessSeaEventAutoKillTarget("Brigades", GetBrigadeTargets, false, function(t)
            local hpVal = t:FindFirstChild("Health") or t:FindFirstChild("Health", true)
            return (hpVal and hpVal:IsA("ValueBase") and hpVal.Value > 0) or (t:FindFirstChild("Humanoid") and t.Humanoid.Health > 0) or true
        end)
        ProcessSeaEventAutoKillTarget("Sea Beast", GetSeaBeastTargets, false, IsSeaBeastAlive)
        ProcessSeaEventAutoKillTarget("Fish Boat", GetFishBoatTargets, false, function(t)
            local hpVal = t:FindFirstChild("Health") or t:FindFirstChild("Health", true)
            return (hpVal and hpVal:IsA("ValueBase") and hpVal.Value > 0) or (t:FindFirstChild("Humanoid") and t.Humanoid.Health > 0) or true
        end)
        ProcessSeaEventAutoKillTarget("Fish Crew Member", GetFishCrewMemberTargets, true, IsTargetReady)
    end)
end)

local function GetMagnetTargetsInWorkspace()
    local ef = Workspace:FindFirstChild("Enemies")
    local res = {}
    if not ef then return res end
    for _, m in ipairs(ef:GetChildren()) do
        if m:IsA("Model") then
            local proxy = m:FindFirstChild("MagnetModeProxy")
            if proxy and proxy:IsA("StringValue") then
                local h = m:FindFirstChild("Humanoid")
                local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                if h and h.Health > 0 and hrp then
                    table.insert(res, m)
                end
            end
        end
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and #res > 1 then
        table.sort(res, function(a, b)
            local ah = a:FindFirstChild("HumanoidRootPart") or a.PrimaryPart
            local bh = b:FindFirstChild("HumanoidRootPart") or b.PrimaryPart
            if not ah then return false end
            if not bh then return true end
            return (hrp.Position - ah.Position).Magnitude < (hrp.Position - bh.Position).Magnitude
        end)
    end
    return res
end

local function GetMagnetTargetsInReplicatedStorage()
    local rsEnemies = ReplicatedStorage:FindFirstChild("Enemies") or ReplicatedStorage
    local res = {}
    for _, m in ipairs(rsEnemies:GetChildren()) do
        if m:IsA("Model") then
            local proxy = m:FindFirstChild("MagnetModeProxy")
            if proxy and proxy:IsA("StringValue") then
                table.insert(res, m)
            end
        end
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and #res > 1 then
        table.sort(res, function(a, b)
            local ap = a:IsA("Model") and a:GetPivot().Position or Vector3.zero
            local bp = b:IsA("Model") and b:GetPivot().Position or Vector3.zero
            return (hrp.Position - ap).Magnitude < (hrp.Position - bp).Magnitude
        end)
    end
    return res
end

local isMagnetFarmRunning = false

local function FarmMagnetNPCsLoop()
    if isMagnetFarmRunning then return end
    isMagnetFarmRunning = true

    local hb
    hb = RunService.Heartbeat:Connect(function(dt)
        if not State.AutoFarmMagnetNPCsEnabled then
            hb:Disconnect()
            isMagnetFarmRunning = false
            UnanchorAll()
            local c = LocalPlayer.Character
            local h = c and c:FindFirstChild("Humanoid")
            if h then h.PlatformStand = false end
            return
        end

        local char = LocalPlayer.Character if not char then return end

        local hum = char:FindFirstChild("Humanoid") local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not hrp then return end

        CleanAnchoredTargets()

        local wsTargets = GetMagnetTargetsInWorkspace()
        if #wsTargets > 0 then
            local target = wsTargets[1]
            local tmh = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
            if tmh then
                local targetPos = tmh.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                local dist = (hrp.Position - targetPos).Magnitude

                if dist >= State.TWEEN_THRESHOLD or (tick() - State.LastRespawnTick) <= 3 then
                    StepMoveTowards(hrp, hum, targetPos, dt)
                    return
                else
                    AnchorTarget(target)
                    hum.PlatformStand = true
                    pcall(function()
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                    end)
                    local cf, thr = GetMobTopPosition(target)
                    local targetsToHit = { target }
                    if cf then
                        local mobDist = (hrp.Position - cf.Position).Magnitude
                        if mobDist < 0.5 then
                            hrp.CFrame = cf
                        else
                            hrp.CFrame = hrp.CFrame:Lerp(cf, math.clamp((State.TWEEN_SPEED / 16) * 0.15, 0.05, 1))
                        end
                        if thr then
                            if State.BringNPCsEnabled and mobDist <= 5 then
                                targetsToHit = DoBringNPCs(target, thr)
                            end
                        end
                    end
                    FireHitRemotes(targetsToHit)
                    return
                end
            end
            return
        else
            local rsTargets = GetMagnetTargetsInReplicatedStorage()
            if #rsTargets > 0 then
                local rsTarget = rsTargets[1]
                local pivot = rsTarget:IsA("Model") and rsTarget:GetPivot() or nil
                if pivot then
                    local targetPos = pivot.Position + Vector3.new(0, State.DistanceBetweenNPC, 0)
                    StepMoveTowards(hrp, hum, targetPos, dt)
                end
            else
                hum.PlatformStand = false
            end
        end
    end)
end

local function InitUI()
    local Window=Library:CreateWindow({Title=" Symbiote ",Size=UDim2.new(0,580,0,440)})
    local PlayerTab=Window:CreateTab("Player")
    local AutoFarmTab=Window:CreateTab("Auto Farm")
    local VariousTab=Window:CreateTab("Various")
    local RaidsTab=Window:CreateTab("Raids")
    local SeaEventTab=Window:CreateTab("Sea Event")
    local PVPTab=Window:CreateTab("PVP")

    PlayerTab:AddLabel("MOVEMENT")
    PlayerTab:AddToggle("Fly",function(state) State.FlyEnabled=state if state then EnableFly() else DisableFly() end end)
    PlayerTab:AddSlider("Fly Speed",50,500,50,function(v) State.FlySpeed=v end)
    PlayerTab:AddToggle("NoClip",function(state) State.NoClipEnabled=state if state then EnableNoClip() else DisableNoClip() end end)
    PlayerTab:AddToggle("Infinite Jump",function(state)
        State.InfiniteJumpEnabled=state
        if state then
            if State.InfiniteJumpConnection then State.InfiniteJumpConnection:Disconnect() end
            State.InfiniteJumpConnection=UserInputService.JumpRequest:Connect(function()
                if not State.InfiniteJumpEnabled then return end
                local c=LocalPlayer.Character local h=c and c:FindFirstChild("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else if State.InfiniteJumpConnection then State.InfiniteJumpConnection:Disconnect();State.InfiniteJumpConnection=nil end end
    end)
    PlayerTab:AddToggle("CTRL + Click to TP",function(state) State.CtrlClickTPEnabled=state if state then EnableCtrlClickTP() else DisableCtrlClickTP() end end)

    PlayerTab:AddSeparator()
    PlayerTab:AddLabel("SPEED")
    PlayerTab:AddToggle("Walk Speed",function(state) State.WalkSpeedEnabled=state if state then EnableWalkSpeed() else DisableWalkSpeed() end end)
    PlayerTab:AddSlider("Walk Speed Amount",1,100,1,function(v) State.WalkSpeedSmoothing=v*(1/20) end)
    PlayerTab:AddToggle("Laggy Run",function(state) State.LaggyRunEnabled=state if state then EnableLaggyRun() else DisableLaggyRun() end end)
    PlayerTab:AddSlider("Laggy Run Distance",1,10,1,function(v) State.LaggyRunDistance=v end)
    PlayerTab:AddSlider("Laggy Run Delay",1,10,1,function(v) State.LaggyRunDelay=v end)

    PlayerTab:AddSeparator()
    PlayerTab:AddLabel("MISC")
    PlayerTab:AddToggle("Kill Aura",function(state) State.KillAuraEnabled=state end)
    PlayerTab:AddToggle("Infinite Stamina",function(state) State.InfiniteStaminaEnabled=state if state then EnableInfiniteStamina() else DisableInfiniteStamina() end end)
    PlayerTab:AddToggle("Auto Haki",function(state) State.AutoHakiEnabled=state end)
    PlayerTab:AddToggle("Auto Instinct",function(state) State.AutoInstinctEnabled=state end)
    PlayerTab:AddToggle("Water Walking",function(state) State.WaterWalkingEnabled=state UpdateWaterWalking() end)
    PlayerTab:AddToggle("Anti AFK",function(state) State.AntiAFKEnabled=state if state then EnableAntiAFK() else DisableAntiAFK() end end)

    AutoFarmTab:AddLabel("SETTINGS")
    do
        local farmEquipSelecting=false; local farmEquipDropdownRef
        farmEquipDropdownRef=AutoFarmTab:AddDropdown("Auto Equip Weapon",{"Melee","Sword","Blox Fruit"},function(selected)
            if farmEquipSelecting then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.AutoEquipWeaponFarm=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.AutoEquipWeaponFarm then chosen=k;break end end farmEquipSelecting=true;farmEquipDropdownRef:ClearSelection();farmEquipSelecting=false end
            State.AutoEquipWeaponFarm=chosen

        end)
    end
    AutoFarmTab:AddSlider("Distance To NPC (studs)",5,50,5,function(v) State.DistanceBetweenNPC=v end)
    AutoFarmTab:AddToggle("Bring NPCs",function(state) State.BringNPCsEnabled=state end)

    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("NPC FARM")
    AutoFarmTab:AddToggle("Auto Farm",function(state) if state then State.AutoFarmEnabled=true;task.spawn(FarmNormalLoop) else State.AutoFarmEnabled=false end end)
    AutoFarmTab:AddToggle("Auto Farm Nearby NPCs",function(state) if state then State.AutoFarmNearbyNPCsEnabled=true;task.spawn(FarmNearbyNPCsLoop) else State.AutoFarmNearbyNPCsEnabled=false end end)
    local npcOptions={}; for _,n in ipairs(NPCNames) do table.insert(npcOptions,n) end
    AutoFarmTab:AddDropdown("Select NPC",npcOptions,function(selected) State.SelectedNPCs={} for n in pairs(selected) do State.SelectedNPCs[n]=true end end)

    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("BOSS FARM")
    AutoFarmTab:AddToggle("Auto Farm Boss",function(state) if state then State.AutoFarmBossEnabled=true;task.spawn(FarmBossLoop) else State.AutoFarmBossEnabled=false end end)
    AutoFarmTab:AddToggle("Auto Farm Nearby Bosses",function(state) if state then State.AutoFarmNearbyBossesEnabled=true;task.spawn(FarmNearbyBossesLoop) else State.AutoFarmNearbyBossesEnabled=false end end)
    local bossOptions={}; for _,b in ipairs(BossNames) do table.insert(bossOptions,b) end
    AutoFarmTab:AddDropdown("Select Boss",bossOptions,function(selected) State.SelectedBosses={} for n in pairs(selected) do State.SelectedBosses[n]=true end end)

    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("LEVEL FARM")
    AutoFarmTab:AddToggle("Auto Farm Level",function(state) if state then State.AutoFarmLevelEnabled=true;task.spawn(FarmLevelLoop) else State.AutoFarmLevelEnabled=false end end)

    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("ELITE")
    AutoFarmTab:AddToggle("Auto Get Elite Hunter Quest",function(state)
        State.AutoGetEliteHunterQuestEnabled=state
        if state then
            task.spawn(function()
                while State.AutoGetEliteHunterQuestEnabled do
                    pcall(function()
                        local pg=LocalPlayer:FindFirstChild("PlayerGui")
                        local main=pg and pg:FindFirstChild("Main")
                        local q=main and main:FindFirstChild("Quest")
                        if q and q.Visible==false then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter")
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)
    AutoFarmTab:AddToggle("Auto Kill Elite Hunter",function(state)
        State.AutoKillEliteHunterEnabled=state
        if state then
            task.spawn(FarmEliteHunterLoop)
        end
    end)

    AutoFarmTab:AddSeparator()
    AutoFarmTab:AddLabel("MAGNET")
    AutoFarmTab:AddToggle("Auto Farm Magnet NPCs", function(state)
        if state then
            State.AutoFarmMagnetNPCsEnabled = true
            task.spawn(FarmMagnetNPCsLoop)
        else
            State.AutoFarmMagnetNPCsEnabled = false
        end
    end)

    VariousTab:AddLabel("ESP")
    VariousTab:AddToggle("Service NPC ESP",function(state) State.ServiceNPCESPEnabled=state if not state then RemoveAllESP() end end)
    VariousTab:AddToggle("Fruit ESP",function(state) State.FruitESPEnabled=state if not state then RemoveAllFruitESP() end end)

    VariousTab:AddSeparator()
    VariousTab:AddLabel("TELEPORT")
    do
        local initNPCNames=GetNPCsForTP(); State.lastServiceNPCNames=initNPCNames; local tpSel=false
        State.ServiceNPCTPDropdownRef=VariousTab:AddDropdown("Teleport To NPC",initNPCNames,function(selected)
            if tpSel then return end
            for n in pairs(selected) do
                if n=="(None)" then break end
                local mc=LocalPlayer.Character local mh=mc and mc:FindFirstChild("HumanoidRootPart") if not mh then break end
                local nf=Workspace:FindFirstChild("NPCs") if not nf then break end
                local m=nf:FindFirstChild(n)
                if m and m:IsA("Model") then local rp=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart") if rp then mh.CFrame=CFrame.new(rp.Position+Vector3.new(0,5,0)) end end
                break
            end
            tpSel=true; task.defer(function() pcall(function() State.ServiceNPCTPDropdownRef:ClearSelection() end);tpSel=false end)
        end)
    end

    do
        local initLocNames = GetLocationPartNames()

        State.lastLocationNames = initLocNames
        local tpSel = false
        State.TweenToPlaceDropdownRef = VariousTab:AddDropdown("Tween To Place", initLocNames, function(selected)
            if tpSel then return end
            for n in pairs(selected) do
                if n ~= "(None)" then
                    TweenToLocationPart(n)
                end
                break
            end
            tpSel = true
            task.defer(function()
                pcall(function() State.TweenToPlaceDropdownRef:ClearSelection() end)
                tpSel = false
            end)
        end)
    end

    VariousTab:AddSeparator()
    VariousTab:AddLabel("TP")
    VariousTab:AddButton("TP To Sea 1", function()
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("TravelMain")
        end)
    end)
    VariousTab:AddButton("TP To Sea 2", function()
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("TravelDressrosa")
        end)
    end)
    VariousTab:AddButton("TP To Sea 3", function()
        pcall(function()

            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("TravelZou")
        end)
    end)

    VariousTab:AddSeparator()
    VariousTab:AddLabel("QUEST & STATS & CHEST")
    do
        local qSel=false; local qRef
        qRef=VariousTab:AddDropdown("Auto Quest",AutoQuestOrder,function(selected)
            if qSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.SelectedAutoQuest=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.SelectedAutoQuest then chosen=k;break end end qSel=true;qRef:ClearSelection();qSel=false end
            State.SelectedAutoQuest=chosen
        end)
    end
    do
        VariousTab:AddDropdown("Auto Stats",{"Melee","Defense","Sword","Gun","Blox Fruit"},function(selected) State.SelectedStats={} for n in pairs(selected) do State.SelectedStats[n]=true end end)
        VariousTab:AddSlider("Stat Point",1,50,1,function(v) State.StatPointValue=v end)
        VariousTab:AddToggle("Auto Stats",function(state) State.AutoStatsEnabled=state if state then StartAutoStats() else StopAutoStats() end end)
    end
    VariousTab:AddToggle("Auto Collect Chest",function(state) State.AutoCollectChestEnabled=state if state then StartAutoCollectChest() else StopAutoCollectChest() end end)

    VariousTab:AddSeparator()
    VariousTab:AddLabel("FRUIT")
    VariousTab:AddToggle("Auto Buddha Transform",function(state) State.AutoBuddhaTransformEnabled=state end)
    local function StartFruitAutoSkillLoop()
        while State.FruitAutoSkillEnabled do
            task.wait(0.1)
            if State.IsTweening then continue end
            local char = LocalPlayer.Character if not char then continue end
            local hum = char:FindFirstChild("Humanoid") if not hum or hum.Health <= 0 then continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and (tool.ToolTip == "Blox Fruit" or string.find(tool.Name, "Fruit")) then
                for skillKey in pairs(State.SelectedFruitSkills) do
                    if not State.FruitAutoSkillEnabled or State.IsTweening then break end
                    pcall(function()

                        local key = Enum.KeyCode[skillKey]

                        if key then
                            VirtualInputManager:SendKeyEvent(true, key, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, key, false, game)
                        end
                    end)
                end
            end
        end
    end
    VariousTab:AddToggle("Auto Skill",function(state)

        State.FruitAutoSkillEnabled=state
        if state then task.spawn(StartFruitAutoSkillLoop) end
    end)
    VariousTab:AddDropdown("Select Fruit Skill To Auto",{"Z","X","C","V","F"},function(selected) State.SelectedFruitSkills={} for s in pairs(selected) do State.SelectedFruitSkills[s]=true end end)
    VariousTab:AddToggle("Auto Store Fruit", function(state)
        State.AutoStoreFruitEnabled = state
        if state then
            task.spawn(function()
                local function GetNil(Name, DebugId)
                    if getnilinstances then
                        for _, Object in ipairs(getnilinstances()) do
                            if Object.Name == Name and Object:GetDebugId() == DebugId then
                                return Object
                            end
                        end
                    end
                    return nil
                end

                while State.AutoStoreFruitEnabled do
                    local stored = false
                    pcall(function()
                        local bp = LocalPlayer:FindFirstChild("Backpack")
                        if bp then
                            for _, tool in ipairs(bp:GetChildren()) do
                                if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then
                                    local origName = tool:GetAttribute("OriginalName") or tool.Name
                                    local debugId = pcall(function() return tool:GetDebugId() end) and tool:GetDebugId() or ""
                                    local nilObj = GetNil(tool.Name, debugId) or tool
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", origName, nilObj)
                                    stored = true
                                    break
                                end
                            end
                        end
                    end)
                    if stored then
                        task.wait(5)
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end)

    VariousTab:AddToggle("Auto Roll Fruit",function(state)
        State.AutoRollFruitEnabled=state

        if state then
            task.spawn(function()
                while State.AutoRollFruitEnabled do
                    pcall(function()
                        local event = ReplicatedStorage.Modules.Net["RF/GachaNetworkRF"]
                        event:InvokeServer({
                            Context = "Purchase",
                            BoxName = "ZiolesGacha"
                        })
                    end)
                    local elapsed = 0
                    while elapsed < 60 and State.AutoRollFruitEnabled do
                        task.wait(1)
                        elapsed = elapsed + 1
                    end
                end
            end)
        end
    end)

    RaidsTab:AddLabel("SETTINGS")
    do
        local raidEquipSelecting=false; local raidEquipDropdownRef
        raidEquipDropdownRef=RaidsTab:AddDropdown("Auto Equip Weapon",{"Melee","Sword","Blox Fruit"},function(selected)
            if raidEquipSelecting then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.RaidAutoEquipWeapon=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.RaidAutoEquipWeapon then chosen=k;break end end raidEquipSelecting=true;raidEquipDropdownRef:ClearSelection();raidEquipSelecting=false end
            State.RaidAutoEquipWeapon=chosen
        end)
    end
    RaidsTab:AddSlider("Distance To NPC (studs)",5,50,5,function(v) State.RaidDistanceBetweenNPC=v end)
    RaidsTab:AddToggle("Bring NPCs",function(state) State.RaidBringNPCsEnabled=state end)

    RaidsTab:AddSeparator()
    RaidsTab:AddLabel("AUTO RAID")
    RaidsTab:AddToggle("Auto Raid",function(state)
        if state then
            State.AutoRaidEnabled=true
            task.spawn(RaidFarmLoop)
        else
            State.AutoRaidEnabled=false
        end
    end)

    RaidsTab:AddToggle("Auto Start Raid",function(state)
        State.AutoStartRaidEnabled=state
        if state then
            task.spawn(function()
                while State.AutoStartRaidEnabled do
                    PerformStartRaid()
                    local elapsed = 0
                    while elapsed < 300 and State.AutoStartRaidEnabled do
                        task.wait(1)
                        elapsed = elapsed + 1
                    end
                end
            end)
        end
    end)
    RaidsTab:AddToggle("Auto Go Lab To Start", function(state)
        State.AutoGoLabToStartEnabled = state
    end)
    do
        local rSel=false; local rRef
        rRef=RaidsTab:AddDropdown("Select Raid To Start",{"Flame","Ice","Quake","Light","Dark","Spider","Magma","Buddha","Sand"},function(selected)
            if rSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.SelectedRaidType=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.SelectedRaidType then chosen=k;break end end rSel=true;rRef:ClearSelection();rSel=false end
            State.SelectedRaidType=chosen
        end)
    end

    SeaEventTab:AddLabel("SETTINGS")
    do
        local seEquipSelecting=false; local seEquipDropdownRef

        seEquipDropdownRef=SeaEventTab:AddDropdown("Auto Equip Weapon",{"Melee","Sword","Blox Fruit"},function(selected)
            if seEquipSelecting then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.SeaEventAutoEquipWeapon=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.SeaEventAutoEquipWeapon then chosen=k;break end end seEquipSelecting=true;seEquipDropdownRef:ClearSelection();seEquipSelecting=false end
            State.SeaEventAutoEquipWeapon=chosen
        end)
    end
    SeaEventTab:AddSlider("Distance To NPC (studs)",5,50,5,function(v) State.SeaEventDistanceBetweenNPC=v end)
    SeaEventTab:AddToggle("Bring NPCs",function(state) State.SeaEventBringNPCsEnabled=state end)
    SeaEventTab:AddToggle("Reset If Boat Sinks",function(state) State.ResetIfBoatSinks=state end)
    SeaEventTab:AddToggle("Noclip Boat",function(state) State.NoclipBoatEnabled=state if state then EnableNoclipBoat() else DisableNoclipBoat() end end)

    SeaEventTab:AddSeparator()
    SeaEventTab:AddLabel("AUTO SEA EVENT")
    SeaEventTab:AddToggle("Auto Buy Boat",function(state) State.AutoBuyBoatEnabled=state end)
    do
        local bSel=false; local bRef
        local boatList={"Guardian","PirateBrigade","MarineBrigade","PirateGrandBrigade","MarineGrandBrigade","PirateSloop","MarineSloop","BeastHunter"}
        bRef=SeaEventTab:AddDropdown("Select Boat to Buy",boatList,function(selected)
            if bSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.SelectedBoatToBuy=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.SelectedBoatToBuy then chosen=k;break end end bSel=true;bRef:ClearSelection();bSel=false end
            State.SelectedBoatToBuy=chosen
        end)
    end
    SeaEventTab:AddToggle("Auto Find Sea Event",function(state)
        State.AutoFindSeaEventEnabled=state
        if state then task.spawn(SeaEventPatrolLoop) else StopBoatAndPlayerMovement() end
    end)
    do
        local zSel=false; local zRef
        local zoneList={"Zone 1 Low","Zone 2 Medium","Zone 3 High","Zone 4 Extreme","Zone 5 Crazy","Zone 6 ???"}
        zRef=SeaEventTab:AddDropdown("Select Zone",zoneList,function(selected)
            if zSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.SelectedSeaEventZone="Zone 6 ???";return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.SelectedSeaEventZone then chosen=k;break end end zSel=true;zRef:ClearSelection();zSel=false end
            State.SelectedSeaEventZone=chosen
        end)
    end
    SeaEventTab:AddToggle("Auto Kill",function(state)
        State.AutoKillEnabled=state
        if state then
            task.spawn(KillHauntedCrewMemberLoop)
        end
    end)
    local autoKillList={"Shark","Terrorshark","Piranha","Brigades","Sea Beast","Fish Boat","Fish Crew Member","Haunted Crew Member"}
    SeaEventTab:AddDropdown("Select To Auto Kill",autoKillList,function(selected) State.SelectedAutoKillTargets={} for t in pairs(selected) do State.SelectedAutoKillTargets[t]=true end end)

    SeaEventTab:AddSeparator()
    SeaEventTab:AddLabel("AUTO FIND")
    SeaEventTab:AddToggle("Auto Find Mirage Island",function(state)
        State.AutoFindMirageIslandEnabled=state

        if state then StartIslandPatrolLoop() end

    end)
    SeaEventTab:AddToggle("Auto Find Prehistoric Island",function(state)
        State.AutoFindPrehistoricIslandEnabled=state
        if state then StartIslandPatrolLoop() end
    end)
    SeaEventTab:AddToggle("Auto Find Shipwreck Island",function(state)
        State.AutoFindShipwreckIslandEnabled=state

        if state then StartIslandPatrolLoop() end
    end)
    SeaEventTab:AddToggle("Auto Find Kitsune Island",function(state)
        State.AutoFindKitsuneIslandEnabled=state
        if state then StartIslandPatrolLoop() end
    end)

    PVPTab:AddLabel("ESP")
    PVPTab:AddToggle("ESP Players",function(state) State.PlayerESPEnabled=state if not state then RemoveAllPlayerESP() end end)
    PVPTab:AddToggle("ESP Lines",function(state) State.ESPLinesEnabled=state if not state then RemoveAllESPLines() end end)

    PVPTab:AddSeparator()
    PVPTab:AddLabel("COMBAT")
    do
        local pvpSel=false; local pvpRef
        pvpRef=PVPTab:AddDropdown("Auto Equip Weapon",{"Melee","Sword","Blox Fruit"},function(selected)
            if pvpSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.AutoEquipWeaponPVP=nil;return end

            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.AutoEquipWeaponPVP then chosen=k;break end end pvpSel=true;pvpRef:ClearSelection();pvpSel=false end
            State.AutoEquipWeaponPVP=chosen
        end)
    end

    PVPTab:AddToggle("Player Kill Aura", function(state) State.PlayerKillAuraEnabled = state end)
    PVPTab:AddToggle("TP Behind While Orbit",function(state) State.TPBehindOrbitEnabled=state if State.OrbitEnabled and State.OrbitTarget then StartOrbit(State.OrbitTarget) end end)
    do
        local oSel=false
        State.OrbitDropdownRef=PVPTab:AddDropdown("Orbit Player",GetOnlinePlayerNames(),function(selected)
            if oSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then StopOrbit();State.OrbitTarget=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=(State.OrbitTarget and State.OrbitTarget.Name or nil) then chosen=k;break end end oSel=true;State.OrbitDropdownRef:ClearSelection();oSel=false end
            if chosen=="(No players)" then StopOrbit();State.OrbitTarget=nil;return end
            local tp=Players:FindFirstChild(chosen) if tp then StartOrbit(tp) else StopOrbit();State.OrbitTarget=nil end
        end)
    end
    PVPTab:AddSlider("Orbit Speed",1,20,1,function(v) State.OrbitSpeed=v end)
    PVPTab:AddSlider("Orbit Distance",5,50,10,function(v) State.OrbitDistance=v end)

    PVPTab:AddSeparator()
    PVPTab:AddLabel("AIM")
    PVPTab:AddToggle("Aimlock On Closest Player", function(state) State.AimlockClosestPlayerEnabled = state end)
    PVPTab:AddToggle("Aimbot On Selected Player", function(state) State.AimbotSelectedPlayerEnabled = state end)
    do
        local pList = GetOnlinePlayerNames()
        State.lastAimlockPlayerSet = pList
        local aimSel = false
        State.AimlockSelectedDropdownRef = PVPTab:AddDropdown("Select Player To Aimlock On", pList, function(selected)
            if aimSel then return end
            local keys = {} for k in pairs(selected) do table.insert(keys, k) end
            if #keys == 0 then State.AimlockSelectedPlayerTarget = nil; return end
            local chosen = keys[1]
            if #keys > 1 then
                for _, k in ipairs(keys) do if k ~= State.AimlockSelectedPlayerTarget then chosen = k; break end end
                aimSel = true; State.AimlockSelectedDropdownRef:ClearSelection(); aimSel = false
            end
            if chosen == "(No players)" then State.AimlockSelectedPlayerTarget = nil; return end
            State.AimlockSelectedPlayerTarget = chosen
        end)
    end

    PVPTab:AddSeparator()
    PVPTab:AddLabel("CAMERA")
    PVPTab:AddToggle("Lock Camera On Closest Player",function(state)
        State.LockCameraEnabled=state
        if not state then pcall(function() local cam=Workspace.CurrentCamera local mc=LocalPlayer.Character local mh=mc and mc:FindFirstChild("Humanoid") if mh then cam.CameraSubject=mh end;cam.CameraType=Enum.CameraType.Custom end) end
    end)
    PVPTab:AddToggle("Lock Camera On Selected Player",function(state)
        State.LockCameraSelectedPlayerEnabled=state
        if not state then pcall(function() local cam=Workspace.CurrentCamera local mc=LocalPlayer.Character local mh=mc and mc:FindFirstChild("Humanoid") if mh then cam.CameraSubject=mh end;cam.CameraType=Enum.CameraType.Custom end) end
    end)
    do
        local pList=GetOnlinePlayerNames()
        State.lastLockCameraPlayerSet=pList
        local lcSel=false
        State.LockCameraSelectedDropdownRef=PVPTab:AddDropdown("Select Player To Lock Camera On",pList,function(selected)
            if lcSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            if #keys==0 then State.LockCameraSelectedPlayerTarget=nil;return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=State.LockCameraSelectedPlayerTarget then chosen=k;break end end lcSel=true;State.LockCameraSelectedDropdownRef:ClearSelection();lcSel=false end
            if chosen=="(No players)" then State.LockCameraSelectedPlayerTarget=nil;return end
            State.LockCameraSelectedPlayerTarget=chosen
        end)
    end
    do
        local sSel=false
        State.SpectateDropdownRef=PVPTab:AddDropdown("Spectate Player",GetOnlinePlayerNames(),function(selected)
            if sSel then return end
            local keys={}; for k in pairs(selected) do table.insert(keys,k) end
            local function resetCam() State.SpectateEnabled=false;State.SpectateTarget=nil pcall(function() local cam=Workspace.CurrentCamera local mc=LocalPlayer.Character local mh=mc and mc:FindFirstChild("Humanoid") if mh then cam.CameraSubject=mh end;cam.CameraType=Enum.CameraType.Custom end) end
            if #keys==0 then resetCam();return end
            local chosen=keys[1]
            if #keys>1 then for _,k in ipairs(keys) do if k~=(State.SpectateTarget and State.SpectateTarget.Name or nil) then chosen=k;break end end sSel=true;State.SpectateDropdownRef:ClearSelection();sSel=false end
            if chosen=="(No players)" then resetCam();return end
            local tp=Players:FindFairstChild(chosen) if tp then State.SpectateTarget=tp;State.SpectateEnabled=true else resetCam() end
        end)
    end
end

InitUI()

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})