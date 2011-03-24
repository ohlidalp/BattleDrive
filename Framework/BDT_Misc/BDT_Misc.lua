--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Misc
-- @description Misc utilities.
--------------------------------------------------------------------------------

return function( dir )
	local BDT_Misc = {};
	require(dir .. "/XYMover.lua") (BDT_Misc);
	return BDT_Misc;
end