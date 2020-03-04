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
	self:NetworkVar( "Float", 	4, "RotationSpeedMultiplier", 	{ KeyName = "rotationspeedmultiplier", 	Edit = { type = "Float", 		order = 5, min = 0, max = 1 } } )
	self:SetRotationSpeedMultiplier( 1 )
	self:NetworkVar( "Bool", 	0, "ShortStopStabilizer", 	{ KeyName = "shortstopstabilizer", 	Edit = { type = "Boolean", 		order = 6} } )
	self:NetworkVar( "Bool", 	1, "Stabilizer", 	{ KeyName = "stabilizer", 	Edit = { type = "Boolean", 		order = 7} } )
	self:NetworkVar( "Bool", 	2, "FCS", 	{ KeyName = "fcs", 	Edit = { type = "Boolean", 		order = 8} } )

end
