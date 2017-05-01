module("loadout", package.seeall)

LoadoutInfo = {}

LoadoutInfo[0] 	= { Name = "Default", 	Melee = "", Secondary = "", 	Primary = "", MaxHealth = 100, StartingArmour = 0, Speed = 400}
LoadoutInfo[1] 	= { Name = "Light", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_m3s90", MaxHealth = 75, StartingArmour = 0, Speed = 300}
LoadoutInfo[2] 	= { Name = "Medium", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_g3", MaxHealth = 100, StartingArmour = 25, Speed = 200}
LoadoutInfo[3] 	= { Name = "Heavy", 	Melee = "weapon_crowbar", Secondary = "fas2_ragingbull", 	Primary = "fas2_rpk", MaxHealth = 125, StartingArmour = 50, Speed = 150}

function GetName(int_id)
  return LoadoutInfo[int_id].Name
end

function GetAllLoadouts()
  return LoadoutInfo
end

function GetWeapons(int_id)
  return {LoadoutInfo[int_id].Melee, LoadoutInfo[int_id].Secondary, LoadoutInfo[int_id].Primary}
end

function GetMaxHealth(int_id)
  return LoadoutInfo[int_id].MaxHealth
end

function GetStartingArmour(int_id)
  return LoadoutInfo[int_id].StartingArmour
end

function GetSpeed(int_id)
  return LoadoutInfo[int_id].Speed
end

function SetUp(int_id, str_name, str_melee, str_secondary, str_primary, int_h_max, int_a_max, int_speed)
  LoadoutInfo[int_id] = {Name = str_name, Melee = str_melee, Secondary = str_secondary, Primary = str_primary, MaxHealth = int_h_max, MaxArmour = int_a_max, Speed = int_speed}
end

function x()

end

function Valid( loadout_id ) end
