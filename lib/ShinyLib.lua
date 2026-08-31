local ShinyLib = {}
ShinyLib.Flags = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Theme = {
    Bg = Color3.fromRGB(16,16,18),
    Card = Color3.fromRGB(24,24,27),
    Element = Color3.fromRGB(32,32,36),
    Accent = Color3.fromRGB(130,85,255),
    Text = Color3.fromRGB(235,235,235),
    SubText = Color3.fromRGB(140,140,150),
    Stroke = Color3.fromRGB(38,38,42)
}

function ShinyLib:CreateWindow(opts)
    local Parent = (gethui and gethui()) or game:GetService("CoreGui")
    local Gui = Instance.new("ScreenGui", Parent)
    Gui.Name = "ShinyHub"
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0, 640, 0, 420)
    Main.Position = UDim2.new(0.5, -320, 0.5, -210)
    Main.BackgroundColor3 = Theme.Bg
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Main).Color = Theme.Stroke
    Main.Active = true
    Main.Draggable = true

    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1, 0, 0, 44)
    Top.BackgroundColor3 = Theme.Card
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 8)
    local TopFix = Instance.new("Frame", Top)
    TopFix.Size = UDim2.new(1,0,0,8)
    TopFix.Position = UDim2.new(0,0,1,-8)
    TopFix.BackgroundColor3 = Theme.Card
    TopFix.BorderSizePixel = 0
    TopFix.ZIndex = 0

    local Title = Instance.new("TextLabel", Top)
    Title.Text = opts.Name or "ShinyHub"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Theme.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(0, 150, 1, -54)
    TabBar.Position = UDim2.new(0, 8, 0, 54)
    TabBar.BackgroundTransparency = 1
    Instance.new("UIListLayout", TabBar).Padding = UDim.new(0, 4)

    local ContentHolder = Instance.new("Frame", Main)
    ContentHolder.Size = UDim2.new(1, -168, 1, -54)
    ContentHolder.Position = UDim2.new(0, 162, 0, 54)
    ContentHolder.BackgroundColor3 = Theme.Card
    ContentHolder.ClipsDescendants = true
    Instance.new("UICorner", ContentHolder).CornerRadius = UDim.new(0, 8)

    local Tabs = {}
    local Current = nil

    UserInputService.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode == Enum.KeyCode[opts.ToggleUIKeybind or "K"] then Gui.Enabled = not Gui.Enabled end end)

    local Window = {}
    function Window:CreateTab(tabOpts)
        local TabBtn = Instance.new("TextButton", TabBar)
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Card
        TabBtn.Text = "  "..(tabOpts.Name or "Tab")
        TabBtn.TextColor3 = Theme.SubText
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 12
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.BackgroundTransparency = 1
        Scroll.ScrollBarThickness = 2
        Scroll.ScrollBarImageColor3 = Theme.Stroke
        Scroll.CanvasSize = UDim2.new(0,0,0,0)
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Scroll.Visible = false
        Scroll.Parent = ContentHolder
        local Pad = Instance.new("UIPadding", Scroll)
        Pad.PaddingTop = UDim.new(0,8) Pad.PaddingBottom = UDim.new(0,8) Pad.PaddingLeft = UDim.new(0,8) Pad.PaddingRight = UDim.new(0,8)
        local List = Instance.new("UIListLayout", Scroll)
        List.Padding = UDim.new(0,6)
        List.SortOrder = Enum.SortOrder.LayoutOrder

        local function Select()
            for _, t in pairs(Tabs) do
                t.Btn.BackgroundColor3 = Theme.Card
                t.Btn.TextColor3 = Theme.SubText
                t.Scroll.Visible = false
            end
            TabBtn.BackgroundColor3 = Theme.Element
            TabBtn.TextColor3 = Theme.Text
            Scroll.Visible = true
            Current = Scroll
        end
        TabBtn.MouseButton1Click:Connect(Select)
        if #Tabs == 0 then task.defer(Select) end
        table.insert(Tabs, {Btn=TabBtn, Scroll=Scroll})

        local Tab = {}
        function Tab:CreateSection(name)
            local L = Instance.new("TextLabel", Scroll)
            L.Text = name:upper()
            L.Font = Enum.Font.GothamBold
            L.TextSize = 10
            L.TextColor3 = Theme.Accent
            L.BackgroundTransparency = 1
            L.Size = UDim2.new(1,0,0,16)
            L.TextXAlignment = Enum.TextXAlignment.Left
        end
        function Tab:CreateToggle(t)
            local State = t.CurrentValue or t.Default or false
            if t.Flag and ShinyLib.Flags[t.Flag] ~= nil then State = ShinyLib.Flags[t.Flag] end
            local F = Instance.new("Frame", Scroll)
            F.Size = UDim2.new(1, -4, 0, 34)
            F.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            local L = Instance.new("TextLabel", F)
            L.Text = t.Name
            L.Font = Enum.Font.Gotham
            L.TextSize = 12
            L.TextColor3 = Theme.Text
            L.BackgroundTransparency = 1
            L.Size = UDim2.new(1, -56, 1, 0)
            L.Position = UDim2.new(0, 8, 0, 0)
            L.TextXAlignment = Enum.TextXAlignment.Left
            local Toggle = Instance.new("Frame", F)
            Toggle.Size = UDim2.new(0, 36, 0, 18)
            Toggle.Position = UDim2.new(1, -44, 0.5, -9)
            Toggle.BackgroundColor3 = State and Theme.Accent or Color3.fromRGB(45,45,50)
            Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)
            local Dot = Instance.new("Frame", Toggle)
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)
            local Btn = Instance.new("TextButton", F)
            Btn.Size = UDim2.new(1,0,1,0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            local function Update(s)
                State = s
                if t.Flag then ShinyLib.Flags[t.Flag]=s end
                TweenService:Create(Toggle,TweenInfo.new(0.15),{BackgroundColor3 = s and Theme.Accent or Color3.fromRGB(45,45,50)}):Play()
                TweenService:Create(Dot,TweenInfo.new(0.15),{Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                if t.Callback then t.Callback(s) end
            end
            Btn.MouseButton1Click:Connect(function() Update(not State) end)
            if State and t.Callback then task.defer(function() t.Callback(State) end) end
        end
        function Tab:CreateButton(b)
            local Btn = Instance.new("TextButton", Scroll)
            Btn.Size = UDim2.new(1, -4, 0, 34)
            Btn.BackgroundColor3 = Theme.Accent
            Btn.Text = b.Name
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 12
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Btn.MouseButton1Click:Connect(function() if b.Callback then b.Callback() end end)
        end
        function Tab:CreateSlider(s) 
            local Val = s.CurrentValue or s.Range[1]
            local F = Instance.new("Frame", Scroll)
            F.Size = UDim2.new(1, -4, 0, 44)
            F.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            local L = Instance.new("TextLabel", F)
            L.Text = s.Name
            L.Font = Enum.Font.Gotham
            L.TextSize = 11
            L.TextColor3 = Theme.Text
            L.BackgroundTransparency = 1
            L.Size = UDim2.new(1, -50, 0, 16)
            L.Position = UDim2.new(0, 8, 0, 4)
            L.TextXAlignment = Enum.TextXAlignment.Left
            local V = Instance.new("TextLabel", F)
            V.Text = tostring(Val)..(s.Suffix or "")
            V.Font = Enum.Font.GothamBold
            V.TextSize = 11
            V.TextColor3 = Theme.Accent
            V.BackgroundTransparency = 1
            V.Size = UDim2.new(0, 50, 0, 16)
            V.Position = UDim2.new(1, -52, 0, 4)
            V.TextXAlignment = Enum.TextXAlignment.Right
            local Bar = Instance.new("Frame", F)
            Bar.Size = UDim2.new(1, -16, 0, 4)
            Bar.Position = UDim2.new(0, 8, 1, -12)
            Bar.BackgroundColor3 = Color3.fromRGB(45,45,50)
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)
            local Fill = Instance.new("Frame", Bar)
            Fill.BackgroundColor3 = Theme.Accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)
            local function Set(v)
                v = math.clamp(v,s.Range[1],s.Range[2])
                if s.Increment then v = math.round(v/s.Increment)*s.Increment end
                Val = v
                V.Text = tostring(v)..(s.Suffix or "")
                Fill.Size = UDim2.new((v - s.Range[1])/(s.Range[2]-s.Range[1]),0,1,0)
                if s.Callback then s.Callback(v) end
            end
            Set(Val)
            local Drag=false
            Bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Drag=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then Drag=false end end)
            UserInputService.InputChanged:Connect(function(i) if Drag and i.UserInputType==Enum.UserInputType.MouseMovement then local pct=math.clamp((i.Position.X-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1) Set(s.Range[1]+pct*(s.Range[2]-s.Range[1])) end end)
        end
        function Tab:CreateDropdown(d)
            local Cur = d.CurrentOption and d.CurrentOption[1] or d.Options[1]
            local F = Instance.new("Frame", Scroll)
            F.Size = UDim2.new(1, -4, 0, 34)
            F.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            local Btn = Instance.new("TextButton", F)
            Btn.Size = UDim2.new(1,0,1,0)
            Btn.BackgroundTransparency = 1
            Btn.Text = d.Name.." : "..tostring(Cur)
            Btn.TextColor3 = Theme.Text
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 12
            local List = Instance.new("Frame", F)
            List.Visible = false
            List.Size = UDim2.new(1,0,0, math.min(#d.Options*26,130))
            List.Position = UDim2.new(0,0,1,4)
            List.BackgroundColor3 = Theme.Card
            List.ZIndex = 10
            Instance.new("UICorner", List).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", List).Color = Theme.Stroke
            local SF = Instance.new("ScrollingFrame", List)
            SF.Size = UDim2.new(1,0,1,0)
            SF.BackgroundTransparency = 1
            SF.ScrollBarThickness = 2
            SF.CanvasSize = UDim2.new(0,0,0,0)
            SF.AutomaticCanvasSize = Enum.AutomaticSize.Y
            local LL = Instance.new("UIListLayout", SF)
            LL.Padding = UDim.new(0,2)
            for _, opt in ipairs(d.Options) do
                local O = Instance.new("TextButton", SF)
                O.Size = UDim2.new(1,0,0,24)
                O.BackgroundColor3 = Theme.Element
                O.Text = opt
                O.TextColor3 = Theme.Text
                O.Font = Enum.Font.Gotham
                O.TextSize = 11
                Instance.new("UICorner", O).CornerRadius = UDim.new(0, 4)
                O.MouseButton1Click:Connect(function()
                    Cur = opt
                    Btn.Text = d.Name.." : "..opt
                    List.Visible = false
                    if d.Callback then d.Callback(Cur) end
                end)
            end
            Btn.MouseButton1Click:Connect(function() List.Visible = not List.Visible end)
        end
        function Tab:CreateInput(i)
            local F = Instance.new("Frame", Scroll)
            F.Size = UDim2.new(1, -4, 0, 34)
            F.BackgroundColor3 = Theme.Element
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            local TB = Instance.new("TextBox", F)
            TB.Size = UDim2.new(1, -12, 1, -8)
            TB.Position = UDim2.new(0, 6, 0, 4)
            TB.BackgroundColor3 = Theme.Bg
            TB.TextColor3 = Theme.Text
            TB.PlaceholderText = i.PlaceholderText or i.Name
            TB.Text = ""
            TB.Font = Enum.Font.Gotham
            TB.TextSize = 12
            Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 4)
            TB.FocusLost:Connect(function() if i.Callback then i.Callback(TB.Text) end end)
        end
        function Tab:CreateParagraph(p)
            local F = Instance.new("Frame", Scroll)
            F.Size = UDim2.new(1, -4, 0, 44)
            F.BackgroundColor3 = Theme.Bg
            Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
            local T = Instance.new("TextLabel", F)
            T.Text = p.Title
            T.Font = Enum.Font.GothamBold
            T.TextSize = 12
            T.TextColor3 = Theme.Text
            T.BackgroundTransparency = 1
            T.Size = UDim2.new(1,-8,0,16)
            T.Position = UDim2.new(0,6,0,4)
            T.TextXAlignment = Enum.TextXAlignment.Left
            local C = Instance.new("TextLabel", F)
            C.Text = p.Content
            C.Font = Enum.Font.Gotham
            C.TextSize = 11
            C.TextColor3 = Theme.SubText
            C.BackgroundTransparency = 1
            C.Size = UDim2.new(1,-8,0,20)
            C.Position = UDim2.new(0,6,0,20)
            C.TextWrapped = true
        end
        return Tab
    end
    function ShinyLib:Notify(n)
        local Holder = Gui:FindFirstChild("NotifyHolder") or Instance.new("Frame", Gui)
        Holder.Name = "NotifyHolder"
        Holder.Size = UDim2.new(0, 280, 1, 0)
        Holder.Position = UDim2.new(1, -290, 0, 10)
        Holder.BackgroundTransparency = 1
        if not Holder:FindFirstChild("UIListLayout") then
            local L = Instance.new("UIListLayout", Holder)
            L.Padding = UDim.new(0,6)
        end
        local F = Instance.new("Frame", Holder)
        F.Size = UDim2.new(1,0,0,56)
        F.BackgroundColor3 = Theme.Card
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", F).Color = Theme.Accent
        local T = Instance.new("TextLabel", F)
        T.Text = n.Title or "ShinyHub"
        T.Font = Enum.Font.GothamBold
        T.TextSize = 12
        T.TextColor3 = Theme.Text
        T.BackgroundTransparency = 1
        T.Size = UDim2.new(1,-8,0,18)
        T.Position = UDim2.new(0,8,0,6)
        T.TextXAlignment = Enum.TextXAlignment.Left
        local C = Instance.new("TextLabel", F)
        C.Text = n.Content or ""
        C.Font = Enum.Font.Gotham
        C.TextSize = 11
        C.TextColor3 = Theme.SubText
        C.BackgroundTransparency = 1
        C.Size = UDim2.new(1,-8,0,28)
        C.Position = UDim2.new(0,8,0,22)
        C.TextWrapped = true
        task.delay(n.Duration or 3, function() pcall(function() F:Destroy() end) end)
    end
    return Window
end

return ShinyLib
