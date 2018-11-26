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
ENT.HasCrew = 0
ENT.ShellList = {}
ENT.BasicVelocity = 29527.6

function ENT:Initialize()
	--self:SetModel(self.DakModel)
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
	self.Outputs = WireLib.CreateOutputs( self, { "Cooldown" , "CooldownPercent", "MaxCooldown", "Ammo", "AmmoType [STRING]", "MuzzleVel", "ShellMass", "Penetration" } )
 	self.Held = false
 	self.Soundtime = CurTime()
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
			self.DakMass = math.Round(5+(2*math.Round(((((self.DakCaliber*6.5)*(self.DakCaliber*3)*(self.DakCaliber*3))+(math.pi*(self.DakCaliber^2)*(self.DakCaliber*50))-(math.pi*((self.DakCaliber/2)^2)*(self.DakCaliber*50)))*0.001*7.8125)/1000)))

			self.DakAP = math.Round(self.DakCaliber,2).."mmMGAPAmmo"

			self.BaseDakShellDamage = (math.pi*((self.DakCaliber*0.02*0.5)^2)*(self.DakCaliber*0.02*6.5))*25
			--get the volume of shell and multiply by density of steel
			--pi*radius^2 * height * density
			--Shell length ratio: Cannon - 6.5, Howitzer - 4, Mortar - 2.75
			self.BaseDakShellMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*6.5))*7700
			self.DakShellSplashDamage = self.DakCaliber*0.0375
			self.BaseDakShellPenetration = (self.DakCaliber*2)*(50/50)
			self.DakShellExplosive = false
			self.DakShellBlastRadius = (self.DakCaliber/10*39)
			self.DakBaseShellFragPen = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*5))*4850

			self.DakFireEffect = "dakteballisticfire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteballistictracer"
			self.BaseDakShellVelocity = self.BasicVelocity
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
		end
		--Machine Guns
		if self.DakGunType == "Flamethrower" then
			self.DakName = "Flamethrower"
			self.DakCooldown = 0.1
			self.DakMaxHealth = 10
			self.DakArmor = 50
			self.DakMass = 50

			self.DakAP = "Flamethrower Fuel"

			self.BaseDakShellDamage = 0.2*25
			self.BaseDakShellMass = 1
			self.DakShellSplashDamage = 0.2
			self.BaseDakShellPenetration = 0.0001
			self.DakShellExplosive = false
			self.DakShellBlastRadius = 15

			self.DakFireEffect = "dakteflamefire"
			self.DakFirePitch = 100
			self.DakShellTrail = "dakteflametrail"
			self.BaseDakShellVelocity = 5000
			self.DakPellets = 10

			self.DakShellPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
			self.ReloadSound = "daktanks/dakreloadlight.wav"

			if self.DakFireSound == nil then
				self.DakFireSound = "daktanks/flamerfire.wav"
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

	if CurTime()>=self.MidThinkTime+0.33 then
		self:DakTEAmmoCheck()

		WireLib.TriggerOutput(self, "Cooldown", math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100))
		WireLib.TriggerOutput(self, "CooldownPercent", 100*(math.Clamp((self.LastFireTime+self.DakCooldown)-CurTime(),0,100)/self.DakCooldown))
		WireLib.TriggerOutput(self, "MaxCooldown",self.DakCooldown)
		self.MidThinkTime = CurTime()
	end

	for i = 1, #self.ShellList do
		self.ShellList[i].LifeTime = self.ShellList[i].LifeTime + 0.1
		self.ShellList[i].Gravity = physenv.GetGravity()*self.ShellList[i].LifeTime

		local trace = {}
			trace.start = self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * (self.ShellList[i].LifeTime-0.1)) - (-physenv.GetGravity()*((self.ShellList[i].LifeTime-0.1)^2)/2)
			trace.endpos = self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * self.ShellList[i].LifeTime) - (-physenv.GetGravity()*(self.ShellList[i].LifeTime^2)/2)
			trace.filter = self.ShellList[i].Filter
			trace.mins = Vector(-self.ShellList[i].DakCaliber*0.02,-self.ShellList[i].DakCaliber*0.02,-self.ShellList[i].DakCaliber*0.02)
			trace.maxs = Vector(self.ShellList[i].DakCaliber*0.02,self.ShellList[i].DakCaliber*0.02,self.ShellList[i].DakCaliber*0.02)
		local ShellTrace = util.TraceHull( trace )

		local effectdata = EffectData()
		effectdata:SetStart(ShellTrace.StartPos)
		effectdata:SetOrigin(ShellTrace.HitPos)
		effectdata:SetScale((self.ShellList[i].DakCaliber*0.0393701))
		util.Effect(self.DakShellTrail, effectdata, true, true)

		if ShellTrace.Hit then
			if self.ShellList[i].IsGuided then
				DTShellHit(ShellTrace.StartPos,self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*0.1),ShellTrace.Entity,self.ShellList[i],ShellTrace.HitNormal)
			else
				DTShellHit(ShellTrace.StartPos,self.ShellList[i].Pos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward() * self.ShellList[i].LifeTime) - (-physenv.GetGravity()*(self.ShellList[i].LifeTime^2)/2),ShellTrace.Entity,self.ShellList[i],ShellTrace.HitNormal)
			end
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
		if self.DakName == "Flamethrower" then
			WireLib.TriggerOutput(self, "AmmoType", "Fuel")
		else
			WireLib.TriggerOutput(self, "AmmoType", "Armor Piercing")
		end
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
				local shootAngles = (self:GetVelocity()+self:GetForward()*self.DakShellVelocity):GetNormalized():Angle()
				if self:GetParent():IsValid() then
					if self:GetParent():GetParent():IsValid() then
						local shootAngles = (self:GetParent():GetParent():GetVelocity()+self:GetForward()*self.DakShellVelocity):GetNormalized():Angle()
					end
				end
				local shootDir = shootAngles:Forward()
				
 				local Shell = {}
 				Shell.Pos = shootOrigin + ( self:GetForward() * 1 )
 				Shell.Ang = shootAngles + Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1))
				Shell.DakTrail = self.DakShellTrail
				Shell.DakVelocity = self.DakShellVelocity * math.Rand( 0.95, 1.05 )
				Shell.DakDamage = self.DakShellDamage * math.Rand( 0.99, 1.01 )
				Shell.DakMass = self.DakShellMass
				Shell.DakIsPellet = false
				Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.99, 1.01 )
				Shell.DakPenetration = self.DakShellPenetration * math.Rand( 0.99, 1.01 )
				Shell.DakExplosive = self.DakShellExplosive
				Shell.DakBlastRadius = self.DakShellBlastRadius
				Shell.DakPenSounds = self.DakShellPenSounds
				Shell.DakBasePenetration = self.BaseDakShellPenetration
				Shell.DakFragPen = self.DakBaseShellFragPen
				Shell.DakCaliber = self.DakMaxHealth
				Shell.DakFireSound = self.DakFireSound
				Shell.DakFirePitch = self.DakFirePitch
				Shell.DakGun = self
				Shell.Filter = table.Copy(self.DakTankCore.Contraption)
				Shell.LifeTime = 0
				Shell.Gravity = 0
				Shell.DakPenLossPerMeter = self.DakPenLossPerMeter
				Shell.DakShellType = self.DakShellAmmoType
				if self.DakShellAmmoType == "HESH" or self.DakShellAmmoType == "HEAT" then
					Shell.DakFragPen = self.DakBaseShellFragPen * 0.5
					Shell.DakBlastRadius = self.DakShellBlastRadius * 0.5
					Shell.DakSplashDamage = self.DakShellSplashDamage * math.Rand( 0.99, 1.01 ) * 0.5
				end
				if self.DakName == "Flamethrower" then
					Shell.DakIsFlame = 1
				end
				self.ShellList[#self.ShellList+1] = Shell

				self:SetNWString("FireSound",self.DakFireSound)
				self:SetNWInt("FirePitch",self.DakFirePitch)
				self:SetNWFloat("Caliber",self.DakCaliber)

				if self.DakCaliber>=40 then
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
				if (self:IsValid()) then
					if(self.DakTankCore:GetParent():IsValid()) then
						if(self.DakTankCore:GetParent():GetParent():IsValid()) then
							self.DakTankCore:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -self:GetForward()*self.DakShellVelocity*self.BaseDakShellMass/(self.DakTankCore.TotalMass/self.DakTankCore.PhysMass), self:GetPos() )
						end
					end
					if not(self.DakTankCore:GetParent():IsValid()) then
						self:GetPhysicsObject():ApplyForceCenter( -self:GetForward()*self.DakShellVelocity*self.BaseDakShellMass/20/(self.DakTankCore.TotalMass/self.DakTankCore.PhysMass) )
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


--[[
function GetAncestor ( Entity )
    if not IsValid(Entity) return end
    
    local Parent = Entity
    
    while Parent:GetParent() do
        Parent = Parent:GetParent()
    end
    
    return Parent
end
]]--