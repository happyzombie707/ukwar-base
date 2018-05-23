NUM_DOF_NODES = 100
function DOF_Think( )
	DOF_SPACING	= pp_dof_spacing:GetFloat()
	DOF_OFFSET	= pp_dof_initlength:GetFloat()
end

--]]
hook.Add( "Think", "DOFThink", function()
	--print("dof")
	--DOF_SPACING = Lerp(1, 0, 1000)
	--print("DOF: ", DOF_SPACING)
	DOF_SPACING = 90 -- pp_dof_spacing:GetFloat() --90
	DOF_OFFSET = 512 -- pp_dof_initlength:GetFloat() --512
end )--]]

--NUM_DOF_NODES = 10
function DOF_Start_()
	local effectdata = EffectData()
	local g = effectdata:GetOrigin()
	print(Vector(g))
	effectdata:SetOrigin(Vector(-10,-1,-10))
	local g = effectdata:GetOrigin()
	print(Vector(g))

	--print(NUM_DOF_NODES)
	for i=0, NUM_DOF_NODES do
		

		--PrintTable(t)

		effectdata:SetScale( i )
		util.Effect( "dof_node", effectdata )
	end
	DOFModeHack( true )
end