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
	
	local emitter = ParticleEmitter( Pos )
	
	for i = 1,10 do

		local particle = emitter:Add( "dak/smokey", Pos+Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)))  
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(5) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0) 
			particle:SetEndSize(100)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(50,100)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,math.random(5,50)) ) 
			particle:SetAirResistance(20)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end

	for i = 1,10 do

		local particle = emitter:Add( "dak/flamelet5", Pos+Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25))) 
		 
		if particle == nil then particle = emitter:Add( "dak/flamelet5", Pos+Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25)))  end
		
		if (particle) then
			particle:SetVelocity(Vector(math.random(-50,50),math.random(-50,50),math.random(-25,25)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(2.5) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(25) 
			particle:SetEndSize(5)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(255,255),math.random(255,255),math.random(255,255),math.random(255,255))
			particle:SetGravity( Vector(0,0,math.random(0,0)) ) 
			particle:SetAirResistance(0.0)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end

	emitter:Finish()
		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end