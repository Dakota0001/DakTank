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

	if self.DakHealth<(self.DakMaxHealth*0.25) and self.DakIsExplosive then

		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetEntity(self)
		effectdata:SetAttachment(1)
		effectdata:SetMagnitude(.5)
		effectdata:SetScale(500)
		util.Effect("dakscalingexplosion", effectdata)

		self:DTExplosion(self:GetPos(),250,500,200,100,self.DakOwner)

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
			util.Decal( "Impact.Concrete", self:GetPos(), self:GetPos()+(Direction*Radius), self)
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:GetClass()=="dak_bot") then
				if (self:CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
								end
							end
						end
					end
					self:DamageEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
								end
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if not(ExpTrace.Entity.SPPOwner==nil) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
							local HPPerc = (ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor))/ExpTrace.Entity.DakMaxHealth
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
							if not(ExpTrace.Entity.DakRed == nil) then 
								ExpTrace.Entity:SetColor(Color(ExpTrace.Entity.DakRed*HPPerc,ExpTrace.Entity.DakGreen*HPPerc,ExpTrace.Entity.DakBlue*HPPerc,ExpTrace.Entity:GetColor().a))
							end
						end
					else
						local HPPerc = (ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor))/ExpTrace.Entity.DakMaxHealth
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
						if not(ExpTrace.Entity.DakRed == nil) then 
							ExpTrace.Entity:SetColor(Color(ExpTrace.Entity.DakRed*HPPerc,ExpTrace.Entity.DakGreen*HPPerc,ExpTrace.Entity.DakBlue*HPPerc,ExpTrace.Entity:GetColor().a))
						end
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						self.salvage = ents.Create( "dak_tesalvage" )
						self.salvage.DakModel = ExpTrace.Entity:GetModel()
						self.salvage:SetPos( ExpTrace.Entity:GetPos())
						self.salvage:SetAngles( ExpTrace.Entity:GetAngles())
						self.salvage:Spawn()
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
						Pain:SetReportedPosition( self:GetPos() )
						Pain:SetDamagePosition( ExpTrace.Entity:GetPhysicsObject():GetMassCenter() )
						Pain:SetDamageType(DMG_BLAST)
						ExpTrace.Entity:TakeDamageInfo( Pain )
					end
				end
			end

			if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) then
				if(ExpTrace.Entity:GetParent():IsValid()) then
					if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
						ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
					end
				end
				if not(ExpTrace.Entity:GetParent():IsValid()) then
					ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
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
		util.Decal( "Impact.Concrete", self:GetPos(), self:GetPos()+(Direction*Radius), self)
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:GetClass()=="dak_bot") then
			if (self:CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
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
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
							end
						end
					end
				end
				self:DamageEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
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
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
							end
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if not(ExpTrace.Entity.SPPOwner==nil) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
						local HPPerc = (ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor))/ExpTrace.Entity.DakMaxHealth
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
						if not(ExpTrace.Entity.DakRed == nil) then 
							ExpTrace.Entity:SetColor(Color(ExpTrace.Entity.DakRed*HPPerc,ExpTrace.Entity.DakGreen*HPPerc,ExpTrace.Entity.DakBlue*HPPerc,ExpTrace.Entity:GetColor().a))
						end
					end
				else
					local HPPerc = (ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor))/ExpTrace.Entity.DakMaxHealth
					ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
					if not(ExpTrace.Entity.DakRed == nil) then 
						ExpTrace.Entity:SetColor(Color(ExpTrace.Entity.DakRed*HPPerc,ExpTrace.Entity.DakGreen*HPPerc,ExpTrace.Entity.DakBlue*HPPerc,ExpTrace.Entity:GetColor().a))
					end
				end
				if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
					self.salvage = ents.Create( "dak_tesalvage" )
					self.salvage.DakModel = ExpTrace.Entity:GetModel()
					self.salvage:SetPos( ExpTrace.Entity:GetPos())
					self.salvage:SetAngles( ExpTrace.Entity:GetAngles())
					self.salvage:Spawn()
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
					Pain:SetReportedPosition( self:GetPos() )
					Pain:SetDamagePosition( ExpTrace.Entity:GetPhysicsObject():GetMassCenter() )
					Pain:SetDamageType(DMG_BLAST)
					ExpTrace.Entity:TakeDamageInfo( Pain )
				end
			end
		end
		if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) then
			if(ExpTrace.Entity:GetParent():IsValid()) then
				if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
					ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
				end
			end
			if not(ExpTrace.Entity:GetParent():IsValid()) then
				ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
			end
		end		
	end
end