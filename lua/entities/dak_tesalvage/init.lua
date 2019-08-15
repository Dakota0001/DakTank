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

	if self.DakModel == "models/daktanks/crew.mdl" or self.DakModel == "models/daktanks/crewstand.mdl" or self.DakModel == "models/daktanks/crewdriver.mdl" or self.DakModel == "models/Humans/Charple01.mdl" or self.DakModel == "models/Humans/Charple02.mdl" or self.DakModel == "models/Humans/Charple03.mdl" or self.DakModel == "models/Humans/Charple04.mdl" then
		local salvage = ents.Create( "prop_ragdoll" )

		salvage:SetModel("models/Humans/Charple0"..math.random(1,4)..".mdl")
		salvage:SetPos( self:GetPos())
		salvage:SetAngles( self:GetAngles())
		salvage:Spawn()
		salvage:SetCollisionGroup( COLLISION_GROUP_WORLD )
		salvage.VO = math.random(1,6)
		if self.launch == 1 then
			salvage:GetPhysicsObject():ApplyForceCenter( VectorRand()*350*salvage:GetPhysicsObject():GetMass()*math.Rand(5,15))
		end
		if math.random(0,4) == 0 then
			salvage:Ignite(25,1)
		else
			salvage:Ignite(math.Rand(1,5),1)
		end
		timer.Simple( 30, function()
			salvage:Remove()
		end )
		if math.random(0,4) == 0 then
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


		self:Remove()
	end

	self:SetModel( self.DakModel )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("models/props_buildings/plasterwall021a")
	self:SetColor(Color(100,100,100,255))
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	local phys = self:GetPhysicsObject()
	
	self.SpawnTime = CurTime()
	local DeathSounds = {"daktanks/closeexp1.wav","daktanks/closeexp2.wav","daktanks/closeexp3.wav"}
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
	if self.SpawnTime+30 < CurTime() then
		self:Remove()
	end
end