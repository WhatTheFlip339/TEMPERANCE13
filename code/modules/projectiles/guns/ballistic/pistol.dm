/obj/item/gun/ballistic/pistol
	name = "\improper dogshit pistol"
	desc = "" //usually used by syndicates
	icon_state = "pistol"
	fire_sound = 'sound/blank.ogg'
	load_sound = 'sound/blank.ogg'
	eject_sound = 'sound/blank.ogg'
	fire_sound_volume = 90
	dry_fire_sound = 'sound/blank.ogg'
	dist_fire_sound = DISTANTLIGHT
	far_volume = 30 //60 max, default 50. pistols are quieter than revolvers to give them slight differentiation
	casing_ejector = FALSE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	tac_reloads = FALSE
	var/spin_delay = 10
	var/recent_spin = 0
	bolt_wording = "primer"
	dry_fire_sound = 'sound/blank.ogg'
	slot_flags = ITEM_SLOT_HIP
	icon = 'icons/roguetown/weapons/32guns.dmi'
	possible_item_intents = list(
		/datum/intent/shoot/pistol,
		INTENT_GENERIC,
		)
/datum/intent/shoot/pistol
	chargedrain = 0
	no_early_release = TRUE

/datum/intent/shoot/pistol/get_chargetime()
	if(!mastermob || !chargetime)
		var/newtime = 0
		newtime = ((newtime + 10) - (mastermob.get_skill_level(/datum/skill/combat/pistols) * (4)))
		if(strength_check == TRUE)
			newtime = ((newtime + 10) - (mastermob.STASTR / 2))
		else
			newtime = newtime 
		newtime = ((newtime + 20) - (mastermob.STAPER))

/datum/intent/arc/pistol
	chargetime = 1
	chargedrain = 0
	no_early_release = TRUE

/datum/intent/arc/pistol/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE

/datum/intent/arc/pistol/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = 0
		newtime = ((newtime + 10) - (mastermob.get_skill_level(/datum/skill/combat/pistols) * (4)))
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

/////////////  pistols


/obj/item/gun/ballistic/rifle/repeater/pistol 
	name = "SiR 'Harland'"
	desc = "A clip-loaded pistol. Mass produced, and issued to Risvon Soldats. Chambered in 9mm."
	icon_state = "pocketpistol"
	item_state = "pocketpistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/pistol
	slowdown = 0.15
	spread = 0.5
	pump_sound = 'sound/combat/ranged/hpistol_cock.ogg'
	fire_sound = PISTOLSHOT
	load_sound = 'sound/combat/ranged/clipload.ogg'
	recoil = 0.15
	slot_flags = ITEM_SLOT_HIP
	semi_auto = TRUE
	sellprice = 12
	longarm = FALSE

/obj/item/gun/ballistic/rifle/repeater/jackal 
	name = "SPR 'Jackal'"
	desc = "One of the few semi-automatic designs that's ever been produced. Comes with its own magazine, and fires a weak cartridge. Chambered in .22 LR."
	icon_state = "handgun"
	item_state = "handgun"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/jackal
	slowdown = 0.15
	spread = 0.5
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = PISTOLSHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.15
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_HIP
	sellprice = 30
	longarm = FALSE

/obj/item/gun/ballistic/rifle/repeater/commandant
	name = "ANL 'Liberation'"
	desc = "Clip-loaded, semi-automatic pistol. Honor the Divegat. Chambered in 9mm."
	icon_state = "machinepistol"
	item_state = "machinepistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/machinepistol
	slowdown = 0.15
	spread = 0.5
	pump_sound = 'sound/combat/ranged/hpistol_cock.ogg'
	fire_sound = PISTOLSHOT
	load_sound = 'sound/combat/ranged/clipload.ogg'
	recoil = 0.15
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_BACK
	sellprice = 160

/obj/item/gun/ballistic/rifle/repeater/fury
	name = "XOZ 'Fury'"
	desc = "A rather rare semi-auto pistol. Chambered in .45 ACP."
	icon_state = "colt"
	item_state = "colt"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/fury
	slowdown = 0.15
	spread = 0.5
	force = 25 //heavy pistol, should be good for whipping someone in the head with
	pump_sound = 'sound/combat/ranged/hpistol_cock.ogg'
	fire_sound = COLTSHOT
	load_sound = 'sound/combat/ranged/coltmagin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.15
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_HIP
	sellprice = 70
	longarm = FALSE

/obj/item/gun/ballistic/rifle/repeater/broomhandle
	name = "KR 'Trenchsweeper'"
	desc = "Heavy and uncomfortable, requiring two hands to fire. Engraved with a golden 'KR'. Chambered in 7.62mmR."
	icon_state = "broomhandle"
	item_state = "broomhandle"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/broomhandle
	slowdown = 0.25 //BIG pistol
	spread = 0.5
	force = 25 //heavy pistol, should be good for whipping someone in the head with
	pump_sound = 'sound/combat/ranged/hpistol_cock.ogg'
	fire_sound = RIFLESHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.2 //make it FEEL uncomfortable
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_BACK
	sellprice = 90

/obj/item/gun/ballistic/rifle/repeater/luger
	name = "KR 'Confessor'"
	desc = "You know, they say that these guns are unique to King's Row - coming from an Outlet that hasn't been discovered by either of the two Nations. Chambered in 9mm."
	icon_state = "officerluger"
	item_state = "officerluger"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/luger
	slowdown = 0.15
	spread = 0.5
	force = 15 
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = PISTOLSHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.15
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_HIP
	sellprice = 64
	longarm = FALSE

/obj/item/gun/ballistic/rifle/repeater/offiseroluger
	name = "ZOM 'Galinha'"
	desc = "Straight from the Machine. Chambered in 9mm."
	icon_state = "luger"
	item_state = "luger"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/luger
	slowdown = 0.15
	spread = 0.5
	force = 15 
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = PISTOLSHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.15
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_HIP
	sellprice = 48
	longarm = FALSE

/obj/item/gun/ballistic/rifle/repeater/artyluger
	name = "KR 'Preacher'"
	desc = "In-house modification of a Confessor, rather expensive. Chambered in 9mm."
	icon_state = "artyluger"
	item_state = "artyluger"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/luger
	slowdown = 0.2
	spread = 0.5
	force = 30 //it has a fat fucking stock lemme smack a motherfucker with it
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = PISTOLSHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.05 //stocked pistol
	semi_auto = TRUE
	sellprice = 90

/obj/item/gun/ballistic/rifle/repeater/infiltrator
	name = "KR 'Infiltrator'"
	desc = "A 20-round, semi-automatic pistol. It goes all in on the ammo capacity - meaning that the caliber's pretty weak, and it can't be reloaded. Chambered in .30."
	icon_state = "mauser"
	item_state = "mauser"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/infiltrator
	slowdown = 0.15
	spread = 0.5
	force = 15 
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = CARBINESHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.15
	semi_auto = TRUE
	slot_flags = ITEM_SLOT_HIP
	sellprice = 20 //assume people are going to be selling these empty
	longarm = FALSE

/obj/item/gun/ballistic/rifle/repeater/mpcolt
	name = "MP 'Certain Fury'"
	desc = "In-fort modification of a Fury, fitted with a stock made from some other rifle, a grip, and with a flared magwell, allowing it to fit in bigger magazines. Chambered in .45 ACP."
	icon = 'icons/roguetown/weapons/64guns.dmi'
	icon_state = "mp1911"
	item_state = "mp1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/cfmag
	slowdown = 0.2
	spread = 0.5
	force = 30 //it has a fat fucking stock lemme smack a motherfucker with it
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = COLTSHOT
	load_sound = 'sound/combat/ranged/coltmagin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.05 //stocked pistol
	semi_auto = TRUE
	sellprice = 64

/obj/item/gun/ballistic/rifle/repeater/risvocarb
	name = "KAR 'Marland' Pistol Carbine"
	desc = "A modified Harland pistol fitted with a cheap stock, and with a much more expensive internal magazine. Chambered in 9mm."
	icon = 'icons/roguetown/weapons/64guns.dmi'
	icon_state = "m1912"
	item_state = "m1912"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/risvocarb
	slowdown = 0.2
	spread = 0.5
	force = 30 //it has a fat fucking stock lemme smack a motherfucker with it
	pump_sound = 'sound/combat/ranged/pistol_cock.ogg'
	fire_sound = CARBINESHOT
	load_sound = 'sound/combat/ranged/pistol_magin.ogg'
	eject_sound = 'sound/combat/ranged/pistol_magout.ogg'
	recoil = 0.05 //stocked pistol
	semi_auto = TRUE
	sellprice = 64
