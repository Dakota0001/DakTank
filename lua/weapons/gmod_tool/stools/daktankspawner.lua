 
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
TOOL.ClientConVar[ "DTTE_GunCaliber" ] = 5
TOOL.ClientConVar[ "DTTE_AmmoType" ] = ""

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
	if not(trace.Entity:GetClass() == self:GetClientInfo("SpawnEnt")) and not(trace.Entity:GetClass() == "dak_gun") and not(trace.Entity:GetClass() == "dak_laser") and not(trace.Entity:GetClass() == "dak_xpulselaser") and not(trace.Entity:GetClass() == "dak_launcher") and not(trace.Entity:GetClass() == "dak_lams") and not(trace.Entity:GetClass() == "dak_tegun") and not(trace.Entity:GetClass() == "dak_teautogun") and not(trace.Entity:GetClass() == "dak_temachinegun") and not(trace.Entity:GetClass() == "dak_teammo") then
		local Target = trace.HitPos
		local spawnent = self:GetClientInfo("SpawnEnt")
		self.spawnedent = ents.Create(spawnent)
		if ( !IsValid( self.spawnedent ) ) then return end
		self.spawnedent:SetPos(Target+Vector(0,0,2*self.spawnedent:OBBMins().z))
		self.spawnedent:SetAngles( Angle(0,0,0))
	end
	if (trace.Entity:GetClass() == "dak_gun") or (trace.Entity:GetClass() == "dak_laser") or (trace.Entity:GetClass() == "dak_xpulselaser") or (trace.Entity:GetClass() == "dak_launcher") or (trace.Entity:GetClass() == "dak_lams") or (trace.Entity:GetClass() == "dak_tegun") or (trace.Entity:GetClass() == "dak_teautogun") or (trace.Entity:GetClass() == "dak_temachinegun") or (trace.Entity:GetClass() == "dak_teammo") then
		if (self:GetClientInfo("SpawnEnt") == "dak_gun") or (self:GetClientInfo("SpawnEnt") == "dak_laser") or (self:GetClientInfo("SpawnEnt") == "dak_xpulselaser") or (self:GetClientInfo("SpawnEnt") == "dak_launcher") or (self:GetClientInfo("SpawnEnt") == "dak_lams") or (self:GetClientInfo("SpawnEnt") == "dak_tegun") or (self:GetClientInfo("SpawnEnt") == "dak_teautogun")or (self:GetClientInfo("SpawnEnt") == "dak_temachinegun") or (self:GetClientInfo("SpawnEnt") == "dak_teammo") then
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
		--Micro--
		if self:GetClientInfo("SpawnSettings") == "MicroAPBox" then
			self.spawnedent:SetModel( "models/Items/BoxSRounds.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGAPAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "MicroHEBox" then
			self.spawnedent:SetModel( "models/Items/BoxSRounds.mdl" )
			self.DakIsHE = true
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGHEAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "MicroFLBox" then
			self.spawnedent:SetModel( "models/Items/BoxSRounds.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGFLAmmo"
			end
		end
		--Small--
		if self:GetClientInfo("SpawnSettings") == "SmallAPBox" then
			self.spawnedent:SetModel( "models/props_c17/SuitCase_Passenger_Physics.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGAPAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "SmallHEBox" then
			self.spawnedent:SetModel( "models/props_c17/SuitCase_Passenger_Physics.mdl" )
			self.DakIsHE = true
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGHEAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "SmallFLBox" then
			self.spawnedent:SetModel( "models/props_c17/SuitCase_Passenger_Physics.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGFLAmmo"
			end
		end
		--Standard--
		if self:GetClientInfo("SpawnSettings") == "StandardAPBox" then
			self.spawnedent:SetModel( "models/Items/BoxMRounds.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGAPAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "StandardHEBox" then
			self.spawnedent:SetModel( "models/Items/BoxMRounds.mdl" )
			self.DakIsHE = true
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGHEAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "StandardFLBox" then
			self.spawnedent:SetModel( "models/Items/BoxMRounds.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGFLAmmo"
			end
		end
		--Large--
		if self:GetClientInfo("SpawnSettings") == "LargeAPBox" then
			self.spawnedent:SetModel( "models/props_c17/SuitCase001a.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGAPAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "LargeHEBox" then
			self.spawnedent:SetModel( "models/props_c17/SuitCase001a.mdl" )
			self.DakIsHE = true
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGHEAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "LargeFLBox" then
			self.spawnedent:SetModel( "models/props_c17/SuitCase001a.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGFLAmmo"
			end
		end
		--Huge--
		if self:GetClientInfo("SpawnSettings") == "HugeAPBox" then
			self.spawnedent:SetModel( "models/daktanks/Ammo.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGAPAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "HugeHEBox" then
			self.spawnedent:SetModel( "models/daktanks/Ammo.mdl" )
			self.DakIsHE = true
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGHEAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "HugeFLBox" then
			self.spawnedent:SetModel( "models/daktanks/Ammo.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGFLAmmo"
			end
		end
		--Ultra--
		if self:GetClientInfo("SpawnSettings") == "UltraAPBox" then
			self.spawnedent:SetModel( "models/Items/ammocrate_smg1.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGAPAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGAPAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGAPAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "UltraHEBox" then
			self.spawnedent:SetModel( "models/Items/ammocrate_smg1.mdl" )
			self.DakIsHE = true
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGHEAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGHEAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGHEAmmo"
			end
		end
		if self:GetClientInfo("SpawnSettings") == "UltraFLBox" then
			self.spawnedent:SetModel( "models/Items/ammocrate_smg1.mdl" )
			self.DakIsHE = false
			if self:GetClientInfo("DTTE_AmmoType") == "Cannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),25,200)
				self.DakName = self.DakCaliber.."mmCFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmCFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Howitzer" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),50,240)
				self.DakName = self.DakCaliber.."mmHFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Mortar" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),40,280)
				self.DakName = self.DakCaliber.."mmMFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Autocannon" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,60)
				self.DakName = self.DakCaliber.."mmACFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmACFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),5,25)
				self.DakName = self.DakCaliber.."mmMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmMGFLAmmo"
			end
			if self:GetClientInfo("DTTE_AmmoType") == "Heavy Machine Gun" then
				self.DakCaliber = math.Clamp(math.Round(tonumber(self:GetClientInfo("DTTE_GunCaliber")),2),20,40)
				self.DakName = self.DakCaliber.."mmHMGFLAmmo"
				self.DakIsExplosive = true
				self.DakAmmoType = self.DakCaliber.."mmHMGFLAmmo"
			end
		end
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
		if self:GetClientInfo("SpawnEnt") == "dak_tegun" or self:GetClientInfo("SpawnEnt") == "dak_teautogun" or self:GetClientInfo("SpawnEnt") == "dak_temachinegun" then
			self.spawnedent.DakOwner = self:GetOwner()
			self.spawnedent.DakGunType = self.DakGunType
			self.spawnedent.DakCaliber = self.DakCaliber
			self.spawnedent.DakMaxHealth = self.DakMaxHealth
			self.spawnedent.DakName = self.DakName
			self.spawnedent.DakModel = self.DakModel
			self.spawnedent:SetModel(self.spawnedent.DakModel)
		end
		if self:GetClientInfo("SpawnEnt") == "dak_teammo" then
			if trace.Entity then
				if trace.Entity:GetClass() == "dak_teammo" then
					trace.Entity.DakName = self.DakName
					trace.Entity.DakIsExplosive = self.DakIsExplosive
					--trace.Entity.DakAmmo = self.DakAmmo
					--trace.Entity.DakMaxAmmo = self.DakMaxAmmo
					trace.Entity.DakAmmoType = self.DakAmmoType
					trace.Entity.DakOwner = self:GetOwner()
					trace.Entity.DakIsHE = self.DakIsHE
					self:GetOwner():ChatPrint("Ammo updated.")
				end
			end
			if not(trace.Entity:IsValid()) then
				self.spawnedent.DakName = self.DakName
				self.spawnedent.DakIsExplosive = self.DakIsExplosive
				--self.spawnedent.DakAmmo = self.DakAmmo
				--self.spawnedent.DakMaxAmmo = self.DakMaxAmmo
				self.spawnedent.DakAmmoType = self.DakAmmoType
				self.spawnedent.DakOwner = self:GetOwner()
				self.spawnedent.DakIsHE = self.DakIsHE
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
				end
			end
			if Target:GetClass() == "dak_teautogun" then
				if Target.Loaders then
					ply:ChatPrint("Loaders: "..Target.Loaders)
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

local DLabelAmmo = vgui.Create( "DLabel", panel )
DLabelAmmo:SetPos( 17, 410 )
DLabelAmmo:SetAutoStretchVertical( true )
DLabelAmmo:SetText( "Select an entity and information for it will appear here" )
DLabelAmmo:SetTextColor(Color(0,0,0,255))
DLabelAmmo:SetWide( 200 )
DLabelAmmo:SetWrap( true )

local DermaNumSlider = vgui.Create( "DNumSlider", panel )
DermaNumSlider:SetPos( 10, 355 )			// Set the position
DermaNumSlider:SetSize( 200, 20 )		// Set the size
DermaNumSlider:SetText( "Caliber" )	// Set the text above the slider
DermaNumSlider:SetValue(5)
DermaNumSlider:SetMin( 0 )				// Set the minimum number you can slide to
DermaNumSlider:SetMax( 10 )				// Set the maximum number you can slide to
DermaNumSlider:SetDecimals( 2 )			// Decimal places - zero for whole number

local AmmoBoxSelect = vgui.Create( "DComboBox", panel )
AmmoBoxSelect:SetPos( 10, 385 )
AmmoBoxSelect:SetSize( 300, 20 )
AmmoBoxSelect:SetValue( "Pick Ammo Type" )
AmmoBoxSelect:AddChoice( "Autocannon" )
AmmoBoxSelect:AddChoice( "Cannon" )
AmmoBoxSelect:AddChoice( "Heavy Machine Gun" )
AmmoBoxSelect:AddChoice( "Howitzer" )
AmmoBoxSelect:AddChoice( "Machine Gun" )
AmmoBoxSelect:AddChoice( "Mortar" )
AmmoBoxSelect.OnSelect = function( panel, index, value )
	RunConsoleCommand("daktankspawner_DTTE_AmmoType", value)
	if value == "Autocannon" then
		DermaNumSlider:SetMin( 20 )
		DermaNumSlider:SetMax( 60 )	
	end
	if value == "Cannon" then
		DermaNumSlider:SetMin( 25 )
		DermaNumSlider:SetMax( 200 )	
	end
	if value == "Heavy Machine Gun" then
		DermaNumSlider:SetMin( 20 )
		DermaNumSlider:SetMax( 40 )	
	end
	if value == "Howitzer" then
		DermaNumSlider:SetMin( 50 )
		DermaNumSlider:SetMax( 240 )	
	end
	if value == "Machine Gun" then
		DermaNumSlider:SetMin( 5 )
		DermaNumSlider:SetMax( 25 )	
	end
	if value == "Mortar" then
		DermaNumSlider:SetMin( 40 )
		DermaNumSlider:SetMax( 280 )	
	end
end


AmmoBoxSelect:SetVisible(false)
DLabelAmmo:SetVisible(false)
DermaNumSlider:SetVisible(false)

DTTE_NodeList={}
DTTE_NodeList["Guide"] = ctrl:AddNode( "DakTank Guide" )
DTTE_NodeList["Help1"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: The Basics" )
DTTE_NodeList["Help2"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Armor" )
DTTE_NodeList["Help3"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Health" )
DTTE_NodeList["Help4"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Munitions: AP" )
DTTE_NodeList["Help5"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Munitions: HE" )
DTTE_NodeList["Help6"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Munitions: FL" )
DTTE_NodeList["Help7"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Weaponry" )
DTTE_NodeList["Help8"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Flamethrowers" )
DTTE_NodeList["Help9"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Mobility" )
DTTE_NodeList["Help10"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Critical Hits" )
DTTE_NodeList["Help11"] = DTTE_NodeList["Guide"]:AddNode( "DakTank Guide: Crew" )
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
		DTTE_NodeList["Gearbox"] = DTTE_NodeList["Mobility"]:AddNode( "Gearbox" )
			DTTE_NodeList["GearboxF"] = DTTE_NodeList["Gearbox"]:AddNode( "Frontal Mount Gearbox" )
				DTTE_NodeList["MicroGearboxF"] = DTTE_NodeList["GearboxF"]:AddNode( "Micro Frontal Mount Gearbox" )
				DTTE_NodeList["SmallGearboxF"] = DTTE_NodeList["GearboxF"]:AddNode( "Small Frontal Mount Gearbox" )
				DTTE_NodeList["StandardGearboxF"] = DTTE_NodeList["GearboxF"]:AddNode( "Standard Frontal Mount Gearbox" )
				DTTE_NodeList["LargeGearboxF"] = DTTE_NodeList["GearboxF"]:AddNode( "Large Frontal Mount Gearbox" )
				DTTE_NodeList["HugeGearboxF"] = DTTE_NodeList["GearboxF"]:AddNode( "Huge Frontal Mount Gearbox" )
				DTTE_NodeList["UltraGearboxF"] = DTTE_NodeList["GearboxF"]:AddNode( "Ultra Frontal Mount Gearbox" )
			DTTE_NodeList["GearboxR"] = DTTE_NodeList["Gearbox"]:AddNode( "Rear Mount Gearbox" )
				DTTE_NodeList["MicroGearboxR"] = DTTE_NodeList["GearboxR"]:AddNode( "Micro Rear Mount Gearbox" )
				DTTE_NodeList["SmallGearboxR"] = DTTE_NodeList["GearboxR"]:AddNode( "Small Rear Mount Gearbox" )
				DTTE_NodeList["StandardGearboxR"] = DTTE_NodeList["GearboxR"]:AddNode( "Standard Rear Mount Gearbox" )
				DTTE_NodeList["LargeGearboxR"] = DTTE_NodeList["GearboxR"]:AddNode( "Large Rear Mount Gearbox" )
				DTTE_NodeList["HugeGearboxR"] = DTTE_NodeList["GearboxR"]:AddNode( "Huge Rear Mount Gearbox" )
				DTTE_NodeList["UltraGearboxR"] = DTTE_NodeList["GearboxR"]:AddNode( "Ultra Rear Mount Gearbox" )
	DTTE_NodeList["Turret"] = DTTE_NodeList["Utilities"]:AddNode( "Turret" )
		DTTE_NodeList["TControl"] = DTTE_NodeList["Turret"]:AddNode( "Turret Controller" )
		DTTE_NodeList["TMotor"] = DTTE_NodeList["Turret"]:AddNode( "Turret Motor" )
	DTTE_NodeList["Weapons"] = ctrl:AddNode( "Weapons" )
		DTTE_NodeList["Autocannons"] = DTTE_NodeList["Weapons"]:AddNode( "Autocannons" )
		DTTE_NodeList["Autoloaders"] = DTTE_NodeList["Weapons"]:AddNode( "Autoloaders" )
			DTTE_NodeList["ALGuns"] = DTTE_NodeList["Autoloaders"]:AddNode( "Autoloading Guns" )
			DTTE_NodeList["ALClips"] = DTTE_NodeList["Autoloaders"]:AddNode( "Autoloader Clips" )
				DTTE_NodeList["SALClip"] = DTTE_NodeList["ALClips"]:AddNode( "Small Autoloader Clip" )
				DTTE_NodeList["MALClip"] = DTTE_NodeList["ALClips"]:AddNode( "Medium Autoloader Clip" )
				DTTE_NodeList["LALClip"] = DTTE_NodeList["ALClips"]:AddNode( "Large Autoloader Clip" )
			
		DTTE_NodeList["Cannons"] = DTTE_NodeList["Weapons"]:AddNode( "Cannons" )
		DTTE_NodeList["Flamethrower"] = DTTE_NodeList["Weapons"]:AddNode( "Flamethrower" )
		DTTE_NodeList["Howitzers"] = DTTE_NodeList["Weapons"]:AddNode( "Howitzers" )
		DTTE_NodeList["Mortars"] = DTTE_NodeList["Weapons"]:AddNode( "Mortars" )
		DTTE_NodeList["MGs"] = DTTE_NodeList["Weapons"]:AddNode( "Machine Guns" )
		DTTE_NodeList["HMGs"] = DTTE_NodeList["Weapons"]:AddNode( "Heavy Machine Guns" )

DTTE_NodeList["Ammo"] = ctrl:AddNode( "Ammo" )
	DTTE_NodeList["APAmmo"] = DTTE_NodeList["Ammo"]:AddNode( "Armor Piercing" )
		DTTE_NodeList["MicroAPBox"] = DTTE_NodeList["APAmmo"]:AddNode( "Micro AP Ammo Box" )
		DTTE_NodeList["SmallAPBox"] = DTTE_NodeList["APAmmo"]:AddNode( "Small AP Ammo Box" )
		DTTE_NodeList["StandardAPBox"] = DTTE_NodeList["APAmmo"]:AddNode( "Standard AP Ammo Box" )
		DTTE_NodeList["LargeAPBox"] = DTTE_NodeList["APAmmo"]:AddNode( "Large AP Ammo Box" )
		DTTE_NodeList["HugeAPBox"] = DTTE_NodeList["APAmmo"]:AddNode( "Huge AP Ammo Box" )
		DTTE_NodeList["UltraAPBox"] = DTTE_NodeList["APAmmo"]:AddNode( "Ultra AP Ammo Box" )
	DTTE_NodeList["HEAmmo"] = DTTE_NodeList["Ammo"]:AddNode( "High Explosive" )
		DTTE_NodeList["MicroHEBox"] = DTTE_NodeList["HEAmmo"]:AddNode( "Micro HE Ammo Box" )
		DTTE_NodeList["SmallHEBox"] = DTTE_NodeList["HEAmmo"]:AddNode( "Small HE Ammo Box" )
		DTTE_NodeList["StandardHEBox"] = DTTE_NodeList["HEAmmo"]:AddNode( "Standard HE Ammo Box" )
		DTTE_NodeList["LargeHEBox"] = DTTE_NodeList["HEAmmo"]:AddNode( "Large HE Ammo Box" )
		DTTE_NodeList["HugeHEBox"] = DTTE_NodeList["HEAmmo"]:AddNode( "Huge HE Ammo Box" )
		DTTE_NodeList["UltraHEBox"] = DTTE_NodeList["HEAmmo"]:AddNode( "Ultra HE Ammo Box" )
	DTTE_NodeList["FLAmmo"] = DTTE_NodeList["Ammo"]:AddNode( "Flechette" )
		DTTE_NodeList["MicroFLBox"] = DTTE_NodeList["FLAmmo"]:AddNode( "Micro FL Ammo Box" )
		DTTE_NodeList["SmallFLBox"] = DTTE_NodeList["FLAmmo"]:AddNode( "Small FL Ammo Box" )
		DTTE_NodeList["StandardFLBox"] = DTTE_NodeList["FLAmmo"]:AddNode( "Standard FL Ammo Box" )
		DTTE_NodeList["LargeFLBox"] = DTTE_NodeList["FLAmmo"]:AddNode( "Large FL Ammo Box" )
		DTTE_NodeList["HugeFLBox"] = DTTE_NodeList["FLAmmo"]:AddNode( "Huge FL Ammo Box" )
		DTTE_NodeList["UltraFLBox"] = DTTE_NodeList["FLAmmo"]:AddNode( "Ultra FL Ammo Box" )
	DTTE_NodeList["FTFuel"] = DTTE_NodeList["Ammo"]:AddNode( "Flamethrower Fuel" )

	function DermaNumSlider:OnValueChanged( cal )
		RunConsoleCommand("daktankspawner_DTTE_GunCaliber", cal)

		if ctrl:GetSelectedItem():GetText() == "Cannons" then
			DLabel:SetText( math.Round(cal,2).."mm Cannon\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((9000/((200/cal)*(200/cal)))).." kg\nReload Time: "..math.Round(((cal/13 + cal/100)),2).." seconds crewed, "..math.Round(((cal/13 + cal/100)*1.5),2).." seconds uncrewed\n\nAP Stats\nPenetration: "..math.Round((cal*2),2).."mm\nDamage: "..math.Round(cal*0.25,2).."\nVelocity: 800 m/s\n\nHE Stats\nPenetration: "..math.Round((cal*2*0.3),2).."mm\nFrag Penetration: "..math.Round((cal/2.5),2).."mm\nDamage: "..math.Round(cal*0.25*0.5,2).."\nSplash Damage: "..math.Round(cal*0.375,2).."\nBlast Radius: "..math.Round((cal/25),2).."m\nVelocity: 800 m/s\n\nFL Stats\nPenetration: "..math.Round((cal*2*0.75),2).."mm\nDamage: "..math.Round(cal*0.025,2).."\nPellets: 10\nVelocity: 600 m/s\n\nDescription: Versatile and reliable guns with high penetration and velocity but high weight." )
		end
		if ctrl:GetSelectedItem():GetText() == "Autoloading Guns" then
			DLabel:SetText( math.Round(cal,2).."mm Autoloader\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((9000/((200/cal)*(200/cal)))).." kg\nReload Time: "..math.Round(((cal/13 + cal/100)*0.2),2).."\nSmall Clip Size: "..math.Round(600/cal).."\nMedium Clip Size: "..math.Round((600/cal)*1.5).."\nLarge Clip Size: "..math.Round((600/cal)*2).."\nSmall Clip Reload Time: "..math.Round((cal/13 + cal/100)*math.Round(600/cal),2).."\nMedium Clip Reload Time: "..math.Round(((cal/13 + cal/100)*math.Round((600/cal)*1.5)*0.75),2).."\nLarge Clip Reload Time: "..math.Round(((cal/13 + cal/100)*math.Round((600/cal)*2)*0.5),2).."\n\nAP Stats\nPenetration: "..math.Round((cal*2),2).."mm\nDamage: "..math.Round(cal*0.25,2).."\nVelocity: 800 m/s\n\nHE Stats\nPenetration: "..math.Round((cal*2*0.3),2).."mm\nFrag Penetration: "..math.Round((cal/2.5),2).."mm\nDamage: "..math.Round(cal*0.25*0.5,2).."\nSplash Damage: "..math.Round(cal*0.375,2).."\nBlast Radius: "..math.Round((cal/25),2).."m\nVelocity: 800 m/s\n\nDescription: Cannons that fire a burst of shells before having to reload. Great for hit and runs. They can only use AP and HE cannon ammo and require a clip." )
		end
		if ctrl:GetSelectedItem():GetText() == "Howitzers" then
			DLabel:SetText( math.Round(cal,2).."mm Howitzer\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((9000/((240/cal)*(240/cal)))).." kg\nReload Time: "..math.Round(((cal/13 + cal/100)),2).." seconds crewed, "..math.Round(((cal/13 + cal/100))*1.5,2).." seconds uncrewed\n\nAP Stats\nPenetration: "..math.Round((cal*1.5),2).."mm\nDamage: "..math.Round(cal*0.25,2).."\nVelocity: 600 m/s\n\nHE Stats\nPenetration: "..math.Round((cal*1.5*0.3),2).."mm\nFrag Penetration: "..math.Round((cal/2.5)*1.3,2).."mm\nDamage: "..math.Round(cal*0.25*0.5,2).."\nSplash Damage: "..math.Round(cal*0.375,2).."\nBlast Radius: "..math.Round((cal/25)*1.3,2).."m\nVelocity: 600 m/s\n\nFL Stats\nPenetration: "..math.Round((cal*1.5*0.75),2).."mm\nDamage: "..math.Round(cal*0.025,2).."\nPellets: 10\nVelocity: 450 m/s\n\nDescription: Powerful guns with high damage per shot and lower weights than cannons. They generally have longer reloads than cannons and have less velocity, but they also have higher bonuses on HE damage and radius." )
		end
		if ctrl:GetSelectedItem():GetText() == "Mortars" then
			DLabel:SetText( math.Round(cal,2).."mm Mortar\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((4500/((280/cal)*(280/cal)))).." kg\nReload Time: "..math.Round(((cal/13 + cal/100)),2).." seconds crewed, "..math.Round(((cal/13 + cal/100)*1.5),2).." seconds uncrewed\n\nAP Stats\nPenetration: "..math.Round((cal*0.4),2).."mm\nDamage: "..math.Round(cal*0.25,2).."\nVelocity: 160 m/s\n\nHE Stats\nPenetration: "..math.Round((cal*0.4*0.3),2).."mm\nFrag Penetration: "..math.Round((cal/2.5)*1.15,2).."mm\nDamage: "..math.Round(cal*0.25*0.5,2).."\nSplash Damage: "..math.Round(cal*0.375,2).."\nBlast Radius: "..math.Round((cal/25)*1.15,2).."m\nVelocity: 160 m/s\n\nFL Stats\nPenetration: "..math.Round((cal*0.4*0.75),2).."mm\nDamage: "..math.Round(cal*0.025,2).."\nPellets: 10\nVelocity: 120 m/s\n\nDescription: Light guns with low damage, penetration, and velocity but low weight and high HE splash radius. They generally have longer reloads than howitzers, but higher listed HE damage, however due to the low penetration they deal less damage than a howitzer of equal caliber." )
		end
		if ctrl:GetSelectedItem():GetText() == "Autocannons" then
			DLabel:SetText( math.Round(cal,2).."mm Autocannon\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((2000/((50/cal)*(50/cal)))).." kg\nReload Time: 0.1 seconds\nClip Reload Time: 25 seconds\nClip Size: "..math.Round(600/cal).."\n\nAP Stats\nPenetration: "..math.Round((cal*2),2).."mm\nDamage: "..math.Round(cal*0.25,2).."\nVelocity: 800 m/s\n\nHE Stats\nPenetration: "..math.Round((cal*2*0.3),2).."mm\nFrag Penetration: "..math.Round((cal/2.5),2).."mm\nDamage: "..math.Round(cal*0.25*0.5,2).."\nSplash Damage: "..math.Round(cal*0.375,2).."\nBlast Radius: "..math.Round((cal/25),2).."m\nVelocity: 800 m/s\n\nDescription: Light guns with large clips and very rapid fire but long reload times. Great for hit and runs. They can only use AP and HE cannon ammo." )
		end
		if ctrl:GetSelectedItem():GetText() == "Machine Guns" then
			DLabel:SetText( math.Round(cal,2).."mm Machine Gun\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((60/((14.5/cal)*(14.5/cal)))).." kg\nReload Time: "..math.Round(((cal/13 + cal/100)*0.1),2).." seconds\n\nAP Stats\nPenetration: "..math.Round((cal*2),2).."mm\nDamage: "..math.Round(cal*0.025,2).."\nVelocity: 600 m/s\n\nDescription: Light and rapid fire anti infantry guns with very little penetration power and only AP rounds, its best to not waste them on armored targets." )
		end
		if ctrl:GetSelectedItem():GetText() == "Heavy Machine Guns" then
			DLabel:SetText( math.Round(cal,2).."mm Heavy Machine Gun\n\nArmor: "..math.Round((cal*5),2).."mm\nWeight: "..math.Round((600/((40/cal)*(40/cal)))).." kg\nReload Time: 0.1 seconds\nClip Reload Time: 20 seconds\nClip Size: "..math.Round(800/cal).."\n\nAP Stats\nPenetration: "..math.Round((cal*1.5),2).."mm\nDamage: "..math.Round(cal*0.25,2).."\nVelocity: 400 m/s\n\nHE Stats\nPenetration: "..math.Round((cal*1.5*0.3),2).."mm\nFrag Penetration: "..math.Round((cal/2.5),2).."mm\nDamage: "..math.Round(cal*0.25*0.5,2).."\nSplash Damage: "..math.Round(cal*0.375,2).."\nBlast Radius: "..math.Round((cal/25),2).."m\nVelocity: 600 m/s\n\nDescription: More light barreled autocannons than machine guns, these are somewhat useful against both armored targets and infantry. They can only use AP and HE HMG ammo." )
		end

		local MicroVol = 1097.1177978516	
		local SmallVol = 2778.4775390625	
		local StandardVol = 2880.7651367188	
		local LargeVol = 6702.1049804688	
		local HugeVol = 12977.875976563	
		local UltraVol = 56916.671875

		if AmmoBoxSelect:GetSelected() == "Cannon" then	
			local ShellVol = math.pi*(((cal*0.5)*0.0393701)^2)*(cal*0.0393701*13)
			local ShellMass = ShellVol*0.044
			if ctrl:GetSelectedItem():GetText() == "Micro AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Small AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Standard AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Large AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Huge AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Ultra AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmCFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
		end
		if AmmoBoxSelect:GetSelected() == "Howitzer" then	
			local ShellVol = math.pi*(((cal*0.5)*0.0393701)^2)*(cal*0.0393701*8)
			local ShellMass = ShellVol*0.044

			if ctrl:GetSelectedItem():GetText() == "Micro AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Small AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Standard AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Large AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Huge AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Ultra AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/4)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/4).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
		end
		if AmmoBoxSelect:GetSelected() == "Mortar" then	
			local ShellVol = math.pi*(((cal*0.5)*0.0393701)^2)*(cal*0.0393701*5.25)
			local ShellMass = ShellVol*0.044

			if ctrl:GetSelectedItem():GetText() == "Micro AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Small AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Standard AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Large AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Huge AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Ultra AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/2.75)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/2.75).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
		end
		if AmmoBoxSelect:GetSelected() == "Autocannon" then
			local ShellVol = math.pi*(((cal*0.5)*0.0393701)^2)*(cal*0.0393701*13)
			local ShellMass = ShellVol*0.044

			if ctrl:GetSelectedItem():GetText() == "Micro AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Small AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Standard AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Large AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Huge AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Ultra AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmACFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
		end
		if AmmoBoxSelect:GetSelected() == "Heavy Machine Gun" then
			local ShellVol = math.pi*(((cal*0.5)*0.0393701)^2)*(cal*0.0393701*13)
			local ShellMass = ShellVol*0.044

			if ctrl:GetSelectedItem():GetText() == "Micro AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Small AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Standard AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Large AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Huge AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Ultra AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmHMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
		end
		if AmmoBoxSelect:GetSelected() == "Machine Gun" then
			local ShellVol = math.pi*(((cal*0.5)*0.0393701)^2)*(cal*0.0393701*13)
			local ShellMass = ShellVol*0.044

			if ctrl:GetSelectedItem():GetText() == "Micro AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Micro FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((MicroVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Small AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Small FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((SmallVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Standard AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Standard FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((StandardVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Large AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Large FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((LargeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Huge AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Huge FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((HugeVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
			if ctrl:GetSelectedItem():GetText() == "Ultra AP Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGAP Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra HE Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGHE Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, also explodes.")
			end
			if ctrl:GetSelectedItem():GetText() == "Ultra FL Ammo Box" then
				DLabelAmmo:SetText(math.Round(cal,2).."mmMGFL Ammo\n\nHealth: 10\nWeight: "..math.Round(ShellMass*math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5)+10).."kg\nAmmo: "..math.floor((((UltraVol^(1/3))/(cal*0.0393701))^2)/6.5).."\n\nDescription: Makes guns shootier, cooks off when damaged.")
			end
			--
		end
	end

	function ctrl:DoClick( node )
		--FLAMETHROWERS
		if (node == DTTE_NodeList["Flamethrower"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Flamethrower")
			DLabel:SetText( "Flamethrower\n\nArmor: 50mm\nWeight: 50 kg\nHealth: 10\n\nDescription: Flamethrower capable of igniting infantry, softening armor, and stalling engines." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["FTFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Flamethrower Fuel")
			DLabel:SetText( "Flamethrower Fuel\n\nArmor: 25mm\nWeight: 500 kg\nHealth: 30\nAmmo: 15 seconds\n\nDescription: Flamethrower fuel tank, more armored than normal ammo boxes but more likely to be crit, use with caution." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		--CLIPs
		if (node == DTTE_NodeList["SALClip"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautoloadingmodule")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SALClip")
			DLabel:SetText( "Small Autoloader Clip\n\nArmor: 10mm\nWeight: 1000 kg\nHealth: 50\n\nDescription: Small sized clip required to load an autoloader." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["MALClip"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautoloadingmodule")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MALClip")
			DLabel:SetText( "Medium Autoloader Clip\n\nArmor: 10mm\nWeight: 2000 kg\nHealth: 75\n\nDescription: Medium sized clip required to load an autoloader. Increases clip size and decreases reload times by 20% per shell" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["LALClip"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautoloadingmodule")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LALClip")
			DLabel:SetText( "Large Autoloader Clip\n\nArmor: 10mm\nWeight: 3000 kg\nHealth: 100\n\nDescription: Large sized clip required to load an autoloader. Increases clip size and decreases reload times by 40% per shell" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["Cannons"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Cannon")
			DermaNumSlider:SetValue(25)
			DermaNumSlider:SetMin( 25 )
			DermaNumSlider:SetMax( 200 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Howitzers"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Howitzer")
			DermaNumSlider:SetValue(50)
			DermaNumSlider:SetMin( 50 )
			DermaNumSlider:SetMax( 240 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Mortars"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Mortar")
			DermaNumSlider:SetValue(40)
			DermaNumSlider:SetMin( 40 )
			DermaNumSlider:SetMax( 280 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["MGs"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temachinegun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MG")
			DermaNumSlider:SetValue(5)
			DermaNumSlider:SetMin( 5 )
			DermaNumSlider:SetMax( 25 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["HMGs"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HMG")
			DermaNumSlider:SetValue(20)
			DermaNumSlider:SetMin( 20 )
			DermaNumSlider:SetMax( 40 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Autocannons"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Autocannon")
			DermaNumSlider:SetValue(20)
			DermaNumSlider:SetMin( 20 )
			DermaNumSlider:SetMax( 60 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["ALGuns"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teautogun")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Autoloader")
			DermaNumSlider:SetValue(75)
			DermaNumSlider:SetMin( 75 )
			DermaNumSlider:SetMax( 200 )
			DLabel:SetText( "Pick a Caliber" )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(false)
		end

		----AMMO
		if (node == DTTE_NodeList["MicroAPBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroAPBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["MicroHEBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroHEBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["MicroFLBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroFLBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["SmallAPBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallAPBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["SmallHEBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallHEBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["SmallFLBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallFLBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["StandardAPBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardAPBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["StandardHEBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardHEBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["StandardFLBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardFLBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["LargeAPBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeAPBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["LargeHEBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeHEBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["LargeFLBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeFLBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["HugeAPBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeAPBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["HugeHEBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeHEBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["HugeFLBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeFLBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["UltraAPBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraAPBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["UltraHEBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraHEBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end
		if (node == DTTE_NodeList["UltraFLBox"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_teammo")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraFLBox")
			DLabelAmmo:SetText( "Pick an ammo type\n\nHealth: 10\nWeight: 10kg\nAmmo: ?\n\nDescription: Makes guns shootier, also explodes sometimes." )
			DLabel:SetVisible(false)
			DLabelAmmo:SetVisible(true)
			DermaNumSlider:SetVisible(true)
			AmmoBoxSelect:SetVisible(true)
		end

		if (node == DTTE_NodeList["MicroGearboxF"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroGearboxF")
			DLabel:SetText( "Micro Frontal Mount Gearbox\n\nHealth: 15\nArmor: 15mm\nWeight: 150 kg\nMax Power Rating: 150 hp\nTorque Multiplier: 0.85\n\nDescription: Tiny gearbox for tiny tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["SmallGearboxF"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallGearboxF")
			DLabel:SetText( "Small Frontal Mount Gearbox\n\nHealth: 35\nArmor: 35mm\nWeight: 350 kg\nMax Power Rating: 330 hp\nTorque Multiplier: 0.95\n\nDescription: Small gearbox for small tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["StandardGearboxF"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardGearboxF")
			DLabel:SetText( "Standard Frontal Mount Gearbox\n\nHealth: 60\nArmor: 60mm\nWeight: 625 kg\nMax Power Rating: 600 hp\nTorque Multiplier: 1\n\nDescription: Medium gearbox for medium tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["LargeGearboxF"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeGearboxF")
			DLabel:SetText( "Large Frontal Mount Gearbox\n\nHealth: 95\nArmor: 95mm\nWeight: 975 kg\nMax Power Rating: 930 hp\nTorque Multiplier: 1.15\n\nDescription: Large gearbox for large tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["HugeGearboxF"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeGearboxF")
			DLabel:SetText( "Huge Frontal Mount Gearbox\n\nHealth: 140\nArmor: 140mm\nWeight: 1400 kg\nMax Power Rating: 1350 hp\nTorque Multiplier: 1.25\n\nDescription: Huge gearbox for huge tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["UltraGearboxF"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraGearboxF")
			DLabel:SetText( "Ultra Frontal Mount Gearbox\n\nHealth: 250\nArmor: 250mm\nWeight: 2500 kg\nMax Power Rating: 2400 hp\nTorque Multiplier: 1.3\n\nDescription: ultra gearbox for landcruisers." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["MicroGearboxR"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroGearboxR")
			DLabel:SetText( "Micro Rear Mount Gearbox\n\nHealth: 15\nArmor: 15mm\nWeight: 150 kg\nMax Power Rating: 150 hp\nTorque Multiplier: 0.85\n\nDescription: Tiny gearbox for tiny tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["SmallGearboxR"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallGearboxR")
			DLabel:SetText( "Small Rear Mount Gearbox\n\nHealth: 35\nArmor: 35mm\nWeight: 350 kg\nMax Power Rating: 330 hp\nTorque Multiplier: 0.95\n\nDescription: Small gearbox for small tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["StandardGearboxR"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardGearboxR")
			DLabel:SetText( "Standard Rear Mount Gearbox\n\nHealth: 60\nArmor: 60mm\nWeight: 625 kg\nMax Power Rating: 600 hp\nTorque Multiplier: 1\n\nDescription: Medium gearbox for medium tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["LargeGearboxR"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeGearboxR")
			DLabel:SetText( "Large Rear Mount Gearbox\n\nHealth: 95\nArmor: 95mm\nWeight: 975 kg\nMax Power Rating: 930 hp\nTorque Multiplier: 1.15\n\nDescription: Large gearbox for large tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["HugeGearboxR"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeGearboxR")
			DLabel:SetText( "Huge Rear Mount Gearbox\n\nHealth: 140\nArmor: 140mm\nWeight: 1400 kg\nMax Power Rating: 1350 hp\nTorque Multiplier: 1.25\n\nDescription: Huge gearbox for huge tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["UltraGearboxR"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tegearbox")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraGearboxR")
			DLabel:SetText( "Ultra Rear Mount Gearbox\n\nHealth: 250\nArmor: 250mm\nWeight: 2500 kg\nMax Power Rating: 2400 hp\nTorque Multiplier: 1.3\n\nDescription: ultra gearbox for landcruisers." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["MicroEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroEngine")
			DLabel:SetText( "Micro Engine\n\nHealth: 15\nArmor: 15mm\nWeight: 150 kg\nSpeed: 25 crewed/15 uncrewed kph at 10 ton total mass\nPower: 75 hp\nFuel Required: 45 (lowers output with less fuel)\n\nDescription: Tiny engine for tiny tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["SmallEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallEngine")
			DLabel:SetText( "Small Engine\n\nHealth: 30\nArmor: 30mm\nWeight: 350 kg\nSpeed: 55 crewed/33 uncrewed kph at 10 ton total mass\nPower: 165 hp\nFuel Required: 90 (lowers output with less fuel)\n\nDescription: Small engine for light tanks and slow mediums." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["StandardEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardEngine")
			DLabel:SetText( "Standard Engine\n\nHealth: 45\nArmor: 45mm\nWeight: 625 kg\nSpeed: 100 crewed/60 uncrewed kph at 10 ton total mass\nPower: 300 hp\nFuel Required: 180 (lowers output with less fuel)\n\nDescription: Standard sized engine for medium tanks or slow heavies." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["LargeEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeEngine")
			DLabel:SetText( "Large Engine\n\nHealth: 60\nArmor: 60mm\nWeight: 975 kg\nSpeed: 155 crewed/93 uncrewed kph at 10 ton total mass\nPower: 465 hp\nFuel Required: 360 (lowers output with less fuel)\n\nDescription: Large engine for heavy tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["HugeEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeEngine")
			DLabel:SetText( "Huge Engine\n\nHealth: 75\nArmor: 75mm\nWeight: 1400 kg\nSpeed: 225 crewed/135 uncrewed kph at 10 ton total mass\nPower: 675 hp\nFuel Required: 720 (lowers output with less fuel)\n\nDescription: Huge engine for heavy tanks that want to move fast." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["UltraEngine"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_temotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraEngine")
			DLabel:SetText( "Ultra Engine\n\nHealth: 90\nArmor: 90mm\nWeight: 2500 kg\nSpeed: 400 crewed/240 uncrewed kph at 10 ton total mass\nPower: 1200 hp\nFuel Required: 1440 (lowers output with less fuel)\n\nDescription: Ultra engine for use in super heavy tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["MicroFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "MicroFuel")
			DLabel:SetText( "Micro Fuel Tank\n\nHealth: 10\nWeight: 65 kg\nFuel Capacity: 45\n\nDescription: Tiny fuel tank to run light tanks and tankettes." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["SmallFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "SmallFuel")
			DLabel:SetText( "Small Fuel Tank\n\nHealth: 20\nWeight: 120 kg\nFuel Capacity: 90\n\nDescription: Small fuel tank for light tanks and weak engined mediums." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["StandardFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "StandardFuel")
			DLabel:SetText( "Standard Fuel Tank\n\nHealth: 30\nWeight: 240 kg\nFuel Capacity: 180\n\nDescription: Standard medium tank fuel tank." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["LargeFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "LargeFuel")
			DLabel:SetText( "Large Fuel Tank\n\nHealth: 40\nWeight: 475 kg\nFuel Capacity: 360\n\nDescription: Large fuel tanks for heavies running mid sized engines." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["HugeFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "HugeFuel")
			DLabel:SetText( "Huge Fuel Tank\n\nHealth: 50\nWeight: 950 kg\nFuel Capacity: 720\n\nDescription: Huge fuel tank for heavies running large gas guzzlers." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["UltraFuel"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tefuel")
			RunConsoleCommand("daktankspawner_SpawnSettings", "UltraFuel")
			DLabel:SetText( "Ultra Fuel Tank\n\nHealth: 60\nWeight: 1900 kg\nFuel Capacity: 1440\n\nDescription: Massive fuel tank designed for super heavy tanks running the largest of engines." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		--GENERAL INFO
		if (node == DTTE_NodeList["Core"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_tankcore")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Core")
			DLabel:SetText( "Tank Core\n\nThis is the tank's automated health pooling system, just parent one onto your tank and it will combine the HP of all attached props and have them act as one. They will still each have their own unique armor values though, load weight into pieces that need it." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Crew"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_crew")
			RunConsoleCommand("daktankspawner_SpawnSettings", "Crew")
			DLabel:SetText( "Crew Member\n\nHealth: 5\nWeight: 75kg\n\nAllows an entity to function up to their full potential when linked to it. Can be linked to engines, normal guns, autocannons, and HMGs, but not autoloaders or machine guns." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["TControl"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_turretcontrol")
			RunConsoleCommand("daktankspawner_SpawnSettings", "TControl")
			DLabel:SetText( "Turret Controller\n\nThis entity acts as a turret E2 would, except its more optimized and required for regulation DakTank vehicles. It must have the arrow pointing forward. You can set the elevation, depression, and yaw limits by holding C and right clicking this chip and pressing edit properties. The Gun input goes directly to the heaviest gun in the turret, the gun itself, not the aimer. It can also be boosted by a turret motor." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["TMotor"]) then
			RunConsoleCommand("daktankspawner_SpawnEnt", "dak_turretmotor")
			RunConsoleCommand("daktankspawner_SpawnSettings", "TMotor")
			DLabel:SetText( "Turret Motor\n\nThis can be linked to a single turret controller, doubling the speed that the turret rotates. If destroyed turret speed will go back to normal." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["Utilities"]) then
			DLabel:SetText( "Utilities\n\nThis stuff is required to keep your vehicle running." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Mobility"]) then
			DLabel:SetText( "Mobility\n\nThe equipment used to get your vehicle moving." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Turret"]) then
			DLabel:SetText( "Turret\n\nThe equipment used to rotate your gun, for turreted and non turreted vehicles." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Fuel"]) then
			DLabel:SetText( "Fuel\n\nFuel tanks are required to run your engine, there are different sizes providing different bonuses." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Engine"]) then
			DLabel:SetText( "Engines\n\nLarge gas guzzlers to get your tank moving at speeds faster than a brisk walk." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Gearbox"]) then
			DLabel:SetText( "Gearboxes\n\nTransfers the power of your engines to the wheels, you'll need heavy gearboxes to handle high power engines." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["GearboxR"]) then
			DLabel:SetText( "Rear Mount Gearboxes\n\nGearbox for rear mounting." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["GearboxF"]) then
			DLabel:SetText( "Frontal Mount Gearboxes\n\nGearbox for frontal mounting." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Weapons"]) then
			DLabel:SetText( "Weapons\n\nEquipment used to make things deader, point at things you want removed." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["APAmmo"]) then
			DLabel:SetText( "Armor Piercing Rounds\n\nHigh penetration value single shot rounds good for getting through heavy armor and dealing solid damage." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["HEAmmo"]) then
			DLabel:SetText( "High Explosive Rounds\n\nLow penetration rounds that explode when hitting armor they can't pen, the explosion deals damage ignoring sloping." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["FLAmmo"]) then
			DLabel:SetText( "Flechette Rounds\n\nThese rounds fire a burst of projectiles towards the target, dealing the same base damage as AP rounds when totalled but with 75% of the penetration and velocity. They're good for seeking criticals against internal components against light armor." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Ammo"]) then
			DLabel:SetText( "Ammo\n\nKeeps guns shooty." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["ALClips"]) then
			DLabel:SetText( "Autoloader Clips\n\nThese are the clips that hold shells and supply them to an autoloader. They are explosive." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Autoloaders"]) then
			DLabel:SetText( "Autoloading Cannons\n\nThese are cannons modified to work with a clip, they will not fire without one." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end

		if (node == DTTE_NodeList["Guide"]) then
			DLabel:SetText( "DakTank Guide\n\nIn this folder you'll find a guide going over the game mechanics of DakTank, providing you some insight to get started on or improve your tanks." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help1"]) then
			DLabel:SetText( "DakTank Guide: The Basics\n\nIn DakTanks tanks consist of props making up armor, a fuel tank, an engine, a gearbox, at least one gun, ammo, a seat, a turret controller, and wiring all held together by the tank core entity. The tank core must be parented to a gate that has been parented (NOT WELDED) to the baseplate of the tank. Doing this will pool the tank's health and allow your guns to fire. Props set to 1kg will be considered detail props by the system and will be entirely ignored by the damage system (but will count towards total pooled HP). Please set any detail props to 1kg." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help2"]) then
			DLabel:SetText( "DakTank Guide: Armor\n\nEach prop has its own armor value based on the mm protection of steel plate. The amount of protection you get on the prop is determined by its weight and volume, or simply put its density. A large prop will take much more weight than a small prop, but you'll need large props on your tank if you are to fit your equipment, larger equipment tends to offer much better bonuses than smaller counterparts. Angling your armor will increase its effective thickness, making it harder for your armor to be penetrated, though HE damage ignores slope. Treads (or anything you set to make spherical using the tool for it) have their own designated armor value based on the actual thickness of the prop then run through a modifier. Treads can be penetrated but take no damage, this lets you use them as extra armor for your sides that will reduce the AP damage they take (slightly) but does nothing against HE." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help3"]) then
			DLabel:SetText( "DakTank Guide: Health\n\nHealth determines just how much damage your tank can take and is totalled up by the tank core, health is based mainly on the armor weight of the vehicle in tons multiplied by 10, so two tanks can be the same total weight but have different health, the more armored one being stronger. However, health is modified further by size multipliers, which also affect rate of fire of cannons, howitzers, mortars, autocannons, and HMGs, if your tank is large for its weight it gains bonus health to improve its durability due to the higher cost to armor it, if a tank is small for its weight it will lose health but have an easy time armoring itself. Ramming damage is calculated based on max health of a tank, it finds the total mass involved in the collision then each tank takes a percentage of the damage equal to the other tank's percentage of the weight, so a 5 ton tank ramming a 50 ton tank would take 11 times the damage that the 50 ton tank took. Each module has its own health value." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help4"]) then
			DLabel:SetText( "DakTank Guide: Munitions: AP\n\nThere are 3 types of ammo, Armor Piercing (AP), High Explosive (HE), and Flechette (FL). Each type of ammo has its own purposes in the combat of daktek, it is a good idea to take at least some amount of each if your gun allows it.\n\nAP fires a single shell at a target, if it doesn't have enough penetration to go through the armor then it will only deal a quarter its specified damage and be deflected away. If your shell does penetrate then it deals damage equal to its specified value multiplied by its own penetration value divided by the armor value of the prop it went through. The damage is capped to the amount of armor the prop has, making extremely heavy cannons firing AP not the best tool for dealing with light tanks, however you'll still shoot a hole right through them and likely rip out many modules at once and still deal respectable damage." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help5"]) then
			DLabel:SetText( "DakTank Guide: Munitions: HE\n\nHE fires an explosive shell at its target. It has penetration equal to 40% of an AP round's penetration and acts as an AP until it finds something it cannot penetrate, at which point it explodes, creating fragments equal to half the caliber. Each fragment acts as an AP shell with no damage cap and pen equal to the shell's pen before exploding, making HE extremely powerful against low armor and very effective if you get a penetrating shot and explode inside. HE is also very effective against low armor but highly angled armor. HE's fragmentation based nature can be very random with lower chances to hit targets further from the blast radius, you'll do much more damage on direct hits than splashes." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help6"]) then
			DLabel:SetText( "DakTank Guide: Munitions: FL\n\nFL fires a volley of 10 projectiles at once like a large shotgun. It has more spread than normal shells, has 75% less penetration and velocity than AP. Each projectile is equal to a tenth of the damage of an AP shell. Where FL shines is attacking armor that it can overpenetrate by large margins. As I stated previously, AP's damage is capped to the total armor of a prop, so if you have 100mm of penetration going through 10mm armor and your shell does 5 damage then you get a times 10 multiplier to your damage, but you are capped to 10 damage instead of your 50 point potential. With FL you split the shell into 10 different bits and would have 75mm of penetration going through 10mm of armor, so you would have a 7.5 times multiplier and each shell has a base of 0.5 damage, this leads to 3.75 damage per shell, giving a total of 37.5 damage, nearly 4 times the amount of what AP would have done. It also is more likely to tear apart modules if it penetrates, great for flankers." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help7"]) then
			DLabel:SetText( "DakTank Guide: Weaponry\n\nIn DakTanks there are cannons, howitzers, autoloaders, mortars, autocannons, heavy machine guns, and machine guns. Cannons are your basic weapon type and have access to any ammo type. Howitzers have a higher focus on HE, with larger splash radius, splash damage, and total damage than cannons of equal weight but longer reloads and often less penetration per ton. Autoloaders are cannons that can only fire AP and HE and require a clip module, they can fire devastating bursts in a short period of time but can have very long reloading periods. Mortars are low velocity HE focused guns. Autocannons are low caliber AP and HE firing guns that fire 10-30 shots at a rate of 10 shots per second but then have a 30 second reload, they're great for light weight hit and run. HMGs have larger clips than autocannons and half the reload times but also half the penetration, and half the velocity. Machine Guns are rapid fire anti infantry weapons that barely scratch light armor and only uses AP." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help8"]) then
			DLabel:SetText( "DakTank Guide: Flamethrowers\n\nFlamethrowers are a special weapon type that reduces the armor value of armor it hits over time to a minimum of half of its original value. Flamethrowers also can overheat the engines of a vehicle, reducing the power and eventually stalling a tank, making it easy to flank or easy to hit. They will also ignite infantry caught in the impact zone, dealing burn damage over the next 5 seconds. Flamethrowers require a lot of fuel to keep them firing, allowing only 15 seconds of fire per fuel tank. This means that dedicated flamethrower tanks will either need to be very large, have external tanks, or bring along a somewhat vulnerable fuel trailer or they'll be limited to short bursts of fire. Flamethrower fuel tanks have more armor and health than regular ammo crates but are also heavier and larger. However, their combination of armor and health makes them very vulnerable to crits from guns that do penetrate their armor." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help9"]) then
			DLabel:SetText( "DakTank Guide: Mobility\n\nVehicle speed is determined by your combined engine power, modified by how much fuel you have and total weight of the vehicle. Given the same engine and fuel tank a 30 ton tank will move twice as fast as a 60 tonner and will turn faster. You can use as many engines or fuel tanks as you want, each engine requires a certain amount of fuel and each fuel tank has a certain amount of fuel. Having less fuel than you require reduces your power output. Each gearbox can only handle a certain amount of power and each tank can only support one gearbox, providing more power to the gearbox than it can handle will result in waste power. Damage will reduce the stats of each of the mobility entities, potentially immobilizing you. You could create large but fast and lightly armored vehicles or small but slow and heavily armored vehicles. The faster vehicle would be good against heavier tanks that it could flank while the heavy vehicle would be good for dominating tanks that can't pen it." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help10"]) then
			DLabel:SetText( "DakTank Guide: Critical Hits\n\nCertain components such as fuel, ammo, and autoloader clips can suffer from catastrophic failure in cases in which they are reduced to less than half health but not outright destroyed. Upon exploding fuel and clips will deal 250 points of damage between the entities nearby and ammo will deal between 0 and 500 damage depending on how full the crate is. Ammo boxes can have their ammo ejected via its wire input to avoid such failures in dire circumstances, though it can take a few seconds to empty out fully. Crit explosions function just like HE explosions, so damage may be much higher than stated, this gives some reason to place explosive items in the front of the tank so that the frontal armor absorbs some of the damage. AP and FL ammo cooks off instead of exploding outright, causing multiple internal penetrations to occur in a short time span." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
		if (node == DTTE_NodeList["Help11"]) then
			DLabel:SetText( "DakTank Guide: Crew\n\nCrew greatly improve the performance of a tank they are working on, each crew member is relatively light but takes up a sizeable area. Crew can be tasked with driving or loading while a turret motor can assist in improving turret rotation speeds. Only one crew member can be driver at once but you can have as many loaders as you want, each gives diminishing returns though, the first loader reduces reload times by a third, each loader after this reduces reload times by half as much as the last. Machineguns and Autoloaders cannot be crewed, as they are fully automated. Crew members are lightly armored and have low health, making them easy to lose in the case of an armor penetration, having many crew members taken out at once can be cripling, be sure to keep them safe." )
			DLabel:SetVisible(true)
			DLabelAmmo:SetVisible(false)
			DermaNumSlider:SetVisible(false)
			AmmoBoxSelect:SetVisible(false)
		end
	end
end

function TOOL:Think()
end
