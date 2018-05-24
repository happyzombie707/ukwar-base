net.Receive( "ShowLoadoutAdmin", function ()

    if(not LocalPlayer():IsPlayer()) then return end

    local cached_loadouts = {}

    --local

    --Create panel elements
    local Frame = vgui.Create( "DFrame" )
    local DTextEntry_Name = vgui.Create( "DTextEntry", Frame )
    local DComboBox_Primary = vgui.Create( "DComboBox", Frame )
    local DComboBox_Secondary = vgui.Create( "DComboBox", Frame )
    local DComboBox_Melee = vgui.Create( "DComboBox", Frame )
    local DNumberWang_Health = vgui.Create( "DNumberWang", Frame )
    local DNumberWang_Armour = vgui.Create( "DNumberWang", Frame )
    local DLabel_Weight = vgui.Create( "DLabel", Frame )
    local DLabel_Speed = vgui.Create( "DLabel", Frame )
    local DButton_Add = vgui.Create( "DButton", Frame )
    local DListView_Loadouts = vgui.Create( "DListView", Frame )

    --Initialise frame
    Frame:SetSize( 500, 400 )
    Frame:Center()
    Frame:SetTitle( "Customise Loadouts" )
    Frame:SetVisible( true )
    Frame:SetDraggable( false )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()


    --init name entry
    DTextEntry_Name:SetSize(150, 20)
    DTextEntry_Name:SetPos(75, 50)
    DTextEntry_Name:SetText("Name")
    --init primary box
    DComboBox_Primary:SetSize(150, 20)
    DComboBox_Primary:SetPos(275, 50)
    DComboBox_Primary:SetText("Primary")
    --init secondary
    DComboBox_Secondary:SetSize(150, 20)
    DComboBox_Secondary:SetPos(75, 95)
    DComboBox_Secondary:SetValue("Secondary")
    --init melee
    DComboBox_Melee:SetSize(150, 20)
    DComboBox_Melee:SetPos(275, 95)
    DComboBox_Melee:SetText("Melee")
    --init health
    DNumberWang_Health:SetSize(50, 20)
    DNumberWang_Health:SetPos(175, 140)
    DNumberWang_Health:SetValue(100)
    --init armour
    DNumberWang_Armour:SetSize(50, 20)
    DNumberWang_Armour:SetPos(275, 140)
    DNumberWang_Armour:SetValue(10)
    --init weight
    DLabel_Weight:SetSize(75, 20)
    DLabel_Weight:SetPos(175, 185)
    DLabel_Weight:SetText("Weight: 69")
    --init speed
    DLabel_Speed:SetSize(75, 20)
    DLabel_Speed:SetPos(275, 185)
    DLabel_Speed:SetText("Speed: 420")

    DButton_Add:SetSize(25, 20)
    DButton_Add:SetPos(250, 185)
    DButton_Add:SetText("Add")
    DButton_Add.DoClick = function ()
        net.Start("UpdateLoadout")
        net.WriteInt(1, 2)
        net.WriteString(DComboBox_Name:GetSelected())
        net.WriteString(DComboBox_Primary:GetSelected())
        net.WriteString(DComboBox_Secondary:GetSelected())
        net.WriteString(DComboBox_Melee:GetSelected())
        net.WriteInt(DNumberWang_Health:GetValue(), 8)
        net.WriteInt(DNumberWang_Armour:GetValue(), 8)
        net.SendToServer()
    end

    --init loadout view
    DListView_Loadouts:SetSize(400, 150)
    DListView_Loadouts:SetPos(50, 220)
    DListView_Loadouts:AddColumn("ayy lmao")


    --add weapons to boxes
    for k, v in pairs(weapons.GetList()) do
        --need to check loadout slot here
        DComboBox_Primary:AddChoice(v.ClassName)
        DComboBox_Secondary:AddChoice(v.ClassName)
        DComboBox_Melee:AddChoice(v.ClassName)
    end

end)
