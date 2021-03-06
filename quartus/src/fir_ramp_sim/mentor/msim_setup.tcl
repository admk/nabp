
# (C) 2001-2012 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ----------------------------------------
# Auto-generated simulation script

# ----------------------------------------
# Initialize the variable
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
} 

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "fir_ramp"
} elseif { ![ string match "" $TOP_LEVEL_NAME ] } { 
  set TOP_LEVEL_NAME "$TOP_LEVEL_NAME"
} 

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
} elseif { ![ string match "" $QSYS_SIMDIR ] } { 
  set QSYS_SIMDIR "$QSYS_SIMDIR"
} 


# ----------------------------------------
# Copy ROM/RAM files to simulation directory

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries/     
ensure_lib      ./libraries/work/
vmap       work ./libraries/work/
if { ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] } {
  ensure_lib                        ./libraries/altera_ver/            
  vmap       altera_ver             ./libraries/altera_ver/            
  ensure_lib                        ./libraries/lpm_ver/               
  vmap       lpm_ver                ./libraries/lpm_ver/               
  ensure_lib                        ./libraries/sgate_ver/             
  vmap       sgate_ver              ./libraries/sgate_ver/             
  ensure_lib                        ./libraries/altera_mf_ver/         
  vmap       altera_mf_ver          ./libraries/altera_mf_ver/         
  ensure_lib                        ./libraries/altera_lnsim_ver/      
  vmap       altera_lnsim_ver       ./libraries/altera_lnsim_ver/      
  ensure_lib                        ./libraries/stratixiv_hssi_ver/    
  vmap       stratixiv_hssi_ver     ./libraries/stratixiv_hssi_ver/    
  ensure_lib                        ./libraries/stratixiv_pcie_hip_ver/
  vmap       stratixiv_pcie_hip_ver ./libraries/stratixiv_pcie_hip_ver/
  ensure_lib                        ./libraries/stratixiv_ver/         
  vmap       stratixiv_ver          ./libraries/stratixiv_ver/         
  ensure_lib                        ./libraries/altera/                
  vmap       altera                 ./libraries/altera/                
  ensure_lib                        ./libraries/lpm/                   
  vmap       lpm                    ./libraries/lpm/                   
  ensure_lib                        ./libraries/sgate/                 
  vmap       sgate                  ./libraries/sgate/                 
  ensure_lib                        ./libraries/altera_mf/             
  vmap       altera_mf              ./libraries/altera_mf/             
  ensure_lib                        ./libraries/altera_lnsim/          
  vmap       altera_lnsim           ./libraries/altera_lnsim/          
  ensure_lib                        ./libraries/stratixiv_hssi/        
  vmap       stratixiv_hssi         ./libraries/stratixiv_hssi/        
  ensure_lib                        ./libraries/stratixiv_pcie_hip/    
  vmap       stratixiv_pcie_hip     ./libraries/stratixiv_pcie_hip/    
  ensure_lib                        ./libraries/stratixiv/             
  vmap       stratixiv              ./libraries/stratixiv/             
}


# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  if { ![ string match "*ModelSim ALTERA*" [ vsim -version ] ] } {
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_primitives.v"               -work altera_ver            
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/220model.v"                        -work lpm_ver               
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/sgate.v"                           -work sgate_ver             
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_mf.v"                       -work altera_mf_ver         
    vlog -sv "/home/admko/altera/11.1/quartus/eda/sim_lib/mentor/altera_lnsim_for_vhdl.sv"   -work altera_lnsim_ver      
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_hssi_atoms.v"            -work stratixiv_hssi_ver    
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_pcie_hip_atoms.v"        -work stratixiv_pcie_hip_ver
    vlog     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_atoms.v"                 -work stratixiv_ver         
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_syn_attributes.vhd"         -work altera                
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_standard_functions.vhd"     -work altera                
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/alt_dspbuilder_package.vhd"        -work altera                
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_europa_support_lib.vhd"     -work altera                
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_primitives_components.vhd"  -work altera                
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_primitives.vhd"             -work altera                
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/220pack.vhd"                       -work lpm                   
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/220model.vhd"                      -work lpm                   
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/sgate_pack.vhd"                    -work sgate                 
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/sgate.vhd"                         -work sgate                 
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_mf_components.vhd"          -work altera_mf             
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_mf.vhd"                     -work altera_mf             
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_lnsim_components.vhd"       -work altera_lnsim          
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_hssi_components.vhd"     -work stratixiv_hssi        
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_hssi_atoms.vhd"          -work stratixiv_hssi        
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_pcie_hip_components.vhd" -work stratixiv_pcie_hip    
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_pcie_hip_atoms.vhd"      -work stratixiv_pcie_hip    
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_atoms.vhd"               -work stratixiv             
    vcom     "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_components.vhd"          -work stratixiv             
  }
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  vlog "$QSYS_SIMDIR/altera_avalon_sc_fifo.v"                        
  vcom "$QSYS_SIMDIR/auk_dspip_math_pkg_hpfir.vhd"                   
  vcom "$QSYS_SIMDIR/auk_dspip_lib_pkg_hpfir.vhd"                    
  vcom "$QSYS_SIMDIR/auk_dspip_avalon_streaming_controller_hpfir.vhd"
  vcom "$QSYS_SIMDIR/auk_dspip_avalon_streaming_sink_hpfir.vhd"      
  vcom "$QSYS_SIMDIR/auk_dspip_avalon_streaming_source_hpfir.vhd"    
  vcom "$QSYS_SIMDIR/auk_dspip_roundsat_hpfir.vhd"                   
  vcom "$QSYS_SIMDIR/fir_ramp_rtl_wysiwyg.vhd"                       
  vcom "$QSYS_SIMDIR/fir_ramp_rtl.vhd"                               
  vcom "$QSYS_SIMDIR/fir_ramp_ast.vhd"                               
  vcom "$QSYS_SIMDIR/fir_ramp.vhd"                                   
  vcom "$QSYS_SIMDIR/fir_ramp_tb.vhd"                                
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  vsim -t ps -L work -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixiv_hssi_ver -L stratixiv_pcie_hip_ver -L stratixiv_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L stratixiv_hssi -L stratixiv_pcie_hip -L stratixiv $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with novopt option
alias elab_debug {
  echo "\[exec\] elab_debug"
  vsim -novopt -t ps -L work -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L stratixiv_hssi_ver -L stratixiv_pcie_hip_ver -L stratixiv_ver -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L stratixiv_hssi -L stratixiv_pcie_hip -L stratixiv $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -novopt
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with novopt option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -novopt"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
}
h
