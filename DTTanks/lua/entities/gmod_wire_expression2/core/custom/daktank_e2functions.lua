E2Lib.RegisterExtension("daktank",true)

-- E2 Functions
__e2setcost(1)
e2function number entity:dakArmor()
	if not IsValid(this) then return end

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
		if SA == -1 then
			this.DakArmor = this:OBBMaxs().x/2
			this.DakIsTread = 1
		else
			if this:GetClass()=="prop_physics" then 
				if not(this.DakArmor == 7.8125*(this:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
					this.DakArmor = 7.8125*(this:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
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

e2function number entity:dakHealth()
	if not IsValid(this) then return end
	if this.DakArmor == nil then
		DakTekTankEditionSetupNewEnt(this)
	end
	if this.DakHealth == nil then
		return 0
	else
		return this.DakHealth
	end
end

e2function number entity:dakMaxHealth()
	if not IsValid(this) then return end
	if this.DakArmor == nil then
		DakTekTankEditionSetupNewEnt(this)
	end
	if this.DakMaxHealth == nil then
		return 0
	else
		return this.DakMaxHealth
	end
end