-- ==============================================
-- 🎨 SIMPLEGUI v6.0 - MODERN & RESPONSIVE WITH REAL-TIME FEATURES
-- ==============================================
print("🔧 Loading SimpleGUI v6.0 - Modern & Responsive UI...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Modern color schemes with gradients
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
        TabNormal = Color3.fromRGB(60, 60, 80),
        TabActive = Color3.fromRGB(98, 147, 255),
        ContentBg = Color3.fromRGB(40, 40, 55),
        Button = Color3.fromRGB(65, 65, 85),
        InputBg = Color3.fromRGB(50, 50, 70),
        ToggleOff = Color3.fromRGB(70, 70, 90),
        ToggleOn = Color3.fromRGB(98, 147, 255),
        SliderTrack = Color3.fromRGB(60, 60, 80),
        SliderFill = Color3.fromRGB(98, 147, 255)
    },
    
    LIGHT = {
        Name = "Light",
        Primary = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(230, 230, 240),
        Accent = Color3.fromRGB(0, 122, 255),
        Text = Color3.fromRGB(30, 30, 40),
        TextSecondary = Color3.fromRGB(100, 100, 120),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 149, 0),
        Error = Color3.fromRGB(255, 45, 85),
        Border = Color3.fromRGB(200, 200, 210),
        Hover = Color3.fromRGB(220, 220, 230),
        Active = Color3.fromRGB(0, 122, 255),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(245, 245, 250),
        TitleBar = Color3.fromRGB(230, 230, 240),
        TabNormal = Color3.fromRGB(210, 210, 220),
        TabActive = Color3.fromRGB(0, 122, 255),
        ContentBg = Color3.fromRGB(250, 250, 255),
        Button = Color3.fromRGB(220, 220, 230),
        InputBg = Color3.fromRGB(240, 240, 245),
        ToggleOff = Color3.fromRGB(200, 200, 210),
        ToggleOn = Color3.fromRGB(0, 122, 255),
        SliderTrack = Color3.fromRGB(210, 210, 220),
        SliderFill = Color3.fromRGB(0, 122, 255)
    },
    
    PURPLE = {
        Name = "Purple",
        Primary = Color3.fromRGB(40, 30, 60),
        Secondary = Color3.fromRGB(60, 45, 90),
        Accent = Color3.fromRGB(175, 82, 222),
        Text = Color3.fromRGB(245, 230, 255),
        TextSecondary = Color3.fromRGB(200, 180, 220),
        Success = Color3.fromRGB(123, 97, 255),
        Warning = Color3.fromRGB(255, 184, 77),
        Error = Color3.fromRGB(255, 105, 180),
        Border = Color3.fromRGB(100, 75, 130),
        Hover = Color3.fromRGB(80, 60, 110),
        Active = Color3.fromRGB(195, 102, 242),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(40, 30, 60),
        TitleBar = Color3.fromRGB(60, 45, 90),
        TabNormal = Color3.fromRGB(80, 60, 110),
        TabActive = Color3.fromRGB(175, 82, 222),
        ContentBg = Color3.fromRGB(50, 35, 75),
        Button = Color3.fromRGB(70, 55, 100),
        InputBg = Color3.fromRGB(60, 50, 85),
        ToggleOff = Color3.fromRGB(90, 70, 120),
        ToggleOn = Color3.fromRGB(175, 82, 222),
        SliderTrack = Color3.fromRGB(80, 65, 115),
        SliderFill = Color3.fromRGB(175, 82, 222)
    }
}

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI v6.0...")
    
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
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
        workspace
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
    
    print("✅ SimpleGUI v6.0 initialized!")
    return self
end

-- Theme management
function SimpleGUI:SetTheme(themeName)
    if self.Themes[themeName:upper()] then
        self.CurrentTheme = themeName:upper()
        print("🎨 Applied theme: " .. self.Themes[self.CurrentTheme].Name)
        
        -- Update all windows
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

-- Create modern window
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local isMobile = UserInputService.TouchEnabled
    local isTablet = isMobile and (workspace.CurrentCamera.ViewportSize.X > 800)
    local scale = isMobile and 0.8 or 1.0
    
    local windowData = {
        Name = opts.Name or "Window",
        Size = opts.Size or UDim2.new(0, 500 * scale, 0, 450 * scale),
        Position = opts.Position or UDim2.new(0.5, -250 * scale, 0.5, -225 * scale),
        ShowThemeTab = opts.ShowThemeTab or false,
        IsMobile = isMobile,
        IsTablet = isTablet,
        Scale = scale
    }
    
    local theme = self:GetTheme()
    
    -- Main Window Frame
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
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35 * scale)
    TitleBar.BackgroundColor3 = theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -100 * scale, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15 * scale, 0, 0)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 14 * scale
    TitleLabel.Font = Enum.Font.SourceSansSemibold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Control Buttons
    local buttonSize = 25 * scale
    
    -- Theme Button
    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Name = "ThemeButton"
    ThemeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    ThemeButton.Position = UDim2.new(1, -75 * scale, 0.5, -buttonSize/2)
    ThemeButton.Text = "🎨"
    ThemeButton.TextColor3 = theme.Text
    ThemeButton.BackgroundColor3 = theme.Button
    ThemeButton.BackgroundTransparency = 0
    ThemeButton.TextSize = 12 * scale
    ThemeButton.Font = Enum.Font.SourceSans
    ThemeButton.Visible = windowData.ShowThemeTab
    ThemeButton.Parent = TitleBar
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    MinimizeButton.Position = UDim2.new(1, -45 * scale, 0.5, -buttonSize/2)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = theme.Text
    MinimizeButton.BackgroundColor3 = theme.Button
    MinimizeButton.BackgroundTransparency = 0
    MinimizeButton.TextSize = 16 * scale
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    CloseButton.Position = UDim2.new(1, -15 * scale, 0.5, -buttonSize/2)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = theme.Error
    CloseButton.BackgroundColor3 = theme.Button
    CloseButton.BackgroundTransparency = 0
    CloseButton.TextSize = 18 * scale
    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.Parent = TitleBar
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 40 * scale)
    TabContainer.Position = UDim2.new(0, 0, 0, 35 * scale)
    TabContainer.BackgroundColor3 = theme.Secondary
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Content Frame
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -75 * scale)
    ContentFrame.Position = UDim2.new(0, 0, 0, 75 * scale)
    ContentFrame.BackgroundColor3 = theme.ContentBg
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4 * scale
    ContentFrame.ScrollBarImageColor3 = theme.Accent
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentFrame.Parent = MainFrame
    
    -- Layouts
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0, 5 * scale)
    TabList.Parent = TabContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 10 * scale)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 10 * scale)
    ContentPadding.PaddingRight = UDim.new(0, 10 * scale)
    ContentPadding.PaddingTop = UDim.new(0, 10 * scale)
    ContentPadding.PaddingBottom = UDim.new(0, 10 * scale)
    ContentPadding.Parent = ContentFrame
    
    -- Minimize functionality
    local isMinimized = false
    local originalSize = windowData.Size
    
    local function updateMinimizeState()
        if isMinimized then
            tween(MainFrame, {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 35 * scale)})
            TitleLabel.Text = windowData.Name .. " [-]"
            TabContainer.Visible = false
            ContentFrame.Visible = false
            MinimizeButton.Text = "+"
        else
            tween(MainFrame, {Size = originalSize})
            TitleLabel.Text = windowData.Name
            TabContainer.Visible = true
            ContentFrame.Visible = true
            MinimizeButton.Text = "_"
        end
    end
    
    -- Button hover effects
    local function setupButtonHover(button)
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
    
    setupButtonHover(ThemeButton)
    setupButtonHover(MinimizeButton)
    setupButtonHover(CloseButton)
    
    -- Button clicks
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        updateMinimizeState()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
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
    
    -- Window object
    local windowObj = {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        TabContainer = TabContainer,
        ContentFrame = ContentFrame,
        Tabs = {},
        ActiveTab = nil,
        WindowData = windowData,
        
        UpdateTheme = function(self, newTheme)
            theme = newTheme
            
            -- Update window colors
            MainFrame.BackgroundColor3 = theme.WindowBg
            TitleBar.BackgroundColor3 = theme.TitleBar
            TitleLabel.TextColor3 = theme.Text
            TabContainer.BackgroundColor3 = theme.Secondary
            ContentFrame.BackgroundColor3 = theme.ContentBg
            ContentFrame.ScrollBarImageColor3 = theme.Accent
            
            ThemeButton.BackgroundColor3 = theme.Button
            ThemeButton.TextColor3 = theme.Text
            MinimizeButton.BackgroundColor3 = theme.Button
            MinimizeButton.TextColor3 = theme.Text
            CloseButton.BackgroundColor3 = theme.Button
            
            -- Update tabs
            for tabName, tabData in pairs(self.Tabs) do
                if tabData.Button then
                    tabData.Button.BackgroundColor3 = theme.TabNormal
                    tabData.Button.TextColor3 = theme.Text
                    
                    if self.ActiveTab == tabName then
                        tabData.Button.BackgroundColor3 = theme.TabActive
                        tabData.Button.TextColor3 = Color3.new(1, 1, 1)
                    end
                end
                
                -- Update tab elements
                if tabData.UpdateTheme then
                    tabData:UpdateTheme(newTheme)
                end
            end
        end,
        
        SetVisible = function(self, visible)
            MainFrame.Visible = visible
            if visible then
                tween(MainFrame, {Size = originalSize})
            end
        end,
        
        Destroy = function(self)
            MainFrame:Destroy()
            self.Windows[windowData.Name] = nil
        end
    }
    
    self.Windows[windowData.Name] = windowObj
    
    -- Tab creation system
    function windowObj:CreateTab(options)
        local tabOptions = type(options) == "string" and {Name = options} or (options or {})
        local tabName = tabOptions.Name or "Tab_" .. (#self.Tabs + 1)
        local scale = self.WindowData.Scale
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(0, 90 * scale, 0, 30 * scale)
        TabButton.Text = tabName
        TabButton.TextColor3 = theme.Text
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 12 * scale
        TabButton.Font = Enum.Font.SourceSans
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = self.TabContainer
        
        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Name = tabName .. "_Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = self.ContentFrame
        
        -- Tab Content Layout
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 10 * scale)
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
        
        setupButtonHover(TabButton)
        
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
                
                -- Update all elements in this tab
                for _, element in pairs(self.ElementObjects) do
                    if element.UpdateTheme then
                        element:UpdateTheme(newTheme)
                    end
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
                Button.TextSize = 13 * scale
                Button.Font = Enum.Font.SourceSansSemibold
                Button.AutoButtonColor = false
                Button.LayoutOrder = #self.Elements + 1
                Button.Parent = TabContent
                
                -- Rounded corners
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 6 * scale)
                Corner.Parent = Button
                
                -- Hover effect
                setupButtonHover(Button)
                
                -- Click animation and callback
                Button.MouseButton1Click:Connect(function()
                    tween(Button, {BackgroundColor3 = theme.Active})
                    task.wait(0.1)
                    tween(Button, {BackgroundColor3 = theme.Button})
                    
                    if opts.Callback then
                        pcall(opts.Callback)
                    end
                end)
                
                table.insert(self.Elements, Button)
                self.ElementObjects[Button.Name] = Button
                
                return Button
            end,
            
            CreateLabel = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local Label = Instance.new("TextLabel")
                Label.Name = opts.Name or "Label_" .. #self.Elements + 1
                Label.Size = UDim2.new(0.9, 0, 0, 24 * scale)
                Label.Text = opts.Text or Label.Name
                Label.TextColor3 = theme.Text
                Label.BackgroundTransparency = 1
                Label.TextSize = 13 * scale
                Label.Font = Enum.Font.SourceSans
                Label.TextXAlignment = opts.Alignment or Enum.TextXAlignment.Left
                Label.LayoutOrder = #self.Elements + 1
                Label.Parent = TabContent
                
                table.insert(self.Elements, Label)
                self.ElementObjects[Label.Name] = Label
                
                return Label
            end,
            
            CreateInput = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local InputFrame = Instance.new("Frame")
                InputFrame.Name = opts.Name or "Input_" .. #self.Elements + 1
                InputFrame.Size = UDim2.new(0.9, 0, 0, 36 * scale)
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
                InputBox.TextSize = 13 * scale
                InputBox.Font = Enum.Font.SourceSans
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = InputFrame
                
                -- Rounded corners
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 6 * scale)
                Corner.Parent = InputBox
                
                -- Padding
                local Padding = Instance.new("UIPadding")
                Padding.PaddingLeft = UDim.new(0, 10 * scale)
                Padding.PaddingRight = UDim.new(0, 10 * scale)
                Padding.Parent = InputBox
                
                -- Focus effects
                InputBox.Focused:Connect(function()
                    tween(InputBox, {BackgroundColor3 = theme.Hover})
                end)
                
                InputBox.FocusLost:Connect(function()
                    tween(InputBox, {BackgroundColor3 = theme.InputBg})
                    if opts.Callback then
                        pcall(opts.Callback, InputBox.Text)
                    end
                end)
                
                -- ✅ REAL-TIME TEXT CHANGED EVENT (FIXED!)
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    if opts.Callback then
                        pcall(opts.Callback, InputBox.Text)
                    end
                end)
                
                table.insert(self.Elements, InputFrame)
                self.ElementObjects[InputFrame.Name] = {
                    Frame = InputFrame,
                    TextBox = InputBox,
                    UpdateTheme = function(_, newTheme)
                        InputBox.BackgroundColor3 = newTheme.InputBg
                        InputBox.TextColor3 = newTheme.Text
                    end
                }
                
                return InputBox
            end,
            
            CreateToggle = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = opts.Name or "Toggle_" .. #self.Elements + 1
                ToggleFrame.Size = UDim2.new(0.9, 0, 0, 32 * scale)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.LayoutOrder = #self.Elements + 1
                ToggleFrame.Parent = TabContent
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "Label"
                ToggleLabel.Size = UDim2.new(1, -60 * scale, 1, 0)
                ToggleLabel.Text = opts.Text or ToggleFrame.Name
                ToggleLabel.TextColor3 = theme.Text
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.TextSize = 13 * scale
                ToggleLabel.Font = Enum.Font.SourceSans
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "Toggle"
                ToggleButton.Size = UDim2.new(0, 50 * scale, 0, 24 * scale)
                ToggleButton.Position = UDim2.new(1, -55 * scale, 0.5, -12 * scale)
                ToggleButton.Text = ""
                ToggleButton.BackgroundColor3 = theme.ToggleOff
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = ToggleFrame
                
                -- Rounded corners
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 12 * scale)
                Corner.Parent = ToggleButton
                
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "Circle"
                ToggleCircle.Size = UDim2.new(0, 18 * scale, 0, 18 * scale)
                ToggleCircle.Position = UDim2.new(0, 3 * scale, 0.5, -9 * scale)
                ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
                ToggleCircle.Parent = ToggleButton
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(0.5, 0)
                CircleCorner.Parent = ToggleCircle
                
                local isToggled = opts.CurrentValue or false
                
                local function updateToggle()
                    if isToggled then
                        tween(ToggleButton, {BackgroundColor3 = theme.ToggleOn})
                        tween(ToggleCircle, {Position = UDim2.new(1, -21 * scale, 0.5, -9 * scale)})
                    else
                        tween(ToggleButton, {BackgroundColor3 = theme.ToggleOff})
                        tween(ToggleCircle, {Position = UDim2.new(0, 3 * scale, 0.5, -9 * scale)})
                    end
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
                self.ElementObjects[ToggleFrame.Name] = {
                    Frame = ToggleFrame,
                    Set = function(value)
                        isToggled = value
                        updateToggle()
                    end,
                    Get = function() return isToggled end,
                    UpdateTheme = function(_, newTheme)
                        ToggleLabel.TextColor3 = newTheme.Text
                        ToggleButton.BackgroundColor3 = isToggled and newTheme.ToggleOn or newTheme.ToggleOff
                    end
                }
                
                return self.ElementObjects[ToggleFrame.Name]
            end,
            
            CreateSlider = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = opts.Name or "Slider_" .. #self.Elements + 1
                SliderFrame.Size = UDim2.new(0.9, 0, 0, 50 * scale)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.LayoutOrder = #self.Elements + 1
                SliderFrame.Parent = TabContent
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "Label"
                SliderLabel.Size = UDim2.new(1, 0, 0, 20 * scale)
                SliderLabel.Text = opts.Text or SliderFrame.Name .. ": " .. (opts.CurrentValue or 0)
                SliderLabel.TextColor3 = theme.Text
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.TextSize = 13 * scale
                SliderLabel.Font = Enum.Font.SourceSans
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Name = "Track"
                SliderTrack.Size = UDim2.new(1, 0, 0, 6 * scale)
                SliderTrack.Position = UDim2.new(0, 0, 0, 30 * scale)
                SliderTrack.BackgroundColor3 = theme.SliderTrack
                SliderTrack.Parent = SliderFrame
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 3 * scale)
                TrackCorner.Parent = SliderTrack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
                SliderFill.BackgroundColor3 = theme.SliderFill
                SliderFill.Parent = SliderTrack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3 * scale)
                FillCorner.Parent = SliderFill
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Name = "SliderButton"
                SliderButton.Size = UDim2.new(0, 16 * scale, 0, 16 * scale)
                SliderButton.Position = UDim2.new(0.5, -8 * scale, 0.5, -8 * scale)
                SliderButton.Text = ""
                SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
                SliderButton.AutoButtonColor = false
                SliderButton.Parent = SliderTrack
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0.5, 0)
                ButtonCorner.Parent = SliderButton
                
                local minVal = opts.Range and opts.Range[1] or 0
                local maxVal = opts.Range and opts.Range[2] or 100
                local currentVal = opts.CurrentValue or minVal
                
                local function updateSlider(value)
                    currentVal = math.clamp(value, minVal, maxVal)
                    local percent = (currentVal - minVal) / (maxVal - minVal)
                    
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderButton.Position = UDim2.new(percent, -8 * scale, 0.5, -8 * scale)
                    SliderLabel.Text = opts.Text and (opts.Text .. ": " .. currentVal) or (SliderFrame.Name .. ": " .. currentVal)
                    
                    if opts.Callback then
                        pcall(opts.Callback, currentVal)
                    end
                end
                
                updateSlider(currentVal)
                
                local dragging = false
                
                local function onInputChanged(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = input.Position.X
                        local trackPos = SliderTrack.AbsolutePosition.X
                        local trackWidth = SliderTrack.AbsoluteSize.X
                        
                        local percent = math.clamp((mousePos - trackPos) / trackWidth, 0, 1)
                        local value = minVal + (percent * (maxVal - minVal))
                        
                        if opts.Increment then
                            value = math.floor(value / opts.Increment) * opts.Increment
                        end
                        
                        updateSlider(value)
                    end
                end
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        onInputChanged(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(onInputChanged)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                table.insert(self.Elements, SliderFrame)
                self.ElementObjects[SliderFrame.Name] = {
                    Frame = SliderFrame,
                    Set = function(value) updateSlider(value) end,
                    Get = function() return currentVal end,
                    UpdateTheme = function(_, newTheme)
                        SliderLabel.TextColor3 = newTheme.Text
                        SliderTrack.BackgroundColor3 = newTheme.SliderTrack
                        SliderFill.BackgroundColor3 = newTheme.SliderFill
                    end
                }
                
                return self.ElementObjects[SliderFrame.Name]
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
    
    -- Create theme tab if requested
    if windowData.ShowThemeTab then
        local ThemeTab = windowObj:CreateTab("🎨 Theme")
        
        ThemeTab:CreateLabel({Text = "Select Theme:", Alignment = Enum.TextXAlignment.Center})
        ThemeTab:CreateButton({Text = "🌙 Dark Theme", Callback = function() self:SetTheme("DARK") end})
        ThemeTab:CreateButton({Text = "☀️ Light Theme", Callback = function() self:SetTheme("LIGHT") end})
        ThemeTab:CreateButton({Text = "💜 Purple Theme", Callback = function() self:SetTheme("PURPLE") end})
        
        ThemeButton.MouseButton1Click:Connect(function()
            if windowObj.ActiveTab ~= "🎨 Theme" then
                ThemeTab.Button:MouseButton1Click()
            end
        end)
    end
    
    print("✅ Created window: " .. windowData.Name)
    return windowObj
end

print("🎉 SimpleGUI v6.0 - Modern & Responsive loaded!")
return SimpleGUI