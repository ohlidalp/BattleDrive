--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Gunfire
-- @description Weapon logic
--------------------------------------------------------------------------------
-- module("BDT_Gunfire.BDT_Gunfire");

return function(BDT_Gunfire_Dir){
	local BDT_Gunfire = {};
	require (BDT_Gunfire_Dir.."/BDT_Gunfire_Blaster.lua") (BDT_Gunfire);
	return BDT_Gunfire;
}