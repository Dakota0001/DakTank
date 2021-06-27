
--[[

	Similar to editable NetworkVars but not limited by DTVar slots
	and actually clamps data when constraints are provided

	api:

	-- SHARED - required, call in entity initialize method
	_DakVar_INSTALL(DakEnt)


	-- SHARED - required, works like ent:SetupDatatables()
	function DakEnt:_DakVar_SETUP()
		DakEnt:_DakVar_REGISTER({type="Float", name="TurnAngle", min=0, max=180}, {title="Turn Angle", property=...})
	end


	-- SERVER/CLIENT - optional, called when a value changes
	function DakEnt:_DakVar_CHANGED(vname, newvalue, oldvalue)
	end

]]

----------------------------------------------------------------
local net, util, duplicator =
	  net, util, duplicator

local pairs, istable, isstring, isnumber, isvector, isfunction =
	  pairs, istable, isstring, isnumber, isvector, isfunction


if SERVER then
	util.AddNetworkString("_DakVar_NETWORK")

	net.Receive("_DakVar_NETWORK", function(len, pl)
		local eid = net.ReadUInt(32)
		local ent = Entity(eid)

		if not ent or not ent:IsValid() or not isfunction(ent._DakVar_SET) then
			return
		end

		if CPPI and pl ~= ent:CPPIGetOwner() then
			return
		end

		local vname = net.ReadString()
		local value = net.ReadString()

		ent:_DakVar_SET(vname, value)
	end)

	-- duplicator.RegisterEntityModifier("_DakVar_DUPED", function(pl, ent, data)
	-- 	if isfunction(ent._DakVar_RESTORE) then
	-- 		timer.Simple(0, function()
	-- 			ent:_DakVar_RESTORE(data)
	-- 		end)
	-- 	end
	-- end)
end

----------------------------------------------------------------
local _NOTIFY = {}
hook.Add("EntityNetworkedVarChanged", "_DakVar_NOTIFY", function(ent, name, old, new)
	if not _NOTIFY[ent] or not ent._DakVar_NOTIFY[name] or not isfunction(ent._DakVar_CHANGED) then
		return
	end
	ent._DakVar_CHANGED(ent, name, old, new)
end)

----------------------------------------------------------------
local sanitize = {}
sanitize.Vector = function(value, var)
	if isvector(value) then
		local min = var.min
		if isvector(min) then
			if value.x < min.x then value.x = min.x end
			if value.y < min.y then value.y = min.y end
			if value.z < min.z then value.z = min.z end
		end
		local max = var.max
		if isvector(max) then
			if value.x > max.x then value.x = max.x end
			if value.y > max.y then value.y = max.y end
			if value.z > max.z then value.z = max.z end
		end
	end
	return value
end
sanitize.Angle = function(value, var) return value end
sanitize.Float = function(value, var)
	if isnumber(value) then
		if isnumber(var.min) and value < var.min then
			value = var.min
		end
		if isnumber(var.max) and value > var.max then
			value = var.max
		end
	end
	return value
end
sanitize.Int = sanitize.Float
sanitize.Bool = function(value, var) return value end
sanitize.String = function(value, var)
	if istable(var.values) and not var.values[value] then
		return nil
	end
	return value
end

----------------------------------------------------------------
function _DakVar_INSTALL(DakEnt)
	_NOTIFY[DakEnt] = true

	local typeids = {}
	local editor = {}
	local order = 0

	DakEnt._DakVar_LOOKUP = {}
	DakEnt._DakVar_NOTIFY = {}

	DakEnt._DakVar_REGISTER = function(_, var, edit)
		if not istable(var) then return end
		local vtype, vname = var.type, var.name
		if not vtype or not vname or not sanitize[vtype] then
			MsgN("DakVar missing required keys: type, name")
			return
		end

		local vset = DakEnt["SetNW2" .. vtype]
		local vget = DakEnt["GetNW2" .. vtype]
		if not isfunction(vset) or not isfunction(vget) then return end

		if var.notify then DakEnt._DakVar_NOTIFY[vname] = true end
		if CLIENT and istable(edit) then
			editor[vname] = {var = var, edit = edit, order = order}
			order = order + 1
			DakEnt._DakVar_EDITOR_ALLOWED = true
		else
			edit = nil
		end

		typeids[vname] = vtype

		DakEnt["Set" .. vname] = function(_, value, nodupe)
			value = sanitize[vtype](value, var)
			if value == nil then
				return
			end

			vset(DakEnt, vname, value)

			DakEnt._DakVar_LOOKUP[vname] = value

			if SERVER and nodupe == nil then
				duplicator.StoreEntityModifier(DakEnt, "_DakVar_DUPED", DakEnt._DakVar_LOOKUP)
			end
		end

		DakEnt["Get" .. vname] = function(_)
			return vget(DakEnt, vname)
		end

		if SERVER then
			if var.default then DakEnt["Set" .. vname](DakEnt, var.default) end
		end
	end

	if SERVER then
		DakEnt._DakVar_RESTORE = function(_, data)
			if not istable(data) then
				return
			end
			for vname in pairs(typeids) do -- DakEnt._DakVar_LOOKUP) do
				if data[vname] and DakEnt["Set" .. vname] then
					DakEnt["Set" .. vname](DakEnt, data[vname], true)
				end
			end
			duplicator.StoreEntityModifier(DakEnt, "_DakVar_DUPED", DakEnt._DakVar_LOOKUP)
		end
	end

	if CLIENT then
		DakEnt._DakVar_EDITOR = function(_)
			return editor
		end
	end

	DakEnt._DakVar_GET = function(_, vname)
		if vname then
			if DakEnt["Get" .. vname] then
				return DakEnt["Get" .. vname](DakEnt, vname)
			end
			return
		end
		local dv = {}
		for vname in pairs(typeids) do -- DakEnt._DakVar_LOOKUP) do
			if DakEnt["Get" .. vname] then
				dv[vname] = DakEnt["Get" .. vname](DakEnt, vname)
			end
		end
		return dv
	end

	DakEnt._DakVar_SET = function(_, vname, value)
		if not isstring(vname) or not isstring(value) then
			return
		end
		if CLIENT then
			net.Start("_DakVar_NETWORK")
				net.WriteUInt(DakEnt:EntIndex(), 32)
				net.WriteString(vname)
				net.WriteString(value)
			net.SendToServer()
		else
			local k = typeids[vname]
			if not isstring(k) then
				return
			end
			local v = util.StringToType(value, k)
			if v == nil then
				return
			end
			if DakEnt["Set" .. vname] then
				DakEnt["Set" .. vname](DakEnt, v)
				return true
			end
		end
	end

	if DakEnt._DakVar_SETUP then DakEnt:_DakVar_SETUP() else MsgN(tostring(DakEnt) " has no :_DakVar_SETUP method!") end
	--if CLIENT and isfunction(DakEnt._DakVar_CHANGED) then timer.Simple(0, function() DakEnt:_DakVar_CHANGED() end) end
end

properties.Add("dakvar_editor", {
	MenuLabel = "Edit DakVars",
	Order = 90001,
	PrependSpacer = true,
	MenuIcon = "icon16/pencil.png",

	Filter = function(self, ent, pl)
		if not ent or not ent:IsValid() or not ent._DakVar_EDITOR_ALLOWED then
			return false
		end
		if not gamemode.Call("CanProperty", pl, "dakvar_editor", ent) then
			return false
		end
		return true
	end,

	Action = function(self, ent)
		local window = g_ContextMenu:Add("DFrame")
		local h = math.floor(ScrH() - 90)
		local w = 420

		window:SetPos(ScrW() - w - 30, ScrH() - h - 30)
		window:SetSize(w, h)
		window:SetDraggable(false)
		window:SetTitle(tostring(ent))
		window.btnMaxim:SetVisible(false)
		window.btnMinim:SetVisible(false)

		local control = window:Add("dakvar_editor")
		control:SetEntity(ent)
		control:Dock(FILL)
		control.OnEntityLost = function()
			window:Remove()
		end

		window.Paint = function(_, w, h)
			surface.SetDrawColor(75, 75, 75)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		window.OnRemove = function()
			hook.Run("dakvar_editor", ent, false)
		end
		hook.Run("dakvar_editor", ent, true)
	end
})
