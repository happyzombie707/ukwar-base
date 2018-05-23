local meta = FindMetaTable( "Player" )
if ( !meta ) then return end

-- No table sent
CONST_FLAG_NO_TABLE = 0
-- Network flag to PUSH ENTIRE TABLE to client, say, for only updating the inflictor client on end of killstreak
CONST_FLAG_KILLTABLE_FULL = 1
-- Network flag to insert on clientside at index
CONST_FLAG_KILLTABLE_INSERT = 2
-- Network flag to push row to clientside Table
CONST_FLAG_KILLTABLE_PUSH = 3
-- Network flag to remove row from clientside at index
CONST_FLAG_KILLTABLE_REMOVE = 4
-- Tell the client their killstreak is over
CONST_FLAG_KILLTABLE_FINISH = 5
CONST_FLAG_KILLTABLE_ASSIST = 6

local CONST_COL_TEXT_COLOUR = Color(170, 140, 180)


-- In this file we're adding functions to the player meta table.
-- This means you'll be able to call functions here straight from the player object
-- You can even override already existing functions.

meta.loadout = 0
CONST_STR_HITGROUP_DISPLAY_TABLE = {
	"",
	"HEADSHOT",
	"PUNCTURE",
	"GUTSHOT",
	"FRAGMENTATION",
	"FRAGMENTATION",
	"FRAGMENTATION",
	"FRAGMENTATION"
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
	"PINCUSHION",
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

function GetHitStrIdx(float_dmg, int_hits)
	if(float_dmg > 90) then
		--if()
	elseif(float_dmg > 80) then

	elseif(float_dmg > 70) then

	elseif(float_dmg > 60) then

	elseif(float_dmg > 50) then

	elseif(float_dmg > 40) then
	
	elseif(float_dmg > 30) then

	end
end
function GetHitString_Ext(float_dmg, int_hits)
end

function GetHitGroupDisplayString( int_index )
	return ( int_index < 8 ) and CONST_STR_HITGROUP_DISPLAY_TABLE[int_index+1] or "GEAR" --Ignore irregular enum
end
HITGROUP_TABLE = {
	"HITGROUP_GENERIC",
	"HITGROUP_HEAD",
	"HITGROUP_CHEST",
	"HITGROUP_STOMACH",
	"HITGROUP_LEFTARM",
	"HITGROUP_RIGHTARM",
	"HITGROUP_LEFTLEG",
	"HITGROUP_RIGHTLEG",

	--[10] = "gear" -- Hack to Ignore it, rather than clamp the index
}

-- Scoring table
HITGROUP_SCORE_TABLE = {
	0,	--No points bonus for generic
	25,	--25 Points bonus for a headshot
	0,	--15 For chest
	15,	-- 15 for Stomach
	5,	-- 5 for Left arm
	5,	-- 5 for Right arm
	5,	-- 5 for Left leg
	5	-- 5 for Right leg
	--[10] = 0 -- Gear, ignore it
}
function GetHitGroupString( int_index )
	--print("Index: ", int_index)
	--if ( int_index < 8 ) then
	--	return HITGROUP_TABLE[int_index+1]
	--else
	--	return "GEAR"
	--end
	return ( int_index < 8 ) and HITGROUP_TABLE[int_index+1] or "GEAR" --Ignore irregular enum
end
function GetHitGroupScore( int_index )
	 return ( int_index < 8 ) and HITGROUP_SCORE_TABLE[int_index+1] or 0 --Ignore irregular enum
end

function meta:Ex_Init()
	self:KF_Init()
	self:STAT_Init()
end


CONST_INT_PLAYER_STATE_BLOODLOSS = 2
function meta:STAT_Init()
	MsgC(CONST_COL_TEXT_COLOUR,"\t[obj_player_extend.lua] meta:STAT_Init void\n")
	local frameinit = { 

		gstate = {
			bBleeding = false,	-- We're bleeding'
			intBleedRate = 0,	-- Bleed how much over game ticks, if 
			intBleedChunk = 0,
			--intStartBleed = 0,
			intBleedDelay = 0,

			--intHitstart_time = 0, -- CONST_INT_PLAYER_STATE_BLOODLOSS
			intBleedCount = 0
		},
		

		sc = 0,		-- Score
	
		hits = 0,	-- Hits on players
		shots = 0,	-- Hits
		assist = 0, -- Assist count

		game = {
			k = 0,		-- Kills count
		},

		k = 0,		-- Kills count
		d = 0		-- Deathcounts
	}

	local tab = self:GetTable()
	tab.stat = frameinit
end
function meta:KF_Init()
	MsgC(CONST_COL_TEXT_COLOUR,"\t[obj_player_extend.lua] meta:KF_Init void\n")
	local tab = self:GetTable()
	local frameinit = { 
		st = 0; -- Server feed starting time
		ut = 0;	-- Not used
		k = 0;	-- Kill count
		b = 0; -- Server feed time  window pad, by seconds
		a = {};	-- Array of kills in window
		lhit = {
				uid = 0,-- Unique ID 
				dmg = 0, -- Total damage
 				lf = 0,
				hcnt = 0 -- Hit count
			};
	}
	-- Init table
	tab.kf = frameinit
	--frameinit
	--table.insert(tab, frameinit)
end

CONST_INT_KF_INCREASE_SECOND = 0.5
CONST_INT_KILL_FRAME_TIME_SEC = 3

function meta:__STAT_GetTable()
	return self:GetTable().stat
end

function meta:STAT_Get()
	return self:GetTable().stat
end

function meta:STAT_GetKills()
	return self:__STAT_GetTable().k
end

function meta:GAME_Kills()
	return self:GetTable().stat.game.k
end

function meta:GAME_Clear()
	print("meta:GAME_Clear")
	self:GetTable().stat.game.k = 0
end

function meta:STAT_Add_Kill(In_int_type)
	-- 1 == NPC
	-- 0 == player
	local t = self:__STAT_GetTable()

	t.k = t.k + 1
	t.game.k = t.game.k + 1

	--print("Kills: ", t.game.k)
	return t.k
end

function meta:STAT_Add_AttackBullet(In_int_hit, In_int_hitgroup)
	local t = self:__STAT_GetTable()
	if(In_int_hit == 0) then
		t.shots = t.shots + 1
	else
		-- I can only detect if a bullet has been fired, not if it's been fired and will hit
		-- so instead we always count any bullet fired as a miss
		-- if we do actually hit someone, we remove the shot from the missed counter, and add it to the hit counter
		--t.shots = t.shots - 1
		-- Actually, that's wrong, we derive the ratio from the count and hits'
		t.hits = t.hits + 1
	end

	--print("Type: ", In_int_hit)
	--print("Total shots: ", t.shots)
	--print("Total hits: ", t.hits)
	--print("Accuracy: ", t.hits / t.shots * 100 .. "%")
	return t.shots
end

function meta:__KF_GetTable()
	return self:GetTable().kf
end

function meta:KF_LastHitCount(int_uid)
	local kf = self:__KF_GetTable()
	if ( kf.lhit.uid == int_uid ) then
		return kf.lhit.hcnt
	end
	return 0
end
function meta:KF_LastHit_DmgAvg(int_uid)
	local kf = self:__KF_GetTable()
	if(kf.lhit.hcnt > 0) then
		MsgC(Color( 100, 255, 100), kf.lhit.dmg / kf.lhit.hcnt)
		return kf.lhit.dmg / kf.lhit.hcnt
	end
	return 0
end
function meta:KF_LastHit_Dmg(int_uid)
	local kf = self:__KF_GetTable()
	if ( kf.lhit.uid == int_uid ) then
		--if ( kf.lhit.dmg > 40 ) then
		return kf.lhit.dmg
		--end
	end
	return 0
end

function meta:KF_UpdateLastHit(uuid, healthtaken)
	local kf = self:__KF_GetTable()
	--print("S UUID: ", uuid)
	--print("I UUID: ", kf.lhit.uid)
	if( kf.lhit.uid == uuid ) then
		kf.lhit.hcnt = kf.lhit.hcnt + 1
		kf.lhit.dmg = kf.lhit.dmg + healthtaken
		--MsgC(CONST_COL_TEXT_COLOUR, "\tmeta:KF_UpdateLastHit: Inc to ", kf.lhit.dmg , "\n")
	else
		kf.lhit.dmg = 0
		kf.lhit.hcnt = 0
		kf.lhit.uid = uuid
		kf.lhit.dmg = healthtaken
	end
end

function meta:KF_Valid()
	if( kf.st + CONST_INT_KILL_FRAME_TIME_SEC >  CurTime() ) then
		return true
	else
		--MsgC(CONST_COL_TEXT_COLOUR,
		--	"\tTimer is up > (" .. CONST_INT_KILL_FRAME_TIME_SEC ..")sec + " .. kf.b .. ") bump\n",
		--	"\tWindow time: ", CurTime() - kf.st, "\n",
		--	"\tKills: " .. kf.k, "\n")

		--print("\tTimer is up > (" .. CONST_INT_KILL_FRAME_TIME_SEC ..")sec + " .. kf.b .. ") bump")
		--print("\tWindow time: ", CurTime() - kf.st)
		--print("\tKills: " .. kf.k)
		return false
	end
end

function meta:KF_Invalid()
	local kf = self:__KF_GetTable()
	if( kf.st + CONST_INT_KILL_FRAME_TIME_SEC >  CurTime() ) then
		return false
	else

		--MsgC(CONST_COL_TEXT_COLOUR,
		--	"\tTimer is up > (" .. CONST_INT_KILL_FRAME_TIME_SEC ..")sec + " .. kf.b .. ") bump\n",
		--	"\tWindow time: ", CurTime() - kf.st, "\n",
		--	"\tKills: " .. kf.k, "\n")

		--print("\tTimer is up > (" .. CONST_INT_KILL_FRAME_TIME_SEC ..")sec + " .. kf.b .. ") bump")
		--print("\tWindow time: ", CurTime() - kf.st)
		--print("\tKills: " .. kf.k)
		return true
	end
end

function meta:KF_Add(inflictor, victim)
	--MsgC(CONST_COL_TEXT_COLOUR, "\t[obj_player_extend.lua] meta:KF_Add k\n")
	local kf = self:__KF_GetTable()

	--print(victim)
	--PrintTable(kf)
	--print("\tServer time: ", CurTime())
	--if (  ) then
	--	kf.k = kf.k+1;
	--print("Inflictor: ", inflictor)	
	CONST_KILL_HEAD_BONUS = 25
	CONST_KILL_NORMAL_SCORE = 100
	CONST_KILL_NORMAL = 0
	CONST_KILL_ASSIST = 2
	CONST_KILL_HEADSHOT = 1

	local hitgroup = victim:LastHitGroup()
	--if(victim != nil ) then
		--hitgroup = victim:LastHitGroup()
	--else
		--hitgroup = 0
	--end
	--print("Hit: ", hitgroup)

	--print("Inf: ", Inflictor)
	local hitstring =  GetHitGroupString( hitgroup )
	local pk = 100 + HITGROUP_SCORE_TABLE[hitgroup+1]

	local kill = {
		--Killing modifier, say killing round was a headshot
		t = hitgroup;
		ts = hitstring;
		i = inflictor;
		s = pk;
		n = victim:Nick()
	}

	-- kf might be zero ( First kill of the game) so set it to server time
	if ( kf.st == 0 ) then
		kf.st = CurTime()
	end

	kf.k = kf.k+1;
	kf.st = kf.st + CONST_INT_KF_INCREASE_SECOND
	kf.b = kf.b + CONST_INT_KF_INCREASE_SECOND
	table.insert(kf.a, kill)
end

function meta:KF_GetKills()
	local p = self:GetTable();
	local t = p.kf.k
	--local r = t.k
	--PrintTable(t)
	--print("\t[obj_player_extend.lua] meta:KF_GetKills Kills: (" .. r ..")")
	--MsgC(CONST_COL_TEXT_COLOUR, "\tKills: ", t ,"\n")
	return t
end

function meta:KF_GetKillTable()
	return self:GetTable().kf.a
end

function meta:KF_Clear()
	--MsgC(CONST_COL_TEXT_COLOUR,"\t[obj_player_extend.lua] meta:KF_Clear void : Clearing kill record table\n")
	local kf = self:GetTable().kf

	-- Clear table
	for k,v in pairs(kf.a) do kf.a[k]=nil end

	-- Strictly speaking, not required. It's just a variable to aid debugging
	kf.b = 0
	
	-- Reset kill counter
	kf.k = 0

	-- Reset timer to zero, reasons
	kf.st = 0
end

function meta:KF_Count()
	--print("Counting points: ")
	local kf = self:GetTable().kf
	local total = 0

	--print("Loop: ", kf.k)
	for k = 1, kf.k, 1 do
		
		-- Base score of 100 for a kill, we'll add assists later if we can'
		local pk = 100

		-- Work out the extra score for the hitgroup we killed them with, by checking HITGROUP_SCORE_TABLE
		pk = pk + HITGROUP_SCORE_TABLE[kf.a[k].t+1] -- t+1, because indexes are not based at zero
		
		-- Debug bit: Sum it up, and print the score
		total = total + pk 
		--MsgC(CONST_COL_TEXT_COLOUR, "Kill score: (" .. pk .. ") " .. kf.a[k].ts , "\n")
	end

	--print("Total: ", total)
	return total
end

function meta:__STATE_GetTable()
	return self:GetTable().stat.gstate
end

function  meta:STATE_IsBleeding()
	return self:__STATE_GetTable().bBleeding
end
function  meta:STATE_SetBleed(int_damage_cap, int_bleed_rate)
	print("Bleeding with damage factor: ", int_damage_cap)
	PrintTable(self:__STATE_GetTable())
	self:__STATE_GetTable().intBleedLimit = int_damage_cap
	self:__STATE_GetTable().intBleedRate = int_damage_cap
	self:__STATE_GetTable().intBleedChunk = 5 + self:__STATE_GetTable().intBleedChunk
	--self:__STATE_GetTable().intStartBleed = self:Health()
	self:__STATE_GetTable().bBleeding = true
end

function  meta:STATE_Bleed()
	local tbl = self:__STATE_GetTable()
	--PrintTable(tbl)
	local health = self:Health()
	if( health > 0 and CurTime() > tbl.intBleedDelay) then
	--(intStartBleed - 
		tbl.intBleedDelay = CurTime() + 0.8
		self:SetHealth( health - tbl.intBleedChunk)
		--print("Bled")
		local vPoint = self:GetPos() + Vector(0, 0, 10)
		--print("Point: ", vPoint)
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		effectdata:SetFlags( 3 )
		effectdata:SetColor( 0 )
		effectdata:SetScale( 6 )
		util.Effect( "BloodImpact", effectdata )

	--else if(health == 0) then
	--	self:Kill()
		--self:__STATE_GetTable().intBleedChunk = 0
		--self:__STATE_GetTable().bBleeding = false
	end
	return true
end


function meta:KF_GetTable()
	local tab = self:GetTable()
	return tab.kf;
end