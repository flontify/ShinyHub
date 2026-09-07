-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Elementalism
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

local Library = createSymbioteShim("Elementalism")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Event = ReplicatedStorage.EventsAndFunctions.Notify
for _, v in pairs(getconnections(Event.OnClientEvent)) do
    v.Function("Symbiote", "WorldEvent")
end

local S = {
    WeaponNames = {
        "Basic Combat","Ironfist","Boxing","Capoeira",
        "Barkwhisper","Dawnsworm","Embergrief","Gravemourn","Oathbreak","Ruinspire",
        "Soulcleaver","Steelthorn","Stellavorne","Sunfang","Thurin","Whisperfang","Winterbite",
        "Combustion","Air","Fire","Earth","Water"
    },
    NPCNames = {"Bandit","EarthBandit","AirBandit","WaterBandit","FireBandit","Ninja"},
    BossNames = {"Voltrex","Ferron","Aureth","Farreth","Viridian","Ignus","Arenox","Magmus","Dusk", "Exibel"},
    FoodNames = {"Apple","Banana","Coconut","Pumpkin","Watermelon","Blue Berry","Steak On A Stick"},
    ignoredActions = {SelectUp=true, SelectDown=true, SelectedAction=true},

    AutoFarmEnabled=false, AutoFarmBossEnabled=false,
    FlyEnabled=false, NoClipEnabled=false,
    SelectedNPCs={}, SelectedBosses={},
    SelectedWeapon=nil, AutoEquipWeapon=nil,
    CurrentTarget=nil, CurrentBossTarget=nil,
    DistanceBetweenNPC=5, TweenSpeed=20, FlySpeed=50,
    NoClipConn=nil, FlyConn=nil, FlyBV=nil, FlyBG=nil,
    ServiceNPCESP=false, MeditateIfNoTarget=false, IsMeditating=false,

    FarmAutoSkill=false, FarmSkillCD=2,
    PlayerAutoSkill=false, PlayerSkillCD=2,
    FarmSkills={}, PlayerSkills={},

    AutoCollect=false, CollectItems={}, CollectTweenSpd=20, CollectBusy=false,

    skillList={}, FarmSkillDDRef=nil, PlayerSkillDDRef=nil, CollectDDRef=nil,

    PlayerESP=false, PlayerESPObjs={},
    ESPLines=false, ESPLineObjs={},
    ShowECM=false, ShowEqStats=false, ShowLoc=false,
    InfoCache={},

    OrbitEnabled=false, OrbitTarget=nil, OrbitSpeed=1,

    OrbitDist=10, OrbitAngle=0, OrbitConn=nil, OrbitDDRef=nil,
    TPBehindOrbit=false,
    OrbitTweenSpeed=20,

    TPSafeEnabled=false, TPSafeConn=nil,
    IsKnockedSafe=false, KnockedSafePos=nil, KnockedReturnPos=nil,

    CooldownGui=nil, CooldownRich=nil, CooldownTitle=nil,

    NoRagdoll=false,
    NoRagdollConn=nil,

    NoDashCD=false,
    NoDashCDConns={},

    AvoidDebuffs=false,
    AvoidDebuffsConns={},

    SpectateEnabled=false, SpectateTarget=nil, SpectateDDRef=nil, lastSpectatePlayers={},
    LockCamera=false,
    InfiniteJump=false, InfiniteJumpConn=nil,
    AutoEat=false, SelectedFoods={}, AutoEatBusy=false,
    AutoQuest=nil,

    WalkSpeedEnabled=false, WalkSpeedVal=5, WalkSpeedSmooth=0.5, WalkSpeedConn=nil,
    LaggyRun=false, LaggyDist=1, LaggyDelay=1, LaggyConn=nil, LaggyAccum=0,
    AutoFish=false, FishTweenSpd=20,

    TPPlaceSpeed=20,
    NPCTPSpeed=20,

    ServiceNPCDDRef=nil, lastServiceNPCNames={}, lastOrbitPlayers={},
    ESPObjs={}, ESPLinesGui=nil,

    ActiveTweens = {},
    TweenAntiGravConn = nil,
    TweenAntiGravBV   = nil,
    TweenCount        = 0,

    FarmBV  = nil,
    FarmBG  = nil,
}

local function _EnsureNoClip()
    local ch = LocalPlayer.Character; if not ch then return end
    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end

local function _CleanupNoClipAfterTween()
    if S.NoClipEnabled then return end
    if S.NoClipConn then S.NoClipConn:Disconnect(); S.NoClipConn = nil end
    local ch = LocalPlayer.Character; if not ch then return end

    for _, p in pairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = true end
    end
end

local function _SetupAntiGravBV()
    local ch = LocalPlayer.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if S.TweenAntiGravBV then pcall(function() S.TweenAntiGravBV:Destroy() end); S.TweenAntiGravBV = nil end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Parent = hrp
    S.TweenAntiGravBV = bv
end

local function _StartAntiGrav()
    S.TweenCount = S.TweenCount + 1
    if S.TweenAntiGravConn then return end
    _SetupAntiGravBV()
    S.TweenAntiGravConn = RunService.Heartbeat:Connect(function()
        if S.TweenCount <= 0 then return end
        if S.FlyEnabled then return end
        local ch = LocalPlayer.Character

        local hrp = ch and ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if not S.TweenAntiGravBV or S.TweenAntiGravBV.Parent ~= hrp then _SetupAntiGravBV() end
    end)
end

local function _StopAntiGrav()
    S.TweenCount = math.max(0, S.TweenCount - 1)
    if S.TweenCount > 0 then return end
    if S.TweenAntiGravConn then S.TweenAntiGravConn:Disconnect(); S.TweenAntiGravConn = nil end
    if S.TweenAntiGravBV then pcall(function() S.TweenAntiGravBV:Destroy() end); S.TweenAntiGravBV = nil end
end

local function _SetupFarmPhysics(hrp)
    if S.FarmBV then pcall(function() S.FarmBV:Destroy() end); S.FarmBV = nil end
    if S.FarmBG then pcall(function() S.FarmBG:Destroy() end); S.FarmBG = nil end
    if not hrp or not hrp.Parent then return end

    local bv = Instance.new("BodyVelocity")
    bv.Velocity  = Vector3.new(0, 0, 0)
    bv.MaxForce  = Vector3.new(math.huge, math.huge, math.huge)
    bv.P         = 1e4
    bv.Parent    = hrp
    S.FarmBV     = bv

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P         = 1e4
    bg.CFrame    = hrp.CFrame
    bg.Parent    = hrp
    S.FarmBG     = bg
end

local function _DestroyFarmPhysics()
    if S.FarmBV then pcall(function() S.FarmBV:Destroy() end); S.FarmBV = nil end
    if S.FarmBG then pcall(function() S.FarmBG:Destroy() end); S.FarmBG = nil end
end

local function StartTween(hrp, targetCF, getSpeed, key, onDone)
    if key and S.ActiveTweens[key] then S.ActiveTweens[key](); S.ActiveTweens[key] = nil end
    if not hrp or not hrp.Parent then if onDone then onDone(false) end; return end

    local cancelled, done = false, false
    local conn
    _StartAntiGrav()

    conn = RunService.Heartbeat:Connect(function(dt)
        if cancelled or done then return end
        _EnsureNoClip()
        if not hrp or not hrp.Parent then
            done = true; cancelled = true; conn:Disconnect(); _StopAntiGrav()
            if onDone then onDone(false) end; return
        end
        local speed = math.max(getSpeed(), 0.1)
        local dist  = (hrp.Position - targetCF.Position).Magnitude
        if dist <= 0.05 then
            done = true; hrp.CFrame = targetCF; conn:Disconnect()
            if key then S.ActiveTweens[key] = nil end
            _StopAntiGrav(); if onDone then onDone(true) end; return
        end
        hrp.CFrame = hrp.CFrame:Lerp(targetCF, math.min(speed * dt, dist) / dist)
    end)

    local function cancel()
        if done then return end
        cancelled = true; done = true
        if conn then conn:Disconnect() end
        if key  then S.ActiveTweens[key] = nil end
        _StopAntiGrav()
    end
    if key then S.ActiveTweens[key] = cancel end
    return cancel
end

local function TweenWaitKey(hrp, targetCF, getSpeed, key)
    if not hrp or not hrp.Parent then return end
    local done = false
    StartTween(hrp, targetCF, getSpeed, key, function() done = true end)
    local t0 = tick()
    while not done do
        if (tick() - t0) > 120 then break end
        task.wait(0.05)
    end
end

local function CancelTween(key)
    if S.ActiveTweens[key] then S.ActiveTweens[key](); S.ActiveTweens[key] = nil end
end

local function NewInst(cls, props, parent)
    local i = Instance.new(cls)
    for k,v in pairs(props) do i[k]=v end
    if parent then i.Parent = parent end
    return i
end
local function AddCorner(p,r) NewInst("UICorner",{CornerRadius=r or UDim.new(0,6)},p) end
local function AddStroke(p,c,t) NewInst("UIStroke",{Color=c or Color3.fromRGB(90,60,150),Thickness=t or 1},p) end
local function AddPad(p,l,r,t,b)
    NewInst("UIPadding",{
        PaddingLeft=UDim.new(0,l or 6),PaddingRight=UDim.new(0,r or 6),
        PaddingTop=UDim.new(0,t or 4),PaddingBottom=UDim.new(0,b or 4)
    },p)
end

local function SetupECMTooltip(row,sg)
    local btn=NewInst("TextButton",{
        Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-100,0.5,-11),
        BackgroundColor3=Color3.fromRGB(55,42,90),TextColor3=Color3.fromRGB(200,170,255),
        Font=Enum.Font.GothamBold,TextSize=13,Text="?",AutoButtonColor=false,ZIndex=10
    },row)
    AddCorner(btn,UDim.new(1,0))
    local tip=NewInst("TextLabel",{
        Size=UDim2.new(0,260,0,40),BackgroundColor3=Color3.fromRGB(20,15,35),
        TextColor3=Color3.fromRGB(220,200,255),Font=Enum.Font.Gotham,TextSize=11,
        Text="You have to move ur mouse along through the player list for data [FOR ONCE]",
        TextWrapped=true,Visible=false,ZIndex=100
    },sg)
    AddCorner(tip,UDim.new(0,6));AddStroke(tip);AddPad(tip)
    local function upd()
        tip.Position=UDim2.new(0,btn.AbsolutePosition.X-265,0,btn.AbsolutePosition.Y+btn.AbsoluteSize.Y+4)
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then upd();tip.Visible=true end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then tip.Visible=false end
    end)
    btn.MouseButton1Click:Connect(function() upd();tip.Visible=not tip.Visible end)
end

local function FindPlayerModel(p)
    local f=Workspace:FindFirstChild("Characters"); return f and f:FindFirstChild(p.Name)
end
local function GetNPCsFolder()
    local c=Workspace:FindFirstChild("Characters"); return c and c:FindFirstChild("NPCs")
end
local function GetCollectablesFolder() return Workspace:FindFirstChild("Collectables") end

local function UpdateDD(ref,opts)

    if not ref then return end
    pcall(function()
        if ref.UpdateOptions then ref:UpdateOptions(opts)
        elseif ref.Refresh then ref:Refresh(opts)

        elseif ref.SetOptions then ref:SetOptions(opts) end
    end)
end

local function FindCharModel()
    local cf=Workspace:FindFirstChild("Characters"); if not cf then return nil end
    local m=cf:FindFirstChild(LocalPlayer.Name); if m and m:IsA("Model") then return m end
    for _,model in pairs(cf:GetChildren()) do
        if model:IsA("Model") then
            for _,d in pairs(model:GetDescendants()) do
                if d:IsA("InputContext") and d.Name=="ToolContext" then return model end
            end
        end
    end
end
local function FindTC(cm)
    if not cm then return nil end
    for _,d in pairs(cm:GetDescendants()) do
        if d:IsA("InputContext") and d.Name=="ToolContext" then return d end
    end
end
local function GetActions(tc)
    local a={}; if not tc then return a end
    for _,c in pairs(tc:GetChildren()) do
        if c:IsA("InputAction") and not S.ignoredActions[c.Name] then table.insert(a,c.Name) end
    end
    return a
end
local function SkillsChanged(new)
    if #new~=#S.skillList then return true end
    local s={}; for _,v in ipairs(S.skillList) do s[v]=true end
    for _,v in ipairs(new) do if not s[v] then return true end end
    return false
end
local function RefreshSkillDDs(actions)
    if not actions or not SkillsChanged(actions) then return end
    S.skillList=actions
    local opts=#actions>0 and actions or {"(No skills)"}
    UpdateDD(S.FarmSkillDDRef,opts); UpdateDD(S.PlayerSkillDDRef,opts)
end
local function FindFire(wn,container)
    if not container then return nil end
    for _,c in ipairs(container:GetChildren()) do
        if c.Name==wn then local f=c:FindFirstChild("Fire"); if f then return f end end
    end
end
local function GetFireEvent(wn)
    if not wn or wn=="" then return nil end
    return FindFire(wn,LocalPlayer.Character) or FindFire(wn,LocalPlayer:FindFirstChild("Backpack"))
end
local function EquipByName(wn)
    if not wn then return false end
    local ch=LocalPlayer.Character; if not ch then return false end
    local hum=ch:FindFirstChild("Humanoid"); if not hum then return false end
    local cur=ch:FindFirstChildOfClass("Tool"); if cur and cur.Name==wn then return true end
    local bp=LocalPlayer:FindFirstChild("Backpack")
    local tool=(bp and bp:FindFirstChild(wn)) or ch:FindFirstChild(wn)
    if not tool or not tool:IsA("Tool") then return false end
    pcall(function() hum:EquipTool(tool) end); task.wait(0.35)
    local after=ch:FindFirstChildOfClass("Tool"); return after~=nil and after.Name==wn
end
local function FireSkill(wn,sn)
    if not wn or not sn then return end
    pcall(function()
        local ch=LocalPlayer.Character
        if ch then
            local bp=LocalPlayer:FindFirstChild("Backpack")
            local ok=(ch:FindFirstChild(wn) and ch:FindFirstChild(wn):IsA("Tool"))
                or(bp and bp:FindFirstChild(wn) and bp:FindFirstChild(wn):IsA("Tool"))
            if ok then EquipByName(wn) end
        end
        local fe=GetFireEvent(wn); if fe then fe:FireServer(true,sn,nil) end
    end)
end
local function EquipWeapon()
    if S.SelectedWeapon and not S.AutoEatBusy then EquipByName(S.SelectedWeapon) end
end
local function IsValid(t)
    if not t or not t.Parent then return false end
    local h=t:FindFirstChild("Humanoid"); return h~=nil and h.Health>0
end
local function IsReady(t)
    if not t or not t.Parent then return false end
    local h=t:FindFirstChild("Humanoid"); local r=t:FindFirstChild("HumanoidRootPart")
    return h~=nil and r~=nil and h.Health>0
end

task.spawn(function()
    local cf=Workspace:FindFirstChild("Characters") or Workspace:WaitForChild("Characters",60)
    if not cf then return end
    local wModel,wTC,tcA,tcR=nil,nil,nil,nil
    local mConns={}
    local function discAll(t) for _,cs in pairs(t) do for _,c in ipairs(cs) do pcall(function()c:Disconnect()end)end end end
    local function clearTC()
        if tcA then pcall(function()tcA:Disconnect()end);tcA=nil end
        if tcR then pcall(function()tcR:Disconnect()end);tcR=nil end
        wTC=nil
    end
    local function onTC(tc)
        clearTC();wTC=tc;RefreshSkillDDs(GetActions(tc))
        tcA=tc.ChildAdded:Connect(function() task.wait(0.05);if wTC==tc then RefreshSkillDDs(GetActions(tc)) end end)
        tcR=tc.ChildRemoved:Connect(function() task.wait(0.05);if wTC==tc then RefreshSkillDDs(GetActions(tc)) end end)
    end
    local function watchTool(tool)
        if mConns[tool] then return end
        local c1=tool.ChildAdded:Connect(function(ch) if ch:IsA("InputContext") and ch.Name=="ToolContext" then task.wait(0.05);onTC(ch) end end)
        local c2=tool.ChildRemoved:Connect(function(ch) if ch==wTC then clearTC() end end)
        local ex=tool:FindFirstChild("ToolContext")
        if ex and ex:IsA("InputContext") then task.spawn(function() task.wait(0.05);onTC(ex) end) end
        mConns[tool]={c1,c2}

    end
    local function watchModel(model)
        discAll(mConns);mConns={};clearTC();wModel=model
        if not model then return end
        for _,ch in pairs(model:GetChildren()) do if ch:IsA("Tool") then watchTool(ch) end end
        local ac=model.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.05);watchTool(ch) end end)
        local rc=model.ChildRemoved:Connect(function(ch)
            if ch:IsA("Tool") and mConns[ch] then
                for _,c in ipairs(mConns[ch]) do pcall(function()c:Disconnect()end) end;mConns[ch]=nil

            end

        end)
        mConns["__model"]={ac,rc}
        local tc=FindTC(model);if tc then onTC(tc) end
    end
    local init=FindCharModel() or LocalPlayer.Character
    if init then watchModel(init) end
    LocalPlayer.CharacterAdded:Connect(function(ch) task.wait(0.5);watchModel(ch) end)
    cf.ChildAdded:Connect(function(ch)
        if not ch:IsA("Model") then return end
        task.wait(0.3)
        if ch.Name==LocalPlayer.Name then watchModel(ch) end
    end)
    cf.ChildRemoved:Connect(function(ch) if ch==wModel then watchModel(nil) end end)
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if not S.ShowECM then continue end
        pcall(function()
            local pg=LocalPlayer.PlayerGui
            local pl=pg:FindFirstChild("PlayerList");if not pl then return end
            local mf=pl:FindFirstChild("MainFrame");if not mf then return end
            local pif=mf:FindFirstChild("PlayerInfoFrame");if not pif then return end
            local nl=pif:FindFirstChild("PlayerName");if not nl then return end
            local sf=pif:FindFirstChild("StatsFrame");if not sf then return end
            local ft=nl.Text;if not ft or ft=="" then return end
            local pu=ft:match("%(@@?([^%)]+)%)")
            local rp=nil
            if pu then
                local ul=pu:lower()
                for _,p in ipairs(Players:GetPlayers()) do if p.Name:lower()==ul then rp=p;break end end
            end
            if not rp then
                local st=(ft:match("^@(.+)") or ft):lower()
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Name:lower()==st or p.DisplayName:lower()==st then rp=p;break end
                end
            end
            if not rp then return end
            local el=sf:FindFirstChild("Element");local cl=sf:FindFirstChild("Class");local ml=sf:FindFirstChild("Mastery")
            local e=el and((el.Text:match("Element:%s*(.+)") or ""):match("^%s*(.-)%s*") or "") or ""
            local c=cl and((cl.Text:match("Class:%s*(.+)") or ""):match("^%s*(.-)%s*") or "") or ""
            local m=ml and((ml.Text:match("Mastery:%s*(.+)") or ""):match("^%s*(.-)%s*") or "") or ""
            local d={element=e,class=c,mastery=m}
            S.InfoCache[rp.Name]=d;S.InfoCache[rp.DisplayName]=d
            S.InfoCache["@"..rp.Name]=d;S.InfoCache["@"..rp.DisplayName]=d
        end)
    end
end)

local function StartMeditate()
    if S.IsMeditating then return end;S.IsMeditating=true
    pcall(function()
        local ch=LocalPlayer.Character;if not ch then return end
        local ba=ch:FindFirstChild("BaseActions");if not ba then return end
        local ev=ba:FindFirstChild("Events");if not ev then return end
        local me=ev:FindFirstChild("Meditate");if not me then return end
        me:FireServer()
    end)
end
local function StopMeditate() S.IsMeditating=false end

local function HasFarmTarget()
    if S.AutoFarmEnabled and S.CurrentTarget and S.CurrentTarget.Parent then
        local h=S.CurrentTarget:FindFirstChild("Humanoid");if h and h.Health>0 then return true end
    end
    if S.AutoFarmBossEnabled and S.CurrentBossTarget and S.CurrentBossTarget.Parent then
        local h=S.CurrentBossTarget:FindFirstChild("Humanoid");if h and h.Health>0 then return true end
    end
    return false
end

task.spawn(function()
    while true do
        if not S.FarmAutoSkill or not(S.AutoFarmEnabled or S.AutoFarmBossEnabled) or not HasFarmTarget() then
            task.wait(0.1);continue
        end
        local sl={};for k in pairs(S.FarmSkills) do table.insert(sl,k) end
        if #sl==0 then task.wait(0.1);continue end
        local ch=LocalPlayer.Character;local eq=ch and ch:FindFirstChildOfClass("Tool")
        local wn=eq and eq.Name or(S.SelectedWeapon or"Basic Combat")
        for _,sn in ipairs(sl) do
            if not S.FarmAutoSkill or not HasFarmTarget() then break end
            FireSkill(wn,sn);task.wait(S.FarmSkillCD)
        end
    end
end)

task.spawn(function()
    while true do
        if not S.PlayerAutoSkill then task.wait(0.1);continue end
        local sl={};for k in pairs(S.PlayerSkills) do table.insert(sl,k) end
        if #sl==0 then task.wait(0.1);continue end
        local ch=LocalPlayer.Character;local eq=ch and ch:FindFirstChildOfClass("Tool")
        local wn=eq and eq.Name or(S.AutoEquipWeapon or"Basic Combat")
        for _,sn in ipairs(sl) do
            if not S.PlayerAutoSkill then break end
            FireSkill(wn,sn);task.wait(S.PlayerSkillCD)
        end
    end
end)

local function GetFoodVal()
    local cf=Workspace:FindFirstChild("Characters")
    local cm=cf and cf:FindFirstChild(LocalPlayer.Name) or LocalPlayer.Character
    if not cm then return nil end
    local ff=cm:FindFirstChild("Food");if not ff then return nil end
    local dcv=ff:FindFirstChild("CurrentValue");if not dcv then return nil end
    return dcv.Value
end
local function FindFood(fn)

    local bp=LocalPlayer:FindFirstChild("Backpack")
    if bp then local f=bp:FindFirstChild(fn);if f then return f end end
    local ch=LocalPlayer.Character
    if ch then local f=ch:FindFirstChild(fn);if f then return f end end
end
local function GetAnyFood()
    for fn in pairs(S.SelectedFoods) do local f=FindFood(fn);if f then return f,fn end end
    return nil,nil
end
task.spawn(function()
    while true do
        task.wait(0.2)
        if not S.AutoEat then continue end
        local hasSel=false;for _ in pairs(S.SelectedFoods) do hasSel=true;break end
        if not hasSel then continue end
        local fv=GetFoodVal();if not fv or fv>50 then continue end
        S.AutoEatBusy=true
        while S.AutoEat do
            local cv=GetFoodVal();if not cv or cv>=100 then break end
            local ft,fn=GetAnyFood();if not ft then break end
            local ch=LocalPlayer.Character;if not ch then break end
            local hum=ch:FindFirstChild("Humanoid");if not hum then break end
            local ef=ch:FindFirstChild(fn)
            if not ef then
                pcall(function()hum:EquipTool(ft)end);task.wait(0.3);ef=ch:FindFirstChild(fn)
            end
            if ef then
                pcall(function()
                    local ae=ef:FindFirstChild("Activate")
                    if ae then ae:FireServer()
                    else
                        local t=ch:FindFirstChildOfClass("Tool")
                        if t and t.Name==fn then t:Activate() end
                    end
                end)
            end
            task.wait(0.5)
        end
        S.AutoEatBusy=false
    end
end)

local function EnableNoClip()
    if S.NoClipConn then return end
    S.NoClipConn=RunService.Stepped:Connect(function()
        local ch=LocalPlayer.Character;if not ch then return end
        for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
end
local function DisableNoClip()
    if S.TweenCount>0 then return end
    if S.NoClipConn then S.NoClipConn:Disconnect();S.NoClipConn=nil end
    local ch=LocalPlayer.Character;if not ch then return end
    for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
end

local function EnableFly()
    local ch=LocalPlayer.Character;if not ch then return end
    local hrp=ch:FindFirstChild("HumanoidRootPart");if not hrp then return end
    if S.FlyBV then S.FlyBV:Destroy() end
    if S.FlyBG then S.FlyBG:Destroy() end
    S.FlyBV=NewInst("BodyVelocity",{Velocity=Vector3.new(0,0,0),MaxForce=Vector3.new(9e9,9e9,9e9)},hrp)
    S.FlyBG=NewInst("BodyGyro",{MaxTorque=Vector3.new(9e9,9e9,9e9),P=9e4},hrp)
    if S.FlyConn then S.FlyConn:Disconnect() end
    S.FlyConn=RunService.Heartbeat:Connect(function()
        if not S.FlyEnabled then return end
        local c=LocalPlayer.Character;if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        if not h or not S.FlyBV or not S.FlyBG then return end
        local cam=Workspace.CurrentCamera
        local dir=Vector3.new(0,0,0);local spd=S.FlySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector*spd end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector*spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,spd,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,spd,0) end
        S.FlyBV.Velocity=dir;S.FlyBG.CFrame=cam.CFrame
    end)
end
local function DisableFly()
    if S.FlyConn then S.FlyConn:Disconnect();S.FlyConn=nil end
    if S.FlyBV then S.FlyBV:Destroy();S.FlyBV=nil end
    if S.FlyBG then S.FlyBG:Destroy();S.FlyBG=nil end
end
local function EnableNoRagdoll()
    if S.NoRagdollConn then
        S.NoRagdollConn:Disconnect()
        S.NoRagdollConn = nil
    end

    local ragdollStatesToRemove = {Ragdolled = true, Stunned = true}

    local function watchStatesFolder(statesFolder)
        if not statesFolder then return end
        for _, child in pairs(statesFolder:GetChildren()) do
            if ragdollStatesToRemove[child.Name] then
                pcall(function() child:Destroy() end)
            end
        end
        return statesFolder.ChildAdded:Connect(function(child)
            if S.NoRagdoll and ragdollStatesToRemove[child.Name] then
                pcall(function() child:Destroy() end)
            end
        end)
    end

    local function setupForModel(model)
        if not model then return end
        local statesFolder = model:FindFirstChild("States")
        local activeConn = nil

        if statesFolder then
            activeConn = watchStatesFolder(statesFolder)
        end
        local addedConn = model.ChildAdded:Connect(function(child)
            if S.NoRagdoll and child.Name == "States" then
                if activeConn then pcall(function() activeConn:Disconnect() end) end
                activeConn = watchStatesFolder(child)
            end
        end)
        return addedConn, activeConn
    end

    local charFolder = Workspace:FindFirstChild("Characters")
    local playerModel = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
    local addedConn, innerConn = setupForModel(playerModel)

    S.NoRagdollConn = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not S.NoRagdoll then return end
        if innerConn then pcall(function() innerConn:Disconnect() end) end
        if addedConn then pcall(function() addedConn:Disconnect() end) end
        local cf2 = Workspace:FindFirstChild("Characters")
        local newModel = cf2 and cf2:FindFirstChild(LocalPlayer.Name)
        addedConn, innerConn = setupForModel(newModel)
    end)

    if charFolder then
        charFolder.ChildAdded:Connect(function(child)
            if S.NoRagdoll and child.Name == LocalPlayer.Name then
                task.wait(0.3)
                if innerConn then pcall(function() innerConn:Disconnect() end) end
                if addedConn then pcall(function() addedConn:Disconnect() end) end
                addedConn, innerConn = setupForModel(child)
            end
        end)
    end
end

local function DisableNoRagdoll()
    if S.NoRagdollConn then
        S.NoRagdollConn:Disconnect()
        S.NoRagdollConn = nil
    end
end

local function EnableNoDashCD()
    for _, c in ipairs(S.NoDashCDConns) do
        pcall(function() c:Disconnect() end)
    end
    S.NoDashCDConns = {}

    local charFolder = Workspace:FindFirstChild("Characters")

    if not charFolder then return end

    local function watchModel(model)
        if not model or not model:IsA("Model") then return end
        local modelConns = {}

        local function watchCooldowns(cdFolder)
            if not cdFolder then return end
            local existing = cdFolder:FindFirstChild("Dash")
            if existing then pcall(function() existing:Destroy() end) end
            local c = cdFolder.ChildAdded:Connect(function(child)
                if S.NoDashCD and child.Name == "Dash" then
                    pcall(function() child:Destroy() end)
                end
            end)
            table.insert(modelConns, c)
            table.insert(S.NoDashCDConns, c)
        end

        local function watchStates(statesFolder)
            if not statesFolder then return end
            local existing = statesFolder:FindFirstChild("DashDisabled")
            if existing then pcall(function() existing:Destroy() end) end
            local c = statesFolder.ChildAdded:Connect(function(child)
                if S.NoDashCD and child.Name == "DashDisabled" then
                    pcall(function() child:Destroy() end)
                end
            end)
            table.insert(modelConns, c)
            table.insert(S.NoDashCDConns, c)
        end

        watchCooldowns(model:FindFirstChild("Cooldowns"))
        watchStates(model:FindFirstChild("States"))

        local c = model.ChildAdded:Connect(function(child)
            if not S.NoDashCD then return end
            if child.Name == "Cooldowns" then
                watchCooldowns(child)
            elseif child.Name == "States" then
                watchStates(child)
            end
        end)
        table.insert(modelConns, c)
        table.insert(S.NoDashCDConns, c)
    end

    for _, model in pairs(charFolder:GetChildren()) do
        if model:IsA("Model") and model.Name ~= "NPCs" then
            watchModel(model)
        end
    end

    local c = charFolder.ChildAdded:Connect(function(child)
        if not S.NoDashCD then return end
        if child:IsA("Model") and child.Name ~= "NPCs" then
            task.wait(0.2)
            watchModel(child)
        end
    end)
    table.insert(S.NoDashCDConns, c)
end

local function DisableNoDashCD()
    for _, c in ipairs(S.NoDashCDConns) do
        pcall(function() c:Disconnect() end)
    end
    S.NoDashCDConns = {}
end

local DebuffNames = {
    ["Light Blinded"] = true,
    ["Crippled"] = true,
    ["Bleeding"] = true,

    ["Poison Bleeding"] = true,
    ["Burning"] = true,
    ["Soaked"] = true,
    ["Silenced"] = true,
    ["Poisoned"] = true,
}

local function EnableAvoidDebuffs()
    for _, c in ipairs(S.AvoidDebuffsConns) do
        pcall(function() c:Disconnect() end)
    end
    S.AvoidDebuffsConns = {}

    local function watchStatesFolder(statesFolder)
        if not statesFolder then return end
        for _, child in pairs(statesFolder:GetChildren()) do
            if DebuffNames[child.Name] then
                pcall(function() child:Destroy() end)
            end
        end
        local c = statesFolder.ChildAdded:Connect(function(child)
            if S.AvoidDebuffs and DebuffNames[child.Name] then
                pcall(function() child:Destroy() end)
            end
        end)
        table.insert(S.AvoidDebuffsConns, c)
    end

    local function setupForModel(model)
        if not model then return end
        local statesFolder = model:FindFirstChild("States")
        if statesFolder then
            watchStatesFolder(statesFolder)
        end
        local c = model.ChildAdded:Connect(function(child)
            if S.AvoidDebuffs and child.Name == "States" then
                watchStatesFolder(child)
            end
        end)
        table.insert(S.AvoidDebuffsConns, c)
    end

    local charFolder = Workspace:FindFirstChild("Characters")
    local playerModel = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
    setupForModel(playerModel)

    local c = LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)

        if not S.AvoidDebuffs then return end
        local cf2 = Workspace:FindFirstChild("Characters")
        local newModel = cf2 and cf2:FindFirstChild(LocalPlayer.Name)
        setupForModel(newModel)
    end)
    table.insert(S.AvoidDebuffsConns, c)

    if charFolder then
        local c2 = charFolder.ChildAdded:Connect(function(child)
            if S.AvoidDebuffs and child.Name == LocalPlayer.Name then
                task.wait(0.3)
                setupForModel(child)
            end
        end)
        table.insert(S.AvoidDebuffsConns, c2)
    end
end

local function DisableAvoidDebuffs()
    for _, c in ipairs(S.AvoidDebuffsConns) do

        pcall(function() c:Disconnect() end)
    end
    S.AvoidDebuffsConns = {}
end

local function UpdateWSSmooth(v)

    S.WalkSpeedVal=v;S.WalkSpeedSmooth=(v/10)*3
end
local function EnableWS()
    if S.WalkSpeedConn then S.WalkSpeedConn:Disconnect() end
    S.WalkSpeedConn=RunService.Heartbeat:Connect(function()
        if not S.WalkSpeedEnabled then return end
        local ch=LocalPlayer.Character;if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart");if not hrp then return end
        local hum=ch:FindFirstChild("Humanoid")
        if not hum or hum.Health<=0 then return end
        local md=hum.MoveDirection;if md.Magnitude<0.1 then return end
        local cf=hrp.CFrame
        hrp.CFrame=CFrame.fromMatrix(cf.Position+md.Unit*S.WalkSpeedSmooth,cf.RightVector,cf.UpVector,-cf.LookVector)
    end)
end
local function DisableWS()
    if S.WalkSpeedConn then S.WalkSpeedConn:Disconnect();S.WalkSpeedConn=nil end
end

local function EnableLaggy()
    if S.LaggyConn then S.LaggyConn:Disconnect() end
    S.LaggyAccum=0
    S.LaggyConn=RunService.Heartbeat:Connect(function(dt)
        if not S.LaggyRun then return end
        local ch=LocalPlayer.Character;if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart");if not hrp then return end
        local hum=ch:FindFirstChild("Humanoid")
        if not hum or hum.Health<=0 then return end
        local md=hum.MoveDirection
        if md.Magnitude<0.1 then S.LaggyAccum=0;return end
        S.LaggyAccum=S.LaggyAccum+dt
        if S.LaggyAccum<S.LaggyDelay*0.1 then return end
        S.LaggyAccum=0
        local cf=hrp.CFrame
        hrp.CFrame=CFrame.fromMatrix(cf.Position+md.Unit*S.LaggyDist,cf.RightVector,cf.UpVector,-cf.LookVector)
    end)
end
local function DisableLaggy()
    if S.LaggyConn then S.LaggyConn:Disconnect();S.LaggyConn=nil end
    S.LaggyAccum=0
end

local function StopOrbit()
    S.OrbitEnabled=false
    if S.OrbitConn then S.OrbitConn:Disconnect();S.OrbitConn=nil end
end
local function StartOrbit(tp)
    StopOrbit();if not tp then return end
    S.OrbitTarget=tp;S.OrbitEnabled=true;S.OrbitAngle=0
    S.OrbitConn=RunService.Heartbeat:Connect(function(dt)
        if not S.OrbitEnabled then return end
        local model=FindPlayerModel(S.OrbitTarget);if not model then return end
        local tHRP=model:FindFirstChild("HumanoidRootPart");if not tHRP then return end
        local myCh=LocalPlayer.Character;if not myCh then return end
        local myHRP=myCh:FindFirstChild("HumanoidRootPart");if not myHRP then return end
        local targetCF
        if S.TPBehindOrbit then
            local bp=tHRP.CFrame.Position+(-tHRP.CFrame.LookVector)*S.OrbitDist
            targetCF=CFrame.new(Vector3.new(bp.X,tHRP.Position.Y,bp.Z),tHRP.Position)
        else
            S.OrbitAngle=S.OrbitAngle+S.OrbitSpeed*dt
            targetCF=CFrame.new(

                Vector3.new(tHRP.Position.X+math.cos(S.OrbitAngle)*S.OrbitDist,
                    tHRP.Position.Y,tHRP.Position.Z+math.sin(S.OrbitAngle)*S.OrbitDist),

                tHRP.Position)
        end
        _EnsureNoClip()
        local speed=S.OrbitTweenSpeed
        local dist=(myHRP.Position-targetCF.Position).Magnitude
        if dist<=0.05 then myHRP.CFrame=targetCF
        else myHRP.CFrame=myHRP.CFrame:Lerp(targetCF,math.min(speed*dt,dist)/dist) end
    end)
end

local function FindNPC(name,exact)
    local folder=GetNPCsFolder();if not folder then return nil end
    for _,npc in pairs(folder:GetChildren()) do
        if npc:IsA("Model") then
            local ok=exact
                and(string.match(npc.Name,"^"..name.."%d*$")~=nil)
                or(string.match(npc.Name,"^"..name)~=nil)
            if ok then
                local h=npc:FindFirstChild("Humanoid")
                if h and h.Health>0 then return npc end
            end
        end
    end
end
local function FindTargetNPC()
    local hasSel=false;for _ in pairs(S.SelectedNPCs) do hasSel=true;break end
    if not hasSel then return nil end
    for n in pairs(S.SelectedNPCs) do local npc=FindNPC(n,true);if npc then return npc end end
end
local function FindTargetBoss()
    local folder=GetNPCsFolder();if not folder then return nil end
    local hasSel=false;for _ in pairs(S.SelectedBosses) do hasSel=true;break end
    if hasSel then
        for n in pairs(S.SelectedBosses) do local npc=FindNPC(n,false);if npc then return npc end end
    else
        for _,npc in pairs(folder:GetChildren()) do
            if npc:IsA("Model") then
                for _,bn in ipairs(S.BossNames) do
                    if string.match(npc.Name,"^"..bn) then
                        local h=npc:FindFirstChild("Humanoid")
                        if h and h.Health>0 then return npc end
                    end
                end
            end
        end
    end
end
local function GetTargetCF(npcHRP)
    local p=npcHRP.Position
    return CFrame.new(Vector3.new(p.X,p.Y+S.DistanceBetweenNPC,p.Z),p)
end

local function TPBack(pos)
    if not pos then return end;task.wait(0.5)
    for i=1,2 do
        local ch=LocalPlayer.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame=CFrame.new(pos) end
        if i<2 then task.wait(0.1) end
    end
end

local function MakeFarmHB(getTgt, getEn)
    return RunService.Heartbeat:Connect(function(dt)
        if not getEn() then return end
        local ch=LocalPlayer.Character;if not ch then return end
        local hum=ch:FindFirstChild("Humanoid")
        if not hum or hum.Health<=0 then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart");if not hrp then return end

        hum.PlatformStand=true
        _EnsureNoClip()

        if not S.FarmBV or S.FarmBV.Parent~=hrp then _SetupFarmPhysics(hrp) end
        if S.FarmBV then S.FarmBV.Velocity=Vector3.new(0,0,0) end

        local tgt=getTgt()
        if not tgt or not IsReady(tgt) then return end

        local nHRP=tgt:FindFirstChild("HumanoidRootPart");if not nHRP then return end
        local tCF=GetTargetCF(nHRP)
        local dist=(hrp.Position-tCF.Position).Magnitude

        if dist<0.08 then
            hrp.CFrame=tCF
            if S.FarmBG then S.FarmBG.CFrame=tCF end
            return
        end

        local speed=math.max(S.TweenSpeed,0.1)
        local step=math.min(speed*dt,dist)
        local newCF=hrp.CFrame:Lerp(tCF,step/dist)
        hrp.CFrame=newCF
        if S.FarmBG then S.FarmBG.CFrame=newCF end
    end)
end

local function RunFarm(getTgt,getEn,getTgtVar,setTgtVar)
    setTgtVar(getTgt())
    if not getTgtVar() and S.MeditateIfNoTarget then StartMeditate() end

    local ch0=LocalPlayer.Character
    local hrp0=ch0 and ch0:FindFirstChild("HumanoidRootPart")

    if hrp0 then _SetupFarmPhysics(hrp0) end

    local hb=MakeFarmHB(getTgtVar,getEn)
    _StartAntiGrav()

    local charConn=LocalPlayer.CharacterAdded:Connect(function(newCh)
        task.wait(0.5)
        if not getEn() then return end
        local hrpN=newCh:FindFirstChild("HumanoidRootPart")

        if hrpN then _SetupFarmPhysics(hrpN) end
    end)

    task.spawn(function()
        while getEn() do
            local tgt=getTgtVar()
            if tgt and IsReady(tgt) then
                pcall(function()
                    ReplicatedStorage:WaitForChild("CombatSystem")
                        :WaitForChild("Remotes"):WaitForChild("RequestHit"):FireServer()
                end)
            end
            task.wait(0.1)
        end
    end)

    local hadTgt=getTgtVar()~=nil
    while getEn() do
        task.wait(0.05)
        local ch=LocalPlayer.Character;if not ch then continue end
        local hum=ch:FindFirstChild("Humanoid")
        if not hum or hum.Health<=0 then setTgtVar(nil);continue end
        EquipWeapon()
        if not getTgtVar() or not IsValid(getTgtVar()) then setTgtVar(getTgt()) end
        local hasTgt=getTgtVar()~=nil and IsValid(getTgtVar())
        if S.MeditateIfNoTarget then
            if not hasTgt and hadTgt then StopMeditate();StartMeditate()
            elseif not hasTgt and not S.IsMeditating then StartMeditate()
            elseif hasTgt then StopMeditate() end
        end
        hadTgt=hasTgt
    end

    charConn:Disconnect()
    hb:Disconnect()
    _StopAntiGrav()
    _DestroyFarmPhysics()

    local ch=LocalPlayer.Character
    local hum2=ch and ch:FindFirstChild("Humanoid")
    if hum2 then hum2.PlatformStand=false end
    StopMeditate()

    local c2=LocalPlayer.Character
    local hrp=c2 and c2:FindFirstChild("HumanoidRootPart")
    local pos=hrp and hrp.Position
    setTgtVar(nil)
    _CleanupNoClipAfterTween()
    task.spawn(function() TPBack(pos) end)
end

local function FarmNormal()
    RunFarm(FindTargetNPC,function()return S.AutoFarmEnabled end,
        function()return S.CurrentTarget end,function(v)S.CurrentTarget=v end)
end
local function FarmBoss()
    RunFarm(FindTargetBoss,function()return S.AutoFarmBossEnabled end,
        function()return S.CurrentBossTarget end,function(v)S.CurrentBossTarget=v end)
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if not S.AutoEquipWeapon then continue end
        local ch=LocalPlayer.Character;if not ch then continue end
        local eq=ch:FindFirstChildOfClass("Tool")
        if eq and eq.Name==S.AutoEquipWeapon then continue end
        EquipByName(S.AutoEquipWeapon)
    end
end)

local function GetHealthDCV()
    local cf=Workspace:FindFirstChild("Characters");if not cf then return nil end
    local cm=cf:FindFirstChild(LocalPlayer.Name);if not cm then return nil end
    return cm:FindFirstChild("Health")
end

local function StartTPSafe()
    if S.TPSafeConn then S.TPSafeConn:Disconnect();S.TPSafeConn=nil end
    S.IsKnockedSafe=false;S.KnockedSafePos=nil;S.KnockedReturnPos=nil
    S.TPSafeConn=RunService.Heartbeat:Connect(function()
        if not S.TPSafeEnabled then return end
        local hdcv=GetHealthDCV();if not hdcv then return end
        local ch=LocalPlayer.Character
        local hrp=ch and ch:FindFirstChild("HumanoidRootPart");if not hrp then return end
        local hp=hdcv.Value
        if not S.IsKnockedSafe then
            if hp==0 then
                S.KnockedReturnPos=hrp.Position
                S.KnockedSafePos=Vector3.new(hrp.Position.X,hrp.Position.Y+500,hrp.Position.Z)
                S.IsKnockedSafe=true;hrp.CFrame=CFrame.new(S.KnockedSafePos)
            end
        else
            if hp==0 then hrp.CFrame=CFrame.new(S.KnockedSafePos)
            else
                local rp=S.KnockedReturnPos
                S.IsKnockedSafe=false;S.KnockedSafePos=nil;S.KnockedReturnPos=nil
                task.spawn(function()
                    for i=1,3 do
                        local c=LocalPlayer.Character;local h=c and c:FindFirstChild("HumanoidRootPart")
                        if h and rp then h.CFrame=CFrame.new(rp) end
                        if i<3 then task.wait(0.1) end
                    end
                end)
            end
        end
    end)
end
local function StopTPSafe()
    if S.TPSafeConn then S.TPSafeConn:Disconnect();S.TPSafeConn=nil end
    S.IsKnockedSafe=false;S.KnockedSafePos=nil;S.KnockedReturnPos=nil
end

local function GetSortedCollects()
    local ch=LocalPlayer.Character
    local hrp=ch and ch:FindFirstChild("HumanoidRootPart");if not hrp then return {} end
    local folder=GetCollectablesFolder();if not folder then return {} end

    local hasSel=false
    for _ in pairs(S.CollectItems) do hasSel=true;break end

    local allParts={}

    for _,model in pairs(folder:GetChildren()) do
        if not model:IsA("Model") then continue end
        if hasSel and not S.CollectItems[model.Name] then continue end
        for _,part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency==0 then
                local d=(hrp.Position-part.Position).Magnitude
                table.insert(allParts,{model=model,part=part,dist=d})
            end
        end
    end

    table.sort(allParts,function(a,b) return a.dist<b.dist end)

    local seen={}
    local result={}
    for _,entry in ipairs(allParts) do
        local mid=tostring(entry.model)
        if not seen[mid] then
            seen[mid]=true
            table.insert(result,entry)
        end
    end
    return result
end

local function FindRareScroll()
    local sf=Workspace:FindFirstChild("WorldEventReferences");if not sf then return nil end
    local ss=sf:FindFirstChild("ScrollSpawns");if not ss then return nil end
    for _,ch in pairs(ss:GetChildren()) do
        if ch:IsA("MeshPart") and ch.Name=="Scroll" and ch.Transparency==0 then return ch end
        if ch:IsA("Model") or ch:IsA("Folder") then
            for _,d in pairs(ch:GetDescendants()) do
                if d:IsA("MeshPart") and d.Name=="Scroll" and d.Transparency==0 then return d end
            end
        end
    end
end
local function CollectPP(model,hrp,radius)
    for _,d in pairs(model:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            local op=d.Parent
            if op and op:IsA("BasePart") then
                if not hrp or(hrp.Position-op.Position).Magnitude<=(radius or 999) then
                    pcall(function()fireproximityprompt(d)end)
                end
            end
        end
    end
end

local function CollectLoop()
    while S.AutoCollect do
        local hasSel=false
        for _ in pairs(S.CollectItems) do hasSel=true;break end

        if hasSel and S.CollectItems["Rare Skill Scroll"] then
            local sp=FindRareScroll()
            if sp and sp.Parent and S.AutoCollect then
                S.CollectBusy=true
                local ch=LocalPlayer.Character
                local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    TweenWaitKey(hrp,CFrame.new(sp.Position+Vector3.new(0,3,0)),
                        function()return S.CollectTweenSpd end,"collect_rare")
                end
                local att=0
                while att<40 and S.AutoCollect do
                    if not sp.Parent or sp.Transparency>=1 then break end
                    ch=LocalPlayer.Character;hrp=ch and ch:FindFirstChild("HumanoidRootPart")
                    CollectPP(sp.Parent or sp,hrp)
                    att=att+1;task.wait(0.15)
                end
                S.CollectBusy=false
            end
        end

        if not S.AutoCollect then break end

        local ch=LocalPlayer.Character
        local hrp=ch and ch:FindFirstChild("HumanoidRootPart")

        if not hrp then task.wait(0.2);continue end

        local targets=GetSortedCollects()
        if #targets==0 then task.wait(0.5);continue end

        S.CollectBusy=true
        for _,entry in ipairs(targets) do
            if not S.AutoCollect then break end
            local model=entry.model;local part=entry.part
            if not model.Parent or not part.Parent then continue end
            if part.Transparency>=1 then continue end

            ch=LocalPlayer.Character;hrp=ch and ch:FindFirstChild("HumanoidRootPart")
            if not hrp then break end

            TweenWaitKey(hrp,CFrame.new(part.Position+Vector3.new(0,3,0)),
                function()return S.CollectTweenSpd end,"collect_item")
            if not S.AutoCollect then break end

            local att=0
            while att<50 do
                if not S.AutoCollect then break end
                if not model.Parent or not part.Parent then break end
                if part.Transparency>=1 then break end
                CollectPP(model,nil,nil)
                local folder2=GetCollectablesFolder()
                ch=LocalPlayer.Character;hrp=ch and ch:FindFirstChild("HumanoidRootPart")
                if folder2 and hrp then
                    for _,nm in pairs(folder2:GetChildren()) do
                        if nm:IsA("Model") then
                            if hasSel and not S.CollectItems[nm.Name] then continue end
                            CollectPP(nm,hrp,10)
                        end
                    end
                end
                att=att+1;task.wait(0.15)
            end
            task.wait(0.05)

        end

        S.CollectBusy=false
        _CleanupNoClipAfterTween()
        task.wait(0.1)
    end
    S.CollectBusy=false
    CancelTween("collect_rare")
    CancelTween("collect_item")
    _CleanupNoClipAfterTween()
end

local function GetPlayerNames()
    local names={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer then table.insert(names,p.Name) end

    end
    if #names==0 then table.insert(names,"(No players)") end
    return names
end

task.spawn(function()
    while true do
        task.wait(3)
        if not S.OrbitDDRef then continue end
        local nn=GetPlayerNames();local ns={}
        for _,n in ipairs(nn) do ns[n]=true end
        local changed=false
        for n in pairs(ns) do if not S.lastOrbitPlayers[n] then changed=true;break end end
        if not changed then for n in pairs(S.lastOrbitPlayers) do if not ns[n] then changed=true;break end end end
        if changed then
            S.lastOrbitPlayers=ns;UpdateDD(S.OrbitDDRef,nn)
            local on=S.OrbitTarget and S.OrbitTarget.Name or nil
            if on and not ns[on] then StopOrbit();S.OrbitTarget=nil end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if not S.SpectateDDRef then continue end
        local nn=GetPlayerNames();local ns={}
        for _,n in ipairs(nn) do ns[n]=true end
        local changed=false
        for n in pairs(ns) do if not S.lastSpectatePlayers[n] then changed=true;break end end
        if not changed then for n in pairs(S.lastSpectatePlayers) do if not ns[n] then changed=true;break end end end
        if changed then
            S.lastSpectatePlayers=ns;UpdateDD(S.SpectateDDRef,nn)
            local sn=S.SpectateTarget and S.SpectateTarget.Name or nil
            if sn and not ns[sn] then

                S.SpectateEnabled=false;S.SpectateTarget=nil
                pcall(function()
                    local cam=Workspace.CurrentCamera;local myCh=LocalPlayer.Character
                    local mH=myCh and myCh:FindFirstChild("Humanoid")
                    if mH then cam.CameraSubject=mH end;cam.CameraType=Enum.CameraType.Custom
                end)
            end
        end
    end
end)

local QuestFn={
    ["Earth Bandit Quest"]=function() pcall(function() Workspace.DialogueNPCs.QuestRelated.NPCDefeating.EarthBandit.Torso.ProximityPrompt.Answer:FireServer("AcceptQuest") end) end,
    ["Air Bandit Quest"] =function() pcall(function() Workspace.DialogueNPCs.QuestRelated.NPCDefeating.AirBandit.Torso.ProximityPrompt.Answer:FireServer("AcceptQuest") end) end,
    ["Water Bandit Quest"]=function() pcall(function() Workspace.DialogueNPCs.QuestRelated.NPCDefeating.WaterBandit.Torso.ProximityPrompt.Answer:FireServer("AcceptQuest") end) end,
    ["Fire Bandit Quest"] =function() pcall(function() Workspace.DialogueNPCs.QuestRelated.NPCDefeating.FireBandit.Torso.ProximityPrompt.Answer:FireServer("AcceptQuest") end) end,
}
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoQuest and QuestFn[S.AutoQuest] then QuestFn[S.AutoQuest]() end
    end
end)

local function FindNearestWater()

    local ch=LocalPlayer.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    local map=Workspace:FindFirstChild("Map");if not map then return nil end
    local roots={}
    local pw=map:FindFirstChild("PhysicalWorld")

    if pw then
        local t=pw:FindFirstChild("Terrain")
        if t then local f=t:FindFirstChild("Forest");if f then local l=f:FindFirstChild("Lakes");if l then table.insert(roots,l) end end end
    end
    local sw=map:FindFirstChild("SpiritualWorld");if sw then local l=sw:FindFirstChild("Lakes");if l then table.insert(roots,l) end end
    local bestPart,bestDist=nil,math.huge
    for _,lf in ipairs(roots) do
        for _,m in pairs(lf:GetChildren()) do
            for _,d in pairs(m:GetDescendants()) do
                if d:IsA("BasePart") and d.Name=="Water" then
                    local dist=hrp and(hrp.Position-d.Position).Magnitude or 0
                    if dist<bestDist then bestDist=dist;bestPart=d end
                end
            end
        end
    end
    return bestPart
end
local function FindRodInBP()
    local bp=LocalPlayer:FindFirstChild("Backpack");if not bp then return nil end
    for _,t in pairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:match("Fishing Rod") then return t end end
end
local function GetEquippedRod()
    local ch=LocalPlayer.Character;if not ch then return nil end
    for _,t in pairs(ch:GetChildren()) do if t:IsA("Tool") and t.Name:match("Fishing Rod") then return t end end
end
local function EquipRod()
    local eq=GetEquippedRod();if eq then return eq end
    local rod=FindRodInBP();if not rod then return nil end
    local ch=LocalPlayer.Character;if not ch then return nil end
    local hum=ch:FindFirstChild("Humanoid")
    if hum then pcall(function()hum:EquipTool(rod)end);task.wait(0.4) end
    return GetEquippedRod()
end
local function GetBait()
    local ch=LocalPlayer.Character;if not ch then return nil end
    for _,t in pairs(ch:GetChildren()) do
        if t:IsA("Tool") and t.Name:match("Fishing Rod$") then
            local b=t:FindFirstChild("FishingBait");if b then return b end
        end
    end
end
local function ClickPart(part)
    if not part then return end
    local clicked=false
    pcall(function()
        for _,d in pairs(part:GetDescendants()) do
            if d:IsA("ClickDetector") and fireclickdetector then fireclickdetector(d);clicked=true;return end
        end
        local cd=part:FindFirstChildOfClass("ClickDetector")
        if cd and fireclickdetector then fireclickdetector(cd);clicked=true end
    end)
    if clicked then return end
    pcall(function() if mouse1click then mouse1click() end end)
    pcall(function() if mouse1press then mouse1press();task.wait(0.05);mouse1release() end end)
    pcall(function()
        local cam=Workspace.CurrentCamera;local sp,ons=cam:WorldToViewportPoint(part.Position)
        if ons then
            local vim=game:GetService("VirtualInputManager")
            vim:SendMouseButtonEvent(sp.X,sp.Y,0,true,game,1);task.wait(0.05)

            vim:SendMouseButtonEvent(sp.X,sp.Y,0,false,game,1)
        end
    end)
end

local function AutoFishLoop()
    local wp=FindNearestWater();if not wp then S.AutoFish=false;return end
    if not GetEquippedRod() then if not EquipRod() then S.AutoFish=false;return end end
    task.wait(0.3)
    local ch=LocalPlayer.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    if hrp then TweenWaitKey(hrp,CFrame.new(wp.Position+Vector3.new(0,3,0)),function()return S.FishTweenSpd end,"fish_tp") end
    task.wait(0.5)
    while S.AutoFish do
        ch=LocalPlayer.Character;hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then task.wait(0.5);continue end
        if wp and wp.Parent then
            local tp=wp.Position+Vector3.new(0,3,0)
            if(hrp.Position-tp).Magnitude>5 then
                TweenWaitKey(hrp,CFrame.new(tp),function()return S.FishTweenSpd end,"fish_tp")
            end
        else
            wp=FindNearestWater();if not wp then break end
            hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then TweenWaitKey(hrp,CFrame.new(wp.Position+Vector3.new(0,3,0)),function()return S.FishTweenSpd end,"fish_tp") end
        end
        if not GetEquippedRod() then EquipRod();task.wait(0.3) end
        ClickPart(wp);task.wait(1)
        while S.AutoFish do if GetBait() then break end;ClickPart(wp);task.wait(1) end
        if not S.AutoFish then break end
        local react=nil
        while S.AutoFish do
            if not GetBait() then ClickPart(wp);task.wait(1);break end
            react=Workspace:FindFirstChild("RodReactEffect");if react then break end
            task.wait(0.2)
        end
        if not S.AutoFish then break end
        if react then ClickPart(react);task.wait(0.5) end
        task.wait(0.1)
    end
    _CleanupNoClipAfterTween()
end

local function GetCollectOpts()
    local folder=GetCollectablesFolder();local names,seen={},{}
    if folder then
        for _,m in pairs(folder:GetChildren()) do
            if m:IsA("Model") and not seen[m.Name] then seen[m.Name]=true;table.insert(names,m.Name) end
        end
    end
    if not seen["Rare Skill Scroll"] then table.insert(names,"Rare Skill Scroll") end
    return names
end
local lastCollectOpts={}
task.spawn(function()
    while true do
        task.wait(3)
        if not S.CollectDDRef then continue end
        local no=GetCollectOpts();if #no==0 then no={"(None)"} end
        local changed=#no~=#lastCollectOpts
        if not changed then
            local s={};for _,v in ipairs(lastCollectOpts) do s[v]=true end
            for _,v in ipairs(no) do if not s[v] then changed=true;break end end
        end
        if changed then lastCollectOpts=no;UpdateDD(S.CollectDDRef,no) end
    end
end)

local function GetServiceNPCNames()
    local names,seen={},{}
    local df=Workspace:FindFirstChild("DialogueNPCs");if not df then return names end
    for _,sf in pairs(df:GetChildren()) do
        if not seen[sf.Name] then seen[sf.Name]=true;table.insert(names,sf.Name) end
    end
    return names
end
task.spawn(function()
    while true do
        task.wait(3)

        if not S.ServiceNPCDDRef then continue end
        local nn=GetServiceNPCNames();if #nn==0 then nn={"(None)"} end
        local changed=#nn~=#S.lastServiceNPCNames
        if not changed then
            local s={};for _,v in ipairs(S.lastServiceNPCNames) do s[v]=true end
            for _,v in ipairs(nn) do if not s[v] then changed=true;break end end
        end
        if changed then S.lastServiceNPCNames=nn;UpdateDD(S.ServiceNPCDDRef,nn) end
    end
end)

local function RemoveAllESP()
    for _,obj in pairs(S.ESPObjs) do
        if obj.hl and obj.hl.Parent then obj.hl:Destroy() end
        if obj.bb and obj.bb.Parent then obj.bb:Destroy() end
    end;S.ESPObjs={}
end
local function CreateNPCESP(model,dn)
    if S.ESPObjs[model] then return end
    local rp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart") or model.PrimaryPart
    if not rp then return end
    local hl=NewInst("SelectionBox",{Color3=Color3.fromRGB(120,80,255),LineThickness=0.07,SurfaceTransparency=0.85,SurfaceColor3=Color3.fromRGB(120,80,255),Adornee=model},Workspace.CurrentCamera)
    local bb=NewInst("BillboardGui",{AlwaysOnTop=true,Size=UDim2.new(0,160,0,50),StudsOffset=Vector3.new(0,4,0),Adornee=rp},Workspace.CurrentCamera)
    NewInst("TextLabel",{Size=UDim2.new(1,0,0.52,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(200,170,255),TextStrokeTransparency=0.35,TextStrokeColor3=Color3.fromRGB(20,5,50),Font=Enum.Font.GothamBold,TextSize=14,Text=dn or model.Name},bb)
    local dl=NewInst("TextLabel",{Size=UDim2.new(1,0,0.48,0),Position=UDim2.new(0,0,0.52,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,220,100),TextStrokeTransparency=0.35,TextStrokeColor3=Color3.fromRGB(20,5,50),Font=Enum.Font.GothamBold,TextSize=13,Text="-- m"},bb)
    S.ESPObjs[model]={hl=hl,bb=bb,dl=dl,rp=rp}
end
RunService.Heartbeat:Connect(function()
    if not S.ServiceNPCESP then return end
    local ch=LocalPlayer.Character;local chHRP=ch and ch:FindFirstChild("HumanoidRootPart")
    local df=Workspace:FindFirstChild("DialogueNPCs");local active={}
    if df then
        for _,sf in pairs(df:GetChildren()) do
            for _,m in pairs(sf:GetChildren()) do if m:IsA("Model") then active[m]=sf.Name end end
        end
    end
    for m,dn in pairs(active) do if not S.ESPObjs[m] then CreateNPCESP(m,dn) end end
    local rem={};for m in pairs(S.ESPObjs) do if not active[m] then table.insert(rem,m) end end
    for _,m in ipairs(rem) do
        local o=S.ESPObjs[m]
        if o.hl and o.hl.Parent then o.hl:Destroy() end
        if o.bb and o.bb.Parent then o.bb:Destroy() end
        S.ESPObjs[m]=nil
    end
    if chHRP then
        for _,e in pairs(S.ESPObjs) do
            if e.rp and e.rp.Parent then e.dl.Text=math.floor((chHRP.Position-e.rp.Position).Magnitude).." m" end
        end
    end
end)

local function EnsureCooldownGui()
    if S.CooldownGui then return end
    S.CooldownGui=NewInst("ScreenGui",{Name="SymbioteCooldownGui",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999,IgnoreGuiInset=true},LocalPlayer.PlayerGui)
    local cont=NewInst("Frame",{Name="CC",AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,0.75,0),Size=UDim2.new(0,900,0,160),BackgroundTransparency=1,BorderSizePixel=0},S.CooldownGui)
    S.CooldownTitle=NewInst("TextLabel",{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,70,70),TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0),Font=Enum.Font.GothamBold,TextSize=22,Text="",Visible=false},cont)
    S.CooldownRich=NewInst("TextLabel",{Size=UDim2.new(1,0,0,130),Position=UDim2.new(0,0,0,32),BackgroundTransparency=1,TextStrokeTransparency=0,TextStrokeColor3=Color3.fromRGB(0,0,0),Font=Enum.Font.GothamBold,TextSize=20,TextWrapped=false,RichText=true,TextXAlignment=Enum.TextXAlignment.Center,TextColor3=Color3.fromRGB(255,255,255),Text="",Visible=false},cont)
end

local function ReadDCV(model,name)
    local dcv=model:FindFirstChild(name);if not dcv then return nil,nil end
    local cur=dcv.Value;local mx=nil;pcall(function()mx=dcv.MaxValue end);return cur,mx
end
local function RemoveAllPlayerESP()
    for _,obj in pairs(S.PlayerESPObjs) do
        pcall(function()
            if obj.bb and obj.bb.Parent then obj.bb:Destroy() end
            if obj.sb and obj.sb.Parent then obj.sb:Destroy() end
            if obj.cdConns then for _,c in ipairs(obj.cdConns) do pcall(function()c:Disconnect()end) end end
        end)
    end
    S.PlayerESPObjs={}
    if S.CooldownRich then S.CooldownRich.Text="";S.CooldownRich.Visible=false end
    if S.CooldownTitle then S.CooldownTitle.Text="";S.CooldownTitle.Visible=false end
end
local function MakeBar(parent,xOff,fgCol,bgCol)
    local out=NewInst("Frame",{Size=UDim2.new(0,12,0,40),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=Color3.fromRGB(0,0,0),BorderSizePixel=0},parent)
    local bg=NewInst("Frame",{Size=UDim2.new(0,8,0,36),Position=UDim2.new(0,2,0,2),BackgroundColor3=bgCol or Color3.fromRGB(40,10,10),BorderSizePixel=0},out)
    return NewInst("Frame",{AnchorPoint=Vector2.new(0,1),Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,0),BackgroundColor3=fgCol,BorderSizePixel=0},bg)

end
local function MakeLbl(parent,yOff,col,sz,xOff,wrap)
    xOff=xOff or 30
    return NewInst("TextLabel",{Size=UDim2.new(1,-xOff,0,sz==12 and 42 or 14),Position=UDim2.new(0,xOff,0,yOff),BackgroundTransparency=1,TextColor3=col,TextStrokeTransparency=0.3,TextStrokeColor3=Color3.fromRGB(0,10,30),Font=Enum.Font.GothamBold,TextSize=sz or 13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=wrap or false,Text="",Visible=false},parent)
end
local function CreatePlayerESP(player)
    if player==LocalPlayer then return end
    local model=FindPlayerModel(player);if not model then return end
    if S.PlayerESPObjs[player] then return end
    local rp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart");if not rp then return end
    local sb=NewInst("SelectionBox",{Color3=Color3.fromRGB(255,60,60),LineThickness=0.07,SurfaceTransparency=0.88,SurfaceColor3=Color3.fromRGB(255,60,60),Adornee=model},Workspace.CurrentCamera)
    local bb=NewInst("BillboardGui",{AlwaysOnTop=true,Size=UDim2.new(0,260,0,160),StudsOffset=Vector3.new(3.8,1.5,0),Adornee=rp},Workspace.CurrentCamera)
    local hpF=MakeBar(bb,0,Color3.fromRGB(80,220,80),Color3.fromRGB(40,10,10))
    local enF=MakeBar(bb,14,Color3.fromRGB(50,150,255),Color3.fromRGB(5,15,40))
    NewInst("TextLabel",{Size=UDim2.new(1,-30,0,18),Position=UDim2.new(0,30,0,0),BackgroundTransparency=1,TextColor3=Color3.fromRGB(200,170,255),TextStrokeTransparency=0.35,TextStrokeColor3=Color3.fromRGB(20,5,50),Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Text=player.Name},bb)
    local dL=NewInst("TextLabel",{Size=UDim2.new(1,-30,0,14),Position=UDim2.new(0,30,0,20),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,220,100),TextStrokeTransparency=0.35,TextStrokeColor3=Color3.fromRGB(20,5,50),Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="-- m",Visible=true},bb)
    local locL=MakeLbl(bb,36,Color3.fromRGB(130,255,160),13);local eqHL=MakeLbl(bb,52,Color3.fromRGB(255,170,50),13)
    local eqEL=MakeLbl(bb,68,Color3.fromRGB(80,210,255),13);local ecmL=MakeLbl(bb,84,Color3.fromRGB(180,230,255),12,30,true)
    local cdC={}
    S.PlayerESPObjs[player]={model=model,bb=bb,sb=sb,rp=rp,hpF=hpF,enF=enF,dL=dL,locL=locL,eqHL=eqHL,eqEL=eqEL,ecmL=ecmL,cdConns=cdC,cds={}}
    task.spawn(function()
        local function setupCD(folder)
            if not folder then return end;local obj=S.PlayerESPObjs[player];if not obj then return end
            for _,ch in pairs(folder:GetChildren()) do obj.cds[ch.Name]=true end
            local a=folder.ChildAdded:Connect(function(ch) local o=S.PlayerESPObjs[player];if o then o.cds[ch.Name]=true end end)
            local r=folder.ChildRemoved:Connect(function(ch) local o=S.PlayerESPObjs[player];if o then o.cds[ch.Name]=nil end end)

            table.insert(obj.cdConns,a);table.insert(obj.cdConns,r)
        end
        local cdf=model:FindFirstChild("Cooldowns");if cdf then setupCD(cdf) end
        local ac=model.ChildAdded:Connect(function(ch) if ch.Name=="Cooldowns" then setupCD(ch) end end)
        local obj=S.PlayerESPObjs[player];if obj then table.insert(obj.cdConns,ac) end
    end)
end
local function RemovePlayerESP(player)
    local obj=S.PlayerESPObjs[player];if not obj then return end
    pcall(function()
        if obj.bb and obj.bb.Parent then obj.bb:Destroy() end
        if obj.sb and obj.sb.Parent then obj.sb:Destroy() end
        if obj.cdConns then for _,c in ipairs(obj.cdConns) do pcall(function()c:Disconnect()end) end end
    end)
    S.PlayerESPObjs[player]=nil
end

local function RemoveAllESPLines()
    for _,obj in pairs(S.ESPLineObjs) do
        pcall(function()
            if obj.line and obj.line.Parent then obj.line:Destroy() end
            if obj.outline and obj.outline.Parent then obj.outline:Destroy() end
        end)
    end;S.ESPLineObjs={}
end
local function EnsureESPLinesGui()
    if S.ESPLinesGui and S.ESPLinesGui.Parent then return end
    S.ESPLinesGui=NewInst("ScreenGui",{Name="SymbioteESPLinesGui",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=998,IgnoreGuiInset=true},LocalPlayer.PlayerGui)
end
local function MakeLine(parent,zi)
    return NewInst("Frame",{BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),ZIndex=zi or 1},parent)
end

RunService.Heartbeat:Connect(function()
    if not S.ESPLines then if next(S.ESPLineObjs) then RemoveAllESPLines() end;return end
    EnsureESPLinesGui()
    local myCh=LocalPlayer.Character;local myHRP=myCh and myCh:FindFirstChild("HumanoidRootPart");if not myHRP then return end
    local cam=Workspace.CurrentCamera;local sb=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y)
    local cP,cD=nil,math.huge

    for _,p in pairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end;local m=FindPlayerModel(p);if not m then continue end
        local r=m:FindFirstChild("HumanoidRootPart");if not r then continue end
        local d=(myHRP.Position-r.Position).Magnitude;if d<cD then cD=d;cP=p end
    end
    local active={}
    for _,p in pairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end;local m=FindPlayerModel(p)
        if not m then
            if S.ESPLineObjs[p] then
                local o=S.ESPLineObjs[p]
                pcall(function()if o.outline and o.outline.Parent then o.outline:Destroy()end end)
                pcall(function()if o.line and o.line.Parent then o.line:Destroy()end end)
                S.ESPLineObjs[p]=nil
            end;continue
        end
        local rp=m:FindFirstChild("HumanoidRootPart");if not rp then continue end
        active[p]=true
        if not S.ESPLineObjs[p] then S.ESPLineObjs[p]={line=MakeLine(S.ESPLinesGui,2),outline=MakeLine(S.ESPLinesGui,1)} end
        local obj=S.ESPLineObjs[p];local isCl=(p==cP)
        local lc=isCl and Color3.fromRGB(255,50,50) or Color3.fromRGB(180,80,255)
        local lt=isCl and 1.5 or 1;local ot=isCl and 2 or 1.5

        local ts,tv=cam:WorldToViewportPoint(rp.Position)
        if not tv then obj.line.Visible=false;obj.outline.Visible=false;continue end
        local tp2=Vector2.new(ts.X,ts.Y);local dx=tp2.X-sb.X;local dy=tp2.Y-sb.Y
        local len=math.sqrt(dx*dx+dy*dy);if len<1 then obj.line.Visible=false;obj.outline.Visible=false;continue end
        local ang=math.deg(math.atan2(dy,dx));local cx=(sb.X+tp2.X)/2;local cy=(sb.Y+tp2.Y)/2
        obj.outline.Size=UDim2.new(0,len+ot,0,lt+ot);obj.outline.Position=UDim2.new(0,cx,0,cy);obj.outline.Rotation=ang;obj.outline.BackgroundColor3=Color3.fromRGB(0,0,0);obj.outline.Visible=true
        obj.line.Size=UDim2.new(0,len,0,lt);obj.line.Position=UDim2.new(0,cx,0,cy);obj.line.Rotation=ang;obj.line.BackgroundColor3=lc;obj.line.Visible=true
    end
    local rem={};for p in pairs(S.ESPLineObjs) do if not active[p] then table.insert(rem,p) end end
    for _,p in ipairs(rem) do
        local o=S.ESPLineObjs[p]
        pcall(function()if o.outline and o.outline.Parent then o.outline:Destroy()end end)

        pcall(function()if o.line and o.line.Parent then o.line:Destroy()end end)
        S.ESPLineObjs[p]=nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.PlayerESP then return end
    local myCh=LocalPlayer.Character;local myHRP=myCh and myCh:FindFirstChild("HumanoidRootPart")
    for _,player in pairs(Players:GetPlayers()) do
        if player==LocalPlayer then continue end
        local model=FindPlayerModel(player)

        if not model then RemovePlayerESP(player);continue end
        if not S.PlayerESPObjs[player] then CreatePlayerESP(player) end
        local obj=S.PlayerESPObjs[player];if not obj then continue end
        local nr=model:FindFirstChild("HumanoidRootPart")
        if nr and nr~=obj.rp then obj.rp=nr;if obj.bb then obj.bb.Adornee=nr end end
        local ch,mx=ReadDCV(model,"Health")
        if ch and mx and mx>0 then
            local r=math.clamp(ch/mx,0,1);obj.hpF.Size=UDim2.new(1,0,r,0);obj.hpF.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-r)),math.floor(220*r),50)
        else
            local hum=model:FindFirstChild("Humanoid")
            if hum and hum.MaxHealth>0 then
                local r=math.clamp(hum.Health/hum.MaxHealth,0,1);obj.hpF.Size=UDim2.new(1,0,r,0);obj.hpF.BackgroundColor3=Color3.fromRGB(math.floor(255*(1-r)),math.floor(220*r),50)
            end
        end
        local ce,me=ReadDCV(model,"Energy")
        if ce and me and me>0 then
            local r=math.clamp(ce/me,0,1);local b=math.floor(100+155*r)
            obj.enF.Size=UDim2.new(1,0,r,0);obj.enF.BackgroundColor3=Color3.fromRGB(30,math.floor(b*0.6),b)
        else obj.enF.Size=UDim2.new(1,0,0,0) end
        if myHRP and obj.rp and obj.rp.Parent then obj.dL.Text=math.floor((myHRP.Position-obj.rp.Position).Magnitude).." m" end
        if S.ShowLoc then
            local ok,lv=pcall(function()return model:GetAttribute("Location")end)
            obj.locL.Text=(ok and lv) and("Loc: "..tostring(lv)) or "Loc: ?";obj.locL.Visible=true
        else obj.locL.Visible=false end
        if S.ShowEqStats then
            local ok1,v1=pcall(function()return model:GetAttribute("EquipmentHealth")end)
            if ok1 and v1~=nil then obj.eqHL.Text="EqHP: "..v1;obj.eqHL.Visible=true else obj.eqHL.Visible=false end
            local ok2,v2=pcall(function()return model:GetAttribute("EquipmentEnergy")end)
            if ok2 and v2~=nil then obj.eqEL.Text="EqEng: "..v2;obj.eqEL.Visible=true else obj.eqEL.Visible=false end
        else obj.eqHL.Visible=false;obj.eqEL.Visible=false end
        if S.ShowECM then
            local inf=S.InfoCache[player.Name] or S.InfoCache[player.DisplayName]
                or S.InfoCache["@"..player.Name] or S.InfoCache["@"..player.DisplayName]
            if inf then
                local pts={}
                if inf.element~="" then table.insert(pts,"El: "..inf.element) end
                if inf.class~="" then table.insert(pts,"Cl: "..inf.class) end
                if inf.mastery~="" then table.insert(pts,"Ms: "..inf.mastery) end
                obj.ecmL.Text=table.concat(pts,"\n");obj.ecmL.Visible=#pts>0
            else obj.ecmL.Visible=false end
        else obj.ecmL.Visible=false end
    end
    local rem={};for p in pairs(S.PlayerESPObjs) do if not Players:FindFirstChild(p.Name) then table.insert(rem,p) end end
    for _,p in ipairs(rem) do RemovePlayerESP(p) end
end)

RunService.Heartbeat:Connect(function()
    EnsureCooldownGui();if not S.CooldownRich then return end
    local myCh=LocalPlayer.Character;local myHRP=myCh and myCh:FindFirstChild("HumanoidRootPart")
    local lines,any={},false
    for plr,obj in pairs(S.PlayerESPObjs) do
        if not obj.rp or not obj.rp.Parent then continue end
        local dist=myHRP and(myHRP.Position-obj.rp.Position).Magnitude or 9999
        if dist<=300 then
            local cdl={};for n in pairs(obj.cds) do table.insert(cdl,n) end
            if #cdl>0 then
                table.sort(cdl)
                local ss=table.concat(cdl,"<font color='#ffffff'> â€¢ </font>")
                table.insert(lines,"<font size='22' color='#FFE030'><b>"..plr.Name.."</b></font><font size='20' color='#aaaaaa'> â€º </font><font size='20' color='#FF7040'><b>"..ss.."</b></font>")
                any=true
            end
        end

    end

    if any then
        S.CooldownTitle.Text="âš  SKILLS ON COOLDOWN";S.CooldownTitle.Visible=true
        S.CooldownRich.Text=table.concat(lines,"\n");S.CooldownRich.Visible=true
    else
        S.CooldownTitle.Text="";S.CooldownTitle.Visible=false
        S.CooldownRich.Text="";S.CooldownRich.Visible=false
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.SpectateEnabled or not S.SpectateTarget then return end
    local m=FindPlayerModel(S.SpectateTarget);if not m then return end
    local h=m:FindFirstChild("HumanoidRootPart");if not h then return end
    local cam=Workspace.CurrentCamera;cam.CameraSubject=h;cam.CameraType=Enum.CameraType.Follow
end)

RunService.Heartbeat:Connect(function()
    if not S.LockCamera then return end
    local myCh=LocalPlayer.Character;local myHRP=myCh and myCh:FindFirstChild("HumanoidRootPart");if not myHRP then return end
    local cP,cD=nil,math.huge
    for _,p in pairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end;local m=FindPlayerModel(p);if not m then continue end
        local r=m:FindFirstChild("HumanoidRootPart");if not r then continue end
        local d=(myHRP.Position-r.Position).Magnitude;if d<cD then cD=d;cP=p end
    end
    if not cP then return end;local tm=FindPlayerModel(cP);if not tm then return end
    local th=tm:FindFirstChild("HumanoidRootPart");if not th then return end
    local cam=Workspace.CurrentCamera;cam.CameraType=Enum.CameraType.Scriptable
    cam.CFrame=CFrame.new(myHRP.Position+Vector3.new(0,5,0)+(myHRP.Position-th.Position).Unit*15,th.Position)
end)

local function ResetCamera()
    pcall(function()
        local cam=Workspace.CurrentCamera;local myCh=LocalPlayer.Character
        local mH=myCh and myCh:FindFirstChild("Humanoid")
        if mH then cam.CameraSubject=mH end;cam.CameraType=Enum.CameraType.Custom
    end)
end
local function SingleSelect(getRef,getCurrent,cb)
    local sel=false
    return function(chosen)
        if sel then return end
        local keys={};for k in pairs(chosen) do table.insert(keys,k) end
        if #keys==0 then cb(nil);return end
        local v=keys[1]
        if #keys>1 then
            for _,k in ipairs(keys) do if k~=getCurrent() then v=k;break end end
            local ref=getRef();if ref then sel=true;ref:ClearSelection();sel=false end
        end
        cb(v)
    end
end
local function ClearAfter(getRef,cb)
    return function(sel)
        cb(sel)

        task.defer(function()
            local ref=getRef();if ref then pcall(function()ref:ClearSelection()end) end
        end)
    end
end

local Window=Library:CreateWindow({Title=" Symbiote ",Size=UDim2.new(0,580,0,440)})

local PT  =Window:CreateTab("Player")
local AFT =Window:CreateTab("Auto Farm")
local VT  =Window:CreateTab("Various")
local PVPT=Window:CreateTab("PVP")

PT:AddToggle("Fly",function(s) S.FlyEnabled=s;if s then EnableFly() else DisableFly() end end)
PT:AddSlider("Fly Speed",50,300,50,function(v)S.FlySpeed=v end)
PT:AddToggle("NoClip",function(s) S.NoClipEnabled=s;if s then EnableNoClip() else DisableNoClip() end end)

PT:AddToggle("No Ragdoll & Stun",function(s)
    S.NoRagdoll=s
    if s then EnableNoRagdoll() else DisableNoRagdoll() end
end)

PT:AddToggle("No Dash CD & Hit While Dashing",function(s)
    S.NoDashCD=s
    if s then EnableNoDashCD() else DisableNoDashCD() end
end)

PT:AddToggle("Walk Speed",function(s) S.WalkSpeedEnabled=s;if s then EnableWS() else DisableWS() end end)
PT:AddSlider("Walk Speed Amount",1,10,5,function(v)UpdateWSSmooth(v)end)
UpdateWSSmooth(5)
PT:AddToggle("Laggy Run",function(s) S.LaggyRun=s;if s then EnableLaggy() else DisableLaggy() end end)
PT:AddSlider("Laggy Run Distance",1,10,1,function(v)S.LaggyDist=v end)
PT:AddSlider("Laggy Run Delay",1,10,1,function(v)S.LaggyDelay=v end)
PT:AddToggle("Infinite Jump",function(s)
    S.InfiniteJump=s
    if s then
        if S.InfiniteJumpConn then S.InfiniteJumpConn:Disconnect() end
        S.InfiniteJumpConn=UserInputService.JumpRequest:Connect(function()
            if not S.InfiniteJump then return end
            local ch=LocalPlayer.Character;local hum=ch and ch:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if S.InfiniteJumpConn then S.InfiniteJumpConn:Disconnect();S.InfiniteJumpConn=nil end
    end
end)
PT:AddDropdown("Select To Auto Eat",S.FoodNames,function(sel)
    S.SelectedFoods={};for n in pairs(sel) do S.SelectedFoods[n]=true end
end)
PT:AddToggle("Auto Eat (If < 50)",function(s)S.AutoEat=s end)

do
    local ref=nil;local tpEnabled=false
    local function GetLocs()
        local lf=Workspace:FindFirstChild("LocationParts");local n={}
        if lf then for _,m in pairs(lf:GetChildren()) do if m:IsA("Model") then table.insert(n,m.Name) end end end
        return #n>0 and n or{"(No locations found)"}
    end
    ref=PT:AddDropdown("Teleport To Place",GetLocs(),ClearAfter(function()return ref end,function(sel)
        for name in pairs(sel) do
            CancelTween("tp_place");if not tpEnabled then break end
            local lf=Workspace:FindFirstChild("LocationParts");if not lf then break end
            local m=lf:FindFirstChild(name);if not m or not m:IsA("Model") then break end
            local part=nil;for _,d in pairs(m:GetDescendants()) do if d:IsA("BasePart") then part=d;break end end
            if part then
                local ch=LocalPlayer.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    EnableNoClip()
                    StartTween(hrp,CFrame.new(part.Position+Vector3.new(0,-100,0)),function()return S.TPPlaceSpeed end,"tp_place",function() _CleanupNoClipAfterTween() end)
                end
            end;break
        end
    end))
    PT:AddToggle("Enable Teleport To Place",function(s) tpEnabled=s;if not s then CancelTween("tp_place") end end)
    PT:AddSlider("Teleport To Place Speed",1,300,20,function(v)S.TPPlaceSpeed=v end)
end

do
    local wRef=nil
    wRef=AFT:AddDropdown("Select Weapon",S.WeaponNames,SingleSelect(
        function()return wRef end,function()return S.SelectedWeapon end,
        function(v)
            if not v then S.SelectedWeapon=nil;return end
            local bp=LocalPlayer:FindFirstChild("Backpack");local ch=LocalPlayer.Character
            local has=(bp and bp:FindFirstChild(v)) or(ch and ch:FindFirstChild(v))
            S.SelectedWeapon=has and v or nil
        end
    ))
end
AFT:AddSlider("Distance To NPC (studs)",5,50,5,function(v)S.DistanceBetweenNPC=v end)
AFT:AddSlider("Farm Tween Speed",1,300,20,function(v)S.TweenSpeed=v end)
do
    local itc=FindTC(FindCharModel());local ia=GetActions(itc);local io=#ia>0 and ia or{"(No skills)"}
    S.FarmSkillDDRef=AFT:AddDropdown("Select Skills",io,function(sel)
        S.FarmSkills={};for s in pairs(sel) do if s~="(No skills)" then S.FarmSkills[s]=true end end
    end)
    AFT:AddToggle("Auto Skill",function(s)S.FarmAutoSkill=s end)
    AFT:AddSlider("Cooldown Between Skills (s)",0.5,10,2,function(v)S.FarmSkillCD=v end)
end
AFT:AddToggle("Meditate If No Target",function(s) S.MeditateIfNoTarget=s;if not s then StopMeditate() end end)
AFT:AddToggle("Auto Farm",function(s)
    if s then
        if S.AutoFarmBossEnabled then S.AutoFarmEnabled=false;return end
        S.AutoFarmEnabled=true;task.spawn(FarmNormal)
    else
        local ch=LocalPlayer.Character;local h=ch and ch:FindFirstChild("HumanoidRootPart");local pos=h and h.Position
        S.AutoFarmEnabled=false;StopMeditate();S.CurrentTarget=nil
        task.spawn(function()TPBack(pos)end)
    end
end)
AFT:AddDropdown("Select NPC",S.NPCNames,function(sel) S.SelectedNPCs={};for n in pairs(sel) do S.SelectedNPCs[n]=true end end)
AFT:AddToggle("Auto Farm Boss",function(s)
    if s then
        if S.AutoFarmEnabled then S.AutoFarmBossEnabled=false;return end
        S.AutoFarmBossEnabled=true;task.spawn(FarmBoss)
    else
        local ch=LocalPlayer.Character;local h=ch and ch:FindFirstChild("HumanoidRootPart");local pos=h and h.Position
        S.AutoFarmBossEnabled=false;StopMeditate();S.CurrentBossTarget=nil
        task.spawn(function()TPBack(pos)end)
    end
end)
AFT:AddDropdown("Select Boss",S.BossNames,function(sel) S.SelectedBosses={};for n in pairs(sel) do S.SelectedBosses[n]=true end end)

VT:AddToggle("Service NPC ESP",function(s) S.ServiceNPCESP=s;if not s then RemoveAllESP() end end)
do
    local initSN=GetServiceNPCNames();if #initSN==0 then initSN={"(None)"} end
    S.lastServiceNPCNames=initSN;local tpSel=false;local npcTpEnabled=false
    S.ServiceNPCDDRef=VT:AddDropdown("Teleport To NPC",initSN,function(sel)
        if tpSel then return end

        for name in pairs(sel) do
            if name=="(None)" then break end
            CancelTween("tp_npc");if not npcTpEnabled then break end
            local myCh=LocalPlayer.Character;local myHRP=myCh and myCh:FindFirstChild("HumanoidRootPart");if not myHRP then break end
            local df=Workspace:FindFirstChild("DialogueNPCs");if not df then break end
            local best,bestD=nil,math.huge
            for _,sf in pairs(df:GetChildren()) do
                if sf.Name==name then
                    for _,m in pairs(sf:GetChildren()) do
                        if m:IsA("Model") then
                            local rp=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            if rp then local d=(myHRP.Position-rp.Position).Magnitude;if d<bestD then bestD=d;best=m end end
                        end
                    end
                end
            end

            if best then
                local rp=best:FindFirstChild("HumanoidRootPart") or best:FindFirstChildWhichIsA("BasePart")

                if rp then
                    EnableNoClip()
                    StartTween(myHRP,CFrame.new(rp.Position+Vector3.new(0,5,0)),function()return S.NPCTPSpeed end,"tp_npc",function() _CleanupNoClipAfterTween() end)
                end
            end;break
        end
        tpSel=true;task.defer(function() pcall(function()S.ServiceNPCDDRef:ClearSelection()end);tpSel=false end)
    end)
    VT:AddToggle("Enable Teleport To NPC",function(s) npcTpEnabled=s;if not s then CancelTween("tp_npc") end end)
    VT:AddSlider("Teleport To NPC Speed",1,300,20,function(v)S.NPCTPSpeed=v end)
end

VT:AddToggle("Auto Collect",function(s)
    if s then
        S.AutoCollect=true;S.CollectBusy=false;task.spawn(CollectLoop)
    else
        S.AutoCollect=false;CancelTween("collect_rare");CancelTween("collect_item");S.CollectBusy=false
    end
end)
VT:AddSlider("Auto Collect Tween Speed",1,300,20,function(v)S.CollectTweenSpd=v end)
do
    local ico=GetCollectOpts();if #ico==0 then ico={"(None)"} end;lastCollectOpts=ico
    S.CollectDDRef=VT:AddDropdown("Select Item To Auto Collect",ico,function(sel)
        S.CollectItems={};for n in pairs(sel) do if n~="(None)" then S.CollectItems[n]=true end end
    end)
end
do
    local ibRef=nil
    local ibO={"Buy Wooden Fishing Rod","Buy Metal Fishing Rod","Buy Obsidian Fishing Rod","Buy Meteoric Fishing Rod"}

    local ibA={
        ["Buy Wooden Fishing Rod"]="BuyWooden Fishing Rod",
        ["Buy Metal Fishing Rod"]="BuyMetal Fishing Rod",
        ["Buy Obsidian Fishing Rod"]="BuyObsidian Fishing Rod",
        ["Buy Meteoric Fishing Rod"]="BuyMeteoric Fishing Rod"
    }
    ibRef=VT:AddDropdown("Instant Buy",ibO,ClearAfter(function()return ibRef end,function(sel)
        for n in pairs(sel) do
            local a=ibA[n];if a then pcall(function() Workspace.DialogueNPCs.Fishmonger.Torso.ProximityPrompt.Answer:FireServer(a) end) end;break
        end
    end))
end
VT:AddToggle("Auto Fish",function(s) S.AutoFish=s;if s then task.spawn(AutoFishLoop) else CancelTween("fish_tp") end end)
VT:AddSlider("Auto Fish Tween Speed",1,300,20,function(v)S.FishTweenSpd=v end)
do
    local qRef=nil;local qO={"Earth Bandit Quest","Air Bandit Quest","Water Bandit Quest","Fire Bandit Quest"}
    qRef=VT:AddDropdown("Auto Quest",qO,SingleSelect(function()return qRef end,function()return S.AutoQuest end,function(v)S.AutoQuest=v end))
end

PVPT:AddToggle("ESP Players",function(s) S.PlayerESP=s;if not s then RemoveAllPlayerESP() end end)
PVPT:AddToggle("ESP Lines",function(s) S.ESPLines=s;if not s then RemoveAllESPLines() end end)
do
    local ecmRow=PVPT:AddToggle("Show Element & Class & Mastery in ESP",function(s)S.ShowECM=s end)
    local row=ecmRow and ecmRow.Row;if row then SetupECMTooltip(row,Window.ScreenGui) end
end
PVPT:AddToggle("Show Equipment HP & Equipment Energy",function(s)S.ShowEqStats=s end)
PVPT:AddToggle("Show Location",function(s)S.ShowLoc=s end)
do
    local aeRef=nil
    aeRef=PVPT:AddDropdown("Auto Equip Weapon",S.WeaponNames,SingleSelect(function()return aeRef end,function()return S.AutoEquipWeapon end,function(v)S.AutoEquipWeapon=v end))
end
do
    local itc2=FindTC(FindCharModel());local ia2=GetActions(itc2);local io2=#ia2>0 and ia2 or{"(No skills)"}
    S.PlayerSkillDDRef=PVPT:AddDropdown("Select Skills",io2,function(sel)
        S.PlayerSkills={};for s in pairs(sel) do if s~="(No skills)" then S.PlayerSkills[s]=true end end
    end)
    PVPT:AddToggle("Auto Skill",function(s)S.PlayerAutoSkill=s end)
    PVPT:AddSlider("Skill Cooldown (s)",0.5,10,2,function(v)S.PlayerSkillCD=v end)
end
PVPT:AddToggle("TP Behind While Orbit",function(s) S.TPBehindOrbit=s;if S.OrbitEnabled and S.OrbitTarget then StartOrbit(S.OrbitTarget) end end)
do
    local orRef=nil
    orRef=PVPT:AddDropdown("Orbit Player",GetPlayerNames(),SingleSelect(

        function()return orRef end,function()return S.OrbitTarget and S.OrbitTarget.Name or nil end,
        function(v)

            if not v or v=="(No players)" then StopOrbit();S.OrbitTarget=nil;return end
            local tp=Players:FindFirstChild(v);if tp then StartOrbit(tp) else StopOrbit();S.OrbitTarget=nil end
        end
    ))
    S.OrbitDDRef=orRef
end
PVPT:AddSlider("Orbit Speed",1,20,1,function(v)S.OrbitSpeed=v end)
PVPT:AddSlider("Orbit Distance",5,50,10,function(v)S.OrbitDist=v end)
PVPT:AddSlider("Orbit Tween Speed",1,300,20,function(v)S.OrbitTweenSpeed=v end)
PVPT:AddToggle("TP To Safe If Knocked",function(s) S.TPSafeEnabled=s;if s then StartTPSafe() else StopTPSafe() end end)

PVPT:AddToggle("Avoid Debuffs",function(s)
    S.AvoidDebuffs=s
    if s then EnableAvoidDebuffs() else DisableAvoidDebuffs() end
end)

do

    local spRef=nil
    spRef=PVPT:AddDropdown("Spectate Player",GetPlayerNames(),SingleSelect(
        function()return spRef end,function()return S.SpectateTarget and S.SpectateTarget.Name or nil end,
        function(v)
            if not v or v=="(No players)" then S.SpectateEnabled=false;S.SpectateTarget=nil;ResetCamera();return end
            local tp=Players:FindFirstChild(v)
            if tp then S.SpectateTarget=tp;S.SpectateEnabled=true else S.SpectateEnabled=false;S.SpectateTarget=nil end
        end

    ))
    S.SpectateDDRef=spRef
end
PVPT:AddToggle("Lock Camera On Closest Player",function(s) S.LockCamera=s;if not s then ResetCamera() end end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})