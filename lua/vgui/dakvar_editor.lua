
do
	local tblRow = vgui.RegisterTable({
		Init = function(self)
			self:Dock(TOP)

			self.Label = self:Add("DLabel")
			self.Label:Dock(LEFT)
			self.Label:DockMargin(4, 2, 2, 2)

			self.Container = self:Add("Panel")
			self.Container:Dock(FILL)
		end,

		PerformLayout = function(self)
			self:SetTall(20)
			self.Label:SetWide(self:GetWide()*0.33)
		end,

		Setup = function(self, var, edit)
			self.Container:Clear()

			local rowtype = edit.property or var.type
			local rowprop = "dakvarprop_" .. rowtype

			if not vgui.GetControlTable(rowprop) then
				if rowtype == "Vector" then rowtype = "Generic" end
				if rowtype == "Angle" then rowtype = "Generic" end
				if rowtype == "String" and var.values then rowtype = "Combo" end
				rowprop = "dakvarprop_" .. rowtype
			end

			if vgui.GetControlTable(rowprop) then
				self.Inner = self.Container:Add(rowprop)
			end

			if not IsValid(self.Inner) then
				self.Inner = self.Container:Add("dakvarprop_Generic")
			end

			self.Inner:SetRow(self)
			self.Inner:Dock(FILL)
			self.Inner:Setup(var, edit)

			self.Inner:SetEnabled(self:IsEnabled())

			self.IsEnabled = function(self)
				return self.Inner:IsEnabled()
			end
			self.SetEnabled = function(self, b)
				self:SetVisible(b)
				self.Inner:SetEnabled(b)
			end
		end,

		DiffValue = function(self, val)
			return self.CacheValue ~= val
		end,

		SetValue = function(self, val)
			if self.CacheValue and self.CacheValue == val then return end
			self.CacheValue = val

			if IsValid(self.Inner) then
				self.Inner:SetValue(val)
			end
		end,

		GetValue = function(self)
			return self.CacheValue
		end,

		Paint = function(self, w, h)
			if not IsValid(self.Inner) then return end

			local Skin = self:GetSkin()
			local editing = self.Inner:IsEditing()
			local disabled = not self.Inner:IsEnabled() or not self:IsEnabled()

			if disabled then
				surface.SetDrawColor(Skin.Colours.Properties.Column_Disabled)
				surface.DrawRect(w*0.33, 0, w, h)
				surface.DrawRect(0, 0, w*0.33, h)
			elseif editing then
				surface.SetDrawColor(Skin.Colours.Properties.Column_Selected)
				surface.DrawRect(0, 0, w*0.33, h)
			elseif self.m_special then
				surface.SetDrawColor(self.m_special)
				--surface.DrawRect(w*0.33, 0, w, h)
				surface.DrawRect(0, 0, w*0.33, h)
			end


			surface.SetDrawColor(Skin.Colours.Properties.Border)
			surface.DrawRect(w - 1, 0, 1, h)
			surface.DrawRect(w*0.33, 0, 1, h)
			surface.DrawRect(0, h - 1, w, 1)

			if disabled then
				self.Label:SetTextColor(Skin.Colours.Properties.Label_Disabled)
			elseif editing then
				self.Label:SetTextColor(Skin.Colours.Properties.Label_Selected)
			else
				self.Label:SetTextColor(Skin.Colours.Properties.Label_Normal)
			end
		end
	}, "Panel")

	local tblCategory = vgui.RegisterTable({
		Init = function(self)
			self:DockMargin(0, 0, 1, 0)
			self:DockPadding(0, 1, 2, 2)
			self:Dock(TOP)
			self.Rows = {}

			self.Header = self:Add("Panel")

			self.Label = self.Header:Add("DLabel")
			self.Label:Dock(FILL)
			self.Label:SetContentAlignment(4)

			self.Expand = self.Header:Add("DExpandButton")
			self.Expand:Dock(LEFT)
			self.Expand:SetSize(16, 16)
			self.Expand:DockMargin(0, 4, 0, 4)
			self.Expand:SetExpanded(true)
			self.Expand.DoClick = function()
				self.Container:SetVisible(not self.Container:IsVisible())
				self.Expand:SetExpanded(self.Container:IsVisible())
				self:InvalidateLayout()
			end

			self.Header:Dock(TOP)

			self.Container = self:Add("Panel")
			self.Container:Dock(TOP)
			self.Container:DockMargin(16, 0, 0, 0)
			self.Container.Paint = function(pnl, w, h)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, 0, w, h)
			end
		end,

		PerformLayout = function(self)
			self.Container:SizeToChildren(false, true)
			self:SizeToChildren(false, true)

			local Skin = self:GetSkin()
			self.Label:SetTextColor(Skin.Colours.Properties.Title)
			self.Label:DockMargin(4, 0, 0, 0)
		end,

		GetRow = function(self, name, bCreate)
			if IsValid(self.Rows[name]) then return self.Rows[name] end
			if not bCreate then return end

			local row = self.Container:Add(tblRow)

			row.Label:SetText(name)
			row.m_category = self

			self.Rows[name] = row

			return row
		end,

		Paint = function(self, w, h)
			local Skin = self:GetSkin()
			surface.SetDrawColor(Skin.Colours.Properties.Border)
			surface.DrawRect(0, 0, w, h)
		end
	}, "Panel")

	local PANEL = {}

	function PANEL:Init()
		self.Categories = {}
	end

	function PANEL:PerformLayout()
		self:SizeToChildren(false, true)
	end

	function PANEL:Clear()
		self:GetCanvas():Clear()
	end

	function PANEL:GetCanvas()
		if not IsValid(self.Canvas) then
			self.Canvas = self:Add("DScrollPanel")
			self.Canvas:Dock(FILL)
		end

		return self.Canvas
	end

	function PANEL:GetCategory(name, bCreate)
		local cat = self.Categories[name]
		if IsValid(cat) then return cat end

		if not bCreate then return end

		cat = self:GetCanvas():Add(tblCategory)
		cat.Label:SetText(name)
		self.Categories[name] = cat
		return cat
	end

	function PANEL:CreateRow(category, name)
		local cat = self:GetCategory(category, true)
		return cat:GetRow(name, true)
	end

	derma.DefineControl("dakvar_properties", "", PANEL, "Panel")
end

do
	local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:SetEntity(entity)
		if self.m_Entity == entity then return end

		self.m_Entity = entity
		self:RebuildControls()
	end

	function PANEL:EntityLost()
		self:Clear()
		self:OnEntityLost()
	end

	function PANEL:OnEntityLost()
	end

	PANEL.AllowAutoRefresh = true

	function PANEL:PreAutoRefresh()
	end

	function PANEL:PostAutoRefresh()
		self:RebuildControls()
	end

	local function SetVisible(self, vname, value)
		if not self.hidepanels[vname] then
			return
		end

		local hidecat = {}
		for k, v in pairs(self.hidepanels[vname]) do
			if v[value] ~= nil then k:SetEnabled(false) else k:SetEnabled(true) end
			hidecat[k.m_category] = true
		end

		-- for cat in pairs(hidecat) do
		-- 	cat:InvalidateChildren()
		-- end

		for cat in pairs(hidecat) do
			local hide = false

			for _, row in pairs(cat.Rows) do
				if row:IsEnabled() then
					hide = true
					break
				end
			end

			cat:SetVisible(hide)
			cat:InvalidateChildren()
			cat:InvalidateLayout()
		end
	end

	function PANEL:RebuildControls()
		self:Clear()

		if not IsValid(self.m_Entity) then return end
		if not self.m_Entity._DakVar_EDITOR then return end

		self.hidepanels = {}

		local editor = self.m_Entity:_DakVar_EDITOR()

		for vname, vdata in SortedPairsByMemberValue(editor, "order") do
			if istable(vdata.var) and istable(vdata.edit) then
				self:EditVariable(vname, vdata.var, vdata.edit, editor)
			end
		end

		for k, v in pairs(self.hidepanels) do
			SetVisible(self, k, self.m_Entity:_DakVar_GET(k))
		end
	end

	local m_special = Color(245, 255, 245)
	function PANEL:EditVariable(vname, var, edit, editor)
		if not isstring(var.type) then return end

		local row = self:CreateRow(edit.category or "General", edit.title or vname)
		row.m_window = self
		row.m_entity = self.m_Entity

		row:Setup(var, edit)

		if edit.help then row:SetTooltip(edit.help) end
		if edit.hidepanel then
			for k, v in pairs(edit.hidepanel) do
				if not self.hidepanels[k] then
					self.hidepanels[k] = {}
				end
				self.hidepanels[k][row] = v
				row.m_special = editor[k].edit.rowcolor
			end
		end

		if edit.rowcolor then
			row.m_special = edit.rowcolor
		end

		row.DataUpdate = function(_)
			if not IsValid(self.m_Entity) then self:EntityLost() return end
			row:SetValue(self.m_Entity:_DakVar_GET(vname))
		end

		row.DataChanged = function(_, val)
			if not IsValid(self.m_Entity) then self:EntityLost() return end
			self.m_Entity:_DakVar_SET(vname, tostring(val))
			SetVisible(self, vname, tostring(val))
		end
	end

	derma.DefineControl("dakvar_editor", "", PANEL, "dakvar_properties")
end
