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

	self:SetRenderBounds( Vector(-1000,-1000,-1000),Vector(1000,1000,1000) )
	--print(WheelColor)
	wheelmodel:SetColor(Color( 255, 0, 0, 255 ))
 	--check for base and forward ent are not null
 	if ForwardEnt:IsValid() then
	 	if (self.RightAngTable == nil and WheelsPerSide>0) or self.LastWheelsPerSide~=WheelsPerSide then
			self.RightAngTable = {}
			self.RightPosTable = {}
			self.RightNodeTable = {}
			for i=1, WheelsPerSide do
				self.RightAngTable[i] = 0
				self.RightPosTable[i] = Vector(0,0,0)
				self.RightNodeTable[i] = {}
			end
		end
		if (self.LeftAngTable == nil and WheelsPerSide>0) or self.LastWheelsPerSide~=WheelsPerSide then
			self.LeftAngTable = {}
			self.LeftPosTable = {}
			self.LeftNodeTable = {}
			for i=1, WheelsPerSide do
				self.LeftAngTable[i] = 0
				self.LeftPosTable[i] = Vector(0,0,0)
				self.LeftNodeTable[i] = {}
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
				trace.start = Pos + ForwardEnt:GetUp()*RideLimit
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
				trace.start = Pos + ForwardEnt:GetUp()*RideLimit
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

		--IDEA
		--get both pos
		--get angle between those pos
		--rotate nodes of wheel by that angle
		--connect via that
		--so I need to get the angle between the last and second to last and first and second to first wheels to make them proper
		
		local pos1
		local pos2
		local x1
		local x2
		local y1
		local y2
		local WheelPos
		local WheelNodes = {}
		local Ang
		local Detail = 8
		local RightFrontAng 
		local RightBackAng
		local LeftFrontAng
		local LeftBackAng
		for i=1, 4 do
			if i == 1 then

				WheelPos = self.RightPosTable[1]+ForwardEnt:GetUp()*wheelmodelZ*(RearWheelHeight/(wheelbounds[3]*2))+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.RightPosTable[1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.RightPosTable[2] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				x1 = ForwardEnt:WorldToLocal(pos1).x
				y1 = ForwardEnt:WorldToLocal(pos1).z
				x2 = ForwardEnt:WorldToLocal(pos2).x
				y2 = ForwardEnt:WorldToLocal(pos2).z
			elseif i == 4 then
				WheelPos = self.RightPosTable[WheelsPerSide]+ForwardEnt:GetUp()*wheelmodelZ*(FrontWheelHeight/(wheelbounds[3]*2))+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.RightPosTable[WheelsPerSide] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.RightPosTable[WheelsPerSide-1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				x1 = ForwardEnt:WorldToLocal(pos1).x
				y1 = ForwardEnt:WorldToLocal(pos1).z
				x2 = ForwardEnt:WorldToLocal(pos2).x
				y2 = ForwardEnt:WorldToLocal(pos2).z
			end
			if i == 2 then
				WheelPos = self.RightPosTable[2]+ForwardEnt:GetUp()*wheelmodelZ+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.RightPosTable[2] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.RightPosTable[3] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			elseif i == 3 then
				WheelPos = self.RightPosTable[WheelsPerSide-1]+ForwardEnt:GetUp()*wheelmodelZ+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.RightPosTable[WheelsPerSide-1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.RightPosTable[WheelsPerSide-2] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			end
			WheelNodes = {}
			
			if i <= 2 then
				Ang = (ForwardEnt:GetUp()):Angle()
			else
				Ang = (-ForwardEnt:GetUp()):Angle()
			end
			if i == 1 or i == 4 then
				if i == 1 then RightBackAng = -math.atan2(y1-y2,x2-x1)*57.2958 end
				if i == 4 then RightFrontAng = 180-math.atan2(y1-y2,x2-x1)*57.2958 end
				Ang:RotateAroundAxis( ForwardEnt:GetRight(), -math.atan2(y1-y2,x2-x1)*57.2958 )
			end
			Ang:RotateAroundAxis( ForwardEnt:GetRight(), (360/(Detail*2))*-1 )
			for j=1, Detail+1 do
				Ang:RotateAroundAxis( ForwardEnt:GetRight(), (360/(Detail*2)) )
				if i <= 3 then
					if i == 1 then
						WheelNodes[j] = WheelPos + (Ang:Forward()*(wheelmodelZ*(RearWheelHeight/(wheelbounds[3]*2))+(self.TreadHeight*0.5)))
					else
						WheelNodes[j] = WheelPos + (Ang:Forward()*(wheelmodelZ+(self.TreadHeight*0.5)))
					end				
				else
					WheelNodes[j] = WheelPos - (Ang:Forward()*(wheelmodelZ*(FrontWheelHeight/(wheelbounds[3]*2))+(self.TreadHeight*0.5)))
				end
			end
			self.RightNodeTable[i] = WheelNodes
		end 
		for i=1, 4 do
			if i == 1 then
				WheelPos = self.LeftPosTable[1]+ForwardEnt:GetUp()*wheelmodelZ*(RearWheelHeight/(wheelbounds[3]*2))+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.LeftPosTable[1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.LeftPosTable[2] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				x1 = ForwardEnt:WorldToLocal(pos1).x
				y1 = ForwardEnt:WorldToLocal(pos1).z
				x2 = ForwardEnt:WorldToLocal(pos2).x
				y2 = ForwardEnt:WorldToLocal(pos2).z
			elseif i == 4 then
				WheelPos = self.LeftPosTable[WheelsPerSide]+ForwardEnt:GetUp()*wheelmodelZ*(FrontWheelHeight/(wheelbounds[3]*2))+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.LeftPosTable[WheelsPerSide] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.LeftPosTable[WheelsPerSide-1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				x1 = ForwardEnt:WorldToLocal(pos1).x
				y1 = ForwardEnt:WorldToLocal(pos1).z
				x2 = ForwardEnt:WorldToLocal(pos2).x
				y2 = ForwardEnt:WorldToLocal(pos2).z
			end
			if i == 2 then
				WheelPos = self.LeftPosTable[2]+ForwardEnt:GetUp()*wheelmodelZ+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.LeftPosTable[2] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.LeftPosTable[3] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			elseif i == 3 then
				WheelPos = self.LeftPosTable[WheelsPerSide-1]+ForwardEnt:GetUp()*wheelmodelZ+ForwardEnt:GetUp()*self.TreadHeight
				pos1 = self.LeftPosTable[WheelsPerSide-1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.LeftPosTable[WheelsPerSide-2] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			end
			WheelNodes = {}
			
			if i <= 2 then
				Ang = (ForwardEnt:GetUp()):Angle()
			else
				Ang = (-ForwardEnt:GetUp()):Angle()
			end
			if i == 1 or i == 4 then
				if i == 1 then LeftBackAng = -math.atan2(y1-y2,x2-x1)*57.2958 end
				if i == 4 then LeftFrontAng = 180-math.atan2(y1-y2,x2-x1)*57.2958 end
				Ang:RotateAroundAxis( ForwardEnt:GetRight(), -math.atan2(y1-y2,x2-x1)*57.2958 )
			end
			Ang:RotateAroundAxis( ForwardEnt:GetRight(), (360/(Detail*2))*-1 )
			for j=1, Detail+1 do
				Ang:RotateAroundAxis( ForwardEnt:GetRight(), (360/(Detail*2)) )
				if i <= 3 then
					if i == 1 then
						WheelNodes[j] = WheelPos + (Ang:Forward()*(wheelmodelZ*(RearWheelHeight/(wheelbounds[3]*2))+(self.TreadHeight*0.5)))
					else
						WheelNodes[j] = WheelPos + (Ang:Forward()*(wheelmodelZ+(self.TreadHeight*0.5)))
					end				
				else
					WheelNodes[j] = WheelPos - (Ang:Forward()*(wheelmodelZ*(FrontWheelHeight/(wheelbounds[3]*2))+(self.TreadHeight*0.5)))
				end
			end
			self.LeftNodeTable[i] = WheelNodes
		end 

		if RightBackAng > 90 then RightBackAng = 0 end
		if RightFrontAng > 90 then RightFrontAng = 0 end

		local RightBackAngChunks = math.floor(math.abs(RightBackAng)/(360/(Detail*2)))
		local RightFrontAngChunks = math.floor(math.abs(RightFrontAng)/(360/(Detail*2)))
		
		for i=1, WheelsPerSide-1 do
			mat = Matrix()
			pos1 = self.RightPosTable[i] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			pos2 = self.RightPosTable[i+1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			if i == 1 then
				pos1 = self.RightNodeTable[1][Detail+1]
				pos2 = self.RightNodeTable[2][Detail-RightBackAngChunks+1]
			elseif i == WheelsPerSide-1 then
				pos1 = self.RightNodeTable[4][1]
				pos2 = self.RightNodeTable[3][1+RightFrontAngChunks]
			end
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
		for i = 1, Detail do
			if i > RightBackAngChunks+1 then
				mat = Matrix()
				pos1 = self.RightNodeTable[1][i]
				pos2 = self.RightNodeTable[1][i+1]
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
			if i+RightFrontAngChunks+1 <= Detail then
				mat = Matrix()
				pos1 = self.RightNodeTable[4][i]
				pos2 = self.RightNodeTable[4][i+1]
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
			if i>=Detail-RightBackAngChunks+1 and RightBackAngChunks>0 then
				mat = Matrix()
				pos1 = self.RightNodeTable[2][i]
				pos2 = self.RightNodeTable[2][i+1]
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
			if i>=Detail-RightFrontAngChunks+1 and RightFrontAngChunks>0 then
				mat = Matrix()
				pos1 = self.RightNodeTable[3][Detail-i+1]
				pos2 = self.RightNodeTable[3][Detail-i+2]
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
		end
		mat = Matrix()
		pos1 = self.RightNodeTable[4][Detail+1-(RightFrontAngChunks+1)]
		pos2 = self.RightNodeTable[1][1+RightBackAngChunks+1]
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

		if LeftBackAng > 90 then LeftBackAng = 0 end
		if LeftFrontAng > 90 then LeftFrontAng = 0 end

		local LeftBackAngChunks = math.floor(math.abs(LeftBackAng)/(360/(Detail*2)))
		local LeftFrontAngChunks = math.floor(math.abs(LeftFrontAng)/(360/(Detail*2)))
		for i=1, WheelsPerSide-1 do
			mat = Matrix()
			pos1 = self.LeftPosTable[i] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
				pos2 = self.LeftPosTable[i+1] + ForwardEnt:GetUp()*(self.TreadHeight*0.5)
			if i == 1 then
				pos1 = self.LeftNodeTable[1][Detail+1]
				pos2 = self.LeftNodeTable[2][Detail-LeftBackAngChunks+1]
			elseif i == WheelsPerSide-1 then
				pos1 = self.LeftNodeTable[4][1]
				pos2 = self.LeftNodeTable[3][1+LeftFrontAngChunks]
			end
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
		for i = 1, Detail do
			if i > LeftBackAngChunks+1 then
				mat = Matrix()
				pos1 = self.LeftNodeTable[1][i]
				pos2 = self.LeftNodeTable[1][i+1]
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
			if i+LeftFrontAngChunks+1 <= Detail then
				mat = Matrix()
				pos1 = self.LeftNodeTable[4][i]
				pos2 = self.LeftNodeTable[4][i+1]
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
			if i>=Detail-LeftBackAngChunks+1 and LeftBackAngChunks>0 then
				mat = Matrix()
				pos1 = self.LeftNodeTable[2][i]
				pos2 = self.LeftNodeTable[2][i+1]
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
			if i>=Detail-LeftFrontAngChunks+1 and LeftFrontAngChunks>0 then
				mat = Matrix()
				pos1 = self.LeftNodeTable[3][Detail-i+1]
				pos2 = self.LeftNodeTable[3][Detail-i+2]
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
		end
		mat = Matrix()
		pos1 = self.LeftNodeTable[4][Detail+1-(LeftFrontAngChunks+1)]
		pos2 = self.LeftNodeTable[1][1+LeftBackAngChunks+1]
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
	wheelmodel:Remove()
	treadmodel:Remove()
	self.LastWheelsPerSide = WheelsPerSide
end

