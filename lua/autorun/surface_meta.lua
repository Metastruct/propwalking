local Player = FindMetaTable( "Player" )
local Entity = FindMetaTable( "Entity" )

local function NetworkVar(what,slot,varname)
	local set = Entity["SetDT"..what]
	local get = Entity["GetDT"..what]
	
	Player["Set"..varname] = function(self,v)
		return set(self,slot,v)
	end
	Player["Get"..varname] = function(self)
		return get(self,slot)
	end
end
NetworkVar("Entity", 5, "SurfaceEnt")
NetworkVar("Vector", 5, "SurfaceVelocity")
NetworkVar("Vector", 6, "SurfaceOffset")
NetworkVar("Angle", 5, "SurfaceAngle")

function Player:SetSurface( ent )

	if self:GetSurface() ~= ent then
		-- self:SetNWEntity( "Surface", ent )
		self:SetSurfaceEnt(ent)
	end

	if SERVER then
		local phys = self:GetPhysicsObject()

		if IsValid( phys ) then
			phys:EnableCollisions( not IsValid( ent ) )
		end
	end

	if IsValid( ent ) then
		-- self:SetNWVector( "Surface Offset", ent:WorldToLocal( self:GetPos() ) )
		self:SetSurfaceOffset( ent:WorldToLocal( self:GetPos() ) )
		-- self:SetNWAngle( "Surface Angle", ent:GetAngles() )
		self:SetSurfaceAngle( ent:GetAngles() )
	end

end

function Player:GetSurface()

	-- local ent = self:GetNWEntity( "Surface", ent )
	local ent = self:GetSurfaceEnt( ent )

	if IsValid( ent ) then
		-- return ent, ent:LocalToWorld( self:GetNWVector( "Surface Offset", vector_origin ) ), self:GetNWAngle( "Surface Angle", angle_zero )
		return ent, ent:LocalToWorld( self:GetSurfaceOffset( vector_origin ) ), self:GetSurfaceAngle( angle_zero )
	end

	return ent, vector_origin

end

function Player:HasSurface()

	return IsValid( self:GetSurface() )

end


function Player:CheckSurface()

	local pos = self:GetPos()
	local mins, maxs = self:GetCollisionBounds()

	local tr = util.TraceHull( {
		start = pos,
		endpos = pos - vector_up * self:GetStepSize(),
		filter = self,
		mins = mins,
		maxs = maxs,
		mask = MASK_PLAYERSOLID
	} )

	if tr.Entity:IsPlayer() or tr.Entity:IsWorld() then
		return NULL
	end

	return tr.Entity, tr.HitNormal.z

end

function Player:GetMaxGroundSpeed()

	local speed = self:GetSequenceGroundSpeed( self:GetSequence() )

	if speed <= 1 then
		return 1
	end

	return speed

end