/obj/item/gun/ballistic/revolver
	name = "\improper .357 revolver"
	desc = "" //usually used by syndicates
	icon_state = "revolver"
	fire_sound = 'sound/blank.ogg'
	load_sound = 'sound/blank.ogg'
	eject_sound = 'sound/blank.ogg'
	fire_sound_volume = 90
	dry_fire_sound = 'sound/blank.ogg'
	dist_fire_sound = DISTANTLIGHT
	casing_ejector = FALSE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	tac_reloads = FALSE
	var/spin_delay = 10
	var/recent_spin = 0
	bolt_wording = "primer"
	dry_fire_sound = 'sound/combat/ranged/revolver_dryfire.ogg'
	slot_flags = ITEM_SLOT_HIP
	icon = 'icons/roguetown/weapons/32guns.dmi'
	possible_item_intents = list(
		/datum/intent/shoot/revolver,
		INTENT_GENERIC,
		)

/obj/item/gun/ballistic/revolver/chamber_round(spin_cylinder = TRUE)
	if(spin_cylinder)
		chambered = magazine.get_round(TRUE)
	else
		chambered = magazine.stored_ammo[1]

/obj/item/gun/ballistic/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='danger'>*CLICK.*</span>")
	playsound(src, dry_fire_sound, 30, TRUE)
	chamber_round(TRUE)

/obj/item/gun/ballistic/revolver/get_ammo(countchambered = FALSE, countempties = TRUE)
	var/boolets = 0 
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/datum/intent/shoot/revolver
	chargedrain = 0
	no_early_release = TRUE

/datum/intent/shoot/revolver/get_chargetime()
	if(!mastermob || !chargetime)
		var/newtime = 0
		newtime = ((newtime + 10) - (mastermob.get_skill_level(/datum/skill/combat/revolvers) * (4)))
		if(strength_check == TRUE)
			newtime = ((newtime + 10) - (mastermob.STASTR / 2))
		else
			newtime = newtime 
		newtime = ((newtime + 20) - (mastermob.STAPER))

/datum/intent/arc/revolver
	chargetime = 1
	chargedrain = 0
	no_early_release = TRUE

/datum/intent/arc/revolver/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE

/datum/intent/arc/revolver/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = 0
		newtime = ((newtime + 10) - (mastermob.get_skill_level(/datum/skill/combat/revolvers) * (4)))
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

///////////////////
//REVOLVERS//
///////////////////

/obj/item/gun/ballistic/revolver/grandmaster
	name = "'Garland' Service Revolver"
	desc = "A very, very expensive revolver used by the Grandmaster. It's got a very nice finish, and looks very well made. It's also got a very high price tag, so you probably shouldn't be holding it. Chambered in .44."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/revolver
	force = 10
	spread = 4
	icon_state = "revolver"
	item_state = "revolver"
	slowdown = 0.15
	empty_indicator = TRUE
	fire_sound = REVOLVERSHOT
	dry_fire_sound = 'sound/combat/ranged/revolver_prime.ogg'
	load_sound = REVOLVERINSERT
	recoil = 0.15
	experimental_inhand = FALSE
	sellprice = 220

/obj/item/gun/ballistic/revolver/pace
	name = "'Pace' Prarie Revolver"
	desc = "A relatively cheap revolver, similar to the Garland. Doesn't handle as well. Not as accurate, not as well made. Still, it'll put holes in things, and that's what you need, right? Chambered in .44."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/revolver
	force = 10
	spread = 6
	icon_state = "pace"
	item_state = "pace"
	slowdown = 0.15
	empty_indicator = TRUE
	fire_sound = REVOLVERSHOT
	load_sound = REVOLVERINSERT
	recoil = 0.30
	experimental_inhand = FALSE
	sellprice = 30

/obj/item/gun/ballistic/revolver/webley
	name = "'Kesha' Break Open Revolver"
	desc = "A classic Kalarian revolver, known for its reliability and it's intuitive break open cylinder, or at least that's what the gunsmith told you. Chambered in .44."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/revolver
	force = 10
	spread = 6
	icon_state = "webley"
	item_state = "webley"
	dry_fire_sound = 'sound/combat/ranged/revhammer.ogg'
	slowdown = 0.15
	empty_indicator = TRUE
	fire_sound = 'sound/combat/ranged/webleyfire.ogg'
	load_sound = REVOLVERINSERT
	recoil = 0.30
	experimental_inhand = FALSE
	sellprice = 42

/obj/item/gun/ballistic/revolver/snub
	name = "'Land' Snubnose Revolver"
	desc = "A compact revolver with a short barrel. Notoriously inaccurate, but easy to conceal. Seems the kind of gun that a bandit would use, but you know, it gets the job done. Chambered in .380 ACP."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/snubby
	force = 9 // haha tiny gun bad
	spread = 8 // with what barrel yo?
	icon_state = "snubnose"
	item_state = "snubnose"
	dry_fire_sound = 'sound/combat/ranged/revhammer.ogg'
	slowdown = 0.1 // small gun, small slowdown
	empty_indicator = TRUE
	fire_sound = REVOLVERSHOT
	load_sound = REVOLVERINSERT
	recoil = 0.30
	experimental_inhand = FALSE
	sellprice = 24

//dogshit double barrel shotgun code

/obj/item/gun/ballistic/revolver/doublebarrel
	name = "'Ranger' Double Barrel Shotgun"
	desc = "A cheap, double barrel shotgun. Usually made by the guy that's holding it. Chambered in 12 gauge."
	w_class = WEIGHT_CLASS_BULKY
	mag_type = /obj/item/ammo_box/magazine/internal/shot/risvon
	force = 30
	spread = 0.5
	icon_state = "dshotgun"
	item_state = "dshotgun"
	slowdown = 0.15
	empty_indicator = TRUE
	fire_sound = SHOTGUNSHOT
	load_sound = SHOTGUNINSERT
	recoil = 0.30
	experimental_inhand = FALSE
	slot_flags = ITEM_SLOT_BACK
	sellprice = 40
	longarm = TRUE

/obj/item/gun/ballistic/revolver/sawedoff
	name = "TIZ 'Persuader' Pocket Shotgun"
	desc = "A one-shot, sawed off shotgun. This configuration's typically made by outlaws to help with deal negotiation. Chambered in 12 gauge."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/shot/sawedoff
	force = 20
	throwforce = 40
	spread = 0.8 // the fuck you think you're gonna hit with that barrel?
	icon_state = "singlebarrel"
	item_state = "singlebarrel"
	slowdown = 0.15
	empty_indicator = TRUE
	fire_sound = SHOTGUNSHOT
	load_sound = SHOTGUNINSERT
	recoil = 0.30
	experimental_inhand = FALSE
	slot_flags = ITEM_SLOT_HIP
	sellprice = 20
	longarm = FALSE //it's a pocket gun with one round, it should be okay

/obj/item/gun/ballistic/revolver/judge
	name = "TYK 'Judge' Revolving Rifle"
	desc = "A rifle-revolver hybrid. Typically used by national guardsmen or game hunters. Chambered in .45 Long Colt."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/judge
	force = 30 //fat stock
	spread = 2 // cut in half cuz much longer barrel
	icon = 'icons/roguetown/weapons/64guns.dmi'
	icon_state = "revolvingrifle"
	item_state = "revolvingrifle"
	dry_fire_sound = 'sound/combat/ranged/revolver_prime.ogg'
	slowdown = 0.2 //slower
	empty_indicator = TRUE
	fire_sound = REVOLVERSHOT
	load_sound = REVOLVERINSERT
	dry_fire_sound = 'sound/combat/ranged/revolver_prime.ogg'
	recoil = 0.1
	experimental_inhand = FALSE
	slot_flags = ITEM_SLOT_BACK
	sellprice = 64
	longarm = TRUE

/obj/item/gun/ballistic/revolver/mercy
	name = "LC 'Mercy' Revolver"
	desc = "A low-caliber revolver, at least it has 8 rounds in the chamber over six. Probably not gonna kill anything, unless you put it up against someone's head. Chambered in .22 LR."
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/mercy
	force = 10
	spread = 6
	icon_state = "mercy"
	item_state = "mercy"
	slowdown = 0.15
	empty_indicator = TRUE
	fire_sound = REVOLVERSHOT
	load_sound = REVOLVERINSERT
	recoil = 0.10 //22lr is a pussy caliber, so less recoil
	experimental_inhand = FALSE
	sellprice = 14
