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

	if size > 7.5 then
		local pregroundtrace = {}
			pregroundtrace.start = Pos + 2*(Ent:GetPos()-Pos)
			pregroundtrace.endpos = Pos + 2*(Ent:GetPos()-Pos) + Vector(0,0,-250)
			pregroundtrace.mask = MASK_SOLID_BRUSHONLY
		local groundtrace = util.TraceLine(pregroundtrace)
		

		if groundtrace.Hit then
			for i = 1,size*3 do
				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(0,size*15)*math.cos(ang),math.Rand(0,size*15)*math.sin(ang),0)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-size*10,size*10),math.Rand(-size*10,size*10),-25))  end
				
				if (particle) then
					local power = math.Rand(0.75,1.25)
					particle:SetVelocity(Vector(0,0,size*20*power))
					particle:SetLifeTime(0) 
					particle:SetDieTime(size*0.1)
					particle:SetStartAlpha(150)
					particle:SetEndAlpha(0)
					particle:SetStartSize(size*0.5*math.Rand(0.5,2)) 
					particle:SetEndSize((size)*5*math.Rand(0.5,2))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,0) ) 
					particle:SetAirResistance(size*100*power) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
		end
	end


	
	
	if not(Ent==NULL) then
		for i = 1,size do

			local particle = emitter:Add( "dak/smokey", Pos) 
			 
			if particle == nil then particle = emitter:Add( "dak/smokey", Pos)  end
			
			local strength = math.Rand(1,10)

			if (particle) then
				particle:SetVelocity(Ent:GetForward()*500*strength+Vector(math.Rand(-100,100)))
				particle:SetLifeTime(0) 
				particle:SetDieTime((size/50)+math.Rand(0,0.5))
				particle:SetStartAlpha(25)
				particle:SetEndAlpha(0)
				particle:SetStartSize((1.5*strength)+size)
				particle:SetEndSize(((1.5*strength)+size)*2)
				particle:SetAngles( Angle(0,0,0) )
				particle:SetAngleVelocity( Angle(0,0,0) ) 
				particle:SetRoll(math.Rand( 0, 360 ))
				particle:SetColor(math.random(250,250),math.random(250,250),math.random(250,250),math.random(25,25))
				particle:SetGravity( Vector(0,0,0) ) 
				particle:SetAirResistance(500) 
				particle:SetCollide(false)
				particle:SetBounce(0)
			end
		end
	end

	if not(Ent==NULL) then
		for i = 1,size do

			local particle = emitter:Add( "sprites/light_glow02_add.vmt", Pos + Ent:GetForward()*math.random( -0, 0 )) 
			 
			if particle == nil then particle = emitter:Add( "sprites/light_glow02_add.vmt", Pos + Ent:GetForward()*math.random( 0, 0 ))  end
			
			if (particle) then
				particle:SetVelocity(Ent:GetForward()*math.Rand(250,3000+(size*600)) + Vector(math.random(-(50+size*20),50+(size*20)),math.random(-(50+size*20),50+(size*20)),math.random(-(50+size*20),50+(size*20))))
				particle:SetLifeTime(0) 
				particle:SetDieTime(0.1+math.Rand(0,0.15)) 
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(0)
				particle:SetStartSize(20+size*12.5) 
				particle:SetEndSize(0)
				particle:SetAngles( Angle(0,0,0) )
				particle:SetAngleVelocity( Angle(0,0,0) ) 
				particle:SetRoll(math.Rand( 0, 360 ))
				particle:SetColor(255,150,75,math.random(150,255))
				particle:SetGravity( Vector(0,0,0) ) 
				particle:SetAirResistance(2500)  
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