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
ENT.BasicVelocity = 29527.6

function ENT:Initialize()
	--self:SetModel(self.DakModel)
	self.DakHealth = self.DakMaxHealth
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	----local phys = self:GetPhysicsObject()
	self.timer = CurTime()
	
	self.Inputs = Wire_CreateInputs(self, { "Fire", "SwapAmmo", "Indicator [ENTITY]" })
	self.Outputs = WireLib.CreateOutputs( self, { "Cooldown" , "CooldownPercent", "MaxCooldown", "Ammo", "AmmoType [STRING]", "MuzzleVel", "ShellMass", "Penetration" } )
 	self.Held = false
 	self.Soundtime = CurTime()
 	self.SlowThinkTime = 0
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

 	self.CooldownDistanceModifier = 1
 	self.CooldownWeightMod = 5000
 	self:SetNWFloat("Caliber",self.DakCaliber)

end

function ENT:Think()
	if not(self:GetModel() == self.DakModel) then
		self:SetModel(self.DakModel)
		--self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end
	if IsValid(self.DakTankCore) then
		if self.ScalingFinished == nil then
			local ScalingGun = 0
			if self.DakModel == "models/daktanks/mortar100mm2.mdl" then ScalingGun = 1 end
			if self.DakModel == "models/daktanks/grenadelauncher100mm.mdl" then ScalingGun = 1 end
			if self.DakModel == "models/daktanks/smokelauncher100mm.mdl" then ScalingGun = 1 end
			if self.DakModel == "models/daktanks/machinegun100mm.mdl" then ScalingGun = 1 end
			if ScalingGun == 1 then
				local Caliber = self.DakCaliber
				self:SetModelScale(1)
				self:SetModelScale( self:GetModelScale() * (Caliber/100), 0 )
				self:EnableCustomCollisions( true )
				self:Activate()
				self.ScalingFinished = true
			else
				self.ScalingFinished = true
			end
			if self:GetParent():IsValid() == false then
				self.DakOwner:ChatPrint("Parenting Error on "..self.DakName..". Please reparent, make sure the gate is parented to the aimer prop and the gun is parented to the gate.")
			else
				if self:GetParent():GetParent():IsValid() == false then
					self.DakOwner:ChatPrint("Parenting Error on "..self.DakName..". Please reparent, make sure the gate is parented to the aimer prop and the gun is parented to the gate.")
				end
			end
		end
	end
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
			self.DakAPHE = math.Round(self.DakCaliber,2).."mmSCAPHEAmmo"
			self.DakAPDS = math.Round(self.DakCaliber,2).."mmSCAPDSAmmo"
			self.DakSM = math.Round(self.DakCaliber,2).."mmSCSMAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*5))*25
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (40/50)
			self.ShellLengthExact = 5
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*5))*self.CooldownWeightMod
			self.DakCooldown = (0.2484886*self.BaseDakShellMass+1.279318)*self.CooldownDistanceModifier
			self.DakShellSplashDamage = self.DakCaliber*5
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			--self.DakShellExplosive = false
			self.DakShellBlastRadius = (((self.DakCaliber/155)*50)*39)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)
			self.DakBaseShellFragPen = (2.137015-0.1086095*self.DakCaliber+0.002989107*self.DakCaliber^2)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
			self.DakPellets = 10

			if self.DakCaliber <= 75 then
				self.DakShellPenSounds = {"daktanks/daksmallpen1.mp3","daktanks/daksmallpen2.mp3","daktanks/daksmallpen3.mp3","daktanks/daksmallpen4.mp3"}
				self.ReloadSound = "daktanks/dakreloadlight.mp3"
			end
			if self.DakCaliber > 75 and self.DakCaliber < 120 then
				self.DakShellPenSounds = {"daktanks/dakmedpen1.mp3","daktanks/dakmedpen2.mp3","daktanks/dakmedpen3.mp3","daktanks/dakmedpen4.mp3","daktanks/dakmedpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadmedium.mp3"
			end
			if self.DakCaliber >= 120 then
				self.DakShellPenSounds = {"daktanks/dakhevpen1.mp3","daktanks/dakhevpen2.mp3","daktanks/dakhevpen3.mp3","daktanks/dakhevpen4.mp3","daktanks/dakhevpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadheavy.mp3"
			end

			if self.DakFireSound1 == nil then
				if self.DakCaliber < 37 then
					self.DakFireSound1 = "daktanks/c25.mp3"
				end
				if self.DakCaliber >= 37 and self.DakCaliber < 50 then
					self.DakFireSound1 = "daktanks/c37.mp3"
				end
				if self.DakCaliber >= 50 and self.DakCaliber < 75 then
					self.DakFireSound1 = "daktanks/c50.mp3"
				end
				if self.DakCaliber >= 75 and self.DakCaliber < 100 then
					self.DakFireSound1 = "daktanks/c75.mp3"
				end
				if self.DakCaliber >= 100 and self.DakCaliber < 120 then
					self.DakFireSound1 = "daktanks/c100.mp3"
				end
				if self.DakCaliber >= 120 and self.DakCaliber < 152 then
					self.DakFireSound1 = "daktanks/c120.mp3"
				end
				if self.DakCaliber >= 152 and self.DakCaliber < 200 then
					self.DakFireSound1 = "daktanks/c152.mp3"
				end
				if self.DakCaliber >= 200 then
					self.DakFireSound1 = "daktanks/c200.mp3"
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
			self.DakAPHE = math.Round(self.DakCaliber,2).."mmCAPHEAmmo"
			self.DakAPDS = math.Round(self.DakCaliber,2).."mmCAPDSAmmo"
			self.DakSM = math.Round(self.DakCaliber,2).."mmCSMAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*6.5))*25
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*6.5))*self.CooldownWeightMod
			--print((math.pi*((75*0.001*0.5)^2)*(75*0.001*6.5))*7700)
			--print((math.pi*((200*0.001*0.5)^2)*(200*0.001*6.5))*7700)
			self.DakCooldown = (0.2484886*self.BaseDakShellMass+1.279318)*self.CooldownDistanceModifier
			self.ShellLengthMult = (50/50)
			self.ShellLengthExact = 6.5
			self.DakShellSplashDamage = self.DakCaliber*5
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			--self.DakShellExplosive = false
			self.DakShellBlastRadius = (((self.DakCaliber/155)*50)*39)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)
			self.DakBaseShellFragPen = (2.137015-0.1086095*self.DakCaliber+0.002989107*self.DakCaliber^2)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
			self.DakPellets = 10

			if self.DakCaliber <= 75 then
				self.DakShellPenSounds = {"daktanks/daksmallpen1.mp3","daktanks/daksmallpen2.mp3","daktanks/daksmallpen3.mp3","daktanks/daksmallpen4.mp3"}
				self.ReloadSound = "daktanks/dakreloadlight.mp3"
			end
			if self.DakCaliber > 75 and self.DakCaliber < 120 then
				self.DakShellPenSounds = {"daktanks/dakmedpen1.mp3","daktanks/dakmedpen2.mp3","daktanks/dakmedpen3.mp3","daktanks/dakmedpen4.mp3","daktanks/dakmedpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadmedium.mp3"
			end
			if self.DakCaliber >= 120 then
				self.DakShellPenSounds = {"daktanks/dakhevpen1.mp3","daktanks/dakhevpen2.mp3","daktanks/dakhevpen3.mp3","daktanks/dakhevpen4.mp3","daktanks/dakhevpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadheavy.mp3"
			end

			if self.DakFireSound1 == nil then
				if self.DakCaliber < 37 then
					self.DakFireSound1 = "daktanks/c25.mp3"
				end
				if self.DakCaliber >= 37 and self.DakCaliber < 50 then
					self.DakFireSound1 = "daktanks/c37.mp3"
				end
				if self.DakCaliber >= 50 and self.DakCaliber < 75 then
					self.DakFireSound1 = "daktanks/c50.mp3"
				end
				if self.DakCaliber >= 75 and self.DakCaliber < 100 then
					self.DakFireSound1 = "daktanks/c75.mp3"
				end
				if self.DakCaliber >= 100 and self.DakCaliber < 120 then
					self.DakFireSound1 = "daktanks/c100.mp3"
				end
				if self.DakCaliber >= 120 and self.DakCaliber < 152 then
					self.DakFireSound1 = "daktanks/c120.mp3"
				end
				if self.DakCaliber >= 152 and self.DakCaliber < 200 then
					self.DakFireSound1 = "daktanks/c152.mp3"
				end
				if self.DakCaliber >= 200 then
					self.DakFireSound1 = "daktanks/c200.mp3"
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
			self.DakAPHE = math.Round(self.DakCaliber,2).."mmLCAPHEAmmo"
			self.DakAPDS = math.Round(self.DakCaliber,2).."mmLCAPDSAmmo"
			self.DakSM = math.Round(self.DakCaliber,2).."mmLCSMAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*9))*25
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (70/50)
			self.ShellLengthExact = 9
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*9))*self.CooldownWeightMod
			self.DakCooldown = (0.2484886*self.BaseDakShellMass+1.279318)*self.CooldownDistanceModifier
			self.DakShellSplashDamage = self.DakCaliber*5
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			--self.DakShellExplosive = false
			self.DakShellBlastRadius = (((self.DakCaliber/155)*50)*39)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)
			self.DakBaseShellFragPen = (2.137015-0.1086095*self.DakCaliber+0.002989107*self.DakCaliber^2)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
			self.DakPellets = 10

			if self.DakCaliber <= 75 then
				self.DakShellPenSounds = {"daktanks/daksmallpen1.mp3","daktanks/daksmallpen2.mp3","daktanks/daksmallpen3.mp3","daktanks/daksmallpen4.mp3"}
				self.ReloadSound = "daktanks/dakreloadlight.mp3"
			end
			if self.DakCaliber > 75 and self.DakCaliber < 120 then
				self.DakShellPenSounds = {"daktanks/dakmedpen1.mp3","daktanks/dakmedpen2.mp3","daktanks/dakmedpen3.mp3","daktanks/dakmedpen4.mp3","daktanks/dakmedpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadmedium.mp3"
			end
			if self.DakCaliber >= 120 then
				self.DakShellPenSounds = {"daktanks/dakhevpen1.mp3","daktanks/dakhevpen2.mp3","daktanks/dakhevpen3.mp3","daktanks/dakhevpen4.mp3","daktanks/dakhevpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadheavy.mp3"
			end
			if self.DakFireSound1 == nil then
				if self.DakCaliber < 37 then
					self.DakFireSound1 = "daktanks/c25.mp3"
				end
				if self.DakCaliber >= 37 and self.DakCaliber < 50 then
					self.DakFireSound1 = "daktanks/c37.mp3"
				end
				if self.DakCaliber >= 50 and self.DakCaliber < 75 then
					self.DakFireSound1 = "daktanks/c50.mp3"
				end
				if self.DakCaliber >= 75 and self.DakCaliber < 100 then
					self.DakFireSound1 = "daktanks/c75.mp3"
				end
				if self.DakCaliber >= 100 and self.DakCaliber < 120 then
					self.DakFireSound1 = "daktanks/c100.mp3"
				end
				if self.DakCaliber >= 120 and self.DakCaliber < 152 then
					self.DakFireSound1 = "daktanks/c120.mp3"
				end
				if self.DakCaliber >= 152 and self.DakCaliber < 200 then
					self.DakFireSound1 = "daktanks/c152.mp3"
				end
				if self.DakCaliber >= 200 then
					self.DakFireSound1 = "daktanks/c200.mp3"
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
			self.DakAPHE = math.Round(self.DakCaliber,2).."mmHAPHEAmmo"
			self.DakAPDS = math.Round(self.DakCaliber,2).."mmHAPDSAmmo"
			self.DakSM = math.Round(self.DakCaliber,2).."mmHSMAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*4))*25
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (30/50)
			self.ShellLengthExact = 4
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*4))*self.CooldownWeightMod
			self.DakCooldown = (0.2484886*self.BaseDakShellMass+1.279318)*self.CooldownDistanceModifier
			self.DakShellSplashDamage = self.DakCaliber*5
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			--self.DakShellExplosive = false
			self.DakShellBlastRadius = (((self.DakCaliber/155)*50)*39)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)
			self.DakBaseShellFragPen = (2.137015-0.1086095*self.DakCaliber+0.002989107*self.DakCaliber^2)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
			self.DakPellets = 10

			if self.DakCaliber <= 75 then
				self.DakShellPenSounds = {"daktanks/daksmallpen1.mp3","daktanks/daksmallpen2.mp3","daktanks/daksmallpen3.mp3","daktanks/daksmallpen4.mp3"}
				self.ReloadSound = "daktanks/dakreloadlight.mp3"
			end
			if self.DakCaliber > 75 and self.DakCaliber < 120 then
				self.DakShellPenSounds = {"daktanks/dakmedpen1.mp3","daktanks/dakmedpen2.mp3","daktanks/dakmedpen3.mp3","daktanks/dakmedpen4.mp3","daktanks/dakmedpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadmedium.mp3"
			end
			if self.DakCaliber >= 120 then
				self.DakShellPenSounds = {"daktanks/dakhevpen1.mp3","daktanks/dakhevpen2.mp3","daktanks/dakhevpen3.mp3","daktanks/dakhevpen4.mp3","daktanks/dakhevpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadheavy.mp3"
			end

			if self.DakFireSound1 == nil then
				if self.DakCaliber < 75 then
					self.DakFireSound1 = "daktanks/h50.mp3"
				end
				if self.DakCaliber >= 75 and self.DakCaliber < 105 then
					self.DakFireSound1 = "daktanks/h75.mp3"
				end
				if self.DakCaliber >= 105 and self.DakCaliber < 122 then
					self.DakFireSound1 = "daktanks/h105.mp3"
				end
				if self.DakCaliber >= 122 and self.DakCaliber < 155 then
					self.DakFireSound1 = "daktanks/h122.mp3"
				end
				if self.DakCaliber >= 155 and self.DakCaliber < 203 then
					self.DakFireSound1 = "daktanks/h155.mp3"
				end
				if self.DakCaliber >= 203 and self.DakCaliber < 420 then
					self.DakFireSound1 = "daktanks/h203.mp3"
				end
				if self.DakCaliber >= 420 then
					self.DakFireSound1 = "daktanks/h420.mp3"
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
			self.DakAPHE = math.Round(self.DakCaliber,2).."mmMAPHEAmmo"
			self.DakATGM = math.Round(self.DakCaliber,2).."mmMATGMAmmo"
			self.DakSM = math.Round(self.DakCaliber,2).."mmMSMAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*2.75))*25
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Long Cannon - 9, Cannon - 6.5, Short Cannon - 5, Howitzer - 4, Mortar - 2.75
			self.ShellLengthMult = (15/50)
			self.ShellLengthExact = 2.75
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*2.75))*self.CooldownWeightMod
			self.DakCooldown = (0.2484886*self.BaseDakShellMass+1.279318)*self.CooldownDistanceModifier
			self.DakShellSplashDamage = self.DakCaliber*5
			self.BaseDakShellPenetration = (self.DakCaliber*2)*self.ShellLengthMult
			--self.DakShellExplosive = false
			self.DakShellBlastRadius = (((self.DakCaliber/155)*50)*39)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)
			self.DakBaseShellFragPen = (2.137015-0.1086095*self.DakCaliber+0.002989107*self.DakCaliber^2)*(-0.005372093*(self.ShellLengthMult*50)+1.118186)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity*self.ShellLengthMult
			self.DakPellets = 10

			if self.DakCaliber <= 75 then
				self.DakShellPenSounds = {"daktanks/daksmallpen1.mp3","daktanks/daksmallpen2.mp3","daktanks/daksmallpen3.mp3","daktanks/daksmallpen4.mp3"}
				self.ReloadSound = "daktanks/dakreloadlight.mp3"
			end
			if self.DakCaliber > 75 and self.DakCaliber < 120 then
				self.DakShellPenSounds = {"daktanks/dakmedpen1.mp3","daktanks/dakmedpen2.mp3","daktanks/dakmedpen3.mp3","daktanks/dakmedpen4.mp3","daktanks/dakmedpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadmedium.mp3"
			end
			if self.DakCaliber >= 120 then
				self.DakShellPenSounds = {"daktanks/dakhevpen1.mp3","daktanks/dakhevpen2.mp3","daktanks/dakhevpen3.mp3","daktanks/dakhevpen4.mp3","daktanks/dakhevpen5.mp3"}
				self.ReloadSound = "daktanks/dakreloadheavy.mp3"
			end

			if self.DakFireSound1 == nil then
				if self.DakCaliber < 90 then
					self.DakFireSound1 = "daktanks/m60.mp3"
				end
				if self.DakCaliber >= 90 and self.DakCaliber < 120 then
					self.DakFireSound1 = "daktanks/m90.mp3"
				end
				if self.DakCaliber >= 120 and self.DakCaliber < 150 then
					self.DakFireSound1 = "daktanks/m120.mp3"
				end
				if self.DakCaliber >= 150 and self.DakCaliber < 240 then
					self.DakFireSound1 = "daktanks/m150.mp3"
				end
				if self.DakCaliber >= 240 and self.DakCaliber < 280 then
					self.DakFireSound1 = "daktanks/m240.mp3"
				end
				if self.DakCaliber >= 280 and self.DakCaliber < 420 then
					self.DakFireSound1 = "daktanks/m280.mp3"
				end
				if self.DakCaliber >= 420 and self.DakCaliber < 600 then
					self.DakFireSound1 = "daktanks/m420.mp3"
				end
				if self.DakCaliber >= 600 then
					self.DakFireSound1 = "daktanks/m600.mp3"
				end
			end
		end

		if self.DakAmmoType == self.DakATGM then
			if self.DakCaliber ~= nil then
				self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*6.5))*self.CooldownWeightMod
				self.DakCooldown = 0.75*self.BaseDakShellMass*self.CooldownDistanceModifier
			end
		end

		if not(self.BaseDakShellDamage==nil) then self.DakShellSplashDamage = self.BaseDakShellDamage/2 end
		self.Loaders = 0
		if self.DakTankCore and self.TurretController then
			if self.DakTankCore.Crew then
				if #self.DakTankCore.Crew>0 then
					for i=1, #self.DakTankCore.Crew do
						if self.DakTankCore.Crew[i].DakEntity == self then
							if IsValid(self.TurretController.TurretBase) and self.TurretController:GetYawMin()>45 and self.TurretController:GetYawMax()>45 then
								if self.DakTankCore.Crew[i]:IsValid() then
									if self.DakTankCore.Crew[i]:GetParent():IsValid() then
										if self.DakTankCore.Crew[i]:GetParent():GetParent():IsValid() then
											if self.DakTankCore.Crew[i]:GetParent():GetParent() == self.TurretController.TurretBase or self.DakTankCore.Crew[i]:GetParent():GetParent() == self:GetParent():GetParent() then
												self.Loaders = self.Loaders + 1	
											end
										end
									end
								end
							else
								self.Loaders = self.Loaders + 1	
							end
						end
					end
				end
				if self.Loaders < math.Max(math.Round( self.BaseDakShellMass/25 ) , 1) then
					self.DakCooldown = self.DakCooldown / (1/(math.Max(math.Round( self.BaseDakShellMass/25 ) , 1)+1))
				end
			end
		end

		if self:GetParent():IsValid() and self:GetParent():GetParent():IsValid() and self.Controller~=nil then
			local BackDist = DTSimpleRecurseTrace((self:GetPos()+self:GetForward()*self:OBBMins().x) , (self:GetPos()+self:GetForward()*self:OBBMins().x)-(self:GetForward()*1000), self.DakCaliber, {self, self:GetParent(), self:GetParent():GetParent()}, self)
			local LeftDist = DTSimpleRecurseTrace((self:GetPos()+self:GetForward()*self:OBBMins().x) , (self:GetPos()+self:GetForward()*self:OBBMins().x)-(self:GetRight()*1000), self.DakCaliber, {self, self:GetParent(), self:GetParent():GetParent()}, self)
			local RightDist = DTSimpleRecurseTrace((self:GetPos()+self:GetForward()*self:OBBMins().x) , (self:GetPos()+self:GetForward()*self:OBBMins().x)+(self:GetRight()*1000), self.DakCaliber, {self, self:GetParent(), self:GetParent():GetParent()}, self)
			local UpDist = DTSimpleRecurseTrace((self:GetPos()+self:GetForward()*self:OBBMins().x) , (self:GetPos()+self:GetForward()*self:OBBMins().x)+(self:GetUp()*1000), self.DakCaliber, {self, self:GetParent(), self:GetParent():GetParent()}, self)
			local DownDist = DTSimpleRecurseTrace((self:GetPos()+self:GetForward()*self:OBBMins().x) , (self:GetPos()+self:GetForward()*self:OBBMins().x)-(self:GetUp()*1000), self.DakCaliber, {self, self:GetParent(), self:GetParent():GetParent()}, self)
			local ShellSize = (self.ShellLengthMult*10*self.DakCaliber*0.0393701)
			if self.ReloadMult == nil then
				local quickmult = ( math.min((BackDist/ShellSize),2) + math.min((LeftDist/ShellSize),2) + math.min((RightDist/ShellSize),2) + math.min((UpDist/ShellSize),2) + math.min((DownDist/ShellSize),2) )*0.2
				self.DakOwner:ChatPrint("Reload speed on "..self.DakName.." #"..self:EntIndex().." at default position: "..(math.Round(quickmult,2)*100).."%.")
				if math.Round(BackDist,2) < math.Round(ShellSize,2) then
					self.DakOwner:ChatPrint("WARNING: "..self.DakName.." #"..self:EntIndex().." does not have ample room to load shell, reload time doubled. Required space behind breech: "..math.Round(ShellSize,2).." inches, given space: "..math.Round(BackDist,2).." inches.")
				end
			end
			self.ReloadMult = ( math.min((BackDist/ShellSize),2) + math.min((LeftDist/ShellSize),2) + math.min((RightDist/ShellSize),2) + math.min((UpDist/ShellSize),2) + math.min((DownDist/ShellSize),2) )*0.2
			self.DakCooldown = self.DakCooldown / self.ReloadMult
			if math.Round(BackDist,2) < math.Round(ShellSize,2) then
				self.DakCooldown = self.DakCooldown * 2
			end
		end

		if self.DakHealth > self.DakMaxHealth then
			self.DakHealth = self.DakMaxHealth
		end
		if self.DakFireSound2 == nil then
			self.DakFireSound2 = self.DakFireSound1
		end
		if self.DakFireSound3 == nil then
			self.DakFireSound3 = self.DakFireSound1
		end
		if self:GetPhysicsObject():GetMass() ~= self.DakMass then self:GetPhysicsObject():SetMass(self.DakMass) end

		self:DakTEAmmoCheck()
		
		self.SlowThinkTime = CurTime()
	end
	if CurTime()>=self.MidThinkTime+0.33 and self.BaseDakShellDamage ~= nil then
		self:DakTEAmmoCheck()

		WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100))
		WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100)/self.DakCooldown))
		WireLib.TriggerOutput(self, "MaxCooldown",self.DakCooldown)
		self.MidThinkTime = CurTime()
	end

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
		self.DakShellFragPen = 0
		self.CooldownWeightMod = 5150
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
		self.DakShellFragPen = self.DakBaseShellFragPen*0.1
		self.CooldownWeightMod = 5350
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
		self.DakShellPenetration = self.DakMaxHealth*1.20
		if self.DakTankCore.ColdWar and self.DakTankCore.Modern then
			if self.DakTankCore.ColdWar == 1 or self.DakTankCore.Modern == 1 then
				self.DakShellPenetration = self.DakMaxHealth*5.4*0.431
			end
		end
		self.DakShellVelocity = self.BaseDakShellVelocity*0.75
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = self.DakBaseShellFragPen*0.75*0.1
		self.CooldownWeightMod = 3550
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
		self.DakShellFragPen = 0
		self.CooldownWeightMod = 3725
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
		self.DakShellPenetration = self.DakMaxHealth*0.05
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = 0
		self.CooldownWeightMod = 3450
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 6 then
		WireLib.TriggerOutput(self, "AmmoType", "Anti Tank Guided Missile")
		self.DakAmmoType = self.DakATGM
		self.DakShellAmmoType = "HEATFS"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*6.40
		if self.DakTankCore.ColdWar and self.DakTankCore.Modern then
			if self.DakTankCore.ColdWar == 1 and self.DakTankCore.Modern == 0 then
				self.DakShellPenetration = self.DakMaxHealth*6.40*0.45
			end
		end
		self.DakShellVelocity = 12600
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = self.DakBaseShellFragPen*0.75*0.1
		self.CooldownWeightMod = 3550
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
		self.DakShellPenetration = self.DakMaxHealth*5.40
		if self.DakTankCore.ColdWar and self.DakTankCore.Modern then
			if self.DakTankCore.ColdWar == 1 and self.DakTankCore.Modern == 0 then
				self.DakShellPenetration = self.DakMaxHealth*5.40*0.658
			end
		end
		self.DakShellVelocity = self.BaseDakShellVelocity*1.3333
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = self.DakBaseShellFragPen*0.75*0.1
		self.CooldownWeightMod = 3550
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
		self.DakShellPenetration = self.BaseDakShellPenetration*7.8*0.5
		self.DakShellVelocity = self.BaseDakShellVelocity*2.394
		self.DakPenLossPerMeter = 0.001
		self.DakShellFragPen = 0
		self.CooldownWeightMod = 2750
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 9 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing High Explosive")
		self.DakAmmoType = self.DakAPHE
		self.DakShellAmmoType = "APHE"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*1.65
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0005
		self.DakShellFragPen = self.DakBaseShellFragPen*0.1
		self.CooldownWeightMod = 5450
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 10 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing Discarding Sabot")
		self.DakAmmoType = self.DakAPDS
		self.DakShellAmmoType = "APDS"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.BaseDakShellPenetration*1.67
		self.DakShellVelocity = self.BaseDakShellVelocity*4/3
		self.DakPenLossPerMeter = 0.001
		self.DakShellFragPen = 0
		self.CooldownWeightMod = 3450
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 11 then
		WireLib.TriggerOutput(self, "AmmoType", "Smoke")
		self.DakAmmoType = self.DakSM
		self.DakShellAmmoType = "SM"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/4
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*0.1
		self.DakShellVelocity = self.BaseDakShellVelocity*0.42
		self.DakPenLossPerMeter = 0.001
		self.DakShellFragPen = 0
		self.CooldownWeightMod = 2700
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if IsValid(self.DakTankCore) then
		self.AmmoCount = 0
		self.SortedAmmo = {}
		if not(self.DakTankCore.Ammoboxes == nil) then
			for i = 1, #self.DakTankCore.Ammoboxes do
				if IsValid(self.DakTankCore.Ammoboxes[i]) then
					if self.DakTankCore.Ammoboxes[i].DakAmmoType == self.DakAmmoType then
						self.AmmoCount = self.AmmoCount + self.DakTankCore.Ammoboxes[i].DakAmmo
					end
					self.SortedAmmo[#self.SortedAmmo+1] = {self.DakTankCore.Ammoboxes[i],self.DakTankCore.Ammoboxes[i]:GetPos():Distance(self:GetPos() + self:GetForward()*self:OBBMins().x)}
				end
			end
			table.sort( self.SortedAmmo, function( a, b ) return a[2] < b[2] end )
		end
		if self.AmmoCount == 0 and self.AutoSwapStacks < 9 and IsValid(self) then
			self.AutoSwapStacks = self.AutoSwapStacks + 1
			self.AmmoSwap = true
			self:DakTEGunAmmoSwap()
		else
			self.AutoSwapStacks = 0
		end

		if not(self.SortedAmmo == nil) then
			local found = 0
			local box = 1
			local distance = 0
			while found == 0 and box <= #self.SortedAmmo do
				if IsValid(self.SortedAmmo[box][1]) then
					if self.SortedAmmo[box][1].DakAmmoType == self.DakAmmoType then
						if self.SortedAmmo[box][1].DakAmmo > 0 then
							distance = self.SortedAmmo[box][2]
							found = 1
							self.CooldownDistanceModifier = math.max( distance, 25 )/60
						end
					end
				end
				box = box + 1
			end
		end

		WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
	end
end

function ENT:DakTEFire()
	if( self.Firing ) then
		if IsValid(self.DakTankCore) then
			self.AmmoCount = 0 
			if not(self.SortedAmmo == nil) then
				for i = 1, #self.SortedAmmo do
					if IsValid(self.SortedAmmo[i][1]) then
						if self.SortedAmmo[i][1].DakAmmoType == self.DakAmmoType then
							self.AmmoCount = self.AmmoCount + self.SortedAmmo[i][1].DakAmmo
						end
					end
				end
			end
		end
		if self.AmmoCount > 0 then
			if CurTime() > (self.timer + self.DakCooldown) then
				--AMMO CHECK HERE
				for i = 1, #self.SortedAmmo do
					if IsValid(self.SortedAmmo[i][1]) then
						if self.SortedAmmo[i][1].DakAmmoType == self.DakAmmoType then
							if self.SortedAmmo[i][1].DakAmmo > 0 then
								self.SortedAmmo[i][1].DakAmmo = self.SortedAmmo[i][1].DakAmmo-1
							break end
						end
					end
				end
				--FIREBULLETHERE
				self.LastFireTime = CurTime()
				local shootOrigin = self:GetPos() + (self:GetForward()*self:GetModelRadius())
				local shootAngles = (self:GetVelocity()+self:GetForward()*self.DakShellVelocity):GetNormalized():Angle()
				local initvel = self:GetVelocity()
				if self:GetParent():IsValid() then
					initvel = self:GetParent():GetVelocity()
					if self:GetParent():GetParent():IsValid() then
						initvel = self:GetParent():GetParent():GetVelocity()
					end
				end
				local shootDir = shootAngles:Forward()

				local Propellant = self:GetPropellant()*0.01
 				local Shell = {}
 				Shell.Pos = shootOrigin + ( self:GetForward() * 1 )
				Shell.DakTrail = self.DakShellTrail
				Shell.DakVelocity = ((self.DakShellVelocity * math.Rand( 0.95, 1.05 ) * Propellant) * (shootAngles + Angle(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05))):Forward()) + initvel
				Shell.DakBaseVelocity = self.DakShellVelocity * Propellant
				Shell.DakDamage = self.DakShellDamage * math.Rand( 0.99, 1.01 )
				Shell.DakMass = self.DakShellMass
				Shell.DakIsPellet = false
				Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.99, 1.01 )
				Shell.DakPenetration = self.DakShellPenetration * math.Rand( 0.99, 1.01 )
				if self.DakShellAmmoType == "AP" or self.DakShellAmmoType == "HE" or self.DakShellAmmoType == "HVAP" or self.DakShellAmmoType == "APFSDS" or self.DakShellAmmoType == "APHE" or self.DakShellAmmoType == "APDS" or self.DakShellAmmoType == "SM" then
					Shell.DakPenetration = self.DakShellPenetration * math.Rand( 0.99, 1.01 ) * Propellant
				end
				Shell.DakExplosive = self.DakShellExplosive
				Shell.DakBlastRadius = self.DakShellBlastRadius
				Shell.DakPenSounds = self.DakShellPenSounds
				Shell.DakBasePenetration = self.BaseDakShellPenetration
				Shell.DakFragPen = self.DakShellFragPen
				Shell.DakCaliber = self.DakMaxHealth
				if self.CurrentAmmoType == 4 then
					Shell.DakCaliber = self.DakMaxHealth/2
				end
				if self.CurrentAmmoType == 8 or self.CurrentAmmoType == 10 then
					Shell.DakCaliber = self.DakMaxHealth/4
				end					
				Shell.DakFireSound = self.DakFireSound1
				Shell.DakFirePitch = self.DakFirePitch
				Shell.DakGun = self
				Shell.Filter = table.Copy(self.DakTankCore.Contraption)
				Shell.LifeTime = 0
				Shell.Gravity = 0
				Shell.DakPenLossPerMeter = self.DakPenLossPerMeter
				Shell.DakShellType = self.DakShellAmmoType
				if self.DakShellAmmoType == "HESH" or self.DakShellAmmoType == "HEAT" or self.DakShellAmmoType == "HEATFS" or self.DakShellAmmoType == "APHE" then
					Shell.DakBlastRadius = self.DakShellBlastRadius * 0.5
					Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.99, 1.01 ) * 0.5
				end
				if self.DakShellAmmoType == "SM" then
					Shell.DakBlastRadius = self.DakShellBlastRadius
					Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.99, 1.01 ) * 0.1
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

				DakTankShellList[#DakTankShellList+1] = Shell

				local FiringSound = {self.DakFireSound1,self.DakFireSound2,self.DakFireSound3}

				self:SetNWString("FireSound",FiringSound[math.random(1,3)])
				self:SetNWInt("FirePitch",self.DakFirePitch)
				self:SetNWFloat("Caliber",self.DakCaliber)

				if self.DakCaliber>=40 then
					self:SetNWBool("Firing",true)
					timer.Create( "ResoundTimer"..self:EntIndex(), 0.1, 1, function()
						self:SetNWBool("Firing",false)
					end)
				else
					sound.Play( FiringSound[math.random(1,3)], self:GetPos(), 100, 100*math.Rand(0.95, 1.05), 1 )
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
				--self:EmitSound( self.DakFireSound1, 100, self.DakFirePitch, 1, 6)
				self.timer = CurTime()
				
				if self.DakAmmoType == self.DakATGM then
					if(self:IsValid()) then
						if(self.DakTankCore:GetParent():IsValid()) then
							if(self.DakTankCore:GetParent():GetParent():IsValid()) then
								self.DakTankCore:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( 0.01*self.DakTankCore:GetParent():GetParent():GetPhysicsObject():GetMass()*((-self:GetForward()*((0.5*self.BaseDakShellMass)*((self.DakShellVelocity*0.0254)^2)))/self.DakTankCore.TotalMass) , self:GetPos() )
							end
						end
						if not(self.DakTankCore:GetParent():IsValid()) then
							self:GetPhysicsObject():ApplyForceCenter( 0.01*self:GetPhysicsObject():GetMass()*((-self:GetForward()*((0.5*self.BaseDakShellMass)*((self.DakShellVelocity*0.0254)^2)))/self.DakTankCore.TotalMass) )
						end
					end
				else
					if (self:IsValid()) then
						if(self.DakTankCore:GetParent():IsValid()) then
							if(self.DakTankCore:GetParent():GetParent():IsValid()) then
								self.DakTankCore:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( 0.1*self.DakTankCore:GetParent():GetParent():GetPhysicsObject():GetMass()*((-self:GetForward()*((0.5*self.BaseDakShellMass)*((self.DakShellVelocity*0.0254)^2)))/self.DakTankCore.TotalMass) , self:GetPos() )
							end
						end
						if not(self.DakTankCore:GetParent():IsValid()) then
							self:GetPhysicsObject():ApplyForceCenter( 0.1*self:GetPhysicsObject():GetMass()*((-self:GetForward()*((0.5*self.BaseDakShellMass)*((self.DakShellVelocity*0.0254)^2)))/self.DakTankCore.TotalMass) )
						end
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
		if self.AmmoCount == 0 and self.AutoSwapStacks < 9 and IsValid(self) then
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
		if self.CurrentAmmoType>11 then
			self.CurrentAmmoType = 1
		end
	else
		self.LastSwapTime = CurTime()-1
	end
	self.timer = CurTime()
	self.LastFireTime = CurTime()
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
		self.DakShellFragPen = 0
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
		self.DakShellFragPen = self.DakBaseShellFragPen*0.1
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
		self.DakShellPenetration = self.DakMaxHealth*1.20
		if self.DakTankCore.ColdWar and self.DakTankCore.Modern then
			if self.DakTankCore.ColdWar == 1 or self.DakTankCore.Modern == 1 then
				self.DakShellPenetration = self.DakMaxHealth*5.4*0.431
			end
		end
		self.DakShellVelocity = self.BaseDakShellVelocity*0.75
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = self.DakBaseShellFragPen*0.75*0.1
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
		self.DakShellFragPen = 0
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
		self.DakShellPenetration = self.DakMaxHealth*0.05
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = 0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 6 then
		WireLib.TriggerOutput(self, "AmmoType", "Anti Tank Guided Missile")
		self.DakAmmoType = self.DakATGM
		self.DakShellAmmoType = "HEATFS"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.DakMaxHealth*6.40
		if self.DakTankCore.ColdWar and self.DakTankCore.Modern then
			if self.DakTankCore.ColdWar == 1 and self.DakTankCore.Modern == 0 then
				self.DakShellPenetration = self.DakMaxHealth*6.40*0.45
			end
		end
		self.DakShellVelocity = 12600
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = self.DakBaseShellFragPen*0.75*0.1
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
		self.DakShellPenetration = self.DakMaxHealth*5.40
		if self.DakTankCore.ColdWar and self.DakTankCore.Modern then
			if self.DakTankCore.ColdWar == 1 and self.DakTankCore.Modern == 0 then
				self.DakShellPenetration = self.DakMaxHealth*5.40*0.658
			end
		end
		self.DakShellVelocity = self.BaseDakShellVelocity*1.3333
		self.DakPenLossPerMeter = 0.0
		self.DakShellFragPen = self.DakBaseShellFragPen*0.75*0.1
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
		self.DakShellPenetration = self.BaseDakShellPenetration*7.8*0.5
		self.DakShellVelocity = self.BaseDakShellVelocity*2.394
		self.DakPenLossPerMeter = 0.001
		self.DakShellFragPen = 0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 9 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing High Explosive")
		self.DakAmmoType = self.DakAPHE
		self.DakShellAmmoType = "APHE"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*1.65
		self.DakShellVelocity = self.BaseDakShellVelocity
		self.DakPenLossPerMeter = 0.0005
		self.DakShellFragPen = self.DakBaseShellFragPen*0.1
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 10 then
		WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing Discarding Sabot")
		self.DakAmmoType = self.DakAPDS
		self.DakShellAmmoType = "APDS"
		self.DakShellExplosive = false
		self.DakShellDamage = self.BaseDakShellDamage/8
		self.DakShellMass = self.BaseDakShellMass/8
		self.DakShellPenetration = self.BaseDakShellPenetration*1.67
		self.DakShellVelocity = self.BaseDakShellVelocity*4/3
		self.DakPenLossPerMeter = 0.001
		self.DakShellFragPen = 0
		WireLib.TriggerOutput(self, "MuzzleVel", self.DakShellVelocity)
		WireLib.TriggerOutput(self, "ShellMass", self.DakShellMass)
		WireLib.TriggerOutput(self, "Penetration", self.DakShellPenetration)
	end
	if self.CurrentAmmoType == 11 then
		WireLib.TriggerOutput(self, "AmmoType", "Smoke")
		self.DakAmmoType = self.DakSM
		self.DakShellAmmoType = "SM"
		self.DakShellExplosive = true
		self.DakShellDamage = self.BaseDakShellDamage/4
		self.DakShellMass = self.BaseDakShellMass
		self.DakShellPenetration = self.DakMaxHealth*0.1
		self.DakShellVelocity = self.BaseDakShellVelocity*0.42
		self.DakPenLossPerMeter = 0.001
		self.DakShellFragPen = 0
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
		if self.AmmoCount == 0 and self.AutoSwapStacks < 9 and IsValid(self) then
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
	info.DakFireSound1 = self.DakFireSound1
	info.DakFireSound2 = self.DakFireSound2
	info.DakFireSound3 = self.DakFireSound3

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
		self:SetNWFloat("Caliber",self.DakCaliber)
		self.DakGunType = Ent.EntityMods.DakTek.DakGunType
		self.DakHealth = self.DakMaxHealth
		if Ent.EntityMods.DakTek.DakFireSound and Ent.EntityMods.DakTek.DakFireSound1 == "" then
			self.DakFireSound1 = Ent.EntityMods.DakTek.DakFireSound
			self.DakFireSound2 = Ent.EntityMods.DakTek.DakFireSound
			self.DakFireSound3 = Ent.EntityMods.DakTek.DakFireSound
		else
			self.DakFireSound1 = Ent.EntityMods.DakTek.DakFireSound1
			self.DakFireSound2 = Ent.EntityMods.DakTek.DakFireSound2
			self.DakFireSound3 = Ent.EntityMods.DakTek.DakFireSound3
		end

		self.DakOwner = Player
		self:SetColor(Ent.EntityMods.DakTek.DakColor)
		self:SetSubMaterial( 0, Ent.EntityMods.DakTek.DakMat0 )
		self:SetSubMaterial( 1, Ent.EntityMods.DakTek.DakMat1 )

		self:Activate()

		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
	local ScalingGun = 0
	if self.DakModel == "models/daktanks/mortar100mm2.mdl" then ScalingGun = 1 end
	if self.DakModel == "models/daktanks/grenadelauncher100mm.mdl" then ScalingGun = 1 end
	if self.DakModel == "models/daktanks/smokelauncher100mm.mdl" then ScalingGun = 1 end
	if self.DakModel == "models/daktanks/machinegun100mm.mdl" then ScalingGun = 1 end

	if ScalingGun == 1 then
		local Caliber = self.DakCaliber
		self:SetModelScale(1)
		self:SetModelScale( self:GetModelScale() * (Caliber/100), 0 )
		self:Activate()
	end
end
