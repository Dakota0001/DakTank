AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakName = "Base Ammo"
ENT.DakIsExplosive = true
--ENT.DakAmmo = 10
ENT.DakArmor = 5
--ENT.DakMaxAmmo = 10
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakAmmoType = "Base"
ENT.DakPooled=0

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	--local phys = self:GetPhysicsObject()

	
	--self.DakAmmo = self.DakMaxAmmo
	
	self.Inputs = Wire_CreateInputs(self, { "EjectAmmo" })
	self.Outputs = WireLib.CreateOutputs( self, { "Ammo", "MaxAmmo" } )
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.DumpTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.DakArmor = 5
 	self.DakMaxHealth = 30
	self.DakHealth = 30
	self.DakBurnStacks = 0

	function self:SetupDataTables()
 		self:NetworkVar("Bool",0,"Firing")
 	end
end

function ENT:Think()
	if CurTime()>=self.SparkTime+0.33 then
		if self.DakHealth<=(self.DakMaxHealth*0.80) and self.DakHealth>(self.DakMaxHealth*0.60) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(1)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+3 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.4, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.60) and self.DakHealth>(self.DakMaxHealth*0.40) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(2)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+2 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.5, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.40) and self.DakHealth>(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(3)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+1 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.6, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(4)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+0.5 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.75, 6)
				self.Soundtime=CurTime()
			end
		end
		self.SparkTime=CurTime()
	end
	if CurTime()>=self.SlowThinkTime+1 then
		if not(self.DakName == "Base Ammo") then
			self.DakCaliber = tonumber(string.Split( self.DakName, "m" )[1])
			if self.DakAmmoType == "Flamethrower Fuel" then
				self.DakMaxAmmo = 150
				if not(self.DakAmmo) then
					self.DakAmmo = self.DakMaxAmmo
				end
				if self.DakAmmo > self.DakMaxAmmo then
					self.DakAmmo = self.DakMaxAmmo
				end
			else
				-- steel density 0.132 kg/in3
				--cannon
				self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
				self.ShellMass = self.ShellVolume*0.044
				self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
				self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				--short cannon and hmg
				if (string.Split( self.DakName, "m" )[3][1] == "S" and string.Split( self.DakName, "m" )[3][2] == "C") or (string.Split( self.DakName, "m" )[3][1] == "H" and string.Split( self.DakName, "m" )[3][2] == "M" and string.Split( self.DakName, "m" )[3][3] == "G") then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*10)
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*10)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				end
				--long cannon
				if string.Split( self.DakName, "m" )[3][1] == "L" and string.Split( self.DakName, "m" )[3][2] == "C" then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*18)
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*18)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				end
				--Howitzer
				if string.Split( self.DakName, "m" )[3][1] == "H" and string.Split( self.DakName, "m" )[3][2] ~= "M" then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*8)
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*8)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				end
				--Mortar
				if string.Split( self.DakName, "m" )[3][1] == "M" and string.Split( self.DakName, "m" )[3][2] ~= "G" then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*5.5)
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*5.5)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				end
				--Grenade Launcher
				if string.Split( self.DakName, "m" )[3][1] == "G" and string.Split( self.DakName, "m" )[3][2] == "L" then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*7)
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*7)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				end
				--Smoke Launcher
				if string.Split( self.DakName, "m" )[3][1] == "S" and string.Split( self.DakName, "m" )[3][2] == "L" then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*2.75)
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*2.75)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
				end
				--ATGM
				if (string.Split( self.DakName, "m" )[3][2]..string.Split( self.DakName, "m" )[3][3]..string.Split( self.DakName, "m" )[3][4]..string.Split( self.DakName, "m" )[3][5]) == "ATGM" then
					self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
					self.ShellMass = self.ShellVolume*0.044
					self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
					self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
					self.DakMaxAmmo = math.floor(self.DakMaxAmmo*(1/1.5))
					self.ShellVolume = self.ShellVolume*1.5
				end
				self.ShellMass = self.ShellVolume*0.044
				if self.DakAmmo == nil then 
					self.DakAmmo = self.DakMaxAmmo
				end
				if self.DakAmmo > self.DakMaxAmmo then
					self.DakAmmo = self.DakMaxAmmo
				end
			end
		end
			--if self.DakAmmoType == "Flamethrower Fuel" then
			--	self:SetModel( "models/props_c17/canister_propane01a.mdl" )
			--else
			--	self:SetModel( "models/daktanks/Ammo.mdl" )
			--end
		if self.DakAmmoType == "Flamethrower Fuel" then
			self.DakArmor = 12.5
		 	self.DakMaxHealth = 30
		 	if self.DakHealth >= self.DakMaxHealth then
				self.DakHealth = 30
			end
			if self:GetPhysicsObject():GetMass() ~= 500 then self:GetPhysicsObject():SetMass(500) end
		else
			self.DakArmor = 5
		 	self.DakMaxHealth = 10
		 	if self.DakHealth >= self.DakMaxHealth then
				self.DakHealth = 10
			end
			if self.ShellMass == nil then
				if self:GetPhysicsObject():GetMass() ~= 10 then self:GetPhysicsObject():SetMass(10) end
			else
				if self:GetPhysicsObject():GetMass() ~= math.Round((self.ShellMass*self.DakAmmo)+10) then self:GetPhysicsObject():SetMass(math.Round((self.ShellMass*self.DakAmmo)+10)) end
			end
		end
		
		WireLib.TriggerOutput(self, "Ammo", self.DakAmmo)
		WireLib.TriggerOutput(self, "MaxAmmo", self.DakMaxAmmo)

		self.DakEjectAmmo = self.Inputs.EjectAmmo.Value
		if self.DakEjectAmmo == 1 then
			if CurTime()>=self.DumpTime+0.5 then
				if self.DakAmmo>0 then
					self.DakAmmo = self.DakAmmo - math.Round(self.DakMaxAmmo/10,0)
					if self.DakAmmo < 0 then
						self.DakAmmo = 0
					end
					self:EmitSound( "dak/Jam.wav", 100, 75, 1)
					self.DumpTime = CurTime()
				end
			end
		end
		if self.DakAmmo then
			if self.DakAmmo>0 and self.DakHealth<(self.DakMaxHealth/2) and self.DakIsExplosive then
				if self.DakIsHE then
					local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetEntity(self)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(500)
					effectdata:SetNormal( Vector(0,0,-1) )
					util.Effect("daktescalingexplosionold", effectdata, true, true)
					timer.Create( "AmmoBurnTimer"..self:EntIndex(), 0.1, 5, function()
						if not(self.DakAmmo == nil) then
							if self.DakAmmo > 0 then
								local effectdata2 = EffectData()
								effectdata2:SetOrigin(self:GetPos())
								effectdata2:SetEntity(self)
								effectdata2:SetAttachment(1)
								effectdata2:SetMagnitude(.5)
								effectdata2:SetScale((self.DakAmmo/self.DakMaxAmmo)*350)
								effectdata2:SetNormal( Vector(0,0,1) )
								util.Effect("dakteammocook", effectdata2, true, true)
							end
						end
					end )
					self:DTExplosion(self:GetPos(),5000*(self.DakAmmo/self.DakMaxAmmo),500,500,300,self.DakOwner)
					--self:EmitSound( "daktanks/ammoexplode.mp3", 100, 75, 1)
					sound.Play( "daktanks/ammoexplode.mp3", self:GetPos(), 100, 75, 1 )
					timer.Create( "RemoveTimer"..self:EntIndex(), 0.5, 1, function()
						if self:IsValid() then
							self:Remove()
						end
					end)
				else
					if self.CookingOff == nil then
						timer.Create( "AmmoDetTimer"..self:EntIndex(), math.Rand(0.5,2), self.DakAmmo, function()
							if not(self.DakAmmo == nil) then
								if self.DakAmmo > 0 then
									local effectdata = EffectData()
									effectdata:SetOrigin(self:GetPos())
									effectdata:SetEntity(self)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetScale((self.DakAmmo/self.DakMaxAmmo)*350)
									effectdata:SetNormal( Vector(0,0,-1) )
									util.Effect("daktescalingexplosionold", effectdata, true, true)

									self:DTExplosion(self:GetPos(),5000*(self.DakAmmo/self.DakMaxAmmo),500,500,200,self.DakOwner)

									--self:EmitSound( "daktanks/ammoexplode.mp3", 100, 75, 1)
									sound.Play( "daktanks/ammoexplode.mp3", self:GetPos(), 100, 75, 1 )
									self:Remove()
								end
							end
						end)		
						timer.Create( "AmmoBurnTimer"..self:EntIndex(), 0.25, 100, function()
							if not(self.DakAmmo == nil) then
								if self.DakAmmo > 0 then
									local effectdata2 = EffectData()
									effectdata2:SetOrigin(self:GetPos())
									effectdata2:SetEntity(self)
									effectdata2:SetAttachment(1)
									effectdata2:SetMagnitude(.5)
									effectdata2:SetScale((self.DakAmmo/self.DakMaxAmmo)*350)
									effectdata2:SetNormal( Vector(0,0,1) )
									util.Effect("dakteammocook", effectdata2, true, true)
								end
							end
						end )
						timer.Create( "AmmoCookTimer"..self:EntIndex(), math.Clamp((1/math.pow((self.DakMaxAmmo),0.5)),0.075,2)*math.Rand(0.75,1.25), self.DakAmmo, function()
							if not(self.DakAmmo == nil) then
								if self.DakAmmo > 0 then
									local shootOrigin = self:GetPos()
									local shootAngles = AngleRand()
									if self.DakMaxAmmo<5 then
										self.ShellSounds = {"daktanks/dakhevpen1.mp3","daktanks/dakhevpen2.mp3","daktanks/dakhevpen3.mp3","daktanks/dakhevpen4.mp3","daktanks/dakhevpen5.mp3"}
									end
									if self.DakMaxAmmo>=5 and self.DakMaxAmmo<=15 then
										self.ShellSounds = {"daktanks/dakmedpen1.mp3","daktanks/dakmedpen2.mp3","daktanks/dakmedpen3.mp3","daktanks/dakmedpen4.mp3","daktanks/dakmedpen5.mp3"}
									end
									if self.DakMaxAmmo>15 then
										self.ShellSounds = {"daktanks/daksmallpen1.mp3","daktanks/daksmallpen2.mp3","daktanks/daksmallpen3.mp3","daktanks/daksmallpen4.mp3"}
									end
									local shell = {}
					 				shell.Pos = shootOrigin + ( self:GetForward() * 1 )
					 				shell.Ang = shootAngles + Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1))
									shell.DakTrail = "dakshelltrail"
									shell.DakVelocity = 5000
									shell.DakDamage = math.Clamp(200/self.DakMaxAmmo,1,200)
									shell.DakMass = 500/self.DakMaxAmmo
									shell.DakIsPellet = false
									shell.DakSplashDamage = 0
									shell.DakPenetration = 150/self.DakMaxAmmo + 10
									shell.DakExplosive = false
									shell.DakBlastRadius = 0
									shell.DakPenSounds = self.ShellSounds
									shell.DakBasePenetration = 150/self.DakMaxAmmo + 10
									shell.DakCaliber = 500/self.DakMaxAmmo + 5
									shell.DakFireSound = self.ShellSounds[math.random(1,#self.ShellSounds)]
									shell.DakFirePitch = 100
									shell.DakGun = self
									shell.Filter = {self}
									shell.LifeTime = 0
									shell.Gravity = 0
									shell.DakPenLossPerMeter = 0.0005
									if self.DakName == "Flamethrower" then
										shell.DakIsFlame = 1
									end
									DakTankShellList[#DakTankShellList+1] = Shell
									local effectdata = EffectData()
									effectdata:SetOrigin( self:GetPos() )
									effectdata:SetEntity(self)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetScale(50/self.DakMaxAmmo)
									util.Effect("dakteshellimpact", effectdata, true, true)
									--self:EmitSound( self.ShellSounds[math.random(1,#self.ShellSounds)], 100, 100, 1, 1)
									sound.Play( self.ShellSounds[math.random(1,#self.ShellSounds)], self:GetPos(), 100, 100, 1 )

									self.DakAmmo = self.DakAmmo - 1
								end
							end
						end )
						self.CookingOff = 1
					end
				end

			end
		end
		self.SlowThinkTime = CurTime()
	end

	if self:IsOnFire() then
		self.DakHealth = self.DakHealth - 0.1
		if self.DakHealth <= 0 then
			local salvage = ents.Create( "dak_tesalvage" )
			salvage.DakModel = self:GetModel()
			salvage:SetPos( self:GetPos())
			salvage:SetAngles( self:GetAngles())
			salvage:Spawn()
			self:Remove()
		end
	end
	
	self:NextThink( CurTime()+0.1 )
    return true
end


function ENT:PreEntityCopy()

	local info = {}
	local entids = {}


	info.DakName = self.DakName
	info.DakIsExplosive = self.DakIsExplosive
	info.DakAmmo = self.DakMaxAmmo
	info.DakMaxAmmo = self.DakMaxAmmo
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakAmmoType = self.DakAmmoType
	info.DakOwner = self.DakOwner
	info.DakIsHE = self.DakIsHE

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakIsExplosive = Ent.EntityMods.DakTek.DakIsExplosive
		self.DakAmmo = Ent.EntityMods.DakTek.DakMaxAmmo
		self.DakMaxAmmo = Ent.EntityMods.DakTek.DakMaxAmmo
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakAmmoType = Ent.EntityMods.DakTek.DakAmmoType
		self.DakOwner = Player
		self.DakIsHE = Ent.EntityMods.DakTek.DakIsHE

		Ent.EntityMods.DakTekLink = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )


	self.DakCaliber = tonumber(string.Split( self.DakName, "m" )[1])
	if self.DakAmmoType == "Flamethrower Fuel" then
		self.DakMaxAmmo = 150
		if not(self.DakAmmo) then
			self.DakAmmo = self.DakMaxAmmo
		end
		if self.DakAmmo > self.DakMaxAmmo then
			self.DakAmmo = self.DakMaxAmmo
		end
	else
		-- steel density 0.132 kg/in3
		self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
		self.ShellMass = self.ShellVolume*0.044
		self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
		self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		if (string.Split( self.DakName, "m" )[3][1] == "S" and string.Split( self.DakName, "m" )[3][2] == "C") or (string.Split( self.DakName, "m" )[3][1] == "H" and string.Split( self.DakName, "m" )[3][2] == "M" and string.Split( self.DakName, "m" )[3][3] == "G") then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*10)
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*10)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		end
		if string.Split( self.DakName, "m" )[3][1] == "L" and string.Split( self.DakName, "m" )[3][2] == "C" then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*18)
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*18)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		end
		if string.Split( self.DakName, "m" )[3][1] == "H" and string.Split( self.DakName, "m" )[3][2] ~= "M" then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*8)
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*8)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		end
		if string.Split( self.DakName, "m" )[3][1] == "M" and string.Split( self.DakName, "m" )[3][2] ~= "G" then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*5.5)
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*5.5)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		end
		if string.Split( self.DakName, "m" )[3][1] == "G" and string.Split( self.DakName, "m" )[3][2] == "L" then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*7)
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*7)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		end
		if string.Split( self.DakName, "m" )[3][1] == "S" and string.Split( self.DakName, "m" )[3][2] == "L" then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*2.75)
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*2.75)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
		end
		if (string.Split( self.DakName, "m" )[3][2]..string.Split( self.DakName, "m" )[3][3]..string.Split( self.DakName, "m" )[3][4]..string.Split( self.DakName, "m" )[3][5]) == "ATGM" then
			self.ShellVolume = math.pi*(((self.DakCaliber*0.5)*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
			self.ShellMass = self.ShellVolume*0.044
			self.ShellSquareVolume = ((self.DakCaliber*0.0393701)^2)*(self.DakCaliber*0.0393701*13)
			self.DakMaxAmmo = math.floor(self:GetPhysicsObject():GetVolume()/self.ShellSquareVolume)
			self.DakMaxAmmo = math.floor(self.DakMaxAmmo*(1/1.5))
			self.ShellVolume = self.ShellVolume*1.5
		end
		self.ShellMass = self.ShellVolume*0.044
		if self.DakAmmo == nil then 
			self.DakAmmo = self.DakMaxAmmo
		end
		if self.DakAmmo > self.DakMaxAmmo then
			self.DakAmmo = self.DakMaxAmmo
		end
	end
	self.DakAmmo = self.DakMaxAmmo

end

function ENT:CheckClip(Ent, HitPos)
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
--[[
function ENT:DTExplosion(Pos,Damage,Radius,Caliber,Pen,Owner)
	local traces = math.Round(Caliber/2)
	local Filter = {self}
	for i=1, traces do
		local Direction = VectorRand()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*Radius*10
			trace.filter = Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local ExpTrace = util.TraceHull( trace )

		if ExpTrace.Entity:IsValid() then
			if ExpTrace.Entity:GetClass() == self:GetClass() then
				ExpTrace.Entity =  NULL
			end 
		end
		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", Pos, Pos+(Direction*Radius), self)
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:GetClass()=="dak_bot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0)) then
				if (self:CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
					if ExpTrace.Entity.DakArmor == nil or ExpTrace.Entity.DakBurnStacks == nil then
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
								DTArmorSanityCheck(ExpTrace.Entity)
							end
						end
					end
					self:DamageEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
				else
					if ExpTrace.Entity.DakArmor == nil or ExpTrace.Entity.DakBurnStacks == nil then
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
								DTArmorSanityCheck(ExpTrace.Entity)
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
						end
					else
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						Filter[#Filter+1] = ExpTrace.Entity
						self.salvage = ents.Create( "dak_tesalvage" )
						self.salvage.DakModel = ExpTrace.Entity:GetModel()
						self.salvage:SetPos( ExpTrace.Entity:GetPos())
						self.salvage:SetAngles( ExpTrace.Entity:GetAngles())
						self.salvage:Spawn()
						Filter[#Filter+1] = self.salvage
						ExpTrace.Entity:Remove()
					end
				end
			end
			if ExpTrace.Entity:IsValid() then
				if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity:GetClass() == "dak_bot" then
					if ExpTrace.Entity:GetClass() == "dak_bot" then
						ExpTrace.Entity:SetHealth(ExpTrace.Entity:Health() - (Damage/traces)*500)
						if ExpTrace.Entity:Health() <= 0 and self.revenge==0 then
							local body = ents.Create( "prop_ragdoll" )
							body:SetPos( ExpTrace.Entity:GetPos() )
							body:SetModel( ExpTrace.Entity:GetModel() )
							body:Spawn()
							ExpTrace.Entity:Remove()
							local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
							body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
							timer.Simple( 5, function()
								body:Remove()
							end )
						end
					else
						local Pain = DamageInfo()
						Pain:SetDamageForce( Direction*(Damage/traces)*5000*self:GetPhysicsObject():GetMass() )
						Pain:SetDamage( (Damage/traces)*500 )
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( self )
						Pain:SetReportedPosition( Pos )
						Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
						Pain:SetDamageType(DMG_BLAST)
						ExpTrace.Entity:TakeDamageInfo( Pain )
					end
				end
			end

			if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) then
				if(ExpTrace.Entity:GetParent():IsValid()) then
					if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
						ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( 0.01*(ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
					end
				end
				if not(ExpTrace.Entity:GetParent():IsValid()) then
					ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( 0.01*(ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
				end
			end		
		end
	end
end

function ENT:DamageEXP(Filter,IgnoreEnt,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
	local traces = math.Round(Caliber/2)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*Radius*10
		Filter[#Filter+1] = IgnoreEnt
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local ExpTrace = util.TraceHull( trace )

	if ExpTrace.Entity:IsValid() then
		if ExpTrace.Entity:GetClass() == self:GetClass() then
			ExpTrace.Entity =  NULL
		end 
	end

	if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Concrete", Pos, Pos+(Direction*Radius), self)
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:GetClass()=="dak_bot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0)) then
			if (self:CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
				if ExpTrace.Entity.DakArmor == nil or ExpTrace.Entity.DakBurnStacks == nil then
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
							DTArmorSanityCheck(ExpTrace.Entity)
						end
					end
				end
				self:DamageEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
			else
				if ExpTrace.Entity.DakArmor == nil or ExpTrace.Entity.DakBurnStacks == nil then
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
							DTArmorSanityCheck(ExpTrace.Entity)
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
					end
				else
					ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
				end
				if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
					Filter[#Filter+1] = ExpTrace.Entity
					self.salvage = ents.Create( "dak_tesalvage" )
					self.salvage.DakModel = ExpTrace.Entity:GetModel()
					self.salvage:SetPos( ExpTrace.Entity:GetPos())
					self.salvage:SetAngles( ExpTrace.Entity:GetAngles())
					self.salvage:Spawn()
					Filter[#Filter+1] = self.salvage
					ExpTrace.Entity:Remove()
				end
			end
		end
		if ExpTrace.Entity:IsValid() then
			if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity:GetClass() == "dak_bot" then
				if ExpTrace.Entity:GetClass() == "dak_bot" then
					ExpTrace.Entity:SetHealth(ExpTrace.Entity:Health() - (Damage/traces)*500)
					if ExpTrace.Entity:Health() <= 0 and self.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( ExpTrace.Entity:GetPos() )
						body:SetModel( ExpTrace.Entity:GetModel() )
						body:Spawn()
						ExpTrace.Entity:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Direction*(Damage/traces)*5000*self:GetPhysicsObject():GetMass() )
					Pain:SetDamage( (Damage/traces)*500 )
					Pain:SetAttacker( Owner )
					Pain:SetInflictor( self )
					Pain:SetReportedPosition( Pos )
					Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					ExpTrace.Entity:TakeDamageInfo( Pain )
				end
			end
		end
		if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) then
			if(ExpTrace.Entity:GetParent():IsValid()) then
				if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
					ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( 0.01*(ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
				end
			end
			if not(ExpTrace.Entity:GetParent():IsValid()) then
				ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( 0.01*(ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
			end
		end		
	end
end
]]--