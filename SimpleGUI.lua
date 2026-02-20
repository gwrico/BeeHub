-- ==============================================
-- 🎨 SIMPLEGUI v7 - MODERN EDITION (FULL)
-- Compatible with SimpleGUI v6 structure
-- Rico Edition
-- ==============================================

print("🚀 Loading SimpleGUI v7 Modern Edition...")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- ======================
-- UTILITIES
-- ======================

local function tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function spring(obj, prop, val)
    tween(obj, {[prop] = val}, 0.25, Enum.EasingStyle.Back)
end

local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, trans)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = trans or 0.5
    s.Thickness = 1
    s.Parent = obj
    return s
end

local function hoverScale(button)
    local sc = Instance.new("UIScale")
    sc.Parent = button
    button.MouseEnter:Connect(function()
        spring(sc, "Scale", 1.05)
    end)
    button.MouseLeave:Connect(function()
        spring(sc, "Scale", 1)
    end)
end

local function glass(frame)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45,45,65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))
    })
    grad.Rotation = 90
    grad.Parent = frame
end

-- ======================
-- THEME
-- ======================

SimpleGUI.Themes = {
    DARK = {
        Window = Color3.fromRGB(28,28,38),
        Topbar = Color3.fromRGB(40,40,55),
        Sidebar = Color3.fromRGB(32,32,45),
        Content = Color3.fromRGB(35,35,50),
        Accent = Color3.fromRGB(120,170,255),
        Text = Color3.fromRGB(235,235,240),
        Button = Color3.fromRGB(55,55,75),
        Hover = Color3.fromRGB(70,70,95),
        Border = Color3.fromRGB(80,80,100),
        Secondary = Color3.fromRGB(45,45,65)
    }
}

-- ======================
-- CONSTRUCTOR
-- ======================

function SimpleGUI.new()
    local self = setmetatable({}, SimpleGUI)

    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleGUIv7_"..math.random(1000,9999)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)

    if not gui.Parent then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    self.Gui = gui
    self.Theme = self.Themes.DARK
    self.Windows = {}

    print("✅ SimpleGUI v7 Ready")
    return self
end

-- ======================
-- WINDOW
-- ======================

function SimpleGUI:CreateWindow(options)
    local opts = options or {}
    local theme = self.Theme

    local Main = Instance.new("Frame")
    Main.Size = opts.Size or UDim2.fromOffset(720,520)
    Main.Position = opts.Position or UDim2.new(0.5,-360,0.5,-260)
    Main.BackgroundColor3 = theme.Window
    Main.Parent = self.Gui

    addCorner(Main,14)
    addStroke(Main, theme.Border, 0.4)
    glass(Main)

    local scale = Instance.new("UIScale")
    scale.Scale = 0.85
    scale.Parent = Main
    tween(scale,{Scale=1},0.25)

    -- TOPBAR
    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1,0,0,42)
    Top.BackgroundColor3 = theme.Topbar
    Top.Parent = Main
    addCorner(Top,14)

    local Title = Instance.new("TextLabel")
    Title.Text = opts.Name or "Window"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = theme.Text
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(14,0)
    Title.Size = UDim2.new(1,-20,1,0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0,180,1,-42)
    Sidebar.Position = UDim2.fromOffset(0,42)
    Sidebar.BackgroundColor3 = theme.Sidebar
    Sidebar.Parent = Main

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0,6)

    -- CONTENT
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1,-180,1,-42)
    ContentHolder.Position = UDim2.fromOffset(180,42)
    ContentHolder.BackgroundColor3 = theme.Content
    ContentHolder.Parent = Main

    local window = {}
    window.Tabs = {}
    window.MainFrame = Main

    -- ======================
    -- NOTIFICATION
    -- ======================
    function window:Notify(text)
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.fromOffset(260,50)
        Notif.Position = UDim2.new(1,20,1,-70)
        Notif.BackgroundColor3 = theme.Secondary
        Notif.Parent = Main
        addCorner(Notif,10)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1,-20,1,0)
        Label.Position = UDim2.fromOffset(10,0)
        Label.Text = text
        Label.BackgroundTransparency = 1
        Label.TextColor3 = theme.Text
        Label.Parent = Notif

        tween(Notif,{Position=UDim2.new(1,-280,1,-70)},0.25)
        task.wait(3)
        tween(Notif,{Position=UDim2.new(1,20,1,-70)},0.25)
        task.wait(0.25)
        Notif:Destroy()
    end

    -- ======================
    -- TAB CREATION
    -- ======================

    function window:CreateTab(name)
        local Btn = Instance.new("TextButton")
        Btn.Text = "   "..name
        Btn.Size = UDim2.new(1,-12,0,40)
        Btn.Position = UDim2.fromOffset(6,0)
        Btn.BackgroundColor3 = theme.Button
        Btn.TextColor3 = theme.Text
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 14
        Btn.Parent = Sidebar
        Btn.AutoButtonColor = false
        addCorner(Btn,8)
        hoverScale(Btn)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0,4,1,0)
        Indicator.BackgroundColor3 = theme.Accent
        Indicator.Visible = false
        Indicator.Parent = Btn

        local Content = Instance.new("ScrollingFrame")
        Content.Size = UDim2.new(1,0,1,0)
        Content.CanvasSize = UDim2.new()
        Content.ScrollBarThickness = 4
        Content.BackgroundTransparency = 1
        Content.Visible = false
        Content.Parent = ContentHolder

        local Layout = Instance.new("UIListLayout", Content)
        Layout.Padding = UDim.new(0,10)

        local tab = {}
        tab.Button = Btn
        tab.Content = Content
        tab.Indicator = Indicator

        function tab:CreateSection(text)
            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(0.9,0,0,24)
            L.Text = text
            L.Font = Enum.Font.GothamBold
            L.TextColor3 = theme.Accent
            L.BackgroundTransparency = 1
            L.Parent = Content
        end

        function tab:CreateButton(options)
            local B = Instance.new("TextButton")
            B.Size = UDim2.new(0.9,0,0,40)
            B.Text = options.Text or "Button"
            B.BackgroundColor3 = theme.Button
            B.TextColor3 = theme.Text
            B.Parent = Content
            addCorner(B,8)
            hoverScale(B)

            B.MouseButton1Click:Connect(function()
                tween(B,{BackgroundColor3=theme.Accent},0.1)
                task.wait(0.1)
                tween(B,{BackgroundColor3=theme.Button},0.1)
                if options.Callback then options.Callback() end
            end)
        end

        function tab:CreateToggle(options)
            local state = options.CurrentValue or false

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0.9,0,0,40)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Content

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.fromOffset(60,30)
            Btn.Position = UDim2.new(0,0,0.5,-15)
            Btn.BackgroundColor3 = theme.Button
            Btn.Parent = Frame
            addCorner(Btn,15)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.fromOffset(24,24)
            Circle.Position = UDim2.fromOffset(3,3)
            Circle.BackgroundColor3 = Color3.new(1,1,1)
            Circle.Parent = Btn
            addCorner(Circle,12)

            local Label = Instance.new("TextLabel")
            Label.Text = options.Text or "Toggle"
            Label.TextColor3 = theme.Text
            Label.BackgroundTransparency = 1
            Label.Position = UDim2.fromOffset(70,0)
            Label.Size = UDim2.new(1,-70,1,0)
            Label.Parent = Frame

            local function update()
                if state then
                    tween(Btn,{BackgroundColor3=theme.Accent})
                    tween(Circle,{Position=UDim2.fromOffset(33,3)})
                else
                    tween(Btn,{BackgroundColor3=theme.Button})
                    tween(Circle,{Position=UDim2.fromOffset(3,3)})
                end
            end

            update()

            Btn.MouseButton1Click:Connect(function()
                state = not state
                update()
                if options.Callback then options.Callback(state) end
            end)
        end

        function tab:CreateDropdown(options)
            local items = options.Items or {}
            local current = items[1]

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0.9,0,0,40)
            Frame.BackgroundColor3 = theme.Button
            Frame.Parent = Content
            addCorner(Frame,8)

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1,0,1,0)
            Button.Text = current or "Select"
            Button.BackgroundTransparency = 1
            Button.TextColor3 = theme.Text
            Button.Parent = Frame

            local List = Instance.new("Frame")
            List.Size = UDim2.new(1,0,0,#items*30)
            List.Position = UDim2.new(0,0,1,4)
            List.Visible = false
            List.BackgroundColor3 = theme.Secondary
            List.Parent = Frame
            addCorner(List,8)

            Button.MouseButton1Click:Connect(function()
                List.Visible = not List.Visible
            end)

            for _,v in ipairs(items) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1,0,0,30)
                opt.Text = v
                opt.BackgroundTransparency = 1
                opt.TextColor3 = theme.Text
                opt.Parent = List

                opt.MouseButton1Click:Connect(function()
                    current = v
                    Button.Text = v
                    List.Visible = false
                    if options.Callback then options.Callback(v) end
                end)
            end
        end

        Btn.MouseButton1Click:Connect(function()
            for _,t in pairs(window.Tabs) do
                t.Content.Visible = false
                t.Indicator.Visible = false
                tween(t.Button,{BackgroundColor3=theme.Button})
            end
            Content.Visible = true
            Indicator.Visible = true
            tween(Btn,{BackgroundColor3=theme.Accent})
        end)

        table.insert(window.Tabs, tab)
        if #window.Tabs == 1 then Btn:Activate() end

        return tab
    end

    -- ======================
    -- DRAG WINDOW
    -- ======================

    local dragging = false
    local dragStart, startPos

    Top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
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

    return window
end

print("🎉 SimpleGUI v7 Modern Edition Loaded")
return SimpleGUI