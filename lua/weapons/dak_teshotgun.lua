AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )
SWEP.Base 			= "dak_gun_base"
if SERVER then

	--AddCSLuaFile ("shared.lua")


	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false

elseif CLIENT then

	SWEP.PrintName = "Semiauto Shotgun"

	SWEP.Slot = 4
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end

SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "totally not a famas, Caliber: 5.56mm, Velocity: 635m/s, Damage: 210, RPM: 300, Pen: 5.56mm"

SWEP.Category = "DakTank"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel  = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "Buckshot"

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
	local owner = self:GetOwner()

	if SERVER and owner:IsNPC() then
		owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
		owner:CapabilitiesAdd( CAP_MOVE_GROUND )
		owner:CapabilitiesAdd( CAP_MOVE_JUMP )
		owner:CapabilitiesAdd( CAP_MOVE_CLIMB )
		owner:CapabilitiesAdd( CAP_MOVE_SWIM )
		owner:CapabilitiesAdd( CAP_MOVE_CRAWL )
		owner:CapabilitiesAdd( CAP_MOVE_SHOOT )
		owner:CapabilitiesAdd( CAP_USE )
		owner:CapabilitiesAdd( CAP_USE_SHOT_REGULATOR )
		owner:CapabilitiesAdd( CAP_SQUAD )
		owner:CapabilitiesAdd( CAP_DUCK )
		owner:CapabilitiesAdd( CAP_AIM_GUN )
		owner:CapabilitiesAdd( CAP_NO_HIT_SQUADMATES )
	end
	self.PrimaryLastFire = 0
	self.Fired = 0

	self.ShellList = {}
	self.RemoveList = {}

	--gun info
	self.ShotCount = 10
	self.Spread = 1 --0.1 for pistols, 0.075 for smgs, 0.05 for rifles
	self.PrimaryCooldown = 0.2
	self.FireSound = "weapons/xm1014/xm1014-1.wav"
	self.IsPistol = false

	--shell info
	self.DakTrail = "dakteballistictracer"
	self.DakCaliber = 5.56
	self.DakShellType = "AP"
	self.DakPenLossPerMeter = 0.0005
	self.DakExplosive = false
	self.DakVelocity = 25000
	self.ShellLengthMult = 0.5
	self.Zoom = 55
end