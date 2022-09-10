/// Increases the heritic's blood cult level by a given amount and apllies the effects of the new level.
/datum/antagonist/heretic/proc/increase_blood_cult_level(amount)
	var/old_level = blood_cult_level
	blood_cult_level += amount
	if(blood_cult_level >= 1 && old_level < 1)
		gain_knowledge(/datum/heretic_knowledge/cult/stun_resist)

	if(blood_cult_level >= 2 && old_level < 2)
		gain_knowledge(/datum/heretic_knowledge/cult/grasp)

	if(blood_cult_level >= 3 && old_level < 3)
		gain_knowledge(/datum/heretic_knowledge/cult/cult_detection)

	if(blood_cult_level >= 4 && old_level < 4)
		gain_knowledge(/datum/heretic_knowledge/cult/item_use)

