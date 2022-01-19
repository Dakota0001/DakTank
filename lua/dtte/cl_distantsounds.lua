net.Receive( "daktankexplosion", function()
	local PlayerPos = LocalPlayer():EyePos()
	local ExplosionPos = net.ReadVector()
	local ExplosionPower = net.ReadFloat() * 0.5
	local ExplosionSound = net.ReadString() -- default sound is such a MASSIVE LET DOWN, so we're gonna use some extra stuff available ingame

	if ExplosionPower <= 75 then
		ExplosionSound = "daktanks/distexp1.mp3" -- WEAK
	elseif ExplosionPower <= 100 then
		ExplosionSound = "ambient/explosions/explode_1.wav"
	elseif ExplosionPower <= 150 then
		ExplosionSound = "ambient/explosions/explode_2.wav"
	elseif ExplosionPower <= 300 then
		ExplosionSound = "ambient/explosions/explode_5.wav"
	else
		ExplosionSound = "ambient/explosions/explode_6.wav"
	end

	local Dist = PlayerPos:Distance(ExplosionPos)
	local Vol = math.Clamp(math.pow( 0.5,PlayerPos:Distance(ExplosionPos) / (ExplosionPower * 50) ),0,1)
	if Vol > 0.01 then
		timer.Simple(Dist / 13503.9, function()

			local DistFresh = PlayerPos:Distance(ExplosionPos)
			local PlayerPosFresh = LocalPlayer():EyePos()
			local SoundDir = (ExplosionPos - PlayerPosFresh):GetNormalized()
			local SoundPos = PlayerPosFresh + (SoundDir * math.Clamp(DistFresh,0,4096))

			for i = 1,math.ceil(math.max(ExplosionPower / 80,1)) do
				sound.Play( ExplosionSound, SoundPos, math.min(110 + (ExplosionPower / 7),165), 100, Vol)
			end

			if LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then
				local Force = (ExplosionPower^1.2) / (DistFresh * 0.1)
				local Amp = (ExplosionPower / 10)
				if (Force * 10) > 5 then util.ScreenShake( ExplosionPos, Amp * 1.2, Amp * 0.74, (ExplosionPower * 0.6) * 0.015, ExplosionPower^1.35 ) end
			end
		end)
	end
end )

net.Receive( "daktankshotfired", function()
	local GunPos = net.ReadVector()
	local Caliber = net.ReadFloat()
	local GunSound = net.ReadString()
	local PlayerPos = LocalPlayer():EyePos()
	local Dist = PlayerPos:Distance(GunPos)
	local Vol = math.Clamp(math.pow( 0.5,PlayerPos:Distance(GunPos) / (Caliber * 250) ),0,1)

	if Vol > 0.01 then
		timer.Simple(Dist / 13503.9, function()

			local PlayerPosFresh = LocalPlayer():EyePos()
			local DistFresh = PlayerPosFresh:Distance(GunPos)
			local SoundDir = (GunPos - PlayerPosFresh):GetNormalized()
			local SoundPos = PlayerPosFresh + (SoundDir * math.Clamp(DistFresh,0,4096))

			for i = 1,math.ceil(math.max(Caliber / 75,1)) do
				sound.Play( GunSound, SoundPos, math.min(110 + (Caliber / 3),165), 100, Vol)
			end

			local Force = (35 * Caliber) / (DistFresh / 2)
			if LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP and Force > 10 then
				util.ScreenShake( GunPos, Force / 10, Force / 2, math.min(Force / 80,0.6), Force * 2.5 )
			end
		end)
	end
end )
