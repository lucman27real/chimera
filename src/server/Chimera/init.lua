local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Chimera = {}
local Servers = {}

local ServerObject = require(script.ServerObject)
local MessageWrapper = require(script.MessagingWrapper)
--//cool little functions n stuffs

local LocalServer = ServerObject.new()
local GlobalChannel = MessageWrapper.GetGlobalChannel()

function messageHandler(MessageEncoded)
	local MsgRaw = HttpService:JSONDecode(MessageEncoded.Data)

	local Request = MsgRaw[1]
	local Server = MsgRaw[2]

	if Request == "UpdateServer" then
		Servers[Server:GetId()] = Server
	elseif Request == "CloseServer" then
		Servers[Server:GetId()] = nil
	end
end

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

LocalServer.Channel:Listen(function(...) LocalServer.RequestHandler(...) end)

GlobalChannel:Post('UpdateServer',LocalServer)
GlobalChannel:Listen(messageHandler)

game:BindToClose(function()
	GlobalChannel:Post('CloseServer',LocalServer)
end)

return Chimera
