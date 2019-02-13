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
SWEP.Instructions = "staring contest consolidation prize, Caliber: 140mm, Velocity: 100m/s, Damage: 17 vs armor, RPM: 30, Pen: 300mm"

SWEP.Category = "DakTank"
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/v_RPG.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "RPG_Round"

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
	self.PrimaryCooldown = 1
	self.FireSound = "daktanks/extra/76mmUSA2.mp3"
	self.IsPistol = false

 	--shell info
 	self.DakTrail = "daktemissiletracer"
	self.DakCaliber = 140
	self.DakShellType = "ATGM"
	self.DakPenLossPerMeter = 0.0
	self.DakExplosive = true
	self.DakVelocity = 3960
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
		for i = 1, #self.ShellList do
			self.ShellList[i].LifeTime = self.ShellList[i].LifeTime + 0.1
			self.ShellList[i].Gravity = physenv.GetGravity()*self.ShellList[i].LifeTime
			local trace = {}
				local indicatortrace = {}
					indicatortrace.start = self.Owner:GetShootPos()
					indicatortrace.endpos = self.Owner:GetShootPos()+self.Owner:GetAimVector()*1000000
					indicatortrace.filter = {self, self.Owner}
				local indicator = util.TraceLine(indicatortrace)
				if not(self.ShellList[i].SimPos) then
					self.ShellList[i].SimPos = self.ShellList[i].Pos
				end

				local _, RotatedAngle =	WorldToLocal( Vector(0,0,0), (indicator.HitPos-self.ShellList[i].SimPos):GetNormalized():Angle(), self.ShellList[i].SimPos, self.ShellList[i].Ang )
				local Pitch = math.Clamp(RotatedAngle.p,-10,10)
				local Yaw = math.Clamp(RotatedAngle.y,-10,10)
				local Roll = math.Clamp(RotatedAngle.r,-10,10)
				local _, FlightAngle = LocalToWorld( self.ShellList[i].SimPos, Angle(Pitch,Yaw,Roll), Vector(0,0,0), Angle(0,0,0) )
				self.ShellList[i].Ang = self.ShellList[i].Ang + FlightAngle
				self.ShellList[i].SimPos = self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*0.1)

				trace.start = self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*-0.1)
				trace.endpos = self.ShellList[i].SimPos + (self.ShellList[i].DakVelocity * self.ShellList[i].Ang:Forward()*0.1)
				trace.filter = self.ShellList[i].Filter
				trace.mins = Vector(-1,-1,-1)
				trace.maxs = Vector(1,1,1)
			local ShellTrace = util.TraceHull( trace )
			local effectdata = EffectData()
			effectdata:SetStart(ShellTrace.StartPos)
			effectdata:SetOrigin(ShellTrace.HitPos)
			effectdata:SetScale((self.ShellList[i].DakCaliber*0.0393701))
			util.Effect(self.ShellList[i].DakTrail, effectdata, true, true)
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
		end
		if #self.RemoveList > 0 then
			for i = 1, #self.RemoveList do
				table.remove( self.ShellList, self.RemoveList[i] )
			end
		end
		self.RemoveList = {}
		self.LastTime = CurTime()
	end
end

