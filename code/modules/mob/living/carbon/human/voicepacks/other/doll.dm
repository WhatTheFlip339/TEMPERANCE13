/datum/voicepack/male/doll/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("firescream")
			used = pick('sound/vo/doll/broke_2.ogg')
		if("painscream")
			used = pick('sound/vo/doll/broke_1.ogg','sound/vo/doll/broke_2.ogg','sound/vo/doll/broke_3.ogg')
		if("scream")
			used = pick('sound/vo/doll/broke_1.ogg','sound/vo/doll/broke_2.ogg','sound/vo/doll/broke_3.ogg')
		if("click")
			used = pick('sound/vo/doll/clicks_clings_1.ogg','sound/vo/doll/clicks_clings_2.ogg','sound/vo/doll/clicks_clings_3.ogg')
		if("clickspin")
			used = pick('sound/vo/doll/spin_1.ogg','sound/vo/doll/spin_2.ogg','sound/vo/doll/spin_3.ogg')

	if(!used) //we haven't found a racial specific sound so use generic
		used = ..(soundin)
	return used

/datum/voicepack/female/doll/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("firescream")
			used = pick('sound/vo/doll/broke_2.ogg')
		if("painscream")
			used = pick('sound/vo/doll/broke_1.ogg','sound/vo/doll/broke_2.ogg','sound/vo/doll/broke_3.ogg')
		if("scream")
			used = pick('sound/vo/doll/broke_1.ogg','sound/vo/doll/broke_2.ogg','sound/vo/doll/broke_3.ogg')
		if("click")
			used = pick('sound/vo/doll/clicks_clings_1.ogg','sound/vo/doll/clicks_clings_2.ogg','sound/vo/doll/clicks_clings_3.ogg')
		if("clickspin")
			used = pick('sound/vo/doll/spin_1.ogg','sound/vo/doll/spin_2.ogg','sound/vo/doll/spin_3.ogg')

	if(!used) //we haven't found a racial specific sound so use generic
		used = ..(soundin)
	return used
