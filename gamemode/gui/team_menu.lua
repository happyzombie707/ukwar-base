
--begin net message
net.Receive("ShowTeamMenu", function()

    --get player
    local ply = LocalPlayer()

    --if not player return
    if (not ply:IsPlayer()) then return end

    --read net data
    local lod = net.ReadTable()
    PrintTable(lod)
    local squad_id = net.ReadUInt(6)
    local squad_alias = net.ReadString()
    local current_loadout = net.ReadInt(4)
    local has_spawn = net.ReadBool()
    local model = ply:GetModel()
    local colour = team.GetColor(ply:Team())

    --setup frame
    local Frame = vgui.Create("DFrame")
    Frame:SetSize( 650, 400 )
    Frame:Center()
    Frame:SetTitle( "Change Squad" )
    Frame:SetVisible( true )
    Frame:SetDraggable( false )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()
    Frame.OnClose = function()
        UpdatePlayer(false, false, false)
    end

    --create all form items
    local DCheckBox_SSpawn = vgui.Create("DCheckBoxLabel", Frame)
    local DComboBox_Model = vgui.Create("DComboBox", Frame)
    local DComboBox_Loadout = vgui.Create("DComboBox", Frame)
    local DListView_Members = vgui.Create("DListView", Frame)
    local DButton_Leave = vgui.Create("DButton", Frame)
    local DButton_Respawn = vgui.Create("DButton", Frame)
    local DTextEntry_SquadName = vgui.Create("DTextEntry", Frame)
    local DComboBox_Players = vgui.Create("DComboBox", Frame)
    local DButton_Invite = vgui.Create("DButton", Frame)
    local DColorCombo_SquadColour = vgui.Create("DColorCombo", Frame)
    local DButton_SaveSquad = vgui.Create( "DButton", Frame )


    --function called to send player info to server
    function UpdatePlayer(leave, respawn, silent)
        net.Start("UpdatePlayer")
        net.WriteBool(leave)    --leaving squad?
        net.WriteBool(respawn)  --respawning?
        net.WriteBool(silent)   --should respawn be silent?
        net.WriteBool(DCheckBox_SSpawn:GetChecked())    --squad spawn
        net.WriteString(DComboBox_Model:GetSelected() or model)  --model
        _, id = DComboBox_Loadout:GetSelected() --get loadout id
        net.WriteInt(id, 4)
        net.SendToServer()  --send
    end

    --set up spawn checkbox
    DCheckBox_SSpawn:SetPos(50, 350)
    DCheckBox_SSpawn:SetValue(ply:GetNWBool("squad_spawn"))
    DCheckBox_SSpawn:SetText("Spawn at squad spawn?")
    DCheckBox_SSpawn:SizeToContents()
    DCheckBox_SSpawn:SetEnabled(has_spawn)

    --set up model combobox
    DComboBox_Model:SetSize(175, 20)
    DComboBox_Model:SetPos(275, 50)
    DComboBox_Model:SetValue(model)
    for k, v in pairs(player_manager.AllValidModels()) do
        DComboBox_Model:AddChoice(v, nil, ply:GetModel() == v)
    end

    --setup loadout combobox
    DComboBox_Loadout:SetSize(175, 20)
    DComboBox_Loadout:SetPos(275, 90)
    DComboBox_Loadout:SetValue("Loadout")
    for k, v in pairs(lod) do
        print(current_loadout)
        DComboBox_Loadout:AddChoice(v.name, v.id, v.id == current_loadout)
    end

    --set up squad list view
    DListView_Members:SetSize(175, 100)
    DListView_Members:SetPos(275, 130)
    DListView_Members:AddColumn("Squad")
    for _, v in pairs(team.GetPlayers(ply:Team())) do
        DListView_Members:AddLine(v:GetName())
    end

    --set up leave squad button
    DButton_Leave:SetSize(75, 20)
    DButton_Leave:SetPos(275, 250)
    DButton_Leave:SetText("Leave")
    DButton_Leave.DoClick = function()
        UpdatePlayer(true, true, true)
    end

    --set up respawn button
    DButton_Respawn:SetSize(75, 20)
    DButton_Respawn:SetPos(375, 250)
    DButton_Respawn:SetText("Respawn")
    DButton_Respawn.DoClick = function()
        Frame:SetVisible(false)
        UpdatePlayer(false, true, false)
    end

    --set up squad name textbox
    DTextEntry_SquadName:SetSize(100, 20)
    DTextEntry_SquadName:SetPos(500, 50)
    DTextEntry_SquadName:SetText(squad_alias)

    --set up player combobox
    DComboBox_Players:SetSize(100, 20)
    DComboBox_Players:SetPos(500, 90)
    DComboBox_Players:SetValue("Invite...")
    for _, v in pairs(player.GetAll()) do
        DComboBox_Players:AddChoice(v:GetName(), v:SteamID())
    end

    --setup invite button
    DButton_Invite:SetSize(50, 20)
    DButton_Invite:SetPos(525, 130)
    DButton_Invite:SetText("Invite")
    DButton_Invite.DoClick = function()
        local name, ssquad_id = DComboBox_Players:GetSelected()

        net.Start("InvitePlayer")
        net.WriteString(ssquad_id)
        net.SendToServer()
    end

    --setup squad colour Combo
    DColorCombo_SquadColour:SetSize(100, 100)
    DColorCombo_SquadColour:SetPos(500, 160)
    DColorCombo_SquadColour:SetColor(team.GetColor(ply:Team()))


    --setup squad save button
    DButton_SaveSquad:SetSize(50, 20)
    DButton_SaveSquad:SetPos(525, 230)
    DButton_SaveSquad:SetText("Save")
    DButton_SaveSquad.DoClick = function()
        net.Start("UpdateSquad")
        local col = Color(DColorCombo_SquadColour:GetColor().r, DColorCombo_SquadColour:GetColor().g, DColorCombo_SquadColour:GetColor().b )
        net.WriteColor(col)
        net.WriteString(DTextEntry_SquadName:GetText())
        net.SendToServer()

    end



end)
