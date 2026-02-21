-- ==============================================
-- 🎨 SIMPLEGUI v7.1 - PROFESSIONAL EDITION (FIXED SCROLL)
-- ==============================================
print("🔧 Loading SimpleGUI v7.1 - Professional Edition with Scroll Fix...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Modern color schemes dengan lebih banyak variasi
SimpleGUI.Themes = {
    DARK = {
        Name = "Dark",
        Primary = Color3.fromRGB(30, 30, 40),
        Secondary = Color3.fromRGB(45, 45, 55),
        Accent = Color3.fromRGB(0, 122, 255),
        AccentLight = Color3.fromRGB(64, 156, 255),
        Text = Color3.fromRGB(245, 245, 255),
        TextSecondary = Color3.fromRGB(180, 180, 195),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 149, 0),
        Error = Color3.fromRGB(255, 69, 58),
        Border = Color3.fromRGB(60, 60, 70),
        Hover = Color3.fromRGB(70, 70, 85),
        Active = Color3.fromRGB(10, 132, 255),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(28, 28, 35),
        TitleBar = Color3.fromRGB(38, 38, 45),
        TabNormal = Color3.fromRGB(45, 45, 55),
        TabActive = Color3.fromRGB(0, 122, 255),
        ContentBg = Color3.fromRGB(35, 35, 42),
        Button = Color3.fromRGB(58, 58, 68),
        ButtonHover = Color3.fromRGB(70, 70, 82),
        InputBg = Color3.fromRGB(48, 48, 55),
        ToggleOff = Color3.fromRGB(72, 72, 82),
        ToggleOn = Color3.fromRGB(0, 122, 255),
        SliderTrack = Color3.fromRGB(58, 58, 68),
        SliderFill = Color3.fromRGB(0, 122, 255),
        Sidebar = Color3.fromRGB(35, 35, 42)
    },
    
    LIGHT = {
        Name = "Light",
        Primary = Color3.fromRGB(242, 242, 247),
        Secondary = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 122, 255),
        AccentLight = Color3.fromRGB(64, 156, 255),
        Text = Color3.fromRGB(28, 28, 35),
        TextSecondary = Color3.fromRGB(99, 99, 102),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 149, 0),
        Error = Color3.fromRGB(255, 69, 58),
        Border = Color3.fromRGB(209, 209, 214),
        Hover = Color3.fromRGB(229, 229, 234),
        Active = Color3.fromRGB(0, 122, 255),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(242, 242, 247),
        TitleBar = Color3.fromRGB(255, 255, 255),
        TabNormal = Color3.fromRGB(255, 255, 255),
        TabActive = Color3.fromRGB(0, 122, 255),
        ContentBg = Color3.fromRGB(255, 255, 255),
        Button = Color3.fromRGB(255, 255, 255),
        ButtonHover = Color3.fromRGB(242, 242, 247),
        InputBg = Color3.fromRGB(255, 255, 255),
        ToggleOff = Color3.fromRGB(199, 199, 204),
        ToggleOn = Color3.fromRGB(0, 122, 255),
        SliderTrack = Color3.fromRGB(209, 209, 214),
        SliderFill = Color3.fromRGB(0, 122, 255),
        Sidebar = Color3.fromRGB(250, 250, 252)
    },
    
    MIDNIGHT = {
        Name = "Midnight",
        Primary = Color3.fromRGB(16, 16, 24),
        Secondary = Color3.fromRGB(28, 28, 38),
        Accent = Color3.fromRGB(94, 92, 230),
        AccentLight = Color3.fromRGB(124, 122, 255),
        Text = Color3.fromRGB(235, 235, 255),
        TextSecondary = Color3.fromRGB(170, 170, 200),
        Success = Color3.fromRGB(48, 209, 88),
        Warning = Color3.fromRGB(255, 159, 10),
        Error = Color3.fromRGB(255, 55, 95),
        Border = Color3.fromRGB(44, 44, 58),
        Hover = Color3.fromRGB(55, 55, 75),
        Active = Color3.fromRGB(94, 92, 230),
        
        -- UI Specific
        WindowBg = Color3.fromRGB(16, 16, 24),
        TitleBar = Color3.fromRGB(22, 22, 32),
        TabNormal = Color3.fromRGB(28, 28, 38),
        TabActive = Color3.fromRGB(94, 92, 230),
        ContentBg = Color3.fromRGB(22, 22, 32),
        Button = Color3.fromRGB(38, 38, 52),
        ButtonHover = Color3.fromRGB(50, 50, 68),
        InputBg = Color3.fromRGB(30, 30, 42),
        ToggleOff = Color3.fromRGB(58, 58, 78),
        ToggleOn = Color3.fromRGB(94, 92, 230),
        SliderTrack = Color3.fromRGB(44, 44, 58),
        SliderFill = Color3.fromRGB(94, 92, 230),
        Sidebar = Color3.fromRGB(22, 22, 32)
    }
}

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI v7.1...")
    
    local self = setmetatable({}, SimpleGUI)
    
    -- Create ScreenGui dengan error handling lebih baik
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SimpleGUI_Pro_" .. math.random(1000, 9999)
    self.ScreenGui.DisplayOrder = 99999
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.IgnoreGuiInset = true
    
    -- Auto parenting dengan priority
    local success, err = pcall(function()
        self.ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        self.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self.Windows = {}
    self.CurrentTheme = "DARK"
    self.MinimizedIcons = {}
    
    print("✅ SimpleGUI v7.1 initialized!")
    return self
end

-- Theme management dengan animasi smooth
function SimpleGUI:SetTheme(themeName)
    local themeKey = themeName:upper()
    if self.Themes[themeKey] then
        self.CurrentTheme = themeKey
        print("🎨 Applied theme: " .. self.Themes[themeKey].Name)
        
        -- Update semua window dengan animasi
        for _, window in pairs(self.Windows) do
            if window.UpdateTheme then
                window:UpdateTheme(self.Themes[themeKey])
            end
        end
        
        -- Update minimized icons
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

-- Animation helper dengan easing yang lebih halus
local function tween(object, properties, duration, easingStyle)
    if not object then return nil end
    
    local tweenInfo = TweenInfo.new(
        duration or 0.25, 
        easingStyle or Enum.EasingStyle.Quint, 
        Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Create window dengan SIDEBAR TABS
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
        SidebarWidth = 180 * scale,
        Logo = opts.Logo or "B"  -- Default logo "B"
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
    
    -- Shadow effect yang lebih modern
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://13110549987"  -- Soft shadow
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 10, 10)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- Rounded corners
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 16 * scale)
    WindowCorner.Parent = MainFrame
    
    -- ===== TITLE BAR (TOP) dengan desain lebih modern =====
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 44 * scale)
    TitleBar.BackgroundColor3 = theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 16 * scale)
    TitleBarCorner.Parent = TitleBar
    
    -- Title dengan icon
    local TitleContainer = Instance.new("Frame")
    TitleContainer.Name = "TitleContainer"
    TitleContainer.Size = UDim2.new(0, 200 * scale, 1, 0)
    TitleContainer.Position = UDim2.new(0, 12 * scale, 0, 0)
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Parent = TitleBar
    
    -- Icon/Logo kecil
    local TitleIcon = Instance.new("TextLabel")
    TitleIcon.Name = "TitleIcon"
    TitleIcon.Size = UDim2.new(0, 24 * scale, 0, 24 * scale)
    TitleIcon.Position = UDim2.new(0, 0, 0.5, -12 * scale)
    TitleIcon.Text = windowData.Logo
    TitleIcon.TextColor3 = theme.Accent
    TitleIcon.BackgroundColor3 = theme.Accent
    TitleIcon.BackgroundTransparency = 0.9
    TitleIcon.TextSize = 16 * scale
    TitleIcon.Font = Enum.Font.GothamBold
    TitleIcon.Parent = TitleContainer
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8 * scale)
    IconCorner.Parent = TitleIcon
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -32 * scale, 1, 0)
    TitleLabel.Position = UDim2.new(0, 32 * scale, 0, 0)
    TitleLabel.Text = windowData.Name
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16 * scale
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleContainer
    
    -- Control Buttons dengan desain lebih elegan
    local buttonSize = 30 * scale
    
    -- Theme Button
    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Name = "ThemeButton"
    ThemeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    ThemeButton.Position = UDim2.new(1, -buttonSize * 3 - 20 * scale, 0.5, -buttonSize/2)
    ThemeButton.Text = "🎨"
    ThemeButton.TextColor3 = theme.TextSecondary
    ThemeButton.BackgroundColor3 = theme.Button
    ThemeButton.BackgroundTransparency = 0
    ThemeButton.TextSize = 16 * scale
    ThemeButton.Font = Enum.Font.Gotham
    ThemeButton.Visible = false  -- Default disembunyikan, bisa diaktifkan lewat opsi
    ThemeButton.Parent = TitleBar
    
    local ThemeButtonCorner = Instance.new("UICorner")
    ThemeButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
    ThemeButtonCorner.Parent = ThemeButton
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    MinimizeButton.Position = UDim2.new(1, -buttonSize * 2 - 10 * scale, 0.5, -buttonSize/2)
    MinimizeButton.Text = "—"
    MinimizeButton.TextColor3 = theme.TextSecondary
    MinimizeButton.BackgroundColor3 = theme.Button
    MinimizeButton.BackgroundTransparency = 0
    MinimizeButton.TextSize = 18 * scale
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Parent = TitleBar
    
    local MinimizeButtonCorner = Instance.new("UICorner")
    MinimizeButtonCorner.CornerRadius = UDim.new(0, 8 * scale)
    MinimizeButtonCorner.Parent = MinimizeButton
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    CloseButton.Position = UDim2.new(1, -buttonSize - 5 * scale, 0.5, -buttonSize/2)
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
    
    -- ===== SIDEBAR (LEFT) - SEKARANG MENGGUNAKAN SCROLLINGFRAME =====
    local Sidebar = Instance.new("ScrollingFrame")  -- Diubah dari Frame ke ScrollingFrame
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, windowData.SidebarWidth, 1, -44 * scale)
    Sidebar.Position = UDim2.new(0, 0, 0, 44 * scale)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.BackgroundTransparency = 0
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = true
    Sidebar.ScrollBarThickness = 4 * scale  -- Scrollbar tipis
    Sidebar.ScrollBarImageColor3 = theme.Accent  -- Warna scrollbar sesuai tema
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y  -- Auto adjust canvas size
    Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y  -- Scroll vertical saja
    Sidebar.ElasticBehavior = Enum.ElasticBehavior.Always  -- Elastic effect saat scroll
    Sidebar.Parent = MainFrame
    
    -- Sidebar Header (tidak ikut scroll)
    local SidebarHeader = Instance.new("Frame")
    SidebarHeader.Name = "SidebarHeader"
    SidebarHeader.Size = UDim2.new(1, 0, 0, 30 * scale)
    SidebarHeader.BackgroundTransparency = 1
    SidebarHeader.Parent = Sidebar
    
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Name = "HeaderLabel"
    HeaderLabel.Size = UDim2.new(1, -20, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 10, 0, 5)
    HeaderLabel.Text = "MENU"
    HeaderLabel.TextColor3 = theme.TextSecondary
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.TextSize = 12 * scale
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Parent = SidebarHeader
    
    -- ===== LAYOUT UNTUK SIDEBAR =====
    -- Container untuk tab buttons (biar bisa discroll)
    local SidebarContainer = Instance.new("Frame")
    SidebarContainer.Name = "SidebarContainer"
    SidebarContainer.Size = UDim2.new(1, 0, 0, 0)
    SidebarContainer.BackgroundTransparency = 1
    SidebarContainer.Parent = Sidebar
    
    -- Layout untuk tab buttons
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 6 * scale)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = SidebarContainer
    
    -- Padding untuk container (YANG DIPERBAIKI)
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 40 * scale)  -- Di bawah header
    SidebarPadding.PaddingLeft = UDim.new(0, 10 * scale)
    SidebarPadding.PaddingRight = UDim.new(0, 10 * scale)  -- ✅ FIXED: scroll.scale -> scale
    SidebarPadding.PaddingBottom = UDim.new(0, 10 * scale)
    SidebarPadding.Parent = SidebarContainer
    
    -- Update canvas size otomatis
    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarContainer.Size = UDim2.new(1, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 50 * scale)
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 50 * scale)
    end)
    
    -- ===== CONTENT FRAME (RIGHT) =====
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -windowData.SidebarWidth, 1, -44 * scale)
    ContentFrame.Position = UDim2.new(0, windowData.SidebarWidth, 0, 44 * scale)
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
    ContentCorner.CornerRadius = UDim.new(0, 16 * scale)
    ContentCorner.Parent = ContentFrame
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = ContentFrame
    
    -- Content layout
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
    
    -- Update canvas size untuk content
    ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.Size = UDim2.new(1, 0, 0, ContentList.AbsoluteContentSize.Y + 36 * scale)
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 36 * scale)
    end)
    
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
            TitleIcon.TextColor3 = theme.Accent
            TitleIcon.BackgroundColor3 = theme.Accent
            Sidebar.BackgroundColor3 = theme.Sidebar
            Sidebar.ScrollBarImageColor3 = theme.Accent
            HeaderLabel.TextColor3 = theme.TextSecondary
            ContentFrame.BackgroundColor3 = theme.ContentBg
            ContentFrame.ScrollBarImageColor3 = theme.Accent
            
            ThemeButton.BackgroundColor3 = theme.Button
            ThemeButton.TextColor3 = theme.TextSecondary
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
        
        -- Tab Button (di dalam SidebarContainer)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(1, -20 * scale, 0, 44 * scale)
        TabButton.Text = icon .. "  " .. tabName
        TabButton.TextColor3 = theme.Text
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = 14 * scale
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        TabButton.LayoutOrder = #self.Tabs + 1
        TabButton.Parent = SidebarContainer  -- Parent ke SidebarContainer bukan Sidebar langsung
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 10 * scale)
        TabButtonCorner.Parent = TabButton
        
        -- Tab Content (di dalam ContentContainer)
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
        
        -- Update ukuran TabContent berdasarkan isinya
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.Size = UDim2.new(1, 0, 0, TabLayout.AbsoluteContentSize.Y)
        end)
        
        -- Tab click handler dengan animasi
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
        
        -- Button hover effects yang lebih smooth
        local function setupButtonHover(button, hoverColor, normalColor)
            if not button or not button:IsA("TextButton") then return end
            
            button.MouseEnter:Connect(function()
                if not isMobile and not button.Active then
                    tween(button, {BackgroundColor3 = hoverColor or theme.ButtonHover}, 0.15)
                end
            end)
            
            button.MouseLeave:Connect(function()
                if not isMobile and not button.Active then
                    tween(button, {BackgroundColor3 = normalColor or theme.Button}, 0.15)
                end
            end)
        end
        
        setupButtonHover(TabButton, theme.Hover, theme.TabNormal)
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
                Button.Size = UDim2.new(0.9, 0, 0, 42 * scale)
                Button.Text = opts.Text or Button.Name
                Button.TextColor3 = theme.Text
                Button.BackgroundColor3 = theme.Button
                Button.BackgroundTransparency = 0
                Button.TextSize = 14 * scale
                Button.Font = Enum.Font.Gotham
                Button.AutoButtonColor = false
                Button.LayoutOrder = #self.Elements + 1
                Button.Parent = TabContent
                
                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 10 * scale)
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
                Label.Size = UDim2.new(0.9, 0, 0, 30 * scale)
                Label.Text = opts.Text or Label.Name
                Label.TextColor3 = opts.Color or theme.Text
                Label.BackgroundTransparency = 1
                Label.TextSize = opts.Size or 14 * scale
                Label.Font = opts.Bold and Enum.Font.GothamBold or Enum.Font.Gotham
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
                Padding.PaddingLeft = UDim.new(0, 14 * scale)
                Padding.PaddingRight = UDim.new(0, 14 * scale)
                Padding.Parent = InputBox
                
                InputBox.Focused:Connect(function()
                    tween(InputBox, {BackgroundColor3 = theme.Hover}, 0.15)
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    tween(InputBox, {BackgroundColor3 = theme.InputBg}, 0.15)
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
                ToggleFrame.Size = UDim2.new(0.9, 0, 0, 42 * scale)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.LayoutOrder = #self.Elements + 1
                ToggleFrame.Parent = TabContent
                
                -- Toggle container
                local ToggleContainer = Instance.new("TextButton")
                ToggleContainer.Name = "ToggleContainer"
                ToggleContainer.Size = UDim2.new(0, 52 * scale, 0, 28 * scale)
                ToggleContainer.Position = UDim2.new(0, 0, 0.5, -14 * scale)
                ToggleContainer.Text = ""
                ToggleContainer.BackgroundColor3 = theme.ToggleOff
                ToggleContainer.BackgroundTransparency = 0
                ToggleContainer.BorderSizePixel = 0
                ToggleContainer.AutoButtonColor = false
                ToggleContainer.Parent = ToggleFrame
                
                local ContainerCorner = Instance.new("UICorner")
                ContainerCorner.CornerRadius = UDim.new(0, 14 * scale)
                ContainerCorner.Parent = ToggleContainer
                
                -- Toggle circle
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Size = UDim2.new(0, 22 * scale, 0, 22 * scale)
                ToggleCircle.Position = UDim2.new(0, 3 * scale, 0.5, -11 * scale)
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
                ToggleLabel.Size = UDim2.new(1, -62 * scale, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 62 * scale, 0, 0)
                ToggleLabel.Text = opts.Text or opts.Name or "Toggle"
                ToggleLabel.TextColor3 = theme.Text
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.TextSize = 14 * scale
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.AutoButtonColor = false
                ToggleLabel.Parent = ToggleFrame
                
                -- Toggle state
                local isToggled = opts.CurrentValue or false
                
                local function updateToggle()
                    if isToggled then
                        tween(ToggleContainer, {BackgroundColor3 = theme.ToggleOn}, 0.2, Enum.EasingStyle.Back)
                        tween(ToggleCircle, {Position = UDim2.new(1, -25 * scale, 0.5, -11 * scale)}, 0.2)
                    else
                        tween(ToggleContainer, {BackgroundColor3 = theme.ToggleOff}, 0.2, Enum.EasingStyle.Back)
                        tween(ToggleCircle, {Position = UDim2.new(0, 3 * scale, 0.5, -11 * scale)}, 0.2)
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
            end,
            
            CreateSlider = function(self, options)
                local opts = options or {}
                local scale = windowData.Scale
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = opts.Name or "Slider_" .. #self.Elements + 1
                SliderFrame.Size = UDim2.new(0.9, 0, 0, 70 * scale)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.LayoutOrder = #self.Elements + 1
                SliderFrame.Parent = TabContent
                
                -- Label
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Size = UDim2.new(1, 0, 0, 22 * scale)
                SliderLabel.Text = opts.Name or "Slider"
                SliderLabel.TextColor3 = theme.Text
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.TextSize = 14 * scale
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                -- Value display
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "ValueLabel"
                ValueLabel.Size = UDim2.new(0, 60 * scale, 0, 22 * scale)
                ValueLabel.Position = UDim2.new(1, -60 * scale, 0, 0)
                ValueLabel.Text = tostring(opts.CurrentValue or (opts.Range and opts.Range[1]) or 50)
                ValueLabel.TextColor3 = theme.Accent
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.TextSize = 14 * scale
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame
                
                -- Slider track
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Name = "SliderTrack"
                SliderTrack.Size = UDim2.new(1, 0, 0, 24 * scale)
                SliderTrack.Position = UDim2.new(0, 0, 0, 30 * scale)
                SliderTrack.BackgroundColor3 = theme.SliderTrack
                SliderTrack.BackgroundTransparency = 0
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Parent = SliderFrame
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 12 * scale)
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
                FillCorner.CornerRadius = UDim.new(0, 12 * scale)
                FillCorner.Parent = SliderFill
                
                -- Slider thumb
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
                
                local function updateSliderPosition(value)
                    currentValue = math.clamp(
                        math.floor((value - range[1]) / increment) * increment + range[1],
                        range[1],
                        range[2]
                    )
                    
                    local percentage = (currentValue - range[1]) / (range[2] - range[1])
                    local fillWidth = math.clamp(percentage, 0, 1)
                    
                    SliderFill.Size = UDim2.new(fillWidth, 0, 1, 0)
                    SliderThumb.Position = UDim2.new(fillWidth, -14 * scale, 0.5, -14 * scale)
                    ValueLabel.Text = tostring(currentValue)
                    
                    if opts.Callback then
                        pcall(opts.Callback, currentValue)
                    end
                end
                
                updateSliderPosition(currentValue)
                
                SliderThumb.MouseButton1Down:Connect(function()
                    isDragging = true
                    tween(SliderThumb, {Size = UDim2.new(0, 32 * scale, 0, 32 * scale)}, 0.1)
                end)
                
                UserInputService.InputChanged:Connect(function(input)
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
                        isDragging = false
                        tween(SliderThumb, {Size = UDim2.new(0, 28 * scale, 0, 28 * scale)}, 0.1)
                    end
                end)
                
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
                
                return {
                    Frame = SliderFrame,
                    GetValue = function() return currentValue end,
                    SetValue = function(value)
                        updateSliderPosition(value)
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
    local originalCornerRadius = WindowCorner.CornerRadius
    local isMinimized = false
    
    -- Buat minimized icon (logo B)
    local MinimizedIcon = Instance.new("TextButton")
    MinimizedIcon.Name = "MinimizedIcon_" .. windowData.Name
    MinimizedIcon.Size = UDim2.new(0, 40 * scale, 0, 40 * scale)
    MinimizedIcon.Position = UDim2.new(0, 20, 0, 20)
    MinimizedIcon.Text = windowData.Logo
    MinimizedIcon.TextColor3 = theme.Text
    MinimizedIcon.BackgroundColor3 = theme.Accent
    MinimizedIcon.BackgroundTransparency = 0
    MinimizedIcon.TextSize = 20 * scale
    MinimizedIcon.Font = Enum.Font.GothamBold
    MinimizedIcon.Visible = false
    MinimizedIcon.Parent = self.ScreenGui
    
    -- Shadow untuk icon
    local IconShadow = Instance.new("ImageLabel")
    IconShadow.Name = "IconShadow"
    IconShadow.Size = UDim2.new(1, 8, 1, 8)
    IconShadow.Position = UDim2.new(0, -4, 0, -4)
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
    
    -- Simpan icon untuk update theme nanti
    self.MinimizedIcons[windowData.Name] = {
        Icon = MinimizedIcon,
        UpdateTheme = function(self, newTheme)
            MinimizedIcon.BackgroundColor3 = newTheme.Accent
            MinimizedIcon.TextColor3 = newTheme.Text
        end
    }
    
    -- Fungsi minimize/restore
    local function setMinimized(minimize)
        isMinimized = minimize
        windowObj.IsMinimized = minimize
        
        if minimize then
            -- Simpan posisi window sebelum minimize
            local windowPos = MainFrame.Position
            
            -- Animasi minimize
            tween(MainFrame, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = windowPos
            }, 0.2)
            
            task.wait(0.15)
            MainFrame.Visible = false
            
            -- Tampilkan icon di posisi window
            MinimizedIcon.Position = UDim2.new(
                windowPos.X.Scale,
                windowPos.X.Offset,
                windowPos.Y.Scale,
                windowPos.Y.Offset
            )
            MinimizedIcon.Visible = true
            
            -- Animasi icon muncul
            MinimizedIcon.Size = UDim2.new(0, 0, 0, 0)
            tween(MinimizedIcon, {Size = UDim2.new(0, 40 * scale, 0, 40 * scale)}, 0.2, Enum.EasingStyle.Back)
            
            MinimizeButton.Text = "⬤"  -- Ganti icon jadi lingkaran (untuk restore)
        else
            -- Sembunyikan icon
            tween(MinimizedIcon, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
            task.wait(0.1)
            MinimizedIcon.Visible = false
            
            -- Tampilkan window
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            tween(MainFrame, {Size = originalSize}, 0.2, Enum.EasingStyle.Back)
            tween(MainFrame, {Position = originalSize and MainFrame.Position or UDim2.new(0.5, -350 * scale, 0.5, -250 * scale)}, 0.2)
            
            -- Kembalikan corner radius
            WindowCorner.CornerRadius = originalCornerRadius
            
            MinimizeButton.Text = "—"
        end
    end
    
    MinimizeButton.MouseButton1Click:Connect(function()
        setMinimized(not isMinimized)
    end)
    
    -- Klik icon untuk restore
    MinimizedIcon.MouseButton1Click:Connect(function()
        setMinimized(false)
    end)
    
    -- Drag untuk icon
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
    
    -- Create theme tab if requested
    if windowData.ShowThemeTab then
        local ThemeTab = windowObj:CreateTab({Name = "Theme", Icon = "🎨"})
        ThemeTab:CreateLabel({Text = "Color Theme", Size = 16, Bold = true, Alignment = Enum.TextXAlignment.Center})
        ThemeTab:CreateButton({Text = "🌙 Dark Mode", Callback = function() self:SetTheme("DARK") end})
        ThemeTab:CreateButton({Text = "☀️ Light Mode", Callback = function() self:SetTheme("LIGHT") end})
        ThemeTab:CreateButton({Text = "🌃 Midnight Mode", Callback = function() self:SetTheme("MIDNIGHT") end})
    end
    
    print("✅ Created professional window: " .. windowData.Name)
    return windowObj
end

print("🎉 SimpleGUI v7.1 - Professional Edition loaded!")
return SimpleGUI