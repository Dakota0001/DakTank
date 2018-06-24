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
function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Mult = data:GetScale()
	local Target = data:GetEntity()
	
	if not(Target==NULL) then	
		local emitter = ParticleEmitter( Pos )
		
		for i = 1,Mult do


			local Rotation = (Vector(math.random(Target:OBBMins().x,Target:OBBMaxs().x),math.random(Target:OBBMins().y,Target:OBBMaxs().y),math.random(Target:OBBMins().z,Target:OBBMaxs().z)))
			Rotation:Rotate(Target:GetAngles())
			local particle = emitter:Add( "dak/smokey", Pos+Rotation  )  
			 
			if particle == nil then particle = emitter:Add( "dak/smokey", Pos) end
			
			if (particle) then
				particle:SetVelocity(Vector(math.random(-5*Mult,5*Mult),math.random(-5*Mult,5*Mult),math.random(-5*Mult,25*Mult)))
				particle:SetLifeTime(0) 
				particle:SetDieTime(2.5) 
				particle:SetStartAlpha(75)
				particle:SetEndAlpha(0)
				particle:SetStartSize(Target:OBBMins():Length()/2) 
				particle:SetEndSize(Target:OBBMins():Length())
				particle:SetAngles( Angle(0,0,0) )
				particle:SetAngleVelocity( Angle(0,0,0) ) 
				particle:SetRoll(math.Rand( 0, 360 ))
				local CVal = math.random(50,100)
				particle:SetColor(CVal,CVal,CVal,math.random(50,50))
				particle:SetGravity( Vector(0,0,math.random(5,50)) ) 
				particle:SetAirResistance(0.1)  
				particle:SetCollide(false)
				particle:SetBounce(0)
			end
		end

		local Rotation = (Vector(math.random(Target:OBBMins().x,Target:OBBMaxs().x),math.random(Target:OBBMins().y,Target:OBBMaxs().y),math.random(Target:OBBMins().z,Target:OBBMaxs().z)))
		Rotation:Rotate(Target:GetAngles())
		local Sparks = EffectData()
			Sparks:SetOrigin( Pos+Rotation )
			--Sparks:SetNormal( self.Normal )
			Sparks:SetMagnitude( math.Rand(0.1*Mult,0.5*Mult) )
			Sparks:SetScale( math.Rand(0.2*Mult,0.4*Mult) )
			Sparks:SetRadius( math.Rand(0.8*Mult,1.2*Mult) )
			util.Effect( "Sparks", Sparks )

		emitter:Finish()
	end
		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end