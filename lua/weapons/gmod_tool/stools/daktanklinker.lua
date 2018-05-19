 
TOOL.Category = "DakTek Tank Edition"
TOOL.Name = "#Tool.daktanklinker.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 

TOOL.EntList = {}
TOOL.ColorList = {}
TOOL.LastLeftClick = CurTime()
TOOL.LastRightClick = CurTime()
TOOL.LastReload = CurTime()

TOOL.ClientConVar[ "DakChatFeedback" ] = 1

if (CLIENT) then
language.Add( "Tool.daktanklinker.listname", "DakTek Tank Edition Linker" )
language.Add( "Tool.daktanklinker.name", "DakTek Tank Edition Linker" )
language.Add( "Tool.daktanklinker.desc", "Links stuff to things." )
language.Add( "Tool.daktanklinker.0", "Left click to select the gearbox, AL clip, or turret motor. Right click on the fuel, gun, or turret control. Also links crew members to things." )
end
--TOOL.ClientConVar[ "myparameter" ] = "fubar"
 
function TOOL:LeftClick( trace )
	if CurTime()>self.LastLeftClick then
		local Target = trace.Entity
		if(string.Explode("_",Target:GetClass(),false)[1] == "dak") then
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
	self.LastLeftClick = CurTime()
	end
end
 
function TOOL:RightClick( trace )
	if CurTime()>self.LastRightClick then
		local Target = trace.Entity
		if IsValid(self.EntList[1]) then
			if self.EntList[1]:GetClass() == "dak_crew" then
				if(Target:GetClass() == "dak_tegearbox" or Target:GetClass() == "dak_tegun" or Target:GetClass() == "dak_teautogun") then
					if Target:GetClass() == "dak_tegearbox" then
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
				if(Target:GetClass() == "dak_teautogun") then
					if self.EntList[1]:GetClass() == "dak_teautoloadingmodule" then
						self.Ent2 = Target
						self.EntList[1].DakGun = self.Ent2
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_close.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								if #self.EntList > 1 then
									self:GetOwner():ChatPrint("Only allows one clip, first selected linked.")
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
						self.Ent2 = Target
						self.Ent2.DakTurretMotor = self.EntList[1]
						if (CLIENT) or (game.SinglePlayer()) then
							self:GetOwner():EmitSound("/items/ammocrate_close.wav")
							if self:GetClientNumber( "DakChatFeedback" ) == 1 then
								if #self.EntList > 1 then
									self:GetOwner():ChatPrint("Only allows one motor, first selected linked.")
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
	panel:AddControl("Header",{Text = "DakTek Tank Edition Linker", Description	= "This tool just links clips to autoloaders, and turret motors to turret controls, also links crew to things. Ammo is automatically found on the contraption by the gun."})	
	panel:AddControl("CheckBox", {Label = "Chat Feedback", Description ="Check for feedback in chat when actions are completed with this tool.", Command = "daktanklinker_DakChatFeedback"})
end
 
