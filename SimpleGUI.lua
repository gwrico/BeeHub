-- ==============================================
-- 🎨 SIMPLEGUI v7.1 - SPEEDHUB EDITION
-- ==============================================
print("🔧 Loading SimpleGUI - SpeedHub Edition...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Color scheme mirip SpeedHub
SimpleGUI.Themes = {
    DARK = {
        Name = "Dark",
        Primary = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(0, 170, 255),  -- Biru terang khas SpeedHub
        AccentLight = Color3.fromRGB(64, 200, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 195),
        Success = Color3.fromRGB(0, 255, 100),
        Warning = Color3.fromRGB(255, 170, 0),
        Error = Color3.fromRGB(255, 70, 70),
        Border = Color3.fromRGB(50, 50, 60),
        Hover = Color3.fromRGB(55, 55, 70),
        Active = Color3.fromRGB(0, 170, 255),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(20, 20, 28),
        TitleBar = Color3.fromRGB(30, 30, 40),
        TabNormal = Color3.fromRGB(40, 40, 50),
        TabActive = Color3.fromRGB(0, 170, 255),
        ContentBg = Color3.fromRGB(28, 28, 35),
        Button = Color3.fromRGB(45, 45, 55),
        ButtonHover = Color3.fromRGB(60, 60, 75),
        InputBg = Color3.fromRGB(38, 38, 45),
        ToggleOff = Color3.fromRGB(70, 70, 80),
        ToggleOn = Color3.fromRGB(0, 170, 255),
        SliderTrack = Color3.fromRGB(45, 45, 55),
        SliderFill = Color3.fromRGB(0, 170, 255),
        Sidebar = Color3.fromRGB(25, 25, 35),
        HeaderText = Color3.fromRGB(0, 170, 255)  -- Warna biru untuk header
    }
}

function SimpleGUI.new()
    print("🚀 Initializing SpeedHub Edition...")
    
    local self = setmetatable({}, SimpleGUI)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SpeedHub_GUI_" .. math.random(1000, 9999)
    self.ScreenGui.DisplayOrder = 99999
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    
    local success, err = pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.Windows = {}
    self.CurrentTheme = "DARK"
    self.MinimizedIcons = {}
    
    print("✅ SpeedHub Edition initialized!")
    return self
end

-- Theme management
function SimpleGUI:SetTheme(themeName)
    local themeKey = themeName:upper()
    if self.Themes[themeKey] then
        self.CurrentTheme = themeKey
        print("🎨 Applied theme: " .. self.Themes[themeKey].Name)
        
        for _, window in pairs(self.Windows) do
            if window.UpdateTheme then
                window:UpdateTheme(self.Themes[themeKey])
            end
        end
        
        for _, icon in pairs(self.MinimizedIcons) do
            if icon and icon.UpdateTheme then
                icon:UpdateTheme(self.Themes[themeKey])
            end
        end
    end
end

function SimpleGUI:GetTheme()
    return self.Themes[self.CurrentTheme]
end

-- Animation helper
local function tween(object, properties, duration, easingStyle)
    if not object then return nil end
    
    local tweenInfo = TweenInfo.new(
        duration or 0.2, 
        easingStyle or Enum.EasingStyle.Quint, 
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Create window dengan tampilan SpeedHub
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local isMobile = UserInputService.TouchEnabled
    local scale = isMobile and 0.85 or 1.0
    
    local windowData = {
        Name = opts.Name or "Speed Hub X",
        SubName = opts.SubName or "Version 5.0.3 | discord.gg/speedhubx",
        Size = opts.Size or UDim2.new(0, 800 * scale, 0, 550 * scale),
        Position = opts.Position or UDim2.new(0.5, -400 * scale, 0.5, -275 * scale),
        IsMobile = isMobile,
        Scale = scale,
        SidebarWidth = 200 * scale,
        Logo = "S"  -- Logo SpeedHub
    }
    
    local theme = self:GetTheme()
    
    -- ===== MAIN WINDOW FRAME =====
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "SpeedHub_Window"
    MainFrame.Size = windowData.Size
    MainFrame.Position = windowData.Position
    MainFrame.BackgroundColor3 = theme.WindowBg
    MainFrame.BackgroundTransparency = 0
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = true
    MainFrame.Parent = self.ScreenGui
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://13110549987"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.8
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- Rounded corners
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 12 * scale)
    WindowCorner.Parent = MainFrame
    
    -- ===== TITLE BAR =====
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50 * scale)
    TitleBar.BackgroundColor3 = theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12 * scale)
    TitleBarCorner.Parent = TitleBar
    
    -- Title dengan icon
    local TitleContainer = Instance.new("Frame")
    TitleContainer.Name = "TitleContainer"
    TitleContainer.Size = UDim2.new(0.5, 0, 1, 0)
    TitleContainer.Position = UDim2.new(0, 15 * scale, 0, 0)
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Parent = TitleBar
    
    -- Icon/Logo
    local TitleIcon = Instance.new("TextLabel")
    TitleIcon.Name = "TitleIcon"
    TitleIcon.Size = UDim2.new(0, 32 * scale, 0, 32 * scale)
    TitleIcon.Position = UDim2.new(0, 0, 0.5, -16 * scale)
    TitleIcon.Text = "S"
    TitleIcon.TextColor3 = Color3.new(1, 1, 1)
    TitleIcon.BackgroundColor3 = theme.Accent
    TitleIcon.BackgroundTransparency = 0
    TitleIcon.TextSize = 18 * scale
    TitleIcon.Font = Enum.Font.GothamBold
    TitleIcon.Parent = TitleContainer
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8 * scale)
    IconCorner.Parent = TitleIcon
    
    -- Title Text
    local TitleTextFrame = Instance.new("Frame")
    TitleTextFrame.Name = "TitleTextFrame"
    TitleTextFrame.Size = UDim2.new(1, -40 * scale, 1, 0)
    TitleTextFrame.Position = UDim2.new(0, 40 * scale, 0, 0)
    TitleTextFrame.BackgroundTransparency = 1
    TitleTextFrame.Parent = TitleContainer
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, 0, 0.5, -2)
    TitleLabel.Position = UDim2.new(0, 0, 0, 8 * scale)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16 * scale
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleTextFrame
    
    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Name = "SubTitle"
    SubTitleLabel.Size = UDim2.new(1, 0, 0.5, -2)
    SubTitleLabel.Position = UDim2.new(0, 0, 0.5, 2)
    SubTitleLabel.Text = windowData.SubName
    SubTitleLabel.TextColor3 = theme.TextSecondary
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.TextSize = 11 * scale
    SubTitleLabel.Font = Enum.Font.Gotham
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.Parent = TitleTextFrame
    
    -- Control Buttons
    local buttonSize = 32 * scale
    local buttonSpacing = 8 * scale
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    MinimizeButton.Position = UDim2.new(1, -buttonSize * 2 - buttonSpacing * 2 - 15 * scale, 0.5, -buttonSize/2)
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = theme.TextSecondary
    MinimizeButton.BackgroundColor3 = theme.Button
    MinimizeButton.BackgroundTransparency = 0
    MinimizeButton.TextSize = 20 * scale
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Parent = TitleBar
    
    local MinimizeButtonCorner = Instance.new("UICorner")
    MinimizeButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
    MinimizeButtonCorner.Parent = MinimizeButton
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    CloseButton.Position = UDim2.new(1, -buttonSize - 15 * scale, 0.5, -buttonSize/2)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = theme.Error
    CloseButton.BackgroundColor3 = theme.Button
    CloseButton.BackgroundTransparency = 0
    CloseButton.TextSize = 16 * scale
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Parent = TitleBar
    
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
    CloseButtonCorner.Parent = CloseButton
    
    -- ===== SIDEBAR =====
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, windowData.SidebarWidth, 1, -50 * scale)
    Sidebar.Position = UDim2.new(0, 0, 0, 50 * scale)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.BackgroundTransparency = 0
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    Sidebar.ScrollBarThickness = 4 * scale
    Sidebar.ScrollBarImageColor3 = theme.Accent
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    Sidebar.ElasticBehavior = Enum.ElasticBehavior.Always
    Sidebar.Parent = MainFrame
    
    -- Sidebar Border (garis pemisah)
    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Name = "SidebarBorder"
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = theme.Border
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = Sidebar
    
    -- Sidebar Header "MENU"
    local SidebarHeader = Instance.new("Frame")
    SidebarHeader.Name = "SidebarHeader"
    SidebarHeader.Size = UDim2.new(1, 0, 0, 40 * scale)
    SidebarHeader.BackgroundTransparency = 1
    SidebarHeader.Parent = Sidebar
    
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Name = "HeaderLabel"
    HeaderLabel.Size = UDim2.new(1, -20, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 10, 0, 10)
    HeaderLabel.Text = "MENU"
    HeaderLabel.TextColor3 = theme.HeaderText
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.TextSize = 14 * scale
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = SidebarHeader
    
    -- Sidebar Container
    local SidebarContainer = Instance.new("Frame")
    SidebarContainer.Name = "SidebarContainer"
    SidebarContainer.Size = UDim2.new(1, 0, 0, 0)
    SidebarContainer.BackgroundTransparency = 1
    SidebarContainer.Parent = Sidebar
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5 * scale)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = SidebarContainer
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 45 * scale)
    SidebarPadding.PaddingLeft = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingRight = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingBottom = UDim.new(0, 10 * scale)
    SidebarPadding.Parent = SidebarContainer
    
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarContainer.Size = UDim2.new(1, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 55 * scale)
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 55 * scale)
    end)
    
    -- ===== CONTENT FRAME =====
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -windowData.SidebarWidth, 1, -50 * scale)
    ContentFrame.Position = UDim2.new(0, windowData.SidebarWidth, 0, 50 * scale)
    ContentFrame.BackgroundColor3 = theme.ContentBg
    ContentFrame.BackgroundTransparency = 0
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 4 * scale
    ContentFrame.ScrollBarImageColor3 = theme.Accent
    ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentFrame.ElasticBehavior = Enum.ElasticBehavior.Always
    ContentFrame.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 12 * scale)
    ContentCorner.Parent = ContentFrame
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = ContentFrame
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 15 * scale)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentContainer
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 18 * scale)
    ContentPadding.PaddingRight = UDim.new(0, 18 * scale)
    ContentPadding.PaddingTop = UDim.new(0, 18 * scale)
    ContentPadding.PaddingBottom = UDim.new(0, 18 * scale)
    ContentPadding.Parent = ContentContainer
    
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 36 * scale)
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 36 * scale)
    end)
    
    -- ===== SECTION HEADER =====
    local function createSectionHeader(parent, title)
        local HeaderFrame = Instance.new("Frame")
        HeaderFrame.Name = title .. "_Header"
        HeaderFrame.Size = UDim2.new(1, 0, 0, 30 * scale)
        HeaderFrame.BackgroundTransparency = 1
        HeaderFrame.Parent = parent
        
        local HeaderTitle = Instance.new("TextLabel")
        HeaderTitle.Name = "HeaderTitle"
        HeaderTitle.Size = UDim2.new(0.5, 0, 1, 0)
        HeaderTitle.Text = title
        HeaderTitle.TextColor3 = theme.HeaderText
        HeaderTitle.BackgroundTransparency = 1
        HeaderTitle.TextSize = 16 * scale
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
        HeaderTitle.Parent = HeaderFrame
        
        local HeaderLine = Instance.new("Frame")
        HeaderLine.Name = "HeaderLine"
        HeaderLine.Size = UDim2.new(0.5, -20, 0, 1)
        HeaderLine.Position = UDim2.new(0.5, 10, 0.5, 0)
        HeaderLine.BackgroundColor3 = theme.Border
        HeaderLine.BorderSizePixel = 0
        HeaderLine.Parent = HeaderFrame
        
        return HeaderFrame
    end
    
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
        IsMinimized = false,
        
        UpdateTheme = function(self, newTheme)
            theme = newTheme
            
            MainFrame.BackgroundColor3 = theme.WindowBg
            TitleBar.BackgroundColor3 = theme.TitleBar
            TitleLabel.TextColor3 = theme.Text
            SubTitleLabel.TextColor3 = theme.TextSecondary
            TitleIcon.BackgroundColor3 = theme.Accent
            Sidebar.BackgroundColor3 = theme.Sidebar
            SidebarBorder.BackgroundColor3 = theme.Border
            Sidebar.ScrollBarImageColor3 = theme.Accent
            HeaderLabel.TextColor3 = theme.HeaderText
            ContentFrame.BackgroundColor3 = theme.ContentBg
            ContentFrame.ScrollBarImageColor3 = theme.Accent
            
            MinimizeButton.BackgroundColor3 = theme.Button
            MinimizeButton.TextColor3 = theme.TextSecondary
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
        local icon = tabOptions.Icon or ""
        local scale = self.WindowData.Scale
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(1, -20 * scale, 0, 40 * scale)
        TabButton.Text = icon .. "  " .. tabName
        TabButton.TextColor3 = theme.Text
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 13 * scale
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = SidebarContainer
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
        TabButtonCorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Name = tabName .. "_Content"
        TabContent.Size = UDim2.new(1, 0, 0, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 15 * scale)
        TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.Size = UDim2.new(1, 0, 0, TabLayout.AbsoluteContentSize.Y)
        end)
        
        -- Tab click handler
        TabButton.MouseButton1Click:Connect(function()
            for name, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tween(tab.Button, {BackgroundColor3 = theme.TabNormal}, 0.15)
                tab.Button.TextColor3 = theme.Text
            end
            
            TabContent.Visible = true
            tween(TabButton, {BackgroundColor3 = theme.TabActive}, 0.15)
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            self.ActiveTab = tabName
        end)
        
        -- Button hover effects
        local function setupButtonHover(button, hoverColor, normalColor)
            if not button or not button:IsA("TextButton") then return end
            
            button.MouseEnter:Connect(function()
                if not isMobile then
                    tween(button, {BackgroundColor3 = hoverColor or theme.ButtonHover}, 0.15)
                end
            end)
            
            button.MouseLeave:Connect(function()
                if not isMobile then
                    tween(button, {BackgroundColor3 = normalColor or theme.Button}, 0.15)
                end
            end)
        end
        
        setupButtonHover(TabButton, theme.Hover, theme.TabNormal)
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
            
            CreateSection = function(self, title)
                return createSectionHeader(TabContent, title)
            end,
            
            CreateButton = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local Button = Instance.new("TextButton")
                Button.Name = opts.Name or "Button_" .. #self.Elements + 1
                Button.Size = UDim2.new(0.95, 0, 0, 38 * scale)
                Button.Text = opts.Text or Button.Name
                Button.TextColor3 = theme.Text
                Button.BackgroundColor3 = theme.Button
                Button.BackgroundTransparency = 0
                Button.TextSize = 13 * scale
                Button.Font = Enum.Font.Gotham
                Button.AutoButtonColor = false
                Button.LayoutOrder = #self.Elements + 1
                Button.Parent = TabContent
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8 * scale)
                Corner.Parent = Button
                
                setupButtonHover(Button, theme.ButtonHover, theme.Button)
                
                Button.MouseButton1Click:Connect(function()
                    tween(Button, {BackgroundColor3 = theme.Active}, 0.1)
                    task.wait(0.1)
                    tween(Button, {BackgroundColor3 = theme.ButtonHover}, 0.1)
                    task.wait(0.1)
                    tween(Button, {BackgroundColor3 = theme.Button}, 0.1)
                    
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
                Label.Size = UDim2.new(0.95, 0, 0, 30 * scale)
                Label.Text = opts.Text or Label.Name
                Label.TextColor3 = opts.Color or theme.Text
                Label.BackgroundTransparency = 1
                Label.TextSize = opts.Size or 13 * scale
                Label.Font = opts.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
                Label.TextXAlignment = opts.Alignment or Enum.TextXAlignment.Left
                Label.LayoutOrder = #self.Elements + 1
                Label.Parent = TabContent
                
                table.insert(self.Elements, Label)
                return Label
            end,
            
            CreateToggle = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = opts.Name or "Toggle_" .. #self.Elements + 1
                ToggleFrame.Size = UDim2.new(0.95, 0, 0, 40 * scale)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.LayoutOrder = #self.Elements + 1
                ToggleFrame.Parent = TabContent
                
                -- Toggle container
                local ToggleContainer = Instance.new("TextButton")
                ToggleContainer.Name = "ToggleContainer"
                ToggleContainer.Size = UDim2.new(0, 48 * scale, 0, 24 * scale)
                ToggleContainer.Position = UDim2.new(0, 0, 0.5, -12 * scale)
                ToggleContainer.Text = ""
                ToggleContainer.BackgroundColor3 = theme.ToggleOff
                ToggleContainer.BackgroundTransparency = 0
                ToggleContainer.BorderSizePixel = 0
                ToggleContainer.AutoButtonColor = false
                ToggleContainer.Parent = ToggleFrame
                
                local ContainerCorner = Instance.new("UICorner")
                ContainerCorner.CornerRadius = UDim.new(0, 12 * scale)
                ContainerCorner.Parent = ToggleContainer
                
                -- Toggle circle
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Size = UDim2.new(0, 20 * scale, 0, 20 * scale)
                ToggleCircle.Position = UDim2.new(0, 2 * scale, 0.5, -10 * scale)
                ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
                ToggleCircle.BackgroundTransparency = 0
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Parent = ToggleContainer
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(0.5, 0)
                CircleCorner.Parent = ToggleCircle
                
                -- Toggle label
                local ToggleLabel = Instance.new("TextButton")
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Size = UDim2.new(1, -58 * scale, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 58 * scale, 0, 0)
                ToggleLabel.Text = opts.Text or opts.Name or "Toggle"
                ToggleLabel.TextColor3 = theme.Text
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.TextSize = 13 * scale
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.AutoButtonColor = false
                ToggleLabel.Parent = ToggleFrame
                
                -- Toggle state
                local isToggled = opts.CurrentValue or false
                
                local function updateToggle()
                    if isToggled then
                        tween(ToggleContainer, {BackgroundColor3 = theme.ToggleOn}, 0.2)
                        tween(ToggleCircle, {Position = UDim2.new(1, -22 * scale, 0.5, -10 * scale)}, 0.2)
                    else
                        tween(ToggleContainer, {BackgroundColor3 = theme.ToggleOff}, 0.2)
                        tween(ToggleCircle, {Position = UDim2.new(0, 2 * scale, 0.5, -10 * scale)}, 0.2)
                    end
                end
                
                updateToggle()
                
                local function toggle()
                    isToggled = not isToggled
                    updateToggle()
                    if opts.Callback then
                        pcall(opts.Callback, isToggled)
                    end
                end
                
                ToggleContainer.MouseButton1Click:Connect(toggle)
                ToggleLabel.MouseButton1Click:Connect(toggle)
                
                table.insert(self.Elements, ToggleFrame)
                
                return {
                    Frame = ToggleFrame,
                    GetValue = function() return isToggled end,
                    SetValue = function(value)
                        isToggled = value
                        updateToggle()
                        if opts.Callback then
                            pcall(opts.Callback, isToggled)
                        end
                    end
                }
            end
        }
        
        self.Tabs[tabName] = tabObj
        
        if #self.Tabs == 1 then
            TabButton.BackgroundColor3 = theme.TabActive
            TabButton.TextColor3 = Color3.new(1, 1, 1)
            TabContent.Visible = true
            self.ActiveTab = tabName
        end
        
        return tabObj
    end
    
    -- ===== MINIMIZE FUNCTIONALITY =====
    local originalSize = windowData.Size
    local isMinimized = false
    
    -- Minimized icon
    local MinimizedIcon = Instance.new("TextButton")
    MinimizedIcon.Name = "MinimizedIcon_SpeedHub"
    MinimizedIcon.Size = UDim2.new(0, 45 * scale, 0, 45 * scale)
    MinimizedIcon.Position = UDim2.new(0, 20, 0, 20)
    MinimizedIcon.Text = "S"
    MinimizedIcon.TextColor3 = Color3.new(1, 1, 1)
    MinimizedIcon.BackgroundColor3 = theme.Accent
    MinimizedIcon.BackgroundTransparency = 0
    MinimizedIcon.TextSize = 22 * scale
    MinimizedIcon.Font = Enum.Font.GothamBold
    MinimizedIcon.Visible = false
    MinimizedIcon.Parent = self.ScreenGui
    
    local IconShadow = Instance.new("ImageLabel")
    IconShadow.Name = "IconShadow"
    IconShadow.Size = UDim2.new(1, 10, 1, 10)
    IconShadow.Position = UDim2.new(0, -5, 0, -5)
    IconShadow.BackgroundTransparency = 1
    IconShadow.Image = "rbxassetid://13110549987"
    IconShadow.ImageColor3 = Color3.new(0, 0, 0)
    IconShadow.ImageTransparency = 0.7
    IconShadow.ScaleType = Enum.ScaleType.Slice
    IconShadow.SliceCenter = Rect.new(10, 10, 10, 10)
    IconShadow.ZIndex = -1
    IconShadow.Parent = MinimizedIcon
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 12 * scale)
    IconCorner.Parent = MinimizedIcon
    
    self.MinimizedIcons[windowData.Name] = {
        Icon = MinimizedIcon,
        UpdateTheme = function(self, newTheme)
            MinimizedIcon.BackgroundColor3 = newTheme.Accent
        end
    }
    
    local function setMinimized(minimize)
        isMinimized = minimize
        windowObj.IsMinimized = minimize
        
        if minimize then
            local windowPos = MainFrame.Position
            
            tween(MainFrame, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = windowPos
            }, 0.2)
            
            task.wait(0.15)
            MainFrame.Visible = false
            
            MinimizedIcon.Position = UDim2.new(
                windowPos.X.Scale,
                windowPos.X.Offset,
                windowPos.Y.Scale,
                windowPos.Y.Offset
            )
            MinimizedIcon.Visible = true
            MinimizedIcon.Size = UDim2.new(0, 0, 0, 0)
            tween(MinimizedIcon, {Size = UDim2.new(0, 45 * scale, 0, 45 * scale)}, 0.2, Enum.EasingStyle.Back)
            
            MinimizeButton.Text = "◉"
        else
            tween(MinimizedIcon, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
            task.wait(0.1)
            MinimizedIcon.Visible = false
            
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            tween(MainFrame, {Size = originalSize}, 0.2, Enum.EasingStyle.Back)
            
            MinimizeButton.Text = "—"
        end
    end
    
    MinimizeButton.MouseButton1Click:Connect(function()
        setMinimized(not isMinimized)
    end)
    
    MinimizedIcon.MouseButton1Click:Connect(function()
        setMinimized(false)
    end)
    
    -- Dragging for icon
    local iconDragging = false
    local iconDragStart, iconStartPos
    
    MinimizedIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            iconDragging = true
            iconDragStart = input.Position
            iconStartPos = MinimizedIcon.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if iconDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - iconDragStart
            MinimizedIcon.Position = UDim2.new(
                iconStartPos.X.Scale,
                iconStartPos.X.Offset + delta.X,
                iconStartPos.Y.Scale,
                iconStartPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and iconDragging then
            iconDragging = false
        end
    end)
    
    -- Close button
    CloseButton.MouseButton1Click:Connect(function()
        if isMinimized then
            tween(MinimizedIcon, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
            task.wait(0.15)
            MinimizedIcon.Visible = false
        else
            tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            MainFrame.Visible = false
        end
    end)
    
    -- Dragging window
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            tween(TitleBar, {BackgroundColor3 = theme.Hover}, 0.15)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            tween(TitleBar, {BackgroundColor3 = theme.TitleBar}, 0.15)
        end
    end)
    
    print("✅ Created SpeedHub window!")
    return windowObj
end

print("🎉 SpeedHub Edition loaded!")
return SimpleGUI