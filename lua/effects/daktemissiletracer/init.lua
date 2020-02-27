EFFECT.Mat = Material( "trails/smoke" )

function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Caliber = data:GetScale()*1

	self.Dir = (self.EndPos-self.StartPos):GetNormalized()
	self.Dist = self.EndPos:Distance(self.StartPos)

	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.DieTime = CurTime() + 0.25
	self.Started = CurTime()

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	local emitter = ParticleEmitter( self.StartPos )

	for i = 1,10 do
		local frontmult = math.Rand(0,self.Dist)
		local particle = emitter:Add( "sprites/light_glow02_add.vmt", self.StartPos + self.Dir*frontmult) 
		 
		if particle == nil then particle = emitter:Add( "sprites/light_glow02_add.vmt", self.StartPos)  end
		
		if (particle) then
			--particle:SetVelocity(self.Dir*12600 + Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5)))
			particle:SetVelocity(self.Dir*math.Rand(5*self.Dist*0.95,5*self.Dist*1.05) + Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(0.25) 
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetStartSize(frontmult*0.005*math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20)) 
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

	for i = 1, math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20) do
		local particle = emitter:Add( "dak/smokey", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) 
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(2.0) 
			particle:SetStartAlpha(25)
			particle:SetEndAlpha(0)
			particle:SetStartSize(2*math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20))
			particle:SetEndSize(10*math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20))
			particle:SetAngles( Angle(0,0,0) )
			particle:SetAngleVelocity( Angle(0,0,0) ) 
			particle:SetRoll(math.Rand( 0, 360 ))
			local CVal = math.random(150,200)
			particle:SetColor(CVal,CVal,CVal,math.random(25,25))
			particle:SetGravity( Vector(0,0,math.random(5,25)) ) 
			particle:SetAirResistance(20) 
			particle:SetCollide(true)
			particle:SetBounce(0)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	if ( CurTime() > self.DieTime ) then
		return false
	end
	return true
end

function EFFECT:Render( )
	if CurTime()-self.Started < 0.1 then
		local model = {}
			model.model = "models/daktanks/test/lrmrocket.mdl"
			model.pos = self.StartPos + ((self.Dir*self.Dist)*((CurTime()-self.Started)/0.1)) + ((self.Dir*self.Dist)*0.5)
			model.angle = self.Dir:Angle()
		render.Model( model )
	end
end