include("daktank_swepbase.lua")

if CLIENT then
 
	SWEP.PrintName = "The Sermer"
	SWEP.Slot = 1
end

SWEP.Purpose	  = "Erases Things."
SWEP.Instructions = "Point and Click Adventure"
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel  = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/props_vehicles/van001a_physics.mdl"

SWEP.Primary.ClipSize	 = 50
SWEP.Primary.DefaultClip = 3000
SWEP.Primary.Automatic	 = true
SWEP.Primary.AmmoType	 = "APHE"
SWEP.Primary.Ammo		 = "Thumper"
SWEP.Primary.ShotAmount	 = 10
SWEP.Primary.Cooldown	 = 0.25
SWEP.Primary.Caliber	 = 10
SWEP.Primary.Penetration = 50
SWEP.Primary.MuzzleVel	 = 12500
SWEP.Primary.RoundMass	 = 5
SWEP.Primary.Damage		 = 0.1
SWEP.Primary.IsExplosive = true
SWEP.Primary.SplashDmg	 = 10
SWEP.Primary.BlastRadius = 100
SWEP.Primary.FragPen	 = 10
SWEP.Primary.Spread		 = 1.5
SWEP.Primary.AimFOV 	 = 55

SWEP.FireSound = "daktanks/extra/35mmBushmasterlll.mp3"

SWEP.HoldType = "pistol"

function SWEP:DrawWorldModel()
	self.Weapon:SetMaterial( "models/player/shared/gold_player" )
	self.Weapon:SetModelScale( 0.33 )
	self.Weapon:DrawShadow( false )
	self:DrawModel()
end

function SWEP:PreDrawViewModel( ViewModel, Weapon )
	ViewModel:SetMaterial( "models/player/shared/gold_player" )
end

function SWEP:PostDrawViewModel( ViewModel )
	ViewModel:SetMaterial( "" )
end

function SWEP:GetViewModelPosition( pos, ang )
	local Height = 28

	if self.Owner:Crouching() then
		Height = 12
	end

	return self.Weapon:LocalToWorld(Vector(0, -15, Height)), ang + Angle(0, 10, -100)
end