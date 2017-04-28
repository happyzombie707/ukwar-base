--[[TODO
	remove magic numbers for the teams, replace with constant or whatever lua has instead of a constant, possibly a table
	improve team balance, add autobalance if one team has a much greater score than the other
]]

--RUNTIME_LOG("ENTERED INIT.LUA")

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include( 'shared.lua' )
include( 'player.lua' )
include( 'npc.lua' )
include( 'variable_edit.lua' )

--net messages
util.AddNetworkString( "ShowMenu" )
util.AddNetworkString( "ChangeTeam" )

function RUNTIME_LOG(str_string)
	print(">>> " .. str_string)
end

GM.PlayerSpawnTime = {}

--[[---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn()
   Desc: Called on a player's initial spawn
-----------------------------------------------------------]]
function GM:PlayerInitialSpawn( ply )
	
	ply:SetModel("models/player/breen.mdl")

	--try to keep team numbers roughly even
	if(team.NumPlayers(1) < team.NumPlayers(2)) then
		ply:SetTeam( 1 )
	else
		ply:SetTeam(2)
	end
	ply.LastTeamSwitch = RealTime()

	--spawn message
	print("Player: " .. ply:Nick() .. ", has spawned on the " .. team.GetName(ply:Team()) .. " team.")
	--PlayerClasses.Add(ply, 0)
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawn()
   Desc: Called whenever a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( ply )

	--player_manager.SetPlayerClass( ply, "player_team" ) custom class, WIP
	
	print("Player " .. ply:Nick() .. " spawning on team " .. ply:Team())
	
	--set playermodel colour and spawn location based on team
	local points = {}
	if (ply:Team()== 1) then
		ply:SetPlayerColor( Vector( 1,0.2,0.2 ) )
		points = ents.FindByClass("spawn_red")			--get all spawn_red entities on server
	elseif (ply:Team()== 2) then
		ply:SetPlayerColor( Vector(0.2,0.2,1) )
		points = ents.FindByClass("spawn_blue")
	else
		ply:SetPlayerColor( Vector(0.25,0.25,0.25) ) 
	end

	ply:SetPos(points[math.random(1,#points)]:GetPos())
end

--[[---------------------------------------------------------
   Name: gamemode:Initialize()
   Desc: Called immediately after starting the gamemode
-----------------------------------------------------------]]
function GM:Initialize()

	local spawn_points = {									--proof of concept for storing spawn points as a vector then creating them on	
		["construct"] ={									--server init
			["red"] = Vector (397, -699, -147),             --ofc the actual version will get the values from a database or something
			["blue"] = Vector(358, -243, -147)
		},
		["flatgrass"] = {
			["red"] = Vector(-781, -905, -12287),
			["blue"] = Vector(-1394, -1677, -12799)
		}

	}

	local red_spawn = ents.Create("spawn_red")				--create an entity for the spawns
	local blue_spawn = ents.Create("spawn_blue")

	if(game:GetMap() == "gm_flatgrass") then				
		red_spawn:SetPos(spawn_points["flatgrass"]["red"])
		blue_spawn:SetPos(spawn_points["flatgrass"]["blue"])
	elseif(game:GetMap() == "gm_construct") then
		red_spawn:SetPos(spawn_points["construct"]["red"])
		blue_spawn:SetPos(spawn_points["construct"]["blue"])
	end

	--[[SQL implementation pseudocode
		x y z = SELECT x y z FROM Red.Spawns WHERE Spawns.map = game.GetMap()
		red_spawn:SetPos(Vector(x, y, z)) 

	]]
	red_spawn:Spawn()
	blue_spawn:Spawn()

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

	if (ply:IsPlayer()) and (victim:IsPlayer()) then       --if attacker and victim are both players
		if (ply:Team() ~=3) or (victim:Team() ~=3) then    --if neither of the people are on free for all
			if (ply:Team()) == (victim:Team()) then        --and if they are on the same team
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
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
	
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
	if ( ply.LastTeamSwitch && RealTime() - ply.LastTeamSwitch < TimeBetweenSwitches ) then
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
	if ( server_password != "" ) then

		-- The joining clients password doesn't match sv_password
		if ( server_password != password ) then
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
	if ( mv:KeyPressed( IN_DUCK ) && vehicle.SetThirdPersonMode ) then
		vehicle:SetThirdPersonMode( !vehicle:GetThirdPersonMode() )
	end

	--
	-- Adjust the camera distance with the mouse wheel
	--
	local iWheel = ply:GetCurrentCommand():GetMouseWheel()
	if ( iWheel != 0 && vehicle.SetCameraDistance ) then
		-- The distance is a multiplier
		-- Actual camera distance = ( renderradius + renderradius * dist )
		-- so -1 will be zero.. clamp it there.
		local newdist = math.Clamp( vehicle:GetCameraDistance() - iWheel * 0.03 * ( 1.1 + vehicle:GetCameraDistance() ), -1, 10 )
		vehicle:SetCameraDistance( newdist )
	end

end

--CUSTOM FUNCTIONS FOR HOOKS AND NET MESSAGES AND STUFF

--[[---------------------------------------------------------
   Name: Anonymous function
   Desc: Callback function, called when a player changes team with the team menu
-----------------------------------------------------------]]
net.Receive( "ChangeTeam", function( len, ply )
	 ply:SetTeam(net.ReadUInt(4))
	 ply.LastTeamSwitch = RealTime()
	 ply:Spawn()
end )

function Test(ply, text, public, data)
	if(string.sub(text:lower(), 1,5) == "!test") then
		print(ply:CanChangeTeam())
	end
end
hook.Add("PlayerSay", "Test", Test)

--[[---------------------------------------------------------
   Name: ShowTeamMenu()
   Desc: If the player runs the team command tell their client to open the team menu
-----------------------------------------------------------]]
function ShowTeamMenu(ply, text, public, data)
	if(string.sub(text:lower(), 1,5) == "!team") then
		if(ply:CanChangeTeam()) then
			net.Start( "ShowMenu" )			--show menu net message
			net.WriteUInt(ply:Team(), 4)	--send current team, to be displayed on the menu
			net.Broadcast()					
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
function PrintLoc(ply, text, public, data)
	if(string.sub(text:lower(), 1,4) == "!pos") then
		print (ply:GetPos().x .. ", " .. ply:GetPos().y .. ", " .. ply:GetPos().z)
	end
end
hook.Add("PlayerSay","PrintLoc",PrintLoc)
