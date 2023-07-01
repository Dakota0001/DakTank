AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )

if SERVER then

	--AddCSLuaFile ("shared.lua")


	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false

elseif CLIENT then

	SWEP.PrintName = "Base Gun"

	SWEP.Slot = 4
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end

SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "[Sample Text], 14.55mm pen"

SWEP.Category = "DakTank"

SWEP.Spawnable = false
SWEP.AdminOnly = true

SWEP.ViewModel  = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Primary.ClipSize		= 30
SWEP.Primary.DefaultClip	= 90
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
	self.PrimaryMessage = 0
	self.Fired = 0

	--gun info
	self.ShotCount = 1
	self.Spread = 0.05 --0.1 for pistols, 0.075 for smgs, 0.05 for rifles
	self.PrimaryCooldown = 0.1
	self.FireSound = "weapons/ak47/ak47-1.wav"
	self.IsPistol = false
	self.IsRifle = true
	self.heavyweapon = false

	--shell info
	self.DakTrail = "dakteballistictracer"
	self.DakCaliber = 7.62
	self.DakShellType = "AP"
	self.DakPenLossPerMeter = 0.0005
	self.DakExplosive = false
	self.DakVelocity = 28200
	self.ShellLengthMult = self.DakVelocity / 29527.6
	self.Zoom = 55
end

function SWEP:Reload()
	local owner = self:GetOwner()
	if not ( self:Clip1() < self.Primary.ClipSize and owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then return end

	self:DefaultReload(ACT_VM_RELOAD)
	if owner:GetFOV() == self.Zoom then
		owner:SetFOV( 0, 0.1 )
	end
	self.SpreadStacks = 0
end

function SWEP:Think()
	if self.LastTime + 0.1 >= CurTime() then return end
	local owner = self:GetOwner()

	self.DakOwner = owner
	if self.SpreadStacks > 0 then
		self.SpreadStacks = self.SpreadStacks - ( 0.1 * self.SpreadStacks )
	end
	self.LastTime = CurTime()

	if owner.PerkType == 1 and self.AmmoGiven == nil then
		self.AmmoGiven = 1
		owner:GiveAmmo( self.Primary.DefaultClip, self:GetPrimaryAmmoType(), true )
	end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.PrimaryLastFire + self.PrimaryCooldown < CurTime() then
		local owner = self:GetOwner()

		if ( self.heavyweapon == true and owner:GetVelocity() == Vector( 0, 0, 0 ) and owner:OnGround() ) or self.heavyweapon == false or self.heavyweapon == nil then
			if self:Clip1() > 0 then
				if SERVER then
					if owner:IsPlayer() then
						owner:LagCompensation( true )
					end

					for i = 1, self.ShotCount do
						local shell = {}
						shell.Pos = owner:GetShootPos()
						local initvel = owner:GetVelocity()
						shell.DakVelocity = ( ( self.DakVelocity * math.Rand( 0.95, 1.05 ) ) * ( owner:GetAimVector():Angle() + Angle( math.Rand( -self.Spread, self.Spread ), math.Rand( -self.Spread, self.Spread ), math.Rand( -self.Spread, self.Spread ) ) ):Forward() ) + initvel
						if owner:Crouching() then
							shell.DakVelocity = ( ( self.DakVelocity * math.Rand( 0.95, 1.05 ) ) * ( owner:GetAimVector():Angle() + 0.5 * Angle( math.Rand( -self.Spread, self.Spread ), math.Rand( -self.Spread, self.Spread ), math.Rand( -self.Spread, self.Spread ) ) ):Forward() ) + initvel
						end

						shell.DakTrail = self.DakTrail
						shell.DakCaliber = self.DakCaliber
						shell.DakShellType = self.DakShellType
						shell.DakPenLossPerMeter = self.DakPenLossPerMeter
						shell.DakExplosive = self.DakExplosive

						shell.DakBaseVelocity = self.DakVelocity

						shell.DakMass = ( math.pi * ( ( self.DakCaliber * 0.001 * 0.5 ) ^ 2 ) * ( self.DakCaliber * 0.001 * 5 ) ) * 7700
						shell.DakDamage = shell.DakMass * ( ( self.DakVelocity * 0.0254 ) * ( self.DakVelocity * 0.0254 ) ) * 0.01 * 0.002
						shell.IsMissile = self.IsMissile
						shell.IsTandem = self.IsTandem

						shell.DakIsPellet = false
						shell.DakSplashDamage = self.DakCaliber * 5
						if self.IsMissile then
							shell.DakPenetration = self.PenOverride
							shell.DakBasePenetration = self.PenOverride
						else
							shell.DakPenetration = ( self.DakCaliber * 2 ) * self.ShellLengthMult
							shell.DakBasePenetration = ( self.DakCaliber * 2 ) * self.ShellLengthMult
						end

						if self.DakShellType == "HEAT" or self.DakShellType == "HEATFS" or self.DakShellType == "ATGM" then
							shell.DakBlastRadius = ( ( ( self.DakCaliber / 155 ) * 50 ) * 39 ) * 0.5
						elseif self.DakShellType == "APHE" then
							shell.DakBlastRadius = ( ( ( self.DakCaliber / 155 ) * 50 ) * 39 ) * 0.25
						else
							shell.DakBlastRadius = ( ( ( self.DakCaliber / 155 ) * 50 ) * 39 )
						end

						shell.DakPenSounds = { "daktanks/daksmallpen1.mp3", "daktanks/daksmallpen2.mp3", "daktanks/daksmallpen3.mp3", "daktanks/daksmallpen4.mp3" }

						shell.DakGun = self
						shell.DakGun.DakOwner = owner
						shell.Filter = { owner, self }
						shell.LifeTime = 0
						shell.Gravity = 0
						shell.DakFragPen = self.DakCaliber / 2.5

						shell.IsGuided = self.DakIsGuided

						shell.Indicator = owner
						shell.IndicatorStart = owner:GetShootPos()
						shell.IndicatorEnd = owner:GetShootPos() + owner:GetAimVector() * 1000000

						DakTankShellList[#DakTankShellList + 1] = shell
					end
				end
				if owner:IsPlayer() then
					owner:LagCompensation( false )
				end
				local ActualSpeed = owner:GetVelocity():Length()
				local MaxSpeed = owner:GetRunSpeed()
				local IsMoving = math.max( 0.5, ActualSpeed / MaxSpeed )
				local IsCrouch = owner:Crouching() and 0.5 or 1
				local ShotForce = ( self.DakVelocity * 0.0254 ) * ( self.DakVelocity * 0.0254 ) * ( math.pi * ( ( self.DakCaliber * 0.001 * 0.5 ) ^ 2 ) * ( self.DakCaliber * 0.001 * 5 ) ) * 7700
				if self.DakShellType == "HEAT" or self.DakShellType == "APHE" or self.DakShellType == "HEATFS" or self.DakShellType == "ATGM" then
					ShotForce = ShotForce * 0.05
				end
				local BaseRecoil = Angle( -math.Rand( 0.0004, 0.0006 ), math.Rand( 0.0002, -0.0002 ), 0 )
				local FinalRecoil = BaseRecoil * self.ShotCount * ShotForce * IsMoving * IsCrouch * self.SpreadStacks --have spread stacks so first few shots are sorta accurate
				if self.IsPistol == true then
					FinalRecoil = FinalRecoil * 3
				end
				if self.IsRifle == true then
					FinalRecoil = FinalRecoil * 0.5
				end
				if SERVER then self:SetNWInt( "OwnerPerk", owner.PerkType ) end
				if self:GetNWInt( "OwnerPerk" ) == 5 then FinalRecoil = FinalRecoil * 0.25 end
				if self.heavyweapon == true then FinalRecoil = FinalRecoil * 0.25 end
				if self.SpreadStacks < 5 then
					self.SpreadStacks = self.SpreadStacks + ( ShotForce / 10000 )
				end
				if CLIENT or game.SinglePlayer() then
					owner:SetEyeAngles( owner:EyeAngles() + FinalRecoil )
					owner:ViewPunch( FinalRecoil / 4 )
				end
				if self.Primary.ClipSize > 5 and self:Clip1() <= 5 then
					self:EmitSound( self.FireSound, 140, 95 * math.Rand( 0.99, 1.01 ), 1, 2)
				else
					self:EmitSound( self.FireSound, 140, 95 * math.Rand( 0.99, 1.01 ), 1, 2)
				end

				--[[
				if SERVER then
					net.Start( "daktankshotfired" )
					net.WriteVector( self:GetPos() )
					net.WriteFloat( self.DakCaliber )
					net.WriteString( self.FireSound )
					net.Broadcast()
				end
				]]

				self.PrimaryLastFire = CurTime()
				self:TakePrimaryAmmo( 1 )
				self.Fired = 1
			else
				if SERVER then
					self:Reload()
				end
			end
		end
		if self.heavyweapon == true and not ( owner:GetVelocity() == Vector( 0, 0, 0 ) and owner:OnGround() ) then
			if self.PrimaryMessage == nil then self.PrimaryMessage = 0 end
			if self.PrimaryMessage + 1 < CurTime() then
				if SERVER then
					owner:ChatPrint( "You must stand still and be on the ground to fire this weapon!" )
				end
				self.PrimaryMessage = CurTime()
			end
		end
	end

	if self.Fired == 1 then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Fired = 0
	end
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()

	if owner:GetFOV() == self.Zoom then
		owner:SetFOV( 0, 0.1 )
	else
		owner:SetFOV( self.Zoom, 0.1 )
	end
end

function SWEP:AdjustMouseSensitivity()
	local owner = self:GetOwner()

	if math.Round( owner:GetFOV(), 0 ) == self.Zoom then
		return self.Zoom / 100
	else
		return 1
	end
end

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )
end


