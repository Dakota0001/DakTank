include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "FN P90"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Personal self-defense weapon with 7mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"

SWEP.Primary.ClipSize	 = 50
SWEP.Primary.DefaultClip = 500
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "Pistol"
SWEP.Primary.Cooldown	 = 0.075
SWEP.Primary.Caliber	 = 5.7
SWEP.Primary.Penetration = 7
SWEP.Primary.MuzzleVel	 = 30000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.025
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 50

SWEP.FireSound = "weapons/p90/p90-1.wav"

SWEP.HoldType = "smg"