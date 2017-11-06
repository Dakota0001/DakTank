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
 	self.DakBurnStacks = 0

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
		if self.DakGunType == "MG" then
			self.DakName = self.DakCaliber.."mm Machine Gun"
			self.DakCooldown = math.Round((self.DakCaliber/13 + self.DakCaliber/100)*0.1,2)
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round((60/((14.5/self.DakCaliber)*(14.5/self.DakCaliber))))

			self.DakAP = math.Round(self.DakCaliber,2).."mmMGAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmMGHEAmmo"
			self.DakFL = math.Round(self.DakCaliber,2).."mmMGFLAmmo"

			self.BaseDakShellDamage = self.DakCaliber/100
			self.BaseDakShellMass = self.DakCaliber
			self.DakShellSplashDamage = self.DakCaliber/10*1.25
			self.BaseDakShellPenetration = self.DakCaliber*2
			self.DakShellExplosive = false
			self.DakShellBlastRadius = self.DakCaliber/25*39

			self.DakFireEffect = "dakballisticfirelight"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.DakIsFlechette = false
			self.DakPellets = 10

			if self.DakCaliber <= 75 then
				self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
				self.ReloadSound = "daktanks/dakreloadlight.wav"
			end
			if self.DakCaliber > 75 and self.DakCaliber < 120 then
				self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
				self.ReloadSound = "daktanks/dakreloadmedium.wav"
			end
			if self.DakCaliber >= 120 then
				self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
				self.ReloadSound = "daktanks/dakreloadheavy.wav"
			end

			if self.DakCaliber < 7.62 then
				self.DakFireSound = "daktanks/5mm.wav"
			end
			if self.DakCaliber >= 7.62 and self.DakCaliber < 9 then
				self.DakFireSound = "daktanks/7mm.wav"
			end
			if self.DakCaliber >= 9 and self.DakCaliber < 12.7 then
				self.DakFireSound = "daktanks/9mm.wav"
			end
			if self.DakCaliber >= 12.7 and self.DakCaliber < 14.5 then
				self.DakFireSound = "daktanks/12mm.wav"
			end
			if self.DakCaliber >= 14.5 then
				self.DakFireSound = "daktanks/14mm.wav"
			end
		end
		--Machine Guns
		if self.DakGunType == "Flamethrower" then
			self.DakName = "Flamethrower"
			self.DakCooldown = 0.1
			self.DakMaxHealth = 10
			self.DakArmor = 50
			self.DakMass = 50

			self.DakAP = "Flamethrower Fuel"

			self.BaseDakShellDamage = 0.2
			self.BaseDakShellMass = 1
			self.DakShellSplashDamage = 0.2
			self.BaseDakShellPenetration = 0.0001
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 15

			self.DakFireEffect = "dakflamefire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakflametrail"
			self.BaseDakShellVelocity = 5000
			self.DakIsFlechette = false
			self.DakPellets = 10

			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.ReloadSound = "daktanks/dakreloadlight.wav"

			self.DakFireSound = "daktanks/flamerfire.wav"
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
		if self.DakName == "Flamethrower" then
			WireLib.TriggerOutput(self, "AmmoType", "Fuel")
		else
			WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing")
		end
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

						if i==1 then
							shell:SetNWString("FireSound",self.DakFireSound)
							shell:SetNWInt("FirePitch",self.DakFirePitch)
						else
							shell:SetNWString("FireSound","")
							shell:SetNWInt("FirePitch",self.DakFirePitch)
						end
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
					if self.DakName == "Flamethrower" then
						shell.DakIsFlame = 1
					end

					shell.DakBasePenetration = self.BaseDakShellPenetration

					shell.DakCaliber = self.DakMaxHealth
					
					shell:SetNWString("FireSound",self.DakFireSound)
					shell:SetNWInt("FirePitch",self.DakFirePitch)
					shell.DakGun = self
					shell:Spawn()
				end

				local effectdata = EffectData()
				effectdata:SetOrigin( self:GetAttachment( 1 ).Pos )
				effectdata:SetAngles( self:GetAngles() )
				effectdata:SetEntity(self)
				effectdata:SetScale( self.BaseDakShellDamage )
				util.Effect( self.DakFireEffect, effectdata )

				--self:EmitSound( self.DakFireSound, 100, self.DakFirePitch, 1, 6)
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
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakModel = self.DakModel
	info.DakOwner = self.DakOwner
	info.DakColor = self:GetColor()
	info.DakCaliber = self.DakCaliber
	info.DakGunType = self.DakGunType

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
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakModel = Ent.EntityMods.DakTek.DakModel
		self.DakCaliber = Ent.EntityMods.DakTek.DakCaliber
		self.DakGunType = Ent.EntityMods.DakTek.DakGunType
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
