include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "SIG P228"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Handgun with 8mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel = "models/weapons/w_pist_p228.mdl"

SWEP.Primary.ClipSize	 = 13
SWEP.Primary.DefaultClip = 130
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "Pistol"
SWEP.Primary.Cooldown	 = 0.05
SWEP.Primary.Caliber	 = 9
SWEP.Primary.Penetration = 8
SWEP.Primary.MuzzleVel	 = 20000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.025
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "weapons/p228/p228-1.wav"

SWEP.HoldType = "pistol"