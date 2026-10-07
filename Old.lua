-- ═══════════════════════════════════════════════════════════════
-- HUB UTILITY — ULTIMATE EDITION v5 (OPTIMIZED)
-- LocalScript в StarterPlayer > StarterPlayerScripts
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==================== НАСТРОЙКИ ====================
local SETTINGS = {
	AimEnabled = true,
	AimKey = Enum.UserInputType.MouseButton2,
	ToggleMode = false,
	AimFOV = 200,
	Smoothness = 0.3,
	TargetPart = "Head",
	WallCheck = true,
	MaxWallThickness = 0.5,
	TeamCheck = true,
	IgnoreDead = true,
	ShowFOVCircle = true,
	AimAtNPCs = true,
	NPCTeamCheck = false,

	PredictionEnabled = true,
	PredictionMultiplier = 1.0,
	BulletSpeed = 500,

	IgnorePhantom = false,
	PhantomTransparency = 0.95,

	ESPEnabled = true,
	ESPName = true,
	ESPDistance = true,
	ESPVisibleColor = "0,255,120",
	ESPHiddenColor = "255,60,60",
	ESPThickness = 1.5,
	ESPTransparency = 0.88,
	ESPMaxDistance = 500,
	LODEnabled = false,
	LODDistance = 200,

	HeadDotEnabled = false,
	HeadDotSize = 6,

	SkeletonEnabled = false,
	SkeletonThickness = 1,

	HitmarkerEnabled = true,

	BodySkinEnabled = false,
	BodyMaterial = "Neon",
	BodyColorHex = "255,255,255",
	BodyTransparency = 0,

	SilentAimEnabled = false,
	SilentAimAutoFire = true,
	SilentAimDelay = 0.05,
	SilentAimOnlyWhenVisible = true,

	SpeedEnabled = false,
	SpeedMode = "Legit",
	WalkSpeed = 16,
	JumpPower = 50,
	SpeedKey = Enum.KeyCode.LeftControl,
	SpeedToggleMode = true,

	CameraFOV = 70,
	LockFOV = false,
	Fullbright = false,
	CustomSky = false,
	SkyId = "",

	WatermarkEnabled = true,
	WatermarkFPS = true,
	WatermarkPing = true,
	WatermarkTime = true,

	StatsEnabled = false,

	CrosshairEnabled = false,
	CrosshairStyle = "Cross",
	CrosshairColorHex = "0,255,120",
	CrosshairSize = 12,
	CrosshairThickness = 2,
	CrosshairGap = 4,

	TracersEnabled = false,
	TracersFrom = "Bottom",
	TracersThickness = 1.5,
	TracersTransparency = 0.3,

	InvEnabled = false,
	InvShowSource = true,
	InvShowIcons = true,
	InvMaxSlots = 30,
	InvShowOthers = false,

	RadarEnabled = false,
	RadarSize = 150,
	RadarRange = 150,

	PlayerListEnabled = false,

	PreviewEnabled = false,
	PreviewRotate = true,
	PreviewRotSpeed = 30,
	PreviewName = "Player123",
	PreviewDistance = 42,

	PerformanceMode = false,
	VisibilityHz = 20,
	TargetHz = 60,
	NPCCacheSec = 1.0,
}

local ORIGINAL = {
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd,
	FogStart = Lighting.FogStart,
	GlobalShadows = Lighting.GlobalShadows,
}

-- ==================== ТЕМА ====================
local THEME = {
	BgMain = Color3.fromRGB(15, 16, 22),
	BgHeader = Color3.fromRGB(22, 24, 34),
	CardBg = Color3.fromRGB(24, 26, 38),
	ElementBg = Color3.fromRGB(34, 37, 54),
	Accent = Color3.fromRGB(124, 92, 255),
	ToggleOff = Color3.fromRGB(45, 48, 66),
	TextMain = Color3.fromRGB(240, 242, 255),
	TextDim = Color3.fromRGB(150, 155, 180),
	Stroke = Color3.fromRGB(48, 52, 75),
}

local function tween(object, info, properties)
	local t = TweenService:Create(object, info, properties)
	t:Play()
	return t
end

-- ==================== ЦВЕТ: КЭШ ====================
local colorCache = {}
local function parseColor(str)
	if not str or str == "" then return Color3.fromRGB(255, 255, 255) end
	if colorCache[str] then return colorCache[str] end

	local orig = str
	str = str:gsub("#", ""):gsub("%s", "")
	local result

	if #str == 6 and str:match("^%x+$") then
		local r = tonumber(str:sub(1,2), 16)
		local g = tonumber(str:sub(3,4), 16)
		local b = tonumber(str:sub(5,6), 16)
		result = Color3.fromRGB(r, g, b)
	else
		local parts = {}
		for p in str:gmatch("[^,]+") do table.insert(parts, tonumber(p)) end
		if #parts >= 3 then
			result = Color3.fromRGB(
				math.clamp(parts[1] or 255, 0, 255),
				math.clamp(parts[2] or 255, 0, 255),
				math.clamp(parts[3] or 255, 0, 255)
			)
		else
			result = Color3.fromRGB(255, 255, 255)
		end
	end

	colorCache[orig] = result
	return result
end

local function getMaterial(name)
	local ok, m = pcall(function() return Enum.Material[name] end)
	if ok and m then return m end
	return Enum.Material.Neon
end

-- ==================== ПЕРЕТАСКИВАНИЕ ====================
local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ==================== GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CheatGui_v5"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0, 25, 0.5, -26)
toggleBtn.BackgroundColor3 = THEME.BgHeader
toggleBtn.Text = "⚙"
toggleBtn.TextColor3 = THEME.TextMain
toggleBtn.TextSize = 26
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = THEME.Accent
btnStroke.Thickness = 2
btnStroke.Parent = toggleBtn

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 620)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -310)
mainFrame.BackgroundColor3 = THEME.BgMain
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.Stroke
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = THEME.BgHeader
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = THEME.BgHeader
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "HUB UTILITY"
title.TextColor3 = THEME.TextMain
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(0, 200, 0, 14)
subTitle.Position = UDim2.new(0, 122, 0.5, -7)
subTitle.BackgroundTransparency = 1
subTitle.Text = "• v5 Optimized"
subTitle.TextColor3 = THEME.Accent
subTitle.TextSize = 13
subTitle.Font = Enum.Font.GothamMedium
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
closeBtn.BackgroundColor3 = THEME.ElementBg
closeBtn.Text = "✕"
closeBtn.TextColor3 = THEME.TextDim
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 55)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = THEME.Accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 12)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local scrollPadding = Instance.new("UIPadding")
scrollPadding.PaddingTop = UDim.new(0, 4)
scrollPadding.PaddingBottom = UDim.new(0, 10)
scrollPadding.PaddingLeft = UDim.new(0, 4)
scrollPadding.PaddingRight = UDim.new(0, 8)
scrollPadding.Parent = scroll

local function makeCard(titleText)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = THEME.CardBg
	card.BorderSizePixel = 0
	card.Parent = scroll

	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = card
	local s = Instance.new("UIStroke"); s.Color = THEME.Stroke; s.Thickness = 1; s.Parent = card

	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 8); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = card

	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 10); p.PaddingBottom = UDim.new(0, 12)
	p.PaddingLeft = UDim.new(0, 12); p.PaddingRight = UDim.new(0, 12)
	p.Parent = card

	local h = Instance.new("TextLabel")
	h.Size = UDim2.new(1, 0, 0, 20)
	h.BackgroundTransparency = 1
	h.Text = titleText:upper()
	h.TextColor3 = THEME.Accent
	h.TextSize = 12
	h.Font = Enum.Font.GothamBold
	h.TextXAlignment = Enum.TextXAlignment.Left
	h.Parent = card

	return card
end

local function makeLabel(card, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = THEME.TextDim
	l.TextSize = 11
	l.Font = Enum.Font.Gotham
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.Parent = card
	return l
end

local function makeToggle(card, name, key, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = card

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.7, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = name
	l.TextColor3 = THEME.TextMain
	l.TextSize = 13
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local sw = Instance.new("TextButton")
	sw.Size = UDim2.new(0, 44, 0, 22)
	sw.Position = UDim2.new(1, -44, 0.5, -11)
	sw.BackgroundColor3 = SETTINGS[key] and THEME.Accent or THEME.ToggleOff
	sw.Text = ""
	sw.AutoButtonColor = false
	sw.BorderSizePixel = 0
	sw.Parent = row

	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = sw

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = SETTINGS[key] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = sw

	local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

	sw.MouseButton1Click:Connect(function()
		SETTINGS[key] = not SETTINGS[key]
		local st = SETTINGS[key]
		tween(sw, TweenInfo.new(0.2), {BackgroundColor3 = st and THEME.Accent or THEME.ToggleOff})
		tween(knob, TweenInfo.new(0.2), {Position = st and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
		if callback then callback(st) end
	end)
end

local function makeSlider(card, name, key, min, max, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundTransparency = 1
	row.Parent = card

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.7, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = name
	l.TextColor3 = THEME.TextMain
	l.TextSize = 13
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local vl = Instance.new("TextLabel")
	vl.Size = UDim2.new(0.3, 0, 0, 18)
	vl.Position = UDim2.new(0.7, 0, 0, 0)
	vl.BackgroundTransparency = 1
	vl.Text = tostring(SETTINGS[key])
	vl.TextColor3 = THEME.Accent
	vl.TextSize = 13
	vl.Font = Enum.Font.GothamBold
	vl.TextXAlignment = Enum.TextXAlignment.Right
	vl.Parent = row

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 6)
	bar.Position = UDim2.new(0, 0, 0, 26)
	bar.BackgroundColor3 = THEME.ElementBg
	bar.BorderSizePixel = 0
	bar.Parent = row

	local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((SETTINGS[key] - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(fill.Size.X.Scale, -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = bar

	local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

	local dragging = false

	local function updateFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local val = min + (max - min) * rel
		if max - min <= 2 then
			val = math.floor(val * 100 + 0.5) / 100
		else
			val = math.floor(val + 0.5)
		end
		SETTINGS[key] = val
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -7, 0.5, -7)
		vl.Text = tostring(val)
		if callback then callback(val) end
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function makeDropdown(card, name, key, options, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = card

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0.5, 0, 1, 0)
	l.BackgroundTransparency = 1
	l.Text = name
	l.TextColor3 = THEME.TextMain
	l.TextSize = 13
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 150, 0, 24)
	btn.Position = UDim2.new(1, -150, 0.5, -12)
	btn.BackgroundColor3 = THEME.ElementBg
	btn.Text = tostring(SETTINGS[key]) .. "  ▼"
	btn.TextColor3 = THEME.TextMain
	btn.TextSize = 12
	btn.Font = Enum.Font.Gotham
	btn.BorderSizePixel = 0
	btn.Parent = row

	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
	local s = Instance.new("UIStroke"); s.Color = THEME.Stroke; s.Thickness = 1; s.Parent = btn

	local index = 1
	for i, v in ipairs(options) do if v == SETTINGS[key] then index = i break end end

	btn.MouseButton1Click:Connect(function()
		index = index + 1
		if index > #options then index = 1 end
		SETTINGS[key] = options[index]
		btn.Text = tostring(options[index]) .. "  ▼"
		if callback then callback(options[index]) end
	end)
end

local function makeTextBox(card, name, key, placeholder, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 48)
	row.BackgroundTransparency = 1
	row.Parent = card

	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text = name
	l.TextColor3 = THEME.TextMain
	l.TextSize = 13
	l.Font = Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 26)
	box.Position = UDim2.new(0, 0, 0, 20)
	box.BackgroundColor3 = THEME.ElementBg
	box.BorderSizePixel = 0
	box.Text = SETTINGS[key]
	box.PlaceholderText = placeholder
	box.TextColor3 = THEME.TextMain
	box.PlaceholderColor3 = THEME.TextDim
	box.TextSize = 12
	box.Font = Enum.Font.Gotham
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = row

	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = box
	local s = Instance.new("UIStroke"); s.Color = THEME.Stroke; s.Thickness = 1; s.Parent = box
	local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0, 8); p.Parent = box

	box.Focused:Connect(function() tween(s, TweenInfo.new(0.2), {Color = THEME.Accent}) end)
	box.FocusLost:Connect(function()
		tween(s, TweenInfo.new(0.2), {Color = THEME.Stroke})
		SETTINGS[key] = box.Text
		colorCache = {}
		if callback then callback(box.Text) end
	end)
end

-- ============ НАПОЛНЕНИЕ ============

local aimCard = makeCard("🎯 Аимбот + Prediction")
makeToggle(aimCard, "Включить аим", "AimEnabled")
makeToggle(aimCard, "Проверка стен", "WallCheck")
makeToggle(aimCard, "Игнор союзников", "TeamCheck")
makeToggle(aimCard, "Игнор мёртвых", "IgnoreDead")
makeToggle(aimCard, "Стрелять по NPC", "AimAtNPCs")
makeToggle(aimCard, "Показывать FOV", "ShowFOVCircle")
makeSlider(aimCard, "Радиус FOV", "AimFOV", 20, 500)
makeSlider(aimCard, "Сглаживание", "Smoothness", 0, 0.95)
makeSlider(aimCard, "Макс. толщина стены", "MaxWallThickness", 0, 5)
makeDropdown(aimCard, "Целевая часть", "TargetPart", {"Head", "UpperTorso", "HumanoidRootPart"})
makeToggle(aimCard, "Prediction", "PredictionEnabled")
makeSlider(aimCard, "└ Множитель", "PredictionMultiplier", 0, 3)
makeSlider(aimCard, "└ Скорость пули", "BulletSpeed", 50, 2000)

local silentCard = makeCard("🎯 Silent Aim (Real)")
makeToggle(silentCard, "Включить Silent Aim", "SilentAimEnabled")
makeToggle(silentCard, "└ Авто-выстрел", "SilentAimAutoFire")
makeSlider(silentCard, "└ Задержка (сек)", "SilentAimDelay", 0.01, 1)
makeToggle(silentCard, "└ Только если видно", "SilentAimOnlyWhenVisible")

local phantomCard = makeCard("👻 Фантомы")
makeToggle(phantomCard, "Игнорировать фантомы", "IgnorePhantom")
makeSlider(phantomCard, "Порог прозрачности", "PhantomTransparency", 0, 1)

local espCard = makeCard("👁️ ESP Box")
makeToggle(espCard, "Включить ESP", "ESPEnabled")
makeToggle(espCard, "Показывать имя", "ESPName")
makeToggle(espCard, "Показывать дистанцию", "ESPDistance")
makeTextBox(espCard, "Цвет видимых", "ESPVisibleColor", "0,255,120")
makeTextBox(espCard, "Цвет скрытых", "ESPHiddenColor", "255,60,60")
makeSlider(espCard, "Толщина рамки", "ESPThickness", 0.5, 5)
makeSlider(espCard, "Прозрачность заливки", "ESPTransparency", 0, 1)
makeSlider(espCard, "Макс. дистанция", "ESPMaxDistance", 50, 2000)
makeToggle(espCard, "LOD (скрывать далёких)", "LODEnabled")
makeSlider(espCard, "└ LOD дистанция", "LODDistance", 50, 500)

local extraCard = makeCard("🎯 Дополнительно")
makeToggle(extraCard, "Head Dot", "HeadDotEnabled")
makeSlider(extraCard, "└ Размер точки", "HeadDotSize", 2, 20)
makeToggle(extraCard, "Skeleton ESP", "SkeletonEnabled")
makeSlider(extraCard, "└ Толщина линий", "SkeletonThickness", 0.5, 3)
makeToggle(extraCard, "Hitmarker", "HitmarkerEnabled")

local bodyCard = makeCard("✨ Подсветка тела")
makeToggle(bodyCard, "Включить подсветку", "BodySkinEnabled", function()
	task.wait(0.05); refreshAllBodySkins()
end)
makeDropdown(bodyCard, "Материал", "BodyMaterial",
	{"Neon", "ForceField", "Glass", "Plastic", "SmoothPlastic", "Metal", "Ice", "Marble"},
	function() if SETTINGS.BodySkinEnabled then refreshAllBodySkins() end end)
makeTextBox(bodyCard, "Цвет", "BodyColorHex", "255,0,0 или FF0000",
	function() if SETTINGS.BodySkinEnabled then refreshAllBodySkins() end end)
makeSlider(bodyCard, "Прозрачность", "BodyTransparency", 0, 1, function()
	if SETTINGS.BodySkinEnabled then refreshAllBodySkins() end
end)

local speedCard = makeCard("⚡ Скорость & Прыжок")
makeToggle(speedCard, "Включить Speed", "SpeedEnabled")
makeDropdown(speedCard, "Режим", "SpeedMode", {"Legit", "Rage", "Custom"}, function(mode)
	if mode == "Legit" then SETTINGS.WalkSpeed = 24; SETTINGS.JumpPower = 50
	elseif mode == "Rage" then SETTINGS.WalkSpeed = 120; SETTINGS.JumpPower = 120 end
end)
makeSlider(speedCard, "WalkSpeed", "WalkSpeed", 16, 300)
makeSlider(speedCard, "JumpPower", "JumpPower", 50, 300)
makeToggle(speedCard, "Переключение", "SpeedToggleMode")
makeLabel(speedCard, "Бинд: Left Ctrl")

local visualCard = makeCard("🌐 Визуал")
makeToggle(visualCard, "Зафиксировать FOV", "LockFOV")
makeSlider(visualCard, "FOV камеры", "CameraFOV", 50, 130)

local function applyFullbright(on)
	if on then
		Lighting.Brightness = 3; Lighting.ClockTime = 14
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100000; Lighting.FogStart = 0
	else
		Lighting.Brightness = ORIGINAL.Brightness
		Lighting.ClockTime = ORIGINAL.ClockTime
		Lighting.Ambient = ORIGINAL.Ambient
		Lighting.OutdoorAmbient = ORIGINAL.OutdoorAmbient
		Lighting.GlobalShadows = ORIGINAL.GlobalShadows
		Lighting.FogEnd = ORIGINAL.FogEnd
		Lighting.FogStart = ORIGINAL.FogStart
	end
end
makeToggle(visualCard, "Fullbright", "Fullbright", applyFullbright)

local currentSky = nil
local function parseSkyIds(str)
	str = str:gsub("%s", "")
	if str == "" then return nil end
	local ids = {}
	for id in str:gmatch("[^,]+") do
		local num = id:match("(%d+)")
		if num then table.insert(ids, tonumber(num)) end
	end
	return ids
end

local function applySky(str)
	if currentSky then currentSky:Destroy() currentSky = nil end
	local ids = parseSkyIds(str)
	if not ids or #ids == 0 then return end
	local sky = Instance.new("Sky")
	sky.Name = "CustomSky"
	local function fmt(n) return "rbxassetid://" .. tostring(n) end
	if #ids == 1 then
		sky.SkyboxBk = fmt(ids[1]); sky.SkyboxDn = fmt(ids[1]); sky.SkyboxFt = fmt(ids[1])
		sky.SkyboxLf = fmt(ids[1]); sky.SkyboxRt = fmt(ids[1]); sky.SkyboxUp = fmt(ids[1])
	elseif #ids >= 6 then
		sky.SkyboxBk = fmt(ids[1]); sky.SkyboxDn = fmt(ids[2]); sky.SkyboxFt = fmt(ids[3])
		sky.SkyboxLf = fmt(ids[4]); sky.SkyboxRt = fmt(ids[5]); sky.SkyboxUp = fmt(ids[6])
	end
	sky.Parent = Lighting
	currentSky = sky
end

makeToggle(visualCard, "Кастомное небо", "CustomSky", function(on)
	if on then applySky(SETTINGS.SkyId)
	else if currentSky then currentSky:Destroy() currentSky = nil end end
end)
makeTextBox(visualCard, "ID неба", "SkyId", "1234567 или 1,2,3,4,5,6", function(text)
	if SETTINGS.CustomSky then applySky(text) end
end)

local visualFxCard = makeCard("🎨 Визуальные фичи")
makeToggle(visualFxCard, "Watermark", "WatermarkEnabled")
makeToggle(visualFxCard, "└ FPS", "WatermarkFPS")
makeToggle(visualFxCard, "└ Пинг", "WatermarkPing")
makeToggle(visualFxCard, "└ Время", "WatermarkTime")
makeToggle(visualFxCard, "Stats Panel", "StatsEnabled")

makeToggle(visualFxCard, "Crosshair", "CrosshairEnabled")
makeDropdown(visualFxCard, "└ Стиль", "CrosshairStyle", {"Cross", "Circle", "Dot", "X"})
makeTextBox(visualFxCard, "└ Цвет", "CrosshairColorHex", "0,255,120")
makeSlider(visualFxCard, "└ Размер", "CrosshairSize", 4, 40)
makeSlider(visualFxCard, "└ Толщина", "CrosshairThickness", 1, 6)
makeSlider(visualFxCard, "└ Отступ", "CrosshairGap", 0, 20)

makeToggle(visualFxCard, "Tracers", "TracersEnabled")
makeDropdown(visualFxCard, "└ Откуда", "TracersFrom", {"Bottom", "Center"})
makeSlider(visualFxCard, "└ Толщина", "TracersThickness", 1, 5)
makeSlider(visualFxCard, "└ Прозрачность", "TracersTransparency", 0, 1)

local invCard = makeCard("🎒 Инвентарь")
makeToggle(invCard, "Показывать инвентарь", "InvEnabled")
makeToggle(invCard, "└ Показывать источник", "InvShowSource")
makeToggle(invCard, "└ Показывать иконки", "InvShowIcons")
makeToggle(invCard, "└ Другие игроки", "InvShowOthers")
makeSlider(invCard, "└ Макс. слотов", "InvMaxSlots", 5, 60)

local radarCard = makeCard("📡 Радар")
makeToggle(radarCard, "Включить радар", "RadarEnabled")
makeSlider(radarCard, "Размер", "RadarSize", 100, 300)
makeSlider(radarCard, "Дальность", "RadarRange", 50, 500)

local listCard = makeCard("👥 Список игроков")
makeToggle(listCard, "Показывать список", "PlayerListEnabled")

local previewCard = makeCard("👤 ESP Preview")
makeToggle(previewCard, "Показывать превью", "PreviewEnabled")
makeToggle(previewCard, "└ Вращать", "PreviewRotate")
makeSlider(previewCard, "└ Скорость вращения", "PreviewRotSpeed", 0, 180)
makeTextBox(previewCard, "└ Тестовый ник", "PreviewName", "Player123")
makeSlider(previewCard, "└ Тестовая дистанция", "PreviewDistance", 0, 500)

local perfCard = makeCard("⚡ Оптимизация")
makeToggle(perfCard, "Performance Mode", "PerformanceMode")
makeSlider(perfCard, "Visibility Hz", "VisibilityHz", 5, 60)
makeSlider(perfCard, "Target Hz", "TargetHz", 10, 60)
makeSlider(perfCard, "NPC Cache (сек)", "NPCCacheSec", 0.5, 5)

-- ============ ПОДСВЕТКА ТЕЛА ============
local bodySaved = {}

local function applyBodySkin(player)
	if player == LocalPlayer then return end
	local char = player.Character
	if not char then return end
	if not bodySaved[player] then bodySaved[player] = {} end
	local saved = bodySaved[player]
	local color = parseColor(SETTINGS.BodyColorHex)
	local material = getMaterial(SETTINGS.BodyMaterial)
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if not saved[part] then
				saved[part] = {Material = part.Material, Color = part.Color, Transparency = part.Transparency}
			end
			part.Material = material
			part.Color = color
			part.Transparency = SETTINGS.BodyTransparency
		end
	end
end

local function restoreBodySkin(player)
	local saved = bodySaved[player]
	if not saved then return end
	for part, data in pairs(saved) do
		if part and part.Parent then
			part.Material = data.Material
			part.Color = data.Color
			part.Transparency = data.Transparency
		end
	end
	bodySaved[player] = nil
end

function refreshAllBodySkins()
	if not SETTINGS.BodySkinEnabled then
		for player in pairs(bodySaved) do restoreBodySkin(player) end
		return
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then applyBodySkin(player) end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		if SETTINGS.BodySkinEnabled then applyBodySkin(player) end
	end)
end)
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			task.wait(0.5)
			if SETTINGS.BodySkinEnabled then applyBodySkin(player) end
		end)
	end
end
Players.PlayerRemoving:Connect(function(player) bodySaved[player] = nil end)

-- ============ ОКНО ============
local guiOpen = false
toggleBtn.MouseButton1Click:Connect(function()
	guiOpen = not guiOpen
	mainFrame.Visible = guiOpen
end)
makeDraggable(mainFrame, header)

-- ==================== ХЕЛПЕРЫ ====================

local function buildFilter(extra)
	local list = {}
	if LocalPlayer.Character then table.insert(list, LocalPlayer.Character) end
	if extra then table.insert(list, extra) end
	return list
end

local function getTargetPart(character)
	if SETTINGS.TargetPart == "Head" then return character:FindFirstChild("Head")
	elseif SETTINGS.TargetPart == "UpperTorso" then return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	elseif SETTINGS.TargetPart == "HumanoidRootPart" then return character:FindFirstChild("HumanoidRootPart") end
	return character:FindFirstChild("Head")
end

local function isPhantom(inst)
	if not SETTINGS.IgnorePhantom then return false end
	if not inst or not inst:IsA("BasePart") then return false end
	if inst.Transparency >= SETTINGS.PhantomTransparency then return true end
	if inst.Material == Enum.Material.ForceField and inst.Transparency > 0.5 then return true end
	if inst.CanCollide == false and inst.Transparency >= SETTINGS.PhantomTransparency then return true end
	return false
end

local function raycastSolid(origin, direction, params)
	if direction.Magnitude < 0.01 then return nil end
	local currentOrigin = origin
	local remainingDir = direction
	local dirUnit = direction.Unit
	for i = 1, 15 do
		local result = workspace:Raycast(currentOrigin, remainingDir, params)
		if not result then return nil end
		if not isPhantom(result.Instance) then return result end
		local newOrigin = result.Position + dirUnit * 0.05
		local traveled = (newOrigin - currentOrigin).Magnitude
		local remainingLen = remainingDir.Magnitude - traveled
		if remainingLen <= 0.05 then return nil end
		remainingDir = dirUnit * remainingLen
		currentOrigin = newOrigin
	end
	return nil
end

local function checkWalls(fromPos, toPos, targetChar)
	if not SETTINGS.WallCheck then return true end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = buildFilter(targetChar)
	params.IgnoreWater = true
	local direction = toPos - fromPos
	local totalDist = direction.Magnitude
	local ray1 = raycastSolid(fromPos, direction, params)
	if not ray1 then return true end
	local ray2 = raycastSolid(toPos, -direction, params)
	if not ray2 then return true end
	if ray1.Instance == ray2.Instance then
		return (totalDist - ray1.Distance - ray2.Distance) <= SETTINGS.MaxWallThickness
	end
	return false
end

local function isVisible(fromPos, toPos, targetChar)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = buildFilter(targetChar)
	params.IgnoreWater = true
	return raycastSolid(fromPos, toPos - fromPos, params) == nil
end

local function isAnyPartVisible(fromPos, character)
	if not character then return false end
	local head = character:FindFirstChild("Head")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if head and isVisible(fromPos, head.Position, character) then return true end
	if torso and isVisible(fromPos, torso.Position, character) then return true end
	if hrp and isVisible(fromPos, hrp.Position + Vector3.new(0, 1, 0), character) then return true end
	return false
end

local function predictPosition(targetPart, originPos)
	if not SETTINGS.PredictionEnabled then return targetPart.Position end
	local targetChar = targetPart.Parent
	if not targetChar then return targetPart.Position end
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
	if not targetHRP then return targetPart.Position end
	local targetVel = targetHRP.AssemblyLinearVelocity
	local myVel = Vector3.zero
	if LocalPlayer.Character then
		local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if myHRP then myVel = myHRP.AssemblyLinearVelocity end
	end
	local relVel = targetVel - myVel
	local predicted = targetPart.Position
	for i = 1, 3 do
		local dist = (predicted - originPos).Magnitude
		local time = dist / math.max(SETTINGS.BulletSpeed, 1)
		predicted = targetPart.Position + relVel * time * SETTINGS.PredictionMultiplier
	end
	return predicted
end

-- ==================== КЭШИ ====================
local npcCache = {}
local lastNPCRefresh = 0

local function refreshNPCCache()
	npcCache = {}
	local count = 0
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				table.insert(npcCache, obj)
				count = count + 1
				if count >= 100 then break end
			end
		end
	end
end

local visibilityCache = {}
local function updateVisibilityCache()
	local camPos = Camera.CFrame.Position
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer or not player.Character then
			visibilityCache[player] = false
		else
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				visibilityCache[player] = false
			else
				visibilityCache[player] = isAnyPartVisible(camPos, player.Character)
			end
		end
	end
end

-- ==================== АИМ ====================
local aiming = false
local cachedTarget = nil
local cachedPredictedPos = nil

local function findBestTarget()
	local best, bestDist = nil, math.huge
	local bestPredictedPos = nil
	local viewport = Camera.ViewportSize
	local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
	local origin = Camera.CFrame.Position

	local function processTarget(character, isNPC, targetPlayer)
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		if SETTINGS.TeamCheck and not isNPC and targetPlayer then
			if targetPlayer.Team and targetPlayer.Team == LocalPlayer.Team then return end
		end
		local part = getTargetPart(character)
		if not part then return end
		local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
		if not onScreen then return end
		local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
		if dist > SETTINGS.AimFOV then return end
		local predictedPos = predictPosition(part, origin)
		if not checkWalls(origin, predictedPos, character) then return end
		if dist < bestDist then
			best = part
			bestDist = dist
			bestPredictedPos = predictedPos
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer or not player.Character then continue end
		processTarget(player.Character, false, player)
	end

	if SETTINGS.AimAtNPCs then
		for _, npc in ipairs(npcCache) do
			processTarget(npc, true, nil)
		end
	end

	return best, bestPredictedPos
end

UserInputService.InputBegan:Connect(function(input, gp)
	if input.UserInputType == SETTINGS.AimKey then
		if SETTINGS.ToggleMode then aiming = not aiming else aiming = true end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == SETTINGS.AimKey and not SETTINGS.ToggleMode then aiming = false end
end)

-- ==================== FOV КРУГ ====================
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.ZIndex = 100
fovCircle.Visible = false
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner"); fovCorner.CornerRadius = UDim.new(1, 0); fovCorner.Parent = fovCircle
local fovStroke = Instance.new("UIStroke"); fovStroke.Color = THEME.Accent; fovStroke.Thickness = 1.5; fovStroke.Transparency = 0.2; fovStroke.Parent = fovCircle

-- ==================== SPEED ====================
local speedActive = false
local originalWalkSpeed = 16
local originalJumpPower = 50
local originalJumpHeight = 7.2
local isJumpPowerMode = true

local function onCharacterAdded(char)
	local humanoid = char:WaitForChild("Humanoid")
	task.wait(0.2)
	originalWalkSpeed = humanoid.WalkSpeed
	originalJumpPower = humanoid.JumpPower
	originalJumpHeight = humanoid.JumpHeight
	isJumpPowerMode = humanoid.UseJumpPower
end
if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == SETTINGS.SpeedKey then
		if SETTINGS.SpeedToggleMode then speedActive = not speedActive else speedActive = true end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == SETTINGS.SpeedKey and not SETTINGS.SpeedToggleMode then speedActive = false end
end)

local function getSpeedValues()
	if SETTINGS.SpeedMode == "Legit" then return 24, 50
	elseif SETTINGS.SpeedMode == "Rage" then return 120, 120 end
	return SETTINGS.WalkSpeed, SETTINGS.JumpPower
end

-- ==================== ESP ====================
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESPBoxes"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = PlayerGui

local boxes = {}
local headDots = {}

local function createBox(player)
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.ZIndex = 5
	frame.Parent = espGui

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
	fill.BorderSizePixel = 0
	fill.ZIndex = 4
	fill.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 255, 120)
	stroke.Thickness = 1.5
	stroke.Parent = frame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, 0, -18)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.ZIndex = 6
	nameLabel.Parent = frame

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, 0, 0, 14)
	distLabel.Position = UDim2.new(0, 0, 1, 2)
	distLabel.BackgroundTransparency = 1
	distLabel.Text = ""
	distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	distLabel.TextStrokeTransparency = 0.2
	distLabel.TextSize = 11
	distLabel.Font = Enum.Font.GothamMedium
	distLabel.ZIndex = 6
	distLabel.Parent = frame

	boxes[player] = {frame = frame, fill = fill, stroke = stroke, nameLabel = nameLabel, distLabel = distLabel}

	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.new(0, 6, 0, 6)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dot.BorderSizePixel = 0
	dot.ZIndex = 10
	dot.Visible = false
	dot.Parent = espGui
	local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot
	headDots[player] = dot
end

local function removeBox(player)
	if boxes[player] then boxes[player].frame:Destroy(); boxes[player] = nil end
	if headDots[player] then headDots[player]:Destroy(); headDots[player] = nil end
end

local function setupESP(player)
	if player == LocalPlayer then return end
	if not boxes[player] then createBox(player) end
	player.CharacterAdded:Connect(function()
		task.wait(0.3)
		if not boxes[player] then createBox(player) end
	end)
end

for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
Players.PlayerAdded:Connect(setupESP)
Players.PlayerRemoving:Connect(function(p) removeBox(p); bodySaved[p] = nil; visibilityCache[p] = nil end)

-- ==================== TRACERS ====================
local tracerGui = Instance.new("ScreenGui")
tracerGui.Name = "Tracers"
tracerGui.ResetOnSpawn = false
tracerGui.IgnoreGuiInset = true
tracerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tracerGui.Parent = PlayerGui

local tracers = {}
local function createTracer(player)
	if tracers[player] then return end
	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
	line.BorderSizePixel = 0
	line.ZIndex = 3
	line.Visible = false
	line.Parent = tracerGui
	tracers[player] = line
end
local function removeTracer(player)
	if tracers[player] then tracers[player]:Destroy(); tracers[player] = nil end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createTracer(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createTracer(p) end end)
Players.PlayerRemoving:Connect(removeTracer)

-- ==================== SKELETON ====================
local skeletonGui = Instance.new("ScreenGui")
skeletonGui.Name = "Skeleton"
skeletonGui.ResetOnSpawn = false
skeletonGui.IgnoreGuiInset = true
skeletonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
skeletonGui.Parent = PlayerGui

local skeletons = {}
local SKELETON_BONES_R15 = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
}
local SKELETON_BONES_R6 = {
	{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
	{"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function createSkeleton(player)
	if skeletons[player] then return end
	local lines = {}
	for i = 1, 14 do
		local l = Instance.new("Frame")
		l.AnchorPoint = Vector2.new(0.5, 0.5)
		l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		l.BorderSizePixel = 0
		l.ZIndex = 4
		l.Visible = false
		l.Parent = skeletonGui
		lines[i] = l
	end
	skeletons[player] = lines
end

local function removeSkeleton(player)
	if skeletons[player] then
		for _, l in ipairs(skeletons[player]) do l:Destroy() end
		skeletons[player] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createSkeleton(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createSkeleton(p) end end)
Players.PlayerRemoving:Connect(removeSkeleton)

-- ==================== HITMARKER ====================
local hitmarkerGui = Instance.new("ScreenGui")
hitmarkerGui.Name = "Hitmarker"
hitmarkerGui.ResetOnSpawn = false
hitmarkerGui.IgnoreGuiInset = true
hitmarkerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hitmarkerGui.Parent = PlayerGui

local hmContainer = Instance.new("Frame")
hmContainer.AnchorPoint = Vector2.new(0.5, 0.5)
hmContainer.Size = UDim2.new(0, 40, 0, 40)
hmContainer.BackgroundTransparency = 1
hmContainer.Visible = false
hmContainer.Parent = hitmarkerGui

local hmLines = {}
for i = 1, 4 do
	local l = Instance.new("Frame")
	l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	l.BorderSizePixel = 0
	l.Size = UDim2.new(0, 12, 0, 2)
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Rotation = ({45, 135, 225, 315})[i]
	local offsetX = ({-8, 8, 8, -8})[i]
	local offsetY = ({-8, -8, 8, 8})[i]
	l.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
	l.Parent = hmContainer
	hmLines[i] = l
end

local hmAlpha = 0

local function triggerHitmarker()
	if not SETTINGS.HitmarkerEnabled then return end
	hmAlpha = 1
	local vp = Camera.ViewportSize
	hmContainer.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
	hmContainer.Visible = true
end

local lastHealths = {}
task.spawn(function()
	while true do
		task.wait(0.05)
		if SETTINGS.HitmarkerEnabled then
			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer or not player.Character then continue end
				local hum = player.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					local prev = lastHealths[player]
					if prev and hum.Health < prev then
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart") then
							local d = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
							if d < 300 then triggerHitmarker() end
						end
					end
					lastHealths[player] = hum.Health
				end
			end
		end
	end
end)

-- ==================== WATERMARK ====================
local watermark = Instance.new("Frame")
watermark.Size = UDim2.new(0, 240, 0, 32)
watermark.Position = UDim2.new(0, 100, 0, 20)
watermark.BackgroundColor3 = THEME.BgHeader
watermark.BackgroundTransparency = 0.1
watermark.BorderSizePixel = 0
watermark.Visible = false
watermark.Parent = screenGui

local wmCorner = Instance.new("UICorner"); wmCorner.CornerRadius = UDim.new(0, 8); wmCorner.Parent = watermark
local wmStroke = Instance.new("UIStroke"); wmStroke.Color = THEME.Accent; wmStroke.Thickness = 1.5; wmStroke.Transparency = 0.4; wmStroke.Parent = watermark
local wmAccent = Instance.new("Frame"); wmAccent.Size = UDim2.new(0, 3, 1, -12); wmAccent.Position = UDim2.new(0, 0, 0, 6); wmAccent.BackgroundColor3 = THEME.Accent; wmAccent.BorderSizePixel = 0; wmAccent.Parent = watermark
local wmAC = Instance.new("UICorner"); wmAC.CornerRadius = UDim.new(1, 0); wmAC.Parent = wmAccent
local wmLabel = Instance.new("TextLabel")
wmLabel.Size = UDim2.new(1, -16, 1, 0)
wmLabel.Position = UDim2.new(0, 10, 0, 0)
wmLabel.BackgroundTransparency = 1
wmLabel.Text = "HUB UTILITY"
wmLabel.TextColor3 = THEME.TextMain
wmLabel.TextSize = 12
wmLabel.Font = Enum.Font.GothamBold
wmLabel.TextXAlignment = Enum.TextXAlignment.Left
wmLabel.Parent = watermark

makeDraggable(watermark)

-- ==================== STATS PANEL ====================
local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(0, 200, 0, 130)
statsPanel.Position = UDim2.new(1, -220, 0, 60)
statsPanel.BackgroundColor3 = THEME.BgHeader
statsPanel.BackgroundTransparency = 0.1
statsPanel.BorderSizePixel = 0
statsPanel.Visible = false
statsPanel.Parent = screenGui

local spC = Instance.new("UICorner"); spC.CornerRadius = UDim.new(0, 8); spC.Parent = statsPanel
local spS = Instance.new("UIStroke"); spS.Color = THEME.Accent; spS.Thickness = 1.5; spS.Transparency = 0.4; spS.Parent = statsPanel
local spP = Instance.new("UIPadding"); spP.PaddingTop = UDim.new(0, 8); spP.PaddingLeft = UDim.new(0, 10); spP.PaddingRight = UDim.new(0, 10); spP.Parent = statsPanel

local spTitle = Instance.new("TextLabel")
spTitle.Size = UDim2.new(1, 0, 0, 18)
spTitle.BackgroundTransparency = 1
spTitle.Text = "📊 STATS"
spTitle.TextColor3 = THEME.Accent
spTitle.TextSize = 12
spTitle.Font = Enum.Font.GothamBold
spTitle.TextXAlignment = Enum.TextXAlignment.Left
spTitle.Parent = statsPanel

local statsRows = {}
local statNames = {"FPS", "Ping", "Players", "Time"}
for i, name in ipairs(statNames) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.Position = UDim2.new(0, 0, 0, 22 + (i - 1) * 20)
	row.BackgroundTransparency = 1
	row.Parent = statsPanel

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = THEME.TextDim
	lbl.TextSize = 12
	lbl.Font = Enum.Font.Gotham
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.5, 0, 1, 0)
	val.Position = UDim2.new(0.5, 0, 0, 0)
	val.BackgroundTransparency = 1
	val.Text = "—"
	val.TextColor3 = THEME.TextMain
	val.TextSize = 12
	val.Font = Enum.Font.GothamBold
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = row

	statsRows[name] = val
end

makeDraggable(statsPanel, spTitle)

-- ==================== CROSSHAIR ====================
local crosshairGui = Instance.new("ScreenGui")
crosshairGui.Name = "Crosshair"
crosshairGui.ResetOnSpawn = false
crosshairGui.IgnoreGuiInset = true
crosshairGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
crosshairGui.Parent = PlayerGui

local crossContainer = Instance.new("Frame")
crossContainer.AnchorPoint = Vector2.new(0.5, 0.5)
crossContainer.Size = UDim2.new(0, 100, 0, 100)
crossContainer.BackgroundTransparency = 1
crossContainer.Visible = false
crossContainer.Parent = crosshairGui

local crossParts = {}
for i = 1, 4 do
	local l = Instance.new("Frame")
	l.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
	l.BorderSizePixel = 0
	l.Parent = crossContainer
	crossParts[i] = l
end

local dot = Instance.new("Frame")
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0.5, 0)
dot.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
dot.BorderSizePixel = 0
dot.Parent = crossContainer

local circleStroke = Instance.new("Frame")
circleStroke.AnchorPoint = Vector2.new(0.5, 0.5)
circleStroke.Position = UDim2.new(0.5, 0, 0.5, 0)
circleStroke.BackgroundTransparency = 1
circleStroke.BorderSizePixel = 0
circleStroke.Parent = crossContainer

local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(1, 0); cc.Parent = circleStroke
local co = Instance.new("UIStroke"); co.Color = Color3.fromRGB(0, 255, 120); co.Thickness = 2; co.Parent = circleStroke

local lastCrossKey = ""

-- ==================== INVENTORY ====================
local invGui = Instance.new("ScreenGui")
invGui.Name = "InventoryViewer"
invGui.ResetOnSpawn = false
invGui.IgnoreGuiInset = true
invGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
invGui.Parent = PlayerGui

local invFrame = Instance.new("Frame")
invFrame.Size = UDim2.new(0, 380, 0, 420)
invFrame.Position = UDim2.new(1, -400, 0, 100)
invFrame.BackgroundColor3 = THEME.BgMain
invFrame.BackgroundTransparency = 0.05
invFrame.BorderSizePixel = 0
invFrame.Visible = false
invFrame.Parent = invGui

local ic = Instance.new("UICorner"); ic.CornerRadius = UDim.new(0, 10); ic.Parent = invFrame
local is2 = Instance.new("UIStroke"); is2.Color = THEME.Accent; is2.Thickness = 1.5; is2.Transparency = 0.4; is2.Parent = invFrame

local invHeader = Instance.new("Frame")
invHeader.Size = UDim2.new(1, 0, 0, 34)
invHeader.BackgroundColor3 = THEME.BgHeader
invHeader.BorderSizePixel = 0
invHeader.Parent = invFrame

local ihc = Instance.new("UICorner"); ihc.CornerRadius = UDim.new(0, 10); ihc.Parent = invHeader
local ihf = Instance.new("Frame"); ihf.Size = UDim2.new(1, 0, 0, 12); ihf.Position = UDim2.new(0, 0, 1, -12); ihf.BackgroundColor3 = THEME.BgHeader; ihf.BorderSizePixel = 0; ihf.Parent = invHeader

local invTitle = Instance.new("TextLabel")
invTitle.Size = UDim2.new(1, -16, 1, 0)
invTitle.Position = UDim2.new(0, 10, 0, 0)
invTitle.BackgroundTransparency = 1
invTitle.Text = "🎒 INVENTORY"
invTitle.TextColor3 = THEME.TextMain
invTitle.TextSize = 13
invTitle.Font = Enum.Font.GothamBold
invTitle.TextXAlignment = Enum.TextXAlignment.Left
invTitle.Parent = invHeader

local invScroll = Instance.new("ScrollingFrame")
invScroll.Size = UDim2.new(1, -16, 1, -44)
invScroll.Position = UDim2.new(0, 8, 0, 38)
invScroll.BackgroundTransparency = 1
invScroll.BorderSizePixel = 0
invScroll.ScrollBarThickness = 3
invScroll.ScrollBarImageColor3 = THEME.Accent
invScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
invScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
invScroll.Parent = invFrame

local invGrid = Instance.new("UIGridLayout")
invGrid.CellSize = UDim2.new(0, 78, 0, 78)
invGrid.CellPadding = UDim2.new(0, 6, 0, 6)
invGrid.SortOrder = Enum.SortOrder.LayoutOrder
invGrid.Parent = invScroll

local invPad = Instance.new("UIPadding")
invPad.PaddingTop = UDim.new(0, 6); invPad.PaddingLeft = UDim.new(0, 6)
invPad.PaddingRight = UDim.new(0, 6); invPad.PaddingBottom = UDim.new(0, 6)
invPad.Parent = invScroll

makeDraggable(invFrame, invHeader)

local invSlots = {}

local function getToolIcon(tool)
	if not tool:IsA("Tool") then return nil end
	local ok, tid = pcall(function() return tool.TextureId end)
	if ok and tid and tid ~= "" then return tid end
	local handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		for _, d in ipairs(handle:GetDescendants()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				if d.Texture ~= "" then return d.Texture end
			end
		end
		if handle:IsA("MeshPart") and handle.TextureID ~= "" then return handle.TextureID end
	end
	for _, d in ipairs(tool:GetChildren()) do
		if (d:IsA("Decal") or d:IsA("Texture")) and d.Texture ~= "" then return d.Texture end
	end
	return nil
end

local function getItemSource(tool, ownerPlayer)
	if tool.Parent == ownerPlayer.Backpack then return "Backpack", Color3.fromRGB(0, 200, 255)
	elseif tool.Parent == ownerPlayer.Character then return "Equipped", Color3.fromRGB(255, 200, 0)
	elseif tool.Parent == ownerPlayer:FindFirstChild("StarterGear") then return "StarterGear", Color3.fromRGB(255, 180, 0)
	else return tostring(tool.Parent and tool.Parent.Name or "?"), Color3.fromRGB(160, 160, 160) end
end

local function gatherTools(player)
	local tools = {}
	if player.Backpack then
		for _, t in ipairs(player.Backpack:GetChildren()) do
			if t:IsA("Tool") then table.insert(tools, t) end
		end
	end
	if player.Character then
		for _, t in ipairs(player.Character:GetChildren()) do
			if t:IsA("Tool") then table.insert(tools, t) end
		end
	end
	local sg = player:FindFirstChild("StarterGear")
	if sg then
		for _, t in ipairs(sg:GetChildren()) do
			if t:IsA("Tool") then table.insert(tools, t) end
		end
	end
	return tools
end

local function updateInventory()
	if not SETTINGS.InvEnabled then
		invFrame.Visible = false
		for _, slot in pairs(invSlots) do slot.frame.Visible = false end
		return
	end
	invFrame.Visible = true

	local targetPlayer = LocalPlayer
	if SETTINGS.InvShowOthers then
		local closest, closestDist = nil, math.huge
		local myPos = Camera.CFrame.Position
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
				if d < closestDist then closest = p; closestDist = d end
			end
		end
		if closest then targetPlayer = closest end
	end

	invTitle.Text = "🎒 " .. targetPlayer.Name:upper()
	local tools = gatherTools(targetPlayer)

	table.sort(tools, function(a, b)
		local aEq = (a.Parent == targetPlayer.Character) and 1 or 0
		local bEq = (b.Parent == targetPlayer.Character) and 1 or 0
		if aEq ~= bEq then return aEq > bEq end
		return a.Name < b.Name
	end)

	local maxSlots = math.min(SETTINGS.InvMaxSlots, #tools)

	for i = 1, math.max(maxSlots, #invSlots) do
		local tool = tools[i]
		if i <= maxSlots and tool then
			if not invSlots[i] then
				local slot = Instance.new("Frame")
				slot.BackgroundColor3 = THEME.CardBg
				slot.BorderSizePixel = 0
				slot.Parent = invScroll

				local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 8); sc.Parent = slot
				local ss = Instance.new("UIStroke"); ss.Color = THEME.Stroke; ss.Thickness = 1; ss.Parent = slot

				local icon = Instance.new("ImageLabel")
				icon.Size = UDim2.new(1, -8, 1, -28)
				icon.Position = UDim2.new(0, 4, 0, 4)
				icon.BackgroundTransparency = 1
				icon.ScaleType = Enum.ScaleType.Fit
				icon.Parent = slot

				local eqBadge = Instance.new("TextLabel")
				eqBadge.Size = UDim2.new(1, 0, 0, 12)
				eqBadge.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
				eqBadge.BackgroundTransparency = 0.15
				eqBadge.Text = "★ EQUIPPED"
				eqBadge.TextColor3 = Color3.fromRGB(40, 30, 0)
				eqBadge.TextSize = 9
				eqBadge.Font = Enum.Font.GothamBold
				eqBadge.Visible = false
				eqBadge.ZIndex = 7
				eqBadge.Parent = slot

				local ebc = Instance.new("UICorner"); ebc.CornerRadius = UDim.new(0, 4); ebc.Parent = eqBadge

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(1, -8, 0, 12)
				nameLbl.Position = UDim2.new(0, 4, 1, -26)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Text = "Tool"
				nameLbl.TextColor3 = THEME.TextMain
				nameLbl.TextSize = 10
				nameLbl.Font = Enum.Font.GothamBold
				nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
				nameLbl.Parent = slot

				local sourceLbl = Instance.new("TextLabel")
				sourceLbl.Size = UDim2.new(1, -8, 0, 10)
				sourceLbl.Position = UDim2.new(0, 4, 1, -14)
				sourceLbl.BackgroundTransparency = 1
				sourceLbl.Text = "Backpack"
				sourceLbl.TextColor3 = THEME.TextDim
				sourceLbl.TextSize = 9
				sourceLbl.Font = Enum.Font.Gotham
				sourceLbl.TextXAlignment = Enum.TextXAlignment.Left
				sourceLbl.Parent = slot

				invSlots[i] = {frame = slot, stroke = ss, icon = icon, nameLbl = nameLbl, sourceLbl = sourceLbl, eqBadge = eqBadge}
			end

			local sd = invSlots[i]
			sd.frame.Visible = true

			local iconUrl = SETTINGS.InvShowIcons and getToolIcon(tool) or nil
			if iconUrl then
				sd.icon.Image = iconUrl
				sd.icon.BackgroundTransparency = 1
			else
				sd.icon.Image = ""
				sd.icon.BackgroundColor3 = THEME.ElementBg
				sd.icon.BackgroundTransparency = 0.6
			end

			sd.nameLbl.Text = tool.Name

			if SETTINGS.InvShowSource then
				local src, srcColor = getItemSource(tool, targetPlayer)
				sd.sourceLbl.Text = src
				sd.sourceLbl.TextColor3 = srcColor
				sd.sourceLbl.Visible = true
				sd.stroke.Color = srcColor
			else
				sd.sourceLbl.Visible = false
				sd.stroke.Color = THEME.Stroke
			end

			if tool.Parent == targetPlayer.Character then
				sd.frame.BackgroundColor3 = Color3.fromRGB(50, 45, 20)
				sd.stroke.Color = Color3.fromRGB(255, 200, 0)
				sd.stroke.Thickness = 2
				sd.eqBadge.Visible = true
			else
				sd.frame.BackgroundColor3 = THEME.CardBg
				sd.stroke.Thickness = 1
				sd.eqBadge.Visible = false
			end
		elseif invSlots[i] then
			invSlots[i].frame.Visible = false
		end
	end
end

-- ==================== RADAR ====================
local radarGui = Instance.new("ScreenGui")
radarGui.Name = "Radar"
radarGui.ResetOnSpawn = false
radarGui.IgnoreGuiInset = true
radarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
radarGui.Parent = PlayerGui

local radarFrame = Instance.new("Frame")
radarFrame.Size = UDim2.new(0, 150, 0, 150)
radarFrame.Position = UDim2.new(1, -170, 0, 20)
radarFrame.BackgroundColor3 = THEME.BgMain
radarFrame.BackgroundTransparency = 0.3
radarFrame.BorderSizePixel = 0
radarFrame.Visible = false
radarFrame.ClipsDescendants = true
radarFrame.Parent = radarGui

local rfc = Instance.new("UICorner"); rfc.CornerRadius = UDim.new(1, 0); rfc.Parent = radarFrame
local rfs = Instance.new("UIStroke"); rfs.Color = THEME.Accent; rfs.Thickness = 2; rfs.Transparency = 0.3; rfs.Parent = radarFrame

local radarCenter = Instance.new("Frame")
radarCenter.AnchorPoint = Vector2.new(0.5, 0.5)
radarCenter.Size = UDim2.new(0, 8, 0, 8)
radarCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
radarCenter.BackgroundColor3 = THEME.Accent
radarCenter.BorderSizePixel = 0
radarCenter.ZIndex = 10
radarCenter.Parent = radarFrame

local rcc = Instance.new("UICorner"); rcc.CornerRadius = UDim.new(1, 0); rcc.Parent = radarCenter

local radarH = Instance.new("Frame"); radarH.Size = UDim2.new(1, 0, 0, 1); radarH.Position = UDim2.new(0, 0, 0.5, 0); radarH.BackgroundColor3 = THEME.Stroke; radarH.BorderSizePixel = 0; radarH.BackgroundTransparency = 0.5; radarH.Parent = radarFrame
local radarV = Instance.new("Frame"); radarV.Size = UDim2.new(0, 1, 1, 0); radarV.Position = UDim2.new(0.5, 0, 0, 0); radarV.BackgroundColor3 = THEME.Stroke; radarV.BorderSizePixel = 0; radarV.BackgroundTransparency = 0.5; radarV.Parent = radarFrame

makeDraggable(radarFrame)

local radarDots = {}

-- ==================== PLAYER LIST ====================
local listGui = Instance.new("ScreenGui")
listGui.Name = "PlayerList"
listGui.ResetOnSpawn = false
listGui.IgnoreGuiInset = true
listGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
listGui.Parent = PlayerGui

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0, 260, 0, 40)
listFrame.Position = UDim2.new(0, 100, 0, 60)
listFrame.BackgroundColor3 = THEME.BgMain
listFrame.BackgroundTransparency = 0.1
listFrame.BorderSizePixel = 0
listFrame.AutomaticSize = Enum.AutomaticSize.Y
listFrame.Visible = false
listFrame.Parent = listGui

local lfc = Instance.new("UICorner"); lfc.CornerRadius = UDim.new(0, 10); lfc.Parent = listFrame
local lfs = Instance.new("UIStroke"); lfs.Color = THEME.Accent; lfs.Thickness = 1.5; lfs.Transparency = 0.4; lfs.Parent = listFrame

local listLayoutV = Instance.new("UIListLayout")
listLayoutV.Padding = UDim.new(0, 4); listLayoutV.SortOrder = Enum.SortOrder.LayoutOrder; listLayoutV.Parent = listFrame

local listPad = Instance.new("UIPadding")
listPad.PaddingTop = UDim.new(0, 8); listPad.PaddingBottom = UDim.new(0, 8)
listPad.PaddingLeft = UDim.new(0, 10); listPad.PaddingRight = UDim.new(0, 10)
listPad.Parent = listFrame

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, 0, 0, 20)
listTitle.BackgroundTransparency = 1
listTitle.Text = "👥 PLAYERS"
listTitle.TextColor3 = THEME.Accent
listTitle.TextSize = 12
listTitle.Font = Enum.Font.GothamBold
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Parent = listFrame

makeDraggable(listFrame, listTitle)

local listRows = {}

local function makeListRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 24)
	row.BackgroundColor3 = THEME.CardBg
	row.BorderSizePixel = 0
	row.Parent = listFrame

	local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = row

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(0.6, 0, 1, 0)
	nameL.Position = UDim2.new(0, 8, 0, 0)
	nameL.BackgroundTransparency = 1
	nameL.Text = player.Name
	nameL.TextColor3 = THEME.TextMain
	nameL.TextSize = 12
	nameL.Font = Enum.Font.GothamMedium
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.TextTruncate = Enum.TextTruncate.AtEnd
	nameL.Parent = row

	local hpBg = Instance.new("Frame")
	hpBg.Size = UDim2.new(0.35, 0, 0, 8)
	hpBg.Position = UDim2.new(0.62, 0, 0.5, -4)
	hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	hpBg.BorderSizePixel = 0
	hpBg.Parent = row

	local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(1, 0); hc.Parent = hpBg

	local hpFill = Instance.new("Frame")
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg

	local hfc = Instance.new("UICorner"); hfc.CornerRadius = UDim.new(1, 0); hfc.Parent = hpFill

	local hpTxt = Instance.new("TextLabel")
	hpTxt.Size = UDim2.new(0.35, 0, 1, 0)
	hpTxt.Position = UDim2.new(0.62, 0, 0, 0)
	hpTxt.BackgroundTransparency = 1
	hpTxt.Text = "100"
	hpTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpTxt.TextSize = 9
	hpTxt.Font = Enum.Font.GothamBold
	hpTxt.TextStrokeTransparency = 0.5
	hpTxt.ZIndex = 5
	hpTxt.Parent = row

	listRows[player] = {row = row, hpFill = hpFill, hpTxt = hpTxt}
end

local function removeListRow(player)
	if listRows[player] then listRows[player].row:Destroy(); listRows[player] = nil end
end

Players.PlayerRemoving:Connect(removeListRow)

-- ==================== ESP PREVIEW ====================
local previewGui = Instance.new("ScreenGui")
previewGui.Name = "ESPPreview"
previewGui.ResetOnSpawn = false
previewGui.IgnoreGuiInset = true
previewGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
previewGui.Parent = PlayerGui

local previewFrame = Instance.new("Frame")
previewFrame.Size = UDim2.new(0, 220, 0, 360)
previewFrame.Position = UDim2.new(1, -240, 0.5, -180)
previewFrame.BackgroundColor3 = THEME.BgMain
previewFrame.BackgroundTransparency = 0.05
previewFrame.BorderSizePixel = 0
previewFrame.Visible = false
previewFrame.Parent = previewGui

local pfc = Instance.new("UICorner"); pfc.CornerRadius = UDim.new(0, 12); pfc.Parent = previewFrame
local pfs = Instance.new("UIStroke"); pfs.Color = THEME.Accent; pfs.Thickness = 1.5; pfs.Transparency = 0.4; pfs.Parent = previewFrame

local previewTitle = Instance.new("TextLabel")
previewTitle.Size = UDim2.new(1, -16, 0, 30)
previewTitle.Position = UDim2.new(0, 8, 0, 6)
previewTitle.BackgroundTransparency = 1
previewTitle.Text = "👤 ESP PREVIEW"
previewTitle.TextColor3 = THEME.Accent
previewTitle.TextSize = 12
previewTitle.Font = Enum.Font.GothamBold
previewTitle.TextXAlignment = Enum.TextXAlignment.Left
previewTitle.Parent = previewFrame

makeDraggable(previewFrame, previewTitle)

local viewHolder = Instance.new("Frame")
viewHolder.Size = UDim2.new(1, -20, 1, -50)
viewHolder.Position = UDim2.new(0, 10, 0, 40)
viewHolder.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
viewHolder.BorderSizePixel = 0
viewHolder.ClipsDescendants = true
viewHolder.Parent = previewFrame

local vhc = Instance.new("UICorner"); vhc.CornerRadius = UDim.new(0, 8); vhc.Parent = viewHolder

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.new(1, 0, 1, 0)
viewport.BackgroundTransparency = 1
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(180, 180, 180)
viewport.LightColor = Color3.fromRGB(255, 255, 255)
viewport.LightDirection = Vector3.new(-1, -1, -1)
viewport.Parent = viewHolder

local worldModel = Instance.new("WorldModel"); worldModel.Parent = viewport
local viewCam = Instance.new("Camera"); viewCam.Parent = viewport; viewport.CurrentCamera = viewCam

local dummy = Instance.new("Model"); dummy.Name = "PreviewDummy"; dummy.Parent = worldModel

local function makePart(size, pos, name, parent)
	local p = Instance.new("Part")
	p.Size = size; p.Position = pos; p.Name = name
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.Color = Color3.fromRGB(180, 180, 180)
	p.Parent = parent
	return p
end

local previewParts = {
	torso = makePart(Vector3.new(2, 2, 1), Vector3.new(0, 0, 0), "Torso", dummy),
	head = makePart(Vector3.new(1.25, 1.25, 1.25), Vector3.new(0, 1.625, 0), "Head", dummy),
	leftArm = makePart(Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0), "LeftArm", dummy),
	rightArm = makePart(Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0), "RightArm", dummy),
	leftLeg = makePart(Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0), "LeftLeg", dummy),
	rightLeg = makePart(Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0), "RightLeg", dummy),
}

local previewBox = Instance.new("Frame")
previewBox.AnchorPoint = Vector2.new(0.5, 0.5)
previewBox.Size = UDim2.new(0, 90, 0, 200)
previewBox.Position = UDim2.new(0.5, 0, 0.5, 0)
previewBox.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
previewBox.BackgroundTransparency = 0.88
previewBox.BorderSizePixel = 0
previewBox.ZIndex = 5
previewBox.Parent = viewHolder

local pbs = Instance.new("UIStroke"); pbs.Color = Color3.fromRGB(0, 255, 120); pbs.Thickness = 1.5; pbs.Parent = previewBox

local previewName = Instance.new("TextLabel")
previewName.Size = UDim2.new(1, 0, 0, 16)
previewName.Position = UDim2.new(0, 0, 0, -18)
previewName.BackgroundTransparency = 1
previewName.Text = "Player123"
previewName.TextColor3 = Color3.fromRGB(255, 255, 255)
previewName.TextStrokeTransparency = 0.2
previewName.TextSize = 12
previewName.Font = Enum.Font.GothamBold
previewName.ZIndex = 6
previewName.Parent = previewBox

local previewDist = Instance.new("TextLabel")
previewDist.Size = UDim2.new(1, 0, 0, 14)
previewDist.Position = UDim2.new(0, 0, 1, 2)
previewDist.BackgroundTransparency = 1
previewDist.Text = "42 studs"
previewDist.TextColor3 = Color3.fromRGB(220, 220, 220)
previewDist.TextStrokeTransparency = 0.2
previewDist.TextSize = 11
previewDist.Font = Enum.Font.GothamMedium
previewDist.ZIndex = 6
previewDist.Parent = previewBox

local previewAngle = 0
local previewLastTime = tick()

local function applyPreviewBodySkin()
	local color = parseColor(SETTINGS.BodyColorHex)
	local material = getMaterial(SETTINGS.BodyMaterial)
	for _, part in pairs(previewParts) do
		if SETTINGS.BodySkinEnabled then
			part.Material = material
			part.Color = color
			part.Transparency = SETTINGS.BodyTransparency
		else
			part.Material = Enum.Material.SmoothPlastic
			part.Color = Color3.fromRGB(180, 180, 180)
			part.Transparency = 0
		end
	end
end

-- ═══════════════════════════════════════════════════════════════
-- SILENT AIM (ОПРЕДЕЛЕНИЕ ДО MASTER LOOP!)
-- ═══════════════════════════════════════════════════════════════

local silentTarget = nil
local silentPredicted = nil
local silentLastShot = 0
local silentFiring = false

local function getActiveTool()
	local char = LocalPlayer.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Tool")
end

local function silentFire()
	if silentFiring then return end
	if not silentTarget then return end
	if SETTINGS.SilentAimOnlyWhenVisible then
		if not isAnyPartVisible(Camera.CFrame.Position, silentTarget.Parent) then return end
	end
	local tool = getActiveTool()
	if not tool or not tool:FindFirstChild("Handle") then return end

	silentFiring = true
	local realCF = Camera.CFrame
	local aimPos = silentPredicted or silentTarget.Position
	Camera.CFrame = CFrame.new(realCF.Position, aimPos)
	RunService.RenderStepped:Wait()
	pcall(function() tool:Activate() end)
	Camera.CFrame = realCF
	silentFiring = false
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if not SETTINGS.SilentAimEnabled then return end
	if SETTINGS.SilentAimAutoFire then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	silentFire()
end)

-- ═══════════════════════════════════════════════════════════════
-- МАСТЕР-ЦИКЛ
-- ═══════════════════════════════════════════════════════════════

local frameCounter = 0
local lastTargetSearch = 0
local lastVisibility = 0
local lastNPC = 0
local lastWatermark = 0
local lastStats = 0
local lastInv = 0
local lastList = 0
local fps = 60
local fpsFrames = 0
local fpsLastTime = tick()
local pingMs = 0

local espVisibleColor = parseColor(SETTINGS.ESPVisibleColor)
local espHiddenColor = parseColor(SETTINGS.ESPHiddenColor)
local lastBodyState = ""

RunService.RenderStepped:Connect(function(dt)
	frameCounter = frameCounter + 1

	fpsFrames = fpsFrames + 1
	local nowT = tick()
	if nowT - fpsLastTime >= 1 then
		fps = fpsFrames
		fpsFrames = 0
		fpsLastTime = nowT
		pingMs = math.floor(LocalPlayer:GetNetworkPing() * 1000)
	end

	local visHz = SETTINGS.PerformanceMode and math.min(SETTINGS.VisibilityHz, 10) or SETTINGS.VisibilityHz
	local tgtHz = SETTINGS.PerformanceMode and math.min(SETTINGS.TargetHz, 30) or SETTINGS.TargetHz
	local npcSec = SETTINGS.PerformanceMode and math.max(SETTINGS.NPCCacheSec, 2) or SETTINGS.NPCCacheSec
	local now = tick()

	if SETTINGS.AimAtNPCs and (now - lastNPC > npcSec) then
		lastNPC = now
		refreshNPCCache()
	end

	if SETTINGS.AimEnabled and aiming then
		if now - lastTargetSearch > (1 / tgtHz) then
			lastTargetSearch = now
			cachedTarget, cachedPredictedPos = findBestTarget()
		end
	end

	if SETTINGS.AimEnabled and aiming and cachedTarget then
		local currentCF = Camera.CFrame
		local aimPos = cachedPredictedPos or cachedTarget.Position
		local targetCF = CFrame.new(currentCF.Position, aimPos)
		local smoothness = math.clamp(SETTINGS.Smoothness, 0, 0.95)
		local alpha = 1 - smoothness
		alpha = 1 - (1 - alpha) ^ (dt * 60)
		Camera.CFrame = currentCF:Lerp(targetCF, alpha)
	end

	if Camera.FieldOfView ~= SETTINGS.CameraFOV then
		Camera.FieldOfView = SETTINGS.CameraFOV
	end

	if now - lastVisibility > (1 / visHz) then
		lastVisibility = now
		updateVisibilityCache()
	end

	do
		local char = LocalPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if SETTINGS.SpeedEnabled and speedActive then
				local ws, jp = getSpeedValues()
				if humanoid.WalkSpeed ~= ws then humanoid.WalkSpeed = ws end
				if isJumpPowerMode then
					if humanoid.JumpPower ~= jp then humanoid.JumpPower = jp end
				else
					local jh = jp / 7.2
					if humanoid.JumpHeight ~= jh then humanoid.JumpHeight = jh end
				end
			else
				if humanoid.WalkSpeed ~= originalWalkSpeed then humanoid.WalkSpeed = originalWalkSpeed end
				if isJumpPowerMode then
					if humanoid.JumpPower ~= originalJumpPower then humanoid.JumpPower = originalJumpPower end
				else
					if humanoid.JumpHeight ~= originalJumpHeight then humanoid.JumpHeight = originalJumpHeight end
				end
			end
		end
	end

	if SETTINGS.ShowFOVCircle and SETTINGS.AimEnabled then
		local vp = Camera.ViewportSize
		fovCircle.Visible = true
		fovCircle.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
		fovCircle.Size = UDim2.new(0, SETTINGS.AimFOV * 2, 0, SETTINGS.AimFOV * 2)
	else
		fovCircle.Visible = false
	end

	espVisibleColor = parseColor(SETTINGS.ESPVisibleColor)
	espHiddenColor = parseColor(SETTINGS.ESPHiddenColor)

	local camPos = Camera.CFrame.Position
	local lodDist = SETTINGS.LODEnabled and SETTINGS.LODDistance or SETTINGS.ESPMaxDistance

	if SETTINGS.ESPEnabled then
		for player, data in pairs(boxes) do
			local char = player.Character
			if not char then
				data.frame.Visible = false
				if headDots[player] then headDots[player].Visible = false end
				continue
			end
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				data.frame.Visible = false
				if headDots[player] then headDots[player].Visible = false end
				continue
			end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			local head = char:FindFirstChild("Head")
			if not hrp or not head then
				data.frame.Visible = false
				if headDots[player] then headDots[player].Visible = false end
				continue
			end

			local dist = (hrp.Position - camPos).Magnitude
			if dist > lodDist then
				data.frame.Visible = false
				if headDots[player] then headDots[player].Visible = false end
				continue
			end

			local topPos = head.Position + Vector3.new(0, 0.5, 0)
			local bottomPos = hrp.Position - Vector3.new(0, 3, 0)
			local topScreen, topOn = Camera:WorldToViewportPoint(topPos)
			local botScreen, botOn = Camera:WorldToViewportPoint(bottomPos)

			if not topOn or not botOn then
				data.frame.Visible = false
				if headDots[player] then headDots[player].Visible = false end
				continue
			end

			local topVec = Vector2.new(topScreen.X, topScreen.Y)
			local botVec = Vector2.new(botScreen.X, botScreen.Y)
			local height = math.abs(botVec.Y - topVec.Y)
			local width = height * 0.55

			if height < 5 then
				data.frame.Visible = false
				if headDots[player] then headDots[player].Visible = false end
				continue
			end

			local centerX = (topVec.X + botVec.X) / 2
			data.frame.Position = UDim2.new(0, centerX - width / 2, 0, math.min(topVec.Y, botVec.Y))
			data.frame.Size = UDim2.new(0, width, 0, height)
			data.frame.Visible = true

			local isVis = visibilityCache[player] or false
			local color = isVis and espVisibleColor or espHiddenColor
			data.stroke.Color = color
			data.stroke.Thickness = SETTINGS.ESPThickness
			data.fill.BackgroundColor3 = color
			data.fill.BackgroundTransparency = SETTINGS.ESPTransparency
			data.nameLabel.Visible = SETTINGS.ESPName
			data.nameLabel.Text = player.Name
			data.distLabel.Visible = SETTINGS.ESPDistance
			data.distLabel.Text = math.floor(dist) .. " studs"

			if SETTINGS.HeadDotEnabled and headDots[player] then
				local hScreen, hOn = Camera:WorldToViewportPoint(head.Position)
				if hOn then
					local d = headDots[player]
					d.Visible = true
					d.Position = UDim2.new(0, hScreen.X, 0, hScreen.Y)
					d.Size = UDim2.new(0, SETTINGS.HeadDotSize, 0, SETTINGS.HeadDotSize)
					d.BackgroundColor3 = color
				else
					headDots[player].Visible = false
				end
			elseif headDots[player] then
				headDots[player].Visible = false
			end
		end
	else
		for _, data in pairs(boxes) do data.frame.Visible = false end
		for _, d in pairs(headDots) do d.Visible = false end
	end

	if SETTINGS.TracersEnabled then
		local vp = Camera.ViewportSize
		local oX, oY
		if SETTINGS.TracersFrom == "Bottom" then oX = vp.X / 2; oY = vp.Y
		else oX = vp.X / 2; oY = vp.Y / 2 end

		for player, line in pairs(tracers) do
			local char = player.Character
			if not char then line.Visible = false; continue end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then line.Visible = false; continue end
			local head = char:FindFirstChild("Head")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not head and not hrp then line.Visible = false; continue end

			local tPos = head and head.Position or hrp.Position
			local sp, on = Camera:WorldToViewportPoint(tPos)
			if not on then line.Visible = false; continue end

			local isVis = visibilityCache[player] or false
			local color = isVis and espVisibleColor or espHiddenColor
			local tX, tY = sp.X, sp.Y
			local dx, dy = tX - oX, tY - oY
			local len = math.sqrt(dx*dx + dy*dy)
			local angle = math.deg(math.atan2(dy, dx))

			line.Size = UDim2.new(0, len, 0, SETTINGS.TracersThickness)
			line.Position = UDim2.new(0, (oX + tX) / 2, 0, (oY + tY) / 2)
			line.Rotation = angle
			line.BackgroundColor3 = color
			line.BackgroundTransparency = SETTINGS.TracersTransparency
			line.Visible = true
		end
	else
		for _, line in pairs(tracers) do line.Visible = false end
	end

	if SETTINGS.SkeletonEnabled then
		for player, lines in pairs(skeletons) do
			local char = player.Character
			if not char then
				for _, l in ipairs(lines) do l.Visible = false end
				continue
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				for _, l in ipairs(lines) do l.Visible = false end
				continue
			end
			local hrp2 = char:FindFirstChild("HumanoidRootPart")
			local dist = hrp2 and (hrp2.Position - camPos).Magnitude or 1000
			if dist > lodDist then
				for _, l in ipairs(lines) do l.Visible = false end
				continue
			end

			local bones = (hum.RigType == Enum.HumanoidRigType.R15) and SKELETON_BONES_R15 or SKELETON_BONES_R6
			local isVis = visibilityCache[player] or false
			local color = isVis and espVisibleColor or espHiddenColor

			for i, line in ipairs(lines) do
				local bone = bones[i]
				if not bone then line.Visible = false; continue end
				local p1 = char:FindFirstChild(bone[1])
				local p2 = char:FindFirstChild(bone[2])
				if not p1 or not p2 then line.Visible = false; continue end
				local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
				local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
				if not on1 or not on2 then line.Visible = false; continue end
				local v1 = Vector2.new(s1.X, s1.Y)
				local v2 = Vector2.new(s2.X, s2.Y)
				local d = v2 - v1
				local len = d.Magnitude
				local angle = math.deg(math.atan2(d.Y, d.X))
				line.Size = UDim2.new(0, len, 0, SETTINGS.SkeletonThickness)
				line.Position = UDim2.new(0, (v1.X + v2.X) / 2, 0, (v1.Y + v2.Y) / 2)
				line.Rotation = angle
				line.BackgroundColor3 = color
				line.Visible = true
			end
		end
	else
		for _, lines in pairs(skeletons) do
			for _, l in ipairs(lines) do l.Visible = false end
		end
	end

	if hmAlpha > 0 then
		hmAlpha = math.max(0, hmAlpha - dt * 3)
		for _, l in ipairs(hmLines) do
			l.BackgroundTransparency = 1 - hmAlpha
			l.BackgroundColor3 = Color3.fromRGB(255, 255 * hmAlpha, 255 * hmAlpha)
		end
		if hmAlpha <= 0 then hmContainer.Visible = false end
	end

	if SETTINGS.RadarEnabled then
		radarFrame.Visible = true
		radarFrame.Size = UDim2.new(0, SETTINGS.RadarSize, 0, SETTINGS.RadarSize)
		local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if myHRP then
			local myPos = myHRP.Position
			local myLook = Camera.CFrame.LookVector
			local myAngle = math.atan2(myLook.X, myLook.Z)
			local size = SETTINGS.RadarSize
			local halfSize = size / 2
			local scale = halfSize / SETTINGS.RadarRange

			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer then continue end
				local char = player.Character
				if not char then
					if radarDots[player] then radarDots[player].Visible = false end
					continue
				end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then
					if radarDots[player] then radarDots[player].Visible = false end
					continue
				end

				if not radarDots[player] then
					local d = Instance.new("Frame")
					d.Size = UDim2.new(0, 8, 0, 8)
					d.AnchorPoint = Vector2.new(0.5, 0.5)
					d.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
					d.BorderSizePixel = 0
					d.ZIndex = 5
					d.Parent = radarFrame
					local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = d
					radarDots[player] = d
				end

				local dot = radarDots[player]
				local rel = hrp.Position - myPos
				local dist = math.sqrt(rel.X^2 + rel.Z^2)
				if dist > SETTINGS.RadarRange then
					dot.Visible = false
					continue
				end

				local relAngle = math.atan2(rel.X, rel.Z) - myAngle
				local x = math.sin(relAngle) * dist
				local z = math.cos(relAngle) * dist
				dot.Position = UDim2.new(0, halfSize + x * scale, 0, halfSize - z * scale)

				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					local isVis = visibilityCache[player] or false
					dot.BackgroundColor3 = isVis and espVisibleColor or espHiddenColor
					dot.Visible = true
				else
					dot.Visible = false
				end
			end
		end
	else
		radarFrame.Visible = false
	end

	if SETTINGS.CrosshairEnabled then
		local key = SETTINGS.CrosshairStyle .. "|" .. SETTINGS.CrosshairColorHex .. "|" ..
			tostring(SETTINGS.CrosshairSize) .. "|" .. tostring(SETTINGS.CrosshairThickness) .. "|" .. tostring(SETTINGS.CrosshairGap)
		if key ~= lastCrossKey then
			lastCrossKey = key
			local vp = Camera.ViewportSize
			crossContainer.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
			local col = parseColor(SETTINGS.CrosshairColorHex)
			for _, p in ipairs(crossParts) do p.BackgroundColor3 = col end
			dot.BackgroundColor3 = col
			co.Color = col

			local style = SETTINGS.CrosshairStyle
			local size = SETTINGS.CrosshairSize
			local thick = SETTINGS.CrosshairThickness
			local gap = SETTINGS.CrosshairGap
			for _, p in ipairs(crossParts) do p.Visible = false; p.Rotation = 0 end
			dot.Visible = false
			circleStroke.Visible = false

			if style == "Cross" then
				crossParts[1].Size = UDim2.new(0, size, 0, thick); crossParts[1].Position = UDim2.new(0.5, gap, 0.5, -thick/2); crossParts[1].Visible = true
				crossParts[2].Size = UDim2.new(0, size, 0, thick); crossParts[2].Position = UDim2.new(0.5, -gap - size, 0.5, -thick/2); crossParts[2].Visible = true
				crossParts[3].Size = UDim2.new(0, thick, 0, size); crossParts[3].Position = UDim2.new(0.5, -thick/2, 0.5, gap); crossParts[3].Visible = true
				crossParts[4].Size = UDim2.new(0, thick, 0, size); crossParts[4].Position = UDim2.new(0.5, -thick/2, 0.5, -gap - size); crossParts[4].Visible = true
			elseif style == "Circle" then
				circleStroke.Size = UDim2.new(0, size * 2, 0, size * 2)
				co.Thickness = thick
				circleStroke.Visible = true
			elseif style == "Dot" then
				dot.Size = UDim2.new(0, size / 2, 0, size / 2); dot.Visible = true
			elseif style == "X" then
				local diag = size * 0.7
				crossParts[1].Size = UDim2.new(0, diag, 0, thick); crossParts[1].Position = UDim2.new(0.5, gap * 0.5, 0.5, -thick/2); crossParts[1].Rotation = 45; crossParts[1].Visible = true
				crossParts[2].Size = UDim2.new(0, diag, 0, thick); crossParts[2].Position = UDim2.new(0.5, -gap * 0.5 - diag, 0.5, -thick/2); crossParts[2].Rotation = 45; crossParts[2].Visible = true
				crossParts[3].Size = UDim2.new(0, diag, 0, thick); crossParts[3].Position = UDim2.new(0.5, gap * 0.5, 0.5, -thick/2); crossParts[3].Rotation = -45; crossParts[3].Visible = true
				crossParts[4].Size = UDim2.new(0, diag, 0, thick); crossParts[4].Position = UDim2.new(0.5, -gap * 0.5 - diag, 0.5, -thick/2); crossParts[4].Rotation = -45; crossParts[4].Visible = true
			end
		end
		crossContainer.Visible = true
	else
		crossContainer.Visible = false
	end

	if SETTINGS.PreviewEnabled then
		previewFrame.Visible = true
		if SETTINGS.PreviewRotate then
			local delta = now - previewLastTime
			previewLastTime = now
			previewAngle = previewAngle + math.rad(SETTINGS.PreviewRotSpeed) * delta
		end
		local radius = 10
		viewCam.CFrame = CFrame.new(Vector3.new(math.sin(previewAngle) * radius, 1.2, math.cos(previewAngle) * radius), Vector3.new(0, 0, 0))
		pbs.Color = espVisibleColor
		previewBox.BackgroundColor3 = espVisibleColor
		previewBox.BackgroundTransparency = SETTINGS.ESPTransparency
		previewName.Text = SETTINGS.PreviewName
		previewDist.Text = math.floor(SETTINGS.PreviewDistance) .. " studs"
		pbs.Thickness = SETTINGS.ESPThickness

		local stateKey = tostring(SETTINGS.BodySkinEnabled) .. "|" .. tostring(SETTINGS.BodyMaterial) .. "|" .. tostring(SETTINGS.BodyColorHex) .. "|" .. tostring(SETTINGS.BodyTransparency)
		if stateKey ~= lastBodyState then
			lastBodyState = stateKey
			applyPreviewBodySkin()
		end
	else
		previewFrame.Visible = false
	end

	if now - lastWatermark > 0.5 then
		lastWatermark = now
		if SETTINGS.WatermarkEnabled then
			watermark.Visible = true
			local parts = {"HUB"}
			if SETTINGS.WatermarkFPS then table.insert(parts, "FPS: " .. fps) end
			if SETTINGS.WatermarkPing then table.insert(parts, "Ping: " .. pingMs .. "ms") end
			if SETTINGS.WatermarkTime then
				local t = os.date("*t")
				table.insert(parts, string.format("%02d:%02d", t.hour, t.min))
			end
			wmLabel.Text = table.concat(parts, "  •  ")
		else
			watermark.Visible = false
		end
	end

	if now - lastStats > 0.5 then
		lastStats = now
		if SETTINGS.StatsEnabled then
			statsPanel.Visible = true
			local fpsColor = Color3.fromRGB(0, 255, 100)
			if fps < 30 then fpsColor = Color3.fromRGB(255, 60, 60)
			elseif fps < 50 then fpsColor = Color3.fromRGB(255, 200, 0) end
			statsRows["FPS"].Text = tostring(fps)
			statsRows["FPS"].TextColor3 = fpsColor

			local pingColor = Color3.fromRGB(0, 255, 100)
			if pingMs > 150 then pingColor = Color3.fromRGB(255, 60, 60)
			elseif pingMs > 80 then pingColor = Color3.fromRGB(255, 200, 0) end
			statsRows["Ping"].Text = pingMs .. "ms"
			statsRows["Ping"].TextColor3 = pingColor

			statsRows["Players"].Text = tostring(#Players:GetPlayers())
			statsRows["Time"].Text = os.date("%H:%M:%S")
		else
			statsPanel.Visible = false
		end
	end

	if now - lastInv > 0.5 then
		lastInv = now
		pcall(updateInventory)
	end

	if now - lastList > 0.33 then
		lastList = now
		if SETTINGS.PlayerListEnabled then
			listFrame.Visible = true
			for p, _ in pairs(listRows) do if not p.Parent then removeListRow(p) end end
			for _, p in ipairs(Players:GetPlayers()) do
				if not listRows[p] then makeListRow(p) end
			end
			for p, data in pairs(listRows) do
				local hp = 100
				if p.Character then
					local hum = p.Character:FindFirstChildOfClass("Humanoid")
					if hum then hp = math.max(0, hum.Health / hum.MaxHealth * 100) end
				end
				data.hpFill.Size = UDim2.new(hp / 100, 0, 1, 0)
				data.hpTxt.Text = math.floor(hp) .. "%"
				if hp > 60 then data.hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
				elseif hp > 30 then data.hpFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
				else data.hpFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end
			end
		else
			listFrame.Visible = false
		end
	end

	if SETTINGS.SilentAimEnabled and aiming then
		silentTarget = cachedTarget
		silentPredicted = cachedPredictedPos
	else
		silentTarget = nil
		silentPredicted = nil
	end

	if SETTINGS.SilentAimEnabled and SETTINGS.SilentAimAutoFire and aiming and silentTarget then
		if now - silentLastShot >= SETTINGS.SilentAimDelay then
			silentLastShot = now
			silentFire()
		end
	end
end)

print("[HUB v5] Загружен с оптимизацией.")
