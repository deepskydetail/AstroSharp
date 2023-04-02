namespace eval SelectColor {
    Widget::define SelectColor color Dialog

    Widget::declare SelectColor {
        {-title      String     "Select a color" 0}
        {-parent     String     ""               0}
        {-command    String     ""               0}
        {-help       Boolean    0                1}
        {-color      TkResource ""               0 {label -background}}
	{-type       Enum       "dialog"         1 {dialog popup}}
	{-placement  String     "center"         1}
        {-background TkResource ""               0 {label -background}}
    }

    variable _baseColors {
        \#0000ff \#00ff00 \#00ffff \#ff0000 \#ff00ff \#ffff00
        \#000099 \#009900 \#009999 \#990000 \#990099 \#999900
        \#000000 \#333333 \#666666 \#999999 \#cccccc \#ffffff
    }

    variable _userColors {
        \#ffffff \#ffffff \#ffffff \#ffffff \#ffffff \#ffffff
        \#ffffff \#ffffff \#ffffff \#ffffff \#ffffff
    }

    if {[string equal $::tcl_platform(platform) "unix"]} {
        set useTkDialogue 0
    } else {
        set useTkDialogue 1
    }

    variable _selectype
    variable _selection
    variable _wcolor
    variable _image
    variable _hsv

    variable _command
    variable _unsavedSelection
    variable _oldColor
    variable _entryColor
    variable _bgColor
    variable _fgColor
    variable _rounds
}

proc SelectColor::create { path args } {
    Widget::init SelectColor $path $args

    set type [Widget::cget $path -type]

    switch -- [Widget::cget $path -type] {
	"dialog" {
	    return [eval [list SelectColor::dialog $path] $args]
	}

	"popup" {
	    set list      [list at center left right above below]
	    set placement [Widget::cget $path -placement]
	    set where     [lindex $placement 0]

	    if {[lsearch $list $where] < 0} {
		return -code error \
		    [BWidget::badOptionString placement $placement $list]
	    }

	    ## If they specified a parent and didn't pass a second argument
	    ## in the placement, set the placement relative to the parent.
	    set parent [Widget::cget $path -parent]
	    if {[string length $parent]} {
		if {[llength $placement] == 1} { lappend placement $parent }
	    }
	    return [eval [list SelectColor::menu $path $placement] $args]
	}
    }
}

proc SelectColor::menu {path placement args} {
    variable _baseColors
    variable _userColors
    variable _wcolor
    variable _selectype
    variable _selection
    variable _command
    variable _bgColor
    variable _rounds

    Widget::init SelectColor $path $args
    set top [toplevel $path]
    set parent [winfo toplevel [winfo parent $top]]
    wm withdraw  $top
    wm transient $top $parent
    wm overrideredirect $top 1
    catch { wm attributes $top -topmost 1 }

    set _command  [Widget::cget $path -command]
    set _bgColor  [Widget::cget $path -background]
    set _rounds   {}

    set frame [frame $top.frame \
                   -highlightthickness 0 \
                   -relief raised -borderwidth 2]
    set col    0
    set row    0
    set count  0
    set colors [concat $_baseColors $_userColors]
    foreach color $colors {
        set f [frame $frame.c$count \
                   -highlightthickness 2 \
                   -highlightcolor white \
                   -relief solid -borderwidth 1 \
                   -width 16 -height 16 -background $color]
        bind $f <1>     "set SelectColor::_selection $count; break"
        bind $f <Enter> {focus %W}
        grid $f -column $col -row $row
        incr count
        if {[incr col] == 6 } {
            set  col 0
            incr row
        }
    }
    set f [label $frame.c$count \
               -highlightthickness 2 \
               -highlightcolor white \
               -relief flat -borderwidth 0 \
               -width 16 -height 16 -image [Bitmap::get palette]]
    grid $f -column $col -row $row
    bind $f <1>     "set SelectColor::_selection $count; break"
    bind $f <Enter> {focus %W}
    pack $frame

    bind $top <1>      {set SelectColor::_selection -1}
    bind $top <Escape> {set SelectColor::_selection -2}
    bind $top <FocusOut> [subst {if {"%W" == "$top"} \
				     {set SelectColor::_selection -2}}]

    # set background color for menu
    $f     configure -bg $_bgColor
    $frame configure -bg $_bgColor
    foreach w [winfo children $frame] {
        $w configure -highlightcolor $_bgColor -highlightbackground $_bgColor
    }

    eval [list BWidget::place $top 0 0] $placement

    wm deiconify $top
    raise $top
    if {$::tcl_platform(platform) == "unix"} {
	tkwait visibility $top
	update
    }
    BWidget::SetFocusGrab $top $frame.c0

    vwait SelectColor::_selection
    BWidget::RestoreFocusGrab $top $frame.c0 destroy
    Widget::destroy $top
    if {$_selection == $count} {
	array set opts {
	    -parent -parent
	    -title  -title
	    -color  -initialcolor
	}
	if {[Widget::theme]} {
	    set native 1
	    set nativecmd [list tk_chooseColor -parent $parent]
	    foreach {key val} $args {
		if {![info exists opts($key)]} {
		    set native 0
		    break
		}
		lappend nativecmd $opts($key) $val
	    }
	    if {$native} {
		# Call native dialog
		return [eval $nativecmd]
	    }
	}
	# Call BWidget dialog
	return [eval [list dialog $path] $args]
    } else {
	# The user has either selected one of the palette colors, or has
	# cancelled.  The full BWidget/native dialog was not called.
	# Unless the user has cancelled, pass the selected
	# color to _userCommand.
	set tmpCol [lindex $colors $_selection]
	if {[string equal $tmpCol ""]} {
	    # User has cancelled - no need to call _userCommand.
	} else {
	    _userCommand $tmpCol
	}
	return $tmpCol
    }
}


proc SelectColor::_userCommand {color} {
    variable _command
    if {[string equal $_command {}]} {
        return
    }
    uplevel #0 $_command [list $color]
    return
}


proc SelectColor::dialog {path args} {
    variable _baseColors
    variable _userColors
    variable _widget
    variable _selection
    variable _image
    variable _hsv
    variable _command
    variable _unsavedSelection
    variable _oldColor
    variable _entryColor
    variable _bgColor
    variable _fgColor
    variable _rounds


    Widget::init SelectColor $path:SelectColor $args
    set top   [Dialog::create $path \
                   -title  [Widget::cget $path:SelectColor -title]  \
                   -parent [Widget::cget $path:SelectColor -parent] \
                   -separator 0 -default 0 -cancel 1 -anchor e]
    wm resizable $top 0 0
    set dlgf  [$top getframe]
    set fg    [frame $dlgf.fg]
    set desc  [list \
                   base _baseColors "Base colors" \
                   user _userColors "User colors"]

    set help    [Widget::cget $path:SelectColor -help]
    set _command [Widget::cget $path:SelectColor -command]
    set _bgColor [Widget::cget $path:SelectColor -background]
    set _rounds  {}
    set mouseHelpText ""
    if {$help} {
        append mouseHelpText [subst -nocommands -novariables\
                [lindex [BWidget::getname mouseHelpText] 0]]
    }

    set count 0
    foreach {type varcol defTitle} $desc {
        set col   0
        set lin   0
        set title [lindex [BWidget::getname "${type}Colors"] 0]
        if {![string length $title]} {
            set title $defTitle
        }
        set titf  [TitleFrame $fg.$type -text $title]
        set subf  [$titf getframe]
        foreach color [set $varcol] {
            set fround [frame $fg.round$count \
                            -highlightthickness 1 \
                            -relief sunken -borderwidth 2]
            set fcolor [frame $fg.color$count -width 16 -height 12 \
                            -highlightthickness 0 \
                            -relief flat -borderwidth 0 \
                            -background $color]
            pack $fcolor -in $fround
            grid $fround -in $subf -row $lin -column $col -padx 1 -pady 1

            bind $fround <ButtonPress-1> [list SelectColor::_select_rgb $count]
            bind $fcolor <ButtonPress-1> [list SelectColor::_select_rgb $count]
            
            DynamicHelp::add $fround -text $mouseHelpText
            DynamicHelp::add $fcolor -text $mouseHelpText

	    bind $fround <Double-1> \
	    	"SelectColor::_select_rgb [list $count]; [list $top] invoke 0"
	    bind $fcolor <Double-1> \
	    	"SelectColor::_select_rgb [list $count]; [list $top] invoke 0"

	    # Record list of $fround values in _rounds
	    lappend _rounds $fround

            incr count
            if {[incr col] == 6} {
                incr lin
                set  col 0
            }
        }
        pack $titf -anchor w -pady 2
    }

    # Record these colors for later use
    set _fgColor [$fg.round0 cget -highlightcolor]

    # Add a TitleFrame $titf to wrap $fg.round and $fg.value
    set name [lindex [BWidget::getname yourSelection] 0]
    set titf [TitleFrame $fg.choice -text $name]
    set subf [$titf getframe]
    pack $titf -anchor w -pady 2 -expand yes -fill both

    # Add an entry widget $fg.value for the #RRGGBB value
    if {$::tk_version > 8.4} {
	set fixedFont TkFixedFont
    } else {
	set fixedFont Courier
    }
    set subf2 $fg.vround
    frame $subf2 -highlightthickness 0 -relief sunken -borderwidth 2
    entry $fg.value -width 8 -relief sunken -bd 0 -highlightthickness 0 \
            -bg white -textvariable ::SelectColor::_entryColor -font $fixedFont
    pack  $subf2    -in $subf  -anchor w -side left
    pack  $fg.value -in $subf2 -anchor w -side left
    
    if {$help} {
        DynamicHelp::add $fg.value -text [subst -nocommands -novariables\
                    [lindex [BWidget::getname keyboardHelpText] 0]]
    }

    # Remove focus from the entry widget by clicking anywhere...
    bind $top <1> [list ::SelectColor::_CheckFocus %W]

    # ... or by pressing Return/Escape.
    bind $fg.value <Return> [list ::SelectColor::_CheckFocus .]
    bind $fg.value <Escape> [list ::SelectColor::_CheckFocus .]
    bind $fg.value <Return> {+break}
    bind $fg.value <Escape> {+break}
    # Break so that the bindings to these events on the toplevel are not
    # executed.

    # MODS - record the Tk window path for the entry widget.
    set _widget(en) $fg.value

    set fround [frame $fg.round \
                    -highlightthickness 0 \
                    -relief sunken -borderwidth 2]
    set fcolor [frame $fg.color \
                    -width 50 \
                    -highlightthickness 0 \
                    -relief flat -borderwidth 0]
    pack $fcolor -in $fround -fill y -expand yes
    pack $fround -in $subf -side right -anchor e -pady 2 -fill y -expand yes

    # Add a TitleFrame $dlgf.fd to wrap the canvas selectors.  The
    # labels are referenced by the DynamicHelp tooltip.
    set name [lindex [BWidget::getname colorSelectors] 0]
    set fd0 [TitleFrame $dlgf.fd -text $name]
    set fd  [$fd0 getframe]
    set f1  [frame $fd.f1 -relief sunken -borderwidth 2]
    set f2  [frame $fd.f2 -relief sunken -borderwidth 2]
    set c1  [canvas $f1.c -width 200 -height 200 -bd 0 -highlightthickness 0]
    set c2  [canvas $f2.c -width 15  -height 200 -bd 0 -highlightthickness 0]

    for {set val 0} {$val < 40} {incr val} {
        $c2 create rectangle 0 [expr {5*$val}] 15 [expr {5*$val+5}] -tags val[expr {39-$val}]
    }
    $c2 create polygon 0 0 10 5 0 10 -fill black -outline white -tags target

    pack $c1 $c2
    pack $f1 $f2 -side left -padx 10 -anchor n

    pack $fg $fd0 -side left -anchor n -fill y
    pack configure $fd0 -pady 2 -padx {4 0}

    bind $c1 <ButtonPress-1> [list SelectColor::_select_hue_sat %x %y]
    bind $c1 <B1-Motion>     [list SelectColor::_select_hue_sat %x %y]

    bind $c2 <ButtonPress-1> [list SelectColor::_select_value %x %y]
    bind $c2 <B1-Motion>     [list SelectColor::_select_value %x %y]

    if {![info exists _image] || [catch {image type $_image}]} {
        set _image [image create photo -width 200 -height 200]
        for {set x 0} {$x < 200} {incr x 4} {
            for {set y 0} {$y < 200} {incr y 4} {
                $_image put \
		    [eval [list format "\#%04x%04x%04x"] \
			[hsvToRgb [expr {$x/196.0}] [expr {(196-$y)/196.0}] 0.85]] \
			-to $x $y [expr {$x+4}] [expr {$y+4}]
            }
        }
    }
    $c1 create image  0 0 -anchor nw -image $_image
    $c1 create bitmap 0 0 \
        -bitmap @[file join $::BWIDGET::LIBRARY "images" "target.xbm"] \
        -anchor nw -tags target

    set _selection -1
    set _widget(fcolor) $fg
    set _widget(chs)    $c1
    set _widget(cv)     $c2
    set rgb             [winfo rgb $path [Widget::cget $path:SelectColor -color]]
    set _hsv            [eval rgbToHsv $rgb]
    _set_rgb     [eval [list format "\#%04x%04x%04x"] $rgb]
    _set_hue_sat [lindex $_hsv 0] [lindex $_hsv 1]
    _set_value   [lindex $_hsv 2]

    # Initialize _oldColor which is used to reset the color supplied to
    # _userCommand if the user cancels.
    set _oldColor [set _unsavedSelection]
    set tmp24     [::SelectColor::_24BitRgb $_oldColor]
    if {[_ValidateColorEntry forced $tmp24]} {
        set ::SelectColor::_entryColor $tmp24
    } else {
        # Value $tmp24 does not pass entry widget validation and if used
        # would disable validation.  Use this default instead.
        set _entryColor #
    }

    # Validate input to the entry field.
    # To avoid conflict with the entry -variable (_entryColor), do not set the
    # latter directly (because a failed validation will switch off subsequent
    # validations).  Either call _SetEntryValue, or set _unsavedSelection which
    # triggers the trace.

    $fg.value configure -validate all -validatecommand \
            [list SelectColor::_ValidateColorEntry %V %P]

    # Trace _unsavedSelection
    # Subsequent modifications to _unsavedSelection will update the entry
    # widget, if the value is valid.
    # From now on, this is the only way that:
    # (1) ::SelectColor::_SetEntryValue is called
    # (2) ::SelectColor::_entryColor is modified (except by the user typing in
    #     the entry widget)

    trace add variable ::SelectColor::_unsavedSelection write ::SelectColor::_SetEntryValue

    $top add -text [lindex [BWidget::getname ok] 0]
    $top add -text [lindex [BWidget::getname cancel] 0]

    # Override background color
    ReColor $path $_bgColor

    set res [$top draw]
    if {$res == 0} {
        set color [$fg.color cget -background]
    } else {
        # User has cancelled - call _userCommand to undo any changes made
        # in the caller.
        _userCommand $_oldColor
        set color ""
    }

    trace remove variable ::SelectColor::_unsavedSelection write ::SelectColor::_SetEntryValue

    destroy $top
    return $color
}


# ----------------------------------------------------------------------------
# Command SelectColor::setbasecolor
# ----------------------------------------------------------------------------
# Exported command, to allow the caller to set the base colors of the palette.

proc SelectColor::setbasecolor { idx color } {
    variable _baseColors
    set _baseColors [lreplace $_baseColors $idx $idx $color]
}

# ----------------------------------------------------------------------------
# Command SelectColor::setcolor
# ----------------------------------------------------------------------------

proc SelectColor::setcolor { idx color } {
    variable _userColors
    set _userColors [lreplace $_userColors $idx $idx $color]
}

proc SelectColor::_select_rgb {count} {
    variable _baseColors
    variable _userColors
    variable _selection
    variable _widget
    variable _hsv
    variable _unsavedSelection
    variable _bgColor
    variable _fgColor

    set frame $_widget(fcolor)

    # Use highlight color instead of focus to identify the selected
    # palette color. Tab traversal of focus now works correctly.
    if {$_selection >= 0} {
        $frame.round$_selection configure \
            -relief sunken -highlightthickness 1 -borderwidth 2 \
            -highlightbackground $_bgColor
    }
    $frame.round$count configure \
        -relief flat -highlightthickness 2 -borderwidth 1 \
        -highlightbackground $_fgColor
    set _selection $count
    set bg   [$frame.color$count cget -background]
    set user [expr {$_selection-[llength $_baseColors]}]
    if {$user >= 0 &&
        [string equal \
              [winfo rgb $frame.color$_selection $bg] \
              [winfo rgb $frame.color$_selection white]]} {
        set bg [$frame.color cget -bg]
        $frame.color$_selection configure -background $bg
        set _userColors [lreplace $_userColors $user $user $bg]
    } else {
        set _hsv [eval rgbToHsv [winfo rgb $frame.color$count $bg]]
        _set_hue_sat [lindex $_hsv 0] [lindex $_hsv 1]
        _set_value   [lindex $_hsv 2]
        $frame.color configure -background $bg

        # Display selected color in entry widget (via trace on
        # ::SelectColor::_unsavedSelection), and notify caller.
        set ::SelectColor::_unsavedSelection $bg
        _userCommand $bg
    }
}


proc SelectColor::_set_rgb {rgb} {
    variable _selection
    variable _baseColors
    variable _userColors
    variable _widget
    variable _unsavedSelection

    set frame $_widget(fcolor)
    $frame.color configure -background $rgb

    # Display selected color in entry widget (via trace on
    # ::SelectColor::_unsavedSelection), and notify caller.
    set ::SelectColor::_unsavedSelection $rgb
    _userCommand $rgb
    set user [expr {$_selection-[llength $_baseColors]}]
    if {$user >= 0} {
        $frame.color$_selection configure -background $rgb
        set _userColors [lreplace $_userColors $user $user $rgb]
    }
}


proc SelectColor::_select_hue_sat {x y} {
    variable _widget
    variable _hsv

    if {$x < 0} {
        set x 0
    } elseif {$x > 200} {
        set x 200
    }
    if {$y < 0 } {
        set y 0
    } elseif {$y > 200} {
        set y 200
    }
    set hue  [expr {$x/200.0}]
    set sat  [expr {(200-$y)/200.0}]
    set _hsv [lreplace $_hsv 0 1 $hue $sat]
    $_widget(chs) coords target [expr {$x-9}] [expr {$y-9}]
    _draw_values $hue $sat
    _set_rgb [eval [list format "\#%04x%04x%04x"] [eval [list hsvToRgb] $_hsv]]
}


proc SelectColor::_set_hue_sat {hue sat} {
    variable _widget

    set x [expr {$hue*200-9}]
    set y [expr {(1-$sat)*200-9}]
    $_widget(chs) coords target $x $y
    _draw_values $hue $sat
}



proc SelectColor::_select_value {x y} {
    variable _widget
    variable _hsv

    if {$y < 0} {
        set y 0
    } elseif {$y > 200} {
        set y 200
    }
    $_widget(cv) coords target 0 [expr {$y-5}] 10 $y 0 [expr {$y+5}]
    set _hsv [lreplace $_hsv 2 2 [expr {(200-$y)/200.0}]]
    _set_rgb [eval [list format "\#%04x%04x%04x"] [eval [list hsvToRgb] $_hsv]]
}


proc SelectColor::_draw_values {hue sat} {
    variable _widget

    for {set val 0} {$val < 40} {incr val} {
        set l   [hsvToRgb $hue $sat [expr {$val/39.0}]]
        set col [eval [list format "\#%04x%04x%04x"] $l]
        $_widget(cv) itemconfigure val$val -fill $col -outline $col
    }
}


proc SelectColor::_set_value {value} {
    variable _widget

    set y [expr {int((1-$value)*200)}]
    $_widget(cv) coords target 0 [expr {$y-5}] 10 $y 0 [expr {$y+5}]
}


# --
#  Taken from tk8.0/demos/tcolor.tcl
# --
# The procedure below converts an HSB value to RGB.  It takes hue, saturation,
# and value components (floating-point, 0-1.0) as arguments, and returns a
# list containing RGB components (integers, 0-65535) as result.  The code
# here is a copy of the code on page 616 of "Fundamentals of Interactive
# Computer Graphics" by Foley and Van Dam.

proc SelectColor::hsvToRgb {hue sat val} {
    set v [expr {round(65535.0*$val)}]
    if {$sat == 0} {
	return [list $v $v $v]
    } else {
	set hue [expr {$hue*6.0}]
	if {$hue >= 6.0} {
	    set hue 0.0
	}
	set i [expr {int($hue)}]
	set f [expr {$hue-$i}]
	set p [expr {round(65535.0*$val*(1 - $sat))}]
        set q [expr {round(65535.0*$val*(1 - ($sat*$f)))}]
        set t [expr {round(65535.0*$val*(1 - ($sat*(1 - $f))))}]
        switch $i {
	    0 {return [list $v $t $p]}
	    1 {return [list $q $v $p]}
	    2 {return [list $p $v $t]}
	    3 {return [list $p $q $v]}
	    4 {return [list $t $p $v]}
            5 {return [list $v $p $q]}
        }
    }
}


# --
#  Taken from tk8.0/demos/tcolor.tcl
# --
# The procedure below converts an RGB value to HSB.  It takes red, green,
# and blue components (0-65535) as arguments, and returns a list containing
# HSB components (floating-point, 0-1) as result.  The code here is a copy
# of the code on page 615 of "Fundamentals of Interactive Computer Graphics"
# by Foley and Van Dam.

proc SelectColor::rgbToHsv {red green blue} {
    if {$red > $green} {
	set max $red.0
	set min $green.0
    } else {
	set max $green.0
	set min $red.0
    }
    if {$blue > $max} {
	set max $blue.0
    } else {
	if {$blue < $min} {
	    set min $blue.0
	}
    }
    set range [expr {$max-$min}]
    if {$max == 0} {
	set sat 0
    } else {
	set sat [expr {($max-$min)/$max}]
    }
    if {$sat == 0} {
	set hue 0
    } else {
	set rc [expr {($max - $red)/$range}]
	set gc [expr {($max - $green)/$range}]
	set bc [expr {($max - $blue)/$range}]
	if {$red == $max} {
	    set hue [expr {.166667*($bc - $gc)}]
	} else {
	    if {$green == $max} {
		set hue [expr {.166667*(2 + $rc - $bc)}]
	    } else {
		set hue [expr {.166667*(4 + $gc - $rc)}]
	    }
	}
	if {$hue < 0.0} {
	    set hue [expr {$hue + 1.0}]
	}
    }
    return [list $hue $sat [expr {$max/65535}]]
}

# ------------------------------------------------------------------------------
#  Command SelectColor::ReColor
# ------------------------------------------------------------------------------
# Command to change the background color for the dialog.
#
# FIXME Ideally this would be called by "$w configure -background $value".
# Currently a "configure -background" command is passed to Dialog and Widget
# but does not change SelectColor.
# HaO: it might also be possible that this is controled by the option data base.
# ------------------------------------------------------------------------------

proc SelectColor::ReColor {path newColor} {
    variable _bgColor
    variable _rounds

    set _bgColor $newColor

    $path configure -bg $_bgColor

    # Use the internal names of the dialog widget - it would be nicer to
    # use a colored dialog widget.
    foreach child {
        fd      fd.f.f1  fd.f.f2
        fg      fg.base  fg.choice
        fg.user fg.round fg.vround
    } {
        $path.frame.$child configure -background $_bgColor
    }

    # Special treatment for Aqua native buttons.
    # FIXME implement a general fix for BWidget Button/ButtonBox/Dialog
    if {[string equal [tk windowingsystem] "aqua"]} {
        $path.bbox.b0 configure -highlightbackground $_bgColor \
                -highlightthickness 0
        $path.bbox.b1 configure -highlightbackground $_bgColor \
                -highlightthickness 0
    } else {
        $path.bbox.b0 configure -bg $_bgColor -activebackground $_bgColor \
                -highlightbackground $_bgColor
        $path.bbox.b1 configure -bg $_bgColor -activebackground $_bgColor \
                -highlightbackground $_bgColor
    }

    foreach fround $_rounds {
        $fround configure -highlightbackground $_bgColor -bg $_bgColor
    }
    
    return
}


# ------------------------------------------------------------------------------
# Command SelectColor::_24BitRgb
# ------------------------------------------------------------------------------
# Command to convert a hex 12n-bit RGB color to 24-bit, n > 0.
# Convert anything else to {}.
# Used to process the display in the entry widget.
# ------------------------------------------------------------------------------

proc SelectColor::_24BitRgb {col} {
    set  lenny [string length $col]
    incr lenny -1

    if {    ($lenny % 3)
         || ($lenny == 0)
         || (![regexp {^#[a-fA-F0-9]*$} $col])
    } {
        # Not a multiple of 3, or not leading #, or nothing after #,
        # or non-HEX digits.
        return {}
    } elseif {$lenny == 3} {
        # 12-bit, pad to 24-bit
        set val $col
        set val [string replace $val 3 3 "[string index $val 3]0"]
        set val [string replace $val 2 2 "[string index $val 2]0"]
        set val [string replace $val 1 1 "[string index $val 1]0"]
        return $val
    } elseif {$lenny == 6} {
        # 24-bit, return unchanged
        return $col
    } else {
        # Truncate to 24-bit
        set delta  [expr {$lenny / 3}]
        set delta2 [expr {$delta * 2}]
        set deltaP1  [incr delta]
        set deltaP2  [incr delta]
        set delta2P1 [incr delta2]
        set delta2P2 [incr delta2]
        set result #
        append result [string range $col 1 2]
        append result [string range $col $deltaP1  $deltaP2]
        append result [string range $col $delta2P1 $delta2P2]
        return $result
    }
}


# ------------------------------------------------------------------------------
# Command SelectColor::_SetEntryValue
# ------------------------------------------------------------------------------
# Command to update the (hexadecimal color displayed in the) entry widget
# when there is a change in the color currently selected in the GUI, which is
# stored in _unsavedSelection.
#
# This command is called by a write trace on _unsavedSelection; if the
# value of this variable is a valid color (i.e. "#" followed by 3N hex digits),
# this command converts the value to 24 bits and sets ::SelectColor::_entryColor
# to the result, thereby displaying it in the entry widget.  Therefore,
# when the user chooses a color by means other than the entry widget, this
# command updates the entry widget.
#
# This command does not update the GUI when the user changes the value in the
# entry widget: that is done instead by the -vcmd of the entry widget, which
# is SelectColor::_ValidateColorEntry.  When the user chooses a color by typing
# in the entry widget, the command _ValidateColorEntry copies the value to
# _unsavedSelection if a keystroke in the widget makes its contents 3N hex
# digits long.
# ------------------------------------------------------------------------------

proc SelectColor::_SetEntryValue {argVarName var2 op} {
    variable _entryColor
    variable _unsavedSelection

    if {[string equal $argVarName ::SelectColor::_unsavedSelection] &&
            [string equal $var2 {}] && [string equal $op "write"]} {
        # OK
    } else {
        # Unexpected call
        return -code error "Unexpected trace of variable\
                \"$argVarName\", \"$var2\", \"$op\""
    }

    set col24bit [::SelectColor::_24BitRgb [set $argVarName]]

    if {[_ValidateColorEntry forced $col24bit]} {
        set ::SelectColor::_entryColor $col24bit
    } else {
        # Value is invalid, and if written to _entryColor this would disable
        # validation.
    }

    return
}


# ------------------------------------------------------------------------------
# Command SelectColor::_CheckFocus
# ------------------------------------------------------------------------------
# This command is called with argument %W as a binding to <1> on the toplevel.
# It is also called with argument {.}, by bindings on the entry widget to
# <Escape>, <Return>.
#
# The command does something only if the entry widget has focus, and the
# argument (the clicked window) is the Tk window path of somewhere else.  Then,
# the command removes focus from the entry widget to the default button.
# ------------------------------------------------------------------------------

proc SelectColor::_CheckFocus {w} {
    variable _widget

    if {    (! [string equal $w $_widget(en)]) &&
            ([string equal [focus]  $_widget(en)])} {
        set top [winfo toplevel $_widget(en)]
        $top setfocus default
    }

    return
}


# ------------------------------------------------------------------------------
# Command SelectColor::_ValidateColorEntry
# ------------------------------------------------------------------------------
# This command is the "-validate all -vcmd" of the entry widget.
# It is also called by SelectColor::dialog and SelectColor::_SetEntryValue to
# check values assigned to _entryColor.
#
# When the user chooses a color by typing in the entry widget, this command
# copies the value to _unsavedSelection if a keystroke in the widget makes its
# contents 3N hex digits long.
# ------------------------------------------------------------------------------

proc SelectColor::_ValidateColorEntry {percentV percentP} {
    variable _unsavedSelection

    set result [regexp -- {^#[0-9a-fA-F]*$} $percentP]
    set lenny  [string length $percentP]

    if {$result} {
        if {[string equal $percentV "forced"]} {
            # Validation only.  Don't want a loop.
        } elseif {[string equal $percentV "key"]} {
            # Copy to GUI if a valid color.
            if {($lenny - 1) % 3 || $lenny == 1} {
                # Not a valid color, which needs 3n+1 characters, n > 0
            } else {
                after idle [list SelectColor::_SetWithoutTrace $percentP]
            }
        } elseif {[string equal $percentV "focusout"]} {
            # If the color is valid it will already have been copied to the GUI
            # and to _userCommand by the "key" validation above.
            #
            # The code below only needs to reset the value in the entry widget.
            # Remove an invalid value, convert a valid one to 24-bit.
            # Ignore $percentP, just fire the trace on _unsavedSelection.
            set color $_unsavedSelection
            after idle [list set ::SelectColor::_unsavedSelection $color]
        }
    }

    return $result
}


# ------------------------------------------------------------------------------
# Command SelectColor::_SetWithoutTrace
# ------------------------------------------------------------------------------
# This command sets _unsavedSelection (using _set_rgb) without firing the trace
# that copies the value to _entryColor.
# The command is called by SelectColor::_ValidateColorEntry to avoid a loop.
# ------------------------------------------------------------------------------

proc SelectColor::_SetWithoutTrace {value} {
    trace remove variable ::SelectColor::_unsavedSelection write ::SelectColor::_SetEntryValue
    _set_rgb $value
    set _hsv [eval rgbToHsv [winfo rgb . $value]]
    _set_hue_sat [lindex $_hsv 0] [lindex $_hsv 1]
    _set_value   [lindex $_hsv 2]
    trace add variable ::SelectColor::_unsavedSelection write ::SelectColor::_SetEntryValue
    return
}
