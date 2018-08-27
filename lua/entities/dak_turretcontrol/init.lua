AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakName = "Turret Control"
ENT.DakContraption = {}
ENT.DakTurretMotor = nil
ENT.SentError = 0
ENT.SentError2 = 0
ENT.DakCore = NULL
ENT.DakTurretMotors = {}

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
	local phys = self:GetPhysicsObject()
	self.timer = CurTime()

	if(IsValid(phys)) then
		phys:Wake()
	end

	self.Inputs = Wire_CreateInputs(self, { "Active", "Gun [ENTITY]", "Turret [ENTITY]", "CamTrace [RANGER]" })
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
			

			local Elevation = self:GetElevation()
			local Depression = self:GetDepression()
			local YawMin = self:GetYawMin()
			local YawMax = self:GetYawMax()

			self.DakActive = self.Inputs.Active.Value
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
						local GunMass = 0
						local GunList = self.DakCore.Guns
						for i=1, #GunList do
							if IsValid(GunList[i]) then
								if IsValid(GunList[i]:GetParent()) then
									if IsValid(GunList[i]:GetParent():GetParent()) then
										if GunList[i]:GetParent():GetParent() == GunEnt:GetParent():GetParent() then
											GunMass = GunMass + GunList[i]:GetPhysicsObject():GetMass()
										end
									end
								end
							end
						end
						if IsValid(DakTurret) then
							GunMass = GunMass + GunEnt:GetPhysicsObject():GetMass()
							GunMass = GunMass + DakTurret:GetPhysicsObject():GetMass()
							local TurretEnts = DakTurret:GetChildren()
							local TurretEnts2 = nil
							for k, v in pairs(TurretEnts) do
								if IsValid(v) then
									if IsValid(v:GetPhysicsObject()) then
										GunMass = GunMass + v:GetPhysicsObject():GetMass()
										TurretEnts2 = v:GetChildren()
										for l, b in pairs(TurretEnts2) do
											if IsValid(b) then
												if IsValid(b:GetPhysicsObject()) then
													GunMass = GunMass + b:GetPhysicsObject():GetMass()
												end
											end
										end
									end
								end
							end
						end
						
					self.GunMass = GunMass
					end
					self.DakParented = 1
				else
					self.DakParented = 0
				end
			end
			if IsValid(self.DakGun) then
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
				self.RotationSpeed = RotMult * (15000/self.GunMass)
				self.DakCamTrace = self.Inputs.CamTrace.Value
				if (Class == "dak_tegun" or Class == "dak_teautogun" or Class == "dak_temachinegun") then
					
					if not(self.Inertia) then
						self.Inertia = Angle(self.DakGun:GetPhysicsObject():GetInertia().y,self.DakGun:GetPhysicsObject():GetInertia().z,self.DakGun:GetPhysicsObject():GetInertia().x)
					end
					if not(self.GunAng) then
						self.GunAng = self:WorldToLocalAngles(self.DakGun:GetAngles())
					end

					if self.DakActive > 0 then
						if self.DakCamTrace then
						    local GunDir = normalizedVector(self.DakCamTrace.HitPos - self.DakGun:GetPos())
						    self.GunAng = angnorm(angClamp(self.GunAng - angNumClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(GunDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
						    local Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(self.GunAng):Forward())
						    Ang = Angle(Ang.pitch*2500,Ang.yaw*2500,Ang.roll*2500)
						    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
						    local AngVelAng = Angle( AngVel.y*30, AngVel.z*30, AngVel.x*30 )
						    Ang = Angle((Ang.pitch - AngVelAng.pitch),(Ang.yaw - AngVelAng.yaw),(Ang.roll - AngVelAng.roll))
						    Ang = Angle((Ang.pitch*self.Inertia.pitch),(Ang.yaw*self.Inertia.yaw),(Ang.roll*self.Inertia.roll))
						    self:ApplyForce(self.DakGun, Ang)
							if IsValid(DakTurret) then
								self:ApplyForce(DakTurret, Angle(0,Ang.yaw,0))
							end
						end
					else
						local GunDir = self:GetForward()
					    self.GunAng = angnorm(angClamp(self.GunAng - angNumClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(GunDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
					    local Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(self.GunAng):Forward())
					    Ang = Angle(Ang.pitch*2500,Ang.yaw*2500,Ang.roll*2500)
					    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
					    local AngVelAng = Angle( AngVel.y*30, AngVel.z*30, AngVel.x*30 )
					    Ang = Angle((Ang.pitch - AngVelAng.pitch),(Ang.yaw - AngVelAng.yaw),(Ang.roll - AngVelAng.roll))
					    Ang = Angle((Ang.pitch*self.Inertia.pitch),(Ang.yaw*self.Inertia.yaw),(Ang.roll*self.Inertia.roll))
					    self:ApplyForce(self.DakGun, Ang)
						if IsValid(DakTurret) then
							self:ApplyForce(DakTurret, Angle(0,Ang.yaw,0))
						end
					end
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