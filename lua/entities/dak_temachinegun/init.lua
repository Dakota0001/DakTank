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
ENT.DakPenLossPerMeter = 0.0005
ENT.DakPooled=0
ENT.DakArmor = 1
ENT.DakTankCore = nil
ENT.HasCrew = 0
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
	self.Inputs = Wire_CreateInputs(self, { "Fire" })
	self.Outputs = WireLib.CreateOutputs( self, { "Cooldown" , "CooldownPercent", "Ammo", "AmmoType [STRING]", "MuzzleVel", "ShellMass", "Penetration" } )
 	self.Held = false
 	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.MidThinkTime = CurTime()
 	self.LastFireTime = CurTime()
 	self.CurrentAmmoType = 1
 	self.DakBurnStacks = 0
 	self.BasicVelocity = 29527.6

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
		--Machine Guns
		if self.DakGunType == "MG" then
			self.DakName = self.DakCaliber.."mm Machine Gun"
			self.DakCooldown = math.Round((self.DakCaliber/13 + self.DakCaliber/100)*0.1,2)
			self.DakMaxHealth = self.DakCaliber
			self.DakArmor = self.DakCaliber*5
			self.DakMass = 2*math.Round(((((self.DakCaliber*2.75)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(((self.DakCaliber+62.5)/2)^2)*(self.DakCaliber*15))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*15)))*0.001*7.8125)/1000)

			self.DakAP = math.Round(self.DakCaliber,2).."mmMGAPAmmo"
			self.DakHE = math.Round(self.DakCaliber,2).."mmMGHEAmmo"
			self.DakFL = math.Round(self.DakCaliber,2).."mmMGFLAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*6.5))
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Cannon - 6.5, Howitzer - 4, Mortar - 2.75
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*6.5))*7700
			self.DakShellSplashDamage = self.DakCaliber*0.0375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*(50/50)
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/25*39)
			self.DakShellFragPen = (self.DakCaliber/2.5)

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity
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

			self.DakFireEffect = "dakteflamefire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteflametrail"
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

	if CurTime()>=self.MidThinkTime+0.33 then
		self:DakTEAmmoCheck()

		WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100))
		WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100)/self.DakCooldown))
		self.MidThinkTime = CurTime()
	end

	for i = 1, #self.ShellList do
		self.ShellList[i].LifeTime = self.ShellList[i].LifeTime + 0.1
		self.ShellList[i].Gravity = physenv.GetGravity()*self.ShellList[i].LifeTime

		local trace = {}
			trace.start = self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * (self.ShellList[i].LifeTime-0.1)) - (-physenv.GetGravity()*((self.ShellList[i].LifeTime-0.1)^2)/2)
			trace.endpos = self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * self.ShellList[i].LifeTime) - (-physenv.GetGravity()*(self.ShellList[i].LifeTime^2)/2)
			trace.filter = self.ShellList[i].Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local ShellTrace = util.TraceHull( trace )

		local effectdata = EffectData()
		effectdata:SetStart(ShellTrace.StartPos)
		effectdata:SetOrigin(ShellTrace.HitPos)
		effectdata:SetScale((self.ShellList[i].DakCaliber*0.0393701))
		util.Effect(self.DakShellTrail, effectdata, true, true)

		if ShellTrace.Hit then
			DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,self.ShellList[i],ShellTrace.HitNormal)
		end

		if self.ShellList[i].DieTime then
			--self.RemoveList[#self.RemoveList+1] = i
			if self.ShellList[i].DieTime+1.5<CurTime()then
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
		self.DakPenLossPerMeter = 0.0005
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
				
				if self.DakIsFlechette then
					for i = 1, self.DakPellets do
						local Shell = {}
		 				Shell.Pos = shootOrigin + ( self:GetForward() * 1 )
		 				Shell.Ang = shootAngles + Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),math.Rand(-0.5,0.5))
						Shell.DakTrail = self.DakShellTrail
						Shell.DakVelocity = self.DakShellVelocity * math.Rand( 0.95, 1.05 )
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
						Shell.DakCaliber = self.DakMaxHealth/10
						Shell.DakFireSound = self.DakFireSound
						Shell.DakFirePitch = self.DakFirePitch
						Shell.DakGun = self
						Shell.Filter = table.Copy(self.DakTankCore.Contraption)
						Shell.LifeTime = 0
						Shell.Gravity = 0
						Shell.DakPenLossPerMeter = self.DakPenLossPerMeter
						if self.DakName == "Flamethrower" then
							Shell.DakIsFlame = 1
						end
						self.ShellList[#self.ShellList+1] = Shell
	 				end
	 			else
	 				local Shell = {}
	 				Shell.Pos = shootOrigin + ( self:GetForward() * 1 )
	 				Shell.Ang = shootAngles + Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1))
					Shell.DakTrail = self.DakShellTrail
					Shell.DakVelocity = self.DakShellVelocity * math.Rand( 0.95, 1.05 )
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
					Shell.DakFireSound = self.DakFireSound
					Shell.DakFirePitch = self.DakFirePitch
					Shell.DakGun = self
					Shell.Filter = table.Copy(self.DakTankCore.Contraption)
					Shell.LifeTime = 0
					Shell.Gravity = 0
					Shell.DakPenLossPerMeter = self.DakPenLossPerMeter
					if self.DakName == "Flamethrower" then
						Shell.DakIsFlame = 1
					end
					self.ShellList[#self.ShellList+1] = Shell
				end

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
								

				local effectdata = EffectData()
				effectdata:SetOrigin( self:GetAttachment( 1 ).Pos )
				effectdata:SetAngles( self:GetAngles() )
				effectdata:SetEntity(self)
				effectdata:SetScale( self.DakMaxHealth*0.25 )
				util.Effect( self.DakFireEffect, effectdata, true, true )

				--self:EmitSound( self.DakFireSound, 100, self.DakFirePitch, 1, 6)
				self.timer = CurTime()
				if(self:IsValid()) then
					if(self:GetParent():IsValid()) then
						if(self:GetParent():GetParent():IsValid()) then
							self:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( -self:GetForward()*self.DakShellVelocity*self.BaseDakShellMass/40 )
						end
					end
					if not(self:GetParent():IsValid()) then
						self:GetPhysicsObject():ApplyForceCenter( -self:GetForward()*self.DakShellVelocity*self.BaseDakShellMass/40 )
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
		WireLib.TriggerOutput(self, "Ammo", self.AmmoCount)
	end
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

function CheckClip(Ent, HitPos)
	if not (Ent:GetClass() == "prop_physics") or (Ent.ClipData == nil) then return false end
	
	local HitClip = false
	local normal
	local origin
	for i=1, #Ent.ClipData do
		normal = Ent:LocalToWorldAngles(Ent.ClipData[i]["n"]):Forward()
		origin = Ent:LocalToWorld(Ent.ClipData[i]["n"]:Forward()*Ent.ClipData[i]["d"])
		HitClip = HitClip or normal:Dot((origin - HitPos):GetNormalized()) > 0.25
		if HitClip then return true end
	end
	return HitClip
end

function DTShellHit(Start,End,HitEnt,Shell,Normal)
	if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner) ~= false then
		if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt:GetClass()=="dak_bot") then
			if (CheckClip(HitEnt,End)) or (HitEnt:GetPhysicsObject():GetMass()<=1 and not(HitEnt:IsVehicle()) and not(HitEnt.IsDakTekFutureTech==1)) or HitEnt.DakName=="Damaged Component" then
				if HitEnt.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HitEnt)
				end
				local SA = HitEnt:GetPhysicsObject():GetSurfaceArea()
				if HitEnt.DakBurnStacks == nil then
					HitEnt.DakBurnStacks = 0
				end
				if HitEnt.IsDakTekFutureTech == 1 then
					HitEnt.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HitEnt:OBBMaxs().x, 3 )
						HitEnt.DakArmor = HitEnt:OBBMaxs().x/2
						HitEnt.DakIsTread = 1
					else
						if HitEnt:GetClass()=="prop_physics" then 
							if not(HitEnt.DakArmor == 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25) then
								HitEnt.DakArmor = 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25
							end
						end
					end
				end
				Shell.Filter[#Shell.Filter+1] = HitEnt
				DTShellContinue(Start,Shell,Normal)
			else
				if HitEnt.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HitEnt)
				end
				local SA = HitEnt:GetPhysicsObject():GetSurfaceArea()
				if HitEnt.IsDakTekFutureTech == 1 then
					HitEnt.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HitEnt:OBBMaxs().x, 3 )
						HitEnt.DakArmor = HitEnt:OBBMaxs().x/2
						HitEnt.DakIsTread = 1
					else
						if HitEnt:GetClass()=="prop_physics" then 
							if not(HitEnt.DakArmor == 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25) then
								HitEnt.DakArmor = 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25
							end
						end
					end
				end
				
				HitEnt.DakLastDamagePos = End

				local Vel = Shell.Ang:Forward()
				local EffArmor = (HitEnt.DakArmor/math.abs(Normal:Dot(Vel:GetNormalized())))
				if EffArmor < (Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))) and HitEnt.IsDakTekFutureTech == nil then
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then		
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							if Shell.DakIsFlechette==true then
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*0.2)
							else
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor)
							end
						end
					else
						if Shell.DakIsFlechette==true then
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*0.2)
						else
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor)
						end
					end
					if(HitEnt:IsValid() and HitEnt:GetClass()~="dak_bot" and HitEnt:GetClass()~="prop_ragdoll") then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass(),HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								end
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass(),HitEnt:GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
						end
					end

					DTSpall(End,EffArmor,Shell.DakVelocity*Shell.DakMass,HitEnt,Shell.DakCaliber,(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))),Shell.DakGun.DakOwner,Shell)

					local effectdata = EffectData()
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakCaliber*0.25)
					util.Effect("dakteshellpenetrate", effectdata, true, true)
					util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
					util.Decal( "Impact.Concrete", End+((End-Start):GetNormalized()*5), End-((End-Start):GetNormalized()*5), Shell.DakGun)
					Shell.DakVelocity = Shell.DakVelocity - (Shell.DakVelocity * (EffArmor/Shell.DakPenetration))
					local checktrace = {}
						checktrace.start = Start
						checktrace.endpos = End
						checktrace.filter = Shell.Filter
						checktrace.mins = Vector(-1,-1,-1)
						checktrace.maxs = Vector(1,1,1)
					local CheckShellTrace = util.TraceHull( checktrace )
					Shell.Pos = End
					Shell.LifeTime = 0
					Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
					Shell.DakPenetration = Shell.DakPenetration-(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))*(EffArmor/Shell.DakPenetration)
					--soundhere penetrate sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 100, 1 )
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					DTShellContinue(Start,Shell,Normal)
				else
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt:GetClass()~="dak_bot" then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							if Shell.DakIsFlechette == true then	
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.1875
							else
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
							end
						end
					else
						if Shell.DakIsFlechette == true then	
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.1875
						else
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
						end
					end
					if Shell.DakIsFlame == 1 then
						if SA then
							if HitEnt.DakArmor > (7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5 then
								HitEnt.DakBurnStacks = HitEnt.DakBurnStacks+1
							end
						end
					end
					if(HitEnt:IsValid() and HitEnt:GetClass()~="dak_bot" and HitEnt:GetClass()~="prop_ragdoll") then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass(),HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								end							
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass(),HitEnt:GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
						end
					end
					if Shell.DakExplosive then
						local checktrace = {}
							checktrace.start = Start
							checktrace.endpos = End
							checktrace.filter = Shell.Filter
							checktrace.mins = Vector(-1,-1,-1)
							checktrace.maxs = Vector(1,1,1)
						local CheckShellTrace = util.TraceHull( checktrace )
						Shell.Pos = End
						Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
					--print( math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
						local effectdata = EffectData()
						if Shell.DakIsFlame == 1 then
							effectdata:SetOrigin(End)
							effectdata:SetEntity(Shell.DakGun)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(1)
							util.Effect("dakteflameimpact", effectdata, true, true)
							local Targets = ents.FindInSphere( End, 150 )
							if table.Count(Targets) > 0 then
								for i = 1, #Targets do
									if Targets[i]:GetClass() == "dak_temotor" then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
									if Targets[i]:GetClass() == "dak_tegearbox" then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
										Targets[i].DakBurnStacks = Targets[i].DakBurnStacks+1
									end
									if Targets[i]:IsPlayer() then
										if not Targets[i]:InVehicle() then
											if not(Targets[i]:IsOnFire()) then 
												Targets[i]:Ignite(5,1)
											end
										end
									end
									if Targets[i]:IsNPC() or (Targets[i]:GetClass()=="dak_bot" or Targets[i]:GetClass()=="dak_zombie") then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
								end
							end
							sound.Play( "daktanks/flamerimpact.wav", End, 100, 100, 1 )
						else
							if Shell.DakDamage > 0 then
								effectdata:SetOrigin(End)
								effectdata:SetEntity(Shell.DakGun)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(Shell.DakCaliber*0.25)
								util.Effect("dakteshellbounce", effectdata, true, true)
								util.Decal( "Impact.Glass", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
								local BounceSounds = {}
								if Shell.DakCaliber < 20 then
									BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
								else
									BounceSounds = {"daktanks/dakrico1.wav","daktanks/dakrico2.wav","daktanks/dakrico3.wav","daktanks/dakrico4.wav","daktanks/dakrico5.wav","daktanks/dakrico6.wav"}
								end
								if Shell.DakIsPellet then
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], End, 100, 150, 0.25 )
								else
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], End, 100, 100, 1 )
								end
							end
						end
						Shell.DakVelocity = Shell.DakVelocity*0.025
						Shell.Ang = ((End-Start) - 1.25 * (Normal:Dot(End-Start) * Normal)):Angle() + Angle(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5))
						local checktrace = {}
							checktrace.start = Start
							checktrace.endpos = End
							checktrace.filter = Shell.Filter
							checktrace.mins = Vector(-1,-1,-1)
							checktrace.maxs = Vector(1,1,1)
						local CheckShellTrace = util.TraceHull( checktrace )
						Shell.Pos = End
						Shell.LifeTime = 0
						Shell.DakPenetration = Shell.DakPenetration-(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))*(HitEnt.DakArmor/Shell.DakPenetration)
						Shell.DakDamage = 0
						--soundhere bounce sound
					end
				end
				if HitEnt.DakHealth <= 0 and HitEnt.DakPooled==0 then
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = HitEnt:GetModel()
					salvage:SetPos( HitEnt:GetPos())
					salvage:SetAngles( HitEnt:GetAngles())
					salvage:Spawn()
					HitEnt:Remove()
					if Shell.salvage then
						Shell.Filter[#Shell.Filter+1] = Shell.salvage
					end
				end
			end
		end
		if HitEnt:IsValid() then
			if HitEnt:IsPlayer() or HitEnt:IsNPC() or HitEnt:GetClass() == "dak_bot" then
				if HitEnt:GetClass() == "dak_bot" then
					HitEnt:SetHealth(HitEnt:Health() - Shell.DakDamage*500)
					if HitEnt:Health() <= 0 and HitEnt.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( HitEnt:GetPos() )
						body:SetModel( HitEnt:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						if Shell.DakIsFlame == 1 then
							body:Ignite(10,1)
						end
						HitEnt:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Shell.Ang:Forward()*Shell.DakDamage*Shell.DakMass*Shell.DakVelocity )
					Pain:SetDamage( Shell.DakDamage*500 )
					Pain:SetAttacker( Shell.DakGun.DakOwner )
					Pain:SetInflictor( Shell.DakGun )
					Pain:SetReportedPosition( End )
					Pain:SetDamagePosition( HitEnt:GetPos() )
					if Shell.DakIsFlame == 1 then
						Pain:SetDamageType(DMG_BURN)
					else
						Pain:SetDamageType(DMG_CRUSH)
					end
					HitEnt:TakeDamageInfo( Pain )
				end
				if HitEnt:Health() <= 0 and not(Shell.DakIsFlame == 1) then
					local effectdata = EffectData()
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakCaliber*0.25)
					util.Effect("dakteshellpenetrate", effectdata, true, true)
					util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
					util.Decal( "Impact.Concrete", End+((End-Start):GetNormalized()*5), End-((End-Start):GetNormalized()*5), Shell.DakGun)
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.salvage then
						Shell.Filter[#Shell.Filter+1] = Shell.salvage
					end
					DTShellContinue(Start,Shell,Normal)
					--soundhere penetrate human sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 100, 1 )
					end
				else
					local effectdata = EffectData()
					if Shell.DakIsFlame == 1 then
						effectdata:SetOrigin(End)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(1)
						util.Effect("dakteflameimpact", effectdata, true, true)
						local Targets = ents.FindInSphere( End, 150 )
						if table.Count(Targets) > 0 then
							for i = 1, #Targets do
								if Targets[i]:GetClass() == "dak_temotor" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
								if Targets[i]:GetClass() == "dak_tegearbox" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
									Targets[i].DakBurnStacks = Targets[i].DakBurnStacks+1
								end
								if Targets[i]:IsPlayer() then
									if not Targets[i]:InVehicle() then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
								end
								if Targets[i]:IsNPC() or (Targets[i]:GetClass()=="dak_bot" or Targets[i]:GetClass()=="dak_zombie") then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
							end
						end
						sound.Play( "daktanks/flamerimpact.wav", End, 100, 100, 1 )
					else
						effectdata:SetOrigin(End)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Shell.DakCaliber*0.25)
						util.Effect("dakteshellimpact", effectdata, true, true)
						util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
						local ExpSounds = {}
						if Shell.DakCaliber < 20 then
							ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
						else
							ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
						end

						if Shell.DakIsPellet then
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 150, 0.25 )	
						else
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 100, 1 )	
						end
					end
					Shell.RemoveNow = 1
					if Shell.DakExplosive then
						Shell.ExplodeNow = true
					end
					Shell.LifeTime = 0
					Shell.DakVelocity = 0
					Shell.DakDamage = 0
				end
			end
		end
		if HitEnt:IsWorld() or Shell.ExplodeNow==true then
			if Shell.DakExplosive then
				local effectdata = EffectData()
				effectdata:SetOrigin(End)
				effectdata:SetEntity(Shell.DakGun)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(Shell.DakBlastRadius)
				util.Effect("daktescalingexplosion", effectdata, true, true)

				Shell.DakGun:SetNWFloat("ExpDamage",Shell.DakSplashDamage)
				if Shell.DakCaliber>=75 then
					Shell.DakGun:SetNWBool("Exploding",true)
					timer.Create( "ExplodeTimer"..Shell.DakGun:EntIndex(), 0.1, 1, function()
						Shell.DakGun:SetNWBool("Exploding",false)
					end)
				else
					local ExpSounds = {}
					if Shell.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
					end
					sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 100, 1 )	
				end
				DTShockwave(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
				DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
			else
				local effectdata = EffectData()
				if Shell.DakIsFlame == 1 then
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(1)
					util.Effect("dakteflameimpact", effectdata, true, true)
					local Targets = ents.FindInSphere( End, 150 )
					if table.Count(Targets) > 0 then
						if table.Count(Targets) > 0 then
							for i = 1, #Targets do
								if Targets[i]:GetClass() == "dak_temotor" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
								if Targets[i]:GetClass() == "dak_tegearbox" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
									Targets[i].DakBurnStacks = Targets[i].DakBurnStacks+1
								end
								if Targets[i]:IsPlayer() then
									if not Targets[i]:InVehicle() then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
								end
								if Targets[i]:IsNPC() or (Targets[i]:GetClass()=="dak_bot" or Targets[i]:GetClass()=="dak_zombie") then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
							end
						end
					end
					sound.Play( "daktanks/flamerimpact.wav", End, 100, 100, 1 )
				else
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					if Shell.DakDamage == 0 then
						effectdata:SetScale(0.5)
					else
						effectdata:SetScale(Shell.DakCaliber*0.25)
					end
					util.Effect("dakteshellimpact", effectdata, true, true)
					util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
					local ExpSounds = {}
					if Shell.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
					end

					if Shell.DakIsPellet then
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 150, 0.25 )	
					else
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 100, 1 )	
					end
				end
			end
			Shell.RemoveNow = 1
			if Shell.DakExplosive then
				Shell.ExplodeNow = true
			end
			Shell.LifeTime = 0
			Shell.DakVelocity = 0
			Shell.DakDamage = 0
		else

		end	

		if Shell.DakPenetration <= 0 then
			Shell.Spent = 1
			if Shell.DieTime == nil then
				Shell.DieTime = CurTime()
			end
		end
	end
end

function DTShellContinue(Start,Shell,Normal)
	local newtrace = {}
		newtrace.start = Shell.Pos + (Shell.DakVelocity * Shell.Ang:Forward() * (Shell.LifeTime-0.1)) - (-physenv.GetGravity()*((Shell.LifeTime-0.1)^2)/2)
		newtrace.endpos = Shell.Pos + (Shell.DakVelocity * Shell.Ang:Forward() * Shell.LifeTime) - (-physenv.GetGravity()*(Shell.LifeTime^2)/2)
		newtrace.filter = Shell.Filter
		newtrace.mins = Vector(-1,-1,-1)
		newtrace.maxs = Vector(1,1,1)
	local ContShellTrace = util.TraceHull( newtrace )

	local HitEnt = ContShellTrace.Entity
	local End = ContShellTrace.HitPos

	local effectdata = EffectData()
	effectdata:SetStart(ContShellTrace.StartPos)
	effectdata:SetOrigin(ContShellTrace.HitPos)
	effectdata:SetScale((Shell.DakCaliber*0.0393701))
	util.Effect("dakteballistictracer", effectdata, true, true)


	if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner) ~= false then
		if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt:GetClass()=="dak_bot") then
			if (CheckClip(HitEnt,End)) or (HitEnt:GetPhysicsObject():GetMass()<=1 and not(HitEnt:IsVehicle()) and not(HitEnt.IsDakTekFutureTech==1)) or HitEnt.DakName=="Damaged Component" then
				if HitEnt.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HitEnt)
				end
				local SA = HitEnt:GetPhysicsObject():GetSurfaceArea()
				if HitEnt.DakBurnStacks == nil then
					HitEnt.DakBurnStacks = 0
				end
				if HitEnt.IsDakTekFutureTech == 1 then
					HitEnt.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HitEnt:OBBMaxs().x, 3 )
						HitEnt.DakArmor = HitEnt:OBBMaxs().x/2
						HitEnt.DakIsTread = 1
					else
						if HitEnt:GetClass()=="prop_physics" then 
							if not(HitEnt.DakArmor == 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25) then
								HitEnt.DakArmor = 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25
							end
						end
					end
				end

				Shell.Filter[#Shell.Filter+1] = HitEnt
				DTShellContinue(Start,Shell,Normal)
			else
				if HitEnt.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HitEnt)
				end
				local SA = HitEnt:GetPhysicsObject():GetSurfaceArea()
				if HitEnt.IsDakTekFutureTech == 1 then
					HitEnt.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HitEnt:OBBMaxs().x, 3 )
						HitEnt.DakArmor = HitEnt:OBBMaxs().x/2
						HitEnt.DakIsTread = 1
					else
						if HitEnt:GetClass()=="prop_physics" then 
							if not(HitEnt.DakArmor == 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25) then
								HitEnt.DakArmor = 7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HitEnt.DakBurnStacks*0.25
							end
						end
					end
				end
				
				HitEnt.DakLastDamagePos = End


				local Vel = Shell.Ang:Forward()
				local EffArmor = (HitEnt.DakArmor/math.abs(Normal:Dot(Vel:GetNormalized())))
				if EffArmor < (Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))) and HitEnt.IsDakTekFutureTech == nil then
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then	
							if Shell.DakIsFlechette==true then
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*0.2)
							else
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor)
							end
						end
					else
						if Shell.DakIsFlechette==true then
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*0.2)
						else
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor)
						end
					end
					if(HitEnt:IsValid() and HitEnt:GetClass()~="dak_bot" and HitEnt:GetClass()~="prop_ragdoll") then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass(),HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								end
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass(),HitEnt:GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
						end
					end

					DTSpall(End,EffArmor,Shell.DakVelocity*Shell.DakMass,HitEnt,Shell.DakCaliber,(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))),Shell.DakGun.DakOwner,Shell)

					local effectdata = EffectData()
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakCaliber*0.25)
					util.Effect("dakteshellpenetrate", effectdata, true, true)
					util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
					util.Decal( "Impact.Concrete", End+((End-Start):GetNormalized()*5), End-((End-Start):GetNormalized()*5), Shell.DakGun)
					Shell.DakVelocity = Shell.DakVelocity - (Shell.DakVelocity * (EffArmor/Shell.DakPenetration))
					local checktrace = {}
						checktrace.start = Start
						checktrace.endpos = End
						checktrace.filter = Shell.Filter
						checktrace.mins = Vector(-1,-1,-1)
						checktrace.maxs = Vector(1,1,1)
					local CheckShellTrace = util.TraceHull( checktrace )
					Shell.Pos = End
					Shell.LifeTime = 0
					Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
					Shell.DakPenetration = Shell.DakPenetration-(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))*(EffArmor/Shell.DakPenetration)
					--soundhere penetrate sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 100, 1 )
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					DTShellContinue(Start,Shell,Normal)
				else
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt:GetClass()~="dak_bot" then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then	
							if Shell.DakIsFlechette == true then	
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.1875
							else
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
							end
						end
					else
						if Shell.DakIsFlechette == true then	
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.1875
						else
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
						end
					end
					if Shell.DakIsFlame == 1 then
						if SA then
							if HitEnt.DakArmor > (7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5 then
								HitEnt.DakBurnStacks = HitEnt.DakBurnStacks+1
							end
						end
					end
					if(HitEnt:IsValid() and HitEnt:GetClass()~="dak_bot" and HitEnt:GetClass()~="prop_ragdoll") then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass(),HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
								end
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass(),HitEnt:GetPos()+HitEnt:WorldToLocal(End):GetNormalized() )
						end
					end
					if Shell.DakExplosive then
						local checktrace = {}
							checktrace.start = Start
							checktrace.endpos = End
							checktrace.filter = Shell.Filter
							checktrace.mins = Vector(-1,-1,-1)
							checktrace.maxs = Vector(1,1,1)
						local CheckShellTrace = util.TraceHull( checktrace )
						Shell.Pos = End
						Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
					--print( math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
						local effectdata = EffectData()
						if Shell.DakIsFlame == 1 then
							effectdata:SetOrigin(End)
							effectdata:SetEntity(Shell.DakGun)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(1)
							util.Effect("dakteflameimpact", effectdata, true, true)
							local Targets = ents.FindInSphere( End, 150 )
							if table.Count(Targets) > 0 then
								for i = 1, #Targets do
									if Targets[i]:GetClass() == "dak_temotor" then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
									if Targets[i]:GetClass() == "dak_tegearbox" then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
										Targets[i].DakBurnStacks = Targets[i].DakBurnStacks+1
									end
									if Targets[i]:IsPlayer() then
										if not Targets[i]:InVehicle() then
											if not(Targets[i]:IsOnFire()) then 
												Targets[i]:Ignite(5,1)
											end
										end
									end
									if Targets[i]:IsNPC() or (Targets[i]:GetClass()=="dak_bot" or Targets[i]:GetClass()=="dak_zombie") then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
								end
							end
							sound.Play( "daktanks/flamerimpact.wav", End, 100, 100, 1 )
						else
							if Shell.DakDamage > 0 then
								effectdata:SetOrigin(End)
								effectdata:SetEntity(Shell.DakGun)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(Shell.DakCaliber*0.25)
								util.Effect("dakteshellbounce", effectdata, true, true)
								util.Decal( "Impact.Glass", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
								local BounceSounds = {}
								if Shell.DakCaliber < 20 then
									BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
								else
									BounceSounds = {"daktanks/dakrico1.wav","daktanks/dakrico2.wav","daktanks/dakrico3.wav","daktanks/dakrico4.wav","daktanks/dakrico5.wav","daktanks/dakrico6.wav"}
								end
								if Shell.DakIsPellet then
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], End, 100, 150, 0.25 )
								else
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], End, 100, 100, 1 )
								end
							end
						end
						Shell.DakVelocity = Shell.DakVelocity*0.025
						Shell.Ang = ((End-Start) - 1.25 * (Normal:Dot(End-Start) * Normal)):Angle() + Angle(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5))
						local checktrace = {}
							checktrace.start = Start
							checktrace.endpos = End
							checktrace.filter = Shell.Filter
							checktrace.mins = Vector(-1,-1,-1)
							checktrace.maxs = Vector(1,1,1)
						local CheckShellTrace = util.TraceHull( checktrace )
						Shell.Pos = End
						Shell.LifeTime = 0
						Shell.DakPenetration = Shell.DakPenetration-(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))*(HitEnt.DakArmor/Shell.DakPenetration)
						Shell.DakDamage = 0
						--soundhere bounce sound
						
					end
				end
				if HitEnt.DakHealth <= 0 and HitEnt.DakPooled==0 then
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = HitEnt:GetModel()
					salvage:SetPos( HitEnt:GetPos())
					salvage:SetAngles( HitEnt:GetAngles())
					salvage:Spawn()
					HitEnt:Remove()
					if Shell.salvage then
						Shell.Filter[#Shell.Filter+1] = Shell.salvage
					end
				end
			end
		end
		if HitEnt:IsValid() then
			if HitEnt:IsPlayer() or HitEnt:IsNPC() or HitEnt:GetClass() == "dak_bot" then
				if HitEnt:GetClass() == "dak_bot" then
					HitEnt:SetHealth(HitEnt:Health() - Shell.DakDamage*500)
					if HitEnt:Health() <= 0 and HitEnt.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( HitEnt:GetPos() )
						body:SetModel( HitEnt:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						if Shell.DakIsFlame == 1 then
							body:Ignite(10,1)
						end
						HitEnt:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Shell.Ang:Forward()*Shell.DakDamage*Shell.DakMass*Shell.DakVelocity )
					Pain:SetDamage( Shell.DakDamage*500 )
					Pain:SetAttacker( Shell.DakGun.DakOwner )
					Pain:SetInflictor( Shell.DakGun )
					Pain:SetReportedPosition( End )
					Pain:SetDamagePosition( HitEnt:GetPos() )
					if Shell.DakIsFlame == 1 then
						Pain:SetDamageType(DMG_BURN)
					else
						Pain:SetDamageType(DMG_CRUSH)
					end
					HitEnt:TakeDamageInfo( Pain )
				end
				if HitEnt:Health() <= 0 and not(Shell.DakIsFlame == 1) then
					local effectdata = EffectData()
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakCaliber*0.25)
					util.Effect("dakteshellpenetrate", effectdata, true, true)
					util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
					util.Decal( "Impact.Concrete", End+((End-Start):GetNormalized()*5), End-((End-Start):GetNormalized()*5), Shell.DakGun)
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.salvage then
						Shell.Filter[#Shell.Filter+1] = Shell.salvage
					end
					DTShellContinue(Start,Shell,Normal)
					--soundhere penetrate human sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 100, 1 )
					end
				else
					local effectdata = EffectData()
					if Shell.DakIsFlame == 1 then
						effectdata:SetOrigin(End)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(1)
						util.Effect("dakteflameimpact", effectdata, true, true)
						local Targets = ents.FindInSphere( End, 150 )
						if table.Count(Targets) > 0 then
							for i = 1, #Targets do
								if Targets[i]:GetClass() == "dak_temotor" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
								if Targets[i]:GetClass() == "dak_tegearbox" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
									Targets[i].DakBurnStacks = Targets[i].DakBurnStacks+1
								end
								if Targets[i]:IsPlayer() then
									if not Targets[i]:InVehicle() then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
								end
								if Targets[i]:IsNPC() or (Targets[i]:GetClass()=="dak_bot" or Targets[i]:GetClass()=="dak_zombie") then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
							end
						end
						sound.Play( "daktanks/flamerimpact.wav", End, 100, 100, 1 )
					else
						effectdata:SetOrigin(End)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Shell.DakCaliber*0.25)
						util.Effect("dakteshellimpact", effectdata, true, true)
						util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
						local ExpSounds = {}
						if Shell.DakCaliber < 20 then
							ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
						else
							ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
						end

						if Shell.DakIsPellet then
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 150, 0.25 )	
						else
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 100, 1 )	
						end
					end
					Shell.RemoveNow = 1
					if Shell.DakExplosive then
						Shell.ExplodeNow = true
					end
					Shell.LifeTime = 0
					Shell.DakVelocity = 0
					Shell.DakDamage = 0
				end
			end
		end
		if HitEnt:IsWorld() or Shell.ExplodeNow==true then
			if Shell.DakExplosive then
				local effectdata = EffectData()
				effectdata:SetOrigin(End)
				effectdata:SetEntity(Shell.DakGun)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(Shell.DakBlastRadius)
				util.Effect("daktescalingexplosion", effectdata, true, true)

				Shell.DakGun:SetNWFloat("ExpDamage",Shell.DakSplashDamage)
				if Shell.DakCaliber>=75 then
					Shell.DakGun:SetNWBool("Exploding",true)
					timer.Create( "ExplodeTimer"..Shell.DakGun:EntIndex(), 0.1, 1, function()
						Shell.DakGun:SetNWBool("Exploding",false)
					end)
				else
					local ExpSounds = {}
					if Shell.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
					end
					sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 100, 1 )	
				end
				DTShockwave(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
				DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
			else
				local effectdata = EffectData()
				if Shell.DakIsFlame == 1 then
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(1)
					util.Effect("dakteflameimpact", effectdata, true, true)
					local Targets = ents.FindInSphere( End, 150 )
					if table.Count(Targets) > 0 then
						if table.Count(Targets) > 0 then
							for i = 1, #Targets do
								if Targets[i]:GetClass() == "dak_temotor" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
								if Targets[i]:GetClass() == "dak_tegearbox" then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
									Targets[i].DakBurnStacks = Targets[i].DakBurnStacks+1
								end
								if Targets[i]:IsPlayer() then
									if not Targets[i]:InVehicle() then
										if not(Targets[i]:IsOnFire()) then 
											Targets[i]:Ignite(5,1)
										end
									end
								end
								if Targets[i]:IsNPC() or (Targets[i]:GetClass()=="dak_bot" or Targets[i]:GetClass()=="dak_zombie") then
									if not(Targets[i]:IsOnFire()) then 
										Targets[i]:Ignite(5,1)
									end
								end
							end
						end
					end
					sound.Play( "daktanks/flamerimpact.wav", End, 100, 100, 1 )
				else
					effectdata:SetOrigin(End)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					if Shell.DakDamage == 0 then
						effectdata:SetScale(0.5)
					else
						effectdata:SetScale(Shell.DakCaliber*0.25)
					end
					util.Effect("dakteshellimpact", effectdata, true, true)
					util.Decal( "Impact.Concrete", End-((End-Start):GetNormalized()*5), End+((End-Start):GetNormalized()*5), Shell.DakGun)
					local ExpSounds = {}
					if Shell.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
					end

					if Shell.DakIsPellet then
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 150, 0.25 )	
					else
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], End, 100, 100, 1 )	
					end
				end
			end
			Shell.RemoveNow = 1
			if Shell.DakExplosive then
				Shell.ExplodeNow = true
			end
			Shell.LifeTime = 0
			Shell.DakVelocity = 0
			Shell.DakDamage = 0
		end	

		if Shell.DakPenetration <= 0 then
			Shell.Spent=1
			if Shell.DieTime == nil then
				Shell.DieTime = CurTime()
			end
		end
	end
end

function DTExplosion(Pos,Damage,Radius,Caliber,Pen,Owner,Shell)
	local traces = math.Round(Caliber/2)
	local Filter = {}
	for i=1, traces do
		local Direction = VectorRand()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*Radius*10
			trace.filter = Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local ExpTrace = util.TraceHull( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", Pos, Pos+(Direction*Radius), Shell.DakGun)
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:GetClass()=="dak_bot") then
				if (CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
					if ExpTrace.Entity.DakArmor == nil then
						DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
					end
					local SA = ExpTrace.Entity:GetPhysicsObject():GetSurfaceArea()
					if ExpTrace.Entity.IsDakTekFutureTech == 1 then
						ExpTrace.Entity.DakArmor = 1000
					else
						if SA == nil then
							--Volume = (4/3)*math.pi*math.pow( ExpTrace.Entity:OBBMaxs().x, 3 )
							ExpTrace.Entity.DakArmor = ExpTrace.Entity:OBBMaxs().x/2
							ExpTrace.Entity.DakIsTread = 1
						else
							if ExpTrace.Entity:GetClass()=="prop_physics" then 
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					DamageEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
				else
					if ExpTrace.Entity.DakArmor == nil then
						DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
					end
					local SA = ExpTrace.Entity:GetPhysicsObject():GetSurfaceArea()
					if ExpTrace.Entity.IsDakTekFutureTech == 1 then
						ExpTrace.Entity.DakArmor = 1000
					else
						if SA == nil then
							--Volume = (4/3)*math.pi*math.pow( ExpTrace.Entity:OBBMaxs().x, 3 )
							ExpTrace.Entity.DakArmor = ExpTrace.Entity:OBBMaxs().x/2
							ExpTrace.Entity.DakIsTread = 1
						else
							if ExpTrace.Entity:GetClass()=="prop_physics" then 
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)
						end
					else
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = ExpTrace.Entity:GetModel()
						salvage:SetPos( ExpTrace.Entity:GetPos())
						salvage:SetAngles( ExpTrace.Entity:GetAngles())
						salvage:Spawn()
						ExpTrace.Entity:Remove()
					end
				end
			end
			if ExpTrace.Entity:IsValid() then
				if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity:GetClass() == "dak_bot" then
					if ExpTrace.Entity:GetClass() == "dak_bot" then
						ExpTrace.Entity:SetHealth(ExpTrace.Entity:Health() - (Damage/traces)*500)
						if ExpTrace.Entity:Health() <= 0 and ExpTrace.Entity.revenge==0 then
							local body = ents.Create( "prop_ragdoll" )
							body:SetPos( ExpTrace.Entity:GetPos() )
							body:SetModel( ExpTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							ExpTrace.Entity:Remove()
							local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
							body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
							timer.Simple( 5, function()
								body:Remove()
							end )
						end
					else
						local Pain = DamageInfo()
						Pain:SetDamageForce( Direction*(Damage/traces)*5000*Shell.DakMass )
						Pain:SetDamage( (Damage/traces)*500 )
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( Shell.DakGun )
						Pain:SetReportedPosition( Shell.DakGun:GetPos() )
						Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
						Pain:SetDamageType(DMG_BLAST)
						ExpTrace.Entity:TakeDamageInfo( Pain )
					end
				end
			end

			if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:GetClass()=="dak_bot") then
				if(ExpTrace.Entity:GetParent():IsValid()) then
					if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
						ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*3.5*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
					end
				end
				if not(ExpTrace.Entity:GetParent():IsValid()) then
					ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*3.5*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
				end
			end		
		end
	end
end

function DamageEXP(Filter,IgnoreEnt,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
	local traces = math.Round(Caliber/2)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*Radius*10
		Filter[#Filter+1] = IgnoreEnt
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local ExpTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Concrete", Pos, Pos+(Direction*Radius), Shell.DakGun)
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:GetClass()=="dak_bot") then
			if (CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
				if ExpTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
				end
				local SA = ExpTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if ExpTrace.Entity.IsDakTekFutureTech == 1 then
					ExpTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( ExpTrace.Entity:OBBMaxs().x, 3 )
						ExpTrace.Entity.DakArmor = ExpTrace.Entity:OBBMaxs().x/2
						ExpTrace.Entity.DakIsTread = 1
					else
						if ExpTrace.Entity:GetClass()=="prop_physics" then 
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				DamageEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
			else
				if ExpTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
				end
				local SA = ExpTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if ExpTrace.Entity.IsDakTekFutureTech == 1 then
					ExpTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( ExpTrace.Entity:OBBMaxs().x, 3 )
						ExpTrace.Entity.DakArmor = ExpTrace.Entity:OBBMaxs().x/2
						ExpTrace.Entity.DakIsTread = 1
					else
						if ExpTrace.Entity:GetClass()=="prop_physics" then 
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)
					end
				else
					ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)
				end
				if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = ExpTrace.Entity:GetModel()
					salvage:SetPos( ExpTrace.Entity:GetPos())
					salvage:SetAngles( ExpTrace.Entity:GetAngles())
					salvage:Spawn()
					ExpTrace.Entity:Remove()
				end
			end
		end
		if ExpTrace.Entity:IsValid() then
			if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity:GetClass() == "dak_bot" then
				if ExpTrace.Entity:GetClass() == "dak_bot" then
					ExpTrace.Entity:SetHealth(ExpTrace.Entity:Health() - (Damage/traces)*500)
					if ExpTrace.Entity:Health() <= 0 and ExpTrace.Entity.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( ExpTrace.Entity:GetPos() )
						body:SetModel( ExpTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						ExpTrace.Entity:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Direction*(Damage/traces)*5000*Shell.DakMass )
					Pain:SetDamage( (Damage/traces)*500 )
					Pain:SetAttacker( Owner )
					Pain:SetInflictor( Shell.DakGun )
					Pain:SetReportedPosition( Shell.DakGun:GetPos() )
					Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					ExpTrace.Entity:TakeDamageInfo( Pain )
				end
			end
		end
		if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) then
			if(ExpTrace.Entity:GetParent():IsValid()) then
				if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
					ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*3.5*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
				end
			end
			if not(ExpTrace.Entity:GetParent():IsValid()) then
				ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*3.5*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
			end
		end		
	end
end

function DTShockwave(Pos,Damage,Radius,Pen,Owner,Shell)
	Shell.DakDamageList = {}
	Shell.RemoveList = {}
	Shell.IgnoreList = {}
	local Targets = ents.FindInSphere( Pos, Radius )
	if table.Count(Targets) > 0 then
		for i = 1, #Targets do
			if Targets[i]:IsValid() then
				if hook.Run("DakTankDamageCheck", Targets[i], Owner) ~= false then
				else
					table.insert(Shell.IgnoreList,Targets[i])
				end
				if not(Targets[i].DakHealth == nil) then
					if Targets[i].DakHealth <= 0 or Targets[i]:GetClass() == "dak_salvage" or Targets[i]:GetClass() == "dak_tesalvage" or Targets[i].DakIsTread==1 then
						if IsValid(Targets[i]:GetPhysicsObject()) then
							if Targets[i]:GetPhysicsObject():GetMass()<=1 then
								table.insert(Shell.IgnoreList,Targets[i])
							end
						end
						table.insert(Shell.IgnoreList,Targets[i])
					end
				end
			end
		end

		for i = 1, #Targets do
			if Targets[i]:IsValid() or Targets[i]:IsPlayer() or Targets[i]:IsNPC() then
				local trace = {}
				trace.start = Pos
				trace.endpos = Targets[i]:LocalToWorld( Targets[i]:OBBCenter() )
				trace.filter = Shell.IgnoreList
				trace.mins = Vector(-1,-1,-1)
				trace.maxs = Vector(1,1,1)
				local ExpTrace = util.TraceHull( trace )
				if ExpTrace.Entity == Targets[i] then
					if not(string.Explode("_",Targets[i]:GetClass(),false)[2] == "wire") and not(Targets[i]:IsVehicle()) and not(Targets[i]:GetClass() == "dak_salvage") and not(Targets[i]:GetClass() == "dak_tesalvage") and Targets[i]:GetPhysicsObject():GetMass()>1 and Targets[i].DakIsTread==nil and not(Targets[i]:GetClass() == "dak_turretcontrol") then
						if (not(ExpTrace.Entity:IsPlayer())) and (not(ExpTrace.Entity:IsNPC())) then
							if ExpTrace.Entity.DakArmor == nil then
								DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
							end
							table.insert(Shell.DakDamageList,ExpTrace.Entity)
						else
							if Targets[i]:GetClass() == "dak_bot" then
								Targets[i]:SetHealth(Targets[i]:Health() - Damage*50*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000))*500)
								if Targets[i]:Health() <= 0 and Shell.revenge==0 then
									local body = ents.Create( "prop_ragdoll" )
									body:SetPos( Targets[i]:GetPos() )
									body:SetModel( Targets[i]:GetModel() )
									body:Spawn()
									Targets[i]:Remove()
									local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
									body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
									timer.Simple( 5, function()
										body:Remove()
									end )
								end
							else
								local ExpPain = DamageInfo()
								ExpPain:SetDamageForce( ExpTrace.Normal*Damage*Shell.DakMass*Shell.DakVelocity )
								ExpPain:SetDamage( Damage*50*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000)) )
								ExpPain:SetAttacker( Owner )
								ExpPain:SetInflictor( Shell.DakGun )
								ExpPain:SetReportedPosition( self:GetPos() )
								ExpPain:SetDamagePosition( ExpTrace.Entity:GetPhysicsObject():GetMassCenter() )
								ExpPain:SetDamageType(DMG_BLAST)
								ExpTrace.Entity:TakeDamageInfo( ExpPain )
							end
						end
					end
				end
			end
		end
		for i = 1, #Shell.DakDamageList do
			if(Shell.DakDamageList[i]:IsValid()) then
				if not(Shell.DakDamageList[i]:GetClass() == "dak_bot") then
					if(Shell.DakDamageList[i]:GetParent():IsValid()) then
						if(Shell.DakDamageList[i]:GetParent():GetParent():IsValid()) then
						Shell.DakDamageList[i]:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (Shell.DakDamageList[i]:GetPos()-Pos):GetNormalized()*(Damage/table.Count(Shell.DakDamageList))*1000*2*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/1000)) )
						end
					end
					if not(Shell.DakDamageList[i]:GetParent():IsValid()) then
						Shell.DakDamageList[i]:GetPhysicsObject():ApplyForceCenter( (Shell.DakDamageList[i]:GetPos()-Pos):GetNormalized()*(Damage/table.Count(Shell.DakDamageList))*1000*2*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/1000))  )
					end
				end
			end
			local HPPerc = 0
			if not(Shell.DakDamageList[i].SPPOwner==nil) then
				if Shell.DakDamageList[i].SPPOwner:HasGodMode()==false then	
					if Shell.DakDamageList[i].DakIsTread==nil then
						if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then 
							Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - (  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))
						else
							Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - (  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )
						end
					end
					Shell.DakDamageList[i].DakLastDamagePos = Pos
					if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
						table.insert(Shell.RemoveList,Shell.DakDamageList[i])
					end
				end
			else
				if Shell.DakDamageList[i].DakIsTread==nil then
					if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then 
						Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - (  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))
					else
						Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - (  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )
					end
				end
				Shell.DakDamageList[i].DakLastDamagePos = Pos
				if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
					table.insert(Shell.RemoveList,Shell.DakDamageList[i])
				end
			end

		end
		for i = 1, #Shell.RemoveList do
			Shell.salvage = ents.Create( "dak_tesalvage" )
			Shell.salvage.DakModel = Shell.RemoveList[i]:GetModel()
			Shell.salvage:SetPos( Shell.RemoveList[i]:GetPos())
			Shell.salvage:SetAngles( Shell.RemoveList[i]:GetAngles())
			Shell.salvage.DakLastDamagePos = Pos
			Shell.salvage:Spawn()
			Shell.RemoveList[i]:Remove()
		end
	end
end

function DTSpall(Pos,Armor,Momentum,HitEnt,Caliber,Pen,Owner,Shell)
	local SpallVolume = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)
	local SpallMass = (SpallVolume*0.0078125) * 0.1
	local SpallVelocity = (Momentum/SpallMass) * (Armor/Pen) * 0.1
	local SpallPen = Armor * 0.1
	local SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)*0.1

	local traces = 10
	local Filter = {HitEnt}
	for i=1, traces do
		local Ang = 45*(Armor/Pen)
		local Direction = (Shell.Ang + Angle(math.Rand(-Ang,Ang),math.Rand(-Ang,Ang),math.Rand(-Ang,Ang))):Forward()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local SpallTrace = util.TraceHull( trace )

		if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,HitEnt})
			if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity:GetClass()=="dak_bot") then
				if (CheckClip(SpallTrace.Entity,SpallTrace.HitPos)) or (SpallTrace.Entity:GetPhysicsObject():GetMass()<=1 or (SpallTrace.Entity.DakIsTread==1) and not(SpallTrace.Entity:IsVehicle()) and not(SpallTrace.Entity.IsDakTekFutureTech==1)) then
					if SpallTrace.Entity.DakArmor == nil then
						DakTekTankEditionSetupNewEnt(SpallTrace.Entity)
					end
					local SA = SpallTrace.Entity:GetPhysicsObject():GetSurfaceArea()
					if SpallTrace.Entity.IsDakTekFutureTech == 1 then
						SpallTrace.Entity.DakArmor = 1000
					else
						if SA == nil then
							--Volume = (4/3)*math.pi*math.pow( SpallTrace.Entity:OBBMaxs().x, 3 )
							SpallTrace.Entity.DakArmor = SpallTrace.Entity:OBBMaxs().x/2
							SpallTrace.Entity.DakIsTread = 1
						else
							if SpallTrace.Entity:GetClass()=="prop_physics" then 
								if not(SpallTrace.Entity.DakArmor == 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25) then
									SpallTrace.Entity.DakArmor = 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					DamageSpall(Filter,SpallTrace.Entity,Pos,SpallDamage,SpallPen,Owner,Direction,Shell)
				else
					if SpallTrace.Entity.DakArmor == nil then
						DakTekTankEditionSetupNewEnt(SpallTrace.Entity)
					end
					local SA = SpallTrace.Entity:GetPhysicsObject():GetSurfaceArea()
					if SpallTrace.Entity.IsDakTekFutureTech == 1 then
						SpallTrace.Entity.DakArmor = 1000
					else
						if SA == nil then
							--Volume = (4/3)*math.pi*math.pow( SpallTrace.Entity:OBBMaxs().x, 3 )
							SpallTrace.Entity.DakArmor = SpallTrace.Entity:OBBMaxs().x/2
							SpallTrace.Entity.DakIsTread = 1
						else
							if SpallTrace.Entity:GetClass()=="prop_physics" then 
								if not(SpallTrace.Entity.DakArmor == 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25) then
									SpallTrace.Entity.DakArmor = 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					
					SpallTrace.Entity.DakLastDamagePos = SpallTrace.HitPos

					if not(SpallTrace.Entity.SPPOwner==nil) and not(SpallTrace.Entity.SPPOwner:IsWorld()) then			
						if SpallTrace.Entity.SPPOwner:HasGodMode()==false and SpallTrace.Entity.DakIsTread == nil then	
							SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor)
						end
					else
						SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor)
					end
					if SpallTrace.Entity.DakHealth <= 0 and SpallTrace.Entity.DakPooled==0 then
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = SpallTrace.Entity:GetModel()
						salvage:SetPos( SpallTrace.Entity:GetPos())
						salvage:SetAngles( SpallTrace.Entity:GetAngles())
						salvage:Spawn()
						SpallTrace.Entity:Remove()
					end
				end
			end
			if SpallTrace.Entity:IsValid() then
				if SpallTrace.Entity:IsPlayer() or SpallTrace.Entity:IsNPC() or SpallTrace.Entity:GetClass() == "dak_bot" then
					if SpallTrace.Entity:GetClass() == "dak_bot" then
						SpallTrace.Entity:SetHealth(SpallTrace.Entity:Health() - (SpallDamage)*500)
						if SpallTrace.Entity:Health() <= 0 and SpallTrace.Entity.revenge==0 then
							local body = ents.Create( "prop_ragdoll" )
							body:SetPos( SpallTrace.Entity:GetPos() )
							body:SetModel( SpallTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							SpallTrace.Entity:Remove()
							local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
							body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
							timer.Simple( 5, function()
								body:Remove()
							end )
						end
					else
						local Pain = DamageInfo()
						Pain:SetDamageForce( Direction*(SpallDamage)*5000*Shell.DakMass )
						Pain:SetDamage( (SpallDamage)*500 )
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( Shell.DakGun )
						Pain:SetReportedPosition( Shell.DakGun:GetPos() )
						Pain:SetDamagePosition( SpallTrace.Entity:GetPos() )
						Pain:SetDamageType(DMG_BLAST)
						SpallTrace.Entity:TakeDamageInfo( Pain )
					end
				end
				local effectdata = EffectData()
				effectdata:SetStart(Pos)
				effectdata:SetOrigin(SpallTrace.HitPos)
				effectdata:SetScale(Shell.DakCaliber*0.00393701)
				util.Effect("dakteballistictracer", effectdata)
			else
				local effectdata = EffectData()
				effectdata:SetStart(Pos)
				effectdata:SetOrigin(Pos + Direction*1000)
				effectdata:SetScale(Shell.DakCaliber*0.00393701)
				util.Effect("dakteballistictracer", effectdata)
			end
		end
	end
end

function DamageSpall(Filter,IgnoreEnt,Pos,Damage,Pen,Owner,Direction,Shell)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*1000
		Filter[#Filter+1] = IgnoreEnt
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local SpallTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,IgnoreEnt})
		if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity:GetClass()=="dak_bot") then
			if (CheckClip(SpallTrace.Entity,SpallTrace.HitPos)) or (SpallTrace.Entity:GetPhysicsObject():GetMass()<=1 or (SpallTrace.Entity.DakIsTread==1) and not(SpallTrace.Entity:IsVehicle()) and not(SpallTrace.Entity.IsDakTekFutureTech==1)) then
				if SpallTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(SpallTrace.Entity)
				end
				local SA = SpallTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if SpallTrace.Entity.IsDakTekFutureTech == 1 then
					SpallTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( SpallTrace.Entity:OBBMaxs().x, 3 )
						SpallTrace.Entity.DakArmor = SpallTrace.Entity:OBBMaxs().x/2
						SpallTrace.Entity.DakIsTread = 1
					else
						if SpallTrace.Entity:GetClass()=="prop_physics" then 
							if not(SpallTrace.Entity.DakArmor == 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25) then
								SpallTrace.Entity.DakArmor = 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				DamageSpall(Filter,SpallTrace.Entity,Pos,Damage,Pen,Owner,Direction,Shell)
			else
				if SpallTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(SpallTrace.Entity)
				end
				local SA = SpallTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if SpallTrace.Entity.IsDakTekFutureTech == 1 then
					SpallTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( SpallTrace.Entity:OBBMaxs().x, 3 )
						SpallTrace.Entity.DakArmor = SpallTrace.Entity:OBBMaxs().x/2
						SpallTrace.Entity.DakIsTread = 1
					else
						if SpallTrace.Entity:GetClass()=="prop_physics" then 
							if not(SpallTrace.Entity.DakArmor == 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25) then
								SpallTrace.Entity.DakArmor = 7.8125*(SpallTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - SpallTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				
				SpallTrace.Entity.DakLastDamagePos = SpallTrace.HitPos

				if not(SpallTrace.Entity.SPPOwner==nil) and not(SpallTrace.Entity.SPPOwner:IsWorld()) then			
					if SpallTrace.Entity.SPPOwner:HasGodMode()==false and SpallTrace.Entity.DakIsTread == nil then	
						SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor)
					end
				else
					SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor)
				end
				if SpallTrace.Entity.DakHealth <= 0 and SpallTrace.Entity.DakPooled==0 then
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = SpallTrace.Entity:GetModel()
					salvage:SetPos( SpallTrace.Entity:GetPos())
					salvage:SetAngles( SpallTrace.Entity:GetAngles())
					salvage:Spawn()
					SpallTrace.Entity:Remove()
				end
			end
		end
		if SpallTrace.Entity:IsValid() then
			if SpallTrace.Entity:IsPlayer() or SpallTrace.Entity:IsNPC() or SpallTrace.Entity:GetClass() == "dak_bot" then
				if SpallTrace.Entity:GetClass() == "dak_bot" then
					SpallTrace.Entity:SetHealth(SpallTrace.Entity:Health() - (Damage)*500)
					if SpallTrace.Entity:Health() <= 0 and SpallTrace.Entity.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( SpallTrace.Entity:GetPos() )
						body:SetModel( SpallTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						SpallTrace.Entity:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Direction*(Damage)*5000*Shell.DakMass )
					Pain:SetDamage( (Damage)*500 )
					Pain:SetAttacker( Owner )
					Pain:SetInflictor( Shell.DakGun )
					Pain:SetReportedPosition( Shell.DakGun:GetPos() )
					Pain:SetDamagePosition( SpallTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					SpallTrace.Entity:TakeDamageInfo( Pain )
				end
			end
			local effectdata = EffectData()
			effectdata:SetStart(Pos)
			effectdata:SetOrigin(SpallTrace.HitPos)
			effectdata:SetScale(Shell.DakCaliber*0.00393701)
			util.Effect("dakteballistictracer", effectdata)
		else
			local effectdata = EffectData()
			effectdata:SetStart(Pos)
			effectdata:SetOrigin(Pos + Direction*1000)
			effectdata:SetScale(Shell.DakCaliber*0.00393701)
			util.Effect("dakteballistictracer", effectdata)
		end	
	end
end

