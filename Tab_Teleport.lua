-- ==============================================
-- 📍 TELEPORT TAB MODULE - MODERN EDITION
-- ==============================================

local Teleport = {}

function Teleport.Init(Dependencies)
    local Tab = Dependencies.Tab
    local Shared = Dependencies.Shared
    local Bdev = Dependencies.Bdev
    
    -- Get services
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    
    -- ===== FUNGSI TWEEN LOKAL =====
    local function tween(object, properties, duration, easingStyle)
        if not object then return nil end
        
        local tweenInfo = TweenInfo.new(
            duration or 0.2, 
            easingStyle or Enum.EasingStyle.Quint, 
            Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(object, tweenInfo, properties)
        tween:Play()
        return tween
    end
    
    -- ===== VARIABLES =====
    local selectedPlayer = nil
    local playerDropdownRef = nil
    local infoLabelRef = nil
    
    -- ===== FUNGSI TELEPORT =====
    local function teleportToPlayer(targetPlayer)
        if not targetPlayer then
            Bdev:Notify({
                Title = "❌ Error",
                Content = "Pilih player terlebih dahulu!",
                Duration = 3
            })
            return false
        end
        
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then 
            Bdev:Notify({
                Title = "❌ Error",
                Content = "Character not found!",
                Duration = 3
            })
            return false
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then 
            Bdev:Notify({
                Title = "❌ Error",
                Content = "HumanoidRootPart not found!",
                Duration = 3
            })
            return false
        end
        
        if targetPlayer.Character then
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                humanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                Bdev:Notify({
                    Title = "✅ Teleport",
                    Content = "Ke " .. targetPlayer.Name,
                    Duration = 2
                })
                return true
            end
        end
        
        Bdev:Notify({
            Title = "❌ Error",
            Content = "Player tidak memiliki karakter!",
            Duration = 3
        })
        return false
    end
    
    -- ===== FUNGSI TELEPORT KE SPAWN =====
    local function teleportToSpawn()
        local player = game.Players.LocalPlayer
        local character = player.Character
        if not character then 
            Bdev:Notify({
                Title = "❌ Error",
                Content = "Character not found!",
                Duration = 3
            })
            return 
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then 
            Bdev:Notify({
                Title = "❌ Error",
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
        
        if spawn then
            if spawn:IsA("BasePart") then
                humanoidRootPart.CFrame = CFrame.new(spawn.Position)
            elseif spawn:IsA("Model") then
                for _, part in pairs(spawn:GetDescendants()) do
                    if part:IsA("BasePart") and (part.Name:find("Spawn") or part.Name:find("Start")) then
                        humanoidRootPart.CFrame = CFrame.new(part.Position)
                        break
                    end
                end
            end
            Bdev:Notify({
                Title = "✅ Teleport",
                Content = "Ke Spawn",
                Duration = 2
            })
        else
            -- Default spawn
            humanoidRootPart.CFrame = CFrame.new(Vector3.new(0, 50, 0))
            Bdev:Notify({
                Title = "✅ Teleport",
                Content = "Ke Default Spawn",
                Duration = 2
            })
        end
    end
    
    -- ===== FUNGSI UPDATE PLAYER LIST =====
    local function getPlayerList()
        local players = {}
        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                table.insert(players, "👤 " .. player.Name)
            end
        end
        table.sort(players)
        return players
    end
    
    -- ===== FUNGSI GET PLAYER BY DISPLAY =====
    local function getPlayerFromDisplay(display)
        local name = display:gsub("👤 ", "")
        return Shared.Services.Players:FindFirstChild(name)
    end
    
    -- ===== FUNGSI UPDATE INFO LABEL =====
    local function updateInfoLabel()
        if infoLabelRef then
            if selectedPlayer then
                infoLabelRef.Text = "➤ Target: " .. selectedPlayer.Name
            else
                infoLabelRef.Text = "➤ Target: Belum dipilih"
            end
        end
    end
    
    -- ===== MEMBUAT UI =====
    
    -- 1. HEADER
    local header = Tab:CreateLabel({
        Name = "Header_Teleport",
        Text = "───── 📍 TELEPORT ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 2. TOMBOL SPAWN
    local spawnBtn = Tab:CreateButton({
        Name = "TPSpawn",
        Text = "🏠 TELEPORT KE SPAWN",
        Callback = teleportToSpawn
    })
    
    -- 3. SPACER
    Tab:CreateLabel({
        Name = "Spacer1",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 4. HEADER PLAYER
    local headerPlayer = Tab:CreateLabel({
        Name = "Header_Player",
        Text = "───── 👥 TELEPORT KE PLAYER ─────",
        Color = Color3.fromRGB(255, 185, 0),
        Bold = true,
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 5. INFO LABEL
    infoLabelRef = Tab:CreateLabel({
        Name = "InfoLabel",
        Text = "➤ Target: Belum dipilih",
        Color = Color3.fromRGB(255, 255, 255),
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- 6. DROPDOWN PLAYER
    local function refreshPlayerDropdown()
        local players = getPlayerList()
        
        if #players == 0 then
            if playerDropdownRef then
                playerDropdownRef.UpdateOptions({"-- Tidak ada player --"})
            end
            if infoLabelRef then
                infoLabelRef.Text = "➤ Target: Tidak ada player online"
            end
        else
            if playerDropdownRef then
                playerDropdownRef.UpdateOptions(players)
                if selectedPlayer then
                    -- Cek apakah player masih online
                    if Shared.Services.Players:FindFirstChild(selectedPlayer.Name) then
                        playerDropdownRef.SetValue("👤 " .. selectedPlayer.Name)
                    else
                        selectedPlayer = nil
                        updateInfoLabel()
                    end
                end
            end
        end
    end
    
    -- Buat dropdown
    local initialPlayers = getPlayerList()
    playerDropdownRef = Tab:CreateDropdown({
        Name = "PlayerDropdown",
        Text = "Pilih Player:",
        Options = #initialPlayers > 0 and initialPlayers or {"-- Tidak ada player --"},
        Default = #initialPlayers > 0 and initialPlayers[1] or "-- Tidak ada player --",
        Callback = function(value)
            if value == "-- Tidak ada player --" then
                selectedPlayer = nil
            else
                selectedPlayer = getPlayerFromDisplay(value)
            end
            updateInfoLabel()
        end
    })
    
    -- Set default selected player
    if #initialPlayers > 0 then
        selectedPlayer = getPlayerFromDisplay(initialPlayers[1])
        updateInfoLabel()
    end
    
    -- 7. FRAME AKSI CEPAT
    local ActionFrame = Instance.new("Frame")
    ActionFrame.Name = "ActionFrame"
    ActionFrame.Size = UDim2.new(0.95, 0, 0, 40)
    ActionFrame.BackgroundTransparency = 1
    ActionFrame.LayoutOrder = #Tab.Elements + 1
    ActionFrame.Parent = Tab.Content
    
    local ActionLayout = Instance.new("UIListLayout")
    ActionLayout.FillDirection = Enum.FillDirection.Horizontal
    ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ActionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ActionLayout.Padding = UDim.new(0, 10)
    ActionLayout.Parent = ActionFrame
    
    -- Tombol Teleport
    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Name = "TeleportBtn"
    TeleportBtn.Size = UDim2.new(0, 150, 0, 40)
    TeleportBtn.Text = "📍 TELEPORT"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
    TeleportBtn.BackgroundTransparency = 0
    TeleportBtn.TextSize = 14
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.AutoButtonColor = false
    TeleportBtn.Parent = ActionFrame
    
    local TeleportCorner = Instance.new("UICorner")
    TeleportCorner.CornerRadius = UDim.new(0, 8)
    TeleportCorner.Parent = TeleportBtn
    
    TeleportBtn.MouseButton1Click:Connect(function()
        teleportToPlayer(selectedPlayer)
    end)
    
    -- Tombol Refresh
    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Name = "RefreshBtn"
    RefreshBtn.Size = UDim2.new(0, 80, 0, 40)
    RefreshBtn.Text = "🔄"
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    RefreshBtn.BackgroundTransparency = 0
    RefreshBtn.TextSize = 18
    RefreshBtn.Font = Enum.Font.GothamBold
    RefreshBtn.AutoButtonColor = false
    RefreshBtn.Parent = ActionFrame
    
    local RefreshCorner = Instance.new("UICorner")
    RefreshCorner.CornerRadius = UDim.new(0, 8)
    RefreshCorner.Parent = RefreshBtn
    
    RefreshBtn.MouseButton1Click:Connect(function()
        refreshPlayerDropdown()
        Bdev:Notify({
            Title = "🔄 Refresh",
            Content = "Daftar player diperbarui",
            Duration = 2
        })
    end)
    
    -- ===== HOVER EFFECTS =====
    local function setupHover(btn, normalColor, hoverColor)
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = hoverColor}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = normalColor}, 0.15)
        end)
    end
    
    setupHover(TeleportBtn, Color3.fromRGB(255, 185, 0), Color3.fromRGB(255, 215, 100))
    setupHover(RefreshBtn, Color3.fromRGB(70, 70, 85), Color3.fromRGB(90, 90, 105))
    
    -- Hover untuk spawn button (sudah ada dari method CreateButton)
    
    -- ===== AUTO REFRESH =====
    local Players = Shared.Services.Players
    
    Players.PlayerAdded:Connect(function()
        task.wait(1)
        refreshPlayerDropdown()
    end)
    
    Players.PlayerRemoving:Connect(function()
        refreshPlayerDropdown()
    end)
    
    -- ===== CLEANUP =====
    local function cleanup()
        -- Tidak perlu cleanup khusus
    end
    
    -- ===== SHARE FUNCTIONS =====
    Shared.Modules = Shared.Modules or {}
    Shared.Modules.Teleport = {
        TeleportToPlayer = teleportToPlayer,
        TeleportToSpawn = teleportToSpawn,
        GetSelectedPlayer = function() return selectedPlayer end,
        RefreshList = refreshPlayerDropdown
    }
    
    print("✅ Teleport module loaded - Modern Edition")
    
    return cleanup
end

return Teleport