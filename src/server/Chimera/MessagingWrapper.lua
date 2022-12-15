local MessagingService = game:GetService("MessagingService")
local Wrapper = {}
Wrapper.__index = Wrapper

function Wrapper.Channel(Id: string)
	local ChannelLink
	if Id == "Global" then
		ChannelLink = "ChimeraGlobalRequest"
	else
		ChannelLink = "ChimeraRequestId" .. Id
	end
	return setmetatable({ ChannelLink = ChannelLink, Identifier = Id }, Wrapper)
end

local GlobalChannel = Wrapper.Channel("Global")

function Wrapper.GetGlobalChannel()
	return GlobalChannel
end

function Wrapper:Post(...)
	MessagingService:PublishAsync(self.ChannelLink, ...)
end

function Wrapper:Listen(AttachedFunction)
	return MessagingService:SubscribeAsync(self.ChannelLink, AttachedFunction)
end

return Wrapper
