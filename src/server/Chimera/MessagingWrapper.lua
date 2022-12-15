local MessagingService = game:GetService("MessagingService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Wrapper = {}

local GLOBAL_CHANNEL_LINK = "GlobalChimeraChannel"
local PRIVATE_CHANNEL_PREFIX = "PrivateChimera"

local _mockEvent = nil
if RunService:IsStudio() then 
    warn("Chimera: Chimera is running in studio, MessagingService won't work. MessagingWrapper will run in mock mode. teehee")
    _mockEvent = Instance.new('BindableEvent'),
end 

function Wrapper.GlobalChannelLink()
    return  GLOBAL_CHANNEL_LINK
end 

function Wrapper.PrivateChannelLink()
    return  PRIVATE_CHANNEL_PREFIX
end 

function Wrapper.PublishAsync(ChannelLink : string, ...)
    if _mockEvent then 
        return _mockEvent:Fire(ChannelLink,
            HttpService:JsonEncode(Data = {...})
        )
    end 

    return MessagingService:PublishAsync(ChannelLink, ...)
end 

function Wrapper.Listen(ChannelLink : string, Listener : func: (any) -> (any) )
    if _mockEvent then 
        return _mockEvent.OnEvent:Connect(function(ChannelLinkMock,MessageEncoded)
            if ChannelLinkMock ~= ChannelLink then
                return
            end 

            local DecodedData = HttpService:JSONDecode(MessageEncoded.Data)
            Listener(DecodedData,MessageEncoded)    
        end)
    end 

    return MessagingService:SubscribeAsync(self.ChannelLink, function(MessageEncoded) 
        local DecodedData = HttpService:JSONDecode(MessageEncoded.Data)
        Listener(DecodedData,MessageEncoded)
    end)
end 


return Wrapper