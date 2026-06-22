local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Ждём загрузки игрока
if not localPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

print("Скрипт запущен") -- Проверка в консоли

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.ResetOnSpawn = false -- Важно! Чтобы GUI не исчезал при смерти
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

print("GUI создан:", screenGui.Parent) -- Проверка

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Включаем встроенное перетаскивание!
mainFrame.Parent = screenGui

print("Фрейм создан") -- Проверка

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.Text = "ESP + AIM Panel"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 16
titleBar.Parent = mainFrame

-- Функция создания кнопки
local function createButton(parent, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 170, 100)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    
    return btn
end

-- Создаём кнопки
local espBtn = createButton(mainFrame, "ESP: ON", 40)
local playerBtn = createButton(mainFrame, "Players: ON", 75)
local npcBtn = createButton(mainFrame, "NPCs: ON", 110)
local nameBtn = createButton(mainFrame, "Names: ON", 145)
local healthBtn = createButton(mainFrame, "Health: ON", 180)
local aimBtn = createButton(mainFrame, "AIM BOT: OFF", 215, Color3.fromRGB(170, 0, 0))
local partBtn = createButton(mainFrame, "Target: Head", 250)
local crossBtn = createButton(mainFrame, "Crosshair: OFF", 285, Color3.fromRGB(170, 0, 0))

print("Кнопки созданы") -- Проверка

-- Переменные состояний
local states = {
    esp = true,
    players = true,
    npcs = true,
    names = true,
    health = true,
    aim = false,
    aimPart = "Head",
    crosshair = false
}

-- Словарь для хранения ESP объектов
local espObjects = {}

-- Функция обновления цвета кнопки
local function updateBtn(btn, state, name)
    btn.Text = name .. ": " .. (state and "ON" or "OFF")
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(170, 0, 0)
end

-- Обработчики кнопок
espBtn.MouseButton1Click:Connect(function()
    states.esp = not states.esp
    updateBtn(espBtn, states.esp, "ESP")
end)

playerBtn.MouseButton1Click:Connect(function()
    states.players = not states.players
    updateBtn(playerBtn, states.players, "Players")
end)

npcBtn.MouseButton1Click:Connect(function()
    states.npcs = not states.npcs
    updateBtn(npcBtn, states.npcs, "NPCs")
end)

nameBtn.MouseButton1Click:Connect(function()
    states.names = not states.names
    updateBtn(nameBtn, states.names, "Names")
end)

healthBtn.MouseButton1Click:Connect(function()
    states.health = not states.health
    updateBtn(healthBtn, states.health, "Health")
end)

aimBtn.MouseButton1Click:Connect(function()
    states.aim = not states.aim
    updateBtn(aimBtn, states.aim, "AIM BOT")
end)

partBtn.MouseButton1Click:Connect(function()
    states.aimPart = states.aimPart == "Head" and "HumanoidRootPart" or "Head"
    partBtn.Text = "Target: " .. (states.aimPart == "Head" and "Head" or "Torso")
end)

crossBtn.MouseButton1Click:Connect(function()
    states.crosshair = not states.crosshair
    updateBtn(crossBtn, states.crosshair, "Crosshair")
end)

-- Создание ESP для одного персонажа
local function addESP(character, isPlayer, name)
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Проверка на уже существующий ESP
    if head:FindFirstChild("ESPBillboard") then return end
    
    -- Табличка
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESPBillboard"
    bill.Adornee = head
    bill.Size = UDim2.new(0, 150, 0, 40)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = head
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Parent = bill
    
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 12
    nameLabel.Parent = bg
    
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
    hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: 100"
    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    hpLabel.Font = Enum.Font.SourceSans
    hpLabel.TextSize = 11
    hpLabel.Parent = bg
    
    -- Подсветка
    local hl = Instance.new("Highlight")
    hl.Name = "ESPHighlight"
    hl.FillColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.8
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Parent = character
    
    local data = {
        billboard = bill,
        highlight = hl,
        nameLabel = nameLabel,
        hpLabel = hpLabel,
        character = character,
        head = head,
        isPlayer = isPlayer
    }
    
    espObjects[name] = data
    
    -- Обновление здоровья
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function(hp)
            hpLabel.Text = "HP: " .. math.floor(hp)
            if hp > 75 then
                hpLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            elseif hp > 40 then
                hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            else
                hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
        
        humanoid.Died:Connect(function()
            bill:Destroy()
            hl:Destroy()
            espObjects[name] = nil
        end)
    end
    
    character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            bill:Destroy()
            hl:Destroy()
            espObjects[name] = nil
        end
    end)
end

-- Обновление видимости
local function updateVisibility()
    for _, data in pairs(espObjects) do
        local show = states.esp and ((data.isPlayer and states.players) or (not data.isPlayer and states.npcs))
        data.billboard.Enabled = show
        data.highlight.Enabled = show
        data.nameLabel.Visible = states.names
        data.hpLabel.Visible = states.health
    end
end

-- Подключаем обновление видимости к кнопкам
for _, btn in ipairs({espBtn, playerBtn, npcBtn, nameBtn, healthBtn}) do
    btn.MouseButton1Click:Connect(updateVisibility)
end

-- Обработка игроков
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer and player.Character then
        addESP(player.Character, true, player.Name)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(0.5)
        addESP(char, true, player.Name)
    end)
end)

-- Поиск NPC
local function scanNPCs()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("Head") then
            if not Players:GetPlayerFromCharacter(obj) then
                local n = obj.Name
                if obj.Humanoid.DisplayName ~= "" then n = obj.Humanoid.DisplayName end
                addESP(obj, false, n)
            end
        end
    end
end

scanNPCs()

-- Повторное сканирование
spawn(function()
    while wait(3) do
        scanNPCs()
    end
end)

-- Прицел
local crossGui
local function toggleCrosshair()
    if states.crosshair then
        if crossGui then crossGui:Destroy() end
        crossGui = Instance.new("ScreenGui", localPlayer.PlayerGui)
        
        -- Вертикальная линия
        local v = Instance.new("Frame", crossGui)
        v.Size = UDim2.new(0, 2, 0, 20)
        v.Position = UDim2.new(0.5, -1, 0.5, -10)
        v.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        v.BorderSizePixel = 0
        
        -- Горизонтальная линия
        local h = Instance.new("Frame", crossGui)
        h.Size = UDim2.new(0, 20, 0, 2)
        h.Position = UDim2.new(0.5, -10, 0.5, -1)
        h.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        h.BorderSizePixel = 0
        
        -- Точка
        local d = Instance.new("Frame", crossGui)
        d.Size = UDim2.new(0, 4, 0, 4)
        d.Position = UDim2.new(0.5, -2, 0.5, -2)
        d.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        d.BorderSizePixel = 0
        Instance.new("UICorner", d).CornerRadius = UDim.new(0, 2)
    else
        if crossGui then
            crossGui:Destroy()
            crossGui = nil
        end
    end
end

crossBtn.MouseButton1Click:Connect(toggleCrosshair)

-- Aim Bot
RunService.RenderStepped:Connect(function()
    if not states.aim then return end
    
    local mouse = UserInputService:GetMouseLocation()
    local closest = nil
    local minDist = 200 -- Радиус в пикселях
    
    for _, data in pairs(espObjects) do
        local char = data.character
        if char and char.Parent then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Проверяем фильтры
                if (data.isPlayer and not states.players) or (not data.isPlayer and not states.npcs) then
                    continue
                end
                
                local part = char:FindFirstChild(states.aimPart)
                if part then
                    local pos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    
    if closest then
        camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closest.Position), 0.2)
    end
end)

print("Скрипт полностью загружен!")
