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
	
	if ( Ent == NULL ) then return end
	
	local Emitter = ParticleEmitter( Pos )
	
	local Velocity = Vector(Ent:GetRight()*math.random(-5,5) + Ent:GetForward()*math.random(0,25))
	local Particle = Emitter:Add( "dak/smokey", Pos )
	local Color = math.random(50,100)

	Particle:SetVelocity( Ent:GetUp()*math.random(-5,5) + Velocity )
	Particle:SetDieTime( 5 ) 
	Particle:SetStartAlpha( 75 )
	Particle:SetEndSize( 25 )
	Particle:SetRoll( math.Rand(0,360) )
	Particle:SetColor( Color,Color,Color,math.random(50,150) )
	Particle:SetGravity( Vector(0,0,math.random(5,25)) ) 
	Particle:SetAirResistance( 25 )  

	Emitter:Finish()

end

function EFFECT:Think()		
	return false
end

function EFFECT:Render()
end