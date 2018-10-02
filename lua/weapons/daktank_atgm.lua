include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "M47 Dragon"
	SWEP.Slot = 4
end

SWEP.Purpose 	  = "Antitank guided missile launcher with 330mm of penetration and a decent HE charge."
SWEP.Instructions = "Can only be fired while standing still.\nRight click to zoom in.\nRecoil bonus while crouching."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/v_RPG.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize	 = 1
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "RPG_Round"
SWEP.Primary.Cooldown	 = 6
SWEP.Primary.Caliber	 = 140
SWEP.Primary.AmmoType	 = "ATGM"
SWEP.Primary.Penetration = 300
SWEP.Primary.MuzzleVel	 = 8000
SWEP.Primary.LossXMeter	 = 0.0
SWEP.Primary.RoundMass	 = 11
SWEP.Primary.Damage		 = 10
SWEP.Primary.IsExplosive = true
SWEP.Primary.SplashDmg	 = 30
SWEP.Primary.BlastRadius = 150
SWEP.Primary.FragPen	 = 20
SWEP.Primary.AimFOV		 = 35
SWEP.Primary.Trail		 = "daktemissiletracer"
SWEP.Primary.IsGuided	 = true

SWEP.FireMoving	 = false
SWEP.FireSound	 = "daktanks/h50.wav"
SWEP.ReloadSound = {"weapons/ar2/ar2_empty.wav",
					"weapons/slam/mine_mode.wav"}

SWEP.HoldType = "rpg"