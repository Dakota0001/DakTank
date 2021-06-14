-- DTTE.Models library
-- Model convex mesh and volume
DTTE.Models = {}

local Models = DTTE.Models

local function CreateEntity(Model)
    util.PrecacheModel(Model) -- 'ate CSEnts.

    local Entity = SERVER and ents.Create("base_anim") or ents.CreateClientProp(Model)

    Entity:SetModel(Model)
    Entity:PhysicsInit(SOLID_VPHYSICS)

    return Entity
end

local function GetModelData(Model)
    if not isstring(Model) then return end
    if IsUselessModel(Model) then return end

    local Data = Models[Model]

    if Data then return Data end

    local Entity = CreateEntity(Model)

    if not IsValid(Entity) then return end

    local PhysObj = Entity:GetPhysicsObject()

    if not IsValid(PhysObj) then return end

    local Min, Max = PhysObj:GetAABB()

    Data = {
        Mesh   = PhysObj:GetMeshConvexes(),
        Volume = PhysObj:GetVolume(),
        Center = (Max + Min) * 0.5,
        Size   = Max - Min,
        Min    = Min,
        Max    = Max,
    }

    Models[Model] = Data

    Entity:Remove()

    return Data
end

local function IsValidScale(Scale)
    if not Scale then return false end
    if isnumber(Scale) then return true end

    return isvector(Scale)
end

local function ScaleMesh(Mesh, Scale)
    for I, Hull in ipairs(Mesh) do
        for J, Vertex in ipairs(Hull) do
            Mesh[I][J] = Vertex.pos * Scale
        end
    end
end

local function GetMeshVolume(Mesh)
    local Entity = CreateEntity("models/props_junk/PopCan01a.mdl")
    Entity:PhysicsInitMultiConvex(Mesh)

    local PhysObj = Entity:GetPhysicsObject()
    local Volume  = PhysObj:GetVolume()

    Entity:Remove()

    return Volume
end

-------------------------------------------------------------------

function Models.GetMesh(Model, Scale)
    local Data = GetModelData(Model)

    if not Data then return end

    local Mesh = table.Copy(Data.Mesh)

    if IsValidScale(Scale) then ScaleMesh(Mesh, Scale) end

    return Mesh
end

function Models.GetCenter(Model, Scale)
    local Data = GetModelData(Model)

    if not Data then return end

    if not IsValidScale(Scale) then
        return Data.Center
    end

    return Data.Center * Scale
end

function Models.GetVolume(Model, Scale)
    local Data = GetModelData(Model)

    if not Data then return end
    if not IsValidScale(Scale) then
        return Data.Volume
    end

    local Mesh = table.Copy(Data.Mesh)

    ScaleMesh(Mesh, Scale)

    return GetMeshVolume(Mesh)
end

function Models.GetSize(Model, Scale)
    local Data = GetModelData(Model)

    if not Data then return end
    if not IsValidScale(Scale) then
        return Vector(Data.Size)
    end

    return Data.Size * Scale
end