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
	self.TimeScale = (1/(1/engine.TickInterval()))
	self.TimeMult = (self.TimeScale/(1/66.66))
	--self:SetModel(self.DakModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakSpeed = 2
	--local phys = self:GetPhysicsObject()
	self.Inputs = Wire_CreateInputs(self, { "Forward", "Reverse", "Left", "Right", "Brakes", "Activate", "CarTurning", "ForwardFacingEntity [ENTITY]" })
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
	self.Gear = 0
	self.SideDist = self:GetSideDist()
 	self.TrackLength = self:GetTrackLength()
 	self.WheelsPerSide = self:GetWheelsPerSide()
 	self.RideHeight = self:GetRideHeight()
 	self.RideLimit = self:GetRideLimit()
	self.RightChanges = {}
	self.RightPosChanges = {}
	self.LeftChanges = {}
	self.LeftPosChanges = {}
	self.SlowThinkTime = CurTime()
	for i=1, self.WheelsPerSide do
		self.RightChanges[i] = 0
		self.LeftChanges[i] = 0
		self.RightPosChanges[i] = self:GetPos()
		self.LeftPosChanges[i] = self:GetPos()
	end
	self.LastWheelsPerSide = self.WheelsPerSide

	function self:SetupDataTables()
 		self:NetworkVar("Entity",0,"ForwardEnt")
 		self:NetworkVar("Entity",1,"Base")
 	end
 	self:SetNWEntity("ForwardEnt",self)
 	self:SetNWEntity("Base",self)
end

function ENT:Think()
	local self = self
	self.SideDist = self:GetSideDist()
 	self.TrackLength = self:GetTrackLength()
 	self.WheelsPerSide = self:GetWheelsPerSide()
 	self.RideHeight = self:GetRideHeight()
 	self.RideLimit = self:GetRideLimit()
 	self.FrontWheelRaise = self:GetFrontWheelRaise()
 	self.RearWheelRaise = self:GetRearWheelRaise()
 	self.ForwardOffset = self:GetForwardOffset()
	self.GearRatio = self:GetGearRatio()*0.01

	self.WheelHeight = self:GetWheelHeight()
 	self.FrontWheelHeight = self:GetFrontWheelHeight()
 	self.RearWheelHeight = self:GetRearWheelHeight()

 	if CurTime()>=self.SlowThinkTime+1 then
 		self.SlowThinkTime=CurTime()

 		if self.DakName == "Micro Frontal Mount Gearbox" then
			self.DakMaxHealth = 7.5
			self.DakArmor = 7.5
			self.DakMass = 80
			self.DakModel = "models/daktanks/gearbox1f1.mdl"
			self.Torque = 1
			self.MaxHP = 80
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Small Frontal Mount Gearbox" then
			self.DakMaxHealth = 25
			self.DakArmor = 25
			self.DakMass = 265
			self.DakModel = "models/daktanks/gearbox1f2.mdl"
			self.Torque = 1
			self.MaxHP = 250
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Standard Frontal Mount Gearbox" then
			self.DakMaxHealth = 60
			self.DakArmor = 60
			self.DakMass = 630
			self.DakModel = "models/daktanks/gearbox1f3.mdl"
			self.Torque = 1
			self.MaxHP = 600
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Large Frontal Mount Gearbox" then
			self.DakMaxHealth = 120
			self.DakArmor = 120
			self.DakMass = 1230
			self.DakModel = "models/daktanks/gearbox1f4.mdl"
			self.Torque = 1
			self.MaxHP = 1200
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Huge Frontal Mount Gearbox" then
			self.DakMaxHealth = 200
			self.DakArmor = 200
			self.DakMass = 2130
			self.DakModel = "models/daktanks/gearbox1f5.mdl"
			self.Torque = 1
			self.MaxHP = 2000
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Ultra Frontal Mount Gearbox" then
			self.DakMaxHealth = 480
			self.DakArmor = 480
			self.DakMass = 5050
			self.DakModel = "models/daktanks/gearbox1f6.mdl"
			self.Torque = 1
			self.MaxHP = 4800
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Micro Rear Mount Gearbox" then
			self.DakMaxHealth = 7.5
			self.DakArmor = 7.5
			self.DakMass = 80
			self.DakModel = "models/daktanks/gearbox1r1.mdl"
			self.Torque = 1
			self.MaxHP = 80
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Small Rear Mount Gearbox" then
			self.DakMaxHealth = 25
			self.DakArmor = 25
			self.DakMass = 265
			self.DakModel = "models/daktanks/gearbox1r2.mdl"
			self.Torque = 1
			self.MaxHP = 250
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Standard Rear Mount Gearbox" then
			self.DakMaxHealth = 60
			self.DakArmor = 60
			self.DakMass = 630
			self.DakModel = "models/daktanks/gearbox1r3.mdl"
			self.Torque = 1
			self.MaxHP = 600
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Large Rear Mount Gearbox" then
			self.DakMaxHealth = 120
			self.DakArmor = 120
			self.DakMass = 1230
			self.DakModel = "models/daktanks/gearbox1r4.mdl"
			self.Torque = 1
			self.MaxHP = 1200
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Huge Rear Mount Gearbox" then
			self.DakMaxHealth = 200
			self.DakArmor = 200
			self.DakMass = 2130
			self.DakModel = "models/daktanks/gearbox1r5.mdl"
			self.Torque = 1
			self.MaxHP = 2000
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
		if self.DakName == "Ultra Rear Mount Gearbox" then
			self.DakMaxHealth = 480
			self.DakArmor = 480
			self.DakMass = 5050
			self.DakModel = "models/daktanks/gearbox1r6.mdl"
			self.Torque = 1
			self.MaxHP = 4800
			--self.DakSound = "vehicles/apc/apc_cruise_loop3.wav"
		end
	end

	if CurTime()>=self.SparkTime+0.33 then
		if self.DakHealth<=(self.DakMaxHealth*0.80) and self.DakHealth>(self.DakMaxHealth*0.60) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(1)
			util.Effect("daktedamage", effectdata)
		end
		if self.DakHealth<=(self.DakMaxHealth*0.60) and self.DakHealth>(self.DakMaxHealth*0.40) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(2)
			util.Effect("daktedamage", effectdata)
		end
		if self.DakHealth<=(self.DakMaxHealth*0.40) and self.DakHealth>(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(3)
			util.Effect("daktedamage", effectdata)
		end
		if self.DakHealth<=(self.DakMaxHealth*0.20) then
			local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
			effectdata:SetEntity(self)
			effectdata:SetAttachment(1)
			effectdata:SetMagnitude(.5)
			effectdata:SetScale(4)
			util.Effect("daktedamage", effectdata)
		end
		self.SparkTime=CurTime()
	end
	if not(self.FirstCheck) and not(self.DakMaxHealth == 25) then
		self.FirstCheck = true
		self.DakHealth = self.DakMaxHealth
	end

	if IsValid(self.DakTankCore) and IsValid(self.DakTankCore.Motors[1]) then
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
			--self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end
		if self.AddonMass ~= nil then
			if self:GetPhysicsObject():GetMass() ~= self.DakMass+self.AddonMass then self:GetPhysicsObject():SetMass(self.DakMass+self.AddonMass) end
		end
		self.MoveForward = self.Inputs.Forward.Value
		self.MoveReverse = self.Inputs.Reverse.Value
		self.MoveLeft = self.Inputs.Left.Value
		self.MoveRight = self.Inputs.Right.Value
		self.Brakes = self.Inputs.Brakes.Value
		self.Active = self.Inputs.Activate.Value
		self.ForwardEnt = self.Inputs.ForwardFacingEntity.Value
		if self.ForwardEnt == nil or self.ForwardEnt == NULL then
			self.ForwardEnt = self
		end

		if self.ForwardEnt~=self.LastForwardEnt then
			self:SetNWEntity("ForwardEnt",self.ForwardEnt)
			self.LastForwardEnt = self.ForwardEnt
		end
		
		self.CarTurning = self.Inputs.CarTurning.Value

	    if IsValid(self.DakTankCore) then
	    	if self.setup == nil then
	    		if self:GetParent():IsValid() then
	    			if self:GetParent():GetParent():IsValid() then
			    		self.YawAng = Angle(0,self:GetParent():GetParent():GetAngles().yaw,0)
			 			self.LastYaw = self:GetParent():GetParent():GetAngles().yaw

			 			self:GetParent():GetParent():GetPhysicsObject():SetInertia( self:GetParent():GetParent():GetPhysicsObject():GetInertia()*(self.TotalMass/10000) )
			 			--print(self:GetParent():GetParent():GetPhysicsObject():GetInertia())

			 			self.setup = 1
			 		end
			 	end
	 		end

	    	if self.TotalMass then
	    		if self.AddonMass == nil then self.AddonMass = math.Round(self.TotalMass*0.1), self:GetPhysicsObject():SetMass(self:GetPhysicsObject():GetMass()+math.Round(self.TotalMass*0.1)) end
		    	self.DakSpeed = self.DakSpeed*(10000/self.TotalMass)
		    	self.TopSpeed = (29.851*self.DakSpeed)*self.GearRatio
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
				if self.base~=self.Lastbase then
					self:SetNWEntity("Base",self.base)
					self.Lastbase = self.base
				end
				self.HPperTon = self.DakHP/(self.TotalMass/1000)
		        if (self.Active>0) then
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
						self.Perc = 0
			        	--DO BRAKES BOTH
			        	self.RightBrake = 1
			        	self.LeftBrake = 1
			        	self.LeftForce = 0
			        	self.RightForce = 0
			        	if #self.DakTankCore.Motors>0 then
							for i=1, #self.DakTankCore.Motors do
								if IsValid(self.DakTankCore.Motors[i]) then
									self.DakTankCore.Motors[i].Sound:ChangePitch(math.Clamp( 255*self.RPM/2500,0,255), 0.5 )
								end
							end
						end
			        else
			        	if not(self.MoveForward>0) and not(self.MoveReverse>0) then
			        		if self.Perc > 0 then
								self.Perc = self.Perc - 0.1
							end
							if self.Perc < 0 then
								self.Perc = self.Perc + 0.1
							end
						end
						if not(self.MoveRight>0) and not(self.MoveLeft>0) then
							self.TurnPerc = 0
						end
						if self.MoveForward>0 then
							if self.Perc < 0 then
								self.Perc = 0
							end
							if self.Perc < 1 then
			        			self.Perc = self.Perc + 0.1
			        		end
						end
						if self.MoveReverse>0 then
							if self.Perc > 0 then
								self.Perc = 0
							end
		        			if self.Perc > -1 then
			        			self.Perc = self.Perc - 0.1
			        		end
		        			self.TopSpeed = self.TopSpeed/3
						end
							
						local ForwardVal = self.ForwardEnt:GetForward():Distance(self.phy:GetVelocity():GetNormalized()) --if it is below one you are going forward, if it is above one you are reversing
						if self.Speed < self.TopSpeed then			
							self.RBoost = 1
						 	self.LBoost = 1
								--TRACTION CONTROL
								--print(self.LastYaw-self.base:GetAngles().yaw)
							if self.MoveRight==0 and self.MoveLeft==0 then
								if self.Speed > 0 then
									if self.Perc>=0 then
										if self.LastYaw-self.base:GetAngles().yaw > 0.01 then
											self.LBoost = 0
											self.RBoost = 1
										end
										if self.LastYaw-self.base:GetAngles().yaw < -0.01 then
											self.LBoost = 1
											self.RBoost = 0
										end
									else
										if self.LastYaw-self.base:GetAngles().yaw > 0.01 then
											self.LBoost = 1
											self.RBoost = 0
										end
										if self.LastYaw-self.base:GetAngles().yaw < -0.01 then
											self.LBoost = 0
											self.RBoost = 1
										end
									end
								else
									self.LBoost = 1
									self.RBoost = 1
								end
							else
								if self.CarTurning==0 then
									self.LBoost = 1
									self.RBoost = 1
								else
									self.LBoost = 1
									self.RBoost = 1
								end
							end
							if self.CarTurning == 1 then
								--ENSURE BRAKES ARE OFF
								self.RightBrake = 0
			        			self.LeftBrake = 0
							else
								if self.MoveLeft==0 then
			        				self.LeftBrake = 0
						        end
						        if self.MoveRight==0 then
						        	self.RightBrake = 0
						        end
							end
							
							local GearBoost = 0
							self.CurTopSpeed = 0
							self.LastTopSpeed = 0
							self.MaxSpeedDif = 0

							local G1Speed = self.TopSpeed*0.15
							local G2Speed = self.TopSpeed*0.4
							local G3Speed = self.TopSpeed*0.75
							local G4Speed = self.TopSpeed

							self.LeftForce = 0
							self.RightForce = 0
							self.RightBrake = 0
			       			self.LeftBrake = 0
							if self.Speed < G1Speed then
								--self.Gear = 1
								GearBoost = math.Clamp(self.TopSpeed/(self.Speed*5.3),0,8*math.abs(self.Perc))
								self.CurTopSpeed = G1Speed
								self.LastTopSpeed = 0
								self.MaxSpeedDif = G1Speed
								self.LeftForce = (self.PhysicalMass/3000)*self.LBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								self.RightForce = (self.PhysicalMass/3000)*self.RBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								--LPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.LBoost*math.Clamp(Lmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*4),0,8*math.abs(self.Perc)) )
								--RPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.RBoost*math.Clamp(Rmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*4),0,8*math.abs(self.Perc)) )
							elseif self.Speed < G2Speed then
								--self.Gear = 2
								GearBoost = math.Clamp(self.TopSpeed/(self.Speed*5.5),0,4*math.abs(self.Perc))
								self.CurTopSpeed = G2Speed
								self.LastTopSpeed = G1Speed
								self.MaxSpeedDif = G2Speed - self.TopSpeed*0.1
								self.LeftForce = (self.PhysicalMass/3000)*self.LBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								self.RightForce = (self.PhysicalMass/3000)*self.RBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								--LPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.LBoost*math.Clamp(Lmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*5),0,4*math.abs(self.Perc)) )
								--RPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.RBoost*math.Clamp(Rmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*5),0,4*math.abs(self.Perc)) )
							elseif self.Speed < G3Speed then
								--self.Gear = 3
								GearBoost = math.Clamp(self.TopSpeed/(self.Speed*1.5),0,2*math.abs(self.Perc))
								self.CurTopSpeed = G3Speed
								self.LastTopSpeed = G2Speed
								self.MaxSpeedDif = G3Speed - G2Speed
								self.LeftForce = (self.PhysicalMass/3000)*self.LBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								self.RightForce = (self.PhysicalMass/3000)*self.RBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								--LPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.LBoost*math.Clamp(Lmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*2),0,2*math.abs(self.Perc)) )
								--RPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.RBoost*math.Clamp(Rmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*2),0,2*math.abs(self.Perc)) )
							else
								--self.Gear = 4
								GearBoost = math.Clamp(self.TopSpeed/(self.Speed*1.125),0,2*math.abs(self.Perc))
								self.CurTopSpeed = G4Speed
								self.LastTopSpeed = G3Speed
								self.MaxSpeedDif = G4Speed - G3Speed
								self.LeftForce = (self.PhysicalMass/3000)*self.LBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								self.RightForce = (self.PhysicalMass/3000)*self.RBoost*self.Perc*(1/self.GearRatio)*self.HPperTon*25*GearBoost
								--LPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.LBoost*math.Clamp(Lmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*1.5),0,1*math.abs(self.Perc)) )
								--RPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.RBoost*math.Clamp(Rmult,0.0,2)*-self:GetRight()*self.Perc*(1/self.GearRatio)*self.HPperTon*150*math.Clamp(self.TopSpeed/(self.Speed*1.5),0,1*math.abs(self.Perc)) )
							end

							
							local newspeed = self.phy:GetVelocity():Length()*(0.277778*0.254)

							--print(newspeed-self.Speed)

							if self.Speed > 0 and self.Speed < G1Speed and not(self.Gear == 1) then
								self.Gear = 1 
								if #self.DakTankCore.Motors>0 then
									for i=1, #self.DakTankCore.Motors do
										if IsValid(self.DakTankCore.Motors[i]) then
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 0.75 , 0 )
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 1 , 0.2 )
											self.DakTankCore.Motors[i].Sound:ChangePitch( 50 , 0.1 )
										end
									end
								end
							end
							if self.Speed > G1Speed and self.Speed < G2Speed and not(self.Gear == 2) then
								self.Gear = 2 
								if #self.DakTankCore.Motors>0 then
									for i=1, #self.DakTankCore.Motors do
										if IsValid(self.DakTankCore.Motors[i]) then
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 0.75 , 0 )
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 1 , 0.2 )
											self.DakTankCore.Motors[i].Sound:ChangePitch( 50 , 0.1 )
										end
									end
								end
							end
							if self.Speed > G2Speed and self.Speed < G3Speed and not(self.Gear == 3) then
								self.Gear = 3
								if #self.DakTankCore.Motors>0 then
									for i=1, #self.DakTankCore.Motors do
										if IsValid(self.DakTankCore.Motors[i]) then
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 0.75 , 0 )
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 1 , 0.2 )
											self.DakTankCore.Motors[i].Sound:ChangePitch( 50 , 0.1 )
										end
									end
								end
							end
							if self.Speed > G3Speed and self.Speed < G4Speed and not(self.Gear == 4) then
								self.Gear = 4
								if #self.DakTankCore.Motors>0 then
									for i=1, #self.DakTankCore.Motors do
										if IsValid(self.DakTankCore.Motors[i]) then
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 0.75 , 0 )
											self.DakTankCore.Motors[i].Sound:ChangeVolume( 1 , 0.2 )
											self.DakTankCore.Motors[i].Sound:ChangePitch( 50 , 0.1 )
										end
									end
								end
							end
							if self.MoveForward>0 or self.MoveReverse>0 or self.MoveLeft>0 or self.MoveRight>0 then
								if #self.DakTankCore.Motors>0 then
									for i=1, #self.DakTankCore.Motors do
										if IsValid(self.DakTankCore.Motors[i]) then
											self.DakTankCore.Motors[i].Sound:ChangePitch( math.Clamp(((self.Speed-self.LastTopSpeed)/self.MaxSpeedDif),0.7,1)*200 , 0.2 )
										end
									end
								end
							end
						end
						if self.Speed > self.TopSpeed then
							self.LeftForce = 0
							self.RightForce = 0
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


						if self.CarTurning==0 then
							local TorqueBoost = 0.15*self.HPperTon

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
								--[[
								if self.Perc>=0 then
									if self.LastYaw-self.base:GetAngles().yaw > 0.01 then
										self.LBoost = 0
										self.RBoost = 1
									end
									if self.LastYaw-self.base:GetAngles().yaw < -0.01 then
										self.LBoost = 1
										self.RBoost = 0
									end
								else
									if self.LastYaw-self.base:GetAngles().yaw > 0.01 then
										self.LBoost = 1
										self.RBoost = 0
									end
									if self.LastYaw-self.base:GetAngles().yaw < -0.01 then
										self.LBoost = 0
										self.RBoost = 1
									end
								end
								]]--

								if self.MoveLeft>0 and self.MoveRight==0 then
									if self.MoveReverse>0 then 
										self.RightForce = 0
										if math.abs(self.LastYaw-self.base:GetAngles().yaw)<1 then
											self.RightBrake = 1
										else
											self.RightBrake = 0
										end
										self.LeftForce = 0
			        					self.LeftBrake = 0
									else
										self.LeftForce = 0
										self.RightBrake = 0
										if math.abs(self.LastYaw-self.base:GetAngles().yaw)<1 then
											self.LeftBrake = 1
										else
											self.LeftBrake = 0
										end
										self.RightForce = 0
									end
								end
								if self.MoveRight>0 and self.MoveLeft==0 then
									if self.MoveReverse>0 then 
										self.LeftForce = 0
										self.RightBrake = 0
										if math.abs(self.LastYaw-self.base:GetAngles().yaw)<1 then
											self.LeftBrake = 1
										else
											self.LeftBrake = 0
										end
										self.RightForce = 0
									else
										self.RightForce = 0
										if math.abs(self.LastYaw-self.base:GetAngles().yaw)<1 then
											self.RightBrake = 1
										else
											self.RightBrake = 0
										end
										self.LeftForce = 0
			        					self.LeftBrake = 0
									end
								end
							else
					        	if self.MoveLeft>0 or self.MoveRight>0 then
									self.RPM = 1000*math.Clamp( 0.5*(self.HPperTon/13) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*10 ,0,2)
									if #self.DakTankCore.Motors>0 then
										for i=1, #self.DakTankCore.Motors do
											if IsValid(self.DakTankCore.Motors[i]) then
												self.DakTankCore.Motors[i].Sound:ChangePitch( math.Clamp( 255*self.RPM/2500,0,255), 0.5 )
											end
										end
									end
								end
								--OLD FORMULA
								--LPhys:ApplyTorqueCenter( (self.PhysicalMass/3000)*self.Turn*self:GetRight()*10*math.Clamp( (0.13*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw) ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) )
								
								if self.MoveReverse>0 then
									if self.MoveLeft>0 and self.MoveRight==0 then
										self.LeftForce = (self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										self.RightForce = -(self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										--RIGHT FORWARD
										--LEFT BACKWARD
									end
									if self.MoveRight>0 and self.MoveLeft==0 then
										self.LeftForce = -(self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										self.RightForce = (self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										--RIGHT BACKWARD
										--LEFT FORWARD
									end
								else
									if self.MoveLeft>0 and self.MoveRight==0 then
										self.LeftForce = -(self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										self.RightForce = (self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										--RIGHT BACKWARD
										--LEFT FORWARD
									end
									if self.MoveRight>0 and self.MoveLeft==0 then
										self.LeftForce = (self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										self.RightForce = -(self.PhysicalMass/3000)*(33/(1/engine.TickInterval()))*self.Turn*10*math.Clamp( (0.015*(1/self.GearRatio)*self.HPperTon) / math.abs(self.LastYaw-self.base:GetAngles().yaw)*1.75 ,0,10*self.turnperc)*450*(self.DakHealth/self.DakMaxHealth) 
										--RIGHT FORWARD
										--LEFT BACKWARD
									end
								end
							end
						end

						if not(self.MoveForward>0) and not(self.MoveReverse>0) and not(self.MoveLeft>0) and not(self.MoveRight>0) then
							--STANDARD BRAKING, NO FORCE APPLIED
							self.RightBrake = 0
			        		self.LeftBrake = 0
							if #self.DakTankCore.Motors>0 then
								for i=1, #self.DakTankCore.Motors do
									if IsValid(self.DakTankCore.Motors[i]) then
										self.DakTankCore.Motors[i].Sound:ChangePitch( 50, 0.5 )
									end
								end
							end
						end
						--self.LastYaw = self.base:GetAngles().yaw
					end
		        else
		        	self.LeftForce = 0
		        	self.RightForce = 0
		        	self.RightBrake = 1
			        self.LeftBrake = 1
		        	if self.RPM > 0 then
		        		self.RPM = self.RPM - 10
		        	end
		        	--STANDARD BRAKING, NO FORCE APPLIED
					if #self.DakTankCore.Motors>0 then
						for i=1, #self.DakTankCore.Motors do
							if IsValid(self.DakTankCore.Motors[i]) then
								self.DakTankCore.Motors[i].Sound:ChangeVolume( 0, 2 )
								self.DakTankCore.Motors[i].Sound:ChangePitch( 0, 2 )
							end
						end
					end
		        	--self.LastYaw = self.base:GetAngles().yaw
		        end

				local GravxTicks = physenv.GetGravity()*(1/66.66)
				
				local Pos
				local selfpos = self.base:GetPos()
				local trace = {}
				local CurTrace
				local RidePos
				local SuspensionForce
				local SuspensionAbsorb
				local lastchange
				local lastvel
				local AbsorbForce
				local AbsorbForceFinal
				local FrictionForce
				local FrictionForceFinal
				local lastvelnorm 
				local CurTraceDist
				local ForwardEnt = self.ForwardEnt
				local WheelsPerSide = self.WheelsPerSide--5
				local SuspensionForceMult = 1
				local TrackLength = self.TrackLength
				local ForwardOffset = self.ForwardOffset
				local RideLimit = self.RideLimit
				local RideHeight = self.RideHeight
				local FrontWheelRaise = self.FrontWheelRaise
				local RearWheelRaise = self.RearWheelRaise

				local forward = ForwardEnt:GetForward()
				local right = ForwardEnt:GetRight()
				local up = ForwardEnt:GetUp()
				--local selfpos = self:GetPos()
				local CurTraceHitPos
				local weightforce = self.PhysicalMass*-GravxTicks --note, raise tick interval if I increase interval
				local wheelforce = weightforce/((WheelsPerSide-2)*2)

				local wheelweightforce = Vector(0,0,(self.AddonMass/(WheelsPerSide*2))*-9.8*engine.TickInterval())
				if self.LastWheelsPerSide ~= WheelsPerSide then
			        for i=1, WheelsPerSide do
						self.RightChanges[i] = 0
						self.LeftChanges[i] = 0
						self.RightPosChanges[i] = selfpos
						self.LeftPosChanges[i] = selfpos
					end
				end
				local traceline = util.TraceLine
				local TickInt = (1/66.66)
				local clamp = math.Clamp
				local abs = math.abs
				local max = math.Max
				if self.RightGroundedLast == nil then self.RightGroundedLast = WheelsPerSide end
				if self.LeftGroundedLast == nil then self.LeftGroundedLast = WheelsPerSide end
				local CurRideHeight = 0
				local RightGrounded = 0
				local LeftGrounded = 0
				local BrakeMult = 0
				--Right side
				for i=1, WheelsPerSide do
					Pos = selfpos + (forward*(((i-1)*TrackLength/(WheelsPerSide-1)) - (TrackLength*0.5) + (ForwardOffset))) + (right*self.SideDist)
					if i==WheelsPerSide then 
						CurRideHeight = RideHeight - FrontWheelRaise
					elseif i==1 then
						CurRideHeight = RideHeight - RearWheelRaise
					else
						CurRideHeight = RideHeight
					end
					trace = {
						start = Pos + up*(-CurRideHeight+100),
						endpos = Pos + up*-CurRideHeight,
						mask = MASK_SOLID_BRUSHONLY
					}
					CurTrace = traceline( trace )
					CurTraceHitPos = CurTrace.HitPos
					CurTraceDist = (CurTrace.StartPos-(CurTraceHitPos)):Length()
					lastchange = (CurTraceDist-self.RightChanges[i])/TickInt
					self.RightChanges[i] = CurTraceDist
					lastvel = CurTraceHitPos - self.RightPosChanges[i]
					lastvel = -ForwardEnt:GetPos()+ForwardEnt:LocalToWorld(Vector(math.max(self.RightBrake,0.0),1,0)*ForwardEnt:WorldToLocal(ForwardEnt:GetPos()+lastvel))
					self.RightPosChanges[i] = CurTraceHitPos
					RidePos = (CurTraceDist - 100)
					if RidePos<-0.1 then
						AbsorbForce = 0.2 *(5/WheelsPerSide)
						FrictionForce = 2*(self.PhysicalMass*-GravxTicks).z * 0.9/(WheelsPerSide*2)
					else
						AbsorbForce = 0.0
						FrictionForce = 0
					end
					SuspensionForce = ((500*(100/RideLimit))*Vector(0,0,1)*math.abs(RidePos)) + wheelweightforce
					AbsorbForceFinal = (-Vector(0,0,self.PhysicalMass*lastchange/(WheelsPerSide*2)) * AbsorbForce)
					lastvelnorm = lastvel:GetNormalized()--*(Vector(1-forward.x,1-forward.y,1-forward.z)) + forward*self.RightBrake
					FrictionForceFinal = -Vector(clamp(lastvel.x,-abs(lastvelnorm.x),abs(lastvelnorm.x)),clamp(lastvel.y,-abs(lastvelnorm.y),abs(lastvelnorm.y)),0)*FrictionForce
					--print(FrictionForceFinal) ----------FIX ISSUE WHERE THIS SPERGS OUT AND GETS BIG FOR NO RAISIN
					self.phy:ApplyForceOffset( self.TimeMult*((forward*Vector(1,1,0))*4*self.RightForce/WheelsPerSide+SuspensionForce+Vector(FrictionForceFinal.x,FrictionForceFinal.y,max(0,AbsorbForceFinal.z))) ,Pos)
				end

				--Left side
				for i=1, WheelsPerSide do
					Pos = selfpos + (forward*(((i-1)*TrackLength/(WheelsPerSide-1)) - (TrackLength*0.5) + (ForwardOffset))) - (right*self.SideDist)
					if i==WheelsPerSide then 
						CurRideHeight = RideHeight - FrontWheelRaise
					elseif i==1 then
						CurRideHeight = RideHeight - RearWheelRaise
					else
						CurRideHeight = RideHeight
					end

					trace = {
						start = Pos + up*(-CurRideHeight+100),
						endpos = Pos + up*-CurRideHeight,
						mask = MASK_SOLID_BRUSHONLY
					}
					CurTrace = traceline( trace )
					CurTraceHitPos = CurTrace.HitPos
					CurTraceDist = (CurTrace.StartPos-(CurTraceHitPos)):Length()
					lastchange = (CurTraceDist-self.LeftChanges[i])/TickInt
					self.LeftChanges[i] = CurTraceDist
					lastvel = CurTraceHitPos - self.LeftPosChanges[i]
					lastvel = -ForwardEnt:GetPos()+ForwardEnt:LocalToWorld(Vector(math.max(self.LeftBrake,0.0),1,0)*ForwardEnt:WorldToLocal(ForwardEnt:GetPos()+lastvel))
					self.LeftPosChanges[i] = CurTraceHitPos
					RidePos = (CurTraceDist - 100)

					if RidePos<-0.1 then
						AbsorbForce = 0.2 *(5/WheelsPerSide)
						FrictionForce = 2*(self.PhysicalMass*-GravxTicks).z * 0.9/(WheelsPerSide*2)
					else
						AbsorbForce = 0.0
						FrictionForce = 0
					end
					SuspensionForce = ((500*(100/RideLimit))*Vector(0,0,1)*math.abs(RidePos)) + wheelweightforce

					AbsorbForceFinal = (-Vector(0,0,self.PhysicalMass*lastchange/(WheelsPerSide*2)) * AbsorbForce)
					lastvelnorm = lastvel:GetNormalized() --*(Vector(1-forward.x,1-forward.y,1-forward.z)) + forward*self.RightBrake
					FrictionForceFinal = -Vector(clamp(lastvel.x,-abs(lastvelnorm.x),abs(lastvelnorm.x)),clamp(lastvel.y,-abs(lastvelnorm.y),abs(lastvelnorm.y)),0)*FrictionForce
					self.phy:ApplyForceOffset( self.TimeMult*((forward*Vector(1,1,0))*4*self.LeftForce/WheelsPerSide+SuspensionForce+Vector(FrictionForceFinal.x,FrictionForceFinal.y,max(0,AbsorbForceFinal.z))) ,Pos)
				end
				
				self.LastWheelsPerSide = WheelsPerSide

		        self.Speed = Vector(0,0,0):Distance(self.phy:GetVelocity())*(0.277778*0.254)
		    end
		    self.LastYaw = self:GetParent():GetParent():GetAngles().yaw
		else
			--NO TANKCORE, INACTIVE
	    end

	    if self.DakBurnStacks>40 then
	    	self.DakBurnStacks = 40
	    end

	    if self.DakBurnStacks>0 and not(self:IsOnFire()) then
	    	self.DakBurnStacks = self.DakBurnStacks - 0.1
	    end

	    if self:IsOnFire() then
			self.DakHealth = self.DakHealth - self.DakMaxHealth*0.1*0.025
			if self.DakHealth <= 0 then
				local salvage = ents.Create( "dak_tesalvage" )
				salvage.DakModel = self:GetModel()
				salvage:SetPos( self:GetPos())
				salvage:SetAngles( self:GetAngles())
				salvage:Spawn()
				self:Remove()
			end
		end
	end
	--print(self.TimeScale)
    self:NextThink(CurTime())
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