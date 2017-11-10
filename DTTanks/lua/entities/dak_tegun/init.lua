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
ENT.DakCrew = NULL

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
	self.Inputs = Wire_CreateInputs(self, { "Fire", "SwapAmmo" })
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
		if self.DakGunType == "Cannon" then
			self.DakName = self.DakCaliber.."mm Cannon"
			self.DakCooldown = math.Round((self.DakCaliber/13 + self.DakCaliber/100),2)
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round((9000/((200/self.DakCaliber)*(200/self.DakCaliber))))

			self.DakAP = math.Round(self.DakCaliber,2).."mmCAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmCHEAmmo"
			self.DakFL = math.Round(self.DakCaliber,2).."mmCFLAmmo"

			self.BaseDakShellDamage = (self.DakCaliber*0.1)*1.5
			self.BaseDakShellMass = self.DakCaliber
			self.DakShellSplashDamage = (self.DakCaliber*0.1)*1.5*1.25
			self.BaseDakShellPenetration = self.DakCaliber*2
			self.DakShellExplosive = false
			self.DakShellBlastRadius = self.DakCaliber/25*39

			self.DakFireEffect = "dakballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.wav"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.wav"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.wav"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.wav"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.wav"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.wav"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.wav"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.wav"
			end
		end

		if self.DakGunType == "Howitzer" then
			self.DakName = self.DakCaliber.."mm Howitzer"
			self.DakCooldown = math.Round((self.DakCaliber/13 + self.DakCaliber/100)*1.5,2)
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round((9000/((240/self.DakCaliber)*(240/self.DakCaliber))))

			self.DakAP = math.Round(self.DakCaliber,2).."mmHAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmHHEAmmo"
			self.DakFL = math.Round(self.DakCaliber,2).."mmHFLAmmo"

			self.BaseDakShellDamage = self.DakCaliber/5
			self.BaseDakShellMass = self.DakCaliber
			self.DakShellSplashDamage = self.DakCaliber/5*1.5
			self.BaseDakShellPenetration = self.DakCaliber*1.5
			self.DakShellExplosive = false
			self.DakShellBlastRadius = self.DakCaliber/12.5*39

			self.DakFireEffect = "dakballisticfire"
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

			if self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/h50.wav"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 105 then
				self.DakFireSound = "daktanks/h75.wav"
			end
			if self.DakCaliber >= 105 and self.DakCaliber < 122 then
				self.DakFireSound = "daktanks/h105.wav"
			end
			if self.DakCaliber >= 122 and self.DakCaliber < 155 then
				self.DakFireSound = "daktanks/h122.wav"
			end
			if self.DakCaliber >= 155 and self.DakCaliber < 203 then
				self.DakFireSound = "daktanks/h155.wav"
			end
			if self.DakCaliber >= 203 and self.DakCaliber < 420 then
				self.DakFireSound = "daktanks/h203.wav"
			end
			if self.DakCaliber >= 420 then
				self.DakFireSound = "daktanks/h420.wav"
			end
		end

		if self.DakGunType == "Mortar" then
			self.DakName = self.DakCaliber.."mm Mortar"
			self.DakCooldown = math.Round((self.DakCaliber/13 + self.DakCaliber/100),2)
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round((4500/((280/self.DakCaliber)*(280/self.DakCaliber))))

			self.DakAP = math.Round(self.DakCaliber,2).."mmMAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmMHEAmmo"
			self.DakFL = math.Round(self.DakCaliber,2).."mmMFLAmmo"

			self.BaseDakShellDamage = self.DakCaliber/20
			self.BaseDakShellMass = self.DakCaliber
			self.DakShellSplashDamage = self.DakCaliber/20*7
			self.BaseDakShellPenetration = self.DakCaliber*0.8
			self.DakShellExplosive = false
			self.DakShellBlastRadius = self.DakCaliber/10*39

			self.DakFireEffect = "dakballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
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

			if self.DakCaliber < 90 then
				self.DakFireSound = "daktanks/m60.wav"
			end
			if self.DakCaliber >= 90 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/m90.wav"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 150 then
				self.DakFireSound = "daktanks/m120.wav"
			end
			if self.DakCaliber >= 150 and self.DakCaliber < 240 then
				self.DakFireSound = "daktanks/m150.wav"
			end
			if self.DakCaliber >= 240 and self.DakCaliber < 280 then
				self.DakFireSound = "daktanks/m240.wav"
			end
			if self.DakCaliber >= 280 and self.DakCaliber < 420 then
				self.DakFireSound = "daktanks/m280.wav"
			end
			if self.DakCaliber >= 420 and self.DakCaliber < 600 then
				self.DakFireSound = "daktanks/m420.wav"
			end
			if self.DakCaliber >= 600 then
				self.DakFireSound = "daktanks/m600.wav"
			end
		end

		self.Loaders = 0

		if self.DakTankCore then
			if #self.DakTankCore.Crew>0 then
				for i=1, #self.DakTankCore.Crew do
					if self.DakTankCore.Crew[i].DakEntity == self then
						self.Loaders = self.Loaders + 1
					end
				end
			end
			if self.Loaders == 0 then
				self.DakCooldown = self.DakCooldown * 1.5
			else
				self.DakCooldown = self.DakCooldown*(1/math.pow((self.Loaders),0.4))
			end
			self.DakCooldown = self.DakCooldown/(2*math.pow( 0.0005,(0.09/(self.DakTankCore.SizeMult))))
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
	if self.CurrentAmmoType == 2 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive")
		self.DakAmmoType = self.DakHE
		self.DakIsFlechette = false
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/2
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.BaseDakShellPenetration*0.4
		self.DakShellVelocity = self.BaseDakShellVelocity
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 3 then
		WireLib.TriggerOutput(self, "AmmoType", "Flechette")
		self.DakAmmoType = self.DakFL
		self.DakIsFlechette = true
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/self.DakPellets
		self.DakShellMass = self.BaseDakShellMass/self.DakPellets
		self.DakShellPenetration = self.BaseDakShellPenetration*0.75
		self.DakShellVelocity = self.BaseDakShellVelocity*0.75
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

					shell.DakBasePenetration = self.BaseDakShellPenetration

					shell.DakCaliber = self.DakMaxHealth

					shell:SetNWString("FireSound",self.DakFireSound)
					shell:SetNWInt("FirePitch",self.DakFirePitch)
					shell.DakGun = self
					shell:Spawn()
				end

				timer.Create( "ReloadFinishTimer"..self:EntIndex()..CurTime(), self.DakCooldown-SoundDuration(self.ReloadSound), 1, function()
					if IsValid(self) then
						self:EmitSound( self.ReloadSound, 60, 100, 1, 6)
					end
				end)

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

function ENT:DakTEGunAmmoSwap()
	if( self.AmmoSwap ) then
		self.CurrentAmmoType = self.CurrentAmmoType+1
		if self.CurrentAmmoType>3 then
			self.CurrentAmmoType = 1
		end
	else
		self.LastSwapTime = CurTime()-1
	end
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
	if self.CurrentAmmoType == 2 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive")
		self.DakAmmoType = self.DakHE
		self.DakIsFlechette = false
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/2
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.BaseDakShellPenetration*0.4
		self.DakShellVelocity = self.BaseDakShellVelocity
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 3 then
		WireLib.TriggerOutput(self, "AmmoType", "Flechette")
		self.DakAmmoType = self.DakFL
		self.DakIsFlechette = true
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/self.DakPellets
		self.DakShellMass = self.BaseDakShellMass/self.DakPellets
		self.DakShellPenetration = self.BaseDakShellPenetration*0.75
		self.DakShellVelocity = self.BaseDakShellVelocity*0.75
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
		if (iname == "SwapAmmo") then
			if(value) then
			self.AmmoSwap = value > 0
			self:DakTEGunAmmoSwap()
			end
		end
	end
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}
	info.CrewID = self.DakCrew:EntIndex()
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
		local Crew = CreatedEntities[ Ent.EntityMods.DakTek.CrewID ]
		if Crew and IsValid(Crew) then
			self.DakCrew = Crew
		end
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
