
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# slow_clock, debounce, attractor, svga_controller

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART em.avnet.com:zed:part0:1.4 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
slow_clock\
debounce\
attractor\
svga_controller\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set BTNC [ create_bd_port -dir I BTNC ]
  set blue_out [ create_bd_port -dir O -from 3 -to 0 blue_out ]
  set green_out [ create_bd_port -dir O -from 3 -to 0 green_out ]
  set horz_sync_out [ create_bd_port -dir O horz_sync_out ]
  set red_out [ create_bd_port -dir O -from 3 -to 0 red_out ]
  set sys_clock [ create_bd_port -dir I -type clk sys_clock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   CONFIG.PHASE {0.000} \
 ] $sys_clock
  set vert_sync_out [ create_bd_port -dir O vert_sync_out ]

  # Create instance: Block_Memory, and set properties
  set Block_Memory [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 Block_Memory ]
  set_property -dict [ list \
   CONFIG.Byte_Size {9} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Enable_B {Always_Enabled} \
   CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
   CONFIG.Operating_Mode_A {NO_CHANGE} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Read_Width_A {9} \
   CONFIG.Read_Width_B {9} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
   CONFIG.Reset_Memory_Latch_B {false} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Use_RSTB_Pin {false} \
   CONFIG.Write_Depth_A {480000} \
   CONFIG.Write_Width_A {9} \
   CONFIG.Write_Width_B {9} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $Block_Memory

  # Create instance: Blue_Channel_Slice, and set properties
  set Blue_Channel_Slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Blue_Channel_Slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {8} \
   CONFIG.DIN_TO {6} \
   CONFIG.DIN_WIDTH {9} \
   CONFIG.DOUT_WIDTH {3} \
 ] $Blue_Channel_Slice

  # Create instance: Clocks, and set properties
  set Clocks [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 Clocks ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {159.371} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} \
   CONFIG.CLKOUT2_JITTER {175.402} \
   CONFIG.CLKOUT2_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {25} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {25.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {40} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {2} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $Clocks

  # Create instance: Color_Change_Clock, and set properties
  set block_name slow_clock
  set block_cell_name Color_Change_Clock
  if { [catch {set Color_Change_Clock [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Color_Change_Clock eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: Concat_Blue, and set properties
  set Concat_Blue [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 Concat_Blue ]
  set_property -dict [ list \
   CONFIG.IN1_WIDTH {3} \
 ] $Concat_Blue

  # Create instance: Concat_Color_Channels, and set properties
  set Concat_Color_Channels [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 Concat_Color_Channels ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $Concat_Color_Channels

  # Create instance: Concat_Green, and set properties
  set Concat_Green [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 Concat_Green ]
  set_property -dict [ list \
   CONFIG.IN1_WIDTH {3} \
 ] $Concat_Green

  # Create instance: Constant_One, and set properties
  set Constant_One [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 Constant_One ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
 ] $Constant_One

  # Create instance: Debouncer, and set properties
  set block_name debounce
  set block_cell_name Debouncer
  if { [catch {set Debouncer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Debouncer eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.clk_freq {25000000} \
 ] $Debouncer

  # Create instance: Green_Channel_Slice, and set properties
  set Green_Channel_Slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Green_Channel_Slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {5} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {9} \
   CONFIG.DOUT_WIDTH {3} \
 ] $Green_Channel_Slice

  # Create instance: Lorenz_Generator, and set properties
  set block_name attractor
  set block_cell_name Lorenz_Generator
  if { [catch {set Lorenz_Generator [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $Lorenz_Generator eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: Red_Channel_Slice, and set properties
  set Red_Channel_Slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 Red_Channel_Slice ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {9} \
   CONFIG.DOUT_WIDTH {3} \
 ] $Red_Channel_Slice

  # Create instance: svga_controller_1, and set properties
  set block_name svga_controller
  set block_cell_name svga_controller_1
  if { [catch {set svga_controller_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $svga_controller_1 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconcat_Red, and set properties
  set xlconcat_Red [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_Red ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {1} \
   CONFIG.IN1_WIDTH {3} \
 ] $xlconcat_Red

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create port connections
  connect_bd_net -net Debouncer_result [get_bd_pins Debouncer/result] [get_bd_pins Lorenz_Generator/reset]
  connect_bd_net -net attractor_0_address [get_bd_pins Block_Memory/addra] [get_bd_pins Lorenz_Generator/address]
  connect_bd_net -net attractor_0_blue_out [get_bd_pins Concat_Color_Channels/In2] [get_bd_pins Lorenz_Generator/blue_out]
  connect_bd_net -net attractor_0_green_out [get_bd_pins Concat_Color_Channels/In1] [get_bd_pins Lorenz_Generator/green_out]
  connect_bd_net -net attractor_0_plot [get_bd_pins Block_Memory/wea] [get_bd_pins Lorenz_Generator/plot]
  connect_bd_net -net attractor_0_red_out [get_bd_pins Concat_Color_Channels/In0] [get_bd_pins Lorenz_Generator/red_out]
  connect_bd_net -net blk_mem_gen_0_doutb [get_bd_pins Block_Memory/doutb] [get_bd_pins Blue_Channel_Slice/Din] [get_bd_pins Green_Channel_Slice/Din] [get_bd_pins Red_Channel_Slice/Din]
  connect_bd_net -net clk_wiz_clk_out1 [get_bd_pins Block_Memory/clkb] [get_bd_pins Clocks/clk_out1] [get_bd_pins svga_controller_1/clock_40]
  connect_bd_net -net clk_wiz_clk_out2 [get_bd_pins Block_Memory/clka] [get_bd_pins Clocks/clk_out2] [get_bd_pins Color_Change_Clock/clock_25] [get_bd_pins Debouncer/clk] [get_bd_pins Lorenz_Generator/clock_25]
  connect_bd_net -net sig_in_0_1 [get_bd_ports BTNC] [get_bd_pins Debouncer/button]
  connect_bd_net -net slow_clock_0_slow_clock [get_bd_pins Color_Change_Clock/slow_clock] [get_bd_pins Lorenz_Generator/slow_clock]
  connect_bd_net -net svga_controller_0_blue_out [get_bd_ports blue_out] [get_bd_pins svga_controller_1/blue_out]
  connect_bd_net -net svga_controller_0_green_out [get_bd_ports green_out] [get_bd_pins svga_controller_1/green_out]
  connect_bd_net -net svga_controller_0_horz_sync_out [get_bd_ports horz_sync_out] [get_bd_pins svga_controller_1/horz_sync_out]
  connect_bd_net -net svga_controller_0_red_out [get_bd_ports red_out] [get_bd_pins svga_controller_1/red_out]
  connect_bd_net -net svga_controller_0_vert_sync_out [get_bd_ports vert_sync_out] [get_bd_pins svga_controller_1/vert_sync_out]
  connect_bd_net -net svga_controller_1_address [get_bd_pins Block_Memory/addrb] [get_bd_pins svga_controller_1/address]
  connect_bd_net -net sys_clock_1 [get_bd_ports sys_clock] [get_bd_pins Clocks/clk_in1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins Concat_Green/dout] [get_bd_pins svga_controller_1/green]
  connect_bd_net -net xlconcat_1_dout [get_bd_pins Concat_Blue/dout] [get_bd_pins svga_controller_1/blue]
  connect_bd_net -net xlconcat_2_dout [get_bd_pins svga_controller_1/red] [get_bd_pins xlconcat_Red/dout]
  connect_bd_net -net xlconcat_3_dout [get_bd_pins Block_Memory/dina] [get_bd_pins Concat_Color_Channels/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins Clocks/reset] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins Concat_Blue/In0] [get_bd_pins Concat_Green/In0] [get_bd_pins xlconcat_Red/In0] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins Constant_One/dout] [get_bd_pins Debouncer/reset_n]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins Red_Channel_Slice/Dout] [get_bd_pins xlconcat_Red/In1]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins Concat_Green/In1] [get_bd_pins Green_Channel_Slice/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins Blue_Channel_Slice/Dout] [get_bd_pins Concat_Blue/In1]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


