module branchFlush (
	input branch, zero,
	output ID_EX_flush, EX_MEM_flush
	);
	
	reg ID_EX_flush_reg, EX_MEM_flush_reg;
	
	always @(*) begin
		if(branch && zero) begin
			ID_EX_flush_reg = 1;
			EX_MEM_flush_reg = 1;
		end
		else begin
			ID_EX_flush_reg = 0;
			EX_MEM_flush_reg = 0;
		end
	end
	
	assign ID_EX_flush = ID_EX_flush_reg;
	assign EX_MEM_flush = EX_MEM_flush_reg;
	
endmodule
		
			