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

function EFFECT:Init( Data )

	local Pos = Data:GetOrigin()
	local Ent = Data:GetEntity()
	local Size = Data:GetScale()
	
	if ( Ent == NULL ) then return end
	
	local Emitter = ParticleEmitter( Pos )
	
	for i = 1, 5 do

		local Particle = Emitter:Add( "dak/smokey", Pos )
		local VelocityX = math.random(-(150+Size*100),150+(Size*100))
		local VelocityY = math.random(-(150+Size*100),150+(Size*100))
		local VelocityZ = math.random(-(150+Size*100),150+(Size*100))
		
		Particle:SetVelocity( Ent:GetForward()*math.Rand(750,6000+(Size*1200)) + Vector(VelocityX,VelocityY,VelocityZ) )
		Particle:SetDieTime( math.Rand(Size/5, Size/5+0.5) )
		Particle:SetStartAlpha( 50 )
		Particle:SetStartSize( 15+Size ) 
		Particle:SetEndSize( (15+Size)*3 )
		Particle:SetRoll( math.Rand(0, 360) )
		Particle:SetColor( 150, 150, 150, 255 )
		Particle:SetAirResistance( 1500 ) 
	end

	for i = 1,25 do

		local Particle = Emitter:Add( "sprites/light_glow02_add.vmt", Pos + Ent:GetForward()*math.random( -0, 0 )) 
		local VelocityX = math.random(-(50+Size*20),50+(Size*20))
		local VelocityY = math.random(-(50+Size*20),50+(Size*20))
		local VelocityZ = math.random(-(50+Size*20),50+(Size*20))

		Particle:SetVelocity( Ent:GetForward()*math.Rand(250,3000+(Size*600)) + Vector(VelocityX,VelocityY,VelocityZ) )
		Particle:SetDieTime( math.Rand(0.1,0.25) )
		Particle:SetStartAlpha( 200 )
		Particle:SetStartSize( 20+Size*5 )
		Particle:SetRoll( math.Rand( 0, 360 ) )
		Particle:SetColor( 255, 150, 75, math.random(150,255) )
		Particle:SetAirResistance( 1500 )
	end

	Emitter:Finish()

end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end