hook.Add( "InitPostEntity", "DakTekTankEditionRunOnLoadHook", function()
	local Settings = physenv.GetPerformanceSettings() // copy table from physenfv
	Settings.MaxVelocity = 1000000 // change max velocity
	physenv.SetPerformanceSettings(Settings) // push max velocity back into engine.
	print("DakTekTankEditionLoaded")
end)

local math = math
local bmax = 16384
local bmin = -bmax

-- modifies original vector, returns false if it was clamped... not sure about the efficiency of this
function Dak_clampVector(vec)

	local x = vec.x
	local y = vec.y
	local z = vec.z

	local safe = true

	if x < bmin then vec.x = bmin; safe = nil elseif x > bmax then vec.x = bmin; safe = nil end
	if y < bmin then vec.y = bmin; safe = nil elseif y > bmax then vec.y = bmin; safe = nil end
	if z < bmin then vec.z = bmin; safe = nil elseif z > bmax then vec.z = bmin; safe = nil end

	return safe

end
local Dak_clampVector = Dak_clampVector

DakTankShellList = {} --Create Entity list for storing things people spawn
DakTankLastShellThink = 0
--Setup global daktek function for setting up affected entities.
function DakTekTankEditionSetupNewEnt(ent)
	if IsValid(ent) and not (string.Explode("_",ent:GetClass(),false)[1] == "dak") then --make sure its not daktek stuff
 		--setup values
 		if ent.IsDakTekFutureTech == nil then
 			ent.DakBurnStacks = 0
			ent.DakName = "Armor"
			if ent.EntityMods and ent.EntityMods.IsERA==1 then 
				ent.DakMaxHealth = 5
				ent.DakPooled = 1
			else
				if ent:GetClass() == "prop_ragdoll" then
	 				ent.DakHealth = 100000000000000000000
	 			else
		 			if IsValid(ent:GetPhysicsObject()) then
				 		ent.DakHealth = ent:GetPhysicsObject():GetMass()/20
				 	else
				 		ent.DakHealth = 100000000000000000000
				 	end
				end
				if IsValid(ent:GetPhysicsObject()) then
			 		ent.DakMaxHealth = ent:GetPhysicsObject():GetMass()/20
		 		else
			 		ent.DakMaxHealth = 100000000000000000000
			 	end
		 		ent.DakPooled = 0
		 	end
	 		--1 mm of armor on a meter*meter plate would be 8kg
	 		--1 kg gives 0.125 armor
	 		if ent:IsSolid() then
	 			if IsValid(ent:GetPhysicsObject()) then
	 				local SA = ent:GetPhysicsObject():GetSurfaceArea()
	 				if SA == nil then
	 					--Volume = (4/3)*math.pi*math.pow( ent:OBBMaxs().x, 3 )
	 					ent.DakArmor = ent:OBBMaxs().x/2
	 					ent.DakIsTread = 1
	 				else
	 					ent.DakArmor = 7.8125*(ent:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ent.DakBurnStacks*0.25
	 				end
			 	end
		 	else
		 		ent.DakArmor = 0
		 	end
		else
			ent.DakArmor = 1000
		end
 		--ent.DakArmor = (ent:GetPhysicsObject():GetMass()*0.125)
	else
		if IsValid(ent) then
			--exceptions for bots
			if ent:GetClass()=="dak_bot" then
				--ent.DakHealth = ent:GetPhysicsObject():GetMass()/20
				ent.DakBurnStacks = 0
				ent.DakHealth = 10
				ent.DakName = "Armor"
				ent.DakMaxHealth = 10
		 		--ent.DakMaxHealth = ent:GetPhysicsObject():GetMass()/20
		 		ent.DakPooled = 0
		 		ent.DakArmor = 10
			end
		end
	end
end

--example hook add
--hook.Add( "DakTankDamageCheck", "DakTekTankEditionDamageCheck", function (Damaged,Damager)
--end )

function impactexplode(collider, col)
	if collider.IsDakTekFutureTech == nil and col.HitEntity.IsDakTekFutureTech == nil then
		if IsValid(collider.Controller) and IsValid(col.HitEntity.Controller) then
			if not(collider.Controller==col.HitEntity.Controller) then
				if col.HitEntity:GetPhysicsObject():IsMotionEnabled() then
					if hook.Run("DakTankDamageCheck", col.HitEntity, collider.Controller.DakOwner, collider.Controller) ~= false then
						local Damage = ((col.OurOldVelocity-col.TheirOldVelocity):Length()/200)*(collider.DakMaxHealth/col.HitEntity.DakMaxHealth)
						col.HitEntity.DakHealth = col.HitEntity.DakHealth - Damage*25
						collider:EmitSound( "physics/metal/metal_large_debris2.wav" )
						local effectdata = EffectData()
						effectdata:SetOrigin(col.HitPos)
						effectdata:SetEntity(collider)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Damage/10)
						util.Effect("dakshellbounce", effectdata)
					end
				end
			end
		end
	end
end

hook.Add( "OnEntityCreated", "AddCollisionBoomFunction", function( ent )
	ent:AddCallback( "PhysicsCollide", impactexplode )
end )


local DakTankBulletThinkDelay = 0.1
hook.Add( "Think", "DakTankShellTableFunction", function()
	--if CurTime()-DakTankBulletThinkDelay >= DakTankLastShellThink then
		--DakTankLastShellThink = CurTime()
		local ShellList = DakTankShellList
		local RemoveList = {}
		for i = 1, #ShellList do
			if ShellList[i].ShellThinkTime == nil then
				ShellList[i].ShellThinkTime = 0
			end
			if CurTime()-DakTankBulletThinkDelay >= ShellList[i].ShellThinkTime then
				ShellList[i].ShellThinkTime = CurTime()
				--ShellList[i].Gravity = physenv.GetGravity()*ShellList[i].LifeTime
				if ShellList[i].LifeTime>25 then
					ShellList[i].RemoveNow = 1
				else
					local trace = {}
					if ShellList[i].IsGuided then
						local indicatortrace = {}
							if not(ShellList[i].Indicator) or ShellList[i].Indicator==nil or ShellList[i].Indicator==NULL then
								indicatortrace.start = ShellList[i].DakVelocity:GetNormalized()*-10000
								indicatortrace.endpos = ShellList[i].DakVelocity:GetNormalized()*10000
							else
								if ShellList[i].Indicator:IsPlayer() then 
									indicatortrace.start = ShellList[i].Indicator:GetShootPos()
									indicatortrace.endpos = ShellList[i].Indicator:GetShootPos()+ShellList[i].Indicator:GetAimVector()*1000000
								else
									indicatortrace.start = ShellList[i].Indicator:GetPos()
									indicatortrace.endpos = ShellList[i].Indicator:GetPos() + ShellList[i].Indicator:GetForward()*1000000
								end
							end
							indicatortrace.filter = ShellList[i].Filter
						local indicator = util.TraceLine(indicatortrace)
						if not(ShellList[i].SimPos) then
							ShellList[i].SimPos = ShellList[i].Pos
						end

						local difference = ShellList[i].DakVelocity:GetNormalized() - (indicator.HitPos-ShellList[i].SimPos):GetNormalized()
						
						local _, LocalAng = WorldToLocal( indicator.HitPos, (indicator.HitPos-ShellList[i].SimPos):GetNormalized():Angle(), ShellList[i].SimPos, ShellList[i].DakVelocity:GetNormalized():Angle() )
						local pitch = 0
						local yaw = 0
						local roll = 0
						if ShellList[i].LifeTime>0.2 then
							pitch = math.Clamp(LocalAng.pitch,-10,10)
							yaw = math.Clamp(LocalAng.yaw,-10,10)
							if math.abs(LocalAng.yaw)>90 then yaw = -math.Clamp(LocalAng.yaw,-10,10) end
							roll = 0--math.Clamp(LocalAng.roll,-10,10)
						end


						ShellList[i].DakVelocity = (ShellList[i].DakVelocity:GetNormalized():Angle() + Angle(pitch,yaw,roll)):Forward() * math.Clamp((12600/2*ShellList[i].LifeTime) - (7875/20*ShellList[i].LifeTime), 4725, 12600)

						if ShellList[i].LifeTime == 0 then
							trace.start = ShellList[i].SimPos
							ShellList[i].SimPos = ShellList[i].SimPos + (ShellList[i].DakVelocity*DakTankBulletThinkDelay)
						else
							ShellList[i].SimPos = ShellList[i].SimPos + (ShellList[i].DakVelocity*DakTankBulletThinkDelay)
							trace.start = ShellList[i].SimPos + (ShellList[i].DakVelocity*-DakTankBulletThinkDelay)
						end
						trace.endpos = ShellList[i].SimPos + (ShellList[i].DakVelocity*DakTankBulletThinkDelay)
					else
						local DragForce = 0.0245 * ((ShellList[i].DakVelocity:Distance(Vector(0,0,0))*0.0254)*(ShellList[i].DakVelocity:Distance(Vector(0,0,0))*0.0254)) * (math.pi * ((ShellList[i].DakCaliber/2000)*(ShellList[i].DakCaliber/2000)))
						if ShellList[i].DakShellType == "HVAP" then
							DragForce = 0.0245 * ((ShellList[i].DakVelocity:Distance(Vector(0,0,0))*0.0254)*(ShellList[i].DakVelocity:Distance(Vector(0,0,0))*0.0254)) * (math.pi * ((ShellList[i].DakCaliber/1000)*(ShellList[i].DakCaliber/1000)))
						end
						if ShellList[i].DakShellType == "APFSDS" then
							DragForce = 0.085 * ((ShellList[i].DakVelocity:Distance(Vector(0,0,0))*0.0254)*(ShellList[i].DakVelocity:Distance(Vector(0,0,0))*0.0254)) * (math.pi * ((ShellList[i].DakCaliber/1000)*(ShellList[i].DakCaliber/1000)))
						end
						if not(ShellList[i].DakShellType == "HEAT" or ShellList[i].DakShellType == "HEATFS" or ShellList[i].DakShellType == "ATGM" or ShellList[i].DakShellType == "HESH") then
							local PenLoss = ShellList[i].DakBasePenetration*((((DragForce/(ShellList[i].DakMass/2))*DakTankBulletThinkDelay)*39.37)/ShellList[i].DakBaseVelocity)
							ShellList[i].DakPenetration = ShellList[i].DakPenetration - PenLoss
						end
						if ShellList[i].DakShellType == "HEAT" or ShellList[i].DakShellType == "HVAP" or ShellList[i].DakShellType == "ATGM" or ShellList[i].DakShellType == "HEATFS" or ShellList[i].DakShellType == "APFSDS" then
							ShellList[i].DakVelocity = ShellList[i].DakVelocity - (((DragForce/(ShellList[i].DakMass*8/2))*DakTankBulletThinkDelay)*39.37)*ShellList[i].DakVelocity:GetNormalized()
						else
							ShellList[i].DakVelocity = ShellList[i].DakVelocity - (((DragForce/(ShellList[i].DakMass/2))*DakTankBulletThinkDelay)*39.37)*ShellList[i].DakVelocity:GetNormalized()
						end
						if ShellList[i].IsMissile == true then
							ShellList[i].DakVelocity = ShellList[i].DakVelocity:GetNormalized() * (ShellList[i].DakBaseVelocity*(ShellList[i].LifeTime+1))
						end
						if ShellList[i].JustBounced == 1 then
							trace.start = ShellList[i].Pos
							trace.endpos = ShellList[i].Pos + (ShellList[i].DakVelocity * (ShellList[i].LifeTime+0.1)) - (-physenv.GetGravity()*(ShellList[i].LifeTime^2)/2)
							ShellList[i].JustBounced = 0
						else
							if ShellList[i].LifeTime == 0 then
								trace.start = ShellList[i].Pos
							else
								if ShellList[i].Pos == nil or ShellList[i].DakVelocity == nil or physenv.GetGravity() == nil then 
									ShellList[i].RemoveNow = 1
								else
									trace.start = ShellList[i].Pos + (ShellList[i].DakVelocity * (ShellList[i].LifeTime-DakTankBulletThinkDelay)) - (-physenv.GetGravity()*((ShellList[i].LifeTime-DakTankBulletThinkDelay)^2)/2)
								end
							end
							if ShellList[i].RemoveNow ~= 1 then
								if ShellList[i].FuzeDelay~=nil and ShellList[i].LifeTime >= ShellList[i].FuzeDelay-DakTankBulletThinkDelay and ShellList[i].FuzeDelay > 0 then
									trace.endpos = ShellList[i].Pos + (ShellList[i].DakVelocity * (ShellList[i].LifeTime+(ShellList[i].FuzeDelay-ShellList[i].LifeTime))) - (-physenv.GetGravity()*((ShellList[i].LifeTime+(ShellList[i].FuzeDelay-ShellList[i].LifeTime))^2)/2)
								else
									trace.endpos = ShellList[i].Pos + (ShellList[i].DakVelocity * (ShellList[i].LifeTime+DakTankBulletThinkDelay)) - (-physenv.GetGravity()*((ShellList[i].LifeTime+DakTankBulletThinkDelay)^2)/2)
								end
							end
						end
					end
					if ShellList[i].RemoveNow ~= 1 then
						trace.filter = ShellList[i].Filter
						trace.mins = Vector(-ShellList[i].DakCaliber*0.02,-ShellList[i].DakCaliber*0.02,-ShellList[i].DakCaliber*0.02)
						trace.maxs = Vector(ShellList[i].DakCaliber*0.02,ShellList[i].DakCaliber*0.02,ShellList[i].DakCaliber*0.02)

						if not Dak_clampVector(trace.start) or not Dak_clampVector(trace.endpos) then
							ShellList[i].RemoveNow = 1
						end

						local ShellTrace = util.TraceHull( trace )

						--end
						if ShellTrace ~= nil then
							if ShellList[i].Crushed ~= 1 then
								local effectdata = EffectData()
								effectdata:SetStart(ShellTrace.StartPos)
								effectdata:SetOrigin(ShellTrace.HitPos)
								effectdata:SetScale((ShellList[i].DakCaliber*0.0393701))
								if ShellTrace.Hit then
									util.Effect(ShellList[i].DakTrail, effectdata, true, true)
								else
									util.Effect(ShellList[i].DakTrail, effectdata, true, true)
								end
							end

							if ShellTrace.Hit then
								if not(ShellTrace.HitSky and (ShellTrace.HitNormal == Vector(0,0,-1))) then
									--check if aps is near if shellvel is low enough and shell type is right
									--also check if thing is large enough caliber
									--if caliber too big to kill then halve pen?
									--determine if shell is moving towards or away from APS
									if ShellList[i].ShotDown == nil then ShellList[i].ShotDown = 0 end
									local ExpPos = ShellTrace.StartPos
									if ShellList[i].DakVelocity:Length() < 27559.1 then --max vel of shell it can catch 700m/s based off en.wikipedia.org/wiki/Drozd
										if (ShellList[i].DakShellType == "HEAT" or ShellList[i].DakShellType == "HEATFS" or ShellList[i].DakShellType == "ATGM") and  ShellList[i].ShotDown ~= 1 then
											local APS = ents.FindByClass( "dak_tankcore" )
											local Done = 0
											for i=1, #APS do
												if APS[i].APSEnable == true then
													if ShellList[i] ~= nil then
														if ShellList[i].DakCaliber >= APS[i].APSMinCaliber then
															if Done == 0 then
																if ShellTrace.HitPos:Distance(APS[i]:GetPos()) < 275 then --it's in range ~7m based off drozd again
																	if ShellTrace.StartPos:Distance(APS[i]:GetPos())>ShellTrace.HitPos:Distance(APS[i]:GetPos()) then --it's coming at us
																		local _, a = WorldToLocal( APS[i]:GetPos(), (ShellTrace.StartPos-APS[i]:GetPos()):GetNormalized():Angle(), APS[i]:GetPos(), APS[i].Forward:Angle() )
																		local frontalhit = false
																		local sidehit = false
																		local rearhit = false
																		if math.abs(a.yaw) >= 0 and math.abs(a.yaw) <= 45 then
																			frontalhit = true
																		end
																		if math.abs(a.yaw) >= 45 and math.abs(a.yaw) <= 135 then
																			sidehit = true
																		end
																		if math.abs(a.yaw) >= 135 and math.abs(a.yaw) <= 180 then
																			rearhit = true
																		end
																		local CanShoot = false
																		if APS[i].APSFrontalArc == true and frontalhit == true then
																			CanShoot = true
																		end
																		if APS[i].APSSideArc == true and sidehit == true then
																			CanShoot = true
																		end
																		if APS[i].APSRearArc == true and rearhit == true then
																			CanShoot = true
																		end
																		if CanShoot == true then --may need to convert this to angle later for readouts, but this value is nice
																			if APS[i].APSShots > 0 then
																				--play some effect or sound or something maybe
																				APS[i].APSShots = APS[i].APSShots - 1
																				Done = 1
																				ShellList[i].ShotDown = 1
																				ExpPos = APS[i]:GetPos() + (ShellTrace.StartPos-APS[i]:GetPos()):GetNormalized()*275
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
									if ShellList[i].ShotDown == 1 then
										if ShellList[i].DakShellType == "HEAT" or ShellList[i].DakShellType == "HEATFS" or ShellList[i].DakShellType == "ATGM" then
											ShellList[i].RemoveNow = 1
											ShellList[i].ExplodeNow = true
											DTShellAirBurst(ExpPos,ShellList[i],trace.endpos-trace.start)
										end
									else
										if ShellList[i].IsGuided then
											DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,ShellList[i],ShellTrace.HitNormal)
										else
											DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,ShellList[i],ShellTrace.HitNormal)
										end
									end
									
								end
							else
								if ShellList[i].FuzeDelay~=nil and ShellList[i].LifeTime >= ShellList[i].FuzeDelay-DakTankBulletThinkDelay and ShellList[i].FuzeDelay > 0 then
									if ShellList[i].DakShellType == "HE" or ShellList[i].DakShellType == "SM" then
										ShellList[i].ExplodeNow = true
										DTShellAirBurst(trace.endpos,ShellList[i],trace.endpos-trace.start)
									end
								end
							end
						end
					end
				end

				if ShellList[i].DieTime then
					if ShellList[i].DieTime<CurTime()then
						RemoveList[#RemoveList+1] = ShellList[i]
					end
				end

				if ShellList[i].RemoveNow == 1 then
					RemoveList[#RemoveList+1] = ShellList[i]
				end
				ShellList[i].LifeTime = ShellList[i].LifeTime + DakTankBulletThinkDelay
			end
		end
		if #RemoveList > 0 then
			for i = 1, #RemoveList do
				table.RemoveByValue( ShellList, RemoveList[i] )
			end
		end
	--end
end )
