/obj/item/device/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	flags = FPRINT | TABLEPASS| CONDUCT
	throwforce = 5
	w_class = 2.0
	throw_speed = 3
	throw_range = 10

	var/secured = 0
	var/obj/item/device/assembly/a_left = null
	var/obj/item/device/assembly/a_right = null
	var/obj/special_assembly = null

	proc/attach(var/obj/item/device/D, var/obj/item/device/D2, var/mob/user)
		return

	proc/attach_special(var/obj/O, var/mob/user)
		return

	proc/process_activation(var/obj/item/device/D)
		return



	IsAssemblyHolder()
		return 1


	attach(var/obj/item/device/D, var/obj/item/device/D2, var/mob/user)
		if((!D)||(!D2))	return 0
		if((!isassembly(D))||(!isassembly(D2)))	return 0
		if((D:secured)||(D2:secured))	return 0
		if(user)
			user.remove_from_mob(D)
			user.remove_from_mob(D2)
		D:holder = src
		D2:holder = src
		D.loc = src
		D2.loc = src
		a_left = D
		a_right = D2
		name = "[D.name]-[D2.name] assembly"
		update_icon()
		return 1


	attach_special(var/obj/O, var/mob/user)
		if(!O)	return
		if(!O.IsSpecialAssembly())	return 0

/*		if(O:Attach_Holder())
			special_assembly = O
			update_icon()
			src.name = "[a_left.name] [a_right.name] [special_assembly.name] assembly"
*/
		return


	update_icon()
		overlays = null
		if(a_left)
			overlays += "[a_left.icon_state]_left"
			for(var/O in a_left.attached_overlays)
				overlays += "[O]_l"
		if(a_right)
			src.overlays += "[a_right.icon_state]_right"
			for(var/O in a_right.attached_overlays)
				overlays += "[O]_r"
		if(master)
			master.update_icon()

/*		if(special_assembly)
			special_assembly.update_icon()
			if(special_assembly:small_icon_state)
				src.overlays += special_assembly:small_icon_state
				for(var/O in special_assembly:small_icon_state_overlays)
					src.overlays += O
*/

	examine()
		set src in view()
		..()
		if ((in_range(src, usr) || src.loc == usr))
			if (src.secured)
				usr << "\The [src] is ready!"
			else
				usr << "\The [src] can be attached!"
		return


	HasProximity(atom/movable/AM as mob|obj)
		if(a_left)
			a_left.HasProximity(AM)
		if(a_right)
			a_right.HasProximity(AM)
		if(special_assembly)
			special_assembly.HasProximity(AM)


	HasEntered(atom/movable/AM as mob|obj)
		if(a_left)
			a_left.HasEntered(AM)
		if(a_right)
			a_right.HasEntered(AM)
		if(special_assembly)
			special_assembly.HasEntered(AM)


	on_found(mob/finder as mob)
		if(a_left)
			a_left.on_found(finder)
		if(a_right)
			a_right.on_found(finder)
		if(special_assembly)
			if(istype(special_assembly, /obj/item))
				var/obj/item/S = special_assembly
				S.on_found(finder)


	Move()
		..()
		if(a_left && a_right)
			a_left.holder_movement()
			a_right.holder_movement()
//		if(special_assembly)
//			special_assembly:holder_movement()
		return


	attack_hand()//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
		if(a_left && a_right)
			a_left.holder_movement()
			a_right.holder_movement()
//		if(special_assembly)
//			special_assembly:Holder_Movement()
		..()
		return


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(isscrewdriver(W))
			if(!a_left || !a_right)
				user << "\red BUG:Assembly part missing, please report this!"
				return
			a_left.toggle_secure()
			a_right.toggle_secure()
			secured = !secured
			if(secured)
				user << "\blue \The [src] is ready!"
			else
				user << "\blue \The [src] can now be taken apart!"
			update_icon()
			return
		else if(W.IsSpecialAssembly())
			attach_special(W, user)
		else
			..()
		return


	attack_self(mob/user as mob)
		src.add_fingerprint(user)
		if(src.secured)
			if(!a_left || !a_right)
				user << "\red Assembly part missing!"
				return
			if(istype(a_left,a_right.type))//If they are the same type it causes issues due to window code
				switch(alert("Which side would you like to use?",,"Left","Right"))
					if("Left")	a_left.attack_self(user)
					if("Right")	a_right.attack_self(user)
				return
			else
				a_left.attack_self(user)
				a_right.attack_self(user)
		else
			var/turf/T = get_turf(src)
			if(!T)	return 0
			if(a_left)
				a_left:holder = null
				a_left.loc = T
			if(a_right)
				a_right:holder = null
				a_right.loc = T
			spawn(0)
				del(src)
		return


	process_activation(var/obj/D, var/normal = 1, var/special = 1)
		if(!D)	return 0
		if((normal) && (a_right) && (a_left))
			if(a_right != D)
				a_right.pulsed(0)
			if(a_left != D)
				a_left.pulsed(0)
		if(master)
			master.receive_signal()
//		if(special && special_assembly)
//			if(!special_assembly == D)
//				special_assembly.dothings()
		return 1










