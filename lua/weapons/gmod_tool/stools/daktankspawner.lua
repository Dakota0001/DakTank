TOOL.Category = "DakTek Tank Edition"
TOOL.Name = "#Tool.daktankspawner.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
if CLIENT then
	language.Add( "Tool.daktankspawner.listname", "DakTek Tank Edition Spawner" )
	language.Add( "Tool.daktankspawner.name", "DakTek Tank Edition Spawner" )
	language.Add( "Tool.daktankspawner.desc", "Spawns DakTek Tank Edition entities." )
	language.Add( "Tool.daktankspawner.0", "Left click to spawn or update valid entities. Right click to check health of target. Reload to get contraption total mass." )
end
TOOL.ClientConVar[ "SpawnEnt" ] 	   = ""
TOOL.ClientConVar[ "SpawnSettings" ]   = ""
TOOL.ClientConVar[ "DTTE_GunCaliber" ] = 5
TOOL.ClientConVar[ "DTTE_AmmoType" ]   = ""

--setup info requirements
TOOL.DakName 		= "Base Ammo Gun"
TOOL.DakHealth 		= 1
TOOL.DakMaxHealth 	= 1
TOOL.DakAmmo 		= 0
TOOL.DakMaxAmmo 	= 10
TOOL.DakModel 		= "models/daktanks/cannon25mm.mdl"
TOOL.DakAmmoType 	= "AC2Ammo"
TOOL.DakIsExplosive = false
TOOL.DakSound 		= "npc/combine_gunship/engine_whine_loop1.wav"

--Main spawning function, creates entities based on the options selected in the menu and updates current entities
function TOOL:LeftClick( trace )
	if SERVER then
		if not(trace.Entity:GetClass() == self:GetClientInfo("SpawnEnt")) and not(trace.Entity:GetClass() == "dak_gun") and not(trace.Entity:GetClass() == "dak_laser") and not(trace.Entity:GetClass() == "dak_xpulselaser") and not(trace.Entity:GetClass() == "dak_launcher") and not(trace.Entity:GetClass() == "dak_lams") and not(trace.Entity:GetClass() == "dak_tegun") and not(trace.Entity:GetClass() == "dak_teautogun") and not(trace.Entity:GetClass() == "dak_temachinegun") then
			local Target = trace.HitPos
			local spawnent = self:GetClientInfo("SpawnEnt")
			self.spawnedent = ents.Create(spawnent)
			if ( !IsValid( self.spawnedent ) ) then return end
			self.spawnedent:SetPos(Target+Vector(0,0,2*self.spawnedent:OBBMins().z))
			self.spawnedent:SetAngles( Angle(0,0,0))
		end
		if (trace.Entity:GetClass() == "dak_gun") or (trace.Entity:GetClass() == "dak_laser") or (trace.Entity:GetClass() == "dak_xpulselaser") or (trace.Entity:GetClass() == "dak_launcher") or (trace.Entity:GetClass() == "dak_lams") or (trace.Entity:GetClass() == "dak_tegun") or (trace.Entity:GetClass() == "dak_teautogun") or (trace.Entity:GetClass() == "dak_temachinegun") then
			if (self:GetClientInfo("SpawnEnt") == "dak_gun") or (self:GetClientInfo("SpawnEnt") == "dak_laser") or (self:GetClientInfo("SpawnEnt") == "dak_xpulselaser") or (self:GetClientInfo("SpawnEnt") == "dak_launcher") or (self:GetClientInfo("SpawnEnt") == "dak_lams") or (self:GetClientInfo("SpawnEnt") == "dak_tegun") or (self:GetClientInfo("SpawnEnt") == "dak_teautogun")or (self:GetClientInfo("SpawnEnt") == "dak_temachinegun") then
				local Target = trace.HitPos
				local spawnent = self:GetClientInfo("SpawnEnt")
				self.spawnedent = ents.Create(spawnent)
				if ( !IsValid( self.spawnedent ) ) then return end
				self.spawnedent:SetPos(trace.Entity:GetPos())
				self.spawnedent:SetAngles(trace.Entity:GetAngles())		
				if trace.Entity:GetParent():IsValid() then
					self.spawnedent:SetMoveType(MOVETYPE_NONE)
					self.spawnedent:SetParent(trace.Entity:GetParent())
				end
			end
		end
	--MOBILITY--
	    --Turret
		if self:GetClientInfo("SpawnSettings") == "STMotor" then
			self.DakMaxHealth = 10
			self.DakHealth = 10
			self.DakName = "Small Turret Motor"
			self.DakModel = "models/xqm/hydcontrolbox.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "MTMotor" then
			self.DakMaxHealth = 20
			self.DakHealth = 20
			self.DakName = "Medium Turret Motor"
			self.DakModel = "models/props_c17/utilityconducter001.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "LTMotor" then 
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Large Turret Motor"
			self.DakModel = "models/props_c17/substation_transformer01d.mdl"
		end
		--Fuel
		if self:GetClientInfo("SpawnSettings") == "MicroFuel" then
			self.DakMaxHealth = 10
			self.DakHealth = 10
			self.DakName = "Micro Fuel Tank"
			self.DakModel = "models/daktanks/fueltank1.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "SmallFuel" then
			self.DakMaxHealth = 20
			self.DakHealth = 20
			self.DakName = "Small Fuel Tank"
			self.DakModel = "models/daktanks/fueltank2.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "StandardFuel" then
			self.DakMaxHealth = 30
			self.DakHealth = 30
			self.DakName = "Standard Fuel Tank"
			self.DakModel = "models/daktanks/fueltank3.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "LargeFuel" then
			self.DakMaxHealth = 40
			self.DakHealth = 40
			self.DakName = "Large Fuel Tank"
			self.DakModel = "models/daktanks/fueltank4.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "HugeFuel" then
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Huge Fuel Tank"
			self.DakModel = "models/daktanks/fueltank5.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "UltraFuel" then
			self.DakMaxHealth = 60
			self.DakHealth = 60
			self.DakName = "Ultra Fuel Tank"
			self.DakModel = "models/daktanks/fueltank6.mdl"
		end
		--Engines
		if self:GetClientInfo("SpawnSettings") == "MicroEngine" then
			self.DakName = "Micro Engine"
			self.DakHealth = 15
			self.DakMaxHealth = 15
			self.DakModel = "models/daktanks/engine1.mdl"
			self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "SmallEngine" then
			self.DakName = "Small Engine"
			self.DakHealth = 30
			self.DakMaxHealth = 30
			self.DakModel = "models/daktanks/engine2.mdl"
			self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "StandardEngine" then
			self.DakName = "Standard Engine"
			self.DakHealth = 45
			self.DakMaxHealth = 45
			self.DakModel = "models/daktanks/engine3.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_idle_loop1.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "LargeEngine" then
			self.DakName = "Large Engine"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakModel = "models/daktanks/engine4.mdl"
			self.DakSound = "vehicles/crane/crane_idle_loop3.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "HugeEngine" then
			self.DakName = "Huge Engine"
			self.DakHealth = 75
			self.DakMaxHealth = 75
			self.DakModel = "models/daktanks/engine5.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "UltraEngine" then
			self.DakName = "Ultra Engine"
			self.DakHealth = 90
			self.DakMaxHealth = 90
			self.DakModel = "models/daktanks/engine6.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
		end
		--GEARBOXES
		if self:GetClientInfo("SpawnSettings") == "MicroGearboxF" then
			self.DakName = "Micro Frontal Mount Gearbox"
			self.DakHealth = 15
			self.DakMaxHealth = 15
			self.DakModel = "models/daktanks/gearbox1f1.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "SmallGearboxF" then
			self.DakName = "Small Frontal Mount Gearbox"
			self.DakHealth = 35
			self.DakMaxHealth = 35
			self.DakModel = "models/daktanks/gearbox1f2.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "StandardGearboxF" then
			self.DakName = "Standard Frontal Mount Gearbox"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakModel = "models/daktanks/gearbox1f3.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "LargeGearboxF" then
			self.DakName = "Large Frontal Mount Gearbox"
			self.DakHealth = 95
			self.DakMaxHealth = 95
			self.DakModel = "models/daktanks/gearbox1f4.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "HugeGearboxF" then
			self.DakName = "Huge Frontal Mount Gearbox"
			self.DakHealth = 140
			self.DakMaxHealth = 140
			self.DakModel = "models/daktanks/gearbox1f5.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "UltraGearboxF" then
			self.DakName = "Ultra Frontal Mount Gearbox"
			self.DakHealth = 250
			self.DakMaxHealth = 250
			self.DakModel = "models/daktanks/gearbox1f6.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "MicroGearboxR" then
			self.DakName = "Micro Rear Mount Gearbox"
			self.DakHealth = 15
			self.DakMaxHealth = 15
			self.DakModel = "models/daktanks/gearbox1r1.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "SmallGearboxR" then
			self.DakName = "Small Rear Mount Gearbox"
			self.DakHealth = 35
			self.DakMaxHealth = 35
			self.DakModel = "models/daktanks/gearbox1r2.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "StandardGearboxR" then
			self.DakName = "Standard Rear Mount Gearbox"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakModel = "models/daktanks/gearbox1r3.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "LargeGearboxR" then
			self.DakName = "Large Rear Mount Gearbox"
			self.DakHealth = 95
			self.DakMaxHealth = 95
			self.DakModel = "models/daktanks/gearbox1r4.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "HugeGearboxR" then
			self.DakName = "Huge Rear Mount Gearbox"
			self.DakHealth = 140
			self.DakMaxHealth = 140
			self.DakModel = "models/daktanks/gearbox1r5.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "UltraGearboxR" then
			self.DakName = "Ultra Rear Mount Gearbox"
			self.DakHealth = 250
			self.DakMaxHealth = 250
			self.DakModel = "models/daktanks/gearbox1r6.mdl"
		end
		--CLIPS--
		if self:GetClientInfo("SpawnSettings") == "SALMagazine" then
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Small Autoloader Magazine"
			self.DakModel = "models/daktanks/alclip1.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "MALMagazine" then
			self.DakMaxHealth = 75
			self.DakHealth = 75
			self.DakName = "Medium Autoloader Magazine"
			self.DakModel = "models/daktanks/alclip2.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "LALMagazine" then
			self.DakMaxHealth = 100
			self.DakHealth = 100
			self.DakName = "Large Autoloader Magazine"
			self.DakModel = "models/daktanks/alclip3.mdl"
		end
		--GUNS--
		if self:GetClientInfo("SpawnSettings") == "Cannon" then
			self.DakGunType = "Cannon"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Cannon"
			if self.DakCaliber < 32 then
				self.DakModel = "models/daktanks/cannon25mm.mdl"
			end
			if self.DakCaliber >= 32 and self.DakCaliber < 39 then
				self.DakModel = "models/daktanks/cannon32mm.mdl"
			end
			if self.DakCaliber >= 39 and self.DakCaliber < 46 then
				self.DakModel = "models/daktanks/cannon39mm.mdl"
			end
			if self.DakCaliber >= 46 and self.DakCaliber < 53 then
				self.DakModel = "models/daktanks/cannon46mm.mdl"
			end
			if self.DakCaliber >= 53 and self.DakCaliber < 60 then
				self.DakModel = "models/daktanks/cannon53mm.mdl"
			end
			if self.DakCaliber >= 60 and self.DakCaliber < 67 then
				self.DakModel = "models/daktanks/cannon60mm.mdl"
			end
			if self.DakCaliber >= 67 and self.DakCaliber < 74 then
				self.DakModel = "models/daktanks/cannon67mm.mdl"
			end
			if self.DakCaliber >= 74 and self.DakCaliber < 81 then
				self.DakModel = "models/daktanks/cannon74mm.mdl"
			end
			if self.DakCaliber >= 81 and self.DakCaliber < 88 then
				self.DakModel = "models/daktanks/cannon81mm.mdl"
			end
			if self.DakCaliber >= 88 and self.DakCaliber < 95 then
				self.DakModel = "models/daktanks/cannon88mm.mdl"
			end
			if self.DakCaliber >= 95 and self.DakCaliber < 102 then
				self.DakModel = "models/daktanks/cannon95mm.mdl"
			end
			if self.DakCaliber >= 102 and self.DakCaliber < 109 then
				self.DakModel = "models/daktanks/cannon102mm.mdl"
			end
			if self.DakCaliber >= 109 and self.DakCaliber < 116 then
				self.DakModel = "models/daktanks/cannon109mm.mdl"
			end
			if self.DakCaliber >= 116 and self.DakCaliber < 123 then
				self.DakModel = "models/daktanks/cannon116mm.mdl"
			end
			if self.DakCaliber >= 123 and self.DakCaliber < 130 then
				self.DakModel = "models/daktanks/cannon123mm.mdl"
			end
			if self.DakCaliber >= 130 and self.DakCaliber < 137 then
				self.DakModel = "models/daktanks/cannon130mm.mdl"
			end
			if self.DakCaliber >= 137 and self.DakCaliber < 144 then
				self.DakModel = "models/daktanks/cannon137mm.mdl"
			end
			if self.DakCaliber >= 144 and self.DakCaliber < 151 then
				self.DakModel = "models/daktanks/cannon144mm.mdl"
			end
			if self.DakCaliber >= 151 and self.DakCaliber < 158 then
				self.DakModel = "models/daktanks/cannon151mm.mdl"
			end
			if self.DakCaliber >= 158 and self.DakCaliber < 165 then
				self.DakModel = "models/daktanks/cannon158mm.mdl"
			end
			if self.DakCaliber >= 165 and self.DakCaliber < 172 then
				self.DakModel = "models/daktanks/cannon165mm.mdl"
			end
			if self.DakCaliber >= 172 and self.DakCaliber < 179 then
				self.DakModel = "models/daktanks/cannon172mm.mdl"
			end
			if self.DakCaliber >= 179 and self.DakCaliber < 186 then
				self.DakModel = "models/daktanks/cannon179mm.mdl"
			end
			if self.DakCaliber >= 186 and self.DakCaliber < 193 then
				self.DakModel = "models/daktanks/cannon186mm.mdl"
			end
			if self.DakCaliber >= 193 and self.DakCaliber < 200 then
				self.DakModel = "models/daktanks/cannon193mm.mdl"
			end
			if self.DakCaliber >= 200 then
				self.DakModel = "models/daktanks/cannon200mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Long Cannon" then
			self.DakGunType = "Long Cannon"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Long Cannon"
			if self.DakCaliber < 32 then
				self.DakModel = "models/daktanks/lcannon25mm.mdl"
			end
			if self.DakCaliber >= 32 and self.DakCaliber < 39 then
				self.DakModel = "models/daktanks/lcannon32mm.mdl"
			end
			if self.DakCaliber >= 39 and self.DakCaliber < 46 then
				self.DakModel = "models/daktanks/lcannon39mm.mdl"
			end
			if self.DakCaliber >= 46 and self.DakCaliber < 53 then
				self.DakModel = "models/daktanks/lcannon46mm.mdl"
			end
			if self.DakCaliber >= 53 and self.DakCaliber < 60 then
				self.DakModel = "models/daktanks/lcannon53mm.mdl"
			end
			if self.DakCaliber >= 60 and self.DakCaliber < 67 then
				self.DakModel = "models/daktanks/lcannon60mm.mdl"
			end
			if self.DakCaliber >= 67 and self.DakCaliber < 74 then
				self.DakModel = "models/daktanks/lcannon67mm.mdl"
			end
			if self.DakCaliber >= 74 and self.DakCaliber < 81 then
				self.DakModel = "models/daktanks/lcannon74mm.mdl"
			end
			if self.DakCaliber >= 81 and self.DakCaliber < 88 then
				self.DakModel = "models/daktanks/lcannon81mm.mdl"
			end
			if self.DakCaliber >= 88 and self.DakCaliber < 95 then
				self.DakModel = "models/daktanks/lcannon88mm.mdl"
			end
			if self.DakCaliber >= 95 and self.DakCaliber < 102 then
				self.DakModel = "models/daktanks/lcannon95mm.mdl"
			end
			if self.DakCaliber >= 102 and self.DakCaliber < 109 then
				self.DakModel = "models/daktanks/lcannon102mm.mdl"
			end
			if self.DakCaliber >= 109 and self.DakCaliber < 116 then
				self.DakModel = "models/daktanks/lcannon109mm.mdl"
			end
			if self.DakCaliber >= 116 and self.DakCaliber < 123 then
				self.DakModel = "models/daktanks/lcannon116mm.mdl"
			end
			if self.DakCaliber >= 123 and self.DakCaliber < 130 then
				self.DakModel = "models/daktanks/lcannon123mm.mdl"
			end
			if self.DakCaliber >= 130 and self.DakCaliber < 137 then
				self.DakModel = "models/daktanks/lcannon130mm.mdl"
			end
			if self.DakCaliber >= 137 and self.DakCaliber < 144 then
				self.DakModel = "models/daktanks/lcannon137mm.mdl"
			end
			if self.DakCaliber >= 144 and self.DakCaliber < 151 then
				self.DakModel = "models/daktanks/lcannon144mm.mdl"
			end
			if self.DakCaliber >= 151 and self.DakCaliber < 158 then
				self.DakModel = "models/daktanks/lcannon151mm.mdl"
			end
			if self.DakCaliber >= 158 and self.DakCaliber < 165 then
				self.DakModel = "models/daktanks/lcannon158mm.mdl"
			end
			if self.DakCaliber >= 165 and self.DakCaliber < 172 then
				self.DakModel = "models/daktanks/lcannon165mm.mdl"
			end
			if self.DakCaliber >= 172 and self.DakCaliber < 179 then
				self.DakModel = "models/daktanks/lcannon172mm.mdl"
			end
			if self.DakCaliber >= 179 and self.DakCaliber < 186 then
				self.DakModel = "models/daktanks/lcannon179mm.mdl"
			end
			if self.DakCaliber >= 186 and self.DakCaliber < 193 then
				self.DakModel = "models/daktanks/lcannon186mm.mdl"
			end
			if self.DakCaliber >= 193 and self.DakCaliber < 200 then
				self.DakModel = "models/daktanks/lcannon193mm.mdl"
			end
			if self.DakCaliber >= 200 then
				self.DakModel = "models/daktanks/lcannon200mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Short Cannon" then
			self.DakGunType = "Short Cannon"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Short Cannon"
			if self.DakCaliber < 32 then
				self.DakModel = "models/daktanks/scannon25mm.mdl"
			end
			if self.DakCaliber >= 32 and self.DakCaliber < 39 then
				self.DakModel = "models/daktanks/scannon32mm.mdl"
			end
			if self.DakCaliber >= 39 and self.DakCaliber < 46 then
				self.DakModel = "models/daktanks/scannon39mm.mdl"
			end
			if self.DakCaliber >= 46 and self.DakCaliber < 53 then
				self.DakModel = "models/daktanks/scannon46mm.mdl"
			end
			if self.DakCaliber >= 53 and self.DakCaliber < 60 then
				self.DakModel = "models/daktanks/scannon53mm.mdl"
			end
			if self.DakCaliber >= 60 and self.DakCaliber < 67 then
				self.DakModel = "models/daktanks/scannon60mm.mdl"
			end
			if self.DakCaliber >= 67 and self.DakCaliber < 74 then
				self.DakModel = "models/daktanks/scannon67mm.mdl"
			end
			if self.DakCaliber >= 74 and self.DakCaliber < 81 then
				self.DakModel = "models/daktanks/scannon74mm.mdl"
			end
			if self.DakCaliber >= 81 and self.DakCaliber < 88 then
				self.DakModel = "models/daktanks/scannon81mm.mdl"
			end
			if self.DakCaliber >= 88 and self.DakCaliber < 95 then
				self.DakModel = "models/daktanks/scannon88mm.mdl"
			end
			if self.DakCaliber >= 95 and self.DakCaliber < 102 then
				self.DakModel = "models/daktanks/scannon95mm.mdl"
			end
			if self.DakCaliber >= 102 and self.DakCaliber < 109 then
				self.DakModel = "models/daktanks/scannon102mm.mdl"
			end
			if self.DakCaliber >= 109 and self.DakCaliber < 116 then
				self.DakModel = "models/daktanks/scannon109mm.mdl"
			end
			if self.DakCaliber >= 116 and self.DakCaliber < 123 then
				self.DakModel = "models/daktanks/scannon116mm.mdl"
			end
			if self.DakCaliber >= 123 and self.DakCaliber < 130 then
				self.DakModel = "models/daktanks/scannon123mm.mdl"
			end
			if self.DakCaliber >= 130 and self.DakCaliber < 137 then
				self.DakModel = "models/daktanks/scannon130mm.mdl"
			end
			if self.DakCaliber >= 137 and self.DakCaliber < 144 then
				self.DakModel = "models/daktanks/scannon137mm.mdl"
			end
			if self.DakCaliber >= 144 and self.DakCaliber < 151 then
				self.DakModel = "models/daktanks/scannon144mm.mdl"
			end
			if self.DakCaliber >= 151 and self.DakCaliber < 158 then
				self.DakModel = "models/daktanks/scannon151mm.mdl"
			end
			if self.DakCaliber >= 158 and self.DakCaliber < 165 then
				self.DakModel = "models/daktanks/scannon158mm.mdl"
			end
			if self.DakCaliber >= 165 and self.DakCaliber < 172 then
				self.DakModel = "models/daktanks/scannon165mm.mdl"
			end
			if self.DakCaliber >= 172 and self.DakCaliber < 179 then
				self.DakModel = "models/daktanks/scannon172mm.mdl"
			end
			if self.DakCaliber >= 179 and self.DakCaliber < 186 then
				self.DakModel = "models/daktanks/scannon179mm.mdl"
			end
			if self.DakCaliber >= 186 and self.DakCaliber < 193 then
				self.DakModel = "models/daktanks/scannon186mm.mdl"
			end
			if self.DakCaliber >= 193 and self.DakCaliber < 200 then
				self.DakModel = "models/daktanks/scannon193mm.mdl"
			end
			if self.DakCaliber >= 200 then
				self.DakModel = "models/daktanks/scannon200mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Howitzer" then
			self.DakGunType = "Howitzer"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Howitzer"
			if self.DakCaliber < 58 then
				self.DakModel = "models/daktanks/howitzer50mm.mdl"
			end
			if self.DakCaliber >= 58 and self.DakCaliber < 65 then
				self.DakModel = "models/daktanks/howitzer58mm.mdl"
			end
			if self.DakCaliber >= 65 and self.DakCaliber < 73 then
				self.DakModel = "models/daktanks/howitzer65mm.mdl"
			end
			if self.DakCaliber >= 73 and self.DakCaliber < 80 then
				self.DakModel = "models/daktanks/howitzer73mm.mdl"
			end
			if self.DakCaliber >= 80 and self.DakCaliber < 88 then
				self.DakModel = "models/daktanks/howitzer80mm.mdl"
			end
			if self.DakCaliber >= 88 and self.DakCaliber < 96 then
				self.DakModel = "models/daktanks/howitzer88mm.mdl"
			end
			if self.DakCaliber >= 96 and self.DakCaliber < 103 then
				self.DakModel = "models/daktanks/howitzer96mm.mdl"
			end
			if self.DakCaliber >= 103 and self.DakCaliber < 111 then
				self.DakModel = "models/daktanks/howitzer103mm.mdl"
			end
			if self.DakCaliber >= 111 and self.DakCaliber < 118 then
				self.DakModel = "models/daktanks/howitzer111mm.mdl"
			end
			if self.DakCaliber >= 118 and self.DakCaliber < 126 then
				self.DakModel = "models/daktanks/howitzer118mm.mdl"
			end
			if self.DakCaliber >= 126 and self.DakCaliber < 134 then
				self.DakModel = "models/daktanks/howitzer126mm.mdl"
			end
			if self.DakCaliber >= 134 and self.DakCaliber < 141 then
				self.DakModel = "models/daktanks/howitzer134mm.mdl"
			end
			if self.DakCaliber >= 141 and self.DakCaliber < 149 then
				self.DakModel = "models/daktanks/howitzer141mm.mdl"
			end
			if self.DakCaliber >= 149 and self.DakCaliber < 156 then
				self.DakModel = "models/daktanks/howitzer149mm.mdl"
			end
			if self.DakCaliber >= 156 and self.DakCaliber < 164 then
				self.DakModel = "models/daktanks/howitzer156mm.mdl"
			end
			if self.DakCaliber >= 164 and self.DakCaliber < 172 then
				self.DakModel = "models/daktanks/howitzer164mm.mdl"
			end
			if self.DakCaliber >= 172 and self.DakCaliber < 179 then
				self.DakModel = "models/daktanks/howitzer172mm.mdl"
			end
			if self.DakCaliber >= 179 and self.DakCaliber < 187 then
				self.DakModel = "models/daktanks/howitzer179mm.mdl"
			end
			if self.DakCaliber >= 187 and self.DakCaliber < 194 then
				self.DakModel = "models/daktanks/howitzer187mm.mdl"
			end
			if self.DakCaliber >= 194 and self.DakCaliber < 202 then
				self.DakModel = "models/daktanks/howitzer194mm.mdl"
			end
			if self.DakCaliber >= 202 and self.DakCaliber < 210 then
				self.DakModel = "models/daktanks/howitzer202mm.mdl"
			end
			if self.DakCaliber >= 210 and self.DakCaliber < 217 then
				self.DakModel = "models/daktanks/howitzer210mm.mdl"
			end
			if self.DakCaliber >= 217 and self.DakCaliber < 225 then
				self.DakModel = "models/daktanks/howitzer217mm.mdl"
			end
			if self.DakCaliber >= 225 and self.DakCaliber < 232 then
				self.DakModel = "models/daktanks/howitzer225mm.mdl"
			end
			if self.DakCaliber >= 232 and self.DakCaliber < 240 then
				self.DakModel = "models/daktanks/howitzer232mm.mdl"
			end
			if self.DakCaliber >= 240 then
				self.DakModel = "models/daktanks/howitzer240mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Mortar" then
			self.DakGunType = "Mortar"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Mortar"
			if self.DakCaliber < 48 then
				self.DakModel = "models/daktanks/mortar40mm.mdl"
			end
			if self.DakCaliber >= 48 and self.DakCaliber < 56 then
				self.DakModel = "models/daktanks/mortar48mm.mdl"
			end
			if self.DakCaliber >= 56 and self.DakCaliber < 64 then
				self.DakModel = "models/daktanks/mortar56mm.mdl"
			end
			if self.DakCaliber >= 64 and self.DakCaliber < 72 then
				self.DakModel = "models/daktanks/mortar64mm.mdl"
			end
			if self.DakCaliber >= 72 and self.DakCaliber < 80 then
				self.DakModel = "models/daktanks/mortar72mm.mdl"
			end
			if self.DakCaliber >= 80 and self.DakCaliber < 88 then
				self.DakModel = "models/daktanks/mortar80mm.mdl"
			end
			if self.DakCaliber >= 88 and self.DakCaliber < 96 then
				self.DakModel = "models/daktanks/mortar88mm.mdl"
			end
			if self.DakCaliber >= 96 and self.DakCaliber < 104 then
				self.DakModel = "models/daktanks/mortar96mm.mdl"
			end
			if self.DakCaliber >= 104 and self.DakCaliber < 112 then
				self.DakModel = "models/daktanks/mortar104mm.mdl"
			end
			if self.DakCaliber >= 112 and self.DakCaliber < 120 then
				self.DakModel = "models/daktanks/mortar112mm.mdl"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 128 then
				self.DakModel = "models/daktanks/mortar120mm.mdl"
			end
			if self.DakCaliber >= 128 and self.DakCaliber < 136 then
				self.DakModel = "models/daktanks/mortar128mm.mdl"
			end
			if self.DakCaliber >= 136 and self.DakCaliber < 144 then
				self.DakModel = "models/daktanks/mortar136mm.mdl"
			end
			if self.DakCaliber >= 144 and self.DakCaliber < 152 then
				self.DakModel = "models/daktanks/mortar144mm.mdl"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 160 then
				self.DakModel = "models/daktanks/mortar152mm.mdl"
			end
			if self.DakCaliber >= 160 and self.DakCaliber < 168 then
				self.DakModel = "models/daktanks/mortar160mm.mdl"
			end
			if self.DakCaliber >= 168 and self.DakCaliber < 176 then
				self.DakModel = "models/daktanks/mortar168mm.mdl"
			end
			if self.DakCaliber >= 176 and self.DakCaliber < 184 then
				self.DakModel = "models/daktanks/mortar176mm.mdl"
			end
			if self.DakCaliber >= 184 and self.DakCaliber < 192 then
				self.DakModel = "models/daktanks/mortar184mm.mdl"
			end
			if self.DakCaliber >= 192 and self.DakCaliber < 200 then
				self.DakModel = "models/daktanks/mortar192mm.mdl"
			end
			if self.DakCaliber >= 200 and self.DakCaliber < 208 then
				self.DakModel = "models/daktanks/mortar200mm.mdl"
			end
			if self.DakCaliber >= 208 and self.DakCaliber < 216 then
				self.DakModel = "models/daktanks/mortar208mm.mdl"
			end
			if self.DakCaliber >= 216 and self.DakCaliber < 224 then
				self.DakModel = "models/daktanks/mortar216mm.mdl"
			end
			if self.DakCaliber >= 224 and self.DakCaliber < 232 then
				self.DakModel = "models/daktanks/mortar224mm.mdl"
			end
			if self.DakCaliber >= 232 and self.DakCaliber < 240 then
				self.DakModel = "models/daktanks/mortar232mm.mdl"
			end
			if self.DakCaliber >= 240 and self.DakCaliber < 248 then
				self.DakModel = "models/daktanks/mortar240mm.mdl"
			end
			if self.DakCaliber >= 248 and self.DakCaliber < 256 then
				self.DakModel = "models/daktanks/mortar248mm.mdl"
			end
			if self.DakCaliber >= 256 and self.DakCaliber < 264 then
				self.DakModel = "models/daktanks/mortar256mm.mdl"
			end
			if self.DakCaliber >= 264 and self.DakCaliber < 272 then
				self.DakModel = "models/daktanks/mortar264mm.mdl"
			end
			if self.DakCaliber >= 272 and self.DakCaliber < 280 then
				self.DakModel = "models/daktanks/mortar272mm.mdl"
			end
			if self.DakCaliber >= 280 then
				self.DakModel = "models/daktanks/mortar280mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Autoloader" then
			self.DakGunType = "Autoloader"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),75,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Autoloader"
			if self.DakCaliber < 81 then
				self.DakModel = "models/daktanks/al74mm.mdl"
			end
			if self.DakCaliber >= 81 and self.DakCaliber < 88 then
				self.DakModel = "models/daktanks/al81mm.mdl"
			end
			if self.DakCaliber >= 88 and self.DakCaliber < 95 then
				self.DakModel = "models/daktanks/al88mm.mdl"
			end
			if self.DakCaliber >= 95 and self.DakCaliber < 102 then
				self.DakModel = "models/daktanks/al95mm.mdl"
			end
			if self.DakCaliber >= 102 and self.DakCaliber < 109 then
				self.DakModel = "models/daktanks/al102mm.mdl"
			end
			if self.DakCaliber >= 109 and self.DakCaliber < 116 then
				self.DakModel = "models/daktanks/al109mm.mdl"
			end
			if self.DakCaliber >= 116 and self.DakCaliber < 123 then
				self.DakModel = "models/daktanks/al116mm.mdl"
			end
			if self.DakCaliber >= 123 and self.DakCaliber < 130 then
				self.DakModel = "models/daktanks/al123mm.mdl"
			end
			if self.DakCaliber >= 130 and self.DakCaliber < 137 then
				self.DakModel = "models/daktanks/al130mm.mdl"
			end
			if self.DakCaliber >= 137 and self.DakCaliber < 144 then
				self.DakModel = "models/daktanks/al137mm.mdl"
			end
			if self.DakCaliber >= 144 and self.DakCaliber < 151 then
				self.DakModel = "models/daktanks/al144mm.mdl"
			end
			if self.DakCaliber >= 151 and self.DakCaliber < 158 then
				self.DakModel = "models/daktanks/al151mm.mdl"
			end
			if self.DakCaliber >= 158 and self.DakCaliber < 165 then
				self.DakModel = "models/daktanks/al158mm.mdl"
			end
			if self.DakCaliber >= 165 and self.DakCaliber < 172 then
				self.DakModel = "models/daktanks/al165mm.mdl"
			end
			if self.DakCaliber >= 172 and self.DakCaliber < 179 then
				self.DakModel = "models/daktanks/al172mm.mdl"
			end
			if self.DakCaliber >= 179 and self.DakCaliber < 186 then
				self.DakModel = "models/daktanks/al179mm.mdl"
			end
			if self.DakCaliber >= 186 and self.DakCaliber < 193 then
				self.DakModel = "models/daktanks/al186mm.mdl"
			end
			if self.DakCaliber >= 193 and self.DakCaliber < 200 then
				self.DakModel = "models/daktanks/al193mm.mdl"
			end
			if self.DakCaliber >= 200 then
				self.DakModel = "models/daktanks/al200mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "MG" then
			self.DakGunType = "MG"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Machine Gun"
			if self.DakCaliber < 9 then
				self.DakModel = "models/daktanks/mg5mm.mdl"
			end
			if self.DakCaliber >= 9 and self.DakCaliber < 13 then
				self.DakModel = "models/daktanks/mg9mm.mdl"
			end
			if self.DakCaliber >= 13 and self.DakCaliber < 17 then
				self.DakModel = "models/daktanks/mg13mm.mdl"
			end
			if self.DakCaliber >= 17 and self.DakCaliber < 21 then
				self.DakModel = "models/daktanks/mg17mm.mdl"
			end
			if self.DakCaliber >= 21 and self.DakCaliber < 25 then
				self.DakModel = "models/daktanks/mg21mm.mdl"
			end
			if self.DakCaliber >= 25 then
				self.DakModel = "models/daktanks/mg25mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Flamethrower" then
			self.DakGunType = "Flamethrower"
			self.DakCaliber = 10
			self.DakMaxHealth = 10
			self.DakName = "Flamethrower"
			self.DakModel = "models/daktanks/flamethrower.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "HMG" then
			self.DakGunType = "HMG"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Heavy Machine Gun"
			if self.DakCaliber < 24 then
				self.DakModel = "models/daktanks/hmg20mm.mdl"
			end
			if self.DakCaliber >= 24 and self.DakCaliber < 28 then
				self.DakModel = "models/daktanks/hmg24mm.mdl"
			end
			if self.DakCaliber >= 28 and self.DakCaliber < 32 then
				self.DakModel = "models/daktanks/hmg28mm.mdl"
			end
			if self.DakCaliber >= 32 and self.DakCaliber < 36 then
				self.DakModel = "models/daktanks/hmg32mm.mdl"
			end
			if self.DakCaliber >= 36 and self.DakCaliber < 40 then
				self.DakModel = "models/daktanks/hmg36mm.mdl"
			end
			if self.DakCaliber >= 40 then
				self.DakModel = "models/daktanks/hmg40mm.mdl"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "Autocannon" then
			self.DakGunType = "Autocannon"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Autocannon"
			if self.DakCaliber < 25 then
				self.DakModel = "models/daktanks/ac20mm.mdl"
			end
			if self.DakCaliber >= 25 and self.DakCaliber < 30 then
				self.DakModel = "models/daktanks/ac25mm.mdl"
			end
			if self.DakCaliber >= 30 and self.DakCaliber < 35 then
				self.DakModel = "models/daktanks/ac30mm.mdl"
			end
			if self.DakCaliber >= 35 and self.DakCaliber < 40 then
				self.DakModel = "models/daktanks/ac35mm.mdl"
			end
			if self.DakCaliber >= 40 and self.DakCaliber < 45 then
				self.DakModel = "models/daktanks/ac40mm.mdl"
			end
			if self.DakCaliber >= 45 and self.DakCaliber < 50 then
				self.DakModel = "models/daktanks/ac45mm.mdl"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 55 then
				self.DakModel = "models/daktanks/ac50mm.mdl"
			end
			if self.DakCaliber >= 55 and self.DakCaliber < 60 then
				self.DakModel = "models/daktanks/ac55mm.mdl"
			end
			if self.DakCaliber >= 60 then
				self.DakModel = "models/daktanks/ac60mm.mdl"
			end
		end
		--AMMO--
		--Define variables--
		if self:GetClientInfo("SpawnSettings") == "MicroAPBox" or self:GetClientInfo("SpawnSettings") == "SmallAPBox" or self:GetClientInfo("SpawnSettings") == "StandardAPBox" or self:GetClientInfo("SpawnSettings") == "LargeAPBox" or self:GetClientInfo("SpawnSettings") == "HugeAPBox" or self:GetClientInfo("SpawnSettings") == "UltraAPBox" then
			self.DakIsHE = false
			self.AmmoType = "AP"
		end
		if self:GetClientInfo("SpawnSettings") == "MicroHEBox" or self:GetClientInfo("SpawnSettings") == "SmallHEBox" or self:GetClientInfo("SpawnSettings") == "StandardHEBox" or self:GetClientInfo("SpawnSettings") == "LargeHEBox" or self:GetClientInfo("SpawnSettings") == "HugeHEBox" or self:GetClientInfo("SpawnSettings") == "UltraHEBox" then
			self.DakIsHE = true
			self.AmmoType = "HE"
		end
		if self:GetClientInfo("SpawnSettings") == "MicroHEATBox" or self:GetClientInfo("SpawnSettings") == "SmallHEATBox" or self:GetClientInfo("SpawnSettings") == "StandardHEATBox" or self:GetClientInfo("SpawnSettings") == "LargeHEATBox" or self:GetClientInfo("SpawnSettings") == "HugeHEATBox" or self:GetClientInfo("SpawnSettings") == "UltraHEATBox" then
			self.DakIsHE = true
			self.AmmoType = "HEAT"
		end
		if self:GetClientInfo("SpawnSettings") == "MicroHESHBox" or self:GetClientInfo("SpawnSettings") == "SmallHESHBox" or self:GetClientInfo("SpawnSettings") == "StandardHESHBox" or self:GetClientInfo("SpawnSettings") == "LargeHESHBox" or self:GetClientInfo("SpawnSettings") == "HugeHESHBox" or self:GetClientInfo("SpawnSettings") == "UltraHESHBox" then
			self.DakIsHE = true
			self.AmmoType = "HESH"
		end
		if self:GetClientInfo("SpawnSettings") == "MicroHVAPBox" or self:GetClientInfo("SpawnSettings") == "SmallHVAPBox" or self:GetClientInfo("SpawnSettings") == "StandardHVAPBox" or self:GetClientInfo("SpawnSettings") == "LargeHVAPBox" or self:GetClientInfo("SpawnSettings") == "HugeHVAPBox" or self:GetClientInfo("SpawnSettings") == "UltraHVAPBox" then
			self.DakIsHE = false
			self.AmmoType = "HVAP"
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
			self.GunType = "C"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Long Cannon" then
			self.GunType = "LC"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Short Cannon" then
			self.GunType = "SC"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
			self.GunType = "H"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
			self.GunType = "M"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Autoloader" then
			self.GunType = "C"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),75,200)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
			self.GunType = "AC"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "MG" then
			self.GunType = "MG"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
		end
		if self:GetClientInfo("DTTE_AmmoType") == "HMG" then
			self.GunType = "HMG"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
		end
		--huge if statement that checks to see if its an ammo crate of any type
		if self:GetClientInfo("SpawnSettings") == "MicroAPBox" or self:GetClientInfo("SpawnSettings") == "SmallAPBox" or self:GetClientInfo("SpawnSettings") == "StandardAPBox" or self:GetClientInfo("SpawnSettings") == "LargeAPBox" or self:GetClientInfo("SpawnSettings") == "HugeAPBox" or self:GetClientInfo("SpawnSettings") == "UltraAPBox" or self:GetClientInfo("SpawnSettings") == "MicroHEBox" or self:GetClientInfo("SpawnSettings") == "SmallHEBox" or self:GetClientInfo("SpawnSettings") == "StandardHEBox" or self:GetClientInfo("SpawnSettings") == "LargeHEBox" or self:GetClientInfo("SpawnSettings") == "HugeHEBox" or self:GetClientInfo("SpawnSettings") == "UltraHEBox" or self:GetClientInfo("SpawnSettings") == "MicroHEATBox" or self:GetClientInfo("SpawnSettings") == "SmallHEATBox" or self:GetClientInfo("SpawnSettings") == "StandardHEATBox" or self:GetClientInfo("SpawnSettings") == "LargeHEATBox" or self:GetClientInfo("SpawnSettings") == "HugeHEATBox" or self:GetClientInfo("SpawnSettings") == "UltraHEATBox" or self:GetClientInfo("SpawnSettings") == "MicroHVAPBox" or self:GetClientInfo("SpawnSettings") == "SmallHVAPBox" or self:GetClientInfo("SpawnSettings") == "StandardHVAPBox" or self:GetClientInfo("SpawnSettings") == "LargeHVAPBox" or self:GetClientInfo("SpawnSettings") == "HugeHVAPBox" or self:GetClientInfo("SpawnSettings") == "UltraHVAPBox" or self:GetClientInfo("SpawnSettings") == "MicroHESHBox" or self:GetClientInfo("SpawnSettings") == "SmallHESHBox" or self:GetClientInfo("SpawnSettings") == "StandardHESHBox" or self:GetClientInfo("SpawnSettings") == "LargeHESHBox" or self:GetClientInfo("SpawnSettings") == "HugeHESHBox" or self:GetClientInfo("SpawnSettings") == "UltraHESHBox" then
			self.DakIsExplosive = true
			self.DakAmmoType = self.DakCaliber.."mm"..self.GunType..self.AmmoType.."Ammo"
		end
		--Flamethrower--
		if self:GetClientInfo("SpawnSettings") == "Flamethrower Fuel" then
			self.DakIsHE = true
			self.DakCaliber = 10
			self.DakName = "Flamethrower Fuel Tank"
			self.DakIsExplosive = true
			self.DakAmmo = 150
			self.DakMaxAmmo = 150
			self.DakAmmoType = "Flamethrower Fuel"
			self.spawnedent:SetModel( "models/props_c17/canister_propane01a.mdl" )
		end
		--Guns--
		if self:GetClientInfo("SpawnEnt") == "dak_tegun" or self:GetClientInfo("SpawnEnt") == "dak_teautogun" or self:GetClientInfo("SpawnEnt") == "dak_temachinegun" then
			self.spawnedent.DakOwner = self:GetOwner()
			self.spawnedent.DakGunType = self.DakGunType
			self.spawnedent.DakCaliber = math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2)
			self.spawnedent.DakMaxHealth = self.DakMaxHealth
			self.spawnedent.DakName = self.DakName
			self.spawnedent.DakModel = self.DakModel
			self.spawnedent:SetModel(self.spawnedent.DakModel)
		end
		--
		if self:GetClientInfo("SpawnEnt") == "dak_teammo" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_teammo" then
					trace.Entity.DakName = self.DakAmmoType
					trace.Entity.DakIsExplosive = self.DakIsExplosive
					trace.Entity.DakAmmoType = self.DakAmmoType
					trace.Entity.DakOwner = self:GetOwner()
					trace.Entity.DakIsHE = self.DakIsHE
					self:GetOwner():ChatPrint("Ammo updated.")
				else
					self.spawnedent.DakName = self.DakAmmoType
					self.spawnedent.DakIsExplosive = self.DakIsExplosive
					self.spawnedent.DakAmmoType = self.DakAmmoType
					self.spawnedent.DakOwner = self:GetOwner()
					self.spawnedent.DakIsHE = self.DakIsHE
							--Micro--
					if self:GetClientInfo("SpawnSettings") == "MicroAPBox" or self:GetClientInfo("SpawnSettings") == "MicroHEBox" or self:GetClientInfo("SpawnSettings") == "MicroHEATBox" or self:GetClientInfo("SpawnSettings") == "MicroHVAPBox" or self:GetClientInfo("SpawnSettings") == "MicroHESHBox" then
						self.spawnedent:SetModel( "models/daktanks/ammo1.mdl" )
					end
					--Small--
					if self:GetClientInfo("SpawnSettings") == "SmallAPBox" or self:GetClientInfo("SpawnSettings") == "SmallHEBox" or self:GetClientInfo("SpawnSettings") == "SmallHEATBox" or self:GetClientInfo("SpawnSettings") == "SmallHVAPBox" or self:GetClientInfo("SpawnSettings") == "SmallHESHBox" then
						self.spawnedent:SetModel( "models/daktanks/ammo2.mdl" )
					end
					--Standard--
					if self:GetClientInfo("SpawnSettings") == "StandardAPBox" or self:GetClientInfo("SpawnSettings") == "StandardHEBox" or self:GetClientInfo("SpawnSettings") == "StandardHEATBox" or self:GetClientInfo("SpawnSettings") == "StandardHVAPBox" or self:GetClientInfo("SpawnSettings") == "StandardHESHBox" then
						self.spawnedent:SetModel( "models/daktanks/ammo3.mdl" )
					end
					--Large--
					if self:GetClientInfo("SpawnSettings") == "LargeAPBox" or self:GetClientInfo("SpawnSettings") == "LargeHEBox" or self:GetClientInfo("SpawnSettings") == "LargeHEATBox" or self:GetClientInfo("SpawnSettings") == "LargeHVAPBox" or self:GetClientInfo("SpawnSettings") == "LargeHESHBox" then
						self.spawnedent:SetModel( "models/daktanks/ammo4.mdl" )
					end
					--Huge--
					if self:GetClientInfo("SpawnSettings") == "HugeAPBox" or self:GetClientInfo("SpawnSettings") == "HugeHEBox" or self:GetClientInfo("SpawnSettings") == "HugeHEATBox" or self:GetClientInfo("SpawnSettings") == "HugeHVAPBox" or self:GetClientInfo("SpawnSettings") == "HugeHESHBox" then
						self.spawnedent:SetModel( "models/daktanks/ammo5.mdl" )
					end
					--Ultra--
					if self:GetClientInfo("SpawnSettings") == "UltraAPBox" or self:GetClientInfo("SpawnSettings") == "UltraHEBox" or self:GetClientInfo("SpawnSettings") == "UltraHEATBox" or self:GetClientInfo("SpawnSettings") == "UltraHVAPBox" or self:GetClientInfo("SpawnSettings") == "UltraHESHBox" then
						self.spawnedent:SetModel( "models/daktanks/ammo6.mdl" )
					end
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakAmmoType
				self.spawnedent.DakIsExplosive = self.DakIsExplosive
				self.spawnedent.DakAmmoType = self.DakAmmoType
				self.spawnedent.DakOwner = self:GetOwner()
				self.spawnedent.DakIsHE = self.DakIsHE
						--Micro--
				if self:GetClientInfo("SpawnSettings") == "MicroAPBox" or self:GetClientInfo("SpawnSettings") == "MicroHEBox" or self:GetClientInfo("SpawnSettings") == "MicroHEATBox" or self:GetClientInfo("SpawnSettings") == "MicroHVAPBox" or self:GetClientInfo("SpawnSettings") == "MicroHESHBox" then
					self.spawnedent:SetModel( "models/daktanks/ammo1.mdl" )
				end
				--Small--
				if self:GetClientInfo("SpawnSettings") == "SmallAPBox" or self:GetClientInfo("SpawnSettings") == "SmallHEBox" or self:GetClientInfo("SpawnSettings") == "SmallHEATBox" or self:GetClientInfo("SpawnSettings") == "SmallHVAPBox" or self:GetClientInfo("SpawnSettings") == "SmallHESHBox" then
					self.spawnedent:SetModel( "models/daktanks/ammo2.mdl" )
				end
				--Standard--
				if self:GetClientInfo("SpawnSettings") == "StandardAPBox" or self:GetClientInfo("SpawnSettings") == "StandardHEBox" or self:GetClientInfo("SpawnSettings") == "StandardHEATBox" or self:GetClientInfo("SpawnSettings") == "StandardHVAPBox" or self:GetClientInfo("SpawnSettings") == "StandardHESHBox" then
					self.spawnedent:SetModel( "models/daktanks/ammo3.mdl" )
				end
				--Large--
				if self:GetClientInfo("SpawnSettings") == "LargeAPBox" or self:GetClientInfo("SpawnSettings") == "LargeHEBox" or self:GetClientInfo("SpawnSettings") == "LargeHEATBox" or self:GetClientInfo("SpawnSettings") == "LargeHVAPBox" or self:GetClientInfo("SpawnSettings") == "LargeHESHBox" then
					self.spawnedent:SetModel( "models/daktanks/ammo4.mdl" )
				end
				--Huge--
				if self:GetClientInfo("SpawnSettings") == "HugeAPBox" or self:GetClientInfo("SpawnSettings") == "HugeHEBox" or self:GetClientInfo("SpawnSettings") == "HugeHEATBox" or self:GetClientInfo("SpawnSettings") == "HugeHVAPBox" or self:GetClientInfo("SpawnSettings") == "HugeHESHBox" then
					self.spawnedent:SetModel( "models/daktanks/ammo5.mdl" )
				end
				--Ultra--
				if self:GetClientInfo("SpawnSettings") == "UltraAPBox" or self:GetClientInfo("SpawnSettings") == "UltraHEBox" or self:GetClientInfo("SpawnSettings") == "UltraHEATBox" or self:GetClientInfo("SpawnSettings") == "UltraHVAPBox" or self:GetClientInfo("SpawnSettings") == "UltraHESHBox" then
					self.spawnedent:SetModel( "models/daktanks/ammo6.mdl" )
				end
			end
		end
		if self:GetClientInfo("SpawnEnt") == "dak_teautoloadingmodule" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_teautoloadingmodule" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakOwner = self:GetOwner()
					trace.Entity.DakModel = self.DakModel
					trace.Entity.DakMaxHealth = self.DakMaxHealth
					trace.Entity.DakHealth = self.DakMaxHealth
					trace.Entity:PhysicsDestroy()
					trace.Entity:SetModel(trace.Entity.DakModel)
					trace.Entity:PhysicsInit(SOLID_VPHYSICS)
					trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
					trace.Entity:SetSolid(SOLID_VPHYSICS)
					self:GetOwner():ChatPrint("Magazine updated.")
				else
					self.spawnedent.DakName = self.DakName
					self.spawnedent.DakOwner = self:GetOwner()
					self.spawnedent.DakModel = self.DakModel
					self.spawnedent.DakMaxHealth = self.DakMaxHealth
					self.spawnedent.DakHealth = self.DakMaxHealth
					self.spawnedent:PhysicsDestroy()
					self.spawnedent:SetModel(self.DakModel)
					self.spawnedent:PhysicsInit(SOLID_VPHYSICS)
					self.spawnedent:SetMoveType(MOVETYPE_VPHYSICS)
					self.spawnedent:SetSolid(SOLID_VPHYSICS)
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakOwner = self:GetOwner()
				self.spawnedent.DakModel = self.DakModel
				self.spawnedent.DakMaxHealth = self.DakMaxHealth
				self.spawnedent.DakHealth = self.DakMaxHealth
				self.spawnedent:PhysicsDestroy()
				self.spawnedent:SetModel(self.DakModel)
				self.spawnedent:PhysicsInit(SOLID_VPHYSICS)
				self.spawnedent:SetMoveType(MOVETYPE_VPHYSICS)
				self.spawnedent:SetSolid(SOLID_VPHYSICS)
			end
		end
		if self:GetClientInfo("SpawnEnt") == "dak_turretmotor" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_turretmotor" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakOwner = self:GetOwner()
					trace.Entity.DakModel = self.DakModel
					trace.Entity.DakMaxHealth = self.DakMaxHealth
					trace.Entity.DakHealth = self.DakMaxHealth
					trace.Entity:PhysicsDestroy()
					trace.Entity:SetModel(trace.Entity.DakModel)
					trace.Entity:PhysicsInit(SOLID_VPHYSICS)
					trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
					trace.Entity:SetSolid(SOLID_VPHYSICS)
					self:GetOwner():ChatPrint("Turret motor updated.")
				else
					self.spawnedent.DakName = self.DakName
					self.spawnedent.DakOwner = self:GetOwner()
					self.spawnedent.DakModel = self.DakModel
					self.spawnedent.DakMaxHealth = self.DakMaxHealth
					self.spawnedent.DakHealth = self.DakMaxHealth
					self.spawnedent:PhysicsDestroy()
					self.spawnedent:SetModel(self.DakModel)
					self.spawnedent:PhysicsInit(SOLID_VPHYSICS)
					self.spawnedent:SetMoveType(MOVETYPE_VPHYSICS)
					self.spawnedent:SetSolid(SOLID_VPHYSICS)
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakOwner = self:GetOwner()
				self.spawnedent.DakModel = self.DakModel
				self.spawnedent.DakMaxHealth = self.DakMaxHealth
				self.spawnedent.DakHealth = self.DakMaxHealth
				self.spawnedent:PhysicsDestroy()
				self.spawnedent:SetModel(self.DakModel)
				self.spawnedent:PhysicsInit(SOLID_VPHYSICS)
				self.spawnedent:SetMoveType(MOVETYPE_VPHYSICS)
				self.spawnedent:SetSolid(SOLID_VPHYSICS)
			end
		end
		if self:GetClientInfo("SpawnEnt") == "dak_temotor" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_temotor" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakMaxHealth = self.DakMaxHealth
					trace.Entity.DakHealth = self.DakHealth
					trace.Entity.DakModel = self.DakModel
					trace.Entity.DakSound = self.DakSound
					trace.Entity:PhysicsDestroy()
					trace.Entity:SetModel(trace.Entity.DakModel)
					trace.Entity:PhysicsInit(SOLID_VPHYSICS)
					trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
					trace.Entity:SetSolid(SOLID_VPHYSICS)
					self:GetOwner():ChatPrint( "Engine updated.")
				else
					self.spawnedent.DakName = self.DakName
					self.spawnedent.DakMaxHealth = self.DakMaxHealth
					self.spawnedent.DakHealth = self.DakHealth
					self.spawnedent.DakModel = self.DakModel
					self.spawnedent.DakSound = self.DakSound
					self.spawnedent:SetModel(self.spawnedent.DakModel)
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakMaxHealth = self.DakMaxHealth
				self.spawnedent.DakHealth = self.DakHealth
				self.spawnedent.DakModel = self.DakModel
				self.spawnedent.DakSound = self.DakSound
				self.spawnedent:SetModel(self.spawnedent.DakModel)
			end
		end
		if self:GetClientInfo("SpawnEnt") == "dak_tefuel" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_tefuel" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakMaxHealth = self.DakMaxHealth
					trace.Entity.DakHealth = self.DakMaxHealth
					trace.Entity.DakModel = self.DakModel
					trace.Entity:PhysicsDestroy()
					trace.Entity:SetModel(trace.Entity.DakModel)
					trace.Entity:PhysicsInit(SOLID_VPHYSICS)
					trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
					trace.Entity:SetSolid(SOLID_VPHYSICS)
					self:GetOwner():ChatPrint( "Fuel updated.")
				else
					self.spawnedent.DakName = self.DakName
					self.spawnedent.DakMaxHealth = self.DakMaxHealth
					self.spawnedent.DakHealth = self.DakMaxHealth
					self.spawnedent.DakModel = self.DakModel
					self.spawnedent:SetModel(self.spawnedent.DakModel)
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakMaxHealth = self.DakMaxHealth
				self.spawnedent.DakHealth = self.DakMaxHealth
				self.spawnedent.DakModel = self.DakModel
				self.spawnedent:SetModel(self.spawnedent.DakModel)
			end
		end
		if self:GetClientInfo("SpawnEnt") == "dak_tegearbox" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_tegearbox" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakMaxHealth = self.DakMaxHealth
					trace.Entity.DakHealth = self.DakMaxHealth
					trace.Entity.DakModel = self.DakModel
					trace.Entity:PhysicsDestroy()
					trace.Entity:SetModel(trace.Entity.DakModel)
					trace.Entity:PhysicsInit(SOLID_VPHYSICS)
					trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
					trace.Entity:SetSolid(SOLID_VPHYSICS)
					self:GetOwner():ChatPrint( "Gearbox updated.")
				else
					self.spawnedent.DakName = self.DakName
					self.spawnedent.DakMaxHealth = self.DakMaxHealth
					self.spawnedent.DakHealth = self.DakMaxHealth
					self.spawnedent.DakModel = self.DakModel
					self.spawnedent:SetModel(self.spawnedent.DakModel)
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakMaxHealth = self.DakMaxHealth
				self.spawnedent.DakHealth = self.DakMaxHealth
				self.spawnedent.DakModel = self.DakModel
				self.spawnedent:SetModel(self.spawnedent.DakModel)
			end
		end
		if not(trace.Entity:GetClass() == self:GetClientInfo("SpawnEnt")) and not(trace.Entity:GetClass() == "dak_gun") and not(trace.Entity:GetClass() == "dak_tegun") and not(trace.Entity:GetClass() == "dak_temachinegun") and not(trace.Entity:GetClass() == "dak_teautogun") and not(trace.Entity:GetClass() == "dak_laser") and not(trace.Entity:GetClass() == "dak_xpulselaser") and not(trace.Entity:GetClass() == "dak_launcher") and not(trace.Entity:GetClass() == "dak_lams") then
			self.spawnedent:Spawn()
			self.spawnedent.DakOwner = self:GetOwner()
			self.spawnedent:GetPhysicsObject():EnableMotion( false )
			self.spawnedent:SetPos(trace.HitPos+Vector(0,0,-self.spawnedent:OBBMins().z))
			--self.spawnedent:SetSubMaterial( 0, "dak/dakplainmetallight" )
			--self.spawnedent:SetSubMaterial( 1, "dak/dakplainmetaldark" )
			local ply = self:GetOwner()
			ply:AddCount( "daktek", self.spawnedent)
			undo.Create( "daktek" )
			undo.AddEntity( self.spawnedent )
			undo.SetPlayer( ply )
			undo.Finish()
			ply:AddCleanup( "daktek", self.spawnedent )
			cleanup.Register("daktek")
		end
		if (trace.Entity:GetClass() == "dak_gun") or (trace.Entity:GetClass() == "dak_tegun") or (trace.Entity:GetClass() == "dak_teautogun") or (trace.Entity:GetClass() == "dak_temachinegun") or (trace.Entity:GetClass() == "dak_laser") or (trace.Entity:GetClass() == "dak_xpulselaser") or (trace.Entity:GetClass() == "dak_launcher") or (trace.Entity:GetClass() == "dak_lams") then
			if (self:GetClientInfo("SpawnEnt") == "dak_gun") or (self:GetClientInfo("SpawnEnt") == "dak_tegun") or (self:GetClientInfo("SpawnEnt") == "dak_temachinegun") or (self:GetClientInfo("SpawnEnt") == "dak_teautogun") or (self:GetClientInfo("SpawnEnt") == "dak_laser") or (self:GetClientInfo("SpawnEnt") == "dak_xpulselaser") or (self:GetClientInfo("SpawnEnt") == "dak_launcher") or (self:GetClientInfo("SpawnEnt") == "dak_lams") then
			self.spawnedent:Spawn()
			self.spawnedent.DakOwner = self:GetOwner()
			self.spawnedent:GetPhysicsObject():EnableMotion( false )
			--self.spawnedent:SetSubMaterial( 0, "dak/dakplainmetallight" )
			--self.spawnedent:SetSubMaterial( 1, "dak/dakplainmetaldark" )
			local ply = self:GetOwner()
			ply:AddCount( "daktek", self.spawnedent)
			undo.Create( "daktek" )
			undo.AddEntity( self.spawnedent )
			undo.SetPlayer( ply )
			undo.Finish()
			ply:AddCleanup( "daktek", self.spawnedent )
			cleanup.Register("daktek")
			self.spawnedent:GetPhysicsObject():EnableMotion(false)

		local Constraints = constraint.GetTable( trace.Entity )
			for k, v in pairs(Constraints) do
				if v.Ent1 == trace.Entity then
					v.Ent1 = self.spawnedent
				end
				if v.Ent2 == trace.Entity then
					v.Ent2 = self.spawnedent
				end
				if v.Type == "AdvBallsocket" then
					constraint.AdvBallsocket( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.forcelimit, v.torquelimit, v.xmin, v.ymin, v.zmin, v.xmax, v.ymax, v.zmax, v.xfric, v.yfric, v.zfric, v.onlyrotation, v.nocollide )
				end
				if v.Type == "Axis" then
					constraint.Axis( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.forcelimit, v.torquelimit, v.friction, v.nocollide, v.LocalAxis, v.DontAddTable )
				end
				if v.Type == "Ballsocket" then
					constraint.Ballsocket( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LocalPos, v.forcelimit, v.torquelimit, v.nocollide )
				end
				if v.Type == "Elastic" then
					constraint.Elastic( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.constant, v.damping, v.rdamping, v.material, v.width, v.stretchonly )
				end
				if v.Type == "Hydraulic" then
					constraint.Hydraulic( v.pl, v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.Length1, v.Length2, v.width, v.key, v.fixed, v.speed, v.material )
				end
				if v.Type == "Motor" then
					constraint.Motor( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.friction, v.torque, v.forcetime, v.nocollide, v.toggle, v.pl, v.forcelimit, v.numpadkey_fwd, v.numpadkey_bwd, v.direction, v.LocalAxis )
				end
				if v.Type == "Muscle" then
					constraint.Muscle( v.pl, v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.Length1, v.Length2, v.width, v.key, v.fixed, v.period, v.amplitude, v.starton, v.material )
				end
				if v.Type == "NoCollide" then
					constraint.NoCollide( v.Ent1, v.Ent2, v.Bone1, v.Bone2 )
				end
				if v.Type == "Pulley" then
					constraint.Pulley( v.Ent1, v.Ent4, v.Bone1, v.Bone4, v.LPos1, v.LPos4, v.WPos2, v.WPos3, v.forcelimit, v.rigid, v.width, v.material )
				end
				if v.Type == "Rope" then
					constraint.Rope( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.length, v.addlength, v.forcelimit, v.width, v.material, v.rigid )
				end
				if v.Type == "Slider" then
					constraint.Slider( v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.width, v.material )
				end
				if v.Type == "Weld" then
					constraint.Weld( v.ent1, v.ent2, v.bone1, v.bone2, v.forcelimit, v.nocollide, v.deleteent1onbreak )
				end
				if v.Type == "Winch" then
					constraint.Winch( v.pl, v.Ent1, v.Ent2, v.Bone1, v.Bone2, v.LPos1, v.LPos2, v.width, v.key, v.key, v.fwd_speed, v.bwd_speed, v.material, v.toggle )
				end
			end

				self.spawnedent.Inputs.Fire.Path = trace.Entity.Inputs.Fire.Path
				self.spawnedent.Inputs.Fire.Entity = self.spawnedent
				self.spawnedent.Inputs.Fire.SrcId = trace.Entity.Inputs.Fire.SrcId
				self.spawnedent.Inputs.Fire.Name = trace.Entity.Inputs.Fire.Name
				self.spawnedent.Inputs.Fire.Src = trace.Entity.Inputs.Fire.Src
				self.spawnedent.Inputs.Fire.Num = trace.Entity.Inputs.Fire.Num	
				self.spawnedent.Inputs.Fire.Material = trace.Entity.Inputs.Fire.Material
				self.spawnedent.Inputs.Fire.Width = trace.Entity.Inputs.Fire.Width
				self.spawnedent.Inputs.Fire.Value = trace.Entity.Inputs.Fire.Value
				self.spawnedent.Inputs.Fire.Color = trace.Entity.Inputs.Fire.Color
				--self.spawnedent.Inputs.Fire.Idx = trace.Entity.Inputs.Fire.Idx
				self.spawnedent.Inputs.Fire.StartPos = trace.Entity.Inputs.Fire.StartPos
				self.spawnedent.Inputs.Fire.Type = trace.Entity.Inputs.Fire.Type

			self.spawnedent:SetColor(trace.Entity:GetColor())
			trace.Entity:Remove()
			local ply = self:GetOwner()
			ply:AddCount( "daktek", self.spawnedent)
			ply:AddCleanup( "daktek", self.spawnedent )

			undo.Create( "daktek" )
				undo.AddEntity( self.spawnedent )
				undo.SetPlayer( ply )
			undo.Finish()
			ply:AddCleanup( "DakTek", self.spawnedent )
			self:GetOwner():ChatPrint("Weapon updated, respawn with duplicator to apply wiring.")
		end
		end


	end
end
 
--Information readout function, displays some useful information in chat on any entity that is right clicked
function TOOL:RightClick( trace )
	if SERVER then
		if IsValid(trace.Entity) then
			if trace.Entity.DakArmor == nil then
				DakTekTankEditionSetupNewEnt(trace.Entity)
			end
			if trace.Entity:GetClass()=="prop_physics" then 
				local SA = trace.Entity:GetPhysicsObject():GetSurfaceArea()
				if trace.Entity.IsDakTekFutureTech == 1 then
					trace.Entity.DakArmor = 1000
				else
					if SA == nil then
						--Volume = (4/3)*math.pi*math.pow( Hit.Entity:OBBMaxs().x, 3 )
						trace.Entity.DakArmor = trace.Entity:OBBMaxs().x/2
						trace.Entity.DakIsTread = 1
					else
						if trace.Entity:GetClass()=="prop_physics" then 
							if not(trace.Entity.DakArmor == 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - trace.Entity.DakBurnStacks*0.25) then
								trace.Entity.DakArmor = 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA) - trace.Entity.DakBurnStacks*0.25
							end
						end
					end
				end
			end
			local Target = trace.Entity
			local ply = self:GetOwner()
			local TarName = Target.DakName
			local HP = math.Round(Target.DakHealth, 1 )
			local MHP = math.Round(Target.DakMaxHealth, 1 )
			local PHP = math.Round((HP/MHP)*100, 1 )
			ply:ChatPrint(TarName..", ".. math.Round(Target.DakArmor,2).." Armor (mm), ".. HP.."/"..MHP.." Health, "..PHP.."% Health")
			if Target:GetClass() == "dak_teammo" then
				if Target.DakAmmo and Target.DakMaxAmmo then
					ply:ChatPrint("Ammo: "..Target.DakAmmo.."/"..Target.DakMaxAmmo.." Rounds")
				end
			end
			if Target:GetClass() == "dak_tegearbox" then
				if Target.DakHP and Target.TotalMass then
					if Target.DakCrew == NULL then
						ply:ChatPrint("HP/T: "..math.Round(Target.DakHP/(Target.TotalMass/1000),2)..", Uncrewed")
					else
						ply:ChatPrint("HP/T: "..math.Round(Target.DakHP/(Target.TotalMass/1000),2)..", Crewed")
					end
				end
			end
			if Target:GetClass() == "dak_temotor" then
				if Target.DakHP then
					ply:ChatPrint("HP: "..Target.DakHP)
				end
			end
			if Target:GetClass() == "dak_tefuel" then
				if Target.DakFuel then
					ply:ChatPrint("Fuel: "..Target.DakFuel.." L")
				end
			end
			if Target:GetClass() == "dak_tegun" then
				if Target.Loaders then
					ply:ChatPrint("Loaders: "..Target.Loaders)
					ply:ChatPrint("Reload Time: "..math.Round(Target.DakCooldown,2))
				end
			end
			if Target:GetClass() == "dak_teautogun" then
				if Target.Loaders then
					ply:ChatPrint("Loaders: "..Target.Loaders)
					ply:ChatPrint("Reload Time: "..math.Round(Target.DakCooldown,2))
					ply:ChatPrint("Reload Time (magazine): "..math.Round(Target.DakReloadTime,2))
				end
			end
			if Target:GetClass() == "dak_crew" then
				if Target.DakEntity.DakName ~= nil then
					ply:ChatPrint("Crew for "..Target.DakEntity.DakName)
				else
					ply:ChatPrint("Crew idle")
				end
			end
		end
	end
end

--Used in tool reload function, gets entities that are physically constrained to target entity directly and indirectly
local function GetPhysCons( ent, Results )
	local Results = Results or {}
	if not IsValid( ent ) then return end
		if Results[ ent ] then return end
		Results[ ent ] = ent
		local Constraints = constraint.GetTable( ent )
		for k, v in ipairs( Constraints ) do
			if not (v.Type == "NoCollide") then
				for i, Ent in pairs( v.Entity ) do
					GetPhysCons( Ent.Entity, Results )
				end
			end
		end
	return Results
end

--Used in tool reload function, gets entities that are parented to the target entity directly and indirectly
local function GetParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetParents(Parent, Results)
	end
	return Results
end

--Gets total weight of a contraption and prints into chat
function TOOL:Reload( trace )
	if SERVER then
		if IsValid(trace.Entity) then
		local Contraption = {}
		table.Add(Contraption,GetParents(trace.Entity))
		for k, v in pairs(GetParents(trace.Entity)) do
			table.Add(Contraption,GetPhysCons(v))
		end
		local Mass = 0
		for i=1, #Contraption do
			table.Add( Contraption, Contraption[i]:GetChildren() )
			table.Add( Contraption, Contraption[i]:GetParent() )
		end
		local Children = {}
		for i2=1, #Contraption do
			if table.Count(Contraption[i2]:GetChildren()) > 0 then
				table.Add( Children, Contraption[i2]:GetChildren() )
			end
		end
		table.Add( Contraption, Children )
		local hash = {}
		local res = {}
		for _,v in ipairs(Contraption) do
   			if (not hash[v]) then
    			res[#res+1] = v
    	   		hash[v] = true
   			end
		end
		for i=1, #res do
			if res[i]:IsSolid() then
				Mass = Mass + res[i]:GetPhysicsObject():GetMass()
			end
		end
		local ply = self:GetOwner()
		ply:ChatPrint("This Contraption weighs "..Mass.." kg")
		end
	end
end

function TOOL.BuildCPanel( panel )
	panel:SetMouseInputEnabled( true )
	
	--Panel creation zone--
	local ctrl 					 = vgui.Create( "DTree", panel )
	local DLabel 				 = vgui.Create( "DLabel", panel )
	local AmmoBoxSelect 		 = vgui.Create( "DComboBox", panel )
	local DermaNumSlider 		 = vgui.Create( "DNumSlider", panel )
	local AmmoTypeSelect 		 = vgui.Create( "DComboBox", panel )
	local AmmoModelSelect 		 = vgui.Create( "DComboBox", panel )
	local FuelModelSelect 		 = vgui.Create( "DComboBox", panel )
	local EngineModelSelect 	 = vgui.Create( "DComboBox", panel )
	local GearboxDirectionSelect = vgui.Create( "DComboBox", panel )
	local GearboxModelSelect 	 = vgui.Create( "DComboBox", panel )
	local AutoloaderMagazineSelect 	 = vgui.Create( "DComboBox", panel )
	local TurretMotorSelect 	 = vgui.Create( "DComboBox", panel )
	
	--Variables
	local CrateModel 	   = ""
	local Volume		   = 0
	local FuelModel		   = ""
	local GearboxDirection = ""
	local Caliber		   = 5
	local GunType		   = ""
	local EntType		   = ""
	local AmmoTypes 	   = {}
	local AmmoTypeGun    = ""
	local AutoloaderMagazine   = ""
	local TurretMotor   = ""
	local EngineModel	   = ""
	local GearboxModel	   = ""
	local AmmoWeight	   = 0
	local AmmoCount 	   = 0
	local AmmoData		   = { 0, 0, 0, 0, 0, 0, 0, 0, 0 } --1 = AP Pen Multiplier, 2 = AP Velocity, 3 = HE Pen Multiplier, 4 = HE Blast and Frag Pen Multiplier, 5 = HE Velocity, 6 = HEAT Pen Multiplier, 7 = HEAT Velocity, 8 = HESH Pen Multiplier, 9 = HESH Velocity
	
	--Table containing the information of the available engines
	local engineList = {}
	engineList["Micro Engine"] = function()
		DLabel:SetText( "Micro Engine\n\nTiny engine for tiny tanks.\n\nEngine Stats:\nHealth:                  15\nArmor:                   15mm\nWeight:                 150kg\nCrewed Speed:     25km/h with 10t contraption\nUncrewed Speed: 15km/h with 10t contraption\nPower:                  75 HP\nFuel Required:      45L (for full performance)" )
	end
	engineList["Small Engine"] = function()
		DLabel:SetText( "Small Engine\n\nSmall engine for light tanks and slow mediums.\n\nEngine Stats:\nHealth:                  30\nArmor:                   30mm\nWeight:                 350kg\nCrewed Speed:     55km/h with 10t contraption\nUncrewed Speed: 33km/h with 10t contraption\nPower:                  165 HP\nFuel Required:      90L (for full performance)" )
	end
	engineList["Standard Engine"] = function()
		DLabel:SetText( "Standard Engine\n\nStandard sized engine for medium tanks or slow heavies.\n\nEngine Stats:\nHealth:                  45\nArmor:                   45mm\nWeight:                 625kg\nCrewed Speed:     100km/h with 10t contraption\nUncrewed Speed: 60km/h with 10t contraption\nPower:                  300 HP\nFuel Required:      180L (for full performance)" )
	end
	engineList["Large Engine"] = function()
		DLabel:SetText( "Large Engine\n\nLarge engine for heavy tanks.\n\nEngine Stats:\nHealth:                  60\nArmor:                   60mm\nWeight:                 975kg\nCrewed Speed:     155km/h with 10t contraption\nUncrewed Speed: 93km/h with 10t contraption\nPower:                  465 HP\nFuel Required:      360L (for full performance)" )
	end
	engineList["Huge Engine"] = function()
		DLabel:SetText( "Huge Engine\n\nHuge engine for heavy tanks that want to move fast.\n\nEngine Stats:\nHealth:                  75\nArmor:                   75mm\nWeight:                 1400kg\nCrewed Speed:     225km/h with 10t contraption\nUncrewed Speed: 135km/h with 10t contraption\nPower:                  675 HP\nFuel Required:      720L (for full performance)" )
	end
	engineList["Ultra Engine"] = function()
		DLabel:SetText( "Ultra Engine\n\nUltra engine for use in super heavy tanks.\n\nEngine Stats:\nHealth:                  90\nArmor:                   90mm\nWeight:                 2500kg\nCrewed Speed:     400km/h with 10t contraption\nUncrewed Speed: 240km/h with 10t contraption\nPower:                  1200 HP\nFuel Required:      1440L (for full performance)" )
	end
	
	--Table containing the description of the available gearboxes
	local gearboxList = {}
	gearboxList["Micro Gearbox"] = function()
		DLabel:SetText( "Micro "..GearboxDirection.." Mount Gearbox\n\nTiny gearbox for tiny tanks.\n\nGearbox Stats:\nHealth:                 15\nArmor:                  15mm\nWeight:                150kg\nPower Rating:      150 HP\nTorque Multiplier: 0.85" )
	end
	gearboxList["Small Gearbox"] = function()
		DLabel:SetText( "Small "..GearboxDirection.." Mount Gearbox\n\nSmall gearbox for small tanks.\n\nGearbox Stats:\nHealth:                 35\nArmor:                  35mm\nWeight:                350kg\nPower Rating:      330 HP\nTorque Multiplier: 0.95" )
	end
	gearboxList["Standard Gearbox"] = function()
		DLabel:SetText( "Standard "..GearboxDirection.." Mount Gearbox\n\nMedium gearbox for medium tanks.\n\nGearbox Stats:\nHealth:                 60\nArmor:                  60mm\nWeight:                625kg\nPower Rating:      600 HP\nTorque Multiplier: 1" )
	end
	gearboxList["Large Gearbox"] = function()
		DLabel:SetText( "Large "..GearboxDirection.." Mount Gearbox\n\nLarge gearbox for large tanks.\n\nGearbox Stats:\nHealth:                 95\nArmor:                  95mm\nWeight:                975kg\nPower Rating:      930 HP\nTorque Multiplier: 1.15" )
	end
	gearboxList["Huge Gearbox"] = function()
		DLabel:SetText( "Huge "..GearboxDirection.." Mount Gearbox\n\nHuge gearbox for huge tanks.\n\nGearbox Stats:\nHealth:                 140\nArmor:                  140mm\nWeight:                1400kg\nPower Rating:      1350 HP\nTorque Multiplier: 1.25" )
	end
	gearboxList["Ultra Gearbox"] = function()
		DLabel:SetText( "Ultra "..GearboxDirection.." Mount Gearbox\n\nUltra gearbox for landcruisers.\n\nGearbox Stats:\nHealth:                 250\nArmor:                  250mm\nWeight:                2500kg\nPower Rating:      2400 HP\nTorque Multiplier: 1.3" )
	end
	
	--Table containing the description of the autoloader magazines
	local magazineList = {}
	magazineList["Small Autoloader Magazine"] = function()
		DLabel:SetText( "Small Autoloader Magazine\n\nSmall sized magazine required to load an autoloader.\n\nMagazine Stats:\nArmor:   10mm\nWeight: 1000kg\nHealth:  50" )
	end
	magazineList["Medium Autoloader Magazine"] = function()
		DLabel:SetText( "Medium Autoloader Magazine\n\nMedium sized magazine required to load an autoloader.\n\nMagazine Stats:\nArmor:   10mm\nWeight: 2000kg\nHealth:  75" )
	end
	magazineList["Large Autoloader Magazine"] = function()
		DLabel:SetText( "Large Autoloader Magazine\n\nLarge sized magazine required to load an autoloader.\n\nMagazine Stats:\nArmor:   10mm\nWeight: 3000kg\nHealth:  100" )
	end
	
	--Table containing the description of the Turret Motors
	local turretmotorList = {}
	turretmotorList["Small Turret Motor"] = function()
		DLabel:SetText( "Small Turret Motor\n\nThis can be linked to a single turret controller, increasing the speed it rotates by a flat amount, this small motor is useful for light turrets. If destroyed turret speed will go back to normal.\n\nMotor Stats:\nHealth:  10\nWeight: 250kg\nPower: x1 speed of unassisted turret" )
	end
	turretmotorList["Medium Turret Motor"] = function()
		DLabel:SetText( "Medium Turret Motor\n\nThis can be linked to a single turret controller, increasing the speed it rotates by a flat amount, this small motor is useful for medium turrets. If destroyed turret speed will go back to normal.\n\nMotor Stats:\nHealth:  20\nWeight: 500kg\nPower: x2.5 speed of unassisted turret" )
	end
	turretmotorList["Large Turret Motor"] = function()
		DLabel:SetText( "Large Turret Motor\n\nThis can be linked to a single turret controller, increasing the speed it rotates by a flat amount, this small motor is useful for heavy turrets. If destroyed turret speed will go back to normal.\n\nMotor Stats:\nHealth:  50\nWeight: 1000kg\nPower: x6 speed of unassisted turret" )
	end

	--Table containing the description of the available ammo types, called when spawning ammo crates
	local selectedAmmo = {}
	selectedAmmo["AP"] = function()
		if GunType == "Howitzer" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*4)),2).."\nVelocity:        "..AmmoData[2].." m/s" )
		elseif GunType == "Mortar" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*2.75)),2).."\nVelocity:        "..AmmoData[2].." m/s" )
		elseif GunType == "Long Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*9)),2).."\nVelocity:        "..AmmoData[2].." m/s" )
		elseif GunType == "Short Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*5)),2).."\nVelocity:        "..AmmoData[2].." m/s" )
		else
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nVelocity:        "..AmmoData[2].." m/s" )
		end	
	end
	selectedAmmo["HE"] = function()
		if GunType == "Howitzer" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*4)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s" )
		elseif GunType == "Mortar" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*2.75)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s" )
		elseif GunType == "Long Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*9)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s" )
		elseif GunType == "Short Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s" )
		else
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s" )	
		end
	end
	selectedAmmo["HEAT"] = function()
		if GunType == "Howitzer" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*4)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s" )
		elseif GunType == "Mortar" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*2.75)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s" )
		elseif GunType == "Long Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*9)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s" )
		elseif GunType == "Short Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s" )
		else
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s" )
		end
	end
	selectedAmmo["HVAP"] = function()
		if GunType == "Long Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1]*1.5,2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*9)),2).."\nVelocity:        "..(AmmoData[2]*4/3).." m/s" )
		elseif GunType == "Short Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1]*1.5,2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*5)),2).."\nVelocity:        "..(AmmoData[2]*4/3).." m/s" )
		else
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1]*1.5,2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*6.5)),2).."\nVelocity:        "..(AmmoData[2]*4/3).." m/s" )
		end	
	end
	selectedAmmo["HESH"] = function()
		if GunType == "Howitzer" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:       0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:       "..AmmoData[9].." m/s" )
		elseif GunType == "Mortar" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:       0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:       "..AmmoData[9].." m/s" )
		elseif GunType == "Long Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:       0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:       "..AmmoData[9].." m/s" )
		elseif GunType == "Short Cannon" then
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:       0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:       "..AmmoData[9].." m/s" )
		else
			DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration: "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:       0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:       "..AmmoData[9].." m/s" )
		end
	end
	
	--Table containing the description of the fuel tanks
	local fuelList = {}
	fuelList["Micro Fuel Tank"] = function()
		DLabel:SetText( "Micro Fuel Tank\n\nTiny fuel tank to run light tanks and tankettes.\n\nFuel Tank Stats:\nHealth:    10\nWeight:   65kg\nCapacity: 45L" )
	end
	fuelList["Small Fuel Tank"] = function()
		DLabel:SetText( "Small Fuel Tank\n\nSmall fuel tank for light tanks and weak engined mediums.\n\nFuel Tank Stats:\nHealth:    20\nWeight:   120kg\nCapacity: 90L" )
	end
	fuelList["Standard Fuel Tank"] = function()
		DLabel:SetText( "Standard Fuel Tank\n\nStandard medium tank fuel tank.\n\nFuel Tank Stats:\nHealth:    30\nWeight:   240kg\nCapacity: 180L" )
	end
	fuelList["Large Fuel Tank"] = function()
		DLabel:SetText( "Large Fuel Tank\n\nLarge fuel tanks for heavies running mid sized engines.\n\nFuel Tank Stats:\nHealth:    40\nWeight:   475kg\nCapacity: 360L" )
	end
	fuelList["Huge Fuel Tank"] = function()
		DLabel:SetText( "Huge Fuel Tank\n\nHuge fuel tank for heavies running large gas guzzlers.\n\nFuel Tank Stats:\nHealth:    50\nWeight:   950kg\nCapacity: 720L" )
	end
	fuelList["Ultra Fuel Tank"] = function()
		DLabel:SetText( "Ultra Fuel Tank\n\nMassive fuel tank designed for super heavy tanks running the largest of engines.\n\nFuel Tank Stats:\nHealth:    60\nWeight:   1900kg\nCapacity: 1440L" )
	end
	
	--Table containing the description of the available weapons
	local gunList = {}
	gunList["Autocannon"] = function()
		DLabel:SetText( Caliber.."mm Autocannon\n\nLight guns with large magazines and very rapid fire but long reload times. Great for hit and runs. They can only use AP and HE cannon ammo.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..2*math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000).." kg\nRate of Fire: "..math.Round(60/(0.2*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)),2).." rpm\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)*0.5*math.Round(600/Caliber),2).." seconds\nMagazine Size:       "..math.Round(600/Caliber).." rounds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n" )
	end
	gunList["Autoloader"] = function()
		DLabel:SetText( Caliber.."mm Autoloader\n\nCannons that fire a burst of shells before having to reload. Great for hit and runs. They can only use AP and HE cannon ammo and require a magazine.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000).." kg\nRefire Time: "..math.Round(0.8*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700),2).." seconds\n\nSmall Magazine Stats:\nMagazine Size:       "..math.Round(600/Caliber).." rounds\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)*1.2*math.Round(600/Caliber),2).." seconds\n\nMedium Magazine Stats:\nMagazine Size:       "..math.Round((600/Caliber)*1.5).." rounds\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)*1.8*math.Round(600/Caliber),2).." seconds\n\nLarge Magazine Stats:\nMagazine Size:       "..math.Round((600/Caliber)*2).." rounds\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)*2.4*math.Round(600/Caliber),2).." seconds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n" )
	end
	gunList["Cannon"] = function()
		DLabel:SetText( Caliber.."mm Cannon\n\nVersatile and reliable guns with high penetration and velocity but high weight.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000).." kg\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)*4,2).." seconds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n\nHEAT Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s\n\nHVAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1]*1.5,2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*6.5)),2).."\nVelocity:        "..(AmmoData[2]*4/3).." m/s" )
	end
	gunList["Long Cannon"] = function()
		DLabel:SetText( Caliber.."mm Long Cannon\n\nExtended barrel cannon firing higher velocity and higher penetration shells at the cost of shell size and gun weight.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..math.Round(((((Caliber*9)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*70))-(math.pi*((Caliber/2)^2)*(Caliber*70)))*0.001*7.8125)/1000).." kg\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9))*7700)*4,2).." seconds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*9)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*9)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n\nHEAT Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*9)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s\n\nHVAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1]*1.5,2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*9)),2).."\nVelocity:        "..(AmmoData[2]*4/3).." m/s" )
	end
	gunList["Short Cannon"] = function()
		DLabel:SetText( Caliber.."mm Short Cannon\n\nShort barrel cannon firing lower vel and lower penetration shells to save weight and fit more ammo per crate.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..math.Round(((((Caliber*5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*40))-(math.pi*((Caliber/2)^2)*(Caliber*40)))*0.001*7.8125)/1000).." kg\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*7700)*4,2).." seconds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*5)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n\nHEAT Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s\n\nHVAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1]*1.5,2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*5)),2).."\nVelocity:        "..(AmmoData[2]*4/3).." m/s" )
	end
	gunList["Flamethrower"] = function()
		DLabel:SetPos( 15, 380 )
		DLabel:SetText( "Flamethrower\n\nFlamethrower capable of igniting infantry, softening armor and stalling engines.\n\nWeapon Stats:\nArmor:           50mm\nWeight:         50kg\nHealth:          10\nDamage:       0.2\nRate of Fire: 600 streams/minute\n" )
		DermaNumSlider:SetVisible( false )
	end
	gunList["HMG"] = function()
		DLabel:SetText( Caliber.."mm Heavy Machine Gun\n\nMore light barreled autocannons than machine guns, these are somewhat useful against both armored targets and infantry. They can only use AP and HE HMG ammo.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..1.5*math.Round(((((Caliber*5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*40))-(math.pi*((Caliber/2)^2)*(Caliber*40)))*0.001*7.8125)/1000).." kg\nRate of Fire: "..math.Round(60/(0.2*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*7700)),2).." rpm\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*7700)*0.5*math.Round(800/Caliber),2).." seconds\nMagazine Size:       "..math.Round(800/Caliber).." rounds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n" )
	end
	gunList["Howitzer"] = function()
		DLabel:SetText( Caliber.."mm Howitzer\n\nLower penetration and velocity than cannons, but also lower weight and better HE.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..math.Round(((((Caliber*4)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*30))-(math.pi*((Caliber/2)^2)*(Caliber*30)))*0.001*7.8125)/1000).." kg\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4))*7700)*4,2).." seconds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*4)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*4)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n\nHEAT Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*4)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s\n\nHESH Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:               0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[9].." m/s\n" )
	end
	gunList["MG"] = function()
		DLabel:SetText( Caliber.."mm Machine Gun\n\nLight and rapid fire anti infantry guns with very little penetration power and only AP rounds, its best to not waste them on armored targets.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..5+(2*math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000)).." kg\nRate of Fire: "..math.Round(60/((Caliber/13 + Caliber/100)*0.1)).." rpm\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*6.5)),2).."\nVelocity:        "..AmmoData[2].." m/s\n" )
	end
	gunList["Mortar"] = function()
		DLabel:SetText( Caliber.."mm Mortar\n\nLight guns with low damage, penetration, and velocity but low weight and high HE splash radius.\n\nWeapon Stats:\nArmor:           "..(Caliber*5).."mm\nWeight:         "..math.Round(((((Caliber*2.75)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*15))-(math.pi*((Caliber/2)^2)*(Caliber*15)))*0.001*7.8125)/1000).." kg\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75))*7700)*4,2).." seconds\n\nAP Stats:\nPenetration: "..math.Round(Caliber*AmmoData[1],2).."mm\nDamage:       "..math.Round((math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*2.75)),2).."\nVelocity:        "..AmmoData[2].." m/s\n\nHE Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[3],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:               "..math.Round((0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*2.75)),2).."\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[5].." m/s\n\nHEAT Stats:\nPenetration: "..math.Round(Caliber*AmmoData[6],2).."mm\nFrag Penetration: "..math.Round(Caliber*AmmoData[4]*10,2).."mm\nDamage:       "..math.Round((0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*2.75)),2).."\nSplash Damage:    "..math.Round(Caliber*0.1875,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4]*0.5,2).."m\nVelocity:       "..AmmoData[7].." m/s\n\nHESH Stats:\nPenetration:         "..math.Round(Caliber*AmmoData[8],2).."mm\nDamage:               0\nSplash Damage:    "..math.Round(Caliber*0.375,2).."\nBlast Radius:         "..math.Round(Caliber*AmmoData[4],2).."m\nVelocity:                "..AmmoData[9].." m/s\n" )
	end
	
	--AmmoData Key--1 = AP Pen Multiplier, 2 = AP Velocity, 3 = HE Pen Multiplier, 4 = HE Blast and Frag Pen Multiplier, 5 = HE Velocity, 6 = HEAT Pen Multiplier, 7 = HEAT Velocity
	--Table containing information and settings for weapons, this is called by the Gun Type combobox
	local gunData = {}
	gunData["Autocannon"] = function()
		EntType   = "dak_teautogun"
		AmmoData  = { 2, 750, 0.2, 0.04, 750 }
		AmmoTypes = { "Armor Piercing", "High Explosive" }
		DermaNumSlider:SetMinMax( 20, 60 )
	end
	gunData["Autoloader"] = function()
		EntType   = "dak_teautogun"
		AmmoData  = { 2, 750, 0.2, 0.04, 750 }
		AmmoTypes = { "Armor Piercing", "High Explosive" }
		DermaNumSlider:SetMinMax( 75, 200 )
	end
	gunData["Cannon"] = function()
		EntType   = "dak_tegun"
		AmmoData  = { 2, 750, 0.2, 0.04, 750, 1.2, 562.5 }
		AmmoTypes = { "Armor Piercing", "High Explosive", "High Explosive Anti Tank", "High Velocity Armor Piercing" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Long Cannon"] = function()
		EntType   = "dak_tegun"
		AmmoData  = { 2.8, 1050, 0.2, 0.04, 1050, 1.2, 787.5 }
		AmmoTypes = { "Armor Piercing", "High Explosive", "High Explosive Anti Tank", "High Velocity Armor Piercing" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Short Cannon"] = function()
		EntType   = "dak_tegun"
		AmmoData  = { 1.6, 600, 0.2, 0.04, 600, 1.2, 450 }
		AmmoTypes = { "Armor Piercing", "High Explosive", "High Explosive Anti Tank", "High Velocity Armor Piercing" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Flamethrower"] = function()
		EntType   = "dak_temachinegun"
		AmmoTypes = {}
	end
	gunData["Heavy Machine Gun"] = function()
		GunType   = "HMG"
		EntType   = "dak_teautogun"
		AmmoData  = { 1.6, 600, 0.2, 0.04, 600 }
		AmmoTypes = { "Armor Piercing", "High Explosive" }
		DermaNumSlider:SetMinMax( 20, 40 )
	end
	gunData["Howitzer"] = function()
		EntType   = "dak_tegun"
		AmmoData  = { 1.2, 450, 0.2, 0.052, 450, 1.2, 337.5, 1.25, 225 }
		AmmoTypes = { "Armor Piercing", "High Explosive", "High Explosive Anti Tank", "High Explosive Squash Head" }
		DermaNumSlider:SetMinMax( 50, 240 )
	end
	gunData["Machine Gun"] = function()
		GunType   = "MG"
		EntType   = "dak_temachinegun"
		AmmoData  = { 2, 750 }
		AmmoTypes = { "Armor Piercing" }
		DermaNumSlider:SetMinMax( 5, 25 )
	end
	gunData["Mortar"] = function()
		EntType   = "dak_tegun"
		AmmoData  = { 0.6, 225, 0.2, 0.046, 225, 1.2, 168.75, 1.25, 112.5 }
		AmmoTypes = { "Armor Piercing", "High Explosive", "High Explosive Anti Tank", "High Explosive Squash Head"}
		DermaNumSlider:SetMinMax( 40, 280 )
	end
	
	--Table containing the volume of the available ammo crates
	local crateList = {}
	crateList["Micro Ammo Box"] = function()
		Volume = 3384.4787597656
	end
	crateList["Small Ammo Box"] = function()
		Volume = 6797.3989257813
	end
	crateList["Standard Ammo Box"] = function()
		Volume = 13651.918945313
	end
	crateList["Large Ammo Box"] = function()
		Volume = 20506.4375
	end
	crateList["Huge Ammo Box"] = function()
		Volume = 30802.55859375
	end
	crateList["Ultra Ammo Box"] = function()
		Volume = 41098.6796875
	end
	
	--Table containing the information of the different tree nodes
	local selection = {}
	------------- Guide -------------
	selection["DakTank Guide"] = function()
		DLabel:SetText( "DakTank Guide\n\nIn this folder you'll find a guide going over the game mechanics of DakTank, providing you some insight to get started on or improve your tanks." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: The Basics"] = function()
		DLabel:SetText( "DakTank Guide: The Basics\n\nIn DakTanks tanks consist of props making up armor, a fuel tank, an engine, a gearbox, at least one gun, ammo, a seat, a turret controller, and wiring all held together by the tank core entity.\n\nThe tank core must be parented to a gate that has been parented (NOT WELDED) to the baseplate of the tank. Doing this will pool the tank's health and allow your guns to fire.\n\nProps set to 1kg will be considered detail props by the system and will be entirely ignored by the damage system (but will count towards total pooled HP). Please set any detail props to 1kg." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Armor"] = function()
		DLabel:SetText( "DakTank Guide: Armor\n\nEach prop has its own armor value based on the mm protection of steel plate. The amount of protection you get on the prop is determined by its weight and volume, or simply put its density. A large prop will take much more weight than a small prop, but you'll need large props on your tank if you are to fit your equipment, larger equipment tends to offer much better bonuses than smaller counterparts.\n\nAngling your armor will increase its effective thickness, making it harder for your armor to be penetrated, though HE damage ignores slope.\n\nTreads (or anything you set to make spherical using the tool for it) have their own designated armor value based on the actual thickness of the prop then run through a modifier.\n\nTreads can be penetrated but take no damage, this lets you use them as extra armor for your sides that will reduce the AP damage they take (slightly) but does nothing against HE." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Health"] = function()
		DLabel:SetText( "DakTank Guide: Health\n\nHealth determines just how much damage your tank can take and is totalled up by the tank core, health is based mainly on the armor weight of the vehicle in tons multiplied by 10, so two tanks can be the same total weight but have different health, the more armored one being stronger.\n\nHowever, health is modified further by size multipliers, which also affect rate of fire of cannons, howitzers, mortars, autocannons, and HMGs, if your tank is large for its weight it gains bonus health to improve its durability due to the higher cost to armor it, if a tank is small for its weight it will lose health but have an easy time armoring itself.\n\nRamming damage is calculated based on max health of a tank, it finds the total mass involved in the collision then each tank takes a percentage of the damage equal to the other tank's percentage of the weight, so a 5 ton tank ramming a 50 ton tank would take 11 times the damage that the 50 ton tank took. Each module has its own health value." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: AP Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: AP Ammunition\n\nThere are 5 types of ammo, Armor Piercing (AP), High Explosive (HE), High Explosive Anti Tank (HEAT), High Velocity Armor Piercing (HVAP), and High Explosive Squash Head (HESH). Each type of ammo has its own purposes in the combat of daktek, it is a good idea to take at least some amount of each if your gun allows it.\n\nAP fires a single shell at a target, if it doesn't have enough penetration to go through the armor then it will only deal a quarter its specified damage and be deflected away.\n\nIf your shell does penetrate then it deals damage equal to its specified value multiplied by its own penetration value divided by the armor value of the prop it went through.\n\nThe damage is capped to the amount of armor the prop has, making extremely heavy cannons firing AP not the best tool for dealing with light tanks, however you'll still shoot a hole right through them and likely rip out many modules at once and still deal respectable damage." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HE Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HE Ammunition\n\nHE fires an explosive shell at its target. It has penetration equal to 30% of an AP round's penetration and acts as an AP until it finds something it cannot penetrate, at which point it explodes, creating fragments equal to half the caliber. Each fragment acts as an AP shell with no damage cap, making HE extremely powerful against low armor and very effective if you get a penetrating shot and explode inside.\n\nHE is also very effective against low thickness but highly angled armor. HE's fragmentation based nature can be very random with lower chances to hit targets further from the blast radius, you'll do much more damage on direct hits than splashes. Shots to thin armor may allow harmful fragmentation to damage internals." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HEAT Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HEAT Ammunition\n\nHEAT shells lose no penetration over range and may offer better penetration than AP in howitzers and mortars. On impact the shell propels a molten stream of metal into the enemy armor in an attempt to penetrate it. On penetration the shell will deal damage in a beam forward, with penetration quickly falling off, spalling is created equal to an HVAP shell penetration and fragments from the explosion spread through the interior of the tank. In cases where there is no penetration the shell acts like a low powered HE shell." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HVAP Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HVAP Ammunition\n\nHVAP, also known as APCR (Armor Piercing Composite Rigid) to the brits, has more penetration and velocity than AP at the cost of significantly lower damage and post pen effects. It also loses pen over distance faster." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HESH Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HESH Ammunition\n\nHESH shells fire a mass of plastic explosive at a target, spreading out on impact then detonating. It doesn't really penetrate the armor, but it is designed to create powerful spalling that damages the internals of the tank. Due to the nature of how HESH works, it totally ignores the effects of angling armor and penetrates based on the raw armor value. The explosion it generates lacks the fragmentation component found in HE and HEAT, but retains the powerful shockwave." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Weaponry"] = function()
		DLabel:SetText( "DakTank Guide: Weaponry\n\nIn DakTanks there are cannons, howitzers, autoloaders, mortars, autocannons, heavy machine guns, and machine guns.\n\nCannons are your basic weapon type and have access to any ammo type.\n\nHowitzers have weaker AP than cannons but stronger HE and are lighter with lower velocity, they are great for direct fire HE bombardment.\n\nAutoloaders are cannons that can only fire AP and HE and require a magazine module, they can fire devastating bursts in a short period of time but can have very long reloading periods.\n\nMortars are low velocity HE focused guns.\n\nAutocannons are low caliber AP and HE firing guns that fire 10-30 shots at a rate of 10 shots per second but then have a 30 second reload, they're great for light weight hit and run.\n\nHMGs have larger magazines than autocannons and half the reload times but also half the penetration, and half the velocity.\n\nMachine Guns are rapid fire anti infantry weapons that barely scratch light armor and only uses AP." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Flamethrowers"] = function()
		DLabel:SetText( "DakTank Guide: Flamethrowers\n\nFlamethrowers are a special weapon type that reduces the armor value of armor it hits over time to a minimum of half of its original value.\n\nFlamethrowers also can overheat the engines of a vehicle, reducing the power and eventually stalling a tank, making it easy to flank or easy to hit. They will also ignite infantry caught in the impact zone, dealing burn damage over the next 5 seconds.\n\nFlamethrowers require a lot of fuel to keep them firing, allowing only 15 seconds of fire per fuel tank. This means that dedicated flamethrower tanks will either need to be very large, have external tanks, or bring along a somewhat vulnerable fuel trailer or they'll be limited to short bursts of fire.\n\nFlamethrower fuel tanks have more armor and health than regular ammo crates but are also heavier and larger. However, their combination of armor and health makes them very vulnerable to crits from guns that do penetrate their armor." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Mobility"] = function()
		DLabel:SetText( "DakTank Guide: Mobility\n\nVehicle speed is determined by your combined engine power, modified by how much fuel you have and total weight of the vehicle.\n\nGiven the same engine and fuel tank a 30 ton tank will move twice as fast as a 60 tonner and will turn faster.\n\nYou can use as many engines or fuel tanks as you want, each engine requires a certain amount of fuel and each fuel tank has a certain amount of fuel. Having less fuel than you require reduces your power output.\n\nEach gearbox can only handle a certain amount of power and each tank can only support one gearbox, providing more power to the gearbox than it can handle will result in waste power.\n\nDamage will reduce the stats of each of the mobility entities, potentially immobilizing you. You could create large but fast and lightly armored vehicles or small but slow and heavily armored vehicles. The faster vehicle would be good against heavier tanks that it could flank while the heavy vehicle would be good for dominating tanks that can't pen it." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Critical Hits"] = function()
		DLabel:SetText( "DakTank Guide: Critical Hits\n\nCertain components such as fuel, ammo, and autoloader magazines can suffer from catastrophic failure in cases in which they are reduced to less than half health but not outright destroyed.\n\nUpon exploding fuel and magazines will deal 250 points of damage between the entities nearby and ammo will deal between 0 and 500 damage depending on how full the crate is.\n\nAmmo boxes can have their ammo ejected via its wire input to avoid such failures in dire circumstances, though it can take a few seconds to empty out fully.\n\nCrit explosions function just like HE explosions, so damage may be much higher than stated, this gives some reason to place explosive items in the front of the tank so that the frontal armor absorbs some of the damage.\n\nAP and HVAP ammo cooks off instead of exploding outright, causing multiple internal penetrations to occur in a short time span." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Crew"] = function()
		DLabel:SetText( "DakTank Guide: Crew\n\nCrew greatly improve the performance of a tank they are working on, each crew member is relatively light but takes up a sizeable area. Crew can be tasked with driving or loading while a turret motor can assist in improving turret rotation speeds.\n\nOnly one crew member can be driver at once but you can have as many loaders as you want, each gives diminishing returns though, the first loader reduces reload times by a third, each loader after this reduces reload times by half as much as the last.\n\nMachineguns and Autoloaders cannot be crewed, as they are fully automated. Crew members are lightly armored and have low health, making them easy to lose in the case of an armor penetration, having many crew members taken out at once can be cripling, be sure to keep them safe." )
		DLabel:SetVisible( true )
	end
	------------- Utilities -------------
	selection["Utilities"] = function()
		DLabel:SetText( "Utilities\n\nThis stuff is required to keep your vehicle running." )
		DLabel:SetVisible( true )
	end
	selection["Tank Core"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_tankcore" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "Core" )
		DLabel:SetText( "Tank Core\n\nThis is the tank's automated health pooling system, just parent one onto your tank and it will combine the HP of all attached props and have them act as one. They will still each have their own unique armor values though, load weight into pieces that need it." )
		DLabel:SetVisible( true )
	end
	selection["Crew Member"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_crew" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "Crew" )
		DLabel:SetText( "Crew Member\n\nAllows an entity to function up to their full potential when linked to it. Can be linked to engines, normal guns, autocannons, and HMGs, but not autoloaders or machine guns.\n\nCrew Stats:\nHealth:  5\nWeight: 75kg" )
		DLabel:SetVisible( true )
	end
	selection["Turret Controller"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_turretcontrol" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "TControl" )
		DLabel:SetText( "Turret Controller\n\nThis entity acts as a turret E2 would, except its more optimized and required for regulation DakTank vehicles. It must have the arrow pointing forward. You can set the elevation, depression, and yaw limits by holding C and right clicking this chip and pressing edit properties. The Gun input goes directly to the heaviest gun in the turret, the gun itself, not the aimer. It can also be boosted by a turret motor." )
		DLabel:SetVisible( true )
	end
	selection["Turret Motor"] = function()
		TurretMotorSelect:SetVisible( true )
		DLabel:SetVisible(true)
		DLabel:SetPos( 15, 380 )
		
		if TurretMotorSelect:GetSelectedID() == nil then
			DLabel:SetText( "Turret Motors\n\nThese are electric motors that help to turn the turret. They're very useful for heavier vehicles." )
		else
			turretmotorList[TurretMotor]()
			RunConsoleCommand( "daktankspawner_SpawnSettings", string.sub( TurretMotor, 1, 1 ).."TMotor" )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_turretmotor" )
		end
	end
	------------- Mobility -------------
	selection["Mobility"] = function()
		DLabel:SetText( "Mobility\n\nThe equipment used to get your vehicle moving." )
		DLabel:SetVisible( true )
	end
	selection["Engines"] = function()
		EngineModelSelect:SetVisible( true )
		DLabel:SetVisible( true )
		DLabel:SetPos( 15, 380 )

		if EngineModelSelect:GetSelectedID() == nil then
			DLabel:SetText( "Engines\n\nLarge gas guzzlers to get your tank moving at speeds faster than a brisk walk." )
		else
			engineList[EngineModel]()
			RunConsoleCommand( "daktankspawner_SpawnSettings", string.Replace( EngineModel, " ", "" ) )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_temotor" )
		end
	end
	selection["Fuel Tanks"] = function()
		FuelModelSelect:SetVisible( true )
		DLabel:SetVisible( true )
		DLabel:SetPos( 15, 380 )
		
		if FuelModelSelect:GetSelectedID() == nil then
			DLabel:SetText( "Fuel\n\nFuel tanks are required to run your engine, there are different sizes providing different bonuses." )
		else
			fuelList[FuelModel]()
			local String = string.Explode( " ", FuelModel )
			RunConsoleCommand( "daktankspawner_SpawnSettings", String[1]..String[2] )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_tefuel" )
		end
	end
	selection["Gearboxes"] = function()
		GearboxDirectionSelect:SetVisible( true )
		DLabel:SetVisible( true )
		DLabel:SetPos( 15, 405 )

		if GearboxDirectionSelect:GetSelectedID() ~= nil then
			GearboxModelSelect:SetVisible( true )
		end
		
		if GearboxModelSelect:GetSelectedID() == nil then
			DLabel:SetText( "Gearboxes\n\nTransfers the power of your engines to the wheels, you'll need heavy gearboxes to handle high power engines." )
		else
			gearboxList[GearboxModel]()
			RunConsoleCommand( "daktankspawner_SpawnSettings", string.Replace( GearboxModel, " ", "" )..string.sub( GearboxDirection, 1, 1 ) )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_tegearbox" )
		end
	end
	------------- Weaponry -------------
	selection["Weaponry"] = function()
		DLabel:SetText( "Weaponry\n\nEquipment used to make things deader." )
		DLabel:SetVisible(true)
	end
	selection["Weapons"] = function()
		AmmoBoxSelect:SetVisible( true )
		DLabel:SetVisible(true)
		DLabel:SetPos( 15, 405 )
		
		if AmmoBoxSelect:GetSelectedID() == nil then
			DLabel:SetText( "Weapons\n\nThis kills the enemy, point at things you want removed." )
		else
			DermaNumSlider:SetVisible( true )
			gunList[GunType]()
			RunConsoleCommand( "daktankspawner_SpawnSettings", GunType )
			RunConsoleCommand( "daktankspawner_SpawnEnt", EntType )
		end
	end
	selection["Autoloader Magazines"] = function()
		AutoloaderMagazineSelect:SetVisible( true )
		DLabel:SetVisible(true)
		DLabel:SetPos( 15, 380 )
		
		if AutoloaderMagazineSelect:GetSelectedID() == nil then
			DLabel:SetText( "Autoloader Magazines\n\nThese are the magazines that hold shells and supply them to an autoloader. They are explosive." )
		else
			magazineList[AutoloaderMagazine]()
			RunConsoleCommand( "daktankspawner_SpawnSettings", string.sub( AutoloaderMagazine, 1, 1 ).."ALMagazine" )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautoloadingmodule" )
		end
	end
	selection["Ammunition"] = function()
		AmmoBoxSelect:SetVisible( true )
		DLabel:SetVisible( true )
		DLabel:SetPos( 15, 455 )
			
		if AmmoBoxSelect:GetSelected() == "Flamethrower" then
			DLabel:SetPos( 15, 380 )
			DLabel:SetText( "Flamethrower Fuel\n\nFlamethrower fuel tank, more armored than normal ammo boxes but more likely to be crit, use with caution.\n\nCrate Stats:\nArmor:  25mm\nWeight: 500kg\nHealth:  30\n\nFuel Stats:\nCapacity:      15 seconds\nDamage:       0.2\nRate of Fire: 600 streams/minute" )
			RunConsoleCommand( "daktankspawner_SpawnSettings", "Flamethrower Fuel" )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teammo" )
		else
			if AmmoBoxSelect:GetSelectedID() ~= nil then
				DermaNumSlider:SetVisible( true )
				AmmoTypeSelect:SetVisible( true )
				if AmmoBoxSelect:GetSelected() ~= AmmoTypeGun then
					AmmoTypeGun = AmmoBoxSelect:GetSelected()
					AmmoTypeSelect:Clear()
					AmmoTypeSelect:SetValue( "--Select Ammo Type--" )
					for k, v in ipairs( AmmoTypes ) do
						AmmoTypeSelect:AddChoice( AmmoTypes[k] )
					end
				end
			end
				
			if AmmoTypeSelect:GetSelectedID() ~= nil then
				AmmoModelSelect:SetVisible( true )
			end
				
			if AmmoTypeSelect:GetSelectedID() == nil or AmmoModelSelect:GetSelectedID() == nil then
				DLabel:SetText( "Ammunition\n\nKeeps guns shooty." )
			else
				local String = string.Explode( " ", CrateModel )
				local AmmoCrate = String[1]..AmmoType..String[3]
				local ShellVol 	   = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*0.5118113
				local ShellLenMult = 6.5

				if AmmoBoxSelect:GetSelected() == "Howitzer" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*0.3149608
					ShellLenMult = 4
				elseif AmmoBoxSelect:GetSelected() == "Mortar" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*0.206693025
					ShellLenMult = 2.75
				elseif AmmoBoxSelect:GetSelected() == "Short Cannon" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*0.393701
					ShellLenMult = 5
				elseif AmmoBoxSelect:GetSelected() == "Long Cannon" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*0.7086618
					ShellLenMult = 9
				end

				local ShellMass = ShellVol * 0.044
				AmmoWeight 		= math.Round(ShellMass*math.floor((((Volume^(1/3))/(Caliber*0.0393701))^2)/ShellLenMult)+10)
				AmmoCount 		= math.floor((((Volume^(1/3))/(Caliber*0.0393701))^2)/ShellLenMult)

				selectedAmmo[AmmoType]()
				RunConsoleCommand( "daktankspawner_DTTE_AmmoType", GunType )
				RunConsoleCommand( "daktankspawner_SpawnSettings", AmmoCrate )
				RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teammo" )
			end
		end
	end

	--Function to update what you see in the User Interface menu
	local function updateUI()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "" )
		DLabel:SetPos( 15, 355 )
		DLabel:SetText( "" )
		TurretMotorSelect:SetVisible( false )
		AutoloaderMagazineSelect:SetVisible( false )
		GearboxModelSelect:SetVisible( false )
		GearboxDirectionSelect:SetVisible( false )
		EngineModelSelect:SetVisible( false )
		FuelModelSelect:SetVisible( false )
		AmmoTypeSelect:SetVisible( false )
		AmmoModelSelect:SetVisible( false )
		AmmoBoxSelect:SetVisible( false )
		DLabel:SetVisible( false )
		DermaNumSlider:SetVisible( false )

		if (ctrl:GetSelectedItem() ~= nil and selection[ctrl:GetSelectedItem():GetText()]) then
			selection[ctrl:GetSelectedItem():GetText()]()
		end
	end

	--Function in charge of adjusting the width of the components of the UI
	panel.PerformLayoutLegacy = panel.PerformLayout
	function panel:PerformLayout( Width, Height )
		local PanelWidth = Width-30
		
		ctrl:SetSize( PanelWidth, 300 )
		DLabel:SetWide( PanelWidth )
		AmmoBoxSelect:SetSize( PanelWidth, 20 )
		DermaNumSlider:SetSize( PanelWidth, 20 )
		AmmoTypeSelect:SetSize( PanelWidth, 20 )
		AmmoModelSelect:SetSize( PanelWidth, 20 )
		FuelModelSelect:SetSize( PanelWidth, 20 )
		EngineModelSelect:SetSize( PanelWidth, 20 )
		GearboxDirectionSelect:SetSize( PanelWidth, 20 )
		GearboxModelSelect:SetSize( PanelWidth, 20 )
		AutoloaderMagazineSelect:SetSize( PanelWidth, 20 )
		TurretMotorSelect:SetSize( PanelWidth, 20 )
		
		self:PerformLayoutLegacy( Width, Height )
	end

	--Main Tree
	ctrl:SetPos( 15, 30 )
	ctrl:SetPadding( 5 )
	ctrl:SetShowIcons( true )
	ctrl:SetVisible( true )

	--Text Box
	DLabel:SetPos( 15, 345 )
	DLabel:SetText( "Select an entity and information for it will appear here" )
	DLabel:SetTextColor( Color( 0, 0, 0, 255 ) )
	DLabel:SetAutoStretchVertical( true )
	DLabel:SetWrap( true )
	DLabel:SetVisible( true )

	--Gun Selection Combo Box
	AmmoBoxSelect:SetPos( 15, 345 )
	AmmoBoxSelect:SetSortItems( false )
	AmmoBoxSelect:SetValue( "--Select Weapon--" )
	AmmoBoxSelect:AddChoice( "Autocannon" )
	AmmoBoxSelect:AddChoice( "Autoloader" )
	AmmoBoxSelect:AddChoice( "Short Cannon" )
	AmmoBoxSelect:AddChoice( "Cannon" )
	AmmoBoxSelect:AddChoice( "Long Cannon" )
	AmmoBoxSelect:AddChoice( "Flamethrower" )
	AmmoBoxSelect:AddChoice( "Heavy Machine Gun" )
	AmmoBoxSelect:AddChoice( "Howitzer" )
	AmmoBoxSelect:AddChoice( "Machine Gun" )
	AmmoBoxSelect:AddChoice( "Mortar" )
	AmmoBoxSelect.OnSelect = function( panel, index, value )
		GunType = value
		gunData[value]()
		DermaNumSlider:SetValue( math.Clamp(DermaNumSlider:GetValue(),DermaNumSlider:GetMin(),DermaNumSlider:GetMax()) )

		updateUI()
	end

	--Caliber Slider
	DermaNumSlider:SetPos( 15, 370 )
	DermaNumSlider:SetText( "Caliber" )
	DermaNumSlider:SetDark( true )
	DermaNumSlider:SetValue( 5 )
	DermaNumSlider:SetMinMax( 0, 10 )
	DermaNumSlider:SetDecimals( 2 )

	--Ammo Type Combo Box
	AmmoTypeSelect:SetPos( 15, 395 )
	AmmoTypeSelect:SetSortItems( false )
	AmmoTypeSelect.OnSelect = function( panel, index, value )
		local String = string.Explode( " ", value )
		if ( #String > 2 ) then 
			AmmoType = string.sub( String[1], 1, 1 )..string.sub( String[2], 1, 1 )..string.sub( String[3], 1, 1 )..string.sub( String[4], 1, 1 )
		elseif ( #String > 1 ) then
			AmmoType = string.sub( String[1], 1, 1 )..string.sub( String[2], 1, 1 )
		else
			AmmoType = string.upper( string.sub( String[1], 1, 2 ) )
		end

		updateUI()
	end

	--Ammo Crate Model Combo Box
	AmmoModelSelect:SetPos( 15, 420 )
	AmmoModelSelect:SetSortItems( false )
	AmmoModelSelect:SetValue( "--Select Ammo Crate--" )
	AmmoModelSelect:AddChoice( "Micro Ammo Box" )
	AmmoModelSelect:AddChoice( "Small Ammo Box" )
	AmmoModelSelect:AddChoice( "Standard Ammo Box" )
	AmmoModelSelect:AddChoice( "Large Ammo Box" )
	AmmoModelSelect:AddChoice( "Huge Ammo Box" )
	AmmoModelSelect:AddChoice( "Ultra Ammo Box" )
	AmmoModelSelect.OnSelect = function( panel, index, value )
		CrateModel = value
		crateList[value]()

		updateUI()
	end

	--Fuel Tank Model Combo Box
	FuelModelSelect:SetPos( 15, 345 )
	FuelModelSelect:SetSortItems( false )
	FuelModelSelect:SetValue( "--Select Fuel Tank--" )
	FuelModelSelect:AddChoice( "Micro Fuel Tank" )
	FuelModelSelect:AddChoice( "Small Fuel Tank" )
	FuelModelSelect:AddChoice( "Standard Fuel Tank" )
	FuelModelSelect:AddChoice( "Large Fuel Tank" )
	FuelModelSelect:AddChoice( "Huge Fuel Tank" )
	FuelModelSelect:AddChoice( "Ultra Fuel Tank" )
	FuelModelSelect.OnSelect = function( panel, index, value )
		FuelModel = value

		updateUI()
	end

	--Engine Model Combo Box
	EngineModelSelect:SetPos( 15, 345 )
	EngineModelSelect:SetSortItems( false )
	EngineModelSelect:SetValue( "--Select Engine--" )
	EngineModelSelect:AddChoice( "Micro Engine" )
	EngineModelSelect:AddChoice( "Small Engine" )
	EngineModelSelect:AddChoice( "Standard Engine" )
	EngineModelSelect:AddChoice( "Large Engine" )
	EngineModelSelect:AddChoice( "Huge Engine" )
	EngineModelSelect:AddChoice( "Ultra Engine" )
	EngineModelSelect.OnSelect = function( panel, index, value )
		EngineModel = value

		updateUI()
	end

	--Gearbox Direction Combo Box
	GearboxDirectionSelect:SetPos( 15, 345 )
	GearboxDirectionSelect:SetValue( "--Select Direction--" )
	GearboxDirectionSelect:AddChoice( "Frontal Mount" )
	GearboxDirectionSelect:AddChoice( "Rear Mount" )
	GearboxDirectionSelect.OnSelect = function( panel, index, value )
		GearboxDirection = string.Explode( " ", value )[1]

		updateUI()
	end

	--Gearbox Model Combo Box
	GearboxModelSelect:SetPos( 15, 370 )
	GearboxModelSelect:SetSortItems( false )
	GearboxModelSelect:SetValue( "--Select Gearbox--" )
	GearboxModelSelect:AddChoice( "Micro Gearbox" )
	GearboxModelSelect:AddChoice( "Small Gearbox" )
	GearboxModelSelect:AddChoice( "Standard Gearbox" )
	GearboxModelSelect:AddChoice( "Large Gearbox" )
	GearboxModelSelect:AddChoice( "Huge Gearbox" )
	GearboxModelSelect:AddChoice( "Ultra Gearbox" )
	GearboxModelSelect.OnSelect = function( panel, index, value )
		GearboxModel = value

		updateUI()
	end

	--Autoloader Magazine Model Combo Box
	AutoloaderMagazineSelect:SetPos( 15, 345 )
	AutoloaderMagazineSelect:SetValue( "--Select Autoloader Magazine--" )
	AutoloaderMagazineSelect:SetSortItems( false )
	AutoloaderMagazineSelect:AddChoice( "Small Autoloader Magazine" )
	AutoloaderMagazineSelect:AddChoice( "Medium Autoloader Magazine" )
	AutoloaderMagazineSelect:AddChoice( "Large Autoloader Magazine" )
	AutoloaderMagazineSelect.OnSelect = function( panel, index, value )
		AutoloaderMagazine = value

		updateUI()
	end

	--Turret Motor Model Combo Box
	TurretMotorSelect:SetPos( 15, 345 )
	TurretMotorSelect:SetValue( "--Select Turret Motor--" )
	TurretMotorSelect:SetSortItems( false )
	TurretMotorSelect:AddChoice( "Small Turret Motor" )
	TurretMotorSelect:AddChoice( "Medium Turret Motor" )
	TurretMotorSelect:AddChoice( "Large Turret Motor" )
	TurretMotorSelect.OnSelect = function( panel, index, value )
		TurretMotor = value

		updateUI()
	end

	--If the value of the caliber slider changes
	function DermaNumSlider:OnValueChanged( cal )
		Caliber = math.Round( cal, 2 )
		RunConsoleCommand( "daktankspawner_DTTE_GunCaliber", Caliber )

		updateUI()
	end

	--If the main tree is pressed
	function ctrl:DoClick()
		updateUI()
	end

	--UI Initialization
	updateUI()

	--Creation of the main tree menu
	DTTE_NodeList={}
	DTTE_NodeList["Guide"] 		= ctrl:AddNode( "DakTank Guide", "icon16/book.png" )
		DTTE_NodeList["Help1"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: The Basics", "icon16/page.png" )
		DTTE_NodeList["Help2"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Armor", "icon16/page.png" )
		DTTE_NodeList["Help3"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Health", "icon16/page.png" )
		DTTE_NodeList["Help4"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: AP Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help5"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HE Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help6"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HEAT Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help12"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HVAP Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help13"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HESH Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help7"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Weaponry", "icon16/page.png" )
		DTTE_NodeList["Help8"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Flamethrowers", "icon16/page.png" )
		DTTE_NodeList["Help9"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Mobility", "icon16/page.png" )
		DTTE_NodeList["Help10"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Critical Hits", "icon16/page.png" )
		DTTE_NodeList["Help11"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Crew", "icon16/page.png" )

	DTTE_NodeList["Utilities"] 	  = ctrl:AddNode( "Utilities", "icon16/folder_brick.png" )
		DTTE_NodeList["Core"] 	  = DTTE_NodeList["Utilities"]:AddNode( "Tank Core", "icon16/cog.png" )
		DTTE_NodeList["Crew"] 	  = DTTE_NodeList["Utilities"]:AddNode( "Crew Member", "icon16/cog.png" )	
		DTTE_NodeList["TControl"] = DTTE_NodeList["Utilities"]:AddNode( "Turret Controller", "icon16/cog.png" )
		DTTE_NodeList["TMotor"]   = DTTE_NodeList["Utilities"]:AddNode( "Turret Motor", "icon16/cog.png" )

	DTTE_NodeList["Mobility"] 	 = ctrl:AddNode( "Mobility", "icon16/folder_wrench.png" )
		DTTE_NodeList["Engine"]  = DTTE_NodeList["Mobility"]:AddNode( "Engines", "icon16/cog.png" )
		DTTE_NodeList["Fuel"] 	 = DTTE_NodeList["Mobility"]:AddNode( "Fuel Tanks", "icon16/cog.png" )
		DTTE_NodeList["Gearbox"] = DTTE_NodeList["Mobility"]:AddNode( "Gearboxes", "icon16/cog.png" )

	DTTE_NodeList["Weapons"] 	= ctrl:AddNode( "Weaponry", "icon16/folder_wrench.png" )
		DTTE_NodeList["Weapon"] = DTTE_NodeList["Weapons"]:AddNode( "Weapons", "icon16/cog.png" )
		DTTE_NodeList["ALMagazine"] = DTTE_NodeList["Weapons"]:AddNode( "Autoloader Magazines", "icon16/cog.png" )
		DTTE_NodeList["Ammo"] 	= DTTE_NodeList["Weapons"]:AddNode( "Ammunition", "icon16/cog.png" )
end

function TOOL:Think()
end