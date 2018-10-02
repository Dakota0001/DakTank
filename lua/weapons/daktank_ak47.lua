include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "AK-47"
	SWEP.Slot = 3
end

SWEP.Purpose	  = "Assault rifle with 20mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel  = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Primary.ClipSize	 = 30
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "AR2"
SWEP.Primary.Cooldown	 = 0.1
SWEP.Primary.Caliber	 = 7.62
SWEP.Primary.Penetration = 20
SWEP.Primary.MuzzleVel	 = 37500
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.1
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 50

SWEP.FireSound = "weapons/ak47/ak47-1.wav"

SWEP.HoldType = "ar2"