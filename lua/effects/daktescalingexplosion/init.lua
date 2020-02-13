function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local size = data:GetScale()/78
	local emitter = ParticleEmitter( Pos )

	local dustsize = data:GetScale()/10
	if dustsize > 1 then
		local pregroundtrace = {}
			pregroundtrace.start = Pos
			pregroundtrace.endpos = Pos + Vector(0,0,-250)
			pregroundtrace.mask = MASK_SOLID_BRUSHONLY
		local groundtrace = util.TraceLine(pregroundtrace)
		local dusttime = dustsize*0.1
		if groundtrace.Hit then
			for i = 1,dustsize*1 do
				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*math.Rand(0,2.5)*math.cos(ang),dustsize*math.Rand(0,2.5)*math.sin(ang),dustsize*0.125)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-75))  end
				
				if (particle) then
					local power = math.Rand(0.75,1.25)
					particle:SetVelocity(Vector(0,0,power * dustsize))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.125*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*3*math.Rand(0.5,2))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,0) ) 
					particle:SetAirResistance(dustsize*100*power) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
			for i = 1,dustsize*1 do

				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*math.Rand(2.5,5)*math.cos(ang),dustsize*math.Rand(2.5,5)*math.sin(ang),dustsize*0.125)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-75))  end
				
				if (particle) then
					local power = math.Rand(0.75,1.25)
					particle:SetVelocity(Vector(0,0,power * dustsize))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.125*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*2.25*math.Rand(0.5,2))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,0) ) 
					particle:SetAirResistance(dustsize*100*power) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
			for i = 1,dustsize*1 do

				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*math.Rand(5,7.5)*math.cos(ang),dustsize*math.Rand(5,7.5)*math.sin(ang),dustsize*0.125)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-75))  end
				
				if (particle) then
					local power = math.Rand(0.75,1.25)
					particle:SetVelocity(Vector(0,0,power * dustsize))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.125*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*1.5*math.Rand(0.5,2))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,0) ) 
					particle:SetAirResistance(dustsize*100*power) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
			for i = 1,dustsize*1 do

				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*math.Rand(7.5,10)*math.cos(ang),dustsize*math.Rand(7.5,10)*math.sin(ang),dustsize*0.125)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-75))  end
				
				if (particle) then
					local power = math.Rand(0.75,1.25)
					particle:SetVelocity(Vector(0,0,power * dustsize))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.125*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*0.75*math.Rand(0.5,2))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,0) ) 
					particle:SetAirResistance(dustsize*100*power) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end

			for i = 1,dustsize*0.5 do
				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*3.5*math.cos(ang),dustsize*3.5*math.sin(ang),-25)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-25))  end
				
				if (particle) then
					particle:SetVelocity(Vector(0,0,math.Rand(dustsize*25,dustsize*50)))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.25*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*2.5*math.Rand(0.9,1.1))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,dustsize*35*1*math.Rand(0.9,1.1)) ) 
					particle:SetAirResistance(100*25*math.Rand(0.9,1.1)) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
			for i = 1,dustsize*0.5 do
				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*math.Rand(0,2.5)*math.cos(ang),dustsize*math.Rand(0,2.5)*math.sin(ang),-25)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-25))  end
				
				if (particle) then
					particle:SetVelocity(Vector(0,0,math.Rand(dustsize*25,dustsize*50)))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.25*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*2.5*math.Rand(0.9,1.1))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,dustsize*40*1*math.Rand(0.9,1.1)) ) 
					particle:SetAirResistance(100*25*math.Rand(0.9,1.1)) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
			for i = 1,dustsize*0.5 do
				local ang = math.Rand(0,360) * math.pi/180
				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(dustsize*math.Rand(0,1)*math.cos(ang),dustsize*math.Rand(0,1)*math.sin(ang),-25)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-25))  end
				
				if (particle) then
					particle:SetVelocity(Vector(0,0,math.Rand(dustsize*25,dustsize*50)))
					particle:SetLifeTime(0) 
					--particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetDieTime(dusttime)
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*0.25*math.Rand(0.5,2)) 
					particle:SetEndSize((dustsize)*1.75*math.Rand(0.9,1.1))
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(math.Rand(-0.5,0.5),0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,dustsize*15*1*math.Rand(0.75,1.25)) ) 
					particle:SetAirResistance(100*25*math.Rand(0.5,1.5)) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
		end
	end
	for i = 1,3.75*size do
		local ang = math.Rand(0,360) * math.pi/180




		local particle = emitter:Add( "dak/smokey", Pos + size*1*Vector(math.Rand(0,15)*math.cos(ang),math.Rand(0,15)*math.sin(ang),-math.random(-7.5,7.5)) ) 
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos + size*Vector(   math.random(0,0),math.random(0,0),math.random(0,0) ) ) end
		if (particle) then
			particle:SetVelocity(size*0.65*Vector(math.random(-30,30),math.random(-30,30),math.random(-20,20)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(5) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(size*7.5) 
			particle:SetEndSize(math.random(1,2)*size*7.5)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(40,60)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,50) ) 
			particle:SetAirResistance(math.random(0.9,1.1)*25)  
			particle:SetCollide(false)
			particle:SetBounce(100)
			particle:SetNextThink( 0 ) -- Makes sure the think hook is used on all particles of the particle emitter
		end
	end

	for i=1, size*2.5 do
	
		local Debris = emitter:Add( "effects/fleck_tile"..math.random(1,2), Pos )
		if (Debris) then
			Debris:SetVelocity (size*Vector(math.random(-250,250),math.random(-250,250),math.random(-250,250)))
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 0.5 , 1.5 ) )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 2 )
			Debris:SetEndSize( 2 )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )			
			Debris:SetAirResistance( 50 ) 			 
			Debris:SetGravity( Vector( 0, 0, math.Rand(-500, -250) ) ) 			
			Debris:SetColor( 50,50,50 )
		end
	end

	for i = 1,size*3.125 do
		local ang = math.Rand(0,360) * math.pi/180
		local particle = emitter:Add( "sprites/light_glow02_add.vmt", Pos + size*0.4*Vector(math.Rand(0,20)*math.cos(ang),math.Rand(0,20)*math.sin(ang),-math.random(-20,20)) ) 
		 
		if particle == nil then particle = emitter:Add( "sprites/light_glow02_add.vmt", Pos + size*Vector(   math.random(0,0),math.random(0,0),math.random(0,0) ) ) end
		
		if (particle) then
			particle:SetVelocity(size*Vector(math.random(-50,50),math.random(-50,50),math.random(-75,75)))
			particle:SetLifeTime(0.0) 
			particle:SetDieTime(0.15) 
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			local expsize = size*15*math.Rand(0.9,1.1)
			particle:SetStartSize(expsize) 
			particle:SetEndSize(expsize*0.5)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(255,150,75,math.random(150,255))
			particle:SetGravity( Vector(0,0,0) ) 
			particle:SetAirResistance(75)  
			particle:SetCollide(false)
			particle:SetBounce(1000)
		end
	end

	emitter:Finish()
		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end