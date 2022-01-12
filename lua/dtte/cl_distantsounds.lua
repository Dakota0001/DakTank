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
	local SoundPos = LerpVector(0.4,PlayerPos,ExplosionPos)
	if Vol > 0.01 then
		timer.Simple(Dist / 18005, function()
			if Dist < 8192 then
				local LerpScale = math.min((Dist / 8192) * 1.5,1)
				sound.Play( ExplosionSound, LerpVector(LerpScale,ExplosionPos,SoundPos), math.min(110 + (ExplosionPower / 7),165), 100, Vol)
			else
				local LerpScale = math.min(Dist / 32768,0.5)
				sound.Play( ExplosionSound, LerpVector(LerpScale,SoundPos,PlayerPos), math.min(110 + (ExplosionPower / 7),165), 100, Vol)
			end

			if LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP then
				local Force = (ExplosionPower^1.2) / (Dist * 0.1)
				local Amp = (ExplosionPower / 10)
				if (Force * 10) > 5 then util.ScreenShake( ExplosionPos, Amp * 1.2, Amp * 0.74, (ExplosionPower * 0.6) * 0.015, ExplosionPower^1.35 ) end
			end
		end)
	end
end )

net.Receive( "daktankshotfired", function()
	local PlayerPos = LocalPlayer():EyePos()
	local GunPos = net.ReadVector()
	local Caliber = net.ReadFloat()
	local GunSound = net.ReadString()
	local Dist = PlayerPos:Distance(GunPos)
	local Vol = math.Clamp(math.pow( 0.5,PlayerPos:Distance(GunPos) / (Caliber * 250) ),0,1)
	local SoundPos = LerpVector(0.4,PlayerPos,GunPos)
	if Vol > 0.01 then
		timer.Simple(Dist / 18005, function()
			if Dist < 8192 then
				local LerpScale = math.min((Dist / 8192) * 1.5,1)
				sound.Play( GunSound, LerpVector(LerpScale,GunPos,SoundPos), math.min(90 + (Caliber / 3),165), 100 * math.Rand(0.95,1.05), Vol)
			else
				local LerpScale = math.min(Dist / 32768,0.5)
				sound.Play( GunSound, LerpVector(LerpScale,SoundPos,PlayerPos), math.min(90 + (Caliber / 3.5),165), 100 * math.Rand(0.95,1.05), Vol)
			end
			local Force = (35 * Caliber) / (Dist / 1.5)
			if LocalPlayer():GetMoveType() ~= MOVETYPE_NOCLIP and Force > 10 then
				util.ScreenShake( GunPos, Force / 10, Force / 2, math.min(Force / 80,0.6), Force * 2.5 )
			end
		end)
	end
end )
