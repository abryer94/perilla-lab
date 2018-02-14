#!/bin/tclsh 
#
#### AJB - Tcl script to format distance restraint, colvars file
####	   for NAMD. Parsed from talos

if { $argc != 4 } { 
	puts "usage: tclsh $argv0 \$inputfile \$outputfile1 \$outputfile2 segment ID"
	exit
}

#input and output; read/write 
set input [open [lindex $argv 0] r] 
set output [open [lindex $argv 1] w]
set output2 [open [lindex $argv 2] w]
set psfSegID [lindex $argv 3]

#set force constant
set k 200.0
set i 0
while { [gets $input line] != -1 } {
	if { [string range $line 0 5] == "assign" } {
		gets $input newline
		if { [string range $newline 0 5] == "assign" || $newline != -1} {
			set i [expr $i+1]
			set resid1 [lindex $line 2]
			set atmname1 [lindex $line 5]
			set resid2 [lindex $line 8]
			set atmname2 [lindex $line 11]
	
			#bounds
			set lower [format %.1f [expr [lindex $line 13] - [lindex $line 14]]]
			set upper [format %.1f [expr [lindex $line 13] + [lindex $line 15]]]

			puts $output "colvar { " 
			puts $output "\t name $i"
			puts $output "\t lowerWall $lower"
			puts $output "\t upperWall $upper"
			puts $output "\t lowerWallConstant $k"
			puts $output "\t upperWallConstant $k"
			puts $output "\t distance { "
			puts $output "\t\t group1 { "
			puts $output "\t\t psfSegID $psfSegID"
			puts $output "\t\t atomNameResidueRange $atmname1 $resid1-$resid1 } "
			puts $output "\t\t group2 { "
			puts $output "\t\t psfSegID $psfSegID"
			puts $output "\t\t atomNameResidueRange $atmname2 $resid2-$resid2 } "
			puts $output "\t\t} "
			puts $output "} "

			puts $output2 "$i $lower $upper $k $psfSegID $resid1 $atmname1 $resid2 $atmname2"
	 		
	}
}
}
#close 
close $input 
close $output 
puts "Success! Finished processing input: [lindex $argv 0]"
puts "Results written to: [lindex $argv 1] and ..."

