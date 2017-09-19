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
ENT.DakIsReloading = 0
ENT.DakShotsCounter = 0
ENT.DakClip = 2
ENT.DakReloadTime = 10
ENT.IsAutoLoader = 0
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
	self.Inputs = Wire_CreateInputs(self, { "Fire", "SwapAmmo","Reload" })
	self.Outputs = WireLib.CreateOutputs( self, { "Cooldown" , "CooldownPercent", "Ammo", "ClipRounds", "AmmoType [STRING]", "MuzzleVel", "ShellMass", "Penetration" } )
 	self.Held = false
 	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.LastFireTime = CurTime()
 	self.CurrentAmmoType = 1
 	self.DakIsReloading = 0
	self.DakShotsCounter = 0
	self.DakClip = 1
	self.DakReloadTime = 20
	self.DakLastReload = CurTime()
	self.IsAutoLoader = 0
	self.Loaded=0

	function self:SetupDataTables()
 		self:NetworkVar("Bool",0,"Firing")
 		self:NetworkVar("Float",0,"Timer")
 		self:NetworkVar("Float",1,"Cooldown")
 		self:NetworkVar("String",0,"Model")
 	end

end

function ENT:Think()
	if CurTime()>=self.SlowThinkTime+1 then
		--HMGs
		if self.DakName == "20mm Heavy Machine Gun" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 20
			self.DakArmor = 80
			self.DakMass = 200
			self.DakAP = "20mmHMGAPAmmo"
			self.DakHE = "20mmHMGHEAmmo"
			self.DakFL = "20mmHMGFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/hmg20.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 20996
			self.BaseDakShellDamage = 2
			self.BaseDakShellMass = 20
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 2
			self.BaseDakShellPenetration = 30
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 31
			self.DakClip = 35
			self.DakReloadTime = 20
			self.Loaded=1
			self.DakModel = "models/daktanks/hmg20mm.mdl"
		end
		if self.DakName == "30mm Heavy Machine Gun" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 30
			self.DakArmor = 120
			self.DakMass = 400
			self.DakAP = "30mmHMGAPAmmo"
			self.DakHE = "30mmHMGHEAmmo"
			self.DakFL = "30mmHMGFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/hmg30.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 20996
			self.BaseDakShellDamage = 3
			self.BaseDakShellMass = 30
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 3
			self.BaseDakShellPenetration = 45
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 47
			self.DakClip = 25
			self.DakReloadTime = 20
			self.Loaded=1
			self.DakModel = "models/daktanks/hmg30mm.mdl"
		end
		if self.DakName == "40mm Heavy Machine Gun" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 40
			self.DakArmor = 160
			self.DakMass = 600
			self.DakAP = "40mmHMGAPAmmo"
			self.DakHE = "40mmHMGHEAmmo"
			self.DakFL = "40mmHMGFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/hmg40.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 20996
			self.BaseDakShellDamage = 4
			self.BaseDakShellMass = 40
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 4
			self.BaseDakShellPenetration = 60
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 63
			self.DakClip = 20
			self.DakReloadTime = 20
			self.Loaded=1
			self.DakModel = "models/daktanks/hmg40mm.mdl"
		end
		--AutoCannons
		if self.DakName == "25mm Autocannon" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 25
			self.DakArmor = 125
			self.DakMass = 800
			self.DakAP = "25mmCAPAmmo"
			self.DakHE = "25mmCHEAmmo"
			self.DakFL = "25mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/ac25.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 2.5
			self.BaseDakShellMass = 25
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 2.5
			self.BaseDakShellPenetration = 50
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 39
			self.DakClip = 25
			self.DakReloadTime = 25
			self.Loaded=1
			self.DakModel = "models/daktanks/ac25mm.mdl"
		end
		if self.DakName == "37mm Autocannon" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 37
			self.DakArmor = 185
			self.DakMass = 1200
			self.DakAP = "37mmCAPAmmo"
			self.DakHE = "37mmCHEAmmo"
			self.DakFL = "37mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/ac37.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 3.7
			self.BaseDakShellMass = 37
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 3.7
			self.BaseDakShellPenetration = 74
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 58
			self.DakClip = 15
			self.DakReloadTime = 25
			self.Loaded=1
			self.DakModel = "models/daktanks/ac37mm.mdl"
		end
		if self.DakName == "50mm Autocannon" then
			self.DakCooldown = 0.1
			self.DakMaxHealth = 50
			self.DakArmor = 250
			self.DakMass = 2000
			self.DakAP = "50mmCAPAmmo"
			self.DakHE = "50mmCHEAmmo"
			self.DakFL = "50mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/ac50.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 5
			self.BaseDakShellMass = 50
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 5
			self.BaseDakShellPenetration = 100
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 79
			self.DakClip = 10
			self.DakReloadTime = 25
			self.Loaded=1
			self.DakModel = "models/daktanks/ac50mm.mdl"
		end
		--Autoloaders
		if self.DakName == "50mm Autoloader" then
			self.DakCooldown = 0.9
			self.DakMaxHealth = 50
			self.DakArmor = 250
			self.DakMass = 500
			self.DakAP = "50mmCAPAmmo"
			self.DakHE = "50mmCHEAmmo"
			self.DakFL = "50mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c50.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 5
			self.BaseDakShellMass = 50
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 5
			self.BaseDakShellPenetration = 100
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 79
			self.IsAutoLoader = 1
			self.DakModel = "models/daktanks/al50mm.mdl"
		end
		if self.DakName == "75mm Autoloader" then
			self.DakCooldown = 1.3
			self.DakMaxHealth = 75
			self.DakArmor = 375
			self.DakMass = 1500
			self.DakAP = "75mmCAPAmmo"
			self.DakHE = "75mmCHEAmmo"
			self.DakFL = "75mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c75.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 7.5
			self.BaseDakShellMass = 75
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 7.5
			self.BaseDakShellPenetration = 150
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 118
			self.IsAutoLoader = 1
			self.DakModel = "models/daktanks/al75mm.mdl"
		end
		if self.DakName == "100mm Autoloader" then
			self.DakCooldown = 1.7
			self.DakMaxHealth = 100
			self.DakArmor = 500
			self.DakMass = 3000
			self.DakAP = "100mmCAPAmmo"
			self.DakHE = "100mmCHEAmmo"
			self.DakFL = "100mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c100.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 10
			self.BaseDakShellMass = 100
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellSplashDamage = 10
			self.BaseDakShellPenetration = 200
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 157
			self.IsAutoLoader = 1
			self.DakModel = "models/daktanks/al100mm.mdl"
		end
		if self.DakName == "120mm Autoloader" then
			self.DakCooldown = 2.1
			self.DakMaxHealth = 120
			self.DakArmor = 600
			self.DakMass = 5000
			self.DakAP = "120mmCAPAmmo"
			self.DakHE = "120mmCHEAmmo"
			self.DakFL = "120mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c120.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 12
			self.BaseDakShellMass = 120
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 12
			self.BaseDakShellPenetration = 240
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 189
			self.IsAutoLoader = 1
			self.DakModel = "models/daktanks/al120mm.mdl"
		end
		if self.DakName == "152mm Autoloader" then
			self.DakCooldown = 2.6
			self.DakMaxHealth = 152
			self.DakArmor = 760
			self.DakMass = 7000
			self.DakAP = "152mmCAPAmmo"
			self.DakHE = "152mmCHEAmmo"
			self.DakFL = "152mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c152.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 15.2
			self.BaseDakShellMass = 152
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 15.2
			self.BaseDakShellPenetration = 304
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 239
			self.IsAutoLoader = 1
			self.DakModel = "models/daktanks/al152mm.mdl"
		end
		if self.DakName == "200mm Autoloader" then
			self.DakCooldown = 3.5
			self.DakMaxHealth = 200
			self.DakArmor = 1000
			self.DakMass = 9000
			self.DakAP = "200mmCAPAmmo"
			self.DakHE = "200mmCHEAmmo"
			self.DakFL = "200mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c200.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 41992
			self.BaseDakShellDamage = 20
			self.BaseDakShellMass = 200
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 20
			self.BaseDakShellPenetration = 400
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 315
			self.IsAutoLoader = 1
			self.DakModel = "models/daktanks/al200mm.mdl"
		end

		if not(self.IsAutoLoader == 1) then
			if self.DakCrew == NULL then
				self.DakReloadTime = self.DakReloadTime * 1.5
			else
				if not(self.DakCrew.DakEntity == self) then
					self.DakReloadTime = self.DakReloadTime * 1.5
				end
			end
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

	self:DakTEAutoAmmoCheck()

	WireLib.TriggerOutput(self, "ClipRounds", self.DakClip - self.DakShotsCounter)
	if self.DakIsReloading == 0 then
		WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100))
		WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100)/self.DakCooldown))
	else
		WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.DakLastReload+self.DakReloadTime)-CurTime(),0,100))
		WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.DakLastReload+self.DakReloadTime)-CurTime(),0,100)/self.DakReloadTime))
	end

	self:NextThink( CurTime()+0.33 )
	return true
end

function ENT:DakTEAutoAmmoCheck()
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
		self.DakShellPenetration = self.BaseDakShellPenetration*0.2
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

function ENT:DakTEAutoFire()
	if self.Firing and self.DakIsReloading==0 and self.Loaded==1 then
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

				self.DakShotsCounter = self.DakShotsCounter + 1
				if self.DakShotsCounter >= self.DakClip then
					self.DakIsReloading = 1
					self.DakShotsCounter = 0
					self.DakLastReload = CurTime()
					self:EmitSound( "daktanks/dakreload.wav", 60, 100, 1, 6)
					timer.Create( "ReloadFinishTimer"..self:EntIndex()..CurTime(), self.DakReloadTime-2, 1, function()
						if IsValid(self) then
							self:EmitSound( "daktanks/dakreloadfinish.wav", 60, 100, 1, 6)
						end
					end)
					timer.Create( "ReloadTimer"..self:EntIndex()..CurTime(), self.DakReloadTime, 1, function()
						if IsValid(self) then
							if self.DakIsReloading == 1 then
								self.DakIsReloading = 0
							end
						end
					end)
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

function ENT:DakTEAutoGunAmmoSwap()
	if( self.AmmoSwap ) then
		self.CurrentAmmoType = self.CurrentAmmoType+1
		if self.CurrentAmmoType>2 then
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
		self.DakShellPenetration = self.BaseDakShellPenetration*0.2
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

function ENT:DakTEAutoGunReload()
	if self.DakShotsCounter > 0 then
		self.DakIsReloading = 1
		self.DakShotsCounter = 0
		self.DakLastReload = CurTime()
		self:EmitSound( "daktanks/dakreload.wav", 60, 100, 1, 6)
		timer.Create( "ReloadFinishTimer"..self:EntIndex()..CurTime(), self.DakReloadTime-2, 1, function()
			if IsValid(self) then
				self:EmitSound( "daktanks/dakreloadfinish.wav", 60, 100, 1, 6)
			end
		end)
		timer.Create( "ReloadTimer"..self:EntIndex()..CurTime(), self.DakReloadTime, 1, function()
			if IsValid(self) then
				if self.DakIsReloading == 1 then
					self.DakIsReloading = 0
				end
			end
		end)
	end
end


function ENT:TriggerInput(iname, value)
	if IsValid(self.DakTankCore) then
		self.Held = value
		if (iname == "Fire") then
			if value>0 then
				self:DakTEAutoFire()
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
			self:DakTEAutoGunAmmoSwap()
			end
		end
		if (iname == "Reload") then
			if value>0 then
				self:DakTEAutoGunReload()
			end
		end
	end
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}
	info.CrewID = self.DakCrew:EntIndex()
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
		local Crew = CreatedEntities[ Ent.EntityMods.DakTek.CrewID ]
		if Crew and IsValid(Crew) then
			self.DakCrew = Crew
		end
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
