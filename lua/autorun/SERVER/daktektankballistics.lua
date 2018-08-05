local function CheckClip(Ent, HitPos)
	if not Ent.EntityMods then return false end
    if not Ent.EntityMods.clipping_all_prop_clips or Ent:GetClass() ~= "prop_physics" then return false end

    for I = 1, #Ent.EntityMods.clipping_all_prop_clips do
        local Data = Ent.EntityMods.clipping_all_prop_clips[I]
        local Normal = Ent:LocalToWorldAngles(Data[1]):Forward()
        local Origin = Ent:LocalToWorld(Data[1]:Forward()*Data[2])
        
        if Normal:Dot((Origin - HitPos):GetNormalized()) > 0.001 then return true end
    end
    
    return false
end
function DTShellHit(Start,End,HitEnt,Shell,Normal)
	if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner, Shell.DakGun) ~= false then
		if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") then
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
				local EffArmor = 0
				if Shell.DakShellType == "HESH" then
					EffArmor = HitEnt.DakArmor
				else
					EffArmor = (HitEnt.DakArmor/math.abs(Normal:Dot(Vel:GetNormalized())))
				end
				if EffArmor < (Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))) and HitEnt.IsDakTekFutureTech == nil then
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then		
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
						end
					else
						HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
					end
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") then
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
					if Shell.DakShellType == "HESH" then
						DTSpall(End,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))),Shell.DakGun.DakOwner,Shell,((End-(Normal*2))-End):Angle())
					else
						DTSpall(End,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))),Shell.DakGun.DakOwner,Shell,Shell.Ang)
					end
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
					--Shell.LifeTime = 0
					Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
					Shell.DakPenetration = Shell.DakPenetration-(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))*(EffArmor/Shell.DakPenetration)
					--soundhere penetrate sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 100, 1 )
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.DakShellType == "HESH" or Shell.DakShellType == "HEAT" then
						if Shell.DakShellType == "HEAT" then
							DTHEAT(End,HitEnt,Shell.DakCaliber,Shell.DakPenetration,Shell.DakDamage,Shell.DakGun.DakOwner,Shell)
							Shell.HeatPen = true
						end
						local checktrace = {}
							checktrace.start = Start
							checktrace.endpos = End
							checktrace.filter = Shell.Filter
							checktrace.mins = Vector(-1,-1,-1)
							checktrace.maxs = Vector(1,1,1)
						local CheckShellTrace = util.TraceHull( checktrace )
						Shell.Pos = End
						--Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
						DTShellContinue(Start,Shell,Normal)
					end
				else
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt.Base ~= "base_nextbot" then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
						end
					else
						HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
					end
					if Shell.DakIsFlame == 1 then
						if SA then
							if HitEnt.DakArmor > (7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5 then
								if HitEnt.DakBurnStacks == nil then
									HitEnt.DakBurnStacks = 0
								end
								HitEnt.DakBurnStacks = HitEnt.DakBurnStacks+1
							end
						end
					end
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") then
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
						--Shell.LifeTime = 0
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
									if Targets[i]:IsNPC() or Targets[i].Base == "base_nextbot" then
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
						--Shell.LifeTime = 0
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
			if HitEnt:IsPlayer() or HitEnt:IsNPC() or HitEnt.Base == "base_nextbot" then
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
								if Targets[i]:IsNPC() or Targets[i].Base == "base_nextbot" then
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
					--Shell.LifeTime = 0
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
				if Shell.DakShellType == "HESH" or Shell.DakShellType == "HEAT" then
					if Shell.DakShellType == "HEAT" then
						DTShockwave(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
						if Shell.HeatPen == true then
						    --Note the HEAT fragmentation spews inside of the vehicle here
							DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell,HitEnt) 
						else
							DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
						end
					else
						DTShockwave(End+(Normal*2),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					end
				else
					DTShockwave(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
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
								if Targets[i]:IsNPC() or Targets[i].Base == "base_nextbot" then
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
			--Shell.LifeTime = 0
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


	if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner, Shell.DakGun) ~= false then
		if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") then
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
				local EffArmor = 0
				if Shell.DakShellType == "HESH" then
					EffArmor = HitEnt.DakArmor
				else
					EffArmor = (HitEnt.DakArmor/math.abs(Normal:Dot(Vel:GetNormalized())))
				end
				if EffArmor < (Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))) and HitEnt.IsDakTekFutureTech == nil then
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then	
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
						end
					else
						HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
					end
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") then
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

					if Shell.DakShellType == "HESH" then
						DTSpall(End,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))),Shell.DakGun.DakOwner,Shell,((End-(Normal*2))-End):Angle())
					else
						DTSpall(End,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49))),Shell.DakGun.DakOwner,Shell,Shell.Ang)
					end

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
					--Shell.LifeTime = 0
					Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
					Shell.DakPenetration = Shell.DakPenetration-(Shell.DakPenetration-(Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)))*(EffArmor/Shell.DakPenetration)
					--soundhere penetrate sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], End, 100, 100, 1 )
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.DakShellType == "HESH" or Shell.DakShellType == "HEAT" then
						if Shell.DakShellType == "HEAT" then
							DTHEAT(End,HitEnt,Shell.DakCaliber,Shell.DakPenetration,Shell.DakDamage,Shell.DakGun.DakOwner,Shell)
							Shell.HeatPen = true
						end
						local checktrace = {}
							checktrace.start = Start
							checktrace.endpos = End
							checktrace.filter = Shell.Filter
							checktrace.mins = Vector(-1,-1,-1)
							checktrace.maxs = Vector(1,1,1)
						local CheckShellTrace = util.TraceHull( checktrace )
						Shell.Pos = End
						--Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
						DTShellContinue(Start,Shell,Normal)
					end
				else
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt.Base ~= "base_nextbot" then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then	
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
						end
					else
						HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
					end
					if Shell.DakIsFlame == 1 then
						if SA then
							if HitEnt.DakArmor > (7.8125*(HitEnt:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5 then
								if HitEnt.DakBurnStacks == nil then
									HitEnt.DakBurnStacks = 0
								end
								HitEnt.DakBurnStacks = HitEnt.DakBurnStacks+1
							end
						end
					end
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") then
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
						--Shell.LifeTime = 0
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
									if Targets[i]:IsNPC() or Targets[i].Base == "base_nextbot" then
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
						--Shell.LifeTime = 0
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
			if HitEnt:IsPlayer() or HitEnt:IsNPC() or HitEnt.Base == "base_nextbot" then
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
								if Targets[i]:IsNPC() or Targets[i].Base == "base_nextbot" then
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
					--Shell.LifeTime = 0
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
				if Shell.DakShellType == "HESH" or Shell.DakShellType == "HEAT" then
					if Shell.DakShellType == "HEAT" then
						DTShockwave(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
						if Shell.HeatPen == true then
						    --Note the HEAT fragmentation spews inside of the vehicle here
							DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell,HitEnt)  
						else
							DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
						end
					else
						DTShockwave(End+(Normal*2),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					end
				else
					DTShockwave(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					DTExplosion(End+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
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
								if Targets[i]:IsNPC() or Targets[i].Base == "base_nextbot" then
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
			--Shell.LifeTime = 0
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

function DTExplosion(Pos,Damage,Radius,Caliber,Pen,Owner,Shell,HitEnt)
	local traces = math.Round(Caliber/2)
	local Filter = {HitEnt}
	for i=1, traces do
		local Direction = VectorRand()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*Radius*10
			trace.filter = Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local ExpTrace = util.TraceHull( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), HitEnt)
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Base == "base_nextbot") then
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
					ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
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
					local EffArmor = (ExpTrace.Entity.DakArmor/math.abs(ExpTrace.HitNormal:Dot(Direction)))
					if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
						util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
						ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
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
				if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Base == "base_nextbot" then
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

			if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Base == "base_nextbot") then
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

function ContEXP(Filter,IgnoreEnt,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
	local traces = math.Round(Caliber/2)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*Radius*10
		Filter[#Filter+1] = IgnoreEnt
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local ExpTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), IgnoreEnt)
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Base == "base_nextbot") then
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
				ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
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
				local EffArmor = (ExpTrace.Entity.DakArmor/math.abs(ExpTrace.HitNormal:Dot(Direction)))
				if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
					util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
					ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
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
			if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Base == "base_nextbot" then
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
				if hook.Run("DakTankDamageCheck", Targets[i], Owner, Shell.DakGun) ~= false then
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
								ExpPain:SetReportedPosition( Shell.DakGun:GetPos() )
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
				if not(Shell.DakDamageList[i].Base == "base_nextbot") then
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
				if Shell.DakDamageList[i].SPPOwner:HasGodMode()==false and not(Shell.DakDamageList[i].SPPOwner:IsWorld()) then	
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

function DTSpall(Pos,Armor,HitEnt,Caliber,Pen,Owner,Shell, Dir)
	local SpallVolume = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)
	local SpallMass = (SpallVolume*0.0078125) * 0.1
	local SpallPen = Armor * 0.1
	local SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)*0.1

	local traces = 10
	local Filter = {HitEnt}
	for i=1, traces do
		local Ang = 45*(Armor/Pen)
		local Direction = (Dir + Angle(math.Rand(-Ang,Ang),math.Rand(-Ang,Ang),math.Rand(-Ang,Ang))):Forward()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local SpallTrace = util.TraceHull( trace )

		if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner, Shell.DakGun) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
			if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity.Base == "base_nextbot") then
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
					ContSpall(Filter,SpallTrace.Entity,Pos,SpallDamage,SpallPen,Owner,Direction,Shell)
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
							SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
						end
					else
						SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
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
					local EffArmor = (SpallTrace.Entity.DakArmor/math.abs(SpallTrace.HitNormal:Dot(Direction)))
					if EffArmor < SpallPen and SpallTrace.Entity.IsDakTekFutureTech == nil then
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
						util.Decal( "Impact.Concrete", SpallTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})
						ContSpall(Filter,SpallTrace.Entity,Pos,SpallDamage*(1-EffArmor/SpallPen),SpallPen-EffArmor,Owner,Direction,Shell)
					else
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,HitEnt})
					end
				end
			end
			if SpallTrace.Entity:IsValid() then
				if SpallTrace.Entity:IsPlayer() or SpallTrace.Entity:IsNPC() or SpallTrace.Entity.Base == "base_nextbot" then
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

function ContSpall(Filter,IgnoreEnt,Pos,Damage,Pen,Owner,Direction,Shell)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*1000
		Filter[#Filter+1] = IgnoreEnt
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local SpallTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner, Shell.DakGun) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
		if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity.Base == "base_nextbot") then
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
				ContSpall(Filter,SpallTrace.Entity,Pos,Damage,Pen,Owner,Direction,Shell)
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
						SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
					end
				else
					SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
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
				local EffArmor = (SpallTrace.Entity.DakArmor/math.abs(SpallTrace.HitNormal:Dot(Direction)))
				if EffArmor < Pen and SpallTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
					util.Decal( "Impact.Concrete", SpallTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})
					ContSpall(Filter,SpallTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Pen-EffArmor,Owner,Direction,Shell)
				else
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,HitEnt})
				end
			end
		end
		if SpallTrace.Entity:IsValid() then
			if SpallTrace.Entity:IsPlayer() or SpallTrace.Entity:IsNPC() or SpallTrace.Entity.Base == "base_nextbot" then
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

function DTHEAT(Pos,HitEnt,Caliber,Pen,Damage,Owner,Shell)
	local HEATPen = Pen
	local HEATDamage = Damage

	local traces = 10
	local Filter = {HitEnt}
	local Direction = Shell.Ang:Forward()
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*1000
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local HEATTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
		if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") then
			if (CheckClip(HEATTrace.Entity,HEATTrace.HitPos)) or (HEATTrace.Entity:GetPhysicsObject():GetMass()<=1 or (HEATTrace.Entity.DakIsTread==1) and not(HEATTrace.Entity:IsVehicle()) and not(HEATTrace.Entity.IsDakTekFutureTech==1)) then
				if HEATTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
				end
				local SA = HEATTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if HEATTrace.Entity.IsDakTekFutureTech == 1 then
					HEATTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HEATTrace.Entity:OBBMaxs().x, 3 )
						HEATTrace.Entity.DakArmor = HEATTrace.Entity:OBBMaxs().x/2
						HEATTrace.Entity.DakIsTread = 1
					else
						if HEATTrace.Entity:GetClass()=="prop_physics" then 
							if not(HEATTrace.Entity.DakArmor == 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25) then
								HEATTrace.Entity.DakArmor = 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				ContHEAT(Filter,HEATTrace.Entity,Pos,HEATDamage,HEATPen,Owner,Direction,Shell)
			else
				if HEATTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
				end
				local SA = HEATTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if HEATTrace.Entity.IsDakTekFutureTech == 1 then
					HEATTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HEATTrace.Entity:OBBMaxs().x, 3 )
						HEATTrace.Entity.DakArmor = HEATTrace.Entity:OBBMaxs().x/2
						HEATTrace.Entity.DakIsTread = 1
					else
						if HEATTrace.Entity:GetClass()=="prop_physics" then 
							if not(HEATTrace.Entity.DakArmor == 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25) then
								HEATTrace.Entity.DakArmor = 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				
				HEATTrace.Entity.DakLastDamagePos = HEATTrace.HitPos
				--lose 2.54mm of pen per inch of air
				local HeatPenLoss = Pos:Distance(HEATTrace.HitPos)*2.54
				if not(HEATTrace.Entity.SPPOwner==nil) and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
					if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then	
						HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*((HEATPen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
					end
				else
					HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*((HEATPen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
				end
				if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = HEATTrace.Entity:GetModel()
					salvage:SetPos( HEATTrace.Entity:GetPos())
					salvage:SetAngles( HEATTrace.Entity:GetAngles())
					salvage:Spawn()
					HEATTrace.Entity:Remove()
				end
				local EffArmor = (HEATTrace.Entity.DakArmor/math.abs(HEATTrace.HitNormal:Dot(Direction)))
				
				if EffArmor < (HEATPen-HeatPenLoss) and HEATTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
					util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})
					ContHEAT(Filter,HEATTrace.Entity,Pos,HEATDamage*(1-EffArmor/(HEATPen-HeatPenLoss)),(HEATPen-HeatPenLoss)-EffArmor,Owner,Direction,Shell)
				else
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,HitEnt})
				end
			end
		end
		if HEATTrace.Entity:IsValid() then
			if HEATTrace.Entity:IsPlayer() or HEATTrace.Entity:IsNPC() or HEATTrace.Entity.Base == "base_nextbot" then
				if HEATTrace.Entity:GetClass() == "dak_bot" then
					HEATTrace.Entity:SetHealth(HEATTrace.Entity:Health() - (HEATDamage)*500)
					if HEATTrace.Entity:Health() <= 0 and HEATTrace.Entity.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( HEATTrace.Entity:GetPos() )
						body:SetModel( HEATTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						HEATTrace.Entity:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Direction*(HEATDamage)*5000*Shell.DakMass )
					Pain:SetDamage( (HEATDamage)*500 )
					Pain:SetAttacker( Owner )
					Pain:SetInflictor( Shell.DakGun )
					Pain:SetReportedPosition( Shell.DakGun:GetPos() )
					Pain:SetDamagePosition( HEATTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					HEATTrace.Entity:TakeDamageInfo( Pain )
				end
			end
			local effectdata = EffectData()
			effectdata:SetStart(Pos)
			effectdata:SetOrigin(HEATTrace.HitPos)
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

function ContHEAT(Filter,IgnoreEnt,Pos,Damage,Pen,Owner,Direction,Shell)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*1000
		Filter[#Filter+1] = IgnoreEnt
		trace.filter = Filter
		trace.mins = Vector(-1,-1,-1)
		trace.maxs = Vector(1,1,1)
	local HEATTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
		if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") then
			if (CheckClip(HEATTrace.Entity,HEATTrace.HitPos)) or (HEATTrace.Entity:GetPhysicsObject():GetMass()<=1 or (HEATTrace.Entity.DakIsTread==1) and not(HEATTrace.Entity:IsVehicle()) and not(HEATTrace.Entity.IsDakTekFutureTech==1)) then
				if HEATTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
				end
				local SA = HEATTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if HEATTrace.Entity.IsDakTekFutureTech == 1 then
					HEATTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HEATTrace.Entity:OBBMaxs().x, 3 )
						HEATTrace.Entity.DakArmor = HEATTrace.Entity:OBBMaxs().x/2
						HEATTrace.Entity.DakIsTread = 1
					else
						if HEATTrace.Entity:GetClass()=="prop_physics" then 
							if not(HEATTrace.Entity.DakArmor == 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25) then
								HEATTrace.Entity.DakArmor = 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				ContHEAT(Filter,HEATTrace.Entity,Pos,Damage,Pen,Owner,Direction,Shell)
			else
				if HEATTrace.Entity.DakArmor == nil then
					DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
				end
				local SA = HEATTrace.Entity:GetPhysicsObject():GetSurfaceArea()
				if HEATTrace.Entity.IsDakTekFutureTech == 1 then
					HEATTrace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( HEATTrace.Entity:OBBMaxs().x, 3 )
						HEATTrace.Entity.DakArmor = HEATTrace.Entity:OBBMaxs().x/2
						HEATTrace.Entity.DakIsTread = 1
					else
						if HEATTrace.Entity:GetClass()=="prop_physics" then 
							if not(HEATTrace.Entity.DakArmor == 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25) then
								HEATTrace.Entity.DakArmor = 7.8125*(HEATTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - HEATTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				
				HEATTrace.Entity.DakLastDamagePos = HEATTrace.HitPos
				--lose 2.54mm of pen per inch of air
				local HeatPenLoss = Pos:Distance(HEATTrace.HitPos)*2.54
				if not(HEATTrace.Entity.SPPOwner==nil) and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
					if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then	
						HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(Damage*((Pen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
					end
				else
					HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(Damage*((Pen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
				end
				if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = HEATTrace.Entity:GetModel()
					salvage:SetPos( HEATTrace.Entity:GetPos())
					salvage:SetAngles( HEATTrace.Entity:GetAngles())
					salvage:Spawn()
					HEATTrace.Entity:Remove()
				end
				local EffArmor = (HEATTrace.Entity.DakArmor/math.abs(HEATTrace.HitNormal:Dot(Direction)))

				if EffArmor < (Pen-HeatPenLoss) and HEATTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
					util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})
					ContHEAT(Filter,HEATTrace.Entity,Pos,Damage*(1-EffArmor/(Pen-HeatPenLoss)),(Pen-HeatPenLoss)-EffArmor,Owner,Direction,Shell)
				else
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun, HitEnt})
				end
			end
		end
		if HEATTrace.Entity:IsValid() then
			if HEATTrace.Entity:IsPlayer() or HEATTrace.Entity:IsNPC() or HEATTrace.Entity.Base == "base_nextbot" then
				if HEATTrace.Entity:GetClass() == "dak_bot" then
					HEATTrace.Entity:SetHealth(HEATTrace.Entity:Health() - (Damage)*500)
					if HEATTrace.Entity:Health() <= 0 and HEATTrace.Entity.revenge==0 then
						local body = ents.Create( "prop_ragdoll" )
						body:SetPos( HEATTrace.Entity:GetPos() )
						body:SetModel( HEATTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						HEATTrace.Entity:Remove()
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
					Pain:SetDamagePosition( HEATTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					HEATTrace.Entity:TakeDamageInfo( Pain )
				end
			end
			local effectdata = EffectData()
			effectdata:SetStart(Pos)
			effectdata:SetOrigin(HEATTrace.HitPos)
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
