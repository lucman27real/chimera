local ServerObject = {}
ServerObject.__index = ServerObject
local MessagingWrapper = require(script.Parent.MessagingWrapper)

local GLOBAL_CHANNEL_LINK =  MessagingWrapper.GlobalChannelLink()
local PRIVATE_CHANNEL_PREFIX =  MessagingWrapper.PrivateChannelLink()

function ServerObject.new()
	local self = setmetatable({
		JobId = game.JobId,
		Keys = {},
		OnTeleport = function() end,
		RequestHandler = function() end,
	}, ServerObject)
    MessagingWrapper.PublishAsync(GLOBAL_CHANNEL_LINK,"UpdateServer",self)
    return self 
end

function ServerObject.IsServer(MysteriousTable : table) 
	return getmetatable(MysteriousTable).__index = ServerObject
end 

function ServerObject:SetPrivateRequestHandler(... : function) 
    return self.RequestHandler = ...
end 

function ServerObject:SetOnTeleportHandler(... : function) 
	return self.OnTeleport = ...
end 

function ServerObject:GetId()
	return self.JobId
end

function ServerObject:SetKey(KeyName : string, KeyValue : string)
	self.Keys[KeyName] = KeyValue
    return MessagingWrapper.PublishAsync(GLOBAL_CHANNEL_LINK,"UpdateServer",self)
end

function ServerObject:GetKey(KeyName : string)
	return self.Keys[KeyName]
end

function ServerObject:Message(Targets : table, MessageData : table)
	if self.JobId ~= game.JobId then
		warn("Chimera: Trying to message from a foreign server.")
		return
	end
	if getmetatable(Targets).__index == ServerObject then
		Targets = { Targets }
	end
	for _, Target in Targets do
        MessageWrapper.PublishAsync(PRIVATE_CHANNEL_PREFIX..Target.JobId, "PrivateMessage", MessageData)
    end
end
