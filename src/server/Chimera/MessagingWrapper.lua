local MessagingService = game:GetService("MessagingService")
local Wrapper = {}
Wrapper.__index = Wrapper

function Wrapper.Channel(Id)
    local ChannelLink
    if Id == "Global" then 
        ChannelLink = "ChimeraGlobalRequest"
    else
        ChannelLink = "ChimeraRequestId"..Id
    end 
    return setmetatable({ChannelLink = ChannelLink; Identifier = Id;},Wrapper)
end 

GlobalChannel = Wrapper.Channel('Global')

function Wrapper.GetGlobalChannel()
    return GlobalChannel
end 

function Wrapper:Post(...)
    MessagingService:PublishAsync(self.ChannelLink, ...)
end 

function Wrapper:Listen(AttachedFunction : function)
    return MessagingService:SubscribeAsync(self.ChannelLink, AttachedFunction)
end 


return Wrapper