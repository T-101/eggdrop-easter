##
##	eggdrop-easter by T-101 / Darklite ^ Primitive
##
##	Tells the date of easter
##
##	Usage: !easter [year]		
##
##	On it's own it will output the date of next easter.
##	Accepts optional year as a parameter.
##
##      Only configuration is to set the channel flag where you want this to work.
##      In partyline: .chanset #yourchannel +eggdropeaster
##
##	2017 | darklite.org | primitive.be | IRCNet
##
##
##	Version history:
##		1.0.0	-	Initial release
##              1.0.1   -       Fixed issue with invalid parameter values

::namespace eval ::eggdrop-easter {

    set currentVersion "1.0.1"

    setudef flag eggdropeaster

    bind pub - !easter ::eggdrop-easter::announce

    proc calcEaster { y } {
	set paschal [expr (3 - (11 * (($y % 19) + 1)) + ($y - 1600) / 100 - ($y - 1600) / 400 - ((($y - 1400) / 100) * 8) / 25) % 30]
	if {$paschal == 29 || ($paschal == 28 && [expr (($y % 19) + 1)] > 11)} {
		set p [expr $paschal - 1] } else { set p $paschal
        }
	set e [expr $p + ((((8 - ($y + ($y / 4) - ($y / 100) + ($y / 400)) % 7) % 7 - (80 + $p) % 7) - 1) % 7 + 1)]
	if {$e < 11} {
		return [clock scan 03/[expr $e + 21]/$y]
	} else {
		return [clock scan 04/[expr $e - 10]/$y]
	}
    }

    proc announce { nick mask hand channel arguments } {
        # Check if channel has flag set and user is on channel
        if {![channel get $channel eggdropeaster] || ![onchan $nick $channel]} { return }
    
        # Get year from system time or argument. Fallback is system time
        set easterRegEx [regexp -inline {^\d{1,5}} $arguments]
        if {[llength $arguments] && $easterRegEx != ""} {
            set year $easterRegEx
        } else {
            set year [clock format [clock seconds] -format "%Y"]
        }

        # Calculate easter. If already passed, calculate next easter
        set easter [calcEaster $year]
        if {$easterRegEx == "" && $easter < [clock seconds]} {
            set easter [calcEaster [expr $year + 1]]
        }

        # Human readable
        set easter [clock format $easter -format "%A %b %d, %Y"]
        putquick "PRIVMSG $channel :$easter"
    
    }
    putlog "eggdrop-easter.tcl $currentVersion by T-101 loaded!"
}