## This file is a constraints file for the Nexys 4 DDR board.
## It has been adapted for the Verilog module "topModule".

## Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports {clk}];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk}];

## Switches (16 total for the 'instr' input)
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports {instr[0]}];  # SW0
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports {instr[1]}];  # SW1
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports {instr[2]}];  # SW2
set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports {instr[3]}];  # SW3
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports {instr[4]}];  # SW4
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports {instr[5]}];  # SW5
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {instr[6]}];  # SW6
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports {instr[7]}];  # SW7
set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS33 } [get_ports {instr[8]}];  # SW8
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports {instr[9]}];  # SW9
set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports {instr[10]}]; # SW10
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports {instr[11]}]; # SW11
set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports {instr[12]}]; # SW12
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports {instr[13]}]; # SW13
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports {instr[14]}]; # SW14
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports {instr[15]}]; # SW15

## LEDs (16 total for the 'out' bus)
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports {out[0]}];   # LED0
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports {out[1]}];   # LED1
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports {out[2]}];   # LED2
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports {out[3]}];   # LED3
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports {out[4]}];   # LED4
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {out[5]}];   # LED5
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports {out[6]}];   # LED6
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {out[7]}];   # LED7
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {out[8]}];   # LED8
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33 } [get_ports {out[9]}];   # LED9
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {out[10]}];  # LED10
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports {out[11]}];  # LED11
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {out[12]}];  # LED12
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {out[13]}];  # LED13
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports {out[14]}];  # LED14
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports {out[15]}];  # LED15

## Buttons
# We will use BTNC for reset and BTNU for execution (btn)
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {rst}];  # BTNC (Used as Reset)
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports {btn}];  # BTNU (Used as Execute Button)
