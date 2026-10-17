# gtkwave::loadFile "dump.vcd"

set all_signals [list]

lappend all_signals tb_lfm.clk
lappend all_signals tb_lfm.rst
lappend all_signals tb_lfm.cpu.pc
lappend all_signals tb_lfm.imAddr
lappend all_signals tb_lfm.imData
lappend all_signals tb_lfm.regAddr
lappend all_signals tb_lfm.regData
lappend all_signals tb_lfm.cpu.i_component
lappend all_signals tb_lfm.cpu.q_component
lappend all_signals tb_lfm.cpu.gpio_port_a
lappend all_signals tb_lfm.cpu.gpio_port_b


set num_added [ gtkwave::addSignalsFromList $all_signals ]

gtkwave::/Time/Zoom/Zoom_Full
