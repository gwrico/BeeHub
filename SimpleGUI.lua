-- ==============================================
-- 🎨 SIMPLEGUI v5.1 - SIMPLIFIED THEME EDITOR
-- ==============================================
print("🔧 Loading SimpleGUI v5.1 - Simplified Theme Editor...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI v5.1...")
    
    local self = setmetatable({}, SimpleGUI)
    
    -- BUAT SCREEN GUI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SimpleGUIv5_" .. tostring(math.random(10000,99999))
    self.ScreenGui.DisplayOrder = 99999
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    -- AUTO PARENTING SYSTEM
    local parentsToTry = {
        game:GetService("CoreGui"),
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
        workspace
    }
    
    for _, parent in ipairs(parentsToTry) do
        pcall(function()
            self.ScreenGui.Parent = parent
            task.wait(0.05)
        end)
        if self.ScreenGui.Parent then
            print("✅ Parented to: " .. tostring(self.ScreenGui.Parent))
            break
        end
    end
    
    self.Windows = {}
    self.CurrentTheme = "DARK"
    
    -- THEMES (simplified tanpa font size properties)
    self.Themes = {
        DARK = {
            Name = "Dark",
            WindowBg = Color3.fromRGB(40, 40, 60),
            WindowBorder = Color3.fromRGB(100, 100, 150),
            TitleBarBg = Color3.fromRGB(60, 60, 90),
            TitleTextColor = Color3.fromRGB(255, 255, 255),
            ButtonNormal = Color3.fromRGB(80, 80, 120),
            ButtonHover = Color3.fromRGB(100, 100, 140),
            ButtonActive = Color3.fromRGB(100, 150, 255),
            ToggleOff = Color3.fromRGB(70, 70, 100),
            ToggleOn = Color3.fromRGB(100, 150, 255),
            SliderTrack = Color3.fromRGB(70, 70, 100),
            SliderFill = Color3.fromRGB(100, 150, 255),
            InputBg = Color3.fromRGB(70, 70, 100),
            InputFocused = Color3.fromRGB(90, 90, 120),
            TabBg = Color3.fromRGB(50, 50, 75),
            TabNormal = Color3.fromRGB(70, 70, 100),
            TabActive = Color3.fromRGB(100, 150, 255),
            ContentBg = Color3.fromRGB(45, 45, 65)
        },
        
        LIGHT = {
            Name = "Light",
            WindowBg = Color3.fromRGB(245, 245, 245),
            WindowBorder = Color3.fromRGB(200, 200, 200),
            TitleBarBg = Color3.fromRGB(220, 220, 220),
            TitleTextColor = Color3.fromRGB(50, 50, 50),
            ButtonNormal = Color3.fromRGB(180, 180, 180),
            ButtonHover = Color3.fromRGB(200, 200, 200),
            ButtonActive = Color3.fromRGB(66, 135, 245),
            ToggleOff = Color3.fromRGB(160, 160, 160),
            ToggleOn = Color3.fromRGB(66, 135, 245),
            SliderTrack = Color3.fromRGB(160, 160, 160),
            SliderFill = Color3.fromRGB(66, 135, 245),
            InputBg = Color3.fromRGB(240, 240, 240),
            InputFocused = Color3.fromRGB(255, 255, 255),
            TabBg = Color3.fromRGB(230, 230, 230),
            TabNormal = Color3.fromRGB(180, 180, 180),
            TabActive = Color3.fromRGB(66, 135, 245),
            ContentBg = Color3.fromRGB(250, 250, 250)
        },
        
        NIGHT = {
            Name = "Night",
            WindowBg = Color3.fromRGB(20, 20, 30),
            WindowBorder = Color3.fromRGB(50, 50, 80),
            TitleBarBg = Color3.fromRGB(30, 30, 45),
            TitleTextColor = Color3.fromRGB(220, 220, 255),
            ButtonNormal = Color3.fromRGB(50, 50, 80),
            ButtonHover = Color3.fromRGB(70, 70, 100),
            ButtonActive = Color3.fromRGB(120, 180, 255),
            ToggleOff = Color3.fromRGB(40, 40, 60),
            ToggleOn = Color3.fromRGB(120, 180, 255),
            SliderTrack = Color3.fromRGB(40, 40, 60),
            SliderFill = Color3.fromRGB(120, 180, 255),
            InputBg = Color3.fromRGB(40, 40, 60),
            InputFocused = Color3.fromRGB(60, 60, 80),
            TabBg = Color3.fromRGB(35, 35, 50),
            TabNormal = Color3.fromRGB(50, 50, 70),
            TabActive = Color3.fromRGB(120, 180, 255),
            ContentBg = Color3.fromRGB(25, 25, 40)
        }
    }
    
    self.DefaultTheme = self.Themes[self.CurrentTheme]
    
    print("✅ SimpleGUI v5.1 initialized!")
    return self
end

-- SIMPLIFIED THEME MANAGEMENT
function SimpleGUI:SetTheme(themeName)
    if self.Themes[themeName:upper()] then
        self.CurrentTheme = themeName:upper()
        self.DefaultTheme = self.Themes[self.CurrentTheme]
        print("🎨 Applied theme: " .. self.DefaultTheme.Name)
        
        -- Hanya update window utama (tidak perlu update setiap element)
        for windowName, windowObj in pairs(self.Windows) do
            if windowObj.UpdateWindowTheme then
                windowObj:UpdateWindowTheme(self.DefaultTheme)
            end
        end
    end
end

function SimpleGUI:GetCurrentTheme()
    return self.CurrentTheme
end

-- ===== SIMPLIFIED WINDOW CREATION =====
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    
    local windowData = {
        Name = opts.Name or "Window",
        Size = opts.Size or UDim2.new(0, 500, 0, 400),
        Position = opts.Position or UDim2.new(0.5, -250, 0.5, -200),
        Minimizable = opts.Minimizable ~= false,
        ShowThemeTab = opts.ShowThemeTab or false  -- Default false untuk kompatibilitas
    }
    
    local theme = self.DefaultTheme
    
    -- WINDOW FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Window_" .. windowData.Name
    MainFrame.Size = windowData.Size
    MainFrame.Position = windowData.Position
    MainFrame.BackgroundColor3 = theme.WindowBg
    MainFrame.BackgroundTransparency = 0
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = theme.WindowBorder
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = true
    MainFrame.Parent = self.ScreenGui
    
    -- TITLE BAR
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = theme.TitleBarBg
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    -- TITLE TEXT
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.TitleTextColor
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- MINIMIZE BUTTON
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.BackgroundColor3 = theme.ButtonNormal
    MinimizeButton.BackgroundTransparency = 0
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Visible = windowData.Minimizable
    MinimizeButton.Parent = TitleBar
    
    -- CLOSE BUTTON
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 150, 150)
    CloseButton.BackgroundColor3 = theme.ButtonNormal
    CloseButton.BackgroundTransparency = 0
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = TitleBar
    
    -- TAB CONTAINER
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 35)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = theme.TabBg
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- CONTENT FRAME
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -65)
    ContentFrame.Position = UDim2.new(0, 0, 0, 65)
    ContentFrame.BackgroundColor3 = theme.ContentBg
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame
    
    -- ===== MINIMIZE SYSTEM =====
    local isMinimized = false
    local originalSize = windowData.Size
    
    local function updateMinimizeState()
        if isMinimized then
            MainFrame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 25)
            TitleBar.Size = UDim2.new(1, 0, 1, 0)
            TitleLabel.TextSize = 11
            TitleLabel.Text = windowData.Name .. " [-]"
            TabContainer.Visible = false
            ContentFrame.Visible = false
            MinimizeButton.Text = "+"
            MinimizeButton.TextColor3 = Color3.fromRGB(100, 255, 100)
            MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
            MinimizeButton.Position = UDim2.new(1, -50, 0.5, -10)
            CloseButton.Size = UDim2.new(0, 20, 0, 20)
            CloseButton.Position = UDim2.new(1, -25, 0.5, -10)
        else
            MainFrame.Size = originalSize
            TitleBar.Size = UDim2.new(1, 0, 0, 30)
            TitleLabel.TextSize = 14
            TitleLabel.Text = windowData.Name
            TabContainer.Visible = true
            ContentFrame.Visible = true
            MinimizeButton.Text = "_"
            MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
            MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
            CloseButton.Size = UDim2.new(0, 25, 0, 25)
            CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
        end
    end
    
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        updateMinimizeState()
    end)
    
    -- BUTTON HOVER
    local function setupButtonHover(button, normalColor, hoverColor)
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hoverColor
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normalColor
        end)
    end
    
    setupButtonHover(MinimizeButton, theme.ButtonNormal, theme.ButtonHover)
    setupButtonHover(CloseButton, theme.ButtonNormal, Color3.fromRGB(100, 80, 80))
    
    -- CLOSE
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- DRAGGABLE
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            TitleBar.BackgroundColor3 = theme.ButtonHover
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
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
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            TitleBar.BackgroundColor3 = theme.TitleBarBg
        end
    end)
    
    -- LAYOUTS
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame
    
    -- WINDOW OBJECT
    local windowObj = {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        MinimizeButton = MinimizeButton,
        CloseButton = CloseButton,
        TabContainer = TabContainer,
        ContentFrame = ContentFrame,
        Tabs = {},
        ActiveTab = nil,
        
        UpdateWindowTheme = function(self, newTheme)
            MainFrame.BackgroundColor3 = newTheme.WindowBg
            MainFrame.BorderColor3 = newTheme.WindowBorder
            TitleBar.BackgroundColor3 = newTheme.TitleBarBg
            TitleLabel.TextColor3 = newTheme.TitleTextColor
            TabContainer.BackgroundColor3 = newTheme.TabBg
            ContentFrame.BackgroundColor3 = newTheme.ContentBg
            MinimizeButton.BackgroundColor3 = newTheme.ButtonNormal
            CloseButton.BackgroundColor3 = newTheme.ButtonNormal
            
            -- Update tab buttons
            for tabName, tabData in pairs(self.Tabs) do
                if tabData.Button then
                    tabData.Button.BackgroundColor3 = newTheme.TabNormal
                    tabData.Button.TextColor3 = newTheme.TitleTextColor
                    
                    if self.ActiveTab == tabName then
                        tabData.Button.BackgroundColor3 = newTheme.TabActive
                        tabData.Button.TextColor3 = Color3.new(1, 1, 1)
                    end
                end
            end
        end,
        
        Minimize = function(self)
            isMinimized = true
            updateMinimizeState()
        end,
        
        Restore = function(self)
            isMinimized = false
            updateMinimizeState()
        end,
        
        SetVisible = function(self, visible)
            MainFrame.Visible = visible
        end,
        
        Destroy = function(self)
            MainFrame:Destroy()
            self.Windows[windowData.Name] = nil
        end
    }
    
    self.Windows[windowData.Name] = windowObj
    
    -- ===== SIMPLIFIED TAB CREATION =====
    function windowObj:CreateTab(options)
        local tabOptions = type(options) == "string" and {Name = options} or (options or {})
        local tabName = tabOptions.Name or "Tab_" .. (#self.Tabs + 1)
        
        -- TAB BUTTON
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(0, 90, 0, 28)
        TabButton.Text = tabName
        TabButton.TextColor3 = theme.TitleTextColor
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.SourceSans
        TabButton.AutoButtonColor = true
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = self.TabContainer
        
        -- TAB CONTENT
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "_Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = theme.SliderFill
        TabContent.Visible = false
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.Parent = self.ContentFrame
        
        -- TAB LAYOUT
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 8)
        TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        -- TAB CLICK
        TabButton.MouseButton1Click:Connect(function()
            for name, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = theme.TabNormal
                tab.Button.TextColor3 = theme.TitleTextColor
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = theme.TabActive
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            self.ActiveTab = tabName
        end)
        
        setupButtonHover(TabButton, theme.TabNormal, theme.ButtonHover)
        
        local tabObj = {
            Button = TabButton,
            Content = TabContent,
            Elements = {}
        }
        
        self.Tabs[tabName] = tabObj
        
        if #self.Tabs == 1 then
            TabButton.BackgroundColor3 = theme.TabActive
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            TabContent.Visible = true
            self.ActiveTab = tabName
        end
        
        -- TAB BUILDER METHODS (SAMA SEPERTI SEBELUMNYA)
        local tabBuilder = {}
        
        function tabBuilder:CreateButton(options)
            local opts = options or {}
            
            local Button = Instance.new("TextButton")
            Button.Name = opts.Name or "Button_" .. #tabObj.Elements + 1
            Button.Size = UDim2.new(0.9, 0, 0, 36)
            Button.Text = opts.Text or Button.Name
            Button.TextColor3 = theme.TitleTextColor
            Button.BackgroundColor3 = theme.ButtonNormal
            Button.BackgroundTransparency = 0
            Button.TextSize = 13
            Button.Font = Enum.Font.SourceSans
            Button.AutoButtonColor = true
            Button.LayoutOrder = #tabObj.Elements + 1
            Button.Parent = TabContent
            
            setupButtonHover(Button, theme.ButtonNormal, theme.ButtonHover)
            
            if opts.Callback then
                Button.MouseButton1Click:Connect(function()
                    pcall(opts.Callback)
                end)
            end
            
            table.insert(tabObj.Elements, Button)
            return Button
        end
        
        function tabBuilder:CreateLabel(options)
            local opts = options or {}
            
            local Label = Instance.new("TextLabel")
            Label.Name = opts.Name or "Label_" .. #tabObj.Elements + 1
            Label.Size = UDim2.new(0.9, 0, 0, 26)
            Label.Text = opts.Text or Label.Name
            Label.TextColor3 = theme.TitleTextColor
            Label.BackgroundTransparency = 1
            Label.TextSize = 13
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.LayoutOrder = #tabObj.Elements + 1
            Label.Parent = TabContent
            
            table.insert(tabObj.Elements, Label)
            return Label
        end
        
        function tabBuilder:CreateToggle(options)
            local opts = options or {}
            local toggleName = opts.Name or "Toggle_" .. #tabObj.Elements + 1
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = toggleName .. "_Frame"
            ToggleFrame.Size = UDim2.new(0.9, 0, 0, 32)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.LayoutOrder = #tabObj.Elements + 1
            ToggleFrame.Parent = TabContent
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "Toggle"
            ToggleButton.Size = UDim2.new(0, 50, 0, 24)
            ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
            ToggleButton.Text = ""
            ToggleButton.BackgroundColor3 = theme.ToggleOff
            ToggleButton.BackgroundTransparency = 0
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = ToggleFrame
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "Circle"
            ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
            ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
            ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
            ToggleCircle.BackgroundTransparency = 0
            ToggleCircle.Parent = ToggleButton
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Text = opts.Text or toggleName
            ToggleLabel.TextColor3 = theme.TitleTextColor
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.SourceSans
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local isToggled = opts.CurrentValue or false
            
            if isToggled then
                ToggleButton.BackgroundColor3 = theme.ToggleOn
                ToggleCircle.Position = UDim2.new(1, -22, 0.5, -10)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                isToggled = not isToggled
                
                if isToggled then
                    ToggleButton.BackgroundColor3 = theme.ToggleOn
                    ToggleCircle.Position = UDim2.new(1, -22, 0.5, -10)
                else
                    ToggleButton.BackgroundColor3 = theme.ToggleOff
                    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
                end
                
                if opts.Callback then
                    pcall(opts.Callback, isToggled)
                end
            end)
            
            table.insert(tabObj.Elements, ToggleFrame)
            
            return {
                Set = function(value)
                    isToggled = value
                    if isToggled then
                        ToggleButton.BackgroundColor3 = theme.ToggleOn
                        ToggleCircle.Position = UDim2.new(1, -22, 0.5, -10)
                    else
                        ToggleButton.BackgroundColor3 = theme.ToggleOff
                        ToggleCircle.Position = UDim2.new(0, 2, 0.5, -10)
                    end
                end,
                Get = function() return isToggled end
            }
        end
        
        function tabBuilder:CreateSlider(options)
            local opts = options or {}
            local sliderName = opts.Name or "Slider_" .. #tabObj.Elements + 1
            local minVal = opts.Range and opts.Range[1] or 0
            local maxVal = opts.Range and opts.Range[2] or 100
            local currentVal = opts.CurrentValue or minVal
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderName .. "_Frame"
            SliderFrame.Size = UDim2.new(0.9, 0, 0, 48)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.LayoutOrder = #tabObj.Elements + 1
            SliderFrame.Parent = TabContent
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Size = UDim2.new(1, 0, 0, 20)
            SliderLabel.Text = sliderName .. ": " .. currentVal
            SliderLabel.TextColor3 = theme.TitleTextColor
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.SourceSans
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = "Track"
            SliderTrack.Size = UDim2.new(1, 0, 0, 6)
            SliderTrack.Position = UDim2.new(0, 0, 0, 28)
            SliderTrack.BackgroundColor3 = theme.SliderTrack
            SliderTrack.BorderSizePixel = 0
            SliderTrack.Parent = SliderFrame
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            local fillPercent = (currentVal - minVal) / (maxVal - minVal)
            SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
            SliderFill.BackgroundColor3 = theme.SliderFill
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderTrack
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Name = "SliderButton"
            SliderButton.Size = UDim2.new(0, 14, 0, 14)
            SliderButton.Position = UDim2.new(fillPercent, -7, 0.5, -7)
            SliderButton.Text = ""
            SliderButton.BackgroundColor3 = Color3.new(1, 1, 1)
            SliderButton.BackgroundTransparency = 0
            SliderButton.AutoButtonColor = false
            SliderButton.Parent = SliderTrack
            
            local dragging = false
            
            local function updateSlider(value)
                currentVal = math.clamp(value, minVal, maxVal)
                fillPercent = (currentVal - minVal) / (maxVal - minVal)
                
                SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
                SliderButton.Position = UDim2.new(fillPercent, -7, 0.5, -7)
                SliderLabel.Text = sliderName .. ": " .. math.floor(currentVal)
                
                if opts.Callback then
                    pcall(opts.Callback, currentVal)
                end
            end
            
            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position.X
                    local sliderPos = SliderTrack.AbsolutePosition.X
                    local sliderWidth = SliderTrack.AbsoluteSize.X
                    
                    local relativePos = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
                    local newValue = minVal + (relativePos * (maxVal - minVal))
                    
                    if opts.Increment then
                        newValue = math.floor(newValue / opts.Increment) * opts.Increment
                    end
                    
                    updateSlider(newValue)
                end
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            table.insert(tabObj.Elements, SliderFrame)
            
            return {
                Set = function(value) updateSlider(value) end,
                Get = function() return currentVal end
            }
        end
        
        function tabBuilder:CreateInput(options)
            local opts = options or {}
            local inputName = opts.Name or "Input_" .. #tabObj.Elements + 1
            
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = inputName .. "_Frame"
            InputFrame.Size = UDim2.new(0.9, 0, 0, 36)
            InputFrame.BackgroundTransparency = 1
            InputFrame.LayoutOrder = #tabObj.Elements + 1
            InputFrame.Parent = TabContent
            
            local InputBox = Instance.new("TextBox")
            InputBox.Name = "InputBox"
            InputBox.Size = UDim2.new(1, 0, 1, 0)
            InputBox.Text = opts.CurrentValue or ""
            InputBox.PlaceholderText = opts.PlaceholderText or "Enter text..."
            InputBox.TextColor3 = theme.TitleTextColor
            InputBox.BackgroundColor3 = theme.InputBg
            InputBox.BackgroundTransparency = 0
            InputBox.TextSize = 13
            InputBox.Font = Enum.Font.SourceSans
            InputBox.ClearTextOnFocus = false
            InputBox.Parent = InputFrame
            
            InputBox.Focused:Connect(function()
                InputBox.BackgroundColor3 = theme.InputFocused
            end)
            
            InputBox.FocusLost:Connect(function(enterPressed)
                if opts.Callback then
                    pcall(opts.Callback, InputBox.Text)
                end
                InputBox.BackgroundColor3 = theme.InputBg
            end)
            
            table.insert(tabObj.Elements, InputFrame)
            return InputBox
        end
        
        return tabBuilder
    end
    
    -- ===== OPTIONAL THEME TAB =====
    if windowData.ShowThemeTab then
        local ThemeTab = windowObj:CreateTab("🎨 Theme")
        
        ThemeTab:CreateLabel({
            Text = "Select Theme:"
        })
        
        ThemeTab:CreateButton({
            Text = "🌙 Dark Theme",
            Callback = function()
                self:SetTheme("DARK")
            end
        })
        
        ThemeTab:CreateButton({
            Text = "☀️ Light Theme",
            Callback = function()
                self:SetTheme("LIGHT")
            end
        })
        
        ThemeTab:CreateButton({
            Text = "🌃 Night Theme",
            Callback = function()
                self:SetTheme("NIGHT")
            end
        })
        
        ThemeTab:CreateLabel({
            Text = "Current: " .. self.DefaultTheme.Name
        })
    end
    
    print("✅ Window created: " .. windowData.Name)
    return windowObj
end

print("🎉 SimpleGUI v5.1 - Simplified Theme Editor loaded!")
return SimpleGUI
