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
	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Caliber = data:GetScale()*1

	self.Dir = (self.EndPos-self.StartPos):GetNormalized()
	self.Dist = self.EndPos:Distance(self.StartPos)

	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.DieTime = CurTime() + 0.25

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	local emitter = ParticleEmitter( self.StartPos )
	for i = 1, 10 do

		local particle = emitter:Add( "dak/flamelet5", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) 
		 
		if particle == nil then particle = emitter:Add( "dak/flamelet5", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.Rand(-250,250),math.Rand(-250,250),math.Rand(-250,250)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.5) 
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(0)
			particle:SetStartSize(15)
			particle:SetEndSize(0)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(255,255),math.random(255,255),math.random(255,255),math.random(255,255))
			particle:SetGravity( Vector(0,0,math.random(-5,-25)) )  
			particle:SetAirResistance(750)  
			particle:SetCollide(true)
			particle:SetBounce(0)
		end
	end

	for i = 1, 3 do

		local particle = emitter:Add( "dak/smokey", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) 
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.Rand(-25,25),math.Rand(-25,25),math.Rand(-25,25)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(2.0) 
			particle:SetStartAlpha(75)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(25)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(50,100)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,math.random(5,25)) ) 
			particle:SetAirResistance(20) 
			particle:SetCollide(true)
			particle:SetBounce(0)
		end
	end
	emitter:Finish()
--[[

	local Pos = data:GetOrigin()
	local Ent = data:GetEntity()

	local emitter = ParticleEmitter( Pos )
	
	if not(Ent==NULL) then
	for i = 1,1 do

		local particle = emitter:Add( "dak/smokey", Pos + Ent:GetForward()*math.random( -0, 0 ))  
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", Pos + Ent:GetForward()*math.random( -0, 0 )) end
		
		if (particle) then
			particle:SetVelocity(Ent:GetForward()*math.random( 5, 25 )+Vector(math.random(-25,25),math.random(-25,25),math.random(-25,25)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(5) 
			particle:SetStartAlpha(75)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0) 
			particle:SetEndSize(25)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(50,100)
			particle:SetColor(CVal,CVal,CVal,math.random(50,50))
			particle:SetGravity( Vector(0,0,math.random(5,25)) ) 
			particle:SetAirResistance(20)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	end

	if not(Ent==NULL) then
	for i = 1,1 do

		local particle = emitter:Add( "dak/flamelet5", Pos + Ent:GetForward()*math.random( -0, 0 )) 
		 
		if particle == nil then particle = emitter:Add( "dak/flamelet5", Pos + Ent:GetForward()*math.random( -0, 0 ))  end
		
		if (particle) then
			particle:SetVelocity(Vector(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(2.5) 
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(15) 
			particle:SetEndSize(10)
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			particle:SetColor(math.random(255,255),math.random(255,255),math.random(255,255),math.random(255,255))
			particle:SetGravity( Vector(0,0,math.random(-5,-25)) ) 
			particle:SetAirResistance(0.0)  
			particle:SetCollide(false)
			particle:SetBounce(0)
		end
	end
	end

	emitter:Finish()
	]]--
end

function EFFECT:Think()		
	if ( CurTime() > self.DieTime ) then
		return false
	end
	return true
end

function EFFECT:Render()
	--render.SetMaterial( self.Mat )
	--render.DrawBeam( self.StartPos, self.EndPos, self.Caliber, 1, 0, Color( 255,175,50, 255 ) )
end