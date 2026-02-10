-- ==============================================
-- 📍 TELEPORT TAB MODULE - WITH WORKING REFRESH & SEARCH
-- ==============================================

local Teleport = {}

function Teleport.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Functions = Shared.Functions
    
    print("📍 Initializing Teleport tab...")
    
    -- Variables for player list management
    local playerButtons = {}
    local noPlayersLabel = nil
    local playerListLabel = nil
    
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
    
    -- ===== PLAYER SEARCH WITH AUTOCOMPLETE =====
    local targetPlayerName = ""
    local searchResults = {}
    local searchResultButtons = {}
    
    -- Create search section
    Tab:CreateLabel({
        Name = "SearchLabel",
        Text = "🔍 Search & Teleport to Player:"
    })
    
    local searchInput = Tab:CreateInput({
        Name = "PlayerSearchInput",
        PlaceholderText = "Type player name...",
        CurrentValue = "",
        Callback = function(text)
            targetPlayerName = text
            updateSearchResults(text)
        end
    })
    
    -- Function to update search results
    local function updateSearchResults(searchText)
        -- Clear previous search results
        for _, button in pairs(searchResultButtons) do
            if button and button.Destroy then
                button:Destroy()
            end
        end
        searchResultButtons = {}
        
        if searchText == "" then
            return
        end
        
        local searchLower = searchText:lower()
        local resultCount = 0
        
        -- Search for players
        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Name:lower():find(searchLower) then
                resultCount = resultCount + 1
                
                -- Create button for search result
                local button = Tab:CreateButton({
                    Name = "SearchResult_" .. player.Name,
                    Text = "👤 " .. player.Name,
                    Callback = function()
                        teleportToPlayer(player)
                    end
                })
                
                table.insert(searchResultButtons, button)
                
                -- Limit results for performance
                if resultCount >= 10 then
                    break
                end
            end
        end
        
        -- Show "No results" if needed
        if resultCount == 0 and searchText ~= "" then
            local noResultLabel = Tab:CreateLabel({
                Name = "NoSearchResults",
                Text = "No players found matching: '" .. searchText .. "'"
            })
            table.insert(searchResultButtons, noResultLabel)
        end
    end
    
    -- Teleport function
    local function teleportToPlayer(targetPlayer)
        if targetPlayer and targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if targetHRP and humanoidRootPart then
                -- Teleport with offset
                humanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                Bdev:Notify({
                    Title = "Teleport",
                    Content = "Teleported to " .. targetPlayer.Name .. "!",
                    Duration = 3
                })
                searchInput.CurrentValue = ""
                targetPlayerName = ""
                updateSearchResults("") -- Clear search results
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
    
    -- Quick teleport button for current search
    Tab:CreateButton({
        Name = "QuickTP",
        Text = "🚀 Quick Teleport",
        Callback = function()
            if targetPlayerName == "" then
                Bdev:Notify({
                    Title = "Error",
                    Content = "Please enter a player name first!",
                    Duration = 3
                })
                return
            end
            
            -- Find exact or best match
            local bestMatch = nil
            local searchLower = targetPlayerName:lower()
            
            for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    local playerLower = player.Name:lower()
                    
                    -- Exact match
                    if playerLower == searchLower then
                        bestMatch = player
                        break
                    end
                    
                    -- Contains match
                    if playerLower:find(searchLower) then
                        if not bestMatch then
                            bestMatch = player
                        elseif #player.Name < #bestMatch.Name then
                            -- Prefer shorter names (closer match)
                            bestMatch = player
                        end
                    end
                end
            end
            
            if bestMatch then
                teleportToPlayer(bestMatch)
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "Player '" .. targetPlayerName .. "' not found!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== REFRESHABLE PLAYER LIST =====
    Tab:CreateLabel({
        Name = "PlayerListHeader",
        Text = "📋 Online Players:"
    })
    
    -- Function to create/refresh player list
    local function createPlayerList()
        -- Clear existing player buttons
        for _, button in pairs(playerButtons) do
            if button and button.Destroy then
                button:Destroy()
            end
        end
        playerButtons = {}
        
        -- Clear "no players" label if exists
        if noPlayersLabel and noPlayersLabel.Destroy then
            noPlayersLabel:Destroy()
            noPlayersLabel = nil
        end
        
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
        
        -- Show "no players" message if empty
        if playerCount == 0 then
            noPlayersLabel = Tab:CreateLabel({
                Name = "NoPlayersMsg",
                Text = "No other players online"
            })
            table.insert(playerButtons, noPlayersLabel)
        end
        
        return playerCount
    end
    
    -- Initial player list creation
    local initialCount = createPlayerList()
    print("👥 Initial player list created with", initialCount, "players")
    
    -- ===== REFRESH BUTTON =====
    Tab:CreateButton({
        Name = "RefreshPlayerList",
        Text = "🔄 Refresh Player List",
        Callback = function()
            local newCount = createPlayerList()
            Bdev:Notify({
                Title = "Player List",
                Content = "Refreshed! " .. newCount .. " players online",
                Duration = 3
            })
            print("🔄 Player list refreshed. Now", newCount, "players")
        end
    })
    
    -- ===== AUTO REFRESH ON PLAYER JOIN/LEAVE =====
    -- Connect to player events for real-time updates
    local function setupPlayerEvents()
        local Players = Shared.Services.Players
        
        Players.PlayerAdded:Connect(function(player)
            wait(1) -- Wait a bit for player to fully load
            local count = createPlayerList()
            print("➕ Player joined:", player.Name, "- Total:", count)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            local count = createPlayerList()
            print("➖ Player left:", player.Name, "- Total:", count)
        end)
    end
    
    -- Setup player events
    pcall(setupPlayerEvents)
    
    -- ===== TELEPORT TO COORDINATES =====
    Tab:CreateLabel({
        Name = "CoordSection",
        Text = "📍 Teleport to Coordinates:"
    })
    
    local coordX, coordY, coordZ = "", "", ""
    
    Tab:CreateInput({
        Name = "InputX",
        PlaceholderText = "X",
        CurrentValue = "",
        Callback = function(text)
            coordX = text
        end
    })
    
    Tab:CreateInput({
        Name = "InputY",
        PlaceholderText = "Y",
        CurrentValue = "",
        Callback = function(text)
            coordY = text
        end
    })
    
    Tab:CreateInput({
        Name = "InputZ",
        PlaceholderText = "Z",
        CurrentValue = "",
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
                    Content = string.format("Teleported to (%.1f, %.1f, %.1f)", x, y, z),
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
    
    -- ===== QUICK LOCATIONS (OPTIONAL) =====
    Tab:CreateLabel({
        Name = "QuickLocations",
        Text = "⚡ Quick Locations:"
    })
    
    local quickLocations = {
        {"🔼 High Above", Vector3.new(0, 500, 0)},
        {"📍 Origin", Vector3.new(0, 5, 0)},
        {"🔺 Pyramid", Vector3.new(100, 50, 100)},
        {"⬅️ Left Side", Vector3.new(-200, 50, 0)},
        {"➡️ Right Side", Vector3.new(200, 50, 0)}
    }
    
    for i, location in ipairs(quickLocations) do
        local name, position = location[1], location[2]
        
        Tab:CreateButton({
            Name = "QuickLoc_" .. i,
            Text = name,
            Callback = function()
                local player = game.Players.LocalPlayer
                local character = player.Character
                local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    if Functions.teleportToPosition then
                        Functions.teleportToPosition(position)
                    else
                        humanoidRootPart.CFrame = CFrame.new(position)
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
    
    print("✅ Teleport tab initialized with refresh & search features")
end

return Teleport