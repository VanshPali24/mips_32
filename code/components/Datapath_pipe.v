// Pipelined Datapath
module datapath_pipe #(parameter WIDTH = 32)(
	input clk, reset,
	input [WIDTH-1:0] instr,
	output [WIDTH-1:0] PC,
	output [WIDTH-1:0] Result
	);
	
	wire [WIDTH-1:0] PCNext, PCInter, PCplus4, imm_extend, ReadData, ReadReg2, ReadReg1, SrcA, SrcB, aluResult, branchTarget, forwardReg2, DataRead1, DataRead2;
	wire [3:0] aluCtrl;
	wire regDst, regWrite, aluSrc, memWrite, memtoReg, branch, zero, ID_EX_stall_flush, ID_EX_flush, EX_MEM_flush, memRead;
	wire [4:0] WrReg;
	wire [1:0] forwardA, forwardB;
	wire forwardC, forwardD;
	
	reg [4:0] rsReg_IF_ID, rtReg_IF_ID, rdReg_IF_ID;
	reg [15:0] Imm_IF_ID;
	reg [WIDTH-1:0] PCplus4_IF_ID, instr_IF_ID;
	
	reg [4:0] rtReg_ID_EX, rdReg_ID_EX, rsReg_ID_EX;
	reg [WIDTH-1:0] PCplus4_ID_EX, ReadReg2_ID_EX, ReadReg1_ID_EX, left_shift_Imm_extend_ID_EX, Imm_extend_ID_EX;
	reg aluSrc_ID_EX, regWrite_ID_EX, memtoReg_ID_EX, branch_ID_EX, memWrite_ID_EX, regDst_ID_EX, memRead_ID_EX;
	reg [3:0] aluCtrl_ID_EX;
	
	reg [WIDTH-1:0] branchTarget_EX_MEM, aluResult_EX_MEM, ReadReg2_EX_MEM;
	reg branch_EX_MEM, zero_EX_MEM, memWrite_EX_MEM, regWrite_EX_MEM, memtoReg_EX_MEM;
	reg [4:0] WrReg_EX_MEM;
	
	reg [4:0] WrReg_MEM_WB;
	reg regWrite_MEM_WB, memtoReg_MEM_WB;
	reg [WIDTH-1:0] aluResult_MEM_WB, ReadData_MEM_WB;
	
	// IF stage- PC, PC+4, IF/ID Reg
	
	mux2#(32)	branchMux(PCplus4, branchTarget_EX_MEM, branch_EX_MEM & zero_EX_MEM, PCInter);
	mux2#(32)	stallMux(PCInter, PC, ID_EX_stall_flush, PCNext); 
	ff_rst#(32) PCreg(clk, reset, PCNext, PC);
	adder			Pcadd(PC, 4, PCplus4);
	
	always @(posedge clk) begin
		
		if (reset || ID_EX_flush) begin
			PCplus4_IF_ID <= 0;
			instr_IF_ID <= 0;
			rsReg_IF_ID <= 0;
			rtReg_IF_ID <= 0;
			rdReg_IF_ID <= 0;
			Imm_IF_ID <= 0;
		end
		
		else if(ID_EX_stall_flush == 0) begin
			PCplus4_IF_ID <= PCplus4;
			instr_IF_ID <= instr;
			rsReg_IF_ID <= instr[25:21];
			rtReg_IF_ID <= instr[20:16];
			rdReg_IF_ID <= instr[15:11];
			Imm_IF_ID <= instr[15:0];
		end
	end
	
	//ID Stage- Regfile, Extend, Controller, ID/EX Reg
	
	controller c(instr_IF_ID, regDst, regWrite, aluSrc, memWrite, memtoReg, branch, aluCtrl, memRead);
		
	// Register File
	regfile  Registerfile(rsReg_IF_ID, rtReg_IF_ID, WrReg_MEM_WB, Result, regWrite_MEM_WB, clk, DataRead1, DataRead2);
	
	mux2#(32) frwrdC(DataRead1 ,Result, forwardC, ReadReg1);
	
	mux2#(32) frwrdD(DataRead2 ,Result, forwardD, ReadReg2);
	
	// Extend block
	extend   Extend_block(Imm_IF_ID, imm_extend);
	
	//Hazard Detection Unit
	HDU hdu(memRead_ID_EX, rtReg_ID_EX, rsReg_IF_ID, rtReg_IF_ID, ID_EX_stall_flush);
	
	always @(posedge clk) begin
		if(reset || ID_EX_stall_flush || ID_EX_flush) begin
			aluSrc_ID_EX <= 0;
			regWrite_ID_EX <= 0;
			memtoReg_ID_EX <= 0;
			branch_ID_EX <= 0;
			memWrite_ID_EX <= 0;
			regDst_ID_EX <= 0;
			aluCtrl_ID_EX <= 0;
			memRead_ID_EX <= 0;
			rtReg_ID_EX <= 0;
			rdReg_ID_EX <= 0;
			rsReg_ID_EX <= 0;
			PCplus4_ID_EX <= 0;
			ReadReg2_ID_EX <= 0;
			ReadReg1_ID_EX <= 0;
			left_shift_Imm_extend_ID_EX <= 0;
			Imm_extend_ID_EX <= 0;
		end
		else begin
			rtReg_ID_EX <= rtReg_IF_ID;
			rdReg_ID_EX <= rdReg_IF_ID;
			rsReg_ID_EX <= rsReg_IF_ID;
			PCplus4_ID_EX <= PCplus4_IF_ID;
			ReadReg2_ID_EX <= ReadReg2;
			ReadReg1_ID_EX <= ReadReg1;
			left_shift_Imm_extend_ID_EX <= {imm_extend[29:0], 2'b00};
			Imm_extend_ID_EX <= imm_extend;
			aluSrc_ID_EX <= aluSrc;
			regWrite_ID_EX <= regWrite;
			memtoReg_ID_EX <= memtoReg;
			branch_ID_EX <= branch;
			memWrite_ID_EX <= memWrite;
			regDst_ID_EX <= regDst;
			aluCtrl_ID_EX <= aluCtrl;
			memRead_ID_EX <= memRead;
		end
	end
	
	//EX Stage - Alu, Branch Target, zero, EX/MEM Reg, Forwarding unit and MUXs
	
	//Write Destination
	mux2#(5)		dstmux(rtReg_ID_EX, rdReg_ID_EX, regDst_ID_EX, WrReg);
	
	//ForwardA Mux
	mux3#(32)	forwardAMux(ReadReg1_ID_EX, Result, aluResult_EX_MEM, forwardA, SrcA);
	
	//ForwardB Mux
	mux3#(32)	forwardBMux(ReadReg2_ID_EX, Result, aluResult_EX_MEM, forwardB, forwardReg2);
	
	// ALU
	mux2#(32)	SrcMux(forwardReg2, Imm_extend_ID_EX, aluSrc_ID_EX, SrcB);
	alu 			ALU(SrcA, SrcB, aluCtrl_ID_EX, aluResult, zero);
	
	//Forwarding Unit
	
	frwrdUnit	FU(rsReg_ID_EX, rtReg_ID_EX, WrReg_EX_MEM, WrReg_MEM_WB, rsReg_IF_ID, rtReg_IF_ID, regWrite_MEM_WB, regWrite_EX_MEM, forwardA, forwardB, forwardC, forwardD);
	
	//Branch address
	adder 		branchAdder(PCplus4_ID_EX, left_shift_Imm_extend_ID_EX, branchTarget);
	
	always @(posedge clk) begin
		if(reset || EX_MEM_flush) begin
			branch_EX_MEM <= 0;
			zero_EX_MEM <= 0;
			memWrite_EX_MEM <= 0;
			regWrite_EX_MEM <= 0;
			memtoReg_EX_MEM <= 0;
			branchTarget_EX_MEM <= 0;
			aluResult_EX_MEM <= 0;
			ReadReg2_EX_MEM <= 0;
			WrReg_EX_MEM <= 0;
		end
		else begin
			branchTarget_EX_MEM <= branchTarget;
			branch_EX_MEM <= branch_ID_EX;
			zero_EX_MEM <= zero;
			aluResult_EX_MEM <= aluResult;
			ReadReg2_EX_MEM <= ReadReg2_ID_EX;
			WrReg_EX_MEM <= WrReg;
			memWrite_EX_MEM <= memWrite_ID_EX;
			regWrite_EX_MEM <= regWrite_ID_EX;
			memtoReg_EX_MEM <= memtoReg_ID_EX;
		end
			
	end
	
	//MEM stage - Data memory, MEM/WB Reg, Branch check
	dataMem dm(aluResult_EX_MEM, ReadReg2_EX_MEM, memWrite_EX_MEM, clk, ReadData);

	branchFlush f(branch_EX_MEM, zero_EX_MEM, ID_EX_flush, EX_MEM_flush);
	
	always @(posedge clk) begin
		if(reset) begin
			regWrite_MEM_WB <= 0;
			memtoReg_MEM_WB <= 0;
		end 
		else begin
			WrReg_MEM_WB <= WrReg_EX_MEM;
			regWrite_MEM_WB <= regWrite_EX_MEM;
			memtoReg_MEM_WB <= memtoReg_EX_MEM;
			aluResult_MEM_WB <= aluResult_EX_MEM;
			ReadData_MEM_WB <= ReadData;
		end
	end
	
	//WB stage - write back mux, regfile write(in previous stages mentioned)
	mux2#(32)	resultMux(aluResult_MEM_WB, ReadData_MEM_WB, memtoReg_MEM_WB, Result);
	
	
endmodule
	
