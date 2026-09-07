-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Sailor Piece
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

local Library = createSymbioteShim("Sailor Piece")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Event = game:GetService("ReplicatedStorage").Remotes.ShowNotification

for i = 1, 3 do
    for _, v in pairs(getconnections(Event.OnClientEvent)) do
        v.Function("Quest", {
            message = "  Symbiote "
        })
    end
    task.wait(0.1)
end

local WeaponNames = {
    "Combat", "Gojo", "Sukuna", "Strongest In History", "Strongest Of Today",
    "Saber Alter", "CosmicBeing", "TheWorld", "BlackReaper", "Qin Shi", "Yuji", "Alucard", "Katana", "Dark Blade",
    "Saber", "Excalibur", "Jinwoo", "Ragna", "Aizen", "Shadow", "Strongest Shinobi", "Spirit Warrior",
    "MoonSlayer", "AntiMagic", "Ichigo", "Soul Reaper", "Rimuru", "Madoka", "Gilgamesh", "Anos", "Shadow Monarch",
    "Atomic", "Ice Queen", "DragonGoddess", "Sun God", "Dual Wielder", "GreatMage", "Abyssal Empress", "Escanor", "True Aizen", "Yamato",
    "Blessed Maiden", "Gryphon", "Flame", "Ice", "Light", "Dark", "Magma", "Dragon",
    "Bomb", "Invisible", "Quake"
}

local NPCNames = {
    "Thief", "Monkey", "DesertBandit", "FrostRogue", "SorcererStudent",
    "Hollow", "StrongSorcerer", "Slime", "Curse", "AcademyTeacher",
    "Swordsman", "Quincy", "Ninja", "ArenaFighter", "Delinquent",
    "StrongFighter", "StrongBandit", "FastNinja", "Bunny",
    "SpiritFighter", "StrongSlayer", "GhoulMember",
}

local BossNames = {
    "ThiefBoss", "MonkeyBoss", "DesertBoss", "SnowBoss", "PandaMiniBoss",
    "SaberBoss", "QinShiBoss", "GojoBoss", "SukunaBoss", "YujiBoss",
    "JinwooBoss", "AlucardBoss", "RagnaBoss", "AizenBoss", "IchigoBoss",
    "MadokaBoss", "Yamato", "Gilgamesh", "StrongestofTodayBoss", "StrongestShinobiBoss",
    "StrongestinHistoryBoss", "Rimuru", "Anos", "TrueAizen", "BlessedMaiden",
    "SaberAlter", "AtomicBoss", "IceQueenBoss", "GreatMageBoss", "CosmicBeingBoss",
    "TheWorldBoss", "SunGodBoss", "MinoBoss", "BlackReaperBoss"
}

local QuestNames = {
    {name = "Thief Quest",                              npc = "QuestNPC1"},
    {name = "Thief Boss Quest",                         npc = "QuestNPC2"},
    {name = "Monkey Quest",                             npc = "QuestNPC3"},
    {name = "Monkey Boss Quest",                        npc = "QuestNPC4"},
    {name = "Desert Bandit Quest",                      npc = "QuestNPC5"},
    {name = "Desert Bandit Boss Quest",                 npc = "QuestNPC6"},
    {name = "Frost Rogue Quest",                        npc = "QuestNPC7"},
    {name = "Winter Warden Quest",                      npc = "QuestNPC8"},
    {name = "Sorcerer Student Quest",                   npc = "QuestNPC9"},
    {name = "Panda Sorcerer Quest",                     npc = "QuestNPC10"},
    {name = "Hollow Quest",                             npc = "QuestNPC11"},
    {name = "Strong Sorcerer Quest",                    npc = "QuestNPC12"},
    {name = "Curse Quest",                              npc = "QuestNPC13"},
    {name = "Slime Warrior Quest",                      npc = "QuestNPC14"},
    {name = "Academy Teacher Quest",                    npc = "QuestNPC15"},
    {name = "Swordsmen Quest",                          npc = "QuestNPC16"},
    {name = "Quincy Quest",                             npc = "QuestNPC17"},
    {name = "Ninja Quest",                              npc = "QuestNPC18"},
    {name = "Arena Fighter Quest",                      npc = "QuestNPC19"},
    {name = "Delinquent Quest",                         npc = "QuestNPC20"},
    {name = "Strong Fighter Quest",                     npc = "QuestNPC21"},
    {name = "Strong Bandit Quest",                      npc = "QuestNPC22"},
    {name = "Fast Ninja Quest",                         npc = "QuestNPC23"},
    {name = "Spirit Fighter Quest",                     npc = "QuestNPC24"},
    {name = "Strong Slayer Quest",                      npc = "QuestNPC25"},
    {name = "Ghoul Member Quest",                       npc = "QuestNPC26"},
    {name = "Anos Quest",                               npc = "AnosQuestNPC"},
    {name = "Haki Quest",                               npc = "HakiQuestNPC"},
    {name = "Solo Hunter Training Quest",               npc = "JinwooMovesetNPC"},
    {name = "Cursed King(Sukuna) Training Quest",       npc = "SukunaMovesetNPC"},
    {name = "Limitless Sorcerer(Gojo) Training Quest",  npc = "GojoMovesetNPC"},
    {name = "Manipulator(Aizen) Training Quest",        npc = "AizenMovesetNPC"},
}

local IslandPortalKeys = {
    ["Starter Island"]    = "Starter",
    ["Jungle Island"]     = "Jungle",
    ["Desert Island"]     = "Desert",
    ["Snow Island"]       = "Snow",
    ["Sailor Island"]     = "Sailor",
    ["Shibuya Station"]   = "Shibuya",
    ["Hollow Island"]     = "HollowIsland",
    ["Boss Island"]       = "Boss",
    ["Dungeon Island"]    = "Dungeon",
    ["Shinjuku Island"]   = "Shinjuku",
    ["Slime Island"]      = "Slime",

    ["Academy Island"]    = "Academy",
    ["Judgement Island"]  = "Judgement",
    ["Soul Dominion"]     = "SoulDominion",
    ["Ninja Island"]      = "Ninja",
    ["Tower Island"]      = "Tower",
    ["Lawless Island"]    = "Lawless",
    ["Easter Island"]     = "Easter",
    ["World Island"]      = "World",
    ["World Island Sea 2"]      = "Sea2World",
    ["Starter Island Sea 2"]      = "StarterSea2",

    ["Bizarre Island"]    = "Bizarre",
    ["Punch Island"]      = "Punch",
    ["Blue Planet Island"]      = "BluePlanet",
    ["Slayer Island"]     = "Slayer",
    ["Isolation Island"] = "Isolation",
}

local IslandPositions = {
    {name = "Starter Island",   portalKey = "Starter",      cframe = CFrame.new(-34.4348831, -2.58425546, -275.509857, -0.152905077, 1.80722004e-09, -0.988240898, 8.49596038e-09, 1, 5.14190912e-10, 0.988240898, -8.31743296e-09, -0.152905077)},
    {name = "Jungle Island",    portalKey = "Jungle",       cframe = CFrame.new(-445.951965, -1.6332469, 428.936768, -0.836325169, 5.44023404e-09, 0.548233688, 5.67644998e-09, 1, -1.26383293e-09, -0.548233688, 2.05504591e-09, -0.836325169)},
    {name = "Desert Island",    portalKey = "Desert",       cframe = CFrame.new(-714.655396, -0.896497905, -294.313812, 0.170899898, 6.1884478e-08, 0.985288382, -3.46061917e-08, 1, -5.68059875e-08, -0.985288382, -2.43889424e-08, 0.170899898)},
    {name = "Snow Island",      portalKey = "Snow",         cframe = CFrame.new(-220.19368, -4.14506054, -996.632019, -0.376017213, -2.75259726e-08, 0.926612675, 4.47651409e-08, 1, 4.78716053e-08, -0.926612675, 5.94804916e-08, -0.376017213)},
    {name = "Sailor Island",    portalKey = "Sailor",       cframe = CFrame.new(211.194473, 3.04897046, 683.035889, -0.9904989, 2.10108837e-08, -0.137520611, 2.97304688e-08, 1, -6.13516207e-08, 0.137520611, -6.4857268e-08, -0.9904989)},
    {name = "Shibuya Station",  portalKey = "Shibuya",      cframe = CFrame.new(1311.32666, 8.83891392, 253.368454, -0.147848666, -5.83041491e-08, -0.989009976, -1.21485018e-08, 1, -5.71359315e-08, 0.989009976, 3.56751784e-09, -0.147848666)},
    {name = "Hollow Island",    portalKey = "HollowIsland", cframe = CFrame.new(-574.182068, -2.08896708, 893.559387, -0.866070628, 2.55811248e-08, 0.49992165, 2.83578707e-08, 1, -2.04273198e-09, -0.49992165, 1.24075639e-08, -0.866070628)},
    {name = "Boss Island",      portalKey = "Boss",         cframe = CFrame.new(629.30127, -2.83459735, -1054.51758, 0.698677361, 0, -0.715436876, 0, 1, 0, 0.715436876, 0, 0.698677361)},
    {name = "Dungeon Island",   portalKey = "Dungeon",      cframe = CFrame.new(1298.83447, 2.10761261, -902.259644, 0.362519026, 0, -0.931976378, 0, 1, 0, 0.931976378, 0, 0.362519026)},
    {name = "Shinjuku Island",  portalKey = "Shinjuku",     cframe = CFrame.new(209.76918, -1.63673973, -1669.54724, 0.966838777, 0, -0.255387455, 0, 1, 0, 0.255387455, 0, 0.966838777)},
    {name = "Slime Island",     portalKey = "Slime",        cframe = CFrame.new(-1009.93933, -4.0925765, 266.805908, -0.223429903, 0, 0.974720001, 0, 1, 0, -0.974720001, 0, -0.223429903)},
    {name = "Academy Island",   portalKey = "Academy",      cframe = CFrame.new(984.556091, -1.94254327, 1087.52075, -0.925900221, 0, -0.377768129, 0, 1, 0, 0.377768129, 0, -0.925900221)},
    {name = "Judgement Island", portalKey = "Judgement",    cframe = CFrame.new(-1046.20483, 0.570000768, -1024.96448, 0.824122906, -2.22641994e-08, 0.566411018, -2.49473686e-08, 1, 7.56056906e-08, -0.566411018, -7.64388446e-08, 0.824122906)},
    {name = "Soul Dominion",    portalKey = "SoulDominion", cframe = CFrame.new(-1046.20483, 0.570000768, -1024.96448, 0.824122906, -2.22641994e-08, 0.566411018, -2.49473686e-08, 1, 7.56056906e-08, -0.566411018, -7.64388446e-08, 0.824122906)},
    {name = "Ninja Island",     portalKey = "Ninja",        cframe = CFrame.new(-1700.55286, 8.27048874, -613.175537, 0.113950521, 1.28913982e-07, 0.993486404, 3.18172311e-09, 1, -1.30124107e-07, -0.993486404, 1.79887092e-08, 0.113950521)},
    {name = "Tower Island",     portalKey = "Tower",        cframe = CFrame.new(1330.61597, -2.12812114, -1462.00525, 0.454680264, 2.32699211e-08, -0.890654743, 4.04300522e-08, 1, 4.67663455e-08, 0.890654743, -5.72729491e-08, 0.454680264)},
    {name = "Lawless Island",   portalKey = "Lawless",      cframe = CFrame.new(126.601532, -5.66588545, 1698.35742, -0.952038944, -2.47085435e-10, 0.305976957, -2.74330549e-08, 1, -8.45496757e-08, -0.305976957, -8.88884628e-08, -0.952038944)},
    {name = "Easter Island",    portalKey = "Easter",       cframe = CFrame.new(2168.63306, 9.46416378, 2246.26196, -0.941153824, -7.12005388e-08, -0.337978542, -1.01250713e-07, 1, 7.1282507e-08, 0.337978542, 1.01308373e-07, -0.941153824)},
    {name = "World Island",     portalKey = "World",        cframe = CFrame.new(-844.734314, 322.997528, -2188.01611, 0.19965826, -7.86387133e-08, -0.979865611, -5.10248626e-08, 1, -9.06514614e-08, 0.979865611, 6.80968171e-08, 0.19965826)},
    {name = "World Island Sea 2", portalKey = "Sea2World",  cframe = CFrame.new(-390.622925, 323.722473, -3005.67798, 0.993739784, 6.52397247e-09, 0.111719303, -4.4040358e-09, 1, -1.92223428e-08, -0.111719303, 1.86099918e-08, 0.993739784)},
    {name = "Starter Island Sea 2", portalKey = "StarterSea2", cframe = CFrame.new(-509.323822, -3.66658521, -366.110565, -0.712458253, 1.56070854e-08, -0.701714516, 4.57978082e-08, 1, -2.4257643e-08, 0.701714516, -4.9419544e-08, -0.712458253)},
    {name = "Bizarre Island",   portalKey = "Bizarre",      cframe = CFrame.new(-2824.69385, 7.51867056, -647.317749, -0.71489495, 1.17666062e-07, 0.699231863, 6.29315196e-08, 1, -1.03937822e-07, -0.699231863, -3.03008996e-08, -0.71489495)},
    {name = "Punch Island",     portalKey = "Punch",        cframe = CFrame.new(-1595.43115, 2.68225145, 1694.05664, -0.999583542, -2.79174728e-09, 0.0288564637, -2.65813016e-09, 1, 4.66876227e-09, -0.0288564637, 4.59011407e-09, -0.999583542)},
    {name = "Blue Planet Island",     portalKey = "BluePlanet",        cframe = CFrame.new(-3517.43457, -1.12273669, 1153.49475, -0.657648087, 0.172477305, 0.733314812, 0.0404572487, 0.980118692, -0.194243476, -0.752238095, -0.0980759263, -0.651551008)},

    {name = "Slayer Island",    portalKey = "Slayer",        cframe = CFrame.new(-2357.74023, 23.1425705, -2942.89502, 0.754539311, 0.137366027, 0.641717315, -0.0534722507, 0.987465203, -0.148503497, -0.654072881, 0.0777376443, 0.752426445)},
    {name = "Isolation Island",    portalKey = "Isolation",        cframe = CFrame.new(6582.34326, 1422.3822, -2656.7146, 0.999986589, -2.63698006e-08, 0.00518149883, 2.62384425e-08, 1, 2.54195509e-08, -0.00518149883, -2.52832546e-08, 0.999986589)},
}

local SeaBeastPatrolPoints = {
    CFrame.new(4557.69336,  76.0794983,   851.766907,  0.972370028,  0.0711530745, -0.222337037,  2.48098843e-07,  0.952417314,  0.304797024,  0.233444899,  -0.296375543,  0.926102042),
    CFrame.new(5708.32715,  76.0820007,  1064.04395,   0.998134851,  0.0167960245, -0.0586917214, 1.30118991e-07,  0.961406589,  0.275131464,  0.0610477217, -0.274618298,  0.959613442),

    CFrame.new(6291.52246,  76.081955,   1099.75964,   0.998134851,  0.0168282725, -0.0586824827, 1.34619938e-07,  0.961255252,  0.27565977,   0.0610477217, -0.27514565,   0.959462404),
    CFrame.new(6157.79053,  -7.76782227,  324.740875,   0.999390781, -0.000387471024, 0.0348982066, -1.97526091e-07, 0.999938309,  0.0111078639, -0.0349003561, -0.0111011043, 0.99932915),
    CFrame.new(5287.7002,   -7.76773071,  355.12149,    0.999390781, -0.000340830156, 0.0348983444, -1.93409974e-07, 0.999952257,  0.00977144297,-0.0349000096, -0.00976549648, 0.999343097),
    CFrame.new(3926.31372,  -7.76755905,  402.652802,   0.999390781, -0.000320405408, 0.0348988883,  1.93776614e-07, 0.999957919,  0.00917502772,-0.0349003598, -0.0091694314,  0.99934876),
    CFrame.new(3770.3252,   -7.2081275,  -696.746033,   0.999048173, -0.000643086445, 0.0436151549, -1.92712292e-07, 0.999891281,  0.0147473747, -0.0436198972, -0.0147333462,  0.998939574),
    CFrame.new(4787.68896,  -7.20816231, -741.220398,   0.999048173, -0.000679468911, 0.04361495,   -1.98515323e-07, 0.999878585,  0.0155814635, -0.0436202437, -0.0155666415,  0.998926878),
    CFrame.new(6091.73193,  -7.20788908, -798.226501,   0.999048173, -0.00064308662,  0.0436155014, -1.98153941e-07, 0.999891281,  0.0147473859, -0.0436202437, -0.0147333583,  0.998939514),
    CFrame.new(4596.31152,  -7.70525885, -2467.45557,  -0.258819371, -0.0143985273,   0.965818405,   1.92481181e-07, 0.999888897,  0.0149065051, -0.965925753,   0.00385827804, -0.258790612),
    CFrame.new(4263.7168,   -7.70554066, -3708.23071,  -0.258819371, -0.016713785,    0.965781152,   1.92145961e-07, 0.999850273,  0.017303437,  -0.965925753,   0.00447865017, -0.258780599),
    CFrame.new(3830.53003,  -7.70591831, -5323.57227,  -0.258819342, -0.0147609264,   0.965812981,  -1.98053343e-07, 0.999883235,  0.0152815841, -0.965925753,   0.00395497819, -0.258789122),
    CFrame.new(5380.34277,  -8.30168629, -5593.33838,   0.16504775,   0.0353647731,  -0.985651374,  -1.8763194e-07,  0.999356925,  0.0358564928,  0.986285567,  -0.00591784809,  0.164941624),
    CFrame.new(4335.78809,  -8.29800606, -5266.55566,  -0.224951804, -0.385297865,    0.894953787,  -9.95850655e-08, 0.91849488,   0.39543283,   -0.974369884,   0.0889532417,  -0.206617117),
    CFrame.new(4014.51758,  -8.30165577, -6087.68164,   0.782384753, -3.49379299e-08,  0.622795343,   1.31238904e-08, 1,            3.96117201e-08,-0.622795343,  -2.28181083e-08,  0.782384753),
    CFrame.new(2556.61523,  -8.30165577, -4982.71924,  -0.898838937, -8.41315284e-09,  0.438279092,  -2.376804e-08,   1,           -2.95484952e-08,-0.438279092,  -3.6976374e-08,  -0.898838937),
    CFrame.new(1337.93359,  -8.30165672, -5360.06494,  -0.103253588, -7.0996202e-11,   0.994655073,   7.25471772e-09, 1,            8.24478597e-10,-0.994655073,   7.30107219e-09, -0.103253588),
    CFrame.new(1219.99768,  -8.30165672, -6584.49121,   0.981627584, -7.11978885e-08, -0.190806985,   6.27181649e-08, 1,           -5.0480395e-08,  0.190806985,   3.75858846e-08,  0.981627584),
    CFrame.new(-20.5836849, -8.30165672, -6419.15869,  -0.100944147, -4.59840201e-08,  0.99489212,    6.01613479e-08, 1,            5.23242214e-08,-0.99489212,    6.51358718e-08, -0.100944147),
    CFrame.new(214.152725,  -8.30165958, -4560.24512,  -0.392371744, -1.52723416e-08,  0.919806719,  -5.58419844e-09, 1,            1.42217482e-08,-0.919806719,   4.43829029e-10, -0.392371744),
}

local function TeleportToPortal(portalKey)
    pcall(function()
        local Ev = game:GetService("ReplicatedStorage").Remotes.TeleportToPortal
        Ev:FireServer(portalKey)
    end)
end

local AutoFarmEnabled      = false
local AutoFarmBossEnabled  = false
local AutoSkillEnabled     = false
local AutoStatEnabled      = false
local AutoBossSpawnEnabled = false
local AutoHakiEnabled      = false
local AutoObsHakiEnabled   = false
local KillAuraEnabled      = false
local AutoDungeonEnabled   = false
local AutoAscendEnabled    = false
local DungeonTweenSpeed    = 300
local DungeonDistance      = 5
local DungeonCurrentTarget = nil
local DungeonSelectedWeapon = nil
local DungeonSkillEnabled  = false
local DungeonSkillCooldowns    = { Z = 5, X = 5, C = 5, V = 5, F = 5 }
local DungeonSkillLastFired    = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
local DungeonSkillGlobalUnlock = 0
local FlyEnabled          = false
local NoClipEnabled       = false
local SelectedNPCs        = {}

local SelectedBosses      = {}
local SelectedWeapon      = nil
local AutoEquipWeapon     = nil
local SelectedQuest       = nil
local SelectedStats       = {}
local StatRoundRobinIndex = 1
local CurrentTarget       = nil
local CurrentBossTarget   = nil
local DistanceBetweenNPC  = 5
local TweenSpeed          = 300
local WalkSpeed           = 16
local JumpHeight          = 50
local FlySpeed            = 50
local NoClipConnection    = nil
local FlyConnection       = nil
local FlyBodyVelocity     = nil
local FlyBodyGyro         = nil

local SelectedSpawnBoss   = nil
local SpawnFrequency      = 10
local ServiceNPCESPEnabled = false

local AutoSeaBeastEnabled        = false
local SeaBeastSelectedWeapon     = nil

local SeaBeastDistanceToNPC      = 5
local SeaBeastTweenSpeed         = 300
local SeaBeastCurrentTarget      = nil
local SeaBeastPatrolTargetCF     = SeaBeastPatrolPoints[1]

local SeaBeastBossTarget = nil

local EggMapESPEnabled = false

local SkillCooldowns      = { Z = 5, X = 5, C = 5, V = 5, F = 5 }
local SkillLastFired      = { Z = 0, X = 0, C = 0, V = 0, F = 0 }
local SkillGlobalUnlockAt = 0

local SkillKeyMap = { Z = 1, X = 2, C = 3, V = 4, F = 5 }
local SkillOrder  = { "Z", "X", "C", "V", "F" }

local FruitWeapons = {
    Flame = true, Ice = true, Light = true, Dark = true,
    Magma = true, Dragon = true, Bomb = true, Invisible = true, Quake = true
}

local FruitSkillKeyCodes = {
    Z = Enum.KeyCode.Z,
    X = Enum.KeyCode.X,
    C = Enum.KeyCode.C,
    V = Enum.KeyCode.V,
    F = Enum.KeyCode.F,
}

local function GetEquippedFruitWeapon()
    local character = LocalPlayer.Character
    if not character then return nil end
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and FruitWeapons[item.Name] then
            return item.Name
        end
    end
    return nil
end

local StatOrder = {"Melee", "Sword", "Defense", "Power"}

local SpawnBossData = {
    {name = "Saber",                    remote = "SaberBoss",        tier = nil},

    {name = "Qin Shi",                  remote = "QinShiBoss",       tier = nil},
    {name = "Ichigo",                   remote = "IchigoBoss",       tier = nil},
    {name = "Gilgamesh [Normal]",       remote = "GilgameshBoss",    tier = "Normal"},
    {name = "Gilgamesh [Medium]",       remote = "GilgameshBoss",    tier = "Medium"},
    {name = "Gilgamesh [Hard]",         remote = "GilgameshBoss",    tier = "Hard"},
    {name = "Gilgamesh [Extreme]",      remote = "GilgameshBoss",    tier = "Extreme"},
    {name = "Blessed Maiden [Normal]",  remote = "BlessedMaidenBoss", tier = "Normal"},
    {name = "Blessed Maiden [Medium]",  remote = "BlessedMaidenBoss", tier = "Medium"},
    {name = "Blessed Maiden [Hard]",    remote = "BlessedMaidenBoss", tier = "Hard"},
    {name = "Blessed Maiden [Extreme]", remote = "BlessedMaidenBoss", tier = "Extreme"},
    {name = "Saber Alter [Normal]",     remote = "SaberAlterBoss",   tier = "Normal"},

    {name = "Saber Alter [Medium]",     remote = "SaberAlterBoss",   tier = "Medium"},
    {name = "Saber Alter [Hard]",       remote = "SaberAlterBoss",   tier = "Hard"},
    {name = "Saber Alter [Extreme]",    remote = "SaberAlterBoss",   tier = "Extreme"},
    {name = "Moon Slayer [Normal]",     remote = "MoonSlayerBoss",   tier = "Normal"},
    {name = "Moon Slayer [Medium]",     remote = "MoonSlayerBoss",   tier = "Medium"},
    {name = "Moon Slayer [Hard]",       remote = "MoonSlayerBoss",   tier = "Hard"},
    {name = "Moon Slayer [Extreme]",    remote = "MoonSlayerBoss",   tier = "Extreme"},
    {name = "Ice Queen [Normal]",       remote = "IceQueenBoss",     tier = "Normal"},
    {name = "Ice Queen [Medium]",       remote = "IceQueenBoss",     tier = "Medium"},
    {name = "Ice Queen [Hard]",         remote = "IceQueenBoss",     tier = "Hard"},
    {name = "Ice Queen [Extreme]",      remote = "IceQueenBoss",     tier = "Extreme"},
}

task.spawn(function()
    while true do
        if AutoBossSpawnEnabled and SelectedSpawnBoss then
            pcall(function()
                local Ev = game:GetService("ReplicatedStorage").Remotes.RequestSummonBoss
                if SelectedSpawnBoss.tier then
                    Ev:FireServer(SelectedSpawnBoss.remote, SelectedSpawnBoss.tier)
                else
                    Ev:FireServer(SelectedSpawnBoss.remote)
                end
            end)
            task.wait(SpawnFrequency)

        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if not AutoAscendEnabled then continue end
        pcall(function()
            local Ev = game:GetService("ReplicatedStorage").RemoteEvents.RequestAscend
            Ev:FireServer()
        end)
    end
end)

local function FindNPC(npcName, exactMatch)
    local NPCsFolder = Workspace:FindFirstChild("NPCs")
    if not NPCsFolder then return nil end
    for _, npc in pairs(NPCsFolder:GetChildren()) do
        if npc:IsA("Model") and npc.Name ~= "TrainingDummy" then
            local matches
            if exactMatch then
                matches = string.match(npc.Name, "^" .. npcName .. "%d+$") ~= nil
            else
                matches = string.match(npc.Name, "^" .. npcName) ~= nil
            end
            if matches then
                local humanoid = npc:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then return npc end
            end
        end
    end
    return nil
end

local function IsTargetValid(target)
    if not target or not target.Parent then return false end
    if target.Name == "MinoBoss" then
        local hitbox = target:FindFirstChild("MinoBossHitbox")
        return hitbox ~= nil and hitbox.Parent ~= nil
    end
    local humanoid = target:FindFirstChild("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

local function IsTargetReady(target)
    if not target or not target.Parent then return false end
    if target.Name == "MinoBoss" then
        local hitbox = target:FindFirstChild("MinoBossHitbox")
        return hitbox ~= nil and hitbox.Parent ~= nil
    end
    local humanoid = target:FindFirstChild("Humanoid")
    local hrp      = target:FindFirstChild("HumanoidRootPart")
    return humanoid ~= nil and hrp ~= nil and humanoid.Health > 0
end

local function FindClosestIsland(targetPosition)
    local closestIsland, closestDistance = nil, math.huge

    for _, island in ipairs(IslandPositions) do
        local d = (island.cframe.Position - targetPosition).Magnitude

        if d < closestDistance then closestDistance = d; closestIsland = island end
    end
    return closestIsland
end

local function GetNPCWalkPoint(npcModel)
    local humanoid = npcModel:FindFirstChild("Humanoid")
    if humanoid then
        local wp = humanoid.WalkToPoint
        if wp ~= Vector3.new(0, 0, 0) then return wp end
    end
    return nil
end

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
    if FlyBodyGyro     then FlyBodyGyro:Destroy() end
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity  = Vector3.new(0, 0, 0)
    FlyBodyVelocity.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent    = hrp
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.P         = 9e4
    FlyBodyGyro.Parent    = hrp
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyEnabled then return end

        local char = LocalPlayer.Character
        if not char then return end
        local flyHRP = char:FindFirstChild("HumanoidRootPart")
        if not flyHRP or not FlyBodyVelocity or not FlyBodyGyro then return end
        local camera = Workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + camera.CFrame.LookVector  * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - camera.CFrame.LookVector  * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - camera.CFrame.RightVector * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + camera.CFrame.RightVector * FlySpeed end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0, FlySpeed, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, FlySpeed, 0) end
        FlyBodyVelocity.Velocity = dir
        FlyBodyGyro.CFrame       = camera.CFrame
    end)
end

local function DisableFly()
    if FlyConnection    then FlyConnection:Disconnect();    FlyConnection    = nil end
    if FlyBodyVelocity  then FlyBodyVelocity:Destroy();     FlyBodyVelocity  = nil end

    if FlyBodyGyro      then FlyBodyGyro:Destroy();         FlyBodyGyro      = nil end
end

local function EquipWeapon()

    if not SelectedWeapon then return end
    local character = LocalPlayer.Character
    if not character then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped and equipped.Name == SelectedWeapon then return end
    local weapon = backpack:FindFirstChild(SelectedWeapon)
    if weapon then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid:EquipTool(weapon) end
    end
end

local function EquipAutoWeapon()
    if not AutoEquipWeapon then return end
    local character = LocalPlayer.Character
    if not character then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped and equipped.Name == AutoEquipWeapon then return end
    local weapon = backpack:FindFirstChild(AutoEquipWeapon)
    if weapon then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid:EquipTool(weapon) end
    end
end

local function EquipDungeonWeapon()
    if not DungeonSelectedWeapon then return end
    local character = LocalPlayer.Character
    if not character then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped and equipped.Name == DungeonSelectedWeapon then return end
    local weapon = backpack:FindFirstChild(DungeonSelectedWeapon)

    if weapon then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid:EquipTool(weapon) end
    end
end

local function EquipSeaBeastWeapon()
    if not SeaBeastSelectedWeapon then return end
    local character = LocalPlayer.Character
    if not character then return end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped and equipped.Name == SeaBeastSelectedWeapon then return end

    local weapon = backpack:FindFirstChild(SeaBeastSelectedWeapon)

    if weapon then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid:EquipTool(weapon) end
    end
end

local function FindSeaBeast()
    local NPCsFolder = Workspace:FindFirstChild("NPCs")
    if not NPCsFolder then return nil end
    for _, npc in pairs(NPCsFolder:GetChildren()) do
        if npc:IsA("Model") then
            local name = npc.Name
            if string.find(name, "Kraken") or string.find(name, "Sea Serpent") then
                local hitbox = npc:FindFirstChild("SeaBeastHitbox")
                if hitbox and hitbox:IsA("BasePart") then
                    return hitbox
                end
            end
        end
    end
    return nil
end

local FACE_DOWN_CF = CFrame.Angles(math.rad(-90), 0, 0)

local function GetTargetCFrame(npcHRP)
    local pos = Vector3.new(npcHRP.Position.X, npcHRP.Position.Y + DistanceBetweenNPC, npcHRP.Position.Z)
    return CFrame.new(pos) * FACE_DOWN_CF
end

local function TeleportToIsland(island)
    TeleportToPortal(island.portalKey)

    task.wait(0.2)
end

local function FindTargetNPC()
    local hasSelection = false
    for _ in pairs(SelectedNPCs) do hasSelection = true break end
    if hasSelection then
        for npcName in pairs(SelectedNPCs) do
            local npc = FindNPC(npcName, true)
            if npc then return npc end
        end
    else
        local NPCsFolder = Workspace:FindFirstChild("NPCs")
        if NPCsFolder then
            for _, npc in pairs(NPCsFolder:GetChildren()) do
                if npc:IsA("Model") and npc.Name ~= "TrainingDummy" then
                    local isBoss = false
                    for _, bossName in ipairs(BossNames) do
                        if string.match(npc.Name, "^" .. bossName) then isBoss = true break end
                    end
                    if not isBoss then
                        local h = npc:FindFirstChild("Humanoid")
                        if h and h.Health > 0 then return npc end
                    end
                end
            end
        end
    end
    return nil
end

local function FindTargetBoss()
    local hasSelection = false
    for _ in pairs(SelectedBosses) do hasSelection = true break end
    if hasSelection then
        for bossName in pairs(SelectedBosses) do
            local npc = FindNPC(bossName, false)
            if npc then return npc end
        end
    else
        local NPCsFolder = Workspace:FindFirstChild("NPCs")
        if NPCsFolder then
            for _, npc in pairs(NPCsFolder:GetChildren()) do
                if npc:IsA("Model") and npc.Name ~= "TrainingDummy" then
                    for _, bossName in ipairs(BossNames) do
                        if string.match(npc.Name, "^" .. bossName) then
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

local function FarmNormalLoop()
    CurrentTarget = FindTargetNPC()
    if not CurrentTarget then AutoFarmEnabled = false; return end
    local walkPoint = GetNPCWalkPoint(CurrentTarget)
    if walkPoint then
        local closestIsland = FindClosestIsland(walkPoint)
        if closestIsland then TeleportToIsland(closestIsland) end
    end
    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled then
            heartbeat:Disconnect()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
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
    while AutoFarmEnabled do
        task.wait(0.05)
        if AutoFarmBossEnabled and CurrentBossTarget and IsTargetValid(CurrentBossTarget) then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then CurrentTarget = nil; continue end
        if SelectedWeapon then EquipWeapon() end
        if not CurrentTarget or not IsTargetValid(CurrentTarget) then
            CurrentTarget = FindTargetNPC()
            if CurrentTarget then
                local wp = GetNPCWalkPoint(CurrentTarget)
                if wp then
                    local island = FindClosestIsland(wp)
                    if island then TeleportToIsland(island) end
                end
            end
        end
    end
    if heartbeat then heartbeat:Disconnect() end
    local char = LocalPlayer.Character

    local hum  = char and char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end

    CurrentTarget = nil
end

local function FarmBossLoop()
    CurrentBossTarget = FindTargetBoss()
    if not CurrentBossTarget then AutoFarmBossEnabled = false; return end
    local walkPoint = GetNPCWalkPoint(CurrentBossTarget)
    if walkPoint then
        local closestIsland = FindClosestIsland(walkPoint)
        if closestIsland then TeleportToIsland(closestIsland) end
    end
    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function()
        if not AutoFarmBossEnabled then
            heartbeat:Disconnect()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
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
    while AutoFarmBossEnabled do
        task.wait(0.05)
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then CurrentBossTarget = nil; continue end
        if SelectedWeapon then EquipWeapon() end
        if not CurrentBossTarget or not IsTargetValid(CurrentBossTarget) then
            CurrentBossTarget = FindTargetBoss()
            if CurrentBossTarget then
                local wp = GetNPCWalkPoint(CurrentBossTarget)
                if wp then
                    local island = FindClosestIsland(wp)
                    if island then TeleportToIsland(island) end

                end
            end
        end
    end
    if heartbeat then heartbeat:Disconnect() end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
    CurrentBossTarget = nil
end

local function SeaBeastFarmLoop()
    local patrolIndex = 1
    local atPoint     = false
    local arrivalTime = 0
    SeaBeastPatrolTargetCF = SeaBeastPatrolPoints[1]
    SeaBeastBossTarget     = nil
    local lastTeleportedBoss = nil

    local heartbeat

    heartbeat = RunService.Heartbeat:Connect(function()
        if not AutoSeaBeastEnabled then
            heartbeat:Disconnect()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
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

        if SeaBeastBossTarget and IsTargetReady(SeaBeastBossTarget) then
            local npcHRP = SeaBeastBossTarget:FindFirstChild("HumanoidRootPart")
            if npcHRP then
                local pos = Vector3.new(npcHRP.Position.X, npcHRP.Position.Y + DistanceBetweenNPC, npcHRP.Position.Z)
                local targetCF = CFrame.new(pos) * FACE_DOWN_CF
                local dist = (hrp.Position - targetCF.Position).Magnitude
                if dist < 0.5 then hrp.CFrame = targetCF
                else
                    local alpha = math.clamp((TweenSpeed / 16) * 0.15, 0.05, 1)
                    hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
                end
            end
        elseif SeaBeastCurrentTarget and SeaBeastCurrentTarget.Parent then
            local targetPos = SeaBeastCurrentTarget.Position
            local pos = Vector3.new(targetPos.X, targetPos.Y + SeaBeastDistanceToNPC, targetPos.Z)
            local targetCF = CFrame.new(pos) * FACE_DOWN_CF
            local dist = (hrp.Position - targetCF.Position).Magnitude
            if dist < 0.5 then hrp.CFrame = targetCF
            else
                local alpha = math.clamp((SeaBeastTweenSpeed / 16) * 0.15, 0.05, 1)
                hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
            end
        elseif SeaBeastPatrolTargetCF then
            local dist = (hrp.Position - SeaBeastPatrolTargetCF.Position).Magnitude
            if dist > 5 then
                local alpha = math.clamp((SeaBeastTweenSpeed / 16) * 0.15, 0.05, 1)
                hrp.CFrame = hrp.CFrame:Lerp(SeaBeastPatrolTargetCF, alpha)
            end
        end
    end)

    task.spawn(function()
        while AutoSeaBeastEnabled do
            if SeaBeastBossTarget and IsTargetReady(SeaBeastBossTarget) then
                pcall(function()
                    ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
                end)
            elseif SeaBeastCurrentTarget and SeaBeastCurrentTarget.Parent then
                pcall(function()
                    ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
                end)
            end
            task.wait(0.1)
        end
    end)

    while AutoSeaBeastEnabled do
        task.wait(0.1)
        local char = LocalPlayer.Character
        if not char then continue end

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then
            SeaBeastCurrentTarget = nil
            SeaBeastBossTarget    = nil
            lastTeleportedBoss    = nil
            continue
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if SeaBeastBossTarget and IsTargetReady(SeaBeastBossTarget) then

            if SelectedWeapon then EquipWeapon() end
        elseif SeaBeastCurrentTarget and SeaBeastCurrentTarget.Parent then
            if SeaBeastSelectedWeapon then EquipSeaBeastWeapon() end
        else
            if SeaBeastSelectedWeapon then EquipSeaBeastWeapon() end
        end

        if SeaBeastCurrentTarget and not SeaBeastCurrentTarget.Parent then
            SeaBeastCurrentTarget = nil
        end

        if SeaBeastBossTarget and not IsTargetValid(SeaBeastBossTarget) then
            SeaBeastBossTarget = nil
            lastTeleportedBoss = nil
        end

        if AutoFarmBossEnabled then
            if not SeaBeastBossTarget then
                SeaBeastBossTarget = FindTargetBoss()
                if SeaBeastBossTarget then
                    local wp = GetNPCWalkPoint(SeaBeastBossTarget)
                    if wp then
                        local island = FindClosestIsland(wp)
                        if island then
                            lastTeleportedBoss = SeaBeastBossTarget
                            TeleportToIsland(island)
                        end
                    end
                end
            elseif SeaBeastBossTarget ~= lastTeleportedBoss then

                local wp = GetNPCWalkPoint(SeaBeastBossTarget)
                if wp then
                    local island = FindClosestIsland(wp)
                    if island then
                        lastTeleportedBoss = SeaBeastBossTarget
                        TeleportToIsland(island)
                    end
                end
            end
        else
            SeaBeastBossTarget = nil
            lastTeleportedBoss = nil
        end

        if SeaBeastBossTarget and IsTargetValid(SeaBeastBossTarget) then
            local foundSB = FindSeaBeast()
            if foundSB then

                SeaBeastCurrentTarget = foundSB
            end
            SeaBeastPatrolTargetCF = nil
            atPoint = false
        else
            SeaBeastBossTarget = nil
            lastTeleportedBoss = nil

            local foundSB = FindSeaBeast()
            if foundSB then
                SeaBeastCurrentTarget  = foundSB
                SeaBeastPatrolTargetCF = nil
                atPoint = false
            else
                SeaBeastCurrentTarget = nil
                local dest = SeaBeastPatrolPoints[patrolIndex]
                SeaBeastPatrolTargetCF = dest
                local dist = (hrp.Position - dest.Position).Magnitude
                if dist < 15 then
                    if not atPoint then
                        atPoint     = true
                        arrivalTime = tick()
                    elseif tick() - arrivalTime >= 8 then
                        patrolIndex            = patrolIndex % #SeaBeastPatrolPoints + 1
                        SeaBeastPatrolTargetCF = SeaBeastPatrolPoints[patrolIndex]
                        atPoint                = false
                        arrivalTime            = 0
                    end
                else
                    atPoint = false
                end
            end
        end
    end

    if heartbeat then heartbeat:Disconnect() end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
    SeaBeastCurrentTarget  = nil
    SeaBeastBossTarget     = nil
    SeaBeastPatrolTargetCF = nil
    lastTeleportedBoss     = nil
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if not AutoSkillEnabled then continue end
        if not (AutoFarmEnabled or AutoFarmBossEnabled or AutoSeaBeastEnabled) then continue end

        local now = tick()
        if now < SkillGlobalUnlockAt then continue end
        local fruitWeapon = GetEquippedFruitWeapon()
        for _, k in ipairs(SkillOrder) do
            if now >= SkillLastFired[k] + SkillCooldowns[k] then
                if fruitWeapon then
                    pcall(function()
                        local Ev = game:GetService("ReplicatedStorage").RemoteEvents.FruitPowerRemote
                        Ev:FireServer("UseAbility", {
                            FruitPower = fruitWeapon,
                            KeyCode = FruitSkillKeyCodes[k]
                        })
                    end)
                else
                    pcall(function()
                        local Ev = game:GetService("ReplicatedStorage").AbilitySystem.Remotes.RequestAbility
                        Ev:FireServer(SkillKeyMap[k])
                    end)
                end
                SkillLastFired[k]   = now
                SkillGlobalUnlockAt = now + 0.8
                break
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if not DungeonSkillEnabled then continue end
        if not AutoDungeonEnabled then continue end
        if not (DungeonCurrentTarget and IsTargetValid(DungeonCurrentTarget)) then continue end
        local now = tick()
        if now < DungeonSkillGlobalUnlock then continue end
        local fruitWeapon = GetEquippedFruitWeapon()
        for _, k in ipairs(SkillOrder) do
            if now >= DungeonSkillLastFired[k] + DungeonSkillCooldowns[k] then
                if fruitWeapon then
                    pcall(function()
                        local Ev = game:GetService("ReplicatedStorage").RemoteEvents.FruitPowerRemote
                        Ev:FireServer("UseAbility", {
                            FruitPower = fruitWeapon,
                            KeyCode = FruitSkillKeyCodes[k]
                        })

                    end)
                else
                    pcall(function()
                        local Ev = game:GetService("ReplicatedStorage").AbilitySystem.Remotes.RequestAbility
                        Ev:FireServer(SkillKeyMap[k])
                    end)
                end
                DungeonSkillLastFired[k]  = now
                DungeonSkillGlobalUnlock  = now + 0.8
                break
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.2)
        if not AutoHakiEnabled then continue end
        local character = LocalPlayer.Character
        if not character then continue end
        local leftArm = character:FindFirstChild("Left Arm")
        if not leftArm then continue end
        local hasParticle = leftArm:FindFirstChild("3") and leftArm:FindFirstChild("3"):IsA("ParticleEmitter")
        if not hasParticle then

            pcall(function()
                local Ev = game:GetService("ReplicatedStorage").RemoteEvents.HakiRemote
                Ev:FireServer("Toggle")
            end)
        end
    end
end)

task.spawn(function()
    local state = "idle"
    local function getCooldownFrame()
        local pg  = LocalPlayer:FindFirstChild("PlayerGui")
        local cui = pg and pg:FindFirstChild("CooldownUI")
        local mf  = cui and cui:FindFirstChild("MainFrame")
        if not mf then return nil end
        return mf:FindFirstChild("Cooldown_ObsHaki_Observation")
    end
    while true do
        task.wait(0.15)
        if not AutoObsHakiEnabled then state = "idle"; continue end
        if state == "idle" then
            if not getCooldownFrame() then
                pcall(function()
                    local Ev = game:GetService("ReplicatedStorage").RemoteEvents.ObservationHakiRemote
                    Ev:FireServer("Toggle")
                end)
                state = "waitActive"
            end
        elseif state == "waitActive" then
            if getCooldownFrame() then state = "waitExpire" end
        elseif state == "waitExpire" then
            if not getCooldownFrame() then state = "idle" end
        end
    end
end)

task.spawn(function()
    while true do
        if SelectedQuest ~= nil then
            pcall(function()
                local Ev = game:GetService("ReplicatedStorage").RemoteEvents.QuestAccept
                Ev:FireServer(SelectedQuest.npc)
            end)
            task.wait(1)
        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        if AutoStatEnabled then
            local statList = {}
            for _, s in ipairs(StatOrder) do
                if SelectedStats[s] then table.insert(statList, s) end
            end
            if #statList > 0 then
                if StatRoundRobinIndex > #statList then StatRoundRobinIndex = 1 end
                local stat = statList[StatRoundRobinIndex]
                pcall(function()
                    local Ev = game:GetService("ReplicatedStorage").RemoteEvents.AllocateStat
                    Ev:FireServer(stat, 10)
                end)
                StatRoundRobinIndex = StatRoundRobinIndex % #statList + 1
                task.wait(0.2)
            else
                task.wait(0.5)
            end

        else
            task.wait(0.5)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")

            if humanoid then
                if humanoid.WalkSpeed ~= WalkSpeed then humanoid.WalkSpeed = WalkSpeed end
                if humanoid.JumpHeight ~= JumpHeight then humanoid.JumpHeight = JumpHeight end
            end

        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not KillAuraEnabled then continue end
        pcall(function()
            ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()

        end)
    end
end)

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

local function AutoDungeonLoop()
    local isHandlingLevers = false

    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function()
        if not AutoDungeonEnabled then
            heartbeat:Disconnect()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = false end
            return
        end
        if isHandlingLevers then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hum.PlatformStand = true
        if DungeonCurrentTarget and IsTargetValid(DungeonCurrentTarget) then
            local targetPart = nil
            if DungeonCurrentTarget.Name == "MinoBoss" then
                targetPart = DungeonCurrentTarget:FindFirstChild("MinoBossHitbox")
            end
            if not targetPart then
                targetPart = DungeonCurrentTarget:FindFirstChild("HumanoidRootPart")
            end
            if targetPart then
                local pos = Vector3.new(targetPart.Position.X, targetPart.Position.Y + DungeonDistance, targetPart.Position.Z)
                local targetCF = CFrame.new(pos) * FACE_DOWN_CF
                local dist = (hrp.Position - targetCF.Position).Magnitude
                if dist < 0.5 then hrp.CFrame = targetCF
                else
                    local alpha = math.clamp((DungeonTweenSpeed / 16) * 0.15, 0.05, 1)
                    hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
                end
            end
        end
    end)

    task.spawn(function()
        while AutoDungeonEnabled do
            if not isHandlingLevers and DungeonCurrentTarget and IsTargetValid(DungeonCurrentTarget) then
                pcall(function()
                    ReplicatedStorage:WaitForChild("CombatSystem"):WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
                end)
            end
            task.wait(0.1)
        end
    end)

    task.spawn(function()
        while AutoDungeonEnabled do
            task.wait(0.1)
            if isHandlingLevers then continue end
            if not (DungeonCurrentTarget and DungeonCurrentTarget.Name == "MinoBoss" and IsTargetValid(DungeonCurrentTarget)) then continue end

            local levers = {}
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("MeshPart") and obj.Name == "MinoBossLever" then
                    table.insert(levers, obj)
                end
            end
            if #levers == 0 then continue end

            isHandlingLevers = true

            for _, lever in ipairs(levers) do
                if not AutoDungeonEnabled then break end
                if not lever.Parent then continue end

                local leverPos = lever.Position
                local arrived  = false

                while AutoDungeonEnabled and not arrived do
                    if not lever.Parent then arrived = true; break end
                    local c = LocalPlayer.Character
                    if not c then break end
                    local hrp2 = c:FindFirstChild("HumanoidRootPart")
                    if not hrp2 then break end
                    local hum2 = c:FindFirstChild("Humanoid")
                    if hum2 then hum2.PlatformStand = true end
                    local targetCF = CFrame.new(leverPos)
                    local dist = (hrp2.Position - targetCF.Position).Magnitude

                    if dist < 2 then
                        hrp2.CFrame = targetCF
                        arrived = true
                    else
                        local alpha = math.clamp((DungeonTweenSpeed / 16) * 0.15, 0.05, 1)
                        hrp2.CFrame = hrp2.CFrame:Lerp(targetCF, alpha)
                    end
                    task.wait()
                end

                if arrived and lever.Parent then
                    local prompt = lever:FindFirstChild("PullLeverPrompt")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                    end

                    while AutoDungeonEnabled and lever.Parent do
                        local c = LocalPlayer.Character
                        if not c then break end

                        local hrp2 = c:FindFirstChild("HumanoidRootPart")
                        if not hrp2 then break end
                        local hum2 = c:FindFirstChild("Humanoid")
                        if hum2 then hum2.PlatformStand = true end
                        hrp2.CFrame = CFrame.new(leverPos)

                        prompt = lever:FindFirstChild("PullLeverPrompt")
                        if prompt and prompt:IsA("ProximityPrompt") then
                            prompt.HoldDuration = 0
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                        task.wait()
                    end
                end
            end

            isHandlingLevers = false
        end
    end)

    while AutoDungeonEnabled do
        task.wait(0.05)
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then DungeonCurrentTarget = nil; continue end
        local charHRP = char:FindFirstChild("HumanoidRootPart")
        if not charHRP then continue end
        if DungeonSelectedWeapon then EquipDungeonWeapon() end

        if not DungeonCurrentTarget or not IsTargetValid(DungeonCurrentTarget) then
            DungeonCurrentTarget = nil
            local NPCsFolder = Workspace:FindFirstChild("NPCs")
            if NPCsFolder then
                for _, npc in pairs(NPCsFolder:GetChildren()) do
                    if npc:IsA("Model") then
                        if npc.Name == "MinoBoss" then
                            local hitbox = npc:FindFirstChild("MinoBossHitbox")
                            if hitbox then
                                DungeonCurrentTarget = npc
                                break
                            end
                        else
                            local h      = npc:FindFirstChild("Humanoid")
                            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                            if h and npcHRP and h.Health > 0 then
                                DungeonCurrentTarget = npc
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    if heartbeat then heartbeat:Disconnect() end
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = false end
    DungeonCurrentTarget = nil
end

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ServiceNPCESP"
ESPFolder.Parent = Workspace.CurrentCamera

local ESPObjects = {}

local function RemoveAllESP()
    for model, obj in pairs(ESPObjects) do
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
        if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
    end

    ESPObjects = {}
end

local function CreateESPForModel(model)
    if ESPObjects[model] then return end
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart
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
    billboard.Size = UDim2.new(0, 140, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = rootPart
    billboard.Parent = Workspace.CurrentCamera
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.52, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
    nameLabel.TextStrokeTransparency = 0.35
    nameLabel.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = model.Name
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
    ESPObjects[model] = { highlight = highlight, billboard = billboard, distLabel = distLabel, rootPart = rootPart }
end

RunService.Heartbeat:Connect(function()
    if not ServiceNPCESPEnabled then return end
    local character = LocalPlayer.Character
    local charHRP = character and character:FindFirstChild("HumanoidRootPart")
    local serviceFolder = Workspace:FindFirstChild("ServiceNPCs")
    local activeModels = {}
    if serviceFolder then
        for _, model in pairs(serviceFolder:GetChildren()) do
            if model:IsA("Model") and not string.match(model.Name, "^Spot") then
                activeModels[model] = true
            end
        end
    end
    for model in pairs(activeModels) do
        if not ESPObjects[model] then CreateESPForModel(model) end
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
        for model, entry in pairs(ESPObjects) do
            if entry.rootPart and entry.rootPart.Parent then
                local dist = math.floor((charHRP.Position - entry.rootPart.Position).Magnitude)
                entry.distLabel.Text = dist .. " m"
            end
        end
    end
end)

local EggMapESPObjects = {}

local function RemoveAllEggMapESP()
    for part, obj in pairs(EggMapESPObjects) do
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
        if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
    end
    EggMapESPObjects = {}
end

local function CreateEggMapESPForPart(part, displayName)
    if EggMapESPObjects[part] then return end
    if not part or not part.Parent then return end
    local highlight = Instance.new("SelectionBox")
    highlight.Color3 = Color3.fromRGB(120, 80, 255)
    highlight.LineThickness = 0.07
    highlight.SurfaceTransparency = 0.85
    highlight.SurfaceColor3 = Color3.fromRGB(120, 80, 255)
    highlight.Adornee = part
    highlight.Parent = Workspace.CurrentCamera
    local billboard = Instance.new("BillboardGui")
    billboard.AlwaysOnTop = true

    billboard.Size = UDim2.new(0, 140, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Adornee = part
    billboard.Parent = Workspace.CurrentCamera
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.52, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(200, 170, 255)
    nameLabel.TextStrokeTransparency = 0.35
    nameLabel.TextStrokeColor3 = Color3.fromRGB(20, 5, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = displayName or part.Name
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
    EggMapESPObjects[part] = { highlight = highlight, billboard = billboard, distLabel = distLabel }
end

RunService.Heartbeat:Connect(function()
    if not EggMapESPEnabled then return end

    local character = LocalPlayer.Character
    local charHRP   = character and character:FindFirstChild("HumanoidRootPart")
    local activeParts = {}
    local eggFolder = Workspace:FindFirstChild("EasterEggs")
    if eggFolder then
        for _, child in pairs(eggFolder:GetDescendants()) do
            if child:IsA("MeshPart") and not string.match(child.Name, "^Spot") then
                activeParts[child] = { displayName = "Easter Egg" }
            end
        end
    end
    local mapFolder = Workspace:FindFirstChild("Sea2MapQuest")
    if mapFolder then
        for _, child in pairs(mapFolder:GetDescendants()) do
            if child:IsA("Part") and not string.match(child.Name, "^Spot") then
                activeParts[child] = { displayName = child.Name }
            end
        end
    end
    for part, info in pairs(activeParts) do
        if not EggMapESPObjects[part] then CreateEggMapESPForPart(part, info.displayName) end
    end
    local toRemove = {}
    for part in pairs(EggMapESPObjects) do
        if not activeParts[part] or not part.Parent then table.insert(toRemove, part) end
    end
    for _, part in ipairs(toRemove) do
        local obj = EggMapESPObjects[part]
        if obj.highlight and obj.highlight.Parent then obj.highlight:Destroy() end
        if obj.billboard and obj.billboard.Parent then obj.billboard:Destroy() end
        EggMapESPObjects[part] = nil
    end
    if charHRP then
        for part, entry in pairs(EggMapESPObjects) do
            if part.Parent then
                local dist = math.floor((charHRP.Position - part.Position).Magnitude)
                entry.distLabel.Text = dist .. " m"
            end
        end
    end
end)

local Window = Library:CreateWindow({
    Title = "  Symbiote ",
    Size  = UDim2.new(0, 580, 0, 440),
})

local PlayerTab     = Window:CreateTab("Player")
local AutoFarmTab   = Window:CreateTab("Auto Farm")
local SeaBeastsTab  = Window:CreateTab("SeaBeasts")
local BossSpawnTab  = Window:CreateTab("Boss Spawn")
local DungeonTab    = Window:CreateTab("Auto Farm\nWorlds")
local ServiceTab    = Window:CreateTab("Service NPCs")

local function StopAllFarmsExcept(except)

    if except ~= "normal"   then AutoFarmEnabled     = false; CurrentTarget        = nil end
    if except ~= "boss"     then AutoFarmBossEnabled = false; CurrentBossTarget    = nil end
    if except ~= "dungeon"  then AutoDungeonEnabled  = false; DungeonCurrentTarget = nil end
    if except ~= "seabeast" then
        AutoSeaBeastEnabled    = false
        SeaBeastCurrentTarget  = nil
        SeaBeastBossTarget     = nil
        SeaBeastPatrolTargetCF = nil
    end
end

PlayerTab:AddSlider("Walk Speed", 16, 500, 16, function(v)
    WalkSpeed = v
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = v end
    end
end)

PlayerTab:AddSlider("Jump Height", 50, 200, 50, function(v)
    JumpHeight = v
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.JumpHeight = v end
    end
end)

PlayerTab:AddToggle("Fly", function(state)
    FlyEnabled = state
    if state then EnableFly() else DisableFly() end
end)

PlayerTab:AddSlider("Fly Speed", 50, 200, 50, function(v) FlySpeed = v end)

PlayerTab:AddToggle("NoClip", function(state)
    NoClipEnabled = state
    if state then EnableNoClip() else DisableNoClip() end
end)

PlayerTab:AddToggle("Auto Haki", function(state) AutoHakiEnabled = state end)
PlayerTab:AddToggle("Auto Observation Haki", function(state) AutoObsHakiEnabled = state end)
PlayerTab:AddToggle("Kill Aura", function(state) KillAuraEnabled = state end)
PlayerTab:AddToggle("Auto Ascend", function(state) AutoAscendEnabled = state end)

local teleportOptions = {}
for _, island in ipairs(IslandPositions) do table.insert(teleportOptions, island.name) end
local teleportDropdownRef
teleportDropdownRef = PlayerTab:AddDropdown("Teleport To", teleportOptions, function(selected)
    for islandName in pairs(selected) do
        for _, island in ipairs(IslandPositions) do
            if island.name == islandName then TeleportToPortal(island.portalKey); break end
        end
        break
    end
    task.defer(function() teleportDropdownRef:ClearSelection() end)
end)

PlayerTab:AddToggle("Auto Stat", function(state)
    AutoStatEnabled = state; StatRoundRobinIndex = 1
end)

PlayerTab:AddDropdown("Select Stat", {"Melee", "Sword", "Defense", "Power"}, function(selected)
    SelectedStats = {}; StatRoundRobinIndex = 1
    for statName in pairs(selected) do SelectedStats[statName] = true end
end)

do
    local autoEquipWeaponOptions = {}
    for _, w in ipairs(WeaponNames) do table.insert(autoEquipWeaponOptions, w) end
    local autoEquipSelecting = false
    local autoEquipDropdownRef
    autoEquipDropdownRef = PlayerTab:AddDropdown("Auto Equip Weapon", autoEquipWeaponOptions, function(selected)
        if autoEquipSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then AutoEquipWeapon = nil; return end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do if k ~= AutoEquipWeapon then chosen = k break end end
            chosen = chosen or keys[1]
            autoEquipSelecting = true; autoEquipDropdownRef:ClearSelection(); autoEquipSelecting = false
        end
        AutoEquipWeapon = chosen
    end)
end

local weaponOptions = {}
for _, w in ipairs(WeaponNames) do table.insert(weaponOptions, w) end
local weaponDropdownRef
local weaponSelecting = false
weaponDropdownRef = AutoFarmTab:AddDropdown("Select Weapon", weaponOptions, function(selected)
    if weaponSelecting then return end
    local keys = {}
    for k in pairs(selected) do table.insert(keys, k) end
    if #keys == 0 then SelectedWeapon = nil; return end
    local chosen
    if #keys == 1 then chosen = keys[1]
    else
        for _, k in ipairs(keys) do if k ~= SelectedWeapon then chosen = k break end end
        chosen = chosen or keys[1]
    end
    local backpack  = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character

    local has = (backpack and backpack:FindFirstChild(chosen)) or (character and character:FindFirstChild(chosen))
    local newWeapon = has and chosen or nil
    if #keys > 1 then
        weaponSelecting = true; weaponDropdownRef:ClearSelection(); weaponSelecting = false
        SelectedWeapon = newWeapon
    else
        SelectedWeapon = newWeapon
    end
end)

AutoFarmTab:AddSlider("Distance To NPC (studs)", 5, 50, 5, function(v) DistanceBetweenNPC = v end)

AutoFarmTab:AddToggle("Auto Skill", function(state) AutoSkillEnabled = state end)
AutoFarmTab:AddSlider("Z Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.Z = v end)
AutoFarmTab:AddSlider("X Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.X = v end)
AutoFarmTab:AddSlider("C Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.C = v end)
AutoFarmTab:AddSlider("V Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.V = v end)
AutoFarmTab:AddSlider("F Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.F = v end)

local questOptions = {}
for _, q in ipairs(QuestNames) do table.insert(questOptions, q.name) end
AutoFarmTab:AddDropdown("Auto Quest", questOptions, function(selected)
    local count = 0
    for _ in pairs(selected) do count = count + 1 end
    if count == 0 then SelectedQuest = nil; return end
    for questName in pairs(selected) do
        for _, q in ipairs(QuestNames) do
            if q.name == questName then SelectedQuest = q break end
        end
        break
    end
end)

AutoFarmTab:AddToggle("Auto Farm", function(state)
    if state then
        if AutoFarmBossEnabled or AutoDungeonEnabled or AutoSeaBeastEnabled then AutoFarmEnabled = false; return end
        StopAllFarmsExcept("normal")
        AutoFarmEnabled = true
        task.spawn(FarmNormalLoop)
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
        if AutoFarmEnabled or AutoDungeonEnabled then AutoFarmBossEnabled = false; return end
        if AutoSeaBeastEnabled then
            AutoFarmBossEnabled = true
            return
        end
        StopAllFarmsExcept("boss")
        AutoFarmBossEnabled = true
        task.spawn(FarmBossLoop)

    else
        AutoFarmBossEnabled   = false
        CurrentBossTarget     = nil
        SeaBeastBossTarget    = nil
    end
end)

local bossOptions = {}
for _, b in ipairs(BossNames) do table.insert(bossOptions, b) end
AutoFarmTab:AddDropdown("Select Boss", bossOptions, function(selected)
    SelectedBosses = {}
    for bossName in pairs(selected) do SelectedBosses[bossName] = true end
end)

do
    local sbWeaponOptions = {}
    for _, w in ipairs(WeaponNames) do table.insert(sbWeaponOptions, w) end
    local sbWeaponSelecting = false
    local sbWeaponDropdownRef
    sbWeaponDropdownRef = SeaBeastsTab:AddDropdown("Select Weapon", sbWeaponOptions, function(selected)
        if sbWeaponSelecting then return end
        local keys = {}
        for k in pairs(selected) do table.insert(keys, k) end
        if #keys == 0 then SeaBeastSelectedWeapon = nil; return end
        local chosen
        if #keys == 1 then chosen = keys[1]
        else
            for _, k in ipairs(keys) do if k ~= SeaBeastSelectedWeapon then chosen = k break end end
            chosen = chosen or keys[1]
            sbWeaponSelecting = true; sbWeaponDropdownRef:ClearSelection(); sbWeaponSelecting = false
        end
        local backpack  = LocalPlayer:FindFirstChild("Backpack")
        local character = LocalPlayer.Character
        local has = (backpack and backpack:FindFirstChild(chosen)) or (character and character:FindFirstChild(chosen))
        SeaBeastSelectedWeapon = has and chosen or nil
    end)
end

SeaBeastsTab:AddSlider("Distance To NPC (studs)", 5, 200, 5, function(v) SeaBeastDistanceToNPC = v end)
SeaBeastsTab:AddToggle("Auto Skill", function(state) AutoSkillEnabled = state end)
SeaBeastsTab:AddSlider("Z Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.Z = v end)
SeaBeastsTab:AddSlider("X Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.X = v end)
SeaBeastsTab:AddSlider("C Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.C = v end)
SeaBeastsTab:AddSlider("V Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.V = v end)
SeaBeastsTab:AddSlider("F Skill Cooldown (s)", 3, 45, 5, function(v) SkillCooldowns.F = v end)

local seaBeastToggleRow = SeaBeastsTab:AddToggle("Auto Find & Farm SeaBeasts", function(state)
    if state then
        if AutoFarmEnabled or AutoDungeonEnabled then AutoSeaBeastEnabled = false; return end

        if AutoFarmBossEnabled then
            AutoFarmBossEnabled = false
            CurrentBossTarget   = nil
        end
        AutoFarmEnabled  = false; CurrentTarget = nil
        AutoDungeonEnabled = false; DungeonCurrentTarget = nil
        AutoSeaBeastEnabled = true
        task.spawn(SeaBeastFarmLoop)
    else

        AutoSeaBeastEnabled    = false
        SeaBeastCurrentTarget  = nil
        SeaBeastBossTarget     = nil
        SeaBeastPatrolTargetCF = nil
    end
end)

do
    local row = seaBeastToggleRow and seaBeastToggleRow.Row
    if row then

        local questionBtn = Instance.new("TextButton")
        questionBtn.Size = UDim2.new(0, 22, 0, 22)
        questionBtn.Position = UDim2.new(1, -100, 0.5, -11)
        questionBtn.BackgroundColor3 = Color3.fromRGB(55, 42, 90)
        questionBtn.TextColor3 = Color3.fromRGB(200, 170, 255)
        questionBtn.Font = Enum.Font.GothamBold
        questionBtn.TextSize = 13
        questionBtn.Text = "?"
        questionBtn.AutoButtonColor = false
        questionBtn.ZIndex = 10
        questionBtn.Parent = row
        local qCorner = Instance.new("UICorner")
        qCorner.CornerRadius = UDim.new(1, 0)
        qCorner.Parent = questionBtn

        local screenGui = Window.ScreenGui
        local sbTooltip = Instance.new("TextLabel")
        sbTooltip.Size = UDim2.new(0, 240, 0, 36)
        sbTooltip.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
        sbTooltip.TextColor3 = Color3.fromRGB(220, 200, 255)
        sbTooltip.Font = Enum.Font.Gotham
        sbTooltip.TextSize = 11
        sbTooltip.Text = "You need at least 500K bounty to let SeaBeasts spawn"
        sbTooltip.TextWrapped = true
        sbTooltip.Visible = false
        sbTooltip.ZIndex = 100
        sbTooltip.Parent = screenGui
        local tCorner = Instance.new("UICorner"); tCorner.CornerRadius = UDim.new(0, 6); tCorner.Parent = sbTooltip
        local tStroke = Instance.new("UIStroke"); tStroke.Color = Color3.fromRGB(90, 60, 150); tStroke.Thickness = 1; tStroke.Parent = sbTooltip
        local tPad = Instance.new("UIPadding")
        tPad.PaddingLeft = UDim.new(0, 6); tPad.PaddingRight = UDim.new(0, 6)
        tPad.PaddingTop = UDim.new(0, 4);  tPad.PaddingBottom = UDim.new(0, 4)
        tPad.Parent = sbTooltip
        local function updateTooltipPos()
            local abs = questionBtn.AbsolutePosition; local sz = questionBtn.AbsoluteSize
            sbTooltip.Position = UDim2.new(0, abs.X - 245, 0, abs.Y + sz.Y + 4)
        end
        questionBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                updateTooltipPos(); sbTooltip.Visible = true
            end
        end)
        questionBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then

                sbTooltip.Visible = false
            end
        end)
        questionBtn.MouseButton1Click:Connect(function()
            updateTooltipPos(); sbTooltip.Visible = not sbTooltip.Visible
        end)
    end
end

BossSpawnTab:AddToggle("Auto Boss Spawn", function(state) AutoBossSpawnEnabled = state end)

local spawnBossNames = {}
for _, d in ipairs(SpawnBossData) do table.insert(spawnBossNames, d.name) end
local spawnBossSelecting = false
local spawnBossDropdownRef
spawnBossDropdownRef = BossSpawnTab:AddDropdown("Select Boss to Spawn", spawnBossNames, function(selected)
    if spawnBossSelecting then return end
    local keys = {}
    for k in pairs(selected) do table.insert(keys, k) end
    if #keys == 0 then SelectedSpawnBoss = nil; return end
    local chosen
    if #keys == 1 then chosen = keys[1]
    else
        for _, k in ipairs(keys) do
            if not SelectedSpawnBoss or k ~= SelectedSpawnBoss.name then chosen = k break end
        end
        chosen = chosen or keys[1]
        spawnBossSelecting = true; spawnBossDropdownRef:ClearSelection(); spawnBossSelecting = false
    end
    for _, d in ipairs(SpawnBossData) do
        if d.name == chosen then SelectedSpawnBoss = d break end
    end
end)

BossSpawnTab:AddSlider("Spawn Frequency (s)", 3, 60, 10, function(v) SpawnFrequency = v end)

local dungeonToggleRow = DungeonTab:AddToggle("Auto Farm Worlds", function(state)
    if state then
        if AutoFarmEnabled or AutoFarmBossEnabled or AutoSeaBeastEnabled then AutoDungeonEnabled = false; return end
        StopAllFarmsExcept("dungeon")
        AutoDungeonEnabled = true
        task.spawn(AutoDungeonLoop)
    else
        AutoDungeonEnabled = false; DungeonCurrentTarget = nil
    end
end)

do
    local row = dungeonToggleRow and dungeonToggleRow.Row
    if row then
        local questionBtn = Instance.new("TextButton")
        questionBtn.Size = UDim2.new(0, 22, 0, 22)
        questionBtn.Position = UDim2.new(1, -100, 0.5, -11)
        questionBtn.BackgroundColor3 = Color3.fromRGB(55, 42, 90)
        questionBtn.TextColor3 = Color3.fromRGB(200, 170, 255)
        questionBtn.Font = Enum.Font.GothamBold
        questionBtn.TextSize = 13
        questionBtn.Text = "?"
        questionBtn.AutoButtonColor = false
        questionBtn.ZIndex = 10
        questionBtn.Parent = row
        local qCorner = Instance.new("UICorner"); qCorner.CornerRadius = UDim.new(1, 0); qCorner.Parent = questionBtn
        local screenGui = Window.ScreenGui
        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, 210, 0, 36)
        tooltip.BackgroundColor3 = Color3.fromRGB(20, 15, 35)
        tooltip.TextColor3 = Color3.fromRGB(220, 200, 255)
        tooltip.Font = Enum.Font.Gotham
        tooltip.TextSize = 11
        tooltip.Text = "You have to enter dungeon/tower/crys defense/raid first"
        tooltip.TextWrapped = true
        tooltip.Visible = false
        tooltip.ZIndex = 100
        tooltip.Parent = screenGui
        local tCorner = Instance.new("UICorner"); tCorner.CornerRadius = UDim.new(0, 6); tCorner.Parent = tooltip
        local tStroke = Instance.new("UIStroke"); tStroke.Color = Color3.fromRGB(90, 60, 150); tStroke.Thickness = 1; tStroke.Parent = tooltip
        local tPad = Instance.new("UIPadding")
        tPad.PaddingLeft = UDim.new(0, 6); tPad.PaddingRight = UDim.new(0, 6)
        tPad.PaddingTop = UDim.new(0, 4);  tPad.PaddingBottom = UDim.new(0, 4)
        tPad.Parent = tooltip
        local function updateTooltipPos()
            local abs = questionBtn.AbsolutePosition; local sz = questionBtn.AbsoluteSize
            tooltip.Position = UDim2.new(0, abs.X - 215, 0, abs.Y + sz.Y + 4)
        end
        questionBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                updateTooltipPos(); tooltip.Visible = true
            end
        end)
        questionBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                tooltip.Visible = false
            end
        end)
        questionBtn.MouseButton1Click:Connect(function()
            updateTooltipPos(); tooltip.Visible = not tooltip.Visible
        end)
    end
end

local dungeonWeaponOptions = {}
for _, w in ipairs(WeaponNames) do table.insert(dungeonWeaponOptions, w) end
local dungeonWeaponSelecting = false
local dungeonWeaponDropdownRef
dungeonWeaponDropdownRef = DungeonTab:AddDropdown("Select Weapon", dungeonWeaponOptions, function(selected)
    if dungeonWeaponSelecting then return end
    local keys = {}
    for k in pairs(selected) do table.insert(keys, k) end
    if #keys == 0 then DungeonSelectedWeapon = nil; return end
    local chosen
    if #keys == 1 then chosen = keys[1]
    else
        for _, k in ipairs(keys) do if k ~= DungeonSelectedWeapon then chosen = k break end end

        chosen = chosen or keys[1]
        dungeonWeaponSelecting = true; dungeonWeaponDropdownRef:ClearSelection(); dungeonWeaponSelecting = false
    end
    local backpack  = LocalPlayer:FindFirstChild("Backpack")
    local character = LocalPlayer.Character
    local has = (backpack and backpack:FindFirstChild(chosen)) or (character and character:FindFirstChild(chosen))
    DungeonSelectedWeapon = has and chosen or nil
end)

DungeonTab:AddSlider("Distance To NPC (studs)", 5, 50, 5, function(v) DungeonDistance = v end)
DungeonTab:AddToggle("Auto Skill", function(state) DungeonSkillEnabled = state end)
DungeonTab:AddSlider("Z Skill Cooldown (s)", 3, 45, 5, function(v) DungeonSkillCooldowns.Z = v end)
DungeonTab:AddSlider("X Skill Cooldown (s)", 3, 45, 5, function(v) DungeonSkillCooldowns.X = v end)
DungeonTab:AddSlider("C Skill Cooldown (s)", 3, 45, 5, function(v) DungeonSkillCooldowns.C = v end)
DungeonTab:AddSlider("V Skill Cooldown (s)", 3, 45, 5, function(v) DungeonSkillCooldowns.V = v end)
DungeonTab:AddSlider("F Skill Cooldown (s)", 3, 45, 5, function(v) DungeonSkillCooldowns.F = v end)

local OpenUIItems = {
    "Open Teleport UI", "Open Ascend UI", "Open Artifact Mastery UI", "Open Merchant UI",

    "Open Stat Reroll UI", "Open Trait Reroll UI", "Open Boss Rush Merchant UI", "Open Boss Rush UI",
    "Open Boss Rush Upgrades UI", "Open Enchant UI", "Open Bless UI", "Open Summon Boss UI",
    "Open Dungeon UI", "Open Dungeon Merchant UI", "Open Skill Tree UI", "Open Infinite Tower UI",
    "Open Infinite Tower Merchant UI", "Open Easter Shop UI", "Open Easter Merchant UI", "Open Guild UI",
    "Open Raid UI", "Open Raid Merchant UI", "Open Index UI",
}

local function FireOpenUI(name)
    pcall(function()
        if name == "Open Ascend UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.OpenAscendUI.OnClientEvent)
        elseif name == "Open Teleport UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenTeleportUI.OnClientEvent, "Starter")
        elseif name == "Open Artifact Mastery UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.ArtifactMilestoneOpenUI.OnClientEvent)
        elseif name == "Open Merchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.MerchantRemotes.OpenMerchantUI.OnClientEvent)
        elseif name == "Open Stat Reroll UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.OpenStatRerollUI.OnClientEvent)
        elseif name == "Open Trait Reroll UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.OpenTraitUI.OnClientEvent)
        elseif name == "Open Boss Rush Merchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.BossRushMerchantRemotes.OpenBossRushMerchantUI.OnClientEvent)
        elseif name == "Open Boss Rush UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenBossRushUI.OnClientEvent)
        elseif name == "Open Boss Rush Upgrades UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.OpenBossRushShop.OnClientEvent)
        elseif name == "Open Enchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenEnchantUI.OnClientEvent)
        elseif name == "Open Bless UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenBlessingUI.OnClientEvent)
        elseif name == "Open Summon Boss UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenSummonUI.OnClientEvent, "IchigoBoss")
        elseif name == "Open Dungeon UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenDungeonUI.OnClientEvent)
        elseif name == "Open Dungeon Merchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.DungeonMerchantRemotes.OpenDungeonMerchantUI.OnClientEvent)
        elseif name == "Open Skill Tree UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.OpenSkillTreeUI.OnClientEvent)
        elseif name == "Open Infinite Tower UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenInfiniteTowerUI.OnClientEvent)
        elseif name == "Open Infinite Tower Merchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.InfiniteTowerMerchantRemotes.OpenInfiniteTowerMerchantUI.OnClientEvent)
        elseif name == "Open Easter Shop UI" then firesignal(game:GetService("ReplicatedStorage").RemoteEvents.OpenEasterShop.OnClientEvent)
        elseif name == "Open Easter Merchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.EasterMerchantRemotes.OpenEasterMerchantUI.OnClientEvent)
        elseif name == "Open Guild UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.GuildRemotes.OpenGuildUI.OnClientEvent)
        elseif name == "Open Raid UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenRaidUI.OnClientEvent)
        elseif name == "Open Raid Merchant UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.RaidMerchantRemotes.OpenRaidMerchantUI.OnClientEvent)
        elseif name == "Open Index UI" then firesignal(game:GetService("ReplicatedStorage").Remotes.OpenIndexUI.OnClientEvent)
        end
    end)
end

local openUIDropdownRef
openUIDropdownRef = ServiceTab:AddDropdown("Open UI", OpenUIItems, function(selected)
    for itemName in pairs(selected) do FireOpenUI(itemName); break end
    task.defer(function() openUIDropdownRef:ClearSelection() end)
end)

ServiceTab:AddToggle("Service NPC ESP", function(state)
    ServiceNPCESPEnabled = state
    if not state then RemoveAllESP() end
end)

ServiceTab:AddToggle("Egg & Map Piece ESP", function(state)
    EggMapESPEnabled = state
    if not state then RemoveAllEggMapESP() end
end)

local TalkNPCItems = {
    "Talk To Shadow Master", "Talk To Shadow Monarch Master", "Talk To Dragon Slayer Master",
    "Talk To Slime(Rimuru) Master", "Talk To Atomic Master", "Talk To Cosmic Being Master",
}

local function FireTalkNPC(name)
    pcall(function()
        local Ev = game:GetService("ReplicatedStorage").RemoteEvents.QuestAccept
        if name == "Talk To Shadow Master" then Ev:FireServer("ShadowQuestlineBuff")
        elseif name == "Talk To Shadow Monarch Master" then Ev:FireServer("ShadowMonarchQuestlineBuff")
        elseif name == "Talk To Dragon Slayer Master" then Ev:FireServer("RagnaQuestlineBuff")
        elseif name == "Talk To Slime(Rimuru) Master" then Ev:FireServer("RimuruMasteryNPC")
        elseif name == "Talk To Atomic Master" then Ev:FireServer("AtomicQuestlineBuff")
        elseif name == "Talk To Cosmic Being Master" then Ev:FireServer("CosmicBeingFMove")
        end
    end)
end

local talkNPCDropdownRef
talkNPCDropdownRef = ServiceTab:AddDropdown("Talk To NPC", TalkNPCItems, function(selected)
    for itemName in pairs(selected) do FireTalkNPC(itemName); break end
    task.defer(function() talkNPCDropdownRef:ClearSelection() end)
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})