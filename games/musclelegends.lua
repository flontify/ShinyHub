if not game:IsLoaded() then game.Loaded:Wait() end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("rEvents", 10)
local MuscleEvent = ReplicatedStorage:WaitForChild("muscleEvent", 10)
local autoRep=false local autoRebirth=false local autoHatch=false local autoSell=false local autoEvolve=false local autoTitan=false local evolveMode="Both" local titanMode="Both"
local startTime=os.time()
local uniquePetsEquipped=false local omegaPetsEquipped=false
local webhookUrl="" local autoWebhook=false local autoWebhookInterval=60 local webhookUsername="ShinyHub"
local Rayfield=loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local Window=Rayfield:CreateWindow({Name="ShinyHub | Muscle Legends", LoadingTitle="ShinyHub", LoadingSubtitle="Muscle Legends", Theme="Default", ToggleUIKeybind="K", DisableRayfieldPrompts=false, DisableBuildWarnings=false, ConfigurationSaving={Enabled=true, FolderName="ShinyHub", FileName="Muscle Legends"}})
local MainTab=Window:CreateTab({Name="Main", Icon="home"})
local PetTab=Window:CreateTab({Name="Pets and Crystals", Icon="paw-print"})
local DiscordTab=Window:CreateTab({Name="Discord", Icon="send"})
local function Notify(o) if pcall(function() Rayfield:Notify(o) end) then return end pcall(function() Window:Notify(o) end) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title=o.Title,Text=o.Content,Duration=o.Duration or 3}) end) end
local function createAfkDisplay(c) if not c then return end local h=c:WaitForChild("Head",5) if not h or h:FindFirstChild("AFK_Tag") then return end local b=Instance.new("BillboardGui") b.Name="AFK_Tag" b.Size=UDim2.new(0,160,0,30) b.StudsOffset=Vector3.new(0,3,0) b.AlwaysOnTop=true b.Parent=h local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text="ShinyHub ANTI-AFK [00:00:00]" l.TextColor3=Color3.fromRGB(140,90,255) l.Font=Enum.Font.GothamBold l.TextSize=12 l.TextStrokeTransparency=0.2 l.Parent=b local s=Instance.new("UIStroke",l) s.Thickness=1.5 s.Color=Color3.fromRGB(0,0,0) task.spawn(function() while b and b.Parent do local e=os.time()-startTime local h=math.floor(e/3600) local m=math.floor((e%3600)/60) local s=e%60 l.Text=string.format("ShinyHub ANTI-AFK [%02d:%02d:%02d]",h,m,s) task.wait(1) end end) end
LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
if LocalPlayer.Character then createAfkDisplay(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(createAfkDisplay)
local function getEquippedTool() local c=LocalPlayer.Character if not c then return end local t=c:FindFirstChildOfClass("Tool") if t and not string.find(string.lower(t.Name),"punch") then return t end local b=LocalPlayer:FindFirstChild("Backpack") if b then for _,i in ipairs(b:GetChildren()) do if i:IsA("Tool") and not string.find(string.lower(i.Name),"punch") then c.Humanoid:EquipTool(i) return i end end end return nil end
local function massTogglePets(r,s) pcall(function() local e=RemoteEvents:FindFirstChild("equipPetEvent") local p=LocalPlayer:FindFirstChild("petsFolder") local f=p and p:FindFirstChild(r) if e and f then for _,pet in ipairs(f:GetChildren()) do e:FireServer(s and "equipPet" or "unequipPet",pet) task.wait(0.02) end end end) end
local function massSellPets(r) pcall(function() local s=RemoteEvents:FindFirstChild("sellPetEvent") local p=LocalPlayer:FindFirstChild("petsFolder") local f=p and p:FindFirstChild(r) if s and f then for _,pet in ipairs(f:GetChildren()) do s:FireServer("sellPet",pet) end end end) end
local function sendProgress() if webhookUrl=="" then return end local payload={username=webhookUsername,embeds={{title="Muscle Legends",fields={{name="Player",value=LocalPlayer.Name,inline=true}},timestamp=DateTime.now():ToIsoDate()}}} local json=HttpService:JSONEncode(payload) local req=(http_request or request or (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request)) if req then pcall(function() req({Url=webhookUrl,Method="POST",Headers={["Content-Type"]="application/json"},Body=json}) end) end end
MainTab:CreateSection("Auto Farm Settings")
MainTab:CreateToggle({Name="Auto Fast Reps",CurrentValue=false,Flag="AutoRep",Callback=function(Value) autoRep=Value if Value then task.spawn(function() while autoRep do pcall(function() local tool=getEquippedTool() if MuscleEvent then for i=1,3 do MuscleEvent:FireServer("rep") end end if tool then tool:Activate() end end) task.wait(0.1) end end) end end,})
MainTab:CreateToggle({Name="Auto Rebirth 500x Mass",CurrentValue=false,Flag="AutoRebirth",Callback=function(Value) autoRebirth=Value if Value then task.spawn(function() while autoRebirth do local r=RemoteEvents:FindFirstChild("rebirthRemote") if r then pcall(function() r:InvokeServer("massRebirthRequest",500) end) end task.wait(0.1) end end) end end,})
PetTab:CreateSection("Crystal Opener")
PetTab:CreateToggle({Name="Auto Open Secret Void Crystal",CurrentValue=false,Flag="AutoHatch",Callback=function(Value) autoHatch=Value if Value then task.spawn(function() while autoHatch do local h=RemoteEvents:FindFirstChild("openCrystalRemote") if h then pcall(function() h:InvokeServer("openCrystal","Secret Void Crystal",1) end) end task.wait(0.1) end end) end end,})
PetTab:CreateSection("Mass Equip / Unequip Tools")
PetTab:CreateButton({Name="Equip / Unequip All Unique Pets", Callback=function() uniquePetsEquipped=not uniquePetsEquipped massTogglePets("Unique",uniquePetsEquipped) Notify({Title="Unique Pets", Content=uniquePetsEquipped and "Equipped all Unique pets!" or "Unequipped all Unique pets!", Duration=3}) end,})
PetTab:CreateButton({Name="Equip / Unequip All Omega Pets", Callback=function() omegaPetsEquipped=not omegaPetsEquipped massTogglePets("Omega",omegaPetsEquipped) Notify({Title="Omega Pets", Content=omegaPetsEquipped and "Equipped all Omega pets!" or "Unequipped all Omega pets!", Duration=3}) end,})
PetTab:CreateSection("Auto Evolve & Sell")
PetTab:CreateToggle({Name="Auto Sell Epic Pets",CurrentValue=false,Flag="AutoSell",Callback=function(Value) autoSell=Value if Value then task.spawn(function() while autoSell do massSellPets("Epic") task.wait(0.5) end end) end end,})
PetTab:CreateSection("Auto Normal Evolve")
PetTab:CreateDropdown({Name="Normal Evolve Target Filter",Options={"Both","Epic","Unique","Omega","All"},CurrentOption={"Both"},MultipleOptions=false,Flag="EvolveMode",Callback=function(Option) evolveMode=type(Option)=="table" and Option[1] or Option end,})
PetTab:CreateToggle({Name="Auto Evolve Pets",CurrentValue=false,Flag="AutoEvolve",Callback=function(Value) autoEvolve=Value if Value then task.spawn(function() while autoEvolve do local m=evolveMode local t={} if m=="Both" then t={"Epic","Unique"} elseif m=="All" then t={"Common","Uncommon","Rare","Epic","Unique","Omega"} else t={m} end for _,r in ipairs(t) do local f=LocalPlayer:FindFirstChild("petsFolder") and LocalPlayer.petsFolder:FindFirstChild(r) local e=RemoteEvents:FindFirstChild("petEvolveEvent") if f and e then for _,p in ipairs(f:GetChildren()) do if not string.find(p.Name,"Evolved") and not string.find(p.Name,"Titan") then e:FireServer("evolvePet",p) task.wait(0.08) end end end end task.wait(0.5) end end) end end,})
PetTab:CreateSection("Auto Titan Evolve")
PetTab:CreateDropdown({Name="Titan Evolve Target Filter",Options={"Both","Epic","Unique","Omega","All"},CurrentOption={"Both"},MultipleOptions=false,Flag="TitanMode",Callback=function(Option) titanMode=type(Option)=="table" and Option[1] or Option end,})
PetTab:CreateToggle({Name="Auto Titan Evolve Pets",CurrentValue=false,Flag="AutoTitan",Callback=function(Value) autoTitan=Value if Value then task.spawn(function() while autoTitan do local m=titanMode local t={} if m=="Both" then t={"Epic","Unique"} elseif m=="All" then t={"Common","Uncommon","Rare","Epic","Unique","Omega"} else t={m} end for _,r in ipairs(t) do local f=LocalPlayer:FindFirstChild("petsFolder") and LocalPlayer.petsFolder:FindFirstChild(r) local e=RemoteEvents:FindFirstChild("petEvolveEvent") if f and e then for _,p in ipairs(f:GetChildren()) do if not string.find(p.Name,"Titan") then e:FireServer("evolveTitan",p) task.wait(0.08) end end end end task.wait(0.5) end end) end end,})
DiscordTab:CreateSection("Discord Webhook")
DiscordTab:CreateInput({Name="Webhook URL", PlaceholderText="https://discord.com/api/webhooks/...", RemoveTextAfterFocusLost=false, Callback=function(Text) webhookUrl=Text end,})
DiscordTab:CreateInput({Name="Webhook Username", PlaceholderText="ShinyHub", RemoveTextAfterFocusLost=false, Callback=function(Text) webhookUsername=Text end,})
DiscordTab:CreateButton({Name="Send Progress Now", Callback=function() sendProgress() end,})
