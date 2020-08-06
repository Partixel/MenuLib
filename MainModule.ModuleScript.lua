local LoaderModule, PackSingle = require(game:GetService("ServerStorage"):FindFirstChild("LoaderModule") and game:GetService("ServerStorage").LoaderModule:FindFirstChild("MainModule") or 03593768376)("MenuLib")

LoaderModule(script:WaitForChild("StarterGui"))

local CoroutineErrorHandling = require(game:GetService("ReplicatedStorage"):FindFirstChild("CoroutineErrorHandling") and game:GetService("ReplicatedStorage").CoroutineErrorHandling:FindFirstChild("MainModule") or game:GetService("ServerStorage"):FindFirstChild("CoroutineErrorHandling") and game:GetService("ServerStorage").CoroutineErrorHandling:FindFirstChild("MainModule") or 4851605998)

local Players = game:GetService("Players")

local MenuModules = game:GetService("ServerStorage"):FindFirstChild("MenuModules")
if not MenuModules then
	MenuModules = Instance.new("Folder")
	MenuModules.Name = "MenuModules"
	MenuModules.Parent = game:GetService("ServerStorage")
end

local MenuLib = game:GetService("ReplicatedStorage"):FindFirstChild("MenuLib")
if not MenuLib then
	MenuLib = Instance.new("Folder")
	MenuLib.Name = "MenuLib"
	MenuLib.Parent = game:GetService("ReplicatedStorage")
end

local DataStore2 = require(3913891878)

local Menus = {}
function HandleMenuFor(Plr, Options)
	local DataStore = DataStore2(Options.Key, Plr)
	
	if Options.BeforeInitialGet then
		DataStore:BeforeInitialGet(function(...)
			return Options.BeforeInitialGet(Plr, ...)
		end)
	end
	
	if Options.BeforeSave then
		DataStore:BeforeSave(function(...)
			return Options.BeforeSave(Plr, ...)
		end)
	end
	
	if Options.SetupPlayer then
		Options.SetupPlayer(Plr, DataStore)
	end
	
	if Options.Remote and Options.SendToClient then
	local Data = DataStore:Get(Options.DefaultValue)
		
		if Options.BeforeSendToClient then
			Data = table.pack(Options.BeforeSendToClient(Plr, Data))
			if Data.n > 0 then
				Options.Remote:FireClient(Plr, unpack(Data, 1, Data.n))
			end
		elseif Data then
			Options.Remote:FireClient(Plr, Data)
		end
	end
end

local Overrides

--[[
Key = string
DefaultValue = tuple
SeparateDataStore = boolean
SendToClient = boolean
BeforeSendToClient = function
AllowRemoteSet = boolean
BeforeRemoteSet = function
BeforeSave = function
BeforeInitialGet = function
]]
function HandleMenu(Mod)
	if Mod:IsA("Folder") then
		for _, Mod in ipairs(Mod:GetChildren()) do
			HandleMenu(Mod)
		end
		return
	end
	
	local Ran, Options = xpcall(function() return require(Mod) end, CoroutineErrorHandling.ErrorHandler)
	if not Ran then
		error("MenuLib - Failed to require server-side of " .. Mod:GetFullName() .. "\n" .. CoroutineErrorHandling.GetError(Options))
	end
	
	Options.Mod = Mod
	
	if Overrides and Overrides[Mod.Name] then
		for Option, Value in pairs(Overrides[Mod.Name]) do
			Options[Option] = Value
		end
	end
	
	if Options.Override then
		Options:Override()
	end
	
	if not Options.SeparateDataStore then
		DataStore2.Combine("PartixelsVeryCoolMasterKey", Options.Key)
	end
	
	if Mod:FindFirstChild("Client") then
		local Client = Mod.Client
		Client.Name = Mod.Name
		Client.Parent = MenuLib
		
		if not Options.Remote and (Options.SendToClient or Options.AllowRemoteSet) then
			Options.Remote = Instance.new("RemoteEvent")
			Options.Remote.Name = "Remote"
			
			if Options.AllowRemoteSet then
				Options.Remote.OnServerEvent:Connect(function(Plr, ...)
					if Options.Debug then print(Plr, ...) end
					if Options.BeforeRemoteSet then
						local DataStore = DataStore2(Options.Key, Plr)
						local Data = table.pack(Options.BeforeRemoteSet(Plr, DataStore, Options.Remote, ...))
						if Data.n == 1 then
							DataStore:Set(Data[1])
						end
					else
						DataStore2(Options.Key, Plr):Set(...)
					end
				end)
			end
			
			Options.Remote.Parent = Client
		end
	end
	
	if Options.BeforeInitialGet or Options.BeforeSave or Options.SendToClient then
		for _, Plr in pairs(Players:GetPlayers()) do
			local Ran, Error = xpcall(HandleMenuFor, CoroutineErrorHandling.ErrorHandler, Plr, Options)
			if not Ran then
				error("MenuLib - Failed to handle menu " .. Mod:GetFullName() .. " for player " .. Plr.Name .. "\n" .. CoroutineErrorHandling.GetError(Error))
			end
		end
	end
	
	Menus[ #Menus + 1 ] = Options
end

Players.PlayerAdded:Connect(function(Plr)
	for _, Options in ipairs(Menus) do
		if Options.BeforeInitialGet or Options.BeforeSave or Options.SendToClient then
			local Ran, Error = xpcall(HandleMenuFor, CoroutineErrorHandling.ErrorHandler, Plr, Options)
			if not Ran then
				error("MenuLib - Failed to handle menu " .. Options.Mod:GetFullName() .. " for player " .. Plr.Name .. "\n" .. CoroutineErrorHandling.GetError(Error))
			end
		end
	end
end)

Overrides = MenuModules:FindFirstChild("Overrides")
if Overrides then
	local Client = Overrides:FindFirstChild("Client")
	if Client then
		Client.Name = "Overrides"
		Client.Parent = MenuLib
	end
	
	Overrides = require(Overrides)
end

MenuModules.ChildAdded:Connect(HandleMenu)
for _, Mod in ipairs(MenuModules:GetChildren()) do
	HandleMenu(Mod)
end

return nil