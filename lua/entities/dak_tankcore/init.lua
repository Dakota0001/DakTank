AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakName = "Tank Core"
ENT.HitBox = {}
ENT.DakActive = 0
ENT.DakFuel = nil

util.AddNetworkString( "daktankcoreera" )
util.AddNetworkString( "daktankcoredetail" )
util.AddNetworkString( "daktankcoreeraremove" )
util.AddNetworkString( "daktankcoredetailremove" )
util.AddNetworkString( "daktankcoredie" )

concommand.Add("daktank_unmake", function()
	cores = ents.FindByClass("dak_tankcore")
	for i=1, #cores do
		local core = cores[i]
		core.Off = true
		core.BuildInfo = {}
		core.OldParent = core:GetParent()
		core:SetParent(nil)
		for j=1, #core.Contraption do
			if core.Contraption[j]~=core then
				core.BuildInfo[j] = {}
				core.BuildInfo[j].Pos = core.Contraption[j]:GetPos()
				core.BuildInfo[j].Ang = core.Contraption[j]:GetAngles()
				core.BuildInfo[j].Parent = core.Contraption[j]:GetParent()
				core.BuildInfo[j].Move = core.Contraption[j]:GetMoveType()
				core.Contraption[j].Pos = core.Contraption[j]:GetPos()
				core.Contraption[j].Ang = core.Contraption[j]:GetAngles()
				core.Contraption[j].OldParent = core.Contraption[j]:GetParent()
				core.Contraption[j].Move = core.Contraption[j]:GetMoveType()
				core.Contraption[j]:SetParent(nil)
				core.Contraption[j]:SetMoveType(MOVETYPE_NONE)
			end
		end
		for j=1, #core.Contraption do
			core.Contraption[j]:SetPos(core:GetPos()+Vector(math.random(-500,500),math.random(-500,500),-500))
			core.Contraption[j]:SetAngles(AngleRand())
		end
	end
end)

function MoveEntToPos(ent)
	ent:SetPos(ent:GetPos()+Vector(0,0,math.random(400,1000)))
	local num = math.random(1,4)
	local scream = ""
	if num == 1 then
		scream = "ambient/halloween/female_scream_0"..math.random(1,9)..".wav"
	end
	if num == 2 then
		scream = "ambient/halloween/female_scream_10.wav"
	end
	if num == 3 then

		scream = "ambient/halloween/male_scream_0"..math.random(3,9)..".wav"
	end
	if num == 4 then
		scream = "ambient/halloween/male_scream_"..math.random(10,23)..".wav"
	end

	local tr = util.TraceLine( {
		start = ent:GetPos()+Vector(0,0,10000),
		endpos = ent:GetPos()+Vector(0,0,-10000),
		--filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
		mask = MASK_NPCWORLDSTATIC
	} )

	local effectdata = EffectData()
	effectdata:SetOrigin(tr.HitPos)
	effectdata:SetEntity(ent)
	effectdata:SetAttachment(1)
	effectdata:SetMagnitude(.5)
	effectdata:SetScale(math.random(5,25))
	util.Effect("dakteshellimpact", effectdata, true, true)

	ent:EmitSound(scream,100,100*math.Rand(0.9,1.1),1*math.Rand(0.9,1.1),CHAN_AUTO)
	timer.Create(ent:EntIndex().."ang", 0.01, 10000, function()
		local moveang = (ent.Ang-ent:GetAngles())
		ent:SetAngles(ent:GetAngles()+Angle(math.Clamp(moveang.pitch,-1,1),math.Clamp(moveang.yaw,-1,1),math.Clamp(moveang.roll,-1,1)))
		ent:SetMoveType(ent.Move)
		if math.Clamp(moveang.pitch,-1,1)==moveang.pitch and math.Clamp(moveang.yaw,-1,1)==moveang.yaw and math.Clamp(moveang.roll,-1,1)==moveang.roll then
			timer.Stop( ent:EntIndex().."ang" )
		end
	end)
	timer.Simple( math.random(1,3), function()
		timer.Create(ent:EntIndex().."move", 0.01, 10000, function()
			local movevec = (ent.Pos-ent:GetPos())
			ent:SetPos(ent:GetPos()+Vector(math.Clamp(movevec.x,-5,5),math.Clamp(movevec.y,-5,5),math.Clamp(movevec.z,-5,5)))
			ent:SetMoveType(ent.Move)

			if math.Clamp(movevec.x,-5,5)==movevec.x and math.Clamp(movevec.y,-5,5)==movevec.y and math.Clamp(movevec.z,-5,5)==movevec.z then
				if ent.soundplayed == nil then
					ent:EmitSound("doors/heavy_metal_stop1.wav",100,100*math.Rand(0.9,1.1),1*math.Rand(0.9,1.1),CHAN_AUTO)
					ent.soundplayed = true
					timer.Stop( ent:EntIndex().."move" )
					if ent.Controller.THETOLL == nil then ent.Controller.THETOLL = 0 end
					ent.Controller.THETOLL = ent.Controller.THETOLL + 1
					if ent.Controller.THETOLL >= #ent.Controller.Contraption-1 then
						for i=1, #ent.Controller.Contraption do
							ent.Controller.Contraption[i]:SetParent(ent.Controller.Contraption[i].OldParent)
							ent.Controller.Contraption[i]:SetMoveType(MOVETYPE_NONE)
						end
						--[[
						timer.Simple( 1, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(25,10,-20)) end )
						timer.Simple( 1, function() ent.Controller:GetParent():GetParent():SetAngles(ent.Controller:GetParent():GetParent():GetAngles()+Angle(-15,-40,0)) end )
						timer.Simple( 2, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(-79,-51,40)) end )
						timer.Simple( 2, function() ent.Controller:GetParent():GetParent():SetAngles(ent.Controller:GetParent():GetParent():GetAngles()+Angle(-5,-130,0)) end )
						timer.Simple( 3, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(40.5,-30.75,-50)) end )
						timer.Simple( 3, function() ent.Controller:GetParent():GetParent():SetAngles(ent.Controller:GetParent():GetParent():GetAngles()+Angle(30,152,0)) end )
						timer.Simple( 4, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(13.5,-10.25,0)) end )
						timer.Simple( 4, function() ent.Controller:GetParent():GetParent():SetAngles(ent.Controller:GetParent():GetParent():GetAngles()+Angle(-10,18,0)) end )
						timer.Simple( 4.1, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-10)) end )
						timer.Simple( 4.2, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-23)) end )
						timer.Simple( 4.3, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-2)) end )
						timer.Simple( 4.4, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-3)) end )
						timer.Simple( 4.5, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-13)) end )
						timer.Simple( 4.6, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-27)) end )
						timer.Simple( 4.7, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-1)) end )
						timer.Simple( 4.8, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-3)) end )
						timer.Simple( 4.9, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-0)) end )
						timer.Simple( 5, function() ent.Controller:GetParent():GetParent():SetPos(ent.Controller:GetParent():GetParent():GetPos()+Vector(0,0,-8)) end )
						]]--
					end
				end
			end

		end)
	end)
end

concommand.Add("daktank_remake", function()
	cores = ents.FindByClass("dak_tankcore")
	for i=1, #cores do
		local core = cores[i]
		for j=1, #core.Contraption do
			if core.Contraption[j]~=core then
				timer.Create( core:EntIndex()..core.Contraption[j]:EntIndex().."start", math.Rand(1,15), 1, function() MoveEntToPos(core.Contraption[j]) end )
			end
		end
	end
end)

hook.Add("AdvDupe_FinishPasting", "daktank_tankcore_check", function(dupe)
	local ents = dupe[1].CreatedEntities
	for id, data in pairs(dupe[1].EntityList) do
		local ent = ents[id]
		if IsValid(ent) then
			if ent:GetClass() == "dak_tankcore" then
				timer.Simple(engine.TickInterval() + 1,function()
					ent.DakFinishedPasting = 1
				end)
			end
			--also do guns while we're here
			if ent:GetClass() == "dak_tegun" or ent:GetClass() == "dak_teautogun" or ent:GetClass() == "dak_temachinegun" then
				local ScalingGun = 0
				if ent.DakModel == "models/daktanks/mortar100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/grenadelauncher100mm.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/smokelauncher100mm.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/machinegun100mm.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/cannon100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/shortcannon100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/longcannon100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/autocannon100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/hmg100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/howitzer100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/launcher100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/duallauncher100mm2.mdl" then ScalingGun = 1 end
				if ent.DakModel == "models/daktanks/recoillessrifle100mm2.mdl" then ScalingGun = 1 end
				if ScalingGun == 1 then
					if IsValid(ent) then
						ent:PhysicsDestroy()	
						--timer.Simple(2,function()
							if IsValid(ent) then
								local mins, maxs = ent:GetModelBounds()
								local CalMult = (ent.DakCaliber/100)
								mins = mins*CalMult
								maxs = maxs*CalMult
								local x0 = mins[1] -- Define the min corner of the box
								local y0 = mins[2]
								local z0 = mins[3]
								local x1 = maxs[1] -- Define the max corner of the box
								local y1 = maxs[2]
								local z1 = maxs[3]
								ent:PhysicsInitConvex( {
								Vector( x0, y0, z0 ),
								Vector( x0, y0, z1 ),
								Vector( x0, y1, z0 ),
								Vector( x0, y1, z1 ),
								Vector( x1, y0, z0 ),
								Vector( x1, y0, z1 ),
								Vector( x1, y1, z0 ),
								Vector( x1, y1, z1 )
								} )
								ent.ScaleSet = true
								ent:SetMoveType(MOVETYPE_VPHYSICS)
								ent:SetSolid(SOLID_VPHYSICS)
								ent:GetPhysicsObject():EnableMotion( false )
								ent:EnableCustomCollisions( true )
								local mins2, maxs2 = ent:GetHitBoxBounds( 0, 0 )
								ent:SetCollisionBounds( mins2*CalMult, maxs2*CalMult )
								--ent:Activate()
							end
						--end)
					end
				else
					ent.ScaleSet = true
				end
			end
		end
	end
end)
--cause self to delete self if not properly unfrozen

--have tank just keep rolling with gearbox on death (they aren't being added to contraption, find all axised to baseplate)

local PhysObj = FindMetaTable("PhysObj")
local O_Mass = PhysObj.SetMass
function PhysObj:SetMass(Mass)
    O_Mass(self, Mass)
   	if IsValid(self:GetEntity().Controller) then
   		self:GetEntity().Controller.MassUpdate = 1
   	end
end

local function SetMass( Player, Entity, Data )
	if not SERVER then return end

	if Data.Mass then
		local physobj = Entity:GetPhysicsObject()
		if physobj:IsValid() then physobj:SetMass(Data.Mass) end
	end

	duplicator.StoreEntityModifier( Entity, "mass", Data )
end
duplicator.RegisterEntityModifier( "mass", SetMass )

function ENT:Initialize()
	self:SetModel( "models/bull/gates/logic.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakArmor = 10
	--local phys = self:GetPhysicsObject()
	self.timer = CurTime()

	self.APSEnable = false
	self.APSFrontalArc = false
	self.APSSideArc = false
	self.APSRearArc = false
	self.APSShots = 0
	self.APSMinCaliber = 0

	self.Outputs = WireLib.CreateOutputs( self, { "Health","HealthPercent","Crew" } )
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.DakActive = 0
	self.CurMass = 0
	self.LastCurMass = 0
	self.HitBox = {}
	self.ERA = {}
	self.HitBoxMass = 0
	self.Hitboxthinktime = CurTime()
	self.LastRemake = CurTime()
	self.DakBurnStacks = 0
	self.SpawnTime = CurTime()
	self.FrontalArmor = 0
	self.SideArmor = 0
	self.RearArmor = 0
	self.Modern = nil
	self.ColdWar = nil
	self.BoxVolume = 100000000
	self.PenMult = 0
	self.DPSMult = 0

	self.PhysEra = true
	self.LastPhysEra = true

	self.PhysDetail = true
	self.LastPhysDetail = true

	self.Forward = self:GetForward()
end


local function GetPhysCons( ent, Results )
	local Results = Results or {}
	if not IsValid( ent ) then return end
		if Results[ ent ] then return end
		Results[ ent ] = ent
		local Constraints = constraint.GetTable( ent )
		for k, v in ipairs( Constraints ) do
			if not (v.Type == "NoCollide") and not (v.Type == "Rope") and not ((v.Type == "AdvBallsocket") and v.onlyrotation == 1) then
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
	local systime = SysTime()
	if IsValid(self) and self.Off~=true then
		if IsValid(self:GetParent()) then
			if IsValid(self:GetParent():GetParent()) then
				self.Base = self:GetParent():GetParent()
				if not(self.PreCostTimerFirst) then
					self.PreCostTimerFirst = CurTime()
					self.PreCostTimer = 0	
				end
				self.PreCostTimer = CurTime() - self.PreCostTimerFirst
				if self.DakFinishedPasting == 1 and self.CanSpawn ~= true and (IsValid(self.Gearbox) or (self.TurretControls~=nil and IsValid(self.TurretControls[1]))) then
					if self:GetForceColdWar() == true then
						self.ColdWar = 1
					end
					if self:GetForceModern() == true then
						self.Modern = 1
					end

					self.APSEnable = self:GetEnableAPS()
					self.APSFrontalArc = self:GetAPSFrontalArc()
					self.APSSideArc = self:GetAPSSideArc()
					self.APSRearArc = self:GetAPSRearArc()
					self.APSShots = math.Clamp(self:GetAPSShots(),0,20)
					self.APSMinCaliber = self:GetAPSMinCaliber()

					if self.APSEnable == true then
						self.Modern = 1
					end

					self.CanSpawn = true

					local GunHandlingMult = 0
					if self.TurretControls[1] then

						local TotalTurretMass = 0 
						for i=1, #self.TurretControls do
							if self.TurretControls[i].GunMass ~= nil then
								TotalTurretMass = TotalTurretMass + self.TurretControls[i].GunMass
							end
						end
						self.MainTurret = self.TurretControls[1]
						local GunPercentage
						for i=1, #self.TurretControls do
							if IsValid(self.MainTurret) then 
								if self.TurretControls[i].GunMass ~= nil and self.MainTurret.GunMass ~= nil then
									if self.TurretControls[i].GunMass > self.MainTurret.GunMass then
										self.MainTurret = self.TurretControls[i]
									end
									local RotationSpeed = self.TurretControls[i].RotationSpeed
									local TurretCost = math.log(RotationSpeed*100,100)
									if self.TurretControls[i].RemoteWeapon == true then
										TurretCost = TurretCost * 1.5
									end
									if self.TurretControls[i]:GetFCS() == true then
										self.ColdWar = 1
										TurretCost = TurretCost * 1.5
									end
									if self.TurretControls[i]:GetStabilizer() == true then
										self.ColdWar = 1
										TurretCost = TurretCost * 1.25
									elseif self.TurretControls[i]:GetShortStopStabilizer() == true then
										TurretCost = TurretCost * 1
									else
										TurretCost = TurretCost * 0.75
									end
									if self.TurretControls[i]:GetYawMin() + self.TurretControls[i]:GetYawMax() <= 90 then
										TurretCost = TurretCost * 0.5
									end
									--print(TurretCost*(self.TurretControls[i].GunMass/TotalTurretMass))
									GunHandlingMult = GunHandlingMult + math.max(TurretCost,0)*(self.TurretControls[i].GunMass/TotalTurretMass)
								end
							end
						end
					end

					self.BestHeight = 0
					self.BestWidth = 0
					self.BestLength = 0
					local HitTable = {}
					local ArmorVal1 = 0
					local addpos
					local count = 0
					local blocks = 0
					local gunhit = 0
					local gearhit = 0
					local HitCrit = 0
					local SpallLiner = 0
					local forward
					local right
					local up
					if IsValid(self.Gearbox) then
						forward = Angle(0,self.Gearbox:GetAngles().yaw,0):Forward()
						right = Angle(0,self.Gearbox:GetAngles().yaw,0):Right()
						up = Angle(0,self.Gearbox:GetAngles().yaw,0):Up()
					elseif IsValid(self.MainTurret) then
						forward = Angle(0,self.MainTurret:GetAngles().yaw,0):Forward()
						right = Angle(0,self.MainTurret:GetAngles().yaw,0):Right()
						up = Angle(0,self.MainTurret:GetAngles().yaw,0):Up()
					end
					self.Forward = forward

					--setup system to check layers of armor between first impact and crew and determine if a spall liner exists 

					--FRONT
					local startpos = self:GetParent():GetParent():GetPos()+(up*125)+(right*-125)
					local basesize = self:GetParent():GetParent():OBBMaxs()
					local distance = math.Max((math.Max(basesize.x, basesize.y, basesize.z)*5),250)
					local ArmorValTable = {}
					local SpallLinerCount = 0
					local hitpos
					for i=1, 25 do
						for j=1, 25 do
							addpos = (right*10*j)+(up*-10*i)+(up*0.4*j)
							SpallLiner = 0
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit, hitpos, SpallLiner = DTGetArmorRecurseNoStop(startpos+addpos+forward*distance, startpos+addpos, "AP", 75, player.GetAll(), self)
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
									if SpallLiner == 1 then
										SpallLinerCount = SpallLinerCount + 1
									end
								end
								if gunhit==0 and ent.Controller == self then
									HitTable[#HitTable+1] = hitpos
								end
							end
						end
					end
					local totalarmor = 0
					table.sort( ArmorValTable, function(a, b) return a < b end )
					local Ave = 0
					local AveCount = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					self.FrontalArmor = Ave/AveCount
					self.FrontalSpallLinerCoverage = (SpallLinerCount/#ArmorValTable)
					--has to be done per side
					--REAR
					count = 0
					blocks = 0
					HitCrit = 0
					startpos = self:GetParent():GetParent():GetPos()+(up*125)+(right*-125)
					ArmorValTable = {}
					SpallLinerCount = 0
					for i=1, 50 do
						for j=1, 50 do
							addpos = (right*5*j)+(up*-5*i)+(up*0.2*j)
							SpallLiner = 0
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit, hitpos, SpallLiner = DTGetArmorRecurseNoStop(startpos+addpos-forward*distance, startpos+addpos, "AP", 75, player.GetAll(), self)
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
									if SpallLiner == 1 then
										SpallLinerCount = SpallLinerCount + 1
									end
								end
								if gunhit==0 and ent.Controller == self then
									HitTable[#HitTable+1] = hitpos
								end
							end
						end
					end
					Ave = 0
					AveCount = 0
					totalarmor = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					self.RearArmor = Ave/AveCount
					self.RearSpallLinerCoverage = (SpallLinerCount/#ArmorValTable)
					--LEFT
					count = 0
					blocks = 0
					HitCrit = 0
					startpos = self:GetParent():GetParent():GetPos()+(up*125)+(forward*-125)
					ArmorValTable = {}
					SpallLinerCount = 0
					for i=1, 25 do
						for j=1, 25 do
							addpos = (forward*10*j)+(up*-10*i)+(up*0.4*j)
							SpallLiner = 0
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit, hitpos, SpallLiner = DTGetArmorRecurseNoStop(startpos+addpos+right*distance, startpos+addpos, "AP", 75, player.GetAll(), self)
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
									if SpallLiner == 1 then
										SpallLinerCount = SpallLinerCount + 1
									end
								end
								if gunhit==0 and ent.Controller == self then
									HitTable[#HitTable+1] = hitpos
								end
							end
						end
					end
					Ave = 0
					AveCount = 0
					totalarmor = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					local LeftArmor = Ave/AveCount
					self.LeftSpallLinerCoverage = (SpallLinerCount/#ArmorValTable)
					--RIGHT
					count = 0
					blocks = 0
					HitCrit = 0
					startpos = self:GetParent():GetParent():GetPos()+(up*125)+(forward*-125)
					ArmorValTable = {}
					SpallLinerCount = 0
					for i=1, 25 do
						for j=1, 25 do
							addpos = (forward*10*j)+(up*-10*i)+(up*0.4*j)
							SpallLiner = 0
							ArmorVal1, ent, _, _, gunhit, gearhit, HitCrit, hitpos, SpallLiner = DTGetArmorRecurseNoStop(startpos+addpos-right*distance, startpos+addpos, "AP", 75, player.GetAll(), self)
							if IsValid(ent) then
								if gunhit==0 and ent.Controller == self and HitCrit == 1 then
									ArmorValTable[#ArmorValTable+1] = ArmorVal1
									if SpallLiner == 1 then
										SpallLinerCount = SpallLinerCount + 1
									end
								end
								if gunhit==0 and ent.Controller == self then
									HitTable[#HitTable+1] = hitpos
								end
							end
						end
					end
					Ave = 0
					AveCount = 0
					totalarmor = 0
					for i=1, #ArmorValTable do
						totalarmor=totalarmor+math.min(ArmorValTable[i],2200)
						if i>=#ArmorValTable/4 and i<=(#ArmorValTable/4)*3 then
							Ave = Ave + math.min(ArmorValTable[i],2200)
							AveCount = AveCount + 1
						end
					end
					local RightArmor = Ave/AveCount
					self.RightSpallLinerCoverage = (SpallLinerCount/#ArmorValTable)
					self.SideArmor = (RightArmor+LeftArmor)/2
					self.SideSpallLinerCoverage = 0.5*(self.RightSpallLinerCoverage + self.LeftSpallLinerCoverage)

					self.ArmorSideMult = math.max(self.SideArmor/250,0.1)

					local Total = math.max(self.FrontalArmor,self.SideArmor,self.RearArmor)

					self.BestAveArmor = Total
					armormult = ((Total/420)*(1+(0.25*self.FrontalSpallLinerCoverage)))*(self.ArmorSideMult*(1+(0.25*self.SideSpallLinerCoverage)))
					--local armormult = (self.FrontalArmor*0.5)+(self.SideArmor*0.3)+(self.RearArmor*0.2)
					--print(self.FrontalArmor)
					--print(self.SideArmor)
					--print(self.RearArmor)
					local shellvol = ((100*0.0393701)^2)*(100*0.0393701*13)
					local shells = 0
					local ammocosts = 0

					for i = 1, #self.Guns do
						self.Guns[i].AmmoBoxes = {}
						for j = 1, #self.Ammoboxes do
							if not(self.Ammoboxes[j].DakAmmoType == "Flamethrower Fuel") then
								if self.Guns[i].DakGunType == "Short Cannon" or self.Guns[i].DakGunType == "Short Autoloader" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "S" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Cannon" or self.Guns[i].DakGunType == "Autoloader" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Long Cannon" or self.Guns[i].DakGunType == "Long Autoloader" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "L" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Howitzer" or self.Guns[i].DakGunType == "Autoloading Howitzer" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "H" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] ~= "M" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Mortar" or self.Guns[i].DakGunType == "Autoloading Mortar" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "M" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] ~= "G" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Smoke Launcher" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "S" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "L" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Flamethrower" then
									if self.Ammoboxes[j].DakAmmoType == "Flamethrower Fuel" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "MG" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "M" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "G" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Grenade Launcher" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "G" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "L" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "HMG" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "H" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "M" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][3] == "G" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Autocannon" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "A" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "Recoilless Rifle" or self.Guns[i].DakGunType == "Autoloading Recoilless Rifle" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "R" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] == "R" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								elseif self.Guns[i].DakGunType == "ATGM Launcher" or self.Guns[i].DakGunType == "Dual ATGM Launcher" or self.Guns[i].DakGunType == "Autoloading ATGM Launcher" or self.Guns[i].DakGunType == "Autoloading Dual ATGM Launcher" then
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "L" and string.Split( self.Ammoboxes[j].DakName, "m" )[3][2] ~= "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								else
									if string.Split( self.Ammoboxes[j].DakName, "m" )[3][1] == "C" then
										self.Guns[i].AmmoBoxes[#self.Guns[i].AmmoBoxes+1] = self.Ammoboxes[j]
									end
								end
							end
						end
					end

					local MaxPen = 0
					for i = 1, #self.Guns do
						for j = 1, #self.Guns[i].AmmoBoxes do
							local boxname = (string.Split( self.Guns[i].AmmoBoxes[j].DakAmmoType, "" ))
							local name6 = boxname[#boxname-9]..boxname[#boxname-8]..boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
							local name4 = boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
							local name2 = boxname[#boxname-5]..boxname[#boxname-4]
							local name
							if name6 == "APFSDS" or name6 == "HEATFS" then
								name = name6
							elseif name4 == "HVAP" or name4 == "APDS" or name4 == "HEAT" or name4 == "HESH" or name4 == "ATGM" or name4 == "APHE" then
								name = name4
							elseif name2 == "AP" or name2 == "HE" or name2 == "SM" then
								name = name2
							end
							if name == "APFSDS" then
								if self.Guns[i].BaseDakShellPenetration*7.8*0.5 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*7.8*0.5 end
							elseif name == "APDS" then
								if self.Guns[i].BaseDakShellPenetration*1.67 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*1.67 end
							elseif name == "HVAP" then
								if self.Guns[i].BaseDakShellPenetration*1.5 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*1.5 end
							elseif name == "AP" then
								if self.Guns[i].BaseDakShellPenetration > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration end
							elseif name == "APHE" then
								if self.Guns[i].BaseDakShellPenetration*0.825 > MaxPen then MaxPen = self.Guns[i].BaseDakShellPenetration*0.825 end
							elseif name == "ATGM" then
								if self.Modern==1 then
									if self.Guns[i].DakMaxHealth*6.40 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*6.40 end
								else
									if self.Guns[i].DakMaxHealth*6.40*0.45 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*6.40*0.45 end
								end
							elseif name == "HEATFS" then
								if self.Modern==1 then
									if self.Guns[i].DakMaxHealth*5.4 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*5.4 end
								else
									if self.Guns[i].DakMaxHealth*5.40*0.658 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*5.40*0.658 end
								end
							elseif name == "HEAT" then
								if self.ColdWar==1 or self.Modern==1 then
									if self.Guns[i].DakMaxHealth*5.4*0.431 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*5.4*0.431 end
								else
									if self.Guns[i].DakMaxHealth*1.20 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*1.20 end
								end
							elseif name == "HESH" then
								if self.Guns[i].DakMaxHealth*1.25 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*1.25 end
							elseif name == "HE" then
								if self.Guns[i].DakBaseShellFragPen > MaxPen then MaxPen = self.Guns[i].DakBaseShellFragPen end
							elseif name == "SM" then
								if self.Guns[i].DakMaxHealth*0.1 > MaxPen then MaxPen = self.Guns[i].DakMaxHealth*0.1 end
							end
						end
					end


					for k=1, #self.Ammoboxes do 
						local boxname = (string.Split( self.Ammoboxes[k].DakAmmoType, "" ))
						local name6 = boxname[#boxname-9]..boxname[#boxname-8]..boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
						local name4 = boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
						local name2 = boxname[#boxname-5]..boxname[#boxname-4]
						--check longest to shortest names, with if then ifelse then else
						local name 
						if name6 == "APFSDS" or name6 == "HEATFS" then
							name = name6
						elseif name4 == "HVAP" or name4 == "APDS" or name4 == "HEAT" or name4 == "HESH" or name4 == "ATGM" or name4 == "APHE" then
							name = name4
						elseif name2 == "AP" or name2 == "HE" or name2 == "SM" then
							name = name2
						end
						shells = self.Ammoboxes[k]:GetPhysicsObject():GetVolume()/shellvol
						local cost = 0
						if name == "HE" then
							cost = shells * 0.1
						elseif name == "HESH" then
							cost = shells * 0.26
						elseif name == "AP" or name == "APHE" or name == "HEAT" then
							if name == "HEAT" and self.ColdWar == 1 then
								cost = shells * 0.41
							else
								cost = shells * 0.25
							end
						elseif name == "HVAP" then
							cost = shells * 0.38
						elseif name == "APDS" then
							cost = shells * 0.42
						elseif name == "HEATFS" or name == "APFSDS" then
							if name == "HEATFS" and self.ColdWar == 1 and self.Modern == 0 then
								cost = shells * 0.62
							else
								cost = shells * 1
							end
						elseif name == "ATGM" then
							if self.ColdWar == 1 and self.Modern == 0 then
								cost = shells * 1.0
							else
								cost = shells * 1.25
							end
						end
						ammocosts = ammocosts + cost
					end
					local speedmult = 1
					if IsValid(self.Gearbox) then
						if self.Gearbox.DakHP ~= nil and self.Gearbox.MaxHP ~= nil and self.Gearbox.TotalMass ~= nil and self.Gearbox.HPperTon ~= nil then
							if self.Gearbox:GetClass() == "dak_tegearboxnew" then
								speedmult = math.Clamp((1+(math.Round(math.Clamp(self.Gearbox.DakHP,0,self.Gearbox.MaxHP)/((self.Gearbox.TotalMass*1.1)/1000),2)*0.05))*0.5,0,1.5)
							else
								speedmult = math.Clamp((1+(math.Round(math.Clamp(self.Gearbox.DakHP,0,self.Gearbox.MaxHP)/(self.Gearbox.TotalMass/1000),2)*0.05))*0.5,0,1.5)
							end
						else
							self.DakOwner:ChatPrint("Please finish setting up the gearbox to get a correct cost for your tank.")
						end
					else
						speedmult = 0.25
						self.DakOwner:ChatPrint("No gearbox detected, towed gun assumed.")
						--self.DakOwner:ChatPrint("Please give your tank a gearbox so that it may calculate its cost properly.")
					end
					--local speedmult = math.Clamp((((math.Clamp(self.Gearbox.DakHP,0,self.Gearbox.MaxHP)/(self.Gearbox.TotalMass/1000))*0.05)),0,2)
					--armormult = armormult+0.1
					--armormult = 1.002663 - 1.056967*2.718^(-6.413596*armormult)

					local DPS = 0
					local TotalDPS = 0
					local ShotsPerSecond
					for g=1, #self.Guns do
						local ShellDamage = self.Guns[g].BaseDakShellDamage
						if self.Guns[g].DakGunType == "Smoke Launcher" then
							ShellDamage = self.Guns[g].BaseDakShellDamage/4
						end
						if self.Guns[g].DakGunType == "Flamethrower" then
							ShellDamage = 0.75
						end
						if self.Guns[g].DakGunType == "ATGM Launcher" or self.Guns[g].DakGunType == "Dual ATGM Launcher" or self.Guns[g].DakGunType == "Autoloading ATGM Launcher" or self.Guns[g].DakGunType == "Autoloading Dual ATGM Launcher" then
							ShellDamage = self.Guns[g].BaseDakShellDamage/8
						end

						--also have an exception here for flamethrower damage per shot
						if self.Guns[g]:GetClass() == "dak_teautogun" then
							ShotsPerSecond = 1/((self.Guns[g].DakCooldown * (1/self.Guns[g].FireRateMod))+((1/self.Guns[g].DakMagazine)*self.Guns[g].DakReloadTime))
							DPS = ShellDamage*ShotsPerSecond
							if self.Guns[g].ReadyRounds == 2 then 
								DPS = DPS*2 
							end
						end
						if self.Guns[g]:GetClass() == "dak_tegun" then
							ShotsPerSecond = 1/(0.2484886*(math.pi*((self.Guns[g].DakCaliber*0.001*0.5)^2)*(self.Guns[g].DakCaliber*0.001*self.Guns[g].ShellLengthExact)*5150)+1.279318)
							DPS = ShellDamage*ShotsPerSecond
							if self.Guns[g].ReadyRounds == 2 then 
								DPS = DPS*2 
							end
						end
						if self.Guns[g]:GetClass() == "dak_temachinegun" then
							self.Guns[g].ShellLengthExact = 6.5
							ShotsPerSecond = 1/(self.Guns[g].DakCooldown*(1/self.Guns[g].FireRateMod))
							DPS = ShellDamage*ShotsPerSecond
							if self.Guns[g].ReadyRounds == 2 then 
								DPS = DPS*2 
							end
						end
						TotalDPS = TotalDPS + DPS
					end
					self.MaxPen = MaxPen
					local firepowermult = MaxPen/420
					local altfirepowermult = 0.005*TotalDPS^1
					--if altfirepowermult > firepowermult then firepowermult = altfirepowermult end
					math.max(0.1,firepowermult)
					self.PenMult = firepowermult*0.5
					self.DPSMult = altfirepowermult*0.5
					firepowermult = (altfirepowermult+firepowermult)*0.5
					local basepos = self:GetParent():GetParent():GetPos()
					self.BestLength = 0
					self.BestWidth = 0
					self.BestHeight = 0
					for i=1, #HitTable do
						local diff = basepos-HitTable[i]
						if math.abs(diff.x) > self.BestWidth then self.BestWidth = math.abs(diff.x) end
						if math.abs(diff.y) > self.BestLength then self.BestLength = math.abs(diff.y) end
						if math.abs(diff.z) > self.BestHeight then self.BestHeight = math.abs(diff.z) end
					end

					self.BoxVolume = self.BestLength*self.BestWidth*self.BestHeight
					local biggestsize = math.max(math.min(self.BestLength, self.BestWidth)*1.1,self.BestHeight*0.5*1.1)*2
					local pixels = 100
					local startpos = self:GetParent():GetParent():GetPos()+(up*self.BestHeight*0.5)+(right*-biggestsize*0.5)+(up*biggestsize*0.5)
					local curarmor = 0
					self.frontarmortable = {}
					for i=1, pixels do
						timer.Simple(engine.TickInterval()*i,function()
							for j=1, pixels do
								addpos = (right*(biggestsize/pixels)*j)+(up*-(biggestsize/pixels)*i)
								SpallLiner = 0
								curarmor, _, _, _, _, _, _, _, _ = DTGetArmorRecurse(startpos+addpos+forward*distance, startpos+addpos-forward*distance, "AP", 75, player.GetAll(), self)
								if curarmor~=nil then
									self.frontarmortable[#self.frontarmortable+1] = math.Round(curarmor)
								else
									self.frontarmortable[#self.frontarmortable+1] = 0
								end
							end
						end)
					end
					timer.Simple(engine.TickInterval()*pixels+1,function()
						self.frontarmortable[#self.frontarmortable+1] = self.FrontalArmor
					end)
					--self.frontarmortable = frontarmortable

					firepowermult = math.max((self.BoxVolume*0.01/250000),firepowermult)

					--print("Highest Armor: "..(armormult*50))
					--print("Side Armor "..self.SideArmor)
					--print("Side Armor Mult: "..(self.SideArmor/100))
					--print("Adjusted Armor: "..((armormult*50)*(self.SideArmor/100)))
					self.FirepowerMult = math.Round(math.max((self.BoxVolume*0.01/250000),firepowermult),2)
					self.SpeedMult = math.Round(math.max(0.1,speedmult),2)
					self.ArmorMult = math.Round(math.max(0.01,armormult),3)
					self.GunHandlingMult = math.Round(math.max(0.1,GunHandlingMult),2)
					self.TotalArmorWeight = self.RHAWeight+self.CHAWeight+self.HHAWeight+self.NERAWeight+self.StillbrewWeight+self.TextoliteWeight+self.ConcreteWeight+self.ERAWeight
					local ArmorTypeMult = (((1*(self.RHAWeight/self.TotalArmorWeight))+(0.75*(self.CHAWeight/self.TotalArmorWeight))+(1.25*(self.HHAWeight/self.TotalArmorWeight))+(1.75*(self.NERAWeight/self.TotalArmorWeight))+(1.0*(self.StillbrewWeight/self.TotalArmorWeight))+(1.5*(self.TextoliteWeight/self.TotalArmorWeight))+(0.05*(self.ConcreteWeight/self.TotalArmorWeight))+(1.25*(self.ERAWeight/self.TotalArmorWeight))))
					self.ArmorMult = self.ArmorMult * ArmorTypeMult
					self.PreCost = self.ArmorMult*50 + self.FirepowerMult*50
					--self.PreCost = self.PreCost*(armormult*speedmult*firepowermult*self.GunHandlingMult)
					self.PreCost = self.PreCost*((self.SpeedMult+self.GunHandlingMult)*0.5)

					self.APSCost = 0
					if self.APSEnable == true then
						local roundcost = 0
						if self.APSFrontalArc == true then
							roundcost = roundcost + 1
						end
						if self.APSSideArc == true then
							roundcost = roundcost + 1
						end
						if self.APSRearArc == true then
							roundcost = roundcost + 1
						end
						self.APSCost = self.APSShots*roundcost
					end

					self.Cost = math.Round(self.PreCost+self.APSCost)

					local curera = "WWII"
					if self.ColdWar == 1 then curera = "Cold War" end
					if self.Modern == 1 then curera = "Modern" end
					self.DakOwner:ChatPrint("Tank Analysis Complete: "..self.Cost.." point "..curera.." tank. Right click tank core with spawner for detailed readout.")
				end

				if not(self.Dead) and (self.DakFinishedPasting == 1 or self.dupespawned==nil) then
					if not(self.DakMaxHealth) then
						self.DakMaxHealth = 10
					end
					if table.Count(self.HitBox)==0 then
						if self.DakHealth>self.DakMaxHealth then
							self.DakHealth = self.DakMaxHealth
						end
					end

					if self.recheckmass == nil then
						local Mass = 0
						local ParentMass = 0
						local SA = 0
						
						self.Contraption = {self:GetParent():GetParent()}
						local turrets = {}

						for k, v in pairs(self:GetParent():GetParent():GetChildren()) do
							self.Contraption[#self.Contraption+1] = v
							for k2, v2 in pairs(v:GetChildren()) do
								self.Contraption[#self.Contraption+1] = v2
								if v2:GetClass() == "dak_turretcontrol" then
									turrets[#turrets+1] = v2
								end
							end
						end

						local turrets2 = {}
						for i=1, #turrets do
							local TurEnts = {}
							if turrets[i].WiredTurret ~= NULL then
								self.Contraption[#self.Contraption+1] = turrets[i].WiredTurret
								TurEnts[#TurEnts+1] = turrets[i].WiredTurret
								for k, v in pairs(turrets[i].WiredTurret:GetChildren()) do
									self.Contraption[#self.Contraption+1] = v
									TurEnts[#TurEnts+1] = v
									for k2, v2 in pairs(v:GetChildren()) do
										self.Contraption[#self.Contraption+1] = v2
										TurEnts[#TurEnts+1] = v2
										if v2:GetClass() == "dak_turretcontrol" then
											turrets2[#turrets2+1] = v2
										end
									end
								end
							end
							if turrets[i].WiredGun ~= NULL then
								if turrets[i].WiredGun:GetClass() == "dak_tegun" or turrets[i].WiredGun:GetClass() == "dak_teautogun" or turrets[i].WiredGun:GetClass() == "dak_temachinegun" then
									self.Contraption[#self.Contraption+1] = turrets[i].WiredGun:GetParent():GetParent()
									TurEnts[#TurEnts+1] = turrets[i].WiredGun:GetParent():GetParent()
									for k, v in pairs(turrets[i].WiredGun:GetParent():GetParent():GetChildren()) do
										self.Contraption[#self.Contraption+1] = v
										TurEnts[#TurEnts+1] = v
										for k2, v2 in pairs(v:GetChildren()) do
											self.Contraption[#self.Contraption+1] = v2
											TurEnts[#TurEnts+1] = v2
											if v2:GetClass() == "dak_turretcontrol" then
												turrets2[#turrets2+1] = v2
											end
										end
									end
								else
									self.DakOwner:ChatPrint(turrets[i].DakName.." #"..turrets[i]:EntIndex().." must have gun wired to a daktank gun.")
								end
							end
							turrets[i].Extra = TurEnts
						end

						local turrets3 = {}
						for i=1, #turrets2 do
							local TurEnts = {}
							if turrets2[i].WiredTurret ~= NULL then
								self.Contraption[#self.Contraption+1] = turrets2[i].WiredTurret
								TurEnts[#TurEnts+1] = turrets2[i].WiredTurret
								for k, v in pairs(turrets2[i].WiredTurret:GetChildren()) do
									self.Contraption[#self.Contraption+1] = v
									TurEnts[#TurEnts+1] = v
									for k2, v2 in pairs(v:GetChildren()) do
										self.Contraption[#self.Contraption+1] = v2
										TurEnts[#TurEnts+1] = v2
										if v2:GetClass() == "dak_turretcontrol" then
											turrets3[#turrets3+1] = v2
										end
									end
								end
							end
							if turrets2[i].WiredGun ~= NULL then
								self.Contraption[#self.Contraption+1] = turrets2[i].WiredGun:GetParent():GetParent()
								TurEnts[#TurEnts+1] = turrets2[i].WiredGun:GetParent():GetParent()
								for k, v in pairs(turrets2[i].WiredGun:GetParent():GetParent():GetChildren()) do
									self.Contraption[#self.Contraption+1] = v
									TurEnts[#TurEnts+1] = v
									for k2, v2 in pairs(v:GetChildren()) do
										self.Contraption[#self.Contraption+1] = v2
										TurEnts[#TurEnts+1] = v2
										if v2:GetClass() == "dak_turretcontrol" then
											turrets3[#turrets3+1] = v2
										end
									end
								end
							end
							turrets2[i].Extra = TurEnts
						end

						--just gonna stop it right here, if people have turrets on their turrets on their turrets that's fine, but I'm not going a step further

						--local turrets4 = {}
						for i=1, #turrets3 do
							local TurEnts = {}
							if turrets3[i].WiredTurret ~= NULL then
								self.Contraption[#self.Contraption+1] = turrets3[i].WiredTurret
								TurEnts[#TurEnts+1] = turrets3[i].WiredTurret
								for k, v in pairs(turrets3[i].WiredTurret:GetChildren()) do
									self.Contraption[#self.Contraption+1] = v
									TurEnts[#TurEnts+1] = v
									for k2, v2 in pairs(v:GetChildren()) do
										self.Contraption[#self.Contraption+1] = v2
										TurEnts[#TurEnts+1] = v2
										--if v2:GetClass() == "dak_turretcontrol" then
										--	turrets4[#turrets4+1] = v2
										--end
									end
								end
							end
							if turrets3[i].WiredGun ~= NULL then
								self.Contraption[#self.Contraption+1] = turrets3[i].WiredGun:GetParent():GetParent()
								TurEnts[#TurEnts+1] = turrets3[i].WiredGun:GetParent():GetParent()
								for k, v in pairs(turrets3[i].WiredGun:GetParent():GetParent():GetChildren()) do
									self.Contraption[#self.Contraption+1] = v
									TurEnts[#TurEnts+1] = v
									for k2, v2 in pairs(v:GetChildren()) do
										self.Contraption[#self.Contraption+1] = v2
										TurEnts[#TurEnts+1] = v2
										--if v2:GetClass() == "dak_turretcontrol" then
										--	turrets4[#turrets4+1] = v2
										--end
									end
								end
							end
							turrets3[i].Extra = TurEnts
						end

						table.Add( self.Contraption, GetPhysCons( self:GetParent():GetParent() ) )

						if table.Count(GetPhysCons( self:GetParent():GetParent() )) > 0 then
							for k, v in pairs(GetPhysCons( self:GetParent():GetParent() )) do
								for k2, v2 in pairs(v:GetChildren()) do
									self.Contraption[#self.Contraption+1] = v2
									for k3, v3 in pairs(v2:GetChildren()) do
										self.Contraption[#self.Contraption+1] = v3
									end
								end
							end
						end
						--PrintTable(self.Contraption)

						local hash = {}
						local res = {}

						for _,v in ipairs(self.Contraption) do
					   		if (not hash[v]) then
					    		res[#res+1] = v
					       		hash[v] = true
					   		end
						end
						
						self.Contraption={}
						self.Ammoboxes={}
						self.TurretControls={}
						self.Guns={}
						self.Crew={}
						self.Motors={}
						self.Fuel={}
						self.Tread={}
						self.ERA={}
						self.DETAIL={}
						self.Seats={}
						self.GunCount = 0
						self.MachineGunCount = 0

						self.RHAWeight = 0
						self.CHAWeight = 0
						self.HHAWeight = 0
						self.NERAWeight = 0
						self.StillbrewWeight = 0
						self.TextoliteWeight = 0
						self.ConcreteWeight = 0
						self.ERAWeight = 0

						local CurrentRes
						self.Clips = {}
						for i=1, #res do
							CurrentRes = res[i]
							if CurrentRes:IsValid() and CurrentRes:IsSolid() then
								if CurrentRes:GetParent():IsValid() then
									--CurrentRes:SetMoveType(MOVETYPE_NONE)
								end
								if CurrentRes:GetClass()=="prop_physics" and CurrentRes:GetPhysicsObject():GetMass()<=1 then
									if table.Count(CurrentRes:GetChildren()) == 0 and CurrentRes:GetParent():IsValid() then
										self.DETAIL[#self.DETAIL+1]=CurrentRes
									else
										self.Contraption[#self.Contraption+1] = CurrentRes
									end
								else
									self.Contraption[#self.Contraption+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_tegearbox" or CurrentRes:GetClass()=="dak_tegearboxnew" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.Gearbox = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_tefuel" then
									self.Fuel[#self.Fuel+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_temotor" then
									self.Motors[#self.Motors+1] = CurrentRes
								end
								if CurrentRes:GetClass() == "dak_teammo" then
									local boxname = (string.Split( CurrentRes.DakAmmoType, "" ))
									local name6 = boxname[#boxname-9]..boxname[#boxname-8]..boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
									local name4 = boxname[#boxname-7]..boxname[#boxname-6]..boxname[#boxname-5]..boxname[#boxname-4]
									local name2 = boxname[#boxname-5]..boxname[#boxname-4]
									--check longest to shortest names, with if then ifelse then else
									local name 
									if name6 == "APFSDS" or name6 == "HEATFS" then
										name = name6
									elseif name4 == "HVAP" or name4 == "APDS" or name4 == "HEAT" or name4 == "HESH" or name4 == "ATGM" or name4 == "APHE" then
										name = name4
									elseif name2 == "AP" or name2 == "HE" or name2 == "SM" then
										name = name2
									end
									if name == "APFSDS" then
										self.Modern = 1
									end
									if name == "HEATFS" or name == "ATGM" or name == "HESH" or name == "APDS" then
										self.ColdWar = 1
									end
									self.Ammoboxes[#self.Ammoboxes+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_tegun" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.GunCount = self.GunCount + 1
									self.Guns[#self.Guns+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_teautogun" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.GunCount = self.GunCount + 1
									self.Guns[#self.Guns+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_temachinegun" then
									CurrentRes.DakTankCore = self
									CurrentRes.Controller = self
									self.MachineGunCount = self.MachineGunCount + 1
									self.Guns[#self.Guns+1] = CurrentRes
								end
								if CurrentRes:GetClass()=="dak_turretcontrol" then
									self.TurretControls[#self.TurretControls+1]=CurrentRes
									CurrentRes.DakContraption = res
									CurrentRes.DakCore = self
									CurrentRes.Controller = self
								end
								if CurrentRes:GetClass()=="prop_vehicle_prisoner_pod" then
									self.Seats[#self.Seats+1]=CurrentRes
								end
								if CurrentRes:GetClass()=="dak_crew" then
									self.Crew[#self.Crew+1]=CurrentRes
									CurrentRes.Controller = self
								end
								if CurrentRes:GetClass()=="prop_physics" then
									CurrentRes.Controller = self
									--clip conversion
									if CurrentRes.ClipData and #CurrentRes.ClipData > 0 then
										if CurrentRes.ClipData[1].physics ~= true then
											local Clips = {}
											local curEnt = CurrentRes
											DTArmorSanityCheck(CurrentRes)
											local CurArmor = CurrentRes.DakArmor
											for j=1, #CurrentRes.ClipData do
												local num = #self.Clips+1
												self.Clips[num] = {}
												self.Clips[num].ent = CurrentRes
												self.Clips[num].armor = CurArmor
												self.Clips[num].n = CurrentRes.ClipData[j].n
												self.Clips[num].d = CurrentRes.ClipData[j].d
												self.Clips[num].inside = CurrentRes.ClipData[j].inside
											end
											ProperClipping.RemoveClips(CurrentRes)
											CurrentRes.ClipData = {}
										end
									end

									if CurrentRes.IsComposite == 1 then
										if CurrentRes.EntityMods==nil then
											CurrentRes.EntityMods = {}
											CurrentRes.EntityMods.CompositeType = "NERA"
											CurrentRes.EntityMods.CompKEMult = 9.2
											CurrentRes.EntityMods.CompCEMult = 18.4
											CurrentRes.EntityMods.DakName = "NERA"
											self.Modern = 1
										else
											if CurrentRes.EntityMods.CompositeType == nil then
												CurrentRes.EntityMods.CompositeType = "NERA"
												CurrentRes.EntityMods.CompKEMult = 9.2
												CurrentRes.EntityMods.CompCEMult = 18.4
												CurrentRes.EntityMods.DakName = "NERA"
												self.Modern = 1
											end
										end
									end
									if CurrentRes.EntityMods==nil then
									else
										if CurrentRes.EntityMods.CompositeType == nil and CurrentRes.IsComposite == nil then
											if CurrentRes.EntityMods.ArmorType == nil then
												self.RHAWeight = self.RHAWeight + CurrentRes:GetPhysicsObject():GetMass()
											else
												if CurrentRes.EntityMods.ArmorType == "RHA" then
													CurrentRes.EntityMods.Density = 7.8125
													CurrentRes.EntityMods.ArmorMult = 1
													CurrentRes.EntityMods.Ductility = 1
													self.RHAWeight = self.RHAWeight + CurrentRes:GetPhysicsObject():GetMass()
												end
												if CurrentRes.EntityMods.ArmorType == "CHA" then
													CurrentRes.EntityMods.Density = 7.8125
													CurrentRes.EntityMods.ArmorMult = 1
													CurrentRes.EntityMods.Ductility = 1.5
													self.CHAWeight = self.CHAWeight + CurrentRes:GetPhysicsObject():GetMass()
												end
												if CurrentRes.EntityMods.ArmorType == "HHA" then
													CurrentRes.EntityMods.Density = 7.8125
													CurrentRes.EntityMods.ArmorMult = 1
													CurrentRes.EntityMods.Ductility = 1.5
													self.HHAWeight = self.HHAWeight + CurrentRes:GetPhysicsObject():GetMass()
												end
											end
										else
											if CurrentRes.EntityMods.CompositeType == "NERA" then
												self.Modern = 1
												local Density = 2000
												CurrentRes:GetPhysicsObject():SetMass(math.Round(CurrentRes:GetPhysicsObject():GetVolume()/61023.7*Density))
												self.NERAWeight = self.NERAWeight + CurrentRes:GetPhysicsObject():GetMass()
											end
											if CurrentRes.EntityMods.CompositeType == "Stillbrew" then
												self.Modern = 1
												local Density = 5750
												CurrentRes:GetPhysicsObject():SetMass(math.Round(CurrentRes:GetPhysicsObject():GetVolume()/61023.7*Density))
												self.StillbrewWeight = self.StillbrewWeight + CurrentRes:GetPhysicsObject():GetMass()
											end
											if CurrentRes.EntityMods.CompositeType == "Textolite" then
												self.ColdWar = 1
												local Density = 1850
												CurrentRes:GetPhysicsObject():SetMass(math.Round(CurrentRes:GetPhysicsObject():GetVolume()/61023.7*Density))
												self.TextoliteWeight = self.TextoliteWeight + CurrentRes:GetPhysicsObject():GetMass()
											end
											if CurrentRes.EntityMods.CompositeType == "Concrete" then
												local Density = 2400
												CurrentRes:GetPhysicsObject():SetMass(math.Round(CurrentRes:GetPhysicsObject():GetVolume()/61023.7*Density))
												self.ConcreteWeight = self.ConcreteWeight + CurrentRes:GetPhysicsObject():GetMass()
											end
											if CurrentRes.EntityMods.CompositeType == "ERA" then
												self.ColdWar = 1
												local Density = 1732
												CurrentRes:GetPhysicsObject():SetMass(math.Round(CurrentRes:GetPhysicsObject():GetVolume()/61023.7*Density))
												self.ERAWeight = self.ERAWeight + CurrentRes:GetPhysicsObject():GetMass()
												self.ERA[#self.ERA+1]=CurrentRes
											end
										end
									end
								end
								if CurrentRes:GetPhysicsObject():IsValid() then
									Mass = Mass + CurrentRes:GetPhysicsObject():GetMass()
									if IsValid(CurrentRes:GetParent()) then
										ParentMass = ParentMass + CurrentRes:GetPhysicsObject():GetMass()
									end
									if CurrentRes:GetPhysicsObject():GetSurfaceArea() then
										if CurrentRes:GetPhysicsObject():GetMass()>1 then
											SA = SA + CurrentRes:GetPhysicsObject():GetSurfaceArea()
										end
									else
										self.Tread[#self.Tread+1]=CurrentRes
									end
								end
							end
						end

						if self.Clips and #self.Clips > 0 then
							self.DakOwner:ChatPrint((#self.Clips).." visclips detected, they are now physical clips, please save your vehicle and respawn to finalize.")
							for i=1,#self.Clips do
								if self.Clips ~= nil and self.Clips[i] ~= nil then
									ProperClipping.AddClip(self.Clips[i].ent, self.Clips[i].n:Forward(), self.Clips[i].d, self.Clips[i].inside, true)
									if self.Clips[i].armor ~= nil then
										local SA = self.Clips[i].ent:GetPhysicsObject():GetSurfaceArea()
										local mass = math.ceil(((self.Clips[i].armor/1/(288/SA))/7.8125)*4.6311781,0)
										self.Clips[i].ent.EntityMods.DakClippedArmor = self.Clips[i].armor
										if mass > 0 then
											SetMass( self.DakOwner, self.Clips[i].ent, { Mass = mass } )
											self.Clips[i].ent:GetPhysicsObject():SetMass(mass)
										end
									end
								end
							end
						end

						--PrintTable(self.Contraption)
						self.CrewCount = #self.Crew
						WireLib.TriggerOutput(self, "Crew", self.CrewCount)
						if IsValid(self.Gearbox) then
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
						self.ParMass = ParentMass
						self.PhysMass = Mass-ParentMass
						self.SurfaceArea = SA
						self.SizeMult = (SA/Mass)*0.18
					end

					--local debugtime = SysTime()
					if self.recheckmass == nil or (self.recheckmass >= 0 and self.MassUpdate == 1) then
						--print("secondary run")
						local CurrentRes
						local Mass = 0
						local ParentMass = 0 
						local SA = 0
						for i=1, #self.Contraption do
							CurrentRes = self.Contraption[i]
							if CurrentRes ~= NULL and CurrentRes ~= nil and CurrentRes:IsValid() then
								local physobj = CurrentRes:GetPhysicsObject()
								if CurrentRes.PhysicsClipped == true then
									if CurrentRes.DakMassSet ~= true then
										if CurrentRes.EntityMods.DakClippedArmor ~= nil then
											local SA = physobj:GetSurfaceArea()
											local mass = math.ceil(((CurrentRes.EntityMods.DakClippedArmor/1/(288/SA))/7.8125)*4.6311781,0)
											if mass > 0 then
												SetMass( self.DakOwner, CurrentRes, { Mass = mass } )
												physobj:SetMass(mass)
											end
											CurrentRes.DakMassSet = true
										end
									end
								end
								

								if physobj:IsValid() then
									local physmass = physobj:GetMass()
									Mass = Mass + physmass
									if IsValid(CurrentRes:GetParent()) then
										ParentMass = ParentMass + physmass
									end
								end
							end
						end
						if IsValid(self.Gearbox) then
							self.Gearbox.TotalMass = Mass
							self.Gearbox.ParentMass = ParentMass
							self.Gearbox.PhysicalMass = Mass-ParentMass
						end
						self.TotalMass = Mass
						self.ParMass = ParentMass
						self.PhysMass = Mass-ParentMass
						self.recheckmass = 0
						self.MassUpdate = 0
					end
					--print("Total: "..(SysTime()-debugtime))
					self.recheckmass = self.recheckmass+1

					if table.Count(self.HitBox) == 0 then
						WireLib.TriggerOutput(self, "Health", self.DakHealth)
						WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)
					end
					--SETUP HEALTHPOOL
					if table.Count(self.HitBox) == 0 and self.Contraption and (IsValid(self.Gearbox) or (self.TurretControls~=nil and IsValid(self.TurretControls[1]))) then
						if #self.Contraption>=1 then
							self.Remake = 0
							self.DakPooled = 1
							self.DakEngine = self
							self.Controller = self
							if #self.Contraption>0 then
								local ContraptionCurrent
								self.HitBox = {}
								self.ERA = {}
								for i=1, #self.Contraption do
									ContraptionCurrent = self.Contraption[i]
									if ContraptionCurrent.Controller == nil or ContraptionCurrent.Controller == NULL or ContraptionCurrent.Controller == self then
										if IsValid(ContraptionCurrent) then
											if ContraptionCurrent.DakName == nil and (ContraptionCurrent.EntityMods and ContraptionCurrent.EntityMods.IsERA~=1) then
												if ContraptionCurrent:IsSolid() then
													self.HitBox[#self.HitBox+1] = ContraptionCurrent
													ContraptionCurrent.Controller = self
													ContraptionCurrent.DakOwner = self.DakOwner
													ContraptionCurrent.DakPooled = 1
												end
											else
												if ContraptionCurrent.EntityMods and ContraptionCurrent.EntityMods.IsERA==1 then
													self.ERA[#self.ERA+1] = ContraptionCurrent
													ContraptionCurrent.Controller = self
													ContraptionCurrent.DakOwner = self.DakOwner
													ContraptionCurrent.DakPooled = 1
													ContraptionCurrent.DakHealth = 5
													ContraptionCurrent.DakMaxHealth = 5
												end
											end
											ContraptionCurrent.Controller = self
										end
									end
								end
							end
							self.HitBoxMass = 0
							for i=1, table.Count(self.HitBox) do
								self.HitBoxMass = self.HitBoxMass + self.HitBox[i]:GetPhysicsObject():GetMass()
							end
							self.CurrentHealth = self.BoxVolume*0.01
							self.DakMaxHealth = self.BoxVolume*0.01
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
					--local debugtime = SysTime()
					--####################OPTIMIZE ZONE START###################--
					if self.DakActive == 1 and table.Count(self.HitBox)~=0 and self.CurrentHealth then
						if table.Count(self.HitBox) > 0 then
							self.LivingCrew = 0
							if self.Crew then
								if table.Count(self.Crew) > 0 then
									for i = 1, table.Count(self.Crew) do
										if self.Crew[i].DakDead ~= true then
											self.LivingCrew = self.LivingCrew + 1
										end
										if not(IsValid(self.Crew[i])) then
											table.remove( self.Crew, i )
										end
									end
								end
							end
							
							--print("ERA: "..(SysTime()-debugtime))
							if self.Composites then
								if table.Count(self.Composites) > 0 then
									local weightvalcomp
									for i = 1, table.Count(self.Composites) do
										if not(IsValid(self.Composites[i])) then
											table.remove( self.Composites, i )
										end
										if self.Composites[i] ~= nil then
											self.Composites[i].IsComposite = 1
											local Density = 2000
											local KE = 9.2
											if self.Composites[i].EntityMods.CompositeType == "NERA" then
												self.Modern = 1
												self.Composites[i].EntityMods.CompKEMult = 9.2
												self.Composites[i].EntityMods.CompCEMult = 18.4
												KE = 9.2
												Density = 2000
												self.Composites[i].EntityMods.DakName = "NERA"
											end
											if self.Composites[i].EntityMods.CompositeType == "Stillbrew" then
												self.Modern = 1
												self.Composites[i].EntityMods.CompKEMult = 23
												self.Composites[i].EntityMods.CompCEMult = 27.6
												KE = 23
												Density = 5750
												self.Composites[i].EntityMods.DakName = "Stillbrew"
											end
											if self.Composites[i].EntityMods.CompositeType == "Textolite" then
												self.ColdWar = 1
												self.Composites[i].EntityMods.CompKEMult = 10.4
												self.Composites[i].EntityMods.CompCEMult = 14
												KE = 10.4
												Density = 1850
												self.Composites[i].EntityMods.DakName = "Textolite"
											end
											if self.Composites[i].EntityMods.CompositeType == "Concrete" then
												self.Composites[i].EntityMods.CompKEMult = 2.8
												self.Composites[i].EntityMods.CompCEMult = 2.8
												KE = 2.8
												Density = 2400
												self.Composites[i].EntityMods.DakName = "Concrete"
											end
											if self.Composites[i].EntityMods.CompositeType == "ERA" then
												self.ColdWar = 1
												self.Composites[i].EntityMods.CompKEMult = 2.5
												self.Composites[i].EntityMods.CompCEMult = 88.9
												KE = 2.5
												Density = 1732
												self.Composites[i].EntityMods.DakName = "ERA"
												self.Composites[i].EntityMods.IsERA = 1
											end
											self.Composites[i].IsComposite = 1
											weightvalcomp = math.Round(self.Composites[i]:GetPhysicsObject():GetVolume()/61023.7*Density)
											if self.Composites[i]:GetPhysicsObject():GetMass() ~= weightvalcomp then self.Composites[i]:GetPhysicsObject():SetMass( math.Round(self.Composites[i]:GetPhysicsObject():GetVolume()/61023.7*Density) ) end
											self.Composites[i].DakArmor = 10*KE
										end
									end
								end
							end
							--print("Comps: "..(SysTime()-debugtime))
							local debugtime = SysTime()
							if self.ERA then
								if self:GetParent():GetParent():GetPhysicsObject():IsMotionEnabled() == true then
									self.PhysEra = false
								else
									self.PhysEra = true
								end
								if self.PhysEra ~= self.LastPhysEra and false then
									if self.PhysEra == true then
										self.ERA = {}
										for i=1, #self.ERAInfoTable do
											local cur = self.ERAInfoTable[i]
											local eraplate = ents.Create("prop_physics")
											local parentent = ents.GetByIndex( cur.Parent )
											eraplate:SetModel(cur.Model)
											eraplate:SetPos(parentent:LocalToWorld(cur.LocalPos))
											eraplate:SetAngles(parentent:LocalToWorldAngles(cur.LocalAng))
											eraplate:SetMaterial(cur.Mat)
											eraplate:SetColor(cur.Col)
											eraplate:SetParent(parentent)
											eraplate.EntityMods = cur.EntityMods
											eraplate.DakName = "ERA"
											eraplate.Controller = self
											eraplate.DakOwner = self.DakOwner
											eraplate.DakPooled = 1
											eraplate.DakHealth = 5
											eraplate.DakMaxHealth = 5
											eraplate:PhysicsInit(SOLID_VPHYSICS)
											--eraplate:SetMoveType(MOVETYPE_NONE)
											eraplate:SetSolid(SOLID_VPHYSICS)
											eraplate:CPPISetOwner(self.DakOwner)
											self.ERA[#self.ERA+1] = eraplate
										end
										net.Start( "daktankcoreeraremove" )
										net.WriteEntity( self )
										net.Broadcast()
									 	for i = 1, #self.ERAHandlers do
											self.ERAHandlers[i]:SetMoveType(MOVETYPE_NONE)
											self.ERAHandlers[i]:PhysicsInit(SOLID_NONE)
											self.ERAHandlers[i]:Remove()
										end
										self.ERAHandlers = {}
									else
										self.ERAInfoTable = {}
										for i = 1, table.Count(self.ERA) do
											local cur = self.ERA[i]
											local currentERA = {}
											currentERA.Parent = cur:GetParent():EntIndex()
											if not(IsValid(cur:GetParent().ERAHandler)) then
												cur:GetParent().ERAHandler = ents.Create("prop_physics")
											 	cur:GetParent().ERAHandler:SetAngles(cur:GetParent():GetForward():Angle())
											 	cur:GetParent().ERAHandler:SetPos(cur:GetParent():GetPos())
											 	cur:GetParent().ERAHandler:SetMoveType(MOVETYPE_NONE)
											 	cur:GetParent().ERAHandler:PhysicsInit(SOLID_NONE)
											 	cur:GetParent().ERAHandler:SetParent(cur:GetParent())
											 	cur:GetParent().ERAHandler:SetModel( "models/props_junk/PopCan01a.mdl" )
											 	cur:GetParent().ERAHandler:DrawShadow(false)
											 	cur:GetParent().ERAHandler:SetColor( Color(255, 255, 255, 0) )
											 	cur:GetParent().ERAHandler:SetRenderMode( RENDERMODE_TRANSCOLOR )
											 	cur:GetParent().ERAHandler:Spawn()
											 	cur:GetParent().ERAHandler:Activate()
											 	cur:GetParent().ERAHandler:SetMoveType(MOVETYPE_NONE)
											 	cur:GetParent().ERAHandler:PhysicsInit(SOLID_NONE)
											 	ERAHandler:CPPISetOwner(self.DakOwner)
											 	if self.ERAHandlers == nil then self.ERAHandlers = {} end
												self.ERAHandlers[#self.ERAHandlers+1] = cur:GetParent().ERAHandler
											end
											currentERA.Model = cur:GetModel()
											currentERA.LocalPos = cur:GetParent():WorldToLocal(cur:GetPos())
											currentERA.LocalAng = cur:GetParent():WorldToLocalAngles(cur:GetAngles())
											currentERA.Mat = cur:GetMaterial()
											currentERA.Col = cur:GetColor()
											currentERA.Mass = cur:GetPhysicsObject():GetMass()
											currentERA.EntityMods = cur.EntityMods
											local a,b = cur:GetPhysicsObject():GetAABB()
											a:Rotate(cur:GetAngles())
											b:Rotate(cur:GetAngles())
											currentERA.mins = a
											currentERA.maxs = b
											cur:Remove()
											self.ERAInfoTable[#self.ERAInfoTable+1] = currentERA
										end
										for j = 1, #self.ERAHandlers do
											local VectorTables = {}
											local Mass = 0
											for i = 1, #self.ERAInfoTable do
												Mass = Mass + self.ERAInfoTable[i].Mass
												if ents.GetByIndex( self.ERAInfoTable[i].Parent ) == self.ERAHandlers[j]:GetParent() then
													local addition = self.ERAInfoTable[i].LocalPos
													local min = self.ERAInfoTable[i].mins + addition
													local max = self.ERAInfoTable[i].maxs + addition
													VectorTables[#VectorTables+1] = {
														Vector( min.y, min.y, min.z ),
														Vector( min.x, min.y, max.z ),
														Vector( min.x, max.y, min.z ),
														Vector( min.x, max.y, max.z ),
														Vector( max.x, min.y, min.z ),
														Vector( max.x, min.y, max.z ),
														Vector( max.x, max.y, min.z ),
														Vector( max.x, max.y, max.z )
													}
													debugoverlay.Box( ents.GetByIndex( self.ERAInfoTable[i].Parent ):LocalToWorld( self.ERAInfoTable[i].LocalPos ), self.ERAInfoTable[i].mins, self.ERAInfoTable[i].maxs, 10, Color( math.random(0,255), math.random(0,255), math.random(0,255) ) )
												end
											end
											self.ERAHandlers[j]:PhysicsDestroy()
											self.ERAHandlers[j]:PhysicsInitMultiConvex(VectorTables)
											self.ERAHandlers[j]:SetSolid( SOLID_VPHYSICS )
											--self.ERAHandlers[j]:SetParent()
											self.ERAHandlers[j]:SetMoveType( MOVETYPE_NONE )
											self.ERAHandlers[j]:EnableCustomCollisions( true )
											self.ERAHandlers[j].IsEraHandler = true
											self.ERAHandlers[j].IsComposite = 1
											self.ERAHandlers[j].EntityMods = {}
											self.ERAHandlers[j].EntityMods.CompKEMult = 2.5
											self.ERAHandlers[j].EntityMods.CompCEMult = 88.9
											self.ERAHandlers[j].DakArmor = 10*self.ERAHandlers[j].EntityMods.CompKEMult
											self.ERAHandlers[j].DakHealth = 9999999
											self.ERAHandlers[j].DakMaxHealth = 9999999
											self.ERAHandlers[j].EntityMods.IsERA = 1
											self.ERAHandlers[j].EntityMods.DakName = "ERA HANDLER"
											self.ERAHandlers[j]:GetPhysicsObject():SetMass(Mass)
										end
										for i=1, math.ceil(#self.ERAInfoTable/50) do
											local tablesegment = {}
											for j=1+((i-1)*50), 50+((i-1)*50) do
												tablesegment[#tablesegment+1] = self.ERAInfoTable[j]
											end
											net.Start( "daktankcoreera" )
											net.WriteEntity( self )
											net.WriteString( util.TableToJSON( tablesegment ) )
											net.Broadcast()
										end
										self.ERA = {}
									end
									self.LastPhysEra = self.PhysEra
								end
								if table.Count(self.ERA) > 0 then
									local effectdata
									local ExpSounds = {"daktanks/eraexplosion.mp3"}
									local EntMod 
									for i = 1, table.Count(self.ERA) do
										if not(IsValid(self.ERA[i])) then
											table.remove( self.ERA, i )
										end
										if self.ERA[i] ~= nil and self.ERA[i] ~= NULL then
											EntMod = self.ERA[i].EntityMods
											if self.ERA[i].IsComposite ~= 1 then self.ERA[i].IsComposite = 1 end
											if EntMod.CompKEMult ~= 2.5 then EntMod.CompKEMult = 2.5 end
											if EntMod.CompCEMult ~= 88.9 then EntMod.CompCEMult = 88.9 end
											if self.ERA[i].DakName ~= "ERA" then self.ERA[i].DakName = "ERA" end
											if self.ERA[i].IsERA ~= 1 then self.ERA[i].IsERA = 1 end
											if self.ColdWar ~= 1 then self.ColdWar = 1 end
											if self.ERA[i].DakHealth <= 0 then
												effectdata = EffectData()
												effectdata:SetOrigin(self.ERA[i]:GetPos())
												effectdata:SetEntity(self)
												effectdata:SetAttachment(1)
												effectdata:SetMagnitude(.5)
												effectdata:SetScale(50)
												effectdata:SetNormal( Vector(0,0,0) )
												util.Effect("daktescalingexplosionold", effectdata, true, true)
												sound.Play( ExpSounds[math.random(1,#ExpSounds)], self.ERA[i]:GetPos(), 100, 100, 1 )
												self.ERA[i]:DTExplosion(self.ERA[i]:GetPos(),25,50,40,5,self.DakOwner)
												self.ERA[i]:Remove()
											end
										end
									end
									local weightval
									for i = 1, table.Count(self.ERA) do
										if IsValid(self.ERA[i]) then
											if self.ERA[i].EntityMods then
												if self.ERA[i].EntityMods.CompositeType == "ERA" then
													self.ColdWar = 1
													self.ERA[i].EntityMods.CompKEMult = 2.5
													self.ERA[i].EntityMods.CompCEMult = 88.9
													self.ERA[i].EntityMods.DakName = "ERA"
													self.ERA[i].EntityMods.IsERA = 1
												end
												local weightval = math.Round(self.ERA[i]:GetPhysicsObject():GetVolume()/61023.7*1732) 
												if self.ERA[i]:GetPhysicsObject():GetMass() ~= weightval then self.ERA[i]:GetPhysicsObject():SetMass( weightval ) end
												self.ERA[i].DakArmor = 2.5
											end
										end
									end
								end
							end
							if self.DETAIL then
								if self:GetParent():GetParent():GetPhysicsObject():IsMotionEnabled() == true then
									self.PhysDetail = false
								else
									self.PhysDetail = true
								end
								if self.PhysDetail ~= self.LastPhysDetail then
									if self.PhysDetail == true then
										self.DETAIL = {}
										for i=1, #self.DetailInfoTable do
											local cur = self.DetailInfoTable[i]
											local detailpiece = ents.Create("prop_physics")
											local parentent = ents.GetByIndex( cur.Parent )
											detailpiece:SetModel(cur.Model)
											detailpiece:SetPos(parentent:LocalToWorld(cur.LocalPos))
											detailpiece:SetAngles(parentent:LocalToWorldAngles(cur.LocalAng))
											detailpiece:SetMaterial(cur.Mat)
											for j=1, #cur.SubMaterials do
												detailpiece:SetSubMaterial( j, cur.SubMaterials[j] )
											end
											detailpiece:SetColor(cur.Col)
											detailpiece:SetParent(parentent)
											detailpiece.EntityMods = cur.EntityMods
											--detailpiece.ClipData = cur.ClipData
											detailpiece:PhysicsInit(SOLID_VPHYSICS)
											--detailpiece:SetMoveType(MOVETYPE_NONE)
											detailpiece:SetSolid(SOLID_VPHYSICS)
											detailpiece:CPPISetOwner(self.DakOwner)
											if cur.ClipData ~= nil then
												for j=1, #cur.ClipData do
													ProperClipping.AddClip(detailpiece, cur.ClipData[j].n:Forward(), cur.ClipData[j].d, cur.ClipData[j].inside, true)
												end
											end
											self.DETAIL[#self.DETAIL+1] = detailpiece
										end
										net.Start( "daktankcoredetailremove" )
										net.WriteEntity( self )
										net.Broadcast()
									else
										self.DetailInfoTable = {}
										for i = 1, table.Count(self.DETAIL) do
											local cur = self.DETAIL[i]
											local currentDetail = {}
											currentDetail.Parent = cur:GetParent():EntIndex()
											currentDetail.Model = cur:GetModel()
											currentDetail.LocalPos = cur:GetParent():WorldToLocal(cur:GetPos())
											currentDetail.LocalAng = cur:GetParent():WorldToLocalAngles(cur:GetAngles())
											currentDetail.Mat = cur:GetMaterial()
											currentDetail.Col = cur:GetColor()
											currentDetail.EntityMods = cur.EntityMods
											currentDetail.ClipData = cur.ClipData
											currentDetail.SubMaterials = {}
											for j = 0, 31 do
												currentDetail.SubMaterials[j] = cur:GetSubMaterial( j )
											end
											cur:Remove()
											self.DetailInfoTable[#self.DetailInfoTable+1] = currentDetail
										end
										for i=1, math.ceil(#self.DetailInfoTable/50) do
											local tablesegment = {}
											for j=1+((i-1)*50), 50+((i-1)*50) do
												tablesegment[#tablesegment+1] = self.DetailInfoTable[j]
											end
											net.Start( "daktankcoredetail" )
											net.WriteEntity( self )
											net.WriteString( util.TableToJSON( tablesegment ) )
											net.Broadcast()
										end
										self.DETAIL = {}
									end
									self.LastPhysDetail = self.PhysDetail
								end
							end
							--print("Total: "..(SysTime()-debugtime))
							--print("ERA2: "..(SysTime()-debugtime))
							self.DamageCycle = 0
							self.LastDamagedBy = NULL
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
											if self.HitBox[i].EntityMods.IsERA == 1 then
												table.RemoveByValue( self.Composites, NULL )
												table.RemoveByValue( self.HitBox, NULL )
											end
											self.DamageCycle = self.DamageCycle+(self.CurrentHealth-self.HitBox[i].DakHealth)
											self.DakLastDamagePos = self.HitBox[i].DakLastDamagePos
											self.LastDamagedBy = self.HitBox[i].LastDamagedBy
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
							--print("Hitbox: "..(SysTime()-debugtime))
							if not(self.CurMass>self.LastCurMass) then
								if self.DamageCycle>0 then
									if self.LastRemake+3 > CurTime() then
										self.DamageCycle = 0
									end
									self.CurrentHealth = self.CurrentHealth-self.DamageCycle
								end
							end
							if self.CurrentHealth >= self.DakMaxHealth then
								self.DakMaxHealth = self.BoxVolume*0.01
								self.CurrentHealth = self.BoxVolume*0.01
							end
							for i = 1, table.Count(self.HitBox) do
								if self.CurrentHealth >= self.DakMaxHealth then
									self.HitBox[i].DakMaxHealth = self.BoxVolume*0.01
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
										if self.Crew[i].DakOwner:IsPlayer() then
											if self.Crew[i].Job == 1 then
												self.Crew[i].DakOwner:ChatPrint("Gunner Killed!") 
											elseif self.Crew[i].Job == 2 then
												self.Crew[i].DakOwner:ChatPrint("Driver Killed!") 
											elseif self.Crew[i].Job == 3 then
												self.Crew[i].DakOwner:ChatPrint("Loader Killed!") 
											else
												self.Crew[i].DakOwner:ChatPrint("Passenger Killed!") 
											end
										end
										self.Crew[i]:SetMaterial("models/flesh")
										self.Crew[i].DakDead = true
									end

								end
							end
							self.LastVel = curvel


							WireLib.TriggerOutput(self, "Health", self.DakHealth)
							WireLib.TriggerOutput(self, "HealthPercent", (self.DakHealth/self.DakMaxHealth)*100)


					--####################OPTIMIZE ZONE END###################--
					--print("Total: "..(SysTime()-debugtime))
							if self.DakHealth then
								if (self.DakHealth <= 0 or #self.Crew < 2 or self.LivingCrew < 2 or (gmod.GetGamemode().Name=="DakTank" and self.LegalUnfreeze ~= true)) and self:GetParent():GetParent():GetPhysicsObject():IsMotionEnabled() then
									local DeathSounds = {"daktanks/closeexp1.mp3","daktanks/closeexp2.mp3","daktanks/closeexp3.mp3"}
									self.RemoveTurretList = {}
									if math.random(1,100) <= self:GetTurretPop() then
										for j=1, #self.TurretControls do
											if IsValid(self.TurretControls[j]) then
												table.RemoveByValue( self.Contraption, self.TurretControls[j].TurretBase )
												if IsValid(self.TurretControls[j].TurretBase) then
													self.TurretControls[j].TurretBase:SetMaterial("models/props_buildings/plasterwall021a")
													self.TurretControls[j].TurretBase:SetColor(Color(100,100,100,255))
													self.TurretControls[j].TurretBase:SetCollisionGroup( COLLISION_GROUP_WORLD )
													--self.TurretControls[j].TurretBase:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
													sound.Play( DeathSounds[math.random(1,#DeathSounds)], self.TurretControls[j].TurretBase:GetPos(), 100, 100, 0.25 )
													if math.random(0,9) == 0 then
														self.TurretControls[j].TurretBase:Ignite(25,1)
													end
													if IsValid(self) then
														if IsValid(self:GetParent()) then
															if IsValid(self:GetParent():GetParent()) then
																constraint.RemoveAll( self:GetParent():GetParent() )
															end
														end
													end
													for l=1, #self.TurretControls[j].Turret do
														if self.TurretControls[j].Turret[l] ~= self.TurretControls[j].TurretBase and self.TurretControls[j].Turret[l] ~= self.TurretControls[j].turretaimer then
															if IsValid(self.TurretControls[j].Turret[l]) then
																table.RemoveByValue( self.Contraption, self.TurretControls[j].Turret[l] )
																self.TurretControls[j].Turret[l]:SetParent( self.TurretControls[j].TurretBase, -1 )
																self.TurretControls[j].Turret[l]:SetMoveType( MOVETYPE_NONE )
																self.TurretControls[j].Turret[l]:SetMaterial("models/props_buildings/plasterwall021a")
																self.TurretControls[j].Turret[l]:SetColor(Color(100,100,100,255))
																self.TurretControls[j].Turret[l]:SetCollisionGroup( COLLISION_GROUP_WORLD )
																if self.TurretControls[j].Turret[l]:GetModel() == "models/daktanks/machinegun100mm.mdl" then
																	self.TurretControls[j].Turret[l]:Remove()
																end
																--self.TurretControls[j].Turret[l]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
																sound.Play( DeathSounds[math.random(1,#DeathSounds)], self.TurretControls[j].Turret[l]:GetPos(), 100, 100, 0.25 )
																if self.TurretControls[j].Turret[l]:IsVehicle() then
																	if IsValid(self.TurretControls[j].Turret[l]:GetDriver()) then
																		self.TurretControls[j].Turret[l]:GetDriver():SetNoDraw( false )
																		self.TurretControls[j].Turret[l]:GetDriver():TakeDamage( 1000000, self.LastDamagedBy, self )
																		--self.TurretControls[j].Turret[l]:GetDriver():Kill()
																	end
																	self.TurretControls[j].Turret[l]:Remove()
																end
																if math.random(0,9) == 0 then
																	self.TurretControls[j].Turret[l]:Ignite(25,1)
																end
																if self.TurretControls[j].Turret[l]:GetClass() == "dak_teammo" then
																	if math.random(0,1) == 0 then
																		self.TurretControls[j].Turret[l]:Ignite(25,1)
																	end
																end
															end
														end
													end

													TurretPhys = ents.Create("prop_physics")
												 	TurretPhys:SetAngles(self.TurretControls[j].turretaimer:GetAngles())
												 	TurretPhys:SetPos(self.TurretControls[j].turretaimer:GetPos())
												 	TurretPhys:SetModel( self.TurretControls[j].TurretBase:GetModel() )
												 	TurretPhys:SetParent(TurretPhys)
												 	TurretPhys:DrawShadow(false)
												 	TurretPhys:SetColor( Color(255, 255, 255, 0) )
												 	TurretPhys:SetRenderMode( RENDERMODE_TRANSCOLOR )
												 	TurretPhys.DakIsTread = true
												 	TurretPhys:Spawn()
												 	TurretPhys:Activate()
												 	--TurretPhys:SetMoveType(MOVETYPE_VPHYSICS)
												 	--TurretPhys:PhysicsInit(SOLID_VPHYSICS)

												 	self.TurretControls[j].turretaimer:SetParent(TurretPhys)

													TurretPhys:SetAngles(self.TurretControls[j].turretaimer:GetAngles() + Angle(math.Rand(-15,15),math.Rand(-15,15),math.Rand(-15,15)))
													TurretPhys:GetPhysicsObject():SetMass(self.TurretControls[j].GunMass)
													TurretPhys:GetPhysicsObject():ApplyForceCenter(TurretPhys:GetUp()*2500*self:GetTurretPopForceMult()*TurretPhys:GetPhysicsObject():GetMass())
													TurretPhys:GetPhysicsObject():AddAngleVelocity(VectorRand()*500*self:GetTurretPopForceMult())
													self.RemoveTurretList[#self.RemoveTurretList+1] = self.TurretControls[j].TurretBase
													self.RemoveTurretList[#self.RemoveTurretList+1] = self.TurretControls[j].turretaimer
													self.RemoveTurretList[#self.RemoveTurretList+1] = TurretPhys
												end
											end
										end
									end

									for i=1, #self.Contraption do
										if IsValid(self.Contraption[i]) then
											if self.Contraption[i]:GetModel() == "models/daktanks/machinegun100mm.mdl" then
												self.Contraption[i]:Remove()
											else
												if self.Contraption[i].DakPooled == 0 or self.Contraption[i]:GetParent()==self:GetParent() or self.Contraption[i].Controller == self then
													self.Contraption[i].DakLastDamagePos = self.DakLastDamagePos
													if self.Contraption[i] ~= self:GetParent():GetParent() and self.Contraption[i] ~= self:GetParent() and self.Contraption[i] ~= self and self.Contraption[i].turretaimer ~= true then
														if math.random(1,6)>1 then
															if self.Contraption[i]:GetClass() == "dak_tegearbox" or self.Contraption[i]:GetClass() == "dak_tegearboxnew" or self.Contraption[i]:GetClass() == "dak_turretcontrol" or self.Contraption[i]:GetClass() == "gmod_wire_expression2" then
																self.salvage = ents.Create( "dak_tesalvage" )
																if ( !IsValid( self.salvage ) ) then return end
																if self.Contraption[i]:GetClass() == "dak_crew" then
																	if self.Contraption[i].DakHealth <= 0 then
																		for i=1, 15 do
																			util.Decal( "Blood", self.Contraption[i]:GetPos(), self.Contraption[i]:GetPos()+(VectorRand()*500), self.Contraption[i])
																		end
																	end
																end

																self.salvage.DakModel = self.Contraption[i]:GetModel()
																self.salvage:SetPos( self.Contraption[i]:GetPos())
																self.salvage:SetAngles( self.Contraption[i]:GetAngles())
																self.salvage:SetModelScale(self.Contraption[i]:GetModelScale())
																self.salvage:Spawn()
																self.Contraption[i]:Remove()
															else
																constraint.RemoveAll( self.Contraption[i] )
																self.Contraption[i]:SetParent( self:GetParent(), -1 )
																self.Contraption[i]:SetMoveType( MOVETYPE_NONE )
																self.Contraption[i]:SetMaterial("models/props_buildings/plasterwall021a")
																self.Contraption[i]:SetColor(Color(100,100,100,255))
																self.Contraption[i]:SetCollisionGroup( COLLISION_GROUP_WORLD )
																--self.Contraption[i]:EmitSound( DeathSounds[math.random(1,#DeathSounds)], 100, 100, 0.25, 3)
																sound.Play( DeathSounds[math.random(1,#DeathSounds)], self.Contraption[i]:GetPos(), 100, 100, 0.25 )
																if math.random(0,9) == 0 then
																	self.Contraption[i]:Ignite(25,1)
																end
																if self.Contraption[i]:GetClass() == "dak_teammo" then
																	if math.random(0,1) == 0 then
																		self.Contraption[i]:Ignite(25,1)
																	end
																end
															end
														else
															self.salvage = ents.Create( "dak_tesalvage" )
															if ( !IsValid( self.salvage ) ) then return end
															self.salvage.launch = 1
															if self.Contraption[i]:GetClass() == "dak_crew" then
																if self.Contraption[i].DakHealth <= 0 then
																	for i=j, 15 do
																		util.Decal( "Blood", self.Contraption[i]:GetPos(), self.Contraption[i]:GetPos()+(VectorRand()*500), self.Contraption[i])
																	end
																end
															end
															self.salvage.DakModel = self.Contraption[i]:GetModel()
															self.salvage:SetPos( self.Contraption[i]:GetPos())
															self.salvage:SetAngles( self.Contraption[i]:GetAngles())
															self.salvage:SetModelScale(self.Contraption[i]:GetModelScale())
															self.salvage:Spawn()
															self.Contraption[i]:Remove()
														end
														if self.Contraption[i]:IsVehicle() then
															if IsValid(self.Contraption[i]:GetDriver()) then
																self.Contraption[i]:GetDriver():SetNoDraw( false )
																self.Contraption[i]:GetDriver():TakeDamage( 1000000, self.LastDamagedBy, self )
																--self.Contraption[i]:GetDriver():Kill()
															end
															self.Contraption[i]:Remove()
														end
													end
												end
											end
										end
									end
									self.Dead=1
									self.DeathTime=CurTime()
									net.Start( "daktankcoredie" )
									net.WriteEntity( self )
									net.Broadcast()
									local effectdata = EffectData()
									effectdata:SetOrigin(self:GetParent():GetParent():GetPos())
									effectdata:SetEntity(self)
									effectdata:SetAttachment(1)
									effectdata:SetMagnitude(.5)
									effectdata:SetNormal( Vector(0,0,-1) )
									effectdata:SetScale(math.Clamp(self.DakMaxHealth*0.04,100,500))
									util.Effect("daktescalingexplosionold", effectdata)
								end
							else
								self:Remove()
							end

						end
					end
				else
					if self.DeathTime then
						if self.DeathTime+30<CurTime() then
							self.AutoRemoved = true
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
				if self.SpawnTime+30 < CurTime() then
					self.DakOwner:PrintMessage( HUD_PRINTTALK, "Tank Core Error: Gate that tank core is parented to is not parented, please parent it to the baseplate." )
				end
			end
		else
			if self.SpawnTime+30 < CurTime() then
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
	if self.Composites ~= nil then
		if table.Count(self.Composites)>0 then
			for i = 1, table.Count(self.Composites) do
				if not(self.Composites[i]==nil) then
					table.insert(CompositesIDs,self.Composites[i]:EntIndex())
				end
			end
		end
		info.CompositesCount = table.Count(self.Composites)
	end

	local ERAIDs = {}
	if self.ERA ~= nil then
		if table.Count(self.ERA)>0 then
			for i = 1, table.Count(self.ERA) do
				if not(self.ERA[i]==nil) then
					table.insert(ERAIDs,self.ERA[i]:EntIndex())
				end
			end
		end
		info.ERACount = table.Count(self.ERA)
	end

	local DupeClips = {}
	if self.Contraption~= nil then 
		if table.Count(self.Contraption)>0 then
			for i=1, #self.Contraption do
				local CurrentRes = self.Contraption[i]
				if CurrentRes ~= NULL and CurrentRes ~= nil then
					local physobj = CurrentRes:GetPhysicsObject()
					if CurrentRes.EntityMods ~= nil then
						if CurrentRes.EntityMods.DakClippedArmor ~= nil then
							local clip = {}
							clip.ID = CurrentRes:EntIndex()
							clip.Armor = CurrentRes.DakArmor
							DupeClips[#DupeClips+1] = clip
						else
							CurrentRes.EntityMods.DakClippedArmor = CurrentRes.DakArmor
							local clip = {}
							clip.ID = CurrentRes:EntIndex()
							clip.Armor = CurrentRes.DakArmor
							DupeClips[#DupeClips+1] = clip
						end
					end
				end
			end
		end
	end

	info.DakName = self.DakName
	info.DakHealth = self.DakHealth
	info.DakMaxHealth = self.DakBaseMaxHealth
	info.DakMass = self.DakMass
	info.DakOwner = self.DakOwner
	duplicator.StoreEntityModifier( self, "DakTek", info )
	duplicator.StoreEntityModifier( self, "DTComposites", CompositesIDs )
	duplicator.StoreEntityModifier( self, "DTERA", ERAIDs )
	duplicator.StoreEntityModifier( self, "DTClips", DupeClips )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	self.dupespawned = true

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
		if Ent.EntityMods.DakTek.ERACount == nil then
			self.NewERA = {}
			if Ent.EntityMods.DTERA then
				for i = 1, table.Count(Ent.EntityMods.DTERA) do
					self.Ent = CreatedEntities[ Ent.EntityMods.DTERA[i]]
					if self.Ent and IsValid(self.Ent) then
						table.insert(self.NewERA,self.Ent)
					end
				end
			end
			self.ERA = self.NewERA
		else
			if Ent.EntityMods.DakTek.ERACount > 0 then
				self.NewERA = {}
				if Ent.EntityMods.DTERA then
					for i = 1, Ent.EntityMods.DakTek.ERACount do
						local hitEnt = CreatedEntities[ Ent.EntityMods.DTERA[i]]
						if IsValid(hitEnt) then
							table.insert(self.NewERA,hitEnt)
						end
					end
				end
				self.ERA = self.NewERA
			else
				self.ERA = {}
			end
		end
		
		if Ent.EntityMods.DTClips ~= nil then
			for i=1, #Ent.EntityMods.DTClips do
				local cur = CreatedEntities[ Ent.EntityMods.DTClips[i].ID ]
				if IsValid(cur) and cur.EntityMods.DakClippedArmor ~= nil then
					cur.EntityMods.DakClippedArmor = Ent.EntityMods.DTClips[i].Armor
					local SA = cur:GetPhysicsObject():GetSurfaceArea()
					local mass = math.ceil(((Ent.EntityMods.DTClips[i].Armor/1/(288/SA))/7.8125)*4.6311781,0)
					cur.EntityMods.DakClippedArmor = Ent.EntityMods.DTClips[i].Armor
					if mass > 0 then
						SetMass( self.DakOwner, cur, { Mass = mass } )
						cur:GetPhysicsObject():SetMass(mass)
					end
				end
			end
		end


		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		Ent.EntityMods.DakTek = nil
	end
	self.PreCostTimerFirst = CurTime()
	self.DakOwner = Player
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end

function ENT:OnRemove()
	if self.Contraption and #self.Contraption>0 then
		for i=1, #self.Contraption do
			if self.Contraption[i]:IsVehicle() then
				if IsValid(self.Contraption[i]:GetDriver()) then
					self.Contraption[i]:GetDriver():SetNoDraw( false )
				end
			end
		end
	end
	if table.Count(self.HitBox)>0 then
		for i = 1, table.Count(self.HitBox) do
			self.HitBox[i].DakPooled = 0
			self.HitBox[i].DakController = nil
		end
	end
	if gmod.GetGamemode().Name=="DakTank" then
		if self.LastDamagedBy:IsValid() and self.AutoRemoved~=true then
			if self.LastDamagedBy:Team() ~= self.DakOwner:Team() then
				local PointsGained
				if Era == "WWII" then
					PointsGained = 5
				elseif Era == "Cold War" then
					PointsGained = 10
				else
					PointsGained = 20
				end
				net.Start( "DT_killnotification" )
					net.WriteInt(2, 32)
					net.WriteInt(PointsGained, 32)
				net.Send( self.LastDamagedBy )
				if not(self.LastDamagedBy:InVehicle()) then self.LastDamagedBy:addPoints( PointsGained ) end
				if self.DakOwner:Team() == 1 then
					SetGlobalFloat("DakTankRedResources", GetGlobalFloat("DakTankRedResources") - 5 )
				elseif self.DakOwner:Team() == 2 then
					SetGlobalFloat("DakTankBlueResources", GetGlobalFloat("DakTankBlueResources") - 5 )
				end
			end
		end
	end
end

