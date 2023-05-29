/// Tests that headrevs can convert people by clicking on them with flashes
/datum/unit_test/revolution_conversion

/datum/unit_test/revolution_conversion/Run()
	var/mob/living/carbon/human/leader = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/peasant = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)

	leader.mind_initialize()
	leader.mock_client = new()
	peasant.mind_initialize()
	peasant.mock_client = new()

	var/datum/antagonist/rev/head/lead_datum = leader.mind.add_antag_datum(/datum/antagonist/rev/head)
	var/datum/team/revolution/revolution = lead_datum.get_team()

	var/obj/item/assembly/flash/handheld/converter = allocate(/obj/item/assembly/flash/handheld)
	converter.burnout_resistance = INFINITY
	converter.cooldown = 0 SECONDS
	leader.put_in_active_hand(converter, forced = TRUE)

	// Fail state
	converter.attack_self(leader)
	TEST_ASSERT(!IS_REVOLUTIONARY(peasant), "Peasant gained revolution antag datum from being AOE flashed, which is not intended.")

	// Fail state again
	var/obj/item/clothing/glasses = allocate(/obj/item/clothing/glasses/sunglasses)
	peasant.equip_to_appropriate_slot(glasses)
	click_wrapper(leader, peasant)
	TEST_ASSERT(!IS_REVOLUTIONARY(peasant), "Peasant gained revolution antag datum despite being flashproof.")
	qdel(glasses)

	// Success state
	click_wrapper(leader, peasant)

	TEST_ASSERT(peasant.IsParalyzed(), "Peasant was not paralyzed after being flashed by the leader.") // Flash paralyze
	TEST_ASSERT(peasant.IsStun(), "Peasant was not stunned after being converted by the leader.") // Conversion stun
	TEST_ASSERT(IS_REVOLUTIONARY(peasant), "Peasant did not gain revolution antag datum on conversion.")
	TEST_ASSERT_EQUAL(length(revolution.members), 2, "Expected revolution to have 2 members after the leader flashes the peasant.")

/// Tests that cults can convert people with their rune
/datum/unit_test/cult_conversion

/datum/unit_test/cult_conversion/Run()
	var/mob/living/carbon/human/cult_a = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/cult_b = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/new_cultist = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)

	cult_a.mind_initialize()
	cult_a.mock_client = new()
	cult_b.mind_initialize()
	cult_b.mock_client = new()
	new_cultist.mind_initialize()
	new_cultist.mock_client = new()

	var/datum/antagonist/cult/a_cult_datum = cult_a.mind.add_antag_datum(/datum/antagonist/cult)
	var/datum/team/cult/cult_team = a_cult_datum.get_team()

	var/obj/effect/rune/convert/convert_rune = allocate(/obj/effect/rune/convert, run_loc_floor_bottom_left)

	// Fail case
	click_wrapper(cult_a, convert_rune)
	TEST_ASSERT(!IS_CULTIST(new_cultist), "New cultist became a cultist with only 1 person converting them.")
	TEST_ASSERT_EQUAL(length(cult_team.members), 1, "Expected cult to have 1 member after the cultist failed to convert anyone.")

	// Success case
	cult_b.mind.add_antag_datum(/datum/antagonist/cult)
	click_wrapper(cult_a, convert_rune)
	TEST_ASSERT(IS_CULTIST(new_cultist), "New cultist did not become a cultist after being converted by two people.")
	TEST_ASSERT_EQUAL(length(cult_team.members), 3, "Expected cult to have 3 members after the cultists convert the new cultist.")
