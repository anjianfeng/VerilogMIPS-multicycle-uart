module mips( clk, rst_in, uart_rx, uart_tx, led );
   input   clk;
   input   rst_in;
   input   uart_rx;
   output  uart_tx;
   output  led;
   
   wire 		     RFWr;
   wire 		     DMWr;
   wire 		     PCWr;
   wire 		     IRWr;
   wire [1:0]  EXTOp;
   wire [4:0]  ALUOp;
   wire [1:0]  NPCOp;
   wire [1:0]  GPRSel;
   wire [1:0]  WDSel;
   wire 		   BSel;
   wire 		   Zero;
   wire [29:0] PC, NPC;
   wire [31:0] im_dout, dm_dout;
   wire [31:0] DR_out;
   wire [31:0] instr;
   wire [4:0]  rs;
   wire [4:0]  rt;
   wire [4:0]  rd;
   wire [5:0]  Op;
   wire [5:0]  Funct;
   wire [15:0] Imm16; 
   wire [31:0] Imm32;
   wire [25:0] IMM;
   wire [4:0]  A3;
   wire [31:0] WD;
   wire [31:0] RD1, RD1_r, RD2, RD2_r;
   wire [31:0] A, B, C, C_r;
   reg   led;
   
   assign Op = instr[31:26];
   assign Funct = instr[5:0];
   assign rs = instr[25:21];
   assign rt = instr[20:16];
   assign rd = instr[15:11];
   assign Imm16 = instr[15:0];
   assign IMM = instr[25:0]; 
   
  reg rst1,rst2,rst;
  always @(posedge clk) begin
	   rst1<=rst_in;
	   rst2<=rst1;
	   rst<=~rst2;
	end
	//assign rst=~rst_in;
	
	always @(posedge clk) begin
	  if (rst)
	    led<=1'b0;
	  else
	    led<=1'b1;
	end
   

   ctrl U_CTRL (
      .clk(clk),	.rst(rst), .Zero(Zero), .Op(Op),  .Funct(Funct),
      .RFWr(RFWr),   .DMWr(DMWr),   .PCWr(PCWr),   .IRWr(IRWr),
      .EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), .GPRSel(GPRSel),
      .WDSel(WDSel), .ASel(ASel), .BSel(BSel),.instr(instr)
   );
   
   PC U_PC (
      .clk(clk), .rst(rst), .PCWr(PCWr), .NPC(NPC), .PC(PC)
   ); 
   
   NPC U_NPC ( 
      .PC(PC), .NPCOp(NPCOp), .IMM(IMM), .NPC(NPC), .Zero(Zero), .instr(instr), .A(A)
   );
   
   IM U_IM ( 
      .clka(clk),.addra(PC[7:0]) , .douta(im_dout)
   );
   
   IR U_IR ( 
      .clk(clk), .rst(rst), .IRWr(IRWr), .im_dout(im_dout), .instr(instr)
   );
   
   RF U_RF (
      .A1(rs), .A2(rt), .A3(A3), .WD(WD), .clk(clk), 
      .RFWr(RFWr), .RD1(RD1), .RD2(RD2)
   );
   
   mux4 #(5) U_MUX4_GPR_A3 (
      .d0(rd), .d1(rt), .d2(5'd31), .d3(/*undefine*/5'd0),
      .s(GPRSel), .y(A3)
   );

   mux4 #(32) U_MUX4_GPR_WD (
      .d0(C_r), .d1(DR_out), .d2({PC,2'b00}), .d3(/*undefine*/32'd0),
      .s(WDSel), .y(WD)
   );
   
   flopr #(32) U_RD1_Reg (
      .clk(clk), .rst(rst), .d(RD1), .q(RD1_r)
   );
   
   flopr #(32) U_RD2_Reg (
      .clk(clk), .rst(rst), .d(RD2), .q(RD2_r)
   );
   
   EXT U_EXT ( 
      .Imm16(Imm16), .EXTOp(EXTOp), .Imm32(Imm32) 
   );
   
   mux2 #(32) U_MUX_ALU_A (
      .d0(RD1_r), .d1({27'b0, instr[10:6]}), .s(ASel) , .y(A)
   );
   
   mux2 #(32) U_MUX_ALU_B (
      .d0(RD2_r), .d1(Imm32), .s(BSel) , .y(B)
   );
   
   alu U_ALU ( 
      .A(A), .B(B), .ALUOp(ALUOp), .C(C), .Zero(Zero)
   );
   
   flopr #(32) U_ALUOut (
      .clk(clk), .rst(rst), .d(C), .q(C_r)
   );
   
   DMUART U_DMUART ( 
      .addra(C_r), .dina(RD2_r), .wea(DMWr), .clk(clk), .douta(dm_dout),
      . uart_rx(uart_rx),. uart_tx(uart_tx), .rst(rst)
   );
   
   flopr #(32) U_DR (
      .clk(clk), .rst(rst), .d(dm_dout), .q(DR_out)
   );

endmodule