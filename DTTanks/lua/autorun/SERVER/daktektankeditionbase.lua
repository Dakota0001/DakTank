if SERVER then
	hook.Add( "InitPostEntity", "DakTekTankEditionRunOnLoadHook", function()
		local Settings = physenv.GetPerformanceSettings() // copy table from physenfv
		Settings.MaxVelocity = 1000000 // change max velocity
		physenv.SetPerformanceSettings(Settings) // push max velocity back into engine.
		print("DakTekTankEditionLoaded")
	end)

	DakTekEntList = {} --Create Entity list for storing things people spawn
	--Setup global daktek function for setting up affected entities.
	function DakTekTankEditionSetupNewEnt(ent)
		if IsValid(ent) and not (string.Explode("_",ent:GetClass(),false)[1] == "dak") then --make sure its not daktek stuff
	 		--setup values
	 		if ent.IsDakTekFutureTech == nil then
	 			if IsValid(ent:GetPhysicsObject()) then
			 		ent.DakHealth = ent:GetPhysicsObject():GetMass()/20
			 	else
			 		ent.DakHealth = 100000000000000000000
			 	end
		 		ent.DakRed = ent:GetColor().r
				ent.DakGreen = ent:GetColor().g
				ent.DakBlue = ent:GetColor().b
				ent.DakName = "Armor"
				if IsValid(ent:GetPhysicsObject()) then
			 		ent.DakMaxHealth = ent:GetPhysicsObject():GetMass()/20
		 		else
			 		ent.DakMaxHealth = 100000000000000000000
			 	end
		 		--DakTekEntList[ ent:EntIndex() ] = ent -- add to list
		 		ent.DakPooled = 0
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
		 					ent.DakArmor = 7.8125*(ent:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
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
			--exceptions for bots
			if ent:GetClass()=="dak_bot" then
				--ent.DakHealth = ent:GetPhysicsObject():GetMass()/20
				ent.DakHealth = 10
		 		ent.DakRed = ent:GetColor().r
				ent.DakGreen = ent:GetColor().g
				ent.DakBlue = ent:GetColor().b
				ent.DakName = "Armor"
				ent.DakMaxHealth = 10
		 		--ent.DakMaxHealth = ent:GetPhysicsObject():GetMass()/20
		 		--DakTekEntList[ ent:EntIndex() ] = ent -- add to list
		 		ent.DakPooled = 0
		 		ent.DakArmor = 10
			end
		end
	end
end
