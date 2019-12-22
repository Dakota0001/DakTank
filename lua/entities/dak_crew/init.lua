AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakEntity = NULL
ENT.DakMaxHealth = 5
ENT.DakHealth = 5
ENT.DakArmor = 2.5
ENT.DakName = "Crew"
--ENT.DakModel = "models/daktanks/crew.mdl"
ENT.DakMass = 75
ENT.DakPooled=0


function ENT:Initialize()
	--self:SetModel(self.DakModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	--local phys = self:GetPhysicsObject()
	
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.DakBurnStacks = 0
 	self.LastHealth = 5
 	self.VO = self:GetVoice()
 	if self.VO == 0 then
		self.VO = math.random(1,6)
	end

 	local VO1Death, dir1 = file.Find( "sound/daktanks/crew/aus/death*", "GAME")
 	local VO1Pain, dir2 = file.Find( "sound/daktanks/crew/aus/pain*", "GAME")
 	local VO1Suffer, dir3 = file.Find( "sound/daktanks/crew/aus/suffer*", "GAME")
 	self.VO1Death = VO1Death
 	self.VO1Pain = VO1Pain
 	self.VO1Suffer = VO1Suffer
  	local VO2Death, dir4 = file.Find( "sound/daktanks/crew/fre/death*", "GAME")
 	local VO2Pain, dir5 = file.Find( "sound/daktanks/crew/fre/pain*", "GAME")
 	local VO2Suffer, dir6 = file.Find( "sound/daktanks/crew/fre/suffer*", "GAME")
 	self.VO2Death = VO2Death
 	self.VO2Pain = VO2Pain
 	self.VO2Suffer = VO2Suffer
  	local VO3Death, dir7 = file.Find( "sound/daktanks/crew/ger/death*", "GAME")
 	local VO3Pain, dir8 = file.Find( "sound/daktanks/crew/ger/pain*", "GAME")
 	local VO3Suffer, dir9 = file.Find( "sound/daktanks/crew/ger/suffer*", "GAME")
 	self.VO3Death = VO3Death
 	self.VO3Pain = VO3Pain
 	self.VO3Suffer = VO3Suffer
  	local VO4Death, dir10 = file.Find( "sound/daktanks/crew/rus/death*", "GAME")
 	local VO4Pain, dir11 = file.Find( "sound/daktanks/crew/rus/pain*", "GAME")
 	local VO4Suffer, dir12 = file.Find( "sound/daktanks/crew/rus/suffer*", "GAME")
 	self.VO4Death = VO4Death
 	self.VO4Pain = VO4Pain
 	self.VO4Suffer = VO4Suffer
 	local VO5Death, dir13 = file.Find( "sound/daktanks/crew/sco/death*", "GAME")
 	local VO5Pain, dir14 = file.Find( "sound/daktanks/crew/sco/pain*", "GAME")
 	local VO5Suffer, dir15 = file.Find( "sound/daktanks/crew/sco/suffer*", "GAME")
 	self.VO5Death = VO5Death
 	self.VO5Pain = VO5Pain
 	self.VO5Suffer = VO5Suffer
  	local VO6Death, dir16 = file.Find( "sound/daktanks/crew/us/death*", "GAME")
 	local VO6Pain, dir17 = file.Find( "sound/daktanks/crew/us/pain*", "GAME")
 	local VO6Suffer, dir18 = file.Find( "sound/daktanks/crew/us/suffer*", "GAME")
 	self.VO6Death = VO6Death
 	self.VO6Pain = VO6Pain
 	self.VO6Suffer = VO6Suffer
end

function ENT:Think()
	self.DakMaxHealth = 5
	self.DakArmor = 2.5
	self.DakMass = 75
	--self.DakModel = "models/daktanks/crew.mdl"	
	if self.DakHealth > self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
	end
	if self.DakModel then
		if not(self:GetModel() == self.DakModel) then
			self:SetModel(self.DakModel)
			--self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end
	end
	if self:GetPhysicsObject():GetMass() ~= self.DakMass then self:GetPhysicsObject():SetMass(self.DakMass) end

	self.VO = self:GetVoice()
 	if self.VO == 0 then
		self.VO = math.random(1,6)
	end

	if self.DakHealth ~= self.LastHealth then
		if (self.LastHealth - self.DakHealth) < 2 then
			--light damage
			if self.VO == 1 then
				sound.Play( "daktanks/crew/aus/"..self.VO1Pain[math.random(1,#self.VO1Pain)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 2 then
				sound.Play( "daktanks/crew/fre/"..self.VO2Pain[math.random(1,#self.VO2Pain)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 3 then
				sound.Play( "daktanks/crew/ger/"..self.VO3Pain[math.random(1,#self.VO3Pain)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 4 then
				sound.Play( "daktanks/crew/rus/"..self.VO4Pain[math.random(1,#self.VO4Pain)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 5 then
				sound.Play( "daktanks/crew/sco/"..self.VO5Pain[math.random(1,#self.VO5Pain)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 6 then
				sound.Play( "daktanks/crew/us/"..self.VO6Pain[math.random(1,#self.VO6Pain)], self:GetPos(), 75, 100, 1 )
			end
		else
			--heavy damage
			if self.VO == 1 then
				sound.Play( "daktanks/crew/aus/"..self.VO1Suffer[math.random(1,#self.VO1Suffer)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 2 then
				sound.Play( "daktanks/crew/fre/"..self.VO2Suffer[math.random(1,#self.VO2Suffer)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 3 then
				sound.Play( "daktanks/crew/ger/"..self.VO3Suffer[math.random(1,#self.VO3Suffer)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 4 then
				sound.Play( "daktanks/crew/rus/"..self.VO4Suffer[math.random(1,#self.VO4Suffer)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 5 then
				sound.Play( "daktanks/crew/sco/"..self.VO5Suffer[math.random(1,#self.VO5Suffer)], self:GetPos(), 75, 100, 1 )
			elseif self.VO == 6 then
				sound.Play( "daktanks/crew/us/"..self.VO6Suffer[math.random(1,#self.VO6Suffer)], self:GetPos(), 75, 100, 1 )
			end
		end
	end
	self.LastHealth = self.DakHealth

    if IsValid(self.DakEntity) then
	    if IsValid(self) then
		    self.DakEntity.DakCrew = self
		end
    end

    if self:IsOnFire() then
		self.DakHealth = self.DakHealth - 0.5
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

	info.DakEntityID = self.DakEntity:EntIndex()
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
		local Job = CreatedEntities[ Ent.EntityMods.DakTek.DakEntityID ]
		if Job and IsValid(Job) then
			self.DakEntity = Job
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

function ENT:OnRemove()
	if self.DakHealth <= 0 then
		if self.VO == 1 then
			sound.Play( "daktanks/crew/aus/"..self.VO1Death[math.random(1,#self.VO1Death)], self:GetPos(), 75, 100, 1 )
		elseif self.VO == 2 then
			sound.Play( "daktanks/crew/fre/"..self.VO2Death[math.random(1,#self.VO2Death)], self:GetPos(), 75, 100, 1 )
		elseif self.VO == 3 then
			sound.Play( "daktanks/crew/ger/"..self.VO3Death[math.random(1,#self.VO3Death)], self:GetPos(), 75, 100, 1 )
		elseif self.VO == 4 then
			sound.Play( "daktanks/crew/rus/"..self.VO4Death[math.random(1,#self.VO4Death)], self:GetPos(), 75, 100, 1 )
		elseif self.VO == 5 then
			sound.Play( "daktanks/crew/sco/"..self.VO5Death[math.random(1,#self.VO5Death)], self:GetPos(), 75, 100, 1 )
		elseif self.VO == 6 then
			sound.Play( "daktanks/crew/us/"..self.VO6Death[math.random(1,#self.VO6Death)], self:GetPos(), 75, 100, 1 )
		end
	end

	if IsValid(self.DakEntity) then
	    self.DakEntity.DakCrew = NULL
    end
end