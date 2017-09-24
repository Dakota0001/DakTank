AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakName = "Fuel Tank"
ENT.DakIsExplosive = true
ENT.DakArmor = 10
ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakPooled=0

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
	self.PowerMod = 1
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.DumpTime = CurTime()

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

		if self.DakName == "Micro Fuel Tank" then
			self.DakMass = 65
			self.PowerMod = 0.5
			self.DakMaxHealth = 10
		end
		if self.DakName == "Small Fuel Tank" then
			self.DakMass = 120
			self.PowerMod = 0.75
			self.DakMaxHealth = 20
		end
		if self.DakName == "Standard Fuel Tank" then
			self.DakMass = 240
			self.PowerMod = 1.0
			self.DakMaxHealth = 30
		end
		if self.DakName == "Large Fuel Tank" then
			self.DakMass = 475
			self.PowerMod = 1.25
			self.DakMaxHealth = 40
		end
		if self.DakName == "Huge Fuel Tank" then
			self.DakMass = 950
			self.PowerMod = 1.5
			self.DakMaxHealth = 50
		end
		if self.DakName == "Ultra Fuel Tank" then
			self.DakMass = 1900
			self.PowerMod = 2.0
			self.DakMaxHealth = 60
		end

		if self.DakHealth > self.DakMaxHealth then
			self.DakHealth = self.DakMaxHealth
		end

		self.PowerMod = self.PowerMod*(self.DakHealth/self.DakMaxHealth)
		self:GetPhysicsObject():SetMass(self.DakMass)

	if self.DakHealth<5 and self.DakIsExplosive then

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
									if IsValid(self.DakOwner) then
										ExpPain:SetAttacker( self.DakOwner )
									end
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

	local info = {}
	local entids = {}


	info.DakName = self.DakName
	info.DakIsExplosive = self.DakIsExplosive
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth
	info.DakOwner = self.DakOwner

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )

	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakIsExplosive = Ent.EntityMods.DakTek.DakIsExplosive
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakOwner = Player

		Ent.EntityMods.DakTekLink = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end