local ServerObject = {}
ServerObject.__index = ServerObject

local MessageWrapper = require(script.Parent.MessagingWrapper)
local GlobalChannel = MessageWrapper.GetGlobalChannel()

function ServerObject.new()
	local self = setmetatable({
		JobId = game.JobId,
		Keys = {},
		Channel = MessageWrapper.Channel(game.JobId),
		OnTeleport = function() end,
		RequestHandler = function() end,
	}, ServerObject)
	GlobalChannel:Post("UpdateServer", self)
	return self
end

function ServerObject:SetPrivateRequestHandler(...)
	self.RequestHandler = ...
end

function ServerObject:SetOnTeleportHandler(...)
	self.OnTeleport = ...
end

function ServerObject:GetId()
	return self.JobId
end

function ServerObject:SetKey(KeyName: string, KeyValue: string)
	self.Keys[KeyName] = KeyValue
	GlobalChannel:Post("UpdateServer", self)
end

function ServerObject:GetKey(KeyName: string)
	return self.Keys[KeyName]
end

function ServerObject:Message(Targets: table, MessageData: table)
	if self.JobId ~= game.JobId then
		warn("Chimera: Trying to message from a foreign server.")
		return
	end
	if getmetatable(Targets).__index == ServerObject then
		Targets = { Targets }
	end
	for _, Target in Targets do
		Target.Channel:Post("PrivateMessage", MessageData)
	end
end
