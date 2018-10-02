include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "H&K USP"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Handgun with 10mm of penetration.\nNot a soldier's gun."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel  = "models/weapons/cstrike/c_pist_usp.mdl"
SWEP.WorldModel = "models/weapons/w_pist_usp.mdl"

SWEP.Primary.ClipSize	 = 12
SWEP.Primary.DefaultClip = 120
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "SMG1"
SWEP.Primary.Cooldown	 = 0.1
SWEP.Primary.Caliber	 = 11.43
SWEP.Primary.Penetration = 10
SWEP.Primary.MuzzleVel	 = 14000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.035
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "weapons/usp/usp_unsil-1.wav"

SWEP.HoldType = "pistol"