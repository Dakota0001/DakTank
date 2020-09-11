function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local size = data:GetScale()*1.5
	local emitter = ParticleEmitter( Pos )
	local dustsize = data:GetScale()*0.25

	if dustsize > 0 then
		local pregroundtrace = {}
			pregroundtrace.start = Pos
			pregroundtrace.endpos = Pos + Vector(0,0,-25)
			pregroundtrace.mask = MASK_SOLID_BRUSHONLY
		local groundtrace = util.TraceLine(pregroundtrace)
		
		if groundtrace.Hit then
			for i = 1, 7 do

				local particle = emitter:Add( "effects/splash2.vtf", groundtrace.HitPos+Vector(math.Rand(-dustsize*1,dustsize*1),math.Rand(-dustsize*1,dustsize*1),0)) 
				 
				if particle == nil then particle = emitter:Add( "effects/splash2.vtf", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),-25))  end
				
				if (particle) then
					local ang = math.Rand(0,360) * math.pi/180
					particle:SetVelocity(Vector(dustsize*math.Rand(0,500)*math.cos(ang),dustsize*math.Rand(0,500)*math.sin(ang),math.Rand(dustsize*250,dustsize*1250)))
					particle:SetLifeTime(0) 
					particle:SetDieTime((dustsize/4)*math.Rand(0.5,1.5))
					particle:SetStartAlpha(100)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*5) 
					particle:SetEndSize((dustsize)*5)
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(0,0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(80,80),math.random(60,60),math.random(30,30),math.random(255,255))
					particle:SetGravity( Vector(0,0,-1000) ) 
					particle:SetAirResistance(2500) 
					particle:SetCollide(false)
					particle:SetBounce(0)

				end
			end
			for i = 1, 7 do

				local particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*1,dustsize*1),math.Rand(-dustsize*1,dustsize*1),-25)) 
				 
				if particle == nil then particle = emitter:Add( "dak/smokey", groundtrace.HitPos+Vector(math.Rand(-dustsize*10,dustsize*10),math.Rand(-dustsize*10,dustsize*10),0))  end
				
				if (particle) then
					local ang = math.Rand(0,360) * math.pi/180
					particle:SetVelocity(Vector(dustsize*math.Rand(0,50)*math.cos(ang),dustsize*math.Rand(0,50)*math.sin(ang),math.Rand(dustsize*250,dustsize*2500)))
					particle:SetLifeTime(0) 
					particle:SetDieTime((dustsize/5)+math.Rand(0,5))
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(0)
					particle:SetStartSize(dustsize*10) 
					particle:SetEndSize((dustsize)*50)
					particle:SetAngles( Angle(0,0,0) )
					particle:SetAngleVelocity( Angle(0,0,0) ) 
					particle:SetRoll(math.Rand( 0, 360 ))
					particle:SetColor(math.random(227,227),math.random(211,211),math.random(161,161),math.random(50,50))
					particle:SetGravity( Vector(0,0,-100) ) 
					particle:SetAirResistance(2500) 
					particle:SetCollide(false)
					particle:SetBounce(0)
				end
			end
		end
	end

	for i = 1,5 do
		local particle = emitter:Add( "effects/fire_cloud2.vtf", Pos+Vector(math.random(-size*0.1,size*0.1),math.random(-size*0.1,size*0.1),math.random(-size*0.1,size*0.1)))  
		if particle == nil then particle = emitter:Add( "effects/fire_cloud2.vtf", Pos) end
		if (particle) then
			particle:SetVelocity(Vector(math.random(-1*size,1*size),math.random(-1*size,1*size),math.random(-1*size,1*size)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.25) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0) 
			particle:SetEndSize(5+size*0.5)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(255,255)
			particle:SetColor(CVal,CVal,CVal,math.random(150,150))
			particle:SetGravity( Vector(0,0,math.random(5,10)) ) 
			particle:SetAirResistance(180)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	for i = 1,5 do
		local particle = emitter:Add( "dak/smokey", Pos+Vector(math.random(-size*0.1,size*0.1),math.random(-size*0.1,size*0.1),math.random(-size*0.1,size*0.1)))  
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos) end
		if (particle) then
			particle:SetVelocity(Vector(math.random(-1*size,1*size),math.random(-1*size,1*size),math.random(-1*size,1*size)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.25) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0) 
			particle:SetEndSize(5+size*0.5)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(50,100)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,math.random(5,10)) ) 
			particle:SetAirResistance(180)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	for i=1, size do
		local Debris = emitter:Add( "effects/fleck_tile"..math.random(1,2), Pos )
		if (Debris) then
			Debris:SetVelocity (Vector(math.random(-50*size,50*size),math.random(-50*size,50*size),math.random(-50*size,50*size)))
			Debris:SetLifeTime( 0 )
			Debris:SetDieTime( math.Rand( 0.5 , 1.5 ) )
			Debris:SetStartAlpha( 255 )
			Debris:SetEndAlpha( 0 )
			Debris:SetStartSize( 2 )
			Debris:SetEndSize( 2 )
			Debris:SetRoll( math.Rand(0, 360) )
			Debris:SetRollDelta( math.Rand(-3, 3) )			
			Debris:SetAirResistance( 240 ) 			 
			Debris:SetGravity( Vector( 0, 0, math.Rand(-350, -150) ) ) 			
			Debris:SetColor( 50,50,50 )
		end
	end

		
end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end