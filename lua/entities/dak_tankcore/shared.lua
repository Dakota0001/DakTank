ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 	0, "TurretPop", 	{ KeyName = "turretpop", 	Edit = {category = "Misc",title = "Turret Launch Chance", type = "Float", order = 1, min = 0, max = 100 } } )
	if self:GetTurretPop()==0 then self:SetTurretPop( 33 ) end
	self:NetworkVar( "Float", 	1, "TurretPopForceMult", 	{ KeyName = "turretpopforcemult", 	Edit = {category = "Misc",title = "Turret Launch Force Mult", type = "Float", order = 1, min = 0, max = 5 } } )
	if self:GetTurretPopForceMult()==0 then self:SetTurretPopForceMult( 0.30 ) end
end