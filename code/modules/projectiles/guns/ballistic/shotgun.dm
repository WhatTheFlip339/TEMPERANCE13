/obj/item/gun/ballistic/shotgun
	slowdown = 0.3 //Bulky gun slowdown with rebate since generally smaller than assault rifles
	name = "shotgun template"
	desc = "Should not exist"
	icon = 'icons/roguetown/weapons/32guns.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/back_l.dmi'
	icon_state = "risvshot"
	item_state = "risvshot"
	var/pump_sound = 'sound/blank.ogg'
	dist_fire_sound = DISTANTMEDIUM
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	force = 15
	spread = 2
	recoil = 1
	var/needs_pump = FALSE
	flags_1 =  CONDUCT_1
	casing_ejector = FALSE
	empty_indicator = TRUE
	var/recentpump = 0
	spawnwithmagazine = TRUE
	possible_item_intents = list(
		/datum/intent/shoot/shotgun,
		INTENT_GENERIC,
		)
	can_parry = TRUE
	verbage = "load"
	cartridge_wording = "bullet"
	load_sound = 'sound/foley/nockarrow.ogg'
	obj_flags = UNIQUE_RENAME
	experimental_inhand = FALSE
	internal_magazine = TRUE 
	semi_auto = FALSE
	dry_fire_sound = 'sound/combat/ranged/gun_empty.ogg'
	longarm = TRUE

/obj/item/gun/ballistic/shotgun/process_chamber(mob/living/user, empty_chamber = 0)
	return ..()

/obj/item/gun/ballistic/shotgun/can_shoot()
	if(needs_pump)
		return FALSE
	return !!chambered?.BB

/obj/item/gun/ballistic/process_chamber(empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	if(!semi_auto && from_firing)
		return

/obj/item/gun/ballistic/shotgun/attack_self(mob/living/user)
	if(recentpump > world.time)
		return
	pump(user, TRUE)
	if(HAS_TRAIT(user, TRAIT_FIREARMS_EXPERT)) //unused rn
		recentpump = world.time + 2
	else
		recentpump = world.time + 10


/obj/item/gun/ballistic/shotgun/proc/pump(mob/M, visible = TRUE)
	if(visible)
		M.visible_message("<span class='warning'>[M] racks the [src].</span>", "<span class='warning'>You rack the [src].</span>")
	playsound(M, pump_sound, 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/ballistic/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.forceMove(drop_location())//Eject casing
		chambered.bounce_away()
		chambered = null

/obj/item/gun/ballistic/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	needs_pump = FALSE
	chambered = AC

/obj/item/gun/ballistic/shotgun/examine(mob/user)
	. = ..()
	if (chambered)
		. += "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/datum/intent/shoot/shotgun
	chargedrain = 0
	no_early_release = TRUE

/datum/intent/shoot/shotgun/get_chargetime()
	if(!mastermob || !chargetime)
		var/newtime = 0
		newtime = ((newtime + 10) - (mastermob.get_skill_level(/datum/skill/combat/shotguns) * (2.3)))
		if(strength_check == TRUE)
			newtime = ((newtime + 10) - (mastermob.STASTR / 2))
		else
			newtime = newtime 
		newtime = ((newtime + 20) - (mastermob.STAPER))

/datum/intent/arc/shotgun
	chargetime = 1
	chargedrain = 0
	no_early_release = TRUE

/datum/intent/arc/shotgun/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE

/datum/intent/arc/shotgun/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = 0
		newtime = ((newtime + 10) - (mastermob.get_skill_level(/datum/skill/combat/shotguns) * (2)))
		if(strength_check == TRUE)
			newtime = ((newtime + 10) - (mastermob.STASTR / 2))
		else
			newtime = newtime 
		newtime = ((newtime + 20) - (mastermob.STAPER))
		if(newtime > 3)
			return newtime
		else
			return 3
	else
		return chargetime

/obj/item/gun/ballistic/rifle/postfire_empty_checks(last_shot_succeeded)
    if(last_shot_succeeded && !semi_auto)
        needs_pump = TRUE
    ..()

// in-game shotguns

/obj/item/gun/ballistic/shotgun/risvon
	name = "RTK 'Hero'"
	desc = "Paint some ugly holes into your enemies. Two shots, plus one. Glory to the Risvonian WAR MACHINE. Chambered in 12 gauge."
	icon_state = "risvshot"
	item_state = "risvshot"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/risvon
	slowdown = 0.15
	spread = 0.5
	fire_sound = SHOTGUNSHOT
	pump_sound = 'sound/combat/ranged/shotgunpump.ogg'
	recoil = 0.15
	load_sound = SHOTGUNINSERT
	sellprice = 64

/obj/item/gun/ballistic/rifle/repeater/auto8
	name = "AO-8 'Willbreaker'"
	desc = "Death comes slowly, then all at once. Chambered in 12 gauge."
	icon = 'icons/roguetown/weapons/64guns.dmi'
	icon_state = "auto8"
	item_state = "auto8"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/auto8
	slowdown = 0.15
	spread = 0.5
	fire_sound = AUTOSGSHOT
	pump_sound = 'sound/combat/ranged/patiencecock.ogg'
	recoil = 0.15
	load_sound = SHOTGUNINSERT
	semi_auto = TRUE
	sellprice = 300

/obj/item/gun/ballistic/rifle/repeater/auto5
	name = "AO-5 'Gloria'"
	desc = "A sawed-off AO-8 with a smaller tube. Strangely, these can be found in the WAR MACHINE already sawed off- but only very rarely. Chambered in 12 gauge."
	icon = 'icons/roguetown/weapons/64guns.dmi'
	icon_state = "auto5"
	item_state = "auto5"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/auto5
	slowdown = 0.15
	spread = 0.5
	fire_sound = AUTOSGSHOT
	pump_sound = 'sound/combat/ranged/patiencecock.ogg'
	recoil = 0.15
	load_sound = SHOTGUNINSERT
	semi_auto = TRUE
	sellprice = 180

/obj/item/gun/ballistic/shotgun/levershotgun
	name = "MNZ 'Hare'"
	desc = "A lever action shotgun! These have recently acquired some fame after being adopted by the Voltigeurs. Chambered in 12 gauge."
	icon = 'icons/roguetown/weapons/64guns.dmi'
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "levershotgun"
	item_state = "levershotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/levershotgun
	slowdown = 0.15
	spread = 0.5
	fire_sound = SHOTGUNSHOT
	pump_sound = 'sound/combat/ranged/leveractioncock.ogg'
	recoil = 0.15
	load_sound = SHOTGUNINSERT
	sellprice = 42
