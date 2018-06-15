function EFFECT:Init( Data )

	local Pos = Data:GetOrigin()
	local Size = Data:GetScale()
	
	local Sparks = EffectData()
	Sparks:SetOrigin( Pos )
	Sparks:SetMagnitude( math.Rand(2,Size/10+2) )
	Sparks:SetScale( math.Rand(1+Size/10,2+Size/10) )
	Sparks:SetRadius( math.Rand(2+Size/10,3+Size/10) )
	util.Effect( "Sparks", Sparks )
	
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

	Emitter:Finish()

end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end