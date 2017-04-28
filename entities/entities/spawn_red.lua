--[[
    Class for blue team spawn point
    TODO: add and inherit from spawn_base
    most of this is not final, the final spawn will not have a model etc
]]
AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

ENT.PrintName = "Red Spawn Point"
ENT.Spawnable = true
ENT.Type = "anim"


function ENT:Initialize()

	if ( CLIENT ) then return end

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_NORMAL )
    self:SetModel( "models/props_borealis/bluebarrel001.mdl" )
    self:SetColor( Color(255, 0, 0))
end

function ENT:Draw()
    self:DrawModel()
end