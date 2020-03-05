AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakName = "Tank Core"
ENT.HitBox = {}
ENT.DakActive = 0
ENT.DakFuel = nil

--cause self to delete self if not properly unfrozen

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
	self.Modern = 0
	self.ColdWar = 0
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
	local systime = SysTime()
	
	if IsValid(self) then
		if IsValid(self:GetParent()) then
			if IsValid(self:GetParent():GetParent()) then
				self.Base = self:GetParent():GetParent()
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
					local blocks = 0
					local gunhit = 0
					local gearhit = 0
					local HitCrit = 0
					local forward = Angle(0,self.Gearbox:GetAngles().yaw,0):Forward()
					local right = Angle(0,self.Gearbox:GetAngles().yaw,0):Right()
					local up = Angle(0,self.Gearbox:GetAngles().yaw,0):Up()
					--FRONT
					local startpos = self:GetParent():GetParent():GetPos()+(up*125)+(right*-125)
					local basesize = self:GetParent():GetParent():OBBMaxs()
					local distance = math.Max(basesize.x, basesize.y, basesize.z)*3
					local ArmorValTable = {}
					for i=1, 25 do
						for j=1, 25 do
							addpos = (right*10*j)+(up*-10*i)+(up*0.4*j)
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit = DTGetArmorRecurseNoStop(startpos+addpos+forward*distance, startpos+addpos, "AP", 75, player.GetAll())
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
								end
							end
						end
					end
					local totalarmor = 0
					table.sort( ArmorValTable, function(a, b) return a < b end )
					local Ave = 0
					local AveCount = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					self.FrontalArmor = Ave/AveCount
					--REAR
					count = 0
					blocks = 0
					HitCrit = 0
					startpos = self:GetParent():GetParent():GetPos()+(up*125)+(right*-125)
					ArmorValTable = {}
					for i=1, 50 do
						for j=1, 50 do
							addpos = (right*5*j)+(up*-5*i)+(up*0.2*j)
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit = DTGetArmorRecurseNoStop(startpos+addpos-forward*distance, startpos+addpos, "AP", 75, player.GetAll())
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
								end
							end
						end
					end
					Ave = 0
					AveCount = 0
					totalarmor = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					self.RearArmor = Ave/AveCount
					--LEFT
					count = 0
					blocks = 0
					HitCrit = 0
					startpos = self:GetParent():GetParent():GetPos()+(up*125)+(forward*-125)
					ArmorValTable = {}
					for i=1, 25 do
						for j=1, 25 do
							addpos = (forward*10*j)+(up*-10*i)+(up*0.4*j)
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit = DTGetArmorRecurseNoStop(startpos+addpos+right*distance, startpos+addpos, "AP", 75, player.GetAll())
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
								end
							end
						end
					end
					Ave = 0
					AveCount = 0
					totalarmor = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					local LeftArmor = Ave/AveCount
					--RIGHT
					count = 0
					blocks = 0
					HitCrit = 0
					startpos = self:GetParent():GetParent():GetPos()+(up*125)+(forward*-125)
					ArmorValTable = {}
					for i=1, 25 do
						for j=1, 25 do
							addpos = (forward*10*j)+(up*-10*i)+(up*0.4*j)
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit = DTGetArmorRecurseNoStop(startpos+addpos-right*distance, startpos+addpos, "AP", 75, player.GetAll())
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
								end
							end
						end
					end
					Ave = 0
					AveCount = 0
					totalarmor = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					local RightArmor = Ave/AveCount
					self.SideArmor = (RightArmor+LeftArmor)/2

					local Total = math.max(self.FrontalArmor,self.SideArmor,self.RearArmor)
					armormult = Total/420
					--local armormult = (self.FrontalArmor*0.5)+(self.SideArmor*0.3)+(self.RearArmor*0.2)
					--print(self.FrontalArmor)
					--print(self.SideArmor)
					--print(self.RearArmor)
					local shellvol = ((100*0.0393701)^2)*(100*0.0393701*13)
					local shells = 0
					local ammocosts = 0


					for i = 1, #self.Guns do
						self.Guns[i].AmmoBoxes = {}
						for j = 1, #self.Ammoboxes do
							if not(self.Ammoboxes[j].DakAmmoType == "Flamethrower Fuel") then
								if self.Guns[i].DakGunType == "Short Cannon" or self.Guns[i].DakGunType == "Short Autoloader" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "S" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Cannon" or self.Guns[i].DakGunType == "Autoloader" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Long Cannon" or self.Guns[i].DakGunType == "Long Autoloader" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "L" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Howitzer" or self.Guns[i].DakGunType == "Autoloading Howitzer" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "H" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] ~= "M" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Mortar" or self.Guns[i].DakGunType == "Autoloading Mortar" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "M" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] ~= "G" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Smoke Launcher" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "S" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "L" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Flamethrower" then
									if self.Ammoboxes[j].DakAmmoType == "Flamethrower Fuel" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "MG" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "M" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "G" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Grenade Launcher" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "G" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "L" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "HMG" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "H" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "M" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][3] == "G" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Autocannon" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "A" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								else
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								end
							end
						end
					end

					local MaxPen = 0
					for i = 1, #self.Guns do
						for j = 1, #self.Guns[i].AmmoBoxes do
							local boxname = (string.Split( self.Guns[i].AmmoBoxes[j].DakAmmoType, "" ))
							local name6 = boxname[#boxname-9]..boxname[#boxname-8]..boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
							local name4 = boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
							local name2 = boxname[#boxname-5]..boxname[#boxname-4]
							local name
							if name6 == "APFSDS" or name6 == "HEATFS" then
								name = name6
							elseif name4 == "HVAP" or name4 == "APDS" or name4 == "HEAT" or name4 == "HESH" or name4 == "ATGM" or name4 == "APHE" then
								name = name4
							elseif name2 == "AP" or name2 == "HE" then
								name = name2
							end
							if name == "APFSDS" then
								if self.Guns[i].BaseDakShellPenetration*7.8*0.5 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*7.8*0.5 end
							elseif name == "APDS" then
								if self.Guns[i].BaseDakShellPenetration*1.67 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*1.67 end
							elseif name == "HVAP" then
								if self.Guns[i].BaseDakShellPenetration*1.5 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*1.5 end
							elseif name == "AP" then
								if self.Guns[i].BaseDakShellPenetration > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration end
							elseif name == "APHE" then
								if self.Guns[i].BaseDakShellPenetration*0.825 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*0.825 end
							elseif name == "ATGM" then
								if self.Modern==1 then
									if self.Guns[i].DakMaxHealth*6.40 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*6.40 end
								else
									if self.Guns[i].DakMaxHealth*6.40*0.45 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*6.40*0.45 end
								end
							elseif name == "HEATFS" then
								if self.Modern==1 then
									if self.Guns[i].DakMaxHealth*5.4 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*5.4 end
								else
									if self.Guns[i].DakMaxHealth*5.40*0.658 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*5.40*0.658 end
								end
							elseif name == "HEAT" then
								if self.Modern==1 then
									if self.Guns[i].DakMaxHealth*5.4*0.431 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*5.4*0.431 end
								else
									if self.Guns[i].DakMaxHealth*1.20 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*1.20 end
								end
							elseif name == "HESH" then
								if self.Guns[i].DakMaxHealth*1.25 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*1.25 end
							elseif name == "HE" then
								if self.Guns[i].DakMaxHealth*0.2 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*0.2 end
							end
						end
					end


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
					--local speedmult = math.Clamp((((math.Clamp(self.Gearbox.DakHP,0,self.Gearbox.MaxHP)/(self.Gearbox.TotalMass/1000))*0.05)),0,2)
					--armormult = armormult+0.1
					--armormult = 1.002663 - 1.056967*2.718^(-6.413596*armormult)

					local DPS = 0
					local TotalDPS = 0
					local ShotsPerSecond
					for g=1, #self.Guns do 
						if self.Guns[g]:GetClass() == "dak_teautogun" then
							ShotsPerSecond = 1/(self.Guns[g].DakCooldown+((1/self.Guns[g].DakMagazine)*self.Guns[g].DakReloadTime))
							DPS = self.Guns[g].BaseDakShellDamage*ShotsPerSecond
						end
						if self.Guns[g]:GetClass() == "dak_tegun" then
							ShotsPerSecond = 1/(0.2484886*(math.pi*((self.Guns[g].DakCaliber*0.001*0.5)^2)*(self.Guns[g].DakCaliber*0.001*self.Guns[g].ShellLengthExact)*5150)+1.279318)
							DPS = self.Guns[g].BaseDakShellDamage*ShotsPerSecond
						end
						if self.Guns[g]:GetClass() == "dak_temachinegun" then
							self.Guns[g].ShellLengthExact = 6.5
							ShotsPerSecond = 1/self.Guns[g].DakCooldown
							DPS = self.Guns[g].BaseDakShellDamage*ShotsPerSecond
						end
						TotalDPS = TotalDPS + DPS
					end
					self.MaxPen = MaxPen
					local firepowermult = MaxPen/420
					local altfirepowermult = 0.005*TotalDPS^1
					--if altfirepowermult > firepowermult then firepowermult = altfirepowermult end
					math.max(0.1,firepowermult)
					firepowermult = (altfirepowermult+firepowermult)*0.5
					firepowermult = math.max((self.DakMaxHealth/25000),firepowermult)

					local GunHandlingMult = 0
					if self.TurretControls[1] then
						local TotalTurretMass = 0 
						for i=1, #self.TurretControls do
							if self.TurretControls[i].GunMass ~= nil then
								TotalTurretMass = TotalTurretMass + self.TurretControls[i].GunMass
							end
						end
						local StabMults = 0
						local FCSMults = 0
						local GunPercentage
						local RotationSpeeds = 0
						local HullMounts = 0
						for i=1, #self.TurretControls do
							if self.TurretControls[i].GunMass ~= nil then
								GunPercentage = self.TurretControls[i].GunMass/TotalTurretMass
								if self.TurretControls[i]:GetFCS() == true then
									self.ColdWar = 1
									FCSMults = FCSMults + 1.5 * GunPercentage
								end
								if self.TurretControls[i]:GetStabilizer() == true then
									self.ColdWar = 1
									StabMults = StabMults + 1.25 * GunPercentage
								elseif self.TurretControls[i]:GetShortStopStabilizer() == true then
									StabMults = StabMults + 1 * GunPercentage
								else
									StabMults = StabMults + 0.75 * GunPercentage
								end
								RotationSpeeds = RotationSpeeds + self.TurretControls[i].RotationSpeed * GunPercentage
								if self.TurretControls[i]:GetYawMin()<=45 and self.TurretControls[i]:GetYawMax()<=45 then
									HullMounts = HullMounts + GunPercentage
								end
							end
						end
						GunHandlingMult = math.log(RotationSpeeds*100,100)
						GunHandlingMult = GunHandlingMult * math.Max(FCSMults,1)
						GunHandlingMult = GunHandlingMult * StabMults
						GunHandlingMult = GunHandlingMult * (1-(0.50*HullMounts))
					end

					--print("Highest Armor: "..(armormult*50))
					--print("Side Armor "..self.SideArmor)
					--print("Side Armor Mult: "..(self.SideArmor/100))
					--print("Adjusted Armor: "..((armormult*50)*(self.SideArmor/100)))

					self.FirepowerMult = math.Round(math.max((self.DakMaxHealth/25000),firepowermult),2)
					self.SpeedMult = math.Round(math.max(0.1,speedmult),2)
					self.ArmorMult = math.Round(math.max(0.1,armormult),2)
					self.GunHandlingMult = math.Round(math.max(0.1,GunHandlingMult),2)

					self.TotalArmorWeight = self.RHAWeight+self.CHAWeight+self.HHAWeight+self.NERAWeight+self.TextoliteWeight+self.ERAWeight
					local ArmorTypeMult = (((1*(self.RHAWeight/self.TotalArmorWeight))+(0.75*(self.CHAWeight/self.TotalArmorWeight))+(1.25*(self.HHAWeight/self.TotalArmorWeight))+(1.75*(self.NERAWeight/self.TotalArmorWeight))+(1.5*(self.TextoliteWeight/self.TotalArmorWeight))+(1.25*(self.ERAWeight/self.TotalArmorWeight))))

					self.ArmorMult = self.ArmorMult * ArmorTypeMult
					self.PreCost = self.ArmorMult*50 + self.FirepowerMult*50
					--self.PreCost = self.PreCost*(armormult*speedmult*firepowermult*self.GunHandlingMult)
					self.PreCost = self.PreCost*((self.SpeedMult+self.GunHandlingMult)*0.5)
					self.Cost = math.Round(self.PreCost)


					local curera = "WWII"
					if self.ColdWar == 1 then curera = "Cold War" end
					if self.Modern == 1 then curera = "Modern" end
					self.DakOwner:ChatPrint("Tank Analysis Complete: "..self.Cost.." point "..curera.." tank. Right click tank core with spawner for detailed readout.")
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
						local ContraptionI
						for i=1, #self.Contraption do
							ContraptionI = self.Contraption[i]
							table.Add( self.Contraption, ContraptionI:GetChildren() )
							table.Add( self.Contraption, ContraptionI:GetParent() )
						end
						local Children = {}
						local ContraptionI2
						for i2=1, #self.Contraption do
							ContraptionI2 = self.Contraption[i2]
							if table.Count(ContraptionI2:GetChildren()) > 0 then
							table.Add( Children, ContraptionI2:GetChildren() )
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
						
						self.Contraption={}
						self.Ammoboxes={}
						self.TurretControls={}
						self.Guns={}
						self.Crew={}
						self.Motors={}
						self.Fuel={}
						self.Tread={}
						self.ERA={}
						self.Seats={}
						self.GunCount = 0
						self.MachineGunCount = 0

						self.RHAWeight = 0
						self.CHAWeight = 0
						self.HHAWeight = 0
						self.NERAWeight = 0
						self.TextoliteWeight = 0
						self.ERAWeight = 0


						local CurrentRes
						for i=1, #res do
							CurrentRes = res[i]
							if CurrentRes:IsSolid() then
									self.Contraption[#self.Contraption+1] = CurrentRes
								if CurrentRes:GetClass()=="dak_tegearbox" or CurrentRes:GetClass()=="dak_tegearboxnew" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.Gearbox = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_tefuel" then
									self.Fuel[#self.Fuel+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_temotor" then
									self.Motors[#self.Motors+1] = CurrentRes
								end
								if CurrentRes:GetClass() == "dak_teammo" then
									local boxname = (string.Split( CurrentRes.DakAmmoType, "" ))
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
									self.Ammoboxes[#self.Ammoboxes+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_tegun" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.GunCount = self.GunCount + 1
									self.Guns[#self.Guns+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_teautogun" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.GunCount = self.GunCount + 1
									self.Guns[#self.Guns+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_temachinegun" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.MachineGunCount = self.MachineGunCount + 1
									self.Guns[#self.Guns+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_turretcontrol" then
									self.TurretControls[#self.TurretControls+1]=CurrentRes
									CurrentRes.DakContraption = res
									CurrentRes.DakCore = self
								end
								if CurrentRes:GetClass()=="prop_vehicle_prisoner_pod" then
									self.Seats[#self.Seats+1]=CurrentRes
								end
								if CurrentRes:GetClass()=="dak_crew" then
									self.Crew[#self.Crew+1]=CurrentRes
								end
								if CurrentRes:GetClass()=="prop_physics" then
									if CurrentRes.IsComposite == 1 then
										if CurrentRes.EntityMods==nil then
											CurrentRes.EntityMods = {}
											CurrentRes.EntityMods.CompositeType = "NERA"
											CurrentRes.EntityMods.CompKEMult = 9.2
											CurrentRes.EntityMods.CompCEMult = 18.4
											CurrentRes.EntityMods.DakName = "NERA"
											self.Modern = 1
										else
											if CurrentRes.EntityMods.CompositeType == nil then
												CurrentRes.EntityMods.CompositeType = "NERA"
												CurrentRes.EntityMods.CompKEMult = 9.2
												CurrentRes.EntityMods.CompCEMult = 18.4
												CurrentRes.EntityMods.DakName = "NERA"
												self.Modern = 1
											end
										end
									end
									if CurrentRes.EntityMods==nil then
									else
										if CurrentRes.EntityMods.CompositeType == nil or CurrentRes.IsComposite == nil then
											
											if CurrentRes.EntityMods.ArmorType == nil then
												self.RHAWeight = self.RHAWeight + CurrentRes:GetPhysicsObject():GetMass()
											else
												if CurrentRes.EntityMods.ArmorType == "RHA" then
													CurrentRes.EntityMods.Density = 7.8125
													CurrentRes.EntityMods.ArmorMult = 1
													CurrentRes.EntityMods.Ductility = 1
													self.RHAWeight = self.RHAWeight + CurrentRes:GetPhysicsObject():GetMass()
												end
												if CurrentRes.EntityMods.ArmorType == "CHA" then
													CurrentRes.EntityMods.Density = 7.8125
													CurrentRes.EntityMods.ArmorMult = 1
													CurrentRes.EntityMods.Ductility = 1.5
													self.CHAWeight = self.CHAWeight + CurrentRes:GetPhysicsObject():GetMass()
												end
												if CurrentRes.EntityMods.ArmorType == "HHA" then
													CurrentRes.EntityMods.Density = 7.8125
													CurrentRes.EntityMods.ArmorMult = 1
													CurrentRes.EntityMods.Ductility = 1.5
													self.HHAWeight = self.HHAWeight + CurrentRes:GetPhysicsObject():GetMass()
												end
											end
										else
											if CurrentRes.EntityMods.CompositeType == "NERA" then
												self.Modern = 1
												self.NERAWeight = self.NERAWeight + CurrentRes:GetPhysicsObject():GetMass()
											end
											if CurrentRes.EntityMods.CompositeType == "Textolite" then
												self.ColdWar = 1
												self.TextoliteWeight = self.TextoliteWeight + CurrentRes:GetPhysicsObject():GetMass()
											end
											if CurrentRes.EntityMods.CompositeType == "ERA" then
												self.ColdWar = 1
												self.ERAWeight = self.ERAWeight + CurrentRes:GetPhysicsObject():GetMass()
												self.ERA[#self.ERA+1]=CurrentRes
											end
										end
									end
								end
								Mass = Mass + CurrentRes:GetPhysicsObject():GetMass()
								if IsValid(CurrentRes:GetParent()) then
									ParentMass = ParentMass + CurrentRes:GetPhysicsObject():GetMass()
								end
								if CurrentRes:GetPhysicsObject():GetSurfaceArea() then
									if CurrentRes:GetPhysicsObject():GetMass()>1 then
										SA = SA + CurrentRes:GetPhysicsObject():GetSurfaceArea()
									end
								else
									self.Tread[#self.Tread+1]=CurrentRes
								end
								---TEST
								if CurrentRes:GetClass()=="prop_physics" then
									--CurrentRes:AddEFlags( EFL_SERVER_ONLY )
									--CurrentRes:AddEFlags( EFL_DORMANT )
								end

								---END TEST
							end
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
								local ContraptionCurrent
								for i=1, #self.Contraption do
									ContraptionCurrent = self.Contraption[i]
									if ContraptionCurrent.Controller == nil or ContraptionCurrent.Controller == NULL or ContraptionCurrent.Controller == self then
										if IsValid(ContraptionCurrent) then
											
											if ContraptionCurrent.DakName == nil and (ContraptionCurrent.EntityMods and ContraptionCurrent.EntityMods.IsERA~=1) then
												if ContraptionCurrent:IsSolid() then
													self.HitBox[#self.HitBox+1] = ContraptionCurrent
													ContraptionCurrent.Controller = self
													ContraptionCurrent.DakOwner = self.DakOwner
													ContraptionCurrent.DakPooled = 1
												end
											else
												if ContraptionCurrent.EntityMods and ContraptionCurrent.EntityMods.IsERA==1 then
													self.ERA[#self.ERA+1] = ContraptionCurrent
													ContraptionCurrent.Controller = self
													ContraptionCurrent.DakOwner = self.DakOwner
													ContraptionCurrent.DakPooled = 1
													ContraptionCurrent.DakHealth = 5
													ContraptionCurrent.DakMaxHealth = 5
												end
											end
											ContraptionCurrent.Controller = self
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
					--####################OPTIMIZE ZONE START###################--
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
									local ExpSounds = {"daktanks/eraexplosion.mp3"}
									local EntMod 
									for i = 1, table.Count(self.ERA) do
										if not(IsValid(self.ERA[i])) then
											table.remove( self.ERA, i )
										end
										if self.ERA[i] ~= nil and self.ERA[i] ~= NULL then
											EntMod = self.ERA[i].EntityMods
											if self.ERA[i].IsComposite ~= 1 then self.ERA[i].IsComposite = 1 end
											if EntMod.CompKEMult ~= 2.5 then EntMod.CompKEMult = 2.5 end
											if EntMod.CompCEMult ~= 88.9 then EntMod.CompCEMult = 88.9 end
											if self.ERA[i].DakName ~= "ERA" then self.ERA[i].DakName = "ERA" end
											if self.ERA[i].IsERA ~= 1 then self.ERA[i].IsERA = 1 end
											if self.ColdWar ~= 1 then self.ColdWar = 1 end
											if self.ERA[i].DakHealth <= 0 then
												effectdata = EffectData()
												effectdata:SetOrigin(self.ERA[i]:GetPos())
												effectdata:SetEntity(self)
												effectdata:SetAttachment(1)
												effectdata:SetMagnitude(.5)
												effectdata:SetScale(50)
												effectdata:SetNormal( Vector(0,0,0) )
												util.Effect("daktescalingexplosionold", effectdata, true, true)
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
									local weightvalcomp
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
											weightvalcomp = math.Round(self.Composites[i]:GetPhysicsObject():GetVolume()/61023.7*Density)
											if self.Composites[i]:GetPhysicsObject():GetMass() ~= weightvalcomp then self.Composites[i]:GetPhysicsObject():SetMass( math.Round(self.Composites[i]:GetPhysicsObject():GetVolume()/61023.7*Density) ) end
											self.Composites[i].DakArmor = math.sqrt(math.sqrt(self.Composites[i]:GetPhysicsObject():GetVolume()))*KE
										end
									end
								end
							end
							if self.ERA then
								if table.Count(self.ERA) > 0 then
									local weightval
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
												weightval = math.Round(self.ERA[i]:GetPhysicsObject():GetVolume()/61023.7*1732) 
												if self.ERA[i]:GetPhysicsObject():GetMass() ~= weightval then self.ERA[i]:GetPhysicsObject():SetMass( weightval ) end
												self.ERA[i].DakArmor = math.sqrt(math.sqrt(self.ERA[i]:GetPhysicsObject():GetVolume()))*2.5
											end
										end
									end
								end
							end

							self.DamageCycle = 0
							self.LastDamagedBy = NULL
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
											self.LastDamagedBy = self.HitBox[i].LastDamagedBy
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
							if self.CurrentHealth >= self.DakMaxHealth then
								self.DakMaxHealth = self.CurMass*0.01*self.SizeMult*25
								self.CurrentHealth = self.CurMass*0.01*self.SizeMult*25
							end
							for i = 1, table.Count(self.HitBox) do
								if self.CurrentHealth >= self.DakMaxHealth then
									self.HitBox[i].DakMaxHealth = self.CurMass*0.01*self.SizeMult*25
								end
								self.HitBox[i].DakHealth = self.CurrentHealth

								if self.HitBox[i]:GetClass()=="prop_physics" then
									--self.HitBox[i]:AddEFlags( EFL_SERVER_ONLY )
									--self.HitBox[i]:AddEFlags( EFL_DORMANT )
									--self.HitBox[i]:AddEFlags( EFL_NO_GAME_PHYSICS_SIMULATION )

									--self.HitBox[i]:RemoveEFlags( EFL_SERVER_ONLY )
									--self.HitBox[i]:RemoveEFlags( EFL_DORMANT )
								end

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
										salvage:SetModelScale(self.Crew[i]:GetModelScale())
										salvage:Spawn()
										self.Crew[i]:Remove()
									end

								end
							end
							self.LastVel = curvel


							WireLib.TriggerOutput(self, "Health", self.DakHealth)
							WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)


					--####################OPTIMIZE ZONE END###################--

							if self.DakHealth then
								if (self.DakHealth <= 0 or #self.Crew <= 0 or (gmod.GetGamemode().Name=="DakTank" and self.LegalUnfreeze ~= true)) and self:GetParent():GetParent():GetPhysicsObject():IsMotionEnabled() then
									local DeathSounds = {"daktanks/closeexp1.mp3","daktanks/closeexp2.mp3","daktanks/closeexp3.mp3"}

									self.RemoveTurretList = {}

									if math.random(1,3) == 1 then
										for j=1, #self.TurretControls do
											if IsValid(self.TurretControls[j]) then
												table.RemoveByValue( self.Contraption, self.TurretControls[j].TurretBase )
												if IsValid(self.TurretControls[j].TurretBase) then
													self.TurretControls[j].TurretBase:SetMaterial("models/props_buildings/plasterwall021a")
													self.TurretControls[j].TurretBase:SetColor(Color(100,100,100,255))
													self.TurretControls[j].TurretBase:SetCollisionGroup( COLLISION_GROUP_WORLD )
													--self.TurretControls[j].TurretBase:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
													sound.Play( DeathSounds[math.random(1,#DeathSounds)], self.TurretControls[j].TurretBase:GetPos(), 100, 100, 0.25 )
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
																--self.TurretControls[j].Turret[l]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
																sound.Play( DeathSounds[math.random(1,#DeathSounds)], self.TurretControls[j].Turret[l]:GetPos(), 100, 100, 0.25 )
																if self.TurretControls[j].Turret[l]:IsVehicle() then
																	if IsValid(self.TurretControls[j].Turret[l]:GetDriver()) then
																		self.TurretControls[j].Turret[l]:GetDriver():TakeDamage( 1000000, self.LastDamagedBy, self )
																		--self.TurretControls[j].Turret[l]:GetDriver():Kill()
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
														if self.Contraption[i]:GetClass() == "dak_tegearbox" or self.Contraption[i]:GetClass() == "dak_tegearboxnew" or self.Contraption[i]:GetClass() == "dak_turretcontrol" or self.Contraption[i]:GetClass() == "gmod_wire_expression2" then
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
															self.salvage:SetModelScale(self.Contraption[i]:GetModelScale())
															self.salvage:Spawn()
															self.Contraption[i]:Remove()
														else
															constraint.RemoveAll( self.Contraption[i] )
															self.Contraption[i]:SetParent( self:GetParent(), -1 )
															self.Contraption[i]:SetMoveType( MOVETYPE_NONE )
															self.Contraption[i]:SetMaterial("models/props_buildings/plasterwall021a")
															self.Contraption[i]:SetColor(Color(100,100,100,255))
															self.Contraption[i]:SetCollisionGroup( COLLISION_GROUP_WORLD )
															--self.Contraption[i]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
															sound.Play( DeathSounds[math.random(1,#DeathSounds)], self.Contraption[i]:GetPos(), 100, 100, 0.25 )
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
														self.salvage:SetModelScale(self.Contraption[i]:GetModelScale())
														self.salvage:Spawn()
														self.Contraption[i]:Remove()
													end
													if self.Contraption[i]:IsVehicle() then
														if IsValid(self.Contraption[i]:GetDriver()) then
															self.Contraption[i]:GetDriver():TakeDamage( 1000000, self.LastDamagedBy, self )
															--self.Contraption[i]:GetDriver():Kill()
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
									util.Effect("daktescalingexplosionold", effectdata)
								end
							else
								self:Remove()
							end

						end
					end
				else
					if self.DeathTime then
						if self.DeathTime+30<CurTime() then
							self.AutoRemoved = true
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
	if gmod.GetGamemode().Name=="DakTank" then
		if self.LastDamagedBy:IsValid() and self.AutoRemoved~=true then
			if self.LastDamagedBy:Team() ~= self.DakOwner:Team() then
				local PointsGained
				if Era == "WWII" then
					PointsGained = 5
				elseif Era == "Cold War" then
					PointsGained = 10
				else
					PointsGained = 20
				end
				net.Start( "DT_killnotification" )
					net.WriteInt(2, 32)
					net.WriteInt(PointsGained, 32)
				net.Send( self.LastDamagedBy )
				if not(self.LastDamagedBy:InVehicle()) then self.LastDamagedBy:addPoints( PointsGained ) end
				if self.DakOwner:Team() == 1 then
					SetGlobalFloat("DakTankRedResources", GetGlobalFloat("DakTankRedResources") - 5 )
				elseif self.DakOwner:Team() == 2 then
					SetGlobalFloat("DakTankBlueResources", GetGlobalFloat("DakTankBlueResources") - 5 )
				end
			end
		end
	end
end

