local meta = FindMetaTable( "Player" )

if (not meta) then return end

w_PlayerLoadouts = {}
w_DefaultLoadout = {Name = "Error", Primary="weapon_crowbar", Secondary="weapon_crowbar", Melee="weapon_crowbar", MaxHealth=150, StartingArmour=0, Speed= 50}

--get players loadout by id
function meta:W_GetLoadout( id )
    if (self:IsBot()) then return w_DefaultLoadout end
    return w_PlayerLoadouts[self:UniqueID()][id] or w_DefaultLoadout
end

--get all loadouts for a player
function meta:W_AllLoadouts()
    if (self:IsBot()) then return {w_DefaultLoadout} end
    return w_PlayerLoadouts[self:UniqueID()] or {}
end

--add loadout to players list
function meta:W_AddLoadout( loadout_table )
    if (self:IsBot()) then return end
    local key = self:UniqueID()
     w_PlayerLoadouts[key] = w_PlayerLoadouts[key] or {}

    w_PlayerLoadouts[key][ #w_PlayerLoadouts[key] +1 ] = loadout_table

end
