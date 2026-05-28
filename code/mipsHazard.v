//top level module 

module mipsHazard #(parameter WIDTH = 32)(
	input clk, reset
	);
	wire [WIDTH-1:0] PC, instr, Result;
	
	//datapath
	datapath_pipe d(clk, reset, instr, PC, Result);
	
	//instruction memory
	instrMem InstMem(PC, instr);

endmodule