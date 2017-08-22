module PC( clk, rst, PCWr, NPC, PC );
           
   input         clk;
   input         rst;
   input         PCWr;
   input  [31:2] NPC;
   output [31:2] PC;
   
   reg [31:2] PC;
   
   // ANJF: for debug only
   // synopsys translate_off   
   wire [15:0] VirtualPC;
   assign VirtualPC={PC[15:2], 2'b00};
   // synopsys translate_on
               
   always @(posedge clk or posedge rst) begin
      if ( rst ) 
         PC <= 'hC00;  // 0x3000/4=0xC00 
      else if ( PCWr ) 
         PC <= NPC;
   end // end always
           
endmodule
