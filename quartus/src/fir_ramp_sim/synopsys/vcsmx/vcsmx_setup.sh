
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
# vcsmx - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="fir_ramp"
QSYS_SIMDIR="./../../"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"

# ----------------------------------------
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/stratixiv_hssi_ver/
mkdir -p ./libraries/stratixiv_pcie_hip_ver/
mkdir -p ./libraries/stratixiv_ver/
mkdir -p ./libraries/altera/
mkdir -p ./libraries/lpm/
mkdir -p ./libraries/sgate/
mkdir -p ./libraries/altera_mf/
mkdir -p ./libraries/altera_lnsim/
mkdir -p ./libraries/stratixiv_hssi/
mkdir -p ./libraries/stratixiv_pcie_hip/
mkdir -p ./libraries/stratixiv/

# ----------------------------------------
# copy RAM/ROM files to simulation directory

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_primitives.v"               -work altera_ver            
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/220model.v"                        -work lpm_ver               
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/sgate.v"                           -work sgate_ver             
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_mf.v"                       -work altera_mf_ver         
  vlogan +v2k -sverilog "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_lnsim.sv"                   -work altera_lnsim_ver      
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_hssi_atoms.v"            -work stratixiv_hssi_ver    
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_pcie_hip_atoms.v"        -work stratixiv_pcie_hip_ver
  vlogan +v2k           "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_atoms.v"                 -work stratixiv_ver         
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_syn_attributes.vhd"         -work altera                
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_standard_functions.vhd"     -work altera                
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/alt_dspbuilder_package.vhd"        -work altera                
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_europa_support_lib.vhd"     -work altera                
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_primitives_components.vhd"  -work altera                
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_primitives.vhd"             -work altera                
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/220pack.vhd"                       -work lpm                   
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/220model.vhd"                      -work lpm                   
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/sgate_pack.vhd"                    -work sgate                 
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/sgate.vhd"                         -work sgate                 
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_mf_components.vhd"          -work altera_mf             
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_mf.vhd"                     -work altera_mf             
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/altera_lnsim_components.vhd"       -work altera_lnsim          
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_hssi_components.vhd"     -work stratixiv_hssi        
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_hssi_atoms.vhd"          -work stratixiv_hssi        
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_pcie_hip_components.vhd" -work stratixiv_pcie_hip    
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_pcie_hip_atoms.vhd"      -work stratixiv_pcie_hip    
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_atoms.vhd"               -work stratixiv             
  vhdlan -xlrm          "/home/admko/altera/11.1/quartus/eda/sim_lib/stratixiv_components.vhd"          -work stratixiv             
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k  "$QSYS_SIMDIR/altera_avalon_sc_fifo.v"                        
  vhdlan -xlrm "$QSYS_SIMDIR/auk_dspip_math_pkg_hpfir.vhd"                   
  vhdlan -xlrm "$QSYS_SIMDIR/auk_dspip_lib_pkg_hpfir.vhd"                    
  vhdlan -xlrm "$QSYS_SIMDIR/auk_dspip_avalon_streaming_controller_hpfir.vhd"
  vhdlan -xlrm "$QSYS_SIMDIR/auk_dspip_avalon_streaming_sink_hpfir.vhd"      
  vhdlan -xlrm "$QSYS_SIMDIR/auk_dspip_avalon_streaming_source_hpfir.vhd"    
  vhdlan -xlrm "$QSYS_SIMDIR/auk_dspip_roundsat_hpfir.vhd"                   
  vhdlan -xlrm "$QSYS_SIMDIR/fir_ramp_rtl_wysiwyg.vhd"                       
  vhdlan -xlrm "$QSYS_SIMDIR/fir_ramp_rtl.vhd"                               
  vhdlan -xlrm "$QSYS_SIMDIR/fir_ramp_ast.vhd"                               
  vhdlan -xlrm "$QSYS_SIMDIR/fir_ramp.vhd"                                   
  vhdlan -xlrm "$QSYS_SIMDIR/fir_ramp_tb.vhd"                                
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $USER_DEFINED_SIM_OPTIONS
fi
