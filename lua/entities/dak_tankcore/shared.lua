ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 	0, "TurretPop", 	{ KeyName = "turretpop", 	Edit = {category = "Misc",title = "Turret Launch Chance", type = "Float", order = 1, min = 0, max = 100 } } )
	if self:GetTurretPop()==0 then self:SetTurretPop( 33 ) end
	self:NetworkVar( "Float", 	1, "TurretPopForceMult", 	{ KeyName = "turretpopforcemult", 	Edit = {category = "Misc",title = "Turret Launch Force Mult", type = "Float", order = 2, min = 0, max = 5 } } )
	if self:GetTurretPopForceMult()==0 then self:SetTurretPopForceMult( 0.30 ) end
	self:NetworkVar( "Bool", 	2, "ForceColdWar", 	{ KeyName = "forcecoldwar", 	Edit = {category = "Era",title = "Force Cold War Tech", type = "Boolean", order = 3 } } )
	self:NetworkVar( "Bool", 	3, "ForceModern", 	{ KeyName = "forcemodern", 	Edit = {category = "Era",title = "Force Modern Tech", type = "Boolean", order = 4 } } )
end