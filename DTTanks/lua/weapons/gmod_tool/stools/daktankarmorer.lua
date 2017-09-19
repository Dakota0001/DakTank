 
TOOL.Category = "DakTek Tank Edition"
TOOL.Name = "#Tool.daktankarmorer.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
TOOL.LastLeftClick = CurTime()
TOOL.LastRightClick = CurTime()

if (CLIENT) then
language.Add( "Tool.daktankarmorer.listname", "DakTek Tank Edition Armorer" )
language.Add( "Tool.daktankarmorer.name", "DakTek Tank Edition Armorer" )
language.Add( "Tool.daktankarmorer.desc", "Armors stuff and gives info." )
language.Add( "Tool.daktankarmorer.0", "Left click to set armor. Right click to get info." )
end
TOOL.ClientConVar[ "DakArmor" ] = "1"
--TOOL.ClientConVar[ "myparameter" ] = "fubar"
--if SERVER then
	local function SetMass( Player, Entity, Data )
		if not SERVER then return end

		if Data.Mass then
			local physobj = Entity:GetPhysicsObject()
			if physobj:IsValid() then physobj:SetMass(Data.Mass) end
		end

		duplicator.StoreEntityModifier( Entity, "mass", Data )
	end
	duplicator.RegisterEntityModifier( "mass", SetMass )
--end

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
						if trace.Entity:GetClass()=="prop_physics" then 
							if not(trace.Entity.DakArmor == 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
								trace.Entity.DakArmor = 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
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
						if trace.Entity:GetClass()=="prop_physics" then 
							if not(trace.Entity.DakArmor == 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
								trace.Entity.DakArmor = 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
							end
						end
					end
				end
			

				local Target = trace.Entity
				local ply = self:GetOwner()
				local TarName = Target.DakName
				local HP = math.Round(Target.DakHealth, 1 )
				local MHP = math.Round(Target.DakMaxHealth, 1 )
				local PHP = math.Round((HP/MHP)*100, 1 )
				local Weight = math.Round(Target:GetPhysicsObject():GetMass(),1)
				local HitAng = math.deg(math.acos(trace.HitNormal:Dot( -trace.Normal )))
				local EffArmor = (Target.DakArmor/math.abs(trace.HitNormal:Dot(trace.Normal)))
				local Multiplier = (EffArmor/Target.DakArmor)
			

				ply:ChatPrint("Raw Armor: "..math.Round(Target.DakArmor,2).."(mm)")
				ply:ChatPrint("Effective Armor: "..math.Round(EffArmor,2).."(mm)")
				ply:ChatPrint("Angle: "..math.Round(90-HitAng,2).."(degrees)")
				ply:ChatPrint("Multiplier: "..math.Round(Multiplier,2))
				ply:ChatPrint("Weight: "..math.Round(Weight,2).."(kg)")
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
