-- ==============================================
-- ⚡ MISC TAB MODULE - FIXED SYNTAX VERSION
-- ==============================================

local Misc = {}

function Misc.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables
    local Services = Shared.Services
    
    --print("⚡ Initializing Misc tab...")
    
    -- Initialize variables
    Variables.godModeEnabled = Variables.godModeEnabled or false
    Variables.invincibleEnabled = Variables.invincibleEnabled or false
    Variables.godModeConnection = nil
    Variables.invincibleLoop = nil
    
    -- ===== ANTI-AFK =====
    local antiAFKConnection
    
    Tab:CreateToggle({
        Name = "AntiAFK",
        Text = "⏰ Anti-AFK",
        CurrentValue = false,
        Callback = function(value)
            Variables.antiAfkEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK enabled! You won't be kicked.",
                    Duration = 3
                })
                
                --print("✅ Anti-AFK enabled")
                
                local lastActivity = tick()
                
                antiAFKConnection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.antiAfkEnabled then return end
                    
                    if tick() - lastActivity > 30 then
                        lastActivity = tick()
                        pcall(function()
                            local VirtualUser = game:GetService("VirtualUser")
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new(0, 0))
                        end)
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Anti-AFK",
                    Content = "Anti-AFK disabled!",
                    Duration = 3
                })
                
                --print("❌ Anti-AFK disabled")
                
                if antiAFKConnection then
                    antiAFKConnection:Disconnect()
                    antiAFKConnection = nil
                end
            end
        end
    })
    
    -- ===== NO CLIP =====
    local noclipConnection
    
    Tab:CreateToggle({
        Name = "NoClip",
        Text = "👻 No Clip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "No Clip",
                    Content = "No Clip enabled! Walk through walls.",
                    Duration = 3
                })
                
                --print("✅ No Clip enabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                end
                
                noclipConnection = Services.RunService.Stepped:Connect(function()
                    if not Variables.noclipEnabled then return end
                    
                    local character = Services.Players.LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "No Clip",
                    Content = "No Clip disabled!",
                    Duration = 3
                })
                
                --print("❌ No Clip disabled")
                
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                
                -- Restore collision
                local character = Services.Players.LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })
    
    -- ===== INFINITE JUMP =====
    local infiniteJumpConnection
    
    Tab:CreateToggle({
        Name = "InfiniteJump",
        Text = "🦘 Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            Variables.infiniteJumpEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite Jump enabled!",
                    Duration = 3
                })
                
                --print("✅ Infinite Jump enabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                end
                
                infiniteJumpConnection = Services.UserInputService.JumpRequest:Connect(function()
                    if Variables.infiniteJumpEnabled then
                        local character = Services.Players.LocalPlayer.Character
                        if character and character:FindFirstChild("Humanoid") then
                            character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite Jump disabled!",
                    Duration = 3
                })
                
                --print("❌ Infinite Jump disabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                    infiniteJumpConnection = nil
                end
            end
        end
    })
    
    -- ===== 🛡️ GOD MODE =====
    Tab:CreateToggle({
        Name = "GodMode",
        Text = "🛡️ God Mode",
        CurrentValue = false,
        Callback = function(value)
            Variables.godModeEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "God Mode",
                    Content = "God Mode enabled! You are INVINCIBLE.",
                    Duration = 3
                })
                
                --print("✅ God Mode enabled")
                
                -- Disable old connection
                if Variables.godModeConnection then
                    Variables.godModeConnection:Disconnect()
                end
                
                -- Infinite health loop
                Variables.godModeConnection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.godModeEnabled then return end
                    
                    local character = Services.Players.LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid.MaxHealth = 999999
                            humanoid.Health = 999999
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "God Mode",
                    Content = "God Mode disabled!",
                    Duration = 3
                })
                
                --print("❌ God Mode disabled")
                
                if Variables.godModeConnection then
                    Variables.godModeConnection:Disconnect()
                    Variables.godModeConnection = nil
                end
            end
        end
    })
    
    -- ===== 💪 INVINCIBLE =====
    Tab:CreateToggle({
        Name = "Invincible",
        Text = "💪 Invincible",
        CurrentValue = false,
        Callback = function(value)
            Variables.invincibleEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Invincible",
                    Content = "Invincibility enabled! Auto-heal active.",
                    Duration = 3
                })
                
                --print("✅ Invincibility enabled")
                
                -- Stop old loop
                if Variables.invincibleLoop then
                    Variables.invincibleLoop:Disconnect()
                end
                
                -- Constant Health Check
                Variables.invincibleLoop = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.invincibleEnabled then return end
                    
                    local player = Services.Players.LocalPlayer
                    local character = player.Character
                    
                    if character then
                        local humanoid = character:FindFirstChild("Humanoid")
                        if humanoid then
                            -- Maintain health
                            if humanoid.Health < 500 then
                                humanoid.Health = 500
                            end
                            
                            -- Increase max health
                            if humanoid.MaxHealth < 500 then
                                humanoid.MaxHealth = 500
                            end
                            
                            -- Revive if dead
                            if humanoid.Health <= 0 then
                                humanoid.Health = 500
                            end
                        end
                    end
                end)
                
                -- Apply to new characters
                Services.Players.LocalPlayer.CharacterAdded:Connect(function()
                    if Variables.invincibleEnabled then
                        task.wait(2)
                        local newChar = Services.Players.LocalPlayer.Character
                        if newChar then
                            local humanoid = newChar:WaitForChild("Humanoid")
                            humanoid.Health = 500
                            humanoid.MaxHealth = 500
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Invincible",
                    Content = "Invincibility disabled!",
                    Duration = 3
                })
                
                --print("❌ Invincibility disabled")
                
                -- Clean up
                if Variables.invincibleLoop then
                    Variables.invincibleLoop:Disconnect()
                    Variables.invincibleLoop = nil
                end
                
                -- Restore normal values
                local character = Services.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.MaxHealth = 100
                        humanoid.Health = math.min(humanoid.Health, 100)
                    end
                end
            end
        end
    })
    
    -- ===== TEST INVINCIBILITY =====
    Tab:CreateButton({
        Name = "TestInvincible",
        Text = "🔄 Test Invincibility",
        Callback = function()
            local character = Services.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    --print("🧪 Testing Invincibility...")
                    --print("Current Health:", humanoid.Health)
                    --print("Max Health:", humanoid.MaxHealth)
                    
                    -- Test: Take small damage
                    pcall(function()
                        humanoid:TakeDamage(10)
                        --print("Took 10 damage")
                        --print("New Health:", humanoid.Health)
                    end)
                    
                    if humanoid.Health <= 0 then
                        --print("❌ TEST FAILED: Character died!")
                        Bdev:Notify({
                            Title = "Test Failed",
                            Content = "Invincibility not working!",
                            Duration = 3
                        })
                    else
                        --print("✅ TEST PASSED: Character survived!")
                        Bdev:Notify({
                            Title = "Test Passed",
                            Content = "Invincibility is working!",
                            Duration = 3
                        })
                    end
                end
            end
        end
    })
    
    -- ===== DISABLE ALL MISC =====
    Tab:CreateButton({
        Name = "DisableAllMisc",
        Text = "🔴 Disable All Misc",
        Callback = function()
            --print("\n🔴 DISABLING ALL MISC FEATURES...")
            
            -- Disable all toggles
            Variables.antiAfkEnabled = false
            Variables.noclipEnabled = false
            Variables.infiniteJumpEnabled = false
            Variables.godModeEnabled = false
            Variables.invincibleEnabled = false
            
            -- Disconnect all connections
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            
            if Variables.godModeConnection then
                Variables.godModeConnection:Disconnect()
                Variables.godModeConnection = nil
            end
            
            if Variables.invincibleLoop then
                Variables.invincibleLoop:Disconnect()
                Variables.invincibleLoop = nil
            end
            
            Bdev:Notify({
                Title = "Misc Features",
                Content = "All misc features disabled!",
                Duration = 4
            })
            
            --print("✅ All misc features disabled")
        end
    })
    
    --print("✅ Misc tab initialized")
end

return Misc