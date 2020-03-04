TOOL.Category = "DakTank"
TOOL.Name = "#Tool.daktankspawner.listname"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
if CLIENT then
	language.Add( "Tool.daktankspawner.listname", "DakTank Spawner" )
	language.Add( "Tool.daktankspawner.name", "DakTank Spawner" )
	language.Add( "Tool.daktankspawner.desc", "Spawns DakTank entities." )
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
		if not(trace.Entity:GetClass() == self:GetClientInfo("SpawnEnt")) and not(trace.Entity:GetClass() == "dak_tegearbox") and not(trace.Entity:GetClass() == "dak_tegearboxnew") and not(trace.Entity:GetClass() == "dak_gun") and not(trace.Entity:GetClass() == "dak_laser") and not(trace.Entity:GetClass() == "dak_xpulselaser") and not(trace.Entity:GetClass() == "dak_launcher") and not(trace.Entity:GetClass() == "dak_lams") and not(trace.Entity:GetClass() == "dak_tegun") and not(trace.Entity:GetClass() == "dak_teautogun") and not(trace.Entity:GetClass() == "dak_temachinegun") then
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
		if trace.Entity:GetClass() == "dak_tegearbox" then
			if self:GetClientInfo("SpawnEnt") == "dak_tegearboxnew" then
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
		if trace.Entity:GetClass() == "dak_tegearboxnew" then
			if self:GetClientInfo("SpawnEnt") == "dak_tegearbox" then
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
	    local Selection = self:GetClientInfo("SpawnSettings")
	    self.IsAmmoCrate = 0
		if Selection == "STMotor" then
			self.DakMaxHealth = 10
			self.DakHealth = 10
			self.DakName = "Small Turret Motor"
			self.DakModel = "models/xqm/hydcontrolbox.mdl"
		end
		if Selection == "MTMotor" then
			self.DakMaxHealth = 20
			self.DakHealth = 20
			self.DakName = "Medium Turret Motor"
			self.DakModel = "models/props_c17/utilityconducter001.mdl"
		end
		if Selection == "LTMotor" then 
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Large Turret Motor"
			self.DakModel = "models/props_c17/substation_transformer01d.mdl"
		end
		--Crew
		if Selection == "CrewSitting" then
			self.DakMaxHealth = 5
			self.DakHealth = 5
			self.DakName = "Crew"
			self.DakModel = "models/daktanks/crew.mdl"
		end
		if Selection == "CrewStanding" then
			self.DakMaxHealth = 5
			self.DakHealth = 5
			self.DakName = "Crew"
			self.DakModel = "models/daktanks/crewstand.mdl"
		end
		if Selection == "CrewDriver" then
			self.DakMaxHealth = 5
			self.DakHealth = 5
			self.DakName = "Crew"
			self.DakModel = "models/daktanks/crewdriver.mdl"
		end
		--Fuel
		if Selection == "MicroFuel" then
			self.DakMaxHealth = 10
			self.DakHealth = 10
			self.DakName = "Micro Fuel Tank"
			self.DakModel = "models/daktanks/fueltank1.mdl"
		end
		if Selection == "SmallFuel" then
			self.DakMaxHealth = 20
			self.DakHealth = 20
			self.DakName = "Small Fuel Tank"
			self.DakModel = "models/daktanks/fueltank2.mdl"
		end
		if Selection == "StandardFuel" then
			self.DakMaxHealth = 30
			self.DakHealth = 30
			self.DakName = "Standard Fuel Tank"
			self.DakModel = "models/daktanks/fueltank3.mdl"
		end
		if Selection == "LargeFuel" then
			self.DakMaxHealth = 40
			self.DakHealth = 40
			self.DakName = "Large Fuel Tank"
			self.DakModel = "models/daktanks/fueltank4.mdl"
		end
		if Selection == "HugeFuel" then
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Huge Fuel Tank"
			self.DakModel = "models/daktanks/fueltank5.mdl"
		end
		if Selection == "UltraFuel" then
			self.DakMaxHealth = 60
			self.DakHealth = 60
			self.DakName = "Ultra Fuel Tank"
			self.DakModel = "models/daktanks/fueltank6.mdl"
		end
		--Engines
		if Selection == "MicroEngine" then
			self.DakName = "Micro Engine"
			self.DakHealth = 15
			self.DakMaxHealth = 15
			self.DakModel = "models/daktanks/engine1.mdl"
			self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if Selection == "SmallEngine" then
			self.DakName = "Small Engine"
			self.DakHealth = 30
			self.DakMaxHealth = 30
			self.DakModel = "models/daktanks/engine2.mdl"
			self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if Selection == "StandardEngine" then
			self.DakName = "Standard Engine"
			self.DakHealth = 45
			self.DakMaxHealth = 45
			self.DakModel = "models/daktanks/engine3.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_idle_loop1.wav"
		end
		if Selection == "LargeEngine" then
			self.DakName = "Large Engine"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakModel = "models/daktanks/engine4.mdl"
			self.DakSound = "vehicles/crane/crane_idle_loop3.wav"
		end
		if Selection == "HugeEngine" then
			self.DakName = "Huge Engine"
			self.DakHealth = 75
			self.DakMaxHealth = 75
			self.DakModel = "models/daktanks/engine5.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
		end
		if Selection == "UltraEngine" then
			self.DakName = "Ultra Engine"
			self.DakHealth = 90
			self.DakMaxHealth = 90
			self.DakModel = "models/daktanks/engine6.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
		end
		--GEARBOXES
		if Selection == "MicroGearboxF" then
			self.DakName = "Micro Frontal Mount Gearbox"
			self.DakHealth = 15
			self.DakMaxHealth = 15
			self.DakModel = "models/daktanks/gearbox1f1.mdl"
		end
		if Selection == "SmallGearboxF" then
			self.DakName = "Small Frontal Mount Gearbox"
			self.DakHealth = 35
			self.DakMaxHealth = 35
			self.DakModel = "models/daktanks/gearbox1f2.mdl"
		end
		if Selection == "StandardGearboxF" then
			self.DakName = "Standard Frontal Mount Gearbox"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakModel = "models/daktanks/gearbox1f3.mdl"
		end
		if Selection == "LargeGearboxF" then
			self.DakName = "Large Frontal Mount Gearbox"
			self.DakHealth = 95
			self.DakMaxHealth = 95
			self.DakModel = "models/daktanks/gearbox1f4.mdl"
		end
		if Selection == "HugeGearboxF" then
			self.DakName = "Huge Frontal Mount Gearbox"
			self.DakHealth = 140
			self.DakMaxHealth = 140
			self.DakModel = "models/daktanks/gearbox1f5.mdl"
		end
		if Selection == "UltraGearboxF" then
			self.DakName = "Ultra Frontal Mount Gearbox"
			self.DakHealth = 250
			self.DakMaxHealth = 250
			self.DakModel = "models/daktanks/gearbox1f6.mdl"
		end
		if Selection == "MicroGearboxR" then
			self.DakName = "Micro Rear Mount Gearbox"
			self.DakHealth = 15
			self.DakMaxHealth = 15
			self.DakModel = "models/daktanks/gearbox1r1.mdl"
		end
		if Selection == "SmallGearboxR" then
			self.DakName = "Small Rear Mount Gearbox"
			self.DakHealth = 35
			self.DakMaxHealth = 35
			self.DakModel = "models/daktanks/gearbox1r2.mdl"
		end
		if Selection == "StandardGearboxR" then
			self.DakName = "Standard Rear Mount Gearbox"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakModel = "models/daktanks/gearbox1r3.mdl"
		end
		if Selection == "LargeGearboxR" then
			self.DakName = "Large Rear Mount Gearbox"
			self.DakHealth = 95
			self.DakMaxHealth = 95
			self.DakModel = "models/daktanks/gearbox1r4.mdl"
		end
		if Selection == "HugeGearboxR" then
			self.DakName = "Huge Rear Mount Gearbox"
			self.DakHealth = 140
			self.DakMaxHealth = 140
			self.DakModel = "models/daktanks/gearbox1r5.mdl"
		end
		if Selection == "UltraGearboxR" then
			self.DakName = "Ultra Rear Mount Gearbox"
			self.DakHealth = 250
			self.DakMaxHealth = 250
			self.DakModel = "models/daktanks/gearbox1r6.mdl"
		end
		--CLIPS--
		if Selection == "SALMagazine" then
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Small Autoloader Magazine"
			self.DakModel = "models/daktanks/alclip1.mdl"
		end
		if Selection == "MALMagazine" then
			self.DakMaxHealth = 75
			self.DakHealth = 75
			self.DakName = "Medium Autoloader Magazine"
			self.DakModel = "models/daktanks/alclip2.mdl"
		end
		if Selection == "LALMagazine" then
			self.DakMaxHealth = 100
			self.DakHealth = 100
			self.DakName = "Large Autoloader Magazine"
			self.DakModel = "models/daktanks/alclip3.mdl"
		end
		--LAUNCHERS--
		if Selection == "2G100" then
			self.DakGunType = "2G100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 2xLauncher Ground Model"
			self.DakModel = "models/daktanks/test/srm23.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "3G100" then
			self.DakGunType = "3G100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 3xLauncher Ground Model"
			self.DakModel = "models/daktanks/test/atm33.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "5G100" then
			self.DakGunType = "5G100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 5xLauncher Ground Model"
			self.DakModel = "models/daktanks/test/lrm53.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "6G100" then
			self.DakGunType = "6G100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 6xLauncher Ground Model"
			self.DakModel = "models/daktanks/test/atm63.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "10G100" then
			self.DakGunType = "10G100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 10xLauncher Ground Model"
			self.DakModel = "models/daktanks/test/mrm103.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "3A100" then
			self.DakGunType = "3A100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 3xLauncher Air Model"
			self.DakModel = "models/daktanks/test/atm32.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "5A100" then
			self.DakGunType = "5A100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 5xLauncher Air Model"
			self.DakModel = "models/daktanks/test/lrm52.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "6A100" then
			self.DakGunType = "6A100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 6xLauncher Air Model"
			self.DakModel = "models/daktanks/test/atm62.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		if Selection == "10A100" then
			self.DakGunType = "10A100"
			self.DakCaliber = 100
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm 10xLauncher Air Model"
			self.DakModel = "models/daktanks/test/mrm102.mdl"
			self.DakFireSound = "daktanks/extra/120mmMainGun02.mp3"
		end
		--GUNS--
		if Selection == "Cannon" then
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.mp3"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.mp3"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.mp3"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.mp3"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.mp3"
			end
		end
		if Selection == "Long Cannon" then
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.mp3"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.mp3"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.mp3"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.mp3"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.mp3"
			end

		end
		if Selection == "Short Cannon" then
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.mp3"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.mp3"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.mp3"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.mp3"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.mp3"
			end
		end
		if Selection == "Howitzer" then
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

			if self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/h50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 105 then
				self.DakFireSound = "daktanks/h75.mp3"
			end
			if self.DakCaliber >= 105 and self.DakCaliber < 122 then
				self.DakFireSound = "daktanks/h105.mp3"
			end
			if self.DakCaliber >= 122 and self.DakCaliber < 155 then
				self.DakFireSound = "daktanks/h122.mp3"
			end
			if self.DakCaliber >= 155 and self.DakCaliber < 203 then
				self.DakFireSound = "daktanks/h155.mp3"
			end
			if self.DakCaliber >= 203 and self.DakCaliber < 420 then
				self.DakFireSound = "daktanks/h203.mp3"
			end
			if self.DakCaliber >= 420 then
				self.DakFireSound = "daktanks/h420.mp3"
			end
		end
		if Selection == "Mortar" then
			self.DakGunType = "Mortar"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,420)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Mortar"
			self.DakModel = "models/daktanks/mortar100mm2.mdl"

			if self.DakCaliber < 90 then
				self.DakFireSound = "daktanks/m60.mp3"
			end
			if self.DakCaliber >= 90 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/m90.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 150 then
				self.DakFireSound = "daktanks/m120.mp3"
			end
			if self.DakCaliber >= 150 and self.DakCaliber < 240 then
				self.DakFireSound = "daktanks/m150.mp3"
			end
			if self.DakCaliber >= 240 and self.DakCaliber < 280 then
				self.DakFireSound = "daktanks/m240.mp3"
			end
			if self.DakCaliber >= 280 and self.DakCaliber < 420 then
				self.DakFireSound = "daktanks/m280.mp3"
			end
			if self.DakCaliber >= 420 and self.DakCaliber < 600 then
				self.DakFireSound = "daktanks/m420.mp3"
			end
			if self.DakCaliber >= 600 then
				self.DakFireSound = "daktanks/m600.mp3"
			end
		end
		if Selection == "Smoke Launcher" then
			self.DakGunType = "Smoke Launcher"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,100)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Smoke Launcher"
			self.DakModel = "models/daktanks/smokelauncher100mm.mdl"

			self.DakFireSound = "daktanks/new/cannons/misc/grenade_launcher_01.mp3"
		end
		if Selection == "Grenade Launcher" then
			self.DakGunType = "Grenade Launcher"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,45)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Grenade Launcher"
			self.DakModel = "models/daktanks/grenadelauncher100mm.mdl"

			self.DakFireSound = "daktanks/new/cannons/misc/grenade_launcher_01.mp3"
		end
		if Selection == "Autoloader" then
			self.DakGunType = "Autoloader"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Autoloader"
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.mp3"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.mp3"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.mp3"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.mp3"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.mp3"
			end
		end
		if Selection == "Long Autoloader" then
			self.DakGunType = "Long Autoloader"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Long Autoloader"
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.mp3"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.mp3"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.mp3"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.mp3"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.mp3"
			end

		end
		if Selection == "Short Autoloader" then
			self.DakGunType = "Short Autoloader"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Short Autoloader"
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

			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/c25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/c37.mp3"
			end
			if self.DakCaliber >= 50 and self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/c50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 100 then
				self.DakFireSound = "daktanks/c75.mp3"
			end
			if self.DakCaliber >= 100 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/c100.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 152 then
				self.DakFireSound = "daktanks/c120.mp3"
			end
			if self.DakCaliber >= 152 and self.DakCaliber < 200 then
				self.DakFireSound = "daktanks/c152.mp3"
			end
			if self.DakCaliber >= 200 then
				self.DakFireSound = "daktanks/c200.mp3"
			end
		end
		if Selection == "Autoloading Howitzer" then
			self.DakGunType = "Autoloading Howitzer"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Autoloading Howitzer"
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

			if self.DakCaliber < 75 then
				self.DakFireSound = "daktanks/h50.mp3"
			end
			if self.DakCaliber >= 75 and self.DakCaliber < 105 then
				self.DakFireSound = "daktanks/h75.mp3"
			end
			if self.DakCaliber >= 105 and self.DakCaliber < 122 then
				self.DakFireSound = "daktanks/h105.mp3"
			end
			if self.DakCaliber >= 122 and self.DakCaliber < 155 then
				self.DakFireSound = "daktanks/h122.mp3"
			end
			if self.DakCaliber >= 155 and self.DakCaliber < 203 then
				self.DakFireSound = "daktanks/h155.mp3"
			end
			if self.DakCaliber >= 203 and self.DakCaliber < 420 then
				self.DakFireSound = "daktanks/h203.mp3"
			end
			if self.DakCaliber >= 420 then
				self.DakFireSound = "daktanks/h420.mp3"
			end
		end
		if Selection == "Autoloading Mortar" then
			self.DakGunType = "Autoloading Mortar"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,420)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Autoloading Mortar"
			self.DakModel = "models/daktanks/mortar100mm2.mdl"

			if self.DakCaliber < 90 then
				self.DakFireSound = "daktanks/m60.mp3"
			end
			if self.DakCaliber >= 90 and self.DakCaliber < 120 then
				self.DakFireSound = "daktanks/m90.mp3"
			end
			if self.DakCaliber >= 120 and self.DakCaliber < 150 then
				self.DakFireSound = "daktanks/m120.mp3"
			end
			if self.DakCaliber >= 150 and self.DakCaliber < 240 then
				self.DakFireSound = "daktanks/m150.mp3"
			end
			if self.DakCaliber >= 240 and self.DakCaliber < 280 then
				self.DakFireSound = "daktanks/m240.mp3"
			end
			if self.DakCaliber >= 280 and self.DakCaliber < 420 then
				self.DakFireSound = "daktanks/m280.mp3"
			end
			if self.DakCaliber >= 420 and self.DakCaliber < 600 then
				self.DakFireSound = "daktanks/m420.mp3"
			end
			if self.DakCaliber >= 600 then
				self.DakFireSound = "daktanks/m600.mp3"
			end
		end
		if Selection == "MG" then
			self.DakGunType = "MG"
			self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
			self.DakMaxHealth = self.DakCaliber
			self.DakName = self.DakCaliber.."mm Machine Gun"
			self.DakModel = "models/daktanks/machinegun100mm.mdl"

			if self.DakCaliber < 7.62 then
				self.DakFireSound = "daktanks/5mm.mp3"
			end
			if self.DakCaliber >= 7.62 and self.DakCaliber < 9 then
				self.DakFireSound = "daktanks/7mm.mp3"
			end
			if self.DakCaliber >= 9 and self.DakCaliber < 12.7 then
				self.DakFireSound = "daktanks/9mm.mp3"
			end
			if self.DakCaliber >= 12.7 and self.DakCaliber < 14.5 then
				self.DakFireSound = "daktanks/12mm.mp3"
			end
			if self.DakCaliber >= 14.5 then
				self.DakFireSound = "daktanks/14mm.mp3"
			end
		end
		if Selection == "Flamethrower" then
			self.DakGunType = "Flamethrower"
			self.DakCaliber = 10
			self.DakMaxHealth = 10
			self.DakName = "Flamethrower"
			self.DakModel = "models/daktanks/flamethrower.mdl"
			self.DakFireSound = "daktanks/flamerfire.mp3"
		end
		if Selection == "HMG" then
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

			if self.DakCaliber < 30 then
				self.DakFireSound = "daktanks/hmg20.mp3"
			end
			if self.DakCaliber >= 30 and self.DakCaliber < 40 then
				self.DakFireSound = "daktanks/hmg30.mp3"
			end
			if self.DakCaliber >= 40 then
				self.DakFireSound = "daktanks/hmg40.mp3"
			end
		end
		if Selection == "Autocannon" then
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
			
			if self.DakCaliber < 37 then
				self.DakFireSound = "daktanks/ac25.mp3"
			end
			if self.DakCaliber >= 37 and self.DakCaliber < 50 then
				self.DakFireSound = "daktanks/ac37.mp3"
			end
			if self.DakCaliber >= 50 then
				self.DakFireSound = "daktanks/ac50.mp3"
			end
		end
		--AMMO--
		--Define variables--
		local boxname = (string.Split( Selection, "" ))
		if boxname[#boxname-4] == "A" and boxname[#boxname-3] == "P" then
			self.IsAmmoCrate = 1
			self.DakIsHE = false
			self.AmmoType = "AP"
		end
		if boxname[#boxname-4] == "H" and boxname[#boxname-3] == "E" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "HE"
		end
		if boxname[#boxname-6] == "H" and boxname[#boxname-5] == "E" and boxname[#boxname-4] == "A" and boxname[#boxname-3] == "T" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "HEAT"
		end
		if boxname[#boxname-8] == "H" and boxname[#boxname-7] == "E" and boxname[#boxname-6] == "A" and boxname[#boxname-5] == "T" and boxname[#boxname-4] == "F" and boxname[#boxname-3] == "S" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "HEATFS"
		end
		if boxname[#boxname-6] == "A" and boxname[#boxname-5] == "P" and boxname[#boxname-4] == "H" and boxname[#boxname-3] == "E" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "APHE"
		end
		if boxname[#boxname-6] == "A" and boxname[#boxname-5] == "T" and boxname[#boxname-4] == "G" and boxname[#boxname-3] == "M" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "ATGM"
		end
		if boxname[#boxname-6] == "H" and boxname[#boxname-5] == "E" and boxname[#boxname-4] == "S" and boxname[#boxname-3] == "H" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "HESH"
		end
		if boxname[#boxname-6] == "H" and boxname[#boxname-5] == "V" and boxname[#boxname-4] == "A" and boxname[#boxname-3] == "P" then
			self.IsAmmoCrate = 1
			self.DakIsHE = false
			self.AmmoType = "HVAP"
		end
		if boxname[#boxname-8] == "A" and boxname[#boxname-7] == "P" and boxname[#boxname-6] == "F" and boxname[#boxname-5] == "S" and boxname[#boxname-4] == "D" and boxname[#boxname-3] == "S" then
			self.IsAmmoCrate = 1
			self.DakIsHE = false
			self.AmmoType = "APFSDS"
		end
		if boxname[#boxname-6] == "A" and boxname[#boxname-5] == "P" and boxname[#boxname-4] == "D" and boxname[#boxname-3] == "S" then
			self.IsAmmoCrate = 1
			self.DakIsHE = false
			self.AmmoType = "APDS"
		end
		if boxname[#boxname-4] == "S" and boxname[#boxname-3] == "M" then
			self.IsAmmoCrate = 1
			self.DakIsHE = true
			self.AmmoType = "SM"
		end
		if self.IsAmmoCrate == 1 then
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
			if self:GetClientInfo("DTTE_AmmoType") == "Smoke Launcher" then
				self.GunType = "SL"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,100)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Grenade Launcher" then
				self.GunType = "GL"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,45)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.GunType = "M"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,420)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autoloader" then
				self.GunType = "C"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Long Autoloader" then
				self.GunType = "LC"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Short Autoloader" then
				self.GunType = "SC"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autoloading Howitzer" then
				self.GunType = "H"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autoloading Mortar" then
				self.GunType = "M"
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,420)
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
			self.DakIsExplosive = true
			self.DakAmmoType = self.DakCaliber.."mm"..self.GunType..self.AmmoType.."Ammo"
		end
		--Flamethrower--
		if Selection == "Flamethrower Fuel" then
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
		if self:GetClientInfo("SpawnEnt") == "dak_teammo" and Selection == "Flamethrower Fuel" then
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
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakAmmoType
				self.spawnedent.DakIsExplosive = self.DakIsExplosive
				self.spawnedent.DakAmmoType = self.DakAmmoType
				self.spawnedent.DakOwner = self:GetOwner()
				self.spawnedent.DakIsHE = self.DakIsHE
			end
		end
		if self:GetClientInfo("SpawnEnt") == "dak_teammo" and not(Selection == "Flamethrower Fuel") then
			local boxtype = string.Explode( " ", Selection )[1]
			local first = string.Explode( "x", boxtype )[1]
			local second = string.Explode( "x", boxtype )[2]
			local third1 = string.Explode( "x", boxtype )[3][1]
			local third2 = string.Explode( "x", boxtype )[3][2]
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
					if first == "6" and second == "6" and third1 == "3" then
						self.spawnedent:SetModel( "models/daktanks/ammo7.mdl" )
					end
					if first == "6" and second == "6" and third1 == "6" then
						self.spawnedent:SetModel( "models/daktanks/ammo8.mdl" )
					end
					if first == "12" and second == "12" and third1 == "6" then
						self.spawnedent:SetModel( "models/daktanks/ammo9.mdl" )
					end
					if first == "12" and second == "12" and third1 == "1" and third2 == "2" then
						self.spawnedent:SetModel( "models/daktanks/ammo10.mdl" )
					end
					if first == "24" and second == "12" and third1 == "1" and third2 == "2" then
						self.spawnedent:SetModel( "models/daktanks/ammo1.mdl" )
					end
					if first == "24" and second == "24" and third1 == "1" and third2 == "2" then
						self.spawnedent:SetModel( "models/daktanks/ammo2.mdl" )
					end
					if first == "24" and second == "24" and third1 == "2" and third2 == "4" then
						self.spawnedent:SetModel( "models/daktanks/ammo3.mdl" )
					end
					if first == "24" and second == "24" and third1 == "3" and third2 == "6" then
						self.spawnedent:SetModel( "models/daktanks/ammo4.mdl" )
					end
					if first == "24" and second == "36" and third1 == "3" and third2 == "6" then
						self.spawnedent:SetModel( "models/daktanks/ammo5.mdl" )
					end
					if first == "24" and second == "36" and third1 == "4" and third2 == "8" then
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
				if first == "6" and second == "6" and third == "3" then
					self.spawnedent:SetModel( "models/daktanks/ammo7.mdl" )
				end
				if first == "6" and second == "6" and third == "6" then
					self.spawnedent:SetModel( "models/daktanks/ammo8.mdl" )
				end
				if first == "12" and second == "12" and third == "6" then
					self.spawnedent:SetModel( "models/daktanks/ammo9.mdl" )
				end
				if first == "12" and second == "12" and third == "12" then
					self.spawnedent:SetModel( "models/daktanks/ammo10.mdl" )
				end
				if first == "24" and second == "12" and third == "12" then
					self.spawnedent:SetModel( "models/daktanks/ammo1.mdl" )
				end
				if first == "24" and second == "24" and third == "12" then
					self.spawnedent:SetModel( "models/daktanks/ammo2.mdl" )
				end
				if first == "24" and second == "24" and third == "24" then
					self.spawnedent:SetModel( "models/daktanks/ammo3.mdl" )
				end
				if first == "24" and second == "24" and third == "36" then
					self.spawnedent:SetModel( "models/daktanks/ammo4.mdl" )
				end
				if first == "24" and second == "36" and third == "36" then
					self.spawnedent:SetModel( "models/daktanks/ammo5.mdl" )
				end
				if first == "24" and second == "36" and third == "48" then
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
		if self:GetClientInfo("SpawnEnt") == "dak_crew" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_crew" then
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
					self:GetOwner():ChatPrint("Crew updated.")
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
		if self:GetClientInfo("SpawnEnt") == "dak_tegearboxnew" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_tegearboxnew" then
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

		self.ScalingGun = 0
		if self.DakModel == "models/daktanks/mortar100mm2.mdl" then self.ScalingGun = 1 end
		if self.DakModel == "models/daktanks/grenadelauncher100mm.mdl" then self.ScalingGun = 1 end
		if self.DakModel == "models/daktanks/smokelauncher100mm.mdl" then self.ScalingGun = 1 end
		if self.DakModel == "models/daktanks/machinegun100mm.mdl" then self.ScalingGun = 1 end

		if not(trace.Entity:GetClass() == self:GetClientInfo("SpawnEnt")) and not(trace.Entity:GetClass() == "dak_tegearbox") and not(trace.Entity:GetClass() == "dak_tegearboxnew") and not(trace.Entity:GetClass() == "dak_gun") and not(trace.Entity:GetClass() == "dak_tegun") and not(trace.Entity:GetClass() == "dak_temachinegun") and not(trace.Entity:GetClass() == "dak_teautogun") and not(trace.Entity:GetClass() == "dak_laser") and not(trace.Entity:GetClass() == "dak_xpulselaser") and not(trace.Entity:GetClass() == "dak_launcher") and not(trace.Entity:GetClass() == "dak_lams") then
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

			if self.ScalingGun == 1 then
				if self:GetClientInfo("SpawnEnt") == "dak_tegun" or self:GetClientInfo("SpawnEnt") == "dak_teautogun" or self:GetClientInfo("SpawnEnt") == "dak_temachinegun" then
					local Caliber = self.DakCaliber*10--GetConVar("daktankspawner_DTTE_GunCaliber"):GetInt()
					self.spawnedent:SetModelScale( self.spawnedent:GetModelScale() * (Caliber/1000), 0 )
					local mins, maxs = self.spawnedent:GetCollisionBounds()
					self.spawnedent:PhysicsDestroy()	
					local x0 = mins[1] -- Define the min corner of the box
					local y0 = mins[2]
					local z0 = mins[3]
					local x1 = maxs[1] -- Define the max corner of the box
					local y1 = maxs[2]
					local z1 = maxs[3]
					self.spawnedent:PhysicsInitConvex( {
					Vector( x0, y0, z0 ),
					Vector( x0, y0, z1 ),
					Vector( x0, y1, z0 ),
					Vector( x0, y1, z1 ),
					Vector( x1, y0, z0 ),
					Vector( x1, y0, z1 ),
					Vector( x1, y1, z0 ),
					Vector( x1, y1, z1 )
					} )
					self.spawnedent:SetMoveType(MOVETYPE_VPHYSICS)
					self.spawnedent:SetSolid(SOLID_VPHYSICS)
					self.spawnedent:EnableCustomCollisions( true )
					self.spawnedent.DakOwner = self:GetOwner()
					local mins2, maxs2 = self.spawnedent:GetHitBoxBounds( 0, 0 )
					self.spawnedent:SetCollisionBounds( mins2*Caliber/1000, maxs2*Caliber/1000 )
					self.spawnedent.ScalingFinished = true
					self.spawnedent:Spawn()
					self.spawnedent:Activate()
				end
			end
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

				if self.ScalingGun == 1 then
					if self:GetClientInfo("SpawnEnt") == "dak_tegun" or self:GetClientInfo("SpawnEnt") == "dak_teautogun" or self:GetClientInfo("SpawnEnt") == "dak_temachinegun" then
						local Caliber = self.DakCaliber*10--GetConVar("daktankspawner_DTTE_GunCaliber"):GetInt()
						self.spawnedent:SetModelScale( self.spawnedent:GetModelScale() * (Caliber/1000), 0 )
						local mins, maxs = self.spawnedent:GetCollisionBounds()
						self.spawnedent:PhysicsDestroy()	
						local x0 = mins[1] -- Define the min corner of the box
						local y0 = mins[2]
						local z0 = mins[3]
						local x1 = maxs[1] -- Define the max corner of the box
						local y1 = maxs[2]
						local z1 = maxs[3]
						self.spawnedent:PhysicsInitConvex( {
						Vector( x0, y0, z0 ),
						Vector( x0, y0, z1 ),
						Vector( x0, y1, z0 ),
						Vector( x0, y1, z1 ),
						Vector( x1, y0, z0 ),
						Vector( x1, y0, z1 ),
						Vector( x1, y1, z0 ),
						Vector( x1, y1, z1 )
						} )
						self.spawnedent:SetMoveType(MOVETYPE_VPHYSICS)
						self.spawnedent:SetSolid(SOLID_VPHYSICS)
						self.spawnedent:EnableCustomCollisions( true )
						self.spawnedent.DakOwner = self:GetOwner()
						local mins2, maxs2 = self.spawnedent:GetHitBoxBounds( 0, 0 )
						self.spawnedent:SetCollisionBounds( mins2*Caliber/1000, maxs2*Caliber/1000 )
						self.spawnedent.ScalingFinished = true
						self.spawnedent:Spawn()
						self.spawnedent:Activate()
					end
				end
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

		if (trace.Entity:GetClass() == "dak_tegearbox") then
			if (self:GetClientInfo("SpawnEnt") == "dak_tegearboxnew") then
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

				self.spawnedent.Inputs = trace.Entity.Inputs
				for i=1, #self.spawnedent.Inputs do
					self.spawnedent.Inputs[i].Entity = self.spawnedent
				end

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
		if (trace.Entity:GetClass() == "dak_tegearboxnew") then
			if (self:GetClientInfo("SpawnEnt") == "dak_tegearbox") then
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

				self.spawnedent.Inputs = trace.Entity.Inputs
				for i=1, #self.spawnedent.Inputs do
					self.spawnedent.Inputs[i].Entity = self.spawnedent
				end

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
						if trace.Entity:GetClass()=="prop_physics" and not(trace.Entity.IsComposite == 1) then
							DTArmorSanityCheck(trace.Entity)
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
			if trace.Entity.IsComposite == 1 then
				if Target.EntityMods.DakName then
					ply:ChatPrint(Target.EntityMods.DakName..", ".. math.Round((DTCompositesTrace( Target, trace.HitPos, trace.Normal, {ply} )*trace.Entity.EntityMods.CompKEMult),2).." Armor(mm) vs KE, ".. math.Round((DTCompositesTrace( Target, trace.HitPos, trace.Normal, {ply} )*trace.Entity.EntityMods.CompCEMult),2).." Armor(mm) vs HEAT, ".. HP.."/"..MHP.." Health, "..PHP.."% Health")
				else
					ply:ChatPrint("Composite, ".. math.Round((DTCompositesTrace( Target, trace.HitPos, trace.Normal, {ply} )*trace.Entity.EntityMods.CompKEMult),2).." Armor(mm) vs KE, ".. math.Round((DTCompositesTrace( Target, trace.HitPos, trace.Normal, {ply} )*trace.Entity.EntityMods.CompCEMult),2).." Armor(mm) vs HEAT, ".. HP.."/"..MHP.." Health, "..PHP.."% Health")
				end
			else
				if Target:GetClass() ~= "dak_tankcore" then
					if Target.EntityMods and Target.EntityMods.ArmorType then
						ply:ChatPrint(Target.EntityMods.ArmorType.." Plate, ".. math.Round(Target.DakArmor,2).." Armor (mm), ".. HP.."/"..MHP.." Health, "..PHP.."% Health")
					else
						if TarName == "Armor" then
							ply:ChatPrint("RHA Plate, ".. math.Round(Target.DakArmor,2).." Armor (mm), ".. HP.."/"..MHP.." Health, "..PHP.."% Health")
						else
							ply:ChatPrint(TarName..", ".. math.Round(Target.DakArmor,2).." Armor (mm), ".. HP.."/"..MHP.." Health, "..PHP.."% Health")
						end
					end
				end
			end
			if Target:GetClass() == "dak_teammo" then
				if Target.DakAmmo and Target.DakMaxAmmo then
					ply:ChatPrint("Ammo: "..Target.DakAmmo.."/"..Target.DakMaxAmmo.." Rounds")
				end
			end
			if Target:GetClass() == "dak_tegearbox" or Target:GetClass() == "dak_tegearboxnew" then
				if Target.DakHP and Target.TotalMass then
					if Target.DakCrew == NULL then
						ply:ChatPrint("HP/T: "..math.Round(math.Clamp(Target.DakHP,0,Target.MaxHP)/(Target.TotalMass/1000),2)..", Speed: "..math.Round(Target.TopSpeed,2).." kph, Uncrewed")
						ply:ChatPrint("Total Mass: "..math.Round(Target.DakTankCore.TotalMass,2).." kg, Physical Mass: "..math.Round(Target.DakTankCore.PhysMass,2).." kg, Parented Mass: "..math.Round(Target.DakTankCore.ParMass,2).." kg")
					else
						ply:ChatPrint("HP/T: "..math.Round(math.Clamp(Target.DakHP,0,Target.MaxHP)/(Target.TotalMass/1000),2)..", Speed: "..math.Round(Target.TopSpeed,2).." kph, Crewed")
						ply:ChatPrint("Total Mass: "..math.Round(Target.DakTankCore.TotalMass,2).." kg, Physical Mass: "..math.Round(Target.DakTankCore.PhysMass,2).." kg, Parented Mass: "..math.Round(Target.DakTankCore.ParMass,2).." kg")
					end
				end
			end
			if Target:GetClass() == "dak_tankcore" then
				if Target.Modern and Target.ColdWar then
					ply:ChatPrint("-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-")
					if Target.Modern == 1 then
						ply:ChatPrint("Modern Tank, no limits, autocannon/HMG reload and mag size improved, carousel autoloader functionality gained")
					elseif Target.ColdWar == 1 then
						ply:ChatPrint("Cold War Tank, limited to no modern composites and no APFSDS, HEATFS/ATGM pen reduced, autocannon/HMG mag size improved, carousel autoloader functionality gained")
					else
						ply:ChatPrint("Historical Tank, limited to no composites, APFSDS, HEATFS, or ATGMs")
					end
					if Target.Cost~=nil then
						if Target.CanSpawn == true then
							--ply:ChatPrint("Tank Cost: "..Target.Cost..", breakdown below:")
							--ply:ChatPrint("Component Cost: "..Target.ComponentCost..", Ammo Cost: "..Target.AmmoCost)
							--ply:ChatPrint("Cost multiplier for Armor: "..Target.ArmorMult)
							--ply:ChatPrint("Cost multiplier for Speed: "..Target.SpeedMult)
							--ply:ChatPrint("Cost multiplier for Firepower: "..Target.FirepowerMult)
							--ply:ChatPrint("Cost multiplier for Gun Handling: "..Target.GunHandlingMult)
							local Era = "WWII"
							if Target.ColdWar == 1 then
								Era = "Cold War"
							end
							if Target.Modern == 1 then
								Era = "Modern"
							end
							ply:ChatPrint(Target.Cost.." point "..Era.." tank.")
							ply:ChatPrint("Base Costs")
							ply:ChatPrint("Armor: "..math.Round(Target.ArmorMult*50,2).." points, Firepower: "..math.Round(Target.FirepowerMult*50,2).." points.")
							ply:ChatPrint("Multipliers")
							ply:ChatPrint("Flanking: "..Target.SpeedMult.."x, Gun Handling: "..Target.GunHandlingMult.."x.")
							ply:ChatPrint("Misc")
							ply:ChatPrint("Best Average Armor: "..(math.Round(Target.ArmorMult*420,2)).."mm, Best Round Pen: "..Target.MaxPen.."mm, HP/T: "..math.Round(Target.Gearbox.HPperTon,2)..".")
							ply:ChatPrint("-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-")
						else
							ply:ChatPrint("Calculating Tank Cost")
							ply:ChatPrint("-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-")
						end
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
					ply:ChatPrint("Loaders: "..Target.Loaders.."/"..math.Max(math.Round( Target.BaseDakShellMass/25 ) , 1))
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
	local ShellLength      = 1
	local ShellLengthExact = 6.5

	--Table containing the information of the available engines
	local engineList = {}
	engineList["Micro Engine"] = function()
		DLabel:SetText( "Micro Engine\n\nTiny engine for tiny tanks.\n\nEngine Stats:\nHealth:                  5\nArmor:                  5mm\nWeight:                80kg\nCrewed Speed:     13km/h with 10t contraption\nUncrewed Speed: 8km/h with 10t contraption\nPower:                  40 HP\nFuel Required:      24L (for full performance)" )
	end
	engineList["Small Engine"] = function()
		DLabel:SetText( "Small Engine\n\nSmall engine for light tanks and slow mediums.\n\nEngine Stats:\nHealth:                  20\nArmor:                  20mm\nWeight:                265kg\nCrewed Speed:     42km/h with 10t contraption\nUncrewed Speed: 25km/h with 10t contraption\nPower:                  125 HP\nFuel Required:      75L (for full performance)" )
	end
	engineList["Standard Engine"] = function()
		DLabel:SetText( "Standard Engine\n\nStandard sized engine for medium tanks or slow heavies.\n\nEngine Stats:\nHealth:                  45\nArmor:                  45mm\nWeight:                630kg\nCrewed Speed:     100km/h with 10t contraption\nUncrewed Speed: 60km/h with 10t contraption\nPower:                  300 HP\nFuel Required:      180L (for full performance)" )
	end
	engineList["Large Engine"] = function()
		DLabel:SetText( "Large Engine\n\nLarge engine for heavy tanks.\n\nEngine Stats:\nHealth:                  90\nArmor:                  90mm\nWeight:                1225kg\nCrewed Speed:     200km/h with 10t contraption\nUncrewed Speed: 120km/h with 10t contraption\nPower:                  600 HP\nFuel Required:      360L (for full performance)" )
	end
	engineList["Huge Engine"] = function()
		DLabel:SetText( "Huge Engine\n\nHuge engine for heavy tanks that want to move fast.\n\nEngine Stats:\nHealth:                  150\nArmor:                  150mm\nWeight:                2120kg\nCrewed Speed:     333km/h with 10t contraption\nUncrewed Speed: 200km/h with 10t contraption\nPower:                  1000 HP\nFuel Required:      600L (for full performance)" )
	end
	engineList["Ultra Engine"] = function()
		DLabel:SetText( "Ultra Engine\n\nUltra engine for use in super heavy tanks.\n\nEngine Stats:\nHealth:                  360\nArmor:                  360mm\nWeight:                5020kg\nCrewed Speed:     800km/h with 10t contraption\nUncrewed Speed: 480km/h with 10t contraption\nPower:                  2400 HP\nFuel Required:      1440L (for full performance)" )
	end
	
	--Table containing the description of the available gearboxes
	local gearboxList = {}
	gearboxList["Micro Gearbox"] = function()
		DLabel:SetText( "Micro "..GearboxDirection.." Mount Gearbox\n\nTiny gearbox for tiny tanks.\n\nGearbox Stats:\nHealth:                 7.5\nArmor:                 7.5mm\nWeight:               80kg\nPower Rating:      80 HP" )
	end
	gearboxList["Small Gearbox"] = function()
		DLabel:SetText( "Small "..GearboxDirection.." Mount Gearbox\n\nSmall gearbox for small tanks.\n\nGearbox Stats:\nHealth:                 25\nArmor:                 25mm\nWeight:               265kg\nPower Rating:      250 HP" )
	end
	gearboxList["Standard Gearbox"] = function()
		DLabel:SetText( "Standard "..GearboxDirection.." Mount Gearbox\n\nMedium gearbox for medium tanks.\n\nGearbox Stats:\nHealth:                 60\nArmor:                 60mm\nWeight:               630kg\nPower Rating:      600 HP" )
	end
	gearboxList["Large Gearbox"] = function()
		DLabel:SetText( "Large "..GearboxDirection.." Mount Gearbox\n\nLarge gearbox for large tanks.\n\nGearbox Stats:\nHealth:                 120\nArmor:                 120mm\nWeight:               1230kg\nPower Rating:      1200 HP" )
	end
	gearboxList["Huge Gearbox"] = function()
		DLabel:SetText( "Huge "..GearboxDirection.." Mount Gearbox\n\nHuge gearbox for huge tanks.\n\nGearbox Stats:\nHealth:                 200\nArmor:                 200mm\nWeight:               2130kg\nPower Rating:      2000 HP" )
	end
	gearboxList["Ultra Gearbox"] = function()
		DLabel:SetText( "Ultra "..GearboxDirection.." Mount Gearbox\n\nUltra gearbox for landcruisers.\n\nGearbox Stats:\nHealth:                 480\nArmor:                 480mm\nWeight:               5050kg\nPower Rating:      4800 HP" )
	end
	
	--Table containing the description of the autoloader magazines
	local magazineList = {}
	magazineList["Small Autoloader Magazine"] = function()
		DLabel:SetText( "Small Autoloader Magazine\n\nSmall sized magazine required to load an autoloader.\n\nMag Stats:\nArmor:   10mm\nWeight: 1000kg\nHealth:  50" )
	end
	magazineList["Medium Autoloader Magazine"] = function()
		DLabel:SetText( "Medium Autoloader Magazine\n\nMedium sized magazine required to load an autoloader.\n\nMag Stats:\nArmor:   10mm\nWeight: 2000kg\nHealth:  75" )
	end
	magazineList["Large Autoloader Magazine"] = function()
		DLabel:SetText( "Large Autoloader Magazine\n\nLarge sized magazine required to load an autoloader.\n\nMag Stats:\nArmor:   10mm\nWeight: 3000kg\nHealth:  100" )
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
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*2*ShellLength,2).."mm\nDamage:        "..math.Round((25*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength).." m/s" )
	end
	selectedAmmo["HE"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*0.2*ShellLength,2).."mm\nFrag Pen:      "..math.Round((2.137015-0.1086095*Caliber+0.002989107*Caliber^2)*(-0.005372093*(ShellLength*50)+1.118186),2).."mm\nDamage:        "..math.Round((25*0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nSplash Dmg:   "..math.Round(Caliber*5,2).."\nBlast Radius:  "..math.Round(((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186))*0.0254,2).."m\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength).." m/s" )	
	end
	selectedAmmo["APHE"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*1.65*ShellLength,2).."mm\nFrag Pen:      "..math.Round((2.137015-0.1086095*Caliber+0.002989107*Caliber^2)*(-0.005372093*(ShellLength*50)+1.118186)*0.1,2).."mm\nDamage:        "..math.Round((25*0.5*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nSplash Dmg:   "..math.Round(Caliber*2.5,2).."\nBlast Radius:  "..math.Round(0.1*0.0254*((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186)),2).."m\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength).." m/s" )	
	end
	selectedAmmo["HEAT"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*5.4*0.431,2).."mm Cold War, "..math.Round(Caliber*1.2,2).."mm WWII\nFrag Pen:      "..math.Round((2.137015-0.1086095*Caliber+0.002989107*Caliber^2)*(-0.005372093*(ShellLength*50)+1.118186)*0.75,2).."mm\nDamage:        "..math.Round((25*0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nSplash Dmg:   "..math.Round(Caliber*2.5,2).."\nBlast Radius:  "..math.Round(0.5*0.0254*((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186)),2).."m\nVelocity:         "..math.Round(29527.6*0.75*ShellLength*0.0254).." m/s" )
	end
	selectedAmmo["HEATFS"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*5.4,2).."mm Modern, "..math.Round(Caliber*5.4*0.658,2).."mm Cold War\nFrag Pen:      "..math.Round((2.137015-0.1086095*Caliber+0.002989107*Caliber^2)*(-0.005372093*(ShellLength*50)+1.118186)*0.75,2).."mm\nDamage:        "..math.Round((25*0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nSplash Dmg:   "..math.Round(Caliber*2.5,2).."\nBlast Radius:  "..math.Round(0.5*0.0254*((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186)),2).."m\nVelocity:         "..math.Round(29527.6*ShellLength*0.0254*1.3333).." m/s" )
	end
	selectedAmmo["ATGM"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*6.4,2).."mm Modern, "..math.Round(Caliber*6.4*0.45,2).."mm Cold War\nFrag Pen:      "..math.Round((2.137015-0.1086095*Caliber+0.002989107*Caliber^2)*(-0.005372093*(ShellLength*50)+1.118186)*0.75,2).."mm\nDamage:        "..math.Round((25*0.125*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nSplash Dmg:   "..math.Round(Caliber*5,2).."\nBlast Radius:  "..math.Round(0.5*0.0254*((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186)),2).."m\nVelocity:         "..math.Round(12600*0.0254).." m/s" )
	end
	selectedAmmo["HVAP"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*3*ShellLength,2).."mm\nDamage:        "..math.Round((25*math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*ShellLengthExact)),2).."\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength*4/3).." m/s" )
	end
	selectedAmmo["APDS"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*3.34*ShellLength,2).."mm\nDamage:        "..math.Round((25*math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.5*0.02*ShellLengthExact)),2).."\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength*4/3).." m/s" )
	end
	selectedAmmo["APFSDS"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, cooks off when damaged.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*7.8*ShellLength,2).."mm\nDamage:        "..math.Round((25*math.pi*((Caliber*0.02*0.25)^2)*(Caliber*0.25*0.02*ShellLengthExact)),2).."\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength*2.394).." m/s" )
	end
	selectedAmmo["HESH"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*1.25,2).."mm\nDamage:        0\nSplash Dmg:   "..math.Round(Caliber*2.5,2).."\nBlast Radius:  "..math.Round(0.5*0.0254*((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186)),2).."m\nVelocity:         "..math.Round(29527.6*0.0254*ShellLength).." m/s" )
	end
	selectedAmmo["SM"] = function()
		DLabel:SetText( Caliber.."mm "..GunType.." "..AmmoType.." Ammo\n\nMakes guns shootier, also explodes.\n\nCrate Stats:\nHealth:  10\nWeight: "..AmmoWeight.."kg\nAmmo:   "..AmmoCount.." round(s)\n\nAmmo Stats:\nPenetration:  "..math.Round(Caliber*0.1*ShellLength,2).."mm\nFrag Pen:      0mm\nDamage:        "..math.Round((25*0.25*math.pi*((Caliber*0.02*0.5)^2)*(Caliber*0.02*ShellLengthExact)),2).."\nSplash Dmg:   "..math.Round(Caliber*0.5,2).."\nBlast Radius:  "..math.Round((((((Caliber/155)*50)*39)*(-0.005372093*(ShellLength*50)+1.118186))*0.0254),2).."m\nVelocity:         "..math.Round(29527.6*0.42*0.0254*ShellLength).." m/s" )	
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
	gunList["Launcher"] = function()
		DLabel:SetText( Caliber.."mm Launcher\n\nLaunches missile" )
	end
	gunList["Autocannon"] = function()
		DLabel:SetText( Caliber.."mm Autocannon\n\nLight guns with large magazines and very rapid fire but long reload times. Great for hit and runs. They can only use AP and HE cannon ammo.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..3.1*math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000).." kg\nRate of Fire: "..math.Round(60/(0.2*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)),2).." rpm, "..math.Round(60/(0.14*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)),2).." modern\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*7700)*0.5*math.Round(600/Caliber),2).." seconds\nMag Size:      "..math.Round(600/Caliber).." rounds, size of crate modern and cold war\n\n" )
	end
	gunList["Autoloader"] = function()
		DLabel:SetText( Caliber.."mm Autoloader\n\nCannons that fire a burst of shells before having to reload. Requires magazine module.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000).." kg\nRefire Time (Mag):         "..math.Round(0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*4300,2).." seconds\nRefire Time (Carousel):  "..math.Round((0.225*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*4300)+1.1,2).." seconds\n\nSmall Mag Stats:\nMag Size:      "..math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*4300)*math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nMedium Mag Stats:\nMag Size:      "..math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*4300)*math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nLarge Mag Stats:\nMag Size:      "..math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5))*4300)*math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\n" )
	end
	gunList["Short Autoloader"] = function()
		DLabel:SetText( Caliber.."mm Short Autoloader\n\nCannons that fire a burst of shells before having to reload. Requires magazine module.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*40))-(math.pi*((Caliber/2)^2)*(Caliber*40)))*0.001*7.8125)/1000).." kg\nRefire Time (Mag):         "..math.Round(0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*4300,2).." seconds\nRefire Time (Carousel):  "..math.Round((0.225*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*4300)+1.1,2).." seconds\n\nSmall Mag Stats:\nMag Size:      "..math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*4300)*math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nMedium Mag Stats:\nMag Size:      "..math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*4300)*math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nLarge Mag Stats:\nMag Size:      "..math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*4300)*math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\n" )
	end
	gunList["Long Autoloader"] = function()
		DLabel:SetText( Caliber.."mm Long Autoloader\n\nCannons that fire a burst of shells before having to reload. Requires magazine module.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*9)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*70))-(math.pi*((Caliber/2)^2)*(Caliber*70)))*0.001*7.8125)/1000).." kg\nRefire Time (Mag):         "..math.Round(0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9))*4300,2).." seconds\nRefire Time (Carousel):  "..math.Round((0.225*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9))*4300)+1.1,2).." seconds\n\nSmall Mag Stats:\nMag Size:      "..math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9))*4300)*math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nMedium Mag Stats:\nMag Size:      "..math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9))*4300)*math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nLarge Mag Stats:\nMag Size:      "..math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9))*4300)*math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\n" )
	end
	gunList["Autoloading Howitzer"] = function()
		DLabel:SetText( Caliber.."mm Autoloading Howitzer\n\nCannons that fire a burst of shells before having to reload. Requires magazine module.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*4)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*30))-(math.pi*((Caliber/2)^2)*(Caliber*30)))*0.001*7.8125)/1000).." kg\nRefire Time (Mag):         "..math.Round(0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4))*4300,2).." seconds\nRefire Time (Carousel):  "..math.Round((0.225*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4))*4300)+1.1,2).." seconds\n\nSmall Mag Stats:\nMag Size:      "..math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4))*4300)*math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nMedium Mag Stats:\nMag Size:      "..math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4))*4300)*math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nLarge Mag Stats:\nMag Size:      "..math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4))*4300)*math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\n" )
	end
	gunList["Autoloading Mortar"] = function()
		DLabel:SetText( Caliber.."mm Autoloading Mortar\n\nCannons that fire a burst of shells before having to reload. Requires magazine module.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*2.75)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*15))-(math.pi*((Caliber/2)^2)*(Caliber*15)))*0.001*7.8125)/1000).." kg\nRefire Time (Mag):         "..math.Round(0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75))*4300,2).." seconds\nRefire Time (Carousel):  "..math.Round((0.225*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75))*4300)+1.1,2).." seconds\n\nSmall Mag Stats:\nMag Size:      "..math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75))*4300)*math.floor(0.27*24068.224609375/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nMedium Mag Stats:\nMag Size:      "..math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75))*4300)*math.floor(0.27*81230.265625/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\nLarge Mag Stats:\nMag Size:      "..math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))).." rounds\nReload Time: "..math.Round((0.15*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75))*4300)*math.floor(0.27*192545.796875/(((Caliber*0.0393701)^2)*(Caliber*0.0393701*13*ShellLength))),2).." seconds\n\n" )
	end
	gunList["Cannon"] = function()
		DLabel:SetText( Caliber.."mm Cannon\n\nVersatile and reliable guns with high penetration and velocity but high weight.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000).." kg\nReloads: \n\nAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*5150) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*5150)/25 ) , 1).. "\nHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*5350) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*5350)/25 ) , 1).. "\nHEAT: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550)/25 ) , 1).. "\nHVAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3725)/25 ) , 1).. "\nHESH: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3450)/25 ) , 1).. "\nATGM: "..math.Round( 0.75*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550)/25 ) , 1).. "\nHEATFS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550)/25 ) , 1).. "\nAPFSDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*2750) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*2750)/25 ) , 1).. "\nAPHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*5450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*5450)/25 ) , 1).. "\nAPDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3725)/25 ) , 1).. "\nAPDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3725)/25 ) , 1).. "\n\n" )
	end
	gunList["Long Cannon"] = function()
		DLabel:SetText( Caliber.."mm Long Cannon\n\nExtended barrel cannon firing higher velocity and higher penetration shells at the cost of shell size and gun weight.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*9)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*70))-(math.pi*((Caliber/2)^2)*(Caliber*70)))*0.001*7.8125)/1000).." kg\nReloads: \n\nAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*5150) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*5150)/25 ) , 1).. "\nHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*5350) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*5350)/25 ) , 1).. "\nHEAT: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3550)/25 ) , 1).. "\nHVAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3725)/25 ) , 1).. "\nHESH: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3450)/25 ) , 1).. "\nATGM: "..math.Round( 0.75*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3550)/25 ) , 1).. "\nHEATFS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3550)/25 ) , 1).. "\nAPFSDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*2750) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*2750)/25 ) , 1).. "\nAPHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*5450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*5450)/25 ) , 1).. "\nAPDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*9)*3725)/25 ) , 1).. "\n\n" )
	end
	gunList["Short Cannon"] = function()
		DLabel:SetText( Caliber.."mm Short Cannon\n\nShort barrel cannon firing lower vel and lower penetration shells to save weight and fit more ammo per crate.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*40))-(math.pi*((Caliber/2)^2)*(Caliber*40)))*0.001*7.8125)/1000).." kg\nReloads: \n\nAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*5150) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*5150)/25 ) , 1).. "\nHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*5350) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*5350)/25 ) , 1).. "\nHEAT: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3550)/25 ) , 1).. "\nHVAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3725)/25 ) , 1).. "\nHESH: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3450)/25 ) , 1).. "\nATGM: "..math.Round( 0.75*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3550)/25 ) , 1).. "\nHEATFS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3550)/25 ) , 1).. "\nAPFSDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*2750) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*2750)/25 ) , 1).. "\nAPHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*5450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*5450)/25 ) , 1).. "\nAPDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3725)/25 ) , 1).. "\nAPDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5)*3725)/25 ) , 1).. "\n\n" )
	end
	gunList["Flamethrower"] = function()
		DLabel:SetPos( 15, 380 )
		DLabel:SetText( "Flamethrower\n\nFlamethrower capable of igniting infantry, softening armor and stalling engines.\n\nWeapon Stats:\nArmor:          50mm\nWeight:        50kg\nHealth:          10\nDamage:        5\nRate of Fire: 600 streams/minute\n" )
		DermaNumSlider:SetVisible( false )
	end
	gunList["HMG"] = function()
		DLabel:SetText( Caliber.."mm Heavy Machine Gun\n\nMore light barreled autocannons than machine guns, these are somewhat useful against both armored targets and infantry. They can only use AP and HE HMG ammo.\n\nWeapon Stats:\nArmor:            "..(Caliber*5).."mm\nWeight:         "..2.33*math.Round(((((Caliber*5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*40))-(math.pi*((Caliber/2)^2)*(Caliber*40)))*0.001*7.8125)/1000).." kg\nRate of Fire: "..math.Round(60/(0.2*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*7700)),2).." rpm, "..math.Round(60/(0.14*math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*7700)),2).." modern\nReload Time: "..math.Round(math.sqrt((math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*5))*7700)*0.5*math.Round(800/Caliber),2).." seconds\nMag Size:      "..math.Round(800/Caliber).." rounds, size of crate modern and cold war\n\n" )
	end
	gunList["Howitzer"] = function()
		DLabel:SetText( Caliber.."mm Howitzer\n\nLower penetration and velocity than cannons, but also lower weight and better HE.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*4)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*30))-(math.pi*((Caliber/2)^2)*(Caliber*30)))*0.001*7.8125)/1000).." kg\nReloads: \n\nAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*5150) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*5150)/25 ) , 1).. "\nHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*5350) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*5350)/25 ) , 1).. "\nHEAT: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3550)/25 ) , 1).. "\nHVAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3725)/25 ) , 1).. "\nHESH: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3450)/25 ) , 1).. "\nATGM: "..math.Round( 0.75*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3550)/25 ) , 1).. "\nHEATFS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3550)/25 ) , 1).. "\nAPFSDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*2750) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*2750)/25 ) , 1).. "\nAPHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*5450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*5450)/25 ) , 1).. "\nAPDS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3725) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*4)*3725)/25 ) , 1).. "\n\n" )
	end
	gunList["MG"] = function()
		DLabel:SetText( Caliber.."mm Machine Gun\n\nLight and rapid fire anti infantry guns with very little penetration power and only AP rounds, its best to not waste them on armored targets.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..5+(2*math.Round(((((Caliber*6.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*50))-(math.pi*((Caliber/2)^2)*(Caliber*50)))*0.001*7.8125)/1000)).." kg\nRate of Fire: "..math.Round(60/((Caliber/13 + Caliber/100)*0.1)).." rpm\n\n" )
	end
	gunList["Smoke Launcher"] = function()
		DLabel:SetText( Caliber.."mm Smoke Launcher\n\nLightweight tube built to fire low velocity smoke grenades to conceal the vehicle's movement.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..5+(2*math.Round(((((Caliber*0.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*3))-(math.pi*((Caliber/2)^2)*(Caliber*3)))*0.001*7.8125)/1000)).." kg\nReload Time: 30 seconds\n\n" )
	end
	gunList["Grenade Launcher"] = function()
		DLabel:SetText( Caliber.."mm Grenade Launcher\n\nAutomatic grenade launcher great for infantry support.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..5+(2*math.Round(((((Caliber*3.5)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*3))-(math.pi*((Caliber/2)^2)*(Caliber*3)))*0.001*7.8125)/1000)).." kg\nRate of Fire: "..math.Round(60/((Caliber/13 + Caliber/100)*0.05)).." rpm\n\n" )
	end
	gunList["Mortar"] = function()
		DLabel:SetText( Caliber.."mm Mortar\n\nLight guns with low damage, penetration, and velocity but low weight and high HE splash radius.\n\nWeapon Stats:\nArmor:          "..(Caliber*5).."mm\nWeight:        "..math.Round(((((Caliber*2.75)*(Caliber*3)*(Caliber*3))+(math.pi*(Caliber^2)*(Caliber*15))-(math.pi*((Caliber/2)^2)*(Caliber*15)))*0.001*7.8125)/1000).." kg\nReloads: \n\nAP: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*5150) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*5150)/25 ) , 1).. "\nHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*5350) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*5350)/25 ) , 1).. "\nHEAT: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3550)/25 ) , 1).. "\nHESH: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3450)/25 ) , 1).. "\nATGM: "..math.Round( 0.75*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*6.5)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3550)/25 ) , 1).. "\nHEATFS: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3550) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*3550)/25 ) , 1).. "\nAPHE: "..math.Round( 1.279318 + 0.2484886*(math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*5450) ,2).." seconds, Loaders: "..math.Max(math.Round( (math.pi*((Caliber*0.001*0.5)^2)*(Caliber*0.001*2.75)*5450)/25 ) , 1).. "\n\n" )
	end
	
	--AmmoData Key--1 = AP Pen Multiplier, 2 = AP Velocity, 3 = HE Pen Multiplier, 4 = HE Blast and Frag Pen Multiplier, 5 = HE Velocity, 6 = HEAT Pen Multiplier, 7 = HEAT Velocity, 8 = HESH Pen Multiplier, 9 = HESH Velocity
	
	--Base Velocity = 29527.6
	--Lenght Mult 
	--AP PEN
	--HE PEN
	--HE FRAG/BLAST PEN
	--HEAT PEN
	--HESH PEN
	--ATGM PEN
	--APFSDS PEN

	--Table containing information and settings for weapons, this is called by the Gun Type combobox
	local gunData = {}
	gunData["Launcher"] = function()
		EntType   = "dak_tegun"
		ShellLength = 50/50
		ShellLengthExact = 6.5
		AmmoTypes = { "Anti Tank Guided Missile" }
		DermaNumSlider:SetMinMax( 100, 100 )
	end
	gunData["Autocannon"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 50/50
		ShellLengthExact = 6.5
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "Armor Piercing Fin Stabilized Discarding Sabot" }
		DermaNumSlider:SetMinMax( 20, 60 )
	end
	gunData["Autoloader"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 50/50
		ShellLengthExact = 6.5
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "High Explosive Squash Head", "Anti Tank Guided Missile", "Armor Piercing Fin Stabilized Discarding Sabot", "Smoke" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Long Autoloader"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 70/50
		ShellLengthExact = 9
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "High Explosive Squash Head", "Anti Tank Guided Missile", "Armor Piercing Fin Stabilized Discarding Sabot", "Smoke" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Short Autoloader"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 40/50
		ShellLengthExact = 5
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "High Explosive Squash Head", "Anti Tank Guided Missile", "Armor Piercing Fin Stabilized Discarding Sabot", "Smoke" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Autoloading Howitzer"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 30/50
		ShellLengthExact = 4
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Explosive Squash Head", "Anti Tank Guided Missile", "Smoke" }
		DermaNumSlider:SetMinMax( 50, 240 )
	end
	gunData["Smoke Launcher"] = function()
		EntType   = "dak_temachinegun"
		ShellLength = 3/50
		ShellLengthExact = 0.5
		AmmoTypes = { "Smoke" }
		DermaNumSlider:SetMinMax( 40, 100 )
	end
	gunData["Grenade Launcher"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 27/50
		ShellLengthExact = 3.5
		AmmoTypes = { "High Explosive", "High Explosive Anti Tank", "High Explosive Squash Head", "Smoke" }
		DermaNumSlider:SetMinMax( 20, 45 )
	end
	gunData["Autoloading Mortar"] = function()
		EntType   = "dak_teautogun"
		ShellLength = 15/50
		ShellLengthExact = 2.75
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Explosive Squash Head", "Anti Tank Guided Missile", "Smoke" }
		DermaNumSlider:SetMinMax( 40, 420 )
	end
	gunData["Cannon"] = function()
		EntType   = "dak_tegun"
		ShellLength = 50/50
		ShellLengthExact = 6.5
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "High Explosive Squash Head", "Anti Tank Guided Missile", "Armor Piercing Fin Stabilized Discarding Sabot", "Smoke" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Long Cannon"] = function()
		EntType   = "dak_tegun"
		ShellLength = 70/50
		ShellLengthExact = 9
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "High Explosive Squash Head", "Anti Tank Guided Missile", "Armor Piercing Fin Stabilized Discarding Sabot", "Smoke" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Short Cannon"] = function()
		EntType   = "dak_tegun"
		ShellLength = 40/50
		ShellLengthExact = 5
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "High Explosive Squash Head", "Anti Tank Guided Missile", "Armor Piercing Fin Stabilized Discarding Sabot", "Smoke" }
		DermaNumSlider:SetMinMax( 25, 200 )
	end
	gunData["Flamethrower"] = function()
		EntType   = "dak_temachinegun"
		AmmoTypes = {}
	end
	gunData["Heavy Machine Gun"] = function()
		GunType   = "HMG"
		EntType   = "dak_teautogun"
		ShellLength = 40/50
		ShellLengthExact = 5
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Velocity Armor Piercing", "Armor Piercing Discarding Sabot", "Armor Piercing Fin Stabilized Discarding Sabot" }
		DermaNumSlider:SetMinMax( 20, 40 )
	end
	gunData["Howitzer"] = function()
		EntType   = "dak_tegun"
		ShellLength = 30/50
		ShellLengthExact = 4
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Explosive Squash Head", "Anti Tank Guided Missile", "Smoke" }
		DermaNumSlider:SetMinMax( 50, 240 )
	end
	gunData["Machine Gun"] = function()
		GunType   = "MG"
		EntType   = "dak_temachinegun"
		ShellLength = 50/50
		ShellLengthExact = 6.5
		AmmoTypes = { "Armor Piercing" }
		DermaNumSlider:SetMinMax( 5, 25 )
	end
	gunData["Mortar"] = function()
		EntType   = "dak_tegun"
		ShellLength = 15/50
		ShellLengthExact = 2.75
		AmmoTypes = { "Armor Piercing", "High Explosive", "Armor Piercing High Explosive", "High Explosive Anti Tank", "High Explosive Anti Tank Fin Stabilized", "High Explosive Squash Head", "Anti Tank Guided Missile", "Smoke"}
		DermaNumSlider:SetMinMax( 40, 420 )
	end
	
	--Table containing the volume of the available ammo crates
	local crateList = {}
	crateList["6x6x3 Ammo Box"] = function()
		Volume = 100.94901275635
	end
	crateList["6x6x6 Ammo Box"] = function()
		Volume = 205.37899780273
	end
	crateList["12x12x6 Ammo Box"] = function()
		Volume = 835.49890136719
	end
	crateList["12x12x12 Ammo Box"] = function()
		Volume = 1685.1589355469
	end
	crateList["24x12x12 Ammo Box"] = function()
		Volume = 3384.4787597656
	end
	crateList["24x24x12 Ammo Box"] = function()
		Volume = 6797.3989257813
	end
	crateList["24x24x24 Ammo Box"] = function()
		Volume = 13651.918945313
	end
	crateList["24x24x36 Ammo Box"] = function()
		Volume = 20506.4375
	end
	crateList["24x36x36 Ammo Box"] = function()
		Volume = 30802.55859375
	end
	crateList["24x36x48 Ammo Box"] = function()
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
		DLabel:SetText( "DakTank Guide: The Basics\n\nIn DakTanks tanks consist of props making up armor, a fuel tank, an engine, a gearbox, at least one gun, ammo, a seat, a turret controller, at least one crew member, and wiring all held together by the tank core entity.\n\nThe tank core must be parented to a gate that has been parented (NOT WELDED) to the baseplate of the tank. Doing this will pool the tank's health and allow your guns to fire.\n\nProps set to 1kg will be considered detail props by the system and will be entirely ignored by the damage system (but will count towards total pooled HP). Please set any detail props to 1kg." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Armor"] = function()
		DLabel:SetText( "DakTank Guide: Armor\n\nEach prop has its own armor value based on the mm protection of steel plate. The amount of protection you get on the prop is determined by its weight and volume, or simply put its density. A large prop will take much more weight than a small prop, but you'll need large props on your tank if you are to fit your equipment, larger equipment tends to offer much better bonuses than smaller counterparts.\n\nAngling your armor will increase its effective thickness, making it harder for your armor to be penetrated, though HE and HESH damage ignores slope.\n\nTreads (or anything you set to make spherical using the tool for it) have their own designated armor value based on the actual thickness of the prop then run through a modifier.\n\nTreads can be penetrated but take no damage, this lets you use them as extra armor for your sides that will reduce the damage they take slightly." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Spaced Armor"] = function()
		DLabel:SetText( "DakTank Guide: Spaced Armor\n\nSpaced armor is used to defeat HEAT rounds for minimal weight costs but high space costs. Heat rounds have an optimal standoff distance of about 7 calibers and drops off heavily to either side of that, meaning a 50mm HEAT round would have best pen when detonated 350mm from its impact zone. \n\nSpaced armor works by having an outer and inner layer of armor, the outer layer is spaced a certain distance away from the inner in an attempt to counter certain calibers of HEAT rounds. Against some rounds this will make them useless while others may become more powerful depending on the spacing. \n\nDue to Heat rounds losing pen over distance rapidly after detonation spaced armor will cause HEAT to lose 2.54mm of pen per inch, note that source units are inches." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Composite Armor"] = function()
		DLabel:SetText( "DakTank Guide: Composite Armor\n\nComposite armor provides 9.2mm protection against KE and 18.4mm protection against HEAT per inch(source unit) that is penned. Composite armor automatically sets its weight based on its volume and its protection based on how much of it is penned by a given shell. If something is clipped inside of a composite block shells will only take into account the amount of composite armor that was penned before hitting the clipping entity. \n\nIn general Composites prove to be more durable than armor for a given weight, though they take up much more space requiring the vehicle itself to be a larger target, which may also make it more costly to armor. \n\nComposites may be created from any prop on the vehicle by using the linker tool to select the props (must be prop_phsyics) and right clicking on the tank core." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Health"] = function()
		DLabel:SetText( "DakTank Guide: Health\n\nHealth determines just how much damage your tank can take and is totalled up by the tank core, health is based mainly on the armor weight of the vehicle in tons multiplied by 250, so two tanks can be the same total weight but have different health, the more armored one being stronger.\n\nHowever, health is modified further by size multipliers, which also affect rate of fire of cannons, howitzers, mortars, autocannons, and HMGs, if your tank is large for its weight it gains bonus health to improve its durability due to the higher cost to armor it, if a tank is small for its weight it will lose health but have an easy time armoring itself.\n\nRamming damage is calculated based on max health of a tank, it finds the total mass involved in the collision then each tank takes a percentage of the damage equal to the other tank's percentage of the weight, so a 5 ton tank ramming a 50 ton tank would take 11 times the damage that the 50 ton tank took. Each module has its own health value." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: AP Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: AP Ammunition\n\nAP rounds are your most basic type of shell, on pen they will go through armor plates until they run out of penetration then will be blocked or deflected away. Each time the shell penetrates something it will deal damage equal to its base damage value multiplied by its penetration divided by the effective armor value it went through capped at double the armor value.\n\nIt also will create spalling with penetration equal to one tenth of the armor it penetrated and damage based off the armor penetrated in a cone of 90 degrees multiplied by the armor divided by pen. This spalling cone is often deadly to crew and damages modules and may lead to killing tanks that lack spall liners in one shot.\n\nKE rounds suffer from T/D ratios influencing the effective armor of what they shoot, causing small caliber rounds to have more trouble against angled armor that has a raw armor value higher than their caliber." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HE Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HE Ammunition\n\nHE fires an explosive shell at its target. It has penetration equal to 30% of an AP round's penetration and acts as an AP until it finds something it cannot penetrate, at which point it explodes, creating fragments equal to half the caliber. Each fragment acts as an AP shell that generates no spalling. HE is extremely powerful against low armor and very effective if you get a penetrating shot and explode inside.\n\nHE is also very effective against low thickness but highly angled armor. HE's fragmentation based nature can be very random with lower chances to hit targets further from the Blast Radius, you'll do much more damage on direct hits than splashes. Shots to thin armor may allow harmful fragmentation to damage internals." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: APHE Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: APHE Ammunition\n\nAPHE rounds act as an AP round until after their first penetration at which point it will explode after its fuse distance of 25 units expires. Since the APHE round is still traveling when it explodes the fragments travel in a cone in the direction of the shell that expands based on the caliber of the shell rather than exploding radially in the case of regular HE, however in the case of the APHE round hitting something and being unable to pen it acts like an HE shell with half the blast radius. Due to APHE's fuses, it can be triggered by spaced armor, rendering in ineffective against some designs." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HEAT Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HEAT Ammunition\n\nHEAT shells lose no penetration over range and do not suffer from TD ratios as KE rounds do, only seeing armor as its LOS thickness, however, it can be quickly defeated by proper spacing and/or composites. On impact the shell propels an explosively formed rod towards the enemy armor in an attempt to penetrate it. In WWII era fights HEAT shells trade raw penetration for penetration against angles and penetration at distance, in cold war and modern era it acts as a lower pen but much higher post pen alternative to HEATFS. In cases where there is no penetration the shell acts like a low powered HE shell." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HEATFS Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HEATFS Ammunition\n\nHEATFS shells lose no penetration over range and have extremely high penetration but are more susceptable to composites than APFSDS. On impact the shell propels an explosively formed rod towards the enemy armor in an attempt to penetrate it. On penetration the shell will deal damage in a beam forward, with penetration quickly falling off, spalling is created equal to an HVAP shell penetration with an explosion half the power of an HE shell's on the exterior. In cases where there is no penetration the shell acts like a low powered HE shell." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HVAP Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HVAP Ammunition\n\nHVAP, also known as APCR (Armor Piercing Composite Rigid) to the brits, has more penetration and velocity than AP at the cost of significantly lower damage, post pen effects, and much worse slope modifiers. It also loses pen over distance faster. Even with all these drawbacks, it still ends up generally having more pen than AP at general engagement ranges and is useful for taking out heavy armor." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: APDS Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: APDS Ammunition\n\nAPDS a step in development past APCR/HVAP, due to its higher cross sectional density it is less affected by drag, allowing it to keep more of its penetration and speed at range, it also has somewhat higher base penetration values and better performance against slopes due to its higher Length/Diameter ratio." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: APFSDS Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: APFSDS Ammunition\n\nAPFSDS rounds have the highest penetration values of any KE round but have rather low shell diameters resulting in rather low post pen effects, a compound issue of extremely thin spall cone due to overpenetration of armor and low shell diameters makes it nearly useless against light armor aside from sniping crew out directly, though it still maintains its position as one of the few rounds that can crack an MBT's frontal armor." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: HESH Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: HESH Ammunition\n\nHESH shells fire a mass of plastic explosive at a target, spreading out on impact then detonating. It doesn't really penetrate the armor, but it is designed to create powerful spalling that damages the internals of the tank. Due to the nature of how HESH works, it totally ignores the effects of angling armor and penetrates based on the raw armor value. The explosion it generates lacks the fragmentation component found in HE and HEAT, but retains the powerful shockwave." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: ATGM Ammunition"] = function()
		DLabel:SetText( "DakTank Guide: ATGM Ammunition\n\nATGMs are Anti Tank Guided Munitions which may or may not be Gun Launched. Once launched they will attempt to angle themselves towards the position painted by the indicator. \n\nGuns and Launchers have an indicator input that allows you to wire any entity that is part of the vehicle up as the indicator, a ranger pointing forward from the indicator's position will guide the missile. In cases where there is no indicator the gun/launcher will be used as the indicator. If the indicator is not a part of the contratpion the missile's guidance will not work properly." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Weaponry"] = function()
		DLabel:SetText( "DakTank Guide: Weaponry\n\nIn DakTanks there are cannons, howitzers, autoloaders, mortars, autocannons, heavy machine guns, and machine guns.\n\nCannons are your basic weapon type and have access to any ammo type.\n\nHowitzers are lighter and shorter than cannons and so are their shells giving them faster refire rates at the cost of damage per shot and velocity.\n\nAutoloaders are cannons that require a magazine module but no crew, they can fire devastating bursts in a short period of time but can have very long reloading periods.\n\nMortars are low velocity HE/HEAT/HESH focused guns.\n\nAutocannons are low caliber guns that rapidly fire a magazine of shells then must be reloaded by the crew.\n\nHMGs are short barreled autocannons, they are lighter and fire smaller shells, allowing them a few more rounds per magazine.\n\nMachine Guns are rapid fire guns with only access to AP rounds, light caliber ones only are useful for anti infantry, though heavier machine guns can be deadly against light armor." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Flamethrowers"] = function()
		DLabel:SetText( "DakTank Guide: Flamethrowers\n\nFlamethrowers are a special weapon type that softens armor it hits over time to a minimum of half of its original value.\n\nFlamethrowers also can overheat the engines of a vehicle, reducing the power and eventually stalling a tank, making it easy to flank or easy to hit. They will also ignite infantry caught in the impact zone, dealing burn damage over the next 5 seconds.\n\nFlamethrowers require a lot of fuel to keep them firing, allowing only 15 seconds of fire per fuel tank. This means that dedicated flamethrower tanks will either need to be very large, have external tanks, or bring along a somewhat vulnerable fuel trailer or they'll be limited to short bursts of fire.\n\nFlamethrower fuel tanks have more armor and health than regular ammo crates but are also heavier and larger. However, their combination of armor and health makes them very vulnerable to crits from guns that do penetrate their armor." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Mobility"] = function()
		DLabel:SetText( "DakTank Guide: Mobility\n\nVehicle speed is determined by your combined engine power, modified by how much fuel you have and total weight of the vehicle.\n\nGiven the same engine and fuel tank a 30 ton tank will move twice as fast as a 60 tonner and will turn faster.\n\nYou can use as many engines or fuel tanks as you want, each engine requires a certain amount of fuel and each fuel tank has a certain amount of fuel. Having less fuel than you require reduces your power output.\n\nEach gearbox can only handle a certain amount of power and each tank can only support one gearbox, providing more power to the gearbox than it can handle will result in waste power.\n\nDamage will reduce the stats of each of the mobility entities, potentially immobilizing you. You could create large but fast and lightly armored vehicles or small but slow and heavily armored vehicles. The faster vehicle would be good against heavier tanks that it could flank while the heavy vehicle would be good for dominating tanks that can't pen it." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Critical Hits"] = function()
		DLabel:SetText( "DakTank Guide: Critical Hits\n\nCertain components such as fuel, ammo, and autoloader magazines can suffer from catastrophic failure in cases in which they are reduced to less than quarter health but not outright destroyed.\n\nUpon exploding these entities will deal between the entities nearby.\n\nAmmo boxes can have their ammo ejected via its wire input to avoid such failures in dire circumstances, though it can take a few seconds to empty out fully.\n\nCrit explosions function just like HE explosions, so damage may be much higher than stated, this gives some reason to place explosive items in the front of the tank or in an armored location so that the frontal armor absorbs some of the damage.\n\nSolid shot ammo cooks off instead of exploding outright, causing multiple internal penetrations to occur in a short time span, then has a chance to explode if the box doesn't empty quickly." )
		DLabel:SetVisible( true )
	end
	selection["DakTank Guide: Crew"] = function()
		DLabel:SetText( "DakTank Guide: Crew\n\nCrew greatly improve the performance of a tank they are working on, each crew member is relatively light but takes up a sizeable area. Crew can be tasked with driving or loading while a turret motor can assist in improving turret rotation speeds.\n\nOnly one crew member can be driver at once but you can have as many loaders as you want, though going over the loader requirement for a gun offers no benefits aside from having backup loaders incase one dies.\n\nMachineguns and Autoloaders cannot be crewed, as they are fully automated. Crew members are lightly armored and have low health, making them easy to lose in the case of an armor penetration, having many crew members taken out at once can be cripling and being reduced to no crew knocks out the tank, be sure to keep them safe." )
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
	selection["Sitting Crew Member"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_crew" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "CrewSitting" )
		DLabel:SetText( "Crew Member\n\nAllows an entity to function up to their full potential when linked to it. Can be linked to engines, normal guns, autocannons, and HMGs, but not autoloaders or machine guns.\n\nCrew Stats:\nHealth:  5\nWeight: 75kg" )
		DLabel:SetVisible( true )
	end
	selection["Standing Crew Member"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_crew" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "CrewStanding" )
		DLabel:SetText( "Crew Member\n\nAllows an entity to function up to their full potential when linked to it. Can be linked to engines, normal guns, autocannons, and HMGs, but not autoloaders or machine guns.\n\nCrew Stats:\nHealth:  5\nWeight: 75kg" )
		DLabel:SetVisible( true )
	end
	selection["Driver Position Crew Member"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_crew" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "CrewDriver" )
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
	selection["Auto Tread Gearboxes"] = function()
		GearboxDirectionSelect:SetVisible( true )
		DLabel:SetVisible( true )
		DLabel:SetPos( 15, 405 )

		if GearboxDirectionSelect:GetSelectedID() ~= nil then
			GearboxModelSelect:SetVisible( true )
		end
		
		if GearboxModelSelect:GetSelectedID() == nil then
			DLabel:SetText( "Auto Tread Gearboxes\n\nTransfers the power of your engines to the wheels, you'll need heavy gearboxes to handle high power engines. Comes with auto generated treads for easy editing." )
		else
			gearboxList[GearboxModel]()
			RunConsoleCommand( "daktankspawner_SpawnSettings", string.Replace( GearboxModel, " ", "" )..string.sub( GearboxDirection, 1, 1 ) )
			RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_tegearboxnew" )
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
	--launchers--
	selection["Ground 100mm x2"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "2G100" )
		DLabel:SetText( "2xLauncher Ground Model" )
		DLabel:SetVisible( true )
	end
	selection["Ground 100mm x3"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "3G100" )
		DLabel:SetText( "3xLauncher Ground Model" )
		DLabel:SetVisible( true )
	end
	selection["Ground 100mm x5"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "5G100" )
		DLabel:SetText( "5xLauncher Ground Model" )
		DLabel:SetVisible( true )
	end
	selection["Ground 100mm x6"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "6G100" )
		DLabel:SetText( "6xLauncher Ground Model" )
		DLabel:SetVisible( true )
	end
	selection["Ground 100mm x10"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "10G100" )
		DLabel:SetText( "10xLauncher Ground Model" )
		DLabel:SetVisible( true )
	end
	selection["Air 100mm x3"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "3A100" )
		DLabel:SetText( "3xLauncher Air Model" )
		DLabel:SetVisible( true )
	end
	selection["Air 100mm x5"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "5A100" )
		DLabel:SetText( "5xLauncher Air Model" )
		DLabel:SetVisible( true )
	end
	selection["Air 100mm x6"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "6A100" )
		DLabel:SetText( "6xLauncher Air Model" )
		DLabel:SetVisible( true )
	end
	selection["Air 100mm x10"] = function()
		RunConsoleCommand( "daktankspawner_SpawnEnt", "dak_teautogun" )
		RunConsoleCommand( "daktankspawner_SpawnSettings", "10A100" )
		DLabel:SetText( "10xLauncher Air Model" )
		DLabel:SetVisible( true )
	end


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
			DLabel:SetText( "Flamethrower Fuel\n\nFlamethrower fuel tank, more armored than normal ammo boxes but more likely to be crit, use with caution.\n\nCrate Stats:\nArmor:  12.5mm\nWeight: 500kg\nHealth:  30\n\nFuel Stats:\nCapacity:      15 seconds\nDamage:        5\nRate of Fire: 600 streams/minute" )
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
				local ShellVol = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*6.5)
				local ShellLenMult = 6.5
				local ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))

				if Caliber < 40 then
					if AmmoTypeSelect:GetValue() == "Anti Tank Guided Missile" then
						AmmoTypeSelect:SetValue("High Explosive Anti Tank")
						AmmoCrate = String[1].."HEAT"..String[3]
						AmmoType = "HEAT"
					end
				end
				--NOTE: shell volume formula is pi * ( ( Caliber * 0.5*mm to inch multiplier)^2 )*Caliber*(mm to inch multiplier*shell length mult*2)
				if AmmoBoxSelect:GetSelected() == "Howitzer" or AmmoBoxSelect:GetSelected() == "Autoloading Howitzer" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*4)
					ShellLenMult = 4
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
				elseif AmmoBoxSelect:GetSelected() == "Smoke Launcher" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*1.375)
					ShellLenMult = 1.375
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
				elseif AmmoBoxSelect:GetSelected() == "Grenade Launcher" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*3.5)
					ShellLenMult = 3.5
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
				elseif AmmoBoxSelect:GetSelected() == "Mortar" or  AmmoBoxSelect:GetSelected() == "AutoloadingMortar" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*2.75)
					ShellLenMult = 2.75
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
				elseif AmmoBoxSelect:GetSelected() == "Short Cannon" or AmmoBoxSelect:GetSelected() == "Heavy Machine Gun" or AmmoBoxSelect:GetSelected() == "Short Autoloader" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*5)
					ShellLenMult = 5
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
				elseif AmmoBoxSelect:GetSelected() == "Long Cannon" or AmmoBoxSelect:GetSelected() == "Long Autoloader" then
					ShellVol 	 = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*(0.0393701*2*9)
					ShellLenMult = 9
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
				end

				local ShellMass = ShellVol * 0.044
				AmmoCount 		= math.floor(Volume/ShellVolSquare)
				AmmoWeight 		= math.Round(10+(AmmoCount*ShellMass))

				if AmmoType == "ATGM" then
					ShellVol = math.pi*( ( Caliber*0.01968505 )^2 )*Caliber*0.5118113 * 1.5
					ShellLenMult = 6.5
					ShellVolSquare = ( ( Caliber*0.0393701 )^2 )*(Caliber*0.0393701*(ShellLenMult*2))
					ShellMass = ShellVol * 0.044
					AmmoCount 		= math.Round(math.floor(Volume/ShellVolSquare)*(1/1.5))
					AmmoWeight 		= math.Round(10+(AmmoCount*ShellMass))
				end

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
	AmmoBoxSelect:AddChoice( "Long Autoloader" )
	AmmoBoxSelect:AddChoice( "Short Autoloader" )
	AmmoBoxSelect:AddChoice( "Autoloading Howitzer" )
	AmmoBoxSelect:AddChoice( "Autoloading Mortar" )
	AmmoBoxSelect:AddChoice( "Short Cannon" )
	AmmoBoxSelect:AddChoice( "Cannon" )
	AmmoBoxSelect:AddChoice( "Launcher" )
	AmmoBoxSelect:AddChoice( "Long Cannon" )
	AmmoBoxSelect:AddChoice( "Flamethrower" )
	AmmoBoxSelect:AddChoice( "Heavy Machine Gun" )
	AmmoBoxSelect:AddChoice( "Howitzer" )
	AmmoBoxSelect:AddChoice( "Machine Gun" )
	AmmoBoxSelect:AddChoice( "Smoke Launcher" )
	AmmoBoxSelect:AddChoice( "Grenade Launcher" )
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
		if ( #String > 4 ) then
			AmmoType = string.sub( String[1], 1, 1 )..string.sub( String[2], 1, 1 )..string.sub( String[3], 1, 1 )..string.sub( String[4], 1, 1 )..string.sub( String[5], 1, 1 ) ..string.sub( String[6], 1, 1 ) 
		elseif ( #String > 2 ) then 
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
	AmmoModelSelect:AddChoice( "6x6x3 Ammo Box" )
	AmmoModelSelect:AddChoice( "6x6x6 Ammo Box" )
	AmmoModelSelect:AddChoice( "12x12x6 Ammo Box" )
	AmmoModelSelect:AddChoice( "12x12x12 Ammo Box" )
	AmmoModelSelect:AddChoice( "24x12x12 Ammo Box" )
	AmmoModelSelect:AddChoice( "24x24x12 Ammo Box" )
	AmmoModelSelect:AddChoice( "24x24x24 Ammo Box" )
	AmmoModelSelect:AddChoice( "24x24x36 Ammo Box" )
	AmmoModelSelect:AddChoice( "24x36x36 Ammo Box" )
	AmmoModelSelect:AddChoice( "24x36x48 Ammo Box" )
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
		DTTE_NodeList["Help15"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Spaced Armor", "icon16/page.png" )
		DTTE_NodeList["Help16"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Composite Armor", "icon16/page.png" )
		DTTE_NodeList["Help3"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Health", "icon16/page.png" )
		DTTE_NodeList["Help4"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: AP Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help5"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HE Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help17"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: APHE Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help6"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HEAT Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help12"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HVAP Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help20"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: APDS Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help13"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HESH Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help18"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: HEATFS Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help19"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: APFSDS Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help14"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: ATGM Ammunition", "icon16/page.png" )
		DTTE_NodeList["Help7"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Weaponry", "icon16/page.png" )
		DTTE_NodeList["Help8"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Flamethrowers", "icon16/page.png" )
		DTTE_NodeList["Help9"] 	= DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Mobility", "icon16/page.png" )
		DTTE_NodeList["Help10"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Critical Hits", "icon16/page.png" )
		DTTE_NodeList["Help11"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Crew", "icon16/page.png" )

	DTTE_NodeList["Utilities"] 	  = ctrl:AddNode( "Utilities", "icon16/folder_brick.png" )
		DTTE_NodeList["Core"] 	  = DTTE_NodeList["Utilities"]:AddNode( "Tank Core", "icon16/cog.png" )
		DTTE_NodeList["Crew1"] 	  = DTTE_NodeList["Utilities"]:AddNode( "Standing Crew Member", "icon16/cog.png" )	
		DTTE_NodeList["Crew2"] 	  = DTTE_NodeList["Utilities"]:AddNode( "Sitting Crew Member", "icon16/cog.png" )	
		DTTE_NodeList["Crew3"] 	  = DTTE_NodeList["Utilities"]:AddNode( "Driver Position Crew Member", "icon16/cog.png" )	
		DTTE_NodeList["TControl"] = DTTE_NodeList["Utilities"]:AddNode( "Turret Controller", "icon16/cog.png" )
		DTTE_NodeList["TMotor"]   = DTTE_NodeList["Utilities"]:AddNode( "Turret Motor", "icon16/cog.png" )

	DTTE_NodeList["Mobility"] 	 = ctrl:AddNode( "Mobility", "icon16/folder_wrench.png" )
		DTTE_NodeList["Engine"]  = DTTE_NodeList["Mobility"]:AddNode( "Engines", "icon16/cog.png" )
		DTTE_NodeList["Fuel"] 	 = DTTE_NodeList["Mobility"]:AddNode( "Fuel Tanks", "icon16/cog.png" )
		DTTE_NodeList["Gearbox"] = DTTE_NodeList["Mobility"]:AddNode( "Gearboxes", "icon16/cog.png" )
		DTTE_NodeList["Auto Tread Gearbox"] = DTTE_NodeList["Mobility"]:AddNode( "Auto Tread Gearboxes", "icon16/cog.png" )

	DTTE_NodeList["Weapons"] 	 	= ctrl:AddNode( "Weaponry", "icon16/folder_wrench.png" )
		DTTE_NodeList["Launcher"]	= ctrl:AddNode( "Missile Launchers", "icon16/folder_wrench.png" )
			DTTE_NodeList["2G100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Ground 100mm x2", "icon16/cog.png" )
			DTTE_NodeList["3G100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Ground 100mm x3", "icon16/cog.png" )
			DTTE_NodeList["5G100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Ground 100mm x5", "icon16/cog.png" )
			DTTE_NodeList["6G100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Ground 100mm x6", "icon16/cog.png" )
			DTTE_NodeList["10G100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Ground 100mm x10", "icon16/cog.png" )
			DTTE_NodeList["3A100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Air 100mm x3", "icon16/cog.png" )
			DTTE_NodeList["5A100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Air 100mm x5", "icon16/cog.png" )
			DTTE_NodeList["6A100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Air 100mm x6", "icon16/cog.png" )
			DTTE_NodeList["10A100"] 	= DTTE_NodeList["Launcher"]:AddNode( "Air 100mm x10", "icon16/cog.png" )
		DTTE_NodeList["Weapon"] 	= DTTE_NodeList["Weapons"]:AddNode( "Weapons", "icon16/cog.png" )
		DTTE_NodeList["ALMagazine"] = DTTE_NodeList["Weapons"]:AddNode( "Autoloader Magazines", "icon16/cog.png" )
		DTTE_NodeList["Ammo"] 		= DTTE_NodeList["Weapons"]:AddNode( "Ammunition", "icon16/cog.png" )
end

function TOOL:Think()
end