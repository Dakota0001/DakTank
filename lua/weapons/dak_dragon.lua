AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )
SWEP.Base 			= "dak_gun_base"
if SERVER then

	--AddCSLuaFile ("shared.lua")
	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 
elseif CLIENT then
 
	SWEP.PrintName = "M47 Dragon"
 
	SWEP.Slot = 5
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end
 
SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "staring contest consolidation prize, Caliber: 140mm, Velocity: 200m/s, Damage: 17 vs armor, RPM: 30, Pen: 300mm"

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

 	--gun info
 	self.ShotCount = 1
	self.Spread = 0.05 --0.1 for pistols, 0.075 for smgs, 0.05 for rifles
	self.PrimaryCooldown = 1
	self.FireSound = "daktanks/extra/76mmUSA2.mp3"
	self.IsPistol = false
	self.heavyweapon = true

 	--shell info
 	self.DakTrail = "daktemissiletracer"
	self.DakCaliber = 140
	self.DakShellType = "ATGM"
	self.DakPenLossPerMeter = 0.0
	self.DakExplosive = true
	self.DakVelocity = 3960
	self.DakIsGuided = true
	self.ShellLengthMult = self.DakVelocity/29527.6
	self.Zoom = 55

	self.IsMissile = true
	self.PenOverride = 300
end
 
function SWEP:Think()
	if self.LastTime+0.1 < CurTime() then
		if self.SpreadStacks>0 then
			self.SpreadStacks = self.SpreadStacks - (0.1*self.SpreadStacks)
		end
		self.LastTime = CurTime()
	end
	if self.Owner.PerkType == 1 and self.AmmoGiven == nil then
		self.AmmoGiven = 1
		self.Owner:GiveAmmo( self.Primary.DefaultClip, self:GetPrimaryAmmoType(), true )
	end
end

