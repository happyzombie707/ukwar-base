local teams = {
    [1] = "Red",
    [2] = "Blue",
   -- [3] = "Free"
}

local loadout_nums = {
    ["Light"] = 1,
    ["Medium"] = 2,
    ["Heavy"] = 3
}

local button_colours = {
  ["Red"] = {
    [1] = Color( 249, 47, 47 ),
    [2] = Color( 239, 100, 100 ),
    [3] = Color( 124, 80, 80 ),
  },
  ["Blue"] = {
    [1] = Color(0, 162, 232),
    [2] = Color( 70, 205, 244 ),
    [3] = Color( 87, 120, 138 ),
  },
}

--[[
    Name: ShowTeamMenu(int team)
    Desc: Creates and displays team selection menu
    Args: int team - player's current team
]]
function ShowTeamMenu(team)

    --Create panel elements
    local Frame = vgui.Create( "DFrame" )
    local DComboBox_Class = vgui.Create( "DComboBox", Frame )
    local DButton_Red = vgui.Create("DButton", Frame)
    local DButton_Blue = vgui.Create("DButton", Frame)

    --Initialise frame
    Frame:SetSize( 500, 400 )
    Frame:Center()
    Frame:SetTitle( "Change Team" )
    Frame:SetVisible( true )
    Frame:SetDraggable( false )
    Frame:ShowCloseButton( false )
    Frame:MakePopup()
    function Frame:Paint(w, h)

      draw.RoundedBox( 0, 0, 0, w, h, Color( 37, 37, 37, 210 ) )
    end

    --Initialise class combobox
    DComboBox_Class:SetSize( 300, 43 )
    DComboBox_Class:Center()
    DComboBox_Class:SetPos(DComboBox_Class:GetPos(), 295)
    DComboBox_Class:SetValue( "Select Class" )   --set current team in the combo box to the players current team
    for k, v in pairs(loadout.GetAllLoadouts()) do
      DComboBox_Class:AddChoice(v.Name)
    end
    DComboBox_Class.OnSelect = function()

    end


    --Initialise red team button
    DButton_Red.CurrentColour = 1
    DButton_Red:SetSize(200,200)
    DButton_Red:SetPos(33, 33)
    DButton_Red:SetText("Red")
    DButton_Red:SetTextColor(Color(255,255,255))
    DButton_Red:SetFont("Trebuchet24")
    DButton_Red.DoClick = function()
        net.Start("ChangeTeam")
        net.WriteUInt(1, 4)  --Send chosen team to the server
        net.WriteUInt(loadout_nums[DComboBox_Class:GetText()], 4)
        net.SendToServer()
        Frame:Close()
    end
    DButton_Red.OnCursorEntered = function()
      DButton_Red.CurrentColour = 2
    end
    DButton_Red.OnCursorExited = function()
      DButton_Red.CurrentColour = 1
    end
    DButton_Red.Paint = function(self, w, h)
      draw.RoundedBox( 5, 0, 0, w, h, button_colours["Red"][DButton_Red.CurrentColour])
    end

    --Initialise red team button
    DButton_Blue.CurrentColour = 1
    DButton_Blue:SetSize(200,200)
    DButton_Blue:SetPos(266, 33)
    DButton_Blue:SetText("Blue")
    DButton_Blue:SetTextColor(Color(255,255,255))
    DButton_Blue:SetFont("Trebuchet24")
    DButton_Blue.DoClick = function()
      net.Start("ChangeTeam")
      net.WriteUInt(2, 4)  --Send chosen team to the server
      net.WriteUInt(loadout_nums[DComboBox_Class:GetText()], 4)
      net.SendToServer()
      Frame:Close()
    end
    DButton_Blue.OnCursorEntered = function()
      DButton_Blue.CurrentColour = 2
    end
    DButton_Blue.OnCursorExited = function()
      DButton_Blue.CurrentColour = 1
    end
    DButton_Blue.Paint = function(self, w, h)
      draw.RoundedBox( 5, 0, 0, w, h, button_colours["Blue"][DButton_Blue.CurrentColour])
    end
end
