-- ==============================================
-- 🎨 SIMPLEGUI v5.1 - SIMPLIFIED THEME EDITOR WITH RESPONSIVE LAYOUT
-- ==============================================
print("🔧 Loading SimpleGUI v5.1 - Simplified Theme Editor with Responsive Layout...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Responsive layout utility functions
function SimpleGUI:GetScreenSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    return {
        Width = viewportSize.X,
        Height = viewportSize.Y
    }
end

function SimpleGUI:GetResponsiveScale()
    local screen = self:GetScreenSize()
    local baseWidth = 1920  -- Base resolution untuk desktop
    local baseHeight = 1080
    
    -- Jika mobile/touch device
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        baseWidth = 1080
        baseHeight = 1920
    end
    
    local scaleX = screen.Width / baseWidth
    local scaleY = screen.Height / baseHeight
    
    return math.min(scaleX, scaleY) * 0.85  -- Scaling factor
end

function SimpleGUI:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

function SimpleGUI:IsTablet()
    local screen = self:GetScreenSize()
    local aspectRatio = screen.Width / screen.Height
    return aspectRatio >= 0.6 and aspectRatio <= 1.7 and UserInputService.TouchEnabled
end

function SimpleGUI.new()
    print("🚀 Initializing SimpleGUI v5.1 with Responsive Layout...")
    
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
    
    -- THEMES (ditambahkan PURPLE dan GREEN)
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
        },
        
        PURPLE = {
            Name = "Purple",
            WindowBg = Color3.fromRGB(45, 30, 60),
            WindowBorder = Color3.fromRGB(100, 70, 140),
            TitleBarBg = Color3.fromRGB(70, 50, 90),
            TitleTextColor = Color3.fromRGB(255, 220, 255),
            ButtonNormal = Color3.fromRGB(90, 60, 120),
            ButtonHover = Color3.fromRGB(120, 80, 160),
            ButtonActive = Color3.fromRGB(180, 120, 220),
            ToggleOff = Color3.fromRGB(80, 50, 110),
            ToggleOn = Color3.fromRGB(200, 140, 255),
            SliderTrack = Color3.fromRGB(80, 50, 110),
            SliderFill = Color3.fromRGB(200, 140, 255),
            InputBg = Color3.fromRGB(70, 45, 95),
            InputFocused = Color3.fromRGB(90, 65, 115),
            TabBg = Color3.fromRGB(60, 40, 80),
            TabNormal = Color3.fromRGB(85, 55, 115),
            TabActive = Color3.fromRGB(180, 120, 220),
            ContentBg = Color3.fromRGB(50, 35, 70)
        },
        
        GREEN = {
            Name = "Green",
            WindowBg = Color3.fromRGB(30, 45, 30),
            WindowBorder = Color3.fromRGB(70, 120, 70),
            TitleBarBg = Color3.fromRGB(40, 65, 40),
            TitleTextColor = Color3.fromRGB(220, 255, 220),
            ButtonNormal = Color3.fromRGB(50, 90, 50),
            ButtonHover = Color3.fromRGB(70, 110, 70),
            ButtonActive = Color3.fromRGB(100, 200, 100),
            ToggleOff = Color3.fromRGB(45, 80, 45),
            ToggleOn = Color3.fromRGB(80, 200, 80),
            SliderTrack = Color3.fromRGB(45, 80, 45),
            SliderFill = Color3.fromRGB(80, 200, 80),
            InputBg = Color3.fromRGB(40, 70, 40),
            InputFocused = Color3.fromRGB(60, 90, 60),
            TabBg = Color3.fromRGB(35, 55, 35),
            TabNormal = Color3.fromRGB(55, 85, 55),
            TabActive = Color3.fromRGB(100, 200, 100),
            ContentBg = Color3.fromRGB(25, 40, 25)
        }
    }
    
    self.DefaultTheme = self.Themes[self.CurrentTheme]
    
    print("✅ SimpleGUI v5.1 with Responsive Layout initialized!")
    return self
end

-- SIMPLIFIED THEME MANAGEMENT
function SimpleGUI:SetTheme(themeName)
    if self.Themes[themeName:upper()] then
        self.CurrentTheme = themeName:upper()
        self.DefaultTheme = self.Themes[self.CurrentTheme]
        print("🎨 Applied theme: " .. self.DefaultTheme.Name)
        
        -- Update semua window dan elemennya
        for windowName, windowObj in pairs(self.Windows) do
            if windowObj.UpdateWindowTheme then
                windowObj:UpdateWindowTheme(self.DefaultTheme)
            end
            if windowObj.UpdateAllElementsTheme then
                windowObj:UpdateAllElementsTheme(self.DefaultTheme)
            end
        end
    end
end

function SimpleGUI:GetCurrentTheme()
    return self.CurrentTheme
end

-- THEME SAVE/LOAD FUNCTIONS
function SimpleGUI:SaveThemeToFile(themeName, fileName)
    fileName = fileName or "SimpleGUI_Theme.json"
    local theme = self.Themes[themeName:upper()]
    
    if theme then
        local data = {}
        for key, value in pairs(theme) do
            if typeof(value) == "Color3" then
                data[key] = {value.R, value.G, value.B}
            else
                data[key] = value
            end
        end
        
        -- Simpan menggunakan plugin atau DataStore (sesuaikan dengan environment)
        print("💾 Theme saved: " .. theme.Name)
        return data
    end
end

function SimpleGUI:LoadThemeFromFile(fileName)
    -- Implementasi load theme dari file
    print("📂 Load theme from: " .. fileName)
    -- Ini adalah placeholder, implementasi sebenarnya tergantung environment
    return nil
end

-- ===== SIMPLIFIED WINDOW CREATION WITH RESPONSIVE LAYOUT =====
function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local isMobile = self:IsMobile()
    local isTablet = self:IsTablet()
    local responsiveScale = self:GetResponsiveScale()
    
    -- Responsive default sizes
    local defaultSize, defaultPosition
    
    if isMobile then
        -- Mobile: full width, height 70%
        defaultSize = UDim2.new(1, -20, 0.7, 0)
        defaultPosition = UDim2.new(0.5, 0, 0.15, 0)
    elseif isTablet then
        -- Tablet: 90% width, 80% height
        defaultSize = UDim2.new(0.9, 0, 0.8, 0)
        defaultPosition = UDim2.new(0.5, 0, 0.1, 0)
    else
        -- Desktop: fixed size dengan scaling
        local scaledWidth = 500 * responsiveScale
        local scaledHeight = 400 * responsiveScale
        defaultSize = UDim2.new(0, scaledWidth, 0, scaledHeight)
        defaultPosition = UDim2.new(0.5, -scaledWidth/2, 0.5, -scaledHeight/2)
    end
    
    local windowData = {
        Name = opts.Name or "Window",
        Size = opts.Size or defaultSize,
        Position = opts.Position or defaultPosition,
        Minimizable = opts.Minimizable ~= false,
        ShowThemeTab = opts.ShowThemeTab or false,
        IsMobile = isMobile,
        IsTablet = isTablet,
        ResponsiveScale = responsiveScale
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
    TitleBar.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
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
    TitleLabel.TextSize = isMobile and 13 or 14
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- THEME BUTTON (hanya muncul jika ShowThemeTab true)
    local ThemeButton = Instance.new("TextButton")
    ThemeButton.Name = "ThemeButton"
    ThemeButton.Size = UDim2.new(0, isMobile and 25 : 25, 0, isMobile and 25 : 25)
    ThemeButton.Position = UDim2.new(1, isMobile and -85 : -90, 0.5, isMobile and -12.5 : -12.5)
    ThemeButton.Text = "🎨"
    ThemeButton.TextColor3 = Color3.fromRGB(255, 255, 200)
    ThemeButton.BackgroundColor3 = theme.ButtonNormal
    ThemeButton.BackgroundTransparency = 0
    ThemeButton.TextSize = isMobile and 11 : 12
    ThemeButton.Font = Enum.Font.SourceSans
    ThemeButton.Visible = windowData.ShowThemeTab
    ThemeButton.Parent = TitleBar
    
    -- MINIMIZE BUTTON
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, isMobile and 25 : 25, 0, isMobile and 25 : 25)
    MinimizeButton.Position = UDim2.new(1, isMobile and -55 : -60, 0.5, isMobile and -12.5 : -12.5)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    MinimizeButton.BackgroundColor3 = theme.ButtonNormal
    MinimizeButton.BackgroundTransparency = 0
    MinimizeButton.TextSize = isMobile and 14 : 16
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.Visible = windowData.Minimizable
    MinimizeButton.Parent = TitleBar
    
    -- CLOSE BUTTON
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, isMobile and 25 : 25, 0, isMobile and 25 : 25)
    CloseButton.Position = UDim2.new(1, isMobile and -25 : -30, 0.5, isMobile and -12.5 : -12.5)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 150, 150)
    CloseButton.BackgroundColor3 = theme.ButtonNormal
    CloseButton.BackgroundTransparency = 0
    CloseButton.TextSize = isMobile and 12 : 14
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Parent = TitleBar
    
    -- TAB CONTAINER
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, isMobile and 40 : 35)
    TabContainer.Position = UDim2.new(0, 0, 0, isMobile and 35 : 30)
    TabContainer.BackgroundColor3 = theme.TabBg
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    -- CONTENT FRAME
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -(isMobile and 75 : 65))
    ContentFrame.Position = UDim2.new(0, 0, 0, isMobile and 75 : 65)
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
            if ThemeButton.Visible then
                ThemeButton.Size = UDim2.new(0, 20, 0, 20)
                ThemeButton.Position = UDim2.new(1, -75, 0.5, -10)
            end
        else
            MainFrame.Size = originalSize
            TitleBar.Size = UDim2.new(1, 0, 0, isMobile and 35 or 30)
            TitleLabel.TextSize = isMobile and 13 or 14
            TitleLabel.Text = windowData.Name
            TabContainer.Visible = true
            ContentFrame.Visible = true
            MinimizeButton.Text = "_"
            MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            MinimizeButton.Size = UDim2.new(0, isMobile and 25 : 25, 0, isMobile and 25 : 25)
            MinimizeButton.Position = UDim2.new(1, isMobile and -55 : -60, 0.5, isMobile and -12.5 : -12.5)
            CloseButton.Size = UDim2.new(0, isMobile and 25 : 25, 0, isMobile and 25 : 25)
            CloseButton.Position = UDim2.new(1, isMobile and -25 : -30, 0.5, isMobile and -12.5 : -12.5)
            if ThemeButton.Visible then
                ThemeButton.Size = UDim2.new(0, isMobile and 25 : 25, 0, isMobile and 25 : 25)
                ThemeButton.Position = UDim2.new(1, isMobile and -85 : -90, 0.5, isMobile and -12.5 : -12.5)
            end
        end
    end
    
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        updateMinimizeState()
    end)
    
    -- BUTTON HOVER
    local function setupButtonHover(button, normalColor, hoverColor)
        button.MouseEnter:Connect(function()
            if not isMobile then
                button.BackgroundColor3 = hoverColor
            end
        end)
        button.MouseLeave:Connect(function()
            if not isMobile then
                button.BackgroundColor3 = normalColor
            end
        end)
    end
    
    setupButtonHover(MinimizeButton, theme.ButtonNormal, theme.ButtonHover)
    setupButtonHover(CloseButton, theme.ButtonNormal, Color3.fromRGB(100, 80, 80))
    setupButtonHover(ThemeButton, theme.ButtonNormal, theme.ButtonHover)
    
    -- THEME BUTTON CLICK
    ThemeButton.MouseButton1Click:Connect(function()
        if windowData.ShowThemeTab then
            -- Cari theme tab dan toggle visibility
            for tabName, tabData in pairs(windowObj.Tabs) do
                if string.find(tabName:lower(), "theme") or string.find(tabName:lower(), "🎨") then
                    tabData.Button.Visible = not tabData.Button.Visible
                    break
                end
            end
        end
    end)
    
    -- CLOSE
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    -- DRAGGABLE
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or (isMobile and input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            TitleBar.BackgroundColor3 = theme.ButtonHover
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TitleBar.BackgroundColor3 = theme.TitleBarBg
        end
    end)
    
    -- RESPONSIVE TOUCH SUPPORT FOR MOBILE
    if isMobile then
        -- Mobile-specific: larger hit areas for touch
        local hitExtend = 10
        
        local function enlargeForTouch(element)
            local currentSize = element.Size
            element.Size = UDim2.new(
                currentSize.X.Scale, 
                currentSize.X.Offset + hitExtend,
                currentSize.Y.Scale,
                currentSize.Y.Offset + hitExtend
            )
        end
        
        -- Enlarge buttons for touch
        for _, element in pairs({MinimizeButton, CloseButton, ThemeButton}) do
            if element.Visible then
                enlargeForTouch(element)
            end
        end
        
        -- Mobile: add swipe to close gesture
        local swipeStart, swipeEnd
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                swipeStart = input.Position
            end
        end)
        
        TitleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch and swipeStart then
                swipeEnd = input.Position
                local swipeDistance = (swipeEnd - swipeStart).Magnitude
                
                -- Swipe down to minimize
                if (swipeEnd.Y - swipeStart.Y) > 50 and swipeDistance > 100 then
                    isMinimized = true
                    updateMinimizeState()
                end
                
                -- Swipe up to restore
                if (swipeStart.Y - swipeEnd.Y) > 50 and swipeDistance > 100 then
                    isMinimized = false
                    updateMinimizeState()
                end
            end
        end)
    end
    
    -- LAYOUTS
    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabList.VerticalAlignment = Enum.VerticalAlignment.Center
    TabList.Padding = UDim.new(0, 5 * responsiveScale)
    TabList.Parent = TabContainer
    
    local ContentList = Instance.new("UIListLayout")
    ContentList.Padding = UDim.new(0, 8 * responsiveScale)
    ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Parent = ContentFrame
    
    -- Responsive padding untuk mobile
    if isMobile then
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.Parent = ContentFrame
    end
    
    -- WINDOW OBJECT
    local windowObj = {
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        ThemeButton = ThemeButton,
        MinimizeButton = MinimizeButton,
        CloseButton = CloseButton,
        TabContainer = TabContainer,
        ContentFrame = ContentFrame,
        Tabs = {},
        ActiveTab = nil,
        WindowData = windowData,
        
        UpdateWindowTheme = function(self, newTheme)
            MainFrame.BackgroundColor3 = newTheme.WindowBg
            MainFrame.BorderColor3 = newTheme.WindowBorder
            TitleBar.BackgroundColor3 = newTheme.TitleBarBg
            TitleLabel.TextColor3 = newTheme.TitleTextColor
            TabContainer.BackgroundColor3 = newTheme.TabBg
            ContentFrame.BackgroundColor3 = newTheme.ContentBg
            MinimizeButton.BackgroundColor3 = newTheme.ButtonNormal
            CloseButton.BackgroundColor3 = newTheme.ButtonNormal
            ThemeButton.BackgroundColor3 = newTheme.ButtonNormal
            
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
        
        UpdateAllElementsTheme = function(self, newTheme)
            -- Update semua elemen UI di semua tab
            for tabName, tabData in pairs(self.Tabs) do
                for _, element in ipairs(tabData.Elements) do
                    -- Update berdasarkan tipe elemen
                    if element:IsA("TextButton") and not string.find(element.Name, "Tab") then
                        element.BackgroundColor3 = newTheme.ButtonNormal
                        element.TextColor3 = newTheme.TitleTextColor
                    elseif element:IsA("TextLabel") then
                        element.TextColor3 = newTheme.TitleTextColor
                    elseif element:IsA("TextBox") then
                        element.BackgroundColor3 = newTheme.InputBg
                        element.TextColor3 = newTheme.TitleTextColor
                    elseif element:IsA("Frame") then
                        -- Handle custom elements (toggle, slider, etc)
                        local toggleBtn = element:FindFirstChild("Toggle")
                        if toggleBtn then
                            toggleBtn.BackgroundColor3 = newTheme.ToggleOff
                            local label = element:FindFirstChild("Label")
                            if label then
                                label.TextColor3 = newTheme.TitleTextColor
                            end
                        end
                        
                        local sliderTrack = element:FindFirstChild("Track")
                        if sliderTrack then
                            sliderTrack.BackgroundColor3 = newTheme.SliderTrack
                            local fill = sliderTrack:FindFirstChild("Fill")
                            if fill then
                                fill.BackgroundColor3 = newTheme.SliderFill
                            end
                            local label = element:FindFirstChild("Label")
                            if label then
                                label.TextColor3 = newTheme.TitleTextColor
                            end
                        end
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
    
    -- Responsive resize handler
    local function setupResponsiveResize()
        local originalSize = windowData.Size
        
        -- Function untuk update window size berdasarkan screen size
        local function updateWindowSize()
            local screen = self:GetScreenSize()
            
            if windowData.IsMobile then
                -- Mobile: always full width, 70% height
                MainFrame.Size = UDim2.new(1, -20, 0.7, 0)
            elseif windowData.IsTablet then
                -- Tablet: maintain aspect ratio
                local maxWidth = screen.Width * 0.9
                local maxHeight = screen.Height * 0.8
                MainFrame.Size = UDim2.new(0, math.min(originalSize.X.Offset, maxWidth), 
                                            0, math.min(originalSize.Y.Offset, maxHeight))
            else
                -- Desktop: scale dengan responsive factor
                local scale = self:GetResponsiveScale()
                MainFrame.Size = UDim2.new(0, originalSize.X.Offset * scale,
                                            0, originalSize.Y.Offset * scale)
            end
        end
        
        -- Connect to viewport size changes
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize)
        
        -- Initial update
        updateWindowSize()
    end
    
    -- Setup responsive resize jika mobile atau tablet
    if windowData.IsMobile or windowData.IsTablet then
        setupResponsiveResize()
    end
    
    self.Windows[windowData.Name] = windowObj
    
    -- ===== SIMPLIFIED TAB CREATION WITH RESPONSIVE ELEMENTS =====
    function windowObj:CreateTab(options)
        local tabOptions = type(options) == "string" and {Name = options} or (options or {})
        local tabName = tabOptions.Name or "Tab_" .. (#self.Tabs + 1)
        
        -- Responsive tab button size
        local tabWidth = self.WindowData.IsMobile and 80 or 90
        local tabHeight = self.WindowData.IsMobile and 24 or 28
        local tabTextSize = self.WindowData.IsMobile and 10 or 12
        
        -- TAB BUTTON
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Button"
        TabButton.Size = UDim2.new(0, tabWidth * self.WindowData.ResponsiveScale, 0, tabHeight * self.WindowData.ResponsiveScale)
        TabButton.Text = tabName
        TabButton.TextColor3 = theme.TitleTextColor
        TabButton.BackgroundColor3 = theme.TabNormal
        TabButton.BackgroundTransparency = 0
        TabButton.TextSize = tabTextSize
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
        TabContent.ScrollBarThickness = self.WindowData.IsMobile and 8 or 4
        TabContent.ScrollBarImageColor3 = theme.SliderFill
        TabContent.Visible = false
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.ScrollingDirection = self.WindowData.IsMobile and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.XY
        TabContent.Parent = self.ContentFrame
        
        -- TAB LAYOUT
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 8 * self.WindowData.ResponsiveScale)
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
        
        -- TAB BUILDER METHODS (RESPONSIVE VERSION)
        local tabBuilder = {}
        
        function tabBuilder:CreateButton(options)
            local opts = options or {}
            local buttonHeight = self.WindowData.IsMobile and 32 or 36
            local textSize = self.WindowData.IsMobile and 12 or 13
            
            local Button = Instance.new("TextButton")
            Button.Name = opts.Name or "Button_" .. #tabObj.Elements + 1
            Button.Size = UDim2.new(0.9, 0, 0, buttonHeight * self.WindowData.ResponsiveScale)
            Button.Text = opts.Text or Button.Name
            Button.TextColor3 = theme.TitleTextColor
            Button.BackgroundColor3 = theme.ButtonNormal
            Button.BackgroundTransparency = 0
            Button.TextSize = textSize
            Button.Font = Enum.Font.SourceSans
            Button.AutoButtonColor = true
            Button.LayoutOrder = #tabObj.Elements + 1
            Button.Parent = TabContent
            
            setupButtonHover(Button, theme.ButtonNormal, theme.ButtonHover)
            
            if opts.Callback then
                Button.MouseButton1Click:Connect(function()
                    pcall(opts.Callback)
                end
                
                -- Touch support for mobile
                if self.WindowData.IsMobile then
                    local touchCount = 0
                    local lastTouch = 0
                    
                    Button.TouchTap:Connect(function()
                        local now = tick()
                        if now - lastTouch > 0.5 then
                            pcall(opts.Callback)
                        end
                        lastTouch = now
                    end)
                end
            end
            
            table.insert(tabObj.Elements, Button)
            return Button
        end
        
        function tabBuilder:CreateLabel(options)
            local opts = options or {}
            local labelHeight = self.WindowData.IsMobile and 22 or 26
            local textSize = self.WindowData.IsMobile and 12 or 13
            
            local Label = Instance.new("TextLabel")
            Label.Name = opts.Name or "Label_" .. #tabObj.Elements + 1
            Label.Size = UDim2.new(0.9, 0, 0, labelHeight * self.WindowData.ResponsiveScale)
            Label.Text = opts.Text or Label.Name
            Label.TextColor3 = theme.TitleTextColor
            Label.BackgroundTransparency = 1
            Label.TextSize = textSize
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
            local toggleHeight = self.WindowData.IsMobile and 28 or 32
            local textSize = self.WindowData.IsMobile and 12 or 13
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = toggleName .. "_Frame"
            ToggleFrame.Size = UDim2.new(0.9, 0, 0, toggleHeight * self.WindowData.ResponsiveScale)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.LayoutOrder = #tabObj.Elements + 1
            ToggleFrame.Parent = TabContent
            
            local toggleButtonWidth = self.WindowData.IsMobile and 40 or 50
            local toggleButtonHeight = self.WindowData.IsMobile and 20 or 24
            local circleSize = self.WindowData.IsMobile and 16 or 20
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "Toggle"
            ToggleButton.Size = UDim2.new(0, toggleButtonWidth * self.WindowData.ResponsiveScale, 0, toggleButtonHeight * self.WindowData.ResponsiveScale)
            ToggleButton.Position = UDim2.new(1, -(toggleButtonWidth + 5) * self.WindowData.ResponsiveScale, 0.5, -(toggleButtonHeight/2) * self.WindowData.ResponsiveScale)
            ToggleButton.Text = ""
            ToggleButton.BackgroundColor3 = theme.ToggleOff
            ToggleButton.BackgroundTransparency = 0
            ToggleButton.AutoButtonColor = false
            ToggleButton.Parent = ToggleFrame
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "Circle"
            ToggleCircle.Size = UDim2.new(0, circleSize * self.WindowData.ResponsiveScale, 0, circleSize * self.WindowData.ResponsiveScale)
            ToggleCircle.Position = UDim2.new(0, 2 * self.WindowData.ResponsiveScale, 0.5, -(circleSize/2) * self.WindowData.ResponsiveScale)
            ToggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
            ToggleCircle.BackgroundTransparency = 0
            ToggleCircle.Parent = ToggleButton
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -(toggleButtonWidth + 10) * self.WindowData.ResponsiveScale, 1, 0)
            ToggleLabel.Text = opts.Text or toggleName
            ToggleLabel.TextColor3 = theme.TitleTextColor
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.TextSize = textSize
            ToggleLabel.Font = Enum.Font.SourceSans
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local isToggled = opts.CurrentValue or false
            
            if isToggled then
                ToggleButton.BackgroundColor3 = theme.ToggleOn
                ToggleCircle.Position = UDim2.new(1, -(circleSize + 2) * self.WindowData.ResponsiveScale, 0.5, -(circleSize/2) * self.WindowData.ResponsiveScale)
            end
            
            local function toggle()
                isToggled = not isToggled
                
                if isToggled then
                    ToggleButton.BackgroundColor3 = theme.ToggleOn
                    ToggleCircle.Position = UDim2.new(1, -(circleSize + 2) * self.WindowData.ResponsiveScale, 0.5, -(circleSize/2) * self.WindowData.ResponsiveScale)
                else
                    ToggleButton.BackgroundColor3 = theme.ToggleOff
                    ToggleCircle.Position = UDim2.new(0, 2 * self.WindowData.ResponsiveScale, 0.5, -(circleSize/2) * self.WindowData.ResponsiveScale)
                end
                
                if opts.Callback then
                    pcall(opts.Callback, isToggled)
                end
            end
            
            ToggleButton.MouseButton1Click:Connect(toggle)
            
            -- Touch support for mobile
            if self.WindowData.IsMobile then
                ToggleButton.TouchTap:Connect(toggle)
            end
            
            table.insert(tabObj.Elements, ToggleFrame)
            
            return {
                Set = function(value)
                    isToggled = value
                    if isToggled then
                        ToggleButton.BackgroundColor3 = theme.ToggleOn
                        ToggleCircle.Position = UDim2.new(1, -(circleSize + 2) * self.WindowData.ResponsiveScale, 0.5, -(circleSize/2) * self.WindowData.ResponsiveScale)
                    else
                        ToggleButton.BackgroundColor3 = theme.ToggleOff
                        ToggleCircle.Position = UDim2.new(0, 2 * self.WindowData.ResponsiveScale, 0.5, -(circleSize/2) * self.WindowData.ResponsiveScale)
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
            local sliderHeight = self.WindowData.IsMobile and 42 or 48
            local textSize = self.WindowData.IsMobile and 12 or 13
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = sliderName .. "_Frame"
            SliderFrame.Size = UDim2.new(0.9, 0, 0, sliderHeight * self.WindowData.ResponsiveScale)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.LayoutOrder = #tabObj.Elements + 1
            SliderFrame.Parent = TabContent
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Name = "Label"
            SliderLabel.Size = UDim2.new(1, 0, 0, 20 * self.WindowData.ResponsiveScale)
            SliderLabel.Text = sliderName .. ": " .. currentVal
            SliderLabel.TextColor3 = theme.TitleTextColor
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.TextSize = textSize
            SliderLabel.Font = Enum.Font.SourceSans
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local trackHeight = self.WindowData.IsMobile and 4 or 6
            local sliderButtonSize = self.WindowData.IsMobile and 12 or 14
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Name = "Track"
            SliderTrack.Size = UDim2.new(1, 0, 0, trackHeight * self.WindowData.ResponsiveScale)
            SliderTrack.Position = UDim2.new(0, 0, 0, 28 * self.WindowData.ResponsiveScale)
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
            SliderButton.Size = UDim2.new(0, sliderButtonSize * self.WindowData.ResponsiveScale, 0, sliderButtonSize * self.WindowData.ResponsiveScale)
            SliderButton.Position = UDim2.new(fillPercent, -sliderButtonSize/2 * self.WindowData.ResponsiveScale, 0.5, -sliderButtonSize/2 * self.WindowData.ResponsiveScale)
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
                SliderButton.Position = UDim2.new(fillPercent, -sliderButtonSize/2 * self.WindowData.ResponsiveScale, 0.5, -sliderButtonSize/2 * self.WindowData.ResponsiveScale)
                SliderLabel.Text = sliderName .. ": " .. math.floor(currentVal)
                
                if opts.Callback then
                    pcall(opts.Callback, currentVal)
                end
            end
            
            local function onInputBegan(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   (self.WindowData.IsMobile and input.UserInputType == Enum.UserInputType.Touch) then
                    dragging = true
                end
            end
            
            local function onInputChanged(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                   input.UserInputType == Enum.UserInputType.Touch) then
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
            end
            
            local function onInputEnded(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end
            
            SliderButton.InputBegan:Connect(onInputBegan)
            SliderTrack.InputBegan:Connect(onInputBegan)
            
            game:GetService("UserInputService").InputChanged:Connect(onInputChanged)
            game:GetService("UserInputService").InputEnded:Connect(onInputEnded)
            
            table.insert(tabObj.Elements, SliderFrame)
            
            return {
                Set = function(value) updateSlider(value) end,
                Get = function() return currentVal end
            }
        end
        
        function tabBuilder:CreateInput(options)
            local opts = options or {}
            local inputName = opts.Name or "Input_" .. #tabObj.Elements + 1
            local inputHeight = self.WindowData.IsMobile and 32 or 36
            local textSize = self.WindowData.IsMobile and 12 or 13
            
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = inputName .. "_Frame"
            InputFrame.Size = UDim2.new(0.9, 0, 0, inputHeight * self.WindowData.ResponsiveScale)
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
            InputBox.TextSize = textSize
            InputBox.Font = Enum.Font.SourceSans
            InputBox.ClearTextOnFocus = false
            InputBox.Parent = InputFrame
            
            InputBox.Focused:Connect(function()
                InputBox.BackgroundColor3 = theme.InputFocused
                
                -- Auto-show keyboard untuk mobile
                if self.WindowData.IsMobile then
                    InputBox:CaptureFocus()
                end
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
    
    -- ===== RESPONSIVE LAYOUT MANAGER =====
    function windowObj:CreateResponsiveLayout(container)
        local layoutManager = {}
        
        layoutManager.Container = container
        layoutManager.Elements = {}
        layoutManager.IsGrid = false
        layoutManager.Columns = 1
        
        function layoutManager:SetGridMode(columns)
            self.IsGrid = true
            self.Columns = columns or 2
        end
        
        function layoutManager:AddElement(element, options)
            local opts = options or {}
            
            table.insert(self.Elements, {
                Instance = element,
                Size = opts.Size or UDim2.new(1, 0, 0, 40),
                Order = opts.Order or #self.Elements + 1
            })
            
            self:UpdateLayout()
            return element
        end
        
        function layoutManager:UpdateLayout()
            local screen = self:GetScreenSize()
            local isMobile = self.WindowData.IsMobile
            
            if self.IsGrid and not isMobile then
                -- Grid layout untuk desktop/tablet
                local columnWidth = 1 / self.Columns
                local currentColumn = 0
                local currentRow = 0
                
                for i, elementData in ipairs(self.Elements) do
                    currentColumn = (i - 1) % self.Columns
                    currentRow = math.floor((i - 1) / self.Columns)
                    
                    elementData.Instance.Size = UDim2.new(
                        columnWidth, -10, 
                        0, elementData.Size.Y.Offset
                    )
                    
                    elementData.Instance.Position = UDim2.new(
                        columnWidth * currentColumn, 5,
                        0, currentRow * (elementData.Size.Y.Offset + 5)
                    )
                end
            else
                -- Vertical list layout untuk mobile
                local currentY = 0
                
                for i, elementData in ipairs(self.Elements) do
                    elementData.Instance.Size = UDim2.new(
                        1, isMobile and -20 or 0,
                        0, elementData.Size.Y.Offset
                    )
                    
                    elementData.Instance.Position = UDim2.new(
                        0, isMobile and 10 or 0,
                        0, currentY
                    )
                    
                    currentY = currentY + elementData.Size.Y.Offset + 5
                end
            end
        end
        
        -- Auto-update saat screen size berubah
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            layoutManager:UpdateLayout()
        end)
        
        return layoutManager
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
        
        ThemeTab:CreateButton({
            Text = "💜 Purple Theme",
            Callback = function()
                self:SetTheme("PURPLE")
            end
        })
        
        ThemeTab:CreateButton({
            Text = "💚 Green Theme",
            Callback = function()
                self:SetTheme("GREEN")
            end
        })
        
        ThemeTab:CreateLabel({
            Text = "Current: " .. self.DefaultTheme.Name
        })
    end
    
    print("✅ Responsive Window created: " .. windowData.Name)
    return windowObj
end

-- ===== EXPORT THEME FUNCTIONS =====
function SimpleGUI:ExportCurrentTheme()
    local theme = self.DefaultTheme
    local exportString = "-- SimpleGUI Theme Export\n"
    exportString = exportString .. "local theme = {\n"
    
    for key, value in pairs(theme) do
        if typeof(value) == "Color3" then
            exportString = exportString .. string.format("    %s = Color3.fromRGB(%d, %d, %d),\n", 
                key, math.round(value.R * 255), math.round(value.G * 255), math.round(value.B * 255))
        elseif type(value) == "string" then
            exportString = exportString .. string.format('    %s = "%s",\n', key, value)
        end
    end
    
    exportString = exportString .. "}\n"
    print("📋 Theme copied to clipboard (simulated)")
    return exportString
end

print("🎉 SimpleGUI v5.1 - Simplified Theme Editor with Responsive Layout loaded!")
return SimpleGUI