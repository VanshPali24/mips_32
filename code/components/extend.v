// Extend block 
module extend (
	input   [15:0] instr,
	output     [31:0] ext_addr
	);

	assign ext_addr = {{16{instr[15]}}, instr[15:0]};

endmodule
	
	