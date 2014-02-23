PLUGIN.Title = "Rusty Games"
PLUGIN.Description = "An Oxide plugin inspired by movies such as The Hunger Games and Battle Royale."
PLUGIN.Author = "DaGodz"
PLUGIN.Version = "0.4"

if (not rustyGames) then
  rustyGames = {}
  rustyGames.tributes = {}
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
  self.Config.say.start = "Tributes ready? Let the Rusty Games Commence!"
  self.Config.say.stop = "The Rusty Games have been abandoned!"
  self.Config.say.loser = "is out of this Games!"
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
  self:StartTheGames()
end

function PLUGIN:CmdStopTheGames(netUser, cmd, args)
  if (netUser and not netUser:canAdmin()) then return end
  
  if (not rustyGames.inProgress) then
    rust.Notice(netUser,"The Rusty Games are not in progress! You can start them with /startthegames")
  else
    self:StopTheGames()
    self:BroadcastChat(self.Config.say.stop)
  end
end

function PLUGIN:StartTheGames()
  if (rustyGames.inProgress) then
    rust.Notice(netUser,"The Rusty Games are already in progress! You can abandon them with /stopthegames")
  else
    local netUsers = rust.GetAllNetUsers()
    if (#netUsers < 2) then
      rust.Notice(netUser,"The Rusty Games need at least 2 tributes! Go and find a volunteer.")
    else
      for i, netUser in pairs(netUsers) do
        table.insert(rustyGames.tributes, netUser.playerClient.userName)
      end
      rustyGames.inProgress = true
      self:BroadcastChat(self.Config.say.start)
    end
  end
end

function PLUGIN:StopTheGames()
  rustyGames.inProgress = false
  rustyGames.tributes = {}
end

function PLUGIN:OnSpawnPlayer(playerClient, useCamp, avatar)
  if (not rustyGames.inProgress) then return end
  playerClient.netUser:Kick(NetError.Facepunch_Kick_RCON, true)
end

function PLUGIN:OnUserDisconnect(networkPlayer)
	local netUser = networkPlayer:GetLocalData()
  self:RemoveTribute(self:FindTribute(netUser.playerClient.userName))
end

function PLUGIN:RemoveTribute(key)
  if (not key) then return end
  self:BroadcastChat(rustyGames.tributes[key] .. " " .. self.Config.say.loser)
  table.remove(rustyGames.tributes, key)
  self:CheckWin()
end

function PLUGIN:FindTribute(userName)
  for key, value in pairs(rustyGames.tributes) do
    if (value == userName) then return key end
  end
end

function PLUGIN:CheckWin()
  if (#rustyGames.tributes == 1) then
    self:BroadcastChat("There is only one player remaining! " .. rustyGames.tributes[1] .. " has won the Rusty Games!")
    self:StopTheGames()
  end
end

function PLUGIN:BroadcastChat(msg)
  if (self.Config.broadcastChat) then rust.BroadcastChat(self.Config.chatName, msg) end
end

function PLUGIN:Log(msg)
  if (self.Config.log) then print(self.Title .. ": " .. msg) end
end