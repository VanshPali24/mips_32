// Instruction Memory of 64 32-bit words
module instrMem #(parameter ADDR_WIDTH = 32, INSTR_SIZE = 32, MEM_SIZE = 64)(
	input  [ADDR_WIDTH-1:0] addr,
	output [INSTR_SIZE-1:0] instr
	);
	
	reg [INSTR_SIZE-1:0] instrMemory[0:MEM_SIZE-1];
	
	integer i;
	initial begin
		for (i =0;i< MEM_SIZE-1;i=i+1) begin
			instrMemory[i] = 0;
		end
		$readmemh("instrhazard_1.hex", instrMemory);
	end
	
	assign instr = instrMemory[addr[7:2]];
		
endmodule 