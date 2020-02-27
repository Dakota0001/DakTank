if SERVER then
	hook.Add( "InitPostEntity", "DakTekTankEditionRunOnLoadHook", function()
		local Settings = physenv.GetPerformanceSettings() // copy table from physenfv
		Settings.MaxVelocity = 1000000 // change max velocity
		physenv.SetPerformanceSettings(Settings) // push max velocity back into engine.
		print("DakTekTankEditionLoaded")
	end)


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
							local pitch = math.Clamp(LocalAng.pitch,-10,10)
							local yaw = math.Clamp(LocalAng.yaw,-10,10)
							if math.abs(LocalAng.yaw)>90 then yaw = -math.Clamp(LocalAng.yaw,-10,10) end
							local roll = 0--math.Clamp(LocalAng.roll,-10,10)


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
									trace.endpos = ShellList[i].Pos + (ShellList[i].DakVelocity * (ShellList[i].LifeTime+DakTankBulletThinkDelay)) - (-physenv.GetGravity()*((ShellList[i].LifeTime+DakTankBulletThinkDelay)^2)/2)
								end
							end
						end
						if ShellList[i].RemoveNow ~= 1 then
							trace.filter = ShellList[i].Filter
							trace.mins = Vector(-ShellList[i].DakCaliber*0.02,-ShellList[i].DakCaliber*0.02,-ShellList[i].DakCaliber*0.02)
							trace.maxs = Vector(ShellList[i].DakCaliber*0.02,ShellList[i].DakCaliber*0.02,ShellList[i].DakCaliber*0.02)
							local ShellTrace = util.TraceHull( trace )
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
								if ShellList[i].IsGuided then
									DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,ShellList[i],ShellTrace.HitNormal)
								else
									DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,ShellList[i],ShellTrace.HitNormal)
								end
							end
						end
					end

					if ShellList[i].DieTime then
						if ShellList[i].DieTime<CurTime()then
							RemoveList[#RemoveList+1] = i
						end
					end

					if ShellList[i].RemoveNow == 1 then
						RemoveList[#RemoveList+1] = i
					end
					ShellList[i].LifeTime = ShellList[i].LifeTime + DakTankBulletThinkDelay
				end
			end	
			if #RemoveList > 0 then
				for i = 1, #RemoveList do
					table.remove( ShellList, RemoveList[i] )
				end
			end
		--end
	end )
end
