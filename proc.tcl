#!/usr/bin/tclsh
proc countc {pattern list } {
	set n 0
	foreach line $list {
		if { [string match $pattern $line] } {
			puts $line
			incr n
		}
	}
	puts $n
}

proc cus_reportcell {value} {
	redirect -variable str {report_cell -nosplit}
	set lst [split $str "\n"]
	foreach line $lst {
		set word [split $line "     "]
		foreach a $word {
			if { [string match {[0-9]*} $a] } {
				if { $a > $value} {
					puts $a
				}				
			}
		}
	} 
}

proc getref {} {
	redirect -variable str {report_cell -nosplit}
        set lst [split $str "\n"]
	set lstref { }
	foreach line $lst {
		set word [split $line " "]
		foreach a $word {
			if { [string match TH5* $a]} {
				set n 0
				foreach b $lstref {
					if { [string match $b $a] } { break 
					} else { incr n}
				}
				if { [llength $lstref] <= $n } {
					lappend lstref $a
				}
			}
		}
	}

	puts $lstref
	puts [llength $lstref]
}

proc portinout {} {
	set i 0
	set o 0
	redirect -variable str {report_port -nosplit}
	set lst [split $str "\n"]
        set lstref { }
        foreach line $lst {
                set word [split $line " "]
                foreach a $word {
			if { [string match in $a] } { 
				incr i
			} elseif { [string match out $a] } {
				incr o
			}
		}
	}
	puts "Input port: $i"
	puts "Output port: $o"
}
					
proc clkcount {} {
	set i 0
	puts [format "%-25s |     %-15s (MHz)" "CLOCK" "FREQUENCY" ]
	puts ------------------------------------------------------
	redirect -variable str {report_clock -nosplit}
        set lst [split $str "\n"]
        set lstref { }
        foreach line $lst {
                set word [split $line " "]
                foreach a $word {
			if { [string match "*C*K*" $a]} {
				incr i
				puts [format "%-25s |     %-15f (MHz)" $a [expr 1000/[lindex $line 1]] ]
			}
		}
	}
	puts "There are $i clocks in design"
}

proc fixcell {} {
	redirect -variable str {report_cell -nosplit}
        set lst [split $str "\n"]
        foreach line $lst {
                set word [split $line " "]
                foreach a $word {
			if {[string match T*5* $a]} {
				set b [string replace [lindex $line 1] 0 1 TL]
				set c [string replace $b end end H]
				size_cell [lindex $line 0] $c
				set d [string replace $b end end Q]
				size_cell [lindex $line 0] $d
			}
		}
	}
}

proc cal_vth_per {} {
	
	set th [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*TH5*" ]]
	set tm [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*TM5*" ]]
	set tl [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*TL5*" ]]

	set buf [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*BUF*" ]]
	set inv [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*INV*" ]]
	set dff [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*DFF*" ]]

	set tt [sizeof_collection [get_cells -hierarchical ]]

	puts $tt
	puts "TH:     [expr $th*100/$tt]  %"
	puts "TM:     [expr $tm*100/$tt]  %"
	puts "TL:     [expr $tl*100/$tt]  %"
	puts "BUF:    [expr $buf*100/$tt] %"
	puts "INV:    [expr $inv*100/$tt] %"
	puts "DFF:    [expr $dff*100/$tt] %"
}

proc libcount {} {
        set lib [get_object_name [get_lib]]
        puts "The current design have [llength $lib ] librarys"
	puts $lib

	foreach c $lib {
		set k 0
		set j 0
		redirect -variable stlib {report_lib $c -nosplit}
        	set lstlib [split $stlib "\n"]
        	foreach linelib $lstlib {
                	set wordlib [split $linelib " "]
                	foreach d $wordlib {
                        	if { [string match T?5* $d]} {
					incr k
					set l [sizeof_collection [get_cells -filter "ref_name =~ $d" -quiet -hierarchical]]				
					set j [expr $j + $l]
					if { $l != 0 } {
						puts "$d have $l cells"
					}
				}
			}
		}
		puts "Library $c have $k types"
		puts "Library $c have $j cells in current design"
	}
}

proc getall_net_buffer {} {
	set cell_list [get_object_name  [get_cells -filter "ref_name =~ *BUF*" -hierarchical ] ]
	foreach cell $cell_list {
		
		set a [get_nets -of_objects [get_object_name [get_pins -of_objects $cell  -filter "pin_direction =~ *out*"]]]
		puts [get_object_name $a]
	}
}

proc getnet_fanout10 {} {
	set net_list [get_object_name [get_nets -filter "number_of_leaf_loads > 10 "]]
	foreach net $net_list {
		set a [get_cells -of_objects [get_pins -of_objects $net -filter "direction==out"]]
		puts "Cells which is driven by net, is :[get_object_name $a]"
		set b [get_cells -of_objects [get_pins -of_objects $net -filter "direction==in"]]
                puts "Cells drive net is :[get_object_name $b]"

	}
}

proc buffer_insert_drive {net} {
	insert_buffer [get_pins -of_objects $net -filter "direction =~ *out*"] TH5BUFXA
}

proc buffer_insert_driven {net} {
        insert_buffer [get_pins -of_objects $net -filter "direction =~ *in*"] TH5BUFXA
}

proc buffer_input_MUX {cell} {
	set a [get_attribute -class cell $cell ref_name]
	if { [string match *MUX* $a ]} {
		insert_buffer [get_pins -of_objects $cell -filter "direction =~ *in*"]  TH5BUFXA

	} else { puts "It is not a Mux gate" }
}

proc buffer_output_MUX {cell} {
        set a [get_attribute -class cell $cell ref_name]
        if { [string match *MUX* $a ]} {
                insert_buffer [get_pins -of_objects $cell -filter "direction =~ *out*"] TH5BUFXA
        } else { puts "It is not a Mux gate" }

}

proc count_reg {} {
	set kq { }
	set reg_list [get_object_name [all_registers]]
	foreach reg $reg_list {
		set n 0
		foreach a $kq {
			set b [string range $a 0 end-3 ]
			if { [regexp $b $reg] } { break } else { incr n }
		}
		if { [ llength $kq ] <= $n } { lappend kq $reg }
	}
	set c [lsort $kq]
	foreach d $c {
		puts $d
	}
}


proc reg_in_module { } {
	set reg_list [get_object_name [all_registers]]
	set mod_list [get_object_name [get_cells */*]]
	foreach reg $reg_list {
		foreach mod $mod_list {
			if { [string match $reg $mod] } {
				puts "Register $reg belong to Module $mod"
			}
		}
	}
}

proc macro_type {} {
	set cell_list [get_object_name [get_cells *] ]
	foreach cell $cell_list {
		set ref [ get_attribute -class cell $cell ref_name ]
		if { ![string match *AND* $ref ]} { 
			if { ![string match *OR* $ref ]} { 
				if { ![string match *XOR* $ref ]} { 
					if { ![string match *FF* $ref ]} {
						if { ![string match *LATCH* $ref ]} { 
							 puts "Cell $cell have ref_name $ref" 
						}
					}
				}
			}
		}
	}
}

proc reg_clk {} {
	set clk_list [get_object_name [ all_clocks ] ]
        foreach clk $clk_list {
		puts ======================$clk=======================================
		set reg_list [get_object_name [ all_registers -clock $clk ] ]
		puts $reg_list
		puts \n 
		puts \n
	}
}

proc summary_report_path {} {
#	puts =======================================================================================================================================================================================
#	puts [format "|%-20s | %-20s | %-20s | %-20s | %-20s | %-20s |%-20s | %-20s |" "FROM_REG" "LAUNCH CLOCK" "TO_REG" "CAPTURE CLOCK" "VIOLATE" "WNS" "TNS" "RATIO"]  
#	puts =======================================================================================================================================================================================
        set ti 0
	set t_tns 0
	foreach_in_collection group [get_path_groups ] {
		set i 0
		set wns 0 
		set tns 0
		foreach_in_collection path [get_timing_paths -nworst 10000 -group $group] {
			incr i
			set slack [get_attribute $path slack]
			if { $slack < $wns } {
 				set wns $slack
 			}	
			if { $slack < 0 } {
				set tns [expr $tns + $slack]
			}	
		}
         	puts [format "|%-20s | %-20s | %-20s | %-20s | %-20s | %-20s |%-20s | %-20s |" from_reg launch_clock to_reg "CAPTURE CLOCK" $i $wns $tns "RATIO"]
	set ti [expr $ti + $i]
	set t_tns [expr $t_tns + $tns]
	}
#	puts =======================================================================================================================================================================================
#	puts "**SUMMARY** : TOTAL_VIOLATION: $ti 			TOTAL_SLACK (ns): $t_tns"
}
