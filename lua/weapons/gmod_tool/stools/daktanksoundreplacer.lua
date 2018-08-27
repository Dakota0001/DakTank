 
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
TOOL.ClientConVar[ "DakSound" ] = ""
--TOOL.ClientConVar[ "myparameter" ] = "fubar"
 
function TOOL:LeftClick( trace )
	if CurTime()>self.LastLeftClick then
		local Target = trace.Entity
		if Target:GetClass() == "dak_temotor" then
			Target.DakSound = self:GetClientInfo("DakSound")
			if (CLIENT) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Sound Replaced.")
			end
		elseif Target:GetClass() == "dak_tegun" or Target:GetClass() == "dak_teautogun" or Target:GetClass() == "dak_temachinegun" then
			Target.DakFireSound = self:GetClientInfo("DakSound")
			if (CLIENT) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Sound Replaced.")
			end
		else
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
			if not(Target.DakSound == nil) then
				if (CLIENT) or (game.SinglePlayer()) then
					self:GetOwner():ChatPrint(Target.DakSound)
				end
			end
		elseif Target:GetClass() == "dak_tegun" or Target:GetClass() == "dak_teautogun" or Target:GetClass() == "dak_temachinegun" then
			if not(Target.DakFireSound == nil) then
				if (CLIENT) or (game.SinglePlayer()) then
					self:GetOwner():ChatPrint(Target.DakFireSound)
				end
			end
		else
			if (CLIENT) or (game.SinglePlayer()) then
				self:GetOwner():ChatPrint("Select a motor or gun to read sound.")
			end
		end
	self.LastRightClick = CurTime()
	end
end
 
function TOOL.BuildCPanel(panel)
	local wide = panel:GetWide()

	local SoundNameText = vgui.Create("DTextEntry", ValuePanel)
	SoundNameText:SetText("")
	SoundNameText:SetWide(wide)
	SoundNameText:SetTall(20)
	SoundNameText:SetMultiline(false)
	SoundNameText:SetConVar("wire_soundemitter_sound")
	SoundNameText:SetVisible(true)
	panel:AddItem(SoundNameText)

	local SoundBrowserButton = vgui.Create("DButton")
	SoundBrowserButton:SetText("Open Sound Browser")
	SoundBrowserButton:SetWide(wide)
	SoundBrowserButton:SetTall(20)
	SoundBrowserButton:SetVisible(true)
	SoundBrowserButton.DoClick = function()
		RunConsoleCommand("wire_sound_browser_open",SoundNameText:GetValue())
	end
	panel:AddItem(SoundBrowserButton)

	local SoundPre = vgui.Create("DPanel")
	SoundPre:SetWide(wide)
	SoundPre:SetTall(40)
	SoundPre:SetVisible(true)

	local SoundPreWide = SoundPre:GetWide()

	local SoundPrePlay = vgui.Create("DButton", SoundPre)
	SoundPrePlay:SetText("Play")
	SoundPrePlay:SetWide(SoundPreWide / 2)
	SoundPrePlay:SetPos(0, 0)
	SoundPrePlay:SetTall(20)
	SoundPrePlay:SetVisible(true)
	SoundPrePlay.DoClick = function()
		RunConsoleCommand("play",SoundNameText:GetValue())
	end

	local SoundPreStop = vgui.Create("DButton", SoundPre)
	SoundPreStop:SetText("Stop")
	SoundPreStop:SetWide(SoundPreWide / 2)
	SoundPreStop:SetPos(SoundPreWide / 2, 0)
	SoundPreStop:SetTall(20)
	SoundPreStop:SetVisible(true)
	SoundPreStop.DoClick = function()
		RunConsoleCommand("play", "common/NULL.WAV") //Playing a silent sound will mute the preview but not the sound emitters.
	end

	local SoundSet = vgui.Create("DButton", SoundPre)
	SoundSet:SetText("Set Sound")
	SoundSet:SetWide(SoundPreWide / 2)
	SoundSet:SetPos(0, 20)
	SoundSet:SetTall(20)
	SoundSet:SetVisible(true)
	SoundSet.DoClick = function()
		RunConsoleCommand("daksoundreplacer_DakSound", GetConVar("wire_soundemitter_sound"):GetString())
	end

	panel:AddItem(SoundPre)
	SoundPre:InvalidateLayout(true)
	SoundPre.PerformLayout = function()
		local SoundPreWide = SoundPre:GetWide()
		SoundPrePlay:SetWide(SoundPreWide / 2)
		SoundPreStop:SetWide(SoundPreWide / 2)
		SoundSet:SetWide(SoundPreWide)
		SoundPreStop:SetPos(SoundPreWide / 2, 0)
		SoundSet:SetPos(0, 20)
	end

	

end