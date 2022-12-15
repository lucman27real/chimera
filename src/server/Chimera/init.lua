local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local ServerObject = require(script.ServerObject)
local MessagingWrapper = require(script.MessagingWrapper)

local _localServer = ServerObject.new()
local _globalChannel = MessagingWrapper.GetGlobalChannel()

local serverList = {}

local function messageHandler(MessageEncoded: table)
	local RawMessage = HttpService:JSONDecode(MessageEncoded.Data)

	local Request = RawMessage[1]
	local Server = RawMessage[2]

	if Request == "UpdateServer" then
		serverList[Server:GetId()] = Server
	elseif Request == "CloseServer" then
		serverList[Server:GetId()] = nil
	end
end

_localServer.Channel:Listen(function(...)
	_localServer.RequestHandler(...)
end)

_globalChannel:Post("UpdateServer", _localServer)
_globalChannel:Listen(messageHandler)

game:BindToClose(function()
	_globalChannel:Post("CloseServer", _localServer)
end)

local Chimera = {
	ThisServer = function()
		return _localServer
	end,

	AllServers = function()
		return serverList
	end,

	ServerFromId = function(JobId: string)
		return serverList[JobId]
	end,

	AllServersWith = function(KeyName, KeyValue)
		local PossibleServers = {}
		for JobId, Data in serverList do
			if Data[KeyName] == nil then
				warn(string.format("Chimera: Server %s does not have key %s, skipped.", tostring(JobId), KeyName))
				continue
			end
			if Data[KeyName] == KeyValue then
				PossibleServers[JobId] = Data
			end
		end
		return PossibleServers
	end,

	TeleportToServer = function(PlayerList, TargetServer: table, TeleportData: table)
		if typeof(PlayerList) ~= "table" then
			PlayerList = { PlayerList }
		end

		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions.ServerInstanceId = TargetServer.JobId
		TeleportOptions:SetTeleportData(TeleportData)
		TeleportService:TeleportAsync(game.PlaceId, PlayerList, TeleportOptions)
	end,
}

return Chimera
