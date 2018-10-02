include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "AT Rifle"
	SWEP.Slot = 4
end

SWEP.Purpose	  = "Antitank rifle with 60mm of penetration."
SWEP.Instructions = "Can only be fired while standing still.\nRight click to zoom in.\nRecoil bonus while crouching."
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_snip_awp.mdl"
SWEP.WorldModel = "models/weapons/w_snip_awp.mdl"

SWEP.Primary.ClipSize	 = 5
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "XBowBolt"
SWEP.Primary.Cooldown	 = 1.75
SWEP.Primary.Caliber	 = 14.5
SWEP.Primary.Penetration = 50
SWEP.Primary.MuzzleVel	 = 40000
SWEP.Primary.RoundMass	 = 10
SWEP.Primary.Damage		 = 2
SWEP.Primary.Spread		 = 0.05
SWEP.Primary.AimFOV		 = 35

SWEP.FireSound = "daktanks/c25.wav"

SWEP.HoldType = "ar2"