ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 	0, "GearRatio", 	{ KeyName = "gearratio", 	Edit = { type = "Float", order = 1, min = 50, max = 100 } } )
	self:SetGearRatio( 100 )

end