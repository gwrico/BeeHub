-- ==============================================
-- 🎨 SIMPLEGUI v6.3 - SIDEBAR TABS (VERTICAL) - FIXED VERSION
-- WITH v7 FINAL UI
-- ==============================================
print("🔧 Loading SimpleGUI v6.3 - With v7 UI...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Modern color schemes
SimpleGUI.Themes = {
    DARK = {
        Name = "Dark",
        Primary = Color3.fromRGB(33, 33, 45),
        Secondary = Color3.fromRGB(45, 45, 60),
        Accent = Color3.fromRGB(98, 147, 255),
        Text = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        Success = Color3.fromRGB(76, 217, 100),
        Warning = Color3.fromRGB(255, 204, 0),
        Error = Color3.fromRGB(255, 59, 48),
        Border = Color3.fromRGB(70, 70, 90),
        Hover = Color3.fromRGB(65, 65, 85),
        Active = Color3.fromRGB(120, 170, 255),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(33, 33, 45),
        TitleBar = Color3.fromRGB(45, 45, 60),
        TabNormal = Color3.fromRGB(50, 50, 70),
        TabActive = Color3.fromRGB(98, 147, 255),
        ContentBg = Color3.fromRGB(40, 40, 55),
        Button = Color3.fromRGB(65, 65, 85),
        InputBg = Color3.fromRGB(50, 50, 70),
        ToggleOff = Color3.fromRGB(70, 70, 90),
        ToggleOn = Color3.fromRGB(98, 147, 255),
        SliderTrack = Color3.fromRGB(60, 60, 80),
        SliderFill = Color3.fromRGB(98, 147, 255),
        Sidebar = Color3.fromRGB(40, 40, 55)
    }
}

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI v6.3...")
    
    local self = setmetatable({}, SimpleGUI)
    
    -- Destroy existing GUI
    pcall(function() game:GetService("CoreGui").SimpleGUI:Destroy() end)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SimpleGUI"
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
    
    print("✅ SimpleGUI v6.3 initialized!")
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

-- Create window with SIDEBAR TABS (Using v7 UI)
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
    WindowCorner.CornerRadius = UDim.new(0, 12 * scale)
    WindowCorner.Parent = MainFrame
    
    -- ===== TITLE BAR =====
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42 * scale)
    TitleBar.BackgroundColor3 = theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12 * scale)
    TitleBarCorner.Parent = TitleBar
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -120 * scale, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14 * scale, 0, 0)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16 * scale
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Control Buttons
    -- Theme Button
    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Name = "ThemeButton"
    ThemeButton.Size = UDim2.fromOffset(28 * scale, 28 * scale)
    ThemeButton.Position = UDim2.new(1, -70 * scale, 0.5, -14 * scale)
    ThemeButton.Text = "🎨"
    ThemeButton.TextColor3 = theme.Text
    ThemeButton.BackgroundColor3 = theme.Button
    ThemeButton.BackgroundTransparency = 0
    ThemeButton.TextSize = 14 * scale
    ThemeButton.Font = Enum.Font.SourceSans
    ThemeButton.Visible = windowData.ShowThemeTab
    ThemeButton.Parent = TitleBar
    
    local ThemeButtonCorner = Instance.new("UICorner")
    ThemeButtonCorner.CornerRadius = UDim.new(0, 6 * scale)
    ThemeButtonCorner.Parent = ThemeButton
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.fromOffset(28 * scale, 28 * scale)
    MinimizeButton.Position = UDim2.new(1, -36 * scale, 0.5, -14 * scale)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = theme.Text
    MinimizeButton.BackgroundColor3 = theme.Button
    MinimizeButton.BackgroundTransparency = 0
    MinimizeButton.TextSize = 18 * scale
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Parent = TitleBar
    
    local MinimizeButtonCorner = Instance.new("UICorner")
    MinimizeButtonCorner.CornerRadius = UDim.new(0, 6 * scale)
    MinimizeButtonCorner.Parent = MinimizeButton
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.fromOffset(28 * scale, 28 * scale)
    CloseButton.Position = UDim2.new(1, 0, 0.5, -14 * scale)  -- Paling kanan
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = theme.Error
    CloseButton.BackgroundColor3 = theme.Button
    CloseButton.BackgroundTransparency = 0
    CloseButton.TextSize = 16 * scale
    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.Parent = TitleBar
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 6 * scale)
    CloseButtonCorner.Parent = CloseButton
    
    -- ===== SIDEBAR (LEFT) =====
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, windowData.SidebarWidth, 1, -42 * scale)
    Sidebar.Position = UDim2.new(0, 0, 0, 42 * scale)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- Sidebar layout
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 6 * scale)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingLeft = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingRight = UDim.new(0, 10 * scale)
    SidebarPadding.Parent = Sidebar
    
    -- ===== CONTENT FRAME (RIGHT) =====
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
    
    -- Content layout
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8 * scale)
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
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(1, 0, 0, 36 * scale)
        TabButton.Text = "  " .. tabName
        TabButton.TextColor3 = theme.Text
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 14 * scale
        TabButton.Font = Enum.Font.SourceSansSemibold
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = self.Sidebar
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
        TabButtonCorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Name = tabName .. "_Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = self.ContentFrame
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 8 * scale)
        TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        -- Tab click handler
        TabButton.MouseButton1Click:Connect(function()
            for name, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = theme.TabNormal
                tab.Button.TextColor3 = theme.Text
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = theme.TabActive
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            self.ActiveTab = tabName
        end)
        
        -- Button hover effects
        local function setupButtonHover(button)
            if button and button:IsA("TextButton") then
                button.MouseEnter:Connect(function()
                    if not isMobile then
                        button.BackgroundColor3 = theme.Hover
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    if not isMobile then
                        button.BackgroundColor3 = theme.Button
                    end
                end)
            end
        end
        
        setupButtonHover(TabButton)
        setupButtonHover(ThemeButton)
        setupButtonHover(MinimizeButton)
        setupButtonHover(CloseButton)
        
        -- ===== TAB BUILDER METHODS =====
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
                Button.Size = UDim2.new(0.9, 0, 0, 36 * scale)
                Button.Text = opts.Text or Button.Name
                Button.TextColor3 = theme.Text
                Button.BackgroundColor3 = theme.Button
                Button.BackgroundTransparency = 0
                Button.TextSize = 14 * scale
                Button.Font = Enum.Font.SourceSansSemibold
                Button.AutoButtonColor = false
                Button.LayoutOrder = #self.Elements + 1
                Button.Parent = TabContent
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8 * scale)
                Corner.Parent = Button
                
                setupButtonHover(Button)
                
                Button.MouseButton1Click:Connect(function()
                    Button.BackgroundColor3 = theme.Active
                    task.wait(0.1)
                    Button.BackgroundColor3 = theme.Button
                    
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
                Label.Font = Enum.Font.SourceSans
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
                InputFrame.Size = UDim2.new(0.9, 0, 0, 40 * scale)
                InputFrame.BackgroundTransparency = 1
                InputFrame.LayoutOrder = #self.Elements + 1
                InputFrame.Parent = TabContent
                
                local InputBox = Instance.new("TextBox")
                InputBox.Name = "TextBox"
                InputBox.Size = UDim2.new(1, 0, 1, 0)
                InputBox.Text = opts.CurrentValue or ""
                InputBox.PlaceholderText = opts.PlaceholderText or "Enter text..."
                InputBox.TextColor3 = theme.Text
                InputBox.BackgroundColor3 = theme.InputBg
                InputBox.BackgroundTransparency = 0
                InputBox.TextSize = 14 * scale
                InputBox.Font = Enum.Font.SourceSans
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = InputFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8 * scale)
                Corner.Parent = InputBox
                
                local Padding = Instance.new("UIPadding")
                Padding.PaddingLeft = UDim.new(0, 12 * scale)
                Padding.PaddingRight = UDim.new(0, 12 * scale)
                Padding.Parent = InputBox
                
                InputBox.Focused:Connect(function()
                    InputBox.BackgroundColor3 = theme.Hover
                end)
                
                InputBox.FocusLost:Connect(function()
                    InputBox.BackgroundColor3 = theme.InputBg
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
                ToggleFrame.Size = UDim2.new(0.9, 0, 0, 36 * scale)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.LayoutOrder = #self.Elements + 1
                ToggleFrame.Parent = TabContent
                
                -- Toggle button (simple text button)
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Text = (opts.Text or opts.Name or "Toggle") .. " : OFF"
                ToggleButton.TextColor3 = theme.Text
                ToggleButton.BackgroundColor3 = theme.Button
                ToggleButton.BackgroundTransparency = 0
                ToggleButton.TextSize = 14 * scale
                ToggleButton.Font = Enum.Font.SourceSansSemibold
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = ToggleFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8 * scale)
                Corner.Parent = ToggleButton
                
                setupButtonHover(ToggleButton)
                
                local isToggled = opts.CurrentValue or false
                
                local function updateToggle()
                    ToggleButton.Text = (opts.Text or opts.Name or "Toggle") .. " : " .. (isToggled and "ON" or "OFF")
                    ToggleButton.BackgroundColor3 = isToggled and theme.ToggleOn or theme.Button
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
                SliderFrame.Size = UDim2.new(0.9, 0, 0, 36 * scale)
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
                SliderButton.Font = Enum.Font.SourceSansSemibold
                SliderButton.AutoButtonColor = false
                SliderButton.Parent = SliderFrame
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8 * scale)
                Corner.Parent = SliderButton
                
                setupButtonHover(SliderButton)
                
                SliderButton.MouseButton1Click:Connect(function()
                    value = value + increment
                    if value > max then value = min end
                    SliderButton.Text = (opts.Name or "Slider") .. " : " .. value
                    
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
            -- Minimize: small window with only buttons
            MainFrame.Size = UDim2.fromOffset(240 * scale, 42 * scale)
            Sidebar.Visible = false
            ContentFrame.Visible = false
            TitleLabel.Visible = false
            ThemeButton.Visible = false
            
            -- Reposition buttons
            MinimizeButton.Position = UDim2.new(0, 5 * scale, 0.5, -14 * scale)
            CloseButton.Position = UDim2.new(1, -28 * scale, 0.5, -14 * scale)
            
            MinimizeButton.Text = "□"
        else
            -- Restore
            MainFrame.Size = windowData.Size
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
    
    -- Close button
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame:Destroy()
    end)
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            TitleBar.BackgroundColor3 = theme.Hover
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
            TitleBar.BackgroundColor3 = theme.TitleBar
        end
    end)
    
    -- Create theme tab if requested
    if windowData.ShowThemeTab then
        local ThemeTab = windowObj:CreateTab("🎨 Theme")
        ThemeTab:CreateLabel({Text = "Select Theme:", Alignment = Enum.TextXAlignment.Center})
        ThemeTab:CreateButton({Text = "🌙 Dark", Callback = function() self:SetTheme("DARK") end})
    end
    
    print("✅ Created window with sidebar tabs: " .. windowData.Name)
    return windowObj
end

-- ===============================
-- DEPENDENCY SYSTEM (from v7)
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
-- EXPORT (v7 compatible)
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

print("🎉 SimpleGUI v6.3 - With v7 UI loaded!")
return SimpleGUI