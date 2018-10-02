include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "Steyr TMP"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Machine pistol with 8mm of penetration."
SWEP.Instructions = "Right click to zoom in.\nRecoil bonus while crouching and standing still."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"

SWEP.Primary.ClipSize	 = 30
SWEP.Primary.DefaultClip = 300
SWEP.Primary.Automatic	 = true
SWEP.Primary.Ammo		 = "Pistol"
SWEP.Primary.Cooldown	 = 0.075
SWEP.Primary.Caliber	 = 9
SWEP.Primary.Penetration = 8
SWEP.Primary.MuzzleVel	 = 21000
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.03
SWEP.Primary.Spread		 = 0.1
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "weapons/tmp/tmp-1.wav"

SWEP.HoldType = "smg"