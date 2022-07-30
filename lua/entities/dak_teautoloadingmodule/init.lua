AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakName = "Autoloader Module"
ENT.DakIsExplosive = true
ENT.DakArmor = 10
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakPooled=0
ENT.DakGun = nil

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	--local phys = self:GetPhysicsObject()

	
	self.DakArmor = 10
	self.DakMass = 1000
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()

 	if self.DakHealth>self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
	end
 	
	self.DakBurnStacks = 0
end

function ENT:Think()
	if CurTime()>=self.SparkTime+0.33 then
		if self.DakHealth<=(self.DakMaxHealth*0.80) and self.DakHealth>(self.DakMaxHealth*0.60) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(1)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+3 then
				self:EmitSound( "daktanks/shock.mp3", 60, math.Rand(60,150), 0.4, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.60) and self.DakHealth>(self.DakMaxHealth*0.40) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(2)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+2 then
				self:EmitSound( "daktanks/shock.mp3", 60, math.Rand(60,150), 0.5, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.40) and self.DakHealth>(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(3)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+1 then
				self:EmitSound( "daktanks/shock.mp3", 60, math.Rand(60,150), 0.6, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(4)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+0.5 then
				self:EmitSound( "daktanks/shock.mp3", 60, math.Rand(60,150), 0.75, 6)
				self.Soundtime=CurTime()
			end
		end
		self.SparkTime=CurTime()
	end
	if self.DakName == "Small Autoloader Clip" then
		self.DakName = "Small Autoloader Magazine" 
	end
	if self.DakName == "Medium Autoloader Clip" then
		self.DakName = "Medium Autoloader Magazine" 
	end
	if self.DakName == "Large Autoloader Clip" then
		self.DakName = "Large Autoloader Magazine" 
	end
	if self.DakName == "Small Autoloader Magazine" then
		self.DakMass = 1000
	end
	if self.DakName == "Medium Autoloader Magazine" then
		self.DakMass = 2000
	end
	if self.DakName == "Large Autoloader Magazine" then
		self.DakMass = 3000
	end
	if IsValid(self.DakGun) then
		if self.DakGun.IsAutoLoader == 1 then
			if self.DakGun.TurretController then
				if self:GetParent() then
					if self:GetParent():GetParent() == self.DakGun.TurretController.TurretBase or self:GetParent():GetParent() == self.DakGun:GetParent():GetParent() or (self.DakGun.TurretController:GetYawMin()<=45 and self.DakGun.TurretController:GetYawMax()<=45) then
						self.DakGun.DakMagazine = math.floor(0.27*self:GetPhysicsObject():GetVolume()/(((self.DakGun.DakCaliber*0.0393701)^2)*(self.DakGun.DakCaliber*0.0393701*13*self.DakGun.ShellLengthMult)))
						if self.DakGun.DakMagazine > 0 then
							self.DakGun.DakReloadTime = self.DakGun.DakCooldown * self.DakGun.DakMagazine
							self.DakGun.HasMag = 1
							self.DakGun.Loaded = 1
						else
							self.DakGun.HasMag = 0
							self.DakGun.Loaded = 0
						end
					else
						self.DakGun.HasMag = 0
						self.DakGun.Loaded = 0
					end
				end
			else
				self.DakGun.DakMagazine = math.floor(0.27*self:GetPhysicsObject():GetVolume()/(((self.DakGun.DakCaliber*0.0393701)^2)*(self.DakGun.DakCaliber*0.0393701*13*self.DakGun.ShellLengthMult)))
				self.DakGun.DakReloadTime = self.DakGun.DakCooldown * self.DakGun.DakMagazine
				if self.DakGun.DakMagazine > 0 then
					self.DakGun.DakReloadTime = self.DakGun.DakCooldown * self.DakGun.DakMagazine
					self.DakGun.HasMag = 1
					self.DakGun.Loaded = 1
				else
					self.DakGun.HasMag = 0
					self.DakGun.Loaded = 0
				end
			end
		end
	end

	if self.DakHealth > self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
	end

	if self:GetPhysicsObject():GetMass() ~= self.DakMass then self:GetPhysicsObject():SetMass(self.DakMass) end

	if self.DakDead ~= true then
		if self.DakHealth<self.DakMaxHealth/2 and self.DakIsExplosive then

			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(500)
			effectdata:SetNormal( Vector(0,0,-1) )
			util.Effect("daktescalingexplosion", effectdata, true, true)

			self:DTExplosion(self:GetPos(),20000,500,200,100,self.DakOwner)

			self:EmitSound( "daktanks/ammoexplode.mp3", 100, 75, 1)
			if self.DakOwner:IsPlayer() and self.DakOwner~=NULL then self.DakOwner:ChatPrint(self.DakName.." Exploded!") end
			self:SetMaterial("models/props_buildings/plasterwall021a")
			self:SetColor(Color(100,100,100,255))
			self.DakDead = true
			if IsValid(self.DakGun) then self.DakGun.Loaded = 0 end
		end
	else
		if IsValid(self.DakGun) then self.DakGun.Loaded = 0 end
		self.DakHealth = 0
	end

	if self:IsOnFire() and self.DakDead ~= true then
		self.DakHealth = self.DakHealth - 5
		if self.DakHealth <= 0 then
			if self.DakOwner:IsPlayer() and self.DakOwner~=NULL then self.DakOwner:ChatPrint(self.DakName.." Destroyed!") end
			self:SetMaterial("models/props_buildings/plasterwall021a")
			self:SetColor(Color(100,100,100,255))
			self.DakDead = true
			if IsValid(self.DakGun) then self.DakGun.Loaded = 0 end
		end
	end

	self:NextThink(CurTime()+1)
    return true
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}
	info.DakName = self.DakName
	info.DakIsExplosive = self.DakIsExplosive
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakOwner = self.DakOwner
	if IsValid(self.DakGun) then
		info.GunID = self.DakGun:EntIndex()
	end
	info.DakColor = self:GetColor()
	--Materials
	info.DakMat0 = self:GetSubMaterial(0)
	info.DakMat1 = self:GetSubMaterial(1)
	duplicator.StoreEntityModifier( self, "DakTek", info )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakIsExplosive = Ent.EntityMods.DakTek.DakIsExplosive
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = self.DakMaxHealth
		self.DakOwner = Player
		self:SetColor(Ent.EntityMods.DakTek.DakColor)
		self:SetSubMaterial( 0, Ent.EntityMods.DakTek.DakMat0 )
		self:SetSubMaterial( 1, Ent.EntityMods.DakTek.DakMat1 )
		local Gun = CreatedEntities[ Ent.EntityMods.DakTek.GunID ]
		if Gun and IsValid(Gun) then
			self.DakGun = Gun
		end
		self:Activate()
		Ent.EntityMods.DakTek = nil
		Ent.EntityMods.DakTekLink = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end

function ENT:OnRemove()
	if IsValid(self.DakGun) then
		self.DakGun.Loaded = 0
	end
end