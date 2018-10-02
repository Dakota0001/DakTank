include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "H&K G3SG/1"
	SWEP.Slot = 3
end

SWEP.Purpose	  = "Semiautomatic assault rifle with 20mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_snip_g3sg1.mdl"
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl"

SWEP.Primary.ClipSize	 = 20
SWEP.Primary.DefaultClip = 200
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "AR2"
SWEP.Primary.Cooldown	 = 0.12
SWEP.Primary.Caliber	 = 7.62
SWEP.Primary.Penetration = 20
SWEP.Primary.MuzzleVel	 = 40000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.1
SWEP.Primary.Spread		 = 0.05
SWEP.Primary.AimFOV		 = 30

SWEP.FireSound = "weapons/g3sg1/g3sg1-1.wav"

SWEP.HoldType = "ar2"