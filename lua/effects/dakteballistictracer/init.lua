EFFECT.Mat = Material( "trails/smoke" )

function EFFECT:Init( Data )

	self.StartPos = Data:GetStart()
	self.EndPos = Data:GetOrigin()
	self.Caliber = Data:GetScale()

	self.Dir = (self.EndPos-self.StartPos):GetNormalized()
	self.Dist = self.EndPos:Distance(self.StartPos)

	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.DieTime = CurTime() + 0.25

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	local Emitter = ParticleEmitter( self.StartPos )
	local Amount = math.Clamp(math.Round(self.Caliber/0.00393701),1,20) --Caliber / 0.0393701 / 10
	
	for i = 1, Amount do
		
		local Position = self.StartPos + self.Dir*math.Rand(0,self.Dist)
		local Velocity = Vector(math.Rand(-5,5),math.Rand(-5,5),math.Rand(-5,5))
		local Particle = Emitter:Add( "dak/smokey", Position )
		local Color = math.random(50,100)

		Particle:SetVelocity( Velocity )
		Particle:SetDieTime( 1.0 ) 
		Particle:SetStartAlpha( 50 )
		Particle:SetStartSize( Amount )
		Particle:SetEndSize( Amount * 3 )
		Particle:SetRoll( math.Rand(0, 360) )
		Particle:SetColor( Color, Color, Color, 50 )
		Particle:SetGravity( Vector(0,0,math.random(5,25)) ) 
		Particle:SetAirResistance( 20 ) 
		Particle:SetCollide( true )
	end
	
	Emitter:Finish()
	
end

function EFFECT:Think()
	return CurTime() <= self.DieTime
end

function EFFECT:Render()
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, self.Caliber, 1, 0, Color( 255,175,50, 100 ) )
end