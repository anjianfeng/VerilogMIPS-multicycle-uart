# Sample program for UART
ori $a0, $0, 'M'   # send a char 
jal send
ori $a0, $0, 'I'   # send a char 
jal send
ori $a0, $0, 'P'   # send a char 
jal send
ori $a0, $0, 'S'   # send a char 
jal send

loop:jal receive
jal send
j loop

send: # $a0 stores the char
loop1: lw $t0, 0x7f10     # read the tx_busy  
bne $t0, $0, loop1
sw $a0, 0x7f00     
loop2: lw $t0, 0x7f10     # read the tx_busy   
beq $t0, $0, loop2
loop3: lw $t0, 0x7f10     # read the tx_busy  
bne $t0, $0, loop3
jr $ra

receive: # $a0 stores the char
loop11: lw $t0, 0x7f14     # read the rx_busy   
beq $t0, $0, loop11
loop12: lw $t0, 0x7f14     # read the rx_busy   
bne $t0, $0, loop12
lw $a0, 0x7f04 
jr $ra
 




