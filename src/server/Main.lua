local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Chimera = {}
local Servers = {}

local ServerObject = {}
ServerObject.__index = ServerObject

--//cool little functions n stuffs

function messageHandler(MessageEncoded)
	local MsgRaw = HttpService:JSONDecode(MessageEncoded.Data)

	local Request = MsgRaw[1]
	local Server = MsgRaw[2]

	if Request == "OpenServer" then
		Servers[Server:GetId()] = Server
	elseif Request == "CloseServer" then
		Servers[Server:GetId()] = nil
	end
end

function ServerObject.new()
	return setmetatable({
		JobId = game.JobId,
		Keys = {},
		OnTeleport = function(...) end,
		RequestHandler = function(...) end,
	}, ServerObject)
end

function ServerObject:GetId()
	return self.JobId
end

function ServerObject:SetKey(name, val)
	self.Keys[name] = val
	MessagingService:PublishAsync("ChimeraGlobalRequest", { "OpenServer", self })
end

function ServerObject:GetKey(name)
	return self.Keys[name]
end

function ServerObject:Message(Targets, MessageData)
	if self.JobId ~= game.JobId then
		warn("Chimera: Trying to message from a foreign server.")
		return
	end
	if Targets:GetId() then --// if Targets (list) is a ServerObject, then
		Targets = { Targets }
	end
	for _, Target in Targets do
		MessagingService:PublishAsync("ChimeraRequestId" .. Target.JobId, { "PrivateMessage", MessageData })
	end
end

local LocalServer = ServerObject.new()

function Chimera.ThisServer()
	return LocalServer
end

function Chimera.AllServers()
	return Servers
end

function Chimera.ServerFromId(JobId)
	return Servers[JobId]
end

function Chimera.AllServersWith(KeyName, KeyValue)
	local PossibleServers = {}
	for JobId, Data in Servers do
		if Data[KeyName] == nil then
			warn(string.format("Chimera: Server %s does not have key %s, skipped.", tostring(JobId), KeyName))
			continue
		end
		if Data[KeyName] == KeyValue then
			PossibleServers[JobId] = Data
		end
	end
	return PossibleServers
end

function Chimera.TeleportToServer(PlayerList, ServerObject: table, TeleportData: table)
	if typeof(PlayerList) ~= "table" then
		PlayerList = { PlayerList }
	end

	local TeleportOptions = Instance.new("TeleportOptions")
	TeleportOptions.ServerInstanceId = ServerObject.JobId
	TeleportOptions:SetTeleportData(TeleportData)
	TeleportService:TeleportAsync(game.PlaceId, PlayerList, TeleportOptions)
end

--//Chimera actual setup

MessagingService:PublishAsync("ChimeraGlobalRequest", { "OpenServer", LocalServer })
MessagingService:SubscribeAsync("ChimeraGlobalRequest", messageHandler)
MessagingService:SubscribeAsync("ChimeraRequestId" .. LocalServer:GetId(), function(MessageEncoded)
	if LocalServer.RequestHandler then
		LocalServer.RequestHandler(MessageEncoded)
	else
		messageHandler(MessageEncoded)
	end
end)

game:BindToClose(function()
	MessagingService:PublishAsync("ChimeraGlobalRequest", { "CloseServer", LocalServer })
end)

return Chimera
