print("ENTERED game.lua")
AddCSLuaFile()
--include ("func.lua")
--include('sound.lua')

DEBUG_VERBOSE = false
-- 13
CONST_STR_WEAPON_LIST = {
	"fas2_ak47",
	"fas2_ak74",
	"fas2_g3",
	"fas2_glock20",
	"fas2_m3s90",
	"fas2_m24",
	"fas2_mp5a5",
	"fas2_pp19",
	"fas2_ragingbull",
	"fas2_rk95",
	"fas2_rpk",
	"fas2_sg552",
	"fas2_sks",



	"fas2_mac11",
	"fas2_mp5k",
	"fas2_mp5sd6",
	"fas2_uzi",


	"fas2_famas",
	"fas2_g36c",
	"fas2_m4a1",
	"fas2_m14",
	"fas2_m21",
	"fas2_m82",
	"fas2_sg550",
	"fas2_sr25",


	"fas2_deagle",
	"fas2_m1911",
	"fas2_ots33",
	"fas2_p226",


	"fas2_ks23",
	"fas2_rem870"

}

CONST_INT_GUNGAME_MAX_KILLS = 28
CONST_STR_GUNGAME_WEAPON_LIST = {
	"fas2_ak47",
	"fas2_sterling",
	"fas2_ak74",
	"fas2_rpk",
	"fas2_sg550",

	"fas2_rk95",
	"fas2_famas",

	"fas2_ak12",
	"fas2_g3",

	"fas2_sks",
	"fas2_m14",
	"fas2_m21",
	"fas2_sr25",

	"fas2_pp19",
	"fas2_mp5k",
	"fas2_uzi",
	"fas2_mac11",

	"fas2_ks23",
	"fas2_rem870",
	"fas2_m3s90",

	"fas2_p226",
	"fas2_p227",

	"fas2_m1911a",
	"fas2_glock20",
	"fas2_glock18",

	--"fas2_m79",
	"fas2_m82",

	"fas2_deagle",
	"fas2_deagle_a", -- 28

	"fas2_machete"
}
CONST_STR_GAMEMODE_LIST = {
	"UNREGISTERED",	-- Unregistered, defaults to deathmatch
	"DEATHMATCH",	-- Deathmatch, requires combine and rebel spawns, teams will compete for the kill limit
	"TEAM Deathmatch",
	"RUSH",			-- Rush in, requires maps with objective areas
	"DEFUSAL",		-- Bomb defusal, see: Counterstrike
	"KNOCK-KNOCK",	-- Bang Bang, 1 life, two teams
	"GUNGAME",		-- First to get a kill with all guns
	"CUSTOM"		-- Load custom from file
}

FLAG_GAME_STATE_RELOAD = true
CONST_INT_PREGAME_TIME = 10 --seconds
CONST_INT_POSTGAME_TIME = 5 -- seconds

-- Enum of built in gamemodes, choose other if it's a custom ruleset'
CONST_INT_GAMEMODE_ENUM = {
	UNREGISTERED = 0,
	DEATHMATCH = 1,
	TDM = 2,
	RUSH = 3,
	DEFUSAL = 4,
	ctr = 5,
	GUNGAME = 6,
	CUSTOM = 7,
}

CONST_INT_MINEFIELD_WEIGHT = {
	0,		-- On target 1/10
	1,
	2, 2,
	3, 3,	-- 2/10
	4, 4, 4,	-- 3/10
	5, 5, 5, 5,
	6, 6, 6 -- 4/10
}

math.randomseed(os.time())

function MinefieldPickOffset()

	INT_MAX = 16
	INT_MIN = 1

	range = 16

	--range = INT_MAX - INT_MIN

	--% range + min;

	--rnd =
	local rnd = math.random(1, 16)
	--local mod = math.floor(math.mod(rnd, 100))
	--, range + INT_MIN)

	print("rnd: ", rnd)
	return CONST_INT_MINEFIELD_WEIGHT[rnd]

	/*local sum_of_weight = 0

	local i = 0
	for i= 1, 15, i+1 do
		sum_of_weight = sum_of_weight + CONST_INT_MINEFIELD_WEIGHT[i]
	end
	print("\tWeight sum: " .. sum_of_weight)
	rnd = math.random(sum_of_weight)
	print("rnd: " .. rnd)
	for i = 1, 16, i+1 do
		if(rnd < CONST_INT_MINEFIELD_WEIGHT[i]) then
			print("Return: " .. i)
			return i
		end
		rnd = rnd - CONST_INT_MINEFIELD_WEIGHT[i]
	end*/
end


CONST_INT_GAME_TIME = {
	0, -- Undefined, timer is not started
	30,--30,
	60 * 10,
	60
}

CONST_INT_GAME_STATE = {
	WAIT =	 0, -- "We init to WAIT_PRE_GAME we must switch to PRE OR PLAY to start"
	PRE		= 1,
	PLAY	= 2,  -- Game is in progress, the typical state
	POST	= 3, -- Post game, pause players, animate outtro and show pick gamemode stuff

	-- I don't think these should be typically used, they're an exception
	CHANGE	= 4, -- Ovverriden to change gamemode, game is paused and gamemode is reloaded, eg, new map and mode
	PAUSE	= 5  -- Freeze game, pause all players, timers, stop input and physics, to unpause, change to PLAY
}

CONST_STR_GAME_STATE = {
	"GAME_WAIT",		-- No damage
	"GAME_PREGAME",		-- Countdown timer is started
	"GAME_IN_PROGRESS",	-- Game is playing
	"GAME_POSTGAME",
	"GAME_PAUSED",
	"GAME_CHANGE"
}

int_gamestate = 0

-- GAME_PAUSE (boolean 1)
--	1- Pause or unpause
CONST_DEFAULT_ROUND_TIME = 60 * 10 --Sixty seconds * 10 = 600/six mins
INT_TIMER_FLAG = false

INT_TIME_START = 0
INTERNAL_MAP_HAS_POINTCAMERA = false
CONST_INT_DEFAULT_FOV = 110

CONST_INT_DMG_SCALE_HEADSHOT = 2
CONST_INT_DMG_SCALE_BODY = 1

CONST_GAME_WIN_CONDITION_FLAGS = {
	ALL_DEAD		= 0x1,
	ALL_ALIVE		= 0x2,
	GLOBAL_KILL_LIMIT = 0x100,
	TEAM_SCORE_LIMIT = 0x4,
	TEAM_KILL_LIMIT	 = 0x8,
	SQUAD_SCORE_LIMIT = 0x10,
	SQUAD_KILL_LIMIT = 0x12,
}

CONST_GAME_KILLSTREAK_MODIFIER = {

}

CONST_PLAYER_HIT_CLIP = {
	NONE = -1,
	ALL		 = 0,
	HEAD	= 0x1,
	CHEST	= 0x2,
	STOMACH = 0x4,
}
-- We use this value to call the GAME_CHANGE_STATE when the round is finished
int_timer_change = 0
int_timer_base = 0
float_timer_ltime = 0
float_timer_time = 0
float_timer_target = 0
float_timescale_timer = 0
float_timer_schedule = 0

-- Timers for Z-Time
int_timescale = 0		-- Factor of the timescale, 1 is full speed, 0.4 is 40%
CONST_INT_SLOWTIME_SCALE = 0.4	-- Default scale for Z-Time
CONST_INT_SLOWTIME_TIME = 1.5	-- Default timer for Z-Time

CONST_VEC_COLOR_1 = Color(180, 255, 0)
-- GLOBAL OBJECT

GAME = {}

GAME.flags = {
	state = {
		GameType = 0,
		GAME_KILL_LIMIT = 100,
		GAME_WIN_CONDITIONS = CONST_GAME_WIN_CONDITION_FLAGS.ALL_DEAD, --| CONST_GAME_WIN_CONDITION_FLAGS.GLOBAL_KILL_LIMIT,
		TEAMS_ALLOWED = true,
		SQUADS_ALLOWED = true,
	},
	game = {
		PlayerJumpMultiplier = 3,					-- Force multiplier for jumping
		PlayerHitClip = CONST_PLAYER_HIT_CLIP.ALL,	-- 0 NO CLIP If set to specific flags, will ignore all hits apart from set flags
		PlayerHitClipBonusMultiplier = 0,			-- Score multiplier, eh
		PlayerLifeRange = 1,						-- 0 unlimited, number of lives before perma dead

		weapon = {
			ExplosiveBullets = false,
			FireBullets = false,

			-- Explode on hit flag
			ExplosiveDismemberClip = CONST_PLAYER_HIT_CLIP.NONE,
			killseries_mod = {
				NONE = 0
			}
		}
	},

	--interact ={}
	PLAYER_CAN_KILL = true,
	PLAYER_VEHICLE_CAN_THIRDPERSON = true, -- Enable or disable third person in vehicles
	PLAYER_CAN_SPRAY = false,			-- Player can spray textures
	PLAYER_CAN_PICKUP_KENTER = false,

	PLAYER_PICKUP_FREEZE = false,		-- Pick up weapons freeze, doesn't seem to work correctly
	PLAYER_CAN_SWITCH_WEAPON = true,	-- Player can switch weapons
	PLAYER_CAN_PICKUP_WEAPON = false,
	PLAYER_CAN_DROP_WEAPON = false,
	PLAYER_CAN_SUICIDE = true,			-- Player can kill themselves with 'kill' command

	PLAYER_VEHICLE_CAN_EXIT = false,	-- Player can exit vehicle
	PLAYER_VEHICLE_CAN_ENTER = false	-- Not used
}

GAME_SERIAL = {}
function SerializeStateTable()
	GAME_SERIAL = {}
	print("++++ SERIALIZING GAME_TABLE ++++ ")

	GAME_SERIAL.state = GAME.flags.state
	GAME_SERIAL.str_gamename = ""

	for key,value in pairs(GAME.flags)
		do
			if(value != 0) then
				--GAME_SERIAL[]
			end
		print(key,value)
	end
end

function GAME:IsGameRunning()
	return ((int_gamestate == CONST_INT_GAME_STATE.PLAY) and true or false)
end
-- Schedule and display an event to all clients, to be run at XXX time, for example, a server soft restart or reboot, typically use this to manually reboot and notify all players
-- Warning, 0 is ignored
function GAME:ScheduleEvent(In_int_type, In_int_time)
	float_timer_schedule = CurTime() + float_timer_schedule

	print("Schedule set to: ", CurTime() + float_timer_schedule, float_timer_schedule)
end

function GAME:TimeScale(In_in_timer)
	--print(
    if(math.random(10) == 1) then
    	MsgC(CONST_VEC_COLOR_1, "GAME:TimeScale -> Started Z-Time: " .. ((float_timescale_timer > 0) and "[Extended]" or "[New]") .. "(" .. CurTime() - ( CurTime() + CONST_INT_SLOWTIME_TIME) .. ")\n")
    	int_timescale = CONST_INT_SLOWTIME_SCALE
    	game.SetTimeScale( int_timescale )
        timer.Simple(1 ,function()
            game.SetTimeScale(1)
    	end)
    	float_timescale_timer = CurTime() + CONST_INT_SLOWTIME_TIME
    end
end

function GAME:setup_ffile(char_file) end

function GAME:setup_tdm(int_teams, int_maxkill, int_maxtime) end

function GAME:setup_sdm(int_squad_count, int_maxkill, int_maxtime) end

function GAME:setup_conquest(int_ticketcount, int_maxtime) end

function GAME:setup_conquet(int_ticketcount, int_maxtime) end

function GAME:StartTime( )
	return INT_TIME_START
end

function GAME:Init()
	print("Game.lua INIT {")
	print("\tLoading convars")
	concommand.Add("game_state_print", PRINT_GAME_STATE)
	concommand.Add("game_change_state", GameConvar_SetGameState)
	concommand.Add("game_restart", GameConvar_Restart)
	--concommand.Add("game_set_gamemode", GAME.COM_SetGameMode)

	INT_TIME_START = CurTime()
	GAME:LOAD_SpawnTable()
	print("\t} ----> ok")
end

function GAME:HandlePlayer(ply)

end

function GAME:RespawnAll_Player()
	for k, v in pairs(player.GetAll()) do if( v:IsPlayer() ) then v:Spawn() end end
end

function GAME:RespawnAll_Bot()
	for k, v in pairs(player.GetAll()) do if( v:IsBot() ) then v:Spawn() end end
end

function GAME:KickAll_Bot()
	for k, v in pairs(player.GetAll()) do if( v:IsBot() ) then v:Kick() end end
end

function GameConvar_SetGameState(ply, cmd, args)
	local int_state = tonumber(args[1])
	print("GOT: ", int_state)
	GAME_CHANGE_STATE(int_state)
end

function GameConvar_Restart(ply, cmd, args)
	---local int_state = tonumber(args[1]) --ply, cmd, args
	--SET_GAME_TIMER_SEC(0)
	--print(int_gamestate)

	print("GAME_RESTART_WRAP Setting timer to: ", CONST_INT_GAME_TIME[CONST_INT_GAME_STATE.PRE])
	GAME:GAME_CHANGE_STATE(CONST_INT_GAME_STATE.PRE)
	GAME:SET_GAME_TIMER_SEC(CONST_INT_GAME_TIME[int_gamestate], int_gamestate)
end

local CONST_SPAWN_CLASS_STR = {
	"info_player_start",
	"info_player_deathmatch",
	"info_player_combine",
	"info_player_rebel",

	-- Counterstrike is pleb teir, I play Roblox
	"info_player_counterterrorist",
	"info_player_terrorist",

	-- Someone is lazy
	"gmod_player_start",

	-- Why the fuck are you loading a teamfortress 2 map
	"info_player_teamspawn",

	"info_player_axis", -- Go away
	"info_player_allies", -- Why

	-- OB Maps No, these are our team colours
	"info_player_red",
	"info_player_blue",

	-- Zombiemaster sucks
	"info_player_zombiemaster"
}

local SPAWN_TABLE = {}
function GAME:Logic_NewPlayer(ply)

end

function GAME:StartMinefield(Int_range_start, Int_range_end)
	print("GAME:TickMinefield`dbg_test_minefield")
	local int_pos = MinefieldPickOffset()
	local ply = player.GetAll()[1]



	print("Pos: ", int_pos)
	Vector(int_pos, int_pos, ply:GetPos().z)

	INT_POS_MULTIPLIER = 30

	--print("Twiddle: ",  Vector(int_pos * INT_POS_MULTIPLIER, int_pos * INT_POS_MULTIPLIER, int_pos * 1))
	--print("CurTime() - (CurTime() ", math.mod(CurTime(), 10))

	int_flip = math.mod(CurTime(), 2)

	-- flipper
	y_flip =  (int_flip < 1) and (bit.bnot(int_pos) + 1) or int_pos
	x_flip =  (int_flip > 1) and (bit.bnot(int_pos) + 1) or int_pos
	pos =  ply:GetPos() + Vector(x_flip * INT_POS_MULTIPLIER, y_flip * INT_POS_MULTIPLIER)
	print("X: " .. x_flip .. " Y: " .. y_flip)

	util.BlastDamage(game.GetWorld(), game.GetWorld(), pos, 250, 200)

	local explode = ents.Create( "env_explosion" )
	explode:SetKeyValue( "spawnflags", 2 + 16 );
	explode:SetPos( pos )

	--explode:SetOwner( ply )
	explode:Spawn()
	explode:SetKeyValue( "iMagnitude", "220" ) --the magnitude
	explode:Fire( "Explode", 0, 0 )
end

local MAP_ENTITY_TABLE = {

}

local CAMERA = nil
local INTERNAL_POINT_CAMERA = {
	ent_p_camera = nil,
	ent_target = nil,
	exists = false
}


function GAME:HAS_CAMERA()
	return INTERNAL_POINT_CAMERA.exists
end
function GAME:GenerateMapEntities(int_fov)
	local ents = ents.FindByClass("point_camera")

	if(ents != nil) then
		print("Found point_camera")
		if (!INTERNAL_POINT_CAMERA.exists) then
			INTERNAL_POINT_CAMERA.exists = true
		end

		CAMERA = ents[1]
		local ply = player.GetAll()

		CAMERA:PointAtEntity(ply[1])
		print("int_fov: ", int_fov)

		CAMERA:SetKeyValue( "fov", int_fov)

		--CAMERA = ent_pcam[1]
		--CAMERA:PointAtEntity(ply[1])


		--ent_pcam[2]:PointAtEntity(ply[1])
		--INTERNAL_POINT_CAMERA.ent_p_camera = ent_pcam[1]
		PrintTable(INTERNAL_POINT_CAMERA)
		--INTERNAL_POINT_CAMERA.ent_p_camera:

		--INTERNAL_POINT_CAMERA.ent_p_camera = ent_pcam[1]
		--INTERNAL_POINT_CAMERA.ent_target = ply[1]

		--print(CAMERA)
		--CAMERA:SetFov(40, 2)
		--print("DISTANCE: ", INTERNAL_POINT_CAMERA.ent_p_camera:GetPos():Distance(INTERNAL_POINT_CAMERA.ent_target:GetPos()))

		--INTERNAL_POINT_CAMERA.ent_p_camera:
		--ent_pcam[1]:SetKeyValue( "fov", "90" )
	end

	--local t = ents.FindByClass("bf_weapon_random")

	--for k, v in pairs(t) do
	--	PrintTable(Entity:GetTable())
	--end
end

function GAME:LOAD_SpawnTable()
	local int_tbllen = table.Count(CONST_SPAWN_CLASS_STR)
	print("[GAME:LoadSpawnTable] Attempting to load: ", int_tbllen)
	for k = 1, int_tbllen, 1 do
		--"\tInsert-> ",
		--print("\t -> Size: ", bufsz)
		local buf = ents.FindByClass( CONST_SPAWN_CLASS_STR[k] )
		local bufsz = table.Count(buf)
		print( "\t " .. CONST_SPAWN_CLASS_STR[k], bufsz )

		PrintTable(buf)
		table.insert( SPAWN_TABLE, buf)
	end

	int_tbllen = table.Count(CONST_SPAWN_CLASS_STR)
	print("[GAME:LoadSpawnTable] Table size: ", int_tbllen)

	PrintTable(SPAWN_TABLE)

		--table.insert( SPAWN_TABLE, ents.FindByClass( "info_player_start" ))
		--table.insert( SPAWN_TABLE, ents.FindByClass( "info_player_deathmatch" ) )
		--table.insert( SPAWN_TABLE, ents.FindByClass( "info_player_combine" ) )
		--table.insert( SPAWN_TABLE, ents.FindByClass( "info_player_rebel" ) )

		-- CS Maps
		--print("Insert -> ")
		--table.insert( SPAWN_TABLE, ents.FindByClass( "info_player_counterterrorist" ) )
		--table.insert( SPAWN_TABLE, ents.FindByClass( "info_player_terrorist" ) )
end
function GAME:SET_GAME_TIMER_MIN(int_min, int_val)
	SET_GAME_TIMER_SEC(60 * int_min, int_val)
end

function GAME:SET_GAME_TIMER_SEC(int_sec, int_val)
	int_timer_base = int_sec --= (60 * int_min)
	float_timer_target = ( CurTime() + int_timer_base)

	int_timer_change = int_val
	INT_TIMER_FLAG = true
	print("Setting timer to : ", int_sec)

	local tstr = (int_sec > 0) and int_sec / 60 or 0
	--PrintMessage(
	--	HUD_PRINTCENTER,
	--	"Changing to: " ..  GET_GAME_STATE_STRING(int_gamestate) ..
	--	"\n\tGAME_STATE_TIMER STARTING FOR: (" .. string.format("%.1f", tstr) .. ")min\n\t(" .. int_sec .. ")sec ")
end

function GAME:PlayerThink()
	if(GAME.flags.state.GameType == 0) then

	end
end

function GAME:SHUNT_GAME_STATE()
	-- Shunt gamestate forwards, helpful for running games, that reach the endgame objective
	print("SHUNT_GAME_STATE")
	GAME:GAME_CHANGE_STATE(int_gamestate + 1)
	GAME:SET_GAME_TIMER_SEC(CONST_INT_GAME_TIME[int_gamestate], int_gamestate)
end

function GAME:CLOCK_THINK()
	--if ( !INT_TIMER_FLAG ) then return false end
	--print("TICK")
	-- ScheduleEvent is always fired first
	if(CurTime() < float_timer_schedule) then
		float_timer_schedule = 0
		print("[GAME]: GAME:CLOCK_THINK ScheduleEvent")
		MsgA("[GAME]: ScheduleEvent fired")
	end

	if( GAME:HAS_CAMERA() )then
		--INTERNAL_POINT_CAMERA.ent_p_camera:PointAtEntity(player.GetAll()[1])
		--CAMERA:SetAngles( Vector(0, 90, 0) )
		CAMERA:PointAtEntity(player.GetAll()[1])

		CAMERA:SetKeyValue( "fov", "60")
		CAMERA:GetPos():Distance(player.GetAll()[1]:GetPos())

		--dbg_bf_w_spawn

		--PrintTable(INTERNAL_POINT_CAMERA)
	end
	--print(float_timescale_timer)
	if ( float_timescale_timer > 0 ) then
		--print("float_timescale_timer -> tick")
		if( float_timescale_timer > CurTime() ) then
			--print("float_timescale_timer -> lerp")
			Lerp(0.5, 0.5, 1)
		else
			print("[GAME]: float_timescale_timer expired.")
			game.SetTimeScale(1)
			float_timescale_timer = 0
		end
	end

	if (CurTime() < float_timer_target ) then

		--print(CurTime(), "->", float_timer_target, "(" .. int_timer_base .. ")sec")
		--print(CurTime() , float_timer_target)
		float_timer_time = CurTime() - float_timer_target
		--math.abs(  CurTime() - float_timer_target )

		if ( math.abs(float_timer_ltime - float_timer_time) > 1) then
			--print("Time: ", string.format("%1.1f", math.abs(float_timer_ltime - float_timer_time)))
			local str = string.format("%.0f", math.abs(float_timer_time))
			--print("CLOCK_THINK: ", str , "/" , int_timer_base)
			float_timer_ltime = float_timer_time
			--PrintMessage(HUD_PRINTCENTER, GET_GAME_STATE_STRING(int_gamestate))
		end
	else
		--print("TIMER_END: (", int_timer_base, ") SEC")
		--PrintMessage(HUD_PRINTCENTER, GET_GAME_STATE_STRING(int_gamestate))
		--INT_TIMER_FLAG = false
		--print("CHANGE STATE")
		if( int_gamestate + 1 < 4) then
			--print("Gamestate: ", int_gamestate)
			--print("Game state before: ", int_gamestate)
			-- Incriment game state
			int_gamestate = int_gamestate+1
			--print("Game state after: ", int_gamestate)
			-- Change state
			GAME:GAME_CHANGE_STATE(int_gamestate)
			print("Timer: ", CONST_INT_GAME_TIME[int_gamestate+1], int_gamestate)
			-- Set timer to call back with this value, and a timer to run it for
			GAME:SET_GAME_TIMER_SEC(CONST_INT_GAME_TIME[int_gamestate+1], int_gamestate)
		else
			INT_TIMER_FLAG = false
			return false
		end
	end
end

function GAME_PAUSE(bFlag)
	-- If game is already paused, we'll ignore the call
	if(bFlag == true and int_gamestate == CONST_INT_GAME_STATE.PAUSE) then
		print("[GAME_STATE] GAME_ALREADY PAUSED")
		return false
	end
	print("[GAME] GAME_PAUSE: ", bFlag, ((bflag == true) and "Paused" or "Unpaused"))
	for k, v in pairs(player.GetAll()) do v:Freeze(bFlag) end
	return true
end
function GET_GAME_STATE_STRING(int_index)
	return (int_index < 0 and int_index > 5)
	and	"BAD_INDEX"
	or  CONST_STR_GAME_STATE[int_index]
end
function PRINT_GAME_STATE()
	print("[GAME] GAME_STATE IS : [" .. GET_GAME_STATE_STRING(int_gamestate+1) .. "]")
end
function GAME:GET_GAME_STATE()
	return int_gamestate
end

--ply, cmd, args
function GAME:GAME_CHANGE_STATE(int_state)
	--local int_state = tonumber(args[1]) --ply, cmd, args
	--print(int_state)

	if (int_state < 0 or int_state > 4) then return false end

	if(int_gamestate == int_state and !FLAG_GAME_STATE_RELOAD) then
		MsgC(CONST_VEC_COLOR_1, "[GAME] Gamestate already active, will not reload without override flag\n")
		return false
	end

	PRINT_GAME_STATE()
	print("Target: ", GET_GAME_STATE_STRING(int_state))
	print("State num: ", int_state)

	--print("INTERNAL: ", int_gamestate, CONST_INT_GAME_STATE.PAUSE)
	if(int_state == CONST_INT_GAME_STATE.PRE) then
		--play_sound(1)
		--RespawnAll_Player()
		GAME_PAUSE(true)
	elseif (int_state == CONST_INT_GAME_STATE.PLAY) then
		--if( int_gamestate == CONST_INT_GAME_STATE.PAUSE or CONST_INT_GAME_STATE.PRE) then
		GAME_PAUSE(false)

		--end
	elseif(int_state == CONST_INT_GAME_STATE.POST) then

		--v:StripWeapons()
		-- Clear their kills table
		--v:KF_Clear()
		-- Stripping running game score table
		--v:GAME_Clear()

		GAME_PAUSE(true)
	elseif(int_state == CONST_INT_GAME_STATE.PAUSE) then
		GAME_PAUSE(true)

	end

	print("[GAME]: GAME STATE CHANGED TO: [" .. GET_GAME_STATE_STRING(int_state+1) .."]")
	int_gamestate = int_state;

	-- Tell networked clients
	net.Start( "GS_UPDATE" )
		net.WriteInt(int_gamestate, 8)
		net.WriteInt(CONST_INT_GAME_TIME[int_gamestate+1], 16)
	net.Broadcast()

	print("Timer: ", CONST_INT_GAME_TIME[int_gamestate+1])
	return true
	--PrintMessage(HUD_PRINTCENTER, GET_GAME_STATE_STRING(int_gamestate+1))
end

function GAME:PlayerKill(ply)
	print("GAME: PlayerKill & GAMESTATE: ", GAME.flags.state.GameType, CONST_INT_GAMEMODE_ENUM.GUNGAME)
	if ( GAME.flags.state.GameType ==  CONST_INT_GAMEMODE_ENUM.UNREGISTERED ) then
	elseif (GAME.flags.state.GameType == CONST_INT_GAMEMODE_ENUM.DEATHMATCH) then
	elseif ( GAME.flags.state.GameType ==  CONST_INT_GAMEMODE_ENUM.GUNGAME) then
		print("GAME: PlayerKills: ", ply:GAME_Kills())
		if(ply:GAME_Kills() < CONST_INT_GUNGAME_MAX_KILLS) then
			print("GAME: PlayerKill OK")
			print("[GUNGAME] Player kills: ", ply:GAME_Kills(), ply:Nick())
			print("Stripping: ", CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills()])
			ply:StripWeapon(CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills()])

			print("Giving: ", CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills() + 1])
			ply:Give(CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills() + 1])
			--ply:SetActiveWeapon(CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills() + 1])
		else
			--GAME:GAME_MODE_CHANGE(CONST_INT_GAMEMODE_ENUM.GUNGAME)
			-- Set state to win condition & details, shunt state to game end
			GAME:SHUNT_GAME_STATE()
		end
	end
end

function GAME:OnPlayerSpawn(ply)
	print("-> OnPlayerSpawn")
	--ply:GAME_Clear()
	--ply:Give("fas2_deagle_a")
	ply:Give(CONST_STR_GUNGAME_WEAPON_LIST[1], false)

	if ( GAME.flags.state.GameType ==  CONST_INT_GAMEMODE_ENUM.UNREGISTERED ) then
		ply:Give(CONST_STR_GUNGAME_WEAPON_LIST[1], false)
		--ply:Give(CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills() + 1])

	elseif (GAME.flags.state.GameType == CONST_INT_GAMEMODE_ENUM.DEATHMATCH) then
		ply:Give(CONST_STR_GUNGAME_WEAPON_LIST[1], false)
	elseif ( GAME.flags.state.GameType ==  CONST_INT_GAMEMODE_ENUM.GUNGAME) then
		ply:Give(CONST_STR_GUNGAME_WEAPON_LIST[ply:GAME_Kills() + 1], false)
	end

end
function GAME:GAME_MODE_CHANGE(int_mode)
	print("-> [GAME_MODE_CHANGE]", CONST_STR_GAMEMODE_LIST[int_mode], int_mode)
	GAME.flags.state.GameType = int_mode
	-- Set up players for the gamemode
	for k, v in pairs(player.GetAll()) do
		if(not v:IsBot()) then
			if ( GAME.flags.state.GameType ==  CONST_INT_GAMEMODE_ENUM.GUNGAME) then
				-- Freeze game
				v:Freeze(bFlag)

				-- Kill players, because I'm too lazy to move players to the spawnpoints without spawning'
				v:Kill()

				-- Spawn them
				v:Spawn()

				-- Take their weapons away if somehow they've been given some, if so, please fix that so It can't happen
				v:StripWeapons();

				-- Clear their kills table
				v:KF_Clear()

				print("PLAYER GAME RESET")
				-- Stripping running game score table
				v:GAME_Clear()

				--v:Give("fas2_dv2")
				v:Give(CONST_STR_GUNGAME_WEAPON_LIST[1], false)
				print(CONST_STR_GUNGAME_WEAPON_LIST[1])
			end
		end
	end

	print(" ++++ Switching state ++++ ")

	GAME:GAME_CHANGE_STATE(CONST_INT_GAME_STATE.PRE)
	GAME:SET_GAME_TIMER_SEC(CONST_INT_GAME_TIME[int_gamestate+1], int_gamestate+1)
	--GAME:GAME_CHANGE_STATE(CONST_INT_GAME_STATE.POST)
	--GAME:SET_GAME_TIMER_SEC(CONST_INT_GAME_TIME[int_gamestate+1], int_gamestate+1)



	--GAME_CHANGE_STATE()
	--net.Start( "GM_CHANGE" )
	--	net.WriteInt(GAME.flags.state.GameType, 8)
		--net.WriteInt(CONST_INT_GAME_TIME[int_gamestate+1], 16)
	--net.Broadcast()
	--GAME.flags.state.GameType = ;
end
function GAME:COM_SetGameMode(ply, cmd, args)
	print("Switching gamemode")
	local int_state = tonumber(args[1])
	GAME:GAME_MODE_CHANGE(int_state)--CONST_INT_GAMEMODE_ENUM.DEATHMATCH)
end


checkpoint_table = {

}

concommand.Add("game_set_gamemode", GAME.COM_SetGameMode)

return GAME
