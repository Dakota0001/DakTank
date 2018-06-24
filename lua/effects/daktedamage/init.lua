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
	local Mult = Data:GetScale()
	local Target = Data:GetEntity()
	
	if ( Target == NULL ) then return end
	
	local RotationX = math.random(Target:OBBMins().x,Target:OBBMaxs().x)
	local RotationY = math.random(Target:OBBMins().y,Target:OBBMaxs().y)
	local RotationZ = math.random(Target:OBBMins().z,Target:OBBMaxs().z)
	local Rotation = Vector( RotationX, RotationZ, RotationZ )
	Rotation:Rotate( Target:GetAngles() )

	local Sparks = EffectData()
	Sparks:SetOrigin( Pos+Rotation )
	Sparks:SetMagnitude( math.Rand(0.1,0.5)*Mult )
	Sparks:SetRadius( math.Rand(0.8,1.2)*Mult )
	Sparks:SetScale( math.Rand(0.2,0.4)*Mult )
	util.Effect( "Sparks", Sparks )
	
	local Emitter = ParticleEmitter( Pos )
		
	for i = 1, math.Round(Mult) do
		
		RotationX = math.random(Target:OBBMins().x,Target:OBBMaxs().x)
		RotationY = math.random(Target:OBBMins().y,Target:OBBMaxs().y)
		RotationZ = math.random(Target:OBBMins().z,Target:OBBMaxs().z)
		Rotation = Vector( RotationX, RotationZ, RotationZ )
		Rotation:Rotate( Target:GetAngles() )
		
		local Particle = Emitter:Add( "dak/smokey", Pos+Rotation  )
		local VelocityX = math.random(-5*Mult,5*Mult)
		local VelocityY = math.random(-5*Mult,5*Mult)
		local VelocityZ = math.random(-5*Mult,5*Mult)
		local Color = math.random(50,100)
			
		Particle:SetVelocity( Vector(VelocityX,VelocityY,VelocityZ) )
		Particle:SetDieTime( 2.5 ) 
		Particle:SetStartAlpha( 75 )
		Particle:SetStartSize( Target:OBBMins():Length()/2 ) 
		Particle:SetEndSize( Target:OBBMins():Length() )
		Particle:SetRoll(math.Rand( 0, 360 ))
		Particle:SetColor( Color, Color, Color, 50 )
		Particle:SetGravity( Vector(0,0,math.random(5,50)) ) 
		Particle:SetAirResistance( 0.1 )
	end

	Emitter:Finish()

end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end