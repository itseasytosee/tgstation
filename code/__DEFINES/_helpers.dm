// Stuff that is relatively "core" and is used in other defines/helpers

//Returns the hex value of a decimal number
//len == length of returned string
#define num2hex(X, len) num2text(X, len, 16)

//Returns an integer given a hex input, supports negative values "-ff"
//skips preceding invalid characters
#define hex2num(X) text2num(X, 16)

/// Stringifies whatever you put into it.
#define STRINGIFY(argument) #argument

/// subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

/// Until a condition is true, sleep
#define UNTIL(X) while(!(X)) stoplag()

/// Sleep if we haven't been deleted
/// Otherwise, return
#define SLEEP_NOT_DEL(time) \
	if(QDELETED(src)) { \
		return; \
	} \
	sleep(time);

#ifdef EXPERIMENT_515_DONT_CACHE_REF
/// Takes a datum as input, returns its ref string
#define text_ref(datum) ref(datum)
#else
/// Takes a datum as input, returns its ref string, or a cached version of it
/// This allows us to cache \ref creation, which ensures it'll only ever happen once per datum, saving string tree time
/// It is slightly less optimal then a []'d datum, but the cost is massively outweighed by the potential savings
/// It will only work for datums mind, for datum reasons
/// : because of the embedded typecheck
#define text_ref(datum) (isdatum(datum) ? (datum:cached_ref ||= "\ref[datum]") : ("\ref[datum]"))
#endif

//Converts an angle (degrees) into a ss13 direction
GLOBAL_LIST_INIT(modulo_angle_to_dir, list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST))
#define angle2dir(X) (GLOB.modulo_angle_to_dir[round(((((X)%360)+382.5)%360)/45)+1])
// melbert todo : check this
