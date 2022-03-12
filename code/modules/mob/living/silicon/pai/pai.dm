/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be deactivated."
	weather_immunities = list("ash")
	health = 500
	maxHealth = 500
	layer = BELOW_MOB_LAYER
	var/obj/item/instrument/piano_synth/internal_instrument
	silicon_privileges = PRIVILEGES_PAI

	var/network = "ss13"
	var/obj/machinery/camera/current = null

	var/ram = 100	// Used as currency to purchase different abilities
	var/list/software = list()
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/paicard/card	// The card we inhabit
	var/hacking = FALSE		//Are we hacking a door?

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"

	var/obj/item/radio/headset			// The pAI's headset
	var/obj/item/pai_cable/cable		// The cable we produce and use when door or camera jacking

	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/pda/ai/pai/pda = null

	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	var/datum/data/record/medicalActive1		// Datacore record declarations for record software
	var/datum/data/record/medicalActive2

	var/datum/data/record/securityActive1		// Could probably just combine all these into one
	var/datum/data/record/securityActive2

	var/obj/machinery/door/hackdoor		// The airlock being hacked
	var/hackprogress = 0				// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check

	var/obj/item/integrated_signaler/signaler // AI's signaller

	var/encryptmod = FALSE
	var/holoform = FALSE
	var/canholo = TRUE
	var/obj/item/card/id/access_card = null
	var/chassis = "repairbot"
	var/dynamic_chassis
	var/dynamic_chassis_sit = FALSE			//whether we're sitting instead of resting spritewise
	var/dynamic_chassis_bellyup = FALSE		//whether we're lying down bellyup
	var/list/possible_chassis			//initialized in initialize.
	var/list/dynamic_chassis_icons		//ditto.

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitterregen = 0.25
	var/emitter_next_use = 0
	var/emitter_emp_cd = 300
	var/emittercd = 50
	var/emitteroverloadcd = 100

	var/radio_short = FALSE
	var/radio_short_cooldown = 3 MINUTES
	var/radio_short_timerid

	mobility_flags = NONE
	var/silent = FALSE
	var/brightness_power = 5

	var/icon/custom_holoform_icon

/mob/living/silicon/pai/Destroy()
	QDEL_NULL(internal_instrument)
	if (loc != card)
		card.forceMove(drop_location())
	card.pai = null
	card.cut_overlays()
	card.add_overlay("pai-off")
	GLOB.pai_list -= src
	return ..()

/mob/living/silicon/pai/Initialize()
	var/obj/item/paicard/P = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/paicard(newcardloc)
		P.setPersonality(src)
	forceMove(P)
	card = P
	signaler = new(src)
	if(!radio)
		radio = new /obj/item/radio/headset/silicon/pai(src)

	//PDA
	pda = new(src)
	spawn(5)
		pda.ownjob = "pAI Messenger"
		pda.owner = text("[]", src)
		pda.name = pda.owner + " (" + pda.ownjob + ")"

	possible_chassis = typelist(NAMEOF(src, possible_chassis), list("cat" = TRUE, "mouse" = TRUE, "monkey" = TRUE, "corgi" = FALSE,
									"fox" = FALSE, "repairbot" = TRUE, "rabbit" = TRUE, "borgi" = FALSE ,
									"parrot" = FALSE, "bear" = FALSE , "mushroom" = FALSE, "crow" = FALSE ,
									"fairy" = FALSE , "spiderbot" = FALSE))		//assoc value is whether it can be picked up.
	dynamic_chassis_icons = typelist(NAMEOF(src, dynamic_chassis_icons), initialize_dynamic_chassis_icons())

	. = ..()

	var/datum/action/innate/pai/software/SW = new
	var/datum/action/innate/pai/shell/AS = new /datum/action/innate/pai/shell
	var/datum/action/innate/pai/chassis/AC = new /datum/action/innate/pai/chassis
	var/datum/action/innate/pai/rest/AR = new /datum/action/innate/pai/rest
	var/datum/action/innate/pai/light/AL = new /datum/action/innate/pai/light
	var/datum/action/innate/custom_holoform/custom_holoform = new /datum/action/innate/custom_holoform

	var/datum/action/language_menu/ALM = new
	SW.Grant(src)
	AS.Grant(src)
	AC.Grant(src)
	AR.Grant(src)
	AL.Grant(src)
	ALM.Grant(src)
	custom_holoform.Grant(src)
	emitter_next_use = world.time + 10 SECONDS

/mob/living/silicon/pai/deployed/Initialize()
	. = ..()
	fold_out(TRUE)

/mob/living/silicon/pai/ComponentInitialize()
	. = ..()
	if(possible_chassis[chassis])
		AddElement(/datum/element/mob_holder, chassis, 'icons/mob/pai_item_head.dmi', 'icons/mob/pai_item_rh.dmi', 'icons/mob/pai_item_lh.dmi', ITEM_SLOT_HEAD)

/mob/living/silicon/pai/BiologicalLife(seconds, times_fired)
	if(!(. = ..()))
		return
	if(hacking)
		process_hack()

/mob/living/silicon/pai/proc/process_hack()

	if(cable && cable.machine && istype(cable.machine, /obj/machinery/door) && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
		hackprogress = clamp(hackprogress + 4, 0, 100)
	else
		temp = "Door Jack: Connection to airlock has been lost. Hack aborted."
		hackprogress = 0
		hacking = FALSE
		hackdoor = null
		return
	if(screen == "doorjack" && subscreen == 0) // Update our view, if appropriate
		paiInterface()
	if(hackprogress >= 100)
		hackprogress = 0
		var/obj/machinery/door/D = cable.machine
		D.open()
		hacking = FALSE

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/Login()
	..()
	usr << browse_rsc('html/paigrid.png')			// Go ahead and cache the interface resources as early as possible
	if(client)
		client.perspective = EYE_PERSPECTIVE
		if(holoform)
			client.eye = src
		else
			client.eye = card

/mob/living/silicon/pai/get_status_tab_items()
	. += ..()
	if(!stat)
		. += text("Emitter Integrity: [emitterhealth * (100/emittermaxhealth)]")
	else
		. += text("Systems nonfunctional")

/mob/living/silicon/pai/restrained(ignore_grab)
	. = FALSE

// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE, no_tk=FALSE)
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/proc/makePAI(delold)
	var/obj/item/paicard/card = new /obj/item/paicard(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	transfer_ckey(pai)
	pai.name = name
	card.setPersonality(pai)
	if(delold)
		qdel(src)

/datum/action/innate/pai
	name = "PAI Action"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	var/mob/living/silicon/pai/P

/datum/action/innate/pai/Trigger()
	if(!ispAI(owner))
		return 0
	P = owner

/datum/action/innate/pai/software
	name = "Software Interface"
	button_icon_state = "pai"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/software/Trigger()
	..()
	P.paiInterface()

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/shell/Trigger()
	..()
	if(P.holoform)
		P.fold_in(FALSE)
	else
		P.fold_out()

/datum/action/innate/pai/chassis
	name = "Holochassis Appearance Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/chassis/Trigger()
	..()
	P.choose_chassis()

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/rest/Trigger()
	..()
	P.lay_down()

/datum/action/innate/pai/light
	name = "Toggle Integrated Lights"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "emp"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/light/Trigger()
	..()
	P.toggle_integrated_light()

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(!.)
		add_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
		return TRUE
	remove_movespeed_modifier(/datum/movespeed_modifier/pai_spacewalk)
	return TRUE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()
	. += "A personal AI in holochassis mode. Its master ID string seems to be [master]."

/mob/living/silicon/pai/PhysicalLife()
	. = ..()
	if(cable)
		if(get_dist(src, cable) > 1)
			var/turf/T = get_turf(src.loc)
			T.visible_message("<span class='warning'>[src.cable] rapidly retracts back into its spool.</span>", "<span class='italics'>You hear a click and the sound of wire spooling rapidly.</span>")
			qdel(src.cable)
			cable = null

/mob/living/silicon/pai/BiologicalLife()
	if(!(. = ..()))
		return
	silent = max(silent - 1, 0)

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getBruteLoss() - getFireLoss()
	update_stat()

/mob/living/silicon/pai/process()
	emitterhealth = clamp((emitterhealth + emitterregen), -50, emittermaxhealth)

/obj/item/paicard/attackby(obj/item/W, mob/user, params)
	..()
	user.set_machine(src)
	var/encryption_key_stuff = W.tool_behaviour == TOOL_SCREWDRIVER || istype(W, /obj/item/encryptionkey)
	if(!encryption_key_stuff)
		return
	if(pai?.encryptmod)
		pai.radio.attackby(W, user, params)
	else
		to_chat(user, "Encryption Key ports not configured.")

/obj/item/paicard/emag_act(mob/user) // Emag to wipe the master DNA and supplemental directive
	. = ..()
	if(!pai)
		return
	to_chat(user, "<span class='notice'>You override [pai]'s directive system, clearing its master string and supplied directive.</span>")
	to_chat(pai, "<span class='danger'>Warning: System override detected, check directive sub-system for any changes.'</span>")
	log_game("[key_name(user)] emagged [key_name(pai)], wiping their master DNA and supplemental directive.")
	pai.master = null
	pai.master_dna = null
	pai.laws.supplied[1] = "None." // Sets supplemental directive to this

/mob/living/silicon/pai/proc/short_radio()
	if(radio_short_timerid)
		deltimer(radio_short_timerid)
	radio_short = TRUE
	to_chat(src, "<span class='danger'>Your radio shorts out!</span>")
	radio_short_timerid = addtimer(CALLBACK(src, .proc/unshort_radio), radio_short_cooldown, flags = TIMER_STOPPABLE)

/mob/living/silicon/pai/proc/unshort_radio()
	radio_short = FALSE
	to_chat(src, "<span class='danger'>You feel your radio is operational once more.</span>")
	if(radio_short_timerid)
		deltimer(radio_short_timerid)

/mob/living/silicon/pai/proc/initialize_dynamic_chassis_icons()
	. = list()

	//This is a horrible system and I wish I was not as lazy and did something smarter, like just generating a new icon in memory which is probably more efficient.

	//Basic /tg/ cyborgs
	.["Cyborg - Engineering (default)"] = process_holoform_icon_filter(icon('icons/mob/robots.dmi', "engineer"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Engineering (loaderborg)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "loaderborg"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Engineering (handyeng)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "handyeng"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Engineering (sleekeng)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "sleekeng"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Engineering (marinaeng)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "marinaeng"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Medical (default)"] = process_holoform_icon_filter(icon('icons/mob/robots.dmi', "medical"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Medical (marinamed)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "marinamed"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Medical (eyebotmed)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "eyebotmed"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Security (default)"] = process_holoform_icon_filter(icon('icons/mob/robots.dmi', "sec"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Security (sleeksec)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "sleeksec"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Security (marinasec)"] = process_holoform_icon_filter(icon('modular_citadel/icons/mob/robots.dmi', "marinasec"), HOLOFORM_FILTER_PAI, FALSE)
	.["Cyborg - Clown (default)"] = process_holoform_icon_filter(icon('icons/mob/robots.dmi', "clown"), HOLOFORM_FILTER_PAI, FALSE)
