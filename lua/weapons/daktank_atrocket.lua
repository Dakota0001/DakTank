include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "AT-4"
	SWEP.Slot = 4
end

SWEP.Purpose 	  = "Antitank rocket launcher with 420mm of penetration and a decent HE charge."
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
SWEP.Primary.Caliber	 = 84
SWEP.Primary.AmmoType	 = "HEAT"
SWEP.Primary.Penetration = 420
SWEP.Primary.MuzzleVel	 = 12000
SWEP.Primary.LossXMeter	 = 0.0
SWEP.Primary.RoundMass	 = 5
SWEP.Primary.Damage		 = 10
SWEP.Primary.IsExplosive = true
SWEP.Primary.SplashDmg	 = 30
SWEP.Primary.BlastRadius = 200
SWEP.Primary.FragPen	 = 25
SWEP.Primary.Spread		 = 0.5
SWEP.Primary.AimFOV		 = 35
SWEP.Primary.Trail		 = "daktemissiletracer"

SWEP.FireMoving	 = false
SWEP.FireSound	 = "daktanks/h50.wav"
SWEP.ReloadSound = {"weapons/ar2/ar2_empty.wav",
					"weapons/slam/mine_mode.wav"}

SWEP.HoldType = "rpg"