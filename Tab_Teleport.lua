-- ==============================================
-- 📍 TELEPORT TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3
-- ==============================================

local Teleport = {}

function Teleport.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    print("📍 Initializing Teleport tab for SimpleGUI v6.3...")
    
    -- Variables for player list management
    local playerButtons = {}
    
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
                    humanoidRootPart.CFrame = CFrame.new(spawn.Position)
                    teleported = true
                elseif spawn:IsA("Model") then
                    for _, part in pairs(spawn:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Name:find("Spawn") or part.Name:find("Start")) then
                            humanoidRootPart.CFrame = CFrame.new(part.Position)
                            teleported = true
                            break
                        end
                    end
                end
            end
            
            if not teleported then
                -- Default spawn
                humanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 50, 0))
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
    Tab:CreateLabel({
        Name = "SearchLabel",
        Text = "🔍 Search Player:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local searchInputFrame = Instance.new("Frame")
    searchInputFrame.Name = "SearchInputFrame"
    searchInputFrame.Size = UDim2.new(0.9, 0, 0, 40)
    searchInputFrame.BackgroundTransparency = 1
    searchInputFrame.LayoutOrder = 5
    searchInputFrame.Parent = Tab.Content
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "PlayerSearchBox"
    SearchBox.Size = UDim2.new(0.7, 0, 1, 0)
    SearchBox.Position = UDim2.new(0, 0, 0, 0)
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Type player name..."
    SearchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
    SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SearchBox.BackgroundTransparency = 0
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = searchInputFrame
    
    local SearchBoxCorner = Instance.new("UICorner")
    SearchBoxCorner.CornerRadius = UDim.new(0, 8)
    SearchBoxCorner.Parent = SearchBox
    
    local SearchBoxPadding = Instance.new("UIPadding")
    SearchBoxPadding.PaddingLeft = UDim.new(0, 12)
    SearchBoxPadding.PaddingRight = UDim.new(0, 12)
    SearchBoxPadding.Parent = SearchBox
    
    local SearchButton = Instance.new("TextButton")
    SearchButton.Name = "SearchButton"
    SearchButton.Size = UDim2.new(0.25, 0, 1, 0)
    SearchButton.Position = UDim2.new(0.75, 5, 0, 0)
    SearchButton.Text = "🔍"
    SearchButton.TextColor3 = Color3.fromRGB(240, 240, 245)
    SearchButton.BackgroundColor3 = Color3.fromRGB(98, 147, 255)
    SearchButton.BackgroundTransparency = 0
    SearchButton.TextSize = 14
    SearchButton.Font = Enum.Font.SourceSansSemibold
    SearchButton.AutoButtonColor = false
    SearchButton.Parent = searchInputFrame
    
    local SearchButtonCorner = Instance.new("UICorner")
    SearchButtonCorner.CornerRadius = UDim.new(0, 8)
    SearchButtonCorner.Parent = SearchButton
    
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
                return true
            else
                Bdev:Notify({
                    Title = "Error",
                    Content = "Cannot teleport to " .. targetPlayer.Name .. "!",
                    Duration = 3
                })
                return false
            end
        else
            Bdev:Notify({
                Title = "Error",
                Content = targetPlayer.Name .. " has no character!",
                Duration = 3
            })
            return false
        end
    end
    
    -- Search results display
    local searchResultsContainer = Instance.new("Frame")
    searchResultsContainer.Name = "SearchResultsContainer"
    searchResultsContainer.Size = UDim2.new(0.9, 0, 0, 0)
    searchResultsContainer.BackgroundTransparency = 1
    searchResultsContainer.LayoutOrder = 6
    searchResultsContainer.Visible = false
    searchResultsContainer.Parent = Tab.Content
    
    local function clearSearchResults()
        for _, child in pairs(searchResultsContainer:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        searchResultsContainer.Visible = false
        searchResultsContainer.Size = UDim2.new(0.9, 0, 0, 0)
    end
    
    local function showSearchResults(players)
        clearSearchResults()
        
        if #players == 0 then
            local noResults = Instance.new("TextLabel")
            noResults.Name = "NoResults"
            noResults.Size = UDim2.new(1, 0, 0, 30)
            noResults.Text = "No players found!"
            noResults.TextColor3 = Color3.fromRGB(240, 240, 245)
            noResults.BackgroundTransparency = 1
            noResults.TextSize = 14
            noResults.Font = Enum.Font.SourceSans
            noResults.Parent = searchResultsContainer
            
            searchResultsContainer.Size = UDim2.new(0.9, 0, 0, 35)
            searchResultsContainer.Visible = true
            return
        end
        
        local resultsLabel = Instance.new("TextLabel")
        resultsLabel.Name = "ResultsLabel"
        resultsLabel.Size = UDim2.new(1, 0, 0, 25)
        resultsLabel.Text = "Found " .. #players .. " player(s):"
        resultsLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        resultsLabel.BackgroundTransparency = 1
        resultsLabel.TextSize = 13
        resultsLabel.Font = Enum.Font.SourceSansSemibold
        resultsLabel.Parent = searchResultsContainer
        
        local totalHeight = 30
        for i, player in ipairs(players) do
            local playerButton = Instance.new("TextButton")
            playerButton.Name = "Result_" .. player.Name
            playerButton.Size = UDim2.new(1, 0, 0, 35)
            playerButton.Position = UDim2.new(0, 0, 0, totalHeight)
            playerButton.Text = "👤 " .. player.Name
            playerButton.TextColor3 = Color3.fromRGB(240, 240, 245)
            playerButton.BackgroundColor3 = Color3.fromRGB(65, 65, 85)
            playerButton.BackgroundTransparency = 0
            playerButton.TextSize = 14
            playerButton.Font = Enum.Font.SourceSansSemibold
            playerButton.AutoButtonColor = false
            playerButton.Parent = searchResultsContainer
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 6)
            buttonCorner.Parent = playerButton
            
            -- Hover effect
            playerButton.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(playerButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                }):Play()
            end)
            
            playerButton.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(playerButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(65, 65, 85)
                }):Play()
            end)
            
            playerButton.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
                clearSearchResults()
                SearchBox.Text = ""
            end)
            
            totalHeight = totalHeight + 40
        end
        
        searchResultsContainer.Size = UDim2.new(0.9, 0, 0, totalHeight + 10)
        searchResultsContainer.Visible = true
    end
    
    SearchButton.MouseButton1Click:Connect(function()
        local searchText = SearchBox.Text
        if searchText == "" then
            Bdev:Notify({
                Title = "Search",
                Content = "Please enter a player name!",
                Duration = 3
            })
            clearSearchResults()
            return
        end
        
        local searchLower = searchText:lower()
        local foundPlayers = {}
        
        -- Search players
        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Name:lower():find(searchLower) then
                table.insert(foundPlayers, player)
            end
        end
        
        showSearchResults(foundPlayers)
    end)
    
    SearchBox.FocusLost:Connect(function()
        if SearchBox.Text ~= "" then
            SearchButton.MouseButton1Click:Fire()
        end
    end)
    
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
    
    -- Close search results when clicking outside
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if searchResultsContainer.Visible then
                local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                local pos = Vector2.new(mouse.X, mouse.Y)
                
                local searchBoxAbs = SearchBox.AbsolutePosition
                local searchBoxSize = SearchBox.AbsoluteSize
                local resultsAbs = searchResultsContainer.AbsolutePosition
                local resultsSize = searchResultsContainer.AbsoluteSize
                
                local isInSearchBox = pos.X >= searchBoxAbs.X and pos.X <= searchBoxAbs.X + searchBoxSize.X and
                                     pos.Y >= searchBoxAbs.Y and pos.Y <= searchBoxAbs.Y + searchBoxSize.Y
                
                local isInResults = pos.X >= resultsAbs.X and pos.X <= resultsAbs.X + resultsSize.X and
                                   pos.Y >= resultsAbs.Y and pos.Y <= resultsAbs.Y + resultsSize.Y
                
                if not isInSearchBox and not isInResults then
                    clearSearchResults()
                end
            end
        end
    end)
    
    print("✅ Teleport tab initialized")
end

return Teleport