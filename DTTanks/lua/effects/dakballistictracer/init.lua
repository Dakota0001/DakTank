EFFECT.Mat = Material( "trails/smoke" )

function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.Caliber = data:GetScale()*1

	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.DieTime = CurTime() + 0.25

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

--[[
	local ent = data:GetEntity()
	local att = data:GetAttachment()

	if ( IsValid( ent ) && att > 0 ) then
		if ( ent.Owner == LocalPlayer() && !LocalPlayer():GetViewModel() != LocalPlayer() ) then ent = ent.Owner:GetViewModel() end

		local att = ent:GetAttachment( att )
		if ( att ) then
			self.StartPos = att.Pos
		end
	end

	

	
	self.TracerTime = math.min( 1, self.StartPos:Distance( self.EndPos ) / 10000 )
	self.Length = math.Rand( 0.1, 0.15 )

	-- Die when it reaches its target
	self.DieTime = CurTime() + self.TracerTime
]]--
end

function EFFECT:Think()
	if ( CurTime() > self.DieTime ) then
		return false
	end
	return true
end

function EFFECT:Render()
	render.SetMaterial( self.Mat )
	render.DrawBeam( self.StartPos, self.EndPos, self.Caliber, 1, 0, Color( 255,175,50, 255 ) )
end