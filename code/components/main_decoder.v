// Main decoder
module main_decoder #(parameter WIDTH = 32)(
	input  [5:0] opcode,
	output 		 regDst, regWrite, aluSrc, memWrite, memtoReg, branch,
	output [1:0] aluOp,
	output memRead
	);
	
	reg [8:0] controls;
	
	always @(*) begin
		case(opcode)
							//regDst_regWrite_aluSrc_aluOp_memWrite_memtoReg_branch_memRead
			6'b000000 : controls = 9'b1_1_0_10_0_0_0_0; // R-type Instr
			6'b100011 : controls = 9'b0_1_1_00_0_1_0_1; // Load
			6'b101011 : controls = 9'b0_0_1_00_1_0_0_0; // Store
			6'b000100 : controls = 9'b0_0_0_01_0_0_1_0; // Beq
			6'b000010 : controls = 9'b0_0_0_00_0_0_0_0; // Jump
			default : controls = 9'b0_0_0_00_0_0_0_0;
		endcase
	end
	
	assign {regDst, regWrite, aluSrc, aluOp, memWrite, memtoReg, branch, memRead} = controls;
endmodule
			
	