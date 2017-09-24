AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakName = "Base Ammo"
ENT.DakIsExplosive = true
ENT.DakAmmo = 10
ENT.DakArmor = 10
ENT.DakMaxAmmo = 10
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakAmmoType = "Base"
ENT.DakPooled=0


function ENT:Initialize()

	self:SetModel( "models/daktanks/Ammo.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if(IsValid(phys)) then
		phys:Wake()
	end
	self.DakAmmo = self.DakMaxAmmo
	self.DakArmor = 10
	self.Inputs = Wire_CreateInputs(self, { "EjectAmmo" })
	self.Outputs = WireLib.CreateOutputs( self, { "Ammo", "MaxAmmo" } )
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.DumpTime = CurTime()
 	self.DakMaxHealth = 10
	self.DakHealth = 10

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
			util.Effect("dakdamage", effectdata)
			if CurTime()>=self.Soundtime+3 then
				self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.4, 6)
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
			util.Effect("dakdamage", effectdata)
			if CurTime()>=self.Soundtime+2 then
				self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.5, 6)
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
			util.Effect("dakdamage", effectdata)
			if CurTime()>=self.Soundtime+1 then
				self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.6, 6)
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
			util.Effect("dakdamage", effectdata)
			if CurTime()>=self.Soundtime+0.5 then
				self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.75, 6)
				self.Soundtime=CurTime()
			end
		end
		self.SparkTime=CurTime()
	end
	self:GetPhysicsObject():SetMass(200)
	WireLib.TriggerOutput(self, "Ammo", self.DakAmmo)
	WireLib.TriggerOutput(self, "MaxAmmo", self.DakMaxAmmo)

	if self.DakName == "5.56mmMGAPAmmo" then
		self.DakMaxAmmo = 500
	end
	if self.DakName == "7.62mmMGAPAmmo" then
		self.DakMaxAmmo = 425
	end
	if self.DakName == "9mmMGAPAmmo" then
		self.DakMaxAmmo = 350
	end
	if self.DakName == "12.7mmMGAPAmmo" then
		self.DakMaxAmmo = 275
	end
	if self.DakName == "14.5mmMGAPAmmo" then
		self.DakMaxAmmo = 200
	end

	if self.DakName == "20mmHMGAPAmmo" then
		self.DakMaxAmmo = 70
	end
	if self.DakName == "20mmHMGHEAmmo" then
		self.DakMaxAmmo = 70
		self.DakIsHE = true
	end
	if self.DakName == "30mmHMGAPAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "30mmHMGHEAmmo" then
		self.DakMaxAmmo = 50
		self.DakIsHE = true
	end
	if self.DakName == "40mmHMGAPAmmo" then
		self.DakMaxAmmo = 40
	end
	if self.DakName == "40mmHMGHEAmmo" then
		self.DakMaxAmmo = 40
		self.DakIsHE = true
	end

	if self.DakName == "25mmCAPAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "25mmCHEAmmo" then
		self.DakMaxAmmo = 50
		self.DakIsHE = true
	end
	if self.DakName == "25mmCFLAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "37mmCAPAmmo" then
		self.DakMaxAmmo = 35
	end
	if self.DakName == "37mmCHEAmmo" then
		self.DakMaxAmmo = 35
		self.DakIsHE = true
	end
	if self.DakName == "37mmCFLAmmo" then
		self.DakMaxAmmo = 35
	end
	if self.DakName == "50mmCAPAmmo" then
		self.DakMaxAmmo = 20
	end
	if self.DakName == "50mmCHEAmmo" then
		self.DakMaxAmmo = 20
		self.DakIsHE = true
	end
	if self.DakName == "50mmCFLAmmo" then
		self.DakMaxAmmo = 20
	end
	if self.DakName == "75mmCAPAmmo" then
		self.DakMaxAmmo = 15
	end
	if self.DakName == "75mmCHEAmmo" then
		self.DakMaxAmmo = 15
		self.DakIsHE = true
	end
	if self.DakName == "75mmCFLAmmo" then
		self.DakMaxAmmo = 15
	end
	if self.DakName == "100mmCAPAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "100mmCHEAmmo" then
		self.DakMaxAmmo = 10
		self.DakIsHE = true
	end
	if self.DakName == "100mmCFLAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "120mmCAPAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "120mmCHEAmmo" then
		self.DakMaxAmmo = 8
		self.DakIsHE = true
	end
	if self.DakName == "120mmCFLAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "152mmCAPAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "152mmCHEAmmo" then
		self.DakMaxAmmo = 6
		self.DakIsHE = true
	end
	if self.DakName == "152mmCFLAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "200mmCAPAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "200mmCHEAmmo" then
		self.DakMaxAmmo = 4
		self.DakIsHE = true
	end
	if self.DakName == "200mmCFLAmmo" then
		self.DakMaxAmmo = 4
	end

	if self.DakName == "50mmHAPAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "50mmHHEAmmo" then
		self.DakMaxAmmo = 10
		self.DakIsHE = true
	end
	if self.DakName == "50mmHFLAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "75mmHAPAmmo" then
		self.DakMaxAmmo = 7
	end
	if self.DakName == "75mmHHEAmmo" then
		self.DakMaxAmmo = 7
		self.DakIsHE = true
	end
	if self.DakName == "75mmHFLAmmo" then
		self.DakMaxAmmo = 7
	end
	if self.DakName == "105mmHAPAmmo" then
		self.DakMaxAmmo = 5
	end
	if self.DakName == "105mmHHEAmmo" then
		self.DakMaxAmmo = 5
		self.DakIsHE = true
	end
	if self.DakName == "105mmHFLAmmo" then
		self.DakMaxAmmo = 5
	end
	if self.DakName == "122mmHAPAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "122mmHHEAmmo" then
		self.DakMaxAmmo = 4
		self.DakIsHE = true
	end
	if self.DakName == "122mmHFLAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "155mmHAPAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "155mmHHEAmmo" then
		self.DakMaxAmmo = 3
		self.DakIsHE = true
	end
	if self.DakName == "155mmHFLAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "203mmHAPAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "203mmHHEAmmo" then
		self.DakMaxAmmo = 2
		self.DakIsHE = true
	end
	if self.DakName == "203mmHFLAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "420mmHAPAmmo" then
		self.DakMaxAmmo = 1
	end
	if self.DakName == "420mmHHEAmmo" then
		self.DakMaxAmmo = 1
		self.DakIsHE = true
	end
	if self.DakName == "420mmHFLAmmo" then
		self.DakMaxAmmo = 1
	end

	if self.DakName == "60mmMAPAmmo" then
		self.DakMaxAmmo = 16
	end
	if self.DakName == "60mmMHEAmmo" then
		self.DakMaxAmmo = 16
		self.DakIsHE = true
	end
	if self.DakName == "60mmMFLAmmo" then
		self.DakMaxAmmo = 16
	end
	if self.DakName == "90mmMAPAmmo" then
		self.DakMaxAmmo = 12
	end
	if self.DakName == "90mmMHEAmmo" then
		self.DakMaxAmmo = 12
		self.DakIsHE = true
	end
	if self.DakName == "90mmMFLAmmo" then
		self.DakMaxAmmo = 12
	end
	if self.DakName == "120mmMAPAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "120mmMHEAmmo" then
		self.DakMaxAmmo = 8
		self.DakIsHE = true
	end
	if self.DakName == "120mmMFLAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "150mmMAPAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "150mmMHEAmmo" then
		self.DakMaxAmmo = 6
		self.DakIsHE = true
	end
	if self.DakName == "150mmMFLAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "240mmMAPAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "240mmMHEAmmo" then
		self.DakMaxAmmo = 4
		self.DakIsHE = true
	end
	if self.DakName == "240mmMFLAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "280mmMAPAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "280mmMHEAmmo" then
		self.DakMaxAmmo = 3
		self.DakIsHE = true
	end
	if self.DakName == "280mmMFLAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "420mmMAPAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "420mmMHEAmmo" then
		self.DakMaxAmmo = 2
		self.DakIsHE = true
	end
	if self.DakName == "420mmMFLAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "600mmMAPAmmo" then
		self.DakMaxAmmo = 1
	end
	if self.DakName == "600mmMHEAmmo" then
		self.DakMaxAmmo = 1
		self.DakIsHE = true
	end
	if self.DakName == "600mmMFLAmmo" then
		self.DakMaxAmmo = 1
	end

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

	if self.DakAmmo>0 and self.DakHealth<5 and self.DakIsExplosive then
		if self.DakIsHE then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(200)
			util.Effect("daklongtomexplosion", effectdata)

			self.DamageList = {}
			self.RemoveList = {}
			self.IgnoreList = {}
			local Targets = ents.FindInSphere( self:GetPos(), 500 )
			if table.Count(Targets) > 0 then
				for i = 1, #Targets do
					if Targets[i]:IsValid() then
						if hook.Run("DakTankDamageCheck", Targets[i], self.DakOwner) ~= false then
						else
							table.insert(self.IgnoreList,Targets[i])
						end
						if not(Targets[i].DakHealth == nil) then
							if Targets[i].DakHealth <= 0 or Targets[i]:GetClass() == "dak_salvage" or Targets[i]:GetClass() == "dak_tesalvage" or Targets[i].DakIsTread==1 then
								if IsValid(Targets[i]:GetPhysicsObject()) then
									if Targets[i]:GetPhysicsObject():GetMass()<=1 then
										table.insert(self.IgnoreList,Targets[i])
									end
								end
								table.insert(self.IgnoreList,Targets[i])
							end
						end
					end
				end
				table.insert(self.IgnoreList,self)

				for i = 1, #Targets do
					if Targets[i]:IsValid() or Targets[i]:IsPlayer() or Targets[i]:IsNPC() then
						local trace = {}
						trace.start = self:GetPos()
						trace.endpos = Targets[i]:GetPos()
						trace.filter = self.IgnoreList
						local ExpTrace = util.TraceLine( trace )
						if ExpTrace.Entity == Targets[i] then
							if not(string.Explode("_",Targets[i]:GetClass(),false)[2] == "wire") and not(Targets[i]:IsVehicle()) and not(Targets[i]:GetClass() == "dak_salvage") and not(Targets[i]:GetClass() == "dak_tesalvage") and not(Targets[i]:GetClass() == "dak_turretcontrol") then
								if (not(ExpTrace.Entity:IsPlayer())) and (not(ExpTrace.Entity:IsNPC())) then
									if ExpTrace.Entity.DakHealth == nil then
										DakTekSetupNewEnt(ExpTrace.Entity)
									end
									table.insert(self.DamageList,ExpTrace.Entity)
								else
									if Targets[i]:GetClass() == "dak_bot" then
										Targets[i]:SetHealth(Targets[i]:Health() - (200*(self.DakAmmo/self.DakMaxAmmo))*50*(1-(ExpTrace.Entity:GetPos():Distance(self:GetPos())/1000)))
										if Targets[i]:Health() <= 0 and self.revenge==0 then
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
										ExpPain:SetDamageForce( ExpTrace.Normal*(50*(self.DakAmmo/self.DakMaxAmmo))*2500 )
										ExpPain:SetDamage( (200*(self.DakAmmo/self.DakMaxAmmo))*50*(1-(ExpTrace.Entity:GetPos():Distance(self:GetPos())/1000)) )
										ExpPain:SetAttacker( self.DakOwner )
										ExpPain:SetInflictor( self )
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
				for i = 1, #self.DamageList do
					if(self.DamageList[i]:IsValid()) then
						if not(self.DamageList[i]:GetClass() == "dak_bot") then
							if(self.DamageList[i]:GetParent():IsValid()) then
								if(self.DamageList[i]:GetParent():GetParent():IsValid()) then
									self.DamageList[i]:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (self.DamageList[i]:GetPos()-self:GetPos()):GetNormalized()*(250/table.Count(self.DamageList)*(self.DakAmmo/self.DakMaxAmmo))*10000*2*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000)) )
								end
							end
							if not(self.DamageList[i]:GetParent():IsValid()) then
								self.DamageList[i]:GetPhysicsObject():ApplyForceCenter( (self.DamageList[i]:GetPos()-self:GetPos()):GetNormalized()*(250/table.Count(self.DamageList)*(self.DakAmmo/self.DakMaxAmmo))*10000*2*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000))  )
							end
						end
					end
					if not(self.DamageList[i].SPPOwner==nil) then
						if self.DamageList[i].SPPOwner:HasGodMode()==false then	
							local HPPerc = (self.DamageList[i].DakHealth-(500/table.Count(self.DamageList)*(self.DakAmmo/self.DakMaxAmmo))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000)))/self.DamageList[i].DakMaxHealth
							self.DamageList[i].DakHealth = self.DamageList[i].DakHealth-(500/table.Count(self.DamageList)*(self.DakAmmo/self.DakMaxAmmo))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000))
							if not(self.DamageList[i].DakRed == nil) then
								self.DamageList[i]:SetColor(Color(self.DamageList[i].DakRed*HPPerc,self.DamageList[i].DakGreen*HPPerc,self.DamageList[i].DakBlue*HPPerc,self.DamageList[i]:GetColor().a))
							end
							self.DamageList[i].DakLastDamagePos = self:GetPhysicsObject():GetPos()
							if self.DamageList[i].DakHealth <= 0 and self.DamageList[i].DakPooled==0 then
								table.insert(self.RemoveList,self.DamageList[i])
							end
						end
					else
						local HPPerc = (self.DamageList[i].DakHealth-(500/table.Count(self.DamageList)*(self.DakAmmo/self.DakMaxAmmo))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000)))/self.DamageList[i].DakMaxHealth
						self.DamageList[i].DakHealth = self.DamageList[i].DakHealth-(500/table.Count(self.DamageList)*(self.DakAmmo/self.DakMaxAmmo))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000))
						if not(self.DamageList[i].DakRed == nil) then
							self.DamageList[i]:SetColor(Color(self.DamageList[i].DakRed*HPPerc,self.DamageList[i].DakGreen*HPPerc,self.DamageList[i].DakBlue*HPPerc,self.DamageList[i]:GetColor().a))
						end
						self.DamageList[i].DakLastDamagePos = self:GetPhysicsObject():GetPos()
						if self.DamageList[i].DakHealth <= 0 and self.DamageList[i].DakPooled==0 then
							table.insert(self.RemoveList,self.DamageList[i])
						end
					end
				end
				for i = 1, #self.RemoveList do
					self.salvage = ents.Create( "dak_tesalvage" )
					self.salvage.DakModel = self.RemoveList[i]:GetModel()
					self.salvage:SetPos( self.RemoveList[i]:GetPos())
					self.salvage:SetAngles( self.RemoveList[i]:GetAngles())
					self.salvage.DakLastDamagePos = self:GetPhysicsObject():GetPos()
					self.salvage:Spawn()
					self.RemoveList[i]:Remove()
				end
			end
			self:EmitSound( "dak/ammoexplode.wav", 100, 75, 1)
			self:Remove()
		else
			if self.CookingOff == nil then
			timer.Create( "AmmoCookTimer"..self:EntIndex(), 0.10, self.DakAmmo, function()
				if not(self.DakAmmo == nil) then
					if self.DakAmmo > 0 then
						local shootOrigin = self:GetPos()
						local shootAngles = AngleRand()
						local shell = ents.Create( "dak_tankshell" )
		 				if ( !IsValid( shell ) ) then return end
		 				shell:SetPos( shootOrigin + ( self:GetForward() * 1 ))
						shell:SetAngles( shootAngles + Angle(math.Rand(-0.1,0.1),math.Rand(-0.1,0.1),math.Rand(-0.1,0.1)) )



						shell.DakTrail = "dakshelltrail"
						shell.DakVelocity = 5000
						shell.DakDamage = 200/self.DakMaxAmmo
						shell.DakMass = 500/self.DakMaxAmmo
						shell.DakIsPellet = false
						shell.DakSplashDamage = 0
						shell.DakPenetration = 150/self.DakMaxAmmo + 10
						shell.DakExplosive = false
						shell.DakBlastRadius = 0

						if self.DakMaxAmmo<5 then
							self.ShellSounds = {"daktanks/dakhevpen1.wav","daktanks/dakhevpen2.wav","daktanks/dakhevpen3.wav","daktanks/dakhevpen4.wav","daktanks/dakhevpen5.wav"}
						end
						if self.DakMaxAmmo>=5 and self.DakMaxAmmo<=15 then
							self.ShellSounds = {"daktanks/dakmedpen1.wav","daktanks/dakmedpen2.wav","daktanks/dakmedpen3.wav","daktanks/dakmedpen4.wav","daktanks/dakmedpen5.wav"}
						end
						if self.DakMaxAmmo>15 then
							self.ShellSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
						end

						shell.DakPenSounds = self.ShellSounds
						shell.DakBasePenetration = 150/self.DakMaxAmmo + 10
						shell.DakCaliber = 500/self.DakMaxAmmo + 5
						shell.DakGun = self
						shell:Spawn()
						local effectdata = EffectData()
						effectdata:SetOrigin( self:GetPos() )
						effectdata:SetEntity(self)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(50/self.DakMaxAmmo)
						util.Effect("dakshellimpact", effectdata)
						self:EmitSound( self.ShellSounds[math.random(1,#self.ShellSounds)], 100, 100, 1, 1)

						self.DakAmmo = self.DakAmmo - 1
					end
				end
				end )
			self.CookingOff = 1
			end
		end
		
	end

	self:NextThink(CurTime()+1)
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

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakIsExplosive = Ent.EntityMods.DakTek.DakIsExplosive
		self.DakAmmo = Ent.EntityMods.DakTek.DakAmmo
		self.DakMaxAmmo = Ent.EntityMods.DakTek.DakMaxAmmo
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakAmmoType = Ent.EntityMods.DakTek.DakAmmoType
		self.DakOwner = Player

		Ent.EntityMods.DakTekLink = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

	if self.DakName == "5.56mmMGAPAmmo" then
		self.DakMaxAmmo = 500
	end
	if self.DakName == "7.62mmMGAPAmmo" then
		self.DakMaxAmmo = 425
	end
	if self.DakName == "9mmMGAPAmmo" then
		self.DakMaxAmmo = 350
	end
	if self.DakName == "12.7mmMGAPAmmo" then
		self.DakMaxAmmo = 275
	end
	if self.DakName == "14.5mmMGAPAmmo" then
		self.DakMaxAmmo = 200
	end

	if self.DakName == "20mmHMGAPAmmo" then
		self.DakMaxAmmo = 70
	end
	if self.DakName == "20mmHMGHEAmmo" then
		self.DakMaxAmmo = 70
	end
	if self.DakName == "30mmHMGAPAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "30mmHMGHEAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "40mmHMGAPAmmo" then
		self.DakMaxAmmo = 40
	end
	if self.DakName == "40mmHMGHEAmmo" then
		self.DakMaxAmmo = 40
	end

	if self.DakName == "25mmCAPAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "25mmCHEAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "25mmCFLAmmo" then
		self.DakMaxAmmo = 50
	end
	if self.DakName == "37mmCAPAmmo" then
		self.DakMaxAmmo = 35
	end
	if self.DakName == "37mmCHEAmmo" then
		self.DakMaxAmmo = 35
	end
	if self.DakName == "37mmCFLAmmo" then
		self.DakMaxAmmo = 35
	end
	if self.DakName == "50mmCAPAmmo" then
		self.DakMaxAmmo = 20
	end
	if self.DakName == "50mmCHEAmmo" then
		self.DakMaxAmmo = 20
	end
	if self.DakName == "50mmCFLAmmo" then
		self.DakMaxAmmo = 20
	end
	if self.DakName == "75mmCAPAmmo" then
		self.DakMaxAmmo = 15
	end
	if self.DakName == "75mmCHEAmmo" then
		self.DakMaxAmmo = 15
	end
	if self.DakName == "75mmCFLAmmo" then
		self.DakMaxAmmo = 15
	end
	if self.DakName == "100mmCAPAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "100mmCHEAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "100mmCFLAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "120mmCAPAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "120mmCHEAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "120mmCFLAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "152mmCAPAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "152mmCHEAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "152mmCFLAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "200mmCAPAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "200mmCHEAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "200mmCFLAmmo" then
		self.DakMaxAmmo = 4
	end

	if self.DakName == "50mmHAPAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "50mmHHEAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "50mmHFLAmmo" then
		self.DakMaxAmmo = 10
	end
	if self.DakName == "75mmHAPAmmo" then
		self.DakMaxAmmo = 7
	end
	if self.DakName == "75mmHHEAmmo" then
		self.DakMaxAmmo = 7
	end
	if self.DakName == "75mmHFLAmmo" then
		self.DakMaxAmmo = 7
	end
	if self.DakName == "105mmHAPAmmo" then
		self.DakMaxAmmo = 5
	end
	if self.DakName == "105mmHHEAmmo" then
		self.DakMaxAmmo = 5
	end
	if self.DakName == "105mmHFLAmmo" then
		self.DakMaxAmmo = 5
	end
	if self.DakName == "122mmHAPAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "122mmHHEAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "122mmHFLAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "155mmHAPAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "155mmHHEAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "155mmHFLAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "203mmHAPAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "203mmHHEAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "203mmHFLAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "420mmHAPAmmo" then
		self.DakMaxAmmo = 1
	end
	if self.DakName == "420mmHHEAmmo" then
		self.DakMaxAmmo = 1
	end
	if self.DakName == "420mmHFLAmmo" then
		self.DakMaxAmmo = 1
	end

	if self.DakName == "60mmMAPAmmo" then
		self.DakMaxAmmo = 16
	end
	if self.DakName == "60mmMHEAmmo" then
		self.DakMaxAmmo = 16
	end
	if self.DakName == "60mmMFLAmmo" then
		self.DakMaxAmmo = 16
	end
	if self.DakName == "90mmMAPAmmo" then
		self.DakMaxAmmo = 12
	end
	if self.DakName == "90mmMHEAmmo" then
		self.DakMaxAmmo = 12
	end
	if self.DakName == "90mmMFLAmmo" then
		self.DakMaxAmmo = 12
	end
	if self.DakName == "120mmMAPAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "120mmMHEAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "120mmMFLAmmo" then
		self.DakMaxAmmo = 8
	end
	if self.DakName == "150mmMAPAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "150mmMHEAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "150mmMFLAmmo" then
		self.DakMaxAmmo = 6
	end
	if self.DakName == "240mmMAPAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "240mmMHEAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "240mmMFLAmmo" then
		self.DakMaxAmmo = 4
	end
	if self.DakName == "280mmMAPAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "280mmMHEAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "280mmMFLAmmo" then
		self.DakMaxAmmo = 3
	end
	if self.DakName == "420mmMAPAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "420mmMHEAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "420mmMFLAmmo" then
		self.DakMaxAmmo = 2
	end
	if self.DakName == "600mmMAPAmmo" then
		self.DakMaxAmmo = 1
	end
	if self.DakName == "600mmMHEAmmo" then
		self.DakMaxAmmo = 1
	end
	if self.DakName == "600mmMFLAmmo" then
		self.DakMaxAmmo = 1
	end
	self.DakAmmo = self.DakMaxAmmo

end