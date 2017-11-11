ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Editable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 	0, "Elevation", 	{ KeyName = "elevation", 	Edit = { type = "Float", 		order = 1, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	1, "Depression", 	{ KeyName = "depression", 	Edit = { type = "Float", 		order = 2, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	2, "YawMin", 	{ KeyName = "yawmin", 	Edit = { type = "Float", 		order = 3, min = 0, max = 360 } } )
	self:NetworkVar( "Float", 	3, "YawMax", 	{ KeyName = "yawmax", 	Edit = { type = "Float", 		order = 4, min = 0, max = 360 } } )


		--self.StrideLength = 2.2
        --self.StrideHeight = 0.3
        --self.HipBobMultiplier = 1
       	--self.CrouchPercent = 0.9

end
