include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "FN Five-seveN"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Handgun with 7mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Primary.ClipSize	 = 20
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "Pistol"
SWEP.Primary.Cooldown	 = 0.05
SWEP.Primary.Caliber	 = 5.7
SWEP.Primary.Penetration = 7
SWEP.Primary.MuzzleVel	 = 30000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.025
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "weapons/fiveseven/fiveseven-1.wav"

SWEP.HoldType = "pistol"