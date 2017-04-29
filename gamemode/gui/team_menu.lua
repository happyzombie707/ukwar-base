local teams = {
    [1] = "Red",
    [2] = "Blue",
   -- [3] = "Free"
}

local team_nums = {
    ["Red"] = 1,
    ["Blue"] = 2,
    --["Free"] = 3
}

--[[
    Name: ShowTeamMenu(int team)
    Desc: Creates and displays team selection menu
    Args: int team - player's current team
]]
function ShowTeamMenu(team)

    --Create panel elements
    local Frame = vgui.Create( "DFrame" )
    local DComboBox_Team = vgui.Create( "DComboBox", Frame )
    --local DComboBox_Class = vgui.Create( "DComboBox", Frame )
    local DButton = vgui.Create("DButton", Frame)

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

    --Initialise team combobox
    DComboBox_Team:SetSize( 300, 43 )
    DComboBox_Team:Center()
    x = DComboBox_Team:GetPos()
    DComboBox_Team:SetPos(DComboBox_Team:GetPos(), 295)
    DComboBox_Team:SetValue( "Select Class" )   --set current team in the combo box to the players current team
    DComboBox_Team:AddChoice( "Red" )
    DComboBox_Team:AddChoice( "Blue" )
    --DComboBox_Team:AddChoice( "Free" )
    DComboBox_Team.OnSelect = function()
        if(LocalPlayer():Team() == team_nums[DComboBox_Team:GetValue()]) then
            DButton:SetEnabled(false)
        else
            DButton:SetEnabled(true)
        end
    end

    --Initialise class combobox
    --[[DComboBox_Class:SetPos(5,40)
    DComboBox_Class:SetSize( 150, 20 )
    DComboBox_Class:SetValue("Pick a class")
    DComboBox_Class:AddChoice( "I" )
    DComboBox_Class:AddChoice( "Like" )
    DComboBox_Class:AddChoice( "Memes" )]]


    --submit button
    DButton:SetSize(200,200)
    DButton:SetPos(33, 33)
    DButton:SetText("Red")
    DButton:SetTextColor(Color(255,255,255))
    DButton:SetFont("Trebuchet24")
    DButton.DoClick = function()
        net.Start("ChangeTeam")
        net.WriteUInt(team_nums[DComboBox_Team:GetValue()], 4)  --Send chosen team to the server
        net.SendToServer()
        Frame:Close()
    end
    function DButton:Paint(w, h)
      draw.RoundedBox( 0, 0, 0, w, h, Color( 249, 47, 47 ) )
    end

    Meme = vgui.Create("DButton", Frame)
    Meme:SetSize(200,200)
    Meme:SetPos(266, 33)
    Meme:SetTextColor(Color(255,255,255))
    Meme:SetText("Blue")
    Meme:SetFont("Trebuchet24")
    function Meme:Paint(w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 162, 232))
  end
end
