local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local ServerObject = require(script.ServerObject)
local MessagingWrapper = require(script.MessagingWrapper)


local GLOBAL_CHANNEL_LINK =  MessagingWrapper.GlobalChannelLink()
local PRIVATE_CHANNEL_PREFIX =  MessagingWrapper.PrivateChannelLink()

local _localServer = ServerObject.new()
local _jobId = _localServer.JobId

local serverList = {}

local function defaultMessageHandler(RawMessage : table)
	local Request = RawMessage[1]
	local Server = RawMessage[2]

	if Request == "UpdateServer" then
		serverList[Server:GetId()] = Server
	elseif Request == "CloseServer" then
		serverList[Server:GetId()] = nil
	end
end

MessagingWrapper.Listen(PRIVATE_CHANNEL_PREFIX.._jobId, function(DecodedData,MessageEncoded)
	_localServer.RequestHandler(DecodedData,MessageEncoded) 
end)

MessagingWrapper.Listen(GLOBAL_CHANNEL_LINK,defaultMessageHandler)

game:BindToClose(function()
    MessagingWrapper.PublishAsync(GLOBAL_CHANNEL_LINK,"CloseServer",self)
end)

local Chimera = {
	ThisServer = function()
		return _localServer
	end,

	AllServers = function()
		return serverList
	end,

	ServerFromId = function(JobId : string)
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

	TeleportToServer = function(PlayerList, ServerObject: table, TeleportData: table)
		if typeof(PlayerList) ~= "table" then
			PlayerList = { PlayerList }
		end

		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions.ServerInstanceId = ServerObject.JobId
		TeleportOptions:SetTeleportData(TeleportData)
		TeleportService:TeleportAsync(game.PlaceId, PlayerList, TeleportOptions)
	end,
} 

return Chimera