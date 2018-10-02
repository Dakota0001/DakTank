AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )
AddCSLuaFile()

local bor = bit.bor
local max = math.max
local Rand = math.Rand
local Clamp = math.Clamp
local remove = table.remove
local Gravity = physenv.GetGravity
local TraceHull = util.TraceHull
local Effect = util.Effect
local EffectData = EffectData
local IsValid = IsValid
local SWEP = SWEP

if SERVER then

	SWEP.Weight = 5
elseif CLIENT then

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
	SWEP.PrintName = "SWEP Base"
	SWEP.Slot = 1
end

SWEP.Author	   = "DakTank"
SWEP.Spawnable = false
SWEP.BobScale  = 1.5
SWEP.SwayScale = 1.5

SWEP.ViewModel  = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

SWEP.Primary.ClipSize	 = 10
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic	 = false
SWEP.Primary.Ammo		 = "Pistol"
SWEP.Primary.ShotAmount	 = 1
SWEP.Primary.Cooldown	 = 0.1
SWEP.Primary.Caliber	 = 5
SWEP.Primary.AmmoType	 = "AP"
SWEP.Primary.Explosive	 = false
SWEP.Primary.Penetration = 1
SWEP.Primary.MuzzleVel	 = 7500
SWEP.Primary.LossXMeter	 = 0.0005
SWEP.Primary.RoundMass	 = 1
SWEP.Primary.Damage		 = 0.025
SWEP.Primary.IsExplosive = false
SWEP.Primary.SplashDmg	 = 0
SWEP.Primary.BlastRadius = 0
SWEP.Primary.FragPen	 = 0
SWEP.Primary.Spread		 = 0
SWEP.Primary.AimFOV		 = 50
SWEP.Primary.Trail		 = "dakteballistictracer"
SWEP.Primary.IsGuided	 = false
SWEP.Primary.PenSounds	 = {"daktanks/daksmallpen1.wav",
							"daktanks/daksmallpen2.wav",
							"daktanks/daksmallpen3.wav",
							"daktanks/daksmallpen4.wav"}

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo 	   = "none"

SWEP.LastTime 	 = CurTime()
SWEP.UseHands 	 = true
SWEP.Category 	 = "DakTank"
SWEP.FireMoving	 = true
SWEP.ReloadSound = {"weapons/ar2/ar2_empty.wav"}

SWEP.CSMuzzleFlashes = true

function SWEP:Recoil()
	if not IsValid(self) then return end
	
	local Player = self.Owner
	local Primary = self.Primary
	local ActualSpeed = Player:GetVelocity():Length()
	local MaxSpeed = Player:GetRunSpeed()
	local IsMoving = max(0.5, ActualSpeed/MaxSpeed)
	local IsCrouch = Player:Crouching() and 0.5 or 1
	local ShotForce = (Primary.MuzzleVel*0.000254)*(Primary.MuzzleVel*0.000254)*Primary.RoundMass*0.5
	local BaseRecoil = Angle(-Rand(0.04, 0.06), Rand(0.02,-0.02), 0)
	local FinalRecoil = BaseRecoil * ShotForce * IsMoving * IsCrouch

	Player:SetEyeAngles( Player:EyeAngles() + FinalRecoil )
	Player:ViewPunch( FinalRecoil / 4 )
end

function SWEP:ShootBullet()
	local Player = self.Owner
	local Primary = self.Primary
	local ShellList = self.ShellList
	local Direction = Player:GetAimVector():Angle()
	local Position = Player:GetShootPos()
	
	for i = 1, Primary.ShotAmount do
		local DakShell = {
			Pos = Position,
			Ang = Direction + Angle(Rand(Primary.Spread,-Primary.Spread),Rand(Primary.Spread,-Primary.Spread),0),
			DakTrail = Primary.Trail,
			DakVelocity = Primary.MuzzleVel,
			DakDamage = Primary.Damage,
			DakMass = Primary.RoundMass,
			DakPenetration = Primary.Penetration,
			DakPenSounds = Primary.PenSounds,
			DakBasePenetration = Primary.Penetration,
			DakCaliber = Primary.Caliber,
			DakExplosive = Primary.IsExplosive,
			DakSplashDamage = Primary.SplashDmg,
			DakBlastRadius = Primary.BlastRadius,
			DakFragPen = Primary.FragPen,
			IsGuided = Primary.IsGuided,
			Indicator = Player,
			DakFirePitch = 100,
			DakGun = Player,
			Filter = { Player },
			LifeTime = 0,
			DakPenLossPerMeter = Primary.LossXMeter,
		}
		DakShell.DakGun.DakOwner = Player

		ShellList[#ShellList+1] = DakShell
	end
end

function SWEP:Initialize()
	
	if SERVER and self.Owner:IsNPC() then
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
	
	self:SetHoldType( self.HoldType )

	self.Primary.LastFire = 0

	self.ShellList = {}
end

function SWEP:Think()

	if self.LastTime+0.1 >= CurTime() then return end
	
	for i = #self.ShellList, 1, -1 do
		local Shell = self.ShellList[i]

		Shell.LifeTime = Shell.LifeTime + 0.1
		Shell.Gravity = Gravity()*Shell.LifeTime

		local Trace = {
			filter = Shell.Filter,
			mins = -Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02),
			maxs = Vector(Shell.DakCaliber*0.02,Shell.DakCaliber*0.02,Shell.DakCaliber*0.02)
		}

		if Shell.IsGuided then			
			if not Shell.SimPos then
				Shell.SimPos = Shell.Pos
			end

			local AimPos = Shell.Indicator:GetEyeTraceNoCursor().HitPos

			local _, RotatedAngle = WorldToLocal(Vector(), (AimPos-Shell.SimPos):GetNormalized():Angle(), Shell.SimPos, Shell.Ang)
			local Pitch = Clamp(RotatedAngle.p,-1,1)
			local Yaw = Clamp(RotatedAngle.y,-1,1)
			local Roll = Clamp(RotatedAngle.r,-1,1)
			local _, FlightAngle = LocalToWorld(Shell.SimPos, Angle(Pitch,Yaw,Roll), Vector(), Angle())
				
			Shell.Ang = Shell.Ang + FlightAngle
			Shell.SimPos = Shell.SimPos + (Shell.DakVelocity * Shell.Ang:Forward()*0.1)

			Trace.start = Shell.SimPos + (Shell.DakVelocity * Shell.Ang:Forward()*-0.1)
			Trace.endpos = Shell.SimPos + (Shell.DakVelocity * Shell.Ang:Forward()*0.1)
		else
			Trace.start = Shell.Pos + (Shell.DakVelocity * Shell.Ang:Forward() * (Shell.LifeTime-0.1)) - (-Gravity()*((Shell.LifeTime-0.1)^2)/2)
			Trace.endpos = Shell.Pos + (Shell.DakVelocity * Shell.Ang:Forward() * Shell.LifeTime) - (-Gravity()*(Shell.LifeTime^2)/2)
		end
				
		local ShellTrace = TraceHull( Trace )

		local Data = EffectData()
			  Data:SetStart(ShellTrace.StartPos)
			  Data:SetOrigin(ShellTrace.HitPos)
			  Data:SetScale(Shell.DakCaliber*0.0393701)
		Effect(Shell.DakTrail, Data, true, true)
			
		if ShellTrace.Hit then
			DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,Shell,ShellTrace.HitNormal)
		end
			
		if Shell.DieTime and Shell.DieTime+1.5 < CurTime()
		or Shell.RemoveNow == 1 then
			remove( self.ShellList, i )
		end
	end

	self.LastTime = CurTime()
end

function SWEP:CanPrimaryAttack()
	if not IsValid(self) then return false end
	if self.Primary.LastFire+self.Primary.Cooldown > CurTime() then return false end
	if not self.FireMoving and self.Owner:GetVelocity():Length() > 0 then return false end
	if self.Weapon:Clip1() == 0 then return false end
	
	return true
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:EmitSound( self.FireSound, 140, 100, 1, 2)
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:TakePrimaryAmmo(1)
	self:ShootBullet()
	self:Recoil()

	self.Primary.LastFire = CurTime()
end

function SWEP:SecondaryAttack()
	self.Owner:SetFOV(self.Primary.AimFOV, 0.15)
	self:AdjustMouseSensitivity()
end

hook.Add( "KeyRelease", "daktank_keyrelease_mouse2", function( ply, key )
	if ( key == IN_ATTACK2 ) then
		ply:SetFOV(0, 0.15)
	end
end )

function SWEP:Reload()
	local Primary = self.Primary
	local Weapon = self.Weapon
	local Owner = self.Owner
	
	if ( Weapon:Clip1() == Primary.ClipSize ) then return end
	if ( Owner:GetAmmoCount(Primary.Ammo) == 0 ) then return end
	
	for _, Sound in pairs(self.ReloadSound) do
		Weapon:EmitSound(Sound, 100, 100, 1)
	end 
	
	Weapon:DefaultReload(ACT_VM_RELOAD)
	Owner:SetFOV( 0, 0.15 )
end

function SWEP:GetCapabilities()
	return bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )
end

function SWEP:AdjustMouseSensitivity()
	return self.Owner:GetFOV() == self.Primary.AimFOV and self.Primary.AimFOV / 100 or 1
end