include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

function ENT:Think()
	if self.Scaled == nil then self.Scaled = 0 end
	if self.CycleVal == nil then self.CycleVal = 0.05 end
	if self.LastFire2 == nil then self.LastFire2 = false end
	local Caliber = self:GetNWFloat("Caliber")
	local Energy = self:GetNWFloat("Energy")

	if Caliber > 0 and self.Scaled == 0 then
		--self:PhysicsInit( SOLID_VPHYSICS )
		local mins, maxs = self:GetModelBounds()
		self:PhysicsInitBox( mins, maxs )
		self:SetSolidFlags( 0 )
		self.Scaled = 1
	end
	--self:SetSolid( SOLID_BBOX )
	--self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionBounds( self:GetRotatedAABB( self:GetModelBounds( 0, 0 ) ) )

	if self.Scaled == 1 then
		if self:GetPhysicsObject():IsValid() then
			self:GetPhysicsObject():SetPos(self:GetPos())
			self:GetPhysicsObject():SetAngles(self:GetAngles()+Angle(0,-90,0))
			self:GetPhysicsObject():EnableMotion( false )
		end
	end

	if self:GetModel() == "models/daktanks/mortar100mm2.mdl" then
		if self:GetNWBool("Firing") == true and self:GetNWBool("Firing")~=self.LastFire2 then
			self:SetSequence( self:LookupSequence( "recoil" ) )
			self.CycleVal = 0.05
			self:SetCycle( self.CycleVal )
			timer.Create( "RecoilTimer"..self:EntIndex()..CurTime(), 0.005, 200, function()
				if self.CycleVal ~= nil then
					self.CycleVal = self.CycleVal + 0.005
					self:SetCycle( self.CycleVal )
				end
			end)
		end
		self.LastFire2 = self:GetNWBool("Firing")
	end
	if (self:GetNWBool("Firing")) == true and self:GetNWBool("Firing")~=self.LastFire then
		local pitch = math.Rand(0.95, 1.05)
		local Dir = LocalPlayer():GetPos()+((self:GetPos()-LocalPlayer():GetPos()):GetNormalized()*1000)
		local Vol = math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/5000 ),0,1)
		--13503.9 speed of sound in inches
		timer.Simple(LocalPlayer():GetPos():Distance(self:GetPos())/13503.9, function()
			if self:IsValid() then
				sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
				if Energy >= 25000 then
					sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
				end
				if Energy >= 250000 then
					sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
				end
				if Energy >= 2500000 then
					sound.Play( self:GetNWString("FireSound"), Dir, 100, 100*pitch, Vol )
				end
			end
			local mult = math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(self:GetPos())/(0.1*Energy) ),0,1) * 2.5
			util.ScreenShake( self:GetPos(), mult * 2.5, 2.5, mult * 1, 5000000 )
		end)
	end
	self.LastFire = self:GetNWBool("Firing")
end