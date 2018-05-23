--AddCSLuaFile()

loadout = {}


--loadout[0].LoadoutInfo[0] = { Name = "Default", 	Melee = "", Secondary = "", 	Primary = "", MaxHealth = 100, StartingArmour = 0, Speed = 400, SpecialPurpose = true}
--loadout[0].LoadoutInfo = { Name = "Light", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_m3s90", MaxHealth = 75, StartingArmour = 0, Speed = 300, SpecialPurpose = false}
--loadout[0].LoadoutInfo[2] = { Name = "Medium", 	Melee = "weapon_crowbar", Secondary = "fas2_glock20", 	Primary = "fas2_g3", MaxHealth = 100, StartingArmour = 25, Speed = 200, SpecialPurpose = false}
--loadout[0].LoadoutInfo[3] = { Name = "Heavy", 	Melee = "weapon_crowbar", Secondary = "fas2_ragingbull", 	Primary = "fas2_rpk", MaxHealth = 125, StartingArmour = 50, Speed = 150, SpecialPurpose = false}

loadout.Create = function(name, primary, secondary, melee, health, armour )
    return {Name = name, Primary=primary, Secondary=secondary, Melee=melee, MaxHealth=health, StartingArmour=armour, Speed= 400, }
end

loadout.GetName = function(table_loadout)
  return table_loadout.Name
end

loadout.GetMelee = function(table_loadout)
  return table_loadout.Melee
end

loadout.GetSecondary = function(table_loadout)
  return table_loadout.Secondary
end

loadout.GetPrimary = function(table_loadout)
  return table_loadout.Primary
end

loadout.GetWeapons = function(table_loadout)
  return {table_loadout.Melee, table_loadout.Secondary, table_loadout.Primary}
end

loadout.GetMaxHealth = function(table_loadout)
  return table_loadout.MaxHealth
end

loadout.GetStartingArmour = function(table_loadout)
  return table_loadout.StartingArmour
end

loadout.GetSpeed = function(table_loadout)
    print("XD " .. table_loadout.Speed)
  return table_loadout.Speed
end

loadout.Valid = function( table_loadout , str_steam_id )
  print (table_loadout)
  //if (table.HasValue(table_loadout, loadout["default"])) then return true end
  return false
end
