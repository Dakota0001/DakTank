function EFFECT:Init( Data )

	local Pos = Data:GetOrigin()
	local Size = Data:GetScale()
	
	local Emitter = ParticleEmitter( Pos )
	
	for i = 1, math.Round(5*Size) do

		local Position = Pos + Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5))
		local Velocity = Size*Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100))
		local Particle = Emitter:Add( "dak/smokey", Position )
		local Color = math.random(50,100)

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( 0.5 )
		Particle:SetStartAlpha( 150 )
		Particle:SetStartSize( 5+Size ) 
		Particle:SetRoll( math.Rand(0,360) )
		Particle:SetColor( Color, Color, Color, math.random(50,50) )
		Particle:SetGravity( Vector(0,0,math.random(5,10)) ) 
		Particle:SetAirResistance( 75*Size )
	end

	for i = 1, math.Round(10*Size) do

		local Velocity = Size*Vector(math.random(-250,250),math.random(-250,250),math.random(-250,250))
		local Debris = Emitter:Add( "effects/fleck_tile"..math.random(1,2), Pos )

		Debris:SetVelocity( Velocity )
		Debris:SetDieTime( math.Rand(0.5,1.5) )
		Debris:SetStartAlpha( 255 )
		Debris:SetStartSize( 1 )
		Debris:SetEndSize( 1 )
		Debris:SetRoll( math.Rand(0,360) )
		Debris:SetRollDelta( math.Rand(-3,3) )			
		Debris:SetAirResistance( 20*Size ) 			 
		Debris:SetGravity( Vector(0,0,-math.Rand(150,350)) ) 			
		Debris:SetColor( 50, 50, 50 )
	end
	
	Emitter:Finish()

end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end