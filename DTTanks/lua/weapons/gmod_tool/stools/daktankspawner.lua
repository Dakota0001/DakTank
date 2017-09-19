 
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
TOOL.ClientConVar[ "SpawnEnt" ] = ""
TOOL.ClientConVar[ "SpawnSettings" ] = ""
TOOL.ClientConVar[ "SpawnMod" ] = 1
TOOL.ClientConVar[ "PTSpawnMod" ] = 1
TOOL.ClientConVar[ "STSpawnMod" ] = 1

//setup gun info requirements
TOOL.DakName = "Base Ammo Gun"
TOOL.DakCooldown = 1
TOOL.DakHeat = 1
TOOL.DakMaxHealth = 1
TOOL.DakHealth = 1
TOOL.DakAmmo = 0
TOOL.DakMass = 1
TOOL.DakEngine = NULL
TOOL.DakModel = "models/daktanks/cannon25mm.mdl"
TOOL.DakUseAmmo = true
TOOL.DakAmmoType = "AC2Ammo"
TOOL.DakAmmoUse = "AC2AmmoUse"
TOOL.DakAmmoQueue = "AC2AmmoUseQueue"
TOOL.DakFireEffect = "dakac5fire"
TOOL.DakShellType = "dak_baseshell"
TOOL.DakFireSound = "dak/AC5.wav"
TOOL.DakFirePitch = 90
TOOL.DakFireSpecialShell = false
TOOL.DakShellEnt = "dak_baseshell"
TOOL.DakIsLBX = false
TOOL.DakLBXPellets = 1
TOOL.DakIsExplosive = false
TOOL.DakIsRAC = false
TOOL.DakIsUAC = false
//setup gun shell info requirements
TOOL.DakShellTrail = "ac2trail"
TOOL.DakShellVelocity = 25000
TOOL.DakShellDamage = 2
TOOL.DakShellExplosionEffect = "daksmallballisticexplosion"
TOOL.DakShellGravity = true
TOOL.DakShellMass = 20
TOOL.DakShellImpactSound = "dak/ballisticimpact.wav"
TOOL.DakShellImpactPitch = 75
//setup ammo box info requirements
TOOL.DakName = "AC2 Ammo"
TOOL.DakIsExplosive = true
TOOL.DakAmmo = 10
TOOL.DakMaxAmmo = 10
TOOL.DakAmmoType = "AC2"
//setup hoverdrive and motor info requirements
TOOL.DakName = "Light Hoverdrive"
TOOL.DakMaxHealth = 50
TOOL.DakHealth = 50
TOOL.DakModel = "models/daktanks/cannon25mm.mdl"
TOOL.DakSpeed = 0.5
TOOL.DakMass = 5000
TOOL.DakSound = "npc/combine_gunship/engine_whine_loop1.wav"

 
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
			self.DakMass = 1250
			self.DakSpeed = 1.675
			self.DakEngine = NULL
			self.DakModel = "models/daktanks/engine1.mdl"
			self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "SmallEngine" then
			self.DakName = "Small Engine"
			self.DakHealth = 30
			self.DakMaxHealth = 30
			self.DakMass = 1875
			self.DakSpeed = 2.68
			self.DakEngine = NULL
			self.DakModel = "models/daktanks/engine2.mdl"
			self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "StandardEngine" then
			self.DakName = "Standard Engine"
			self.DakHealth = 45
			self.DakMaxHealth = 45
			self.DakMass = 2500
			self.DakSpeed = 3.685
			self.DakEngine = NULL
			self.DakModel = "models/daktanks/engine3.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_idle_loop1.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "LargeEngine" then
			self.DakName = "Large Engine"
			self.DakHealth = 60
			self.DakMaxHealth = 60
			self.DakMass = 3125
			self.DakSpeed = 4.69
			self.DakEngine = NULL
			self.DakModel = "models/daktanks/engine4.mdl"
			self.DakSound = "vehicles/crane/crane_idle_loop3.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "HugeEngine" then
			self.DakName = "Huge Engine"
			self.DakHealth = 75
			self.DakMaxHealth = 75
			self.DakMass = 3750
			self.DakSpeed = 5.695
			self.DakEngine = NULL
			self.DakModel = "models/daktanks/engine5.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
		end
		if self:GetClientInfo("SpawnSettings") == "UltraEngine" then
			self.DakName = "Ultra Engine"
			self.DakHealth = 90
			self.DakMaxHealth = 90
			self.DakMass = 5000
			self.DakSpeed = 6.7
			self.DakEngine = NULL
			self.DakModel = "models/daktanks/engine6.mdl"
			self.DakSound = "vehicles/airboat/fan_motor_fullthrottle_loop1.wav"
		end
		--CLIPS--
		if self:GetClientInfo("SpawnSettings") == "SALClip" then
			self.DakMaxHealth = 50
			self.DakHealth = 50
			self.DakName = "Small Autoloader Clip"
			self.DakModel = "models/daktanks/alclip1.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "MALClip" then
			self.DakMaxHealth = 75
			self.DakHealth = 75
			self.DakName = "Medium Autoloader Clip"
			self.DakModel = "models/daktanks/alclip2.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "LALClip" then
			self.DakMaxHealth = 100
			self.DakHealth = 100
			self.DakName = "Large Autoloader Clip"
			self.DakModel = "models/daktanks/alclip3.mdl"
		end
		--GUNS--
		--Heavy Machine Guns
		if self:GetClientInfo("SpawnSettings") == "20mmHMG" then
			self.DakMaxHealth = 100
			self.DakName = "20mm Heavy Machine Gun"
			self.DakModel = "models/daktanks/hmg20mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "30mmHMG" then
			self.DakMaxHealth = 100
			self.DakName = "30mm Heavy Machine Gun"
			self.DakModel = "models/daktanks/hmg30mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "40mmHMG" then
			self.DakMaxHealth = 100
			self.DakName = "40mm Heavy Machine Gun"
			self.DakModel = "models/daktanks/hmg40mm.mdl"
		end
		--Machine Guns
		if self:GetClientInfo("SpawnSettings") == "5.56mmMG" then
			self.DakMaxHealth = 100
			self.DakName = "5.56mm Machine Gun"
			self.DakModel = "models/daktanks/mg556mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "7.62mmMG" then
			self.DakMaxHealth = 100
			self.DakName = "7.62mm Machine Gun"
			self.DakModel = "models/daktanks/mg762mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "9mmMG" then
			self.DakMaxHealth = 100
			self.DakName = "9mm Machine Gun"
			self.DakModel = "models/daktanks/mg9mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "12.7mmMG" then
			self.DakMaxHealth = 100
			self.DakName = "12.7mm Machine Gun"
			self.DakModel = "models/daktanks/mg127mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "14.5mmMG" then
			self.DakMaxHealth = 100
			self.DakName = "14.5mm Machine Gun"
			self.DakModel = "models/daktanks/mg145mm.mdl"
		end
		--AutoLoaders
		if self:GetClientInfo("SpawnSettings") == "50mmAL" then
			self.DakMaxHealth = 100
			self.DakName = "50mm Autoloader"
			self.DakModel = "models/daktanks/al50mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmAL" then
			self.DakMaxHealth = 100
			self.DakName = "75mm Autoloader"
			self.DakModel = "models/daktanks/al75mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "100mmAL" then
			self.DakMaxHealth = 100
			self.DakName = "100mm Autoloader"
			self.DakModel = "models/daktanks/al100mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmAL" then
			self.DakMaxHealth = 100
			self.DakName = "120mm Autoloader"
			self.DakModel = "models/daktanks/al120mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "152mmAL" then
			self.DakMaxHealth = 100
			self.DakName = "152mm Autoloader"
			self.DakModel = "models/daktanks/al152mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "200mmAL" then
			self.DakMaxHealth = 100
			self.DakName = "200mm Autoloader"
			self.DakModel = "models/daktanks/al200mm.mdl"
		end
		--AutoCannons
		if self:GetClientInfo("SpawnSettings") == "25mmAC" then
			self.DakMaxHealth = 100
			self.DakName = "25mm Autocannon"
			self.DakModel = "models/daktanks/ac25mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "37mmAC" then
			self.DakMaxHealth = 100
			self.DakName = "37mm Autocannon"
			self.DakModel = "models/daktanks/ac37mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "50mmAC" then
			self.DakMaxHealth = 100
			self.DakName = "50mm Autocannon"
			self.DakModel = "models/daktanks/ac50mm.mdl"
		end
		--Cannons
		if self:GetClientInfo("SpawnSettings") == "25mmC" then
			self.DakMaxHealth = 100
			self.DakName = "25mm Cannon"
			self.DakModel = "models/daktanks/cannon25mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "37mmC" then
			self.DakMaxHealth = 100
			self.DakName = "37mm Cannon"
			self.DakModel = "models/daktanks/cannon37mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "50mmC" then
			self.DakMaxHealth = 100
			self.DakName = "50mm Cannon"
			self.DakModel = "models/daktanks/cannon50mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmC" then
			self.DakMaxHealth = 100
			self.DakName = "75mm Cannon"
			self.DakModel = "models/daktanks/cannon75mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "100mmC" then
			self.DakMaxHealth = 100
			self.DakName = "100mm Cannon"
			self.DakModel = "models/daktanks/cannon100mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmC" then
			self.DakMaxHealth = 100
			self.DakName = "120mm Cannon"
			self.DakModel = "models/daktanks/cannon120mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "152mmC" then
			self.DakMaxHealth = 100
			self.DakName = "152mm Cannon"
			self.DakModel = "models/daktanks/cannon152mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "200mmC" then
			self.DakMaxHealth = 100
			self.DakName = "200mm Cannon"
			self.DakModel = "models/daktanks/cannon200mm.mdl"
		end
		--Howitzers
		if self:GetClientInfo("SpawnSettings") == "50mmH" then
			self.DakMaxHealth = 100
			self.DakName = "50mm Howitzer"
			self.DakModel = "models/daktanks/howitzer50mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmH" then
			self.DakMaxHealth = 100
			self.DakName = "75mm Howitzer"
			self.DakModel = "models/daktanks/howitzer75mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "105mmH" then
			self.DakMaxHealth = 100
			self.DakName = "105mm Howitzer"
			self.DakModel = "models/daktanks/howitzer105mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "122mmH" then
			self.DakMaxHealth = 100
			self.DakName = "122mm Howitzer"
			self.DakModel = "models/daktanks/howitzer122mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "155mmH" then
			self.DakMaxHealth = 100
			self.DakName = "155mm Howitzer"
			self.DakModel = "models/daktanks/howitzer155mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "203mmH" then
			self.DakMaxHealth = 100
			self.DakName = "203mm Howitzer"
			self.DakModel = "models/daktanks/howitzer203mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "420mmH" then
			self.DakMaxHealth = 100
			self.DakName = "420mm Howitzer"
			self.DakModel = "models/daktanks/howitzer420mm.mdl"
		end
		--Mortars
		if self:GetClientInfo("SpawnSettings") == "60mmM" then
			self.DakMaxHealth = 100
			self.DakName = "60mm Mortar"
			self.DakModel = "models/daktanks/mortar60mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "90mmM" then
			self.DakMaxHealth = 100
			self.DakName = "90mm Mortar"
			self.DakModel = "models/daktanks/mortar90mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmM" then
			self.DakMaxHealth = 100
			self.DakName = "120mm Mortar"
			self.DakModel = "models/daktanks/mortar120mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "150mmM" then
			self.DakMaxHealth = 100
			self.DakName = "150mm Mortar"
			self.DakModel = "models/daktanks/mortar150mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "240mmM" then
			self.DakMaxHealth = 100
			self.DakName = "240mm Mortar"
			self.DakModel = "models/daktanks/mortar240mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "280mmM" then
			self.DakMaxHealth = 100
			self.DakName = "280mm Mortar"
			self.DakModel = "models/daktanks/mortar280mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "420mmM" then
			self.DakMaxHealth = 100
			self.DakName = "420mm Mortar"
			self.DakModel = "models/daktanks/mortar420mm.mdl"
		end
		if self:GetClientInfo("SpawnSettings") == "600mmM" then
			self.DakMaxHealth = 100
			self.DakName = "600mm Mortar"
			self.DakModel = "models/daktanks/mortar600mm.mdl"
		end
		--AMMO--
		--20mmHMG
		if self:GetClientInfo("SpawnSettings") == "20mmHMGAPAmmo" then
			self.DakName = "20mmHMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 70
			self.DakMaxAmmo = 70
			self.DakAmmoType = "20mmHMGAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "20mmHMGHEAmmo" then
			self.DakName = "20mmHMGHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 70
			self.DakMaxAmmo = 70
			self.DakAmmoType = "20mmHMGHEAmmo"
		end
		--30mmHMG
		if self:GetClientInfo("SpawnSettings") == "30mmHMGAPAmmo" then
			self.DakName = "30mmHMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 50
			self.DakMaxAmmo = 50
			self.DakAmmoType = "30mmHMGAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "30mmHMGHEAmmo" then
			self.DakName = "30mmHMGHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 50
			self.DakMaxAmmo = 50
			self.DakAmmoType = "30mmHMGHEAmmo"
		end
		--40mmHMG
		if self:GetClientInfo("SpawnSettings") == "40mmHMGAPAmmo" then
			self.DakName = "40mmHMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 40
			self.DakMaxAmmo = 40
			self.DakAmmoType = "40mmHMGAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "40mmHMGHEAmmo" then
			self.DakName = "40mmHMGHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 40
			self.DakMaxAmmo = 40
			self.DakAmmoType = "40mmHMGHEAmmo"
		end
		--5.56mmMG
		if self:GetClientInfo("SpawnSettings") == "5.56mmMGAPAmmo" then
			self.DakName = "5.56mmMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 500
			self.DakMaxAmmo = 500
			self.DakAmmoType = "5.56mmMGAPAmmo"
		end
		--7.62mmMG
		if self:GetClientInfo("SpawnSettings") == "7.62mmMGAPAmmo" then
			self.DakName = "7.62mmMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 425
			self.DakMaxAmmo = 425
			self.DakAmmoType = "7.62mmMGAPAmmo"
		end
		--9mmMG
		if self:GetClientInfo("SpawnSettings") == "9mmMGAPAmmo" then
			self.DakName = "9mmMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 350
			self.DakMaxAmmo = 350
			self.DakAmmoType = "9mmMGAPAmmo"
		end
		--12.7mmMG
		if self:GetClientInfo("SpawnSettings") == "12.7mmMGAPAmmo" then
			self.DakName = "12.7mmMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 275
			self.DakMaxAmmo = 275
			self.DakAmmoType = "12.7mmMGAPAmmo"
		end
		--14.5mmMG
		if self:GetClientInfo("SpawnSettings") == "14.5mmMGAPAmmo" then
			self.DakName = "14.5mmMGAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 200
			self.DakMaxAmmo = 200
			self.DakAmmoType = "14.5mmMGAPAmmo"
		end
		--25mmC
		if self:GetClientInfo("SpawnSettings") == "25mmCAPAmmo" then
			self.DakName = "25mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 50
			self.DakMaxAmmo = 50
			self.DakAmmoType = "25mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "25mmCHEAmmo" then
			self.DakName = "25mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 50
			self.DakMaxAmmo = 50
			self.DakAmmoType = "25mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "25mmCFLAmmo" then
			self.DakName = "25mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 50
			self.DakMaxAmmo = 50
			self.DakAmmoType = "25mmCFLAmmo"
		end
		--37mmC
		if self:GetClientInfo("SpawnSettings") == "37mmCAPAmmo" then
			self.DakName = "37mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 35
			self.DakMaxAmmo = 35
			self.DakAmmoType = "37mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "37mmCHEAmmo" then
			self.DakName = "37mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 35
			self.DakMaxAmmo = 35
			self.DakAmmoType = "37mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "37mmCFLAmmo" then
			self.DakName = "37mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 35
			self.DakMaxAmmo = 35
			self.DakAmmoType = "37mmCFLAmmo"
		end
		--50mmC
		if self:GetClientInfo("SpawnSettings") == "50mmCAPAmmo" then
			self.DakName = "50mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 20
			self.DakMaxAmmo = 20
			self.DakAmmoType = "50mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "50mmCHEAmmo" then
			self.DakName = "50mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 20
			self.DakMaxAmmo = 20
			self.DakAmmoType = "50mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "50mmCFLAmmo" then
			self.DakName = "50mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 20
			self.DakMaxAmmo = 20
			self.DakAmmoType = "50mmCFLAmmo"
		end
		--75mmC
		if self:GetClientInfo("SpawnSettings") == "75mmCAPAmmo" then
			self.DakName = "75mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 15
			self.DakMaxAmmo = 15
			self.DakAmmoType = "75mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmCHEAmmo" then
			self.DakName = "75mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 15
			self.DakMaxAmmo = 15
			self.DakAmmoType = "75mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmCFLAmmo" then
			self.DakName = "75mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 15
			self.DakMaxAmmo = 15
			self.DakAmmoType = "75mmCFLAmmo"
		end
		--100mmC
		if self:GetClientInfo("SpawnSettings") == "100mmCAPAmmo" then
			self.DakName = "100mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 10
			self.DakMaxAmmo = 10
			self.DakAmmoType = "100mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "100mmCHEAmmo" then
			self.DakName = "100mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 10
			self.DakMaxAmmo = 10
			self.DakAmmoType = "100mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "100mmCFLAmmo" then
			self.DakName = "100mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 10
			self.DakMaxAmmo = 10
			self.DakAmmoType = "100mmCFLAmmo"
		end
		--120mmC
		if self:GetClientInfo("SpawnSettings") == "120mmCAPAmmo" then
			self.DakName = "120mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 8
			self.DakMaxAmmo = 8
			self.DakAmmoType = "120mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmCHEAmmo" then
			self.DakName = "120mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 8
			self.DakMaxAmmo = 8
			self.DakAmmoType = "120mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmCFLAmmo" then
			self.DakName = "120mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 8
			self.DakMaxAmmo = 8
			self.DakAmmoType = "120mmCFLAmmo"
		end
		--152mmC
		if self:GetClientInfo("SpawnSettings") == "152mmCAPAmmo" then
			self.DakName = "152mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 6
			self.DakMaxAmmo = 6
			self.DakAmmoType = "152mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "152mmCHEAmmo" then
			self.DakName = "152mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 6
			self.DakMaxAmmo = 6
			self.DakAmmoType = "152mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "152mmCFLAmmo" then
			self.DakName = "152mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 6
			self.DakMaxAmmo = 6
			self.DakAmmoType = "152mmCFLAmmo"
		end
		--100mmC
		if self:GetClientInfo("SpawnSettings") == "200mmCAPAmmo" then
			self.DakName = "200mmCAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "200mmCAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "200mmCHEAmmo" then
			self.DakName = "200mmCHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "200mmCHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "200mmCFLAmmo" then
			self.DakName = "200mmCFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "200mmCFLAmmo"
		end
		--50mmH
		if self:GetClientInfo("SpawnSettings") == "50mmHAPAmmo" then
			self.DakName = "50mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 10
			self.DakMaxAmmo = 10
			self.DakAmmoType = "50mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "50mmHHEAmmo" then
			self.DakName = "50mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 10
			self.DakMaxAmmo = 10
			self.DakAmmoType = "50mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "50mmHFLAmmo" then
			self.DakName = "50mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 10
			self.DakMaxAmmo = 10
			self.DakAmmoType = "50mmHFLAmmo"
		end
		--75mmH
		if self:GetClientInfo("SpawnSettings") == "75mmHAPAmmo" then
			self.DakName = "75mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 7
			self.DakMaxAmmo = 7
			self.DakAmmoType = "75mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmHHEAmmo" then
			self.DakName = "75mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 7
			self.DakMaxAmmo = 7
			self.DakAmmoType = "75mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "75mmHFLAmmo" then
			self.DakName = "75mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 7
			self.DakMaxAmmo = 7
			self.DakAmmoType = "75mmHFLAmmo"
		end
		--105mmH
		if self:GetClientInfo("SpawnSettings") == "105mmHAPAmmo" then
			self.DakName = "105mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 5
			self.DakMaxAmmo = 5
			self.DakAmmoType = "105mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "105mmHHEAmmo" then
			self.DakName = "105mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 5
			self.DakMaxAmmo = 5
			self.DakAmmoType = "105mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "105mmHFLAmmo" then
			self.DakName = "105mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 5
			self.DakMaxAmmo = 5
			self.DakAmmoType = "105mmHFLAmmo"
		end
		--122mmH
		if self:GetClientInfo("SpawnSettings") == "122mmHAPAmmo" then
			self.DakName = "122mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "122mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "122mmHHEAmmo" then
			self.DakName = "122mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "122mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "122mmHFLAmmo" then
			self.DakName = "122mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "122mmHFLAmmo"
		end
		--155mmH
		if self:GetClientInfo("SpawnSettings") == "155mmHAPAmmo" then
			self.DakName = "155mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 3
			self.DakMaxAmmo = 3
			self.DakAmmoType = "155mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "155mmHHEAmmo" then
			self.DakName = "155mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 3
			self.DakMaxAmmo = 3
			self.DakAmmoType = "155mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "155mmHFLAmmo" then
			self.DakName = "155mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 3
			self.DakMaxAmmo = 3
			self.DakAmmoType = "155mmHFLAmmo"
		end
		--203mmH
		if self:GetClientInfo("SpawnSettings") == "203mmHAPAmmo" then
			self.DakName = "203mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 2
			self.DakMaxAmmo = 2
			self.DakAmmoType = "203mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "203mmHHEAmmo" then
			self.DakName = "203mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 2
			self.DakMaxAmmo = 2
			self.DakAmmoType = "203mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "203mmHFLAmmo" then
			self.DakName = "203mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 2
			self.DakMaxAmmo = 2
			self.DakAmmoType = "203mmHFLAmmo"
		end
		--420mmH
		if self:GetClientInfo("SpawnSettings") == "420mmHAPAmmo" then
			self.DakName = "420mmHAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 1
			self.DakMaxAmmo = 1
			self.DakAmmoType = "420mmHAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "420mmHHEAmmo" then
			self.DakName = "420mmHHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 1
			self.DakMaxAmmo = 1
			self.DakAmmoType = "420mmHHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "420mmHFLAmmo" then
			self.DakName = "420mmHFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 1
			self.DakMaxAmmo = 1
			self.DakAmmoType = "420mmHFLAmmo"
		end
		--60mmM
		if self:GetClientInfo("SpawnSettings") == "60mmMAPAmmo" then
			self.DakName = "60mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 16
			self.DakMaxAmmo = 16
			self.DakAmmoType = "60mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "60mmMHEAmmo" then
			self.DakName = "60mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 16
			self.DakMaxAmmo = 16
			self.DakAmmoType = "60mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "60mmMFLAmmo" then
			self.DakName = "60mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 16
			self.DakMaxAmmo = 16
			self.DakAmmoType = "60mmMFLAmmo"
		end
		--90mmM
		if self:GetClientInfo("SpawnSettings") == "90mmMAPAmmo" then
			self.DakName = "90mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 12
			self.DakMaxAmmo = 12
			self.DakAmmoType = "90mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "90mmMHEAmmo" then
			self.DakName = "90mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 12
			self.DakMaxAmmo = 12
			self.DakAmmoType = "90mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "90mmMFLAmmo" then
			self.DakName = "90mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 12
			self.DakMaxAmmo = 12
			self.DakAmmoType = "90mmMFLAmmo"
		end
		--120mmM
		if self:GetClientInfo("SpawnSettings") == "120mmMAPAmmo" then
			self.DakName = "120mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 8
			self.DakMaxAmmo = 8
			self.DakAmmoType = "120mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmMHEAmmo" then
			self.DakName = "120mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 8
			self.DakMaxAmmo = 8
			self.DakAmmoType = "120mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "120mmMFLAmmo" then
			self.DakName = "120mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 8
			self.DakMaxAmmo = 8
			self.DakAmmoType = "120mmMFLAmmo"
		end
		--150mmM
		if self:GetClientInfo("SpawnSettings") == "150mmMAPAmmo" then
			self.DakName = "150mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 6
			self.DakMaxAmmo = 6
			self.DakAmmoType = "150mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "150mmMHEAmmo" then
			self.DakName = "150mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 6
			self.DakMaxAmmo = 6
			self.DakAmmoType = "150mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "150mmMFLAmmo" then
			self.DakName = "150mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 6
			self.DakMaxAmmo = 6
			self.DakAmmoType = "150mmMFLAmmo"
		end
		--240mmM
		if self:GetClientInfo("SpawnSettings") == "240mmMAPAmmo" then
			self.DakName = "240mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "240mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "240mmMHEAmmo" then
			self.DakName = "240mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "240mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "240mmMFLAmmo" then
			self.DakName = "240mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 4
			self.DakMaxAmmo = 4
			self.DakAmmoType = "240mmMFLAmmo"
		end
		--280mmM
		if self:GetClientInfo("SpawnSettings") == "280mmMAPAmmo" then
			self.DakName = "280mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 3
			self.DakMaxAmmo = 3
			self.DakAmmoType = "280mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "280mmMHEAmmo" then
			self.DakName = "280mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 3
			self.DakMaxAmmo = 3
			self.DakAmmoType = "280mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "280mmMFLAmmo" then
			self.DakName = "280mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 3
			self.DakMaxAmmo = 3
			self.DakAmmoType = "280mmMFLAmmo"
		end
		--420mmM
		if self:GetClientInfo("SpawnSettings") == "420mmMAPAmmo" then
			self.DakName = "420mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 2
			self.DakMaxAmmo = 2
			self.DakAmmoType = "420mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "420mmMHEAmmo" then
			self.DakName = "420mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 2
			self.DakMaxAmmo = 2
			self.DakAmmoType = "420mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "420mmMFLAmmo" then
			self.DakName = "420mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 2
			self.DakMaxAmmo = 2
			self.DakAmmoType = "420mmMFLAmmo"
		end
		--600mmM
		if self:GetClientInfo("SpawnSettings") == "600mmMAPAmmo" then
			self.DakName = "600mmMAPAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 1
			self.DakMaxAmmo = 1
			self.DakAmmoType = "600mmMAPAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "600mmMHEAmmo" then
			self.DakName = "600mmMHEAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 1
			self.DakMaxAmmo = 1
			self.DakAmmoType = "600mmMHEAmmo"
		end
		if self:GetClientInfo("SpawnSettings") == "600mmMFLAmmo" then
			self.DakName = "600mmMFLAmmo"
			self.DakIsExplosive = true
			self.DakAmmo = 1
			self.DakMaxAmmo = 1
			self.DakAmmoType = "600mmMFLAmmo"
		end

		if self:GetClientInfo("SpawnEnt") == "dak_tegun" or self:GetClientInfo("SpawnEnt") == "dak_teautogun" or self:GetClientInfo("SpawnEnt") == "dak_temachinegun" then
			self.spawnedent.DakOwner = self:GetOwner()
			self.spawnedent.DakName = self.DakName
			self.spawnedent.DakCooldown = self.DakCooldown
			self.spawnedent.DakHeat = self.DakHeat
			self.spawnedent.DakMaxHealth = self.DakMaxHealth
			self.spawnedent.DakHealth = self.DakMaxHealth
			self.spawnedent.DakAmmo = self.DakAmmo
			self.spawnedent.DakMass = self.DakMass
			self.spawnedent.DakEngine = self.DakEngine
			self.spawnedent.DakModel = self.DakModel
			self.spawnedent.DakAmmoType = self.DakAmmoType
			self.spawnedent.DakAmmoUse = self.DakAmmoUse
			self.spawnedent.DakAmmoQueue = self.DakAmmoQueue
			self.spawnedent.DakFireEffect = self.DakFireEffect
			self.spawnedent.DakFireSound = self.DakFireSound
			self.spawnedent.DakFirePitch = self.DakFirePitch
			self.spawnedent.DakFireSpecialShell = self.DakFireSpecialShell
			self.spawnedent.DakShellEnt = self.DakShellEnt
			self.spawnedent.DakIsExplosive = self.DakIsExplosive
			self.spawnedent.DakShellTrail = self.DakShellTrail
			self.spawnedent.DakShellVelocity = self.DakShellVelocity
			self.spawnedent.DakShellDamage = self.DakShellDamage
			self.spawnedent.DakShellExplosionEffect = self.DakShellExplosionEffect
			self.spawnedent.DakShellGravity = self.DakShellGravity
			self.spawnedent.DakShellMass = self.DakShellMass
			self.spawnedent.DakIsLBX = self.DakIsLBX
			self.spawnedent.DakLBXPellets = self.DakLBXPellets
			self.spawnedent.DakShellImpactSound = self.DakShellImpactSound
			self.spawnedent.DakShellImpactPitch = self.DakShellImpactPitch
			self.spawnedent.DakUseAmmo = self.DakUseAmmo
			self.spawnedent.DakIsRAC = self.DakIsRAC
			self.spawnedent.DakIsUAC = self.DakIsUAC
			self.spawnedent:SetModel(self.spawnedent.DakModel)
		end
		if self:GetClientInfo("SpawnEnt") == "dak_teammo" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_teammo" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakIsExplosive = self.DakIsExplosive
					trace.Entity.DakAmmo = self.DakAmmo
					trace.Entity.DakMaxAmmo = self.DakMaxAmmo
					trace.Entity.DakAmmoType = self.DakAmmoType
					trace.Entity.DakOwner = self:GetOwner()
					self:GetOwner():ChatPrint("Ammo updated.")
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakIsExplosive = self.DakIsExplosive
				self.spawnedent.DakAmmo = self.DakAmmo
				self.spawnedent.DakMaxAmmo = self.DakMaxAmmo
				self.spawnedent.DakAmmoType = self.DakAmmoType
				self.spawnedent.DakOwner = self:GetOwner()
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
					self:GetOwner():ChatPrint("Clip updated.")
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
					trace.Entity.DakSpeed = self.DakSpeed
					trace.Entity.DakModel = self.DakModel
					trace.Entity.DakSound = self.DakSound
					trace.Entity:PhysicsDestroy()
					trace.Entity:SetModel(trace.Entity.DakModel)
					trace.Entity:PhysicsInit(SOLID_VPHYSICS)
					trace.Entity:SetMoveType(MOVETYPE_VPHYSICS)
					trace.Entity:SetSolid(SOLID_VPHYSICS)
					self:GetOwner():ChatPrint( "Engine updated.")
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakMaxHealth = self.DakMaxHealth
				self.spawnedent.DakHealth = self.DakHealth
				self.spawnedent.DakSpeed = self.DakSpeed
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
			self.spawnedent:GetPhysicsObject():EnableMotion( false )
			self.spawnedent:SetPos(trace.HitPos+Vector(0,0,-self.spawnedent:OBBMins().z))

			if not(self.spawnedent:GetClass() == "dak_engine") and not(self.spawnedent:GetClass() == "dak_module") and not(self.spawnedent:GetClass() == "dak_ammo") and not(self.spawnedent:GetClass() == "dak_teammo") and not(self.spawnedent:GetClass() == "dak_heatsink") and not(self.spawnedent:GetClass() == "dak_hitboxcontroller") and not(self.spawnedent:GetClass() == "dak_masc") and not(self.spawnedent:GetClass() == "dak_supercharger") and not(self.spawnedent:GetClass() == "dak_motor") and not(self.spawnedent:GetClass() == "dak_temotor") and not(self.spawnedent:GetClass() == "dak_vtol") and not(self.spawnedent:GetClass() == "dak_fighter") and not(self.spawnedent:GetClass() == "dak_hoverdrive") and not(self.spawnedent:GetClass() == "dak_gyro") and not(self.spawnedent:GetClass() == "dak_quadgyro") and not(self.spawnedent:GetClass() == "dak_lams") and not(self.spawnedent:GetClass() == "dak_jumpjet") then
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 1 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakplainmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 2 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakplainmetaldark" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 3 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakscratchedmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 4 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakscratchedmetaldark" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 5 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakpittedmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 6 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakpittedmetaldark" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 7 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakrustedmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 8 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakrustedmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 2 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakplainmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 1 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakplainmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 4 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakscratchedmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 3 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakscratchedmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 6 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakpittedmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 5 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakpittedmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 8 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakrustedmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 7 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakrustedmetaldark" )
				end
			end
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
			self.spawnedent:GetPhysicsObject():EnableMotion( false )

			if not(self.spawnedent:GetClass() == "dak_engine") and not(self.spawnedent:GetClass() == "dak_module") and not(self.spawnedent:GetClass() == "dak_ammo") and not(self.spawnedent:GetClass() == "dak_teammo") and not(self.spawnedent:GetClass() == "dak_heatsink") and not(self.spawnedent:GetClass() == "dak_hitboxcontroller") and not(self.spawnedent:GetClass() == "dak_masc") and not(self.spawnedent:GetClass() == "dak_supercharger") and not(self.spawnedent:GetClass() == "dak_motor") and not(self.spawnedent:GetClass() == "dak_temotor") and not(self.spawnedent:GetClass() == "dak_vtol") and not(self.spawnedent:GetClass() == "dak_fighter") and not(self.spawnedent:GetClass() == "dak_hoverdrive") and not(self.spawnedent:GetClass() == "dak_gyro") and not(self.spawnedent:GetClass() == "dak_quadgyro") and not(self.spawnedent:GetClass() == "dak_lams") and not(self.spawnedent:GetClass() == "dak_jumpjet") then
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 1 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakplainmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 2 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakplainmetaldark" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 3 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakscratchedmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 4 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakscratchedmetaldark" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 5 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakpittedmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 6 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakpittedmetaldark" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 7 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakrustedmetallight" )
				end
				if math.Round( self:GetClientInfo("PTSpawnMod"), 0 ) == 8 then
					self.spawnedent:SetSubMaterial( 0, "dak/dakrustedmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 2 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakplainmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 1 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakplainmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 4 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakscratchedmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 3 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakscratchedmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 6 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakpittedmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 5 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakpittedmetaldark" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 8 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakrustedmetallight" )
				end
				if math.Round( self:GetClientInfo("STSpawnMod"), 0 ) == 7 then
					self.spawnedent:SetSubMaterial( 1, "dak/dakrustedmetaldark" )
				end
			end
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
			self.spawnedent.DakEngine = trace.Entity.DakEngine
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
						if not(trace.Entity.DakArmor == 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)) then
							trace.Entity.DakArmor = 7.8125*(trace.Entity:GetPhysicsObject():GetMass()/4.6311781)*(288/SA)
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
		if Target:GetClass() == "dak_engine" then
			ply:ChatPrint(TarName..", ".. HP.." Health, "..MHP.." Max Health, "..PHP.."% Health")
			ply:ChatPrint("Alpha strike max heat percent: "..math.Round((Target.DakAlphaHeatThreshhold*100),0).."%")
			ply:ChatPrint("Heat Efficiency: "..math.Round((Target.DakHeatEfficiency*100),0).."%")
			ply:ChatPrint("Alpha strike heat: "..math.Round(Target.DakWeaponHeat,2).." Heat")
			ply:ChatPrint("Heat per second: "..math.Round(Target.DakWeaponHPS,2).." HPS")
			ply:ChatPrint("Max Heat: "..math.Round(Target.DakMaxHeat,2).." Heat")
			ply:ChatPrint("Cooling: "..math.Round(Target.DakCooling,2).." HPS")
			if Target.DakOverheatTime < 0 then
				ply:ChatPrint("Time to overheat: Never")
			else
				ply:ChatPrint("Time to overheat: "..math.Round(Target.DakOverheatTime,1).." seconds")
			end
		else
			ply:ChatPrint(TarName..", ".. math.Round(Target.DakArmor,2).." Armor (mm), ".. HP.." Health, "..MHP.." Max Health, "..PHP.."% Health")
		end
	end
	end
end

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

local function GetParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetParents(Parent, Results)
	end
	return Results
end

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
local ctrl = vgui.Create( "DTree", panel )
ctrl:SetPos( 5, 30 )
ctrl:SetPadding( 5 )
ctrl:SetSize( 300, 300 )
ctrl:SetShowIcons( false )

local DLabel = vgui.Create( "DLabel", panel )
DLabel:SetPos( 17, 410 )
DLabel:SetAutoStretchVertical( true )
DLabel:SetText( "Select an entity and information for it will appear here" )
DLabel:SetTextColor(Color(0,0,0,255))
DLabel:SetWide( 200 )
DLabel:SetWrap( true )

local ModOption = vgui.Create( "DComboBox", panel )
ModOption:SetPos( 17, 340 )
ModOption:SetSize( 100, 20 )
ModOption:SetValue( "Model Options" )
ModOption:AddChoice( "Model 1" )
ModOption:AddChoice( "Model 2" )
ModOption:AddChoice( "Model 3" )
ModOption:AddChoice( "Model 4" )

local ModOption2 = vgui.Create( "DComboBox", panel )
ModOption2:SetPos( 17, 370 )
ModOption2:SetSize( 125, 20 )
ModOption2:SetValue( "Primary Texture" )
ModOption2:AddChoice( "Plain Light" )
ModOption2:AddChoice( "Plain Dark" )
ModOption2:AddChoice( "Scratched Light" )
ModOption2:AddChoice( "Scratched Dark" )
ModOption2:AddChoice( "Pitted Light" )
ModOption2:AddChoice( "Pitted Dark" )
ModOption2:AddChoice( "Rusted Light" )
ModOption2:AddChoice( "Rusted Dark" )

local ModOption3 = vgui.Create( "DComboBox", panel )
ModOption3:SetPos( 145, 370 )
ModOption3:SetSize( 125, 20 )
ModOption3:SetValue( "Secondary Texture" )
ModOption3:AddChoice( "Plain Dark" )
ModOption3:AddChoice( "Plain Light" )
ModOption3:AddChoice( "Scratched Dark" )
ModOption3:AddChoice( "Scratched Light" )
ModOption3:AddChoice( "Pitted Dark" )
ModOption3:AddChoice( "Pitted Light" )
ModOption3:AddChoice( "Rusted Dark" )
ModOption3:AddChoice( "Rusted Light" )


DTTE_NodeList={}
DTTE_NodeList["Help1"] = ctrl:AddNode( "DakTank Guide: The Basics" )
DTTE_NodeList["Help2"] = ctrl:AddNode( "DakTank Guide: Armor" )
DTTE_NodeList["Help3"] = ctrl:AddNode( "DakTank Guide: Munitions: AP" )
DTTE_NodeList["Help4"] = ctrl:AddNode( "DakTank Guide: Munitions: HE" )
DTTE_NodeList["Help5"] = ctrl:AddNode( "DakTank Guide: Munitions: FL" )
DTTE_NodeList["Help6"] = ctrl:AddNode( "DakTank Guide: Weaponry" )
DTTE_NodeList["Help7"] = ctrl:AddNode( "DakTank Guide: Mobility" )
DTTE_NodeList["Help8"] = ctrl:AddNode( "DakTank Guide: Critical Hits" )
DTTE_NodeList["Utilities"] = ctrl:AddNode( "Utilities" )
	DTTE_NodeList["Core"] = DTTE_NodeList["Utilities"]:AddNode( "Tank Core" )
	DTTE_NodeList["Crew"] = DTTE_NodeList["Utilities"]:AddNode( "Crew Member" )
	DTTE_NodeList["Mobility"] = DTTE_NodeList["Utilities"]:AddNode( "Mobility" )
		DTTE_NodeList["Engine"] = DTTE_NodeList["Mobility"]:AddNode( "Engine" )
			DTTE_NodeList["MicroEngine"] = DTTE_NodeList["Engine"]:AddNode( "Micro Engine" )
			DTTE_NodeList["SmallEngine"] = DTTE_NodeList["Engine"]:AddNode( "Small Engine" )
			DTTE_NodeList["StandardEngine"] = DTTE_NodeList["Engine"]:AddNode( "Standard Engine" )
			DTTE_NodeList["LargeEngine"] = DTTE_NodeList["Engine"]:AddNode( "Large Engine" )
			DTTE_NodeList["HugeEngine"] = DTTE_NodeList["Engine"]:AddNode( "Huge Engine" )
			DTTE_NodeList["UltraEngine"] = DTTE_NodeList["Engine"]:AddNode( "Ultra Engine" )
		DTTE_NodeList["Fuel"] = DTTE_NodeList["Mobility"]:AddNode( "Fuel" )
			DTTE_NodeList["MicroFuel"] = DTTE_NodeList["Fuel"]:AddNode( "Micro Fuel Tank" )
			DTTE_NodeList["SmallFuel"] = DTTE_NodeList["Fuel"]:AddNode( "Small Fuel Tank" )
			DTTE_NodeList["StandardFuel"] = DTTE_NodeList["Fuel"]:AddNode( "Standard Fuel Tank" )
			DTTE_NodeList["LargeFuel"] = DTTE_NodeList["Fuel"]:AddNode( "Large Fuel Tank" )
			DTTE_NodeList["HugeFuel"] = DTTE_NodeList["Fuel"]:AddNode( "Huge Fuel Tank" )
			DTTE_NodeList["UltraFuel"] = DTTE_NodeList["Fuel"]:AddNode( "Ultra Fuel Tank" )
	DTTE_NodeList["Turret"] = DTTE_NodeList["Utilities"]:AddNode( "Turret" )
		DTTE_NodeList["TControl"] = DTTE_NodeList["Turret"]:AddNode( "Turret Controller" )
		DTTE_NodeList["TMotor"] = DTTE_NodeList["Turret"]:AddNode( "Turret Motor" )
DTTE_NodeList["Weapons"] = ctrl:AddNode( "Weapons" )
		DTTE_NodeList["Autocannons"] = DTTE_NodeList["Weapons"]:AddNode( "Autocannons" )
			DTTE_NodeList["25mmAC"] = DTTE_NodeList["Autocannons"]:AddNode( "25mm Autocannon" )
			DTTE_NodeList["37mmAC"] = DTTE_NodeList["Autocannons"]:AddNode( "37mm Autocannon" )
			DTTE_NodeList["50mmAC"] = DTTE_NodeList["Autocannons"]:AddNode( "50mm Autocannon" )
		DTTE_NodeList["Autoloaders"] = DTTE_NodeList["Weapons"]:AddNode( "Autoloaders" )
			DTTE_NodeList["ALGuns"] = DTTE_NodeList["Autoloaders"]:AddNode( "Autoloading Guns" )
				DTTE_NodeList["50mmAL"] = DTTE_NodeList["ALGuns"]:AddNode( "50mm Autoloader" )
				DTTE_NodeList["75mmAL"] = DTTE_NodeList["ALGuns"]:AddNode( "75mm Autoloader" )
				DTTE_NodeList["100mmAL"] = DTTE_NodeList["ALGuns"]:AddNode( "100mm Autoloader" )
				DTTE_NodeList["120mmAL"] = DTTE_NodeList["ALGuns"]:AddNode( "120mm Autoloader" )
				DTTE_NodeList["152mmAL"] = DTTE_NodeList["ALGuns"]:AddNode( "152mm Autoloader" )
				DTTE_NodeList["200mmAL"] = DTTE_NodeList["ALGuns"]:AddNode( "200mm Autoloader" )
			DTTE_NodeList["ALClips"] = DTTE_NodeList["Autoloaders"]:AddNode( "Autoloader Clips" )
				DTTE_NodeList["SALClip"] = DTTE_NodeList["ALClips"]:AddNode( "Small Autoloader Clip" )
				DTTE_NodeList["MALClip"] = DTTE_NodeList["ALClips"]:AddNode( "Medium Autoloader Clip" )
				DTTE_NodeList["LALClip"] = DTTE_NodeList["ALClips"]:AddNode( "Large Autoloader Clip" )
			
		DTTE_NodeList["Cannons"] = DTTE_NodeList["Weapons"]:AddNode( "Cannons" )
			DTTE_NodeList["25mmC"] = DTTE_NodeList["Cannons"]:AddNode( "25mm Cannon" )
			DTTE_NodeList["37mmC"] = DTTE_NodeList["Cannons"]:AddNode( "37mm Cannon" )
			DTTE_NodeList["50mmC"] = DTTE_NodeList["Cannons"]:AddNode( "50mm Cannon" )
			DTTE_NodeList["75mmC"] = DTTE_NodeList["Cannons"]:AddNode( "75mm Cannon" )
			DTTE_NodeList["100mmC"] = DTTE_NodeList["Cannons"]:AddNode( "100mm Cannon" )
			DTTE_NodeList["120mmC"] = DTTE_NodeList["Cannons"]:AddNode( "120mm Cannon" )
			DTTE_NodeList["152mmC"] = DTTE_NodeList["Cannons"]:AddNode( "152mm Cannon" )
			DTTE_NodeList["200mmC"] = DTTE_NodeList["Cannons"]:AddNode( "200mm Cannon" )
		DTTE_NodeList["Howitzers"] = DTTE_NodeList["Weapons"]:AddNode( "Howitzers" )
			DTTE_NodeList["50mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "50mm Howitzer" )
			DTTE_NodeList["75mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "75mm Howitzer" )
			DTTE_NodeList["105mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "105mm Howitzer" )
			DTTE_NodeList["122mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "122mm Howitzer" )
			DTTE_NodeList["155mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "155mm Howitzer" )
			DTTE_NodeList["203mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "203mm Howitzer" )
			DTTE_NodeList["420mmH"] = DTTE_NodeList["Howitzers"]:AddNode( "420mm Howitzer" )
		DTTE_NodeList["Mortars"] = DTTE_NodeList["Weapons"]:AddNode( "Mortars" )
			DTTE_NodeList["60mmM"] = DTTE_NodeList["Mortars"]:AddNode( "60mm Mortar" )
			DTTE_NodeList["90mmM"] = DTTE_NodeList["Mortars"]:AddNode( "90mm Mortar" )
			DTTE_NodeList["120mmM"] = DTTE_NodeList["Mortars"]:AddNode( "120mm Mortar" )
			DTTE_NodeList["150mmM"] = DTTE_NodeList["Mortars"]:AddNode( "150mm Mortar" )
			DTTE_NodeList["240mmM"] = DTTE_NodeList["Mortars"]:AddNode( "240mm Mortar" )
			DTTE_NodeList["280mmM"] = DTTE_NodeList["Mortars"]:AddNode( "280mm Mortar" )
			DTTE_NodeList["420mmM"] = DTTE_NodeList["Mortars"]:AddNode( "420mm Mortar" )
			DTTE_NodeList["600mmM"] = DTTE_NodeList["Mortars"]:AddNode( "600mm Mortar" )
		DTTE_NodeList["MGs"] = DTTE_NodeList["Weapons"]:AddNode( "Machine Guns" )
			DTTE_NodeList["5.56mmMG"] = DTTE_NodeList["MGs"]:AddNode( "5.56mm Machine Gun" )
			DTTE_NodeList["7.62mmMG"] = DTTE_NodeList["MGs"]:AddNode( "7.62mm Machine Gun" )
			DTTE_NodeList["9mmMG"] = DTTE_NodeList["MGs"]:AddNode( "9mm Machine Gun" )
			DTTE_NodeList["12.7mmMG"] = DTTE_NodeList["MGs"]:AddNode( "12.7mm Machine Gun" )
			DTTE_NodeList["14.5mmMG"] = DTTE_NodeList["MGs"]:AddNode( "14.5mm Machine Gun" )
		DTTE_NodeList["HMGs"] = DTTE_NodeList["Weapons"]:AddNode( "Heavy Machine Guns" )
			DTTE_NodeList["20mmHMG"] = DTTE_NodeList["HMGs"]:AddNode( "20mm Heavy Machine Gun" )
			DTTE_NodeList["30mmHMG"] = DTTE_NodeList["HMGs"]:AddNode( "30mm Heavy Machine Gun" )
			DTTE_NodeList["40mmHMG"] = DTTE_NodeList["HMGs"]:AddNode( "40mm Heavy Machine Gun" )

DTTE_NodeList["Ammo"] = ctrl:AddNode( "Ammo" )
	DTTE_NodeList["APAmmo"] = DTTE_NodeList["Ammo"]:AddNode( "Armor Piercing" )
		DTTE_NodeList["25mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "25mmC AP Ammo" )
		DTTE_NodeList["37mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "37mmC AP Ammo" )
		DTTE_NodeList["50mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "50mmC AP Ammo" )
		DTTE_NodeList["75mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "75mmC AP Ammo" )
		DTTE_NodeList["100mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "100mmC AP Ammo" )
		DTTE_NodeList["120mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "120mmC AP Ammo" )
		DTTE_NodeList["152mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "152mmC AP Ammo" )
		DTTE_NodeList["200mmCAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "200mmC AP Ammo" )

		DTTE_NodeList["50mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "50mmH AP Ammo" )
		DTTE_NodeList["75mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "75mmH AP Ammo" )
		DTTE_NodeList["105mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "105mmH AP Ammo" )
		DTTE_NodeList["122mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "122mmH AP Ammo" )
		DTTE_NodeList["155mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "155mmH AP Ammo" )
		DTTE_NodeList["203mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "203mmH AP Ammo" )
		DTTE_NodeList["420mmHAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "420mmH AP Ammo" )

		DTTE_NodeList["60mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "60mmM AP Ammo" )
		DTTE_NodeList["90mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "90mmM AP Ammo" )
		DTTE_NodeList["120mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "120mmM AP Ammo" )
		DTTE_NodeList["150mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "150mmM AP Ammo" )
		DTTE_NodeList["240mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "240mmM AP Ammo" )
		DTTE_NodeList["280mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "280mmM AP Ammo" )
		DTTE_NodeList["420mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "420mmM AP Ammo" )
		DTTE_NodeList["600mmMAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "600mmM AP Ammo" )

		DTTE_NodeList["5.56mmMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "5.56mmMG AP Ammo" )
		DTTE_NodeList["7.62mmMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "7.62mmMG AP Ammo" )
		DTTE_NodeList["9mmMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "9mmMG AP Ammo" )
		DTTE_NodeList["12.7mmMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "12.7mmMG AP Ammo" )
		DTTE_NodeList["14.5mmMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "14.5mmMG AP Ammo" )

		DTTE_NodeList["20mmHMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "20mHMG AP Ammo" )
		DTTE_NodeList["30mmHMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "30mHMG AP Ammo" )
		DTTE_NodeList["40mmHMGAPAmmo"] = DTTE_NodeList["APAmmo"]:AddNode( "40mHMG AP Ammo" )
	DTTE_NodeList["HEAmmo"] = DTTE_NodeList["Ammo"]:AddNode( "High Explosive" )
		DTTE_NodeList["25mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "25mmC HE Ammo" )
		DTTE_NodeList["37mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "37mmC HE Ammo" )
		DTTE_NodeList["50mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "50mmC HE Ammo" )
		DTTE_NodeList["75mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "75mmC HE Ammo" )
		DTTE_NodeList["100mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "100mmC HE Ammo" )
		DTTE_NodeList["120mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "120mmC HE Ammo" )
		DTTE_NodeList["152mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "152mmC HE Ammo" )
		DTTE_NodeList["200mmCHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "200mmC HE Ammo" )

		DTTE_NodeList["50mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "50mmH HE Ammo" )
		DTTE_NodeList["75mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "75mmH HE Ammo" )
		DTTE_NodeList["105mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "105mmH HE Ammo" )
		DTTE_NodeList["122mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "122mmH HE Ammo" )
		DTTE_NodeList["155mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "155mmH HE Ammo" )
		DTTE_NodeList["203mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "203mmH HE Ammo" )
		DTTE_NodeList["420mmHHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "420mmH HE Ammo" )

		DTTE_NodeList["60mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "60mmM HE Ammo" )
		DTTE_NodeList["90mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "90mmM HE Ammo" )
		DTTE_NodeList["120mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "120mmM HE Ammo" )
		DTTE_NodeList["150mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "150mmM HE Ammo" )
		DTTE_NodeList["240mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "240mmM HE Ammo" )
		DTTE_NodeList["280mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "280mmM HE Ammo" )
		DTTE_NodeList["420mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "420mmM HE Ammo" )
		DTTE_NodeList["600mmMHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "600mmM HE Ammo" )

		DTTE_NodeList["20mmHMGHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "20mHMG HE Ammo" )
		DTTE_NodeList["30mmHMGHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "30mHMG HE Ammo" )
		DTTE_NodeList["40mmHMGHEAmmo"] = DTTE_NodeList["HEAmmo"]:AddNode( "40mHMG HE Ammo" )
	DTTE_NodeList["FLAmmo"] = DTTE_NodeList["Ammo"]:AddNode( "Flechette" )
		DTTE_NodeList["25mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "25mmC FL Ammo" )
		DTTE_NodeList["37mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "37mmC FL Ammo" )
		DTTE_NodeList["50mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "50mmC FL Ammo" )
		DTTE_NodeList["75mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "75mmC FL Ammo" )
		DTTE_NodeList["100mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "100mmC FL Ammo" )
		DTTE_NodeList["120mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "120mmC FL Ammo" )
		DTTE_NodeList["152mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "152mmC FL Ammo" )
		DTTE_NodeList["200mmCFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "200mmC FL Ammo" )

		DTTE_NodeList["50mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "50mmH FL Ammo" )
		DTTE_NodeList["75mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "75mmH FL Ammo" )
		DTTE_NodeList["105mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "105mmH FL Ammo" )
		DTTE_NodeList["122mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "122mmH FL Ammo" )
		DTTE_NodeList["155mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "155mmH FL Ammo" )
		DTTE_NodeList["203mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "203mmH FL Ammo" )
		DTTE_NodeList["420mmHFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "420mmH FL Ammo" )

		DTTE_NodeList["60mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "60mmM FL Ammo" )
		DTTE_NodeList["90mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "90mmM FL Ammo" )
		DTTE_NodeList["120mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "120mmM FL Ammo" )
		DTTE_NodeList["150mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "150mmM FL Ammo" )
		DTTE_NodeList["240mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "240mmM FL Ammo" )
		DTTE_NodeList["280mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "280mmM FL Ammo" )
		DTTE_NodeList["420mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "420mmM FL Ammo" )
		DTTE_NodeList["600mmMFLAmmo"] = DTTE_NodeList["FLAmmo"]:AddNode( "600mmM FL Ammo" )

	function ModOption:OnSelect( index, value, data )
		if value=="Model 1" then
			RunConsoleCommand("daktankspawner_SpawnMod", 1)
		end
		if value=="Model 2" then
			RunConsoleCommand("daktankspawner_SpawnMod", 2)
		end
		if value=="Model 3" then
			RunConsoleCommand("daktankspawner_SpawnMod", 3)
		end
		if value=="Model 4" then
			RunConsoleCommand("daktankspawner_SpawnMod", 4)
		end
	end
	function ModOption2:OnSelect( index, value, data )
		if value=="Plain Light" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 1)
		end
		if value=="Plain Dark" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 2)
		end
		if value=="Scratched Light" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 3)
		end
		if value=="Scratched Dark" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 4)
		end
		if value=="Pitted Light" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 5)
		end
		if value=="Pitted Dark" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 6)
		end
		if value=="Rusted Light" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 7)
		end
		if value=="Rusted Dark" then
			RunConsoleCommand("daktankspawner_PTSpawnMod", 8)
		end
	end
	function ModOption3:OnSelect( index, value, data )
		if value=="Plain Dark" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 1)
		end
		if value=="Plain Light" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 2)
		end
		if value=="Scratched Dark" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 3)
		end
		if value=="Scratched Light" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 4)
		end
		if value=="Pitted Dark" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 5)
		end
		if value=="Pitted Light" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 6)
		end
		if value=="Rusted Dark" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 7)
		end
		if value=="Rusted Light" then
			RunConsoleCommand("daktankspawner_STSpawnMod", 8)
		end
	end
	function ctrl:DoClick( node )
		--CLIPs
		if (node == DTTE_NodeList["SALClip"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautoloadingmodule")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SALClip")
			DLabel:SetText( "Small Autoloader Clip\n\nArmor: 10mm\nWeight: 1000 kg\nHealth: 50\n\nDescription: Small sized clip required to load an autoloader." )
		end
		if (node == DTTE_NodeList["MALClip"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautoloadingmodule")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MALClip")
			DLabel:SetText( "Medium Autoloader Clip\n\nArmor: 10mm\nWeight: 2000 kg\nHealth: 75\n\nDescription: Medium sized clip required to load an autoloader. Increases clip size and decreases reload times by 20% per shell" )
		end
		if (node == DTTE_NodeList["LALClip"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautoloadingmodule")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LALClip")
			DLabel:SetText( "Large Autoloader Clip\n\nArmor: 10mm\nWeight: 3000 kg\nHealth: 100\n\nDescription: Large sized clip required to load an autoloader. Increases clip size and decreases reload times by 40% per shell" )
		end

		--HMG
		if (node == DTTE_NodeList["20mmHMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "20mmHMG")
			DLabel:SetText( "20mm Heavy Machine Gun\n\nArmor: 80mm\nWeight: 200 kg\nReload Time: 0.1 seconds\nClip Load Time: 20 seconds crewed, 30 seconds uncrewed\nClip Size: 35 rounds\n\nAP Stats\nPenetration: 30mm\nDamage: 2\nVelocity: 400 m/s\n\nHE Stats\nPenetration: 12mm\nDamage: 1\nSplash Damage: 2\nBlast Radius: 0.8m\nVelocity: 300 m/s\n\nDescription: Low weight heavy machine gun, great for denting armor or killing infantry, though terrible at penetrating armor." )
		end
		if (node == DTTE_NodeList["30mmHMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "30mmHMG")
			DLabel:SetText( "30mm Heavy Machine Gun\n\nArmor: 120mm\nWeight: 400 kg\nReload Time: 0.1 seconds\nClip Load Time: 20 seconds crewed, 30 seconds uncrewed\nClip Size: 25 rounds\n\nAP Stats\nPenetration: 45mm\nDamage: 3\nVelocity: 400 m/s\n\nHE Stats\nPenetration: 18mm\nDamage: 1.5\nSplash Damage: 3\nBlast Radius: 1.2m\nVelocity: 300 m/s\n\nDescription: heavy machine gun, great for denting armor or killing infantry, might get through some weak rear armor." )
		end
		if (node == DTTE_NodeList["40mmHMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "40mmHMG")
			DLabel:SetText( "40mm Heavy Machine Gun\n\nArmor: 160mm\nWeight: 600 kg\nReload Time: 0.1 seconds\nClip Load Time: 20 seconds crewed, 30 seconds uncrewed\nClip Size: 20 rounds\n\nAP Stats\nPenetration: 60mm\nDamage: 4\nVelocity: 400 m/s\n\nHE Stats\nPenetration: 24mm\nDamage: 2\nSplash Damage: 4\nBlast Radius: 1.6m\nVelocity: 300 m/s\n\nDescription: heavy duty heavy machine gun, great for denting armor or killing infantry, could do well against light armor." )
		end
		--MG
		if (node == DTTE_NodeList["5.56mmMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "5.56mmMG")
			DLabel:SetText( "5.56mm Machine Gun\n\nArmor: 22.24mm\nWeight: 20 kg\nReload Time: 0.06 seconds\n\nAP Stats\nPenetration: 11mm\nDamage: 0.06\nVelocity: 600 m/s\n\nDescription: Light weight but weak anti infantry machine gun." )
		end
		if (node == DTTE_NodeList["7.62mmMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "7.62mmMG")
			DLabel:SetText( "7.62mm Machine Gun\n\nArmor: 30.48mm\nWeight: 30 kg\nReload Time: 0.09 seconds\n\nAP Stats\nPenetration: 15mm\nDamage: 0.08\nVelocity: 600 m/s\n\nDescription: Light weight anti infantry machine gun, not much stopping power." )
		end
		if (node == DTTE_NodeList["9mmMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "9mmMG")
			DLabel:SetText( "9mm Machine Gun\n\nArmor: 36mm\nWeight: 40 kg\nReload Time: 0.1 seconds\n\nAP Stats\nPenetration: 18mm\nDamage: 0.09\nVelocity: 600 m/s\n\nDescription: Light weight anti infantry machine gun." )
		end
		if (node == DTTE_NodeList["12.7mmMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "12.7mmMG")
			DLabel:SetText( "12.7mm Machine Gun\n\nArmor: 50.8mm\nWeight: 50 kg\nReload Time: 0.15 seconds\n\nAP Stats\nPenetration: 25mm\nDamage: 0.13\nVelocity: 600 m/s\n\nDescription: Light weight anti infantry machine gun with stopping power to spare." )
		end
		if (node == DTTE_NodeList["14.5mmMG"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "14.5mmMG")
			DLabel:SetText( "14.5mm Machine Gun\n\nArmor: 58mm\nWeight: 60 kg\nReload Time: 0.17 seconds\n\nAP Stats\nPenetration: 29mm\nDamage: 0.15\nVelocity: 600 m/s\n\nDescription: Light weight infantry machine gun bordering on anti material territory." )
		end
		--Autocannons
		if (node == DTTE_NodeList["25mmAC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "25mmAC")
			DLabel:SetText( "25mm Autocannon\n\nArmor: 125mm\nWeight: 800 kg\nReload Time: 0.1 seconds\nClip Load Time: 25 seconds crewed, 37.5 seconds uncrewed\nClip Size: 25 rounds\n\nAP Stats\nPenetration: 50mm\nDamage: 2.5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 20mm\nDamage: 1.25\nSplash Damage: 2.5\nBlast Radius: 1.0m\nVelocity: 800 m/s\n\nDescription: Small autocannon capable of large bursts of shells in a short time. Its long reload is rather limiting however." )
		end
		if (node == DTTE_NodeList["37mmAC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "37mmAC")
			DLabel:SetText( "37mm Autocannon\n\nArmor: 185mm\nWeight: 1200 kg\nReload Time: 0.1 second\nClip Load Time: 25 seconds crewed, 37.5 seconds uncrewed\nClip Size: 15 rounds\n\nAP Stats\nPenetration: 74mm\nDamage: 3.7\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 30mm\nDamage: 1.85\nSplash Damage: 3.7\nBlast Radius: 1.5m\nVelocity: 800 m/s\n\nDescription: Medium autocannon packing a bit more penetration and damage per shot but lower clip sizes. Its 30 second reload requires a boom and zoom type of style." )
		end
		if (node == DTTE_NodeList["50mmAC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmAC")
			DLabel:SetText( "50mm Autocannon\n\nArmor: 250mm\nWeight: 2000 kg\nReload Time: 0.1 seconds\nClip Load Time: 25 seconds crewed, 37.5 seconds uncrewed\nClip Size: 10 rounds\n\nAP Stats\nPenetration: 100mm\nDamage: 5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 40mm\nDamage: 2.5\nSplash Damage: 5\nBlast Radius: 2.0m\nVelocity: 800 m/s\n\nDescription: Devastating heavy autocannon against light armor, its reload keeps you from wiping out too many little tanks too quickly.." )
		end
		--autoloaders
		if (node == DTTE_NodeList["50mmAL"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmAL")
			DLabel:SetText( "50mm Autoloader\n\nArmor: 250mm\nWeight: 500 kg\nReload Time: 0.9 seconds\nSmall Clip Load Time: 24 seconds\nSmall Clip Size: 10 rounds\nMedium Clip Load Time: 30 seconds\nMedium Clip Size: 15 rounds\nLarge Clip Load Time: 32 seconds\nLarge Clip Size: 20 rounds\n\nAP Stats\nPenetration: 100mm\nDamage: 5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 40mm\nDamage: 2.5\nSplash Damage: 5\nBlast Radius: 2.0m\nVelocity: 800 m/s\n\nDescription: This light autoloader fires off a respectable amount of shells in short order and reloads its clip relatively fast." )
		end
		if (node == DTTE_NodeList["75mmAL"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmAL")
			DLabel:SetText( "75mm Autoloader\n\nArmor: 375mm\nWeight: 1500 kg\nReload Time: 1.3 seconds\nSmall Clip Load Time: 34 seconds\nSmall Clip Size: 8 rounds\nMedium Clip Load Time: 42 seconds\nMedium Clip Size: 12 rounds\nLarge Clip Load Time: 45 seconds\nLarge Clip Size: 16 rounds\n\nAP Stats\nPenetration: 150mm\nDamage: 7.5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 60mm\nDamage: 3.75\nSplash Damage: 7.5\nBlast Radius: 3.0m\nVelocity: 800 m/s\n\nDescription: This gun gets off a shot a second with 200mm average penetration each, its reload isn't the longest, but its best used for flanking and running." )
		end
		if (node == DTTE_NodeList["100mmAL"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "100mmAL")
			DLabel:SetText( "100mm Autoloader\n\nArmor: 500mm\nWeight: 3000 kg\nReload Time: 1.7 seconds\nSmall Clip Load Time: 33 seconds\nSmall Clip Size: 6 rounds\nMedium Clip Load Time: 41 seconds\nMedium Clip Size: 9 rounds\nLarge Clip Load Time: 43 seconds\nLarge Clip Size: 12 rounds\n\nAP Stats\nPenetration: 200mm\nDamage: 10\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 80mm\nDamage: 5\nSplash Damage: 10\nBlast Radius: 4.0m\nVelocity: 800 m/s\n\nDescription: Boom and zoom with 250mm of pen, have fun." )
		end
		if (node == DTTE_NodeList["120mmAL"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmAL")
			DLabel:SetText( "120mm Autoloader\n\nArmor: 600mm\nWeight: 5000 kg\nReload Time: 2.1 seconds\nSmall Clip Load Time: 30 seconds\nSmall Clip Size: 5 rounds\nMedium Clip Load Time: 35 seconds\nMedium Clip Size: 7 rounds\nLarge Clip Load Time: 40 seconds\nLarge Clip Size: 10 rounds\n\nAP Stats\nPenetration: 240mm\nDamage: 12\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 96mm\nDamage: 6\nSplash Damage: 12\nBlast Radius: 4.8m\nVelocity: 800 m/s\n\nDescription: The reload on this gun is very long, but the potential damage is great if you can penetrate." )
		end
		if (node == DTTE_NodeList["152mmAL"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "152mmAL")
			DLabel:SetText( "152mm Autoloader\n\nArmor: 760mm\nWeight: 7000 kg\nReload Time: 2.6 seconds\nSmall Clip Load Time: 31 seconds\nSmall Clip Size: 4 rounds\nMedium Clip Load Time: 39 seconds\nMedium Clip Size: 6 rounds\nLarge Clip Load Time: 42 seconds\nLarge Clip Size: 8 rounds\n\nAP Stats\nPenetration: 304mm\nDamage: 15.2\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 122mm\nDamage: 7.6\nSplash Damage: 15.2\nBlast Radius: 6.08m\nVelocity: 800 m/s\n\nDescription: You get a full 400mm of pen on average with this gun, but the long reload and 5 shot max clip means its only good if you have an escape plan." )
		end
		if (node == DTTE_NodeList["200mmAL"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "200mmAL")
			DLabel:SetText( "200mm Autoloader\n\nArmor: 1000mm\nWeight: 9000 kg\nReload Time: 3.5 seconds\nSmall Clip Load Time: 31 seconds\nSmall Clip Size: 3 rounds\nMedium Clip Load Time: 43 seconds\nMedium Clip Size: 5 rounds\nLarge Clip Load Time: 41 seconds\nLarge Clip Size: 6 rounds\n\nAP Stats\nPenetration: 400mm\nDamage: 20\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 16mm\nDamage: 10\nSplash Damage: 20\nBlast Radius: 8.0m\nVelocity: 800 m/s\n\nDescription: If you can't kill your enemy before you empty the clip on this gun then you're going to have a bad time." )
		end
		--Cannons
		if (node == DTTE_NodeList["25mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "25mmC")
			DLabel:SetText( "25mm Cannon\n\nArmor: 125mm\nWeight: 200 kg\nReload Time: 2 seconds crewed, 3 seconds uncrewed\n\nAP Stats\nPenetration: 50mm\nDamage: 2.5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 20mm\nDamage: 1.25\nSplash Damage: 2.5\nBlast Radius: 1.0m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 37.5mm\nDamage: 0.25\nPellets: 10\nVelocity: 600 m/s\n\nDescription: Tiny peashooter capable of only taking out light vehicles. It has pretty quick reload times and may work well as a coax or for taking out infantry." )
		end
		if (node == DTTE_NodeList["37mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "37mmC")
			DLabel:SetText( "37mm Cannon\n\nArmor: 185mm\nWeight: 300 kg\nReload Time: 3 seconds crewed, 4.5 seconds uncrewed\n\nAP Stats\nPenetration: 74mm\nDamage: 3.7\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 30mm\nDamage: 1.85\nSplash Damage: 3.7\nBlast Radius: 1.48m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 55.5mm\nDamage: 0.37\nPellets: 10\nVelocity: 600 m/s\n\nDescription: You might just be able to penetrate some heavy tank's rear armor with this gun." )
		end
		if (node == DTTE_NodeList["50mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmC")
			DLabel:SetText( "50mm Cannon\n\nArmor: 250mm\nWeight: 500 kg\nReload Time: 4 seconds crewed, 6 seconds uncrewed\n\nAP Stats\nPenetration: 100mm\nDamage: 5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 40mm\nDamage: 2.5\nSplash Damage: 5\nBlast Radius: 2.0m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 75mm\nDamage: 0.5\nPellets: 10\nVelocity: 600 m/s\n\nDescription: Pretty light cannon, may give your light tank some bite against people who didn't put much weight into armor." )
		end
		if (node == DTTE_NodeList["75mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmC")
			DLabel:SetText( "75mm Cannon\n\nArmor: 375mm\nWeight: 1500 kg\nReload Time: 7 seconds crewed, 10.5 seconds uncrewed\n\nAP Stats\nPenetration: 150mm\nDamage: 7.5\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 60mm\nDamage: 3.75\nSplash Damage: 7.5\nBlast Radius: 3.0m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 112.5mm\nDamage: 0.75\nPellets: 10\nVelocity: 600 m/s\n\nDescription: This could go well on a medium tank looking to fight other lights and mediums, though likely won't penetrate the fronts of heavy tanks...sides however may be a more viable target." )
		end
		if (node == DTTE_NodeList["100mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "100mmC")
			DLabel:SetText( "100mm Cannon\n\nArmor: 500mm\nWeight: 3000 kg\nReload Time: 9 seconds crewed, 13.5 seconds uncrewed\n\nAP Stats\nPenetration: 200mm\nDamage: 10\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 80mm\nDamage: 5\nSplash Damage: 10\nBlast Radius: 4.0m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 150mm\nDamage: 1.0\nPellets: 10\nVelocity: 600 m/s\n\nDescription: If you shot this at the front of a light tank you might just go all the way through." )
		end
		if (node == DTTE_NodeList["120mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmC")
			DLabel:SetText( "120mm Cannon\n\nArmor: 600mm\nWeight: 5000 kg\nReload Time: 10 seconds crewed, 15 seconds uncrewed\n\nAP Stats\nPenetration: 240mm\nDamage: 12\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 96mm\nDamage: 6\nSplash Damage: 12\nBlast Radius: 4.8m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 180mm\nDamage: 1.2\nPellets: 10\nVelocity: 600 m/s\n\nDescription: With the 300mm of penetration this gun offers you should be able to put up a decent fight against heavy tanks." )
		end
		if (node == DTTE_NodeList["152mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "152mmC")
			DLabel:SetText( "152mm Cannon\n\nArmor: 760mm\nWeight: 7000 kg\nReload Time: 13 seconds crewed, 19.5 seconds uncrewed\n\nAP Stats\nPenetration: 304mm\nDamage: 15.2\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 122mm\nDamage: 7.6\nSplash Damage: 15.2\nBlast Radius: 6.1m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 228mm\nDamage: 1.52\nPellets: 10\nVelocity: 600 m/s\n\nDescription: You might not be able to penetrate the most angled of armor, but you'll sure leave 'em bloodied." )
		end
		if (node == DTTE_NodeList["200mmC"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "200mmC")
			DLabel:SetText( "200mm Cannon\n\nArmor: 1000mm\nWeight: 9000 kg\nReload Time: 17 seconds crewed, 25.5 seconds uncrewed\n\nAP Stats\nPenetration: 400mm\nDamage: 20\nVelocity: 800 m/s\n\nHE Stats\nPenetration: 160mm\nDamage: 10\nSplash Damage: 20\nBlast Radius: 8.0m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: 300mm\nDamage: 2.0\nPellets: 10\nVelocity: 600 m/s\n\nDescription: This 9 ton hole puncher should be able to get through just about anything unlucky enough to be hit by it." )
		end
		--Howitzers
		if (node == DTTE_NodeList["50mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmH")
			DLabel:SetText( "50mm Howitzer\n\nArmor: 150mm\nWeight: 400 kg\nReload Time: 5 seconds crewed, 7.5 seconds uncrewed\n\nAP Stats\nPenetration: 60mm\nDamage: 10\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 24mm\nDamage: 5\nSplash Damage: 15\nBlast Radius: 4.0m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 45mm\nDamage: 1\nPellets: 10\nVelocity: 450 m/s\n\nDescription: This puny howitzer doesn't have great penetration values, but could work very well as an HE thrower." )
		end
		if (node == DTTE_NodeList["75mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmH")
			DLabel:SetText( "75mm Howitzer\n\nArmor: 225mm\nWeight: 1200 kg\nReload Time: 8 seconds crewed, 12 seconds uncrewed\n\nAP Stats\nPenetration: 90mm\nDamage: 15\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 36mm\nDamage: 7.5\nSplash Damage: 22.5\nBlast Radius: 6.0m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 67.5mm\nDamage: 1.5\nPellets: 10\nVelocity: 450 m/s\n\nDescription: This howitzer gets some decent penetration but also has great HE potential." )
		end
		if (node == DTTE_NodeList["105mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "105mmH")
			DLabel:SetText( "105mm Howitzer\n\nArmor: 315mm\nWeight: 2400 kg\nReload Time: 11 seconds crewed, 16.5 seconds uncrewed\n\nAP Stats\nPenetration: 126mm\nDamage: 21\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 50.4mm\nDamage: 10.5\nSplash Damage: 31.5\nBlast Radius: 8.4m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 94.5mm\nDamage: 2.1\nPellets: 10\nVelocity: 450 m/s\n\nDescription: The penetration isn't the best in the world, but it puts out some good damage per shot, should be very powerful against light tanks" )
		end
		if (node == DTTE_NodeList["122mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "122mmH")
			DLabel:SetText( "122mm Howitzer\n\nArmor: 366mm\nWeight: 4000 kg\nReload Time: 13 seconds crewed, 19.5 seconds uncrewed\n\nAP Stats\nPenetration: 146.4mm\nDamage: 24.4\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 58.6mm\nDamage: 12.2\nSplash Damage: 36.6\nBlast Radius: 9.8m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 109.8mm\nDamage: 2.44\nPellets: 10\nVelocity: 450 m/s\n\nDescription: This high quality potato launcher puts out great damage for its weight." )
		end
		if (node == DTTE_NodeList["155mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "155mmH")
			DLabel:SetText( "155mm Howitzer\n\nArmor: 465mm\nWeight: 5600 kg\nReload Time: 16 seconds crewed, 24 seconds uncrewed\n\nAP Stats\nPenetration: 186mm\nDamage: 31\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 74.4mm\nDamage: 15.5\nSplash Damage: 46.5\nBlast Radius: 12.4m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 139.5mm\nDamage: 3.1\nPellets: 10\nVelocity: 450 m/s\n\nDescription: This howitzer combines good penetration with high damage values, leading to some horrendous damage on pens." )
		end
		if (node == DTTE_NodeList["203mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "203mmH")
			DLabel:SetText( "203mm Howitzer\n\nArmor: 609mm\nWeight: 7200 kg\nReload Time: 21 seconds crewed, 31.5 seconds uncrewed\n\nAP Stats\nPenetration: 243.6mm\nDamage: 40.6\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 97.4mm\nDamage: 20.3\nSplash Damage: 60.9\nBlast Radius: 16.2m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 182.7mm\nDamage: 4.06\nPellets: 10\nVelocity: 450 m/s\n\nDescription: You could probably shoot through like 3 light tanks in a line with this thing." )
		end
		if (node == DTTE_NodeList["420mmH"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmH")
			DLabel:SetText( "420mm Howitzer\n\nArmor: 1260mm\nWeight: 14400 kg\nReload Time: 44 seconds crewed, 66 seconds uncrewed\n\nAP Stats\nPenetration: 504mm\nDamage: 84\nVelocity: 600 m/s\n\nHE Stats\nPenetration: 201.6mm\nDamage: 42\nSplash Damage: 126\nBlast Radius: 33.6m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: 378mm\nDamage: 8.4\nPellets: 10\nVelocity: 450 m/s\n\nDescription: This massive howitzer has a reload time of nearly a full minute, but should destroy heavy tanks in just a couple shots. Very little will be able to block damage from this massive gun. Just don't miss." )
		end

		--Mortars
		if (node == DTTE_NodeList["60mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "60mmM")
			DLabel:SetText( "60mm Mortar\n\nArmor: 120mm\nWeight: 200 kg\nReload Time: 7 seconds crewed, 10.5 seconds uncrewed\n\nAP Stats\nPenetration: 30mm\nDamage: 3\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 12mm\nDamage: 1.5\nSplash Damage: 21\nBlast Radius: 4.8m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 22.5mm\nDamage: 0.3\nPellets: 10\nVelocity: 120 m/s\n\nDescription: For the most part these are used as anti infantry support, you'll be lucky to even get through roof armor with your HE." )
		end
		if (node == DTTE_NodeList["90mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "90mmM")
			DLabel:SetText( "90mm Mortar\n\nArmor: 180mm\nWeight: 400 kg\nReload Time: 10 seconds crewed, 15 seconds uncrewed\n\nAP Stats\nPenetration: 45mm\nDamage: 4.5\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 18mm\nDamage: 2.25\nSplash Damage: 31.5\nBlast Radius: 7.2m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 33.75mm\nDamage: 0.45\nPellets: 10\nVelocity: 120 m/s\n\nDescription: This heavy infantry support mortar has a decent chance of getting through roof armor, though not much luck of getting through a turret." )
		end
		if (node == DTTE_NodeList["120mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmM")
			DLabel:SetText( "120mm Mortar\n\nArmor: 240mm\nWeight: 750 kg\nReload Time: 14 seconds crewed, 21 seconds uncrewed\n\nAP Stats\nPenetration: 60mm\nDamage: 6\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 24mm\nDamage: 3\nSplash Damage: 42\nBlast Radius: 9.6m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 45mm\nDamage: 0.6\nPellets: 10\nVelocity: 120 m/s\n\nDescription: This versatile mortar should be able to do some decent splash damage against roofs, and rears and its AP rounds could deal heavy damage through roof tops." )
		end
		if (node == DTTE_NodeList["150mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "150mmM")
			DLabel:SetText( "150mm Mortar\n\nArmor: 300mm\nWeight: 1250 kg\nReload Time: 17 seconds crewed, 25.5 seconds uncrewed\n\nAP Stats\nPenetration: 75mm\nDamage: 7.5\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 30mm\nDamage: 3.75\nSplash Damage: 52.5\nBlast Radius: 12.0m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 56.25mm\nDamage: 0.75\nPellets: 10\nVelocity: 120 m/s\n\nDescription: This mid range mortar puts out great HE damage for its weight with decent penetration." )
		end
		if (node == DTTE_NodeList["240mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "240mmM")
			DLabel:SetText( "240mm Mortar\n\nArmor: 480mm\nWeight: 2250 kg\nReload Time: 27 seconds crewed, 54 seconds uncrewed\n\nAP Stats\nPenetration: 120mm\nDamage: 12\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 48mm\nDamage: 6\nSplash Damage: 84\nBlast Radius: 19.2m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 90mm\nDamage: 1.2\nPellets: 10\nVelocity: 120 m/s\n\nDescription: This mortar could punch right through weak rear armor and explode inside, roofs will be no problem." )
		end
		if (node == DTTE_NodeList["280mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "280mmM")
			DLabel:SetText( "280mm Mortar\n\nArmor: 560mm\nWeight: 3000 kg\nReload Time: 32 seconds crewed, 48 seconds uncrewed\n\nAP Stats\nPenetration: 140mm\nDamage: 14\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 56mm\nDamage: 7\nSplash Damage: 98\nBlast Radius: 22.4m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 105mm\nDamage: 1.4\nPellets: 10\nVelocity: 120 m/s\n\nDescription: Its rather hard to miss a target with the splash on this mortar, you're bound to put in some damage." )
		end
		if (node == DTTE_NodeList["420mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmM")
			DLabel:SetText( "420mm Mortar\n\nArmor: 840mm\nWeight: 4300 kg\nReload Time: 47 seconds crewed, 70.5 seconds uncrewed\n\nAP Stats\nPenetration: 210mm\nDamage: 21\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 84mm\nDamage: 10.5\nSplash Damage: 147\nBlast Radius: 33.6m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 157.5mm\nDamage: 2.1\nPellets: 10\nVelocity: 120 m/s\n\nDescription: This siege mortar will have no problems going through a turret and roof to explode inside of vehicles, causing crippling damage." )
		end
		if (node == DTTE_NodeList["600mmM"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "600mmM")
			DLabel:SetText( "600mm Mortar\n\nArmor: 1200mm\nWeight: 8000 kg\nReload Time: 68 seconds crewed, 102 seconds uncrewed\n\nAP Stats\nPenetration: 300mm\nDamage: 30\nVelocity: 160 m/s\n\nHE Stats\nPenetration: 120mm\nDamage: 15\nSplash Damage: 210\nBlast Radius: 48.0m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: 225mm\nDamage: 3.0\nPellets: 10\nVelocity: 120 m/s\n\nDescription: Direct hits through the roof with this mortar should simply vaporize vehicles, otherwise you can splash entire groups at once." )
		end

		----AMMO

		--20mmHMG
		if (node == DTTE_NodeList["20mmHMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "20mmHMGAPAmmo")
			DLabel:SetText( "20mmHMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 70\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["20mmHMGHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "20mmHMGHEAmmo")
			DLabel:SetText( "20mmHMG HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 70\n\nDescription: Makes guns shootier, also explodes." )
		end
		--30mmHMG
		if (node == DTTE_NodeList["30mmHMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "30mmHMGAPAmmo")
			DLabel:SetText( "30mmHMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 50\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["30mmHMGHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "30mmHMGHEAmmo")
			DLabel:SetText( "30mmHMG HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 50\n\nDescription: Makes guns shootier, also explodes." )
		end
		--40mmHMG
		if (node == DTTE_NodeList["40mmHMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "40mmHMGAPAmmo")
			DLabel:SetText( "40mmHMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 40\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["40mmHMGHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "40mmHMGHEAmmo")
			DLabel:SetText( "40mmHMG HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 40\n\nDescription: Makes guns shootier, also explodes." )
		end

		--5.56mmMG
		if (node == DTTE_NodeList["5.56mmMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "5.56mmMGAPAmmo")
			DLabel:SetText( "5.56mmMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 500\n\nDescription: Makes guns shootier, also explodes." )
		end
		--7.62mmMG
		if (node == DTTE_NodeList["7.62mmMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "7.62mmMGAPAmmo")
			DLabel:SetText( "7.62mmMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 425\n\nDescription: Makes guns shootier, also explodes." )
		end
		--9mmMG
		if (node == DTTE_NodeList["9mmMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "9mmMGAPAmmo")
			DLabel:SetText( "9mmMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 350\n\nDescription: Makes guns shootier, also explodes." )
		end
		--12.7mmMG
		if (node == DTTE_NodeList["12.7mmMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "12.7mmMGAPAmmo")
			DLabel:SetText( "12.7mmMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 275\n\nDescription: Makes guns shootier, also explodes." )
		end
		--14.5mmMG
		if (node == DTTE_NodeList["14.5mmMGAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "14.5mmMGAPAmmo")
			DLabel:SetText( "14.5mmMG AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 200\n\nDescription: Makes guns shootier, also explodes." )
		end

		--25mmC
		if (node == DTTE_NodeList["25mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "25mmCAPAmmo")
			DLabel:SetText( "25mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 50\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["25mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "25mmCHEAmmo")
			DLabel:SetText( "25mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 50\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["25mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "25mmCFLAmmo")
			DLabel:SetText( "25mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 50\n\nDescription: Makes guns shootier, also explodes." )
		end
		--37mmC
		if (node == DTTE_NodeList["37mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "37mmCAPAmmo")
			DLabel:SetText( "37mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 35\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["37mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "37mmCHEAmmo")
			DLabel:SetText( "37mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 35\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["37mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "37mmCFLAmmo")
			DLabel:SetText( "37mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 35\n\nDescription: Makes guns shootier, also explodes." )
		end
		--50mmC
		if (node == DTTE_NodeList["50mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmCAPAmmo")
			DLabel:SetText( "50mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 20\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["50mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmCHEAmmo")
			DLabel:SetText( "50mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 20\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["50mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmCFLAmmo")
			DLabel:SetText( "50mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 20\n\nDescription: Makes guns shootier, also explodes." )
		end
		--75mmC
		if (node == DTTE_NodeList["75mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmCAPAmmo")
			DLabel:SetText( "75mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 15\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["75mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmCHEAmmo")
			DLabel:SetText( "75mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 15\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["75mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmCFLAmmo")
			DLabel:SetText( "75mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 15\n\nDescription: Makes guns shootier, also explodes." )
		end
		--100mmC
		if (node == DTTE_NodeList["100mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "100mmCAPAmmo")
			DLabel:SetText( "100mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 10\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["100mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "100mmCHEAmmo")
			DLabel:SetText( "100mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 10\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["100mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "100mmCFLAmmo")
			DLabel:SetText( "100mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 10\n\nDescription: Makes guns shootier, also explodes." )
		end
		--120mmC
		if (node == DTTE_NodeList["120mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmCAPAmmo")
			DLabel:SetText( "120mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 8\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["120mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmCHEAmmo")
			DLabel:SetText( "120mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 8\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["120mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmCFLAmmo")
			DLabel:SetText( "120mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 8\n\nDescription: Makes guns shootier, also explodes." )
		end
		--100mmC
		if (node == DTTE_NodeList["152mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "152mmCAPAmmo")
			DLabel:SetText( "152mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 6\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["152mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "152mmCHEAmmo")
			DLabel:SetText( "152mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 6\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["152mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "152mmCFLAmmo")
			DLabel:SetText( "152mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 6\n\nDescription: Makes guns shootier, also explodes." )
		end
		--100mmC
		if (node == DTTE_NodeList["200mmCAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "200mmCAPAmmo")
			DLabel:SetText( "200mmC AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["200mmCHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "200mmCHEAmmo")
			DLabel:SetText( "200mmC HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["200mmCFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "200mmCFLAmmo")
			DLabel:SetText( "200mmC FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end


		--50mmH
		if (node == DTTE_NodeList["50mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmHAPAmmo")
			DLabel:SetText( "50mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 10\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["50mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmHHEAmmo")
			DLabel:SetText( "50mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 10\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["50mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "50mmHFLAmmo")
			DLabel:SetText( "50mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 10\n\nDescription: Makes guns shootier, also explodes." )
		end
		--75mmH
		if (node == DTTE_NodeList["75mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmHAPAmmo")
			DLabel:SetText( "75mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 7\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["75mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmHHEAmmo")
			DLabel:SetText( "75mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 7\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["75mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "75mmHFLAmmo")
			DLabel:SetText( "75mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 7\n\nDescription: Makes guns shootier, also explodes." )
		end
		--105mmH
		if (node == DTTE_NodeList["105mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "105mmHAPAmmo")
			DLabel:SetText( "105mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 5\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["105mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "105mmHHEAmmo")
			DLabel:SetText( "105mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 5\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["105mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "105mmHFLAmmo")
			DLabel:SetText( "105mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 5\n\nDescription: Makes guns shootier, also explodes." )
		end
		--122mmH
		if (node == DTTE_NodeList["122mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "122mmHAPAmmo")
			DLabel:SetText( "122mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["122mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "122mmHHEAmmo")
			DLabel:SetText( "122mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["122mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "122mmHFLAmmo")
			DLabel:SetText( "122mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		--155mmH
		if (node == DTTE_NodeList["155mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "155mmHAPAmmo")
			DLabel:SetText( "155mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 3\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["155mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "155mmHHEAmmo")
			DLabel:SetText( "155mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 3\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["155mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "155mmHFLAmmo")
			DLabel:SetText( "155mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 3\n\nDescription: Makes guns shootier, also explodes." )
		end
		--203mmH
		if (node == DTTE_NodeList["203mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "203mmHAPAmmo")
			DLabel:SetText( "203mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 2\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["203mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "203mmHHEAmmo")
			DLabel:SetText( "203mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 2\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["203mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "203mmHFLAmmo")
			DLabel:SetText( "203mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 2\n\nDescription: Makes guns shootier, also explodes." )
		end
		--420mmH
		if (node == DTTE_NodeList["420mmHAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmHAPAmmo")
			DLabel:SetText( "420mmH AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 1\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["420mmHHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmHHEAmmo")
			DLabel:SetText( "420mmH HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 1\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["420mmHFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmHFLAmmo")
			DLabel:SetText( "420mmH FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 1\n\nDescription: Makes guns shootier, also explodes." )
		end

		--60mmM
		if (node == DTTE_NodeList["60mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "60mmMAPAmmo")
			DLabel:SetText( "60mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 16\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["60mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "60mmMHEAmmo")
			DLabel:SetText( "60mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 16\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["60mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "60mmMFLAmmo")
			DLabel:SetText( "60mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 16\n\nDescription: Makes guns shootier, also explodes." )
		end
		--90mmM
		if (node == DTTE_NodeList["90mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "90mmMAPAmmo")
			DLabel:SetText( "90mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 12\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["90mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "90mmMHEAmmo")
			DLabel:SetText( "90mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 12\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["90mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "90mmMFLAmmo")
			DLabel:SetText( "90mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 12\n\nDescription: Makes guns shootier, also explodes." )
		end
		--120mmM
		if (node == DTTE_NodeList["120mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmMAPAmmo")
			DLabel:SetText( "120mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 8\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["120mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmMHEAmmo")
			DLabel:SetText( "120mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 8\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["120mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "120mmMFLAmmo")
			DLabel:SetText( "120mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 8\n\nDescription: Makes guns shootier, also explodes." )
		end
		--150mmM
		if (node == DTTE_NodeList["150mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "150mmMAPAmmo")
			DLabel:SetText( "150mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 6\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["150mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "150mmMHEAmmo")
			DLabel:SetText( "150mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 6\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["150mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "150mmMFLAmmo")
			DLabel:SetText( "150mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 6\n\nDescription: Makes guns shootier, also explodes." )
		end
		--240mmM
		if (node == DTTE_NodeList["240mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "240mmMAPAmmo")
			DLabel:SetText( "240mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["240mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "240mmMHEAmmo")
			DLabel:SetText( "240mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["240mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "240mmMFLAmmo")
			DLabel:SetText( "240mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 4\n\nDescription: Makes guns shootier, also explodes." )
		end
		--280mmM
		if (node == DTTE_NodeList["280mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "280mmMAPAmmo")
			DLabel:SetText( "280mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 3\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["280mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "280mmMHEAmmo")
			DLabel:SetText( "280mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 3\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["280mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "280mmMFLAmmo")
			DLabel:SetText( "280mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 3\n\nDescription: Makes guns shootier, also explodes." )
		end
		--420mmM
		if (node == DTTE_NodeList["420mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmMAPAmmo")
			DLabel:SetText( "420mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 2\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["420mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmMHEAmmo")
			DLabel:SetText( "420mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 2\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["420mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "420mmMFLAmmo")
			DLabel:SetText( "420mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 2\n\nDescription: Makes guns shootier, also explodes." )
		end
		--600mmM
		if (node == DTTE_NodeList["600mmMAPAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "600mmMAPAmmo")
			DLabel:SetText( "600mmM AP Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 1\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["600mmMHEAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "600mmMHEAmmo")
			DLabel:SetText( "600mmM HE Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 1\n\nDescription: Makes guns shootier, also explodes." )
		end
		if (node == DTTE_NodeList["600mmMFLAmmo"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "600mmMFLAmmo")
			DLabel:SetText( "600mmM FL Ammo\n\nHealth: 10\nWeight: 200kg\nAmmo: 1\n\nDescription: Makes guns shootier, also explodes." )
		end

		if (node == DTTE_NodeList["MicroEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroEngine")
			DLabel:SetText( "Micro Engine\n\nHealth: 15\nArmor: 15mm\nWeight: 1250 kg\nSpeed: 50 crewed/30 uncrewed kph at 10 ton total mass\n\nDescription: Tiny engine for tiny tanks." )
		end
		if (node == DTTE_NodeList["SmallEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallEngine")
			DLabel:SetText( "Small Engine\n\nHealth: 30\nArmor: 30mm\nWeight: 1875 kg\nSpeed: 80 crewed/48 uncrewed kph at 10 ton total mass\n\nDescription: Small engine for light tanks and slow mediums." )
		end
		if (node == DTTE_NodeList["StandardEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardEngine")
			DLabel:SetText( "Standard Engine\n\nHealth: 45\nArmor: 45mm\nWeight: 2500 kg\nSpeed: 110 crewed/66 uncrewed kph at 10 ton total mass\n\nDescription: Standard sized engine for medium tanks or slow heavies." )
		end
		if (node == DTTE_NodeList["LargeEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeEngine")
			DLabel:SetText( "Large Engine\n\nHealth: 60\nArmor: 60mm\nWeight: 3125 kg\nSpeed: 140 crewed/84 uncrewed kph at 10 ton total mass\n\nDescription: Large engine for heavy tanks." )
		end
		if (node == DTTE_NodeList["HugeEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeEngine")
			DLabel:SetText( "Huge Engine\n\nHealth: 75\nArmor: 75mm\nWeight: 3750 kg\nSpeed: 170 crewed/102 uncrewed kph at 10 ton total mass\n\nDescription: Huge engine for heavy tanks that want to move fast." )
		end
		if (node == DTTE_NodeList["UltraEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraEngine")
			DLabel:SetText( "Ultra Engine\n\nHealth: 90\nArmor: 90mm\nWeight: 5000 kg\nSpeed: 200 crewed/120 uncrewed kph at 10 ton total mass\n\nDescription: Ultra engine for use in super heavy tanks." )
		end


		if (node == DTTE_NodeList["MicroFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroFuel")
			DLabel:SetText( "Micro Fuel Tank\n\nHealth: 10\nWeight: 65 kg\nSpeed: Multiplies engine power by 0.5\n\nDescription: Tiny fuel tank to run light tanks and tankettes." )
		end
		if (node == DTTE_NodeList["SmallFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallFuel")
			DLabel:SetText( "Small Fuel Tank\n\nHealth: 20\nWeight: 120 kg\nSpeed: Multiplies engine power by 0.75\n\nDescription: Small fuel tank for light tanks and weak engined mediums." )
		end
		if (node == DTTE_NodeList["StandardFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardFuel")
			DLabel:SetText( "Standard Fuel Tank\n\nHealth: 30\nWeight: 240 kg\nSpeed: Multiplies engine power by 1.0\n\nDescription: Standard medium tank fuel tank." )
		end
		if (node == DTTE_NodeList["LargeFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeFuel")
			DLabel:SetText( "Large Fuel Tank\n\nHealth: 40\nWeight: 475 kg\nSpeed: Multiplies engine power by 1.25\n\nDescription: Large fuel tanks for heavies running mid sized engines." )
		end
		if (node == DTTE_NodeList["HugeFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeFuel")
			DLabel:SetText( "Huge Fuel Tank\n\nHealth: 50\nWeight: 950 kg\nSpeed: Multiplies engine power by 1.5\n\nDescription: Huge fuel tank for heavies running large gas guzzlers." )
		end
		if (node == DTTE_NodeList["UltraFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraFuel")
			DLabel:SetText( "Ultra Fuel Tank\n\nHealth: 60\nWeight: 1900 kg\nSpeed: Multiplies engine power by 2\n\nDescription: Massive fuel tank designed for super heavy tanks running the largest of engines." )
		end
		--GENERAL INFO
		if (node == DTTE_NodeList["Core"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tankcore")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Core")
			DLabel:SetText( "Tank Core\n\nThis is the tank's automated health pooling system, just parent one onto your tank and it will combine the HP of all attached props and have them act as one. They will still each have their own unique armor values though, load weight into pieces that need it." )
		end
		if (node == DTTE_NodeList["Crew"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_crew")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Crew")
			DLabel:SetText( "Crew Member\n\nHealth: 5\nWeight: 75kg\n\nAllows an entity to function up to their full potential when linked to it. Can be linked to engines, normal guns, autocannons, and HMGs, but not autoloaders or machine guns." )
		end

		if (node == DTTE_NodeList["TControl"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_turretcontrol")
			RunConsoleCommand("daktankspawner_SpawnSettings", "TControl")
			DLabel:SetText( "Turret Controller\n\nThis entity acts as a turret E2 would, except its more optimized and required for regulation DakTank vehicles. It must have the arrow pointing forward. You can set the elevation, depression, and yaw limits by holding C and right clicking this chip and pressing edit properties. The Gun input goes directly to the heaviest gun in the turret, the gun itself, not the aimer. It can also be boosted by a turret motor." )
		end
		if (node == DTTE_NodeList["TMotor"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_turretmotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "TMotor")
			DLabel:SetText( "Turret Motor\n\nThis can be linked to a single turret controller, doubling the speed that the turret rotates. If destroyed turret speed will go back to normal." )
		end

		if (node == DTTE_NodeList["Utilities"]) then
			DLabel:SetText( "Utilities\n\nThis stuff is required to keep your vehicle running." )
		end
		if (node == DTTE_NodeList["Mobility"]) then
			DLabel:SetText( "Mobility\n\nThe equipment used to get your vehicle moving." )
		end
		if (node == DTTE_NodeList["Turret"]) then
			DLabel:SetText( "Turret\n\nThe equipment used to rotate your gun, for turreted and non turreted vehicles." )
		end
		if (node == DTTE_NodeList["Fuel"]) then
			DLabel:SetText( "Fuel\n\nFuel tanks are required to run your engine, there are different sizes providing different bonuses." )
		end
		if (node == DTTE_NodeList["Engine"]) then
			DLabel:SetText( "Engines\n\nLarge gas guzzlers to get your tank moving at speeds faster than a brisk walk." )
		end
		if (node == DTTE_NodeList["Weapons"]) then
			DLabel:SetText( "Weapons\n\nEquipment used to make things deader, point at things you want removed." )
		end
		if (node == DTTE_NodeList["APAmmo"]) then
			DLabel:SetText( "Armor Piercing Rounds\n\nHigh penetration value single shot rounds good for getting through heavy armor and dealing solid damage." )
		end
		if (node == DTTE_NodeList["HEAmmo"]) then
			DLabel:SetText( "High Explosive Rounds\n\nLow penetration rounds that explode when hitting armor they can't pen, the explosion deals damage ignoring sloping." )
		end
		if (node == DTTE_NodeList["FLAmmo"]) then
			DLabel:SetText( "Flechette Rounds\n\nThese rounds fire a burst of projectiles towards the target, dealing the same base damage as AP rounds when totalled but with 75% of the penetration and velocity. They're good for seeking criticals against internal components against light armor." )
		end
		if (node == DTTE_NodeList["Ammo"]) then
			DLabel:SetText( "Ammo\n\nKeeps guns shooty." )
		end


		if (node == DTTE_NodeList["ALClips"]) then
			DLabel:SetText( "Autoloader Clips\n\nThese are the clips that hold shells and supply them to an autoloader. They are explosive." )
		end
		if (node == DTTE_NodeList["ALGuns"]) then
			DLabel:SetText( "Autoloading Cannons\n\nThese are cannons modified to work with a clip, they will not fire without one." )
		end
		if (node == DTTE_NodeList["MGs"]) then
			DLabel:SetText( "Machine Guns\n\nLight and rapid fire anti infantry guns with very little penetration power and only AP rounds, its best to not waste them on armored targets." )
		end
		if (node == DTTE_NodeList["HMGs"]) then
			DLabel:SetText( "Heavy Machine Guns\n\nMore light barreled autocannons than machine guns, these are somewhat useful against both armored targets and infantry. They can only use AP and HE HMG ammo." )
		end

		if (node == DTTE_NodeList["Autocannons"]) then
			DLabel:SetText( "Autocannons\n\nLight guns with large clips and very rapid fire but long reload times. Great for hit and runs. They can only use AP and HE cannon ammo." )
		end
		if (node == DTTE_NodeList["Autoloaders"]) then
			DLabel:SetText( "Autoloaders\n\nCannons that fire a burst of shells before having to reload. Great for hit and runs. They can only use AP and HE cannon ammo and require a clip." )
		end
		if (node == DTTE_NodeList["Cannons"]) then
			DLabel:SetText( "Cannons\n\nVersatile and reliable guns with high penetration and velocity but high weight." )
		end
		if (node == DTTE_NodeList["Howitzers"]) then
			DLabel:SetText( "Howitzers\n\nPowerful guns with high damage per shot and lower weights than cannons. They generally have longer reloads than cannons and have less velocity, but they also have higher bonuses on HE damage and radius." )
		end
		if (node == DTTE_NodeList["Mortars"]) then
			DLabel:SetText( "Mortars\n\nLight guns with low damage, penetration, and velocity but low weight and high HE splash radius. They generally have longer reloads than howitzers, but higher listed HE damage, however due to the low penetration they deal less damage than a howitzer of equal caliber." )
		end


		if (node == DTTE_NodeList["Help1"]) then
			DLabel:SetText( "DakTank Guide: The Basics\n\nIn DakTanks tanks consist of props making up armor, a fuel tank, an engine, at least one gun, ammo, a seat, and wiring all held together by the tank core entity. The tank core must be parented to a gate that has been parented (NOT WELDED) to the baseplate of the tank. Doing this will pool the tank's health and allow your guns to fire. Props set to 1kg will be considered detail props by the system and will be entirely ignored by the damage system (but will count towards total pooled HP). Please set any detail props to 1kg." )
		end
		if (node == DTTE_NodeList["Help2"]) then
			DLabel:SetText( "DakTank Guide: Armor\n\nEach prop has its own armor value based on the mm protection of steel plate. The amount of protection you get on the prop is determined by its weight and volume, or simply put its density. A large prop will take much more weight than a small prop, but you'll need large props on your tank if you are to fit your equipment, larger equipment tends to offer much better bonuses than smaller counterparts. Angling your armor will increase its effective thickness, making it harder for your armor to be penetrated, though HE damage ignores slope. Treads (or anything you set to make spherical using the tool for it) have their own designated armor value based on the actual thickness of the prop then run through a modifier. Treads can be penetrated but take no damage, this lets you use them as extra armor for your sides that will reduce the AP damage they take (slightly) but does nothing against HE." )
		end
		if (node == DTTE_NodeList["Help3"]) then
			DLabel:SetText( "DakTank Guide: Munitions: AP\n\nThere are 3 types of ammo, Armor Piercing (AP), High Explosive (HE), and Flechette (FL). Each type of ammo has its own purposes in the combat of daktek, it is a good idea to take at least some amount of each if your gun allows it.\n\nAP fires a single shell at a target, if it doesn't have enough penetration to go through the armor then it will only deal half its specified damage and be deflected away. If your shell does penetrate then it deals damage equal to its specified value multiplied by its own penetration value divided by the armor value of the prop it went through. The damage is capped to the amount of armor the prop has, making extremely heavy cannons firing AP not the best tool for dealing with light tanks, however you'll still shoot a hole right through them and likely rip out many modules at once and still deal respectable damage." )
		end
		if (node == DTTE_NodeList["Help4"]) then
			DLabel:SetText( "DakTank Guide: Munitions: HE\n\nHE fires an explosive shell at its target. It has penetration equal to 40% of an AP round's penetration and acts as an AP until it finds something it cannot penetrate, at which point it explodes, dealing damage to all things around it equal to the number designated in its stats divided by the amount of entities it hit. Each entity has the damage it takes further modified however, as the damage is multiplied by its penetration value and then divided by the enemy's armor value, similar to AP. HE does not have a damage cap however, making it very good at taking out lightly armored weak spots on enemies, such as extremely angled armor, roofs, weak sides, rears, and baseplates. HE's much lower base penetration than AP makes it generally do much weaker damage against heavy armor. Howitzers get a bonus to splash radius and damage compared to cannons." )
		end
		if (node == DTTE_NodeList["Help5"]) then
			DLabel:SetText( "DakTank Guide: Munitions: FL\n\nFL fires a volley of 10 projectiles at once like a large shotgun. It has more spread than normal shells, has 75% less penetration and velocity than AP. Each projectile is equal to a tenth of the damage of an AP shell. Where FL shines is attacking armor that it can overpenetrate by large margins. As I stated previously, AP's damage is capped to the total armor of a prop, so if you have 100mm of penetration going through 10mm armor and your shell does 5 damage then you get a times 10 multiplier to your damage, but you are capped to 10 damage instead of your 50 point potential. With FL you split the shell into 10 different bits and would have 75mm of penetration going through 10mm of armor, so you would have a 7.5 times multiplier and each shell has a base of 0.5 damage, this leads to 3.75 damage per shell, giving a total of 37.5 damage, nearly 4 times the amount of what AP would have done. It also is more likely to tear apart modules if it penetrates, great for flankers." )
		end
		if (node == DTTE_NodeList["Help6"]) then
			DLabel:SetText( "DakTank Guide: Weaponry\n\nIn DakTanks there are cannons, howitzers, autoloaders, autocannons, heavy machine guns, and machine guns. Cannons are your basic weapon type and have access to any ammo type. Howitzers have a higher focus on HE, with larger splash radius, splash damage, and total damage than cannons of equal weight but longer reloads and often less penetration per ton. Autoloaders are cannons that can only fire AP and HE and require a clip module, they can fire devastating bursts in a short period of time but can have very long reloading periods. Autocannons are low caliber AP and HE firing guns that fire 13-30 shots at a rate of 10 shots per second but then have a 30 second reload, they're great for light weight hit and run. HMGs have larger clips than autocannons and half the reload times but also half the penetration, slightly over half the damage per shot, and half the velocity. Machine Guns are rapid fire anti infantry weapons that barely scratch light armor and only uses AP." )
		end
		if (node == DTTE_NodeList["Help7"]) then
			DLabel:SetText( "DakTank Guide: Mobility\n\nVehicle speed is determined by the engine size, modified by the fuel tank size and total weight of the vehicle. Given the same engine and fuel tank a 30 ton tank will move twice as fast as a 60 tonner and will turn faster. The largest fuel tanks provide 50% bonuses to speed while the smallest will decrease your maximum speed, however the compact size makes it less likely to be hit if your tank is penetrated and a smaller vehicle has to spend less weight for the same armor values. You could create large but fast moving vehicles or small but heavily armored vehicles that will run into ammo problems or be forced to use small guns. The faster vehicle would be good against heavier tanks that it could flank while the heavy vehicle with a weak gun would be good for dominating tanks that are lighter than it. Turning speeds can also be modified by the length and width of your vehicle and the physical properties of the wheels." )
		end
		if (node == DTTE_NodeList["Help8"]) then
			DLabel:SetText( "DakTank Guide: Critical Hits\n\nCertain components such as fuel, ammo, and autoloader clips can suffer from catastrophic failure in cases in which they are reduced to less than half health but not outright destroyed. Upon exploding fuel and clips will deal 250 points of damage between the entities nearby and ammo will deal between 0 and 500 damage depending on how full the crate is. Ammo boxes can have their ammo ejected via its wire input to avoid such failures in dire circumstances, though it can take a few seconds to empty out fully." )
		end
	end
end

function TOOL:Think()
end
