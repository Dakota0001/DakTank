ENT.Type = "anim"
ENT.Base = "base_wire_entity"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE


----------------------------------------------------------------
local textures = {
	["track_amx13"] = "Amx13",
	["track_amx30"] = "Amx30",
	["track_bmp"] = "BMP",
	["track_chieftain"] = "Chieftain",
	["track_generic"] = "Generic",
	["track_kingtiger"] = "King Tiger",
	["track_kv"] = "KV",
	["track_leopard1"] = "Leopard 1",
	["track_leopard2"] = "Leopard 2",
	["track_m1"] = "M1",
	["track_m2bradley"] = "M2 Bradley",
	["track_m4"] = "M4",
	["track_m4a1"] = "M4a1",
	["track_m4a3e8"] = "M4a3e8",
	["track_m60a1"] = "M60a1",
	["track_maus"] = "Maus",
	["track_panther"] = "Panther",
	["track_panzer4"] = "Panzer 4",
	["track_sheridan"] = "Sheridan",
	["track_t30"] = "T30",
	["track_t34"] = "T34",
	["track_t54"] = "T54",
	["track_t55"] = "T55",
	["track_t62"] = "T62",
	["track_t64"] = "T64",
	["track_t72"] = "T72",
	["track_t80"] = "T80",
	["track_t90"] = "T90",
	["track_tiger"] = "Tiger",
	["track_type90"] = "Type90",
}

local modes = {
	["halftracked"] = "Halftracked (experimental)",
	["tracked"] = "Tracked",
	["wheeled"] = "Wheeled",
}

function ENT:_DakVar_SETUP()
	local category, hidepanel


	----------------------------------------------------------------
	category = "Gearbox Setup"

	self:_DakVar_REGISTER({notify = CLIENT,type = "String", name = "VehicleMode", default = "tracked", values = modes},
		{category = category, title = "Mode", rowcolor = Color(225, 255, 225)})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "WheelOffsetX", min = -200, max = 200, default = 0},
		{category = category, title = "X Offset"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "WheelOffsetY", min = 0, max = 1000, default = 50},
		{category = category, title = "Y Offset"})


	----------------------------------------------------------------
	category = "Mobility Setup"

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "WheelBase", min = 1, max = 1000, default = 200},
		{category = category, title = "Wheelbase", help = "Distance between front and rear wheels"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "WheelOffsetZ", min = 0, max = 200, default = 20},
		{category = category, title = "Ground Clearance", help = "Max length of wheel traces"})

	self:_DakVar_REGISTER({type = "Float", name = "GearRatio", min = 50, max = 100, default = 100},
		{category = category, title = "Top Speed Bias"})

	self:_DakVar_REGISTER({type = "Float", name = "SuspensionBias", min = -0.99, max = 0.99, default = 0},
		{category = category, title = "Suspension Bias"})

	self:_DakVar_REGISTER({type = "Float", name = "RideLimit", min = 50, max = 200, default = 100},
		{category = category, title = "Suspension Give"})

	self:_DakVar_REGISTER({type = "Float", name = "SuspensionForceMult", min = 0, max = 2, default = 1},
		{category = category, title = "Suspension Force"})

	self:_DakVar_REGISTER({type = "Float", name = "SuspensionDamping", min = 0.1, max = 0.9, default = 0.25},
		{category = category, title = "Suspension Damping"})

	self:_DakVar_REGISTER({type = "Float", name = "BrakeStiffness", min = 0, max = 1, default = 1},
		{category = category, title = "Brake Turning Stiffness"})

	self:_DakVar_REGISTER({type = "Float", name = "DakFriction", min = 1, max = 2, default = 1},
		{category = category, title = "Friction"})

	self:_DakVar_REGISTER({type = "Float", name = "DakInertia", min = 0, max = 10, default = 1},
		{category = category, title = "Inertia"})

	----------------------------------------------------------------
	category = "Track Appearance"
	hidepanel = {VehicleMode = {wheeled = true}}

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "TrackTension", min = 0, max = 1, default = 0.5},
		{hidepanel = hidepanel, category = category, title = "Tension"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "TrackHeight", min = 1, max = 32, default = 3},
		{hidepanel = hidepanel, category = category, title = "Height"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "TrackWidth", min = 1, max = 200, default = 24},
		{hidepanel = hidepanel, category = category, title = "Width"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "TrackResolution", min = 1, max = 8, default = 2},
		{hidepanel = hidepanel, category = category, title = "Resolution", help = "Material aspect ratio multiplier (Width*Resolution)"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "TrackMaterial", default = "track_generic", values = textures},
		{hidepanel = hidepanel, category = category, title = "Material"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Vector", name = "TrackColor", default = Vector(255, 255, 255)},
		{hidepanel = hidepanel, category = category, title = "Color", property = "Color"})


	----------------------------------------------------------------
	category = "General Wheel Appearance"

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "WheelMaterial", default = ""},
		{category = category, title = "Material", help = "Can set submaterials with comma separated values, ex: 0,path0,1,path1"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Vector", name = "WheelColor", default = Vector(255, 255, 255)},
		{category = category, title = "Color", property = "Color"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Int", name = "RoadWTurnAngle", min = 0, max = 45, default = 0},
		{hidepanel = {VehicleMode = {tracked = true}}, category = category, title = "Turning Angle"})

	local hidepanel = {VehicleMode = {halftracked = true, tracked = true}}

	self:_DakVar_REGISTER({notify = CLIENT, type = "Int", name = "RoadWTurnFront", min = 0, max = 9, default = 0},
		{hidepanel = hidepanel, category = category, title = "Front turning pairs", func = {max = {mul = 0.5, num = "GetRoadWCount"}}})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Int", name = "RoadWTurnRear", min = 0, max = 9, default = 0},
		{hidepanel = hidepanel, category = category, title = "Rear turning pairs", func = {max = {mul = 0.5, num = "GetRoadWCount"}}})


	----------------------------------------------------------------
	category = "Halftrack Wheel Appearance"
	hidepanel = {VehicleMode = {tracked = true, wheeled = true}}

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "HalfTWDiameter", min = 1, max = 200, default = 40},
		{hidepanel = hidepanel, category = category, title = "Diameter"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "HalfTWWidth", min = 1, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Width"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "HalfTOffsetX", min = 0, max = 1, default = 1},
		{hidepanel = hidepanel, category = category, title = "X Offset %", help = "Percentage of HalfWheelbase*X"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "HalfTOffsetY", min = 0, max = 1, default = 1},
		{hidepanel = hidepanel, category = category, title = "Y Offset %", help = "Percentage of HalfWheelY*Y"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "HalfTWModel", default = "models/sprops/trans/wheel_e/t_wheel15.mdl"},
		{hidepanel = hidepanel, category = category, title = "Model"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "HalfTWBGroup", default = ""},
		{hidepanel = hidepanel, category = category, title = "Bodygroup", help = "Each single-digit number in the string represents a separate bodygroup. Ex: 01004"})


	----------------------------------------------------------------
	category = "Drive Wheel Setup"
	hidepanel = {VehicleMode = {wheeled = true}}

	self:_DakVar_REGISTER({notify = CLIENT,type = "Bool", name = "DriveWEnabled", default = true},
		{hidepanel = hidepanel, category = category, title = "Enabled"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "DriveWDiameter", min = 1, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Diameter"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "DriveWWidth", min = 1, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Width"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "DriveWOffsetZ", min = -200, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Z Offset"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "DriveWModel", default = "models/sprops/trans/miscwheels/tank15.mdl"},
		{hidepanel = hidepanel, category = category, title = "Model"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "DriveWBGroup", default = "001"},
		{hidepanel = hidepanel, category = category, title = "Bodygroup", help = "Each single-digit number in the string represents a separate bodygroup. Ex: 01004"})


	----------------------------------------------------------------
	category = "Road Wheel Setup"
	hidepanel = {VehicleMode = {wheeled = true}}

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "RoadWType", default = "normal", values = {normal = "Normal", interleave = "Interleave"}},
		{hidepanel = hidepanel, category = category, title = "Type"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Int", name = "RoadWCount", min = 0, max = 18, default = 5},
		{category = category, title = "Count"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "RoadWDiameter", min = 1, max = 200, default = 20},
		{category = category, title = "Diameter"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "RoadWWidth", min = 1, max = 200, default = 20},
		{category = category, title = "Width"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "String", name = "RoadWOffsetsX", default = ""},
		{category = category, title = "X Offsets", property = "idxoff", func = {num = "GetRoadWCount"}})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "RoadWModel", default = "models/sprops/trans/miscwheels/tank15.mdl"},
		{category = category, title = "Model"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "RoadWBGroup"},
		{category = category, title = "Bodygroup", help = "Each single-digit number in the string represents a separate bodygroup. Ex: 01004"})


	----------------------------------------------------------------
	category = "Idler Wheel Setup"
	hidepanel = {VehicleMode = {wheeled = true}}

	self:_DakVar_REGISTER({notify = CLIENT,type = "Bool", name = "IdlerWEnabled", default = true},
		{hidepanel = hidepanel, category = category, title = "Enabled"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "IdlerWDiameter", min = 1, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Diameter"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "IdlerWWidth", min = 1, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Width"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "Float", name = "IdlerWOffsetZ", min = -200, max = 200, default = 20},
		{hidepanel = hidepanel, category = category, title = "Z Offset"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "IdlerWModel", default = "models/sprops/trans/miscwheels/tank15.mdl"},
		{hidepanel = hidepanel, category = category, title = "Model"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "IdlerWBGroup"},
		{hidepanel = hidepanel, category = category, title = "Bodygroup", help = "Each single-digit number in the string represents a separate bodygroup. Ex: 01004"})


	----------------------------------------------------------------
	category = "Roller Wheel Setup"
	hidepanel = {VehicleMode = {wheeled = true}}

	self:_DakVar_REGISTER({notify = CLIENT, type = "Int", name = "RollerWCount", min = 0, max = 18, default = 2},
		{hidepanel = hidepanel, category = category, title = "Count"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "RollerWDiameter", min = 1, max = 200, default = 10},
		{hidepanel = hidepanel, category = category, title = "Diameter"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "RollerWWidth", min = 1, max = 200, default = 5},
		{hidepanel = hidepanel, category = category, title = "Width"})

	self:_DakVar_REGISTER({notify = CLIENT,type = "String", name = "RollerWOffsetsX", default = ""},
		{hidepanel = hidepanel, category = category, title = "X Offsets", property = "idxoff", func = {num = "GetRollerWCount"}})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "RollerWOffsetZ", min = -200, max = 200, default = 0},
		{hidepanel = hidepanel, category = category, title = "Z Offset"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "Float", name = "RollerWBias", min = 0, max = 1, default = 0},
		{hidepanel = hidepanel, category = category, title = "Z Bias", help = "Weight of the slope toward front or rear"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "RollerWModel", default = "models/sprops/trans/miscwheels/tank15.mdl"},
		{hidepanel = hidepanel, category = category, title = "Model"})

	self:_DakVar_REGISTER({notify = CLIENT, type = "String", name = "RollerWBGroup"},
		{hidepanel = hidepanel, category = category, title = "Bodygroup", help = "Each single-digit number in the string represents a separate bodygroup. Ex: 01004"})
end


----------------------------------------------------------------
--	store indexed position offsets as a 2 character string
--	networked strings have a 199 character limit
--	ex: a3z9 means wheel 1 (a) has an offset weight of 0.333 (3/9) and wheel 26 (z) has an offset weight of 1 (9/9)
local string = string
local table = table
local math = math

local function a1z26_toTable(str, int)
	local ret = {}
	local key = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local len = string.len(key)
	for k, v in string.gmatch(str, "(%a+)(%-?%d+)") do
		local idx = 0
		for i = 1, #k do
			local f = string.find(key, string.sub(k, i, i))
			idx = idx + f + f*(len*(i - 1))
		end
		ret[idx] = tonumber(v)/int
	end
	return ret
end

local function a1z26_toString(tbl, int)
	local ret = {}
	local key = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for k, v in pairs(tbl) do
		local f = string.sub(key, k, k)
		table.insert(ret, f .. math.Round(v*int))
	end
	return table.concat(ret)
end

function ENT:a1z26Encode(tbl)
	return a1z26_toString(tbl, 99)
end

function ENT:a1z26Decode(str)
	return a1z26_toTable(str, 99)
end
