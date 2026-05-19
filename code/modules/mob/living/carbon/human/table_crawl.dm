//------------------------------------------------------------
// MOB VAR
//------------------------------------------------------------
/mob/living/carbon/human
	var/datum/table_crawl_controller/table_crawl


//------------------------------------------------------------
// CONTROLLER
//------------------------------------------------------------
/datum/table_crawl_controller
	var/mob/living/carbon/human/owner
	var/state = TABLECRAWL_NONE
	var/tmp/next_bonk = 0

/datum/table_crawl_controller/New(mob/living/carbon/human/M)
	owner = M


//------------------------------------------------------------
// HELPERS
//------------------------------------------------------------
/datum/table_crawl_controller/proc/get_table(atom/location)
	var/turf/T = get_turf(location)
	if(!T) return null

	for(var/obj/structure/table/X in T)
		return X


//------------------------------------------------------------
// VALIDATION
//------------------------------------------------------------
/datum/table_crawl_controller/proc/can_crawl()
	var/mob/living/carbon/human/M = owner

	if(M.buckled) return FALSE
	if(M.mobility_flags & MOBILITY_STAND) return FALSE
	if(M.m_intent != MOVE_INTENT_SNEAK) return FALSE
	if(M.mob_size >= MOB_SIZE_LARGE) return FALSE

	return TRUE


/datum/table_crawl_controller/proc/can_start()
	return can_crawl() && owner.resting


//------------------------------------------------------------
// FIXED DIST CHECK (REPLACES Adjacent)
//------------------------------------------------------------
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

	// ✔ FIX: replaces Adjacent()
	if(get_dist(M, T) != 1)
		return FALSE

	return TRUE


//------------------------------------------------------------
// ENTRY (FORCED RELIABLE VERSION)
//------------------------------------------------------------
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

	var/delay = T.climb_time
	M.changeNext_move(delay, override = TRUE)

	M.visible_message(
		span_warning("[M] crawls under [T]."),
		span_warning("You crawl under [T]...")
	)

	if(delay && !do_after(M, delay, target = T))
		state = TABLECRAWL_NONE
		return

	// ✔ FORCE ENTRY (NO step(), NO signal dependency)
	M.forceMove(target)

	state = TABLECRAWL_UNDER

	refresh()


//------------------------------------------------------------
// BONK
//------------------------------------------------------------
/datum/table_crawl_controller/proc/head_bonk()
	var/mob/living/carbon/human/M = owner
	var/obj/structure/table/T = get_table(M)

	M.visible_message(
		span_warning("[M] bumps their head on [T ? "[T]" : "the table"]!"),
		span_warning("You bump your head!")
	)

	playsound(M, "genblunt", TABLE_CRAWL_BONK_SOUND_VOLUME, TRUE)
	M.Stun(TABLE_CRAWL_BONK_STUN)


//------------------------------------------------------------
// REFRESH
//------------------------------------------------------------
/datum/table_crawl_controller/proc/refresh()
	var/mob/living/carbon/human/M = owner

	if(state == TABLECRAWL_NONE)
		M.reset_offsets("structure_climb")
		M.layer = LYING_MOB_LAYER
		return

	if(state == TABLECRAWL_UNDER)
		if(!can_start() || !get_table(M))
			state = TABLECRAWL_NONE
			M.reset_offsets("structure_climb")
			M.layer = LYING_MOB_LAYER
			return

		M.reset_offsets("structure_climb")
		M.layer = TABLE_LAYER - TABLE_CRAWL_UNDER_LAYER_OFFSET
