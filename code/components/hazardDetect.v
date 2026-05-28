//Hazard Detection Unit for Stalling
module HDU(
	input ID_EX_memRead,
	input [4:0] regRt_ID_EX, regRs_IF_ID, regRt_IF_ID,
	output flush_ID_EX
	);
	reg flush_ID_EX_reg;
	
	always @(*) begin
		
		if(ID_EX_memRead && ( (regRt_ID_EX == regRs_IF_ID) || (regRt_ID_EX == regRt_IF_ID))) flush_ID_EX_reg = 1;
		else flush_ID_EX_reg = 0;
	
	end
	
	assign flush_ID_EX = flush_ID_EX_reg;

endmodule
	