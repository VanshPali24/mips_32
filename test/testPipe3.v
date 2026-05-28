module tb_mipshazard_3;
	
    reg clk;
    reg reset;

    mipsHazard dut(clk, reset);
    
    always #5 clk = ~clk;

    initial begin
	
	clk = 0;
	reset = 1;

	#20;
	reset = 0;
	
	#200;
	$stop;
    end

    always @(posedge clk) begin
		if (!reset) begin
			 $display(
				"time = %0d | PC=%h | R2=%0d R5=%0d R8=%0d R12=%0d EX_MEM_flush = %0d ID_EX_flush = %0d branch = %0d zero = %0d",
			$time,
			dut.d.PC,
			dut.d.Registerfile.Reg[2],
			dut.d.Registerfile.Reg[5],
			dut.d.Registerfile.Reg[8],
			dut.d.Registerfile.Reg[12],
			dut.d.EX_MEM_flush,
			dut.d.ID_EX_flush,
			dut.d.branch_EX_MEM, 
			dut.d.zero_EX_MEM
			);
		end
    end

endmodule

