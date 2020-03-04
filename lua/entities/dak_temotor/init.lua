AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakFuel = NULL
ENT.DakMaxHealth = 25
ENT.DakHealth = 25
--ENT.DakName = "Light Motor"
--ENT.DakModel = "models/daktanks/engine1.mdl"
ENT.DakSpeed = 1.1725
ENT.DakMass = 1000
ENT.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
ENT.DakPooled=0
ENT.DakCrew = NULL
ENT.DakHP = 0


function ENT:Initialize()
	--self:SetModel(self.DakModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	--local phys = self:GetPhysicsObject()
	
	--self:EmitSound(self.DakSound,75,0,1,CHAN_AUTO)
	self.initsound = self.DakSound
	self.Sound = CreateSound( self, self.DakSound, CReliableBroadcastRecipientFilter )
	self.Sound:PlayEx(1,100)
	self.Sound:ChangePitch( 0, 0 )
	self.Sound:ChangeVolume( 0, 0 )
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
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
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.4, 6)
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
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.5, 6)
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
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.6, 6)
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
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.75, 6)
				self.Soundtime=CurTime()
			end
		end
		self.SparkTime=CurTime()
	end
	if self.DakName == "Micro Engine" then
		self.DakMaxHealth = 5
		self.DakArmor = 5
		self.DakMass = 80
		self.DakSpeed = 0.4444
		self.DakModel = "models/daktanks/engine1.mdl"
		self.DakFuelReq = 24
		self.DakHP = 40
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	elseif self.DakName == "Small Engine" then
		self.DakMaxHealth = 20
		self.DakArmor = 20
		self.DakMass = 265
		self.DakSpeed = 1.3888
		self.DakModel = "models/daktanks/engine2.mdl"
		self.DakFuelReq = 75
		self.DakHP = 125
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	elseif self.DakName == "Standard Engine" then
		self.DakMaxHealth = 45
		self.DakArmor = 45
		self.DakMass = 625
		self.DakSpeed = 3.3333
		self.DakModel = "models/daktanks/engine3.mdl"
		self.DakFuelReq = 180
		self.DakHP = 300
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	elseif self.DakName == "Large Engine" then
		self.DakMaxHealth = 90
		self.DakArmor = 90
		self.DakMass = 1225
		self.DakSpeed = 6.6666
		self.DakModel = "models/daktanks/engine4.mdl"
		self.DakFuelReq = 360
		self.DakHP = 600
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	elseif self.DakName == "Huge Engine" then
		self.DakMaxHealth = 150
		self.DakArmor = 150
		self.DakMass = 2120
		self.DakSpeed = 11.1111
		self.DakModel = "models/daktanks/engine5.mdl"
		self.DakFuelReq = 600
		self.DakHP = 1000
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	elseif self.DakName == "Ultra Engine" then
		self.DakMaxHealth = 360
		self.DakArmor = 360
		self.DakMass = 5020
		self.DakSpeed = 26.6666
		self.DakModel = "models/daktanks/engine6.mdl"
		self.DakFuelReq = 1440
		self.DakHP = 2400
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if not(self.FirstCheck) and not(self.DakMaxHealth == 25) then
		self.FirstCheck = true
		self.DakHealth = self.DakMaxHealth
	end

	if self.DakHealth > self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
	end

	self.DakSpeed = self.DakSpeed * (self.DakHealth/self.DakMaxHealth) * self:GetHorsePowerMultiplier()
	self.DakHP = self.DakHP * (self.DakHealth/self.DakMaxHealth) * self:GetHorsePowerMultiplier()

	if self.initsound ~= self.DakSound then
		self.initsound = self.DakSound
		self.Sound:Stop()
		self.Sound = CreateSound( self, self.DakSound, CReliableBroadcastRecipientFilter )
		self.Sound:PlayEx(1,100)
		self.Sound:ChangePitch( 0, 0 )
		self.Sound:ChangeVolume( 0, 0 )
	end
	if self.DakModel then
		if self:GetModel() ~= self.DakModel then
			self:SetModel(self.DakModel)
			--self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end
	end
	if self:GetPhysicsObject():GetMass() ~= self.DakMass then self:GetPhysicsObject():SetMass(self.DakMass) end

	if self:IsOnFire() then
		self.DakHealth = self.DakHealth - self.DakMaxHealth*0.025*0.25
		if self.DakHealth <= 0 then
			local salvage = ents.Create( "dak_tesalvage" )
			salvage.DakModel = self:GetModel()
			salvage:SetPos( self:GetPos())
			salvage:SetAngles( self:GetAngles())
			salvage:Spawn()
			self:Remove()
		end
	end
    self:NextThink(CurTime()+0.25)
    return true
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}

	info.FuelID = self.DakFuel:EntIndex()
	info.CrewID = self.DakCrew:EntIndex()
	info.DakName = self.DakName
	info.DakMass = self.DakMass
	info.DakModel = self.DakModel
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakSpeed = self.DakSpeed
	info.DakSound = self.DakSound

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		local Fuel = CreatedEntities[ Ent.EntityMods.DakTek.FuelID ]
		if Fuel and IsValid(Fuel) then
			self.DakFuel = Fuel
		end
		local Crew = CreatedEntities[ Ent.EntityMods.DakTek.CrewID ]
		if Crew and IsValid(Crew) then
			self.DakCrew = Crew
		end
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakModel = Ent.EntityMods.DakTek.DakModel
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakSpeed = Ent.EntityMods.DakTek.DakSpeed
		self.DakSound = Ent.EntityMods.DakTek.DakSound
		self.DakOwner = Player
		self.DakHealth = self.DakMaxHealth
		if not(Ent.EntityMods.DakTek.DakColor) then
		else
			self:SetColor(Ent.EntityMods.DakTek.DakColor)
		end

		--self:PhysicsDestroy()
		--self:SetModel(self.DakModel)
		--self:PhysicsInit(SOLID_VPHYSICS)
		--self:SetMoveType(MOVETYPE_VPHYSICS)
		--self:SetSolid(SOLID_VPHYSICS)

		--self:Activate()

		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end

function ENT:OnRemove()
	self.Sound:Stop()
end