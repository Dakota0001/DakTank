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

	if self:GetNWString("Trail")=="dakflametrail" then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetEntity(self)
		effectdata:SetAttachment(1)
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		util.Effect("dakflametrail", effectdata)
	end

end

if (CLIENT) then
	function ENT:Think()
		if self.Triggered == nil then
			if not(self:GetNWString("FireSound") == "") then
				if self:GetNWBool("Cookoff") then
					sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch"), math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/3000 ),0,0.5) )
				else
					sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch"), math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
				end
				self.Triggered = 1
			end
		end
	end
	function ENT:OnRemove()
		if self:GetNWBool("Explosive") then
			sound.Play( "daktanks/distexp1.wav", LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, 100, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/(500*self:GetNWFloat("ExpDamage")) ),0,1) )
		end
	end
end

if ( CLIENT ) then return end

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
	self:SetNWBool("Explosive",self.DakExplosive)
	self:SetNWFloat("ExpDamage",self.DakSplashDamage)
	if self.DakGun:GetClass()=="dak_teammo" then
		self:SetNWBool("Cookoff",1)
	else
		self:SetNWBool("Cookoff",0)
	end

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
 	if self.DakIsFlame == 1 then
 	else
	 	util.SpriteTrail( self, -1, Color(255,175,50,255), false, (self.DakCaliber*0.0393701), (self.DakCaliber*0.0393701)/2, 0.250, 1 / ((self.DakCaliber*0.0393701) + (self.DakCaliber*0.0393701)/2 ) * 0.5, "trails/smoke.vmt" )
 	end
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

		if hook.Run("DakTankDamageCheck", Hit.Entity, self.DakGun.DakOwner) ~= false then
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
								if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25) then
									Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25
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
								if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25) then
									Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25
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
								Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*2*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
							end
						else
							Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*2*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
						end
						if(Hit.Entity:IsValid() and Hit.Entity:GetClass()~="dak_bot" and Hit.Entity:GetClass()~="prop_ragdoll") then
							if(Hit.Entity:GetParent():IsValid()) then
								if(Hit.Entity:GetParent():GetParent():IsValid()) then
									local Div = Vector(Hit.Entity:GetParent():GetParent():OBBMaxs().x/75,Hit.Entity:GetParent():GetParent():OBBMaxs().y/75,Hit.Entity:GetParent():GetParent():OBBMaxs().z/75)
									Hit.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(self:GetVelocity()*self:GetPhysicsObject():GetMass()/5000)*Hit.Entity:GetParent():GetParent():GetPhysicsObject():GetMass(),Hit.Entity:GetParent():GetParent():GetPos()+Hit.Entity:WorldToLocal(self.LastHit):GetNormalized() )
								end
							end
							if not(Hit.Entity:GetParent():IsValid()) then
								local Div = Vector(Hit.Entity:OBBMaxs().x/75,Hit.Entity:OBBMaxs().y/75,Hit.Entity:OBBMaxs().z/75)
								Hit.Entity:GetPhysicsObject():ApplyForceOffset( Div*(self:GetVelocity()*self:GetPhysicsObject():GetMass()/5000)*Hit.Entity:GetPhysicsObject():GetMass(),Hit.Entity:GetPos()+Hit.Entity:WorldToLocal(self.LastHit):GetNormalized() )
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
						if not(Hit.Entity.SPPOwner==nil) and not(Hit.Entity.SPPOwner:IsWorld()) and Hit.Entity:GetClass()~="dak_bot" then			
							if Hit.Entity.SPPOwner:HasGodMode()==false and Hit.Entity.DakIsTread == nil then	
								Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
							end
						else
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
						end
						if self.DakIsFlame == 1 then
							if Hit.Entity.DakArmor > (7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5 then
								Hit.Entity.DakBurnStacks = Hit.Entity.DakBurnStacks+1
							end
						end
						if(Hit.Entity:IsValid() and Hit.Entity:GetClass()~="dak_bot" and Hit.Entity:GetClass()~="prop_ragdoll") then
							if(Hit.Entity:GetParent():IsValid()) then
								if(Hit.Entity:GetParent():GetParent():IsValid()) then
									local Div = Vector(Hit.Entity:GetParent():GetParent():OBBMaxs().x/75,Hit.Entity:GetParent():GetParent():OBBMaxs().y/75,Hit.Entity:GetParent():GetParent():OBBMaxs().z/75)
									Hit.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(self:GetVelocity()*self:GetPhysicsObject():GetMass()/5000)*Hit.Entity:GetParent():GetParent():GetPhysicsObject():GetMass(),Hit.Entity:GetParent():GetParent():GetPos()+Hit.Entity:WorldToLocal(self.LastHit):GetNormalized() )
								end
							end
							if not(Hit.Entity:GetParent():IsValid()) then
								local Div = Vector(Hit.Entity:OBBMaxs().x/75,Hit.Entity:OBBMaxs().y/75,Hit.Entity:OBBMaxs().z/75)
								Hit.Entity:GetPhysicsObject():ApplyForceOffset( Div*(self:GetVelocity()*self:GetPhysicsObject():GetMass()/5000)*Hit.Entity:GetPhysicsObject():GetMass(),Hit.Entity:GetPos()+Hit.Entity:WorldToLocal(Hit.HitPos):GetNormalized() )
							end
						end
						if self.DakExplosive then
							self:SetPos(Hit.HitPos)
							self:GetPhysicsObject():SetVelocity(Vector(0,0,0))
							self:SetPos(Hit.HitPos)
							self.DakDamage = 0
							self.LastHit = Hit.HitPos
							self.LastHitEnt = Hit.Entity
							self.ExplodeNow = true
						else
						--print( math.deg(math.acos(Hit.HitNormal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
							local effectdata = EffectData()
							if self.DakIsFlame == 1 then
								effectdata:SetOrigin(Hit.HitPos)
								effectdata:SetEntity(self)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(1)
								util.Effect("dakflameimpact", effectdata)
								local Targets = ents.FindInSphere( self.LastHit, 150 )
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
								--util.Decal( "Impact.Scorch", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
								sound.Play( "daktanks/flamerimpact.wav", Hit.HitPos, 100, 100, 1 )
							else
								effectdata:SetOrigin(Hit.HitPos)
								effectdata:SetEntity(self)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(self.DakDamage)
								util.Effect("dakshellbounce", effectdata)
								util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
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
							
							self:SetPos(Hit.HitPos)
							self:GetPhysicsObject():SetVelocity((Vel - 2 * (Hit.HitNormal:Dot(Vel) * (Hit.HitNormal+Vector(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05)))  ))*0.025)
							self:SetPos(Hit.HitPos)
							self.DakPenetration = self.DakPenetration-self.DakPenetration*(Hit.Entity.DakArmor/self.DakPenetration)
							self.DakDamage = 0
							self.LastHit = Hit.HitPos
							self.LastHitEnt = Hit.Entity
							--soundhere bounce sound
							
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
								body.DakHealth=1000000
								body.DakMaxHealth=1000000
								if self.DakIsFlame == 1 then
									body:Ignite(10,1)
								end
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
						Pain:SetDamagePosition( self.LastHitEnt:GetPos() )
						if self.DakIsFlame == 1 then
							Pain:SetDamageType(DMG_BURN)
						else
							Pain:SetDamageType(DMG_CRUSH)
						end
						self.LastHitEnt:TakeDamageInfo( Pain )
					end
					--self.LastHitEnt:TakeDamage( self.DakDamage*50, self.DakGun.DakOwner, self.DakGun )
					if self.LastHitEnt:Health() <= 0 and not(self.DakIsFlame == 1) then
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
						if self.DakIsFlame == 1 then
							effectdata:SetOrigin(Hit.HitPos)
							effectdata:SetEntity(self)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(1)
							util.Effect("dakflameimpact", effectdata)
							local Targets = ents.FindInSphere( self.LastHit, 150 )
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
							--util.Decal( "Impact.Scorch", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
							sound.Play( "daktanks/flamerimpact.wav", Hit.HitPos, 100, 100, 1 )
						else
							effectdata:SetOrigin(Hit.HitPos)
							effectdata:SetEntity(self)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(self.DakDamage)
							util.Effect("dakshellimpact", effectdata)
							util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
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
						self.DakDamage = 0
						self.LastHit = Hit.HitPos
						self.LastHitEnt = Hit.Entity
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
					self:DTExplosion(self.LastHit+(Hit.HitNormal*2),self.DakSplashDamage,self.DakBlastRadius,self.DakCaliber,self.DakBasePenetration*0.4,self.DakGun.DakOwner)
				else
					local effectdata = EffectData()
					if self.DakIsFlame == 1 then
						effectdata:SetOrigin(Hit.HitPos)
						effectdata:SetEntity(self)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(1)
						util.Effect("dakflameimpact", effectdata)
						local Targets = ents.FindInSphere( self.LastHit, 150 )
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
						--util.Decal( "Impact.Scorch", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
						sound.Play( "daktanks/flamerimpact.wav", Hit.HitPos, 100, 100, 1 )
					else
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
						util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
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
		
		else
			self:Remove()
			return false
		end

	end
	self:NextThink( CurTime() )
	return true
end

function ENT:Damage(oldhit)
	if self.Repeats == nil then
		self.Repeats = 0
	end
	self.Repeats = self.Repeats + 1
	if self.Repeats > 5 then
		return
	end
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

	if hook.Run("DakTankDamageCheck", Hit.Entity, self.DakGun.DakOwner) ~= false then
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
							if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25) then
								Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25
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
							if not(Hit.Entity.DakArmor == 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25) then
								Hit.Entity.DakArmor = 7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Hit.Entity.DakBurnStacks*0.25
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
							Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*2*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
						end
					else
						Hit.Entity.DakHealth = Hit.Entity.DakHealth- math.Clamp(self.DakDamage*2*(self.DakPenetration/Hit.Entity.DakArmor),0,Hit.Entity.DakArmor)
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
					if not(Hit.Entity.SPPOwner==nil) and not(Hit.Entity.SPPOwner:IsWorld()) and Hit.Entity:GetClass()~="dak_bot" then		
						if Hit.Entity.SPPOwner:HasGodMode()==false and Hit.Entity.DakIsTread == nil then	
							Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
						end
					else
						Hit.Entity.DakHealth = Hit.Entity.DakHealth-self.DakDamage*0.5
					end
					if self.DakIsFlame == 1 then
						if Hit.Entity.DakArmor > (7.8125*(Hit.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5 then
							Hit.Entity.DakBurnStacks = Hit.Entity.DakBurnStacks+1
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
						if self.DakIsFlame == 1 then
							effectdata:SetOrigin(Hit.HitPos)
							effectdata:SetEntity(self)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(1)
							util.Effect("dakflameimpact", effectdata)
							local Targets = ents.FindInSphere( self.LastHit, 150 )
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
							--util.Decal( "Impact.Scorch", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
							sound.Play( "daktanks/flamerimpact.wav", Hit.HitPos, 100, 100, 1 )
						else
							effectdata:SetOrigin(Hit.HitPos)
							effectdata:SetEntity(self)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(self.DakDamage)
							util.Effect("dakshellbounce", effectdata)
							util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
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
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						if self.DakIsFlame == 1 then
							body:Ignite(10,1)
						end
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
					Pain:SetDamagePosition( self.LastHitEnt:GetPos() )
					if self.DakIsFlame == 1 then
						Pain:SetDamageType(DMG_BURN)
					else
						Pain:SetDamageType(DMG_CRUSH)
					end
					self.LastHitEnt:TakeDamageInfo( Pain )
				end

				if self.LastHitEnt:Health() <= 0 and not(self.DakIsFlame == 1) then
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
					if self.DakIsFlame == 1 then
						effectdata:SetOrigin(Hit.HitPos)
						effectdata:SetEntity(self)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(1)
						util.Effect("dakflameimpact", effectdata)
						local Targets = ents.FindInSphere( self.LastHit, 150 )
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
						--util.Decal( "Impact.Scorch", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
						sound.Play( "daktanks/flamerimpact.wav", Hit.HitPos, 100, 100, 1 )
					else
						effectdata:SetOrigin(Hit.HitPos)
						effectdata:SetEntity(self)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(self.DakDamage)
						util.Effect("dakshellimpact", effectdata)
						util.Decal( "Impact.Concrete", Hit.HitPos+(self:GetForward()*-5), Hit.HitPos+(self:GetForward()*5), self)
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
					self.DakDamage = 0
					self.LastHit = Hit.HitPos
					self.LastHitEnt = Hit.Entity
				end
			end
		end
	else
		self:Remove()
		return false
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
			util.Decal( "Impact.Concrete", self.LastHit, self.LastHit+(Direction*Radius), self)
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if not(ExpTrace.Entity.SPPOwner==nil) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
						end
					else
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
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
						Pain:SetDamageForce( Direction*(Damage/traces)*5000*self:GetPhysicsObject():GetMass() )
						Pain:SetDamage( (Damage/traces)*500 )
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( self.DakGun )
						Pain:SetReportedPosition( self:GetPos() )
						Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
						Pain:SetDamageType(DMG_BLAST)
						ExpTrace.Entity:TakeDamageInfo( Pain )
					end
				end
			end

			if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:GetClass()=="dak_bot") then
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
		util.Decal( "Impact.Concrete", self.LastHit, self.LastHit+(Direction*Radius), self)
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
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
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
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if not(ExpTrace.Entity.SPPOwner==nil) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
					end
				else
					ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- (Damage/traces)*2*(Pen/ExpTrace.Entity.DakArmor)
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
					Pain:SetDamageForce( Direction*(Damage/traces)*5000*self:GetPhysicsObject():GetMass() )
					Pain:SetDamage( (Damage/traces)*500 )
					Pain:SetAttacker( Owner )
					Pain:SetInflictor( self.DakGun )
					Pain:SetReportedPosition( self:GetPos() )
					Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
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