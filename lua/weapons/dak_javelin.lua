AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )
SWEP.Base 			= "dak_gun_base"
if SERVER then

	--AddCSLuaFile ("shared.lua")


	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false

elseif CLIENT then

	SWEP.PrintName = "FGM-148 Javelin"

	SWEP.Slot = 5
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end

SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "No top attack today, Caliber: 127mm, Velocity: 200m/s, Damage: 13 vs armor, RPM: 30, Pen: 750mm, Tandem"

SWEP.Category = "DakTank"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel  = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 2
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "RPG_Round"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true

SWEP.HoldType = "rpg"
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

	--gun info
	self.ShotCount = 1
	self.Spread = 0.05 --0.1 for pistols, 0.075 for smgs, 0.05 for rifles
	self.PrimaryCooldown = 1
	self.FireSound = "daktanks/extra/76mmUSA2.mp3"
	self.IsPistol = false
	self.heavyweapon = true

	--shell info
	self.DakTrail = "daktemissiletracer"
	self.DakCaliber = 127
	self.DakShellType = "ATGM"
	self.DakPenLossPerMeter = 0.0
	self.DakExplosive = true
	self.DakVelocity = 3960
	self.DakIsGuided = true
	self.ShellLengthMult = self.DakVelocity / 29527.6
	self.Zoom = 55

	self.IsMissile = true
	self.IsTandem = true
	self.PenOverride = 750
end

function SWEP:Think()
	local owner = self:GetOwner()

	if self.LastTime + 0.1 < CurTime() then
		if self.SpreadStacks > 0 then
			self.SpreadStacks = self.SpreadStacks - ( 0.1 * self.SpreadStacks )
		end
		self.LastTime = CurTime()
	end
	if owner.PerkType == 1 and self.AmmoGiven == nil then
		self.AmmoGiven = 1
		owner:GiveAmmo( self.Primary.DefaultClip, self:GetPrimaryAmmoType(), true )
	end
end

