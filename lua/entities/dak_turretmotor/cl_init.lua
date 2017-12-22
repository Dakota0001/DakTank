include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

<<<<<<< HEAD:DTTanks/lua/entities/dak_temachinegun/cl_init.lua
function ENT:Think()
	if self:GetNWFloat("Caliber") >= 75 then
		if (self:GetNWBool("Firing")) == true and self:GetNWBool("Firing")~=self.LastFire then
			sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch"), math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
		end
		self.LastFire = self:GetNWBool("Firing")
	end
	if self:GetNWFloat("Caliber") >= 75 then
		if (self:GetNWBool("Exploding")) == true and self:GetNWBool("Exploding")~=self.LastExp then
			sound.Play( "daktanks/distexp1.wav", LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, 100, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/(500*self:GetNWFloat("ExpDamage")) ),0,1) )
		end
		self.LastExp = self:GetNWBool("Exploding")
	end
end
=======
>>>>>>> upstream/master:lua/entities/dak_turretmotor/cl_init.lua
