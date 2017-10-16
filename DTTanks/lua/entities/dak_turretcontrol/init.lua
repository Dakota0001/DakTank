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

	self.Inputs = Wire_CreateInputs(self, { "Active", "Gun [ENTITY]", "Turret [ENTITY]", "CamHitPos [VECTOR]", "CamAngle [ANGLE]" })
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
		self.RotMult = 2
	else
		self.RotMult = 4
	end

	if #self.DakContraption > 0 then
		if IsValid(self.Inputs.Gun.Value) then
			self.RotationSpeed = self.RotMult * (3000/self.Inputs.Gun.Value:GetPhysicsObject():GetMass())

			self.Elevation = self:GetElevation()
			self.Depression = self:GetDepression()
			self.YawMin = self:GetYawMin()
			self.YawMax = self:GetYawMax()

			self.DakActive = self.Inputs.Active.Value
			if IsValid(self.Inputs.Gun.Value:GetParent()) then
				if IsValid(self.Inputs.Gun.Value:GetParent():GetParent()) then
					self.DakGun = self.Inputs.Gun.Value:GetParent():GetParent()
				end
			else
				self.DakGun = self.Inputs.Gun.Value
			end
			if self.DakGun:GetPhysicsObject():GetMass()>1000 then
				if self.SentError == 0 then
					self.SentError = 1
					self.DakOwner:PrintMessage( HUD_PRINTTALK, "Turret Controller Error: Gun is too heavy, please parent it or lower the aimer weight." )
					self.ErrorTime=CurTime()
				else
					if CurTime()>=self.ErrorTime+10 then
						self.DakOwner:PrintMessage( HUD_PRINTTALK, "Turret Controller Error: Gun is too heavy, please parent it or lower the aimer weight." )
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
			self.DakCamHitPos = self.Inputs.CamHitPos.Value
			self.DakCamAngle = self.Inputs.CamAngle.Value
			if (self.DakGun:GetPhysicsObject():GetMass()<=1000) and (Class == "dak_tegun" or Class == "dak_teautogun" or Class == "dak_temachinegun") then
				if self.DakActive > 0 then
					local trace = {}
					trace.start = self.DakCamHitPos
					trace.endpos = self.DakCamHitPos + (self.DakCamAngle:Forward() * 9999999)
					trace.filter = self.DakContraption
					local Hit = util.TraceLine( trace )
					self.GunAng = (Hit.HitPos-self.DakGun:GetPos()):Angle()
					self.RotAngle = Angle(math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).pitch,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).yaw,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).roll,-self.RotationSpeed,self.RotationSpeed))
					self.RotAngle = self.RotAngle - self:WorldToLocalAngles(self.LastHullAngles)*13.5
					self.ClampAngle = Angle(math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).pitch,-self.Elevation,self.Depression),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).yaw,-self.YawMin,self.YawMax),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).roll,-1,1))
					self.PreAngle = ((self.DakGun:WorldToLocalAngles(self:LocalToWorldAngles(self.ClampAngle)) * 250) - (Angle(self.DakGun:GetPhysicsObject():GetAngleVelocity().y,self.DakGun:GetPhysicsObject():GetAngleVelocity().z,self.DakGun:GetPhysicsObject():GetAngleVelocity().x) * 50))
					self.PostAngle = Angle(self.PreAngle.pitch * self.DakGun:GetPhysicsObject():GetInertia().y,self.PreAngle.yaw * self.DakGun:GetPhysicsObject():GetInertia().z,self.PreAngle.roll)
					self:ApplyForce(self.DakGun, self.PostAngle)
					if IsValid(self.DakTurret) then
						self:ApplyForce(self.DakTurret, Angle(0,self.PostAngle.yaw,0))
					end
					self.LastHullAngles = self:GetAngles()
				else
					self.GunAng = self:GetAngles()
					self.RotAngle = Angle(math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).pitch,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).yaw,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).roll,-self.RotationSpeed,self.RotationSpeed))
					self.RotAngle = self.RotAngle - self:WorldToLocalAngles(self.LastHullAngles)*13.5
					self.ClampAngle = Angle(math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).pitch,-self.Elevation,self.Depression),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).yaw,-self.YawMin,self.YawMax),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).roll,-1,1))
					self.PreAngle = ((self.DakGun:WorldToLocalAngles(self:LocalToWorldAngles(self.ClampAngle)) * 250) - (Angle(self.DakGun:GetPhysicsObject():GetAngleVelocity().y,self.DakGun:GetPhysicsObject():GetAngleVelocity().z,self.DakGun:GetPhysicsObject():GetAngleVelocity().x) * 50))
					self.PostAngle = Angle(self.PreAngle.pitch * self.DakGun:GetPhysicsObject():GetInertia().y,self.PreAngle.yaw * self.DakGun:GetPhysicsObject():GetInertia().z,self.PreAngle.roll)
					self:ApplyForce(self.DakGun, self.PostAngle+(self:GetAngles()-self.LastHullAngles))
					if IsValid(self.DakTurret) then
						self:ApplyForce(self.DakTurret, Angle(0,self.PostAngle.yaw,0))
					end
					self.LastHullAngles = self:GetAngles()
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