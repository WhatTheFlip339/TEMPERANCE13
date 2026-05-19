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
// STATE HELPERS
//------------------------------------------------------------
/datum/table_crawl_controller/proc/is_under()
	return state == TABLECRAWL_UNDER


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


/datum/table_crawl_controller/proc/can_remain()
	return can_crawl() && owner.resting


//------------------------------------------------------------
// SAFE PASS CHECK (NO DENSITY MUTATION)
//------------------------------------------------------------
/datum/table_crawl_controller/proc/can_virtual(obj/structure/table/T, turf/target)
	var/mob/living/carbon/human/M = owner
	var/turf/S = get_turf(M)

	if(!S || !target || S == target)
		return FALSE

	if(S.LinkBlockedWithAccess(target, M, null))
		return FALSE

	if(!target.CanPass(M, target))
		return FALSE

	for(var/atom/movable/A as anything in target)
		if(A == M || A == T) continue
		if(!A.CanPass(M, S))
			return FALSE

	return TRUE


//------------------------------------------------------------
// ENTRY CHECK
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

	if(get_dist(M, T) != 1)
		return FALSE

	if(!can_virtual(T, target))
		return FALSE

	return TRUE


//------------------------------------------------------------
// ENTRY
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

	if(!can_finish(T, target))
		state = TABLECRAWL_NONE
		return

	var/delay = T.climb_time
	M.changeNext_move(delay, override = TRUE)

	M.visible_message(
		span_warning("[M] starts crawling under [T]."),
		span_warning("You start crawling under [T]...")
	)

	if(delay && !do_after(M, delay, target = T))
		state = TABLECRAWL_NONE
		return

	if(!can_finish(T, target))
		state = TABLECRAWL_NONE
		return

	state = TABLECRAWL_PENDING

	var/d = get_dir(M, target)
	if(!d || !step(M, d))
		state = TABLECRAWL_NONE


//------------------------------------------------------------
// IMPORTANT FIX: FINALIZE STATE HERE
//------------------------------------------------------------
/datum/table_crawl_controller/proc/on_moved()
	var/mob/living/carbon/human/M = owner

	if(state == TABLECRAWL_PENDING && get_table(M))
		state = TABLECRAWL_UNDER

	refresh()


//------------------------------------------------------------
// BONK
//------------------------------------------------------------
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


/datum/table_crawl_controller/proc/try_bonk()
	if(!is_under())
		return FALSE

	if(world.time < next_bonk)
		return FALSE

	next_bonk = world.time + TABLE_CRAWL_BONK_COOLDOWN
	head_bonk()
	refresh()
	return TRUE


//------------------------------------------------------------
// VISUAL
//------------------------------------------------------------
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


//------------------------------------------------------------
// REFRESH (CRITICAL FIX HERE)
//------------------------------------------------------------
/datum/table_crawl_controller/proc/refresh()
	var/mob/living/carbon/human/M = owner

	if(state == TABLECRAWL_NONE)
		clear_visual()
		return

	if(state == TABLECRAWL_UNDER)
		if(!can_remain() || !get_table(M))
			state = TABLECRAWL_NONE
			clear_visual()
			return

		apply_visual()
