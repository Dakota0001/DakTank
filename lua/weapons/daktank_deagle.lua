include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "IMI Desert Eagle"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Handgun with 13mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"

SWEP.Primary.ClipSize	 = 7
SWEP.Primary.DefaultClip = 70
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "357"
SWEP.Primary.Cooldown	 = 0.75
SWEP.Primary.Caliber	 = 12.7
SWEP.Primary.Penetration = 13
SWEP.Primary.MuzzleVel	 = 23500
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.075
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "weapons/deagle/deagle-1.wav"

SWEP.HoldType = "pistol"