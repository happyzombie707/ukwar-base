--[[TODO
	remove magic numbers for the teams, replace with constant or whatever lua has instead of a constant, possibly a table
	improve team balance, add autobalance if one team has a much greater score than the other
]]

--RUNTIME_LOG("ENTERED INIT.LUA")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

--include("/loadout.lua")

include( "loadout.lua" )
include( "shared.lua" )
include( "player.lua" )
include( "npc.lua" )
include( "variable_edit.lua" )

--net messages
util.AddNetworkString( "ShowMenu" )
util.AddNetworkString( "ChangeTeam" )
util.AddNetworkString( "PlayerLoadout" )

function RUNTIME_LOG(str_string)
	print(">>> " .. str_string)
end

GM.PlayerSpawnTime = {}
GM.SecondsBetweenTeamSwitches = 5
TEAM_RED = 1
TEAM_BLUE = 2


concommand.Add( "sv_loadout", function( ply, cmd, args )
	loadout.SetUp(#loadout.GetAllLoadouts()+1, "TEST", "weapon_crowbar", "fas2_m1911", "fas2_mac11", 100, 50, 500, false)
end )


--[[---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn()
   Desc: Called on a player's initial spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply )
	ply.loadout = 0
	ply:SetTeam(TEAM_UNASSIGNED)
	--ply:SetColor(Color(0,0,0,0))
	--ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:SetModel("models/player/breen.mdl")

	timer.Simple(1 ,function()
		net.Start( "ShowMenu" )													--show menu net message
		net.WriteUInt(1, 4)														--send current team, to be displayed on the menu
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

	if (ply:IsBot() ) then ply:SetTeam(math.random(2)) end

	ply:StripWeapons() --remove player's weapons

	--set playermodel colour and spawn location based on team
	local points = {}															--create list to store possible spawn points in

	if(team.Valid(ply:Team()) and ply:Team() > 0 and ply:Team() < 1001) then	--if a valid team and not spectator, or unassigned etc
		local colour = team.GetColor(ply:Team())		--make a variable to store model colour
		ply:SetPlayerColor( Vector( colour.r/255, colour.g/255, colour.b/255 ) )--set player to team colour, converting colour value to vector
		for k, v in pairs(ents.FindByClass("spawn_default"))do					--loop through all spawns
			if (v:Team() == ply:Team()) then
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


	if(loadout.Valid(ply:Loadout())) then										--if they have a loadout that's valid
		ply:SetMaxHealth(loadout.GetMaxHealth(ply:Loadout()))					--set max health
		ply:SetHealth(loadout.GetMaxHealth(ply:Loadout()))						--set current health (same as max)
		ply:SetArmor(loadout.GetStartingArmour(ply:Loadout()) or 0)				--set armor
		ply:SetWalkSpeed(loadout.GetSpeed(ply:Loadout()))						--set speed
		ply:SetRunSpeed(loadout.GetSpeed(ply:Loadout()) + 100)					--set run to be 100 faster than walking

		for k, v in pairs(loadout.GetWeapons(ply:Loadout()))do					--get all weapons for the loadout and loop
			ply:Give(v)															--give player current weapon
		end
		ply:SelectWeapon(loadout.GetPrimary(ply:Loadout()))						--set default to primary
	else
		ply:Give("weapon_pistol")
		ply:SelectWeapon("weapon_pistol")
	end
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
   Name: gamemode:Initialize()
   Desc: Called immediately after starting the gamemode
-----------------------------------------------------------]]
function GM:Initialize()

	if (!sql.TableExists(game.GetMap())) then sql.Query (  "CREATE TABLE " .. game.GetMap() .. " (Type int, Data int, x int, y int, z int )" ) end
	local table_custom_ents = sql.Query("SELECT * FROM " .. game.GetMap() .. " WHERE Type = 1") or {}
	if (table_custom_ents != nil) then
		for k, v in pairs(table_custom_ents) do
			CreateSpawnEnt(v)
		end
	end

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

	if (ply:IsPlayer() and victim:IsPlayer()) then       --if attacker and victim are both players
		if (ply:Team() ~= 3) or (victim:Team() ~= 3) then    --if neither of the people are on free for all
			if (ply:Team() == victim:Team()) then        --and if they are on the same team
				return false							   --take no damage
			end
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

--[[---------------------------------------------------------
   Name: gamemode:EntityTakeDamage( ent, info )
   Desc: The entity has received damage
-----------------------------------------------------------]]
function GM:EntityTakeDamage( ent, info )
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerHurt( )
   Desc: Called when a player is hurt.
-----------------------------------------------------------]]
function GM:PlayerHurt( player, attacker, healthleft, healthtaken )
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
net.Receive( "ChangeTeam", function( len, ply )
	 ply:SetTeam(net.ReadUInt(4))
	 ply:SetLoadout(net.ReadUInt(4))
	 ply.LastTeamSwitch = RealTime()
	 PrintMessage(HUD_PRINTTALK, "Player " .. ply:Nick() .. " has joined the " .. team.GetName(ply:Team()) .. " team.")
	 ply:Spawn()
end )

net.Receive ("PlayerLoadout", function( len, ply )

	--loadout.AddPlayerLoadout

end)



function Test(ply, text, public, data)
	if (string.sub(text:lower(), 1,5) == "!test") then
		loadout.SetUp(5, "Meme-Bandit", "weapon_crowbar", "fas2_deagle", "fas2_famas", 50, 0, 250, false)
		PrintTable(loadout.GetAllLoadouts())
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
			net.Start( "ShowMenu" )			--show menu net message
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
   Name: PrintLoc()
   Desc: Test method, used for getting xyz map coordinates
-----------------------------------------------------------]]
function SetSpawn(ply, text, public, data)
	if (string.sub(text:lower(), 1,9) == "!setspawn") then
		local team_name = string.sub(text:lower(), 11, 21):gsub("%s+", "")
		if (sql.QueryRow("SELECT * FROM " .. game.GetMap() .. " WHERE Type = 1 AND Data = " .. ply:Team()) == nil) then
			sql.Query( "INSERT INTO " .. game.GetMap() .. " ( Type, Data, x, y, z ) VALUES ( 1,'" .. team_name:lower() .. "', " .. ply:GetPos().x .. ", " .. ply:GetPos().y .. ", " .. ply:GetPos().z .. " )" )
		else
			sql.Query("INSERT INTO " .. game.GetMap() .. " ( Type, Data, x, y, z ) VALUES ( 1,'" .. team_name:lower() .. "', " .. ply:GetPos().x .. ", " .. ply:GetPos().y .. ", " .. ply:GetPos().z .. " )")
		end
		CreateSpawnEnt({Data = team_name, x = ply:GetPos().x, y = ply:GetPos().y, z = ply:GetPos().z})
		--ents.FindByClass("spawn_" .. team_name)[1]:Remove()
		--[[for k, v in pairs(team.GetAllTeams()) do
			if (k > TEAM_CONNECTING and k < TEAM_UNASSIGNED) then
				if (string.sub(text:lower(), 11, 21) == v.Name:lower()) then
					CreateSpawnEnt(k)
				end
			end
		end]]
	end
end
hook.Add("PlayerSay","SetSpawn",SetSpawn)
--	 sql.Query( "INSERT INTO player_data ( SteamID, Money ) VALUES ( '" .. ply:SteamID() .. "', 0 )" )
