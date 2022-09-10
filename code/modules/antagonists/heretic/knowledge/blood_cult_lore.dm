/datum/heretic_knowledge/cult
	gain_span = "cult"
	route = PATH_CULT

/datum/heretic_knowledge/cult/stun_resist
	name = "Trials of the Geometer's force"
	gain_text = "The Nar'sian cultists are vessels of immense eldritch force, but they lack true finesse of spell weaving. They are wild and reckless with forces beyond their comprehension. This recklessness can be exploited."
	desc = "You will now counter the stunning aura spell with a burst of magic that viloently repels your attacker. The mixings of magic will scorch both you and your attacker"

/datum/heretic_knowledge/cult/stun_resist/on_gain(mob/user)
	ADD_TRAIT(user, TRAIT_HERETIC_CULT_DEFENSE, "cult_knowledge")

/datum/heretic_knowledge/cult/stun_resist/on_lose(mob/user)
	REMOVE_TRAIT(user, TRAIT_HERETIC_CULT_DEFENSE, "cult_knowledge")

/datum/heretic_knowledge/cult/grasp
	name = "Anecdote of the Cultist's weakness"
	gain_text = "The presence of the Elder Godess stains her cultist's bodies. A volitile and unholy liquid fills their soul. This liquid may react to specific magic as plasma might to a flame."
	desc = "Your Mansus Grasp is now be more effective against cultists. It will do increased burn damage and knock them back a distance. Both of these effects will increase as your knowledge grows"

/datum/heretic_knowledge/cult/grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/cult/grasp/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/cult/grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!IS_CULTIST(target))
		return

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(source)
	var/throw_distance = heretic_datum.blood_cult_level

	target.mob_light(_range = 3, _color = LIGHT_COLOR_BLOOD_MAGIC, _duration = 0.2 SECONDS)
	source.mob_light(_range = 3, _color = LIGHT_COLOR_PURPLE, _duration = 0.3 SECONDS)

	playsound(get_turf(target), 'sound/magic/repulse.ogg', 100)
	to_chat(target, span_cult("Intense eldritch energies  from [source] colilde with your own, blasting you back!"))

	target.Paralyze(20)
	target.apply_damage(min(heretic_datum.blood_cult_level * 5, 25), BURN, wound_bonus = CANT_WOUND) // Unfortunately, I think it would be a bit unfair to have this scale indefinitely

	var/turf/thrownat = get_ranged_target_turf_direct(source, target, throw_distance)
	target.throw_at(thrownat, throw_distance, 3, null, TRUE, force = MOVE_FORCE_OVERPOWERING)

/datum/heretic_knowledge/cult/cult_detection
	name = "An Understood Profile"
	gain_text = "The cultists walk with a particular staggering strut invisible to the untrained eye, but the true giveaway is the glint in their eye that transcends sight."
	desc = "You can identify cultists on sight."

/datum/heretic_knowledge/cult/grasp/on_gain(mob/user)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	heretic_datum.add_team_hud(user, /datum/antagonist/cult)

/datum/heretic_knowledge/cult/item_use
	name = "Mimicry of faith"
	gain_text = "The unholy objects handled by Nar'Sian cultists twist and turn on their user if they find their wielder is unfaithful. Lucky for you, faith is an easy thing to fake."
	desc = "You can now use stolen cult weapons and structures as if you were a cultist."

/datum/heretic_knowledge/cult/grasp/on_gain(mob/user)
	ADD_TRAIT(user, TRAIT_FAKE_CULT, "cult_knowledge")

/datum/heretic_knowledge/cult/stun_resist/on_lose(mob/user)
	REMOVE_TRAIT(user, TRAIT_FAKE_CULT, "cult_knowledge")
