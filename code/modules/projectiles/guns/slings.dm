/obj/item/sling
	name = "sling"
	desc = "Double-pendulum kinetics are, and always were, better than balisitc propulsion. Anyone who thinks otherwise can suck on some stones."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "debug"
	w_class = WEIGHT_CLASS_SMALL
	var/swinging = FALSE
	var/obj/item/ammo_casing/sling_stone/loaded_stone

/obj/item/sling/afterattack(atom/target, mob/living/user, flag, params)
	if(loaded_stone)
		loaded_stone.fire_casing(target, user, fired_from = src)
		loaded_stone = null
		playsound(src, 'sound/weapons/bulletflyby.ogg', 100, TRUE)
		user.visible_message(span_danger("[user] launches the [loaded_stone] at [target]!"), \
						span_danger("You launch the [loaded_stone] at [target]!"))

/obj/item/sling/attack_self(atom/target, mob/living/user, flag, params)

/obj/item/sling/attackby(obj/item/attacking_item, mob/user)
	. = ..()
	if(istype(attacking_item, /obj/item/ammo_casing/sling_stone))
		var/obj/item/ammo_casing/sling_stone/stone = attacking_item
		user.transferItemToLoc(stone, src)
		loaded_stone = stone
		to_chat(user, span_notice("You load the stone into the sling."))

/obj/item/storage/belt/sling_pouch
	name = "Sling Pouch"
	desc = "A pouch made to hold many small stones, like one might fire out of a sling. Obviously."

/obj/item/storage/belt/bandolier/Initialize(mapload)
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
