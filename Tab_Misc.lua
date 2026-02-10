-- ==============================================
-- ⚡ MISC TAB MODULE - SIMPLIFIED
-- ==============================================

local Misc = {}

function Misc.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables
    local Services = Shared.Services
    
    print("⚡ Initializing Misc tab...")
    
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
    
    -- ===== CLEANUP =====
    Services.Players.LocalPlayer.CharacterAdded:Connect(function()
        Variables.antiAfkEnabled = false
        Variables.noclipEnabled = false
        Variables.infiniteJumpEnabled = false
        
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
    end)
    
    print("✅ Misc tab initialized")
end

return Misc