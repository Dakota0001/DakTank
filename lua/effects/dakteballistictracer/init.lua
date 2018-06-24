EFFECT.Mat = Material( "trails/smoke" )

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

	for i = 1, math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20) do
		local particle = emitter:Add( "dak/smokey", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) 
		 
		if particle == nil then particle = emitter:Add( "dak/smokey", self.StartPos + self.Dir*math.Rand(0,self.Dist) ) end
		
		if (particle) then
			particle:SetVelocity(Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5)))
			particle:SetLifeTime(0) 
			particle:SetDieTime(1.0) 
			particle:SetStartAlpha(50)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1*math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20))
			particle:SetEndSize(3*math.Clamp(math.Round((self.Caliber/0.0393701)/10,0),1,20))
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
end

function EFFECT:Think()
	if ( CurTime() > self.DieTime ) then
		return false
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, self.Caliber, 1, 0, Color( 255,175,50, 100 ) )
end