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
			if (v.Type ~= "NoCollide") and (v.Type ~= "Axis") and (v.Type ~= "Ballsocket") and (v.Type ~= "AdvBallsocket") then
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

	self.Inputs = Wire_CreateInputs(self, { "Active", "Gun [ENTITY]", "Turret [ENTITY]", "CamTrace [RANGER]", "Lock" })
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
								Mass = Mass + res[i]:GetPhysicsObject():GetMass()
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
						if IsValid(DakTurret) then
							if not(self.TurInertia) then
								self.TurInertia = Angle(DakTurret:GetPhysicsObject():GetInertia().y,DakTurret:GetPhysicsObject():GetInertia().z,DakTurret:GetPhysicsObject():GetInertia().x)
							end
							if not(self.TurAng) then
								self.TurAng = self:WorldToLocalAngles(DakTurret:GetAngles())
							end
						end
						if self.DakActive > 0 then
							if self.Inputs.Lock.Value > 0 then
								if IsValid(self.DakCore.Base) then
									if not(constraint.FindConstraint( self.DakGun, "Weld" )) then
										constraint.Weld( self.DakGun, self.DakCore.Base, 0, 0, 0, false, false )
									end
								end
							else
								if constraint.FindConstraint( self.DakGun, "Weld" ) then
					        		constraint.RemoveConstraints( self.DakGun, "Weld" )
					        	end
								if self.DakCamTrace then
									local trace = {}
										trace.start = self.DakCamTrace.StartPos
										trace.endpos = self.DakCamTrace.StartPos + self.DakCamTrace.Normal*9999999999
										trace.filter = self.DakContraption
									local CamTrace = util.TraceLine( trace )
							    	GunDir = normalizedVector(CamTrace.HitPos - CamTrace.StartPos+Vector(0,0,CamTrace.StartPos.z-self.DakGun:GetPos().z))
							    	self.GunAng = angnorm(angClamp(self.GunAng - angNumClamp(heading(Vector(0,0,0), self.GunAng, self:toLocalAxis(GunDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
								    local Ang = -heading(Vector(0,0,0), self.DakGun:GetAngles(), self:LocalToWorldAngles(self.GunAng):Forward())
								    Ang = Angle(Ang.pitch*2500,Ang.yaw*2500,Ang.roll*2500)
								    local AngVel = self.DakGun:GetPhysicsObject():GetAngleVelocity()
								    local AngVelAng = Angle( AngVel.y*30, AngVel.z*30, AngVel.x*30 )
								    Ang = Angle((Ang.pitch - AngVelAng.pitch),(Ang.yaw - AngVelAng.yaw),(Ang.roll - AngVelAng.roll))
								    Ang = Angle((Ang.pitch*self.Inertia.pitch),(Ang.yaw*self.Inertia.yaw),(Ang.roll*self.Inertia.roll))
									if IsValid(DakTurret) then
										TurDir = normalizedVector(CamTrace.HitPos - CamTrace.StartPos+Vector(0,0,CamTrace.StartPos.z-DakTurret:GetPos().z))
								    	self.TurAng = angnorm(angClamp(self.TurAng - angNumClamp(heading(Vector(0,0,0), self.TurAng, self:toLocalAxis(TurDir)), -self.RotationSpeed, self.RotationSpeed), Angle(-Elevation, -YawMin, -1), Angle(Depression, YawMax, 1)))
									    local TurAng = -heading(Vector(0,0,0), DakTurret:GetAngles(), self:LocalToWorldAngles(self.TurAng+Angle(0,self.YawDiff,0)):Forward())
									    TurAng = Angle(TurAng.pitch*250,TurAng.yaw*250,TurAng.roll*250)
									    local TurAngVel = DakTurret:GetPhysicsObject():GetAngleVelocity()
									    local TurAngVelAng = Angle( TurAngVel.y*30, TurAngVel.z*30, TurAngVel.x*30 )
									    TurAng = Angle((TurAng.pitch - TurAngVelAng.pitch),(TurAng.yaw - TurAngVelAng.yaw),(TurAng.roll - TurAngVelAng.roll))
									    TurAng = Angle((TurAng.pitch*self.TurInertia.pitch),(TurAng.yaw*self.TurInertia.yaw),(TurAng.roll*self.TurInertia.roll))
										self:ApplyForce(DakTurret, Angle(TurAng.pitch,0,0))
										self:ApplyForce(self.DakGun, Angle(Ang.pitch,0,0))
									else
										self:ApplyForce(self.DakGun, Ang)
									end
								end
							end
						else
							if constraint.FindConstraint( self.DakGun, "Weld" ) then
				        		constraint.RemoveConstraints( self.DakGun, "Weld" )
				        	end
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