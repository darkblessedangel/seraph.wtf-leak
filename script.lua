-- source: https://github.com/darkblessedangel <3

if not game.Loaded then
	game.Loaded:Wait()
end

local seraphAcc = {username="femboy_kitty_furry_",role="whitelisted",workshop={},hexColor="#9b59b6",authKeys={first="",},userid=1,icon="",expires=0,}
if getgenv().loaded then 
	pcall(function()
		getgenv().library:unload_menu() 
		for i,v in next, getgenv().connections do v:Disconnect() end
	end)
end 

getgenv().loaded = true 

local seraphAcc = seraphAcc or {}

-- Variables 
local uis = game:GetService("UserInputService") 
local players = game:GetService("Players") 
local ws = game:GetService("Workspace")
local safeWorkspace = cloneref(workspace)
local rs = game:GetService("ReplicatedStorage")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = cloneref(game:GetService("CoreGui"))
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local sound_service = game:GetService("SoundService")
local configName = "default"
local player_list = {}
local esp_frames = {}
local lerpedFlySpeed, totalSpeed = 0, 1;

local _assets = game:GetObjects("rbxassetid://96007083256961")[1]:Clone()

function xpcall(...)
	for _, toPcall in {...} do
		if pcall(toPcall) then break end
	end
end

local cons = {}

local peakAsset = game:GetObjects("rbxassetid://113170053514092")[1]:Clone()
peakAsset.Size = Vector3.zero
peakAsset.Anchored, peakAsset.CanCollide, peakAsset.CanTouch, peakAsset.CanQuery = true, false, false, false

local visualization = peakAsset:Clone()
-- draw visualization
do
	function createArc(startAngle, endAngle, segments, radiusScale, thicknessScale)
		radiusScale = radiusScale or 0.45   -- % of min(parent size)
		thicknessScale = thicknessScale or 0.05

		local frame = Instance.new("Frame")
		frame.Name = "Arc"
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 1)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromScale(0.5, 0.5)

		local pieces = {}

		local function rebuild()
			for _, v in ipairs(pieces) do
				v:Destroy()
			end
			table.clear(pieces)

			local size = frame.AbsoluteSize
			if size.X == 0 or size.Y == 0 then return end

			local minSize = math.min(size.X, size.Y)
			local innerRadius = minSize * radiusScale
			local thickness = minSize * thicknessScale

			local startRad = math.rad(startAngle)
			local endRad = math.rad(endAngle)
			local theta = (endRad - startRad) / segments
			local sideLen = 2 * math.tan(theta / 2) * innerRadius

			for i = 0, segments - 1 do
				local angle = startRad + theta * (i + 0.5)

				local x = math.cos(angle) * innerRadius
				local y = math.sin(angle) * innerRadius

				local f = Instance.new("Frame")
				f.AnchorPoint = Vector2.new(0.5, 0.5)
				f.Size = UDim2.fromOffset(sideLen + 1, thickness)
				f.Position = UDim2.fromOffset(
					size.X / 2 + x,
					size.Y / 2 + y
				)
				f.Rotation = math.deg(angle) + 90
				f.BorderSizePixel = 0
				f.BackgroundColor3 =
					Color3.fromHSV(i / (segments - 1), 1, 1):Lerp(Color3.new(1,1,1), .5)

				f.Parent = frame
				table.insert(pieces, f)
			end
		end

		frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(rebuild)
		task.defer(rebuild)

		return frame
	end

	visualization:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("ImageLabel").ImageTransparency = 0.7
	local frame = createArc(0, 360, 360 / 5, 0.5, 0.007)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Parent = visualization:FindFirstChildWhichIsA("SurfaceGui")
	visualization:FindFirstChildWhichIsA("SurfaceGui").SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	visualization:FindFirstChildWhichIsA("SurfaceGui").PixelsPerStud = 50
	visualization.Parent = nil
end
-- end visualization

getgenv().connections = cons

--local run_debug = false
makefolder("seraph/debug")
makefolder("seraph/configs")
makefolder("seraph/sounds")

for soundPath, soundUrl in {
	["seraph/sounds/bubble.mp3"] = "https://github.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/sounds/bubble.mp3",
	["seraph/sounds/bubble2.mp3"] = "https://github.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/sounds/bubble2.mp3",
	["seraph/sounds/trident.mp3"] = "https://github.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/sounds/trident.mp3",
}
 do
	if not isfile(soundPath) then
		writefile(soundPath, game:HttpGet(soundUrl))
	end
end

--if run_debug then pcall(delfile, "seraph/cache/seraph.gif") pcall(delfile, "seraph/debug/debug.log") end
pcall(function()
	local defaultConfig = readfile("seraph/configs/default.value")
	if defaultConfig then
		configName = defaultConfig
	end
end)

local elapsed_ticks = 0
local holder = Instance.new("Folder", cloneref(workspace))

function get(url)
	return game:HttpGet(url) or request({
		Url = url,
		Method = "GET",
		Headers = {
			["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 SeraphClient/1.0 Chocosploit/1.0"
		}
	}).Body
end
function setproperty(obj, prop, value)
	obj[prop] = value
end

local isDone
task.spawn(function()

	local load = Instance.new("ScreenGui")
	load.Name = "load"
	load.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	load.Parent = coregui

	local frame = Instance.new("Frame")
	frame.Name = "frame"
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 0, 0, 25)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.BorderColor3 = Color3.new(0, 0, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Parent = load

	local UICorner = Instance.new("UICorner")
	UICorner.Name = "UICorner"

	UICorner.Parent = frame

	local icon = Instance.new("ImageLabel")
	icon.Name = "icon"
	icon.Size = UDim2.new(0, 25, 0, 25)
	icon.BackgroundColor3 = Color3.new(1, 1, 1)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.BorderColor3 = Color3.new(0, 0, 0)
	icon.Transparency = 1
	icon.Image = "rbxassetid://101942723117519"
	icon.Parent = frame

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Name = "UIStroke"
	UIStroke.Thickness = 2
	UIStroke.Parent = frame

	local UIStroke2 = Instance.new("UIStroke")
	UIStroke2.Name = "UIStroke"
	UIStroke2.Thickness = 2.5
	UIStroke2.Transparency = 0.25
	UIStroke2.Parent = frame

	local UIStroke3 = Instance.new("UIStroke")
	UIStroke3.Name = "UIStroke"
	UIStroke3.Thickness = 3
	UIStroke3.Transparency = 0.5
	UIStroke3.Parent = frame

	local UIStroke4 = Instance.new("UIStroke")
	UIStroke4.Name = "UIStroke"
	UIStroke4.Thickness = 4
	UIStroke4.Transparency = 0.75
	UIStroke4.Parent = frame

	local UIStroke5 = Instance.new("UIStroke")
	UIStroke5.Name = "UIStroke"
	UIStroke5.Thickness = 8
	UIStroke5.Transparency = 0.9900000095367432
	UIStroke5.Parent = frame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Name = "UIListLayout"
	UIListLayout.Padding = UDim.new(0, 6)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = frame

	local fps = Instance.new("TextLabel")
	fps.Name = "fps"
	fps.Size = UDim2.new(0, 0, 0, 25)
	fps.BackgroundColor3 = Color3.new(1, 1, 1)
	fps.BackgroundTransparency = 1
	fps.BorderSizePixel = 0
	fps.BorderColor3 = Color3.new(0, 0, 0)
	fps.AutomaticSize = Enum.AutomaticSize.X
	fps.LayoutOrder = 7
	fps.Text = "Preparing setup.."
	fps.TextColor3 = Color3.new(0.956863, 0.956863, 0.956863)
	fps.TextSize = 16
	fps.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	fps.TextWrapped = true
	fps.Parent = frame

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Name = "UIPadding"
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.Parent = frame

	local UIStroke6 = Instance.new("UIStroke")
	UIStroke6.Name = "UIStroke"
	UIStroke6.Thickness = 4.5
	UIStroke6.Transparency = 0.800000011920929
	UIStroke6.Parent = frame

	local UIStroke7 = Instance.new("UIStroke")
	UIStroke7.Name = "UIStroke"
	UIStroke7.Thickness = 5
	UIStroke7.Transparency = 0.8500000238418579
	UIStroke7.Parent = frame

	local UIStroke8 = Instance.new("UIStroke")
	UIStroke8.Name = "UIStroke"
	UIStroke8.Thickness = 5.5
	UIStroke8.Transparency = 0.8999999761581421
	UIStroke8.Parent = frame

	frame.Visible = false
	task.wait(1)
	frame.Visible = true
	setproperty(fps,"TextTransparency",1)
	setproperty(icon,"ImageTransparency",1)
	setproperty(frame,"BackgroundTransparency",1)
	tween_service:Create(fps, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
	tween_service:Create(icon, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
	tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
	tween_service:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {ImageColor3 = Color3.new()}):Play()
	for _, stroke in frame:GetChildren() do
		if not stroke:IsA("UIStroke") then continue end
		local trans = stroke.Transparency
		setproperty(stroke,"Transparency",1)
		tween_service:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = trans}):Play()
	end

	task.wait(0.25)

	if not isfile("seraph/cache/seraphdata.gif") then

		makefolder("seraph/gifs")

		tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.1, 0)}):Play()

		for i = 1, 150 do
			local frame_translation = string.format("frame_%03d_delay-0.02s.png", i-1)
			writefile(`seraph/gifs/{frame_translation}`, get("https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/gifs/" .. frame_translation))

			fps.Text = "We're geting things set up for you..".. (" (" .. i .. "/150)")
			task.wait()


		end
		writefile("seraph/cache/seraphdata.gif", "<translation=\"completed\">")

		task.wait(0.5)

		tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

		task.wait(1)
	end

	if not isfile("seraph/cache/images.cache") then

		tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.1, 0)}):Play()

		local asset_list = {
			['von.png'] = 'https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/imgs/von.png',
			['icon.jpg'] = 'https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/imgs/icon.jpg',
			['atom.png'] = 'https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/imgs/atom.png',
			['ser.png'] = 'https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/imgs/ser.png',
			['aph.png'] = 'https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/imgs/aph.png',
		}

		makefolder("seraph/imgs")

		local n, l = 0, 0

		for _ in asset_list do
			l += 1
		end

		for i, v in asset_list do
			n += 1

			local src = get(v)

			writefile(`seraph/imgs/{i}`, src)

			fps.Text = "Downloading images..".. (` ({n} / {l})`)
			task.wait(0.5)


		end
		writefile("seraph/cache/images.cache", "<translation=\"completed\">")

		task.wait(0.5)

		tween_service:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

		task.wait(1)
	end

	fps.Text = "Cleaning up..."

	task.wait(0.25)

	isDone = true

	tween_service:Create(fps, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
	tween_service:Create(icon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
	tween_service:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
	for _, stroke in frame:GetChildren() do
		if not stroke:IsA("UIStroke") then continue end
		tween_service:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
	end
end)


repeat task.wait() until isDone

function create(class, prop)
	local inst = Instance.new(class)
	if typeof(prop) == 'table' then
		for i, v in prop do
			inst[i] = v
		end
	end
	return inst
end

if (game.GameId == 73885730) then
	configName = "prison-life"
elseif (game.PlaceId == 286090429) then
	configName = "arsenal"
end

pcall(function()
	local defaultConfig = readfile(`seraph/configs/{tostring(game.PlaceId)}.value`)
	if defaultConfig then
		configName = defaultConfig
	end
end)

for _,v in listfiles("seraph") do
	if string.match(v, ".value") or string.match(v, ".vector") then
		local name = string.gsub(v, "seraph/", "")
		local src = readfile(v)
		delfile(v)
		writefile(`seraph/configs/{name}`, src)
	end
end

pcall(sethiddenproperty,workspace,"SignalBehavior",Enum.SignalBehavior.Immediate)

local sfx = {
	none = "",
	rust = "rbxassetid://97189180645129",
	ding = "rbxassetid://9126073001",
	neverlose = "rbxassetid://18391691942",
	fatality = "rbxassetid://6607142036",
	hit = "rbxassetid://71845200764605",
	hitmarker = "rbxassetid://7242037470",
	baimware = "rbxassetid://6607339542",
	onetap = "rbxassetid://126006761622363",
	kickball = "rbxassetid://102170046721162",
	gamesense = "rbxassetid://4817809188",
	pop = "rbxassetid://85730811347567",
	["minecraft success"] = "rbxassetid://135478009117226",
	["bwomp"] = "rbxassetid://89053290756490",
	["retro ouch"] = "rbxassetid://109681634329245",
	["terraria slime"] = "rbxassetid://6916371803",
}
for _, file in listfiles("seraph/sounds/") do
	local fileName = string.split(file, "sounds\\")[2]:gsub(".mp3", "")
	sfx[fileName] = getcustomasset(file)
end

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new 
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer
if not lp then
	repeat run.RenderStepped:Wait() lp = players.LocalPlayer until lp
end
local mouse = lp:GetMouse() 
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max 
local floor = math.floor 
local min = math.min 
local abs = math.abs 
local noise = math.noise
local rad = math.rad 
local random = math.random 
local pow = math.pow 
local sin = math.sin 
local cos = math.cos
local pi = math.pi 
local tan = math.tan 
local atan2 = math.atan2 
local clamp = math.clamp 
local rng = random

local insert = table.insert
local find = table.find 
local remove = table.remove
local concat = table.concat
-- 

-- Library init
getgenv().library = {
	directory = "seraph",
	folders = {
		"/fonts",
		"/cfg",
		"/lua"
	},
	flags = {},
	config_flags = {},

	connections = {},   
	notifications = {},
	playerlist_data = {
		players = {},
		player = {}, 
	},
	colorpicker_open = false; 
	gui; 
}


library.gradientEvent = Instance.new("BindableEvent")
library.gradientChanged = library.gradientEvent.Event

library.guiVisibility = Instance.new("BindableEvent")
library.guiVisibilityChanged = library.guiVisibility.Event

library.font = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)

local themes = {
	corners = true,

	preset = {
		--[[outline = rgb(10, 10, 10),
		inline = rgb(35, 35, 35),
		text = rgb(180, 180, 180),
		text_outline = rgb(0, 0, 0),
		background = rgb(20, 20, 20),

		["1"] = rgb(33, 33, 33), 
		["2"] = rgb(33, 33, 33),
		["3"] = rgb(33, 33, 33),
		]]
		outline = rgb(0, 0, 0),             -- Pure black outer border
        inline = rgb(14, 14, 14),           -- Lighter inner "shine" border
        text = rgb(255, 255, 255),          -- Bright white text
        text_outline = rgb(0, 0, 0),
        background = rgb(15, 15, 15),       -- Darker background for contrast
        
        -- These replace your "1", "2", "3" with the Bitchbot section colors
        ["1"] = rgb(20, 20, 20), 
        ["2"] = rgb(20, 20, 20),
        ["3"] = rgb(20, 20, 20),

		button = seraphAcc.theme and seraphAcc.theme.button or rgb(121, 96, 180),
		button_alt = seraphAcc.theme and seraphAcc.theme.button_alt or rgb(151, 125, 214)
	},

	utility = {
		inline = {
			BackgroundColor3 = {} 	
		},
		text = {
			TextColor3 = {}	
		},
		text_outline = {
			Color = {} 	
		},
		["1"] = {
			BackgroundColor3 = {}, 	
			TextColor3 = {}, 
			ImageColor3 = {}, 
			ScrollBarImageColor3 = {} 
		},
		["2"] = {
			BackgroundColor3 = {}, 	
			TextColor3 = {}, 
			ImageColor3 = {}, 
			ScrollBarImageColor3 = {} 
		},
		["3"] = {
			BackgroundColor3 = {}, 	
			TextColor3 = {}, 
			ImageColor3 = {}, 
			ScrollBarImageColor3 = {} 
		},
	}
}

local keys = {
	[Enum.KeyCode.LeftShift] = "LS",
	[Enum.KeyCode.RightShift] = "RS",
	[Enum.KeyCode.LeftControl] = "LC",
	[Enum.KeyCode.RightControl] = "RC",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent",
	[Enum.KeyCode.LeftAlt] = "LA",
	[Enum.KeyCode.RightAlt] = "RA",
	[Enum.KeyCode.CapsLock] = "CAPS",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.Semicolon] = ",",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Backquote] = "`",
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do 
	makefolder(library.directory .. path)
end

local flags = library.flags 
local config_flags = library.config_flags

-- Font importing system 
local fonts = {}; do
	function Register_Font(Name, Weight, Style, Asset)
		Asset.Id = library.directory .. "/fonts/" .. Asset.Id
		if not isfile(Asset.Id) then
			writefile(Asset.Id, Asset.Font)
		end

		if isfile(library.directory .. "/fonts/" ..Name .. ".font") then
			delfile(library.directory .. "/fonts/" ..Name .. ".font")
		end

		local Data = {
			name = Name,
			faces = {
				{
					name = "Regular",
					weight = Weight,
					style = Style,
					assetId = getcustomasset(Asset.Id),
				},
			},
		}

		writefile(Name .. ".font", game:GetService("HttpService"):JSONEncode(Data))

		return getcustomasset(Name .. ".font");
	end

	local ProggyTiny = Register_Font("ProggyTiny", 200, "Normal", {
		Id = "ProggyTiny.ttf",
		Font = game:HttpGet("https://github.com/darkblessedangel/seraph.wtf-leak/raw/refs/heads/main/fonts/ProggyTiny.ttf"),
	})

	local ProggyClean = Register_Font("ProggyClean", 200, "normal", {
		Id = "ProggyClean.ttf",
		Font = game:HttpGet("https://github.com/darkblessedangel/seraph.wtf-leak/raw/refs/heads/main/fonts/ProggyClean.ttf")
	})

	local Pixel = Register_Font("Pixel", 200, "normal", {
		Id = "Pixel.ttf",
		Font = game:HttpGet("https://github.com/darkblessedangel/seraph.wtf-leak/raw/refs/heads/main/fonts/Pixel.ttf")
	})

	local Tahoma = Register_Font("Tahoma", 200, "normal", {
		Id = "Tahoma.ttf",
		Font = game:HttpGet("https://github.com/darkblessedangel/seraph.wtf-leak/raw/refs/heads/main/fonts/Tahoma.ttf")
	})

	local Verdana = Register_Font("Verdana", 200, "normal", {
		Id = "Verdana.ttf",
		Font = game:HttpGet("https://github.com/darkblessedangel/seraph.wtf-leak/raw/refs/heads/main/fonts/Verdana.ttf")
	})

	local Pixel2 = Register_Font("Pixel2", 200, "normal", {
		Id = "Pixel2.ttf",
		Font = game:HttpGet("https://github.com/darkblessedangel/seraph.wtf-leak/raw/refs/heads/main/fonts/Pixel2.ttf")
	})

	fonts = {
		["TahomaBold"] = Font.new(ProggyTiny, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		["ProggyClean"] = Font.new(ProggyClean, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		["Pixel"] = Font.new(Pixel, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		["Verdana"] = Font.new(Verdana, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		["Tahoma"] = Font.new(Tahoma, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
		["Pixel2"] = Font.new(Pixel2, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	}

	library.font = fonts.ProggyClean
end
--
-- 

-- Library functions 
-- Misc functions
function library:tween(obj, properties) 
	local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()

	return tween
end 

function library:close_current_element(cfg) 
	local path = library.current_element_open

	if path then
		path.set_visible(false)
		path.open = false 
	end
end 

function library:resizify(frame) 
	local Frame = Instance.new("TextButton")
	Frame.Position = dim2(1, -10, 1, -10)
	Frame.BorderColor3 = rgb(0, 0, 0)
	Frame.Size = dim2(0, 10, 0, 10)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = rgb(255, 255, 255)
	Frame.Parent = frame
	Frame.BackgroundTransparency = 1 
	Frame.Text = ""

	local resizing = false 
	local start_size 
	local start 
	local og_size = frame.Size  

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			start = input.Position
			start_size = frame.Size
		end
	end)

	Frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	library:connection(uis.InputChanged, function(input, game_event) 
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local viewport_x = camera.ViewportSize.X
			local viewport_y = camera.ViewportSize.Y

			local current_size = dim2(
				start_size.X.Scale,
				math.clamp(
					start_size.X.Offset + (input.Position.X - start.X),
					og_size.X.Offset,
					viewport_x
				),
				start_size.Y.Scale,
				math.clamp(
					start_size.Y.Offset + (input.Position.Y - start.Y),
					og_size.Y.Offset,
					viewport_y
				)
			)
			frame.Size = current_size
		end
	end)
end

function library:mouse_in_frame(uiobject)
	local y_cond = uiobject.AbsolutePosition.Y <= mouse.Y and mouse.Y <= uiobject.AbsolutePosition.Y + uiobject.AbsoluteSize.Y
	local x_cond = uiobject.AbsolutePosition.X <= mouse.X and mouse.X <= uiobject.AbsolutePosition.X + uiobject.AbsoluteSize.X

	return (y_cond and x_cond)
end

library.lerp = function(start, finish, t)
	t = t or 1 / 8

	return start * (1 - t) + finish * t
end

function library:draggify(frame, scale)
	local scale = scale or 1
	local dragging = false 
	local start_size = frame.Position
	local start 

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			start = input.Position
			start_size = frame.Position
		end
	end)

	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	library:connection(uis.InputChanged, function(input, game_event) 
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local viewport_x = camera.ViewportSize.X
			local viewport_y = camera.ViewportSize.Y

			local current_position = dim2(
				0,
				floor(clamp(
					start_size.X.Offset + (input.Position.X - start.X),
					0,
					viewport_x - frame.Size.X.Offset
					) / scale) * scale,
				0,
				floor(clamp(
					start_size.Y.Offset + (input.Position.Y - start.Y),
					0,
					viewport_y - frame.Size.Y.Offset
					) / scale) * scale
			)

			frame.Position = current_position
		end
	end)
end 

function library:convert(str)
	local values = {}

	for value in string.gmatch(str, "[^,]+") do
		insert(values, tonumber(value))
	end

	if #values == 4 then              
		return unpack(values)
	else 
		return
	end
end

function library:convert_enum(enum)
	local enum_parts = {}

	for part in string.gmatch(enum, "[%w_]+") do
		insert(enum_parts, part)
	end

	local enum_table = Enum
	for i = 2, #enum_parts do
		local enum_item = enum_table[enum_parts[i]]

		enum_table = enum_item
	end

	return enum_table
end

local config_holder;
function library:update_config_list() 
	if not config_holder then 
		return 
	end

	local list = {}

	for idx, file in listfiles(library.directory .. "/configs") do
		if not file:match(".cfg") then continue end
		local name = file:gsub(library.directory .. "/configs\\", ""):gsub(".cfg", ""):gsub(library.directory .. "\\cfg\\", "")
		list[#list + 1] = name
	end


	config_holder.refresh_options(list)
end 

function library:get_config()
    local Config = {}

    for flag_name, v in pairs(flags) do
        if type(v) == "table" and v.key then
            Config[flag_name] = {
                active = v.active, 
                mode = v.mode, 
                key = tostring(v.key)
            }
        elseif type(v) == "table" and v["Color"] then
            local colorHex = typeof(v["Color"]) == "Color3" and v["Color"]:ToHex() or v["Color"]
            Config[flag_name] = {
                Transparency = v["Transparency"] or 0, 
                Color = colorHex
            }
        elseif type(v) ~= "table" and type(v) ~= "userdata" and type(v) ~= "function" then
            Config[flag_name] = v
        elseif type(v) == "table" then
            local cleanTable = {}
            local isPureTable = true
            for i, val in pairs(v) do
                if type(val) == "userdata" or type(val) == "function" then
                    isPureTable = false
                    break
                end
                cleanTable[i] = val
            end
            if isPureTable then
                Config[flag_name] = cleanTable
            end
        end
    end 

    return http_service:JSONEncode(Config)
end

function library:load_config(config_json) 
	local config = http_service:JSONDecode(config_json)

	for _, v in next, config do 
		pcall(function()
			local function_set = library.config_flags[_]

			if _ == "config_name_list" then 
				return
			end

			if function_set then 
				if type(v) == "table" and v["Transparency"] and v["Color"] then
					function_set(hex(v["Color"]), v["Transparency"])
					--print("set cp!")
				elseif type(v) == "table" and v["active"] then 
					function_set(v)
				else
					function_set(v)
				end
			end 
		end)
	end 
end 

function library:round(number, float) 
	local multiplier = 1 / (float or 1)

	return floor(number * multiplier + 0.5) / multiplier
end 

function library:apply_theme(instance, theme, property) 
	insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
	for _, property in themes.utility[theme] do 

		for m, object in property do 
			if object[_] == themes.preset[theme] then 
				object[_] = color 
			end
		end 
	end 

	themes.preset[theme] = color 
end 

function library:connection(signal, callback)
	local connection = signal:Connect(callback)

	insert(library.connections, connection)

	return connection 
end

function library:apply_stroke(parent) 
	local STROKE = library:create("UIStroke", {
		Parent = parent,
		Color = themes.preset.text_outline, 
		LineJoinMode = Enum.LineJoinMode.Miter
	}) 

	library:apply_theme(STROKE, "text_outline", "Color")
end

function library:create(instance, options)
	local ins = Instance.new(instance) 

	for prop, value in next, options do 
		ins[prop] = value
	end

	if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
		library:apply_theme(ins, "text", "TextColor3")
		library:apply_stroke(ins)
	end

	return ins 
end

function library:unload_menu() 
	if library.gui then 
		library.gui:Destroy()
	end

	for index, connection in next, library.connections do 
		pcall(function()
			connection:Disconnect() 
			connection = nil 
		end)
	end     

	if library.sgui then 
		library.sgui:Destroy()
	end 

	unload_full()

	library = nil 

end 
--


function ref_trans(obj)

	if not transValues[obj] then
		transValues[obj] = {}
	end
end

-- Library element functions

function udim_scale(udim, scale)
	return UDim2.new(udim.X.Scale * scale, udim.X.Offset * scale, udim.Y.Scale * scale, udim.Y.Offset * scale)
end
function library:window(properties)
	local cfg = {
		name = properties.name or properties.Name or "fijihack.panda",
		size = properties.size or properties.Size or dim2(0, 460, 0, 362), 
		selected_tab 
	}

	library.gui = library:create("ScreenGui", {
		Parent = coregui,
		Name = "\0",
		Enabled = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 9e4
	})

	local particles = { }
	for i = 1, 65 do
		particles[i] = {
			frame = library:create("Frame", {
				Parent = library.gui,
				Size = dim2(0, 2, 0, 2),
				BackgroundColor3 = rgb(255, 255, 255),
				BorderSizePixel = 0,
				Position = dim2(math.random(), math.random(-10,10), math.random(), math.random(-10,10)),
				BackgroundTransparency = 1
			}),
			position = vec2(math.random() * camera.ViewportSize.X, -rng(1,20)),
			velocity = vec2(rng(-5,5), rng(5,8))
		}
	end


	local scale, scale2 = library:create("UIScale", {
		Parent = library.gui
	}), library:create("UIScale", {
		Parent = library.gui
	})

	library.gui_scale = 1
	library.main_scale = scale

	pcall(function()
		library.gui_scale = tonumber(readfile("seraph/configs/default_scale.value"))
	end)

	local tween
	local info = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	library.gui_visible = true
	library.guiVisibility:Fire(library.gui_visible)

	local gui_connections = {}

	uis.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Home and not guiDebounce then
			library:set_visibility()
		end
	end)

	function library:set_visibility()
		if tween then tween:Cancel() end
		guiDebounce = true
		tween = tween_service:Create(scale, info, {Scale = library.gui_visible and 0 or library.gui_scale}) 		tween:Play()
		library.gui_visible = not library.gui_visible 
		writefile("seraph/configs/default_scale.value", tostring(library.gui_scale))
		library.guiVisibility:Fire(library.gui_visible)
			--[[if library.gui_visible then
				for x, con in gui_connections do
					con:Enable()
					if x % 5 == 0 then task.wait() end
				end
			else
				for x, con in gui_connections do
					con:Disable()
					if x % 5 == 0 then task.wait() end
				end
			end]]
			task.wait()
		guiDebounce = false
	end

	local window_outline = library:create("Frame", {
		Parent = library.gui;
		Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2);
		BorderColor3 = rgb(0, 0, 0);
		Size = cfg.size;
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	function library:set_scale(scale_value)
		library.gui_scale = scale_value
		if tween then tween:Cancel() end
		scale.Scale = library.gui_visible and scale_value or 0
	end

	task.delay(0.1, function()
		tween = tween_service:Create(scale, info, {Scale = library.gui_scale})
		tween:Play()
	end)


	-- Window

	library:create("ImageLabel", {
		Name = "glow",
		Image = "rbxassetid://18245826428",
		BackgroundTransparency = 1,
		ImageColor3 = rgb(),
		ZIndex = -1,
		ImageTransparency = 0.8,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(0, -20, 0, -20),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(21, 21, 79, 79),
		Parent = window_outline
	})

	library.main_frame = window_outline

	if themes.corners then
		library:create("UICorner", {
			Parent = window_outline,
			CornerRadius = UDim.new(0, 2)
		})

		scale.Parent = window_outline
	end

	window_outline.Position = dim2(0, window_outline.AbsolutePosition.Y, 0, window_outline.AbsolutePosition.Y)
	cfg.main_outline = window_outline

	library:resizify(window_outline)
	library:draggify(window_outline)

	local title_holder = library:create("Frame", {
		Parent = window_outline;
		BackgroundTransparency = 0.800000011920929;
		Position = dim2(0, 2, 0, 2);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -4, 0, 20);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0)
	});


	local ui_title = library:create("TextLabel", {
		FontFace = fonts["TahomaBold"];
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = title_holder;
		BackgroundTransparency = 1;
		Size = dim2(1, 0, 1, 0);
		BorderSizePixel = 0;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255),
		RichText = true,
	});

	function cfg:set_title(new_title)
		ui_title.Text = new_title
	end

	library.gradient = library:create("UIGradient", {
		Color = rgbseq{
			rgbkey(0, themes.preset["1"]), 
			rgbkey(0.5, themes.preset["2"]),
			rgbkey(1, themes.preset["3"]),
		};
		Parent = window_outline
	});

	local tab_button_holder = library:create("Frame", {
		AnchorPoint = vec2(0, 1);
		Parent = window_outline;
		BackgroundTransparency = 0.800000011920929;
		Position = dim2(0, 2, 1, -2);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -4, 0, 20);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0)
	}); cfg.tab_button_holder = tab_button_holder

	library:create("UIListLayout", {
		VerticalAlignment = Enum.VerticalAlignment.Center;
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		HorizontalFlex = Enum.UIFlexAlignment.Fill;
		Parent = tab_button_holder;
		SortOrder = Enum.SortOrder.LayoutOrder;
		VerticalFlex = Enum.UIFlexAlignment.Fill
	});
	--

	return setmetatable(cfg, library)
end 

function library:tab(properties)
	local cfg = {
		name = properties.name or "visuals", 
		count = 0,
		on_click = properties.on_click or function() end,
	}

	-- Instances 
	-- Tab Button
	local tab_button = library:create("TextButton", {
		FontFace = library.font;
		TextColor3 = rgb(170, 170, 170);
		BorderColor3 = rgb(0, 0, 0);
		Text = '';
		Parent = self.tab_button_holder;
		BackgroundTransparency = 0;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.XY;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});
	-- 

	library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(170, 170, 170);
		BorderColor3 = rgb(0, 0, 0);
		Size = UDim2.new(1, 0, 1, 0);
		Text = cfg.name;
		Parent = tab_button;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.XY;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Color = rgbseq{
			rgbkey(0, themes.preset["1"]:lerp(rgb(), .3)), 
			rgbkey(1, themes.preset["2"]),
		};
		Rotation = 90;
		Parent = tab_button
	});

	-- Page
	local Page = library:create("Frame", {
		Parent = self.main_outline;
		BackgroundTransparency = 0.6;
		Position = dim2(0, 2, 0, 24);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -4, 1, -48);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0),
		Visible = false,
	}); cfg.page = Page

	library:create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal;
		HorizontalFlex = Enum.UIFlexAlignment.Fill;
		Parent = Page;
		Padding = dim(0, 2);
		SortOrder = Enum.SortOrder.LayoutOrder;
		VerticalFlex = Enum.UIFlexAlignment.Fill
	});

	library:create("UIPadding", {
		PaddingTop = dim(0, 2);
		PaddingBottom = dim(0, 2);
		Parent = Page;
		PaddingRight = dim(0, 2);
		PaddingLeft = dim(0, 2)
	});
	-- 
	-- 

	function cfg.open_tab() 
		local selected_tab = self.selected_tab

		if selected_tab then 
			selected_tab[1].Visible = false 
			selected_tab[2].TextColor3 = rgb(170, 170, 170)

			selected_tab = nil 
		end

		Page.Visible = true
		tab_button.TextColor3 = rgb(255, 255, 255)

		self.selected_tab = {Page, tab_button}

		cfg.on_click()
	end

	function cfg.change_visibility(self, visible)
		tab_button.Visible = visible
		cfg.visible = visible
	end

	cfg.visible = true

	tab_button.MouseButton1Down:Connect(function()
		cfg.open_tab()
	end)

	if not self.selected_tab then 
		cfg.open_tab(true) 
	end

	return setmetatable(cfg, library)    
end 

local notifications = {notifs = {}} 

library.sgui = library:create("ScreenGui", {
	Name = "Hi",
	Parent = gethui() 
})

function notifications:refresh_notifs() 
	for i, v in notifications.notifs do 
		local Position = vec2(50, 50)
		tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = dim_offset(Position.X, Position.Y + (i * 30))}):Play()
	end
end

function notifications:fade(path, is_fading)
	local fading = is_fading and 1 or 0 

	tween_service:Create(path, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = fading}):Play()

	for _, instance in path:GetDescendants() do 
		if not instance:IsA("GuiObject") then 
			if instance:IsA("UIStroke") then
				tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Transparency = fading}):Play()
			end

			continue
		end 

		if instance:IsA("TextLabel") then
			tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = fading}):Play()
		elseif instance:IsA("Frame") then
			tween_service:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = instance.Transparency and 0.6 and is_fading and 1 or 0.6}):Play()
		end
	end
end 

library.hitLogGui = library:create("ScreenGui", {
    Name = "HitLogs",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = gethui()
})

library.logContainer = library:create("Frame", {
    Name = "LogContainer",
    Size = UDim2.new(0, 0, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    AutomaticSize = Enum.AutomaticSize.X,
    Parent = library.hitLogGui
})

library:create("UIListLayout", {
    Name = "UiListLayout",
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 2),
    Parent = library.logContainer
})

library.activeNotifications = 0

function library:spawnLog(text)
	local identity = getidentity()
	setidentity(8)
    local logFrame = library:create("Frame", {
        Name = "LogFrame",
        Size = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        BackgroundTransparency = 0.5,
        AutomaticSize = Enum.AutomaticSize.X,
        BorderSizePixel = 0,
        Parent = library.logContainer
    })

	local scale = library:create("UIScale", {
		Parent = logFrame,
		Scale = 0
	})

	tween_service:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Scale = 1}):Play()

	library.activeNotifications += 1
	local notifId = library.activeNotifications

    library:create("UIPadding", {
        Name = "UiPadding",
        PaddingTop = UDim.new(0, 1),
        PaddingBottom = UDim.new(0, 1),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 64),
        Parent = logFrame
    })

    library:create("UIGradient", {
        Name = "MainGradient",
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.0822943, 0),
            NumberSequenceKeypoint.new(0.366584, 0.0375),
            NumberSequenceKeypoint.new(0.51995, 0.19375),
            NumberSequenceKeypoint.new(0.75187, 0.2875),
            NumberSequenceKeypoint.new(0.840399, 0.66875),
            NumberSequenceKeypoint.new(0.9202, 0.85625),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Parent = logFrame
    })

    local textLabel = library:create("TextLabel", {
        Name = "Segments",
        Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
		TextStrokeTransparency = 1,
        ZIndex = 5,
        AutomaticSize = Enum.AutomaticSize.X,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        RichText = true,
        FontFace = fonts.ProggyClean,
        Parent = logFrame
    })

    local accentBar = library:create("Frame", {
        Name = "AccentBar",
        Position = UDim2.new(0, -6, 0, 0),
        Size = UDim2.new(0, 8, 1, 0),
        BackgroundColor3 = themes.preset.button_alt,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        Parent = logFrame
    })

    library:create("UIGradient", {
        Name = "AccentGradient",
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), 
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.527431, 0),
            NumberSequenceKeypoint.new(0.599751, 1),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Parent = accentBar
    })

    local topBorder = library:create("Frame", {
        Name = "TopBorder",
        Position = UDim2.new(0, -5, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
		BackgroundTransparency = 0.4,
        Parent = logFrame
    })

    local bottomBorder = library:create("Frame", {
        Name = "BottomBorder",
        Position = UDim2.new(0, -5, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
		BackgroundTransparency = 0.4,
        Parent = logFrame
    })

    local borderSequence = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.0822943, 0),
        NumberSequenceKeypoint.new(0.713217, 0),
        NumberSequenceKeypoint.new(0.75187, 0.2875),
        NumberSequenceKeypoint.new(0.840399, 0.66875),
        NumberSequenceKeypoint.new(0.9202, 0.85625),
        NumberSequenceKeypoint.new(1, 1)
    })

    library:create("UIGradient", { Name = "TopGrad", Transparency = borderSequence, Parent = topBorder })
    library:create("UIGradient", { Name = "BottomGrad", Transparency = borderSequence, Parent = bottomBorder })

    task.spawn(function()
		run.RenderStepped:Wait()
		local timeWaiting = 7
		repeat
			timeWaiting -= run.RenderStepped:Wait()
		until (timeWaiting <= 0 or (library.activeNotifications - notifId) > 20)
		library.activeNotifications -= 1
		tween_service:Create(bottomBorder, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		tween_service:Create(topBorder, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		tween_service:Create(accentBar, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		tween_service:Create(logFrame, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		tween_service:Create(textLabel, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		tween_service:Create(textLabel, TweenInfo.new(1.05, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(-2, 0, 0)}):Play()
        task.delay(1.0, game.Destroy, logFrame)
    end)
	setidentity(identity)
end

function notifications:create_notification(options)
	local cfg = {
		name = options.name or "Hit: q3sm (finobe) in the Head for 100 Damage!",
		outline; 
	}

	-- Instances
	local outline = library:create("Frame", {
		Parent = library.sgui;
		Position = dim_offset(-50, 50 + (#notifications.notifs * 30)); -- origin (dependant on the watermark position rn)
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0, 0, 0, 24);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	local dark = library:create("Frame", {
		Parent = outline;
		BackgroundTransparency = 1;
		Position = dim2(0, 2, 0, 2);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -4, 1, -4);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0)
	});

	library:create("UIPadding", {
		PaddingTop = dim(0, 7);
		PaddingBottom = dim(0, 6);
		Parent = dark;
		PaddingRight = dim(0, 7);
		PaddingLeft = dim(0, 4)
	});

	library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = dark;
		Size = dim2(0, 0, 1, 0);
		Position = dim2(0, 1, 0, -1);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	}); 

	library:create("UIGradient", {
		Color = rgbseq{
			rgbkey(0, themes.preset["1"]), 
			rgbkey(0.5, themes.preset["2"]),
			rgbkey(1, themes.preset["3"]),
		};
		Parent = outline
	});
	-- 

	local index = #notifications.notifs + 1
	notifications.notifs[index] = outline

	notifications:refresh_notifs()
	tween_service:Create(outline, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {AnchorPoint = vec2(0, 0)}):Play()

	notifications:fade(outline, false)

	task.spawn(function()
		task.wait(3)

		notifications.notifs[index] = nil

		notifications:fade(outline, true)

		task.wait(3)

		outline:Destroy() 
	end)
end

function library:watermark(options)
	local cfg = {
		name = options.name or "nebulahax";
	}

	-- Instances
	local outline = library:create("Frame", {
		Parent = library.sgui;
		Position = dim2(0, 50, 0, 50); 
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0, 0, 0, 24);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		BackgroundColor3 = rgb(255, 255, 255)
	}); library.watermark_outline = outline; library:draggify(outline);

	local dark = library:create("Frame", {
		Parent = outline;
		BackgroundTransparency = 0.6;
		Position = dim2(0, 2, 0, 2);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -4, 1, -4);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0)
	});

	library:create("UIPadding", {
		PaddingTop = dim(0, 7);
		PaddingBottom = dim(0, 6);
		Parent = dark;
		PaddingRight = dim(0, 7);
		PaddingLeft = dim(0, 4)
	});

	local text_title = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = dark;
		Size = dim2(0, 0, 1, 0);
		Position = dim2(0, 1, 0, -1);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	}); 

	library:create("UIGradient", {
		Color = rgbseq{
			rgbkey(0, themes.preset["1"]), 
			rgbkey(0.5, themes.preset["2"]),
			rgbkey(1, themes.preset["3"]),
		};
		Parent = outline
	});
	--

	function cfg.update_text(text)
		text_title.Text = text
	end

	cfg.update_text(cfg.name)

	return setmetatable(cfg, library)
end 

--local watermark = library:watermark({name = "priv9 - 100 fps - 100 ping"})
local fps = 0
local watermark_delay = tick() 

--[[
run.RenderStepped:Connect(function()
	fps += 1

	if tick() - watermark_delay > 1 then 
		watermark_delay = tick()
		local ping = math.floor(stats.PerformanceStats.Ping:GetValue()) .. "ms"                
		watermark.update_text(string.format("priv9 - fps: %s - ping: %s", fps, ping))
		fps = 0
	end
end)
]]

        --[[
        	local pingTimeSec = game.Players.LocalPlayer:GetNetworkPing()
	local pingTimeMs = pingTimeSec * 1000
	pingLabel.Text = "Ping: " .. tostring(math.floor(pingTimeMs)) .. "ms"

	local realFPS = workspace:GetRealPhysicsFPS()
	fpsLabel.Text = "FPS: " .. tostring(math.floor(realFPS))
        ]]

function library:column(properties)
	self.count += 1
	local base = self

	local cfg = {color = library.gradient.Color.Keypoints[self.count].Value, count = self.count} 

	local scrolling_frame = library:create("ScrollingFrame", {
		ScrollBarImageColor3 = rgb(0, 0, 0);
		Active = true;
		AutomaticCanvasSize = Enum.AutomaticSize.Y;
		ScrollBarThickness = 0;
		Parent = self.page;
		LayoutOrder = -1;
		BackgroundTransparency = 1;
		ScrollBarImageTransparency = 1;
		BorderColor3 = rgb(0, 0, 0);
		BackgroundColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		CanvasSize = dim2(0, 0, 0, 0)
	}); cfg.column = scrolling_frame

	function cfg:destroy()
		self.count -= 1
		scrolling_frame:Destroy()
		table.clear(cfg)
	end

	library:create("UIListLayout", {
		Parent = scrolling_frame;
		Padding = dim(0, 5);
		SortOrder = Enum.SortOrder.LayoutOrder
	});

	return setmetatable(cfg, library)            
end 

function library:multisection(properties)
    local cfg = {
        name = properties.name or "multisection",
        sections = properties.sections or {"tab"},
        size = properties.size or 1,
        autofill = properties.auto_fill or false,
        count = self.count,
        color = self.color,
        tabs = {},
        active_tab = nil
    }

    -- 1. Main Container
    local accent = library:create("Frame", {
        Parent = self.column;
        ClipsDescendants = true;
        BorderColor3 = rgb(0, 0, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color;
        Size = cfg.autofill and dim2(1, 0, cfg.size, 0) or dim2(1, 0, 0, 0);
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3");

    -- Re-adding 2px UICorner
    library:create("UICorner", {
        Parent = accent,
        CornerRadius = dim(0, 2)
    })

    -- 2. Tab Bar (Shifted to Right)
    local tab_holder = library:create("Frame", {
        Parent = accent,
        Size = dim2(1, 0, 0, 18),
        Position = dim2(0, 0, 0, 0), 
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    library:create("UIListLayout", {
        Parent = tab_holder,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right, -- Buttons now on the right
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = dim(0, 0) 
    })

    -- 3. Sliding Bar (Visual Indicator)
    local sliding_bar = library:create("Frame", {
        Parent = tab_holder,
        -- Sized based on buttons
        Size = dim2(1 / #cfg.sections, 0, 0, 1),
        -- Initial position needs to account for Right alignment
        -- If aligned right, the first button is at: 1 - (total_tabs * tab_width)
        Position = dim2(1 - (1 / #cfg.sections * #cfg.sections), 0, 1, -1),
        BackgroundColor3 = self.color,
        BorderSizePixel = 0,
        ZIndex = 5
    }); library:apply_theme(sliding_bar, tostring(self.count), "BackgroundColor3");

    -- 4. Content Container
    local dark = library:create("Frame", {
        Parent = accent;
        BackgroundTransparency = 0.6;
        Position = dim2(0, 2, 0, 19);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -4, 0, 0); 
        BorderSizePixel = 0;
        ClipsDescendants = true; 
        BackgroundColor3 = rgb(0, 0, 0)
    });

    -- Re-adding 2px UICorner to inner box
    library:create("UICorner", {
        Parent = dark,
        CornerRadius = dim(0, 2)
    })

    for i, tab_name in ipairs(cfg.sections) do
        local but = library:create("TextButton", {
            Parent = tab_holder,
            -- Buttons are sized to fit their fraction of the total width
            Size = dim2(1 / #cfg.sections, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tab_name:lower(),
            TextColor3 = (i == 1) and rgb(255, 255, 255) or rgb(155, 155, 155),
            FontFace = fonts["TahomaBold"],
            TextSize = 12,
            AutoButtonColor = false,
            BorderSizePixel = 0
        })

        local content = library:create("Frame", {
            Parent = dark,
            Size = dim2(1, 0, 1, 0), 
            Position = dim2(i == 1 and 0 or 1, 0, 0, 0), 
            BackgroundTransparency = 1,
            Visible = (i == 1),
        })

        local padding_cont = library:create("Frame", {
            Parent = content,
            Size = dim2(1, -10, 0, 0),
            Position = dim2(0, 5, 0, 5),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y
        })

        local layout = library:create("UIListLayout", {
            Parent = padding_cont,
            Padding = dim(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local function update_height()
            if cfg.active_tab == tab_name then
                local content_height = math.ceil(layout.AbsoluteContentSize.Y) + 10
                dark.Size = dim2(1, -4, 0, content_height)
                accent.Size = dim2(1, 0, 0, content_height + 21)
            end
        end

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_height)

        local tab_api = setmetatable({
            elements = padding_cont,
            button = but,
            index = i,
            container = content,
            update_height = update_height,
            column = self.column,
            count = self.count,
            color = self.color
        }, { __index = library })

        cfg.tabs[tab_name] = tab_api

		local tween
		local busy = 0
        but.MouseButton1Click:Connect(function()
            if cfg.active_tab == tab_name then return end
			if busy > 0 then return end
            
            cfg.active_tab = tab_name
            local target_tab = cfg.tabs[tab_name]
            local t_info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            
            local bar_x = 1 - ((#cfg.sections - i + 1) * (1 / #cfg.sections))
            
            tween_service:Create(sliding_bar, t_info, {
                Position = dim2(bar_x, 0, 1, -1)
            }):Play()

			busy += 3

            for _, t in pairs(cfg.tabs) do
                local is_active = (t == target_tab)
                local target_x = (t.index < target_tab.index) and -1 or (t.index > target_tab.index) and 1 or 0
                
                if is_active then t.container.Visible = true end

                tween = tween_service:Create(t.container, t_info, {
                    Position = dim2(target_x, 0, 0, 0)
                })
                tween:Play()
                
                tween.Completed:Connect(function()
                    if not is_active then t.container.Visible = false end
					busy -= 1
                end)

                tween_service:Create(t.button, TweenInfo.new(0.25), {
                    TextColor3 = is_active and rgb(255, 255, 255) or rgb(155, 155, 155)
                }):Play()
            end
            update_height()
        end)

        if i == 1 then cfg.active_tab = tab_name end
    end

    task.spawn(function()
        task.wait()
        if cfg.active_tab and cfg.tabs[cfg.active_tab] then
            cfg.tabs[cfg.active_tab].update_height()
        end
    end)

    function cfg:get_tab(name)
        return cfg.tabs[name]
    end

    return cfg
end

function library:section(properties)            
	local cfg = {
		name = properties.name or properties.Name or "section",
		size = properties.size or 1, 
		autofill = properties.auto_fill or false,
		count = self.count;
		color = self.color;
	}

	-- Instances
	local accent = library:create("Frame", {
		Parent = self.column;
		ClipsDescendants = true;
		BorderColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(fill, tostring(self.count), "BackgroundColor3");

	function cfg.show_element(bool)
		accent.Visible = bool
	end

	function cfg:destroy()
		accent:Destroy()
		table.clear(cfg)
	end

	local dark = library:create("Frame", {
		Parent = accent;
		BackgroundTransparency = 0.6;
		Position = dim2(0, 2, 0, 16);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -4, 1, -18);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0)
	});

	if themes.corners then
		library:create("UICorner", {
			Parent = accent,
			CornerRadius = UDim.new(0, 2)
		})

	end

	local elements = library:create("Frame", {
		Parent = dark;
		Position = dim2(0, 4, 0, 5);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -8, 0, 0);
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	}); cfg.elements = elements

	if cfg.autofill == false then 
		elements.AutomaticSize = Enum.AutomaticSize.Y;
		accent.AutomaticSize = Enum.AutomaticSize.Y;
		accent.Size = dim2(1, 0, 0, 0);

		local UIPadding = library:create("UIPadding", {
			Parent = elements,
			Name = "",
			PaddingBottom = dim(0, 7)
		})
	else 
		accent.Size = dim2(1, 0, cfg.size, 0);
	end

	library:create("UIListLayout", {
		Parent = elements;
		Padding = dim(0, 6);
		SortOrder = Enum.SortOrder.LayoutOrder
	});

	local title = library:create("TextLabel", {
		FontFace = fonts["TahomaBold"];
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = accent;
		Size = dim2(1, 0, 0, 0);
		Position = dim2(0, 4, 0, 1);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.Y;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	function cfg.set_title(self, bool)
		title.Text = bool
	end

	library:create("UIListLayout", {
		Parent = ScrollingFrame;
		Padding = dim(0, 5);
		SortOrder = Enum.SortOrder.LayoutOrder
	});
	--

	return setmetatable(cfg, library)
end 

do
	local layover = Instance.new("ScreenGui")
	local frame = Instance.new("Frame")
	local label = Instance.new("TextLabel")
	local pad = Instance.new("UIPadding")
	local corner = Instance.new("UICorner")

	layover.Name = "layover"
	layover.Parent = gethui()
	layover.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	layover.ResetOnSpawn = false
	layover.DisplayOrder = 100000

	frame.Name = "frame"
	frame.Parent = layover
	frame.BackgroundColor3 = rgb(20, 20, 20)
	frame.BorderColor3 = rgb(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.AutomaticSize = Enum.AutomaticSize.XY

	label.Name = "label"
	label.Parent = frame
	label.BackgroundColor3 = rgb(255, 255, 255)
	label.BackgroundTransparency = 1.000
	label.BorderColor3 = rgb(0, 0, 0)
	label.BorderSizePixel = 0
	label.FontFace = fonts["ProggyClean"]
	label.TextColor3 = rgb(255, 255, 255)
	label.TextSize = 12.000
	label.AutomaticSize = Enum.AutomaticSize.XY

	pad.Name = "pad"
	pad.Parent = frame
	pad.PaddingBottom = UDim.new(0, 7)
	pad.PaddingLeft = UDim.new(0, 7)
	pad.PaddingRight = UDim.new(0, 7)
	pad.PaddingTop = UDim.new(0, 7)

	--corner.CornerRadius = UDim.new(0, 6)
	--corner.Name = "corner"
	--corner.Parent = frame

	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = themes.preset.button_alt
	stroke.LineJoinMode = Enum.LineJoinMode.Miter
	stroke.ZIndex = 11

	local grad = Instance.new("UIGradient", stroke)
	grad.Rotation = 90
	grad.Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))

	for i = 1, 10 do
		local stroke = stroke:Clone()
		stroke.Parent = frame
		stroke.Transparency = i / 10
		stroke.ZIndex -= 1
		stroke.Thickness = 1 + i / 3
		stroke.Color = stroke.Color:Lerp(rgb(), i / 20)
	end

	local grad = Instance.new("UIGradient", label)
	grad.Rotation = 90
	grad.Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))

	frame.Visible = true
	local scale = Instance.new("UIScale", frame)
	scale.Scale = 0.0

	local tween

	local current_position
	label:GetPropertyChangedSignal("TextBounds"):Connect(function()
		if not current_position then return end
		frame.Position = UDim2.new(0, current_position.X - label.TextBounds.X / 2, 0, current_position.Y)
	end)
	show_tooltip = function(enabled, text, pos)
		if tween then tween:Cancel() end
		tween = tween_service:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Scale = enabled and 1.0 or 0.0
		})
		tween:Play()
		label.Text = text
		frame.Position = UDim2.new(0, pos.X - label.TextBounds.X / 2, 0, pos.Y)
		current_position = pos

	end
end


library.animations = {}
function library:create_tween(obj, info, prop)
	if library.animations[obj] then
		library.animations[obj]:Cancel()
		library.animations[obj] = nil
	end

	local tween = tween_service:Create(obj, TweenInfo.new(table.unpack(info)), prop)
	tween:Play()

	if not library.animations[obj] then
		library.animations[obj] = tween
	end
end
-- Elements  

function library:label(options) 
    local cfg = {
        name = options.name or "Label",
        popout = options.popout or false, -- Enabled for sub-items
        wip = options.wip,
        beta = options.beta,
        color = self.color,
    }

    local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"
    local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)

    if is_beta and cfg.beta then
        clr = hex("#e67e22")
    elseif not is_beta and cfg.beta then
        clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2)
    end

    -- Main Container
    local label_element = library:create("Frame", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
    });

    cfg.instance = label_element

    local nameplate = library:create("TextLabel", {
        FontFace = library.font;
        TextColor3 = clr;
        Text = cfg.name;
        Parent = label_element;
        Size = dim2(0, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        TextTransparency = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0,
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
    });

    -- Tooltip logic remains identical
    if options.tip then
        local question = library:create("TextLabel", {
            FontFace = library.font;
            Text = '?';
            Parent = nameplate;
            Size = dim2(0, 0, 1, 0);
            Position = dim2(1, 3, 0, -3);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 8;
            TextColor3 = clr,
        });
        question.MouseEnter:Connect(function() show_tooltip(true, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
        question.MouseLeave:Connect(function() show_tooltip(false, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
    end

    local right_holder = library:create("Frame", {
        Parent = label_element,
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
    })

    library:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        Parent = right_holder;
        Padding = dim(0, 4);
        SortOrder = Enum.SortOrder.LayoutOrder
    });

    -- POPOUT LOGIC (FOR SUB-ITEMS)
    local popout_elements;
    if cfg.popout then
        local gear = library:create("ImageButton", {
            Name = "Gear",
            Parent = right_holder,
            Size = dim2(0, 14, 0, 14),
            Position = dim2(0, 0, -3, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7059346373",
            ImageColor3 = rgb(200, 200, 200),
            LayoutOrder = 1
        })

        popout_elements = library:create("Frame", {
            Name = "PopoutMenu",
            Parent = library.gui,
            BackgroundColor3 = rgb(1, 1, 1),
            BorderColor3 = self.color,
            BorderSizePixel = 1,
            Position = dim2(1, 10, 0, 0),
            Size = dim2(0, 160, 0, 0),
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 100
        })

        local scale = library:create("UIScale", { Parent = popout_elements, Scale = 0.0 })
        library:create("UIListLayout", { Parent = popout_elements, Padding = dim(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder })
        library:create("UICorner", { Parent = popout_elements, CornerRadius = dim(0, 4) })
        local stroke = library:create("UIStroke", { Parent = popout_elements, Color = themes.preset.button_alt, Thickness = 1 })
        library:create("UIPadding", { Parent = popout_elements, PaddingTop = dim(0, 4), PaddingBottom = dim(0, 4), PaddingLeft = dim(0, 4), PaddingRight = dim(0, 4) })

        local visible = false
        local function update_position()
            popout_elements.Position = dim2(0, label_element.AbsolutePosition.X + label_element.AbsoluteSize.X / 2, 0, label_element.AbsolutePosition.Y + label_element.AbsoluteSize.Y * 2 + 60)
        end

        local tween, scale_tween;
        local function animate()
            if tween then tween:Cancel() end
            if scale_tween then scale_tween:Cancel() end
            stroke.Color = visible and themes.preset.button or themes.preset.button_alt
            tween = tween_service:Create(gear, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Rotation = visible and 90 or 0,
                ImageTransparency = visible and 0 or 0.5
            })
            tween:Play()

            scale_tween = tween_service:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
                Scale = visible and 1 or 0
            })
            scale_tween:Play()
        end

        animate()

        gear.MouseButton1Click:Connect(function()
            update_position()
            visible = not visible
            popout_elements.Visible = true
            animate()

            if not visible then return end

            local mouse_con
            mouse_con = uis.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if (not library:mouse_in_frame(popout_elements)) and (not library:mouse_in_frame(gear)) then
                        visible = false
                        mouse_con:Disconnect()
                        animate()
                    end
                end
            end)

            local loop_con;
            loop_con = run.RenderStepped:Connect(function()
                if not visible then loop_con:Disconnect() return end
                update_position()
            end)
        end)
    end

    function cfg:add(element_instance)
        if typeof(element_instance) == "table" then
            element_instance = element_instance.instance
        end
        if popout_elements and element_instance then
            element_instance.Parent = popout_elements
        end
        return element_instance
    end

    function cfg:set_text(val)
        nameplate.Text = val
    end

    return setmetatable(cfg, library)
end

function library:toggle(options) 
    local cfg = {
        enabled = options.enabled or nil,
        name = options.name or "Toggle",
        flag = options.flag or tostring(math.random(1,9999999)),
        default = options.default or false,
        popout = options.popout or false,
        wip = options.wip,
        beta = options.beta,
        callback = options.callback or function() end,
        color = self.color,
        count = self.count,
    }

    local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"
    local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)

    if is_beta and cfg.beta then
        clr = hex("#e67e22")
    elseif not is_beta and cfg.beta then
        clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2)
    end

    -- Main Container
    local toggle = library:create("TextButton", {
        Parent = self.elements;
        BackgroundTransparency = 1;
        Text = "";
        Size = dim2(1, 0, 0, 12);
        BorderSizePixel = 0;
    });

	cfg.instance = toggle

    local nameplate = library:create("TextLabel", {
        FontFace = library.font;
        TextColor3 = clr;
        Text = cfg.name;
        Parent = toggle;
        Size = dim2(0, 0, 1, 0);
        Position = dim2(0, 1, 0, -1);
        BackgroundTransparency = 1;
        TextXAlignment = Enum.TextXAlignment.Left;
        BorderSizePixel = 0;
        TextTransparency = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0,
        AutomaticSize = Enum.AutomaticSize.X;
        TextSize = 12;
    });

    -- Tooltip Logic
    if options.tip then
        local question = library:create("TextLabel", {
            FontFace = library.font;
            Text = '?';
            Parent = nameplate;
            Size = dim2(0, 0, 1, 0);
            Position = dim2(1, 3, 0, -3);
            BackgroundTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 8;
            TextColor3 = clr,
        });
        question.MouseEnter:Connect(function() show_tooltip(true, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
        question.MouseLeave:Connect(function() show_tooltip(false, options.tip, question.AbsolutePosition - vec2(0, 30)) end)
    end

    local right_holder = library:create("Frame", {
        Parent = toggle,
        Size = dim2(1, 0, 1, 0),
        BackgroundTransparency = 1,
    })

    library:create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        Parent = right_holder;
        Padding = dim(0, 4);
        SortOrder = Enum.SortOrder.LayoutOrder
    });

    -- THE GEARBOX & POPOUT
    local popout_elements;
    if cfg.popout then
        local gear = library:create("ImageButton", {
            Name = "Gear",
            Parent = right_holder,
            Size = dim2(0, 14, 0, 14),
            Position = dim2(0, 0, -3, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7059346373",
            ImageColor3 = rgb(200, 200, 200),
            LayoutOrder = 1
        })

        popout_elements = library:create("Frame", {
            Name = "PopoutMenu",
            Parent = library.gui,
            BackgroundColor3 = rgb(1, 1, 1),
            BorderColor3 = self.color,
            BorderSizePixel = 1,
            Position = dim2(1, 10, 0, 0),
            Size = dim2(0, 160, 0, 0),
            Visible = false,
            AutomaticSize = Enum.AutomaticSize.Y,
            ZIndex = 100
        })

        local scale = library:create("UIScale", { Parent = popout_elements, Scale = 0.0 })
        library:create("UIListLayout", { Parent = popout_elements, Padding = dim(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder })
        library:create("UICorner", { Parent = popout_elements, CornerRadius = dim(0, 4) })
        local stroke = library:create("UIStroke", { Parent = popout_elements, Color = themes.preset.button_alt, Thickness = 1 })
        library:create("UIPadding", { Parent = popout_elements, PaddingTop = dim(0, 4), PaddingBottom = dim(0, 4), PaddingLeft = dim(0, 4), PaddingRight = dim(0, 4) })

        local visible = false
        local function update_position()
            popout_elements.Position = dim2(0, toggle.AbsolutePosition.X + toggle.AbsoluteSize.X / 2, 0, toggle.AbsolutePosition.Y + toggle.AbsoluteSize.Y * 2 + 60)
        end

		local tween, scale_tween;
        local function animate()
			if tween then tween:Cancel() end
			if scale_tween then scale_tween:Cancel() end
			stroke.Color = visible and themes.preset.button or themes.preset.button_alt
            tween = tween_service:Create(gear, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Rotation = visible and 90 or 0,
                ImageTransparency = visible and 0 or 0.5
            })
            tween:Play()

            scale_tween = tween_service:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
                Scale = visible and 1 or 0
            })
            scale_tween:Play()
        end

		animate()

        local mouse_con
        gear.MouseButton1Click:Connect(function()
            update_position()
            visible = not visible
            popout_elements.Visible = true
            animate()

            if not visible then 
                if mouse_con then mouse_con:Disconnect() end
                return 
            end

            mouse_con = uis.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if (not library:mouse_in_frame(popout_elements)) and (not library:mouse_in_frame(gear)) then
                        visible = false
                        mouse_con:Disconnect()
                        animate()
                    end
                end
            end)

            local loop_con;
            loop_con = run.RenderStepped:Connect(function()
                if not visible then loop_con:Disconnect() return end
				if not library.gui_visible then loop_con:Disconnect() visible = false mouse_con:Disconnect() animate() return end
                update_position()
            end)
        end)
    end

	--print(options.name)
	--print(self.count)
    -- THE CHECKBOX
    local accent = library:create("Frame", {
        Parent = right_holder;
        Size = dim2(0, 12, 0, 12);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color,
        LayoutOrder = 2
    }); library:apply_theme(accent, tostring(self.count), "BackgroundColor3");     

    local fill = library:create("Frame", {
        Parent = accent;
        Position = dim2(0, 1, 0, 1);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = self.color;
		ClipsDescendants = true;
    }); library:apply_theme(fill, tostring(self.count), "BackgroundColor3");  

    local c = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0.0
    library:create("UIGradient", {
        Parent = fill, Rotation = 90,
        Transparency = NumberSequence.new(math.lerp(c, 0, 0.25), c),
        Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155), rgb(155, 155, 155), rgb(177, 177, 177), rgb(55, 55, 55))
    })

    -- Functionality
    function cfg.set(bool)       
        if cfg.wip or (cfg.beta and not is_beta) then return end           
        local backgroundColor3 = bool and themes.preset.button or themes.preset.inline
		fill:SetAttribute("buttonPrimary", bool)
        fill.BackgroundColor3 = backgroundColor3
        fill.BackgroundTransparency = bool and 0 or 1
        flags[cfg.flag] = bool
        cfg.enabled = bool
        cfg.callback(bool)
    end 

    function cfg.show_element(bool)
        toggle.Visible = bool
    end

    function cfg.set_value(bool)
        cfg.set(bool)
    end

    toggle.MouseButton1Click:Connect(function()
        cfg.set(not cfg.enabled)
    end)

    -- MANUAL PARENTING METHOD
    function cfg:add(element_instance)
		if typeof(element_instance) == "table" then
			element_instance = element_instance.instance
		end
        if popout_elements and element_instance then
            element_instance.Parent = popout_elements
        end
    end

	library.config_flags[cfg.flag] = cfg.set_value

    cfg.set(cfg.default)
    return setmetatable(cfg, library) -- NO SETMETATABLE (Prevents Cyclic Error)
end

function library:list(options)
	local cfg = {
		callback = options and options.callback or function() end, 
		name = options.name or nil, 

		scale = options.size or 90, 
		items = options.items or {"1", "2", "3"}, 
		-- order = options.order or 1, 
		visible = options.visible or true,

		option_instances = {}, 
		current_instance = nil, 
		flag = options.flag or "SET A FLAG U n", 
	}

	-- Elements
	local accent = library:create("Frame", {
		BorderColor3 = rgb(0, 0, 0);
		AnchorPoint = vec2(1, 0);
		Parent = self.elements;
		Position = dim2(1, 0, 0, 0);
		Size = dim2(1, 0, 0, cfg.scale);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundColor3 = self.color
	}); library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

	function cfg:destroy()
		accent:Destroy()
		table.clear(cfg)
	end

	function cfg.show_element(bool)
		accent.Visible = bool
	end

	local inline = library:create("Frame", {
		Parent = accent;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BackgroundColor3 = rgb(),
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(inline, "inline", "BackgroundColor3")

	local scrollingframe = library:create("ScrollingFrame", {
		ScrollBarImageColor3 = rgb(0, 0, 0);
		Active = true;
		AutomaticCanvasSize = Enum.AutomaticSize.Y;
		ScrollBarThickness = 0;
		Parent = inline;
		Size = dim2(1, 0, 1, 0);
		LayoutOrder = -1;
		BackgroundTransparency = 1;
		ScrollBarImageTransparency = 1;
		BorderColor3 = rgb(0, 0, 0);
		BackgroundColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		CanvasSize = dim2(0, 0, 0, 0)
	});

	library:create("UIGradient", {
		Parent = inline;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(188, 188, 188))
	})

	library:create("UIListLayout", {
		Parent = scrollingframe;
		Padding = dim(0, 6);
		SortOrder = Enum.SortOrder.LayoutOrder
	});

	library:create("UIPadding", {
		PaddingTop = dim(0, 2);
		PaddingBottom = dim(0, 4);
		Parent = scrollingframe;
		PaddingRight = dim(0, 5);
		PaddingLeft = dim(0, 5)
	});
	-- 

	-- Functions
	function cfg.render_option(text) 
		local text = library:create("TextButton", {
			FontFace = library.font;
			TextColor3 = rgb(170, 170, 170);
			BorderColor3 = rgb(0, 0, 0);
			Text = text;
			AutoButtonColor = false;
			BackgroundTransparency = 1;
			Parent = scrollingframe;
			BorderSizePixel = 0;
			Size = dim2(1, 0, 0, 0);
			AutomaticSize = Enum.AutomaticSize.Y;
			TextSize = 12;
			TextXAlignment = Enum.TextXAlignment.Left;
			BackgroundColor3 = rgb(255, 255, 255)
		}); 

		return text 
	end 

	function cfg.refresh_options(options)
		for _, v in cfg.option_instances do 
			v:Destroy() 
		end 

		for _, option in next, options do 
			local button = cfg.render_option(option) 

			insert(cfg.option_instances, button)

			button.MouseButton1Click:Connect(function()
				if cfg.current_instance and cfg.current_instance ~= button then 
					cfg.current_instance.TextColor3 = rgb(170, 170, 170)
				end 

				cfg.current_instance = button
				button.TextColor3 = rgb(255, 255, 255) 

				flags[cfg.flag] = button.text

				cfg.callback(button.text)
			end)
		end 
	end

	function cfg.filter_options(text)
		for _, v in next, cfg.option_instances do 
			if string.find(v.Text, text) then 
				v.Visible = true 
			else 
				v.Visible = false
			end
		end
	end

	function cfg.set(value)
		for _, buttons in next, cfg.option_instances do 
			if buttons.Text == value then 
				buttons.TextColor3 = rgb(255, 255, 255) 
			else 
				buttons.TextColor3 = rgb(170, 170, 170)
			end 
		end 

		flags[cfg.flag] = value
		cfg.callback(value)
	end 

	cfg.refresh_options(cfg.items) 
	-- 

	return setmetatable(cfg, library)
end     

function library:slider(options) 
	local cfg = {
		name = options.name or nil,
		suffix = options.suffix or "",
		flag = options.flag or tostring(2^789),
		callback = options.callback or function() end, 

		min = options.min or options.minimum or 0,
		max = options.max or options.maximum or 100,
		intervals = options.interval or options.decimal or 1,
		default = options.default or 10,
		value = options.default or 10, 

		ignore = options.ignore or false, 
		dragging = false,
	} 

	local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"

	local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)

	local is_active = is_beta and options.beta

	if is_beta and options.beta then
		clr = hex("#e67e22")
	elseif not is_beta and options.beta then
		clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2)
	end

	-- Instances 
	local slider = library:create("Frame", {
		Parent = self.elements;
		BackgroundTransparency = 1;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 25);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});
	
	cfg.instance = slider

	function cfg.show_element(bool)
		slider.Visible = bool
	end

	function cfg:destroy()
		slider:Destroy()
		table.clear(cfg)
	end

	local eeeee = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		RichText = true;
		BorderColor3 = rgb(0, 0, 0);
		Text = "max distance : 5000";
		Parent = slider;
		TextColor3 = clr,
		Size = dim2(1, 0, 0, 0);
		Position = dim2(0, 1, 0, -2);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.XY;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	local outline = library:create("TextButton", {
		Parent = slider;
		Text = "";
		AutoButtonColor = false;
		Position = dim2(0, 0, 0, 13);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 12);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(outline, tostring(self.count), "BackgroundColor3")

	local slider_color = themes.preset.button
	if is_beta and options.beta then
		slider_color = hex("#e67e22")
	elseif not is_beta and options.beta then
		slider_color = hex("#e67e22"):lerp(rgb(0, 0, 0), .2)
	end

	local inline = library:create("Frame", {
		Parent = outline;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(outline, "inline", "BackgroundColor3")

	library:create("UIGradient", {
		Parent = inline;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(222, 222, 222))
	})


	local accent = library:create("Frame", {
		Parent = inline;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0.5, 0, 1, 0);
		BorderSizePixel = 0;
		BackgroundColor3 = slider_color
	}); --library:apply_theme(accent, tostring(self.count), "BackgroundColor3")
	accent:SetAttribute("buttonPrimary", true)

	library:create("UIGradient", {
		Parent = accent;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))
	})

	if themes.corners then
		library:create("UICorner", {
			Parent = outline,
			CornerRadius = UDim.new(0, 2)
		})

		library:create("UICorner", {
			Parent = inline,
			CornerRadius = UDim.new(0, 2)
		})

		library:create("UICorner", {
			Parent = accent,
			CornerRadius = UDim.new(0, 2)
		})

		library:create("UICorner", {
			Parent = slider,
			CornerRadius = UDim.new(0, 2)
		})
	end


	-- 

	-- Functions 
	function cfg.set(value)
		local valuee = tonumber(value)

		if valuee == nil then 
			return 
		end 

		cfg.value = clamp(library:round(valuee, cfg.intervals), cfg.min, cfg.max)

		accent.Size = dim2((cfg.value - cfg.min) / (cfg.max - cfg.min), 0, 1, 0)
		eeeee.Text = cfg.name ..  "<font color='#AAAAAA'>" .. ' - ' .. tostring(cfg.value) .. cfg.suffix .. "</font>"

		flags[cfg.flag] = cfg.value

		cfg.callback(flags[cfg.flag])
	end 

	cfg.set(cfg.default)
	-- 

	-- Connections
	outline.MouseButton1Down:Connect(function()
		cfg.dragging = true 
	end)

	library:connection(uis.InputChanged, function(input)
		if cfg.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then 
			local size_x = (input.Position.X - inline.AbsolutePosition.X) / inline.AbsoluteSize.X
			local value = ((cfg.max - cfg.min) * size_x) + cfg.min

			cfg.set(value)
		end
	end)

	library:connection(uis.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			cfg.dragging = false 
		end 
	end)
	-- 

	cfg.set(cfg.default)

	config_flags[cfg.flag] = cfg.set

	return setmetatable(cfg, library)
end 

function library:dropdown(options) 
	local cfg = {
		name = options.name or nil,
		flag = options.flag or tostring(random(1,9999999)),
		items = options.items or {""},
		callback = options.callback or function() end,
		multi = options.multi or false, 
		scrolling = true, 

		-- Ignore these 
		open = false, 
		option_instances = {}, 
		multi_items = {}, 
		ignore = options.ignore or false, 
	}   

	options.scrolling = true

	cfg.default = options.default or (cfg.multi and {cfg.items[1]}) or cfg.items[1] or "None"

	flags[cfg.flag] = {} 

	-- Instances
	-- Element 
	local dropdown = library:create("Frame", {
		Parent = self.elements;
		BackgroundTransparency = 1;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 16);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	cfg.instance = dropdown

	function cfg.show_element(bool)
		dropdown.Visible = bool
	end

	function cfg:destroy()
		dropdown:Destroy()
		table.clear(cfg)
	end

	local dropdown_holder = library:create("TextButton", {
		AnchorPoint = vec2(1, 0);
		AutoButtonColor = false; 
		Text = "";
		BackgroundColor3 = rgb();
		Parent = dropdown;
		Position = dim2(1, 0, 0, 0);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0.5, 0, 0, 16);
		BorderSizePixel = 0;
		--BackgroundColor3 = self.color
	}); library:apply_theme(dropdown_holder, tostring(self.count), "BackgroundColor3")

	local inline = library:create("Frame", {
		Parent = dropdown_holder;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	});

	local is_beta = seraphAcc.role == "contributor" or seraphAcc.role == "beta"

	local clr = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255)

	local is_active = is_beta and options.beta

	if is_beta and options.beta then
		clr = hex("#e67e22")
	elseif not is_beta and options.beta then
		clr = hex("#e67e22"):lerp(rgb(0, 0, 0), .2)
	end

	local text = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = clr,
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = inline;
		Size = dim2(1, 0, 1, 0);
		BackgroundTransparency = 1;
		Position = dim2(0, 0, 0, 1);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});


	local title = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = clr,
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = dropdown;
		Size = dim2(1, 0, 1, 0);
		Position = dim2(0, 1, 0, 0);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Parent = inline;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))
	})


	if themes.corners then
		library:create("UICorner", {
			Parent = inline,
			CornerRadius = UDim.new(0, 2)
		})

		library:create("UICorner", {
			Parent = dropdown_holder,
			CornerRadius = UDim.new(0, 2)
		})
	end

	-- 

	-- Holder
	local accent = library:create("Frame", {
		Parent = library.gui;
		Size = dim2(0.0907348021864891, 0, 0.006218905560672283, 20);
		Position = dim2(0, 500, 0, 100);
		BorderColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		Visible = false;
		AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundColor3 = self.color,
		ZIndex = 50000
	});	library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

	local inline_overlay = library:create("Frame", {
		Parent = accent;
		Size = dim2(1, -2, 1, -2);
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		Active = false,
		BackgroundColor3 = themes.preset.inline,
		ZIndex = 50005
	});	library:apply_theme(inline_overlay, "inline", "BackgroundColor3")

	library:create("UIGradient", {
		Parent = inline_overlay;
		Rotation = 90,
		Transparency = numseq({numkey(0, 1), numkey(0.7, 1), numkey(1, 0.5)}),
		Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))
	})

	local maxInlineSize = 200
	local inline = library:create(cfg.scrolling and "ScrollingFrame" or "Frame", {
		Parent = accent;
		Size = dim2(1, -2, 1, -2);
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		AutomaticSize = cfg.scrolling and Enum.AutomaticSize.None or Enum.AutomaticSize.Y;
		BackgroundColor3 = themes.preset.inline,
		ZIndex = 50000
	});	library:apply_theme(inline, "inline", "BackgroundColor3")

	library:create("UIGradient", {
		Parent = inline;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))
	})

	library:create("UIListLayout", {
		Parent = inline;
		Padding = dim(0, 6);
		SortOrder = Enum.SortOrder.LayoutOrder
	});

	library:create("UIPadding", {
		PaddingTop = dim(0, 5);
		PaddingBottom = dim(0, 2);
		Parent = inline;
		PaddingRight = dim(0, 6);
		PaddingLeft = dim(0, 6)
	});

	local padding = library:create("UIPadding", {
		PaddingBottom = dim(0, 2);
		Parent = accent
	});
	--  
	-- 

	-- Functions

	local currentSize = 0
	function cfg.render_option(text) 
		local title = library:create("TextButton", {
			FontFace = library.font;
			AutoButtonColor = false;
			TextColor3 = clr;
			BorderColor3 = rgb(0, 0, 0);
			Text = string.lower(text);
			Parent = inline;
			Size = dim2(1, 0, 0, 0);
			Position = dim2(0, 0, 0, 1);
			BackgroundTransparency = 1;
			TextXAlignment = Enum.TextXAlignment.Left;
			BackgroundColor3 = rgb(),
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.Y;
			TextSize = 12;
		});

		if cfg.scrolling then
			currentSize += title.AbsoluteSize.Y + 6
			inline.Size = UDim2.new(1, -2, 0, clamp(currentSize, 0, maxInlineSize) + title.AbsoluteSize.Y / 2)
			inline.CanvasSize = UDim2.new(0, 0, 0, currentSize + title.AbsoluteSize.Y)
			inline.ScrollBarThickness = 1
		end

		inline_overlay.Size = inline.Size

		title.Name = text

		return title
	end 

	function cfg.set_visible(bool) 
		accent.Visible = bool
		local currentSize = 0
		for i, title in next, cfg.option_instances do 
			currentSize += title.AbsoluteSize.Y + 6
			inline.Size = UDim2.new(1, -2, 0, clamp(currentSize, 0, maxInlineSize) + title.AbsoluteSize.Y / 2)
			inline.CanvasSize = UDim2.new(0, 0, 0, currentSize + title.AbsoluteSize.Y)
			inline.ScrollBarThickness = 1
		end
	end

	function cfg.set(value)
		local selected = {}
		local isTable = type(value) == "table"

		if value == nil then 
			return 
		end

		for _, option in next, cfg.option_instances do 
			if option.Name == value or (isTable and find(value, option.Name)) then 
				insert(selected, option.Name)
				cfg.multi_items = selected
				option.TextColor3 = clr
			else
				option.TextColor3 = clr:Lerp(rgb(), .23)
			end
		end

		inline_overlay.Size = inline.Size

		text.Text = if isTable then concat(selected, ", ") else selected[1]
		text.Text = string.lower(text.Text)
		text.TextTruncate = Enum.TextTruncate.AtEnd

		flags[cfg.flag] = if isTable then selected else selected[1]

		cfg.callback(flags[cfg.flag]) 
	end

	function cfg.refresh_options(list) 
		for _, option in next, cfg.option_instances do 
			option:Destroy() 
		end

		cfg.option_instances = {} 

		for _, option in next, list do 
			local button = cfg.render_option(option)

			insert(cfg.option_instances, button)

			button.MouseButton1Down:Connect(function()
				if cfg.multi then 
					local selected_index = find(cfg.multi_items, button.Name)

					if selected_index then 
						remove(cfg.multi_items, selected_index)
					else
						insert(cfg.multi_items, button.Name)
					end

					cfg.set(cfg.multi_items) 				
				else 
					cfg.set_visible(false)
					cfg.open = false 

					cfg.set(button.Name)
				end
			end)
		end
	end

	cfg.refresh_options(cfg.items)

	cfg.set(cfg.default)

	config_flags[cfg.flag] = cfg.set
	-- 

	-- Connections 
	dropdown_holder.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open 

		local currentSize = 0
		for i, title in next, cfg.option_instances do 
			currentSize += title.AbsoluteSize.Y + 6 * i
			inline.Size = UDim2.new(1, -2, 0, clamp(currentSize, 0, maxInlineSize) + title.AbsoluteSize.Y)
			inline.CanvasSize = UDim2.new(0, 0, 0, currentSize + title.AbsoluteSize.Y)
			inline.ScrollBarThickness = 1
		end
		accent.Size = dim2(0, dropdown_holder.AbsoluteSize.X, 0, accent.Size.Y.Offset)
		accent.Position = dim2(0, dropdown_holder.AbsolutePosition.X, 0, dropdown_holder.AbsolutePosition.Y + 77)

		cfg.set_visible(cfg.open)
	end)

	local inputEndedFunc = function(input)
		if not cfg.open then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not (library:mouse_in_frame(accent) or library:mouse_in_frame(dropdown)) then 
				cfg.open = false
				cfg.set_visible(false)
			end
		end
	end
	local inputEndedSig = uis.InputEnded:Connect(inputEndedFunc)
	inputEndedSig:Disconnect()
	-- 

	library.guiVisibilityChanged:Connect(function()
		cfg.set_visible(false)
		if library.gui_visible then inputEndedSig = uis.InputEnded:Connect(inputEndedFunc) else inputEndedSig:Disconnect() inputEndedSig = nil end
	end)

	return setmetatable(cfg, library)
end 

function library:colorpicker(options) 
	local cfg = {
		name = options.name or "Color", 
		flag = options.flag or tostring(2^789),

		color = options.color or color(1, 1, 1), -- Default to white color if not provided
		alpha = options.alpha and 1 - options.alpha or 0,

		open = false, 
		callback = options.callback or function() end,
	}

	-- Instances
	-- Element
	local colorpicker_element = library:create("TextButton", {
		Parent = self.elements;
		BackgroundTransparency = 1;
		Text = "";
		AutoButtonColor = false;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 12);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	cfg.instance = colorpicker_element

	function cfg:destroy()
		colorpicker_element:Destroy()
		table.clear(cfg)
	end

	local accent = library:create("Frame", {
		AnchorPoint = vec2(1, 0);
		Parent = colorpicker_element;
		Position = dim2(1, 0, 0, 0);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0, 30, 0, 12);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

	local colorpicker_element_color = library:create("Frame", {
		Parent = accent;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Parent = colorpicker_element_color;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))
	})


	if themes.corners then
		library:create("UICorner", {
			Parent = colorpicker_element_color,
			CornerRadius = UDim.new(0, 2)
		})

		library:create("UICorner", {
			Parent = accent,
			CornerRadius = UDim.new(0, 2)
		})
	end

	library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = colorpicker_element;
		Size = dim2(1, 0, 1, 0);
		Position = dim2(0, 1, 0, 0);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	-- 

	-- Elements
	local colorpicker = library:create("Frame", {
		Parent = library.gui;
		ZIndex = 50000,
		Position = dim2(0.6888179183006287, 0, 0.24751244485378265, 0);
		BorderColor3 = rgb(0, 0, 0);
		Visible = false;
		Size = dim2(0, 150, 0, 150);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	});	library:apply_theme(colorpicker, tostring(self.count), "BackgroundColor3")

	library:create("UICorner", {
		Parent = colorpicker;
		CornerRadius = UDim.new(0, 2)
	});

	local a = library:create("Frame", {
		Parent = colorpicker;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 1, 0);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(a, tostring(self.count), "BackgroundColor3")

	local e = library:create("Frame", {
		Parent = a;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0);
		BackgroundTransparency = 0.6;
		ZIndex = -1
	}); 

	local _ = library:create("UIPadding", {
		PaddingTop = dim(0, 7);
		PaddingBottom = dim(0, -13);
		Parent = e;
		PaddingRight = dim(0, 6);
		PaddingLeft = dim(0, 7)
	});

	local textbox_holder = library:create("Frame", {
		Parent = e;
		Position = dim2(0, 0, 1, -36);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -1, 0, 16);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(textbox_holder, tostring(self.count), "BackgroundColor3")

	local textbox = library:create("TextBox", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = "";
		Parent = textbox_holder;
		BackgroundTransparency = 0;
		ClearTextOnFocus = false;
		PlaceholderColor3 = rgb(255, 255, 255);
		Size = dim2(1, -2, 1, -2);
		Position = dim2(0, 1, 0, 1);
		BorderSizePixel = 0;
		TextSize = 12;
		TextXAlignment = Enum.TextXAlignment.Center;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(textbox, "inline", "BackgroundColor3")

	local hue_button = library:create("TextButton", {
		AnchorPoint = vec2(1, 0);
		Text = "";
		AutoButtonColor = false;
		Parent = e;
		Position = dim2(1, -1, 0, 0);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0, 14, 1, -60);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(hue_button, "inline", "BackgroundColor3")

	local hue_drag = library:create("Frame", {
		Parent = hue_button;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Rotation = -90;
		Parent = hue_drag;
		Color = rgbseq{rgbkey(0, rgb(255, 0, 0)), rgbkey(0.17, rgb(255, 255, 0)), rgbkey(0.33, rgb(0, 255, 0)), rgbkey(0.5, rgb(0, 255, 255)), rgbkey(0.67, rgb(0, 0, 255)), rgbkey(0.83, rgb(255, 0, 255)), rgbkey(1, rgb(255, 0, 0))}
	});

	local hue_picker = library:create("Frame", {
		Parent = hue_drag;
		BorderMode = Enum.BorderMode.Inset;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 2, 0, 3);
		Position = dim2(0, -1, 0, -1);
		BackgroundColor3 = rgb(255, 255, 255)
	});

	local alpha_button = library:create("TextButton", {
		AnchorPoint = vec2(0, 0.5);
		Text = "";
		AutoButtonColor = false;
		Parent = e;
		Position = dim2(0, 0, 1, -48);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -1, 0, 14);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(alpha_button, "inline", "BackgroundColor3")

	local alpha_color = library:create("Frame", {
		Parent = alpha_button;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 221, 255)
	});

	local alphaind = library:create("ImageLabel", {
		ScaleType = Enum.ScaleType.Tile;
		BorderColor3 = rgb(0, 0, 0);
		Parent = alpha_color;
		Image = "rbxassetid://18274452449";
		BackgroundTransparency = 1;
		Size = dim2(1, 0, 1, 0);
		TileSize = dim2(0, 4, 0, 4);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Parent = alphaind;
		Rotation = 180;
		Transparency = numseq{numkey(0, 0), numkey(1, 1)}
	});

	local alpha_picker = library:create("Frame", {
		Parent = alpha_color;
		BorderMode = Enum.BorderMode.Inset;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0, 3, 1, 2);
		Position = dim2(0, -1, 0, -1);
		BackgroundColor3 = rgb(255, 255, 255)
	});

	local saturation_value_button = library:create("TextButton", {
		Parent = e;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -20, 1, -60);
		Text = "";
		AutoButtonColor = false;
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(saturation_value_button, "inline", "BackgroundColor3")

	local colorpicker_color = library:create("Frame", {
		Parent = saturation_value_button;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 221, 255)
	});

	local val = library:create("TextButton", {
		Parent = colorpicker_color;
		Text = "";
		AutoButtonColor = false;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 1, 0);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Parent = val;
		Transparency = numseq{numkey(0, 0), numkey(1, 1)}
	});

	local saturation_value_picker = library:create("Frame", {
		Parent = colorpicker_color;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0, 3, 0, 3);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(0, 0, 0)
	});

	local inline = library:create("Frame", {
		Parent = saturation_value_picker;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	local saturation_button = library:create("TextButton", {
		Parent = colorpicker_color;
		Text = "";
		AutoButtonColor = false;
		Size = dim2(1, 0, 1, 0);
		BorderColor3 = rgb(0, 0, 0);
		ZIndex = 2;
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	library:create("UIGradient", {
		Rotation = 270;
		Transparency = numseq{numkey(0, 0), numkey(1, 1)};
		Parent = saturation_button;
		Color = rgbseq{rgbkey(0, rgb(0, 0, 0)), rgbkey(1, rgb(0, 0, 0))}
	});


	-- 
	-- 

	-- Functions 
	local dragging_sat = false 
	local dragging_hue = false 
	local dragging_alpha = false 

	local h, s, v = cfg.color:ToHSV() 
	local a = cfg.alpha 

	flags[cfg.flag] = {} 

	function cfg.set_visible(bool) 
		colorpicker.Visible = bool

		colorpicker.Position = dim_offset(colorpicker_element_color.AbsolutePosition.X - 1, colorpicker_element_color.AbsolutePosition.Y + colorpicker_element_color.AbsoluteSize.Y + 65)
	end

	function cfg.show_element(bool)
		colorpicker_element.Visible = bool
	end

	function cfg.set(color, alpha)
		if color then
			h, s, v = color:ToHSV()
		end

		if alpha then 
			a = alpha
		end 

		local Color = Color3.fromHSV(h, s, v)

		hue_picker.Position = dim2(0, -1, 1 - h, -1)
		alpha_picker.Position = dim2(1 - a, -1, 0, -1)
		saturation_value_picker.Position = dim2(s, -1, 1 - v, -1)

		--element_alpha.ImageTransparency = 1 - a

		alpha_color.BackgroundColor3 = Color
		colorpicker_element_color.BackgroundColor3 = Color
		colorpicker_color.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

		flags[cfg.flag] = {
			Color = Color;
			Transparency = a 
		}

		local color = colorpicker_element_color.BackgroundColor3
		textbox.Text = string.format("%s, %s, %s, ", library:round(color.R * 255), library:round(color.G * 255), library:round(color.B * 255))
		textbox.Text ..= library:round(1 - a, 0.01)

		cfg.callback(Color, a)
	end

	function cfg.update_color() 
		local mouse = uis:GetMouseLocation() 
		local offset = vec2(mouse.X, mouse.Y - gui_offset) 

		if dragging_sat then	
			s = math.clamp((offset - saturation_value_button.AbsolutePosition).X / saturation_value_button.AbsoluteSize.X, 0, 1)
			v = 1 - math.clamp((offset - saturation_value_button.AbsolutePosition).Y / saturation_value_button.AbsoluteSize.Y, 0, 1)
		elseif dragging_hue then
			h = 1 - math.clamp((offset - hue_button.AbsolutePosition).Y / hue_button.AbsoluteSize.Y, 0, 1)
		elseif dragging_alpha then
			a = 1 - math.clamp((offset - alpha_button.AbsolutePosition).X / alpha_button.AbsoluteSize.X, 0, 1)
		end

		cfg.set(nil, nil)
	end

	cfg.set(cfg.color, cfg.alpha)

	config_flags[cfg.flag] = cfg.set
	-- 

	-- Connections 
	colorpicker_element.MouseButton1Click:Connect(function()
		cfg.open = not cfg.open 

		cfg.set_visible(cfg.open)            
	end)

	uis.InputChanged:Connect(function(input)
		if (dragging_sat or dragging_hue or dragging_alpha) and input.UserInputType == Enum.UserInputType.MouseMovement then
			cfg.update_color() 
		end
	end)

	library:connection(uis.InputEnded, function(input)
		if not cfg.open then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging_sat = false
			dragging_hue = false
			dragging_alpha = false  

			if not (library:mouse_in_frame(colorpicker_element) or library:mouse_in_frame(colorpicker)) then 
				cfg.open = false
				cfg.set_visible(false)
			end
		end
	end)

	alpha_button.MouseButton1Down:Connect(function()
		dragging_alpha = true 
	end)

	hue_button.MouseButton1Down:Connect(function()
		dragging_hue = true 
	end)

	saturation_button.MouseButton1Down:Connect(function()
		dragging_sat = true  
	end)

	textbox.FocusLost:Connect(function()
		local s, hex = pcall(hex, textbox.Text)
		if hex and s then
			local r, g, b = floor(hex.R * 255), floor(hex.G * 255), floor(hex.B * 255)
			cfg.set(rgb(r, g, b), cfg.alpha)
			return
		end

		local r, g, b, a = library:convert(textbox.Text)

		if not a then
			a = 1
		end

		if r and g and b and a then 
			cfg.set(rgb(r, g, b), 1 - a)
		end 
	end)

	library.guiVisibilityChanged:Connect(function()
		cfg.set_visible(false)
	end)
	-- 

	return setmetatable(cfg, library)
end

function library:textbox(options) 
	local cfg = {
		name = options.name or "...",
		placeholder = options.placeholder or options.placeholdertext or options.holder or options.holdertext or "type here...",
		default = options.default,
		flag = options.flag or "SET ME rawr",
		callback = options.callback or function() end,
		visible = options.visible or true,
	}

	-- Instances 
	local frame = library:create("TextButton", {
		AnchorPoint = vec2(1, 0);
		Text = "";
		AutoButtonColor = false;
		Parent = self.elements;
		Position = dim2(1, 0, 0, 0);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 16);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	});

	local frame_inline = library:create("Frame", {
		Parent = frame;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	});

	local input = library:create("TextBox", {
		Parent = frame,
		Name = "",
		FontFace = library.font,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = 12,
		Size = dim2(1, -6, 1, 0),
		RichText = true,
		TextColor3 = rgb(255, 255, 255),
		BorderColor3 = rgb(0, 0, 0),
		CursorPosition = -1,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = dim2(0, 6, 0, 0),
		BorderSizePixel = 0,
		PlaceholderColor3 = rgb(170, 170, 170),
	})
	-- 

	-- Functions
	function cfg:destroy()
		frame:Destroy()
		table.clear(cfg)
	end

	function cfg.set(text) 
		flags[cfg.flag] = text

		input.Text = text

		cfg.callback(text)
	end 

	config_flags[cfg.flag] = cfg.set

	if cfg.default then 
		cfg.set(cfg.default) 
	end
	--

	-- Connections 
	input:GetPropertyChangedSignal("Text"):Connect(function()
		cfg.set(input.Text) 
	end)
	-- 

	return setmetatable(cfg, library)
end 

local keybinds = {}
function library:keybind(options) 
	local cfg = {
		flag = options.flag or "SET ME A FLAG NOWWW!!!!",
		callback = options.callback or function() end,
		open = false,
		binding = nil, 
		name = options.name or nil, 
		ignore_key = options.ignore or false, 

		key = options.key or nil, 
		display = options.display or nil,
		mode = options.mode or "hold",
		active = options.default or false,
		text = Drawing.new("Text"),

		hold_instances = {},
	}

	insert(keybinds, cfg)

	flags[cfg.flag] = {} 

	-- Instances
	-- Element 
	local keybind = library:create("Frame", {
		Parent = self.elements;
		BackgroundTransparency = 1;
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 16);
		BorderSizePixel = 0;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	cfg.instance = keybind

	function cfg:destroy()
		keybind:Destroy()
		table.clear(cfg)
	end

	function cfg.show_element(bool)
		keybind.Visible = bool
	end

	local keybind_holder = library:create("TextButton", {
		AnchorPoint = vec2(1, 0);
		AutoButtonColor = false; 
		Text = "";
		Parent = keybind;
		BackgroundTransparency = 1;
		Position = dim2(1, 0, 0, 0);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(0.5, 0, 0, 16);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

	local inline = library:create("Frame", {
		Parent = keybind_holder;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		BackgroundTransparency = 1;
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	});

	library:create("UIGradient", {
		Parent = inline;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(155, 155, 155))
	})

	local text = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = inline;
		Size = dim2(1, 0, 1, 0);
		BackgroundTransparency = 1;
		Position = dim2(0, 0, 0, -1);
		TextColor3 = rgb(221, 221, 221),
		BorderSizePixel = 0;
		TextXAlignment = Enum.TextXAlignment.Right;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 10;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	local title = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = keybind;
		Size = dim2(0, 0, 1, 0);
		Position = dim2(0, 1, 0, 0);
		BackgroundTransparency = 1;
		TextXAlignment = Enum.TextXAlignment.Left;
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextColor3 = options.unsafe and rgb(210, 215, 192) or rgb(255, 255, 255),
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});

	if options.tip then
		--87959697501504
		local question = library:create("TextLabel", {
			FontFace = library.font;
			TextColor3 = title.TextColor3;
			BorderColor3 = rgb(0, 0, 0);
			Text = '?';
			Parent = title;
			Size = dim2(0, 0, 1, 0);
			Position = dim2(1, 3, 0, -3);
			BackgroundTransparency = 1;
			TextXAlignment = Enum.TextXAlignment.Left;
			BorderSizePixel = 0;
			TextTransparency = (options.wip or (not is_beta and cfg.beta)) and 0.5 or 0,
			AutomaticSize = Enum.AutomaticSize.X;
			TextSize = 8;
			BackgroundColor3 =rgb(255, 255, 255)
		});
		question.MouseEnter:Connect(function()
			show_tooltip(true, options.tip, question.AbsolutePosition - vec2(0, 30))
		end)
		question.MouseLeave:Connect(function()
			show_tooltip(false, options.tip, question.AbsolutePosition - vec2(0, 30))
		end)
	end
	-- 

	-- Holder
	local accent = library:create("Frame", {
		Parent = library.gui;
		Visible = false;
		Size = dim2(0.0907348021864891, 0, 0.006218905560672283, 20);
		Position = dim2(0, 500, 0, 100);
		BorderColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundColor3 = self.color;
		ZIndex = 50000
	});	library:apply_theme(accent, tostring(self.count), "BackgroundColor3")

	local inline = library:create("Frame", {
		Parent = accent;
		Size = dim2(1, -2, 1, -2);
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.Y;
		BackgroundColor3 = themes.preset.inline;
		ZIndex = 50000
	});	library:apply_theme(inline, "inline", "BackgroundColor3")

	library:create("UIListLayout", {
		Parent = inline;
		Padding = dim(0, 6);
		SortOrder = Enum.SortOrder.LayoutOrder
	});

	library:create("UIPadding", {
		PaddingTop = dim(0, 5);
		PaddingBottom = dim(0, 2);
		Parent = inline;
		PaddingRight = dim(0, 6);
		PaddingLeft = dim(0, 6)
	});

	local padding = library:create("UIPadding", {
		PaddingBottom = dim(0, 2);
		Parent = accent
	});

	local options = {"Hold", "Toggle", "Always"}

	for _, v in options do
		local option = library:create("TextButton", {
			FontFace = library.font;
			TextColor3 = rgb(170, 170, 170);
			BorderColor3 = rgb(0, 0, 0);
			Text = v;
			Parent = inline;
			Position = dim2(0, 0, 0, 1);
			BackgroundTransparency = 1;
			TextXAlignment = Enum.TextXAlignment.Left;
			BorderSizePixel = 0;
			AutomaticSize = Enum.AutomaticSize.XY;
			TextSize = 12;
			BackgroundColor3 = rgb(255, 255, 255)
		}); cfg.hold_instances[v] = option

		option.MouseButton1Click:Connect(function()
			cfg.set(v)

			cfg.set_visible(false)

			cfg.open = false
		end)
	end
	--  
	--

	-- Functions 
	function cfg.modify_mode_color(path) -- ts so frikin tuff ðŸ’€
		for _, v in cfg.hold_instances do 
			v.TextColor3 = rgb(170, 170, 170)
		end

		if cfg.hold_instances[path] then 
			cfg.hold_instances[path].TextColor3 = rgb(255, 255, 255)
		end
	end 

	function cfg.set_mode(mode) 
		cfg.mode = mode 

		if mode == "Always" then
			cfg.set(true)
		elseif mode == "Hold" then
			cfg.set(false)
		end

		flags[cfg.flag]["mode"] = mode
		cfg.modify_mode_color(mode)
	end 

	function cfg.set(input)
		if type(input) == "boolean" then 
			local __cached = input 

			if cfg.mode == "Always" then 
				__cached = true 
			end 

			cfg.active = __cached 
			cfg.callback(__cached)
		elseif tostring(input):find("Enum") then 
			input = input.Name == "Escape" and "..." or input

			cfg.key = input or "..."	

			cfg.callback(cfg.active or false)
		elseif find({"Toggle", "Hold", "Always"}, input) then 
			cfg.set_mode(input)

			if input == "Always" then 
				cfg.active = true 
			end 

			cfg.callback(cfg.active or false)
		elseif type(input) == "table" then 
			input.key = type(input.key) == "string" and input.key ~= "..." and library:convert_enum(input.key) or input.key

			input.key = input.key == Enum.KeyCode.Escape and "..." or input.key
			cfg.key = input.key or "..."

			cfg.mode = input.mode or "Toggle"
			cfg.set_mode(input.mode)

			if input.active then
				cfg.active = input.active
			end
		end 

		flags[cfg.flag] = {
			mode = cfg.mode,
			key = cfg.key, 
			active = cfg.active
		}

		local _text = tostring(cfg.key) ~= "Enums" and (keys[cfg.key] or tostring(cfg.key):gsub("Enum.", "")) or nil
		local __text = _text and (tostring(_text):gsub("KeyCode.", ""):gsub("UserInputType.", ""))

		text.Text = "[".. __text .."]"

		-- if keybind_list_text then
		--     keybind_list_text.Text = "[ ".. __text  .." ] ".. cfg.name ..":".. string.lower(cfg.mode) .."";
		--     keybind_list_text.Visible = cfg.active
		-- end
	end

	function cfg.set_visible(bool)
		accent.Visible = bool

		accent.Size = dim2(0, keybind_holder.AbsoluteSize.X, 0, accent.Size.Y.Offset)
		accent.Position = dim2(0, keybind_holder.AbsolutePosition.X, 0, keybind_holder.AbsolutePosition.Y + 77)
	end
	-- 

	-- Connections
	keybind_holder.MouseButton1Down:Connect(function()
		task.wait()
		text.Text = "[-]"	

		cfg.binding = library:connection(uis.InputBegan, function(input, game_event)  
			cfg.set((input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType))

			cfg.binding:Disconnect() 
			cfg.binding = nil
		end)
	end)

	keybind_holder.MouseButton2Down:Connect(function()
		cfg.open = not cfg.open 

		cfg.set_visible(cfg.open) 
	end)

	library:connection(uis.InputBegan, function(input, game_event) 
		if not game_event then 
			if input.KeyCode == cfg.key then 
				if cfg.mode == "Toggle" then 
					cfg.active = not cfg.active
					cfg.set(cfg.active)
				elseif cfg.mode == "Hold" then 
					cfg.set(true)
				end
			elseif input.UserInputType == cfg.key then
				if cfg.mode == "Toggle" then 
					cfg.active = not cfg.active
					cfg.set(cfg.active)
				elseif cfg.mode == "Hold" then 
					cfg.set(true)
				end
			end
		end
	end)

	library:connection(uis.InputEnded, function(input, game_event) 
		if game_event then 
			return 
		end 

		local selected_key = input.UserInputType == Enum.UserInputType.Keyboard and (input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType)

		if input.KeyCode == cfg.key or input.UserInputType == cfg.key then
			if cfg.mode == "Hold" then 
				cfg.set(false)
			end
		end

		if library.gui_visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not (library:mouse_in_frame(keybind_holder) or library:mouse_in_frame(accent)) then 
				cfg.open = false
				cfg.set_visible(false)
			end
		end
	end)

	config_flags[cfg.flag] = cfg.set
	cfg.set({mode = cfg.mode, active = cfg.active, key = cfg.key})
	cfg.set_mode(cfg.mode)

	library.guiVisibilityChanged:Connect(function()
		cfg.set_visible(false)
	end)

	return setmetatable(cfg, library)
end

function library:button(options) 
	local cfg = {
		name = options.name or "button",
		callback = options.callback or function() end,
	}

	-- Instances 
	local frame = library:create("TextButton", {
		AnchorPoint = vec2(1, 0);
		Text = "";
		AutoButtonColor = false;
		Parent = self.elements;
		Position = dim2(1, 0, 0, 0);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, 0, 0, 16);
		BorderSizePixel = 0;
		BackgroundColor3 = self.color
	}); library:apply_theme(frame, tostring(self.count), "BackgroundColor3")

	local frame_inline = library:create("Frame", {
		Parent = frame;
		Position = dim2(0, 1, 0, 1);
		BorderColor3 = rgb(0, 0, 0);
		Size = dim2(1, -2, 1, -2);
		BorderSizePixel = 0;
		BackgroundColor3 = themes.preset.inline
	}); library:apply_theme(frame_inline, "inline", "BackgroundColor3")


	library:create("UIGradient", {
		Parent = frame_inline;
		Rotation = 90,
		Color = rgbseq(rgb(255, 255, 255), rgb(188, 188, 188))
	})

	if themes.corners then
		library:create("UICorner", {
			Parent = frame_inline,
			CornerRadius = UDim.new(0, 2)
		})

		library:create("UICorner", {
			Parent = frame,
			CornerRadius = UDim.new(0, 2)
		})
	end

	local text = library:create("TextLabel", {
		FontFace = library.font;
		TextColor3 = rgb(255, 255, 255);
		BorderColor3 = rgb(0, 0, 0);
		Text = cfg.name;
		Parent = frame;
		Size = dim2(1, 0, 1, 0);
		BackgroundTransparency = 1;
		Position = dim2(0, 1, 0, 1);
		BorderSizePixel = 0;
		AutomaticSize = Enum.AutomaticSize.X;
		TextSize = 12;
		BackgroundColor3 = rgb(255, 255, 255)
	});
	-- 

	-- Connections 
	frame.MouseButton1Click:Connect(function()
		cfg.callback()
	end)
	--

	function cfg:destroy()
		frame:Destroy()
		table.clear(cfg)
	end

	return setmetatable(cfg, library)
end 
-- 
-- 
-- 

local function rgbstr(rgb)
	local values = {}

	values.r = floor(rgb.r * 255)
	values.g = floor(rgb.g * 255)
	values.b = floor(rgb.b * 255)

	return `rgb({values.r},{values.g},{values.b})`
end


local function setup(obj, prop)
	for k, v in prop do
		obj[k] = v
	end
	return obj
end

local function applyMatrix(v, M)
	return Vector3.new(
		v.X * M.R00 + v.Y * M.R01 + v.Z * M.R02,
		v.X * M.R10 + v.Y * M.R11 + v.Z * M.R12,
		v.X * M.R20 + v.Y * M.R21 + v.Z * M.R22
	)
end

local function worldToScreenPoint(point)
	local cam = workspace.CurrentCamera
	local dp = cam.CFrame:PointToObjectSpace(typeof(point) == 'CFrame' and point.Position or (typeof(point) == 'Instance' and point.Position or point))
	local distorted = dp, applyMatrix(dp, globalStretch)
	local worldDistorted = cam.CFrame:PointToWorldSpace(distorted)
	local vector, onScreen = cam:WorldToViewportPoint(worldDistorted)

	return Vector2.new(vector.X, vector.Y), onScreen
end


local services = setmetatable({}, {
	__index = function(self, t)
		return game:GetService(t:gsub("^%l", string.upper))
	end,
})


pcall(game.Destroy, services.coreGui:FindFirstChild("PRIV9CHAMS"))
pcall(game.Destroy,  lighting:FindFirstChild("\233"))

local sky = Instance.new("Sky")
sky.Name = "\233"
sky.StarCount = 0
sky.MoonTextureId, sky.SunTextureId = '', ''
local skyboxes = {
	blank = {
		SkyboxBk = 'http://www.roblox.com/asset/?ID=1361097',
		SkyboxDn = 'http://www.roblox.com/asset/?ID=1361097',
		SkyboxFt = 'http://www.roblox.com/asset/?ID=1361097',
		SkyboxLf = 'http://www.roblox.com/asset/?ID=1361097',
		SkyboxRt = 'http://www.roblox.com/asset/?ID=1361097',
		SkyboxUp = 'http://www.roblox.com/asset/?ID=1361097',
		MoonTextureId = '',
		SunTextureId = '',
		StarCount = 0,
		SunAngularSize = 1
	},
	["red night sky"] = {
		SkyboxBk = 'http://www.roblox.com/Asset/?ID=401664839',
		SkyboxDn = 'http://www.roblox.com/asset/?ID=401664862',
		SkyboxFt = 'http://www.roblox.com/asset/?ID=401664960',
		SkyboxLf = 'http://www.roblox.com/asset/?ID=401664881',
		SkyboxRt = 'http://www.roblox.com/asset/?ID=401664901',
		SkyboxUp = 'http://www.roblox.com/asset/?ID=401664936',
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["purple galaxy"] = {
		SkyboxBk = 'http://www.roblox.com/Asset/?ID=14543264135',
		SkyboxDn = 'http://www.roblox.com/asset/?ID=14543358958',
		SkyboxFt = 'http://www.roblox.com/asset/?ID=14543257810',
		SkyboxLf = 'http://www.roblox.com/asset/?ID=14543275895',
		SkyboxRt = 'http://www.roblox.com/asset/?ID=14543280890',
		SkyboxUp = 'http://www.roblox.com/asset/?ID=14543371676',
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
		["purple clouds"] = {
		SkyboxLf = "rbxassetid://151165191",
		SkyboxBk = "rbxassetid://151165214",
		SkyboxDn = "rbxassetid://151165197",
		SkyboxFt = "rbxassetid://151165224",
		SkyboxRt = "rbxassetid://151165206",
		SkyboxUp = "rbxassetid://151165227",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["cloudy skies"] = {
		SkyboxLf = "rbxassetid://151165191",
		SkyboxBk = "rbxassetid://151165214",
		SkyboxDn = "rbxassetid://151165197",
		SkyboxFt = "rbxassetid://151165224",
		SkyboxRt = "rbxassetid://151165206",
		SkyboxUp = "rbxassetid://151165227",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["purple nebula"] = {
		SkyboxLf = "rbxassetid://159454286",
		SkyboxBk = "rbxassetid://159454299",
		SkyboxDn = "rbxassetid://159454296",
		SkyboxFt = "rbxassetid://159454293",
		SkyboxRt = "rbxassetid://159454300",
		SkyboxUp = "rbxassetid://159454288",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["purple and blue"] = {
		SkyboxLf = "rbxassetid://149397684",
		SkyboxBk = "rbxassetid://149397692",
		SkyboxDn = "rbxassetid://149397686",
		SkyboxFt = "rbxassetid://149397697",
		SkyboxRt = "rbxassetid://149397688",
		SkyboxUp = "rbxassetid://149397702",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["vivid Skies"] = {
		SkyboxLf = "rbxassetid://271042310",
		SkyboxBk = "rbxassetid://271042516",
		SkyboxDn = "rbxassetid://271077243",
		SkyboxFt = "rbxassetid://271042556",
		SkyboxRt = "rbxassetid://271042467",
		SkyboxUp = "rbxassetid://271077958",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["twighlight"] = {
		SkyboxLf = "rbxassetid://264909758",
		SkyboxBk = "rbxassetid://264908339",
		SkyboxDn = "rbxassetid://264907909",
		SkyboxFt = "rbxassetid://264909420",
		SkyboxRt = "rbxassetid://264908886",
		SkyboxUp = "rbxassetid://264907379",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["vaporwave"] = {
		SkyboxLf = "rbxassetid://1417494402",
		SkyboxBk = "rbxassetid://1417494030",
		SkyboxDn = "rbxassetid://1417494146",
		SkyboxFt = "rbxassetid://1417494253",
		SkyboxLf = "rbxassetid://1417494402",
		SkyboxRt = "rbxassetid://1417494499",
		SkyboxUp = "rbxassetid://1417494643",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["clouds"] = {
		SkyboxLf = "rbxassetid://570557620",
		SkyboxBk = "rbxassetid://570557514",
		SkyboxDn = "rbxassetid://570557775",
		SkyboxFt = "rbxassetid://570557559",
		SkyboxLf = "rbxassetid://570557620",
		SkyboxRt = "rbxassetid://570557672",
		SkyboxUp = "rbxassetid://570557727",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["night sky"] = {
		SkyboxBk = "rbxassetid://12064107",
		SkyboxDn = "rbxassetid://12064152",
		SkyboxFt = "rbxassetid://12064121",
		SkyboxLf = "rbxassetid://12063984",
		SkyboxRt = "rbxassetid://12064115",
		SkyboxUp = "rbxassetid://12064131",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["setting sun"] = {
		SkyboxBk = "rbxassetid://626460377",
		SkyboxDn = "rbxassetid://626460216",
		SkyboxFt = "rbxassetid://626460513",
		SkyboxLf = "rbxassetid://626473032",
		SkyboxRt = "rbxassetid://626458639",
		SkyboxUp = "rbxassetid://626460625",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["fade blue"] = {
		SkyboxBk = "rbxassetid://153695414",
		SkyboxDn = "rbxassetid://153695352",
		SkyboxFt = "rbxassetid://153695452",
		SkyboxLf = "rbxassetid://153695320",
		SkyboxRt = "rbxassetid://153695383",
		SkyboxUp = "rbxassetid://153695471",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["elegant morning"] = {
		SkyboxBk = "rbxassetid://153767241",
		SkyboxDn = "rbxassetid://153767216",
		SkyboxFt = "rbxassetid://153767266",
		SkyboxLf = "rbxassetid://153767200",
		SkyboxRt = "rbxassetid://153767231",
		SkyboxUp = "rbxassetid://153767288",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["neptune"] = {
		SkyboxBk = "rbxassetid://218955819",
		SkyboxDn = "rbxassetid://218953419",
		SkyboxFt = "rbxassetid://218954524",
		SkyboxLf = "rbxassetid://218958493",
		SkyboxRt = "rbxassetid://218957134",
		SkyboxUp = "rbxassetid://218950090",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["redshift"] = {
		SkyboxBk = "rbxassetid://401664839",
		SkyboxDn = "rbxassetid://401664862",
		SkyboxFt = "rbxassetid://401664960",
		SkyboxLf = "rbxassetid://401664881",
		SkyboxRt = "rbxassetid://401664901",
		SkyboxUp = "rbxassetid://401664936",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	},
	["aesthetic night"] = {
		SkyboxBk = "rbxassetid://1045964490",
		SkyboxDn = "rbxassetid://1045964368",
		SkyboxFt = "rbxassetid://1045964655",
		SkyboxLf = "rbxassetid://1045964655",
		SkyboxRt = "rbxassetid://1045964655",
		SkyboxUp = "rbxassetid://1045962969",
		MoonTextureId = 'rbxasset://sky/moon.jpg',
		SunTextureId = 'rbxasset://sky/sun.jpg',
		SunAngularSize = 21,
		StarCount = 1000
	}
}
sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt, sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = 'http://www.roblox.com/asset/?ID=1361097', 'http://www.roblox.com/asset/?ID=1361097', 'http://www.roblox.com/asset/?ID=1361097', 'http://www.roblox.com/asset/?ID=1361097', 'http://www.roblox.com/asset/?ID=1361097', 'http://www.roblox.com/asset/?ID=1361097'
local chamsContainer = Instance.new("ScreenGui", services.coreGui) chamsContainer.Name = "PRIV9CHAMS"
cons[#cons + 1] = players.PlayerRemoving:Connect(function(plr)
	if chamsContainer:FindFirstChild(plr.Name) then
		chamsContainer:FindFirstChild(plr.Name):Destroy()
	end
end)
local viewport = Instance.new("ViewportFrame") viewport.Size = UDim2.new(1,0,1,0) viewport.BackgroundTransparency = 1 viewport.CurrentCamera = camera viewport.Parent = library.gui
local tearParts, materialParts = {}, {}


function upperString(t)
	return t:gsub("^%l", string.upper)
end

local cf, angles, thread = CFrame.new, CFrame.Angles, task.spawn
local params = RaycastParams.new()
params.RespectCanCollide = false

local globals = {
	frametime = 0
}


local notifications = {}
function createNotification(info)
	local notif = Instance.new("Frame")
	notif.Name = "notif"
	notif.Position = UDim2.new(1, -5, 1, -5)
	notif.Size = UDim2.new(0, 500, 0, 23)
	notif.BackgroundColor3 = Color3.new(0.129412, 0.129412, 0.129412)
	notif.BorderSizePixel = 0
	notif.BorderColor3 = Color3.new(0, 0, 0)
	notif.AnchorPoint = Vector2.new(1, 1)
	notif.Parent = library.gui

	local holder = Instance.new("Frame")
	holder.Name = "holder"
	holder.Position = UDim2.new(0.5, 0, 0.5, 0)
	holder.Size = UDim2.new(1, -5, 1, -5)
	holder.BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647)
	holder.BorderSizePixel = 0
	holder.BorderColor3 = Color3.new(0, 0, 0)
	holder.AnchorPoint = Vector2.new(0.5, 0.5)
	holder.Parent = notif

	local textContainer = Instance.new("Frame")
	textContainer.Name = "textContainer"
	textContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
	textContainer.Size = UDim2.new(1, -5, 1, -5)
	textContainer.BackgroundColor3 = Color3.new(0.0705882, 0.0705882, 0.0705882)
	textContainer.BackgroundTransparency = 1
	textContainer.BorderSizePixel = 0
	textContainer.BorderColor3 = Color3.new(0, 0, 0)
	textContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	textContainer.Transparency = 1
	textContainer.Parent = holder

	local start = Instance.new("TextLabel")
	start.Name = "start"
	start.Size = UDim2.new(0, 0, 0, 11)
	start.BackgroundColor3 = Color3.new(1, 1, 1)
	start.BackgroundTransparency = 1
	start.BorderSizePixel = 0
	start.BorderColor3 = Color3.new(0, 0, 0)
	start.AutomaticSize = Enum.AutomaticSize.X
	start.Text = "seraph.wtf"
	start.TextColor3 = themes.preset.button_alt
	start.TextSize = 14
	start.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	start.Parent = textContainer

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Name = "UIListLayout"
	UIListLayout.Padding = UDim.new(0, 5)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = textContainer

	local sub = Instance.new("TextLabel")
	sub.Name = "sub"
	sub.Size = UDim2.new(0, 0, 0, 11)
	sub.BackgroundColor3 = Color3.new(1, 1, 1)
	sub.BackgroundTransparency = 1
	sub.BorderSizePixel = 0
	sub.BorderColor3 = Color3.new(0, 0, 0)
	sub.AutomaticSize = Enum.AutomaticSize.X
	sub.Text = "|"
	sub.TextColor3 = Color3.new(1, 1, 1)
	sub.TextSize = 14
	sub.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	sub.Parent = textContainer

	local real = Instance.new("TextLabel")
	real.Name = "real"
	real.Size = UDim2.new(0, 0, 0, 11)
	real.BackgroundColor3 = Color3.new(1, 1, 1)
	real.BackgroundTransparency = 1
	real.BorderSizePixel = 0
	real.BorderColor3 = Color3.new(0, 0, 0)
	real.AutomaticSize = Enum.AutomaticSize.X
	real.Text = "welcome to seraph.wtf!"
	real.TextColor3 = Color3.new(1, 1, 1)
	real.TextSize = 14
	real.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	real.Parent = textContainer

	local border = Instance.new("UIStroke")
	border.Name = "border"
	border.Transparency = 0.800000011920929
	border.Parent = holder

	local border2 = Instance.new("UIStroke")
	border2.Name = "border"
	border2.Color = Color3.new(0.129412, 0.129412, 0.129412)
	border2.LineJoinMode = Enum.LineJoinMode.Miter
	border2.Parent = notif

	local border3 = Instance.new("UIStroke")
	border3.Name = "border"
	border3.Color = Color3.new(0.143126, 0.143126, 0.143126)
	border3.Thickness = 1.5
	border3.LineJoinMode = Enum.LineJoinMode.Miter
	border3.Parent = notif

	local border4 = Instance.new("UIStroke")
	border4.Name = "border"
	border4.Color = Color3.new(0.153327, 0.153327, 0.153327)
	border4.Thickness = 2
	border4.LineJoinMode = Enum.LineJoinMode.Miter
	border4.Parent = notif

	local border5 = Instance.new("UIStroke")
	border5.Name = "border"
	border5.Color = Color3.new(0.163528, 0.163528, 0.163528)
	border5.Thickness = 2.5
	border5.LineJoinMode = Enum.LineJoinMode.Miter
	border5.Parent = notif

	local border6 = Instance.new("UIStroke")
	border6.Name = "border"
	border6.Color = Color3.new(0.173728, 0.173728, 0.173728)
	border6.Thickness = 3
	border6.LineJoinMode = Enum.LineJoinMode.Miter
	border6.Parent = notif

	local border7 = Instance.new("UIStroke")
	border7.Name = "border"
	border7.Color = Color3.new(0.183929, 0.183929, 0.183929)
	border7.Thickness = 3.5
	border7.LineJoinMode = Enum.LineJoinMode.Miter
	border7.Parent = notif

	local border8 = Instance.new("UIStroke")
	border8.Name = "border"
	border8.Color = Color3.new(0.19413, 0.19413, 0.19413)
	border8.Thickness = 4
	border8.LineJoinMode = Enum.LineJoinMode.Miter
	border8.Parent = notif

	local border9 = Instance.new("UIStroke")
	border9.Name = "border"
	border9.Color = Color3.new(0.204331, 0.204331, 0.204331)
	border9.Thickness = 4.5
	border9.LineJoinMode = Enum.LineJoinMode.Miter
	border9.Parent = notif

	local loading = Instance.new("Frame")
	loading.Name = "loading"
	loading.Size = UDim2.new(1, 0, 0, 1)
	loading.BackgroundColor3 = themes.preset.button_alt
	loading.BorderSizePixel = 0
	loading.BorderColor3 = Color3.new(0, 0, 0)
	loading.Parent = notif

	local gradient = Instance.new("UIGradient")
	gradient.Name = "gradient"
	gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(0.419608, 0.419608, 0.419608))})
	gradient.Rotation = 90
	gradient.Parent = loading

	local border10 = Instance.new("UIStroke")
	border10.Name = "border"
	border10.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	border10.Transparency = 0.8

	border10.Parent = loading

	local scale = Instance.new("UIScale")
	scale.Name = "scale"

	scale.Parent = notif

	task.spawn(function()
		if not info.time then
			info.time = math.clamp((#info.text / 4) / 2, 5, 50)
		end
		info.text ..= "   "
		for i = 1, #info.text do
			real.Text = string.sub(info.text, 1, i)
			start.TextColor3 = themes.preset.button_alt
			if i % 4 == 0 then
				services.runService.RenderStepped:Wait()
			end
		end
	end)

	if flags.notifSound then
		local sound = Instance.new("Sound")
		sound.SoundId = math.random() > .5 and sfx.bubble2 or sfx.bubble
		sound.Name = ""
		sound.Volume = 1
		sound.PlaybackSpeed = 1
		sound.PlayOnRemove = true
		sound.Parent = coregui
		task.defer(game.Destroy, sound)
	end

	task.defer(function()
		notif.Size = UDim2.new(0,0,0,23)

		scale.Parent = notif
		scale.Scale = 0.0


		insert(notifications, {
			time = info.time or 5,
			totalTime = info.time or info.duration or 5,
			notif = notif
		})
	end)
end

local function checkfile(dir, src)
	if not isfile(dir) then
		writefile(dir, game:HttpGetAsync(src))
	end
end

local function correctAlpha(t, dt_)
	return 1 - (1 - t) ^ (dt_ * 60)
end

local function getTimeString()
	local t=os.date"*t"
	local h=t.hour%12; if h==0 then h=12 end
	return ("%02d:%02d:%02d %s"):format(h,t.min,t.sec, t.hour>=12 and "PM" or "AM")
end

local currentText = "v0.2.4-git.9f8dca0"
if string.match(currentText, "replaceThisVersion") then
	currentText = "development"
end

--[[
do
	local frame = Instance.new("Frame")
	frame.Name = "frame"
	frame.Position = UDim2.new(0, 50, 0, 50)
	frame.Size = UDim2.new(0, 0, 0, 25)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 0.10000000149011612
	frame.BorderSizePixel = 0
	frame.BorderColor3 = Color3.new(0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Transparency = 0.10000000149011612
	frame.Parent = library.gui

	local UICorner = Instance.new("UICorner")
	UICorner.Name = "UICorner"

	UICorner.Parent = frame

	local icon = Instance.new("ImageLabel")
	icon.Name = "icon"
	icon.Size = UDim2.new(0, 25, 0, 25)
	icon.BackgroundColor3 = Color3.new(1, 1, 1)
	icon.BackgroundTransparency = 1
	icon.BorderSizePixel = 0
	icon.BorderColor3 = Color3.new(0, 0, 0)
	icon.Transparency = 1
	icon.Image = "rbxassetid://101942723117519"
	icon.Parent = frame

	local icon2 = Instance.new("ImageLabel")
	icon2.Name = "icon"
	icon2.Size = UDim2.new(0, 26, 0, 26)
	icon2.BackgroundColor3 = Color3.new(0.592157, 0.490196, 0.839216)
	icon2.BackgroundTransparency = 1
	icon2.BorderSizePixel = 0
	icon2.BorderColor3 = Color3.new(0, 0, 0)
	icon2.Transparency = 1
	icon2.Image = "rbxassetid://101942723117519"
	icon2.ImageColor3 = Color3.new(0.592157, 0.490196, 0.839216)
	icon2.ImageTransparency = 0.5
	icon2.Parent = icon

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Name = "UIStroke"
	UIStroke.Thickness = 2
	UIStroke.Parent = frame

	local UIStroke2 = Instance.new("UIStroke")
	UIStroke2.Name = "UIStroke"
	UIStroke2.Thickness = 2.5
	UIStroke2.Transparency = 0.25
	UIStroke2.Parent = frame

	local UIStroke3 = Instance.new("UIStroke")
	UIStroke3.Name = "UIStroke"
	UIStroke3.Thickness = 3
	UIStroke3.Transparency = 0.5
	UIStroke3.Parent = frame

	local UIStroke4 = Instance.new("UIStroke")
	UIStroke4.Name = "UIStroke"
	UIStroke4.Thickness = 4
	UIStroke4.Transparency = 0.75
	UIStroke4.Parent = frame

	local UIStroke5 = Instance.new("UIStroke")
	UIStroke5.Name = "UIStroke"
	UIStroke5.Thickness = 5
	UIStroke5.Transparency = 0.9900000095367432
	UIStroke5.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "title"
	title.Size = UDim2.new(0, 0, 0, 25)
	title.BackgroundColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.BorderColor3 = Color3.new(0, 0, 0)
	title.AutomaticSize = Enum.AutomaticSize.X
	title.LayoutOrder = 1
	title.Text = "seraph"
	title.TextColor3 = Color3.new(0.956863, 0.956863, 0.956863)
	title.TextSize = 16
	title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	title.TextWrapped = true
	title.Parent = frame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Name = "UIListLayout"
	UIListLayout.Padding = UDim.new(0, 6)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = frame

	local version = Instance.new("TextLabel")
	version.Name = "version"
	version.Size = UDim2.new(0, 0, 0, 25)
	version.BackgroundColor3 = Color3.new(1, 1, 1)
	version.BackgroundTransparency = 1
	version.BorderSizePixel = 0
	version.BorderColor3 = Color3.new(0, 0, 0)
	version.AutomaticSize = Enum.AutomaticSize.X
	version.LayoutOrder = 4
	version.Text = currentText
	version.TextColor3 = Color3.new(0.956863, 0.956863, 0.956863)
	version.TextSize = 16
	version.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	version.TextWrapped = true
	version.Parent = frame


	local splitter = Instance.new("Frame")
	splitter.Name = "splitter"
	splitter.Size = UDim2.new(0, 10, 0, 1)
	splitter.BackgroundColor3 = Color3.new(1, 1, 1)
	splitter.BorderSizePixel = 0
	splitter.BorderColor3 = Color3.new(0, 0, 0)
	splitter.LayoutOrder = 2
	splitter.Parent = frame

	local UIGradient3 = Instance.new("UIGradient")
	UIGradient3.Name = "UIGradient"
	UIGradient3.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(0.501247, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)})
	UIGradient3.Parent = splitter

	local splitter2 = Instance.new("Frame")
	splitter2.Name = "splitter"
	splitter2.Size = UDim2.new(0, 10, 0, 1)
	splitter2.BackgroundColor3 = Color3.new(1, 1, 1)
	splitter2.BorderSizePixel = 0
	splitter2.BorderColor3 = Color3.new(0, 0, 0)
	splitter2.LayoutOrder = 5
	splitter2.Parent = frame

	local UIGradient4 = Instance.new("UIGradient")
	UIGradient4.Name = "UIGradient"
	UIGradient4.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(0.501247, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)})
	UIGradient4.Parent = splitter2

	local time = Instance.new("TextLabel")
	time.Name = "time"
	time.Size = UDim2.new(0, 0, 0, 25)
	time.BackgroundColor3 = Color3.new(1, 1, 1)
	time.BackgroundTransparency = 1
	time.BorderSizePixel = 0
	time.BorderColor3 = Color3.new(0, 0, 0)
	time.AutomaticSize = Enum.AutomaticSize.X
	time.LayoutOrder = 11
	time.Text = "4:32 am"
	time.TextColor3 = Color3.new(0.956863, 0.956863, 0.956863)
	time.TextSize = 16
	time.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	time.TextWrapped = true
	time.Parent = frame

	local vers = Instance.new("ImageLabel")
	vers.Name = "vers"
	vers.Size = UDim2.new(0, 25, 0, 25)
	vers.BackgroundColor3 = Color3.new(1, 1, 1)
	vers.BackgroundTransparency = 1
	vers.BorderSizePixel = 0
	vers.BorderColor3 = Color3.new(0, 0, 0)
	vers.Visible = false
	vers.LayoutOrder = 3
	vers.Transparency = 1
	vers.Image = "rbxassetid://91840508165296"
	vers.Parent = frame

	local frames = Instance.new("ImageLabel")
	frames.Name = "frames"
	frames.Size = UDim2.new(0, 25, 0, 25)
	frames.BackgroundColor3 = Color3.new(1, 1, 1)
	frames.BackgroundTransparency = 1
	frames.BorderSizePixel = 0
	frames.BorderColor3 = Color3.new(0, 0, 0)
	frames.Visible = false
	frames.LayoutOrder = 6
	frames.Transparency = 1
	frames.Image = "rbxassetid://12684119225"
	frames.Parent = frame

	local fps = Instance.new("TextLabel")
	fps.Name = "fps"
	fps.Size = UDim2.new(0, 0, 0, 25)
	fps.BackgroundColor3 = Color3.new(1, 1, 1)
	fps.BackgroundTransparency = 1
	fps.BorderSizePixel = 0
	fps.BorderColor3 = Color3.new(0, 0, 0)
	fps.AutomaticSize = Enum.AutomaticSize.X
	fps.LayoutOrder = 7
	fps.Text = "0 fps"
	fps.TextColor3 = Color3.new(0.956863, 0.956863, 0.956863)
	fps.TextSize = 16
	fps.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	fps.TextWrapped = true
	fps.Parent = frame


	local splitter3 = Instance.new("Frame")
	splitter3.Name = "splitter"
	splitter3.Size = UDim2.new(0, 10, 0, 1)
	splitter3.BackgroundColor3 = Color3.new(1, 1, 1)
	splitter3.BorderSizePixel = 0
	splitter3.BorderColor3 = Color3.new(0, 0, 0)
	splitter3.LayoutOrder = 8
	splitter3.Parent = frame

	local UIGradient7 = Instance.new("UIGradient")
	UIGradient7.Name = "UIGradient"
	UIGradient7.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(0.501247, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)})
	UIGradient7.Parent = splitter3

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Name = "UIPadding"
	UIPadding.PaddingRight = UDim.new(0, 5)
	UIPadding.Parent = frame

	local splitter4 = Instance.new("Frame")
	splitter4.Name = "splitter"
	splitter4.Size = UDim2.new(0, 10, 0, 1)
	splitter4.BackgroundColor3 = Color3.new(1, 1, 1)
	splitter4.BorderSizePixel = 0
	splitter4.BorderColor3 = Color3.new(0, 0, 0)
	splitter4.LayoutOrder = 10
	splitter4.Parent = frame

	local UIGradient8 = Instance.new("UIGradient")
	UIGradient8.Name = "UIGradient"
	UIGradient8.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1, 0), NumberSequenceKeypoint.new(0.501247, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)})
	UIGradient8.Parent = splitter4

	local ping = Instance.new("TextLabel")
	ping.Name = "ping"
	ping.Size = UDim2.new(0, 0, 0, 25)
	ping.BackgroundColor3 = Color3.new(1, 1, 1)
	ping.BackgroundTransparency = 1
	ping.BorderSizePixel = 0
	ping.BorderColor3 = Color3.new(0, 0, 0)
	ping.AutomaticSize = Enum.AutomaticSize.X
	ping.LayoutOrder = 9
	ping.Text = "0 ms"
	ping.TextColor3 = Color3.new(0.956863, 0.956863, 0.956863)
	ping.TextSize = 16
	ping.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	ping.TextWrapped = true
	ping.Parent = frame

	library:draggify(frame)

	pcall(function()
		local savedFramePos = http_service:JSONDecode(readfile('seraph/configs/watermark.vector'))
		local translated = Vector2.new(savedFramePos.X, savedFramePos.Y)

		frame.Position = UDim2.new(0,translated.X,0,translated.Y)
	end)

	local fpsValue, targetFPS = 0, 0
	local pingValue, targetPing = 0, 0
	local last = os.clock()
	cons[#cons + 1] = services.runService.RenderStepped:Connect(function(dt)
		frame.Visible = flags.watermark
		if os.clock() - last > 0.25 then
			last = os.clock()
			targetFPS,targetPing = floor(1/dt),floor(services.stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			globals.ping = services.stats.Network.ServerStatsItem["Data Ping"]:GetValue()

			writefile('seraph/configs/watermark.vector', http_service:JSONEncode({
				X = frame.Position.X.Offset,
				Y = frame.Position.Y.Offset
			}))
		end
		fpsValue = math.lerp(fpsValue, targetFPS, correctAlpha(0.35, dt))
		pingValue = math.lerp(pingValue, targetPing, correctAlpha(0.35, dt))
		frame.Parent = library.gui
		fps.Text = `{floor(fpsValue)} fps`
		time.Text = getTimeString()
		ping.Text = `{floor(pingValue)} ms`
	end)
end
]]

do
	local watermark = Instance.new("ScreenGui")
	watermark.Name = "watermark"
	watermark.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	watermark.Parent = library.gui
	watermark.DisplayOrder = 9999

	local frame = Instance.new("Frame")
	frame.Name = "frame"
	frame.Position = UDim2.new(0, 5, 0, 5)
	frame.Size = UDim2.new(0, 0, 0, 25)
	frame.BackgroundColor3 = Color3.new(0.105882, 0.101961, 0.101961)
	frame.BorderSizePixel = 0
	frame.BorderColor3 = Color3.new(0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.X
	frame.Parent = watermark

	local outer = Instance.new("UIStroke")
	outer.Name = "outer"
	outer.Color = Color3.new(0.129412, 0.12549, 0.12549)
	outer.Thickness = 4
	outer.LineJoinMode = Enum.LineJoinMode.Miter
	outer.Parent = frame

	local outer2 = Instance.new("UIStroke")
	outer2.Name = "outer"
	outer2.Color = Color3.new(0.164706, 0.164706, 0.164706)
	outer2.Thickness = 2
	outer2.LineJoinMode = Enum.LineJoinMode.Miter
	outer2.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "label"
	label.Position = UDim2.new(0, 0, 0.5, 0)
	label.Size = UDim2.new(0, 0, 1, 0)
	label.BackgroundColor3 = Color3.new(1, 1, 1)
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.BorderColor3 = Color3.new(0, 0, 0)
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Text = ""
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 12
	label.FontFace = fonts["ProggyClean"] or Font.new("rbxassetid://12187370747", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.RichText = true
	label.Parent = frame

	local outer3 = Instance.new("UIStroke")
	outer3.Name = "outer"
	outer3.Color = Color3.new(0.141176, 0.141176, 0.141176)
	outer3.Thickness = 3
	outer3.LineJoinMode = Enum.LineJoinMode.Miter
	outer3.Parent = frame

	local pad = Instance.new("UIPadding")
	pad.Name = "pad"
	pad.PaddingLeft = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 4)
	pad.Parent = frame

	local outer4 = Instance.new("UIStroke")
	outer4.Name = "outer"
	outer4.Color = Color3.new(0.164706, 0.164706, 0.164706)
	outer4.LineJoinMode = Enum.LineJoinMode.Miter
	outer4.Parent = frame

	local bar = Instance.new("Frame")
	bar.Name = "bar"
	bar.Position = UDim2.new(0.5, 0, 0, 0)
	bar.Size = UDim2.new(1, 8, 0, 2)
	bar.BackgroundColor3 = Color3.new(1, 0, 0)
	bar.BorderSizePixel = 0
	bar.BorderColor3 = Color3.new(0, 0, 0)
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Parent = frame

	local grad = Instance.new("UIGradient")
	grad.Name = "grad"
	grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(0.394015, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)})
	grad.Rotation = 90
	grad.Parent = bar

	library:draggify(frame, 5)

	pcall(function()
		local savedFramePos = http_service:JSONDecode(readfile('seraph/configs/watermark.vector'))
		local translated = Vector2.new(savedFramePos.X, savedFramePos.Y)

		frame.Position = UDim2.new(0,translated.X,0,translated.Y)
	end)

	local function time12h()
		local t = os.date("*t")
		return string.format(
			"%d:%02d %s",
			(t.hour % 12 == 0 and 12 or t.hour % 12),
			t.min,
			t.hour >= 12 and "PM" or "AM"
		)
	end


	local fpsValue, targetFPS = 0, 0
	local pingValue, targetPing = 0, 0
	local last = os.clock()

	local renderFuncs = {
		uid = function()
			return `uid {seraphAcc.userid or 1}`
		end,
		fps = function()
			return `{targetFPS} fps`
		end,
		ping = function()
			return `{targetPing} ms`
		end,
		time = function()
			return `{time12h()}`
		end,
		username = function()
			return seraphAcc.username or "Unknown"
		end
	}
	local corner_text = library:create("TextLabel", {
		Size = dim2(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Position = dim2(1, -5, 0, 5),
		AnchorPoint = vec2(1, 0),
		BackgroundTransparency = 1,
		TextColor3 = rgb(255,255,255),
		TextStrokeTransparency = 0,
		RichText = true,
		TextSize = 11,
		Font = fonts.verdana,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = library.gui
	})
	local sine = 0
	cons[#cons + 1] = services.runService.RenderStepped:Connect(function(dt)
		frame.Visible = flags.watermark and (flags.watermark_style == "classic")
		sine += (dt * 60)
		corner_text.Visible = flags.watermark and (flags.watermark_style == "corner")
		if os.clock() - last > 0.85 then
			last = os.clock()
			targetFPS,targetPing = floor(1/dt),floor(services.stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			globals.ping = services.stats.Network.ServerStatsItem["Data Ping"]:GetValue()

			writefile('seraph/configs/watermark.vector', http_service:JSONEncode({
				X = frame.Position.X.Offset,
				Y = frame.Position.Y.Offset
			}))
		end
		fpsValue = math.lerp(fpsValue, targetFPS, correctAlpha(0.1, dt))
		pingValue = math.lerp(pingValue, targetPing, correctAlpha(0.1, dt))
		bar.BackgroundColor3 = themes.preset.button
		frame.Parent = library.gui
		corner_text.Parent = library.gui
		corner_text.ZIndex = 99999
		local activeText = ""
		local splitter = flags.watermark_style == "classic" and "|" or "Â·"
		for _, renderName in flags.watermark_options or {} do
			activeText ..= ` {splitter} {renderFuncs[renderName]()}`
		end
		label.Text = `seraph<font color="{rgbstr(themes.preset.button)}">.wtf</font> beta{activeText}`
		local interpValue = rgbstr( themes.preset.button:Lerp(rgb(), math.abs(0.1 - 0.05 * cos(sine / 30))) )
		corner_text.Text = `seraph<font color="{interpValue}">.wtf</font> beta{activeText}`
	end)
end

-- documentation 
local build_str = (function(targetStr)
	local len, build = string.len(targetStr), ""

	for i = 1, len do
		build ..= `<font color="{rgbstr(themes.preset.button:lerp(themes.preset.button_alt, i/len))}">{targetStr:sub(i, i)}</font>`
	end

	return build
end)(currentText)

local window = library:window({
	name = `seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str}`,
	size = dim2(0, 460, 0, 362)
})

checkfile('seraph/cache/von.png', 'https://raw.githubusercontent.com/darkblessedangel/seraph.wtf-leak/refs/heads/main/imgs/von.png')

createNotification({text = "loading menu..."})
createNotification({text = "loading modules..."})

local dependants = {}
local function depend(element, f)
	insert(dependants, {element, f})
end

local rage = window:tab({name = "rage"})
rage:change_visibility(false)
if (game.GameId == 73885730) then task.spawn(function()
		rage:change_visibility(true)
		local column = rage:column({})
		local column2 = rage:column({})
		local aimbot = column:section({name = "aimbot", auto_fill = false, size = 0.3})
		aimbot:toggle({name = "enabled", flag = "aimbotenabled"})

		aimbot:slider({name = "fov", min = 0, max = 360, default = 60, interval = 1, suffix = string.char(194,176), flag = "fov"})
		depend(aimbot:colorpicker({name = "color", flag = "fovcolor", color = themes.preset.button, alpha = 0}), function()
			return flags.fov > 0
		end)
		aimbot:dropdown({
			name = "mode",
			flag = "aimbotmode",
			items = {"normal", "multishot"},
			multi = false,
			scrolling = true
		})
		aimbot:dropdown({
			name = "bone",
			flag = "aimbotbone",
			items = {"Head", "Torso"},
			multi = false,
			scrolling = true
		})
		depend(aimbot:slider({name = "bullets", min = 1, max = 1000, default = 1, interval = 1, suffix = "b", flag = "bullets"}), function()
			return flags.aimbotmode == "multishot"
		end)
		depend(aimbot:toggle({name = "multi target", flag = "multitarget", tip = "This can cause issues with your ragebot."}), function()
			return flags.aimbotmode == "multishot"
		end)
		local gun_manip = aimbot:keybind({name = "gun manip", flag = "gunmanip", display = "gun manipulation"})
		aimbot:slider({name = "gun y offset", min = -25, max = 25, default = 0, interval = 1, suffix = "studs", flag = "gunoffset"})
		local resolver = aimbot:keybind({name = "resolver", flag = "resolver", display = "resolver", tip = "Allows you to kill cockroaches (skids under the floor)"})
		aimbot:slider({name = "step scale", min = 1, max = 10, default = 2, interval = 1, suffix = "studs", flag = "resolver_steps"})
		aimbot:slider({name = "max steps", min = 1, max = 30, default = 6, interval = 1, suffix = "studs", flag = "resolver_max_steps"})
		--[[local target_strafe = aimbot:keybind({name = "target strafe", flag = "targetstrafe", display = "target strafe", tip = "Strafes around targets"})
		aimbot:slider({name = "speed", min = 1, max = 11, default = 6, interval = 1, suffix = "studs", flag = "strafe_speed"})
		aimbot:slider({name = "radius", min = 1, max = 16, default = 8, interval = 1, suffix = "studs", flag = "strafe_radius"})
		aimbot:slider({name = "begin after", min = 1, max = 5, default = 2, interval = 1, suffix = "studs", flag = "strafe_targetting"})]]
		local anti_target = aimbot:keybind({name = "anti-target", flag = "antitarget", display = "anti-target", tip = "Prevents enemies and other exploiters from hitting you"})
		aimbot:slider({name = "strength", min = 1, max = 10, default = 2, interval = 1, suffix = "studs", flag = "antitarget_strength"})
		
		aimbot:toggle({name = "single render", flag = "singlerender", tip = "Instead of rendering every bullet shot, it only renders a single one.", default = true})

		aimbot:toggle({name = "criminal targets inmates", flag = "criminal_targets_inmates"})
		aimbot:toggle({name = "inmate targets criminals", flag = "inmate_targets_criminals"})
		aimbot:toggle({name = "no delay", flag = "nodelay", tip = "This causes alot of issues now, we recommend using delay multiplier."})
		depend(aimbot:slider({name = "delay multiplier", min = 0.01, max = 1, default = 1, interval = 0.01, suffix = "x", flag = "delaymult"}), function()
			return not flags.nodelay
		end)
		depend(aimbot:toggle({name = "randomize delay", flag = "rngdelay"}), function() return not flags.nodelay end)
		aimbot:toggle({name = "no spread", flag = "nospread"})
		depend(aimbot:toggle({name = "spread match", flag = "spreadmatch"}), function()
			return flags.aimbotmode == "multishot" and flags.bullets > 1 and (not flags.nospread)
		end)
		aimbot:toggle({name = "prediction", flag = "prediction"})

	--[[local target_selection = column:section({name = "target selection", auto_fill = false, size = 0.7})
	target_selection:dropdown({
		name = "target",
		flag = "targetmode",
		items = {"normal", "nearest", "lowest health"},
		multi = false,
		scrolling = true
	})]]
		local misc = column2:section({name = "misc", auto_fill = false, size = 0.3})
		misc:toggle({name = "arrest aura", flag = "arrestaura"})
		depend(misc:toggle({name = "pull towards", flag = "pull_towards"}), function()
			return flags.arrestaura
		end)
		misc:toggle({name = "targets trespassing", flag = "trespassing"})
		misc:toggle({name = "damage logs", flag = "dmglogs"})
		depend(misc:dropdown({
			name = "kill sound",
			flag = "killsound",
			items = (function()
				local list = {}
				for soundName in sfx do
					insert(list, soundName)
				end
				return list
			end)(),
			multi = false,
			scrolling = true
		}), function()
			return flags.dmglogs
		end)
		depend(misc:toggle({name = "hit sounds", flag = "hitsounds"}), function()
			return flags.dmglogs
		end)
		depend(misc:toggle({name = "pitch randomizer", flag = "pitchrng"}), function()
			return flags.dmglogs
		end)
		depend(misc:toggle({name = "log all", flag = "dmglogsall"}), function()
			return flags.dmglogs
		end)
	--[[local desync = column2:section({name = "desync", auto_fill = false, size = 0.3})
	desync:toggle({name = "animation desync", flag = "animdesync_flag"})
	desync:toggle({name = "velocity breaker", flag = "velocity_breaker"})]]

		local circle = Drawing.new("Circle")
		local outline = Drawing.new("Circle")

		outline.Filled = false
		outline.NumSides = 32
		outline.Transparency = 1
		circle.Filled = true
		circle.NumSides = 32
		circle.Transparency = 0.7

		task.spawn(function()
			local function getPlayerByDisplayName(plrName)
				local player

				for _,v in services.Players:GetPlayers() do
					if v.DisplayName == plrName then
						player = v
						break
					end
				end

				return player
			end

			local killFeed = services.replicatedStorage:WaitForChild("Killfeed")
			killFeed.ChildAdded:Connect(function(obj)
				if not flags.dmglogs then
					return
				end
				local objectName = obj.Name
				if string.match(objectName, `@{lp.Name}`) then
					local nameArgs = string.sub(objectName, #`{lp.DisplayName} (@{lp.Name})  killed ` + 1):split(" with ")

					local enemyName, weaponName = nameArgs[1], nameArgs[2]

					local distance = 'N/A'
					local killedPlayer = getPlayerByDisplayName(enemyName)
					local success, value = pcall(function()
						if killedPlayer then
							local char = killedPlayer.Character
							if char then
								distance = math.floor((char:GetPivot().Position - workspace.CurrentCamera.Focus.Position).Magnitude)
							end
							enemyName = `{enemyName} (@{killedPlayer.Name})`
						end
					end)
					if not success then
						--print(value)
					end

					local sfxId = sfx[flags.killsound]
					if sfxId then
						local sound = Instance.new("Sound")
						sound.SoundId = sfxId
						sound.Name = ""
						sound.Volume = 1
						sound.PlaybackSpeed = flags.pitchrng and math.random(95, 105) / 100 or 1
						sound.PlayOnRemove = true
						sound.Parent = coregui
						task.defer(game.Destroy, sound)
					end


					createNotification({text = `killed {enemyName} with {weaponName} from {distance} studs`})
				elseif flags.dmglogsall then
					local killer, victim, weapon =
						string.match(objectName, "^(.-) killed (.-) with (.+)$")

					local distance = "N/A"

					local killedPlayer = getPlayerByDisplayName(victim)
					local success, value = pcall(function()
						if killedPlayer then
							local char = killedPlayer.Character
							if char then
								distance = math.floor((char:GetPivot().Position - workspace.CurrentCamera.Focus.Position).Magnitude)
							end
							victim = `{victim} (@{killedPlayer.Name})`
						end
					end)

					createNotification({text = `{killer} killed {victim} with {weapon} from {distance} studs`})
				end
			end)
		end)

		local tool

		local function canFire()
			return tool:GetAttribute("CurrentAmmo") > 0
		end

		local function playLocalSound(sfx)
			sfx:Play()
		end

		local glassParts, params = {}, RaycastParams.new()

		local function playerIsEnemy(player)
			local isSameTeam = lp.TeamColor == player.TeamColor
			if isSameTeam then
				return false
			end

			local selfTeam, enemyTeam = lp.Team.Name, player.Team.Name

			local char = player.Character

			if selfTeam == "Guards" then
				if enemyTeam == "Inmates" and char:GetAttribute("Hostile") then
					return true
				elseif enemyTeam == "Criminals" then
					return true
				end
			elseif selfTeam == "Criminals" then
				if enemyTeam == "Inmates" and (flags.criminal_targets_inmates and (char:GetAttribute("Hostile") or char:GetAttribute("Trespassing"))) then
					return true
				elseif enemyTeam == "Guards" then
					return true
				end
			elseif selfTeam == "Inmates" then
				if enemyTeam == "Guards" then
					return true
				elseif (flags.inmate_targets_criminals and enemyTeam == "Criminals") then
					return true
				end
			end

			return false
		end

		local function castRay(startPos, endPos)

		--[[local spreadFactor = (startPos - endPos).magnitude / tool:GetAttribute("SpreadRadius")

		local randomOffset = flags.nospread and vec3(0, 0, 0) or vec3(
			math.random(-spreadFactor, spreadFactor) / 10,
			math.random(-spreadFactor, spreadFactor) / 10,
			math.random(-spreadFactor, spreadFactor) / 10
		)]]

			local direction = (CFrame.new(startPos, endPos) * (flags.nospread and CFrame.identity or CFrame.Angles(0, 0, math.rad(math.random(-360, 360))) * CFrame.Angles(0, math.random() * tool:GetAttribute("SpreadRadius"), 0))).LookVector * tool:GetAttribute("Range")

			--local direction = (endPos + randomOffset - startPos).unit * tool:GetAttribute("Range")

			local raycastResult = workspace:Raycast(startPos, direction, params)

			if raycastResult then
				return raycastResult.Instance, raycastResult.Position
			end

			return nil, startPos + direction
		end


		local function getTarget()
			local targetPart
			local closestDistance = math.huge
			for _, player in services.players:GetPlayers() do
				local char = player.Character
				if not char then continue end
				if not playerIsEnemy(player) then continue end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum then continue end
				if hum.Health <= 0 then continue end
				if char:FindFirstChildOfClass("ForceField") then continue end
				if player_list[player.Name] and player_list[player.Name].ignore_player then continue end
				local bonePart = char:FindFirstChild(flags.aimbotbone)
				if flags.aimbotbone == "Random" then
					local sel = {}
					for _, part in char:GetChildren() do
						if part:IsA("BasePart") then
							insert(sel, part)
						end
					end
					bonePart = sel[math.random(1, #sel)]
				end
				if not bonePart then continue end
				local screenPoint, onScreen = worldToScreenPoint(bonePart)
				local diff = (vec2(mouse.X, mouse.Y) - screenPoint).Magnitude
				local canIShoot = (flags.fov >= 360 and true or (diff <= flags.fov and onScreen))


				if (canIShoot and diff < closestDistance)  then --  and Distance < ClosestDistance
					targetPart = bonePart
					closestDistance = diff
				end
			end
			return targetPart
		end

		function timeout(signal, f)
			local elapsed,executed,args = 0,false,nil

			task.spawn(function()
				args = {signal:Wait()}
				executed = true
			end)

			task.spawn(function()
				repeat elapsed += task.wait() until executed or elapsed >= 0.25
				if executed then
					f(table.unpack(args))
				end
			end)
		end

		local function getTargetAll()
			local targetParts = {}
			local closestDistance = math.huge
			for _, player in services.players:GetPlayers() do
				local char = player.Character
				if not char then continue end
				if not playerIsEnemy(player) then continue end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum then continue end
				if hum.Health <= 0 then continue end
				if char:FindFirstChildOfClass("ForceField") then continue end
				if player_list[player.Name] and player_list[player.Name].ignore_player then continue end
				local bonePart = char:FindFirstChild(flags.aimbotbone)
				if not bonePart then continue end
				local screenPoint, onScreen = worldToScreenPoint(bonePart)
				local diff = (vec2(mouse.X, mouse.Y) - screenPoint).Magnitude
				local canIShoot = (flags.fov >= 360 and true or diff <= flags.fov)

				if (canIShoot and diff < closestDistance)  then --  and Distance < ClosestDistance
					insert(targetParts, bonePart)
					closestDistance = diff
				end
			end
			return targetParts
		end

		local function traceBullet(startPos, endPos, hitTarget)
			local hitPart, hitPos = castRay(startPos, endPos)

			if not hitPart then
				return
			end

			if (not hitPart:IsDescendantOf(hitTarget.Parent)) then
				return
			end

			return {
				startPos,
				hitPos,
				hitPart
			}
		end


		local function generateBullets(muzzlePos, targetPos, target)
			local fireBullets, renderBullets = {}, {}
			local bulletCount = (flags.aimbotmode == "multishot" and flags.bullets or (tool:GetAttribute("ProjectileCount") or 1))

			local pred = targetPos + (target.Velocity * globals.frametime) * services.stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000

			if flags.multitarget and flags.aimbotmode == "multishot" then
				local targets = getTargetAll()
				for _, target in targets do
					local firstBullet = traceBullet(muzzlePos, target.Position, target)
					if not firstBullet then continue end
					if flags.prediction then
						firstBullet[2] = pred
					end
					for i = 1, math.clamp(math.floor(bulletCount / #targets), 1, 5000) do
						insert(fireBullets, firstBullet)
					end
				end
			else
				if (flags.spreadmatch and (not flags.nospread)) then

					for i = 1, bulletCount do
						local firstBullet = traceBullet(muzzlePos, targetPos, target)
						if not firstBullet then continue end
						if flags.prediction then
							firstBullet[2] = pred
						end
						insert(fireBullets, firstBullet)
					end
				else
					local firstBullet = traceBullet(muzzlePos, targetPos, target)
					if not firstBullet then return end
					if flags.prediction then
						firstBullet[2] = pred
					end
					for i = 1, bulletCount do
						insert(fireBullets, firstBullet)
					end
				end
			end

			if flags.singlerender then
				local thisBullet = fireBullets[1]
				if thisBullet then
					insert(renderBullets, {thisBullet[1], thisBullet[2], "Bullet"})
				end
			else
				for _, thisBullet in fireBullets do
					insert(renderBullets, {thisBullet[1], thisBullet[2], "Bullet"})
				end
			end

			if flags.hitsounds and flags.dmglogs then
				local hum = target.Parent:FindFirstChildOfClass("Humanoid")
				local sfxId = sfx[flags.killsound]
				if sfxId then
					local old = hum.Health
					timeout(hum.HealthChanged, function()
						if hum.Health < old then
							local sound = Instance.new("Sound")
							sound.SoundId = sfxId
							sound.Name = ""
							sound.Volume = 1
							sound.PlaybackSpeed = flags.pitchrng and math.random(95, 105) / 100 or 1
							sound.PlayOnRemove = true
							sound.Parent = coregui
							task.defer(game.Destroy, sound)
						end
					end)
				end
			end

			return fireBullets, renderBullets
		end

		local bulletDelay = 0
		local dbgT = Drawing.new("Text")
		dbgT.Position = workspace.CurrentCamera.ViewportSize / 2 + vec2(0, 100)
		dbgT.Visible = true
		dbgT.Size = 18
		dbgT.Color = themes.preset.button:lerp(rgb(255,255,255),0.5)
		dbgT.Center = true
		dbgT.Text = ""

		local textParts = {}
		for i = 1, 32 do
			local textPartition = Drawing.new("Text")
			textPartition.Position = workspace.CurrentCamera.ViewportSize / 2 + vec2(0, 100)
			textPartition.Visible = true
			textPartition.Center = true
			textPartition.Font = 3
			textPartition.Size = 12
			textPartition.Outline = false
			textPartition.Text = ""
			insert(textParts, textPartition)
		end

		function renderText(str)
			local len = string.len(str)

			if len == 0 then
				for _, part in textParts do part.Visible = false end
				return
			end

			local center = workspace.CurrentCamera.ViewportSize / 2 + vec2(0, 100)
			for i, part in textParts do
				if i > len then
					part.Visible = false
					continue
				end

				part.Visible = true
				part.Text = str:sub(i, i)
				center -= Vector2.new(part.TextBounds.X / 2, 0)
			end

			for i, part in textParts do
				if i > len then
					part.Visible = false
					continue
				end

				part.Color = themes.preset.button:lerp(themes.preset.button_alt:lerp(rgb(255,255,255),0.25), 0.5 + 0.5 * math.sin(elapsed_ticks / 5)):Lerp(themes.preset.button_alt:lerp(themes.preset.button:lerp(rgb(255,255,255),-0.25), 0.5 - 0.5 * math.sin(elapsed_ticks / 5)), i/len)
				part.Position = center
				center += Vector2.new(part.TextBounds.X, 0)
			end

		end

		local realRootCF = cf()
		local function getTargetResolver()
			local targetPart
			local closestDistance = math.huge
			local bestTeleportCF

			local localChar = services.players.LocalPlayer.Character
			if not localChar then return end

			local localRoot = localChar:FindFirstChild("HumanoidRootPart")
			local localHead = localChar:FindFirstChild("Head")
			if not (localRoot and localHead) then return end

			for _, player in services.players:GetPlayers() do
				local char = player.Character
				if not char then continue end
				if not playerIsEnemy(player) then continue end

				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health <= 0 then continue end
				if char:FindFirstChildOfClass("ForceField") then continue end
				if player_list[player.Name] and player_list[player.Name].ignore_player then continue end

				local bonePart = char:FindFirstChild(flags.aimbotbone)
				if flags.aimbotbone == "Random" then
					local sel = {}
					for _, part in char:GetChildren() do
						if part:IsA("BasePart") then
							table.insert(sel, part)
						end
					end
					bonePart = sel[math.random(1, #sel)]
				end
				if not bonePart then continue end

				local screenPoint, onScreen = worldToScreenPoint(bonePart)
				local diff = (vec2(mouse.X, mouse.Y) - screenPoint).Magnitude
				local canIShoot = (flags.fov >= 360) or (diff <= flags.fov and onScreen)

				if not canIShoot or diff >= closestDistance then continue end

				-- basic directional "pathfinding"
				local targetRoot = char:FindFirstChild("HumanoidRootPart")
				local targetHead = char:FindFirstChild("Head")
				if not (targetRoot and targetHead) then continue end

				local bestDist
				local foundCF

				local step = clamp(flags.resolver_steps, 1, flags.resolver_max_steps)
				local maxSteps = flags.resolver_max_steps
				local directions = {
					Vector3.new(1, 0, 0),
					Vector3.new(-1, 0, 0),
					Vector3.new(0, 0, 1),
					Vector3.new(0, 0, -1),
					Vector3.new(0, 1, 0),
					Vector3.new(0, -1, 0),
					Vector3.new(0.5, 0, 0.5),
					Vector3.new(-0.5, 0, -0.5),
					Vector3.new(0.5, 0, -0.5),
					Vector3.new(-0.5, 0, 0.5)
				}

				for _, dir in directions do
					for i = 1, maxSteps do
						local offset = dir * step * i
						local testRootPos = (realRootCF and realRootCF.Position or targetRoot.Position) + offset
						local headOffset = localHead.Position - localRoot.Position
						local testHeadPos = testRootPos + headOffset

						-- LOS check (can we be hit / hit them)
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Blacklist
						params.FilterDescendantsInstances = { localChar, char }
						params.IgnoreWater = true

						local ray = workspace:Raycast(
							targetHead.Position,
							testHeadPos - targetHead.Position,
							params
						)

						if not ray then
							local dist = (localRoot.Position - testRootPos).Magnitude
							if not bestDist or dist < bestDist then
								bestDist = dist
								foundCF = CFrame.new(testRootPos, targetRoot.Position)
							end
							break -- stop stepping further in this direction
						end
					end
				end

				targetPart = bonePart
				closestDistance = diff
				bestTeleportCF = foundCF
			end

			return targetPart, bestTeleportCF
		end



		-- exploit to change position on server (old method by me)
		-- technical explanation: ping and packet delays cause this to desync on the server, allowing us to "teleport" on the server while remaining untouched on the client.
		function tdf(c, f, ...)
			if c == 0 then
				return f(...)
			end

			return task.defer(tdf, c-1,f,...)
		end

		local offsetCFrame = CFrame.identity
		local offsetVelocity = Vector3.zero

		local overrideCF = cf()
		local thisConnection

		local cameraOffset = CFrame.identity

		local line = create('BoxHandleAdornment', {
			AlwaysOnTop = true,
			Parent = coregui,
			Adornee = workspace.Terrain,
			Size = Vector3.new(2,2,1),
			Color3 = themes.preset.button_alt,
			Transparency = 0.5,
			AdornCullingMode = Enum.AdornCullingMode.Never,
			ZIndex = 10,
			Visible = true
		})
		local lerpedCF, width = cf(), 0
		thisConnection = run.Stepped:Connect(function(_, dt)
			local char = lp.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then return end


			local possibleOffset = cf()
			if overrideCF.Position.Magnitude >= 2 then
				possibleOffset = overrideCF
				width = math.lerp(width, 0.05, correctAlpha(0.45, dt))
			else
				possibleOffset = cf()
				width = math.lerp(width, 0.00, correctAlpha(0.25, dt))
			end

			local focus = hrp.Position
			local saved = hrp.CFrame * lerpedCF
			line.CFrame = cf(focus, saved.Position) * cf(0,0,-(focus - saved.Position).Magnitude/2)
			line.Size = vec3(width, width, (focus - saved.Position).Magnitude)
			line.Visible = (lerpedCF.Position.Magnitude > 0)
			realRootCF = hrp.CFrame

			offsetCFrame = possibleOffset
			lerpedCF = lerpedCF:Lerp(offsetCFrame, correctAlpha(0.9, dt))
				
			hrp.CFrame *= offsetCFrame
			cameraOffset = offsetCFrame
			
			hum.CameraOffset = -cameraOffset.Position
		end)

		local thisConnection
		thisConnection = run.RenderStepped:Connect(function(dt)
			local char = lp.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			--lp.Character.HumanoidRootPart.CFrame += offsetCFrame:Inverse().Position
			if (offsetCFrame.Position.Magnitude > 0) then
				hrp.CFrame = cf((realRootCF + hrp.AssemblyLinearVelocity * dt).Position) * hrp.CFrame.Rotation
			end
			offsetCFrame = CFrame.identity
		end)

		-- used to fix camera and character issues
		local saved = cf()
	 	--[[run:BindToRenderStep("cameraUpdateEvent", Enum.RenderPriority.Camera.Value - 1, function(dt)
			if (offsetCFrame.Position.Magnitude == 0) then
				return
			end
			saved = lp.Character.HumanoidRootPart.CFrame
			lp.Character.HumanoidRootPart.CFrame *= cameraOffset
		end)]]
		--[[run:BindToRenderStep("preUpdateInput", Enum.RenderPriority.Input.Value - 1, function(dt)
			local char = lp.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			saved = hrp.CFrame
			hrp.CFrame = realRootCF
		end)
		run:BindToRenderStep("postUpdateChar", Enum.RenderPriority.Character.Value + 1, function(dt)
			local char = lp.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			if not saved then return end
			hrp.CFrame = saved
			saved = nil
		end)]]

		local projectiles, debree = {}, {}
		local function updateProjectiles(delta)
			for i,v in projectiles do
				v.Velocity = v.Velocity * (1 - delta * 2)
				v.TimeInWorld -= delta
				v.Object.CFrame += v.Velocity * delta
				if v.Outline then
					v.Outline.CFrame = v.Object.CFrame
				end
				if v.TimeInWorld <= 0 then
					v.Object:Destroy()
					table.remove(projectiles, i)
				end
				if v.Rot then
					v.Object.CFrame *= CFrame.fromAxisAngle(v.Rot * delta, 0.1)
				end
			end
			for i,v in debree do
				v.TimeInWorld -= delta
				v.Object.Transparency = 1.0 - (v.TimeInWorld / v.TotalTime)
				v.Outline.Transparency = v.Object.Transparency
				v.Intensity += delta / 5
				v.Intensity = math.min(v.Intensity, 1)
				v.Object.CFrame *= (CFrame.Angles(v.AngleX*delta,v.AngleY*delta,v.AngleZ*delta)*CFrame.new(v.PosX*delta,v.PosY*delta,v.PosZ*delta)):Lerp(CFrame.identity, v.Intensity)
				v.Outline.CFrame = v.Object.CFrame
				if v.TimeInWorld <= 0 then
					v.Outline:Destroy()
					v.Object:Destroy()
					table.remove(debree, i)
				end
			end
		end

		local function shoot()
			local char = lp.Character
			if not char then
				return --print("FAIL XD")
			end
			
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then
				return --print("FAIL XD")
			end
			
			--[[if target_strafe.active then
				local targetPart = getTarget()
				if targetPart then
					local dist = (targetPart.Position - hum.RootPart.Position).Magnitude
					if dist <= (flags.strafe_targetting + flags.strafe_radius) then
						local angle = (elapsed_ticks / 30) * flags.strafe_speed
						local radius = flags.strafe_radius
						local offsetX = math.cos(angle) * radius
						local offsetZ = -math.sin(angle) * radius
						local target = cf(targetPart.Position) * cf(offsetX, 0, offsetZ)
						if (hum.RootPart.Position ~= target.Position) then
							local pos = hum.RootPart.Position
							local look = target.Position
							hum.RootPart.CFrame = cf(pos, vec3(look.x, pos.y, look.z))
							local base = vec3(0, hum.RootPart.AssemblyLinearVelocity.Y, 0)
							local vector = ((look - pos).Unit * 25)
							hum.RootPart.AssemblyLinearVelocity = base + vec3(vector.x, 0, vector.z)
							--sethiddenproperty(hum, "MoveDirection", (pos - target.Position).Unit)
							--lp:Move((pos - look), false)
						end
					end
				end
			end]]
			
			overrideCF = cf()
			library.desyncPlayer = false
			if (anti_target.active) then
				overrideCF *= cf(random(-1,1) * random() * flags.antitarget_strength, 0, random(-1,1) * random() * flags.antitarget_strength)
			end
			tool = char:FindFirstChildOfClass("Tool")
			if not tool then
				return --print("FAIL XD")
			end
			local muzzle = tool:FindFirstChild("Muzzle")
			if not muzzle then
				return --print("FAIL XD")
			end
			if tool:GetAttribute("Reloading__") ~= nil then 
				--	renderText("reloading")
				return end
			if tool:GetAttribute("Local_ReloadSession") ~= 0 then 
				--	renderText("reloading")
				return
			end

			if (resolver.active) then
				
				local targetPart, targetPos = getTargetResolver()
				if targetPart and targetPos then
					library.desyncPlayer = true
					overrideCF = cf((realRootCF:Inverse() * targetPos).Position)
				else
					library.desyncPlayer = false
				end
			end

			if not tool:GetAttribute("gunOffset") then tool:SetAttribute("gunOffset", tool.GripPos) end
			if gun_manip.active then
				if tool.GripPos.Y ~= flags.gunoffset then
					hum:UnequipTools()
					tool.GripPos = Vector3.new(tool.GripPos.X, flags.gunoffset, tool.GripPos.Z)
					hum:EquipTool(tool)
				end
			else
				tool.GripPos = Vector3.new(tool.GripPos.X, tool:GetAttribute("gunOffset").Y, tool.GripPos.Z)
			end
			if not canFire() then
				--print("START reloading")
				tool:SetAttribute("Reloading__", tick())
				local rt = tool
				playLocalSound(tool.Handle["ReloadSound"])
				services.replicatedStorage.GunRemotes.FuncReload:InvokeServer()
				rt:SetAttribute("Reloading__", nil)
				--print("STOP reloading")
				return
			end
			local shootGunDoe = (flags.nodelay and true or (tick() - bulletDelay) >= (tool:GetAttribute("FireRate") * flags.delaymult)) and canFire()
			--renderText("")
			--dbgT.Text = `can fire rn: {(tick() - bulletDelay) >= tool:GetAttribute("FireRate")}\nfire delay: {math.floor((tick() - bulletDelay)*100)/100}\ncanFire return: {canFire()}\nwill i shoot doe? {shootGunDoe}\nbone target: {flags.aimbotbone}`
			if shootGunDoe then
				--print('can fire','attempt')
				local replicateBullet = services.replicatedStorage.GunRemotes.ReplicateEvent

				local targetPart = getTarget()
				if not targetPart then return end

				params.FilterDescendantsInstances = {char}

				local firstBullet = traceBullet(muzzle.Position, targetPart.Position, targetPart)
				if not firstBullet then return end

				local bulletsToFire, bulletsToRender = generateBullets(muzzle.Position, targetPart.Position, targetPart)

				if not bulletsToFire or not bulletsToRender then return end

				if #bulletsToFire == 0 then
					return
				end



				playLocalSound(tool.Handle.ShootSound)

				if flags.shoot_effects then
					for i = 1, 8 do
						local trailPart = _assets.Trails.A:Clone()
						trailPart.CFrame = muzzle.CFrame * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
						trailPart.CanCollide = false
						trailPart.Anchored = true
						trailPart.Transparency = 1
						for _, trailObject in trailPart:GetDescendants() do
							if not trailObject:IsA("Trail") then continue end
							trailObject.Color = ColorSequence.new(flags.shoot_effects_color.Color, flags.shoot_effects_color.Color:Lerp(rgb(), .3))
						end
						trailPart.Parent = workspace.Terrain
						table.insert(projectiles,{
							Object = trailPart,
							TimeInWorld = flags.shoot_effects_lifetime,
							Velocity = Vector3.new(math.random(-16,16),math.random(-16,16),math.random(-16,16))
						})
					end

					for i = 1, 6 do
						local trailPart = _assets.Trails.A:Clone()
						trailPart.CFrame = muzzle.CFrame * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
						trailPart.CanCollide = false
						trailPart.Anchored = true
						trailPart.Transparency = 0
						trailPart.Material = Enum.Material.Neon
						trailPart.Color = flags.shoot_effects_color.Color
						trailPart.Parent = workspace.Terrain
						local outline = _assets.Trails.A:Clone()
						outline.CFrame = muzzle.CFrame
						outline.CanCollide = false
						outline.Anchored = true
						outline.Transparency = 0
						outline.Material = Enum.Material.ForceField
						outline.Size *= 1.1
						outline.Color = flags.shoot_effects_color.Color
						outline.Parent = trailPart
						outline:ClearAllChildren()
						for _, trailObject in trailPart:GetDescendants() do
							if not trailObject:IsA("Trail") then continue end
							trailObject.Color = ColorSequence.new(flags.shoot_effects_color.Color, flags.shoot_effects_color.Color:Lerp(rgb(), .3))
						end
						table.insert(debree,{
							Object = trailPart,
							Outline = outline,
							TimeInWorld = flags.shoot_effects_lifetime or 5,
							TotalTime = flags.shoot_effects_lifetime or 5,
							AngleX = math.random(-8,8),
							AngleY = math.random(-8,8),
							AngleZ = 0,
							PosX = randomGen:NextNumber(5,10),
							PosY = randomGen:NextNumber(5,10),
							PosZ = randomGen:NextNumber(5,10),
							Intensity = 0
						})
					end
				end

				for _, bullet in bulletsToRender do
					draw_bullet(bullet[1], bullet[2], false)
				end

				services.replicatedStorage.GunRemotes.ShootEvent:FireServer(bulletsToFire)

				local delayTime = ((not flags.nodelay) and flags.rngdelay) and math.random()/100 or 0
				bulletDelay = tick()+delayTime
			end
		end

		local function arrest()
			local char = lp.Character
			if not char then return end
			local hasCuffs = char:FindFirstChild("Handcuffs") or lp.Backpack:FindFirstChild("Handcuffs")
			if not hasCuffs then return end
			local arrestRemote = services.ReplicatedStorage.Remotes.ArrestPlayer
			local usedCuffs = false
			local playersAttempted = 0

			local lhum = char:FindFirstChildOfClass("Humanoid")
			if not lhum then return end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			for _, plr in services.Players:GetPlayers() do
				if plr.Team and plr.Team.Name == "Guards" then continue end

				local enemyChar = plr.Character
				if not enemyChar then continue end

				local canArrest = (plr.Team.Name == "Criminals" or (enemyChar:GetAttribute("Tased") and (enemyChar:GetAttribute("Hostile") or enemyChar:GetAttribute("Trespassing")))) or (flags.trespassing and enemyChar:GetAttribute("Trespassing"))
				if not canArrest then continue end

				if player_list[plr.Name] and player_list[plr.Name].ignore_player then continue end

				local hum = enemyChar:FindFirstChildOfClass("Humanoid")
				local rootPart = enemyChar:FindFirstChild("HumanoidRootPart")
				if (not rootPart) or (not hum) then continue end

				if flags.pull_towards then
					if (rootPart.Position - hrp.Position).Magnitude < 14.5 then
						rootPart.CFrame = rootPart.CFrame:Lerp(hrp.Position, 0.2)
						if (rootPart.Position - hrp.Position).Magnitude <= 7.5 then
							continue
						end
					end
				else
					if (rootPart.Position - hrp.Position).Magnitude > 7.5 then
						continue
					end
				end



				if hum.WalkSpeed == 0 and hum.JumpHeight == 0 then
					if hasCuffs:GetAttribute(
						"forceEquipped"
						) then
						hasCuffs:SetAttribute("forceEquipped", false)

						local toolList = {}
						for _, obj in char:GetChildren() do
							if obj:IsA("Tool") and obj ~= hasCuffs then
								insert(toolList, obj)
							end
						end

						lhum:UnequipTools()

						for _, tool in toolList do
							lhum:EquipTool(tool)
						end

						table.clear(toolList)
					end
					continue
				end

				playersAttempted += 1

				if hasCuffs.Parent == lp.Backpack then
					hasCuffs:SetAttribute(
						"forceEquipped",
						true
					)
					lhum:UnequipTools()
					lhum:EquipTool(hasCuffs)
				end


				task.spawn(function() arrestRemote:InvokeServer(plr) end)

			end

			if hasCuffs:GetAttribute("forceEquipped") and playersAttempted == 0 then
				hasCuffs:SetAttribute("forceEquipped", false)
				local toolList = {}
				for _, obj in char:GetChildren() do
					if obj:IsA("Tool") and obj ~= hasCuffs then
						insert(toolList, obj)
					end
				end

				lhum:UnequipTools()

				for _, tool in toolList do
					lhum:EquipTool(tool)
				end

				table.clear(toolList)
			end
		end

		cons[#cons + 1] = services.runService.RenderStepped:Connect(function(dt)
			thread(updateProjectiles, dt)
			if flags.arrestaura then
				arrest()
			end
			if not flags.aimbotenabled then
				circle.Visible, outline.Visible = false, false
				return
			end


			circle.Position = uis:GetMouseLocation()
			circle.Radius = flags.fov
			circle.Color = flags.fovcolor.Color
			circle.Transparency = 0.7 * (flags.fovcolor.Transparency)
			circle.Visible = (flags.fov ~= 360)

			outline.Position = uis:GetMouseLocation()
			outline.Radius = flags.fov
			outline.Transparency = 1 * (flags.fovcolor.Transparency)
			outline.Color = flags.fovcolor.Color:Lerp(rgb(), 0.25)
			outline.Visible = (flags.fov ~= 360)

			shoot()
		end) end)
elseif game.PlaceId == 286090429 then

end

local bullets = {
	--[[line = function(from, to, playSound)
		local bullet = Instance.new("Part")
		bullet.CFrame = cf(from, to) * cf(0, 0, -(from - to).Magnitude / 2)
		bullet.Size = Vector3.new(0,0,(from - to).Magnitude)
		bullet.Material = Enum.Material.Neon
		bullet.Name = ""
		bullet.Anchored = true
		bullet.CanCollide = false
		bullet.Transparency = 1
		bullet.Parent = workspace.Terrain
		local sphere = Instance.new("SpecialMesh")
		sphere.MeshType = Enum.MeshType.Sphere
		sphere.Scale = Vector3.new(1, 1, 1)
		sphere.Parent = bullet
		tween_service:Create(bullet,TweenInfo.new(0.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0),{Color = flags.bullet_tracer_color.Color}):Play()
		tween_service:Create(bullet,TweenInfo.new(0.25,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0),{Transparency = 1 - flags.bullet_tracer_color.Transparency}):Play()
		tween_service:Create(bullet,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0),{Size = Vector3.new(flags.bullet_tracer_thickness,flags.bullet_tracer_thickness,(from - to).Magnitude)}):Play()
		task.delay(1.5, function() tween_service:Create(bullet,TweenInfo.new(4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0),{Transparency = 1}):Play() end)
		task.delay(6, game.Destroy, bullet)
	end,]]
	lightning = function(from, to, playSound)
		local parts = {}
		local translated = {}
		local origin, originOffset = from, from
		local length = clamp(floor((from - to).Magnitude / 25), 10, 100)

		local scale = .5
		for i = 1, length do
			local new = origin:Lerp(to, i/length)
			local offset = vec3(
				math.random() * math.random(-1,1) * scale,
				math.random() * math.random(-1,1) * scale,
				math.random() * math.random(-1,1) * scale
			)
			local part = Instance.new("Part")
			local length = (origin - new).Magnitude
			part.CFrame = cf(origin, new) * cf(0, 0, -length / 2)
			part.Size = Vector3.new(0, 0, length)
			part.Color = Color3.new(

			)
			local length = (originOffset - (new + offset)).Magnitude
			tween_service:Create(part, TweenInfo.new(0.2 + i/5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0),{
				Size = Vector3.new(flags.bullet_tracer_thickness, flags.bullet_tracer_thickness, length),
				CFrame = cf(originOffset, (new + offset)) * cf(0, 0, -length / 2)
			}):Play()
			tween_service:Create(part, TweenInfo.new(0.05 + i/5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0),{
				Color = flags.bullet_tracer_color.Color
			}):Play()
			tween_service:Create(part, TweenInfo.new(0.5 + i/5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0),{
				Transparency = 1
			}):Play()
			task.delay(0.5 + i/5,game.Destroy,part)
			part.Material = Enum.Material.Neon
			part.Name = ""
			part.Anchored = true
			part.Transparency = 1 - flags.bullet_tracer_color.Transparency
			part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
			part.Parent = workspace.Terrain
			origin = new
			originOffset = new + offset
		end
	end,
	spiral = function(from, to)
		local distance = (from - to).Magnitude
		local direction = (to - from).Unit

		local right = Vector3.new(0, 1, 0):Cross(direction).Unit
		if right.Magnitude == 0 then right = Vector3.new(1, 0, 0) end
		local up = direction:Cross(right).Unit
		local brush = Instance.new("Part")
		brush.Size = Vector3.new(0.01, 0.01, 0.01)
		brush.Transparency = 1
		brush.CanCollide = false
		brush.Anchored = true
		brush.CFrame = CFrame.new(from)
		brush.Parent = workspace.Terrain
		local a0 = Instance.new("Attachment", brush)
		local a1 = Instance.new("Attachment", brush)
		a0.Position = Vector3.new(0, flags.bullet_tracer_thickness, 0)
		a1.Position = Vector3.new(0, -flags.bullet_tracer_thickness, 0)

		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.LightEmission = 1
		trail.Texture = "rbxassetid://6091329339"
		trail.Transparency = NumberSequence.new(0, 1)
		trail.TextureMode = Enum.TextureMode.Wrap
		trail.Color = ColorSequence.new(flags.bullet_tracer_color.Color)
		trail.Transparency = NumberSequence.new(1 - flags.bullet_tracer_color.Transparency, 1)
		trail.Lifetime = 3.5 -- How long the tracer stays visible
		trail.WidthScale = NumberSequence.new(1, 0)
		trail.FaceCamera = true
		trail.Parent = brush
		local segments = 90 
		local rotations = 2
		local radius = math.clamp(math.random(), 0.5, 0.9)

		for i = 0, segments do
			local t = i / segments
			local basePos = from:Lerp(to, t)
			local angle = t * math.pi * 2 * rotations
			local offset = (right * math.cos(angle) * radius) + (up * math.sin(angle) * radius)
			brush.Position = basePos + offset
			if i % 3 == 0 then
				task.wait()
			end
		end
		task.delay(trail.Lifetime, game.Destroy, brush)
	end,
	smooth = function(from, to)
		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")

		a0.WorldPosition = from
		a1.WorldPosition = to

		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.LightEmission = 1
		beam.TextureLength = 3.5
		beam.Texture = "rbxassetid://446111271"
		beam.TextureSpeed = math.random()
		beam.FaceCamera = true
		beam.Width0 = flags.bullet_tracer_thickness * .9
		beam.Width1 = flags.bullet_tracer_thickness * .9
		beam.TextureMode = Enum.TextureMode.Wrap

		beam.Parent = workspace.Terrain
		a0.Parent = workspace.Terrain
		a1.Parent = workspace.Terrain

		local tween = tween_service:Create(beam, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true,0),{
			Width0 = flags.bullet_tracer_thickness,
		})

		tween:Play()

		task.delay(0.25 / 2, function()
			local tween = tween_service:Create(beam, TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1,true,0),{
				Width1 = flags.bullet_tracer_thickness,
			})

			tween:Play()
		end)

		for i = 1, 5 do
			beam.Transparency = NumberSequence.new(1-i/5, 1-i/5)
			beam.Color = ColorSequence.new(flags.bullet_tracer_color.Color)
			task.wait()
		end

		task.wait(5)

		for i = 1, 50 do
			beam.Transparency = NumberSequence.new(i/50, i/50)
			beam.Width0 = math.lerp(beam.Width0, 0, 1/50)
			beam.Width1 = math.lerp(beam.Width1, 0, 1/50)
			beam.Color = ColorSequence.new(flags.bullet_tracer_color.Color)
			task.wait()
		end

		a0:Destroy()
		beam:Destroy()
		a1:Destroy()
	end,
	line = function(from, to)
		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")

		a0.WorldPosition = from
		a1.WorldPosition = to

		local boxhandle = library:create("BoxHandleAdornment", {
			Size = Vector3.new(0.02, 0.02, (from - to).Magnitude),
			CFrame = cf(from, to) * cf(0, 0, -(from - to).Magnitude / 2),
			Adornee = workspace.Terrain,
			AlwaysOnTop = true,
			ZIndex = 1,
			Transparency = 1,
			Color3 = flags.bullet_tracer_color.Color,
			Parent = workspace.Terrain
		})

		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = a1
		beam.LightEmission = .5
		beam.LightInfluence = 0
		beam.TextureLength = 3.5
		beam.TextureSpeed = .5
		beam.FaceCamera = true
		beam.Width0 = 0 --flags.bullet_tracer_thickness * .8
		beam.Width1 = 0 --flags.bullet_tracer_thickness * .9
		beam.TextureMode = Enum.TextureMode.Wrap

		beam.Parent = workspace.Terrain
		a0.Parent = workspace.Terrain
		a1.Parent = workspace.Terrain

		tween_service:Create(beam, TweenInfo.new(1.0,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{
			Width0 = flags.bullet_tracer_thickness,
			Width1 = flags.bullet_tracer_thickness,
		}):Play()

		for i = 1, 5 do
			beam.Transparency = NumberSequence.new(1-i/5, 1-i/5)
			boxhandle.Transparency = 1-i/10
			beam.Color = ColorSequence.new(flags.bullet_tracer_color.Color)
			task.wait()
		end

		task.wait(3)

		for i = 1, 90 do
			beam.Transparency = NumberSequence.new(i/90, i/90)
			boxhandle.Transparency = math.lerp(boxhandle.Transparency, 1, 1/90)
			boxhandle.Size = boxhandle.Size:lerp(Vector3.new(0, 0, boxhandle.Size.Z), i/90)
			beam.Width0 = math.lerp(beam.Width0, 0, 1/90)
			beam.Width1 = math.lerp(beam.Width1, 0, 1/90)
			beam.Color = ColorSequence.new(flags.bullet_tracer_color.Color)
			task.wait()
		end

		a0:Destroy()
		beam:Destroy()
		a1:Destroy()
	end,
	lightning2 = function(from, to, playSound)
		local parts = {}
		local translated = {}
		local origin, originOffset = from, from
		local length = clamp(floor((from - to).Magnitude / 25), 10, 100)

		local scale = .5
		for i = 1, length do
			local new = origin:Lerp(to, i/length)
			local offset = vec3(
				math.random() * math.random(-1,1) * scale,
				math.random() * math.random(-1,1) * scale,
				math.random() * math.random(-1,1) * scale
			)
			local part = Instance.new("Part")
			local length = (origin - new).Magnitude
			part.CFrame = cf(origin, new) * cf(0, 0, -length / 2)
			part.Size = Vector3.new(0, 0, length)
			local sphere = Instance.new("SpecialMesh")
			sphere.MeshType = Enum.MeshType.Sphere
			sphere.Scale = Vector3.new(1, 1, 1)
			sphere.Parent = part
			part.Color = Color3.new(

			)
			local length = (originOffset - (new + offset)).Magnitude
			tween_service:Create(part, TweenInfo.new(0.2 + i/5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0),{
				Size = Vector3.new(flags.bullet_tracer_thickness, flags.bullet_tracer_thickness, length),
				CFrame = cf(originOffset, (new + offset)) * cf(0, 0, -length / 2)
			}):Play()
			tween_service:Create(part, TweenInfo.new(0.05 + i/5,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut,0,false,0),{
				Color = flags.bullet_tracer_color.Color
			}):Play()
			tween_service:Create(part, TweenInfo.new(0.5 + i/5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,false,0),{
				Transparency = 1
			}):Play()
			task.delay(0.5 + i/5,game.Destroy,part)
			part.Material = Enum.Material.Neon
			part.Name = ""
			part.Anchored = true
			part.Transparency = 1 - flags.bullet_tracer_color.Transparency
			part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
			part.Parent = workspace.Terrain
			origin = new
			originOffset = new + offset
		end
	end
}
function draw_bullet(from, to, playSound)
	if not flags.bullet_tracers then return end
	local func = bullets[flags.bullet_tracer_style]
	task.spawn(func, from, to, playSound)
	local sfxId = sfx[flags.killsound_l]
	if sfxId and (playSound == nil or playSound == true) then
		local sound = Instance.new("Sound")
		sound.SoundId = sfxId
		sound.Name = ""
		sound.Volume = flags.sound_volume or 1.0
		sound.PlaybackSpeed = flags.pitchrng_l and math.random(95, 105) / 100 or 1
		sound.PlayOnRemove = true
		sound.Parent = services.soundService
		task.delay(0, game.Destroy, sound)
	end
end

local barsRendered, listAdd = {}, 0
function drawBar(barName, progress, visible, startColor, endColor)
	if not barsRendered[barName] then
		barsRendered[barName] = {
			outerBar = Drawing.new("Square"),
			innerBar = Drawing.new("Square"),
			text = Drawing.new("Text"),
			transparency = 0
		}
	end


	progress = clamp(progress, 0, 1)
	local outerBar, innerBar, text = barsRendered[barName].outerBar, barsRendered[barName].innerBar, barsRendered[barName].text
	local where = camera.ViewportSize / 2 + vec2(0, 45 + listAdd)
	local size, padding = vec2(50, 2), vec2(1, 1)
	outerBar.Position = where - size / 2 - padding
	outerBar.Size = size + padding * 2
	outerBar.Color = rgb(11, 11, 11)

	text.Center = false
	text.Position = where - vec2(size.x / 2, size.Y + 13)
	text.Size = 12
	text.Color = rgb(255, 255, 255)
	text.Outline = true
	text.Text = barName

	innerBar.Size = vec2(math.lerp(0, size.X, progress), size.Y)
	innerBar.Position = where - size / 2 --+ vec2(innerBar.Size.X, 0)

	innerBar.Color = startColor:lerp(endColor, progress)

	barsRendered[barName].transparency = clamp(barsRendered[barName].transparency + (visible and 0.1 or -0.1), 0, 1)

	local visible = barsRendered[barName].transparency ~= 0


	text.Transparency, outerBar.Transparency, innerBar.Transparency =
		barsRendered[barName].transparency,
	barsRendered[barName].transparency,
	barsRendered[barName].transparency
	outerBar.Filled, innerBar.Filled = true, true
	outerBar.Visible, innerBar.Visible, text.Visible = visible, visible, visible

	if visible then
		listAdd += 25
	end
end

local legit
task.spawn(function()
if true then
	legit = window:tab({name = "aimbot"})
	local column = legit:column({})
	local column2 = legit:column({})
	local aimbot = column:section({name = "aimbot", auto_fill = false, size = 0.3})
	local aimbotToggle = aimbot:keybind({name = "enabled", flag = "aimbot_enabled", display = "aimbot", tip = "Bind for the universal aimbot"})
	aimbot:toggle({name = "only rmb", flag = "onlyrmb", tip = "Only update aimbot when right mouse button is held.", wip = true})
	aimbot:dropdown({
		name = "mode",
		flag = "legitmode",
		items = {"normal", "silent", "camera"},
		multi = false,
		scrolling = true
	})
	depend(aimbot:toggle({name = "movement fix", flag = "movefix", tip = "Fixes issues that occur in some games where your movement will break while using the aimbot"}), function() return flags.legitmode ~= "normal" end)
	depend(aimbot:slider({name = "smoothing", min = 1, max = 100, default = 60, interval = 1, suffix = "", flag = "sensitivity"}), function() return flags.legitmode == "normal" end)
	depend(aimbot:toggle({name = "game sens", flag = "mousesens", tip = "Uses your roblox mouse sensitivity instead of the 'smoothing' value."}), function() return flags.legitmode == "normal" end)
	local selection = column2:section({name = "selection", auto_fill = false, size = 0.3})
	selection:slider({name = "fov", min = 0, max = 360, default = 60, interval = 1, suffix = string.char(194,176), flag = "legitfov"})
	depend(selection:toggle({name = "dynamic fov", flag = "dynamicfov"}), function() return flags.legitfov > 0 and not flags.ignorefov end)
	depend(selection:colorpicker({name = "color", flag = "legitfovcolor", color = themes.preset.button, alpha = 0}), function()
		return flags.legitfov > 0 and not flags.ignorefov
	end)
	depend(selection:toggle({name = "ignore fov", flag = "ignorefov"}), function() return flags.legitfov > 0 end)
	depend(selection:toggle({name = "ignore screen check", flag = "ignorescreen"}), function() return flags.legitfov > 0 and not flags.ignorefov end)
	selection:dropdown({
		name = "hitbox",
		flag = "legithitbox",
		items = {"Head", "HumanoidRootPart"},
		multi = false,
		scrolling = true
	})
	--selection:toggle({name = "target npcs", flag = "targetnpcs"})
	selection:toggle({name = "ignore teamcheck", flag = "ignoreteam"})
	local mousetab = column:section({name = "mouse", auto_fill = false, size = 0.3})
	mousetab:toggle({name = "automatically fire", flag = "autofire"})
	mousetab:dropdown({
		name = "click type",
		flag = "mousetype",
		items = {"once", "rapid"},
		multi = false,
		scrolling = true
	})
	depend(mousetab:toggle({name = "mouse delay", flag = "mousedelay"}), function() return flags.autofire end)
	depend(mousetab:slider({name = "delay", min = 10, max = 1000, default = 60, interval = 1, suffix = "ms", flag = "delaymouse"}), function() return flags.autofire and flags.mousedelay end)
	local misc = column:section({name = "misc", auto_fill = false, size = 0.3})
	misc:toggle({name = "no spread", flag = "legit_nospread", beta = true})
	local doubletap
	if restorefunction then
		doubletap = misc:keybind({name = "doubletap", flag = "doubletap", unsafe = true, display = "doubletap", tip = "Abuses a bug in some games that changes the waiting time between shots. This can break your game though."})
	end
	misc:dropdown({
		name = "wallbangs",
		flag = "wallbangs",
		unsafe = true,
		items = {"off", "collision", "origin"},
		multi = false,
		scrolling = true
	})
	depend(misc:toggle({name = "wallbangs collsion bypass", flag = "wallbangs_bypass", tip = "Changes if collision checks should be forced"}), function() return flags.wallbangs ~= "off" end)
	depend(misc:slider({name = "max walls", min = 10, max = 100, default = 15, interval = 1, suffix = "part(s)", flag = "wallbangwalls"}), function() return flags.wallbangs ~= "off" end)

	local elapsedLoad = tick()
	misc:dropdown({
		name = "hit sound",
		flag = "killsound_l",
		items = (function()
			local list = {}
			for soundName in sfx do
				insert(list, soundName)
			end
			return list
		end)(),
		callback = function(name)
			if (tick() - elapsedLoad) < 2 then return end
			local sfxId = sfx[flags.killsound_l]
			if sfxId then
				local sound = Instance.new("Sound")
				sound.SoundId = sfxId
				sound.Name = ""
				sound.Volume = 1
				sound.PlaybackSpeed = flags.pitchrng_l and math.random(95, 105) / 100 or 1
				sound.PlayOnRemove = true
				sound.Parent = coregui
				task.defer(game.Destroy, sound)
			end
		end,
		multi = false,
		scrolling = true
	})
	misc:toggle({name = "bullet sim", flag = "bulletsim", tip = "renders/shows fake bullets of where players are"})
	misc:toggle({name = "pitch randomizer", flag = "pitchrng_l"})
	misc:toggle({name = "player prediction", flag = "playerprediction"})
	local triggerbot = column2:section({name = "triggerbot", auto_fill = false, size = 0.3})

	local triggerbotToggle = triggerbot:keybind({name = "enabled", flag = "trigger_enabled", display = "triggerbot"})
	triggerbot:toggle({name = "magnet", flag = "magnet_flag"})
	triggerbot:toggle({name = "render", flag = "render_trigger"})
	--[[triggerbot:dropdown({
		name = "safe",
		flag = "trigger_safe_flags",
		items = {"anti-pfire", "anti-flick"},
		multi = true,
		scrolling = true
	})]]
	triggerbot:slider({name = "reaction delay", min = 10, max = 1000, default = 400, interval = 1, suffix = "ms", flag = "reaction_delay"})
	triggerbot:slider({name = "fire delay max", min = 10, max = 1000, default = 50, interval = 1, suffix = "ms", flag = "fire_delay"})

	local legit_antiaim = column2:section({name = "antiaim", auto_fill = false, size = 0.3})
	legit_antiaim:toggle({name = "animation desync", flag = "animdesync", unsafe = true})
	local animMap = {
		none = "",
		griddy = "rbxassetid://121966805049108",
		invisible = "rbxassetid://73753845465382",
		rampage = "rbxassetid://73450595652488"
	}
	legit_antiaim:dropdown({
		name = "force anim",
		flag = "forceanim",
		items = (function()
			local list = {}
			for animName, _ in animMap do
				insert(list, animName)
			end
			return list
		end)(),
		default = "none",
		multi = false,
		scrolling = true
	})
	legit_antiaim:dropdown({
		name = "yaw mode",
		flag = "yawmode",
		items = {"off", "spin", "random"},
		multi = false,
		scrolling = true
	})

	do
		local tracked_animations = {}

		local yaw = {
			off = function()
				local char = lp.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hrp and hum then
						hum.AutoRotate = true
					end
				end
			end,
			random = function()
				local char = lp.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-360,360)), 0)
					end
				end
			end,
			spin = function()
				local char = lp.Character
				if char then
					local hrp = char:FindFirstChild("HumanoidRootPart")
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hrp and hum then
						hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(15), 0)
						hum.AutoRotate = false
					end
				end
			end
		}

		run.Heartbeat:Connect(function()
			yaw[flags.yawmode]()

			local char = lp.Character
			if not char then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then return end
			if flags.forceanim and flags.forceanim ~= "none" and animMap[flags.forceanim] then
				if not tracked_animations[hum] or tracked_animations[hum].Animation.AnimationId ~= animMap[flags.forceanim] then
					pcall(function() tracked_animations[hum]:Stop() end)
					local griddyAnim = Instance.new("Animation")
					griddyAnim.AnimationId = animMap[flags.forceanim]
					local animTrack = hum:LoadAnimation(griddyAnim)
					animTrack.Priority = Enum.AnimationPriority.Action
					animTrack:Play()
					tracked_animations[hum] = animTrack
				end
				for _, animTrack in hum:GetPlayingAnimationTracks() do
					if animTrack.Animation and animTrack.Animation.AnimationId:find(animMap[flags.forceanim]) then
						continue
					end
					animTrack:Stop()
				end
				return
			end

			if not flags.animdesync then
				for _, animTrack in tracked_animations do
					if typeof(animTrack) == "Instance" then
						animTrack:Stop()
					end
					tracked_animations[_] = nil
				end
				return
			end


			--[[
			for _, animTrack in hum:GetPlayingAnimationTracks() do
				if not tracked_animations[animTrack] then
					animTrack:AdjustSpeed(0)
					tracked_animations[animTrack] = tick()
				elseif tick() - tracked_animations[animTrack] > 1 then
					local elapsed = tick() - tracked_animations[animTrack]
					animTrack:AdjustSpeed(elapsed > 2 and 1000 * math.random(-1, 1) or 0)
					if elapsed > 3 then
						animTrack:AdjustSpeed(0/0)
						tracked_animations[animTrack] = tick()
					end
				end
			end]]
			for _, animTrack in hum:GetPlayingAnimationTracks() do
				if not tracked_animations[animTrack] then
					animTrack:AdjustSpeed(0)
					tracked_animations[animTrack] = tick()
				elseif tick() - tracked_animations[animTrack] > 0.25 then
					local elapsed = tick() - tracked_animations[animTrack]
					animTrack:AdjustSpeed(0)
					if elapsed > 1 + math.random() - math.random() / 2 then
						animTrack:AdjustSpeed((tick() - tracked_animations[animTrack]) + 1)
						tracked_animations[animTrack] = tick()
					end
				end
			end
		end)
	end

	local legit_fakelag = column2:section({name = "fakelag", auto_fill = false, size = 0.3})
	local fakelag = legit_fakelag:keybind({name = "enabled", flag = "fakelag", display = "fake lag"})
	legit_fakelag:slider({name = "ticks", min = 1, max = 1000, default = 14, interval = 1, suffix = "t", flag = "ticks"})
	seraphAcc.rnet_exists = pcall(function() raknet.clear_all_send_hooks() end)
	if seraphAcc.rnet_exists then
		task.spawn(function()
			local saved = cf()
			local desync = legit_fakelag:keybind({name = "desync", flag = "desync", display = "desync"})
			legit_fakelag:toggle({name = "render", flag = "renderdesync"})
			local frozen = {}
			raknet.clear_all_send_hooks()
			raknet.add_send_hook(function(packetData)
				if buffer.readu8(packetData, 0) == 0x1B then
					if (library.desyncPlayer or desync.active) and frozen[6] then
						for i = 5, 8 do
							buffer.writeu8(packetData, i, frozen[i])
						end
					else
						pcall(function()
							saved = lp.Character.HumanoidRootPart.CFrame
						end)
						for i = 5, 8 do
							frozen[i] = buffer.readu8(packetData, i)
						end
					end
				end
				return true
			end)

			local obj = create('BoxHandleAdornment', {
				AlwaysOnTop = true,
				Parent = coregui,
				Adornee = workspace.Terrain,
				Size = Vector3.new(2,2,1),
				Color3 = themes.preset.button_alt,
				Transparency = 0.5,
				AdornCullingMode = Enum.AdornCullingMode.Never,
				ZIndex = 10,
				Visible = true
			})

			local line = create('BoxHandleAdornment', {
				AlwaysOnTop = true,
				Parent = coregui,
				Adornee = workspace.Terrain,
				Size = Vector3.new(2,2,1),
				Color3 = themes.preset.button_alt,
				Transparency = 0.5,
				AdornCullingMode = Enum.AdornCullingMode.Never,
				ZIndex = 10,
				Visible = true
			})

			run.RenderStepped:Connect(function()
				obj.Visible = ((library.desyncPlayer or desync.active) and frozen[6] and flags.renderdesync)
				obj.CFrame = saved

				local focus = camera.Focus.Position  - vec3(0,1.5,0)
				line.CFrame = cf(focus, saved.Position) * cf(0,0,-(focus - saved.Position).Magnitude/2)
				line.Size = Vector3.new(0.1, 0.1, (focus - saved.Position).Magnitude)
				line.Visible = ((library.desyncPlayer or desync.active) and frozen[6] and flags.renderdesync)
			end)
		end)
	end
	local fakeLagTicks = 0

	local reactionTime = 0

	local triggerbotDebug = Drawing.new("Text")
	triggerbotDebug.Position = workspace.CurrentCamera.ViewportSize / 2 + vec2(0, 100)
	triggerbotDebug.Visible = true
	triggerbotDebug.Outline = true
	triggerbotDebug.Center = true
	triggerbotDebug.Font = 3
	triggerbotDebug.Size = 15
	triggerbotDebug.Text = ""

	local mousePressed = false

	local resetCollision = {}

	function getTarget()
		local targetPart
		local closestDistance = math.huge
		local targets = services.players:GetPlayers()
		for _, player in targets do
			if player == lp then continue end
			local char = player.Character
			if not char then continue end
			if (not flags.ignoreteam) and player.Team and player.Team.Name ~= "Neutral" and lp.Team then
				if player.Team and (player.Team.Name == lp.Team.Name) then continue end
			end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then continue end
			if hum.Health <= 0 then continue end
			if char:FindFirstChildOfClass("ForceField") then print("hi im forcefield") continue end
			local bonePart = char:FindFirstChild(flags.legithitbox)
			if player_list[player.Name] and player_list[player.Name].ignore_player then print("hi im ignored") continue end
			if not bonePart then continue end
			local screenPoint, onScreen = worldToScreenPoint(bonePart)
			if flags.wallbangs == "collision" then
				local checks, hitPlayer = 0, false
				repeat
					checks += 1
					if flags.wallbangs_bypass then
						params.RespectCanCollide = true
					end
					local canSee = workspace:Raycast(workspace.CurrentCamera.Focus.Position, -(workspace.CurrentCamera.Focus.Position - bonePart.Position), params)
					if not canSee then continue end
					local isNotPlayer = canSee.Instance and (not canSee.Instance:IsDescendantOf(bonePart.Parent) and canSee.Instance ~= bonePart and canSee.Instance.Parent.Name ~= bonePart.Parent.Name)
					if canSee.Instance and isNotPlayer then
						if canSee.Instance.CanCollide then
							insert(resetCollision, {canSee.Instance, true})
							canSee.Instance.CanCollide = false
						end
						insert(params.FilterDescendantsInstances, canSee.Instance)
					elseif canSee.Instance and not isNotPlayer then
						hitPlayer = true
						--print(hitPlayer, checks)
					end
					--print(canSee.Instance, checks, hitPlayer)
				until (checks > flags.wallbangwalls or hitPlayer)
				if not hitPlayer then continue end
			elseif flags.wallbangs == "origin" then

			else
				local canSee = workspace:Raycast(workspace.CurrentCamera.Focus.Position, -(workspace.CurrentCamera.Focus.Position - bonePart.Position), params)
				if not canSee then continue end
				if canSee.Instance and (not canSee.Instance:IsDescendantOf(bonePart.Parent) and canSee.Instance ~= bonePart and canSee.Instance.Parent.Name ~= bonePart.Parent.Name) then
					continue
				end
			end


			local diff = (vec2(mouse.X, mouse.Y) - screenPoint).Magnitude
			if flags.ignorefov then
				diff, onScreen = flags.legitfov, onScreen
			end
			if flags.ignorescreen then
				onScreen = true
			end
			local dyn = math.clamp(flags.dynamicfov and (70 / camera.FieldOfView) or 0, 0, 25) * 65
			local canIShoot = (diff <= (flags.legitfov + dyn) and onScreen)


			if (canIShoot and (flags.ignorefov or diff <= closestDistance))  then --  and Distance < ClosestDistance
				targetPart = bonePart
				closestDistance = diff
			end
		end
		return targetPart
	end

	local circle = Drawing.new("Circle")
	circle.Filled = false
	circle.NumSides = 32
	circle.Transparency = 0.7

	local wasLockedFully = false

	local function sus(f,...)
		task.desynchronize()
		task.synchronize()
		return f(...)
	end
	function tdf(c, f, ...)
		if c == 0 then
			return f(...)
		end

		return task.defer(tdf, c-1,f,...)
	end

	--[[mouse.Button1Down:Connect(function()
		if not flags.silentlock then return end
		local targetHere = getTarget()
		local cam = workspace.CurrentCamera
		if targetHere then
			params.FilterDescendantsInstances = {lp.Character, workspace.CurrentCamera}
			local mag = (workspace.CurrentCamera.Focus.Position - targetHere.Position).Magnitude
			local canSee = workspace:Raycast(workspace.CurrentCamera.Focus.Position, -(workspace.CurrentCamera.Focus.Position - targetHere.Position), params)
			if not canSee then return end
			if canSee.Instance and (not canSee.Instance:IsDescendantOf(targetHere.Parent) and canSee.Instance ~= targetHere and canSee.Instance.Parent.Name ~= targetHere.Parent.Name) then
				return --print('lol', canSee.Instance)
			end
			local hrp = targetHere.Parent:FindFirstChild'HumanoidRootPart'
			if not hrp then return end
			local hum = targetHere.Parent:FindFirstChildOfClass'Humanoid'
			if not hum then return end
			local predictionScale = (flags.playerprediction and 1 or 0)
			local lHrp = lp.Character:FindFirstChild("HumanoidRootPart")
			if not lHrp then return end
			local dt = globals.frametime
			local where = (targetHere.CFrame + (hrp.AssemblyLinearVelocity * (dt * predictionScale * (hum.WalkSpeed / 8))) - (lHrp.AssemblyLinearVelocity * dt * 2)).Position
			local targetScreen, onScreen = cam:WorldToViewportPoint(where)
			targetScreen = Vector2.new(targetScreen.X, targetScreen.Y)
			local currentMouse = targetScreen - (uis:GetMouseLocation() - services.guiService:GetGuiInset())
			local sens = uis.MouseDeltaSensitivity / 10

			local cam = workspace.CurrentCamera
			local mode = lp.CameraMode
			local ccf = cam.CFrame
			local oldAngle = ccf.Rotation
			local old = ccf
			local plane = cam.NearPlaneZ
			--setscriptable (mouse, "Hit", true)
			--setscriptable (mouse, "Target", true)

			local original; original = hookmetamethod(mouse, "__index", function(...)
				local key = select(2, ...)
				if key == "Hit" then
					return CFrame.new(canSee.Position)
				elseif key == "Target" then
					return targetHere
				end
				return original(...)
			end)

			--setscriptable (mouse, "Hit", false)
			--setscriptable (mouse, "Target", false)
			cam.CFrame = cf(cam.Focus.Position, where)
			tdf(80,function()
				hookmetamethod(mouse, "__index", original)
				lp.CameraMode = mode
				cam.CFrame = cf(ccf.Position) * oldAngle
				cam.CFrame = old
			end)
		end
	end)]]

	-- arsenal support

	workspace.DescendantAdded:Connect(function(v)
		task.wait()
		if v:IsA("ObjectValue") and v.Value == lp and v.Name == "creator" then
			local damage = v:FindFirstChild("Damage")
			if not v:FindFirstChild("where") then return end
			local head = (lp.Character and lp.Character:FindFirstChild("Head") or workspace.CurrentCamera.Focus).Position
			local where
			local parent = v.Parent
			pcall(function() where = (parent:FindFirstChild("HumanoidRootPart") or parent:FindFirstChild("Head") or parent:FindFirstChild("UpperTorso") or parent:FindFirstChild("Torso") or parent:GetPivot()).Position end)
			pcall(function() if not where then where = v.Parent.RootPart.Position end end)
			pcall(function()
				local hum
				if parent:IsA("Humanoid") then hum = parent
				else hum = parent:FindFirstChildOfClass("Humanoid") end
				if hum.Health == 0 and flags.killsay then

				end
			end)
			if where then draw_bullet(head, where) end
		end
	end)

	local mouseDelay = 0
	local lastRender = tick() - 2
	local mouseAimbotPressed

	local listAdd = 0

	tickShift, shift, noSpreadHook = 0, false, false
	local old, hookedIt = function(t)
		if oldTick and shift and lp.Character then
			return math.huge
		end
		return oldTick()
	end, false


	local dt_ticks = 0
	local function aimBot(dt)
		if restorefunction then
			if doubletap.active and not hookedIt then
				hookedIt = true
				oldTick = hookfunction(tick, old)
				hookfunction(task.wait, function(t)
					local t = t or 1/60
					local b = t
					repeat
						t -= run.RenderStepped:Wait()
					until t <= 0 or shift
					return b
				end)
			elseif not doubletap.active and hookedIt then
				hookedIt = false
				oldTick = nil
				restorefunction(tick)
				restorefunction(task.wait)
			end

			if flags.legit_nospread and not noSpreadHook then
				noSpreadHook = true
				local old; old = hookfunction(math.random, function()
					return 0
				end)
			elseif not flags.legit_nospread and noSpreadHook then
				noSpreadHook = false
				restorefunction(math.random)
			end
		end

		if not lp.Character then shift = false return end

		if mouseAimbotPressed then mouseAimbotPressed = false mouse1release() shift = false end
		local is_focused = isrbxactive()
		if not is_focused then
			return
		end
		if not aimbotToggle.active then 
			drawBar("doubletap", 0, false, themes.preset.button_alt, themes.preset.button_alt)
			drawBar("delay", 0, false, themes.preset.button_alt, themes.preset.button_alt) 
			circle.Transparency = clamp(circle.Transparency - dt * 10, 0, 1) 
			circle.Radius = math.lerp(circle.Radius, 1, correctAlpha(0.1, dt)) 
			return 
		end

		if doubletap.active then
			dt_ticks += dt * 5
			for i,v in workspace.CurrentCamera:GetDescendants() do
				pcall(function()
					for _, track in v:GetPlayingAnimationTracks() do
						track:AdjustSpeed(dt_ticks >= 0.5 and 10 or 1)
					end
				end)
			end
			if dt_ticks >= 1.0 then dt_ticks = 0 end
			drawBar("doubletap", clamp(dt_ticks, 0, 1), true, rgb(255,0,0), rgb(0,255,0))
		else
			drawBar("doubletap", 0, false, themes.preset.button_alt, themes.preset.button_alt)
		end


		circle.Position = uis:GetMouseLocation()
		circle.Radius = math.lerp(circle.Radius, flags.legitfov + math.clamp(flags.dynamicfov and (70 / camera.FieldOfView) or 0, 0, 25) * 65, correctAlpha(0.75, dt))
		circle.Color = flags.legitfovcolor.Color
		circle.Transparency = math.lerp(circle.Transparency, 0.7 * (flags.legitfovcolor.Transparency), correctAlpha(0.25, dt))
		circle.Visible = not flags.ignorefov

		listAdd = 0

		if library.gui_visible == true then return end
		local ignored = {}
		for i,v in resetCollision do
			insert(ignored, v[1])
			pcall(function() v[1].CanCollide = v[2] end)
		end
		table.clear(resetCollision)

		local targetHere = getTarget()
		local cam = workspace.CurrentCamera
		if targetHere and not fakelag.active and not gui_service.MenuIsOpen then
			local mouseRequired = flags.autofire and flags.mousetype ~= "off" and flags.mousedelay
			if mouseRequired then
				mouseDelay += dt
				local prog = clamp(mouseDelay / (flags.delaymouse / 1000), 0, 1)
				--print(mouseDelay, flags.delaymouse / 1000)
				drawBar("delay", prog, true, rgb(255,0,0), rgb(0,255,0))
			else
				drawBar("delay", 0, false, themes.preset.button_alt, themes.preset.button_alt)
			end
			params.RespectCanCollide = false
			params.FilterDescendantsInstances = {lp.Character, workspace.CurrentCamera, table.unpack(ignored)}
			local mag = (workspace.CurrentCamera.Focus.Position - targetHere.Position).Magnitude
			--[[local canSee = workspace:Raycast(workspace.CurrentCamera.Focus.Position, -(workspace.CurrentCamera.Focus.Position - targetHere.Position), params)
			if not canSee then return  end
			if canSee.Instance and (not canSee.Instance:IsDescendantOf(targetHere.Parent) and canSee.Instance ~= targetHere and canSee.Instance.Parent.Name ~= targetHere.Parent.Name) then
				return 
			end]]
			local hrp = targetHere.Parent:FindFirstChild'HumanoidRootPart'
			if not hrp then return end
			local hum = targetHere.Parent:FindFirstChildOfClass'Humanoid'
			if not hum then return end
			local predictionScale = (flags.playerprediction and 1 or 0)
			local lHrp = lp.Character:FindFirstChild("HumanoidRootPart")
			if not lHrp then return end
			local where = targetHere.Position
			local targetScreen, onScreen = cam:WorldToViewportPoint(where)
			targetScreen = Vector2.new(targetScreen.X, targetScreen.Y)
			local currentMouse = targetScreen - (uis:GetMouseLocation() - gui_service:GetGuiInset())
			local sens = flags.mousesens and uis.MouseDeltaSensitivity / 10 or flags.sensitivity / 100

			local targetPos = where

			-- *(v) ayo
			local pred = targetHere.Position + (hrp.Velocity * globals.frametime) * services.stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 10

			if flags.playerprediction then
				targetPos = pred
			end

			local delayed = (not mouseRequired)
			if delayed then
				delayed = mouseDelay < flags.delaymouse / 1000
			end

			if flags.autofire and not flags.mousedelay and flags.mousetype ~= "off" then
				delayed = false
			end

			if flags.legitmode == "camera" then
				--[[if (currentMouse.Magnitude <= 5 or wasLockedFully) and flags.forcelock then
					mousemoverel(currentMouse.x * (sens * 2), currentMouse.y * (sens * 2))
					wasLockedFully = true
				else
					mousemoverel(currentMouse.x * sens, currentMouse.y * sens)
					wasLockedFully = false
				end]]
				camera.CFrame = cf(camera.CFrame.Position, targetPos)
				if flags.wallbangs == "origin" then
					camera.CFrame = cf(targetPos + vec3(0, 1, 0), targetPos)
					local where = lHrp.CFrame
					lHrp.CFrame = cf(targetPos + vec3(0, 2, 0))
					task.spawn(function()
						lHrp.CFrame = where
					end)
				end
				if not mouseAimbotPressed and not delayed and flags.autofire then
					if flags.mousetype ~= "off" then mouse1press() mouseAimbotPressed = true shift = true end
					if tick() - lastRender > 0.1 and flags.bulletsim then lastRender = tick() draw_bullet(camera.Focus.Position, where) end
				end
			elseif flags.legitmode == "silent" then
				local ccf = camera.CFrame
				camera.CFrame = cf(camera.Focus.Position, targetPos)
				if flags.wallbangs == "origin" then
					camera.CFrame = cf(targetPos + vec3(0, 1, 0), targetPos)
				end
				if flags.autostop == "zero full-stop" then
					lHrp.AssemblyLinearVelocity = vec3(0, lHrp.AssemblyLinearVelocity.Y, 0)
				elseif flags.autostop == "full-stop" then
					lHrp.AssemblyLinearVelocity = vec3(0, 0, 0)
				end
				if not mouseAimbotPressed and not delayed then
					if flags.mousetype ~= "off" then mouse1press() mouseAimbotPressed = true shift = true end
					if tick() - lastRender > 0.1 and flags.bulletsim then lastRender = tick() draw_bullet(camera.Focus.Position, where) end
				end
				oldData = ccf
			else
				local moveVector = currentMouse.Unit * (currentMouse.Magnitude * sens)
				mousemoverel(moveVector.x, moveVector.y)
				if not mouseAimbotPressed and not delayed and flags.autofire then
					if flags.mousetype ~= "off" then mouse1press() mouseAimbotPressed = true shift = true end
					if tick() - lastRender > 0.1 and flags.bulletsim then lastRender = tick() draw_bullet(camera.Focus.Position, where) end
				end
			end

		else
			--drawBar("doubleTapProgress", 0, false, themes.preset.button_alt, themes.preset.button_alt)
			drawBar("delay", 0, false, themes.preset.button_alt, themes.preset.button_alt)
			mouseDelay = 0
		end
	end

	local function triggerBot(dt)
		local is_focused = isrbxactive()
		if not is_focused then
			return
		end
		triggerbotDebug.Position = workspace.CurrentCamera.ViewportSize / 2 + vec2(0, 100)
		if not triggerbotToggle.active then
			reactionTime = 0
			triggerbotDebug.Transparency = math.clamp(triggerbotDebug.Transparency - dt * 5, 0, 1)
			if mousePressed then mouse1release() mousePressed = false end
			triggerbotDebug.Text = #triggerbotDebug.Text > 0 and string.sub(triggerbotDebug.Text, 1, #triggerbotDebug.Text - 1) or ""
			return
		end
		triggerbotDebug.Transparency = math.clamp(triggerbotDebug.Transparency + dt * 5, 0, 1)
		local target = mouse.Target
		if target == nil then
			reactionTime = 0
			if mousePressed then mouse1release() mousePressed = false end
			triggerbotDebug.Text = "[ no target ]"
			return
		end
		local parent = target.Parent
		local player = services.players:FindFirstChild(parent.Name)
		if not player then
			reactionTime = 0
			if mousePressed then mouse1release() mousePressed = false end
			triggerbotDebug.Text = "[ no target ]"
			return
		end

		if player.Team.Name ~= "Neutral" and player.Team.Name == lp.Team.Name then
			triggerbotDebug.Text = "[ no target ]"
			if mousePressed then mouse1release() mousePressed = false end
			return
		end

		reactionTime += dt

		local value = math.floor( (reactionTime / (flags.reaction_delay / 1000)) * 10 ) / 10
		triggerbotDebug.Text = `[ target found, {value} ]`
		if reactionTime >= flags.reaction_delay / 1000 then
			mouse1press()
			mousePressed = true
			reactionTime -= flags.fire_delay / 1000

			if (flags.magnet_flag) then
				local targetScreen, onScreen = worldToScreenPoint(mouse.Target.CFrame)

				local currentMouse = targetScreen - uis:GetMouseLocation()
				mousemoverel(currentMouse.x / 5, currentMouse.y / 5)
			end
		else
			mouse1release()
			mousePressed = false
		end
	end
	local function fakeLag(dt)
		if not fakelag.active then 
			settings():GetService("NetworkSettings").IncomingReplicationLag = 0
			fakeLagTicks = 0
			services.networkClient:SetOutgoingKBPSLimit(0)
			return 
		end
		fakeLagTicks = fakeLagTicks + 1
		if fakeLagTicks >= flags.ticks then
			settings():GetService("NetworkSettings").IncomingReplicationLag = 0
			fakeLagTicks = 0
			services.networkClient:SetOutgoingKBPSLimit(0)
		else
			settings():GetService("NetworkSettings").IncomingReplicationLag = (fakeLagTicks % 5 == 0) and 1 or 0
			services.networkClient:SetOutgoingKBPSLimit(1)
		end
	end

	local loadTime = tick()
	cons[#cons + 1] = services.runService.Stepped:Connect(function(_, dt)
		thread(fakeLag, dt)
		thread(triggerBot, dt)
		thread(aimBot, dt)
	end)
	cons[#cons + 1] = services.runService.Heartbeat:Connect(function()
		local camera = workspace.CurrentCamera
		if oldData then
			local campos = camera.Focus.Position
			--draw_bullet(campos, mouse.Hit.Position)
			tdf(80, function()
				camera.CFrame = oldData
				oldData = nil
			end)
		end
	end)
end
end)
task.wait()
--[[
section:toggle({name = "enabled", flag = "toggle_flag"})
section:keybind({name = "aim key"})
section:toggle({name = "silent", flag = "toggle_flag"})
section:slider({name = "smooth", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})

section2:slider({name = "fov", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
section2:slider({name = "max distance", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
section2:toggle({name = "target npcs", flag = "toggle_flag"})
section2:dropdown({name = "hitbox", flag = "distance_priority", items = {"head","chest","legs"}, default = "head"})
section2:slider({name = "hs after x shots", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})

local column = rage:column({})
local section = column:section({name = "weapon modifications"})
local section2 = column:section({name = "other"})
section:toggle({name = "no-spread", flag = "toggle_flag"})
section:slider({name = "recoil multiplier", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
section:slider({name = "bullet thickness", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
section:slider({name = "bullet speed", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})

local column = rage:column({})
local section = column:section({name = "weapon modifications"})
local section2 = column:section({name = "other"})
section:toggle({name = "no-spread", flag = "toggle_flag"})
section:slider({name = "recoil multiplier", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
section:slider({name = "bullet thickness", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
section:slider({name = "bullet speed", min = 0, max = 10, default = 10, interval = 0.1, suffix = "", flag = "abc"})
]]
local visuals = window:tab({name = "visuals"})
local column = visuals:column({})
local column2 = visuals:column({})

local editor = column:section({name = "selection", autofill = true}):list({
	name = "view",
	flag = "editor_list",
	size = 80,
	items = {
		"players",
		"self",
		"world",
		"misc"
	},
})
local left_column = column
column = column2
local section = column:section({name = "chams", size = 0.3})
depend(section, function()
	return flags.editor_list == "players"
end)
local self_secondary
section:toggle({name = "enabled", flag = "enemy_chams", tip = "Toggles the enemy chams"})
section:toggle({name = "animation", flag = "enemy_animated", callback = function()
	if not self_secondary then return end
	self_secondary.show_element(flags.enemy_animated)
end,})
section:toggle({name = "enemy only", flag = "enemy_only"})
section:dropdown({
	name = "style",
	flag = "chams_enemy_material",
	items = {"breathe", "normal", "inverted", "occluded"},
	multi = false,
	scrolling = true,
	callback = function()
		chamsContainer:ClearAllChildren()
		holder:ClearAllChildren()
		viewport:ClearAllChildren()
	end
})
section:colorpicker({name = "primary color", flag = "enemy_primary_color", color = themes.preset.button, alpha = 0})
self_secondary = section:colorpicker({name = "secondary color", flag = "enemy_secondary_color", color = themes.preset.button_alt, alpha = 0})
self_secondary.show_element(flags.enemy_animated)
local section = column:section({name = "bullet tracers", size = 0.3})
depend(section, function()
	return flags.editor_list == "world"
end)
section:toggle({name = "enabled", flag = "bullet_tracers"})
section:colorpicker({name = "color", flag = "bullet_tracer_color", color = color(1,0,0), alpha = 0})
section:slider({name = "thickness", min = 0.01, max = 1, default = 0.03, interval = 0.01, suffix = "", flag = "bullet_tracer_thickness"})
section:dropdown({
	name = "style",
	flag = "bullet_tracer_style",
	items = {"line", "smooth", "spiral", "lightning", "lightning2"},
	multi = false,
	scrolling = true
})
local shoot_effects = column:section({name = "shoot effects", size = 0.3})
shoot_effects:toggle({name = "enabled", flag = "shoot_effects"})
shoot_effects:colorpicker({name = "color", flag = "shoot_effects_color", color = themes.preset.button, alpha = 0})
shoot_effects:slider({name = "lifetime", min = 4, max = 12, default = 4, interval = 0.1, suffix = "s", flag = "shoot_effects_lifetime"})
depend(shoot_effects, function()
	return flags.editor_list == "world"
end)
local fog = column:section({name = "fog", size = 0.3})
depend(fog, function()
	return flags.editor_list == "world"
end)
local saved = {FogColor = lighting.FogColor, FogEnd = lighting.FogEnd, FogStart = lighting.FogStart, ColorShift_Top = lighting.ColorShift_Top, ColorShift_Bottom = lighting.ColorShift_Bottom}
local baseSignals = {}
local atmosphere = Instance.new("Atmosphere")
fog:dropdown({
	name = "type",
	flag = "fog_tab",
	items = {"fog", "atmosphere"},
	multi = false,
	scrolling = true,
	default = "atmosphere"
})
local collected_atmospheres = {}
fog:toggle({name = "enabled", flag = "atmosphere_enabled", callback = function(t)
	task.spawn(function()
		if not t then
			for _, signal in baseSignals do signal:Disconnect() end
			for _, atmosphere in collected_atmospheres do
				pcall(function() atmosphere.Parent = lighting end)
			end
			table.clear(baseSignals)
			atmosphere.Parent = nil
			for i, v in saved do
				lighting[i] = v
			end
		else
			saved = {FogColor = lighting.FogColor, FogEnd = lighting.FogEnd, FogStart = lighting.FogStart, ColorShift_Top = lighting.ColorShift_Top, ColorShift_Bottom = lighting.ColorShift_Bottom}
			baseSignals[#baseSignals + 1] = run.Heartbeat:Connect(function()
				if flags.fog_tab == "atmosphere" then 
					atmosphere.Parent = nil
					atmosphere.Parent = lighting
				else
					atmosphere.Parent = nil
					for _, atmosphere in lighting:GetChildren() do
						if atmosphere:IsA("Atmosphere") then
							table.insert(collected_atmospheres, atmosphere)
							atmosphere.Parent = nil
						end
					end
					local newList = {}
					for name in saved do
						newList[name] = flags["fog_" .. name:lower()]
						if typeof(newList[name]) == "table" then newList[name] = newList[name].Color end
					end
					for entryName, property in newList do
						lighting[entryName] = property
					end
				end
			end)
		end
	end)
end})
for entryName, property in saved do
	local entry
	if typeof(property) == "Color3" then
		entry = fog:colorpicker({name = entryName:lower():gsub("_", " "), flag = "fog_" .. entryName:lower(), color = property, alpha = 0, callback = function()
			lighting[entryName] = flags["fog_" .. entryName:lower()].Color
		end})
	else
		entry = fog:slider({name = entryName:lower():gsub("_", " "), min = 0, max = 10000, default = property, interval = 1, suffix = "", flag = "fog_" .. entryName:lower(), callback = function()
			lighting[entryName] = flags["fog_" .. entryName:lower()]
		end})
	end
	if entry ~= nil then
		depend(entry, function()
			return flags.fog_tab == "fog"
		end)
	end
end
depend(fog:slider({name = "offset", min = 0, max = 1, default = 0, interval = 1e-2, suffix = "", flag = "fog_offset", callback = function()
	atmosphere.Offset = flags.fog_offset
end}), function()
	return flags.fog_tab == "atmosphere"
end)
depend(fog:slider({name = "density", min = 0, max = 1, default = 0.395, interval = 1e-2, suffix = "", flag = "fog_density", callback = function()
	atmosphere.Density = flags.fog_density
end}), function()
	return flags.fog_tab == "atmosphere"
end)
depend(fog:colorpicker({name = "color", flag = "fog_color", color = rgb(199, 170, 107), alpha = 0, callback = function()
	atmosphere.Color = flags.fog_color.Color
end}), function()
	return flags.fog_tab == "atmosphere"
end)
depend(fog:colorpicker({name = "decay", flag = "fog_decay", color = rgb(92, 60, 13), alpha = 0, callback = function()
	atmosphere.Decay = flags.fog_decay.Color	
end}), function()
	return flags.fog_tab == "atmosphere"
end)
depend(fog:slider({name = "glare", min = 0, max = 1, default = 0, interval = 1e-2, suffix = "", flag = "fog_glare", callback = function()
	atmosphere.Glare = flags.fog_glare
end}), function()
	return flags.fog_tab == "atmosphere"
end)
depend(fog:slider({name = "haze", min = 0, max = 1, default = 0, interval = 1e-2, suffix = "", flag = "fog_haze", callback = function()
	atmosphere.Haze = flags.fog_haze
end}), function()
	return flags.fog_tab == "atmosphere"
end)
local section = left_column:section({name = "environment", size = 0.3})
depend(section, function()
	return flags.editor_list == "world"
end)
if game.GameId == 113491250 then
	section:toggle({name = "no sway", flag = "pf_nosway"})
	section:toggle({name = "no camera sway", flag = "pf_nocamerasway"})
end
do
	section:slider({name = "aspect ratio", min = 70, max = 120, default = 100, interval = 1, suffix = "%", flag = "stretch", wip = game.GameId == 113491250})
	section:toggle({name = "awesome mode", flag = "awesomestuff"})
	globalStretch = {R00 = 1, R01 = 0, R02 = 0, R10 = 0, R11 = 1, R12 = 0, R20 = 0, R21 = 0, R22 = 1}
	if game.GameId ~= 113491250 then
		run.RenderStepped:Connect(function()
			local stretch = flags.stretch / 100
			if stretch ~= 1 then return end
			local c = camera.CFrame

			local x, y, z,
			R00, R01, R02,
			R10, R11, R12,
			R20, R21, R22 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

			if flags.awesomestuff then
				stretch = 1 + .1 * math.cos(elapsed_ticks / 10)
			end

			R00 = stretch
			R11 = 1 - (stretch - 1) / 2
			R22 = 1

			globalStretch.R00, globalStretch.R11 = R00, R11

			camera.CFrame *= CFrame.new(
				x, y, z,
				R00, R01, R02,
				R10, R11, R12,
				R20, R21, R22
			)

		end)
	else
		--[[local active
		function connectCamera()
			camera:GetPropertyChangedSignal("CFrame"):Connect(function()
				if active then return end
				active = true
				local stretch = flags.stretch / 100
				local c = camera.CFrame

				local x, y, z,
				R00, R01, R02,
				R10, R11, R12,
				R20, R21, R22 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

				if flags.awesomestuff then
					stretch = 1 + .1 * math.cos(elapsed_ticks / 10)
				end

				R00 = stretch
				R11 = 1 - (stretch - 1) / 2
				R22 = 1

				globalStretch.R00, globalStretch.R11 = 1, 1

				camera.CFrame *= CFrame.new(
					x, y, z,
					R00, R01, R02,
					R10, R11, R12,
					R20, R21, R22
				)

				warn("hii")

				active = false
			end)
		end

		--connectCamera()
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			camera = workspace.CurrentCamera
			--connectCamera()
		end)

		for i = -15, 15, 1 do
			run:BindToRenderStep("camera_____00000", Enum.RenderPriority.Camera.Value + i, (function()
				local stretch = flags.stretch / 100
				local c = camera.CFrame

				local x, y, z,
				R00, R01, R02,
				R10, R11, R12,
				R20, R21, R22 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

				if flags.awesomestuff then
					stretch = 1 + .1 * math.cos(elapsed_ticks / 10)
				end

				R00 = stretch
				R11 = 1 - (stretch - 1) / 2
				R22 = 1

				globalStretch.R00, globalStretch.R11 = 1, 1

				camera.CFrame *= CFrame.new(
					x, y, z,
					R00, R01, R02,
					R10, R11, R12,
					R20, R21, R22
				)

			end))
		end]]
		local function applyAspectRatio(v)
			local ratioy = 1
			local ratiox = flags.stretch / 100

			local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = v:GetComponents()

			r01, r11, r21 = r01 * ratioy, r11 * ratioy, r21 * ratioy
			r00, r10, r20 = r00 * ratiox, r10 * ratiox, r20 * ratiox

			return CFrame.new(x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
		end
		local function isCameraCFrame(self, k)
			return self == camera and k == "CFrame"
		end
		local oldNewindex; oldNewindex = hookfunction(getrawmetatable(camera).__newindex, newcclosure(function(self, k, v)
			if isCameraCFrame(self, k) then
				v = applyAspectRatio(v)
			end
			return oldNewindex(self, k, v)
		end))
	end
	local applying = false



end
section:dropdown({
	name = "skybox",
	flag = "world_skybox",
	items = (function()
		local items = {"off"}
		for name in skyboxes do
			items[#items + 1] = name
		end
		return items
	end)(),
	default = 'off',
	multi = false,
	scrolling = true,
})
--[[
section:toggle({name = "disable effects", flag = "world_noeffects"})
]]

local cache = {}
section:dropdown({
	name = "nightmode",
	flag = "world_nightmode",
	items = {"off", "fullbright", "nightmode"},
	multi = false,
	scrolling = true,
	callback = function()
		if flags.world_nightmode == 'nightmode' then
			for _,v in workspace:GetDescendants() do
				if v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") then
					if not v:GetAttribute("seraphBrightness") then
						v:SetAttribute("seraphBrightness", v.Brightness)
					end
					v.Brightness = v:GetAttribute("seraphBrightness") * .3
				end
			end
		elseif flags.world_nightmode == 'fullbright' then
			for _,v in workspace:GetDescendants() do
				if v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") then
					if not v:GetAttribute("seraphBrightness") then
						v:SetAttribute("seraphBrightness", v.Brightness)
					end
					v.Brightness = v:GetAttribute("seraphBrightness") * .6
				end
			end
		else
			for _,v in workspace:GetDescendants() do
				if v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") then
					if not v:GetAttribute("seraphBrightness") then
						v:SetAttribute("seraphBrightness", v.Brightness)
					end
					v.Brightness = v:GetAttribute("seraphBrightness")
				end
			end
		end
	end,
})
workspace.DescendantAdded:Connect(function(v)
	if flags.world_nightmode == "off" then return end
	if not v:IsA("PointLight") or not v:IsA("SurfaceLight") or not v:IsA("SpotLight") then return end
	if not v:GetAttribute("seraphBrightness") then
		v:SetAttribute("seraphBrightness", v.Brightness)
	end
	v.Brightness = v:GetAttribute("seraphBrightness") * .3
end)
--[[
section:dropdown({
	name = "particles",
	flag = "world_particles",
	items = {"off", "ash", "snow"},
	multi = false,
	scrolling = true
})
]]
section:colorpicker({name = "color correction", flag = "world_color_correction", color = color(1,1,1), alpha = 0})
local bloom = Instance.new("BloomEffect")
bloom.Parent = lighting
section:slider({name = "bloom scale", min = 1, max = 1000, default = 1, interval = 1, suffix = "", flag = "bloomscale", callback = function()
	local t = flags.bloomscale / 1000
	local curve = t ^ 2.2
	bloom.Intensity = curve * 2.5
	bloom.Size      = 12 + curve * 48 
	bloom.Threshold = 1.2 - curve * 0.8
	bloom.Enabled = curve > 0.01
end})
local elements = column2:section({name = "elements", size = 0.3})
depend(elements, function()
	return flags.editor_list == "misc"
end)
elements:toggle({name = "autosave notification", flag = "autosave_notification", default = true})
elements:toggle({name = "notification sound", flag = "notifSound", default = true})
elements:toggle({name = "linked discord profile", flag = "linked_discord_profile", default = true})
elements:toggle({name = "watermark", flag = "watermark", default = true})
elements:dropdown({
	name = "watermark style",
	flag = "watermark_style",
	items = {"corner", "classic"},
	multi = false,
	scrolling = true
})
elements:dropdown({
	name = "options",
	flag = "watermark_options",
	items = {"ping", "fps", "time", "username", "uid"},
	multi = true,
	scrolling = true
})
elements:toggle({name = "spinning logo", flag = "spinning_logo"})
elements:slider({name = "spinning logo size", min = 1, max = 1000, default = 100, interval = 1, suffix = "", flag = "logosize"})
elements:dropdown({
	name = "keybinds",
	flag = "keybinds_type",
	items = {"off", "crosshair", "widget"},
	multi = false,
	scrolling = true
})
local section = left_column:section({name = "viewmodel", size = 0.3})
depend(section, function()
	return flags.editor_list == "self"
end)
local self_secondary
section:toggle({name = "enabled", flag = "viewmodel"})
local isHand = function() return false end
if game.GameId == 113491250 then
	isHand = function(v)
		return v:FindFirstChild("SkinTone") or v:FindFirstChild("Hand")
	end
end
section:toggle({name = "ignore hands", flag = "viewmodel_ignore_hands", tip = "This might not work in alot of games!"})
section:toggle({name = "enable color", flag = "viewmodel_color_enabled"})
section:colorpicker({name = "color", flag = "viewmodel_color", color = themes.preset.button, alpha = 0})
section:toggle({name = "glow", flag = "highlight_viewmodel"})
section:toggle({name = "overlay", flag = "viewmodel_neon"})
section:toggle({name = "tools", flag = "viewmodel_tools"})
if game.GameId == 113491250 then
	section:toggle({name = "no sleeves", flag = "viewmodel_nosleeves"})
	section:toggle({name = "disable scope", flag = "viewmodel_noscope", tip = "Disables the scope overlay on sniper rifles"})
end
local forcefieldanimations = {
	["off"] = "",
	["web"] = "rbxassetid://301464986",
	["webbed"] = "rbxassetid://2179243880",
	["scanning"] = "rbxassetid://5843010904",
	["pixelated"] = "rbxassetid://140652787",
	["swirl"] = "rbxassetid://8133639623",
	["checkerboard"] = "rbxassetid://5790215150",
	["christmas"] = "rbxassetid://6853532738",
	["player"] = "rbxassetid://4494641460",
	["shield"] = "rbxassetid://361073795",
	["dots"] = "rbxassetid://5830615971",
	["bubbles"] = "rbxassetid://1461576423",
	["matrix"] = "rbxassetid://10713189068",
	["honeycomb"] = "rbxassetid://179898251",
	["groove"] = "rbxassetid://10785404176",
	["cloud"] = "rbxassetid://5176277457",
	["sky"] = "rbxassetid://1494603972",
	["smudge"] = "rbxassetid://6096634060",
	["scrapes"] = "rbxassetid://6248583558",
	["galaxy"] = "rbxassetid://1120738433",
	["galaxies"] = "rbxassetid://5101923607",
	["stars"] = "rbxassetid://598201818",
	["rainbow"] = "rbxassetid://10037165803",
	["wires"] = "rbxassetid://14127933",
	["camo"] = "rbxassetid://3280937154",
	["hexagon"] = "rbxassetid://6175083785",
	["particles"] = "rbxassetid://1133822388",
	["triangular"] = "rbxassetid://4504368932",
	["wall"] = "rbxassetid://4271279"
}
depend(section:dropdown({
	name = "overlay animation",
	flag = "viewmodel_neon_animation",
	items = (function()
		local animationList = {}

		for animation, _ in forcefieldanimations do
			insert(animationList, animation)
		end

		return animationList
	end)(),
	default = "off",
	multi = false,
	scrolling = true
}), function()
	return flags.viewmodel_neon
end)
section:dropdown({
	name = "material",
	flag = "viewmodel_material",
	items = (function()
		local materialList = {}

		for _, material in Enum.Material:GetEnumItems() do
			insert(materialList, material.Name)
		end

		return materialList
	end)(),
	default = "Glass",
	multi = false,
	scrolling = true
})
section:dropdown({
	name = "mode",
	flag = "viewmodel_mode",
	items = {"normal", "pulse"},
	default = "normal",
	multi = false,
	scrolling = true
})
function handle_viewmodel_transparency(transparency, mode, dt)
	if mode == "pulse" then
		transparency = math.clamp(math.sin(elapsed_ticks / 10) * transparency, 0, 1)
	end
	return transparency
end

local cachedHighlight = {}
for i = 1, 25 do
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0.5
	highlight.Parent = nil
	cachedHighlight[i] = highlight
end

function getCachedHighlight()
	for i, highlight in cachedHighlight do
		if not highlight.Parent or not highlight:IsDescendantOf(game) or not highlight.Adornee or not highlight.Adornee:IsDescendantOf(game) then
			if not pcall(function() highlight.Parent = coregui end) then
				pcall(game.Destroy, highlight)
				highlight = Instance.new("Highlight")
				cachedHighlight[i] = highlight
			end
			return highlight
		end
	end
	return nil
end

local whitelist = {"SkinTone","Arm"}
function handleViewmodelPart(v, dt)
	if v.Parent:FindFirstChild(whitelist[1]) and not table.find(whitelist, v.Name) then
		v.Transparency = 1
		return
	end
	local vm_mode = flags.viewmodel_mode
	if not v:GetAttribute("Material") then
		v:SetAttribute("Material", v.Material.Name)
		v:SetAttribute("Color", v.Color)
		v:SetAttribute("Transparency", v.Transparency)
		pcall(function()
			v:SetAttribute("TextureID", v.TextureID)
		end)
	end
	v.Material = Enum.Material[upperString(flags.viewmodel_material)] 
	if flags.viewmodel_neon then
		local ChamsInstance = v:FindFirstChild("ChamsInstance")
		local Scale =  vec3(1,1,1) * .1
		if not ChamsInstance then
			ChamsInstance = v:Clone()
			ChamsInstance.Name = "ChamsInstance"
			ChamsInstance.Parent = v
			ChamsInstance.Anchored = false
			ChamsInstance:ClearAllChildren()
			local Weld = Instance.new("Weld")
			Weld.Part0,Weld.Part1 = v,ChamsInstance
			Weld.Parent = ChamsInstance
		end
		ChamsInstance.Material = Enum.Material.ForceField
		ChamsInstance.Color = flags.viewmodel_color.Color
		if ChamsInstance:IsA("MeshPart") then
			ChamsInstance.TextureID = forcefieldanimations[flags.viewmodel_neon_animation] or "rbxassetid://0"
		end
		ChamsInstance.Transparency = v.Transparency
		ChamsInstance.Size = v.Size + Scale
	elseif v:FindFirstChild("ChamsInstance") then
		v.ChamsInstance:Destroy()
	end
	if flags.viewmodel_color_enabled then
		v.Color = flags.viewmodel_color.Color
	else
		v.Color = v:GetAttribute("Color")
	end
	pcall(setproperty, v, "TextureID", "")
	v.Transparency = library.thirdPerson and 0.9999 or handle_viewmodel_transparency(1 - flags.viewmodel_color.Transparency, vm_mode, dt)
	--[[if (v.Name:match("Sleeve")) then 
		v.Transparency = 1 
	end]]
	v:SetAttribute("lol", true)
end

function updateToolViewmodel(v, dt)
	if v:IsA("SpecialMesh") then
		if flags.viewmodel then
			if not v:GetAttribute("VertexColor") then
				v:SetAttribute("VertexColor", v.VertexColor)
				v:SetAttribute("TextureId", v.TextureId)
			end
			v.VertexColor = flags.viewmodel_color_enabled and Vector3.new(flags.viewmodel_color.Color.R / 255, flags.viewmodel_color.Color.G / 255, flags.viewmodel_color.Color.B / 255) or v:GetAttribute("VertexColor")
			v.TextureId = ""
		else
			if v:GetAttribute("VertexColor") then
				v.VertexColor = v:GetAttribute("VertexColor")
				v.TextureId = v:GetAttribute("TextureId")
				v:SetAttribute("VertexColor", nil)
				v:SetAttribute("TextureId", nil)
			end
		end
	end
	if not v:IsA("BasePart") then 
		return
	end
	if (v.Transparency == 1 and not v:GetAttribute("lol")) or v.Name == "ChamsInstance" then
		return
	end
	if flags.viewmodel then
		handleViewmodelPart(v, dt)
	else
		if v:GetAttribute("Material") then
			v.Material = Enum.Material[v:GetAttribute("Material")]
			v.Color = v:GetAttribute("Color")
			v.Transparency = v:GetAttribute("Transparency")
			pcall(function() v.TextureID = v:GetAttribute("TextureID") end)
			if v:FindFirstChild("ChamsInstance") then
				v.ChamsInstance:Destroy()
			end
			v:SetAttribute("Material", nil)
			v:SetAttribute("Color", nil)
			v:SetAttribute("Transparency", nil)
			pcall(function()
				v:SetAttribute("TextureID", nil)
			end)
		end
	end
end

local function viewmodelTexture(v)
	if flags.viewmodel_color_enabled then
		if not v:GetAttribute("Color") then
			v:SetAttribute("Color", v.Color3)
		end
		v.Color3 = flags.viewmodel_color.Color
	else
		if v:GetAttribute("Color") then
			v.Color3 = v:GetAttribute("Color")
			v:SetAttribute("Color", nil)
		end
	end
	local tr
	pcall(function() tr = v.Parent.Transparency end)
	if v:IsA("Decal") then
		tr = 1
	end
	v.Transparency = tr or library.thirdPerson and 0.9999 or handle_viewmodel_transparency(1 - flags.viewmodel_color.Transparency, vm_mode, dt)
	v:SetAttribute("lol", true)
end

function viewmodelSetup(v)
	if v:IsA("Texture") or v:IsA("Decal") then
		return viewmodelTexture(v)
	end
	if not v:IsA("BasePart") then 
		return
	end
	if v:IsA("MeshPart") and v:FindFirstChildOfClass("Bone") then return end
	if (v.Transparency == 1 or v.Name == "ChamsInstance") then
		return
	end
	if (flags.viewmodel_ignore_hands and (isHand(v.Parent) or v.Name:match("Hand") or (v:IsA("MeshPart") and (v.MeshId == "rbxasset://fonts/leftarm.mesh" or v.MeshId == "rbxasset://fonts/rightarm.mesh")) or v.Name:match("Arm"))) then
		return
	end
	local model = v:FindFirstAncestorOfClass("Model")
	if model ~= nil and not chamsContainer:FindFirstChild(model.Name) and flags.highlight_viewmodel then
		local highlight = getCachedHighlight()
		highlight.Name = model.Name
		highlight.Parent = chamsContainer
		highlight.Adornee = model
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = flags.viewmodel_color.Color
		highlight.FillTransparency = 10
		highlight.OutlineTransparency = 0.999
		highlight.OutlineColor = Color3.new(1,1,1)
		highlight.FillColor = Color3.new(0,0,0)
	end
	pcall(function()
		v.UsePartColor = true
	end)
	if flags.viewmodel then
		handleViewmodelPart(v, dt)
	else
		if v:GetAttribute("Material") then
			v.Material = Enum.Material[v:GetAttribute("Material")]
			v.Color = v:GetAttribute("Color")
			v.Transparency = v:GetAttribute("Transparency")
			pcall(function() v.TextureID = v:GetAttribute("TextureID") end)
			if v:FindFirstChild("ChamsInstance") then
				v.ChamsInstance:Destroy()
			end
			v:SetAttribute("Material", nil)
			v:SetAttribute("Color", nil)
			v:SetAttribute("Transparency", nil)
			pcall(function()
				v:SetAttribute("TextureID", nil)
			end)
		end
	end
end

if (game.PlaceId == 17516596118) then
	cons[#cons + 1] = run.RenderStepped:Connect(function(dt)
		local ignore = workspace:FindFirstChild("IgnoreThese")
		if not ignore then return end
		local myArms = ignore:FindFirstChild("MyArms")
		if not myArms then return end
		for i, v in myArms:GetDescendants() do
			viewmodelSetup(v)
		end

	end)
else
	run:BindToRenderStep("??", Enum.RenderPriority.Last.Value, function(dt)
		if not flags.viewmodel then return end
		for i, v in camera:GetDescendants() do
			thread(viewmodelSetup, v)
		end

		local char = lp.Character
		if not char then return end
		local tool = char:FindFirstChildOfClass("Tool")

		if flags.viewmodel_tools and tool then
			for _,v in tool:GetDescendants() do
				thread(updateToolViewmodel, v, dt)
			end
		end
	end)
end

if game.GameId == 113491250 then
	local section = column:section({name = "character model", size = 0.3})
	depend(section, function()
		return flags.editor_list == "players"
	end)
	section:toggle({name = "enabled", flag = "character_chams"})
	section:toggle({name = "hide attachments", flag = "hide_other_attachments"})
	section:toggle({name = "only enemy", flag = "enemy_only_character"})
	section:colorpicker({name = "color", flag = "character_chams_color", color = themes.preset.button, alpha = 0})
	section:dropdown({
		name = "material",
		flag = "character_chams_material",
		items = {"neon", "flat", "forcefield"},
		multi = false,
		scrolling = true
	})
	depend(section:dropdown({
		name = "forcefield style",
		flag = "character_chams_forcefield_style",
		items = (function()
			local list = {}
			for style, _ in forcefieldanimations do
				table.insert(list, style)
			end
			return list
		end)(),
		default = "off",
		multi = false,
		scrolling = true
	}), function() return flags.character_chams_material == "forcefield"  end)
	local section = column:section({name = "character model", size = 0.3})
	depend(section, function()
		return flags.editor_list == "self"
	end)
	section:toggle({name = "enabled", flag = "self_character_chams"})
	section:toggle({name = "chinahat", flag = "chinahat", callback = function() library.gradientEvent:Fire() end})
	depend(section:toggle({name = "rainbow", flag = "chinahat_rainbow", callback = function() library.gradientEvent:Fire() end}), function()
		return flags.chinahat
	end)
	depend(section:toggle({name = "render bottom", flag = "chinahat_bottom", callback = function() library.gradientEvent:Fire() end}), function()
		return flags.chinahat
	end)
	depend(section:colorpicker({name = "color", flag = "chinahat_color", color = themes.preset.button, alpha = 0, callback = function() library.gradientEvent:Fire() end}), function()
		return flags.chinahat
	end)
	section:toggle({name = "hide attachments", flag = "hide_local_attachments"})
	section:colorpicker({name = "color", flag = "self_character_chams_color", color = themes.preset.button, alpha = 0})
	section:dropdown({
		name = "material",
		flag = "self_character_chams_material",
		items = {"neon", "flat", "forcefield"},
		multi = false,
		scrolling = true
	})
	depend(section:toggle({name = "hide body parts", flag = "self_character_chams_hide_body_parts", tip = "Removes your body parts and only shows the outline."}), function()
		return flags.self_character_chams_material == "forcefield"
	end)
	depend(section:dropdown({
		name = "forcefield style",
		flag = "self_character_chams_forcefield_style",
		items = (function()
			local list = {}
			for style, _ in forcefieldanimations do
				table.insert(list, style)
			end
			return list
		end)(),
		default = "off",
		multi = false,
		scrolling = true
	}), function() return flags.self_character_chams_material == "forcefield"  end)
	local shoot_effects = column:section({name = "shoot effects", size = 0.3})
	shoot_effects:toggle({name = "enabled", flag = "shoot_effects"})
	shoot_effects:colorpicker({name = "color", flag = "shoot_effects_color", color = themes.preset.button, alpha = 0})
	shoot_effects:slider({name = "lifetime", min = 4, max = 12, default = 4, interval = 0.1, suffix = "s", flag = "shoot_effects_lifetime"})
	depend(shoot_effects, function()
		return flags.editor_list == "world"
	end)
end

local column = column2
local section = column:section({name = "chams", size = 0.3})
depend(section, function()
	return flags.editor_list == "self"
end)
local self_secondary


section:toggle({name = "enabled", flag = "self_chams"})
section:toggle({name = "animation", flag = "self_animated", callback = function()
	if not self_secondary then return end
	self_secondary.show_element(flags.self_animated)
end,})
section:dropdown({
	name = "style",
	flag = "chams_self_material",
	items = {"breathe", "normal", "inverted"},
	multi = false,
	scrolling = true
})
section:colorpicker({name = "primary color", flag = "self_primary_color", color = themes.preset.button, alpha = 0})
self_secondary = section:colorpicker({name = "secondary color", flag = "self_secondary_color", color = themes.preset.button_alt, alpha = 0})
self_secondary.show_element(flags.self_animated)



local section = left_column:section({name = "esp", size = 0.3})
depend(section, function()
	return flags.editor_list == "players"
end)
local function force_reset()
	for player, frame in esp_frames do
		frame:Destroy()
		esp_frames[player] = nil
	end
	table.clear(esp_frames)
end
library.esp_masterswitch = section:toggle({name = "enabled", flag = "masterswitch", callback = force_reset, popout = true})
library.esp_masterswitch:add(section:slider({name = "font size", min = 0.1, max = 1.5, default = 1, interval = 0.1, suffix = "", flag = "esp_font_size_multiplier", callback = force_reset}))
library.esp_masterswitch:add(section:toggle({name = "fast render", flag = "fastrender", tip = "THIS MAY CAUSE A LOT OF LAG! Fixes your ESP lagging behind your camera", callback = function()
	force_reset()
	if flags.fastrender then
		local db = false
		cameraEvent = camera:GetPropertyChangedSignal("CFrame"):Connect(function()
			if db then return end
			db = true
			thread(update_esp)
			db = false
		end)
	else
		if cameraEvent then cameraEvent:Disconnect() cameraEvent = nil end
	end
end}))

library.esp_masterswitch:add(section:toggle({name = "enemy only", flag = "onlyenemy", callback = force_reset}))
library.esp_masterswitch:add(section:toggle({name = "on self", flag = "localesp", callback = force_reset}))
--[[
local walkspeed_parent = movement:toggle({
		name = "walkspeed", 
		flag = "force_speed", 
		tip = "Speed exploit",
		popout = true -- This makes it a parent for sub-items
	})

    walkspeed_parent:add(movement:toggle({
		name = "improve control", 
		flag = "speed_control", 
		tip = "Improves player control"
	}))
    walkspeed_parent:add(movement:slider({
        name     = "speed value", 
        flag     = "speedvalue",
        min      = 16, 
        max      = 110, 
        default  = 16, 
        interval = 1, 
        suffix   = 'studs/s', 
        tip      = "Exploit speed value"
    }))
		]]

library.name = section:toggle({name = "username", flag = "esp_username", callback = force_reset, popout = true})
library.name:add(section:toggle({name = "prefer display name", flag = "prefer_display_name", callback = force_reset}))

library.distance = section:toggle({name = "distance", flag = "esp_distance", callback = force_reset, popout = true})
library.distance:add(section:toggle({name = "suffix", flag = "esp_suffix", callback = force_reset}))

library.oof_arrows = section:toggle({name = "oof arrows", flag = "oof_arrows", callback = force_reset, popout = true})
library.oof_arrows:add(section:slider({name = "size", min = 10, max = 100, default = 50, interval = 1, suffix = "px", flag = "oof_arrows_size", callback = force_reset}))
library.oof_arrows:add(section:slider({name = "offset", min = 64, max = 512, default = 128, interval = 1, suffix = "px", flag = "oof_arrows_offset", callback = force_reset}))
library.oof_arrows:add(section:toggle({name = "dynamic offset", flag = "oof_arrows_dynamic_offset", callback = force_reset}))
library.oof_arrows:add(section:colorpicker({name = "color", flag = "oof_arrows_color", color = themes.preset.button, alpha = 0, callback = force_reset}))

library.bounding_box = section:toggle({name = "bounding box", flag = "bounding_box", callback = force_reset, popout = true})
library.bounding_box:add(section:colorpicker({name = "primary", flag = "esp_primary", color = themes.preset.button, alpha = 0, callback = force_reset}))
library.bounding_box:add(section:colorpicker({name = "secondary", flag = "esp_secondary", color = themes.preset.button, alpha = 0, callback = force_reset}))
library.bounding_box:add(section:toggle({name = "filled", flag = "esp_filled", callback = force_reset}))
library.bounding_box:add(section:toggle({name = "gradient", flag = "esp_gradient", callback = force_reset}))
local gradient_rotation = section:slider({name = "gradient rotation", min = 0, max = 360, default = 0, interval = 5, suffix = "Â°", flag = "esp_gradient_rotation", callback = force_reset})
depend(gradient_rotation, function()
	return flags.esp_gradient
end)
library.bounding_box:add(gradient_rotation)
library.bounding_box:add(section:toggle({name = "cat", flag = "esp_cat", callback = force_reset}))

library.ammo_bar = section:toggle({name = "ammo bar", flag = "esp_ammobar", callback = force_reset, popout = true})
library.ammo_bar:add(section:colorpicker({name = "color", flag = "ammo_bar_color", color = themes.preset.button, alpha = 0, callback = force_reset}))

library.health_bar = section:toggle({name = "health bar", flag = "esp_healthbar", callback = force_reset, popout = true})
library.health_bar:add(section:toggle({name = "glow", flag = "health_bar_glow", callback = force_reset}))
library.health_bar:add(section:colorpicker({name = "max health", flag = "maxhealth", color = themes.preset.button_alt, alpha = 0, callback = force_reset}))
library.health_bar:add(section:colorpicker({name = "min health", flag = "minhealth", color = themes.preset.button_alt:Lerp(rgb(), 0.5), alpha = 0, callback = force_reset}))
library.health_bar:add(section:slider({name = "width", min = 15, max = 85, default = 35, interval = 1, suffix = "px", flag = "health_bar_width", callback = force_reset}))
--[[section:toggle({name = "master switch", flag = "masterswitch"})
section:toggle({name = "only visible", flag = "onlyvisible"})
section:dropdown({
	name = "include",
	flag = "includeflags",
	items =  game.GameId == 113491250 and {"items", "others"} or {"items", "npcs", "vehicles", "others"},
	multi = true,
	scrolling = true
})
section:colorpicker({name = "enemy color", flag = "enemy_color", color = themes.preset.button, alpha = 0})
section:colorpicker({name = "friend color", flag = "friend_color", color = Color3.fromHex("#00BFFF"), alpha = 0})
section:slider({name = "max distance", min = 1, max = 10000, default = 500, interval = 1, suffix = "u", flag = "maxdistance"})
section:dropdown({
	name = "bounding box",
	flag = "boundingbox",
	items = {"none", "quad", "corners", "3d"},
	multi = false,
	scrolling = true
})
section:toggle({name = "filled box", flag = "filledbox"})
section:toggle({name = "enemy only", flag = "onlyenemy"})
section:toggle({name = "team colors", flag = "teamcolors"})
depend(section:toggle({name = "ignore self", flag = "ignoreself"}), function() return not flags.onlyenemy end)
section:dropdown({
	name = "flags",
	flag = "espflags",
	items = game.GameId == 113491250 and {"name", "ping", "distance", "health", "gun"} or {"name", "ping", "distance", "health", "tool", "team", "velocity"},
	multi = true,
	scrolling = true
})
local maxhealthcolor = section:colorpicker({name = "max health", flag = "maxhealth", color = themes.preset.button_alt, alpha = 0})
local minhealthcolor = section:colorpicker({name = "min health", flag = "minhealth", color = themes.preset.button_alt:Lerp(rgb(), 0.5), alpha = 0})
depend(maxhealthcolor, function() return table.find(flags.espflags, "health") end)
depend(minhealthcolor, function() return table.find(flags.espflags, "health") end)
section:toggle({name = "lines", flag = "lines"})
section:toggle({name = "head dot", flag = "headdot", wip = true})
section:toggle({name = "skeleton", flag = "skeleton", wip = true})
section:toggle({name = "interpolation", flag = "interpolation", wip = true})
section:toggle({name = "king von", flag = "kingvon", wip = true})]]

do
	local players = window:tab({name = "players"})
	local column = players:column({})
	local column2 = players:column({})
	local section = column:section({name = "selection", size = 130})
	local list = section:list({name = "players", size = 130, items = {}, visible = true, flag = "player_list", callback = function()
		task.defer(update_title)
	end})

	refresh_players = function()
		local options = {}


		for idx, player in services.players:GetPlayers() do
			if player == lp then continue end
			if not player_list[player.Name] then
				player_list[player.Name] = {ignore_player = false}
			end
			options[ #options + 1 ] = player.Name
		end

		cfgs = options
		list.refresh_options(options)
	end
	task.defer(refresh_players)

	services.players.PlayerAdded:Connect(function()
		task.defer(refresh_players)
	end)
	services.players.PlayerRemoving:Connect(function()
		task.defer(refresh_players)
	end)
	local section = column2:section({name = "actions - none", size = 0.3})
	local saved_action_list = {}

	section:button({ name = "goto", unsafe = true, callback = function()
		local char = lp.Character
		if not char then return end
		local target = services.players:FindFirstChild(flags.player_list)
		if not target then return end
		local rootpart = char:FindFirstChild("HumanoidRootPart")
		if not rootpart then return end
		if not target.Character then return end
		rootpart.CFrame = target.Character:GetPivot()
	end})
	local ignore_toggle; ignore_toggle = section:toggle({ name = "ignore player", flag = "ignore_player", unsafe = true, callback = function()
		task.delay(0.1, function()
			local t = player_list[flags.player_list]
			if not t then
				ignore_toggle:set_value(false)
				return
			end
			t.ignore_player = flags.ignore_player
			createNotification({text = `set ignore for {flags.player_list} to {t.ignore_player}`})
		end)
	end })

	--print(ignore_toggle)
	task.delay(1, function()
		ignore_toggle:set_value(false)	
	end)


	update_title = function()
		local t = player_list[flags.player_list]
		if not t then
			if flags.ignore_player then
				ignore_toggle:set_value(false)
			end
			section:set_title("actions - none")
			return
		end
		if flags.ignore_player ~= t.ignore_player then
			ignore_toggle:set_value(t.ignore_player)
		end
		---section:set_title(`actions - {flags.player_list or "none"}`)
	end

	task.delay(0.1, update_title)

end

if game.PlaceId == 112757576021097 then
	do
		local skins = services.replicatedStorage.Import.Assets.Skins
		local tab = window:tab({name = "skins"})
		local column = tab:column({})
		local column2 = tab:column({})

		local skinCount = 0

		local arms = nil
		local lastGun
		for _, skinFolder in skins:GetChildren() do
			skinCount += 1
			local column = (skinCount % 2 == 0 and column or column2)
			local thisSkin = column:section({name = skinFolder.Name, size = 0.3})
			local thisCon
			workspace.CurrentCamera.ChildAdded:Connect(function(v)
				if v.Name == "Arms" then
					if flags[`{skinFolder.Name}enabled`] then
						local theSkin = flags[`{skinFolder.Name}skin`]
						lp:FindFirstChild("CurrentGun",true).Changed:Wait()
						if skinFolder:FindFirstChild(theSkin) and lp:FindFirstChild("CurrentGun",true) then
							local currentGun = lp:FindFirstChild("CurrentGun",true).Value
							if string.lower(currentGun) == string.lower(skinFolder.Name) then
								local arms = v
								if arms then
									for _, part in arms:GetDescendants() do
										if part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "Glove" and part.Name ~= "Sleeve" then
											if part:FindFirstChildWhichIsA("SurfaceAppearance") then
												part:FindFirstChildWhichIsA("SurfaceAppearance"):Destroy()
											end
											skinFolder[theSkin]:FindFirstChildOfClass("SurfaceAppearance"):Clone().Parent = part
										end
									end
								end
							end
						end
					end
				end
			end)
			thisSkin:toggle({name = "enabled", flag = `{skinFolder.Name}enabled`, default = false, callback = function()
			end})
			thisSkin:dropdown({
				name = "skin",
				flag = `{skinFolder.Name}skin`,
				items = (function()
					local list = {"default"}
					for _, v in skinFolder:GetChildren() do
						insert(list,  v.Name)
					end
					return list
				end)(),
				multi = false,
				scrolling = true
			})
		end
	end
end


local misc = window:tab({name = "misc"})

local lua = window:tab({name = "lua"})
local column = misc:column({})
local column2 = misc:column({})
local section = column:section({name = "movement", size = 0.3})
section:toggle({name = "velocity fix", flag = "velocityfix", wip = (game.GameId == 113491250)})
section:toggle({name = "high jump", flag = "highjump", wip = (game.GameId == 113491250)})
if (game.GameId == 7633926880) then
	section:toggle({name = "infinite stamina", flag = "infinitestamina"})
	section:toggle({name = "no friction", flag = "nofriction"})
	section:toggle({name = "auto bhop", flag = "autobhop"})
	depend(section:dropdown({
		name = "air strafe",
		flag = "strafe",
		items = {"subtick", "directional"},
		multi = true,
		scrolling = true
	}), function() return flags.autobhop end)
	local charController = require(services.replicatedStorage.Controllers.CharacterController)
	local charModule = require(services.replicatedStorage.Classes.Character)
	local localCharModule
	charModule.TakeStamina = newlclosure(function(self, amount)
		if flags.infinitestamina then
			amount = -1
		end
		self.Stamina = math.clamp(self.Stamina - amount, 0, self.MaxStamina)
		localCharModule = self
	end)
	local oldAccelerate = charModule.Accelerate
	charModule.Accelerate = newlclosure(function(self, ...)
		localCharModule = self
		print(self)
		return oldAccelerate(self, ...)
	end)
	local subtickSpeed = 0
	cons[#cons + 1] = run.RenderStepped:Connect(function(dt)
		if not flags.autobhop then return end
		local char = lp.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		if hum.FloorMaterial ~= Enum.Material.Air and uis:IsKeyDown(Enum.KeyCode.Space) then
			for _, connection in getconnections(uis.JumpRequest) do
				local hasFunction, theFunction = pcall(function() return connection.Function end)
				if hasFunction and theFunction and typeof(theFunction) == "function" then
					theFunction()
				end
			end
			for _, connection in getconnections(uis.InputBegan) do
				local hasFunction, theFunction = pcall(function() return connection.Function end)
				if hasFunction and theFunction and typeof(theFunction) == "function" then
					theFunction({
						KeyCode = Enum.KeyCode.Space,
						UserInputType = Enum.UserInputType.Keyboard,
						UserInputState = Enum.UserInputState.Begin,
					})
				end
			end
			charController.jump()
			if find(flags.strafe,"subtick") then
				subtickSpeed += 1
				subtickSpeed = math.clamp(subtickSpeed, 0, 2)
				hum.RootPart.AssemblyLinearVelocity = hum.RootPart.AssemblyLinearVelocity + (hum.MoveDirection * subtickSpeed)
			end
		elseif hum.FloorMaterial ~= Enum.Material.Air then
			subtickSpeed = 0
		elseif hum.FloorMaterial == Enum.Material.Air and find(flags.strafe,"directional") then
			local moveDir = Vector3.new(0,0,0)
			if uis:IsKeyDown(Enum.KeyCode.W) then
				moveDir += camera.CFrame.LookVector
			end
			if uis:IsKeyDown(Enum.KeyCode.S) then
				moveDir -= camera.CFrame.LookVector
			end
			if uis:IsKeyDown(Enum.KeyCode.A) then
				moveDir -= camera.CFrame.RightVector
			end
			if uis:IsKeyDown(Enum.KeyCode.D) then
				moveDir += camera.CFrame.RightVector
			end
			moveDir = moveDir.Unit
			local speed =  (15 + subtickSpeed)
			if find(flags.strafe,"subtick") then
				subtickSpeed += 9
				subtickSpeed = math.clamp(subtickSpeed, 0, 2)
				speed = (20.5 - floor(elapsed_ticks) % 3)
			else
				subtickSpeed = 0
			end
			local isFalling = hum.RootPart.AssemblyLinearVelocity.Y < 0
			hum.RootPart.AssemblyLinearVelocity = vec3(0,hum.RootPart.AssemblyLinearVelocity.Y,0) + vec3(moveDir.X, 0, moveDir.Z) * speed
		end
	end)
end
section:dropdown({
	name = "spiderman",
	flag = "spider_mode_flag",
	items = game.GameId == 113491250 and {"off", "exploit"} or {"off", "state", "velocity", "rotation", "jumpangle"},
	multi = false,
	scrolling = true,
	unsafe = true
})
local spider_key = section:keybind({name = "key", flag = "spiderkey", unsafe = true, display = "spiderman"})
local spider_min_height = section:slider({name = "height", min = 1, max = 15, default = 5, interval = 1, suffix = "u", flag = "spider_min_height", unsafe = true})
depend(spider_min_height, function() return flags.spider_mode_flag ~= "off" end)
depend(spider_key, function() return flags.spider_mode_flag ~= "off" end)
section:dropdown({
	name = "flight",
	flag = "flight_mode_flag",
	items = game.GameId == 113491250 and {"off", "experimental"} or {"off", "instant", "vehicle", "velocity", "sit", "cframe", "jump"},
	multi = false,
	scrolling = true,
	unsafe = true
})
local flight_key = section:keybind({name = "key", flag = "flightkey", unsafe = true, display = "flight"})
local flight_speed = section:slider({name = "speed", min = 1, max = 100, default = 5, interval = 1, suffix = "u", flag = "flight_speed", unsafe = true})
depend(flight_speed, function() return flags.flight_mode_flag ~= "off" end)
depend(flight_key, function() return flags.flight_mode_flag ~= "off" end)
local speed_key = section:keybind({name = "speed", flag = "speed", unsafe = true})
section:dropdown({
	name = "mode",
	flag = "speed_mode_flag",
	items = game.GameId == 113491250 and {"off", "exploit", "bhop", "multistep"} or {"off", "normal", "strafe", "ground", "grim", "fastgrim", "pl", "spike"},
	multi = false,
	scrolling = true,
	unsafe = true
})
local phase_key = section:keybind({name = "phase", flag = "phasekey", unsafe = true})
section:toggle({name = "instant stop", flag = "instantstop"})
local section = column:section({name = "other", size = 0.3})
local thirdPerson = section:keybind({name = "third-person", flag = "thirdperson", unsafe = true, display = "thirdperson"})
section:slider({name = "third-person distance", min = 1, max = 50, default = 12, interval = 1, suffix = "u", flag = "thirdpersonDistance"})
if game.GameId == 113491250 then
	section:toggle({name = "player smooth interpolation", flag = "smoothinterp"})
	section:toggle({name = "instant update", flag = "instantupdate"})
end
local forceFOV = section:keybind({name = "override fov", flag = "overridefov", unsafe = true, display = "override fov"})
section:slider({name = "fov", min = 1, max = 200, default = 70, interval = 1, suffix = string.char(194,176), flag = "real_fov"})
local zoomKey = section:keybind({name = "zoom", flag = "zoomkey", unsafe = true, display = "zoom"})
section:slider({name = "zoom fov", min = 1, max = 200, default = 40, interval = 1, suffix = string.char(194,176), flag = "zoom_fov"})
local ui_scale = section:slider({name = "ui scale", min = 1, max = 200, default = 100, interval = 1, suffix = "u", flag = "menuscale", callback = function()
	local scale = flags.menuscale / 100
	library.gui_scale = scale
end})
section:dropdown({name = "font", flag = "menufont", items = {"pixel", "alternate"}, multi = false, scrolling = true, callback = function()
	task.delay(1/30,function()
		for _, v in library.gui:GetDescendants() do
			if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
				if not v:GetAttribute("BaseFontSize") then v:SetAttribute("BaseFontSize", v.TextSize) end
				if flags.menufont == "pixel" then
					v.FontFace = fonts.ProggyClean
					v.TextSize = v:GetAttribute("BaseFontSize") * 1
				else
					v.FontFace = fonts.Tahoma
					v.TextSize = v:GetAttribute("BaseFontSize") * 1.2
				end
			end
		end
	end)
end})
section:toggle({name = "ws headless", flag = "headless_flag"})
section:toggle({name = "ws fiery", flag = "fiery_flag"})
local theme_elements = {}

section:colorpicker({name = "ui color", flag = "ui_color", color = themes.preset.button, alpha = 0, callback = function()
	themes.preset.button = flags.ui_color.Color
	themes.preset.button_alt = flags.ui_color.Color
	task.delay(1/60, function()
		build_str = (function(targetStr)
			local len, build = string.len(targetStr), ""

			for i = 1, len do
				build ..= `<font color="{rgbstr(themes.preset.button:lerp(themes.preset.button_alt, i/len))}">{targetStr:sub(i, i)}</font>`
			end

			return build
		end)(currentText)
		window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
		for _, v in library.gui:GetDescendants() do
			if v:IsA("Frame") and v:GetAttribute("buttonPrimary") then
				v.BackgroundColor3 = flags.ui_color.Color
			elseif v:IsA("Frame") and v:GetAttribute("buttonAlt") then
				v.BackgroundColor3 = flags.ui_color.Color
			end
		end
		library.gradientEvent:Fire()
	end)
end})
--113506071094099
local game_supports = table.find({113506071094099, 93853815957083}, game.PlaceId) ~= nil

local currentRegistered, lastRegistered, elapsedPingTime = 0, 0, tick()
section:toggle({name = "ping spike", flag = "pingspike", beta = true, wip = not game_supports});
depend(section:dropdown({
	name = "spike type",
	flag = "spikemode",
	items = {"incoming", "outgoing", "both"},
	multi = false,
	scrolling = true,
	beta = true
}), function() return flags.pingspike end)
depend(section:slider({name = "delay", min = 1, max = 10000, default = 1000, interval = 1, suffix = "ms", flag = "pingspikescale", beta = true}), function() return flags.pingspike end)

function getFromCore(name)
	local nilObject

	for _, instance in coregui:GetChildren() do
		if instance.Name == name then
			nilObject = instance
			break
		end
	end

	return nilObject
end
seraphAcc.hookBind = getFromCore("seraphHook")

local f = ({
	["113506071094099"] = function()
		local Event = game:GetService("ReplicatedStorage").Shared.Remote.RemoteEvents.LatencyService_Ping

		local OldFireServer; OldFireServer = hookfunction(Event.FireServer, function(...)
			local Args = table.pack(...)
			if flags.pingspike and (flags.spikemode == "outgoing" or flags.spikemode == "both") then
				local howLong = flags.pingspikescale / 1000
				Args[1] += howLong
				task.wait(howLong)
				currentRegistered += 1
			end

			return OldFireServer(table.unpack(Args))
		end)
		for i, con in getconnections(Event.OnClientEvent) do
			if pcall(function() return con.Function end) and con.Function ~= nil and typeof(con.Function) == "function" then
				local oldFunc; oldFunc = hookfunction(con.Function, function(...)
					if flags.pingspike and (flags.spikemode == "incoming" or flags.spikemode == "both") then task.wait(flags.pingspikescale / 1000) end
					currentRegistered += 1
					return oldFunc(...)
				end)
			end
		end

	end,
	["93853815957083"] = function()
		local Event = game:GetService("ReplicatedStorage").Shared.Remote.RemoteEvents.LatencyService_Ping

		local OldFireServer; OldFireServer = hookfunction(Event.FireServer, function(...)
			local Args = table.pack(...)
			if flags.pingspike and (flags.spikemode == "outgoing" or flags.spikemode == "both") then
				local howLong = flags.pingspikescale / 1000
				Args[1] += howLong
				task.wait(howLong)
				currentRegistered += 1
			end

			return OldFireServer(table.unpack(Args))
		end)
		for i, con in getconnections(Event.OnClientEvent) do
			if pcall(function() return con.Function end) and con.Function ~= nil and typeof(con.Function) == "function" then
				local oldFunc; oldFunc = hookfunction(con.Function, function(...)
					if flags.pingspike and (flags.spikemode == "incoming" or flags.spikemode == "both") then task.wait(flags.pingspikescale / 1000) end
					currentRegistered += 1
					return oldFunc(...)
				end)
			end
		end

	end
})[tostring(game.PlaceId)]
if f then task.spawn(f) end
section:button({ name = "rejoin", callback = function()
	services.teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
	writefile(library.directory .. "/configs/default.cfg", library:get_config())
end })
section:button({ name = "unload", callback = function()
	if getgenv().loaded then 
		getgenv().library:unload_menu() 
		for i,v in next, getgenv().connections do v:Disconnect() end
	end 

	getgenv().loaded = true 

end })

local section = column2:section({name = "config", size = 0.3, on_click = function()
	refresh_configs()
end})
local list = section:list({name = "configs", size = 130, items = {}, visible = true, flag = "config_list"})
local cfgs = {}
local linking_api = (function()
    local HttpService = game:GetService("HttpService")
    local Workshop = {}

    -- Internal cache for usernames to avoid redundant requests
    local userCache = { [0] = "System" }

    local function safeToNumber(v)
        if type(v) == "number" then return v end
        if type(v) == "string" then
            local n = tonumber(v)
            if n then return n end
        end
        return nil
    end

    local function normalizeBoolLike(v)
        if v == true then return true end
        if v == false then return false end
        if type(v) == "number" and v ~= 0 then return true end
        if type(v) == "string" then
            local vl = v:lower()
            if vl == "true" or vl == "1" then return true end
            if vl == "false" or vl == "0" then return false end
        end
        return false
    end

    local function claimersContains(claimers, userId)
        if type(claimers) ~= "table" then return false end
        local uidS = tostring(userId)
        for _, v in ipairs(claimers) do
            if tostring(v) == uidS then return true end
        end
        return false
    end

    local function getUsername(baseUrl, userId)
        if not userId then return "System" end
        if userCache[userId] then return userCache[userId] end

        -- Try the username endpoint
        local ok, response = pcall(function()
            return request({
                Url = baseUrl .. "/api/username/" .. tostring(userId),
                Method = "GET"
            })
        end)

        if ok and response and (response.StatusCode == 200 or response.Success == true) and response.Body then
            local success, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if success and data and data.username then
                userCache[userId] = data.username
                return data.username
            end
        end

        return "ID: " .. tostring(userId)
    end

    function Workshop.fetchItems(baseUrl, token)
        local headers = { ["authentication"] = token }
        local allItems = {}

        local function populate(endpoint, category, isWorkshop)
            local ok, response = pcall(function()
                return request({
                    Url = baseUrl .. endpoint,
                    Method = "GET",
                    Headers = headers
                })
            end)

            if not ok or not response then
                warn("Failed HTTP request to " .. tostring(endpoint))
                return
            end

            if not (response.StatusCode == 200 or response.Success == true) then
                warn("Failed to fetch " .. tostring(category) .. " from " .. tostring(endpoint) .. " (status: " .. tostring(response.StatusCode) .. ")")
                return
            end

            local success, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if not success or not data then
                warn("Failed to decode JSON from " .. tostring(endpoint))
                return
            end

            local list = (isWorkshop and data.items) or data
            if type(list) ~= "table" then
                warn("Unexpected list type for " .. tostring(endpoint))
                return
            end

            for _, item in ipairs(list) do
                -- Normalize claim-related info
                local claimers = item.claimers or {}
                if type(claimers) ~= "table" then claimers = {} end

                -- Normalize claimed_by_me: server sets boolean but be tolerant
                local claimed_by_me = normalizeBoolLike(item.claimed_by_me)

                -- Fallback: if claimed_by_me false, double-check claimers array for any truthy match
                -- (this covers some edge cases where the server returns strings or numeric flags)
                if not claimed_by_me and #claimers > 0 then
                    -- We don't always have our own numeric userId in the client, so if the server already
                    -- computed claimed_by_me this is usually sufficient. This fallback checks whether the
                    -- owner_user_id is present among claimers (not ideal, but helps in some cases).
                    -- If you have a local numeric userId, replace `item.owner_user_id` below with it.
                    local found = false
                    for _, v in ipairs(claimers) do
                        if tostring(v) == tostring(item.owner_user_id) then
                            found = true
                            break
                        end
                    end
                    if found then claimed_by_me = true end
                end

                local downloadUrl = item.source_url or item.resolve_url
                local entry = {
                    id = item.id,
                    name = item.name,
                    type = category,
                    is_copy = item.is_copy or (item.copy_of ~= nil),
                    owner_id = item.owner_user_id,
                    owner_name = getUsername(baseUrl, item.owner_user_id),
                    source = nil,
                    claimers = claimers,
                    claimed_by_me = claimed_by_me,
                    is_owner = item.is_owner == true
                }

                -- Only fetch source if we have a valid URL
                if downloadUrl then
                    local ok2, srcRes = pcall(function()
                        return request({ Url = downloadUrl, Method = "GET", Headers = headers })
                    end)
                    if ok2 and srcRes then
                        local srcSuccess = (srcRes.Success == true) or (srcRes.StatusCode == 200)
                        if srcSuccess and srcRes.Body then
                            entry.source = srcRes.Body
                        end
                    end
                end

                table.insert(allItems, entry)
            end
        end
        populate("/api/my-cloud-luas", "lua", false)
        populate("/api/my-cloud-configs", "config", false)
		task.wait()
        return allItems
    end

    return Workshop
end)()

local mapped = { configs = {}, luas = {} }

refresh_configs = function()
	local options = {}

	for name, source in mapped.configs do
		options[ #options + 1 ] = name
	end

	for idx, file in listfiles(library.directory .. "/configs") do
		if not string.match(file :: string, '.cfg') then continue end
		options[ #options + 1 ] = string.gsub(string.gsub(string.gsub(file :: string, ".cfg", ''), 'configs\\', ''), 'seraph\\', '')
	end


	cfgs = options
	list.refresh_options(options)
end

section:textbox {
	name = "config",
	placeholder = "name",
	flag = "rawrconfig",
	visible = true
}

section:button({ name = "create", callback = function()
	writefile(library.directory .. `/configs/{flags.rawrconfig}.cfg`, library:get_config())
	configName = flags.rawrconfig

	task.defer(refresh_configs)
	createNotification({text = `changed config to {flags.rawrconfig}`})

	window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
end })

section:button({ name = "save", callback = function()
	if not find(cfgs, flags.config_list) then
		return
	end
	if mapped.configs[configName] then
		createNotification({text = `cannot save cloud configs`})
		return
	end
	writefile(library.directory .. `/configs/{flags.config_list}.cfg`, library:get_config())
	createNotification({text = `saved config to {flags.config_list}`})

	window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
end })
section:button({ name = "load", callback = function()
	if not find(cfgs, flags.config_list) then
		return
	end
	configName = flags.config_list
	if mapped.configs[configName] then
		library:load_config(mapped.configs[configName])
		return
	end
	pcall(function()
		local cfgdata = readfile(library.directory .. `/configs/{configName}.cfg`)
		if cfgdata and typeof(cfgdata) == 'string' then
			library:load_config(cfgdata)
		end
	end)
	createNotification({text = `loaded config {flags.config_list}`})
	window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
end })

section:button({ name = "set default (universal)", callback = function()
	if not find(cfgs, flags.config_list) then
		return
	end
	writefile("seraph/configs/default.value", flags.config_list)
	createNotification({text = `set {flags.config_list} as universal default`})

	window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
end })

section:button({ name = "set default (game)", callback = function()
	if not find(cfgs, flags.config_list) then
		return
	end
	writefile(`seraph/configs/{tostring(game.PlaceId)}.value`, flags.config_list)
	createNotification({text = `set {flags.config_list} as game default`})

	window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
end })
section:button({ name = "reset to default", callback = function()
	flags = table.clone(library.empty_flags)
end })

section:button({ name = "refresh", callback = function()
	createNotification({text = "refreshing..."})
	refresh_configs()
end })

task.defer(refresh_configs)

local section = column2:section({name = "lua", size = 0.3, on_click = function()
	refresh_luas()
end})
local list = section:list({name = "lua scripts", size = 130, items = {}, visible = true, flag = "lua_scripts"})
local loaded_luas, luas = {}, {}


refresh_luas = function()
	local options = {}

	for name, source in mapped.luas do
		options[ #options + 1 ] = name
	end

	--for idx, file in listfiles(library.directory .. "/lua") do
	--	if not string.match(file :: string, '.lua') then continue end
	--	options[ #options + 1 ] = string.gsub(string.gsub(file :: string, ".lua", ''), 'priv9/', '')
	--end
	for idx, file in listfiles(library.directory .. "/lua") do
		if not string.match(file :: string, '.lua') then continue end
		options[ #options + 1 ] = string.gsub(string.gsub(string.gsub(file :: string, ".lua", ''), 'lua\\', ''), 'seraph\\', '')
	end

	luas = options
	list.refresh_options(options)
end

task.spawn(function()
	local linked_data = linking_api.fetchItems("https://seraph.wtf", _G.Product)

	for name, data in linked_data do
		local parentArray = mapped[data.type.. "s"]
		if parentArray and (data.claimed_by_me or data.owner_user_id == seraphAcc.uid) then
			local fullName = data.name
			if #fullName > 26 then fullName = string.sub(data.name, 1, 26).. "..." end
			mapped[data.type.. "s"][`* {fullName}`] = data.source
		end
	end
	task.defer(refresh_luas)
	task.defer(refresh_configs)
end)

local function start_lua(lua_name, should_load, is_workshop)
	local file = `{library.directory}/lua/{lua_name}.lua`

	if not should_load then
		local lua = loaded_luas[lua_name]
		if not lua then return end

		for _, rbxConnection in lua["connections"] do
			rbxConnection:Disconnect()
		end
		for _,instance in lua["elements"] do
			instance:destroy()
		end

		task.cancel(lua.thread)

		table.clear(lua)
		loaded_luas[lua_name] = nil

		return
	end



	local success, src 
	if not is_workshop then
		success, src = pcall(readfile, file)
	else
		success, src = pcall(function()
			local data = mapped.luas[lua_name]
			if not data then
				return error("FAILED TO FETCH DATA")
			end
			return data
		end)
	end

	if not success then
		createNotification({text = "failed to load lua"})
		return
	end

	local lua_instance = {
		connections = {},
		elements = {},
		thread = nil,
	}

	local lua_api = {
		seraph = {
			get = function() return library end,
		},
		ui = {
			column = function()
				local column = lua:column({})


				insert(lua_instance.elements, column)

				return column
			end,
			section = function(self, column, section)
				local section = column:section(section)

				insert(lua_instance.elements, section)

				return section
			end,
			child = function(self, section, childName, childData)
				local child = section[childName](section, childData)

				insert(lua_instance.elements, child)

				return child
			end,
			get = function(idx)
				return (typeof(idx) == 'string' and flags[idx] or flags[idx.flag])
			end,
		},
		notification = {
			create = function(self, data)
				createNotification(data)
			end,
		}
	}

	local loadfunc = loadstring(src, `[priv9::{lua_name}]`)
	local fenv = getfenv(loadfunc)

	for name, value in lua_api do
		fenv[name] = value
	end

	lua_instance.thread = task.spawn(loadfunc)

	loaded_luas[lua_name] = lua_instance
end

section:button({ name = "refresh", callback = refresh_luas })
section:button({ name = "load", callback = function()
	if not find(luas, flags.lua_scripts) then
		return
	end
	createNotification({text = "loading lua..."})
	start_lua(flags.lua_scripts, true, mapped.luas[flags.lua_scripts] ~= nil)

end })
section:button({ name = "unload", callback = function()
	if not find(luas, flags.lua_scripts) then
		return
	end
	start_lua(flags.lua_scripts, false, mapped.luas[flags.lua_scripts] ~= nil)
end })

if isfile('auto_load.json') and readfile('auto_load.json') then
	local file = http_service:JSONDecode(readfile("auto_load.json"))
	local luas = file.luas
	for _, name in luas do
		task.delay(1, start_lua, name, true, false)
	end
else
	writefile(
		'auto_load.json',
		http_service:JSONEncode({
			luas = {
				
			}
		})
	)
end

refresh_luas()

createNotification({text = "loaded seraph"})

-- inst
pcall(game.Destroy, workspace.CurrentCamera:FindFirstChild("colorcorrectionPriv"))
local colorcorrection = Instance.new("ColorCorrectionEffect")

-- vars


-- api

local antiaim = (function()
	local antiaim = {}

	antiaim.desync = { hitfloor = 0 }

	function antiaim.desync.start_prediction(self)
		local char = lp.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if not hum then return end
		if hum.FloorMaterial == Enum.Material.Air then self.hitfloor = 0 hrp.AssemblyLinearVelocity = vec3(hrp.AssemblyLinearVelocity.X, math.clamp(hrp.AssemblyLinearVelocity.Y, -300, 50), hrp.AssemblyLinearVelocity.Z) return end
		self.hitfloor += 1
		if self.hitfloor <= 5 then return end
		antiaim.true_velocity = hrp.AssemblyLinearVelocity
		local hrpStart = hrp.CFrame.Y
		hrp.AssemblyLinearVelocity = vec3(hrp.AssemblyLinearVelocity.X, 72.323211, hrp.AssemblyLinearVelocity.Z)
		--hrp.AssemblyLinearVelocity = -((hrp.CFrame.Position - target:GetPivot().Position) / client.deltaTime)
		hrp.Anchored = false
	end

	function antiaim.desync.end_prediction(self)
		local char = lp.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if not hum then return end
		if hum.FloorMaterial == Enum.Material.Air then self.hitfloor = 0 return end
		if self.hitfloor <= 5 then return end
		hrp.Anchored = false
		if antiaim.true_velocity.Y >= 300 then
			antiaim.true_velocity = vec3(antiaim.true_velocity.X, 0, antiaim.true_velocity.Z)
		end
		hrp.AssemblyLinearVelocity = (antiaim.true_velocity or Vector3.new())
	end

	function antiaim.set_pitch_value(self, pitchValue)
		self.pitch = pitchValue;
		return antiaim
	end

	function antiaim.set_yaw_Value(self, yawValue)
		self.yaw = yawValue;
		return antiaim
	end

	local set_pitch = function() end



	function antiaim:update()
		local char = lp.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if not hum then return end
		local yaw, pitch = self.yaw, self.pitch

		if yaw ~= nil then
			hum.AutoRotate = false
			hrp.CFrame = cf(hrp.Position) * angles(0, rad(yaw), 0)
		end

		if pitch ~= nil then
			set_pitch(pitch)
		end
	end

	if (is_PHANTOM_FORCES) then
		antiaim.update = function(self)
			local yaw, pitch = self.yaw, self.pitch


		end
	end

	return antiaim
end)()

function getMoveVector(pos, speed, vertical)
	local cfr = CFrame.new(pos, Vector3.new(pos.X + workspace.CurrentCamera.CFrame.LookVector.X, pos.Y, pos.Z + workspace.CurrentCamera.CFrame.LookVector.Z))

	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.W)) then
		cfr *= CFrame.new(0,0,1)
	end
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.S)) then
		cfr *= CFrame.new(0,0,-1)
	end
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.A)) then
		cfr *= CFrame.new(1,0,0)
	end
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.D)) then
		cfr *= CFrame.new(-1,0,0)
	end

	local diff = (pos - cfr.Position)
	local unit = (diff.Magnitude > 0.5 and diff.Unit or Vector3.zero)
	local pos = CFrame.new(pos + unit * (speed or 1)).p
	if vertical then
		local height = 0
		if uis:IsKeyDown(Enum.KeyCode.Q) then height = -1 end
		if uis:IsKeyDown(Enum.KeyCode.E) then height = 1 end

		if flags.bypass_flag and math.floor(elapsed_ticks) % 3 == 0 then
			height = -height
		end

		pos += Vector3.new(0, height, 0)
	end

	return pos
end

function getFlyVector(pos, speed, vertical)
	local cfr = CFrame.new(pos, Vector3.new(pos.X + camera.CFrame.LookVector.X, pos.Y + camera.CFrame.LookVector.Y, pos.Z + camera.CFrame.LookVector.Z))
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.W)) then
		cfr *= CFrame.new(0,0,1)
	end
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.S)) then
		cfr *= CFrame.new(0,0,-1)
	end
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.A)) then
		cfr *= CFrame.new(1,0,0)
	end
	if (not uis:GetFocusedTextBox() and uis:IsKeyDown(Enum.KeyCode.D)) then
		cfr *= CFrame.new(-1,0,0)
	end

	local diff = (pos - cfr.Position)
	local unit = (diff.Magnitude > 0.5 and diff.Unit or Vector3.zero)
	local pos = CFrame.new(pos + unit * (speed or 1)).Position

	return (pos ~= cfr.Position and cf(pos, cfr.Position) * angles(0, math.rad(180), 0) or cfr)
end

local movement
local lastStrafe = tick()
movement = {
--[[
	fastladder = {
		check = function()
			local char = lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			if uis:IsKeyDown(Enum.KeyCode.Space) and not uis:GetFocusedTextBox() then
				if spider_key.active then
					local center = rootpart.CFrame
					local start = rootpart.CFrame * cf(0, spider_min_height.value, 0)
					local forward = start * cf(0, 0, 1)
					params.FilterDescendantsInstances = {char}
					local rayA = workspace:Raycast(start.Position, start.LookVector, params)
					local rayB = workspace:Raycast(center.Position, center.LookVector, params)
					if not rayA or not rayB then return end
					if rayA.Instance ~= rayB.Instance then
						return
					end
					movement.spider.modes[flags.spider_mode_flag]()
				end
			end
		end,
	},]]
	instantstop = {
		check = function()
			if not flags.instantstop then return end
			local char = library.char or lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			if not hum then return end
			if hum.MoveDirection.Magnitude == 0 then
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)

				rootpart.CFrame -= velocity * globals.frametime
				workspace.CurrentCamera.CFrame -= velocity * globals.frametime
			end
		end,
	},
	highjump = {
		check = function()
			if not flags.highjump then return end
			local char = lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
			if not hum then return end
			local velocity = rootpart.AssemblyLinearVelocity * vec3(0, 1, 0)
			if velocity.Y < 0 then
				velocity = vec3(0, -velocity.Y / 5, 0)
			end

			rootpart.CFrame += (velocity * globals.frametime) * .75
		end,
	},
	speed = {
		modes = {
			normal = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
				local d = math.floor(elapsed_ticks) % 12 > 6 and velocity * globals.frametime or Vector3.zero

				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			["fastgrim"] = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
				local d = math.floor(elapsed_ticks) % 12 > 4 and velocity * (globals.frametime) or Vector3.zero
				d *= (math.floor(elapsed_ticks) % 20) / 2
				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			["spike"] = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
				local d = vec3()
				local e = tick() - elapsedPingTime
				if (lastRegistered < currentRegistered) then
					lastRegistered = currentRegistered
					d = velocity * (globals.frametime)
					elapsedPingTime = tick()
				end
				if e >= 60 then e = 60 end
				d *= (e * 5)
				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			["grim"] = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
				local d = floor(elapsed_ticks) % 2 == 0 and velocity * (globals.frametime) or Vector3.zero
				d *= 1 + (floor(elapsed_ticks) % 25) / 13.25
				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			["pl"] = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local velocity = hum.MoveDirection * vec3(1, 0, 1)
				local d = floor(elapsed_ticks) % 2 == 0 and velocity * (globals.frametime) or Vector3.zero
				d *= 15
				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			strafe = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				if not moving then
					totalSpeed = 1
					return
				end
				if hum.FloorMaterial ~= Enum.Material.Air then
					hum.Jump = true
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
					rootpart.AssemblyLinearVelocity -= vec3(0, 3, 0)
				end
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
				local d = hum.MoveDirection * totalSpeed * globals.frametime

				totalSpeed = clamp(totalSpeed * 1.1, 0, 32)
				--print(totalSpeed)

				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			ground = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				if not moving then
					totalSpeed = 1
					return
				end
				if hum.FloorMaterial == Enum.Material.Air then
					totalSpeed /= 1.001
					totalSpeed = clamp(totalSpeed, 0.5, 32)
				end
				local velocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
				local d = hum.MoveDirection * totalSpeed * globals.frametime

				totalSpeed = clamp(totalSpeed * 1.1, 0.5, 32)
				--print(totalSpeed)

				rootpart.CFrame += d
				workspace.CurrentCamera.CFrame += d
			end,
			bhop = function()
				local char = library.char or lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				if not moving then
					totalSpeed = 16
					return
				end
				if hum.FloorMaterial ~= Enum.Material.Air and (tick() - lastStrafe) > 0.2 then
					lastStrafe = tick()
					rootpart.AssemblyLinearVelocity = vec3(0, 13, 0)
					totalSpeed += 3
				else
					totalSpeed += 0.5
				end
				rootpart.AssemblyLinearVelocity = (hum.MoveDirection * clamp(totalSpeed, 18, 40)) + vec3(0, rootpart.AssemblyLinearVelocity.Y > 1 and rootpart.AssemblyLinearVelocity.Y - 1.43 or rootpart.AssemblyLinearVelocity.Y, 0)
			end,
			exploit = function()
				local char = (library.char or lp.Character)
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				if (moving) then
					local lerp = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
					totalSpeed = math.lerp(totalSpeed, 45 + (floor(elapsed_ticks) % 5), correctAlpha(0.3, globals.frametime))
					rootpart.AssemblyLinearVelocity = (hum.MoveDirection * totalSpeed) + vec3(0,rootpart.AssemblyLinearVelocity.Y,0)
				else
					totalSpeed = 2
				end
			end,
			multistep = function()
				local char = (library.char or lp.Character)
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				if (moving) then
					local lerp = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1)
					totalSpeed = math.lerp(totalSpeed, 40 + (floor(elapsed_ticks) % 10), correctAlpha(0.1, globals.frametime))
					if floor(elapsed_ticks) % 5 == 0 then
						local moveVector = (hum.MoveDirection * totalSpeed) * globals.frametime
						rootpart.Position += moveVector
						library.send_network_packet("repupdate", rootpart.Position + moveVector, vec3(), vec3(), library.gameClock.getTime())
					else
						totalSpeed += floor(elapsed_ticks) % 4 - 2
						rootpart.AssemblyLinearVelocity = (hum.MoveDirection * totalSpeed) + vec3(0,rootpart.AssemblyLinearVelocity.Y,0)
					end
				else
					totalSpeed = 2
				end
			end
		},
		check = function()
			if not speed_key.active then return end
			local char = (library.char or lp.Character)
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			local hum = char:FindFirstChildWhichIsA("Humanoid")
			if not hum then return end
			if hum.MoveDirection.Magnitude ~= 0 and not hum.SeatPart then
				movement.speed.modes[flags.speed_mode_flag]()
			end
		end,
	},
	phase = {
		phaseIntoPart = function()
			local char = lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end

			local elapsed = math.floor(elapsed_ticks) % 4
			if elapsed == 0 then
				rootpart.CFrame *= angles(rad(90),rad(5),0)
				rootpart.CFrame *= cf(0, -2.23, 0)
				rootpart.CFrame *= angles(rad(-90),rad(-5),0)
			end
		end,
		check = function(self)
			local char = lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end

			if not phase_key.active then
				return
			end

			local center = rootpart.CFrame
			local start = rootpart.CFrame * cf(0, 1, 0)
			local forward = start * cf(0, 0, 1)
			params.FilterDescendantsInstances = {char}
			local rayA = workspace:Raycast(start.Position, start.LookVector, params)
			local rayB = workspace:Raycast(center.Position, center.LookVector, params)
			if not rayA or not rayB then return end
			if rayA.Instance ~= rayB.Instance then
				return
			end

			self:phaseIntoPart()
		end
	},
	spider = {
		modes = {
			exploit = function()
				local hum = (library.char or lp.Character):FindFirstChildWhichIsA("Humanoid")
				if hum.RootPart.Velocity.Y < 5 then
					hum.RootPart.Velocity = hum.RootPart.Velocity + vec3(0, 30, 0)
				end
			end,
			off = function()

			end,
			state = function()
				local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
				hum:ChangeState(Enum.HumanoidStateType.Climbing)
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end,
			velocity = function()
				local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
				hum.RootPart.Velocity = hum.RootPart.Velocity + vec3(0, 6, 0)
			end,
			rotation = function()
				local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
				local elapsed = math.floor(elapsed_ticks) % 3
				if elapsed == 0 then
					hum.RootPart.CFrame = hum.RootPart.CFrame * angles(rad(0), rad(45), rad(1))
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				elseif elapsed == 1 then
					hum.RootPart.CFrame = hum.RootPart.CFrame * angles(rad(-45), rad(-45), rad(45))
				end
				--print(elapsed)
			end,
			jumpangle = function()
				local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
				local elapsed = math.floor(elapsed_ticks) % 3
				if elapsed == 0 then
					hum.RootPart.CFrame = hum.RootPart.CFrame * angles(rad(-90), rad(45), rad(1))
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				elseif elapsed == 1 then
					hum.RootPart.CFrame = hum.RootPart.CFrame * angles(rad(90), rad(-45), rad(0))
				end
				--print(elapsed)
			end,
		},
		check = function()
			local char = library.char or lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			if uis:IsKeyDown(Enum.KeyCode.Space) and not uis:GetFocusedTextBox() then
				if spider_key.active then
					local center = rootpart.CFrame
					local start = rootpart.CFrame * cf(0, spider_min_height.value, 0)
					local forward = start * cf(0, 0, 1)
					params.FilterDescendantsInstances = {char}
					local rayA = workspace:Raycast(start.Position, start.LookVector, params)
					local rayB = workspace:Raycast(center.Position, center.LookVector, params)
					if not rayA or not rayB then return end
					if rayA.Instance ~= rayB.Instance then
						return
					end
					movement.spider.modes[flags.spider_mode_flag]()
				end
			end
		end,
	},
	velocityfix = {
		check = function()
			if not flags.velocityfix then return end
			local char = lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			local hum = lp.Character:FindFirstChildWhichIsA("Humanoid")
			if not hum then return end
			local vel = rootpart.AssemblyLinearVelocity * vec3(0, 1, 0)
			rootpart.AssemblyLinearVelocity = vel + vec3(hum.MoveDirection.X * hum.WalkSpeed, 0, hum.MoveDirection.Z * hum.WalkSpeed)
		end,
	},
	flight = {
		modes = {
			off = function()

			end,
			jump = function()
				local char = library.char or lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				if uis:IsKeyDown(Enum.KeyCode.Space) then
					if floor(elapsed_ticks) % 7 == 0 then
						rootpart.AssemblyLinearVelocity = rootpart.AssemblyLinearVelocity * vec3(1, 0, 1) + vec3(0, 32, 0)
						rootpart.CFrame *= cf(0, 0.5, 0)
					end
				else
					local y_vector = rootpart.AssemblyLinearVelocity * vec3(0, 0.75, 0)

					rootpart.CFrame -= y_vector * globals.frametime
				end
			end,
			experimental = function()
				local char = library.char or lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum then return end
				if uis:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
					rootpart.AssemblyLinearVelocity = camera.CFrame.LookVector * flight_speed.value + vec3(0, 32, 0)
				end

			end,
			cframe = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				local currentSpeed = flight_speed.value
				local flyMoveVector = getFlyVector(rootpart.Position, currentSpeed, true)

				rootpart.CFrame = rootpart.CFrame:Lerp(flyMoveVector, correctAlpha(0.75, globals.frametime))
				rootpart.AssemblyAngularVelocity = Vector3.zero
				rootpart.AssemblyLinearVelocity = Vector3.zero
			end,
			instant = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if not hum then return end
				local moving = hum.MoveDirection.Magnitude > 0.1
				local currentSpeed = flight_speed.value
				local flyMoveVector = getFlyVector(rootpart.Position, currentSpeed, true)
				rootpart.AssemblyLinearVelocity = Vector3.one * 9e9
				rootpart.CFrame = flyMoveVector - rootpart.AssemblyLinearVelocity * globals.frametime
				rootpart.AssemblyAngularVelocity = Vector3.zero
			end,
			sit = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum then return end

				hum.Sit = true

				if rootpart.AssemblyLinearVelocity.Magnitude > 10 then
					rootpart.AssemblyLinearVelocity /= 2
				end

				local velocity = rootpart.AssemblyLinearVelocity

				rootpart.CFrame -= velocity * globals.frametime
				workspace.CurrentCamera.CFrame -= velocity * globals.frametime

				local elapsed = floor(elapsed_ticks) % 60
				if (elapsed % 11 == 0) then
					lerpedFlySpeed = flight_speed.value
				else
					lerpedFlySpeed = math.lerp(lerpedFlySpeed, 0, globals.frametime * 30)
				end
				local flyMoveVector = getMoveVector(rootpart.Position, lerpedFlySpeed, true)
				rootpart.CFrame = rootpart.CFrame:Lerp((CFrame.new(flyMoveVector) + Vector3.new(0, (globals.frametime * 3), 0)) * CFrame.Angles(0, math.rad((os.clock() * 5) % 360), 0), globals.frametime * 20)
				rootpart.CFrame = CFrame.new(rootpart.Position, rootpart.Position + workspace.CurrentCamera.CFrame.LookVector)
				hum.Jump = true
				workspace:FindFirstChild("Seat", true):Sit(hum)
			end,
			vehicle = function()
				local char = lp.Character
				if not char then return end
				local rootpart = char:FindFirstChild("HumanoidRootPart")
				if not rootpart then return end
				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum then return end

				local seatPart = hum.SeatPart
				if not seatPart then return end
				local newPos = getMoveVector(seatPart.Position, flight_speed.value, true)
				local flyMoveVector = (seatPart.Position - newPos)
				seatPart.CFrame += Vector3.new(0, globals.frametime, 0)
				seatPart.AssemblyAngularVelocity = Vector3.zero

				seatPart.AssemblyLinearVelocity = (-flyMoveVector / globals.frametime) * 2
				local cfr = CFrame.new(seatPart.Position, Vector3.new(seatPart.Position.X + 5, seatPart.Position.Y, seatPart.Position.Z + 5)) * CFrame.Angles(0,math.rad(180),0)
				seatPart.CFrame = cfr

				if math.floor(elapsed_ticks) % 5 == 0 then
					seatPart:Sit(hum)
					hum.Jump = true
					seatPart:Sit(hum)
				end
			end
		},
		check = function()
			local char = library.char or lp.Character
			if not char then return end
			local rootpart = char:FindFirstChild("HumanoidRootPart")
			if not rootpart then return end
			if flight_key.active then
				movement.flight.modes[flags.flight_mode_flag]()
			end
		end,
	}
}

local chams_functions = {
	breathe = function(model, flag, clr, onScreen, name)
		if tearParts[model] then
			for _, part in tearParts[model] do
				part:Destroy()
			end
			table.clear(tearParts[model])
			tearParts[model] = nil
		end
		viewport:ClearAllChildren()
		local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
		local outline = chamsContainer:FindFirstChild(model.Name) or Instance.new("Highlight")
		local distance = (workspace.CurrentCamera.CFrame.Position - model:GetPivot().Position).Magnitude
		outline.FillColor, outline.OutlineColor = clr, clr
		outline.FillTransparency, outline.OutlineTransparency = 100 * breathe_effect * 0.01, 100 * breathe_effect * 0.01
		outline.FillTransparency, outline.OutlineTransparency = math.lerp(outline.FillTransparency, 1, math.clamp(distance / 400, 0, 1)), math.lerp(outline.OutlineTransparency, 1, math.clamp(distance / 400, 0, 1))
		outline.Name, outline.Enabled = name or model.Name, outline.OutlineTransparency < 1 or onScreen
		outline.Adornee, outline.Parent = model, chamsContainer
	end,
	normal = function(model, flag, clr, onScreen, name)
		if tearParts[model] then
			for _, part in tearParts[model] do
				part:Destroy()
			end
			table.clear(tearParts[model])
			tearParts[model] = nil
		end
		viewport:ClearAllChildren()
		local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
		local outline = chamsContainer:FindFirstChild(model.Name) or Instance.new("Highlight")
		local distance = (workspace.CurrentCamera.CFrame.Position - model:GetPivot().Position).Magnitude
		outline.FillColor, outline.OutlineColor = clr, clr
		outline.FillTransparency, outline.OutlineTransparency = 0.5, 0.5
		outline.FillTransparency, outline.OutlineTransparency = math.lerp(0.5, 1, math.clamp(distance / 400, 0, 1)), math.lerp(outline.OutlineTransparency, 1, math.clamp(distance / 400, 0, 1))
		outline.Name, outline.Enabled = name or model.Name, outline.OutlineTransparency < 1 or onScreen
		outline.Parent, outline.Adornee = chamsContainer, model
	end,
	inverted = function(model, flag, clr, onScreen, name)
		if tearParts[model] then
			for _, part in tearParts[model] do
				part:Destroy()
			end
			table.clear(tearParts[model])
			tearParts[model] = nil
		end
		viewport:ClearAllChildren()
		local name = name or model.Name
		if not onScreen and chamsContainer:FindFirstChild(name) then
			return chamsContainer:FindFirstChild(name):Destroy()
		end	
		local breathe_effect = math.atan(math.sin(tick() * 2)) * 2 / math.pi
		local outline = chamsContainer:FindFirstChild(name) or Instance.new("Highlight")
		local distance = (workspace.CurrentCamera.CFrame.Position - model:GetPivot().Position).Magnitude
		outline.FillColor, outline.OutlineColor = Color3.new(.5,.5,.5), clr
		outline.FillTransparency, outline.OutlineTransparency = -1, 0
		outline.Name, outline.Enabled = name, outline.OutlineTransparency < 1 or onScreen
		outline.Parent, outline.Adornee = chamsContainer, model
	end,
	tearing = function(model, flag, clr, onScreen)
		if not tearParts[model] then
			local baseParts = {}

			for _,v in model:GetDescendants() do
				if v:IsA("BasePart") then
					local newReflective = weirdCube:Clone()
					newReflective.Size = v.Size * 1.1
					if (v.Size == Vector3.new(2,1,1)) then
						newReflective.Size = Vector3.new(1.2,1.2,1.2) * 1.1
					end
					newReflective.Parent = workspace.CurrentCamera
					newReflective.Name = ""
					baseParts[v] = newReflective
				end
			end
			tearParts[model] = baseParts
		end
		viewport:ClearAllChildren()
		for real, fake in tearParts[model] do
			fake.Color = clr:Lerp(Color3.new(1,1,1),0.5 - 0.5 * math.cos(elapsed_ticks / 60))
			fake.CFrame = real.CFrame
		end
	end,
	material = function(model, flag, clr, onScreen)
		if tearParts[model] then
			for _, part in tearParts[model] do
				part:Destroy()
			end
			table.clear(tearParts[model])
			tearParts[model] = nil
		end
		viewport.CurrentCamera = camera viewport.Parent = library.gui

		local m = viewport:FindFirstChild(model.Name)
		if not onScreen then
			if m then m:Destroy() end
			return
		end

		for _,v in viewport:GetChildren() do
			if not v.Linked.Value or not v.Linked.Value:IsDescendantOf(workspace) then
				v:Destroy()
			else
				local plr = players:GetPlayerFromCharacter(v.Linked.Value)
				local team = plr.Team and plr.Team == lp.Team
				if team then
					v:Destroy()
				end
			end
		end

		if not viewport:FindFirstChild(model.Name) then
			for i,v in model:GetDescendants() do
				if v:IsA("BasePart") then
					v:SetAttribute("linkName", math.random() * math.random(1,1e3))
				end
			end
			local new = cloneref(model)
			if not pcall(function()
					new:FindFirstChildOfClass("Humanoid").RequiresNeck = false
				end) then return end
			new.Archivable = true
			new = new:Clone()
			new.Parent = viewport
			create("ObjectValue", {
				Name = "Linked",
				Value = model,
				Parent = new,
			})
			local this; this = model.AncestryChanged:Once(function()
				this:Disconnect()
				this = nil
				new:Destroy()
			end)
		end

		if not m then return end

		for i,v in model:GetDescendants() do
			if v:IsA("BasePart") then
				local realPart = m:FindFirstChild(v.Name) or getFromAttribute(m, v:GetAttribute("linkName"))
				if realPart then
					realPart.CFrame = v.CFrame
				end
			end
		end
	end,
	occluded = function(model, flag, clr, onScreen)
		if tearParts[model] then
			for _, part in tearParts[model] do
				part:Destroy()
			end
			table.clear(tearParts[model])
			tearParts[model] = nil
		end
		viewport:ClearAllChildren()

		local m = holder:FindFirstChild(model.Name)
		if not onScreen then
			pcall(function()
				local outline = chamsContainer:FindFirstChild(model.Name)
				local occluded = chamsContainer:FindFirstChild(model.Name .. "?")
				occluded:Destroy()
				outline:Destroy()
			end)
			if m then m:Destroy() end
			return
		end

		pcall(function()
			for _,v in holder:GetChildren() do
				if not v.Linked.Value or not v.Linked.Value:IsDescendantOf(workspace) then
					v:Destroy()
				else
					local plr = players:GetPlayerFromCharacter(v.Linked.Value)
					local team = plr.Team and plr.Team == lp.Team
					if team then
						v:Destroy()
					end
				end
			end
		end)

		if not holder:FindFirstChild(model.Name) then
			for i,v in model:GetDescendants() do
				if v:IsA("BasePart") then
					v:SetAttribute("linkName", math.random() * math.random(1,1e3))
				end
			end
			local new = cloneref(model)
			new.Archivable = true
			new = new:Clone()
			if not pcall(function()
					new:FindFirstChildOfClass("Humanoid"):Destroy()
				end) then return end
			new.Parent = holder
			local chams = Instance.new("Highlight")
			chams.FillColor, chams.OutlineColor = clr, clr
			chams.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			chams.FillTransparency, chams.OutlineTransparency = 0, 0
			chams.Name, chams.Enabled = model.Name .. "?", onScreen
			chams.Parent, chams.Adornee = chamsContainer, new
			create("ObjectValue", {
				Name = "Linked",
				Value = model,
				Parent = new,
			})
			local outline = chamsContainer:FindFirstChild(model.Name) or Instance.new("Highlight")
			outline.FillColor, outline.OutlineColor = clr, clr:Lerp(rgb(255,255,255),0.1)
			outline.DepthMode = Enum.HighlightDepthMode.Occluded
			outline.FillTransparency, outline.OutlineTransparency = 0.99, 1
			outline.Name, outline.Enabled = model.Name, onScreen
			outline.Parent, outline.Adornee = chamsContainer, model

			local this; this = model.AncestryChanged:Once(function()
				this:Disconnect()
				this = nil
				new:Destroy()
				chams:Destroy()
			end)
			local m = new
			for i,v in m:GetDescendants() do
				if v:IsA("CharacterMesh") then
					local meshId = v.MeshId
					local bodyPart = v.BodyPart.Name
					for _,v in m:GetChildren() do
						if v:IsA("BasePart") and v.Name:gsub(" ", "") == bodyPart then
							local mesh = Instance.new("SpecialMesh")
							mesh.MeshId = string.format("rbxassetid://%s", meshId)
							mesh.Parent = v
						end
					end
					v:Destroy()
				end
			end
			for i,v in model:GetDescendants() do
				if v:IsA("BasePart") then
					local realPart = m:FindFirstChild(v.Name) or getFromAttribute(m, v:GetAttribute("linkName"))
					if realPart then
						realPart.Size *= 0.98
						realPart:BreakJoints()
						realPart.CanTouch = false
						realPart.Material = Enum.Material.SmoothPlastic
						pcall(function() realPart.TextureID = "" end)
						realPart.CanCollide = false
						realPart.CanQuery = false
						realPart.CFrame = v.CFrame
						local weld = Instance.new("Weld")
						weld.Part0 = v
						weld.Part1 = realPart
						weld.Name = ""
						weld.Parent = realPart
					end
				end
			end
		end

		pcall(function()
			local outline = chamsContainer:FindFirstChild(model.Name)
			local occluded = chamsContainer:FindFirstChild(model.Name .. "?")
			occluded.Enabled, outline.Enabled = onScreen, onScreen
		end)

		if not m then return end


	end,
}

local rgb, cf, vec3, floor, ceil, clamp = Color3.fromRGB, CFrame.new, Vector3.new, math.floor, math.ceil, math.clamp

local esp, library, baseProperties = {}, library or {}, {
	TextLabel = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		RichText = true,
	}
}
function library:new(class, properties, children)
	local object = Instance.new(class)

	if baseProperties[class] then
		for prop, value in baseProperties[class] do
			object[prop] = value
		end
	end

	for prop, value in properties do
		object[prop] = value
	end

	if children then
		for _, child in children do
			child.Parent = object
		end
	end

	return object
end

esp.config = {
	seraph = `<font color="rgb(220,50,50)"><b>[S]</b></font>`,
	ax = `<font color="rgb(220,0,9)"><b>EXP</b></font>`,
	health_bar_width = 35,
	health_bar_padding = 5,
	font = fonts.Tahoma or Font.new("rbxassetid://12187362578", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
	health_alive = rgb(255,255,255),
	health_dead = rgb(0,0,0),
	color = rgb(255,255,255),
	secondary = rgb(),

	features = {}
}

library.esp_gui = library:new("ScreenGui", {
	Parent = gethui and gethui() or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

function library:isBright(rgb) 
	return (rgb.R > .5 or rgb.B > .5 or rgb.G > .5) 
end

function library:toRgbValues(color: Color3)
	return clamp(floor(color.R * 255), 0, 255),clamp(floor(color.G * 255), 0, 255),clamp(floor(color.B * 255), 0, 255)
end

function library:invert(color: Color3) 
	local r, g, b = library:toRgbValues(color)
	return rgb(255 - r, 255 - g, 255 - b)
end

function esp:update_to_theme(frame)
	local health = frame.health
	local background = health.backgroundbar
	local clr = flags.esp_primary.Color
	frame.glow.ImageColor3 = clr
	health.outline.Color = clr
	background.bg.BackgroundColor3 = clr:lerp(rgb(), .8)
end

function esp:create()
	return library:new("Frame",{
		BackgroundTransparency = 1,
		Size = UDim2.new(0,100,0,250),
		Position = UDim2.new(0.5,0,0.5,0),
		Parent = library.esp_gui
	}, {
		library:new("UIGradient", {
			Name = "gradient",
			Rotation = -90
		}),

		library:new("UIStroke", {
			Name = "box",
			Thickness = 1,
			Color = esp.config.color,
			LineJoinMode = Enum.LineJoinMode.Miter,
		}, {
			library:new("UIGradient", {
				Name = "gradient"
			})
		}),

		library:new("ImageLabel", {
			Name = "cat",
			ImageTransparency = 1,
			BackgroundTransparency = 1,
			Image = "rbxassetid://101187568031385",
			ImageColor3 = rgb(255,255,255),
			ImageTransparency = 0.25,
			Size = UDim2.new(1,0,1,0),
			ZIndex = -3,
		}),

		library:new("UIStroke", {
			Name = "outline",
			ZIndex = -1,
			Thickness = 2,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Color = rgb(0,0,0)
		}),

		library:new("UIStroke", {
			Name = "inner",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			ZIndex = -1,
			Thickness = 1,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Color = rgb(0,0,0)
		}),

		library:new("ImageLabel", {
			Name = "glow",
			Image = "rbxassetid://18245826428",
			BackgroundTransparency = 1,
			ImageColor3 = esp.config.color,
			ZIndex = -1,
			ImageTransparency = 0.8,
			Size = UDim2.new(1, 40, 1, 40),
			Position = UDim2.new(0, -20, 0, -20),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(21, 21, 79, 79)
		}, {
			library:new("UICorner", {
				CornerRadius = UDim.new(0, 4)
			})	
		}),

		-- start footer
		library:new("Frame", {
			Name = "footer",
			AnchorPoint = Vector2.new(0.5,0),
			Position = UDim2.new(0.5,0,1,5),
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			ZIndex = 25,
		}, {

			library:new("UIListLayout", {
				Name = "padding",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 5)
			}),

			library:new("TextLabel", {
				Name = "distance",
				Text = `0M`,
				Size = UDim2.new(0,0,0,0),
				AutomaticSize = Enum.AutomaticSize.XY,
				FontFace = fonts.Pixel,
				TextSize = 12,
				TextStrokeTransparency = 0.5,
				TextColor3 = rgb(255,255,255),
				LayoutOrder = 1,
			}),

			library:new("Frame", {
				Name = "ammo",
				Size = UDim2.new(1,0,0,4),
				BackgroundColor3 = rgb(2, 2, 2),
				BackgroundTransparency = 0.4,
				LayoutOrder = 2,
			}, {
				library:new("ImageLabel", {
					Name = "glowbg",
					Image = "rbxassetid://18245826428",
					BackgroundTransparency = 1,
					ZIndex = -1,
					ImageColor3 = rgb(),
					ImageTransparency = 0.8,
					Size = UDim2.new(1, 40, 1, 40),
					Position = UDim2.new(0, -20, 0, -20),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(21, 21, 79, 79)
				}, {
					library:new("UICorner", {
						CornerRadius = UDim.new(0, 4)
					})	
				}),
				library:new("Frame", {
					Name = "fill",
					Position = UDim2.new(0,1,0,-1),
					Size = UDim2.new(1,-2,0,2),
					BackgroundColor3 = rgb(255, 255, 255),
					BackgroundTransparency = 0,
					LayoutOrder = 2,
				}, {
					library:new("UIGradient", {
						Name = "gradient",
						Rotation = 90,
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, rgb(255,255,255)),
							ColorSequenceKeypoint.new(1, rgb(158, 158, 158))
						}
					}),
				}),
			}),

		}),
		-- stop footer

		-- start header
		library:new("Frame", {
			Name = "header",
			Position = UDim2.new(0.5,0,0,-5),
			Size = UDim2.new(1,0,0,0),
			AutomaticSize = Enum.AutomaticSize.Y,
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1
		}, {

			library:new("UIListLayout", {
				Name = "padding",
				Padding = UDim.new(0, 1),
				VerticalAlignment = Enum.VerticalAlignment.Bottom
			}),

			library:new("TextLabel", {
				Name = "team",
				Text = `<font color="rgb(255,0,0)"><b>[N]</b></font> Neutral`,
				Size = UDim2.new(1,0,0,0),
				AutomaticSize = Enum.AutomaticSize.Y,
				FontFace = esp.config.font,
				TextStrokeTransparency = 0.5,
				TextColor3 = rgb(255,255,255),
				TextSize = 15,
				LayoutOrder = 2,
			}),

			library:new("TextLabel", {
				Name = "username",
				Text = `{esp.config.seraph} {esp.config.ax} username`,
				Size = UDim2.new(1,0,0,0),
				AutomaticSize = Enum.AutomaticSize.Y,
				FontFace = esp.config.font,
				TextStrokeTransparency = 0.5,
				TextSize = 15,
				TextColor3 = rgb(255,255,255),
				LayoutOrder = 1,
			}),

		}),

		library:new("Frame", {
			Name = "flags",
			Position = UDim2.new(1,10,0,1),
			Size = UDim2.new(1,0,0,0),
			AutomaticSize = Enum.AutomaticSize.Y,
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1
		}, {

			library:new("UIListLayout", {
				Name = "padding",
				Padding = UDim.new(0, 1),
				VerticalAlignment = Enum.VerticalAlignment.Bottom
			}),

			library:new("TextLabel", {
				Name = "team",
				Text = ``,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1,0,0,0),
				AutomaticSize = Enum.AutomaticSize.Y,
				FontFace = fonts.Pixel,
				TextStrokeTransparency = 0.5,
				TextColor3 = rgb(255,255,255),
				TextSize = 15,
				LayoutOrder = 2,
			}),

		}),
		-- end header

		--[[player_icon = library:new("ImageLabel", {
			Name = "icon",
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 5, 0, -5),
			BackgroundTransparency = 0,
			BackgroundColor3 = rgb(0, 0, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.new(0,15,0,15),
		}),]]

		-- health
		library:new("Frame", {
			Name = "health",
			--Size = UDim2.new(0, esp.config.health_bar_width, 1, 2),
			--Position = UDim2.new(0, -(esp.config.health_bar_width + esp.config.health_bar_padding), 0, -1),
			--Size = UDim2.new(esp.config.health_bar_width / 1000, 0, 1, 2),
			--Position = UDim2.new(0 - esp.config.health_bar_width / 1000, -(esp.config.health_bar_padding), 0, -1),
			Size = UDim2.new(esp.config.health_bar_width / 1000, 0, 1, 0),
			Position = UDim2.new(0 - esp.config.health_bar_width / 1000, -(esp.config.health_bar_padding), 0, 0),
			BackgroundTransparency = 1,
		}, {
			library:new("UISizeConstraint", {
				MaxSize = Vector2.new(math.huge, math.huge),
				MinSize = Vector2.new(1, 0)
			}),

			--[[
			library:new("TextLabel", {
				Name = "percentage",
				BackgroundTransparency = 1,
				TextColor3 = rgb(255,255,255),
				TextStrokeTransparency = 0.5,
				Position = UDim2.new(0.5,0,1.001,5),	
				AnchorPoint = Vector2.new(0.5,0),
				FontFace = esp.config.font,
				Rotation = 0,
				TextSize = 12,
				Text = "100%",
				ZIndex = 5,
			}),
			]]

			library:new("TextLabel", {
				Name = "percentage",
				BackgroundTransparency = 1,
				TextColor3 = rgb(255,255,255),
				TextStrokeTransparency = 0.5,
				--Position = UDim2.new(-1,0,0.5,0),
				--AnchorPoint = Vector2.new(0,0.5),
				Position = UDim2.new(-1,0,0,0),
				AnchorPoint = Vector2.new(0.5,0),
				Size = UDim2.new(1,0,0,0),
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Center,
				FontFace = esp.config.font,
				Rotation = 0,
				TextSize = 12,
				Text = "100%",
				ZIndex = 25,
			}),

			library:new("Frame", {
				Name = "backgroundbar",
				BackgroundColor3 = rgb(0,0,0),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5,0,1,0),
				AnchorPoint = Vector2.new(0.5,1),
			}, {

				library:new("Frame", {
					Name = "bg",
					BackgroundColor3 = esp.config.color:lerp(rgb(), .8),
					BorderSizePixel = 0,
					Size = UDim2.new(1,0,1,0),
					Position = UDim2.new(0.5,0,1,0),
					AnchorPoint = Vector2.new(0.5,1),
					ZIndex = 10,
				}, {
					library:new("UIStroke", {
						Name = "first",
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						ZIndex = 5,
						Thickness = 1,
						Transparency = 0.8,
						LineJoinMode = Enum.LineJoinMode.Miter,
						Color = esp.config.color
					}),
					library:new("UIStroke", {
						Name = "middle",
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						ZIndex = 4,
						Thickness = 2,
						Transparency = 0.9,
						LineJoinMode = Enum.LineJoinMode.Miter,
						Color = esp.config.color
					}),
					library:new("UIStroke", {
						Name = "farthest",
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						ZIndex = 3,
						Thickness = 3,
						Transparency = 0.99,
						LineJoinMode = Enum.LineJoinMode.Miter,
						Color = esp.config.color
					}),
				}),


				library:new("ImageLabel", {
					Name = "glowbg",
					Image = "rbxassetid://18245826428",
					BackgroundTransparency = 1,
					ZIndex = -1,
					ImageColor3 = rgb(),
					ImageTransparency = 0.8,
					Size = UDim2.new(1, 40, 1, 40),
					Position = UDim2.new(0, -20, 0, -20),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(21, 21, 79, 79)
				}, {
					library:new("UICorner", {
						CornerRadius = UDim.new(0, 4)
					})	
				}),

				library:new("UIGradient", {
					Name = "gradient"
				}),
				library:new("ImageLabel", {
					Name = "glow",
					Image = "rbxassetid://18245826428",
					BackgroundTransparency = 1,
					ZIndex = -1,
					ImageTransparency = 0.5,
					Size = UDim2.new(1, 20, 1, 20),
					Position = UDim2.new(0.5,0,1,0),
					AnchorPoint = Vector2.new(0.5,1),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(21, 21, 79, 79)
				}, {
					library:new("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),
					library:new("UIGradient", {
						Name = "gradient",
						Rotation = 90
					})
				}),
			}),

			library:new("Frame", {
				Name = "bar",
				BackgroundColor3 = rgb(255,255,255),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,1,0),
				AnchorPoint = Vector2.new(0.5,1),
				ZIndex = 2
			}, {
				library:new("UIGradient", {
					Name = "gradient",
					Rotation = 90
				})
			}),


			library:new("UIStroke", {
				Name = "outline",
				ZIndex = 30,
				Thickness = 1,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Color = esp.config.color
			}),

			library:new("UIStroke", {
				Name = "border",
				ZIndex = -2,
				Transparency = 0.5,
				Thickness = 2,
				LineJoinMode = Enum.LineJoinMode.Miter,
				Color = rgb(0,0,0)
			}),
		})
	})
end

local function worldToScreenPoint(obj)
	return workspace.CurrentCamera:WorldToScreenPoint(typeof(obj) == 'CFrame' and obj.Position or obj)
end

function getScreenRect(cf, size, minPixels)
	minPixels = minPixels or 10

	local half = size * 0.5

	local corners = {
		cf * Vector3.new(-half.X,  half.Y, 0),
		cf * Vector3.new( half.X,  half.Y, 0),
		cf * Vector3.new(-half.X, -half.Y, 0),
		cf * Vector3.new( half.X, -half.Y, 0),
	}

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for _, worldPos in corners do
		local screenPos, onScreen = worldToScreenPoint(worldPos)
		if not onScreen then
			return nil
		end

		minX = math.min(minX, screenPos.X)
		minY = math.min(minY, screenPos.Y)
		maxX = math.max(maxX, screenPos.X)
		maxY = math.max(maxY, screenPos.Y)
	end

	local width  = maxX - minX
	local height = maxY - minY
	local cx = minX + width * 0.5
	local cy = minY + height * 0.5
	width  = math.max(width,  minPixels)
	height = math.max(height, minPixels)
	minX = cx - width * 0.5
	minY = cy - height * 0.5

	return minX, minY, width, height
end

function getFontSize(worldPos, base, min, max, scale)
	local camCF = workspace.CurrentCamera.CFrame
	local relative = camCF:PointToObjectSpace(worldPos.Position)

	local dist = (camCF.Position - worldPos.Position).Magnitude

	return clamp(base * (1 - clamp(dist / (250 * (scale or 1)), 0, 1)), 1, max or 36)
end

function esp:hide(player)
	local frame = esp_frames[player]
	if frame then
		frame.Visible = false
	end
end

function interp(base, next, t, ft)
	return math.lerp(base, next, t*ft)
end

function esp:full_render(dt, player, position, size, healthRatio)
	local healthRatio = healthRatio

	local frame = esp_frames[player]

	local ccf = workspace.CurrentCamera.CFrame
	local size = size or vec3(2, 4, 1)
	local pos = cf(position, ccf.LookVector + position) * cf(0, -0.25, 0)

	local distance = (ccf.Position - position).Magnitude

	esp:update_to_theme(frame)
	local features = flags.featureflags or {}
	local dist = frame.footer.distance
	local health = frame.health
	local healthgrad = health.bar.gradient
	local healthglow = health.backgroundbar.glow
	local healthbg = health.backgroundbar.bg
	local header = frame.header

	if flags.esp_distance then
		dist.Text = `{floor(distance)}{flags.esp_suffix and "M" or ""}`
		dist.Visible = true
	else
		dist.Visible = false
	end

	if flags.esp_healthbar then
		health.Size = UDim2.new(flags.health_bar_width / 1000, 0, 1, 0)
		health.Position = UDim2.new(0 - flags.health_bar_width / 1000, -(esp.config.health_bar_padding), 0, 0)
		health.bar.Size = UDim2.fromScale(1, healthRatio)
		healthgrad.Color = ColorSequence.new(flags.maxhealth.Color, flags.minhealth.Color)
		healthgrad.Offset = -Vector2.new(0,1 - healthRatio)

		if flags.health_bar_glow then
			local glow_gradient = healthglow.gradient

			healthglow.Size = UDim2.new(1, 20, healthRatio, 20)
			healthglow.Position = UDim2.new(0.5, 0, 1, 10)

			healthglow.ImageTransparency = 0.3

			glow_gradient.Color = healthgrad.Color
			glow_gradient.Offset = -Vector2.new(0,1 - healthRatio)
		else
			healthglow.Visible = false
		end


		health.percentage.Text = ""

		local thickness = clamp(1 - (distance / 250), 0.3, 1)
		health.outline.Thickness = thickness
		healthbg.first.Thickness = thickness
		healthbg.middle.Thickness = clamp(2 - (distance / 250) * 2, 0.3, 2)
		healthbg.farthest.Thickness = clamp(3 - (distance / 250) * 3, 0.3, 3)
		health.border.Thickness = thickness <= 0.5 and 1 or 2
		health.Visible = true
	else
		health.Visible = false
	end

	if flags.bounding_box and flags.esp_gradient then
		frame.box.Color = rgb(255,255,255)
		frame.box.gradient.Color = rgbseq(flags.esp_secondary.Color, flags.esp_primary.Color)
		frame.box.gradient.Rotation = flags.esp_gradient_rotation
	else
		frame.box.Color = flags.esp_secondary.Color
		frame.box.gradient.Color = rgbseq(rgb(255,255,255),rgb(255,255,255))
	end

	local box = flags.bounding_box
	frame.box.Transparency = box and 0 or 1
	frame.inner.Transparency = box and 0 or 1
	frame.outline.Transparency = box and 0 or 1
	frame.glow.Visible = box

	if flags.esp_username then
		header.username.Text = flags.prefer_display_name and player.DisplayName or player.Name
		header.username.Visible = true
	else
		header.username.Visible = false
	end

	if flags.esp_ammobar then
		frame.footer.ammo.Visible = true
		frame.footer.ammo.fill.BackgroundColor3 = flags.ammo_bar_color.Color
	else
		frame.footer.ammo.Visible = false
	end

	if box and flags.esp_cat then
		frame.cat.ImageTransparency = 0.25
	else
		frame.cat.ImageTransparency = 1
	end

	header.team.Visible = false
	frame.BackgroundTransparency = box and flags.esp_filled and 1-flags.esp_primary.Transparency or 1
	frame.gradient.Color = ColorSequence.new(flags.esp_secondary.Color, flags.esp_primary.Color)
end


function esp:render(dt, player, position, size, healthRatio)
	local healthRatio = clamp(healthRatio / 100, 0, 1)
	if not esp_frames[player] then
		esp_frames[player] = esp:create(player)
		task.spawn(esp.full_render, esp, dt, player, position, size, healthRatio)
	end

	local frame = esp_frames[player]

	local screenPos, visible = workspace.CurrentCamera:WorldToScreenPoint(position)
	if not visible then
		frame:SetAttribute("renderLast", 0)
		frame.Visible = false
		return
	end

	local ccf = workspace.CurrentCamera.CFrame
	local pos = cf(position, ccf.LookVector + position) * cf(0, -0.25, 0)
	local distance = (ccf.Position - pos.Position).Magnitude
	local x, y, w, h = getScreenRect(pos, size*(1+(distance/300)))

	local distance = (ccf.Position - position).Magnitude

	if not x then
		frame.Visible = false
		return
	end

	if not frame:GetAttribute("renderLast") then frame:SetAttribute("renderLast", tick()) end
	local lastHealth = frame:GetAttribute('lastHealth') or healthRatio
	local lastForce = frame:GetAttribute("renderLast")
	local forceRefresh

	local dist = frame.footer.distance
	local health = frame.health
	local header = frame.header


	if lastHealth ~= healthRatio then
		forceRefresh = true
	end
	frame:SetAttribute('lastHealth', healthRatio)
	if tick() - lastForce >= 8.5 then
		lastForce = tick()
		forceRefresh = true
	end

	frame:SetAttribute("renderLast", lastForce)
	if forceRefresh then
		task.spawn(esp.full_render, esp, dt, player, position, size, healthRatio)
	end


	--[[header.team.TextSize = getFontSize(pos, 17, 1, 36, 1.5)
	dist.TextSize = getFontSize(pos, 12, 1, 36, 1.5)
	header.username.TextSize = getFontSize(pos, 17, 1, 36, 1.5)
	health.percentage.TextSize = getFontSize(pos, 12, 1, 36, 1.5)]]

	header.team.TextSize = 12 * flags.esp_font_size_multiplier * (math.clamp(1 - (distance / 1000), 0.5, 1))
	dist.TextSize = 10 * flags.esp_font_size_multiplier * (math.clamp(1 - (distance / 1000), 0.5, 1))
	header.username.TextSize = 12 * flags.esp_font_size_multiplier
	health.percentage.TextSize = 10 * flags.esp_font_size_multiplier
	local flagtext = ""
	--[[if library.player_state and library.player_state[player] and library.player_state[player].exploiting then
		flagtext ..= `<font color="{rgbstr(rgb(220,0,9):lerp(rgb(133, 133, 133), 1 - library.player_state[player].exploitCharge / 2))}"><b>EXPLOITING [{library.player_state[player].exploitCharge}s]</b></font>`
	end]]
	for _, flag in frame.flags:GetChildren() do
		if not flag:IsA("TextLabel") then continue end
		flag.TextSize = 8.5 * flags.esp_font_size_multiplier * (math.clamp(1 - (distance / 1000), 0.5, 1))
		flag.Text = flagtext
	end

	local entry = player.Character
	if entry then
		local weapon = entry:FindFirstChildOfClass("Tool")
		if entry and weapon then
			pcall(function()frame.footer.ammo.fill.Size = UDim2.new(clamp((weapon:GetAttribute("Ammo")) / weapon:GetAttribute("MaxAmmo"), 0, 1), 0, 1, 0)end)
		end
	end

	dist.Text = `{floor(distance)}M`

	frame.Position = UDim2.fromOffset(x, y)
	frame.Size = UDim2.fromOffset(w, h)

	frame.Visible  = true
end

	local function render_chams(plr, model, flag, clr, mat)
		if not model then return end
		local chams_color = clr or themes.preset["1"]:Lerp(themes.preset["3"], 0.5 + 0.5 * math.cos(elapsed_ticks / 12))
		if not flag then
			if chamsContainer:FindFirstChild(plr.Name) then
				chamsContainer:FindFirstChild(plr.Name):Destroy()
			end
		else
			local _, onScreen = workspace.CurrentCamera:WorldToScreenPoint((model:FindFirstChild("Torso") or model:GetPivot()).Position)

			chams_functions[mat](model, flag, chams_color, onScreen, plr.Name)
		end
	end

	local teamCheck = library.aimbot and library.aimbot.team_check
	teamCheck = function(player)
		local char = player.Character
		if not char then return false end
		local localTeam = lp.Team.Name
		if localTeam == 'Criminals' then
			return player.Team.Name == 'Guards'
		end
		if localTeam == 'Inmates' then
			return player.Team.Name == 'Guards'
		end
		if player.Team.Name == 'Inmates' and not char:GetAttribute("Hostile") then
			return false
		end
		return player.Team.Name ~= localTeam
	end
	--print(teamCheck)
	function update_esp(dt)
		local t = {}

		task.spawn(function()
			for _, player in players:GetPlayers() do
				if player == lp then
					render_chams(player, lp.Character, flags.self_chams, flags.self_primary_color.Color:Lerp(flags.self_secondary_color.Color, 0.5 + 0.5 * math.cos(elapsed_ticks / 12)), flags.chams_self_material)
					continue
				end
				local team = player.Team
				local char = player.Character
				if not char or (teamCheck ~= nil and not pcall(teamCheck, player)) then task.spawn(esp.hide, esp, player) continue end

				local localTeam = lp.Team

				local isActive, isEnemy = flags.masterswitch, true
				isEnemy = teamCheck ~= nil and teamCheck(player) or player.Team ~= lp.Team
				if flags.onlyenemy and isActive then
					isActive = isEnemy
				end

				local charInstance = char

				if isActive then
					local _, boxSize = charInstance:GetBoundingBox()
					if (boxSize.Magnitude >= 15) then
						boxSize = vec3(2, 5, 1)
					end
					local health
					pcall(function()
						local humanoid = charInstance:FindFirstChildOfClass("Humanoid")
						if humanoid then
							health = humanoid.Health
						end
					end)
					if not health then task.spawn(esp.hide, esp, player) continue end
					local obj
					xpcall(function()
						obj = char.Torso
					end, function() obj = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") end)
					task.spawn(esp.render, dt, esp, player, obj.Position, boxSize + vec3(0,0.5,0), health or 0)
				else
					task.spawn(esp.hide, esp, player)
				end

				local isActive = flags.enemy_chams
				if flags.enemy_only and isActive then
					isActive = isEnemy
				end


				local t = flags.enemy_animated and 0.5 + 0.5 * math.cos(elapsed_ticks / 12) or 0
				task.spawn(render_chams, player, charInstance, isActive, flags.enemy_primary_color.Color:Lerp(flags.enemy_secondary_color.Color, t), flags.chams_enemy_material)
			end
		end)

	end

local global_shadows = lighting.GlobalShadows
local function update_render()
	if not colorcorrection.Parent then
		colorcorrection = Instance.new("ColorCorrectionEffect")
		colorcorrection.Name = "colorcorrectionPriv"
	end

	colorcorrection.Parent = workspace.CurrentCamera
	colorcorrection.TintColor = flags.world_color_correction.Color

	xpcall(function() sky.Parent = (flags.world_skybox and flags.world_skybox ~= 'off') and lighting or nil end, function() 
		sky = Instance.new("Sky")
		sky.Name = "skyboxPriv"
	end)
	if flags.world_skybox ~= 'off' then
		for skyboxProp, skyboxVal in skyboxes[flags.world_skybox] do
			sky[skyboxProp] = skyboxVal
		end
	end

	local case = flags.world_nightmode
	if case == "fullbright" then
		lighting.GlobalShadows = false
		colorcorrection.Brightness = 0.1
	elseif case == "nightmode" then
		lighting.GlobalShadows = global_shadows
		colorcorrection.Brightness = -0.1
	else
		lighting.GlobalShadows = global_shadows
		colorcorrection.Brightness = 0.0
	end
end

local function update_antiaim(dt)
	if flags.desired_breaker then
		thread(antiaim.desiredBreaker)
	end
	if flags.velocity_breaker then
		antiaim.desync:start_prediction()
	end
end

insert(cons, services.runService.Stepped:Connect(function()
	if not flags.velocity_breaker then return end
	antiaim.desync:end_prediction()
end))
local cfg, config_write_tick = library:get_config(), tick()
insert(cons, services.runService.RenderStepped:Connect(function(dt)
	globals.frametime = dt

	if tick() - config_write_tick >= 1 and cfg ~= library:get_config() and not mapped.configs[configName] then
		config_write_tick = tick()
		writefile(library.directory .. `/configs/{configName}.cfg`, library:get_config())
		cfg = library:get_config()
		if flags.autosave_notification then
			createNotification({text = "autosaving config..."})
		end
		--socket:Send("0x321655Dead")
	end


	local lua_len = 0
	for k in loaded_luas do
		lua_len += 1
	end
	lua:change_visibility(lua_len > 0)
	elapsed_ticks += dt * 60

	-- spawn new feature threads
	thread(update_render)
	thread(update_antiaim)
end))

services.runService:BindToRenderStep("camera", Enum.RenderPriority.Last.Value + 1, function()
	thread(update_esp)
end)


task.spawn(function()

	local userIdList, customIconList, tracked_players = {}, {}, {}

	local function connect()
		local success, ws = pcall(function()
			return WebSocket.connect("wss://seraph.wtf/ws")
		end)
		if success and ws then
			return ws
		else
			createNotification({text = "Failed to connect to Websocket, retrying in 1 second..."})
			task.wait(1)
			return connect()
		end
	end


	local OnClose = Instance.new("BindableEvent")

	local OnMessage = Instance.new("BindableEvent")

	task.spawn(function()
		task.wait(2)
		local webSocket = connect()
		webSocket.OnClose:Connect(function(...)
			OnClose:Fire(...)
		end)
		webSocket.OnMessage:Connect(function(...)
			OnMessage:Fire(...)
		end)
	end)

	OnClose.Event:Connect(function(code, reason)
		createNotification({text = "Websocket closed!"})
		task.wait(.1)
		createNotification({text = "Attempting to reconnect in 2 seconds..."})
		task.delay(2, function()
			webSocket = connect() --WebSocket.connect("wss://ws.seraph.wtf:1000")
			webSocket.OnClose:Connect(function(...)
				OnClose:Fire(...)
			end)
			webSocket.OnMessage:Connect(function(...)
				OnMessage:Fire(...)
			end)
			createNotification({text = "Reconnected to Websocket!"})
		end)
	end)

	task.spawn(function()

		function addCharacterStuff(char, which)
			if not char:FindFirstChild("seraph fiery horns") and which == "fieryHorns" then
				local fiery = game:GetObjects('rbxassetid://1744060292')[1]:Clone() 
				fiery.Handle.Fire.Color,fiery.Handle.Fire.SecondaryColor = rgb(151, 125, 214), rgb(121, 96, 180) 
				fiery.Name = "seraph fiery horns" 
				fiery.Parent = workspace
				fiery.Parent = char
				local weld = Instance.new("Weld")
				weld.Part1, weld.Part0 = char:FindFirstChild("Head"), fiery.Handle
				weld.C0,weld.C1 = cf(0, -0.665, -0),cf(0, 0.57, 0)
				weld.Parent = fiery.Handle
			end

			if which == "headless" then
				pcall(function()
					local head = char:FindFirstChild("Head")
					if head:IsA("MeshPart") then
						head.MeshId = "rbxassetid://134082579"
						head.TextureID = ""
					end
					local mesh = head:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh")
					mesh.MeshType = Enum.MeshType.Head
					mesh.Scale = vec3(0, 0, 0)
					mesh.Name = "seraph headless"
					mesh.Parent = head
				end)
			end
		end

		function library:send_seraph_chat(message, username, hexColor)
			local channel = services.textChatService.TextChannels:FindFirstChild("Global") or services.textChatService.TextChannels:FindFirstChild("RBXSystem")
			if not channel then channel = services.textChatService.TextChannels:FindFirstChildOfClass("TextChannel") end
			channel:DisplaySystemMessage(
				`<font face="Arial" color='{rgbstr(themes.preset.button_alt)}'>[seraph.wtf]</font> <font color='{hexColor}' face="Arial">{username}:</font> {message}` -- <font color='{hexColor}'>{username}</font><font color='rgb(155,155,155)'>:</font> <font color='rgb(233,233,233)'>{message}</font>
			)
		end
		
		for _, gui in services.coreGui:GetDescendants() do
			if gui:IsA("TextBox") and gui:FindFirstAncestor("ExperienceChat") then
				local selfCons = {}
				selfCon = gui.FocusLost:Connect(function(...)
					local textBox = ...
					if gui.Text:sub(1,1) == "@" then
						local ogText = gui.Text
						gui.Text = ""
						return webSocket:Send(http_service:JSONEncode({
							type = "addChatMessage",
							name = seraphAcc.username or seraphAcc.name or lp.Name,
							message = ogText:sub(2),
							hexColor = seraphAcc.hexColor or "#FFF"
						}))

					end
					for _, con in selfCons do
						if con == selfCon then continue end
						con:Defer(...)
					end
				end)
				--print(#getconnections(gui.FocusLost))

				for _, connection in getconnections(gui.FocusLost) do
					if pcall(function() return tostring(connection.Function) end) and connection.Function ~= nil then
						print("Connection found")
					else
						table.insert(selfCons, connection)
						connection:Disable()
						connection:Enable()
					end
				end
			end
		end
	--[[
		services.textChatService.SendingMessage:Connect(function(textChatMessage)
			if textChatMessage and textChatMessage.Text:sub(1,1) == "@" then
				local ogText = textChatMessage.Text
				textChatMessage.Text = "/e "
				textChatMessage.TextChannel = nil
				return webSocket:Send(http_service:JSONEncode({
					type = "addChatMessage",
					name = seraphAcc.username or seraphAcc.name or lp.Name,
					message = ogText:sub(2),
					hexColor = seraphAcc.hexColor or "#FFF"
				}))
			end
		end)
	--[[
		for _,v in services.textChatService.TextChannels:GetChildren() do
			local wrapper__ = coroutine.wrap(function()
				local old; old = hookfunction(v.SendAsync, function(self, message, ...)
					if message and message:sub(1,1) == "@" then
						return webSocket:Send(http_service:JSONEncode({
							type = "addChatMessage",
							name = seraphAcc.username or seraphAcc.name or lp.Name,
							message = message:sub(2),
							hexColor = seraphAcc.hexColor or "#FFF"
						}))
					end
					return old(self, message, ...)
				end)
			end)
			pcall(wrapper__)
		end
	]]
		OnMessage.Event:Connect(function(message)
			local data = http_service:JSONDecode(message)
			if not data then return end
			if not data.type then return end
			if data.type == "connect" then
				local userId = tonumber(data.userId)
				if not table.find(userIdList, userId) then
					insert(userIdList, userId)
				end
				tracked_players[data.userId] = tick()
			elseif data.type == "setCustomIcon" then
				local userId = tonumber(data.userId)
				if not table.find(customIconList, userId) then
					insert(customIconList, userId)
				end
			elseif data.type == "fieryHorns" or data.type == "headless" then
				local userId = tonumber(data.userId)
				local plr = players:GetPlayerByUserId(userId)
				if plr and plr.Character then
					thread(addCharacterStuff, plr.Character, data.type)
				end
			elseif data.type == "addChatMessage" then
				print("hi")
				library:send_seraph_chat(data.message, data.name, data.hexColor)
			end
		end)

	end)

	function checkPlayer(player)
		if table.find(userIdList, player.UserId) then
			local playerList = coregui:FindFirstChild("PlayerList")
			if not playerList then return end 
			local pChild = nil
			for _, obj in playerList:GetDescendants() do
				if obj.Name:match(tostring(player.UserId)) then
					pChild = obj
					--print(obj:GetFullName())
				end
			end
			if not pChild then
				return --print('failed')
			end

			local icon = pChild:FindFirstChild(`PlayerIcon`, true)
			if icon:IsA("TextLabel") then 
				icon.Text = ""
			else 
				icon.Image = ""
			end

			local img = icon:FindFirstChildOfClass("ImageLabel") or Instance.new("ImageLabel")
			img.BackgroundTransparency = 1
			img.Size = UDim2.new(1,10,1,10)
			img.Position = UDim2.new(0,-5,0,-5)
			img.Image = getcustomasset("seraph/imgs/atom.png")
			img.Parent = icon

			local char = player.Character
			if not char then
				return
			end

			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum then
				return
			end

			local verified = utf8.char(0xE000)
			if not hum.DisplayName:match(verified) then
				hum.DisplayName = `{verified} {hum.DisplayName}`
			end
		end
	end
	task.spawn(function()
		for _, player in services.Players:GetPlayers() do
			task.spawn(checkPlayer, player)
		end
		insert(cons, services.players.PlayerAdded:Connect(checkPlayer))
	end)
end)


task.spawn(function()
	local smoothedFov = camera.FieldOfView
	camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
		if zoomKey.active then
			if not oldFov then
				oldFov = camera.FieldOfView
			end
			camera.FieldOfView = smoothedFov
		else
			smoothedFov = camera.FieldOfView
			if oldFov then
				camera.FieldOfView = oldFov
				oldFov = nil
			end
			if forceFOV.active then
				camera.FieldOfView = flags.real_fov
			end
		end
	end)
	local elapseCheck = 0
	cons[#cons + 1] = services.runService.Stepped:Connect(function(_, dt)
		local scopeGui = lp.PlayerGui:FindFirstChild("UnscaledScreenGui")
		if scopeGui then scopeGui.Enabled = not flags.viewmodel_noscope end
		if zoomKey.active then
			smoothedFov = math.lerp(smoothedFov, flags.zoom_fov, correctAlpha(0.4, dt))
			if not oldFov then
				oldFov = camera.FieldOfView
			end
			camera.FieldOfView = smoothedFov
		else
			smoothedFov = camera.FieldOfView
			if oldFov then
				camera.FieldOfView = oldFov
				oldFov = nil
			end
		end

		if forceFOV.active then
			camera.FieldOfView = flags.real_fov
		end

		elapseCheck += dt
		if elapseCheck >= 1 then
			elapseCheck = 0	
			for _, player in services.Players:GetPlayers() do
				checkPlayer(player)
			end
		end
		for _, method in movement do
			pcall(thread, method.check, method)
		end
	end)

	function listenChange(obj, prop, func)
		return obj:GetPropertyChangedSignal(prop):Connect(func)
	end

	function thirdPersonCheck()
		if thirdPerson.active then
			if not thirdPersonArray then
				thirdPersonArray = {}
				for _, prop in {'CameraMaxZoomDistance','CameraMinZoomDistance','CameraMode'} do
					thirdPersonArray[prop] = lp[prop]
				end
				thirdPersonArray.cameraMode = listenChange(lp,"CameraMode",function() lp.CameraMode = Enum.CameraMode.Classic end)
				thirdPersonArray.cameraMaxZoomDistance = listenChange(lp,"CameraMaxZoomDistance",function() lp.CameraMaxZoomDistance = flags.thirdpersonDistance end)
				thirdPersonArray.cameraMinZoomDistance = listenChange(lp,"CameraMinZoomDistance",function() lp.CameraMinZoomDistance = flags.thirdpersonDistance end)
				lp.CameraMaxZoomDistance = flags.thirdpersonDistance
				lp.CameraMinZoomDistance = flags.thirdpersonDistance
				lp.CameraMode = Enum.CameraMode.Classic

				local distance = flags.thirdpersonDistance
				local height = 2
				local rotX, rotY = 0, 0

				thirdPersonArray.inputChanged = uis.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local sens = uis.MouseDeltaSensitivity
						rotX = rotX - input.Delta.X * sens
						rotY = math.clamp(rotY - input.Delta.Y * sens, -80, 80)
					end
				end)

				thirdPersonArray.MouseBehavior = uis.MouseBehavior
				uis.MouseBehavior = Enum.MouseBehavior.Default
				camera.CameraType = Enum.CameraType.Scriptable
				--mouse2press()
				run:BindToRenderStep("camFix", Enum.RenderPriority.Camera.Value + 1, function()
					local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
					if not root then return end
					local look = CFrame.Angles(0, math.rad(rotX), 0) * CFrame.Angles(math.rad(rotY), 0, 0)
					local targetPos = root.Position
					local camPos = targetPos - look.LookVector * distance + Vector3.new(0, height, 0)

					camera.CFrame = CFrame.new(camPos, targetPos)
					uis.MouseBehavior = Enum.MouseBehavior.LockCenter
				end)
				thirdPersonArray.mouseBehavior = listenChange(uis, "MouseBehavior", function()
					uis.MouseBehavior = Enum.MouseBehavior.LockCenter
				end)
				uis.MouseBehavior = Enum.MouseBehavior.Default
			end
		elseif thirdPersonArray then
			--mouse2release()
			for i,v in thirdPersonArray do
				pcall(function()
					v:Disconnect()
				end)
			end
			for i,v in thirdPersonArray do
				pcall(function()
					lp[i] = v
				end)
			end
			uis.MouseBehavior = thirdPersonArray.MouseBehavior
			camera.CameraType = Enum.CameraType.Custom
			run:UnbindFromRenderStep("camFix")
			uis.MouseBehavior = thirdPersonArray.MouseBehavior
			thirdPersonArray = nil
		end
	end

	if game.GameId then
		thirdPersonCheck = function()
			local act = thirdPerson.active
			library.thirdPerson = act
			if act then
				if not thirdPersonArray then
					thirdPersonArray = {}

					--mouse2press()
					run:BindToRenderStep("camFix", Enum.RenderPriority.Camera.Value + 1, function()
						--camera.CFrame *= CFrame.new(0,flags.thirdpersonDistance/6,flags.thirdpersonDistance)
					end)

					local db = false
					thirdPersonArray.camera = listenChange(camera, "CFrame", function()
						if db then return end
						db = true
						local old = camera.Focus.Position
						pcall(function() old = library.char.HumanoidRootPart.CFrame.Position end)
						camera.CFrame *= CFrame.new(0,flags.thirdpersonDistance/32,flags.thirdpersonDistance)
						db = false
					end)
				end
			elseif thirdPersonArray then
				--mouse2release()
				for i,v in thirdPersonArray do
					pcall(function()
						v:Disconnect()
					end)
				end
				run:UnbindFromRenderStep("camFix")
				thirdPersonArray = nil
			end
		end
	end

	function checkTearParts()
		if #tearParts == 0 then return end
		for model, parts in tearParts do
			if not model or not model:IsDescendantOf(game) then
				for _, part in parts do
					part:Destroy()
				end
				table.clear(parts)
				tearParts[model] = nil
			end
		end
	end

	function createWidgetDrag(frame, frameName)
		local n = 'seraph/configs/'..frameName..'.vector'
		library:draggify(frame)
		pcall(function()
			local savedFramePos = http_service:JSONDecode(readfile(n))
			local translated = Vector2.new(savedFramePos.X, savedFramePos.Y)

			frame.Position = UDim2.new(0,translated.X,0,translated.Y)
		end)

		local check; check = function() 
			task.delay(1, function()
				writefile(n, http_service:JSONEncode({
					X = frame.Position.X.Offset,
					Y = frame.Position.Y.Offset
				}))
				check()
			end) 
		end 
		task.delay(1, check)
	end

	task.spawn(function()

		local lol = Instance.new("ScreenGui")
		local frame = Instance.new("Frame")
		local bar = Instance.new("Frame")
		local gradient = Instance.new("UIGradient")
		local username = Instance.new("TextLabel")
		local pad = Instance.new("UIPadding")
		local UICorner = Instance.new("UICorner")
		local label = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local layout = Instance.new("UIListLayout")


		lol.Name = "lol"
		lol.Parent = gethui()
		lol.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

		frame.Name = "frame"
		frame.Parent = lol
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = Color3.fromRGB(21, 21, 20)
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Position = UDim2.new(0.150000006, 0, 0.150000006, 0)
		frame.Size = UDim2.new(0, 150, 0, 15)
		frame.AutomaticSize = Enum.AutomaticSize.Y

		bar.Name = "bar"
		bar.Parent = frame
		bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		bar.BorderSizePixel = 0
		bar.Position = UDim2.new(0, 1, 0, 1)
		bar.Size = UDim2.new(1, -2, 0, 2)

		gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, themes.preset.button), ColorSequenceKeypoint.new(0.5, themes.preset.button_alt), ColorSequenceKeypoint.new(1.00, themes.preset.button)}
		gradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(1.00, 1.00)}
		gradient.Name = "gradient"
		gradient.Parent = bar
		library.gradientChanged:Connect(function()
			gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, themes.preset.button), ColorSequenceKeypoint.new(0.5, themes.preset.button_alt), ColorSequenceKeypoint.new(1.00, themes.preset.button)}
		end)

		local scale = Instance.new("UIScale")
		scale.Name = "scale"
		scale.Scale = 1
		scale.Parent = frame

		local outer = Instance.new("UIStroke")
		outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outer.LineJoinMode = Enum.LineJoinMode.Miter
		outer.Name = "outer"
		outer.Color = Color3.fromRGB(39, 40, 41)
		outer.ZIndex = 5
		outer.Thickness = 3
		outer.Parent = frame

		local outeroutline = Instance.new("UIStroke")
		outeroutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outeroutline.LineJoinMode = Enum.LineJoinMode.Miter
		outeroutline.Name = "outeroutline"
		outeroutline.Color = Color3.fromRGB(60, 65, 60)
		outeroutline.ZIndex = 4
		outeroutline.Thickness = 4
		outeroutline.Parent = frame

		local inner = Instance.new("UIStroke")
		inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		inner.LineJoinMode = Enum.LineJoinMode.Round
		inner.Name = "inner"
		inner.Color = Color3.fromRGB(60, 65, 60)
		inner.ZIndex = 4
		inner.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		inner.Parent = frame

		local outline = Instance.new("UIStroke")
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.LineJoinMode = Enum.LineJoinMode.Miter
		outline.Name = "outline"
		outline.Color = Color3.fromRGB(2, 3, 3)
		outline.ZIndex = 4
		outline.Thickness = 5
		outline.Parent = frame

		username.Name = "username"
		username.Parent = frame
		username.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		username.BackgroundTransparency = 1.000
		username.BorderColor3 = Color3.fromRGB(0, 0, 0)
		username.BorderSizePixel = 0
		username.LayoutOrder = 1
		username.Size = UDim2.new(0, 0, 0, 16)
		username.AutomaticSize = Enum.AutomaticSize.X
		username.Font = Enum.Font.Code
		username.Text = "%s"
		username.TextColor3 = Color3.fromRGB(255, 255, 255)
		username.TextSize = 14.000

		local holder = username:Clone()
		holder.Text = ""
		holder.Parent = frame


		pad.Name = "pad"
		pad.Parent = frame
		pad.PaddingBottom = UDim.new(0, 5)
		pad.PaddingLeft = UDim.new(0, 5)
		pad.PaddingRight = UDim.new(0, 5)

		UICorner.Parent = frame

		label.Name = "label"
		label.Parent = frame
		label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		label.BorderSizePixel = 0
		label.Size = UDim2.new(0, 35, 0, 35)
		label.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

		UICorner_2.CornerRadius = UDim.new(0, 4)
		UICorner_2.Parent = label

		layout.Name = "layout"
		layout.Parent = frame
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 5)

		local layout = layout:Clone()
		layout.Name = "layout"
		layout.Parent = holder
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom 
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 5)

		holder.AutomaticSize = Enum.AutomaticSize.XY


		label.Parent = holder
		username.Parent = holder

		function formatUnixDate(ts)
			local day = tonumber(os.date("%d", ts))
			local month = os.date("%B", ts)
			local year = os.date("%Y", ts)

			local suffix = "th"
			if day % 10 == 1 and day ~= 11 then suffix = "st"
			elseif day % 10 == 2 and day ~= 12 then suffix = "nd"
			elseif day % 10 == 3 and day ~= 13 then suffix = "rd" end

			return string.format("%s %d%s, %s", month, day, suffix, year)
		end

		
		main_frame = frame

		if seraphAcc.icon then
			label.Image = seraphAcc.icon
			local expires = username:Clone()
			expires.Name = "expires"
			expires.LayoutOrder = 2
			print(seraphAcc.expires)
			expires.Text = string.rep(" ", 1) .. "expires on ".. formatUnixDate(tonumber(seraphAcc.expires))
			expires.Parent = label.Parent
			username.TextColor3 = Color3.fromHex(seraphAcc.hexColor)
			username.RichText = true
			username.Text = string.rep(" ", 1) .. seraphAcc.username.."<font color=\"rgb(255,255,255)\">,</font>"
			insert(cons, holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				frame.Size = UDim2.new(0, math.max(holder.AbsoluteSize.X + 15, 5), 0, frame.Size.Y.Offset)
			end))
			task.delay(0.1, function()
				frame.Size = UDim2.new(0, math.max(holder.AbsoluteSize.X + 15, 5), 0, frame.Size.Y.Offset)
			end)
		end

		createWidgetDrag(frame, "account_info")
	end)

	task.spawn(function()
		local bind_list = Instance.new("ScreenGui")
		bind_list.Name = "bind_list"
		bind_list.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		bind_list.Parent = gethui()


		local frame = Instance.new("Frame")
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Name = "frame"
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.Size = UDim2.new(0, 50, 0, 15)
		frame.BorderSizePixel = 0
		frame.AutomaticSize = Enum.AutomaticSize.Y
		frame.BackgroundColor3 = Color3.fromRGB(21, 21, 20)
		frame.Parent = bind_list

		local scale = Instance.new("UIScale")
		scale.Name = "scale"
		scale.Scale = 1
		scale.Parent = frame

		local outer = Instance.new("UIStroke")
		outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outer.LineJoinMode = Enum.LineJoinMode.Miter
		outer.Name = "outer"
		outer.Color = Color3.fromRGB(39, 40, 41)
		outer.ZIndex = 5
		outer.Thickness = 3
		outer.Parent = frame

		local outeroutline = Instance.new("UIStroke")
		outeroutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outeroutline.LineJoinMode = Enum.LineJoinMode.Miter
		outeroutline.Name = "outeroutline"
		outeroutline.Color = Color3.fromRGB(60, 65, 60)
		outeroutline.ZIndex = 4
		outeroutline.Thickness = 4
		outeroutline.Parent = frame

		local inner = Instance.new("UIStroke")
		inner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		inner.LineJoinMode = Enum.LineJoinMode.Round
		inner.Name = "inner"
		inner.Color = Color3.fromRGB(60, 65, 60)
		inner.ZIndex = 4
		inner.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		inner.Parent = frame

		local outline = Instance.new("UIStroke")
		outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		outline.LineJoinMode = Enum.LineJoinMode.Miter
		outline.Name = "outline"
		outline.Color = Color3.fromRGB(2, 3, 3)
		outline.ZIndex = 4
		outline.Thickness = 5
		outline.Parent = frame

		local bar = Instance.new("Frame")
		bar.Name = "bar"
		bar.Position = UDim2.new(0, 1, 0, 1)
		bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		bar.Size = UDim2.new(1, -2, 0, 2)
		bar.BorderSizePixel = 0
		bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bar.Parent = frame

		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, themes.preset.button), ColorSequenceKeypoint.new(0.5, themes.preset.button_alt), ColorSequenceKeypoint.new(1.00, themes.preset.button)}
		gradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1)
		}
		gradient.Name = "gradient"
		gradient.Parent = bar
		library.gradientChanged:Connect(function()
			gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, themes.preset.button), ColorSequenceKeypoint.new(0.5, themes.preset.button_alt), ColorSequenceKeypoint.new(1.00, themes.preset.button)}
		end)

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Name = "layout"
		layout.Parent = frame

		local example = Instance.new("TextLabel")
		example.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		example.TextColor3 = Color3.fromRGB(255, 255, 255)
		example.BorderColor3 = Color3.fromRGB(0, 0, 0)
		example.Text = "[K] yoo"
		example.Name = "example"
		example.BackgroundTransparency = 1
		example.Size = UDim2.new(0, 0, 0, 16)
		example.BorderSizePixel = 0
		example.AutomaticSize = Enum.AutomaticSize.X
		example.TextSize = 14
		example.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		example.Parent = frame

		local pad = Instance.new("UIPadding")
		pad.Name = "pad"
		pad.PaddingBottom = UDim.new(0, 5)
		pad.PaddingRight = UDim.new(0, 5)
		pad.PaddingLeft = UDim.new(0, 5)
		pad.Parent = frame

		local UICorner = Instance.new("UICorner")
		UICorner.Parent = frame
		UICorner.CornerRadius = UDim.new(0, 4)

		bindList, bindExample, binds, bindScale = bind_list, example:Clone(), {}, scale
		example:Destroy()

		createWidgetDrag(frame, "bind_list")
	end)

	local elapseTime = tick()
	local renders = {
		keybinds = {
			off = function(dt)
				bindScale.Scale = 0.0
				for i, keybind in keybinds do
					local text = keybind.text
					text.Visible = false
				end
			end,
			widget = function(dt)
				local currentSize = 50
				local activeBinds = 0
				for i, keybind in keybinds do
					local text, mode, active = keybind.text, keybind.mode, keybind.active
					if not keybind.inset then keybind.inset = 0 end
					if active then
						activeBinds += 1
					end
					text.Visible = false

					local bindFrame = binds[keybind] or bindExample:Clone()
					binds[keybind] = bindFrame
					bindFrame.Visible = active
					bindFrame.TextTransparency = clamp(bindFrame.TextTransparency - (active and dt or -dt) * 10, 0, 1)
					bindFrame.TextStrokeTransparency = clamp(bindFrame.TextStrokeTransparency - (active and dt or -dt) * 10, 0, 0.5)
					bindFrame.Text = `[{keybind.key and keybind.key.Name or "<none>"}] {string.lower(keybind.display or keybind.name)} ({string.lower(mode)})`
					bindFrame.Parent = bindList.frame
					if (bindFrame.AbsoluteSize.X + 20) > currentSize and bindFrame.visible then
						currentSize = bindFrame.AbsoluteSize.X + 20
					end
				end
				bindScale.Scale = clamp(bindScale.Scale + (activeBinds > 0 and dt or -dt) * 15, 0, 1)
				bindList.frame.Size = UDim2.new(0, currentSize, 0, 15)
			end,
			crosshair = function(dt)
				bindScale.Scale = 0.0
				local inset = 0
				local center = workspace.CurrentCamera.ViewportSize / 2 + vec2(0, 150)
				for i, keybind in keybinds do
					local text, mode, active = keybind.text, keybind.mode, keybind.active
					if not keybind.inset then keybind.inset = 0 end
					text.Size = math.lerp(text.Size, active and 22 or 0, correctAlpha(0.15, dt))
					text.Transparency = math.clamp(text.Transparency + (active and dt or -dt) * 10, 0, 1)
					text.Center = true
					text.Text = string.lower(`{keybind.display or keybind.name} [{mode}]`)
					text.Outline = true
					text.OutlineColor = text.Color:Lerp(rgb(), 0.75)
					text.Color = themes.preset.button_alt:Lerp(themes.preset.button, 0.5 + 0.5 * math.cos((elapsed_ticks + i * 2) / 12))
					text.Position = center + vec2(0, inset)
					text.Visible = true
					keybind.inset = math.lerp(keybind.inset, active and text.TextBounds.Y + 2 or 0, correctAlpha(0.35, dt))

					inset += keybind.inset
				end
			end
		}
	}

	function updateNotifications(dt)
		for i, notifData in notifications do
			local notif = notifData.notif
			notifData.time -= dt
			local textContainer = notif.holder.textContainer
			local totalLength, count = 0, 0
			for _, v in textContainer:GetChildren() do
				if v:IsA("TextLabel") then
					totalLength += v.AbsoluteSize.X
					count += 1
				end
				continue
			end

			totalLength += 5 * count - 1
			notif.Size = notif.Size:lerp(UDim2.new(0,totalLength + 2,0,23), correctAlpha(0.45, dt))
			notif.loading.Size = UDim2.new(math.lerp(1, 0, 1 - (notifData.time / notifData.totalTime)), 0, 0, 1)
			if notifData.time <= 0 then
				--notif.Position = notif.Position:Lerp(UDim2.new(1.5, 0,1, -5 - (35 * (i - 1))), dt * 5)
				notif.Position = notif.Position:Lerp(UDim2.new(1, -5,1, 60), correctAlpha(0.35, dt))
				notif.scale.Scale = math.clamp(notif.scale.Scale - dt * 2, 0.0, 1.0)
				if notif.scale.Scale <= 0.05 then
					table.clear(notifData)
					notif:Destroy()
					table.remove(notifications, i)
					continue
				end
			else
				notif.Position = notif.Position:Lerp(UDim2.new(1, -5,1, -5 - (35 * ((#notifications - i)))), correctAlpha(0.35, dt))
				notif.scale.Scale = math.clamp(notif.scale.Scale + dt * 10, 0.0, 1.0)
			end
			notif.Parent = library.gui

		end
	end

	services.runService:BindToRenderStep("movement0x078DE4A", Enum.RenderPriority.Character.Value, function(dt)
		if tick() - elapseTime >= 1 and webSocket and webSocket.Send then
			elapseTime = tick()
			webSocket:Send(http_service:JSONEncode({
				type = "connect",
				userId = tostring(lp.UserId),
			}))
			if currentText == "development" then
				webSocket:Send(http_service:JSONEncode({
					type = "setCustomIcon",
					userId = tostring(lp.UserId),
				}))
			end

			task.delay(0.2, function()
				if flags.headless_flag then
					webSocket:Send(http_service:JSONEncode({
						type = "headless",
						userId = tostring(lp.UserId),
					}))
				end

				if flags.fiery_flag then
					webSocket:Send(http_service:JSONEncode({
						type = "fieryHorns",
						userId = tostring(lp.UserId),
					}))
				end
			end)
		end

		main_frame.Visible = flags.linked_discord_profile

		thread(thirdPersonCheck)
		thread(checkTearParts)

		if library.gui_visible then
			for _, depend in dependants do
				local element, check = depend[1], depend[2]

				element.show_element(check())
			end
		end
		renders.keybinds[flags.keybinds_type](dt)

		thread(updateNotifications, dt);
	end)

	insert(cons, services.players.PlayerRemoving:Connect(function(player)
		if esp_frames[player] then
			esp_frames[player]:Destroy()
			esp_frames[player] = nil
		end
		local viewModel = viewport:FindFirstChild(player.Name)
		if viewModel then viewModel:Destroy() end
	end))

	if not rage.visible then
		--legit:open_tab()
	end
	task.spawn(function()
		window:set_title(`seraph<font color="{rgbstr(themes.preset.button_alt)}">.wtf</font> {build_str} | {configName}`)
		createNotification({
			text = `welcome to seraph, {lp.Name}!`,
		})
		task.wait(0.5)
		createNotification({
			text = "we hope you enjoy your time using seraph!",
		})
		task.wait(0.5)
		createNotification({
			text = "if you encounter any issues, or have any suggestions, then feel free to make a post in the community server",
		})
	end)


	unload_full = function()
		table.clear(notifications)
		services.runService:UnbindFromRenderStep("movement0x078DE4A")
		bindList:Destroy()
		chamsContainer:Destroy()
		sky:Destroy()
		bloom:Destroy()
		colorcorrection:Destroy()
		main_frame:Destroy()
	end

	task.spawn(function()
		local old = Instance.new("ImageLabel")
		old.Name = "old"
		old.Position = UDim2.new(0, 125, 0, 125)
		old.Size = UDim2.new(0, 200, 0, 160)
		old.BackgroundColor3 = Color3.new(1, 1, 1)
		old.BackgroundTransparency = 1
		old.BorderSizePixel = 0
		old.BorderColor3 = Color3.new(0, 0, 0)
		old.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		old.Parent = library.gui

		local scale = Instance.new("UIScale")
		scale.Name = "scale"
		scale.Scale = 1.0
		scale.Parent = old

		local new = Instance.new("ImageLabel")
		new.Name = "new"
		new.Size = UDim2.new(1, 0, 1, 0)
		new.BackgroundColor3 = Color3.new(1, 1, 1)
		new.BackgroundTransparency = 1
		new.BorderSizePixel = 0
		new.BorderColor3 = Color3.new(0, 0, 0)
		new.Visible = true
		new.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		new.Parent = old

		library:draggify(old)

		local pos = old.Position

		old.Position = UDim2.new(0, 1, 0, 1)
		scale.Scale = 0.01

		for i = 1, 150 do
			local frame_translation = string.format("frame_%03d_delay-0.02s.png", i-1)
			local image = getcustomasset(`seraph/gifs/{frame_translation}`)
			new.Image = image
			old.Image = image
			task.wait()
		end

		scale.Scale = 1
		old.Position = pos

		pcall(function()
			local savedFramePos = http_service:JSONDecode(readfile('seraph/configs/spinning.vector'))
			local translated = Vector2.new(savedFramePos.X, savedFramePos.Y)

			old.Position = UDim2.new(0,translated.X,0,translated.Y)
		end)


		new.Image = ""
		old.Image = ""

		while task.wait() do
			if library.unloaded then break end
			if flags.spinning_logo then
				scale.Scale = flags.logosize / 100
				for i = 1, 150 do
					local frame_translation = string.format("frame_%03d_delay-0.02s.png", i-1)
					local image = getcustomasset(`seraph/gifs/{frame_translation}`)

					if i > 1 then
						local frame_translation = string.format("frame_%03d_delay-0.02s.png", i-2)
						local image = getcustomasset(`seraph/gifs/{frame_translation}`)
						new.Image = image
					end

					old.Visible = flags.spinning_logo
					old.Image = image
					new.ImageTransparency, old.ImageTransparency = 0.0, 0.0
					for i = 1, 2 do new.ImageTransparency,old.ImageTransparency = i / 2, 0; task.wait() end
				end
				writefile('seraph/configs/spinning.vector', http_service:JSONEncode({
					X = old.Position.X.Offset,
					Y = old.Position.Y.Offset
				}))
			else
				scale.Scale = 0.0
			end
		end
	end)

end)


pcall(function()
	local baseConfig = table.clone(flags)
	library.empty_flags = baseConfig
	local cfgdata = readfile(library.directory .. `/configs/{configName}.cfg`)
	if cfgdata and typeof(cfgdata) == 'string' then
		task.delay(1/30, function()
			library:load_config(cfgdata)
		end)
	end
end)

--"
