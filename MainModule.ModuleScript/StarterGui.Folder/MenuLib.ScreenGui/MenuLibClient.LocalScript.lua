local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local MenuLib = game:GetService("ReplicatedStorage"):WaitForChild("MenuLib")
local ThemeUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("ThemeUtil"):WaitForChild("ThemeUtil"))

local TopBarIcon = script.Parent.TopBar.LeftFrame.Settings.Background

coroutine.wrap(function()
	while wait(0.1) do
		local R15 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if R15 then
			R15 = R15.RigType == Enum.HumanoidRigType.R15
		end
		
		local Chat, Backpack, EmotesMenu, PlayerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat), StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack), StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu), StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
		
		if not script.Parent.TopBar.Visible then
			script.Parent.TopBar.Visible = Chat or Backpack or EmotesMenu or PlayerList
		end
		TopBarIcon.Parent.Position = UDim2.new( 0, 44 * (1 + (Chat and 1 or 0) + (EmotesMenu and R15 and 1 or 0)), 0, 0)
	end
end)()

local Overrides
local function Invalidate(self, CustomFunc, ...)
	if CustomFunc ~= false and script.Parent.Frame.Visible and self.Options.Gui.Visible and self.Options.CurrentTab == self.TabNumber then
		if CustomFunc then
			CustomFunc(self, ...)
		elseif self.Redraw then
			local Drew = self:Redraw()
			if Drew ~= false then
				self.Invalid = nil
			end
		end
	else
		self.Invalid = true
	end
end

local Menus = {}
local Open
local function ToggleGui(Options)
	if Open and Open ~= Options then
		ToggleGui(Open)
	end
	
	Options.Open = not Options.Open
	
	if Options.Open then
		Open = Options
		
		if Options.OnOpen then
			Options:OnOpen()
		end
		
		local CurrentTab = Options.Tabs[Options.CurrentTab]
		if CurrentTab.OnOpen then
			CurrentTab:OnOpen()
		end
		if CurrentTab.Invalid and CurrentTab.Redraw then 
			local Drew = CurrentTab:Redraw()
			if Drew ~= false then
				CurrentTab.Invalid = nil
			end
		end
		
		local Cur = Options.Toggle.LayoutOrder
		if Cur == #Menus then
			Cur = 1
		else
			Cur = Cur + 1
		end
		script.Parent.Frame.Down.Visible = true
		script.Parent.Frame.Down.Text = "v " .. Menus[Cur].ButtonText .. " v"
		
		Cur = Options.Toggle.LayoutOrder
		if Cur == 1 then
			Cur = #Menus
		else
			Cur = Cur - 1
		end
		script.Parent.Frame.Up.Visible = true
		script.Parent.Frame.Up.Text = "ʌ " .. Menus[Cur].ButtonText .. " ʌ"
		
		Options.Gui.Visible = true
		
		TweenService:Create(Options.Gui, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.7, 0, 0.5, 0), Size = Options.OpenSize or UDim2.new(0.6, 0, 0.6, 0)}):Play()
		
		ThemeUtil.BindUpdate(Options.Toggle, {BorderColor3 = "Selection_Color3"})
	else
		Open = nil
		
		if Options.OnClose then
			Options:OnClose()
		end
		
		local CurrentTab = Options.Tabs[Options.CurrentTab]
		if CurrentTab.OnClose then
			CurrentTab:OnClose()
		end
		
		script.Parent.Frame.Down.Visible = false
		script.Parent.Frame.Up.Visible = false
		
		local Tween = TweenService:Create(Options.Gui, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {AnchorPoint = Vector2.new(0, 0), Position = UDim2.fromOffset(Options.Toggle.AbsolutePosition - script.Parent.Frame.AbsolutePosition), Size = UDim2.fromOffset(Options.Toggle.AbsoluteSize)})
		Tween.Completed:Connect(function(State)
			if State == Enum.PlaybackState.Completed then
				Options.Gui.Visible = false
			end
		end)
		Tween:Play()
		
		ThemeUtil.BindUpdate(Options.Toggle, {BorderColor3 = "Secondary_BackgroundColor"})
	end
end

local Invalid = true
function Redraw()
	for i, Options in ipairs(Menus) do
		Options.Toggle.LayoutOrder = i
		if not Options.Gui.Visible then
			Options.Gui.Position = UDim2.fromOffset(Options.Toggle.AbsolutePosition - script.Parent.Frame.AbsolutePosition)
			Options.Gui.Size = UDim2.fromOffset(Options.Toggle.AbsoluteSize)
		end
	end
end

script.Parent.Frame.Up.MouseButton1Click:Connect(function()
	local Cur = Open.Toggle.LayoutOrder
	if Cur == 1 then
		Cur = #Menus
	else
		Cur = Cur - 1
	end
	ToggleGui(Menus[Cur])
end)

script.Parent.Frame.Down.MouseButton1Click:Connect(function()
	local Cur = Open.Toggle.LayoutOrder
	if Cur == #Menus then
		Cur = 1
	else
		Cur = Cur + 1
	end
	ToggleGui(Menus[Cur])
end)

local White = Color3.new(1, 1, 1)
local CurSpin
local function Spin(Color)
	local MySpin = {}
	CurSpin = MySpin
	for a = 100, 1, -1 do
		if MySpin ~= CurSpin then return end
		TopBarIcon.Icon.Rotation = -a ^ 2 / 12
		if Color then
			TopBarIcon.Icon.ImageColor3 = Color:lerp(White, 1 - a ^ 2 / 12 / 833.333334)
		end
		wait()
	end
	TopBarIcon.Icon.Rotation = 0
end

local NotOpened = true
coroutine.wrap(function()
	for a = 1, 10 do
		if not NotOpened then return end
		TopBarIcon.Icon.ImageColor3 = ThemeUtil.GetThemeFor("Selection_Color3")
		Spin(TopBarIcon.Icon.ImageColor3)
		if not NotOpened then return end
		wait(2)
	end
end)()

ThemeUtil.BindUpdate(script.Parent.Frame.SideBar, {BackgroundColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency"})
ThemeUtil.BindUpdate(script.Parent.Frame.SideBar.Search, {BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency", PlaceholderColor3 = "Secondary_TextColor"})
ThemeUtil.BindUpdate({script.Parent.Frame.Up, script.Parent.Frame.Down}, {BackgroundColor3 = "Primary_BackgroundColor", BorderColor3 = "Primary_BackgroundColor", BackgroundTransparency = "Primary_BackgroundTransparency", TextColor3 = "Primary_TextColor", TextTransparency = "Primary_TextTransparency"})

local OldChat, OldPlayerList, OldEmotesMenu, OldMinZoom
function ToggleMenu()
	NotOpened = nil
	script.Parent.Frame.Visible = not script.Parent.Frame.Visible
	script.Parent.Blocker.Visible = script.Parent.Frame.Visible
	
	if script.Parent.Frame.Visible then
		TopBarIcon.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		TopBarIcon.Icon.Image = "rbxassetid://5030232831"
		
		OldChat, OldPlayerList, OldEmotesMenu = StarterGui:GetCore("ChatActive"), StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList), GuiService:GetEmotesMenuOpen()
		
		StarterGui:SetCore("ChatActive", false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		GuiService:SetEmotesMenuOpen(false)
		
		OldMinZoom = LocalPlayer.CameraMinZoomDistance
		
		LocalPlayer.CameraMinZoomDistance = 2
		
		if Open and Open.OnOpen then
			Open:OnOpen()
		end
		
		coroutine.wrap(Spin)()
	else
		TopBarIcon.Icon.ImageColor3 = ThemeUtil.GetThemeFor("Selection_Color3")
		TopBarIcon.Icon.Image = "rbxassetid://5030232675"
		
		StarterGui:SetCore("ChatActive", OldChat or false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, OldPlayerList)
		GuiService:SetEmotesMenuOpen(OldEmotesMenu)
		
		LocalPlayer.CameraMinZoomDistance = OldMinZoom
		
		OldChat, OldPlayerList, OldEmotesMenu, OldMinZoom = nil, nil, nil, nil
		
		if Open and Open.OnClose then
			Open:OnClose()
		end
		
		coroutine.wrap(Spin)(TopBarIcon.Icon.ImageColor3)
	end
	
	if Invalid then
		Redraw()
		Invalid = nil
	end
end
TopBarIcon.MouseButton1Click:Connect(ToggleMenu)
TopBarIcon.MouseEnter:Connect(function()
	TopBarIcon.StateOverlay.ImageTransparency = 0.9
end)
TopBarIcon.MouseLeave:Connect(function()
	TopBarIcon.StateOverlay.ImageTransparency = 1
end)

--[[
	RequiresRemote = boolean
	GetCustomGui = function()
	CustomMenuFunc = function(Remote, GetCustomGui())
OR
	SetupGui = function(self, Remote)
	OnOpen = function(self)
	OnClose = function(self)
	Tabs = {
		{
			Tab = Frame
			SetupTab = function(self)
			Redraw = function(self)
		}
	}
]]
function RequireModule(Mod)
	if Mod.Name == "Overrides" then
		Overrides = require(Mod)
		return
	end
	
	local Ran, Options = pcall(function() return require(Mod) end)
	if not Ran then
		warn("MenuLib - Failed to require client-side of " .. Mod:GetFullName() .. "\n" .. Options)
		return
	end
	
	if Overrides and Overrides[Mod.Name] then
		for Option, Value in pairs(Overrides[Mod.Name]) do
			Options[Option] = Value
		end
	end
	
	if Options.Override then
		Options:Override()
	end
	
	Options.Remote = Options.RequiresRemote and Mod:WaitForChild("Remote")
	if Options.CustomMenuFunc then
		Options.CustomMenuFunc(Options.Remote, Options.GetCustomGui and Options.GetCustomGui() or nil)
	else
		Options.ButtonText = Options.ButtonText or Mod.Name
		
		Options.Gui = Mod:WaitForChild("Gui")
		Options.Gui.Name = Options.ButtonText
		Options.Gui.Visible = false
		Options.Gui.Parent = script.Parent.Frame
		
		Options.Toggle = script.Toggle:Clone()
		Options.Toggle.Name = Options.ButtonText .. "_Toggle"
		Options.Toggle.Text = Options.ButtonText
		Options.Toggle.MouseButton1Click:Connect(function()
			ToggleGui(Options)
		end)
		ThemeUtil.BindUpdate(Options.Toggle, {TextTransparency = "Primary_TextTransparency", TextColor3 = "Primary_TextColor", BackgroundColor3 = "Secondary_BackgroundColor", BackgroundTransparency = "Secondary_BackgroundTransparency", BorderColor3 = Options.Gui.Visible and "Selection_Color3" or "Secondary_BackgroundColor"})
		Options.Toggle.Parent = script.Parent.Frame.SideBar.Toggles
		
		Options.CurrentTab = 1
		
		for i, Tab in ipairs(Options.Tabs) do
			Tab.Invalidate = Invalidate
			Tab.TabNumber = i
			Tab.Options = Options
			Tab.Tab.Visible = i == 1
			Tab:Invalidate()
			if Tab.SetupTab then
				Tab:SetupTab()
			end
			
			if Tab.OnClose then
				Tab:OnClose()
			end
			
			if Tab.Button then
				Tab.Button.MouseButton1Click:Connect(function()
					if Options.CurrentTab == i then return end
					
					local OldTab = Options.Tabs[Options.CurrentTab]
					OldTab.Tab.Visible = false
					if OldTab.OnClose then
						OldTab:OnClose()
					end
					
					Options.CurrentTab = i
					Tab.Tab.Visible = true
					if Tab.OnOpen then
						Tab:OnOpen()
					end
					
					if Tab.Invalid and Tab.Redraw then 
						local Drew = Tab:Redraw()
						if Drew ~= false then
							Tab.Invalid = nil
						end
					end
				end)
			end
		end
		
		if Options.SetupGui then
			Options:SetupGui()
		end
		
		Menus[#Menus + 1] = Options
		table.sort(Menus, function(a, b)
			return a.ButtonText < b.ButtonText
		end)
		
		if script.Parent.Frame.Visible then
			Redraw()
			Invalid = nil
		else
			Invalid = true
		end
	end
end

MenuLib.ChildAdded:Connect(RequireModule)
for _, Mod in ipairs(MenuLib:GetChildren()) do
	coroutine.wrap(RequireModule)(Mod)
end