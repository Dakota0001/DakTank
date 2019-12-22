AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakEngine = NULL
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
--ENT.DakName = "TMotor"
--ENT.DakModel = "models/xqm/hydcontrolbox.mdl"
ENT.DakMass = 250
ENT.DakPooled=0


function ENT:Initialize()
	--self:SetModel(self.DakModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakArmor = 10
	self.DakHealth = self.DakMaxHealth
	--local phys = self:GetPhysicsObject()
	
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
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
				self:EmitSound( "dak/shock.wav", 60, math.Rand(60,150), 0.4, 6)
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
				self:EmitSound( "dak/shock.wav", 60, math.Rand(60,150), 0.5, 6)
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
				self:EmitSound( "dak/shock.wav", 60, math.Rand(60,150), 0.6, 6)
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
				self:EmitSound( "dak/shock.wav", 60, math.Rand(60,150), 0.75, 6)
				self.Soundtime=CurTime()
			end
		end
		self.SparkTime=CurTime()
	end

	if self.DakName == "Turret Motor" then
		self.DakName = "Small Turret Motor"
	end
	if self.DakName == "TMotor" then
		self.DakName = "Small Turret Motor"
	end

	if self.DakName == "Small Turret Motor" then
		self.DakMaxHealth = 10
		self.DakMass = 250
		self.DakModel = "models/xqm/hydcontrolbox.mdl"	
		self.DakRotMult = 0.1
	end
	if self.DakName == "Medium Turret Motor" then
		self.DakMaxHealth = 20
		self.DakMass = 500
		self.DakModel = "models/props_c17/utilityconducter001.mdl"	
		self.DakRotMult = 0.25
	end
	if self.DakName == "Large Turret Motor" then
		self.DakMaxHealth = 50
		self.DakMass = 1000
		self.DakModel = "models/props_c17/substation_transformer01d.mdl"	
		self.DakRotMult = 0.6
	end
	if self.DakModel then
		if self:GetModel() ~= self.DakModel then
			self:SetModel(self.DakModel)
			--self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end
	end
	if self.DakHealth > self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
	end
	if self.DakRotMult then
		self.DakRotMult = self.DakRotMult * self.DakHealth/self.DakMaxHealth
	end
	if self:GetPhysicsObject():GetMass() ~= self.DakMass then self:GetPhysicsObject():SetMass(self.DakMass) end
	
	if self:IsOnFire() then
		self.DakHealth = self.DakHealth - 1*0.33
		if self.DakHealth <= 0 then
			local salvage = ents.Create( "dak_tesalvage" )
			salvage.DakModel = self:GetModel()
			salvage:SetPos( self:GetPos())
			salvage:SetAngles( self:GetAngles())
			salvage:Spawn()
			self:Remove()
		end
	end

    self:NextThink(CurTime()+0.33)
    return true
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}

	if IsValid(self.TurretController) then
		info.TurretID = self.TurretController:EntIndex()
	end
	info.DakName = self.DakName
	info.DakMass = self.DakMass
	info.DakModel = self.DakModel
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		if Ent.EntityMods.DakTek.TurretID then
			local Eng = CreatedEntities[ Ent.EntityMods.DakTek.TurretID ]
			if Eng and IsValid(Eng) then
				self.TurretController = Eng
			end
		end
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakModel = Ent.EntityMods.DakTek.DakModel
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakOwner = Player
		self.DakHealth = self.DakMaxHealth
		if Ent.EntityMods.DakTek.DakColor == nil then
		else
			self:SetColor(Ent.EntityMods.DakTek.DakColor)
		end

		--self:PhysicsDestroy()
		--self:SetModel(self.DakModel)
		--self:PhysicsInit(SOLID_VPHYSICS)
		--self:SetMoveType(MOVETYPE_VPHYSICS)
		--self:SetSolid(SOLID_VPHYSICS)

		self:Activate()

		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end