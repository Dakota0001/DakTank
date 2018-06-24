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
	
	for i = 1, 15 do
		
		local Position = Pos + Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
		local Velocity = Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200))
		local Particle = Emitter:Add( "dak/smokey", Position ) 
		local Color = math.random(10,100)
		
		Particle:SetVelocity( Velocity )
		Particle:SetLifeTime( 0.5 ) 
		Particle:SetDieTime( 1.0 ) 
		Particle:SetStartAlpha( 255 )
		Particle:SetStartSize( 10 ) 
		Particle:SetEndSize( 50 )
		Particle:SetRoll( math.Rand(0, 360) )
		Particle:SetColor( Color, Color, Color, 255 )
		Particle:SetGravity( Vector(0,0,5) ) 
		Particle:SetAirResistance( 50 )  
		Particle:SetBounce( 100 )
	end

	for i = 1, 20 do

		local Velocity = Vector(math.random(-250,250),math.random(-250,250),math.random(-250,250))
		local Debris = Emitter:Add( "effects/fleck_tile"..math.random(1,2), Pos )

		Debris:SetVelocity( Velocity )
		Debris:SetDieTime( math.Rand( 0.5 , 1.5 ) )
		Debris:SetStartAlpha( 255 )
		Debris:SetStartSize( 2 )
		Debris:SetEndSize( 2 )
		Debris:SetRoll( math.Rand(0, 360) )
		Debris:SetRollDelta( math.Rand(-3, 3) )
		Debris:SetAirResistance( 50 )
		Debris:SetGravity( Vector(0,0,-math.Rand(250,500)) )			
		Debris:SetColor( 50, 50, 50 )
	end

	for i = 1, 25 do
		
		local Velocity = Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200))
		local Particle = Emitter:Add( "sprites/light_glow02_add.vmt", Pos + Vector( math.random(-10,10),math.random(-10,10),math.random(-10,10) ) ) 

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( math.Rand(0.01,0.16) ) 
		Particle:SetStartAlpha( 200 )
		Particle:SetStartSize( math.Rand(90,110) ) 
		Particle:SetRoll( math.Rand(0,360) )
		Particle:SetColor( 255, 150, 75, math.random(150,255) )
		Particle:SetAirResistance( 1500 )  
		Particle:SetBounce( 1000 )
	end

	Emitter:Finish()

end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end