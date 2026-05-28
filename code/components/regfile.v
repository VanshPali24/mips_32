// Register File consisting of 32 general purpose registers each of size 32 bits

module regfile #(parameter WIDTH = 32)(
	input 	[4:0]       regSrc1, regSrc2, wrRegNum,
	input 		[WIDTH-1:0] writeData,
	input 	            regWrite,
	input							clk,
	output 		[WIDTH-1:0] readReg1, readReg2
	);
	
	//defining the registers
	reg [WIDTH-1:0] Reg [0:31];
	
	//initialising
	integer i;
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			Reg[i] = i;
		end
	end
	
	assign readReg1 = (regSrc1 != 0) ? Reg[regSrc1] : 0;
	assign readReg2 = (regSrc2 != 0) ? Reg[regSrc2] : 0;
	
	always @(posedge clk) begin
		if(regWrite) Reg[wrRegNum] <= writeData;
	end
	
endmodule
	
	