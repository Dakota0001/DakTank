include("shared.lua")

local Shader = {
    ["$basetexture"] = "models/debug/debugwhite",
    ["$alphatest"]   = "1",
    ["$nocull"]      = "1",

    ["$phong"]              = "1",
    ["$phongboost"]         = "0.1",
    ["$phongfresnelranges"] = "[0 0.5 0.5]",
    ["$phongexponent"]      = "15",
    ["$phongalbedotint"]    = "1",

    ["$angle"]     = "-90",
    ["$translate"] = "[0.0 0.0 0.0]",
    ["$center"]    = "[0.5 0.5 0.5]",
    ["$newscale"]  = "[1.0 1.0 1.0]",

    ["Proxies"] = {
        ["TextureTransform"] = {
            ["translateVar"] = "$translate",
            ["scaleVar"]     = "$newscale",
            ["rotateVar"]    = "$angle",
            ["centerVar"]    = "$center",
            ["resultVar"]    = "$basetexturetransform",
        },
    }
}
local data1 = table.Copy(Shader)
local data2 = table.Copy(Shader)
data1["$basetexture"] = "WTP/textures/track_2"
data2["$basetexture"] = "WTP/textures/track_2"
local TreadMatRight = CreateMaterial("DakTankTreadMaterialRight" .. SysTime(), "VertexLitGeneric", data1)
local TreadMatLeft = CreateMaterial("DakTankTreadMaterialLeft" .. SysTime(), "VertexLitGeneric", data2)
function quickhull(points)
    local p = #points

    local cross = function(p, q, r)
        return (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
    end

    table.sort(points, function(a, b)
        return a[1] == b[1] and a[2] > b[2] or a[1] > b[1]
    end)

    local lower = {}
    for i = 1, p do
        while (#lower >= 2 and cross(lower[#lower - 1], lower[#lower], points[i]) <= 0) do
            table.remove(lower, #lower)
        end

        --table.insert(lower, points[i])
        lower[#lower + 1] = points[i]
    end

    local upper = {}
    for i = p, 1, -1 do
        while (#upper >= 2 and cross(upper[#upper - 1], upper[#upper], points[i]) <= 0) do
            table.remove(upper, #upper)
        end

        --table.insert(upper, points[i])
        upper[#upper + 1] = points[i]
    end

    table.remove(upper, #upper)
    table.remove(lower, #lower)
    for _, point in ipairs(lower) do
        --table.insert(upper, point)
        upper[#upper + 1] = point
    end

    return upper
end
function ENT:Draw()
	self:DrawModel()
	local treadmodel = ClientsideModel("models/sprops/rectangles/size_2/rect_12x12x3.mdl")
	local wheelmodel = ClientsideModel( self:GetWheelModel() )
	local wheelmins, wheelmaxs = wheelmodel:GetHitBoxBounds(0,0)
	local wheelbounds = (wheelmaxs - wheelmins)*0.5
	local wheelmodelZ = wheelbounds[3]
	--if (self.lastslowthink == nil) or CurTime() >= self.lastslowthink+1 then 
		self.SideDist = self:GetSideDist()
	 	self.TrackLength = self:GetTrackLength()
	 	self.WheelsPerSide = self:GetWheelsPerSide()
	 	self.RideHeight = self:GetRideHeight()
	 	self.FrontWheelRaise = self:GetFrontWheelRaise()
	 	self.RearWheelRaise = self:GetRearWheelRaise()
	 	self.ForwardOffset = self:GetForwardOffset()
	 	self.RideLimit = self:GetRideLimit()

	 	self.WheelWidth = self:GetWheelWidth()
	 	self.WheelHeight = self:GetWheelHeight()
	 	self.FrontWheelHeight = self:GetFrontWheelHeight()
	 	self.RearWheelHeight = self:GetRearWheelHeight()
	 	self.TreadWidth = self:GetTreadWidth()
	 	self.TreadHeight = self:GetTreadHeight()

	 	self.WheelColor = self:GetWheelColor()
	 	self.TreadColor = self:GetTreadColor()
	 	--self.lastslowthink = CurTime() 
	--end
	if self.RightScroll == nil then self.RightScroll = 0 end
	if self.LeftScroll == nil then self.LeftScroll = 0 end
	local wheelwidthmult = self.WheelWidth/(math.Min(wheelbounds[1],wheelbounds[2],wheelbounds[3]))*0.5
	local Width = self.TreadWidth/12
	local Height = self.TreadHeight/3
 	local SideDist = self.SideDist
 	local TrackLength = self.TrackLength
 	local WheelsPerSide = self.WheelsPerSide
 	local RideHeight = self.RideHeight
 	local FrontWheelRaise = self.FrontWheelRaise
 	local RearWheelRaise = self.RearWheelRaise
 	local ForwardOffset = self.ForwardOffset
 	local RideLimit = self.RideLimit
 	local ForwardEnt = self:GetNWEntity("ForwardEnt")
 	local Base = self:GetNWEntity("Base")
 	local WheelHeight = self.WheelHeight
	local FrontWheelHeight = self.FrontWheelHeight
	local RearWheelHeight = self.RearWheelHeight
	local WheelColor = self.WheelColor
	local TreadColor = self.TreadColor

	self:SetRenderBounds( Vector(-1000,-1000,-50),Vector(1000,1000,50) )
	self:DrawShadow(false)
	--print(WheelColor)
	wheelmodel:SetColor(Color( 255, 0, 0, 255 ))
 	--check for base and forward ent are not null
 	if ForwardEnt:IsValid() and Base:IsValid() then
	 	if (self.RightAngTable == nil and WheelsPerSide>0) or self.LastWheelsPerSide~=WheelsPerSide then
			self.RightAngTable = {}
			self.RightPosTable = {}
			for i=1, WheelsPerSide do
				self.RightAngTable[i] = 0
				self.RightPosTable[i] = Vector(0,0,0)
			end
		end
		if (self.LeftAngTable == nil and WheelsPerSide>0) or self.LastWheelsPerSide~=WheelsPerSide then
			self.LeftAngTable = {}
			self.LeftPosTable = {}
			for i=1, WheelsPerSide do
				self.LeftAngTable[i] = 0
				self.LeftPosTable[i] = Vector(0,0,0)
			end
		end
		local Speed
		local RotateAngle

	 	local trace
	 	local CurTrace 
	 	local Pos
	 	local lastvel
	 	local scale
		local mat
		local WheelMult
		local WheelHeightMult
		for i=1, WheelsPerSide do
			if i == 1 then
				WheelMult = RearWheelHeight
			elseif i == WheelsPerSide then
				WheelMult = FrontWheelHeight
			else
				WheelMult = WheelHeight
			end
			WheelHeightMult = WheelMult/(wheelbounds[3]*2)
			Pos = Base:GetPos() + (ForwardEnt:GetForward()*(((i-1)*TrackLength/(WheelsPerSide-1)) - (TrackLength*0.5) + (ForwardOffset))) + (ForwardEnt:GetRight()*SideDist)
			trace = {}
				trace.start = Pos + ForwardEnt:GetUp()*RideHeight
				if i==WheelsPerSide then 
					trace.endpos = Pos + ForwardEnt:GetUp()*(-RideHeight+FrontWheelRaise)
				elseif i==1 then
					trace.endpos = Pos + ForwardEnt:GetUp()*(-RideHeight+RearWheelRaise)
				else
					trace.endpos = Pos + ForwardEnt:GetUp()*(-RideHeight)
				end
				trace.filter = self
				trace.mask = MASK_SOLID_BRUSHONLY
			CurTrace = util.TraceLine( trace )
			lastvel = CurTrace.HitPos - self.RightPosTable[i]
			self.RightPosTable[i] = CurTrace.HitPos
			if Base then
				Speed = (ForwardEnt:WorldToLocal(ForwardEnt:GetPos()+lastvel)).x			
				RotateAngle = -360*(Speed/(WheelMult*math.pi))
			end
			self.RightAngTable[i] = self.RightAngTable[i] - RotateAngle/math.pi

			mat = Matrix()
			scale = Vector( WheelHeightMult, wheelwidthmult, WheelHeightMult )
			mat:Scale( scale )
			wheelmodel:EnableMatrix( "RenderMultiply", mat )
			wheelmodel:SetPos( CurTrace.HitPos+ForwardEnt:GetUp()*wheelmodelZ*WheelHeightMult+ForwardEnt:GetUp()*self.TreadHeight)
			wheelmodel:SetAngles( ForwardEnt:LocalToWorldAngles( -Angle(self.RightAngTable[i],180,0) ) )
			wheelmodel:SetupBones()
			render.SetColorModulation( WheelColor.x, WheelColor.y, WheelColor.z )
			wheelmodel:DrawModel()
			render.SetColorModulation( 1, 1, 1 )
		end
		self.RightScroll = self.RightScroll - Speed/(TreadMatRight:Height()*0.5)
		TreadMatRight:SetVector("$translate",Vector(0,self.RightScroll,0))
		for i=1, WheelsPerSide do
			if i == 1 then
				WheelMult = RearWheelHeight
			elseif i == WheelsPerSide then
				WheelMult = FrontWheelHeight
			else
				WheelMult = WheelHeight
			end
			WheelHeightMult = WheelMult/(wheelbounds[3]*2)
			Pos = Base:GetPos() + (ForwardEnt:GetForward()*(((i-1)*TrackLength/(WheelsPerSide-1)) - (TrackLength*0.5) + (ForwardOffset))) - (ForwardEnt:GetRight()*SideDist)
			trace = {}
				trace.start = Pos + ForwardEnt:GetUp()*RideHeight
				if i==WheelsPerSide then 
					trace.endpos = Pos + ForwardEnt:GetUp()*(-RideHeight+FrontWheelRaise)
				elseif i==1 then
					trace.endpos = Pos + ForwardEnt:GetUp()*(-RideHeight+RearWheelRaise)
				else
					trace.endpos = Pos + ForwardEnt:GetUp()*(-RideHeight)
				end
				trace.filter = self
				trace.mask = MASK_SOLID_BRUSHONLY
			CurTrace = util.TraceLine( trace )
			lastvel = CurTrace.HitPos - self.LeftPosTable[i]
			self.LeftPosTable[i] = CurTrace.HitPos
			if Base then
				Speed = (ForwardEnt:WorldToLocal(ForwardEnt:GetPos()+lastvel)).x
				RotateAngle = 360*(Speed/(WheelMult*math.pi))
			end
			self.LeftAngTable[i] = self.LeftAngTable[i] - RotateAngle/math.pi

			mat = Matrix()
			scale = Vector( WheelHeightMult, wheelwidthmult, WheelHeightMult )
			mat:Scale( scale )
			wheelmodel:EnableMatrix( "RenderMultiply", mat )
			wheelmodel:SetPos( CurTrace.HitPos+ForwardEnt:GetUp()*wheelmodelZ*WheelHeightMult+ForwardEnt:GetUp()*self.TreadHeight)
			wheelmodel:SetAngles( ForwardEnt:LocalToWorldAngles( -Angle(self.LeftAngTable[i],0,0) ) )
			wheelmodel:SetupBones()
			render.SetColorModulation( WheelColor.x, WheelColor.y, WheelColor.z )
			wheelmodel:DrawModel()
			render.SetColorModulation( 1, 1, 1 )
		end
		self.LeftScroll = self.LeftScroll - Speed/(TreadMatLeft:Height()*0.5)
		TreadMatLeft:SetVector("$translate",Vector(0,self.LeftScroll,0))
		
		local pos1
		local pos2
		local x1
		local x2
		local y1
		local y2
		local WheelPos
		local Ang
		local Detail = 32
		local NewPos

		local LeftWheelNodes = {}
		for i=1, WheelsPerSide do
			if i == 1 then
				WheelPos = self.LeftPosTable[i]+(ForwardEnt:GetUp()*RearWheelHeight*0.5)+ForwardEnt:GetUp()*self.TreadHeight
			elseif i == WheelsPerSide then
				WheelPos = self.LeftPosTable[i]+(ForwardEnt:GetUp()*FrontWheelHeight*0.5)+ForwardEnt:GetUp()*self.TreadHeight
			else
				WheelPos = self.LeftPosTable[i]+(ForwardEnt:GetUp()*WheelHeight*0.5)+ForwardEnt:GetUp()*self.TreadHeight
			end
			WheelPos = ForwardEnt:WorldToLocal(WheelPos)
			for j=1, Detail do
				if i == 1 then
					NewPos = {WheelPos[1] + (RearWheelHeight*0.5+self.TreadHeight*0.5)*math.cos(j*(360/(Detail))),WheelPos[3] + (RearWheelHeight*0.5+self.TreadHeight*0.5)*math.sin(j*(360/(Detail)))}
				elseif i == WheelsPerSide then
					NewPos = {WheelPos[1] + (FrontWheelHeight*0.5+self.TreadHeight*0.5)*math.cos(j*(360/(Detail))),WheelPos[3] + (FrontWheelHeight*0.5+self.TreadHeight*0.5)*math.sin(j*(360/(Detail)))}
				else
					NewPos = {WheelPos[1] + (WheelHeight*0.5+self.TreadHeight*0.5)*math.cos(j*(360/(Detail))),WheelPos[3] + (WheelHeight*0.5+self.TreadHeight*0.5)*math.sin(j*(360/(Detail)))}
				end	
				--WheelNodes[j] = {NewPos[1],NewPos[3]}	
				LeftWheelNodes[#LeftWheelNodes+1] = NewPos
			end
		end
		local TreadSideOffset = ForwardEnt:WorldToLocal(Base:GetPos()).y
		local LeftTreadPoints = quickhull(LeftWheelNodes)
		for i=1, #LeftTreadPoints-1 do
			mat = Matrix()
			pos1 = ForwardEnt:LocalToWorld(Vector(LeftTreadPoints[i][1],SideDist+TreadSideOffset,LeftTreadPoints[i][2]))
			pos2 = ForwardEnt:LocalToWorld(Vector(LeftTreadPoints[i+1][1],SideDist+TreadSideOffset,LeftTreadPoints[i+1][2]))
			scale = Vector( (pos1:Distance(pos2))/12, Width, Height )
			mat:Scale( scale )
			treadmodel:EnableMatrix( "RenderMultiply", mat )
			treadmodel:SetPos( (pos1 + pos2)/2 )
			x1 = ForwardEnt:WorldToLocal(pos1).x
			y1 = ForwardEnt:WorldToLocal(pos1).z
			x2 = ForwardEnt:WorldToLocal(pos2).x
			y2 = ForwardEnt:WorldToLocal(pos2).z
			treadmodel:SetAngles( ForwardEnt:LocalToWorldAngles( Angle(math.atan2(y1-y2,x2-x1)*57.2958,0,0) ) )
			treadmodel:SetupBones()
			render.ModelMaterialOverride( TreadMatLeft )
			TreadMatLeft:SetVector("$newscale",Vector((scale.x*512/TreadMatLeft:Height()),512/TreadMatLeft:Width(),5))
			render.SetColorModulation( TreadColor.x, TreadColor.y, TreadColor.z )
			treadmodel:DrawModel()
			render.SetColorModulation( 1, 1, 1 )
			render.ModelMaterialOverride()
		end
		mat = Matrix()
		pos1 = ForwardEnt:LocalToWorld(Vector(LeftTreadPoints[1][1],SideDist+TreadSideOffset,LeftTreadPoints[1][2]))
		pos2 = ForwardEnt:LocalToWorld(Vector(LeftTreadPoints[#LeftTreadPoints][1],SideDist+TreadSideOffset,LeftTreadPoints[#LeftTreadPoints][2]))
		scale = Vector( (pos1:Distance(pos2))/12, Width, Height )
		mat:Scale( scale )
		treadmodel:EnableMatrix( "RenderMultiply", mat )
		treadmodel:SetPos( (pos1 + pos2)/2 )
		x1 = ForwardEnt:WorldToLocal(pos1).x
		y1 = ForwardEnt:WorldToLocal(pos1).z
		x2 = ForwardEnt:WorldToLocal(pos2).x
		y2 = ForwardEnt:WorldToLocal(pos2).z
		treadmodel:SetAngles( ForwardEnt:LocalToWorldAngles( Angle(math.atan2(y1-y2,x2-x1)*57.2958,0,0) ) )
		treadmodel:SetupBones()
		render.ModelMaterialOverride( TreadMatLeft )
		TreadMatLeft:SetVector("$newscale",Vector((scale.x*512/TreadMatLeft:Height()),512/TreadMatLeft:Width(),5))
		render.SetColorModulation( TreadColor.x, TreadColor.y, TreadColor.z )
		treadmodel:DrawModel()
		render.SetColorModulation( 1, 1, 1 )
		render.ModelMaterialOverride()

		local RightWheelNodes = {}
		for i=1, WheelsPerSide do
			if i == 1 then
				WheelPos = self.RightPosTable[i]+(ForwardEnt:GetUp()*RearWheelHeight*0.5)+ForwardEnt:GetUp()*self.TreadHeight
			elseif i == WheelsPerSide then
				WheelPos = self.RightPosTable[i]+(ForwardEnt:GetUp()*FrontWheelHeight*0.5)+ForwardEnt:GetUp()*self.TreadHeight
			else
				WheelPos = self.RightPosTable[i]+(ForwardEnt:GetUp()*WheelHeight*0.5)+ForwardEnt:GetUp()*self.TreadHeight
			end
			WheelPos = ForwardEnt:WorldToLocal(WheelPos)
			for j=1, Detail do
				if i == 1 then
					NewPos = {WheelPos[1] + (RearWheelHeight*0.5+self.TreadHeight*0.5)*math.cos(j*(360/(Detail))),WheelPos[3] + (RearWheelHeight*0.5+self.TreadHeight*0.5)*math.sin(j*(360/(Detail)))}
				elseif i == WheelsPerSide then
					NewPos = {WheelPos[1] + (FrontWheelHeight*0.5+self.TreadHeight*0.5)*math.cos(j*(360/(Detail))),WheelPos[3] + (FrontWheelHeight*0.5+self.TreadHeight*0.5)*math.sin(j*(360/(Detail)))}
				else
					NewPos = {WheelPos[1] + (WheelHeight*0.5+self.TreadHeight*0.5)*math.cos(j*(360/(Detail))),WheelPos[3] + (WheelHeight*0.5+self.TreadHeight*0.5)*math.sin(j*(360/(Detail)))}
				end	
				--WheelNodes[j] = {NewPos[1],NewPos[3]}	
				RightWheelNodes[#RightWheelNodes+1] = NewPos
			end
		end
		local RightTreadPoints = quickhull(RightWheelNodes)
		for i=1, #RightTreadPoints-1 do
			mat = Matrix()
			pos1 = ForwardEnt:LocalToWorld(Vector(RightTreadPoints[i][1],-SideDist+TreadSideOffset,RightTreadPoints[i][2]))
			pos2 = ForwardEnt:LocalToWorld(Vector(RightTreadPoints[i+1][1],-SideDist+TreadSideOffset,RightTreadPoints[i+1][2]))
			scale = Vector( (pos1:Distance(pos2))/12, Width, Height )
			mat:Scale( scale )
			treadmodel:EnableMatrix( "RenderMultiply", mat )
			treadmodel:SetPos( (pos1 + pos2)/2 )
			x1 = ForwardEnt:WorldToLocal(pos1).x
			y1 = ForwardEnt:WorldToLocal(pos1).z
			x2 = ForwardEnt:WorldToLocal(pos2).x
			y2 = ForwardEnt:WorldToLocal(pos2).z
			treadmodel:SetAngles( ForwardEnt:LocalToWorldAngles( Angle(math.atan2(y1-y2,x2-x1)*57.2958,0,0) ) )
			treadmodel:SetupBones()
			render.ModelMaterialOverride( TreadMatRight )
			TreadMatRight:SetVector("$newscale",Vector((scale.x*512/TreadMatRight:Height()),512/TreadMatRight:Width(),5))
			render.SetColorModulation( TreadColor.x, TreadColor.y, TreadColor.z )
			treadmodel:DrawModel()
			render.SetColorModulation( 1, 1, 1 )
			render.ModelMaterialOverride()
		end
		mat = Matrix()
		pos1 = ForwardEnt:LocalToWorld(Vector(RightTreadPoints[1][1],-SideDist+TreadSideOffset,RightTreadPoints[1][2]))
		pos2 = ForwardEnt:LocalToWorld(Vector(RightTreadPoints[#RightTreadPoints][1],-SideDist+TreadSideOffset,RightTreadPoints[#RightTreadPoints][2]))
		scale = Vector( (pos1:Distance(pos2))/12, Width, Height )
		mat:Scale( scale )
		treadmodel:EnableMatrix( "RenderMultiply", mat )
		treadmodel:SetPos( (pos1 + pos2)/2 )
		x1 = ForwardEnt:WorldToLocal(pos1).x
		y1 = ForwardEnt:WorldToLocal(pos1).z
		x2 = ForwardEnt:WorldToLocal(pos2).x
		y2 = ForwardEnt:WorldToLocal(pos2).z
		treadmodel:SetAngles( ForwardEnt:LocalToWorldAngles( Angle(math.atan2(y1-y2,x2-x1)*57.2958,0,0) ) )
		treadmodel:SetupBones()
		render.ModelMaterialOverride( TreadMatRight )
		TreadMatRight:SetVector("$newscale",Vector((scale.x*512/TreadMatRight:Height()),512/TreadMatRight:Width(),5))
		render.SetColorModulation( TreadColor.x, TreadColor.y, TreadColor.z )
		treadmodel:DrawModel()
		render.SetColorModulation( 1, 1, 1 )
		render.ModelMaterialOverride()
	end
	wheelmodel:Remove()
	treadmodel:Remove()
	self.LastWheelsPerSide = WheelsPerSide
end

