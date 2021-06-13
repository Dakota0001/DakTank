include("shared.lua")

--

function DTTE.CreateERA(Host, Ents)
    local E = ents.Create("dak_era")

    E:SetModel("models/props_lab/huladoll.mdl")
    E:SetPos(Host:GetPos())
    E:SetAngles(Host:GetAngles())
    E:SetParent(Host)
    E:Spawn()

    E:P2M(Ents) -- Prop 2 Mesh
    E:P2P(Ents) -- Prop 2 Physics
end

function ENT:P2M(Ents)
    local Tool = {
        GetClientNumber = function() return 0 end,
        selection = {}
    }

    for ent in pairs(Ents) do
        Tool.selection[ent] = { col = ent:GetColor(), mat = ent:GetMaterial() }
    end

    self:ToolDataAUTO(Tool)
end

function ENT:P2P(Ents)
    local mesh = {}
    local c    = 0

    for ent in pairs(Ents) do
        if not IsValid(ent:GetPhysicsObject()) then continue end

        c = c + 1

        local offset     = self:WorldToLocal(ent:GetPos())
        local mins, maxs = ent:GetPhysicsObject():GetAABB()
            mins:Rotate(ent:GetAngles())
            maxs:Rotate(ent:GetAngles())
        mins, maxs = mins + offset, maxs + offset

        mesh[c] = {
            Vector( mins.y, mins.y, mins.z ),
            Vector( mins.x, mins.y, maxs.z ),
            Vector( mins.x, maxs.y, mins.z ),
            Vector( mins.x, maxs.y, maxs.z ),
            Vector( maxs.x, mins.y, mins.z ),
            Vector( maxs.x, mins.y, maxs.z ),
            Vector( maxs.x, maxs.y, mins.z ),
            Vector( maxs.x, maxs.y, maxs.z )
        }

        self:PhysicsInitMultiConvex(mesh)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:EnableCustomCollisions(true)
        self:DrawShadow(false)
    end
end