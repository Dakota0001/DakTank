AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakName = "Autoloader Module"
ENT.DakIsExplosive = true
ENT.DakArmor = 10
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakPooled=0
ENT.DakGun = nil

function ENT:Initialize()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if(IsValid(phys)) then
		phys:Wake()
	end
	self.DakArmor = 10
	self.DakMass = 1000
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()

 	if self.DakHealth>self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
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

		if self.DakName == "Small Autoloader Clip" then
			self.DakMass = 1000
			if IsValid(self.DakGun) then
				if self.DakGun.IsAutoLoader == 1 then
					self.DakGun.DakClip = math.Round(600/self.DakGun.DakCaliber)
					self.DakGun.DakReloadTime = ((self.DakGun.DakCaliber/13)+(self.DakGun.DakCaliber/100)) * self.DakGun.DakClip
					self.DakGun.Loaded = 1
				end
			end
		end
		if self.DakName == "Medium Autoloader Clip" then
			self.DakMass = 2000
			if IsValid(self.DakGun) then
				if self.DakGun.IsAutoLoader == 1 then
					self.DakGun.DakClip = math.Round(600/self.DakGun.DakCaliber*1.5)
					self.DakGun.DakReloadTime = ((self.DakGun.DakCaliber/13)+(self.DakGun.DakCaliber/100)) * self.DakGun.DakClip * 0.75
					self.DakGun.Loaded = 1
				end
			end
		end
		if self.DakName == "Large Autoloader Clip" then
			self.DakMass = 3000
			if IsValid(self.DakGun) then
				if self.DakGun.IsAutoLoader == 1 then
					self.DakGun.DakClip = math.Round(600/self.DakGun.DakCaliber*2)
					self.DakGun.DakReloadTime = ((self.DakGun.DakCaliber/13)+(self.DakGun.DakCaliber/100)) * self.DakGun.DakClip * 0.5
					self.DakGun.Loaded = 1
				end
			end
		end

		if self.DakHealth > self.DakMaxHealth then
			self.DakHealth = self.DakMaxHealth
		end

		self:GetPhysicsObject():SetMass(self.DakMass)

	if self.DakHealth<self.DakMaxHealth/2 and self.DakIsExplosive then

		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetEntity(self)
		effectdata:SetAttachment(1)
		effectdata:SetMagnitude(.5)
		effectdata:SetScale(500)
		util.Effect("dakscalingexplosion", effectdata)

		self.DamageList = {}
		self.RemoveList = {}
		local Targets = ents.FindInSphere( self:GetPos(), 500 )
		if table.Count(Targets) > 0 then
			for i = 1, #Targets do
				if Targets[i]:IsValid() or Targets[i]:IsPlayer() or Targets[i]:IsNPC() then
					local trace = {}
					trace.start = self:GetPos()
					trace.endpos = Targets[i]:GetPos()
					trace.filter = { self }
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
									Targets[i]:SetHealth(Targets[i]:Health() - (200)*50*(1-(ExpTrace.Entity:GetPos():Distance(self:GetPos())/1000)))
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
									ExpPain:SetDamageForce( ExpTrace.Normal*(50)*2500 )
									ExpPain:SetDamage( (200)*50*(1-(ExpTrace.Entity:GetPos():Distance(self:GetPos())/1000)) )
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
								self.DamageList[i]:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (self.DamageList[i]:GetPos()-self:GetPos()):GetNormalized()*(250/table.Count(self.DamageList))*10000*2*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000)) )
							end
						end
						if not(self.DamageList[i]:GetParent():IsValid()) then
							self.DamageList[i]:GetPhysicsObject():ApplyForceCenter( (self.DamageList[i]:GetPos()-self:GetPos()):GetNormalized()*(250/table.Count(self.DamageList))*10000*2*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000))  )
						end
					end
				end
				if not(self.DamageList[i].SPPOwner==nil) then
					if self.DamageList[i].SPPOwner:HasGodMode()==false then	
						local HPPerc = (self.DamageList[i].DakHealth-(250/table.Count(self.DamageList))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000)))/self.DamageList[i].DakMaxHealth
						self.DamageList[i].DakHealth = self.DamageList[i].DakHealth-(250/table.Count(self.DamageList))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000))
						if not(self.DamageList[i].DakRed == nil) then
							self.DamageList[i]:SetColor(Color(self.DamageList[i].DakRed*HPPerc,self.DamageList[i].DakGreen*HPPerc,self.DamageList[i].DakBlue*HPPerc,self.DamageList[i]:GetColor().a))
						end
						self.DamageList[i].DakLastDamagePos = self:GetPhysicsObject():GetPos()
						if self.DamageList[i].DakHealth <= 0 and self.DamageList[i].DakPooled==0 then
							table.insert(self.RemoveList,self.DamageList[i])
						end
					end
				else
					local HPPerc = (self.DamageList[i].DakHealth-(250/table.Count(self.DamageList))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000)))/self.DamageList[i].DakMaxHealth
					self.DamageList[i].DakHealth = self.DamageList[i].DakHealth-(250/table.Count(self.DamageList))*(1-(self.DamageList[i]:GetPos():Distance(self:GetPos())/1000))
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
	end

	self:NextThink(CurTime()+1)
    return true
end

function ENT:PreEntityCopy()
	print("copied")
	local info = {}
	local entids = {}
	info.DakName = self.DakName
	info.DakIsExplosive = self.DakIsExplosive
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakOwner = self.DakOwner
	if IsValid(self.DakGun) then
		info.GunID = self.DakGun:EntIndex()
	end
	info.DakColor = self:GetColor()
	--Materials
	info.DakMat0 = self:GetSubMaterial(0)
	info.DakMat1 = self:GetSubMaterial(1)
	duplicator.StoreEntityModifier( self, "DakTek", info )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	print("hi")
	print(Ent.EntityMods)
	print(Ent.EntityMods.DakTek)
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		print("its doing something")
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakIsExplosive = Ent.EntityMods.DakTek.DakIsExplosive
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakOwner = Player
		self.DakHealth = self.DakMaxHealth
		self:SetColor(Ent.EntityMods.DakTek.DakColor)
		self:SetSubMaterial( 0, Ent.EntityMods.DakTek.DakMat0 )
		self:SetSubMaterial( 1, Ent.EntityMods.DakTek.DakMat1 )
		local Gun = CreatedEntities[ Ent.EntityMods.DakTek.GunID ]
		if Gun and IsValid(Gun) then
			self.DakGun = Gun
		end
		self:Activate()
		Ent.EntityMods.DakTek = nil
		Ent.EntityMods.DakTekLink = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end

function ENT:OnRemove()
	if IsValid(self.DakGun) then
		self.DakGun.Loaded = 0
	end
end