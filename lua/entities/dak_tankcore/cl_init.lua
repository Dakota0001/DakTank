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
	local core = net.ReadEntity()
	local DetailInfoTable = util.JSONToTable(net.ReadString())
	if core.Detail == nil then core.Detail = {} end
	for i=1, #DetailInfoTable do
		local cur = DetailInfoTable[i]
		local Detailplate = ents.CreateClientProp( cur.Model )
		local parentent = ents.GetByIndex( cur.Parent )
		if parentent:IsValid() then
			Detailplate:SetPos(parentent:LocalToWorld(cur.LocalPos))
			Detailplate:SetAngles(parentent:LocalToWorldAngles(cur.LocalAng))
			Detailplate:SetMaterial(cur.Mat)
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
			core.Detail[#core.Detail+1] = Detailplate
		end
	end
end )

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
	local core = net.ReadEntity()
	if core.Detail ~= nil then
		if #core.Detail > 0 then
			for i=1, #core.Detail do
				if core.Detail[i]:IsValid() then core.Detail[i]:Remove() end
			end
		end
	end
end)

net.Receive( "daktankcoredie", function()
	local core = net.ReadEntity()
	if core.Detail ~= nil then
		if #core.Detail > 0 then
			for i=1, #core.Detail do
				if core.Detail[i]:IsValid() then 
					core.Detail[i]:SetMaterial("models/props_buildings/plasterwall021a")
					core.Detail[i]:SetColor(Color(100,100,100,255))
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
	if self.Detail ~= nil then
		if #self.Detail > 0 then
			for i=1, #self.Detail do
				if self.Detail[i]:IsValid() then self.Detail[i]:Remove() end
			end
		end
	end
end