AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )

if SERVER then
 
	--AddCSLuaFile ("shared.lua")
 

	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 
elseif CLIENT then
 
	SWEP.PrintName = "Repair Tool"
 
	SWEP.Slot = 4
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end
 
SWEP.Author = "DakTank"
SWEP.Purpose = "Unshoots Things."
SWEP.Instructions = "laser torch used for field repairs, heals gearbox, motors, and fuel up to at half health then repairs destroyed ammo bins which must be refilled at a point."

SWEP.Category = "DakTank"
 
SWEP.Spawnable = true
SWEP.AdminOnly = false
 
SWEP.ViewModel  = "models/weapons/c_irifle.mdl"
SWEP.WorldModel = "models/weapons/w_irifle.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

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
	self.PrimaryMessage = 0
	self.Fired = 0

 	--gun info
 	self.ShotCount = 1
	self.Spread = 0.05 --0.1 for pistols, 0.075 for smgs, 0.05 for rifles
	self.PrimaryCooldown = 0.5
	self.FireSound = "dak/pulselarge.wav"
	self.IsPistol = false
	self.IsRifle = true
	self.heavyweapon = false

	self.Zoom = 55
end

function SWEP:Reload()
	--[[
	if  ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		self.Weapon:DefaultReload(ACT_VM_RELOAD)	
		if self.Owner:GetFOV()==self.Zoom then
			self.Owner:SetFOV( 0, 0.1 )
		end
		self.SpreadStacks = 0
	end
	]]--
end
 
function SWEP:Think()
	if self.LastTime+0.1 < CurTime() then
		self.DakOwner = self.Owner
		--if self.SpreadStacks>0 then
		--	self.SpreadStacks = self.SpreadStacks - (0.1*self.SpreadStacks)
		--end
		self.LastTime = CurTime()

		--if self.Owner.PerkType == 1 and self.AmmoGiven == nil then
		--	self.AmmoGiven = 1
		--	self.Owner:GiveAmmo( self.Primary.DefaultClip, self:GetPrimaryAmmoType(), true )
		--end
	end
	if CLIENT or game.SinglePlayer() then
		if(self:GetNWBool("BeamOn")) then
			if (self:GetAttachment( 1 )) then
				local Dist = self:GetNWFloat("BeamDist")
				local Dir = self:GetNWVector("BeamDir")
				local Start = self:GetNWVector("BeamStart")
				local effectdata = EffectData()
				effectdata:SetOrigin(Start + (Dir * Dist))
				effectdata:SetEntity(self)
				effectdata:SetAttachment(1)
				effectdata:SetMagnitude(1)
				effectdata:SetScale(200)
				util.Effect("laserburn", effectdata)
				--local effectdata2 = EffectData()
				--effectdata2:SetOrigin(LocalPlayer():GetPos() + LocalPlayer():EyeAngles():Forward()*250*math.Clamp((90/LocalPlayer():GetFOV()),1,4) )
				--effectdata2:SetStart(Start)
				--effectdata2:SetEntity(LocalPlayer())
				--effectdata2:SetAttachment(1)
				--effectdata2:SetMagnitude(Dist)
				--effectdata2:SetScale(0.5)
				--util.Effect("smalllaserbeam", effectdata2)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end
	if self.PrimaryLastFire+self.PrimaryCooldown<CurTime() then
		if (self.heavyweapon == true and self.Owner:GetVelocity()==Vector(0,0,0) and self.Owner:OnGround()) or self.heavyweapon == false or self.heavyweapon == nil then 
			if SERVER then
				if ( self.Owner:IsPlayer() ) then
					self.Owner:LagCompensation( true )
				end
				local shootOrigin = self.Owner:EyePos()
				local shootDir = self.Owner:GetAimVector()
				local trace = {}
				trace.start = self.Owner:GetShootPos()
				trace.endpos = self.Owner:GetShootPos()+self.Owner:GetAimVector()*250
				trace.filter = self.Owner
				trace.mins = -Vector(0.01,0.01,0.01)
				trace.maxs = Vector(0.01,0.01,0.01)
				local BeamTrace = util.TraceHull( trace )
				self.LastHit = BeamTrace.HitPos

				local heal = 0
				if IsValid(BeamTrace.Entity) then
					self.LastEnt = BeamTrace.Entity
					if IsValid(self.LastEnt.Controller) then
						if IsValid(self.LastEnt.Controller.Gearbox) then
							if heal == 0 and self.LastEnt.Controller.Gearbox.DakHealth < self.LastEnt.Controller.Gearbox.DakMaxHealth*0.5 then
								self.LastEnt.Controller.Gearbox.DakHealth = math.Min(self.LastEnt.Controller.Gearbox.DakHealth + math.ceil(self.LastEnt.Controller.Gearbox.DakMaxHealth*0.01),self.LastEnt.Controller.Gearbox.DakMaxHealth)
								heal = 1
								self.Owner:ChatPrint("Gearbox repaired to "..(100*self.LastEnt.Controller.Gearbox.DakHealth/self.LastEnt.Controller.Gearbox.DakMaxHealth).."%")
								self.LastEnt.Controller.Gearbox:SetColor(Color(255,255,255,255))
								self.LastEnt.Controller.Gearbox.DakDead = false
							end
							if heal == 0 then
								for i=1, #self.LastEnt.Controller.Motors do
									if heal == 0 and self.LastEnt.Controller.Motors[i].DakHealth < self.LastEnt.Controller.Motors[i].DakMaxHealth*0.5 then
										self.LastEnt.Controller.Motors[i].DakHealth = math.Min(self.LastEnt.Controller.Motors[i].DakHealth + math.ceil(self.LastEnt.Controller.Motors[i].DakMaxHealth*0.025),self.LastEnt.Controller.Motors[i].DakMaxHealth)
										heal = 1
										self.Owner:ChatPrint("Motor #"..i.." repaired to "..(100*self.LastEnt.Controller.Motors[i].DakHealth/self.LastEnt.Controller.Motors[i].DakMaxHealth).."%")
										self.LastEnt.Controller.Motors[i]:SetColor(Color(255,255,255,255))
										self.LastEnt.Controller.Motors[i].DakDead = false
									end
								end
							end
							if heal == 0 then
								for i=1, #self.LastEnt.Controller.Fuel do
									self.LastEnt.Controller.Fuel[i]:Extinguish()
									if heal == 0 and self.LastEnt.Controller.Fuel[i].DakHealth < self.LastEnt.Controller.Fuel[i].DakMaxHealth*0.5 then
										self.LastEnt.Controller.Fuel[i].DakHealth = math.Min(self.LastEnt.Controller.Fuel[i].DakHealth + math.ceil(self.LastEnt.Controller.Fuel[i].DakMaxHealth*0.05),self.LastEnt.Controller.Fuel[i].DakMaxHealth)
										heal = 1
										self.Owner:ChatPrint("Fuel Tank #"..i.." repaired to "..(100*self.LastEnt.Controller.Fuel[i].DakHealth/self.LastEnt.Controller.Fuel[i].DakMaxHealth).."%")
										self.LastEnt.Controller.Fuel[i]:SetColor(Color(255,255,255,255))
										self.LastEnt.Controller.Fuel[i].DakDead = false
									end
								end
							end
							if heal == 0 then
								for i=1, #self.LastEnt.Controller.Ammoboxes do
									if heal == 0 then
										if self.LastEnt.Controller.Ammoboxes[i].DakHealth <= 0 then
											self.LastEnt.Controller.Ammoboxes[i].DakAmmo = 0
											self.LastEnt.Controller.Ammoboxes[i].DakHealth = self.LastEnt.Controller.Ammoboxes[i].DakMaxHealth
											heal = 1
											self.Owner:ChatPrint("Ammo Box #"..i.." repaired and emptied")
											self.LastEnt.Controller.Ammoboxes[i]:SetColor(Color(255,255,255,255))
											self.LastEnt.Controller.Ammoboxes[i].DakDead = false
										end
									end
								end
							end
						else
							if heal == 0 then
								for i=1, #self.LastEnt.Controller.Ammoboxes do
									if heal == 0 then
										if self.LastEnt.Controller.Ammoboxes[i].DakHealth <= 0 then
											self.LastEnt.Controller.Ammoboxes[i].DakAmmo = 0
											self.LastEnt.Controller.Ammoboxes[i].DakHealth = self.LastEnt.Controller.Ammoboxes[i].DakMaxHealth
											heal = 1
											self.Owner:ChatPrint("Ammo Box #"..i.." repaired and emptied")
											self.LastEnt.Controller.Ammoboxes[i]:SetColor(Color(255,255,255,255))
											self.LastEnt.Controller.Ammoboxes[i].DakDead = false
										end
									end
								end
							end
						end
						self.Fired = heal
						self:EmitSound( self.FireSound, 140, 95*math.Rand(0.99,1.01), 1, 2)
					else
						self:EmitSound( self.FireSound, 140, 95*math.Rand(0.24,0.26), 1, 2)
					end
				end
			end
			if ( self.Owner:IsPlayer() ) then
				self.Owner:LagCompensation( false )
			end
			
			--[[
			if SERVER then
				net.Start( "daktankshotfired" )
				net.WriteVector( self:GetPos() )
				net.WriteFloat( self.DakCaliber )
				net.WriteString( self.FireSound )
				net.Broadcast()
			end
			--]]	
			self.PrimaryLastFire = CurTime()
		end
		if (self.heavyweapon == true and not(self.Owner:GetVelocity()==Vector(0,0,0) and self.Owner:OnGround())) then
			if self.PrimaryMessage == nil then self.PrimaryMessage = 0 end
			if self.PrimaryMessage+1<CurTime() then
				if SERVER then
					self.Owner:ChatPrint("You must stand still and be on the ground to fire this weapon!")
				end
				self.PrimaryMessage = CurTime()
			end
		end
	end
	if self.Fired == 1 then
		if SERVER then
			self:SetNWBool("BeamOn", true)
			timer.Simple(0.4,function() self:SetNWBool("BeamOn", false) end)
			self:SetNWFloat("BeamDist",self.LastHit:Distance(self.Owner:EyePos()))
			self:SetNWVector("BeamDir",self.Owner:GetAimVector())
			self:SetNWVector("BeamStart",self.Owner:EyePos())
		end
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