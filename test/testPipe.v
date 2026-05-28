module tb_mipshazard;
	
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
				"time = %0d | PC=%h | R1=%0d R2=%0d R20=%0d R29=%0d R30=%0d rsReg_ID_EX=%0d rtReg_ID_EX=%0d rdReg_ID_EX=%0d WrReg_EX_MEM=%0d frwdA=%2b frwdB=%2b",
			$time,
			dut.d.PC,
			dut.d.Registerfile.Reg[1],
			dut.d.Registerfile.Reg[2],
			dut.d.Registerfile.Reg[20],
			dut.d.Registerfile.Reg[29],
			dut.d.Registerfile.Reg[30],
			dut.d.rsReg_ID_EX,
			dut.d.rtReg_ID_EX,
			dut.d.rdReg_ID_EX,
			dut.d.WrReg_EX_MEM,
			dut.d.forwardA,
			dut.d.forwardB
			);
		end
    end

endmodule

