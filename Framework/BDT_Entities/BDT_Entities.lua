--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Entities
-- @description Gameplay objects.
--------------------------------------------------------------------------------

local BDT_Entities = {
	_loaded = {}
};

--------------------------------------------------------------------------------
-- Loads entity class and it's factory class.
-- @return : BDT_Entities.Factory Subclass of Factory
--------------------------------------------------------------------------------
function BDT_Entities:createFactory(entName)
	if type(self._loaded[entName]) == "table" then
		return self._loaded[entName].factory:new(
				self._loaded[entName].entity, self._bdGraphicsDir, self._statusMarker);
	else
		local entity = require(self._gameEntitiesDir .. entName .. 'Entity.lua');
		local factory = require(self._gameEntitiesDir .. entName .. 'EntityFactory.lua');
		self._loaded[entName] = {
			entity = entity,
			factory = factory
		};
		return factory:new(entity, self._bdGraphicsDir, self._statusMarker);
	end
end

--------------------------------------------------------------------------------
-- @param statusMarker : BDT_Misc.StatusMarker Displays game loading status.
--------------------------------------------------------------------------------
function BDT_Entities:setStatusMarker(o)
	BDT_Entities._statusMarker = o;
end

return function( dir, BDT, gameEntitiesDir, bdGraphicsDir )
	require(dir .. "/Entity.lua") (BDT_Entities);
	require(dir .. "/VehicleEntity.lua") (BDT_Entities);
	BDT_Entities._gameEntitiesDir = gameEntitiesDir or 'Entities/';
	BDT_Entities._bdGraphicsDir = bdGraphicsDir or 'Graphics/';
	return BDT_Entities;
end