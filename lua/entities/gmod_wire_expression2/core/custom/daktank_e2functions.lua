E2Lib.RegisterExtension("daktank",true)

-- E2 Functions
__e2setcost(1)
e2function number entity:daktankArmor()
	if not IsValid(this) then return 0 end

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
		return 0
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
		return 0
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
		return 0
	else
		return this.DakMaxHealth
	end
end

e2function string entity:daktankGetName()
	if not IsValid(this) then return "" end

	return this.DakName
end

e2function string entity:daktankGetAmmoType()
	if not IsValid(this) then return "" end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then

		if this.DakName == "Flamethrower" then
			return "Fuel"
		else
			if this.CurrentAmmoType == 1 then
				return "Armor Piercing"
			end
			if this.CurrentAmmoType == 2 then
				return "High Explosive"
			end
			if this.CurrentAmmoType == 3 then
				return "Flechette"
			end
		end
	end
end

e2function number entity:daktankGetCooldownPerc()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_temachinegun" then
		return 100*(math.Clamp((this.LastFireTime+this.DakCooldown)-CurTime(),0,100)/this.DakCooldown)
	end
	if this:GetClass() == "dak_teautogun" then
		if this.DakIsReloading == 0 then
			return 100*(math.Clamp((this.LastFireTime+this.DakCooldown)-CurTime(),0,100)/this.DakCooldown)
		else
			return 100*(math.Clamp((this.DakLastReload+this.DakReloadTime)-CurTime(),0,100)/this.DakReloadTime)
		end
	end

end

e2function number entity:daktankGetAmmoCount()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		return this.AmmoCount
	end
end

e2function number entity:daktankGetShellPenetration()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		return this.DakShellPenetration
	end
end

e2function number entity:daktankGetShellVelocity()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		return this.DakShellVelocity
	end
end

e2function number entity:daktankGetShellMass()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		return this.DakShellMass
	end
end

e2function number entity:daktankGetShellDamage()
	if not IsValid(this) then return 0 end

	if this:GetClass() == "dak_tegun" or this:GetClass() == "dak_teautogun" or this:GetClass() == "dak_temachinegun" then
		return this.DakShellDamage
	end
end