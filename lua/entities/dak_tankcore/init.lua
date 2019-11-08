AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakName = "Tank Core"
ENT.HitBox = {}
ENT.DakActive = 0
ENT.DakFuel = nil

function ENT:Initialize()
	self:SetModel( "models/bull/gates/logic.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakArmor = 10
	--local phys = self:GetPhysicsObject()
	self.timer = CurTime()

	

	self.Outputs = WireLib.CreateOutputs( self, { "Health","HealthPercent","Crew" } )
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.DakActive = 0
	self.CurMass = 0
	self.LastCurMass = 0
	self.HitBox = {}
	self.ERA = {}
	self.HitBoxMass = 0
	self.Hitboxthinktime = CurTime()
	self.LastRemake = CurTime()
	self.DakBurnStacks = 0
	self.SpawnTime = CurTime()
	self.FrontalArmor = 0
	self.SideArmor = 0
	self.RearArmor = 0
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
--[[
local function GetPhysCons( Ent, Table )
    if not IsValid( Ent ) then return end

    local Table = Table or {[Ent] = true}
            if Table[Ent] then return end

    for _, V in ipairs( constraint.GetTable(Ent) ) do
        if V.Type ~= "NoCollide" then
            for _, Ent in pairs(V.Entity) do
                GetPhysCons(Ent.Entity, Table)
            end
        end
    end

    return Table
end
]]--

local function GetParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetParents(Parent, Results)
	end
	return Results
end
--[[
local function GetParents(Ent)
    if not IsValid(Ent) then return end
    
    local Table  = {[Ent] = true}
    local Parent = Ent:GetParent()

    while IsValid(Parent:GetParent()) do
        Table[Parent] = true
        Parent = Parent:GetParent()
    end

    return Table
end
]]--

local function GetPhysicalConstraints( Ent, Table )
    if not IsValid( Ent ) then return end

    local Table = Table or {}
            if Table[Ent] then return end
            Table[Ent] = true
    for _, V in ipairs( constraint.GetTable(Ent) ) do
        if V.Type ~= "NoCollide" then
            for _, Ent in pairs(V.Entity) do
                GetPhysicalConstraints(Ent.Entity, Table)
            end
        end
    end

    return Table
end

--[[
local function GetContraption(Ent)
    if not IsValid(Ent) then return {} end

    -- Get our ancestor (Move to top of tree)
    local Root = Ent
    while IsValid(Root:GetParent()) do Root = Root:GetParent() end

    -- Get everything constrained to it (Spread horizontally on tree)
    local Entities = GetPhysicalConstraints(Root)
    PrintTable(Entities)

    -- Get all children (Move down all branches of tree)
    local Children = {}

    for Entity in pairs(Entities) do
        for Child in pairs(Entity:GetChildren()) do
            Children[Child] = true
        end
    end

    table.Add(Entities, Children)
    PrintTable(Children)
    PrintTable(Entities)
    return Entities --Mass
end
]]--
function ENT:Think()
	if IsValid(self) then
		if IsValid(self:GetParent()) then
			if IsValid(self:GetParent():GetParent()) then
				self.Base = self:GetParent():GetParent()
				if self.PreCost and self.PreCost>0 then
					if not(self.PreCostTimerFirst) then
						self.PreCostTimerFirst = CurTime()
						self.PreCostTimer = 0	
					end
					self.PreCostTimer = CurTime() - self.PreCostTimerFirst
					if self.PreCostTimer > 5 and self.CanSpawn ~= true and IsValid(self.Gearbox) then
						self.CanSpawn = true

						local ArmorVal1 = 0
						local addpos
						local count = 0
						local blocks50 = 0
						local blocks100 = 0
						local blocks150 = 0
						local blocks200 = 0
						local blocks300 = 0
						local blocks400 = 0
						local blocks500 = 0
						local blocks650 = 0
						local blocks850 = 0
						local blocks1000 = 0
						local gunhit = 0
						local gearhit = 0
						local forward = Angle(0,self.Gearbox:GetAngles().yaw,0):Forward()
						local right = Angle(0,self.Gearbox:GetAngles().yaw,0):Right()
						local up = Angle(0,self.Gearbox:GetAngles().yaw,0):Up()
						--FRONT
						local startpos = self:GetParent():GetParent():GetPos()+(up*125)+(right*-125)
						for i=1, 25 do
							for j=1, 25 do
								addpos = (right*10*j)+(up*-10*i)+(up*0.4*j)
								ArmorVal1, ent, _, _, gunhit, gearhit = DTGetArmorRecurse(startpos+addpos+forward*500, startpos+addpos-forward*500, "AP", 75, player.GetAll())
								if IsValid(ent) then
									if gunhit==0 and ent.Controller == self then
										count = count+1
										if ArmorVal1>50 then
											blocks50 = blocks50 + 1
										end
										if ArmorVal1>100 then
											blocks100 = blocks100 + 1
										end
										if ArmorVal1>150 then
											blocks150 = blocks150 + 1
										end
										if ArmorVal1>200 then
											blocks200 = blocks200 + 1
										end
										if ArmorVal1>300 then
											blocks300 = blocks300 + 1
										end
										if ArmorVal1>400 then
											blocks400 = blocks400 + 1
										end
										if ArmorVal1>500 then
											blocks500 = blocks500 + 1
										end
										if ArmorVal1>650 then
											blocks650 = blocks650 + 1
										end
										if ArmorVal1>850 then
											blocks850 = blocks850 + 1
										end
										if ArmorVal1>1000 then
											blocks1000 = blocks1000 + 1
										end
									end
								end
							end
						end
						self.FrontalArmor = (((blocks50/count)+(blocks100/count)+(blocks150/count)+(blocks200/count)+(blocks300/count)+(blocks400/count)+(blocks500/count)+(blocks650/count)+(blocks850/count)+(blocks1000/count))/10)
						--REAR
						count = 0
						blocks50 = 0
						blocks100 = 0
						blocks150 = 0
						blocks200 = 0
						blocks300 = 0
						blocks400 = 0
						blocks500 = 0
						blocks650 = 0
						blocks850 = 0
						blocks1000 = 0
						startpos = self:GetParent():GetParent():GetPos()+(up*125)+(right*-125)
						for i=1, 25 do
							for j=1, 25 do
								addpos = (right*10*j)+(up*-10*i)+(up*0.4*j)
								ArmorVal1, ent, _, _, gunhit, gearhit = DTGetArmorRecurse(startpos+addpos-forward*500, startpos+addpos+forward*500, "AP", 75, player.GetAll())
								if IsValid(ent) then
									if gunhit==0 and ent.Controller == self then
										count = count+1
										if ArmorVal1>50 then
											blocks50 = blocks50 + 1
										end
										if ArmorVal1>100 then
											blocks100 = blocks100 + 1
										end
										if ArmorVal1>150 then
											blocks150 = blocks150 + 1
										end
										if ArmorVal1>200 then
											blocks200 = blocks200 + 1
										end
										if ArmorVal1>300 then
											blocks300 = blocks300 + 1
										end
										if ArmorVal1>400 then
											blocks400 = blocks400 + 1
										end
										if ArmorVal1>500 then
											blocks500 = blocks500 + 1
										end
										if ArmorVal1>650 then
											blocks650 = blocks650 + 1
										end
										if ArmorVal1>850 then
											blocks850 = blocks850 + 1
										end
										if ArmorVal1>1000 then
											blocks1000 = blocks1000 + 1
										end
									end
								end
							end
						end
						self.RearArmor = (((blocks50/count)+(blocks100/count)+(blocks150/count)+(blocks200/count)+(blocks300/count)+(blocks400/count)+(blocks500/count)+(blocks650/count)+(blocks850/count)+(blocks1000/count))/10)
						--LEFT
						count = 0
						blocks50 = 0
						blocks100 = 0
						blocks150 = 0
						blocks200 = 0
						blocks300 = 0
						blocks400 = 0
						blocks500 = 0
						blocks650 = 0
						blocks850 = 0
						blocks1000 = 0
						startpos = self:GetParent():GetParent():GetPos()+(up*125)+(forward*-125)
						for i=1, 25 do
							for j=1, 25 do
								addpos = (forward*10*j)+(up*-10*i)+(up*0.4*j)
								ArmorVal1, ent, _, _, gunhit, gearhit = DTGetArmorRecurse(startpos+addpos+right*500, startpos+addpos-right*500, "AP", 75, player.GetAll())
								if IsValid(ent) then
									if gunhit==0 and ent.Controller == self then
										count = count+1
										if ArmorVal1>50 then
											blocks50 = blocks50 + 1
										end
										if ArmorVal1>100 then
											blocks100 = blocks100 + 1
										end
										if ArmorVal1>150 then
											blocks150 = blocks150 + 1
										end
										if ArmorVal1>200 then
											blocks200 = blocks200 + 1
										end
										if ArmorVal1>300 then
											blocks300 = blocks300 + 1
										end
										if ArmorVal1>400 then
											blocks400 = blocks400 + 1
										end
										if ArmorVal1>500 then
											blocks500 = blocks500 + 1
										end
										if ArmorVal1>650 then
											blocks650 = blocks650 + 1
										end
										if ArmorVal1>850 then
											blocks850 = blocks850 + 1
										end
										if ArmorVal1>1000 then
											blocks1000 = blocks1000 + 1
										end
									end
								end
							end
						end
						local LeftArmor = (((blocks50/count)+(blocks100/count)+(blocks150/count)+(blocks200/count)+(blocks300/count)+(blocks400/count)+(blocks500/count)+(blocks650/count)+(blocks850/count)+(blocks1000/count))/10)
						--RIGHT
						count = 0
						blocks50 = 0
						blocks100 = 0
						blocks150 = 0
						blocks200 = 0
						blocks300 = 0
						blocks400 = 0
						blocks500 = 0
						blocks650 = 0
						blocks850 = 0
						blocks1000 = 0
						startpos = self:GetParent():GetParent():GetPos()+(up*125)+(forward*-125)
						for i=1, 25 do
							for j=1, 25 do
								addpos = (forward*10*j)+(up*-10*i)+(up*0.4*j)
								ArmorVal1, ent, _, _, gunhit, gearhit = DTGetArmorRecurse(startpos+addpos-right*500, startpos+addpos+right*500, "AP", 75, player.GetAll())
								if IsValid(ent) then
									if gunhit==0 and ent.Controller == self then
										count = count+1
										if ArmorVal1>50 then
											blocks50 = blocks50 + 1
										end
										if ArmorVal1>100 then
											blocks100 = blocks100 + 1
										end
										if ArmorVal1>150 then
											blocks150 = blocks150 + 1
										end
										if ArmorVal1>200 then
											blocks200 = blocks200 + 1
										end
										if ArmorVal1>300 then
											blocks300 = blocks300 + 1
										end
										if ArmorVal1>400 then
											blocks400 = blocks400 + 1
										end
										if ArmorVal1>500 then
											blocks500 = blocks500 + 1
										end
										if ArmorVal1>650 then
											blocks650 = blocks650 + 1
										end
										if ArmorVal1>850 then
											blocks850 = blocks850 + 1
										end
										if ArmorVal1>1000 then
											blocks1000 = blocks1000 + 1
										end
									end
								end
							end
						end
						local RightArmor = (((blocks50/count)+(blocks100/count)+(blocks150/count)+(blocks200/count)+(blocks300/count)+(blocks400/count)+(blocks500/count)+(blocks650/count)+(blocks850/count)+(blocks1000/count))/10)
						self.SideArmor = (RightArmor+LeftArmor)/2

						local armormult = (self.FrontalArmor*0.7)+(self.SideArmor*0.2)+(self.RearArmor*0.1)

						local shellvol = ((100*0.0393701)^2)*(100*0.0393701*13)
						local shells = 0
						local ammocosts = 0
						local hasAPFSDS = 0
						local hasHEATFS = 0
						local hasAPDS = 0
						local hasHVAP = 0
						local hasATGM = 0
						for k=1, #self.Ammoboxes do 
							local boxname = (string.Split( self.Ammoboxes[k].DakAmmoType, "" ))
							local name6 = boxname[#boxname-9]..boxname[#boxname-8]..boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
							local name4 = boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
							local name2 = boxname[#boxname-5]..boxname[#boxname-4]
							--check longest to shortest names, with if then ifelse then else
							local name 
							if name6 == "APFSDS" or name6 == "HEATFS" then
								name = name6
							elseif name4 == "HVAP" or name4 == "APDS" or name4 == "HEAT" or name4 == "HESH" or name4 == "ATGM" or name4 == "APHE" then
								name = name4
							elseif name2 == "AP" or name2 == "HE" then
								name = name2
							end

							if name == "APFSDS" then
								hasAPFSDS = 1
							end
							if name == "HEATFS" then
								hasHEATFS = 1
							end
							if name == "APDS" then
								hasAPDS = 1
							end
							if name == "HVAP" then
								hasHVAP = 1
							end
							if name == "ATGM" then
								hasATGM = 1
							end

							shells = self.Ammoboxes[k]:GetPhysicsObject():GetVolume()/shellvol
							local cost = 0
							if name == "HE" then
								cost = shells * 0.1
							elseif name == "HESH" then
								cost = shells * 0.26
							elseif name == "AP" or name == "APHE" or name == "HEAT" then
								if name == "HEAT" and self.ColdWar == 1 then
									cost = shells * 0.41
								else
									cost = shells * 0.25
								end
							elseif name == "HVAP" then
								cost = shells * 0.38
							elseif name == "APDS" then
								cost = shells * 0.42
							elseif name == "HEATFS" or name == "APFSDS" then
								if name == "HEATFS" and self.ColdWar == 1 and self.Modern == 0 then
									cost = shells * 0.62
								else
									cost = shells * 1
								end
							elseif name == "ATGM" then
								if self.ColdWar == 1 and self.Modern == 0 then
									cost = shells * 1.0
								else
									cost = shells * 1.25
								end
							end
							ammocosts = ammocosts + cost
						end

						local speedmult = math.Clamp((1+((math.Clamp(self.Gearbox.DakHP,0,self.Gearbox.MaxHP)/(self.Gearbox.TotalMass/1000))*0.05))*0.5,0,1.5)
						armormult = armormult+0.5
						--armormult = 1.002663 - 1.056967*2.718^(-6.413596*armormult)

						local KEPen = {0}
						local CEPen = {0}
						local DPS = 0
						local TotalDPS = 0
						local ShotsPerSecond
						for g=1, #self.Guns do 
							if hasAPFSDS==1 then
								KEPen[#KEPen+1] = self.Guns[g].BaseDakShellPenetration*7.8*0.5
							elseif hasAPDS==1 then
								KEPen[#KEPen+1] = self.Guns[g].BaseDakShellPenetration*1.67
							elseif hasHVAP==1 then	
								KEPen[#KEPen+1] = self.Guns[g].BaseDakShellPenetration*1.5
							else
								KEPen[#KEPen+1] = self.Guns[g].BaseDakShellPenetration
							end
							if hasATGM==1 then
								if self.Modern==1 then
									CEPen[#CEPen+1] = self.Guns[g].DakMaxHealth*6.20
								else
									CEPen[#CEPen+1] = self.Guns[g].DakMaxHealth*6.40*0.45
								end
							elseif hasHEATFS==1 then
								if self.Modern==1 then
									CEPen[#CEPen+1] = self.Guns[g].DakMaxHealth*5.4
								else
									CEPen[#CEPen+1] = self.Guns[g].DakMaxHealth*5.40*0.658
								end
							else
								if self.ColdWar==1 then
									CEPen[#CEPen+1] = self.Guns[g].DakMaxHealth*5.4*0.431
								else
									CEPen[#CEPen+1] = self.Guns[g].DakMaxHealth*1.20
								end
							end
							if self.Guns[g]:GetClass() == "dak_teautogun" then
								ShotsPerSecond = 1/(self.Guns[g].DakCooldown+((1/self.Guns[g].DakMagazine)*self.Guns[g].DakReloadTime))
								DPS = self.Guns[g].BaseDakShellDamage*ShotsPerSecond
							end
							if self.Guns[g]:GetClass() == "dak_tegun" or self.Guns[g]:GetClass() == "dak_temachinegun" then
								if self.Guns[g]:GetClass() == "dak_temachinegun" then self.Guns[g].ShellLengthExact = 6.5 end
								ShotsPerSecond = 1/(0.2484886*(math.pi*((self.Guns[g].DakCaliber*0.001*0.5)^2)*(self.Guns[g].DakCaliber*0.001*self.Guns[g].ShellLengthExact)*5150)+1.279318)
								DPS = self.Guns[g].BaseDakShellDamage*ShotsPerSecond
							end
							local shellmult = 1
							--if self.Guns[g].ShellLengthMult then shellmult = self.Guns[g].ShellLengthMult end
							TotalDPS = TotalDPS + DPS*shellmult
						end
						table.sort( KEPen, function( a, b ) return a > b end )
						table.sort( CEPen, function( a, b ) return a > b end )
						local Pen = math.max(KEPen[1],CEPen[1])		
						local firepowermult = Pen*0.003
						if Pen>500 then firepowermult = math.log(Pen,500)+0.5 end
						local altfirepowermult = 0.005*TotalDPS^1
						--if altfirepowermult > firepowermult then firepowermult = altfirepowermult end
						math.max(0.1,firepowermult)
						firepowermult = (altfirepowermult+firepowermult)*0.5
						firepowermult = math.max((self.DakMaxHealth/25000),firepowermult)
						self.FirepowerMult = math.Round(math.max((self.DakMaxHealth/25000),firepowermult),2)
						self.SpeedMult = math.Round(math.max(0.1,speedmult),2)
						self.ArmorMult = math.Round(math.max(0.1,armormult),2)
						self.AmmoCost = math.Round(ammocosts)
						self.ComponentCost = math.Round(self.PreCost)
						self.PreCost = (self.PreCost + ammocosts + 100)*0.5
						self.PreCost = self.PreCost*(armormult*speedmult*firepowermult)
						self.Cost = math.Round(self.PreCost)
					end
				end
				if not(self.Dead) then
					if not(self.DakMaxHealth) then
						self.DakMaxHealth = 10
					end
					if table.Count(self.HitBox)==0 then
						if self.DakHealth>self.DakMaxHealth then
							self.DakHealth = self.DakMaxHealth
						end
					end
					if not self:GetModel() == self.DakModel then
						self:SetModel(self.DakModel)
						self:PhysicsInit(SOLID_VPHYSICS)
						self:SetMoveType(MOVETYPE_VPHYSICS)
						self:SetSolid(SOLID_VPHYSICS)
					end
					
					if self.rebuildtable == nil or self.rebuildtable == 5 then --rebuild contraption table every 5 seconds instead of every second to notice weight changes.
						self.rebuildtable = 0
					end

					if self.rebuildtable == 0 then
						self.Contraption = {}
						table.Add(self.Contraption,GetParents(self))
						for k, v in pairs(GetParents(self)) do
							table.Add(self.Contraption,GetPhysCons(v))
						end

						local Mass = 0
						local ParentMass = 0
						local SA = 0

						for i=1, #self.Contraption do
							table.Add( self.Contraption, self.Contraption[i]:GetChildren() )
							table.Add( self.Contraption, self.Contraption[i]:GetParent() )
						end
						local Children = {}
						for i2=1, #self.Contraption do
							if table.Count(self.Contraption[i2]:GetChildren()) > 0 then
							table.Add( Children, self.Contraption[i2]:GetChildren() )
							end
						end
						table.Add( self.Contraption, Children )

						local hash = {}
						local res = {}
						for _,v in ipairs(self.Contraption) do
					   		if (not hash[v]) then
					    		res[#res+1] = v
					       		hash[v] = true
					   		end
						end
						self.Modern = 0
						self.ColdWar = 0
						self.Contraption={}
						self.Ammoboxes={}
						self.TurretControls={}
						self.Guns={}
						self.Crew={}
						self.Motors={}
						self.Fuel={}
						self.Tread={}
						self.PreCost = 0
						self.GunCount = 0
						self.MachineGunCount = 0
						for i=1, #res do
							if res[i]:IsSolid() then
									self.Contraption[#self.Contraption+1] = res[i]
								if res[i]:GetClass()=="dak_tegearbox" then
									res[i].DakTankCore = self
									self.Gearbox = res[i]
								end
								if res[i]:GetClass()=="dak_tefuel" then
									self.Fuel[#self.Fuel+1] = res[i]
								end
								if res[i]:GetClass()=="dak_temotor" then
									self.Motors[#self.Motors+1] = res[i]
								end
								if res[i]:GetClass() == "dak_teammo" then
									local boxname = (string.Split( res[i].DakAmmoType, "" ))
									local name6 = boxname[#boxname-9]..boxname[#boxname-8]..boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
									local name4 = boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
									local name2 = boxname[#boxname-5]..boxname[#boxname-4]
									--check longest to shortest names, with if then ifelse then else
									local name 
									if name6 == "APFSDS" or name6 == "HEATFS" then
										name = name6
									elseif name4 == "HVAP" or name4 == "APDS" or name4 == "HEAT" or name4 == "HESH" or name4 == "ATGM" or name4 == "APHE" then
										name = name4
									elseif name2 == "AP" or name2 == "HE" then
										name = name2
									end
									if name == "APFSDS" then
										self.Modern = 1
									end
									if name == "HEATFS" or name == "ATGM" or name == "HESH" or name == "APDS" then
										self.ColdWar = 1
									end
									self.Ammoboxes[#self.Ammoboxes+1] = res[i]
								end
								if res[i]:GetClass()=="dak_tegun" then
									res[i].DakTankCore = self
									self.GunCount = self.GunCount + 1
									self.Guns[#self.Guns+1] = res[i]
								end
								if res[i]:GetClass()=="dak_teautogun" then
									res[i].DakTankCore = self
									self.GunCount = self.GunCount + 1
									self.Guns[#self.Guns+1] = res[i]
								end
								if res[i]:GetClass()=="dak_temachinegun" then
									res[i].DakTankCore = self
									self.MachineGunCount = self.MachineGunCount + 1
									self.Guns[#self.Guns+1] = res[i]
								end
								if res[i]:GetClass()=="dak_turretcontrol" then
									self.TurretControls[#self.TurretControls+1]=res[i]
									res[i].DakContraption = res
									res[i].DakCore = self
								end
								if res[i]:GetClass()=="dak_crew" then
									self.Crew[#self.Crew+1]=res[i]
								end
								if res[i]:GetClass()=="prop_physics" then
									if res[i].IsComposite == 1 then
										if res[i].EntityMods==nil then
											res[i].EntityMods = {}
											res[i].EntityMods.CompositeType = "NERA"
											res[i].EntityMods.CompKEMult = 9.2
											res[i].EntityMods.CompCEMult = 18.4
											res[i].EntityMods.DakName = "NERA"
											self.Modern = 1
											self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.75
										else
											if res[i].EntityMods.CompositeType == nil then
												res[i].EntityMods.CompositeType = "NERA"
												res[i].EntityMods.CompKEMult = 9.2
												res[i].EntityMods.CompCEMult = 18.4
												res[i].EntityMods.DakName = "NERA"
												self.Modern = 1
												self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.75
											end
										end
									end
									if res[i].EntityMods==nil then
									else
										if res[i].EntityMods.CompositeType == nil or res[i].IsComposite == nil then
											if res[i].EntityMods.ArmorType == nil then
												self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()
											else
												if res[i].EntityMods.ArmorType == "RHA" then
													res[i].EntityMods.Density = 7.8125
													res[i].EntityMods.ArmorMult = 1
													res[i].EntityMods.Ductility = 1
													self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()
												end
												if res[i].EntityMods.ArmorType == "CHA" then
													res[i].EntityMods.Density = 7.8125
													res[i].EntityMods.ArmorMult = 1
													res[i].EntityMods.Ductility = 1.5
													self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*0.75
												end
												if res[i].EntityMods.ArmorType == "HHA" then
													res[i].EntityMods.Density = 7.8125
													res[i].EntityMods.ArmorMult = 1
													res[i].EntityMods.Ductility = 1.5
													self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.25
												end
											end
										else
											if res[i].EntityMods.CompositeType == "NERA" then
												self.Modern = 1
												self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.75
											end
											if res[i].EntityMods.CompositeType == "Textolite" then
												self.ColdWar = 1
												self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.5
											end
											if res[i].EntityMods.CompositeType == "ERA" then
												self.ColdWar = 1
												self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.25
											end
										end
									end
								else
									if res[i]:GetClass()=="dak_teautogun"  then
										self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*1.5
									elseif res[i]:GetClass()=="dak_temachinegun" then
										self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()*0.5
									else
										self.PreCost = self.PreCost + res[i]:GetPhysicsObject():GetMass()
									end
								end
								Mass = Mass + res[i]:GetPhysicsObject():GetMass()
								if IsValid(res[i]:GetParent()) then
									ParentMass = ParentMass + res[i]:GetPhysicsObject():GetMass()
								end
								if res[i]:GetPhysicsObject():GetSurfaceArea() then
									if res[i]:GetPhysicsObject():GetMass()>1 then
										SA = SA + res[i]:GetPhysicsObject():GetSurfaceArea()
									end
								else
									self.Tread[#self.Tread+1]=res[i]
								end
							end
						end
						if self.Modern == 1 then
							self.PreCost = math.Round(self.PreCost*0.001)
						elseif self.ColdWar == 1 then
							self.PreCost = math.Round(self.PreCost*0.001)
						else
							self.PreCost = math.Round(self.PreCost*0.001)
						end
						--PrintTable(self.Contraption)
						self.CrewCount = #self.Crew
						WireLib.TriggerOutput(self, "Crew", self.CrewCount)
						if IsValid(self.Gearbox) then
							self.Gearbox.TotalMass = Mass
							self.Gearbox.ParentMass = ParentMass
							self.Gearbox.PhysicalMass = Mass-ParentMass
						end

						if IsValid(self.Tread[1]) then
							if self.Tread[1]:GetPhysicsObject():GetMaterial()~="jeeptire" then
								for i=1, table.Count(self.Tread) do
									self.Tread[i]:GetPhysicsObject():SetMaterial("jeeptire")
								end
							end
						end
						self.TotalMass = Mass
						self.ParMass = ParentMass
						self.PhysMass = Mass-ParentMass
						self.SurfaceArea = SA
						self.SizeMult = (SA/Mass)*0.18
					end

					self.rebuildtable = self.rebuildtable+1

					if table.Count(self.HitBox) == 0 then
						WireLib.TriggerOutput(self, "Health", self.DakHealth)
						WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)
					end
					--SETUP HEALTHPOOL
					if table.Count(self.HitBox) == 0 and self.Contraption and IsValid(self.Gearbox) then
						if #self.Contraption>=1 then
							self.Remake = 0
							self.DakPooled = 1
							self.DakEngine = self
							self.Controller = self
							if #self.Contraption>0 then
								for i=1, #self.Contraption do
									if self.Contraption[i].Controller == nil or self.Contraption[i].Controller == NULL or self.Contraption[i].Controller == self then
										if IsValid(self.Contraption[i]) then
											if string.Explode("_",self.Contraption[i]:GetClass(),false)[1] ~= "dak" and (self.Contraption[i].EntityMods and self.Contraption[i].EntityMods.IsERA~=1) then
												if self.Contraption[i]:IsSolid() then
													self.HitBox[#self.HitBox+1] = self.Contraption[i]
													self.Contraption[i].Controller = self
													self.Contraption[i].DakOwner = self.DakOwner
													self.Contraption[i].DakPooled = 1
												end
											else
												if self.Contraption[i].EntityMods and self.Contraption[i].EntityMods.IsERA==1 then
													self.ERA[#self.ERA+1] = self.Contraption[i]
													self.Contraption[i].Controller = self
													self.Contraption[i].DakOwner = self.DakOwner
													self.Contraption[i].DakPooled = 1
													self.Contraption[i].DakHealth = 5
													self.Contraption[i].DakMaxHealth = 5
												end
											end
											self.Contraption[i].Controller = self
										end
									end
								end
							end
							self.HitBoxMass = 0
							for i=1, table.Count(self.HitBox) do
								self.HitBoxMass = self.HitBoxMass + self.HitBox[i]:GetPhysicsObject():GetMass()
							end
							self.CurrentHealth = self.HitBoxMass*0.01*self.SizeMult*25
							self.DakMaxHealth = self.HitBoxMass*0.01*self.SizeMult*25
							for i=1, table.Count(self.HitBox) do
								DakTekTankEditionSetupNewEnt(self.HitBox[i])
								self.HitBox[i].DakHealth = self.CurrentHealth
								self.HitBox[i].DakMaxHealth = self.CurrentHealth
								self.HitBox[i].Controller = self
								self.HitBox[i].DakOwner = self.DakOwner
								self.HitBox[i].DakPooled = 1
							end
							self.LastRemake = CurTime()
						end
					end
					if table.Count(self.HitBox)~=0 then
						self.DakActive = 1
					else
						self.DakActive = 0
					end

					if self.DakActive == 1 and table.Count(self.HitBox)~=0 and self.CurrentHealth then
						if table.Count(self.HitBox) > 0 then
							if self.Crew then
								if table.Count(self.Crew) > 0 then
									for i = 1, table.Count(self.Crew) do
										if not(IsValid(self.Crew[i])) then
											table.remove( self.Crew, i )
										end
									end
								end
							end

							if self.ERA then
								if table.Count(self.ERA) > 0 then
									local effectdata
									local ExpSounds = {"daktanks/eraexplosion.wav"}
									for i = 1, table.Count(self.ERA) do
										if not(IsValid(self.ERA[i])) then
											table.remove( self.ERA, i )
										end
										if self.ERA[i] ~= nil and self.ERA[i] ~= NULL then
											self.ERA[i].IsComposite = 1
											if self.ERA[i].EntityMods.CompositeType == "NERA" then
												self.ERA[i].EntityMods.CompKEMult = 9.2
												self.ERA[i].EntityMods.CompCEMult = 18.4
												self.ERA[i].EntityMods.DakName = "NERA"
												self.Modern = 1
											end
											if self.ERA[i].EntityMods.CompositeType == "Textolite" then
												self.ERA[i].EntityMods.CompKEMult = 10.4
												self.ERA[i].EntityMods.CompCEMult = 14
												self.ERA[i].EntityMods.DakName = "Textolite"
												self.ColdWar = 1
											end
											if self.ERA[i].EntityMods.CompositeType == "ERA" then
												self.ERA[i].EntityMods.CompKEMult = 2.5
												self.ERA[i].EntityMods.CompCEMult = 88.9
												self.ERA[i].EntityMods.DakName = "ERA"
												self.ERA[i].EntityMods.IsERA = 1
												self.ColdWar = 1
											end
											if self.ERA[i].DakHealth <= 0 then
												effectdata = EffectData()
												effectdata:SetOrigin(self.ERA[i]:GetPos())
												effectdata:SetEntity(self)
												effectdata:SetAttachment(1)
												effectdata:SetMagnitude(.5)
												effectdata:SetScale(50)
												effectdata:SetNormal( Vector(0,0,0) )
												util.Effect("daktescalingexplosion", effectdata, true, true)
												sound.Play( ExpSounds[math.random(1,#ExpSounds)], self.ERA[i]:GetPos(), 100, 100, 1 )
												self.ERA[i]:DTExplosion(self.ERA[i]:GetPos(),25,50,40,5,self.DakOwner)
												self.ERA[i]:Remove()
											end
										end
									end
								end
							end

							if self.Composites then
								if table.Count(self.Composites) > 0 then
									for i = 1, table.Count(self.Composites) do
										if not(IsValid(self.Composites[i])) then
											table.remove( self.Composites, i )
										end
										if self.Composites[i] ~= nil then
											self.Composites[i].IsComposite = 1
											local Density = 2000
											local KE = 9.2
											if self.Composites[i].EntityMods.CompositeType == "NERA" then
												self.Modern = 1
												self.Composites[i].EntityMods.CompKEMult = 9.2
												self.Composites[i].EntityMods.CompCEMult = 18.4
												KE = 9.2
												Density = 2000
												self.Composites[i].EntityMods.DakName = "NERA"
											end
											if self.Composites[i].EntityMods.CompositeType == "Textolite" then
												self.ColdWar = 1
												self.Composites[i].EntityMods.CompKEMult = 10.4
												self.Composites[i].EntityMods.CompCEMult = 14
												KE = 10.4
												Density = 1850
												self.Composites[i].EntityMods.DakName = "Textolite"
											end
											if self.Composites[i].EntityMods.CompositeType == "ERA" then
												self.ColdWar = 1
												self.Composites[i].EntityMods.CompKEMult = 2.5
												self.Composites[i].EntityMods.CompCEMult = 88.9
												KE = 2.5
												Density = 1732
												self.Composites[i].EntityMods.DakName = "ERA"
												self.Composites[i].EntityMods.IsERA = 1
											end
											self.Composites[i].IsComposite = 1
											self.Composites[i]:GetPhysicsObject():SetMass( math.Round(self.Composites[i]:GetPhysicsObject():GetVolume()/61023.7*Density) )
											self.Composites[i].DakArmor = math.sqrt(math.sqrt(self.Composites[i]:GetPhysicsObject():GetVolume()))*KE
										end
									end
								end
							end
							if self.ERA then
								if table.Count(self.ERA) > 0 then
									for i = 1, table.Count(self.ERA) do
										if IsValid(self.ERA[i]) then
											if self.ERA[i].EntityMods then
												if self.ERA[i].EntityMods.CompositeType == "ERA" then
													self.ColdWar = 1
													self.ERA[i].EntityMods.CompKEMult = 2.5
													self.ERA[i].EntityMods.CompCEMult = 88.9
													self.ERA[i].EntityMods.DakName = "ERA"
													self.ERA[i].EntityMods.IsERA = 1
												end
												self.ERA[i]:GetPhysicsObject():SetMass( math.Round(self.ERA[i]:GetPhysicsObject():GetVolume()/61023.7*1732) )
												self.ERA[i].DakArmor = math.sqrt(math.sqrt(self.ERA[i]:GetPhysicsObject():GetVolume()))*2.5
											end
										end
									end
								end
							end

							self.DamageCycle = 0
							if self.DakHealth < self.CurrentHealth then
								self.DamageCycle = self.DamageCycle+(self.CurrentHealth-self.DakHealth)
								self.DakLastDamagePos = self.DakLastDamagePos	
							end
							self.Remake = 0
							self.LastCurMass = self.CurMass
							self.CurMass = 0
							for i = 1, table.Count(self.HitBox) do
								if self.HitBox[i].Controller ~= self then
									self.Remake = 1	
								end
								if self.Remake == 1 then
									if self.HitBox[i].Controller == self then
										self.HitBox[i].DakPooled = 0
										self.HitBox[i].Controller = nil
									end
								end
								if self.LastCurMass>0 then
									if self.HitBox[i].DakHealth then
										if self.HitBox[i].DakHealth < self.CurrentHealth then
											if self.HitBox[i].EntityMods.IsERA == 1 then
												table.RemoveByValue( self.Composites, NULL )
												table.RemoveByValue( self.HitBox, NULL )
											end
											self.DamageCycle = self.DamageCycle+(self.CurrentHealth-self.HitBox[i].DakHealth)
											self.DakLastDamagePos = self.HitBox[i].DakLastDamagePos	
										end
									end
								end
								if self.Remake == 1 then
									self.HitBox = {}
									self.Remake = 0
									break
								end
								if self.HitBox[i]~=NULL then
									if self.HitBox[i].Controller == self then
										if self.HitBox[i]:IsSolid() then
											self.CurMass = self.CurMass + self.HitBox[i]:GetPhysicsObject():GetMass()
										end
									end
								end
							end

							if not(self.CurMass>self.LastCurMass) then
								if self.DamageCycle>0 then
									if self.LastRemake+3 > CurTime() then
										self.DamageCycle = 0
									end
									self.CurrentHealth = self.CurrentHealth-self.DamageCycle
								end
							end
							for i = 1, table.Count(self.HitBox) do
								if self.CurrentHealth >= self.DakMaxHealth then
									self.DakMaxHealth = self.CurMass*0.01*self.SizeMult*25
									self.CurrentHealth = self.CurMass*0.01*self.SizeMult*25
									self.HitBox[i].DakMaxHealth = self.CurMass*0.01*self.SizeMult*25
								end
								self.HitBox[i].DakHealth = self.CurrentHealth
							end
							self.DakHealth = self.CurrentHealth
							
							local curvel = self:GetParent():GetParent():GetVelocity()
							if self.LastVel == nil then
								self.LastVel = curvel
							end
							if curvel:Distance(self.LastVel) > 1000 then
								for i=1, #self.Crew do
									self.Crew[i].DakHealth = self.Crew[i].DakHealth - ((curvel:Distance(self.LastVel)-1000)/100)

									if self.Crew[i].DakHealth <= 0 then
										local salvage = ents.Create( "dak_tesalvage" )
										salvage.DakModel = self.Crew[i]:GetModel()
										salvage:SetPos( self.Crew[i]:GetPos())
										salvage:SetAngles( self.Crew[i]:GetAngles())
										salvage:Spawn()
										self.Crew[i]:Remove()
									end

								end
							end
							self.LastVel = curvel


							WireLib.TriggerOutput(self, "Health", self.DakHealth)
							WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)
							if self.DakHealth then
								if (self.DakHealth <= 0 or #self.Crew <= 0) and self:GetParent():GetParent():GetPhysicsObject():IsMotionEnabled() then
									local DeathSounds = {"daktanks/closeexp1.wav","daktanks/closeexp2.wav","daktanks/closeexp3.wav"}

									self.RemoveTurretList = {}

									if math.random(1,3) == 1 then
										for j=1, #self.TurretControls do
											if IsValid(self.TurretControls[j]) then
												table.RemoveByValue( self.Contraption, self.TurretControls[j].TurretBase )
												if IsValid(self.TurretControls[j].TurretBase) then
													self.TurretControls[j].TurretBase:SetMaterial("models/props_buildings/plasterwall021a")
													self.TurretControls[j].TurretBase:SetColor(Color(100,100,100,255))
													self.TurretControls[j].TurretBase:SetCollisionGroup( COLLISION_GROUP_WORLD )
													self.TurretControls[j].TurretBase:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
													if math.random(0,9) == 0 then
														self.TurretControls[j].TurretBase:Ignite(25,1)
													end
													if IsValid(self) then
														if IsValid(self:GetParent()) then
															if IsValid(self:GetParent():GetParent()) then
																constraint.RemoveAll( self:GetParent():GetParent() )
															end
														end
													end
													for l=1, #self.TurretControls[j].Turret do
														if self.TurretControls[j].Turret[l] ~= self.TurretControls[j].TurretBase then
															if IsValid(self.TurretControls[j].Turret[l]) then
																table.RemoveByValue( self.Contraption, self.TurretControls[j].Turret[l] )
																self.TurretControls[j].Turret[l]:SetParent( self.TurretControls[j].TurretBase, -1 )
																self.TurretControls[j].Turret[l]:SetMoveType( MOVETYPE_NONE )
																self.TurretControls[j].Turret[l]:SetMaterial("models/props_buildings/plasterwall021a")
																self.TurretControls[j].Turret[l]:SetColor(Color(100,100,100,255))
																self.TurretControls[j].Turret[l]:SetCollisionGroup( COLLISION_GROUP_WORLD )
																self.TurretControls[j].Turret[l]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
																if self.TurretControls[j].Turret[l]:IsVehicle() then
																	if IsValid(self.TurretControls[j].Turret[l]:GetDriver()) then
																		self.TurretControls[j].Turret[l]:GetDriver():Kill()
																	end
																	self.TurretControls[j].Turret[l]:Remove()
																end
																if math.random(0,9) == 0 then
																	self.TurretControls[j].Turret[l]:Ignite(25,1)
																end
																if self.TurretControls[j].Turret[l]:GetClass() == "dak_teammo" then
																	if math.random(0,1) == 0 then
																		self.TurretControls[j].Turret[l]:Ignite(25,1)
																	end
																end
															end
														end
													end
													self.TurretControls[j].TurretBase:SetAngles(self.TurretControls[j].TurretBase:GetAngles() + Angle(math.Rand(-45,45),math.Rand(-45,45),math.Rand(-45,45)))
													self.TurretControls[j].TurretBase:GetPhysicsObject():ApplyForceCenter(self.TurretControls[j].TurretBase:GetUp()*2500*self.TurretControls[j].TurretBase:GetPhysicsObject():GetMass())
													self.RemoveTurretList[#self.RemoveTurretList+1] = self.TurretControls[j].TurretBase
												end
											end
										end
									end

									for i=1, #self.Contraption do
										if IsValid(self.Contraption[i]) then
											if self.Contraption[i].DakPooled == 0 or self.Contraption[i]:GetParent()==self:GetParent() or self.Contraption[i].Controller == self then
												self.Contraption[i].DakLastDamagePos = self.DakLastDamagePos
												if self.Contraption[i] ~= self:GetParent():GetParent() and self.Contraption[i] ~= self:GetParent() and self.Contraption[i] ~= self then
													if math.random(1,6)>1 then
														if self.Contraption[i]:GetClass() == "dak_tegearbox" or self.Contraption[i]:GetClass() == "dak_turretcontrol" or (string.Explode("_",self.Contraption[i]:GetClass(),false)[1] == "gmod") then
															self.salvage = ents.Create( "dak_tesalvage" )
															if ( !IsValid( self.salvage ) ) then return end
															if self.Contraption[i]:GetClass() == "dak_crew" then
																if self.Contraption[i].DakHealth <= 0 then
																	for i=1, 15 do
																		util.Decal( "Blood", self.Contraption[i]:GetPos(), self.Contraption[i]:GetPos()+(VectorRand()*500), self.Contraption[i])
																	end
																end
															end

															self.salvage.DakModel = self.Contraption[i]:GetModel()
															self.salvage:SetPos( self.Contraption[i]:GetPos())
															self.salvage:SetAngles( self.Contraption[i]:GetAngles())
															self.salvage:Spawn()
															self.Contraption[i]:Remove()
														else
															constraint.RemoveAll( self.Contraption[i] )
															self.Contraption[i]:SetParent( self:GetParent(), -1 )
															self.Contraption[i]:SetMoveType( MOVETYPE_NONE )
															self.Contraption[i]:SetMaterial("models/props_buildings/plasterwall021a")
															self.Contraption[i]:SetColor(Color(100,100,100,255))
															self.Contraption[i]:SetCollisionGroup( COLLISION_GROUP_WORLD )
															self.Contraption[i]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
															if math.random(0,9) == 0 then
																self.Contraption[i]:Ignite(25,1)
															end
															if self.Contraption[i]:GetClass() == "dak_teammo" then
																if math.random(0,1) == 0 then
																	self.Contraption[i]:Ignite(25,1)
																end
															end
														end
													else
														self.salvage = ents.Create( "dak_tesalvage" )
														if ( !IsValid( self.salvage ) ) then return end
														self.salvage.launch = 1
														if self.Contraption[i]:GetClass() == "dak_crew" then
															if self.Contraption[i].DakHealth <= 0 then
																for i=1, 15 do
																	util.Decal( "Blood", self.Contraption[i]:GetPos(), self.Contraption[i]:GetPos()+(VectorRand()*500), self.Contraption[i])
																end
															end
														end
														self.salvage.DakModel = self.Contraption[i]:GetModel()
														self.salvage:SetPos( self.Contraption[i]:GetPos())
														self.salvage:SetAngles( self.Contraption[i]:GetAngles())
														self.salvage:Spawn()
														self.Contraption[i]:Remove()
													end
													if self.Contraption[i]:IsVehicle() then
														if IsValid(self.Contraption[i]:GetDriver()) then
															self.Contraption[i]:GetDriver():Kill()
														end
														self.Contraption[i]:Remove()
													end
												end
											end
										end
									end
									self.Dead=1
									self.DeathTime=CurTime()
									local effectdata = EffectData()
									effectdata:SetOrigin(self:GetParent():GetParent():GetPos())
									effectdata:SetEntity(self)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetNormal( Vector(0,0,-1) )
									effectdata:SetScale(math.Clamp(self.DakMaxHealth*0.04,100,500))
									util.Effect("daktescalingexplosion", effectdata)
								end
							else
								self:Remove()
							end

						end
					end
				else
					if self.DeathTime then
						if self.DeathTime+30<CurTime() then
							for j=1, #self.RemoveTurretList do
								if IsValid(self.RemoveTurretList[j]) then
									self.RemoveTurretList[j]:Remove()
								end
							end
							if IsValid(self) then
								self:Remove()
							end
							if IsValid(self:GetParent():Remove()) then
								self:GetParent():Remove()
							end
							if IsValid(self:GetParent():GetParent():Remove()) then
								self:GetParent():GetParent():Remove()
							end
						end
					end
				end
			else
				if self.SpawnTime+10 < CurTime() then
					self.DakOwner:PrintMessage( HUD_PRINTTALK, "Tank Core Error: Gate that tank core is parented to is not parented, please parent it to the baseplate." )
				end
			end
		else
			if self.SpawnTime+10 < CurTime() then
				self.DakOwner:PrintMessage( HUD_PRINTTALK, "Tank Core Error: Tank core is not parented to anything, please parent it to a gate." )
			end
		end
	end
	self:NextThink(CurTime()+1)
    return true
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}

	local CompositesIDs = {}
	if table.Count(self.Composites)>0 then
		for i = 1, table.Count(self.Composites) do
			if not(self.Composites[i]==nil) then
				table.insert(CompositesIDs,self.Composites[i]:EntIndex())
			end
		end
	end
	info.CompositesCount = table.Count(self.Composites)
	local ERAIDs = {}
	if table.Count(self.ERA)>0 then
		for i = 1, table.Count(self.ERA) do
			if not(self.ERA[i]==nil) then
				table.insert(ERAIDs,self.ERA[i]:EntIndex())
			end
		end
	end
	info.ERACount = table.Count(self.ERA)

	info.DakName = self.DakName
	info.DakHealth = self.DakHealth
	info.DakMaxHealth = self.DakBaseMaxHealth
	info.DakMass = self.DakMass
	info.DakOwner = self.DakOwner
	duplicator.StoreEntityModifier( self, "DakTek", info )
	duplicator.StoreEntityModifier( self, "DTComposites", CompositesIDs )
	duplicator.StoreEntityModifier( self, "DTERA", ERAIDs )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		if Ent.EntityMods.DakTek.CompositesCount == nil then
			self.NewComposites = {}
			if Ent.EntityMods.DTComposites then
				for i = 1, table.Count(Ent.EntityMods.DTComposites) do
					self.Ent = CreatedEntities[ Ent.EntityMods.DTComposites[i]]
					if self.Ent and IsValid(self.Ent) then
						table.insert(self.NewComposites,self.Ent)
					end
				end
			end
			self.Composites = self.NewComposites
		else
			if Ent.EntityMods.DakTek.CompositesCount > 0 then
				self.NewComposites = {}
				if Ent.EntityMods.DTComposites then
					for i = 1, Ent.EntityMods.DakTek.CompositesCount do
						local hitEnt = CreatedEntities[ Ent.EntityMods.DTComposites[i]]
						if IsValid(hitEnt) then
							table.insert(self.NewComposites,hitEnt)
						end
					end
				end
				self.Composites = self.NewComposites
			else
				self.Composites = {}
			end
		end
		if Ent.EntityMods.DakTek.ERACount == nil then
			self.NewERA = {}
			if Ent.EntityMods.DTERA then
				for i = 1, table.Count(Ent.EntityMods.DTERA) do
					self.Ent = CreatedEntities[ Ent.EntityMods.DTERA[i]]
					if self.Ent and IsValid(self.Ent) then
						table.insert(self.NewERA,self.Ent)
					end
				end
			end
			self.ERA = self.NewERA
		else
			if Ent.EntityMods.DakTek.ERACount > 0 then
				self.NewERA = {}
				if Ent.EntityMods.DTERA then
					for i = 1, Ent.EntityMods.DakTek.ERACount do
						local hitEnt = CreatedEntities[ Ent.EntityMods.DTERA[i]]
						if IsValid(hitEnt) then
							table.insert(self.NewERA,hitEnt)
						end
					end
				end
				self.ERA = self.NewERA
			else
				self.ERA = {}
			end
		end
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		Ent.EntityMods.DakTek = nil
	end
	self.DakOwner = Player
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end

function ENT:OnRemove()
	if table.Count(self.HitBox)>0 then
		for i = 1, table.Count(self.HitBox) do
			self.HitBox[i].DakPooled = 0
			self.HitBox[i].DakController = nil
		end
	end
end

