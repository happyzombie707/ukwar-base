--[[
    Class for blue team spawn point
    TODO: add and inherit from spawn_base
    most of this is not final, the final spawn will not have a model etc
]]
AddCSLuaFile()
DEFINE_BASECLASS( "base_entity" )

ENT.PrintName = "Team Spawn Point"
ENT.Spawnable = true
ENT.Type = "anim"
ENT.TeamId = 0

function ENT:Initialize()

	if ( CLIENT ) then return end

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetRenderMode( RENDERMODE_NORMAL )
  self:SetModel( "models/props_borealis/bluebarrel001.mdl" )
    --self:SetColor( Color( 250, 50, 50 ))

end

function ENT:Team()
	return self.TeamId
end

function ENT:SetTeam( id )
	self.TeamId = tonumber(id)
	if self:Team() > -1 then
        self:SetColor( team.GetColor(self.TeamId) )
    else
        self:SetColor(Color(255, 255, 255))
    end
end

function ENT:Draw()
    self:DrawModel()
end
