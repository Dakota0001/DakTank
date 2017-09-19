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
	local Ent = data:GetEntity()
	local size = data:GetScale()
	
	local emitter = ParticleEmitter( Pos )
	
	if not(Ent==NULL) then
	for i = 1,50 do

		local particle = emitter:Add( "dak/smokey", Pos + Ent:GetForward()*math.random( -0, 0 )) 
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos + Ent:GetForward()*math.random( 0, 0 ))  end
		
		if (particle) then
			particle:SetVelocity(Ent:GetForward()*math.Rand(750,6000+(size*1200)) + Vector(math.random(-(150+size*100),150+(size*100)),math.random(-(150+size*100),150+(size*100)),math.random(-(150+size*100),150+(size*100))))
			particle:SetLifeTime(0) 
			particle:SetDieTime((size/5)+math.Rand(0,0.5))
			particle:SetStartAlpha(50)
			particle:SetEndAlpha(0)
			particle:SetStartSize(15+size) 
			particle:SetEndSize((15+size)*3)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(150,150),math.random(150,150),math.random(150,150),math.random(255,255))
			particle:SetGravity( Vector(0,0,0) ) 
			particle:SetAirResistance(1500) 
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	end

	if not(Ent==NULL) then
		for i = 1,50 do

		local particle = emitter:Add( "sprites/light_glow02_add.vmt", Pos + Ent:GetForward()*math.random( -0, 0 )) 
		 
		if particle == nil then particle = emitter:Add( "sprites/light_glow02_add.vmt", Pos + Ent:GetForward()*math.random( 0, 0 ))  end
		
		if (particle) then
			particle:SetVelocity(Ent:GetForward()*math.Rand(250,3000+(size*600)) + Vector(math.random(-(50+size*20),50+(size*20)),math.random(-(50+size*20),50+(size*20)),math.random(-(50+size*20),50+(size*20))))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.1+math.Rand(0,0.15)) 
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetStartSize(20+size*5) 
			particle:SetEndSize(0)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(255,150,75,math.random(150,255))
			particle:SetGravity( Vector(0,0,0) ) 
			particle:SetAirResistance(1500)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	end

	emitter:Finish()
		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end