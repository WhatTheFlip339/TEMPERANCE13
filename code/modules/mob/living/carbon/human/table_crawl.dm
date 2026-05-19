
// vars
//====================================================================

/mob/living/carbon/human
	var/tmp/table_crawl_state = TABLECRAWL_NONE
	var/tmp/table_crawl_passtable_owned = FALSE
	var/tmp/table_crawl_restoring = FALSE
	var/tmp/table_crawl_next_bonk = 0
	var/tmp/table_crawl_next_action_warning = 0
	var/tmp/list/table_crawl_spell_actions


// state helpers
//====================================================================

/mob/living/carbon/human/proc/is_table_crawl_player()
	return !!mind && !!client

/mob/living/carbon/human/proc/is_under_table()
	return table_crawl_state == TABLECRAWL_UNDER

/mob/living/carbon/human/proc/is_table_crawling()
	return table_crawl_state != TABLECRAWL_NONE


/mob/living/carbon/human/proc/set_table_crawl_state(s)
	table_crawl_state = s
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



// safety check
//====================================================================

/mob/living/carbon/human/proc/can_virtual_table_climb(obj/structure/table/T, turf/target)
	var/turf/S = get_turf(src)
	if(!S || !target || S == target) return FALSE

	if(S.LinkBlockedWithAccess(target, src, null)) return FALSE
	if(!target.CanPass(src, target)) return FALSE

	for(var/atom/movable/A as anything in target)
		if(A == src || A == T) continue
		if(!A.CanPass(src, S)) return FALSE

	return TRUE


/mob/living/carbon/human/proc/can_finish_table_crawl(obj/structure/table/T, turf/target)
	if(QDELETED(src) || QDELETED(T)) return FALSE
	if(!is_table_crawl_player()) return FALSE
	if(!can_start_table_crawl()) return FALSE
	if(get_table_crawl_table(loc)) return FALSE
	if(get_turf(T) != target) return FALSE
	if(!Adjacent(T)) return FALSE
	if(!can_virtual_table_climb(T, target)) return FALSE
	return TRUE



// movement flow
//====================================================================

/mob/living/carbon/human/proc/try_offer_table_crawl(obj/structure/table/T, turf/target)
	if(is_table_crawling()) return
	if(table_crawl_state == TABLECRAWL_ATTEMPTING || doing) return
	if(!can_finish_table_crawl(T, target)) return

	table_crawl_state = TABLECRAWL_ATTEMPTING
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/carbon/human, begin_table_crawl_attempt), T, target)


/mob/living/carbon/human/proc/begin_table_crawl_attempt(obj/structure/table/T, turf/target)
	if(QDELETED(src) || QDELETED(T)) { table_crawl_state = TABLECRAWL_NONE; return }
	if(!can_finish_table_crawl(T, target)) { table_crawl_state = TABLECRAWL_NONE; return }

	var/delay = max(T.climb_time, 0)
	changeNext_move(delay, override = TRUE)

	visible_message(span_warning("[src] starts crawling under [T]."),
	span_warning("You start crawling under [T]..."))

	if(delay && !do_after(src, delay, target = T,
		extra_checks = CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human/can_finish_table_crawl), T, target)))
		table_crawl_state = TABLECRAWL_NONE
		return

	if(!can_finish_table_crawl(T, target)) { table_crawl_state = TABLECRAWL_NONE; return }

	set_table_crawl_state(TABLECRAWL_PENDING)

	var/d = get_dir(src, target)
	if(!d || !step(src, d))
		table_crawl_state = TABLECRAWL_NONE



// state
//====================================================================

/mob/living/carbon/human/proc/finalize_table_crawl()
	if(table_crawl_state == TABLECRAWL_PENDING && get_table_crawl_table())
		table_crawl_state = TABLECRAWL_UNDER


// bonk code
//====================================================================

/mob/living/carbon/human/proc/table_crawl_head_bonk()
	var/obj/structure/table/T = get_table_crawl_table()
	var/atom/S = T ? T : src
	var/n = T ? "[T]" : "the table"

	visible_message(span_warning("[src] bumps their head on [n]!"),
	span_warning("You bump your head on [n]!"))

	playsound(S, "genblunt", TABLE_CRAWL_BONK_SOUND_VOLUME, TRUE)
	Stun(TABLE_CRAWL_BONK_STUN)


// visuality with tables
//====================================================================

/mob/living/carbon/human/proc/apply_table_crawl_visual()
	reset_offsets("structure_climb")
	layer = TABLE_LAYER - TABLE_CRAWL_UNDER_LAYER_OFFSET
	plane = GAME_PLANE_LOWER


/mob/living/carbon/human/proc/clear_table_crawl_visual()
	var/obj/structure/table/T = get_table_crawl_table()
	if(T?.climb_offset)
		set_mob_offsets("structure_climb", _y = T.climb_offset)
	else
		reset_offsets("structure_climb")

	layer = LYING_MOB_LAYER
	plane = initial(plane)


/mob/living/carbon/human/proc/update_table_crawl_visibility()
	if(is_under_table())
		overlay_fullscreen(TABLE_CRAWL_FULLSCREEN_CATEGORY, /atom/movable/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen(TABLE_CRAWL_FULLSCREEN_CATEGORY, 0)


// spells under table
//====================================================================

/mob/living/carbon/human/proc/clear_table_crawl_spell_actions()
	if(!table_crawl_spell_actions) return
	for(var/datum/action/spell_action/A in table_crawl_spell_actions)
		UnregisterSignal(A, COMSIG_ACTION_TRIGGER, PROC_REF(handle_table_crawl_spell_trigger))
	table_crawl_spell_actions.Cut()


/mob/living/carbon/human/proc/handle_table_crawl_spell_trigger(datum/action/spell_action/source, datum/action/action)
	SIGNAL_HANDLER
	if(!is_under_table()) return NONE
	return COMPONENT_ACTION_BLOCK_TRIGGER


// refreshing stuff
//====================================================================

/mob/living/carbon/human/proc/refresh_table_crawl()
	if(table_crawl_state == TABLECRAWL_PENDING)
		finalize_table_crawl()

	if(table_crawl_state == TABLECRAWL_NONE)
		clear_table_crawl_visual()
		update_table_crawl_visibility()
		clear_table_crawl_spell_actions()
		return

	if(table_crawl_state == TABLECRAWL_UNDER)
		if(!can_remain_table_crawl() || !get_table_crawl_table())
			end_table_crawl()
			return

		apply_table_crawl_visual()
		update_table_crawl_visibility()


//====================================================================

/mob/living/carbon/human/proc/clear_table_crawl_passtable()
	if(!table_crawl_passtable_owned) return
	table_crawl_passtable_owned = FALSE
	pass_flags &= ~PASSTABLE


// hook
//====================================================================

/mob/living/carbon/human/set_resting(rest, silent = TRUE)
	if(!rest && try_table_crawl_head_bonk()) rest = TRUE
	. = ..()
	if(resting && is_table_crawl_player())
		AddElement(/datum/element/table_crawl)
	refresh_table_crawl()


/mob/living/carbon/human/toggle_rest()
	if(resting && try_table_crawl_head_bonk()) return
	return ..()


/mob/living/carbon/human/stand_up()
	if(try_table_crawl_head_bonk()) return FALSE
	return ..()


// elements
//====================================================================

/datum/element/table_crawl
	element_flags = ELEMENT_DETACH

/datum/element/table_crawl/Attach(datum/target)
	if(!ishuman(target)) return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(target, COMSIG_MOVABLE_BUMP, PROC_REF(on_bump))

/datum/element/table_crawl/Detach(mob/living/carbon/human/source, ...)
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_BUMP))
	source.end_table_crawl()
	return ..()

/datum/element/table_crawl/proc/on_bump(mob/living/carbon/human/source, atom/A)
	if(source.is_table_crawling() || !source.can_start_table_crawl()) return NONE
	if(!istype(A, /obj/structure/table)) return NONE
	source.try_offer_table_crawl(A, get_turf(A))

/datum/element/table_crawl/proc/on_moved(mob/living/carbon/human/source)
	source.clear_table_crawl_passtable()
	source.refresh_table_crawl()
