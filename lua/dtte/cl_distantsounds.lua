net.Receive( "daktankexplosion", function()
	local PlayerPos = LocalPlayer():GetPos()
	local ExplosionPos = net.ReadVector()
	local ExplosionPower = net.ReadFloat()*0.5
	local ExplosionSound = net.ReadString()
	local Dist = PlayerPos:Distance(ExplosionPos)
	local Vol = math.Clamp(math.pow( 0.5,PlayerPos:Distance(ExplosionPos)/(ExplosionPower*50) ),0,1)
	if Vol > 0.01 then
		timer.Simple(Dist/13503.9, function()
			local mult = math.Clamp(math.pow( 0.5,Dist/(ExplosionPower*250) ),0,1)
			sound.Play(  ExplosionSound, PlayerPos+((ExplosionPos-PlayerPos):GetNormalized()*1000), 100, 100, Vol )
			if LocalPlayer():GetMoveType()~=MOVETYPE_NOCLIP then
				util.ScreenShake( ExplosionPos, mult*5, 5, (ExplosionPower*0.8)*0.025, 5000000 )
			end
		end)
	end
end )

net.Receive( "daktankshotfired", function()

	local PlayerPos = LocalPlayer():GetPos()
	local GunPos = net.ReadVector()
	local Caliber = net.ReadFloat()
	local GunSound = net.ReadString()
	local Dist = PlayerPos:Distance(GunPos)
	local pitch = math.Rand(0.95, 1.05)
	local Vol = math.Clamp(math.pow( 0.5,PlayerPos:Distance(GunPos)/(7500) )*0.5,0,0.5)*(1+(math.Min((Caliber/200),1)*0.5))
	if Vol > 0.01 then
		timer.Simple(Dist/13503.9, function()
			local Dir = LocalPlayer():GetPos()+((GunPos-LocalPlayer():GetPos()):GetNormalized()*1000)
			sound.Play( GunSound, Dir, 100, 100*pitch, Vol )
			sound.Play( GunSound, Dir, 100, 100*pitch*0.8, Vol )
			--EmitSound( GunSound, Dir, -1, CHAN_STATIC, Vol, 100, 0, 100*pitch, 0 )
			--EmitSound( GunSound, Dir, -1, CHAN_STATIC, Vol, 100, 0, 100*pitch*0.8, 0 )
			if LocalPlayer():GetMoveType()~=MOVETYPE_NOCLIP then
				util.ScreenShake( GunPos, math.Clamp(math.pow( 0.5,LocalPlayer():GetPos():Distance(GunPos)/(50*Caliber) ),0,1) * 2.5, 2.5, Caliber/100, 5000000 )
			end
		end)
	end
end )