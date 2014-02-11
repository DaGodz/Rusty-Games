PLUGIN.Title = "Rusty Games"
PLUGIN.Description = "An Oxide plugin inspired by movies such as The Hunger Games and Battle Royale."

function PLUGIN:Init()
  self:AddChatCommand("tinroof", self.cmdTinRoof)
end

function PLUGIN:cmdTinRoof(netuser, cmd, args)
  rust.Notice(netuser,"Rusty!",10000)
end