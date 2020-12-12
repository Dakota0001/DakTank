ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()
	--Misc
	self:NetworkVar( "String", 	0, "TankName", 	{ KeyName = "tankname", 	Edit = {category = "Misc",title = "Vehicle Name", type = "String", order = 1 } } )
	self:NetworkVar( "Float", 	0, "TurretPop", 	{ KeyName = "turretpop", 	Edit = {category = "Misc",title = "Turret Launch Chance", type = "Float", order = 2, min = 0, max = 100 } } )
	if self:GetTurretPop()==0 then self:SetTurretPop( 33 ) end
	self:NetworkVar( "Float", 	1, "TurretPopForceMult", 	{ KeyName = "turretpopforcemult", 	Edit = {category = "Misc",title = "Turret Launch Force Mult", type = "Float", order = 3, min = 0, max = 5 } } )
	if self:GetTurretPopForceMult()==0 then self:SetTurretPopForceMult( 0.30 ) end
	--Era
	self:NetworkVar( "Bool", 	2, "ForceColdWar", 	{ KeyName = "forcecoldwar", 	Edit = {category = "Era",title = "Force Cold War Tech", type = "Boolean", order = 4 } } )
	self:NetworkVar( "Bool", 	3, "ForceModern", 	{ KeyName = "forcemodern", 	Edit = {category = "Era",title = "Force Modern Tech", type = "Boolean", order = 5 } } )
	--APS
	self:NetworkVar( "Bool", 	4, "EnableAPS", 	{ KeyName = "enableaps", 	Edit = {category = "Active Protection System",title = "Enable APS", type = "Boolean", order = 6 } } )
	self:NetworkVar( "Int", 	1, "APSShots", 	{ KeyName = "apsshots", 	Edit = {category = "Active Protection System",title = "APS Shots", type = "Int", order = 7, min = 0, max = 20 } } )

	self:NetworkVar( "Bool", 	5, "APSFrontalArc", 	{ KeyName = "apsfrontalarc", 	Edit = {category = "Active Protection System",title = "Protect Front", type = "Boolean", order = 8 } } )
	self:NetworkVar( "Bool", 	6, "APSSideArc", 	{ KeyName = "apssidearc", 	Edit = {category = "Active Protection System",title = "Protect Sides", type = "Boolean", order = 9 } } )
	self:NetworkVar( "Bool", 	7, "APSRearArc", 	{ KeyName = "apsreararc", 	Edit = {category = "Active Protection System",title = "Protect Rear", type = "Boolean", order = 10 } } )

	self:NetworkVar( "Float", 	2, "APSMinCaliber", 	{ KeyName = "apsmincaliber", 	Edit = {category = "Active Protection System",title = "APS Min Caliber", type = "Float", order = 11, min = 0, max = 420 } } )
end