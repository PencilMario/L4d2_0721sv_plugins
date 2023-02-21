DirectorOptions <-
{
   	ActiveChallenge = 1
	cm_AggressiveSpecials 			= true
	cm_ShouldHurry 					= 1
	cm_SpecialRespawnInterval 		= 15 //Time for an SI spawn slot to become available
	cm_SpecialSlotCountdownTime 	= 0
	
	cm_AllowPillConversion = 0
	cm_AllowSurvivorRescue = 0
	SurvivorMaxIncapacitatedCount = 0
	
	DominatorLimit 			= 3
	cm_BaseSpecialLimit 	= 3
	cm_MaxSpecials 			= 3
	BoomerLimit 			= 1
	SpitterLimit 			= 0
	HunterLimit 			= 1
	JockeyLimit 			= 1
	ChargerLimit 			= 1
	SmokerLimit 			= 0
	
	LookTempo = true

    RelaxMaxFlowTravel = 10
    RelaxMaxInterval = 1
    RelaxMinInterval = 0
	
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
 	weaponsToConvert =
	{
		weapon_first_aid_kit =	"weapon_pain_pills_spawn"
		weapon_adrenaline =	"weapon_pain_pills_spawn"
	}

	function ConvertWeaponSpawn( classname )
	{
		if ( classname in weaponsToConvert )
		{
			return weaponsToConvert[classname];
		}
		return 0;
	}
	TempHealthDecayRate = 0.001
	function RecalculateHealthDecay()
	{
		if ( Director.HasAnySurvivorLeftSafeArea() )
		{
			TempHealthDecayRate = 0.27 // pain_pills_decay_rate default
		}
	}
}

MapData <-{
	g_nSI 	= 3
	g_nTime = 3
}


function update_diff()
{
    local timer = (Convars.GetFloat("SS_Time")).tointeger()
    local Si1p = (Convars.GetFloat("sss_1P")).tointeger()
    local Si1pl = (Convars.GetFloat("sss_1P_Lim")).tointeger()

    DirectorOptions.cm_SpecialRespawnInterval = timer
    DirectorOptions.cm_SpecialSlotCountdownTime = timer
    DirectorOptions.HunterLimit = Si1pl
    DirectorOptions.BoomerLimit = Si1pl
    DirectorOptions.JockeyLimit = Si1pl
    DirectorOptions.SmokerLimit = Si1pl
    DirectorOptions.ChargerLimit = Si1pl
    DirectorOptions.SpitterLimit = Si1pl
    MapData.g_nSI = Si1p
    
    DirectorOptions.cm_BaseSpecialLimit = MapData.g_nSI
    DirectorOptions.cm_MaxSpecials      = MapData.g_nSI
    DirectorOptions.DominatorLimit      = MapData.g_nSI
}

function Update()
{
	DirectorOptions.RecalculateHealthDecay();
}
update_diff();
g_ModeScript.update_diff();
