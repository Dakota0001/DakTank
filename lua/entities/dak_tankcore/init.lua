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
	self.DakBurnStacks = 0
	self.SpawnTime = CurTime()
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
--[[
local function GetPhysCons( Ent, Table )
    if not IsValid( Ent ) then return end

    local Table = Table or {[Ent] = true}
            if Table[Ent] then return end

    for _, V in ipairs( constraint.GetTable(Ent) ) do
        if V.Type ~= "NoCollide" then
            for _, Ent in pairs(V.Entity) do
                GetPhysCons(Ent.Entity, Table)
            end
        end
    end

    return Table
end
]]--

local function GetParents( ent, Results )
	local Results = Results or {}
	local Parent = ent:GetParent()
	Results[ ent ] = ent
	if IsValid(Parent) then
		GetParents(Parent, Results)
	end
	return Results
end
--[[
local function GetParents(Ent)
    if not IsValid(Ent) then return end
    
    local Table  = {[Ent] = true}
    local Parent = Ent:GetParent()

    while IsValid(Parent:GetParent()) do
        Table[Parent] = true
        Parent = Parent:GetParent()
    end

    return Table
end
]]--

local function GetPhysicalConstraints( Ent, Table )
    if not IsValid( Ent ) then return end

    local Table = Table or {}
            if Table[Ent] then return end
            Table[Ent] = true
    for _, V in ipairs( constraint.GetTable(Ent) ) do
        if V.Type ~= "NoCollide" then
            for _, Ent in pairs(V.Entity) do
                GetPhysicalConstraints(Ent.Entity, Table)
            end
        end
    end

    return Table
end

--[[
local function GetContraption(Ent)
    if not IsValid(Ent) then return {} end

    -- Get our ancestor (Move to top of tree)
    local Root = Ent
    while IsValid(Root:GetParent()) do Root = Root:GetParent() end

    -- Get everything constrained to it (Spread horizontally on tree)
    local Entities = GetPhysicalConstraints(Root)
    PrintTable(Entities)

    -- Get all children (Move down all branches of tree)
    local Children = {}

    for Entity in pairs(Entities) do
        for Child in pairs(Entity:GetChildren()) do
            Children[Child] = true
        end
    end

    table.Add(Entities, Children)
    PrintTable(Children)
    PrintTable(Entities)
    return Entities --Mass
end
]]--
function ENT:Think()
	if IsValid(self) then
		if IsValid(self:GetParent()) then
			if IsValid(self:GetParent():GetParent()) then
				self.Base = self:GetParent():GetParent()
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
					local ParentMass = 0
					local SA = 0

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
					
					--self.Contraption = GetContraption(self)

					self.Ammoboxes={}
					self.TurretControls={}
					self.Guns={}
					self.Crew={}
					self.Motors={}
					self.Fuel={}
					self.Tread={}
					for i=1, #res do
						if res[i]:IsSolid() then
							if res[i]:GetClass()=="dak_tegearbox" then
								res[i].DakTankCore = self
								self.Gearbox = res[i]
							end
							if res[i]:GetClass()=="dak_tefuel" then
								self.Fuel[#self.Fuel+1] = res[i]
							end
							if res[i]:GetClass()=="dak_temotor" then
								self.Motors[#self.Motors+1] = res[i]
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
								self.TurretControls[#self.TurretControls+1]=res[i]
								res[i].DakContraption = res
								res[i].DakCore = self
							end
							if res[i]:GetClass()=="dak_crew" then
								self.Crew[#self.Crew+1]=res[i]
							end
							Mass = Mass + res[i]:GetPhysicsObject():GetMass()
							if IsValid(res[i]:GetParent()) then
								ParentMass = ParentMass + res[i]:GetPhysicsObject():GetMass()
							end
							if res[i]:GetPhysicsObject():GetSurfaceArea() then
								if res[i]:GetPhysicsObject():GetMass()>1 then
									SA = SA + res[i]:GetPhysicsObject():GetSurfaceArea()
								end
							else
								self.Tread[#self.Tread+1]=res[i]
							end
						end
					end
					if self.Gearbox then
						self.Gearbox.TotalMass = Mass
						self.Gearbox.ParentMass = ParentMass
						self.Gearbox.PhysicalMass = Mass-ParentMass
					end

					if IsValid(self.Tread[1]) then
						if self.Tread[1]:GetPhysicsObject():GetMaterial()~="jeeptire" then
							for i=1, table.Count(self.Tread) do
								self.Tread[i]:GetPhysicsObject():SetMaterial("jeeptire")
							end
						end
					end

					self.TotalMass = Mass
					self.SurfaceArea = SA
					self.SizeMult = (SA/Mass)*0.18

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
													self.Contraption[i].DakOwner = self.DakOwner
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
							self.CurrentHealth = self.HitBoxMass*0.01*self.SizeMult*25
							self.DakMaxHealth = self.HitBoxMass*0.01*self.SizeMult*25
							for i=1, table.Count(self.HitBox) do
								DakTekTankEditionSetupNewEnt(self.HitBox[i])
								self.HitBox[i].DakHealth = self.CurrentHealth
								self.HitBox[i].DakMaxHealth = self.CurrentHealth
								self.HitBox[i].Controller = self
								self.HitBox[i].DakOwner = self.DakOwner
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

							if self.Composites then
								if table.Count(self.Composites) > 0 then
									for i = 1, table.Count(self.Composites) do
										self.Composites[i].IsComposite = 1
										self.Composites[i]:GetPhysicsObject():SetMass( math.Round(self.Composites[i]:GetPhysicsObject():GetVolume()/61023.7*2000) )
										self.Composites[i].DakArmor = math.sqrt(math.sqrt(self.Composites[i]:GetPhysicsObject():GetVolume()))*15.5
									end
								end
							end

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
									self.DakMaxHealth = self.CurMass*0.01*self.SizeMult*25
									self.CurrentHealth = self.CurMass*0.01*self.SizeMult*25
									self.HitBox[i].DakMaxHealth = self.CurMass*0.01*self.SizeMult*25
								end
								self.HitBox[i].DakHealth = self.CurrentHealth
							end
							self.DakHealth = self.CurrentHealth
							
							local curvel = self:GetParent():GetParent():GetVelocity()
							if self.LastVel == nil then
								self.LastVel = curvel
							end
							if curvel:Distance(self.LastVel) > 1000 then
								for i=1, #self.Crew do
									self.Crew[i].DakHealth = self.Crew[i].DakHealth - ((curvel:Distance(self.LastVel)-1000)/100)

									if self.Crew[i].DakHealth <= 0 then
										local salvage = ents.Create( "dak_tesalvage" )
										salvage.DakModel = self.Crew[i]:GetModel()
										salvage:SetPos( self.Crew[i]:GetPos())
										salvage:SetAngles( self.Crew[i]:GetAngles())
										salvage:Spawn()
										self.Crew[i]:Remove()
									end

								end
							end
							self.LastVel = curvel


							WireLib.TriggerOutput(self, "Health", self.DakHealth)
							WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)
							if self.DakHealth then
								if (self.DakHealth <= 0 or #self.Crew <= 0) and self:GetParent():GetParent():GetPhysicsObject():IsMotionEnabled() then
									local DeathSounds = {"daktanks/closeexp1.wav","daktanks/closeexp2.wav","daktanks/closeexp3.wav"}

									self.RemoveTurretList = {}

									if math.random(1,3) == 1 then
										for j=1, #self.TurretControls do
											table.RemoveByValue( self.Contraption, self.TurretControls[j].TurretBase )
											self.TurretControls[j].TurretBase:SetMaterial("models/props_buildings/plasterwall021a")
											self.TurretControls[j].TurretBase:SetColor(Color(100,100,100,255))
											self.TurretControls[j].TurretBase:SetCollisionGroup( COLLISION_GROUP_WORLD )
											self.TurretControls[j].TurretBase:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
											if math.random(0,9) == 0 then
												self.TurretControls[j].TurretBase:Ignite(25,1)
											end
											constraint.RemoveAll( self:GetParent():GetParent() )
											for l=1, #self.TurretControls[j].Turret do
												if self.TurretControls[j].Turret[l] ~= self.TurretControls[j].TurretBase then
													if IsValid(self.TurretControls[j].Turret[l]) then
														table.RemoveByValue( self.Contraption, self.TurretControls[j].Turret[l] )
														self.TurretControls[j].Turret[l]:SetParent( self.TurretControls[j].TurretBase, -1 )
														self.TurretControls[j].Turret[l]:SetMoveType( MOVETYPE_NONE )
														self.TurretControls[j].Turret[l]:SetMaterial("models/props_buildings/plasterwall021a")
														self.TurretControls[j].Turret[l]:SetColor(Color(100,100,100,255))
														self.TurretControls[j].Turret[l]:SetCollisionGroup( COLLISION_GROUP_WORLD )
														self.TurretControls[j].Turret[l]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
														if self.TurretControls[j].Turret[l]:IsVehicle() then
															if IsValid(self.TurretControls[j].Turret[l]:GetDriver()) then
																self.TurretControls[j].Turret[l]:GetDriver():Kill()
															end
															self.TurretControls[j].Turret[l]:Remove()
														end
														if math.random(0,9) == 0 then
															self.TurretControls[j].Turret[l]:Ignite(25,1)
														end
													end
												end
											end
											self.TurretControls[j].TurretBase:SetAngles(self.TurretControls[j].TurretBase:GetAngles() + Angle(math.Rand(-45,45),math.Rand(-45,45),math.Rand(-45,45)))
											self.TurretControls[j].TurretBase:GetPhysicsObject():ApplyForceCenter(self.TurretControls[j].TurretBase:GetUp()*2500*self.TurretControls[j].TurretBase:GetPhysicsObject():GetMass())
											self.RemoveTurretList[#self.RemoveTurretList+1] = self.TurretControls[j].TurretBase
										end
									end

									for i=1, #self.Contraption do
										if self.Contraption[i].DakPooled == 0 or self.Contraption[i]:GetParent()==self:GetParent() or self.Contraption[i].Controller == self then
											self.Contraption[i].DakLastDamagePos = self.DakLastDamagePos
											if self.Contraption[i] ~= self:GetParent():GetParent() and self.Contraption[i] ~= self:GetParent() and self.Contraption[i] ~= self then
												if math.random(1,6)>1 then
													if self.Contraption[i]:GetClass() == "dak_tegearbox" or self.Contraption[i]:GetClass() == "dak_turretcontrol" or (string.Explode("_",self.Contraption[i]:GetClass(),false)[1] == "gmod") then
														self.salvage = ents.Create( "dak_tesalvage" )
														if ( !IsValid( self.salvage ) ) then return end
														if self.Contraption[i]:GetClass() == "dak_crew" then
															self.salvage.DakModel = "models/Humans/Charple01.mdl"
														else
															self.salvage.DakModel = self.Contraption[i]:GetModel()
														end
														self.salvage:SetPos( self.Contraption[i]:GetPos())
														self.salvage:SetAngles( self.Contraption[i]:GetAngles())
														self.salvage:Spawn()
														self.Contraption[i]:Remove()
													else
														constraint.RemoveAll( self.Contraption[i] )
														self.Contraption[i]:SetParent( self:GetParent(), -1 )
														self.Contraption[i]:SetMoveType( MOVETYPE_NONE )
														self.Contraption[i]:SetMaterial("models/props_buildings/plasterwall021a")
														self.Contraption[i]:SetColor(Color(100,100,100,255))
														self.Contraption[i]:SetCollisionGroup( COLLISION_GROUP_WORLD )
														self.Contraption[i]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
														if math.random(0,9) == 0 then
															self.Contraption[i]:Ignite(25,1)
														end
													end
												else
													self.salvage = ents.Create( "dak_tesalvage" )
													if ( !IsValid( self.salvage ) ) then return end
													self.salvage.launch = 1
													if self.Contraption[i]:GetClass() == "dak_crew" then
														self.salvage.DakModel = "models/Humans/Charple01.mdl"
													else
														self.salvage.DakModel = self.Contraption[i]:GetModel()
													end
													self.salvage:SetPos( self.Contraption[i]:GetPos())
													self.salvage:SetAngles( self.Contraption[i]:GetAngles())
													self.salvage:Spawn()
													self.Contraption[i]:Remove()
												end
												if self.Contraption[i]:IsVehicle() then
													if IsValid(self.Contraption[i]:GetDriver()) then
														self.Contraption[i]:GetDriver():Kill()
													end
													self.Contraption[i]:Remove()
												end
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
									effectdata:SetNormal( Vector(0,0,-1) )
									effectdata:SetScale(math.Clamp(self.DakMaxHealth*0.2,100,500))
									util.Effect("daktescalingexplosion", effectdata)

								end
							else
								self:Remove()
							end

						end
					end
				else
					if self.DeathTime then
						if self.DeathTime+30<CurTime() then
							for j=1, #self.RemoveTurretList do
								if IsValid(self.RemoveTurretList[j]) then
									self.RemoveTurretList[j]:Remove()
								end
							end
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
			else
				if self.SpawnTime+10 < CurTime() then
					self.DakOwner:PrintMessage( HUD_PRINTTALK, "Tank Core Error: Gate that tank core is parented to is not parented, please parent it to the baseplate." )
				end
			end
		else
			if self.SpawnTime+10 < CurTime() then
				self.DakOwner:PrintMessage( HUD_PRINTTALK, "Tank Core Error: Tank core is not parented to anything, please parent it to a gate." )
			end
		end
	end
	self:NextThink(CurTime()+1)
    return true
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}

	local CompositesIDs = {}
	if table.Count(self.Composites)>0 then
		for i = 1, table.Count(self.Composites) do
			if not(self.Composites[i]==nil) then
				table.insert(CompositesIDs,self.Composites[i]:EntIndex())
			end
		end
	end
	info.CompositesCount = table.Count(self.Composites)

	info.DakName = self.DakName
	info.DakHealth = self.DakHealth
	info.DakMaxHealth = self.DakBaseMaxHealth
	info.DakMass = self.DakMass
	info.DakOwner = self.DakOwner
	duplicator.StoreEntityModifier( self, "DakTek", info )
	duplicator.StoreEntityModifier( self, "DTComposites", CompositesIDs )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then
		if Ent.EntityMods.DakTek.CompositesCount == nil then
			self.NewComposites = {}
			if Ent.EntityMods.DTComposites then
				for i = 1, table.Count(Ent.EntityMods.DTComposites) do
					self.Ent = CreatedEntities[ Ent.EntityMods.DTComposites[i]]
					if self.Ent and IsValid(self.Ent) then
						table.insert(self.NewComposites,self.Ent)
					end
				end
			end
			self.Composites = self.NewComposites
		else
			if Ent.EntityMods.DakTek.CompositesCount > 0 then
				self.NewComposites = {}
				if Ent.EntityMods.DTComposites then
					for i = 1, Ent.EntityMods.DakTek.CompositesCount do
						local hitEnt = CreatedEntities[ Ent.EntityMods.DTComposites[i]]
						if IsValid(hitEnt) then
							table.insert(self.NewComposites,hitEnt)
						end
					end
				end
				self.Composites = self.NewComposites
			else
				self.Composites = {}
			end
		end
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