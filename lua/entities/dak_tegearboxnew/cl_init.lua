----------------------------------------------------------------
include("shared.lua")

local cv_part = CreateClientConVar("daktank_autotread_enable_particles", "1", true, false)
local cv_dt = CreateClientConVar("daktank_autotread_max_detail", "8", true, false, "maximum track render quality", 4, 16)
local cv_ad = CreateClientConVar("daktank_autotread_adaptive_detail", "1", true, false, "enhance track render quality as speed increases")

local debugmode = false


----------------------------------------------------------------
local gui, cam, util, math, mesh, table, string, render =
	  gui, cam, util, math, mesh, table, string, render

local rawset, rawget, Vector, Angle, worldToLocal, LocalToWorld, FrameTime, EffectData =
	  rawset, rawget, Vector, Angle, WorldToLocal, LocalToWorld, FrameTime, EffectData

local table_insert = table.insert

local mesh_Begin, mesh_End, mesh_Position, mesh_TexCoord, mesh_Normal, mesh_AdvanceVertex =
	  mesh.Begin, mesh.End, mesh.Position, mesh.TexCoord, mesh.Normal, mesh.AdvanceVertex

local render_SetMaterial, render_SetColorModulation =
	  render.SetMaterial, render.SetColorModulation

local math_Round, math_atan2, math_abs, math_sin, math_floor, math_ceil, math_max, math_min, math_Clamp =
	  math.Round, math.atan2, math.abs, math.sin, math.floor, math.ceil, math.max, math.min, math.Clamp

local math_rad = math.pi/180
local math_deg = 180/math.pi

local _mvec = Vector()
local _mvec_set, _mvec_add, _mvec_dot, _mvec_rotate, _mvec_length, _mvec_distance =
	  _mvec.Set, _mvec.Add, _mvec.Dot, _mvec.Rotate, _mvec.Length, _mvec.Distance

local _mang = Angle()
local _mang_forward, _mang_right, _mang_up =
	  _mang.Forward, _mang.Right, _mang.Up

local _mmat = Matrix()
local _mmat_setTranslation, _mmat_setAngles =
	  _mmat.SetTranslation, _mmat.SetAngles

local debugtype = {
	trace = {
		enabled = true,
		update  = function(self, ent, reset)
			if reset or not self.data[ent] then
				self.data[ent] = {}
			end
			return self.data[ent]
		end,
		render  = function(self, ent, data)
			surface.SetTextColor(255, 125, 0, 100)
			surface.SetFont("BudgetLabel")

			for k, v in pairs(data) do
				local p1 = v.StartPos:ToScreen()
				local p2 = v.HitPos:ToScreen()

				surface.SetDrawColor(255, 255, 0, 100)
				surface.DrawLine(p1.x, p1.y, p2.x, p2.y)

				surface.SetDrawColor(255, 0, 0, 100)
				surface.DrawRect(p1.x - 2, p1.y - 2, 4, 4)
				surface.DrawRect(p2.x - 2, p2.y - 2, 4, 4)

				local p3 = ((v.StartPos + v.HitPos)*0.5):ToScreen()
				surface.SetTextPos(p3.x, p3.y)
				surface.DrawText(math_floor(_mvec_length(v.StartPos - v.HitPos)))
			end
		end,
		data    = {},
	}
}

hook.Add("HUDPaint", "GBXDBGHUD", function()
	if not debugmode then
		return
	end

	for k, v in pairs(debugtype) do
		if not v.enabled then
			continue
		end

		for i, j in pairs(v.data) do
			if not i or not i:IsValid() then
				v.data[i] = nil
				break
			end

			v:render(i, j)
		end
	end
end)


----------------------------------------------------------------
function ENT:Initialize()
	_DakVar_INSTALL(self)
	self:_DakVar_CHANGED()
end

local waittime = 0
function ENT:_DakVar_CHANGED(name, old, new)
	self.dak_resetGearbox = CurTime() + waittime
	if self._DakVar_ONCHANGED then
		self:_DakVar_ONCHANGED(name, old, new)
	end
end

function ENT:Think()
	if not self.dak_resetInitial or self.dak_resetGearbox and self.dak_resetGearbox < CurTime() then
		self.dak_resetInitial = true
		self.dak_resetGearbox = nil
		self.dak_vehicleMode = self:GetVehicleMode()
		self:setup_gearbox(self.dak_vehicleMode)
		return
	end
	self:update_gearbox(self.dak_vehicleMode)
end

function ENT:Draw()
	self:DrawModel()

	if FrameTime() == 0 or gui.IsConsoleVisible() then -- or EyePos():DistToSqr(self:GetPos()) > 25000000 then
		self.dak_isVisible = nil
		return
	end

	self:render_gearbox(self.dak_vehicleMode)

	self.dak_isVisible = true
end

function ENT:OnRemove()
	local snapshot = self.dak_csents

	timer.Simple(0, function()
		if (self and self:IsValid()) or not snapshot then
			return
		end
		for k, v in pairs(snapshot) do
			if v and v:IsValid() then
				v:Remove()
			end
		end
	end)
end


----------------------------------------------------------------
function ENT:csents_create()
	if not self.dak_csents then
		self.dak_csents = {}
	end

	for k, v in pairs({"wheel"}) do
		if not self.dak_csents[v] or not self.dak_csents[v]:IsValid() then
			local CSEnt = ents.CreateClientside("base_anim")
			CSEnt.RenderGroup = RENDERGROUP_OPAQUE
			CSEnt:SetRenderMode(RENDERMODE_TRANSCOLOR)
			CSEnt:SetNoDraw(true)
			CSEnt:SetLOD(0)
			self.dak_csents[v] = CSEnt
		end
	end
end

function ENT:parentMatrix_Set()
	local baseEnt = self:GetNWEntity("Base")
	local forwardEnt = self:GetNWEntity("ForwardEnt")

	if baseEnt == NULL then baseEnt = self end
	if forwardEnt == NULL then forwardEnt = self end

	local matrix = self.dak_modelMatrix
	if not matrix then
		self.dak_modelMatrix = Matrix()
		matrix = self.dak_modelMatrix
	end

	_mmat_setTranslation(matrix, baseEnt:GetPos())
	_mmat_setAngles(matrix, forwardEnt:GetAngles())
end

function ENT:parentMatrix_Get()
	return self.dak_modelMatrix or self:GetWorldTransformMatrix()
end

function ENT:parentMatrix_Decomp()
	local matrix = self.dak_modelMatrix
	if not matrix then
		return self:GetPos(), self:GetAngles()
	end
	return matrix:GetTranslation(), matrix:GetAngles()
end

function ENT:parentMatrix_toWorld(lpos, lang)
	local pos, ang = self:parentMatrix_Decomp()
	return LocalToWorld(lpos, lang or Angle(), pos, ang)
end

function ENT:parentMatrix_toLocal(wpos, wang)
	local pos, ang = self:parentMatrix_Decomp()
	return WorldToLocal(wpos, wang or Angle(), pos, ang)
end


----------------------------------------------------------------
-- GEARBOX
local enableTracks = {tracked = true, halftracked = true}
local enableTurning = {wheeled = true, halftracked = true}

function ENT:setup_gearbox(vehicleMode)
	if not vehicleMode then return end

	self:csents_create()
	self:setup_wheels(vehicleMode)

	if enableTracks[vehicleMode] then
		self:setup_tracks(vehicleMode)
	end
end

function ENT:render_gearbox(vehicleMode)
	if not vehicleMode then return end

	self:render_wheels(vehicleMode)

	if enableTracks[vehicleMode] then
		self:render_tracks(vehicleMode)
	end
end

function ENT:update_gearbox(vehicleMode)
	if not vehicleMode or not self.dak_isVisible then return end

	self.dak_isVisible = nil

	self:parentMatrix_Set()

	self:update_wheels(vehicleMode)

	if enableTracks[vehicleMode] then
		self:update_tracks(vehicleMode)
	end
end


----------------------------------------------------------------
-- WHEELS
local function calcbounds(min, max, pos)
	if pos.x < min.x then min.x = pos.x elseif pos.x > max.x then max.x = pos.x end
	if pos.y < min.y then min.y = pos.y elseif pos.y > max.y then max.y = pos.y end
	if pos.z < min.z then min.z = pos.z elseif pos.z > max.z then max.z = pos.z end
end

local function resetbounds(self)
	local rendermin, rendermax = Vector(0, 0, -self.dak_wheels_groundClearance), Vector(0, 0, self.dak_wheels_groundClearance*2)
	local renderpos, renderang = self:parentMatrix_Decomp()

	renderpos, renderang = WorldToLocal(self:GetPos(), self:GetAngles(), renderpos, renderang)
	calcbounds(rendermin, rendermax, renderpos)

	for i = 1, self.dak_wheels_count_ri do
		calcbounds(rendermin, rendermax, self.dak_wheels_ri[i].posA + self.dak_wheels_ri[i].info.bound1)
		calcbounds(rendermin, rendermax, self.dak_wheels_le[i].posA + self.dak_wheels_le[i].info.bound2)
	end

	self.rendermin = rendermin*1.5
	self.rendermax = rendermax*1.5
	self:SetRenderBounds(self.rendermin, self.rendermax)
end

local function setup_modelinfo(self, vehicleMode, dak_wheels_info)
	if vehicleMode == "tracked" or vehicleMode == "halftracked" then
		if vehicleMode == "halftracked" then
			dak_wheels_info[0] = {
				name         = "halftrack",
				bodygroup    = self:GetHalfTWBGroup(),
				model        = self:GetHalfTWModel(),
				width        = self:GetHalfTWWidth(),
				radius       = self:GetHalfTWDiameter()*0.5,
				offsetx      = self:GetHalfTOffsetX(),
				offsety      = (1 - self:GetHalfTOffsetY())*self:GetWheelOffsetY(),
				trace_start  = self.dak_wheels_groundClearance,
				trace_length = self.dak_wheels_groundClearance*2,
			}
		end

		if self:GetDriveWEnabled() then
			dak_wheels_info[1] = {
				name      = "drive",
				bodygroup = self:GetDriveWBGroup(),
				model     = self:GetDriveWModel(),
				width     = self:GetDriveWWidth(),
				radius    = self:GetDriveWDiameter()*0.5,
				offsetz   = self:GetDriveWOffsetZ() + (self:GetDriveWDiameter()*0.5 + self:GetTrackHeight()),
			}
		end
		if self:GetIdlerWEnabled() then
			dak_wheels_info[3] = {
				name      = "idler",
				bodygroup = self:GetIdlerWBGroup(),
				model     = self:GetIdlerWModel(),
				width     = self:GetIdlerWWidth(),
				radius    = self:GetIdlerWDiameter()*0.5,
				offsetz   = self:GetIdlerWOffsetZ() + (self:GetIdlerWDiameter()*0.5 + self:GetTrackHeight()),
			}
		end

		if self:GetRollerWCount() > 0 then
			local bias1 = self:GetIdlerWOffsetZ() + (self:GetIdlerWDiameter()*0.5 + self:GetTrackHeight())
			local bias2 = self:GetDriveWOffsetZ() + (self:GetDriveWDiameter()*0.5 + self:GetTrackHeight())

			dak_wheels_info[4] = {
				name      = "roller",
				bodygroup = self:GetRollerWBGroup(),
				model     = self:GetRollerWModel(),
				width     = self:GetRollerWWidth(),
				radius    = self:GetRollerWDiameter()*0.5,
				offsetx   = self:a1z26Decode(self:GetRollerWOffsetsX()),
				offsetz   = self:GetRollerWOffsetZ(),
				bias1     = bias1 + self:GetRollerWBias()*(bias2 - bias1),
				bias2     = bias2 + self:GetRollerWBias()*(bias1 - bias2),
			}
		end
	end

	dak_wheels_info[2] = {
		name = "road",
		bodygroup    = self:GetRoadWBGroup(),
		model        = self:GetRoadWModel(),
		width        = self:GetRoadWWidth(),
		radius       = self:GetRoadWDiameter()*0.5,
		type         = self:GetRoadWType(),
		offsetx      = self:a1z26Decode(self:GetRoadWOffsetsX()),
		trace_start  = self.dak_wheels_groundClearance,
		trace_length = self.dak_wheels_groundClearance*2,
	}

	local dak_csents_wheel = self.dak_csents.wheel
	for _, info in pairs(dak_wheels_info) do
		if IsUselessModel(info.model) or not file.Exists(info.model, "GAME") then
			info.model = "models/hunter/blocks/cube025x025x025.mdl"
		end

		dak_csents_wheel:SetModel(info.model)
		dak_csents_wheel:DisableMatrix("RenderMultiply")
		dak_csents_wheel:SetupBones()

		// HitBoxBounds is the only function I could find that returns the correct min, max
		// of models that have bodygroups that extend past the model's obb bounding box
		// but it also gives (incorrectly) rotated vectors on some models
		local hmin, hmax, hbb = dak_csents_wheel:GetHitBoxBounds(0, 0)
		if hmin and hmax then
			hbb = hmax -  hmin
		end

		local obb = dak_csents_wheel:OBBMaxs() - dak_csents_wheel:OBBMins()
		local scale1, scale2, rotate

		// scale vector has to have the length of hbb but component order of obb
		// hack below should cover all cases
		if obb.y < obb.x and obb.y < obb.z then
			if hbb then
				if hbb.y < hbb.x and hbb.y < hbb.z then
				else
					obb.x = hbb.y
					obb.y = hbb.x
					obb.z = hbb.z
				end
			end

			scale1 = Vector(info.radius*2/obb.x, info.width/obb.y, info.radius*2/obb.z)
			scale2 = scale1*Vector(1, 0.5, 1)

		elseif obb.x < obb.y and obb.x < obb.z then
			if hbb then
				obb.x = hbb.y
				obb.y = hbb.x
				obb.z = hbb.z
			end

			scale1 = Vector(info.width/obb.x, info.radius*2/obb.y, info.radius*2/obb.z)
			scale2 = scale1*Vector(0.5, 1, 1)
			rotate = Angle(0, 90, 0)

		else
			scale1 = Vector(info.radius*2/obb.x, info.width/obb.y, info.radius*2/obb.z)
			scale2 = scale1*Vector(1, 0.5, 1)

		end

		info.scale1 = Matrix()
		info.scale2 = Matrix()
		if rotate then
			info.scale1:Rotate(rotate)
			info.scale2:Rotate(rotate)
		end
		info.scale1:SetScale(scale1)
		info.scale2:SetScale(scale2)

		info.bound1 = Vector(-info.radius, -info.width*0.5, -info.radius)
		info.bound2 = Vector(info.radius, info.width*0.5, info.radius)

		local bodygroup = string.rep("0", dak_csents_wheel:GetNumBodyGroups())
		for char = 1, #bodygroup do
			local isnum = tonumber(info.bodygroup[char])
			if isnum then
				bodygroup = string.format("%s%s%s", string.sub(bodygroup, 1, char - 1), isnum, string.sub(bodygroup, char + 1))
			end
		end
		info.bodygroup = bodygroup
	end

	local color = self:GetWheelColor()
	self.dak_wheels_color = Vector(color.x/255, color.y/255, color.z/255)

	local material = string.Explode(", ", self:GetWheelMaterial())
	if #material == 1 then
		dak_csents_wheel:SetMaterial(material[1])
		dak_csents_wheel:SetSubMaterial(nil)
	else
		dak_csents_wheel:SetMaterial(nil)
		for i = 1, #material, 2 do
			local id = tonumber(material[i])
			if id and material[i + 1] then
				dak_csents_wheel:SetSubMaterial(id, material[i + 1])
			end
		end
	end
end

local function addwheel(tbl, data)
	data.index = table_insert(tbl, data)
end

local function setwheel(tbl, index, data)
	data.index = index
	rawset(tbl, index, data)
end

function ENT:setup_wheels(vehicleMode)
	self.dak_wheels_info = {}
	local dak_wheels_info = self.dak_wheels_info

	self.dak_wheels_ri = {}
	self.dak_wheels_le = {}
	self.dak_wheels_groundClearance = self:GetWheelOffsetZ()

	setup_modelinfo(self, vehicleMode, dak_wheels_info)

	local pos_ri = Vector(self:GetWheelOffsetX(), -self:GetWheelOffsetY(), 0)
	local pos_le = Vector(self:GetWheelOffsetX(), self:GetWheelOffsetY(), 0)

	local wheelbase = self:GetWheelBase()
	local wheelbasemove = 0
	local wheeltracecount = 0

	-- halftrack wheel
	local wtype = 0
	local winfo = dak_wheels_info[wtype]

	if winfo then
		wheelbase = wheelbase*0.5
		wheelbasemove = wheelbase*0.5

		local pos = Vector(wheelbase*winfo.offsetx, winfo.offsety, winfo.trace_start)
		setwheel(self.dak_wheels_ri, 0, {trace = true, turn = 1, type = wtype, info = winfo, turn = 1, opp = 1, posL = pos + pos_ri, posA = pos + pos_ri, angL = Angle(0, 180, 0), angA = Angle(0, 180, 0)})

		local pos = Vector(wheelbase*winfo.offsetx, -winfo.offsety, winfo.trace_start)
		setwheel(self.dak_wheels_le, 0, {trace = true, turn = 1, type = wtype, info = winfo, turn = 1, opp = 1, posL = pos + pos_le, posA = pos + pos_le, angL = Angle(0, 0, 0), angA = Angle(0, 0, 0)})

		wheeltracecount = wheeltracecount + 1
	end

	-- drive wheel
	local wtype = 1
	local winfo = dak_wheels_info[wtype]

	if winfo then
		local pos = Vector(wheelbase*0.5 - wheelbasemove, 0, winfo.offsetz)
		addwheel(self.dak_wheels_ri, {type = wtype, info = winfo, opp = 1, posL = pos + pos_ri, posA = pos + pos_ri, angL = Angle(0, 180, 0), angA = Angle(0, 180, 0)})
		addwheel(self.dak_wheels_le, {type = wtype, info = winfo, opp = 1, posL = pos + pos_le, posA = pos + pos_le, angL = Angle(0, 0, 0), angA = Angle(0, 0, 0)})
	end

	-- road wheel
	local wtype = 2
	local winfo = dak_wheels_info[wtype]

	if winfo then
		local add_i, add_n
		if dak_wheels_info[1] and dak_wheels_info[3] then
			add_i = 1
			add_n = 1
		elseif dak_wheels_info[1] then
			add_i = 1
			add_n = 0
		elseif dak_wheels_info[3] then
			add_i = 0
			add_n = 0
		else
			add_i = 0
			add_n = -1
		end

		local turn_f, turn_r, wheeled
		if vehicleMode == "wheeled" then
			turn_f = self:GetRoadWTurnFront()
			turn_r = self:GetRoadWTurnRear()
			wheeled = true
		end

		local num_road = self:GetRoadWCount()
		for i = 0, num_road - 1 do
			local t0 = (i + add_i)/(num_road + add_n)
			local t1 = (i + add_i + 1)/(num_road + add_n)
			local pos = Vector(wheelbase*0.5 - wheelbase*(t0 - (winfo.offsetx[i + 1] or 0)*(t1 - t0)) - wheelbasemove, 0, winfo.trace_start)

			local turn, alt
			if wheeled then
				if i > (num_road - 1)*0.5 then
					turn = (i > (num_road  - 1) - turn_r) and -1
				else
					turn = (i < turn_f) and 1
				end
			elseif winfo.type == "interleave" then
				local even = num_road % 2 == 0 and 0 or 1
				alt = i % 2 == even and true or false
			end

			local opp = alt and -1 or 1

			addwheel(self.dak_wheels_ri, {trace = true, turn = turn, type = wtype, info = winfo, alt = alt, opp = opp, posL = pos + pos_ri, posA = pos + pos_ri, angL = Angle(0, alt and 0 or 180, 0), angA = Angle(0, alt and 0 or 180, 0)})
			addwheel(self.dak_wheels_le, {trace = true, turn = turn, type = wtype, info = winfo, alt = alt, opp = opp, posL = pos + pos_le, posA = pos + pos_le, angL = Angle(0, alt and 180 or 0, 0), angA = Angle(0, alt and 180 or 0, 0)})
			wheeltracecount = wheeltracecount + 1
		end
	end

	-- idler wheel
	local wtype = 3
	local winfo = dak_wheels_info[wtype]

	if winfo then
		local pos = Vector(-wheelbase*0.5 - wheelbasemove, 0, winfo.offsetz)
		addwheel(self.dak_wheels_ri, {type = wtype, info = winfo, opp = 1, posL = pos + pos_ri, posA = pos + pos_ri, angL = Angle(0, 180, 0), angA = Angle(0, 180, 0)})
		addwheel(self.dak_wheels_le, {type = wtype, info = winfo, opp = 1, posL = pos + pos_le, posA = pos + pos_le, angL = Angle(0, 0, 0), angA = Angle(0, 0, 0)})
	end

	-- roller wheel
	local wtype = 4
	local winfo = dak_wheels_info[wtype]

	if winfo then
		local num_roller = self:GetRollerWCount()
		for i = 0, num_roller - 1 do
			local t0 = (i + 1)/(num_roller + 1)
			local t1 = (i + 2)/(num_roller + 1)
			local pos = Vector(-wheelbase*0.5 + wheelbase*(t0 - (winfo.offsetx[i + 1] or 0)*(t1 - t0)) - wheelbasemove, 0, winfo.bias1 + t0*(winfo.bias2 - winfo.bias1) + winfo.offsetz)
			addwheel(self.dak_wheels_ri, {type = wtype, info = winfo, opp = 1, posL = pos + pos_ri, posA = pos + pos_ri, angL = Angle(0, 180, 0), angA = Angle(0, 180, 0)})
			addwheel(self.dak_wheels_le, {type = wtype, info = winfo, opp = 1, posL = pos + pos_le, posA = pos + pos_le, angL = Angle(0, 0, 0), angA = Angle(0, 0, 0)})
		end
	end

	self.dak_wheels_count_ri = #self.dak_wheels_ri
	self.dak_wheels_count_le = #self.dak_wheels_le
	self.dak_wheels_count_trace = wheeltracecount

	self.dak_wheels_yaw = 0
	self.dak_wheels_bias_fo = 0
	self.dak_wheels_bias_ri = 0
	self.dak_wheels_lastpos_ri = self:GetPos()
	self.dak_wheels_lastpos_le = self:GetPos()
	self.dak_wheels_lastrot_ri = 0
	self.dak_wheels_lastrot_le = 0
	self.dak_wheels_lastvel_ri = 0
	self.dak_wheels_lastvel_le = 0

	self.dak_tracks_textureres = self:GetTrackResolution()*self:GetTrackWidth()
	self.dak_tracks_texturemap = 1/self.dak_tracks_textureres

	self:update_wheels(vehicleMode)

	resetbounds(self)
end

local trace = {mask = MASK_SOLID_BRUSHONLY}

function ENT:update_wheels(vehicleMode)
	local ft = FrameTime()

	local dak_wheels_ri = self.dak_wheels_ri
	local dak_wheels_le = self.dak_wheels_le

	local basePos, baseAng = self:parentMatrix_Decomp()
	local baseUp = _mang_up(baseAng)

	local bfo = _mang_forward(baseAng)
	local bri =  _mang_right(baseAng)*self:GetWheelOffsetY()
	local radius = self:GetRoadWDiameter()*math.pi

	local pos_ri = basePos + bri
	local vel_ri = _mvec_dot(bfo, self.dak_wheels_lastpos_ri - pos_ri)
	local rot_ri = (360*vel_ri)/radius
	self.dak_wheels_lastvel_ri = vel_ri
	self.dak_wheels_lastpos_ri = pos_ri
	self.dak_wheels_lastrot_ri = self.dak_wheels_lastrot_ri - vel_ri/self.dak_tracks_textureres

	local pos_le = basePos - bri
	local vel_le = _mvec_dot(bfo, self.dak_wheels_lastpos_le - pos_le)
	local rot_le = (360*vel_le)/radius
	self.dak_wheels_lastvel_le = vel_le
	self.dak_wheels_lastpos_le = pos_le
	self.dak_wheels_lastrot_le = self.dak_wheels_lastrot_le - vel_le/self.dak_tracks_textureres

	local wheel_yaw
	if enableTurning[vehicleMode] then
		local yaw = self:GetNWFloat("WheelYaw", 0)
		local rate = ft*5
		self.dak_wheels_yaw = self.dak_wheels_yaw + rate*(yaw - self.dak_wheels_yaw)
		wheel_yaw = math_abs(self.dak_wheels_yaw) > 0.01 and self.dak_wheels_yaw or nil
	end

	local trace_length = self.dak_wheels_groundClearance
	local trace_count = self.dak_wheels_count_trace
	local trace_count_half = trace_count*0.5

	self.dak_wheels_bias_fo = self.dak_wheels_bias_fo + 5*ft*(self:GetNWFloat("Hydra", 0) - self.dak_wheels_bias_fo)
	self.dak_wheels_bias_ri = self.dak_wheels_bias_ri + 5*ft*(self:GetNWFloat("HydraSide", 0) - self.dak_wheels_bias_ri)

	local bias_fo = self.dak_wheels_bias_fo
	if math_abs(bias_fo) < 0.01 then
		bias_fo = nil
	end

	local bias_ri = self.dak_wheels_bias_ri*trace_length
	if math_abs(bias_ri) < 0.01 then
		bias_ri = nil
	end

	local fx, fxscale_ri, fxscale_le
	if cv_part:GetBool() then
		fx = EffectData()

		fxscale_ri = math_min(0.5, math_abs(vel_ri*0.5))
		if fxscale_ri == 0 then
			fxscale_ri = nil
		end

		fxscale_le = math_min(0.5, math_abs(vel_le*0.5))
		if fxscale_le == 0 then
			fxscale_le = nil
		end
	end

	if debugmode and debugtype.trace.enabled then
		debugtype.trace:update(self, true)
	end

	for i = vehicleMode == "halftracked" and 0 or 1, self.dak_wheels_count_ri do
		local wheel_ri = rawget(dak_wheels_ri, i)
		local wheel_le = rawget(dak_wheels_le, i)

		wheel_ri.angL.p = wheel_ri.angL.p + rot_ri*wheel_ri.opp
		wheel_le.angL.p = wheel_le.angL.p - rot_le*wheel_le.opp

		if wheel_ri.trace then
			if wheel_yaw and wheel_ri.turn then
				wheel_ri.angL.y = wheel_ri.angA.y - wheel_yaw*wheel_ri.turn
				wheel_le.angL.y = wheel_le.angA.y - wheel_yaw*wheel_ri.turn
			end

			local length_base = wheel_ri.info.trace_length
			local length_ri = 0
			local length_le = 0

			if bias_fo then
				if i > trace_count_half then
					length_base = length_base + (bias_fo*(trace_count_half - (trace_count - wheel_ri.index + 0.5))/trace_count_half*trace_length)
				else
					length_base = length_base - (bias_fo*(trace_count_half - (wheel_ri.index - 0.5))/trace_count_half*trace_length)
				end
			end
			if bias_ri then
				length_ri = bias_ri
				length_le = -bias_ri
			end

			local wheel_z = baseUp*(wheel_ri.trackHeight or wheel_ri.info.radius)

			-- right
			local wpos, _ = LocalToWorld(wheel_ri.posA, _mang, basePos, baseAng)
			trace.start = wpos
			trace.endpos = wpos - baseUp*(length_base + length_ri)

			local traceres = util.TraceLine(trace)
			local lpos, _ = WorldToLocal(traceres.HitPos + wheel_z, _mang, basePos, baseAng)
			wheel_ri.posL = lpos

			if fxscale_ri and traceres.Hit then
				fx:SetOrigin(traceres.HitPos)
				fx:SetScale(fxscale_ri)
				util.Effect("WheelDust", fx)
			end

			if debugmode and debugtype.trace.enabled then
				local data = debugtype.trace:update(self, false)
				rawset(data, i, traceres)
			end

			-- left
			local wpos, _ = LocalToWorld(wheel_le.posA, _mang, basePos, baseAng)
			trace.start = wpos
			trace.endpos = wpos - baseUp*(length_base + length_le)

			local traceres = util.TraceLine(trace)
			local lpos, _ = WorldToLocal(traceres.HitPos + wheel_z, _mang, basePos, baseAng)
			wheel_le.posL = lpos

			if fxscale_le and traceres.Hit then
				fx:SetOrigin(traceres.HitPos)
				fx:SetScale(fxscale_le)
				util.Effect("WheelDust", fx)
			end
		end
	end
end

function ENT:render_wheels(vehicleMode)
	local dak_csents_wheel = self.dak_csents.wheel
	if not dak_csents_wheel or not dak_csents_wheel:IsValid() then
		return
	end

	local dak_wheels_ri = self.dak_wheels_ri
	local dak_wheels_le = self.dak_wheels_le

	local prevtype, prevmodel, prevbody, prevalt
	local pos, ang = self:parentMatrix_Decomp()

	local color = self.dak_wheels_color
	render_SetColorModulation(color.x, color.y, color.z)

	for i = vehicleMode == "halftracked" and 0 or 1, self.dak_wheels_count_ri do
		local wheel_ri = rawget(dak_wheels_ri, i)
		local wheel_le = rawget(dak_wheels_le, i)

		local wheel_info = wheel_ri.info

		if prevtype ~= wheel_ri.type or prevalt ~= wheel_ri.alt then
			prevtype = wheel_ri.type

			if prevmodel ~= wheel_info.model then
				prevmodel = wheel_info.model
				dak_csents_wheel:SetModel(prevmodel)
			end

			if prevbody ~= wheel_info.bodygroup then
				prevbody = wheel_info.bodygroup
				dak_csents_wheel:SetBodyGroups(prevbody)
			end

			if prevalt ~= wheel_ri.alt then
				prevalt = wheel_ri.alt
			end

			dak_csents_wheel:EnableMatrix("RenderMultiply", prevalt and wheel_info.scale2 or wheel_info.scale1)
		end

		local wpos, wang = LocalToWorld(wheel_ri.posL, wheel_ri.angL, pos, ang)
		dak_csents_wheel:SetAngles(wang)
		dak_csents_wheel:SetPos(wpos)
		dak_csents_wheel:SetupBones()
		dak_csents_wheel:DrawModel()

		local wpos, wang = LocalToWorld(wheel_le.posL, wheel_le.angL, pos, ang)
		dak_csents_wheel:SetAngles(wang)
		dak_csents_wheel:SetPos(wpos)
		dak_csents_wheel:SetupBones()
		dak_csents_wheel:DrawModel()
	end

	render_SetColorModulation(1, 1, 1)
end


----------------------------------------------------------------
-- TRACKS
local track_textures = {}
local function createTrackTexture(path)
	local folders = { "dak/tracks/", "tanktrack_controller_new/" }
	local diffuse

	for k, v in pairs(folders) do
		local check = v .. path
		if track_textures[check] then
			return track_textures[check]
		end
		if file.Exists(string.format("materials/%s_d.vtf", check), "GAME") then
			path = check
			diffuse = string.format("%s_d.vtf", check)
			break
		end
	end

	if not diffuse then
		diffuse = "hunter/myplastic"
	end

	local shader = {
		["$basetexture"]         = diffuse,
		["$alphatest"]           = "1",
		["$nocull"]              = "1",
		["$color2"]              = "[1 1 1]",
		["$vertexcolor"]         = "1",
		["$angle"]               = "0",
		["$translate"]           = "[0.0 0.0 0.0]",
		["$center"]              = "[0.0 0.0 0.0]",
		["$newscale"]            = "[1.0 1.0 1.0]",
		["Proxies"]              = {
			["TextureTransform"] = {
				["translateVar"] = "$translate",
				["scaleVar"]     = "$newscale",
				["rotateVar"]    = "$angle",
				["centerVar"]    = "$center",
				["resultVar"]    = "$basetexturetransform",
			},
		}
	}

	track_textures[path] = CreateMaterial("daktracks" .. path .. SysTime(), "VertexLitGeneric", shader)

	return track_textures[path]
end

local trackverts_lines = {1, 3, 3, 4, 4, 2, 2, 6, 6, 5, 5, 1, 7, 8, 8, 8}
local trackverts_model = function(y, z)
	return {Vector(0, y*0.5, 0), Vector(0, -y*0.5, 0), Vector(0, y*0.375, z*0.5), Vector(0, -y*0.375, z*0.5), Vector(0, y*0.375, -z*0.5), Vector(0, -y*0.375, -z*0.5), Vector(0, 0, z*0.5), Vector(0, 0, -z*1.5)}
end
local _angle = Angle()

local function bisect_spline(index, spline, tensor, detail, step)
	local p1 = rawget(spline, index)
	local d1 = rawget(spline, index + 1) - p1
	for b = 1, detail - 1 do
		table_insert(spline, index + b, p1 + d1*(b/detail) + math_sin(step*b)*tensor)
	end
	return detail - 1
end

function ENT:setup_tracks(vehicleMode)
	local color = self:GetTrackColor()
	self.dak_tracks_color = Vector(color.x/255, color.y/255, color.z/255)

	self.dak_tracks_texture = createTrackTexture(self:GetTrackMaterial())
	self.dak_tracks_tension = 1 - self:GetTrackTension()
	self.dak_tracks_tensor  = Vector(0, 0, -self.dak_tracks_tension*3)

	self.dak_tracks_model = trackverts_model(self:GetTrackWidth(), self:GetTrackHeight())
	self.dak_tracks_modelcount = #self.dak_tracks_model

	self.dak_tracks_nodes_ri = {}
	self.dak_tracks_nodes_le = {}
	self.dak_tracks_nodescount_ri = 0
	self.dak_tracks_nodescount_le = 0

	self.dak_tracks_verts_ri = {}
	self.dak_tracks_verts_le = {}
	self.dak_tracks_vertscount_ri = 0
	self.dak_tracks_vertscount_le = 0

	self.dak_tracks_normals_ri = {}
	self.dak_tracks_normals_le = {}

	local trackHeight = self:GetTrackHeight()*0.5
	for i = 1, self.dak_wheels_count_ri do
		local trackRadius = self.dak_wheels_ri[i].info.radius + trackHeight
		self.dak_wheels_ri[i].trackRadius = trackRadius
		self.dak_wheels_le[i].trackRadius = trackRadius
		self.dak_wheels_ri[i].trackHeight = trackRadius + trackHeight + 0.1
		self.dak_wheels_le[i].trackHeight = trackRadius + trackHeight + 0.1
	end

	self:update_wheels(vehicleMode)

	self.dak_tracks_ready = nil
end

function ENT:update_tracks(vehicleMode)
	local min_detail = 4
	local max_detail = cv_dt:GetInt()
	local adaptive_detail = cv_ad:GetBool()

	local tension_det = 2--math_ceil(tracknodesdetail/2)
	local tension_rad = (180/tension_det)*math_rad
	local tension_val = self.dak_tracks_tension
	local tension_dir = self.dak_tracks_tensor

	for i = 1, 2 do
		local trackroots, trackrootscount, tracknodes, tracknodesdetail

		if i == 1 then
			trackroots = self.dak_wheels_ri
			trackrootscount = self.dak_wheels_count_ri
			tracknodes = self.dak_tracks_nodes_ri
			tracknodesdetail = adaptive_detail and (min_detail + math_floor(math_abs(self.dak_wheels_lastvel_ri)*0.5)) or max_detail
		else
			trackroots = self.dak_wheels_le
			trackrootscount = self.dak_wheels_count_le
			tracknodes = self.dak_tracks_nodes_le
			tracknodesdetail = adaptive_detail and (min_detail + math_floor(math_abs(self.dak_wheels_lastvel_le)*0.5)) or max_detail
		end

		if tracknodesdetail > max_detail then
			tracknodesdetail = max_detail
		end

		local tracknodesdetailrad = 1/(45/tracknodesdetail)
		local tracknodescount = 0
		local switchdir = -1

		for rootid = 1, trackrootscount do
			-- local root0 = rawget(trackroots, rootid - 1) or rawget(trackroots, trackrootscount)
			-- local root1 = rawget(trackroots, rootid)
			-- local root2 = rawget(trackroots, rootid + 1) or rawget(trackroots, 1)

			local root0 = rawget(trackroots, rootid == 1 and trackrootscount or rootid - 1)
			local root1 = rawget(trackroots, rootid)
			local root2 = rawget(trackroots, rootid == trackrootscount and 1 or rootid + 1)

			local pos1 = root1.posL
			local rad1 = root1.trackRadius

			local dir0 = root0.posL - pos1
			local dir2 = root2.posL - pos1

			local atan0, atan2

			if dir2.x < 0 then
				atan2 = math_atan2(-dir2.x, -dir2.z)*math_deg
				atan0 = math_atan2(dir0.x, dir0.z)*math_deg
			else
				atan2 = math_atan2(dir2.x, dir2.z)*math_deg
				atan0 = math_atan2(-dir0.x, -dir0.z)*math_deg
				rad1 = -rad1
				switchdir = switchdir + 1
			end

			local count = tracknodesdetail
			if (dir2.x > 0) ~= (dir0.x > 0) then
				count = math_Round(math_abs(atan2) - math_abs(atan0))*tracknodesdetailrad
			end

			if count > 0 then
				for k = 0, count do
					_angle.p = atan0 + (atan2 - atan0)*(k/count)
					tracknodescount = tracknodescount + 1
					rawset(tracknodes, tracknodescount, pos1 + _mang_forward(_angle)*rad1)
				end
			else
				_angle.p = atan0 + (atan2 - atan0)*0.5
				tracknodescount = tracknodescount + 1
				rawset(tracknodes, tracknodescount, pos1 + _mang_forward(_angle)*rad1)
			end

			if switchdir > 0 and tension_val > 0 then
				-- there is something wrong with this
				tracknodescount = tracknodescount + bisect_spline(tracknodescount - math_floor(math_max(0, count)) - 1, tracknodes, tension_dir, tension_det, tension_rad)
			end
		end

		if switchdir > 0 then
			rawset(tracknodes, tracknodescount + 1, rawget(tracknodes, 1))
			if tension_val > 0 then
				tracknodescount = tracknodescount + bisect_spline(tracknodescount, tracknodes, tension_dir, tension_det, tension_rad)
			end
		else
			local node0 = rawget(tracknodes, tracknodescount)
			local node2 = rawget(tracknodes, 1)
			local dir = node2 - node0

			local splitcount = trackrootscount
			local splitdroop = tension_val*(splitcount - 2)*2
			splitcount = splitcount - 1

			local splitcfold = 1/splitcount
			local splitsteps = 180*splitcfold

			for n = 1, splitcount - 1 do
				local node1 = node0 + dir*n*splitcfold

				if n < splitcount then
					local root0 = trackroots[splitcount - n + 1]
					local nextz = node1.z - math_sin(splitsteps*n*math_rad)*splitdroop
					local diffz = -(root0.posL.z - nextz)
					local radius = root0.trackRadius

					if diffz < radius then
						nextz = nextz + (radius - diffz)
					end

					node1.z = nextz
				end

				tracknodescount = tracknodescount + 1
				rawset(tracknodes, tracknodescount, node1)
			end

			rawset(tracknodes, tracknodescount + 1, rawget(tracknodes, 1))
		end

		if i == 1 then self.dak_tracks_nodescount_ri = tracknodescount else self.dak_tracks_nodescount_le = tracknodescount end
	end

	local trackmodel = self.dak_tracks_model
	local trackmodelcount = self.dak_tracks_modelcount
	local trackresolution = self.dak_tracks_texturemap

	for i = 1, 2 do
		local tracknodes, tracknodescount, trackverts, tracknormals

		if i == 1 then
			tracknodes = self.dak_tracks_nodes_ri
			tracknodescount = self.dak_tracks_nodescount_ri
			trackverts = self.dak_tracks_verts_ri
			tracknormals = self.dak_tracks_normals_ri
		else
			tracknodes = self.dak_tracks_nodes_le
			tracknodescount = self.dak_tracks_nodescount_le
			trackverts = self.dak_tracks_verts_le
			tracknormals = self.dak_tracks_normals_le
		end

		local trackvertscount = 0

		for nodeid = 1, tracknodescount do
			local node0 = rawget(tracknodes, nodeid - 1) or rawget(tracknodes, tracknodescount)
			local node1 = rawget(tracknodes, nodeid)
			local node2 = rawget(tracknodes, nodeid + 1) or rawget(tracknodes, 1)

			local dir = node2 - node0

			_angle.p = math_atan2(-dir.z, dir.x)*math_deg

			local normals = rawget(tracknormals, nodeid)
			if not normals then
				rawset(tracknormals, nodeid, {len = 0, up = Vector(0, 0, 1), dn = Vector(0, 0, -1), ri = Vector(0, 1, 0)})
				normals = rawget(tracknormals, nodeid)
			end

			normals.len = _mvec_distance(node1, node2)*trackresolution

			_mvec_set(normals.up, _mang_up(_angle))
			_mvec_set(normals.dn, -_mang_up(_angle))
			_mvec_set(normals.ri, _mang_right(_angle))

			for vertid = 1, trackmodelcount do
				trackvertscount = trackvertscount + 1

				local vertex = rawget(trackverts, trackvertscount)
				if not vertex then
					rawset(trackverts, trackvertscount, Vector())
					vertex = rawget(trackverts, trackvertscount)
				end

				_mvec_set(vertex, rawget(trackmodel, vertid))
				_mvec_rotate(vertex, _angle)
				_mvec_add(vertex, node1)

				rawset(trackverts, trackvertscount, vertex)
			end
		end

		for wrap = 1, 8 do
			trackvertscount = trackvertscount + 1

			local vertex = rawget(trackverts, trackvertscount)
			if not vertex then
				rawset(trackverts, trackvertscount, Vector())
				vertex = rawget(trackverts, trackvertscount)
			end

			_mvec_set(vertex, rawget(trackverts, wrap))

			rawset(trackverts, trackvertscount, vertex)
		end

		if i == 1 then self.dak_tracks_vertscount_ri = trackvertscount else self.dak_tracks_vertscount_le = trackvertscount end
	end

	self.dak_tracks_ready = true
end

local matfallback = Material("editor/wireframe")
local flip1 = Vector(-1, -1, 1)
local flip2 = Vector(1, -1, 1)

function ENT:render_tracks(vehicleMode)
	if not self.dak_tracks_ready then return end

	cam.PushModelMatrix(self:parentMatrix_Get())

	local texture = self.dak_tracks_texture
	if texture and self.dak_tracks_color then
		texture:SetVector("$color2", self.dak_tracks_color)
	end

	for i = 1, 2 do
		local tracknodes, tracknodescount, trackverts, trackvertscount, tracknormals, trackscroll
		if i == 1 then
			tracknodes = self.dak_tracks_nodes_ri
			tracknodescount = self.dak_tracks_nodescount_ri
			trackverts = self.dak_tracks_verts_ri
			trackvertscount = self.dak_tracks_vertscount_ri
			tracknormals = self.dak_tracks_normals_ri
			trackscroll = self.dak_wheels_lastrot_ri
		else
			tracknodes = self.dak_tracks_nodes_le
			tracknodescount = self.dak_tracks_nodescount_le
			trackverts = self.dak_tracks_verts_le
			trackvertscount = self.dak_tracks_vertscount_le
			tracknormals = self.dak_tracks_normals_le
			trackscroll = self.dak_wheels_lastrot_le
		end

		if texture then
			texture:SetVector("$newscale", i == 1 and flip1 or flip2)
		end

		render_SetMaterial(texture or matfallback)

		mesh_Begin(MATERIAL_QUADS, tracknodescount*7 + 7)

		local ytrans = trackscroll or 0
		local yshift = 0

		for nodeid = 1, tracknodescount do
			local vertid = nodeid + (nodeid - 1)*7
			local normals = rawget(tracknormals, nodeid)

			if not normals or vertid + 15 > trackvertscount then
				print("skipping", nodeid, vertid, "this should not happen")
				goto SKIP_NODE
			end

			local normal_up = normals.up or _mvec
			local normal_dn = normals.dn or _mvec
			local normal_ri = normals.ri or _mvec

			local yscale = normals.len or 0
			yshift = yshift - yscale

			local yfinal1 = ytrans + yshift
			local yfinal2 = yscale + yfinal1


			// UPPER LEFT
			mesh_Position(trackverts[vertid + 10])
			mesh_TexCoord(0, 0.143, yfinal1)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 2])
			mesh_TexCoord(0, 0.143, yfinal2)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid])
			mesh_TexCoord(0, 0, yfinal2)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 8])
			mesh_TexCoord(0, 0, yfinal1)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()


			// UPPER RIGHT
			mesh_Position(trackverts[vertid + 9])
			mesh_TexCoord(0, 1, yfinal1)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 1])
			mesh_TexCoord(0, 1, yfinal2)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 3])
			mesh_TexCoord(0, 0.857, yfinal2)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 11])
			mesh_TexCoord(0, 0.857, yfinal1)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()


			// UPPER MIDDLE
			mesh_Position(trackverts[vertid + 11])
			mesh_TexCoord(0, 0.857, yfinal1)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 3])
			mesh_TexCoord(0, 0.857, yfinal2)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 2])
			mesh_TexCoord(0, 0.143, yfinal2)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 10])
			mesh_TexCoord(0, 0.143, yfinal1)
			mesh_Normal(normal_up)
			mesh_AdvanceVertex()


			// LOWER LEFT
			mesh_Position(trackverts[vertid + 8])
			mesh_TexCoord(0, 0, yfinal1)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid])
			mesh_TexCoord(0, 0, yfinal2)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 4])
			mesh_TexCoord(0, 0.143, yfinal2)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 12])
			mesh_TexCoord(0, 0.143, yfinal1)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()


			// LOWER RIGHT
			mesh_Position(trackverts[vertid + 13])
			mesh_TexCoord(0, 0.857, yfinal1)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 5])
			mesh_TexCoord(0, 0.857, yfinal2)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 1])
			mesh_TexCoord(0, 1, yfinal2)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 9])
			mesh_TexCoord(0, 1, yfinal1)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()


			// LOWER MIDDLE
			mesh_Position(trackverts[vertid + 12])
			mesh_TexCoord(0, 0.143, yfinal1)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 4])
			mesh_TexCoord(0, 0.143, yfinal2)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 5])
			mesh_TexCoord(0, 0.857, yfinal2)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 13])
			mesh_TexCoord(0, 0.857, yfinal1)
			mesh_Normal(normal_dn)
			mesh_AdvanceVertex()


			// GUIDE
			mesh_Position(trackverts[vertid + 14])
			mesh_TexCoord(0, 0.143, yfinal1)
			mesh_Normal(normal_ri)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 6])
			mesh_TexCoord(0, 0.143, yfinal2)
			mesh_Normal(normal_ri)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 7])
			mesh_TexCoord(0, 0, yfinal2)
			mesh_Normal(normal_ri)
			mesh_AdvanceVertex()

			mesh_Position(trackverts[vertid + 15])
			mesh_TexCoord(0, 0, yfinal1)
			mesh_Normal(normal_ri)
			mesh_AdvanceVertex()

			::SKIP_NODE::
		end

		mesh_End()
	end

	render_SetColorModulation(1, 1, 1)
	cam.PopModelMatrix()
end
