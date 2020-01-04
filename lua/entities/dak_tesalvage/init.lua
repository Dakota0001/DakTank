AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakArmor = 10
ENT.DakName = "Salvage"
ENT.DakModel = ""
ENT.DakPooled = 0
ENT.DakLastDamagePos = Vector(0,0,0)
ENT.LastHP = 0

function ENT:Initialize()
	--[[
	if self.DakModel == "models/daktanks/crew.mdl" or self.DakModel == "models/daktanks/crewstand.mdl" or self.DakModel == "models/daktanks/crewdriver.mdl" and not(self.gibbed==1) then
		self.gibbed = 1
		local salvage
		for i=1, 6 do
			salvage = ents.Create( "dak_tesalvage" )
			if i == 1 then
				salvage:SetModel("models/gibs/hgibs.mdl")
			end
			if i == 2 then
				salvage:SetModel("models/gibs/hgibs_spine.mdl")
			end
			if i >= 3 then
				salvage:SetModel("models/gibs/hgibs_rib.mdl")
			end
			salvage.LastPos = self:GetPos()
			salvage:SetPos( self:GetPos())
			salvage:SetAngles( self:GetAngles())
			salvage:Spawn()
			salvage:SetCollisionGroup( COLLISION_GROUP_WORLD )
			salvage.VO = math.random(1,6)
			salvage:GetPhysicsObject():ApplyForceCenter( VectorRand()*50*salvage:GetPhysicsObject():GetMass()*math.Rand(5,15))
			if math.random(0,4) == 0 then
				salvage:Ignite(25,1)
			else
				salvage:Ignite(math.Rand(1,5),1)
			end
			timer.Simple( 30, function()
				salvage:Remove()
			end )
			if i==1 and math.random(0,4) == 0 then
				timer.Simple(1.0 + math.Rand(-0.5,0.5), function()
					if IsValid(salvage) then
						salvage:EmitSound( "daktanks/crew/us/suffer"..math.random(1,6)..".mp3", 100, 100, 0.25, 3)
					end
				end )
				timer.Simple(2.0 + math.Rand(-0.5,0.5), function()
					if IsValid(salvage) then
					 	salvage:EmitSound( "daktanks/crew/us/suffer"..math.random(1,6)..".mp3", 100, 100, 0.25, 3)
					end
				end )
				timer.Simple(3.0 + math.Rand(-0.5,0.5), function()
					if IsValid(salvage) then
					 	salvage:EmitSound( "daktanks/crew/us/suffer"..math.random(1,6)..".mp3", 100, 100, 0.25, 3)
					end
				end )
				timer.Simple(4.0 + math.Rand(-0.5,0.5), function()
					if IsValid(salvage) then
					 	salvage:EmitSound( "daktanks/crew/us/suffer"..math.random(1,6)..".mp3", 100, 100, 0.25, 3)
					end
				end )
				timer.Simple(5.0 + math.Rand(-0.5,0.5), function()
					if IsValid(salvage) then
					 	salvage:EmitSound( "daktanks/crew/us/suffer"..math.random(1,6)..".mp3", 100, 100, 0.25, 3)
					end
				end )
			end
		end

		self:Remove()
	end
	]]--
	if self:GetModel() == "models/gibs/hgibs.mdl" or self:GetModel() == "models/gibs/hgibs_spine.mdl" or self:GetModel() == "models/gibs/hgibs_rib.mdl" then
		
	else
		self:SetMaterial("models/props_buildings/plasterwall021a")
	end

	self:SetModel( self.DakModel )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetColor(Color(100,100,100,255))
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	
	self.SpawnTime = CurTime()
	local DeathSounds = {"daktanks/closeexp1.mp3","daktanks/closeexp2.mp3","daktanks/closeexp3.mp3"}
	self:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 1, 3)

	if self.launch == 1 then
		if self:IsValid() then
			if self:GetPhysicsObject():IsValid() then
				self:GetPhysicsObject():ApplyForceCenter( VectorRand()*70*self:GetPhysicsObject():GetMass()*math.Rand(5,15))
			end
		end
	end
	if math.random(0,4) == 0 then
		self:Ignite(25,1)
	end
	self.DakBurnStacks = 0

end

function ENT:Think()

	if self:GetModel() == "models/gibs/hgibs_rib.mdl" and (self:GetParent()==NULL or self:GetParent()==nil) then
		trace = {}
		trace.start = self.LastPos
		trace.endpos = self:GetPos() + self:GetVelocity()*0.25
		trace.filter = self
		local Hit = util.TraceLine( trace )
		if Hit.Entity:IsValid() then 
			self:SetParent(Hit.Entity)
			if Hit.Entity:GetParent():IsValid() then
				self:SetParent(Hit.Entity:GetParent())
				if Hit.Entity:GetParent():GetParent():IsValid() then
					self:SetParent(Hit.Entity:GetParent():GetParent())
				end
			end
			self:SetParent(Hit.Entity)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetPos(Hit.HitPos)
		end
	end

	if self.SpawnTime+30 < CurTime() then
		self:Remove()
	end

	self:NextThink(CurTime()+0.25)
    return true
end