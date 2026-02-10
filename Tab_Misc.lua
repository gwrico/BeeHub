-- ==============================================
-- ⚡ MISC TAB MODULE - DUAL INVINCIBILITY SYSTEM
-- ==============================================

local Misc = {}

function Misc.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables
    local Services = Shared.Services
    
    print("⚡ Initializing Misc tab with dual invincibility...")
    
    -- Tambahkan variabel ke Shared jika belum ada
    if Variables.godModeEnabled == nil then Variables.godModeEnabled = false end
    if Variables.invincibleEnabled == nil then Variables.invincibleEnabled = false end
    Variables.invincibleConnection = nil
    Variables.invincibleCharAdded = nil
    Variables.godModeConnection = nil
    Variables.godModeCharAdded = nil
    
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
                
                print("✅ Anti-AFK enabled")
                
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
                
                print("❌ Anti-AFK disabled")
                
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
                
                print("✅ No Clip enabled")
                
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
                
                print("❌ No Clip disabled")
                
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
                
                print("✅ Infinite Jump enabled")
                
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
                
                print("❌ Infinite Jump disabled")
                
                if infiniteJumpConnection then
                    infiniteJumpConnection:Disconnect()
                    infiniteJumpConnection = nil
                end
            end
        end
    })
    
    -- ===== 🛡️ GOD MODE (FULL POWER) =====
    local function enableGodMode()
        if Variables.godModeConnection then
            Variables.godModeConnection:Disconnect()
        end
        
        Variables.godModeConnection = Services.RunService.Heartbeat:Connect(function()
            if not Variables.godModeEnabled then return end
            
            local player = Services.Players.LocalPlayer
            local character = player.Character
            
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    -- Set health to maximum
                    humanoid.MaxHealth = 99999
                    humanoid.Health = 99999
                    
                    -- Prevent death
                    if humanoid.Health <= 0 then
                        humanoid.Health = 99999
                    end
                    
                    -- Try to disable damage (if possible)
                    pcall(function()
                        for _, connection in pairs(getconnections(humanoid.Died)) do
                            connection:Disable()
                        end
                    end)
                end
            end
        end)
    end
    
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
                
                print("✅ God Mode enabled")
                
                -- Enable god mode
                enableGodMode()
                
                -- Also apply to new characters
                if Variables.godModeCharAdded then
                    Variables.godModeCharAdded:Disconnect()
                end
                
                Variables.godModeCharAdded = Services.Players.LocalPlayer.CharacterAdded:Connect(function()
                    if Variables.godModeEnabled then
                        task.wait(1)
                        enableGodMode()
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "God Mode",
                    Content = "God Mode disabled!",
                    Duration = 3
                })
                
                print("❌ God Mode disabled")
                
                -- Clean up
                if Variables.godModeConnection then
                    Variables.godModeConnection:Disconnect()
                    Variables.godModeConnection = nil
                end
                
                if Variables.godModeCharAdded then
                    Variables.godModeCharAdded:Disconnect()
                    Variables.godModeCharAdded = nil
                end
                
                -- Restore normal health
                local character = Services.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.MaxHealth = 100
                        humanoid.Health = math.min(humanoid.Health, 100)
                        
                        -- Re-enable damage
                        pcall(function()
                            for _, connection in pairs(getconnections(humanoid.Died)) do
                                connection:Enable()
                            end
                        end)
                    end
                end
            end
        end
    })
    
    -- ===== 💪 INVINCIBLE (SAFE MODE) =====
    local function enableInvincible()
        local player = Services.Players.LocalPlayer
        local character = player.Character
        
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                -- Set high health
                humanoid.MaxHealth = 1000
                humanoid.Health = 1000
                
                -- Auto-heal when damaged
                if Variables.invincibleConnection then
                    Variables.invincibleConnection:Disconnect()
                end
                
                Variables.invincibleConnection = humanoid.HealthChanged:Connect(function(newHealth)
                    if Variables.invincibleEnabled and newHealth < 1000 then
                        humanoid.Health = 1000
                    end
                end)
            end
        end
    end
    
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
                
                print("✅ Invincibility enabled")
                
                -- Enable invincibility
                enableInvincible()
                
                -- Apply to new characters
                if Variables.invincibleCharAdded then
                    Variables.invincibleCharAdded:Disconnect()
                end
                
                Variables.invincibleCharAdded = Services.Players.LocalPlayer.CharacterAdded:Connect(function()
                    if Variables.invincibleEnabled then
                        task.wait(1)
                        enableInvincible()
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Invincible",
                    Content = "Invincibility disabled!",
                    Duration = 3
                })
                
                print("❌ Invincibility disabled")
                
                -- Clean up
                if Variables.invincibleConnection then
                    Variables.invincibleConnection:Disconnect()
                    Variables.invincibleConnection = nil
                end
                
                if Variables.invincibleCharAdded then
                    Variables.invincibleCharAdded:Disconnect()
                    Variables.invincibleCharAdded = nil
                end
                
                -- Restore normal health
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
    
    -- ===== DISABLE ALL MISC =====
    Tab:CreateButton({
        Name = "DisableAllMisc",
        Text = "🔴 Disable All Misc",
        Callback = function()
            print("\n🔴 DISABLING ALL MISC FEATURES...")
            
            -- Disable all toggles
            Variables.antiAfkEnabled = false
            Variables.noclipEnabled = false
            Variables.infiniteJumpEnabled = false
            Variables.godModeEnabled = false
            Variables.invincibleEnabled = false
            
            -- Disconnect all connections
            local connections = {
                antiAFKConnection, noclipConnection, infiniteJumpConnection,
                Variables.godModeConnection, Variables.invincibleConnection,
                Variables.godModeCharAdded, Variables.invincibleCharAdded
            }
            
            for _, conn in pairs(connections) do
                if conn then
                    pcall(function() conn:Disconnect() end)
                end
            end
            
            -- Reset variables
            antiAFKConnection = nil
            noclipConnection = nil
            infiniteJumpConnection = nil
            Variables.godModeConnection = nil
            Variables.invincibleConnection = nil
            Variables.godModeCharAdded = nil
            Variables.invincibleCharAdded = nil
            
            Bdev:Notify({
                Title = "Misc Features",
                Content = "All misc features disabled!",
                Duration = 4
            })
            
            print("✅ All misc features disabled")
        end
    })
    
    -- ===== CLEANUP ON RESPAWN =====
    Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        -- Disable auto features on respawn (optional)
        -- Variables.antiAfkEnabled = false
        -- Variables.noclipEnabled = false
        -- Variables.infiniteJumpEnabled = false
        
        -- But keep god mode/invincible if enabled
        if Variables.godModeEnabled then
            task.wait(1)
            enableGodMode()
        end
        
        if Variables.invincibleEnabled then
            task.wait(1)
            enableInvincible()
        end
    end)
    
    print("✅ Misc tab with dual invincibility initialized")
end

return Misc