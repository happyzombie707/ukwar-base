--[[TODO
	remove magic numbers for the teams, replace with constant or whatever lua has instead of a constant, possibly a table
	improve team balance, add autobalance if one team has a much greater score than the other
]]

--RUNTIME_LOG("ENTERED INIT.LUA")

include( "loadout.lua" )
include ("player/player_ext.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("gui/team_menu.lua")
AddCSLuaFile("gui/loadout_admin.lua")
AddCSLuaFile("gui/squad_request.lua")


--include("/loadout.lua")
include( "sv_player_extend.lua" )
include( "game.lua" )
include( "shared.lua" )
include( "player.lua" )
include( "npc.lua" )
include( "variable_edit.lua" )

--net messages
util.AddNetworkString( "PlayerKill_Feed" )
util.AddNetworkString( "ShowTeamMenu" )
util.AddNetworkString( "AcceptInvite" )
util.AddNetworkString( "ShowLoadoutAdmin" )
util.AddNetworkString( "UpdatePlayer" )
util.AddNetworkString( "PlayerRequestLoadout" )
util.AddNetworkString( "InvitePlayer" )
util.AddNetworkString( "SendPlayerLoadout" )
util.AddNetworkString( "DisplayRequest" )
util.AddNetworkString( "UpdateSquad" )
util.AddNetworkString( "UpdateLoadout" )



function RUNTIME_LOG(str_string)
	print(">>> " .. str_string)
end

GM.SquadAlias = {}
GM.FreeTeams = {}
GM.PendingInvites = {}
GM.PlayerSpawnTime = {}
GM.SecondsBetweenTeamSwitches = 5
TEAM_RED = 1
TEAM_BLUE = 2


concommand.Add( "force_team", function( ply, cmd, args )
    ply:SetTeam(args[1])
end )


--[[---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn()
   Desc: Called on a player's initial spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply )

    ply:SetNWInt("loadout", 1)
    ply:Ex_Init()
    local player_id = ply:SteamID64()
    print (player_id)

    if (sql.Query("SELECT * FROM players WHERE player_id = " .. player_id) == nil) then
        sql.Query( "INSERT INTO players ( player_id,  player_level, player_exp) VALUES( '"..player_id.."', 0, 0 )" )
        print "createing player table"
    else
        local table_loadouts = sql.Query("SELECT * FROM loadouts WHERE player_id =" .. player_id) or {}
        print (sql.LastError())
        PrintTable (table_loadouts)

        for k, v in pairs(table_loadouts) do
            ply:W_AddLoadout(loadout.Create(v.loadout_name, v.prim, v.sec, v.mel, v.health, v.armour))
        end
    end


--    ply:AddLoadout(loadout.Create("Test", "fas2_g3", "fas2_m1911", "fas2_dv2", 150, 10))


    ply:SetNWBool("squad_spawn", false)
	--print("YOUR NAN " .. ply:Loadout())
	--ply:SetTeam(TEAM_UNASSIGNED)
	--ply:SetColor(Color(0,0,0,0))
	--ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:SetModel("models/player/breen.mdl")

    ply:SetTeam(GAMEMODE.FreeTeams[#GAMEMODE.FreeTeams])
    table.remove(GAMEMODE.FreeTeams, #GAMEMODE.FreeTeams)


	timer.Simple(1 ,function()
        local to_send = {}
        for k, v in pairs(ply:W_AllLoadouts()) do
            print (k .. " " .. v.Name)
            to_send[k] = {id=k, name=v.Name}
        end
		net.Start( "ShowTeamMenu" )													--show menu net message
        net.WriteTable(to_send)
		net.WriteUInt(1, 4)
        net.WriteString(GAMEMODE.SquadAlias[ply:Team()])												--send current team, to be displayed on the menu
        net.Send(ply)
	end)


																				--try to keep team numbers roughly even
	ply.LastTeamSwitch = RealTime()

																				--spawn message

																				--PlayerClasses.Add(ply, 0)
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawn()
   Desc: Called whenever a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( ply )

	--if (ply:IsBot() ) then ply:SetTeam(math.random(2)) end

	ply:StripWeapons() --remove player's weapons
	--set playermodel colour and spawn location based on team
	local points = {}															--create list to store possible spawn points in

	if(team.Valid(ply:Team()) and ply:Team() > 0 and ply:Team() < 1001) then	--if a valid team and not spectator, or unassigned etc
		local colour = team.GetColor(ply:Team())		--make a variable to store model colour
		ply:SetPlayerColor( Vector( colour.r/255, colour.g/255, colour.b/255 ) )--set player to team colour, converting colour value to vector
        local mode = ply:GetNWBool("squad_spawn")
        for k, v in pairs(ents.FindByClass("spawn_default"))do
            print (mode)
			if ((v:Team() == ply:Team() and mode) or (v:Team() == -1 and not mode)) then
				 table.Add(points, {v})
			 end																--if the spawn team is the same as the player team, add to list
		end
	else
		ply:SetPlayerColor( Vector(0.25,0.25,0.25) )							--if player not on a valid team
	end

	if(points[1] == nil) then
		print ("empty")															--if spawn list is empty
		points = ents.FindByClass("info_player_start")							--set them to the default spawn
	end

	ply:SetPos(points[math.random(1,#points)]:GetPos())							--randomly select a spawn from list

	--print ("XDD " .. ply:Loadout())
	--if(loadout.Valid(ply:Loadout(), ply:SteamID())) then
    										--if they have a loadout that's valid
    local lod = ply:W_GetLoadout(ply:GetNWInt("loadout"))

    ply:SetMaxHealth(loadout.GetMaxHealth(lod) or 100)					--set max health
	ply:SetHealth(loadout.GetMaxHealth(lod) or 100)						--set current health (same as max)
	ply:SetArmor(loadout.GetStartingArmour(lod) or 0)				--set armor
	ply:SetWalkSpeed(loadout.GetSpeed(lod) or 1)						--set speed
	ply:SetRunSpeed(loadout.GetSpeed(lod))					--set run to be 100 faster than walking

	for k, v in pairs(loadout.GetWeapons(lod))do					--get all weapons for the loadout and loop
		ply:Give(v)															--give player current weapon
	end

	ply:SelectWeapon(loadout.GetPrimary(lod))						--set default to primary
	--else
	--end
	for k, v in pairs(weapons.GetList()) do
	//	print(v:GetPrintName() .. " - " .. v:GetWeight())
	end
end

--[[---------------------------------------------------------
   Name: gamemode:Initialize()
   Desc: Called immediately after starting the gamemode
-----------------------------------------------------------]]
function GM:PlayerSilentDeath(victim, inflictor, attacker)
	victim:StripWeapons()
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerDisconnected()
   Desc: Called immediately after starting the gamemode
-----------------------------------------------------------]]
function GM:PlayerDisconnected(ply)
    local team_id = ply:Team()
    if #team.GetPlayers(team_id) <= 1 then
        table.insert(GAMEMODE.FreeTeams, team_id)
    end
end

--[[---------------------------------------------------------
   Name: gamemode:Initialize()
   Desc: Called immediately after starting the gamemode
-----------------------------------------------------------]]
function GM:Initialize()

    --create list of available teams
    for i=1, game.MaxPlayers() do
        table.insert(GAMEMODE.FreeTeams, i)
    end

    for i=1, #team.GetAllTeams() do
        table.insert(GAMEMODE.SquadAlias, "Squad " .. i)
    end

    PrintTable(GAMEMODE.SquadAlias)

    --create table for and set up spawns
	if (!sql.TableExists(game.GetMap())) then sql.Query (  "CREATE TABLE " .. game.GetMap() .. " (Type int, Data int, x int, y int, z int )" ) end
	local table_custom_ents = sql.Query("SELECT * FROM " .. game.GetMap() .. " WHERE Type = 1") or {}
	if (table_custom_ents != nil) then
		for k, v in pairs(table_custom_ents) do
			CreateSpawnEnt(v)
		end
	end

    --{ Name = "Default", 	Melee = "", Secondary = "", 	Primary = "", MaxHealth = 100, StartingArmour = 0, Speed = 400, SpecialPurpose = true}


    --create player - loadout link table
    if (!sql.TableExists("players")) then sql.Query (  "CREATE TABLE players (player_id string, player_level int, player_exp int)" ) end

    --create table for loadouts
    if (!sql.TableExists("loadouts")) then
        sql.Query ("CREATE TABLE loadouts (loadout_id int, player_id string, loadout_name string, prim string, sec string, mel string, health int, armour int)")
        print (sql.LastError())
    end

    --create table for weapons
    if (!sql.TableExists("weapons")) then
        sql.Query ("CREATE TABLE weapons (weapon_id string, slot string, weight int)")
    end
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerConnect()
   Desc: Called when a player connects
-----------------------------------------------------------]]
function GM:PlayerConnect( name, ip )

end

--[[---------------------------------------------------------
   Name: gamemode:InitPostEntity()
   Desc: Called as soon as all map entities have been spawned
-----------------------------------------------------------]]
function GM:InitPostEntity()
end

--[[---------------------------------------------------------
   Name: gamemode:Think()
   Desc: Called every frame
-----------------------------------------------------------]]
function GM:Think()
end

--[[---------------------------------------------------------
   Name: gamemode:ShutDown()
   Desc: Called when the Lua system is about to shut down
-----------------------------------------------------------]]
function GM:ShutDown()
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage( )
   Desc: Checks whether a player should take damage from attacks
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, victim )

	if (ply:IsPlayer() and victim:IsPlayer() and GAME.flags.PLAYER_CAN_KILL) then       --if attacker and victim are both players
			if (ply:Team() == victim:Team()) then        --and if they are on the same team
				return false							   --take no damage
			end
	end
	return true											   --otherwise take damage
end

--[[---------------------------------------------------------
   Name: gamemode:DoPlayerDeath( )
   Desc: Carries out actions when the player dies
-----------------------------------------------------------]]
function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()

	ply:AddDeaths( 1 )

	if ( attacker:IsValid() and attacker:IsPlayer() ) then

		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end

	end

end

--[[
    Name: GM:ScalePlayerDamage
    Desc: Scale the damage done to a player
]]
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
    if(hitgroup == HITGROUP_HEAD) then
        dmginfo:ScaleDamage(2)
    elseif (hitgroup == HITGROUP_CHEST) then
        dmginfo:ScaleDamage(1)
    elseif (hitgroup == HITGROUP_STOMACH) then
        dmginfo:ScaleDamage(0.75)
    else
        dmginfo:ScaleDamage(0.666)
    end
    return false
end

--[[---------------------------------------------------------
   Name: gamemode:EntityTakeDamage( ent, info )
   Desc: The entity has received damage
-----------------------------------------------------------]]
function GM:EntityTakeDamage( ent, dmginfo) --, attacker) -- amount, dmginfo
	-- Fiddle with damage, for example, remove explosion damage
	if(DEBUG_VERBOSE) then
		print("[EntityTakeDamage]")
	end
	print("[EntityTakeDamage]")

	--if(attacker == nil) then return end

	--print("Hit ent: ", ent:IsPlayer(), attacker:IsPlayer())

	if(ent:IsPlayer() and dmginfo:GetAttacker():IsPlayer()) then

		--hitgroup == HITGROUP_LEFTARM ||
		--hitgroup == HITGROUP_RIGHTARM ||
		--hitgroup == HITGROUP_LEFTLEG ||
		--hitgroup == HITGROUP_RIGHTLEG ||
		print("EntityTakeDamage: Player")
		ent:STATE_SetBleed(1)


		dmginfo:GetAttacker():STAT_Add_AttackBullet(1)
		local int_hitgroup = ent:LastHitGroup()
        print(int_hitgroup)
		if(int_hitgroup > 0 and int_hitgroup < 8) then	end

		--if(DEBUG_VERBOSE) then
		MsgC(CONST_COL_TEXT_COLOUR, "[EntityTakeDamage]: Entity Hit:\n\tIsBullet: ", dmginfo:IsBulletDamage(),
			"\n\tHealth: ", ent:Health(),
			"\n\tDamage: ", dmginfo:GetDamage(),
			"\n\tAttacker: ", dmginfo:GetAttacker(), "\n")
		--end
		-- if(Suicidevalue) then
			-- DO SOMETHING HERE
		--end

		if(	dmginfo:IsBulletDamage() and
			dmginfo:GetDamage() > 80 and ent:Health() - dmginfo:GetDamage() < 0 --> 80 and dmginfo:GetDamage() > 80
			) then

			if(DEBUG_VERBOSE) then
				MsgC(Color(150, 150, 100), "[EntityTakeDamage] -> Critical, Z-Time")
			end
			-- Go Into slow motion

			GAME:TimeScale(5)
			if(bKillGravityFunky) then
				ent:SetGravity( 0 )
				ent:SetVelocity(Vector(0, 0, 500))
				print(ent:GetVelocity())
			end

			if(bExplodeOnLethalBullet) then
				local explode = ents.Create( "env_explosion" )
				--explode:SetOwner( <PLAYER> )

				local pos = ent:GetPos()
				pos:Add(Vector(0, 0, 0))
				explode:SetPos( pos ) --ent:GetPos()
				explode:Spawn()
				explode:SetKeyValue( "iMagnitude", "220" )
				explode:Fire( "Explode", 0, 0 )
			end
		end
	end
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerHurt( )
   Desc: Called when a player is hurt.
-----------------------------------------------------------]]
function GM:PlayerHurt( victim, attacker, healthleft, healthtaken )
	--print("Ply: [" .. player:Nick() .. "] Hit: [" .. attacker:Nick() .. "]")
	if(DEBUG_VERBOSE) then
		print("[PlayerHurt]")
	end

	if ( attacker != nil and attacker:IsPlayer()) then

		attacker:KF_UpdateLastHit(victim:UniqueID(), healthtaken)
		if( healthleft <= 0 and healthtaken > 80 ) then
			--print("Critical")
		end

		if(DEBUG_VERBOSE) then
			MsgC(Color( 100, 255, 100 ), "[PlayerHurt] Atk: [" .. attacker:Nick() .. "] Hit: " .. victim:Nick()
			.. " healthtaken: " ..healthtaken .. "/" .. healthleft, "\n")
		end

		--print("[PlayerHurt] Atk: [" .. attacker:Nick() .. "] Hit: " .. victim:Nick()
		--.. " healthtaken: " ..healthtaken .. "/" .. healthleft)
	else
		--MsgC(Color( 100, 255, 100 ), "[PlayerHurt] Hit by non player SENT\n")
	end
end

--[[---------------------------------------------------------
   Name: gamemode:CreateEntityRagdoll( entity, ragdoll )
   Desc: A ragdoll of an entity has been created
-----------------------------------------------------------]]
function GM:CreateEntityRagdoll( entity, ragdoll )
end

-- Set the ServerName every 30 seconds in case it changes..
-- This is for backwards compatibility only - client can now use GetHostName()
local function HostnameThink()
	SetGlobalString( "ServerName", GetHostName() )
end

timer.Create( "HostnameThink", 30, 0, HostnameThink )

--[[---------------------------------------------------------
	Show the default team selection screen
-----------------------------------------------------------]]
function GM:ShowTeam( ply )

	if ( !GAMEMODE.TeamBased ) then return end

	local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
	if ( ply.LastTeamSwitch and RealTime() - ply.LastTeamSwitch < TimeBetweenSwitches ) then
		ply.LastTeamSwitch = ply.LastTeamSwitch + 1
		ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", ( TimeBetweenSwitches - ( RealTime() - ply.LastTeamSwitch ) ) + 1 ) )
		return false
	end

	-- For clientside see cl_pickteam.lua
	ply:SendLua( "GAMEMODE:ShowTeam()" )

end

--
-- CheckPassword( steamid, networkid, server_password, password, name )
--
-- Called every time a non-localhost player joins the server. steamid is their 64bit
-- steamid. Return false and a reason to reject their join. Return true to allow
-- them to join.
--
function GM:CheckPassword( steamid, networkid, server_password, password, name )

	-- The server has sv_password set
	if ( server_password ~= "" ) then

		-- The joining clients password doesn't match sv_password
		if ( server_password ~= password ) then
			return false
		end

	end

	--
	-- Returning true means they're allowed to join the server
	--
	return true

end

--[[---------------------------------------------------------
   Name: gamemode:FinishMove( player, movedata )
-----------------------------------------------------------]]
function GM:VehicleMove( ply, vehicle, mv )

	--
	-- On duck toggle third person view
	--
	if ( mv:KeyPressed( IN_DUCK ) and vehicle.SetThirdPersonMode ) then
		vehicle:SetThirdPersonMode( !vehicle:GetThirdPersonMode() )
	end

	--
	-- Adjust the camera distance with the mouse wheel
	--
	local iWheel = ply:GetCurrentCommand():GetMouseWheel()
	if ( iWheel ~= 0 and vehicle.SetCameraDistance ) then
		-- The distance is a multiplier
		-- Actual camera distance = ( renderradius + renderradius * dist )
		-- so -1 will be zero.. clamp it there.
		local newdist = math.Clamp( vehicle:GetCameraDistance() - iWheel * 0.03 * ( 1.1 + vehicle:GetCameraDistance() ), -1, 10 )
		vehicle:SetCameraDistance( newdist )
	end

end

--CUSTOM FUNCTIONS FOR HOOKS AND NET MESSAGES AND STUFF

--[[---------------------------------------------------------
   Name: CreateSpawn()
   Desc: Callback function, called when a player changes team with the team menu
-----------------------------------------------------------]]
function CreateSpawnEnt( spawn_info )

	local spawn_ent = ents.Create("spawn_default")

    print (spawn_info.Data)

	local spawn_pos = Vector( spawn_info.x, spawn_info.y, spawn_info.z )
	if (spawn_pos ~= nil ) then
		spawn_ent:SetPos( spawn_pos )
		spawn_ent:SetTeam( spawn_info.Data )
		spawn_ent:Spawn()

	else
		print("Error creating spawn point for " .. team.GetName(int_team))
	end

end


--[[---------------------------------------------------------
   Name: Anonymous function
   Desc: Callback function, called when a player changes team with the team menu
-----------------------------------------------------------]]
net.Receive( "UpdateSquad", function( len, ply )

    local colour = net.ReadColor()
    local squad_name = net.ReadString()
    local _team = ply:Team()
    print(colour.r .. ", " .. colour.g .. ", " .. colour.b)

    GAMEMODE.SquadAlias[_team] = squad_name

    team.SetColor(_team, colour)
    for k, v in pairs(team.GetPlayers(_team)) do
        v:SetPlayerColor( Vector( colour.r/255, colour.g/255, colour.b/255 ) )--set player to team colour, converting colour value to vector
    end


end)

--[[---------------------------------------------------------
   Name: Anonymous function
   Desc: Callback function, called when a player changes team with the team menu
-----------------------------------------------------------]]
net.Receive( "UpdatePlayer", function( len, ply )

    local leave_team = net.ReadBool()
    local respawn = net.ReadBool()
    local is_silent = net.ReadBool()
    local squad_spawn = net.ReadBool()
    local player_model = net.ReadString()
    local player_loadout = net.ReadInt(4)
    print ("xd "..player_loadout)
    ply:SetNWInt("loadout", player_loadout)

    print (player_model)

    ply:SetNWBool("squad_spawn", squad_spawn)
    --ply:SetLoadout(player_loadout)
    ply:SetModel(player_model)

    --if player is leaving current squad
    if leave_team then  --if already in empty squad
        if #team.GetPlayers(ply:Team()) <= 1 then
            ply:PrintMessage(HUD_PRINTTALK, "There is no escape :^)")
        else    --if worth leaving get a free squad, mark it as unavailable and join it
            local new_team = GAMEMODE.FreeTeams[#GAMEMODE.FreeTeams]
            table.remove(GAMEMODE.FreeTeams, #GAMEMODE.FreeTeams)
            ply:SetTeam(new_team)
            PrintMessage(HUD_PRINTTALK, "Player " .. ply:Nick() .. " has joined the " .. team.GetName(ply:Team()) .. " team.")
            ply.LastTeamSwitch = RealTime()
        end
    end

    --if respawning
    if respawn then
        if silent then
            ply:KillSilent() --kill silent if needed
        else
            ply:Kill()    --otherwise just kill
        end
    end
end )

net.Receive("InvitePlayer", function ( len, ply )

    local player_id = net.ReadString()
    print (player_id)
    local team_id = ply:Team()
    local pl = player.GetBySteamID( player_id )
    if(pl:IsBot()) then pl:SetTeam(team_id); pl:Kill(); return end
    GAMEMODE.PendingInvites[pl:SteamID()] = team_id
    net.Start("DisplayRequest")
    net.WriteString(ply:SteamID())
    net.WriteString(GAMEMODE.SquadAlias[team_id])
    net.Send(pl)
end)

net.Receive("AcceptInvite", function (len, ply)

    if net.ReadBool() then
        ply:SetTeam(GAMEMODE.PendingInvites[ply:SteamID()])
        ply:KillSilent()
    end
    GAMEMODE.PendingInvites[ply:SteamID()] = nil
end)

net.Receive ("PlayerRequestLoadout", function( len, ply )		--when player requests loadout list
	str_player_id = net.ReadString()	--read steamID from netmessage
	net.Start("SendPlayerLoadout")	--start netmessage to send list of names
	loadout_names = {}							--create table to store loadout names
	loadouts = loadout.W_GetAllLoadouts(str_steam_id)	--get all loadouts for player

	print ("meme: " .. #loadouts)

	for k, v in pairs(loadouts) do		--for each loadout, add the name to the list with the key
		table.insert(loadout_names, {loadout.GetName(v)})
		print(loadout.GetName(v))
	end
	--loadout.AddPlayerLoadout
	print ("DX " .. #loadout_names)
	net.WriteTable(loadout_names)
	net.Send(ply)
end)

--who knows what this is for, probs debugging
function Test(ply, text, public, data)
	if (string.sub(text:lower(), 1,5) == "!test") then
        collectgarbage( "collect")
    end
end
hook.Add("PlayerSay", "test", Test)


--[[---------------------------------------------------------
   Name: ShowTeamMenu()
   Desc: If the player runs the team command tell their client to open the team menu
-----------------------------------------------------------]]
function ShowTeamMenu(ply, text, public, data)
	if (string.sub(text:lower(), 1,5) == "!team") then
		if (ply:CanChangeTeam()) then
            print "hello??????"
            local to_send = {}
            for k, v in pairs(ply:W_AllLoadouts()) do
                print (k .. " " .. v.Name)
                to_send[k] = {id=k, name=v.Name}
            end


			net.Start( "ShowTeamMenu" )			--show menu net message
            net.WriteTable(to_send)
			net.WriteUInt(ply:Team(), 6)	--send current team, to be displayed on the menu
            net.WriteString(GAMEMODE.SquadAlias[ply:Team()])
            net.WriteInt(ply:GetNWInt("loadout"), 4)
            local has_spawn = false
            for _, v in pairs(ents.FindByClass("spawn_default")) do
                if (v:Team() == ply:Team()) then has_spawn = true; break end
            end
            net.WriteBool(has_spawn)
            net.Send(ply)
		else
			local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
			ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", ( TimeBetweenSwitches - ( RealTime() - ply.LastTeamSwitch ) ) + 1 ) )
		end
	end
end
hook.Add("PlayerSay","ShowTeamMenu",ShowTeamMenu) --add command


--[[---------------------------------------------------------
   Name: ShowLoadoutMenu()
   Desc: If the player runs the team command tell their client to open the team menu
-----------------------------------------------------------]]
function ShowLoadoutMenu(ply, text, public, data)
	if (string.sub(text:lower(), 1,5) == "!loadout") then
		if (ply:CanChangeTeam()) then
			net.Start( "ShowLoadMenu" )			--show menu net message
			net.WriteUInt(ply:Team(), 4)	--send current team, to be displayed on the menu
			net.Send(ply)
		else
			local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
			ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", ( TimeBetweenSwitches - ( RealTime() - ply.LastTeamSwitch ) ) + 1 ) )
		end
	end
end
hook.Add("PlayerSay","ShowTeamMenu",ShowTeamMenu) --add command

--[[---------------------------------------------------------
   Name: ShowLoadoutMenu()
   Desc: If the player runs the team command tell their client to open the team menu
-----------------------------------------------------------]]
function ShowLoadoutAdmin(ply, text, public, data)
    if (string.sub(text:lower(), 1,3) == "!la") then

       net.Start( "ShowLoadoutAdmin" )
	   net.Send(ply)
   end
end
hook.Add("PlayerSay","ShowLoadoutAdmin",ShowLoadoutAdmin) --add command


--[[---------------------------------------------------------
   Name: GetTeamId()
   Desc: Takes a team name and returns the ID
-----------------------------------------------------------]]
net.Receive ("UpdateLoadout", function( len, ply )

    local mode = net.ReadInt(2)
    local name = net.ReadString()
    local primary = net.ReadString()
    local secondary = net.ReadString()
    local melee = net.ReadString()



end)


--[[---------------------------------------------------------
   Name: GetTeamId()
   Desc: Takes a team name and returns the ID
-----------------------------------------------------------]]
function GetTeamId(team_name)

    team_id = -1    --default value
    team_name = team_name:lower() --make sure team name is lowercase

    --for each team
    for k, v in pairs (team.GetAllTeams()) do
        if v.Name:lower() == team_name then --if team name = given name
            team_id = k     --update team_id
            break           --break out of loop
        end
    end
    return team_id          --return id
end


--[[---------------------------------------------------------
   Name: SetSpawn()
   Desc: Function for the set spawn command
-----------------------------------------------------------]]
function SetSpawn(ply, text, public, data)
    --if first part of message is setspawn command
	if (string.sub(text:lower(), 1,9) == "!setspawn") then
		local team_name = string.sub(text:lower(), 11, 21):gsub("%s+", "")  --extract the team name
        local team_id = GetTeamId(team_name)    --get the team id from the name
        if team_id ~= -1 or team_name == "any" then                   --if valid team
            --insert into database and create entity for spawn
		    sql.Query("INSERT INTO " .. game.GetMap() .. " ( Type, Data, x, y, z ) VALUES ( 1,'" .. team_id .. "', " .. ply:GetPos().x .. ", " .. ply:GetPos().y .. ", " .. ply:GetPos().z .. " )")
		    CreateSpawnEnt({Data = team_id, x = ply:GetPos().x, y = ply:GetPos().y, z = ply:GetPos().z})
        else
            --if invalid team return error message
            ply:PrintMessage(HUD_PRINTTALK, "Invalid team name '" .. team_name .. "'.")
        end
        return false
    end
end
hook.Add("PlayerSay","SetSpawn",SetSpawn)   --register playersay hook
