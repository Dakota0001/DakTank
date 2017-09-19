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

	function self:SetupDataTables()
 		self:NetworkVar("Bool",0,"Firing")
 		self:NetworkVar("Float",0,"Timer")
 		self:NetworkVar("Float",1,"Cooldown")
 		self:NetworkVar("String",0,"Model")
 	end

end

function ENT:Think()
	if CurTime()>=self.SlowThinkTime+1 then
		--Cannons
		if self.DakName == "25mm Cannon" then
			self.DakCooldown = 2.0
			self.DakMaxHealth = 25
			self.DakArmor = 125
			self.DakMass = 200
			self.DakAP = "25mmCAPAmmo"
			self.DakHE = "25mmCHEAmmo"
			self.DakFL = "25mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c25.wav"
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
			self.DakShellSplashDamage = 3.125
			self.BaseDakShellPenetration = 50
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 39
			self.DakModel = "models/daktanks/cannon25mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "37mm Cannon" then
			self.DakCooldown = 3
			self.DakMaxHealth = 37
			self.DakArmor = 185
			self.DakMass = 300
			self.DakAP = "37mmCAPAmmo"
			self.DakHE = "37mmCHEAmmo"
			self.DakFL = "37mmCFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/c37.wav"
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
			self.DakShellSplashDamage = 4.625
			self.BaseDakShellPenetration = 74
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 58
			self.DakModel = "models/daktanks/cannon37mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "50mm Cannon" then
			self.DakCooldown = 4
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
			self.DakShellSplashDamage = 6.25
			self.BaseDakShellPenetration = 100
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 79
			self.DakModel = "models/daktanks/cannon50mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "75mm Cannon" then
			self.DakCooldown = 7
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
			self.DakShellSplashDamage = 9.375
			self.BaseDakShellPenetration = 150
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 118
			self.DakModel = "models/daktanks/cannon75mm.mdl"
			self.ReloadSound = "daktanks/dakreloadmedium.wav"
		end
		if self.DakName == "100mm Cannon" then
			self.DakCooldown = 9
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
			self.DakShellSplashDamage = 12.5
			self.BaseDakShellPenetration = 200
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 157
			self.DakModel = "models/daktanks/cannon100mm.mdl"
			self.ReloadSound = "daktanks/dakreloadmedium.wav"
		end
		if self.DakName == "120mm Cannon" then
			self.DakCooldown = 10
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
			self.DakShellSplashDamage = 15
			self.BaseDakShellPenetration = 240
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 189
			self.DakModel = "models/daktanks/cannon120mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "152mm Cannon" then
			self.DakCooldown = 13
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
			self.DakShellSplashDamage = 19
			self.BaseDakShellPenetration = 304
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 239
			self.DakModel = "models/daktanks/cannon152mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "200mm Cannon" then
			self.DakCooldown = 17
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
			self.DakShellSplashDamage = 25
			self.BaseDakShellPenetration = 400
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 315
			self.DakModel = "models/daktanks/cannon200mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		--Howitzers
		if self.DakName == "50mm Howitzer" then
			self.DakCooldown = 5
			self.DakMaxHealth = 50
			self.DakArmor = 150
			self.DakMass = 400
			self.DakAP = "50mmHAPAmmo"
			self.DakHE = "50mmHHEAmmo"
			self.DakFL = "50mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h50.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 10
			self.BaseDakShellMass = 100
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 15
			self.BaseDakShellPenetration = 60
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 157
			self.DakModel = "models/daktanks/howitzer50mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "75mm Howitzer" then
			self.DakCooldown = 8
			self.DakMaxHealth = 75
			self.DakArmor = 225
			self.DakMass = 1200
			self.DakAP = "75mmHAPAmmo"
			self.DakHE = "75mmHHEAmmo"
			self.DakFL = "75mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h75.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 15
			self.BaseDakShellMass = 150
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 22.5
			self.BaseDakShellPenetration = 90
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 236
			self.DakModel = "models/daktanks/howitzer75mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "105mm Howitzer" then
			self.DakCooldown = 11
			self.DakMaxHealth = 105
			self.DakArmor = 315
			self.DakMass = 2400
			self.DakAP = "105mmHAPAmmo"
			self.DakHE = "105mmHHEAmmo"
			self.DakFL = "105mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h105.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 21
			self.BaseDakShellMass = 210
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellSplashDamage = 31.5
			self.BaseDakShellPenetration = 126
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 331
			self.DakModel = "models/daktanks/howitzer105mm.mdl"
			self.ReloadSound = "daktanks/dakreloadmedium.wav"
		end
		if self.DakName == "122mm Howitzer" then
			self.DakCooldown = 13
			self.DakMaxHealth = 122
			self.DakArmor = 366
			self.DakMass = 4000
			self.DakAP = "122mmHAPAmmo"
			self.DakHE = "122mmHHEAmmo"
			self.DakFL = "122mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h122.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 24.4
			self.BaseDakShellMass = 244
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellSplashDamage = 36.6
			self.BaseDakShellPenetration = 146
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 384
			self.DakModel = "models/daktanks/howitzer122mm.mdl"
			self.ReloadSound = "daktanks/dakreloadmedium.wav"
		end
		if self.DakName == "155mm Howitzer" then
			self.DakCooldown = 16
			self.DakMaxHealth = 155
			self.DakArmor = 465
			self.DakMass = 5600
			self.DakAP = "155mmHAPAmmo"
			self.DakHE = "155mmHHEAmmo"
			self.DakFL = "155mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h155.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 31
			self.BaseDakShellMass = 310
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 46.5
			self.BaseDakShellPenetration = 186
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 488
			self.DakModel = "models/daktanks/howitzer155mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "203mm Howitzer" then
			self.DakCooldown = 21
			self.DakMaxHealth = 203
			self.DakArmor = 609
			self.DakMass = 7200
			self.DakAP = "203mmHAPAmmo"
			self.DakHE = "203mmHHEAmmo"
			self.DakFL = "203mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h203.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 40.6
			self.BaseDakShellMass = 406
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 60.9
			self.BaseDakShellPenetration = 243.6
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 639
			self.DakModel = "models/daktanks/howitzer203mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "420mm Howitzer" then
			self.DakCooldown = 44
			self.DakMaxHealth = 420
			self.DakArmor = 1260
			self.DakMass = 14400
			self.DakAP = "420mmHAPAmmo"
			self.DakHE = "420mmHHEAmmo"
			self.DakFL = "420mmHFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/h420.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 31494
			self.BaseDakShellDamage = 84
			self.BaseDakShellMass = 840
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 126
			self.BaseDakShellPenetration = 504
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 1323
			self.DakModel = "models/daktanks/howitzer420mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		--Mortars
		if self.DakName == "60mm Mortar" then
			self.DakCooldown = 7
			self.DakMaxHealth = 60
			self.DakArmor = 120
			self.DakMass = 200
			self.DakAP = "60mmMAPAmmo"
			self.DakHE = "60mmMHEAmmo"
			self.DakFL = "60mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m60.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 3
			self.BaseDakShellMass = 30
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 21
			self.BaseDakShellPenetration = 30
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 189
			self.DakModel = "models/daktanks/mortar60mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "90mm Mortar" then
			self.DakCooldown = 10
			self.DakMaxHealth = 90
			self.DakArmor = 180
			self.DakMass = 400
			self.DakAP = "90mmMAPAmmo"
			self.DakHE = "90mmMHEAmmo"
			self.DakFL = "90mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m90.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 4.5
			self.BaseDakShellMass = 45
			self.DakIsFlechette = false
			self.DakPellets = 10
			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 31.5
			self.BaseDakShellPenetration = 45
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 283
			self.DakModel = "models/daktanks/mortar90mm.mdl"
			self.ReloadSound = "daktanks/dakreloadlight.wav"
		end
		if self.DakName == "120mm Mortar" then
			self.DakCooldown = 14
			self.DakMaxHealth = 120
			self.DakArmor = 240
			self.DakMass = 750
			self.DakAP = "120mmMAPAmmo"
			self.DakHE = "120mmMHEAmmo"
			self.DakFL = "120mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m120.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 6
			self.BaseDakShellMass = 60
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 42
			self.BaseDakShellPenetration = 60
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 378
			self.DakModel = "models/daktanks/mortar120mm.mdl"
			self.ReloadSound = "daktanks/dakreloadmedium.wav"
		end
		if self.DakName == "150mm Mortar" then
			self.DakCooldown = 17
			self.DakMaxHealth = 150
			self.DakArmor = 300
			self.DakMass = 1250
			self.DakAP = "150mmMAPAmmo"
			self.DakHE = "150mmMHEAmmo"
			self.DakFL = "150mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m150.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 7.5
			self.BaseDakShellMass = 75
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			--self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 52.5
			self.BaseDakShellPenetration = 75
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 472
			self.DakModel = "models/daktanks/mortar150mm.mdl"
			self.ReloadSound = "daktanks/dakreloadmedium.wav"
		end
		if self.DakName == "240mm Mortar" then
			self.DakCooldown = 27
			self.DakMaxHealth = 240
			self.DakArmor = 480
			self.DakMass = 2250
			self.DakAP = "240mmMAPAmmo"
			self.DakHE = "240mmMHEAmmo"
			self.DakFL = "240mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m240.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 12
			self.BaseDakShellMass = 120
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 84
			self.BaseDakShellPenetration = 120
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 756
			self.DakModel = "models/daktanks/mortar240mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "280mm Mortar" then
			self.DakCooldown = 32
			self.DakMaxHealth = 280
			self.DakArmor = 560
			self.DakMass = 3000
			self.DakAP = "280mmMAPAmmo"
			self.DakHE = "280mmMHEAmmo"
			self.DakFL = "280mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m280.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 14
			self.BaseDakShellMass = 140
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 98
			self.BaseDakShellPenetration = 140
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 882
			self.DakModel = "models/daktanks/mortar280mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "420mm Mortar" then
			self.DakCooldown = 47
			self.DakMaxHealth = 420
			self.DakArmor = 840
			self.DakMass = 4300
			self.DakAP = "420mmMAPAmmo"
			self.DakHE = "420mmMHEAmmo"
			self.DakFL = "420mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m420.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 21
			self.BaseDakShellMass = 210
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 147
			self.BaseDakShellPenetration = 210
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 1323
			self.DakModel = "models/daktanks/mortar420mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end
		if self.DakName == "600mm Mortar" then
			self.DakCooldown = 68
			self.DakMaxHealth = 600
			self.DakArmor = 1200
			self.DakMass = 8000
			self.DakAP = "600mmMAPAmmo"
			self.DakHE = "600mmMHEAmmo"
			self.DakFL = "600mmMFLAmmo"
			self.DakFireEffect = "dakballisticfire"
			self.DakFireSound = "daktanks/m600.wav"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakshelltrail"
			self.BaseDakShellVelocity = 8398
			self.BaseDakShellDamage = 30
			self.BaseDakShellMass = 300
			self.DakIsFlechette = false
			self.DakPellets = 10
			--self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			--self.DakShellPenSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
			self.DakShellPenSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
			self.DakShellSplashDamage = 210
			self.BaseDakShellPenetration = 300
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 1890
			self.DakModel = "models/daktanks/mortar600mm.mdl"
			self.ReloadSound = "daktanks/dakreloadheavy.wav"
		end

		if self.DakCrew == NULL then
			self.DakCooldown = self.DakCooldown * 1.5
		else
			if not(self.DakCrew.DakEntity == self) then
				self.DakCooldown = self.DakCooldown * 1.5
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
