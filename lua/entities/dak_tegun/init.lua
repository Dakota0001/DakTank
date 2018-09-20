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
ENT.DakAmmoType = ""
ENT.DakFireEffect = ""
ENT.DakFirePitch = 100
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
ENT.DakPenLossPerMeter = 0.0005
ENT.DakPooled=0
ENT.DakArmor = 1
ENT.DakTankCore = nil
ENT.DakCrew = NULL
ENT.ShellList = {}
ENT.BasicVelocity = 29527.6

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
	self.Inputs = Wire_CreateInputs(self, { "Fire", "SwapAmmo", "Indicator [ENTITY]" })
	self.Outputs = WireLib.CreateOutputs( self, { "Cooldown" , "CooldownPercent", "Ammo", "AmmoType [STRING]", "MuzzleVel", "ShellMass", "Penetration" } )
 	self.Held = false
 	self.Soundtime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.MidThinkTime = CurTime()
 	self.LastFireTime = CurTime()
 	self.CurrentAmmoType = 1
 	self.DakBurnStacks = 0
 	self.BasicVelocity = 29527.6
 	self.AutoSwapStacks = 0

	function self:SetupDataTables()
 		self:NetworkVar("Bool",0,"Firing")
 		self:NetworkVar("Float",0,"Timer")
 		self:NetworkVar("Float",1,"Cooldown")
 		self:NetworkVar("String",0,"Model")
 	end

 	self.ShellList = {}
 	self.RemoveList = {}
end

function ENT:Think()
	if CurTime()>=self.SlowThinkTime+1 then
		if self.DakGunType == "Short Cannon" then
			self.DakName = self.DakCaliber.."mm Short Cannon"
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round(((((self.DakCaliber*5)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(self.DakCaliber^2)*(self.DakCaliber*40))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*40)))*0.001*7.8125)/1000)

			self.DakAP = math.Round(self.DakCaliber,2).."mmSCAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmSCHEAmmo"
			self.DakHEAT = math.Round(self.DakCaliber,2).."mmSCHEATAmmo"
			self.DakHESH = math.Round(self.DakCaliber,2).."mmSCHESHAmmo"
			self.DakHVAP = math.Round(self.DakCaliber,2).."mmSCHVAPAmmo"
			self.DakATGM = math.Round(self.DakCaliber,2).."mmSCATGMAmmo"
			self.DakHEATFS = math.Round(self.DakCaliber,2).."mmSCHEATFSAmmo"
			self.DakAPFSDS = math.Round(self.DakCaliber,2).."mmSCAPFSDSAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*5))
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (40/50)
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*5))*7700
			self.DakCooldown = 4*math.sqrt(self.BaseDakShellMass)
			self.DakShellSplashDamage = self.DakCaliber*0.375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/25*39)
			self.DakShellFragPen = (self.DakCaliber/2.5)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
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

			if self.DakFireSound == nil then
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
		end
		if self.DakGunType == "Cannon" then
			self.DakName = self.DakCaliber.."mm Cannon"
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round(((((self.DakCaliber*6.5)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(self.DakCaliber^2)*(self.DakCaliber*50))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*50)))*0.001*7.8125)/1000)

			self.DakAP = math.Round(self.DakCaliber,2).."mmCAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmCHEAmmo"
			self.DakHEAT = math.Round(self.DakCaliber,2).."mmCHEATAmmo"
			self.DakHESH = math.Round(self.DakCaliber,2).."mmCHESHAmmo"
			self.DakHVAP = math.Round(self.DakCaliber,2).."mmCHVAPAmmo"
			self.DakATGM = math.Round(self.DakCaliber,2).."mmCATGMAmmo"
			self.DakHEATFS = math.Round(self.DakCaliber,2).."mmCHEATFSAmmo"
			self.DakAPFSDS = math.Round(self.DakCaliber,2).."mmCAPFSDSAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*6.5))
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*6.5))*7700
			--print((math.pi*((75*0.001*0.5)^2)*(75*0.001*6.5))*7700)
			--print((math.pi*((200*0.001*0.5)^2)*(200*0.001*6.5))*7700)
			
			self.DakCooldown = 4*math.sqrt(self.BaseDakShellMass)
			self.ShellLengthMult = (50/50)
			self.DakShellSplashDamage = self.DakCaliber*0.375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/25*39)
			self.DakShellFragPen = (self.DakCaliber/2.5)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
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

			if self.DakFireSound == nil then
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
		end
		if self.DakGunType == "Long Cannon" then
			self.DakName = self.DakCaliber.."mm Long Cannon"
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round(((((self.DakCaliber*9)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(self.DakCaliber^2)*(self.DakCaliber*70))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*70)))*0.001*7.8125)/1000)

			self.DakAP = math.Round(self.DakCaliber,2).."mmLCAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmLCHEAmmo"
			self.DakHEAT = math.Round(self.DakCaliber,2).."mmLCHEATAmmo"
			self.DakHESH = math.Round(self.DakCaliber,2).."mmLCHESHAmmo"
			self.DakHVAP = math.Round(self.DakCaliber,2).."mmLCHVAPAmmo"
			self.DakATGM = math.Round(self.DakCaliber,2).."mmLCATGMAmmo"
			self.DakHEATFS = math.Round(self.DakCaliber,2).."mmLCHEATFSAmmo"
			self.DakAPFSDS = math.Round(self.DakCaliber,2).."mmLCAPFSDSAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*9))
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (70/50)
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*9))*7700
			self.DakCooldown = 4*math.sqrt(self.BaseDakShellMass)
			self.DakShellSplashDamage = self.DakCaliber*0.375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/25*39)
			self.DakShellFragPen = (self.DakCaliber/2.5)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
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
			if self.DakFireSound == nil then
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
		end

		if self.DakGunType == "Howitzer" then
			self.DakName = self.DakCaliber.."mm Howitzer"
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round(((((self.DakCaliber*4)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(self.DakCaliber^2)*(self.DakCaliber*30))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*30)))*0.001*7.8125)/1000)

			self.DakAP = math.Round(self.DakCaliber,2).."mmHAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmHHEAmmo"
			self.DakHEAT = math.Round(self.DakCaliber,2).."mmHHEATAmmo"
			self.DakHESH = math.Round(self.DakCaliber,2).."mmHHESHAmmo"
			self.DakATGM = math.Round(self.DakCaliber,2).."mmHATGMAmmo"
			self.DakHEATFS = math.Round(self.DakCaliber,2).."mmHHEATFSAmmo"
			self.DakAPFSDS = math.Round(self.DakCaliber,2).."mmHAPFSDSAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*4))
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (30/50)
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*4))*7700
			self.DakCooldown = 4*math.sqrt(self.BaseDakShellMass)
			self.DakShellSplashDamage = self.DakCaliber*0.375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/25*39)*1.3
			self.DakShellFragPen = (self.DakCaliber/2.5)*1.3

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
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

			if self.DakFireSound == nil then
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
		end

		if self.DakGunType == "Mortar" then
			self.DakName = self.DakCaliber.."mm Mortar"
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = math.Round(((((self.DakCaliber*2.75)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(self.DakCaliber^2)*(self.DakCaliber*15))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*15)))*0.001*7.8125)/1000)

			self.DakAP = math.Round(self.DakCaliber,2).."mmMAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmMHEAmmo"
			self.DakHEAT = math.Round(self.DakCaliber,2).."mmMHEATAmmo"
			self.DakHESH = math.Round(self.DakCaliber,2).."mmMHESHAmmo"
			self.DakHEATFS = math.Round(self.DakCaliber,2).."mmMHEATFSAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*2.75))
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (15/50)
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*2.75))*7700
			self.DakCooldown = 4*math.sqrt(self.BaseDakShellMass)
			self.DakShellSplashDamage = self.DakCaliber*0.375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/25*39)*1.15
			self.DakShellFragPen = (self.DakCaliber/2.5)*1.15

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
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

			if self.DakFireSound == nil then
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
		end

		self.Loaders = 0

		if self.DakTankCore then
			if self.DakTankCore.Crew then
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

		self:DakTEAmmoCheck()
		
		self.SlowThinkTime = CurTime()
	end
	if CurTime()>=self.MidThinkTime+0.33 then
		self:DakTEAmmoCheck()

		WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100))
		WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100)/self.DakCooldown))
		self.MidThinkTime = CurTime()
	end

	for i = 1, #self.ShellList do
		self.ShellList[i].LifeTime = self.ShellList[i].LifeTime + 0.1
		--self.ShellList[i].Gravity = physenv.GetGravity()*self.ShellList[i].LifeTime
		
		local trace = {}
			if self.ShellList[i].IsGuided then
				local indicatortrace = {}
					indicatortrace.start = self.ShellList[i].Indicator:GetPos()
					indicatortrace.endpos = self.ShellList[i].Indicator:GetPos() + self.ShellList[i].Indicator:GetForward()*1000000
					indicatortrace.filter = self.ShellList[i].Filter
				local indicator = util.TraceLine(indicatortrace)
				if not(self.ShellList[i].SimPos) then
					self.ShellList[i].SimPos = self.ShellList[i].Pos
				end

				local _, RotatedAngle =	WorldToLocal( Vector(0,0,0), (indicator.HitPos-self.ShellList[i].SimPos):GetNormalized():Angle(), self.ShellList[i].SimPos, self.ShellList[i].Ang )
				local Pitch = math.Clamp(RotatedAngle.p,-10,10)
				local Yaw = math.Clamp(RotatedAngle.y,-10,10)
				local Roll = math.Clamp(RotatedAngle.r,-10,10)
				local _, FlightAngle = LocalToWorld( self.ShellList[i].SimPos, Angle(Pitch,Yaw,Roll), Vector(0,0,0), Angle(0,0,0) )
				self.ShellList[i].Ang = self.ShellList[i].Ang + FlightAngle
				self.ShellList[i].SimPos = self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*0.1)

				trace.start = self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*-0.1)
				trace.endpos = self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*0.1)
			else
				trace.start = self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * (self.ShellList[i].LifeTime-0.1)) - (-physenv.GetGravity()*((self.ShellList[i].LifeTime-0.1)^2)/2)
				trace.endpos = self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * self.ShellList[i].LifeTime) - (-physenv.GetGravity()*(self.ShellList[i].LifeTime^2)/2)
			end
			trace.filter = self.ShellList[i].Filter
			trace.mins = Vector(-self.ShellList[i].DakCaliber*0.02,-self.ShellList[i].DakCaliber*0.02,-self.ShellList[i].DakCaliber*0.02)
			trace.maxs = Vector(self.ShellList[i].DakCaliber*0.02,self.ShellList[i].DakCaliber*0.02,self.ShellList[i].DakCaliber*0.02)
		local ShellTrace = util.TraceHull( trace )

		local effectdata = EffectData()
		effectdata:SetStart(ShellTrace.StartPos)
		effectdata:SetOrigin(ShellTrace.HitPos)
		effectdata:SetScale((self.ShellList[i].DakCaliber*0.0393701))
		util.Effect(self.ShellList[i].DakTrail, effectdata, true, true)

		if ShellTrace.Hit then
			DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,self.ShellList[i],ShellTrace.HitNormal)
		end

		if self.ShellList[i].DieTime then
			if self.ShellList[i].DieTime<CurTime()then
				self.RemoveList[#self.RemoveList+1] = i
			end
		end

		if self.ShellList[i].RemoveNow == 1 then
			self.RemoveList[#self.RemoveList+1] = i
		end

		--self.ShellList[i].Pos = self.ShellList[i].Pos + (self.ShellList[i].Ang:Forward()*self.ShellList[i].DakVelocity*0.1) + (self.ShellList[i].Gravity*0.1)
	end
	
	if #self.RemoveList > 0 then
		for i = 1, #self.RemoveList do
			table.remove( self.ShellList, self.RemoveList[i] )
		end
	end

	self.RemoveList = {}

	self:NextThink( CurTime()+0.1 )
	return true
end

function ENT:DakTEAmmoCheck()
	if self.CurrentAmmoType == 1 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing")
		self.DakAmmoType = self.DakAP
		self.DakShellAmmoType = "AP"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.BaseDakShellPenetration
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0005
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 2 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive")
		self.DakAmmoType = self.DakHE
		self.DakShellAmmoType = "HE"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/2
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*0.2
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0005
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 3 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive Anti Tank")
		self.DakAmmoType = self.DakHEAT
		self.DakShellAmmoType = "HEAT"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*1.20*self.ShellLengthMult
		self.DakShellVelocity = self.BaseDakShellVelocity*0.75
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 4 then
		WireLib.TriggerOutput(self, "AmmoType", "High Velocity Armor Piercing")
		self.DakAmmoType = self.DakHVAP
		self.DakShellAmmoType = "HVAP"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.BaseDakShellPenetration*1.5
		self.DakShellVelocity = self.BaseDakShellVelocity*4/3
		self.DakPenLossPerMeter = 0.001
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 5 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive Squash Head")
		self.DakAmmoType = self.DakHESH
		self.DakShellAmmoType = "HESH"
		self.DakShellExplosive = true
		self.DakShellDamage = 0
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*1.25
		self.DakShellVelocity = self.BaseDakShellVelocity*0.5
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 6 then
		WireLib.TriggerOutput(self, "AmmoType", "Anti Tank Guided Missile")
		self.DakAmmoType = self.DakATGM
		self.DakShellAmmoType = "HEAT"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*6.40*self.ShellLengthMult
		self.DakShellVelocity = 12600
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 7 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive Anti Tank Fin Stabilized")
		self.DakAmmoType = self.DakHEATFS
		self.DakShellAmmoType = "HEATFS"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*5.40*self.ShellLengthMult
		self.DakShellVelocity = self.BaseDakShellVelocity*1.3333
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 8 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing Fin Stabilized Discarding Sabot")
		self.DakAmmoType = self.DakAPFSDS
		self.DakShellAmmoType = "APFSDS"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.BaseDakShellPenetration*5.3*0.5
		self.DakShellVelocity = self.BaseDakShellVelocity*2.227
		self.DakPenLossPerMeter = 0.001
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if IsValid(self.DakTankCore) then
		self.AmmoCount = 0 
		if not(self.DakTankCore.Ammoboxes == nil) then
			for i = 1, #self.DakTankCore.Ammoboxes do
				if IsValid(self.DakTankCore.Ammoboxes[i]) then
					if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
						self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
					end
				end
			end
		end
		if self.AmmoCount == 0 and self.AutoSwapStacks < 5 and IsValid(self) then
			self.AutoSwapStacks = self.AutoSwapStacks + 1
			self.AmmoSwap = true
			self:DakTEGunAmmoSwap()
		else
			self.AutoSwapStacks = 0
		end
		WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
	end
end

function ENT:DakTEFire()
	if( self.Firing ) then
		if IsValid(self.DakTankCore) then
			self.AmmoCount = 0 
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
				
 				local Shell = {}
 				Shell.Pos = shootOrigin + ( self:GetForward() * 1 )
 				Shell.Ang = shootAngles + Angle(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05))
				Shell.DakTrail = self.DakShellTrail
				Shell.DakVelocity = self.DakShellVelocity * math.Rand( 0.99, 1.01 )
				Shell.DakDamage = self.DakShellDamage * math.Rand( 0.75, 1.25 )
				Shell.DakMass = self.DakShellMass
				Shell.DakIsPellet = false
				Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.75, 1.25 )
				Shell.DakPenetration = self.DakShellPenetration * math.Rand( 0.75, 1.25 )
				Shell.DakExplosive = self.DakShellExplosive
				Shell.DakBlastRadius = self.DakShellBlastRadius
				Shell.DakPenSounds = self.DakShellPenSounds
				Shell.DakBasePenetration = self.BaseDakShellPenetration
				Shell.DakFragPen = self.DakShellFragPen
				Shell.DakCaliber = self.DakMaxHealth
				if self.CurrentAmmoType == 4 then
					Shell.DakCaliber = self.DakMaxHealth/2
				end
				if self.CurrentAmmoType == 8 then
					Shell.DakCaliber = self.DakMaxHealth/4
				end					
				Shell.DakFireSound = self.DakFireSound
				Shell.DakFirePitch = self.DakFirePitch
				Shell.DakGun = self
				Shell.Filter = table.Copy(self.DakTankCore.Contraption)
				Shell.LifeTime = 0
				Shell.Gravity = 0
				Shell.DakPenLossPerMeter = self.DakPenLossPerMeter
				Shell.DakShellType = self.DakShellAmmoType
				if self.DakShellAmmoType == "HESH" or self.DakShellAmmoType == "HEAT" or self.DakShellAmmoType == "HEATFS" then
					Shell.DakFragPen = self.DakShellFragPen * 1
					Shell.DakBlastRadius = self.DakShellBlastRadius * 0.5
					Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.75, 1.25 ) * 0.5
				end
				if self.DakName == "Flamethrower" then
					Shell.DakIsFlame = 1
				end

				if self.DakAmmoType == self.DakATGM then
					Shell.IsGuided = true
					Shell.DakTrail = "daktemissiletracer"
					if IsValid(self.Inputs.Indicator.Value) then
						Shell.Indicator = self.Inputs.Indicator.Value
					else
						Shell.Indicator = self
					end
				end

				self.ShellList[#self.ShellList+1] = Shell

				self:SetNWString("FireSound",self.DakFireSound)
				self:SetNWInt("FirePitch",self.DakFirePitch)
				self:SetNWFloat("Caliber",self.DakCaliber)

				if self.DakCaliber>=75 then
					self:SetNWBool("Firing",true)
					timer.Create( "ResoundTimer"..self:EntIndex(), 0.1, 1, function()
						self:SetNWBool("Firing",false)
					end)
				else
					sound.Play( self.DakFireSound, self:GetPos(), 100, 100, 1 )
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
				effectdata:SetScale( self.DakMaxHealth*0.25 )
				util.Effect( self.DakFireEffect, effectdata, true, true)
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
	if IsValid(self.DakTankCore) then
		self.AmmoCount = 0 
		if not(self.DakTankCore.Ammoboxes == nil) then
			for i = 1, #self.DakTankCore.Ammoboxes do
				if IsValid(self.DakTankCore.Ammoboxes[i]) then
					if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
						self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
					end
				end
			end
		end
		if self.AmmoCount == 0 and self.AutoSwapStacks < 5 and IsValid(self) then
			self.AutoSwapStacks = self.AutoSwapStacks + 1
			self.AmmoSwap = true
			self:DakTEGunAmmoSwap()
		else
			self.AutoSwapStacks = 0
		end
		WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
	end
end

function ENT:DakTEGunAmmoSwap()
	if( self.AmmoSwap ) then
		self.CurrentAmmoType = self.CurrentAmmoType+1
		if self.CurrentAmmoType>8 then
			self.CurrentAmmoType = 1
		end
	else
		self.LastSwapTime = CurTime()-1
	end
	if self.CurrentAmmoType == 1 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing")
		self.DakAmmoType = self.DakAP
		self.DakShellAmmoType = "AP"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.BaseDakShellPenetration
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0005
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 2 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive")
		self.DakAmmoType = self.DakHE
		self.DakShellAmmoType = "HE"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/2
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*0.2
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0005
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 3 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive Anti Tank")
		self.DakAmmoType = self.DakHEAT
		self.DakShellAmmoType = "HEAT"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*5.40*self.ShellLengthMult
		self.DakShellVelocity = self.BaseDakShellVelocity*0.75
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 4 then
		WireLib.TriggerOutput(self, "AmmoType", "High Velocity Armor Piercing")
		self.DakAmmoType = self.DakHVAP
		self.DakShellAmmoType = "HVAP"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.BaseDakShellPenetration*1.5
		self.DakShellVelocity = self.BaseDakShellVelocity*4/3
		self.DakPenLossPerMeter = 0.001
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 5 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive Squash Head")
		self.DakAmmoType = self.DakHESH
		self.DakShellAmmoType = "HESH"
		self.DakShellExplosive = true
		self.DakShellDamage = 0
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*1.25
		self.DakShellVelocity = self.BaseDakShellVelocity*0.5
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 6 then
		WireLib.TriggerOutput(self, "AmmoType", "Anti Tank Guided Missile")
		self.DakAmmoType = self.DakATGM
		self.DakShellAmmoType = "HEAT"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*6.40*self.ShellLengthMult
		self.DakShellVelocity = 12600
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 7 then
		WireLib.TriggerOutput(self, "AmmoType", "High Explosive Anti Tank Fin Stabilized")
		self.DakAmmoType = self.DakHEATFS
		self.DakShellAmmoType = "HEATFS"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*5.40*self.ShellLengthMult
		self.DakShellVelocity = self.BaseDakShellVelocity*1.3333
		self.DakPenLossPerMeter = 0.0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 8 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing Fin Stabilized Discarding Sabot")
		self.DakAmmoType = self.DakAPFSDS
		self.DakShellAmmoType = "APFSDS"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.BaseDakShellPenetration*5.3*0.5
		self.DakShellVelocity = self.BaseDakShellVelocity*2.227
		self.DakPenLossPerMeter = 0.001
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if IsValid(self.DakTankCore) then
		self.AmmoCount = 0 
		if not(self.DakTankCore.Ammoboxes == nil) then
			for i = 1, #self.DakTankCore.Ammoboxes do
				if IsValid(self.DakTankCore.Ammoboxes[i]) then
					if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
						self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
					end
				end
			end
		end
		if self.AmmoCount == 0 and self.AutoSwapStacks < 5 and IsValid(self) then
			self.AutoSwapStacks = self.AutoSwapStacks + 1
			self.AmmoSwap = true
			self:DakTEGunAmmoSwap()
		else
			self.AutoSwapStacks = 0
		end
		WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
	end
end


function ENT:TriggerInput(iname, value)
	if IsValid(self.DakTankCore) and hook.Run("DakTankCanFire", self) ~= false then
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
	info.DakFireSound = self.DakFireSound

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
		self.DakFireSound = Ent.EntityMods.DakTek.DakFireSound

		self.DakOwner = Player
		self:SetColor(Ent.EntityMods.DakTek.DakColor)
		self:SetSubMaterial( 0, Ent.EntityMods.DakTek.DakMat0 )
		self:SetSubMaterial( 1, Ent.EntityMods.DakTek.DakMat1 )

		self:Activate()

		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end
