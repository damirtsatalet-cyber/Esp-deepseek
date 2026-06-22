-- Ждём полной загрузки
repeat wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

local camera = workspace.CurrentCamera

-- СОЗДАЁМ ГЛАВНЫЙ GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MyCustomGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Кнопка-заглушка для проверки (красный квадрат)
local testBtn = Instance.new("TextButton")
testBtn.Name = "TestButton"
testBtn.Size = UDim2.new(0, 200, 0, 50)
testBtn.Position = UDim2.new(0.5, -100, 0.5, -25)
testBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
testBtn.Text = "КЛИКНИ МЕНЯ"
testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
testBtn.TextSize = 20
testBtn.Font = Enum.Font.SourceSansBold
testBtn.Parent = screenGui

print("ТЕСТОВАЯ КНОПКА СОЗДАНА")
print("GUI родитель:", screenGui.Parent)
print("Кнопка видима:", testBtn.Visible)
print("Абсолютная позиция:", testBtn.AbsolutePosition)

-- Если ты видишь красную кнопку - GUI работает
-- Нажми на неё чтобы создать основной GUI

testBtn.MouseButton1Click:Connect(function()
    print("Кнопка нажата! Создаю основной GUI...")
    testBtn:Destroy()
    createMainGUI()
end)

function createMainGUI()
    print("Создаю основной GUI...")
    
    -- Главная панель
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 500)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Заголовок
    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    titleBar.Text = "ESP + AIM Panel"
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.Font = Enum.Font.SourceSansBold
    titleBar.TextSize = 16
    titleBar.Parent = mainFrame
    
    -- Создаём ScrollingFrame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -30)
    scrollFrame.Position = UDim2.new(0, 0, 0, 30)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    scrollFrame.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = scrollFrame
    
    print("Панель создана")
    
    -- Функция создания кнопки
    local function createButton(text, yPos, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = color or Color3.fromRGB(0, 170, 100)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 13
        btn.AutoButtonColor = false
        btn.Parent = contentFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        return btn
    end
    
    -- Функция создания слайдера
    local function createSlider(name, min, max, default, yPos)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 50)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = contentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 18)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. default
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 0, 6)
        bg.Position = UDim2.new(0, 0, 0, 22)
        bg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        bg.Parent = container
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 3)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        fill.Parent = bg
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
        
        local knob = Instance.new("TextButton")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new((default - min) / (max - min), -7, 0, 18)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Text = ""
        knob.Parent = container
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)
        
        local value = default
        
        local function updateKnob(input)
            local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            knob.Position = UDim2.new(pos, -7, 0, 18)
            label.Text = name .. ": " .. value
        end
        
        knob.MouseButton1Down:Connect(function()
            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateKnob(input)
                end
            end)
            
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end)
        
        return {
            GetValue = function() return value end
        }
    end
    
    -- Функция создания палитры
    local function createColorPicker(name, defaultColor, yPos)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 80)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = contentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 18)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local currentColor = defaultColor
        
        local preview = Instance.new("Frame")
        preview.Size = UDim2.new(0, 30, 0, 30)
        preview.Position = UDim2.new(1, -30, 0, 22)
        preview.BackgroundColor3 = currentColor
        preview.BorderSizePixel = 0
        preview.Parent = container
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)
        
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(255, 128, 0),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(0, 128, 255),
            Color3.fromRGB(128, 0, 255),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 0, 0),
        }
        
        for i, color in ipairs(colors) do
            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 22, 0, 22)
            colorBtn.Position = UDim2.new(0, (i - 1) * 25, 0, 55)
            colorBtn.BackgroundColor3 = color
            colorBtn.BorderSizePixel = 0
            colorBtn.Text = ""
            colorBtn.Parent = container
            Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 3)
            
            if color == Color3.fromRGB(0, 0, 0) then
                colorBtn.BorderSizePixel = 1
                colorBtn.BorderColor3 = Color3.fromRGB(100, 100, 100)
            end
            
            colorBtn.MouseButton1Click:Connect(function()
                currentColor = color
                preview.BackgroundColor3 = color
            end)
        end
        
        return {
            GetColor = function() return currentColor end
        }
    end
    
    -- Функция выпадающего списка
    local function createDropdown(name, items, defaultIndex, yPos)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -20, 0, 30)
        container.Position = UDim2.new(0, 10, 0, yPos)
        container.BackgroundTransparency = 1
        container.Parent = contentFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 100, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name .. ":"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        
        local currentIndex = defaultIndex
        
        local mainBtn = Instance.new("TextButton")
        mainBtn.Size = UDim2.new(1, -105, 1, 0)
        mainBtn.Position = UDim2.new(0, 105, 0, 0)
        mainBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        mainBtn.Text = items[defaultIndex]
        mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainBtn.Font = Enum.Font.SourceSans
        mainBtn.TextSize = 12
        mainBtn.Parent = container
        Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 4)
        
        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(1, -105, 0, #items * 25)
        dropFrame.Position = UDim2.new(0, 105, 1, 2)
        dropFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropFrame.Visible = false
        dropFrame.ZIndex = 10
        dropFrame.Parent = container
        Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)
        
        for i, item in ipairs(items) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 25)
            itemBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 25)
            itemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextSize = 11
            itemBtn.ZIndex = 10
            itemBtn.Parent = dropFrame
            
            itemBtn.MouseButton1Click:Connect(function()
                currentIndex = i
                mainBtn.Text = item
                dropFrame.Visible = false
            end)
        end
        
        mainBtn.MouseButton1Click:Connect(function()
            dropFrame.Visible = not dropFrame.Visible
        end)
        
        return {
            GetValue = function() return items[currentIndex] end,
            GetIndex = function() return currentIndex end
        }
    end
    
    -- Создаём элементы
    local yOffset = 10
    
    -- ESP секция
    local espLabel = Instance.new("TextLabel")
    espLabel.Size = UDim2.new(1, -20, 0, 20)
    espLabel.Position = UDim2.new(0, 10, 0, yOffset)
    espLabel.BackgroundTransparency = 1
    espLabel.Text = "── ESP Settings ──"
    espLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    espLabel.Font = Enum.Font.SourceSansBold
    espLabel.TextSize = 13
    espLabel.Parent = contentFrame
    yOffset = yOffset + 25
    
    local espBtn = createButton("ESP: ON", yOffset)
    yOffset = yOffset + 35
    local playerBtn = createButton("Players: ON", yOffset)
    yOffset = yOffset + 35
    local npcBtn = createButton("NPCs: ON", yOffset)
    yOffset = yOffset + 35
    local nameBtn = createButton("Names: ON", yOffset)
    yOffset = yOffset + 35
    local healthBtn = createButton("Health: ON", yOffset)
    yOffset = yOffset + 40
    
    local materialDropdown = createDropdown("ESP Style", {"Default", "Neon", "Glass", "ForceField"}, 1, yOffset)
    yOffset = yOffset + 40
    
    local outlineColorPicker = createColorPicker("Outline Color", Color3.fromRGB(255, 255, 255), yOffset)
    yOffset = yOffset + 90
    local fillColorPicker = createColorPicker("Fill Color", Color3.fromRGB(255, 255, 255), yOffset)
    yOffset = yOffset + 95
    
    -- AIM секция
    local aimLabel = Instance.new("TextLabel")
    aimLabel.Size = UDim2.new(1, -20, 0, 20)
    aimLabel.Position = UDim2.new(0, 10, 0, yOffset)
    aimLabel.BackgroundTransparency = 1
    aimLabel.Text = "── AIM Bot ──"
    aimLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    aimLabel.Font = Enum.Font.SourceSansBold
    aimLabel.TextSize = 13
    aimLabel.Parent = contentFrame
    yOffset = yOffset + 25
    
    local aimBtn = createButton("AIM BOT: OFF", yOffset, Color3.fromRGB(170, 0, 0))
    yOffset = yOffset + 35
    local aimRadiusSlider = createSlider("AIM Radius", 50, 500, 200, yOffset)
    yOffset = yOffset + 55
    local aimSmoothSlider = createSlider("Smoothness", 1, 20, 5, yOffset)
    yOffset = yOffset + 55
    local aimShowRadiusBtn = createButton("Show Radius: ON", yOffset)
    yOffset = yOffset + 35
    local partBtn = createButton("Target: Head", yOffset)
    yOffset = yOffset + 35
    local crossBtn = createButton("Crosshair: OFF", yOffset, Color3.fromRGB(170, 0, 0))
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 40)
    
    print("Все элементы созданы, yOffset:", yOffset)
    
    -- Состояния
    local states = {
        esp = true,
        players = true,
        npcs = true,
        names = true,
        health = true,
        aim = false,
        aimPart = "Head",
        crosshair = false,
        showRadius = true
    }
    
    local espObjects = {}
    
    local function updateBtn(btn, state, name)
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(170, 0, 0)
    end
    
    -- Обновление ESP
    local function updateAllESP()
        for _, data in pairs(espObjects) do
            if data.highlight then
                local show = states.esp and ((data.isPlayer and states.players) or (not data.isPlayer and states.npcs))
                data.highlight.Enabled = show
                data.highlight.OutlineColor = outlineColorPicker.GetColor()
                data.highlight.FillColor = fillColorPicker.GetColor()
                
                local material = materialDropdown.GetValue()
                if material == "Neon" then
                    data.highlight.FillTransparency = 0.7
                    data.highlight.OutlineTransparency = 0
                elseif material == "Glass" then
                    data.highlight.FillTransparency = 0.5
                    data.highlight.OutlineTransparency = 0.3
                elseif material == "ForceField" then
                    data.highlight.FillTransparency = 0.9
                    data.highlight.OutlineTransparency = 0
                else
                    data.highlight.FillTransparency = 0.8
                    data.highlight.OutlineTransparency = 0
                end
            end
            if data.billboard then
                local show = states.esp and ((data.isPlayer and states.players) or (not data.isPlayer and states.npcs))
                data.billboard.Enabled = show
            end
            if data.nameLabel then
                data.nameLabel.Visible = states.names
            end
            if data.hpLabel then
                data.hpLabel.Visible = states.health
            end
        end
    end
    
    -- Обработчики
    espBtn.MouseButton1Click:Connect(function() states.esp = not states.esp; updateBtn(espBtn, states.esp, "ESP"); updateAllESP() end)
    playerBtn.MouseButton1Click:Connect(function() states.players = not states.players; updateBtn(playerBtn, states.players, "Players"); updateAllESP() end)
    npcBtn.MouseButton1Click:Connect(function() states.npcs = not states.npcs; updateBtn(npcBtn, states.npcs, "NPCs"); updateAllESP() end)
    nameBtn.MouseButton1Click:Connect(function() states.names = not states.names; updateBtn(nameBtn, states.names, "Names"); updateAllESP() end)
    healthBtn.MouseButton1Click:Connect(function() states.health = not states.health; updateBtn(healthBtn, states.health, "Health"); updateAllESP() end)
    
    aimBtn.MouseButton1Click:Connect(function()
        states.aim = not states.aim
        updateBtn(aimBtn, states.aim, "AIM BOT")
        updateRadiusCircle()
    end)
    
    partBtn.MouseButton1Click:Connect(function()
        states.aimPart = states.aimPart == "Head" and "HumanoidRootPart" or "Head"
        partBtn.Text = "Target: " .. (states.aimPart == "Head" and "Head" or "Torso")
    end)
    
    aimShowRadiusBtn.MouseButton1Click:Connect(function()
        states.showRadius = not states.showRadius
        updateBtn(aimShowRadiusBtn, states.showRadius, "Show Radius")
        updateRadiusCircle()
    end)
    
    crossBtn.MouseButton1Click:Connect(function()
        states.crosshair = not states.crosshair
        updateBtn(crossBtn, states.crosshair, "Crosshair")
        toggleCrosshair()
    end)
    
    -- ESP для персонажа
    local function addESP(character, isPlayer, name)
        local head = character:FindFirstChild("Head")
        if not head or head:FindFirstChild("ESPBillboard") then return end
        
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
        
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.8
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
        
        local humano
