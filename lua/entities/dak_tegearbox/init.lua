AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 25
ENT.DakHealth = 25
ENT.DakName = "Light Motor"
ENT.DakModel = "models/daktanks/engine1.mdl"
ENT.DakSpeed = 1.1725
ENT.DakMass = 1000
ENT.DakPooled=0
ENT.DakCrew = NULL
ENT.MaxHP = 0


function ENT:Initialize()
	--self:SetModel(self.DakModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakSpeed = 2
	local phys = self:GetPhysicsObject()
	if(phys:IsValid()) then
		phys:Wake()
	end
	self.Inputs = Wire_CreateInputs(self, { "Forward", "Reverse", "Left", "Right", "Brakes", "Activate", "LeftDriveWheel [ENTITY]" , "RightDriveWheel [ENTITY]", "CarTurning" })
	self.Soundtime = CurTime()
 	self.Perc = 0
 	self.TurnPerc = 0
 	self.YawAng = Angle(0,self:GetAngles().yaw,0)
 	self.LastYaw = self:GetAngles().yaw
 	self.Prev = {}
 	self.PrevPos = self:GetPos()
 	self.Time = CurTime()
 	self.TopSpeed = 1
 	self.RBoost = 1
 	self.LBoost = 1
 	self.Speed = 0
 	self.ExtraTorque = 1
 	self.Vel = 1
 	self.DakBurnStacks = 0
 	self.RPM = 0
 	self.turnperc = 0
 	self.SparkTime = CurTime()
 	self.MoveRightOld = 0
	self.MoveLeftOld = 0
	self.InertiaSet = 0
	self.LeftBrakesEnabled = 0
	self.RightBrakesEnabled = 0
end

function ENT:Think()
	if CurTime()>=self.SparkTime+0.33 then
		if self.DakHealth<=(self.DakMaxHealth*0.80) and self.DakHealth>(self.DakMaxHealth*0.60) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(1)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+3 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.4, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.60) and self.DakHealth>(self.DakMaxHealth*0.40) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(2)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+2 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.5, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.40) and self.DakHealth>(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(3)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+1 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.6, 6)
				self.Soundtime=CurTime()
			end
		end
		if self.DakHealth<=(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(4)
			util.Effect("daktedamage", effectdata)
			if CurTime()>=self.Soundtime+0.5 then
				--self:EmitSound( "daktanks/shock.wav", 60, math.Rand(60,150), 0.75, 6)
				self.Soundtime=CurTime()
			end
		end
		self.SparkTime=CurTime()
	end
	if self.DakName == "Micro Frontal Mount Gearbox" then
		self.DakMaxHealth = 15
		self.DakArmor = 15
		self.DakMass = 150
		self.DakModel = "models/daktanks/gearbox1f1.mdl"
		self.Torque = 1
		self.MaxHP = 150
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Small Frontal Mount Gearbox" then
		self.DakMaxHealth = 35
		self.DakArmor = 35
		self.DakMass = 350
		self.DakModel = "models/daktanks/gearbox1f2.mdl"
		self.Torque = 1
		self.MaxHP = 330
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Standard Frontal Mount Gearbox" then
		self.DakMaxHealth = 60
		self.DakArmor = 60
		self.DakMass = 625
		self.DakModel = "models/daktanks/gearbox1f3.mdl"
		self.Torque = 1
		self.MaxHP = 600
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Large Frontal Mount Gearbox" then
		self.DakMaxHealth = 95
		self.DakArmor = 95
		self.DakMass = 975
		self.DakModel = "models/daktanks/gearbox1f4.mdl"
		self.Torque = 1
		self.MaxHP = 930
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Huge Frontal Mount Gearbox" then
		self.DakMaxHealth = 140
		self.DakArmor = 140
		self.DakMass = 1400
		self.DakModel = "models/daktanks/gearbox1f5.mdl"
		self.Torque = 1
		self.MaxHP = 1350
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Ultra Frontal Mount Gearbox" then
		self.DakMaxHealth = 250
		self.DakArmor = 250
		self.DakMass = 2500
		self.DakModel = "models/daktanks/gearbox1f6.mdl"
		self.Torque = 1
		self.MaxHP = 2400
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Micro Rear Mount Gearbox" then
		self.DakMaxHealth = 15
		self.DakArmor = 15
		self.DakMass = 150
		self.DakModel = "models/daktanks/gearbox1r1.mdl"
		self.Torque = 1
		self.MaxHP = 150
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Small Rear Mount Gearbox" then
		self.DakMaxHealth = 35
		self.DakArmor = 35
		self.DakMass = 350
		self.DakModel = "models/daktanks/gearbox1r2.mdl"
		self.Torque = 1
		self.MaxHP = 330
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Standard Rear Mount Gearbox" then
		self.DakMaxHealth = 60
		self.DakArmor = 60
		self.DakMass = 625
		self.DakModel = "models/daktanks/gearbox1r3.mdl"
		self.Torque = 1
		self.MaxHP = 600
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Large Rear Mount Gearbox" then
		self.DakMaxHealth = 95
		self.DakArmor = 95
		self.DakMass = 975
		self.DakModel = "models/daktanks/gearbox1r4.mdl"
		self.Torque = 1
		self.MaxHP = 930
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Huge Rear Mount Gearbox" then
		self.DakMaxHealth = 140
		self.DakArmor = 140
		self.DakMass = 1400
		self.DakModel = "models/daktanks/gearbox1r5.mdl"
		self.Torque = 1
		self.MaxHP = 1350
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end
	if self.DakName == "Ultra Rear Mount Gearbox" then
		self.DakMaxHealth = 250
		self.DakArmor = 250
		self.DakMass = 2500
		self.DakModel = "models/daktanks/gearbox1r6.mdl"
		self.Torque = 1
		self.MaxHP = 2400
		--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
	end

	self.DakSpeed = 0
	self.DakFuel = 0
	self.DakFuelReq = 0
	self.DakHP = 0
	if self.DakTankCore then
		if #self.DakTankCore.Motors>0 then
			for i=1, #self.DakTankCore.Motors do
				if IsValid(self.DakTankCore.Motors[i]) then
					self.DakSpeed = self.DakSpeed + self.DakTankCore.Motors[i].DakSpeed
					self.DakFuelReq = self.DakFuelReq + self.DakTankCore.Motors[i].DakFuelReq
					self.DakHP = self.DakHP + self.DakTankCore.Motors[i].DakHP
				end
			end
		else
			self.DakHP = 0
		end
		if #self.DakTankCore.Fuel>0 then
			for i=1, #self.DakTankCore.Fuel do
				if self.DakFuel then
					if IsValid(self.DakTankCore.Fuel[i]) then
						self.DakFuel = self.DakFuel + self.DakTankCore.Fuel[i].DakFuel
					end
				end
			end
		else
			self.DakHP = 0
		end
	end

	self.DakSpeed = (self.DakSpeed * math.Clamp(self.DakFuel/self.DakFuelReq,0,1)) * math.Clamp(self.MaxHP/self.DakHP,0,1)

	if self.DakCrew == NULL then
		self.DakSpeed = self.DakSpeed * 0.6
	else
		if self.DakCrew.DakEntity ~= self then
			self.DakSpeed = self.DakSpeed * 0.6
		end
	end

	if self.DakHealth > self.DakMaxHealth then
		self.DakHealth = self.DakMaxHealth
	end
	if self:GetModel() ~= self.DakModel then
		self:SetModel(self.DakModel)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	end
	self:GetPhysicsObject():SetMass(self.DakMass)
	self.MoveForward = self.Inputs.Forward.Value
	self.MoveReverse = self.Inputs.Reverse.Value
	self.MoveLeft = self.Inputs.Left.Value
	self.MoveRight = self.Inputs.Right.Value
	self.Brakes = self.Inputs.Brakes.Value
	self.Active = self.Inputs.Activate.Value
	self.LeftDriveWheel = self.Inputs.LeftDriveWheel.Value
	self.RightDriveWheel = self.Inputs.RightDriveWheel.Value

	self.CarTurning = self.Inputs.CarTurning.Value
    
    if IsValid(self.DakTankCore) and IsValid(self.LeftDriveWheel) and IsValid(self.RightDriveWheel) and not(IsValid(self.LeftDriveWheel:GetParent())) and not(IsValid(self.RightDriveWheel:GetParent())) then
    	if self.setup == nil then
    		if self:GetParent():IsValid() then
    			if self:GetParent():GetParent():IsValid() then
		    		self.YawAng = Angle(0,self:GetParent():GetParent():GetAngles().yaw,0)
		 			self.LastYaw = self:GetParent():GetParent():GetAngles().yaw
		 			self.setup = 1
		 		end
		 	end
 		end

    	local LPhys = self.LeftDriveWheel:GetPhysicsObject()
    	local RPhys = self.RightDriveWheel:GetPhysicsObject()
    	local LPos = self:GetUp()*math.Clamp(self.LeftDriveWheel:OBBMaxs().z*2,1,60)
		local RPos = self:GetUp()*math.Clamp(self.RightDriveWheel:OBBMaxs().z*2,1,60)

    	if self.TotalMass then
	    	self.DakSpeed = self.DakSpeed*(10000/self.TotalMass)
	    	self.TopSpeed = (29.851*self.DakSpeed)
			if(self:GetParent():IsValid()) then
				if(self:GetParent():GetParent():IsValid()) then
					self.phy = self:GetParent():GetParent():GetPhysicsObject()
					self.base = self:GetParent():GetParent()
				end
			end
			if not(self:GetParent():IsValid()) then
				self.phy = self:GetPhysicsObject()
				self.base = self
			end
	        if (self.Active>0) then
	        	self.HPperTon = self.DakHP/(self.TotalMass/1000)
	        	if not(self.MoveForward>0) and not(self.MoveReverse>0) and not(self.MoveLeft>0) and not(self.MoveRight>0) then
					if self.RPM > 600 then
		        		self.RPM = self.RPM - 100
		        	end
		        	if self.RPM < 600 then
		        		self.RPM = 600
		        	end
		        else
		        	if self.MoveReverse>0 then
		        		self.RPM = 1000*math.Clamp(self.TopSpeed*0.5/(self.Speed*1.5),0.6,2.0)
		        		if self.Speed*1.5>self.TopSpeed then
			        		self.RPM = 2000*math.Clamp(self.Speed/self.TopSpeed*0.5,0.5,1)
			        	end
		        	else
			        	self.RPM = 1000*math.Clamp(self.TopSpeed/(self.Speed*1.5),0.6,2.0)
			        	if self.Speed*1.5>self.TopSpeed then
			        		self.RPM = 2000*math.Clamp(self.Speed/self.TopSpeed,0.5,1)
			        	end
			        end
	        	end
	        	if #self.DakTankCore.Motors>0 then
					for i=1, #self.DakTankCore.Motors do
						if IsValid(self.DakTankCore.Motors[i]) then
							self.DakTankCore.Motors[i].Sound:ChangeVolume( 1, 1 )
						end
					end
				end

	        	if self.Brakes>0 then
		        	if self.LeftBrakesEnabled == 0 then
		        		constraint.Weld( self.LeftDriveWheel, self.base, 0, 0, 0, false, false )
		        		self.LeftBrakesEnabled = 1
		        	end
		        	if self.RightBrakesEnabled == 0 then
		        		constraint.Weld( self.RightDriveWheel, self.base, 0, 0, 0, false, false )
		        		self.RightBrakesEnabled = 1
		        	end
		        	if #self.DakTankCore.Motors>0 then
						for i=1, #self.DakTankCore.Motors do
							if IsValid(self.DakTankCore.Motors[i]) then
								self.DakTankCore.Motors[i].Sound:ChangePitch( 255*self.RPM/2500, 0.5 )
							end
						end
					end
		        else
		        	if not(self.MoveForward>0) and not(self.MoveReverse>0) then
							self.Perc = 0
					end
					if not(self.MoveRight>0) and not(self.MoveLeft>0) then
						self.TurnPerc = 0
					end
					if self.MoveForward>0 then
		        			self.Perc = 1
					end
					if self.MoveReverse>0 then
		        			self.Perc = -1
		        			self.TopSpeed = self.TopSpeed/3
					end
						
					local ForwardVal = self:GetForward():Distance(self.phy:GetVelocity():GetNormalized()) --if it is below one you are going forward, if it is above one you are reversing
					if self.Speed < self.TopSpeed and math.abs(LPhys:GetAngleVelocity().y/6) < math.Clamp(1250*(self.Speed*1.5/self.TopSpeed),500,1000) and math.abs(RPhys:GetAngleVelocity().y/6) < math.Clamp(1250*(self.Speed*1.5/self.TopSpeed),500,1000) then			
						self.RBoost = 1
					 	self.LBoost = 1
					 		local Lmult = 1
							local Rmult = 1
						if RPhys:GetAngleVelocity().y == 0 or LPhys:GetAngleVelocity().y == 0 then
							Lmult = 1
							Rmult = 1
						else
							Lmult = math.abs(RPhys:GetAngleVelocity().y)/math.abs(LPhys:GetAngleVelocity().y)
							Rmult = math.abs(LPhys:GetAngleVelocity().y)/math.abs(RPhys:GetAngleVelocity().y)
						end
						if self.MoveRight==0 and self.MoveLeft==0 then
							if self.Speed > 0 then
								if self.Perc>=0 then
									if self.LastYaw-self.base:GetAngles().yaw > 0.1 then
										if Lmult<0.9 then
											self.LBoost = -1
										else
											self.LBoost = 0
										end
										self.RBoost = 1
									end
									if self.LastYaw-self.base:GetAngles().yaw < -0.1 then
										self.LBoost = 1
										if Rmult<0.9 then
											self.RBoost = -1
										else
											self.RBoost = 0
										end
									end
								else
									if self.LastYaw-self.base:GetAngles().yaw > 0.1 then
										self.LBoost = 1
										if Rmult<0.9 then
											self.RBoost = -1
										else
											self.RBoost = 0
										end
									end
									if self.LastYaw-self.base:GetAngles().yaw < -0.1 then
										if Lmult<0.9 then
											self.LBoost = -1
										else
											self.LBoost = 0
										end
										self.RBoost = 1
									end
								end
							else
								self.LBoost = 1
								self.RBoost = 1
							end
						else
							if self.CarTurning==0 then
								self.LBoost = 0
								self.RBoost = 0
								self.Perc=self.Perc*0.2
							else
								self.LBoost = 1
								self.RBoost = 1
							end
						end
						if self.MoveLeft==0 then
							if self.LeftBrakesEnabled == 1 then
				        		constraint.RemoveConstraints( self.LeftDriveWheel, "Weld" )
				        		self.LeftBrakesEnabled = 0
				        	end
				        end
				        if self.MoveRight==0 then
				        	if self.RightBrakesEnabled == 1 then
				        		constraint.RemoveConstraints( self.RightDriveWheel, "Weld" )
				        		self.RightBrakesEnabled = 0
				        	end
				        end

						local LeftVel = math.Clamp( (3000/(math.abs(LPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
						local RightVel = math.Clamp( (3000/(math.abs(RPhys:GetAngleVelocity().y)/6))-0.99,1,5 )

						

						if #self.DakTankCore.Motors>0 then
							for i=1, #self.DakTankCore.Motors do
								if IsValid(self.DakTankCore.Motors[i]) then
									self.DakTankCore.Motors[i].Sound:ChangePitch( 255*self.RPM/2500 , 0.5 )
								end
							end
						end
						
						--(self.DakHP/(4.8*math.pi)/(self.RightDriveWheel:OBBMaxs().z/12))/2.20462 = KG = how much it moves in a minute
						LPhys:ApplyTorqueCenter( self.LBoost*math.Clamp(Lmult,0.0,2)*-self:GetRight()*self.Perc*(LPhys:GetMass()/150)*self.HPperTon*math.Clamp(self.TopSpeed/(self.Speed*3),0,2)*450 )
						RPhys:ApplyTorqueCenter( self.RBoost*math.Clamp(Rmult,0.0,2)*-self:GetRight()*self.Perc*(RPhys:GetMass()/150)*self.HPperTon*math.Clamp(self.TopSpeed/(self.Speed*3),0,2)*450 )

					end
					if self.Speed > self.TopSpeed then
						if self.MoveForward>0 or self.MoveReverse>0 or self.MoveLeft>0 or self.MoveRight>0 then
							self.RPM = 2000 * self.Speed/self.TopSpeed
							if #self.DakTankCore.Motors>0 then
								for i=1, #self.DakTankCore.Motors do
									if IsValid(self.DakTankCore.Motors[i]) then
										self.DakTankCore.Motors[i].Sound:ChangePitch( math.Clamp(255*self.RPM/2500,0,255) , 0.5 )
									end
								end
							end
						end
					end

					if math.abs(LPhys:GetAngleVelocity().y/6) < 1500 and math.abs(RPhys:GetAngleVelocity().y/6) < 1500 then
						if self.CarTurning==0 then
							local TorqueBoost = 0.15*self.HPperTon 
							local LeftVel = math.Clamp( (3000/(math.abs(LPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
							local RightVel = math.Clamp( (3000/(math.abs(RPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
							if self.MoveLeft>0 or self.MoveRight>0 then
								if self.turnperc < 1 then
									self.turnperc = self.turnperc + 0.02
								end
								if self.MoveReverse > 0 then
									if self.MoveLeft>0 and self.MoveRight==0 then
										self.MoveRight = 1
										self.MoveLeft = 0
									elseif self.MoveRight>0 and self.MoveLeft==0 then
										self.MoveLeft = 1
										self.MoveRight = 0
									end
									self.Turn = -1
								else
									self.Turn = 1
								end
							else
								self.turnperc = 0
							end
							if self.MoveRightOld ~= self.MoveRight or self.MoveLeftOld ~= self.MoveLeft then
								self.turnperc = 0
							end
							self.MoveRightOld = self.MoveRight
							self.MoveLeftOld = self.MoveLeft
							if self.Speed > 10 then
								if #self.DakTankCore.Motors>0 then
									for i=1, #self.DakTankCore.Motors do
										if IsValid(self.DakTankCore.Motors[i]) then
											self.DakTankCore.Motors[i].Sound:ChangePitch( 255*self.RPM/2500 , 0.5 )
										end
									end
								end
								if self.MoveLeft>0 and self.MoveRight==0 then
									if self.MoveReverse>0 then 
										if self.RightBrakesEnabled == 0 then
											constraint.Weld( self.RightDriveWheel, self.base, 0, 0, 0, false, false )
											self.RightBrakesEnabled = 1
										end
										LPhys:ApplyTorqueCenter( self:GetRight()*(LPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth)*((self.TopSpeed - self.Speed)/self.TopSpeed) )
									else
										if self.LeftBrakesEnabled == 0 then
											constraint.Weld( self.LeftDriveWheel, self.base, 0, 0, 0, false, false )
											self.LeftBrakesEnabled = 1
										end
										RPhys:ApplyTorqueCenter( -self:GetRight()*(RPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth)*((self.TopSpeed - self.Speed)/self.TopSpeed) )
									end
								end
								if self.MoveRight>0 and self.MoveLeft==0 then
									if self.MoveReverse>0 then 
										if self.LeftBrakesEnabled == 0 then
											constraint.Weld( self.LeftDriveWheel, self.base, 0, 0, 0, false, false )
											self.LeftBrakesEnabled = 1
										end
										RPhys:ApplyTorqueCenter( self:GetRight()*(RPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth)*((self.TopSpeed - self.Speed)/self.TopSpeed) )
									else
										if self.RightBrakesEnabled == 0 then
											constraint.Weld( self.RightDriveWheel, self.base, 0, 0, 0, false, false )
											self.RightBrakesEnabled = 1
										end
										LPhys:ApplyTorqueCenter( -self:GetRight()*(LPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth)*((self.TopSpeed - self.Speed)/self.TopSpeed) )
									end
								end
							else
								if self.LeftBrakesEnabled == 1 then
					        		constraint.RemoveConstraints( self.LeftDriveWheel, "Weld" )
					        		self.LeftBrakesEnabled = 0
					        	end
					        	if self.RightBrakesEnabled == 1 then
					        		constraint.RemoveConstraints( self.RightDriveWheel, "Weld" )
					        		self.RightBrakesEnabled = 0
					        	end
					        	if self.MoveLeft>0 or self.MoveRight>0 then
									self.RPM = 1000*math.Clamp( 0.5*(self.HPperTon/13) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,2)
									if #self.DakTankCore.Motors>0 then
										for i=1, #self.DakTankCore.Motors do
											if IsValid(self.DakTankCore.Motors[i]) then
												self.DakTankCore.Motors[i].Sound:ChangePitch( 255*self.RPM/2500, 0.5 )
											end
										end
									end
								end

								if self.MoveReverse>0 then
									if self.MoveLeft>0 and self.MoveRight==0 then
										RPhys:ApplyTorqueCenter( self.Turn*self:GetRight()*(RPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
										LPhys:ApplyTorqueCenter( self.Turn*-self:GetRight()*(LPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
									end
									if self.MoveRight>0 and self.MoveLeft==0 then
										RPhys:ApplyTorqueCenter( self.Turn*-self:GetRight()*(RPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
										LPhys:ApplyTorqueCenter( self.Turn*self:GetRight()*(LPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
									end
								else
									if self.MoveLeft>0 and self.MoveRight==0 then
										RPhys:ApplyTorqueCenter( self.Turn*-self:GetRight()*(RPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
										LPhys:ApplyTorqueCenter( self.Turn*self:GetRight()*(LPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
									end
									if self.MoveRight>0 and self.MoveLeft==0 then
										RPhys:ApplyTorqueCenter( self.Turn*self:GetRight()*(RPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
										LPhys:ApplyTorqueCenter( self.Turn*-self:GetRight()*(LPhys:GetMass()/150)*10*math.Clamp( (0.13*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
									end
								end
							end
						end
					end

					if math.abs(LPhys:GetAngleVelocity().y/6) < 1250*(self.Speed*1.5/self.TopSpeed) and math.abs(RPhys:GetAngleVelocity().y/6) < 1250*(self.Speed*1.5/self.TopSpeed) then
						if not(self.MoveForward>0) and not(self.MoveReverse>0) and not(self.MoveLeft>0) and not(self.MoveRight>0) then
							self.Vel = ((self.phy:GetVelocity()*self:GetForward()).x+(self.phy:GetVelocity()*self:GetForward()).y)*100
							local TorqueBoost = math.Clamp(math.abs(self.Vel/1000),1,10)
							local LeftVel = math.Clamp( (3000/(math.abs(LPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
							local RightVel = math.Clamp( (3000/(math.abs(RPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
							local LForce = (self.DakHealth/self.DakMaxHealth)*1.5*75*(self.LeftDriveWheel:OBBMaxs().z/22.5)*1*self:GetForward()*TorqueBoost
							local RForce = (self.DakHealth/self.DakMaxHealth)*1.5*75*(self.RightDriveWheel:OBBMaxs().z/22.5)*1*self:GetForward()*TorqueBoost
							if self.Vel>0.1 then
								LPhys:ApplyForceOffset( -LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()+LPos)
								LPhys:ApplyForceOffset( LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()-LPos)
								RPhys:ApplyForceOffset( -RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()+RPos)
								RPhys:ApplyForceOffset( RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()-RPos)
							end
							if self.Vel<-0.1 then
								LPhys:ApplyForceOffset( LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()+LPos)
								LPhys:ApplyForceOffset( -LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()-LPos)
								RPhys:ApplyForceOffset( RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()+RPos)
								RPhys:ApplyForceOffset( -RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()-RPos)
							end
							if #self.DakTankCore.Motors>0 then
								for i=1, #self.DakTankCore.Motors do
									if IsValid(self.DakTankCore.Motors[i]) then
										self.DakTankCore.Motors[i].Sound:ChangePitch( 255*self.RPM/2500, 0.5 )
									end
								end
							end
						end
					end
					self.LastYaw = self.base:GetAngles().yaw
				end
	        else
	        	if self.RPM > 0 then
	        		self.RPM = self.RPM - 10
	        	end
	        	if math.abs(LPhys:GetAngleVelocity().y/6) < 1250*(self.Speed*1.5/self.TopSpeed) and math.abs(RPhys:GetAngleVelocity().y/6) < 1250*(self.Speed*1.5/self.TopSpeed) then
		        	self.Vel = ((self.phy:GetVelocity()*self:GetForward()).x+(self.phy:GetVelocity()*self:GetForward()).y)*100
		        	local TorqueBoost = math.Clamp(math.abs(self.Vel/1000),1,10)
		        	local LeftVel = math.Clamp( (3000/(math.abs(LPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
					local RightVel = math.Clamp( (3000/(math.abs(RPhys:GetAngleVelocity().y)/6))-0.99,1,5 )
					local LForce = (self.DakHealth/self.DakMaxHealth)*1.5*75*(self.LeftDriveWheel:OBBMaxs().z/22.5)*LeftVel*self:GetForward()*TorqueBoost
					local RForce = (self.DakHealth/self.DakMaxHealth)*1.5*75*(self.RightDriveWheel:OBBMaxs().z/22.5)*RightVel*self:GetForward()*TorqueBoost
					if self.Vel>0.1 then
						LPhys:ApplyForceOffset( -LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()+LPos)
						LPhys:ApplyForceOffset( LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()-LPos)
						RPhys:ApplyForceOffset( -RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()+RPos)
						RPhys:ApplyForceOffset( RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()-RPos)
					end
					if self.Vel<-0.1 then
						LPhys:ApplyForceOffset( LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()+LPos)
						LPhys:ApplyForceOffset( -LForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.LeftDriveWheel:GetPos()-LPos)
						RPhys:ApplyForceOffset( RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()+RPos)
						RPhys:ApplyForceOffset( -RForce / math.Clamp((self.DakBurnStacks/2.5),1,1000000), self.RightDriveWheel:GetPos()-RPos)
					end
				end
				if #self.DakTankCore.Motors>0 then
					for i=1, #self.DakTankCore.Motors do
						if IsValid(self.DakTankCore.Motors[i]) then
							self.DakTankCore.Motors[i].Sound:ChangeVolume( 0, 2 )
							self.DakTankCore.Motors[i].Sound:ChangePitch( 0, 2 )
						end
					end
				end
	        	self.LastYaw = self.base:GetAngles().yaw
	        end

	        if #self.Prev>=5 then 
	        	table.remove( self.Prev, 1 ) 
	        end
	        self.NewPos = self:GetPos()
	        self.Dist = self.NewPos:Distance(self.PrevPos)
	        self.PrevPos = self.NewPos

	        table.insert(self.Prev,1, ( (self.Dist/(CurTime()-self.Time))/(84480/1609) ) )
	        self.Time = CurTime()
	        if #self.Prev>=5 then 
	        	self.Speed = ((self.Prev[1]+self.Prev[2]+self.Prev[3]+self.Prev[4]+self.Prev[5])/5)*3.6*5
	        else
	        	self.Speed = 0
	        end
	    end
	else
		if self.LeftBrakesEnabled == 0 then
    		constraint.Weld( self.LeftDriveWheel, self.base, 0, 0, 0, false, false )
    		self.LeftBrakesEnabled = 1
    	end
    	if self.RightBrakesEnabled == 0 then
    		constraint.Weld( self.RightDriveWheel, self.base, 0, 0, 0, false, false )
    		self.RightBrakesEnabled = 1
    	end
    	if IsValid(self.DakTankCore) then
	    	if #self.DakTankCore.Motors>0 then
				for i=1, #self.DakTankCore.Motors do
					if IsValid(self.DakTankCore.Motors[i]) then
						self.DakTankCore.Motors[i].Sound:ChangePitch( 255*self.RPM/2500, 0 )
					end
				end
			end
		end
    end

    if self.DakBurnStacks>40 then
    	self.DakBurnStacks = 40
    end

    if self.DakBurnStacks>0 and not(self:IsOnFire()) then
    	self.DakBurnStacks = self.DakBurnStacks - 0.1
    end

    if self:IsOnFire() then
		self.DakHealth = self.DakHealth - self.DakMaxHealth*0.025*0.025
		if self.DakHealth <= 0 then
			local salvage = ents.Create( "dak_tesalvage" )
			salvage.DakModel = self:GetModel()
			salvage:SetPos( self:GetPos())
			salvage:SetAngles( self:GetAngles())
			salvage:Spawn()
			self:Remove()
		end
	end

    self:NextThink(CurTime()+0.025)
    return true
end

function ENT:PreEntityCopy()

	local info = {}
	local entids = {}

	info.CrewID = self.DakCrew:EntIndex()
	info.DakName = self.DakName
	info.DakMass = self.DakMass
	info.DakModel = self.DakModel
	info.DakMaxHealth = self.DakMaxHealth
	info.DakHealth = self.DakHealth

	duplicator.StoreEntityModifier( self, "DakTek", info )

	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
	
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		local Crew = CreatedEntities[ Ent.EntityMods.DakTek.CrewID ]
		if Crew and IsValid(Crew) then
			self.DakCrew = Crew
		end
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakModel = Ent.EntityMods.DakTek.DakModel
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakOwner = Player
		self.DakHealth = self.DakMaxHealth
		if not(Ent.EntityMods.DakTek.DakColor) then
		else
			self:SetColor(Ent.EntityMods.DakTek.DakColor)
		end

		--self:PhysicsDestroy()
		--self:SetModel(self.DakModel)
		--self:PhysicsInit(SOLID_VPHYSICS)
		--self:SetMoveType(MOVETYPE_VPHYSICS)
		--self:SetSolid(SOLID_VPHYSICS)

		self:Activate()

		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )

end