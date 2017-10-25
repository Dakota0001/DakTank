AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakName = "Tank Core"
ENT.HitBox = {}
ENT.DakActive = 0
ENT.DakFuel = nil

function ENT:Initialize()
	self:SetModel( "models/bull/gates/logic.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakArmor = 10
	local phys = self:GetPhysicsObject()
	self.timer = CurTime()

	if(IsValid(phys)) then
		phys:Wake()
	end

	self.Outputs = WireLib.CreateOutputs( self, { "Health","HealthPercent" } )
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.DakActive = 0
	self.CurMass = 0
	self.LastCurMass = 0
	self.HitBox = {}
	self.HitBoxMass = 0
	self.Hitboxthinktime = CurTime()
	self.LastRemake = CurTime()
end

local function GetPhysCons( ent, Results )
	local Results = Results or {}
	if not IsValid( ent ) then return end
		if Results[ ent ] then return end
		Results[ ent ] = ent
		local Constraints = constraint.GetTable( ent )
		for k, v in ipairs( Constraints ) do
			if not (v.Type == "NoCollide") then
				for i, Ent in pairs( v.Entity ) do
					GetPhysCons( Ent.Entity, Results )
				end
			end
		end
	return Results
end

local function GetParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetParents(Parent, Results)
	end
	return Results
end

function ENT:Think()
	if not(self.Dead) then
		if not(self.DakMaxHealth) then
			self.DakMaxHealth = 10
		end
		if table.Count(self.HitBox)==0 then
			if self.DakHealth>self.DakMaxHealth then
				self.DakHealth = self.DakMaxHealth
			end
		end
		if not self:GetModel() == self.DakModel then
			self:SetModel(self.DakModel)
			self:PhysicsInit(SOLID_VPHYSICS)
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end
		
		self.Contraption = {}
		table.Add(self.Contraption,GetParents(self))
		for k, v in pairs(GetParents(self)) do
			table.Add(self.Contraption,GetPhysCons(v))
		end

		local Mass = 0

		for i=1, #self.Contraption do
			table.Add( self.Contraption, self.Contraption[i]:GetChildren() )
			table.Add( self.Contraption, self.Contraption[i]:GetParent() )
		end
		local Children = {}
		for i2=1, #self.Contraption do
			if table.Count(self.Contraption[i2]:GetChildren()) > 0 then
			table.Add( Children, self.Contraption[i2]:GetChildren() )
			end
		end
		table.Add( self.Contraption, Children )

		local hash = {}
		local res = {}
		for _,v in ipairs(self.Contraption) do
	   		if (not hash[v]) then
	    		res[#res+1] = v
	       		hash[v] = true
	   		end
		end
		self.Contraption=res
		self.Ammoboxes={}
		self.TurretControls={}
		self.Guns={}
		for i=1, #res do
			if res[i]:IsSolid() then
				if res[i]:GetClass()=="dak_tefuel" then
					self.DakFuel=res[i]
				end
				if res[i]:GetClass() == "dak_teammo" then
					self.Ammoboxes[#self.Ammoboxes+1] = res[i]
				end
				if res[i]:GetClass()=="dak_tegun" then
					res[i].DakTankCore = self
					self.Guns[#self.Guns+1] = res[i]
				end
				if res[i]:GetClass()=="dak_teautogun" then
					res[i].DakTankCore = self
					self.Guns[#self.Guns+1] = res[i]
				end
				if res[i]:GetClass()=="dak_temachinegun" then
					res[i].DakTankCore = self
					self.Guns[#self.Guns+1] = res[i]
				end
				if res[i]:GetClass()=="dak_turretcontrol" then
					res[i].DakContraption = res
					res[i].DakCore = self
				end
				Mass = Mass + res[i]:GetPhysicsObject():GetMass()
			end
		end
		if self.DakFuel then
			self.DakFuel.TotalMass = Mass
		end
		self.TotalMass = Mass

		if table.Count(self.HitBox) == 0 then
			WireLib.TriggerOutput(self, "Health", self.DakHealth)
			WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)
		end
		--SETUP HEALTHPOOL
		if table.Count(self.HitBox) == 0 and self.Contraption then
			if #self.Contraption>=1 then
				self.Remake = 0
				self.DakPooled = 1
				self.DakEngine = self
				self.Controller = self
				if #self.Contraption>0 then
					for i=1, #self.Contraption do
						if self.Contraption[i].Controller == nil or self.Contraption[i].Controller == NULL or self.Contraption[i].Controller == self then
							if IsValid(self.Contraption[i]) then
								if string.Explode("_",self.Contraption[i]:GetClass(),false)[1] ~= "dak" then
									if self.Contraption[i]:IsSolid() then
										self.HitBox[#self.HitBox+1] = self.Contraption[i]
										self.Contraption[i].Controller = self
										self.Contraption[i].DakPooled = 1
									end
								end
							end
						end
					end
				end
				self.HitBoxMass = 0
				for i=1, table.Count(self.HitBox) do
					self.HitBoxMass = self.HitBoxMass + self.HitBox[i]:GetPhysicsObject():GetMass()
				end
				self.CurrentHealth = self.HitBoxMass*0.01
				self.DakMaxHealth = self.HitBoxMass*0.01
				for i=1, table.Count(self.HitBox) do
					DakTekTankEditionSetupNewEnt(self.HitBox[i])
					self.HitBox[i].DakHealth = self.CurrentHealth
					self.HitBox[i].DakMaxHealth = self.CurrentHealth
					self.HitBox[i].Controller = self
					self.HitBox[i].DakPooled = 1
				end
				self.LastRemake = CurTime()
			end
		end
		if table.Count(self.HitBox)~=0 then
			self.DakActive = 1
		else
			self.DakActive = 0
		end

		if self.DakActive == 1 and table.Count(self.HitBox)~=0 and self.CurrentHealth then
			if table.Count(self.HitBox) > 0 then
				self.DamageCycle = 0
				if self.DakHealth < self.CurrentHealth then
					self.DamageCycle = self.DamageCycle+(self.CurrentHealth-self.DakHealth)
					self.DakLastDamagePos = self.DakLastDamagePos	
				end
				self.Remake = 0
				self.LastCurMass = self.CurMass
				self.CurMass = 0
				for i = 1, table.Count(self.HitBox) do
					if self.HitBox[i].Controller ~= self then
						self.Remake = 1	
					end
					if self.Remake == 1 then
						if self.HitBox[i].Controller == self then
							self.HitBox[i].DakPooled = 0
							self.HitBox[i].Controller = nil
						end
					end
					if self.LastCurMass>0 then
						if self.HitBox[i].DakHealth then
							if self.HitBox[i].DakHealth < self.CurrentHealth then
								self.DamageCycle = self.DamageCycle+(self.CurrentHealth-self.HitBox[i].DakHealth)
								self.DakLastDamagePos = self.HitBox[i].DakLastDamagePos	
							end
						end
					end
					if self.Remake == 1 then
						self.HitBox = {}
						self.Remake = 0
						break
					end
					if self.HitBox[i]~=NULL then
						if self.HitBox[i].Controller == self then
							if self.HitBox[i]:IsSolid() then
								self.CurMass = self.CurMass + self.HitBox[i]:GetPhysicsObject():GetMass()
							end
						end
					end
				end

				if not(self.CurMass>self.LastCurMass) then
					if self.DamageCycle>0 then
						if self.LastRemake+3 > CurTime() then
							self.DamageCycle = 0
						end
						self.CurrentHealth = self.CurrentHealth-self.DamageCycle
					end
				end
				for i = 1, table.Count(self.HitBox) do
					if self.CurrentHealth >= self.DakMaxHealth then
						self.DakMaxHealth = self.CurMass*0.01
						self.CurrentHealth = self.CurMass*0.01
						self.HitBox[i].DakMaxHealth = self.CurMass*0.01
						self.HitBox[i].DakRed = self.HitBox[i]:GetColor().r
						self.HitBox[i].DakGreen = self.HitBox[i]:GetColor().g
						self.HitBox[i].DakBlue = self.HitBox[i]:GetColor().b
					else
						local HPPerc = self.HitBox[i].DakHealth/self.HitBox[i].DakMaxHealth --get hp percent then set colors based on it
						self.HitBox[i]:SetColor(Color(self.HitBox[i].DakRed*HPPerc,self.HitBox[i].DakGreen*HPPerc,self.HitBox[i].DakBlue*HPPerc,self.HitBox[i]:GetColor().a))
					end
					self.HitBox[i].DakHealth = self.CurrentHealth
				end
				self.DakHealth = self.CurrentHealth
				
				WireLib.TriggerOutput(self, "Health", self.DakHealth)
				WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)
				if self.DakHealth then
					if self.DakHealth <= 0 then
						for i=1, #self.Contraption do
							if self.Contraption[i].DakPooled == 0 or self.Contraption[i]:GetParent()==self:GetParent() or self.Contraption[i].Controller == self then
								self.Contraption[i].DakLastDamagePos = self.DakLastDamagePos
								if self.Contraption[i] ~= self:GetParent():GetParent() and self.Contraption[i] ~= self:GetParent() and self.Contraption[i] ~= self then
									if math.random(1,6)>1 then
									self.salvage = ents.Create( "dak_tesalvage" )
									if ( !IsValid( self.salvage ) ) then return end
									self.salvage.DakModel = self.Contraption[i]:GetModel()
									self.salvage:SetPos( self.Contraption[i]:GetPos())
									self.salvage:SetAngles( self.Contraption[i]:GetAngles())
									self.salvage:Spawn()
									self.salvage:SetParent( self:GetParent():GetParent(), -1 )
									--self.salvage:PhysicsDestroy()
									else
										self.salvage = ents.Create( "dak_tesalvage" )
										if ( !IsValid( self.salvage ) ) then return end
										self.salvage.launch = 1
										self.salvage.DakModel = self.Contraption[i]:GetModel()
										self.salvage:SetPos( self.Contraption[i]:GetPos())
										self.salvage:SetAngles( self.Contraption[i]:GetAngles())
										self.salvage:Spawn()
									end
									if self.Contraption[i]:IsVehicle() then
										if IsValid(self.Contraption[i]:GetDriver()) then
											self.Contraption[i]:GetDriver():Kill()
										end
									end
									self.Contraption[i]:Remove()
								end
							end
						end
						self.Dead=1
						self.DeathTime=CurTime()
						local effectdata = EffectData()
						effectdata:SetOrigin(self:GetParent():GetParent():GetPos())
						effectdata:SetEntity(self)
						effectdata:SetAttachment(1)
						effectdata:SetMagnitude(.5)

						effectdata:SetScale(math.Clamp(self.DakMaxHealth,250,500))
						util.Effect("dakscalingexplosion", effectdata)
						

					end
				else
					self:Remove()
				end

			end
		end
	else
		if self.DeathTime then
			if self.DeathTime+30<CurTime() then
				if IsValid(self) then
					self:Remove()
				end
				if IsValid(self:GetParent():Remove()) then
					self:GetParent():Remove()
				end
				if IsValid(self:GetParent():GetParent():Remove()) then
					self:GetParent():GetParent():Remove()
				end
			end
		end
	end
	self:NextThink(CurTime()+1)
    return true
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}
	info.DakName = self.DakName
	info.DakHealth = self.DakHealth
	info.DakMaxHealth = self.DakBaseMaxHealth
	info.DakMass = self.DakMass
	info.DakOwner = self.DakOwner
	duplicator.StoreEntityModifier( self, "DakTek", info )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakOwner = Player
		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end

function ENT:OnRemove()
	if table.Count(self.HitBox)>0 then
		for i = 1, table.Count(self.HitBox) do
			self.HitBox[i].DakPooled = 0
			self.HitBox[i].DakController = nil
		end
	end
end