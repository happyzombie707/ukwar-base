-- Manages the killfeed, twiddled with to change the killfeed to be slightly more descriptive
--RUNTIME_LOG("ENTERED cl_deathnotice")

AddCSLuaFile()

include("cl_killstreak.lua")
print("[Runtime_entered] cl_deathnotice.lua");

surface.CreateFont( "HudScoreFont", {
	font = "Trebuchet", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

CONST_NO_TEAM = -1
FLAG_DISPLAY_NOTEAM_HINT = false
CONST_NET_KILL_HEADSHOT = 1

CONST_STR_HITSTR_TABLE = {

}

CONST_STR_HITSTR_DISPLAY_TABLE = {
	"", --NONE

	-- Head: Gun
	"HEADSHOT",
	"EAGLE",
	"MARKSMAN",

	-- Head: Melee
	"JAWBREAKER",
	"HOME RUN",
	"FISTS OF THUNDER",

	-- Chest
	"GUTSHOT",
	"PUNCTURE",
	"SWISS CHEESE",

	-- Legs
	"KNEECAPPER",
	
	-- Legs and arms
	"SHATTER",

	-- Arms
	"CLIPPER",

	-- General, explosive
	"FRAGMENTATION",
	"ORBITAL",
	"ESCAPE VELOCITY"
}

CONST_STR_HITGROUP_DISPLAY_TABLE = {
	"",
	"HEADSHOT",
	"PUNCTURE",
	"GUTSHOT",
	"", --"FRAGMENTATION",
	"",--"FRAGMENTATION",
	"",--"LEG SHATTER",
	"",--"LEG SHATTER"
}

function GetWeaponName(str_classname)
	local inf_ent = weapons.Get(str_classname)
	if ( inf_ent != nil ) then
		return inf_ent.PrintName
	else
		return str_classname
	end
end
function GetHitGroupDisplayString( int_index )
	return ( int_index < 8 ) and CONST_STR_HITGROUP_DISPLAY_TABLE[int_index+1] or "" --Ignore irregular enum
end
local hud_deathnotice_time = CreateConVar( "hud_deathnotice_time", "6", FCVAR_REPLICATED, "Amount of time to show death notice" )

-- These are our kill icons
local Color_Icon = Color( 255, 0, 0, 0 ) --Color( 255, 80, 0, 255 )
local NPC_Color = Color( 250, 50, 50, 255 )
 --[[
 --Chopped out the kill icon, and replaced it with a text string
 -- Thus, we can ( I think ) skip loading the fonts and icons here

killicon.AddFont( "prop_physics",		"HL2MPTypeDeath",	"9",	Color_Icon )
killicon.AddFont( "weapon_smg1",		"HL2MPTypeDeath",	"/",	Color_Icon )
killicon.AddFont( "weapon_357",			"HL2MPTypeDeath",	".",	Color_Icon )
killicon.AddFont( "weapon_ar2",			"HL2MPTypeDeath",	"2",	Color_Icon )
killicon.AddFont( "crossbow_bolt",		"HL2MPTypeDeath",	"1",	Color_Icon )
killicon.AddFont( "weapon_shotgun",		"HL2MPTypeDeath",	"0",	Color_Icon )
killicon.AddFont( "rpg_missile",		"HL2MPTypeDeath",	"3",	Color_Icon )
killicon.AddFont( "npc_grenade_frag",	"HL2MPTypeDeath",	"4",	Color_Icon )
killicon.AddFont( "weapon_pistol",		"HL2MPTypeDeath",	"-",	Color_Icon )
killicon.AddFont( "prop_combine_ball",	"HL2MPTypeDeath",	"8",	Color_Icon )
killicon.AddFont( "grenade_ar2",		"HL2MPTypeDeath",	"7",	Color_Icon )
killicon.AddFont( "weapon_stunstick",	"HL2MPTypeDeath",	"!",	Color_Icon )
killicon.AddFont( "npc_satchel",		"HL2MPTypeDeath",	"*",	Color_Icon )
killicon.AddFont( "npc_tripmine",		"HL2MPTypeDeath",	"*",	Color_Icon )
killicon.AddFont( "weapon_crowbar",		"HL2MPTypeDeath",	"6",	Color_Icon )
killicon.AddFont( "weapon_physcannon",	"HL2MPTypeDeath",	",",	Color_Icon )
--]]

-- Death table, written into by AddDeathNotice and read out by DrawDeathNotice
local Deaths = {}

local KillEventScore = { 
	time = 0,	-- Time
	k = 0,
	--tw = "",	-- Weapon
	ts = 200,	-- Score
	--tb = "",	--
	--text = "",	--
	sflag = true, -- Active flag
	f = 0	-- Active flag
}
local KillEventNotice = {
}
local function PlayerIDOrNameToString( var )
	print("[cl_deathnotice.lua] PlayerIDOrNameToString")
	if ( type( var ) == "string" ) then
		if ( var == "" ) then return "" end
		return "#" .. var
	end
	local ply = Entity( var )
	if ( !IsValid( ply ) ) then return "NULL!" end
	return ply:Name()
end

function DrawSimpleText(x, y, text)
	local len = surface.GetTextSize(text);
	draw.SimpleText( text,
		"ChatFont",
		x /2 - len /2,
		y / 2,
		Color( 255, 0, 0, 0 ),
		TEXT_ALIGN_RIGHT
	 )
end

local function RecvPlayerKilled_Feed()
	print("[cl_deathnotice.lua: RecvPlayerKilled_Feed] -->")
	local FLAGS = net.ReadInt(8)
	local feed = net.ReadInt(8)
	-- If flags is CONST_FLAG_KILLTABLE_FULL then we'll take the table and print it'
	if ( FLAGS == 6 ) then --assist flag
		local dmg = net.ReadInt(8)
		print("ASSIST dmg: ", dmg)

		POST_PROCESS_ADD(10, 0, 5, CurTime() + 0.5)

		local Notice = {}
		Notice.time = CurTime()
		Notice.tw = ""
		Notice.ts = dmg
		Notice.tb = "ASSIST"
		Notice.text = "[ASSIST] " .. dmg  .. " " --.. tag
		table.insert( KillEventNotice, Notice )

	elseif(FLAGS == 3) then
		local wtable = net.ReadTable()
		print("KILL TABLE: " .. table.Count(wtable))
		PrintTable(wtable)
		
		local Notice = {}
		Notice.time = CurTime()
		--Notice.fflag = true 
		

		if ( wtable.t == CONST_NET_KILL_HEADSHOT ) then
			--POST_PROCESS_ADD(7, 0, 10, CurTime() + 0.2)
			POST_PROCESS_ADD(10, 0, 10, CurTime() + 0.2)

			POST_PROCESS_ADD(11, 0, 10, CurTime() + 2)
			surface.PlaySound("headshot.mp3")
		else
			POST_PROCESS_ADD(10, 0, 5, CurTime() + 0.5)
		end

		if (feed == 1) then
			KillEventScore.df = true
			KillEventScore.ts = KillEventScore.ts + wtable.s
			KillEventScore.k = 	KillEventScore.k + 1
			KillEventScore.tb =  10 * KillEventScore.k

		else
			KillEventScore.df = false
			KillEventScore.ts = wtable.s
			KillEventScore.k = 1
			KillEventScore.tb = 0
			-- Clear table for new scores
			KillEventNotice = {}
		end
		
		--POST_PROCESS_ADD(10, 0, 5, CurTime() + 0.)
		--Notice.tw = "[" .. wtable.i .. "]" 
		--Notice.ts = wtable.s
		--Notice.tb = ((wtable.t == 1) and " HEADSHOT" or "")
		-- Some bug here
		Notice.text = GetHitGroupDisplayString(wtable.t) .. " [" .. GetWeaponName(wtable.i) .. "] " .. wtable.n .. " " .. wtable.s

		--((wtable.t == 1) and "[HEADSHOT] " or "") .. "[" .. wtable.i .. "] " .. wtable.s
		--.." DEBUG[" .. wtable.ts .. "]"
		Notice.color1 = Color_Icon

		print("Notice: ", Notice.text)
		table.insert( KillEventNotice, Notice )
	end

end
net.Receive( "PlayerKill_Feed", RecvPlayerKilled_Feed )

local function RecvPlayerKilledByPlayer()
	print("[cl_deathnotice.lua: RecvPlayerKilledByPlayer] -->")

	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()
	local kills = net.ReadInt(8)
	local flag =  net.ReadInt(8)

	--local FLAGS = net.ReadInt(8)

	-- If flags is CONST_FLAG_KILLTABLE_FULL then we'll take the table and print it'
	--if(FLAGS == 1) then
	--	local wtable = net.ReadTable()
	--	print("Got table: " .. table.Count(wtable))
	--	PrintTable(wtable)
	--end

	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end

	print("Attacker_team (" .. attacker:Team() .. ")")
	print("Victim_team (" .. victim:Team() .. ")")
	
	--PrintTable(attacker)
	--PrintTable(victim)

	--PrintTable(attacker:GetTable())
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team(), flag, k)
end
net.Receive( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )

local function RecvPlayerKilledSelf()
	print("[cl_deathnotice.lua: RecvPlayerKilledSelf] -->")

	local victim = net.ReadEntity()
	if ( !IsValid( victim ) ) then return end

	print("Victim_team (" .. victim:Team() .. ")")

	GAMEMODE:AddDeathNotice( nil, CONST_NO_TEAM, "suicide", victim:Name(), victim:Team(), 0, 0 )

end
net.Receive( "PlayerKilledSelf", RecvPlayerKilledSelf )

local function RecvPlayerKilled()
	print("[cl_deathnotice.lua: RecvPlayerKilled]")

	local victim	= net.ReadEntity()
	if ( !IsValid( victim ) ) then return end
	local inflictor	= net.ReadString()
	local attacker	= "#" .. net.ReadString()

	print(victim)
	print(inflictor)

	GAMEMODE:AddDeathNotice( attacker, CONST_NO_TEAM, inflictor, victim:Name(), victim:Team(), 0, 0)

end
net.Receive( "PlayerKilled", RecvPlayerKilled )

local function RecvPlayerKilledNPC()
	print("[cl_deathnotice.lua: PlayerKilledNPC]")

	local victimtype = net.ReadString()
	local victim	= "#" .. victimtype

	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	--local infent = ents.FindByName(inflictor)
	--print("Name: " .. infent:GetPrintName())
	--print("Victime: " .. victim)
	--print("Victime type: " .. victimtype)
	--
	-- For some reason the killer isn't known to us, so don't proceed.
	--

	if ( !IsValid( attacker ) ) then return end

	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1, 0, 0)

	local bIsLocalPlayer = ( IsValid(attacker) && attacker == LocalPlayer() )

	local bIsEnemy = IsEnemyEntityName( victimtype )
	local bIsFriend = IsFriendEntityName( victimtype )

	if ( bIsLocalPlayer && bIsEnemy ) then
		achievements.IncBaddies()
	end

	if ( bIsLocalPlayer && bIsFriend ) then
		achievements.IncGoodies()
	end

	if ( bIsLocalPlayer && ( !bIsFriend && !bIsEnemy ) ) then
		achievements.IncBystander()
	end

end
net.Receive( "PlayerKilledNPC", RecvPlayerKilledNPC )

local function RecvNPCKilledNPC()
	print("[cl_deathnotice.lua: RecvNPCKilledNPC")
	local victim	= "#" .. net.ReadString()
	local inflictor	= net.ReadString()
	local attacker	= "#" .. net.ReadString()

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1, 0, 0)

end
net.Receive( "NPCKilledNPC", RecvNPCKilledNPC )

--[[---------------------------------------------------------
   Name: gamemode:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2 )
   Desc: Adds an death notice entry

   Some weird bugs with this, was causing lua errors on fall suicide, fixed the errors, but it still needs work
   will possibly rewrite sometime
-----------------------------------------------------------]]

CONST_STR_LINEPAD_OPEN = " ["
CONST_STR_CONST_LINEPAD_CLOSE = "] "
CONST_INT_FEED_PAD = 16
function GetTeamName(int_id)
	--if ( int_team == -1 ) then
	--	return "[GetTeamName: Unknown team inflictor]: Very lazy and cheeky hack to stop crash -> pls fix this"
	-- end

	--[[
			print("Team: " .. int_team)                      Had a go at fixing this, doesn't bring up an error
			return CONST_STR_LINEPAD_OPEN
			.. team.GetName(
			Entity( int_team ) : Team()                      I think the problem is Entity(team), Entity() gets the ent with that id
			) .. CONST_STR_CONST_LINEPAD_CLOSE               so for an unassigned team it was trying to get entity 1001, which didn't exist
		]]

	if(int_id > 0 and int_id < 1001 and team.Valid(int_id)) then	--check if team isn't subscriber and also exists
	return CONST_STR_LINEPAD_OPEN
		.. team.GetName(int_id) ..																	--returns [teamname]

		CONST_STR_CONST_LINEPAD_CLOSE
	else
		return CONST_STR_LINEPAD_OPEN
			.. "¯\\_(ツ)_/¯" ..																				--returns [placeholder]
			CONST_STR_CONST_LINEPAD_CLOSE
	end
end

function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2, HIT_FLAGS, KILL_COUNT)
	print("[cl_deathnotice.lua] GM:AddDeathNotice")
	--print("Inflictor: " .. Inflictor)

	-- Todo: Fix bugs, for some reason, the team name can invalid
	-- Unfixed, pretty serious

	local Death = {}
	Death.time		= CurTime()

	-- In dev-version, concatanate the team and attacker name, also add weapon entery
	print("> Death notice -------")
	print("Attacker: ", Attacker)
	print("Team1: ", team1)
	print("Inflictor: ", Inflictor)
	print("Victim: ", Victim)
	print("Team2: ", team2)


	-- Inflictor string colour	
	Death.color3 =  Color( 250, 255, 50, 255 )

	-- If the attacker is nll, then it's suicide Jim'
	if ( Attacker != nil

		--Check if the string has been sent with the # tag @ 0, if so, we'll ignore it'
		and string.sub(Attacker, 1,1) != '#') then

		--Death.left = if ( team1 < 0 ) then "" else GetTeamName(team1) end
		--if (string.sub(Attacker, 1,1) == '#') then
		--	Death.left = ""
		--else

		if (team1 != -1) then -- Check if we have a team, if not, don't append team flag'
			Death.left	= GetTeamName(team1) .. Attacker .. ": "-- .. "(" ..KILL_COUNT .. ")"
			Death.color1 = table.Copy( team.GetColor( team1 ) )
		else
			Death.left	= (FLAG_DISPLAY_NOTEAM_HINT) and "[No Team] " .. Attacker or Attacker --.. "(" ..KILL_COUNT .. ")"
			Death.color1 = Color(222, 147, 95, 255)--table.Copy( NPC_Color )
		end
	end
	if ( team2 == -1 ) then
		Death.right	= Victim
		Death.color2 = table.Copy( NPC_Color )
	else
		print(team2)
		Death.right	= GetTeamName(team2) .. Victim
		Death.color2 = table.Copy( team.GetColor( team2 ) )
	end

	--Death.right = (( team2 < 0 ) and "" or GetTeamName(team2)) .. Victim
	-- See if the attacking ent exists in the weapon table

	local inf_ent = weapons.Get(Inflictor)
	if ( inf_ent != nil ) then
		-- Was found in ent table, then we get the sent name
		-- TODO: Sent name might be null?
		print("[AddDeathNotice: Inflictor exists as ent] Inflictor name: ", inf_ent.PrintName)

		-- Add row to hold the inflictor
		Death.att_inflictor = CONST_STR_LINEPAD_OPEN ..  inf_ent.PrintName .. CONST_STR_CONST_LINEPAD_CLOSE --.. "--> [" .. HIT_FLAGS .."]"
	else
		-- Could't find the ent in the table, just dump the name :('
		print("[AddDeathNotice: Inflictor is null weapon] Inflictor name: ", Inflictor)

		-- Another cheeky formatting bit, to make it pretty, rewrite Inflictor if it's "world" into "gravity"'
		if ( Inflictor == "worldspawn" ) then
			Inflictor = "Gravity"
		-- Funny-
		--elseif ( Inflictor == "suicide" ) then
		--	Inflictor = "sudoku"
		end
		Death.att_inflictor = CONST_STR_LINEPAD_OPEN .. Inflictor .. CONST_STR_CONST_LINEPAD_CLOSE -- .. "--> [" .. HIT_FLAGS .."]"
	end


	-- Removed the icon calls, so no need to add it to the table
	-- Death.icon		= Inflictor
	-- Not removed this bit yet, unsure if I need to
	--if ( team1 == -1 ) then Death.color1 = table.Copy( NPC_Color )
	--else Death.color1 = table.Copy( team.GetColor( team1 ) ) end
	
	--if ( team2 == -1 ) then Death.color2 = table.Copy( NPC_Color )
	--else Death.color2 = table.Copy( team.GetColor( team2 ) ) end

	--if (Death.left == Death.right) then
	--	Death.left = nil
		--Death.icon = "suicide"
	--end

	table.insert( Deaths, Death )

end

local function DrawDeath( x, y, death, hud_deathnotice_time )
	local b_draw_icon = false

	--local w, h = killicon.GetSize( death.icon )
	--if ( !w || !h ) then return end

	local fadeout = ( death.time + hud_deathnotice_time ) - CurTime()

	local alpha = math.Clamp( fadeout * 255, 0, 255 )

	--death.color2.a = alpha
	--death.color1.a = alpha

	local first
	local second
	local padding = 20

	--if(death.fflag != nil) then
		--local p = 0.5 + math.sin(SysTime()) * 0.8;
		--print("Drawing middle text: @" .. "(" .. x .. ") (" .. y .. ")")
	--	local len = surface.GetTextSize(death.text);

	--	draw.SimpleTextOutlined(
	--		death.text, "Trebuchet24",--"HL2MPTypeDeath",--"DermaLarge",

	--		x /2 + len /2,
	--		ScrH() / 4 * 3,

	--		Color( 95, 129, 157, 255), TEXT_ALIGN_RIGHT, 0,
	--		0, Color( 255, 255, 255, 128 )
	--		)
	--	return ( y + CONST_INT_FEED_PAD - 2 * 0.70 )
	--end

	--print("INFLICTOR: " .. death.att_inflictor)
	--print("VICTIM: " .. death.right)

	--if ( b_draw_icon ) then
	-- Draw Icon
	--killicon.Draw( x, y, death.icon, alpha )

	first = surface.GetTextSize(death.right);

	-- Draw VICTIM, get length of text when using this font
	draw.SimpleText( death.right,		"ChatFont", x - padding, y, death.color2, TEXT_ALIGN_RIGHT )
	first = surface.GetTextSize(death.right);

	-- Pad it to the left screen_width - previous_string - padding

	if ( death.att_inflictor ) then 

		death.color2.a = alpha
		draw.SimpleText( death.att_inflictor, "ChatFont",
		 x - padding - first, y, death.color3, TEXT_ALIGN_RIGHT )

		second = surface.GetTextSize(death.att_inflictor);
	end

	-- Draw KILLER: Pad it to the left screen_width - padding
	if ( death.left ) then
		death.color1.a = alpha
		draw.SimpleText( death.left, "ChatFont",
		 x - padding - first - second, y, death.color1, TEXT_ALIGN_RIGHT )

		--draw.SimpleText( death.left,	"ChatFont", x - ( w / 2 ) - 16, y, death.color1, TEXT_ALIGN_RIGHT )
		--draw.SimpleText( death.att_inflictor,	"ChatFont", x - ( w / 2 ) - 18, y, death.color3, TEXT_ALIGN_RIGHT )
	end

	-- Draw VICTIM
	--draw.SimpleText( death.right,		"ChatFont", x + ( w / 2 ) + 16, y, death.color2, TEXT_ALIGN_LEFT )

	-- Return y + row height * 0.70 to lerp caller
	return ( y + CONST_INT_FEED_PAD - 2 * 0.70 )

end

local function DrawEventNotice( x, y, event, hud_deathnotice_time )
	local fadeout = ( event.time + hud_deathnotice_time ) - CurTime()
	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	local off = (x / 2)
	

	if(event.sflag) then
		local tslen = surface.GetTextSize(event.ts)
		draw.SimpleText( event.ts, --.. "(x" .. event.k .. " + " .. event.tb .. ")", 
		"HudScoreFont",
		 off + ScrW() / 15 + tslen,
		 y - 20 + (y/15),
		 Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER )
	else
		draw.SimpleTextOutlined(
			event.text, 
			--"Trebuchet",
			"HudScoreFont",  
			off, 
			y + (y/15),
			Color( 255, 255, 255, alpha ), 
			TEXT_ALIGN_CENTER, 
			TEXT_ALIGN_TOP, 
			0, 
			Color( 0, 0, 0, alpha ) 
		)
		--draw.SimpleText( event.text, "HudScoreFont", off, y,Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER )
	end
	return ( y + CONST_INT_FEED_PAD + 6 - 2 * 0.70 )
end


function GM:DrawKillNotice(x, y)
	--print("DrawKillNotice")
	--print("Timer: ", hud_deathnotice_time)

	local hud_deathnotice_time = hud_deathnotice_time:GetFloat() * 1
	y = ScrH() - ScrH() /3
	x = ScrW()
	
	--x = ScrW() / 2
	--DOF_Start()

	if ( KillEventScore.df == true ) then
		DrawEventNotice( x , y, KillEventScore, hud_deathnotice_time )
	end
	--PrintTable(KillEventNotice)
	for k, Event in pairs( KillEventNotice ) do
		--print("(" .. k .. ") Kill pair->")
		if ( Event.time + hud_deathnotice_time > CurTime() ) then
			if ( Event.lerp ) then
				--x = x * 0.3 + Event.lerp.x * 0.7
				y = y * 0.3 + Event.lerp.y * 0.7
				--print("----->\n\tX: ", Death.lerp.x)
				--print("\tX adder: ", x)
				--print("\tY adder: ", y)
			else 
				--print("New event, no lerp movement")
			end

			Event.lerp = Event.lerp or {}
			Event.lerp.x = x
			Event.lerp.y = y
			y = DrawEventNotice( x , y, Event, hud_deathnotice_time )
		end
	end

	for k, Event in pairs( KillEventNotice ) do
		if ( Event.time + hud_deathnotice_time > CurTime() ) then
			return
		end
	end

	KillEventScore.df = false
	KillEventNotice = {}
	--DOF_Kill()
end


function GM:DrawDeathNotice( x, y )
	--print(" GM:DrawDeathNotice( x, y )", x, y)
	--if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end

	local hud_deathnotice_time = hud_deathnotice_time:GetFloat() * 1.5;

	x = x * ScrW()
	y = y * ScrH()

	-- Draw
	for k, Death in pairs( Deaths ) do
		--print("(" .. k .. ")Pair->")
		if ( Death.time + hud_deathnotice_time > CurTime() ) then
			
			if ( Death.lerp ) then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
				--print("----->\n\tX: ", Death.lerp.x)
				--print("\tY: ", Death.lerp.y)
			end

			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y

			y = DrawDeath( x , y, Death, hud_deathnotice_time )

		end

	end

	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for k, Death in pairs( Deaths ) do
		if ( Death.time + hud_deathnotice_time > CurTime() 
		
		) then
			return
		end
	end

	--if(KillEventScore.time + 4 >  CurTime()) then
	--	return
	--end

	Deaths = {}

end
