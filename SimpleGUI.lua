local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

-- ======================
-- THEME
-- ======================

local theme = {
    Background = Color3.fromRGB(28,28,38),
    Secondary = Color3.fromRGB(35,35,48),
    Button = Color3.fromRGB(45,45,60),
    ButtonHover = Color3.fromRGB(60,60,85),
    Accent = Color3.fromRGB(170,120,255),
    Text = Color3.fromRGB(235,235,255),
    Border = Color3.fromRGB(80,80,110)
}

-- ======================
-- UTIL
-- ======================

local function tween(obj,props,time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function spring(object, property, target)
    TweenService:Create(
        object,
        TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {[property] = target}
    ):Play()
end

local function createGlass(frame)
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Transparency = 0.4
    stroke.Thickness = 1
    stroke.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45,45,65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,25,35))
    })
    gradient.Rotation = 90
    gradient.Parent = frame
end

-- ======================
-- CREATE WINDOW
-- ======================

function SimpleGUI:CreateWindow(data)
    local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = data.Size or UDim2.fromOffset(600,400)
    MainFrame.Position = UDim2.new(0.5,-300,0.5,-200)
    MainFrame.BackgroundColor3 = theme.Background
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,12)

    createGlass(MainFrame)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,0,0,40)
    Title.Text = data.Name or "SimpleGUI v7"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = theme.Text
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame

    -- SIDEBAR
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0,160,1,-40)
    Sidebar.Position = UDim2.new(0,0,0,40)
    Sidebar.BackgroundColor3 = theme.Secondary
    Sidebar.Parent = MainFrame
    Instance.new("UICorner",Sidebar).CornerRadius = UDim.new(0,10)

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0,6)
    SideLayout.Parent = Sidebar

    -- CONTENT
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1,-170,1,-50)
    ContentContainer.Position = UDim2.new(0,165,0,45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local window = {}
    window.Tabs = {}
    window.MainFrame = MainFrame

    -- ======================
    -- TAB SYSTEM
    -- ======================

    function window:CreateTab(name)
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

        local tabObj = {
            Button = TabButton,
            Content = TabContent,
            Indicator = Indicator
        }

        table.insert(window.Tabs, tabObj)

        TabButton.MouseButton1Click:Connect(function()
            for _,tab in pairs(window.Tabs) do
                tab.Content.Visible = false
                tab.Indicator.Visible = false
                tab.Button.BackgroundColor3 = theme.Button
            end

            TabContent.Visible = true
            Indicator.Visible = true
            TabButton.BackgroundColor3 = theme.ButtonHover
        end)

        if #window.Tabs == 1 then
            TabContent.Visible = true
            Indicator.Visible = true
        end

        -- ======================
        -- ELEMENTS
        -- ======================

        function tabObj:CreateSection(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.9,0,0,24)
            Label.Text = text
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = theme.Accent
            Label.BackgroundTransparency = 1
            Label.Parent = TabContent
        end

        function tabObj:CreateButton(data)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0.9,0,0,36)
            Button.Text = data.Text or "Button"
            Button.BackgroundColor3 = theme.Button
            Button.TextColor3 = theme.Text
            Button.Parent = TabContent
            Instance.new("UICorner",Button).CornerRadius = UDim.new(0,8)

            Button.MouseButton1Click:Connect(function()
                if data.Callback then
                    data.Callback()
                end
            end)

            local scale = Instance.new("UIScale",Button)
            Button.MouseEnter:Connect(function()
                spring(scale,"Scale",1.05)
            end)
            Button.MouseLeave:Connect(function()
                spring(scale,"Scale",1)
            end)

            return Button
        end

        function tabObj:CreateToggle(data)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0.9,0,0,36)
            Frame.BackgroundColor3 = theme.Button
            Frame.Parent = TabContent
            Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-50,1,0)
            Label.Text = data.Text or "Toggle"
            Label.TextColor3 = theme.Text
            Label.BackgroundTransparency = 1
            Label.Parent = Frame

            local Toggle = Instance.new("TextButton")
            Toggle.Size = UDim2.new(0,40,0,20)
            Toggle.Position = UDim2.new(1,-45,0.5,-10)
            Toggle.BackgroundColor3 = Color3.fromRGB(60,60,80)
            Toggle.Text = ""
            Toggle.Parent = Frame
            Instance.new("UICorner",Toggle).CornerRadius = UDim.new(1,0)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0,16,0,16)
            Circle.Position = UDim2.new(0,2,0.5,-8)
            Circle.BackgroundColor3 = Color3.new(1,1,1)
            Circle.Parent = Toggle
            Instance.new("UICorner",Circle).CornerRadius = UDim.new(1,0)

            local state = false

            Toggle.MouseButton1Click:Connect(function()
                state = not state
                tween(Circle,{
                    Position = state and UDim2.new(1,-18,0.5,-8)
                                     or UDim2.new(0,2,0.5,-8)
                })
                Toggle.BackgroundColor3 = state and theme.Accent or Color3.fromRGB(60,60,80)

                if data.Callback then
                    data.Callback(state)
                end
            end)
        end

        function tabObj:CreateDropdown(data)
            local items = data.Items or {}
            local current = items[1] or "Select"

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(0.9,0,0,36)
            Frame.BackgroundColor3 = theme.Button
            Frame.Parent = TabContent
            Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,8)

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1,0,1,0)
            Button.Text = current
            Button.TextColor3 = theme.Text
            Button.BackgroundTransparency = 1
            Button.Parent = Frame

            local List = Instance.new("Frame")
            List.Size = UDim2.new(1,0,0,#items*28)
            List.Position = UDim2.new(0,0,1,4)
            List.Visible = false
            List.BackgroundColor3 = theme.Secondary
            List.Parent = Frame
            Instance.new("UICorner",List).CornerRadius = UDim.new(0,8)

            for _,v in ipairs(items) do
                local opt = Instance.new("TextButton")
                opt.Size = UDim2.new(1,0,0,28)
                opt.Text = v
                opt.BackgroundTransparency = 1
                opt.TextColor3 = theme.Text
                opt.Parent = List

                opt.MouseButton1Click:Connect(function()
                    Button.Text = v
                    List.Visible = false
                    if data.Callback then
                        data.Callback(v)
                    end
                end)
            end

            Button.MouseButton1Click:Connect(function()
                List.Visible = not List.Visible
            end)
        end

        return tabObj
    end

    -- ======================
    -- NOTIFICATION
    -- ======================

    function window:Notify(text)
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
        Label.BackgroundTransparency = 1
        Label.TextColor3 = theme.Text
        Label.Parent = Notif

        tween(Notif,{Position=UDim2.new(1,-280,1,-70)},0.25)
        task.wait(3)
        tween(Notif,{Position=UDim2.new(1,20,1,-70)},0.25)
        task.wait(0.25)
        Notif:Destroy()
    end

    return window
end

return SimpleGUI