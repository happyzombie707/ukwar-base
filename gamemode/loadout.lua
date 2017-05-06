AddCSLuaFile()

loadout = {}

loadout.LoadoutInfo = {}

loadout.LoadoutInfo[0] = { Name = "Default", 	Melee = "", Secondary = "", 	Primary = "", MaxHealth = 100, StartingArmour = 0, Speed = 400, SpecialPurpose = true}
loadout.LoadoutInfo[1] = { Name = "Light", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_m3s90", MaxHealth = 75, StartingArmour = 0, Speed = 300, SpecialPurpose = false}
loadout.LoadoutInfo[2] = { Name = "Medium", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_g3", MaxHealth = 100, StartingArmour = 25, Speed = 200, SpecialPurpose = false}
loadout.LoadoutInfo[3] = { Name = "Heavy", 	Melee = "weapon_crowbar", Secondary = "fas2_ragingbull", 	Primary = "fas2_rpk", MaxHealth = 125, StartingArmour = 50, Speed = 150, SpecialPurpose = false}

loadout.GetName = function(int_id)
  return loadout.LoadoutInfo[int_id].Name
end

loadout.GetAllLoadouts = function()
  return loadout.LoadoutInfo
end

loadout.GetMelee = function(int_id)
  return loadout.LoadoutInfo[int_id].Melee
end

loadout.GetSecondary = function(int_id)
  return loadout.LoadoutInfo[int_id].Secndary
end

loadout.GetPrimary = function(int_id)
  return loadout.LoadoutInfo[int_id].Primary
end

loadout.GetWeapons = function(int_id)
  return {loadout.LoadoutInfo[int_id].Melee, loadout.LoadoutInfo[int_id].Secondary, loadout.LoadoutInfo[int_id].Primary}
end

loadout.GetMaxHealth = function(int_id)
  return loadout.LoadoutInfo[int_id].MaxHealth
end

loadout.GetStartingArmour = function(int_id)
  return loadout.LoadoutInfo[int_id].StartingArmour
end

loadout.GetSpeed = function(int_id)
    print("XD " .. loadout.LoadoutInfo[int_id].Speed)
  return loadout.LoadoutInfo[int_id].Speed
end

loadout.SetUp = function(int_id, str_name, str_melee, str_secondary, str_primary, int_h_max, int_a_max, int_speed, bool_special)
  if(bool_special == nil) then bool_special = false end
  loadout.LoadoutInfo[int_id] = {Name = str_name, Melee = str_melee, Secondary = str_secondary, Primary = str_primary, MaxHealth = int_h_max, MaxArmour = int_a_max, Speed = int_speed, SpecialPurpose = bool_special}
  print (#loadout.LoadoutInfo)
end

loadout.Valid = function( int_id )
  if (!loadout.LoadoutInfo[int_id]) then return false end
  if (loadout.LoadoutInfo[int_id].SpecialPurpose) then return false end

  return true
end
