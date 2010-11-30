return function(BDT_AI_Dir){
	local BDT_AI = {};
	require (BDT_AI_Dir.."/BDT_AI_Turret.lua") (BDT_AI);
	return BDT_AI;
}