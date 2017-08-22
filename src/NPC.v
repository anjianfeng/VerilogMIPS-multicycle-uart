`include "ctrl_encode_def.v"
`include "instruction_def.v"
module NPC( PC, NPCOp, IMM, NPC, Zero, instr, A );
    
   input  [31:2] PC;
   input  [1:0]  NPCOp;
   input  [25:0] IMM;
   output [31:2] NPC;
   input Zero;
   input [31:0] instr;
   input [31:0] A;
   
   reg [31:2] NPC;
   
   always @(*) begin
      NPC = PC + 1;
      case (NPCOp)
          `NPC_PLUS4: NPC = PC + 1;
          `NPC_BRANCH: 
            if (Zero==1'b1)
                NPC = PC + {{14{IMM[15]}}, IMM[15:0]};
            else
                NPC = PC + 1;
          `NPC_JUMP: begin
            NPC = {PC[31:28], IMM[25:0]};
            if (
                ((instr[31:26]==`INSTR_RTYPE_OP)&&(instr[5:0]==`INSTR_JR_FUNCT))
                ||
                ((instr[31:26]==`INSTR_RTYPE_OP)&&(instr[5:0]==`INSTR_JALR_FUNCT))
                )
                NPC = {2'b00, A[31:2]};
          end
          default: ;
      endcase
   end // end always
   
endmodule
