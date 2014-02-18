PLUGIN.Title = "Rusty Games"
PLUGIN.Description = "An Oxide plugin inspired by movies such as The Hunger Games and Battle Royale."
PLUGIN.Author = "DaGodz"
PLUGIN.Version = "0.2"

deadUsers = {}

function PLUGIN:Init()
  print("Loading " .. self.Title .. " (" .. self.Version .. ")...")
  self:LoadConfig(false)
  self:AddChatCommand("tinroof", self.CmdTinRoof)
  self:AddCommand("rustygames", "resetconfig", self.CmdResetConfig)
end

function PLUGIN:LoadConfig(isReset)
	local b, res = config.Read("rustygames")
	self.Config = res or {}
	if (not b or isReset) then
		self:LoadDefaultConfig()
		if (res) then config.Save("rustygames") end
	end
end

function PLUGIN:LoadDefaultConfig()
  self.Config.chatName = "RustyGames"
  self.Config.broadcastChat = true
  self.Config.log = true
end

function PLUGIN:CmdResetConfig(netUser, cmd, args)
  self:LoadConfig(true)
  rust.Notice(netUser,"Config reset")
end

function PLUGIN:BroadcastChat(msg)
  if (self.Config.broadcastChat) then rust.BroadcastChat(self.Config.chatName, msg) end
end

function PLUGIN:Log(msg)
  if (self.Config.log) then print(self.Title .. ": " .. msg) end
end

function PLUGIN:CmdTinRoof(netUser, cmd, args)
  rust.Notice(netUser,"Rusty!")
end

function PLUGIN:OnKilled(takeDamage, damage)
  if (takeDamage:GetComponent("HumanController" )) then
    userName = damage.victim.client.userName
    deadUsers[userName] = true
    self:Log(userName .. " died.")
  end
end

function PLUGIN:OnSpawnPlayer(playerClient, useCamp, avatar)
  local userName = playerClient.userName
  if (deadUsers[userName]) then
    self:BroadcastChat(userName .. " is out of this Rusty Games!")
    playerClient.netUser:Kick(NetError.Facepunch_Kick_RCON, true)
    self:Log(userName .. " kicked for dying.")
    deadUsers[userName] = nil
  end
end