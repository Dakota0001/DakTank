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

	local Pos = Data:GetOrigin()

	local Emitter = ParticleEmitter( Pos )

	for i = 1, 3 do

		local Position = Pos + Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50))
		local Velocity = Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25))
		local Particle = Emitter:Add( "dak/smokey", Position )
		local Color = math.random(50,100)

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( 5 )
		Particle:SetStartAlpha( 150 )
		Particle:SetEndSize( 100 )
		Particle:SetRoll( math.Rand( 0, 360 ) )
		Particle:SetColor( Color,Color,Color,50 )
		Particle:SetGravity( Vector(0,0,math.random(5,50)) )
		Particle:SetAirResistance( 20 )
	end

	for i = 1, 3 do

		local Position = Pos + Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25))
		local Velocity = Vector(math.random(-50,50),math.random(-50,50),math.random(-25,25))
		local Particle = Emitter:Add( "dak/flamelet5", Position )

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( 2.5 )
		Particle:SetStartAlpha( 255 )
		Particle:SetStartSize( 25 )
		Particle:SetEndSize( 5 )
		Particle:SetRoll( math.Rand( 0, 360 ) )
		Particle:SetColor( 255,255,255,255 )
	end

	Emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end