-- ==============================================
-- 👤 PLAYER MODS TAB MODULE - FIXED
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Services = Shared.Services
    local Variables = Shared.Variables
    local Functions = Shared.Functions
    
    print("👤 Initializing PlayerMods tab...")
    
    -- ===== SPEED HACK =====
    local customSpeed = 100
    local speedConnection = nil
    
    local speedToggle = Tab:CreateToggle({
        Name = "SpeedHack",
        Text = "🏃 Speed Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.speedHackEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Speed Hack",
                    Content = "Speed hack enabled! (" .. customSpeed .. " walk speed)",
                    Duration = 3
                })
                
                print("✅ Speed hack enabled:", customSpeed)
                
                if speedConnection then
                    speedConnection:Disconnect()
                end
                
                speedConnection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.speedHackEnabled then
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.WalkSpeed = customSpeed
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Speed Hack",
                    Content = "Speed hack disabled!",
                    Duration = 3
                })
                
                print("❌ Speed hack disabled")
                
                if speedConnection then
                    speedConnection:Disconnect()
                    speedConnection = nil
                end
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 16
                end
            end
        end
    })
    
    Tab:CreateSlider({
        Name = "SpeedValue",
        Text = "Speed: " .. customSpeed,
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
    
    -- ===== JUMP HACK =====
    local customJump = 150
    local jumpConnection = nil
    
    local jumpToggle = Tab:CreateToggle({
        Name = "JumpHack",
        Text = "🦘 Jump Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.jumpHackEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Jump Hack",
                    Content = "Jump hack enabled! (" .. customJump .. " jump power)",
                    Duration = 3
                })
                
                print("✅ Jump hack enabled:", customJump)
                
                if jumpConnection then
                    jumpConnection:Disconnect()
                end
                
                jumpConnection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.jumpHackEnabled then
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid.JumpPower = customJump
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Jump Hack",
                    Content = "Jump hack disabled!",
                    Duration = 3
                })
                
                print("❌ Jump hack disabled")
                
                if jumpConnection then
                    jumpConnection:Disconnect()
                    jumpConnection = nil
                end
                
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 50
                end
            end
        end
    })
    
    Tab:CreateSlider({
        Name = "JumpValue",
        Text = "Jump: " .. customJump,
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
    
    -- ===== SIMPLE FLY HACK =====
    local flySpeed = 50
    local flyEnabled = false
    local flyConnection = nil
    
    Tab:CreateToggle({
        Name = "FlyHack",
        Text = "✈️ Simple Fly",
        CurrentValue = false,
        Callback = function(value)
            flyEnabled = value
            Variables.flyEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Fly Hack",
                    Content = "Simple fly enabled! (Press Space/Shift)",
                    Duration = 3
                })
                
                print("✅ Simple fly enabled")
                
                if flyConnection then
                    flyConnection:Disconnect()
                end
                
                flyConnection = Services.RunService.Heartbeat:Connect(function()
                    if not flyEnabled then return end
                    
                    local char = game.Players.LocalPlayer.Character
                    if not char then return end
                    
                    local humanoid = char:FindFirstChild("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not humanoid or not root then return end
                    
                    -- Simple fly: just increase jump power and enable no gravity
                    humanoid.JumpPower = flySpeed * 2
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Fly Hack",
                    Content = "Fly disabled!",
                    Duration = 3
                })
                
                print("❌ Fly disabled")
                
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                
                local char = game.Players.LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = 50
                    end
                end
            end
        end
    })
    
    Tab:CreateSlider({
        Name = "FlySpeed",
        Text = "Fly Speed: " .. flySpeed,
        Range = {10, 200},
        Increment = 5,
        CurrentValue = 50,
        Callback = function(value)
            flySpeed = value
            print("📊 Fly speed set to:", value)
        end
    })
    
    -- ===== SIMPLE NOCLIP =====
    local noclipConnection = nil
    
    Tab:CreateToggle({
        Name = "Noclip",
        Text = "👻 Simple Noclip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Titik dua
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
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Noclip",
                    Content = "Noclip disabled!",
                    Duration = 3
                })
                
                print("❌ Noclip disabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                
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
                Bdev:Notify({  -- ✅ FIXED: Titik dua
                    Title = "Infinite Jump",
                    Content = "Infinite jump enabled!",
                    Duration = 3
                })
                
                print("✅ Infinite jump enabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                end
                
                infiniteJumpConnection = Services.UserInputService.JumpRequest:Connect(function()
                    if Variables.infiniteJumpEnabled then
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            char.Humanoid:ChangeState("Jumping")
                        end
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Titik dua
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
    
    -- ===== QUICK SPEED =====
    Tab:CreateButton({
        Name = "QuickSpeed",
        Text = "⚡ Quick Speed 100",
        Callback = function()
            customSpeed = 100
            
            if not Variables.speedHackEnabled then
                speedToggle:Set(true)  -- Enable if not enabled
            else
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = 100
                end
            end
            
            Bdev:Notify({
                Title = "Quick Speed",
                Content = "Speed set to 100!",
                Duration = 3
            })
        end
    })
    
    -- ===== QUICK JUMP =====
    Tab:CreateButton({
        Name = "QuickJump",
        Text = "⚡ Quick Jump 150",
        Callback = function()
            customJump = 150
            
            if not Variables.jumpHackEnabled then
                jumpToggle:Set(true)  -- Enable if not enabled
            else
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.JumpPower = 150
                end
            end
            
            Bdev:Notify({
                Title = "Quick Jump",
                Content = "Jump set to 150!",
                Duration = 3
            })
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
            Variables.autoCollectEnabled = false
            Variables.autoPunchEnabled = false
            
            -- Disconnect all connections
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
            
            if jumpConnection then
                jumpConnection:Disconnect()
                jumpConnection = nil
            end
            
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            
            -- Reset character stats
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
                char.Humanoid.JumpPower = 50
                char.Humanoid.PlatformStand = false
            end
            
            Bdev:Notify({  -- ✅ FIXED: Titik dua
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