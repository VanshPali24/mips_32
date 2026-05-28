// Data Memory consisting of 64 32-bit words/data
module dataMem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64)(
	input   [ADDR_WIDTH-1:0] addr,
	input   [DATA_WIDTH-1:0] writeData,
	input                   memWrite,
   input 							clk,
	output [DATA_WIDTH-1:0] data
	);
	
	reg [DATA_WIDTH-1:0] dataMemory [0:MEM_SIZE-1];
	
	assign data = dataMemory[addr[7:2]]; // memory is word addressable, address is byte addressable
													 // addr[7:2] as memory size is 64 words
	always @(posedge clk) begin
		if (memWrite) dataMemory[addr[7:2]] <= writeData;
	end
endmodule
	