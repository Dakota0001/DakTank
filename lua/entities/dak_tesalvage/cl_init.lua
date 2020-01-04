include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

function ENT:Initialize()
	--if LocalPlayer():GetPos():Distance(self:GetPos()) > 3500 then
	--local ExpSounds = {"daktanks/distexp1.wav","daktanks/distexp2.wav","daktanks/distexp3.wav","daktanks/distexp4.wav","daktanks/distexp5.wav"}
	--sound.Play( ExpSounds[math.random(1,#ExpSounds)], LocalPlayer():GetPos(), 100, 100, math.Clamp(5000/LocalPlayer():GetPos():Distance(self:GetPos()),0,1) )		
	if LocalPlayer():GetPos():Distance(self:GetPos())>2500 then
		sound.Play( "daktanks/distexp1.mp3", LocalPlayer():GetPos(), 100, 100, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,0.1) )
	end
	--self:EmitSound( "daktanks/distexp1.wav", 180, 100, 1, 3)
	--print("yep here")
end