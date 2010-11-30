return function(BDT_Gunfire_Dir){
	local BDT_Gunfire = {};
	require (BDT_Gunfire_Dir.."/BDT_Gunfire_Blaster.lua") (BDT_Gunfire);
	return BDT_Gunfire;
}