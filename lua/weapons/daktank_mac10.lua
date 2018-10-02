include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "MAC-10"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Machine pistol with 10mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mac10.mdl"

SWEP.Primary.ClipSize	 = 30
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "SMG1"
SWEP.Primary.Cooldown	 = 0.05
SWEP.Primary.Caliber	 = 11.43
SWEP.Primary.Penetration = 10
SWEP.Primary.MuzzleVel	 = 14500
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.03
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "weapons/mac10/mac10-1.wav"

SWEP.HoldType = "pistol"