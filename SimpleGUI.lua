--// ===============================
--// SimpleGUI v7 FINAL (COMPATIBLE EDITION)
--// Executor Safe + PlayerMods Compatible
--// ===============================

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local function tween(o,p,t)
    TweenService:Create(o,TweenInfo.new(t or 0.2,Enum.EasingStyle.Quad),p):Play()
end

pcall(function() game.CoreGui.SimpleGUI:Destroy() end)

-- ===============================
-- THEME
-- ===============================

local theme = {
    Window = Color3.fromRGB(28,28,38),
    Title = Color3.fromRGB(38,38,50),
    Sidebar = Color3.fromRGB(34,34,46),
    Content = Color3.fromRGB(30,30,40),
    Button = Color3.fromRGB(55,55,75),
    Accent = Color3.fromRGB(160,120,255),
    Text = Color3.fromRGB(230,230,255),
    Error = Color3.fromRGB(255,80,80)
}

-- ===============================
-- ROOT
-- ===============================

local GUIRoot = Instance.new("ScreenGui")
GUIRoot.Name="SimpleGUI"
GUIRoot.Parent=game.CoreGui
GUIRoot.ResetOnSpawn=false

local Main = Instance.new("Frame")
Main.Size=UDim2.fromOffset(700,420)
Main.Position=UDim2.new(0.5,-350,0.5,-210)
Main.BackgroundColor3=theme.Window
Main.Parent=GUIRoot
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)

-- ===============================
-- TITLE BAR
-- ===============================

local TitleBar=Instance.new("Frame")
TitleBar.Size=UDim2.new(1,0,0,42)
TitleBar.BackgroundColor3=theme.Title
TitleBar.Parent=Main
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,12)

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-120,1,0)
Title.Position=UDim2.fromOffset(14,0)
Title.Text="SimpleGUI v7"
Title.TextColor3=theme.Text
Title.Font=Enum.Font.GothamBold
Title.TextSize=16
Title.BackgroundTransparency=1
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=TitleBar

local function makeBtn(text,color,x)
    local b=Instance.new("TextButton")
    b.Size=UDim2.fromOffset(28,28)
    b.Position=UDim2.new(1,x,0.5,-14)
    b.Text=text
    b.TextColor3=color
    b.BackgroundColor3=theme.Button
    b.Parent=TitleBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end

local MinBtn=makeBtn("_",theme.Text,-70)
local CloseBtn=makeBtn("✕",theme.Error,-36)

-- ===============================
-- SIDEBAR
-- ===============================

local Sidebar=Instance.new("Frame")
Sidebar.Size=UDim2.new(0,180,1,-42)
Sidebar.Position=UDim2.new(0,0,0,42)
Sidebar.BackgroundColor3=theme.Sidebar
Sidebar.Parent=Main

local SideLayout=Instance.new("UIListLayout")
SideLayout.Padding=UDim.new(0,6)
SideLayout.Parent=Sidebar

local SidePad=Instance.new("UIPadding")
SidePad.PaddingTop=UDim.new(0,10)
SidePad.PaddingLeft=UDim.new(0,10)
SidePad.PaddingRight=UDim.new(0,10)
SidePad.Parent=Sidebar

-- ===============================
-- CONTENT
-- ===============================

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-180,1,-42)
Content.Position=UDim2.new(0,180,0,42)
Content.BackgroundColor3=theme.Content
Content.Parent=Main

-- ===============================
-- TAB SYSTEM
-- ===============================

local Tabs={}

local function CreateBaseTab(name)
    local Button=Instance.new("TextButton")
    Button.Size=UDim2.new(1,0,0,36)
    Button.Text="  "..name
    Button.TextColor3=theme.Text
    Button.BackgroundColor3=theme.Button
    Button.Parent=Sidebar
    Instance.new("UICorner",Button).CornerRadius=UDim.new(0,8)

    local Page=Instance.new("Frame")
    Page.Size=UDim2.new(1,0,1,0)
    Page.BackgroundTransparency=1
    Page.Visible=false
    Page.Parent=Content

    local layout=Instance.new("UIListLayout")
    layout.Padding=UDim.new(0,8)
    layout.Parent=Page

    Tabs[#Tabs+1]={Button=Button,Page=Page}

    Button.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs) do
            t.Page.Visible=false
            t.Button.BackgroundColor3=theme.Button
        end
        Page.Visible=true
        Button.BackgroundColor3=theme.Accent
    end)

    if #Tabs==1 then
        Page.Visible=true
        Button.BackgroundColor3=theme.Accent
    end

    return Page
end

-- ===============================
-- COMPATIBILITY TAB API
-- ===============================

local function CreateCompatTab(name)
    local Page = CreateBaseTab(name)
    local tab = {}

    function tab:CreateButton(opt)
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0.9,0,0,36)
        b.Text=opt.Text or opt.Name or "Button"
        b.TextColor3=theme.Text
        b.BackgroundColor3=theme.Button
        b.Parent=Page
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
        b.MouseButton1Click:Connect(function()
            if opt.Callback then opt.Callback() end
        end)
    end

    function tab:CreateToggle(opt)
        local state = opt.CurrentValue or false

        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0.9,0,0,36)
        b.Text=(opt.Text or opt.Name or "Toggle").." : "..(state and "ON" or "OFF")
        b.TextColor3=theme.Text
        b.BackgroundColor3=theme.Button
        b.Parent=Page
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)

        b.MouseButton1Click:Connect(function()
            state = not state
            b.Text=(opt.Text or opt.Name).." : "..(state and "ON" or "OFF")
            if opt.Callback then opt.Callback(state) end
        end)
    end

    function tab:CreateSlider(opt)
        local value = opt.CurrentValue or opt.Range[1]
        local min = opt.Range[1]
        local max = opt.Range[2]
        local inc = opt.Increment or 1

        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0.9,0,0,36)
        b.Text=(opt.Name or "Slider").." : "..value
        b.TextColor3=theme.Text
        b.BackgroundColor3=theme.Button
        b.Parent=Page
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)

        b.MouseButton1Click:Connect(function()
            value = value + inc
            if value > max then value = min end
            b.Text=(opt.Name or "Slider").." : "..value
            if opt.Callback then opt.Callback(value) end
        end)
    end

    return tab
end

-- ===============================
-- WINDOW CONTROL
-- ===============================

CloseBtn.MouseButton1Click:Connect(function()
    Main:Destroy()
end)

local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    Sidebar.Visible=not minimized
    Content.Visible=not minimized
    Main.Size=minimized and UDim2.fromOffset(240,42)
                        or UDim2.fromOffset(700,420)
end)

-- ===============================
-- DRAG SYSTEM
-- ===============================

local drag=false
local start,origin

TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true
        start=i.Position
        origin=Main.Position
    end
end)

UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-start
        Main.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,
                                origin.Y.Scale,origin.Y.Offset+d.Y)
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=false
    end
end)

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
    CreateTab = CreateCompatTab,

    CreatePlayerModsEnvironment = function()
        return {
            Tab = nil,
            GUI = GUIRoot,
            Bdev = Bdev,
            Shared = {
                Services = Services,
                Variables = Variables,
                Functions = {}
            }
        }
    end
}