module tb_mipshazard_2;
	
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
				"time = %0d | PC=%h | Mem[22]=%0d R6=%0d R7=%0d R9=%0d R17=%0d rsReg_ID_EX=%0d rtReg_ID_EX=%0d rdReg_ID_EX=%0d WrReg_EX_MEM=%0d frwdA=%2b frwdB=%2b frwdC=%b frwdD=%b, load_use_stall=%b",
			$time,
			dut.d.PC,
			dut.d.dm.dataMemory[22],
			dut.d.Registerfile.Reg[6],
			dut.d.Registerfile.Reg[7],
			dut.d.Registerfile.Reg[9],
			dut.d.Registerfile.Reg[17],
			dut.d.rsReg_ID_EX,
			dut.d.rtReg_ID_EX,
			dut.d.rdReg_ID_EX,
			dut.d.WrReg_EX_MEM,
			dut.d.forwardA,
			dut.d.forwardB,
			dut.d.forwardC,
			dut.d.forwardD,
			dut.d.ID_EX_stall_flush
			);
		end
    end

endmodule

