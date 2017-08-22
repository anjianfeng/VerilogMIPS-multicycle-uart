 `timescale 1ns/1ps

module mips_tb();
    
   reg clk, rst;
    
   mips U_MIPS(
      .clk(clk), .rst_in(rst), .uart_rx(uart_tx), 
      .uart_tx(uart_tx), .led(led)
   );
    
   initial begin
      // Removed if you use the Xilinx IP
      //$readmemh( "code.txt" , U_MIPS.U_IM.imem ) ;
      $monitor("PC = 0x%8X, IR = 0x%8X", U_MIPS.U_PC.PC, U_MIPS.instr ); 
      clk = 1 ;
      rst = 0 ;
      #500 ;
      rst = 0 ;
      #20 ;
      rst = 1 ;
      #2000 ;      
      rst = 1 ;
      #200 ;      
      rst = 1 ;
   end
   
   always
	   #(50) clk = ~clk;
   
endmodule
