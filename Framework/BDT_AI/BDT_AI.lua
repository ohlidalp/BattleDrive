--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_AI
-- @description Misc AI logic
--------------------------------------------------------------------------------
-- module("BDT_AI.BDT_AI");

return function(BDT_AI_Dir)
	local BDT_AI = {};
	require (BDT_AI_Dir.."/BDT_AI_Turret.lua") (BDT_AI);
	return BDT_AI;
end