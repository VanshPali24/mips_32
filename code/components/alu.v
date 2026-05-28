// ALU 
module alu #(parameter WIDTH = 32)(
	input   [WIDTH-1:0] srcA,
	input 	  [WIDTH-1:0] srcB,
	input   [3:0]       aluCtrl,
	output     [WIDTH-1:0] aluWire,
	output 					  zero
	);
	reg [WIDTH-1:0] aluOut;
	assign aluWire = aluOut;
	always @(*) begin
		case(aluCtrl)
			4'b0000 : aluOut = srcA & srcB; // and
			4'b0001 : aluOut = srcA | srcB; // or
			4'b0010 : aluOut = srcA + srcB; // add
			4'b0110 : aluOut = srcA + ~srcB + 1; // sub
			4'b0111 : aluOut = (srcA < srcB) ? 1 : 0; // slt
			default : aluOut = 0;
		endcase
	end
	
	assign zero = (aluOut == 0) ? 1'b1 : 1'b0;
endmodule