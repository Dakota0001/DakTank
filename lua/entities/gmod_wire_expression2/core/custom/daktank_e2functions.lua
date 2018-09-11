E2Lib.RegisterExtension("daktank",true)

-- E2 Functions
__e2setcost(1)
e2function number entity:daktankArmor()
	if not IsValid(this) then return 0 end
	if this.IsWorld() then return 0 end

	if this.DakArmor == nil then
		DakTekTankEditionSetupNewEnt(this)
	end
	local SA = -1
	if IsValid(this:GetPhysicsObject()) then
		SA = this:GetPhysicsObject():GetSurfaceArea()
	end
	if this.IsDakTekFutureTech == 1 then
		this.DakArmor = 1000
	else
		if SA == -1 or SA == nil then
			this.DakArmor = this:OBBMaxs().x/2
			this.DakIsTread = 1
		else
			if this:GetClass()=="prop_physics" then 
				if not(this.DakArmor == 7.8125*(this:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - this.DakBurnStacks*0.25) then
					this.DakArmor = 7.8125*(this:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - this.DakBurnStacks*0.25
				end
			end
		end
	end
	if this.DakArmor == nil then
		return 1
	else
		return this.DakArmor
	end
end

e2function number entity:daktankHealth()
	if not IsValid(this) then return 0 end

	if this.DakArmor == nil then
		DakTekTankEditionSetupNewEnt(this)
	end

	if this.DakHealth == nil then
		return 1
	else
		return this.DakHealth
	end
end

e2function number entity:daktankMaxHealth()
	if not IsValid(this) then return 0 end

	if this.DakArmor == nil then
		DakTekTankEditionSetupNewEnt(this)
	end

	if this.DakMaxHealth == nil then
		return 1
	else
		return this.DakMaxHealth
	end
end

e2function string entity:daktankGetName()
	if not IsValid(this) then return "" end

	if this.DakName == nil then
		return ""
	else
		return this.DakName
	end
end

e2function string entity:daktankGetAmmoType()
	if not IsValid(this) then return "" end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.DakName == nil then
			return ""
		else
			if this.DakName == "Flamethrower" then
				return "Fuel"
			else
				if this.CurrentAmmoType == 1 then
					return "AP"
				end
				if this.CurrentAmmoType == 2 then
					return "HE"
				end
				if this.CurrentAmmoType == 3 then
					return "HEAT"
				end
				if this.CurrentAmmoType == 4 then
					return "HVAP"
				end
				if this.CurrentAmmoType == 5 then
					return "HESH"
				end
				if this.CurrentAmmoType == 6 then
					return "ATGM"
				end
			end
		end
	else
		return ""
	end
end

e2function number entity:daktankGetCooldownPerc()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_temachinegun" then
		if this.LastFireTime == nil or this.DakCooldown == nil then
			return 1
		else
			return 100*(math.Clamp((this.LastFireTime+this.DakCooldown)-CurTime(),0,100)/this.DakCooldown)
		end
	end
	if this:GetClass() == "dak_teautogun" then
		if this.LastFireTime == nil or this.DakCooldown == nil or this.DakLastReload == nil or this.DakReloadTime == nil then
			return 1
		else
			if this.DakIsReloading == 0 then
				return 100*(math.Clamp((this.LastFireTime+this.DakCooldown)-CurTime(),0,100)/this.DakCooldown)
			else
				return 100*(math.Clamp((this.DakLastReload+this.DakReloadTime)-CurTime(),0,100)/this.DakReloadTime)
			end
		end
	end
	return 0
end

e2function number entity:daktankGetAmmoCount()
	if not IsValid(this) then return 1 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.AmmoCount == nil then
			return 1
		else
			return this.AmmoCount
		end
	end
	return 1
end

e2function number entity:daktankGetShellPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.DakShellPenetration == nil then
			return 1
		else
			return this.DakShellPenetration
		end
	end
	return 0
end

e2function number entity:daktankGetShellVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.DakShellVelocity == nil then
			return 1
		else
			return this.DakShellVelocity
		end
	end
	return 0
end

e2function number entity:daktankGetShellMass()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.DakShellMass == nil then
			return 1
		else
			return this.DakShellMass
		end
	end
	return 0
end

e2function number entity:daktankGetShellDamage()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.DakShellDamage == nil then
			return 1
		else
			return this.DakShellDamage
		end
	end
	return 0
end

e2function number entity:daktankGetAPPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellPenetration == nil then
			return 1
		else
			return this.BaseDakShellPenetration
		end
	end
	return 0
end

e2function number entity:daktankGetHVAPPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellPenetration == nil then
			return 1
		else
			return this.BaseDakShellPenetration*1.5
		end
	end
	return 0
end

e2function number entity:daktankGetHEATPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellPenetration == nil then
			return 1
		else
			return this.DakMaxHealth*1.20
		end
	end
	return 0
end

e2function number entity:daktankGetHESHPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellPenetration == nil then
			return 1
		else
			return this.DakMaxHealth*1.25
		end
	end
	return 0
end

e2function number entity:daktankGetHEPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellPenetration == nil then
			return 1
		else
			return this.BaseDakShellPenetration*0.3
		end
	end
	return 0
end

e2function number entity:daktankGetHEFragPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.DakShellFragPen == nil then
			return 1
		else
			return this.DakShellFragPen
		end
	end
	return 0
end

e2function number entity:daktankGetAPDamage()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellDamage == nil then
			return 1
		else
			return this.BaseDakShellDamage
		end
	end
	return 0
end

e2function number entity:daktankGetHVAPDamage()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellDamage == nil then
			return 1
		else
			return this.BaseDakShellDamage/8
		end
	end
	return 0
end

e2function number entity:daktankGetHEATDamage()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellDamage == nil then
			return 1
		else
			return this.BaseDakShellDamage/8
		end
	end
	return 0
end

e2function number entity:daktankGetHESHDamage()
	return 0
end

e2function number entity:daktankGetHEDamage()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellDamage == nil or this.DakShellSplashDamage == nil then
			return 1
		else
			return (this.BaseDakShellDamage/2) + this.DakShellSplashDamage
		end
	end
	return 0
end

e2function number entity:daktankGetAPVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellVelocity == nil then
			return 1
		else
			return this.BaseDakShellVelocity
		end
	end
	return 0
end

e2function number entity:daktankGetHVAPVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellVelocity == nil then
			return 1
		else
			return this.BaseDakShellVelocity*4/3
		end
	end
	return 0
end

e2function number entity:daktankGetHEVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellVelocity == nil then
			return 1
		else
			return this.BaseDakShellVelocity
		end
	end
	return 0
end

e2function number entity:daktankGetHEATVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellVelocity == nil then
			return 1
		else
			return this.BaseDakShellVelocity*0.75
		end
	end
	return 0
end

e2function number entity:daktankGetHESHVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		if this.BaseDakShellVelocity == nil then
			return 1
		else
			return this.BaseDakShellVelocity*0.5
		end
	end
	return 0
end