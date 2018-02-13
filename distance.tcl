#!/bin/tclsh 
#
#### AJB - Tcl script to format distance restraint, colvars file
####	   for NAMD. Parsed from talos

if { $argc != 2 } { 
	puts "usage: tclsh $argv0 \$inputfile \$outputfile"
	exit
}

#input and output; read/write 
set input [open [lindex $argv 0] r] 
set output [open [lindex $argv 1] w]

#set force constant
set k 200.0

while { [gets $input line] != -1 } {
	if { [string range $line 0 5] == "assign" } {
		set resid1 [lindex $line 2]
		set atmname1 [lindex $line 5]
		set resid2 [lindex $line 8]
		set atmname2 [lindex $line 11]
	
		#bounds
		set lower [format %.1f [expr [lindex $line 13] - [lindex $line 14]]]
		set upper [format %.1f [expr [lindex $line 13] + [lindex $line 15]]]

		puts $output "colvar { " 
		puts $output "\t name distance:$resid1-$resid2"
		puts $output "\t lowerWalls $lower"
		puts $output "\t upperWalls $upper"
		puts $output "\n\t distance { "
		puts $output "\t\t group1 {atomNameResidueRange $atmname1 $resid1-$resid1} "
		puts $output "\t\t group2 {atomNameResidueRange $atmname2 $resid2-$resid2} "
		puts $output "\t\t} "
		puts $output "} "

		puts $output "\nharmonicWalls { "
		puts $output "\tcolvars distance:$resid1-$resid1"
		puts $output "\t lowerWallConstant $k "
		puts $output "\t upperWallConstant $k "
		puts $output "} \n"
	 
	}
}

#close 
close $input 
close $output 
puts "Success! Finished processing input: [lindex $argv 0]"
puts "Results written to: [lindex $argv 1]"


