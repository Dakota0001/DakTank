include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

function ENT:Think()
	if self:GetNWFloat("Caliber") >= 40 then
		if (self:GetNWBool("Firing")) == true and self:GetNWBool("Firing")~=self.LastFire then
			local pitch = math.random(0.95, 1.05)
			sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch")*pitch, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
			if self:GetNWFloat("Caliber") >= 75 then
				sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch")*pitch, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
			end
			if self:GetNWFloat("Caliber") >= 100 then
				sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch")*pitch, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
			end
			if self:GetNWFloat("Caliber") >= 150 then
				sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch")*pitch, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
			end
			if self:GetNWFloat("Caliber") >= 250 then
				sound.Play( self:GetNWString("FireSound"), LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, self:GetNWInt("FirePitch")*pitch, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1) )
			end
		end
		self.LastFire = self:GetNWBool("Firing")
	end
	if self:GetNWFloat("Caliber") >= 75 then
		if (self:GetNWBool("Exploding")) == true and self:GetNWBool("Exploding")~=self.LastExp then
			sound.Play( "daktanks/distexp1.mp3", LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000), 100, 100, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/(500*self:GetNWFloat("ExpDamage")) ),0,1) )
		end
		self.LastExp = self:GetNWBool("Exploding")
	end
end