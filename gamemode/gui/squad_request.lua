net.Receive ("DisplayRequest", function ()

    local ply_sender = player.GetBySteamID(net.ReadString())
    local team_id = ply_sender:Team()
    local squad_alias = net.ReadString()

    --Create panel elements
    local Frame = vgui.Create( "DFrame" )
    local DLabel_Message = vgui.Create("DLabel", Frame)
    local DButton_Accept = vgui.Create("DButton", Frame)
    local DButton_Deny = vgui.Create("DButton", Frame)

    Frame:SetSize(400, 100)
    Frame:Center()
    Frame:SetTitle( "Squad request.." )
    Frame:SetVisible( true )
    Frame:SetDraggable( true )
    Frame:ShowCloseButton( false )
    Frame:MakePopup()

    DLabel_Message:SetText(ply_sender:GetName() .. " invites you to join " .. squad_alias .. ".")
    DLabel_Message:SetPos(30, 30)
    DLabel_Message:SetSize(340, 40)
    DLabel_Message:SetMultiline()

    DButton_Accept:SetSize(75, 20)
    DButton_Accept:SetText("Accept")
    DButton_Accept:SetPos(100, 70)
    DButton_Accept.DoClick = function()
        Frame:SetVisible(false)
        net.Start("AcceptInvite")
        net.WriteBool(true)
        net.SendToServer()
    end

    DButton_Deny:SetSize(75, 20)
    DButton_Deny:SetText("Deny")
    DButton_Deny:SetPos(225, 70)
    DButton_Deny.DoClick = function()
        Frame:SetVisible(false)
        net.Start("AcceptInvite")
        net.WriteBool(false)
        net.SendToServer()
    end


end)
