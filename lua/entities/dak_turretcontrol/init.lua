AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakArmor = 0
ENT.DakName = "Turret Control"
ENT.DakContraption = {}
ENT.DakTurretMotor = nil
ENT.SentError = 0
ENT.SentError2 = 0
ENT.DakCore = NULL
ENT.DakTurretMotors = {}

local function GetTurretParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetTurretParents(Parent, Results)
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

local function GetTurretPhysCons( ent, Results )
	local Results = Results or {}
	if not IsValid( ent ) then return end
		if Results[ ent ] then return end
		Results[ ent ] = ent
		local Constraints = constraint.GetTable( ent )
		for k, v in ipairs( Constraints ) do
			if (v.Type ~= "NoCollide") and (v.Type ~= "Axis") and (v.Type ~= "Ballsocket") and (v.Type ~= "AdvBallsocket") and (v.Type ~= "Rope") and (v.Type ~= "Wire") then
				for i, Ent in pairs( v.Entity ) do
					GetTurretPhysCons( Ent.Entity, Results )
				end
			end
		end
	return Results
end


function ENT:toLocalAxis(worldAxis)
	if not IsValid(self) then return Vector(0,0,0) end
	return self:WorldToLocal(Vector(worldAxis[1],worldAxis[2],worldAxis[3])+self:GetPos())
end

function normalizedVector(vector)
	local len = (vector[1] * vector[1] + vector[2] * vector[2] + vector[3] * vector[3]) ^ 0.5
	if len > 0.0000001000000 then
		return Vector( vector[1] / len, vector[2] / len, vector[3] / len )
	else
		return Vector( 0, 0, 0 )
	end
end

local function angnorm(rv1)
	return Angle((rv1[1] + 180) % 360 - 180,(rv1[2] + 180) % 360 - 180,(rv1[3] + 180) % 360 - 180)
end

local function angClamp(ang,clamp1,clamp2)
	return Angle(math.Clamp(ang.pitch,clamp1.pitch,clamp2.pitch),math.Clamp(ang.yaw,clamp1.yaw,clamp2.yaw),math.Clamp(ang.roll,clamp1.roll,clamp2.roll))
end

local function angNumClamp(ang,clamp1,clamp2)
	return Angle(math.Clamp(ang.pitch,clamp1,clamp2),math.Clamp(ang.yaw,clamp1,clamp2),math.Clamp(ang.roll,clamp1,clamp2))
end

local function angNumRotationSpeedClamp(ang,clamp1,clamp2,elevationmult)
	return Angle(math.Clamp(ang.pitch,clamp1*elevationmult,clamp2*elevationmult),math.Clamp(ang.yaw,clamp1,clamp2),math.Clamp(ang.roll,clamp1,clamp2))
end

local function heading(originpos,originangle,pos)
	pos = WorldToLocal(Vector(pos[1],pos[2],pos[3]),Angle(0,0,0),Vector(originpos[1],originpos[2],originpos[3]),Angle(originangle[1],originangle[2],originangle[3]))

	local bearing = (180 / math.pi)*-math.atan2(pos.y, pos.x)

	local len = pos:Length()
	if (len < 0.0000001000000) then return Angle( 0, bearing, 0 ) end
	return Angle( (180 / math.pi)*math.asin(pos.z / len), bearing, 0 )
end

function ENT:ApplyForce(entity, angle)
	local phys = entity:GetPhysicsObject()

	local up = entity:GetUp()
	local left = entity:GetRight() * -1
	local forward = entity:GetForward()
	
	local forcemult = 1
	if angle.pitch ~= 0 then
		local pitch = up      * (angle.pitch * 0.5)
		phys:ApplyForceOffset( forward*forcemult, pitch )
		phys:ApplyForceOffset( forward * -1*forcemult, pitch * -1 )
	end
	if angle.yaw ~= 0 then
		local yaw   = forward * (angle.yaw * 0.5)
		phys:ApplyForceOffset( left*forcemult, yaw )
		phys:ApplyForceOffset( left * -1*forcemult, yaw * -1 )
	end
	if angle.roll ~= 0 then
		local roll  = left    * (angle.roll * 0.5)
		phys:ApplyForceOffset( up*forcemult, roll )
		phys:ApplyForceOffset( up * -1*forcemult, roll * -1 )
	end
end


function ENT:Initialize()
	self:SetModel( "models/beer/wiremod/gate_e2_mini.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakArmor = 10
	--local phys = self:GetPhysicsObject()
	self.timer = CurTime()

	

	self.Inputs = Wire_CreateInputs(self, { "Active", "Gun [ENTITY]", "Turret [ENTITY]", "CamTrace [RANGER]", "Lock", "CamTrace2 [RANGER]", "Active2" })
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.ErrorTime = CurTime()
 	self.ErrorTime2 = CurTime()
 	self.SlowThinkTime = CurTime()
 	RotMult = 1.2
 	self.SentError = 0
 	self.SentError2 = 0
 	self.LastHullAngles = self:GetAngles()
 	self.DakBurnStacks = 0
 	self.DakTurretMotors = {}
 	self.Locked = 0
 	self.Off = true
 	self.OffTicks = 0
 	self.Accel = 0

 	self.ShortStop = self:GetShortStopStabilizer()
	self.Stabilizer = self:GetStabilizer()
	self.FCS = self:GetFCS()
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

function ENT:Think()
	local RotMult = 0.1
	
	if #self.DakContraption > 0 then
		local GunEnt = self.Inputs.Gun.Value

		if IsValid(GunEnt) then
			GunEnt.TurretController = self
			if IsValid(GunEnt:GetParent()) then
				if IsValid(GunEnt:GetParent():GetParent()) then
					self.DakGun = GunEnt:GetParent():GetParent()
				end
			end
			if IsValid(self.DakGun) then
				local Elevation = self:GetElevation()
				local Depression = self:GetDepression()
				local YawMin = self:GetYawMin()
				local YawMax = self:GetYawMax()
				local RotationMult = self:GetRotationSpeedMultiplier()
				if self.FCS ~= true then
					if self:GetTable().Inputs.CamTrace.Path and self:GetTable().Inputs.CamTrace.Path[1].Entity:GetClass()~="gmod_wire_cameracontroller" then self.FCS = true end
					if self:GetTable().Inputs.CamTrace2.Path and self:GetTable().Inputs.CamTrace2.Path[1].Entity:GetClass()~="gmod_wire_cameracontroller" then self.FCS = true end
					if self.FCS == true then
						self.DakOwner:ChatPrint("Custom FCS E2 detected, gun handling multiplier affected.")
					end
					self.CustomFCS = true
				end
				self.DakActive = self.Inputs.Active.Value
				self.DakActive2 = self.Inputs.Active2.Value
				local DakTurret = self.Inputs.Turret.Value
				if #self.DakTurretMotors > 0 then
					for i = 1, #self.DakTurretMotors do
						if IsValid(self.DakTurretMotors[i]) then
							RotMult = RotMult + self.DakTurretMotors[i].DakRotMult
						end
					end
				end
				if not(self.DakParented==1) then
					if IsValid(GunEnt:GetParent()) then
						if IsValid(GunEnt:GetParent():GetParent()) then
							self.DakGun = GunEnt:GetParent():GetParent()
						end
						self.Turret = {}
						table.Add(self.Turret,GetTurretParents(GunEnt))
						for k, v in pairs(GetTurretParents(GunEnt)) do
							table.Add(self.Turret,GetTurretPhysCons(v))
						end
						if IsValid(DakTurret) then
							table.Add(self.Turret,GetTurretParents(DakTurret))
							for k, v in pairs(GetTurretParents(DakTurret)) do
								table.Add(self.Turret,GetTurretPhysCons(v))
							end
						end
						for i=1, #self.Turret do
							table.Add( self.Turret, self.Turret[i]:GetChildren() )
							table.Add( self.Turret, self.Turret[i]:GetParent() )
						end
						local Children = {}
						for i2=1, #self.Turret do
							if table.Count(self.Turret[i2]:GetChildren()) > 0 then
							table.Add( Children, self.Turret[i2]:GetChildren() )
							end
						end
						table.Add( self.Turret, Children )
						local hash = {}
						local res = {}
						for _,v in ipairs(self.Turret) do
					   		if (not hash[v]) then
					    		res[#res+1] = v
					       		hash[v] = true
					   		end
						end
						self.Turret = res
						self.TurretBase = DakTurret
						local Mass = 0

						for i=1, #res do
							if res[i]:IsSolid() then
								if res[i]:GetClass() == "dak_tegun" or res[i]:GetClass() == "dak_teautogun" or res[i]:GetClass() == "dak_temachinegun" then
									Mass = Mass + res[i].DakMass
								else
									Mass = Mass + res[i]:GetPhysicsObject():GetMass()
								end
							end
							if res[i]:IsValid() then
								if res[i]:GetClass() == "dak_tegun" or res[i]:GetClass() == "dak_teautogun" or res[i]:GetClass() == "dak_temachinegun" then
									res[i].TurretController = self
									res[i].TurretBase = DakTurret
								end
							end
						end
						self.GunMass = Mass
						self.DakParented = 1
						if IsValid(DakTurret) then
							self.YawDiff = DakTurret:GetAngles().yaw-self.DakGun:GetAngles().yaw
						end
					else
						self.DakParented = 0
					end
				end
				if IsValid(self.DakGun) then
					local BasePlate = self.Controller:GetParent():GetParent()
					if self.LastVel == nil then self.LastVel = 0 end
					if self.DakParented == 0 then
						if self.SentError == 0 then
							self.SentError = 1
							self.DakOwner:PrintMessage( HUD_PRINTTALK, "Turret Controller Error: Gun must be parented to an aimer prop." )
							self.ErrorTime=CurTime()
						else
							if CurTime()>=self.ErrorTime+10 then
								self.DakOwner:PrintMessage( HUD_PRINTTALK, "Turret Controller Error: Gun must be parented to an aimer prop." )
								self.ErrorTime=CurTime()
							end
						end
					end
					local Class = GunEnt:GetClass()
					if Class ~= "dak_tegun" and Class ~= "dak_teautogun" and Class ~= "dak_temachinegun" then
						if self.SentError2 == 0 then
							self.SentError2 = 1
							self.DakOwner:PrintMessage( HUD_PRINTTALK, "Turret Controller Error: You must wire the gun input to the gun entity, not an aimer prop." )
							self.ErrorTime2=CurTime()
						else
							if CurTime()>=self.ErrorTime2+10 then
								self.DakOwner:PrintMessage( HUD_PRINTTALK, "Turret Controller Error: You must wire the gun input to the gun entity, not an aimer prop." )
								self.ErrorTime2=CurTime()
							end
						end
					end
					self.RotationSpeed = RotMult * (15000/self.GunMass) * (66/(1/engine.TickInterval())) * RotationMult
					if self.DakActive > 0 then
						self.DakCamTrace = self.Inputs.CamTrace.Value
					end
					if self.DakActive2 > 0 then
						self.DakCamTrace = self.Inputs.CamTrace2.Value
					end
					if (Class == "dak_tegun" or Class == "dak_teautogun" or Class == "dak_temachinegun") then
						if not(self.Inertia) then
							self.Inertia = Angle(self.DakGun:GetPhysicsObject():GetInertia().y,self.DakGun:GetPhysicsObject():GetInertia().z,self.DakGun:GetPhysicsObject():GetInertia().x)
						end
						if not(self.GunAng) then
							self.GunAng = self:WorldToLocalAngles(self.DakGun:GetAngles())
						end
						if IsValid(DakTurret) then
							if not(self.TurInertia) then
								self.TurInertia = Angle(DakTurret:GetPhysicsObject():GetInertia().y,DakTurret:GetPhysicsObject():GetInertia().z,DakTurret:GetPhysicsObject():GetInertia().x)
							end
							if not(self.TurAng) then
								self.TurAng = self:WorldToLocalAngles(DakTurret:GetAngles())-Angle(0,self.YawDiff,0)
							end
						end
						
						if self.DakActive > 0 or self.DakActive2 > 0 then
							if self.Inputs.Lock.Value > 0 then
								self.LastAngles = self:GetAngles()
								if self.LastPos == nil then self.LastPos = BasePlate:GetPos() end
								if IsValid(self.DakCore.Base) then
									if self.Locked == 0 then
										constraint.Weld( self.DakGun, self.DakCore.Base, 0, 0, 0, false, false )
										if IsValid(DakTurret) then
											constraint.Weld( DakTurret, self.DakCore.Base, 0, 0, 0, false, false )
										end
										self.Locked = 1
									end
								end
							else
								if self.Locked == 1 then
									if IsValid(DakTurret) then
										constraint.RemoveConstraints( DakTurret, "Weld" )
									end
					        		constraint.RemoveConstraints( self.DakGun, "Weld" )
					        		self.Locked = 0
					        	end

								if self.DakCamTrace then
										if self.FCS==true and not(self.CustomFCS==true) then
											local traceFCS = {}
												traceFCS.start = self.DakCamTrace.StartPos
												traceFCS.endpos = self.DakCamTrace.StartPos + self.DakCamTrace.Normal*9999999999
												traceFCS.filter = self.DakContraption
											local PreCamTrace = util.TraceLine( traceFCS )

											if self.NoTarTicks == nil then self.NoTarTicks = 0 end

											local G = math.abs(physenv.GetGravity().z)
											local Caliber = GunEnt.DakMaxHealth
											local ShellType = GunEnt.DakShellAmmoType
											local V = GunEnt.DakShellVelocity * (GunEnt:GetPropellant()*0.01)
											local ShellMass = GunEnt.DakShellMass
											local Drag = (((V*0.0254)*(V*0.0254)) * (math.pi * ((Caliber/2000)*(Caliber/2000))))*0.0245
											if ShellType=="HVAP" then Drag = (((V*0.0254)*(V*0.0254)) * (math.pi * ((Caliber/1000)*(Caliber/1000))))*0.0245 end
											if ShellType=="APFSDS" then Drag = (((V*0.0254)*(V*0.0254)) * (math.pi * ((Caliber/1000)*(Caliber/1000))))*0.085 end
											local VelLoss
											if ShellType == "HEAT" or ShellType == "HVAP" or ShellType == "ATGM" or ShellType == "HEATFS" or ShellType == "APFSDS" then
											    VelLoss = ((Drag/(ShellMass*8/2))*39.37)
											else
											    VelLoss = ((Drag/(ShellMass/2))*39.37)
											end

											if PreCamTrace.Entity and not(PreCamTrace.Entity:IsWorld()) or self.Tar==nil then
												self.Tar = PreCamTrace.Entity
												self.CamTarPos = PreCamTrace.HitPos
											else 
												self.NoTarTicks = self.NoTarTicks + 1 
											end
											if self.NoTarTicks>15 then
												self.Tar = PreCamTrace.Entity
												self.NoTarTicks = 0
											end

											local TarPos0
											local GunPos=GunEnt:GetPos()
											if self.Tar and self.Tar:IsValid() then
												TarPos0 = self.Tar:GetPos() + (self.CamTarPos-self.Tar:GetPos())
											else
												TarPos0 = PreCamTrace.HitPos
											end

											local TarVel = self.Tar:GetVelocity()
											if self.Tar:GetParent() and self.Tar:GetParent():IsValid() then
											    TarVel=self.Tar:GetParent():GetVelocity()
											    if self.Tar:GetParent():GetParent() and self.Tar:GetParent():GetParent():IsValid() then
											        TarVel=self.Tar:GetParent():GetParent():GetVelocity()
											    end
											end
											local SelfVel = self.Controller:GetParent():GetParent():GetVelocity()
											
											local VelValue = V
											local VelLossFull = VelLoss
											local TravelTime=0
											local Diff
											local X
											local Y
											local Disc
											local Ang
											for i=1, 2 do
											    VelValue = V - VelLossFull
											    TarPos = TarPos0 + (TarVel-SelfVel)*TravelTime
											    Diff = (TarPos-GunPos)
											    X = Vector(Diff.x,Diff.y,0):Length()
											    Y = Diff.z
											    Disc = VelValue^4 - G*(G*X*X + 2*Y*VelValue*VelValue)
											    Ang = math.atan(-(VelValue^2 - math.sqrt(Disc))/(G*X))*57.29577951
											    TravelTime = X/(VelValue*math.cos(Ang*0.017453293))
											    VelLossFull = VelLoss * TravelTime 
											end
											local traceFCS2 = {}
												traceFCS2.start = GunPos
												traceFCS2.endpos = GunPos + Angle(Ang,Diff:Angle().yaw,0):Forward()*1000
												traceFCS2.filter = self.DakContraption
											self.CamTrace = util.TraceLine( traceFCS2 )
										else
											local trace = {}
												trace.start = self.DakCamTrace.StartPos
												trace.endpos = self.DakCamTrace.StartPos + self.DakCamTrace.Normal*9999999999
												trace.filter = self.DakContraption
											self.CamTrace = util.TraceLine( trace )
										end
									
									self.Shake = Angle(0,0,0)
									if self.Stabilizer==false then
										local X = math.abs(self.DakGun:OBBMins().x)+math.abs(self.DakGun:OBBMaxs().x)
										local Y = math.abs(self.DakGun:OBBMins().y)+math.abs(self.DakGun:OBBMaxs().y)
										local Z = math.abs(self.DakGun:OBBMins().z)+math.abs(self.DakGun:OBBMaxs().z)

										if self.LastPos == nil then self.LastPos = BasePlate:GetPos() end
										if self.LastAngles == nil then self.LastAngles = Angle(0,0,0) end
										local Speed = Vector(0,0,0):Distance(BasePlate:GetPos()-self.LastPos)									

										if self.ShakeAmpX == nil then self.ShakeAmpX = 0 end
										self.ShakeAmpX = self.ShakeAmpX + math.random(-1,1)
										if self.ShakeAmpX > 5 then self.ShakeAmpX = 5 end
										if self.ShakeAmpX < -5 then self.ShakeAmpX = -5 end
										if self.ShakeAmpX > 0 then self.ShakeAmpX = self.ShakeAmpX - 0.05 end 
										if self.ShakeAmpX < 0 then self.ShakeAmpX = self.ShakeAmpX + 0.05 end 
										
										if self.ShakeAmpY == nil then self.ShakeAmpY = 0 end
										self.ShakeAmpY = self.ShakeAmpY + math.random(-1,1)
										if self.ShakeAmpY > 5 then self.ShakeAmpY = 5 end
										if self.ShakeAmpY < -5 then self.ShakeAmpY = -5 end
										if self.ShakeAmpY > 0 then self.ShakeAmpY = self.ShakeAmpY - 0.05 end 
										if self.ShakeAmpY < 0 then self.ShakeAmpY = self.ShakeAmpY + 0.05 end 

										if self.ShortStop==false then
											Shake = (Angle(1*self.ShakeAmpX,0.1*self.ShakeAmpY,0) * (Speed * 0.025))+Angle(-self.Accel*25,0,0)--+(Angle(((self:GetAngles().pitch - self.LastAngles.pitch))*5,0,0))
										else
											Shake = Angle(1*self.ShakeAmpX,0.1*self.ShakeAmpY,0) * (Speed * 0.0125)
										end
										self.Shake = Shake
										self.LastAngles = self:GetAngles()
									end

							    	GunDir = normalizedVector(self.CamTrace.HitPos - self.CamTrace.StartPos+(self.CamTrace.StartPos-self.DakGun:GetPos()))
							    	self.GunAng = angnorm(angClamp(self.GunAng - angNumRotationSpeedClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(GunDir)), -self.RotationSpeed, self.RotationSpeed, 1), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
								    self.GunAng = self.GunAng
								    local Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(  angClamp(self.GunAng+self.Shake,Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1))  ):Forward())
								    Ang = Angle(Ang.pitch*1250,Ang.yaw*1250,Ang.roll*1250)
								    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
								    local AngVelAng = Angle( AngVel.y*30, AngVel.z*30, AngVel.x*30 )
								    Ang = Angle((Ang.pitch - AngVelAng.pitch),(Ang.yaw - AngVelAng.yaw),(Ang.roll - AngVelAng.roll))
								    Ang = Angle((Ang.pitch*self.Inertia.pitch),(Ang.yaw*self.Inertia.yaw),(Ang.roll*self.Inertia.roll))
									if IsValid(DakTurret) then
										TurDir = normalizedVector(self.CamTrace.HitPos - self.CamTrace.StartPos+(self.CamTrace.StartPos-DakTurret:GetPos()))
								    	self.TurAng = angnorm(angClamp(self.TurAng - angNumClamp(heading(Vector(0,0,0), self.TurAng, self:toLocalAxis(TurDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
									    local TurAng = -heading(Vector(0,0,0), DakTurret:GetAngles()-Angle(0,self.YawDiff,0), self:LocalToWorldAngles(self.TurAng):Forward())
									    TurAng = Angle(TurAng.pitch*250,TurAng.yaw*250,TurAng.roll*250)
									    local TurAngVel = DakTurret:GetPhysicsObject():GetAngleVelocity()
									    local TurAngVelAng = Angle( TurAngVel.y*30, TurAngVel.z*30, TurAngVel.x*30 )
									    TurAng = Angle((TurAng.pitch - TurAngVelAng.pitch),(TurAng.yaw - TurAngVelAng.yaw),(TurAng.roll - TurAngVelAng.roll))
									    TurAng = Angle((TurAng.pitch*self.TurInertia.pitch),(TurAng.yaw*self.TurInertia.yaw),(TurAng.roll*self.TurInertia.roll))
									    --find yaw axis
									    if self.Off == true then
									    	self.OffTicks = self.OffTicks + 1
									    	if self.OffTicks > 70 then
												self.Off = false
												self.GunAng = Angle(0,0,0)
												self.TurAng = Angle(0,0,0)
											end
										else
										   	if (DakTurret:GetAngles()-self.DakGun:GetAngles()).roll > 1 or (DakTurret:GetAngles()-self.DakGun:GetAngles()).roll < -1 then
												self:ApplyForce(DakTurret, Angle(TurAng.pitch,0,0))
											else
												self:ApplyForce(DakTurret, Angle(0,TurAng.yaw,0))
											end
											local CounterAngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
										    local CounterAngVelAng = Angle( CounterAngVel.y*30, CounterAngVel.z*30, CounterAngVel.x*30 )
										    CounterAng = Angle((-CounterAngVelAng.pitch*self.Inertia.pitch),(-CounterAngVelAng.yaw*self.Inertia.yaw),(-CounterAngVelAng.roll*self.Inertia.roll))
											self:ApplyForce(self.DakGun, Angle(Ang.pitch,CounterAng.yaw,CounterAng.roll))
										end
									else
										if self.Off == true then
											self.OffTicks = self.OffTicks + 1
											if self.OffTicks > 70 / (66/(1/engine.TickInterval())) then
												self.Off = false
												self.GunAng = Angle(0,0,0)
											end
										else
											self:ApplyForce(self.DakGun, Ang)
										end
									end
								end
							end
						else
							if self.Locked == 1 then
				        		constraint.RemoveConstraints( self.DakGun, "Weld" )
				        		if IsValid(DakTurret) then
									constraint.RemoveConstraints( DakTurret, "Weld" )
								end
				        		self.Locked = 0
				        	end
							local GunDir = self:GetForward()
						    self.GunAng = angnorm(angClamp(self.GunAng - angNumClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(GunDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
						    local Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(self.GunAng):Forward())
						    Ang = Angle(Ang.pitch*1250,Ang.yaw*1250,Ang.roll*1250)
						    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
						    local AngVelAng = Angle( AngVel.y*30, AngVel.z*30, AngVel.x*30 )
						    Ang = Angle((Ang.pitch - AngVelAng.pitch),(Ang.yaw - AngVelAng.yaw),(Ang.roll - AngVelAng.roll))
						    Ang = Angle((Ang.pitch*self.Inertia.pitch),(Ang.yaw*self.Inertia.yaw),(Ang.roll*self.Inertia.roll))
						    self:ApplyForce(self.DakGun, Ang)
							if IsValid(DakTurret) then
								self:ApplyForce(DakTurret, Angle(0,Ang.yaw,0))
							end
							self.Off = true
							self.OffTicks = 0
							if self.LastPos == nil then self.LastPos = BasePlate:GetPos() end
							self.LastAngles = self:GetAngles()
						end
					end
					if self.SpeedTable == nil then self.SpeedTable = {} end
					if self.LastAccel == nil then self.LastAccel = 0 end

					self.SpeedTable[#self.SpeedTable+1] = (Vector(0,0,0):Distance(BasePlate:GetPos()-self.LastPos)-self.LastVel)
					if #self.SpeedTable >= 5 then
						 table.remove( self.SpeedTable, 1 )
					end
					local totalspeed = 0
					for i=1, #self.SpeedTable do
						totalspeed = totalspeed + self.SpeedTable[i]
					end
					self.Accel = (totalspeed/#self.SpeedTable)
					self.LastVel = Vector(0,0,0):Distance(BasePlate:GetPos()-self.LastPos)
					self.LastPos = BasePlate:GetPos()
				end
			end
		end
	end
	self:NextThink(CurTime())
    return true
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}
	info.TurretMotorIDs = {}

	if #self.DakTurretMotors > 0 then
		for i = 1, #self.DakTurretMotors do
			info.TurretMotorIDs[i] = self.DakTurretMotors[i]:EntIndex()
		end
	end

	info.DakName = self.DakName
	info.DakHealth = self.DakHealth
	info.DakMaxHealth = self.DakBaseMaxHealth
	info.DakMass = self.DakMass
	info.DakOwner = self.DakOwner
	duplicator.StoreEntityModifier( self, "DakTek", info )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		if Ent.EntityMods.DakTek.TurretMotorIDs then
			if #Ent.EntityMods.DakTek.TurretMotorIDs > 0 then
				for i = 1, #Ent.EntityMods.DakTek.TurretMotorIDs do
					self.DakTurretMotors[#self.DakTurretMotors+1] = CreatedEntities[ Ent.EntityMods.DakTek.TurretMotorIDs[i] ] 
				end
			end
		end

		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakOwner = Player
		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end