-- Manages the killfeed, twiddled with to change the killfeed to be slightly more descriptive
--RUNTIME_LOG("ENTERED cl_deathnotice")
AddCSLuaFile()

print("[Runtime_entered] cl_deathnotice.lua");

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

local function PlayerIDOrNameToString( var )

	if ( type( var ) == "string" ) then
		if ( var == "" ) then return "" end
		return "#" .. var
	end
	
	local ply = Entity( var )
	
	if ( !IsValid( ply ) ) then return "NULL!" end
	
	return ply:Name()

end


local function RecvPlayerKilledByPlayer()
	print("[cl_deathnotice.lua: RecvPlayerKilledByPlayer]")

	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()


	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end
	
	print(attacker)
	
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team() )

end
net.Receive( "PlayerKilledByPlayer", RecvPlayerKilledByPlayer )

local function RecvPlayerKilledSelf()
	print("[cl_deathnotice.lua: RecvPlayerKilledSelf]")

	local victim = net.ReadEntity()
	if ( !IsValid( victim ) ) then return end
	GAMEMODE:AddDeathNotice( nil, 0, "suicide", victim:Name(), victim:Team() )

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

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim:Name(), victim:Team() )

end
net.Receive( "PlayerKilled", RecvPlayerKilled )

local function RecvPlayerKilledNPC()
	print("[cl_deathnotice.lua: PlayerKilledNPC]")

	local victimtype = net.ReadString()
	local victim	= "#" .. victimtype

	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	local infent = ents.FindByName(inflictor)

	print("Name: " .. infent:GetPrintName())
	
	print("Victime: " .. victim)
	print("Victime type: " .. victimtype)
	--
	-- For some reason the killer isn't known to us, so don't proceed.
	--
	if ( !IsValid( attacker ) ) then return end
	
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), inflictor, victim, -1 )
	
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

	GAMEMODE:AddDeathNotice( attacker, -1, inflictor, victim, -1 )

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
function GetTeamName(int_team)
	if ( int_team == -1 ) then
		return "[GetTeamName: Unknown team inflictor]: Very lazy and cheeky hack to stop crash -> pls fix this"
	end
	print("Team: " .. int_team)
	return CONST_STR_LINEPAD_OPEN 
		.. team.GetName( 
			Entity( int_team ) : Team()
		) .. 
		CONST_STR_CONST_LINEPAD_CLOSE
end

function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2 )
	print("[cl_deathnotice.lua] GM:AddDeathNotice")
	--print("Inflictor: " .. Inflictor)

	-- Todo: Fix bugs, for some reason, the team name can invalid
	-- Unfixed, pretty serious

	local Death = {}
	Death.time		= CurTime()

	--print("-------")
	--print(Attacker)
	--print(Inflictor)
	--print(Victim)

	-- In dev-version, concatanate the team and attacker name, also add weapon entery

	-- Inflictor string colour
	Death.color3 =  Color( 250, 255, 50, 255 )

	-- If the attacker is nll, then it's suicide Jim'
	if ( Attacker != nil ) then
		Death.left	= GetTeamName(team1) .. Attacker .. ": "
	end

	-- See if the attacking ent exists in the weapon table
	local inf_ent = weapons.Get(Inflictor)
	if ( inf_ent != nil ) then
		-- Was found in ent table, then we get the sent name

		-- TODO: Sent name might be null?
		print("[AddDeathNotice: Inflictor exists as ent] Inflictor name: ", inf_ent.PrintName)

		-- Add row to hold the inflictor
		Death.att_inflictor =  CONST_STR_LINEPAD_OPEN ..  inf_ent.PrintName .. CONST_STR_CONST_LINEPAD_CLOSE
	else 
		-- Could't find the ent in the table, just dump the name :('
		print("[AddDeathNotice: Inflictor is null] Inflictor name: ", Inflictor)

		-- Another cheeky formatting bit, to make it pretty, rewrite Inflictor if it's "world" into "gravity"'
		if ( Inflictor == "worldspawn" ) then
			Inflictor = "Gravity"

		-- Funny-
		--elseif ( Inflictor == "suicide" ) then
		--	Inflictor = "sudoku"
		end
			 
		Death.att_inflictor =  CONST_STR_LINEPAD_OPEN .. Inflictor .. CONST_STR_CONST_LINEPAD_CLOSE
	end

	Death.right		= GetTeamName(team2) .. Victim

	-- Removed the icon calls, so no need to add it to the table
	-- Death.icon		= Inflictor


	-- Not removed this bit yet, unsure if I need to
	if ( team1 == -1 ) then Death.color1 = table.Copy( NPC_Color )
	else Death.color1 = table.Copy( team.GetColor( team1 ) ) end
	
	if ( team2 == -1 ) then Death.color2 = table.Copy( NPC_Color )
	else Death.color2 = table.Copy( team.GetColor( team2 ) ) end
	
	if (Death.left == Death.right) then
		Death.left = nil
		--Death.icon = "suicide"
	end
	
	table.insert( Deaths, Death )

end

local function DrawDeath( x, y, death, hud_deathnotice_time )
	local b_draw_icon = false

	--local w, h = killicon.GetSize( death.icon )
	--if ( !w || !h ) then return end
	
	local fadeout = ( death.time + hud_deathnotice_time ) - CurTime()
	
	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	death.color1.a = alpha
	death.color2.a = alpha


	local first 
	local second
	local padding = 20
	--if ( b_draw_icon ) then 
	-- Draw Icon
	--killicon.Draw( x, y, death.icon, alpha )
	
	-- Draw KILLER

	
	-- Draw VICTIM, get length of text when using this font
	first = surface.GetTextSize(death.right);
	-- Pad it to the left screen_width - padding
	draw.SimpleText( death.right,		"ChatFont", x - padding, y, death.color2, TEXT_ALIGN_RIGHT )
	first = surface.GetTextSize(death.right);

	-- Pad it to the left screen_width - previous_string - padding
	if ( death.att_inflictor ) then 
		draw.SimpleText( death.att_inflictor, "ChatFont",
		 x - padding - first, y, death.color3, TEXT_ALIGN_RIGHT )

		second = surface.GetTextSize(death.att_inflictor);
	end
	if ( death.left ) then
		draw.SimpleText( death.left, "ChatFont",
		 x - padding - first - second, y, death.color1, TEXT_ALIGN_RIGHT )
		 --draw.SimpleText( death.left,	"ChatFont", x - ( w / 2 ) - 16, y, death.color1, TEXT_ALIGN_RIGHT )
		--draw.SimpleText( death.att_inflictor,	"ChatFont", x - ( w / 2 ) - 18, y, death.color3, TEXT_ALIGN_RIGHT )
	end

	-- Draw VICTIM
	--draw.SimpleText( death.right,		"ChatFont", x + ( w / 2 ) + 16, y, death.color2, TEXT_ALIGN_LEFT )
	--end

	-- Return x + row height * 0.70 to lerp caller
	return ( y + 32 * 0.70 )

end


function GM:DrawDeathNotice( x, y )

	if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end

	local hud_deathnotice_time = hud_deathnotice_time:GetFloat() * 1.5;

	x = x * ScrW()
	y = y * ScrH()

	-- Draw
	for k, Death in pairs( Deaths ) do
		if ( Death.time + hud_deathnotice_time > CurTime() ) then
	
			if ( Death.lerp ) then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
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
		if ( Death.time + hud_deathnotice_time > CurTime() ) then
			return
		end
	end
	
	Deaths = {}

end
