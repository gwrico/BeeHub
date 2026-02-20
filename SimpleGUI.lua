--// ===============================
--// SimpleGUI v7 Modern (FINAL)
--// Executor Safe - Single Script
--// ===============================

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function tween(obj,props,time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

-- remove old UI
pcall(function()
    game.CoreGui.SimpleGUI:Destroy()
end)

-- ===============================
-- THEME
-- ===============================

local theme = {
    Main = Color3.fromRGB(30,30,40),
    Secondary = Color3.fromRGB(40,40,55),
    Button = Color3.fromRGB(60,60,85),
    ButtonHover = Color3.fromRGB(75,75,110),
    Accent = Color3.fromRGB(170,120,255),
    Text = Color3.fromRGB(235,235,255)
}

-- ===============================
-- ROOT GUI
-- ===============================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(640,420)
MainFrame.Position = UDim2.new(0.5,-320,0.5,-210)
MainFrame.BackgroundColor3 = theme.Main
MainFrame.Parent = ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,12)

-- drag system
do
    local dragging, dragStart, startPos

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
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

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "SimpleGUI v7"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = theme.Text
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,160,1,-40)
Sidebar.Position = UDim2.new(0,0,0,40)
Sidebar.BackgroundColor3 = theme.Secondary
Sidebar.Parent = MainFrame
Instance.new("UICorner",Sidebar).CornerRadius = UDim.new(0,10)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,6)
SideLayout.Parent = Sidebar

-- content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1,-170,1,-50)
ContentContainer.Position = UDim2.new(0,165,0,45)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- ===============================
-- TAB SYSTEM
-- ===============================

local Tabs = {}

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1,0,0,40)
    TabButton.Text = name
    TabButton.BackgroundColor3 = theme.Button
    TabButton.TextColor3 = theme.Text
    TabButton.Parent = Sidebar
    Instance.new("UICorner",TabButton).CornerRadius = UDim.new(0,8)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0,4,1,0)
    Indicator.BackgroundColor3 = theme.Accent
    Indicator.Visible = false
    Indicator.Parent = TabButton

    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1,0,1,0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.Parent = TabContent

    local tab = {}
    tab.Content = TabContent

    table.insert(Tabs,{
        Button = TabButton,
        Content = TabContent,
        Indicator = Indicator
    })

    TabButton.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs) do
            t.Content.Visible = false
            t.Indicator.Visible = false
            t.Button.BackgroundColor3 = theme.Button
        end

        TabContent.Visible = true
        Indicator.Visible = true
        TabButton.BackgroundColor3 = theme.ButtonHover
    end)

    if #Tabs == 1 then
        TabContent.Visible = true
        Indicator.Visible = true
    end

    -- ===========================
    -- ELEMENTS
    -- ===========================

    function tab:Section(text)
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.9,0,0,24)
        Label.Text = text
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = theme.Accent
        Label.BackgroundTransparency = 1
        Label.Parent = TabContent
    end

    function tab:Button(text,callback)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0.9,0,0,36)
        Button.Text = text
        Button.BackgroundColor3 = theme.Button
        Button.TextColor3 = theme.Text
        Button.Parent = TabContent
        Instance.new("UICorner",Button).CornerRadius = UDim.new(0,8)

        Button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        Button.MouseEnter:Connect(function()
            tween(Button,{BackgroundColor3 = theme.ButtonHover})
        end)

        Button.MouseLeave:Connect(function()
            tween(Button,{BackgroundColor3 = theme.Button})
        end)
    end

    function tab:Toggle(text,callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0.9,0,0,36)
        Frame.BackgroundColor3 = theme.Button
        Frame.Parent = TabContent
        Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1,-50,1,0)
        Label.Text = text
        Label.TextColor3 = theme.Text
        Label.BackgroundTransparency = 1
        Label.Parent = Frame

        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0,40,0,20)
        Toggle.Position = UDim2.new(1,-45,0.5,-10)
        Toggle.BackgroundColor3 = Color3.fromRGB(90,90,120)
        Toggle.Text = ""
        Toggle.Parent = Frame
        Instance.new("UICorner",Toggle).CornerRadius = UDim.new(1,0)

        local Dot = Instance.new("Frame")
        Dot.Size = UDim2.new(0,16,0,16)
        Dot.Position = UDim2.new(0,2,0.5,-8)
        Dot.BackgroundColor3 = Color3.new(1,1,1)
        Dot.Parent = Toggle
        Instance.new("UICorner",Dot).CornerRadius = UDim.new(1,0)

        local state=false

        Toggle.MouseButton1Click:Connect(function()
            state=not state
            tween(Dot,{
                Position = state and UDim2.new(1,-18,0.5,-8)
                                 or UDim2.new(0,2,0.5,-8)
            })
            Toggle.BackgroundColor3 = state and theme.Accent
                                               or Color3.fromRGB(90,90,120)
            if callback then callback(state) end
        end)
    end

    function tab:Dropdown(text,list,callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0.9,0,0,36)
        Frame.BackgroundColor3 = theme.Button
        Frame.Parent = TabContent
        Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1,0,1,0)
        Button.Text = text
        Button.TextColor3 = theme.Text
        Button.BackgroundTransparency = 1
        Button.Parent = Frame

        local Drop = Instance.new("Frame")
        Drop.Size = UDim2.new(1,0,0,#list*28)
        Drop.Position = UDim2.new(0,0,1,4)
        Drop.Visible = false
        Drop.BackgroundColor3 = theme.Secondary
        Drop.Parent = Frame
        Instance.new("UICorner",Drop).CornerRadius = UDim.new(0,8)

        for _,v in ipairs(list) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1,0,0,28)
            opt.Text = v
            opt.BackgroundTransparency = 1
            opt.TextColor3 = theme.Text
            opt.Parent = Drop

            opt.MouseButton1Click:Connect(function()
                Button.Text = v
                Drop.Visible = false
                if callback then callback(v) end
            end)
        end

        Button.MouseButton1Click:Connect(function()
            Drop.Visible = not Drop.Visible
        end)
    end

    return tab
end

-- ===============================
-- NOTIFICATION
-- ===============================

local function Notify(text)
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.fromOffset(260,50)
    Notif.Position = UDim2.new(1,20,1,-70)
    Notif.BackgroundColor3 = theme.Secondary
    Notif.Parent = MainFrame
    Instance.new("UICorner",Notif).CornerRadius = UDim.new(0,10)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,-20,1,0)
    Label.Position = UDim2.fromOffset(10,0)
    Label.Text = text
    Label.TextColor3 = theme.Text
    Label.BackgroundTransparency = 1
    Label.Parent = Notif

    tween(Notif,{Position=UDim2.new(1,-280,1,-70)},0.25)
    task.wait(3)
    tween(Notif,{Position=UDim2.new(1,20,1,-70)},0.25)
    task.wait(0.25)
    Notif:Destroy()
end

-- ===============================
-- EXPORT GLOBAL
-- ===============================

getgenv().SimpleGUI = {
    CreateTab = CreateTab,
    Notify = Notify
}