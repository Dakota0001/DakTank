
-- STRING
do
	local PANEL = {}

	AccessorFunc(PANEL, "m_pRow", "Row")

	function PANEL:Init()
	end

	function PANEL:GetCategory()
		return self:GetRow().m_category
	end

	function PANEL:GetEntity()
		return self:GetRow().m_entity
	end

	function PANEL:GetWindow()
		return self:GetRow().m_window
	end

	function PANEL:Think()
		if not self:IsEditing() and isfunction(self.m_pRow.DataUpdate) then
			self.m_pRow:DataUpdate()
		end
	end

	function PANEL:ValueChanged(newval, bForce)
		if (self:IsEditing() or bForce) and isfunction(self.m_pRow.DataChanged) then
			if isfunction(self.m_pRow.DiffValue) and not self.m_pRow:DiffValue(newval) then
				return
			end
			self.m_pRow:DataChanged(newval)
		end
	end

	function PANEL:Setup(var, edit)
		self:Clear()

		local text = self:Add("DTextEntry")
		if (not var or not var.waitforenter) then text:SetUpdateOnType(true) end
		text:SetPaintBackground(false)
		text:Dock(FILL)

		self.IsEditing = function(self)
			return text:IsEditing()
		end

		self.IsEnabled = function(self)
			return text:IsEnabled()
		end
		self.SetEnabled = function(self, b)
			text:SetEnabled(b)
		end

		self.SetValue = function(self, val)
			text:SetText(util.TypeToString(val))
		end

		text.OnValueChange = function(text, newval)
			self:ValueChanged(newval)
		end
	end

	derma.DefineControl("dakvarprop_Generic", "", PANEL, "Panel")
end

-- FLOAT
do
	local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:GetDecimals()
		return 2
	end

	function PANEL:UpdateMinMax(var, edit, ctrl)
		if not edit.func then
			return
		end

		local getmax, getmin
		local entity = self:GetEntity()

		if edit.func.max and edit.func.max.num then
			local mul = edit.func.max.mul or 1
			local max = edit.func.max.num
			getmax = function()
				return entity[max](entity)*mul
			end
		end

		if edit.func.min and edit.func.min.num then
			local mul = edit.func.min.mul or 1
			local min = edit.func.min.num
			getmin = function()
				return entity[min](entity)*mul
			end
		end

		if getmax or getmin then
			if not self.overthink then
				self.overthink = ctrl.Think
			end
			ctrl.Think = function(sl)
				if self.overthink then
					self.overthink(sl)
				end
				if getmax and IsValid(entity) and ctrl:GetMax() ~= getmax() then
					local max = getmax()
					ctrl:SetMax(max)
					if ctrl:GetValue() > max then
						ctrl:SetValue(max)
						self:ValueChanged(max, true)
					end
				end
				if getmin and IsValid(entity) and ctrl:GetMin() ~= getmin() then
					local min = getmin()
					ctrl:SetMin(min)
					if ctrl:GetValue() < min then
						ctrl:SetValue(min)
						self:ValueChanged(min, true)
					end
				end
			end
		end
	end

	function PANEL:Setup(var, edit)
		self:Clear()

		var = var or {}

		local ctrl = self:Add("DNumSlider")
		ctrl:Dock(FILL)
		ctrl:SetDark(true)
		ctrl:SetDecimals(self:GetDecimals())

		ctrl:SetMin(var.min or 0)
		ctrl:SetMax(var.max or 1)

		--ctrl.Scratch:SetEnabled(false)
		self:GetRow().Label:SetMouseInputEnabled(true)
		ctrl.Scratch:SetParent(self:GetRow().Label)
		ctrl.Label:SetVisible(false)
		ctrl.TextArea:Dock(LEFT)
		ctrl.Slider:DockMargin(0, 3, 8, 3)

		self:UpdateMinMax(var, edit, ctrl)

		self.IsEditing = function(self)
			return ctrl:IsEditing()
		end

		self.IsEnabled = function(self)
			return ctrl:IsEnabled()
		end
		self.SetEnabled = function(self, b)
			ctrl:SetEnabled(b)
		end

		self.SetValue = function(self, val)
			ctrl:SetValue(val)
		end

		ctrl.OnValueChanged = function(ctrl, newval)
			self:ValueChanged(newval)
		end

		self.Paint = function()
			ctrl.Slider:SetVisible(self:IsEditing() or self:GetRow():IsChildHovered())
		end
	end

	derma.DefineControl("dakvarprop_Float", "", PANEL, "dakvarprop_Generic")
end

-- INT
do
	local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:GetDecimals()
		return 0
	end

	derma.DefineControl("dakvarprop_Int", "", PANEL, "dakvarprop_Float")
end

-- BOOL
do
	local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:Setup(var, edit)
		self:Clear()

		local ctrl = self:Add("DCheckBox")
		ctrl:SetPos(0, 2)

		self.IsEditing = function(self)
			return ctrl:IsEditing()
		end

		self.IsEnabled = function(self)
			return ctrl:IsEnabled()
		end
		self.SetEnabled = function(self, b)
			ctrl:SetEnabled(b)
		end

		self.SetValue = function(self, val)
			ctrl:SetChecked(tobool(val))
		end

		ctrl.OnChange = function(ctrl, newval)
			if newval then newval = 1 else newval = 0 end
			self:ValueChanged(newval)
		end
	end

	derma.DefineControl("dakvarprop_Bool", "", PANEL, "dakvarprop_Generic")
end

-- COMBOBOX
do
	local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:Setup(var, edit)
		var = var or {}

		self:Clear()

		local combo = vgui.Create("DComboBox", self)
		combo:Dock(FILL)
		combo:DockMargin(0, 1, 2, 2)

		for id, text in SortedPairs(var.values or {}) do
			combo:AddChoice(text, id)
		end

		self.IsEditing = function(self)
			return combo:IsMenuOpen()
		end

		self.SetValue = function(self, val)
			for id, data in pairs(combo.Data) do
				if data == val then
					combo:ChooseOptionID(id)
				end
			end
		end

		combo.OnSelect = function(_, id, val, data)
			self:ValueChanged(data, true)
		end

		combo.Paint = function(combo, w, h)
			if self:IsEditing() or self:GetRow():IsHovered() or self:GetRow():IsChildHovered() then
				DComboBox.Paint(combo, w, h)
			end
		end

		self:GetRow().AddChoice = function(self, value, data, select)
			combo:AddChoice(value, data, select)
		end

		self:GetRow().SetSelected = function(self, id)
			combo:ChooseOptionID(id)
		end

		self.IsEnabled = function(self)
			return combo:IsEnabled()
		end
		self.SetEnabled = function(self, b)
			combo:SetEnabled(b)
		end
	end

	derma.DefineControl("dakvarprop_Combo", "", PANEL, "dakvarprop_Generic")
end

-- Color
do
	local PANEL = {}

	function PANEL:Init()
	end

	function PANEL:Setup(var, edit)
		self:Clear()

		local text = self:Add("DLabel")
		text:Dock(FILL)
		text:SetTextColor(color_black)

		self.SetValue = function(self, val)
			self.ColorValue = Color(val.x, val.y, val.z, 255)
			text:SetText(string.format("%g %g %g", val.x, val.y, val.z))
		end

		local btn = self:Add("DButton")
		btn:Dock(LEFT)
		btn:DockMargin(0, 2, 4, 2)
		btn:SetWide(16)
		btn:SetText("")

		btn.Paint = function(btn, w, h)
			if self.ColorValue then
				surface.SetDrawColor(self.ColorValue)
				surface.DrawRect(2, 2, w - 4, h - 4)
			end
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local color

		btn.DoClick = function()
			if IsValid(color) then
				return
			end

			color = vgui.Create("DColorCombo", self:GetWindow())

			color.Mixer:SetAlphaBar(false)
			color.Mixer:SetWangs(true)
			color:SetupCloseButton(function()
				color:Remove()
				color = nil
			end)

			color.OnValueChanged = function(color, newcol)
				self:ValueChanged(Vector(newcol.r, newcol.g, newcol.b), true)
			end

			local x, y = self:GetWindow():ScreenToLocal(gui.MouseX(), gui.MouseY())
			color:Center()
			color:SetPos(color:GetX() - 8, y)
			color:SetColor(self.ColorValue)
		end

		self.IsEditing = function(self)
			return btn:IsDown()
		end

		self.IsEnabled = function(self)
			return btn:IsEnabled()
		end
		self.SetEnabled = function(self, b)
			btn:SetEnabled(b)
			text:SetEnabled(b)
		end
	end

	derma.DefineControl("dakvarprop_Color", "", PANEL, "dakvarprop_Generic")
end

-- string indexed offsets
do
	local PANEL = {}

	function PANEL:Init()
	end

	local function ResetFrame(self, frame, scroll, count)
		scroll:Clear()

		frame:SetSize(self:GetWindow():GetWide()*0.75, 24*math.Clamp(count, 6, 12) + 8)
		frame:Center()

		self.sliders = {}

		local function SliderChange(slider, value)
			self.context[slider.index] = value
			self:ValueChanged(self:GetEntity():a1z26Encode(self.context))
		end

		local function SliderPaint(slider, w, h)
			local lw = slider.Label:GetWide()
			local sw = w - lw

			surface.SetDrawColor(color_white)
			surface.DrawRect(0, 0, lw - 1, h - 1)
			surface.DrawRect(lw, 0, sw - 2, h - 1)
		end

		for i = 1, count do
			local slider = scroll:Add("DNumSlider")

			slider.Scratch:SetEnabled(false)
			slider.Scratch:SetVisible(false)
			slider.Label:SetText("Wheel " .. i)
			slider.Label:DockMargin(8, 0, 0, 0)

			slider:SetDark(true)
			slider:SetDecimals(1)
			slider:SetMin(-1)
			slider:SetMax(1)
			slider:SetValue(0)
			slider:SetTall(24)
			slider:Dock(TOP)

			slider.OnValueChanged = SliderChange
			slider.Paint = SliderPaint
			slider.index = i

			self.sliders[i] = slider
			if self.context[i] then
				slider:SetValue(self.context[i])
			end
		end
	end

	function PANEL:Setup(var, edit)
		self:Clear()

		if not edit.func or not edit.func.num then
			return
		end

		local entity = self:GetEntity()
		local func = entity[edit.func.num]
		if not isfunction(func) then
			return
		end

		self.sliders = {}
		self.context = {}

		self.SetValue = function(self, val)
			self.context = entity:a1z26Decode(val)
			for i = 1, #self.sliders do
				if self.context[i] and IsValid(self.sliders[i]) then
					self.sliders[i]:SetValue(self.context[i])
				end
			end
		end

		local btn = self:Add("DButton")
		btn:SetText("open offset editor")
		btn:Dock(FILL)
		btn:DockMargin(0, 1, 5, 2)

		btn.Paint = function(btn, w, h)
			surface.SetDrawColor(225, 225, 225)
			surface.DrawRect(0, 0, w, h)
		end

		local frame, lastcount
		btn.DoClick = function()
			if IsValid(frame) then
				return
			end

			lastcount = nil
			frame = vgui.Create("DFrame", self:GetWindow())
			frame:SetTitle(string.format("%s - %s", edit.category, edit.title))
			frame.btnMaxim:SetVisible(false)
			frame.btnMinim:SetVisible(false)

			local scroll = frame:Add("DScrollPanel")
			scroll:Dock(FILL)

			frame.Paint = function(_, w, h)
				local count = IsValid(entity) and func(entity)
				if not count then return end

				if lastcount ~= count then
					ResetFrame(self, frame, scroll, count)
					lastcount = count
					return
				end

				surface.SetDrawColor(75, 75, 75)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(0, 0, 0)
				surface.DrawOutlinedRect(0, 0, w, h)
			end
		end

		self.IsEditing = function(self)
			return btn:IsDown() or IsValid(frame)
		end
		self.IsEnabled = function(self)
			return btn:IsEnabled()
		end
		self.SetEnabled = function(self, b)
			btn:SetEnabled(b)
		end
	end

	derma.DefineControl("dakvarprop_idxoff", "", PANEL, "dakvarprop_Generic")
end
