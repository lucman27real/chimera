local thing = require(script.Parent.Main)
local ThisServer = thing.ThisServer()

print(ThisServer:GetId())
print(ThisServer:GetKey("gokuJoined"))
ThisServer:SetKey("gokuJoined", true)
print(ThisServer:GetKey("gokuJoined"))
