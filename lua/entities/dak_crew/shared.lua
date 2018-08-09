ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 	0, "Voice", 	{ KeyName = "voice", 	Edit = { type = "Int", 		order = 1, min = 0, max = 6 } } )
end