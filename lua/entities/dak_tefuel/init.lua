AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakName = "Fuel Tank"
ENT.DakIsExplosive = true
ENT.DakArmor = 10
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakPooled=0
ENT.DakFuel = 0

function CheckClip(Ent, HitPos)
	if not (Ent:GetClass() == "prop_physics") or (Ent.ClipData == nil) then return false end
	local HitClip = false
	local normal
	local origin
	for i=1, #Ent.ClipData do
		normal = Ent:LocalToWorldAngles(Ent.ClipData[i]["n"]):Forward()
		origin = Ent:LocalToWorld(Ent.ClipData[i]["n"]:Forward()*Ent.ClipData[i]["d"])
		HitClip = HitClip or normal:Dot((origin - HitPos):GetNormalized()) > 0
		if HitClip then return true end
	end
	return HitClip
end

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	--local phys = self:GetPhysicsObject()

	
	self.DakArmor = 10
	self.DakMass = 1000
	self.PowerMod = 1
	self.Soundtime = CurTime()
 	self.DumpTime = CurTime()
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

		if self.DakName == "Micro Fuel Tank" then
			self.DakMass = 65
			self.DakFuel = 45
			self.DakMaxHealth = 10
		end
		if self.DakName == "Small Fuel Tank" then
			self.DakMass = 120
			self.DakFuel = 90
			self.DakMaxHealth = 20
		end
		if self.DakName == "Standard Fuel Tank" then
			self.DakMass = 240
			self.DakFuel = 180
			self.DakMaxHealth = 30
		end
		if self.DakName == "Large Fuel Tank" then
			self.DakMass = 475
			self.DakFuel = 360
			self.DakMaxHealth = 40
		end
		if self.DakName == "Huge Fuel Tank" then
			self.DakMass = 950
			self.DakFuel = 720
			self.DakMaxHealth = 50
		end
		if self.DakName == "Ultra Fuel Tank" then
			self.DakMass = 1900
			self.DakFuel = 1440
			self.DakMaxHealth = 60
		end

		if self.DakHealth > self.DakMaxHealth then
			self.DakHealth = self.DakMaxHealth
		end

		self.DakFuel = self.DakFuel * (self.DakHealth/self.DakMaxHealth)

		if self:GetPhysicsObject():GetMass() ~= self.DakMass then self:GetPhysicsObject():SetMass(self.DakMass) end

	if self.DakHealth<(self.DakMaxHealth*0.9) and self.DakIsExplosive then
		self:Ignite( 60, 0 )
	end
	if self:IsOnFire() then
		for i=1, 10 do
			local Direction = VectorRand()
			local trace = {}
				trace.start = self:GetPos()
				trace.endpos = self:GetPos() + Direction*50
				trace.filter = self
				trace.mins = Vector(-1,-1,-1)
				trace.maxs = Vector(1,1,1)
			local FireTrace = util.TraceHull( trace )
			if IsValid(FireTrace.Entity) then
				local Class = FireTrace.Entity:GetClass()
				if Class=="dak_crew" or Class=="dak_teammo" or Class=="dak_teautoloadingmodule" or Class=="dak_tefuel" or Class=="dak_tegearbox" or Class=="dak_temotor" or Class=="dak_turretmotor" then
					FireTrace.Entity:Ignite( 60, 0 )
				end
				if FireTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(FireTrace.Entity)
				end
				if FireTrace.Entity.DakArmor < 5 or CheckClip(FireTrace.Entity,FireTrace.HitPos) then
					RecurseTrace(self:GetPos(), self:GetPos() + Direction*50, {self, FireTrace.Entity})
				end
			end
		end
		self.DakHealth = self.DakHealth - 1
		if self.DakHealth <= 0 then
			local salvage = ents.Create( "dak_tesalvage" )
			salvage.DakModel = self:GetModel()
			salvage:SetPos( self:GetPos())
			salvage:SetAngles( self:GetAngles())
			salvage:Spawn()
			self:Remove()
		end
	end
	self:NextThink(CurTime()+1)
    return true
end

function RecurseTrace(start, endpos, filter)
	local trace = {}
		trace.start = start
		trace.endpos = endpos
		trace.filter = filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local FireTrace = util.TraceHull( trace )
	if IsValid(FireTrace.Entity) then
		local Class = FireTrace.Entity:GetClass()
		if Class=="dak_crew" or Class=="dak_teammo" or Class=="dak_teautoloadingmodule" or Class=="dak_tefuel" or Class=="dak_tegearbox" or Class=="dak_temotor" or Class=="dak_turretmotor" then
			FireTrace.Entity:Ignite( 60, 0 )
		end
		if FireTrace.Entity.DakArmor == nil then
			DakTekTankEditionSetupNewEnt(FireTrace.Entity)
		end
		if FireTrace.Entity.DakArmor < 5 or CheckClip(FireTrace.Entity,FireTrace.HitPos) then
			filter[#filter+1] = FireTrace.Entity
			RecurseTrace(start, endpos, filter)
		end
	end
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}


	info.DakName = self.DakName
	info.DakIsExplosive = self.DakIsExplosive
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakOwner = self.DakOwner

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakIsExplosive = Ent.EntityMods.DakTek.DakIsExplosive
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakOwner = Player

		Ent.EntityMods.DakTekLink = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end