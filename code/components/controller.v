// Controller
module controller#(parameter WIDTH = 32)(
	input  [WIDTH-1:0] instr,
	output 		 regDst, regWrite, aluSrc, memWrite, memtoReg, branch,
	output [3:0] aluCtrl,
	output memRead
	);
	
	wire [1:0] aluOp;
	//instantiating main decoder
	main_decoder	MD(instr[31:26], regDst, regWrite, aluSrc, memWrite, memtoReg, branch, aluOp, memRead);
	
	//instantiating alu decoder
	alu_decoder		AD(aluOp, instr[5:0], aluCtrl);
	
endmodule
