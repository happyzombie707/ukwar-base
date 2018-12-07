local squad_width = ScrW() * 0.15
local squad_height = ScrH() * 0.3

local health_height = ScrH() * 0.05
local health_width = ScrW() * 0.45

local armour_height = health_height
local armour_width = health_width

local weapon_height = health_height
local weapon_width = ScrW() * 0.15


function HUD_Health_BG()
    surface.SetDrawColor(255, 0, 0, 150)
    surface.DrawRect(0, ScrH() - health_height, health_width, health_height)

end

function HUD_Armour_BG()
    surface.SetDrawColor(255, 255, 0, 150)
    surface.DrawRect(ScrW() - armour_width, ScrH() - armour_height, armour_width, armour_height)
end

function HUD_Info_BG()
    surface.SetDrawColor(0, 255, 0, 150)
    surface.DrawRect(ScrW() - weapon_width, ScrH() - health_height - weapon_height, weapon_width, weapon_height)
end

function HUD_Squad_BG()
    surface.SetDrawColor(0, 255, 255, 150)
    surface.DrawRect(0, ScrH() - health_height - squad_height, squad_width, squad_height)
end
