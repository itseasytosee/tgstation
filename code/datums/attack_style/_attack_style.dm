GLOBAL_LIST_INIT(attack_styles, init_attack_styles())

/proc/init_attack_styles()
	var/list/styles = list()
	for(var/style_type in typesof(/datum/attack_style))
		styles[style_type] = new style_type()

	return styles

/datum/movespeed_modifier/attack_style_executed
	variable = TRUE

/**
 * # Attack style singleton
 *
 * Handles sticking behavior onto a weapon to make it attack a certain way
 */
/datum/attack_style
	var/successful_hit_sound = 'sound/weapons/punch1.ogg'
	var/miss_sound = 'sound/weapons/fwoosh.ogg'
	var/cd = CLICK_CD_MELEE
	var/slowdown = 1
	var/reverse_for_lefthand = TRUE
	/// If TRUE, pacifists are completely disallowed from using this attack style
	/// If FALSE, pacifism is still checked, but it checks weapon force instead - any weapon with force > 0 will be disallowed
	var/pacifism_completely_banned = FALSE

/**
 * Process attack -> execute attack -> finalize attack
 *
 * Arguments
 * * attacker - the mob doing the attack
 * * weapon - optional, the item being attacked with.
 * * aimed_towards - what atom the attack is being aimed at, does not necessarily correspond to the atom being attacked,
 * but is also checked as a priority target if multiple mobs are on the same turf.
 * * right_clicking - whether the attack was done via r-click
 *
 * Implementation notes
 * * Do not override process attack
 * * You may extend execute attack with additonal checks, but call parent
 * * You can freely override finalize attack with whatever behavior you want
 *
 * Usage notes
 * * Does NOT check for nextmove, that should be checked before entering this
 * * DOES check for pacifism
 *
 * Return TRUE on success, and FALSE on failure
 */
/datum/attack_style/proc/process_attack(mob/living/attacker, obj/item/weapon, atom/aimed_towards, right_clicking = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(HAS_TRAIT(attacker, TRAIT_PACIFISM) && (pacifism_completely_banned || weapon?.force > 0))
		return FALSE

	var/attack_direction = get_dir(attacker, get_turf(aimed_towards))
	var/list/affecting = select_targeted_turfs(attacker, attack_direction, right_clicking)
	if(reverse_for_lefthand)
		// Determine which hand the attacker is attacking from
		// If they are not holding the weapon passed / the weapon is null, default to active hand
		var/which_hand = (!isnull(weapon) && attacker.get_held_index_of_item(weapon)) || attacker.active_hand_index

		// Left hand will reverse the turfs list order
		if(which_hand % 2 == 1)
			reverse_range(affecting)

	// Prioritise the atom we clicked on initially, so if two mobs are on one turf, we hit the one we clicked on
	if(!execute_attack(attacker, weapon, affecting, aimed_towards, right_clicking))
		// Just apply a small second CD so they don't spam failed attacks
		attacker.changeNext_move(0.33 SECONDS)
		return FALSE

	if(slowdown > 0)
		attacker.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/attack_style_executed, multiplicative_slowdown = slowdown)
		addtimer(CALLBACK(attacker, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/attack_style_executed), cd * 0.2)
	if(cd > 0)
		attacker.changeNext_move(cd)
	return TRUE

/datum/attack_style/proc/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	SHOULD_CALL_PARENT(TRUE)

	attack_effect_animation(attacker, weapon, affecting)

	var/attack_flag = NONE
	for(var/turf/hitting as anything in affecting)

#ifdef TESTING
		apply_testing_color(hitting, affecting.Find(hitting))
#endif

		var/mob/living/smack_who
		if(isliving(priority_target) && (priority_target in hitting))
			smack_who = priority_target
		else
			smack_who = locate() in hitting
		if(!isliving(smack_who))
			continue

		attack_flag |= finalize_attack(attacker, smack_who, weapon, right_clicking)
		if(attack_flag & ATTACK_STYLE_CANCEL)
			return ATTACK_STYLE_CANCEL
		if(attack_flag & ATTACK_STYLE_BLOCKED)
			break

	if(attack_flag & ATTACK_STYLE_HIT)
		if(successful_hit_sound)
			playsound(attacker, successful_hit_sound, 50, TRUE)

	else
		if(miss_sound)
			playsound(attacker, miss_sound, 50, TRUE)

	return attack_flag

#ifdef TESTING
/datum/attack_style/proc/apply_testing_color(turf/hit, index = -1)
	hit.add_atom_colour(COLOR_RED, TEMPORARY_COLOUR_PRIORITY)
	hit.maptext = MAPTEXT("[index]")
	animate(hit, 1 SECONDS, color = null)
	addtimer(CALLBACK(src, PROC_REF(clear_testing_color), hit), 1 SECONDS)

/datum/attack_style/proc/clear_testing_color(turf/hit)
	hit.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_RED)
	hit.maptext = null
#endif

/datum/attack_style/proc/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	RETURN_TYPE(/list)
	return list(get_step(attacker, attack_direction))

/datum/attack_style/proc/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	if(isnull(weapon))
		return

	var/num_turfs_to_move = length(affecting)
	var/time_per_turf = 0.4 SECONDS
	var/final_animation_length = time_per_turf * num_turfs_to_move
	var/initial_angle = get_angle(attacker, affecting[1])
	var/final_angle = get_angle(attacker, affecting[num_turfs_to_move])

	var/image/attack_image = image(icon = weapon, loc = attacker, layer = attacker.layer + 0.1)
	var/matrix/base_transform = matrix(attack_image.transform)
	attack_image.alpha = 180
	attack_image.color = "#c4c4c4"
	attack_image.transform.Turn(initial_angle)
	var/matrix/final_transform = base_transform.Turn(final_angle)

	message_admins("[final_animation_length]")
	flick_overlay_global(attack_image, GLOB.clients, final_animation_length + time_per_turf)
	animate(attack_image, time = final_animation_length, alpha = 120, transform = final_transform)
	// animate(attack_image, time = time_per_turf, alpha = 0, easing = CIRCULAR_EASING|EASE_OUT)

/datum/attack_style/proc/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	return weapon.melee_attack_chain(smacked, attacker)
	// Convert to bitflags, ATTACK_STYLE_HIT / ATTACK_STYLE_BLOCKED
	// Attack chain current
	// Click -> item Melee attack chain -> item tool act -> item pre attack -> mob attackby -> item attack -> mob attacked by -> item attack qdeleted -> item after attack

/**
 * Unarmed attack styles work slightly differently
 *
 * For normal attack styles, the style should not be handling the damage whatsoever, it should be handled by the weapon.
 *
 * But since we have no weapon for these, we kinda hvae to do it ourselves.
 */
/datum/attack_style/unarmed
	reverse_for_lefthand = FALSE
	successful_hit_sound = 'sound/weapons/punch1.ogg'
	miss_sound = 'sound/weapons/punchmiss.ogg'

	var/attack_effect = ATTACK_EFFECT_PUNCH
/*
/datum/attack_style/unarmed/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!isnull(weapon))
		// Not intended for use here
		return

	return ..()
*/
/datum/attack_style/unarmed/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	CRASH("No narmed interaction for [type]!")

/datum/attack_style/unarmed/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	if(attack_effect)
		attacker.do_attack_animation(affecting[1], attack_effect)

// swings at 3 targets in a direction
/datum/attack_style/swing
	cd = CLICK_CD_MELEE * 3 // Three times the turfs, 3 times the cooldown

/datum/attack_style/swing/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	return get_turfs_and_adjacent_in_direction(attacker, attack_direction)

/datum/attack_style/swing/requires_wield

/datum/attack_style/swing/requires_wield/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return FALSE
	return ..()

/datum/attack_style/swing/esword
	cd = CLICK_CD_MELEE * 1.25 // Much faster than normal swings
	reverse_for_lefthand = FALSE

/datum/attack_style/swing/esword/execute_attack(mob/living/attacker, obj/item/melee/energy/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!weapon.blade_active)
		attacker.balloon_alert(attacker, "activate your weapon!")
		return FALSE

	// Right clicking attacks the opposite direction
	if(right_clicking)
		reverse_range(affecting)

	return ..()

/datum/attack_style/swing/requires_wield/desword
	cd = CLICK_CD_MELEE * 1.25
	reverse_for_lefthand = FALSE

/datum/attack_style/swing/requires_wield/desword/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	var/behind_us = REVERSE_DIR(attack_direction)
	var/list/cone_turfs = list()
	for(var/around_dir in list(NORTH, SOUTH, EAST, WEST, NORTHWEST, NORTHEAST, SOUTHWEST, SOUTHEAST))
		if(around_dir & behind_us)
			continue
		var/turf/found_turf = get_step(attacker, around_dir)
		if(istype(found_turf))
			cone_turfs += found_turf

	return cone_turfs

// Direct stabs out to turfs in front
/datum/attack_style/stab_out
	reverse_for_lefthand = FALSE
	var/stab_range = 1

/datum/attack_style/stab_out/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	var/max_range = stab_range
	var/turf/last_turf = get_turf(attacker)
	var/list/select_turfs = list()
	while(max_range > 0)
		var/turf/next_turf = get_step(last_turf, attack_direction)
		if(!isturf(next_turf) || next_turf.is_blocked_turf(exclude_mobs = TRUE, source_atom = attacker))
			return select_turfs
		select_turfs += next_turf
		last_turf = next_turf
		max_range--

	return select_turfs

/datum/attack_style/stab_out/spear
	cd = CLICK_CD_MELEE * 2
	stab_range = 2

/datum/attack_style/stab_out/spear/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(!HAS_TRAIT(weapon, TRAIT_WIELDED))
		attacker.balloon_alert(attacker, "wield your weapon!")
		return FALSE
	return ..()

// Overhead swings, bypass blocks / targets heads
/datum/attack_style/overhead
