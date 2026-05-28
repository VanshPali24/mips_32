// ALU_decoder 
module alu_decoder(
	input [1:0] aluOp,
	input [5:0] funct,
	output reg [3:0] aluCtrl
	);
	
	always @(*) begin
		case(aluOp)
			2'b00 : aluCtrl = 4'b0010; //add
			2'b01 : aluCtrl = 4'b0110; //subtract
			default :
				casez(funct)
					6'bzz0000 : aluCtrl = 4'b0010;
					6'bzz0010 : aluCtrl = 4'b0110;
					6'bzz0100 : aluCtrl = 4'b0000; //and
					6'bzz0101 : aluCtrl = 4'b0001; //or
					6'bzz1010 : aluCtrl = 4'b0111; //slt
					default : aluCtrl = 4'b0000;
				endcase
		endcase
	end
endmodule
