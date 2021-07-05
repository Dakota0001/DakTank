AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

DEFINE_BASECLASS("base_scalable_mconvex")

----

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 	0, "Propellant", 	{ KeyName = "propellant", 	Edit = { type = "Float", order = 1, min = 10, max = 100 } } )
	self:SetPropellant( 100 )

end