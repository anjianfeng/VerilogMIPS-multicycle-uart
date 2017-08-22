`include "ctrl_encode_def.v"
`include "instruction_def.v"
module ctrl(clk,	rst, Zero, Op, Funct,
            RFWr, DMWr, PCWr, IRWr,
            EXTOp, ALUOp, NPCOp, GPRSel,
            WDSel, BEOp, ASel, BSel, instr);
    
   input 		     clk, rst, Zero;       
   input  [5:0] Op;
   input  [5:0] Funct;
   output       RFWr;
   output       DMWr;
   output       PCWr;
   output       IRWr;
   output [1:0] EXTOp;
   output [4:0] ALUOp;
   output [1:0] NPCOp;
   output [1:0] GPRSel;
   output [1:0] WDSel;
   output [1:0] BEOp;
   output       ASel, BSel; 
   input [31:0] instr;
    
   parameter Fetch  = 4'b0000,
             Fetch2 = 4'b1111,
             DCD    = 4'b0001,
             Exe    = 4'b0010,
             MA     = 4'b0011,
             Branch = 4'b0100,
             Jmp    = 4'b0101,
             MR     = 4'b0110,
             MW     = 4'b0111,
             WB     = 4'b1000,
             MemWB  = 4'b1001;
    
	
   wire RType;   // Type of R-Type Instruction
   wire IType;   // Tyoe of Imm    Instruction  
   wire BrType;  // Type of Branch Instruction
   wire JType;   // Type of Jump   Instruction
   wire LdType;  // Type of Load   Instruction
   wire StType;  // Type of Store  Instruction
   wire MemType; // Type pf Memory Instruction(Load/Store)
	
   assign RType   = (Op == `INSTR_RTYPE_OP);
   assign IType   = (Op == `INSTR_ORI_OP  )
   || (Op == `INSTR_LUI_OP   ) 
   || (Op == `INSTR_ADDI_OP   )
   || (Op == `INSTR_ADDIU_OP)
   || (Op == `INSTR_XORI_OP)
   || (Op == `INSTR_ANDI_OP)
   || (Op == `INSTR_ORI_OP)
   || (Op == `INSTR_SLTI_OP)
   || (Op == `INSTR_SLTIU_OP)
   ;
   assign BrType  = (Op == `INSTR_BEQ_OP  )||(Op == `INSTR_BNE_OP  )||(Op == `INSTR_BLEZ_OP  )||(Op == `INSTR_BGTZ_OP  )
   ||(Op == `INSTR_BLTZ_OP  )||(Op == `INSTR_BGEZ_OP  );
   assign JType   = (Op == `INSTR_JAL_OP  )||(Op == `INSTR_J_OP  )
    ||((Funct == `INSTR_JR_FUNCT)&&(Op == `INSTR_RTYPE_OP)  )
    ||((Funct == `INSTR_JALR_FUNCT)&&(Op == `INSTR_RTYPE_OP)  )
    ;
   assign LdType  = (Op == `INSTR_LW_OP   )|| (Op == `INSTR_LB_OP   )|| (Op == `INSTR_LH_OP   )||
   (Op == `INSTR_LBU_OP   )|| (Op == `INSTR_LHU_OP   );
   assign StType  = (Op == `INSTR_SW_OP   )||(Op == `INSTR_SH_OP   )||(Op == `INSTR_SB_OP   )  ;
   assign MemType = LdType || StType;
    
	/*************************************************/
	/******               FSM                   ******/
   reg [3:0] nextstate;
   reg [3:0] state;
   
   always @(posedge clk or posedge rst) begin
	   if ( rst )
		   state <= Fetch;
      else
         state <= nextstate;
	end // end always
             
   always @(*) begin
      nextstate = state;
      case (state)
         Fetch: nextstate = Fetch2;
         Fetch2: nextstate = DCD;
         DCD: begin
            if ( RType || IType ) begin 
				   nextstate = Exe;
				   if ( ((Funct == `INSTR_JR_FUNCT)&&(Op == `INSTR_RTYPE_OP)  )
                         ||((Funct == `INSTR_JALR_FUNCT)&&(Op == `INSTR_RTYPE_OP)) )
                   nextstate = Jmp;
	        end
            else if ( MemType ) 
               nextstate = MA;
            else if ( BrType )
               nextstate = Branch;
            else if ( JType )
               nextstate = Jmp;
            else   //if Op wrong, then fetch next one.
               nextstate = Fetch;
         end
         Exe:  nextstate = WB;
         MA: begin 
            if ( LdType )
				   nextstate = MR;   //LW
            else if ( StType )
					nextstate = MW;   //SW
			end
         Branch: nextstate = Fetch;
         Jmp: 	nextstate = Fetch;
         MR:   nextstate = MemWB;
         MW:   nextstate = Fetch;
         WB: 	 nextstate = Fetch;
         MemWB: nextstate = Fetch;      
			default: ;
       endcase
   end // end always
	
	
	/*************************************************/
	/******         Control Signal              ******/
	reg       RFWr;
   reg       DMWr;
   reg       PCWr;
   reg       IRWr;
   reg [1:0] EXTOp;
   reg [4:0] ALUOp;
   reg [1:0] NPCOp;
   reg [1:0] GPRSel;
   reg [1:0] WDSel;
   reg [1:0] BEOp;
   reg       ASel, BSel;
   
	always @( * ) begin    
	   ASel   = 1'b0;
	   if (((Funct==`INSTR_SRA_FUNCT)|| (Funct==`INSTR_SRL_FUNCT)  ||(Funct==`INSTR_SLL_FUNCT)  )  &&(Op == `INSTR_RTYPE_OP)) 
               ASel   = 1'b1;
            else
               ASel   = 1'b0;
    end
	
	always @( * ) begin
	   
      PCWr   = 1'b0;
      NPCOp  = `NPC_PLUS4; 
      IRWr   = 1'b0;
      RFWr  = 1'b0;
      DMWr   = 1'b0;
      EXTOp  = 0;
      GPRSel = 0;
      WDSel  = 0;
      BSel   = 0;
      ALUOp  = 0;
            
     case ( state ) 
		   Fetch2: begin
            PCWr   = 1'b1;
            NPCOp  = `NPC_PLUS4; 
            IRWr   = 1'b1;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            EXTOp  = 0;
            GPRSel = 0;
            WDSel  = 0;
            BSel   = 0;
            ALUOp  = 0;
			end // end Fetch
         DCD: begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            EXTOp  = 0;
            GPRSel = 0;
            WDSel  = 0;
            BSel   = 0;
            ALUOp  = 0;
			end	// end DCD
         Exe: 	begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            if ( (Op == `INSTR_ORI_OP)
            
            )
               EXTOp = `EXT_ZERO;
            else if (Op == `INSTR_LUI_OP)
               EXTOp = `EXT_HIGHPOS;
            else if ((Op == `INSTR_ADDI_OP)
            || (Op == `INSTR_ADDIU_OP)
            )
               EXTOp = `EXT_SIGNED;
            else
               EXTOp = 0;
            GPRSel = 0;
            WDSel  = 0;
            DMWr   = 0;
            if (IType)
               BSel   = 1'b1;
            else
               BSel   = 1'b0;
           
          
           
           
            if (Op == `INSTR_ORI_OP)
               ALUOp = `ALUOp_OR;
            else if ( Op == `INSTR_RTYPE_OP ) 
               case (Funct)
                   // Todo
                   `INSTR_ADDU_FUNCT: ALUOp = `ALUOp_ADDU;
                   `INSTR_SUBU_FUNCT: ALUOp = `ALUOp_SUBU;
                   `INSTR_ADD_FUNCT: ALUOp = `ALUOp_ADD;
                   `INSTR_SUB_FUNCT: ALUOp = `ALUOp_SUB;
                   `INSTR_XOR_FUNCT: ALUOp = `ALUOp_XOR;
                   `INSTR_OR_FUNCT: ALUOp = `ALUOp_OR;                   
                   `INSTR_NOR_FUNCT: ALUOp = `ALUOp_NOR;
                   `INSTR_AND_FUNCT: ALUOp = `ALUOp_AND;
                   `INSTR_SLL_FUNCT: ALUOp = `ALUOp_SLL;                   
                   `INSTR_SLLV_FUNCT: ALUOp = `ALUOp_SLL;               
                   `INSTR_SLT_FUNCT: ALUOp = `ALUOp_SLT;                     
                   `INSTR_SLTU_FUNCT: ALUOp = `ALUOp_SLTU;       
                   `INSTR_SRA_FUNCT: ALUOp = `ALUOp_SRA;   
                   `INSTR_SRAV_FUNCT: ALUOp = `ALUOp_SRA;        
                   `INSTR_SRL_FUNCT: ALUOp = `ALUOp_SRL;  
                   `INSTR_SRLV_FUNCT: ALUOp = `ALUOp_SRL;                     
                   //TODO: break, div, divu, jalr, jr, mfhi, mlfo, mthi, mtlo, mult,multu, systemcall
                   default: ;
               endcase
            
            else if ( Op == `INSTR_ADDIU_OP ) 
               ALUOp = `ALUOp_ADDU;
            else if ( Op == `INSTR_ADDI_OP ) 
               ALUOp = `ALUOp_ADD;   
            else if ( Op == `INSTR_ANDI_OP ) 
               ALUOp = `ALUOp_AND;   
            else if ( Op == `INSTR_XORI_OP ) 
               ALUOp = `ALUOp_XOR;   
            else if ( Op == `INSTR_SLTI_OP ) 
               ALUOp = `ALUOp_SLT;   
            else if ( Op == `INSTR_SLTIU_OP ) 
               ALUOp = `ALUOp_SLTU;   
            else if ( Op == `INSTR_XORI_OP ) 
               ALUOp = `ALUOp_XOR;   
            
            //anjf
            BEOp = 2'b00;
			end // end Exe
         MA: begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            EXTOp  = `EXT_SIGNED;
            GPRSel = 0;
            WDSel  = 0;
            BSel   = 1'b1;
            ALUOp  = `ALUOp_ADDU;
			end // end MA
         Branch: begin
            if (Zero) 
               PCWr = 1'b1;
            else
               PCWr = 1'b0;
            NPCOp  = `NPC_BRANCH;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            EXTOp  = `EXT_SIGNED;
            GPRSel = 0;
            WDSel  = 0;
            BSel   = 1'b0;
            //ALUOp  = 0;
            if (Op == `INSTR_BEQ_OP  )
                ALUOp  =`ALUOp_EQL;
            else if (Op == `INSTR_BNE_OP  )
                ALUOp  =`ALUOp_BNE;
            else if (Op == `INSTR_BLEZ_OP  )
                ALUOp  =`ALUOp_LE0;
            else if (Op == `INSTR_BGTZ_OP  )
                ALUOp  =`ALUOp_GT0;
            else if ((Op == `INSTR_BLTZ_OP  )&&(instr[16]==1'b0))
                ALUOp  =`ALUOp_LT0;
            else if ( (Op == `INSTR_BGEZ_OP  )&&(instr[16]==1'b1))
                ALUOp  =`ALUOp_GE0;
			end // end Branch
         Jmp: 	begin
            PCWr   = 1'b1;
            NPCOp  = `NPC_JUMP;
            IRWr   = 1'b0;
            RFWr  = 1'b1;
            DMWr   = 1'b0;
            EXTOp  = `EXT_SIGNED;
            GPRSel = `GPRSel_31;
            WDSel  = `WDSel_FromPC;
            BSel   = 0;
            ALUOp  = 0;
			end // end Jmp
         MR:  begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            EXTOp  = 0;
            GPRSel = 0;
            WDSel  = 0;
            //BSel   = 0;
            BSel   = 1'b1;
            ALUOp  = 0;
			end // end MR
         MW:  begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b1;
            EXTOp  = 0;
            GPRSel = 0;
            WDSel  = 0;
            //BSel   = 0;
            BSel   = 1'b1;
            ALUOp  = 0;
			end // end MW
         WB: 	begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b1;
            DMWr   = 1'b0;
            EXTOp  = 0;
            if (IType)
               GPRSel = `GPRSel_RT;
            else
               GPRSel = `GPRSel_RD;
            WDSel  = `WDSel_FromALU;
            BSel   = 0;
            ALUOp  = 0;
			end // end WB
         MemWB: begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b1;
            DMWr   = 1'b0;
            EXTOp  = 0;
            GPRSel = `GPRSel_RT;
            WDSel  = `WDSel_FromMEM;
            //BSel   = 0;
            BSel   = 1'b1;
            ALUOp  = 0;
			end // end MemWB
		default: begin
            PCWr   = 1'b0;
            NPCOp  = 0;
            IRWr   = 1'b0;
            RFWr  = 1'b0;
            DMWr   = 1'b0;
            EXTOp  = 0;
            GPRSel = 0;
            WDSel  = 0;
            BSel   = 0;
            ALUOp  = 0;
			end // end default
	   endcase
   end // end always
    
endmodule
