-- ==============================================
-- 🎨 SIMPLEGUI v6.3 - SIDEBAR TABS (VERTICAL) - AESTHETIC EDITION
-- WITH v7 FINAL UI + GLASSMORPHISM
-- ==============================================
print("🔧 Loading SimpleGUI Aesthetic Edition...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Modern color schemes dengan gradient
SimpleGUI.Themes = {
    DARK = {
        Name = "Dark",
        Primary = Color3.fromRGB(20, 20, 30),
        Secondary = Color3.fromRGB(30, 30, 45),
        Accent = Color3.fromRGB(120, 90, 255),  -- Ungu aesthetic
        AccentLight = Color3.fromRGB(160, 140, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 220),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 80, 100),
        Border = Color3.fromRGB(50, 50, 70),
        Hover = Color3.fromRGB(70, 70, 100),
        Active = Color3.fromRGB(140, 110, 255),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(18, 18, 25),
        TitleBar = Color3.fromRGB(25, 25, 35),
        TabNormal = Color3.fromRGB(35, 35, 50),
        TabActive = Color3.fromRGB(120, 90, 255),
        ContentBg = Color3.fromRGB(22, 22, 32),
        Button = Color3.fromRGB(45, 45, 65),
        InputBg = Color3.fromRGB(40, 40, 55),
        ToggleOff = Color3.fromRGB(60, 60, 80),
        ToggleOn = Color3.fromRGB(120, 90, 255),
        SliderTrack = Color3.fromRGB(50, 50, 70),
        SliderFill = Color3.fromRGB(120, 90, 255),
        Sidebar = Color3.fromRGB(25, 25, 38)
    }
}

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI Aesthetic Edition...")
    
    local self = setmetatable({}, SimpleGUI)
    
    -- Destroy existing GUI
    pcall(function() game:GetService("CoreGui").SimpleGUI:Destroy() end)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SimpleGUI_Aesthetic"
    self.ScreenGui.DisplayOrder = 99999
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    -- Auto parenting
    local parents = {
        game:GetService("CoreGui"),
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    }
    
    for _, parent in ipairs(parents) do
        pcall(function()
            self.ScreenGui.Parent = parent
            task.wait(0.05)
        end)
        if self.ScreenGui.Parent then break end
    end
    
    self.Windows = {}
    self.CurrentTheme = "DARK"
    
    print("✅ SimpleGUI Aesthetic Edition initialized!")
    return self
end

-- Theme management
function SimpleGUI:SetTheme(themeName)
    if self.Themes[themeName:upper()] then
        self.CurrentTheme = themeName:upper()
        print("🎨 Applied theme: " .. self.Themes[self.CurrentTheme].Name)
        
        for _, window in pairs(self.Windows) do
            if window.UpdateTheme then
                window:UpdateTheme(self.Themes[self.CurrentTheme])
            end
        end
    end
end

function SimpleGUI:GetTheme()
    return self.Themes[self.CurrentTheme]
end

-- Animation helper
local function tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Create window with SIDEBAR TABS (Aesthetic Edition)
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local isMobile = UserInputService.TouchEnabled
    local scale = isMobile and 0.85 or 1.0
    
    local windowData = {
        Name = opts.Name or "Window",
        Size = opts.Size or UDim2.new(0, 700 * scale, 0, 420 * scale),
        Position = opts.Position or UDim2.new(0.5, -350 * scale, 0.5, -210 * scale),
        ShowThemeTab = opts.ShowThemeTab or false,
        IsMobile = isMobile,
        Scale = scale,
        SidebarWidth = 180 * scale
    }
    
    local theme = self:GetTheme()
    
    -- ===== MAIN WINDOW FRAME =====
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = windowData.Name .. "_Window"
    MainFrame.Size = windowData.Size
    MainFrame.Position = windowData.Position
    MainFrame.BackgroundColor3 = theme.WindowBg
    MainFrame.BackgroundTransparency = 0
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = true
    MainFrame.Parent = self.ScreenGui
    
    -- Rounded corners
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 16 * scale)  -- Lebih bulat
    WindowCorner.Parent = MainFrame
    
    -- ===== SHADOW EFFECT (Aesthetic) =====
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045157"  -- Shadow image
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- ===== TITLE BAR =====
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42 * scale)
    TitleBar.BackgroundColor3 = theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 16 * scale)
    TitleBarCorner.Parent = TitleBar
    
    -- ===== GRADIENT EFFECT (Title Bar) =====
    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.TitleBar),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, theme.TitleBar)
    })
    TitleGradient.Rotation = 90
    TitleGradient.Parent = TitleBar
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -120 * scale, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14 * scale, 0, 0)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 18 * scale  -- Lebih besar
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Control Buttons with hover effects
    local function createButton(text, color, x, isClose)
        local btn = Instance.new("TextButton")
        btn.Name = "Button_" .. text
        btn.Size = UDim2.fromOffset(28 * scale, 28 * scale)
        btn.Position = UDim2.new(1, x * scale, 0.5, -14 * scale)
        btn.Text = text
        btn.TextColor3 = isClose and theme.Error or theme.Text
        btn.BackgroundColor3 = theme.Button
        btn.BackgroundTransparency = 0
        btn.TextSize = 16 * scale
        btn.Font = Enum.Font.GothamBold
        btn.Parent = TitleBar
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8 * scale)
        corner.Parent = btn
        
        -- Hover effect
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = theme.Hover}, 0.1)
            if isClose then
                tween(btn, {TextColor3 = Color3.new(1, 1, 1)}, 0.1)
            end
        end)
        
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = theme.Button}, 0.1)
            if isClose then
                tween(btn, {TextColor3 = theme.Error}, 0.1)
            end
        end)
        
        return btn
    end
    
    local ThemeButton = createButton("🎨", theme.Text, -70)
    ThemeButton.Visible = windowData.ShowThemeTab
    local MinimizeButton = createButton("_", theme.Text, -36)
    local CloseButton = createButton("✕", theme.Error, 0, true)
    
    -- ===== SIDEBAR =====
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, windowData.SidebarWidth, 1, -42 * scale)
    Sidebar.Position = UDim2.new(0, 0, 0, 42 * scale)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- Sidebar Gradient
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.Sidebar),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, theme.Sidebar)
    })
    SidebarGradient.Rotation = 90
    SidebarGradient.Parent = Sidebar
    
    -- Sidebar layout
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 8 * scale)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 12 * scale)
    SidebarPadding.PaddingLeft = UDim.new(0, 12 * scale)
    SidebarPadding.PaddingRight = UDim.new(0, 12 * scale)
    SidebarPadding.Parent = Sidebar
    
    -- ===== CONTENT FRAME =====
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -windowData.SidebarWidth, 1, -42 * scale)
    ContentFrame.Position = UDim2.new(0, windowData.SidebarWidth, 0, 42 * scale)
    ContentFrame.BackgroundColor3 = theme.ContentBg
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4 * scale
    ContentFrame.ScrollBarImageColor3 = theme.Accent
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentFrame.Parent = MainFrame
    
    -- Content Gradient
    local ContentGradient = Instance.new("UIGradient")
    ContentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.ContentBg),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 28, 40)),
        ColorSequenceKeypoint.new(1, theme.ContentBg)
    })
    ContentGradient.Rotation = 90
    ContentGradient.Parent = ContentFrame
    
    -- Content layout
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 10 * scale)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 15 * scale)
    ContentPadding.PaddingRight = UDim.new(0, 15 * scale)
    ContentPadding.PaddingTop = UDim.new(0, 15 * scale)
    ContentPadding.PaddingBottom = UDim.new(0, 15 * scale)
    ContentPadding.Parent = ContentFrame
    
    -- ===== WINDOW OBJECT =====
    local windowObj = {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        Sidebar = Sidebar,
        ContentFrame = ContentFrame,
        Tabs = {},
        ActiveTab = nil,
        WindowData = windowData,
        
        UpdateTheme = function(self, newTheme)
            theme = newTheme
            
            MainFrame.BackgroundColor3 = theme.WindowBg
            TitleBar.BackgroundColor3 = theme.TitleBar
            TitleLabel.TextColor3 = theme.Text
            Sidebar.BackgroundColor3 = theme.Sidebar
            ContentFrame.BackgroundColor3 = theme.ContentBg
            ContentFrame.ScrollBarImageColor3 = theme.Accent
            
            ThemeButton.BackgroundColor3 = theme.Button
            ThemeButton.TextColor3 = theme.Text
            MinimizeButton.BackgroundColor3 = theme.Button
            MinimizeButton.TextColor3 = theme.Text
            CloseButton.BackgroundColor3 = theme.Button
            CloseButton.TextColor3 = theme.Error
            
            for tabName, tabData in pairs(self.Tabs) do
                if tabData.Button then
                    tabData.Button.BackgroundColor3 = theme.TabNormal
                    tabData.Button.TextColor3 = theme.Text
                    
                    if self.ActiveTab == tabName then
                        tabData.Button.BackgroundColor3 = theme.TabActive
                        tabData.Button.TextColor3 = Color3.new(1, 1, 1)
                    end
                end
                
                if tabData.UpdateTheme then
                    tabData:UpdateTheme(newTheme)
                end
            end
        end,
        
        SetVisible = function(self, visible)
            MainFrame.Visible = visible
        end,
        
        Destroy = function(self)
            MainFrame:Destroy()
        end
    }
    
    self.Windows[windowData.Name] = windowObj
    
    -- ===== TAB CREATION =====
    function windowObj:CreateTab(options)
        local tabOptions = type(options) == "string" and {Name = options} or (options or {})
        local tabName = tabOptions.Name or "Tab_" .. (#self.Tabs + 1)
        local scale = self.WindowData.Scale
        
        -- Tab Button (Aesthetic)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(1, 0, 0, 38 * scale)  -- Lebih tinggi
        TabButton.Text = "  " .. tabName
        TabButton.TextColor3 = theme.Text
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 14 * scale
        TabButton.Font = Enum.Font.GothamSemibold  -- Font lebih modern
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = self.Sidebar
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 10 * scale)  -- Lebih bulat
        TabButtonCorner.Parent = TabButton
        
        -- Tab hover effect
        TabButton.MouseEnter:Connect(function()
            if self.ActiveTab ~= tabName then
                tween(TabButton, {BackgroundColor3 = theme.Hover}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if self.ActiveTab ~= tabName then
                tween(TabButton, {BackgroundColor3 = theme.TabNormal}, 0.1)
            end
        end)
        
        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Name = tabName .. "_Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = self.ContentFrame
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 10 * scale)
        TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        -- Tab click handler with animation
        TabButton.MouseButton1Click:Connect(function()
            for name, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tween(tab.Button, {BackgroundColor3 = theme.TabNormal}, 0.1)
                tab.Button.TextColor3 = theme.Text
            end
            
            TabContent.Visible = true
            tween(TabButton, {BackgroundColor3 = theme.TabActive}, 0.1)
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            self.ActiveTab = tabName
        end)
        
        -- ===== TAB BUILDER METHODS (Aesthetic) =====
        local tabObj = {
            Button = TabButton,
            Content = TabContent,
            Elements = {},
            ElementObjects = {},
            
            UpdateTheme = function(self, newTheme)
                TabButton.BackgroundColor3 = newTheme.TabNormal
                TabButton.TextColor3 = newTheme.Text
                
                if windowObj.ActiveTab == tabName then
                    TabButton.BackgroundColor3 = newTheme.TabActive
                    TabButton.TextColor3 = Color3.new(1, 1, 1)
                end
            end,
            
            CreateButton = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local Button = Instance.new("TextButton")
                Button.Name = opts.Name or "Button_" .. #self.Elements + 1
                Button.Size = UDim2.new(0.9, 0, 0, 38 * scale)
                Button.Text = opts.Text or Button.Name
                Button.TextColor3 = theme.Text
                Button.BackgroundColor3 = theme.Button
                Button.BackgroundTransparency = 0
                Button.TextSize = 14 * scale
                Button.Font = Enum.Font.GothamSemibold
                Button.AutoButtonColor = false
                Button.LayoutOrder = #self.Elements + 1
                Button.Parent = TabContent
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 10 * scale)
                Corner.Parent = Button
                
                -- Hover effect
                Button.MouseEnter:Connect(function()
                    tween(Button, {BackgroundColor3 = theme.Hover}, 0.1)
                end)
                
                Button.MouseLeave:Connect(function()
                    tween(Button, {BackgroundColor3 = theme.Button}, 0.1)
                end)
                
                Button.MouseButton1Click:Connect(function()
                    tween(Button, {BackgroundColor3 = theme.Active}, 0.05)
                    task.wait(0.1)
                    tween(Button, {BackgroundColor3 = theme.Button}, 0.05)
                    
                    if opts.Callback then
                        pcall(opts.Callback)
                    end
                end)
                
                table.insert(self.Elements, Button)
                return Button
            end,
            
            CreateLabel = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local Label = Instance.new("TextLabel")
                Label.Name = opts.Name or "Label_" .. #self.Elements + 1
                Label.Size = UDim2.new(0.9, 0, 0, 28 * scale)
                Label.Text = opts.Text or Label.Name
                Label.TextColor3 = theme.Text
                Label.BackgroundTransparency = 1
                Label.TextSize = 14 * scale
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = opts.Alignment or Enum.TextXAlignment.Left
                Label.LayoutOrder = #self.Elements + 1
                Label.Parent = TabContent
                
                table.insert(self.Elements, Label)
                return Label
            end,
            
            CreateInput = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local InputFrame = Instance.new("Frame")
                InputFrame.Name = opts.Name or "Input_" .. #self.Elements + 1
                InputFrame.Size = UDim2.new(0.9, 0, 0, 42 * scale)
                InputFrame.BackgroundTransparency = 1
                InputFrame.LayoutOrder = #self.Elements + 1
                InputFrame.Parent = TabContent
                
                local InputBox = Instance.new("TextBox")
                InputBox.Name = "TextBox"
                InputBox.Size = UDim2.new(1, 0, 1, 0)
                InputBox.Text = opts.CurrentValue or ""
                InputBox.PlaceholderText = opts.PlaceholderText or "Enter text..."
                InputBox.PlaceholderColor3 = theme.TextSecondary
                InputBox.TextColor3 = theme.Text
                InputBox.BackgroundColor3 = theme.InputBg
                InputBox.BackgroundTransparency = 0
                InputBox.TextSize = 14 * scale
                InputBox.Font = Enum.Font.Gotham
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = InputFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 10 * scale)
                Corner.Parent = InputBox
                
                local Padding = Instance.new("UIPadding")
                Padding.PaddingLeft = UDim.new(0, 12 * scale)
                Padding.PaddingRight = UDim.new(0, 12 * scale)
                Padding.Parent = InputBox
                
                InputBox.Focused:Connect(function()
                    tween(InputBox, {BackgroundColor3 = theme.Hover}, 0.1)
                end)
                
                InputBox.FocusLost:Connect(function()
                    tween(InputBox, {BackgroundColor3 = theme.InputBg}, 0.1)
                    if opts.Callback then
                        pcall(opts.Callback, InputBox.Text)
                    end
                end)
                
                table.insert(self.Elements, InputFrame)
                return InputBox
            end,
            
            CreateToggle = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = opts.Name or "Toggle_" .. #self.Elements + 1
                ToggleFrame.Size = UDim2.new(0.9, 0, 0, 38 * scale)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.LayoutOrder = #self.Elements + 1
                ToggleFrame.Parent = TabContent
                
                -- Toggle button with animation
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Text = (opts.Text or opts.Name or "Toggle") .. " : OFF"
                ToggleButton.TextColor3 = theme.Text
                ToggleButton.BackgroundColor3 = theme.Button
                ToggleButton.BackgroundTransparency = 0
                ToggleButton.TextSize = 14 * scale
                ToggleButton.Font = Enum.Font.GothamSemibold
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = ToggleFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 10 * scale)
                Corner.Parent = ToggleButton
                
                -- Hover effect
                ToggleButton.MouseEnter:Connect(function()
                    tween(ToggleButton, {BackgroundColor3 = theme.Hover}, 0.1)
                end)
                
                ToggleButton.MouseLeave:Connect(function()
                    local targetColor = isToggled and theme.ToggleOn or theme.Button
                    tween(ToggleButton, {BackgroundColor3 = targetColor}, 0.1)
                end)
                
                local isToggled = opts.CurrentValue or false
                
                local function updateToggle()
                    ToggleButton.Text = (opts.Text or opts.Name or "Toggle") .. " : " .. (isToggled and "ON" or "OFF")
                    local targetColor = isToggled and theme.ToggleOn or theme.Button
                    tween(ToggleButton, {BackgroundColor3 = targetColor}, 0.15)
                end
                
                updateToggle()
                
                ToggleButton.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    updateToggle()
                    
                    if opts.Callback then
                        pcall(opts.Callback, isToggled)
                    end
                end)
                
                table.insert(self.Elements, ToggleFrame)
                
                return {
                    Frame = ToggleFrame,
                    Button = ToggleButton,
                    GetValue = function() return isToggled end,
                    SetValue = function(value)
                        isToggled = value
                        updateToggle()
                    end
                }
            end,
            
            CreateSlider = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = opts.Name or "Slider_" .. #self.Elements + 1
                SliderFrame.Size = UDim2.new(0.9, 0, 0, 38 * scale)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.LayoutOrder = #self.Elements + 1
                SliderFrame.Parent = TabContent
                
                local range = opts.Range or {0, 100}
                local increment = opts.Increment or 1
                local value = opts.CurrentValue or range[1]
                local min = range[1]
                local max = range[2]
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Name = "SliderButton"
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.Text = (opts.Name or "Slider") .. " : " .. value
                SliderButton.TextColor3 = theme.Text
                SliderButton.BackgroundColor3 = theme.Button
                SliderButton.BackgroundTransparency = 0
                SliderButton.TextSize = 14 * scale
                SliderButton.Font = Enum.Font.GothamSemibold
                SliderButton.AutoButtonColor = false
                SliderButton.Parent = SliderFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 10 * scale)
                Corner.Parent = SliderButton
                
                -- Hover effect
                SliderButton.MouseEnter:Connect(function()
                    tween(SliderButton, {BackgroundColor3 = theme.Hover}, 0.1)
                end)
                
                SliderButton.MouseLeave:Connect(function()
                    tween(SliderButton, {BackgroundColor3 = theme.Button}, 0.1)
                end)
                
                SliderButton.MouseButton1Click:Connect(function()
                    value = value + increment
                    if value > max then value = min end
                    SliderButton.Text = (opts.Name or "Slider") .. " : " .. value
                    
                    -- Click animation
                    tween(SliderButton, {BackgroundColor3 = theme.Active}, 0.05)
                    task.wait(0.1)
                    tween(SliderButton, {BackgroundColor3 = theme.Button}, 0.05)
                    
                    if opts.Callback then
                        pcall(opts.Callback, value)
                    end
                end)
                
                table.insert(self.Elements, SliderFrame)
                
                return {
                    Frame = SliderFrame,
                    Button = SliderButton,
                    GetValue = function() return value end,
                    SetValue = function(newValue)
                        value = newValue
                        SliderButton.Text = (opts.Name or "Slider") .. " : " .. value
                    end
                }
            end
        }
        
        self.Tabs[tabName] = tabObj
        
        -- Set first tab as active
        if #self.Tabs == 1 then
            TabButton.BackgroundColor3 = theme.TabActive
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            TabContent.Visible = true
            self.ActiveTab = tabName
        end
        
        return tabObj
    end
    
    -- ===== MINIMIZE FUNCTIONALITY =====
    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            -- Minimize with animation
            tween(MainFrame, {Size = UDim2.fromOffset(240 * scale, 42 * scale)}, 0.2)
            Sidebar.Visible = false
            ContentFrame.Visible = false
            TitleLabel.Visible = false
            ThemeButton.Visible = false
            
            -- Reposition buttons
            MinimizeButton.Position = UDim2.new(0, 5 * scale, 0.5, -14 * scale)
            CloseButton.Position = UDim2.new(1, -28 * scale, 0.5, -14 * scale)
            
            MinimizeButton.Text = "□"
        else
            -- Restore with animation
            tween(MainFrame, {Size = windowData.Size}, 0.2)
            Sidebar.Visible = true
            ContentFrame.Visible = true
            TitleLabel.Visible = true
            ThemeButton.Visible = windowData.ShowThemeTab
            
            -- Restore button positions
            ThemeButton.Position = UDim2.new(1, -70 * scale, 0.5, -14 * scale)
            MinimizeButton.Position = UDim2.new(1, -36 * scale, 0.5, -14 * scale)
            CloseButton.Position = UDim2.new(1, 0, 0.5, -14 * scale)
            
            MinimizeButton.Text = "_"
        end
    end)
    
    -- Close button with animation
    CloseButton.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        MainFrame:Destroy()
    end)
    
    -- Dragging with smooth animation
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            tween(TitleBar, {BackgroundColor3 = theme.Hover}, 0.1)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(TitleBar, {BackgroundColor3 = theme.TitleBar}, 0.1)
        end
    end)
    
    -- Create theme tab if requested
    if windowData.ShowThemeTab then
        local ThemeTab = windowObj:CreateTab("🎨 Theme")
        ThemeTab:CreateLabel({Text = "Select Theme:", Alignment = Enum.TextXAlignment.Center})
        ThemeTab:CreateButton({Text = "🌙 Dark", Callback = function() self:SetTheme("DARK") end})
    end
    
    print("✅ Created aesthetic window: " .. windowData.Name)
    return windowObj
end

-- ===============================
-- DEPENDENCY SYSTEM
-- ===============================

local Services = {
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService")
}

local Variables = {}

local Bdev = {}
function Bdev:Notify(opt)
    print("[NOTIFY]", opt.Title, opt.Content)
end

-- ===============================
-- EXPORT
-- ===============================

getgenv().SimpleGUI = {
    new = SimpleGUI.new,
    Themes = SimpleGUI.Themes,
    
    CreatePlayerModsEnvironment = function()
        return {
            Tab = nil,
            GUI = SimpleGUI.ScreenGui,
            Bdev = Bdev,
            Shared = {
                Services = Services,
                Variables = Variables,
                Functions = {}
            }
        }
    end
}

print("🎉 SimpleGUI Aesthetic Edition loaded!")
return SimpleGUI