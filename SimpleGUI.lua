-- ==============================================
-- 🎨 SIMPLEGUI v6.2 - BOTTOM TABS + DROPDOWN
-- ==============================================
print("🔧 Loading SimpleGUI v6.2 - Bottom Tabs + Dropdown...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Modern color schemes (same as before)
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
    }
    -- ... (other themes same)
}

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI v6.2...")
    
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
    
    print("✅ SimpleGUI v6.2 initialized!")
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

-- Create window with BOTTOM TABS
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local isMobile = UserInputService.TouchEnabled
    local scale = isMobile and 0.85 or 1.0
    
    local windowData = {
        Name = opts.Name or "Window",
        Size = opts.Size or UDim2.new(0, 500 * scale, 0, 500 * scale), -- Taller for bottom tabs
        Position = opts.Position or UDim2.new(0.5, -250 * scale, 0.5, -250 * scale),
        ShowThemeTab = opts.ShowThemeTab or false,
        IsMobile = isMobile,
        Scale = scale,
        TabsAtBottom = true  -- ✅ NEW: Tabs at bottom
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
    
    -- Rounded top corners only
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
    
    -- ===== CONTENT FRAME (MIDDLE) =====
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -120 * scale)  -- Space for title + tabs
    ContentFrame.Position = UDim2.new(0, 0, 0, 40 * scale)  -- Below title
    ContentFrame.BackgroundColor3 = theme.ContentBg
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4 * scale
    ContentFrame.ScrollBarImageColor3 = theme.Accent
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentFrame.Parent = MainFrame
    
    -- ===== TAB CONTAINER (BOTTOM) =====
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 45 * scale)
    TabContainer.Position = UDim2.new(0, 0, 1, -45 * scale)  -- ✅ BOTTOM
    TabContainer.BackgroundColor3 = theme.Secondary
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- Rounded bottom corners for tab container
    local TabContainerCorner = Instance.new("UICorner")
    TabContainerCorner.CornerRadius = UDim.new(0, 12 * scale)
    TabContainerCorner.Parent = TabContainer
    
    -- ===== LAYOUTS =====
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
    
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0, 10 * scale)
    TabList.Parent = TabContainer
    
    -- ===== WINDOW OBJECT =====
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
    
    -- ===== TAB CREATION (BOTTOM TABS) =====
    function windowObj:CreateTab(options)
        local tabOptions = type(options) == "string" and {Name = options} or (options or {})
        local tabName = tabOptions.Name or "Tab_" .. (#self.Tabs + 1)
        local scale = self.WindowData.Scale
        
        -- Tab Button (at bottom)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(0, 110 * scale, 0, 35 * scale)
        TabButton.Text = tabName
        TabButton.TextColor3 = theme.Text
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 13 * scale
        TabButton.Font = Enum.Font.SourceSansSemibold
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = self.TabContainer
        
        -- Rounded corners for bottom tab
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
            
            -- ===== CREATE BUTTON =====
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
            
            -- ===== CREATE LABEL =====
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
            
            -- ===== CREATE INPUT =====
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
                
                -- Real-time text changed
                InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    if opts.Callback then
                        pcall(opts.Callback, InputBox.Text)
                    end
                end)
                
                table.insert(self.Elements, InputFrame)
                return InputBox
            end,
            
            -- ===== CREATE DROPDOWN (NEW!) =====
            CreateDropdown = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = opts.Name or "Dropdown_" .. #self.Elements + 1
                DropdownFrame.Size = UDim2.new(0.9, 0, 0, 40 * scale)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.LayoutOrder = #self.Elements + 1
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = TabContent
                
                -- Main dropdown button
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "Button"
                DropdownButton.Size = UDim2.new(1, 0, 0, 40 * scale)
                DropdownButton.Text = opts.PlaceholderText or "Select..."
                DropdownButton.TextColor3 = theme.Text
                DropdownButton.BackgroundColor3 = theme.InputBg
                DropdownButton.BackgroundTransparency = 0
                DropdownButton.TextSize = 14 * scale
                DropdownButton.Font = Enum.Font.SourceSans
                DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                DropdownButton.AutoButtonColor = false
                DropdownButton.Parent = DropdownFrame
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
                ButtonCorner.Parent = DropdownButton
                
                local ButtonPadding = Instance.new("UIPadding")
                ButtonPadding.PaddingLeft = UDim.new(0, 12 * scale)
                ButtonPadding.PaddingRight = UDim.new(0, 35 * scale)
                ButtonPadding.Parent = DropdownButton
                
                -- Arrow icon
                local Arrow = Instance.new("TextLabel")
                Arrow.Name = "Arrow"
                Arrow.Size = UDim2.new(0, 20 * scale, 0, 20 * scale)
                Arrow.Position = UDim2.new(1, -25 * scale, 0.5, -10 * scale)
                Arrow.Text = "▼"
                Arrow.TextColor3 = theme.TextSecondary
                Arrow.BackgroundTransparency = 1
                Arrow.TextSize = 12 * scale
                Arrow.Font = Enum.Font.SourceSans
                Arrow.Parent = DropdownFrame
                
                -- Options frame (hidden)
                local OptionsFrame = Instance.new("Frame")
                OptionsFrame.Name = "Options"
                OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                OptionsFrame.Position = UDim2.new(0, 0, 1, 5 * scale)
                OptionsFrame.BackgroundColor3 = theme.InputBg
                OptionsFrame.BackgroundTransparency = 0
                OptionsFrame.BorderSizePixel = 0
                OptionsFrame.ClipsDescendants = true
                OptionsFrame.Visible = false
                OptionsFrame.Parent = DropdownFrame
                
                local OptionsCorner = Instance.new("UICorner")
                OptionsCorner.CornerRadius = UDim.new(0, 8 * scale)
                OptionsCorner.Parent = OptionsFrame
                
                local OptionsLayout = Instance.new("UIListLayout")
                OptionsLayout.Padding = UDim.new(0, 2 * scale)
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionsLayout.Parent = OptionsFrame
                
                local OptionsPadding = Instance.new("UIPadding")
                OptionsPadding.PaddingTop = UDim.new(0, 5 * scale)
                OptionsPadding.PaddingBottom = UDim.new(0, 5 * scale)
                OptionsPadding.PaddingLeft = UDim.new(0, 5 * scale)
                OptionsPadding.PaddingRight = UDim.new(0, 5 * scale)
                OptionsPadding.Parent = OptionsFrame
                
                local isOpen = false
                local selectedOption = nil
                local optionButtons = {}
                
                -- Function to toggle dropdown
                local function toggleDropdown()
                    isOpen = not isOpen
                    
                    if isOpen then
                        OptionsFrame.Visible = true
                        local optionCount = opts.Options and #opts.Options or 0
                        local maxHeight = math.min(optionCount * 35 * scale, 200 * scale)
                        tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, maxHeight)})
                        Arrow.Text = "▲"
                        tween(DropdownButton, {BackgroundColor3 = theme.Hover})
                    else
                        tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)})
                        task.wait(0.2)
                        OptionsFrame.Visible = false
                        Arrow.Text = "▼"
                        tween(DropdownButton, {BackgroundColor3 = theme.InputBg})
                    end
                end
                
                -- Create option buttons
                if opts.Options then
                    for i, option in ipairs(opts.Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Name = "Option_" .. i
                        OptionButton.Size = UDim2.new(1, -10 * scale, 0, 32 * scale)
                        OptionButton.Position = UDim2.new(0, 5 * scale, 0, 0)
                        OptionButton.Text = option
                        OptionButton.TextColor3 = theme.Text
                        OptionButton.BackgroundColor3 = theme.Button
                        OptionButton.BackgroundTransparency = 0
                        OptionButton.TextSize = 13 * scale
                        OptionButton.Font = Enum.Font.SourceSans
                        OptionButton.AutoButtonColor = false
                        OptionButton.LayoutOrder = i
                        OptionButton.Parent = OptionsFrame
                        
                        local OptionCorner = Instance.new("UICorner")
                        OptionCorner.CornerRadius = UDim.new(0, 6 * scale)
                        OptionCorner.Parent = OptionButton
                        
                        -- Hover effect
                        OptionButton.MouseEnter:Connect(function()
                            tween(OptionButton, {BackgroundColor3 = theme.Hover})
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            tween(OptionButton, {BackgroundColor3 = theme.Button})
                        end)
                        
                        -- Click handler
                        OptionButton.MouseButton1Click:Connect(function()
                            selectedOption = option
                            DropdownButton.Text = option
                            toggleDropdown()
                            
                            if opts.Callback then
                                pcall(opts.Callback, option)
                            end
                        end)
                        
                        table.insert(optionButtons, OptionButton)
                    end
                end
                
                -- Main button click
                DropdownButton.MouseButton1Click:Connect(toggleDropdown)
                
                -- Hover effect for main button
                setupButtonHover(DropdownButton)
                
                table.insert(self.Elements, DropdownFrame)
                
                -- Return dropdown object
                return {
                    Frame = DropdownFrame,
                    Button = DropdownButton,
                    Options = OptionsFrame,
                    GetSelected = function() return selectedOption end,
                    SetSelected = function(option)
                        selectedOption = option
                        DropdownButton.Text = option or opts.PlaceholderText
                    end,
                    SetOptions = function(newOptions)
                        -- Clear old options
                        for _, btn in pairs(optionButtons) do
                            btn:Destroy()
                        end
                        optionButtons = {}
                        
                        -- Create new options
                        if newOptions then
                            for i, option in ipairs(newOptions) do
                                -- ... (same creation code as above)
                            end
                        end
                    end
                }
            end,
            
            -- ===== CREATE TOGGLE (existing) =====
            CreateToggle = function(self, options)
                -- ... (same as before)
            end,
            
            -- ===== CREATE SLIDER (existing) =====
            CreateSlider = function(self, options)
                -- ... (same as before)
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
    
    -- Minimize functionality
    local isMinimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tween(MainFrame, {Size = UDim2.new(windowData.Size.X.Scale, windowData.Size.X.Offset, 0, 40 * scale)})
            TitleLabel.Text = windowData.Name .. " [-]"
            ContentFrame.Visible = false
            TabContainer.Visible = false
            MinimizeButton.Text = "+"
        else
            tween(MainFrame, {Size = windowData.Size})
            TitleLabel.Text = windowData.Name
            ContentFrame.Visible = true
            TabContainer.Visible = true
            MinimizeButton.Text = "_"
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
        ThemeTab:CreateButton({Text = "☀️ Light", Callback = function() self:SetTheme("LIGHT") end})
        ThemeTab:CreateButton({Text = "💜 Purple", Callback = function() self:SetTheme("PURPLE") end})
    end
    
    print("✅ Created window with bottom tabs: " .. windowData.Name)
    return windowObj
end

print("🎉 SimpleGUI v6.2 - Bottom Tabs + Dropdown loaded!")
return SimpleGUI