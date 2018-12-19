--[[
local function CheckClip(Ent, HitPos)
	if not Ent.EntityMods then return false end
    if not Ent.EntityMods.clips or Ent:GetClass() ~= "prop_physics" then return false end

    for I = 1, #Ent.EntityMods.clips do
        local Data = Ent.EntityMods.clips[I]
        local Normal = Ent:LocalToWorldAngles(Data[1]):Forward()
        local Origin = Ent:LocalToWorld(Data[1]:Forward()*Data[2])
        
        if Normal:Dot((Origin - HitPos):GetNormalized()) > 0.001 then return true end
    end
    
    return false
end
--this function seemingly only works with that one broken visclip twisted suggested I use once
]]--

function DTGetArmor(Start, End, ShellType, Caliber, Filter)
	local trace = {}
		trace.start = Start
		trace.endpos = End 
		trace.filter = Filter
	local ShellSimTrace = util.TraceLine( trace )

	local HitEnt = ShellSimTrace.Entity
	local EffArmor = 0
	local Shatter = 0
	local HitAng = math.deg(math.acos(ShellSimTrace.HitNormal:Dot(-ShellSimTrace.Normal)))
	if HitEnt.DakHealth == nil then
		DakTekTankEditionSetupNewEnt(HitEnt)
	end
	if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") and (HitEnt.DakHealth and not(HitEnt.DakHealth <= 0)) then
		if not((CheckClip(HitEnt,ShellSimTrace.HitPos)) or (HitEnt:GetPhysicsObject():GetMass()<=1 and not(HitEnt:IsVehicle()) and not(HitEnt.IsDakTekFutureTech==1)) or HitEnt.DakName=="Damaged Component") then
			if HitEnt.DakArmor == nil or HitEnt.DakBurnStacks == nil then
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

			local TDRatio = HitEnt.DakArmor/Caliber
			if ShellType == "APFSDS" then
				TDRatio = HitEnt.DakArmor/(Caliber*2.5)
			end
			if ShellType == "APDS" then
				TDRatio = HitEnt.DakArmor/(Caliber*1.75)
			end
			if HitEnt.IsComposite == 1 then
				EffArmor = DTCompositesTrace( HitEnt, ShellSimTrace.HitPos, ShellSimTrace.Normal, Filter )*9.2
				if ShellType == "APFSDS" or ShellType == "APDS" then
					if ShellType == "APFSDS" then
						if (EffArmor/3)/(Caliber*2.5) >= 0.8 then
							Shatter = 1
						end
					else
						if (EffArmor/3)/(Caliber*1.75) >= 0.8 then
							Shatter = 1
						end
					end
				else
					if (EffArmor/3)/Caliber >= 0.8 then
						Shatter = 1
					end
				end
				if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
					EffArmor = EffArmor*2
				end
			else
				if TDRatio >= 0.8 then
					Shatter = 1
				end
				if ShellType == "HESH" then
					EffArmor = HitEnt.DakArmor
				end
				if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
					EffArmor = (HitEnt.DakArmor/math.abs(ShellSimTrace.HitNormal:Dot(ShellSimTrace.Normal)) )
				end
				if ShellType == "AP" or ShellType == "APHE" or ShellType == "HE" or ShellType == "HVAP" or ShellType == "SM" then
					local aVal = 2.251132 - 0.1955696*math.max( HitAng, 10 ) + 0.009955601*math.pow( math.max( HitAng, 10 ), 2 ) - 0.0001919089*math.pow( math.max( HitAng, 10 ), 3 ) + 0.000001397442*math.pow( math.max( HitAng, 10 ), 4 )
					local bVal = 0.04411227 - 0.003575789*math.max( HitAng, 10 ) + 0.0001886652*math.pow( math.max( HitAng, 10 ), 2 ) - 0.000001151088*math.pow( math.max( HitAng, 10 ), 3 ) + 1.053822e-9*math.pow( math.max( HitAng, 10 ), 4 )
					EffArmor = math.Clamp(HitEnt.DakArmor * (aVal * math.pow( TDRatio, bVal )),HitEnt.DakArmor,10000000000)
				end
				if ShellType == "APDS" then
					EffArmor = HitEnt.DakArmor * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
				end
				if ShellType == "APFSDS" then
					EffArmor = HitEnt.DakArmor * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
				end
			end
		end
	end
	if ShellSimTrace.Hit then
		EndPos = ShellSimTrace.HitPos
	else
		EndPos = End
	end
	return EffArmor, HitEnt, EndPos, Shatter
end

function DTGetArmorRecurse(Start, End, ShellType, Caliber, Filter)
	local Armor, Ent, FirstPenPos, Shattered = DTGetArmor(Start, End, ShellType, Caliber, Filter)
	local Recurse = 1
	local NewFilter = Filter
	NewFilter[#NewFilter+1] = Ent
	local newEnt = Ent
	local newArmor = 0
	local Go = 1
	local LastPenPos = FirstPenPos
	local Shatters = Shattered
	while Go == 1 and Recurse<25 do
		local newArmor, newEnt, LastPenPos, Shattered = DTGetArmor(Start, End, ShellType, Caliber, NewFilter)		
		if Armor == 0 or newArmor == 0 then
			FirstPenPos = LastPenPos
		end
		Shatters = Shatters + Shattered
		if newEnt:IsValid() then
			if newEnt:GetClass() == "dak_crew" or newEnt:GetClass() == "dak_teammo" or newEnt:GetClass() == "dak_teautoloadingmodule" or newEnt:GetClass() == "dak_tefuel" or newEnt:IsWorld() then
				Go = 0
			end
		else
			Go = 0
		end
		if Go == 0 then
			if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
				Armor = Armor + (FirstPenPos:Distance(LastPenPos)*2.54)
			end
			return Armor, newEnt, Shatters
		end
		NewFilter[#NewFilter+1] = newEnt
		Armor = Armor + newArmor
		Recurse = Recurse + 1
	end
end

function DTCompositesTrace( Ent, StartPos, Dir, Filter )
    local Phys = Ent:GetPhysicsObject()
    local Obj = Phys:GetMeshConvexes()
    for I in pairs( Obj ) do
        local Mesh = Obj[ I ]
        local H1
        for K = 1, table.Count( Mesh ), 3 do
            local P1 = Ent:LocalToWorld( Mesh[ K ].pos )
            local P2 = Ent:LocalToWorld( Mesh[ K + 1 ].pos )
            local P3 = Ent:LocalToWorld( Mesh[ K + 2 ].pos )
            local S1 = P2 - P1
            local S2 = P3 - P1
            local Norm = S1:Cross( S2 ):GetNormalized()
            local Pos = util.IntersectRayWithPlane( StartPos, Dir, P1, Norm ) --Thanks Garry
            if Pos then
                local S3 = Pos - P1
                local D1 = S1:Dot(S1)
                local D2 = S1:Dot(S2)
                local D3 = S1:Dot(S3)
                local D4 = S2:Dot(S2)
                local D5 = S2:Dot(S3)
                local ID = 1 / ( D1 * D4 - D2 * D2 )
                local U = ( D4 * D3 - D2 * D5 ) * ID
                local V = ( D1 * D5 - D2 * D3 ) * ID
                if U >= 0 and V >= 0 and U + V < 1 then
                    if H1 then 
                    	--Only get the first example of entry/exit as the trace will be called again when the bullet hits the other side of the prop (thinking about it, the prop gets filtered out after first time touched, will revisit later)
                		local checktrace = {}
							checktrace.start = StartPos
							checktrace.endpos = H1
							if Filter == nil then
								checktrace.filter = {Ent}
							else
								local checkfilter = table.Copy( Filter )
								checkfilter[#checkfilter+1] = Ent
								checktrace.filter = checkfilter
							end
						local checkinternaltrace = util.TraceLine( checktrace )
						if IsValid(checkinternaltrace.Entity) and Pos:Distance(checkinternaltrace.HitPos)<Pos:Distance(H1) then
							return Pos:Distance(checkinternaltrace.HitPos)
						end
                    	return Pos:Distance(H1)
                    else
                    	H1 = Pos
                    end
                end
            end
        end
    end
    return 0
end

function CheckClip(Ent, HitPos)
	if not (Ent:GetClass() == "prop_physics") or (Ent.ClipData == nil) then return false end
	local HitClip = false
	local normal
	local origin
	for i=1, #Ent.ClipData do
		normal = Ent:LocalToWorldAngles(Ent.ClipData[i]["n"]):Forward()
		origin = Ent:LocalToWorld(Ent.ClipData[i]["n"]:Forward()*Ent.ClipData[i]["d"])
		HitClip = HitClip or normal:Dot((origin - HitPos):GetNormalized()) > 0
		if HitClip then return true end
	end
	return HitClip
end

function DTShellHit(Start,End,HitEnt,Shell,Normal)
	local newtrace = {}
		newtrace.start = Start - 250*(Shell.Ang:Forward())
		newtrace.endpos = End + 250*(Shell.Ang:Forward())
		newtrace.filter = Shell.Filter
		newtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
		newtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
	local HitCheckShellTrace = util.TraceHull( newtrace )
	local HitCheckNormalTrace = util.TraceLine( newtrace )
	Normal = HitCheckShellTrace.HitNormal
	HitEnt = HitCheckShellTrace.Entity
	local HitPos = HitCheckShellTrace.HitPos
	if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner, Shell.DakGun) ~= false then
		if HitEnt.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(HitEnt)
		end
		if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") and (HitEnt.DakHealth and not(HitEnt.DakHealth <= 0)) then
			if (CheckClip(HitEnt,HitPos)) or (HitEnt:GetPhysicsObject():GetMass()<=1 and not(HitEnt:IsVehicle()) and not(HitEnt.IsDakTekFutureTech==1)) or HitEnt.DakName=="Damaged Component" then
				if HitEnt.DakArmor == nil or HitEnt.DakBurnStacks == nil then
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
				DTShellContinue(Start - 250*(Shell.Ang:Forward()),End + 250*(Shell.Ang:Forward()),Shell,Normal,true)
			else
				if HitEnt.DakArmor == nil or HitEnt.DakBurnStacks == nil then
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
				
				HitEnt.DakLastDamagePos = HitPos

				local Vel = Shell.Ang:Forward()
				local EffArmor = 0

				local CurrentPen = Shell.DakPenetration-Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)

				local HitAng = math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() )))

				
				local TDRatio = 0
				local PenRatio = 0
				local CompArmor = DTCompositesTrace( HitEnt, HitPos, Shell.Ang:Forward(), Shell.Filter )*9.2
				if HitEnt.IsComposite == 1 then
					if Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS" then
						if Shell.DakShellType == "APFSDS" then
							TDRatio = (CompArmor/3)/(Shell.DakCaliber*2.5)
						else
							TDRatio = (CompArmor/3)/(Shell.DakCaliber*1.75)
						end
					else
						TDRatio = (CompArmor/3)/Shell.DakCaliber
					end
					PenRatio = CurrentPen/CompArmor
				else
					if Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS" then
						if Shell.DakShellType == "APFSDS" then
							TDRatio = HitEnt.DakArmor/(Shell.DakCaliber*2.5)
						else
							TDRatio = HitEnt.DakArmor/(Shell.DakCaliber*1.75)
						end
					else
						TDRatio = HitEnt.DakArmor/Shell.DakCaliber
					end
					PenRatio = CurrentPen/HitEnt.DakArmor
				end
				--shattering occurs when TD ratio is above 0.8 and pen is 1.05 to 1.25 times more than the armor
				--random chance to pen happens between 0.9 and 1.2 pen to armor ratio
				--if pen to armor ratio is 0.9 or below round fails
				--if T/D ratio is above 0.8 and round pens it still shatters 
				--round must also be going above 600m/s
				local Failed = 0
				local Shattered = 0
				local ShatterVel = 600
				if Shell.DakShellType == "APFSDS" then
					ShatterVel = 1500
				end	
				if Shell.DakShellType == "APDS" then
					ShatterVel = 1050
				end				
				if Shell.DakVelocity*0.0254 > ShatterVel and not(Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then
					if TDRatio > 0.8 then
						if PenRatio < 0.9 then
							Failed = 1
							Shattered = 0
						end
						if PenRatio >= 0.9 and PenRatio < 1.05 then
							Failed = math.random(0,1)
							Shattered = 0
						end
						if PenRatio >= 1.05 and PenRatio < 1.25 then
							Failed = 1
							Shattered = 1
						end
						if PenRatio >= 1.25 then
							Failed = 0
							Shattered = 1
						end
					else
						if PenRatio < 0.9 then
							Failed = 1
							Shattered = 0
						end
						if PenRatio >= 0.9 and PenRatio < 1.20 then
							Failed = math.random(0,1)
							Shattered = 0
						end
						if PenRatio >= 1.20 then
							Failed = 0
							Shattered = 0
						end
					end
				end
				if (Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then
					if HitAng >= 80 then
						Failed = 1
						Shattered = 1
					end
					if HitAng >= 70 and HitAng < 80 then
						Failed = 0
						Shattered = 1
					end
				end
				
				if HitEnt.IsComposite == 1 then
					EffArmor = CompArmor
					if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH" then
						EffArmor = EffArmor*2
					end
				else
					if Shell.DakShellType == "HESH" then
						EffArmor = HitEnt.DakArmor
					end
					if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
						EffArmor = (HitEnt.DakArmor/math.abs(Normal:Dot(Vel:GetNormalized())) )
					end
					if Shell.DakShellType == "AP" or Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "HVAP" or Shell.DakShellType == "SM" then
						local aVal = 2.251132 - 0.1955696*math.max( HitAng, 10 ) + 0.009955601*math.pow( math.max( HitAng, 10 ), 2 ) - 0.0001919089*math.pow( math.max( HitAng, 10 ), 3 ) + 0.000001397442*math.pow( math.max( HitAng, 10 ), 4 )
						local bVal = 0.04411227 - 0.003575789*math.max( HitAng, 10 ) + 0.0001886652*math.pow( math.max( HitAng, 10 ), 2 ) - 0.000001151088*math.pow( math.max( HitAng, 10 ), 3 ) + 1.053822e-9*math.pow( math.max( HitAng, 10 ), 4 )
						EffArmor = math.Clamp(HitEnt.DakArmor * (aVal * math.pow( TDRatio, bVal )),HitEnt.DakArmor,10000000000)
					end
					if Shell.DakShellType == "APDS" then
						EffArmor = HitEnt.DakArmor * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
					end
					if Shell.DakShellType == "APFSDS" then
						EffArmor = HitEnt.DakArmor * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
					end
				end
				if EffArmor < (CurrentPen) and HitEnt.IsDakTekFutureTech == nil and Failed == 0 then
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then		
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)*0.001
							else
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
							end
						end
					else
						if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)*0.001
						else
							HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
						end
					end
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								end
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
						end
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.DakShellType == "HESH" then
						DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(CurrentPen),Shell.DakGun.DakOwner,Shell,((HitPos-(Normal*2))-HitPos):Angle())
					else
						if Shattered == 1 then
							DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber*2,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.Ang)
						else
							DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.Ang)
						end
					end
					local effectdata = EffectData()
					effectdata:SetOrigin(HitPos)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakCaliber*0.25)
					util.Effect("dakteshellpenetrate", effectdata, true, true)
					util.Decal( "Impact.Concrete", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
					util.Decal( "Impact.Concrete", HitPos+((HitPos-Start):GetNormalized()*5), HitPos-((HitPos-Start):GetNormalized()*5), Shell.DakGun)
					Shell.DakVelocity = Shell.DakVelocity - (Shell.DakVelocity * (EffArmor/Shell.DakPenetration))
					Shell.Pos = HitPos
					Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
					Shell.DakPenetration = Shell.DakPenetration-(CurrentPen)*(EffArmor/Shell.DakPenetration)
					if Shattered == 1 then
						Shell.DakDamage = Shell.DakDamage*0.5
						Shell.DakPenetration = Shell.DakPenetration*0.5
					end
					--soundhere penetrate sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], HitPos, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], HitPos, 100, 100, 1 )
					end
					if Shell.DakShellType == "HESH" or Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							Shell.LifeTime = 0
							DTHEAT(HitPos,HitEnt,Shell.DakCaliber,Shell.DakPenetration,Shell.DakDamage,Shell.DakGun.DakOwner,Shell)
							Shell.HeatPen = true
						end
						Shell.Pos = HitPos
						Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
						DTShellContinue(Start - 250*(Shell.Ang:Forward()),End + 250*(Shell.Ang:Forward()),Shell,Normal)
						Shell.LifeTime = 0
					end
				else
					if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt.Base ~= "base_nextbot" then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25*0.001
							else
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
							end
						end
					else
						if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25*0.001
						else
							HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
						end
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
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								end							
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
						end
					end
					if Shell.DakExplosive then
						Shell.Pos = HitPos
						Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
					--print( math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
						local effectdata = EffectData()
						if Shell.DakIsFlame == 1 then
							effectdata:SetOrigin(HitPos)
							effectdata:SetEntity(Shell.DakGun)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(1)
							util.Effect("dakteflameimpact", effectdata, true, true)
							local Targets = ents.FindInSphere( HitPos, 150 )
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
							sound.Play( "daktanks/flamerimpact.wav", HitPos, 100, 100, 1 )
						else
							if Shell.DakDamage >= 0 then
								effectdata:SetOrigin(HitPos)
								effectdata:SetEntity(Shell.DakGun)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(Shell.DakCaliber*0.25)
								util.Effect("dakteshellbounce", effectdata, true, true)
								util.Decal( "Impact.Glass", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
								local BounceSounds = {}
								if Shell.DakCaliber < 20 then
									BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
								else
									BounceSounds = {"daktanks/dakrico1.wav","daktanks/dakrico2.wav","daktanks/dakrico3.wav","daktanks/dakrico4.wav","daktanks/dakrico5.wav","daktanks/dakrico6.wav"}
								end
								if Shell.DakIsPellet then
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], HitPos, 100, 150, 0.25 )
								else
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], HitPos, 100, 100, 1 )
								end
								--if (90-math.abs(math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))))) > 45 then
									Shell.DakVelocity = Shell.DakVelocity*0.025
									Shell.Ang = ((HitPos-Start) - 1.25 * (Normal:Dot(HitPos-Start) * Normal)):Angle() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
									Shell.DakPenetration = 0
									Shell.DakDamage = 0
									Shell.LifeTime = 0.0
									Shell.Pos = HitPos
								--else
								--	local Energy = (math.abs(math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))))/90)
								--	Shell.DakVelocity = Shell.DakVelocity*Energy
								--	Shell.Ang = ((HitPos-Start) - 1* (Normal:Dot(HitPos-Start) * Normal)):Angle() + Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),math.Rand(-0.5,0.5))
								--	Shell.DakPenetration = Shell.DakPenetration*Energy
								--	Shell.DakDamage = Shell.DakDamage*Energy
								--	Shell.Filter[#Shell.Filter+1] = HitEnt
								--	Shell.LifeTime = 0.0
								--	local HitVel = HitEnt:GetVelocity() 
								--	if HitEnt:GetParent() then
								--		HitVel = HitEnt:GetParent():GetVelocity() 
								--	end
								--	if HitEnt:GetParent():GetParent() then
								--		HitVel = HitEnt:GetParent():GetParent():GetVelocity() 
								--	end
								--	Shell.Pos = HitPos
								--end	
							end
							Shell.Filter[#Shell.Filter+1] = HitEnt
						end
						--soundhere bounce sound
					end
				end
				if HitEnt.DakHealth <= 0 and HitEnt.DakPooled==0 then
					Shell.Filter[#Shell.Filter+1] = HitEnt
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = HitEnt:GetModel()
					salvage:SetPos( HitEnt:GetPos())
					salvage:SetAngles( HitEnt:GetAngles())
					salvage:Spawn()
					Shell.Filter[#Shell.Filter+1] = salvage
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
					local checkhitboxtrace = {}
						checkhitboxtrace.start = Shell.Pos + (Shell.DakVelocity * Shell.Ang:Forward() * (Shell.LifeTime-0.1)) - (-physenv.GetGravity()*((Shell.LifeTime-0.1)^2)/2)
						checkhitboxtrace.endpos = Shell.Pos + (Shell.DakVelocity * Shell.Ang:Forward() * Shell.LifeTime) - (-physenv.GetGravity()*(Shell.LifeTime^2)/2)
						checkhitboxtrace.filter = Shell.Filter
						checkhitboxtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
						checkhitboxtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
					local HitboxTrace = util.TraceHull( checkhitboxtrace )
					local Pain = DamageInfo()
					Pain:SetDamageForce( Shell.Ang:Forward()*Shell.DakDamage*Shell.DakMass*Shell.DakVelocity )
					Pain:SetDamage( Shell.DakDamage*500 )
					Pain:SetAttacker( Shell.DakGun.DakOwner )
					Pain:SetInflictor( Shell.DakGun )
					Pain:SetReportedPosition( HitPos )
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
					effectdata:SetOrigin(HitPos)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakCaliber*0.25)
					util.Effect("dakteshellpenetrate", effectdata, true, true)
					util.Decal( "Impact.Concrete", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
					util.Decal( "Impact.Concrete", HitPos+((HitPos-Start):GetNormalized()*5), HitPos-((HitPos-Start):GetNormalized()*5), Shell.DakGun)
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.salvage then
						Shell.Filter[#Shell.Filter+1] = Shell.salvage
					end
					DTShellContinue(Start - 250*(Shell.Ang:Forward()),End + 250*(Shell.Ang:Forward()),Shell,Normal)
					--soundhere penetrate human sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], HitPos, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], HitPos, 100, 100, 1 )
					end
				else
					local effectdata = EffectData()
					if Shell.DakIsFlame == 1 then
						effectdata:SetOrigin(HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(1)
						util.Effect("dakteflameimpact", effectdata, true, true)
						local Targets = ents.FindInSphere( HitPos, 150 )
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
						sound.Play( "daktanks/flamerimpact.wav", HitPos, 100, 100, 1 )
					else
						effectdata:SetOrigin(HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Shell.DakCaliber*0.25)
						util.Effect("dakteshellimpact", effectdata, true, true)
						util.Decal( "Impact.Concrete", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
						local ExpSounds = {}
						if Shell.DakCaliber < 20 then
							ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
						else
							ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
						end

						if Shell.DakIsPellet then
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 150, 0.25 )	
						else
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 100, 1 )	
						end
					end
					Shell.RemoveNow = 1
					if Shell.DakExplosive then
						Shell.ExplodeNow = true
					end
					Shell.LifeTime = 0
					Shell.DakVelocity = 0
					Shell.DakDamage = 0
				end
			end
		end
		if HitEnt:IsWorld() or Shell.ExplodeNow==true then
			if Shell.DakExplosive then
				local effectdata = EffectData()
				effectdata:SetOrigin(HitPos)
				effectdata:SetEntity(Shell.DakGun)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(.5)
				effectdata:SetScale(Shell.DakBlastRadius)
				effectdata:SetNormal( Normal )
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
					sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 100, 1 )	
				end
				if Shell.DakShellType == "HESH" then
					DTShockwave(HitPos+(Normal*2),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
				else
					DTShockwave(HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					DTExplosion(HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
				end
			else
				local effectdata = EffectData()
				if Shell.DakIsFlame == 1 then
					effectdata:SetOrigin(HitPos)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(1)
					util.Effect("dakteflameimpact", effectdata, true, true)
					local Targets = ents.FindInSphere( HitPos, 150 )
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
					sound.Play( "daktanks/flamerimpact.wav", HitPos, 100, 100, 1 )
				else
					effectdata:SetOrigin(HitPos)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					if Shell.DakDamage == 0 then
						effectdata:SetScale(0.5)
					else
						effectdata:SetScale(Shell.DakCaliber*0.25)
					end
					util.Effect("dakteshellimpact", effectdata, true, true)
					util.Decal( "Impact.Concrete", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
					local ExpSounds = {}
					if Shell.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
					end

					if Shell.DakIsPellet then
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 150, 0.25 )	
					else
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 100, 1 )	
					end
				end
			end
			Shell.RemoveNow = 1
			if Shell.DakExplosive then
				Shell.ExplodeNow = true
			end
			Shell.LifeTime = 0
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

function DTShellContinue(Start,End,Shell,Normal,HitNonHitable)
	local Fuze = 25
	if Shell.DakShellType == "HE" or Shell.DakShellType == "SM" then
		Fuze = 5
	end
	local newtrace = {}
		if (Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "SM") and not(HitNonHitable) then
			newtrace.start = Shell.Pos
			newtrace.endpos = Shell.Pos + (Fuze * Shell.Ang:Forward())
		else
			newtrace.start = Start
			newtrace.endpos = End
		end
		newtrace.filter = Shell.Filter
		newtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
		newtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
	local ContShellTrace = util.TraceHull( newtrace )
	Normal = ContShellTrace.HitNormal
	if (Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "SM") and not(ContShellTrace.Hit) and not(HitNonHitable) then
		if Shell.DieTime == nil then
			Shell.DieTime = CurTime()
		end
		local effectdata = EffectData()
		effectdata:SetOrigin(Shell.Pos + (Fuze * Shell.Ang:Forward()))
		effectdata:SetEntity(Shell.DakGun)
		effectdata:SetAttachment(1)
		effectdata:SetMagnitude(.5)
		if Shell.DakShellType == "APHE" then
			effectdata:SetScale(Shell.DakBlastRadius*0.25)
		else
			effectdata:SetScale(Shell.DakBlastRadius)
		end
		effectdata:SetNormal( Normal )
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
			sound.Play( ExpSounds[math.random(1,#ExpSounds)], Shell.Pos + (Fuze * Shell.Ang:Forward()), 100, 100, 1 )	
		end
		if Shell.DakShellType == "APHE" then
			DTAPHE(Shell.Pos + (Fuze * Shell.Ang:Forward()),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
		else
			DTShockwave(Shell.Pos + (Fuze * Shell.Ang:Forward()),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
			DTExplosion(Shell.Pos + (Fuze * Shell.Ang:Forward()),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
		end
	else
		local HitEnt = ContShellTrace.Entity
		--local End = ContShellTrace.HitPos
		local effectdata = EffectData()
		effectdata:SetStart(ContShellTrace.StartPos)
		effectdata:SetOrigin(ContShellTrace.HitPos)
		effectdata:SetScale((Shell.DakCaliber*0.0393701))
		util.Effect("dakteballistictracer", effectdata, true, true)

		if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner, Shell.DakGun) ~= false then
			if HitEnt.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(HitEnt)
			end
			if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") and (HitEnt.DakHealth and not(HitEnt.DakHealth <= 0)) then
				if (CheckClip(HitEnt,ContShellTrace.HitPos)) or (HitEnt:GetPhysicsObject():GetMass()<=1 and not(HitEnt:IsVehicle()) and not(HitEnt.IsDakTekFutureTech==1)) or HitEnt.DakName=="Damaged Component" then
					if HitEnt.DakArmor == nil or HitEnt.DakBurnStacks == nil then
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
					DTShellContinue(Start,End,Shell,Normal,true)
				else
					if HitEnt.DakArmor == nil or HitEnt.DakBurnStacks == nil then
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
					
					HitEnt.DakLastDamagePos = ContShellTrace.HitPos

					local Vel = Shell.Ang:Forward()
					local EffArmor = 0

					local CurrentPen = Shell.DakPenetration-Shell.DakPenetration*Shell.DakVelocity*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)

					local HitAng = math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() )))

					local TDRatio = 0
					local PenRatio = 0
					local CompArmor = DTCompositesTrace( HitEnt, ContShellTrace.HitPos, Shell.Ang:Forward(), Shell.Filter )*9.2
					if HitEnt.IsComposite == 1 then
						if Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS" then
							if Shell.DakShellType == "APFSDS" then
								TDRatio = (CompArmor/3)/(Shell.DakCaliber*2.5)
							else
								TDRatio = (CompArmor/3)/(Shell.DakCaliber*1.75)
							end
						else
							TDRatio = (CompArmor/3)/Shell.DakCaliber
						end
						PenRatio = CurrentPen/CompArmor
					else
						if Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS" then
							if Shell.DakShellType == "APFSDS" then
								TDRatio = HitEnt.DakArmor/(Shell.DakCaliber*2.5)
							else
								TDRatio = HitEnt.DakArmor/(Shell.DakCaliber*1.75)
							end
						else
							TDRatio = HitEnt.DakArmor/Shell.DakCaliber
						end
						PenRatio = CurrentPen/HitEnt.DakArmor
					end

					--shattering occurs when TD ratio is above 0.8 and pen is 1.05 to 1.25 times more than the armor
					--random chance to pen happens between 0.9 and 1.2 pen to armor ratio
					--if pen to armor ratio is 0.9 or below round fails
					--if T/D ratio is above 0.8 and round pens it still shatters 
					--round must also be going above 600m/s
					local Failed = 0
					local Shattered = 0
					local ShatterVel = 600
					if Shell.DakShellType == "APFSDS" then
						ShatterVel = 1500
					end	
					if Shell.DakShellType == "APDS" then
						ShatterVel = 1050
					end	
					if Shell.DakVelocity*0.0254 > ShatterVel and not(Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then
						if TDRatio > 0.8 then
							if PenRatio < 0.9 then
								Failed = 1
								Shattered = 0
							end
							if PenRatio >= 0.9 and PenRatio < 1.05 then
								Failed = math.random(0,1)
								Shattered = 0
							end
							if PenRatio >= 1.05 and PenRatio < 1.25 then
								Failed = 1
								Shattered = 1
							end
							if PenRatio >= 1.25 then
								Failed = 0
								Shattered = 1
							end
						else
							if PenRatio < 0.9 then
								Failed = 1
								Shattered = 0
							end
							if PenRatio >= 0.9 and PenRatio < 1.20 then
								Failed = math.random(0,1)
								Shattered = 0
							end
							if PenRatio >= 1.20 then
								Failed = 0
								Shattered = 0
							end
						end
					end
					if (Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then
						if HitAng >= 80 then
							Failed = 1
							Shattered = 1
						end
						if HitAng >= 70 and HitAng < 80 then
							Failed = 0
							Shattered = 1
						end
					end
					if HitEnt.IsComposite == 1 then
						EffArmor = CompArmor
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH" then
							EffArmor = EffArmor*2
						end
					else
						if Shell.DakShellType == "HESH" then
							EffArmor = HitEnt.DakArmor
						end
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							EffArmor = (HitEnt.DakArmor/math.abs(Normal:Dot(Vel:GetNormalized())) )
						end
						if Shell.DakShellType == "AP" or Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "HVAP" or Shell.DakShellType == "SM" then
							local aVal = 2.251132 - 0.1955696*math.max( HitAng, 10 ) + 0.009955601*math.pow( math.max( HitAng, 10 ), 2 ) - 0.0001919089*math.pow( math.max( HitAng, 10 ), 3 ) + 0.000001397442*math.pow( math.max( HitAng, 10 ), 4 )
							local bVal = 0.04411227 - 0.003575789*math.max( HitAng, 10 ) + 0.0001886652*math.pow( math.max( HitAng, 10 ), 2 ) - 0.000001151088*math.pow( math.max( HitAng, 10 ), 3 ) + 1.053822e-9*math.pow( math.max( HitAng, 10 ), 4 )
							EffArmor = math.Clamp(HitEnt.DakArmor * (aVal * math.pow( TDRatio, bVal )),HitEnt.DakArmor,10000000000)
						end
						if Shell.DakShellType == "APDS" then
							EffArmor = HitEnt.DakArmor * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
						end
						if Shell.DakShellType == "APFSDS" then
							EffArmor = HitEnt.DakArmor * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
						end
					end
					if EffArmor < (CurrentPen) and HitEnt.IsDakTekFutureTech == nil and Failed == 0 then
						if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then			
							if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
								if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
									HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)*0.001
								else	
									HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
								end
							end
						else
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)*0.001
							else
								HitEnt.DakHealth = HitEnt.DakHealth- math.Clamp(Shell.DakDamage*((CurrentPen)/HitEnt.DakArmor),0,HitEnt.DakArmor*2)
							end
						end
						if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") then
							if(HitEnt:GetParent():IsValid()) then
								if(HitEnt:GetParent():GetParent():IsValid()) then
									if HitEnt.Controller then
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									else
										local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									end
								end
							end
							if not(HitEnt:GetParent():IsValid()) then
								local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
								HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
							end
						end
						Shell.Filter[#Shell.Filter+1] = HitEnt
						if Shell.DakShellType == "HESH" then
							DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(CurrentPen),Shell.DakGun.DakOwner,Shell,((ContShellTrace.HitPos-(Normal*2))-ContShellTrace.HitPos):Angle())
						else
							if Shattered == 1 then
								DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber*2,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.Ang)
							else
								DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.Ang)
							end
						end

						local effectdata = EffectData()
						effectdata:SetOrigin(ContShellTrace.HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Shell.DakCaliber*0.25)
						util.Effect("dakteshellpenetrate", effectdata, true, true)
						util.Decal( "Impact.Concrete", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
						util.Decal( "Impact.Concrete", ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
						Shell.DakVelocity = Shell.DakVelocity - (Shell.DakVelocity * (EffArmor/Shell.DakPenetration))
						Shell.Pos = ContShellTrace.HitPos
						
						Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
						Shell.DakPenetration = Shell.DakPenetration-(CurrentPen)*(EffArmor/Shell.DakPenetration)
						if Shattered == 1 then
							Shell.DakDamage = Shell.DakDamage*0.5
							Shell.DakPenetration = Shell.DakPenetration*0.5
						end
						--soundhere penetrate sound
						if Shell.DakIsPellet then
							sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )
						else
							sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], ContShellTrace.HitPos, 100, 100, 1 )
						end
						
						if Shell.DakShellType == "HESH" or Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
								Shell.LifeTime = 0
								DTHEAT(ContShellTrace.HitPos,HitEnt,Shell.DakCaliber,Shell.DakPenetration,Shell.DakDamage,Shell.DakGun.DakOwner,Shell)
								Shell.HeatPen = true
							end
							Shell.Pos = ContShellTrace.HitPos
							Shell.LifeTime = 0
							Shell.DakVelocity = 0
							Shell.DakDamage = 0
							Shell.ExplodeNow = true
						else
							DTShellContinue(Start,End,Shell,Normal)
							Shell.LifeTime = 0
						end
					else
						if not(HitEnt.SPPOwner==nil) and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt.Base ~= "base_nextbot" then			
							if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
								if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
									HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25*0.01
								else	
									HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
								end
							end
						else
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25*0.01
							else
								HitEnt.DakHealth = HitEnt.DakHealth-Shell.DakDamage*0.25
							end
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
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*((Shell.DakVelocity*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									else
										local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									end
								end
							end
							if not(HitEnt:GetParent():IsValid()) then
								local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
								HitEnt:GetPhysicsObject():ApplyForceOffset( Div*(Shell.DakVelocity*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
							end
						end
						if Shell.DakExplosive then
							Shell.Pos = ContShellTrace.HitPos
							Shell.LifeTime = 0
							Shell.DakVelocity = 0
							Shell.DakDamage = 0
							Shell.ExplodeNow = true
						else
						--print( math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))) ) -- hit angle
							local effectdata = EffectData()
							if Shell.DakIsFlame == 1 then
								effectdata:SetOrigin(ContShellTrace.HitPos)
								effectdata:SetEntity(Shell.DakGun)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(1)
								util.Effect("dakteflameimpact", effectdata, true, true)
								local Targets = ents.FindInSphere( ContShellTrace.HitPos, 150 )
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
								sound.Play( "daktanks/flamerimpact.wav", ContShellTrace.HitPos, 100, 100, 1 )
							else
								if Shell.DakDamage > 0 then
									effectdata:SetOrigin(ContShellTrace.HitPos)
									effectdata:SetEntity(Shell.DakGun)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetScale(Shell.DakCaliber*0.25)
									util.Effect("dakteshellbounce", effectdata, true, true)
									util.Decal( "Impact.Glass", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
									local BounceSounds = {}
									if Shell.DakCaliber < 20 then
										BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
									else
										BounceSounds = {"daktanks/dakrico1.wav","daktanks/dakrico2.wav","daktanks/dakrico3.wav","daktanks/dakrico4.wav","daktanks/dakrico5.wav","daktanks/dakrico6.wav"}
									end
									if Shell.DakIsPellet then
										sound.Play( BounceSounds[math.random(1,#BounceSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )
									else
										sound.Play( BounceSounds[math.random(1,#BounceSounds)], ContShellTrace.HitPos, 100, 100, 1 )
									end
								end
							end
							--if (90-math.abs(math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))))) > 45 then
								Shell.DakVelocity = Shell.DakVelocity*0.025
								Shell.Ang = ((ContShellTrace.HitPos-Start) - 1.25 * (Normal:Dot(ContShellTrace.HitPos-Start) * Normal)):Angle() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
								Shell.DakPenetration = 0
								Shell.DakDamage = 0
								Shell.LifeTime = 0.0
								Shell.Pos = ContShellTrace.HitPos
							--else
							--	local Energy = (math.abs(math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() ))))/90)
							--	Shell.DakVelocity = Shell.DakVelocity*Energy
							--	Shell.Ang = ((ContShellTrace.HitPos-Start) - 1* (Normal:Dot(ContShellTrace.HitPos-Start) * Normal)):Angle() + Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),math.Rand(-0.5,0.5))
							--	Shell.DakPenetration = Shell.DakPenetration*Energy
							--	Shell.DakDamage = Shell.DakDamage*Energy
							--	Shell.Filter[#Shell.Filter+1] = HitEnt
							--	Shell.LifeTime = 0.0
							--	local HitVel = HitEnt:GetVelocity() 
							--	if HitEnt:GetParent() then
							--		HitVel = HitEnt:GetParent():GetVelocity() 
							--	end
							--	if HitEnt:GetParent():GetParent() then
							--		HitVel = HitEnt:GetParent():GetParent():GetVelocity() 
							--	end
							--	Shell.Pos = ContShellTrace.HitPos
							--end		
							--soundhere bounce sound
						end
					end
					if HitEnt.DakHealth <= 0 and HitEnt.DakPooled==0 then
						Shell.Filter[#Shell.Filter+1] = HitEnt
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = HitEnt:GetModel()
						salvage:SetPos( HitEnt:GetPos())
						salvage:SetAngles( HitEnt:GetAngles())
						salvage:Spawn()
						Shell.Filter[#Shell.Filter+1] = salvage
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
						Pain:SetReportedPosition( ContShellTrace.HitPos )
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
						effectdata:SetOrigin(ContShellTrace.HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Shell.DakCaliber*0.25)
						util.Effect("dakteshellpenetrate", effectdata, true, true)
						util.Decal( "Impact.Concrete", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
						util.Decal( "Impact.Concrete", ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
						Shell.Filter[#Shell.Filter+1] = HitEnt
						if Shell.salvage then
							Shell.Filter[#Shell.Filter+1] = Shell.salvage
						end
						DTShellContinue(Start,End,Shell,Normal)
						--soundhere penetrate human sound
						if Shell.DakIsPellet then
							sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )
						else
							sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], ContShellTrace.HitPos, 100, 100, 1 )
						end
					else
						local effectdata = EffectData()
						if Shell.DakIsFlame == 1 then
							effectdata:SetOrigin(ContShellTrace.HitPos)
							effectdata:SetEntity(Shell.DakGun)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(1)
							util.Effect("dakteflameimpact", effectdata, true, true)
							local Targets = ents.FindInSphere( ContShellTrace.HitPos, 150 )
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
							sound.Play( "daktanks/flamerimpact.wav", ContShellTrace.HitPos, 100, 100, 1 )
						else
							effectdata:SetOrigin(ContShellTrace.HitPos)
							effectdata:SetEntity(Shell.DakGun)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(Shell.DakCaliber*0.25)
							util.Effect("dakteshellimpact", effectdata, true, true)
							util.Decal( "Impact.Concrete", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
							local ExpSounds = {}
							if Shell.DakCaliber < 20 then
								ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
							else
								ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
							end

							if Shell.DakIsPellet then
								sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )	
							else
								sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 100, 1 )	
							end
						end
						Shell.RemoveNow = 1
						if Shell.DakExplosive then
							Shell.ExplodeNow = true
						end
						Shell.LifeTime = 0
						Shell.DakVelocity = 0
						Shell.DakDamage = 0
					end
				end
			end
			if HitEnt:IsWorld() or Shell.ExplodeNow==true then
				if Shell.DakExplosive then
					local effectdata = EffectData()
					effectdata:SetOrigin(ContShellTrace.HitPos)
					effectdata:SetEntity(Shell.DakGun)
					effectdata:SetAttachment(1)
					effectdata:SetMagnitude(.5)
					effectdata:SetScale(Shell.DakBlastRadius)
					effectdata:SetNormal( Normal )
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
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 100, 1 )	
					end
					if Shell.DakShellType == "HESH" then
						DTShockwave(ContShellTrace.HitPos+(Normal*2),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					else
						DTShockwave(ContShellTrace.HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
						DTExplosion(ContShellTrace.HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					end
				else
					local effectdata = EffectData()
					if Shell.DakIsFlame == 1 then
						effectdata:SetOrigin(ContShellTrace.HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(1)
						util.Effect("dakteflameimpact", effectdata, true, true)
						local Targets = ents.FindInSphere( ContShellTrace.HitPos, 150 )
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
						sound.Play( "daktanks/flamerimpact.wav", ContShellTrace.HitPos, 100, 100, 1 )
					else
						effectdata:SetOrigin(ContShellTrace.HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						if Shell.DakDamage == 0 then
							effectdata:SetScale(0.5)
						else
							effectdata:SetScale(Shell.DakCaliber*0.25)
						end
						util.Effect("dakteshellimpact", effectdata, true, true)
						util.Decal( "Impact.Concrete", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
						local ExpSounds = {}
						if Shell.DakCaliber < 20 then
							ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
						else
							ExpSounds = {"daktanks/dakexp1.wav","daktanks/dakexp2.wav","daktanks/dakexp3.wav","daktanks/dakexp4.wav"}
						end

						if Shell.DakIsPellet then
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )	
						else
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 100, 1 )	
						end
					end
				end
				Shell.RemoveNow = 1
				if Shell.DakExplosive then
					Shell.ExplodeNow = true
				end
				Shell.LifeTime = 0
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
			trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
			trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
		local ExpTrace = util.TraceHull( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), HitEnt)
			if ExpTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
			end
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0)) then
				if (CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
							if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
								ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)*0.001,0,ExpTrace.Entity.DakArmor*2)
							else	
								ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor),0,ExpTrace.Entity.DakArmor*2)
							end
						end
					else
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)*0.001,0,ExpTrace.Entity.DakArmor*2)
						else
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor),0,ExpTrace.Entity.DakArmor*2)
						end
					end
					local EffArmor = (ExpTrace.Entity.DakArmor/math.abs(ExpTrace.HitNormal:Dot(Direction)))
					if ExpTrace.Entity.IsComposite == 1 then
						EffArmor = DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*9.2
					end
					if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
						util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
						ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						Filter[#Filter+1] = ExpTrace.Entity
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = ExpTrace.Entity:GetModel()
						salvage:SetPos( ExpTrace.Entity:GetPos())
						salvage:SetAngles( ExpTrace.Entity:GetAngles())
						salvage:Spawn()
						Filter[#Filter+1] = salvage
						ExpTrace.Entity:Remove()
					end
				end
				if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity.Base == "base_nextbot") then
					if(ExpTrace.Entity:GetParent():IsValid()) then
						if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
							ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*0.35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
						end
					end
					if not(ExpTrace.Entity:GetParent():IsValid()) then
						ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*0.35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
					end
				end	
			end
			if ExpTrace.Entity:IsValid() then
				if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity.Base == "base_nextbot" then
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
		end
	end
end

function DTAPHE(Pos,Damage,Radius,Caliber,Pen,Owner,Shell,HitEnt)
	local traces = math.Round(Caliber/2)
	local Filter = {HitEnt}
	for i=1, traces do
		local Direction = (Shell.Ang + Angle(math.Rand(-Caliber*0.75,Caliber*0.75),math.Rand(-Caliber*0.75,Caliber*0.75),math.Rand(-Caliber*0.75,Caliber*0.75))):Forward()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*Radius*10
			trace.filter = Filter
			trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
			trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
		local ExpTrace = util.TraceHull( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), HitEnt)
			if ExpTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
			end
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0)) then
				if (CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
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
								if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
									ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
								end
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
							if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
								ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)*0.001,0,ExpTrace.Entity.DakArmor*2)
							else
								ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor),0,ExpTrace.Entity.DakArmor*2)
							end
						end
					else
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)*0.001,0,ExpTrace.Entity.DakArmor*2)
						else
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor),0,ExpTrace.Entity.DakArmor*2)
						end
					end
					local EffArmor = (ExpTrace.Entity.DakArmor/math.abs(ExpTrace.HitNormal:Dot(Direction)))
					if ExpTrace.Entity.IsComposite == 1 then
						EffArmor = DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*9.2
					end
					if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
						util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
						ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						Filter[#Filter+1] = ExpTrace.Entity
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = ExpTrace.Entity:GetModel()
						salvage:SetPos( ExpTrace.Entity:GetPos())
						salvage:SetAngles( ExpTrace.Entity:GetAngles())
						salvage:Spawn()
						Filter[#Filter+1] = salvage
						ExpTrace.Entity:Remove()
					end
				end
				if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity.Base == "base_nextbot") then
					if(ExpTrace.Entity:GetParent():IsValid()) then
						if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
							ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*0.35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
						end
					end
					if not(ExpTrace.Entity:GetParent():IsValid()) then
						ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*0.35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
					end
				end	
			end
			if ExpTrace.Entity:IsValid() then
				if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity.Base == "base_nextbot" then
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
		end
	end
end

function ContEXP(Filter,IgnoreEnt,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
	local traces = math.Round(Caliber/2)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*Radius*10
		trace.filter = Filter
		trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
		trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
	local ExpTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), IgnoreEnt)
		if ExpTrace.Entity.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
		end
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0)) then
			if (CheckClip(ExpTrace.Entity,ExpTrace.HitPos)) or (ExpTrace.Entity:GetPhysicsObject():GetMass()<=1 or (ExpTrace.Entity.DakIsTread==1) and not(ExpTrace.Entity:IsVehicle()) and not(ExpTrace.Entity.IsDakTekFutureTech==1)) then
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
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				Filter[#Filter+1] = IgnoreEnt
				ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction,Shell)
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
							if not(ExpTrace.Entity.DakArmor == 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25) then
								ExpTrace.Entity.DakArmor = 7.8125*(ExpTrace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - ExpTrace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if not(ExpTrace.Entity.SPPOwner==nil) and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)*0.001,0,ExpTrace.Entity.DakArmor*2)
						else
							ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor),0,ExpTrace.Entity.DakArmor*2)
						end
					end
				else
					if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor)*0.001,0,ExpTrace.Entity.DakArmor*2)
					else
						ExpTrace.Entity.DakHealth = ExpTrace.Entity.DakHealth- math.Clamp((Damage/traces)*(Pen/ExpTrace.Entity.DakArmor),0,ExpTrace.Entity.DakArmor*2)
					end
				end
				local EffArmor = (ExpTrace.Entity.DakArmor/math.abs(ExpTrace.HitNormal:Dot(Direction)))
				if ExpTrace.Entity.IsComposite == 1 then
					EffArmor = DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*9.2
				end
				if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
					util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
					Filter[#Filter+1] = IgnoreEnt
					ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
				end
				if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
					Filter[#Filter+1] = ExpTrace.Entity
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = ExpTrace.Entity:GetModel()
					salvage:SetPos( ExpTrace.Entity:GetPos())
					salvage:SetAngles( ExpTrace.Entity:GetAngles())
					salvage:Spawn()
					Filter[#Filter+1] = salvage
					ExpTrace.Entity:Remove()
				end
			end
			if (ExpTrace.Entity:IsValid()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity:IsPlayer()) then
				if(ExpTrace.Entity:GetParent():IsValid()) then
					if(ExpTrace.Entity:GetParent():GetParent():IsValid()) then
						ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*0.35*ExpTrace.Entity:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
					end
				end
				if not(ExpTrace.Entity:GetParent():IsValid()) then
					ExpTrace.Entity:GetPhysicsObject():ApplyForceCenter( (ExpTrace.HitPos-Pos):GetNormalized()*(Damage/traces)*0.35*ExpTrace.Entity:GetPhysicsObject():GetMass()*(1-(ExpTrace.HitPos:Distance(Pos)/1000))  )
				end
			end	
		end
		if ExpTrace.Entity:IsValid() then
			if ExpTrace.Entity:IsPlayer() or ExpTrace.Entity:IsNPC() or ExpTrace.Entity.Base == "base_nextbot" then
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
				if Targets[i].DakArmor == nil or Targets[i].DakBurnStacks == nil then
					DakTekTankEditionSetupNewEnt(Targets[i])
				end
				if hook.Run("DakTankDamageCheck", Targets[i], Owner, Shell.DakGun) ~= false then
				else
					table.insert(Shell.IgnoreList,Targets[i])
				end
				if Targets[i].DakHealth == nil then
					DakTekTankEditionSetupNewEnt(Targets[i])
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
				trace.endpos = Pos + (Targets[i]:NearestPoint( Pos )-Pos)*Radius
				trace.filter = Shell.IgnoreList
				trace.mins = Vector(-0.1,-0.1,-0.1)
				trace.maxs = Vector(0.1,0.1,0.1)
				local ExpTrace = util.TraceHull( trace )
				if ExpTrace.Entity == Targets[i] and (not(CheckClip(Targets[i],ExpTrace.HitPos))) then
					if not(string.Explode("_",Targets[i]:GetClass(),false)[2] == "wire") and not(Targets[i]:IsVehicle()) and not(Targets[i]:GetClass() == "dak_salvage") and not(Targets[i]:GetClass() == "dak_tesalvage") and Targets[i].DakIsTread==nil and not(Targets[i]:GetClass() == "dak_turretcontrol") then
						if (not(ExpTrace.Entity:IsPlayer())) and (not(ExpTrace.Entity:IsNPC())) and (not(ExpTrace.Entity.Base == "base_nextbot")) then
							if ExpTrace.Entity:GetPhysicsObject():GetMass()>1 then
								if ExpTrace.Entity.DakArmor == nil or ExpTrace.Entity.DakBurnStacks == nil then
									DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
								end
								table.insert(Shell.DakDamageList,ExpTrace.Entity)
							end
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
								ExpPain:SetDamagePosition( ExpTrace.Entity:WorldSpaceCenter() )
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
						Shell.DakDamageList[i]:GetParent():GetParent():GetPhysicsObject():ApplyForceCenter( (Shell.DakDamageList[i]:GetPos()-Pos):GetNormalized()*(Damage/table.Count(Shell.DakDamageList))*Shell.DakDamageList[i]:GetParent():GetParent():GetPhysicsObject():GetMass()*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/1000)) )
						end
					end
					if not(Shell.DakDamageList[i]:GetParent():IsValid()) then
						Shell.DakDamageList[i]:GetPhysicsObject():ApplyForceCenter( (Shell.DakDamageList[i]:GetPos()-Pos):GetNormalized()*(Damage/table.Count(Shell.DakDamageList))*Shell.DakDamageList[i]:GetPhysicsObject():GetMass()*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/1000))  )
					end
				end
			end
			local HPPerc = 0
			if not(Shell.DakDamageList[i].SPPOwner==nil) then
				if Shell.DakDamageList[i].SPPOwner:IsWorld() then
					if Shell.DakDamageList[i].DakIsTread==nil then
						if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then
							if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
								Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))*0.001,0,Shell.DakDamageList[i].DakArmor*2)
							else
								Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius)),0,Shell.DakDamageList[i].DakArmor*2)
							end
						else
							if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
								Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*0.001,0,Shell.DakDamageList[i].DakArmor*2)
							else
								Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  ),0,Shell.DakDamageList[i].DakArmor*2)
							end
						end
					end
					Shell.DakDamageList[i].DakLastDamagePos = Pos
					if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
						table.insert(Shell.RemoveList,Shell.DakDamageList[i])
					end
				else
					if Shell.DakDamageList[i].SPPOwner:HasGodMode()==false and not(Shell.DakDamageList[i].SPPOwner:IsWorld()) then	
						if Shell.DakDamageList[i].DakIsTread==nil then
							if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then 
								if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
									Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))*0.001,0,Shell.DakDamageList[i].DakArmor*2)
								else
									Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius)),0,Shell.DakDamageList[i].DakArmor*2)
								end
							else
								if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
									Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*0.001,0,Shell.DakDamageList[i].DakArmor*2)
								else
									Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  ),0,Shell.DakDamageList[i].DakArmor*2)
								end
							end
						end
						Shell.DakDamageList[i].DakLastDamagePos = Pos
						if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
							table.insert(Shell.RemoveList,Shell.DakDamageList[i])
						end
					end
				end
			else
				if Shell.DakDamageList[i].DakIsTread==nil then
					if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then 
						if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
							Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))*0.001,0,Shell.DakDamageList[i].DakArmor*2)
						else
							Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius)),0,Shell.DakDamageList[i].DakArmor*2)
						end
					else
						if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
							Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  )*0.001,0,Shell.DakDamageList[i].DakArmor*2)
						else
							Shell.DakDamageList[i].DakHealth = Shell.DakDamageList[i].DakHealth - math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/Shell.DakDamageList[i].DakArmor)  ),0,Shell.DakDamageList[i].DakArmor*2)
						end
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
			Shell.Filter[#Shell.Filter+1] = salvage
			Shell.RemoveList[i]:Remove()
		end
	end
end

function DTSpall(Pos,Armor,HitEnt,Caliber,Pen,Owner,Shell,Dir)
	local SpallVolume = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)
	local SpallMass = (SpallVolume*0.0078125) * 0.1
	local SpallPen = Armor * 0.1
	local SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)*0.001
	local traces = 10

	if Shell.DakShellType == "HESH" then
		SpallMass = (SpallVolume*0.0078125) * 0.05
		SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)*0.005
		SpallPen = Caliber * 0.1
		traces = 20 * math.Clamp((Pen/Armor),1,3)
	end
	if Shell.DakShellType == "HEAT" then
		SpallMass = (SpallVolume*0.0078125) * 0.05
		SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)*0.005
		SpallPen = Armor * 0.2
		traces = 20
	end

	local Filter = table.Copy( Shell.Filter )
	for i=1, traces do
		local Ang = 45*(Armor/Pen)
		if Shell.DakShellType == "HESH" then
			Ang = 30 * math.Clamp((Pen/Armor),1,3)
		end
		local Direction = (Dir + Angle(math.Rand(-Ang,Ang),math.Rand(-Ang,Ang),math.Rand(-Ang,Ang))):Forward()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-Caliber*0.002,-Caliber*0.002,-Caliber*0.002)
			trace.maxs = Vector(Caliber*0.002,Caliber*0.002,Caliber*0.002)
		local SpallTrace = util.TraceLine( trace )
		if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner, Shell.DakGun) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
			if SpallTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(SpallTrace.Entity)
			end
			if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity.Base == "base_nextbot") and (SpallTrace.Entity.DakHealth and not(SpallTrace.Entity.DakHealth <= 0)) then
				if (CheckClip(SpallTrace.Entity,SpallTrace.HitPos)) or (SpallTrace.Entity:GetPhysicsObject():GetMass()<=1 or (SpallTrace.Entity.DakIsTread==1) and not(SpallTrace.Entity:IsVehicle()) and not(SpallTrace.Entity.IsDakTekFutureTech==1)) then
					if SpallTrace.Entity.DakArmor == nil or SpallTrace.Entity.DakBurnStacks == nil then
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
					Filter[#Filter+1] = HitEnt
					ContSpall(Filter,SpallTrace.Entity,Pos,SpallDamage,SpallPen,Owner,Direction,Shell)
				else
					if SpallTrace.Entity.DakArmor == nil or SpallTrace.Entity.DakBurnStacks == nil then
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
							if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
								SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)*0.001
							else
								SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
							end		
						end
					else
						if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
							SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)*0.001
						else
							SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(SpallDamage*(SpallPen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
						end
					end
					if SpallTrace.Entity.DakHealth <= 0 and SpallTrace.Entity.DakPooled==0 then
						Filter[#Filter+1] = SpallTrace.Entity
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = SpallTrace.Entity:GetModel()
						salvage:SetPos( SpallTrace.Entity:GetPos())
						salvage:SetAngles( SpallTrace.Entity:GetAngles())
						salvage:Spawn()
						Filter[#Filter+1] = salvage
						SpallTrace.Entity:Remove()
					end
					local EffArmor = (SpallTrace.Entity.DakArmor/math.abs(SpallTrace.HitNormal:Dot(Direction)))
					if SpallTrace.Entity.IsComposite == 1 then
						EffArmor = DTCompositesTrace( SpallTrace.Entity, SpallTrace.HitPos, SpallTrace.Normal, Filter  )*9.2
					end
					if EffArmor < SpallPen and SpallTrace.Entity.IsDakTekFutureTech == nil then
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
						util.Decal( "Impact.Concrete", SpallTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})
						Filter[#Filter+1] = HitEnt
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
		trace.start = Pos - Direction*250
		trace.endpos = Pos + Direction*1000
		trace.filter = Filter
		trace.mins = Vector(-Shell.DakCaliber*0.002,-Shell.DakCaliber*0.002,-Shell.DakCaliber*0.002)
		trace.maxs = Vector(Shell.DakCaliber*0.002,Shell.DakCaliber*0.002,Shell.DakCaliber*0.002)
	local SpallTrace = util.TraceHull( trace )
	if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner, Shell.DakGun) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
		if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity.Base == "base_nextbot") and not(SpallTrace.Entity.DakHealth == 0)then
			if (CheckClip(SpallTrace.Entity,SpallTrace.HitPos)) or (SpallTrace.Entity:GetPhysicsObject():GetMass()<=1 or (SpallTrace.Entity.DakIsTread==1) and not(SpallTrace.Entity:IsVehicle()) and not(SpallTrace.Entity.IsDakTekFutureTech==1)) then
				if SpallTrace.Entity.DakArmor == nil or SpallTrace.Entity.DakBurnStacks == nil then
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
				Filter[#Filter+1] = IgnoreEnt
				ContSpall(Filter,SpallTrace.Entity,Pos,Damage,Pen,Owner,Direction,Shell)
			else
				if SpallTrace.Entity.DakArmor == nil or SpallTrace.Entity.DakBurnStacks == nil then
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
						if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
							SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)*0.001
						else
							SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
						end
					end
				else
					if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
						SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)*0.001
					else
						SpallTrace.Entity.DakHealth = SpallTrace.Entity.DakHealth- math.Clamp(Damage*(Pen/SpallTrace.Entity.DakArmor),0,SpallTrace.Entity.DakArmor*2)
					end
				end
				if SpallTrace.Entity.DakHealth <= 0 and SpallTrace.Entity.DakPooled==0 then
					Filter[#Filter+1] = SpallTrace.Entity
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = SpallTrace.Entity:GetModel()
					salvage:SetPos( SpallTrace.Entity:GetPos())
					salvage:SetAngles( SpallTrace.Entity:GetAngles())
					salvage:Spawn()
					Filter[#Filter+1] = salvage
					SpallTrace.Entity:Remove()
				end
				local EffArmor = (SpallTrace.Entity.DakArmor/math.abs(SpallTrace.HitNormal:Dot(Direction)))
				if SpallTrace.Entity.IsComposite == 1 then
					EffArmor = DTCompositesTrace( SpallTrace.Entity, SpallTrace.HitPos, SpallTrace.Normal, Filter  )*9.2
				end
				if EffArmor < Pen and SpallTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
					util.Decal( "Impact.Concrete", SpallTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})
					Filter[#Filter+1] = IgnoreEnt
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
	if Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
		local HEATPen = Pen
		local HEATDamage = Damage
		local Filter = {HitEnt}
		local Direction = Shell.Ang:Forward()
		local trace = {}
			trace.start = Pos - Direction*250
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-Caliber*0.02,-Caliber*0.02,-Caliber*0.02)
			trace.maxs = Vector(Caliber*0.02,Caliber*0.02,Caliber*0.02)
		local HEATTrace = util.TraceHull( trace )
		if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
			if HEATTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
			end
			if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") and (HEATTrace.Entity.DakHealth and not(HEATTrace.Entity.DakHealth <= 0)) then
				if (CheckClip(HEATTrace.Entity,HEATTrace.HitPos)) or (HEATTrace.Entity:GetPhysicsObject():GetMass()<=1 or (HEATTrace.Entity.DakIsTread==1) and not(HEATTrace.Entity:IsVehicle()) and not(HEATTrace.Entity.IsDakTekFutureTech==1)) then
					if HEATTrace.Entity.DakArmor == nil or HEATTrace.Entity.DakBurnStacks == nil then
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
					ContHEAT(Filter,HEATTrace.Entity,Pos,HEATDamage,HEATPen,Owner,Direction,Shell,false)
				else
					if HEATTrace.Entity.DakArmor == nil or HEATTrace.Entity.DakBurnStacks == nil then
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

					StandoffCalibers = ((Pos:Distance(HEATTrace.HitPos) * 25.4)/Shell.DakCaliber) + 1.65
					if StandoffCalibers > 7.5 then
						HEATPen = HEATPen * 1.4 / (StandoffCalibers/7.5)
					else
						HEATPen = HEATPen * math.sqrt(math.sqrt(StandoffCalibers))/1.185
					end

					if not(HEATTrace.Entity.SPPOwner==nil) and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
						if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then	
							if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
								HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)*0.001
							else
								HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
							end	
						end
					else
						if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
							HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)*0.001
						else
							HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
						end
					end
					if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
						Filter[#Filter+1] = HEATTrace.Entity
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = HEATTrace.Entity:GetModel()
						salvage:SetPos( HEATTrace.Entity:GetPos())
						salvage:SetAngles( HEATTrace.Entity:GetAngles())
						salvage:Spawn()
						Filter[#Filter+1] = salvage
						HEATTrace.Entity:Remove()
					end
					local EffArmor = (HEATTrace.Entity.DakArmor/math.abs(HEATTrace.HitNormal:Dot(Direction)))
					if HEATTrace.Entity.IsComposite == 1 then
						EffArmor = DTCompositesTrace( HEATTrace.Entity, HEATTrace.HitPos, HEATTrace.Normal, Shell.Filter )*18.4
					end
					if EffArmor < math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen) and HEATTrace.Entity.IsDakTekFutureTech == nil then
						Filter[#Filter+1] = HEATTrace.Entity
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Concrete", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun})
						util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), HEATTrace.HitPos-(Direction*5), {Shell.DakGun})
						DTSpall(Pos,EffArmor,HEATTrace.Entity,Shell.DakCaliber*0.25,math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen),Owner,Shell, Direction:Angle())
						ContHEAT(Filter,HEATTrace.Entity,HEATTrace.HitPos,HEATDamage*(1-EffArmor/math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)),math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)-EffArmor,Owner,Direction:Angle(),Shell,true)
					else
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Glass", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun,HitEnt})
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
				effectdata:SetOrigin(Pos + Direction*(Pen/2.54))
				effectdata:SetScale(Shell.DakCaliber*0.00393701)
				util.Effect("dakteballistictracer", effectdata)
			end
		end
	end
	if Shell.DakShellType == "HEAT" then
		local HEATPen = Pen
		local HEATDamage = Damage/5
		local Filter = {HitEnt}
		local Direction = Shell.Ang:Forward()
		local trace = {}
			trace.start = Pos - Direction*250
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-Caliber*0.02,-Caliber*0.02,-Caliber*0.02)
			trace.maxs = Vector(Caliber*0.02,Caliber*0.02,Caliber*0.02)
		local HEATTrace = util.TraceHull( trace )
		if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
			if HEATTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
			end
			if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") and (HEATTrace.Entity.DakHealth and not(HEATTrace.Entity.DakHealth <= 0)) then
				if (CheckClip(HEATTrace.Entity,HEATTrace.HitPos)) or (HEATTrace.Entity:GetPhysicsObject():GetMass()<=1 or (HEATTrace.Entity.DakIsTread==1) and not(HEATTrace.Entity:IsVehicle()) and not(HEATTrace.Entity.IsDakTekFutureTech==1)) then
					if HEATTrace.Entity.DakArmor == nil or HEATTrace.Entity.DakBurnStacks == nil then
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
					ContHEAT(Filter,HEATTrace.Entity,Pos,HEATDamage,HEATPen,Owner,Direction,Shell,false)
				else
					if HEATTrace.Entity.DakArmor == nil or HEATTrace.Entity.DakBurnStacks == nil then
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

					StandoffCalibers = ((Pos:Distance(HEATTrace.HitPos) * 25.4)/Shell.DakCaliber)
					if StandoffCalibers > 7.5 then
						HEATPen = HEATPen * 1.4 / (StandoffCalibers/7.5)
					else
						HEATPen = HEATPen * math.sqrt(math.sqrt(StandoffCalibers))/1.185
					end

					if not(HEATTrace.Entity.SPPOwner==nil) and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
						if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then	
							if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
								HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)*0.001
							else
								HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
							end	
						end
					else
						if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
							HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)*0.001
						else
							HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
						end	
					end
					if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
						Filter[#Filter+1] = HEATTrace.Entity
						local salvage = ents.Create( "dak_tesalvage" )
						Shell.salvage = salvage
						salvage.DakModel = HEATTrace.Entity:GetModel()
						salvage:SetPos( HEATTrace.Entity:GetPos())
						salvage:SetAngles( HEATTrace.Entity:GetAngles())
						salvage:Spawn()
						Filter[#Filter+1] = salvage
						HEATTrace.Entity:Remove()
					end
					local EffArmor = (HEATTrace.Entity.DakArmor/math.abs(HEATTrace.HitNormal:Dot(Direction)))
					if HEATTrace.Entity.IsComposite == 1 then
						EffArmor = DTCompositesTrace( HEATTrace.Entity, HEATTrace.HitPos, HEATTrace.Normal, Shell.Filter )*18.4
					end
					if EffArmor < math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen) and HEATTrace.Entity.IsDakTekFutureTech == nil then
						Filter[#Filter+1] = HEATTrace.Entity
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Concrete", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun})
						util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), HEATTrace.HitPos-(Direction*5), {Shell.DakGun})
						DTSpall(Pos,EffArmor,HEATTrace.Entity,Shell.DakCaliber*0.25,math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen),Owner,Shell, Direction:Angle())
						ContHEAT(Filter,HEATTrace.Entity,HEATTrace.HitPos,HEATDamage*(1-EffArmor/math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)),math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)-EffArmor,Owner,Direction:Angle(),Shell,true)
					else
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Glass", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun,HitEnt})
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
				effectdata:SetOrigin(Pos + Direction*(Pen/2.54))
				effectdata:SetScale(Shell.DakCaliber*0.00393701)
				util.Effect("dakteballistictracer", effectdata)
			end
		end
	end
end

function ContHEAT(Filter,IgnoreEnt,Pos,Damage,Pen,Owner,Direction,Shell,Triggered)
	if isangle(Direction) then
		Direction = Direction:Forward()
	end
	local trace = {}
		trace.start = Pos - Direction*250
		trace.endpos = Pos + Direction*1000
		trace.filter = Filter
		trace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
		trace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
	local HEATTrace = util.TraceHull( trace )

	if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
		if HEATTrace.Entity.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
		end
		if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") and (HEATTrace.Entity.DakHealth and not(HEATTrace.Entity.DakHealth <= 0)) then
			if (CheckClip(HEATTrace.Entity,HEATTrace.HitPos)) or (HEATTrace.Entity:GetPhysicsObject():GetMass()<=1 or (HEATTrace.Entity.DakIsTread==1) and not(HEATTrace.Entity:IsVehicle()) and not(HEATTrace.Entity.IsDakTekFutureTech==1)) then
				if HEATTrace.Entity.DakArmor == nil or HEATTrace.Entity.DakBurnStacks == nil then
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
				Filter[#Filter+1] = IgnoreEnt
				ContHEAT(Filter,HEATTrace.Entity,Pos,Damage,Pen,Owner,Direction,Shell,false)
			else
				if HEATTrace.Entity.DakArmor == nil or HEATTrace.Entity.DakBurnStacks == nil then
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

				if not(Triggered) then
					local StandoffCalibers = 0
					if Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
						StandoffCalibers = ((Pos:Distance(HEATTrace.HitPos) * 25.4)/Shell.DakCaliber) + 1.65
					end
					if Shell.DakShellType == "HEAT" then
						StandoffCalibers = ((Pos:Distance(HEATTrace.HitPos) * 25.4)/Shell.DakCaliber)
					end
					if StandoffCalibers > 7.5 then
						Pen = Pen * 1.4 / (StandoffCalibers/7.5)
					else
						Pen = Pen * math.sqrt(math.sqrt(StandoffCalibers))/1.185
					end
				end
				if not(HEATTrace.Entity.SPPOwner==nil) and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
					if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then
						if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
							HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(Damage*((Pen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)*0.001
						else
							HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(Damage*((Pen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
						end	
					end
				else
					if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
						HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(Damage*((Pen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)*0.001
					else
						HEATTrace.Entity.DakHealth = HEATTrace.Entity.DakHealth- math.Clamp(Damage*((Pen-HeatPenLoss)/HEATTrace.Entity.DakArmor),0,HEATTrace.Entity.DakArmor*2)
					end	
				end
				if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
					Filter[#Filter+1] = HEATTrace.Entity
					local salvage = ents.Create( "dak_tesalvage" )
					Shell.salvage = salvage
					salvage.DakModel = HEATTrace.Entity:GetModel()
					salvage:SetPos( HEATTrace.Entity:GetPos())
					salvage:SetAngles( HEATTrace.Entity:GetAngles())
					salvage:Spawn()
					Filter[#Filter+1] = salvage
					HEATTrace.Entity:Remove()
				end
				local EffArmor = (HEATTrace.Entity.DakArmor/math.abs(HEATTrace.HitNormal:Dot(Direction)))
				if HEATTrace.Entity.IsComposite == 1 then
					EffArmor = DTCompositesTrace( HEATTrace.Entity, HEATTrace.HitPos, HEATTrace.Normal, Shell.Filter )*18.4
				end
				if EffArmor < (Pen-HeatPenLoss) and HEATTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun})
					util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), HEATTrace.HitPos-(Direction*5), {Shell.DakGun})
					Filter[#Filter+1] = IgnoreEnt
					Filter[#Filter+1] = HEATTrace.Entity
					DTSpall(Pos,EffArmor,HEATTrace.Entity,Shell.DakCaliber*0.25,math.Clamp(Pen-HeatPenLoss,Pen*0.05,Pen),Owner,Shell, Direction:Angle())
					ContHEAT(Filter,HEATTrace.Entity,HEATTrace.HitPos,Damage*(1-EffArmor/(Pen-HeatPenLoss)),(Pen-HeatPenLoss)-EffArmor,Owner,Direction,Shell,true)
				else
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Glass", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun, HitEnt})
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
			effectdata:SetScale(Shell.DakCaliber*0.393701)
			util.Effect("dakteballistictracer", effectdata)
		else
			local effectdata = EffectData()
			effectdata:SetStart(Pos)
			effectdata:SetOrigin(Pos + Direction*(Pen/2.54))
			effectdata:SetScale(Shell.DakCaliber*0.393701)
			util.Effect("dakteballistictracer", effectdata)
		end	
	end
end
