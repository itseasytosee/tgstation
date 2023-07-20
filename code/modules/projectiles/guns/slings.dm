/obj/item/sling
	name = "sling"
	desc = "Historically, skilled slingers could put as much force behind a projectile as a modern .45 magnum, unfortunatly spacemen just don't have the technique down."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "debug"
	w_class = WEIGHT_CLASS_SMALL
	var/swinging = FALSE
	var/obj/item/ammo_casing/sling_stone/loaded_stone

/obj/item/sling/afterattack(atom/target, mob/living/user, flag, params)
	if(loaded_stone && swinging)
		playsound(src, 'sound/weapons/bulletflyby.ogg', 100, TRUE)
		user.visible_message(span_danger("[user] launches the [loaded_stone] at [target]!"), \
						span_danger("You launch the [loaded_stone] at [target]!"))
		loaded_stone.fire_casing(target, user, fired_from = src)
		loaded_stone = null
		stop_swinging()

/obj/item/sling/attack_self(mob/living/user, modifiers)
	. = ..()
	start_swinging(user)

/obj/item/sling/proc/start_swinging(mob/living/slinger)
	if(!loaded_stone)
		slinger.balloon_alert(slinger, "can't swing without ammo!")
	if(swinging)
		slinger.balloon_alert(slinger, "Already swinging!")
	else
		slinger.balloon_alert(slinger, "starting swing...")
		if(do_after(slinger, 2 SECONDS, src, list(IGNORE_USER_LOC_CHANGE, IGNORE_TARGET_LOC_CHANGE)))
			slinger.apply_damage(10, STAMINA)
			START_PROCESSING(SSobj, src)
			slinger.balloon_alert(slinger, "swinging active")
			swinging = TRUE
			RegisterSignals(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(stop_swinging))

/obj/item/sling/proc/stop_swinging(mob/living/slinger)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSobj, src)
	swinging = FALSE
	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/sling/process(seconds_per_tick)
	playsound(src, 'sound/weapons/bulletflyby2.ogg', 25, FALSE)
	if(isliving(loc))
		var/mob/living/slinger = loc
		slinger.apply_damage(5 * seconds_per_tick, STAMINA)
	else
		stop_swinging()

/obj/item/sling/attackby(obj/item/attacking_item, mob/user)
	. = ..()
	if(loaded_stone)
		to_chat(user, span_notice("There is already a stone loaded."))
		return
	if(istype(attacking_item, /obj/item/ammo_casing/sling_stone))
		var/obj/item/ammo_casing/sling_stone/stone = attacking_item
		user.transferItemToLoc(stone, src)
		loaded_stone = stone
		to_chat(user, span_notice("You load the stone into the sling."))

/obj/item/storage/belt/sling_pouch
	name = "Sling Pouch"
	desc = "A pouch made to hold many small stones, like one might fire out of a sling. Obviously."

/obj/item/storage/belt/sling_pouch/PopulateContents()
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)
	new /obj/item/ammo_casing/sling_stone(src)

/obj/item/storage/belt/sling_pouch/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 18
	atom_storage.max_total_storage = 18
	atom_storage.numerical_stacking = TRUE
	atom_storage.set_holdable(/obj/item/ammo_casing/sling_stone)

/obj/item/ammo_casing/sling_stone
	name = "stone"
	desc = "A small stone, don't put it in your mouth."
	projectile_type =/obj/projectile/sling_stone
	is_cased_ammo = FALSE

/obj/projectile/sling_stone
	name = "stone"
	damage = 20 // Historically, skilled slingers could put as much force behind a projectile as a modern .45 magnum, unfortunatly spacemen just don't have the technique down
	damage_type = BRUTE
	armor_flag = BULLET

/datum/outfit/slinger
	name = "slinger"

	uniform = /obj/item/clothing/under/color/red
	l_hand = /obj/item/sling
	belt = /obj/item/storage/belt/sling_pouch
