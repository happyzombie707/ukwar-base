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
    local DComboBox_Class = vgui.Create( "DComboBox", Frame )
    local DButton = vgui.Create("DButton", Frame)

    --Initialise frame
    Frame:SetSize( 500, 300 )
    Frame:Center()
    Frame:SetTitle( "Change Team" )
    Frame:SetVisible( true )
    Frame:SetDraggable( false )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()
    
    --Initialise team combobox
    DComboBox_Team:SetPos(5,15)
    DComboBox_Team:SetSize( 150, 20 )
    DComboBox_Team:SetValue( teams[1] )   --set current team in the combo box to the players current team
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
    DComboBox_Class:SetPos(5,40)
    DComboBox_Class:SetSize( 150, 20 )
    DComboBox_Class:SetValue("Pick a class")
    DComboBox_Class:AddChoice( "I" )
    DComboBox_Class:AddChoice( "Like" )
    DComboBox_Class:AddChoice( "Memes" )
    

    --submit button
    DButton:SetSize(100,20)
    DButton:SetPos(5, 65)
    DButton:SetText("Spawn")
    DButton.DoClick = function()
        net.Start("ChangeTeam") 
        net.WriteUInt(team_nums[DComboBox_Team:GetValue()], 4)  --Send chosen team to the server
        net.SendToServer()
        Frame:Close()
    end

end