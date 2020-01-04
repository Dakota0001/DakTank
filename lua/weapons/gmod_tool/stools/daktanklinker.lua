 
TOOL.Category = "DakTank"
TOOL.Name = "#Tool.daktanklinker.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

TOOL.EntList = {}
TOOL.ColorList = {}
TOOL.LastLeftClick = CurTime()
TOOL.LastRightClick = CurTime()
TOOL.LastReload = CurTime()

TOOL.ClientConVar[ "DakChatFeedback" ] = 1
TOOL.ClientConVar[ "DakCompOverride" ] = 1


if (CLIENT) then
language.Add( "Tool.daktanklinker.listname", "DakTank Linker" )
language.Add( "Tool.daktanklinker.name", "DakTank Linker" )
language.Add( "Tool.daktanklinker.desc", "Links stuff to things." )
language.Add( "Tool.daktanklinker.0", "Left click to select the gearbox, AL magazine, or turret motor. Right click on the fuel, gun, or turret control. Also links crew members to things." )
end
--TOOL.ClientConVar[ "myparameter" ] = "fubar"
TOOL.ClientConVar[ "ArmorType" ]   = "RHA"

function TOOL:LeftClick( trace )
	if CurTime()>self.LastLeftClick then
		local Target = trace.Entity
		if(string.Explode("_",Target:GetClass(),false)[1] == "dak") then
			if Target:GetClass()=="dak_tankcore" then
				if (SERVER) or (game.SinglePlayer()) then
					for i = 1, table.Count(Target.Composites) do
						table.insert( self.EntList, table.Count(self.EntList)+1, Target.Composites[i] )
						table.insert( self.ColorList, table.Count(self.ColorList)+1, Target.Composites[i]:GetColor() )
						Target.Composites[i]:SetColor(Color(0,255,0,255))
					end
				end
			else
				if table.HasValue( self.EntList, Target ) then
					self.Ent1 = Target
					if (CLIENT) or (game.SinglePlayer()) then
						self:GetOwner():EmitSound("/items/ammocrate_open.wav")
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("Entity deselected.")
						end
					end
					self.Key = table.KeyFromValue( self.EntList, self.Ent1 )
					self.Ent1:SetColor(self.ColorList[self.Key])
					table.remove( self.EntList, self.Key )
					table.remove( self.ColorList, self.Key )
				else
					if Target:GetClass() == "dak_teautoloadingmodule" or Target:GetClass() == "dak_turretmotor" or Target:GetClass() == "dak_crew" and (#self.EntList==0 or self.EntList[1]:GetClass()==Target:GetClass()) then
						self.Ent1 = Target
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_open.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								self:GetOwner():ChatPrint("Entity selected.")
							end
						end
						table.insert( self.EntList, table.Count(self.EntList)+1, self.Ent1 )
						table.insert( self.ColorList, table.Count(self.ColorList)+1, self.Ent1:GetColor() )
						self.Ent1:SetColor(Color(0,255,0,255))
					else
						self:GetOwner():EmitSound("items/medshotno1.wav")
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("Entity cannot be linked to anything.")
						end
					end
				end
			end
		end
		if Target:GetClass() == "prop_physics" then
			if table.HasValue( self.EntList, Target ) then
				self.Ent1 = Target
				if (CLIENT) or (game.SinglePlayer()) then
					self:GetOwner():EmitSound("/items/ammocrate_open.wav")
					if self:GetClientNumber( "DakChatFeedback" ) == 1 then
						self:GetOwner():ChatPrint("Entity deselected.")
					end
				end
				self.Key = table.KeyFromValue( self.EntList, self.Ent1 )
				self.Ent1:SetColor(self.ColorList[self.Key])
				table.remove( self.EntList, self.Key )
				table.remove( self.ColorList, self.Key )
			else
				if IsValid(self.EntList[1]) and IsValid(Target) then
					if self.EntList[1]:GetClass()==Target:GetClass() then
						self.SameClass = true
					else
						self.SameClass = false
					end
				else
					self.SameClass = false
				end
				if (#self.EntList==0 or self.EntList[1]:GetClass()==Target:GetClass()) then
					self.Ent1 = Target
					if (CLIENT) or (game.SinglePlayer()) then
						self:GetOwner():EmitSound("/items/ammocrate_open.wav")
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("Entity selected.")
						end
					end
					table.insert( self.EntList, table.Count(self.EntList)+1, self.Ent1 )
					table.insert( self.ColorList, table.Count(self.ColorList)+1, self.Ent1:GetColor() )
					self.Ent1:SetColor(Color(0,255,0,255))
				else
					self:GetOwner():EmitSound("items/medshotno1.wav")
					if self:GetClientNumber( "DakChatFeedback" ) == 1 then
						self:GetOwner():ChatPrint("Do not select multiple entity types when selecting composites.")
					end
				end
			end
		end
	self.LastLeftClick = CurTime()
	end
end
 
function TOOL:RightClick( trace )
	if CurTime()>self.LastRightClick then
		local Target = trace.Entity
		if IsValid(self.EntList[1]) then
			if self.EntList[1]:GetClass() == "dak_crew" then
				if(Target:GetClass() == "dak_tegearbox" or Target:GetClass() == "dak_tegearboxnew" or Target:GetClass() == "dak_tegun" or Target:GetClass() == "dak_teautogun") then
					if Target:GetClass() == "dak_tegearbox" or Target:GetClass() == "dak_tegearboxnew" then
						self.Ent2 = Target
						self.EntList[1].DakEntity = self.Ent2
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_close.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								if #self.EntList > 1 then
									self:GetOwner():ChatPrint("Only allows one crew, first selected linked.")
								else
									self:GetOwner():ChatPrint("Crew linked.")
								end
							end
						end
						if table.Count(self.EntList)>0 then
							for i = 1, table.Count(self.EntList) do
								self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
								if self.EntList[self.Key]:IsValid() then
									self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
								end
							end
						end
						self.EntList = {}
						self.ColorList = {}
					end
					if Target:GetClass() == "dak_tegun" then
						self.Ent2 = Target
						if table.Count(self.EntList)>0 then
							for i = 1, table.Count(self.EntList) do
								self.EntList[i].DakEntity = self.Ent2
								self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
								if self.EntList[self.Key]:IsValid() then
									self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
								end
							end
						end
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_close.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								self:GetOwner():ChatPrint("Crew linked.")
							end
						end
						if table.Count(self.EntList)>0 then
							for i = 1, table.Count(self.EntList) do
								self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
								if self.EntList[self.Key]:IsValid() then
									self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
								end
							end
						end
						self.EntList = {}
						self.ColorList = {}
					end
					if(Target:GetClass() == "dak_teautogun") then
						if Target.IsAutoLoader == 1 then
							self:GetOwner():EmitSound("items/medshotno1.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								self:GetOwner():ChatPrint("This is not a valid link.")
							end
						else
							self.Ent2 = Target
							if table.Count(self.EntList)>0 then
								for i = 1, table.Count(self.EntList) do
									self.EntList[i].DakEntity = self.Ent2
									self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
									if self.EntList[self.Key]:IsValid() then
										self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
									end
								end
							end
							if (CLIENT) or (game.SinglePlayer()) then
								self:GetOwner():EmitSound("/items/ammocrate_close.wav")
								if self:GetClientNumber( "DakChatFeedback" ) == 1 then
									self:GetOwner():ChatPrint("Crew linked.")
								end
							end
							if table.Count(self.EntList)>0 then
								for i = 1, table.Count(self.EntList) do
									self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
									if self.EntList[self.Key]:IsValid() then
										self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
									end
								end
							end
							self.EntList = {}
							self.ColorList = {}
						end
					end
				else
					self:GetOwner():EmitSound("items/medshotno1.wav")
					if self:GetClientNumber( "DakChatFeedback" ) == 1 then
						self:GetOwner():ChatPrint("This is not a valid link.")
					end
				end
			else	
				if(Target:GetClass() == "dak_tankcore") then
					if self.EntList[1]:GetClass() == "prop_physics" then
						if self:GetClientInfo("ArmorType") ~= "ERA" then
							if self:GetClientNumber( "DakCompOverride" ) == 1 then
								Target.Composites = self.EntList
							else
								table.Add(Target.Composites,self.EntList)
							end
						end
						self:GetOwner():EmitSound("/items/ammocrate_close.wav")
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("Composite armor hitpool set, select tankcore to select all composites if you wish to edit them.")
						end
						if table.Count(self.EntList)>0 then
							for i = 1, table.Count(self.EntList) do
								self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
								if self.EntList[self.Key]:IsValid() then
									if self.EntList[self.Key].EntityMods==nil then self.EntList[self.Key].EntityMods = {} end
									self.EntList[self.Key].EntityMods.CompositeType = self:GetClientInfo("ArmorType")
									self.EntList[self.Key].EntityMods.CompKEMult = 9.2
									self.EntList[self.Key].EntityMods.CompCEMult = 18.4
									if self:GetClientInfo("ArmorType") == "NERA" then
										self.EntList[self.Key].EntityMods.CompKEMult = 9.2
										self.EntList[self.Key].EntityMods.CompCEMult = 18.4
										self.EntList[self.Key].EntityMods.DakName = "NERA"
									end
									if self:GetClientInfo("ArmorType") == "Textolite" then
										self.EntList[self.Key].EntityMods.CompKEMult = 10.4
										self.EntList[self.Key].EntityMods.CompCEMult = 14
										self.EntList[self.Key].EntityMods.DakName = "Textolite"
									end
									if self:GetClientInfo("ArmorType") == "ERA" then
										self.EntList[self.Key].EntityMods.CompKEMult = 2.5
										self.EntList[self.Key].EntityMods.CompCEMult = 88.9
										self.EntList[self.Key].EntityMods.DakName = "ERA"
										self.EntList[self.Key].DakHealth = 5
										self.EntList[self.Key].DakMaxHealth = 5
										self.EntList[self.Key].EntityMods.IsERA = 1
									end
									self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
								end
							end
						end
						self.EntList = {}
						self.ColorList = {}
					else
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("Armor can only be linked to tankcore.")
						end
					end
				end
				if(Target:GetClass() == "dak_teautogun") then
					if self.EntList[1]:GetClass() == "dak_teautoloadingmodule" then
						self.Ent2 = Target
						self.EntList[1].DakGun = self.Ent2
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_close.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								if #self.EntList > 1 then
									self:GetOwner():ChatPrint("Only allows one magazine, first selected linked.")
								else
									self:GetOwner():ChatPrint("Module linked.")
								end
							end
						end
						if table.Count(self.EntList)>0 then
							for i = 1, table.Count(self.EntList) do
								self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
								if self.EntList[self.Key]:IsValid() then
									self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
								end
							end
						end
						self.EntList = {}
						self.ColorList = {}
					else
						self:GetOwner():EmitSound("items/medshotno1.wav")
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("This is not a valid link.")
						end
					end
				end
				if(Target:GetClass() == "dak_turretcontrol") then
					if self.EntList[1]:GetClass() == "dak_turretmotor" then
						for i = 1, #self.EntList do
							if self.EntList[i]:GetClass() == "dak_turretmotor" then
								self.EntList[i].TurretController = Target 
							end
						end
						table.Add( Target.DakTurretMotors, self.EntList )
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_close.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								if #self.EntList > 1 then
									self:GetOwner():ChatPrint("Turret motors linked.")
								else
									self:GetOwner():ChatPrint("Turret motor linked.")
								end
							end
						end
						if table.Count(self.EntList)>0 then
							for i = 1, table.Count(self.EntList) do
								self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
								if self.EntList[self.Key]:IsValid() then
									self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
								end
							end
						end
						self.EntList = {}
						self.ColorList = {}
					else
						self:GetOwner():EmitSound("items/medshotno1.wav")
						if self:GetClientNumber( "DakChatFeedback" ) == 1 then
							self:GetOwner():ChatPrint("This is not a valid link.")
						end
					end
				end	
			end
		end
	self.LastRightClick = CurTime()
	end
end
 
function TOOL:Reload()
	if CurTime()>self.LastReload then
		if table.Count(self.EntList)>0 then
			for i = 1, table.Count(self.EntList) do
				self.Key = table.KeyFromValue( self.EntList, self.EntList[i] )
				if self.EntList[self.Key]:IsValid() then
					self.EntList[self.Key]:SetColor(self.ColorList[self.Key])
				end
			end
		end
		self.EntList = {}
		self.ColorList = {}
		if (CLIENT) or (game.SinglePlayer()) then
			self:GetOwner():EmitSound("npc/scanner/scanner_siren1.wav")
			if self:GetClientNumber( "DakChatFeedback" ) == 1 then
				self:GetOwner():ChatPrint("Tool reloaded.")
			end
		end
	self.LastReload = CurTime()
	end
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header",{Text = "DakTank Linker", Description	= "This tool just links magazines to autoloaders, and turret motors to turret controls, also links crew to things. Ammo is automatically found on the contraption by the gun."})	
	panel:AddControl("CheckBox", {Label = "Chat Feedback", Description ="Check for feedback in chat when actions are completed with this tool.", Command = "daktanklinker_DakChatFeedback"})

	panel:AddControl("CheckBox", {Label = "Composite Override", Description ="When checked this will cause any composite changes to override the current composite table of the tankcore, when unchecked it will add.", Command = "daktanklinker_DakCompOverride"})

	local ArmorTypeSelect = vgui.Create( "DComboBox", panel )
	ArmorTypeSelect:SetPos( 10, 150 )
	ArmorTypeSelect:SetSize( 275, 20 )
	ArmorTypeSelect:SetValue( "--Select Composite Type--" )
	ArmorTypeSelect:SetVisible( true )
	ArmorTypeSelect:AddChoice( "NERA" )
	ArmorTypeSelect:AddChoice( "Textolite" )
	ArmorTypeSelect:AddChoice( "ERA" )
	ArmorTypeSelect.OnSelect = function( self, index, value )
		local ArmorDesc = self:GetParent():Find( "ArmorDesc" )
		if value == "NERA" then
			ArmorDesc:SetText( "Non-Explosive Reactive Armor\n\nComposite of ceramic plates in a steel and rubber lattice designed to shatter incoming projectiles, it is especially effective at breaking up HEAT jets.\n\nDensity: 2.0g/cm3\nKE Protection: 9.2mm/in\nCE Protection: 18.4mm/in\nCost: 1.75xKG" )
			RunConsoleCommand( "daktanklinker_ArmorType", "NERA" )
		end
		if value == "Textolite" then
			ArmorDesc:SetText( "Glass-Textolite\n\nFiber glass and resin mix, it is lighter than RHA for a given protection value but takes up more space.\n\nDensity: 1.85kg/m3\nKE Protection: 10.4mm/in\nCE Protection: 14mm/in\nCost: 1.5xKG" )
			RunConsoleCommand( "daktanklinker_ArmorType", "Textolite" )
		end
		if value == "ERA" then
			ArmorDesc:SetText( "Explosive Reactive Armor\n\nExplosives sandwiched between two steel plates, detonates on impact, disrupting and shattering incoming HEAT jets.\n\nDensity: 1.732g/cm3\nKE Protection: 2.5mm/in\nCE Protection: 88.9mm/in\nCost: 1.25xKG" )
			RunConsoleCommand( "daktanklinker_ArmorType", "ERA" )
		end
	end

	local ArmorDesc = vgui.Create( "DLabel", panel, "ArmorDesc" )
	ArmorDesc:SetPos( 17, 175 )
	ArmorDesc:SetAutoStretchVertical( true )
	ArmorDesc:SetText( "Pick an armor type." )
	ArmorDesc:SetTextColor(Color(0,0,0,255))
	ArmorDesc:SetWide( 200 )
	ArmorDesc:SetWrap( true )
end
 
