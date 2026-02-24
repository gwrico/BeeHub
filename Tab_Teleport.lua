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
    local allPlayersList = {}  -- Store full player list
    
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
    
    -- ===== FUNGSI UPDATE PLAYER LIST =====
    local function getPlayerList(searchText)
        local players = {}
        allPlayersList = {}  -- Reset full list
        
        for _, player in pairs(Shared.Services.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                local displayName = "👤 " .. player.Name
                table.insert(allPlayersList, displayName)
                
                -- Filter berdasarkan search text
                if not searchText or searchText == "" then
                    table.insert(players, displayName)
                elseif player.Name:lower():find(searchText:lower()) then
                    table.insert(players, displayName)
                end
            end
        end
        
        table.sort(players)
        return players
    end
    
    -- ===== FUNGSI GET PLAYER BY DISPLAY =====
    local function getPlayerFromDisplay(display)
        if not display or display == "-- Tidak ada player --" then return nil end
        local name = display:gsub("👤 ", "")
        return Shared.Services.Players:FindFirstChild(name)
    end
    
    -- ===== FUNGSI UPDATE INFO LABEL =====
    local function updateInfoLabel()
        if infoLabelRef then
            if selectedPlayer then
                infoLabelRef.Text = "➤ Target: 👤 " .. selectedPlayer.Name
            else
                infoLabelRef.Text = "➤ Target: Belum dipilih"
            end
        end
    end
    
    -- ===== FUNGSI UPDATE DROPDOWN =====
    local function updateDropdownOptions(searchText)
        local players = getPlayerList(searchText)
        
        if #players == 0 then
            if playerDropdownRef then
                playerDropdownRef.UpdateOptions({"-- Tidak ada player --"})
                -- Jangan set value otomatis, biarkan user memilih
            end
            if infoLabelRef then
                infoLabelRef.Text = "➤ Target: Tidak ada player online"
            end
            selectedPlayer = nil
        else
            if playerDropdownRef then
                playerDropdownRef.UpdateOptions(players)
                
                -- Cek apakah selected player masih ada di list
                if selectedPlayer then
                    local found = false
                    for _, p in pairs(players) do
                        if p == "👤 " .. selectedPlayer.Name then
                            found = true
                            break
                        end
                    end
                    
                    if not found then
                        selectedPlayer = nil
                        updateInfoLabel()
                    end
                end
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
    
    -- 2. INFO LABEL
    infoLabelRef = Tab:CreateLabel({
        Name = "InfoLabel",
        Text = "➤ Target: Belum dipilih",
        Color = Color3.fromRGB(255, 255, 255),
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- 3. SEARCH SECTION
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchFrame"
    SearchFrame.Size = UDim2.new(0.95, 0, 0, 40)
    SearchFrame.BackgroundTransparency = 1
    SearchFrame.LayoutOrder = #Tab.Elements + 1
    SearchFrame.Parent = Tab.Content
    
    -- Search Box
    local SearchBoxFrame = Instance.new("Frame")
    SearchBoxFrame.Name = "SearchBoxFrame"
    SearchBoxFrame.Size = UDim2.new(0.75, 0, 0, 36)
    SearchBoxFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    SearchBoxFrame.BackgroundTransparency = 0
    SearchBoxFrame.Parent = SearchFrame
    
    local SearchBoxCorner = Instance.new("UICorner")
    SearchBoxCorner.CornerRadius = UDim.new(0, 6)
    SearchBoxCorner.Parent = SearchBoxFrame
    
    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 30, 1, 0)
    SearchIcon.Text = "🔍"
    SearchIcon.TextColor3 = Color3.fromRGB(255, 185, 0)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.TextSize = 16
    SearchIcon.Font = Enum.Font.Gotham
    SearchIcon.Parent = SearchBoxFrame
    
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -35, 1, 0)
    SearchBox.Position = UDim2.new(0, 30, 0, 0)
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Cari player..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundTransparency = 1
    SearchBox.TextSize = 14
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = SearchBoxFrame
    
    -- Refresh Button
    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Name = "RefreshBtn"
    RefreshBtn.Size = UDim2.new(0.2, 0, 0, 36)
    RefreshBtn.Position = UDim2.new(0.78, 5, 0, 0)
    RefreshBtn.Text = "🔄 Refresh"
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    RefreshBtn.BackgroundTransparency = 0
    RefreshBtn.TextSize = 14
    RefreshBtn.Font = Enum.Font.Gotham
    RefreshBtn.AutoButtonColor = false
    RefreshBtn.Parent = SearchFrame
    
    local RefreshCorner = Instance.new("UICorner")
    RefreshCorner.CornerRadius = UDim.new(0, 6)
    RefreshCorner.Parent = RefreshBtn
    
    -- 4. DROPDOWN PLAYER (PASTIKAN INI DIBUAT)
    local initialPlayers = getPlayerList()
    
    -- Tambahkan label untuk dropdown
    local dropdownLabel = Tab:CreateLabel({
        Name = "DropdownLabel",
        Text = "📋 Pilih Player:",
        Color = Color3.fromRGB(255, 255, 255),
        Alignment = Enum.TextXAlignment.Left
    })
    
    -- Buat dropdown
    playerDropdownRef = Tab:CreateDropdown({
        Name = "PlayerDropdown",
        Text = "Pilih Player:",  -- Ini akan menjadi label di dalam dropdown
        Options = #initialPlayers > 0 and initialPlayers or {"-- Tidak ada player --"},
        Default = #initialPlayers > 0 and initialPlayers[1] or "-- Tidak ada player --",
        Callback = function(value)
            if value == "-- Tidak ada player --" then
                selectedPlayer = nil
            else
                selectedPlayer = getPlayerFromDisplay(value)
            end
            updateInfoLabel()
            
            -- Notifikasi
            if selectedPlayer then
                Bdev:Notify({
                    Title = "✅ Dipilih",
                    Content = selectedPlayer.Name,
                    Duration = 1
                })
            end
        end
    })
    
    -- Set default selected player
    if #initialPlayers > 0 then
        selectedPlayer = getPlayerFromDisplay(initialPlayers[1])
        updateInfoLabel()
    end
    
    -- Spacer
    Tab:CreateLabel({
        Name = "Spacer",
        Text = "",
        Alignment = Enum.TextXAlignment.Center
    })
    
    -- 5. TOMBOL TELEPORT
    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Name = "TeleportBtn"
    TeleportBtn.Size = UDim2.new(0.95, 0, 0, 45)
    TeleportBtn.Text = "📍 TELEPORT"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
    TeleportBtn.BackgroundTransparency = 0
    TeleportBtn.TextSize = 16
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.AutoButtonColor = false
    TeleportBtn.LayoutOrder = #Tab.Elements + 1
    TeleportBtn.Parent = Tab.Content
    
    local TeleportCorner = Instance.new("UICorner")
    TeleportCorner.CornerRadius = UDim.new(0, 8)
    TeleportCorner.Parent = TeleportBtn
    
    -- ===== EVENT HANDLERS =====
    
    -- Search functionality
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateDropdownOptions(SearchBox.Text)
    end)
    
    -- Refresh button
    RefreshBtn.MouseButton1Click:Connect(function()
        updateDropdownOptions(SearchBox.Text)
        Bdev:Notify({
            Title = "🔄 Refresh",
            Content = "Daftar player diperbarui",
            Duration = 2
        })
    end)
    
    -- Teleport button
    TeleportBtn.MouseButton1Click:Connect(function()
        teleportToPlayer(selectedPlayer)
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
    
    -- Hover untuk search box
    SearchBoxFrame.MouseEnter:Connect(function()
        tween(SearchBoxFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.15)
    end)
    
    SearchBoxFrame.MouseLeave:Connect(function()
        tween(SearchBoxFrame, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, 0.15)
    end)
    
    -- ===== AUTO REFRESH =====
    local Players = Shared.Services.Players
    
    Players.PlayerAdded:Connect(function()
        task.wait(1)
        updateDropdownOptions(SearchBox.Text)
    end)
    
    Players.PlayerRemoving:Connect(function()
        updateDropdownOptions(SearchBox.Text)
    end)
    
    -- ===== CLEANUP =====
    local function cleanup()
        -- Tidak perlu cleanup khusus
    end
    
    -- ===== SHARE FUNCTIONS =====
    Shared.Modules = Shared.Modules or {}
    Shared.Modules.Teleport = {
        TeleportToPlayer = teleportToPlayer,
        GetSelectedPlayer = function() return selectedPlayer end,
        RefreshList = function() updateDropdownOptions(SearchBox.Text) end,
        Search = function(text)
            SearchBox.Text = text
            updateDropdownOptions(text)
        end
    }
    
    print("✅ Teleport module loaded - dengan Dropdown Fix")
    
    return cleanup
end

return Teleport