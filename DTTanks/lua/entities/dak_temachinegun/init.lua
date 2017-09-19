AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakOwner = NULL
ENT.DakName = "Base Gun"
ENT.DakModel = "models/daktanks/cannon25mm.mdl"
ENT.DakCooldown = 1
ENT.DakMaxHealth = 1
ENT.DakHealth = 1
ENT.DakAmmo = 0
ENT.DakMass = 1
ENT.DakAmmoType = "a"
ENT.DakFireEffect = "a"
ENT.DakFireSound = "a"
ENT.DakFirePitch = 100
ENT.DakIsFlechette = false
ENT.DakPellets = 1
--shell definition
ENT.DakShellTrail = "a"
ENT.DakShellVelocity = 1
ENT.DakShellDamage = 1
ENT.DakShellPenSounds = {}
ENT.DakShellMass = 1
ENT.DakShellSplashDamage = 1
ENT.DakShellPenetration = 1
ENT.DakShellExplosive = false
ENT.DakShellBlastRadius = 100
ENT.DakPooled=0
ENT.DakArmor = 1
ENT.DakTankCore = nil
ENT.HasCrew = 0

function ENT:Initialize()
	self:SetModel(self.DakModel)
	self.DakHealth = self.DakMaxHealth
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	self.timer = CurTime()
	if(IsValid(phys)) then
		phys:Wake()
	end
	self.Inputs = Wire_CreateInputs(self, { "Fire" })
	self.Outputs = WireLib.CreateOutputs( self, { "Cooldown" , "CooldownPercent", "Ammo", "AmmoType [STRING]", "MuzzleVel", "ShellMass", "Penetration" } )
 	self.Held = false
 	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.LastFireTime = CurTime()
 	self.CurrentAmmoType = 1

	function self:SetupDataTables()
 		self:NetworkVar("Bool",0,"Firing")
 		self:NetworkVar("Float",0,"Timer")
 		self:NetworkVar("Float",1,"Cooldown")
 		self:NetworkVar("String",0,"Model")
 	end

end

function ENT:Think()
	if CurTime()>=self.SlowThinkTime+1 then
		--Machine Guns
		if self.DakName == "5.56mm Machine Gun" then
			self.DakCooldown = 0.06
			self.DakMaxHealth = 5.56
			self.DakArmor = 22.24
			self.DakMass = 20
			self.DakAP = "5.56mmMGAPAmmo"
			self.DakFireEffect = "dakballisticfirelight"
			self.DakFireSound = "daktanks/5mm.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 0.06
			self.BaseDakShellMass = 1
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellSplashDamage = 0
			self.BaseDakShellPenetration = 11.12
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 0
			self.DakModel = "models/daktanks/mg556mm.mdl"
		end
		if self.DakName == "7.62mm Machine Gun" then
			self.DakCooldown = 0.08
			self.DakMaxHealth = 7.62
			self.DakArmor = 30.48
			self.DakMass = 30
			self.DakAP = "7.62mmMGAPAmmo"
			self.DakFireEffect = "dakballisticfirelight"
			self.DakFireSound = "daktanks/7mm.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 0.08
			self.BaseDakShellMass = 1
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellSplashDamage = 0
			self.BaseDakShellPenetration = 15.24
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 0
			self.DakModel = "models/daktanks/mg762mm.mdl"
		end
		if self.DakName == "9mm Machine Gun" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 9
			self.DakArmor = 36
			self.DakMass = 40
			self.DakAP = "9mmMGAPAmmo"
			self.DakFireEffect = "dakballisticfirelight"
			self.DakFireSound = "daktanks/9mm.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 0.09
			self.BaseDakShellMass = 1
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellSplashDamage = 0
			self.BaseDakShellPenetration = 18
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 0
			self.DakModel = "models/daktanks/mg9mm.mdl"
		end
		if self.DakName == "12.7mm Machine Gun" then
			self.DakCooldown = 0.15
			self.DakMaxHealth = 12.7
			self.DakArmor = 50.8
			self.DakMass = 50
			self.DakAP = "12.7mmMGAPAmmo"
			self.DakFireEffect = "dakballisticfirelight"
			self.DakFireSound = "daktanks/12mm.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 0.13
			self.BaseDakShellMass = 1
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellSplashDamage = 0
			self.BaseDakShellPenetration = 25.4
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 0
			self.DakModel = "models/daktanks/mg127mm.mdl"
		end
		if self.DakName == "14.5mm Machine Gun" then
			self.DakCooldown = 0.17
			self.DakMaxHealth = 14.5
			self.DakArmor = 58
			self.DakMass = 60
			self.DakAP = "14.5mmMGAPAmmo"
			self.DakFireEffect = "dakballisticfirelight"
			self.DakFireSound = "daktanks/14mm.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 0.15
			self.BaseDakShellMass = 1
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellSplashDamage = 0
			self.BaseDakShellPenetration = 29
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 0
			self.DakModel = "models/daktanks/mg145mm.mdl"
		end

		if not(self:GetModel() == self.DakModel) then
			self:SetModel(self.DakModel)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end

		if self.DakHealth > self.DakMaxHealth then
			self.DakHealth = self.DakMaxHealth
		end
		self:GetPhysicsObject():SetMass(self.DakMass)
		self.SlowThinkTime = CurTime()
	end

	self:DakTEAmmoCheck()

	WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100))
	WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100)/self.DakCooldown))

	self:NextThink( CurTime()+0.33 )
	return true
end

function ENT:DakTEAmmoCheck()
	if self.CurrentAmmoType == 1 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing")
		self.DakAmmoType = self.DakAP
		self.DakIsFlechette = false
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.BaseDakShellPenetration
		self.DakShellVelocity = self.BaseDakShellVelocity
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	self.AmmoCount = 0 
	if IsValid(self.DakTankCore) then
		if not(self.DakTankCore.Ammoboxes == nil) then
			for i = 1, #self.DakTankCore.Ammoboxes do
				if IsValid(self.DakTankCore.Ammoboxes[i]) then
					if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
						self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
					end
				end
			end
		end
	end
	WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
end

function ENT:DakTEFire()
	if( self.Firing ) then
		self.AmmoCount = 0 
		if IsValid(self.DakTankCore) then
			if not(self.DakTankCore.Ammoboxes == nil) then
				for i = 1, #self.DakTankCore.Ammoboxes do
					if IsValid(self.DakTankCore.Ammoboxes[i]) then
						if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
							self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
						end
					end
				end
			end
		end
		if self.AmmoCount > 0 then
			if CurTime() > (self.timer + self.DakCooldown) then
				--AMMO CHECK HERE
				for i = 1, #self.DakTankCore.Ammoboxes do
					if IsValid(self.DakTankCore.Ammoboxes[i]) then
						if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
							if self.DakTankCore.Ammoboxes[i].DakAmmo > 0 then
								self.DakTankCore.Ammoboxes[i].DakAmmo = self.DakTankCore.Ammoboxes[i].DakAmmo-1
							break end
						end
					end
				end
				--FIREBULLETHERE
				self.LastFireTime = CurTime()
				local Attachment = self:GetAttachment( 1 )
				local shootOrigin = Attachment.Pos
				local shootAngles = self:GetAngles()
				local shootDir = shootAngles:Forward()
				
				if self.DakIsFlechette then
					for i = 1, self.DakPellets do
						local shell = ents.Create( "dak_tankshell" )
						if ( !IsValid( shell ) ) then return end

						shell:SetPos( shootOrigin + ( self:GetForward() * 1 ))
						shell:SetAngles( shootAngles + Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),math.Rand(-0.5,0.5)) )

						shell.DakTrail = self.DakShellTrail
						shell.DakVelocity = self.DakShellVelocity
						shell.DakDamage = self.DakShellDamage
						shell.DakMass = self.DakShellMass
						shell.DakIsPellet = true
						shell.DakSplashDamage = self.DakShellSplashDamage
						shell.DakPenetration = self.DakShellPenetration
						shell.DakExplosive = self.DakShellExplosive
						shell.DakBlastRadius = self.DakShellBlastRadius
						shell.DakPenSounds = self.DakShellPenSounds

						shell.DakBasePenetration = self.BaseDakShellPenetration

						shell.DakCaliber = self.DakMaxHealth/10

						shell.DakGun = self
						shell:Spawn()
	 				end
	 			else
	 				local shell = ents.Create( "dak_tankshell" )
	 				if ( !IsValid( shell ) ) then return end
	 				shell:SetPos( shootOrigin + ( self:GetForward() * 1 ))
					shell:SetAngles( shootAngles + Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1)) )

					shell.DakTrail = self.DakShellTrail
					shell.DakVelocity = self.DakShellVelocity
					shell.DakDamage = self.DakShellDamage
					shell.DakMass = self.DakShellMass
					shell.DakIsPellet = false
					shell.DakSplashDamage = self.DakShellSplashDamage
					shell.DakPenetration = self.DakShellPenetration
					shell.DakExplosive = self.DakShellExplosive
					shell.DakBlastRadius = self.DakShellBlastRadius
					shell.DakPenSounds = self.DakShellPenSounds

					shell.DakBasePenetration = self.BaseDakShellPenetration

					shell.DakCaliber = self.DakMaxHealth

					shell.DakGun = self
					shell:Spawn()
				end

				local effectdata = EffectData()
				effectdata:SetOrigin( self:GetAttachment( 1 ).Pos )
				effectdata:SetAngles( self:GetAngles() )
				effectdata:SetEntity(self)
				effectdata:SetScale( self.BaseDakShellDamage )
				util.Effect( self.DakFireEffect, effectdata )

				self:EmitSound( self.DakFireSound, 100, self.DakFirePitch, 1, 6)
				self.timer = CurTime()
				if(self:IsValid()) then
					if(self:GetParent():IsValid()) then
						if(self:GetParent():GetParent():IsValid()) then
							self:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( -self:GetForward()*self.DakShellVelocity*self.BaseDakShellMass/20 )
						end
					end
					if not(self:GetParent():IsValid()) then
						self:GetPhysicsObject():ApplyForceCenter( -self:GetForward()*self.DakShellVelocity*self.BaseDakShellMass/20 )
					end
				end
			end
		end
	end
	self.AmmoCount = 0 
	if IsValid(self.DakTankCore) then
		if not(self.DakTankCore.Ammoboxes == nil) then
			for i = 1, #self.DakTankCore.Ammoboxes do
				if IsValid(self.DakTankCore.Ammoboxes[i]) then
					if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
						self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
					end
				end
			end
		end
	end
	WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
end

function ENT:TriggerInput(iname, value)
	if IsValid(self.DakTankCore) then
		self.Held = value
		if (iname == "Fire") then
			if value>0 then
				self:DakTEFire()
				self.Firing = value > 0
				timer.Create( "RefireTimer"..self:EntIndex(), self.DakCooldown/10, 1, function()
					if IsValid(self) then
						self:TriggerInput("Fire", value)
					end
				end)
			else
				timer.Remove( "RefireTimer"..self:EntIndex() )
			end
		end
	end
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}
	info.DakName = self.DakName
	info.DakCooldown = self.DakCooldown
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakAmmo = self.DakAmmo
	info.DakMass = self.DakMass
	info.DakModel = self.DakModel
	info.DakAmmoType = self.DakAmmoType
	info.DakFireEffect = self.DakFireEffect
	info.DakFireSound = self.DakFireSound
	info.DakFirePitch = self.DakFirePitch
	info.DakIsFlechette = self.DakIsFlechette
	info.DakPellets = self.DakPellets
	info.DakOwner = self.DakOwner
	info.DakColor = self:GetColor()
    --shell definition
	info.DakShellTrail = self.DakShellTrail
	info.DakShellVelocity = self.DakShellVelocity
	info.DakShellDamage = self.DakShellDamage
	info.DakShellMass = self.DakShellMass
	info.DakShellPenSounds = self.DakShellPenSounds
	info.DakShellSplashDamage = self.DakShellSplashDamage
	info.DakShellPenetration = self.DakShellPenetration
	info.DakShellExplosive = self.DakShellExplosive
	info.DakShellBlastRadius = self.DakShellBlastRadius

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
		self.DakCooldown = Ent.EntityMods.DakTek.DakCooldown
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakAmmo = Ent.EntityMods.DakTek.DakAmmo
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakModel = Ent.EntityMods.DakTek.DakModel
		self.DakAmmoType = Ent.EntityMods.DakTek.DakAmmoType
		self.DakFireEffect = Ent.EntityMods.DakTek.DakFireEffect
		self.DakFireSound = Ent.EntityMods.DakTek.DakFireSound
		self.DakFirePitch = Ent.EntityMods.DakTek.DakFirePitch
		self.DakIsFlechette = Ent.EntityMods.DakTek.DakIsFlechette
		self.DakPellets = Ent.EntityMods.DakTek.DakPellets
        --shell definition
		self.DakShellTrail = Ent.EntityMods.DakTek.DakShellTrail
		self.DakShellVelocity = Ent.EntityMods.DakTek.DakShellVelocity
		self.DakShellDamage = Ent.EntityMods.DakTek.DakShellDamage
		self.DakShellGravity = Ent.EntityMods.DakTek.DakShellGravity
		self.DakShellMass = Ent.EntityMods.DakTek.DakShellMass
		self.DakShellPenSounds = Ent.EntityMods.DakTek.DakShellPenSounds
		self.DakShellSplashDamage = Ent.EntityMods.DakTek.DakShellSplashDamage
		self.DakShellPenetration = Ent.EntityMods.DakTek.DakShellPenetration
		self.DakShellExplosive = Ent.EntityMods.DakTek.DakShellExplosive
		self.DakShellBlastRadius = Ent.EntityMods.DakTek.DakShellBlastRadius
		self.DakHealth = self.DakMaxHealth

		self.DakOwner = Player
		self:SetColor(Ent.EntityMods.DakTek.DakColor)
		self:SetSubMaterial( 0, Ent.EntityMods.DakTek.DakMat0 )
		self:SetSubMaterial( 1, Ent.EntityMods.DakTek.DakMat1 )

		self:PhysicsDestroy()
		self:SetModel(self.DakModel)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		self:Activate()

		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end
