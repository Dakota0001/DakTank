AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )
SWEP.Base 			= "dak_gun_base"
if SERVER then
 
	--AddCSLuaFile ("shared.lua")
 

	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 
elseif CLIENT then
 
	SWEP.PrintName = "IMI Galil"
 
	SWEP.Slot = 4
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end
 
SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "bottle opener standard feature, Caliber: 5.56mm, Velocity: 950m/s, Damage: 46.9, RPM: 750, Pen: 14.09mm"

SWEP.Category = "DakTank"
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"

SWEP.Primary.ClipSize		= 35
SWEP.Primary.DefaultClip	= 105
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AR2"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
 
SWEP.UseHands = true

SWEP.HoldType = "ar2"
SWEP.LastTime = CurTime()
SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
	self.SpreadStacks = 0
	self:SetHoldType( self.HoldType )
	if self.Owner:IsNPC() then
		if SERVER then
		self.Owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
		self.Owner:CapabilitiesAdd( CAP_MOVE_GROUND )
		self.Owner:CapabilitiesAdd( CAP_MOVE_JUMP )
		self.Owner:CapabilitiesAdd( CAP_MOVE_CLIMB )
		self.Owner:CapabilitiesAdd( CAP_MOVE_SWIM )
		self.Owner:CapabilitiesAdd( CAP_MOVE_CRAWL )
		self.Owner:CapabilitiesAdd( CAP_MOVE_SHOOT )
		self.Owner:CapabilitiesAdd( CAP_USE )
		self.Owner:CapabilitiesAdd( CAP_USE_SHOT_REGULATOR )
		self.Owner:CapabilitiesAdd( CAP_SQUAD )
		self.Owner:CapabilitiesAdd( CAP_DUCK )
		self.Owner:CapabilitiesAdd( CAP_AIM_GUN )
		self.Owner:CapabilitiesAdd( CAP_NO_HIT_SQUADMATES )
		end
	end
	self.PrimaryLastFire = 0
	self.Fired = 0

	self.ShellList = {}
 	self.RemoveList = {}

 	--gun info
 	self.ShotCount = 1
	self.Spread = 0.05 --0.1 for pistols, 0.075 for smgs, 0.05 for rifles
	self.PrimaryCooldown = 0.08
	self.FireSound = "weapons/galil/galil-1.wav"
	self.IsPistol = false
	self.IsRifle = true

 	--shell info
 	self.DakTrail = "dakteballistictracer"
	self.DakCaliber = 5.56
	self.DakShellType = "AP"
	self.DakPenLossPerMeter = 0.0005
	self.DakExplosive = false
	self.DakVelocity = 37401.6
	self.ShellLengthMult = self.DakVelocity/29527.6
	self.Zoom = 55
end