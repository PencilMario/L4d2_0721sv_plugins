DirectorOptions <-
{
   	ActiveChallenge = 1
	cm_AggressiveSpecials 			= true
	cm_ShouldHurry 					= 1
	//cm_SpecialRespawnInterval 		= 15 //Time for an SI spawn slot to become available
	cm_SpecialSlotCountdownTime 	= 0
	
	DominatorLimit 			= 3
	cm_BaseSpecialLimit 	= 3
	cm_MaxSpecials 			= 3
	BoomerLimit 			= 1
	SpitterLimit 			= 0
	HunterLimit 			= 1
	JockeyLimit 			= 1
	ChargerLimit 			= 1
	SmokerLimit 			= 0
    DefaultItems =
 	[
 		"weapon_smg",
 		"weapon_pistol",
        "weapon_pistol",
 	]

 	function GetDefaultItem( idx )
 	{
 		if ( idx < DefaultItems.len() )
 		{
 			return DefaultItems[idx];
 		}
 		return 0;
 	}
}

MapData <-{
	g_nSI 	= 3
	g_nTime = 3
}

function update_diff()
{
    local difficulty = Convars.GetStr("das_fakedifficulty");
    local timer = (Convars.GetFloat("SS_Time")).tointeger()
    local Si1p = (Convars.GetFloat("sss_1P")).tointeger()
    local Si2p = (Convars.GetFloat("sss_2P")).tointeger()
    local Si3p = (Convars.GetFloat("sss_3P")).tointeger()
    local Si4p = (Convars.GetFloat("sss_4P")).tointeger()
    local Si1pl = (Convars.GetFloat("sss_1P_Lim")).tointeger()
    local Si2pl = (Convars.GetFloat("sss_2P_Lim")).tointeger()
    local Si3pl = (Convars.GetFloat("sss_3P_Lim")).tointeger()
    local Si4pl = (Convars.GetFloat("sss_4P_Lim")).tointeger()

    DirectorOptions.cm_SpecialRespawnInterval = timer
    DirectorOptions.cm_SpecialSlotCountdownTime = timer
    switch (difficulty){
        case "1":
            DirectorOptions.HunterLimit = Si1pl
            DirectorOptions.BoomerLimit = Si1pl
            DirectorOptions.JockeyLimit = Si1pl
            DirectorOptions.SmokerLimit = Si1pl
            DirectorOptions.ChargerLimit = Si1pl
            DirectorOptions.SpitterLimit = Si1pl
            MapData.g_nSI = Si1p
            break;
        case "2":
            DirectorOptions.HunterLimit = Si2pl
            DirectorOptions.BoomerLimit = Si2pl
            DirectorOptions.JockeyLimit = Si2pl
            DirectorOptions.SmokerLimit = Si2pl
            DirectorOptions.ChargerLimit = Si2pl
            DirectorOptions.SpitterLimit = Si2pl
            MapData.g_nSI = Si2p
            break;
        case "3":
            DirectorOptions.HunterLimit = Si3pl
            DirectorOptions.BoomerLimit = Si3pl
            DirectorOptions.JockeyLimit = Si3pl
            DirectorOptions.SmokerLimit = Si3pl
            DirectorOptions.ChargerLimit = Si3pl
            DirectorOptions.SpitterLimit = Si3pl
            MapData.g_nSI = Si3p
            break;
        case "4":
            DirectorOptions.HunterLimit = Si4pl
            DirectorOptions.BoomerLimit = Si4pl
            DirectorOptions.JockeyLimit = Si4pl
            DirectorOptions.SmokerLimit = Si4pl
            DirectorOptions.ChargerLimit = Si4pl
            DirectorOptions.SpitterLimit = Si4pl
            MapData.g_nSI = Si4p
            break;
        default:
            DirectorOptions.HunterLimit = 1
            DirectorOptions.BoomerLimit = 1
            DirectorOptions.JockeyLimit = 1
            DirectorOptions.SmokerLimit = 1
            DirectorOptions.ChargerLimit = 1
            DirectorOptions.SpitterLimit = 1
            MapData.g_nSI = 4
            break;
    }
    DirectorOptions.cm_BaseSpecialLimit = MapData.g_nSI
    DirectorOptions.cm_MaxSpecials      = MapData.g_nSI
    DirectorOptions.DominatorLimit      = MapData.g_nSI
}

update_diff();
g_ModeScript.update_diff();
