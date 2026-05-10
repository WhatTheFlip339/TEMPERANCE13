/*
This is where the magic happens, baby.

These are meant to be used when you walk onto a thingy that flashes you with one of these.
Naturally it also contains the part that contains the loreblurbs you've actually seen already in your human mob.
Just because it'd get a LITTLE annoying if you kept seeing this over and over. Haha.
*/


//This stores blurbs you've seen - this is really useful isn't it?
/mob/living/carbon/human
	var/list/seen_loreblurbs = list()



/datum/loreblurb
	//Obviously the title - it shows up first and it's real big
	var/title = "AN AGONIZING GLEAM"

	//This is the actual lore fluff bit
	var/description = "You thought that death would be the end of your suffering. \n Suffice to say, you were wrong."

	//You might want to give these blurbs a special sound when you see them. That is what this is for.
	var/sound = 'sound/loredump/lore_sting1.ogg'

/datum/loreblurb/proc/onEncounter(mob/living/carbon/human/H)
	if(!H)
		return
	
	if(!H.seen_loreblurbs)
		H.seen_loreblurbs = list()
	

	if(!(src.type in H.seen_loreblurbs))
	//We're good, run the rest of the proc!
		H.seen_loreblurbs += src.type
		if(sound)
			H.playsound_local(H, sound, 100, vary = FALSE)
		toMob(H)


/datum/loreblurb/proc/toMob(mob/living/carbon/human/H)
	if(!H)
		return

	if(src.title == null || src.description == null)
		return
	
	var/lorestring = "<div class=loreblurb>\
	<div class=loreblurb-title>" + title + "</div>\
	<div class=loreblurb-desc>" + description + "</div>\
	</div>"

	to_chat(H, lorestring)


/datum/loreblurb/ruined_city
	title = "Urban Ruins"
	description = "All around you are the crumbled remains of a place once inhabited by people. \n\
	A child's skull lingers half-buried in soil stain'd more than thrice with blood.\n\
	Flies buzz around you, as if mocking your presence here.\n\
	It seems not even the vultures dare come here any longer. It makes your organs want to shrivel inwards and die."

/datum/loreblurb/butchersblock
	title = "The Butcher's Block"
	description = "You wade through gore that reeks of rot. Decay assaults your nose. A wave of nausea washes over you.\n\
	There is no doubt in you that disease will follow you not long after this. Even the open air above you offers no relief from the bloated, rotting carcasses that surround you.\n\
	Dead masses float around in the fetid blood in various states of decay. Even the skull of a hound or some other small mammal occasionally surfaces to greet your sight."

/datum/loreblurb/outpostjulius
	title = "Outpost Julius"
	description = "Cold and oppressive. This outpost was built ontop of conquered land. \n\
	Without a gas mask, the faint smell of copper coats the concrete walls mixed with the soft crackling of blue candles. \n\
	The Perserdunians etched out this outpost a few months ago, after an intense offensive campaign shattered both the land and the bandits that once ruled this region. \n\
	Soldiers stationed here are apart of Outfit Delta, 32nd Cohort of Arms."
	sound = 'sound/loredump/lore_sting2.ogg'

/datum/loreblurb/artillerysector
	title = "AS-Y14"
	description = "Artillery Sector Yield-14. \n\
	Considered to be the backline of Perserdun's presence within the area. \n\
	A typical round-trip takes about 30 minutes on foot through the trenches behind the Outpost.\n\
	AS-Y14 houses the second half of Outfit Delta, and transfers between Julius and Y14 regularly happen."
	sound = 'sound/loredump/lore_sting2.ogg'

/datum/loreblurb/rostrumlemuria
	title = "ROSTRUM LEMURIA"
	description = "The dents of bullet-holes in the walls make themselves prevalent, as you pass by the entrance to the Rostrum. \n\
	It smells like concrete, zigarettes, gunpowder, and blood. There's a decorated pond in the middle of the outstation. \n\
	The Dictate settled in their staging ground a few years ago after negotiating a now-expired trade deal with King's Row. \n\
	Recently, there's been spottings of a second brigade of cadres-and-accompanying-officers setting up camp a few miles past the mountain range the Rostrum's embedded in."

/datum/loreblurb/bastillexiphos
	title = "BASTILLE XIPHOS"
	description = "A bastille is a temporary encampment belonging to a Risvonian brigade. \n\
	Officially, both the Rostrum and Bastille belong the Fourth Forward Battalion. \n\
	Though, the Chapter's been divided into two brigades that transfer personnel to-and-from the Bastille about every week or so. \n\
	The actual bastille's made out of tents and metal walls similar to a siege camp. Travel time is about an hour for a round-trip on foot."

/datum/loreblurb/funnyoutlet
	title = "???"
	description = "There's chills up your spine. \n\
	This doesn't seem safe."
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/code1
	title = "FROM A RADIO"
	description = "34 15 43 313 26 16 312 61 34 15 43 312 53 26"
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/apartments
	title = "The Apartments"
	description = "You're not alone. \n\
	Whirring, beeping sounds echo throughout the walls."
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/code2
	title = "SOMETHING WHISPERS"
	description = "41 231 41 26 312 51 15 52 312 34"
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/hospital 
	title = "The Hospital"
	description = "The stench of antiseptic and decay fills your nostrils. \n\
	It's rather quiet."
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/code3
	title = "WHISPERED IN YOUR EAR"
	description = "132 53 34 231 16 312 41 213"
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/factory
	title = "The Factory"
	description = "Occasional, startling bangs ring throughout the metal tomb. It's oppressive - you feel like you could die at any moment, here.\n\
	You feel on edge. Hopefully you're not alone. It's caked in rust, dirt, and grime - filth covers both the boots and the gloves. \n\
	There's a faint smell of oil, gunpowder, and iron in the air."
	sound = 'sound/loredump/lore_sting6.ogg'

/datum/loreblurb/umamusume
	title = "41 26 16 51 41 KINEN"
	description = "2,500 meters. \n\
	Right-handed. \n\
	52 41 212 41 61 41 51 41 Racecourse. \n\
	Though, it looks like this is a left-handed track. Weird."
	sound = 'sound/loredump/lore_sting6.ogg'
