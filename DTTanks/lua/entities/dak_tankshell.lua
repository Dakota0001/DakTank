AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity" 

ENT.PrintName = "Shell"

ENT.Spawnable = false
ENT.AdminOnly = false
--ENT.RenderGroup = RENDERGROUP_OPAQUE

--util.PrecacheModel("models/Items/AR2_Grenade.mdl")

function ENT:Draw()

	--self:DrawModel()

	if not(self:GetNWString("Trail")=="daksmallshelltrail") then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetEntity(self)
		effectdata:SetAttachment(1)
		effectdata:SetMagnitude(self:GetNWInt("Velocity"))
		effectdata:SetScale(self:GetNWInt("Damage"))
		--util.Effect(self:GetNWString("Trail"), effectdata)
	end

end

if ( CLIENT ) then return end -- We do NOT want to execute anything below in this FILE on Cliet

ENT.DakVelocity = 1
ENT.DakDamage = 1
ENT.DakExplosionEffect = ""
ENT.DakGravity = true
ENT.DakMass = 1
ENT.DakGun = nil
ENT.DakTrail = ""
ENT.DakImpactSound = ""
ENT.DakImpactPitch = 100
ENT.LastPos = Vector(0,0,0)

function ENT:Initialize()
	self:DrawShadow( false )
	self:SetModel( "models/Items/AR2_Grenade.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(10)

	function self:SetupDataTables()
		self:NetworkVar( "String", 0, "Trail" )
	end
	self:SetNWString("Trail",self.DakTrail)
	self:SetNWInt("Velocity",self.DakVelocity)
	self:SetNWInt("Damage",self.DakDamage)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:GetPhysicsObject():SetMass(self.DakMass)
	self:GetPhysicsObject():EnableCollisions(false)
	self.LastPos = self:GetPos()-self:GetForward()*25
	self:GetPhysicsObject():EnableGravity(true)
	self.DakHealth=500
 	self.DakMaxHealth=500
 	--if self.DakTrail=="daksmallshelltrail" then
 		util.SpriteTrail( self, -1, Color(255,175,50,255), false, (self.DakCaliber*0.0393701), (self.DakCaliber*0.0393701)/2, 0.250, 1 / ((self.DakCaliber*0.0393701) + (self.DakCaliber*0.0393701)/2 ) * 0.5, "trails/smoke.vmt" )
 	--end
 	self.Activated = 0

 	self.DakPenetration = self.DakPenetration * math.Rand( 0.75, 1.25 )
 	self.DakDamage = self.DakDamage * math.Rand( 0.75, 1.25 )
 	self.DakVelocity = self.DakVelocity * math.Rand( 0.95, 1.05 )
 	self.DakSplashDamage = self.DakSplashDamage * math.Rand( 0.75, 1.25 )

 	self.Spent=0

end

function ENT:Think()
	if self.Activated == 0 then
		self:GetPhysicsObject():SetVelocity(self:GetForward()*self.DakVelocity)
		self.Activated = 1
	end


	if self.Spent == 0 then
		trace = {}
		trace.start = self.LastPos
		trace.endpos = self:GetPos() + self:GetVelocity():GetNormalized()*self.LastPos:Distance(self:GetPos())
		
		if self.Filters == nil then
			self.Filters = ents.FindByClass( self:GetClass() )
			table.insert(self.Filters,self)
			table.insert(self.Filters,self.DakGun)
			if IsValid(self.DakGun.DakTankCore) then
				table.Add(self.Filters,self.DakGun.DakTankCore.Contraption)
			end
		end
		trace.filter = self.Filters
		local Hit = util.TraceEntity( trace, self )
		if Hit.Entity:IsValid() then
			if Hit.Entity:GetClass() == self:GetClass() then
				Hit.Entity =  NULL
			end 
		end

		if Hit.Entity:IsValid() and not(Hit.Entity:IsPlayer()) and not(Hit.Entity:IsNPC()) and not(Hit.Entity:GetClass()=="dak_bot") then
			if (self:CheckClip(Hit.Entity,Hit.HitPos)) or (Hit.Entity:GetPhysicsObject():GetMass()<=1 and not(Hit.Entity:IsVehicle()) and not(Hit.Entity.IsDakTekFutureTech==1)) then
				self.LastHit = Hit.HitPos
				self.LastHitEnt = Hit.Entity
				if Hit.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(Hit.Entity)
				end
				local SA = Hit.Entity:GetPhysicsObject():GetSurfaceArea()
				if Hit.Entity.IsDakTekFutureTech == 1 then
					Hit.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
						Hit.Entity.DakArmor = Hit.Entity:OBBMaxs().x/2
						Hit.Entity.DakIsTread = 1
					else
						if Hit.Entity:GetClass()=="prop_physics" then 
							if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
								Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
							end
						end
					end
				end

				self:Damage(Hit.Entity)
			else
				if Hit.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(Hit.Entity)
				end
				local SA = Hit.Entity:GetPhysicsObject():GetSurfaceArea()
				if Hit.Entity.IsDakTekFutureTech == 1 then
					Hit.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
						Hit.Entity.DakArmor = Hit.Entity:OBBMaxs().x/2
						Hit.Entity.DakIsTread = 1
					else
						if Hit.Entity:GetClass()=="prop_physics" then 
							if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
								Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
							end
						end
					end
				end
				
				Hit.Entity.DakLastDamagePos = Hit.HitPos


				local Vel = self:GetPhysicsObject():GetVelocity()
				local EffArmor = (Hit.Entity.DakArmor/math.abs(Hit.HitNormal:Dot(Vel:GetNormalized())))
				if EffArmor < self.DakPenetration and Hit.Entity.IsDakTekFutureTech == nil then
					if not(Hit.Entity.SPPOwner==nil) then			
						if Hit.Entity.SPPOwner:HasGodMode()==false and Hit.Entity.DakIsTread == nil then	
							if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
								local HPPerc = (Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5))/Hit.Entity.DakMaxHealth
								Hit.Entity.DakHealth = Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5)
								if not(Hit.Entity.DakRed == nil) then 
									Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
								end
							else
								local HPPerc = (Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor))/Hit.Entity.DakMaxHealth
								Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
								if not(Hit.Entity.DakRed == nil) then 
									Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
								end
							end
						end
					else
						if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
							local HPPerc = (Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5))/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5)
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						else
							local HPPerc = (Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor))/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						end
					end
					local effectdata = EffectData()
					effectdata:SetOrigin(Hit.HitPos)
					effectdata:SetEntity(self)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(self.DakDamage)
					util.Effect("dakshellpenetrate", effectdata)
					util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
					self:SetPos(Hit.HitPos)
					self:GetPhysicsObject():SetVelocity( Vel-(Vel*(EffArmor/self.DakPenetration)) )
					self:SetPos(Hit.HitPos)
					self.DakDamage = self.DakDamage-self.DakDamage*(EffArmor/self.DakPenetration)
					self.DakPenetration = self.DakPenetration-self.DakPenetration*(EffArmor/self.DakPenetration)
					self.LastHit = Hit.HitPos
					self.LastHitEnt = Hit.Entity
					--soundhere penetrate sound
					if self.DakIsPellet then
						sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 150, 0.25 )
					else
						sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 100, 1 )
					end
					self:Damage(Hit.Entity)
				else
					if not(Hit.Entity.SPPOwner==nil) then			
						if Hit.Entity.SPPOwner:HasGodMode()==false and Hit.Entity.DakIsTread == nil then	
							if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
								local HPPerc = (Hit.Entity.DakHealth-(self.DakDamage*0.25))/Hit.Entity.DakMaxHealth
								Hit.Entity.DakHealth = Hit.Entity.DakHealth-(self.DakDamage*0.25)
								if not(Hit.Entity.DakRed == nil) then 
									Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
								end
							else
								local HPPerc = (Hit.Entity.DakHealth-self.DakDamage*0.5)/Hit.Entity.DakMaxHealth
								Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
								if not(Hit.Entity.DakRed == nil) then 
									Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
								end
							end
						end
					else
						if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
							local HPPerc = (Hit.Entity.DakHealth-(self.DakDamage*0.25))/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-(self.DakDamage*0.25)
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						else
							local HPPerc = (Hit.Entity.DakHealth-self.DakDamage*0.5)/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						end
					end
					if self.DakExplosive then
						self:SetPos(Hit.HitPos)
						self:GetPhysicsObject():SetVelocity(Vector(0,0,0))
						self:SetPos(Hit.HitPos)
						--self.DakPenetration = 0
						self.DakDamage = 0
						self.LastHit = Hit.HitPos
						self.LastHitEnt = Hit.Entity
						self.ExplodeNow = true
					else
					--print( math.deg(math.acos(Hit.HitNormal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
						local effectdata = EffectData()
						effectdata:SetOrigin(Hit.HitPos)
						effectdata:SetEntity(self)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(self.DakDamage)
						util.Effect("dakshellbounce", effectdata)
						util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
						self:SetPos(Hit.HitPos)
						self:GetPhysicsObject():SetVelocity((Vel - 2 * (Hit.HitNormal:Dot(Vel) * (Hit.HitNormal+Vector(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05)))  ))*0.025)
						self:SetPos(Hit.HitPos)
						self.DakPenetration = self.DakPenetration-self.DakPenetration*(Hit.Entity.DakArmor/self.DakPenetration)
						self.DakDamage = 0
						self.LastHit = Hit.HitPos
						self.LastHitEnt = Hit.Entity
						--soundhere bounce sound
						local BounceSounds = {}
						if self.DakCaliber < 20 then
							BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
						else
							BounceSounds = {"daktanks/dakrico1.wav","daktanks/dakrico2.wav","daktanks/dakrico3.wav","daktanks/dakrico4.wav","daktanks/dakrico5.wav","daktanks/dakrico6.wav"}
						end
						if self.DakIsPellet then
							sound.Play( BounceSounds[math.random(1,#BounceSounds)], Hit.HitPos, 100, 150, 0.25 )
						else
							sound.Play( BounceSounds[math.random(1,#BounceSounds)], Hit.HitPos, 100, 100, 1 )
						end
					end
				end
				if Hit.Entity.DakHealth <= 0 and Hit.Entity.DakPooled==0 then
					self.salvage = ents.Create( "dak_tesalvage" )
					self.salvage.DakModel = Hit.Entity:GetModel()
					self.salvage:SetPos( Hit.Entity:GetPos())
					self.salvage:SetAngles( Hit.Entity:GetAngles())
					self.salvage:Spawn()
					Hit.Entity:Remove()
				end
			end
		else
			self.LastHit = Hit.HitPos
			self.LastHitEnt = Hit.Entity
		end
		if self.LastHitEnt:IsValid() then
			if self.LastHitEnt:IsPlayer() or self.LastHitEnt:IsNPC() or self.LastHitEnt:GetClass() == "dak_bot" then

					if self.LastHitEnt:GetClass() == "dak_bot" then
						self.LastHitEnt:SetHealth(self.LastHitEnt:Health() - self.DakDamage*500)
						if self.LastHitEnt:Health() <= 0 and self.revenge==0 then
							local body = ents.Create( "prop_ragdoll" )
							body:SetPos( self.LastHitEnt:GetPos() )
							body:SetModel( self.LastHitEnt:GetModel() )
							body:Spawn()
							self.LastHitEnt:Remove()
							local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
							body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
							timer.Simple( 5, function()
								body:Remove()
							end )
						end
					else
					local Pain = DamageInfo()
					Pain:SetDamageForce( self:GetVelocity():GetNormalized()*self.DakDamage*self:GetPhysicsObject():GetMass()*self.DakVelocity )
					Pain:SetDamage( self.DakDamage*500 )
					Pain:SetAttacker( self.DakGun.DakOwner )
					Pain:SetInflictor( self.DakGun )
					Pain:SetReportedPosition( self:GetPos() )
					Pain:SetDamagePosition( self.LastHitEnt:GetPhysicsObject():GetMassCenter() )
					Pain:SetDamageType(DMG_CRUSH)
					self.LastHitEnt:TakeDamageInfo( Pain )
				end
				--self.LastHitEnt:TakeDamage( self.DakDamage*50, self.DakGun.DakOwner, self.DakGun )
				if self.LastHitEnt:Health() <= 0 then
					local effectdata = EffectData()
					effectdata:SetOrigin(self.LastHit)
					effectdata:SetEntity(self)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(self.DakDamage)
					util.Effect("dakshellpenetrate", effectdata)
					util.Decal( "Impact.Concrete", self.LastHit+(self:GetForward()*-5), self.LastHit+(self:GetForward()*5), self)
					self:Damage(self.LastHitEnt)
					--soundhere penetrate human sound
					if self.DakIsPellet then
						sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 150, 0.25 )
					else
						sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 100, 1 )
					end
				else
					local effectdata = EffectData()
					effectdata:SetOrigin(self.LastHit)
					effectdata:SetEntity(self)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(self.DakDamage)
					util.Effect("dakshellimpact", effectdata)
					util.Decal( "Impact.Concrete", self.LastHit+(self:GetForward()*-5), self.LastHit+(self:GetForward()*5), self)
					self.DakDamage = 0
					self.LastHit = Hit.HitPos
					self.LastHitEnt = Hit.Entity
					--soundhere impact human sound
					local ExpSounds = {}
					if self.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
					end

					if self.DakIsPellet then
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], Hit.HitPos, 100, 150, 0.25 )	
					else
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], Hit.HitPos, 100, 100, 1 )	
					end
				end
			end
		end
		if self.LastHitEnt:IsWorld() or self.ExplodeNow==true then
			if self.DakExplosive then
				local effectdata = EffectData()
				effectdata:SetOrigin(self.LastHit)
				effectdata:SetEntity(self)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(self.DakBlastRadius)
				util.Effect("dakscalingexplosion", effectdata)

				self.DakDamageList = {}
				self.RemoveList = {}
				self.IgnoreList = {}
				local Targets = ents.FindInSphere( self.LastHit, self.DakBlastRadius )
				if table.Count(Targets) > 0 then
					for i = 1, #Targets do
						if Targets[i]:IsValid() then
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
							trace.start = self.LastHit
							trace.endpos = Targets[i]:LocalToWorld( Targets[i]:OBBCenter() )
							trace.filter = self.IgnoreList
							local ExpTrace = util.TraceHull( trace, self )
							if ExpTrace.Entity == Targets[i] then
								if not(string.Explode("_",Targets[i]:GetClass(),false)[2] == "wire") and not(Targets[i]:GetClass() == self:GetClass()) and not(Targets[i]:IsVehicle()) and not(Targets[i]:GetClass() == "dak_salvage") and not(Targets[i]:GetClass() == "dak_tesalvage") and Targets[i]:GetPhysicsObject():GetMass()>1 and Targets[i].DakIsTread==nil and not(Targets[i]:GetClass() == "dak_turretcontrol") then
									if (not(ExpTrace.Entity:IsPlayer())) and (not(ExpTrace.Entity:IsNPC())) then
										if ExpTrace.Entity.DakArmor == nil then
											DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
										end
										table.insert(self.DakDamageList,ExpTrace.Entity)
									else
										if self.LastHitEnt:GetClass() == "dak_bot" then
											self.LastHitEnt:SetHealth(self.LastHitEnt:Health() - self.DakSplashDamage*50*(1-(ExpTrace.Entity:GetPos():Distance(self.LastHit)/1000))*500)
											if self.LastHitEnt:Health() <= 0 and self.revenge==0 then
												local body = ents.Create( "prop_ragdoll" )
												body:SetPos( self.LastHitEnt:GetPos() )
												body:SetModel( self.LastHitEnt:GetModel() )
												body:Spawn()
												self.LastHitEnt:Remove()
												local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
												body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
												timer.Simple( 5, function()
													body:Remove()
												end )
											end
										else
											local ExpPain = DamageInfo()
											ExpPain:SetDamageForce( ExpTrace.Normal*self.DakSplashDamage*self:GetPhysicsObject():GetMass()*self.DakVelocity )
											ExpPain:SetDamage( self.DakSplashDamage*50*(1-(ExpTrace.Entity:GetPos():Distance(self.LastHit)/1000)) )
											ExpPain:SetAttacker( self.DakGun.DakOwner )
											ExpPain:SetInflictor( self.DakGun )
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
					for i = 1, #self.DakDamageList do
						if(self.DakDamageList[i]:IsValid()) then
							if not(self.LastHitEnt:GetClass() == "dak_bot") then
								if(self.DakDamageList[i]:GetParent():IsValid()) then
									if(self.DakDamageList[i]:GetParent():GetParent():IsValid()) then
									self.DakDamageList[i]:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (self.DakDamageList[i]:GetPos()-self.LastHit):GetNormalized()*(self.DakSplashDamage/table.Count(self.DakDamageList))*1000*2*(1-(self.DakDamageList[i]:GetPos():Distance(self.LastHit)/1000)) )
									end
								end
								if not(self.DakDamageList[i]:GetParent():IsValid()) then
									self.DakDamageList[i]:GetPhysicsObject():ApplyForceCenter( (self.DakDamageList[i]:GetPos()-self.LastHit):GetNormalized()*(self.DakSplashDamage/table.Count(self.DakDamageList))*1000*2*(1-(self.DakDamageList[i]:GetPos():Distance(self.LastHit)/1000))  )
								end
							end
						end
						local HPPerc = 0
						if not(self.DakDamageList[i].SPPOwner==nil) then
							if self.DakDamageList[i].SPPOwner:HasGodMode()==false then	
								if self.DakDamageList[i].DakIsTread==nil then
									if self.DakDamageList[i]:GetPos():Distance(self.LastHit) > self.DakBlastRadius/2 then 
										HPPerc = (self.DakDamageList[i].DakHealth - (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  )*(1-(self.DakDamageList[i]:GetPos():Distance(self.LastHit)/self.DakBlastRadius)))/self.DakDamageList[i].DakMaxHealth
										self.DakDamageList[i].DakHealth = self.DakDamageList[i].DakHealth - (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  )*(1-(self.DakDamageList[i]:GetPos():Distance(self.LastHit)/self.DakBlastRadius))
									else
										HPPerc = (self.DakDamageList[i].DakHealth- (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  ))/self.DakDamageList[i].DakMaxHealth
										self.DakDamageList[i].DakHealth = self.DakDamageList[i].DakHealth - (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  )
									end
								end

								if not(self.DakDamageList[i].DakRed == nil) then
									self.DakDamageList[i]:SetColor(Color(self.DakDamageList[i].DakRed*HPPerc,self.DakDamageList[i].DakGreen*HPPerc,self.DakDamageList[i].DakBlue*HPPerc,self.DakDamageList[i]:GetColor().a))
								end
								self.DakDamageList[i].DakLastDamagePos = self.LastHit
								if self.DakDamageList[i].DakHealth <= 0 and self.DakDamageList[i].DakPooled==0 then
									table.insert(self.RemoveList,self.DakDamageList[i])
								end
							end
						else
							if self.DakDamageList[i].DakIsTread==nil then
								if self.DakDamageList[i]:GetPos():Distance(self.LastHit) > self.DakBlastRadius/2 then 
									HPPerc = (self.DakDamageList[i].DakHealth - (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  )*(1-(self.DakDamageList[i]:GetPos():Distance(self.LastHit)/self.DakBlastRadius)))/self.DakDamageList[i].DakMaxHealth
									self.DakDamageList[i].DakHealth = self.DakDamageList[i].DakHealth - (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  )*(1-(self.DakDamageList[i]:GetPos():Distance(self.LastHit)/self.DakBlastRadius))
								else
									HPPerc = (self.DakDamageList[i].DakHealth- (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  ))/self.DakDamageList[i].DakMaxHealth
									self.DakDamageList[i].DakHealth = self.DakDamageList[i].DakHealth - (  (self.DakSplashDamage/table.Count(self.DakDamageList)) * ((self.DakBasePenetration*0.4)/self.DakDamageList[i].DakArmor)  )
								end
							end

							if not(self.DakDamageList[i].DakRed == nil) then
								self.DakDamageList[i]:SetColor(Color(self.DakDamageList[i].DakRed*HPPerc,self.DakDamageList[i].DakGreen*HPPerc,self.DakDamageList[i].DakBlue*HPPerc,self.DakDamageList[i]:GetColor().a))
							end
							self.DakDamageList[i].DakLastDamagePos = self.LastHit
							if self.DakDamageList[i].DakHealth <= 0 and self.DakDamageList[i].DakPooled==0 then
								table.insert(self.RemoveList,self.DakDamageList[i])
							end
						end

					end
					for i = 1, #self.RemoveList do
						self.salvage = ents.Create( "dak_tesalvage" )
						self.salvage.DakModel = self.RemoveList[i]:GetModel()
						self.salvage:SetPos( self.RemoveList[i]:GetPos())
						self.salvage:SetAngles( self.RemoveList[i]:GetAngles())
						self.salvage.DakLastDamagePos = self.LastHit
						self.salvage:Spawn()
						self.RemoveList[i]:Remove()
					end
				end
			else
				local effectdata = EffectData()
				effectdata:SetOrigin(self.LastHit)
				effectdata:SetEntity(self)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				if self.DakDamage == 0 then
					effectdata:SetScale(0.5)
				else
					effectdata:SetScale(self.DakDamage)
				end
				util.Effect("dakshellimpact", effectdata)
				util.Decal( "Impact.Concrete", self.LastHit+(self:GetForward()*-5), self.LastHit+(self:GetForward()*5), self)
			end
			if(self.LastHitEnt:IsValid()) then
				if(self.LastHitEnt:GetParent():IsValid()) then
					if(self.LastHitEnt:GetParent():GetParent():IsValid()) then
						local Div = Vector(self.LastHitEnt:GetParent():GetParent():OBBMaxs().x/75,self.LastHitEnt:GetParent():GetParent():OBBMaxs().y/75,self.LastHitEnt:GetParent():GetParent():OBBMaxs().z/75)
						self.LastHitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(self:GetVelocity()*self:GetPhysicsObject():GetMass()/20000)*self.LastHitEnt:GetParent():GetParent():GetPhysicsObject():GetMass(),self.LastHitEnt:GetParent():GetParent():GetPos()+self.LastHitEnt:WorldToLocal(self.LastHit):GetNormalized() )
					end
				end
				if not(self.LastHitEnt:GetParent():IsValid()) then
					local Div = Vector(self.LastHitEnt:OBBMaxs().x/75,self.LastHitEnt:OBBMaxs().y/75,self.LastHitEnt:OBBMaxs().z/75)
					self.LastHitEnt:GetPhysicsObject():ApplyForceOffset( Div*(self:GetVelocity()*self:GetPhysicsObject():GetMass()/20000)*self.LastHitEnt:GetPhysicsObject():GetMass(),self.LastHitEnt:GetPos()+self.LastHitEnt:WorldToLocal(self.LastHit):GetNormalized() )
				end
			end
		--soundhere impact ground sound here
		local ExpSounds = {}
		if self.DakCaliber < 20 then
			ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
		else
			ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
		end
		if self.DakIsPellet then
			sound.Play( ExpSounds[math.random(1,#ExpSounds)], Hit.HitPos, 100, 150, 0.25 )		
		else
			sound.Play( ExpSounds[math.random(1,#ExpSounds)], Hit.HitPos, 100, 100, 1 )		
		end
		self:Remove()
		end	
		self.LastPos = self:GetPos()

		if self.DakPenetration <= 0 then
			self.Spent=1
			timer.Simple( 1.5, function()
				if IsValid(self) then
					self:Remove()
				end
			end )
		end

	end
	self:NextThink( CurTime() )
	return true
end

function ENT:Damage(oldhit)
	trace = {}
	trace.start = self.LastPos
	trace.endpos = self:GetPos() + self:GetVelocity():GetNormalized()*self.LastPos:Distance(self:GetPos())
	table.insert(self.Filters,oldhit)
	trace.filter = self.Filters
	local Hit = util.TraceEntity( trace, self )
	if Hit.Entity:IsValid() then
		if Hit.Entity:GetClass() == self:GetClass() then
			Hit.Entity =  NULL
		end
	end

	if Hit.Entity:IsValid() and not(Hit.Entity:IsPlayer()) and not(Hit.Entity:IsNPC()) and not(Hit.Entity:GetClass()=="dak_bot") then
		if ((self:CheckClip(Hit.Entity,Hit.HitPos)) and (self.LastHit:Distance(Hit.HitPos) > 5)) or (Hit.Entity:GetPhysicsObject():GetMass()<=1 and not(Hit.Entity:IsVehicle()) and not(Hit.Entity.IsDakTekFutureTech==1)) then
			self.LastHit = Hit.HitPos
			self.LastHitEnt = Hit.Entity
			if Hit.Entity.DakArmor == nil then
				DakTekTankEditionSetupNewEnt(Hit.Entity)
			end
			local SA = Hit.Entity:GetPhysicsObject():GetSurfaceArea()
			if Hit.Entity.IsDakTekFutureTech == 1 then
				Hit.Entity.DakArmor = 1000
			else
				if SA == nil then
					--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
					Hit.Entity.DakArmor = Hit.Entity:OBBMaxs().x/2
					Hit.Entity.DakIsTread = 1
				else
					if Hit.Entity:GetClass()=="prop_physics" then 
						if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
							Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
						end
					end
				end
			end
			self:Damage(Hit.Entity)
		else
			if Hit.Entity.DakArmor == nil then
				DakTekTankEditionSetupNewEnt(Hit.Entity)
			end
			local SA = Hit.Entity:GetPhysicsObject():GetSurfaceArea()
			if Hit.Entity.IsDakTekFutureTech == 1 then
				Hit.Entity.DakArmor = 1000
			else
				if SA == nil then
					--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
					Hit.Entity.DakArmor = Hit.Entity:OBBMaxs().x/2
					Hit.Entity.DakIsTread = 1
				else
					if Hit.Entity:GetClass()=="prop_physics" then 
						if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
							Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
						end
					end
				end
			end
			local RemoveDamage = Hit.Entity.DakHealth
			
			Hit.Entity.DakLastDamagePos = Hit.HitPos
			local Vel = self:GetPhysicsObject():GetVelocity()
			local EffArmor = (Hit.Entity.DakArmor/math.abs(Hit.HitNormal:Dot(Vel:GetNormalized())))
			if EffArmor < self.DakPenetration and Hit.Entity.IsDakTekFutureTech == nil then
				if not(Hit.Entity.SPPOwner==nil) then			
					if Hit.Entity.SPPOwner:HasGodMode()==false and Hit.Entity.DakIsTread == nil then	
						if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
							local HPPerc = (Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5))/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5)
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						else
							local HPPerc = (Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor))/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						end
					end
				else
					if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
						local HPPerc = (Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5))/Hit.Entity.DakMaxHealth
						Hit.Entity.DakHealth = Hit.Entity.DakHealth-(math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)*0.5)
						if not(Hit.Entity.DakRed == nil) then 
							Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
						end
					else
						local HPPerc = (Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor))/Hit.Entity.DakMaxHealth
						Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
						if not(Hit.Entity.DakRed == nil) then 
							Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
						end
					end
				end
				local effectdata = EffectData()
				effectdata:SetOrigin(Hit.HitPos)
				effectdata:SetEntity(self)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(self.DakDamage)
				util.Effect("dakshellpenetrate", effectdata)
				util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
				self:SetPos(Hit.HitPos)
				self:GetPhysicsObject():SetVelocity( Vel-(Vel*(EffArmor/self.DakPenetration)) )
				self:SetPos(Hit.HitPos)
				self.DakDamage = self.DakDamage-self.DakDamage*(EffArmor/self.DakPenetration)
				self.DakPenetration = self.DakPenetration-self.DakPenetration*(EffArmor/self.DakPenetration)
				self.LastHit = Hit.HitPos
				self.LastHitEnt = Hit.Entity
				self:Damage(Hit.Entity)
				--soundhere penetrate sound
				if self.DakIsPellet then
					sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 150, 0.25 )
				else
					sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 100, 1 )
				end
			else
				if not(Hit.Entity.SPPOwner==nil) then			
					if Hit.Entity.SPPOwner:HasGodMode()==false and Hit.Entity.DakIsTread == nil then	
						if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
							local HPPerc = (Hit.Entity.DakHealth-(self.DakDamage*0.25))/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-(self.DakDamage*0.25)
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						else
							local HPPerc = (Hit.Entity.DakHealth-self.DakDamage*0.5)/Hit.Entity.DakMaxHealth
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
							if not(Hit.Entity.DakRed == nil) then 
								Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
							end
						end
					end
				else
					if (Hit.Entity.DakName == "Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Armor")or(Hit.Entity.DakName == "Heavy Reactive Reflective Armor") then
						local HPPerc = (Hit.Entity.DakHealth-(self.DakDamage*0.25))/Hit.Entity.DakMaxHealth
						Hit.Entity.DakHealth = Hit.Entity.DakHealth-(self.DakDamage*0.25)
						if not(Hit.Entity.DakRed == nil) then 
							Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
						end
					else
						local HPPerc = (Hit.Entity.DakHealth-self.DakDamage*0.5)/Hit.Entity.DakMaxHealth
						Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
						if not(Hit.Entity.DakRed == nil) then 
							Hit.Entity:SetColor(Color(Hit.Entity.DakRed*HPPerc,Hit.Entity.DakGreen*HPPerc,Hit.Entity.DakBlue*HPPerc,Hit.Entity:GetColor().a))
						end
					end
				end
				if self.DakExplosive then
					self:SetPos(Hit.HitPos)
					self:GetPhysicsObject():SetVelocity(Vector(0,0,0))
					self:SetPos(Hit.HitPos)
					--self.DakPenetration = 0
					self.DakDamage = 0
					self.LastHit = Hit.HitPos
					self.LastHitEnt = Hit.Entity
					self.ExplodeNow = true
				else
				--print( math.deg(math.acos(Hit.HitNormal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
					local effectdata = EffectData()
					effectdata:SetOrigin(Hit.HitPos)
					effectdata:SetEntity(self)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(self.DakDamage)
					util.Effect("dakshellbounce", effectdata)
					util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
					self:SetPos(Hit.HitPos)
					self:GetPhysicsObject():SetVelocity((Vel - 2 * (Hit.HitNormal:Dot(Vel) * (Hit.HitNormal+Vector(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05)))  ))*0.025)
					self:SetPos(Hit.HitPos)
					self.DakPenetration = self.DakPenetration-self.DakPenetration*(Hit.Entity.DakArmor/self.DakPenetration)
					self.DakDamage = 0
					self.LastHit = Hit.HitPos
					self.LastHitEnt = Hit.Entity
					--soundhere bounce sound
					local BounceSounds = {}
					if self.DakCaliber < 20 then
						BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
					else
						BounceSounds = {"daktanks/dakrico1.wav","daktanks/dakrico2.wav","daktanks/dakrico3.wav","daktanks/dakrico4.wav","daktanks/dakrico5.wav","daktanks/dakrico6.wav"}
					end
					if self.DakIsPellet then
						sound.Play( BounceSounds[math.random(1,#BounceSounds)], Hit.HitPos, 100, 150, 0.25 )
					else
						sound.Play( BounceSounds[math.random(1,#BounceSounds)], Hit.HitPos, 100, 100, 1 )
					end
				end
			end
			if Hit.Entity.DakHealth <= 0 and Hit.Entity.DakPooled==0 then
				self.salvage = ents.Create( "dak_tesalvage" )
				self.salvage.DakModel = Hit.Entity:GetModel()
				self.salvage:SetPos( Hit.Entity:GetPos())
				self.salvage:SetAngles( Hit.Entity:GetAngles())
				self.salvage:Spawn()
				Hit.Entity:Remove()
			end
		end
	else
		self.LastHit = Hit.HitPos
		self.LastHitEnt = Hit.Entity
	end

	if self.LastHitEnt:IsValid() then
		if self.LastHitEnt:IsPlayer() or self.LastHitEnt:IsNPC() or self.LastHitEnt:GetClass() == "dak_bot" then
			if self.LastHitEnt:GetClass() == "dak_bot" then
				self.LastHitEnt:SetHealth(self.LastHitEnt:Health() - self.DakDamage*500)
				if self.LastHitEnt:Health() <= 0 and self.revenge==0 then
					local body = ents.Create( "prop_ragdoll" )
					body:SetPos( self.LastHitEnt:GetPos() )
					body:SetModel( self.LastHitEnt:GetModel() )
					body:Spawn()
					self.LastHitEnt:Remove()
					local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
					body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
					timer.Simple( 5, function()
						body:Remove()
					end )
				end
			else
				local Pain = DamageInfo()
				Pain:SetDamageForce( self:GetVelocity():GetNormalized()*self.DakDamage*self:GetPhysicsObject():GetMass()*self.DakVelocity )
				Pain:SetDamage( self.DakDamage*500 )
				Pain:SetAttacker( self.DakGun.DakOwner )
				Pain:SetInflictor( self.DakGun )
				Pain:SetReportedPosition( self:GetPos() )
				Pain:SetDamagePosition( self.LastHitEnt:GetPhysicsObject():GetMassCenter() )
				Pain:SetDamageType(DMG_CRUSH)
				self.LastHitEnt:TakeDamageInfo( Pain )
			end

			if self.LastHitEnt:Health() <= 0 then
				local effectdata = EffectData()
				effectdata:SetOrigin(self.LastHit)
				effectdata:SetEntity(self)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(self.DakDamage)
				util.Effect("dakshellpenetrate", effectdata)
				util.Decal( "Impact.Concrete", self.LastHit+(self:GetForward()*-5), self.LastHit+(self:GetForward()*5), self)
				self:Damage(self.LastHitEnt)
				--soundhere penetrate human sound
				if self.DakIsPellet then
					sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 150, 0.25 )
				else
					sound.Play( self.DakPenSounds[math.random(1,#self.DakPenSounds)], Hit.HitPos, 100, 100, 1 )
				end
			else
				local effectdata = EffectData()
				effectdata:SetOrigin(self.LastHit)
				effectdata:SetEntity(self)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(self.DakDamage)
				util.Effect("dakshellimpact", effectdata)
				util.Decal( "Impact.Concrete", self.LastHit+(self:GetForward()*-5), self.LastHit+(self:GetForward()*5), self)
				--soundhere impact human sound
				local ExpSounds = {}
				if self.DakCaliber < 20 then
					ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
				else
					ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
				end
				if self.DakIsPellet then
					sound.Play( ExpSounds[math.random(1,#ExpSounds)], Hit.HitPos, 100, 150, 0.25 )	
				else
					sound.Play( ExpSounds[math.random(1,#ExpSounds)], Hit.HitPos, 100, 100, 1 )
				end	
				self.DakDamage = 0
				self.LastHit = Hit.HitPos
				self.LastHitEnt = Hit.Entity
			end
		end
	end
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