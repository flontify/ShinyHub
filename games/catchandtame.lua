-- if you skid give credit, its open source for a reason - discord.gg/TtH3rBCyrv
-- ShinyHub | Catch And Tame
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
                Theme = "Amoled",
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
            TabObj.AddToggle = TabObj.AddToggle
            TabObj.AddSlider = TabObj.AddSlider
            TabObj.AddDropdown = TabObj.AddDropdown
            TabObj.AddSeparator = TabObj.AddSeparator
            TabObj.AddLabel = TabObj.AddLabel
            TabObj.AddButton = TabObj.AddButton
            return TabObj
        end
        return WindowObj
    end
    return shimLib

end

local v1 = createSymbioteShim("Catch And Tame")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local u8 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local t1 = {
	"Common",
	"Rare",
	"Epic",
	"Legendary",

	"Mythical",
	"Boss",
	"Secret",
	"Divine",
}
local t2 = {
	"Normal",
	"Albino",
	"Gold",
	"Rainbow",
	"Glass",
	"Neon",
	"Shiny",
	"Charged",
	"Volcanic",
	"Cosmic",
	"Seabound",
	"Steam Punk",
	"Dusty",
	"Crystal",
	"Taco",
	"Abducted",
	"Easter",
	"Lovestruck",
	"Fluffy",
	"Alien",
	"Clawed",
	"Bloodbound",
	"Snowy",
	"Fractured",
	"Admin",

}
local t3 = {
	"RoamingPets",
	"SkyIslandPets",
	"WaterIslandPets",
	"BeeIslandPets",
	"IceIslandPets",
	"GalaxyIslandPets",
	"NewEventIslandPets",
	"SafariIslandPets",
	"CaveIslandPets",
	"DeepCavePets",
	"AbyssIslandPets",
	"SummerRoamingPets",
}
local u12 = false
local t4 = {}
local t5 = {}
local t6 = {}
local u16 = false
local n1 = 50
local connection = nil
local BodyVelocity = nil
local BodyGyro = nil
local u21 = false
local u22
local u23 = nil
local u24 = false
local thread

local connection2 = nil
local u27 = false
local u28 = false
local u29
local u32 = t3
local u33 = ReplicatedStorage
local u35 = ReplicatedStorage
local u36 = ReplicatedStorage
local u37 = VirtualInputManager
local u38 = LocalPlayer

local function u39(p1)
	local HumanoidRootPart = p1.model:FindFirstChild("HumanoidRootPart")

	if HumanoidRootPart then
		local Remotes = u35:FindFirstChild("Remotes")

		if Remotes then
			local minigameRequest = Remotes:FindFirstChild("minigameRequest")

			if minigameRequest then
				local p1parentFolder = workspace:FindFirstChild(p1.parentFolder)

				if p1parentFolder then
					local Pets = p1parentFolder:FindFirstChild("Pets")

					if Pets then
						local p1modelName = Pets:FindFirstChild(p1.model.Name)

						if p1modelName then
							local _pcall = pcall

							local u141 = HumanoidRootPart

							pcall(function()
								local v229 = (function(...)
									local t7 = { ... }

									t7.n = select("#", ...)

									return t7
								end)(CFrame.new(u141.CFrame.Position))

								minigameRequest:InvokeServer(p1modelName, unpack(v229, 1, v229.n))
							end)

							return
						end

						return
					end

					return
				end

				return
			end

			return
		end

		return
	end
end
local function u40()
	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local v149 = ViewportSize.X / 2
	local v150 = ViewportSize.Y / 2

	for i = 1, 8 do
		local _pcall = pcall
		local u153 = v149
		local u154 = v150

		pcall(function()
			u37:SendMouseButtonEvent(u153, u154, 0, true, game, 0)
			u37:SendMouseButtonEvent(u153, u154, 0, false, game, 0)
		end)

		if i < 8 then
			task.wait(0.125)
		end
	end
end
local function u41()
	local Remotes = u36:FindFirstChild("Remotes")

	if Remotes then
		local UpdateProgress = Remotes:FindFirstChild("UpdateProgress")

		if UpdateProgress then
			local _pcall = pcall
			local u145 = UpdateProgress

			pcall(function()
				u145:FireServer(25)
			end)
			task.wait()
			local u147 = UpdateProgress

			pcall(function()
				u147:FireServer(100)
			end)

			return

		end

		return
	end
end
local function v42(p2)
	if p2 and p2.model and p2.model.Parent then
		local HumanoidRootPart = p2.model:FindFirstChild("HumanoidRootPart")
		local Character = u38.Character
		local v158 = Character and Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart and v158 then
			v158.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		end

		u39(p2)
		task.wait(0.1)

		u40()
		u41()

		local v159 = tick() + 1

		repeat
			if not (v159 > tick()) then

				return false
			end

			task.wait(0.05)

			if not p2.model or not p2.model.Parent then
				return false
			end
		until p2.model.Parent == workspace

		return true
	end

	return false
end
local function u43()
	local t8 = {}

	for _, v in ipairs(u32) do
		local v2 = workspace:FindFirstChild(v)

		if v2 then
			local Pets = v2:FindFirstChild("Pets")

			if Pets then
				for _, child in ipairs(Pets:GetChildren()) do
					if child:IsA("Model") then
						local v119 = child:GetAttribute("Mutation") or "None"
						local v120 = child:GetAttribute("Name") or child.Name
						local v121 = child:GetAttribute("Rarity") or "Common"
						local t9 = {
							model = child,
							name = v120,

							mutation = v119,
							displayMut = v119 == "None" and "Normal" or v119,
							rarity = v121,
							parentFolder = v,
						}

						table.insert(t8, t9)
					end
				end
			end
		end
	end

	return t8
end
local function v44()
	local v160 = u43()
	local t10 = {}

	for _, v in ipairs(v160) do
		local v164 = next(t4) == nil or t4[v.name]
		local v165 = next(t5) == nil or t5[v.displayMut]
		local v166 = next(t6) == nil or t6[v.rarity]

		if v164 and v165 and v166 then
			table.insert(t10, v)
		end
	end

	return t10
end

local t11 = {
	["Main Place"] = CFrame.new(
		-3.48583341,
		16.9999981,
		-2886.95581,
		-0.999839425,
		2.59817967E-09,
		-0.0179189797,
		2.62033462E-09,
		1,
		-0.00000000121291466,
		0.0179189797,
		-0.0000000012596737,
		-0.999839425
	),
	["Sky Island"] = CFrame.new(
		23.2471924,
		823.030029,
		-3049.76855,
		-0.998015404,
		1.65147913E-08,
		-0.0629704669,
		1.67329084E-08,
		1,
		-0.00000000293642377,
		0.0629704669,
		-0.00000000398427513,
		-0.998015404
	),
	["John's Store"] = CFrame.new(
		9.96656322,
		13.7406616,
		-5046.44482,
		0.997560799,
		-0.00000000326393446,
		0.0698029175,

		3.48145091E-09,
		1,
		-0.00000000299449665,
		-0.0698029175,
		3.23020788E-09,
		0.997560799
	),
	["Deep Sea"] = CFrame.new(
		9.51443672,
		-1726.16614,
		-4957.17188,
		0.424611837,
		3.62968358E-08,
		-0.905375481,
		-0.0000000128792017,
		1,
		3.40501529E-08,
		0.905375481,
		-0.00000000279758461,
		0.424611837
	),
	["Bee Island"] = CFrame.new(
		106.163147,
		27.1896076,
		-1059.48438,
		-0.99997288,
		-0.0000000515851397,
		-0.00736449566,
		-0.0000000520325365,
		1,
		6.05589463E-08,
		0.00736449566,
		6.09405006E-08,
		-0.99997288
	),
	["Bryan Shop"] = CFrame.new(
		-68.2911224,
		14.3621826,

		-974.84198,
		0.537317038,
		0.0117067564,
		0.843299091,
		-0.000000316507197,
		0.999903679,
		-0.0138805546,
		-0.843380332,
		0.00745799113,
		0.537265241
	),
	["Safari Island"] = CFrame.new(
		-2438.47192,
		11.9987259,
		-2749.84424,
		0.602665246,
		8.04509597E-08,
		0.797994137,
		2.91607254E-08,

		1,
		-0.000000122839396,
		-0.797994137,

		9.73011183E-08,
		0.602665246
	),
	["Cave Island"] = CFrame.new(
		-3337.56836,

		8.99611187,
		-2835.90112,
		0.0404205658,
		-0.0000000950037418,
		0.999182761,
		5.17201464E-08,
		1,
		9.29891826E-08,
		-0.999182761,
		4.79192046E-08,
		0.0404205658
	),

	["Deep Cave"] = CFrame.new(
		-4740.9834,
		-559.273071,
		-1132.38245,
		0.0608007945,
		6.87305013E-09,
		-0.998149931,
		1.84897395E-08,
		1,
		8.0120639E-09,
		0.998149931,
		-0.0000000189426714,
		0.0608007945
	),
	["Abyss Island"] = CFrame.new(
		14.0138626,
		-2048.24731,
		-5055.32764,
		0.999028623,
		-0.0000000406469844,
		-0.0440665931,
		4.1071587E-08,
		1,
		8.73009487E-09,
		0.0440665931,
		-0.0000000105314992,
		0.999028623
	),
	["Lost Docks"] = CFrame.new(
		1461.198,
		16.4402313,
		-4430.65186,
		0.283759207,
		-0.0000000157304765,

		-0.958895564,
		-0.0000000378941998,
		1,
		-0.000000027618551,
		0.958895564,
		4.41735999E-08,
		0.283759207
	),
	Valerian = CFrame.new(
		1231.38208,
		-84.1661682,
		-4361.15137,
		-0.292363763,
		-0.0115160858,
		0.956237853,
		-0.000000000631622366,
		0.999927461,
		0.0120422449,
		-0.956307173,
		0.00352071552,
		-0.292342573
	),
	["Tropical Island"] = CFrame.new(
		1529.0011,
		59.3376427,
		-2158.99829,
		0.0319115184,
		5.58900446E-08,
		0.999490678,
		-0.0000000208639381,
		1,
		-0.0000000552523858,
		-0.999490678,
		-0.000000019090125,
		0.0319115184
	),
}
local t12 = {
	"Main Place",
	"Sky Island",
	"John's Store",
	"Deep Sea",
	"Bee Island",
	"Bryan Shop",
	"Safari Island",
	"Cave Island",
	"Deep Cave",
	"Abyss Island",
	"Lost Docks",
	"Tropical Island",
}
local u52 = LocalPlayer

local function v53()
	local Backpack = u52:FindFirstChild("Backpack")

	if Backpack then
		for _, child in ipairs(Backpack:GetChildren()) do
			if child:IsA("Tool") and child.Name:sub(-3) == "Rod" then
				return child
			end
		end

		return nil
	end

	return nil
end

local u54 = LocalPlayer

local function v55()
	local Character = u54.Character

	if Character then
		for _, child in ipairs(Character:GetChildren()) do
			if child:IsA("Tool") and child.Name:sub(-3) == "Rod" then
				return true
			end
		end

		return false
	end

	return false
end
local u59 = RunService
local u60 = v55
local u61 = v53
local u62 = LocalPlayer

local function u63()
	connection2 = u59.Heartbeat:Connect(function()
		if u24 then
			if not u60() then
				local v247 = u61()

				if v247 then
					local Character = u62.Character

					if Character then
						v247.Parent = Character

						return
					end

					return
				end

				return
			end

			return
		end
	end)
	thread = task.spawn(function()
		while u24 do
			task.wait(0.2)

			if not u24 then
				return
			end

			pcall(function()
				game:GetService("ReplicatedStorage").Remotes.EndFIshing:FireServer()
			end)
		end
	end)
end

local u64 = LocalPlayer

local function v65()
	local Backpack = u64:FindFirstChild("Backpack")

	if Backpack then
		for _, child in ipairs(Backpack:GetChildren()) do
			if child:IsA("Tool") and child.Name:find("Shovel") then
				return child
			end
		end

		return nil
	end

	return nil
end

local u66 = LocalPlayer

local function v67()
	local Character = u66.Character

	if Character then
		for _, child in ipairs(Character:GetChildren()) do
			if child:IsA("Tool") and child.Name:find("Shovel") then
				return true
			end
		end

		return false
	end

	return false
end
local u74 = LocalPlayer
local u75 = RunService
local u76 = UserInputService

local function u77()
	local Character = u74.Character

	if Character then
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

		if HumanoidRootPart then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")

			if Humanoid then

				Humanoid.PlatformStand = true
			end

			BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Velocity = Vector3.new(0, 0, 0)
			BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
			BodyVelocity.Parent = HumanoidRootPart
			BodyGyro = Instance.new("BodyGyro")
			BodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
			BodyGyro.P = 10000
			BodyGyro.CFrame = HumanoidRootPart.CFrame
			BodyGyro.Parent = HumanoidRootPart
			connection = u75.Heartbeat:Connect(function()
				if u16 then
					local CurrentCamera = workspace.CurrentCamera
					local vector3 = Vector3.new(0, 0, 0)

					if u76:IsKeyDown(Enum.KeyCode.W) then
						vector3 = vector3 + CurrentCamera.CFrame.LookVector
					end

					if u76:IsKeyDown(Enum.KeyCode.S) then
						vector3 = vector3 - CurrentCamera.CFrame.LookVector
					end

					if u76:IsKeyDown(Enum.KeyCode.A) then
						vector3 = vector3 - CurrentCamera.CFrame.RightVector
					end

					if u76:IsKeyDown(Enum.KeyCode.D) then
						vector3 = vector3 + CurrentCamera.CFrame.RightVector
					end

					if u76:IsKeyDown(Enum.KeyCode.Space) then
						vector3 = vector3 + Vector3.new(0, 1, 0)
					end

					if u76:IsKeyDown(Enum.KeyCode.LeftControl) then
						vector3 = vector3 - Vector3.new(0, 1, 0)
					end

					if vector3.Magnitude > 0 then
						vector3 = vector3.Unit
					end

					if BodyVelocity then
						BodyVelocity.Velocity = vector3 * n1
					end

					if BodyGyro then
						BodyGyro.CFrame = CurrentCamera.CFrame
					end

					return
				end
			end)

			return
		end

		return
	end
end
local v81 = v1:CreateWindow({
	Title = "  Symbiote ",
	Size = UDim2.new(0, 500, 0, 480),
})
local v82 = v81:CreateTab("Player")
local v83 = v81:CreateTab("Auto Farm")

v82:AddLabel("MOVEMENT")

local u84 = LocalPlayer

v82:AddSlider("Walk Speed", 16, 300, 16, function(p3)
	local Character = u84.Character
	local v190 = Character and Character:FindFirstChildOfClass("Humanoid")

	if v190 then
		v190.WalkSpeed = p3
	end
end)

local u85 = LocalPlayer

v82:AddSlider("Jump Height", 50, 500, 50, function(p4)
	local Character = u85.Character
	local v193 = Character and Character:FindFirstChildOfClass("Humanoid")

	if v193 then
		v193.JumpHeight = p4

	end
end)
v82:AddSeparator()
v82:AddLabel("FLY")

local u86 = LocalPlayer

v82:AddToggle("Fly", function(p5)
	u16 = p5

	if not p5 then
		if connection then
			connection:Disconnect()
			connection = nil
		end

		if BodyVelocity then
			BodyVelocity:Destroy()
			BodyVelocity = nil
		end

		if BodyGyro then
			BodyGyro:Destroy()
			BodyGyro = nil
		end

		local Character = u86.Character

		if Character then
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				Humanoid.PlatformStand = false
			end
		end

		return

	end

	u77()
end)
v82:AddSlider("Fly Speed", 10, 300, 50, function(p6)
	n1 = p6
end)
v82:AddSeparator()
v82:AddLabel("NOCLIP")

local u87 = RunService
local u88 = LocalPlayer

v82:AddToggle("Noclip", function(p7)
	u22 = p7

	if not p7 then
		if u23 then
			u23:Disconnect()
			u23 = nil
		end

		local Character = u88.Character

		if Character then
			for _, descendant in ipairs(Character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = true
				end
			end
		end

		return
	end

	u23 = u87.Stepped:Connect(function()
		local Character = u88.Character

		if Character then
			for _, descendant in ipairs(Character:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = false

				end
			end
		end
	end)
end)
v82:AddSeparator()
v82:AddLabel("TELEPORT")

local u89 = nil
local u90 = t11
local u91 = LocalPlayer

u89 = v82:AddDropdown("Teleport to Place", t12, function(p8)
	for k, _ in pairs(p8) do
		local v205 = u90[k]
		local Character = u91.Character
		local v207 = Character and Character:FindFirstChild("HumanoidRootPart")

		if v205 and v207 then
			v207.CFrame = v205
		end

		u89:ClearSelection()

		return
	end
end)

local u92 = Players
local u93 = LocalPlayer

local function v94()
	local t13 = {}

	for _, player in ipairs(u92:GetPlayers()) do
		if player ~= u93 then
			local playerName = player.Name

			table.insert(t13, playerName)
		end
	end

	return t13
end

local u95 = nil
local u96 = v94

v82:AddButton("Refresh Players", function()
	u95:SetOptions((u96()))
end)

local v97 = v94()
local u98 = Players
local u99 = LocalPlayer

u95 = v82:AddDropdown("Teleport to Player", v97, function(p9)
	for k, _ in pairs(p9) do
		local k2 = u98:FindFirstChild(k)

		if k2 and k2.Character then
			local HumanoidRootPart = k2.Character:FindFirstChild("HumanoidRootPart")
			local Character = u99.Character
			local v218 = Character and Character:FindFirstChild("HumanoidRootPart")

			if HumanoidRootPart and v218 then
				v218.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)

			end
		end

		u95:ClearSelection()

		return
	end
end)
v82:AddSeparator()
v82:AddLabel("CASH")

local u100 = ReplicatedStorage

v82:AddToggle("Auto Collect Cash", function(p10)
	u21 = p10

	if p10 then
		task.spawn(function()
			local collectPetCash = u100:WaitForChild("Remotes"):WaitForChild("collectPetCash")

			while u21 do
				local PlayerPens = workspace:FindFirstChild("PlayerPens")

				if PlayerPens then
					for _, child in ipairs(PlayerPens:GetChildren()) do
						local PlrName
						local _pcall = pcall
						local u274 = child

						pcall(function()
							PlrName = u274.Sign.GuiPart.SignSurfaceGui.Holder.PlayerHolder.PlayerName.PlrName
						end)

						if nil then
							local Pets = child:FindFirstChild("Pets")

							if Pets then
								for _, child2 in ipairs(Pets:GetChildren()) do
									collectPetCash:FireServer(child2.Name)
									task.wait()
								end
							end

							break
						end
					end
				end

				task.wait(1)
			end
		end)
	end
end)
v83:AddLabel("FARMING")

local u102 = LocalPlayer
local u103 = v44
local u104 = t12
local u105 = t11
local u106 = v42

v83:AddToggle("Auto Farm", function(p11)

	u12 = p11

	if p11 then
		u8 = u102.Character or u102.CharacterAdded:Wait()
		task.spawn(function()
			local t14 = {}
			local n2 = 1
			local u280 = false

			while u12 do
				local v281 = u103()
				local t15 = {}

				for _, v in ipairs(v281) do
					local model = v.model

					if not t14[tostring(model)] then
						table.insert(t15, v)
					end
				end

				if #t15 ~= 0 then
					u280 = false

					local v286 = t15[1]
					local model = v286.model
					local str = tostring(model)
					local v289 = false

					for _ = 1, 3 do
						if not u12 or not v286.model or not v286.model.Parent then
							break
						end

						v289 = u106(v286)

						if v289 then

							break
						end
					end

					if not v289 then
						t14[str] = true
					end
				else
					t14 = {}

					if u27 and not u280 then
						u280 = true
						task.spawn(function()

							local g325 = nil
							local g338 = nil

							while u12 and u27 do
								local v319 = u104[n2]
								local v320 = u105[v319]
								local Character = u102.Character
								local v322 = Character and Character:FindFirstChild("HumanoidRootPart")

								if v320 and v322 then
									v322.CFrame = v320
								end

								local v323 = tick() + 5
								local v324 = false

								repeat
									if not (v323 > tick()) then
										g325 = true
									end

									if g325 then
										break
									end

									task.wait(0.2)

									if not u12 or not u27 then
										u280 = false

										return
									end
								until #u103() > 0

								if not g325 then
									v324 = true
								end

								g325 = false

								if not v324 then
									n2 = n2 % #u104 + 1

								else
									local v326 = tick() + 60

									while u12 and u27 and v326 > tick() do
										local v327 = u103()

										if #v327 ~= 0 then
											local v328 = v327[1]

											local model = v328.model
											local str = tostring(model)
											local v331 = false

											for _ = 1, 3 do
												if not u12 or not v328.model or not v328.model.Parent then

													break
												end

												v331 = u106(v328)

												if v331 then
													break
												end
											end

											if not v331 then
												t14[str] = true
											end

											task.wait(0.05)
										else
											local Character2 = u102.Character
											local v334 = Character2 and Character2:FindFirstChild("HumanoidRootPart")

											local v335 = u105[v319]

											if v335 and v334 then
												v334.CFrame = v335
											end

											local v336 = tick() + 5
											local v337 = false

											repeat
												if not (v336 > tick()) then
													g338 = true

												end

												if g338 then
													break

												end

												task.wait(0.2)

												if not u12 or not u27 then
													u280 = false

													return
												end
											until #u103() > 0

											if not g338 then
												v337 = true
											end

											g338 = false

											if not v337 then
												n2 = n2 % #u104 + 1

												break
											end
										end
									end

									n2 = n2 % #u104 + 1
								end

								task.wait(2)
							end

							u280 = false
						end)

					end

					task.wait(0.5)
				end

				task.wait(0.05)
			end
		end)
	end
end)
v83:AddToggle("Auto Travel If No Target", function(p12)
	u27 = p12
end)
v83:AddSeparator()
v83:AddLabel("FISHING")
v83:AddToggle("Auto Fish", function(p13)
	u24 = p13

	if not p13 then
		if connection2 then
			connection2:Disconnect()
			connection2 = nil
		end

		thread = nil

		return
	end

	u63()
end)
v83:AddSeparator()
v83:AddLabel("DIGGING")

local u107 = v67
local u108 = v65

local u109 = LocalPlayer

v83:AddToggle("Auto Dig", function(p14)
	u28 = p14

	if not p14 then
		u28 = false
		u29 = nil

		return
	end

	u29 = task.spawn(function()
		while u28 do
			local v293

			if not u107() then
				local v291 = u108()

				if v291 then
					local Character = u109.Character

					if Character then
						v291.Parent = Character
						task.wait(0.1)
						v293 = true

					else
						v293 = false
					end
				else
					v293 = false
				end
			else
				v293 = true
			end

			if v293 then
				local Character = u109.Character

				if Character and Character:FindFirstChild("HumanoidRootPart") then
					pcall(function()
						local StartDigging =
							game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DiggingService.RE.StartDigging
						local Character3 = u109.Character
						local v341 = Character3 and Character3:FindFirstChild("HumanoidRootPart")

						if v341 then
							StartDigging:FireServer(v341.CFrame)
						end
					end)
					pcall(function()
						game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DiggingService.RE.EndDigging:FireServer()
					end)
					task.wait(0.1)
				else
					task.wait(0.5)
				end
			else
				task.wait(1)
			end
		end
	end)
end)
v83:AddSeparator()
v83:AddLabel("FILTERS")
v83:AddDropdown(
	"Select Animals",
	(function()
		local t16 = {}
		local t17 = {}
		local v125 = u33:FindFirstChild("Assets") and u33.Assets:FindFirstChild("Pets")

		if v125 then
			for _, child in ipairs(v125:GetChildren()) do
				if child:IsA("Model") and not t17[child.Name] then
					t17[child.Name] = true

					local childName = child.Name

					table.insert(t16, childName)
				end
			end
		end

		table.sort(t16)

		return t16
	end)(),
	function(p15)
		t4 = p15
	end
)
v83:AddDropdown("Select Mutation", t2, function(p16)
	t5 = p16
end)
v83:AddDropdown("Select Rarity", t1, function(p17)
	t6 = p17
end)

Notify({Title="Discord", Content="Dont forget to join https://discord.gg/TtH3rBCyrv", Duration=5})