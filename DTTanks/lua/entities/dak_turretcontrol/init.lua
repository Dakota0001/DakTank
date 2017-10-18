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

	local forcemult = math.Clamp( ( phys:GetMass()/2.5 ),0,100) / (phys:GetMass()*(250/phys:GetMass()) )
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
 	self.RotMult = 1.2
 	self.SentError = 0
 	self.SentError2 = 0
 	self.LastHullAngles = self:GetAngles()
end

function ENT:Think()
	if self.DakTurretMotor == nil then
		self.RotMult = 0.08
	else
		self.RotMult = 0.16
	end

	if #self.DakContraption > 0 then
		if IsValid(self.Inputs.Gun.Value) then
			

			self.Elevation = self:GetElevation()
			self.Depression = self:GetDepression()
			self.YawMin = self:GetYawMin()
			self.YawMax = self:GetYawMax()

			self.DakActive = self.Inputs.Active.Value
			if IsValid(self.Inputs.Gun.Value:GetParent()) then
				if IsValid(self.Inputs.Gun.Value:GetParent():GetParent()) then
					self.DakGun = self.Inputs.Gun.Value:GetParent():GetParent()
					self.GunMass = 0
					for i=1, #self.DakCore.Guns do
						if IsValid(self.DakCore.Guns[i]) then
							if IsValid(self.DakCore.Guns[i]:GetParent()) then
								if IsValid(self.DakCore.Guns[i]:GetParent():GetParent()) then
									if self.DakCore.Guns[i]:GetParent():GetParent() == self.Inputs.Gun.Value:GetParent():GetParent() then
										self.GunMass = self.GunMass + self.DakCore.Guns[i]:GetPhysicsObject():GetMass()
									end
								end
							end
						end
					end
					self.RotationSpeed = self.RotMult * (3000/self.GunMass)
				end
				self.DakParented = 1
			else
				self.DakParented = 0
			end
			
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
			local Class = self.Inputs.Gun.Value:GetClass()
			if not(Class == "dak_tegun" or Class == "dak_teautogun" or Class == "dak_temachinegun") then
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
			self.DakTurret = self.Inputs.Turret.Value
			self.DakCamTrace = self.Inputs.CamTrace.Value
			if (Class == "dak_tegun" or Class == "dak_teautogun" or Class == "dak_temachinegun") then
				
				if self.Inertia == nil then
					self.Inertia = Angle(self.DakGun:GetPhysicsObject():GetInertia().y,self.DakGun:GetPhysicsObject():GetInertia().z,self.DakGun:GetPhysicsObject():GetInertia().x)
				end
				if self.GunAng == nil then
					self.GunAng = self:WorldToLocalAngles(self.DakGun:GetAngles())
				end

				if self.DakActive > 0 then
					if not(self.DakCamTrace == nil) then
					    self.GunDir = normalizedVector(self.DakCamTrace.HitPos - self.DakGun:GetPos())
					    self.GunAng = angnorm(angClamp(self.GunAng - angNumClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(self.GunDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-self.Elevation, -self.YawMin, -1), Angle(self.Depression, self.YawMax, 1)))
					    self.Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(self.GunAng):Forward())
					    self.Ang = Angle(self.Ang.pitch*4500,self.Ang.yaw*4500,self.Ang.roll*4500)
					    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
					    local AngVelAng = Angle( AngVel.y*100, AngVel.z*100, AngVel.x*100 )
					    self.Ang = Angle((self.Ang.pitch - AngVelAng.pitch),(self.Ang.yaw - AngVelAng.yaw),(self.Ang.roll - AngVelAng.roll))
					    self.Ang = Angle((self.Ang.pitch*self.Inertia.pitch),(self.Ang.yaw*self.Inertia.yaw),(self.Ang.roll*self.Inertia.roll))
					    self:ApplyForce(self.DakGun, self.Ang)
						if IsValid(self.DakTurret) then
							self:ApplyForce(self.DakTurret, Angle(0,self.Ang.yaw,0))
						end
					end
				else
					self.GunDir = self:GetForward()
				    self.GunAng = angnorm(angClamp(self.GunAng - angNumClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(self.GunDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-self.Elevation, -self.YawMin, -1), Angle(self.Depression, self.YawMax, 1)))
				    self.Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(self.GunAng):Forward())
				    self.Ang = Angle(self.Ang.pitch*4500,self.Ang.yaw*4500,self.Ang.roll*4500)
				    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
				    local AngVelAng = Angle( AngVel.y*100, AngVel.z*100, AngVel.x*100 )
				    self.Ang = Angle((self.Ang.pitch - AngVelAng.pitch),(self.Ang.yaw - AngVelAng.yaw),(self.Ang.roll - AngVelAng.roll))
				    self.Ang = Angle((self.Ang.pitch*self.Inertia.pitch),(self.Ang.yaw*self.Inertia.yaw),(self.Ang.roll*self.Inertia.roll))
				    self:ApplyForce(self.DakGun, self.Ang)
					if IsValid(self.DakTurret) then
						self:ApplyForce(self.DakTurret, Angle(0,self.Ang.yaw,0))
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

	if IsValid(self.DakTurretMotor) then
		info.TurretMotorID = self.DakTurretMotor:EntIndex()
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

		local TurretMotor = CreatedEntities[ Ent.EntityMods.DakTek.TurretMotorID ]
		if TurretMotor and IsValid(TurretMotor) then
			self.DakTurretMotor = TurretMotor
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