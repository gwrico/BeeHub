-- ==============================================
-- 👤 PLAYER MODS TAB MODULE
-- ==============================================

local PlayerMods = {}

function PlayerMods.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
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
                Rayfield.Notify({
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
                Rayfield.Notify({
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
    
    -- ===== JUMP HACK =====
    local customJump = 150
    local jumpToggle = Tab:CreateToggle({
        Name = "JumpHack",
        Text = "🦘 Jump Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.jumpHackEnabled = value
            
            if value then
                Rayfield.Notify({
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
                Rayfield.Notify({
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
    
    -- ===== FLY HACK =====
    local flySpeed = 50
    local flyToggle = Tab:CreateToggle({
        Name = "FlyHack",
        Text = "✈️ Fly Hack",
        CurrentValue = false,
        Callback = function(value)
            Variables.flyEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Fly Hack",
                    Content = "Fly hack enabled! (" .. flySpeed .. " speed)",
                    Duration = 3
                })
                
                print("✅ Fly hack enabled:", flySpeed)
                
                -- Initialize fly variables
                local player = game.Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                local humanoid = character:WaitForChild("Humanoid")
                
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
                        flyConnection:Disconnect()
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
                
                -- Handle character respawn
                local characterAddedConnection
                characterAddedConnection = player.CharacterAdded:Connect(function(newChar)
                    character = newChar
                    humanoid = newChar:WaitForChild("Humanoid")
                    
                    if Variables.flyEnabled then
                        wait(1)
                        if bodyVelocity then bodyVelocity:Destroy() end
                        bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                        bodyVelocity.P = 1000
                        bodyVelocity.Name = "FlyHackBodyVelocity"
                        bodyVelocity.Parent = newChar.PrimaryPart or newChar:FindFirstChild("HumanoidRootPart")
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Fly Hack",
                    Content = "Fly hack disabled!",
                    Duration = 3
                })
                
                print("❌ Fly hack disabled")
                
                -- Clean up fly objects
                local char = game.Players.LocalPlayer.Character
                if char then
                    -- Remove body velocity
                    local bodyVelocity = char:FindFirstChild("FlyHackBodyVelocity")
                    if bodyVelocity then
                        bodyVelocity:Destroy()
                    end
                    
                    -- Reset platform stand
                    if char:FindFirstChild("Humanoid") then
                        char.Humanoid.PlatformStand = false
                    end
                end
            end
        end
    })
    
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
    
    -- ===== CHARACTER MODIFIER =====
    
    -- Character Size Slider
    local characterSize = 1
    local sizeSlider = Tab:CreateSlider({
        Name = "Character Size",
        Range = {0.1, 10},
        Increment = 0.1,
        CurrentValue = 1,
        Callback = function(value)
            characterSize = value
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                -- Scale character parts
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * (value / characterSize)
                    end
                end
                
                -- Scale humanoid if it's a Scale instance
                if humanoid:FindFirstChild("BodyDepthScale") then
                    humanoid.BodyDepthScale.Value = value
                    humanoid.BodyWidthScale.Value = value
                    humanoid.BodyHeightScale.Value = value
                    humanoid.HeadScale.Value = value
                end
                
                print("📏 Character size set to:", value)
            end
        end
    })
    
    -- Reset Size Button
    Tab:CreateButton({
        Name = "ResetSize",
        Text = "🔄 Reset Size",
        Callback = function()
            characterSize = 1
            sizeSlider:Set(1)
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                if humanoid:FindFirstChild("BodyDepthScale") then
                    humanoid.BodyDepthScale.Value = 1
                    humanoid.BodyWidthScale.Value = 1
                    humanoid.BodyHeightScale.Value = 1
                    humanoid.HeadScale.Value = 1
                end
            end
            
            Rayfield.Notify({
                Title = "Character Size",
                Content = "Character size reset to normal!",
                Duration = 3
            })
            
            print("✅ Character size reset")
        end
    })
    
    -- Invisible Character Toggle
    Tab:CreateToggle({
        Name = "Invisible",
        Text = "👻 Invisible Character",
        CurrentValue = false,
        Callback = function(value)
            Variables.invisibleEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Invisible",
                    Content = "Character is now invisible!",
                    Duration = 3
                })
                
                print("✅ Invisible mode enabled")
                
                local connection
                connection = Services.RunService.Heartbeat:Connect(function()
                    if not Variables.invisibleEnabled then
                        connection:Disconnect()
                        return
                    end
                    
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        -- Make all parts transparent
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 1
                                if part:FindFirstChildOfClass("Decal") then
                                    part:FindFirstChildOfClass("Decal").Transparency = 1
                                end
                            elseif part:IsA("Accessory") then
                                local handle = part:FindFirstChild("Handle")
                                if handle and handle:IsA("BasePart") then
                                    handle.Transparency = 1
                                end
                            end
                        end
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Invisible",
                    Content = "Character is now visible!",
                    Duration = 3
                })
                
                print("❌ Invisible mode disabled")
                
                local char = game.Players.LocalPlayer.Character
                if char then
                    -- Reset transparency
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Transparency = 0
                            if part:FindFirstChildOfClass("Decal") then
                                part:FindFirstChildOfClass("Decal").Transparency = 0
                            end
                        elseif part:IsA("Accessory") then
                            local handle = part:FindFirstChild("Handle")
                            if handle and handle:IsA("BasePart") then
                                handle.Transparency = 0
                            end
                        end
                    end
                end
            end
        end
    })
    
    -- ===== RAINBOW CHARACTER =====
    
    -- Rainbow Character Toggle
    local rainbowSpeed = 1
    Tab:CreateToggle({
        Name = "RainbowCharacter",
        Text = "🌈 Rainbow Character",
        CurrentValue = false,
        Callback = function(value)
            Variables.rainbowCharacterEnabled = value
            
            if value then
                Rayfield.Notify({
                    Title = "Rainbow Character",
                    Content = "Rainbow mode enabled!",
                    Duration = 3
                })
                
                print("✅ Rainbow character enabled")
                
                local hue = 0
                local connection
                connection = Services.RunService.Heartbeat:Connect(function(deltaTime)
                    if not Variables.rainbowCharacterEnabled then
                        connection:Disconnect()
                        -- Reset colors
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.fromRGB(255, 255, 255)
                                end
                            end
                        end
                        return
                    end
                    
                    -- Update hue
                    hue = (hue + (deltaTime * rainbowSpeed)) % 1
                    
                    -- Calculate rainbow color
                    local color = Color3.fromHSV(hue, 1, 1)
                    
                    -- Apply to character
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = color
                                
                                -- Also change particle colors if they exist
                                for _, particle in pairs(part:GetChildren()) do
                                    if particle:IsA("ParticleEmitter") then
                                        particle.Color = ColorSequence.new(color)
                                    end
                                end
                            end
                        end
                    end
                end)
                
            else
                Rayfield.Notify({
                    Title = "Rainbow Character",
                    Content = "Rainbow mode disabled!",
                    Duration = 3
                })
                
                print("❌ Rainbow character disabled")
                
                -- Reset character colors
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end
            end
        end
    })
    
    -- Rainbow Speed Slider
    Tab:CreateSlider({
        Name = "Rainbow Speed",
        Range = {0.1, 10},
        Increment = 0.1,
        CurrentValue = 1,
        Callback = function(value)
            rainbowSpeed = value
            print("🌈 Rainbow speed set to:", value)
        end
    })
    
    -- Reset Colors Button
    Tab:CreateButton({
        Name = "ResetColors",
        Text = "🎨 Reset Colors",
        Callback = function()
            Variables.rainbowCharacterEnabled = false
            
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
            
            Rayfield.Notify({
                Title = "Colors",
                Content = "Character colors reset to default!",
                Duration = 3
            })
            
            print("✅ Character colors reset")
        end
    })
    
    -- ===== NOCLIP =====
    Tab:CreateToggle({
        Name = "Noclip",
        Text = "👻 Noclip",
        CurrentValue = false,
        Callback = function(value)
            Variables.noclipEnabled = value
            
            if value then
                Rayfield.Notify({
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
                Rayfield.Notify({
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
    
    -- ===== INFINITE JUMP =====
    Tab:CreateToggle({
        Name = "InfiniteJump",
        Text = "∞ Infinite Jump",
        CurrentValue = false,
        Callback = function(value)
            Variables.infiniteJumpEnabled = value
            
            if value then
                Rayfield.Notify({
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
                Rayfield.Notify({
                    Title = "Infinite Jump",
                    Content = "Infinite jump disabled!",
                    Duration = 3
                })
                
                print("❌ Infinite jump disabled")
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
            Variables.rainbowCharacterEnabled = false
            Variables.invisibleEnabled = false
            Variables.autoMineEnabled = false
            Variables.autoPunchEnabled = false
            
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
                
                -- Reset size and colors
                if char.Humanoid:FindFirstChild("BodyDepthScale") then
                    char.Humanoid.BodyDepthScale.Value = 1
                    char.Humanoid.BodyWidthScale.Value = 1
                    char.Humanoid.BodyHeightScale.Value = 1
                    char.Humanoid.HeadScale.Value = 1
                end
                
                -- Reset colors
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = Color3.fromRGB(255, 255, 255)
                        part.Transparency = 0
                    end
                end
            end
            
            Rayfield.Notify({
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