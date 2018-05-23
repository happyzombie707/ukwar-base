function ShowLoadoutMenu()

    PrintTable(loadout.GetAllLoadouts())

    --Create panel elements
    local Frame = vgui.Create( "DFrame" )
    local DTextEntry_Name = vgui.Create( "DTextEntry", Frame )
    local DComboBox_Primary = vgui.Create( "DComboBox", Frame )
    local DComboBox_Secondary = vgui.Create( "DComboBox", Frame )
    local DComboBox_Melee = vgui.Create( "DComboBox", Frame )
    local DTextEntry_Health = vgui.Create( "DTextEntry", Frame )
    local DTextEntry_Armour = vgui.Create( "DTextEntry", Frame )


    --Initialise frame
    Frame:SetSize( 500, 400 )
    Frame:Center()
    Frame:SetTitle( "Customise Loadouts" )
    Frame:SetVisible( true )
    Frame:SetDraggable( false )
    Frame:ShowCloseButton( true )
    Frame:MakePopup()


    --Initialise class combobox
--    DComboBox_Class:Clear()
    DTextEntry_Name:Center()
    DTextEntry_Name:SetPos(DTextEntry_Health:GetPos(), 5)
    DComboBox_Primary:Center()
    DComboBox_Primary:SetPos(DComboBox_Class:GetPos(), 15)
    DComboBox_Secondary:Center()
    DComboBox_Secondary:SetPos(DComboBox_Class:GetPos(), 25)
    DComboBox_Melee:Center()
    DComboBox_Melee:SetPos(DComboBox_Class:GetPos(), 35)
    DTextEntry_Health:Center()
    DTextEntry_Health:SetPos(DTextEntry_Health:GetPos(), 45)
    DTextEntry_Armour:Center()
    DTextEntry_Armour:SetPos(DTextEntry_Health:GetPos(), 55)



    for k, v in pairs(weapons.GetList()) do
        DComboBox_Primary:AddChoice(v.ClassName)
        DComboBox_Secondary:AddChoice(v.ClassName)
        DComboBox_Melee:AddChoice(v.ClassName)
    end

    --DComboBox_Class.OnSelect = function()

    --end


    --Initialise red team button

end
