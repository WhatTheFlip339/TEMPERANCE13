// MOB VAR
/mob/living/carbon/human
	var/datum/table_crawl_controller/table_crawl

// CONTROLLER
/datum/table_crawl_controller
	var/mob/living/carbon/human/owner
	var/state = TABLECRAWL_NONE
	var/tmp/next_bonk = 0

/datum/table_crawl_controller/New(mob/living/carbon/human/M)
	owner = M

// HELPERS
/datum/table_crawl_controller/proc/get_table(atom/location)
	var/turf/T = get_turf(location)
	if(!T) return null

	for(var/obj/structure/table/X in T)
		return X

// VALIDATION
/datum/table_crawl_controller/proc/can_crawl()
	var/mob/living/carbon/human/M = owner

	if(M.buckled) return FALSE
	if(M.mobility_flags & MOBILITY_STAND) return FALSE
	if(M.m_intent != MOVE_INTENT_SNEAK) return FALSE
	if(M.mob_size >= MOB_SIZE_LARGE) return FALSE

	return TRUE

/datum/table_crawl_controller/proc/can_start()
	return can_crawl() && owner.resting

// ENTRY VALIDATION
/datum/table_crawl_controller/proc/can_finish(obj/structure/table/T, turf/target)
	var/mob/living/carbon/human/M = owner
	if(QDELETED(M) || QDELETED(T))
		return FALSE
	if(!can_start())
		return FALSE
	if(get_table(M.loc))
		return FALSE
	if(get_turf(T) != target)
		return FALSE
	if(get_dist(M, T) != 1)
		return FALSE
	return TRUE

// ENTRY TRIGGER
/datum/table_crawl_controller/proc/try_enter(obj/structure/table/T, turf/target)
	if(state != TABLECRAWL_NONE)
		return
	if(!can_finish(T, target))
		return
	state = TABLECRAWL_ATTEMPTING
	INVOKE_ASYNC(src, PROC_REF(begin_enter), T, target)

/datum/table_crawl_controller/proc/begin_enter(obj/structure/table/T, turf/target)
	var/mob/living/carbon/human/M = owner

	if(QDELETED(M) || QDELETED(T))
		state = TABLECRAWL_NONE
		return
	if(!can_finish(T, target))
		state = TABLECRAWL_NONE
		return
	var/delay = T.climb_time
	M.changeNext_move(delay, override = TRUE)
	M.visible_message(
		span_warning("[M] crawls under [T]."),
		span_warning("You start crawling under [T]...")
	)

	// channeling
	if(delay && !do_after(M, delay, target = T))
		state = TABLECRAWL_NONE
		return
	if(!can_finish(T, target))
		state = TABLECRAWL_NONE
		return

	// FORCE ENTRY
	M.forceMove(target)
	state = TABLECRAWL_UNDER
	refresh()


// BONK SYSTEM
/datum/table_crawl_controller/proc/head_bonk()
	var/mob/living/carbon/human/M = owner
	var/obj/structure/table/T = get_table(M)
	var/atom/S = T ? T : M
	M.visible_message(
		span_warning("[M] bumps their head on [T ? "[T]" : "the table"]!"),
		span_warning("You bump your head!")
	)

	playsound(S, "genblunt", TABLE_CRAWL_BONK_SOUND_VOLUME, TRUE)
	M.Stun(TABLE_CRAWL_BONK_STUN)

// VISUALS
/datum/table_crawl_controller/proc/apply_visual()
	var/mob/living/carbon/human/M = owner
	M.reset_offsets("structure_climb")
	M.layer = TABLE_LAYER - TABLE_CRAWL_UNDER_LAYER_OFFSET
	M.plane = GAME_PLANE_LOWER

/datum/table_crawl_controller/proc/clear_visual()
	var/mob/living/carbon/human/M = owner
	M.reset_offsets("structure_climb")
	M.layer = LYING_MOB_LAYER
	M.plane = initial(M.plane)


// REFRESH (STATE MACHINE)
/datum/table_crawl_controller/proc/refresh()
	var/mob/living/carbon/human/M = owner

	if(state == TABLECRAWL_NONE)
		clear_visual()
		return
	if(state == TABLECRAWL_UNDER)
		if(!can_start() || !get_table(M))
			state = TABLECRAWL_NONE
			clear_visual()
			return
		apply_visual()

// MOB HOOK
/mob/living/carbon/human/set_resting(rest, silent = TRUE)
	. = ..()

	if(!table_crawl)
		table_crawl = new(src)
	if(resting)
		AddElement(/datum/element/table_crawl)
	table_crawl?.refresh()

/mob/living/carbon/human/stand_up()
	if(table_crawl?.state == TABLECRAWL_UNDER)
		if(world.time >= table_crawl.next_bonk)
			table_crawl.next_bonk = world.time + TABLE_CRAWL_BONK_COOLDOWN
			table_crawl.head_bonk()

		return FALSE

	return ..()

// ELEMENT triggers entry
/datum/element/table_crawl
	element_flags = ELEMENT_DETACH

/datum/element/table_crawl/Attach(mob/living/carbon/human/H)
	RegisterSignal(H, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(H, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))

/datum/element/table_crawl/Detach(mob/living/carbon/human/H, ...)
	UnregisterSignal(H, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_MOVED))
	H.table_crawl = null
	return ..()

/datum/element/table_crawl/proc/on_bump(mob/living/carbon/human/H, atom/A)
	if(!istype(A, /obj/structure/table))
		return
	if(!H.table_crawl)
		H.table_crawl = new(H)
	H.table_crawl.try_enter(A, get_turf(A))

/datum/element/table_crawl/proc/on_moved(mob/living/carbon/human/H)
	H.table_crawl?.refresh()
