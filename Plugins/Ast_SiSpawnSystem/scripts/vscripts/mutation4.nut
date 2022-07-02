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
    local timer = 15
    switch (difficulty){
        case "1":
            DirectorOptions.HunterLimit = 1
            DirectorOptions.BoomerLimit = 1
            DirectorOptions.JockeyLimit = 1
            DirectorOptions.SmokerLimit = 1
            DirectorOptions.ChargerLimit = 1
            DirectorOptions.SpitterLimit = 0
            MapData.g_nSI = 4
            break;
        case "2":
            DirectorOptions.HunterLimit = 2
            DirectorOptions.BoomerLimit = 1
            DirectorOptions.JockeyLimit = 2
            DirectorOptions.SmokerLimit = 2
            DirectorOptions.ChargerLimit = 2
            DirectorOptions.SpitterLimit = 1
            MapData.g_nSI = 9
            break;
        case "3":
            DirectorOptions.HunterLimit = 3
            DirectorOptions.BoomerLimit = 2
            DirectorOptions.JockeyLimit = 3
            DirectorOptions.SmokerLimit = 2
            DirectorOptions.ChargerLimit = 2
            DirectorOptions.SpitterLimit = 2
            MapData.g_nSI = 14
            break;
        case "4":
            DirectorOptions.HunterLimit = 3
            DirectorOptions.BoomerLimit = 3
            DirectorOptions.JockeyLimit = 3
            DirectorOptions.SmokerLimit = 3
            DirectorOptions.ChargerLimit = 3
            DirectorOptions.SpitterLimit = 3
            MapData.g_nSI = 18
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
