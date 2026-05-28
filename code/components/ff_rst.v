// Positive edge triggered D flip-flop with reset

module ff_rst #(parameter width = 32)(
	input      clk,  rst,
	input   [width-1:0] d,
	output reg [width-1:0] q
	);
	
	always @(posedge clk or posedge rst) begin
		q <= rst ? 0 : d;
	end
	
endmodule
		