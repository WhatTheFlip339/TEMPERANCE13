
//====================================================================


/mob/living/carbon/human
	var/tmp/table_crawl_state = TABLECRAWL_NONE
	var/tmp/table_crawl_passtable_owned = FALSE
	var/tmp/table_crawl_restoring = FALSE
	var/tmp/table_crawl_next_bonk = 0
	var/tmp/table_crawl_next_action_warning = 0
	var/tmp/list/table_crawl_spell_actions


// State Helpers
//====================================================================

/mob/living/carbon/human/proc/is_table_crawl_player()
	return !!mind && !!client

/mob/living/carbon/human/proc/is_under_table()
	return table_crawl_state == TABLECRAWL_UNDER

/mob/living/carbon/human/proc/is_table_crawling()
	return table_crawl_state != TABLECRAWL_NONE

/mob/living/carbon/human/proc/set_table_crawl_state(new_state)
	table_crawl_state = new_state
	refresh_table_crawl()

/mob/living/carbon/human/proc/end_table_crawl()
	table_crawl_state = TABLECRAWL_NONE
	clear_table_crawl_passtable()
	clear_table_crawl_spell_actions()
	update_table_crawl_visibility()
	clear_table_crawl_visual()


// Validation
//====================================================================

/mob/living/carbon/human/proc/can_table_crawl()
	if(buckled) return FALSE
	if(mobility_flags & MOBILITY_STAND) return FALSE
	if(m_intent != MOVE_INTENT_SNEAK) return FALSE
	if(mob_size >= MOB_SIZE_LARGE) return FALSE
	return TRUE

/mob/living/carbon/human/proc/can_start_table_crawl()
	return can_table_crawl() && resting

/mob/living/carbon/human/proc/can_remain_table_crawl()
	return can_table_crawl() && resting

/mob/living/carbon/human/proc/get_table_crawl_table(atom/location = loc)
	var/turf/T = get_turf(location)
	if(!T) return
	for(var/obj/structure/table/t in T)
		return t

/mob/living/carbon/human/proc/get_table_crawl_delay(obj/structure/table/T)
	var/delay = T.climb_time
	if(restrained()) delay *= 2
	if(HAS_TRAIT(src, TRAIT_FREERUNNING)) delay *= 0.8
	delay -= STASPD * 2
	return max(delay, 0)


// SAFE VIRTUAL CLIMB CHECK (NO DENSITY MUTATION)
//====================================================================

/mob/living/carbon/human/proc/can_virtual_table_climb(obj/structure/table/T, turf/target_turf)
	var/turf/source_turf = get_turf(src)

	if(!source_turf || !target_turf || source_turf == target_turf)
		return FALSE

	if(source_turf.LinkBlockedWithAccess(target_turf, src, null))
		return FALSE

	if(!target_turf.CanPass(src, target_turf))
		return FALSE

	for(var/atom/movable/A as anything in target_turf)
		if(A == src || A == T) continue
		if(!A.CanPass(src, source_turf))
			return FALSE

	return TRUE


/mob/living/carbon/human/proc/can_finish_table_crawl(obj/structure/table/T, turf/target_turf)
	if(QDELETED(src) || QDELETED(T)) return FALSE
	if(!is_table_crawl_player()) return FALSE
	if(!can_start_table_crawl()) return FALSE
	if(get_table_crawl_table(loc)) return FALSE
	if(get_turf(T) != target_turf) return FALSE
	if(!Adjacent(T)) return FALSE
	if(!can_virtual_table_climb(T, target_turf)) return FALSE
	return TRUE



// Movement
//====================================================================

/mob/living/carbon/human/proc/try_offer_table_crawl(obj/structure/table/T, turf/target_turf)
	if(is_table_crawling()) return
	if(table_crawl_state == TABLECRAWL_ATTEMPTING || doing) return
	if(!can_finish_table_crawl(T, target_turf)) return

	table_crawl_state = TABLECRAWL_ATTEMPTING
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/carbon/human, begin_table_crawl_attempt), T, target_turf)


/mob/living/carbon/human/proc/begin_table_crawl_attempt(obj/structure/table/T, turf/target_turf)
	if(QDELETED(src) || QDELETED(T) || QDELETED(target_turf))
		table_crawl_state = TABLECRAWL_NONE
		return

	if(!can_finish_table_crawl(T, target_turf))
		table_crawl_state = TABLECRAWL_NONE
		return

	var/delay = get_table_crawl_delay(T)
	changeNext_move(max(delay, CLICK_CD_MELEE), override = TRUE)

	visible_message(span_warning("[src] starts to crawl under [T]."),
	span_warning("You start to crawl under [T]..."))

	if(delay && !do_after(src, delay, target = T,
		extra_checks = CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, can_finish_table_crawl), T, target_turf)))
		table_crawl_state = TABLECRAWL_NONE
		return

	if(!can_finish_table_crawl(T, target_turf))
		table_crawl_state = TABLECRAWL_NONE
		return

	set_table_crawl_state(TABLECRAWL_PENDING)

	var/dir = get_dir(src, target_turf)
	if(!dir || !step(src, dir))
		table_crawl_state = TABLECRAWL_NONE


/mob/living/carbon/human/proc/table_crawl_head_bonk()
	var/obj/structure/table/T = get_table_crawl_table()
	var/atom/S = T ? T : src
	var/name = T ? "[T]" : "the table"

	visible_message(span_warning("[src] bumps their head on [name]!"),
	span_warning("You bump your head on [name]!"))

	playsound(S, "genblunt", 100, TRUE)
	Stun(5 SECONDS)



// BONK ENTRY GUARD
//====================================================================

/mob/living/carbon/human/proc/try_table_crawl_head_bonk()
	if(!is_under_table() || !get_table_crawl_table())
		return FALSE

	if(world.time >= table_crawl_next_bonk)
		table_crawl_next_bonk = world.time + 1 SECONDS
		table_crawl_head_bonk()

	refresh_table_crawl()
	return TRUE



// VISUALS
//====================================================================

/mob/living/carbon/human/proc/apply_table_crawl_visual()
	reset_offsets("structure_climb")
	layer = TABLE_LAYER - 0.1
	plane = GAME_PLANE_LOWER


/mob/living/carbon/human/proc/clear_table_crawl_visual()
	var/obj/structure/table/T = get_table_crawl_table()

	if(T?.climb_offset)
		set_mob_offsets("structure_climb", _x = 0, _y = T.climb_offset)
	else
		reset_offsets("structure_climb")

	layer = LYING_MOB_LAYER
	plane = initial(plane)


/mob/living/carbon/human/proc/update_table_crawl_visibility()
	if(is_under_table())
		overlay_fullscreen("table_crawl_view", /atom/movable/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("table_crawl_view", 0)



// SPELL + ACTION BLOCKING
//====================================================================

/mob/living/carbon/human/proc/interrupt_table_crawl_offense()
	if(in_throw_mode) throw_mode_off()
	if(ranged_ability) ranged_ability.deactivate(src)
	else if(click_intercept && click_intercept != src)
		if(hascall(click_intercept, "end_targeting"))
			call(click_intercept, "end_targeting")()



// REFRESH CORE
//====================================================================

/mob/living/carbon/human/proc/refresh_table_crawl()
	if(table_crawl_state == TABLECRAWL_PENDING && !get_table_crawl_table())
		table_crawl_state = TABLECRAWL_NONE

	if(table_crawl_state == TABLECRAWL_NONE)
		clear_table_crawl_visual()
		update_table_crawl_visibility()
		clear_table_crawl_spell_actions()
		return

	if(table_crawl_state == TABLECRAWL_UNDER)
		if(!can_remain_table_crawl() || !get_table_crawl_table())
			end_table_crawl()
			return

		interrupt_table_crawl_offense()
		apply_table_crawl_visual()
		update_table_crawl_visibility()
		update_table_crawl_spell_actions()



// SPELL BLOCKING
//====================================================================

/mob/living/carbon/human/proc/handle_table_crawl_spell_trigger(datum/action/spell_action/source, datum/action/action)
	SIGNAL_HANDLER
	if(!is_under_table()) return NONE
	return COMPONENT_ACTION_BLOCK_TRIGGER



// PASSTABLE
//====================================================================

/mob/living/carbon/human/proc/clear_table_crawl_passtable()
	if(!table_crawl_passtable_owned) return
	table_crawl_passtable_owned = FALSE
	pass_flags &= ~PASSTABLE



// HOOKS
//====================================================================

/mob/living/carbon/human/set_resting(rest, silent = TRUE)
	if(!rest && try_table_crawl_head_bonk())
		rest = TRUE

	. = ..()

	if(resting && is_table_crawl_player())
		AddElement(/datum/element/table_crawl)

	refresh_table_crawl()


/mob/living/carbon/human/toggle_rest()
	if(resting && try_table_crawl_head_bonk())
		return
	return ..()


/mob/living/carbon/human/stand_up()
	if(try_table_crawl_head_bonk())
		return FALSE
	return ..()


// ELEMENT 
//====================================================================

/datum/element/table_crawl
	element_flags = ELEMENT_DETACH

/datum/element/table_crawl/Attach(datum/target)
	if(!ishuman(target)) return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))
	RegisterSignal(target, COMSIG_MOB_CLICKON, PROC_REF(on_click))

/datum/element/table_crawl/Detach(mob/living/carbon/human/source, ...)
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_BUMP, COMSIG_MOB_CLICKON))
	source.end_table_crawl()
	return ..()

/datum/element/table_crawl/proc/on_bump(mob/living/carbon/human/source, atom/A)
	if(source.is_table_crawling() || !source.can_start_table_crawl()) return NONE
	if(!istype(A, /obj/structure/table)) return NONE
	source.try_offer_table_crawl(A, get_turf(A))

/datum/element/table_crawl/proc/on_moved(mob/living/carbon/human/source)
	source.clear_table_crawl_passtable()
	source.refresh_table_crawl()
