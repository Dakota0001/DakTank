 
TOOL.Category = "DakTank"
TOOL.Name = "#Tool.daktankarmorer.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
TOOL.LastLeftClick = CurTime()
TOOL.LastRightClick = CurTime()
TOOL.LastThink = 0

if (CLIENT) then
	language.Add( "Tool.daktankarmorer.listname", "DakTank Armorer" )
	language.Add( "Tool.daktankarmorer.name", "DakTank Armorer" )
	language.Add( "Tool.daktankarmorer.desc", "Armors stuff and gives info." )
	language.Add( "Tool.daktankarmorer.0", "Left click to set armor. Right click to get info." )

	surface.CreateFont( "DakTankArmorFont", {
		font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 25,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )
end
TOOL.ClientConVar[ "DakArmor" ] = "1"

local function SetMass( Player, Entity, Data )
	if not SERVER then return end

	if Data.Mass then
		local physobj = Entity:GetPhysicsObject()
		if physobj:IsValid() then physobj:SetMass(Data.Mass) end
	end

	duplicator.StoreEntityModifier( Entity, "mass", Data )
end
duplicator.RegisterEntityModifier( "mass", SetMass )

function TOOL:LeftClick( trace )
	if CurTime()>self.LastLeftClick then

		if trace.Entity:IsSolid() and IsValid(trace.Entity) then 
			if SERVER then
				if trace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(trace.Entity)
				end
				local SA = trace.Entity:GetPhysicsObject():GetSurfaceArea()
				if trace.Entity.IsDakTekFutureTech == 1 then
					trace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
						trace.Entity.DakArmor = trace.Entity:OBBMaxs().x/2
						trace.Entity.DakIsTread = 1
					else
						if trace.Entity:GetClass()=="prop_physics" and not(trace.Entity.IsComposite == 1) then 
							if not(trace.Entity.DakArmor == 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - trace.Entity.DakBurnStacks*0.25) then
								trace.Entity.DakArmor = 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - trace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
			end

			local Target = trace.Entity
			if not(string.Explode("_",Target:GetClass(),false)[1] == "dak") then
				--local Volume = trace.Entity:GetPhysicsObject():GetVolume()
				if trace.Entity.DakIsTread == 1 then
					if (CLIENT) or (game.SinglePlayer()) then
						self:GetOwner():EmitSound("npc/manhack/bat_away.wav")
						self:GetOwner():ChatPrint("Tread armor cannot be changed, it is based on size of wheel.")
					end
				else
					if SERVER then
						local SA = trace.Entity:GetPhysicsObject():GetSurfaceArea()
						local mass = math.Round(((self:GetClientInfo("DakArmor")/(288/SA))/7.8125)*4.6311781,0)
						if mass > 0 then
							SetMass( self:GetOwner(), trace.Entity, { Mass = mass } )
						end
					end
				end
				if (CLIENT) or (game.SinglePlayer()) then
					self:GetOwner():EmitSound("npc/manhack/grind1.wav")
					self:GetOwner():ChatPrint("Armor Set.")
				end
			end
		end
	self.LastLeftClick = CurTime()
	end
end
 
function TOOL:RightClick( trace )
	if CurTime()>self.LastRightClick then
		if (SERVER) then
			if trace.Entity:IsSolid() and IsValid(trace.Entity) then 
				local ply = self:GetOwner()
				local APArmor, APEnt, APShatters = DTGetArmorRecurse(trace.StartPos, trace.HitPos+trace.Normal*5000, "AP", self:GetClientInfo("DakArmor"), {self:GetOwner()})
				local HEATArmor, HEATEnt, HEATShatters = DTGetArmorRecurse(trace.StartPos, trace.HitPos+trace.Normal*5000, "HEAT", self:GetClientInfo("DakArmor"), {self:GetOwner()})
				local HVAPArmor, HVAPEnt, HVAPShatters = DTGetArmorRecurse(trace.StartPos, trace.HitPos+trace.Normal*5000, "HVAP", self:GetClientInfo("DakArmor")*0.5, {self:GetOwner()})
				local APFSDSArmor, APFSDSEnt, APFSDSShatters = DTGetArmorRecurse(trace.StartPos, trace.HitPos+trace.Normal*5000, "APFSDS", self:GetClientInfo("DakArmor")*0.25, {self:GetOwner()})
				if (APEnt:IsWorld() or APEnt==NULL) and APArmor > 0 then
					ply:ChatPrint("No critical entities hit.")
				else
					ply:ChatPrint("Effective Armor vs AP: "..math.Round(APArmor,2).."(mm), "..APShatters.." Shatters.")
					ply:ChatPrint("Effective Armor vs HEAT: "..math.Round(HEATArmor,2).."(mm), 0 Shatters.")
					ply:ChatPrint("Effective Armor vs HVAP: "..math.Round(HVAPArmor,2).."(mm), "..HVAPShatters.." Shatters.")
					ply:ChatPrint("Effective Armor vs APFSDS: "..math.Round(APFSDSArmor,2).."(mm), "..APFSDSShatters.." Shatters.")
				end
				ply:ChatPrint("Use armor input value in Q menu as shell diameter")
			end
		end
	self.LastRightClick = CurTime()
	end
end
 
local function GetPhysCons( ent, Results )
	local Results = Results or {}
	if not IsValid( ent ) then return end
		if Results[ ent ] then return end
		Results[ ent ] = ent
		local Constraints = constraint.GetTable( ent )
		for k, v in ipairs( Constraints ) do
			if not (v.Type == "NoCollide") then
				for i, Ent in pairs( v.Entity ) do
					GetPhysCons( Ent.Entity, Results )
				end
			end
		end
	return Results
end

local function GetParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetParents(Parent, Results)
	end
	return Results
end

function TOOL:Reload( trace )
	if SERVER then
		if IsValid(trace.Entity) then
		local Contraption = {}
		table.Add(Contraption,GetParents(trace.Entity))
		for k, v in pairs(GetParents(trace.Entity)) do
			table.Add(Contraption,GetPhysCons(v))
		end
		local Mass = 0
		for i=1, #Contraption do
			table.Add( Contraption, Contraption[i]:GetChildren() )
			table.Add( Contraption, Contraption[i]:GetParent() )
		end
		local Children = {}
		for i2=1, #Contraption do
			if table.Count(Contraption[i2]:GetChildren()) > 0 then
				table.Add( Children, Contraption[i2]:GetChildren() )
			end
		end
		table.Add( Contraption, Children )
		local hash = {}
		local res = {}
		for _,v in ipairs(Contraption) do
   			if (not hash[v]) then
    			res[#res+1] = v
    	   		hash[v] = true
   			end
		end
		for i=1, #res do
			if res[i]:IsSolid() then
				Mass = Mass + res[i]:GetPhysicsObject():GetMass()
			end
		end
		local ply = self:GetOwner()
		ply:ChatPrint("This Contraption weighs "..Mass.." kg")
		end
	end
end

function TOOL:Think()
	if SERVER then
		if self.LastThink+0.1 < CurTime() then
			local newtrace = {}
				newtrace.start = self:GetOwner():GetShootPos()
				newtrace.endpos = self:GetOwner():GetShootPos() + self:GetOwner():EyeAngles():Forward()*1000000
				newtrace.filter = self:GetOwner()
			local trace = util.TraceLine(newtrace)

			if trace.Entity:IsSolid() and IsValid(trace.Entity) then 
				if trace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(trace.Entity)
				end
				local SA = trace.Entity:GetPhysicsObject():GetSurfaceArea()
				if trace.Entity.IsDakTekFutureTech == 1 then
					trace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
						trace.Entity.DakArmor = trace.Entity:OBBMaxs().x/2
						trace.Entity.DakIsTread = 1
					else
						if trace.Entity:GetClass()=="prop_physics" and not(trace.Entity.IsComposite == 1) then 
							if not(trace.Entity.DakArmor == 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - trace.Entity.DakBurnStacks*0.25) then
								trace.Entity.DakArmor = 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - trace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end

				self.Weapon:SetNWFloat("Angle",math.Round(math.deg(math.acos(trace.HitNormal:Dot( -trace.Normal ))),2))
				self.Weapon:SetNWFloat("Mass",math.Round(trace.Entity:GetPhysicsObject():GetMass(),2))
				self.Weapon:SetNWFloat("Shell",math.Round(self:GetClientInfo("DakArmor"),2))
				if trace.Entity.IsComposite == 1 then
					local CompArmor = math.Round((DTCompositesTrace( trace.Entity, trace.HitPos, trace.Normal )*9.2),2)
					self.Weapon:SetNWFloat("Armor",CompArmor)
					self.Weapon:SetNWFloat("AP",CompArmor)
					self.Weapon:SetNWFloat("HEAT",math.Round(CompArmor*2,2))
					self.Weapon:SetNWFloat("HVAP",CompArmor)
					self.Weapon:SetNWFloat("APFSDS",CompArmor)
				else
					local APArmor, _, _, _ = DTGetArmor(trace.StartPos, trace.HitPos+trace.Normal*5, "AP", self:GetClientInfo("DakArmor"), self:GetOwner())
					local HEATArmor, _, _, _ = DTGetArmor(trace.StartPos, trace.HitPos+trace.Normal*5, "HEAT", self:GetClientInfo("DakArmor"), self:GetOwner())
					local HVAPArmor, _, _, _ = DTGetArmor(trace.StartPos, trace.HitPos+trace.Normal*5, "HVAP", self:GetClientInfo("DakArmor"), self:GetOwner())
					local APFSDSArmor, _, _, _ = DTGetArmor(trace.StartPos, trace.HitPos+trace.Normal*5, "APFSDS", self:GetClientInfo("DakArmor"), self:GetOwner())
					self.Weapon:SetNWFloat("Armor",math.Round(trace.Entity.DakArmor,2))
					self.Weapon:SetNWFloat("AP",math.Round(APArmor,2))
					self.Weapon:SetNWFloat("HEAT",math.Round(HEATArmor,2))
					self.Weapon:SetNWFloat("HVAP",math.Round(HVAPArmor,2))
					self.Weapon:SetNWFloat("APFSDS",math.Round(APFSDSArmor,2))
				end
			else
				self.Weapon:SetNWFloat("Angle",0)
				self.Weapon:SetNWFloat("Armor",0)
				self.Weapon:SetNWFloat("Mass",0)
				self.Weapon:SetNWFloat("Shell",math.Round(self:GetClientInfo("DakArmor"),2))
				self.Weapon:SetNWFloat("AP",0)
				self.Weapon:SetNWFloat("HEAT",0)
				self.Weapon:SetNWFloat("HVAP",0)
				self.Weapon:SetNWFloat("APFSDS",0)
			end
			self.LastThink = CurTime()
		end
	end
end

function TOOL.BuildCPanel(panel)
	local wide = panel:GetWide()


	local DLabel = vgui.Create( "DLabel", panel )
	DLabel:SetPos( 17, 50 )
	DLabel:SetAutoStretchVertical( true )
	DLabel:SetText( "Put an armor value in the box in mm then left click stuff to set mass for that value." )
	DLabel:SetTextColor(Color(0,0,0,255))
	DLabel:SetWide( 200 )
	DLabel:SetWrap( true )

	local SoundNameText = vgui.Create("DTextEntry", ValuePanel)
	DLabel:SetPos( 17, 65 )
	SoundNameText:SetText("")
	SoundNameText:SetWide(wide/2)
	SoundNameText:SetTall(20)
	SoundNameText:SetMultiline(false)
	SoundNameText:SetConVar("daktankarmorer_DakArmor")
	SoundNameText:SetVisible(true)
	panel:AddItem(SoundNameText)

	--local SoundSet = vgui.Create("DButton", SoundPre)
	--SoundSet:SetText("Set Armor")
	--SoundSet:SetWide(SoundPreWide / 2)
	--SoundSet:SetPos(0, 20)
	--SoundSet:SetTall(20)
	--SoundSet:SetVisible(true)
	--SoundSet.DoClick = function()
	--	RunConsoleCommand("daktankarmorer_DakArmor", GetConVar("daktankarmorer_DakArmor"):GetString())
	--end
end

function TOOL:DrawToolScreen( w, h )
	if not CLIENT then return end

	cam.Start2D()
		render.Clear( 0, 0, 0, 0 )
		
		surface.SetMaterial( Material( "phoenix_storms/black_chrome" ) )
		surface.SetDrawColor( color_white )
		surface.DrawTexturedRect( 0, 0, 256, 256 )
		surface.SetFont( "DakTankArmorFont" )

		draw.SimpleTextOutlined( "Angle", "DakTankArmorFont", 64, 20, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("Angle"),2), "DakTankArmorFont", 64, 50, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )

		draw.SimpleTextOutlined( "Armor", "DakTankArmorFont", 64, 79, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("Armor"),2), "DakTankArmorFont", 64, 109, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		
		draw.SimpleTextOutlined( "Mass", "DakTankArmorFont", 64, 143, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("Mass"),2), "DakTankArmorFont", 64, 173, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )

		draw.SimpleTextOutlined( "Shell", "DakTankArmorFont", 64, 207, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("Shell"),2), "DakTankArmorFont", 64, 237, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )

		draw.SimpleTextOutlined( "vs AP", "DakTankArmorFont", 192, 20, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("AP"),2), "DakTankArmorFont", 192, 50, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )

		draw.SimpleTextOutlined( "vs HEAT", "DakTankArmorFont", 192, 79, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("HEAT"),2), "DakTankArmorFont", 192, 109, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		
		draw.SimpleTextOutlined( "vs HVAP", "DakTankArmorFont", 192, 143, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("HVAP"),2), "DakTankArmorFont", 192, 173, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )

		draw.SimpleTextOutlined( "vs APFSDS", "DakTankArmorFont", 192, 207, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )
		draw.SimpleTextOutlined( math.Round(self.Weapon:GetNWFloat("APFSDS"),2), "DakTankArmorFont", 192, 237, Color( 224, 224, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, color_black )

	cam.End2D()
	
end