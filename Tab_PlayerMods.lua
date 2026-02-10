-- ==============================================
-- 👤 PLAYER MODS TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI  -- ✅ ADDED: Access to SimpleGUI
    
    local Services = Shared.Services
    local Variables = Shared.Variables
    local Functions = Shared.Functions
    
    print("👤 Initializing PlayerMods tab...")
    
    -- ===== SPEED HACK =====
    local customSpeed = 100
    local speedToggle = Tab:CreateToggle({
        Name = "SpeedHack",
        Text = "🏃 Speed Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.speedHackEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Speed Hack",
                    Content = "Speed hack enabled! (" .. customSpeed .. " walk speed)",
                    Duration = 3
                })
                
                print("✅ Speed hack enabled:", customSpeed)
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.speedHackEnabled then
                        if connection then
                            connection:Disconnect()
                        end
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = customSpeed
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
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
    
    local speedSlider = Tab:CreateSlider({
        Name = "SpeedValue",
        Text = "Speed Value: " .. customSpeed,
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 100,
        Callback = function(value)
            customSpeed = value
            speedSlider.Text = "Speed Value: " .. value  -- ✅ UPDATE label
            
            if Variables.speedHackEnabled then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = value
                end
            end
            print("📊 Speed set to:", value)
        end
    })
    
    -- ===== JUMP HACK =====
    local customJump = 150
    local jumpToggle = Tab:CreateToggle({
        Name = "JumpHack",
        Text = "🦘 Jump Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.jumpHackEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Jump Hack",
                    Content = "Jump hack enabled! (" .. customJump .. " jump power)",
                    Duration = 3
                })
                
                print("✅ Jump hack enabled:", customJump)
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.jumpHackEnabled then
                        if connection then
                            connection:Disconnect()
                        end
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = customJump
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
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
    
    local jumpSlider = Tab:CreateSlider({
        Name = "JumpValue",
        Text = "Jump Value: " .. customJump,
        Range = {50, 500},
        Increment = 5,
        CurrentValue = 150,
        Callback = function(value)
            customJump = value
            jumpSlider.Text = "Jump Value: " .. value  -- ✅ UPDATE label
            
            if Variables.jumpHackEnabled then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = value
                end
            end
            print("📊 Jump power set to:", value)
        end
    })
    
    -- ===== FLY HACK =====
    local flySpeed = 50
    local flyBodyVelocity = nil
    local flyConnection = nil
    local charAddedConnection = nil
    
    local flyToggle = Tab:CreateToggle({
        Name = "FlyHack",
        Text = "✈️ Fly Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.flyEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Fly Hack",
                    Content = "Fly hack enabled! (" .. flySpeed .. " speed)",
                    Duration = 3
                })
                
                print("✅ Fly hack enabled:", flySpeed)
                
                local player = game.Players.LocalPlayer
                local character = player.Character
                
                if not character then
                    Bdev:Notify({
                        Title = "Error",
                        Content = "No character found!",
                        Duration = 3
                    })
                    return
                end
                
                -- Create fly body velocity
                local root = character:FindFirstChild("HumanoidRootPart")
                if not root then
                    Bdev:Notify({
                        Title = "Error",
                        Content = "No HumanoidRootPart found!",
                        Duration = 3
                    })
                    return
                end
                
                if flyBodyVelocity then
                    flyBodyVelocity:Destroy()
                end
                
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                flyBodyVelocity.P = 1000
                flyBodyVelocity.Name = "FlyHackBodyVelocity"
                flyBodyVelocity.Parent = root
                
                -- Fly control function
                if flyConnection then
                    flyConnection:Disconnect()
                end
                
                flyConnection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.flyEnabled or not character or not character.Parent then
                        return
                    end
                    
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if not root or not flyBodyVelocity or flyBodyVelocity.Parent ~= root then
                        return
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
                    flyBodyVelocity.Velocity = direction
                    
                    -- Zero out gravity while flying
                    if character:FindFirstChild("Humanoid") then
                        character.Humanoid.PlatformStand = true
                    end
                end)
                
                -- Handle character respawn
                if charAddedConnection then
                    charAddedConnection:Disconnect()
                end
                
                charAddedConnection = player.CharacterAdded:Connect(function(newChar)
                    character = newChar
                    wait(1)  -- Wait for character to load
                    
                    if Variables.flyEnabled then
                        local root = newChar:FindFirstChild("HumanoidRootPart")
                        if root then
                            if flyBodyVelocity then
                                flyBodyVelocity:Destroy()
                            end
                            
                            flyBodyVelocity = Instance.new("BodyVelocity")
                            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                            flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                            flyBodyVelocity.P = 1000
                            flyBodyVelocity.Name = "FlyHackBodyVelocity"
                            flyBodyVelocity.Parent = root
                        end
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Fly Hack",
                    Content = "Fly hack disabled!",
                    Duration = 3
                })
                
                print("❌ Fly hack disabled")
                
                -- Clean up
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                
                if charAddedConnection then
                    charAddedConnection:Disconnect()
                    charAddedConnection = nil
                end
                
                if flyBodyVelocity then
                    flyBodyVelocity:Destroy()
                    flyBodyVelocity = nil
                end
                
                -- Reset platform stand
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.PlatformStand = false
                end
            end
        end
    })
    
    local flySlider = Tab:CreateSlider({
        Name = "FlySpeed",
        Text = "Fly Speed: " .. flySpeed,
        Range = {10, 200},
        Increment = 5,
        CurrentValue = 50,
        Callback = function(value)
            flySpeed = value
            flySlider.Text = "Fly Speed: " .. value  -- ✅ UPDATE label
            print("📊 Fly speed set to:", value)
        end
    })
    
    -- ===== NOCLIP =====
    local noclipConnection = nil
    
    Tab:CreateToggle({
        Name = "Noclip",
        Text = "👻 Noclip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Noclip",
                    Content = "Noclip enabled!",
                    Duration = 3
                })
                
                print("✅ Noclip enabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                end
                
                noclipConnection = Services.RunService.Stepped:Connect(function()
                    if not Variables.noclipEnabled then
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
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Noclip",
                    Content = "Noclip disabled!",
                    Duration = 3
                })
                
                print("❌ Noclip disabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                
                -- Restore collision
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
    
    -- ===== INFINITE JUMP =====
    local infiniteJumpConnection = nil
    
    Tab:CreateToggle({
        Name = "InfiniteJump",
        Text = "∞ Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            Variables.infiniteJumpEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Infinite Jump",
                    Content = "Infinite jump enabled!",
                    Duration = 3
                })
                
                print("✅ Infinite jump enabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                end
                
                infiniteJumpConnection = Services.UserInputService.JumpRequest:Connect(function()
                    if not Variables.infiniteJumpEnabled then
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:ChangeState("Jumping")
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Infinite Jump",
                    Content = "Infinite jump disabled!",
                    Duration = 3
                })
                
                print("❌ Infinite jump disabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                    infiniteJumpConnection = nil
                end
            end
        end
    })
    
    -- ===== ANTI-AFK =====
    Tab:CreateToggle({
        Name = "AntiAFK",
        Text = "⏰ Anti-AFK",
        CurrentValue = false,
        Callback = function(value)
            Variables.antiAfkEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Anti-AFK",
                    Content = "Anti-AFK enabled!",
                    Duration = 3
                })
                
                print("✅ Anti-AFK enabled")
                
                -- Simulate movement every 30 seconds
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.antiAfkEnabled then
                        if connection then
                            connection:Disconnect()
                        end
                        return
                    end
                    
                    -- Every 30 seconds, simulate a small movement
                    if tick() % 30 < 0.1 then
                        local vim = Services.VirtualInputManager
                        pcall(function()
                            -- Press W briefly
                            vim:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                            task.wait(0.1)
                            vim:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                        end)
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Anti-AFK",
                    Content = "Anti-AFK disabled!",
                    Duration = 3
                })
                
                print("❌ Anti-AFK disabled")
            end
        end
    })
    
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
            Variables.antiAfkEnabled = false
            Variables.autoCollectEnabled = false
            Variables.autoPunchEnabled = false
            Variables.autoHatchEnabled = false
            
            -- Reset character stats
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
                char.Humanoid.PlatformStand = false
                
                -- Remove fly body velocity
                local bodyVelocity = char:FindFirstChild("FlyHackBodyVelocity")
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
            
            -- Disconnect all connections
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            if charAddedConnection then
                charAddedConnection:Disconnect()
                charAddedConnection = nil
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            
            Bdev:Notify({  -- ✅ FIXED: Colon syntax
                Title = "All Hacks",
                Content = "All hacks have been disabled!",
                Duration = 4
            })
            
            print("✅ All hacks disabled")
        end
    })
    
    -- ===== QUICK SETTINGS =====
    Tab:CreateLabel({
        Name = "QuickSettings",
        Text = "⚡ Quick Settings:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    Tab:CreateButton({
        Name = "QuickSpeed",
        Text = "🏃 100 Speed",
        Callback = function()
            customSpeed = 100
            speedSlider:Set(100)
            speedSlider.Text = "Speed Value: 100"
            
            if not Variables.speedHackEnabled then
                speedToggle:Set(true)
            else
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 100
                end
            end
            
            Bdev:Notify({
                Title = "Quick Settings",
                Content = "Speed set to 100!",
                Duration = 3
            })
        end
    })
    
    Tab:CreateButton({
        Name = "QuickJump",
        Text = "🦘 150 Jump",
        Callback = function()
            customJump = 150
            jumpSlider:Set(150)
            jumpSlider.Text = "Jump Value: 150"
            
            if not Variables.jumpHackEnabled then
                jumpToggle:Set(true)
            else
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 150
                end
            end
            
            Bdev:Notify({
                Title = "Quick Settings",
                Content = "Jump set to 150!",
                Duration = 3
            })
        end
    })
    
    print("✅ PlayerMods tab initialized")
end

return PlayerMods