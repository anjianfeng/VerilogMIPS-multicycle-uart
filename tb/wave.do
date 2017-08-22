onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate {/mips_tb/U_MIPS/U_RF/rf[8]}
add wave -noupdate {/mips_tb/U_MIPS/U_RF/rf[31]}
add wave -noupdate /mips_tb/U_MIPS/U_PC/VirtualPC
add wave -noupdate /mips_tb/U_MIPS/U_RF/rf
add wave -noupdate /mips_tb/U_MIPS/U_ALU/A
add wave -noupdate /mips_tb/U_MIPS/U_ALU/B
add wave -noupdate /mips_tb/U_MIPS/U_ALU/C
add wave -noupdate /mips_tb/U_MIPS/U_ALU/ALUOp
add wave -noupdate /mips_tb/U_MIPS/U_ALU/Zero
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/clk
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/rst
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/Zero
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/Op
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/Funct
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/state
add wave -noupdate /mips_tb/U_MIPS/U_IR/instr
add wave -noupdate /mips_tb/U_MIPS/U_PC/VirtualPC
add wave -noupdate /mips_tb/U_MIPS/U_PC/PC
add wave -noupdate -divider IM
add wave -noupdate /mips_tb/U_MIPS/U_IM/clka
add wave -noupdate /mips_tb/U_MIPS/U_IM/addra
add wave -noupdate /mips_tb/U_MIPS/U_IM/douta
add wave -noupdate -divider IR
add wave -noupdate /mips_tb/U_MIPS/U_IR/clk
add wave -noupdate /mips_tb/U_MIPS/U_IR/rst
add wave -noupdate /mips_tb/U_MIPS/U_IR/IRWr
add wave -noupdate /mips_tb/U_MIPS/U_IR/im_dout
add wave -noupdate /mips_tb/U_MIPS/U_PC/VirtualPC
add wave -noupdate /mips_tb/U_MIPS/U_IR/instr
add wave -noupdate -divider DMUART
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/clk
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/rst
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/wea
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/addra
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/dina
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/douta
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/uart_rx
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/uart_tx
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/dm_wea
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/tx_wr
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/dm_dout
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/rx_data
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/rx_done
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/tx_done
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/rx_busy
add wave -noupdate /mips_tb/U_MIPS/U_DMUART/tx_busy
add wave -noupdate /mips_tb/U_MIPS/led
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/RType
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/IType
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/BrType
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/JType
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/LdType
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/StType
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/MemType
add wave -noupdate -divider NPC
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/state
add wave -noupdate /mips_tb/U_MIPS/U_NPC/PC
add wave -noupdate /mips_tb/U_MIPS/U_NPC/NPCOp
add wave -noupdate /mips_tb/U_MIPS/U_NPC/IMM
add wave -noupdate /mips_tb/U_MIPS/U_NPC/NPC
add wave -noupdate /mips_tb/U_MIPS/U_NPC/Zero
add wave -noupdate /mips_tb/U_MIPS/U_NPC/instr
add wave -noupdate /mips_tb/U_MIPS/U_NPC/A
add wave -noupdate /mips_tb/U_MIPS/U_CTRL/PCWr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1652860 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 138
configure wave -valuecolwidth 130
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {308928 ps} {2368460 ps}
