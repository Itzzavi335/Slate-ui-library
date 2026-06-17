local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ICONS = {
	Lock = "rbxassetid://84057422523657",
	Clock = "rbxassetid://139133324696861",
	Tag = "rbxassetid://92768859826736",
	Eye = "rbxassetid://4674746809",
	ArrowDown = "rbxassetid://127928339372741",
}

local C = {
	BG = Color3.fromRGB(20, 23, 30),
	BG2 = Color3.fromRGB(26, 30, 40),
	BG3 = Color3.fromRGB(16, 19, 26),
	Border = Color3.fromRGB(38, 44, 60),
	Accent = Color3.fromRGB(0, 210, 210),
	AccentDk = Color3.fromRGB(0, 160, 160),
	AccentFnt = Color3.fromRGB(0, 35, 35),
	TextPri = Color3.fromRGB(215, 225, 240),
	TextMut = Color3.fromRGB(85, 100, 125),
	TextDim = Color3.fromRGB(55, 65, 85),
	ToggleOff = Color3.fromRGB(38, 44, 60),
	Green = Color3.fromRGB(50, 200, 100),
	Red = Color3.fromRGB(210, 65, 65),
	White = Color3.fromRGB(255, 255, 255),
}

local SlateUI = {}
local SavedConfigs = {}
local ActiveConfig = nil
local RememberKeyData = nil
local VerifiedKey = nil

local function rnd(f, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 4)
	c.Parent = f
	return c
end

local function strk(f, col, t)
	local s = Instance.new("UIStroke")
	s.Color = col or C.Border
	s.Thickness = t or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = f
	return s
end

local function draggable(win, bar)
	local drag, ds, sp = false, nil, nil
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			ds = i.Position
			sp = win.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					drag = false
				end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and ds then
			if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
				local d = i.Position - ds
				win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
			end
		end
	end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SlateUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local NOTIF_ICON = "rbxassetid://11401835376"

local function showNotification(title, message, notifType, duration)
	duration = duration or 3.5
	local typeColors = {
		info = C.Accent,
		success = C.Green,
		error = C.Red,
		warning = Color3.fromRGB(220, 170, 40),
	}
	local accentCol = typeColors[notifType or "info"] or C.Accent

	local W_WIDTH = 240
	local W_HEIGHT = 62

	local notif = Instance.new("Frame")
	notif.Size = UDim2.fromOffset(W_WIDTH, W_HEIGHT)
	notif.AnchorPoint = Vector2.new(1, 1)
	notif.Position = UDim2.new(1, -12, 1, -12 + W_HEIGHT + 4)
	notif.BackgroundColor3 = C.BG2
	notif.BorderSizePixel = 0
	notif.ZIndex = 200
	notif.Parent = ScreenGui
	rnd(notif, 7)
	strk(notif, C.Border, 1)

	local ico = Instance.new("ImageLabel")
	ico.Size = UDim2.fromOffset(18, 18)
	ico.Position = UDim2.fromOffset(12, (W_HEIGHT - 18) / 2)
	ico.BackgroundTransparency = 1
	ico.Image = NOTIF_ICON
	ico.ImageColor3 = accentCol
	ico.ZIndex = 201
	ico.Parent = notif

	local ttl = Instance.new("TextLabel")
	ttl.Size = UDim2.new(1, -42, 0, 18)
	ttl.Position = UDim2.fromOffset(36, 12)
	ttl.BackgroundTransparency = 1
	ttl.Text = title or "Notification"
	ttl.TextColor3 = C.TextPri
	ttl.TextSize = 12
	ttl.Font = Enum.Font.GothamBold
	ttl.TextXAlignment = Enum.TextXAlignment.Left
	ttl.ZIndex = 201
	ttl.Parent = notif

	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -42, 0, 14)
	msg.Position = UDim2.fromOffset(36, 32)
	msg.BackgroundTransparency = 1
	msg.Text = message or ""
	msg.TextColor3 = C.TextMut
	msg.TextSize = 10
	msg.Font = Enum.Font.Gotham
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextWrapped = true
	msg.ZIndex = 201
	msg.Parent = notif

	local progBG = Instance.new("Frame")
	progBG.Size = UDim2.new(1, -8, 0, 2)
	progBG.Position = UDim2.new(0, 4, 1, -4)
	progBG.BackgroundColor3 = C.BG3
	progBG.BorderSizePixel = 0
	progBG.ZIndex = 201
	progBG.Parent = notif
	rnd(progBG, 99)

	local progFill = Instance.new("Frame")
	progFill.Size = UDim2.fromScale(1, 1)
	progFill.BackgroundColor3 = accentCol
	progFill.BorderSizePixel = 0
	progFill.ZIndex = 202
	progFill.Parent = progBG
	rnd(progFill, 99)

	local targetY = UDim2.new(1, -12, 1, -12)
	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = targetY }):Play()
	TweenService:Create(progFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) }):Play()

	task.delay(duration, function()
		TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Position = UDim2.new(1, -12, 1, -12 + W_HEIGHT + 4),
			BackgroundTransparency = 1,
		}):Play()
		task.wait(0.3)
		notif:Destroy()
	end)
end

local function tryLoadRememberedKey()
	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile("SlateUI_RememberKey.json"))
	end)
	if success and data and data.Key and data.Time and data.Type then
		if os.time() < data.Time then
			RememberKeyData = data
			return true
		end
	end
	return false
end

local function saveRememberedKey(key, expiryTime, keyType)
	local data = { Key = key, Time = expiryTime, Type = keyType }
	writefile("SlateUI_RememberKey.json", HttpService:JSONEncode(data))
	RememberKeyData = data
end

local function clearRememberedKey()
	pcall(function() delfile("SlateUI_RememberKey.json") end)
	RememberKeyData = nil
end

local function parseKeyInfo(keyString)
	local parts = string.split(keyString, ":")
	if #parts >= 3 then
		local keyId = parts[1]
		local keyType = parts[2]
		local duration = parts[3]
		return keyId, keyType, duration
	end
	return nil, nil, nil
end

local function calculateExpiry(durationStr)
	if durationStr == "Infinite" then
		return os.time() + (365 * 24 * 60 * 60)
	end
	local num = tonumber(string.match(durationStr, "%d+"))
	local unit = string.match(durationStr, "%a+")
	if num and unit then
		local multipliers = { h = 3600, hour = 3600, hours = 3600, d = 86400, day = 86400, days = 86400, w = 604800, week = 604800, weeks = 604800, m = 2592000, month = 2592000, months = 2592000 }
		local mult = multipliers[unit:lower()] or 86400
		return os.time() + (num * mult)
	end
	return os.time() + 86400
end

local function formatTimeLeft(expiryTime)
	if expiryTime - os.time() > (365 * 24 * 60 * 60) - 1000 then
		return "Infinite"
	end
	local diff = expiryTime - os.time()
	if diff <= 0 then
		return "Expired"
	end
	local days = math.floor(diff / 86400)
	local hours = math.floor((diff % 86400) / 3600)
	local minutes = math.floor((diff % 3600) / 60)
	if days > 0 then
		return string.format("%d Days, %d Hours", days, hours)
	elseif hours > 0 then
		return string.format("%d Hours, %d Minutes", hours, minutes)
	else
		return string.format("%d Minutes", minutes)
	end
end

local function loadSavedConfigs()
	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile("SlateUI_Configs.json"))
	end)
	if success and data then
		SavedConfigs = data
	end
end

local function saveConfigsToFile()
	writefile("SlateUI_Configs.json", HttpService:JSONEncode(SavedConfigs))
end

local function getConfigList()
	local list = {}
	for name in pairs(SavedConfigs) do
		table.insert(list, name)
	end
	if #list == 0 then
		list = { "No saved configs" }
	end
	table.sort(list)
	return list
end

loadSavedConfigs()

function SlateUI:CreateWindow(config)
	local Title = config.Title or "Slate UI"
	local WindowSize = config.Size or UDim2.fromOffset(560, 460)
	local KeySystem = config.KeySystem or false
	local KeySystemTitle = config.KeySystemTitle or "Authentication Required"
	local GetKeyLink = config.GetKeyLink or "https://example.com/getkey"
	local Keys = config.Keys or {}

	local w = WindowSize.X.Offset
	local h = WindowSize.Y.Offset

	local KeySystemPassed = false
	if KeySystem then
		if tryLoadRememberedKey() then
			local validKey = false
			for _, keyDef in ipairs(Keys) do
				local keyId, keyType, duration = parseKeyInfo(keyDef)
				if keyId and RememberKeyData.Key == keyId and RememberKeyData.Type == keyType then
					if os.time() < RememberKeyData.Time then
						validKey = true
						VerifiedKey = { Key = keyId, Type = keyType, Expiry = RememberKeyData.Time }
						break
					end
				end
			end
			if validKey then
				KeySystemPassed = true
			else
				clearRememberedKey()
			end
		end
	end

	local function buildKeySystem(callback)
		local KWin = Instance.new("Frame")
		KWin.Size = UDim2.fromOffset(320, 300)
		KWin.AnchorPoint = Vector2.new(0.5, 0.5)
		KWin.Position = UDim2.fromScale(0.5, 0.5)
		KWin.BackgroundColor3 = C.BG
		KWin.BorderSizePixel = 0
		KWin.ZIndex = 2
		KWin.Parent = ScreenGui
		strk(KWin, C.Border, 1)

		local top = Instance.new("Frame")
		top.Size = UDim2.new(1, 0, 0, 2)
		top.BackgroundColor3 = C.Accent
		top.BorderSizePixel = 0
		top.ZIndex = 3
		top.Parent = KWin

		local bar = Instance.new("Frame")
		bar.Name = "TitleBar"
		bar.Size = UDim2.new(1, 0, 0, 40)
		bar.BackgroundTransparency = 1
		bar.ZIndex = 3
		bar.Parent = KWin

		local ico = Instance.new("ImageLabel")
		ico.Size = UDim2.fromOffset(16, 16)
		ico.Position = UDim2.fromOffset(12, 12)
		ico.BackgroundTransparency = 1
		ico.Image = ICONS.Lock
		ico.ImageColor3 = C.Accent
		ico.ZIndex = 4
		ico.Parent = bar

		local ttl = Instance.new("TextLabel")
		ttl.Size = UDim2.new(1, -40, 1, 0)
		ttl.Position = UDim2.fromOffset(34, 0)
		ttl.BackgroundTransparency = 1
		ttl.Text = KeySystemTitle
		ttl.TextColor3 = C.TextPri
		ttl.TextSize = 13
		ttl.Font = Enum.Font.GothamBold
		ttl.TextXAlignment = Enum.TextXAlignment.Left
		ttl.ZIndex = 4
		ttl.Parent = bar

		local div = Instance.new("Frame")
		div.Size = UDim2.new(1, 0, 0, 1)
		div.Position = UDim2.fromOffset(0, 40)
		div.BackgroundColor3 = C.Border
		div.BorderSizePixel = 0
		div.ZIndex = 3
		div.Parent = KWin

		draggable(KWin, bar)

		local keyVisible = true
		local rememberKey = false
		local isLoading = false

		local KC = Instance.new("Frame")
		KC.Size = UDim2.new(1, -28, 0, 210)
		KC.Position = UDim2.fromOffset(14, 50)
		KC.BackgroundTransparency = 1
		KC.ZIndex = 3
		KC.Parent = KWin

		local EKL = Instance.new("TextLabel")
		EKL.Size = UDim2.new(1, 0, 0, 16)
		EKL.BackgroundTransparency = 1
		EKL.Text = "Enter Key"
		EKL.TextColor3 = C.TextPri
		EKL.TextSize = 12
		EKL.Font = Enum.Font.Gotham
		EKL.TextXAlignment = Enum.TextXAlignment.Left
		EKL.ZIndex = 4
		EKL.Parent = KC

		local IC = Instance.new("Frame")
		IC.Size = UDim2.new(1, 0, 0, 34)
		IC.Position = UDim2.fromOffset(0, 20)
		IC.BackgroundColor3 = C.BG3
		IC.BorderSizePixel = 0
		IC.ZIndex = 4
		IC.Parent = KC
		rnd(IC, 5)
		local IS = strk(IC, C.Border, 1)

		local KI = Instance.new("TextBox")
		KI.Size = UDim2.new(1, -42, 1, 0)
		KI.Position = UDim2.fromOffset(10, 0)
		KI.BackgroundTransparency = 1
		KI.Text = ""
		KI.PlaceholderText = "Enter your key here..."
		KI.PlaceholderColor3 = C.TextMut
		KI.TextColor3 = C.TextPri
		KI.TextSize = 12
		KI.Font = Enum.Font.Gotham
		KI.TextXAlignment = Enum.TextXAlignment.Left
		KI.ClearTextOnFocus = false
		KI.ZIndex = 5
		KI.Parent = IC

		local EB = Instance.new("ImageButton")
		EB.Size = UDim2.fromOffset(18, 18)
		EB.Position = UDim2.new(1, -26, 0.5, -9)
		EB.BackgroundTransparency = 1
		EB.Image = ICONS.Eye
		EB.ImageColor3 = C.TextMut
		EB.ZIndex = 5
		EB.Parent = IC
		EB.MouseButton1Click:Connect(function()
			keyVisible = not keyVisible
			KI.TextTransparency = keyVisible and 0 or 1
			EB.ImageColor3 = keyVisible and C.TextMut or C.Accent
		end)
		KI.Focused:Connect(function()
			TweenService:Create(IS, TweenInfo.new(0.15), { Color = C.Accent, Thickness = 1.2 }):Play()
		end)
		KI.FocusLost:Connect(function()
			TweenService:Create(IS, TweenInfo.new(0.15), { Color = C.Border, Thickness = 1 }):Play()
		end)

		local RR = Instance.new("Frame")
		RR.Size = UDim2.new(1, 0, 0, 20)
		RR.Position = UDim2.fromOffset(0, 62)
		RR.BackgroundTransparency = 1
		RR.ZIndex = 4
		RR.Parent = KC

		local CB = Instance.new("TextButton")
		CB.Size = UDim2.fromOffset(13, 13)
		CB.Position = UDim2.fromOffset(0, 3)
		CB.BackgroundColor3 = C.BG3
		CB.BorderSizePixel = 0
		CB.Text = ""
		CB.ZIndex = 5
		CB.Parent = RR
		rnd(CB, 3)
		local CS = strk(CB, C.Border, 1)

		local CM = Instance.new("ImageLabel")
		CM.Size = UDim2.fromOffset(9, 9)
		CM.Position = UDim2.fromOffset(2, 2)
		CM.BackgroundTransparency = 1
		CM.Image = "rbxassetid://6031068421"
		CM.ImageColor3 = C.Accent
		CM.Visible = false
		CM.ZIndex = 6
		CM.Parent = CB

		local RL = Instance.new("TextLabel")
		RL.Size = UDim2.new(1, -18, 1, 0)
		RL.Position = UDim2.fromOffset(18, 0)
		RL.BackgroundTransparency = 1
		RL.Text = "Remember Key"
		RL.TextColor3 = C.TextPri
		RL.TextSize = 12
		RL.Font = Enum.Font.Gotham
		RL.TextXAlignment = Enum.TextXAlignment.Left
		RL.ZIndex = 5
		RL.Parent = RR
		CB.MouseButton1Click:Connect(function()
			rememberKey = not rememberKey
			CM.Visible = rememberKey
			CS.Color = rememberKey and C.Accent or C.Border
		end)

		local TLR = Instance.new("Frame")
		TLR.Size = UDim2.new(1, 0, 0, 18)
		TLR.Position = UDim2.fromOffset(0, 92)
		TLR.BackgroundTransparency = 1
		TLR.ZIndex = 4
		TLR.Parent = KC

		local TLI = Instance.new("ImageLabel")
		TLI.Size = UDim2.fromOffset(13, 13)
		TLI.Position = UDim2.fromOffset(0, 2)
		TLI.BackgroundTransparency = 1
		TLI.Image = ICONS.Clock
		TLI.ImageColor3 = C.Accent
		TLI.ZIndex = 5
		TLI.Parent = TLR

		local TimeLabel = Instance.new("TextLabel")
		TimeLabel.Size = UDim2.new(1, -18, 1, 0)
		TimeLabel.Position = UDim2.fromOffset(18, 0)
		TimeLabel.BackgroundTransparency = 1
		TimeLabel.Text = "Time Left:  --"
		TimeLabel.TextColor3 = C.TextPri
		TimeLabel.TextSize = 12
		TimeLabel.Font = Enum.Font.Gotham
		TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
		TimeLabel.ZIndex = 5
		TimeLabel.Parent = TLR

		local KTR = Instance.new("Frame")
		KTR.Size = UDim2.new(1, 0, 0, 18)
		KTR.Position = UDim2.fromOffset(0, 116)
		KTR.BackgroundTransparency = 1
		KTR.ZIndex = 4
		KTR.Parent = KC

		local KTI = Instance.new("ImageLabel")
		KTI.Size = UDim2.fromOffset(13, 13)
		KTI.Position = UDim2.fromOffset(0, 2)
		KTI.BackgroundTransparency = 1
		KTI.Image = ICONS.Tag
		KTI.ImageColor3 = C.Accent
		KTI.ZIndex = 5
		KTI.Parent = KTR

		local TypeLabel = Instance.new("TextLabel")
		TypeLabel.Size = UDim2.new(1, -18, 1, 0)
		TypeLabel.Position = UDim2.fromOffset(18, 0)
		TypeLabel.BackgroundTransparency = 1
		TypeLabel.Text = "Key Type:  --"
		TypeLabel.TextColor3 = C.TextPri
		TypeLabel.TextSize = 12
		TypeLabel.Font = Enum.Font.Gotham
		TypeLabel.TextXAlignment = Enum.TextXAlignment.Left
		TypeLabel.ZIndex = 5
		TypeLabel.Parent = KTR

		local BR = Instance.new("Frame")
		BR.Size = UDim2.new(1, 0, 0, 34)
		BR.Position = UDim2.fromOffset(0, 144)
		BR.BackgroundTransparency = 1
		BR.ZIndex = 4
		BR.Parent = KC

		local GKB = Instance.new("TextButton")
		GKB.Size = UDim2.new(0.44, 0, 1, 0)
		GKB.BackgroundColor3 = C.BG2
		GKB.BorderSizePixel = 0
		GKB.Text = ""
		GKB.ZIndex = 5
		GKB.Parent = BR
		rnd(GKB, 5)
		strk(GKB, C.Border, 1)
		local GKInner = Instance.new("Frame")
		GKInner.Size = UDim2.fromScale(1, 1)
		GKInner.BackgroundTransparency = 1
		GKInner.ZIndex = 6
		GKInner.Parent = GKB
		local GKIco = Instance.new("ImageLabel")
		GKIco.Size = UDim2.fromOffset(13, 13)
		GKIco.Position = UDim2.new(0.5, -32, 0.5, -6)
		GKIco.BackgroundTransparency = 1
		GKIco.Image = ICONS.Tag
		GKIco.ImageColor3 = C.TextPri
		GKIco.ZIndex = 7
		GKIco.Parent = GKInner
		local GKT = Instance.new("TextLabel")
		GKT.Size = UDim2.new(1, -18, 1, 0)
		GKT.Position = UDim2.new(0.5, -16, 0, 0)
		GKT.BackgroundTransparency = 1
		GKT.Text = "Get Key"
		GKT.TextColor3 = C.TextPri
		GKT.TextSize = 12
		GKT.Font = Enum.Font.GothamBold
		GKT.TextXAlignment = Enum.TextXAlignment.Left
		GKT.ZIndex = 7
		GKT.Parent = GKInner
		GKB.MouseEnter:Connect(function()
			TweenService:Create(GKB, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(35, 41, 56) }):Play()
		end)
		GKB.MouseLeave:Connect(function()
			TweenService:Create(GKB, TweenInfo.new(0.15), { BackgroundColor3 = C.BG2 }):Play()
		end)
		GKB.MouseButton1Click:Connect(function()
			GuiService:OpenBrowserWindow(GetKeyLink)
		end)

		local VB = Instance.new("TextButton")
		VB.Size = UDim2.new(0.53, 0, 1, 0)
		VB.Position = UDim2.new(0.47, 0, 0, 0)
		VB.BackgroundColor3 = C.Accent
		VB.BorderSizePixel = 0
		VB.Text = ""
		VB.ZIndex = 5
		VB.Parent = BR
		rnd(VB, 5)
		local VInner = Instance.new("Frame")
		VInner.Size = UDim2.fromScale(1, 1)
		VInner.BackgroundTransparency = 1
		VInner.ZIndex = 6
		VInner.Parent = VB
		local VShield = Instance.new("ImageLabel")
		VShield.Size = UDim2.fromOffset(14, 14)
		VShield.Position = UDim2.new(0.5, -44, 0.5, -7)
		VShield.BackgroundTransparency = 1
		VShield.Image = "rbxassetid://6022668888"
		VShield.ImageColor3 = Color3.fromRGB(0, 25, 25)
		VShield.ZIndex = 7
		VShield.Parent = VInner
		local VT = Instance.new("TextLabel")
		VT.Size = UDim2.new(1, -18, 1, 0)
		VT.Position = UDim2.new(0.5, -24, 0, 0)
		VT.BackgroundTransparency = 1
		VT.Text = "Verify Key"
		VT.TextColor3 = Color3.fromRGB(0, 25, 25)
		VT.TextSize = 12
		VT.Font = Enum.Font.GothamBold
		VT.TextXAlignment = Enum.TextXAlignment.Left
		VT.ZIndex = 7
		VT.Parent = VInner
		VB.MouseEnter:Connect(function()
			TweenService:Create(VB, TweenInfo.new(0.15), { BackgroundColor3 = C.AccentDk }):Play()
		end)
		VB.MouseLeave:Connect(function()
			TweenService:Create(VB, TweenInfo.new(0.15), { BackgroundColor3 = C.Accent }):Play()
		end)

		local SB = Instance.new("Frame")
		SB.Size = UDim2.new(1, -28, 0, 32)
		SB.Position = UDim2.new(0, 14, 1, -40)
		SB.BackgroundTransparency = 1
		SB.ZIndex = 3
		SB.Parent = KWin

		local SL = Instance.new("TextLabel")
		SL.Size = UDim2.new(1, 0, 0, 13)
		SL.BackgroundTransparency = 1
		SL.Text = "Awaiting key input..."
		SL.TextColor3 = C.TextMut
		SL.TextSize = 10
		SL.Font = Enum.Font.Gotham
		SL.TextXAlignment = Enum.TextXAlignment.Left
		SL.ZIndex = 4
		SL.Parent = SB

		local PBG = Instance.new("Frame")
		PBG.Size = UDim2.new(1, 0, 0, 3)
		PBG.Position = UDim2.fromOffset(0, 16)
		PBG.BackgroundColor3 = C.BG3
		PBG.BorderSizePixel = 0
		PBG.ZIndex = 4
		PBG.Parent = SB
		rnd(PBG, 99)
		strk(PBG, C.Border, 1)

		local PF = Instance.new("Frame")
		PF.Size = UDim2.new(0, 0, 1, 0)
		PF.BackgroundColor3 = C.Accent
		PF.BorderSizePixel = 0
		PF.ZIndex = 5
		PF.Parent = PBG
		rnd(PF, 99)

		local function setStatus(txt, col)
			SL.Text = txt
			SL.TextColor3 = col or C.TextMut
		end

		local function animProg(dur, cb)
			isLoading = true
			local s = 60
			local st = dur / 60
			for i = 1, s do
				PF.Size = UDim2.new(i / s, 0, 1, 0)
				task.wait(st)
			end
			isLoading = false
			if cb then
				cb()
			end
		end

		VB.MouseButton1Click:Connect(function()
			if isLoading then
				return
			end
			local key = KI.Text
			if key == "" then
				setStatus("Please enter a key.", C.Red)
				return
			end
			setStatus("Verifying key...", C.Accent)
			task.spawn(animProg, 1.5, function()
				local validKey = false
				local matchedKeyDef = nil
				for _, keyDef in ipairs(Keys) do
					local keyId, keyType, duration = parseKeyInfo(keyDef)
					if keyId and key == keyId then
						validKey = true
						matchedKeyDef = { Key = keyId, Type = keyType, Expiry = calculateExpiry(duration) }
						break
					end
				end
				if validKey and matchedKeyDef then
					setStatus("Key verified! Welcome.", C.Green)
					TimeLabel.Text = "Time Left:  " .. formatTimeLeft(matchedKeyDef.Expiry)
					TypeLabel.Text = "Key Type:  " .. matchedKeyDef.Type
					if rememberKey then
						saveRememberedKey(matchedKeyDef.Key, matchedKeyDef.Expiry, matchedKeyDef.Type)
					end
					VerifiedKey = matchedKeyDef
					task.wait(2)
					KWin:Destroy()
					callback()
				else
					setStatus("Invalid key. Try again.", C.Red)
					TweenService:Create(PF, TweenInfo.new(0.4), { Size = UDim2.new(0, 0, 1, 0) }):Play()
				end
			end)
		end)
	end

	local Window = {}
	local W, TabPages, TabButtons, TABS, switchTab
	local savedLabel
	local CA, LEFT, RIGHT

	local function rebuildTabBar()
		local TabBar
		for _, child in ipairs(W:GetChildren()) do
			if child:IsA("Frame") and child.Size.Y.Offset == 40 and child.Position.Y.Offset == h - 40 and child.Name ~= "TitleBar" then
				TabBar = child
				break
			end
		end
		if not TabBar then return end

		for _, child in ipairs(TabBar:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		TabButtons = {}

		local tabCount = #TABS
		for i, tname in ipairs(TABS) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1 / tabCount, 0, 1, 0)
			btn.Position = UDim2.new((i - 1) / tabCount, 0, 0, 0)
			btn.BackgroundColor3 = C.BG
			btn.BorderSizePixel = 0
			btn.Text = tname
			btn.TextColor3 = C.TextMut
			btn.TextSize = 12
			btn.Font = Enum.Font.GothamBold
			btn.ZIndex = 4
			btn.Parent = TabBar

			local bl = Instance.new("Frame")
			bl.Name = "BorderLine"
			bl.Size = UDim2.new(1, 0, 0, 2)
			bl.Position = UDim2.fromOffset(0, 0)
			bl.BackgroundColor3 = C.Accent
			bl.BorderSizePixel = 0
			bl.Visible = false
			bl.ZIndex = 5
			bl.Parent = btn

			if i < tabCount then
				local sep = Instance.new("Frame")
				sep.Size = UDim2.new(0, 1, 1, 0)
				sep.Position = UDim2.new(1, 0, 0, 0)
				sep.BackgroundColor3 = C.Border
				sep.BorderSizePixel = 0
				sep.ZIndex = 5
				sep.Parent = btn
			end

			TabButtons[tname] = btn
			btn.MouseButton1Click:Connect(function()
				switchTab(tname)
			end)
		end
	end

	local function buildMainUI()
		W = Instance.new("Frame")
		W.Size = UDim2.fromOffset(w, h)
		W.AnchorPoint = Vector2.new(0.5, 0.5)
		W.Position = UDim2.fromScale(0.5, 0.5)
		W.BackgroundColor3 = C.BG
		W.BorderSizePixel = 0
		W.ZIndex = 2
		W.Parent = ScreenGui
		strk(W, C.Border, 1)

		local uiScale = Instance.new("UIScale")
		uiScale.Scale = 0.7
		uiScale.Parent = W

		local top = Instance.new("Frame")
		top.Size = UDim2.new(1, 0, 0, 2)
		top.BackgroundColor3 = C.Accent
		top.BorderSizePixel = 0
		top.ZIndex = 3
		top.Parent = W

		local WBar = Instance.new("Frame")
		WBar.Name = "TitleBar"
		WBar.Size = UDim2.new(1, 0, 0, 40)
		WBar.BackgroundTransparency = 1
		WBar.ZIndex = 3
		WBar.Parent = W

		local ico = Instance.new("ImageLabel")
		ico.Size = UDim2.fromOffset(16, 16)
		ico.Position = UDim2.fromOffset(12, 12)
		ico.BackgroundTransparency = 1
		ico.Image = ICONS.Lock
		ico.ImageColor3 = C.Accent
		ico.ZIndex = 4
		ico.Parent = WBar

		local ttl = Instance.new("TextLabel")
		ttl.Size = UDim2.new(1, -40, 1, 0)
		ttl.Position = UDim2.fromOffset(34, 0)
		ttl.BackgroundTransparency = 1
		ttl.Text = Title
		ttl.TextColor3 = C.TextPri
		ttl.TextSize = 13
		ttl.Font = Enum.Font.GothamBold
		ttl.TextXAlignment = Enum.TextXAlignment.Left
		ttl.ZIndex = 4
		ttl.Parent = WBar

		local div = Instance.new("Frame")
		div.Size = UDim2.new(1, 0, 0, 1)
		div.Position = UDim2.fromOffset(0, 40)
		div.BackgroundColor3 = C.Border
		div.BorderSizePixel = 0
		div.ZIndex = 3
		div.Parent = W

		draggable(W, WBar)

		local CONTENT_H = h - 41 - 40
		CA = Instance.new("Frame")
		CA.Size = UDim2.new(1, 0, 0, CONTENT_H)
		CA.Position = UDim2.fromOffset(0, 41)
		CA.BackgroundTransparency = 1
		CA.ClipsDescendants = true
		CA.ZIndex = 3
		CA.Parent = W

		LEFT = Instance.new("Frame")
		LEFT.Size = UDim2.new(0.5, 0, 1, 0)
		LEFT.BackgroundTransparency = 1
		LEFT.ZIndex = 3
		LEFT.Parent = CA
		LEFT.ClipsDescendants = true

		local ColDiv = Instance.new("Frame")
		ColDiv.Size = UDim2.new(0, 1, 1, 0)
		ColDiv.Position = UDim2.fromScale(0.5, 0)
		ColDiv.BackgroundColor3 = C.Border
		ColDiv.BorderSizePixel = 0
		ColDiv.ZIndex = 3
		ColDiv.Parent = CA

		RIGHT = Instance.new("Frame")
		RIGHT.Size = UDim2.new(0.5, -1, 1, 0)
		RIGHT.Position = UDim2.new(0.5, 1, 0, 0)
		RIGHT.BackgroundTransparency = 1
		RIGHT.ZIndex = 3
		RIGHT.Parent = CA
		RIGHT.ClipsDescendants = true

		TabPages = {}
		TabButtons = {}
		TABS = {}

		function switchTab(name)
			for _, pg in pairs(TabPages) do
				pg.L.Visible = false
				pg.R.Visible = false
			end
			for n, btn in pairs(TabButtons) do
				local active = n == name
				btn.TextColor3 = active and C.Accent or C.TextMut
				btn.BackgroundColor3 = active and C.BG2 or C.BG
				btn.BorderLine.Visible = active
			end
			if TabPages[name] then
				TabPages[name].L.Visible = true
				TabPages[name].R.Visible = true
			end
		end

		local TAB_Y = h - 40
		local TabBar = Instance.new("Frame")
		TabBar.Size = UDim2.new(1, 0, 0, 40)
		TabBar.Position = UDim2.fromOffset(0, TAB_Y)
		TabBar.BackgroundColor3 = C.BG2
		TabBar.BorderSizePixel = 0
		TabBar.ZIndex = 3
		TabBar.Parent = W
		strk(TabBar, C.Border, 1)

		local TabTopLine = Instance.new("Frame")
		TabTopLine.Size = UDim2.new(1, 0, 0, 1)
		TabTopLine.Position = UDim2.fromOffset(0, 0)
		TabTopLine.BackgroundColor3 = C.Border
		TabTopLine.BorderSizePixel = 0
		TabTopLine.ZIndex = 4
		TabTopLine.Parent = TabBar

		local function makeScroll(parent)
			local sf = Instance.new("ScrollingFrame")
			sf.Size = UDim2.fromScale(1, 1)
			sf.BackgroundTransparency = 1
			sf.BorderSizePixel = 0
			sf.ScrollBarThickness = 2
			sf.ScrollBarImageColor3 = C.Accent
			sf.Visible = false
			sf.ZIndex = 4
			sf.Parent = parent
			local lay = Instance.new("UIListLayout")
			lay.Padding = UDim.new(0, 0)
			lay.SortOrder = Enum.SortOrder.LayoutOrder
			lay.Parent = sf
			local pad = Instance.new("UIPadding")
			pad.PaddingTop = UDim.new(0, 6)
			pad.PaddingBottom = UDim.new(0, 6)
			pad.PaddingLeft = UDim.new(0, 4)
			pad.PaddingRight = UDim.new(0, 4)
			pad.Parent = sf
			lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				sf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 20)
			end)
			return sf
		end

		local function addSection(col, order, title)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 26)
			row.BackgroundTransparency = 1
			row.LayoutOrder = order
			row.ZIndex = 4
			row.Parent = col

			local line = Instance.new("Frame")
			line.Size = UDim2.new(1, -20, 0, 1)
			line.Position = UDim2.new(0, 10, 0.5, 0)
			line.BackgroundColor3 = C.Border
			line.BorderSizePixel = 0
			line.ZIndex = 4
			line.Parent = row

			local pill = Instance.new("Frame")
			pill.AutomaticSize = Enum.AutomaticSize.X
			pill.Size = UDim2.new(0, 0, 1, 0)
			pill.AnchorPoint = Vector2.new(0.5, 0.5)
			pill.Position = UDim2.fromScale(0.5, 0.5)
			pill.BackgroundColor3 = C.BG
			pill.BorderSizePixel = 0
			pill.ZIndex = 5
			pill.Parent = row
			local pp = Instance.new("UIPadding")
			pp.PaddingLeft = UDim.new(0, 6)
			pp.PaddingRight = UDim.new(0, 6)
			pp.Parent = pill

			local t = Instance.new("TextLabel")
			t.AutomaticSize = Enum.AutomaticSize.X
			t.Size = UDim2.new(0, 0, 1, 0)
			t.BackgroundTransparency = 1
			t.Text = title
			t.TextColor3 = C.Accent
			t.TextSize = 10
			t.Font = Enum.Font.GothamBold
			t.ZIndex = 6
			t.Parent = pill
		end

		local ROW_H = 28
		local function baseRow(col, order, rowH)
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, rowH or ROW_H)
			row.BackgroundTransparency = 1
			row.BorderSizePixel = 0
			row.LayoutOrder = order
			row.ZIndex = 4
			row.Parent = col
			return row
		end

		local function rowLabel(row, text)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(0.55, 0, 1, 0)
			l.Position = UDim2.fromOffset(10, 0)
			l.BackgroundTransparency = 1
			l.Text = text
			l.TextColor3 = C.TextPri
			l.TextSize = 12
			l.Font = Enum.Font.Gotham
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.ZIndex = 5
			l.Parent = row
			return l
		end

		local function addToggle(col, order, label, default, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local state = default or false

			local bg = Instance.new("Frame")
			bg.Size = UDim2.fromOffset(34, 18)
			bg.Position = UDim2.new(1, -42, 0.5, -9)
			bg.BackgroundColor3 = state and C.Accent or C.ToggleOff
			bg.BorderSizePixel = 0
			bg.ZIndex = 5
			bg.Parent = row
			rnd(bg, 99)
			local bgs = strk(bg, state and C.AccentDk or C.Border, 1)

			local kn = Instance.new("Frame")
			kn.Size = UDim2.fromOffset(12, 12)
			kn.Position = state and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3)
			kn.BackgroundColor3 = C.White
			kn.BorderSizePixel = 0
			kn.ZIndex = 6
			kn.Parent = bg
			rnd(kn, 99)

			local tb = Instance.new("TextButton")
			tb.Size = UDim2.fromScale(1, 1)
			tb.BackgroundTransparency = 1
			tb.Text = ""
			tb.ZIndex = 7
			tb.Parent = bg
			tb.MouseButton1Click:Connect(function()
				state = not state
				TweenService:Create(bg, TweenInfo.new(0.18), { BackgroundColor3 = state and C.Accent or C.ToggleOff }):Play()
				TweenService:Create(bgs, TweenInfo.new(0.18), { Color = state and C.AccentDk or C.Border }):Play()
				TweenService:Create(kn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Position = state and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3) }):Play()
				if onChange then
					onChange(state)
				end
			end)
		end

		local function addCheckToggle(col, order, label, default, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local state = default or false

			local box = Instance.new("TextButton")
			box.Size = UDim2.fromOffset(16, 16)
			box.Position = UDim2.new(1, -26, 0.5, -8)
			box.BackgroundColor3 = state and C.AccentFnt or C.BG3
			box.BorderSizePixel = 0
			box.Text = ""
			box.ZIndex = 5
			box.Parent = row
			rnd(box, 3)
			local bs = strk(box, state and C.Accent or C.Border, 1)

			local cm = Instance.new("ImageLabel")
			cm.Size = UDim2.fromOffset(10, 10)
			cm.Position = UDim2.fromOffset(3, 3)
			cm.BackgroundTransparency = 1
			cm.Image = "rbxassetid://6031068421"
			cm.ImageColor3 = C.Accent
			cm.Visible = state
			cm.ZIndex = 6
			cm.Parent = box

			box.MouseButton1Click:Connect(function()
				state = not state
				cm.Visible = state
				bs.Color = state and C.Accent or C.Border
				TweenService:Create(box, TweenInfo.new(0.15), { BackgroundColor3 = state and C.AccentFnt or C.BG3 }):Play()
				if onChange then
					onChange(state)
				end
			end)
		end

		local function addButton(col, order, label, btnTxt, onClick)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.fromOffset(80, 20)
			btn.Position = UDim2.new(1, -88, 0.5, -10)
			btn.BackgroundColor3 = C.Accent
			btn.BorderSizePixel = 0
			btn.Text = btnTxt
			btn.TextColor3 = Color3.fromRGB(0, 25, 25)
			btn.TextSize = 11
			btn.Font = Enum.Font.GothamBold
			btn.ZIndex = 5
			btn.Parent = row
			rnd(btn, 4)
			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = C.AccentDk }):Play()
			end)
			btn.MouseLeave:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = C.Accent }):Play()
			end)
			btn.MouseButton1Click:Connect(onClick or function() end)
		end

		local function makeDropList(opts)
			local ITEM_H = 28
			local lf = Instance.new("Frame")
			lf.Size = UDim2.fromOffset(148, #opts * ITEM_H + 8)
			lf.BackgroundColor3 = C.BG2
			lf.BorderSizePixel = 0
			lf.Visible = false
			lf.ZIndex = 100
			lf.Parent = ScreenGui
			rnd(lf, 6)
			local lfs = Instance.new("UIStroke")
			lfs.Color = C.Border
			lfs.Thickness = 1
			lfs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			lfs.Parent = lf

			local ll = Instance.new("UIListLayout")
			ll.SortOrder = Enum.SortOrder.LayoutOrder
			ll.Padding = UDim.new(0, 0)
			ll.Parent = lf
			local lpad = Instance.new("UIPadding")
			lpad.PaddingTop = UDim.new(0, 4)
			lpad.PaddingBottom = UDim.new(0, 4)
			lpad.Parent = lf

			return lf, ll, ITEM_H
		end

		local function positionList(lf, db)
			local abs = db.AbsolutePosition
			local sz = db.AbsoluteSize
			lf.Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 4)
		end

		local function makeDropBtn(row)
			local db = Instance.new("TextButton")
			db.Size = UDim2.fromOffset(148, 24)
			db.Position = UDim2.new(1, -156, 0.5, -12)
			db.BackgroundColor3 = C.BG3
			db.BorderSizePixel = 0
			db.Text = ""
			db.ZIndex = 5
			db.Parent = row
			rnd(db, 5)

			local selL = Instance.new("TextLabel")
			selL.Size = UDim2.new(1, -26, 1, 0)
			selL.Position = UDim2.fromOffset(9, 0)
			selL.BackgroundTransparency = 1
			selL.TextColor3 = C.TextPri
			selL.TextSize = 11
			selL.Font = Enum.Font.Gotham
			selL.TextXAlignment = Enum.TextXAlignment.Left
			selL.ZIndex = 6
			selL.Parent = db

			local arr = Instance.new("ImageLabel")
			arr.Size = UDim2.fromOffset(12, 12)
			arr.Position = UDim2.new(1, -18, 0.5, -6)
			arr.BackgroundTransparency = 1
			arr.Image = ICONS.ArrowDown
			arr.ImageColor3 = C.TextMut
			arr.ZIndex = 6
			arr.Parent = db

			return db, selL, arr
		end

		local function addDropdown(col, order, label, opts, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local db, selL, arr = makeDropBtn(row)
			selL.Text = opts[1] or "Select..."
			local lf, ll, ITEM_H = makeDropList(opts)
			local open = false
			local selected = opts[1]

			for idx, opt in ipairs(opts) do
				local it = Instance.new("TextButton")
				it.Size = UDim2.new(1, 0, 0, ITEM_H)
				it.BackgroundColor3 = C.BG2
				it.BackgroundTransparency = 1
				it.BorderSizePixel = 0
				it.Text = ""
				it.LayoutOrder = idx
				it.ZIndex = 101
				it.Parent = lf

				local tick = Instance.new("Frame")
				tick.Size = UDim2.fromOffset(3, 14)
				tick.Position = UDim2.fromOffset(0, 7)
				tick.BackgroundColor3 = C.Accent
				tick.BorderSizePixel = 0
				tick.Visible = (opt == selected)
				tick.ZIndex = 102
				tick.Parent = it
				rnd(tick, 2)

				local il = Instance.new("TextLabel")
				il.Size = UDim2.new(1, -16, 1, 0)
				il.Position = UDim2.fromOffset(12, 0)
				il.BackgroundTransparency = 1
				il.Text = opt
				il.TextColor3 = opt == selected and C.Accent or C.TextPri
				il.TextSize = 11
				il.Font = Enum.Font.Gotham
				il.TextXAlignment = Enum.TextXAlignment.Left
				il.ZIndex = 102
				il.Parent = it

				it.MouseEnter:Connect(function()
					TweenService:Create(it, TweenInfo.new(0.1), { BackgroundTransparency = 0, BackgroundColor3 = C.BG3 }):Play()
				end)
				it.MouseLeave:Connect(function()
					TweenService:Create(it, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
				end)
				it.MouseButton1Click:Connect(function()
					selected = opt
					selL.Text = opt
					lf.Visible = false
					open = false
					for _, ch in ipairs(lf:GetChildren()) do
						if ch:IsA("TextButton") then
							local t = ch:FindFirstChildWhichIsA("TextLabel")
							local tk = ch:FindFirstChildOfClass("Frame")
							if t then
								t.TextColor3 = t.Text == selected and C.Accent or C.TextPri
							end
							if tk then
								tk.Visible = t and t.Text == selected
							end
						end
					end
					TweenService:Create(arr, TweenInfo.new(0.15), { Rotation = 0 }):Play()
					if onChange then
						onChange(selected)
					end
				end)
			end

			db.MouseButton1Click:Connect(function()
				open = not open
				if open then
					positionList(lf, db)
				end
				lf.Visible = open
				TweenService:Create(arr, TweenInfo.new(0.15), { Rotation = open and 180 or 0 }):Play()
			end)
		end

		local function addMultiDropdown(col, order, label, opts, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local db, selL, arr = makeDropBtn(row)
			selL.Text = "None selected"
			local lf, ll, ITEM_H = makeDropList(opts)
			local open = false
			local selected = {}

			local function refreshLabel()
				local keys = {}
				for k in pairs(selected) do
					table.insert(keys, k)
				end
				if #keys == 0 then
					selL.Text = "None"
				elseif #keys == 1 then
					selL.Text = keys[1]
				else
					selL.Text = keys[1] .. " (+" .. (#keys - 1) .. ")"
				end
			end

			for idx, opt in ipairs(opts) do
				local it = Instance.new("TextButton")
				it.Size = UDim2.new(1, 0, 0, ITEM_H)
				it.BackgroundColor3 = C.BG2
				it.BackgroundTransparency = 1
				it.BorderSizePixel = 0
				it.Text = ""
				it.LayoutOrder = idx
				it.ZIndex = 101
				it.Parent = lf

				local box = Instance.new("Frame")
				box.Size = UDim2.fromOffset(13, 13)
				box.Position = UDim2.new(1, -22, 0.5, -6)
				box.BackgroundColor3 = C.BG3
				box.BorderSizePixel = 0
				box.ZIndex = 102
				box.Parent = it
				rnd(box, 3)
				local bks = strk(box, C.Border, 1)

				local chk = Instance.new("ImageLabel")
				chk.Size = UDim2.fromOffset(9, 9)
				chk.Position = UDim2.fromOffset(2, 2)
				chk.BackgroundTransparency = 1
				chk.Image = "rbxassetid://6031068421"
				chk.ImageColor3 = C.Accent
				chk.Visible = false
				chk.ZIndex = 103
				chk.Parent = box

				local il = Instance.new("TextLabel")
				il.Size = UDim2.new(1, -32, 1, 0)
				il.Position = UDim2.fromOffset(10, 0)
				il.BackgroundTransparency = 1
				il.Text = opt
				il.TextColor3 = C.TextPri
				il.TextSize = 11
				il.Font = Enum.Font.Gotham
				il.TextXAlignment = Enum.TextXAlignment.Left
				il.ZIndex = 102
				il.Parent = it

				it.MouseEnter:Connect(function()
					TweenService:Create(it, TweenInfo.new(0.1), { BackgroundTransparency = 0, BackgroundColor3 = C.BG3 }):Play()
				end)
				it.MouseLeave:Connect(function()
					TweenService:Create(it, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
				end)
				it.MouseButton1Click:Connect(function()
					if selected[opt] then
						selected[opt] = nil
						chk.Visible = false
						bks.Color = C.Border
						TweenService:Create(box, TweenInfo.new(0.12), { BackgroundColor3 = C.BG3 }):Play()
						il.TextColor3 = C.TextPri
					else
						selected[opt] = true
						chk.Visible = true
						bks.Color = C.Accent
						TweenService:Create(box, TweenInfo.new(0.12), { BackgroundColor3 = C.AccentFnt }):Play()
						il.TextColor3 = C.Accent
					end
					refreshLabel()
					if onChange then
						onChange(selected)
					end
				end)
			end

			db.MouseButton1Click:Connect(function()
				open = not open
				if open then
					positionList(lf, db)
				end
				lf.Visible = open
				TweenService:Create(arr, TweenInfo.new(0.15), { Rotation = open and 180 or 0 }):Play()
			end)
		end

		local function addSlider(col, order, label, mn, mx, def, onChange)
			local row = baseRow(col, order)
			row.Size = UDim2.new(1, 0, 0, ROW_H + 16)
			local val = def or mn

			local tl = Instance.new("TextLabel")
			tl.Size = UDim2.new(0.6, 0, 0, 18)
			tl.Position = UDim2.fromOffset(10, 4)
			tl.BackgroundTransparency = 1
			tl.Text = label
			tl.TextColor3 = C.TextPri
			tl.TextSize = 12
			tl.Font = Enum.Font.Gotham
			tl.TextXAlignment = Enum.TextXAlignment.Left
			tl.ZIndex = 5
			tl.Parent = row

			local vl = Instance.new("TextLabel")
			vl.Size = UDim2.new(0.35, 0, 0, 18)
			vl.Position = UDim2.new(0.62, 0, 0, 4)
			vl.BackgroundTransparency = 1
			vl.Text = tostring(val)
			vl.TextColor3 = C.Accent
			vl.TextSize = 11
			vl.Font = Enum.Font.GothamBold
			vl.TextXAlignment = Enum.TextXAlignment.Right
			vl.ZIndex = 5
			vl.Parent = row

			local tr = Instance.new("Frame")
			tr.Size = UDim2.new(1, -20, 0, 3)
			tr.Position = UDim2.fromOffset(10, 24)
			tr.BackgroundColor3 = C.BG3
			tr.BorderSizePixel = 0
			tr.ZIndex = 5
			tr.Parent = row
			rnd(tr, 99)
			strk(tr, C.Border, 1)

			local fi = Instance.new("Frame")
			fi.Size = UDim2.new((val - mn) / (mx - mn), 0, 1, 0)
			fi.BackgroundColor3 = C.Accent
			fi.BorderSizePixel = 0
			fi.ZIndex = 6
			fi.Parent = tr
			rnd(fi, 99)

			local sliding = false
			local function upd(ax)
				local p = math.clamp((ax - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
				val = math.round(mn + p * (mx - mn))
				vl.Text = tostring(val)
				fi.Size = UDim2.new(p, 0, 1, 0)
				if onChange then
					onChange(val)
				end
			end

			local tb = Instance.new("TextButton")
			tb.Size = UDim2.new(1, 0, 0, 18)
			tb.Position = UDim2.fromOffset(0, -7)
			tb.BackgroundTransparency = 1
			tb.Text = ""
			tb.ZIndex = 8
			tb.Parent = tr
			tb.MouseButton1Down:Connect(function(x)
				sliding = true
				upd(x)
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					sliding = false
				end
			end)
			UIS.InputChanged:Connect(function(i)
				if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
					upd(i.Position.X)
				end
			end)
		end

		local function addKeybind(col, order, label, default, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local bound = default or Enum.KeyCode.Unknown
			local waiting = false

			local kb = Instance.new("TextButton")
			kb.Size = UDim2.fromOffset(100, 20)
			kb.Position = UDim2.new(1, -108, 0.5, -10)
			kb.BackgroundColor3 = C.BG3
			kb.BorderSizePixel = 0
			kb.Text = bound == Enum.KeyCode.Unknown and "None" or bound.Name
			kb.TextColor3 = C.Accent
			kb.TextSize = 11
			kb.Font = Enum.Font.GothamBold
			kb.ZIndex = 5
			kb.Parent = row
			rnd(kb, 4)
			strk(kb, C.Border, 1)

			kb.MouseButton1Click:Connect(function()
				if waiting then
					return
				end
				waiting = true
				kb.Text = "Press..."
				kb.TextColor3 = C.TextMut
			end)
			UIS.InputBegan:Connect(function(i, gp)
				if not waiting or gp then
					return
				end
				if i.UserInputType == Enum.UserInputType.Keyboard then
					bound = i.KeyCode
					kb.Text = bound.Name
					kb.TextColor3 = C.Accent
					waiting = false
					if onChange then
						onChange(bound)
					end
				end
			end)
		end

		local function addNumberInput(col, order, label, default, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)

			local nb = Instance.new("Frame")
			nb.Size = UDim2.fromOffset(80, 22)
			nb.Position = UDim2.new(1, -88, 0.5, -11)
			nb.BackgroundColor3 = C.BG3
			nb.BorderSizePixel = 0
			nb.ZIndex = 5
			nb.Parent = row
			rnd(nb, 4)
			local ns = strk(nb, C.Border, 1)

			local nt = Instance.new("TextBox")
			nt.Size = UDim2.new(1, -8, 1, 0)
			nt.Position = UDim2.fromOffset(4, 0)
			nt.BackgroundTransparency = 1
			nt.Text = tostring(default or 0)
			nt.PlaceholderText = "0"
			nt.PlaceholderColor3 = C.TextMut
			nt.TextColor3 = C.TextPri
			nt.TextSize = 12
			nt.Font = Enum.Font.GothamBold
			nt.TextXAlignment = Enum.TextXAlignment.Center
			nt.ClearTextOnFocus = false
			nt.ZIndex = 6
			nt.Parent = nb
			nt.Focused:Connect(function()
				TweenService:Create(ns, TweenInfo.new(0.15), { Color = C.Accent, Thickness = 1.2 }):Play()
			end)
			nt.FocusLost:Connect(function()
				TweenService:Create(ns, TweenInfo.new(0.15), { Color = C.Border, Thickness = 1 }):Play()
				local n = tonumber(nt.Text)
				if not n then
					nt.Text = tostring(default or 0)
					return
				end
				nt.Text = tostring(n)
				if onChange then
					onChange(n)
				end
			end)
		end

		local function addTextInput(col, order, label, ph, onChange)
			local row = baseRow(col, order)
			rowLabel(row, label)

			local nb = Instance.new("Frame")
			nb.Size = UDim2.fromOffset(120, 22)
			nb.Position = UDim2.new(1, -128, 0.5, -11)
			nb.BackgroundColor3 = C.BG3
			nb.BorderSizePixel = 0
			nb.ZIndex = 5
			nb.Parent = row
			rnd(nb, 4)
			local ns = strk(nb, C.Border, 1)

			local tb = Instance.new("TextBox")
			tb.Size = UDim2.new(1, -8, 1, 0)
			tb.Position = UDim2.fromOffset(4, 0)
			tb.BackgroundTransparency = 1
			tb.Text = ""
			tb.PlaceholderText = ph or "..."
			tb.PlaceholderColor3 = C.TextMut
			tb.TextColor3 = C.TextPri
			tb.TextSize = 11
			tb.Font = Enum.Font.Gotham
			tb.TextXAlignment = Enum.TextXAlignment.Left
			tb.ClearTextOnFocus = false
			tb.ZIndex = 6
			tb.Parent = nb
			tb.Focused:Connect(function()
				TweenService:Create(ns, TweenInfo.new(0.15), { Color = C.Accent, Thickness = 1.2 }):Play()
			end)
			tb.FocusLost:Connect(function()
				TweenService:Create(ns, TweenInfo.new(0.15), { Color = C.Border, Thickness = 1 }):Play()
				if onChange then
					onChange(tb.Text)
				end
			end)
		end

		local function addLabel(col, order, text)
			local row = baseRow(col, order)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1, -20, 1, 0)
			l.Position = UDim2.fromOffset(10, 0)
			l.BackgroundTransparency = 1
			l.Text = text
			l.TextColor3 = C.TextMut
			l.TextSize = 11
			l.Font = Enum.Font.Gotham
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.TextWrapped = true
			l.ZIndex = 5
			l.Parent = row
			return l
		end

		local function addBadge(col, order, label, badgeTxt, badgeCol)
			local row = baseRow(col, order)
			rowLabel(row, label)
			local bc = badgeCol or C.Accent

			local badge = Instance.new("Frame")
			badge.AutomaticSize = Enum.AutomaticSize.X
			badge.Size = UDim2.new(0, 0, 0, 18)
			badge.AnchorPoint = Vector2.new(1, 0.5)
			badge.Position = UDim2.new(1, -10, 0.5, 0)
			badge.BackgroundColor3 = Color3.new(bc.R * 0.12, bc.G * 0.12, bc.B * 0.12)
			badge.BorderSizePixel = 0
			badge.ZIndex = 5
			badge.Parent = row
			rnd(badge, 99)
			local bst = Instance.new("UIStroke")
			bst.Color = bc
			bst.Thickness = 1
			bst.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			bst.Parent = badge
			local bpad = Instance.new("UIPadding")
			bpad.PaddingLeft = UDim.new(0, 7)
			bpad.PaddingRight = UDim.new(0, 7)
			bpad.Parent = badge
			local bl = Instance.new("TextLabel")
			bl.AutomaticSize = Enum.AutomaticSize.X
			bl.Size = UDim2.new(0, 0, 1, 0)
			bl.BackgroundTransparency = 1
			bl.Text = badgeTxt
			bl.TextColor3 = bc
			bl.TextSize = 10
			bl.Font = Enum.Font.GothamBold
			bl.ZIndex = 6
			bl.Parent = badge
		end

		local function addConfigsTab()
			TABS[#TABS + 1] = "Configs"
			TabPages["Configs"] = { L = makeScroll(LEFT), R = makeScroll(RIGHT) }

			local CoL = TabPages["Configs"].L
			local CoR = TabPages["Configs"].R

			addSection(CoL, 1, "appearance")
			addDropdown(CoL, 2, "UI Size", { "40%", "50%", "60%", "70%", "80%", "90%", "100%" }, function(v)
				local scaleMap = { ["40%"] = 0.4, ["50%"] = 0.5, ["60%"] = 0.6, ["70%"] = 0.7, ["80%"] = 0.8, ["90%"] = 0.9, ["100%"] = 1.0 }
				local scale = scaleMap[v] or 0.7
				local sc = W:FindFirstChildOfClass("UIScale")
				if sc then
					TweenService:Create(sc, TweenInfo.new(0.2), { Scale = scale }):Play()
				end
			end)

			addSection(CoL, 3, "config management")
			addTextInput(CoL, 4, "Config Name", "Enter config name...", function(v)
				if not ActiveConfig then
					ActiveConfig = {}
				end
				ActiveConfig._name = v
			end)

			addButton(CoL, 5, "Save Config", "Save", function()
				if ActiveConfig and ActiveConfig._name and ActiveConfig._name ~= "" then
					local configToSave = {}
					for k, v in pairs(ActiveConfig) do
						configToSave[k] = v
					end
					SavedConfigs[ActiveConfig._name] = configToSave
					saveConfigsToFile()
					if savedLabel then
						savedLabel.Text = "Last Saved: " .. os.date("%H:%M:%S")
					end
					showNotification("Config Saved", "Config '" .. ActiveConfig._name .. "' saved successfully.", "success")
				else
					showNotification("Error", "Enter a config name first.", "error")
				end
			end)

			addSection(CoR, 1, "saved configs")

			local configList = getConfigList()
			addDropdown(CoR, 2, "Load Config", configList, function(v)
				if v == "No saved configs" then return end
				if SavedConfigs[v] then
					ActiveConfig = SavedConfigs[v]
					showNotification("Config Loaded", "Config '" .. v .. "' loaded.", "info")
				end
			end)

			addButton(CoR, 3, "Delete Config", "Delete", function()
				if ActiveConfig and ActiveConfig._name and SavedConfigs[ActiveConfig._name] then
					SavedConfigs[ActiveConfig._name] = nil
					saveConfigsToFile()
					ActiveConfig = nil
					showNotification("Config Deleted", "Config removed.", "error")
				else
					showNotification("Error", "No config selected to delete.", "error")
				end
			end)

			addButton(CoR, 4, "Refresh List", "Refresh", function()
				showNotification("Refreshed", "Config list updated.", "info")
			end)

			savedLabel = addLabel(CoR, 5, "Last Saved: never")
		end

		addConfigsTab()
		rebuildTabBar()
		switchTab("Configs")
	end

	if KeySystem and not KeySystemPassed then
		buildKeySystem(buildMainUI)
	else
		buildMainUI()
	end

	function Window:CreateTabButton(config)
		local Name = config.Name or "New Tab"
		if TabPages[Name] then
			return Window._createTabMethods(Name)
		end

		local function makeScroll(parent)
			local sf = Instance.new("ScrollingFrame")
			sf.Size = UDim2.fromScale(1, 1)
			sf.BackgroundTransparency = 1
			sf.BorderSizePixel = 0
			sf.ScrollBarThickness = 2
			sf.ScrollBarImageColor3 = C.Accent
			sf.Visible = false
			sf.ZIndex = 4
			sf.Parent = parent
			local lay = Instance.new("UIListLayout")
			lay.Padding = UDim.new(0, 0)
			lay.SortOrder = Enum.SortOrder.LayoutOrder
			lay.Parent = sf
			local pad = Instance.new("UIPadding")
			pad.PaddingTop = UDim.new(0, 6)
			pad.PaddingBottom = UDim.new(0, 6)
			pad.PaddingLeft = UDim.new(0, 4)
			pad.PaddingRight = UDim.new(0, 4)
			pad.Parent = sf
			lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				sf.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 20)
			end)
			return sf
		end

		TabPages[Name] = { L = makeScroll(LEFT), R = makeScroll(RIGHT) }
		table.insert(TABS, #TABS, Name)
		rebuildTabBar()
		switchTab(Name)

		return Window._createTabMethods(Name)
	end

	function Window._createTabMethods(tabName)
		local Tab = {}
		local function getColumn(sectionName)
			if sectionName == "Right" then
				return TabPages[tabName].R
			end
			return TabPages[tabName].L
		end

		function Tab:Button(config)
			addButton(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Name or "Button", config.Callback or function() end)
			return Tab
		end

		function Tab:Toggle(config)
			addToggle(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Default or false, config.Callback or function() end)
			return Tab
		end

		function Tab:Checkbox(config)
			addCheckToggle(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Default or false, config.Callback or function() end)
			return Tab
		end

		function Tab:Input(config)
			addTextInput(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Placeholder, config.Callback or function() end)
			return Tab
		end

		function Tab:NumberInput(config)
			addNumberInput(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Default, config.Callback or function() end)
			return Tab
		end

		function Tab:Keybind(config)
			addKeybind(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Default or Enum.KeyCode.Unknown, config.Callback or function() end)
			return Tab
		end

		function Tab:Dropdown(config)
			if config.Multi then
				addMultiDropdown(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Options or {}, config.Callback or function() end)
			else
				addDropdown(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Options or {}, config.Callback or function() end)
			end
			return Tab
		end

		function Tab:Slider(config)
			addSlider(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Name, config.Min or 0, config.Max or 100, config.Default or 0, config.Callback or function() end)
			return Tab
		end

		function Tab:Label(config)
			addLabel(getColumn(config.Section or "Left"), #getColumn(config.Section or "Left"):GetChildren() + 1, config.Content or "")
			return Tab
		end

		function Tab:Section(config)
			local sectionName = config.Section or "Left"
			local title = config.Title or config.Name or ""
			if config.Badge then
				addSection(getColumn(sectionName), #getColumn(sectionName):GetChildren() + 1, title)
				addBadge(getColumn(sectionName), #getColumn(sectionName):GetChildren() + 1, title, config.Badge, C.Accent)
			else
				addSection(getColumn(sectionName), #getColumn(sectionName):GetChildren() + 1, title)
			end
			return Tab
		end

		return Tab
	end

	function Window:Notify(config)
		showNotification(config.Title or "Notification", config.Content or "", config.Type or "info", config.Duration or 5)
	end

	return Window
end

SlateUI.Notify = function(config)
	showNotification(config.Title or "Notification", config.Content or "", config.Type or "info", config.Duration or 5)
end

return SlateUI
