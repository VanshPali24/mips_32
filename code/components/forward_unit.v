//Forwarding Unit

module frwrdUnit (
	input [4:0] RegRs_ID_EX, RegRt_ID_EX, RegRd_EX_MEM, RegRd_MEM_WB, rsReg_IF_ID, rtReg_IF_ID,
	input regWrite_MEM_WB, regWrite_EX_MEM,
	output [1:0] forwardA, forwardB,
	output forwardC, forwardD 
	);
	reg [1:0] frwrdA, frwrdB;
	reg frwrdC, frwrdD;
	always @(*) begin
		
		if( (regWrite_EX_MEM!=0) && (RegRd_EX_MEM!=0) && (RegRd_EX_MEM == RegRs_ID_EX)) frwrdA = 2'b10;
		
		else if( (regWrite_MEM_WB!=0) && (RegRd_MEM_WB!=0) && ( RegRd_MEM_WB == RegRs_ID_EX )) frwrdA = 2'b01;
		
		else frwrdA = 2'b00;
	
		if( (regWrite_EX_MEM!=0) && (RegRd_EX_MEM!=0) && (RegRd_EX_MEM == RegRt_ID_EX)) frwrdB = 2'b10;
		
		else if( (regWrite_MEM_WB!=0) && (RegRd_MEM_WB!=0) && ( RegRd_MEM_WB == RegRt_ID_EX )) frwrdB = 2'b01;
		
		else frwrdB = 2'b00;
		
		if( (regWrite_MEM_WB!=0) && ( RegRd_MEM_WB == rsReg_IF_ID )) frwrdC = 1'b1;
		
		else frwrdC = 1'b0;
		
		if( (regWrite_MEM_WB!=0) && ( RegRd_MEM_WB == rtReg_IF_ID )) frwrdD = 1'b1;
		
		else frwrdD = 1'b0;
		
		
	end
	
	assign forwardA = frwrdA;
	assign forwardB = frwrdB;
	assign forwardC = frwrdC;
	assign forwardD = frwrdD;
	
endmodule 