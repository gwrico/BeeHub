-- ==============================================
-- 👁️ VISUALS TAB MODULE (PET GAME VERSION)
-- ==============================================

local Visuals = {}

function Visuals.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    local Variables = Shared.Variables
    local Functions = Shared.Functions or {}
    
    print("👁️ Initializing Visuals tab (Pets Edition)...")
    
    -- ===== EGG ESP (GANTI DARI ORE ESP) =====
    local eggHighlights = {}
    Tab:CreateToggle({
        Name = "EggESP",
        Text = "🥚 Egg ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.eggESPEnabled = value
            
            if value then
                Bdev.Notify({
                    Title = "Egg ESP",
                    Content = "Egg ESP enabled! Find eggs easily",
                    Duration = 3
                })
                
                print("✅ Egg ESP enabled")
                
                local rarityColors = {
                    [1] = Color3.fromRGB(184, 115, 51),    -- Copper (coklat tembaga)
                    [2] = Color3.fromRGB(192, 192, 192),   -- Silver (perak)
                    [3] = Color3.fromRGB(255, 215, 0),     -- Gold (emas)
                    [4] = Color3.fromRGB(80, 200, 120),    -- Emerald (hijau zamrud)
                    [5] = Color3.fromRGB(224, 17, 95),     -- Ruby (merah ruby)
                    [6] = Color3.fromRGB(185, 242, 255),   -- Diamond (biru diamond)
                    [7] = Color3.fromRGB(16, 20, 31),      -- Obsidian (hitam obsidian)
                    [8] = Color3.fromRGB(148, 0, 211)      -- Mystery (ungu)
                }
                
                -- Clear existing highlights
                for _, hl in pairs(eggHighlights) do
                    if Functions.safeDestroy then
                        Functions.safeDestroy(hl)
                    elseif hl and hl.Parent then
                        pcall(function() hl:Destroy() end)
                    end
                end
                eggHighlights = {}
                
                local highlighted = 0
                
                -- Cari semua object di workspace
                for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
                        local objName = obj.Name
                        
                        -- Cek untuk setiap egg dalam EggData
                        for eggName, eggData in pairs(Shared.EggData) do
                            -- Pattern matching fleksibel
                            local patterns = {
                                eggName,  -- "Copper Egg"
                                eggName:gsub(" Egg", ""),  -- "Copper"
                                eggName:gsub(" Lucky Block", ""),  -- "Gold"
                                eggName:lower(),  -- "copper egg"
                                eggName:gsub(" Egg", ""):lower()  -- "copper"
                            }
                            
                            local isMatch = false
                            for _, pattern in ipairs(patterns) do
                                if objName:lower():find(pattern:lower(), 1, true) then
                                    isMatch = true
                                    break
                                end
                            end
                            
                            if isMatch then
                                -- Create highlight
                                local highlight
                                if Functions.createHighlight then
                                    highlight = Functions.createHighlight(
                                        obj, 
                                        rarityColors[eggData.rarityId] or Color3.new(1, 1, 1),
                                        0.5  -- Kurangi transparency biar lebih jelas
                                    )
                                else
                                    -- Fallback
                                    highlight = Instance.new("Highlight")
                                    highlight.Adornee = obj
                                    highlight.FillColor = rarityColors[eggData.rarityId] or Color3.new(1, 1, 1)
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineColor = Color3.new(1, 1, 1)
                                    highlight.OutlineTransparency = 0
                                    highlight.Parent = game.CoreGui
                                end
                                
                                highlight.Name = "EggESP_" .. eggName
                                table.insert(eggHighlights, highlight)
                                highlighted = highlighted + 1
                                
                                print("🎯 Found:", eggName, "->", objName)
                                break
                            end
                        end
                    end
                end
                
                print("📊 Highlighted", highlighted, "eggs")
                
            else
                Bdev.Notify({
                    Title = "Egg ESP",
                    Content = "Egg ESP disabled!",
                    Duration = 3
                })
                
                print("❌ Egg ESP disabled")
                
                -- Cleanup highlights
                for _, hl in pairs(eggHighlights) do
                    if Functions.safeDestroy then
                        Functions.safeDestroy(hl)
                    elseif hl and hl.Parent then
                        pcall(function() hl:Destroy() end)
                    end
                end
                eggHighlights = {}
                
                -- Juga clean semua highlight di CoreGui
                for _, obj in pairs(game.CoreGui:GetChildren()) do
                    if obj.Name:find("EggESP_") then
                        if Functions.safeDestroy then
                            Functions.safeDestroy(obj)
                        elseif obj and obj.Parent then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end
    })
    
    -- ===== PET ESP (TAMBAHAN UNTUK PET GAME) =====
    Tab:CreateToggle({
        Name = "PetESP",
        Text = "🐾 Pet ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.petESPEnabled = value
            
            if value then
                Bdev.Notify({
                    Title = "Pet ESP",
                    Content = "Pet ESP enabled! See all pets",
                    Duration = 3
                })
                
                print("✅ Pet ESP enabled")
                
                -- Cari semua pets di workspace (biasanya ada di folder Pets)
                local petsFolder = Shared.Services.Workspace:FindFirstChild("Pets")
                if petsFolder then
                    for _, pet in pairs(petsFolder:GetDescendants()) do
                        if pet:IsA("BasePart") or pet:IsA("Model") then
                            local highlight
                            if Functions.createHighlight then
                                highlight = Functions.createHighlight(
                                    pet,
                                    Color3.fromRGB(255, 105, 180), -- Pink
                                    0.3
                                )
                            end
                            if highlight then
                                highlight.Name = "PetESP_" .. pet.Name
                            end
                        end
                    end
                end
                
            else
                Bdev.Notify({
                    Title = "Pet ESP",
                    Content = "Pet ESP disabled!",
                    Duration = 3
                })
                
                print("❌ Pet ESP disabled")
                
                -- Cleanup pet highlights
                for _, obj in pairs(game.CoreGui:GetChildren()) do
                    if obj.Name:find("PetESP_") then
                        if Functions.safeDestroy then
                            Functions.safeDestroy(obj)
                        end
                    end
                end
            end
        end
    })
    
    -- ===== SIMPLE XRAY =====
    local xrayProcessed = {}
    Tab:CreateToggle({
        Name = "SimpleXRay",
        Text = "🔍 Simple X-Ray",
        CurrentValue = false,
        Callback = function(value)
            Variables.xrayEnabled = value
            
            if value then
                Bdev.Notify({
                    Title = "Simple X-Ray",
                    Content = "X-Ray enabled! Non-player objects are transparent",
                    Duration = 3
                })
                
                print("✅ Simple X-Ray enabled")
                
                local function makePartTransparent(part)
                    if part:IsA("BasePart") then
                        local isPlayerPart = false
                        
                        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                            if player.Character and part:IsDescendantOf(player.Character) then
                                isPlayerPart = true
                                break
                            end
                        end
                        
                        if not isPlayerPart then
                            local parent = part.Parent
                            if parent and (parent:IsA("Tool") or parent.Name == "Tool") then
                                isPlayerPart = true
                            end
                        end
                        
                        if not isPlayerPart then
                            local originalProps = {
                                Transparency = part.Transparency,
                                CastShadow = part.CastShadow
                            }
                            
                            part.Transparency = 0.7
                            part.CastShadow = false
                            
                            xrayProcessed[part] = originalProps
                        end
                    end
                end
                
                -- Process existing objects
                for _, obj in pairs(Shared.Services.Workspace:GetDescendants()) do
                    makePartTransparent(obj)
                end
                
                -- Process new objects
                local connection
                connection = Shared.Services.Workspace.DescendantAdded:Connect(function(obj)
                    makePartTransparent(obj)
                end)
                
            else
                Bdev.Notify({
                    Title = "Simple X-Ray",
                    Content = "X-Ray disabled!",
                    Duration = 3
                })
                
                print("❌ Simple X-Ray disabled")
                
                -- Restore parts
                for part, originalProps in pairs(xrayProcessed) do
                    if part and part.Parent then
                        pcall(function()
                            part.Transparency = originalProps.Transparency
                            part.CastShadow = originalProps.CastShadow
                        end)
                    end
                end
                
                xrayProcessed = {}
            end
        end
    })
    
    -- ===== PLAYER ESP =====
    Tab:CreateToggle({
        Name = "PlayerESP",
        Text = "👤 Player ESP",
        CurrentValue = false,
        Callback = function(value)
            Variables.playerESPEnabled = value
            
            if value then
                Bdev.Notify({
                    Title = "Player ESP",
                    Content = "Player ESP enabled!",
                    Duration = 3
                })
                
                print("✅ Player ESP enabled")
                
                for _, player in pairs(Shared.Services.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        local highlight
                        if Functions.createHighlight then
                            highlight = Functions.createHighlight(
                                player.Character,
                                Color3.new(0, 0.5, 1), -- Biru muda
                                0.7
                            )
                        end
                        if highlight then
                            highlight.Name = "PlayerESP_" .. player.Name
                        end
                        
                        player.CharacterAdded:Connect(function(char)
                            if Variables.playerESPEnabled then
                                task.wait(1)
                                if Functions.createHighlight then
                                    local newHighlight = Functions.createHighlight(
                                        char,
                                        Color3.new(0, 0.5, 1),
                                        0.7
                                    )
                                    if newHighlight then
                                        newHighlight.Name = "PlayerESP_" .. player.Name
                                    end
                                end
                            end
                        end)
                    end
                end
                
            else
                Bdev.Notify({
                    Title = "Player ESP",
                    Content = "Player ESP disabled!",
                    Duration = 3
                })
                
                print("❌ Player ESP disabled")
                
                for _, obj in pairs(game.CoreGui:GetChildren()) do
                    if string.find(obj.Name, "PlayerESP_") then
                        if Functions.safeDestroy then
                            Functions.safeDestroy(obj)
                        end
                    end
                end
            end
        end
    })
    
    print("✅ Visuals tab initialized (Pets Edition)")
end

return Visuals