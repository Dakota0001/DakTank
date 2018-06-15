/*
This effect goes in lua/effects/<Your effect name>/init.lua

How to use: Example Code:

	local OurEnt = LocalPlayer() 
	local part = EffectData()
	if OurEnt ~= NULL then
	part:SetStart( OurEnt:GetPos() + Vector(0,0,70) )
	part:SetOrigin( OurEnt:GetPos() + Vector(0,0,70) )
	part:SetEntity( OurEnt )
	part:SetScale( 1 )
	util.Effect( "Your Effect name", part)
	end 
	
You can use this in ENT:Think() or PrimaryEffect in an entity or hook.Add("Think","Effect", function() ... end)

Think is for animated effects
*/

function EFFECT:Init( Data )

	self.StartPos = Data:GetStart()
	self.EndPos = Data:GetOrigin()
	self.Caliber = Data:GetScale()

	self.Dir = (self.EndPos-self.StartPos):GetNormalized()
	self.Dist = self.EndPos:Distance(self.StartPos)

	self.TracerTime = math.min(1, self.StartPos:Distance(self.EndPos)/10000)
	self.DieTime = CurTime() + 0.25

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	local Emitter = ParticleEmitter( self.StartPos )
	
	for i = 1, 3 do

		local Velocity = Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5))
		local Position = self.StartPos + self.Dir*math.Rand(0,self.Dist)
		local Particle = Emitter:Add( "dak/flamelet5", Position ) 

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( 0.5 )
		Particle:SetStartAlpha( 150 )
		Particle:SetStartSize( 15 )
		Particle:SetEndSize( 10 )
		Particle:SetRoll( math.Rand( 0, 360 ) )
		Particle:SetColor( 255, 255, 255, 255 )
		Particle:SetGravity( Vector(0,0,math.random(-5,-25)) )
		Particle:SetCollide( true )
	end

	for i = 1, 3 do
		
		local Velocity = Vector(math.Rand(-25,25),math.Rand(-25,25),math.Rand(-25,25))
		local Position = self.StartPos + self.Dir*math.Rand(0,self.Dist)
		local Particle = Emitter:Add( "dak/smokey", Position )
		local Color = math.random(50,100)

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( 2.0 ) 
		Particle:SetStartAlpha( 75 )
		Particle:SetEndSize( 25 )
		Particle:SetRoll( math.Rand( 0, 360 ) )
		Particle:SetColor( Color, Color, Color, 50 )
		Particle:SetGravity( Vector(0,0,math.random(5,25)) ) 
		Particle:SetAirResistance( 20 ) 
		Particle:SetCollide( true )
	end
	
	Emitter:Finish()

end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

function EFFECT:Render()
end