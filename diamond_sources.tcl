
# This file contains the tcl commands to add the sources needed to incorporate this module into a higher level design (i.e. FPGA top level)

set abs_path [ file dirname [ file normalize [ info script ] ] ]; # ABSOLUTE PATH TO THE DIRECTORY THIS SCRIPT IS RESIDING IN


#
# PUT LATTICE DIAMOND PROJECT TCL COMMANDS BELOW HERE TO ADD THE SOURCES REQUIRED FOR USING THIS MODULE IN A PROJECT
#
# Example: prj_src add $abs_path/hdl/my_module.sv
#
# See Lattice Diamond HTML help (Reference Guides --> Tcl Command Reference Guide --> Diamond Tool Tcl Command Syntax --> Diamond Project Tcl Commands for more info)
#
# If you have a pre-compiled IP you need to also append to the path to .ngo file directory to the macro_search_path variable.
#
# Example: append macro_search_path "$abs_path/path_to_ip_ngo;" (NOTE THE ; AT THE END OF THE PATH!)
#


# DON'T FORGET to pre-pend $abs_path to the path to your sources
# DON'T FORGET the ; at the end of the path to your pre-compiled IP .ngo file directory

prj_src add $abs_path/rtl/d_engine.sv
prj_src add $abs_path/rtl/d_process_single.sv
prj_src add $abs_path/rtl/vcordic.sv
prj_src add $abs_path/rtl/vcordic_rcordic_chain.sv
prj_src add $abs_path/rtl/elastic-buffer/eb15.sv

# used for the original 2 function mode
# prj_src add $abs_path/rtl/d_process.sv
# prj_src add $abs_path/rtl/reciprocal/hdl/reciprocal.v