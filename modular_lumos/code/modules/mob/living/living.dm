/mob/living
	var/size_multiplier = RESIZE_NORMAL

/// Returns false on failure
/mob/living/proc/update_size(new_size)
	if(!new_size)
		return FALSE
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/oldsize = get_size(H)
		if(new_size == oldsize)
			return FALSE
		H.dna.features["body_size"] = new_size
		H.dna.update_body_size(oldsize)
	else
		var/oldsize = get_size(src)
		if(new_size == oldsize)
			return FALSE
		size_multiplier = new_size
		resize = new_size / oldsize
		update_transform()
	switch(get_size(src))
		if(0 to 40)
			mob_size = MOB_SIZE_TINY
		if(41 to 80)
			mob_size = MOB_SIZE_SMALL
		if(81 to 120)
			mob_size = MOB_SIZE_HUMAN
		if(121 to INFINITY)
			mob_size = MOB_SIZE_LARGE

	return TRUE

/mob/living
	var/datum/gunpoint/gunpointing
	var/list/gunpointed = list()
	var/obj/effect/overlay/gunpoint_effect/gp_effect

/atom
	var/pseudo_z_axis

/atom/proc/get_fake_z()
	return pseudo_z_axis

/obj/structure/table
	pseudo_z_axis = 8

/turf/open/get_fake_z()
	var/objschecked
	for(var/obj/structure/structurestocheck in contents)
		objschecked++
		if(structurestocheck.pseudo_z_axis)
			return structurestocheck.pseudo_z_axis
		if(objschecked >= 25)
			break
	return pseudo_z_axis

/mob/living/Move(atom/newloc, direct)
	. = ..()
	if(.)
		pseudo_z_axis = newloc.get_fake_z()
		pixel_z = pseudo_z_axis
