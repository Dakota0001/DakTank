ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Editable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 	0, "Elevation", 	{ KeyName = "elevation", 	Edit = {category = "Basic", title = "Elevation", type = "Float", 		order = 1, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	1, "Depression", 	{ KeyName = "depression", 	Edit = {category = "Basic", title = "Depression", type = "Float", 		order = 2, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	2, "YawMin", 	{ KeyName = "yawmin", 	Edit = {category = "Basic", title = "Minimum Yaw", type = "Float", 		order = 3, min = 0, max = 360 } } )
	self:NetworkVar( "Float", 	3, "YawMax", 	{ KeyName = "yawmax", 	Edit = {category = "Basic", title = "Maximum Yaw", type = "Float", 		order = 4, min = 0, max = 360 } } )
	self:NetworkVar( "Float", 	4, "RotationSpeedMultiplier", 	{ KeyName = "rotationspeedmultiplier", 	Edit = {category = "Basic", title = "Rotation Speed Multiplier", type = "Float", 		order = 5, min = 0, max = 1 } } )
	self:SetRotationSpeedMultiplier( 1 )
	self:NetworkVar( "Bool", 	0, "FixedGun", 	{ KeyName = "fixedgun", 	Edit = {category = "Features", title = "Fixed Gun", type = "Boolean", 		order = 6} } )
	self:NetworkVar( "Bool", 	1, "ShortStopStabilizer", 	{ KeyName = "shortstopstabilizer", 	Edit = {category = "Features", title = "Short Stop Stabilizer", type = "Boolean", 		order = 7} } )
	self:NetworkVar( "Bool", 	2, "Stabilizer", 	{ KeyName = "stabilizer", 	Edit = {category = "Features", title = "Full Stabilizer", type = "Boolean", 		order = 8} } )
	self:NetworkVar( "Bool", 	3, "FCS", 	{ KeyName = "fcs", 	Edit = {category = "Features", title = "Fire Control System", type = "Boolean", 		order = 9} } )
	self:NetworkVar( "Bool", 	4, "SetPitchOnLoading", 	{ KeyName = "setpitchonloading", 	Edit = {category = "Advanced", title = "Load at Set Angle", type = "Boolean", 		order = 10} } )
	self:NetworkVar( "Float", 	5, "LoadingAngle", 	{ KeyName = "loadingangle", 	Edit = {category = "Advanced", title = "Loading Angle", type = "Float", 		order = 11, min = -self:GetDepression(), max = self:GetElevation() } } )
	self:NetworkVar( "Bool", 	5, "QuadrantElevation", 	{ KeyName = "quadrantelevation", 	Edit = {category = "Advanced", title = "Quadrant Based Limits", type = "Boolean", 		order = 12} } )
	self:NetworkVar( "Float", 	6, "FrontElevation", 	{ KeyName = "frontelevation", 	Edit = {category = "Advanced", title = "Forward Elevation", type = "Float", 		order = 13, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	7, "FrontDepression", 	{ KeyName = "frontdepression", 	Edit = {category = "Advanced", title = "Forward Depression", type = "Float", 		order = 14, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	8, "RightElevation", 	{ KeyName = "rightelevation", 	Edit = {category = "Advanced", title = "Right Elevation", type = "Float", 		order = 15, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	9, "RightDepression", 	{ KeyName = "rightdepression", 	Edit = {category = "Advanced", title = "Right Depression", type = "Float", 		order = 16, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	10, "LeftElevation", 	{ KeyName = "leftelevation", 	Edit = {category = "Advanced", title = "Left Elevation", type = "Float", 		order = 17, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	11, "LeftDepression", 	{ KeyName = "leftdepression", 	Edit = {category = "Advanced", title = "Left Depression", type = "Float", 		order = 18, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	12, "RearElevation", 	{ KeyName = "rearelevation", 	Edit = {category = "Advanced", title = "Rear Elevation", type = "Float", 		order = 19, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	13, "RearDepression", 	{ KeyName = "reardepression", 	Edit = {category = "Advanced", title = "Rear Depression", type = "Float", 		order = 20, min = 0, max = 90 } } )
	self:NetworkVar( "Float", 	14, "IdleElevation", 	{ KeyName = "idleelevation", 	Edit = {category = "Advanced", title = "Idle Elevation", type = "Float", 		order = 21, min = -90, max = 90 } } )
	self:NetworkVar( "Float", 	15, "IdleYaw", 	{ KeyName = "idleyaw", 	Edit = {category = "Advanced", title = "Idle Yaw", type = "Float", 		order = 22, min = -180, max = 180 } } )
	self:NetworkVar( "Float", 	16, "AirburstHeight", 	{ KeyName = "airburstheight", 	Edit = {category = "Advanced", title = "Airburst Height (m)", type = "Float", 		order = 23, min = 0, max = 250 } } )
end
