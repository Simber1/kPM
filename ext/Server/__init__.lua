class "kPMServer"

require ("ServerConfig")
require ("__shared/GameStates")
require ("Match")
local Team = require ("Team")

function kPMServer:__init()
    print("server initialization")

    -- Register all of our needed events
    self:RegisterEvents()

    -- Hold gamestate information
    self.m_GameState = GameStates.None

    -- Create our team information
    self.m_Team1 = Team(TeamId.Team1, "Attackers", "")
    self.m_Team2 = Team(TeamId.Team2, "Defenders", "")

    -- Create a new match
    self.m_Match = Match(self.m_Team1, self.m_Team2, 24)
end

function kPMServer:RegisterEvents()
    -- Engine tick
    self.m_EngineUpdateEvent = Events:Subscribe("Engine:Update", self, self.OnEngineUpdate)

    -- Player join/leave
    self.m_PlayerRequestJoinHook = Hooks:Install("Player:RequestJoin", 1, self, self.OnPlayerRequestJoin)

    self.m_PlayerJoiningEvent = Events:Subscribe("Player:Joining", self, self.OnPlayerJoining)
    self.m_PlayerLeaveEvent = Events:Subscribe("Player:Left", self, self.OnPlayerLeft)

    -- Team management
    self.m_PlayerFindBestSquadHook = Hooks:Install("Player:FindBestSquad", 1, self, self.OnPlayerFindBestSquad)
    self.m_PlayerSelectTeamHook = Hooks:Install("Player:SelectTeam", 1, self, self.OnPlayerSelectTeam)

    -- Round management
    
    -- Damage hooks
    self.m_SoldierDamageHook = Hooks:Install("Soldier:Damage", 1, self, self.OnSoldierDamage)
    self.m_ServerSuppressEnemies = Hooks:Install("Server:SupressEnemies", 1, self, self.OnServerSuppressEnemies)

    -- Events from the client
    self.m_ToggleRupEvent = NetEvents:Subscribe("kPM:ToggleRup", self, self.OnToggleRup)
end

function kPMServer:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    -- TODO: Implement time related functionaity
end

function kPMServer:OnPlayerRequestJoin(p_Hook, p_JoinMode, p_AccountGuid, p_PlayerGuid, p_PlayerName)
    -- TODO: Reject players if a match has started

    return true
end

function kPMServer:OnPlayerJoining(p_Name, p_Guid, p_IpAddress, p_AccountGuid)
    -- Here we can send the event to whichever state we are running in
    print("info: player " .. p_Name .. " (" .. p_Guid .. ") is attempting to join the server")
end

function kPMServer:OnPlayerLeft(p_Player)
    print("info: player " .. p_Name .. " has left the server")
end

function kPMServer:OnPlayerFindBestSquad(p_Hook, p_Player)
    -- TODO: Force squad
end

function kPMServer:OnPlayerSelectTeam(p_Hook, p_Player, p_Team)
    -- p_Team is R/W
    -- p_Player is RO
end

function kPMServer:OnSoldierDamage(p_Hook, p_Soldier, p_Info, p_GiverInfo)
    if p_Soldier == nil then
        return
    end

    if p_Info == nil then
        return
    end
end

function kPMServer:OnServerSuppressEnemies(p_Hook, p_SupressionMultiplier)
    -- Man if you don't get this bullshit outa here
    p_SupressionMultiplier = 0.0
end

function kPMServer:OnToggleRup(p_Player)
    -- Check to see if we have a valid player
    if p_Player == nil then
        print("err: invalid player tried to rup.")
        return
    end

    -- Get the player information
    local s_PlayerName = p_Player.name
    local s_PlayerId = p_Player.id

    -- We only care if we are in warmup state, otherwise rups mean nothing
    if self.m_GameState ~= GameStates.Warmup then
        print("err: player " .. s_PlayerName .. " tried to rup in non-warmup?")
        return
    end

    -- Update the match information
    self.m_Match:OnPlayerRup(p_Player)
end

return kPMServer()