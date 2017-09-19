function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local size = data:GetScale()
	local emitter = ParticleEmitter( Pos )
	for i = 1,5*size do
		local particle = emitter:Add( "dak/smokey", Pos+Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))  
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos) end
		if (particle) then
			particle:SetVelocity(Vector(math.random(-100*size,100*size),math.random(-100*size,100*size),math.random(-100*size,100*size)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.5) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(5+size) 
			particle:SetEndSize(0)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(50,100)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,math.random(5,10)) ) 
			particle:SetAirResistance(75*size)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end

	local Sparks = EffectData()
	Sparks:SetOrigin( Pos )
	--Sparks:SetNormal( self.Normal )
	Sparks:SetMagnitude( 2+math.Rand(0,size/10) )
	Sparks:SetScale( math.Rand(1+size/10,2+size/10) )
	Sparks:SetRadius( math.Rand(2+size/10,3+size/10) )
	util.Effect( "Sparks", Sparks )
	emitter:Finish()
		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end