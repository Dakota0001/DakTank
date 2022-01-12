include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

function ENT:Think()
	if self.Scaled == nil then self.Scaled = 0 end
	if self.CycleVal == nil then self.CycleVal = 0.05 end
	if self.LastFire2 == nil then self.LastFire2 = false end

	if self:GetModel() == "models/daktanks/mortar100mm2.mdl" or self:GetModel() == "models/daktanks/cannon100mm2.mdl" or self:GetModel() == "models/daktanks/shortcannon100mm2.mdl" or self:GetModel() == "models/daktanks/longcannon100mm2.mdl" or self:GetModel() == "models/daktanks/howitzer100mm2.mdl" or self:GetModel() == "models/daktanks/hmg100mm2.mdl" then
		if self:GetNWBool("Firing") == true and self:GetNWBool("Firing")~=self.LastFire2 then
			self:SetSequence( self:LookupSequence( "recoil" ) )
			self.CycleVal = 0.0
			self:SetCycle( self.CycleVal )
			timer.Destroy("RecoilTimer")
			timer.Create( "RecoilTimer"..self:EntIndex()..CurTime(), 0.01, 100, function()
				if self.CycleVal ~= nil then
					self.CycleVal = self.CycleVal + 0.025
					self:SetCycle( self.CycleVal )
				end
			end)
		end
		self.LastFire2 = self:GetNWBool("Firing")
	end
end