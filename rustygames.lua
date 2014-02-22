PLUGIN.Title = "Rusty Games"
PLUGIN.Description = "An Oxide plugin inspired by movies such as The Hunger Games and Battle Royale."
PLUGIN.Author = "DaGodz"
PLUGIN.Version = "0.3"

if (not rustyGames) then
  rustyGames = {}
  rustyGames.deadUsers = {}
  rustyGames.inProgress = false
end

function PLUGIN:Init()
  print("Loading " .. self.Title .. " (" .. self.Version .. ")...")
  self:LoadConfig(false)

  self:AddChatCommand("startthegames", self.CmdStartTheGames)
  self:AddChatCommand("stopthegames", self.CmdStopTheGames)
  self:AddChatCommand("tinroof...", self.CmdTinRoof) -- a bit of fun

  self:AddCommand("rustygames", "resetconfig", self.CCmdResetConfig)
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
  self.Config.chatName = "The Rusty Announcer"
  self.Config.broadcastChat = true
  self.Config.log = true
  
  self.Config.say = {}
  self.Config.say.start = "Let the Rusty Games Commence!"
  self.Config.say.stop = "The Rusty Games have been abandoned!"
  self.Config.say.died = "is out of this Games!"
end

function PLUGIN:CCmdResetConfig(arg)
  self:LoadConfig(true)
  arg:ReplyWith("Rusty Games config reset")
  self:Log("Config reset")
end

function PLUGIN:CmdTinRoof(netUser, cmd, args)
  rust.Notice(netUser,"Rusted!")
end

function PLUGIN:CmdStartTheGames(netUser, cmd, args)
  if (netUser and not netUser:canAdmin()) then return end
  
  if (rustyGames.inProgress) then
    rust.Notice(netUser,"The Rusty Games are already in progress! You can abandon them with /stopthegames")
  else
    rustyGames.deadUsers = {}
    rustyGames.inProgress = true
    self:BroadcastChat(self.Config.say.start)
  end
end

function PLUGIN:CmdStopTheGames(netUser, cmd, args)
  if (netUser and not netUser:canAdmin()) then return end
  
  if (not rustyGames.inProgress) then
    rust.Notice(netUser,"The Rusty Games are not in progress! You can start them with /startthegames")
  else
    rustyGames.deadUsers = {}
    rustyGames.inProgress = false
    self:BroadcastChat(self.Config.say.stop)
  end
end

function PLUGIN:OnKilled(takeDamage, damage)
  if (not rustyGames.inProgress) then return end
  if (takeDamage:GetComponent("HumanController" )) then
    userName = damage.victim.client.userName
    rustyGames.deadUsers[userName] = true
    self:Log(userName .. " died.")
  end
end

function PLUGIN:OnSpawnPlayer(playerClient, useCamp, avatar)
  if (not rustyGames.inProgress) then return end
  local userName = playerClient.userName
  if (rustyGames.deadUsers[userName]) then
    self:BroadcastChat(userName .. " " .. self.Config.say.died)
    playerClient.netUser:Kick(NetError.Facepunch_Kick_RCON, true)
    self:Log(userName .. " kicked for dying.")
    rustyGames.deadUsers[userName] = nil
  end
end

function PLUGIN:BroadcastChat(msg)
  if (self.Config.broadcastChat) then rust.BroadcastChat(self.Config.chatName, msg) end
end

function PLUGIN:Log(msg)
  if (self.Config.log) then print(self.Title .. ": " .. msg) end
end