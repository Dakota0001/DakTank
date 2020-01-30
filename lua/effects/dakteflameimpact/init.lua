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
	
	for i = 1,5 do

		local particle = emitter:Add( "dak/smokey", Pos)  
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos) end
		
		if (particle) then
			local ang = math.Rand(0,360) * math.pi/180
			particle:SetVelocity(Vector(750*math.Rand(0,1)*math.cos(ang),750*math.Rand(0,1)*math.sin(ang),math.Rand(150,250)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(5) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(50) 
			particle:SetEndSize(100)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(50,100)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,math.random(500,500)) ) 
			particle:SetAirResistance(150)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	local ScaleSize = 2
	for i = 1,50 do
		local ang = math.Rand(0,360) * math.pi/180
		local particle = emitter:Add( "dak/flamelet5", Pos)
		if particle == nil then particle = emitter:Add( "dak/flamelet5", Pos+Vector(25*math.Rand(0,1)*math.cos(ang),25*math.Rand(0,1)*math.sin(ang),math.random(-25,100)))  end
		
		if (particle) then
			local ang = math.Rand(0,360) * math.pi/180
			particle:SetVelocity(ScaleSize*Vector(500*math.Rand(0,1)*math.cos(ang),500*math.Rand(0,1)*math.sin(ang),math.Rand(-100,100)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(1) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(ScaleSize*15) 
			particle:SetEndSize(0)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(255,255),math.random(255,255),math.random(255,255),math.random(255,255))
			particle:SetGravity( ScaleSize*Vector(0,0,-600) ) 
			particle:SetAirResistance(ScaleSize*75)  
			particle:SetCollide(true)
			particle:SetBounce(0)
		end
	end
	for i = 1,50 do
		local ang = math.Rand(0,360) * math.pi/180
		local particle = emitter:Add( "dak/flamelet5", Pos)
		if particle == nil then particle = emitter:Add( "dak/flamelet5", Pos+Vector(25*math.Rand(0,1)*math.cos(ang),25*math.Rand(0,1)*math.sin(ang),math.random(-25,100)))  end
		
		if (particle) then
			local ang = math.Rand(0,360) * math.pi/180
			particle:SetVelocity(ScaleSize*Vector(200*math.Rand(0,1)*math.cos(ang),200*math.Rand(0,1)*math.sin(ang),math.Rand(-100,300)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(1) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(ScaleSize*15) 
			particle:SetEndSize(0)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(255,255),math.random(255,255),math.random(255,255),math.random(255,255))
			particle:SetGravity( ScaleSize*Vector(0,0,-600) ) 
			particle:SetAirResistance(ScaleSize*75)  
			particle:SetCollide(true)
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