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
	self.PrimaryCooldown = 0.1
	self.FireSound = "weapons/ak47/ak47-1.wav"
	self.IsPistol = false
	self.IsRifle = true

 	--shell info
 	self.DakTrail = "dakteballistictracer"
	self.DakCaliber = 7.62
	self.DakShellType = "AP"
	self.DakPenLossPerMeter = 0.0005
	self.DakExplosive = false
	self.DakVelocity = 28200
	self.ShellLengthMult = self.DakVelocity/29527.6
	self.Zoom = 55
end

function SWEP:Reload()
	if  ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		self.Weapon:DefaultReload(ACT_VM_RELOAD)	
		if self.Owner:GetFOV()==self.Zoom then
			self.Owner:SetFOV( 0, 0.1 )
		end
		self.SpreadStacks = 0
	end
end
 
function SWEP:Think()
	if self.LastTime+0.1 < CurTime() then
		if self.SpreadStacks>0 then
			self.SpreadStacks = self.SpreadStacks - (0.1*self.SpreadStacks)
		end
		self.LastTime = CurTime()
	end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.PrimaryLastFire+self.PrimaryCooldown<CurTime() then
		if self.Weapon:Clip1() > 0 then
			if SERVER then
				if ( self.Owner:IsPlayer() ) then
					self.Owner:LagCompensation( true )
				end
				local shootOrigin = self.Owner:EyePos()
				local shootDir = self.Owner:GetAimVector()
				for i=1, self.ShotCount do
					local shell = {}
					shell.Pos = self.Owner:GetShootPos()
					shell.Ang = self.Owner:GetAimVector():Angle() + Angle(math.Rand(-self.Spread,self.Spread),math.Rand(-self.Spread,self.Spread),math.Rand(-self.Spread,self.Spread))
					if self.Owner:Crouching() then
						shell.Ang = self.Owner:GetAimVector():Angle() + 0.5*Angle(math.Rand(-self.Spread,self.Spread),math.Rand(-self.Spread,self.Spread),math.Rand(-self.Spread,self.Spread))
					end

					shell.DakTrail = self.DakTrail
					shell.DakCaliber = self.DakCaliber
					shell.DakShellType = self.DakShellType
					shell.DakPenLossPerMeter = self.DakPenLossPerMeter
					shell.DakExplosive = self.DakExplosive

					shell.DakVelocity = self.DakVelocity
					shell.DakBaseVelocity = self.DakVelocity

					shell.DakMass = (math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*5))*7700
					shell.DakDamage = shell.DakMass*((shell.DakVelocity*0.0254)*(shell.DakVelocity*0.0254))*0.01*0.002

					shell.DakIsPellet = false
					shell.DakSplashDamage = self.DakCaliber*0.375
					if self.IsMissile then
						shell.DakPenetration = self.PenOverride
						shell.DakBasePenetration = self.PenOverride
					else
						shell.DakPenetration = (self.DakCaliber*2)*self.ShellLengthMult
						shell.DakBasePenetration = (self.DakCaliber*2)*self.ShellLengthMult
					end
					
					
					shell.DakBlastRadius = (self.DakCaliber/25*39)
					shell.DakPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
					
					shell.DakGun = self
					shell.DakGun.DakOwner = self.Owner
					shell.Filter = {self.Owner, self}
					shell.LifeTime = 0
					shell.Gravity = 0
					shell.DakFragPen = (self.DakCaliber/2.5)

					shell.IsGuided = self.DakIsGuided

					shell.Indicator = self.Owner
					shell.IndicatorStart = self.Owner:GetShootPos()
					shell.IndicatorEnd = self.Owner:GetShootPos()+self.Owner:GetAimVector()*1000000

					DakTankShellList[#DakTankShellList+1] = shell
				end
			end
			if ( self.Owner:IsPlayer() ) then
				self.Owner:LagCompensation( false )
			end
			local ActualSpeed = self.Owner:GetVelocity():Length()
			local MaxSpeed = self.Owner:GetRunSpeed()
			local IsMoving = math.max(0.5, ActualSpeed/MaxSpeed)
			local IsCrouch = self.Owner:Crouching() and 0.5 or 1
			local ShotForce = ((self.DakVelocity*0.0254)*(self.DakVelocity*0.0254)*(math.pi*((self.DakCaliber*0.001*0.5)^2)*(self.DakCaliber*0.001*5))*7700)
			local BaseRecoil = Angle(-math.Rand(0.0004, 0.0006), math.Rand(0.0002,-0.0002), 0)
			local FinalRecoil = BaseRecoil * self.ShotCount * ShotForce * IsMoving * IsCrouch * (self.SpreadStacks/1) --have spread stacks so first few shots are sorta accurate
			if self.IsPistol == true then
				FinalRecoil = FinalRecoil * 3
			end
			if self.IsRifle == true then
				FinalRecoil = FinalRecoil * 0.5
			end
			if self.SpreadStacks<5 then
				self.SpreadStacks = self.SpreadStacks + (ShotForce/10000)
			end
			if CLIENT or game.SinglePlayer() then
				self.Owner:SetEyeAngles( self.Owner:EyeAngles() + FinalRecoil )
				self.Owner:ViewPunch( FinalRecoil / 4 )
			end
			self:EmitSound( self.FireSound, 140, 100, 1, 2)
			self.PrimaryLastFire = CurTime()
			self:TakePrimaryAmmo(1)
			self.Fired = 1
		else
			if SERVER then
				self:Reload()
			end
		end
	end
	
	if self.Fired == 1 then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Fired = 0
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetFOV()==self.Zoom then
		self.Owner:SetFOV( 0, 0.1 )
	else
		self.Owner:SetFOV( self.Zoom, 0.1 )
	end
end
 
function SWEP:AdjustMouseSensitivity()
	if math.Round(self.Owner:GetFOV(),0)==self.Zoom then
		return self.Zoom/100
	else
		return 1
	end
end

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )
end


