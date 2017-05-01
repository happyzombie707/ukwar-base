module("loadout", package.seeall)

LoadoutInfo = {}

LoadoutInfo[0] 	= { Name = "Default", 	Melee = "", Secondary = "", 	Primary = "", MaxHealth = 100, StartingArmour = 0, Speed = 400, SpecialPurpose = true}
LoadoutInfo[1] 	= { Name = "Light", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_m3s90", MaxHealth = 75, StartingArmour = 0, Speed = 300, SpecialPurpose = false}
LoadoutInfo[2] 	= { Name = "Medium", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_g3", MaxHealth = 100, StartingArmour = 25, Speed = 200, SpecialPurpose = false}
LoadoutInfo[3] 	= { Name = "Heavy", 	Melee = "weapon_crowbar", Secondary = "fas2_ragingbull", 	Primary = "fas2_rpk", MaxHealth = 125, StartingArmour = 50, Speed = 150, SpecialPurpose = false}

function GetName(int_id)
  return LoadoutInfo[int_id].Name
end

function GetAllLoadouts()
  return LoadoutInfo
end

function GetMelee(int_id)

end

function GetSecondary(int_id)

end

function GetPrimary(int_id)
  return LoadoutInfo[int_id].Primary
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

function SetUp(int_id, str_name, str_melee, str_secondary, str_primary, int_h_max, int_a_max, int_speed, bool_special)
  if(bool_special == nil) then bool_special = false end
  LoadoutInfo[int_id] = {Name = str_name, Melee = str_melee, Secondary = str_secondary, Primary = str_primary, MaxHealth = int_h_max, MaxArmour = int_a_max, Speed = int_speed, SpecialPurpose = bool_special}
end

function x()
  print ("meep")
end

function Valid( int_id )
  if (!LoadoutInfo[int_id]) then return false end
  if (LoadoutInfo[int_id].SpecialPurpose) then return false end

  return true
end
