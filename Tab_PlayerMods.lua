-- ==============================================
-- 👤 PLAYER MODS TAB MODULE - UPDATED FOR SIMPLEGUI v6.3
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI  -- ✅ AMBIL GUI DARI DEPENDENCIES
    
    local Services = Shared.Services
    local Variables = Shared.Variables
    local Functions = Shared.Functions or {}  -- ✅ HANDLE KASUS FUNCTIONS TIDAK ADA
    
    print("👤 Initializing PlayerMods tab...")
    
    -- ===== SPEED HACK =====
    local customSpeed = 100
    
    -- Pastikan method CreateToggle ada di Tab
    if not Tab.CreateToggle then
        print("⚠️ CreateToggle not found in Tab object! Using fallback...")
        -- Fallback ke button
        Tab:CreateButton({
            Name = "SpeedHack_Fallback",
            Text = "⚠️ Speed Hack (Toggle not available)",
            Callback = function()
                Variables.speedHackEnabled = not Variables.speedHackEnabled
                if Variables.speedHackEnabled then
                    Bdev:Notify({
                        Title = "Speed Hack",
                        Content = "Speed hack enabled! (" .. customSpeed .. ")",
                        Duration = 3
                    })
                else
                    Bdev:Notify({
                        Title = "Speed Hack",
                        Content = "Speed hack disabled!",
                        Duration = 3
                    })
                end
            end
        })
    else
        -- Gunakan CreateToggle jika tersedia
        local speedToggle = Tab:CreateToggle({
            Name = "SpeedHack",
            Text = "🏃 Speed Hack",
            CurrentValue = false,
            Callback = function(value)
                Variables.speedHackEnabled = value
                
                if value then
                    Bdev:Notify({
                        Title = "Speed Hack",
                        Content = "Speed hack enabled! (" .. customSpeed .. " walk speed)",
                        Duration = 3
                    })
                    
                    print("✅ Speed hack enabled:", customSpeed)
                    
                    local connection
                    connection = Services.RunService.Heartbeat:Connect(function()
                        if not Variables.speedHackEnabled then
                            connection:Disconnect()
                            return
                        end
                        
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.WalkSpeed = customSpeed
                        end
                    end)
                    
                else
                    Bdev:Notify({
                        Title = "Speed Hack",
                        Content = "Speed hack disabled!",
                        Duration = 3
                    })
                    
                    print("❌ Speed hack disabled")
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = 16
                    end
                end
            end
        })
    end
    
    -- ===== SPEED SLIDER =====
    if Tab.CreateSlider then
        Tab:CreateSlider({
            Name = "Speed Value",
            Range = {16, 500},
            Increment = 1,
            CurrentValue = 100,
            Callback = function(value)
                customSpeed = value
                if Variables.speedHackEnabled then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = value
                    end
                end
                print("📊 Speed set to:", value)
            end
        })
    else
        print("⚠️ CreateSlider not available for Speed")
    end
    
    -- ===== JUMP HACK =====
    local customJump = 150
    
    if Tab.CreateToggle then
        local jumpToggle = Tab:CreateToggle({
            Name = "JumpHack",
            Text = "🦘 Jump Hack",
            CurrentValue = false,
            Callback = function(value)
                Variables.jumpHackEnabled = value
                
                if value then
                    Bdev:Notify({
                        Title = "Jump Hack",
                        Content = "Jump hack enabled! (" .. customJump .. " jump power)",
                        Duration = 3
                    })
                    
                    print("✅ Jump hack enabled:", customJump)
                    
                    local connection
                    connection = Services.RunService.Heartbeat:Connect(function()
                        if not Variables.jumpHackEnabled then
                            connection:Disconnect()
                            return
                        end
                        
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid.JumpPower = customJump
                        end
                    end)
                    
                else
                    Bdev:Notify({
                        Title = "Jump Hack",
                        Content = "Jump hack disabled!",
                        Duration = 3
                    })
                    
                    print("❌ Jump hack disabled")
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = 50
                    end
                end
            end
        })
    end
    
    if Tab.CreateSlider then
        Tab:CreateSlider({
            Name = "Jump Value",
            Range = {50, 500},
            Increment = 5,
            CurrentValue = 150,
            Callback = function(value)
                customJump = value
                if Variables.jumpHackEnabled then
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = value
                    end
                end
                print("📊 Jump power set to:", value)
            end
        })
    end
    
    -- ===== FLY HACK =====
    local flySpeed = 50
    
    if Tab.CreateToggle then
        local flyToggle = Tab:CreateToggle({
            Name = "FlyHack",
            Text = "✈️ Fly Hack",
            CurrentValue = false,
            Callback = function(value)
                Variables.flyEnabled = value
                
                if value then
                    Bdev:Notify({
                        Title = "Fly Hack",
                        Content = "Fly hack enabled! (" .. flySpeed .. " speed)",
                        Duration = 3
                    })
                    
                    print("✅ Fly hack enabled:", flySpeed)
                    
                    -- Initialize fly variables
                    local player = game.Players.LocalPlayer
                    local character = player.Character or player.CharacterAdded:Wait()
                    
                    -- Create fly body velocity
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                    bodyVelocity.P = 1000
                    bodyVelocity.Name = "FlyHackBodyVelocity"
                    bodyVelocity.Parent = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
                    
                    -- Fly control function
                    local flyConnection
                    flyConnection = Services.RunService.Heartbeat:Connect(function()
                        if not Variables.flyEnabled or not character or not character:FindFirstChild("HumanoidRootPart") then
                            if flyConnection then flyConnection:Disconnect() end
                            if bodyVelocity then bodyVelocity:Destroy() end
                            return
                        end
                        
                        local root = character.HumanoidRootPart
                        if not bodyVelocity or not bodyVelocity.Parent then
                            bodyVelocity = Instance.new("BodyVelocity")
                            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                            bodyVelocity.P = 1000
                            bodyVelocity.Name = "FlyHackBodyVelocity"
                            bodyVelocity.Parent = root
                        end
                        
                        -- Get input for flying
                        local camera = workspace.CurrentCamera
                        local forward = camera.CFrame.LookVector
                        local right = camera.CFrame.RightVector
                        local up = Vector3.new(0, 1, 0)
                        
                        local direction = Vector3.new(0, 0, 0)
                        
                        -- W (forward)
                        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
                            direction = direction + forward
                        end
                        -- S (backward)
                        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
                            direction = direction - forward
                        end
                        -- A (left)
                        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
                            direction = direction - right
                        end
                        -- D (right)
                        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
                            direction = direction + right
                        end
                        -- Space (up)
                        if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            direction = direction + up
                        end
                        -- LeftShift (down)
                        if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                            direction = direction - up
                        end
                        
                        -- Normalize and apply speed
                        if direction.Magnitude > 0 then
                            direction = direction.Unit * flySpeed
                        end
                        
                        -- Apply velocity
                        bodyVelocity.Velocity = direction
                        
                        -- Zero out gravity while flying
                        if character:FindFirstChild("Humanoid") then
                            character.Humanoid.PlatformStand = true
                        end
                    end)
                    
                else
                    Bdev:Notify({
                        Title = "Fly Hack",
                        Content = "Fly hack disabled!",
                        Duration = 3
                    })
                    
                    print("❌ Fly hack disabled")
                    
                    -- Clean up fly objects
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local bodyVelocity = char:FindFirstChild("FlyHackBodyVelocity")
                        if bodyVelocity then bodyVelocity:Destroy() end
                        
                        if char:FindFirstChild("Humanoid") then
                            char.Humanoid.PlatformStand = false
                        end
                    end
                end
            end
        })
    end
    
    if Tab.CreateSlider then
        Tab:CreateSlider({
            Name = "Fly Speed",
            Range = {10, 200},
            Increment = 5,
            CurrentValue = 50,
            Callback = function(value)
                flySpeed = value
                print("📊 Fly speed set to:", value)
            end
        })
    end
    
    -- ===== NOCLIP =====
    if Tab.CreateToggle then
        Tab:CreateToggle({
            Name = "Noclip",
            Text = "👻 Noclip",
            CurrentValue = false,
            Callback = function(value)
                Variables.noclipEnabled = value
                
                if value then
                    Bdev:Notify({
                        Title = "Noclip",
                        Content = "Noclip enabled!",
                        Duration = 3
                    })
                    
                    print("✅ Noclip enabled")
                    
                    local connection
                    connection = Services.RunService.Stepped:Connect(function()
                        if not Variables.noclipEnabled then
                            connection:Disconnect()
                            return
                        end
                        
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                    
                else
                    Bdev:Notify({
                        Title = "Noclip",
                        Content = "Noclip disabled!",
                        Duration = 3
                    })
                    
                    print("❌ Noclip disabled")
                    
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end
                    end
                end
            end
        })
    end
    
    -- ===== INFINITE JUMP =====
    if Tab.CreateToggle then
        Tab:CreateToggle({
            Name = "InfiniteJump",
            Text = "∞ Infinite Jump",
            CurrentValue = false,
            Callback = function(value)
                Variables.infiniteJumpEnabled = value
                
                if value then
                    Bdev:Notify({
                        Title = "Infinite Jump",
                        Content = "Infinite jump enabled!",
                        Duration = 3
                    })
                    
                    print("✅ Infinite jump enabled")
                    
                    local connection
                    connection = Services.UserInputService.JumpRequest:Connect(function()
                        if not Variables.infiniteJumpEnabled then
                            connection:Disconnect()
                            return
                        end
                        
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid:ChangeState("Jumping")
                        end
                    end)
                    
                else
                    Bdev:Notify({
                        Title = "Infinite Jump",
                        Content = "Infinite jump disabled!",
                        Duration = 3
                    })
                    
                    print("❌ Infinite jump disabled")
                end
            end
        })
    end
    
    -- ===== DISABLE ALL HACKS =====
    Tab:CreateButton({
        Name = "DisableAll",
        Text = "🔴 Disable All Hacks",
        Callback = function()
            print("\n🔴 DISABLING ALL HACKS...")
            
            -- Disable all toggles
            Variables.speedHackEnabled = false
            Variables.jumpHackEnabled = false
            Variables.noclipEnabled = false
            Variables.infiniteJumpEnabled = false
            Variables.flyEnabled = false
            
            -- Reset character stats
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
                
                -- Remove fly body velocity
                local bodyVelocity = char:FindFirstChild("FlyHackBodyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
                
                -- Reset platform stand
                char.Humanoid.PlatformStand = false
                
                -- Reset collision
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
            
            Bdev:Notify({
                Title = "All Hacks",
                Content = "All hacks have been disabled!",
                Duration = 4
            })
            
            print("✅ All hacks disabled")
        end
    })
    
    print("✅ PlayerMods tab initialized")
end

return PlayerMods