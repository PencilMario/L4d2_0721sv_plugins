#if defined _f18airstrike_included
  #endinput
#endif
#define _f18airstrike_included


/**
 * @brief Creates an F-18 AirStrike at the location and from the direction specified.
 *
 * @param		origin       Vector origin.
 * @param		direction    float angle direction for the jet to appear.
 * @return		none.
 */
native void F18_ShowAirstrike(float origin[3], float direction);


/**
 * @brief Sets when the plugin is turned on or off.
 *
 * @param		pluginstate		0=Off, 1=On.
 * @return		none.
 */
forward void F18_OnPluginState(int pluginstate);


/**
 * @brief Sets when the plugin is active/inactive in a round.
 *
 * @param		roundstate		0=Started, 1=Stopped.
 * @return		none.
 */
forward void F18_OnRoundState(int roundstate);


/**
 * @brief Called when an AirStrike is created, vector position of where the AirStrike originates
 *
 * @param		origin       Vector origin.
 * @return		none.
 */
forward void F18_OnAirstrike(float origin[3]);


/**
 * @brief Called when the missile impacts, vector position of where the explosion is
 *
 * @param		origin       Vector origin.
 * @return		none.
 */
forward void F18_OnMissileHit(float origin[3]);