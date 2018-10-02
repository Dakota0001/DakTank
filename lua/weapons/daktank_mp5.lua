include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "H&K MP5A3"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Sub machinegun with 8mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel = "models/weapons/w_smg_mp5.mdl"

SWEP.Primary.ClipSize	 = 30
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "Pistol"
SWEP.Primary.Cooldown	 = 0.075
SWEP.Primary.Caliber	 = 9
SWEP.Primary.Penetration = 8
SWEP.Primary.MuzzleVel	 = 21000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.025
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 50

SWEP.FireSound = "weapons/mp5navy/mp5-1.wav"

SWEP.HoldType = "smg"