-- ShinyLib v1 - ShinyHub custom UI
local ShinyLib = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local THEME = {
    Bg = Color3.fromRGB(10,10,12),
    Card = Color3.fromRGB(18,18,20),
    Accent = Color3.fromRGB(140,90,255),
    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(160,160,170)
}

function ShinyLib:CreateWindow(opts)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ShinyHub"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 620, 0, 420)
    Main.Position = UDim2.new(0.5, -310, 0.5, -210)
    Main.BackgroundColor3 = THEME.Bg
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    Main.Parent = ScreenGui
    Main.Active = true
    Main.Draggable = true

    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 50)
    Top.BackgroundColor3 = THEME.Card
    Top.Parent = Main
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Text = opts.Name or "ShinyHub"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = THEME.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 150, 1, -60)
    TabBar.Position = UDim2.new(0, 10, 0, 60)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Main
    local TabLayout = Instance.new("UIListLayout", TabBar)
    TabLayout.Padding = UDim.new(0, 6)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -180, 1, -60)
    Content.Position = UDim2.new(0, 170, 0, 60)
    Content.BackgroundColor3 = THEME.Card
    Content.Parent = Main
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

    local ContentLayout = Instance.new("ScrollingFrame", Content)
    ContentLayout.Size = UDim2.new(1, -10, 1, -10)
    ContentLayout.Position = UDim2.new(0, 5, 0, 5)
    ContentLayout.BackgroundTransparency = 1
    ContentLayout.ScrollBarThickness = 2
    ContentLayout.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentLayout.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local List = Instance.new("UIListLayout", ContentLayout)
    List.Padding = UDim.new(0, 8)

    UIS.InputBegan:Connect(function(i,gpe) if not gpe and i.KeyCode == Enum.KeyCode[opts.ToggleUIKeybind or "K"] then Main.Visible = not Main.Visible end end)

    local Window = {}
    function Window:CreateTab(tabOpts)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Text = tabOpts.Name
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = THEME.Card
        TabBtn.TextColor3 = THEME.Text
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 14
        TabBtn.Parent = TabBar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        local Tab = {}
        function Tab:CreateSection(name)
            local L = Instance.new("TextLabel")
            L.Text = name
            L.Font = Enum.Font.GothamBold
            L.TextColor3 = THEME.Accent
            L.TextSize = 12
            L.BackgroundTransparency = 1
            L.Size = UDim2.new(1, 0, 0, 20)
            L.Parent = ContentLayout
        end
        function Tab:CreateToggle(t)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 36)
            Btn.BackgroundColor3 = THEME.Bg
            Btn.Text = ""
            Btn.Parent = ContentLayout
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            local Label = Instance.new("TextLabel", Btn)
            Label.Text = t.Name
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = THEME.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            local State = t.CurrentValue or false
            local Box = Instance.new("Frame", Btn)
            Box.Size = UDim2.new(0, 40, 0, 20)
            Box.Position = UDim2.new(1, -50, 0.5, -10)
            Box.BackgroundColor3 = State and THEME.Accent or Color3.fromRGB(50,50,55)
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1,0)
            Btn.MouseButton1Click:Connect(function()
                State = not State
                TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = State and THEME.Accent or Color3.fromRGB(50,50,55)}):Play()
                if t.Callback then t.Callback(State) end
            end)
            if t.Flag and opts.ConfigurationSaving and opts.ConfigurationSaving.Enabled then
                -- save stub
            end
        end
        function Tab:CreateButton(t) 
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 36)
            Btn.BackgroundColor3 = THEME.Accent
            Btn.Text = t.Name
            Btn.TextColor3 = THEME.Text
            Btn.Font = Enum.Font.GothamBold
            Btn.Parent = ContentLayout
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            Btn.MouseButton1Click:Connect(function() if t.Callback then t.Callback() end end)
        end
        function Tab:CreateSlider(t)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 50)
            Frame.BackgroundColor3 = THEME.Bg
            Frame.Parent = ContentLayout
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
            local Label = Instance.new("TextLabel", Frame)
            Label.Text = t.Name .. ": " .. tostring(t.CurrentValue or t.Range[1])
            Label.Size = UDim2.new(1, -10, 0, 20)
            Label.Position = UDim2.new(0, 5, 0, 5)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = THEME.Text
            Label.TextSize = 12
            -- slider bar omitted for brevity - add drag logic here
        end
        function Tab:CreateDropdown(t)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 36)
            Btn.BackgroundColor3 = THEME.Bg
            Btn.Text = t.Name .. " ▼"
            Btn.TextColor3 = THEME.Text
            Btn.Parent = ContentLayout
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            Btn.MouseButton1Click:Connect(function() if t.Callback then t.Callback(t.Options[1]) end end)
        end
        function Tab:CreateInput(t)
            local Box = Instance.new("TextBox")
            Box.PlaceholderText = t.PlaceholderText
            Box.Size = UDim2.new(1, 0, 0, 36)
            Box.BackgroundColor3 = THEME.Bg
            Box.TextColor3 = THEME.Text
            Box.Parent = ContentLayout
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
            Box.FocusLost:Connect(function() if t.Callback then t.Callback(Box.Text) end end)
        end
        function Tab:CreateParagraph(t)
            local L = Instance.new("TextLabel")
            L.Text = t.Title .. "\n" .. t.Content
            L.TextWrapped = true
            L.Size = UDim2.new(1, 0, 0, 40)
            L.BackgroundTransparency = 1
            L.TextColor3 = THEME.SubText
            L.Parent = ContentLayout
        end
        return Tab
    end
    function ShinyLib:Notify(opts) print("[ShinyHub]", opts.Title, opts.Content) end
    return Window
end

return ShinyLib
