ENT.Type = "anim"
ENT.Base = "base_wire_entity"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.Editable = true

function ENT:SetupDataTables()
	--Mobility
	self:NetworkVar( "Float", 	0, "GearRatio", 	{ KeyName = "gearratio", 	Edit = {category = "Mobility",title = "Top Speed Bias", type = "Float", order = 1, min = 50, max = 100 } } )
	if self:GetGearRatio()==0 then self:SetGearRatio( 100 ) end
	self:NetworkVar( "Float", 	4, "RideLimit", 	{ KeyName = "ridelimit", 	Edit = {category = "Mobility",title = "Suspension Give", type = "Float", order = 5, min = 50, max = 1000 } } )
	if self:GetRideLimit()==0 then self:SetRideLimit( 250 ) end
	--self:NetworkVar( "Float", 	14, "ForwardBias", 	{ KeyName = "forwardbias", 	Edit = {category = "Mobility",title = "Suspension Forward Bias", type = "Float", order = 6, min = -1, max = 1 } } )
	--if self:GetForwardBias()==0 then self:SetForwardBias( 0 ) end
	--Dimensions
	self:NetworkVar( "Float", 	1, "TrackLength", 	{ KeyName = "tracklength", 	Edit = {category = "Dimensions",title = "Track Length", type = "Float", order = 2, min = 0, max = 1000 } } )
	if self:GetTrackLength()==0 then self:SetTrackLength( 200 ) end
	self:NetworkVar( "Float", 	2, "SideDist", 	{ KeyName = "sidedist", 	Edit = {category = "Dimensions",title = "Track Side Offset", type = "Float", order = 3, min = 0, max = 1000 } } )
	if self:GetSideDist()==0 then self:SetSideDist( 50 ) end
	self:NetworkVar( "Float", 	3, "RideHeight", 	{ KeyName = "rideheight", 	Edit = {category = "Dimensions",title = "Ground Clearance", type = "Float", order = 6, min = -200, max = 200 } } )
	if self:GetRideHeight()==0 then self:SetRideHeight( 0 ) end
	self:NetworkVar( "Float", 	5, "ForwardOffset", 	{category = "Mobility", KeyName = "forwardoffset", 	Edit = {category = "Dimensions",title = "Track Forward Offset", type = "Float", order = 4, min = -200, max = 200 } } )
	if self:GetForwardOffset()==0 then self:SetForwardOffset( 0 ) end
	--WheelDetails
	self:NetworkVar( "Int", 	0, "WheelsPerSide", 	{ KeyName = "wheelsperside", 	Edit = {category = "Wheel Details",title = "Wheels Per Side", type = "Int", order = 7, min = 3, max = 20 } } )
	if self:GetWheelsPerSide()==0 then self:SetWheelsPerSide( 7 ) end
	self:NetworkVar( "Float", 	6, "FrontWheelRaise", 	{ KeyName = "frontwheelraise", 	Edit = {category = "Wheel Details",title = "Front Wheel Raise", type = "Float", order = 8, min = 0, max = 200 } } )
	if self:GetFrontWheelRaise()==0 then self:SetFrontWheelRaise( 0 ) end
	self:NetworkVar( "Float", 	7, "RearWheelRaise", 	{ KeyName = "rearwheelraise", 	Edit = {category = "Wheel Details",title = "Rear Wheel Raise", type = "Float", order = 9, min = 0, max = 200 } } )
	if self:GetRearWheelRaise()==0 then self:SetRearWheelRaise( 0 ) end
	self:NetworkVar( "String", 	0, "WheelModel", 	{ KeyName = "wheelmodel", 	Edit = {category = "Wheel Details",title = "Wheel Model", type = "String", order = 10 } } )
	if self:GetWheelModel()=="" then self:SetWheelModel( "models/sprops/trans/miscwheels/tank20.mdl" ) end
	self:NetworkVar( "Float", 	8, "WheelWidth", 	{ KeyName = "wheelwidth", 	Edit = {category = "Wheel Details",title = "Wheel Width", type = "Float", order = 11, min = 1, max = 100 } } )
	if self:GetWheelWidth()==0 then self:SetWheelWidth( 12 ) end
	self:NetworkVar( "Float", 	9, "WheelHeight", 	{ KeyName = "wheelheight", 	Edit = {category = "Wheel Details",title = "Wheel Diameter", type = "Float", order = 12, min = 1, max = 100 } } )
	if self:GetWheelHeight()==0 then self:SetWheelHeight( 30 ) end
	self:NetworkVar( "Float", 	10, "FrontWheelHeight", 	{ KeyName = "frontwheelheight", 	Edit = {category = "Wheel Details",title = "Front Wheel Diameter", type = "Float", order = 13, min = 1, max = 100 } } )
	if self:GetFrontWheelHeight()==0 then self:SetFrontWheelHeight( 30 ) end
	self:NetworkVar( "Float", 	11, "RearWheelHeight", 	{ KeyName = "rearwheelheight", 	Edit = {category = "Wheel Details",title = "Rear Wheel Diameter", type = "Float", order = 14, min = 1, max = 100 } } )
	if self:GetRearWheelHeight()==0 then self:SetRearWheelHeight( 30 ) end
	self:NetworkVar( "Vector", 	0, "WheelColor", 	{ KeyName = "wheelcolor", 	Edit = {category = "Wheel Details",title = "Wheel Color", type = "VectorColor", order = 15 } } )
	if self:GetWheelColor()==Vector(0,0,0) then self:SetWheelColor(Vector(1,1,1)) end
	--Track Details
	self:NetworkVar( "Float", 	12, "TreadWidth", 	{ KeyName = "treadwidth", 	Edit = {category = "Tread Details",title = "Tread Width", type = "Float", order = 16, min = 1, max = 100 } } )
	if self:GetTreadWidth()==0 then self:SetTreadWidth( 12 ) end
	self:NetworkVar( "Float", 	13, "TreadHeight", 	{ KeyName = "treadheight", 	Edit = {category = "Tread Details",title = "Tread Thickness", type = "Float", order = 17, min = 1, max = 100 } } )
	if self:GetTreadHeight()==0 then self:SetTreadHeight( 3 ) end
	self:NetworkVar( "Vector", 	1, "TreadColor", 	{ KeyName = "treadcolor", 	Edit = {category = "Tread Details",title = "Tread Color", type = "VectorColor", order = 18 } } )
	if self:GetTreadColor()==Vector(0,0,0) then self:SetTreadColor(Vector(1,1,1)) end
end