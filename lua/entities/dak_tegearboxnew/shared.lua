ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()
	--Mobility
	self:NetworkVar( "Float", 	0, "GearRatio", 	{ KeyName = "gearratio", 	Edit = {category = "Mobility",title = "Top Speed Bias", type = "Float", order = 1, min = 50, max = 100 } } )
	if self:GetGearRatio()==0 then self:SetGearRatio( 100 ) end
	self:NetworkVar( "Float", 	1, "RideLimit", 	{ KeyName = "ridelimit", 	Edit = {category = "Mobility",title = "Suspension Give", type = "Float", order = 2, min = 50, max = 200 } } )
	if self:GetRideLimit()==0 then self:SetRideLimit( 100 ) end
	self:NetworkVar( "Float", 	2, "SuspensionBias", 	{ KeyName = "suspensionbias", 	Edit = {category = "Mobility",title = "Suspension Bias", type = "Float", order = 3, min = -0.99, max = 0.99 } } )
	if self:GetSuspensionBias()==0 then self:SetSuspensionBias( 0 ) end
	self:NetworkVar( "Float", 	3, "BrakeStiffness", 	{ KeyName = "brakestiffness", 	Edit = {category = "Mobility",title = "Brake Turning Stiffness", type = "Float", order = 4, min = 0, max = 1 } } )
	if self:GetBrakeStiffness()==0 then self:SetBrakeStiffness( 1 ) end
	self:NetworkVar( "Float", 	4, "SuspensionForceMult", 	{ KeyName = "suspensionforcemult", 	Edit = {category = "Mobility",title = "Suspension Force Mult", type = "Float", order = 5, min = 0, max = 2 } } )
	if self:GetSuspensionForceMult()==0 then self:SetSuspensionForceMult( 1 ) end
	--Dimensions
	self:NetworkVar( "Float", 	5, "TrackLength", 	{ KeyName = "tracklength", 	Edit = {category = "Dimensions",title = "Track Length", type = "Float", order = 6, min = 0, max = 1000 } } )
	if self:GetTrackLength()==0 then self:SetTrackLength( 200 ) end
	self:NetworkVar( "Float", 	6, "SideDist", 	{ KeyName = "sidedist", 	Edit = {category = "Dimensions",title = "Track Side Offset", type = "Float", order = 7, min = 0, max = 1000 } } )
	if self:GetSideDist()==0 then self:SetSideDist( 50 ) end
	self:NetworkVar( "Float", 	7, "RideHeight", 	{ KeyName = "rideheight", 	Edit = {category = "Dimensions",title = "Ground Clearance", type = "Float", order = 8, min = -200, max = 200 } } )
	if self:GetRideHeight()==0 then self:SetRideHeight( 0 ) end
	self:NetworkVar( "Float", 	8, "ForwardOffset", 	{category = "Mobility", KeyName = "forwardoffset", 	Edit = {category = "Dimensions",title = "Track Forward Offset", type = "Float", order = 9, min = -200, max = 200 } } )
	if self:GetForwardOffset()==0 then self:SetForwardOffset( 0 ) end
	--WheelDetails
	self:NetworkVar( "Int", 	0, "WheelsPerSide", 	{ KeyName = "wheelsperside", 	Edit = {category = "Wheel Details",title = "Wheels Per Side", type = "Int", order = 10, min = 2, max = 20 } } )
	if self:GetWheelsPerSide()==0 then self:SetWheelsPerSide( 7 ) end
	self:NetworkVar( "Float", 	9, "FrontWheelRaise", 	{ KeyName = "frontwheelraise", 	Edit = {category = "Wheel Details",title = "Front Wheel Raise", type = "Float", order = 11, min = 0, max = 200 } } )
	if self:GetFrontWheelRaise()==0 then self:SetFrontWheelRaise( 0 ) end
	self:NetworkVar( "Float", 	10, "RearWheelRaise", 	{ KeyName = "rearwheelraise", 	Edit = {category = "Wheel Details",title = "Rear Wheel Raise", type = "Float", order = 12, min = 0, max = 200 } } )
	if self:GetRearWheelRaise()==0 then self:SetRearWheelRaise( 0 ) end
	self:NetworkVar( "String", 	0, "WheelModel", 	{ KeyName = "wheelmodel", 	Edit = {category = "Wheel Details",title = "Wheel Model", type = "String", order = 13 } } )
	if self:GetWheelModel()=="" then self:SetWheelModel( "models/sprops/trans/miscwheels/tank20.mdl" ) end
	self:NetworkVar( "Float", 	11, "WheelWidth", 	{ KeyName = "wheelwidth", 	Edit = {category = "Wheel Details",title = "Wheel Width", type = "Float", order = 14, min = 1, max = 100 } } )
	if self:GetWheelWidth()==0 then self:SetWheelWidth( 12 ) end
	self:NetworkVar( "Float", 	12, "WheelHeight", 	{ KeyName = "wheelheight", 	Edit = {category = "Wheel Details",title = "Wheel Diameter", type = "Float", order = 15, min = 1, max = 100 } } )
	if self:GetWheelHeight()==0 then self:SetWheelHeight( 30 ) end
	self:NetworkVar( "Float", 	13, "FrontWheelHeight", 	{ KeyName = "frontwheelheight", 	Edit = {category = "Wheel Details",title = "Front Wheel Diameter", type = "Float", order = 16, min = 1, max = 100 } } )
	if self:GetFrontWheelHeight()==0 then self:SetFrontWheelHeight( 30 ) end
	self:NetworkVar( "Float", 	14, "RearWheelHeight", 	{ KeyName = "rearwheelheight", 	Edit = {category = "Wheel Details",title = "Rear Wheel Diameter", type = "Float", order = 17, min = 1, max = 100 } } )
	if self:GetRearWheelHeight()==0 then self:SetRearWheelHeight( 30 ) end
	self:NetworkVar( "Vector", 	0, "WheelColor", 	{ KeyName = "wheelcolor", 	Edit = {category = "Wheel Details",title = "Wheel Color", type = "VectorColor", order = 18 } } )
	if self:GetWheelColor()==Vector(0,0,0) then self:SetWheelColor(Vector(1,1,1)) end
	self:NetworkVar( "Int", 	1, "WheelBodygroup1", 	{ KeyName = "wheelbodygroup1", 	Edit = {category = "Wheel Details", title = "Wheel Bodygroup 1", type = "Int", 		order = 19, min = 0, max = 25} } )
	self:NetworkVar( "Int", 	2, "WheelBodygroup2", 	{ KeyName = "wheelbodygroup2", 	Edit = {category = "Wheel Details", title = "Wheel Bodygroup 2", type = "Int", 		order = 20, min = 0, max = 25} } )
	self:NetworkVar( "Int", 	3, "WheelBodygroup3", 	{ KeyName = "wheelbodygroup3", 	Edit = {category = "Wheel Details", title = "Wheel Bodygroup 3", type = "Int", 		order = 21, min = 0, max = 25} } )
	self:NetworkVar( "Bool", 	0, "FrontSprocket", 	{ KeyName = "frontsprocket", 	Edit = {category = "Wheel Details", title = "Front Sprocket", type = "Boolean", 		order = 22} } )
	self:NetworkVar( "Bool", 	1, "RearSprocket", 	{ KeyName = "rearsprocket", 	Edit = {category = "Wheel Details", title = "Rear Sprocket", type = "Boolean", 		order = 23} } )
	self:NetworkVar( "Bool", 	2, "OffsetYaw", 	{ KeyName = "offsetyaw", 	Edit = {category = "Wheel Details", title = "Offset Wheel Yaw", type = "Boolean", 		order = 24} } )
	--Track Details
	self:NetworkVar( "Float", 	15, "TreadWidth", 	{ KeyName = "treadwidth", 	Edit = {category = "Tread Details",title = "Tread Width", type = "Float", order = 25, min = 1, max = 100 } } )
	if self:GetTreadWidth()==0 then self:SetTreadWidth( 12 ) end
	self:NetworkVar( "Float", 	16, "TreadHeight", 	{ KeyName = "treadheight", 	Edit = {category = "Tread Details",title = "Tread Thickness", type = "Float", order = 26, min = 1, max = 100 } } )
	if self:GetTreadHeight()==0 then self:SetTreadHeight( 3 ) end
	self:NetworkVar( "Vector", 	1, "TreadColor", 	{ KeyName = "treadcolor", 	Edit = {category = "Tread Details",title = "Tread Color", type = "VectorColor", order = 27 } } )
	if self:GetTreadColor()==Vector(0,0,0) then self:SetTreadColor(Vector(1,1,1)) end
	--Wheeled Vehicle Options
	self:NetworkVar( "Bool", 	3, "WheeledMode", 	{ KeyName = "wheeledmode", 	Edit = {category = "Wheeled Vehicle Options", title = "Wheeled Vehicle", type = "Boolean", 		order = 28} } )
	self:NetworkVar( "Int", 	4, "ForwardTurningWheels", 	{ KeyName = "forwardturningwheels", 	Edit = {category = "Wheeled Vehicle Options", title = "Forward Turning Wheels", type = "Int", 		order = 29, min = 0, max = 10} } )
	self:NetworkVar( "Int", 	5, "RearTurningWheels", 	{ KeyName = "rearturningwheels", 	Edit = {category = "Wheeled Vehicle Options", title = "Rear Turning Wheels", type = "Int", 		order = 30, min = 0, max = 10} } )
	self:NetworkVar( "Float", 	17, "TurnAngle", 	{ KeyName = "turnangle", 	Edit = {category = "Wheeled Vehicle Options",title = "Turn Angle", type = "Float", order = 31, min = 0, max = 45 } } )
	--Wheel Offset Options
	for i=1, 20 do
		self:NetworkVar( "Int", 	5+i, "WheelForwardOffset"..i, 	{ KeyName = "wheelforwardoffset"..i, 	Edit = {category = "Wheel Offsets", title = "Wheel Forward Offset "..i, type = "Int", 		order = 31+i, min = -10000, max = 10000} } )
	end
end