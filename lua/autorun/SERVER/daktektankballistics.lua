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

function DTGetArmor(Ent, ShellType, Caliber)
	if Ent.EntityMods ~= nil and Ent.EntityMods.ArmorType ~= nil and Ent.EntityMods.ArmorType == "CHA" then
		if Ent.DakArmor < 175 then
			return math.Clamp((-11.6506+1.072239*Ent.DakArmor+0.0004415663*Ent.DakArmor^2-0.000002624166*Ent.DakArmor^3),Ent.DakArmor*0.5,Ent.DakArmor)
		else
			return Ent.DakArmor
		end
	end
	if Ent.EntityMods ~= nil and Ent.EntityMods.ArmorType ~= nil and Ent.EntityMods.ArmorType == "HHA" then
		if ShellType == "HE" or ShellType == "HESH" or ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
			return Ent.DakArmor
		end
		return Ent.DakArmor*(9.7707 * Caliber^0.06111 * (Ent.DakArmor/Caliber)^0.2821 * 450^-0.4363) --hardness value of 450
	end
	if Ent.DakArmor == nil then Ent.DakArmor = 1000 end
	return Ent.DakArmor
end

function DTDealDamage(Ent,Damage,Dealer,entbased)
	Ent.DakHealth = Ent.DakHealth - Damage
	if entbased==true then
		if Dealer.LastDamagedBy == nil or Dealer.LastDamagedBy == NULL then
			Ent.LastDamagedBy = game.GetWorld()
		else
			Ent.LastDamagedBy = Dealer.LastDamagedBy
		end
		
	else
		if Dealer.DakOwner == nil or Dealer.DakOwner == NULL then
			Ent.LastDamagedBy = game.GetWorld()
		else
			Ent.LastDamagedBy = Dealer.DakOwner
		end
		
	end
end

function DTArmorSanityCheck(Ent)
	local SA = Ent:GetPhysicsObject():GetSurfaceArea()
	if Ent.EntityMods == nil or Ent.EntityMods.Hardness == nil then Ent.ArmorMod = 7.8125 else Ent.ArmorMod = 7.8125 * Ent.EntityMods.Hardness end
	
	--Ent.DakArmor > (7.8125*(Ent:GetPhysicsObject():GetMass()/4.6311781)*(288/SA))*0.5

	if not(Ent.DakArmor == 7.8125*(Ent:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Ent.DakBurnStacks*0.25) then
		Ent.DakArmor = 7.8125*(Ent:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - Ent.DakBurnStacks*0.25
	end
	if Ent.DakArmor <= 0 then Ent.DakArmor = 0.001 end 
end

function DTSimpleTrace(Start, End, Caliber, Filter, Gun)
	local trace = {}
		trace.start = Start
		trace.endpos = End 
		trace.filter = Filter
		trace.mins = Vector(-Caliber*0.02,-Caliber*0.02,-Caliber*0.02)
		trace.maxs = Vector(Caliber*0.02,Caliber*0.02,Caliber*0.02)
		trace.ignoreworld = true
	local SimpleTrace = util.TraceLine( trace )
	local Stop = 1
	local Ent = SimpleTrace.Entity
	local Pos = SimpleTrace.HitPos
	if Ent:IsValid() then
		if CheckClip(Ent,Pos) or (Ent:GetPhysicsObject():IsValid() and Ent:GetPhysicsObject():GetMass()<=1) or Ent:IsVehicle() or Ent:GetClass() == "dak_crew" or Ent:GetClass() == "dak_teammo" or Ent.Controller ~= Gun.Controller then
			Stop = 0
		end
	end
	return Ent, Pos, Stop
end

function DTSimpleRecurseTrace(Start, End, Caliber, Filter, Gun)
	local Ent, Pos, Stop = DTSimpleTrace(Start, End, Caliber, Filter, Gun)
	local Recurse = 1
	local NewFilter = Filter
	NewFilter[#NewFilter+1] = Ent
	local newEnt = Ent
	local LastPos = Pos
	if Stop == 1 then
		local Distance = Start:Distance(LastPos)
		return Distance
	end
	while Stop == 0 and Recurse<25 do
		local newEnt, LastPos, Stop = DTSimpleTrace(Start, End, Caliber, NewFilter, Gun)
		NewFilter[#NewFilter+1] = newEnt
		Recurse = Recurse + 1
		if Stop == 1 then
			local Distance = Start:Distance(LastPos)
			return Distance
		end
	end
end

function DTGetEffArmor(Start, End, ShellType, Caliber, Filter)
	if tonumber(Caliber) == nil then return 0, NULL, Vector(0,0,0), 0, 0, 0 end
	local trace = {}
		trace.start = Start
		trace.endpos = End 
		trace.filter = Filter
		trace.ignoreworld = true
	local ShellSimTrace = util.TraceLine( trace )

	local HitEnt = ShellSimTrace.Entity
	local EffArmor = 0
	local Shatter = 0
	local Failed = 0
	local HitGun = 0
	local HitGear = 0
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
						DTArmorSanityCheck(HitEnt)
					end
				end
			end

			if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_teautogun" or HitEnt:GetClass() == "dak_temachinegun" then
				HitGun = 1
			end
			if HitEnt:GetClass() == "dak_tegearbox" then
				HitGear = 1
			end
			local TDRatio = HitEnt.DakArmor/Caliber
			if ShellType == "APFSDS" then
				TDRatio = HitEnt.DakArmor/(Caliber*2.5)
			end
			if ShellType == "APDS" then
				TDRatio = HitEnt.DakArmor/(Caliber*1.75)
			end
			if HitEnt.IsComposite == 1 then
				EffArmor = DTCompositesTrace( HitEnt, ShellSimTrace.HitPos, ShellSimTrace.Normal, Filter )
				if HitEnt.EntityMods.CompKEMult == nil then HitEnt.EntityMods.CompKEMult = 9.2 end 
				if HitEnt.EntityMods.CompCEMult == nil then HitEnt.EntityMods.CompCEMult = 18.4 end 
				if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
					EffArmor = EffArmor*HitEnt.EntityMods.CompCEMult
				else
					EffArmor = EffArmor*HitEnt.EntityMods.CompKEMult
				end
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
					if (EffArmor/3)/Caliber >= 0.8 and not(ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" or ShellType == "HESH") then
						Shatter = 1
					end
				end
				if HitAng >= 70 and EffArmor>=Caliber*0.85 and (ShellType == "APFSDS" or ShellType == "APDS") then Shatter = 1 end
				if HitAng >= 80 and EffArmor>=Caliber*0.85 and (ShellType == "APFSDS" or ShellType == "APDS") then Failed = 1 Shatter = 1 end
			else
				if TDRatio >= 0.8 and not(ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" or ShellType == "HESH") then
					Shatter = 1
				end
				if HitAng >= 70 and HitEnt.DakArmor>=Caliber*0.85 and (ShellType == "APFSDS" or ShellType == "APDS") then Shatter = 1 end
				if HitAng >= 80 and HitEnt.DakArmor>=Caliber*0.85 and (ShellType == "APFSDS" or ShellType == "APDS") then Failed = 1 Shatter = 1 end
				if ShellType == "HESH" then
					EffArmor = DTGetArmor(HitEnt, ShellType, Caliber)
				end
				if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
					EffArmor = (DTGetArmor(HitEnt, ShellType, Caliber)/math.abs(ShellSimTrace.HitNormal:Dot(ShellSimTrace.Normal)) )
				end
				if ShellType == "AP" or ShellType == "APHE" or ShellType == "HE" or ShellType == "HVAP" or ShellType == "SM" then
					if HitAng > 24 then
						local aVal = 2.251132 - 0.1955696*math.max( HitAng, 24 ) + 0.009955601*math.pow( math.max( HitAng, 24 ), 2 ) - 0.0001919089*math.pow( math.max( HitAng, 24 ), 3 ) + 0.000001397442*math.pow( math.max( HitAng, 20 ), 4 )
						local bVal = 0.04411227 - 0.003575789*math.max( HitAng, 24 ) + 0.0001886652*math.pow( math.max( HitAng, 24 ), 2 ) - 0.000001151088*math.pow( math.max( HitAng, 24 ), 3 ) + 1.053822e-9*math.pow( math.max( HitAng, 20 ), 4 )
						EffArmor = math.Clamp(DTGetArmor(HitEnt, ShellType, Caliber) * (aVal * math.pow( TDRatio, bVal )),DTGetArmor(HitEnt, ShellType, Caliber),10000000000)
					else
						EffArmor = (DTGetArmor(HitEnt, ShellType, Caliber)/math.abs(ShellSimTrace.HitNormal:Dot(ShellSimTrace.Normal)) )
					end
				end
				if ShellType == "APDS" then
					EffArmor = DTGetArmor(HitEnt, ShellType, Caliber) * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
				end
				if ShellType == "APFSDS" then
					EffArmor = DTGetArmor(HitEnt, ShellType, Caliber) * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
				end
				if HitAng >= 70 and EffArmor >= 5 and (ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" or ShellType == "HESH") then Shatter = 1 end
				if HitAng >= 80 and EffArmor >= 5 and (ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" or ShellType == "HESH") then Failed = 1 Shatter = 1 end
			end
		end
	end
	if ShellSimTrace.Hit then
		EndPos = ShellSimTrace.HitPos
	else
		EndPos = End
	end
	return EffArmor, HitEnt, EndPos, Shatter, Failed, HitGun, HitGear
end

function DTGetArmorRecurse(Start, End, ShellType, Caliber, Filter)
	if tonumber(Caliber) == nil then return 0, NULL, 0, 0, 0 end
	local Armor, Ent, FirstPenPos, HeatShattered, HeatFailed, HitGun, HitGear = DTGetEffArmor(Start, End, ShellType, Caliber, Filter)
	local Recurse = 1
	local NewFilter = Filter
	NewFilter[#NewFilter+1] = Ent
	local newEnt = Ent
	local newArmor = 0
	local Go = 1
	local LastPenPos = FirstPenPos
	local Shatters = HeatShattered
	local Fails = HeatFailed
	local Rico = 0
	
	while Go == 1 and Recurse<25 do
		local newArmor, newEnt, LastPenPos, Shattered, Failed, newHitGun, newHitGear = DTGetEffArmor(Start, End, ShellType, Caliber, NewFilter)
		if newHitGun == 1 then HitGun = 1 end
		if newHitGear == 1 then HitGear = 1 end		
		if Armor == 0 or newArmor == 0 then
			if Armor == 0 then
				HeatShattered = Shattered
				HeatFailed = Failed
				FirstPenPos = LastPenPos
			end
		end
		Shatters = Shatters + Shattered
		Fails = Fails + Failed
		if newEnt:IsValid() then
			if newEnt:GetClass() == "dak_crew" or newEnt:GetClass() == "dak_teammo" or newEnt:GetClass() == "dak_teautoloadingmodule" or newEnt:GetClass() == "dak_tefuel" or newEnt:IsWorld() then
				if newEnt:GetClass() == "dak_teammo" then
					if newEnt.DakAmmo > 0 then Go = 0 end
				else
					Go = 0
				end
			end
		else
			Go = 0
		end
		if Go == 0 then
			if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
				Armor = Armor + (FirstPenPos:Distance(LastPenPos)*2.54)
			end
			if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" or ShellType == "HESH" then
				if HeatFailed == 1 then Rico = 1 end
				Shatters = HeatShattered
			end
			if ShellType == "APDS" or ShellType == "APFSDS" then
				if Fails > 0 then Rico = 1 end
			end
			return Armor, newEnt, Shatters, Rico, HitGun, HitGear
		end
		NewFilter[#NewFilter+1] = newEnt
		Armor = Armor + newArmor
		Recurse = Recurse + 1
	end
end

function DTGetArmorRecurseNoStop(Start, End, ShellType, Caliber, Filter)
	if tonumber(Caliber) == nil then return 0, NULL, 0, 0, 0, 0 end
	local Armor, Ent, FirstPenPos, HeatShattered, HeatFailed, HitGun, HitGear = DTGetEffArmor(Start, End, ShellType, Caliber, Filter)
	local Recurse = 1
	local NewFilter = Filter
	NewFilter[#NewFilter+1] = Ent
	local newEnt = Ent
	local newArmor = 0
	local Go = 1
	local LastPenPos = FirstPenPos
	local Shatters = HeatShattered
	local Fails = HeatFailed
	local Rico = 0
	local HitCrit = 0
	
	while Go == 1 and Recurse<25 do
		local newArmor, newEnt, LastPenPos, Shattered, Failed, newHitGun, newHitGear = DTGetEffArmor(Start, End, ShellType, Caliber, NewFilter)
		if newHitGun == 1 then HitGun = 1 end
		if newHitGear == 1 then HitGear = 1 end		
		if Armor == 0 or newArmor == 0 then
			if Armor == 0 then
				HeatShattered = Shattered
				HeatFailed = Failed
				FirstPenPos = LastPenPos
			end
		end
		Shatters = Shatters + Shattered
		Fails = Fails + Failed
		if newEnt:IsValid() then
			if newEnt:GetClass() == "dak_crew" or newEnt:GetClass() == "dak_teammo" or newEnt:GetClass() == "dak_teautoloadingmodule" or newEnt:GetClass() == "dak_tefuel" or newEnt:IsWorld() then
				if newEnt:GetClass() == "dak_teammo" then
					if newEnt.DakAmmo > 0 then HitCrit = 1 end
				else
					HitCrit = 1
				end
			end
		else
			Go = 0
		end
		if Go == 0 then
			if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" then
				Armor = Armor + (FirstPenPos:Distance(LastPenPos)*2.54)
			end
			if ShellType == "HEAT" or ShellType == "HEATFS" or ShellType == "ATGM" or ShellType == "HESH" then
				if HeatFailed == 1 then Rico = 1 end
				Shatters = HeatShattered
			end
			if ShellType == "APDS" or ShellType == "APFSDS" then
				if Fails > 0 then Rico = 1 end
			end
			return Armor, Ent, Shatters, Rico, HitGun, HitGear, HitCrit
		end
		NewFilter[#NewFilter+1] = newEnt
		Armor = Armor + newArmor
		Recurse = Recurse + 1
	end
end

function DTGetStandoffMult(Start, End, Caliber, Filter, ShellType)
	if tonumber(Caliber) == nil then return 0 end
	local Recurse = 1
	local NewFilter = Filter
	local Go = 1
	local FirstArmor = nil
	local SecondArmor = nil
	while Go == 1 and Recurse<25 do
		local trace = {}
			trace.start = Start
			trace.endpos = End 
			trace.filter = Filter
		local ShellSimTrace = util.TraceLine( trace )
		if IsValid(ShellSimTrace.Entity) then
			if ShellSimTrace.Entity:GetPhysicsObject() then
				if ShellSimTrace.Entity:GetPhysicsObject():GetMass()>1 and not((CheckClip(ShellSimTrace.Entity,ShellSimTrace.HitPos))) then
					if FirstArmor==nil then 
						FirstArmor = ShellSimTrace.HitPos 
					else 
						SecondArmor = ShellSimTrace.HitPos 
						Go = 0
					end
				end
			end
			NewFilter[#NewFilter+1] = ShellSimTrace.Entity
		else
			return 1
		end
		Recurse = Recurse + 1
	end
	if FirstArmor~=nil and SecondArmor~=nil then
		local Dist = FirstArmor:Distance(SecondArmor)
		local StandoffCalibers = ((Dist * 25.4)/Caliber) + 1.65
		if ShellType == "HEAT"  then
			StandoffCalibers = ((Dist * 25.4)/Caliber)
		end
		if StandoffCalibers > 7.5 then
			return (1.4 / (StandoffCalibers/7.5))
		else
			return (math.sqrt(math.sqrt(StandoffCalibers))/1.185)
		end
	else
		return 1
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
						if IsValid(checkinternaltrace.Entity) and Pos:Distance(checkinternaltrace.HitPos)<Pos:Distance(H1) and (checkinternaltrace.Entity:GetPhysicsObject():IsValid() and checkinternaltrace.Entity:GetPhysicsObject():GetMass()>1) then
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
	if Shell.Hits~=nil and Shell.Hits>50 then 
		Shell.RemoveNow = 1
		print("ERROR, RECURSE")
	return end
	Shell.Hits = 1
	if Shell.FinishedBouncing == 1 and Shell.LifeTime == 0.1 then --figure out if this really is at lifetime 0.1 or 0 after trace fix
		Start = End
		Shell.FinishedBouncing = 0
	else
		Start = End-(Shell.DakVelocity*0.1)
	end
	if Shell.LifeTime == 0.0 then
		Start = End
	end
	End = End+(Shell.DakVelocity*0.1)
	local newtrace = {}
		newtrace.start = Start
		newtrace.endpos = End
		newtrace.filter = Shell.Filter
		newtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
		newtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
	local HitCheckShellTrace = util.TraceHull( newtrace )
	local HitCheckShellLineTrace = util.TraceLine( newtrace )
	Normal = HitCheckShellLineTrace.HitNormal
	HitEnt = HitCheckShellTrace.Entity
	local HitPos = HitCheckShellTrace.HitPos
	if hook.Run("DakTankDamageCheck", HitEnt, Shell.DakGun.DakOwner, Shell.DakGun) ~= false then
		if HitEnt.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(HitEnt)
		end
		if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") and (HitEnt.DakHealth and not(HitEnt.DakHealth <= 0) or (HitEnt.DakName=="Damaged Component")) then
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
							DTArmorSanityCheck(HitEnt)
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
							DTArmorSanityCheck(HitEnt)
						end
					end
				end
				
				HitEnt.DakLastDamagePos = HitPos

				local Vel = Shell.DakVelocity:GetNormalized()
				local EffArmor = 0

				local CurrentPen = Shell.DakPenetration-Shell.DakPenetration*(Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)

				local HitAng = math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() )))

				
				local TDRatio = 0
				local PenRatio = 0
				local CompArmor
				if HitEnt.IsComposite == 1 then
					CompArmor = DTCompositesTrace( HitEnt, HitPos, Shell.DakVelocity:GetNormalized(), Shell.Filter )
					if HitEnt.EntityMods.CompKEMult == nil then HitEnt.EntityMods.CompKEMult = 9.2 end 
					if HitEnt.EntityMods.CompCEMult == nil then HitEnt.EntityMods.CompCEMult = 18.4 end 
					if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH" then
						CompArmor = CompArmor*HitEnt.EntityMods.CompCEMult
						if Shell.IsTandem == true then
							if HitEnt.IsERA == 1 then
								CompArmor = 0
							end
						end
					else
						CompArmor = CompArmor*HitEnt.EntityMods.CompKEMult
					end
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
					PenRatio = CurrentPen/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)
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
				if (Shell.DakVelocity:Distance( Vector(0,0,0) ))*0.0254 > ShatterVel and not(Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then
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
				if HitAng >= 70 and HitEnt.DakArmor>=Shell.DakCaliber*0.85 and (Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS") then Shattered = 1 end
				if HitAng >= 80 and HitEnt.DakArmor>=Shell.DakCaliber*0.85 and (Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS") then Shattered = 1 Failed = 1 end
				if HitEnt.IsComposite == 1 then
					if HitEnt.EntityMods.CompKEMult == nil then HitEnt.EntityMods.CompKEMult = 9.2 end 
					if HitEnt.EntityMods.CompCEMult == nil then HitEnt.EntityMods.CompCEMult = 18.4 end 
					EffArmor = CompArmor
					if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
						EffArmor = EffArmor
					end
				else
					if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
						EffArmor = (DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)/math.abs(Normal:Dot(Vel:GetNormalized())) )
					end
					if Shell.DakShellType == "AP" or Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "HVAP" or Shell.DakShellType == "SM" or Shell.DakShellType == "HESH" then
						if HitAng > 24 then
							local aVal = 2.251132 - 0.1955696*math.max( HitAng, 24 ) + 0.009955601*math.pow( math.max( HitAng, 24 ), 2 ) - 0.0001919089*math.pow( math.max( HitAng, 24 ), 3 ) + 0.000001397442*math.pow( math.max( HitAng, 20 ), 4 )
							local bVal = 0.04411227 - 0.003575789*math.max( HitAng, 24 ) + 0.0001886652*math.pow( math.max( HitAng, 24 ), 2 ) - 0.000001151088*math.pow( math.max( HitAng, 24 ), 3 ) + 1.053822e-9*math.pow( math.max( HitAng, 20 ), 4 )
							EffArmor = math.Clamp(DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) * (aVal * math.pow( TDRatio, bVal )),DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber),10000000000)
						else
							EffArmor = (DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)/math.abs(Normal:Dot(Vel:GetNormalized())) )
						end
					end
					if Shell.DakShellType == "APDS" then
						EffArmor = DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
					end
					if Shell.DakShellType == "APFSDS" then
						EffArmor = DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
					end
				end
				if HitAng >= 70 and EffArmor>=5 and (Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then Shattered = 1 end
				if HitAng >= 80 and EffArmor>=5 and (Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then Shattered = 1 Failed = 1 end
				if EffArmor < (CurrentPen) and HitEnt.IsDakTekFutureTech == nil and Failed == 0 then
					if HitEnt.SPPOwner and HitEnt.SPPOwner:IsPlayer() and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then		
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
							else
								DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end
						end
					else
						if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
							DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
						else
							DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					end
					--print("Shell Hit Function First Impact Damage")
					--print(math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2))
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") and not(Shell.DakIsFlame==1) then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*(((Shell.DakVelocity:Distance( Vector(0,0,0) ))*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								end
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
						end
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shattered == 1 then
						DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber*2,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.DakVelocity:GetNormalized())
					else
						DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.DakVelocity:GetNormalized())
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
					if HitEnt:GetClass()=="dak_crew" then
						util.Decal( "Blood", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*500), Shell.DakGun)
						util.Decal( "Blood", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*500), HitEnt)
					end
					Shell.DakVelocity = Shell.DakVelocity - Shell.DakVelocity * (EffArmor/Shell.DakPenetration)
					Shell.Pos = HitPos
					Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
					Shell.DakPenetration = Shell.DakPenetration-EffArmor
					if Shattered == 1 then
						Shell.DakDamage = Shell.DakDamage*0.5
						Shell.DakPenetration = Shell.DakPenetration*0.5
						Shell.DakVelocity = Shell.DakVelocity*0.5
					end
					--soundhere penetrate sound
					if Shell.DakIsPellet then
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], HitPos, 100, 150, 0.25 )
					else
						sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], HitPos, 100, 100, 1 )
					end
					if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							Shell.LifeTime = 0
							DTHEAT(HitPos,HitEnt,Shell.DakCaliber,Shell.DakPenetration,Shell.DakDamage,Shell.DakGun.DakOwner,Shell)
							Shell.HeatPen = true
						end
						Shell.Pos = HitPos
						Shell.LifeTime = 0
						Shell.DakVelocity = Vector(0,0,0)
						Shell.DakDamage = 0
						Shell.ExplodeNow = true
					else
						DTShellContinue(Start,End,Shell,Normal)
						Shell.LifeTime = 0
					end
				else
					if Shell.DakShellType == "HESH" then
						if HitEnt.IsComposite == 1 then
							if Shell.DakCaliber*1.25 > CompArmor and HitAng < 80 then
								Shell.Filter[#Shell.Filter+1] = HitEnt
								Shell.HeatPen = true
								DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakCaliber*1.25),Shell.DakGun.DakOwner,Shell,((HitPos-(Normal*2))-HitPos):Angle():Forward())
								Shell.Pos = HitPos
								Shell.LifeTime = 0
								Shell.DakVelocity = Vector(0,0,0)
								Shell.DakDamage = 0
								Shell.ExplodeNow = true
							end	
						else
							if Shell.DakCaliber*1.25 > DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) and HitAng < 80 then
								Shell.Filter[#Shell.Filter+1] = HitEnt
								Shell.HeatPen = true
								DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakCaliber*1.25),Shell.DakGun.DakOwner,Shell,((HitPos-(Normal*2))-HitPos):Angle():Forward())
								Shell.Pos = HitPos
								Shell.LifeTime = 0
								Shell.DakVelocity = Vector(0,0,0)
								Shell.DakDamage = 0
								Shell.ExplodeNow = true
							end
						end
					end
					if Shell.DakShellType == "HE" then
						if HitEnt.IsComposite == 1 then
							if Shell.DakFragPen*10 > CompArmor and HitAng < 70 then
								Shell.Filter[#Shell.Filter+1] = HitEnt
								Shell.HeatPen = true
								DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakFragPen*10),Shell.DakGun.DakOwner,Shell,((HitPos-(Normal*2))-HitPos):Angle():Forward())
								Shell.Pos = HitPos
								Shell.LifeTime = 0
								Shell.DakVelocity = Vector(0,0,0)
								Shell.DakDamage = 0
								Shell.ExplodeNow = true
							end	
						else
							if Shell.DakFragPen*10 > DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) and HitAng < 70 then
								Shell.Filter[#Shell.Filter+1] = HitEnt
								Shell.HeatPen = true
								DTSpall(HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakFragPen*10),Shell.DakGun.DakOwner,Shell,((HitPos-(Normal*2))-HitPos):Angle():Forward())
								Shell.Pos = HitPos
								Shell.LifeTime = 0
								Shell.DakVelocity = Vector(0,0,0)
								Shell.DakDamage = 0
								Shell.ExplodeNow = true
							end
						end
					end
					if HitEnt.SPPOwner and HitEnt.SPPOwner:IsPlayer() and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt.Base ~= "base_nextbot" then			
						if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								DTDealDamage(HitEnt,Shell.DakDamage*0.25*0.001,Shell.DakGun)
							else
								DTDealDamage(HitEnt,Shell.DakDamage*0.25,Shell.DakGun)
							end
						end
					else
						if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
							DTDealDamage(HitEnt,Shell.DakDamage*0.25*0.001,Shell.DakGun)
						else
							DTDealDamage(HitEnt,Shell.DakDamage*0.25,Shell.DakGun)
						end
					end
					--print("Shell Hit Function First Impact Damage Fail Pen")
					--print(Shell.DakDamage*0.25)
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
					if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") and not(Shell.DakIsFlame==1) then
						if(HitEnt:GetParent():IsValid()) then
							if(HitEnt:GetParent():GetParent():IsValid()) then
								if HitEnt.Controller then
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*(((Shell.DakVelocity:Distance( Vector(0,0,0) ))*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								else
									local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
									HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
								end							
							end
						end
						if not(HitEnt:GetParent():IsValid()) then
							local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
							HitEnt:GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(HitPos):GetNormalized() )
						end
					end
					
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
						sound.Play( "daktanks/flamerimpact.mp3", HitPos, 100, 100, 1 )
					else
						Shell.Filter[#Shell.Filter+1] = HitEnt
						if Shell.DakDamage >= 0 then
							util.Decal( "Impact.Glass", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
							if HitEnt:GetClass()=="dak_crew" then
							util.Decal( "Blood", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*500), Shell.DakGun)
						end
							local Bounce = 0
							if (90-HitAng) <= 45 then
								local RNG = math.random(0,100)
								if (90-HitAng) <= 45 and (90-HitAng) > 30 then
									if RNG <= 25 then Bounce = 1 end
								end
								if (90-HitAng) <= 30 and (90-HitAng) > 20 then
									if RNG <= 50 then Bounce = 1 end
								end
								if (90-HitAng) <= 20 and (90-HitAng) > 10 then
									if RNG <= 75 then Bounce = 1 end
								end
								if (90-HitAng) <= 10 then
									Bounce = 1
								end
							else
								Bounce = 0
							end
							Bounce = 0
							if Shell.DakShellType == "HESH" or Shell.DakShellType == "ATGM" or Shell.DakIsFlame == 1 then Bounce = 0 end
							if Bounce == 1 then
								effectdata:SetOrigin(HitPos)
								effectdata:SetEntity(Shell.DakGun)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(Shell.DakCaliber*0.25)
								util.Effect("dakteshellbounce", effectdata, true, true)
								local BounceSounds = {}
								if Shell.DakCaliber < 20 then
									BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
								else
									BounceSounds = {"daktanks/dakrico1.mp3","daktanks/dakrico2.mp3","daktanks/dakrico3.mp3","daktanks/dakrico4.mp3","daktanks/dakrico5.mp3","daktanks/dakrico6.mp3"}
								end
								if Shell.DakIsPellet then
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], HitPos, 100, 150, 0.25 )
								else
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], HitPos, 100, 100, 1 )
								end
								Shell.DakVelocity = 0.5*Shell.DakBaseVelocity*((Normal)+((HitPos-Start):GetNormalized()*1*(45/(90-HitAng)))):GetNormalized() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)):Forward()
								Shell.DakPenetration = Shell.DakPenetration*0.5
								Shell.DakDamage = Shell.DakDamage*0.5
								Shell.LifeTime = 0.0
								Shell.Pos = HitPos + (Normal*2*Shell.DakCaliber*0.02)
								Shell.ShellThinkTime = 0
								Shell.JustBounced = 1
								DTShellContinue(HitPos + (Normal*2*Shell.DakCaliber*0.02),Shell.DakVelocity:GetNormalized()*1000,Shell,Normal,true)
								Shell.FinishedBouncing = 1
							else
								Shell.Crushed = 1
								effectdata:SetOrigin(HitPos)
								effectdata:SetEntity(Shell.DakGun)
								effectdata:SetAttachment(1)
								effectdata:SetMagnitude(.5)
								effectdata:SetScale(Shell.DakCaliber*0.25)
								if Shell.IsFrag then
								else
									util.Effect("dakteshellimpact", effectdata, true, true)
								end
								local BounceSounds = {}
								if Shell.DakCaliber < 20 then
									BounceSounds = {"daktanks/dakrico1.mp3","daktanks/dakrico2.mp3","daktanks/dakrico3.mp3","daktanks/dakrico4.mp3","daktanks/dakrico5.mp3","daktanks/dakrico6.mp3"}
								else
									BounceSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
								end
								if Shell.DakIsPellet then
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], HitPos, 100, 150, 0.25 )
								else
									sound.Play( BounceSounds[math.random(1,#BounceSounds)], HitPos, 100, 100, 1 )
								end
								Shell.DakVelocity = Shell.DakBaseVelocity*0.025*((Normal)+((HitPos-Start):GetNormalized()*1*(45/(90-HitAng)))):GetNormalized() --+ Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
								Shell.DakPenetration = 0
								Shell.DakDamage = 0
								Shell.LifeTime = 0.0
								Shell.Pos = HitPos
								Shell.RemoveNow = 1
								if Shell.DakExplosive then
									Shell.Pos = HitPos
									Shell.LifeTime = 0
									Shell.DakVelocity = Vector(0,0,0)
									Shell.DakDamage = 0
									Shell.ExplodeNow = true
								end
							end
						end
					end
					--soundhere bounce sound
				end
				if HitEnt.DakHealth <= 0 and HitEnt.DakPooled==0 then
					if HitEnt:GetClass()=="dak_crew" then
						if HitEnt.DakHealth <= 0 then
							for blood=1, 15 do
								util.Decal( "Blood", HitEnt:GetPos(), HitEnt:GetPos()+(VectorRand()*500), HitEnt)
							end
						end
					end
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
				Shell.Pos = HitPos
				if HitEnt:GetClass() == "dak_bot" then
					HitEnt:SetHealth(HitEnt:Health() - Shell.DakDamage*500)
					if HitEnt:Health() <= 0 and HitEnt.revenge==0 then
						--local body = ents.Create( "prop_ragdoll" )
						body:SetPos( HitEnt:GetPos() )
						body:SetModel( HitEnt:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						if Shell.DakIsFlame == 1 then
							body:Ignite(10,1)
						end
						--HitEnt:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local checkhitboxtrace = {}
						checkhitboxtrace.start = Shell.Pos + ((Shell.DakVelocity:Distance( Vector(0,0,0) )) * Shell.DakVelocity:GetNormalized() * (Shell.LifeTime-0.1)) - (-physenv.GetGravity()*((Shell.LifeTime-0.1)^2)/2)
						checkhitboxtrace.endpos = Shell.Pos + ((Shell.DakVelocity:Distance( Vector(0,0,0) )) * Shell.DakVelocity:GetNormalized() * Shell.LifeTime) - (-physenv.GetGravity()*(Shell.LifeTime^2)/2)
						checkhitboxtrace.filter = Shell.Filter
						checkhitboxtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
						checkhitboxtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
					local HitboxTrace = util.TraceHull( checkhitboxtrace )
					local Pain = DamageInfo()
					Pain:SetDamageForce( Shell.DakVelocity:GetNormalized()*Shell.DakDamage*Shell.DakMass*(Shell.DakVelocity:Distance( Vector(0,0,0) )) )
					Pain:SetDamage( Shell.DakDamage*500 )
					if Shell.DakGun.DakOwner and Shell and Shell.DakGun then
						Pain:SetAttacker( Shell.DakGun.DakOwner )
						Pain:SetInflictor( Shell.DakGun )
					else
						Pain:SetAttacker( game.GetWorld() )
						Pain:SetInflictor( game.GetWorld() )
					end
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
					if HitEnt:GetClass()=="dak_crew" then
						util.Decal( "Blood", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*500), Shell.DakGun)
						util.Decal( "Blood", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*500), HitEnt)
					end
					Shell.Filter[#Shell.Filter+1] = HitEnt
					if Shell.salvage then
						Shell.Filter[#Shell.Filter+1] = Shell.salvage
					end
					DTShellContinue(Start,End,Shell,Normal)
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
						sound.Play( "daktanks/flamerimpact.mp3", HitPos, 100, 100, 1 )
					else
						effectdata:SetOrigin(HitPos)
						effectdata:SetEntity(Shell.DakGun)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)
						effectdata:SetScale(Shell.DakCaliber*0.25)
						if Shell.IsFrag then
						else
							util.Effect("dakteshellimpact", effectdata, true, true)
						end
						util.Decal( "Impact.Concrete", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
						if HitEnt:GetClass()=="dak_crew" then
							util.Decal( "Blood", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*500), Shell.DakGun)
						end
						local ExpSounds = {}
						if Shell.DakCaliber < 20 then
							ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
						else
							ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
						end

						if Shell.DakIsPellet then
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 150, 0.25 )	
						else
							sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 100, 1 )	
						end
					end
					Shell.RemoveNow = 1
					--if Shell.DakExplosive then
					--	Shell.ExplodeNow = true
					--end
					Shell.LifeTime = 0
					Shell.DakVelocity = Vector(0,0,0)
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
				if Shell.DakShellType == "SM" then
					util.Effect("daktescalingsmoke", effectdata, true, true)
				else
					util.Effect("daktescalingexplosion", effectdata, true, true)
				end

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
						ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
					end
					sound.Play( ExpSounds[math.random(1,#ExpSounds)], HitPos, 100, 100, 1 )	
				end
				if Shell.DakShellType == "HESH" then
					DTShockwave(HitPos+(Normal*2),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
				else
					DTShockwave(HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					--DTExplosion(HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
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
					sound.Play( "daktanks/flamerimpact.mp3", HitPos, 100, 100, 1 )
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
					if Shell.IsFrag then
					else
						util.Effect("dakteshellimpact", effectdata, true, true)
					end
					util.Decal( "Impact.Concrete", HitPos-((HitPos-Start):GetNormalized()*5), HitPos+((HitPos-Start):GetNormalized()*5), Shell.DakGun)
					local ExpSounds = {}
					if Shell.DakCaliber < 20 then
						ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
					else
						ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
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
			Shell.DakVelocity = Vector(0,0,0)
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
	Shell.Hits = Shell.Hits + 1
	if Shell.Hits>50 then 
		Shell.RemoveNow = 1
		print("ERROR, RECURSE")
	return end
	local Fuze = 25
	if Shell.DakShellType == "HE" or Shell.DakShellType == "SM" then
		Fuze = 5
	end
	local newtrace = {}
		if (Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "SM") and not(HitNonHitable) then
			newtrace.start = Shell.Pos
			newtrace.endpos = Shell.Pos + (Fuze * Shell.DakVelocity:GetNormalized())
		else
			newtrace.start = Start
			newtrace.endpos = End
		end
		newtrace.filter = Shell.Filter
		newtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
		newtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
	local ContShellTrace = util.TraceLine( newtrace )
	local ContCheckShellLineTrace = util.TraceLine( newtrace )
	Normal = ContCheckShellLineTrace.HitNormal
	if (Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "SM") and not(ContShellTrace.Hit) and not(HitNonHitable) then
		if Shell.DieTime == nil then
			Shell.DieTime = CurTime()
		end
		Shell.RemoveNow = 1
		local effectdata = EffectData()
		effectdata:SetOrigin(Shell.Pos + (Fuze * Shell.DakVelocity:GetNormalized()))
		effectdata:SetEntity(Shell.DakGun)
		effectdata:SetAttachment(1)
		effectdata:SetMagnitude(.5)
		if Shell.DakShellType == "APHE" then
			effectdata:SetScale(Shell.DakBlastRadius*0.25)
		else
			effectdata:SetScale(Shell.DakBlastRadius)
		end
		effectdata:SetNormal( Normal )
		if Shell.DakShellType == "SM" then
			util.Effect("daktescalingsmoke", effectdata, true, true)
		else
			util.Effect("daktescalingexplosion", effectdata, true, true)
		end
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
				ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
			end
			sound.Play( ExpSounds[math.random(1,#ExpSounds)], Shell.Pos + (Fuze * Shell.DakVelocity:GetNormalized()), 100, 100, 1 )	
		end
		if Shell.DakShellType == "APHE" then
			DTAPHE(Shell.Pos + (Fuze * Shell.DakVelocity:GetNormalized()),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
		else
			DTShockwave(Shell.Pos + (Fuze * Shell.DakVelocity:GetNormalized()),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
			--DTExplosion(Shell.Pos + (Fuze * Shell.DakVelocity:GetNormalized()),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
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
			if HitEnt:IsValid() and HitEnt:GetPhysicsObject():IsValid() and not(HitEnt:IsPlayer()) and not(HitEnt:IsNPC()) and not(HitEnt.Base == "base_nextbot") and (HitEnt.DakHealth and not(HitEnt.DakHealth <= 0) or (HitEnt.DakName=="Damaged Component")) then
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
								DTArmorSanityCheck(HitEnt)
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
								DTArmorSanityCheck(HitEnt)
							end
						end
					end
					
					HitEnt.DakLastDamagePos = ContShellTrace.HitPos

					local Vel = Shell.DakVelocity:GetNormalized()
					local EffArmor = 0

					local CurrentPen = Shell.DakPenetration-Shell.DakPenetration*(Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.LifeTime*(Shell.DakPenLossPerMeter/52.49)

					local HitAng = math.deg(math.acos(Normal:Dot( -Vel:GetNormalized() )))

					local TDRatio = 0
					local PenRatio = 0
					local CompArmor
					if HitEnt.IsComposite == 1 then
						CompArmor = DTCompositesTrace( HitEnt, ContShellTrace.HitPos, Shell.DakVelocity:GetNormalized(), Shell.Filter )
						if HitEnt.EntityMods.CompKEMult == nil then HitEnt.EntityMods.CompKEMult = 9.2 end 
						if HitEnt.EntityMods.CompCEMult == nil then HitEnt.EntityMods.CompCEMult = 18.4 end 
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH" then
							CompArmor = CompArmor*HitEnt.EntityMods.CompCEMult
							if Shell.IsTandem == true then
								if HitEnt.IsERA == 1 then
									CompArmor = 0
								end
							end
						else
							CompArmor = CompArmor*HitEnt.EntityMods.CompKEMult
						end
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
						PenRatio = CurrentPen/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)
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
					if (Shell.DakVelocity:Distance( Vector(0,0,0) ))*0.0254 > ShatterVel and not(Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then
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
					if HitNonHitable and HitAng >= 70 and HitEnt.DakArmor>=Shell.DakCaliber*0.85 and (Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS") then Shattered = 1 end
					if HitNonHitable and HitAng >= 80 and HitEnt.DakArmor>=Shell.DakCaliber*0.85 and (Shell.DakShellType == "APFSDS" or Shell.DakShellType == "APDS") then Shattered = 1 Failed = 1 end
					if HitEnt.IsComposite == 1 then
						if HitEnt.EntityMods.CompKEMult == nil then HitEnt.EntityMods.CompKEMult = 9.2 end 
						if HitEnt.EntityMods.CompCEMult == nil then HitEnt.EntityMods.CompCEMult = 18.4 end 
						EffArmor = CompArmor
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							EffArmor = EffArmor
						end
					else
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							EffArmor = (DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)/math.abs(Normal:Dot(Vel:GetNormalized())) )
						end
						if Shell.DakShellType == "AP" or Shell.DakShellType == "APHE" or Shell.DakShellType == "HE" or Shell.DakShellType == "HVAP" or Shell.DakShellType == "SM" or Shell.DakShellType == "HESH" then
							if HitAng > 24 then
								local aVal = 2.251132 - 0.1955696*math.max( HitAng, 24 ) + 0.009955601*math.pow( math.max( HitAng, 24 ), 2 ) - 0.0001919089*math.pow( math.max( HitAng, 24 ), 3 ) + 0.000001397442*math.pow( math.max( HitAng, 20 ), 4 )
								local bVal = 0.04411227 - 0.003575789*math.max( HitAng, 24 ) + 0.0001886652*math.pow( math.max( HitAng, 24 ), 2 ) - 0.000001151088*math.pow( math.max( HitAng, 24 ), 3 ) + 1.053822e-9*math.pow( math.max( HitAng, 20 ), 4 )
								EffArmor = math.Clamp(DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) * (aVal * math.pow( TDRatio, bVal )),DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber),10000000000)
							else
								EffArmor = (DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)/math.abs(Normal:Dot(Vel:GetNormalized())) )
							end
						end
						if Shell.DakShellType == "APDS" then
							EffArmor = DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
						end
						if Shell.DakShellType == "APFSDS" then
							EffArmor = DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) * math.pow( 2.71828, (math.pow( HitAng, 2.6 )*0.00003011) )
						end
					end
					if HitAng >= 70 and EffArmor>=5 and (Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then Shattered = 1 end
					if HitAng >= 80 and EffArmor>=5 and (Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" or Shell.DakShellType == "HESH") then Shattered = 1 Failed = 1 end
					if EffArmor < (CurrentPen) and HitEnt.IsDakTekFutureTech == nil and Failed == 0 then
						if HitEnt.SPPOwner and HitEnt.SPPOwner:IsPlayer() and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) then			
							if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
								if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
									DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
								else	
									DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
								end
							end
						else
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
							else
								DTDealDamage(HitEnt,math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end
						end
						--print("Shell Hit Function Secondary Impact Damage")
						--print(math.Clamp(Shell.DakDamage*((CurrentPen)/DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber)*2))
						if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") and not(Shell.DakIsFlame==1) then
							if(HitEnt:GetParent():IsValid()) then
								if(HitEnt:GetParent():GetParent():IsValid()) then
									if HitEnt.Controller then
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*(((Shell.DakVelocity:Distance( Vector(0,0,0) ))*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									else
										local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									end
								end
							end
							if not(HitEnt:GetParent():IsValid()) then
								local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
								HitEnt:GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
							end
						end
						Shell.Filter[#Shell.Filter+1] = HitEnt
						if Shattered == 1 then
							DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber*2,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.DakVelocity:GetNormalized())
						else
							DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(CurrentPen),Shell.DakGun.DakOwner,Shell,Shell.DakVelocity:GetNormalized())
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
						if HitEnt:GetClass()=="dak_crew" then
							util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), Shell.DakGun)
							util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), HitEnt)
						end
						Shell.DakVelocity = Shell.DakVelocity - (Shell.DakVelocity * (EffArmor/Shell.DakPenetration))
						Shell.Pos = ContShellTrace.HitPos

						Shell.DakDamage = Shell.DakDamage-Shell.DakDamage*(EffArmor/Shell.DakPenetration)
						Shell.DakPenetration = Shell.DakPenetration-EffArmor
						if Shattered == 1 then
							Shell.DakDamage = Shell.DakDamage*0.5
							Shell.DakPenetration = Shell.DakPenetration*0.5
							Shell.DakVelocity = Shell.DakVelocity*0.5
						end
						--soundhere penetrate sound
						if Shell.DakIsPellet then
							sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )
						else
							sound.Play( Shell.DakPenSounds[math.random(1,#Shell.DakPenSounds)], ContShellTrace.HitPos, 100, 100, 1 )
						end
						
						if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
							if Shell.DakShellType == "HEAT" or Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
								Shell.LifeTime = 0
								DTHEAT(ContShellTrace.HitPos,HitEnt,Shell.DakCaliber,Shell.DakPenetration,Shell.DakDamage,Shell.DakGun.DakOwner,Shell)
								Shell.HeatPen = true
							end
							Shell.Pos = ContShellTrace.HitPos
							Shell.LifeTime = 0
							Shell.DakVelocity = Vector(0,0,0)
							Shell.DakDamage = 0
							Shell.ExplodeNow = true
						else
							DTShellContinue(Start,End,Shell,Normal)
							Shell.LifeTime = 0
						end
					else
						if Shell.DakShellType == "HESH" then
							if HitEnt.IsComposite == 1 then
								if Shell.DakCaliber*1.25 > CompArmor and HitAng < 80 then
									Shell.Filter[#Shell.Filter+1] = HitEnt
									Shell.HeatPen = true
									DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakCaliber*1.25),Shell.DakGun.DakOwner,Shell,((ContShellTrace.HitPos-(Normal*2))-ContShellTrace.HitPos):Angle():Forward())
									Shell.Pos = HitPos
									Shell.LifeTime = 0
									Shell.DakVelocity = Vector(0,0,0)
									Shell.DakDamage = 0
									Shell.ExplodeNow = true
								end	
							else
								if Shell.DakCaliber*1.25 > DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) and HitAng < 80 then
									Shell.Filter[#Shell.Filter+1] = HitEnt
									Shell.HeatPen = true
									DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakCaliber*1.25),Shell.DakGun.DakOwner,Shell,((ContShellTrace.HitPos-(Normal*2))-ContShellTrace.HitPos):Angle():Forward())
									Shell.Pos = HitPos
									Shell.LifeTime = 0
									Shell.DakVelocity = Vector(0,0,0)
									Shell.DakDamage = 0
									Shell.ExplodeNow = true
								end
							end
						end
						if Shell.DakShellType == "HE" then
							if HitEnt.IsComposite == 1 then
								if Shell.DakFragPen*10 > CompArmor and HitAng < 70 then
									Shell.Filter[#Shell.Filter+1] = HitEnt
									Shell.HeatPen = true
									DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakFragPen*10),Shell.DakGun.DakOwner,Shell,((ContShellTrace.HitPos-(Normal*2))-ContShellTrace.HitPos):Angle():Forward())
									Shell.Pos = HitPos
									Shell.LifeTime = 0
									Shell.DakVelocity = Vector(0,0,0)
									Shell.DakDamage = 0
									Shell.ExplodeNow = true
								end	
							else
								if Shell.DakFragPen*10 > DTGetArmor(HitEnt, Shell.DakShellType, Shell.DakCaliber) and HitAng < 70 then
									Shell.Filter[#Shell.Filter+1] = HitEnt
									Shell.HeatPen = true
									DTSpall(ContShellTrace.HitPos,EffArmor,HitEnt,Shell.DakCaliber,(Shell.DakFragPen*10),Shell.DakGun.DakOwner,Shell,((ContShellTrace.HitPos-(Normal*2))-ContShellTrace.HitPos):Angle():Forward())
									Shell.Pos = HitPos
									Shell.LifeTime = 0
									Shell.DakVelocity = Vector(0,0,0)
									Shell.DakDamage = 0
									Shell.ExplodeNow = true
								end
							end
						end
						if HitEnt.SPPOwner and HitEnt.SPPOwner:IsPlayer() and not(HitEnt==nil) and not(HitEnt.SPPOwner:IsWorld()) and HitEnt.Base ~= "base_nextbot" then			
							if HitEnt.SPPOwner:HasGodMode()==false and HitEnt.DakIsTread == nil then
								if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
									DTDealDamage(HitEnt,Shell.DakDamage*0.25*0.01,Shell.DakGun)
								else	
									DTDealDamage(HitEnt,Shell.DakDamage*0.25,Shell.DakGun)
								end
							end
						else
							if HitEnt:GetClass() == "dak_tegun" or HitEnt:GetClass() == "dak_temachinegun" or HitEnt:GetClass() == "dak_teautogun" then
								DTDealDamage(HitEnt,Shell.DakDamage*0.25*0.01,Shell.DakGun)
							else
								DTDealDamage(HitEnt,Shell.DakDamage*0.25,Shell.DakGun)
							end
						end
						--print("Shell Hit Function Secondary Impact Damage Fail Pen")
						--print(Shell.DakDamage*0.25)
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
						if(HitEnt:IsValid() and HitEnt.Base ~= "base_nextbot" and HitEnt:GetClass()~="prop_ragdoll") and not(Shell.DakIsFlame==1) then
							if(HitEnt:GetParent():IsValid()) then
								if(HitEnt:GetParent():GetParent():IsValid()) then
									if HitEnt.Controller then
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( -Normal*(0.5*(((Shell.DakVelocity:Distance( Vector(0,0,0) ))*0.254)^2)*Shell.DakMass)/HitEnt.Controller.TotalMass*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									else
										local Div = Vector(HitEnt:GetParent():GetParent():OBBMaxs().x/75,HitEnt:GetParent():GetParent():OBBMaxs().y/75,HitEnt:GetParent():GetParent():OBBMaxs().z/75)
										HitEnt:GetParent():GetParent():GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetParent():GetParent():GetPhysicsObject():GetMass()*0.04,HitEnt:GetParent():GetParent():GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
									end
								end
							end
							if not(HitEnt:GetParent():IsValid()) then
								local Div = Vector(HitEnt:OBBMaxs().x/75,HitEnt:OBBMaxs().y/75,HitEnt:OBBMaxs().z/75)
								HitEnt:GetPhysicsObject():ApplyForceOffset( Div*((Shell.DakVelocity:Distance( Vector(0,0,0) ))*Shell.DakMass/50000)/HitEnt:GetPhysicsObject():GetMass()*0.04,HitEnt:GetPos()+HitEnt:WorldToLocal(ContShellTrace.HitPos):GetNormalized() )
							end
						end
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
							sound.Play( "daktanks/flamerimpact.mp3", ContShellTrace.HitPos, 100, 100, 1 )
						else
							Shell.Filter[#Shell.Filter+1] = HitEnt
							if Shell.DakDamage >= 0 then
								util.Decal( "Impact.Glass", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
								if HitEnt:GetClass()=="dak_crew" then
									util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), Shell.DakGun)
								end
								local Bounce = 0
								if (90-HitAng) <= 45 then
									local RNG = math.random(0,100)
									if (90-HitAng) <= 45 and (90-HitAng) > 30 then
										if RNG <= 25 then Bounce = 1 end
									end
									if (90-HitAng) <= 30 and (90-HitAng) > 20 then
										if RNG <= 50 then Bounce = 1 end
									end
									if (90-HitAng) <= 20 and (90-HitAng) > 10 then
										if RNG <= 75 then Bounce = 1 end
									end
									if (90-HitAng) <= 10 then
										Bounce = 1
									end
								else
									Bounce = 0
								end
								Bounce = 0
								if Shell.DakShellType == "HESH" or Shell.DakShellType == "ATGM" or Shell.DakIsFlame == 1 then Bounce = 0 end
								if Bounce == 1 then
									effectdata:SetOrigin(ContShellTrace.HitPos)
									effectdata:SetEntity(Shell.DakGun)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetScale(Shell.DakCaliber*0.25)
									util.Effect("dakteshellbounce", effectdata, true, true)
									local BounceSounds = {}
									if Shell.DakCaliber < 20 then
										BounceSounds = {"weapons/fx/rics/ric1.wav","weapons/fx/rics/ric2.wav","weapons/fx/rics/ric3.wav","weapons/fx/rics/ric4.wav","weapons/fx/rics/ric5.wav"}
									else
										BounceSounds = {"daktanks/dakrico1.mp3","daktanks/dakrico2.mp3","daktanks/dakrico3.mp3","daktanks/dakrico4.mp3","daktanks/dakrico5.mp3","daktanks/dakrico6.mp3"}
									end
									if Shell.DakIsPellet then
										sound.Play( BounceSounds[math.random(1,#BounceSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )
									else
										sound.Play( BounceSounds[math.random(1,#BounceSounds)], ContShellTrace.HitPos, 100, 100, 1 )
									end
									Shell.DakVelocity = Shell.DakBaseVelocity*0.5*((Normal)+((ContShellTrace.HitPos-Start):GetNormalized()*1*(45/(90-HitAng)))):GetNormalized() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)):Forward()
									Shell.DakPenetration = Shell.DakPenetration*0.5
									Shell.DakDamage = Shell.DakDamage*0.5
									Shell.LifeTime = 0.0
									Shell.Pos = ContShellTrace.HitPos + (Normal*2*Shell.DakCaliber*0.02)
									Shell.ShellThinkTime = 0
									Shell.JustBounced = 1
									DTShellContinue(ContShellTrace.HitPos + (Normal*2*Shell.DakCaliber*0.02),Shell.DakVelocity:GetNormalized()*1000,Shell,Normal,true)
									Shell.FinishedBouncing = 1
								else
									Shell.Crushed = 1
									effectdata:SetOrigin(ContShellTrace.HitPos)
									effectdata:SetEntity(Shell.DakGun)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetScale(Shell.DakCaliber*0.25)
									if Shell.IsFrag then
									else
										util.Effect("dakteshellimpact", effectdata, true, true)
									end
									local BounceSounds = {}
									if Shell.DakCaliber < 20 then
										BounceSounds = {"daktanks/dakrico1.mp3","daktanks/dakrico2.mp3","daktanks/dakrico3.mp3","daktanks/dakrico4.mp3","daktanks/dakrico5.mp3","daktanks/dakrico6.mp3"}
									else
										BounceSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
									end
									if Shell.DakIsPellet then
										sound.Play( BounceSounds[math.random(1,#BounceSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )
									else
										sound.Play( BounceSounds[math.random(1,#BounceSounds)], ContShellTrace.HitPos, 100, 100, 1 )
									end
									Shell.DakVelocity = Shell.DakBaseVelocity*0.025*((Normal)+((ContShellTrace.HitPos-Start):GetNormalized()*1*(45/(90-HitAng)))):GetNormalized() --+ Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))
									Shell.DakPenetration = 0
									Shell.DakDamage = 0
									Shell.LifeTime = 0.0
									Shell.Pos = ContShellTrace.HitPos
									Shell.RemoveNow = 1
									if Shell.DakExplosive then
										Shell.Pos = ContShellTrace.HitPos
										Shell.LifeTime = 0
										Shell.DakVelocity = Vector(0,0,0)
										Shell.DakDamage = 0
										Shell.ExplodeNow = true
									end
								end
							end
						end
					end
					if HitEnt.DakHealth <= 0 and HitEnt.DakPooled==0 then
						if HitEnt:GetClass()=="dak_crew" then
							if HitEnt.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", HitEnt:GetPos(), HitEnt:GetPos()+(VectorRand()*500), HitEnt)
								end
							end
						end
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
					Shell.Pos = HitPos
					if HitEnt:GetClass() == "dak_bot" then
						HitEnt:SetHealth(HitEnt:Health() - Shell.DakDamage*500)
						if HitEnt:Health() <= 0 and HitEnt.revenge==0 then
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( HitEnt:GetPos() )
							body:SetModel( HitEnt:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							if Shell.DakIsFlame == 1 then
								body:Ignite(10,1)
							end
							--HitEnt:Remove()
							local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
							body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
							timer.Simple( 5, function()
								body:Remove()
							end )
						end
					else
						local Pain = DamageInfo()
						Pain:SetDamageForce( Shell.DakVelocity:GetNormalized()*Shell.DakDamage*Shell.DakMass*(Shell.DakVelocity:Distance( Vector(0,0,0) )) )
						Pain:SetDamage( Shell.DakDamage*500 )
						if Shell.DakGun.DakOwner and Shell and Shell.DakGun then
							Pain:SetAttacker( Shell.DakGun.DakOwner )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
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
						if HitEnt:GetClass()=="dak_crew" then
							util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), Shell.DakGun)
							util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), HitEnt)
						end
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
							sound.Play( "daktanks/flamerimpact.mp3", ContShellTrace.HitPos, 100, 100, 1 )
						else
							effectdata:SetOrigin(ContShellTrace.HitPos)
							effectdata:SetEntity(Shell.DakGun)
							effectdata:SetAttachment(1)
							effectdata:SetMagnitude(.5)
							effectdata:SetScale(Shell.DakCaliber*0.25)
							if Shell.IsFrag then
							else
								util.Effect("dakteshellimpact", effectdata, true, true)
							end
							util.Decal( "Impact.Concrete", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
							if HitEnt:GetClass()=="dak_crew" then
								util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), Shell.DakGun)
							end
							local ExpSounds = {}
							if Shell.DakCaliber < 20 then
								ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
							else
								ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
							end

							if Shell.DakIsPellet then
								sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 150, 0.25 )	
							else
								sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 100, 1 )	
							end
						end
						Shell.RemoveNow = 1
						--if Shell.DakExplosive then
						--	Shell.ExplodeNow = true
						--end
						Shell.LifeTime = 0
						Shell.DakVelocity = Vector(0,0,0)
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
					if Shell.DakShellType == "SM" then
						util.Effect("daktescalingsmoke", effectdata, true, true)
					else
						util.Effect("daktescalingexplosion", effectdata, true, true)
					end

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
							ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
						end
						sound.Play( ExpSounds[math.random(1,#ExpSounds)], ContShellTrace.HitPos, 100, 100, 1 )	
					end
					if Shell.DakShellType == "HESH" then
						DTShockwave(ContShellTrace.HitPos+(Normal*2),Shell.DakSplashDamage,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
					else
						DTShockwave(ContShellTrace.HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
						--DTExplosion(ContShellTrace.HitPos+(Normal*2),Shell.DakSplashDamage*0.5,Shell.DakBlastRadius,Shell.DakCaliber,Shell.DakFragPen,Shell.DakGun.DakOwner,Shell)
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
						sound.Play( "daktanks/flamerimpact.mp3", ContShellTrace.HitPos, 100, 100, 1 )
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
						if Shell.IsFrag then
						else
							util.Effect("dakteshellimpact", effectdata, true, true)
						end
						util.Decal( "Impact.Concrete", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*5), Shell.DakGun)
						if HitEnt:GetClass()=="dak_crew" then
							util.Decal( "Blood", ContShellTrace.HitPos-((ContShellTrace.HitPos-Start):GetNormalized()*5), ContShellTrace.HitPos+((ContShellTrace.HitPos-Start):GetNormalized()*500), Shell.DakGun)
						end
						local ExpSounds = {}
						if Shell.DakCaliber < 20 then
							ExpSounds = {"physics/surfaces/sand_impact_bullet1.wav","physics/surfaces/sand_impact_bullet2.wav","physics/surfaces/sand_impact_bullet3.wav","physics/surfaces/sand_impact_bullet4.wav"}
						else
							ExpSounds = {"daktanks/dakexp1.mp3","daktanks/dakexp2.mp3","daktanks/dakexp3.mp3","daktanks/dakexp4.mp3"}
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
				Shell.DakVelocity = Vector(0,0,0)
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
		local ExpTraceLine = util.TraceLine( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), HitEnt)
			if ExpTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
			end
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0) or (ExpTrace.Entity.DakName=="Damaged Component")) then
				if ExpTrace.Entity:GetClass()=="dak_crew" then
					util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), HitEnt)
				end
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
								DTArmorSanityCheck(ExpTrace.Entity)
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
								DTArmorSanityCheck(ExpTrace.Entity)
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if ExpTrace.Entity.SPPOwner and ExpTrace.Entity.SPPOwner:IsPlayer() and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
							if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
							else	
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
							end
						end
					else
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
						else
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
						end
					end
					local EffArmor = (DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)/math.abs(ExpTraceLine.HitNormal:Dot(Direction)))
					if ExpTrace.Entity.IsComposite == 1 then
						if ExpTrace.Entity.EntityMods.CompKEMult == nil then ExpTrace.Entity.EntityMods.CompKEMult = 9.2 end 
						if ExpTrace.Entity.EntityMods.CompCEMult == nil then ExpTrace.Entity.EntityMods.CompCEMult = 18.4 end 
						EffArmor = (ExpTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*ExpTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*ExpTrace.Entity.EntityMods.CompKEMult
					end
					if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
						util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), HitEnt)
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), ExpTrace.Entity)
						end
						ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							if ExpTrace.Entity.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", ExpTrace.Entity:GetPos(), ExpTrace.Entity:GetPos()+(VectorRand()*500), ExpTrace.Entity)
								end
							end
						end
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
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( ExpTrace.Entity:GetPos() )
							body:SetModel( ExpTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							--ExpTrace.Entity:Remove()
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
						if Owner:IsPlayer() and Shell and Shell.DakGun then
							Pain:SetAttacker( Owner )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
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
		local Direction = (Angle(math.Rand(-Caliber*0.75,Caliber*0.75),math.Rand(-Caliber*0.75,Caliber*0.75),math.Rand(-Caliber*0.75,Caliber*0.75))):Forward() + Shell.DakVelocity:GetNormalized()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*Radius*10
			trace.filter = Filter
			trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
			trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
		local ExpTrace = util.TraceHull( trace )
		local ExpTraceLine = util.TraceLine( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), HitEnt)
			if ExpTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
			end
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0) or (ExpTrace.Entity.DakName=="Damaged Component")) then
				if ExpTrace.Entity:GetClass()=="dak_crew" then
					util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), HitEnt)
				end
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
								DTArmorSanityCheck(ExpTrace.Entity)
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
								DTArmorSanityCheck(ExpTrace.Entity)
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if ExpTrace.Entity.SPPOwner and ExpTrace.Entity.SPPOwner:IsPlayer() and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
							if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							else
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end
						end
					else
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						else
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					end
					local EffArmor = (DTGetArmor(ExpTrace.Entity, Shell.DakShellType, Shell.DakCaliber)/math.abs(ExpTraceLine.HitNormal:Dot(Direction)))
					if ExpTrace.Entity.IsComposite == 1 then
						if ExpTrace.Entity.EntityMods.CompKEMult == nil then ExpTrace.Entity.EntityMods.CompKEMult = 9.2 end 
						if ExpTrace.Entity.EntityMods.CompCEMult == nil then ExpTrace.Entity.EntityMods.CompCEMult = 18.4 end
						EffArmor = (ExpTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*ExpTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*ExpTrace.Entity.EntityMods.CompKEMult
					end
					if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
						util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), HitEnt)
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), ExpTrace.Entity)
						end
						ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							if ExpTrace.Entity.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", ExpTrace.Entity:GetPos(), ExpTrace.Entity:GetPos()+(VectorRand()*500), ExpTrace.Entity)
								end
							end
						end
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
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( ExpTrace.Entity:GetPos() )
							body:SetModel( ExpTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							--ExpTrace.Entity:Remove()
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
						if Owner:IsPlayer() and Shell and Shell.DakGun then
							Pain:SetAttacker( Owner )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
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
	local ExpTraceLine = util.TraceLine( trace )

	if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), IgnoreEnt)
		if ExpTrace.Entity.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
		end
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0) or (ExpTrace.Entity.DakName=="Damaged Component")) then
			if ExpTrace.Entity:GetClass()=="dak_crew" then
				util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), IgnoreEnt)
			end
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
							DTArmorSanityCheck(ExpTrace.Entity)
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
							DTArmorSanityCheck(ExpTrace.Entity)
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if ExpTrace.Entity.SPPOwner and ExpTrace.Entity.SPPOwner:IsPlayer() and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
						else
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
						end
					end
				else
					if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
						DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
					else
						DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
					end
				end
				local EffArmor = (DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)/math.abs(ExpTraceLine.HitNormal:Dot(Direction)))
				if ExpTrace.Entity.IsComposite == 1 then
					if ExpTrace.Entity.EntityMods.CompKEMult == nil then ExpTrace.Entity.EntityMods.CompKEMult = 9.2 end 
					if ExpTrace.Entity.EntityMods.CompCEMult == nil then ExpTrace.Entity.EntityMods.CompCEMult = 18.4 end
					EffArmor = (ExpTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*ExpTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*ExpTrace.Entity.EntityMods.CompKEMult
				end
				if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
					util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), IgnoreEnt)
					if ExpTrace.Entity:GetClass()=="dak_crew" then
						util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), IgnoreEnt)
						util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), ExpTrace.Entity)
					end
					Filter[#Filter+1] = IgnoreEnt
					ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
				end
				if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
					if ExpTrace.Entity:GetClass()=="dak_crew" then
						if ExpTrace.Entity.DakHealth <= 0 then
							for blood=1, 15 do
								util.Decal( "Blood", ExpTrace.Entity:GetPos(), ExpTrace.Entity:GetPos()+(VectorRand()*500), ExpTrace.Entity)
							end
						end
					end
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
						--local body = ents.Create( "prop_ragdoll" )
						body:SetPos( ExpTrace.Entity:GetPos() )
						body:SetModel( ExpTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						--ExpTrace.Entity:Remove()
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
					if Owner:IsPlayer() and Shell and Shell.DakGun then
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( Shell.DakGun )
					else
						Pain:SetAttacker( game.GetWorld() )
						Pain:SetInflictor( game.GetWorld() )
					end
					Pain:SetReportedPosition( Shell.DakGun:GetPos() )
					Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					ExpTrace.Entity:TakeDamageInfo( Pain )
				end
			end
		end	
	end
end

util.AddNetworkString( "daktankexplosion" )
function DTShockwave(Pos,Damage,Radius,Pen,Owner,Shell,HitEnt)
	local newtrace = {}
		newtrace.start = Pos - (Shell.DakVelocity:GetNormalized()*1000)
		newtrace.endpos = Pos + (Shell.DakVelocity:GetNormalized()*1000)
		newtrace.filter = Shell.Filter
		newtrace.mins = Vector(-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02,-Shell.DakCaliber*0.02)
		newtrace.maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
	local HitCheckShellTrace = util.TraceHull( newtrace )
	Pos = HitCheckShellTrace.HitPos
	--if Shell.DakCaliber >= 75 then
		net.Start( "daktankexplosion" )
		net.WriteVector( Pos )
		net.WriteFloat( Damage )
		net.WriteString( "daktanks/distexp1.mp3" )
		net.Broadcast()
	--end

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

		if Shell.DakShellType ~= "HESH" then
			local Caliber = Shell.DakCaliber
			local traces = math.Round(Caliber/2)
			local Filter = {}
			for i=1, traces do
				local Direction = VectorRand()
				local trace = {}
					trace.start = Pos
					trace.endpos = Pos + Direction*Radius*2
					trace.filter = Filter
					trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
					trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
				local ExpTrace = util.TraceHull( trace )
				local ExpTraceLine = util.TraceLine( trace )

				if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner, Shell.DakGun) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), HitEnt)
					if ExpTrace.Entity.DakHealth == nil then
						DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
					end
					if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0) or (ExpTrace.Entity.DakName=="Damaged Component")) then
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), HitEnt)
						end
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
										DTArmorSanityCheck(ExpTrace.Entity)
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
										DTArmorSanityCheck(ExpTrace.Entity)
									end
								end
							end
							
							ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

							if ExpTrace.Entity.SPPOwner and ExpTrace.Entity.SPPOwner:IsPlayer() and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
								if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
									if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
										DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
									else	
										DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
									end
								end
							else
								if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
									DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2))*0.001,0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
								else
									DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)),0,DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)*2),Shell.DakGun)
								end
							end
							local EffArmor = (DTGetArmor(ExpTrace.Entity, Shell.DakShellType, 2)/math.abs(ExpTraceLine.HitNormal:Dot(Direction)))
							if ExpTrace.Entity.IsComposite == 1 then
								if ExpTrace.Entity.EntityMods.CompKEMult == nil then ExpTrace.Entity.EntityMods.CompKEMult = 9.2 end 
								if ExpTrace.Entity.EntityMods.CompCEMult == nil then ExpTrace.Entity.EntityMods.CompCEMult = 18.4 end 
								EffArmor = (ExpTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*ExpTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Shell.Filter )*ExpTrace.Entity.EntityMods.CompKEMult
							end
							if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
								util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), Shell.DakGun)
								if ExpTrace.Entity:GetClass()=="dak_crew" then
									util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), HitEnt)
									util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), ExpTrace.Entity)
								end
								ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction,Shell)
							end
							if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
								if ExpTrace.Entity:GetClass()=="dak_crew" then
									if ExpTrace.Entity.DakHealth <= 0 then
										for blood=1, 15 do
											util.Decal( "Blood", ExpTrace.Entity:GetPos(), ExpTrace.Entity:GetPos()+(VectorRand()*500), ExpTrace.Entity)
										end
									end
								end
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
									--local body = ents.Create( "prop_ragdoll" )
									body:SetPos( ExpTrace.Entity:GetPos() )
									body:SetModel( ExpTrace.Entity:GetModel() )
									body:Spawn()
									body.DakHealth=1000000
									body.DakMaxHealth=1000000
									--ExpTrace.Entity:Remove()
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
								if Owner:IsPlayer() and Shell and Shell.DakGun then
									Pain:SetAttacker( Owner )
									Pain:SetInflictor( Shell.DakGun )
								else
									Pain:SetAttacker( game.GetWorld() )
									Pain:SetInflictor( game.GetWorld() )
								end
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
							if ExpTrace.Entity:GetPhysicsObject():IsValid() and ExpTrace.Entity:GetPhysicsObject():GetMass()>1 then
								if ExpTrace.Entity.DakArmor == nil or ExpTrace.Entity.DakBurnStacks == nil then
									DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
								end
								table.insert(Shell.DakDamageList,ExpTrace.Entity)
								if ExpTrace.Entity:GetClass()=="dak_crew" then
									util.Decal( "Blood", ExpTrace.HitPos-(ExpTrace.Normal*5), ExpTrace.HitPos+(ExpTrace.Normal*500), Shell.IgnoreList)
									util.Decal( "Blood", ExpTrace.HitPos-(ExpTrace.Normal*5), ExpTrace.HitPos+(ExpTrace.Normal*500), ExpTrace.Entity)
								end
							end
						else
							if Targets[i]:GetClass() == "dak_bot" then
								if Shell.DakShellType == "SM" then
									Targets[i]:SetHealth(Targets[i]:Health() - 50*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000)))
									Targets[i]:Extinguish()
									Targets[i]:Ignite(25*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000)),1)
								else
									Targets[i]:SetHealth(Targets[i]:Health() - Damage*50*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000))*500)
								end
								if Targets[i]:Health() <= 0 and Shell.revenge==0 then
									--local body = ents.Create( "prop_ragdoll" )
									body:SetPos( Targets[i]:GetPos() )
									body:SetModel( Targets[i]:GetModel() )
									body:Spawn()
									--Targets[i]:Remove()
									local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
									body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
									timer.Simple( 5, function()
										body:Remove()
									end )
								end
							else
								local ExpPain = DamageInfo()
								if Shell.DakShellType == "SM" then
									ExpPain:SetDamageForce( ExpTrace.Normal*50*Shell.DakMass*(Shell.DakVelocity:Distance( Vector(0,0,0) )) )
									ExpPain:SetDamage( 50*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000)) )
									ExpTrace.Entity:Extinguish()
									ExpTrace.Entity:Ignite(25*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000)),1)
								else
									ExpPain:SetDamageForce( ExpTrace.Normal*Damage*Shell.DakMass*(Shell.DakVelocity:Distance( Vector(0,0,0) )) )
									ExpPain:SetDamage( Damage*50*(1-(ExpTrace.Entity:GetPos():Distance(Pos)/1000)) )
								end
								if Owner:IsPlayer() and Shell and Shell.DakGun then
									ExpPain:SetAttacker( Owner )
									ExpPain:SetInflictor( Shell.DakGun )
								else
									ExpPain:SetAttacker( game.GetWorld() )
									ExpPain:SetInflictor( game.GetWorld() )
								end
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
			--[[
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
			--]]
			local HPPerc = 0
			if Shell.DakDamageList[i].SPPOwner and Shell.DakDamageList[i].SPPOwner:IsPlayer() then
				if Shell.DakDamageList[i].SPPOwner:IsWorld() then
					if Shell.DakDamageList[i].DakIsTread==nil then
						if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then
							if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
								DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))*0.001,0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							else
								DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius)),0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end
						else
							if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
								DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*0.001,0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							else
								DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  ),0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end
						end
					end
					Shell.DakDamageList[i].DakLastDamagePos = Pos
					if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
						if Shell.DakDamageList[i]:GetClass()=="dak_crew" then
							if Shell.DakDamageList[i].DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", Shell.DakDamageList[i]:GetPos(), Shell.DakDamageList[i]:GetPos()+(VectorRand()*500), Shell.DakDamageList[i])
								end
							end
						end
						table.insert(Shell.RemoveList,Shell.DakDamageList[i])
					end
				else
					if Shell.DakDamageList[i].SPPOwner:HasGodMode()==false and not(Shell.DakDamageList[i].SPPOwner:IsWorld()) then	
						if Shell.DakDamageList[i].DakIsTread==nil then
							if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then 
								if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
									DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))*0.001,0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
								else
									DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius)),0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
								end
							else
								if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
									DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*0.001,0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
								else
									DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  ),0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
								end
							end
						end
						Shell.DakDamageList[i].DakLastDamagePos = Pos
						if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
							if Shell.DakDamageList[i]:GetClass()=="dak_crew" then
								if Shell.DakDamageList[i].DakHealth <= 0 then
									for blood=1, 15 do
										util.Decal( "Blood", Shell.DakDamageList[i]:GetPos(), Shell.DakDamageList[i]:GetPos()+(VectorRand()*500), Shell.DakDamageList[i])
									end
								end
							end
							table.insert(Shell.RemoveList,Shell.DakDamageList[i])
						end
					end
				end
			else
				if Shell.DakDamageList[i].DakIsTread==nil then
					if Shell.DakDamageList[i]:GetPos():Distance(Pos) > Radius/2 then 
						if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
							DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius))*0.001,0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						else
							DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*(1-(Shell.DakDamageList[i]:GetPos():Distance(Pos)/Radius)),0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					else
						if Shell.DakDamageList[i]:GetClass() == "dak_tegun" or Shell.DakDamageList[i]:GetClass() == "dak_temachinegun" or Shell.DakDamageList[i]:GetClass() == "dak_teautogun" then
							DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  )*0.001,0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						else
							DTDealDamage(Shell.DakDamageList[i], math.Clamp((  (Damage/table.Count(Shell.DakDamageList)) * (Pen/DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber))  ),0,DTGetArmor(Shell.DakDamageList[i], Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					end
				end
				Shell.DakDamageList[i].DakLastDamagePos = Pos
				if Shell.DakDamageList[i].DakHealth <= 0 and Shell.DakDamageList[i].DakPooled==0 then
					if Shell.DakDamageList[i]:GetClass()=="dak_crew" then
						if Shell.DakDamageList[i].DakHealth <= 0 then
							for blood=1, 15 do
								util.Decal( "Blood", Shell.DakDamageList[i]:GetPos(), Shell.DakDamageList[i]:GetPos()+(VectorRand()*500), Shell.DakDamageList[i])
							end
						end
					end
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
	--local SpallVolume = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)
	--local SpallMass = (SpallVolume*0.0078125) * 0.1
	local SpallPen = Armor * 0.1
	local SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*(Armor*0.1)*0.001
	local Ang = 45*(Armor/Pen)
	if (Shell.DakShellType == "HESH" or Shell.DakShellType == "HE") and Shell.HeatPen == true then
		Ang = 30 * math.Clamp((Pen/Armor),1,3)
	end
	if Shell.DakShellType == "HE" then
		Ang = Ang*2
	end
	--if Ang < math.Clamp(Caliber*0.5,10,22.5) then Ang = math.Clamp(Caliber*0.5,10,22.5) end
	local traces = (Ang*Ang*0.04)
	if (Shell.DakShellType == "HESH" or Shell.DakShellType == "HE") and Shell.HeatPen == true then
		--SpallMass = (SpallVolume*0.0078125) * 0.05
		SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*5*0.005
		SpallPen = Caliber * 0.1
		traces = traces*2
		--traces = 20 * math.Clamp((Pen/Armor),1,3)
	end
	if Shell.DakShellType == "HEAT" then
		--SpallMass = (SpallVolume*0.0078125) * 0.05
		SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*5*0.005
		SpallPen = Armor * 0.2
		traces = traces*2
		--traces = 20
	end
	if Shell.DakShellType == "HEATFS" then
		--SpallMass = (SpallVolume*0.0078125) * 0.05
		SpallDamage = math.pi*((Caliber*0.05)*(Caliber*0.05))*5*0.005
		SpallPen = Armor * 0.2
		--traces = 20
	end
	if HitEnt.EntityMods ~= nil and HitEnt.EntityMods.Ductility ~= nil then
		traces = math.Round(traces * HitEnt.EntityMods.Ductility)
		SpallDamage = math.Round(SpallDamage * HitEnt.EntityMods.Ductility,2)
		SpallPen = math.Round(SpallPen * HitEnt.EntityMods.Ductility,2)
	end
	local Filter = table.Copy( Shell.Filter )
	if SpallDamage < 0.01 then traces = 0 end
	if traces > 50 then
		SpallDamage = SpallDamage * (traces/50)
		traces = 50
	end
	local DEBUGSpallDamage = 0
	--print(traces)
	for i=1, traces do
		local Direction = (Angle(math.Rand(-Ang,Ang),math.Rand(-Ang,Ang),math.Rand(-Ang,Ang))):Forward() + Dir
		local trace = {}
			trace.start = Pos - Direction*2
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-Caliber*0.002,-Caliber*0.002,-Caliber*0.002)
			trace.maxs = Vector(Caliber*0.002,Caliber*0.002,Caliber*0.002)
		local SpallTrace = util.TraceLine( trace )
		if hook.Run("DakTankDamageCheck", SpallTrace.Entity, Owner, Shell.DakGun) ~= false and SpallTrace.HitPos:Distance(Pos)<=1000 then
			if SpallTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(SpallTrace.Entity)
			end
			if SpallTrace.Entity:IsValid() and not(SpallTrace.Entity:IsPlayer()) and not(SpallTrace.Entity:IsNPC()) and not(SpallTrace.Entity.Base == "base_nextbot") and (SpallTrace.Entity.DakHealth and not(SpallTrace.Entity.DakHealth <= 0) or (SpallTrace.Entity.DakName=="Damaged Component")) then
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
								DTArmorSanityCheck(SpallTrace.Entity)
							end
						end
					end
					Filter[#Filter+1] = HitEnt
					ContSpall(Filter,SpallTrace.Entity,Pos,SpallDamage,SpallPen,Owner,Direction,Shell,10)
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
								DTArmorSanityCheck(SpallTrace.Entity)
							end
						end
					end
					
					SpallTrace.Entity.DakLastDamagePos = SpallTrace.HitPos
					if SpallTrace.Entity.SPPOwner and SpallTrace.Entity.SPPOwner:IsPlayer() and not(SpallTrace.Entity.SPPOwner:IsWorld()) then			
						if SpallTrace.Entity.SPPOwner:HasGodMode()==false and SpallTrace.Entity.DakIsTread == nil then	
							if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
								DTDealDamage(SpallTrace.Entity, math.Clamp(SpallDamage*(SpallPen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
							else
								DTDealDamage(SpallTrace.Entity, math.Clamp(SpallDamage*(SpallPen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end		
						end
					else
						if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(SpallTrace.Entity, math.Clamp(SpallDamage*(SpallPen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
						else
							DTDealDamage(SpallTrace.Entity, math.Clamp(SpallDamage*(SpallPen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					end
					DEBUGSpallDamage = DEBUGSpallDamage+ math.Clamp(SpallDamage*(SpallPen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)
					if SpallTrace.Entity.DakHealth <= 0 and SpallTrace.Entity.DakPooled==0 then
						if SpallTrace.Entity:GetClass()=="dak_crew" then
							if SpallTrace.Entity.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", SpallTrace.Entity:GetPos(), SpallTrace.Entity:GetPos()+(VectorRand()*500), SpallTrace.Entity)
								end
							end
						end
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
					local EffArmor = (DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)/math.abs(SpallTrace.HitNormal:Dot(Direction)))
					if SpallTrace.Entity.IsComposite == 1 then
						if SpallTrace.Entity.EntityMods.CompKEMult == nil then SpallTrace.Entity.EntityMods.CompKEMult = 9.2 end 
						if SpallTrace.Entity.EntityMods.CompCEMult == nil then SpallTrace.Entity.EntityMods.CompCEMult = 18.4 end
						EffArmor = (SpallTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*SpallTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( SpallTrace.Entity, SpallTrace.HitPos, SpallTrace.Normal, Filter  )*SpallTrace.Entity.EntityMods.CompKEMult
					end
					if EffArmor < SpallPen and SpallTrace.Entity.IsDakTekFutureTech == nil then
						--decals don't like using the adjusted by normal Pos
						--util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
						--util.Decal( "Impact.Concrete", SpallTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})

						if SpallTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", SpallTrace.HitPos-(Direction*5), SpallTrace.HitPos+(Direction*500), Shell.DakGun)
							util.Decal( "Blood", SpallTrace.HitPos-(Direction*5), SpallTrace.HitPos+(Direction*500), SpallTrace.Entity)
						end

						Filter[#Filter+1] = HitEnt
						ContSpall(Filter,SpallTrace.Entity,Pos,SpallDamage*(1-EffArmor/SpallPen),SpallPen-EffArmor,Owner,Direction,Shell,10)
					else
						--decals don't like using the adjusted by normal Pos
						--util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,HitEnt})
						if SpallTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", SpallTrace.HitPos-(Direction*5), SpallTrace.HitPos+(Direction*500), Shell.DakGun)
						end
						--SpallBounceHere
						local HitAng = math.deg(math.acos(SpallTrace.HitNormal:Dot(-SpallTrace.Normal)))
						local Energy = 10 - (HitAng * 0.1)
						if Energy > 10 then
							local newDir = (((SpallTrace.HitNormal)+((SpallTrace.HitPos-Pos):GetNormalized()*1*(45/(90-HitAng)))):GetNormalized():Angle() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))):Forward()
							ContSpall({},Shell.DakGun,SpallTrace.HitPos+SpallTrace.HitNormal*2,SpallDamage*(Energy/10),SpallPen*(Energy/10),Owner,newDir,Shell,Energy)
						end
					end
				end
			end
			if SpallTrace.Entity:IsValid() then
				if SpallTrace.Entity:IsPlayer() or SpallTrace.Entity:IsNPC() or SpallTrace.Entity.Base == "base_nextbot" then
					if SpallTrace.Entity:GetClass() == "dak_bot" then
						SpallTrace.Entity:SetHealth(SpallTrace.Entity:Health() - (SpallDamage)*500)
						if SpallTrace.Entity:Health() <= 0 and SpallTrace.Entity.revenge==0 then
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( SpallTrace.Entity:GetPos() )
							body:SetModel( SpallTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							--SpallTrace.Entity:Remove()
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
						if Owner:IsPlayer() and Shell and Shell.DakGun then
							Pain:SetAttacker( Owner )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
						Pain:SetReportedPosition( Shell.DakGun:GetPos() )
						Pain:SetDamagePosition( SpallTrace.Entity:GetPos() )
						Pain:SetDamageType(DMG_BLAST)
						SpallTrace.Entity:TakeDamageInfo( Pain )
					end
				end
				--local effectdata = EffectData()
				--effectdata:SetStart(Pos)
				--effectdata:SetOrigin(SpallTrace.HitPos)
				--effectdata:SetScale(Shell.DakCaliber*0.00393701)
				--util.Effect("dakteballistictracer", effectdata)
			else
				--local effectdata = EffectData()
				--effectdata:SetStart(Pos)
				--effectdata:SetOrigin(Pos + Direction*1000)
				--effectdata:SetScale(Shell.DakCaliber*0.00393701)
				--util.Effect("dakteballistictracer", effectdata)
			end
		end
	end
	--print("Spall Damage")
	--print(DEBUGSpallDamage)
end

function ContSpall(Filter,IgnoreEnt,Pos,Damage,Pen,Owner,Direction,Shell,Energy)
	local trace = {}
		trace.start = Pos - Direction*2
		trace.endpos = Pos + Direction*1000
		trace.filter = Filter
		trace.mins = Vector(-Shell.DakCaliber*0.002,-Shell.DakCaliber*0.002,-Shell.DakCaliber*0.002)
		trace.maxs = Vector(Shell.DakCaliber*0.002,Shell.DakCaliber*0.002,Shell.DakCaliber*0.002)
	local SpallTrace = util.TraceLine( trace )
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
							DTArmorSanityCheck(SpallTrace.Entity)
						end
					end
				end
				Filter[#Filter+1] = IgnoreEnt
				ContSpall(Filter,SpallTrace.Entity,Pos,Damage,Pen,Owner,Direction,Shell,Energy)
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
							DTArmorSanityCheck(SpallTrace.Entity)
						end
					end
				end
				
				SpallTrace.Entity.DakLastDamagePos = SpallTrace.HitPos
				if SpallTrace.Entity.SPPOwner and SpallTrace.Entity.SPPOwner:IsPlayer() and not(SpallTrace.Entity.SPPOwner:IsWorld()) then			
					if SpallTrace.Entity.SPPOwner:HasGodMode()==false and SpallTrace.Entity.DakIsTread == nil then	
						if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(SpallTrace.Entity, math.Clamp(Damage*(Pen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
						else
							DTDealDamage(SpallTrace.Entity, math.Clamp(Damage*(Pen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					end
				else
					if SpallTrace.Entity:GetClass() == "dak_tegun" or SpallTrace.Entity:GetClass() == "dak_temachinegun" or SpallTrace.Entity:GetClass() == "dak_teautogun" then
						DTDealDamage(SpallTrace.Entity, math.Clamp(Damage*(Pen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
					else
						DTDealDamage(SpallTrace.Entity, math.Clamp(Damage*(Pen/DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
					end
				end
				if SpallTrace.Entity.DakHealth <= 0 and SpallTrace.Entity.DakPooled==0 then
					if SpallTrace.Entity:GetClass()=="dak_crew" then
						if SpallTrace.Entity.DakHealth <= 0 then
							for blood=1, 15 do
								util.Decal( "Blood", SpallTrace.Entity:GetPos(), SpallTrace.Entity:GetPos()+(VectorRand()*500), SpallTrace.Entity)
							end
						end
					end
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
				local EffArmor = (DTGetArmor(SpallTrace.Entity, Shell.DakShellType, Shell.DakCaliber)/math.abs(SpallTrace.HitNormal:Dot(Direction)))
				if SpallTrace.Entity.IsComposite == 1 then
					if SpallTrace.Entity.EntityMods.CompKEMult == nil then SpallTrace.Entity.EntityMods.CompKEMult = 9.2 end 
					if SpallTrace.Entity.EntityMods.CompCEMult == nil then SpallTrace.Entity.EntityMods.CompCEMult = 18.4 end
					EffArmor = (SpallTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*SpallTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( SpallTrace.Entity, SpallTrace.HitPos, SpallTrace.Normal, Filter  )*SpallTrace.Entity.EntityMods.CompKEMult
				end
				if EffArmor < Pen and SpallTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					--util.Decal( "Impact.Concrete", Pos, Pos+(Direction*1000), {Shell.DakGun})
					--util.Decal( "Impact.Concrete", SpallTrace.HitPos+(Direction*5), Pos, {Shell.DakGun})

					if SpallTrace.Entity:GetClass()=="dak_crew" then
						util.Decal( "Blood", SpallTrace.HitPos-(Direction*5), SpallTrace.HitPos+(Direction*500), Shell.DakGun)
						util.Decal( "Blood", SpallTrace.HitPos-(Direction*5), SpallTrace.HitPos+(Direction*500), SpallTrace.Entity)
					end

					Filter[#Filter+1] = IgnoreEnt
					ContSpall(Filter,SpallTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Pen-EffArmor,Owner,Direction,Shell,Energy)
				else
					--decals don't like using the adjusted by normal Pos
					--util.Decal( "Impact.Glass", Pos, Pos+(Direction*1000), {Shell.DakGun,HitEnt})
					if SpallTrace.Entity:GetClass()=="dak_crew" then
						util.Decal( "Blood", SpallTrace.HitPos-(Direction*5), SpallTrace.HitPos+(Direction*500), Shell.DakGun)
					end
					--SpallBounceHere
					local HitAng = math.deg(math.acos(SpallTrace.HitNormal:Dot(-SpallTrace.Normal)))
					Energy = Energy - (HitAng * 0.1)
					if Energy > 10 then
						Pen = Pen*(Energy/10)
						Damage = Damage*(Energy/10)
						local newDir = (((SpallTrace.HitNormal)+((SpallTrace.HitPos-Pos):GetNormalized()*1*(45/(90-HitAng)))):GetNormalized():Angle() + Angle(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1))):Forward()
						ContSpall({},Shell.DakGun,SpallTrace.HitPos+SpallTrace.HitNormal*2,Damage,Pen,Owner,newDir,Shell,Energy)
					end
				end
			end
		end
		if SpallTrace.Entity:IsValid() then
			if SpallTrace.Entity:IsPlayer() or SpallTrace.Entity:IsNPC() or SpallTrace.Entity.Base == "base_nextbot" then
				if SpallTrace.Entity:GetClass() == "dak_bot" then
					SpallTrace.Entity:SetHealth(SpallTrace.Entity:Health() - (Damage)*500)
					if SpallTrace.Entity:Health() <= 0 and SpallTrace.Entity.revenge==0 then
						--local body = ents.Create( "prop_ragdoll" )
						body:SetPos( SpallTrace.Entity:GetPos() )
						body:SetModel( SpallTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						--SpallTrace.Entity:Remove()
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
					if Owner:IsPlayer() and Shell and Shell.DakGun then
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( Shell.DakGun )
					else
						Pain:SetAttacker( game.GetWorld() )
						Pain:SetInflictor( game.GetWorld() )
					end
					Pain:SetReportedPosition( Shell.DakGun:GetPos() )
					Pain:SetDamagePosition( SpallTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					SpallTrace.Entity:TakeDamageInfo( Pain )
				end
			end
			--local effectdata = EffectData()
			--effectdata:SetStart(Pos)
			--effectdata:SetOrigin(SpallTrace.HitPos)
			--effectdata:SetScale(Shell.DakCaliber*0.00393701)
			--util.Effect("dakteballistictracer", effectdata)
		else
			--local effectdata = EffectData()
			--effectdata:SetStart(Pos)
			--effectdata:SetOrigin(Pos + Direction*1000)
			--effectdata:SetScale(Shell.DakCaliber*0.00393701)
			--util.Effect("dakteballistictracer", effectdata)
		end	
	end
end

function DTHEAT(Pos,HitEnt,Caliber,Pen,Damage,Owner,Shell)
	if Shell.DakShellType == "HEATFS" or Shell.DakShellType == "ATGM" then
		local HEATPen = Pen
		local HEATDamage = Damage
		local Filter = {HitEnt}
		local Direction = Shell.DakVelocity:GetNormalized()
		local trace = {}
			trace.start = Pos - Direction*250
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-Caliber*0.02,-Caliber*0.02,-Caliber*0.02)
			trace.maxs = Vector(Caliber*0.02,Caliber*0.02,Caliber*0.02)
		local HEATTrace = util.TraceHull( trace )
		local HEATTraceLine = util.TraceLine( trace )
		if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
			if HEATTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
			end
			if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") and (HEATTrace.Entity.DakHealth and not(HEATTrace.Entity.DakHealth <= 0) or (HEATTrace.Entity.DakName=="Damaged Component")) then
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
								DTArmorSanityCheck(HEATTrace.Entity)
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
								DTArmorSanityCheck(HEATTrace.Entity)
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

					if HEATTrace.Entity.SPPOwner and HEATTrace.Entity.SPPOwner:IsPlayer() and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
						if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then	
							if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
								DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
							else
								DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end	
						end
					else
						if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
						else
							DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end
					end
					--print("First Impact Damage")
					--print(math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2))
					if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
						if HEATTrace.Entity:GetClass()=="dak_crew" then
							if HEATTrace.Entity.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", HEATTrace.Entity:GetPos(), HEATTrace.Entity:GetPos()+(VectorRand()*500), HEATTrace.Entity)
								end
							end
						end
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
					local EffArmor = (DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)/math.abs(HEATTraceLine.HitNormal:Dot(Direction)))
					if HEATTrace.Entity.IsComposite == 1 then
						if HEATTrace.Entity.EntityMods.CompKEMult == nil then HEATTrace.Entity.EntityMods.CompKEMult = 9.2 end 
						if HEATTrace.Entity.EntityMods.CompCEMult == nil then HEATTrace.Entity.EntityMods.CompCEMult = 18.4 end
						EffArmor = DTCompositesTrace( HEATTrace.Entity, HEATTrace.HitPos, HEATTrace.Normal, Shell.Filter )*HEATTrace.Entity.EntityMods.CompCEMult
						if Shell.IsTandem == true then
							if HEATTrace.Entity.IsERA == 1 then
								EffArmor = 0
							end
						end
					end
					if EffArmor < math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen) and HEATTrace.Entity.IsDakTekFutureTech == nil then
						Filter[#Filter+1] = HEATTrace.Entity
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Concrete", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun})
						util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), HEATTrace.HitPos-(Direction*5), {Shell.DakGun})
						if HEATTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), Shell.DakGun)
							util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), HEATTrace.Entity)
						end
						DTSpall(Pos,EffArmor,HEATTrace.Entity,Shell.DakCaliber,math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen),Owner,Shell, Direction:Angle():Forward())
						ContHEAT(Filter,HEATTrace.Entity,HEATTrace.HitPos,HEATDamage*(1-EffArmor/math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)),math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)-EffArmor,Owner,Direction:Angle():Forward(),Shell,true)
					else
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Glass", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun,HitEnt})
						if HEATTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), Shell.DakGun)
						end
					end
				end
			end
			if HEATTrace.Entity:IsValid() then
				if HEATTrace.Entity:IsPlayer() or HEATTrace.Entity:IsNPC() or HEATTrace.Entity.Base == "base_nextbot" then
					if HEATTrace.Entity:GetClass() == "dak_bot" then
						HEATTrace.Entity:SetHealth(HEATTrace.Entity:Health() - (HEATDamage)*500)
						if HEATTrace.Entity:Health() <= 0 and HEATTrace.Entity.revenge==0 then
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( HEATTrace.Entity:GetPos() )
							body:SetModel( HEATTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							--HEATTrace.Entity:Remove()
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
						if Owner:IsPlayer() and Shell and Shell.DakGun then
							Pain:SetAttacker( Owner )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
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
		local Direction = Shell.DakVelocity:GetNormalized()
		local trace = {}
			trace.start = Pos - Direction*250
			trace.endpos = Pos + Direction*1000
			trace.filter = Filter
			trace.mins = Vector(-Caliber*0.02,-Caliber*0.02,-Caliber*0.02)
			trace.maxs = Vector(Caliber*0.02,Caliber*0.02,Caliber*0.02)
		local HEATTrace = util.TraceHull( trace )
		local HEATTraceLine = util.TraceLine( trace )
		if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
			if HEATTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
			end
			if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") and (HEATTrace.Entity.DakHealth and not(HEATTrace.Entity.DakHealth <= 0) or (HEATTrace.Entity.DakName=="Damaged Component")) then
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
								DTArmorSanityCheck(HEATTrace.Entity)
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
								DTArmorSanityCheck(HEATTrace.Entity)
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

					if HEATTrace.Entity.SPPOwner and HEATTrace.Entity.SPPOwner:IsPlayer() and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
						if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then	
							if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
								DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
							else
								DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
							end	
						end
					else
						if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
						else
							DTDealDamage(HEATTrace.Entity, math.Clamp(HEATDamage*(math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end	
					end
					if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
						if HEATTrace.Entity:GetClass()=="dak_crew" then
							if HEATTrace.Entity.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", HEATTrace.Entity:GetPos(), HEATTrace.Entity:GetPos()+(VectorRand()*500), HEATTrace.Entity)
								end
							end
						end
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
					local EffArmor = (DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)/math.abs(HEATTraceLine.HitNormal:Dot(Direction)))
					if HEATTrace.Entity.IsComposite == 1 then
						if HEATTrace.Entity.EntityMods.CompKEMult == nil then HEATTrace.Entity.EntityMods.CompKEMult = 9.2 end 
						if HEATTrace.Entity.EntityMods.CompCEMult == nil then HEATTrace.Entity.EntityMods.CompCEMult = 18.4 end
						EffArmor = DTCompositesTrace( HEATTrace.Entity, HEATTrace.HitPos, HEATTrace.Normal, Shell.Filter )*HEATTrace.Entity.EntityMods.CompCEMult
						if Shell.IsTandem == true then
							if HEATTrace.Entity.IsERA == 1 then
								EffArmor = 0
							end
						end
					end
					if EffArmor < math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen) and HEATTrace.Entity.IsDakTekFutureTech == nil then
						Filter[#Filter+1] = HEATTrace.Entity
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Concrete", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun})
						util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), HEATTrace.HitPos-(Direction*5), {Shell.DakGun})
						if HEATTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), Shell.DakGun)
							util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), HEATTrace.Entity)
						end
						DTSpall(Pos,EffArmor,HEATTrace.Entity,Shell.DakCaliber,math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen),Owner,Shell, Direction:Angle():Forward())
						ContHEAT(Filter,HEATTrace.Entity,HEATTrace.HitPos,HEATDamage*(1-EffArmor/math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)),math.Clamp(HEATPen-HeatPenLoss,HEATPen*0.05,HEATPen)-EffArmor,Owner,Direction:Angle(),Shell,true)
					else
						--decals don't like using the adjusted by normal Pos
						util.Decal( "Impact.Glass", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun,HitEnt})
						if HEATTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), Shell.DakGun)
						end
					end
				end
			end
			if HEATTrace.Entity:IsValid() then
				if HEATTrace.Entity:IsPlayer() or HEATTrace.Entity:IsNPC() or HEATTrace.Entity.Base == "base_nextbot" then
					if HEATTrace.Entity:GetClass() == "dak_bot" then
						HEATTrace.Entity:SetHealth(HEATTrace.Entity:Health() - (HEATDamage)*500)
						if HEATTrace.Entity:Health() <= 0 and HEATTrace.Entity.revenge==0 then
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( HEATTrace.Entity:GetPos() )
							body:SetModel( HEATTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							--HEATTrace.Entity:Remove()
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
						if Owner:IsPlayer() and Shell and Shell.DakGun then
							Pain:SetAttacker( Owner )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
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
	local HEATTraceLine = util.TraceLine( trace )

	if hook.Run("DakTankDamageCheck", HEATTrace.Entity, Owner, Shell.DakGun) ~= false and HEATTrace.HitPos:Distance(Pos)<=1000 then
		if HEATTrace.Entity.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(HEATTrace.Entity)
		end
		if HEATTrace.Entity:IsValid() and not(HEATTrace.Entity:IsPlayer()) and not(HEATTrace.Entity:IsNPC()) and not(HEATTrace.Entity.Base == "base_nextbot") and (HEATTrace.Entity.DakHealth and not(HEATTrace.Entity.DakHealth <= 0) or (HEATTrace.Entity.DakName=="Damaged Component")) then
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
							DTArmorSanityCheck(HEATTrace.Entity)
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
							DTArmorSanityCheck(HEATTrace.Entity)
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
				if HEATTrace.Entity.SPPOwner and HEATTrace.Entity.SPPOwner:IsPlayer() and not(HEATTrace.Entity.SPPOwner:IsWorld()) then			
					if HEATTrace.Entity.SPPOwner:HasGodMode()==false and HEATTrace.Entity.DakIsTread == nil then
						if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(HEATTrace.Entity, math.Clamp(Damage*((Pen-HeatPenLoss)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
						else
							DTDealDamage(HEATTrace.Entity, math.Clamp(Damage*((Pen-HeatPenLoss)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
						end	
					end
				else
					if HEATTrace.Entity:GetClass() == "dak_tegun" or HEATTrace.Entity:GetClass() == "dak_temachinegun" or HEATTrace.Entity:GetClass() == "dak_teautogun" then
						DTDealDamage(HEATTrace.Entity, math.Clamp(Damage*((Pen-HeatPenLoss)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2)*0.001,Shell.DakGun)
					else
						DTDealDamage(HEATTrace.Entity, math.Clamp(Damage*((Pen-HeatPenLoss)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2),Shell.DakGun)
					end	
				end
				--print("Secondary Impact Damage")
				--print(math.Clamp(Damage*((Pen-HeatPenLoss)/DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)),0,DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)*2))
				if HEATTrace.Entity.DakHealth <= 0 and HEATTrace.Entity.DakPooled==0 then
					if HEATTrace.Entity:GetClass()=="dak_crew" then
						if HEATTrace.Entity.DakHealth <= 0 then
							for blood=1, 15 do
								util.Decal( "Blood", HEATTrace.Entity:GetPos(), HEATTrace.Entity:GetPos()+(VectorRand()*500), HEATTrace.Entity)
							end
						end
					end
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
				local EffArmor = (DTGetArmor(HEATTrace.Entity, Shell.DakShellType, Shell.DakCaliber)/math.abs(HEATTraceLine.HitNormal:Dot(Direction)))
				if HEATTrace.Entity.IsComposite == 1 then
					if HEATTrace.Entity.EntityMods.CompKEMult == nil then HEATTrace.Entity.EntityMods.CompKEMult = 9.2 end 
					if HEATTrace.Entity.EntityMods.CompCEMult == nil then HEATTrace.Entity.EntityMods.CompCEMult = 18.4 end
					EffArmor = DTCompositesTrace( HEATTrace.Entity, HEATTrace.HitPos, HEATTrace.Normal, Shell.Filter )*HEATTrace.Entity.EntityMods.CompCEMult
					if Shell.IsTandem == true then
						if HEATTrace.Entity.IsERA == 1 then
							EffArmor = 0
						end
					end
				end
				if EffArmor < (Pen-HeatPenLoss) and HEATTrace.Entity.IsDakTekFutureTech == nil then
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Concrete", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun})
					util.Decal( "Impact.Concrete", HEATTrace.HitPos+(Direction*5), HEATTrace.HitPos-(Direction*5), {Shell.DakGun})
					if HEATTrace.Entity:GetClass()=="dak_crew" then
						util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), Shell.DakGun)
						util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), HEATTrace.Entity)
					end
					Filter[#Filter+1] = IgnoreEnt
					Filter[#Filter+1] = HEATTrace.Entity
					DTSpall(Pos,EffArmor,HEATTrace.Entity,Shell.DakCaliber,math.Clamp(Pen-HeatPenLoss,Pen*0.05,Pen),Owner,Shell, Direction:Angle():Forward())
					ContHEAT(Filter,HEATTrace.Entity,HEATTrace.HitPos,Damage*(1-EffArmor/(Pen-HeatPenLoss)),(Pen-HeatPenLoss)-EffArmor,Owner,Direction,Shell,true)
				else
					--decals don't like using the adjusted by normal Pos
					util.Decal( "Impact.Glass", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*5), {Shell.DakGun, HitEnt})
					if HEATTrace.Entity:GetClass()=="dak_crew" then
						util.Decal( "Blood", HEATTrace.HitPos-(Direction*5), HEATTrace.HitPos+(Direction*500), Shell.DakGun)
					end
				end
			end
		end
		if HEATTrace.Entity:IsValid() then
			if HEATTrace.Entity:IsPlayer() or HEATTrace.Entity:IsNPC() or HEATTrace.Entity.Base == "base_nextbot" then
				if HEATTrace.Entity:GetClass() == "dak_bot" then
					HEATTrace.Entity:SetHealth(HEATTrace.Entity:Health() - (Damage)*500)
					if HEATTrace.Entity:Health() <= 0 and HEATTrace.Entity.revenge==0 then
						--local body = ents.Create( "prop_ragdoll" )
						body:SetPos( HEATTrace.Entity:GetPos() )
						body:SetModel( HEATTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						--HEATTrace.Entity:Remove()
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
					if Owner:IsPlayer() and Shell and Shell.DakGun then
						Pain:SetAttacker( Owner )
						Pain:SetInflictor( Shell.DakGun )
					else
						Pain:SetAttacker( game.GetWorld() )
						Pain:SetInflictor( game.GetWorld() )
					end
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

local entity = FindMetaTable( "Entity" )

function entity:CheckClip(Ent, HitPos)
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

function entity:DTExplosion(Pos,Damage,Radius,Caliber,Pen,Owner)
	local traces = math.Round(Caliber/2)
	local Filter = {self}
	for i=1, traces do
		local Direction = VectorRand()
		local trace = {}
			trace.start = Pos
			trace.endpos = Pos + Direction*Radius*10
			trace.filter = Filter
			trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
			trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
		local ExpTrace = util.TraceHull( trace )
		local ExpTraceLine = util.TraceLine( trace )

		if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
			--decals don't like using the adjusted by normal Pos
			--util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), self)
			if ExpTrace.Entity.DakHealth == nil then
				DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
			end
			if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0) or (ExpTrace.Entity.DakName=="Damaged Component")) then
				if ExpTrace.Entity:GetClass()=="dak_crew" then
					util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), self)
				end
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
								DTArmorSanityCheck(ExpTrace.Entity)
							end
						end
					end
					self:ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
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
								DTArmorSanityCheck(ExpTrace.Entity)
							end
						end
					end
					
					ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

					if ExpTrace.Entity.SPPOwner and ExpTrace.Entity.SPPOwner:IsPlayer() and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
						if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then
							if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber))*0.001,0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
							else
								if ExpTrace.Entity.IsERA == 1 then
									DTDealDamage(ExpTrace.Entity, math.Clamp((Damage*10/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
								else
									DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
								end
							end
						end
					else
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber))*0.001,0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
						else
							if ExpTrace.Entity.IsERA == 1 then
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage*10/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
							else
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
							end	
						end
					end
					local EffArmor = (DTGetArmor(ExpTrace.Entity, "HE", Caliber)/math.abs(ExpTraceLine.HitNormal:Dot(Direction)))
					if ExpTrace.Entity.IsComposite == 1 then
						if ExpTrace.Entity.EntityMods.CompKEMult == nil then ExpTrace.Entity.EntityMods.CompKEMult = 9.2 end 
						if ExpTrace.Entity.EntityMods.CompCEMult == nil then ExpTrace.Entity.EntityMods.CompCEMult = 18.4 end 
						EffArmor = (ExpTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*ExpTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Filter )*ExpTrace.Entity.EntityMods.CompKEMult
					end
					if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
						--util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), self)
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), self)
							util.Decal( "Blood", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*500), ExpTrace.Entity)
						end
						self:ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction)
					end
					if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
						if ExpTrace.Entity:GetClass()=="dak_crew" then
							if ExpTrace.Entity.DakHealth <= 0 then
								for blood=1, 15 do
									util.Decal( "Blood", ExpTrace.Entity:GetPos(), ExpTrace.Entity:GetPos()+(VectorRand()*500), ExpTrace.Entity)
								end
							end
						end
						Filter[#Filter+1] = ExpTrace.Entity
						local salvage = ents.Create( "dak_tesalvage" )
						self.salvage = salvage
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
							--local body = ents.Create( "prop_ragdoll" )
							body:SetPos( ExpTrace.Entity:GetPos() )
							body:SetModel( ExpTrace.Entity:GetModel() )
							body:Spawn()
							body.DakHealth=1000000
							body.DakMaxHealth=1000000
							--ExpTrace.Entity:Remove()
							local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
							body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
							timer.Simple( 5, function()
								body:Remove()
							end )
						end
					else
						local Pain = DamageInfo()
						Pain:SetDamageForce( Direction*(Damage/traces)*5000*2 )
						Pain:SetDamage( (Damage/traces)*500 )
						if Owner:IsPlayer() then
							Pain:SetAttacker( Owner )
						else
							Pain:SetAttacker( game.GetWorld() )
						end
						if self and Shell and Shell.DakGun then
							Pain:SetAttacker( self )
							Pain:SetInflictor( Shell.DakGun )
						else
							Pain:SetAttacker( game.GetWorld() )
							Pain:SetInflictor( game.GetWorld() )
						end
						Pain:SetReportedPosition( Pos )
						Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
						Pain:SetDamageType(DMG_BLAST)
						ExpTrace.Entity:TakeDamageInfo( Pain )
					end
				end
			end	
		end
	end
end

function entity:ContEXP(Filter,IgnoreEnt,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
	local traces = math.Round(Caliber/2)
	local trace = {}
		trace.start = Pos
		trace.endpos = Pos + Direction*Radius*10
		trace.filter = Filter
		trace.mins = Vector(-(Caliber/traces)*0.02,-(Caliber/traces)*0.02,-(Caliber/traces)*0.02)
		trace.maxs = Vector((Caliber/traces)*0.02,(Caliber/traces)*0.02,(Caliber/traces)*0.02)
	local ExpTrace = util.TraceHull( trace )
	local ExpTraceLine = util.TraceLine( trace )

	if hook.Run("DakTankDamageCheck", ExpTrace.Entity, Owner) ~= false and ExpTrace.HitPos:Distance(Pos)<=Radius then
		--decals don't like using the adjusted by normal Pos
		util.Decal( "Impact.Concrete", ExpTrace.HitPos-(Direction*5), ExpTrace.HitPos+(Direction*5), IgnoreEnt)
		if ExpTrace.Entity.DakHealth == nil then
			DakTekTankEditionSetupNewEnt(ExpTrace.Entity)
		end
		if ExpTrace.Entity:IsValid() and not(ExpTrace.Entity:IsPlayer()) and not(ExpTrace.Entity:IsNPC()) and not(ExpTrace.Entity.Base == "base_nextbot") and (ExpTrace.Entity.DakHealth and not(ExpTrace.Entity.DakHealth <= 0) or (ExpTrace.Entity.DakName=="Damaged Component")) then
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
							DTArmorSanityCheck(ExpTrace.Entity)
						end
					end
				end
				Filter[#Filter+1] = IgnoreEnt
				self:ContEXP(Filter,ExpTrace.Entity,Pos,Damage,Radius,Caliber,Pen,Owner,Direction)
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
							DTArmorSanityCheck(ExpTrace.Entity)
						end
					end
				end
				
				ExpTrace.Entity.DakLastDamagePos = ExpTrace.HitPos

				if ExpTrace.Entity.SPPOwner and ExpTrace.Entity.SPPOwner:IsPlayer() and not(ExpTrace.Entity.SPPOwner:IsWorld()) then			
					if ExpTrace.Entity.SPPOwner:HasGodMode()==false and ExpTrace.Entity.DakIsTread == nil then	
						if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
							DTDealDamage(ExpTrace.Entity,- math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber))*0.001,0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
						else
							if ExpTrace.Entity.IsERA == 1 then
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage*10/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
							else
								DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
							end
						end
					end
				else
					if ExpTrace.Entity:GetClass() == "dak_tegun" or ExpTrace.Entity:GetClass() == "dak_temachinegun" or ExpTrace.Entity:GetClass() == "dak_teautogun" then
						DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber))*0.001,0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
					else
						if ExpTrace.Entity.IsERA == 1 then
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage*10/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
						else
							DTDealDamage(ExpTrace.Entity, math.Clamp((Damage/traces)*(Pen/DTGetArmor(ExpTrace.Entity, "HE", Caliber)),0,DTGetArmor(ExpTrace.Entity, "HE", Caliber)*2),self,true)
						end
					end
				end
				local EffArmor = (DTGetArmor(ExpTrace.Entity, "HE", Caliber)/math.abs(ExpTraceLine.HitNormal:Dot(Direction)))
				if ExpTrace.Entity.IsComposite == 1 then
					if ExpTrace.Entity.EntityMods.CompKEMult == nil then ExpTrace.Entity.EntityMods.CompKEMult = 9.2 end 
					if ExpTrace.Entity.EntityMods.CompCEMult == nil then ExpTrace.Entity.EntityMods.CompCEMult = 18.4 end
					EffArmor = (ExpTrace.Entity:GetPhysicsObject():GetVolume()^(1/3))*ExpTrace.Entity.EntityMods.CompCEMult--DTCompositesTrace( ExpTrace.Entity, ExpTrace.HitPos, ExpTrace.Normal, Filter )*ExpTrace.Entity.EntityMods.CompKEMult
				end
				if EffArmor < Pen and ExpTrace.Entity.IsDakTekFutureTech == nil then
					util.Decal( "Impact.Concrete", ExpTrace.HitPos+(Direction*5), ExpTrace.HitPos-(Direction*5), self)
					Filter[#Filter+1] = IgnoreEnt
					self:ContEXP(Filter,ExpTrace.Entity,Pos,Damage*(1-EffArmor/Pen),Radius,Caliber,Pen-EffArmor,Owner,Direction)
				end
				if ExpTrace.Entity.DakHealth <= 0 and ExpTrace.Entity.DakPooled==0 then
					if ExpTrace.Entity:GetClass()=="dak_crew" then
						if ExpTrace.Entity.DakHealth <= 0 then
							for blood=1, 15 do
								util.Decal( "Blood", ExpTrace.Entity:GetPos(), ExpTrace.Entity:GetPos()+(VectorRand()*500), ExpTrace.Entity)
							end
						end
					end
					Filter[#Filter+1] = ExpTrace.Entity
					local salvage = ents.Create( "dak_tesalvage" )
					self.salvage = salvage
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
						--local body = ents.Create( "prop_ragdoll" )
						body:SetPos( ExpTrace.Entity:GetPos() )
						body:SetModel( ExpTrace.Entity:GetModel() )
						body:Spawn()
						body.DakHealth=1000000
						body.DakMaxHealth=1000000
						--ExpTrace.Entity:Remove()
						local SoundList = {"npc/metropolice/die1.wav","npc/metropolice/die2.wav","npc/metropolice/die3.wav","npc/metropolice/die4.wav","npc/metropolice/pain4.wav"}
						body:EmitSound( SoundList[math.random(5)], 100, 100, 1, 2 )
						timer.Simple( 5, function()
							body:Remove()
						end )
					end
				else
					local Pain = DamageInfo()
					Pain:SetDamageForce( Direction*(Damage/traces)*5000*2 )
					Pain:SetDamage( (Damage/traces)*500 )
					if Owner:IsPlayer() then
						Pain:SetAttacker( Owner )
					else
						Pain:SetAttacker( game.GetWorld() )
					end
					if self and Shell and Shell.DakGun then
						Pain:SetAttacker( self )
						Pain:SetInflictor( Shell.DakGun )
					else
						Pain:SetAttacker( game.GetWorld() )
						Pain:SetInflictor( game.GetWorld() )
					end
					Pain:SetReportedPosition( Shell.DakGun:GetPos() )
					Pain:SetDamagePosition( ExpTrace.Entity:GetPos() )
					Pain:SetDamageType(DMG_BLAST)
					ExpTrace.Entity:TakeDamageInfo( Pain )
				end
			end
		end	
	end
end