include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "Semi-Auto Shotgun"
	SWEP.Slot = 3
end

SWEP.Purpose	  = "Semi automatic shotgun with 2mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"

SWEP.Primary.ClipSize	 = 5
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "Buckshot"
SWEP.Primary.ShotAmount	 = 10
SWEP.Primary.Cooldown	 = 0.45
SWEP.Primary.Caliber	 = 1
SWEP.Primary.Penetration = 2
SWEP.Primary.MuzzleVel	 = 25000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.025
SWEP.Primary.Spread		 = 1
SWEP.Primary.AimFOV 	 = 50

SWEP.FireSound = "weapons/xm1014/xm1014-1.wav"

SWEP.HoldType = "ar2"