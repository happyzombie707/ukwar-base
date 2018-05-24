AddCSLuaFile()

include("game.lua")
--include("cl_terminal.lua")
--include("cl_graphics.lua")

__INT_TIME_PREV = 0
__INT_DELTA_TIME = 0
__INT_FRAME_TIME = 0

CONST_INT_STANDARD_HEALTH = 100
CONST_INT_HUD_ENT_HEALTH_SCALE = 1.5
CONST_INT_HEALTH_CLIP_LIMIT = 35
CONST_INT_HUD_OVERLAY_RANGEZFAR = 700 * 2
CONST_INT_HUD_LINE_WIDTH = 1


local SCREEN_GREYSCALE_MOD = 1
local SCREEN_SCREENSPACE_MOD = false

local SCREENSPACE_COLOR_STATE = {
	-- Zero means no change
	[ "$pp_colour_addr" ] = 0.00,
	[ "$pp_colour_addg" ] = 0.00,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,

	-- 1 Means no change
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	
	-- 0 means no change
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0.00,
	[ "$pp_colour_mulb" ] = 0
}

function SCREENSPACE_STRUCT()
	return { time = 0,  start = 0, lerp = 0, target = 0}
end

local SCREENSPACE_ACTIVE_COUNT = 0

local SCREENSPACE_MODIFIER = {
	SCREENSPACE_STRUCT(),	-- $pp_colour_addr
	SCREENSPACE_STRUCT(),	-- $pp_colour_addg
	SCREENSPACE_STRUCT(),	-- $pp_colour_addb
	SCREENSPACE_STRUCT(),	-- $pp_colour_brightness
	SCREENSPACE_STRUCT(),	-- $pp_colour_contrast
	SCREENSPACE_STRUCT(),	-- $pp_colour_colour
	SCREENSPACE_STRUCT(),	-- $pp_colour_mulr
	SCREENSPACE_STRUCT(),	-- $pp_colour_mulg
	SCREENSPACE_STRUCT(),	-- $pp_colour_mulb

	SCREENSPACE_STRUCT(),	-- Bloom
	SCREENSPACE_STRUCT(),	-- Motion blur

}

local POST_PROCESS_KEY_TABLE = {
	"$pp_colour_addr",
	"$pp_colour_addg",
	"$pp_colour_addb",
	"$pp_colour_brightness",
	"$pp_colour_contrast",
	"$pp_colour_colour",
	"$pp_colour_mulr",
	"$pp_colour_mulg",
	"$pp_colour_mulb"
}
function SCREENSPACE_KEY_GET(In_int_key)
	if(In_int_key == 0) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_addr"]
	elseif(In_int_key == 1) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_addg"]
	elseif(In_int_key == 2) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_addb"]
	elseif(In_int_key == 3) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_brightness"]
	elseif(In_int_key == 4) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_contrast"]
	elseif(In_int_key == 5) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_colour"]
	elseif(In_int_key == 6) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_mulr"]
	elseif(In_int_key == 7) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_mulg"]
	elseif(In_int_key == 8) then
		return SCREENSPACE_COLOR_STATE["$pp_colour_mulb"]
	else
		print("SCREENSPACE_KEY_GET OUT OF RANGE")
	end
end

function POST_PROCESS_THINK()
	if(SCREENSPACE_ACTIVE_COUNT > 0) then
		-- Parse display modifiers
		for i = 1, 8 do
			if( __INT_FRAME_TIME < SCREENSPACE_MODIFIER[i].time ) then
				SCREENSPACE_MODIFIER[i].lerp = Lerp( SCREENSPACE_MODIFIER[i].time - __INT_FRAME_TIME, 
													SCREENSPACE_MODIFIER[i].start, 
													SCREENSPACE_MODIFIER[i].target)
				SCREENSPACE_COLOR_STATE[POST_PROCESS_KEY_TABLE[i]] = SCREENSPACE_MODIFIER[i].lerp
			else
				if ( SCREENSPACE_MODIFIER[i].lerp != SCREENSPACE_MODIFIER[i].target) then
					print("CLAMPED POST PROCESS TO TARGET")
					SCREENSPACE_MODIFIER[i].target = SCREENSPACE_MODIFIER[i].lerp
					SCREENSPACE_COLOR_STATE[POST_PROCESS_KEY_TABLE[i]] = SCREENSPACE_MODIFIER[i].lerp
				end
			end
		end
		DrawColorModify( SCREENSPACE_COLOR_STATE )

		if(__INT_FRAME_TIME < SCREENSPACE_MODIFIER[10].time) then
			SCREENSPACE_MODIFIER[10].lerp = Lerp( SCREENSPACE_MODIFIER[10].time - __INT_FRAME_TIME, 
													SCREENSPACE_MODIFIER[10].start, 
													SCREENSPACE_MODIFIER[10].target)
			DrawBloom( 0.65, SCREENSPACE_MODIFIER[10].lerp, 9, 9, 1, 1, 
							SCREENSPACE_MODIFIER[10].lerp * 0.2,
							SCREENSPACE_MODIFIER[10].lerp * 0.2,
							SCREENSPACE_MODIFIER[10].lerp * 0.2)
		end

		if(__INT_FRAME_TIME < SCREENSPACE_MODIFIER[11].time) then
			SCREENSPACE_MODIFIER[10].lerp = Lerp( SCREENSPACE_MODIFIER[11].time - __INT_FRAME_TIME, 
													SCREENSPACE_MODIFIER[11].start, 
													SCREENSPACE_MODIFIER[11].target)
			DrawMotionBlur( 0.4, SCREENSPACE_MODIFIER[11].lerp , 1)
		end
	end
end

-- Schedule screenspace modifier tranistion
function POST_PROCESS_ADD(In_int_key, In_int_startvalue, In_int_target, In_int_time)

	SCREENSPACE_MODIFIER[In_int_key].time = In_int_time
	SCREENSPACE_MODIFIER[In_int_key].target = In_int_target
	SCREENSPACE_MODIFIER[In_int_key].start = In_int_startvalue
	SCREENSPACE_ACTIVE_COUNT = SCREENSPACE_ACTIVE_COUNT + 1

	--print("Modifying: (" .. POST_PROCESS_KEY_TABLE[In_int_key] .. ") From" .. In_int_startvalue .. " To " .. In_int_target .. " Over: " .. CurTime() - In_int_time)

	--print("POST_PROCESS_ADD")
	--SCREENSPACE_MODIFIER[In_int_key].time = In_int_time
end

--CreateClientConVar("hitmarker_enabled", 1, true, false);
--CreateClientConVar("hitmarker_sound", 1, true, false);
--CreateClientConVar("hitmarker_npc", 1, true, false);
--local hitsound = "hit.wav";
--util.PrecacheSound(hitsound);

local function CalculateBezierPoint(t, p0, p1, p2, p3)
  --float 
  local u = t - 1
  --u = u – t
  
  --float 
  local tt = t*t
  
  --float 
  local uu = u*u
  
  --float 
  local uuu = uu * u
  
  --float 
  local ttt = tt * t
 
  local p = uuu * p0		--first term
  p = p + 3 * uu * t * p1		--second term
  p = p + 3 * u * tt * p2		--third term
  p = p + ttt * p3			--fourth term
  return p
end

local alpha = 0;
local hx = ScrW() / 2
local hy = ScrH() / 2

CONST_HITMARKER_FADE = 0.05
CONST_INT_HITMARKET_SCALE = 1
CONST_INT_HITMARKER_OUTER_LENGTH = 7

local function draw_hitmarker()
	alpha = Lerp(CONST_HITMARKER_FADE, alpha, 0);
	surface.SetDrawColor(255, 255, 255, alpha);
	surface.DrawLine(hx - 7, hy - 6, hx - 12, hy - 11);
	surface.DrawLine(hx + 6, hy - 6, hx + 11, hy - 11);
	surface.DrawLine(hx - 7, hy + 6, hx - 12, hy + 11);
	surface.DrawLine(hx + 6, hy + 6, hx + 11, hy + 11);
end

hook.Add("HUDPaint", "hitmarker", draw_hitmarker);
hook.Add("ScalePlayerDamage", "hitmarker_scaleplayerdamage", function(ply, hitgroup, dmginfo)
	--if (GetConVarNumber("hitmarker_enabled") != 1) then return; end

	if (dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker() == LocalPlayer()) then
		alpha = 255;
		
		print("Boop: ", SCREENSPACE_COLOR_STATE[5])

		

		--POST_PROCESS_ADD(10, 0, 3, CurTime() + 1)
		--POST_PROCESS_ADD(11, 0, 3, CurTime() + 5)
		
		--POST_PROCESS_ADD(5, 1, 3, CurTime() + 1)

		--POST_PROCESS_ADD(7, 0, 5, CurTime() + 1)
		--POST_PROCESS_ADD(8, 0, 5, CurTime() + 1)
		--SCREENSPACE_COLOR_STATE["$pp_colour_mulr"] = 5
		
		--if(SCREEN_SCREENSPACE_MOD) then
			DrawColorModify( SCREENSPACE_COLOR_STATE )
		--end

		--if (GetConVarNumber("hitmarker_sound") == 1) then
		--	LocalPlayer():EmitSound(hitsound, 100);
		--end
   end
end);

local nextFireTime = 0;
hook.Add("CreateMove", "hitmarker_npc", function(cmd)
	if (!LocalPlayer():Alive() 
		or !LocalPlayer():KeyDown(IN_ATTACK) 
		or LocalPlayer():GetActiveWeapon():Clip1() 
		<= 0 or GetConVarNumber("hitmarker_enabled") 
		!= 1 or GetConVarNumber("hitmarker_npc") != 1) 
	then return; end

	if (LocalPlayer():GetEyeTrace().Entity:IsNPC()) then
		local next_primary_fire = LocalPlayer():GetActiveWeapon():GetNextPrimaryFire() or 0;
		if (nextFireTime < next_primary_fire) then
			nextFireTime = next_primary_fire;
			alpha = 255;
		
			--if (GetConVarNumber("hitmarker_sound") == 1) then
			--	LocalPlayer():EmitSound(hitsound, 100);
			--end
		end
	end
end);

--]]
--local icon = vgui.Create( "DModelPanel", Panel )
--icon:SetPos( 0, ScrH() / 2)
--icon:SetSize( ScrW() / 5, ScrH() - (ScrH() / 10) - 200 )
--icon:SetModel( "models/weapons/w_m4.mdl" )
--icon:SetCamPos( Vector( 0, 25, -2 ) )
--icon:SetLookAt( Vector( 0, 0, 0 ) )
--function icon:LayoutEntity(Entity)
--	if ( self.bAnimated ) then
--		self:RunAnimation()
--	end
	
	--local t = Entity:GetAngles()
	--t:Normalize()
	--print(t)
	--Angle(0, 0, 0)
	--Entity:SetAngles(t)
	--Entity:SetAngles(Angle(Entity:GetAngles().p+1,Entity:GetAngles().y-1,Entity:GetAngles().r+2	) )
--end

surface.CreateFont( "HBF_HX", {
	font = "Trebuchet MS", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 48 * 2,
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

surface.CreateFont( "HBF_HL", {
	font = "Trebuchet MS", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 48,
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

surface.CreateFont( "HBF_HM", {
	font = "Trebuchet MS", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 48,
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

CONST_INT_SCREEN_PADDING = 10
CONST_INT_SCREEN_PADDING_TOTAL = 20
CONST_INT_BOX_MARGIN = 5
CONST_INT_BOX_MARGIN_TOTAL = 10
CONST_INT_BOX_PADDING = 2
CONST_INT_SQUADBOX_HEIGHT = 16
CONST_INT_SQUADBOX_WIDTH = CONST_INT_BOX_MARGIN_TOTAL + 220
CONST_INT_CHARACTER_WIDTH = 24

CONST_STR_CLASS_ASCII_TABLE = {
	"ASU",
	"ENG",
	"SUP",
	"HVY"
}

CONST_INT_DOF_INIT_LENGTH = 20000
local _bdof_run = true
local _int_doflength = 10000 --100000
local _int_doftarget = 0
local _int_doftime = 2000
local _float_LastThink = 0

function HUD_FadeInto(target)
	if ( HUD_DOFisActive() ) then
		HUD_DOFFadeTo(0)
	else
		HUD_DOFStart(10000, 0)
	end
end

function HUD_DOF_Think()
	if(not HUD_DOFisActive()) then
		--print("NOT ACTIVE")
		return false
	end
	if(_int_doflength != _int_doftarget) then
		local now = CurTime()
		local timepassed = now - _float_LastThink
		RunConsoleCommand( "pp_dof_initlength", _int_doflength )
		_int_doflength = math.Approach(_int_doflength, _int_doftarget, _int_doftime * timepassed)
		--print("Dof think -> len(" .. _int_doflength.. ") Targ(" .._int_doftarget .. ") change(" ..  _int_doftime ..")")
		_float_LastThink = now
	else
		HUD_DOFStop()
	end
end
function HUD_DOFFadeTo(
	--In_int_dof_length, 
	Target)

	_int_doftarget = Target
	_bdof_run = true
	print("DOF -> Swapping fade")
	--_int_doflength = In_int_dof_length
	--In_int_dof_length
end
function HUD_DOFisActive()
	--print("HUD_DOFisActive:", _bdof_run)
	return _bdof_run
end
function HUD_DOFStop()
	_bdof_run = false
	DOF_Kill()
	print("Dof kill ->")
end
function HUD_DOFStart(int_start, int_to)
	if(int_start == nil or int_to == nil) then
		_int_doflength = CONST_INT_DOF_INIT_LENGTH
		_int_doftarget = 0
	else
		_int_doflength = int_start
		_int_doftarget = int_to
	end
	--_int_doftime = 1
	print("DOF -> Starting")
	_bdof_run = true

	DOF_Start()
	
end

function UI_Draw_Terminal()
	print("Draw")
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, ScrW(), ScrH())

	draw.SimpleText("Connecting to uplink..........[Ok]\nCongratulations soldier!", 
		"Trebuchet18",
		0 + CONST_INT_BOX_MARGIN,
		0 + CONST_INT_BOX_MARGIN, 
		Color(255,255,255,255))
	
	
	--draw.RoundedBox( 0,
	--0,0,
	--ScrW(),
	--ScrH(),
	--Color(255, 0, 0, 255)
	--)
end
function UI_Draw3D_Hud_SquadBar()
	local HudMatrix = Matrix()
	local vAngle = Angle()

	HudMatrix:Translate( Vector( ScrW()/2, ScrH()/2 ) )
	vAngle:RotateAroundAxis(Vector(0, 0, 0) , 10)
	HudMatrix:Rotate(vAngle )
	--HudMatrix:Rotate( Angle( 0,  math.sin( CurTime() /100 ) *10 ), 0 )
	cam.PushModelMatrix( HudMatrix )
	
	surface.DrawRect( 100, 100, 200, 300)
	surface.SetFont( "Trebuchet18" )
	surface.SetTextColor( 255, 255, 255, 255 )	
	--	surface.SetTextPos( w/2, h/2 )
	surface.DrawText( "LOLLOLOLOL" )
	cam.PopModelMatrix()
end


function UI_Draw_NDA_USER()
	draw.SimpleText("[" ..LocalPlayer():Nick() .. "]", 
			"HBF_HL",
			ScrW() - 200,
			ScrH() - 200, 
			Color(255,255,255,210))
end

function Get_Squad()
	
end

function UI_Draw_Hud_SquadBar()
	-- Height is number of members up from the bottom
	-- Min is 4, max is 10
	local squad = {
		{
			name="Harry", -- Name string
			c=0, --  Class name, this'll be gotten from the lookup table, rather than the string'
			i="+",	-- Icon
			v=false,  -- Voip Y/N
			l=100, -- Level
			s=true -- Alive/dead state
		},
		{
			name="VERY_LONG_NAME",  -- Name string
			c=3, -- Class name, this'll be gotten from the lookup table, rather than the string'
			i="->",	--Icon
			v=true, -- Voip Y/N
			l=15, -- Level
			s=false -- Alive/dead state
		},
		{
			name="Short Name",
			c=1,
			i="+",
			v=false,
			l=100,
			s=true
		},
		{
			name="Larry",
			c=0,
			i="+",
			v=false,
			l=100,
			s=true
		},
		{
			name="xX_MGL_XxPro",
			c=1,
			i="+",
			v=false,
			l=100,
			s=true
		}
	}

	local dbg_squadnum = table.Count(squad)
	local yoff =  ScrH() - CONST_INT_SCREEN_PADDING - ((CONST_INT_BOX_PADDING + CONST_INT_SQUADBOX_HEIGHT * dbg_squadnum))
	local xoff = CONST_INT_SCREEN_PADDING
	local width, height;
	
		


	
	draw.SimpleText("Squad Table ->" , 
			"Trebuchet18",
			xoff,
			yoff- 24, 
			Color(255,255,255,210))

	--PrintTable(squad)
	draw.RoundedBox( 0, 
		CONST_INT_BOX_MARGIN,					-- Width
		yoff - CONST_INT_BOX_MARGIN,			-- Height offset, full x axis - squadbox height and number of boxes

		CONST_INT_SQUADBOX_WIDTH + CONST_INT_BOX_MARGIN_TOTAL, 
		CONST_INT_BOX_MARGIN + (CONST_INT_BOX_PADDING + CONST_INT_SQUADBOX_HEIGHT * dbg_squadnum),	-- Height
		Color(37, 37, 37, 210 )
		)

	for i = 1, dbg_squadnum, 1 do
		local idx = i-1
		--print("Index --> ", i)
		draw.RoundedBox( 0, 
			xoff, -- Width
			yoff - CONST_INT_BOX_MARGIN + idx * (CONST_INT_SQUADBOX_HEIGHT + CONST_INT_BOX_PADDING),	-- Go down box drawing at each offset
			CONST_INT_SQUADBOX_WIDTH, CONST_INT_SQUADBOX_HEIGHT,	
			Color(37, 37, 37, 210 )
		)

		surface.SetFont( "Trebuchet24" )
		width, height = surface.GetTextSize( squad[i].name )
		if(width > CONST_INT_SQUADBOX_WIDTH /2) then
		
		end

		-- Don't question it!'
		draw.SimpleText("[" .. i .. "] " .. (width < CONST_INT_SQUADBOX_WIDTH/2 + 60 and squad[i].name or (string.sub(squad[i].name, 1, 10) .. "...")) .. " [" .. CONST_STR_CLASS_ASCII_TABLE[squad[i].c+1] .."]" , 
			"Trebuchet18",
			xoff,
			yoff - CONST_INT_BOX_MARGIN + idx * (CONST_INT_SQUADBOX_HEIGHT + CONST_INT_BOX_PADDING), 
			Color(255,255,255,210))
		--xoff + (CONST_INT_SQUADBOX_WIDTH/2) + 15,
		draw.SimpleText(squad[i].v and "V" or "/V", 
			"Trebuchet18",
			xoff + CONST_INT_SQUADBOX_WIDTH - 20,
			yoff - CONST_INT_BOX_MARGIN + idx * (CONST_INT_SQUADBOX_HEIGHT + CONST_INT_BOX_PADDING), 
			Color(255,255,255,210))
		--print(CONST_STR_CLASS_ASCII_TABLE[squad[i].c+1])
		-- .. " [" .. CONST_STR_CLASS_ASCII_TABLE[squad[i].c+1] .."]"
	end

	--cam.Start3D2D( Vector(0, 0), Angle(0, 0, 0), 1 )
	--render.DrawWireframeBox( Vector position, Angle angle, Vector mins, Vector maxs, Color(255, 255, 255, 255), false )
	--draw.DrawText("Your Mother", "Trebuchet18", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
	--cam.End3D2D()

end
function Beziere(In_time, In_vector_p0, In_vector_01, In_vector_02)
	p = (1-t)^2 *In_vector_p0 + 2*(1-t)*t*In_vector_01 + t*t*In_vector_02
end
banner_offset = 0
banner_runtime = 0
function DrawBanner(In_str_text)
	delta_time = (CurTime() - banner_runtime)
	surface.SetFont( "Trebuchet24" )
	local width, height = surface.GetTextSize( In_str_text )

	num = ScrW() / width

	--print("Delta: ", delta_time)
	if(banner_offset < ScrW()) then
		banner_offset = (banner_offset + ScrW() / 10 * delta_time)
	else
		banner_offset = 0
	end

	--draw.SimpleText(In_str_text, 
	--		"Trebuchet24",
	--		banner_offset,
	--		ScrH() / 2, 
	--		Color(255,255,255,210))
	--banner_runtime = CurTime()

	for i = 1, num do
		off = (width * i) + banner_offset +  (50 * i)

		if(	off > ScrW() + width) then
			off = banner_offset - (width * i) - (50 * i)
		end
		
		draw.SimpleText(In_str_text, 
			"Trebuchet24",
			off,
			ScrH() / 2, 
			Color(255,255,255,210))
	end
	banner_runtime = CurTime()
end

CONST_STR_HUD_CHANGESTATE_TABLE = {
	"SHUTDOWN",
	"RESTARTING",
	"RESTART_UPDATE",
	"CHANGE_MAP_OVVERIDE",
	"DEBUG_FAULT_SHUTDOWN",
	"DEBUG_FAULT_RESTART",
	"DEBUG_FAULT_RESTART_&_RELOAD"
}
function UI_Warning_ChangeState(In_int_state, In_int_time)
	local str_outstr = CONST_STR_HUD_CHANGESTATE_TABLE[In_int_state+1]

	--print("Delta_Time: ", __INT_DELTA_TIME)
	--	255 * ((math.cos(__INT_DELTA_TIME)+1)/2)
	surface.SetFont( "HBF_HL" )
	local width, height = surface.GetTextSize( str_outstr )
	draw.SimpleText("Alert!", 
			"HBF_HM",
			ScrW() /2 - 100/2,
			40, 
			Color(
				255,
				255,
				255,
				210)
			)
	--255/2 * ((math.cos(__INT_DELTA_TIME)+1)/2)
	In_int_shift = 255 * ((math.cos(CurTime()) + 1) / 2)
	surface.SetDrawColor( 37, 37, 37, 210 )
	surface.DrawRect( ScrW() /2 - width/2 - 5, 80, width + 10, height )
	draw.SimpleText(str_outstr, 
			"HBF_HL",
			ScrW() /2 - width/2,
			80, 
			Color(
				204 + In_int_shift,
				102 + In_int_shift,
				102 + In_int_shift,
				210)
			)
end

function RenderCustom()
	--local w, h = ScrW(), ScrH()
	--local t = RealTime()*50
	--mat:Rotate( Angle( 0, t, 0 ) )
	--mat:Scale( Vector( 1, 1, 1 ) * math.sin( t/100 ) *10 )
	--mat:Translate( -Vector( w/2, h/2 ) )
end

function GetTimeSecondsMOD(int_mod)
	--print( math.mod(CurTime(), int_mod))
	return math.mod(CurTime(), int_mod)
end

local bDrawBanner = true

function UI_DrawWarningNoBase(str_string)
	local srh = ScrH() - 80
	local scw = ScrW()
	local msg = "Warning, required game assets have not been downloaded. Please visit the steam community for the asset pack, or open the menu, and click 'GAME ASSETS'",
		

	draw.RoundedBox( 0, 
		0, srh,
		ScrW(), 40,-- team.GetColor(k)
		Color(37, 37, 37, 210 )
		)

	surface.SetFont( "Trebuchet24" )
	local width, height = surface.GetTextSize( msg )
	draw.SimpleText(msg, 
		"Trebuchet24",
		ScrW()/2 - width/2,
		srh + 5, 
		Color(255,255,255,210))
end

function UI_DrawTeamHigherachy()
	local tblTeams = team.GetAllTeams()
	local count = table.Count(tblTeams)


	--print("Count: ", count)
	--team.GetAllTeams()

	--PrintTable(tblTeams)
	--
	local h = 32
	local w = 32 * 2

	local width = 300
	local xoff = ScrW() /2 - width/2

	for i = 1, count - 3, 1 do
		--print(i, tblTeams[i].Color)
		draw.RoundedBox(INT_NO_BORDERS, 
			xoff - w * i, 
			0, 
			w, 
			h, 
			tblTeams[i].Color)
		

		draw.SimpleText(tblTeams[i].Name .. "[" .. tblTeams[i].Score .. "]", 
		"Trebuchet18", 
		xoff - w * i + 5,
		16 /2 - 2, 
		Color(255,255,255,210))
		
	end
end

function UI_DrawGameUI()
	--UI_GameBanner()
	--UI_DrawGameHeader()
	--UI_DrawGameHeader_Timer()
end

local str_spntext = "GROUP COMBAT; CUSTOM RULES"
local str_spinner = "/-\\|/-" -- animation frames for the on-screen spinner


local int_pregameoff = 1
local int_spnidx = 1
local ltime = 0

function GetSpinner()
	return string.sub(str_spinner, int_spnidx, int_spnidx)
end
function SpinSpinner()
	if(int_spnidx + 1 < 5) then
		int_spnidx = int_spnidx + 1
	else
		int_spnidx = 1
	end
	--return string.sub(str_spinner, int_spnidx, int_spnidx)
end


function UI_DrawGameSpec()
	local str_head = "GAME STARTING"
	local srh = ScrH() /3 /2

	local width, height = surface.GetTextSize( str_head )
	draw.SimpleText("Specification",
		"HBF_HL", 
		ScrW() - ScrW() / 3,
		srh, 
		Color(255,255,255,210))

	local offset = 40
	draw.SimpleText("Gamemode:",
		"Trebuchet24", 
		ScrW() - ScrW() / 3,
		srh + offset * 1, 
		Color(255,255,255,210))

		draw.SimpleText("Gamemode:",
		"Trebuchet24", 
		ScrW() - ScrW() / 3,
		srh + offset * 2, 
		Color(255,255,255,210))

end

function UI_DrawPreGameScreen()
	local str_head = "GAME STARTING"
	local srh = ScrH() /3 /2
	--.. game.GetMap() .. ": Squad Death Match",
	surface.SetFont( "HBF_HX" )
	local width, height = surface.GetTextSize( str_head )
	draw.SimpleText(str_head,
		"HBF_HX", 
		ScrW() /2 - width/2,
		srh, 
		Color(255,255,255,210))

	local len = string.len(str_spntext)
	if(int_pregameoff < len and ltime < CurTime()) then
		int_pregameoff = int_pregameoff +1
		ltime = CurTime() + 0.1
		
		--print("idx: ", int_spnidx, string.sub(str_spntext, 1, int_pregameoff))
	end
	SpinSpinner()
	-- .. SpinSpinner()
	draw.SimpleText(
		string.sub(str_spntext, 1, int_pregameoff) 
		.. ((int_pregameoff < len) and 
			--GetSpinner() 
			-- Don't question it'
			((GetTimeSecondsMOD(1) > 0.8) and " █" or "")
			or ""), 
		
		"HBF_HL", 
		ScrW() /2 - width/2 + 10,
		srh + height, 
		Color(255,255,255,210))
end

function UI_DrawWaitGameScreen()
	local str_head = "GAME PAUSED"
	local srh = ScrH() /3 /2
	--.. game.GetMap() .. ": Squad Death Match",
	surface.SetFont( "HBF_HX" )
	local width, height = surface.GetTextSize( str_head )
	draw.SimpleText(str_head,
		"HBF_HX", 
		ScrW() /2 - width/2,
		srh, 
		Color(255,255,255,210))
	draw.SimpleText("The game was paused\nIf it persists please speak to an admin.", 
		"HBF_HL", 
		ScrW() /2 - width/2 + 10,
		srh + height, 
		Color(255,255,255,210))
end

function UI_DrawWaitGameScreen()

end

function UI_DrawEndScreen()
	local text = "YOUR TEAM "  .. ((GetOurTeam() == GAME.int_winteam) and "WON" or "LOST")
	local srh = ScrH() /3 /2
	surface.SetFont( "HBF_HX" )
	local width, height = surface.GetTextSize( text )

	draw.SimpleText(text, 
		"HBF_HX", 
		ScrW() /2 - width/2,
		srh, 
		Color(255,255,255,210))

	draw.SimpleText(game.GetMap() .. ": Squad Death Match", 
		"HBF_HL", 
		ScrW() /2 - width/2 + 10,
		srh + height, 
		Color(255,255,255,210))
end

function UI_GameBanner()
	
	local text = "YOUR TEAM WON"
	surface.SetFont( "HBF_HM" )
	local width, height = surface.GetTextSize( text )

	-- TODO: Add beziere transformations if it's performance friendly'
	--local extend = 1 / 1 * 
	--CalculateBezierPoint(2 * )
	
	draw.SimpleText(text, 
		"HBF_HM", 
		ScrW() /2 - width/2,
		ScrH() /3, 
		Color(255,255,255,210))
	-- (width /2), 
	--print("W: ", width, "H: ", health)
end

function UI_DrawGameHeader()
	local width = 32
	local xoff = ScrW() /2 - width/2
	for k = 1, 5, 1 do
		draw.RoundedBox( 0, 
		xoff - (32 * k), 
		32, width, 32, team.GetColor(k)
		--Color(37, 37, 37, 210 )
		)
	end
end

function UI_DrawGameHeader_Timer()
	local timecnt;
	--local f = COSFADE(
	--SliceMilli(
	--	CurTime()
	--)
	

	
	local ColorVec--Color(255, 255, 255, 255)
	if( GAME:GameTimerTarget() > CurTime() ) then
		timecnt = math.abs(CurTime() - GAME:GameTimerTarget())
		
		if( GAME:GameTimerTarget() - CurTime() < 60) then
			--print("Timer remainder, Value: ", GAME:GameTimerTarget() - CurTime() )
			-- Calculate expensive cosine fade, consolidate into single value in header
			int_shift = 255 * ((math.cos(CurTime()) + 1) / 2)
			ColorVec =  Color(204 + int_shift, 102 + int_shift, 102 + int_shift, 255)
		else
			ColorVec = Color(255, 255, 255, 255)
		end
	else
		timecnt = 0
		ColorVec = Color(255, 255, 255, 255)
	end
	local width = 300
	local xoff = ScrW() /2 - width/2


	-- ScrW()
	--vec = Color(COSFADE(SliceMilli()), 150, 150)
	--GenerateTimeString(GAME:GameTimerTarget())
	--local t = (), 60))
	--surface.DrawOutlinedRect( ScrW() /2 - 50, 40, 100,  40)

	draw.RoundedBox( 0, xoff, 0, width, 32, Color(37, 37, 37, 210 ))
	draw.SimpleText(
		--string.format( "%.1f", 	
		GenerateTimeString(timecnt) 
		--)`
		, "DermaLarge",
		ScrW() / 2, 0, ColorVec, TEXT_ALIGN_CENTER )
end

INT_NO_BORDERS = 0
local px = 10
local py = 10
local sx = 1.3
local sy = 1.3

function UI_Hud_Right()
	local w = 128 * sx
	local h = 64 * sy
	--surface.DrawTexturedRectRotated( 
	--	ScrW() - w - px, 
	--	ScrH() - h - py, 
	--	w, 
	--	h, 30 )
	draw.RoundedBox(INT_NO_BORDERS, 
		ScrW() - w - px, 
		ScrH() - h - py, 
		w, 
		h, 
		Color(37,37,37,210))

	local health = LocalPlayer():Health()
	draw.RoundedBox(INT_NO_BORDERS, 
		ScrW() - w - 5, 
		ScrH() - 15 - py - 5, 
		-- Scale health bar to parent box
		health * w / 100 - 10, 
		15, 
		Color(210,210,210,255))
	--draw.RoundedBox(INT_NO_BORDERS, 5, ScrH() - 15 - 20, health * 5, 15, Color(255,0,0,255))
	
	draw.SimpleText(health, 
		"HudScoreFont", 
		ScrW() - w - 5, 
		ScrH() - 15 - 40, 
		Color(255,255,255,210))

	local ammo = GetAmmoCount(LocalPlayer():GetActiveWeapon())
	local loaded
	if(LocalPlayer():Alive()) then
		loaded = LocalPlayer():GetActiveWeapon():Clip1()
	else
		loaded = 0
	end
	--print("Ammo", ammo)
	draw.SimpleText(ammo, 
		"HBF_HL",
		ScrW() - px - 100,
		ScrH() - 15 - 40, 
		Color(255,255,255,210))
	
	--print("Ammo", ammo)
	draw.SimpleText((loaded > 0) and loaded or "-", 
		"DermaLarge",
		ScrW() - px - w,
		ScrH() - 15 - 70, 
		Color(255,255,255,210))
end

local CanISee = {}
local ply = FindMetaTable('Player') --so we can add functions to player objects
function ply:OnScreen()
	return CanISee[self].visible, {[x] = CanISee[self].x, [y] = CanISee[self].y}
end
function HUD_Util_BoolToText(In_int_bool)
	return ((In_int_bool) and "[Yes]" or "[No]")
end


local bDrawTextOverlay = false

function HUD_Draw()
	-- Right side
	HUD_DOF_Think()

	__INT_FRAME_TIME = CurTime()
	__INT_DELTA_TIME =  (__INT_FRAME_TIME - __INT_TIME_PREV)
	POST_PROCESS_THINK()

	--SCREENSPACE_COLOR_STATE["$pp_colour_colour"] =  GAME.ui.screenspace.GREYSCALE_MOD
	--if(SCREEN_SCREENSPACE_MOD) then
	--	DrawColorModify( SCREENSPACE_COLOR_STATE )
	--end
	--PrintTable(SCREENSPACE_COLOR_STATE)
	--print( GAME.ui.screenspace.GREYSCALE_MOD )
	bDrawAdminOverlay = true
	local pVec = LocalPlayer():GetPos()
	--CanISee = {} --clear the table so there are no disconnected players involved
	for k, v in pairs( ents.GetAll() ) do
		if((v:IsPlayer() or v:IsNPC()) and v:Health() > 0) then
			local vec = v:GetPos()
			local vDistance = pVec:Distance( vec )
			if(vDistance > 0  and vDistance < CONST_INT_HUD_OVERLAY_RANGEZFAR) then
				--LocalPlayer():SetEyeAngles(	(vec - LocalPlayer:GetPos() ):Angle() )
				local TNvec = ( vec - pVec )--:Normalize()
				local Tang = TNvec:Angle()
				local vScreen = vec:ToScreen()
				vScreen = vec:ToScreen()
				--if(Tang.y > 10 and Tang.y < 180) then
				if(bDrawAdminOverlay and vScreen.visible) then

					vColor = team.GetColor( v:Team() )
					surface.SetDrawColor(vColor)
					--surface.SetDrawColor( 0, 140, 255, 255 )
					--surface.DrawLine( ScrW() / 2, ScrH(), vec.x, vec.y)
					local triangle = {
						{ x = ScrW()/2 - CONST_INT_HUD_LINE_WIDTH, y = ScrH() - CONST_INT_HUD_LINE_WIDTH},
						{ x = ScrW()/2 + CONST_INT_HUD_LINE_WIDTH, y = ScrH() + CONST_INT_HUD_LINE_WIDTH},
						{ x = vScreen.x - CONST_INT_HUD_LINE_WIDTH, y = vScreen.y - CONST_INT_HUD_LINE_WIDTH},
						{ x = vScreen.x + CONST_INT_HUD_LINE_WIDTH, y = vScreen.y + CONST_INT_HUD_LINE_WIDTH}
					}
					surface.DrawPoly( triangle )
				end

				vec:Add(Vector(0, 0, 75))
				vScreen = vec:ToScreen()
				local tr = util.GetPlayerTrace( LocalPlayer() )
				local scale = (CONST_INT_HUD_OVERLAY_RANGEZFAR / vDistance ) / 15
				local xoff = vScreen.x - (62 * scale)
				local yoff = vScreen.y
				local height = (15 * scale)
				local len = 100 * scale * CONST_INT_HUD_ENT_HEALTH_SCALE

				surface.SetDrawColor( ((v:Health() > CONST_INT_HEALTH_CLIP_LIMIT) and 231 or 255 ), ((v:Health() > CONST_INT_HEALTH_CLIP_LIMIT) and 255 or 0), 0, 255 )
				surface.DrawRect( xoff , yoff, (v:Health() * scale) * CONST_INT_HUD_ENT_HEALTH_SCALE, height)
				
				if(v:IsPlayer()) then
					if(v:IsAdmin()) then
						draw.SimpleText("Admin", "ChatFont", vScreen.x - 50 * scale,vScreen.y, Color(255,255,255,210))
					end
					surface.SetDrawColor( ((v:Armor() > CONST_INT_HEALTH_CLIP_LIMIT) and 0 or 255 ), ((v:Armor() > CONST_INT_HEALTH_CLIP_LIMIT) and 255 or 0), 0, 255 )
					surface.DrawRect( xoff , yoff - height, (v:Armor() * scale) * CONST_INT_HUD_ENT_HEALTH_SCALE, height)
				end

				if(v:IsBot()) then
					draw.SimpleText("Bot", "ChatFont", vScreen.x - 50 * scale,vScreen.y, Color(255,255,255,210))
				end

				if(bDrawAdminOverlay and bDrawTextOverlay) then
					draw.SimpleText(v:Nick() .. " H[" .. v:Health() .. "] A[" .. v:Armor() .. "]", "ChatFont", vScreen.x - 50 * scale,vScreen.y, Color(255,255,255,210))
					draw.SimpleText("NPC: " .. HUD_Util_BoolToText(v:IsNPC()), "ChatFont", vScreen.x - 50 * scale, vScreen.y - 20, Color(100,255,255,210))
					draw.SimpleText("Player: ".. HUD_Util_BoolToText(v:IsPlayer()),"ChatFont",vScreen.x - 50 * scale,vScreen.y - 40, Color(255,200,255,210))
					draw.SimpleText("Muted? : ".. HUD_Util_BoolToText(v:IsMuted()),"ChatFont",vScreen.x - 50 * scale,vScreen.y - 60, Color(255,200,255,210))
					draw.SimpleText("Speaking? : ".. HUD_Util_BoolToText(v:IsSpeaking()),"ChatFont",vScreen.x - 50 * scale,vScreen.y - 80, Color(255,200,255,210))
					draw.SimpleText( "Ping: " ..v:Ping(),"ChatFont",vScreen.x - 50 * scale,vScreen.y - 100, Color(255,200,255,210))
					draw.SimpleText( "Team: " ..v:Team(),"ChatFont",vScreen.x - 50 * scale,vScreen.y - 120, Color(255,200,255,210))
				end
				--draw.SimpleText(" ++ Stats: ", "ChatFont",vScreen.x - 50 * scale, vScreen.y - 100, Color(255,200,255,210))
				--surface.SetDrawColor( 255, 255, 255, 255 )
				--surface.DrawRect( vec.x - 10 , vec.y - 10, (CONST_INT_STANDARD_HEALTH * scale) * CONST_INT_HUD_ENT_HEALTH_SCALE + 10, (25 * scale) + 10)
				--- ( 20 * scale /2)
				--print("Distance: ", vDistance, "Adjust: ", scale)
				--surface.SetDrawColor( 100, 100, 100, 255 )
				--surface.DrawRect( xoff - 5, yoff - height - 5, len + 10, height * 2 + 10)
				--surface.DrawRect( vec.x - 5 - (62 * scale), vec.y - 5, (v:Health() * scale) * CONST_INT_HUD_ENT_HEALTH_SCALE, (15 * scale))
				--surface.SetDrawColor( 150, 10, 100, 255 )
				--surface.DrawRect( vec.x + 25 - 20 * scale, vec.y - 5, (100 - v:Armor() * scale) * CONST_INT_HUD_ENT_HEALTH_SCALE, (15 * scale))
			end
			-- End of brace
		end
	end

	--for _, v in pairs( ents.GetAll() ) do
	--	if v:IsNPC() then 
		
		
		
	--	end
	--end

	--UI_DrawGameSpec()
	UI_Draw_NDA_USER()
	--PrintTable(GAME)
	--if( GAME.ui.bDrawWarningState) then
		--UI_Warning_ChangeState(1, 0)
	--end
		
	--if(GAME.ui.bDrawTerminalClear) then
	--	UI_Draw_Terminal()
	--	return
--	end

--	if ( GAME.ui.bDraw_GameNotice ) then
		UI_GameBanner()
--	end
--	if ( GAME.ui.bDrawRightHud ) then
		--UI_Hud_Right()
	--end

	--UI_Draw3D_Hud_SquadBar()
	--RenderCustom()
	--UI_Draw()
	--UI_DrawWarningNoBase()
	
	UI_DrawTeamHigherachy()
	UI_Draw_Hud_SquadBar()
	--UI_DrawGameHeader_Timer()

	if(GAME.int_gamestate == 0 ) then -- Wait
	elseif(GAME.int_gamestate == 1) then -- Pregame
		UI_DrawPreGameScreen()

		
	elseif(GAME.int_gamestate == 2) then -- Game
		int_spnidx = 0

		
	elseif(GAME.int_gamestate == 3) then -- Post
		--print(GAME.ui.bDrawBigScroll)
		--if(GAME.ui.bDrawBigScroll) then
			--DrawBanner("Congratulations")
		--end
	end
	--UI_GameBanner()
	--UI_DrawGameHeader()
	--__INT_TIME_PREV = __INT_FRAME_TIME --CurTime()
	__INT_TIME_PREV = __INT_FRAME_TIME
end

-- Completely remove HL2 Hud
function hidehud(name)
	for k, v in pairs(
	{
	"CHudHealth", 
	"CHudBattery",
	"CHudAmmo",
	"CHudSecondaryAmmo",
	"CHudBattery",
	--"CHudChat",
	--"CHudWeaponSelection"
	})do
		if name == v then return false end
	end
end

hook.Add("HUDPaint", "ShowServerHud", HUD_Draw) -- I'll explain hooks and functions in a second
hook.Add("HUDShouldDraw", "RemoveHud", hidehud)

int_cnt = 0
function GM:PlayerSwitchWeapon(player, oldWeapon, newWeapon)
	--print("Switched wep")
	--newWeapon.GetPrintName()

	int_cnt = int_cnt +1
	print(player:Nick() .. "Changed " .. int_cnt .. " Times")

	--fbuffer:PrintTable()
	--icon:SetModel( newWeapon:GetModel() )
	--print("Ent: ", icon:GetEntity()) --GetMaxClip1
end
--]]