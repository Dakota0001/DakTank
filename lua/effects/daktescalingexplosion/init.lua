function EFFECT:Init( Data )

	local Pos = Data:GetOrigin()
	local Size = Data:GetScale()/78
	
	local Emitter = ParticleEmitter( Pos )
	
	for i = 1, math.Round(30*Size) do

		local Position = Pos + Size*Vector(math.random(-10,10),math.random(-10,10),math.random(-10,10))
		local Velocity = Size*Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200))
		local Particle = Emitter:Add( "dak/smokey", Position )
		local Color = math.random(40,60)
		
		Particle:SetVelocity( Velocity )
		Particle:SetLifeTime( Size*0.25 ) 
		Particle:SetDieTime( Size ) 
		Particle:SetStartAlpha( 150 )
		Particle:SetStartSize( Size*10 ) 
		Particle:SetEndSize( math.random(25,125)*Size )
		Particle:SetRoll( math.Rand(0,360) )
		Particle:SetColor( Color, Color, Color, 50 )
		Particle:SetGravity( Vector(0,0,-50) ) 
		Particle:SetAirResistance( math.random(25,125) )  
		Particle:SetBounce( 100 )
	end

	for i = 1, math.Round(Size*20) do

		local Velocity = Size*Vector(math.random(-250,250),math.random(-250,250),math.random(-250,250))
		local Debris = Emitter:Add( "effects/fleck_tile"..math.random(1,2), Pos )

		Debris:SetVelocity( Velocity )
		Debris:SetDieTime( math.Rand(0.5,1.5) )
		Debris:SetStartAlpha( 255 )
		Debris:SetStartSize( 2 )
		Debris:SetEndSize( 2 )
		Debris:SetRoll( math.Rand(0,360) )
		Debris:SetRollDelta( math.Rand(-3,3) )			
		Debris:SetAirResistance( 50 ) 			 
		Debris:SetGravity( Vector(0,0,-math.Rand(250,500)) ) 			
		Debris:SetColor( 50,50,50 )
	end

	for i = 1, math.Round(Size*25) do

		local Position = Pos + Size*Vector(math.random(-20,20),math.random(-20,20),math.random(-20,20))
		local Velocity = Size*Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200))
		local Particle = Emitter:Add( "sprites/light_glow02_add.vmt", Position ) 

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( math.Rand(0.01,0.51) ) 
		Particle:SetStartAlpha( 200 )
		Particle:SetStartSize( Size*math.Rand(90,110) ) 
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