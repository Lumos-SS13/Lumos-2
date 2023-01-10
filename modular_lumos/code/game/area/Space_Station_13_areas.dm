/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME   (you can make as many subdivisions as you want)
	name = "NICE NAME" (not required but makes things really nice)
	icon = 'ICON FILENAME' (defaults to 'icons/turf/areas.dmi')
	icon_state = "NAME OF ICON" (defaults to "unknown" (blank))
	requires_power = FALSE (defaults to true)
	ambience_index = AMBIENCE_GENERIC   (picks the ambience from an assoc list in ambience.dm)
	ambientsounds = list() (defaults to ambience_index's assoc on Initialize(). override it as "ambientsounds = list('sound/ambience/signal.ogg')" or by changing ambience_index)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/

/area/shuttle/cargo/CargoElevator
	name = "cargo elevator"
	has_gravity = FALSE

//Old Omega

/area/ruin/space/has_grav/oldomega/HigherHall
	name = "Old station Higher Hall"
	icon_state = "hallC"

/area/ruin/space/has_grav/oldomega/LowerHall
	name = "Old station Lower Hall"
	icon_state = "hallC"

/area/ruin/space/has_grav/oldomega/OldAtmos
	name = "Old station Atmospherics"
	icon_state = "atmos"

/area/ruin/space/has_grav/oldomega/OldMedbay
	name = "Old station Med Bay"
	icon_state = "medbay"

/area/ruin/space/has_grav/oldomega/LowerMaint
	name = "Old station Lower Maintenace"
	icon_state = "maintcentral"

/area/ruin/space/has_grav/oldomega/OldSolars
	name = "Old station Solars"
	icon_state = "yellow"

/area/ruin/space/has_grav/oldomega/HigherMaint
	name = "Old station Higher Maintenace"
	icon_state = "maintcentral"

/area/ruin/space/has_grav/oldomega/TransitCenter
	name = "Old station Transit Center"
	icon_state = "blue"

/area/ruin/space/has_grav/oldomega/OldStorage
	name = "Old station Storage"
	icon_state = "engi_storage"

/area/ruin/space/has_grav/oldomega/OldOffice
	name = "Old station Office"
	icon_state = "blue"

/area/ruin/space/has_grav/oldomega/OldEngi
	name = "Old station Engineering"
	icon_state = "engine_foyer"

/area/ruin/space/has_grav/syndicatebase1
	name = "Syndicate Telecommunications Base"
	icon_state = "red"

/area/ruin/space/has_grav/spacepolicepost
	name = "CentCom Security Post: 01"
	icon_state = "blue"

/area/ruin/space/has_grav/madscientistship
	name = "Xenobiology Prototype Ship"
	icon_state = "blue"

/area/bluespace_locker
  name = "Bluespace Locker"
  icon_state = "away"
  requires_power = FALSE
  has_gravity = STANDARD_GRAVITY
  hidden = TRUE

//Snaxi specific areas
/area/command/bridge/lower
	name = "Lower Bridge Deck"
	icon_state = "bridgelower"

/area/command/bridge/upper
	name = "Upper Bridge Deck"
	icon_state = "bridgeupper"

/area/commons/fitness/pool/oobcold //area for a hidden unreachable controller
	name = "Pool Area"
	icon_state = "pool"

/area/command/garage
	name = "Command Garage"
	icon_state = "blue"
	// ambience_index = AMBIENCE_ENGI
	ambientsounds = ENGINEERING

/area/security/garage
	name = "Security Garage"
	icon_state = "red"
	// ambience_index = AMBIENCE_ENGI
	ambientsounds = ENGINEERING

/area/commons/dorms/lower
	name = "Lower Dorms"
	icon_state = "dorms"

/area/service/basement
	name = "Service Basement"
	icon_state = "maint_bar"
		// ambience_index = AMBIENCE_MAINT
	ambientsounds = MAINTENANCE
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/science/lowmaint
	name = "Lower Science Maintenance"
	icon_state = "purple"
		// ambience_index = AMBIENCE_MAINT
	ambientsounds = MAINTENANCE
	area_flags = BLOBS_ALLOWED | CULT_PERMITTED
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/science/xenoarch //general placeholder xenoarch area
	name = "Xenoarchaeology"
	icon_state = "purple"
