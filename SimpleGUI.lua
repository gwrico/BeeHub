-- ==============================================
-- 🎨 SIMPLEGUI v6.3 - SIDEBAR TABS (VERTICAL) - FIXED VERSION
-- ==============================================
print("🔧 Loading SimpleGUI v6.3 - Fixed Version...")

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
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SimpleGUIv6_" .. math.random(10000, 99999)
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

-- Create window with SIDEBAR TABS
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local isMobile = UserInputService.TouchEnabled
    local scale = isMobile and 0.85 or 1.0
    
    local windowData = {
        Name = opts.Name or "Window",
        Size = opts.Size or UDim2.new(0, 700 * scale, 0, 500 * scale),
        Position = opts.Position or UDim2.new(0.5, -350 * scale, 0.5, -250 * scale),
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
    
    -- Shadow effect
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    Shadow.BackgroundTransparency = 0.8
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 14 * scale)
    ShadowCorner.Parent = Shadow
    
    -- ===== TITLE BAR (TOP) =====
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40 * scale)
    TitleBar.BackgroundColor3 = theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12 * scale)
    TitleBarCorner.Parent = TitleBar
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -100 * scale, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15 * scale, 0, 0)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16 * scale
    TitleLabel.Font = Enum.Font.SourceSansSemibold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Control Buttons
    local buttonSize = 28 * scale
    
    -- Theme Button
    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Name = "ThemeButton"
    ThemeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    ThemeButton.Position = UDim2.new(1, -buttonSize * 3 - 20 * scale, 0.5, -buttonSize/2)
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
    MinimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    MinimizeButton.Position = UDim2.new(1, -buttonSize * 2 - 10 * scale, 0.5, -buttonSize/2)
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
    CloseButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    CloseButton.Position = UDim2.new(1, -buttonSize, 0.5, -buttonSize/2)
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
    Sidebar.Size = UDim2.new(0, windowData.SidebarWidth, 1, -40 * scale)
    Sidebar.Position = UDim2.new(0, 0, 0, 40 * scale)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- ===== CONTENT FRAME (RIGHT) =====
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -windowData.SidebarWidth, 1, -40 * scale)
    ContentFrame.Position = UDim2.new(0, windowData.SidebarWidth, 0, 40 * scale)
    ContentFrame.BackgroundColor3 = theme.ContentBg
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4 * scale
    ContentFrame.ScrollBarImageColor3 = theme.Accent
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentFrame.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 12 * scale)
    ContentCorner.Parent = ContentFrame
    
    -- ===== LAYOUTS =====
    -- Sidebar layout
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5 * scale)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingLeft = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingRight = UDim.new(0, 10 * scale)
    SidebarPadding.Parent = Sidebar
    
    -- Content layout
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 12 * scale)
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
        TabButton.Size = UDim2.new(1, -20 * scale, 0, 40 * scale)
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
        TabLayout.Padding = UDim.new(0, 12 * scale)
        TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        -- Tab click handler
        TabButton.MouseButton1Click:Connect(function()
            for name, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tween(tab.Button, {BackgroundColor3 = theme.TabNormal})
                tab.Button.TextColor3 = theme.Text
            end
            
            TabContent.Visible = true
            tween(TabButton, {BackgroundColor3 = theme.TabActive})
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            self.ActiveTab = tabName
        end)
        
        -- Button hover effects
        local function setupButtonHover(button)
            if button and button:IsA("TextButton") then
                button.MouseEnter:Connect(function()
                    if not isMobile then
                        tween(button, {BackgroundColor3 = theme.Hover})
                    end
                end)
                
                button.MouseLeave:Connect(function()
                    if not isMobile then
                        tween(button, {BackgroundColor3 = theme.Button})
                    end
                end)
            end
        end
        
        setupButtonHover(TabButton)
        setupButtonHover(ThemeButton)
        setupButtonHover(MinimizeButton)
        setupButtonHover(CloseButton)
        
        -- ===== TAB BUILDER METHODS - DIPERBAIKI =====
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
                Button.Size = UDim2.new(0.9, 0, 0, 40 * scale)
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
                    tween(Button, {BackgroundColor3 = theme.Active})
                    task.wait(0.1)
                    tween(Button, {BackgroundColor3 = theme.Button})
                    
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
                    tween(InputBox, {BackgroundColor3 = theme.Hover})
                end)
                
                InputBox.FocusLost:Connect(function()
                    tween(InputBox, {BackgroundColor3 = theme.InputBg})
                    if opts.Callback then
                        pcall(opts.Callback, InputBox.Text)
                    end
                end)
                
                table.insert(self.Elements, InputFrame)
                return InputBox
            end,
            
            -- ===== CREATE TOGGLE - FIXED VERSION =====
            CreateToggle = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = opts.Name or "Toggle_" .. #self.Elements + 1
                ToggleFrame.Size = UDim2.new(0.9, 0, 0, 40 * scale)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.LayoutOrder = #self.Elements + 1
                ToggleFrame.Parent = TabContent
                
                -- Toggle container - PASTIKAN TextButton untuk MouseButton1Click
                local ToggleContainer = Instance.new("TextButton")  -- TEXTBUTTON BUKAN FRAME
                ToggleContainer.Name = "ToggleContainer"
                ToggleContainer.Size = UDim2.new(0, 60 * scale, 0, 30 * scale)
                ToggleContainer.Position = UDim2.new(0, 0, 0.5, -15 * scale)
                ToggleContainer.Text = ""
                ToggleContainer.BackgroundColor3 = theme.ToggleOff
                ToggleContainer.BackgroundTransparency = 0
                ToggleContainer.BorderSizePixel = 0
                ToggleContainer.AutoButtonColor = false
                ToggleContainer.Parent = ToggleFrame
                
                local ContainerCorner = Instance.new("UICorner")
                ContainerCorner.CornerRadius = UDim.new(0, 15 * scale)
                ContainerCorner.Parent = ToggleContainer
                
                -- Toggle circle
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Size = UDim2.new(0, 24 * scale, 0, 24 * scale)
                ToggleCircle.Position = UDim2.new(0, 3 * scale, 0.5, -12 * scale)
                ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
                ToggleCircle.BackgroundTransparency = 0
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Parent = ToggleContainer
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(0.5, 0)
                CircleCorner.Parent = ToggleCircle
                
                -- Toggle label - PASTIKAN TextButton untuk MouseButton1Click
                local ToggleLabel = Instance.new("TextButton")  -- TEXTBUTTON BUKAN TextLabel
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Size = UDim2.new(1, -70 * scale, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 70 * scale, 0, 0)
                ToggleLabel.Text = opts.Text or opts.Name or "Toggle"
                ToggleLabel.TextColor3 = theme.Text
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.TextSize = 14 * scale
                ToggleLabel.Font = Enum.Font.SourceSansSemibold
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.AutoButtonColor = false
                ToggleLabel.Parent = ToggleFrame
                
                -- Toggle state
                local isToggled = opts.CurrentValue or false
                
                -- Update toggle appearance
                local function updateToggle()
                    if isToggled then
                        tween(ToggleContainer, {BackgroundColor3 = theme.ToggleOn}, 0.2)
                        tween(ToggleCircle, {Position = UDim2.new(1, -27 * scale, 0.5, -12 * scale)}, 0.2)
                    else
                        tween(ToggleContainer, {BackgroundColor3 = theme.ToggleOff}, 0.2)
                        tween(ToggleCircle, {Position = UDim2.new(0, 3 * scale, 0.5, -12 * scale)}, 0.2)
                    end
                end
                
                -- Initial state
                updateToggle()
                
                -- Toggle click - SEKARANG VALID karena ToggleContainer adalah TextButton
                ToggleContainer.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    updateToggle()
                    
                    if opts.Callback then
                        pcall(opts.Callback, isToggled)
                    end
                end)
                
                -- Label click - SEKARANG VALID karena ToggleLabel adalah TextButton
                ToggleLabel.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    updateToggle()
                    
                    if opts.Callback then
                        pcall(opts.Callback, isToggled)
                    end
                end)
                
                table.insert(self.Elements, ToggleFrame)
                
                -- Return toggle object
                return {
                    Frame = ToggleFrame,
                    Container = ToggleContainer,
                    Circle = ToggleCircle,
                    Label = ToggleLabel,
                    GetValue = function() return isToggled end,
                    SetValue = function(value)
                        isToggled = value
                        updateToggle()
                    end
                }
            end,
            
            -- ===== CREATE SLIDER =====
            CreateSlider = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = opts.Name or "Slider_" .. #self.Elements + 1
                SliderFrame.Size = UDim2.new(0.9, 0, 0, 60 * scale)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.LayoutOrder = #self.Elements + 1
                SliderFrame.Parent = TabContent
                
                -- Label
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Size = UDim2.new(1, 0, 0, 20 * scale)
                SliderLabel.Text = opts.Name or "Slider"
                SliderLabel.TextColor3 = theme.Text
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.TextSize = 14 * scale
                SliderLabel.Font = Enum.Font.SourceSansSemibold
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                -- Value display
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "ValueLabel"
                ValueLabel.Size = UDim2.new(0, 60 * scale, 0, 20 * scale)
                ValueLabel.Position = UDim2.new(1, -60 * scale, 0, 0)
                ValueLabel.Text = tostring(opts.CurrentValue or (opts.Range and opts.Range[1]) or 50)
                ValueLabel.TextColor3 = theme.Text
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.TextSize = 14 * scale
                ValueLabel.Font = Enum.Font.SourceSans
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                -- Slider track
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Name = "SliderTrack"
                SliderTrack.Size = UDim2.new(1, 0, 0, 20 * scale)
                SliderTrack.Position = UDim2.new(0, 0, 0, 30 * scale)
                SliderTrack.BackgroundColor3 = theme.SliderTrack
                SliderTrack.BackgroundTransparency = 0
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Parent = SliderFrame
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 10 * scale)
                TrackCorner.Parent = SliderTrack
                
                -- Slider fill
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "SliderFill"
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.BackgroundColor3 = theme.SliderFill
                SliderFill.BackgroundTransparency = 0
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderTrack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 10 * scale)
                FillCorner.Parent = SliderFill
                
                -- Slider thumb (TextButton untuk mouse events)
                local SliderThumb = Instance.new("TextButton")
                SliderThumb.Name = "SliderThumb"
                SliderThumb.Size = UDim2.new(0, 28 * scale, 0, 28 * scale)
                SliderThumb.Position = UDim2.new(0, -14 * scale, 0.5, -14 * scale)
                SliderThumb.Text = ""
                SliderThumb.BackgroundColor3 = theme.Accent
                SliderThumb.BackgroundTransparency = 0
                SliderThumb.AutoButtonColor = false
                SliderThumb.Parent = SliderTrack
                
                local ThumbCorner = Instance.new("UICorner")
                ThumbCorner.CornerRadius = UDim.new(0.5, 0)
                ThumbCorner.Parent = SliderThumb
                
                -- Slider variables
                local range = opts.Range or {0, 100}
                local increment = opts.Increment or 1
                local currentValue = opts.CurrentValue or range[1]
                local isDragging = false
                
                -- Update slider position
                local function updateSliderPosition(value)
                    currentValue = math.clamp(
                        math.floor((value - range[1]) / increment) * increment + range[1],
                        range[1],
                        range[2]
                    )
                    
                    local percentage = (currentValue - range[1]) / (range[2] - range[1])
                    local fillWidth = math.clamp(percentage, 0, 1)
                    
                    -- Update visuals
                    tween(SliderFill, {Size = UDim2.new(fillWidth, 0, 1, 0)})
                    tween(SliderThumb, {Position = UDim2.new(fillWidth, -14 * scale, 0.5, -14 * scale)})
                    ValueLabel.Text = tostring(currentValue)
                    
                    -- Call callback
                    if opts.Callback then
                        pcall(opts.Callback, currentValue)
                    end
                end
                
                -- Initial position
                updateSliderPosition(currentValue)
                
                -- Drag events
                SliderThumb.MouseButton1Down:Connect(function()
                    isDragging = true
                    tween(SliderThumb, {Size = UDim2.new(0, 32 * scale, 0, 32 * scale)})
                    tween(SliderThumb, {BackgroundColor3 = theme.Active})
                end)
                
                local connection
                connection = UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local trackPos = SliderTrack.AbsolutePosition
                        local trackSize = SliderTrack.AbsoluteSize
                        
                        local relativeX = (mousePos.X - trackPos.X) / trackSize.X
                        relativeX = math.clamp(relativeX, 0, 1)
                        
                        local value = range[1] + (relativeX * (range[2] - range[1]))
                        updateSliderPosition(value)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isDragging then
                            isDragging = false
                            tween(SliderThumb, {Size = UDim2.new(0, 28 * scale, 0, 28 * scale)})
                            tween(SliderThumb, {BackgroundColor3 = theme.Accent})
                        end
                    end
                end)
                
                -- Click on track to set value
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePos = UserInputService:GetMouseLocation()
                        local trackPos = SliderTrack.AbsolutePosition
                        local trackSize = SliderTrack.AbsoluteSize
                        
                        local relativeX = (mousePos.X - trackPos.X) / trackSize.X
                        relativeX = math.clamp(relativeX, 0, 1)
                        
                        local value = range[1] + (relativeX * (range[2] - range[1]))
                        updateSliderPosition(value)
                    end
                end)
                
                table.insert(self.Elements, SliderFrame)
                
                -- Return slider object
                return {
                    Frame = SliderFrame,
                    Track = SliderTrack,
                    Thumb = SliderThumb,
                    GetValue = function() return currentValue end,
                    SetValue = function(value)
                        updateSliderPosition(value)
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
    
        -- ===== MINIMIZE FUNCTIONALITY (FIXED) =====
    local isMinimized = false
    local originalSize = windowData.Size
    local originalTitleSize = 16 * scale
    local originalButtonSize = 28 * scale
    
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            -- Minimize: kecilkan window
            MainFrame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30 * scale)
            
            -- Sembunyikan sidebar dan content
            Sidebar.Visible = false
            ContentFrame.Visible = false
            
            -- Update tombol dan title
            MinimizeButton.Text = "□"
            TitleLabel.Text = windowData.Name .. " [Min]"
            TitleLabel.TextSize = 14 * scale
            
            -- Kecilkan tombol
            ThemeButton.Size = UDim2.new(0, 22 * scale, 0, 22 * scale)
            MinimizeButton.Size = UDim2.new(0, 22 * scale, 0, 22 * scale)
            CloseButton.Size = UDim2.new(0, 22 * scale, 0, 22 * scale)
            
            -- Reposisi tombol
            ThemeButton.Position = UDim2.new(1, -(22 * 3) - 15, 0.5, -11)
            MinimizeButton.Position = UDim2.new(1, -(22 * 2) - 8, 0.5, -11)
            CloseButton.Position = UDim2.new(1, -22 - 5, 0.5, -11)
        else
            -- Restore: kembalikan ke ukuran normal
            MainFrame.Size = originalSize
            
            -- Tampilkan kembali sidebar dan content
            Sidebar.Visible = true
            ContentFrame.Visible = true
            
            -- Kembalikan tombol dan title
            MinimizeButton.Text = "_"
            TitleLabel.Text = windowData.Name
            TitleLabel.TextSize = 16 * scale
            
            -- Kembalikan ukuran tombol
            ThemeButton.Size = UDim2.new(0, 28 * scale, 0, 28 * scale)
            MinimizeButton.Size = UDim2.new(0, 28 * scale, 0, 28 * scale)
            CloseButton.Size = UDim2.new(0, 28 * scale, 0, 28 * scale)
            
            -- Kembalikan posisi tombol
            ThemeButton.Position = UDim2.new(1, -(28 * 3) - 20 * scale, 0.5, -14 * scale)
            MinimizeButton.Position = UDim2.new(1, -(28 * 2) - 10 * scale, 0.5, -14 * scale)
            CloseButton.Position = UDim2.new(1, -28 * scale, 0.5, -14 * scale)
        end
    end)
    
    -- Close button
    CloseButton.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)})
        task.wait(0.2)
        MainFrame.Visible = false
    end)
    
    -- Dragging
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            tween(TitleBar, {BackgroundColor3 = theme.Hover})
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
            tween(TitleBar, {BackgroundColor3 = theme.TitleBar})
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

print("🎉 SimpleGUI v6.3 - FIXED VERSION loaded!")
return SimpleGUI