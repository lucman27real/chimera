local ServerObject = {}
ServerObject.__index = ServerObject
local MessagingService = game:GetService("MessagingService")

local MessageWrapper = require(script.Parent.MessagingWrapper)
local GlobalChannel = MessageWrapper.GetGlobalChannel()

function ServerObject.new()
	local self = setmetatable({
		JobId = game.JobId,
		Keys = {},
        Channel = MessageWrapper.Channel(game.JobId),
		OnTeleport = function(...) end,
		RequestHandler = function(...) end,
	}, ServerObject)
    GlobalChannel:Post("UpdateServer",self)
    return self 
end

function ServerObject:SetPrivateRequestHandler(... : function) 
    self.RequestHandler = ...
end 

function ServerObject:SetOnTeleportHandler(... : function) 
    self.OnTeleport = ...
end 

function ServerObject:GetId()
	return self.JobId
end

function ServerObject:SetKey(name, val)
	self.Keys[name] = val
    GlobalChannel:Post("UpdateServer",self)
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
        Target.Channel:Post("PrivateMessage", MessageData)
    end
end
