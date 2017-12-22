if SERVER then
 
	--AddCSLuaFile ("shared.lua")
 

	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 
elseif CLIENT then
 
	SWEP.PrintName = "40mm Mortar"
 
	SWEP.Slot = 4
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end
 
SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "20mm average pen, 7m blast"

SWEP.Category = "DakTank"
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel = "models/weapons/v_RPG.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 10
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "RPG_Round"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
 
SWEP.PrimaryCooldown = 5

SWEP.HoldType = "rpg"
function SWEP:Initialize()
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
end
--SWEP:SetHoldType("rpg")
--SWEP.ScopedHoldType = "rpg"
--SWEP.ViewModelFOV = 78.793969849246
--SWEP.ViewModelFlip = false

function SWEP:Reload()
	if  ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
	
		self.Weapon:EmitSound("weapons/slam/mine_mode.wav", 30, 100, 1)
		self.Weapon:DefaultReload(ACT_VM_RELOAD)
		
	end
end
 
function SWEP:Think()
	for i = 1, #self.ShellList do
		self.ShellList[i].LifeTime = self.ShellList[i].LifeTime + 0.1
		self.ShellList[i].Gravity = physenv.GetGravity()*self.ShellList[i].LifeTime

		local trace = {}
			trace.start = self.ShellList[i].Pos
			trace.endpos = self.ShellList[i].Pos + (self.ShellList[i].Ang:Forward()*self.ShellList[i].DakVelocity*0.1) + (self.ShellList[i].Gravity*0.1)
			trace.filter = self.ShellList[i].Filter
			trace.mins = Vector(-1,-1,-1)
			trace.maxs = Vector(1,1,1)
		local ShellTrace = util.TraceHull( trace )

		local effectdata = EffectData()
		effectdata:SetStart(ShellTrace.StartPos)
		effectdata:SetOrigin(ShellTrace.HitPos)
		effectdata:SetScale((self.ShellList[i].DakCaliber*0.0393701))
		util.Effect("dakballistictracer", effectdata)

		if ShellTrace.Hit then
			DTShellHit(ShellTrace.StartPos,ShellTrace.HitPos,ShellTrace.Entity,self.ShellList[i],ShellTrace.HitNormal)
		end

		if self.ShellList[i].DieTime then
			--self.RemoveList[#self.RemoveList+1] = i
			if self.ShellList[i].DieTime+1.5<CurTime()then
				self.RemoveList[#self.RemoveList+1] = i
			end
		end

		if self.ShellList[i].RemoveNow == 1 then
			self.RemoveList[#self.RemoveList+1] = i
		end

		self.ShellList[i].Pos = self.ShellList[i].Pos + (self.ShellList[i].Ang:Forward()*self.ShellList[i].DakVelocity*0.1) + (self.ShellList[i].Gravity*0.1)
	end
	
	if #self.RemoveList > 0 then
		for i = 1, #self.RemoveList do
			table.remove( self.ShellList, self.RemoveList[i] )
		end
	end

	self.RemoveList = {}

	self:NextThink( CurTime()+0.1 )
    return true
end
 
function SWEP:PrimaryAttack()
	if self.PrimaryLastFire+self.PrimaryCooldown<CurTime() then
		if self.Weapon:Clip1() > 0 then
			if SERVER then
				local shootOrigin = self.Owner:EyePos()
				local shootDir = self.Owner:GetAimVector()
				local shell = {}
 				shell.Pos = self.Owner:EyePos()
 				shell.Ang = shootDir:Angle() + Angle(math.Rand(-0.05,0.05),math.Rand(-0.05,0.05),math.Rand(-0.05,0.05))
				shell.DakTrail = "dakshelltrail"
				shell.DakVelocity = 6000
				shell.DakDamage = 2
				shell.DakMass = 20
				shell.DakIsPellet = false
				shell.DakSplashDamage = 50
				shell.DakPenetration = 20
				shell.DakExplosive = true
				shell.DakBlastRadius = 275
				shell.DakPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}
				shell.DakBasePenetration = 20
				shell.DakCaliber = 80
				shell.DakFireSound = ""
				shell.DakFirePitch = 100
				shell.DakGun = self.Owner
				shell.DakGun.DakOwner = self.Owner
				shell.Filter = {self.Owner}
				shell.LifeTime = 0
				shell.Gravity = 0
				if self.DakName == "Flamethrower" then
					shell.DakIsFlame = 1
				end
				self.ShellList[#self.ShellList+1] = shell
			end
			self:EmitSound( "npc/dog/dog_footstep_run7.wav", 140, 100, 1, 2)
			self.PrimaryLastFire = CurTime()
			self:TakePrimaryAmmo(1)
			self.Fired = 1
		else
			self:Reload()
		end
	end

	if self.Fired == 1 then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Fired = 0
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetFOV()==25 then
		self.Owner:SetFOV( 0, 0.1 )
	else
		self.Owner:SetFOV( 25, 0.1 )
	end
end
 
function SWEP:AdjustMouseSensitivity()
	if math.Round(self.Owner:GetFOV(),0)==25 then
	return 0.25
	else
	return 1
	end
end

function SWEP:GetCapabilities()

	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )

end