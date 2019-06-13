 
TOOL.Category = "DakTank"
TOOL.Name = "#Tool.daktanksoundreplacer.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
TOOL.LastLeftClick = CurTime()
TOOL.LastRightClick = CurTime()
TOOL.LastReload = CurTime()

if (CLIENT) then
language.Add( "Tool.daktanksoundreplacer.listname", "DakTank Sound Replacer" )
language.Add( "Tool.daktanksoundreplacer.name", "DakTank Sound Replacer" )
language.Add( "Tool.daktanksoundreplacer.desc", "Changes the sounds for DakTank guns and engines." )
language.Add( "Tool.daktanksoundreplacer.0", "Left click to apply sound. Right click to get target's current sound." )
end
TOOL.ClientConVar[ "DakTankSound1" ] = ""
TOOL.ClientConVar[ "DakTankSound2" ] = ""
TOOL.ClientConVar[ "DakTankSound3" ] = ""
--TOOL.ClientConVar[ "myparameter" ] = "fubar"
 
function TOOL:LeftClick( trace )
	if CurTime()>self.LastLeftClick then
		local Target = trace.Entity
		if Target:GetClass() == "dak_temotor" then
			Target.DakSound = self:GetClientInfo("DakTankSound1")
			if (CLIENT) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Sound Replaced.")
			end
		end
		if Target:GetClass() == "dak_tegun" or Target:GetClass() == "dak_teautogun" or Target:GetClass() == "dak_temachinegun" then
			Target.DakFireSound1 = self:GetClientInfo("DakTankSound1")
			Target.DakFireSound2 = self:GetClientInfo("DakTankSound2")
			Target.DakFireSound3 = self:GetClientInfo("DakTankSound3")
			if (CLIENT) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Sound Replaced.")
			end
		end
		if not(Target:GetClass() == "dak_temotor") and not(Target:GetClass() == "dak_tegun") and not(Target:GetClass() == "dak_teautogun") and not(Target:GetClass() == "dak_temachinegun") then
			if (CLIENT) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Entity not valid for sound replacement.")
			end
		end
	self.LastLeftClick = CurTime()
	end
end

function TOOL:RightClick( trace )
	if CurTime()>self.LastRightClick then
		local Target = trace.Entity
		if Target:GetClass() == "dak_temotor" then
			if not(Target.DakSound == nil) or not(Target.DakSound == "") then
				if (SERVER) or (game.SinglePlayer()) then
					self:GetOwner():ChatPrint(Target.DakSound)
				end
			end
		end
		if Target:GetClass() == "dak_tegun" or Target:GetClass() == "dak_teautogun" or Target:GetClass() == "dak_temachinegun" then
			if not(Target.DakFireSound == nil) or not(Target.DakFireSound == "") then
				if (SERVER) or (game.SinglePlayer()) then
					self:GetOwner():ChatPrint(Target.DakFireSound1..", "..Target.DakFireSound2..", "..Target.DakFireSound3)
				end
			end
		end
		if not(Target:GetClass() == "dak_temotor") and not(Target:GetClass() == "dak_tegun") and not(Target:GetClass() == "dak_teautogun") and not(Target:GetClass() == "dak_temachinegun") then
			if (SERVER) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Select a motor or gun to read sound.")
			end
		end
	self.LastRightClick = CurTime()
	end
end
 
function TOOL.BuildCPanel(panel)
	local wide = panel:GetWide()
	local SoundPre = vgui.Create("DPanel")
	SoundPre:SetWide(wide)
	SoundPre:SetTall(40)
	SoundPre:SetVisible(true)
	local SoundPreWide = SoundPre:GetWide()

	--1
	local Sound1NameText = vgui.Create("DLabel", ValuePanel)
	Sound1NameText:SetText("Sound 1")
	Sound1NameText:SetWide(wide)
	Sound1NameText:SetTall(20)
	Sound1NameText:SetMultiline(false)
	Sound1NameText:SetVisible(true)
	panel:AddItem(Sound1NameText)

	local Sound1NameTextEntry = vgui.Create("DTextEntry", ValuePanel)
	Sound1NameTextEntry:SetText("")
	Sound1NameTextEntry:SetWide(wide)
	Sound1NameTextEntry:SetTall(20)
	Sound1NameTextEntry:SetMultiline(false)
	--Sound1NameTextEntry:SetConVar("wire_soundemitter_sound")
	Sound1NameTextEntry:SetVisible(true)
	panel:AddItem(Sound1NameTextEntry)

	--2
	local Sound2NameText = vgui.Create("DLabel", ValuePanel)
	Sound2NameText:SetText("Sound 2")
	Sound2NameText:SetWide(wide)
	Sound2NameText:SetTall(20)
	Sound2NameText:SetMultiline(false)
	Sound2NameText:SetVisible(true)
	panel:AddItem(Sound2NameText)

	local Sound2NameTextEntry = vgui.Create("DTextEntry", ValuePanel)
	Sound2NameTextEntry:SetText("")
	Sound2NameTextEntry:SetWide(wide)
	Sound2NameTextEntry:SetTall(20)
	Sound2NameTextEntry:SetMultiline(false)
	--Sound2NameTextEntry:SetConVar("wire_soundemitter_sound")
	Sound2NameTextEntry:SetVisible(true)
	panel:AddItem(Sound2NameTextEntry)

	--3
	local Sound3NameText = vgui.Create("DLabel", ValuePanel)
	Sound3NameText:SetText("Sound 3")
	Sound3NameText:SetWide(wide)
	Sound3NameText:SetTall(20)
	Sound3NameText:SetMultiline(false)
	Sound3NameText:SetVisible(true)
	panel:AddItem(Sound3NameText)

	local Sound3NameTextEntry = vgui.Create("DTextEntry", ValuePanel)
	Sound3NameTextEntry:SetText("")
	Sound3NameTextEntry:SetWide(wide)
	Sound3NameTextEntry:SetTall(20)
	Sound3NameTextEntry:SetMultiline(false)
	--Sound3NameTextEntry:SetConVar("wire_soundemitter_sound")
	Sound3NameTextEntry:SetVisible(true)
	panel:AddItem(Sound3NameTextEntry)

	--universal
	local SoundBrowserButton = vgui.Create("DButton")
	SoundBrowserButton:SetText("Open Sound Browser")
	SoundBrowserButton:SetWide(wide)
	SoundBrowserButton:SetTall(20)
	SoundBrowserButton:SetVisible(true)
	SoundBrowserButton.DoClick = function()
		RunConsoleCommand("wire_sound_browser_open",Sound1NameTextEntry:GetValue())
	end
	panel:AddItem(SoundBrowserButton)

	local SoundSet = vgui.Create("DButton", SoundPre)
	SoundSet:SetText("Set Sound")
	SoundSet:SetWide(SoundPreWide / 2)
	SoundSet:SetPos(0, 20)
	SoundSet:SetTall(20)
	SoundSet:SetVisible(true)
	SoundSet.DoClick = function()
		RunConsoleCommand("daktanksoundreplacer_DakTankSound1", Sound1NameTextEntry:GetText())
		RunConsoleCommand("daktanksoundreplacer_DakTankSound2", Sound2NameTextEntry:GetText())
		RunConsoleCommand("daktanksoundreplacer_DakTankSound3", Sound3NameTextEntry:GetText())
	end

	panel:AddItem(SoundPre)
	SoundPre:InvalidateLayout(true)
	SoundPre.PerformLayout = function()
		local SoundPreWide = SoundPre:GetWide()
		SoundSet:SetWide(SoundPreWide)
		SoundSet:SetPos(0, 20)
	end

end