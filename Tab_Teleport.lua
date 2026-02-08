-- ==============================================
-- 📍 TELEPORT TAB MODULE
-- ==============================================

local Teleport = {}

function Teleport.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Rayfield = Dependencies.Rayfield
    
    local Functions = Shared.Functions
    
    print("📍 Initializing Teleport tab...")
    
    -- ===== TP TO SPAWN =====
    Tab:CreateButton({
        Name = "TPSpawn",
        Text = "🏠 TP to Spawn",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local spawn = Shared.Services.Workspace:FindFirstChild("Spawn") or 
                         Shared.Services.Workspace:FindFirstChild("Start") or
                         Shared.Services.Workspace:FindFirstChild("Lobby")
            
            if spawn then
                if spawn:IsA("BasePart") then
                    Functions.teleportToPosition(spawn.Position)
                elseif spawn:IsA("Model") then
                    for _, part in pairs(spawn:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name:find("Spawn") then
                            Functions.teleportToPosition(part.Position)
                            break
                        end
                    end
                end
                print("📍 Teleported to spawn")
                Rayfield.Notify({
                    Title = "Teleport",
                    Content = "Teleported to spawn!",
                    Duration = 3
                })
            else
                Functions.teleportToPosition(Vector3.new(0, 50, 0))
                print("📍 Teleported to default spawn (0,50,0)")
                Rayfield.Notify({
                    Title = "Teleport",
                    Content = "Teleported to default spawn!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== TP TO PLAYER =====
    local targetPlayerName = ""
    Tab:CreateInput({
        Name = "PlayerInput",
        PlaceholderText = "Enter player name",
        CurrentValue = "",
        Callback = function(text)
            targetPlayerName = text
        end
    })
    
    Tab:CreateButton({
        Name = "TPToPlayer",
        Text = "👤 TP to Player",
        Callback = function()
            if targetPlayerName == "" then
                Rayfield.Notify({
                    Title = "Error",
                    Content = "Please enter a player name!",
                    Duration = 3
                })
                return
            end
            
            local targetPlayer = Shared.Services.Players:FindFirstChild(targetPlayerName)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local player = game.Players.LocalPlayer
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if targetHRP and humanoidRootPart then
                    humanoidRootPart.CFrame = targetHRP.CFrame
                    print("📍 Teleported to player:", targetPlayerName)
                    Rayfield.Notify({
                        Title = "Teleport",
                        Content = "Teleported to " .. targetPlayerName .. "!",
                        Duration = 3
                    })
                else
                    Rayfield.Notify({
                        Title = "Error",
                        Content = "Could not teleport to player!",
                        Duration = 3
                    })
                end
            else
                Rayfield.Notify({
                    Title = "Error",
                    Content = "Player '" .. targetPlayerName .. "' not found!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== PLAYER LIST =====
    Tab:CreateLabel("📋 Online Players:")
    
    local function createPlayerList()
        local playerCount = 0
        
        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                Tab:CreateButton({
                    Name = "TP_" .. player.Name,
                    Text = "👤 " .. player.Name,
                    Callback = function()
                        if player.Character then
                            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            local localPlayer = game.Players.LocalPlayer
                            local character = localPlayer.Character
                            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                            
                            if targetHRP and humanoidRootPart then
                                humanoidRootPart.CFrame = targetHRP.CFrame
                                print("📍 Teleported to player:", player.Name)
                                Rayfield.Notify({
                                    Title = "Teleport",
                                    Content = "Teleported to " .. player.Name .. "!",
                                    Duration = 3
                                })
                            else
                                Rayfield.Notify({
                                    Title = "Error",
                                    Content = "Cannot teleport to " .. player.Name .. "!",
                                    Duration = 3
                                })
                            end
                        else
                            Rayfield.Notify({
                                Title = "Error",
                                Content = player.Name .. " has no character!",
                                Duration = 3
                            })
                        end
                    end
                })
                
                playerCount = playerCount + 1
            end
        end
        
        if playerCount == 0 then
            Tab:CreateLabel("No other players online")
        end
        
        print("👥 Created", playerCount, "player teleport buttons")
    end
    
    -- Create initial player list
    createPlayerList()
    
    -- Refresh button
    Tab:CreateButton({
        Name = "RefreshPlayers",
        Text = "🔄 Refresh Player List",
        Callback = function()
            Rayfield.Notify({
                Title = "Refresh",
                Content = "Please re-open Teleport tab to refresh player list",
                Duration = 4
            })
            print("🔄 Player list refresh requested - re-open tab")
        end
    })
    
    print("✅ Teleport tab initialized")
end

return Teleport
