-- ==============================================
-- 📍 TELEPORT TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3
-- ==============================================

local Teleport = {}

function Teleport.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    local GUI = Dependencies.GUI  -- ✅ ADDED: Access to SimpleGUI
    
    local Functions = Shared.Functions or {}
    
    print("📍 Initializing Teleport tab for SimpleGUI v6.3...")
    
    -- Variables for player list management
    local playerButtons = {}
    local searchResultButtons = {}
    
    -- ===== TP TO SPAWN =====
    Tab:CreateButton({
        Name = "TPSpawn",
        Text = "🏠 TP to Spawn",
        Callback = function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            if not character then 
                Bdev:Notify({
                    Title = "Error",
                    Content = "Character not found!",
                    Duration = 3
                })
                return 
            end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then 
                Bdev:Notify({
                    Title = "Error",
                    Content = "HumanoidRootPart not found!",
                    Duration = 3
                })
                return 
            end
            
            -- Find spawn location
            local spawn = Shared.Services.Workspace:FindFirstChild("Spawn") or 
                         Shared.Services.Workspace:FindFirstChild("Start") or
                         Shared.Services.Workspace:FindFirstChild("Lobby") or
                         Shared.Services.Workspace:FindFirstChild("SpawnLocation")
            
            local teleported = false
            
            if spawn then
                if spawn:IsA("BasePart") then
                    if Functions.teleportToPosition then
                        Functions.teleportToPosition(spawn.Position)
                    else
                        humanoidRootPart.CFrame = CFrame.new(spawn.Position)
                    end
                    teleported = true
                elseif spawn:IsA("Model") then
                    for _, part in pairs(spawn:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Name:find("Spawn") or part.Name:find("Start")) then
                            if Functions.teleportToPosition then
                                Functions.teleportToPosition(part.Position)
                            else
                                humanoidRootPart.CFrame = CFrame.new(part.Position)
                            end
                            teleported = true
                            break
                        end
                    end
                end
            end
            
            if not teleported then
                -- Default spawn
                if Functions.teleportToPosition then
                    Functions.teleportToPosition(Vector3.new(0, 50, 0))
                else
                    humanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 50, 0))
                end
                Bdev:Notify({
                    Title = "Teleport",
                    Content = "Teleported to default spawn!",
                    Duration = 3
                })
            else
                Bdev:Notify({
                    Title = "Teleport",
                    Content = "Teleported to spawn!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== PLAYER SEARCH SECTION =====
    local targetPlayerName = ""
    
    Tab:CreateLabel({
        Name = "SearchLabel",
        Text = "🔍 Search Player:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local searchInput = Tab:CreateInput({
        Name = "PlayerSearch",
        PlaceholderText = "Type player name...",
        CurrentValue = "",
        Callback = function(text)
            targetPlayerName = text
        end
    })
    
    -- Search button
    Tab:CreateButton({
        Name = "SearchButton",
        Text = "🔍 Search",
        Callback = function()
            if targetPlayerName == "" then
                Bdev:Notify({
                    Title = "Search",
                    Content = "Please enter a player name!",
                    Duration = 3
                })
                return
            end
            
            -- Clear old results
            for _, button in pairs(searchResultButtons) do
                if button and button.Destroy then
                    pcall(function()
                        button:Destroy()
                    end)
                end
            end
            searchResultButtons = {}
            
            local searchLower = targetPlayerName:lower()
            local foundPlayers = {}
            
            -- Search players
            for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Name:lower():find(searchLower) then
                    table.insert(foundPlayers, player)
                end
            end
            
            if #foundPlayers > 0 then
                Tab:CreateLabel({
                    Name = "ResultsLabel",
                    Text = "Found " .. #foundPlayers .. " player(s):"
                })
                
                for _, player in ipairs(foundPlayers) do
                    local button = Tab:CreateButton({
                        Name = "Result_" .. player.Name,
                        Text = "👤 " .. player.Name,
                        Callback = function()
                            teleportToPlayer(player)
                        end
                    })
                    table.insert(searchResultButtons, button)
                end
            else
                local label = Tab:CreateLabel({
                    Name = "NoResults",
                    Text = "No players found for: '" .. targetPlayerName .. "'"
                })
                table.insert(searchResultButtons, label)
            end
        end
    })
    
    -- Teleport function
    local function teleportToPlayer(targetPlayer)
        if targetPlayer and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and humanoidRootPart then
                humanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                Bdev:Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. targetPlayer.Name .. "!",
                    Duration = 3
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "Cannot teleport to " .. targetPlayer.Name .. "!",
                    Duration = 3
                })
            end
        else
            Bdev:Notify({
                Title = "Error",
                Content = targetPlayer.Name .. " has no character!",
                Duration = 3
            })
        end
    end
    
    -- ===== PLAYER LIST =====
    Tab:CreateLabel({
        Name = "PlayerListHeader",
        Text = "📋 Online Players:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- Function to refresh player list
    local function refreshPlayerList()
        -- Clear old buttons
        for _, button in pairs(playerButtons) do
            if button and button.Destroy then
                pcall(function()
                    button:Destroy()
                end)
            end
        end
        playerButtons = {}
        
        local playerCount = 0
        
        -- Create buttons for each player
        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                playerCount = playerCount + 1
                
                local button = Tab:CreateButton({
                    Name = "Player_" .. player.Name,
                    Text = "👤 " .. player.Name,
                    Callback = function()
                        teleportToPlayer(player)
                    end
                })
                
                table.insert(playerButtons, button)
            end
        end
        
        if playerCount == 0 then
            local label = Tab:CreateLabel({
                Name = "NoPlayers",
                Text = "No other players online"
            })
            table.insert(playerButtons, label)
        end
        
        return playerCount
    end
    
    -- Initial load
    local initialCount = refreshPlayerList()
    print("👥 Player list created:", initialCount, "players")
    
    -- Refresh button
    Tab:CreateButton({
        Name = "RefreshList",
        Text = "🔄 Refresh List",
        Callback = function()
            local count = refreshPlayerList()
            Bdev:Notify({
                Title = "Player List",
                Content = "Refreshed! " .. count .. " players online",
                Duration = 3
            })
            print("🔄 Player list refreshed:", count, "players")
        end
    })
    
    -- ===== COORDINATE TELEPORT =====
    Tab:CreateLabel({
        Name = "CoordLabel",
        Text = "📍 Coordinates:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local coordX, coordY, coordZ = "0", "0", "0"
    
    local xInput = Tab:CreateInput({
        Name = "CoordX",
        PlaceholderText = "X",
        CurrentValue = "0",
        Callback = function(text)
            coordX = text
        end
    })
    
    local yInput = Tab:CreateInput({
        Name = "CoordY",
        PlaceholderText = "Y",
        CurrentValue = "0",
        Callback = function(text)
            coordY = text
        end
    })
    
    local zInput = Tab:CreateInput({
        Name = "CoordZ",
        PlaceholderText = "Z",
        CurrentValue = "0",
        Callback = function(text)
            coordZ = text
        end
    })
    
    Tab:CreateButton({
        Name = "TeleportCoords",
        Text = "📍 Teleport to Coordinates",
        Callback = function()
            local x = tonumber(coordX) or 0
            local y = tonumber(coordY) or 0
            local z = tonumber(coordZ) or 0
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                if Functions.teleportToPosition then
                    Functions.teleportToPosition(Vector3.new(x, y, z))
                else
                    humanoidRootPart.CFrame = CFrame.new(Vector3.new(x, y, z))
                end
                
                Bdev:Notify({
                    Title = "Teleport",
                    Content = "Teleported to (" .. x .. ", " .. y .. ", " .. z .. ")",
                    Duration = 3
                })
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "Character not found!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== QUICK LOCATIONS =====
    Tab:CreateLabel({
        Name = "QuickLocLabel",
        Text = "⚡ Quick Locations:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local quickLocations = {
        {"🔼 High Up", Vector3.new(0, 500, 0)},
        {"📍 Origin", Vector3.new(0, 5, 0)},
        {"⬅️ Left", Vector3.new(-200, 50, 0)},
        {"➡️ Right", Vector3.new(200, 50, 0)},
        {"🔙 Back", Vector3.new(0, 50, -200)}
    }
    
    for i, location in ipairs(quickLocations) do
        local name, pos = location[1], location[2]
        
        Tab:CreateButton({
            Name = "Quick_" .. i,
            Text = name,
            Callback = function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    if Functions.teleportToPosition then
                        Functions.teleportToPosition(pos)
                    else
                        humanoidRootPart.CFrame = CFrame.new(pos)
                    end
                    
                    Bdev:Notify({
                        Title = "Teleport",
                        Content = "Teleported to " .. name,
                        Duration = 3
                    })
                end
            end
        })
    end
    
    -- ===== AUTO-TP TO EGGS (OPTIONAL) =====
    Tab:CreateLabel({
        Name = "EggTPLabel",
        Text = "🥚 Auto-TP to Eggs:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local autoTPEnabled = false
    local autoTPConnection = nil
    
    Tab:CreateToggle({
        Name = "AutoTPEggs",
        Text = "🔁 Auto-TP to Nearest Egg",
        CurrentValue = false,
        Callback = function(value)
            autoTPEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Auto-TP",
                    Content = "Auto-TP enabled! Teleporting to nearest egg...",
                    Duration = 3
                })
                
                if autoTPConnection then
                    autoTPConnection:Disconnect()
                end
                
                autoTPConnection = Shared.Services.RunService.Heartbeat:Connect(function()
                    if not autoTPEnabled then return end
                    
                    if Functions.findClosestEgg then
                        local egg, distance = Functions.findClosestEgg(500)
                        if egg and distance < 100 then
                            local player = game.Players.LocalPlayer
                            local character = player.Character
                            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                            
                            if humanoidRootPart then
                                humanoidRootPart.CFrame = CFrame.new(egg.Position)
                            end
                        end
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Auto-TP",
                    Content = "Auto-TP disabled!",
                    Duration = 3
                })
                
                if autoTPConnection then
                    autoTPConnection:Disconnect()
                    autoTPConnection = nil
                end
            end
        end
    })
    
    -- ===== CLEANUP =====
    -- Auto-refresh on player join/leave
    local Players = Shared.Services.Players
    
    Players.PlayerAdded:Connect(function(player)
        task.wait(2)
        refreshPlayerList()
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        refreshPlayerList()
    end)
    
    print("✅ Teleport tab initialized for SimpleGUI v6.3")
end

return Teleport