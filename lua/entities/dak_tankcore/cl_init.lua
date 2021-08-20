include("shared.lua")

function ENT:Draw()

	self:DrawModel()

end

net.Receive( "daktankcoreera", function()
	local core = net.ReadEntity()
	local ERAInfoTable = util.JSONToTable(net.ReadString())
	if core.ERA == nil then core.ERA = {} end
	for i=1, #ERAInfoTable do
		local cur = ERAInfoTable[i]
		local eraplate = ents.CreateClientProp( cur.Model )
		local parentent = ents.GetByIndex( cur.Parent )
		if parentent:IsValid() then
			eraplate:SetPos(parentent:LocalToWorld(cur.LocalPos))
			eraplate:SetAngles(parentent:LocalToWorldAngles(cur.LocalAng))
			eraplate:SetMaterial(cur.Mat)
			eraplate:SetColor(cur.Col)
			eraplate:SetParent(parentent)
			eraplate:SetMoveType(MOVETYPE_NONE)
			core.ERA[#core.ERA+1] = eraplate
		end
	end
end )

net.Receive( "daktankcoredetail", function()
	local core = net.ReadFloat()
	local DetailInfoTable = util.JSONToTable(net.ReadString())
	if LocalPlayer()[tostring( core )] == nil then LocalPlayer()[tostring( core )] = {} end
	if LocalPlayer()[tostring( core )].Detail == nil then LocalPlayer()[tostring( core )].Detail = {} end
	local cur
	local Detailplate
	local parentent
	for i=1, #DetailInfoTable do
		cur = DetailInfoTable[i]
		Detailplate = ents.CreateClientProp( cur.Model )
		parentent = ents.GetByIndex( cur.Parent )
		--if parentent:IsValid() then
		Detailplate:SetPos(parentent:LocalToWorld(cur.LocalPos))
		Detailplate:SetAngles(parentent:LocalToWorldAngles(cur.LocalAng))
		Detailplate:SetMaterial(cur.Mat)
		Detailplate:SetBodyGroups(cur.Bodygroups)
		Detailplate:SetSkin(cur.Skin)
		for j=0, 31 do
			Detailplate:SetSubMaterial( j, cur.SubMaterials[j] )
		end
		Detailplate:SetColor(cur.Col)
		Detailplate:SetParent(parentent)
		Detailplate:SetMoveType(MOVETYPE_NONE)
		if cur.ClipData ~= nil then
			for j=1, #cur.ClipData do
				ProperClipping.AddVisualClip(Detailplate, cur.ClipData[j].n:Forward(), cur.ClipData[j].d, cur.ClipData[j].inside, false)
			end
		end
		if LocalPlayer()[tostring( core )].Detail ~= nil then
			LocalPlayer()[tostring( core )].Detail[#LocalPlayer()[tostring( core )].Detail+1] = Detailplate
		end
		--end
	end
end )

--Core is null on client that is not in the view portal it was created in and so will not work properly, try getting it by index instead since readentity isn't working

net.Receive( "daktankcoreeraremove", function()
	local core = net.ReadEntity()
	if core.ERA ~= nil then
		if #core.ERA > 0 then
			for i=1, #core.ERA do
				if core.ERA[i]:IsValid() then core.ERA[i]:Remove() end
			end
		end
	end
end)

net.Receive( "daktankcoredetailremove", function()
	local core = net.ReadFloat()
	if LocalPlayer()[tostring( core )].Detail ~= nil then
		if #LocalPlayer()[tostring( core )].Detail > 0 then
			for i=1, #LocalPlayer()[tostring( core )].Detail do
				if LocalPlayer()[tostring( core )].Detail[i]:IsValid() then LocalPlayer()[tostring( core )].Detail[i]:Remove() end
			end
			LocalPlayer()[tostring( core )].Detail = {}
		end
	end
end)

net.Receive( "daktankcoredie", function()
	local core = net.ReadFloat()
	if LocalPlayer()[tostring( core )].Detail ~= nil then
		if #LocalPlayer()[tostring( core )].Detail > 0 then
			for i=1, #LocalPlayer()[tostring( core )].Detail do
				if LocalPlayer()[tostring( core )].Detail[i]:IsValid() then 
					LocalPlayer()[tostring( core )].Detail[i]:SetMaterial("models/props_buildings/plasterwall021a")
					LocalPlayer()[tostring( core )].Detail[i]:SetColor(Color(100,100,100,255))
				end
			end
		end
	end
	if core.ERA ~= nil then
		if #core.ERA > 0 then
			for i=1, #core.ERA do
				if core.ERA[i]:IsValid() then 
					core.ERA[i]:SetMaterial("models/props_buildings/plasterwall021a")
					core.ERA[i]:SetColor(Color(100,100,100,255))
				end
			end
		end
	end
end)

function ENT:OnRemove()
	if self.ERA ~= nil then
		if #self.ERA > 0 then
			for i=1, #self.ERA do
				if self.ERA[i]:IsValid() then self.ERA[i]:Remove() end
			end
		end
	end
	if LocalPlayer()[tostring( self:EntIndex() )].Detail ~= nil then
		if #LocalPlayer()[tostring( self:EntIndex() )].Detail > 0 then
			for i=1, #LocalPlayer()[tostring( self:EntIndex() )].Detail do
				if LocalPlayer()[tostring( self:EntIndex() )].Detail[i]:IsValid() then LocalPlayer()[tostring( self:EntIndex() )].Detail[i]:Remove() end
			end
			LocalPlayer()[tostring( self:EntIndex() )].Detail = {}
		end
	end
end