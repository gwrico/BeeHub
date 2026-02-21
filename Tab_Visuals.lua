-- ==============================================
-- 👁️ VISUALS TAB MODULE - COMPATIBLE WITH SIMPLEGUI v6.3
-- ==============================================

local Visuals = {}

function Visuals.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables
    local Functions = Shared.Functions or {}
    
    --print("👁️ Initializing Visuals tab for SimpleGUI v6.3...")
    
    -- ===== EGG ESP =====
    local eggHighlights = {}
    
    Tab:CreateToggle({
        Name = "EggESP",
        Text = "🥚 Egg ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.eggESPEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Egg ESP",
                    Content = "Egg ESP enabled! Find eggs easily",
                    Duration = 3
                })
                
                --print("✅ Egg ESP enabled")
                
                local rarityColors = {
                    [1] = Color3.fromRGB(184, 115, 51),    -- Copper
                    [2] = Color3.fromRGB(192, 192, 192),   -- Silver
                    [3] = Color3.fromRGB(255, 215, 0),     -- Gold
                    [4] = Color3.fromRGB(80, 200, 120),    -- Emerald
                    [5] = Color3.fromRGB(224, 17, 95),     -- Ruby
                    [6] = Color3.fromRGB(185, 242, 255),   -- Diamond
                    [7] = Color3.fromRGB(16, 20, 31),      -- Obsidian
                    [8] = Color3.fromRGB(148, 0, 211)      -- Mystery
                }
                
                -- Clear existing highlights
                for _, hl in pairs(eggHighlights) do
                    if Functions.safeDestroy then
                        Functions.safeDestroy(hl)
                    elseif hl and hl.Parent then
                        pcall(function() 
                            hl:Destroy() 
                        end)
                    end
                end
                eggHighlights = {}
                
                local highlighted = 0
                
                -- Find all eggs in workspace
                for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                        local objName = obj.Name
                        
                        -- Check against EggData
                        for eggName, eggData in pairs(Shared.EggData) do
                            -- Flexible pattern matching
                            local patterns = {
                                eggName,
                                eggName:gsub(" Egg", ""),
                                eggName:gsub(" Lucky Block", ""),
                                eggName:lower(),
                                eggName:gsub(" Egg", ""):lower()
                            }
                            
                            local isMatch = false
                            for _, pattern in ipairs(patterns) do
                                if objName:lower():find(pattern:lower(), 1, true) then
                                    isMatch = true
                                    break
                                end
                            end
                            
                            if isMatch then
                                local highlight
                                
                                -- Method 1: Use Functions.createHighlight if available
                                if Functions.createHighlight then
                                    highlight = Functions.createHighlight(
                                        obj, 
                                        rarityColors[eggData.rarityId] or Color3.new(1, 1, 1),
                                        0.5
                                    )
                                else
                                    -- Method 2: Create highlight manually
                                    highlight = Instance.new("Highlight")
                                    highlight.Name = "EggESP_" .. eggName
                                    highlight.Adornee = obj
                                    highlight.FillColor = rarityColors[eggData.rarityId] or Color3.new(1, 1, 1)
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineColor = Color3.new(1, 1, 1)
                                    highlight.OutlineTransparency = 0
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.Parent = game:GetService("CoreGui")
                                end
                                
                                table.insert(eggHighlights, highlight)
                                highlighted = highlighted + 1
                                break
                            end
                        end
                    end
                end
                
                --print("📊 Highlighted " .. highlighted .. " eggs")
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Egg ESP",
                    Content = "Egg ESP disabled!",
                    Duration = 3
                })
                
                --print("❌ Egg ESP disabled")
                
                -- Cleanup
                for _, hl in pairs(eggHighlights) do
                    if Functions.safeDestroy then
                        Functions.safeDestroy(hl)
                    elseif hl and hl.Parent then
                        pcall(function() 
                            hl:Destroy() 
                        end)
                    end
                end
                eggHighlights = {}
                
                -- Also clean from CoreGui
                local CoreGui = game:GetService("CoreGui")
                for _, obj in pairs(CoreGui:GetChildren()) do
                    if obj.Name:find("EggESP_") then
                        pcall(function() 
                            obj:Destroy() 
                        end)
                    end
                end
            end
        end
    })
    
    -- ===== AUTO REFRESH EGG ESP =====
    Tab:CreateButton({
        Name = "RefreshESP",
        Text = "🔄 Refresh ESP",
        Callback = function()
            if Variables.eggESPEnabled then
                -- Turn off then on to refresh
                Variables.eggESPEnabled = false
                task.wait(0.1)
                Variables.eggESPEnabled = true
                
                Bdev:Notify({
                    Title = "ESP",
                    Content = "ESP refreshed!",
                    Duration = 3
                })
                --print("🔄 ESP refreshed")
            else
                Bdev:Notify({
                    Title = "ESP",
                    Content = "Turn on ESP first!",
                    Duration = 3
                })
            end
        end
    })
    
    -- ===== X-RAY VISION =====
    local xrayParts = {}
    local xrayConnection = nil
    
    Tab:CreateToggle({
        Name = "XRay",
        Text = "🔍 X-Ray Vision",
        CurrentValue = false,
        Callback = function(value)
            Variables.xrayEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "X-Ray",
                    Content = "X-Ray enabled! See through walls",
                    Duration = 3
                })
                
                --print("✅ X-Ray enabled")
                
                local function processPart(part)
                    if part:IsA("BasePart") then
                        -- Check if part belongs to a player
                        local isPlayerPart = false
                        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                            if player.Character and part:IsDescendantOf(player.Character) then
                                isPlayerPart = true
                                break
                            end
                        end
                        
                        if not isPlayerPart then
                            -- Save original properties
                            xrayParts[part] = {
                                Transparency = part.Transparency,
                                CastShadow = part.CastShadow
                            }
                            
                            -- Make transparent
                            part.Transparency = 0.7
                            part.CastShadow = false
                        end
                    end
                end
                
                -- Process existing parts
                for _, part in pairs(Shared.Services.Workspace:GetDescendants()) do
                    processPart(part)
                end
                
                -- Connect to new parts
                if xrayConnection then
                    xrayConnection:Disconnect()
                end
                
                xrayConnection = Shared.Services.Workspace.DescendantAdded:Connect(function(descendant)
                    if Variables.xrayEnabled then
                        processPart(descendant)
                    end
                end)
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "X-Ray",
                    Content = "X-Ray disabled!",
                    Duration = 3
                })
                
                --print("❌ X-Ray disabled")
                
                -- Restore original properties
                for part, props in pairs(xrayParts) do
                    if part and part.Parent then
                        pcall(function()
                            part.Transparency = props.Transparency
                            part.CastShadow = props.CastShadow
                        end)
                    end
                end
                
                xrayParts = {}
                
                if xrayConnection then
                    xrayConnection:Disconnect()
                    xrayConnection = nil
                end
            end
        end
    })
    
    -- ===== PLAYER ESP =====
    local playerHighlights = {}
    
    Tab:CreateToggle({
        Name = "PlayerESP",
        Text = "👤 Player ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.playerESPEnabled = value
            
            if value then
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Player ESP",
                    Content = "Player ESP enabled!",
                    Duration = 3
                })
                
                --print("✅ Player ESP enabled")
                
                local function highlightPlayer(player, character)
                    if not character or player == game.Players.LocalPlayer then
                        return
                    end
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerESP_" .. player.Name
                    highlight.Adornee = character
                    highlight.FillColor = Color3.new(0, 0.5, 1)  -- Blue
                    highlight.FillTransparency = 0.7
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = game:GetService("CoreGui")
                    
                    playerHighlights[player] = highlight
                end
                
                -- Highlight existing players
                for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                    if player.Character then
                        highlightPlayer(player, player.Character)
                    end
                    
                    -- Connect to character added
                    player.CharacterAdded:Connect(function(character)
                        if Variables.playerESPEnabled then
                            task.wait(1)  -- Wait for character to load
                            highlightPlayer(player, character)
                        end
                    end)
                end
                
            else
                Bdev:Notify({  -- ✅ FIXED: Colon syntax
                    Title = "Player ESP",
                    Content = "Player ESP disabled!",
                    Duration = 3
                })
                
                --print("❌ Player ESP disabled")
                
                -- Remove highlights
                for _, highlight in pairs(playerHighlights) do
                    if highlight and highlight.Parent then
                        pcall(function()
                            highlight:Destroy()
                        end)
                    end
                end
                playerHighlights = {}
                
                -- Also clean from CoreGui
                local CoreGui = game:GetService("CoreGui")
                for _, obj in pairs(CoreGui:GetChildren()) do
                    if obj.Name:find("PlayerESP_") then
                        pcall(function()
                            obj:Destroy()
                        end)
                    end
                end
            end
        end
    })
    
    -- ===== CHAT LOGGER =====
    local chatLoggerConnection = nil
    
    Tab:CreateToggle({
        Name = "ChatLogger",
        Text = "💬 Chat Logger",
        CurrentValue = false,
        Callback = function(value)
            Variables.chatLoggerEnabled = value
            
            if value then
                Bdev:Notify({
                    Title = "Chat Logger",
                    Content = "Chat logger enabled!",
                    Duration = 3
                })
                
                --print("✅ Chat Logger enabled")
                
                if chatLoggerConnection then
                    chatLoggerConnection:Disconnect()
                end
                
                chatLoggerConnection = Shared.Services.Players.PlayerChatted:Connect(function(player, message)
                    if Variables.chatLoggerEnabled then
                        --print("💬 [" .. player.Name .. "]: " .. message)
                    end
                end)
                
            else
                Bdev:Notify({
                    Title = "Chat Logger",
                    Content = "Chat logger disabled!",
                    Duration = 3
                })
                
                --print("❌ Chat Logger disabled")
                
                if chatLoggerConnection then
                    chatLoggerConnection:Disconnect()
                    chatLoggerConnection = nil
                end
            end
        end
    })
    
    -- ===== CLEAR ALL VISUALS =====
    Tab:CreateButton({
        Name = "ClearVisuals",
        Text = "🧹 Clear All Visuals",
        Callback = function()
            -- Disable all toggles
            Variables.eggESPEnabled = false
            Variables.xrayEnabled = false
            Variables.playerESPEnabled = false
            Variables.chatLoggerEnabled = false
            
            -- Clean X-Ray
            for part, props in pairs(xrayParts) do
                if part and part.Parent then
                    pcall(function()
                        part.Transparency = props.Transparency
                        part.CastShadow = props.CastShadow
                    end)
                end
            end
            xrayParts = {}
            
            if xrayConnection then
                xrayConnection:Disconnect()
                xrayConnection = nil
            end
            
            -- Clean ESP highlights
            for _, hl in pairs(eggHighlights) do
                if hl and hl.Parent then
                    pcall(function()
                        hl:Destroy()
                    end)
                end
            end
            eggHighlights = {}
            
            for _, hl in pairs(playerHighlights) do
                if hl and hl.Parent then
                    pcall(function()
                        hl:Destroy()
                    end)
                end
            end
            playerHighlights = {}
            
            -- Clean CoreGui
            local CoreGui = game:GetService("CoreGui")
            for _, obj in pairs(CoreGui:GetChildren()) do
                if obj.Name:find("EggESP_") or obj.Name:find("PlayerESP_") then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
            
            if chatLoggerConnection then
                chatLoggerConnection:Disconnect()
                chatLoggerConnection = nil
            end
            
            Bdev:Notify({
                Title = "Visuals",
                Content = "All visuals cleared!",
                Duration = 3
            })
            
            --print("🧹 All visuals cleared")
        end
    })
    
    -- ===== VISUALS SETTINGS =====
    Tab:CreateLabel({
        Name = "SettingsLabel",
        Text = "⚙️ ESP Settings:",
        Alignment = Enum.TextXAlignment.Center
    })
    
    local espTransparency = 0.7
    local espColor = Color3.new(0, 0.5, 1)
    
    Tab:CreateSlider({
        Name = "ESPTransparency",
        Text = "Transparency: " .. espTransparency,
        Range = {0.1, 0.9},
        Increment = 0.1,
        CurrentValue = 0.7,
        Callback = function(value)
            espTransparency = value
            --print("📊 ESP Transparency set to:", value)
            
            -- Apply to existing ESP if enabled
            if Variables.eggESPEnabled or Variables.playerESPEnabled then
                Bdev:Notify({
                    Title = "Settings",
                    Content = "Change will apply after ESP refresh",
                    Duration = 3
                })
            end
        end
    })
    
    --print("✅ Visuals tab initialized")
end

return Visuals