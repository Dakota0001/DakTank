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
	self:SetModel( self.DakModel )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("models/props_buildings/plasterwall021a")
	self:SetColor(Color(100,100,100,255))
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
	end
	self.SpawnTime = CurTime()

		--local effectdata = EffectData()
		--effectdata:SetOrigin(self:GetPos())
		--effectdata:SetEntity(self)
		--effectdata:SetAttachment(1)
		--effectdata:SetMagnitude(.5)
		--effectdata:SetScale(200)
		--util.Effect("dakbreak", effectdata)
		local DeathSounds = {"daktanks/closeexp1.wav","daktanks/closeexp2.wav","daktanks/closeexp3.wav"}
		self:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)

	--self:GetPhysicsObject():ApplyForceCenter((self:GetPos()-self.DakLastDamagePos):GetNormalized()*2500*math.abs(self.LastHP))
	if self.launch == 1 then
		self:GetPhysicsObject():ApplyForceCenter( VectorRand()*70*self:GetPhysicsObject():GetMass()*math.Rand(5,15))
	end
	if math.random(0,4) == 0 then
		self:Ignite(25,1)
	end

end

function ENT:Think()
	self:SetMaterial("models/props_buildings/plasterwall021a")
	self:SetColor(Color(100,100,100,255))
	--self:GetPhysicsObject():SetMass(250)
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )

	if self.SpawnTime+30 < CurTime() then
		self:Remove()
	end

end