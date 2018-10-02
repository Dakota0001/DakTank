include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "H&K UMP"
	SWEP.Slot = 2
end

SWEP.Purpose	  = "Sub machinegun with 10mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_smg_ump45.mdl"
SWEP.WorldModel = "models/weapons/w_smg_ump45.mdl"

SWEP.Primary.ClipSize	 = 25
SWEP.Primary.DefaultClip = 250
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "SMG1"
SWEP.Primary.Cooldown	 = 0.1
SWEP.Primary.Caliber	 = 11.43
SWEP.Primary.Penetration = 10
SWEP.Primary.MuzzleVel	 = 14000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.035
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV		 = 50

SWEP.FireSound = "weapons/ump45/ump45-1.wav"

SWEP.HoldType = "smg"