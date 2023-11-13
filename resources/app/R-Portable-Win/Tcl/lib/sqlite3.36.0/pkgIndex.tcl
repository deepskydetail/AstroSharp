#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
if {[package vsatisfies [package provide Tcl] 9.0-]} {
    package ifneeded sqlite3 3.36.0 \
	    [list load [file join $dir tcl9sqlite3360.dll] Sqlite3]
} else {
    package ifneeded sqlite3 3.36.0 \
	    [list load [file join $dir sqlite3360.dll] Sqlite3]
}
